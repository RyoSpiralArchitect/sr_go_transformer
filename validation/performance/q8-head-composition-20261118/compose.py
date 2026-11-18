#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Compare the production Q8 pair and callback with the ordinary head."""

import argparse
import json
from pathlib import Path
import platform
from statistics import median
import subprocess
import sys

RECORD = Path(__file__).resolve().parent
ROOT = RECORD.parents[2]
ADJACENT = RECORD.parent / "q8-head-adjacent-20261118"
sys.path.insert(0, str(ADJACENT))
from trajectory import constants  # reuses the archived trajectory fixture's schema
from run import isolated_go_environment, read_journal, replace_once, run_measured, sha, validate_completed

HEAD = "linearOutputHeadInto(executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)"
PAIRS = [["reference", "reference"], ["reference", "candidate"]]

HOOK = '''
package main

import (
    "context"
    "time"
)

type adjacentHeadKey struct{}
type adjacentHeadContext struct {
    mode string
    headNS int64
    calls int
}

// Incremented in the isolated runtime by its caller, after the workers join.
var adjacentTiledCalls int

func init() { contextSweepStageProbe = measureHeadTrajectories }

func compositionHead(ctx context.Context, e *kernelExecutor, y, x []float32, w *Param, rows int) {
    timing, _ := ctx.Value(adjacentHeadKey{}).(*adjacentHeadContext)
    if timing == nil {
        linearOutputHeadInto(e, y, x, w, rows)
        return
    }
    started := time.Now()
    if timing.mode == "candidate" {
        linearOutputHeadInto(e, y, x, w, rows)
    } else {
        linearIntoWithExecutor(e, y, x, w, rows)
    }
    timing.headNS = time.Since(started).Nanoseconds()
    timing.calls++
}
'''


def fixture(text, rounds):
    text = replace_once(text, '''if len(prefixes) != 2 || prefixes[0].format != "f16" || prefixes[1].format != "f16" {
		return nil, fmt.Errorf("expected two FP16 sessions")
	}''', '''if len(prefixes) < 1 || len(prefixes) > 2 {
		return nil, fmt.Errorf("expected one or two sessions")
	}
	for _, cache := range prefixes {
		if cache.format != "f16" {
			return nil, fmt.Errorf("expected FP16 KV")
		}
	}''')
    text = replace_once(text, '(round + step + comparison) % 2', '(round/2 + step + comparison) % 2')
    text = replace_once(text, '[]string{"reference", "pair", "triple"}', '[]string{"reference", "candidate"}')
    return text + constants(dict(rounds=rounds, comparisons=PAIRS, order_seed=[0, 1]))


def analyze(samples, reference, sessions, rounds, steps):
    expected = []
    for rnd in range(rounds):
        for i in (rnd % 2, 1 - rnd % 2):
            expected.append((rnd, i, PAIRS[i], [(rnd//2 + step + i) % 2 for step in range(steps)]))
    if [(s['round'], s['comparison'], s['modes'], s['first_arm']) for s in samples] != expected:
        raise ValueError('resident schedule mismatch')
    for row in samples:
        want_dispatches = [steps if sessions == 2 and mode == 'candidate' else 0 for mode in row['modes']]
        if (row['tiled_dispatches'] != want_dispatches or row['logits_sha256'] != [reference['logits_sha256']]*2
                or row['kv_sha256'] != [reference['kv_sha256']]*2):
            raise ValueError('resident dispatch or numerical signature mismatch')
        if len(row['elapsed_ns']) != 2 or len(row['head_ns']) != 2:
            raise ValueError('missing arms')
        for total, head in zip(row['elapsed_ns'], row['head_ns'], strict=True):
            if len(total) != steps or len(head) != steps or any(not 0 < h <= t for t, h in zip(total, head)):
                raise ValueError('invalid per-call timing')

    result = {}
    for stage in ('elapsed_ns', 'head_ns'):
        result[stage] = {}
        for i, name in enumerate(('control', 'candidate')):
            subset = [s for s in samples if s['comparison'] == i]
            sums = [[sum(a) for a in s[stage]] for s in subset]
            ratios = [right/left for left, right in sums]
            strata = {'first_arm': [s['first_arm'][0] for s in subset],
                      'pair_position': [(s['round'] + i) % 2 for s in subset]}
            result[stage][name] = dict(
                median_ratio=median(ratios), ratios=ratios, wins=sum(r < 1 for r in ratios),
                median_ms_per_call=[median(a)/steps/1e6 for a in zip(*sums)],
                strata={key: [median(r for index, r in enumerate(ratios) if labels[index] == group)
                              for group in (0, 1)] for key, labels in strata.items()})
    control = result['elapsed_ns']['control']
    total, head = result['elapsed_ns']['candidate'], result['head_ns']['candidate']
    result['gate'] = (0.97 <= control['median_ratio'] <= 1.03 and
                      (total['median_ratio'] <= 1.03 if sessions == 1 else
                       total['median_ratio'] <= 0.99 and head['median_ratio'] <= 0.95
                       and total['wins'] >= 6 and max(total['strata']['first_arm']) < 1))
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--model', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    env = isolated_go_environment()
    protocol_path = RECORD/'protocol.json'
    protocol = json.loads(protocol_path.read_text())
    spec = protocol['resident']
    host = platform.system()+'/'+platform.machine()
    go = subprocess.check_output(['go', 'version'], env=env, text=True).strip()
    if (host, go.split()[2], env['GOMAXPROCS']) != (protocol['platform'], protocol['go'], str(protocol['workers'])):
        raise ValueError('use the frozen platform, Go version and worker count')
    if (spec['session_order'], spec['prefixes'], spec['kv'], spec['rounds'], protocol['decode_calls']) != (
            [2, 1], [128, 1024], 'f16', 8, 7):
        raise ValueError('unexpected resident fixture settings')
    runtime = ROOT/'cmd/monolith/monolith.go'
    if sha(runtime) != protocol['candidate_runtime_sha256']:
        raise ValueError('use the frozen candidate runtime')
    catalog = ROOT/'validation/hf/model-profiles.json'
    corpus = ROOT/'validation/quality/corpus.json'
    model = next(x for x in json.loads(catalog.read_text())['models'] if x['id'] == protocol['model_id'])
    if model['revision'] != protocol['model_revision']:
        raise ValueError('use the frozen model revision')
    assets = {args.model.resolve()/name: digest for name, digest in model['files'].items()}
    sources = [ROOT/name for name in ('go.mod', 'go.sum', 'cmd/monolith/context_sweep_perf_test.go',
                                      'cmd/monolith/inference_perf_test.go')]
    measure = ADJACENT/'trajectory_test.go.txt'
    inputs = {p: sha(p) for p in (runtime, protocol_path, Path(__file__).resolve(), catalog, corpus, measure,
                                  ADJACENT/'run.py', ADJACENT/'trajectory.py',
                                  *(ROOT/'scripts'/name for name in ('compare_inference.py', 'quant_quality.py',
                                                                    'measure_context_sweep.py', 'context_sweep_timing.py')),
                                  *sources)}
    if any(sha(p) != digest for p, digest in assets.items()):
        raise ValueError('model asset mismatch')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    build = output/'build'
    build.mkdir()
    text = replace_once(runtime.read_text(), HEAD, HEAD.replace('linearOutputHeadInto(executor', 'compositionHead(ctx, executor'))
    dispatch = '\t\te.parallel((w.Rows+31)/32, rows*w.Cols*w.Rows, e.q8HeadFn)'
    text = replace_once(text, dispatch, dispatch+'\n\t\tadjacentTiledCalls++')
    (build/'monolith.go').write_text(text)
    (build/'trajectory_test.go').write_text(fixture(measure.read_text(), spec['rounds']))
    (build/'hook_test.go').write_text(HOOK)
    for source in sources:
        (build/source.name).write_bytes(source.read_bytes())
    staged = {p: sha(p) for p in build.iterdir()}
    binary = build/'probe.test'
    subprocess.run(['go', 'test', '-c', '-trimpath', '-o', binary, '.'], cwd=build, env=env, check=True, timeout=300)
    binary_hash = sha(binary)
    runs = []
    for sessions in spec['session_order']:
        directory = output/f's{sessions}'
        directory.mkdir()
        print(f'Resident FP16 control and candidate, {sessions} session(s)', flush=True)
        run_env = dict(env, MONOLITH_SWEEP_MODEL=str(args.model.resolve()), MONOLITH_SWEEP_CORPUS=str(corpus),
                       MONOLITH_SWEEP_OUTPUT=str(directory), MONOLITH_SWEEP_FORMAT=spec['kv'],
                       MONOLITH_SWEEP_SESSIONS=str(sessions), MONOLITH_SWEEP_LENGTHS=','.join(map(str, spec['prefixes'])))
        with (directory/'probe.log').open('x') as log:
            resources = run_measured([binary, '-test.run=^TestHFContextSweep$', '-test.v', '-test.timeout=12m'],
                                     cwd=build, env=run_env, stdout=log, stderr=subprocess.STDOUT, timeout=750)
        journal = directory/'cases.jsonl'
        events, error = read_journal(journal)
        if error:
            raise ValueError(error)
        validate_completed(events, spec['kv'], sessions, spec['prefixes'], True)
        if events[0]['plan']['weight_format'] != protocol['weights'] or events[0]['workers'] != protocol['workers']:
            raise ValueError('unexpected model weights or executor size')
        cases = [dict(prefix=measure['prefix'], metrics=analyze(stage['replays'], measure['decode'], sessions,
                     spec['rounds'], protocol['decode_calls']))
                 for measure, stage in zip(events[1:-1:3], events[3:-1:3], strict=True)]
        runs.append(dict(sessions=sessions, journal_sha256=sha(journal), resources=resources, events=events, cases=cases))
        print([(c['prefix'], c['metrics']['gate']) for c in cases], flush=True)
    if any(sha(p) != digest for p, digest in (inputs | staged | assets).items()) or sha(binary) != binary_hash:
        raise ValueError('comparison inputs changed')
    receipt = dict(host=host, go=go, model_files=model['files'], binary_sha256=binary_hash,
                   inputs_sha256={str(p.relative_to(ROOT)): digest for p, digest in inputs.items()},
                   build_sources_sha256={p.name: digest for p, digest in staged.items()},
                   gate=all(c['metrics']['gate'] for run in runs for c in run['cases']), runs=runs)
    (output/'receipt.json').write_text(json.dumps(receipt, indent=2, allow_nan=False)+'\n')


if __name__ == '__main__':
    main()

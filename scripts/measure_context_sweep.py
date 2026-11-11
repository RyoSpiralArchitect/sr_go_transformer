#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Measure offline long-context Q4 decode and capture a separate CPU replay."""
import argparse
import json
import math
import platform
from pathlib import Path
import re
import statistics
import subprocess

from compare_inference import isolated_go_environment
from quant_quality import run_measured, sha, source_path


def read_journal(path):
    """Retain complete records even when the process dies during the last write."""
    if not path.exists():
        return [], 'missing journal'
    events = []
    try:
        with path.open() as journal:
            for line in journal:
                events.append(json.loads(line))
    except (UnicodeError, json.JSONDecodeError) as exc:
        return events, str(exc)
    return events, None


def summarize_profile(go, binary, profile, top, env):
    with top.open('x') as log:
        subprocess.run([go, 'tool', 'pprof', '-top', '-cum', '-unit=milliseconds',
                        '-nodecount=0', '-nodefraction=0', '-edgefraction=0', binary, profile],
                       stdout=log, stderr=subprocess.STDOUT, env=env, check=True, timeout=60)
    text = top.read_text()
    total = re.search(r'Total samples = ([\d.]+)ms', text)
    if not total:
        raise ValueError('profile has no CPU samples')
    costs = {}
    # Cumulative samples include the kernels these wrappers call on workers.
    for symbol, key in [('linearQ4Range', 'q4_range_cpu_ms'),
                        ('linearQ8Into.func1', 'q8_worker_cpu_ms'),
                        ('attentionRange', 'attention_range_cpu_ms')]:
        costs[key] = 0.0
        symbol = re.escape(symbol)
        row = re.search(r'^\s+\S+\s+\S+\s+\S+\s+([\d.]+)ms\s+\S+\s+\S*\.' + symbol + r'\s*$',
                        text, re.MULTILINE)
        if row:
            costs[key] = float(row[1])
        elif re.search(r'\.' + symbol + r'\s*$', text, re.MULTILINE):
            raise ValueError('could not read cumulative samples for ' + symbol)
    return dict(total_cpu_ms=float(total[1]), **costs, cpu_profile_sha256=sha(profile))


def validate_completed(events, fmt, sessions, lengths):
    expected = ['start'] + ['measurement', 'profile'] * len(lengths) + ['complete']
    if [e.get('event') for e in events] != expected:
        raise ValueError('unexpected journal event sequence')
    start = events[0]
    if (start['format'], start['sessions'], start['lengths']) != (fmt, sessions, lengths):
        raise ValueError('unexpected sweep parameters')
    config = start['plan']['config']
    kv_dim = config['dim'] // config['heads'] * config['kv_heads']
    for i, length in enumerate(lengths):
        measurement, profile = events[1+i*2:3+i*2]
        d = measurement['decode']
        steps = d['decode_step_seconds']
        pages = (length + 7 + 31) // 32
        kv_bytes = pages * 32 * 2 * kv_dim * config['layers'] * sessions * (2 if fmt == 'f16' else 4)
        if (measurement['prefix'] != length or profile['prefix'] != length or
                profile['file'] != f'decode-{length}.cpu' or
                len(steps) != 7 or any(x <= 0 or not math.isfinite(x) for x in steps) or
                len(d['token_ids']) != sessions or any(len(ids) != 8 for ids in d['token_ids']) or
                d['kv_payload_bytes'] != kv_bytes):
            raise ValueError(f'incomplete or inconsistent {length}-token measurement')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--model', type=Path, required=True, help='local pinned Llama 3.2 3B snapshot')
    parser.add_argument('--output-dir', type=Path, required=True)
    parser.add_argument('--max-prefix', type=int, choices=(128, 1024, 4096), default=4096)
    parser.add_argument('--sessions', type=int, choices=(1, 2), nargs='+', default=[1, 2])
    parser.add_argument('--formats', choices=('f32', 'f16'), nargs='+', default=['f32', 'f16'])
    args = parser.parse_args()
    if len(set(args.sessions)) != len(args.sessions) or len(set(args.formats)) != len(args.formats):
        parser.error('formats and session counts must be unique')
    root = Path(__file__).resolve().parents[1]
    model, output = args.model.resolve(), args.output_dir.resolve()
    catalog = root/'validation/hf/model-profiles.json'
    source = next(m for m in json.loads(catalog.read_text())['models'] if m['id'] == 'llama32-3b')
    def verify_model():
        for name, expected in source['files'].items():
            if sha(model/name) != expected:
                raise ValueError('pinned model differs: '+name)
    verify_model()
    output.mkdir(parents=True, exist_ok=False)
    names = ('monolith.go', 'go.mod', 'go.sum', 'inference_perf_test.go', 'context_sweep_perf_test.go')
    corpus = root/'validation/quality/corpus.json'
    paths = [source_path(root, n) for n in names] + [Path(__file__), corpus, catalog,
             root/'scripts/compare_inference.py', root/'scripts/quant_quality.py', root/'scripts/go.sh']
    def hashes():
        return {str(p.relative_to(root)): sha(p) for p in paths}
    inputs = hashes()
    build = output/'build'
    build.mkdir()
    for name in names:
        (build/name).write_bytes(source_path(root, name).read_bytes())
    env = isolated_go_environment()
    goroot = subprocess.check_output([root/'scripts/go.sh', 'env', 'GOROOT'], cwd=root, env=env, text=True).strip()
    go = Path(goroot)/'bin/go'
    binary = build/'probe.test'
    with (output/'build.log').open('x') as log:
        subprocess.run([go, 'test', '-c', '-trimpath', '-o', binary, '.'], cwd=build, env=env,
                       stdout=log, stderr=subprocess.STDOUT, check=True, timeout=300)
    binary_hash = sha(binary)
    lengths = [n for n in (128, 1024, 4096) if n <= args.max_prefix]
    schedule = [(fmt, n) for index, fmt in enumerate(args.formats)
                for n in (args.sessions if index == 0 else args.sessions[::-1])]
    receipt = dict(format='monolith-context-sweep-v1', model=source['repo'], revision=source['revision'],
                   model_files=source['files'], inputs_sha256=inputs, binary_sha256=binary_hash,
                   host=platform.platform(), cpu=platform.machine(), lengths=lengths, schedule=schedule,
                   go_version=subprocess.check_output([go, 'version'], env=env, text=True).strip(),
                   runs=[])
    failure = False
    for fmt, n in schedule:
        directory = output/f'{fmt}-s{n}'
        directory.mkdir()
        env.update(MONOLITH_SWEEP_MODEL=str(model), MONOLITH_SWEEP_CORPUS=str(corpus),
                   MONOLITH_SWEEP_OUTPUT=str(directory), MONOLITH_SWEEP_FORMAT=fmt,
                   MONOLITH_SWEEP_SESSIONS=str(n), MONOLITH_SWEEP_LENGTHS=','.join(map(str, lengths)))
        print(f'{fmt}, {n} sessions: starting', flush=True)
        run = dict(kv_format=fmt, sessions=n, error=None)
        with (directory/'probe.log').open('x') as log:
            try:
                run['resources'] = run_measured([binary, '-test.run=^TestHFContextSweep$',
                    '-test.v', '-test.timeout=45m'], cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT,
                    timeout=2760, outcome_path=directory/'resources.json')
            except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as exc:
                run['error'] = str(exc)
        journal = directory/'cases.jsonl'
        events, error = read_journal(journal)
        run.update(events=events, journal_error=error, journal_sha256=sha(journal) if journal.exists() else None)
        run['complete'] = bool(events and events[-1].get('event') == 'complete' and not (error or run['error']))
        if run['complete']:
            try:
                validate_completed(events, fmt, n, lengths)
            except (ValueError, KeyError, TypeError) as exc:
                run.update(complete=False, validation_error=str(exc))
        profiles = {}
        for event in events:
            if event['event'] == 'measurement':
                event['decode_median_ms'] = statistics.median(event['decode']['decode_step_seconds'])*1000
            if event['event'] == 'profile':
                profile = directory/event['file']
                try:
                    profiles[event['prefix']] = summarize_profile(go, binary, profile, profile.with_suffix('.txt'), env)
                except (subprocess.SubprocessError, OSError, ValueError) as exc:
                    profiles[event['prefix']] = dict(error=str(exc))
                    failure = True
        run['profiles'] = profiles
        receipt['runs'].append(run)
        failure |= not run['complete']
        print(f'{fmt}, {n} sessions: complete={run["complete"]}', flush=True)
    receipt['identities_unchanged'] = hashes() == inputs and sha(binary) == binary_hash
    try:
        verify_model()
    except (ValueError, OSError) as exc:
        receipt.update(identities_unchanged=False, model_identity_error=str(exc))
    with (output/'receipt.json').open('x') as f:
        json.dump(receipt, f, indent=2, allow_nan=False)
        f.write('\n')
    if failure or not receipt['identities_unchanged']:
        raise SystemExit('Incomplete sweep. Retained results in '+str(output))


if __name__ == '__main__':
    main()

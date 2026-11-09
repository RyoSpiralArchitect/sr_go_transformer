#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Run the frozen offline BF16 KV screen with one immutable resident weight set."""
import argparse
import json
from pathlib import Path
import subprocess

from compare_inference import isolated_go_environment
from quant_quality import sha, run_measured, source_path


def read_quality_report(path):
    """Keep a missing/truncated final report from hiding durable progress."""
    try:
        report = json.loads(path.read_text())
        if not isinstance(report, dict) or report.get('format') != 'monolith-kv16-quality-v1':
            return None, 'Unexpected quality report format'
        return report, None
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        return None, str(exc)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--model', type=Path, required=True)
    p.add_argument('--output-dir', type=Path, required=True)
    a = p.parse_args()
    root = Path(__file__).resolve().parents[1]
    model, output = a.model.resolve(), a.output_dir.resolve()
    catalog = root/'validation/hf/model-profiles.json'
    source = next(x for x in json.loads(catalog.read_text())['models'] if x['id'] == 'mistral-7b-v03')
    for name, expected in source['files'].items():
        if sha(model/name) != expected:
            raise RuntimeError('Pinned source mismatch: '+name)
    protocol = root/'validation/performance/kv16-protocol-20261110.json'
    spec = json.loads(protocol.read_text())
    for name, expected in spec['input_sha256'].items():
        if sha(root/name) != expected:
            raise RuntimeError('Frozen input mismatch: '+name)
    output.mkdir(parents=True, exist_ok=False)
    names = ['monolith.go', 'kv16_quality_test.go', 'go.mod', 'go.sum']
    paths = [source_path(root,n) for n in names] + [protocol, catalog, Path(__file__),
        root/'scripts/quant_quality.py', root/'scripts/compare_inference.py',
        root/'validation/quality/corpus.json', root/'validation/quality/kv16-long-prompts.json']
    hashes = {str(p.relative_to(root)): sha(p) for p in paths}
    build = output/'build'; build.mkdir()
    for n in names:
        (build/n).write_bytes(source_path(root,n).read_bytes())
    env = isolated_go_environment()
    goroot = subprocess.check_output([root/'scripts/go.sh','env','GOROOT'],cwd=root,env=env,text=True).strip()
    go = str(Path(goroot)/'bin/go')
    binary = build/'probe.test'
    with (output/'build.log').open('w') as log:
        subprocess.run([go,'test','-c','-trimpath','-o',binary,'.'],cwd=build,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=300)
    binary_hash = sha(binary)
    env.update(MONOLITH_KV16_MODEL=str(model),MONOLITH_KV16_CORPUS=str(root/'validation/quality/corpus.json'),
        MONOLITH_KV16_PROMPTS=str(root/'validation/quality/kv16-long-prompts.json'),MONOLITH_KV16_OUTPUT=str(output/'quality.json'))
    failure = None
    with (output/'probe.log').open('w') as log:
        try:
            run_measured([str(binary),'-test.run=^TestHFCache16Quality$','-test.v','-test.timeout=32m'],
                cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=1980,outcome_path=output/'resources.json')
        except (subprocess.CalledProcessError,subprocess.TimeoutExpired) as exc:
            failure = str(exc)
    # Preserve a failed gate or timeout alongside verified identities, never retry.
    unchanged = hashes == {str(p.relative_to(root)):sha(p) for p in paths}
    unchanged = unchanged and sha(binary) == binary_hash
    unchanged = unchanged and all(sha(model/n)==v for n,v in source['files'].items())
    report, report_error = read_quality_report(output/'quality.json')
    progress_path = output/'quality.json.progress.jsonl'
    progress = dict(path=progress_path.name, sha256=sha(progress_path)) if progress_path.exists() else None
    receipt = dict(format='monolith-kv16-screen-receipt-v1',model=source['repo'],revision=source['revision'],
        files=source['files'],inputs_sha256=hashes,binary_sha256=binary_hash,identities_unchanged=unchanged,
        go_version=subprocess.check_output([go,'version'],env=env,text=True).strip(),
        failure=failure,report=report,report_error=report_error,progress=progress,resources=json.loads((output/'resources.json').read_text()),
        note='Long-answer review remains separate from numerical gates. All first results retained.')
    with (output/'receipt.json').open('x') as f:
        json.dump(receipt,f,indent=2,ensure_ascii=False,allow_nan=False);f.write('\n')
    if not unchanged or failure or report_error:
        raise RuntimeError('Screen incomplete or gate failed; retained receipt: '+str(output/'receipt.json'))


if __name__ == '__main__':
    main()

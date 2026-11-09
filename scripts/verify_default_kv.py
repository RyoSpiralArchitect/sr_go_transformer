#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Verify current default KV against a retained, source-bound predecessor receipt.

This replays the identical numerical workload once. It makes no timing claim.
"""
import argparse
import hashlib
import json
import platform
from pathlib import Path
import subprocess

from compare_inference import isolated_go_environment, numerical_signature, validate_case_order
from quant_quality import git_source, run_measured, sha, source_path


def reference_signature(receipt, runtime_hash, harness_hash):
    if receipt.get('numerical_identity') is not True:
        raise ValueError('Reference did not pass numerical identity')
    inputs = receipt['builds']['after']['inputs_sha256']
    if inputs['monolith.go'] != runtime_hash or inputs['inference_perf_test.go'] != harness_hash:
        raise ValueError('Reference runtime or harness differs from selected predecessor')
    candidates = [x['report'] for x in receipt['reports'] if x['variant'] == 'after']
    if not candidates:
        raise ValueError('Reference has no candidate reports')
    signature = numerical_signature(candidates[0])
    if any(numerical_signature(x) != signature for x in candidates):
        raise ValueError('Reference candidate results disagree')
    return signature


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--model', type=Path, required=True)
    p.add_argument('--baseline-ref', required=True)
    p.add_argument('--reference-receipt', type=Path, required=True)
    p.add_argument('--output-dir', type=Path, required=True)
    a = p.parse_args()
    root = Path(__file__).resolve().parents[1]
    model, output = a.model.resolve(), a.output_dir.resolve()
    ref_path = a.reference_receipt.resolve()
    baseline = subprocess.check_output(['git','rev-parse','--verify','--end-of-options',a.baseline_ref+'^{commit}'],cwd=root,text=True).strip()
    reference_hash = sha(ref_path)
    previous = json.loads(ref_path.read_text())
    runtime_hash = hashlib.sha256(git_source(root,baseline,'monolith.go')).hexdigest()
    harness = source_path(root,'inference_perf_test.go')
    expected = reference_signature(previous,runtime_hash,sha(harness))
    catalog = root/'validation/hf/model-profiles.json'
    source = next(x for x in json.loads(catalog.read_text())['models'] if x['id']=='mistral-7b-v03')
    if previous['files'] != source['files'] or previous['revision'] != source['revision']:
        raise ValueError('Model reference differs from catalog')
    for name,digest in source['files'].items():
        if sha(model/name) != digest:
            raise ValueError('Pinned model mismatch: '+name)
    corpus = root/'validation/quality/corpus.json'
    if sha(corpus) != previous['source_inputs_sha256']['validation/quality/corpus.json']:
        raise ValueError('Corpus differs from reference')
    output.mkdir(parents=True,exist_ok=False)
    names=['monolith.go','go.mod','go.sum','inference_perf_test.go']
    paths=[source_path(root,n) for n in names]+[Path(__file__),root/'scripts/quant_quality.py',root/'scripts/compare_inference.py',catalog,corpus]
    hashes={str(p.relative_to(root)):sha(p) for p in paths}
    build=output/'build';build.mkdir()
    for n in names:(build/n).write_bytes(source_path(root,n).read_bytes())
    env=isolated_go_environment()
    goroot=subprocess.check_output([root/'scripts/go.sh','env','GOROOT'],cwd=root,env=env,text=True).strip()
    go=str(Path(goroot)/'bin/go');binary=build/'probe.test'
    with (output/'build.log').open('w') as log:
        subprocess.run([go,'test','-c','-trimpath','-o',binary,'.'],cwd=build,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=300)
    binary_hash=sha(binary)
    env.update(MONOLITH_PERF_MODEL=str(model),MONOLITH_PERF_CORPUS=str(corpus),MONOLITH_PERF_FORMAT='q4-mixed',MONOLITH_PERF_CASE_ORDER='1,2',MONOLITH_PERF_OUTPUT=str(output/'result.json'))
    with (output/'probe.log').open('w') as log:
        resources=run_measured([str(binary),'-test.run=^TestHFInferencePerformance$','-test.v','-test.timeout=11m'],cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=700,outcome_path=output/'resources.json')
    report=json.loads((output/'result.json').read_text());validate_case_order(report,[1,2])
    same=numerical_signature(report)==expected
    unchanged=hashes=={str(p.relative_to(root)):sha(p) for p in paths} and sha(binary)==binary_hash and sha(ref_path)==reference_hash
    unchanged=unchanged and all(sha(model/n)==v for n,v in source['files'].items())
    receipt=dict(format='monolith-default-kv-parity-v1',baseline_commit=baseline,baseline_runtime_sha256=runtime_hash,reference_receipt_sha256=reference_hash,
        source_inputs_sha256=hashes,reference_model=source['repo'],revision=source['revision'],files=source['files'],binary_sha256=binary_hash,
        identities_unchanged=unchanged,numerical_identity=same,report=report,resources=resources,
        go_version=subprocess.check_output([go,'version'],env=env,text=True).strip(),host=platform.system()+'/'+platform.machine(),
        note='One numerical replay of the identical 1/2-session workload. Reference after-runtime is bound to the selected Git predecessor. No speed claim.')
    with (output/'receipt.json').open('x') as f:json.dump(receipt,f,indent=2,allow_nan=False);f.write('\n')
    if not same or not unchanged:raise RuntimeError('Default parity failed; retained receipt')


if __name__=='__main__':main()

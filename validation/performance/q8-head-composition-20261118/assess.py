#!/usr/bin/env python3
# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Summarize the short ordinary comparison and validate the resident receipt."""

import argparse
import json
import math
from pathlib import Path
from statistics import median

from compose import RECORD, analyze, validate_completed
from compare_inference import numerical_signature


def ordinary(receipt, protocol):
    build = receipt['builds']
    if (receipt['baseline_commit'] != protocol['baseline'] or receipt['host'] != protocol['platform']
            or receipt['go_version'].split()[2] != protocol['go'] or receipt['revision'] != protocol['model_revision']
            or build['before']['inputs_sha256']['monolith.go'] != protocol['baseline_runtime_sha256']
            or build['after']['inputs_sha256']['monolith.go'] != protocol['candidate_runtime_sha256']):
        raise ValueError('ordinary receipt source, host or model changed')
    reports = receipt['reports']
    if ([(r['variant'], r['report']['case_order']) for r in reports] !=
            [('before', [1, 2]), ('after', [1, 2]), ('after', [2, 1]), ('before', [2, 1])]):
        raise ValueError('ordinary schedule mismatch')

    signatures = [numerical_signature(r['report']) for r in reports]
    exact = all(sig == signatures[0] for sig in signatures)
    if exact != receipt['numerical_identity']:
        raise ValueError('ordinary signature flag differs from its trials')
    summary = {}
    for sessions in (1, 2):
        trials = [next(case['trials'] for case in row['report']['cases'] if case['sessions'] == sessions)
                  for row in reports]
        for row, ts in zip(reports, trials, strict=True):
            r = row['report']
            if ((r['threads'], r['kernel_workers'], r['prefill_tokens_per_session'], r['decode_steps'],
                    r['plan']['weight_format'], len(ts)) !=
                    (protocol['workers'], protocol['workers'], protocol['ordinary']['prefix'],
                     protocol['decode_calls'], protocol['weights'], protocol['ordinary']['trials_per_process_case'])):
                raise ValueError('unexpected ordinary fixture settings')
        row = dict(workspace_exact=len({t['workspace_bytes'] for ts in trials for t in ts}) == 1)
        for key in ('prefill_seconds', 'decode_seconds', 'allocations', 'allocated_bytes', 'workspace_bytes'):
            if any(not math.isfinite(t[key]) or t[key] <= 0 for ts in trials for t in ts):
                raise ValueError(f'invalid ordinary sample: {key}')
            vals = [median(t[key] for t in ts) for ts in trials]
            ratios = [vals[1]/vals[0], vals[2]/vals[3]]
            row[key] = dict(process_medians=vals, pair_ratios=ratios, median_ratio=median(ratios))
        summary[str(sessions)] = row
    passed = (exact and all(r['workspace_exact'] for r in summary.values())
              and all(r['prefill_seconds']['median_ratio'] <= 1.05 for r in summary.values())
              and summary['1']['decode_seconds']['median_ratio'] <= 1.05
              and summary['2']['decode_seconds']['median_ratio'] <= 0.99)
    return dict(gate=passed, sessions=summary)


def resident(receipt, protocol):
    cases = {}
    spec = protocol['resident']
    if (receipt['host'] != protocol['platform'] or receipt['go'].split()[2] != protocol['go']
            or receipt['inputs_sha256']['cmd/monolith/monolith.go'] != protocol['candidate_runtime_sha256']
            or [r['sessions'] for r in receipt['runs']] != spec['session_order']):
        raise ValueError('resident receipt source, host or order changed')
    for run in receipt['runs']:
        sessions, events = run['sessions'], run['events']
        validate_completed(events, spec['kv'], sessions, spec['prefixes'], True)
        for index, recorded in enumerate(run['cases']):
            base, stage = events[1+3*index], events[3+3*index]
            if recorded['prefix'] != base['prefix']:
                raise ValueError('resident case order mismatch')
            metrics = analyze(stage['replays'], base['decode'], sessions, spec['rounds'], protocol['decode_calls'])
            if metrics != recorded['metrics']:
                raise ValueError('resident summary differs from its samples')
            cases[f"s{sessions}-{recorded['prefix']}"] = metrics['gate']
    if len(cases) != len(spec['session_order'])*len(spec['prefixes']):
        raise ValueError('incomplete resident cases')
    gate = all(cases.values())
    if gate != receipt['gate']:
        raise ValueError('resident gate differs from its samples')
    return dict(gate=gate, cases=cases)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('ordinary', type=Path)
    p.add_argument('resident', type=Path)
    args = p.parse_args()
    protocol = json.loads((RECORD/'protocol.json').read_text())
    short = ordinary(json.loads(args.ordinary.read_text()), protocol)
    long = resident(json.loads(args.resident.read_text()), protocol)
    print(json.dumps(dict(ordinary=short, resident=long, timing_gate=short['gate'] and long['gate']), indent=2))


if __name__ == '__main__':
    main()

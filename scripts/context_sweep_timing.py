# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Instrument the staged context sweep build and summarize its paired replays."""
import math
import statistics

STAGE_PROBE_FILES = (
    'testdata/probes/context_sweep_timing.go',
    'testdata/probes/context_sweep_stage_replay_test.go',
)


def instrument_context_sweep(runtime, compare_shared_kv=False):
    """Wrap only the inference call sites in the copied build source."""
    text = runtime.read_text()
    start = text.index('func (m *Model) prefillSelected(')
    end = text.index('\nfunc (m *Model) Step(', start)
    body = text[start:end]

    def replace_once(old, new):
        nonlocal body
        if body.count(old) != 1:
            raise ValueError('context sweep could not locate exactly one call site: '+old)
        body = body.replace(old, new)

    context_check = '\tif ctx == nil {\n\t\treturn nil, errors.New("nil inference context")\n\t}\n'
    replace_once(context_check, context_check+'\ttiming := contextSweepTimingFrom(ctx)\n')
    if compare_shared_kv:
        gate = '\tsharedLanes := min(attention.lanes, c.KVHeads)\n\tif '
        replace_once(gate, gate+'(timing == nil || !timing.referenceKV) && ')
    replace_once('w.attend(executor, c, l, n, attention)',
                 'contextSweepTimedAttention(timing, w, executor, c, l, n, attention)')
    replace_once('linearIntoWithExecutor(executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)',
                 'contextSweepTimedProjection(timing, true, executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)')
    layer_call = 'linearIntoWithExecutor(executor, '
    if body.count(layer_call) != 7:
        raise ValueError('context sweep expected seven layer projection call sites')
    body = body.replace(layer_call, 'contextSweepTimedProjection(timing, false, executor, ')
    runtime.write_text(text[:start]+body+text[end:])


def summarize_stages(replays, compare_shared_kv=False):
    schedule = [False, True, True, False, True, False, False, True]
    if len(replays) != len(schedule):
        raise ValueError('incomplete stage replay')
    wall = {False: [], True: []}
    stage_names = ('layer_projections', 'attention', 'output_projection')
    parts = {mode: {key: [] for key in (*stage_names, 'other')} for mode in wall}
    shared_calls = []
    workspaces = {mode: [] for mode in wall}
    for replay, enabled in zip(replays, schedule):
        timed = enabled or compare_shared_kv
        path = ('candidate' if enabled else 'reference') if compare_shared_kv else None
        if not replay['exact'] or ('timing' in replay) != timed or replay.get('path') != path:
            raise ValueError('stage replay order or exactness mismatch')
        steps = replay['decode']['decode_step_seconds']
        if len(steps) != 7 or any(x <= 0 or not math.isfinite(x) for x in steps):
            raise ValueError('incomplete stage replay timing')
        total_ms = sum(steps)*1000
        wall[enabled].append(total_ms/len(steps))
        if timed:
            measured = 0
            for key in stage_names:
                span = replay['timing'][key]
                if span['elapsed_ns'] < 0 or span['calls'] < 1:
                    raise ValueError('invalid stage interval')
                ms = span['elapsed_ns']/1_000_000
                parts[enabled][key].append(ms/len(steps))
                measured += ms
            if measured > total_ms+0.000001:
                raise ValueError('stage intervals exceed the complete forward interval')
            parts[enabled]['other'].append(max(0, total_ms-measured)/len(steps))
        if compare_shared_kv:
            count = replay['timing'].get('shared_kv_calls', 0)
            if count not in (0, replay['timing']['attention']['calls']) or (count and not enabled):
                raise ValueError('unexpected shared KV dispatch count')
            if enabled:
                shared_calls.append(count)
            workspaces[enabled].append(replay['decode']['workspace_bytes'])
    control = statistics.median(wall[False])
    timed = statistics.median(wall[True])
    stages = {key: statistics.median(values) for key, values in parts[True].items()}
    if compare_shared_kv:
        if len(set(shared_calls)) != 1:
            raise ValueError('candidate replay dispatch differs between pairs')
        reference = {key: statistics.median(values) for key, values in parts[False].items()}
        return dict(reference_ms_per_call=control, candidate_ms_per_call=timed,
                    candidate_over_reference=timed/control,
                    reference_stage_ms_per_call=reference, candidate_stage_ms_per_call=stages,
                    paired_total_ratios=[b/a for a, b in zip(wall[False], wall[True])],
                    paired_attention_ratios=[b/a for a, b in zip(parts[False]['attention'], parts[True]['attention'])],
                    reference_workspace_bytes=max(workspaces[False]),
                    candidate_workspace_bytes=max(workspaces[True]),
                    shared_kv_calls_per_candidate_replay=shared_calls[0])
    return dict(control_ms_per_call=control, timed_ms_per_call=timed,
                timed_over_control=timed/control, stage_ms_per_call=stages)

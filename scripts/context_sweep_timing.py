# Copyright 2026 RyoSpiralArchitect
# SPDX-License-Identifier: Apache-2.0
"""Instrument the staged context sweep build and summarize its paired replays."""
import math
import statistics

STAGE_PROBE_FILES = (
    'testdata/probes/context_sweep_timing.go',
    'testdata/probes/context_sweep_stage_replay_test.go',
)


def instrument_context_sweep(runtime):
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
    replace_once('w.attend(executor, c, l, n, attention)',
                 'contextSweepTimedAttention(timing, w, executor, c, l, n, attention)')
    replace_once('linearIntoWithExecutor(executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)',
                 'contextSweepTimedProjection(timing, true, executor, w.Logits[:heads*c.Vocab], w.N[:heads*d], head, heads)')
    layer_call = 'linearIntoWithExecutor(executor, '
    if body.count(layer_call) != 7:
        raise ValueError('context sweep expected seven layer projection call sites')
    body = body.replace(layer_call, 'contextSweepTimedProjection(timing, false, executor, ')
    runtime.write_text(text[:start]+body+text[end:])


def summarize_stages(replays):
    schedule = [False, True, True, False, True, False, False, True]
    if len(replays) != len(schedule):
        raise ValueError('incomplete stage replay')
    wall = {False: [], True: []}
    parts = {key: [] for key in ('layer_projections', 'attention', 'output_projection', 'other')}
    for replay, enabled in zip(replays, schedule):
        if not replay['exact'] or ('timing' in replay) != enabled:
            raise ValueError('stage replay order or exactness mismatch')
        steps = replay['decode']['decode_step_seconds']
        if len(steps) != 7 or any(x <= 0 or not math.isfinite(x) for x in steps):
            raise ValueError('incomplete stage replay timing')
        total_ms = sum(steps)*1000
        wall[enabled].append(total_ms/len(steps))
        if enabled:
            measured = 0
            for key in ('layer_projections', 'attention', 'output_projection'):
                span = replay['timing'][key]
                if span['elapsed_ns'] < 0 or span['calls'] < 1:
                    raise ValueError('invalid stage interval')
                ms = span['elapsed_ns']/1_000_000
                parts[key].append(ms/len(steps))
                measured += ms
            if measured > total_ms+0.000001:
                raise ValueError('stage intervals exceed the complete forward interval')
            parts['other'].append(max(0, total_ms-measured)/len(steps))
    control = statistics.median(wall[False])
    timed = statistics.median(wall[True])
    return dict(control_ms_per_call=control, timed_ms_per_call=timed,
                timed_over_control=timed/control,
                stage_ms_per_call={key: statistics.median(values) for key, values in parts.items()})

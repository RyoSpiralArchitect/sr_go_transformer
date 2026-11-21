# SwiGLU placement on a resident Llama 3.2 3B

The [synthetic placement screen](../q4-swiglu-placement-20261118/)
found 0.54–2.08% shorter Gate/Up time at four workers but failed its
advance bounds. This separate live diagnostic asks whether that
direction shows up in all-layer decode, with the earlier hold intact.

The candidate keeps the current Q4 block, Gate and Up dispatches,
and every Up write. After a worker writes its Up range, it activates
the two matching Gate slices before the same Up join. A cached method
on the workspace consumes a borrowed weight pointer and clears it
after the join. The executor remains 120 bytes. The fast path requires
Darwin arm64, two rows, an aligned Q4 Up, and a parallel executor
with enough work. The ordinary path handles other shapes and wide
inputs. There is no timing instrumentation in either runtime source.

## Comparison

Llama 3.2 3B uses the pinned BF16 source snapshot, Q4-mixed resident
weights and four workers on Apple M4. The left baseline process keeps
its weights and the prepared cases resident. On the right, a fresh
process in each group holds the same model: baseline, candidate, then
baseline. At most two models are resident. Within a phase each pair
alternates which side runs first, and only one side computes at a time.
A trial measures either the short prefill or seven one-token decode
calls including every layer and the output head. It excludes
tokenization, digesting, sampling and transport. Each child warms
each case once; the left process reuses private suffix pages and its
decode workspace between commands.

The complete journal, source and binary hashes, asset
hashes and timing decisions are retained. The first comparison is used
regardless of outcome; the synthetic and live results are not pooled.

## Live results

Ratios are the medians of elapsed time divided by the resident left
baseline within each pair. A ratio below one is shorter. The same
binary runs on both sides in the first and final control groups.
There are four pairs per control group and eight per candidate group.

| Case | Phase | First control | Candidate | Final control | Candidate wins |
| --- | --- | ---: | ---: | ---: | ---: |
| 1 session, 8 tokens, FP32 KV | Prefill | 0.9951 | 0.9782 | 0.9767 | 4/8 |
| 1 session, 8 tokens, FP32 KV | Decode | 0.9921 | 0.9271 | 1.0531 | 6/8 |
| 2 sessions, 8 tokens, FP32 KV | Prefill | 0.9963 | 1.0089 | 0.8708 | 1/8 |
| 2 sessions, 8 tokens, FP32 KV | Decode | 0.9655 | 0.9509 | 0.8417 | 5/8 |
| 2 sessions, 128 tokens, FP16 KV | Decode | 0.9669 | 1.1595 | 1.0506 | 2/8 |

The 8-token two-session decode median looks 4.91% shorter, but the
candidate-first stratum was 1.0124, the candidate won only 5 of 8
pairs, and both same-path control groups failed in this phase. At
128 tokens the candidate median was 15.95% longer. Neither result
establishes a causal speed change: the one-session decode route
cannot dispatch the trial kernel, yet its candidate ratio is 0.9271.
The two-session prefixes also use different KV formats, so the
comparison does not isolate context length. Prefill stays on the
ordinary path on these prompts and is a non-eligible control.

**Decision: keep the ordinary runtime.** The screen is complete
and memory stayed within its bounds (44% minimum free at the
recorded checkpoints; zero new swapouts). The stable-controls and
positive-speed gates failed. All 160 timing arms produced identical
full logit/KV digests, token IDs, positions and workspace capacity
within each case and phase. Allocation count medians for the
candidate's decode were 14 per seven calls on both sides; the
experiment did not reduce KV or workspace capacity. The candidate
adds two pointer-sized workspace fields but does not grow the
worker executor or float arrays. No serving, TTFT or CPU-provider
speed claim follows from these timings.

On the exact measured runtime, targeted race tests passed for
warm allocation-free dispatch, rounded range tails, the ordinary
fallback and clearing the borrowed weight after the join. The
long-context check also matched full logits, stored Up and KV
in FP32 and FP16 while group-of-four attention borrowed Up at
four workers. Both measured binaries reproduced byte for byte.
Both the earlier synthetic timing gate and this live gate remain failed.

If this direction is revisited, a short single-residency diagnostic
with a timed selector outside the measured call could identify
scheduler variation separate from process placement. Such a run
would help attribute a mechanism; it would not replace comparison
against an uninstrumented runtime. At the current effect size, a
larger bottleneck is a better target for the next default change.

## Reproduce

Use the archived checkout, Apple M4 with Go 1.27.1, and a populated Go
module cache. Set MODEL_SNAPSHOT to the local snapshot from the repo's
model catalog. The runner verifies every pinned model file before
building. The build and run are offline.

```sh
record=validation/performance/q4-swiglu-live-20261118
mkdir -p runs
PYTHONDONTWRITEBYTECODE=1 python3 -S "$record/live.py" --model "$MODEL_SNAPSHOT" --output runs/swiglu-live-reproduce
PYTHONDONTWRITEBYTECODE=1 python3 -S "$record/assess.py" runs/swiglu-live-reproduce/events.jsonl
sh "$record/verify.sh" runs/swiglu-live-reproduce runs/swiglu-live-verify
```

[Protocol](protocol.json) · [Journal](events.jsonl) · [Decision](assessment.json) ·
[Run identity](receipt.json)

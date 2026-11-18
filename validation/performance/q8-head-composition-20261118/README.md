# Pairing the Q8 output head on top of the two-row Q4 runtime

This experiment applies the paired output kernel from the earlier [Q8
study](../q8-output-head-20261118/) to a large aligned Q8 vocabulary
projection with exactly two selected rows and a pooled executor on
Apple Silicon. It also reuses the executor's callback and clears the
borrowed job when the workers join. The two-row Q4 layer kernels are
already in the baseline and are identical in both builds. The experiment
does not include either three-output kernel.

**Decision: keep the production runtime unchanged.** The first ordinary
runtime comparison failed the frozen timing gate, and the extra callback
field exceeded the executor footprint bound. The patch and both sets of
samples are retained for a new confirmation of the head and callback as
separate changes.

## Full runtime, short FP32 KV workload

The probe ran Llama 3.2 3B Q4-mixed on an Apple M4 with four workers. Each
process started with the same pinned checkpoint, used eight prompt tokens
per session, warmed each case and timed three trials of prefill plus seven
decode calls. The two process pairs used opposite runtime order and
opposite session order. Each pair compares per-process trial medians.

| Stage | Sessions | Candidate / reference, cases 1 then 2 | Candidate / reference, cases 2 then 1 | Median of pairs |
| --- | ---: | ---: | ---: | ---: |
| Prefill | 1 | 1.036 | 1.240 | 1.138 |
| Decode | 1 | 1.002 | 1.850 | 1.426 |
| Prefill | 2 | 1.259 | 1.000 | 1.130 |
| Decode | 2 | 1.219 | 0.993 | 1.106 |

All generated token IDs, full logit and KV digests and workspace capacities
matched across the 24 measured trials. The median two-session allocation
counts were 31 and 30 for the two reference processes and 22 for each
candidate process, over prefill and seven decode calls. Cumulative
allocated bytes moved by about 0.9–1.0 KiB, and process peaks overlapped
(about 2,169–2,179 MiB). This is an allocation count reduction; it does
not establish an elapsed time or peak-memory improvement.

The specialized head cannot dispatch with one selected row. The large
one-session timing changes despite that fallback, and the sign change in
two-session decode, motivate a closer control. This run has no
reference/reference process pairs, so it cannot identify the cause of
the variation. It remains part of the adoption decision.

## Shared process, FP16 KV workload

The second comparison held the checkpoint and worker pool in memory and
alternated the two head paths on branches of the same KV prefix. It
measured seven decode calls per arm. In each of eight rounds per case it
also compared the reference path with itself. Pair position and starting
arm were crossed. This measurement includes the rest of each decode call
and the probe's timing hook, but excludes prefill; it does not replace
timings from the ordinary runtime.

Each cell is the median of paired elapsed-time ratios (below 1 is
shorter). Wins count pairs with shorter candidate decode time.

| Sessions | Prefix per session | Q8 head | Full decode | Same-path full decode | Decode wins |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 128 | 0.971 | 0.987 | 1.000 | 6 / 8 |
| 1 | 1,024 | 1.004 | 1.017 | 1.015 | 1 / 8 |
| 2 | 128 | 0.830 | 0.947 | 1.007 | 6 / 8 |
| 2 | 1,024 | 0.800 | 0.960 | 0.978 | 8 / 8 |

Both two-session cases passed the resident bounds. At prefix 128 the
median full-decode ratios split by where the experimental pair ran in
the round were 0.994 and 0.895; at prefix 1,024 they were 0.968 and
0.947. Both single-session cases dispatched zero paired kernels and
stayed within the 3% bound. Token IDs, logits, KV state, positions and
workspace matched in the trajectories. These results support following
up on the two-row head, but the frozen decision requires both workload
comparisons to pass.

## Candidate checks

The exact measured patch was applied to a separate copy of the baseline.
The focused race tests passed for exact outputs, odd output tails,
fallbacks, clearing the borrowed slices after join, and zero warm
allocations in the paired head alone. Formatting, vet, the 88 Python
tests, isolated probe builds, the cgo-free CLI build and smoke tests also
passed.

The full Go race suite failed `TestProjectionDescriptorFootprint` on a
second run with the same candidate. It measured a 128-byte executor where
the existing bound is 120 bytes; the targeted baseline test measured 120
bytes and passed. The extra `q8HeadFn` field accounts for the difference.
This result is an independent reason to hold the patch even if the timing
is confirmed later.

## Next confirmation

1. Alternate two **unmodified** test executables while each holds its own
   warmed checkpoint, so load and prefill do not separate the two timed
   decode arms. Include same-path process pairs in the identical schedule,
   and pair independent prefill trials separately. Freeze the case order
   and bounds before timing.
2. Compare the two-output head alone against the same head sharing
   the existing Q4 callback slot. Let each worker choose the range
   function once per job from the weight format, and keep the executor at
   120 bytes. Measure one and two sessions, including effects on Q4.
   Keep bit equality, workspace and callback-lifetime checks, and repeat
   on a pinned large-vocabulary 7B checkpoint after the M4 3B controls hold.
3. Profile the combined winner before choosing a second layer optimization.
   The [post-Q4 profile](../post-q4-output-profile-20261112/) leaves layer
   projections as the largest stage. One experiment can compute Gate and
   Up per output tile with the shared input and consume the Up result on
   that worker, then join once before Down. Compare this with separate
   dispatch, measuring Gate/Up, Down, and total separately. The earlier
   [grouped-dispatch attempt](../../../docs/grouped-projection-experiment.md)
   combined job submission but kept separate matrix arithmetic; its
   inconsistent results are not evidence for this new candidate.

## Reproduction

Use a fresh worktree of the commit containing this record. Keep the
baseline in the local Git history. The measurement used Go 1.27.1 on
Darwin/arm64, Python 3.10 or later, and the pinned local `llama32-3b`
snapshot from the model catalog. Populate the Go module cache before the
offline builds. Use unused output paths and run the measurements in
sequence.

```sh
RECORD=validation/performance/q8-head-composition-20261118
git apply --check "$RECORD/candidate.patch"
git apply "$RECORD/candidate.patch"
GOENV=off GOWORK=off GOFLAGS= GOTOOLCHAIN=local go mod download
mkdir -p runs
python3 -S scripts/compare_inference.py --model "$MODEL_SNAPSHOT" \
  --id llama32-3b --baseline-ref 68810f7a59d85944575d4a5fa3100e85d1ca8789 \
  --case-order balanced --output-dir runs/q8-head-ordinary
python3 -S "$RECORD/compose.py" --model "$MODEL_SNAPSHOT" \
  --output runs/q8-head-resident
python3 -S "$RECORD/assess.py" runs/q8-head-ordinary/receipt.json \
  runs/q8-head-resident/receipt.json
```

[Protocol](protocol.json) · [Ordinary receipt](ordinary-receipt.json) ·
[Resident receipt](resident-receipt.json) · [Gate assessment](assessment.json) ·
[Candidate patch](candidate.patch)

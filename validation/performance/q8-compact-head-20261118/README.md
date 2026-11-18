# Q8 output pair with an unchanged executor footprint

The earlier [composition trial](../q8-head-composition-20261118/) used
a third callback slot and raised the executor from 120 to 128 bytes.
This follow-up compares two exact alternatives at the original
120 bytes. Both keep the same aligned, large-vocabulary, two-row
Darwin arm64 head gate and use the same paired inner loop.

- **Pair:** The new head alone; each invocation borrows its own job.
- **Shared:** The same head uses the Q4 callback slot. Each worker
  branches once on the borrowed weight format. The owner clears the
  descriptor after the join; other platforms keep the Q4 range path.

**Decision: hold both variants.** The resident screen finished only
part of the frozen workload. In both cases with six pairs, the pair
kernel won four times, below the required five. The shared kernel
was 9.3% slower in the completed short two-session pairs. The
available results do not qualify either variant for a 7B run.

## Uninstrumented full runtime

The executable has no timers inside the production runtime. The probe
times core forward calls only: prefill separately, and then seven
one-token decode calls from the same checkpoint. Weight loading,
tokenization, greedy selection and digesting are outside the intervals.
For decode, each process prepares its own prefix and reuses private
KV pages; prior suffixes are overwritten. All variants use the pinned
Llama 3.2 3B Q4-mixed snapshot and four workers on an Apple M4.

The [four-process attempt](four-process/journal.jsonl) stopped after the
host recorded 150,412 new swapouts of 16 KiB during startup, about
2.30 GiB. No timings from that attempt enter the decision.

The [two-process protocol](pairs.json) loads at most two models and
runs only one command at a time. Case and comparison order reverse in
the second block and the first arm alternates within each phase. There
were zero additional swapouts and a 62% minimum free-memory reading
at recorded checkpoints. The 15-minute limit stopped the run before the
second shared one-session case, the second control group, and the
direct shared/pair group. The incomplete journal is retained.

Elapsed ratios below 1 are shorter. The count in parentheses is the
number of pairs with the right arm faster. The table shows all
completed pairs, including the shorter control block and only three
one-session shared pairs.

| Workload | Same binary | Pair / reference | Shared / reference |
| --- | ---: | ---: | ---: |
| FP32 KV, 1 session, 8-token prefill | 1.003 (1/3) | 1.032 (3/6) | 1.037 (0/3) |
| FP32 KV, 1 session, 8-token prefix decode | 0.982 (2/3) | 1.001 (2/6) | 1.025 (0/3) |
| FP32 KV, 2 sessions, 8-token prefill | 0.996 (2/3) | 1.006 (2/6) | 1.051 (2/6) |
| FP32 KV, 2 sessions, 8-token prefix decode | 1.008 (1/3) | 0.987 (4/6) | 1.093 (2/6) |
| FP16 KV, 2 sessions, 128-token prefix decode | 0.997 (2/3) | 0.934 (4/6) | 0.973 (4/6) |

All 138 measured arms matched their warm-up checkpoints, including
full logit and KV digests, generated IDs, committed positions and
workspace capacity. In each two-session decode case, the pair variant
allocated seven more objects per seven calls than reference; shared
allocated seven fewer. Allocation counts do not establish peak RSS or
elapsed-time gains.

## Direct shared-slot comparison

A separate, bounded follow-up ran only the missing pair/shared
comparison. Both runtimes stayed loaded. There were four pairs per
phase in alternating order, exact signatures for all 40 measured
arms, and zero additional swapouts.

| Workload | Shared / pair elapsed | Pair / shared median allocations |
| --- | ---: | ---: |
| FP32 KV, 1 session, 8-token prefill | 0.993 | 5 / 4 |
| FP32 KV, 1 session, 8-token prefix decode | 1.008 | 14 / 14 |
| FP32 KV, 2 sessions, 8-token prefill | 1.004 | 8 / 6 |
| FP32 KV, 2 sessions, 8-token prefix decode | 1.016 | 21 / 7 |
| FP16 KV, 2 sessions, 128-token prefix decode | 1.076 | 21.5 / 7 |

Sharing reclaimed about 0.55–0.60 KiB of cumulative allocation per
seven-call two-session trace. Its 128-token median exceeded the
1.03 pair-to-shared overhead bound. The follow-up does not replace
the missing same-binary block or reopen the adoption screen.
[Direct protocol](direct.json) · [Samples](direct-journal.jsonl) ·
[Assessment](direct-assessment.json)

## Compatibility and next experiment

The measured sources passed targeted race tests at 120 bytes without
relaxing the existing footprint guard. The tests cover a Q8-first
executor followed by Q4 and Q8 calls, odd tail output, nil and one-worker
fallback, unaligned columns, one and three input rows, wide sums and
post-join descriptor clearing. Warm Q4 and Q8 together allocate zero
objects in the shared route.

Preparing full prefixes repeatedly cost more time than planned.
Before any new adoption run, reuse the unchanged reference's warm
checkpoint between comparisons, avoid beginning with a long prefill,
and set a budget that includes each variant's prefix warm-up. Keep a
same-binary pair in each order. The 7B test is conditional on a complete
3B pass; no weights were downloaded or run for it here.

## Reproduction

Use the record checkout with the baseline runtime and Go 1.27.1 on
Apple M4. Populate the Go module cache, then supply the pinned local
model directory as `MODEL_SNAPSHOT`. The four-process driver is retained
for its build hashes; the commands below only rebuild the executables
and use the two-process driver.

```sh
record=validation/performance/q8-compact-head-20261118
mkdir -p runs
python3 -S "$record/rebuild.py" --output runs/q8-builds-reproduction
python3 -S "$record/pairs.py" --model "$MODEL_SNAPSHOT" \
  --builds runs/q8-builds-reproduction --output runs/q8-pairs-reproduction
python3 -S "$record/assess.py" --incomplete "$record/two-process-journal.jsonl"
python3 -S "$record/direct.py" --model "$MODEL_SNAPSHOT" \
  --builds runs/q8-builds-reproduction --output runs/q8-direct-reproduction
python3 -S "$record/assess.py" --direct "$record/direct-journal.jsonl"
sh "$record/verify.sh" pair runs/q8-verify-pair
sh "$record/verify.sh" shared runs/q8-verify-shared
```

[Inputs](protocol.json) · [Two-process journal](two-process-journal.jsonl) ·
[Assessment](two-process-assessment.json) · [Candidate builder](variants.py) · [Run identity](receipt.json)

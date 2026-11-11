# Long-context decode sweep

This offline probe uses the existing pinned Llama 3.2 3B checkpoint in
Q4-mixed format. Each process loads one model and uses four kernel workers.
The default sweep covers 128, 1,024 and 4,096 input tokens, one or two
sessions, and FP32 or FP16 KV. It requires a local snapshot matching the
hashes in the model catalog. The probe performs no downloads.

```sh
python3 -S scripts/measure_context_sweep.py \
  --model /path/to/pinned-llama32-3b \
  --output-dir runs/context-sweep
```

Use `--max-prefix 128` for a short preflight, or restrict a run with
`--sessions 1` and `--formats f32`. Use a new output directory each time.

Each session uses the tokenized first or second evaluation passage.
After the initial framing, the probe repeats the passage body as token
IDs and cuts it at exact lengths. Prefill advances in chunks of 32
tokens per session and records the accumulated time spent in forward
calls. It computes output logits at the selected checkpoints. Each
decode replays seven single-token forward calls starting at that
checkpoint. The decode branch shares the prefix's whole pages and
writes new rows into its own pages. The prefix remains available for
the next checkpoint. Each of two sessions has its own prefix and pages.

The receipt records per-step forward times, generated IDs, prompt and
logits hashes, the hash of committed KV rows in their stored format,
allocated KV payload bytes and workspace capacity. The first ID comes
from prefill logits. The probe feeds a fixed number of IDs even at EOS.
Timings exclude loading, tokenization, sampling, hashing and HTTP.

A separate decode replay produces a CPU profile at each length. The
profile's IDs must match the timed replay. The driver reports inclusive
samples for the Q4 worker, Q8 worker and attention worker where present.
These are CPU samples across threads. They cannot be added to or
subtracted from a wall-clock decode interval. A short profile can miss a
small kernel. Raw profiles and symbol tables stay in the output directory.

Each case's timing and profile completion are synced to a journal. The
driver retains complete events after a failure or timeout and marks the
run incomplete. The output also records binary and source hashes and
rechecks the pinned model and build identity after execution.

The first Apple M4 baseline used Go 1.27.1 and the pinned Llama 3.2 3B
Q4-mixed snapshot. One FP32 session reached all three lengths. The
128-token pilot also covered two sessions and both KV formats.

| Input tokens | Accumulated prefill | Median decode call | KV payload after decode | Q8 worker samples | Attention worker samples |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 128 | 16.46 s | 142.24 ms | 35 MiB | 650 ms | 0 sampled |
| 1,024 | 154.12 s | 172.24 ms | 231 MiB | 610 ms | 40 ms |
| 4,096 | 796.32 s | 292.41 ms | 903 MiB | 640 ms | 270 ms |

The two independent 128-token FP32 single-session runs matched prompt
hashes, logits hashes, stored KV hashes and generated IDs. In the
128-token pilot, FP16 halved the KV payload from 35 to 17.5 MiB for one
session and from 70 to 35 MiB for two. The long baseline covers FP32
with one session. The preflight pilot used an earlier driver without
Q8 profile aggregation, with the same runtime and Go harness.

At 4,096 tokens the profile records more attention samples, and the Q8
worker still has more samples than attention. The brief CPU replays
recorded substantial scheduler samples and uneven Q4 samples across
lengths. Use the sampled breakdown to choose a follow-up measurement,
with paired wall-clock comparisons for any optimization decision.

The receipts are in
[`validation/performance/context-sweep-20261110`](../validation/performance/context-sweep-20261110/).

## Paired stage timings

Use `--stage-timing` to replay each checkpoint eight times from the
same committed KV prefix. Each replay checks all recorded logits,
stored KV and generated IDs against that checkpoint's reference.
The timer order is off/on/on/off/on/off/off/on. The first replay
already has a warm decode workspace from the reference call.

For this mode the driver wraps call sites in the copied standalone
build source. The receipt includes the original source, compiled copy
and binary hashes. The test-only
timer context is read by the owner of each forward call. A stage
finishes after its workers join, so each duration includes dispatch
and synchronization as well as its computation.

The stage summaries contain elapsed wall time for layer projections,
attention, output projection and the remaining forward work. The
output projection in the pinned Q4-mixed Llama profile uses Q8
weights. Summaries use the median of four replay averages per mode
and report milliseconds per batched decode call. They also retain
all eight timing records and exactness hashes.

Compare the timer-enabled total with the disabled total before
interpreting the stage durations. A ratio outside 0.95–1.05 marks a
timing disturbance to investigate. Preserve every case and the first
completed attempt. Both modes execute the same instrumented binary,
with clock reads enabled or disabled. Their ratio also includes
replay-to-replay variation. Use the existing paired comparison drivers
with the ordinary runtime to evaluate a future optimization.

### Recorded M4 stage sweep

The 2026-11-11 primary sweep completed all three checkpoints on an
Apple M4 with four threads, four kernel workers, one session,
Q4-mixed Llama 3.2 3B and FP32 KV. All 24 replays matched their
checkpoint's logits, committed KV hash, payload bytes and generated
IDs. Each checkpoint also reproduced the prompt, logits, KV and IDs
from the preceding context-sweep receipt. Source, model, compiled
copy and binary identities passed the before/after checks.

Totals are medians of four replay averages in milliseconds per decode call.

| Prefix tokens | Timers off | Timers on | On/off ratio | Ratio screen |
| --- | ---: | ---: | ---: | --- |
| 128 | 393.244 | 368.524 | 0.937 | Affected |
| 1,024 | 539.884 | 539.132 | 0.999 | Within range |
| 4,096 | 529.384 | 532.461 | 1.006 | Within range |

Stage values are medians of the four timer-enabled replay averages.
Compute each replay's remainder before taking its median.

| Prefix tokens | Layer projections | Attention | Q8 output projection | Remainder |
| --- | ---: | ---: | ---: | ---: |
| 128 | 282.276 | 7.242 | 75.362 | 3.930 |
| 1,024 | 350.920 | 100.114 | 84.218 | 5.351 |
| 4,096 | 196.816 | 279.568 | 49.005 | 2.057 |

The 128-token pilot used the same binary hash and recorded 141.129 ms
with timers off and 138.087 ms with timers on, ratio 0.978. The primary
process shows substantial elapsed-time variation. Its 4,096-token
control averages span 362.075–634.042 ms. The ratio screen uses
mode medians. These observations describe the
recorded host and replay schedule. An optimization decision requires
a fresh paired comparison using the ordinary runtime.

Attention has the largest recorded stage median at 4,096 tokens.
Shared GQA KV reads and page traversal are follow-up candidates for
measurement. The receipt retains every replay, including the affected
128-token case, together with the frozen protocol and pilot in
[`validation/performance/context-stage-timing-20261111`](../validation/performance/context-stage-timing-20261111/).

## Shared KV reads for grouped-query attention

Single-row forwards on Darwin arm64 can share FP32 or FP16 KV reads
across three query heads with a 128-element head dimension. Selection starts
at a visible context of 1,024 positions and requires room for two
score vectors per lane in the existing logits buffer. Each lane owns
whole KV head groups. Its key and value passes traverse pages in tiles
of four positions, sharing each load across the three query heads.
Each head keeps its dimension and position reduction order.

The logits buffer supplies the two extra score vectors until the
attention workers join. The output projection then writes the logits
in their normal slots. Selective prefill clears the logits when it
skips the projection. Workspace admission counts the same buffers.

Run the paired comparison against the per-head path with both stage
timers enabled.

```sh
python3 -S scripts/measure_context_sweep.py \
  --model /path/to/pinned-llama32-3b \
  --compare-shared-kv --formats f32 --sessions 1 \
  --output-dir runs/gqa-f32-long
```

The copied build disables sharing for the reference arm and uses normal
runtime selection for the candidate. Both arms use the same committed
prefix, model, workspace and clock reads. The receipt includes the
actual shared-path call count, workspace capacity, all eight replay
records and adjacent-pair ratios. At 128 tokens both arms use per-head
attention, giving a same-path timing control.

The exploratory M4 microbenchmark used a synthetic one-layer KV cache
with 24 query heads, eight KV heads, one row and four workers. At
4,096 positions the per-call median was 4.315 ms for the per-head
kernel and 1.189 ms for shared KV. The benchmark selected the kernel
directly at each length. The protocol and raw benchmark output are in
[`validation/performance/gqa-shared-kv-20261111`](../validation/performance/gqa-shared-kv-20261111/).

### Recorded M4 FP32 shared-KV comparison

The paired run used the pinned Llama 3.2 3B checkpoint, Q4-mixed
weights, FP32 KV, one session and four workers on an Apple M4.
Each timing below is the median of four replay averages, in
milliseconds per decode call.

| Prefix tokens | Reference attention | Candidate attention | Reference total | Candidate total | Workspace bytes per path |
| --- | ---: | ---: | ---: | ---: | ---: |
| 128 | 2.822 | 2.893 | 153.979 | 158.105 | 638,464 |
| 1,024 | 21.454 | 8.685 | 165.164 | 152.086 | 652,800 |
| 4,096 | 139.019 | 37.045 | 274.235 | 178.251 | 701,552 |

At 4,096 positions the median attention time fell by 73.4% and the
complete decode time fell by 35.0%. All four adjacent pairs favored
shared KV for both measurements. The complete decode ratios in
those pairs ranged from 0.633 to 0.667. The 1,024-token comparison
also passed the frozen timing criteria.

The 128-token same-path control had a candidate/reference median
ratio of 1.027 and adjacent-pair ratios of 0.973–1.102. The receipt
retains every pair. The candidate recorded 196 shared attention
calls per replay at 1,024 and 4,096 tokens and zero at 128 tokens.

All 24 replays matched their checkpoint's logits, committed KV,
payload bytes and generated IDs. Each checkpoint reproduced the
preceding stage sweep's prompt, logits, KV and generated IDs.
Source, compiled copy, binary and pinned model hashes passed the
identity checks. The full run is recorded in
[`f32-s1-long.json`](../validation/performance/gqa-shared-kv-20261111/f32-s1-long.json).

### Shared FP16 KV widening

The grouped kernel specializes on the KV storage type. It widens
each FP16 key or value once for the three query heads. Each head's
dot product, softmax and value accumulation use the same arithmetic
and reduction order as per-head FP16 attention. Score vectors borrow
the same logits and attention workspace.

Use `--formats f16 --sessions 1 --compare-shared-kv` to compare the
shared and per-head paths on a single committed FP16 prefix. The
exploratory one-layer M4 benchmark measured 8.201 ms and 4.208 ms
per call for per-head and shared attention at 4,096 positions.
The FP32 compatibility comparison used the same one-layer benchmark
with a Go source overlay for the preceding runtime. Its median ratios
for the shared path were 1.011 at 1,024 and 1.006 at 4,096 positions.
Raw samples, binary hashes and the full-model protocol are in
[`validation/performance/gqa-shared-kv-f16-20261111`](../validation/performance/gqa-shared-kv-f16-20261111/).

The paired model run used the pinned Llama 3.2 3B checkpoint, Q4-mixed
weights, one FP16 KV session and four workers on an Apple M4. Timings
are medians of four replay averages in milliseconds per decode call.

| Prefix tokens | Per-head attention | Shared attention | Per-head total | Shared total | Workspace bytes per path | FP16 KV payload MiB |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 128 | 8.740 | 8.679 | 149.514 | 147.806 | 638,464 | 17.5 |
| 1,024 | 88.294 | 45.225 | 274.874 | 219.962 | 652,800 | 115.5 |
| 4,096 | 302.814 | 148.903 | 459.135 | 300.968 | 701,552 | 451.5 |

At 4,096 tokens the median attention time fell by 50.8% and the
complete decode time fell by 34.4%. All four adjacent pairs favored
shared KV. Their complete decode ratios ranged from 0.624 to 0.667.
At 1,024 tokens three of four complete decode pairs favored shared
KV, with one ratio of 1.018. Both lengths met the frozen timing
criteria. The 128-token same-path control had a median ratio of
0.989. The receipt retains every pair.

All 24 FP16 replays matched their checkpoint's logits, stored KV,
payload bytes and generated IDs. The 128-token reference matched
the preceding FP16 pilot. Candidate replays at 1,024 and 4,096 each
recorded 196 shared layer calls. Source, model, binary and journal
identity checks passed. [Full FP16 receipt](../validation/performance/gqa-shared-kv-f16-20261111/f16-s1-long.json).

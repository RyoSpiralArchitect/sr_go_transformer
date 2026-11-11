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
build source. The checked-in runtime stays byte-identical. The copied
source and binary hashes are included in the receipt. The test-only
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
timing disturbance to investigate. It does not discard the case or
trigger an automatic rerun. Both modes share the instrumented
binary, so this contrast measures clock-read overhead within that
binary. Compare a future optimization with the ordinary runtime
using the existing paired comparison drivers.

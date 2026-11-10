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

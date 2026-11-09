# Inference buffer lifetimes

Cached decode and chunked prefill reuse storage once its previous readers have
finished. The engine's fixed workers join before the actor changes a buffer's
role. Public calls use request-exclusive pooled scratch with the same rule.

| Storage | First use | Later use |
| --- | --- | --- |
| Q | Query projection, RoPE and attention input | Attention output projection, FFN down projection, final selected-row compaction |
| Gate | Gate projection | In-place SwiGLU result (GELU for GPT-2), then down-projection input |

Q is never reused while attention still reads it. Gate and Up projections read N;
the activated Gate is consumed only after both projections have completed.
Residual additions read Q and write X. Matrix inputs and outputs remain distinct.
The elementwise formulas, reduction order, quantization policy, model parameters,
KV contents, training and evaluation paths are unchanged.

## Memory accounting

For `R` flattened rows, rotary inference previously held
`R * (5*Dim + 2*KVDim + 3*Hidden)` float elements plus logits and attention scores.
It now holds `R * (4*Dim + 2*KVDim + 2*Hidden)` plus those same arrays. GPT-2 has
one fewer Hidden array in each formula because it does not use an Up projection.
The reduction is `4 * R * (Dim + Hidden)` bytes. Capacities are reused across
requests; the 512 MiB budget still includes retained capacities and reserves a
public result copy. Admission is checked before allocating KV pages. The
workspace gauge counts each backing array once, and shutdown still releases it.

For Mistral 7B geometry (`Dim=4096`, `Hidden=14336`, `KVDim=1024`), 1,024 active
rows require 184 MiB instead of 256 MiB for these arrays: a 72 MiB reduction.
This is a geometry calculation, not a 1,024-row execution or process RSS result.
It excludes logits, attention scores, metadata, weights and KV. Activation
scratch was already reused through all layers; model weights and KV still scale with
layer count. This change does not raise supported model-size limits.

## Validation

`inference_liveness_test.go` compares logits and KV float bits against a separate
unaliased forward reference. Synthetic 32/64-layer models exercise FP32, Q8,
Q4 and mixed Q4/Q8, nil/one/four-worker dispatch, mixed session lengths,
attention lanes, page crossings, dirty scratch and selective/skipped heads.
Small HF GPT-2, Qwen2, Llama 3 and Mistral fixtures also exercise biases, learned
positions and RoPE. A depth test checks actual retained scratch at 1/32/64 layers.
The synthetic deep tests establish storage correctness, not trained-model quality.

The real-model comparison uses `scripts/compare_inference.py` with identical
probes against baseline `3c0ab74` and this runtime, Mistral-7B-Instruct-v0.3,
Q4-mixed, offline mode and balanced AB/BA order. Numerical signatures contain
all logits/KV hashes and generated IDs; workspace sizes remain in every raw
report as resource measurements rather than numerical outputs.

## Mistral 7B result (2026-11-10)

Apple M4 / Darwin arm64, Go 1.27.1, four Go threads and fixed workers. The pinned
32-layer model ran in Q4-mixed format using existing local weights. Four processes
ran before/after/after/before, reversing the one/two-session case order in the
second pair. Each case used an eight-token prefix, seven decode calls, one warmup
and three measured trials per process: six trials per variant and session count.

| Sessions | Retained workspace before | After | Saved |
| ---: | ---: | ---: | ---: |
| 1 | 2,228,736 B | 1,638,912 B | 589,824 B (26.46%) |
| 2 | 4,456,960 B | 3,277,312 B | 1,179,648 B (26.47%) |

All 24 measured batch trials preserved the complete logit/KV hashes and generated
IDs. The saved capacities match `4 * rows * (Dim + Hidden)` exactly. The workspace
retains the larger prefill shape during decode. These figures exclude model
weights, KV, metadata and allocator overhead; peak process RSS remained around
3.9 GiB and did not establish a reduction.

| Sessions | Median prefill before / after | Median seven-call decode before / after |
| ---: | ---: | ---: |
| 1 | 2.911 / 2.888 s | 3.243 / 3.235 s |
| 2 | 5.840 / 6.004 s | 4.440 / 4.385 s |

The descriptive time ratios range from 0.988 to 1.028; none crossed the planned
5% aggregate regression investigation threshold. Process/order drift is visible:
the two baseline single-session prefill medians were 2.607 and 3.192 s. The first
before/after pair also had slower candidate medians in every case. All samples
are retained; these data support the workspace reduction and numerical parity,
not a throughput improvement or statistical non-regression guarantee.

[Protocol](../validation/performance/inference-liveness-protocol-20261110.json),
[complete receipt](../validation/performance/inference-liveness-mistral-20261110.json),
and [summary](../validation/performance/inference-liveness-summary-20261110.json)
include source/binary/model identities, every trial and per-process RSS.
The measured runtime is commit `1e8fe4c`; subsequent receipt/documentation changes
do not alter it. Independent review found one obsolete prompt-planner estimate;
the correction and an actual-retained-array boundary test were reviewed again
with no remaining actionable finding.

Reproduce from this revision with an existing pinned model directory:

```sh
python3 -S scripts/compare_inference.py \
  --model /path/to/Mistral-7B-Instruct-v0.3 --id mistral-7b-v03 \
  --baseline-ref 3c0ab74dcdb4d707abf6e397cc3b6b56672db19f \
  --weight-format q4-mixed --case-order balanced \
  --output-dir runs/inference-liveness-new
```

Use a fresh output directory; failed or negative attempts are not overwritten.
The driver disables downloads and ambient Go compiler flags, checks pinned model
files before and after execution, and runs only one resident model at a time.

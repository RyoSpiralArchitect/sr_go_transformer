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
scratch is reused through all layers; model weights and KV still scale with
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

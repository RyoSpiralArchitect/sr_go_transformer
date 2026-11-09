# BF16 KV experiment: not adopted

The opt-in BF16 candidate halves numeric KV payload and preserves default
FP32 output exactly, but does not satisfy the complete quality gate.

The pinned Mistral-7B Q4-mixed screen completed all six English documents
(235 next-token targets) and four fixed 128-token continuations. Mean
KL(FP32 || BF16) was 0.0000213049, p95 KL was 0.00000993781, and mean target
loss changed by -0.000976740 nats/token. These pass the frozen numerical
limits; the tiny loss change is not a general quality-improvement claim.

Actual page payload halved from 144 to 72 MiB for the English input and from
160 to 80 MiB for the Japanese input. Weights and total process RSS do not
halve. The capacity-only 4,096-position preflight reports 512 MiB of BF16 KV
versus 1 GiB of FP32 KV; it is not a 4,096-token quality validation.

English output IDs/text match. Japanese IDs/text differ: BF16 replaces the
source's screws of various sizes with “three kinds of wood”. Independent
label-blinded model-assisted review identified this as a new factual error,
separate from both answers' truncation and weak Japanese. The content gate
therefore fails. All outputs, numerical rows, metadata and reviews are kept
under `validation/performance/bf16-kv-*20261110*`.

The reproduction patch is based on `ce2661a2ef642edb1a237b92dd85da19f528f3d2`
and restores the original candidate source and harness. Apply it only in a
fresh isolated checkout. The original protocol is retained unchanged as
`validation/performance/kv16-protocol-20261110.json`.

FP16 will be evaluated as a distinct 16-bit candidate with the same input set
and thresholds. The failed BF16 sample is not replaced or reclassified.

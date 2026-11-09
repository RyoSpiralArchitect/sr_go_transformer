# KV cache formats

Inference keeps FP32 KV pages by default. The experimental `-kv-format f16`
option stores keys and values as FP16, separately from `-weight-format`.
Attention widens values as it reads them and accumulates in FP32; it does not
keep a second FP32 cache or allocate a conversion buffer per token.

```sh
./monolith infer local -path /path/to/mistral7b-instruct-v0.3 \
  -weight-format q4-mixed -weight-mib 8192 -context 4096 \
  generate -kv-format f16 -kv-mib 512 -prompt "Explain Go channels."
```

`generate`, `infer-hf`, `chat`, `serve`, and `check-hf` accept `-kv-format`.
For `infer local`, place it after the action, alongside `-kv-mib`. Training
and HF remote inference do not use this cache option.

Each numeric KV page takes half the FP32 payload bytes. The same format applies
to private pages, recycled pages, and immutable prefix snapshots. Admission,
prefix allowances, and engine KV metrics charge the selected payload width.
Model weights, tokenizer, workspace, Go runtime overhead, and total RSS do not
halve. `check-hf -json` reports the selected format in `kv_plan`; the embedded
HF weight plan retains its original FP32 KV sizing reference.

FP16 rounds stored K/V to nearest with ties to even. It can change logits and
generated text. FP32 is the default and the comparison reference. Neither the
format nor loaded model settings may be mutated after caches/engines are
created.

The frozen validation protocol is
`validation/performance/fp16-kv-protocol-20261110.json`. It measures held-out
teacher-forced KL and next-token loss, retains two bounded long continuations
per format, and tests page boundaries, prefix copy/share, cancellation, and
pool reuse. A passing small screen is not a general language-quality guarantee.
The first FP16 screen passed on pinned Mistral-7B-Instruct-v0.3 Q4-mixed:
235 next-token targets across six documents gave mean KL 0.000000939708,
p95 KL 0.000000190146, and mean target loss change -0.000211241 nats/token.
This small loss change does not establish improved quality. Both English and
Japanese 128-token output sequences and texts exactly matched FP32. Independent
label-blinded model-assisted review found no new content errors, while retaining
existing off-task English, weak Japanese and bounded truncation.

Actual numeric KV payload was 144 to 72 MiB (English) and 160 to 80 MiB
(Japanese). A separate capacity-only 4,096-position check fits 512 MiB in FP16;
this is not a 4,096-token quality test. The default FP32 logits, KV and token IDs
also exactly matched the predecessor on the fixed one/two-session replay.

Full first results, source/model hashes, reviews and adoption decision are in
`validation/performance/fp16-kv-*20261110*`. There is no latency-improvement or
total-RSS-halving claim. Other models and longer contexts need their own quality
checks; FP32 remains the comparison reference and default.

FP16 values that would overflow to infinity, including non-finite K/V, cause an explicit inference error recommending FP32. The cache position is not committed. There is no silent memory-budget expansion.

The earlier BF16 candidate failed its Japanese content screen and is not offered by the runtime; see [retained experiment](bf16-kv-experiment.md).

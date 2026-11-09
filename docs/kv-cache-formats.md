# KV cache formats

Inference keeps FP32 KV pages by default. The experimental `-kv-format bf16`
option stores keys and values as BF16, separately from `-weight-format`.
Attention widens values as it reads them and accumulates in FP32; it does not
keep a second FP32 cache or allocate a conversion buffer per token.

```sh
./monolith infer local -path /path/to/mistral7b-instruct-v0.3 \
  -weight-format q4-mixed -weight-mib 8192 -context 4096 \
  generate -kv-format bf16 -kv-mib 512 -prompt "Explain Go channels."
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

BF16 rounds stored K/V to nearest with ties to even. It can change logits and
generated text. FP32 is the default and the comparison reference. Neither the
format nor loaded model settings may be mutated after caches/engines are
created.

The frozen validation protocol is
`validation/performance/kv16-protocol-20261110.json`. It measures held-out
teacher-forced KL and next-token loss, retains two bounded long continuations
per format, and tests page boundaries, prefix copy/share, cancellation, and
pool reuse. A passing small screen is not a general language-quality guarantee.
The candidate remains under evaluation until its receipt and review are added.

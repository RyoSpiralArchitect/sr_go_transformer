# OLMo 2 1B base on the Furnace CPU

The tested snapshot is `allenai/OLMo-2-0425-1B` at
`a1847dff35000b4271fa70afc5db10fd29fedbdf`. Its 179 F32 tensors have
1,484,916,736 parameters, including the untied output head and learned norms.
All model assets are pinned in the [model catalog](../model-profiles.json).
The [upstream architecture](https://github.com/huggingface/transformers/blob/v4.50.3/src/transformers/models/olmo2/modeling_olmo2.py)
defines Q/K normalization across the projected channels and both post-sublayer norms.

An offline CPU reference runs Transformers with eager attention, F32 weights
and F32 KV, four threads on P cores 4–7 of the Core Ultra 9 285K. The Go CLI
runs on the same cores. The initial five tokenizer cases cover digits, Unicode, white space
and literal added tokens. Each of two text prompts generates eight greedy tokens.
Each prefill chunk size (1 and 16) is compared against all 100,352 logits at
every step, with a predeclared maximum absolute tolerance of 0.002.
The Q4-mixed CLI also generates eight tokens from each prompt.

| First run | FP32 | Q4-mixed |
| --- | ---: | ---: |
| Peak Go process RSS across the two completions | 5.59 GiB | 1.00 GiB |
| Time to load and return eight tokens, two invocations | 7.38 / 7.38 s | 18.31 / 18.23 s |
| Exact completions against Transformers FP32 | 2/2 | 0/2 |

The FP32 maximum absolute logit error was 0.000326 or less. Q4-mixed quantizes
the source weights during loading. The wall times above include that conversion.
[First-run records](first.jsonl) contain the generated text, IDs, memory and timing.
The short completions measure numerical agreement on these two prompts.

## Reviewed runtime

The initial CLI was built from a working tree. A [clean integration replay](post-fma.jsonl)
used `651ba43`. After review, the [final replay](reviewed.jsonl) used `e7829bb`
and checked the stopping condition, returned ID count and HF decoding of every
completion in both formats. It also matched all 1,536 tokenizer IDs and decoded
text for 4,608 consecutive digits. The [CLI build metadata](cli-builds.json)
binds each receipt to its executable. The public
[`infer local -path` check and generate actions](local-entry.json) passed offline.

Both FP32 prompts again matched every greedy ID with maximum absolute logit
errors of 0.00032521 and 0.00027848 respectively. Peak RSS reached 5.59 GiB
for FP32 and 1.00 GiB for Q4-mixed. Both quantized continuations reached the
eight-token limit and decoded correctly; each diverged from FP32.

The resident test enabled and disabled the AVX2 flag in the **same binary**.
It used four P cores, a 128-token prefix, Q4-mixed weights and F16 KV.
Times cover seven decode forwards per replay, with eight counterbalanced rounds.
Both processes load and quantize the checkpoint before timing starts.

| Sessions | Portable aggregate tok/s | AVX2 aggregate tok/s | Median paired time ratio |
| --- | ---: | ---: | ---: |
| One | 10.10 | 10.13 | 0.996 |
| Two | 14.51 | 25.09 | 0.574 |

All two-session rounds favored AVX2; both cases passed the same-binary stability
checks. Logits, KV and greedy IDs were bit-identical in every replay.
[Pre-review samples](resident-first.jsonl) and [reviewed samples](resident-reviewed.jsonl)
identify the runtime and binary hashes. Reuse the
[Linux resident runner](../../performance/q4-ffn-avx2-20261122/) with
`--model-id olmo2-1b` and build both arms at `e7829bb`.

To replay, build the ordinary Linux Go CLI, then use a CPU Python environment
with the versions in the record (`torch`, `transformers` and `tokenizers`).
The runner verifies the supplied snapshot offline.

```sh
HF_HUB_OFFLINE=1 CUDA_VISIBLE_DEVICES= taskset -c 4-7 python verify.py \
  "$OLMO_SNAPSHOT" /path/to/monolith ../model-profiles.json new-result.jsonl
```

For the small CI oracle, run
`python scripts/hf_profile_fixtures.py --family olmo2` with the repository's
pinned Transformers reference environment. The seeded fixture has grouped KV heads
and independently varied norm weights. CI checks every layer's cached K/V as well
as logits for several chunk sizes and worker counts.

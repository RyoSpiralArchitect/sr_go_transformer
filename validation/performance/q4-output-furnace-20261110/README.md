# Four-output Q4 on Furnace CPU

The reference is the paired kernel at `2f351c1`. The runtime candidate is
the unrolled direct-table four-output path measured at `0897543`. The
Linux/amd64 binaries were cross-built with Go 1.27.1, GOAMD64=v1 and CGO
disabled. Build and input hashes are in `build-ecore.json`.

The first P-core benchmark used cores 4–7. A running background process
later occupied CPU 4 during real-model work. The operator interrupted
only the owned benchmark runner. The next P-core attempt also observed
that process moving onto the proposed affinity. The first microprobe
results are diagnostic and the incomplete real timing remains
unscored. Raw attempts are retained on Furnace and as a local run archive.
Qwen2.5-1.5B Base passed file pinning, then the unmodified loader rejected
the `use_mrope` field before inference. Its failure receipt is retained.

The complete model comparisons use one cluster of four E-cores, 16–19,
on the Core Ultra 9 285K. The runner records samples of the previously
observed background process. Each model uses two paired process runs
with reversed order and one resident model per process. Timed core
forward intervals cover an 8-token prefix and seven decode calls for
one or two sessions. The unit of aggregation is the median of six
measured trials per variant and session count. Timing covers only the
fixed short-context workload. Model hashes were checked before and after
each comparison. See `protocol-ecore.json` and the per-model receipts.

## Register use experiment

The new two-phase four-output source computes lanes a and b, reduces
each output's pair, then computes lanes c and d. Both phases preserve
the original increasing input order within each lane and combine the
results as (a+b)+(c+d). The packed weights, table, scaling, worker tiles
and short paired tail are shared with the direct version.

The Go amd64 direct quad dot function has 128 instruction lines that
reference SP. The two-phase dot function has zero. On the E-core
matrix, the split version reaches the 5% target against the original
paired runtime in two of four four-worker shapes. The synthetic gate
requires three. The split experiment stays outside the inference
candidate. The Mac diagnostic also recorded a four-worker cell about
6.5% slower than the direct quad. See `codegen.json`, `e-core-micro.txt`,
`m4-split-micro.txt` and `split-protocol.json`.

To reproduce the synthetic split probe, first generate the previous
direct-table comparison using the adjacent direct LUT experiment's
instructions at the base runtime. Run `generate_split.py` with that
generated source and a fresh output path. Format the output and compile
the test package with the base runtime. Run `TestQ4SplitExact` and
`BenchmarkQ4Split`, using a single benchmark process, four workers and
200 ms per sample. The small-shape diagnostic uses the dimensions in
`gpt2-shapes-protocol.json` with the same harness.

## E-core model results

| Model | Single decode before → after | Single decode ratio | Single prefill ratio | Two decode ratio | Two prefill ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| GPT-2 124M | 0.0791 → 0.0819 s | 1.0346 | 0.9936 | 1.0003 | 0.9803 |
| Llama 3.2 3B | 1.6613 → 1.6579 s | 0.9979 | 0.9976 | 1.0038 | 1.0012 |
| Mistral 7B Instruct v0.3 | 3.4022 → 3.3863 s | 0.9953 | 0.9987 | 1.0021 | 1.0005 |

All 72 trials match logits, KV and token IDs. The sampled background
process had zero observed overlap under the frozen threshold. Each
model meets all control timing limits. None reaches the 5% target
for single-session decode on these E-cores. The earlier P-core
synthetic measurements remain separate.

The additional GPT-2-sized synthetic screen found no variant that
passed the three-of-four-shape criterion. Its four variants and all
128 samples are retained in `gpt2-shapes-micro.txt`. The split kernel
is kept as a reproducible experiment.

Furnace retains the complete raw results under
`~/scratch/sr-go-q4-direct-20261110/results`. The local ignored copy
is `runs/furnace-q4-direct-20261110/received/furnace-results.tgz`.
Recalculate the compact ratios with `summarize.py` against this
directory. The final conclusion and archive hash in `decision.json`
are operator annotations.

The disabled-mRoPE compatibility fix later loaded the same Qwen2.5-1.5B
Base revision with the original config and weights. Literal
`"use_mrope": false` keeps the standard text RoPE path. The regular CLI
generated eight tokens, and the core probe completed the one- and
two-session cases with exact repeat parity. See
`qwen25-base-disabled-mrope-verification.json`.

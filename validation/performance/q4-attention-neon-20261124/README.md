# Q4 attention projections on Apple M4

`MONOLITH_Q4_FFN_NEON=all+attention` enables the one- and two-row NEON
projection kernels for Q, K, V and O on Darwin arm64. `all` selects the
existing FFN-only mode. For GPT-2 the loader marks the individual Q, K and V
matrices after allocating their transposed destinations. Embeddings, biases,
normalization, KV storage and the vocabulary head use their usual kernels.

## Projection measurements

These timings are for one matrix with synthetic packed weights in the
dimensions of Llama 3.2 3B. Q and O each have 3,072 inputs and 3,072 outputs.
K and V each have 3,072 inputs and 1,024 outputs. Each row reports the median
of six paired NEON/Go **time** ratios, with eight projections per sample.
The starting mode alternates across pairs.

| Matrix | Input rows | 1 worker | 4 workers |
| --- | ---: | ---: | ---: |
| Q or O | 1 | 0.5162 | 0.4381 |
| Q or O | 2 | 0.7991 | 0.6871 |
| K or V | 1 | 0.5358 | 0.5875 |
| K or V | 2 | 0.8223 | 0.7266 |

All eight shapes favored NEON in all six pairs and reported zero allocations
per timed projection. [Raw projection and decode samples](events.jsonl)

## Resident decode

Two processes run the same binary with the two production startup settings.
Both use Q4-mixed weights, FP16 KV and four workers. Each process reports
the matrix selections from the loaded checkpoint before timing. Both select
84 FFN matrices. The attention setting also selects all 112 Q/K/V/O matrices
across the 28 layers. Each replay restores a 128-token prefix and times seven
forward calls. The logit and KV digests, greedy token IDs, cache positions,
KV payload and workspace size are checked against the preceding release. [Protocol](protocol.json)

Each of two waves loads fresh processes. The second reverses both process
startup order and session-count order. Within each four-round wave, the two
labels per mode each occupy every position in the sequence once. The primary
ratio in each round is the sum of both attention-mode samples divided by the
sum of both control samples. The decision also checks each wave separately,
same-mode repeatability, host free memory and swapouts.

| Sessions | FFN only, ms/step | FFN + attention, ms/step | Median paired time ratio | Faster rounds | Exact replays |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 137.44 | 121.11 | 0.8539 | 8/8 | 32/32 |
| 2 | 162.83 | 151.71 | 0.9250 | 8/8 | 32/32 |

The two time columns are medians for each mode. The paired ratio is computed
within each round before taking the median. One two-session step advances
both sessions. All 64 replays matched the previous release. The minimum
sampled free-memory percentage was 49%, with zero new system swapout pages.

The two-session case passed both speed and repeatability criteria. In the
one-session case the FFN-only repeat had a median ratio of 1.044 and a median
absolute deviation from 1 of 8.2%, outside the predeclared 3% and 5% limits.
Both wave medians favored attention at both session counts. The combined
promotion criterion failed and the extension remains an explicit startup
option. [Replayed assessment](assessment.json)

## Reproduction

Use Go 1.27.1 on an Apple M4, with the pinned local Llama 3.2 3B snapshot
and a new output directory. The driver builds from the runtime at
`5391b9a`. The measurement tooling is at `2f5d856`. The protocol records
the compiled probe's SHA-256. The binary uses ordinary production startup
and the resident fixture adds a matrix count to its initial reply.

```sh
d=validation/performance/q4-attention-neon-20261124
python3 -B -S "$d/summarize.py"
python3 -B -S -m unittest discover -s "$d"
python3 -B -S "$d/probe.py" "$LLAMA_3B_SNAPSHOT" "$NEW_OUTPUT"
python3 -B -S "$d/summarize.py" "$NEW_OUTPUT/events.jsonl"
python3 -B -S "$d/verify_cli.py" "$QWEN_05B_SNAPSHOT" "$GPT2_SNAPSHOT" "$NEW_CLI_OUTPUT"
```

To reproduce the original collection after the repository's shared tools have
changed, run `probe.py` from a worktree at `2f5d856` and pass the resulting
events file to the assessor above. The CLI comparison builds the previous
and current ordinary binaries and checks six greedy tokens from the prompt
`Hi` on the two pinned models. [CLI outputs](cli.json)

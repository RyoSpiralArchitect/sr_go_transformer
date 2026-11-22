# Linux amd64 two-row Q4 FFN

These offline measurements compare the ordinary portable Linux binary at
`c665cb3` with the AVX2 opt-in on an Intel Core Ultra 9 285K. Both processes
stay resident on P cores 4–7 with four workers. Llama 3.2 3B uses Q4-mixed
weights, F16 KV, a 128-token prefix and seven timed decode forwards per replay.
Archive loading, tokenization, checkpoint restoration and result hashing are
outside the forward timers. Throughput counts tokens across all active sessions.

Eight rounds interleave the two binaries and same-binary controls. The
prespecified timing limits are a two-session median elapsed ratio at most
0.95 with at least seven wins, a one-session ratio at most 1.05, and control
medians within 3% with median absolute control deviations at most 5%.
Every replay checks full logits, KV, greedy IDs, workspace and positions.
The [first comparison](llama-first.jsonl) measured the sources and runner at
`7c64c85`. The [final comparison](llama-final.jsonl) used runtime revision
`fec0afd`, baseline `c665cb3` and the runner at `11eb230`. The receipt
includes the toolchain, selected source hashes, both binary hashes and the model hashes.

| Run and sessions | Portable aggregate tok/s | AVX2 aggregate tok/s | Median paired time ratio |
| --- | ---: | ---: | ---: |
| First, one | 3.877 | 3.875 | 1.005 |
| First, two | 6.080 | 10.417 | 0.582 |
| Final, one | 3.865 | 3.869 | 1.000 |
| Final, two | 6.016 | 10.543 | 0.572 |

Both two-session runs won all eight rounds. All four cases passed the
same-binary stability bounds. Per-process peak RSS stayed within 2 MiB
between the two arms in each case. Each reported ratio is the median of
paired elapsed times; the throughput columns are separate medians.

The first GOAMD64=v3 numerical screen found a one-ULP discrepancy at output
zero (`bf730bba` vs `bf730bbb`). The newer Go compiler can fuse a scalar
multiply-add at this target. The revised kernel matches the compiler's rounding
at both the inner dot and scale accumulation. Go 1.22.12 and 1.27.1 v3
projection checks passed on Furnace after the change. The [compatibility replay](compatibility.json) includes the original failure and both compiler results.

## Reproduce on Furnace

Run the builder from a clean checkout with Go 1.27.1 and the module cache
available. Copy the two executables and their build manifest to the Linux host.
The runner requires Python 3.11+, the pinned local snapshot, the repository
corpus and the model catalog.

```sh
python3 validation/performance/q4-ffn-avx2-20261122/build.py fec0afd /tmp/q4-avx2-build
taskset -c 4-7 python3 validation/performance/q4-ffn-avx2-20261122/run.py \
  /tmp/q4-avx2-build/scalar.test /tmp/q4-avx2-build/native.test "$LLAMA_SNAPSHOT" \
  validation/quality/corpus.json validation/hf/model-profiles.json \
  /tmp/q4-avx2-build/builds.json llama-replay.jsonl
```

An optional `--baseline` on the builder and `--model-id` on the runner allow
both arms to use the same revision for a newly supported model. Each child
sets the AVX2 switch explicitly. The runner verifies executable and model
hashes before timing and creates a fresh receipt on each invocation.

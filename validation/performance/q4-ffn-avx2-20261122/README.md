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
The first comparison is preserved in [llama-first.jsonl](llama-first.jsonl).

The first GOAMD64=v3 numerical screen found a one-ULP discrepancy at output
zero (`bf730bba` vs `bf730bbb`). The newer Go compiler can fuse a scalar
multiply-add at this target. The revised kernel matches the compiler's rounding
at both the inner dot and scale accumulation. Go 1.22.12 and 1.27.1 v3
projection checks passed on Furnace after the change.

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

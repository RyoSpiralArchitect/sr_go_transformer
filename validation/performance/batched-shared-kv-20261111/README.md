# Batched shared-KV attention

`protocol.json` records the inputs and acceptance criteria for the M4
comparison. The measured sources are at commit
`8c15bad553ab5ca01aa19d8190f736d0238e72e7`. The review follow-up
expanded integration-test coverage after the measurements.
The model probe requires the local Llama 3.2 3B BF16
snapshot at revision `60a99aaf43164077157d64bf909b7b61143c6a6d`.
It verifies the pinned files before and after the run and loads them
with Q4-mixed weights and FP16 KV. Use a new output directory for each run.

```sh
export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local CGO_ENABLED=0 GOMAXPROCS=4
export GOEXPERIMENT='' GOPROXY=off GOSUMDB=off
unset GOGC GOMEMLIMIT GODEBUG

python3 -S scripts/measure_context_sweep.py \
  --model "$MODEL_SNAPSHOT" --compare-shared-kv --formats f16 \
  --sessions 2 --max-prefix 1024 --output-dir runs/batched-f16-1024

mkdir -p runs/batched-kernel
go test -c -trimpath -o runs/batched-kernel/attention.test ./cmd/monolith
runs/batched-kernel/attention.test -test.run '^$' \
  -test.bench '^BenchmarkSharedKVTwoRows$/^group(3|4)$/^(f32|f16)$/^prefix(1024|4096)$' \
  -test.benchtime=80x -test.count=3
```

The model stage probe enables or bypasses the shared planner within
one executable. At 128 tokens both paths use the same per-head kernel.
It replays each prefix from the same caches and reports per-call timing
from each seven-call replay. The isolated kernel benchmark uses two
independent caches and checks output bits before timing. The second
row sees one fewer position than the first. Both kernel variants are
selected directly, so the benchmark also covers the 1,023-position
row that would put the model's 1,024-token case below its dispatch gate.

The single-row control runs each revision's own build of the same
fixtures. From the candidate checkout, set `output` to an absolute path
and use the candidate binary from the command above.

```sh
output="$PWD/runs/batched-kernel"
git worktree add --detach "$output/reference" 505f4f5ad456e79eb28f88c15cbc44ebfe5bb5b4
(
  cd "$output/reference"
  go test -c -trimpath -o "$output/reference.test" ./cmd/monolith
)
for variant in reference candidate candidate reference candidate reference reference candidate; do
  binary="$output/attention.test"
  if [ "$variant" = reference ]; then binary="$output/reference.test"; fi
  printf '# %s\n' "$variant"
  "$binary" -test.run '^$' \
    -test.bench '^BenchmarkSharedKV(Attention|FourHeads)$/^f16$/^prefix(1024|4096)$' \
    -test.benchtime=60x -test.count=1
done
```

- [Model receipt](f16-s2-1024.json) includes every timed replay and
  the checkpoint, model-file, compiled source and binary digests.
- [Two-row kernel samples](kernel-two-rows.txt) and
  [single-row control samples](kernel-single-row.txt) retain all
  process output. [Kernel binary digests](kernel-binaries.txt) identify
  the executables used for both comparisons.

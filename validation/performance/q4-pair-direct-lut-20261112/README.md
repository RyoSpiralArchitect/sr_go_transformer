# Two-row Q4 lookup experiment

The #82 two-session Llama 3.2 3B replay at 1,024 tokens measured
245.44 ms in layer projections and 318.44 ms for the complete batched
decode call. Its separate CPU profile sampled 1,070 ms in
`dotQ4PairBlock64` across seven decode calls. That profile reports CPU
samples. The stage probe measures elapsed time across worker joins.

This experiment takes addresses of the existing lookup table entries in
the two-row dot product. The Go 1.27.1 arm64 binary eliminated 16
stack store/reload pairs from that function's ordinary return path.
The targeted Q4 and quantization tests passed. All 24 model trials
matched prompt IDs, generated IDs, logit and KV digests, and workspace
capacity across the two builds.

| Synthetic Q4 projection | Input rows | Baseline ms | Candidate ms | Ratio |
| --- | ---: | ---: | ---: | ---: |
| Gate/Up | 1 | 0.907 | 0.983 | 1.084 |
| Gate/Up | 2 | 1.789 | 1.664 | 0.930 |
| Gate/Up | 4 | 4.433 | 4.725 | 1.066 |
| Down | 2 | 1.789 | 1.805 | 1.009 |
| Query/attention output | 2 | 0.683 | 0.665 | 0.973 |
| Key/Value | 2 | 0.241 | 0.227 | 0.944 |

| Llama 3.2 3B Q4-mixed, FP32 KV | Pooled median ratio | Adjacent process-pair ratios |
| --- | ---: | ---: |
| One-session decode | 1.005 | 1.183, 0.957 |
| One-session prefill | 1.080 | 1.777, 1.011 |
| Two-session decode | 0.896 | 0.982, 0.965 |
| Two-session prefill | 1.146 | 1.114, 1.314 |

The model probe used eight prompt tokens per session and seven decode
calls. It measures a short prefix with the same two-row projection
kernel as the long-context run. Ratios pool six trials per build, or
compare the two adjacent pairs of three-trial process medians. Other
CPU work was visible during the run, and the one-row and four-row
synthetic controls used the same kernel in both builds. The pooled
two-session improvement was larger than either paired result. Down
and the model prefill controls missed the frozen criteria, so the
candidate is archived as a patch.

## Reproduce

Use Go 1.27.1 on Apple Silicon and set `MODEL_SNAPSHOT` to the local
snapshot recorded in [protocol.json](protocol.json). From the checkout
containing this record, run the following in a new shell.

```sh
record="$PWD/validation/performance/q4-pair-direct-lut-20261112"
base=0e034974880d4c8d28aef7344eab8d9ebe9d2a28
scratch="$(mktemp -d)"
git worktree add --detach "$scratch/source" "$base"
cd "$scratch/source"
git apply --unidiff-zero "$record/candidate.patch"

export GOENV=off GOWORK=off GOFLAGS='' GOTOOLCHAIN=local CGO_ENABLED=0 GOMAXPROCS=4
export GOEXPERIMENT='' GOPROXY=off GOSUMDB=off
unset GOGC GOMEMLIMIT GODEBUG

out="$PWD/runs/pair-lut"
for mode in before after; do
  mkdir -p "$out/$mode"
  cp go.mod go.sum "$out/$mode/"
  cp "$record/bench_test.go.txt" "$out/$mode/bench_test.go"
  if [ "$mode" = before ]; then
    git show "$base:cmd/monolith/monolith.go" > "$out/$mode/monolith.go"
  else
    cp cmd/monolith/monolith.go "$out/$mode/"
  fi
  (
    cd "$out/$mode"
    go test -c -trimpath -o probe.test .
    go tool objdump -s '\.dotQ4PairBlock64$' probe.test > objdump.txt
  )
done
for mode in before after after before after before before after; do
  printf '# %s\n' "$mode"
  "$out/$mode/probe.test" -test.run '^$' -test.bench '^BenchmarkQ4PairLUT$' \
    -test.benchtime=120x -test.count=1
done

python3 -S scripts/compare_inference.py --model "$MODEL_SNAPSHOT" --id llama32-3b \
  --baseline-ref "$base" --weight-format q4-mixed --case-order balanced \
  --output-dir "$out/model"
```

Count the `MOVD Rn, offset(RSP)` stores and `FLDPS offset(RSP), ...`
reloads before the first `RET` in each disassembly. Their stack
offsets match in the reference build. [Decision and hashes](decision.json)
· [Kernel samples](kernels.txt) · [Model receipt](model.json)

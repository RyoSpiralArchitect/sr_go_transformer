# Q4 decode hotspots and two-row FFN SIMD on Apple M4

The baseline is the ordinary monolith at 68810f7a59d85944575d4a5fa3100e85d1ca8789.
The live work uses the pinned Llama 3.2 3B BF16 snapshot from the model catalog,
converted to Q4-mixed resident weights. Both experiments use Go 1.27.1 on Apple
M4. The model runs with four workers, FP16 KV, and prefixes of 128 and 512
tokens per session. Each replay measures seven one-token forwards across all
layers and the output head, with one or two sessions in a forward.

## Decode stage attribution

Each case replays the same prompt KV in one process. The baseline and
same-path control call the ordinary method. The third arm calls a staged
copy with nonoverlapping clocks around Q, K, V, Attention, attention output,
Gate, Up, SwiGLU, Down, and the vocabulary projection. The six rounds run all
arm orders. One run holds only one model and starts each replay from the
same prefix with private suffix pages. The one-session case reuses the first
session's prefix. Token choice and numerical digests run outside the spans.

| Prefix | Sessions | Ordinary ms/forward | Gate ms | Up ms | Down ms | FFN projection share | Attention ms | Vocabulary ms | SwiGLU ms |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 128 | 1 | 138.96 | 25.72 | 25.67 | 24.41 | 54.41% | 4.41 | 30.30 | 0.99 |
| 128 | 2 | 173.75 | 32.05 | 32.08 | 32.50 | 55.52% | 8.34 | 32.35 | 1.93 |
| 512 | 1 | 154.70 | 26.56 | 26.51 | 25.24 | 50.51% | 16.72 | 30.38 | 1.00 |
| 512 | 2 | 211.95 | 34.39 | 34.32 | 34.88 | 48.84% | 34.06 | 35.36 | 2.06 |

Stage durations are medians of per-replay means. FFN share is the
median of (Gate + Up + Down) divided by the enclosing forward time
within a replay. FFN projections were the largest group in all 24
timed replays. SwiGLU occupied 0.64–1.11%. Across the four cases,
the median timed/ordinary ratios were 0.9986–1.0023 and
the repeated-ordinary ratios were 0.9981–1.0031. All 72 measured
replays matched their warm reference.

The separate CPU profile replays omit digests and record the
same token IDs. Their samples cover all workers and cannot be
read as per-forward elapsed shares. See the four pprof text
summaries in [profile](profile/). This context range stays below
the shared-KV attention dispatch threshold. The first preflight
failed to compile its generated imports before starting a replay.
The [build log](profile/first-build.log) records that attempt.

## Two-row Q4 kernel

The staged Go kernel loads packed nibbles and sign-extends them in
vector registers. It keeps four independent FP32 accumulation lanes
in the same column order as the scalar loop, then uses the same
two-stage pairwise reduction. The original Q4 scales, odd-output tail,
worker ranges, and stored Up values are used. The test build uses
[Go's experimental archsimd package](https://pkg.go.dev/simd/archsimd).
The measured ARM64 block emits 64 vector FMA instructions where the
scalar block emits 256 scalar FMA instructions.

Exactness checks with the race detector cover all 256 packed bytes,
10,000 seeded finite block cases, signed zeros, subnormals, and range
tails with one and four workers. The two independent timing blocks
used both 3072×8192 and 8192×3072 shapes, both worker counts, and all
six arm orders. SIMD won all 48 round pairs. Its median elapsed ratios
were 0.6129–0.6224, a 37.76–38.71% reduction. The two scalar labels
passed the same-path timing bounds for every case.

## Resident model comparison

The model is loaded once. In every case, eight balanced rounds run two
ordinary arms and two SIMD arms. The SIMD arms call a staged model
method with Gate, Up, and Down using the kernel above when eligible.
The staged method calls the ordinary code for Q/K/V, Attention, SwiGLU,
and the output head. The one-session SIMD arms fall back to the
ordinary projection.
The four arms share the same experimental build, model, warmed workspace,
and executor. The ordinary arms use the original forward method.

| Prefix | Sessions | Ordinary ms/forward | SIMD arm ms/forward | Paired elapsed ratio | SIMD wins |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 128 | 1 | 143.13 | 143.41 | 1.00500 | 2/8 |
| 128 | 2 | 181.09 | 139.14 | 0.76738 | 8/8 |
| 512 | 1 | 159.00 | 159.36 | 1.00008 | 4/8 |
| 512 | 2 | 218.33 | 171.92 | 0.78780 | 8/8 |

Times are medians of seven-step replay means. Ratios are medians
of the within-round ratios. Two-session elapsed time fell 23.26%
and 21.22%, with both arm orders favoring SIMD at both prefixes.
The same-path medians ranged from 0.99606 to 1.00457. Both
one-session fallback cases passed the same-path bounds.

All 128 measured arms matched their ordinary-toolchain profile
references on every logit and KV digest, token ID, positions,
and workspace capacity. Each two-session SIMD replay dispatched
588 projections over seven forwards. The one-session SIMD replays
and all ordinary replays dispatched zero. Memory-free readings
were 80% at entry and 79% at exit. The swapout counter was zero at
both checkpoints. Peak RSS for the shared process was 2.39 GiB.

The resident diagnostic passed its frozen advancement bounds.
This record covers Apple M4, this model, and these decode cases
within one test binary. The candidate stays in the experiment.
The profile and resident test binaries reproduced byte for byte
from their staged inputs. A separate build-to-build comparison
would measure the cost of integrating the dispatch into a normal
inference build.

## Reproduce

Use Apple M4, the pinned Go 1.27.1 in PATH, a populated Go module cache,
and the local model snapshot designated by MODEL_SNAPSHOT. The drivers
verify the source fingerprint and model asset checksums. They generate
test files under new output directories and run offline.

```sh
record=validation/performance/decode-hotspots-20261121
mkdir -p runs
export PYTHONDONTWRITEBYTECODE=1
python3 -S "$record/run.py" --model "$MODEL_SNAPSHOT" --output runs/decode-stage-reproduce
sh "$record/simd.sh" runs/decode-simd-reproduce
python3 -S "$record/simd_live.py" --model "$MODEL_SNAPSHOT" --output runs/decode-simd-live-reproduce
```

The recorded timing decisions can be rebuilt without running the model.

```sh
python3 -S "$record/assess.py" "$record/profile"
python3 -S "$record/simd_assess.py" synthetic "$record/simd"
python3 -S "$record/simd_assess.py" live "$record/live" "$record/profile"
```

To exercise dispatch and borrowed-job cleanup under the race detector,
copy the staged sources from the live run into another directory and add
the two fixtures. This covers eligible, wide, one-row, four-row, unaligned,
Q8, and nil-executor calls at one and four workers.

```sh
build=runs/decode-simd-live-reproduce/build
verify=runs/decode-simd-dispatch-reproduce
mkdir "$verify"
for file in go.mod go.sum monolith.go ffn_test.go kernel_test.go; do
  cp "$build/$file" "$verify/"
done
cp "$record/simd_test.go.txt" "$verify/simd_test.go"
cp "$record/ffn_dispatch_test.go.txt" "$verify/ffn_dispatch_test.go"
(cd "$verify" && GOENV=off GOWORK=off GOTOOLCHAIN=local GOPROXY=off GOSUMDB=off \
  GOMAXPROCS=4 GOEXPERIMENT=simd CGO_ENABLED=1 go test -race -count=1 -run '^TestSIMDFFNDispatchExact$' .)
```

[Profile decision](profile/assessment.json) · [Kernel decision](simd/assessment.json) ·
[Resident decision](live/assessment.json) · [Recorded inputs](identities.json)

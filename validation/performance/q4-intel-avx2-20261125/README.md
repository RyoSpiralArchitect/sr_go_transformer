# Q4 AVX2 on Intel Core Ultra 9 285K

The ordinary Linux amd64 executable accepts three settings for
`MONOLITH_Q4_FFN_AVX2`. The control (`1`, arm A) accelerates two-input-row
Gate, Up and Down in gated models. Arm F (`all`) adds a single-input kernel for those weights.
Arm B (`all+attention`) also enables both row counts for Q, K, V and O.
GPT-2 selects its attention weights in B and uses its Go MLP in all modes.
The experiments use Q4-mixed weights and FP16 KV. The vocabulary head uses
Q8 in all three arms. [Runtime source](../../../cmd/monolith/q4_ffn_linux_amd64.s)

## Results

| Model | Sessions | `1`, tok/s | `all`, tok/s | `all+attention`, tok/s | F/A time | B/F time | B/A time |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| OLMo 2 1B | 1 | 9.81 | 16.59 | 21.01 | 0.601 | 0.797 | 0.478 |
| OLMo 2 1B | 2 | 24.54 | 24.88 | 32.97 | 0.994 | 0.755 | 0.747 |
| Llama 3.2 3B | 1 | 3.75 | 6.90 | 9.64 | 0.543 | 0.720 | 0.392 |
| Llama 3.2 3B | 2 | 9.97 | 9.74 | 14.36 | 1.032 | 0.676 | 0.701 |

The single-row FFN was faster in all eight rounds on each model. Adding
attention won seven of eight single-session Llama rounds and all eight rounds
in the other three cases. Two-session FFN alone used the same kernel in A and
F. Its paired time ratio was 0.994 on OLMo and 1.032 on Llama, inside the
prespecified 5% control range. Repeatability, speed and memory limits all
passed. Both models reproduced their
previous Linux signatures in all 64 timed replays each. Both runs recorded
zero new system swapout pages. Across arms and waves, per-process peak RSS
was 1.11–1.13 GiB for OLMo and 2.11–2.12 GiB for Llama.
[OLMo assessment](olmo2-1b.json) · [Llama assessment](llama32-3b.json) ·
[OLMo samples](olmo2-1b.jsonl) · [Llama samples](llama32-3b.jsonl)

## Measurement

The throughput measurements use the ordinary GOAMD64=v1 build. All workers
ran on P cores 4–7. Each model used two waves of fresh processes
running the same executable. The second wave reversed launch order and the
order of the one- and two-session cases. Each replay restored a 128-token
prefix and timed seven decode forwards. A two-session forward advances each
session by one token. Model loading, prefix preparation, checkpoint restore
and verification are outside the forward timer. [Frozen protocol](protocol.json)

Each round runs A, F, a repeat of F, and B. Each label occupies every position
once in each wave. The reported throughputs are separate medians of aggregate
tokens per second. The timing comparisons use the elapsed-time ratio within
each of eight rounds. The two F times are averaged before computing a ratio.
For a speed improvement the prespecified limits are a median ratio of at
most 0.98, at least seven faster rounds, and improvement in both waves.
The two-session F/A comparison checks the same two-row FFN path on both sides
and allows a 5% deviation. The same-process F repeat also has a 3% median
ratio limit and a 5% median absolute deviation from one.

## Numerical checks

The assessor checks the selected matrices and both native hook registrations
in each loaded model. OLMo selects 48 FFN matrices in each mode and adds 64
attention matrices in B. Llama selects 84 FFN matrices and adds 112 in B.
The assessor compares every replay's full logit and KV digests,
greedy IDs, cache positions, KV payload and workspace against the preceding
Linux releases. The build manifest identifies the compiled fixture and runtime
sources. [Build manifest](build.json)

The first Go 1.27.1 v3 projection test found a one-ULP difference. The paired
Go kernel on Linux rounds a block's scaled sum before adding it to the output.
The AVX2 single-input kernel now matches that operation, including when the
inner dot uses fused multiply-add. The failing numerical test explicitly
called the candidate on a marked weight. Furnace exercised Go 1.22.12 and
1.27.1 at GOAMD64=v1 and v3 with the switch disabled and with each of its
three supported settings. A separate pure-Go build ran with the expanded
setting. The complete Q4 suite also passed in expanded attention mode for
all four compiler and architecture-level combinations. The separate Go 1.27.1
v3 legacy check reproduced the same seven failing archival comparisons as the
preceding release. [Compatibility results](compatibility.json)

Review identified a separate batch-dependent result in the preceding Go
1.27.1 v3 release. For two Q4 blocks with scales 1 and 1−2⁻²³, a duplicated
input gives +0 in a single-row call and −2⁻⁴⁶ when two rows are processed
together. The expanded modes preserve the released single-row result across
batch sizes. They retain the inner dot's fused arithmetic and round each full
output pair's block product before accumulation. The legacy setting keeps its
original behavior. The regression covers seven row counts, irregular widths,
odd output tails, marked and unmarked weights, and one and four workers.
[Reproducer](batch-witness_test.go.txt) · [Compatibility results](compatibility.json)

The ordinary v3 CLI comparison uses the same eight prompt IDs with prefill
chunks of one and two, then captures the full FP32 vocabulary at four greedy
steps. It checks the preceding single-row convention, the preceding legacy
two-row mode, both expanded modes, and the effect of prefill chunk size.
Each step covers 100,352 entries on OLMo and 128,256 on Llama. All six cases
selected the same four IDs for each model. Both expanded settings at chunk two
matched every logit of the preceding release at chunk one. The legacy setting
at chunk two matched the preceding release at chunk two. Compared with that
legacy two-row result, the expanded settings changed 401,225 of 401,408 OLMo
logits (maximum absolute change 0.005420) and 512,933 of 513,024 Llama logits
(maximum 0.001348).
[OLMo v3 outputs](v3-olmo2-1b.jsonl) · [Llama v3 outputs](v3-llama32-3b.jsonl)

## CPU profiles

After all timings for each model, the runner profiles four additional replays
per session count under A and B. These CPU samples include checkpoint restore
and output validation. Percentages refer to sampled CPU time. The original
profile digests are in the timing records. The portable profiles replace the
host-specific executable pathname, and the exporter checks that the complete
decoded stacks and samples match. [Profiles](profiles/)

The Q8 vocabulary projection accounted for these percentages of flat CPU
samples in `linearQ8Into` and `dotQ8PairBlock64`. Its share rose as the Q4
projections became faster.

| Model | Sessions | Two-row FFN only | Expanded AVX2 |
| --- | ---: | ---: | ---: |
| OLMo 2 1B | 1 | 17.0% | 39.8% |
| OLMo 2 1B | 2 | 27.1% | 36.2% |
| Llama 3.2 3B | 1 | 13.8% | 34.4% |
| Llama 3.2 3B | 2 | 21.9% | 30.4% |

## Reproduction

Build on Darwin arm64 with Go 1.27.1 and the module cache available. Use the
measurement tooling from commit `511801b` for the reviewed build and run.
The builder stages runtime `caf7df9` and emits `resident.test` and `build.json`.
The [first run before review](https://github.com/RyoSpiralArchitect/sr_go_transformer/tree/02976266d7fed3a87554902e38d2ed5c7cdf4f13/validation/performance/q4-intel-avx2-20261125) used the same schedule and thresholds.
Place these next to a checkout on the Intel host and supply the local
snapshots named in the model catalog. The runner verifies and exposes only
the catalogued files to each process. Each output directory must be new.

```sh
d=validation/performance/q4-intel-avx2-20261125
python3 -B -S "$d/prepare.py" "$BUILD" --go "$GO"

taskset -c 4-7 python3 -B -S "$d/measure.py" olmo2-1b "$OLMO_SNAPSHOT" \
  "$BUILD/resident.test" "$BUILD/build.json" "$OLMO_RUN"
taskset -c 4-7 python3 -B -S "$d/measure.py" llama32-3b "$LLAMA_SNAPSHOT" \
  "$BUILD/resident.test" "$BUILD/build.json" "$LLAMA_RUN"
```

With the merged checkout, replay the resident records and inspect the CPU
profiles with the ordinary Go profiler.

```sh
python3 -B -S "$d/assess.py" olmo2-1b "$d/olmo2-1b.jsonl"
python3 -B -S "$d/assess.py" llama32-3b "$d/llama32-3b.jsonl"
python3 -B -S -m unittest discover -s "$d"
go tool pprof -top "$d/profiles/olmo2-1b-B-1.pb.gz"
```

The separate v3 check builds the preceding and current ordinary CLI binaries
and uses the first eight prompt IDs from the model's archived Linux run. Copy
the two executables and manifest to the Intel host. Run the following check
for each model and its corresponding snapshot.

```sh
python3 -B -S "$d/v3_cli.py" build "$V3_BUILD" --go "$GO"
taskset -c 4-7 python3 -B -S "$d/v3_cli.py" check "$MODEL_ID" "$SNAPSHOT" \
  "$V3_BUILD/previous/monolith-v3" "$V3_BUILD/current/monolith-v3" \
  "$V3_BUILD/v3-build.json" "$NEW_V3_RECEIPT"
```

To reproduce the batch-rounding witness, copy `batch-witness_test.go.txt` into
`cmd/monolith` as `batch_witness_test.go` in an isolated checkout of the
revision to examine. Run on a Linux amd64 v3 CPU with Go 1.27.1.

```sh
for mode in 0 1 all all+attention; do
  GOAMD64=v3 MONOLITH_Q4_FFN_AVX2="$mode" \
    go test -count=1 -v -run '^TestIntelBatchWitness$' ./cmd/monolith
done
```

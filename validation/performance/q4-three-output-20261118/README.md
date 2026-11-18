# Three-output Q4 projection experiment

The candidate extends the Apple Silicon two-row layer kernel from
two outputs to three outputs per activation load. It preserves the
four accumulators and scale order for each output. The existing pair
and single-output kernels handle the remainder of each 32-output
worker tile. The [Q8 experiment](../q8-head-adjacent-20261118/)
supplied the interleaved trajectory probe.

## Model comparison

The run used Apple M4, Go 1.27.1, four workers, and pinned Llama 3.2
3B with Q4-mixed weights and FP16 KV. The model committed 128 prompt
tokens per session before the measurement. Every pair of trajectories
advanced both branches one token at a time for seven tokens, with
alternating order. The timed projection span covers Q/K/V, attention
output, Gate, Up and Down across the 28 layers.

| Sessions | Comparison | Q4 projections | Total forward | Total faster |
| ---: | --- | ---: | ---: | ---: |
| 2 | Reference / reference | 0.986 | 0.993 | 5 / 8 |
| 2 | Three outputs / reference | 0.989 | 0.988 | 5 / 8 |
| 1 | Reference / reference | 0.988 | 0.992 | 6 / 8 |
| 1 | Candidate label / reference | 1.029 | 1.024 | 1 / 8 |

The table gives medians of eight paired ratios of summed seven-token
times. In the two-session trial, the Q4 candidate ratio ranged from
0.954 to 1.092, and the same-kernel ratio ranged from 0.949 to 1.285.
When the candidate comparison ran second in its round and started
with the candidate, projection time had a median ratio of 0.983
and fell in all four pairs. When the comparison ran first and
started with the reference, the median ratio was 1.034 and fell
in one of four pairs. The starting arm and comparison position
varied together under this schedule.

One-session calls used the reference path under both labels. All 64
trajectories matched generated IDs, full logits and KV digests, and
workspace capacity. The two-session candidate dispatched 196
three-output projections per decode call. The focused race test
passed for tails, alternate row counts, unaligned input and wide sums.

Disassembly on arm64 showed 527 instructions for two outputs and 757
for three outputs, with zero stack references in both blocks before
the first return. The instruction reduction per output did not give
a distinguishable speedup in the model comparison.
[Model samples](receipt.json) · [Protocol](protocol.json) · [Instruction counts](codegen.json)

## Matrix comparison

Four synthetic matrices use the Llama 3.2 3B projection dimensions.
A matrix fixture uses two input rows and four workers. The driver
checks those protocol values before building.
A second paired-output variant advances typed block views through the
input and weight slices. All synthetic outputs matched bit for bit.

| Inputs × outputs | Reference / reference | Three outputs / reference | Advancing views / reference |
| --- | ---: | ---: | ---: |
| 3,072 × 1,024 (K/V) | 1.035 | 0.989 | 1.000 |
| 3,072 × 3,072 (Q/O) | 0.917 | 1.020 | 1.021 |
| 3,072 × 8,192 (Gate/Up) | 0.952 | 0.961 | 1.046 |
| 8,192 × 3,072 (Down) | 1.007 | 0.974 | 1.015 |

Each result is the median ratio of eight pairs of 16 timed
projections per arm. The Gate/Up candidate difference falls near
the same-kernel variation. Advancing views showed a median ratio
at or above about one in all four shapes. The measurements support
retaining both Q4 variants as experiments.
[Matrix samples](matrix-samples.json) · [Matrix receipt](matrix-receipt.json)

## Reproduction

Run the commands from a checkout containing this experiment and
the Q8 trajectory probe. Commit
`6d1e5b5207548048a2a0ad4c53082d1da8584854` contains the sources
identified by the original receipts. The reference runtime commit
is `77fdf336d0739e87802e741393453eeaa8331912`. Reproduction uses
`darwin/arm64`, Go 1.27.1 on PATH, Python 3.10 or later, and the
local model snapshot specified by the protocol. Prime the Go
module cache before the offline test builds.

```sh
GOENV=off GOWORK=off GOFLAGS= GOTOOLCHAIN=local go mod download
record=validation/performance/q4-three-output-20261118
python3 -S "$record/measure.py" --model "$MODEL_SNAPSHOT" --output runs/q4-three-output
python3 -S "$record/matrix.py" --output runs/q4-matrix-trial
go tool objdump -s '\.(dotQ4TwoRowOutputPair64|dotQ4TwoRowOutputTriple64)$' \
  runs/q4-three-output/build/probe.test
```

The scripts verify the runtime, test sources, and model files used
in each run. Comparison code is assembled in isolated build
directories.

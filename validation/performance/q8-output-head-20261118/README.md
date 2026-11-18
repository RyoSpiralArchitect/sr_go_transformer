# Two-row Q8 output projection

The [post-Q4 profile](../post-q4-output-profile-20261112/) placed the
Q8 output head at 37–41 ms per two-session decode call. This experiment
changes only the final head in an isolated build. The head has 3,072
inputs, 128,256 outputs and 64 weights per quantization block.

- **Reference and control** use the same runtime function.
- **Aligned** keeps one output channel per inner loop with complete blocks.
- **Lookup** replaces each integer conversion in the aligned block with a
  load from a 256-entry FP32 table. Every entry equals the corresponding
  signed byte converted to FP32.
- **Paired** processes two output channels from the same two activation
  rows, preserving each output's four accumulators and block order.
- **Paired lookup** combines the two changes.

The small fixture has 6,144 outputs. The full fixture uses the model's
128,256-output shape. All modes produce bitwise identical outputs in
the fixtures. The focused race run also covers odd output tails,
unaligned inputs, one and four rows, and the wide-activation fallback.

| Synthetic projection ratio | 6,144 outputs | 128,256 outputs |
| --- | ---: | ---: |
| Control / reference | 0.955 | 1.041 |
| Aligned / reference | 0.911 | 0.908 |
| Lookup / aligned | 1.048 | 1.011 |
| Paired / aligned | 0.902 | 0.854 |
| Paired lookup / paired | 1.006 | 1.086 |
| Paired / reference | 0.831 | 0.791 |

Ratios are medians of six within-round comparisons. The full-shape
synthetic control had individual ratios from 0.631 to 2.195, so its
small differences have limited resolution.

The Go arm64 disassembly shows 64 signed byte-to-float conversions
per output channel in the original block and zero in the lookup
block. For two output channels, pairing reduces activation loads
from 256 to 128 values while retaining 128 conversions and 256
fused multiply-adds. These are static instruction counts for a
complete 64-column block.

## Initial model comparison

The pinned Llama 3.2 3B Q4-mixed run used four workers, FP32 KV,
eight prompt tokens per session and seven decode calls. The timed
comparison changes the final head only. All 72 trials matched
generated IDs, logit and stored-KV digests, and workspace capacities
within session count.

| Mode | Two-session head, median ms | Head ratio vs. reference | Total decode ratio vs. reference |
| --- | ---: | ---: | ---: |
| Reference | 43.13 | 1.000 | 1.000 |
| Same-path control | 41.87 | 0.952 | 0.950 |
| Aligned | 36.67 | 0.880 | 0.910 |
| Lookup | 38.27 | 0.902 | 0.962 |
| Paired | 34.17 | 0.761 | 0.912 |
| Paired lookup | 33.15 | 0.783 | 0.968 |

Times are medians of per-trial head averages. Ratios are medians of
the six within-round comparisons. The single-session same-path
decode ratio was 1.185, and the prefill controls also exceeded the
frozen timing limits. This screen left full-decode speed unresolved.
[Model samples](model.json) · [Kernel samples](kernels.txt) ·
[Screen receipt and timing criteria](receipt.json)

## FP16 prefix replay

A second probe isolated decode from repeated prefill. It built
the candidate's ordinary Darwin arm64 head dispatcher, prepared
128 tokens per session once, and interleaved two labels per path
from the committed KV prefix. The paired kernel ran seven times
per eligible replay, with zero dispatches in single-session and
reference replays. All 32 replays matched logits, generated IDs,
stored KV, and workspace capacity. The two-session trajectory also
matched the [previous FP16 profile](../post-q4-output-profile-20261112/f16-s2-1024.json)
at 128 tokens.

| Two-session paired ratio | Head | Total decode |
| --- | ---: | ---: |
| Candidate / reference | 0.893 | 0.985 |
| Repeat / control | 0.968 | 1.321 |
| Control / reference | 1.006 | 0.977 |
| Repeat / candidate | 1.103 | 1.248 |

Each row is the median ratio over four rounds. Repeat and candidate
use the same dispatcher. Their median ratio for time outside the
head was 1.273, computed by subtracting the head interval from each
replay's total before forming the comparison. The timing variation
remains large after prefill isolation. The adoption criteria failed,
and the implementation is preserved in [candidate.patch](candidate.patch).
[Replay protocol](replay-protocol.json) · [All replay samples](replay-receipt.json)

With the candidate applied, local race tests, Go vet, 88 Python tests,
isolated probe builds, a cgo-free build and CLI smoke tests passed.

## Reproduce

Put Go 1.27.1 on PATH, and set `MODEL_SNAPSHOT` to the local checkpoint
specified in [protocol.json](protocol.json). The driver verifies model
files, runtime source, staged sources and the executable. Run from the
experiment checkout to reproduce the screen and the static counts.

```sh
python3 -S validation/performance/q8-output-head-20261118/run.py \
  --model "$MODEL_SNAPSHOT" --output runs/q8-output-head
go tool objdump -s '\.(dotQ8PairBlock64|q8ProbeLookupBlock|q8ProbePairedBlock|q8ProbePairedLookupBlock)$' \
  runs/q8-output-head/build/probe.test
```

Count `SCVTF*` and `FMADDS` before the first `RET` in each function.
Activation-value counts include two values for `FLDPS` and one for
`FMOVS` with a source at an offset of R0 or R1.
[Instruction counts](codegen.json)

To reproduce the FP16 confirmation, apply the candidate to a detached
worktree at the frozen source revision.

```sh
record="$PWD/validation/performance/q8-output-head-20261118"
scratch="$(mktemp -d)"
git worktree add --detach "$scratch/source" 77fdf336d0739e87802e741393453eeaa8331912
cd "$scratch/source"
git apply --unidiff-zero "$record/candidate.patch"
dest=validation/performance/q8-output-head-20261118
mkdir -p "$dest"
cp "$record/run.py" "$record/replay.py" "$record/replay-protocol.json" "$record/replay_test.go.txt" "$dest/"
python3 -S "$dest/replay.py" --model "$MODEL_SNAPSHOT" --output runs/q8-head-replay
```

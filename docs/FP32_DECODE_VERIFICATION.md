# FP32 decode kernel verification record

Verification-only document. It consolidates the evidence behind the FP32
input-sharing optimizations (PRs [#58](https://github.com/RyoSpiralArchitect/sr_go_transformer/pull/58),
[#59](https://github.com/RyoSpiralArchitect/sr_go_transformer/pull/59),
[#61](https://github.com/RyoSpiralArchitect/sr_go_transformer/pull/61),
[#62](https://github.com/RyoSpiralArchitect/sr_go_transformer/pull/62) and
[#63](https://github.com/RyoSpiralArchitect/sr_go_transformer/pull/63)) and the
rejected Q8, Q8-column-pairing and sixteen-output analogues. Nothing here is a
universal performance claim: every measurement is bound to the recorded host,
toolchain, fixture or model, and slower or neutral observations are kept
alongside favourable ones.

## What changed

`linearFP32Range` splits each task tile into a four-sequence-row path and a
remainder-row path. Both paths now share each input load across multiple
output accumulators, step by step:

1. **PR #58** (`5a5f87f`): remainder rows, two output accumulators.
2. **PR #59** (`511a5cc`): remainder rows, four accumulators, with two-column
   and scalar column tails.
3. **PR #61** (`ac2021a`): remainder rows, eight accumulators, with four-,
   two- and one-column tails. Sixteen accumulators measured slower and were
   rejected.
4. **PR #62** (`5355fe0`): `attend` score pass processes four positions per
   iteration, sharing each query load; per-position dot order and in-order
   max updates preserved.
5. **PR #63** (`56bd251`, hardened by `25ee5ac` after fresh-eye review):
   four-row (prefill) path pairs two output columns, so each four-row input
   bundle serves eight accumulators.
6. **PR #64** (`65682fa`): `attend` score pass leads with an eight-position
   group; the value pass unrolls four independent output elements.
7. **PR #65** (`380056c`, portability fixed by `bd6b1e6`): the oct
   remainder-row loop unrolls the input dimension four elements per
   iteration with sequential accumulator adds. CI caught a NaN-payload
   divergence on amd64 — operand order inside differently shaped kernels
   changes which NaN payload propagates — so the special-bits check treats
   NaN lanes as NaN while every non-NaN lane stays bit-exact.

Every output keeps its original ascending input-index accumulation order, so
results are bit-identical to the pre-change kernel. Task partitioning, worker
counts, parallel thresholds and executor policy are unchanged.

## Numerical verification

- Frozen scalar reference compared by `math.Float32bits` over 630 small shape
  combinations plus larger serial/parallel calls and special FP32 bit
  patterns (`cmd/monolith/fp32_outputs_test.go`,
  `cmd/monolith/fp32_outputs4_test.go`).
- Zero warm allocations and no post-join retained invocation state.
- Every completion compared byte-for-byte in kernel, synthetic-generation and
  real-model runs; no divergence observed.

## Timing evidence (Apple M4, Go 1.27.3)

### Kernel level (three fresh processes each, alternating order)

| Stage | workers1 shapes | workers4 shapes |
|---|---:|---:|
| Paired vs original scalar (remainder rows) | ~0.51–0.54x | ~0.52–0.81x |
| Quad vs paired (remainder rows) | ~0.62–0.65x | ~0.63–0.76x |
| Oct vs quad (remainder rows) | ~0.61–0.75x | ~0.74–0.88x |
| Two-column pairs (four-row path) | ~0.54–0.62x | ~0.55–0.76x |
| Four-position attend scoring (whole attend) | ~0.79–0.84x (hd64), ~0.66–0.78x (hd128) | serial per call |

Unchanged-path controls stayed near 1.00; slower or neutral observations are
retained in the raw receipts.

### Whole generation, synthetic FP32 fixture (alternating, completions identical)

| Shape | paired vs original | quad vs paired | oct vs quad | attend vs oct | 4-row pairs vs attend |
|---|---:|---:|---:|---:|---:|
| prefix33 / outputs128 | ~0.68x | ~0.78x | ~0.83x | ~0.96–0.97x | ~0.97x |
| prefix33 / outputs8 | ~0.79x | ~0.87x | ~0.92x | ~0.98x | ~0.81–0.83x |
| long-prefill / outputs1 | ~0.97–0.99x | ~0.99x | ~0.997x | ~0.97–0.98x | ~0.75x |

Long-prefill cases stayed near 1.00 until the four-row path itself was
paired; decode-dominated cases improved step by step.

### Real model: Llama-3.2-3B-Instruct, f32 weights, greedy, threads=4

Whole-process wall clock (`/usr/bin/time -p`), alternating fresh processes,
byte-identical outputs; includes weight load, dequantization, prefill and
decode.

| Run | reference | candidate | ratio |
|---|---:|---:|---:|
| 32 tokens (median of 3) | 32.45s | 21.60s | 0.666 |
| 64 tokens | 54.89s | 34.91s | 0.636 |
| 128 tokens: paired baseline vs quad | 59.09–59.62s | 42.75–44.25s | ~0.73 |
| 128 tokens: quad vs oct | 39.90–40.82s | 35.28–36.33s | ~0.89 |
| 128 tokens: oct vs attend pairing | 35.20–35.22s | 35.30–35.96s | ~1.00 |
| 256 tokens | 191.25s | 117.59s | 0.615 |
| ~330-token prompt + 8 tokens (four-row pairs) | 69.96–71.48s | 44.95–45.31s | ~0.64 |

Estimated decode-only cost (32 vs 64 token delta): ~0.59x reference. The
attend pairing is neutral at ~130 positions where attention is a small
share; it was adopted as a bit-exact step that scales with context length.

### Q8 control

- Q8 weights route through `linearQ8Into`/`linearQ8WideInto`/
  `dotQ8PairBlock64`, not `linearFP32Range`: measured ratio ~1.00 — a
  no-regression control, not an improvement claim.
- Applying the same column-pairing to `linearQ8Into`'s single remainder row
  measured ~1.02–1.05x (slower) at workers1 across three processes and was
  **rejected**. The bit-exact experiment remains in
  `cmd/monolith/q8_outputs_test.go`.
- Extending the FP32 remainder-row sharing to sixteen accumulators measured
  ~1.0–1.58x (slower) and was **rejected**; eight is the measured ceiling.
  The experiment remains in `cmd/monolith/fp32_outputs16_test.go`.

## Receipts

- `validation/performance/fp32-outputs-selection-20261107.json` (+ kernel,
  generation and control run files)
- `validation/performance/fp32-outputs-realmodel-20261107.json`
- `validation/performance/fp32-outputs4-selection-20261107.json` (+ kernel and
  generation run files)
- `validation/performance/fp32-outputs8-selection-20261108.json` (+ kernel and
  generation run files)
- `validation/performance/attend-scores-selection-20261108.json` (+ kernel and
  generation run files)
- `validation/performance/fp32-rows4-selection-20261108.json` (+ kernel and
  generation run files)
- `validation/performance/q8-outputs-kernel-20261107-run{1,2,3}.json`
- `validation/performance/fp32-outputs16-kernel-20261108-run1.json`
- Raw harnesses and binaries: `runs/` (ignored)

## Limitations

- Single real model, single prompt family, greedy sampling, one Apple M4
  host. Not a serving-throughput, tail-latency or memory-footprint claim.
- No claim for q8/q4 kernels, other platforms or toolchains, other models, or
  prefill-dominated workloads.
- The Q8 rejection is a measured outcome on this kernel structure, not a
  statement that quantized decode cannot be improved by other means.

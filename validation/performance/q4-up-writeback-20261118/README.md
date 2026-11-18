# Consuming Q4 Up results without writing the Up array

This follows the [Gate/Up ablation](../q4-gate-up-ablation-20261118/).
Keep the current paired Q4 dot product and every output's reduction
order. A worker computes Gate for its usual range, then applies SwiGLU
as it finishes each pair of Up outputs. Both trial arms apply SwiGLU
from the same local accumulators. The **store** arm also saves those
Up values into the regular workspace; the **local** arm omits those
stores. They use the same task ranges, one join, two wide-sum scans
and the same reserved memory. No production source changed.

On the two-row, 8,192-hidden fixture this removes writes of 16,384
FP32 values (64 KiB) per Gate/Up call. This is logical store traffic;
it is not a DRAM traffic or resident-memory measurement. The arm64
disassembly confirms four removed stores per paired output iteration
and two in the odd tail. Stores to the activated Gate output remain.

## Timing results

The Apple M4 fixture uses the Llama 3.2 3B FFN shape (3,072 input,
8,192 hidden), synthetic Q4 weights, Go 1.27.1 and GOMAXPROCS=4.
Two blocks reverse worker, stage and mode order; each phase has ten
balanced rounds of 32 calls per mode. The **reference** uses the current
separate Gate and Up calls and a separate SwiGLU pass. Identical labels
control for noise in both reference and store. Down runs separately
from the same immutable reference intermediate with identical code
under all five labels.

Each entry is the median of the ten within-round elapsed ratios,
followed by the number of wins where applicable.

| Workers | Block | Store control / store | Local / store | Local / reference |
| ---: | ---: | ---: | ---: | ---: |
| 1 | 1 | 1.0010 | 0.9986 (6/10) | 1.0072 (3/10) |
| 1 | 2 | 1.0005 | 1.0006 (5/10) | 1.0071 (0/10) |
| 4 | 1 | 1.0164 | 0.9960 (5/10) | 0.9771 (7/10) |
| 4 | 2 | 1.0032 | 0.9997 (5/10) | 0.9833 (10/10) |

The store-only effect is within 0.41% of parity in every block.
The aggregate four-worker change is faster in these observations
but cannot be attributed to store elision: in the second block,
even the store arm had a ratio of 0.9825 against reference. In the
first four-worker Gate/Up block, the same-path median absolute
deviations from 1 reached 9.83% (reference) and 5.16% (store),
above the frozen 4% bound. Down passed all its same-path bounds;
its largest median absolute deviation was 1.60% across all blocks.

**Decision: hold.** The store-only comparison did not reach the
predeclared 1%/7-of-10 bound in any block. The aggregate change also
did not pass across worker counts. No model timing or runtime
adoption followed this synthetic screen.

## Long-context correctness

The bounded test preserves the full Up reservation and routes only
eligible two-row aligned Q4 calls through the alternate Gate/Up.
A two-layer, four-query-head-per-KV-head fixture uses positions
1,027 / 1,024 and deliberately needs the Up scratch to fit the
four-lane shared attention plan. Without Up, the plan falls back to
per-head attention. The candidate retained the normalized attention
scores in Up and kept logits, all KV bits, committed positions and
workspace capacity equal to the reference, at both one and four
workers with FP32 and FP16 KV. A subsequent three-row call reused the
workspace and took the ordinary path; it also matched exactly.
One worker had enough score slots in the other buffers and did not
touch Up in the two-row call.

The tail and reused-output tests under the race detector additionally
cover odd tile widths, the cleared borrowed job, and Down output
equality. The isolated long-context wrapper is a correctness probe
and is not used for timing. Reserving the full Up slice still costs
the same memory. Removing its capacity would need a separate
liveness and admission study, including shapes where attention
borrows Up, and segments that fall back to the ordinary projection.

## Reproduction

Use Go 1.27.1 on Apple M4 and a populated Go module cache. The drivers
stage the frozen runtime and write to new output directories. No
checkpoint or network access is required once dependencies are cached.

```sh
record=validation/performance/q4-up-writeback-20261118
mkdir -p runs
sh "$record/run.sh" runs/up-writeback-reproduce
python3 -S "$record/assess.py" runs/up-writeback-reproduce
sh "$record/verify-long.sh" runs/up-writeback-reproduce runs/up-long-reproduce
```

The archived timings can be reassessed by calling the same assessor on
this record directory. See [protocol](protocol.json), [assessment](assessment.json)
and [run identity](receipt.json).

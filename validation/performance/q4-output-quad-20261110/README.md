# Four-output Q4 decode experiment

PR #72 reuses a single input row across two Q4 outputs. This experiment extends
that reuse to four outputs with the same four partial sums per output and the
same reduction order. Both variants keep the packed weight layout, 32-output
worker tiles and the paired tail. Neither passed the frozen synthetic gate.

Each cell compares four samples per kernel on the same synthetic matrix and
fixed worker executor. A ratio above 1 means the candidate took longer. Exact
tests cover complete 64-column blocks, all four output remainders, output
guards and dispatched ranges under the race detector.

| Input × output | Compact, 1 worker | Compact, 4 workers | Unrolled, 1 worker | Unrolled, 4 workers |
| --- | ---: | ---: | ---: | ---: |
| 4096 × 1024 | 1.3154 | 1.2392 | 0.9894 | 0.9896 |
| 4096 × 4096 | 1.3822 | 1.2417 | 0.9893 | 1.0112 |
| 4096 × 14336 | 1.3070 | 1.4540 | 0.9898 | 0.9940 |
| 14336 × 4096 | 1.3119 | 1.1748 | 1.0078 | 0.9285 |

The compact loop produces FP32 stack moves inside its loop on the M4 Go
1.27.1 build. Full unrolling removes those moves in the dot function and
increases its static instruction lines from 120 to 868. The paired function
has 445 lines and no such moves. The generated code explains a plausible
source of overhead, without isolating the timing cost of individual
instructions. The unrolled variant reaches the 5% target in one of four
four-worker shapes. The gate requires three, with at most 5% regression
in every cell. These measurements cover synthetic one-row projections.

The compact invocation used Go's `-count=2`, which repeats each sub-benchmark
before proceeding to the next. Its actual order was AABBBBAA. The unrolled
candidate explicitly used ABBAABBA with `-count=1`. The original protocols
and all samples are retained. Real-model confirmation was gated on passing
the synthetic screen.

To reproduce, use an isolated checkout at the base commit in `decision.json`
and copy `compact.go.txt` to `cmd/monolith/q4_output_quad_test.go`. With
`GOMAXPROCS=4`, run the following commands from the checkout.

```sh
go test -race ./cmd/monolith -run '^TestQ4Output(Quad|Pair)' -count=1
go test ./cmd/monolith -run '^$' -bench '^BenchmarkQ4OutputQuad$' -benchtime 200ms -count 2
```

For the unrolled variant, pass the archived compact source and the test file
path as the two arguments to `expand.py`, then run `gofmt` on the test file.
Use the same race test and replace the benchmark's `-count 2` with `-count 1`.
The archived source is deliberately outside the runtime and test package.

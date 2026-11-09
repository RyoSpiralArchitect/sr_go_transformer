# Paired Q4 decode outputs

For a single input row with complete 64-column Q4 blocks, two output channels
share activation loads while keeping separate four-way sums and the original
reduction order. Odd output tails, partial input blocks, multiple input rows,
and wide-activation safeguards retain their established kernels. The fixed
worker executor and its ownership contract are unchanged.

Two predeclared, independent AB/BA comparisons used the existing pinned
Mistral-7B-Instruct-v0.3 weights in Q4-mixed storage, four workers, an eight-token
prefix per session, and seven decode calls. Each process warmed both cases and
measured three trials; case order reverses with the second process pair.

| Candidate / baseline median | Repeat 1 | Repeat 2 |
| --- | ---: | ---: |
| Single-session decode | 0.8323 | 0.7174 |
| Single-session prefill | 0.9879 | 0.8846 |
| Two-session decode | 1.0300 | 0.9894 |
| Two-session prefill | 1.0142 | 0.9924 |

All logits, committed KV values, and generated IDs match bit-for-bit in all
48 measured case trials. Both repetitions satisfy the frozen target of at
least 5% single-session decode improvement and no control median regression
over 5%. Timing varies substantially between repetitions, including unchanged
prefill paths; these are host/workload-specific observations, not a universal
speedup, long-context result, HTTP throughput result, or language-quality score.

The initial unbalanced microbenchmark remains an exploratory pilot. It is not
used for adoption. Its harness now supports both execution orders. Independent
review also added an actually dispatched four-worker odd-tail exactness test
and made process order, aggregation, and input hashes explicit in the protocol.

Raw bounded receipts and the decision are under `validation/performance/`:
`q4-output-pair-mistral-20261110-run{1,2}.json`,
`q4-output-pair-protocol-20261110.json`, and
`q4-output-pair-decision-20261110.json`.

Local full race, vet, Python driver tests, isolated probe builds, cgo-free
build/CLI smoke checks passed. The added parallel test also passed separately
under the race detector. Production adoption is gated by successful CI on the
final PR head for Go 1.22/Linux, stable/Linux, and stable/macOS.

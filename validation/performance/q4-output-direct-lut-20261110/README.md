# Direct table loads in the four-output Q4 kernel

The first full-unroll experiment counted float register spills. Integer
instructions still copied two-float lookup entries to the stack before
loading the values into float registers. The revised source takes each
entry's address and uses both values immediately. Each input pair is
shared by four outputs, with the original four partial sums per output
and the original block scaling and reduction order.

On the M4 Go 1.27.1 build, the four-output dot function went from 204
instructions mentioning the stack pointer to zero. The current pair,
previous quad, revised pair and revised quad were measured in the same
process. All four four-worker shapes passed the synthetic threshold. The
revised quad was about 28–30% faster than the current pair in elapsed time,
and about 12–13% faster than the revised pair. Both use the same packed
weights, lookup table, worker tile sizes and synthetic input. See
`bench.txt`, `micro-decision.json` and `protocol.json`.

The inference candidate routes one-row Q4 projections with complete
64-column blocks through the new kernel. The pair handles the remaining
one to three output channels. The same wide-input guard, multi-row code
and worker ranges apply. The tests exercise the ordinary inference
entry, incomplete output tiles, guarded buffers and descriptor cleanup.

To regenerate the test-only synthetic comparison, use an isolated
checkout at the base commit from `protocol.json`. Expand the previous
`compact.go.txt` with its archived `expand.py` and gofmt the result.
Then run this directory's `generate.py` with the base monolith source,
the expanded prior test source, and
`cmd/monolith/q4_direct_lut_test.go` as its three arguments. Format the
generated file and run the commands below with `GOMAXPROCS=4`.

```sh
go test -race ./cmd/monolith -run '^TestQ4(DirectLUT|OutputPair)' -count=1
go test ./cmd/monolith -run '^$' -bench '^BenchmarkQ4DirectLUT$' -benchtime 200ms -count 1
```

See `mistral-interrupted.md` for the incomplete Mistral attempt and
`llama32-protocol.json` for the separately pinned Llama comparison.

Two balanced Llama 3.2 3B Q4-mixed comparisons on the M4 passed their
predeclared timing and parity gates. The median ratios below compare the
candidate with the current pair.

| Case | Repeat 1 | Repeat 2 |
| --- | ---: | ---: |
| single decode | 0.7761 | 0.7979 |
| single prefill | 1.0013 | 1.0201 |
| two decode | 0.8884 | 0.9856 |
| two prefill | 0.9246 | 0.9947 |

All 48 case trials matched logits, KV and token IDs. These results use
short prompts and seven decode steps. The two-session controls varied
between runs. The measured single-session gains apply to this workload.
The Mistral adoption gate remains open. The runtime candidate and both
Llama receipts are retained on a local branch for review.

# Single-row Q4 FFN on Apple M4

The experimental NEON kernel processes four Gate, Up or Down output channels
per activation load. The ordinary Darwin arm64 binary selects it with
`MONOLITH_Q4_FFN_NEON=all`. The established value `1` selects the two-row
kernel. Both modes use the same packed weights, scales and executor.

## Isolated projections

These are the dimensions of one Llama 3.2 3B FFN projection. Gate and Up have
the same shape and the benchmark times one matrix at a time. Each pair used
eight measured calls per arm, with the starting arm alternating over six
pairs. Times below are separate medians in milliseconds.

| Projection | Workers | Go | NEON | Faster pairs |
| --- | ---: | ---: | ---: | ---: |
| Gate or Up, 3072 → 8192 | 1 | 2.940 | 1.507 | 6/6 |
| Gate or Up, 3072 → 8192 | 4 | 0.816 | 0.441 | 6/6 |
| Down, 8192 → 3072 | 1 | 2.946 | 1.552 | 6/6 |
| Down, 8192 → 3072 | 4 | 0.836 | 0.454 | 6/6 |

The Go benchmark reported zero allocations/op in all 48 samples. Four
samples reported 2 B/op. The complete output includes the binary digest and
every sample. [Projection samples](projections.txt)

## Resident Llama 3.2 3B decode

The pinned checkpoint ran offline on a 24 GiB Apple M4 with Go 1.27.1,
four workers, Q4-mixed weights and FP16 KV. One resident model served both
arms. A used the Go four-output loop and B used the single-row NEON leaf.
The existing two-row NEON leaf was active in both arms. Each replay restored
a 128-token prefix, timed seven forward calls and hashed the logits and KV
outside the timer. Each case used eight counterbalanced rounds, including
a repeat of each arm in every round. [Protocol](protocol.json)

| Sessions | Go ms/forward | NEON ms/forward | Paired time ratio | Faster rounds | Exact replays |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 143.92 | 106.78 | 0.7374 | 8/8 | 32/32 |
| 2 | 174.88 | 184.43 | 1.0492 | 3/8 | 32/32 |

All 64 replays reproduced the greedy IDs, logit and KV digests, cache
positions, workspace size and KV payload. The two-session result is a
control because both arms executed the same two-row kernel. [Raw replays](events.jsonl)

**The run missed the promotion criteria.** The first attempt stopped during
loading after the system reported 112 new swapout pages. A separate
observation retained every sample and evaluated the same limits. It recorded
1,968 additional swapout pages through loading and the first warmup, with
no increase during the timed rounds. The one-session NEON repeat had a
7.29% median absolute timing difference against a 5% limit. Both session
counts missed the repeatability screen. The single-row result supports an
explicit opt-in for further evaluation. [First stop](load-stop.jsonl) · [Assessment](assessment.json)

## Reproduction

The measured runtime is at `7254c73`, based on `a061282`. The measured binary
and the hashes of its source files and generated test fixture are in the
first event. The fixture switches only the single-row hook between synchronous
replays. In the shipping CLI, kernel selection happens once at startup.
The replay also checks the HF snapshot against the repository's pinned hashes.

```sh
d=validation/performance/q4-ffn-single-neon-20261124
python3 -S "$d/assess.py"
python3 -S "$d/measure.py" "$MODEL" "$OUTPUT"
GOMAXPROCS=4 go test ./cmd/monolith -run '^$' -bench '^BenchmarkQ4FFNQuadNEON$' -benchtime=8x -benchmem
```

Use a new output directory and the Go version in the protocol. The driver
stops at the first memory limit by default. Its `--observe-swap` option
records swapouts through completion while retaining the memory criterion and
free-memory floor. The Linux AVX2 comparison is a separate follow-up.

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
outside the timer. Each case used eight rounds, including a repeat of each
arm in every round. Each arm went first in four primary comparisons.
The position within the four-sample sequence was only partially balanced.
[Protocol](protocol.json)

| Sessions | Go ms/forward | NEON ms/forward | Paired time ratio | Faster rounds | Exact replays |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 143.92 | 106.78 | 0.7374 | 8/8 | 32/32 |
| 2 | 174.88 | 184.43 | 1.0492 | 3/8 | 32/32 |

All 64 replays reproduced the greedy IDs, logit and KV digests, cache
positions, workspace size and KV payload. The two-session result is a
control because both arms executed the same two-row kernel. [Raw replays](events.jsonl)

The ordinary offline CLI also generated the same six greedy tokens as
the previous release on both Llama 3.2 3B and Qwen2.5 0.5B Instruct with
the prompt `Hi`. The receipt records the source and binary hashes, command
arguments and token IDs. [CLI comparison](cli-parity.json)

In the one-session schedule, the primary NEON sample occupied positions
1 through 4 respectively 2, 2, 0 and 4 times. The primary Go sample occupied
each position twice. The two-session case reversed the order. As a sensitivity
check, using only the repeats gives ratios of 0.7344 and 0.9818 for one and
two sessions. Summing both samples per arm within each round gives 0.7450
and 1.0035. These additional calculations leave the original assessment
intact. For a fresh confirmation, replacing both `bAaB` rounds with
`bABa` would place each label in each position twice.

**The run missed the promotion criteria.** The first attempt stopped during
loading after the system reported 112 new swapout pages. A separate
observation retained every sample and evaluated the same limits. It recorded
1,968 additional swapout pages through loading and the first warmup, with
no increase during the timed rounds. The one-session NEON repeat had a
7.29% median absolute timing difference against a 5% limit. Both session
counts missed the repeatability screen. The single-row result supports an
explicit opt-in for further evaluation. [First stop](load-stop.jsonl) · [Assessment](assessment.json)

## Reproduction

The driver stages production sources from `7254c73`, based on `a061282`,
using the local Git history. The assessor verifies the binary, staged sources
and generated test fixture against that build. The fixture switches only the
single-row hook between synchronous replays. In the shipping CLI, kernel
selection happens once at startup. The driver checks the HF snapshot against
the repository's pinned hashes.

```sh
d=validation/performance/q4-ffn-single-neon-20261124
python3 -S "$d/assess.py"
python3 -B -S -m unittest discover -s "$d"
python3 -S "$d/measure.py" "$MODEL" "$OUTPUT"
python3 -S "$d/assess.py" "$OUTPUT/events.jsonl"
```

Use a new output directory and the Go version in the protocol. The driver
stops at the first memory limit by default. Its `--observe-swap` option
records swapouts through completion while retaining the memory criterion and
free-memory floor. To repeat the six pairs in the isolated projection table
with the measured sources, set `PROJECTION_DIR` to a new directory and run
the following from the repository root.

```sh
git worktree add --detach "$PROJECTION_DIR" 7254c73ebfbebe87fd45bd47b6340c3a20fe4a55
cd "$PROJECTION_DIR"
export GOMAXPROCS=4 CGO_ENABLED=0 GOENV=off GOWORK=off GOTOOLCHAIN=local GOFLAGS='' GOEXPERIMENT=''
go test -c -trimpath -o ./kernel.test ./cmd/monolith
for mode in Go NEON NEON Go Go NEON NEON Go Go NEON NEON Go; do
  ./kernel.test -test.run='^$' -test.bench="^BenchmarkQ4FFNQuadNEON$/.*/.*/^${mode}$" -test.benchtime=8x -test.benchmem
done
```

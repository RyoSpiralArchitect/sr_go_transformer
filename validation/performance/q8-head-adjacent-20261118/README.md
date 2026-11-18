# Adjacent Q8 head comparisons on Llama 3.2 3B

The benchmark used an Apple M4, Go 1.27.1, four workers, Q4-mixed
weights, FP16 KV, and two sessions with 128 committed tokens each.
The vocabulary projection has 3,072 inputs and 128,256 outputs. The
previous experiment supplied the two-output runtime through its
archived patch. This probe also generates a pure-Go three-output
range. It retains four accumulators for each input row and output,
scales each block after the same reduction, and assigns disjoint
output ranges to workers. [Previous experiment](../q8-output-head-20261118/)

## Captured inputs

The benchmark captured the normalized input to the Q8 head at every
step of the reference seven-token trajectory. Both arms of each
comparison read the same capture and Q8 weights, write into reusable
output buffers and run one after the other. The calls switch order
every round. All 504 timed projections matched the captured reference
logits bit for bit.

| Head comparison | Baseline median | Candidate median | Median paired ratio | Candidate faster |
| --- | ---: | ---: | ---: | ---: |
| Two outputs / reference | 47.16 ms | 38.57 ms | 0.828 | 40 / 42 |
| Three outputs / reference | 47.45 ms | 37.77 ms | 0.784 | 42 / 42 |
| Three outputs / two outputs | 38.62 ms | 37.49 ms | 0.962 | 31 / 42 |

The three-output ratio against the reference was 0.789 when the
reference ran first and 0.783 in the reverse order. Same-mode median
ratios ranged from 0.989 to 1.001. The third output's incremental gain
over two outputs was smaller. Its individual paired ratios ranged
from 0.825 to 1.160. [All samples](receipt.json) · [Protocol](protocol.json)

The three-output block loads 128 activation values to compute six
64-column dot products across two rows and three channels. The
reference takes three block calls and loads 384 activation values
for that work.
The three-output block emits 192 signed conversions and 384 fused
multiply-adds, with zero stack references before its first return.
[Disassembly counts](codegen.json)

## First decode step

For the first token after the prefix, both arms used the same
committed input and reused private KV append pages. All 72 forwards
matched the reference logits, written KV and workspace size.
The paired median for total forward time was 0.953 for two outputs
against reference and 0.947 for three outputs against reference.
The same-reference median was 1.036, with individual ratios
from 0.873 to 1.219. This stage characterizes one decode position
with page allocation excluded. [First-step samples](receipt.json)

## Seven-token decode

Two branches shared the immutable prefix and each committed its own
FP16 KV. The first arm rotated by round, comparison and token.
Both arms ran before advancing to the next token. Each selected
the next ID from its own logits. The timings cover the ordinary
forward call with an allocated private append page and a reused
workspace. All 64 trajectories matched the reference's generated
IDs, full logits and KV digests, and workspace capacity.

| Comparison | Head median ratio | Total median ratio | Total faster |
| --- | ---: | ---: | ---: |
| Reference / reference | 1.003 | 1.010 | 3 / 8 |
| Two outputs / reference | 0.811 | 0.958 | 7 / 8 |
| Three outputs / reference | 0.767 | 0.924 | 8 / 8 |
| Three outputs / two outputs | 0.947 | 0.997 | 5 / 8 |

Each ratio divides the sums of seven timed calls, then takes the
median across eight matched trajectories. Three-output to reference
total ratios ranged from 0.893 to 0.961. The direct three-output to
two-output comparison narrowed the head time by 5.3% by the paired
median. Its total ratio ranged from 0.900 to 1.071, with median
0.997. Both tiled versions remain experiment candidates.
[Trajectory samples](trajectory-receipt.json) · [Protocol](trajectory-protocol.json)

## Reproduction

Use the frozen runtime and archived patch at the commit containing
this record. Place Go 1.27.1 on PATH and set `MODEL_SNAPSHOT` to the
pinned local model revision in the protocol.

```sh
record=validation/performance/q8-head-adjacent-20261118
python3 -S "$record/run.py" --model "$MODEL_SNAPSHOT" --output runs/q8-head-adjacent
python3 -S "$record/trajectory.py" --model "$MODEL_SNAPSHOT" --output runs/q8-head-trajectory
go tool objdump -s '\.(dotQ8PairBlock64|dotQ8OutputPair64|dotQ8TripleTrial64)$' \
  runs/q8-head-adjacent/build/probe.test
```

Count scalar `SCVTF*` and `FMADDS` instructions before the first
`RET` in each block. Activation loads use R0 and R1, with two
values per `FLDPS` and one per scalar `FMOVS`.

The race test covers odd output tails in parallel 96-output ranges,
one and three input rows, unaligned columns and the wide sum fallback.

```sh
cp "$record/exact_test.go.txt" runs/q8-head-adjacent/build/exact_test.go
(
  cd runs/q8-head-adjacent/build
  GOENV=off GOWORK=off GOFLAGS= GOTOOLCHAIN=local GOEXPERIMENT= GOPROXY=off \
    GOSUMDB=off GOMAXPROCS=4 CGO_ENABLED=1 \
    go test -race -count=1 -run '^TestAdjacentQ8HeadFallbacksAndTails$' .
)
```

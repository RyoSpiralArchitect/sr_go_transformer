# Two-row Q4 projection timing on Apple M4

The probe compares the existing two-row kernel, the previous direct
lookup-table candidate and a tile that shares activation loads across
two output channels. An identical reference mode measures timing
variation. The projection fixtures use the Llama 3.2 3B matrix shapes
and execute all modes in one binary with balanced order.

The Gate and Up matrices each have 3,072 input and 8,192 output
channels. Down has 8,192 inputs and 3,072 outputs. All three have the
same number of packed blocks. Down works through 128 blocks per
output with 96 output tiles, while Gate and Up use 48 blocks per
output and 256 output tiles. Measuring one worker as well as four
makes the comparisons less dependent on executor timing.

| Two-row synthetic fixture | Workers | Same-path ratio | Direct LUT ratio | Two-output ratio |
| --- | ---: | ---: | ---: | ---: |
| Gate/Up | 1 | 1.003 | 0.921 | 0.662 |
| Down | 1 | 1.002 | 0.926 | 0.667 |
| Gate/Up | 4 | 1.002 | 0.908 | 0.685 |
| Down | 4 | 1.013 | 0.926 | 0.672 |

Ratios are medians of the four within-round comparisons. The
four-worker Down direct-LUT ratios span 0.850 to 1.029. Its same-path
ratios span 0.893 to 1.036. The earlier 1.009 Down ratio falls within
this variation. The single-worker Down direct-LUT ratios range from
0.924 to 0.928. These results show a Down improvement on this host and
leave the specific cause of the earlier timing variation unresolved.

The model run used a pinned Llama 3.2 3B model with Q4-mixed weights,
FP32 KV, four workers and an eight-token prefix. Each trial measures
seven decode calls. Gate, Up and Down span all 28 layers and include
worker joins. Displayed times are medians in milliseconds per call.
The ratio column uses within-round pairs.

| Model decode | Reference ms | Two-output ms | Two-output ratio |
| --- | ---: | ---: | ---: |
| Gate, two sessions | 56.64 | 38.56 | 0.681 |
| Up, two sessions | 57.04 | 38.63 | 0.681 |
| Down, two sessions | 56.94 | 38.81 | 0.682 |
| Total, two sessions | 271.73 | 199.75 | 0.735 |
| Total, one session | 154.90 | 154.61 | 1.002 |

All 32 measured trials matched generated IDs, prompt IDs, logits
and KV digests within session count. Workspaces matched at 1,496,576
and 2,992,640 bytes for one and two sessions. The direct LUT
two-session total decode ratio was 0.925. The two-output candidate
passed the frozen screen with all four two-session ratios below one.

The candidate dispatch only handles two input rows with aligned
64-column blocks. Prefill in this probe uses 8 or 16 input rows, so
all four modes execute the same path. Two-session same-path prefill
ratios span 0.997 to 1.241 (median 1.012). In the slow pair both the
timed FFN and the remaining forward interval increased. The experiment
demonstrates variation in the same execution path at the scale of the
previous comparison. It does not identify the host-level source of
that variation.

## Reproduce the screen

Put Go 1.27.1 on PATH. Set `MODEL_SNAPSHOT` to the local pinned snapshot
identified in [protocol.json](protocol.json). Create a separate
worktree from the frozen runtime revision, copy the four harness
files, and run the probe offline.

```sh
record="$PWD/validation/performance/q4-projection-20261112"
scratch="$(mktemp -d)"
git worktree add --detach "$scratch/source" 65e227d18a0121763c495124c573bbfb1d57d353
cd "$scratch/source"
dest=validation/performance/q4-projection-20261112
mkdir -p "$dest"
cp "$record/run.py" "$record/probe_test.go.txt" "$record/protocol.json" "$record/summarize.py" "$dest/"
python3 -S "$dest/run.py" --model "$MODEL_SNAPSHOT" --output runs/q4-projection-roles
python3 -S "$dest/summarize.py" runs/q4-projection-roles
```

The driver checks the pinned model file hashes before and after the run.
It stages the instrumented runtime in the run directory and records the
staged source and executable hashes. [Receipt](receipt.json) ·
[Kernel samples](kernels.txt) · [Model samples](model.json) ·
[Paired summary](summary.json)

## Default-runtime confirmation

The candidate patch installs the two-output kernel on Darwin arm64
for aligned two-row Q4 projections. The ordinary inference probe
builds the pinned reference and candidate separately and balances
process order and session order. No stage timers are present.
Both builds matched all 24 model trials and workspace sizes.
The targeted Q4, quantization and shared-KV race tests also passed
with the patch applied.

| Workload | First pair | Second pair | Median paired ratio |
| --- | ---: | ---: | ---: |
| One-session prefill | 1.1053 | 0.9994 | 1.0524 |
| One-session decode | 1.0613 | 1.0000 | 1.0306 |
| Two-session prefill | 1.0582 | 0.9944 | 1.0263 |
| Two-session decode | 0.7442 | 0.7112 | 0.7277 |

Two-session decode passed the speed criterion in both pairs.
Single-session prefill exceeded the 1.05 guard, so the first
confirmation failed and the candidate remains a patch.

The eight-token prefill uses the existing four-row Q4 path in both
builds. In `go tool objdump -s '\.linearQ4Range$'` of the ordinary
probe binaries, the source-line slice for `if r+4 <= n` through the
fourth output write has 261 instructions in both builds, in identical
opcode order. The slice has 24 FMADDS and 11 stack references in each
build. Register operands differ. The static comparison leaves timing
effects from layout and host activity unresolved.

From the detached runtime worktree used above, apply the patch and
run the ordinary confirmation. Reverse the patch in that worktree
and repeat with the same runtime in both builds to measure
cross-process variation independently.

```sh
git apply --unidiff-zero "$record/candidate.patch"
python3 -S scripts/compare_inference.py --model "$MODEL_SNAPSHOT" --id llama32-3b \
  --baseline-ref 65e227d18a0121763c495124c573bbfb1d57d353 \
  --weight-format q4-mixed --case-order balanced \
  --output-dir runs/q4-projection-confirmation

git apply --unidiff-zero --reverse "$record/candidate.patch"
python3 -S scripts/compare_inference.py --model "$MODEL_SNAPSHOT" --id llama32-3b \
  --baseline-ref 65e227d18a0121763c495124c573bbfb1d57d353 \
  --weight-format q4-mixed --case-order balanced \
  --output-dir runs/q4-projection-same-binary
```

[Confirmation protocol](confirmation-protocol.json) ·
[Confirmation receipt](confirmation.json) ·
[Confirmation summary](confirmation-summary.json)

## Cross-process control

Both executables in this run had the same SHA-256 digest and used
the current production runtime. All 24 numerical signatures and
workspace sizes matched.

| Workload | First pair | Second pair | Median paired ratio |
| --- | ---: | ---: | ---: |
| One-session prefill | 1.0989 | 1.0018 | 1.0503 |
| One-session decode | 1.0953 | 1.0080 | 1.0516 |
| Two-session prefill | 1.0744 | 1.0260 | 1.0502 |
| Two-session decode | 1.0490 | 1.0173 | 1.0331 |

The same executable reproduced a one-session prefill shift of the
same magnitude as the reference/candidate confirmation. This bounds
what can be attributed to the candidate from these runs. It leaves
the original failed confirmation intact and the default runtime
continues to use the reference kernel.

[Control protocol](same-binary-protocol.json) ·
[Control receipt](same-binary.json) · [Control summary](same-binary-summary.json)

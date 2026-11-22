# Darwin arm64 Q4 feed-forward projection

This comparison exercises the Gate, Up and Down projections in the ordinary
Go build. The native leaf decodes the packed weights into NEON registers,
shares activations between two output channels, and keeps four FP32
accumulators in the same order as the scalar kernel. Quantization, activation
functions, scheduling and KV storage use the production implementation.

## Workload

The baseline is `74f4a7a`. The automatically enabled timing candidate is at `5ff3007`. In the shipping binary,
`MONOLITH_Q4_FFN_NEON=1` selects the same leaf at process startup.
The two package builds use Go 1.27.1 with cgo disabled and empty Go flags and
experiments. The resident test fixture calls the uninstrumented model method
and loads the same pinned Llama 3.2 3B snapshot into both processes. Only one
process computes at a time. The offline CLI also exercises a two-token prompt.

The [protocol](protocol.json) fixes Q4-mixed weights, FP16 KV, four workers,
128- and 512-token prefixes, and one or two sessions. Each replay restores
each session's prefix and times seven decode forwards. The runner checks
every logit and KV bit by digest, the greedy IDs, cache positions, KV payload
and workspace. A and B are baseline and native. Lowercase labels repeat the
same binary to measure timing noise. Each condition has eight rounds, with
both arm orders and 32 replays.

The acceptance rule requires both same-binary control medians within 3% and
their median absolute deviations from one within 5%. The one-session native
median may be at most 5% slower. Each two-session condition must have a
paired median at least 5% shorter, win at least seven rounds and improve in
both order strata. All numerical and memory checks must pass.

## First screen

All 128 replays matched. The two-session paired median ratios were 0.8141 and
0.8521. Each two-session condition failed at least one same-binary control. The
512-token condition won six of eight rounds. The run therefore failed the timing rule. Its raw
temporary output was lost in a host restart. The [preserved summary](first-screen.json)
contains only the rounded values available from the operator log. Another
observed run was launched before the restart and has no recoverable outcome.

## Monitored comparison

The [quiet-entry observation](entry-timeout.jsonl) expired after ten minutes.
A separate [shared-host run](host-load.jsonl) observed a median 385% of one CPU
core in other processes during setup and replay. All 128 measured replays
matched their reference. Free memory stayed at or above 66% at the recorded
checkpoints, with zero new swapout pages.

| Prefix | Sessions | Scalar ms/forward | NEON ms/forward | Paired ratio | Native wins | Timing controls |
| ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 128 | 1 | 346.9 | 465.2 | 1.244 | 1/8 | Failed |
| 512 | 1 | 194.3 | 193.8 | 0.993 | 5/8 | Passed |
| 128 | 2 | 272.1 | 193.8 | 0.775 | 7/8 | Failed |
| 512 | 2 | 252.1 | 207.5 | 0.836 | 7/8 | Failed |

Time columns are each arm's median seven-forward replay time divided by seven.
The paired ratio is the median of the eight within-round native/scalar ratios.
The scalar repeat's median absolute distance from one was 13.0% at 128 tokens
and 8.0% at 512 tokens for two sessions. Both exceeded the 5% limit. At one
session and 128 tokens the two binaries ran the scalar path and also failed
the stability criterion. The full [assessment](assessment.json) records the
failed gate and order strata, and the [raw events](events.jsonl) retain every
sample. These observations support shipping the native leaf as an opt-in.

## Shipping binary

A separate [release check](release.json) builds the production sources at
`c9202a8` and starts the same binary with the environment switch unset and
set to `1`. Both CLI invocations encoded `Hi` as two prompt tokens and
generated IDs `[11, 358, 2846]`. Both modes also reproduced the scalar
reference logits, greedy IDs, FP16 KV contents, positions and workspace
for two 128-token sessions over seven decode forwards. This check records
numerical parity and the executable hashes.

## Reproduction

Use a checkout with the baseline, candidate and tooling commits in its Git
history, a locally cached Go module dependency, and the exact offline model
snapshot in the [model catalog](../../hf/model-profiles.json). Put the output
on persistent storage. The observer samples other processes' CPU usage every
two seconds and records aggregate percentages without process identifiers.
Its default entry check allows ten minutes for a 20-second quiet window.
Pass `--existing-load` to record a shared-host run explicitly. The replay
order and timing acceptance limits are identical in both modes.

```sh
record=validation/performance/q4-ffn-neon-20261122
# The measured candidate enables the leaf at startup in this checkout.
git worktree add --detach "$MEASURED_CHECKOUT" 12835e3024092322626145fd60e3d11c415c5b81
python3 -S "$MEASURED_CHECKOUT/$record/observe.py" --existing-load "$MODEL_SNAPSHOT" "$NEW_OUTPUT_DIR"
python3 -S "$record/assess.py" "$NEW_OUTPUT_DIR/run/events.jsonl"
# Run from the release checkout to validate the shipped opt-in and default.
python3 -S "$record/verify_release.py" "$MODEL_SNAPSHOT" "$record/events.jsonl" "$NEW_RELEASE_OUTPUT"
MONOLITH_Q4_FFN_NEON=1 go test -race -run '^TestQ4FFN' -count=1 ./cmd/monolith
go test -tags=purego -run '^TestQ4' -count=1 ./cmd/monolith
```

The assessment checks the package input manifests against both Git commits,
the common fixture and the model catalog before comparing times. It prints the
results and exits with status 1 when a complete run misses the timing rule.
The [experimental SIMD study](../decode-hotspots-20261121/) records the
earlier compiler-experiment implementation separately.

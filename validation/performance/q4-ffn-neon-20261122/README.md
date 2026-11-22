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
0.8521. Both same-binary control screens failed and the 512-token condition
won six of eight rounds. The run therefore failed the timing rule. Its raw
temporary output was lost in a host restart. The [preserved summary](first-screen.json)
contains only the rounded values available from the operator log. Another
observed run was launched before the restart and has no recoverable outcome.

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
MONOLITH_Q4_FFN_NEON=1 go test -race -run '^TestQ4FFN' -count=1 ./cmd/monolith
go test -tags=purego -run '^TestQ4' -count=1 ./cmd/monolith
```

The assessment checks the actual package input manifests against both Git
commits, the common fixture and the model catalog before comparing times.
The [experimental SIMD study](../decode-hotspots-20261121/) records the
earlier compiler-experiment implementation separately.

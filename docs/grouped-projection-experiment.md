# Grouped projection dispatch: not adopted

The candidate batches Q/K/V and Gate/Up into one fixed-worker invocation per
group. It keeps the existing per-matrix arithmetic, falls back for Q8, small
work and extreme Q4 inputs, and clears borrowed descriptors after the join.
Its fixed three-projection packet adds 232 bytes to each executor on a 64-bit
host; callbacks remain lazy and warm dispatch allocates no new objects.

Two frozen AB/BA comparisons used pinned Mistral-7B-Instruct-v0.3 Q4-mixed,
four workers, eight-token prefixes and seven decode calls. Case order reverses
in the second process pair. Each ratio uses six candidate and six baseline
trials; both complete first repetitions are retained.

| Candidate / baseline median | Repeat 1 | Repeat 2 |
| --- | ---: | ---: |
| Single-session decode | 1.0824 | 0.8112 |
| Single-session prefill | 1.0235 | 0.8949 |
| Two-session decode | 0.9820 | 0.8202 |
| Two-session prefill | 0.9527 | 0.9107 |

All measured logits, committed KV and generated IDs match exactly. The first
single-session result regressed rather than improving by the required 5%.
The second improved, but cannot replace the first. Timings varied materially;
these observations do not establish a universal slowdown, a stable speedup,
or its cause. The candidate fails the predeclared requirement that **both**
repetitions pass every gate and is therefore not enabled in production.

Production keeps separate projection dispatch. The final PR contains the
protocol, both full receipts, the decision and an exact reconstruction patch.
There is no hidden runtime switch or dormant production fast path.

The archived candidate passed full local race, vet, Python driver tests,
isolated probe builds, cgo-free build and CLI smoke checks, plus Linux Go
1.22/stable and macOS stable CI. Independent review strengthened aligned-Q4
parallel coverage and poisoned reused outputs to catch missing writes. Its
initial descriptor-footprint failure was resolved by accounting explicitly
for the bounded group packet. These checks establish compatibility within
their coverage, not the missing stable performance improvement.

To reconstruct for a future, separately controlled experiment, use a fresh
checkout of `cc91daf3b455c1578e5cdd5143b10b7f4e241cc4`, then apply
`validation/performance/grouped-projection-candidate-20261110.patch` from this
PR. The patch reproduces the runtime and both changed test files at candidate
`43f2b7c`; exact file hashes and the patch digest are recorded in
`validation/performance/grouped-projection-decision-20261110.json`.
Do not apply it to an active measurement tree. A later adoption requires a
fresh, frozen confirmation and complete compatibility checks; retained
negative samples must remain visible.

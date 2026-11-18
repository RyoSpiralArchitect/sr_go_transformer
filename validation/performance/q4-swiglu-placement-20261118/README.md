# Running SwiGLU on the Up workers

The [Up writeback experiment](../q4-up-writeback-20261118/) found
little elapsed difference from removing the Up stores. This screen
keeps the full Up output and measures moving the activation pass.

**Owner** and **worker** run the same Gate and Up Q4 projection
functions with the same two dispatches, joins, range boundaries,
wide-sum check and buffers. Both write every Up value. The owner
applies SwiGLU over the full result after the Up join. The worker
applies exactly the same function to the two row slices it just
wrote before the Up join. With one worker, both call the same
activation over both contiguous rows on the caller. **Native** is
the existing full path, with no placement probe. The difference
against native is an additional check; worker versus owner is
the matched comparison for moving the activation.

Down is timed in independent phases. All labels call the same
Down projection on one immutable slice of reference activations,
with no Gate/Up calculation inside those timed phases. The Down
ratios serve as controls and should not be added to the Gate/Up
results to predict a model speedup.

## Results on Apple M4

The fixtures have two rows and synthetic packed Q4 weights. The
FFN dimensions are 3,072 × 8,192 and 4,096 × 11,008. Both blocks
test one and four workers with GOMAXPROCS=4, reverse case and phase
orders, and span ten balanced rounds of 24 calls per arm. Control
labels repeat the owner and worker paths. An arm precedes each
other arm equally often.

Values below are median elapsed ratios within each block and case,
with a win count out of ten. Ratios below one favor the worker path.

| Workers | FFN shape | Block | Worker / owner | Worker / native |
| ---: | --- | ---: | ---: | ---: |
| 1 | 3,072 × 8,192 | 1 | 1.0190 (4/10) | 0.9983 (6/10) |
| 1 | 3,072 × 8,192 | 2 | 0.9990 (6/10) | 0.9988 (6/10) |
| 1 | 4,096 × 11,008 | 1 | 0.9908 (6/10) | 1.0037 (2/10) |
| 1 | 4,096 × 11,008 | 2 | 0.9657 (7/10) | 0.9951 (7/10) |
| 4 | 3,072 × 8,192 | 1 | 0.9792 (7/10) | 0.9567 (8/10) |
| 4 | 3,072 × 8,192 | 2 | 0.9860 (10/10) | 0.9799 (10/10) |
| 4 | 4,096 × 11,008 | 1 | 0.9946 (7/10) | 0.9888 (8/10) |
| 4 | 4,096 × 11,008 | 2 | 0.9893 (9/10) | 0.9902 (10/10) |

At four workers the matched comparison is shorter in all four
medians (0.54–2.08%) and in 33 of 40 pairs. Both shapes agree
on the direction. The first large-shape block misses the 1%
bound, and the second large-shape block is narrowly outside that
bound against native. The ordinary path does not show a repeatable
one-worker penalty; the one-worker matched comparison itself
misses its negative-control envelope in block two of the larger
shape, despite both arms running on the caller.

The Gate/Up same-path controls pass in all blocks. In Down, seven
of eight phases pass. For the first four-worker phase on the
smaller shape, the ten same-path label-pair medians range from
0.904 to 1.111, with a maximum median absolute deviation from
one of 14.4%. The projected values and kernel were the same.
This is a failed stability control, not a Down regression or gain.

**Decision: hold for model confirmation.** The measured direction at
four workers warrants following up, but the frozen protocol does not
advance this candidate. It requires both blocks in both shapes to
pass, including the inline and Down controls. No real checkpoint was
loaded and no runtime default or workspace capacity was changed.

Both paths reproduced Up, the activated Gate values and Down output
bit for bit. The race tests include reused and poisoned outputs,
partial ranges, an extreme-input fallback, no retained job and one
visit to each output tile per dispatch. The timing executable was
rebuilt byte for byte. The run identity records the pinned source
and executable as well as the exactness and disassembly hashes.

## Reproduce

Use Apple M4, the pinned Go version and a populated module cache.
The experiment builds the recorded baseline separately. Neither
model weights nor a change to the runtime are needed.

```sh
record=validation/performance/q4-swiglu-placement-20261118
mkdir -p runs
sh "$record/run.sh" runs/swiglu-reproduce
python3 -S "$record/assess.py" runs/swiglu-reproduce
```

The same assessor accepts this record directory to recompute the
published numbers from the [first block](block-0.jsonl) and
[second block](block-1.jsonl). See the [protocol](protocol.json),
[assessment](assessment.json) and [run identity](receipt.json).

# Separating the Gate/Up join from input reuse

This trial follows the [fused tile screen](../q4-gate-up-tile-20261118/).
It keeps the Q4 output matrices and SwiGLU writeback the same in all arms
and keeps Down out of the Gate/Up timing. There is no production change.

## What changed between arms

- **Reference and control:** The current two-row Q4 path, called separately
  for Gate and Up.
- **Packed:** A worker runs those same two projections for its range with
  one dispatch and one join. Both matrices still use the original inner
  loop. This also changes which portions of each matrix run close together.
- **Split and shared:** The same inner loop now computes the Gate and Up
  channels for one output index together. Split reads the two rows again
  for Up; shared reuses them. Both receive the same pointers. The compiled
  64-column block loads **256 vs. 128** activation values and does **256**
  fused multiply-adds in both forms.
- **Waiting control:** A separate test makes the same eight submissions at
  four workers and changes only whether it drains completions between
  Gate and Up. The ranges and calculations are unchanged; the queue may
  assign a range to a different worker or overlap the two waves. One
  worker follows an identical inline path in all labels.

Each Down label runs the same kernel with the **same frozen bytes and
slice**, prepared once from the reference. There is no candidate
projection in the Down interval. Gate/Up and Down run in separate phases;
their timings are not summed to estimate end-to-end speed.

## Measured differences

Two blocks reversed mode, worker-count and stage order. Each row below
compares elapsed time within ten rounds of twenty calls, with matched
rounds by worker count. The fixture used the Llama 3.2 3B FFN dimensions
(3,072 input, 8,192 hidden), two activation rows, synthesized packed
weights and Go 1.27.1 on Apple M4. Ratios below 1 are shorter.

| Workers | Block | Same kernel / reference | Packed / reference | Split / packed | Shared / split | Shared / reference |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 1 | 0.993 | 0.993 | 1.233 | 0.795 | 0.970 |
| 1 | 2 | 1.002 | 1.000 | 1.254 | 0.798 | 1.001 |
| 4 | 1 | 1.027 | 1.020 | 1.226 | 0.842 | 1.002 |
| 4 | 2 | 1.006 | 0.986 | 1.246 | 0.828 | 0.988 |

Shared won **20/20** pairs per worker count against split. It removed
15.8–20.5% of elapsed time in that matched loop. It did not consistently
beat the current kernel: the existing code already shares activation
loads across two outputs of *one* matrix, with the same 128 loads
and 256 FMAs in its complete paired block. The new shared loop uses that
reuse across Gate and Up instead. The comparisons do not establish
additional load savings over the production kernel.

In the waiting-only test, four-worker ratios were **0.983** and **0.963**
(one join / two), with four wins out of six in each block. The identical
two-join control's median absolute deviations from one were **6.48%**
and **5.09%**, outside the 4% bound. The one-worker ratios were 1.003
and 0.996, inside the frozen same-path bounds.

Down's identical labels stayed stable with one worker. With four, the
largest median absolute deviation from one across label pairs was
6.53% in the first block and 4.49% in the second. Since the projected
input and code were identical even there, these are timing variation,
not a measured Down speedup.

**Decision: do not advance either candidate.** The load reuse effect
held inside its matched loop. Neither packed scheduling nor reuse
showed a reproducible net improvement over the current runtime under
the frozen controls. The race tests passed for bit equality of Up,
SwiGLU and Down, disjoint and partial output tiles, cleared job state,
and the reduction from eight to four worker callbacks in the packed
case. All first samples are retained. There was no real-checkpoint
timing, workspace measurement or runtime adoption in this turn.

For a next trial, keep the existing per-matrix block and try consuming
Up within each worker's output range. A matched arm can do the same
computation with the same task partition while still writing the
whole Up buffer. That isolates output storage and activation work
without giving up the current block's reuse. Before removing the
buffer in the runtime, also check the long-context attention path
that borrows it and compare fresh Down controls.

## Reproduce

Use a checkout containing the frozen baseline in its Git history,
Go 1.27.1 on Apple M4, and a populated Go module cache. The drivers
stage an isolated, unchanged runtime. Use new output directories.

```sh
record=validation/performance/q4-gate-up-ablation-20261118
mkdir -p runs
sh "$record/run.sh" runs/gate-up-reproduce
python3 -S "$record/assess.py" runs/gate-up-reproduce
sh "$record/waves.sh" runs/gate-up-reproduce runs/waves-reproduce
python3 -S "$record/assess.py" --waves runs/waves-reproduce
```

To reassess the archived samples, use `assess.py --timings-only` or
`assess.py --waves` with this record directory.
[Frozen protocol](protocol.json) · [Gate/Up and Down assessment](assessment.json) ·
[Waiting protocol](barrier-protocol.json) · [Waiting assessment](barrier-assessment.json) ·
[Source and run identity](receipt.json)

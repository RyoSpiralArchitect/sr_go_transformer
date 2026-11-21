# Fused Gate/Up tiles for two-row Q4

A worker computes the corresponding Gate and Up channels from the
same pair of activation rows. It uses the existing 64-column
two-output block to load the activations once for both matrices.
Each output retains the four accumulators and scale order. The
worker applies SwiGLU before writing its tile and joins once before
Down. The candidate has no full Up write; the Down kernel is unchanged.

This is separate from the earlier
[grouped projection](../../../docs/grouped-projection-experiment.md)
trial, which grouped dispatch while still executing each matrix on
its own. The new experiment is only a synthetic fixture. It does
not alter the runtime or measure live model memory.

## Results

The fixture reproduces the 3,072 input and 8,192 hidden dimensions
of Llama 3.2 3B with two rows. Each of the six orders per worker count
has a reference, the same implementation again as a control, and
the candidate. Each arm runs 16 calls. Exactness passed under the
race detector, including the fused intermediate, Down, odd tails
and reused buffers.

| Workers | Stage | Control / reference | Fused / reference | Fused wins |
| ---: | --- | ---: | ---: | ---: |
| 4 | Gate/Up + SwiGLU | 0.985 | 0.974 | 6 / 6 |
| 4 | Down | 0.963 | 0.968 | 4 / 6 |
| 4 | Combined FFN | 0.984 | 0.978 | 5 / 6 |
| 1 | Gate/Up + SwiGLU | 0.999 | 1.014 | 0 / 6 |
| 1 | Down | 1.000 | 0.999 | 4 / 6 |
| 1 | Combined FFN | 0.999 | 1.009 | 1 / 6 |

Ratios are medians of within-round elapsed ratios. At four workers,
the unchanged Down control fell outside the frozen noise bounds:
0.963 median and 5.66% median absolute deviation from one. At one
worker, control was stable and the new Gate/Up was slower. These
results do not qualify the candidate for a model run.

The four-worker fixture still suggests a possible benefit from
removing the second join or Up writes. A follow-up can separate
these mechanisms: compare a worker that processes both matrices
per tile with the reuse kernel, and test Down reusing the same
frozen activation under both orderings. For a production version,
the Up scratch also backs shared KV attention. Excluding it from
the workspace requires proving that attention still fits in the
remaining scratch and that accounting and fallbacks stay correct.
On the tested shape, the potential two-row Up payload is 64 KiB;
no workspace reduction was measured in this fixture.

## Reproduction

Use Apple M4 and Go 1.27.1, with modules already cached. No
checkpoint is required. The runner stages the exact baseline and
isolates the experiment from production.

```sh
record=validation/performance/q4-gate-up-tile-20261118
mkdir -p runs
sh "$record/run.sh" runs/q4-gate-up-reproduce
python3 -S "$record/assess.py" runs/q4-gate-up-reproduce/samples.jsonl
```

[Protocol](protocol.json) · [Raw samples](samples.jsonl) ·
[Assessment](assessment.json) · [Run identity](receipt.json)

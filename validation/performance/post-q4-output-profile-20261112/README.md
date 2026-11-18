# Decode profile after the two-row Q4 output-pair change

The probe measured the reviewed runtime from PR #83 before its merge.
The merge commit `77fdf336d0739e87802e741393453eeaa8331912` has an
identical source tree. The run used the pinned Llama 3.2 3B Q4-mixed
checkpoint on Apple M4 with two FP16 KV sessions and four workers.

| Prefix per session | Timers off | Timers on | Layer projections | Attention | Q8 output head |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 128 | 210.33 | 205.98 | 155.37 | 10.10 | 37.14 |
| 1,024 | 227.16 | 238.73 | 163.77 | 30.50 | 40.87 |

Times are medians in milliseconds per batched decode call, with
four replay averages per timer mode. The timer-on/off ratios were
0.979 and 1.051. The 1,024-token result is slightly outside the
5% timing guard used by the earlier stage study. Treat its wall
breakdown as approximate. The profile rows report cumulative CPU
samples from separate seven-call replays.

The prompt IDs, generated IDs, logit and stored-KV digests, KV payload
and workspace capacities agree with the preceding
[two-session FP16 run](../batched-shared-kv-20261111/f16-s2-1024.json)
at both prefixes. All 16 stage replays also matched their checkpoints.
The CPU profiles sampled the new two-row Q4 kernel at both lengths.

The layer projections remain the largest combined stage. The Q8
output head accounts for about 17–18% of timed decode in both cases
and is a distinct next target. The 3,072-by-128,256 tied projection
reads a Q8 weight payload of 394,002,432 bytes plus block scales.
The recorded arm64 `dotQ8PairBlock64` has 64 signed integer-to-float
conversions and 128 fused multiply-add instructions. The next
comparison can isolate conversion cost from activation reuse across
two outputs, with one-session decode as a control.

Reproduce with Go 1.27.1, the local pinned model snapshot, and an
unused output directory. Populate the Go module cache before the
offline build.

```sh
GOENV=off GOWORK=off GOFLAGS= GOTOOLCHAIN=local go mod download
python3 -S scripts/measure_context_sweep.py \
  --model "$MODEL_SNAPSHOT" --formats f16 --sessions 2 --max-prefix 1024 \
  --stage-timing --output-dir runs/q4-post-merge/sweep
go tool objdump -s '\.dotQ8PairBlock64$' runs/q4-post-merge/sweep/build/probe.test
```

[Protocol](protocol.json) · [Stage receipt](f16-s2-1024.json) ·
[128-token profile](decode-128-profile.txt) · [1,024-token profile](decode-1024-profile.txt)

# FP16 widening measurements

`protocol.json` describes the 100-iteration first comparison. The 80-iteration
confirmation supplies the table in the [context sweep guide](../../../docs/CONTEXT_SWEEP.md).
`confirmation.json` retains the pair order, raw benchmark output and hashes.

Run from the candidate checkout at `7993175`, or a descendant with matching
source hashes, with the recorded Go toolchain on `PATH` and dependencies cached.

```sh
export GOENV=off GOWORK=off GOFLAGS= GOTOOLCHAIN=local GOMAXPROCS=4
export CGO_ENABLED=0 GOEXPERIMENT= GOPROXY=off GOSUMDB=off
unset GOGC GODEBUG GOMEMLIMIT
go version
python3 -S - <<'PY'
from pathlib import Path
import json
import re
import subprocess
import tempfile

receipt = json.loads(Path('validation/performance/fp16-widening-20261111/confirmation.json').read_text())
runtime = Path('cmd/monolith/monolith.go').resolve()
with tempfile.TemporaryDirectory(prefix='sr-go-fp16-') as directory:
    out = Path(directory)
    reference = out / 'reference.go'
    reference.write_bytes(subprocess.check_output([
        'git', 'show', receipt['baseline_commit'] + ':cmd/monolith/monolith.go',
    ]))
    overlay = out / 'overlay.json'
    overlay.write_text(json.dumps({'Replace': {str(runtime): str(reference)}}))
    for variant in ('reference', 'candidate'):
        binary = out / (variant + '.test')
        args = ['go', 'test', '-c', '-trimpath', '-o', str(binary)]
        if variant == 'reference':
            args += ['-overlay', str(overlay)]
        subprocess.run([*args, './cmd/monolith'], check=True)
        asm = subprocess.check_output([
            'go', 'tool', 'objdump', '-s',
            r'\.(attendF16|attendSharedKV\[go.shape.uint16.*)\b', str(binary),
        ], text=True)
        assert asm.count('TEXT ') == 3
        calls = sum(bool(re.search(r'CALL.*(?:halfFloat|fromF16|attentionKVValue)', line))
                    for line in asm.splitlines())
        print(variant, 'static converter calls', calls, flush=True)

    for mode, *order in receipt['schedule']:
        fmt = 'f32' if mode == 'control' else '(f32|f16)'
        pattern = ('^(BenchmarkSharedKVAttention|BenchmarkSharedKVFourHeads)$/'
                   f'^{fmt}$/^(prefix1024|prefix4096)$/^(reference|shared)-')
        for variant in order:
            print(mode, variant, flush=True)
            subprocess.run([str(out / (variant + '.test')), '-test.run=^$',
                            '-test.bench=' + pattern, '-test.benchtime=80x'], check=True)
PY
```

For each process and benchmark case, take the median of its two samples.
For each comparison pair, divide the candidate median by the reference median.
For each control pair, divide the second median by the first. Summarize each
case with the median of its four ratios. The FP32-only controls characterize
host variation under that shorter sequence of benchmarks.

"""Derive a two-phase four-output experiment from the direct LUT microprobe."""
from pathlib import Path
import sys

src, out = map(Path,sys.argv[1:])
s = src.read_text()

def function(name):
    start = s.index('func '+name+'(')
    end = s.index('\n}\n',start)+3
    return s[start:end]

dot = ['func dotQ4OutputQuadSplit64(x *[64]float32, w0, w1, w2, w3 *[32]byte) (float32, float32, float32, float32) {']
for phase, (lo, hi) in enumerate(('ab','cd')):
    dot.append('var '+', '.join(f'{lane}{i}' for i in range(4) for lane in (lo,hi))+' float32')
    for byte in range(phase,32,2):
        dot += ['{',f'x0, x1 := x[{2*byte}], x[{2*byte+1}]']
        for i in range(4):
            dot += [f'p{i} := &q4Pairs[w{i}[{byte}]]',
                    f'{lo}{i} += x0 * p{i}[0]', f'{hi}{i} += x1 * p{i}[1]']
        dot.append('}')
    if phase == 0:
        dot += [f'ab{i} := a{i} + b{i}' for i in range(4)]
dot += ['return '+', '.join(f'ab{i} + (c{i} + d{i})' for i in range(4)),'}']
matrix = function('linearQ4OutputQuadDirectRange').replace('QuadDirect','QuadSplit')
test = function('TestQ4DirectLUTExact').replace('TestQ4DirectLUTExact','TestQ4SplitExact').replace(
    'linearQ4OutputPairDirectRange, linearQ4OutputQuadDirectRange','linearQ4OutputQuadSplitRange')
bench = function('BenchmarkQ4DirectLUT').replace('BenchmarkQ4DirectLUT','BenchmarkQ4Split').replace(
    '{"quad", linearQ4OutputQuadRange}', '{"quadSplit", linearQ4OutputQuadSplitRange}')
out.write_text(s[:s.index('func BenchmarkQ4DirectLUT')]+'\n'+'\n'.join(dot)+'\n'+matrix+test+bench)

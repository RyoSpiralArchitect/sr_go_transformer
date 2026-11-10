"""Generate test-only direct LUT candidates and the four-way comparison."""
from pathlib import Path
import sys

runtime, archived, output = map(Path, sys.argv[1:])
base, old = runtime.read_text(), archived.read_text()

def kernel(width):
    label = "Pair" if width == 2 else "Quad"
    args = ", ".join(f"w{i}" for i in range(width))
    returns = ", ".join(["float32"] * width)
    lines = [f"func dotQ4Output{label}Direct64(x *[64]float32, {args} *[32]byte) ({returns}) {{"]
    for i in range(width):
        lines.append(f"var a{i}, b{i}, c{i}, d{i} float32")
    for byte in range(32):
        lo, hi = "ab" if byte % 2 == 0 else "cd"
        lines += ["{", f"x0, x1 := x[{2*byte}], x[{2*byte+1}]"]
        for i in range(width):
            lines.append(f"p{i} := &q4Pairs[w{i}[{byte}]]")
            lines.append(f"{lo}{i} += x0 * p{i}[0]")
            lines.append(f"{hi}{i} += x1 * p{i}[1]")
        lines.append("}")
    sums = [f"(a{i} + b{i}) + (c{i} + d{i})" for i in range(width)]
    lines += ["return " + ", ".join(sums), "}"]
    return "\n".join(lines)

def direct_range(source, label):
    begin = source.index(f"func linearQ4Output{label}Range(")
    end = source.index("\n}\n", begin) + 2
    return (source[begin:end]
            .replace(f"linearQ4Output{label}Range", f"linearQ4Output{label}DirectRange")
            .replace(f"dotQ4Output{label}64", f"dotQ4Output{label}Direct64"))

# Keep the archived dot and matrix driver as a separately measured control.
source = old[:old.index("func TestQ4OutputQuadExact")]
source += "\n".join([kernel(2), kernel(4), direct_range(base, "Pair"), direct_range(old, "Quad")])
test = old[old.index("func TestQ4OutputQuadExact"):old.index("func BenchmarkQ4OutputQuad")]
test = test.replace("TestQ4OutputQuadExact", "TestQ4DirectLUTExact")
test = test.replace(
    "e.parallel(tiles, in*out, func(lo, hi int) { linearQ4OutputQuadRange(&job, lo, hi) })\n"
    "\t\t\te.close()\n"
    "\t\t\texactWorkerFloats(t, job.y, want)",
    """for _, run := range []func(*fp32Kernel, int, int){linearQ4OutputPairDirectRange, linearQ4OutputQuadDirectRange} {
                for i := range job.y { job.y[i] = 9876 }
                e.parallel(tiles, in*out, func(lo, hi int) { run(&job, lo, hi) })
                exactWorkerFloats(t, job.y, want)
            }
            e.close()""")
source += "\n" + test + '''
func BenchmarkQ4DirectLUT(b *testing.B) {
    variants := []struct{
        name string
        run func(*fp32Kernel, int, int)
    }{
        {"pair", linearQ4OutputPairRange},
        {"quad", linearQ4OutputQuadRange},
        {"pairDirect", linearQ4OutputPairDirectRange},
        {"quadDirect", linearQ4OutputQuadDirectRange},
    }
    // Four samples per variant, every variant balanced around the midpoint.
    order := []int{0,1,2,3,3,2,1,0, 2,0,3,1,1,3,0,2}
    for _, shape := range [][2]int{{4096,1024},{4096,4096},{4096,14336},{14336,4096}} {
        in,out := shape[0],shape[1]
        x,p,_ := linearFixture(1,in,out)
        w := quantizeQ4TestParam(b,p)
        job := fp32Kernel{x:x,y:make([]float32,out),w:w,n:1}
        for _, workers := range []int{1,4} {
            e := newKernelExecutor(workers)
            tiles := (out+31)/32
            for sample,index := range order {
                v := variants[index]
                fn := func(lo,hi int){v.run(&job,lo,hi)}
                b.Run(fmt.Sprintf("in%d/out%d/w%d/sample%d/%s",in,out,workers,sample,v.name),func(b *testing.B) {
                    b.ReportAllocs()
                    for i:=0;i<b.N;i++ {e.parallel(tiles,in*out,fn)}
                })
            }
            e.close()
        }
    }
}
'''
output.write_text(source)

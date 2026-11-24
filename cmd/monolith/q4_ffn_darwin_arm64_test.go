//go:build !purego

package main

import (
	"fmt"
	"testing"
)

const testQ4NativeEnv = "MONOLITH_Q4_FFN_NEON"

var testQ4NativeDot = dotQ4FFNPairNEON
var testQ4NativeQuadDot = dotQ4FFNQuadNEON

func testQ4NativeAvailable() bool { return true }

func BenchmarkQ4FFNQuadNEON(b *testing.B) {
	previous := q4NativeQuadDot
	q4NativeQuadDot = dotQ4FFNQuadNEON
	b.Cleanup(func() { q4NativeQuadDot = previous })
	for _, shape := range []struct {
		name      string
		cols, out int
	}{{"GateUp", 3072, 8192}, {"Down", 8192, 3072}} {
		w := newInferenceParamFormat("ffn", shape.out, shape.cols, true, "q4")
		for i := range w.Q4.Values {
			w.Q4.Values[i] = byte(i*37 + i/31)
		}
		for i := range w.Q4.Scales {
			w.Q4.Scales[i] = float32(1+i%13) / 127
		}
		x, y := make([]float32, shape.cols), make([]float32, shape.out)
		for i := range x {
			x[i] = float32(i%37-18) / 19
		}
		for _, workers := range []int{1, 4} {
			for _, mode := range []string{"Go", "NEON"} {
				b.Run(fmt.Sprintf("%s/workers%d/%s", shape.name, workers, mode), func(b *testing.B) {
					e := newKernelExecutor(workers)
					defer e.close()
					w.q4Native = mode == "NEON"
					linearQ4Into(e, y, x, w, 1)
					b.ReportAllocs()
					b.ResetTimer()
					for i := 0; i < b.N; i++ {
						linearQ4Into(e, y, x, w, 1)
					}
					b.StopTimer()
				})
			}
		}
	}
}

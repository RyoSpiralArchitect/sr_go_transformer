//go:build !purego

package main

import (
	"fmt"
	"math"
	"os"
	"sync/atomic"
	"testing"
)

const testQ4NativeEnv = "MONOLITH_Q4_FFN_NEON"

var testQ4NativeDot = dotQ4FFNPairNEON

func testQ4NativeAvailable() bool { return true }

func TestQ4FFNQuadNEONCodes(t *testing.T) {
	var x [64]float32
	var packed [128]byte
	scales := []float32{1, 1, 1, 1}
	for code := 0; code < 256; code++ {
		for i := range packed {
			packed[i] = byte(code + 37*i)
		}
		for col := range x {
			x[col] = -1.25
			a, b, c, d := dotQ4FFNQuadNEON(x[:], packed[:], scales)
			p, q, r, s := dotQ4OutputQuadDirect64(&x, (*[32]byte)(packed[:32]), (*[32]byte)(packed[32:64]),
				(*[32]byte)(packed[64:96]), (*[32]byte)(packed[96:]))
			exactWorkerFloats(t, []float32{a, b, c, d}, []float32{p, q, r, s})
			x[col] = 0
		}
	}
}

func TestQ4FFNQuadNEONProjection(t *testing.T) {
	if (q4FFNQuadDot != nil) != (os.Getenv(testQ4NativeEnv) == "1") {
		t.Fatal("unexpected single-row NEON registration")
	}
	previous := q4FFNQuadDot
	var calls atomic.Int64
	q4FFNQuadDot = func(x []float32, packed []byte, scales []float32) (float32, float32, float32, float32) {
		calls.Add(1)
		return dotQ4FFNQuadNEON(x, packed, scales)
	}
	t.Cleanup(func() { q4FFNQuadDot = previous })

	for _, tc := range []struct {
		rows, cols, out int
		wide            bool
	}{
		{1, 64, 1, false}, {1, 64, 3, false}, {1, 64, 4, false},
		{1, 192, 31, false}, {1, 256, 32, false}, {1, 2048, 65, false},
		{1, 129, 33, false}, {1, 192, 5, true}, {3, 128, 5, false},
	} {
		x, dense, _ := linearFixture(tc.rows, tc.cols, tc.out)
		x[0], x[1] = math.Float32frombits(1<<31), math.SmallestNonzeroFloat32
		if tc.wide {
			x[tc.cols-1] = math.MaxFloat32 / 2
		}
		w := quantizeQ4TestParam(t, dense)
		for _, workers := range []int{1, 4} {
			e := newKernelExecutor(workers)
			want, got := make([]float32, tc.rows*tc.out), make([]float32, tc.rows*tc.out)
			w.q4FFNPair = false
			calls.Store(0)
			linearQ4Into(e, want, x, w, tc.rows)
			if calls.Load() != 0 {
				t.Fatal("unmarked weight used the single-row kernel")
			}
			w.q4FFNPair = true
			linearQ4Into(e, got, x, w, tc.rows)
			exactWorkerFloats(t, got, want)
			expected := 0
			if tc.rows == 1 && tc.cols%64 == 0 && !tc.wide {
				expected = tc.out / 4
			}
			if calls.Load() != int64(expected) {
				t.Fatalf("%+v with %d workers: got %d calls, want %d", tc, workers, calls.Load(), expected)
			}
			if expected > 0 && testing.AllocsPerRun(10, func() { linearQ4Into(e, got, x, w, tc.rows) }) != 0 {
				t.Fatal("single-row projection allocated after warmup")
			}
			e.close()
		}
	}
}

func BenchmarkQ4FFNQuadNEON(b *testing.B) {
	previous := q4FFNQuadDot
	q4FFNQuadDot = dotQ4FFNQuadNEON
	b.Cleanup(func() { q4FFNQuadDot = previous })
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
					w.q4FFNPair = mode == "NEON"
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

//go:build !purego

package main

import (
	"math"
	"os"
	"testing"
)

const testQ4NativeEnv = "MONOLITH_Q4_FFN_AVX2"

var testQ4NativeDot = dotQ4FFNPairAVX2
var testQ4NativeQuadDot = dotQ4QuadAVX2

func testQ4NativeAvailable() bool { return q4HasAVX2() }

func TestQ4FFNExpandedBatchRounding(t *testing.T) {
	mode := os.Getenv(testQ4NativeEnv)
	if !q4HasAVX2() || mode != "all" && mode != "all+attention" {
		t.Skip("exercise the expanded AVX2 startup modes")
	}
	// Quantization produces scales 1 and 1-2^-23. A fused final multiply-add
	// leaves -2^-46; separate block scaling gives exactly +0.
	dense := &Param{Rows: 4, Cols: 128, Data: make([]float32, 4*128)}
	for o := 0; o < dense.Rows; o++ {
		row := dense.Data[o*128 : (o+1)*128]
		row[0], row[1], row[64], row[65] = 1, 7, 1, math.Nextafter32(7, 0)
	}
	w := quantizeQ4TestParam(t, dense)
	w.q4Native = true
	x := make([]float32, 7*128)
	for i := 0; i < 7; i++ {
		x[i*128], x[i*128+64] = -1, 1+0x1p-23
	}
	for n := 1; n <= 7; n++ {
		got := make([]float32, n*w.Rows)
		linearQ4Into(nil, got, x[:n*128], w, n)
		for _, v := range got {
			if math.Float32bits(v) != 0 {
				t.Fatalf("%d input rows: got %08x, want +0", n, math.Float32bits(v))
			}
		}
	}

	for _, dims := range [][2]int{{63, 5}, {64, 4}, {128, 31}, {192, 32}, {193, 33}, {1024, 65}} {
		in, out := dims[0], dims[1]
		inputs, p, _ := linearFixture(7, in, out)
		weight := quantizeQ4TestParam(t, p)
		for _, marked := range []bool{false, true} {
			weight.q4Native = marked
			for _, workers := range []int{1, 4} {
				e := newKernelExecutor(workers)
				want := make([]float32, 7*out)
				for row := 0; row < 7; row++ {
					linearQ4Into(e, want[row*out:(row+1)*out], inputs[row*in:(row+1)*in], weight, 1)
				}
				for rows := 2; rows <= 7; rows++ {
					got := make([]float32, rows*out)
					linearQ4Into(e, got, inputs[:rows*in], weight, rows)
					exactWorkerFloats(t, got, want[:rows*out])
				}
				e.close()
			}
		}
	}
}

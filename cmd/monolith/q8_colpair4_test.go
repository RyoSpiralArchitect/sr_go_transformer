package main

import (
	"math"
	"os"
	"runtime"
	"testing"
	"time"
)

// pairedColsQ8Range pairs two output columns in the Q8 four-row path,
// keeping each output's per-group partial-accumulator reduction order
// (a+b)+(c+d) and scale application identical, bit-exact by construction.
func pairedColsQ8Range(y, x []float32, w *Param, n, lo, hi int) {
	in, out := w.Cols, w.Rows
	groups, tiles := (in+q8Block-1)/q8Block, (out+31)/32
	for task := lo; task < hi; task++ {
		r, o0 := (task/tiles)*4, (task%tiles)*32
		if r+4 > n {
			continue
		}
		o1 := min(o0+32, out)
		x0, x1 := x[r*in:(r+1)*in], x[(r+1)*in:(r+2)*in]
		x2, x3 := x[(r+2)*in:(r+3)*in], x[(r+3)*in:(r+4)*in]
		for o := o0; o+1 < o1; o += 2 {
			wr0, wr1 := w.Q8.Values[o*in:(o+1)*in], w.Q8.Values[(o+1)*in:(o+2)*in]
			sc0, sc1 := w.Q8.Scales[o*groups:(o+1)*groups], w.Q8.Scales[(o+1)*groups:(o+2)*groups]
			var s0, s1, s2, s3, t0, t1, t2, t3 float32
			for g := range sc0 {
				var a0, b0, c0, d0, a1, b1, c1, d1, a2, b2, c2, d2, a3, b3, c3, d3 float32
				var a4, b4, c4, d4, a5, b5, c5, d5, a6, b6, c6, d6, a7, b7, c7, d7 float32
				j, end := g*q8Block, min((g+1)*q8Block, in)
				for ; j+4 <= end; j += 4 {
					u0, u1, u2, u3 := float32(wr0[j]), float32(wr0[j+1]), float32(wr0[j+2]), float32(wr0[j+3])
					w0, w1, w2, w3 := float32(wr1[j]), float32(wr1[j+1]), float32(wr1[j+2]), float32(wr1[j+3])
					x0a, x0b, x0c, x0d := x0[j], x0[j+1], x0[j+2], x0[j+3]
					x1a, x1b, x1c, x1d := x1[j], x1[j+1], x1[j+2], x1[j+3]
					x2a, x2b, x2c, x2d := x2[j], x2[j+1], x2[j+2], x2[j+3]
					x3a, x3b, x3c, x3d := x3[j], x3[j+1], x3[j+2], x3[j+3]
					a0 += x0a * u0
					b0 += x0b * u1
					c0 += x0c * u2
					d0 += x0d * u3
					a1 += x1a * u0
					b1 += x1b * u1
					c1 += x1c * u2
					d1 += x1d * u3
					a2 += x2a * u0
					b2 += x2b * u1
					c2 += x2c * u2
					d2 += x2d * u3
					a3 += x3a * u0
					b3 += x3b * u1
					c3 += x3c * u2
					d3 += x3d * u3
					a4 += x0a * w0
					b4 += x0b * w1
					c4 += x0c * w2
					d4 += x0d * w3
					a5 += x1a * w0
					b5 += x1b * w1
					c5 += x1c * w2
					d5 += x1d * w3
					a6 += x2a * w0
					b6 += x2b * w1
					c6 += x2c * w2
					d6 += x2d * w3
					a7 += x3a * w0
					b7 += x3b * w1
					c7 += x3c * w2
					d7 += x3d * w3
				}
				p0, p1, p2, p3 := (a0+b0)+(c0+d0), (a1+b1)+(c1+d1), (a2+b2)+(c2+d2), (a3+b3)+(c3+d3)
				q0, q1, q2, q3 := (a4+b4)+(c4+d4), (a5+b5)+(c5+d5), (a6+b6)+(c6+d6), (a7+b7)+(c7+d7)
				for ; j < end; j++ {
					u, wv := float32(wr0[j]), float32(wr1[j])
					p0 += x0[j] * u
					p1 += x1[j] * u
					p2 += x2[j] * u
					p3 += x3[j] * u
					q0 += x0[j] * wv
					q1 += x1[j] * wv
					q2 += x2[j] * wv
					q3 += x3[j] * wv
				}
				s0 += p0 * sc0[g]
				s1 += p1 * sc0[g]
				s2 += p2 * sc0[g]
				s3 += p3 * sc0[g]
				t0 += q0 * sc1[g]
				t1 += q1 * sc1[g]
				t2 += q2 * sc1[g]
				t3 += q3 * sc1[g]
			}
			y[r*out+o], y[(r+1)*out+o] = s0, s1
			y[(r+2)*out+o], y[(r+3)*out+o] = s2, s3
			y[r*out+o+1], y[(r+1)*out+o+1] = t0, t1
			y[(r+2)*out+o+1], y[(r+3)*out+o+1] = t2, t3
		}
	}
}

func q8KernelFixture(n, in, out int, seed uint64) ([]float32, *Param) {
	r := &RNG{State: seed}
	w := &Param{Rows: out, Cols: in, Q8: &q8Weights{}}
	w.Q8.Values = make([]int8, out*in)
	w.Q8.Scales = make([]float32, out*((in+q8Block-1)/q8Block))
	for i := range w.Q8.Values {
		w.Q8.Values[i] = int8(int(r.Uint64()%255) - 127)
	}
	for i := range w.Q8.Scales {
		w.Q8.Scales[i] = float32(r.Normal()) * 0.02
	}
	x := make([]float32, n*in)
	for i := range x {
		x[i] = float32(r.Normal())
	}
	return x, w
}

func TestPairedColsQ8ExactAndTiming(t *testing.T) {
	old := runtime.GOMAXPROCS(1)
	defer runtime.GOMAXPROCS(old)
	for _, shape := range [][3]int{{4, 1, 2}, {4, 63, 32}, {8, 65, 34}, {4, 256, 64}, {8, 704, 256}, {4, 64, 33}, {8, 1536, 512}} {
		n, in, out := shape[0], shape[1], shape[2]
		x, w := q8KernelFixture(n, in, out, uint64(n*131+in))
		tasks := ((n + 3) / 4) * ((out + 31) / 32)
		want, got := make([]float32, n*out), make([]float32, n*out)
		// reference: run production on the same tasks but leave odd columns to
		// the reference (the experiment covers only paired columns).
		linearQ8Into(nil, want, x, w, n)
		pairedColsQ8Range(got, x, w, n, 0, tasks)
		// fill odd/unpaired columns via reference for comparison purposes:
		// here we instead compare only the columns the variant writes.
		// For odd tails, copy reference.
		tiles := (out + 31) / 32
		for task := 0; task < tasks; task++ {
			o0 := (task % tiles) * 32
			o1 := min(o0+32, out)
			if (o1-o0)%2 == 1 {
				for row := 0; row < n; row++ {
					got[row*out+o1-1] = want[row*out+o1-1]
				}
			}
		}
		for i := range want {
			if math.Float32bits(want[i]) != math.Float32bits(got[i]) {
				t.Fatalf("shape %v mismatch at %d", shape, i)
			}
		}
		if os.Getenv("MONOLITH_Q8_COLPAIR4_TIMING") == "" || out%2 != 0 {
			continue
		}
		var bestA, bestB float64 = 1e18, 1e18
		for trial := 0; trial < 8; trial++ {
			start := time.Now()
			for i := 0; i < 32; i++ {
				linearQ8Into(nil, want, x, w, n)
			}
			if e := float64(time.Since(start).Nanoseconds()) / 32; e < bestA {
				bestA = e
			}
			start = time.Now()
			for i := 0; i < 32; i++ {
				pairedColsQ8Range(got, x, w, n, 0, tasks)
			}
			if e := float64(time.Since(start).Nanoseconds()) / 32; e < bestB {
				bestB = e
			}
		}
		t.Logf("n%d/in%d/out%d: ratio %.4f", n, in, out, bestB/bestA)
	}
}

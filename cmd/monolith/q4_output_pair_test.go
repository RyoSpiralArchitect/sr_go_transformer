// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0
package main

import (
	"fmt"
	"testing"
)

func TestQ4OutputPairExact(t *testing.T) {
	for _, n := range []int{2, 4, 1} {
		for _, in := range []int{63, 64, 65, 128, 192} {
			for _, out := range []int{1, 2, 31, 32, 33, 65} {
				x, p, _ := linearFixture(n, in, out)
				q := quantizeQ4TestParam(t, p)
				got, want := make([]float32, n*out), make([]float32, n*out)
				tasks := ((n + 3) / 4) * ((out + 31) / 32)
				baselineQ4OutputRange(&fp32Kernel{x: x, y: want, w: q, n: n}, 0, tasks)
				for _, workers := range []int{1, 4} {
					e := newKernelExecutor(workers)
					linearQ4Into(e, got, x, q, n)
					e.close()
					exactWorkerFloats(t, got, want)
				}
			}
		}
	}
}

func BenchmarkQ4OutputPairCandidate(b *testing.B) {
	// Concurrent controls precede the single-row target.
	for _, rows := range []int{2, 4, 1} {
		for _, size := range [][2]int{{4096, 1024}, {4096, 4096}, {4096, 14336}, {14336, 4096}} {
			x, p, _ := linearFixture(rows, size[0], size[1])
			q := quantizeQ4TestParam(b, p)
			y := make([]float32, rows*size[1])
			e := newKernelExecutor(4)
			tasks := ((rows + 3) / 4) * ((size[1] + 31) / 32)
			job := fp32Kernel{x: x, y: y, w: q, n: rows}
			for _, candidate := range []bool{false, true} {
				name := fmt.Sprintf("rows%d/in%d/out%d/candidate%v", rows, size[0], size[1], candidate)
				fn := func(lo, hi int) { baselineQ4OutputRange(&job, lo, hi) }
				if candidate {
					fn = func(lo, hi int) { linearQ4Range(&job, lo, hi) }
				}
				b.Run(name, func(b *testing.B) {
					b.ReportAllocs()
					for i := 0; i < b.N; i++ {
						e.parallel(tasks, rows*size[0]*size[1], fn)
					}
				})
			}
			e.close()
		}
	}
}

func TestQ4OutputPairEveryCodeAndColumn(t *testing.T) {
	var x [64]float32
	var a, b [32]byte
	for code := 0; code < 256; code++ {
		for j := range a {
			a[j], b[j] = byte(code+37*j), byte(255-code+11*j)
		}
		for col := range x {
			x[col] = 1.25
			u, v := dotQ4OutputPair64(&x, &a, &b)
			exactWorkerFloats(t, []float32{u, v}, []float32{dotQ4Block64(&x, &a), dotQ4Block64(&x, &b)})
			x[col] = 0
		}
	}
}

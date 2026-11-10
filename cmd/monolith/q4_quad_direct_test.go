// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0
package main

import "testing"

func TestQ4QuadDirectInferenceExact(t *testing.T) {
	for _, in := range []int{64, 192, 4096} {
		for _, out := range []int{1, 2, 3, 4, 31, 32, 33, 34, 35, 65, 67} {
			x, p, _ := linearFixture(1, in, out)
			w := quantizeQ4TestParam(t, p)
			want := make([]float32, out)
			guarded := make([]float32, out+2)
			guarded[0], guarded[out+1] = 123, 456
			tiles := (out + 31) / 32
			job := fp32Kernel{x: x, y: want, w: w, n: 1}
			linearQ4OutputPairRange(&job, 0, tiles)
			job.y = guarded[1 : out+1]
			e := newKernelExecutor(4)
			for i := range job.y {
				job.y[i] = 9876
			}
			linearQ4Into(e, job.y, job.x, job.w, 1)
			exactWorkerFloats(t, job.y, want)
			assertQ4InvocationCleared(t, e)
			e.close()
			if guarded[0] != 123 || guarded[out+1] != 456 {
				t.Fatal("output overrun")
			}
		}
	}
}

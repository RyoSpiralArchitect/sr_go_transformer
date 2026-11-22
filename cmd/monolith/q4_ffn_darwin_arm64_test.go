//go:build !purego

// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"math"
	"testing"
)

func TestQ4FFNPairNEONCodes(t *testing.T) {
	var x0, x1 [64]float32
	var w0, w1 [32]byte
	scale := []float32{1}
	for packed := 0; packed < 256; packed++ {
		for j := range w0 {
			w0[j], w1[j] = byte(packed+37*j), byte(255-packed+11*j)
		}
		for col := range x0 {
			x0[col], x1[63-col] = 1.25, -0.75
			a, b, c, d := dotQ4FFNPairNEON(x0[:], x1[:], w0[:], w1[:], scale, scale)
			e, f, g, h := dotQ4TwoRowOutputPair64(&x0, &x1, &w0, &w1)
			exactWorkerFloats(t, []float32{a, b, c, d}, []float32{e, f, g, h})
			x0[col], x1[63-col] = 0, 0
		}
	}
}

func TestQ4FFNPairNEONProjection(t *testing.T) {
	c, err := preset("tiny")
	if err != nil {
		t.Fatal(err)
	}
	for _, format := range []string{"q4", "q4-mixed", "q8", "f32"} {
		m := allocateModelStorageFormat(c, nil, format)
		expected := make(map[*Param]bool)
		for _, b := range m.Blocks {
			for _, p := range [...]*Param{b.Gate, b.Up, b.Down} {
				expected[p] = format == "q4" || format == "q4-mixed"
			}
		}
		for _, p := range m.Params {
			if p.q4FFNPair != expected[p] {
				t.Fatalf("%s/%s route = %t", format, p.Name, p.q4FFNPair)
			}
		}
	}
	for _, tc := range []struct {
		rows, cols, out int
		wide            bool
	}{
		{2, 64, 2, false}, {2, 2048, 65, false}, {2, 192, 1, false},
		{2, 129, 7, false}, {1, 128, 3, false}, {3, 128, 5, false},
		{2, 128, 3, true},
	} {
		x, dense, _ := linearFixture(tc.rows, tc.cols, tc.out)
		w := quantizeQ4TestParam(t, dense)
		x[0], x[1] = math.Float32frombits(1<<31), math.SmallestNonzeroFloat32
		if tc.wide {
			x[tc.cols-1] = math.MaxFloat32 / 2
		}
		for _, workers := range []int{1, 4} {
			e := newKernelExecutor(workers)
			got, want := make([]float32, tc.rows*tc.out), make([]float32, tc.rows*tc.out)
			w.q4FFNPair = false
			linearQ4Into(e, want, x, w, tc.rows)
			w.q4FFNPair = true
			linearQ4Into(e, got, x, w, tc.rows)
			exactWorkerFloats(t, got, want)
			if !tc.wide && tc.rows == 2 && tc.cols%64 == 0 {
				if allocs := testing.AllocsPerRun(10, func() { linearQ4Into(e, got, x, w, tc.rows) }); allocs != 0 {
					t.Fatalf("%d workers allocated %.1f times per projection", workers, allocs)
				}
			}
			e.close()
		}
	}
}

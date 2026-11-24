//go:build !purego && ((darwin && arm64) || (linux && amd64))

// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"math"
	"os"
	"sync/atomic"
	"testing"
)

func TestQ4FFNPairNativeCodes(t *testing.T) {
	if !testQ4NativeAvailable() {
		t.Skip("CPU does not support the native kernel")
	}
	var x0, x1 [64]float32
	var w0, w1 [32]byte
	scale := []float32{1}
	for packed := 0; packed < 256; packed++ {
		for j := range w0 {
			w0[j], w1[j] = byte(packed+37*j), byte(255-packed+11*j)
		}
		for col := range x0 {
			x0[col], x1[63-col] = 1.25, -0.75
			a, b, c, d := testQ4NativeDot(x0[:], x1[:], w0[:], w1[:], scale, scale)
			e, f, g, h := dotQ4TwoRowOutputPair64(&x0, &x1, &w0, &w1)
			exactWorkerFloats(t, []float32{a, b, c, d}, []float32{e, f, g, h})
			x0[col], x1[63-col] = 0, 0
		}
	}
}

func TestQ4FFNPairNativeStartup(t *testing.T) {
	mode := os.Getenv(testQ4NativeEnv)
	wantAttention := mode == "all+attention" && testQ4NativeAvailable()
	want := (mode == "1" || mode == "all" || mode == "all+attention") && testQ4NativeAvailable()
	if (q4NativePairDot != nil) != want {
		t.Fatalf("native kernel registration = %t, want %t", q4NativePairDot != nil, want)
	}
	c, err := preset("tiny")
	if err != nil {
		t.Fatal(err)
	}
	b := allocateModelStorageFormat(c, nil, "q4-mixed").Blocks[0]
	if b.Gate.q4Native != want || b.Up.q4Native != want || b.Down.q4Native != want || b.O.q4Native != wantAttention || q4NativeAttention != wantAttention {
		t.Fatal("model projection selection does not match startup policy")
	}
}

func TestQ4AttentionModelWeights(t *testing.T) {
	for _, dir := range []string{"testdata/hf-gpt2/f16", "testdata/hf-llama/untied-f32", "testdata/hf-qwen2/untied-bf16", "testdata/hf-olmo2/f32", "testdata/hf-mistral/f32"} {
		for _, format := range []string{"q4-mixed", "q4", "q8", "f32"} {
			m, _, err := loadHFModelFormat(context.Background(), dir, 32, 4, format)
			if err != nil {
				t.Fatal(err)
			}
			want := make(map[*Param]bool)
			for _, b := range m.Blocks {
				for _, p := range [...]*Param{b.Q, b.K, b.V, b.O} {
					want[p] = q4NativeAttention && p.Q4 != nil
				}
				if m.hf.ModelType != "gpt2" {
					for _, p := range [...]*Param{b.Gate, b.Up, b.Down} {
						want[p] = q4NativePairDot != nil && p.Q4 != nil
					}
				}
			}
			for _, p := range m.Params {
				if p.q4Native != want[p] {
					t.Fatalf("%s/%s/%s native=%t, want %t", dir, format, p.Name, p.q4Native, want[p])
				}
			}
		}
	}
}

func TestQ4FFNPairNativeProjection(t *testing.T) {
	if !testQ4NativeAvailable() {
		t.Skip("CPU does not support the native kernel")
	}
	previous := q4NativePairDot
	var calls atomic.Int64
	q4NativePairDot = func(x0, x1 []float32, w0, w1 []byte, s0, s1 []float32) (float32, float32, float32, float32) {
		calls.Add(1)
		return testQ4NativeDot(x0, x1, w0, w1, s0, s1)
	}
	t.Cleanup(func() { q4NativePairDot = previous })
	c, err := preset("tiny")
	if err != nil {
		t.Fatal(err)
	}
	for _, format := range []string{"q4", "q4-mixed", "q8", "f32"} {
		m := allocateModelStorageFormat(c, nil, format)
		expected := make(map[*Param]bool)
		for _, b := range m.Blocks {
			for _, p := range [...]*Param{b.Q, b.K, b.V, b.O} {
				expected[p] = q4NativeAttention && p.Q4 != nil
			}
			for _, p := range [...]*Param{b.Gate, b.Up, b.Down} {
				expected[p] = format == "q4" || format == "q4-mixed"
			}
		}
		for _, p := range m.Params {
			if p.q4Native != expected[p] {
				t.Fatalf("%s/%s route = %t", format, p.Name, p.q4Native)
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
			calls.Store(0)
			w.q4Native = false
			linearQ4Into(e, want, x, w, tc.rows)
			if calls.Load() != 0 {
				t.Fatal("unmarked weight dispatched to native kernel")
			}
			w.q4Native = true
			linearQ4Into(e, got, x, w, tc.rows)
			exactWorkerFloats(t, got, want)
			wantCalls := 0
			if tc.rows == 2 && tc.cols%64 == 0 && !tc.wide {
				wantCalls = tc.out / 2
			}
			if gotCalls := calls.Load(); gotCalls != int64(wantCalls) {
				t.Fatalf("%+v workers=%d: native output pairs = %d, want %d", tc, workers, gotCalls, wantCalls)
			}
			if !tc.wide && tc.rows == 2 && tc.cols%64 == 0 {
				if allocs := testing.AllocsPerRun(10, func() { linearQ4Into(e, got, x, w, tc.rows) }); allocs != 0 {
					t.Fatalf("%d workers allocated %.1f times per projection", workers, allocs)
				}
			}
			e.close()
		}
	}
}

func TestQ4FFNQuadNativeCodes(t *testing.T) {
	if !testQ4NativeAvailable() {
		t.Skip("CPU does not support the native kernel")
	}
	var x [64]float32
	var packed [128]byte
	scales := []float32{1, 1, 1, 1}
	for code := 0; code < 256; code++ {
		for i := range packed {
			packed[i] = byte(code + 37*i)
		}
		for col := range x {
			x[col] = -1.25
			a, b, c, d := testQ4NativeQuadDot(x[:], packed[:], scales)
			p, q, r, s := dotQ4OutputQuadDirect64(&x, (*[32]byte)(packed[:32]), (*[32]byte)(packed[32:64]),
				(*[32]byte)(packed[64:96]), (*[32]byte)(packed[96:]))
			exactWorkerFloats(t, []float32{a, b, c, d}, []float32{p, q, r, s})
			x[col] = 0
		}
	}
}

func TestQ4FFNQuadNativeProjection(t *testing.T) {
	mode := os.Getenv(testQ4NativeEnv)
	if (q4NativeQuadDot != nil) != (testQ4NativeAvailable() && (mode == "all" || mode == "all+attention")) {
		t.Fatal("unexpected single-row native registration")
	}
	if !testQ4NativeAvailable() {
		t.Skip("CPU does not support the native kernel")
	}
	previous := q4NativeQuadDot
	var calls atomic.Int64
	q4NativeQuadDot = func(x []float32, packed []byte, scales []float32) (float32, float32, float32, float32) {
		calls.Add(1)
		return testQ4NativeQuadDot(x, packed, scales)
	}
	t.Cleanup(func() { q4NativeQuadDot = previous })

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
			w.q4Native = false
			calls.Store(0)
			linearQ4Into(e, want, x, w, tc.rows)
			if calls.Load() != 0 {
				t.Fatal("unmarked weight used the single-row kernel")
			}
			w.q4Native = true
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

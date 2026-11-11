// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"fmt"
	"math"
	"testing"
)

func TestSharedKVAttentionExactAcrossPagesAndLanes(t *testing.T) {
	c := Config{Dim: 3072, Heads: 24, KVHeads: 8, Layers: 2, Context: 97}
	w, cache := attentionLaneFixture(c, 1, c.Context)
	defer cache.Close()
	for index, page := range cache.Pages {
		for i := range page.Data {
			page.Data[i] += float32(index) / 17
		}
	}
	for _, workers := range []int{1, 4, 12} {
		t.Run(fmt.Sprintf("workers%d", workers), func(t *testing.T) {
			e := newKernelExecutor(workers)
			defer e.close()
			for _, length := range []int{1, 3, 4, 5, 31, 32, 33, 63, 64, 65, 97} {
				w.positions[0] = length - 1
				reference := planInferenceAttention(e, c, 1, length)
				w.Scores = make([]float32, reference.lanes*reference.stride)
				w.attend(e, c, 1, 1, reference)
				want := append([]float32(nil), w.A...)
				shared := reference
				shared.sharedKV = true
				shared.lanes = min(shared.lanes, c.KVHeads)
				w.Logits = make([]float32, 2*shared.lanes*shared.stride+1)
				for _, buffer := range [][]float32{w.A, w.Scores, w.Logits} {
					for i := range buffer {
						buffer[i] = float32(math.NaN())
					}
				}
				w.Logits[len(w.Logits)-1] = 123
				w.attend(e, c, 1, 1, shared)
				exactWorkerFloats(t, w.A, want)
				if w.Logits[len(w.Logits)-1] != 123 || w.attention != (attentionKernel{}) {
					t.Fatalf("length %d exceeded scratch or retained a worker job", length)
				}
			}
		})
	}
}

func TestSharedKVAttentionClearsUnselectedLogits(t *testing.T) {
	c := Config{Vocab: 2080, Dim: 384, Hidden: 64, Heads: 3, KVHeads: 1, Layers: 1, Context: 1025, RopeTheta: 10000, NormEps: 1e-5}
	m, err := NewModel(c, 17)
	if err != nil {
		t.Fatal(err)
	}
	e := newKernelExecutor(4)
	defer e.close()
	var w decodeWorkspace
	for _, selected := range []bool{false, true} {
		cache := m.NewCache()
		defer cache.Close()
		cache.Pos = 1023
		cache.ensurePages(cache.Pos)
		logits, err := m.prefillSelected(context.Background(), []*KVCache{cache}, [][]int{{7}}, e, &w, []bool{selected})
		if err != nil {
			t.Fatal(err)
		}
		if cache.Pos != 1024 || len(logits) != c.Vocab {
			t.Fatal("wrong position or logits size after single-row prefill")
		}
		nonzero := false
		for _, logit := range logits {
			if !finite(float64(logit)) {
				t.Fatal("nonfinite logit after sharing scratch")
			}
			nonzero = nonzero || logit != 0
		}
		if nonzero != selected {
			t.Fatalf("selected %t left nonzero logits %t", selected, nonzero)
		}
		assertWorkspaceReferencesCleared(t, &w)
	}
}

func BenchmarkSharedKVAttention(b *testing.B) {
	c := Config{Dim: 3072, Heads: 24, KVHeads: 8, Layers: 1, Context: 4096}
	for _, length := range []int{128, 1024, 4096} {
		b.Run(fmt.Sprintf("prefix%d", length), func(b *testing.B) {
			e := newKernelExecutor(4)
			defer e.close()
			w, cache := attentionLaneFixture(c, 1, length)
			defer cache.Close()
			reference := planInferenceAttention(e, c, 1, length)
			shared := reference
			shared.sharedKV = true
			w.Scores = make([]float32, reference.lanes*reference.stride)
			w.Logits = make([]float32, 2*shared.lanes*shared.stride)
			w.attend(e, c, 0, 1, reference)
			want := append([]float32(nil), w.A...)
			w.attend(e, c, 0, 1, shared)
			exactWorkerFloats(b, w.A, want)
			for _, variant := range []struct {
				name string
				plan inferenceAttentionPlan
			}{
				{"reference-first", reference}, {"shared-second", shared},
				{"shared-first", shared}, {"reference-second", reference},
			} {
				b.Run(variant.name, func(b *testing.B) {
					b.ReportAllocs()
					for i := 0; i < b.N; i++ {
						w.attend(e, c, 0, 1, variant.plan)
					}
				})
			}
		})
	}
}

// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"fmt"
	"math"
	"testing"
)

// Valid-input oracle for the buffer lifetimes in 3c0ab74. Keep the residual
// projection and activated MLP output separate from Q and Gate. Kernel math
// stays shared: this test isolates storage reuse, not kernel approximation.
func unaliasedPrefillReference(m *Model, caches []*KVCache, chunks [][]int, e *kernelExecutor) []float32 {
	c := m.Config
	n, maxPos := 0, 0
	for i, cache := range caches {
		n += len(chunks[i])
		maxPos = max(maxPos, cache.Pos+len(chunks[i]))
		cache.ensurePages(cache.Pos + len(chunks[i]))
	}
	d, kd := c.Dim, c.KVDim()
	alloc := func(width int) []float32 { return make([]float32, n*width) }
	w := decodeWorkspace{X: alloc(d), N: alloc(d), Q: alloc(d), K: alloc(kd), V: alloc(kd), A: alloc(d), G: alloc(c.Hidden), U: alloc(c.Hidden)}
	tmp, hidden := alloc(d), alloc(c.Hidden)
	plan := planInferenceAttention(e, c, n, maxPos)
	w.Scores = make([]float32, plan.lanes*plan.stride)
	r := 0
	for i, cache := range caches {
		for j, token := range chunks[i] {
			w.rowCaches[r], w.positions[r] = cache, cache.Pos+j
			m.Emb.copyRow(w.X[r*d:(r+1)*d], token)
			if m.Position != nil {
				addInPlace(w.X[r*d:(r+1)*d], m.Position.Data[w.positions[r]*d:(w.positions[r]+1)*d])
			}
			r++
		}
		w.lastRows[i] = r - 1
	}
	for l, b := range m.Blocks {
		inferenceNorm(w.N, w.X, b.N1, b.N1B, n, c.NormEps)
		linearIntoWithExecutor(e, w.Q, w.N, b.Q, n)
		linearIntoWithExecutor(e, w.K, w.N, b.K, n)
		linearIntoWithExecutor(e, w.V, w.N, b.V, n)
		addBias(w.Q, b.QB)
		addBias(w.K, b.KB)
		addBias(w.V, b.VB)
		for i, cache := range w.rowCaches[:n] {
			if m.Position == nil {
				m.rope(w.Q[i*d:(i+1)*d], 1, 1, c.Heads, w.positions[i], false)
				m.rope(w.K[i*kd:(i+1)*kd], 1, 1, c.KVHeads, w.positions[i], false)
			}
			k, v := cache.row(l, w.positions[i])
			copy(k, w.K[i*kd:(i+1)*kd])
			copy(v, w.V[i*kd:(i+1)*kd])
		}
		w.attend(e, c, l, n, plan)
		linearIntoWithExecutor(e, tmp, w.A, b.O, n)
		addBias(tmp, b.OB)
		addInPlace(w.X, tmp)
		inferenceNorm(w.N, w.X, b.N2, b.N2B, n, c.NormEps)
		linearIntoWithExecutor(e, w.G, w.N, b.Gate, n)
		if m.Position != nil {
			addBias(w.G, b.GateB)
			for i, v := range w.G {
				x := float64(v)
				hidden[i] = float32(0.5 * x * (1 + math.Tanh(math.Sqrt(2/math.Pi)*(x+0.044715*x*x*x))))
			}
		} else {
			linearIntoWithExecutor(e, w.U, w.N, b.Up, n)
			for i, v := range w.G {
				hidden[i] = float32(float64(v)/(1+math.Exp(-float64(v)))) * w.U[i]
			}
		}
		linearIntoWithExecutor(e, tmp, hidden, b.Down, n)
		addBias(tmp, b.DownB)
		addInPlace(w.X, tmp)
	}
	for i, row := range w.lastRows[:len(caches)] {
		copy(tmp[i*d:(i+1)*d], w.X[row*d:(row+1)*d])
	}
	inferenceNorm(w.N[:len(caches)*d], tmp[:len(caches)*d], m.Final, m.FinalBias, len(caches), c.NormEps)
	head := m.Emb
	if m.output != nil {
		head = m.output
	}
	logits := make([]float32, len(caches)*c.Vocab)
	linearIntoWithExecutor(e, logits, w.N[:len(caches)*d], head, len(caches))
	for i, cache := range caches {
		cache.Pos += len(chunks[i])
	}
	return logits
}

func checkInferenceLiveness(t *testing.T, m *Model, workers int) {
	t.Helper()
	var e *kernelExecutor
	if workers > 0 {
		e = newKernelExecutor(workers)
		defer e.close()
	}
	a, b := make([]*KVCache, 3), make([]*KVCache, 3)
	for i := range a {
		a[i], b[i] = m.NewCache(), m.NewCache()
		defer a[i].Close()
		defer b[i].Close()
	}
	var w decodeWorkspace
	// Dirty, shrinking/growing scratch; mixed session lengths cross KV pages.
	for step, sizes := range [][3]int{{21, 3, 1}, {1, 1, 1}, {17, 31, 7}, {1, 1, 1}} {
		chunks := make([][]int, 3)
		for i, size := range sizes {
			chunks[i] = prefillTokens(size, i+step+1)
			for j := range chunks[i] {
				chunks[i][j] %= m.Config.Vocab
			}
		}
		want := unaliasedPrefillReference(m, b, chunks, e)
		selection := [][]bool{nil, {false, true, false}, {false, false, false}, nil}[step]
		got, err := m.prefillSelected(context.Background(), a, chunks, e, &w, selection)
		if err != nil {
			t.Fatal(err)
		}
		for i := range a {
			if selection != nil && !selection[i] {
				clear(want[i*m.Config.Vocab : (i+1)*m.Config.Vocab])
			}
			if a[i].Pos != b[i].Pos || len(a[i].Pages) != len(b[i].Pages) {
				t.Fatal("cache coverage changed")
			}
			for j, page := range a[i].Pages {
				exactWorkerFloats(t, page.Data, b[i].Pages[j].Data)
			}
		}
		exactWorkerFloats(t, got, want)
		assertWorkspaceReferencesCleared(t, &w)
	}
}

func TestInferenceLivenessDeepModels(t *testing.T) {
	for _, layers := range []int{32, 64} {
		for _, format := range []string{"f32", "q8", "q4", "q4-mixed"} {
			t.Run(fmt.Sprintf("layers%d/%s", layers, format), func(t *testing.T) {
				c := Config{Vocab: 258, Dim: 66, Hidden: 129, Heads: 3, KVHeads: 1, Layers: layers, Context: 128, RopeTheta: 10000, NormEps: 1e-5}
				m, err := NewModel(c, 19)
				if err != nil {
					t.Fatal(err)
				}
				for _, p := range m.Params {
					if p.Rows < 2 || format == "f32" {
						continue
					}
					q := quantizeTestParam(t, p)
					if hfMatrixFormat(format, p.Name) == "q4" {
						q = quantizeQ4TestParam(t, p)
					}
					*p = *q
				}
				for _, workers := range []int{0, 1, 4} {
					t.Run(fmt.Sprintf("workers%d", workers), func(t *testing.T) { checkInferenceLiveness(t, m, workers) })
				}
			})
		}
	}
}

func TestInferenceLivenessHFProfiles(t *testing.T) {
	for _, profile := range []string{"hf-gpt2/legacy-f32", "hf-qwen2/untied-bf16", "hf-llama3/f32", "hf-mistral/bf16"} {
		for _, format := range []string{"f32", "q8", "q4", "q4-mixed"} {
			t.Run(profile+"/"+format, func(t *testing.T) {
				m, _, err := loadHFModelFormat(context.Background(), "testdata/"+profile, 64, 8, format)
				if err != nil {
					t.Fatal(err)
				}
				checkInferenceLiveness(t, m, 4)
			})
		}
	}
}

func TestInferenceLivenessWorkspaceBoundIndependentOfDepth(t *testing.T) {
	var first int64
	for _, layers := range []int{1, 32, 64} {
		c := Config{Vocab: 258, Dim: 64, Hidden: 129, Heads: 4, KVHeads: 2, Layers: layers, Context: 128, RopeTheta: 10000, NormEps: 1e-5}
		m, err := NewModel(c, 5)
		if err != nil {
			t.Fatal(err)
		}
		cache := m.NewCache()
		var w decodeWorkspace
		e := newKernelExecutor(1)
		_, err = m.prefillBorrowed(context.Background(), []*KVCache{cache}, [][]int{prefillTokens(33, 4)}, e, &w)
		e.close()
		cache.Close()
		if err != nil {
			t.Fatal(err)
		}
		// Four Dim arrays, K/V, two Hidden arrays, one logits row and scores.
		want := int64(4 * (33*(4*64+2*32+2*129) + 258 + 64))
		if w.floatBytes() != want || layers > 1 && w.floatBytes() != first {
			t.Fatalf("layers %d: workspace %d, want %d", layers, w.floatBytes(), want)
		}
		first = w.floatBytes()
	}
}

func TestInferenceLivenessPromptPlanMatchesRetainedArrays(t *testing.T) {
	for _, profile := range []string{"native", "hf-gpt2/legacy-f32"} {
		t.Run(profile, func(t *testing.T) {
			m := promptPrefillTestModel(t, "f32")
			if profile != "native" {
				var err error
				m, _, err = loadHFModelFormat(context.Background(), "testdata/"+profile, 64, 8, "f32")
				if err != nil {
					t.Fatal(err)
				}
			}
			cache := m.NewCache()
			defer cache.Close()
			e := newKernelExecutor(4)
			defer e.close()
			ids := prefillTokens(64, 7)
			for i := range ids {
				ids[i] %= m.Config.Vocab
			}
			if _, err := m.PrefillBatch(context.Background(), []*KVCache{cache}, [][]int{ids[:48]}); err != nil {
				t.Fatal(err)
			}
			// Fresh scratch records exactly the final 16-row shape. Prefix KV is
			// already populated, so the score extent matches the planner's 64.
			var w decodeWorkspace
			if _, err := m.prefillBorrowed(context.Background(), []*KVCache{cache}, [][]int{ids[48:]}, e, &w); err != nil {
				t.Fatal(err)
			}
			limit := w.floatBytes()/4 + int64(m.Config.Vocab) // reserved public copy
			if got := generationPromptRows(m, 64, 4, limit); got != 16 {
				t.Fatalf("actual 16-row workspace fits, planner chose %d", got)
			}
			if got := generationPromptRows(m, 64, 4, limit-1); got >= 16 {
				t.Fatalf("planner exceeded the actual retained-array budget: %d", got)
			}
		})
	}
}

// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0
package main

import "math"

// Independent storage reference: widened rounded KV in legacy FP32 pages and attention.
func f16WidenedPrefillReference(m *Model, caches []*KVCache, chunks [][]int, e *kernelExecutor) []float32 {
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
			for j := range k {
				k[j], v[j] = fromF16(toF16(k[j])), fromF16(toF16(v[j]))
			}
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

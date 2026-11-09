// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0
package main

// Standalone opt-in offline screen. Timing is diagnostic, not an adoption gate.
import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"os"
	"runtime"
	"sort"
	"strings"
	"testing"
	"time"
)

type kv16QualityRow struct {
	Document string  `json:"document"`
	Position int     `json:"position"`
	Target   int     `json:"target"`
	KL       float64 `json:"kl"`
	F32NLL   float64 `json:"f32_nll"`
	BF16NLL  float64 `json:"bf16_nll"`
}
type kv16LongResult struct {
	ID             string  `json:"id"`
	Format         string  `json:"format"`
	PromptIDs      []int   `json:"prompt_ids"`
	OutputIDs      []int   `json:"output_ids"`
	Text           string  `json:"text"`
	Seconds        float64 `json:"seconds"`
	KVPayloadBytes int     `json:"kv_payload_bytes"`
}

func kv16Metrics(a, b []float32, target int) (kl, na, nb float64, err error) {
	if len(a) == 0 || len(a) != len(b) || target < 0 || target >= len(a) {
		return 0, 0, 0, fmt.Errorf("invalid metric dimensions")
	}
	ma, mb := math.Inf(-1), math.Inf(-1)
	for i := range a {
		if !finite(float64(a[i])) || !finite(float64(b[i])) {
			return 0, 0, 0, fmt.Errorf("nonfinite logits")
		}
		ma = math.Max(ma, float64(a[i]))
		mb = math.Max(mb, float64(b[i]))
	}
	za, zb := 0., 0.
	for i := range a {
		za += math.Exp(float64(a[i]) - ma)
		zb += math.Exp(float64(b[i]) - mb)
	}
	la, lb := ma+math.Log(za), mb+math.Log(zb)
	for i := range a {
		x, y := float64(a[i])-la, float64(b[i])-lb
		kl += math.Exp(x) * (x - y)
	}
	return kl, la - float64(a[target]), lb - float64(b[target]), nil
}

func TestKV16QualityMetrics(t *testing.T) {
	a, b := []float32{float32(math.Log(.75)), float32(math.Log(.25))}, []float32{0, 0}
	kl, na, nb, err := kv16Metrics(a, b, 0)
	if err != nil || math.Abs(kl-(.75*math.Log(1.5)+.25*math.Log(.5))) > 1e-7 || math.Abs(na+math.Log(.75)) > 1e-7 || math.Abs(nb-math.Log(2)) > 1e-7 {
		t.Fatal(kl, na, nb, err)
	}
	if _, _, _, err := kv16Metrics([]float32{float32(math.NaN())}, []float32{0}, 0); err == nil {
		t.Fatal("nonfinite accepted")
	}
}

func TestHFCache16Quality(t *testing.T) {
	dir := os.Getenv("MONOLITH_KV16_MODEL")
	if dir == "" {
		t.Skip("manual offline BF16 KV screen")
	}
	progress, err := os.OpenFile(os.Getenv("MONOLITH_KV16_OUTPUT")+".progress.jsonl", os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0644)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { progress.Close() })
	phase := "startup"
	record := func(value any) {
		t.Helper()
		if err := json.NewEncoder(progress).Encode(value); err != nil {
			t.Fatal(err)
		}
		if err := progress.Sync(); err != nil {
			t.Fatal(err)
		}
	}
	fail := func(args ...any) {
		t.Helper()
		record(map[string]any{"event": "failure", "phase": phase, "error": fmt.Sprint(args...)})
		t.Fatal(args...)
	}
	record(map[string]any{"event": "start", "phase": phase})
	if runtime.GOMAXPROCS(0) != 4 {
		fail("requires GOMAXPROCS=4")
	}
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
	defer cancel()
	phase = "model_load"
	record(map[string]any{"event": "phase", "phase": phase})
	m, plan, err := loadHFModelFormat(ctx, dir, 1024, 8192, "q4-mixed")
	if err != nil {
		fail(err)
	}
	m16 := kv16ModelView(m, "bf16")
	tok, err := loadHFTokenizer(dir, *m.hf)
	if err != nil {
		fail(err)
	}
	var corpus struct {
		Documents []struct {
			ID   string `json:"id"`
			Text string `json:"text"`
		} `json:"evaluation_documents"`
	}
	raw, err := os.ReadFile(os.Getenv("MONOLITH_KV16_CORPUS"))
	if err != nil {
		fail(err)
	}
	if err = json.Unmarshal(raw, &corpus); err != nil || len(corpus.Documents) != 6 {
		fail("six documents required", err)
	}
	e := newKernelExecutor(4)
	defer e.close()
	var w0, w1 decodeWorkspace
	rows := []kv16QualityRow{}
	for _, doc := range corpus.Documents {
		ids, err := tok.encodePrompt(ctx, doc.Text, 1024)
		if err != nil || len(ids) < 2 {
			fail(doc.ID, err)
		}
		a, b := m.NewCache(), m16.NewCache()
		for i := 0; i < min(48, len(ids)-1); i++ {
			phase = fmt.Sprintf("teacher_force/%s/%d", doc.ID, i)
			record(map[string]any{"event": "phase", "phase": phase})
			var x, y []float32
			forward := func(which int) {
				var er error
				if which == 0 {
					x, er = m.prefillBorrowed(ctx, []*KVCache{a}, [][]int{{ids[i]}}, e, &w0)
				} else {
					y, er = m16.prefillBorrowed(ctx, []*KVCache{b}, [][]int{{ids[i]}}, e, &w1)
				}
				if er != nil {
					fail(er)
				}
			}
			forward(i % 2)
			forward(1 - i%2)
			kl, na, nb, err := kv16Metrics(x, y, ids[i+1])
			if err != nil {
				fail(err)
			}
			row := kv16QualityRow{doc.ID, i, ids[i+1], kl, na, nb}
			rows = append(rows, row)
			record(map[string]any{"event": "quality_row", "row": row})
		}
		a.Close()
		b.Close()
	}
	var prompts struct {
		Questions []struct {
			ID       string `json:"id"`
			Question string `json:"question"`
		} `json:"questions"`
	}
	raw, err = os.ReadFile(os.Getenv("MONOLITH_KV16_PROMPTS"))
	if err != nil {
		fail(err)
	}
	if err = json.Unmarshal(raw, &prompts); err != nil || len(prompts.Questions) != 2 {
		fail("two questions required", err)
	}
	texts := []string{}
	for _, doc := range corpus.Documents {
		texts = append(texts, doc.Text)
	}
	var prefix []int
	for repeat := 1; repeat <= 16; repeat++ {
		prefix, err = tok.encodePrompt(ctx, strings.Repeat(strings.Join(texts, "\n")+"\n", repeat), 1024)
		if err != nil {
			fail(err)
		}
		if len(prefix) >= 384 {
			break
		}
	}
	if len(prefix) < 384 {
		fail("prefix too short")
	}
	prefix = prefix[:384]
	long := []kv16LongResult{}
	for qi, q := range prompts.Questions {
		questionIDs, err := tok.encodeText(ctx, q.Question, 1024, false)
		if err != nil {
			fail(err)
		}
		ids := append(append([]int(nil), prefix...), questionIDs...)
		if len(ids)+128 > 1024 {
			fail("long context overflow")
		}
		for order := 0; order < 2; order++ {
			format := "f32"
			model := m
			w := &w0
			if (order+qi)%2 == 1 {
				format = "bf16"
				model = m16
				w = &w1
			}
			phase = fmt.Sprintf("long/%s/%s/prefill", q.ID, format)
			record(map[string]any{"event": "long_start", "phase": phase, "id": q.ID, "format": format, "prompt_ids": ids})
			cache := model.NewCache()
			var logits []float32
			started := time.Now()
			for lo := 0; lo < len(ids); lo += 16 {
				logits, err = model.prefillBorrowed(ctx, []*KVCache{cache}, [][]int{ids[lo:min(lo+16, len(ids))]}, e, w)
				if err != nil {
					fail(err)
				}
			}
			output := make([]int, 0, 128)
			for step := 0; step < 128; step++ {
				phase = fmt.Sprintf("long/%s/%s/token/%d", q.ID, format, step)
				record(map[string]any{"event": "phase", "phase": phase})
				best := 0
				for j, v := range logits {
					if !finite(float64(v)) {
						fail("nonfinite generation")
					}
					if v > logits[best] {
						best = j
					}
				}
				output = append(output, best)
				record(map[string]any{"event": "token", "id": q.ID, "format": format, "step": step, "token_id": best, "partial_text": tok.Decode(output)})
				if step < 127 {
					logits, err = model.prefillBorrowed(ctx, []*KVCache{cache}, [][]int{{best}}, e, w)
					if err != nil {
						fail(err)
					}
				}
			}
			bytes := 0
			for _, page := range cache.Pages {
				bytes += len(page.Data)*4 + len(page.BF16)*2
			}
			item := kv16LongResult{q.ID, format, ids, output, tok.Decode(output), time.Since(started).Seconds(), bytes}
			long = append(long, item)
			record(map[string]any{"event": "long_complete", "result": item})
			cache.Close()
		}
	}
	phase = "aggregation"
	type docMean struct {
		Rows         int     `json:"rows"`
		MeanKL       float64 `json:"mean_kl"`
		MeanNLLDelta float64 `json:"mean_nll_increase"`
	}
	documents := map[string]docMean{}
	for _, r := range rows {
		d := documents[r.Document]
		d.Rows++
		d.MeanKL += r.KL
		d.MeanNLLDelta += r.BF16NLL - r.F32NLL
		documents[r.Document] = d
	}
	for name, d := range documents {
		d.MeanKL /= float64(d.Rows)
		d.MeanNLLDelta /= float64(d.Rows)
		documents[name] = d
	}
	meanKL, delta := 0., 0.
	ks := make([]float64, len(rows))
	for i, r := range rows {
		meanKL += r.KL
		delta += r.BF16NLL - r.F32NLL
		ks[i] = r.KL
	}
	meanKL /= float64(len(rows))
	delta /= float64(len(rows))
	sort.Float64s(ks)
	p95 := ks[int(math.Ceil(.95*float64(len(ks))))-1]
	gates := map[string]bool{"mean_kl": meanKL <= .001, "p95_kl": p95 <= .005, "mean_nll_increase": delta <= .01}
	result := map[string]any{"format": "monolith-kv16-quality-v1", "plan": plan, "context": 1024, "workers": 4, "rows": rows, "documents": documents, "mean_kl": meanKL, "p95_kl": p95, "mean_nll_increase": delta, "numerical_gates": gates, "long_answers": long, "long_answer_review": "pending", "note": "One immutable weight set. No RSS-halving or timing improvement claim. Fixed-step continuations include EOS."}
	out, err := os.OpenFile(os.Getenv("MONOLITH_KV16_OUTPUT"), os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0644)
	if err != nil {
		fail(err)
	}
	enc := json.NewEncoder(out)
	enc.SetIndent("", "  ")
	err = enc.Encode(result)
	closeErr := out.Close()
	if err != nil || closeErr != nil {
		fail(err, closeErr)
	}
	record(map[string]any{"event": "complete", "numerical_gates": gates})
	// Keep the completed receipt even when gates fail.
	for name, pass := range gates {
		if !pass {
			t.Errorf("numerical gate failed: %s", name)
		}
	}
}

// Share immutable parameters without copying sync.Pool or mutable cache state.
func kv16ModelView(m *Model, format string) *Model {
	return &Model{output: m.output, Config: m.Config, Emb: m.Emb, Final: m.Final, Position: m.Position, FinalBias: m.FinalBias, Blocks: m.Blocks, Params: m.Params, Cos: m.Cos, Sin: m.Sin, Revision: m.Revision, kvFormat: format, directKVBytes: m.directKVBytes, hf: m.hf}
}

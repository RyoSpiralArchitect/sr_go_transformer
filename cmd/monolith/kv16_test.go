// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

func TestF16Conversion(t *testing.T) {
	for b := 0; b < 65536; b++ {
		x := fromF16(uint16(b))
		got := toF16(x)
		if math.IsNaN(float64(x)) {
			if !math.IsNaN(float64(fromF16(got))) {
				t.Fatal("NaN lost", b)
			}
			continue
		}
		if got != uint16(b) {
			t.Fatal("roundtrip", b, got)
		}
	}
	for _, tc := range []struct {
		bits uint32
		want uint16
	}{
		{0x3f800fff, 0x3c00}, {0x3f801000, 0x3c00}, {0x3f801001, 0x3c01},
		{0x3f803000, 0x3c02}, {0xbf801000, 0xbc00}, {0xbf803000, 0xbc02},
		{0x33000000, 0}, {0x33000001, 1}, {0x33800000, 1},
		{0x38800000, 0x0400}, {0x387fe000, 0x0400}, {0x387fdfff, 0x03ff},
		{0x477fe000, 0x7bff}, {0x477fefff, 0x7bff}, {0x477ff000, 0x7c00},
		{0x7f800000, 0x7c00}, {0xff800000, 0xfc00}, {0x80000000, 0x8000},
	} {
		if got := toF16(math.Float32frombits(tc.bits)); got != tc.want {
			t.Fatalf("%x: %x != %x", tc.bits, got, tc.want)
		}
	}
}

func TestKV16ReferenceAndDefault(t *testing.T) {
	for _, profile := range []string{"hf-gpt2/legacy-f32", "hf-qwen2/untied-bf16", "hf-llama3/f32", "hf-mistral/bf16"} {
		for _, weights := range []string{"f32", "q4-mixed"} {
			for _, workers := range []int{1, 4} {
				t.Run(fmt.Sprintf("%s/%s/%d", profile, weights, workers), func(t *testing.T) {
					ctx := context.Background()
					m, _, err := loadHFModelFormat(ctx, "testdata/"+profile, 64, 8, weights)
					if err != nil {
						t.Fatal(err)
					}
					e := newKernelExecutor(workers)
					defer e.close()
					// Exact reference is the original FP32 path with only stored values rounded.
					ref := m.NewCache()
					defer ref.Close()
					m16 := kv16ModelView(m, "f16")
					a := m16.NewCache()
					defer a.Close()
					var w decodeWorkspace
					for step, n := range []int{17, 1, 17, 1, 7} {
						ids := prefillTokens(n, step+1)
						for j := range ids {
							ids[j] %= m.Config.Vocab
						}
						want := f16WidenedPrefillReference(m, []*KVCache{ref}, [][]int{ids}, e)
						got, err := m16.prefillBorrowed(ctx, []*KVCache{a}, [][]int{ids}, e, &w)
						if err != nil {
							t.Fatal(err)
						}
						exactWorkerFloats(t, got, want)
						for i, p := range a.Pages {
							if len(p.Data) != 0 || len(p.F16) != len(ref.Pages[i].Data) {
								t.Fatal("not compact")
							}
							for j, b := range p.F16 {
								if math.Float32bits(fromF16(b)) != math.Float32bits(ref.Pages[i].Data[j]) {
									t.Fatal("KV mismatch", i, j)
								}
							}
						}
					}
					// Explicit f32 and omitted selection preserve all original output bits.
					explicit := kv16ModelView(m, "f32")
					b, c := m.NewCache(), explicit.NewCache()
					defer b.Close()
					defer c.Close()
					ids := prefillTokens(11, 3)
					for j := range ids {
						ids[j] %= m.Config.Vocab
					}
					x, err := m.PrefillBatch(ctx, []*KVCache{b}, [][]int{ids})
					if err != nil {
						t.Fatal(err)
					}
					y, err := explicit.PrefillBatch(ctx, []*KVCache{c}, [][]int{ids})
					if err != nil {
						t.Fatal(err)
					}
					exactWorkerFloats(t, x, y)
					for i := range b.Pages {
						exactWorkerFloats(t, b.Pages[i].Data, c.Pages[i].Data)
					}
				})
			}
		}
	}
}

func TestKV16BudgetAndMalformedStorage(t *testing.T) {
	m := workerTestModel(t, 2)
	m.kvFormat = "f16"
	for _, pos := range []int{1, 31, 32, 33, 128} {
		a, err := planInferenceKV(m.Config, pos, 512<<20)
		if err != nil {
			t.Fatal(err)
		}
		b, err := planInferenceKVFormat(m.Config, pos, a.RequiredBytes/2, "f16")
		if err != nil || !b.FitsBudget || b.RequiredBytes*2 != a.RequiredBytes {
			t.Fatal(a, b, err)
		}
		b, err = planInferenceKVFormat(m.Config, pos, a.RequiredBytes/2-1, "f16")
		if err != nil || b.FitsBudget {
			t.Fatal(b, err)
		}
	}
	for _, kind := range []string{"wrong-format", "short", "both", "pool"} {
		t.Run(kind, func(t *testing.T) {
			c := m.NewCache()
			defer c.Close()
			c.ensurePages(1)
			c.Pos = 1
			switch kind {
			case "wrong-format":
				c.Pages[0] = newKVPage(len(c.Pages[0].F16), "f32")
			case "short":
				c.Pages[0].F16 = c.Pages[0].F16[:1]
			case "both":
				c.Pages[0].Data = []float32{0}
			case "pool":
				c.pool = &pagePool{PageElements: len(c.Pages[0].F16), Limit: 1, Reserved: 1, Allocated: 1}
				c.reserved = 1
			}
			if _, err := m.DecodeBatch(context.Background(), []*KVCache{c}, []int{1}); err == nil {
				t.Fatal("malformed storage accepted")
			}
			if c.Pos != 1 {
				t.Fatal("mutation on reject")
			}
		})
	}
	if _, err := planInferenceKVFormat(m.Config, 1, 512<<20, "fp16"); err == nil {
		t.Fatal("unsupported format")
	}
	dir := kvMistralMetadata(t)
	if _, _, err := loadHFModelKVFormat(context.Background(), dir, 4096, 8192, "q4-mixed", 512<<20, true, "f16"); err == nil || strings.Contains(err.Error(), "KV budget") {
		t.Fatal("compact admission must reach missing shards", err)
	}
	if _, _, err := loadHFModelKVFormat(context.Background(), dir, 4096, 8192, "q4-mixed", 512<<20, true, "f32"); err == nil || !strings.Contains(err.Error(), "KV budget") {
		t.Fatal(err)
	}
}

func TestKV16CLIValidation(t *testing.T) {
	for _, action := range []string{"check-hf", "infer-hf", "generate", "chat", "serve"} {
		args := []string{"-kv-format", "invalid"}
		if action == "infer-hf" {
			args = append(args, "-ids", "1")
		}
		if err := runInferenceAction(context.Background(), action, args, true); err == nil || !strings.Contains(err.Error(), "kv-format") {
			t.Fatal(action, err)
		}
	}
}

func TestKV16LocalCheckAndLoaderRouting(t *testing.T) {
	dir := hfCLIFixture(t)
	t.Setenv("HF_HUB_OFFLINE", "1")
	denyHFNetwork(t)
	out, err := os.CreateTemp(t.TempDir(), "check-")
	if err != nil {
		t.Fatal(err)
	}
	defer out.Close()
	original := os.Stdout
	os.Stdout = out
	defer func() { os.Stdout = original }()
	if err := runInferLocal(context.Background(), []string{"-path", dir, "-context", "64", "check", "-kv-format", "f16", "-json"}); err != nil {
		t.Fatal(err)
	}
	if _, err := out.Seek(0, 0); err != nil {
		t.Fatal(err)
	}
	var report hfCheck
	if err := json.NewDecoder(out).Decode(&report); err != nil {
		t.Fatal(err)
	}
	if report.KVPlan == nil || report.KVPlan.Format != "f16" || report.KVPageAlignedBytes*2 != 64*report.Weights.KVBytesPerToken {
		t.Fatal(report)
	}
	for _, action := range []string{"generate", "chat", "serve"} {
		f := flags(action)
		hfFlags(f)
		kvFormatFlag(f)
		f.Int64("kv-mib", 1, "")
		if err := f.Parse([]string{"-kv-format", "f16"}); err != nil {
			t.Fatal(err)
		}
		m, tok, err := loadInference(context.Background(), f, "", dir, 64, 8, "f32")
		if err != nil {
			t.Fatal(err)
		}
		c := m.NewCache()
		c.ensurePages(1)
		if len(c.Pages[0].Data) != 0 || len(c.Pages[0].F16) == 0 {
			t.Fatal("loader ignored format", action)
		}
		c.Close()
		e, err := newEngine(m, tok, EngineConfig{MaxBatch: 1, Queue: 1, CacheBytes: 1 << 20})
		if err != nil {
			t.Fatal(err)
		}
		if e.pool.Format != "f16" {
			t.Fatal("engine ignored format", action)
		}
		e.cancel()
	}
}

func TestKV16FailedProbeRetainsProgress(t *testing.T) {
	exe, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}
	output := filepath.Join(t.TempDir(), "quality.json")
	command := exec.Command(exe, "-test.run=^TestHFCache16Quality$", "-test.timeout=10s")
	command.Env = append(os.Environ(), "GOMAXPROCS=4", "MONOLITH_KV16_MODEL="+t.TempDir(), "MONOLITH_KV16_OUTPUT="+output)
	if log, err := command.CombinedOutput(); err == nil {
		t.Fatal("missing model unexpectedly passed", string(log))
	}
	raw, err := os.ReadFile(output + ".progress.jsonl")
	if err != nil {
		t.Fatal(err)
	}
	lines := strings.Split(strings.TrimSpace(string(raw)), "\n")
	if len(lines) < 3 {
		t.Fatal("missing durable phase/failure", string(raw))
	}
	var event struct{ Event, Phase, Error string }
	if err := json.Unmarshal([]byte(lines[len(lines)-1]), &event); err != nil {
		t.Fatal(err)
	}
	if event.Event != "failure" || event.Phase != "model_load" || event.Error == "" {
		t.Fatal(event)
	}
	if _, err := os.Stat(output); !os.IsNotExist(err) {
		t.Fatal("failed probe claimed completed report", err)
	}
}

func TestKV16DeepMixedSessions(t *testing.T) {
	for _, layers := range []int{32, 64} {
		t.Run(fmt.Sprintf("layers%d", layers), func(t *testing.T) {
			config := Config{Vocab: 258, Dim: 66, Hidden: 129, Heads: 3, KVHeads: 1, Layers: layers, Context: 128, RopeTheta: 10000, NormEps: 1e-5}
			m, err := NewModel(config, 19)
			if err != nil {
				t.Fatal(err)
			}
			for _, p := range m.Params {
				if p.Rows > 1 {
					q := quantizeQ4TestParam(t, p)
					*p = *q
				}
			}
			compact := kv16ModelView(m, "f16")
			a, b := make([]*KVCache, 3), make([]*KVCache, 3)
			for i := range a {
				a[i], b[i] = compact.NewCache(), m.NewCache()
				defer a[i].Close()
				defer b[i].Close()
			}
			e := newKernelExecutor(4)
			defer e.close()
			var w decodeWorkspace
			for step, sizes := range [][3]int{{21, 3, 1}, {17, 31, 7}, {1, 1, 1}} {
				chunks := make([][]int, 3)
				for i, n := range sizes {
					chunks[i] = prefillTokens(n, i+step+1)
				}
				want := f16WidenedPrefillReference(m, b, chunks, e)
				got, err := compact.prefillBorrowed(context.Background(), a, chunks, e, &w)
				if err != nil {
					t.Fatal(err)
				}
				exactWorkerFloats(t, got, want)
				for i := range a {
					for j, page := range a[i].Pages {
						for k, v := range page.F16 {
							if math.Float32bits(fromF16(v)) != math.Float32bits(b[i].Pages[j].Data[k]) {
								t.Fatal("deep KV mismatch", i, j, k)
							}
						}
					}
				}
			}
			if w.attentionFn == nil {
				t.Fatal("mixed-session attention did not dispatch")
			}
		})
	}
}

func TestF16RangeRejectionIsAtomic(t *testing.T) {
	m := workerTestModel(t, 2)
	m.kvFormat = "f16"
	c := m.NewCache()
	defer c.Close()
	c.ensurePages(1)
	kd := m.Config.KVDim()
	keys, values := make([]float32, kd), make([]float32, kd)
	for _, bits := range []uint32{0x477ff000, 0xc77ff000, 0x7f800000, 0xff800000, 0x7fc00000} {
		for _, badKeys := range []bool{false, true} {
			for i := range c.Pages[0].F16 {
				c.Pages[0].F16[i] = 0x3555
			}
			clear(keys)
			clear(values)
			if badKeys {
				keys[kd-1] = math.Float32frombits(bits)
			} else {
				values[kd-1] = math.Float32frombits(bits)
			}
			if err := c.store(0, 0, keys, values); err == nil || !strings.Contains(err.Error(), "use -kv-format f32") {
				t.Fatal(err)
			}
			for _, v := range c.Pages[0].F16 {
				if v != 0x3555 {
					t.Fatal("partial row write")
				}
			}
		}
	}
	clear(keys)
	clear(values)
	values[0] = 65504
	if err := c.store(0, 0, keys, values); err != nil {
		t.Fatal(err)
	}
	_, v := c.rowF16(0, 0)
	if v[0] != 0x7bff {
		t.Fatal(v[0])
	}
}

func TestF16PrefillOverflowKeepsPositionsAndCanRecover(t *testing.T) {
	m := workerTestModel(t, 2)
	m.kvFormat = "f16"
	a, b := m.NewCache(), m.NewCache()
	defer a.Close()
	defer b.Close()
	if _, err := m.PrefillBatch(context.Background(), []*KVCache{a, b}, [][]int{{1}, {2}}); err != nil {
		t.Fatal(err)
	}
	// A later layer fails after the earlier layer already stored future rows.
	bias := &Param{Rows: 1, Cols: m.Config.KVDim(), Data: make([]float32, m.Config.KVDim())}
	bias.Data[0] = 70000
	m.Blocks[1].VB = bias
	chunks := [][]int{{3, 4}, {5}}
	if _, err := m.PrefillBatch(context.Background(), []*KVCache{a, b}, chunks); err == nil || !strings.Contains(err.Error(), "FP16 KV range") {
		t.Fatal(err)
	}
	if a.Pos != 1 || b.Pos != 1 {
		t.Fatal("failed batch committed", a.Pos, b.Pos)
	}
	// The same finite values remain supported by FP32.
	f32 := kv16ModelView(m, "f32")
	fc := f32.NewCache()
	defer fc.Close()
	logits, err := f32.PrefillBatch(context.Background(), []*KVCache{fc}, [][]int{{1, 3, 4}})
	if err != nil {
		t.Fatal(err)
	}
	for _, x := range logits {
		if math.IsNaN(float64(x)) || math.IsInf(float64(x), 0) {
			t.Fatal("nonfinite FP32 control")
		}
	}
	m.Blocks[1].VB = nil
	got, err := m.PrefillBatch(context.Background(), []*KVCache{a, b}, chunks)
	if err != nil {
		t.Fatal(err)
	}
	x, y := m.NewCache(), m.NewCache()
	defer x.Close()
	defer y.Close()
	if _, err = m.PrefillBatch(context.Background(), []*KVCache{x, y}, [][]int{{1}, {2}}); err != nil {
		t.Fatal(err)
	}
	want, err := m.PrefillBatch(context.Background(), []*KVCache{x, y}, chunks)
	if err != nil {
		t.Fatal(err)
	}
	exactWorkerFloats(t, got, want)
	for i, c := range []*KVCache{a, b} {
		ref := []*KVCache{x, y}[i]
		for j, p := range c.Pages {
			for k, v := range p.F16 {
				if v != ref.Pages[j].F16[k] {
					t.Fatal("recovery KV differs")
				}
			}
		}
	}
}

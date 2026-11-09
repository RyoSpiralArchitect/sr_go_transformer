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

func TestBF16Conversion(t *testing.T) {
	for b := 0; b < 65536; b++ {
		x := fromBF16(uint16(b))
		got := toBF16(x)
		if math.IsNaN(float64(x)) {
			if !math.IsNaN(float64(fromBF16(got))) {
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
		{0x3f807fff, 0x3f80}, {0x3f808000, 0x3f80}, {0x3f808001, 0x3f81},
		{0x3f818000, 0x3f82}, {0xbf808000, 0xbf80}, {0xbf818000, 0xbf82},
		{0x00008000, 0}, {0x00008001, 1}, {0x80000000, 0x8000},
		{0x7f800000, 0x7f80}, {0xff800000, 0xff80},
	} {
		if got := toBF16(math.Float32frombits(tc.bits)); got != tc.want {
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
					m16 := kv16ModelView(m, "bf16")
					a := m16.NewCache()
					defer a.Close()
					var w decodeWorkspace
					for step, n := range []int{17, 1, 17, 1, 7} {
						ids := prefillTokens(n, step+1)
						for j := range ids {
							ids[j] %= m.Config.Vocab
						}
						want := bf16WidenedPrefillReference(m, []*KVCache{ref}, [][]int{ids}, e)
						got, err := m16.prefillBorrowed(ctx, []*KVCache{a}, [][]int{ids}, e, &w)
						if err != nil {
							t.Fatal(err)
						}
						exactWorkerFloats(t, got, want)
						for i, p := range a.Pages {
							if len(p.Data) != 0 || len(p.BF16) != len(ref.Pages[i].Data) {
								t.Fatal("not compact")
							}
							for j, b := range p.BF16 {
								if math.Float32bits(fromBF16(b)) != math.Float32bits(ref.Pages[i].Data[j]) {
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
	m.kvFormat = "bf16"
	for _, pos := range []int{1, 31, 32, 33, 128} {
		a, err := planInferenceKV(m.Config, pos, 512<<20)
		if err != nil {
			t.Fatal(err)
		}
		b, err := planInferenceKVFormat(m.Config, pos, a.RequiredBytes/2, "bf16")
		if err != nil || !b.FitsBudget || b.RequiredBytes*2 != a.RequiredBytes {
			t.Fatal(a, b, err)
		}
		b, err = planInferenceKVFormat(m.Config, pos, a.RequiredBytes/2-1, "bf16")
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
				c.Pages[0] = newKVPage(len(c.Pages[0].BF16), "f32")
			case "short":
				c.Pages[0].BF16 = c.Pages[0].BF16[:1]
			case "both":
				c.Pages[0].Data = []float32{0}
			case "pool":
				c.pool = &pagePool{PageElements: len(c.Pages[0].BF16), Limit: 1, Reserved: 1, Allocated: 1}
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
	if _, _, err := loadHFModelKVFormat(context.Background(), dir, 4096, 8192, "q4-mixed", 512<<20, true, "bf16"); err == nil || strings.Contains(err.Error(), "KV budget") {
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
	if err := runInferLocal(context.Background(), []string{"-path", dir, "-context", "64", "check", "-kv-format", "bf16", "-json"}); err != nil {
		t.Fatal(err)
	}
	if _, err := out.Seek(0, 0); err != nil {
		t.Fatal(err)
	}
	var report hfCheck
	if err := json.NewDecoder(out).Decode(&report); err != nil {
		t.Fatal(err)
	}
	if report.KVPlan == nil || report.KVPlan.Format != "bf16" || report.KVPageAlignedBytes*2 != 64*report.Weights.KVBytesPerToken {
		t.Fatal(report)
	}
	for _, action := range []string{"generate", "chat", "serve"} {
		f := flags(action)
		hfFlags(f)
		kvFormatFlag(f)
		f.Int64("kv-mib", 1, "")
		if err := f.Parse([]string{"-kv-format", "bf16"}); err != nil {
			t.Fatal(err)
		}
		m, tok, err := loadInference(context.Background(), f, "", dir, 64, 8, "f32")
		if err != nil {
			t.Fatal(err)
		}
		c := m.NewCache()
		c.ensurePages(1)
		if len(c.Pages[0].Data) != 0 || len(c.Pages[0].BF16) == 0 {
			t.Fatal("loader ignored format", action)
		}
		c.Close()
		e, err := newEngine(m, tok, EngineConfig{MaxBatch: 1, Queue: 1, CacheBytes: 1 << 20})
		if err != nil {
			t.Fatal(err)
		}
		if e.pool.Format != "bf16" {
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

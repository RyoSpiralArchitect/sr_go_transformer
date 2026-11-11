// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"fmt"
	"os"
	"reflect"
	"testing"
	"time"
)

type contextSweepStageReplay struct {
	Decode contextSweepDecode  `json:"decode"`
	Timing *contextSweepTiming `json:"timing,omitempty"`
	Exact  bool                `json:"exact"`
	Path   string              `json:"path,omitempty"`
}

func init() {
	contextSweepStageProbe = replayContextSweepStages
}

func replayContextSweepStages(ctx context.Context, m *Model, e *kernelExecutor, workspace *decodeWorkspace, prefixes []*KVCache, first []float32, reference contextSweepDecode) (any, error) {
	head := m.Emb
	if m.output != nil {
		head = m.output
	}
	if m.Position != nil || head.Q8 == nil {
		return nil, fmt.Errorf("stage replay expects a Q8 output projection and seven layer projections")
	}
	// ABBA then BAAB balances position while both modes share one binary.
	schedule := []bool{false, true, true, false, true, false, false, true}
	compareSharedKV := os.Getenv("MONOLITH_SWEEP_COMPARE_SHARED_KV") == "1"
	results := make([]contextSweepStageReplay, 0, len(schedule))
	for i, enabled := range schedule {
		runCtx := ctx
		var timing *contextSweepTiming
		path := ""
		if compareSharedKV {
			path = "reference"
			if enabled {
				path = "candidate"
			}
		}
		if enabled || compareSharedKV {
			timing = &contextSweepTiming{referenceKV: compareSharedKV && !enabled}
			runCtx = context.WithValue(ctx, contextSweepTimingKey{}, timing)
		}
		r, err := runContextSweepDecode(runCtx, m, e, workspace, prefixes, first, "")
		if err != nil {
			return results, err
		}
		exact := r.Logits == reference.Logits && r.KV == reference.KV &&
			r.KVBytes == reference.KVBytes && reflect.DeepEqual(r.IDs, reference.IDs)
		results = append(results, contextSweepStageReplay{Decode: r, Timing: timing, Exact: exact, Path: path})
		if !exact {
			return results, fmt.Errorf("stage replay %d diverged from checkpoint reference", i)
		}
		if timing != nil {
			layerCalls := len(m.Blocks) * contextSweepSteps
			if timing.LayerProjections.Calls != 7*layerCalls || timing.Attention.Calls != layerCalls ||
				timing.OutputProjection.Calls != contextSweepSteps {
				return results, fmt.Errorf("stage replay %d recorded unexpected call counts", i)
			}
			if timing.referenceKV && timing.SharedKVCalls != 0 {
				return results, fmt.Errorf("reference replay %d used shared KV", i)
			}
			var total float64
			for _, seconds := range r.Seconds {
				total += seconds
			}
			timed := timing.LayerProjections.Elapsed + timing.Attention.Elapsed + timing.OutputProjection.Elapsed
			if timed <= 0 || timed.Seconds() > total+time.Nanosecond.Seconds() {
				return results, fmt.Errorf("stage replay %d recorded invalid elapsed intervals", i)
			}
		}
	}
	return results, nil
}

func TestContextSweepAttributionFixture(t *testing.T) {
	for _, format := range []string{"f32", "f16"} {
		t.Run(format, func(t *testing.T) {
			ctx := context.Background()
			m, _, err := loadHFModelKVFormat(ctx, "testdata/hf-llama3/f32", 64, 4, "q4-mixed", 4<<20, true, format)
			if err != nil {
				t.Fatal(err)
			}
			e := newKernelExecutor(4)
			defer e.close()
			cache := m.NewCache()
			defer cache.Close()
			caches := []*KVCache{cache}
			ids := make([]int, pageTokens)
			for i := range ids {
				ids[i] = i + 1
			}
			var prefill, decode decodeWorkspace
			logits, err := m.prefillBorrowed(ctx, caches, [][]int{ids}, e, &prefill)
			if err != nil {
				t.Fatal(err)
			}
			ref, err := runContextSweepDecode(ctx, m, e, &decode, caches, logits, "")
			if err != nil {
				t.Fatal(err)
			}
			for _, compare := range []string{"0", "1"} {
				t.Setenv("MONOLITH_SWEEP_COMPARE_SHARED_KV", compare)
				replays, err := contextSweepStageProbe(ctx, m, e, &decode, caches, logits, ref)
				if err != nil {
					t.Fatal(err)
				}
				rows := replays.([]contextSweepStageReplay)
				if len(rows) != 8 || cache.Pos != pageTokens || len(cache.Pages) != 1 {
					t.Fatal("stage replay advanced its prefix or stopped early")
				}
				if compare == "1" && (rows[0].Path != "reference" || rows[0].Timing == nil || rows[1].Path != "candidate") {
					t.Fatal("shared KV comparison lost a timed path")
				}
			}
		})
	}
}

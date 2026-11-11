// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"reflect"
	"runtime"
	"runtime/pprof"
	"slices"
	"strconv"
	"strings"
	"testing"
	"time"
)

const contextSweepChunk = 32
const contextSweepSteps = 7

// Only the isolated stage-timing build registers a replay.
var contextSweepStageProbe func(context.Context, *Model, *kernelExecutor, *decodeWorkspace, []*KVCache, []float32, contextSweepDecode) (any, error)

type contextSweepDecode struct {
	Seconds     []float64 `json:"decode_step_seconds"`
	IDs         [][]int   `json:"token_ids"`
	Logits      string    `json:"logits_sha256"`
	KV          string    `json:"kv_sha256"`
	KVBytes     int64     `json:"kv_payload_bytes"`
	Workspace   int64     `json:"workspace_bytes"`
	ProfileFile string    `json:"profile_file,omitempty"`
}

// All sweep checkpoints are page-aligned. Decode only appends into private
// pages. Each fork owns its page slice, and dies before the prefix advances.
func forkContextSweepCache(src *KVCache) (*KVCache, error) {
	if src.Pos%pageTokens != 0 || len(src.Pages) != src.Pos/pageTokens {
		return nil, fmt.Errorf("context sweep needs an exact whole-page prefix")
	}
	c := src.Model.NewCache()
	c.Pos = src.Pos
	c.Pages = slices.Clone(src.Pages)
	return c, nil
}

func runContextSweepDecode(ctx context.Context, m *Model, e *kernelExecutor, w *decodeWorkspace, prefixes []*KVCache, first []float32, profilePath string) (r contextSweepDecode, err error) {
	caches := make([]*KVCache, len(prefixes))
	chunks := make([][]int, len(prefixes))
	for i, prefix := range prefixes {
		cache, err := forkContextSweepCache(prefix)
		if err != nil {
			return r, err
		}
		caches[i] = cache
		defer cache.Close()
	}
	r.IDs = make([][]int, len(caches))
	for i := range r.IDs {
		r.IDs[i] = make([]int, 0, contextSweepSteps+1)
	}
	logitsHash := sha256.New()
	logits := first
	// Profile a separate replay, without hashing in its sampled interval.
	decode := func() error {
		for step := 0; step <= contextSweepSteps; step++ {
			if step > 0 {
				for i := range chunks {
					chunks[i] = r.IDs[i][step-1 : step]
				}
				started := time.Now()
				var err error
				logits, err = m.prefillBorrowed(ctx, caches, chunks, e, w)
				r.Seconds = append(r.Seconds, time.Since(started).Seconds())
				if err != nil {
					return err
				}
			}
			if profilePath == "" {
				perfHashFloats(logitsHash, logits)
			}
			for i := range caches {
				row := logits[i*m.Config.Vocab : (i+1)*m.Config.Vocab]
				best := 0
				for j, v := range row {
					if !finite(float64(v)) {
						return fmt.Errorf("nonfinite logits at step %d, session %d", step, i)
					}
					if v > row[best] {
						best = j
					}
				}
				r.IDs[i] = append(r.IDs[i], best)
			}
		}
		return nil
	}
	if profilePath != "" {
		f, err := os.OpenFile(profilePath, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0600)
		if err != nil {
			return r, err
		}
		if err := pprof.StartCPUProfile(f); err != nil {
			f.Close()
			return r, err
		}
		runErr := decode()
		pprof.StopCPUProfile()
		if closeErr := f.Close(); closeErr != nil {
			return r, closeErr
		}
		r.ProfileFile = filepath.Base(profilePath)
		return r, runErr
	}
	if err := decode(); err != nil {
		return r, err
	}
	r.Logits = hex.EncodeToString(logitsHash.Sum(nil))
	kv := sha256.New()
	half := make([]byte, 0, 2*m.Config.KVDim())
	for i, c := range caches {
		if c.Pos != prefixes[i].Pos+contextSweepSteps {
			return r, fmt.Errorf("unexpected committed decode position %d", c.Pos)
		}
		for _, page := range c.Pages {
			r.KVBytes += int64(len(page.Data))*4 + int64(len(page.F16))*2
		}
		for layer := range m.Blocks {
			for pos := 0; pos < c.Pos; pos++ {
				if c.format == "f16" {
					k, v := c.rowF16(layer, pos)
					for _, values := range [2][]uint16{k, v} {
						half = half[:0]
						for _, x := range values {
							half = binary.LittleEndian.AppendUint16(half, x)
						}
						kv.Write(half)
					}
				} else {
					k, v := c.row(layer, pos)
					perfHashFloats(kv, k)
					perfHashFloats(kv, v)
				}
			}
		}
	}
	r.KV = hex.EncodeToString(kv.Sum(nil))
	r.Workspace = w.floatBytes()
	return r, nil
}

func TestHFContextSweep(t *testing.T) {
	dir := os.Getenv("MONOLITH_SWEEP_MODEL")
	if dir == "" {
		t.Skip("manual offline context sweep")
	}
	format := os.Getenv("MONOLITH_SWEEP_FORMAT")
	sessions, _ := strconv.Atoi(os.Getenv("MONOLITH_SWEEP_SESSIONS"))
	if runtime.GOMAXPROCS(0) != 4 || (format != "f32" && format != "f16") || (sessions != 1 && sessions != 2) {
		t.Fatal("requires four threads, f32/f16, and one/two sessions")
	}
	var lengths []int
	for _, value := range strings.Split(os.Getenv("MONOLITH_SWEEP_LENGTHS"), ",") {
		n, _ := strconv.Atoi(value)
		if (n != 128 && n != 1024 && n != 4096) || (len(lengths) > 0 && n <= lengths[len(lengths)-1]) {
			t.Fatal("lengths must be an increasing subset of 128,1024,4096")
		}
		lengths = append(lengths, n)
	}
	longest := lengths[len(lengths)-1]
	ctx, cancel := context.WithTimeout(context.Background(), 44*time.Minute)
	defer cancel()
	out := os.Getenv("MONOLITH_SWEEP_OUTPUT")
	journal, err := os.OpenFile(filepath.Join(out, "cases.jsonl"), os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0600)
	if err != nil {
		t.Fatal(err)
	}
	defer journal.Close()
	record := func(event any) {
		t.Helper()
		if err := json.NewEncoder(journal).Encode(event); err != nil {
			t.Fatal(err)
		}
		if err := journal.Sync(); err != nil {
			t.Fatal(err)
		}
	}
	m, plan, err := loadHFModelKVFormat(ctx, dir, longest+contextSweepSteps, 8192, "q4-mixed", 1024<<20, true, format)
	if err != nil {
		t.Fatal(err)
	}
	tok, err := loadHFTokenizer(dir, *m.hf)
	if err != nil {
		t.Fatal(err)
	}
	var corpus struct {
		Documents []struct{ Text string } `json:"evaluation_documents"`
	}
	if err := readBoundedJSON(os.Getenv("MONOLITH_SWEEP_CORPUS"), 64<<10, &corpus); err != nil || len(corpus.Documents) < sessions {
		t.Fatal("invalid corpus", err)
	}
	prompts := make([][]int, sessions)
	caches := make([]*KVCache, sessions)
	for i := range prompts {
		line := corpus.Documents[i].Text + "\n"
		ids, err := tok.encodePrompt(ctx, line, 4096)
		if err != nil || len(ids) == 0 {
			t.Fatal("could not tokenize prompt", err)
		}
		repeat, err := tok.encodeText(ctx, line, 4096, false)
		if err != nil || len(repeat) == 0 {
			t.Fatal("could not tokenize prompt body", err)
		}
		for len(ids) < longest {
			ids = append(ids, repeat[:min(longest-len(ids), len(repeat))]...)
		}
		prompts[i] = ids[:longest]
		caches[i] = m.NewCache()
		defer caches[i].Close()
	}
	record(map[string]any{"event": "start", "format": format, "sessions": sessions,
		"plan": plan, "lengths": lengths, "chunk_per_session": contextSweepChunk, "workers": 4})
	e := newKernelExecutor(4)
	defer e.close()
	chunks, selected := make([][]int, sessions), make([]bool, sessions)
	var prefill, decode, profile decodeWorkspace
	var logits []float32
	var prefillSeconds float64
	offset := 0
	for _, length := range lengths {
		for offset < length {
			end := offset + contextSweepChunk
			for i := range chunks {
				chunks[i] = prompts[i][offset:end]
				selected[i] = end == length
			}
			started := time.Now()
			logits, err = m.prefillSelected(ctx, caches, chunks, e, &prefill, selected)
			prefillSeconds += time.Since(started).Seconds()
			if err != nil {
				t.Fatal(err)
			}
			offset = end
		}
		// Prefill owns the first logits, so the two decode workspaces cannot
		// overwrite them during either branch.
		r, err := runContextSweepDecode(ctx, m, e, &decode, caches, logits, "")
		if err != nil {
			t.Fatal(err)
		}
		promptIDs := make([][]int, sessions)
		for i := range prompts {
			promptIDs[i] = prompts[i][:length]
		}
		encoded, err := json.Marshal(promptIDs)
		if err != nil {
			t.Fatal(err)
		}
		record(map[string]any{"event": "measurement", "prefix": length, "prompt_sha256": fmt.Sprintf("%x", sha256.Sum256(encoded)),
			"prefill_seconds": prefillSeconds, "prefill_workspace_bytes": prefill.floatBytes(), "decode": r})
		p, err := runContextSweepDecode(ctx, m, e, &profile, caches, logits, filepath.Join(out, fmt.Sprintf("decode-%d.cpu", length)))
		if err != nil || !reflect.DeepEqual(p.IDs, r.IDs) {
			t.Fatal("profile replay diverged", err)
		}
		record(map[string]any{"event": "profile", "prefix": length, "file": p.ProfileFile})
		if contextSweepStageProbe != nil {
			replays, err := contextSweepStageProbe(ctx, m, e, &decode, caches, logits, r)
			record(map[string]any{"event": "stages", "prefix": length, "replays": replays})
			if err != nil {
				t.Fatal(err)
			}
		}
		t.Logf("%s %d sessions, %d-token prefix complete", format, sessions, length)
	}
	record(map[string]any{"event": "complete"})
}

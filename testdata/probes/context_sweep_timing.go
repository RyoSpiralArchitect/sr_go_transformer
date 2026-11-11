// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"context"
	"time"
)

type contextSweepSpan struct {
	Elapsed time.Duration `json:"elapsed_ns"`
	Calls   int           `json:"calls"`
}

type contextSweepTiming struct {
	LayerProjections contextSweepSpan `json:"layer_projections"`
	Attention        contextSweepSpan `json:"attention"`
	OutputProjection contextSweepSpan `json:"output_projection"`
	SharedKVCalls    int              `json:"shared_kv_calls,omitempty"`
	referenceKV      bool
}

type contextSweepTimingKey struct{}

func contextSweepTimingFrom(ctx context.Context) *contextSweepTiming {
	timing, _ := ctx.Value(contextSweepTimingKey{}).(*contextSweepTiming)
	return timing
}

// The caller records the elapsed interval after workers join. Workers never
// write to the timer. A nil timer bypasses the clock calls.
func contextSweepTimedProjection(timing *contextSweepTiming, output bool, e *kernelExecutor, y, x []float32, param *Param, rows int) {
	var started time.Time
	if timing != nil {
		started = time.Now()
	}
	linearIntoWithExecutor(e, y, x, param, rows)
	if timing != nil {
		elapsed := time.Since(started)
		span := &timing.LayerProjections
		if output {
			span = &timing.OutputProjection
		}
		span.Elapsed += elapsed
		span.Calls++
	}
}

func contextSweepTimedAttention(timing *contextSweepTiming, w *decodeWorkspace, e *kernelExecutor, c Config, layer, rows int, plan inferenceAttentionPlan) {
	var started time.Time
	if timing != nil {
		started = time.Now()
	}
	w.attend(e, c, layer, rows, plan)
	if timing != nil {
		timing.Attention.Elapsed += time.Since(started)
		timing.Attention.Calls++
		if plan.sharedKV {
			timing.SharedKVCalls++
		}
	}
}

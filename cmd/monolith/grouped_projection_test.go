// Copyright 2026 RyoSpiralArchitect
// SPDX-License-Identifier: Apache-2.0
package main

import (
	"fmt"
	"math"
	"testing"
	"time"
)

func assertGroupCleared(t testing.TB, e *kernelExecutor) {
	t.Helper()
	if e.groupCount != 0 || e.groupEnds != [3]int{} {
		t.Fatal("retained group bounds")
	}
	for _, g := range e.group {
		if g.x != nil || g.y != nil || g.w != nil || g.n != 0 {
			t.Fatal("retained group references")
		}
	}
}

func TestGroupedProjectionExactAndFallback(t *testing.T) {
	for _, format := range []string{"f32", "q4", "q8", "mixed", "wide"} {
		for _, n := range []int{1, 2, 4, 7, 17} {
			for _, in := range []int{63, 64, 513} {
				t.Run(fmt.Sprintf("%s/rows%d/in%d", format, n, in), func(t *testing.T) {
					x, _, _ := linearFixture(n, in, 1)
					if format == "wide" {
						x[0] = math.MaxFloat32 / 4
					}
					var projections []inferenceProjection
					var wants [][]float32
					var guards [][]float32
					for i, out := range []int{259, 33, 65} {
						_, p, _ := linearFixture(n, in, out)
						// Keep extreme fixture outputs representable.
						if format == "wide" {
							for j := range p.Data {
								p.Data[j] *= 0.0001
							}
						}
						if format == "q4" || format == "wide" || format == "mixed" && i == 1 {
							p = quantizeQ4TestParam(t, p)
						}
						if format == "q8" {
							p = quantizeTestParam(t, p)
						}
						want := make([]float32, n*out)
						linearIntoWithExecutor(nil, want, x, p, n)
						wants = append(wants, want)
						g := make([]float32, n*out+2)
						g[0], g[len(g)-1] = 987, 987
						guards = append(guards, g)
						projections = append(projections, inferenceProjection{g[1 : len(g)-1], p})
					}
					for _, workers := range []int{0, 1, 4} {
						var e *kernelExecutor
						if workers > 0 {
							e = newKernelExecutor(workers)
						}
						for _, count := range []int{3, 2, 3} {
							linearGroupInto(e, x, n, projections[:count]...)
							for i, p := range projections[:count] {
								exactWorkerFloats(t, p.y, wants[i])
								if guards[i][0] != 987 || guards[i][len(guards[i])-1] != 987 {
									t.Fatal("output overrun")
								}
							}
							if e != nil {
								assertGroupCleared(t, e)
							}
						}
						if e != nil {
							e.close()
						}
					}
				})
			}
		}
	}
}

func TestGroupedProjectionJoinsAndReuses(t *testing.T) {
	e := newKernelExecutor(4)
	x, p, _ := linearFixture(4, 513, 259)
	q := quantizeQ4TestParam(t, p)
	a, b := make([]float32, 4*259), make([]float32, 4*259)
	projections := []inferenceProjection{{a, q}, {b, q}}
	linearGroupInto(e, x, 4, projections...)
	if e.groupFn == nil {
		e.close()
		t.Fatal("group did not dispatch")
	}
	if got := testing.AllocsPerRun(10, func() { linearGroupInto(e, x, 4, projections...) }); got != 0 {
		e.close()
		t.Fatal("warm allocations", got)
	}
	original := e.groupFn
	entered, release, done := make(chan struct{}, 4), make(chan struct{}), make(chan struct{})
	e.groupFn = func(lo, hi int) { entered <- struct{}{}; <-release; original(lo, hi) }
	go func() { linearGroupInto(e, x, 4, projections...); close(done) }()
	t.Cleanup(func() {
		select {
		case <-release:
		default:
			close(release)
		}
		<-done
		e.close()
	})
	for i := 0; i < 4; i++ {
		select {
		case <-entered:
		case <-time.After(5 * time.Second):
			t.Fatal("worker did not enter")
		}
	}
	select {
	case <-done:
		t.Fatal("returned with borrowed outputs")
	default:
	}
	if e.groupCount != 2 || e.group[0].w != q || e.group[1].w != q {
		t.Fatal("cleared before join")
	}
	close(release)
	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("join timeout")
	}
	assertGroupCleared(t, e)
	exactWorkerFloats(t, a, b)
}

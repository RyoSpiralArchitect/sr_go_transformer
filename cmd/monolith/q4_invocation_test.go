package main

import (
	"fmt"
	"math"
	"sync"
	"testing"
	"time"
)

func TestQ4InvocationSteadyAllocation(t *testing.T) {
	for _, workers := range []int{1, 2, 4} {
		for _, rows := range []int{1, 2, 3, 4, 5, 17} {
			t.Run(fmt.Sprintf("workers%d/rows%d", workers, rows), func(t *testing.T) {
				e := newKernelExecutor(workers)
				defer e.close()
				x, dense, _ := linearFixture(rows, 513, 259)
				w := quantizeQ4TestParam(t, dense)
				y := make([]float32, rows*w.Rows)
				linearQ4Into(e, y, x, w, rows)
				if got := testing.AllocsPerRun(20, func() { linearQ4Into(e, y, x, w, rows) }); got != 0 {
					t.Fatalf("warm Q4 kernel allocated %.1f objects, want zero", got)
				}
			})
		}
	}
}

func TestQ4InvocationExact(t *testing.T) {
	for _, workers := range []int{1, 4} {
		e := newKernelExecutor(workers)
		for _, rows := range []int{0, 1, 2, 3, 4, 5, 7, 8, 17} {
			for _, in := range []int{1, 3, 63, 64, 65, 129, 513} {
				for _, out := range []int{1, 2, 31, 32, 33, 65, 259} {
					x, dense, _ := linearFixture(rows, in, out)
					w := quantizeQ4TestParam(t, dense)
					want := make([]float32, rows*out)
					guarded := make([]float32, rows*out+2)
					for i := range guarded {
						guarded[i] = -777
					}
					got := guarded[1 : len(guarded)-1]
					blockBaselineLinearQ4Into(e, want, x, w, rows)
					linearQ4Into(e, got, x, w, rows)
					assertQ4InvocationCleared(t, e)
					if guarded[0] != -777 || guarded[len(guarded)-1] != -777 {
						t.Fatal("Q4 wrote beyond output range")
					}
					for i := range want {
						if math.Float32bits(got[i]) != math.Float32bits(want[i]) {
							t.Fatalf("workers%d/rows%d/in%d/out%d element%d", workers, rows, in, out, i)
						}
					}
				}
			}
		}
		e.close()
	}
}

func assertQ4InvocationCleared(t *testing.T, e *kernelExecutor) {
	t.Helper()
	if e.linear.x != nil || e.linear.y != nil || e.linear.w != nil || e.linear.n != 0 {
		t.Fatal("executor retained Q4 inputs after join")
	}
}

func TestQ4InvocationWaitsBeforeClearing(t *testing.T) {
	e := newKernelExecutor(4)
	x, dense, _ := linearFixture(4, 513, 259)
	w := quantizeQ4TestParam(t, dense)
	y, want := make([]float32, 4*w.Rows), make([]float32, 4*w.Rows)
	blockBaselineLinearQ4Into(e, want, x, w, 4)
	linearQ4Into(e, y, x, w, 4)
	standard := e.q4Fn
	if standard == nil {
		e.close()
		t.Fatal("parallel Q4 callback not initialized")
	}
	started, release, done := make(chan struct{}, 4), make(chan struct{}), make(chan struct{})
	e.q4Fn = func(lo, hi int) { started <- struct{}{}; <-release; standard(lo, hi) }
	go func() { linearQ4Into(e, y, x, w, 4); close(done) }()
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
		case <-started:
		case <-time.After(5 * time.Second):
			t.Fatal("Q4 worker did not start")
		}
	}
	select {
	case <-done:
		t.Fatal("Q4 returned while workers borrowed state")
	default:
	}
	if e.linear.w != w || e.linear.n != 4 || len(e.linear.x) != len(x) || len(e.linear.y) != len(y) {
		t.Fatal("Q4 state cleared before worker completion")
	}
	close(release)
	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("Q4 workers did not join")
	}
	assertQ4InvocationCleared(t, e)
	exactWorkerFloats(t, y, want)
	e.q4Fn = standard
	linearQ4Into(e, y, x, w, 4)
	exactWorkerFloats(t, y, want)
	assertQ4InvocationCleared(t, e)
}

func TestQ4InvocationWideAndIndependentOwners(t *testing.T) {
	x, dense, _ := linearFixture(4, 513, 259)
	w := quantizeQ4TestParam(t, dense)
	want := make([]float32, 4*w.Rows)
	blockBaselineLinearQ4Into(nil, want, x, w, 4)
	var wg sync.WaitGroup
	for i := 0; i < 4; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			e := newKernelExecutor(4)
			defer e.close()
			y := make([]float32, len(want))
			for repeat := 0; repeat < 5; repeat++ {
				linearQ4Into(e, y, x, w, 4)
				exactWorkerFloats(t, y, want)
				assertQ4InvocationCleared(t, e)
			}
		}()
	}
	wg.Wait()
	e := newKernelExecutor(4)
	defer e.close()
	for i := range x {
		x[i] = math.MaxFloat32 / 4
	}
	if !q8NeedsWideSum(x) {
		t.Fatal("wide fixture did not select fallback")
	}
	y := make([]float32, len(want))
	blockBaselineLinearQ4Into(e, want, x, w, 4)
	linearQ4Into(e, y, x, w, 4)
	for i := range y {
		if math.Float32bits(y[i]) != math.Float32bits(want[i]) {
			t.Fatalf("wide Q4 bits differ at %d", i)
		}
	}
	assertQ4InvocationCleared(t, e)
	if e.q4Fn != nil {
		t.Fatal("wide fallback initialized ordinary Q4 callback")
	}
}

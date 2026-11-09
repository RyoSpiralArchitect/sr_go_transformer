package main

import (
	"fmt"
	"math"
	"sync"
	"testing"
)

func TestQ8InvocationAllocationBaseline(t *testing.T) {
	for _, workers := range []int{1, 2, 4} {
		for _, rows := range []int{1, 2, 3, 4, 5, 17} {
			t.Run(fmt.Sprintf("workers%d/rows%d", workers, rows), func(t *testing.T) {
				e := newKernelExecutor(workers)
				defer e.close()
				x, dense, _ := linearFixture(rows, 513, 259)
				w := quantizeTestParam(t, dense)
				y := make([]float32, rows*w.Rows)
				linearQ8Into(e, y, x, w, rows)
				got := testing.AllocsPerRun(20, func() { linearQ8Into(e, y, x, w, rows) })
				t.Logf("retained Q8 baseline: %.1f objects per warm call", got)
			})
		}
	}
}

func TestQ8InvocationWideAndIndependentOwners(t *testing.T) {
	x, dense, _ := linearFixture(4, 513, 259)
	w := quantizeTestParam(t, dense)
	want := make([]float32, 4*w.Rows)
	baselineLinearQ8Into(nil, want, x, w, 4)
	var wg sync.WaitGroup
	for i := 0; i < 4; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			e := newKernelExecutor(4)
			defer e.close()
			y := make([]float32, len(want))
			for repeat := 0; repeat < 5; repeat++ {
				linearQ8Into(e, y, x, w, 4)
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
	y := make([]float32, len(want))
	baselineLinearQ8Into(e, want, x, w, 4)
	linearQ8Into(e, y, x, w, 4)
	for i := range y {
		if math.Float32bits(y[i]) != math.Float32bits(want[i]) {
			t.Fatalf("wide Q8 bits differ at %d", i)
		}
	}
	assertQ4InvocationCleared(t, e)
}

func TestQ8InvocationExact(t *testing.T) {
	for _, workers := range []int{1, 4} {
		e := newKernelExecutor(workers)
		for _, rows := range []int{0, 1, 2, 3, 4, 5, 7, 8, 17} {
			for _, in := range []int{1, 3, 63, 64, 65, 129, 513} {
				for _, out := range []int{1, 2, 31, 32, 33, 65, 259} {
					x, dense, _ := linearFixture(rows, in, out)
					w := quantizeTestParam(t, dense)
					want := make([]float32, rows*out)
					guarded := make([]float32, rows*out+2)
					for i := range guarded {
						guarded[i] = -777
					}
					got := guarded[1 : len(guarded)-1]
					baselineLinearQ8Into(e, want, x, w, rows)
					linearQ8Into(e, got, x, w, rows)
					assertQ4InvocationCleared(t, e)
					if guarded[0] != -777 || guarded[len(guarded)-1] != -777 {
						t.Fatal("Q8 output guard changed")
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

package main

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"math"
	"os"
	"reflect"
	"runtime"
	"sort"
	"sync"
	"testing"
	"time"
)

func frozenWideSumScan(x []float32) bool {
	const limit = float32(math.MaxFloat32 / (2 * q8Block * 127))
	for _, v := range x {
		if v > limit || v < -limit {
			return true
		}
	}
	return false
}

func boundedBitsWideSumScan(x []float32) bool {
	const limit = float32(math.MaxFloat32 / (2 * q8Block * 127))
	limitBits := math.Float32bits(limit)
	for _, v := range x {
		magnitude := math.Float32bits(v) & 0x7fffffff
		if magnitude > limitBits && magnitude <= 0x7f800000 {
			return true
		}
	}
	return false
}

func rangeBitsWideSumScan(x []float32) bool {
	const limit = float32(math.MaxFloat32 / (2 * q8Block * 127))
	limitBits := math.Float32bits(limit)
	for _, v := range x {
		magnitude := math.Float32bits(v) & 0x7fffffff
		if magnitude-(limitBits+1) < 0x7f800000-limitBits {
			return true
		}
	}
	return false
}

func TestWideSumScanPredicates(t *testing.T) {
	const limit = float32(math.MaxFloat32 / (2 * q8Block * 127))
	boundary := math.Float32bits(limit)
	bits := []uint32{0, 1, 0x007fffff, 0x00800000, boundary - 1, boundary, boundary + 1, 0x7f7fffff, 0x7f800000, 0x7f800001, 0x7fc00000, 0x7fffffff}
	check := func(x []float32) {
		t.Helper()
		want := frozenWideSumScan(x)
		for _, fn := range []func([]float32) bool{q8NeedsWideSum, boundedBitsWideSumScan, rangeBitsWideSumScan} {
			if fn(x) != want {
				t.Fatalf("wide predicate mismatch for %v", x)
			}
		}
	}
	check(nil)
	for _, magnitude := range bits {
		for _, sign := range []uint32{0, 0x80000000} {
			v := math.Float32frombits(magnitude | sign)
			check([]float32{v})
			for _, length := range []int{2, 63, 64, 65, 257} {
				for _, pos := range []int{0, length / 2, length - 1} {
					x := make([]float32, length)
					x[pos] = v
					check(x)
				}
			}
		}
	}
	r := RNG{State: 23}
	var x [17]float32
	for trial := 0; trial < 65536; trial++ {
		for i := range x {
			x[i] = math.Float32frombits(uint32(r.Uint64()))
		}
		check(x[:])
	}
}

type compactProjectionLayout struct {
	workers        int
	jobs           chan kernelJob
	completed      chan struct{}
	lifetime       sync.WaitGroup
	linear         fp32Kernel
	linearFn, q4Fn func(lo, hi int)
}

func TestProjectionDescriptorFootprint(t *testing.T) {
	actual, compact := reflect.TypeOf(kernelExecutor{}).Size(), reflect.TypeOf(compactProjectionLayout{}).Size()
	t.Logf("executor %d bytes; compact layout %d bytes", actual, compact)
	if actual > compact {
		t.Fatalf("executor size %d exceeds shared descriptor layout %d", actual, compact)
	}
}

func TestProjectionCallbacksStartLazy(t *testing.T) {
	for _, workers := range []int{1, 4} {
		e := newKernelExecutor(workers)
		if e.linearFn != nil || e.q4Fn != nil {
			e.close()
			t.Fatal("unused projection callback allocated at construction")
		}
		e.close()
	}
}

func TestSharedProjectionAlternatingFormats(t *testing.T) {
	for _, workers := range []int{1, 4} {
		e := newKernelExecutor(workers)
		for _, rows := range []int{1, 3, 4, 5, 17} {
			x, dense, _ := linearFixture(rows, 513, 259)
			q4, q8 := quantizeQ4TestParam(t, dense), quantizeTestParam(t, dense)
			for _, w := range []*Param{q4, dense, q8, q4, dense, q4} {
				y, want := make([]float32, rows*w.Rows), make([]float32, rows*w.Rows)
				linearIntoWithExecutor(nil, want, x, w, rows)
				linearIntoWithExecutor(e, y, x, w, rows)
				exactWorkerFloats(t, y, want)
				assertQ4InvocationCleared(t, e)
				if workers == 1 && (e.q4Fn != nil || e.linearFn != nil) {
					t.Fatal("serial projection initialized a callback")
				}
			}
		}
		e.close()
	}
}

var wideScanSink bool

func TestWideSumScanTiming(t *testing.T) {
	output := os.Getenv("MONOLITH_WIDE_SCAN_OUTPUT")
	if output == "" {
		t.Skip("opt-in wide scan comparison")
	}
	old := runtime.GOMAXPROCS(1)
	defer runtime.GOMAXPROCS(old)
	type result struct {
		Length       int
		NS           [3][]float64
		Ratios       [2][]float64
		MedianRatios [2]float64
	}
	artifact := struct {
		Protocol, GoVersion, GOOS, GOARCH string
		Hashes                            map[string]string
		Results                           []result
	}{Protocol: "wide-scan-three-way-rotating-v1", GoVersion: runtime.Version(), GOOS: runtime.GOOS, GOARCH: runtime.GOARCH, Hashes: make(map[string]string)}
	for _, path := range []string{"cmd/monolith/monolith.go", "cmd/monolith/q4_call_overhead_test.go"} {
		data, err := os.ReadFile(path)
		if err != nil {
			t.Fatal(err)
		}
		artifact.Hashes[path] = fmt.Sprintf("%x", sha256.Sum256(data))
	}
	functions := []func([]float32) bool{frozenWideSumScan, boundedBitsWideSumScan, rangeBitsWideSumScan}
	for _, length := range []int{64, 256, 704, 1536, 3584, 16384} {
		x := make([]float32, length)
		r := RNG{State: uint64(length)}
		for i := range x {
			x[i] = float32(r.Normal())
		}
		iterations := max(1, (1<<20)/length)
		run := func(variant int) {
			for i := 0; i < iterations; i++ {
				wideScanSink = functions[variant](x)
			}
		}
		for variant := range functions {
			run(variant)
		}
		row := result{Length: length}
		for trial := 0; trial < 32; trial++ {
			var elapsed [3]float64
			for leg := 0; leg < 3; leg++ {
				variant := (trial + leg) % 3
				start := time.Now()
				run(variant)
				elapsed[variant] = float64(time.Since(start).Nanoseconds()) / float64(iterations)
				row.NS[variant] = append(row.NS[variant], elapsed[variant])
			}
			for candidate := 0; candidate < 2; candidate++ {
				row.Ratios[candidate] = append(row.Ratios[candidate], elapsed[candidate+1]/elapsed[0])
			}
		}
		for candidate := 0; candidate < 2; candidate++ {
			sorted := append([]float64(nil), row.Ratios[candidate]...)
			sort.Float64s(sorted)
			row.MedianRatios[candidate] = (sorted[15] + sorted[16]) / 2
		}
		artifact.Results = append(artifact.Results, row)
		t.Logf("length%d bounded %.4f, range %.4f", length, row.MedianRatios[0], row.MedianRatios[1])
	}
	data, err := json.MarshalIndent(artifact, "", "  ")
	if err != nil {
		t.Fatal(err)
	}
	f, err := os.OpenFile(output, os.O_CREATE|os.O_EXCL|os.O_WRONLY, 0644)
	if err != nil {
		t.Fatal(err)
	}
	_, writeErr := f.Write(append(data, '\n'))
	closeErr := f.Close()
	if writeErr != nil || closeErr != nil {
		t.Fatal(writeErr, closeErr)
	}
}

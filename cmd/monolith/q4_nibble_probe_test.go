package main

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"math"
	"os"
	"runtime"
	"sort"
	"testing"
	"time"
)

func nibbleQ4Pair(v byte) (float32, float32) {
	return float32(int8(v<<4) >> 4), float32(int8(v) >> 4)
}

func nibbleQ4Block64(x *[64]float32, w *[32]byte) float32 {
	var a, b, c, d float32
	p0, p1 := nibbleQ4Pair(w[0])
	q0, q1 := nibbleQ4Pair(w[1])
	a += x[0] * p0
	b += x[1] * p1
	c += x[2] * q0
	d += x[3] * q1
	p0, p1 = nibbleQ4Pair(w[2])
	q0, q1 = nibbleQ4Pair(w[3])
	a += x[4] * p0
	b += x[5] * p1
	c += x[6] * q0
	d += x[7] * q1
	p0, p1 = nibbleQ4Pair(w[4])
	q0, q1 = nibbleQ4Pair(w[5])
	a += x[8] * p0
	b += x[9] * p1
	c += x[10] * q0
	d += x[11] * q1
	p0, p1 = nibbleQ4Pair(w[6])
	q0, q1 = nibbleQ4Pair(w[7])
	a += x[12] * p0
	b += x[13] * p1
	c += x[14] * q0
	d += x[15] * q1
	p0, p1 = nibbleQ4Pair(w[8])
	q0, q1 = nibbleQ4Pair(w[9])
	a += x[16] * p0
	b += x[17] * p1
	c += x[18] * q0
	d += x[19] * q1
	p0, p1 = nibbleQ4Pair(w[10])
	q0, q1 = nibbleQ4Pair(w[11])
	a += x[20] * p0
	b += x[21] * p1
	c += x[22] * q0
	d += x[23] * q1
	p0, p1 = nibbleQ4Pair(w[12])
	q0, q1 = nibbleQ4Pair(w[13])
	a += x[24] * p0
	b += x[25] * p1
	c += x[26] * q0
	d += x[27] * q1
	p0, p1 = nibbleQ4Pair(w[14])
	q0, q1 = nibbleQ4Pair(w[15])
	a += x[28] * p0
	b += x[29] * p1
	c += x[30] * q0
	d += x[31] * q1
	p0, p1 = nibbleQ4Pair(w[16])
	q0, q1 = nibbleQ4Pair(w[17])
	a += x[32] * p0
	b += x[33] * p1
	c += x[34] * q0
	d += x[35] * q1
	p0, p1 = nibbleQ4Pair(w[18])
	q0, q1 = nibbleQ4Pair(w[19])
	a += x[36] * p0
	b += x[37] * p1
	c += x[38] * q0
	d += x[39] * q1
	p0, p1 = nibbleQ4Pair(w[20])
	q0, q1 = nibbleQ4Pair(w[21])
	a += x[40] * p0
	b += x[41] * p1
	c += x[42] * q0
	d += x[43] * q1
	p0, p1 = nibbleQ4Pair(w[22])
	q0, q1 = nibbleQ4Pair(w[23])
	a += x[44] * p0
	b += x[45] * p1
	c += x[46] * q0
	d += x[47] * q1
	p0, p1 = nibbleQ4Pair(w[24])
	q0, q1 = nibbleQ4Pair(w[25])
	a += x[48] * p0
	b += x[49] * p1
	c += x[50] * q0
	d += x[51] * q1
	p0, p1 = nibbleQ4Pair(w[26])
	q0, q1 = nibbleQ4Pair(w[27])
	a += x[52] * p0
	b += x[53] * p1
	c += x[54] * q0
	d += x[55] * q1
	p0, p1 = nibbleQ4Pair(w[28])
	q0, q1 = nibbleQ4Pair(w[29])
	a += x[56] * p0
	b += x[57] * p1
	c += x[58] * q0
	d += x[59] * q1
	p0, p1 = nibbleQ4Pair(w[30])
	q0, q1 = nibbleQ4Pair(w[31])
	a += x[60] * p0
	b += x[61] * p1
	c += x[62] * q0
	d += x[63] * q1
	return (a + b) + (c + d)
}

func TestNibbleQ4BlockExact(t *testing.T) {
	r := RNG{State: 19}
	for code := 0; code < 256; code++ {
		lo, hi := nibbleQ4Pair(byte(code))
		if lo != q4Pairs[code][0] || hi != q4Pairs[code][1] {
			t.Fatalf("decode byte %d", code)
		}
		var x [64]float32
		var w [32]byte
		for i := range x {
			x[i] = float32(r.Normal())
		}
		for i := range w {
			w[i] = byte(code + i*37)
		}
		want, got := dotQ4Block64(&x, &w), nibbleQ4Block64(&x, &w)
		if math.Float32bits(got) != math.Float32bits(want) {
			t.Fatalf("code %d: %08x != %08x", code, math.Float32bits(got), math.Float32bits(want))
		}
	}
}

var nibbleQ4Sink float32

func TestNibbleQ4Timing(t *testing.T) {
	output := os.Getenv("MONOLITH_Q4_NIBBLE_OUTPUT")
	if output == "" {
		t.Skip("opt-in nibble versus lookup comparison")
	}
	old := runtime.GOMAXPROCS(1)
	defer runtime.GOMAXPROCS(old)
	r := RNG{State: 19}
	var x [256][64]float32
	var w [256][32]byte
	for i := range x {
		for j := range x[i] {
			x[i][j] = float32(r.Normal())
		}
		for j := range w[i] {
			w[i][j] = byte(r.Uint64())
		}
		if math.Float32bits(dotQ4Block64(&x[i], &w[i])) != math.Float32bits(nibbleQ4Block64(&x[i], &w[i])) {
			t.Fatal("fixture differs")
		}
	}
	functions := []func(*[64]float32, *[32]byte) float32{dotQ4Block64, nibbleQ4Block64}
	run := func(variant int) {
		var sum float32
		for repeat := 0; repeat < 1024; repeat++ {
			for i := range x {
				sum += functions[variant](&x[i], &w[i])
			}
		}
		nibbleQ4Sink = sum
	}
	run(0)
	run(1)
	var before, after, ratios []float64
	for trial := 0; trial < 32; trial++ {
		var elapsed [2]float64
		for leg := 0; leg < 2; leg++ {
			variant := (trial + leg) % 2
			start := time.Now()
			run(variant)
			elapsed[variant] = float64(time.Since(start).Nanoseconds()) / (1024 * 256)
		}
		before = append(before, elapsed[0])
		after = append(after, elapsed[1])
		ratios = append(ratios, elapsed[1]/elapsed[0])
	}
	sorted := append([]float64(nil), ratios...)
	sort.Float64s(sorted)
	hashes := make(map[string]string)
	for _, path := range []string{"cmd/monolith/monolith.go", "cmd/monolith/q4_nibble_probe_test.go"} {
		data, err := os.ReadFile(path)
		if err != nil {
			t.Fatal(err)
		}
		hashes[path] = fmt.Sprintf("%x", sha256.Sum256(data))
	}
	artifact := struct {
		Protocol, GoVersion, GOOS, GOARCH string
		SourceSHA256                      map[string]string
		BeforeNS, AfterNS, Ratios         []float64
		MedianRatio                       float64
		Allocs                            [2]float64
	}{"q4-nibble-block64-alternating-v1", runtime.Version(), runtime.GOOS, runtime.GOARCH, hashes,
		before, after, ratios, (sorted[15] + sorted[16]) / 2,
		[2]float64{testing.AllocsPerRun(5, func() { run(0) }), testing.AllocsPerRun(5, func() { run(1) })}}
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
	t.Logf("nibble/lookup ratio %.4f; allocs %v", artifact.MedianRatio, artifact.Allocs)
}

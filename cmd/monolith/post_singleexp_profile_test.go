package main

import (
	"fmt"
	"reflect"
	"runtime"
	"testing"
)

func postSingleExpModel(t testing.TB, format string) *Model {
	t.Helper()
	m := decodeComparisonModel(t, Tokenizer{})
	for _, p := range m.Params {
		if p.Rows < 2 || format == "f32" {
			continue
		}
		var q *Param
		switch format {
		case "q8":
			q = quantizeTestParam(t, p)
		case "q4":
			q = quantizeQ4TestParam(t, p)
		default:
			t.Fatalf("unknown format %q", format)
		}
		*p = *q
	}
	return m
}

func BenchmarkPostSingleExpGeneration(b *testing.B) {
	for _, format := range []string{"f32", "q8", "q4"} {
		b.Run(format, func(b *testing.B) {
			m := postSingleExpModel(b, format)
			for _, workers := range []int{1, 4} {
				b.Run(fmt.Sprintf("workers%d", workers), func(b *testing.B) {
					for _, shape := range [][2]int{{257, 1}, {33, 8}, {33, 128}} {
						b.Run(fmt.Sprintf("prefix%d/tokens%d", shape[0], shape[1]), func(b *testing.B) {
							old := runtime.GOMAXPROCS(workers)
							defer runtime.GOMAXPROCS(old)
							_, planned := planGenerationPrompt(m, shape[0], shape[1])
							if planned != workers {
								b.Fatalf("planned %d workers, want %d", planned, workers)
							}
							want := decodeComparisonRun(b, m, Tokenizer{}, false, shape[0], shape[1])
							if got := decodeComparisonRun(b, m, Tokenizer{}, false, shape[0], shape[1]); !reflect.DeepEqual(got, want) {
								b.Fatal("completion is not deterministic")
							}
							b.ReportAllocs()
							b.ResetTimer()
							for i := 0; i < b.N; i++ {
								decodeComparisonRun(b, m, Tokenizer{}, false, shape[0], shape[1])
							}
						})
					}
				})
			}
		})
	}
}

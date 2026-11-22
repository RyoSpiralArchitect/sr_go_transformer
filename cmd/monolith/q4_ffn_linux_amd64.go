//go:build !purego

package main

import "os"

func init() {
	if os.Getenv("MONOLITH_Q4_FFN_AVX2") == "1" && q4HasAVX2() {
		q4FFNPairDot = dotQ4FFNPairAVX2
	}
}

func q4HasAVX2() bool

// Each scale covers 64 floats and 32 packed bytes in each row.
//
//go:noescape
func dotQ4FFNPairAVX2(x0, x1 []float32, w0, w1 []byte, s0, s1 []float32) (a00, a01, a10, a11 float32)

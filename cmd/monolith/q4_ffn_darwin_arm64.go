//go:build !purego

package main

import "os"

func init() {
	switch os.Getenv("MONOLITH_Q4_FFN_NEON") {
	case "all+attention":
		q4NativeAttention = true
		fallthrough
	case "all":
		q4NativeQuadDot = dotQ4FFNQuadNEON
		fallthrough
	case "1":
		q4NativePairDot = dotQ4FFNPairNEON
	}
}

// Each scale covers 64 floats and 32 packed bytes per row. The caller has
// checked the activation range and passes two complete input and output rows.
//
//go:noescape
func dotQ4FFNPairNEON(x0, x1 []float32, w0, w1 []byte, s0, s1 []float32) (a00, a01, a10, a11 float32)

// x contains whole 64-element blocks. packed and scales contain four
// consecutive rows with 32 packed bytes and one scale per block per row.
//
//go:noescape
func dotQ4FFNQuadNEON(x []float32, packed []byte, scales []float32) (a, b, c, d float32)

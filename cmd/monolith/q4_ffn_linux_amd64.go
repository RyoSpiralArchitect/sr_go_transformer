//go:build !purego

package main

import "os"

func init() {
	mode := os.Getenv("MONOLITH_Q4_FFN_AVX2")
	switch mode {
	case "1", "all", "all+attention":
		if !q4HasAVX2() {
			return
		}
		q4NativePairDot = dotQ4FFNPairAVX2
		if mode != "1" {
			q4NativeQuadDot = dotQ4QuadAVX2
		}
		q4NativeAttention = mode == "all+attention"
	}
}

// Go compilers may contract a multiply and add on GOAMD64=v3 and above.
// This product rounds to 1 before addition, or to a negative residual if fused.
var q4UseFMA = q4MultiplyAdd(1+0x1p-23, 1-0x1p-23, -1) != 0

//go:noinline
func q4MultiplyAdd(x, y, z float32) float32 { return x*y + z }

func q4HasAVX2() bool

// Each scale covers 64 floats and 32 packed bytes in each row.
//
//go:noescape
func dotQ4FFNPairAVX2(x0, x1 []float32, w0, w1 []byte, s0, s1 []float32) (a00, a01, a10, a11 float32)

// A whole number of 64-value blocks, with four contiguous packed output rows
// and their per-row block scales.
//
//go:noescape
func dotQ4QuadAVX2(x []float32, packed []byte, scales []float32) (a, b, c, d float32)

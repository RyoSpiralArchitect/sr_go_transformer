//go:build !purego

package main

func init() { q4FFNPairDot = dotQ4FFNPairNEON }

// Each scale covers 64 floats and 32 packed bytes per row. The caller has
// checked the activation range and passes two complete input and output rows.
//
//go:noescape
func dotQ4FFNPairNEON(x0, x1 []float32, w0, w1 []byte, s0, s1 []float32) (a00, a01, a10, a11 float32)

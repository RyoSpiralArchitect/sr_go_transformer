//go:build !purego

package main

const testQ4NativeEnv = "MONOLITH_Q4_FFN_AVX2"

var testQ4NativeDot = dotQ4FFNPairAVX2

func testQ4NativeAvailable() bool { return q4HasAVX2() }

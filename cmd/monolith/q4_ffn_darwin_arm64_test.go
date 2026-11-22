//go:build !purego

package main

const testQ4NativeEnv = "MONOLITH_Q4_FFN_NEON"

var testQ4NativeDot = dotQ4FFNPairNEON

func testQ4NativeAvailable() bool { return true }

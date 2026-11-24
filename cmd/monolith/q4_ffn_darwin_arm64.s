//go:build !purego

#include "textflag.h"

// The low 16 bits of float32(k) are zero for every signed nibble k.
// Indexing these two byte tables supplies bits 16..23 and 24..31.
DATA q4FloatBytes<>+0(SB)/8, $0xe0c0a08040008000
DATA q4FloatBytes<>+8(SB)/8, $0x80004080a0c0e000
DATA q4FloatBytes<>+16(SB)/8, $0x4040404040403f00
DATA q4FloatBytes<>+24(SB)/8, $0xbfc0c0c0c0c0c0c1
GLOBL q4FloatBytes<>(SB), RODATA|NOPTR, $32

// Expand eight packed bytes to sixteen high halfwords, low nibble first.
#define DECODE16(ptr, lo, hi) \
	VLD1.P 8(ptr), [V9.B8]; \
	VAND V6.B16, V9.B16, V10.B16; \
	VUSHR $4, V9.B16, V9.B16; \
	VZIP1 V9.B16, V10.B16, V10.B16; \
	VTBL V10.B16, [V7.B16], V11.B16; \
	VTBL V10.B16, [V8.B16], V12.B16; \
	VZIP1 V12.B16, V11.B16, lo; \
	VZIP2 V12.B16, V11.B16, hi

// Insert zero low halfwords and reuse both weights across the two inputs.
#define ACCUM4(zip, w0, w1, x0, x1) \
	zip w0, V5.H8, V17.H8; \
	zip w1, V5.H8, V18.H8; \
	VFMLA V17.S4, x0, V1.S4; \
	VFMLA V18.S4, x0, V2.S4; \
	VFMLA V17.S4, x1, V3.S4; \
	VFMLA V18.S4, x1, V4.S4

// ARM64 FADDP Vd.4S, Vn.4S, Vm.4S. Go 1.22 lacks this vector mnemonic.
#define FADDP4(d, n, m) WORD $(0x6e20d400 | ((m)<<16) | ((n)<<5) | (d))

TEXT ·dotQ4FFNPairNEON(SB), NOSPLIT, $0-160
	MOVD x0_base+0(FP), R0
	MOVD x1_base+24(FP), R1
	MOVD w0_base+48(FP), R2
	MOVD w1_base+72(FP), R3
	MOVD s0_base+96(FP), R4
	MOVD s1_base+120(FP), R5
	MOVD s0_len+104(FP), R6
	MOVD $q4FloatBytes<>(SB), R8
	VLD1 (R8), [V7.B16, V8.B16]
	VMOVI $15, V6.B16
	VEOR V5.B16, V5.B16, V5.B16
	VEOR V0.B16, V0.B16, V0.B16
	CBZ R6, done

block:
	VEOR V1.B16, V1.B16, V1.B16
	VEOR V2.B16, V2.B16, V2.B16
	VEOR V3.B16, V3.B16, V3.B16
	VEOR V4.B16, V4.B16, V4.B16
	MOVD $4, R7
lanes:
	DECODE16(R2, V13.B16, V14.B16)
	DECODE16(R3, V15.B16, V16.B16)
	VLD1.P 64(R0), [V24.S4, V25.S4, V26.S4, V27.S4]
	VLD1.P 64(R1), [V28.S4, V29.S4, V30.S4, V31.S4]
	ACCUM4(VZIP1, V13.H8, V15.H8, V24.S4, V28.S4)
	ACCUM4(VZIP2, V13.H8, V15.H8, V25.S4, V29.S4)
	ACCUM4(VZIP1, V14.H8, V16.H8, V26.S4, V30.S4)
	ACCUM4(VZIP2, V14.H8, V16.H8, V27.S4, V31.S4)
	SUB $1, R7
	CBNZ R7, lanes

	// The scalar kernel reduces (a+b)+(c+d) for each of the four dots.
	FADDP4(1, 1, 2)
	FADDP4(3, 3, 4)
	FADDP4(1, 1, 3)
	VLD1.P 4(R4), V9.S[0]
	VLD1.P 4(R5), V9.S[1]
	VZIP1 V9.D2, V9.D2, V9.D2
	VFMLA V9.S4, V1.S4, V0.S4
	SUB $1, R6
	CBNZ R6, block

done:
	VMOV V0.S[0], R8
	MOVW R8, a00+144(FP)
	VMOV V0.S[1], R8
	MOVW R8, a01+148(FP)
	VMOV V0.S[2], R8
	MOVW R8, a10+152(FP)
	VMOV V0.S[3], R8
	MOVW R8, a11+156(FP)
	RET

// One input feeds four output rows. Each accumulator keeps the scalar
// kernel's four lanes through the full block before applying its row scale.
#define ACCUMROW(lo, hi, acc) \
	VZIP1 lo, V5.H8, V17.H8; \
	VZIP2 lo, V5.H8, V18.H8; \
	VZIP1 hi, V5.H8, V19.H8; \
	VZIP2 hi, V5.H8, V20.H8; \
	VFMLA V17.S4, V24.S4, acc; \
	VFMLA V18.S4, V25.S4, acc; \
	VFMLA V19.S4, V26.S4, acc; \
	VFMLA V20.S4, V27.S4, acc

TEXT ·dotQ4FFNQuadNEON(SB), NOSPLIT, $0-88
	MOVD x_base+0(FP), R0
	MOVD x_len+8(FP), R10
	LSR $6, R10, R10             // blocks per row
	MOVD packed_base+24(FP), R1
	LSL $5, R10, R11             // packed row stride in bytes
	ADD R11, R1, R2
	ADD R11, R2, R3
	ADD R11, R3, R4
	MOVD scales_base+48(FP), R5
	LSL $2, R10, R11             // scale row stride in bytes
	ADD R11, R5, R6
	ADD R11, R6, R7
	ADD R11, R7, R8
	MOVD $q4FloatBytes<>(SB), R11
	VLD1 (R11), [V7.B16, V8.B16]
	VMOVI $15, V6.B16
	VEOR V5.B16, V5.B16, V5.B16
	VEOR V0.B16, V0.B16, V0.B16
	CBZ R10, quadDone

quadBlock:
	VEOR V1.B16, V1.B16, V1.B16
	VEOR V2.B16, V2.B16, V2.B16
	VEOR V3.B16, V3.B16, V3.B16
	VEOR V4.B16, V4.B16, V4.B16
	MOVD $4, R9
quadLanes:
	VLD1.P 64(R0), [V24.S4, V25.S4, V26.S4, V27.S4]
	DECODE16(R1, V13.B16, V14.B16)
	ACCUMROW(V13.H8, V14.H8, V1.S4)
	DECODE16(R2, V13.B16, V14.B16)
	ACCUMROW(V13.H8, V14.H8, V2.S4)
	DECODE16(R3, V13.B16, V14.B16)
	ACCUMROW(V13.H8, V14.H8, V3.S4)
	DECODE16(R4, V13.B16, V14.B16)
	ACCUMROW(V13.H8, V14.H8, V4.S4)
	SUB $1, R9
	CBNZ R9, quadLanes

	FADDP4(1, 1, 2)
	FADDP4(3, 3, 4)
	FADDP4(1, 1, 3)
	VLD1.P 4(R5), V9.S[0]
	VLD1.P 4(R6), V9.S[1]
	VLD1.P 4(R7), V9.S[2]
	VLD1.P 4(R8), V9.S[3]
	VFMLA V9.S4, V1.S4, V0.S4
	SUB $1, R10
	CBNZ R10, quadBlock

quadDone:
	VMOV V0.S[0], R11
	MOVW R11, a+72(FP)
	VMOV V0.S[1], R11
	MOVW R11, b+76(FP)
	VMOV V0.S[2], R11
	MOVW R11, c+80(FP)
	VMOV V0.S[3], R11
	MOVW R11, d+84(FP)
	RET

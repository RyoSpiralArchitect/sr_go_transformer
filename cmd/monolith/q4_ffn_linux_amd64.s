//go:build !purego

#include "textflag.h"

// A baseline amd64 binary must also run where the OS does not save YMM state.
TEXT ·q4HasAVX2(SB), NOSPLIT, $0-1
	MOVB $0, ret+0(FP)
	XORL AX, AX
	CPUID
	CMPL AX, $7
	JB unavailable
	MOVL $1, AX
	CPUID
	ANDL $0x18000000, CX // AVX and OSXSAVE
	CMPL CX, $0x18000000
	JNE unavailable
	XORL CX, CX
	XGETBV
	ANDL $6, AX
	CMPL AX, $6
	JNE unavailable
	MOVL $7, AX
	XORL CX, CX
	CPUID
	TESTL $32, BX // AVX2
	JE unavailable
	MOVB $1, ret+0(FP)
unavailable:
	RET

#ifdef GOAMD64_v3
#define MAY_FUSE
#endif
#ifdef GOAMD64_v4
#define MAY_FUSE
#endif

// Each 128-bit half holds the four scalar accumulation lanes of one output.
// Share the unpacked weights between both inputs with the compiler's scalar rounding.
#define UNFUSED() \
	VMULPS Y5, Y6, Y6; \
	VMULPS Y5, Y7, Y7; \
	VADDPS Y6, Y8, Y8; \
	VADDPS Y7, Y9, Y9

#define FUSED() \
	VFMADD231PS Y5, Y6, Y8; \
	VFMADD231PS Y5, Y7, Y9

#define ACCUM(offset, madd) \
	VPMOVSXBD X0, Y5; \
	VCVTDQ2PS Y5, Y5; \
	VBROADCASTF128 offset(AX), Y6; \
	VBROADCASTF128 offset(BX), Y7; \
	madd()

#define UNPACK_PAIR(p0, p1) \
	VMOVD (p0), X0; \
	VPINSRD $1, (p1), X0, X0; \
	VPSRLW $4, X0, X1; \
	VPAND X3, X0, X0; \
	VPAND X3, X1, X1; \
	VPUNPCKLBW X1, X0, X0; \
	VPXOR X4, X0, X0; \
	VPSUBB X4, X0, X0; \
	VPSHUFD $0xd8, X0, X0

#define EIGHT(madd) \
	UNPACK_PAIR(CX, DX); \
	ACCUM(0, madd); \
	VPSRLDQ $8, X0, X0; \
	ACCUM(16, madd); \
	ADDQ $32, AX; \
	ADDQ $32, BX; \
	ADDQ $4, CX; \
	ADDQ $4, DX

TEXT ·dotQ4FFNPairAVX2(SB), NOSPLIT, $0-160
	MOVQ x0_base+0(FP), AX
	MOVQ x1_base+24(FP), BX
	MOVQ w0_base+48(FP), CX
	MOVQ w1_base+72(FP), DX
	MOVQ s0_base+96(FP), SI
	MOVQ s1_base+120(FP), DI
	MOVQ s0_len+104(FP), R8
	MOVL $0x0f0f0f0f, R9
	VMOVD R9, X3
	VPSHUFD $0, X3, X3
	MOVL $0x08080808, R9
	VMOVD R9, X4
	VPSHUFD $0, X4, X4
	VXORPS Y10, Y10, Y10
	TESTQ R8, R8
	JZ done
block:
	VXORPS Y8, Y8, Y8
	VXORPS Y9, Y9, Y9
	MOVL $8, R9
#ifdef MAY_FUSE
	CMPB ·q4UseFMA(SB), $0
	JNE eightFused
#endif
eight:
	EIGHT(UNFUSED)
	DECL R9
	JNZ eight
#ifdef MAY_FUSE
	JMP reduce
eightFused:
	EIGHT(FUSED)
	DECL R9
	JNZ eightFused
reduce:
#endif

	VHADDPS Y9, Y8, Y0
	VHADDPS Y0, Y0, Y0
	VBROADCASTSS (SI), X1
	VBROADCASTSS (DI), X2
	VINSERTF128 $1, X2, Y1, Y1
#ifdef MAY_FUSE
	CMPB ·q4UseFMA(SB), $0
	JE separateScale
	VFMADD231PS Y1, Y0, Y10
	JMP nextBlock
separateScale:
#endif
	VMULPS Y1, Y0, Y0
	VADDPS Y0, Y10, Y10
#ifdef MAY_FUSE
nextBlock:
#endif
	ADDQ $4, SI
	ADDQ $4, DI
	DECQ R8
	JNZ block
done:
	VEXTRACTF128 $1, Y10, X1
	VMOVSS X10, a00+144(FP)
	VMOVSS X1, a01+148(FP)
	VEXTRACTPS $1, X10, a10+152(FP)
	VEXTRACTPS $1, X1, a11+156(FP)
	VZEROUPPER
	RET

// Each YMM accumulator holds four reduction lanes for each of two output
// rows. Broadcast each four-float input once and reuse it for both pairs.
#define QUAD_MUL_ADD(x, w, acc) \
	VMULPS x, w, w; \
	VADDPS w, acc, acc

#define QUAD_FMA(x, w, acc) VFMADD231PS x, w, acc

#define QUAD_PAIR(p0, p1, acc, madd) \
	UNPACK_PAIR(p0, p1); \
	VPMOVSXBD X0, Y5; \
	VCVTDQ2PS Y5, Y5; \
	madd(Y11, Y5, acc); \
	VPSRLDQ $8, X0, X0; \
	VPMOVSXBD X0, Y5; \
	VCVTDQ2PS Y5, Y5; \
	madd(Y12, Y5, acc)

#define QUAD_EIGHT(madd) \
	VBROADCASTF128 (AX), Y11; \
	VBROADCASTF128 16(AX), Y12; \
	QUAD_PAIR(CX, DX, Y8, madd); \
	QUAD_PAIR(SI, DI, Y9, madd); \
	ADDQ $32, AX; \
	ADDQ $4, CX; \
	ADDQ $4, DX; \
	ADDQ $4, SI; \
	ADDQ $4, DI

TEXT ·dotQ4QuadAVX2(SB), NOSPLIT, $0-88
	MOVQ x_base+0(FP), AX
	MOVQ x_len+8(FP), R9
	SHRQ $6, R9                 // blocks per output row
	MOVQ packed_base+24(FP), CX
	MOVQ R9, R10
	SHLQ $5, R10
	LEAQ (CX)(R10*1), DX
	LEAQ (DX)(R10*1), SI
	LEAQ (SI)(R10*1), DI
	MOVQ scales_base+48(FP), R8
	LEAQ 0(R9*4), R10           // scale row stride in bytes
	LEAQ (R8)(R10*2), R11       // scale pointer for row 2
	MOVL $0x0f0f0f0f, R12
	VMOVD R12, X3
	VPSHUFD $0, X3, X3
	MOVL $0x08080808, R12
	VMOVD R12, X4
	VPSHUFD $0, X4, X4
	VXORPS X10, X10, X10
	TESTQ R9, R9
	JZ quadDone
quadBlock:
	VXORPS Y8, Y8, Y8
	VXORPS Y9, Y9, Y9
	MOVL $8, R12
#ifdef MAY_FUSE
	CMPB ·q4UseFMA(SB), $0
	JNE quadEightFused
#endif
quadEight:
	QUAD_EIGHT(QUAD_MUL_ADD)
	DECL R12
	JNZ quadEight
#ifdef MAY_FUSE
	JMP quadReduce
quadEightFused:
	QUAD_EIGHT(QUAD_FMA)
	DECL R12
	JNZ quadEightFused
quadReduce:
#endif
	// Lower 128 bits reduce rows 0 and 2, upper bits reduce rows 1 and 3.
	VHADDPS Y9, Y8, Y0
	VHADDPS Y0, Y0, Y0
	VEXTRACTF128 $1, Y0, X1
	VUNPCKLPS X1, X0, X0
	VMOVSS (R8), X1
	VPINSRD $1, (R8)(R10*1), X1, X1
	VPINSRD $2, (R11), X1, X1
	VPINSRD $3, (R11)(R10*1), X1, X1
	// The portable Linux one-row pair path rounds each scaled block
	// before accumulating it, even when the inner dot uses FMA.
	VMULPS X1, X0, X0
	VADDPS X0, X10, X10
	ADDQ $4, R8
	ADDQ $4, R11
	DECQ R9
	JNZ quadBlock
quadDone:
	VMOVSS X10, a+72(FP)
	VEXTRACTPS $1, X10, b+76(FP)
	VEXTRACTPS $2, X10, c+80(FP)
	VEXTRACTPS $3, X10, d+84(FP)
	VZEROUPPER
	RET

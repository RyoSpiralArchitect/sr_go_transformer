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

#define EIGHT(madd) \
	VMOVD (CX), X0; \
	VPINSRD $1, (DX), X0, X0; \
	VPSRLW $4, X0, X1; \
	VPAND X3, X0, X0; \
	VPAND X3, X1, X1; \
	VPUNPCKLBW X1, X0, X0; \
	VPXOR X4, X0, X0; \
	VPSUBB X4, X0, X0; \
	VPSHUFD $0xd8, X0, X0; \
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

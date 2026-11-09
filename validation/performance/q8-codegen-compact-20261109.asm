TEXT github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.newQ8CodegenProbe.func1(SB) /Users/ryohiga/SpiralReality/sr_go_transformer/cmd/monolith/q8_codegen_test.go
  q8_codegen_test.go:17		0x100444b00		f9400b90		MOVD 16(R28), R16										
  q8_codegen_test.go:17		0x100444b04		d102c3f1		SUB $176, RSP, R17										
  q8_codegen_test.go:17		0x100444b08		eb10023f		CMP R16, R17											
  q8_codegen_test.go:17		0x100444b0c		54005629		BLS 689(PC)											
  q8_codegen_test.go:17		0x100444b10		d104c3f4		SUB $304, RSP, R20										
  q8_codegen_test.go:17		0x100444b14		a93ffa9d		STP (R29, R30), -8(R20)										
  q8_codegen_test.go:17		0x100444b18		9100029f		MOVD R20, RSP											
  q8_codegen_test.go:17		0x100444b1c		d10023fd		SUB $8, RSP, R29										
  q8_codegen_test.go:21		0x100444b20		f900a3e1		MOVD R1, 320(RSP)										
  q8_codegen_test.go:17		0x100444b24		f9400743		MOVD 8(R26), R3											
  q8_codegen_test.go:18		0x100444b28		a9419464		LDP 24(R3), (R4, R5)										
  q8_codegen_test.go:18		0x100444b2c		f9007be5		MOVD R5, 240(RSP)										
  q8_codegen_test.go:18		0x100444b30		f90037e4		MOVD R4, 104(RSP)										
  q8_codegen_test.go:18		0x100444b34		a9439c66		LDP 56(R3), (R6, R7)										
  q8_codegen_test.go:18		0x100444b38		f9008fe6		MOVD R6, 280(RSP)										
  q8_codegen_test.go:18		0x100444b3c		f90057e7		MOVD R7, 168(RSP)										
  q8_codegen_test.go:19		0x100444b40		a94124c8		LDP 16(R6), (R8, R9)										
  q8_codegen_test.go:19		0x100444b44		f9005be9		MOVD R9, 176(RSP)										
  q8_codegen_test.go:19		0x100444b48		f9004be8		MOVD R8, 144(RSP)										
  q8_codegen_test.go:20		0x100444b4c		9100fd2a		ADD $63, R9, R10										
  q8_codegen_test.go:20		0x100444b50		937ffd4a		ASR $63, R10, R10										
  q8_codegen_test.go:20		0x100444b54		8b4ae92a		ADD R10>>58, R9, R10										
  q8_codegen_test.go:20		0x100444b58		9100fd4a		ADD $63, R10, R10										
  q8_codegen_test.go:20		0x100444b5c		f90077ea		MOVD R10, 232(RSP)										
  q8_codegen_test.go:20		0x100444b60		91007d0b		ADD $31, R8, R11										
  q8_codegen_test.go:20		0x100444b64		937ffd6b		ASR $63, R11, R11										
  q8_codegen_test.go:20		0x100444b68		8b4bed0b		ADD R11>>59, R8, R11										
  q8_codegen_test.go:20		0x100444b6c		91007d6b		ADD $31, R11, R11										
  q8_codegen_test.go:18		0x100444b70		f940146c		MOVD 40(R3), R12										
  q8_codegen_test.go:18		0x100444b74		f90027ec		MOVD R12, 72(RSP)										
  q8_codegen_test.go:18		0x100444b78		f9400463		MOVD 8(R3), R3											
  q8_codegen_test.go:18		0x100444b7c		f90087e3		MOVD R3, 264(RSP)										
  q8_codegen_test.go:20		0x100444b80		9346fd4d		ASR $6, R10, R13										
  q8_codegen_test.go:20		0x100444b84		f9005fed		MOVD R13, 184(RSP)										
  q8_codegen_test.go:20		0x100444b88		9345fd6b		ASR $5, R11, R11										
  q8_codegen_test.go:20		0x100444b8c		f9003feb		MOVD R11, 120(RSP)										
  q8_codegen_test.go:21		0x100444b90		14000002		JMP 2(PC)											
  q8_codegen_test.go:21		0x100444b94		91000400		ADD $1, R0, R0											
  q8_codegen_test.go:21		0x100444b98		eb00003f		CMP R0, R1											
  q8_codegen_test.go:21		0x100444b9c		54001b6d		BLE 219(PC)											
  q8_codegen_test.go:22		0x100444ba0		b400514b		CBZ R11, 650(PC)										
  q8_codegen_test.go:21		0x100444ba4		f90043e0		MOVD R0, 128(RSP)										
  q8_codegen_test.go:22		0x100444ba8		9acb0c0e		SDIV R11, R0, R14										
  q8_codegen_test.go:22		0x100444bac		f90073ee		MOVD R14, 224(RSP)										
  q8_codegen_test.go:22		0x100444bb0		9acb0c1b		SDIV R11, R0, R27										
  q8_codegen_test.go:22		0x100444bb4		9b0b836f		MSUB R11, R0, R27, R15										
  q8_codegen_test.go:22		0x100444bb8		d37ef5d0		LSL $2, R14, R16										
  q8_codegen_test.go:22		0x100444bbc		f90047f0		MOVD R16, 136(RSP)										
  q8_codegen_test.go:22		0x100444bc0		d37be9ef		LSL $5, R15, R15										
  q8_codegen_test.go:22		0x100444bc4		f9004fef		MOVD R15, 152(RSP)										
  q8_codegen_test.go:22		0x100444bc8		aa0f03e2		MOVD R15, R2											
  q8_codegen_test.go:23		0x100444bcc		14000003		JMP 3(PC)											
  q8_codegen_test.go:26		0x100444bd0		aa1303f0		MOVD R19, R16											
  q8_codegen_test.go:23		0x100444bd4		aa1403ef		MOVD R20, R15											
  q8_codegen_test.go:23		0x100444bd8		91008051		ADD $32, R2, R17										
  q8_codegen_test.go:23		0x100444bdc		eb11011f		CMP R17, R8											
  q8_codegen_test.go:23		0x100444be0		9a91b111		CSEL LT, R8, R17, R17										
  q8_codegen_test.go:23		0x100444be4		eb1101ff		CMP R17, R15											
  q8_codegen_test.go:23		0x100444be8		54fffd6a		BGE -21(PC)											
  q8_codegen_test.go:24		0x100444bec		f94044d1		MOVD 136(R6), R17										
  q8_codegen_test.go:24		0x100444bf0		f9400a33		MOVD 16(R17), R19										
  q8_codegen_test.go:24		0x100444bf4		910005f4		ADD $1, R15, R20										
  q8_codegen_test.go:24		0x100444bf8		9b097e95		MUL R9, R20, R21										
  q8_codegen_test.go:24		0x100444bfc		9b097df6		MUL R9, R15, R22										
  q8_codegen_test.go:24		0x100444c00		eb15027f		CMP R21, R19											
  q8_codegen_test.go:24		0x100444c04		54004dc3		BCC 622(PC)											
  q8_codegen_test.go:24		0x100444c08		eb1602bf		CMP R22, R21											
  q8_codegen_test.go:24		0x100444c0c		54004d23		BCC 617(PC)											
  q8_codegen_test.go:24		0x100444c10		f9400235		MOVD (R17), R21											
  q8_codegen_test.go:24		0x100444c14		cb1302d7		SUB R19, R22, R23										
  q8_codegen_test.go:24		0x100444c18		8a97fed7		AND R23->63, R22, R23										
  q8_codegen_test.go:25		0x100444c1c		f9401638		MOVD 40(R17), R24										
  q8_codegen_test.go:25		0x100444c20		9b0d7e99		MUL R13, R20, R25										
  q8_codegen_test.go:24		0x100444c24		8b1702b5		ADD R23, R21, R21										
  q8_codegen_test.go:24		0x100444c28		cb160273		SUB R22, R19, R19										
  q8_codegen_test.go:25		0x100444c2c		9b0d7df6		MUL R13, R15, R22										
  q8_codegen_test.go:25		0x100444c30		eb19031f		CMP R25, R24											
  q8_codegen_test.go:25		0x100444c34		54004b83		BCC 604(PC)											
  q8_codegen_test.go:25		0x100444c38		eb16033f		CMP R22, R25											
  q8_codegen_test.go:25		0x100444c3c		54004ae3		BCC 599(PC)											
  q8_codegen_test.go:24		0x100444c40		f9006ff4		MOVD R20, 216(RSP)										
  q8_codegen_test.go:25		0x100444c44		f9400e31		MOVD 24(R17), R17										
  q8_codegen_test.go:25		0x100444c48		cb1802d7		SUB R24, R22, R23										
  q8_codegen_test.go:25		0x100444c4c		8a97fed6		AND R23->63, R22, R22										
  q8_codegen_test.go:26		0x100444c50		91001217		ADD $4, R16, R23										
  q8_codegen_test.go:25		0x100444c54		8b160a31		ADD R22<<2, R17, R17										
  q8_codegen_test.go:26		0x100444c58		eb1700ff		CMP R23, R7											
  q8_codegen_test.go:26		0x100444c5c		540005eb		BLT 47(PC)											
  q8_codegen_test.go:27		0x100444c60		91000613		ADD $1, R16, R19										
  q8_codegen_test.go:27		0x100444c64		9b137d36		MUL R19, R9, R22										
  q8_codegen_test.go:27		0x100444c68		9b097dd8		MUL R9, R14, R24										
  q8_codegen_test.go:27		0x100444c6c		eb16009f		CMP R22, R4											
  q8_codegen_test.go:27		0x100444c70		54004903		BCC 584(PC)											
  q8_codegen_test.go:27		0x100444c74		eb180adf		CMP R24<<2, R22											
  q8_codegen_test.go:27		0x100444c78		54004863		BCC 579(PC)											
  q8_codegen_test.go:27		0x100444c7c		cb180899		SUB R24<<2, R4, R25										
  q8_codegen_test.go:27		0x100444c80		cb1903f9		NEG R25, R25											
  q8_codegen_test.go:27		0x100444c84		8a99ff19		AND R25->63, R24, R25										
  q8_codegen_test.go:27		0x100444c88		91000a1a		ADD $2, R16, R26										
  q8_codegen_test.go:27		0x100444c8c		9b1a7d3e		MUL R26, R9, R30										
  q8_codegen_test.go:27		0x100444c90		cb180ad8		SUB R24<<2, R22, R24										
  q8_codegen_test.go:27		0x100444c94		8b191079		ADD R25<<4, R3, R25										
  q8_codegen_test.go:27		0x100444c98		eb1e009f		CMP R30, R4											
  q8_codegen_test.go:27		0x100444c9c		54004703		BCC 568(PC)											
  q8_codegen_test.go:27		0x100444ca0		eb1603df		CMP R22, R30											
  q8_codegen_test.go:27		0x100444ca4		54004663		BCC 563(PC)											
  q8_codegen_test.go:27		0x100444ca8		cb0402cb		SUB R4, R22, R11										
  q8_codegen_test.go:27		0x100444cac		8a8bfecb		AND R11->63, R22, R11										
  q8_codegen_test.go:28		0x100444cb0		91000e16		ADD $3, R16, R22										
  q8_codegen_test.go:28		0x100444cb4		9b097ec1		MUL R9, R22, R1											
  q8_codegen_test.go:27		0x100444cb8		8b0b086b		ADD R11<<2, R3, R11										
  q8_codegen_test.go:28		0x100444cbc		eb01009f		CMP R1, R4											
  q8_codegen_test.go:28		0x100444cc0		54004563		BCC 555(PC)											
  q8_codegen_test.go:28		0x100444cc4		eb1e003f		CMP R30, R1											
  q8_codegen_test.go:28		0x100444cc8		540044e3		BCC 551(PC)											
  q8_codegen_test.go:28		0x100444ccc		cb0403c0		SUB R4, R30, R0											
  q8_codegen_test.go:28		0x100444cd0		8a80ffde		AND R0->63, R30, R30										
  q8_codegen_test.go:28		0x100444cd4		9b097ef7		MUL R9, R23, R23										
  q8_codegen_test.go:28		0x100444cd8		8b1e087e		ADD R30<<2, R3, R30										
  q8_codegen_test.go:28		0x100444cdc		eb17009f		CMP R23, R4											
  q8_codegen_test.go:28		0x100444ce0		540043e3		BCC 543(PC)											
  q8_codegen_test.go:28		0x100444ce4		eb0102ff		CMP R1, R23											
  q8_codegen_test.go:28		0x100444ce8		54004363		BCC 539(PC)											
  q8_codegen_test.go:28		0x100444cec		f9006bf6		MOVD R22, 208(RSP)										
  q8_codegen_test.go:28		0x100444cf0		cb040037		SUB R4, R1, R23											
  q8_codegen_test.go:28		0x100444cf4		8a97fc37		AND R23->63, R1, R23										
  q8_codegen_test.go:28		0x100444cf8		8b170877		ADD R23<<2, R3, R23										
  q8_codegen_test.go:18		0x100444cfc		aa0303e0		MOVD R3, R0											
  q8_codegen_test.go:30		0x100444d00		aa1f03e3		MOVD ZR, R3											
  q8_codegen_test.go:30		0x100444d04		1e2703e0		FMOVS ZR, F0											
  q8_codegen_test.go:30		0x100444d08		1e2703e1		FMOVS ZR, F1											
  q8_codegen_test.go:30		0x100444d0c		1e2703e2		FMOVS ZR, F2											
  q8_codegen_test.go:30		0x100444d10		1e2703e3		FMOVS ZR, F3											
  q8_codegen_test.go:30		0x100444d14		1400015b		JMP 347(PC)											
  q8_codegen_test.go:69		0x100444d18		91000a16		ADD $2, R16, R22										
  q8_codegen_test.go:69		0x100444d1c		eb1600ff		CMP R22, R7											
  q8_codegen_test.go:69		0x100444d20		540004ab		BLT 37(PC)											
  q8_codegen_test.go:70		0x100444d24		91000617		ADD $1, R16, R23										
  q8_codegen_test.go:70		0x100444d28		9b177d38		MUL R23, R9, R24										
  q8_codegen_test.go:70		0x100444d2c		9b097dd9		MUL R9, R14, R25										
  q8_codegen_test.go:70		0x100444d30		eb18009f		CMP R24, R4											
  q8_codegen_test.go:70		0x100444d34		54002943		BCC 330(PC)											
  q8_codegen_test.go:70		0x100444d38		eb190b1f		CMP R25<<2, R24											
  q8_codegen_test.go:70		0x100444d3c		540028a3		BCC 325(PC)											
  q8_codegen_test.go:70		0x100444d40		cb19089a		SUB R25<<2, R4, R26										
  q8_codegen_test.go:70		0x100444d44		cb1a03fe		NEG R26, R30											
  q8_codegen_test.go:70		0x100444d48		8a9eff3e		AND R30->63, R25, R30										
  q8_codegen_test.go:70		0x100444d4c		9b167d2b		MUL R22, R9, R11										
  q8_codegen_test.go:70		0x100444d50		cb190b19		SUB R25<<2, R24, R25										
  q8_codegen_test.go:70		0x100444d54		8b1e107e		ADD R30<<4, R3, R30										
  q8_codegen_test.go:70		0x100444d58		eb0b009f		CMP R11, R4											
  q8_codegen_test.go:70		0x100444d5c		54002783		BCC 316(PC)											
  q8_codegen_test.go:70		0x100444d60		eb18017f		CMP R24, R11											
  q8_codegen_test.go:70		0x100444d64		54002703		BCC 312(PC)											
  q8_codegen_test.go:24		0x100444d68		f9003bf3		MOVD R19, 112(RSP)										
  q8_codegen_test.go:24		0x100444d6c		f9008bf5		MOVD R21, 272(RSP)										
  q8_codegen_test.go:25		0x100444d70		f90093f1		MOVD R17, 288(RSP)										
  q8_codegen_test.go:69		0x100444d74		f9006bf6		MOVD R22, 208(RSP)										
  q8_codegen_test.go:70		0x100444d78		f90067f7		MOVD R23, 200(RSP)										
  q8_codegen_test.go:70		0x100444d7c		f9002ff9		MOVD R25, 88(RSP)										
  q8_codegen_test.go:70		0x100444d80		f90033fa		MOVD R26, 96(RSP)										
  q8_codegen_test.go:70		0x100444d84		f90083fe		MOVD R30, 256(RSP)										
  q8_codegen_test.go:23		0x100444d88		f90053ef		MOVD R15, 160(RSP)										
  q8_codegen_test.go:70		0x100444d8c		cb04030b		SUB R4, R24, R11										
  q8_codegen_test.go:70		0x100444d90		8a8bff0b		AND R11->63, R24, R11										
  q8_codegen_test.go:70		0x100444d94		8b0b086b		ADD R11<<2, R3, R11										
  q8_codegen_test.go:70		0x100444d98		f9007feb		MOVD R11, 248(RSP)										
  q8_codegen_test.go:70		0x100444d9c		cb180098		SUB R24, R4, R24										
  q8_codegen_test.go:70		0x100444da0		f9002bf8		MOVD R24, 80(RSP)										
  q8_codegen_test.go:72		0x100444da4		aa1f03f0		MOVD ZR, R16											
  q8_codegen_test.go:72		0x100444da8		1e2703e0		FMOVS ZR, F0											
  q8_codegen_test.go:72		0x100444dac		1e2703e1		FMOVS ZR, F1											
  q8_codegen_test.go:72		0x100444db0		14000082		JMP 130(PC)											
  q8_codegen_test.go:22		0x100444db4		aa1003f3		MOVD R16, R19											
  q8_codegen_test.go:69		0x100444db8		14000003		JMP 3(PC)											
  q8_codegen_test.go:122	0x100444dbc		bc3078a0		FMOVS F0, (R5)(R16<<2)										
  q8_codegen_test.go:104	0x100444dc0		aa1603f0		MOVD R22, R16											
  q8_codegen_test.go:104	0x100444dc4		eb07021f		CMP R7, R16											
  q8_codegen_test.go:104	0x100444dc8		54fff04a		BGE -126(PC)											
  q8_codegen_test.go:105	0x100444dcc		91000616		ADD $1, R16, R22										
  q8_codegen_test.go:105	0x100444dd0		9b097ed7		MUL R9, R22, R23										
  q8_codegen_test.go:105	0x100444dd4		9b097e18		MUL R9, R16, R24										
  q8_codegen_test.go:105	0x100444dd8		eb17009f		CMP R23, R4											
  q8_codegen_test.go:105	0x100444ddc		54000b43		BCC 90(PC)											
  q8_codegen_test.go:105	0x100444de0		eb1802ff		CMP R24, R23											
  q8_codegen_test.go:105	0x100444de4		54000aa3		BCC 85(PC)											
  q8_codegen_test.go:105	0x100444de8		cb040317		SUB R4, R24, R23										
  q8_codegen_test.go:105	0x100444dec		8a97ff17		AND R23->63, R24, R23										
  q8_codegen_test.go:105	0x100444df0		8b170877		ADD R23<<2, R3, R23										
  q8_codegen_test.go:107	0x100444df4		aa1f03f8		MOVD ZR, R24											
  q8_codegen_test.go:107	0x100444df8		1e2703e0		FMOVS ZR, F0											
  q8_codegen_test.go:107	0x100444dfc		14000003		JMP 3(PC)											
  q8_codegen_test.go:120	0x100444e00		1f020020		FMADDS F2, F0, F1, F0										
  q8_codegen_test.go:107	0x100444e04		aa1903f8		MOVD R25, R24											
  q8_codegen_test.go:107	0x100444e08		eb8a1b1f		CMP R10->6, R24											
  q8_codegen_test.go:107	0x100444e0c		5400076a		BGE 59(PC)											
  q8_codegen_test.go:108	0x100444e10		91000719		ADD $1, R24, R25										
  q8_codegen_test.go:108	0x100444e14		d37ae73a		LSL $6, R25, R26										
  q8_codegen_test.go:107	0x100444e18		bc787a21		FMOVS (R17)(R24<<2), F1										
  q8_codegen_test.go:108	0x100444e1c		d37ae718		LSL $6, R24, R24										
  q8_codegen_test.go:108	0x100444e20		eb19193f		CMP R25<<6, R9											
  q8_codegen_test.go:108	0x100444e24		9a9ab13a		CSEL LT, R9, R26, R26										
  q8_codegen_test.go:108	0x100444e28		1e2703e2		FMOVS ZR, F2											
  q8_codegen_test.go:108	0x100444e2c		1e2703e3		FMOVS ZR, F3											
  q8_codegen_test.go:108	0x100444e30		1e2703e4		FMOVS ZR, F4											
  q8_codegen_test.go:108	0x100444e34		1e2703e5		FMOVS ZR, F5											
  q8_codegen_test.go:108	0x100444e38		14000007		JMP 7(PC)											
  q8_codegen_test.go:114	0x100444e3c		bc6b7ae6		FMOVS (R23)(R11<<2), F6										
  q8_codegen_test.go:114	0x100444e40		38ab6aab		MOVB (R21)(R11), R11										
  q8_codegen_test.go:114	0x100444e44		1e220167		SCVTFWS R11, F7											
  q8_codegen_test.go:114	0x100444e48		1f0708c2		FMADDS F7, F2, F6, F2										
  q8_codegen_test.go:22		0x100444e4c		f9403feb		MOVD 120(RSP), R11										
  q8_codegen_test.go:110	0x100444e50		aa1e03f8		MOVD R30, R24											
  q8_codegen_test.go:110	0x100444e54		9100131e		ADD $4, R24, R30										
  q8_codegen_test.go:110	0x100444e58		eb1e035f		CMP R30, R26											
  q8_codegen_test.go:110	0x100444e5c		5400032b		BLT 25(PC)											
  q8_codegen_test.go:111	0x100444e60		eb09031f		CMP R9, R24											
  q8_codegen_test.go:111	0x100444e64		54000662		BCS 51(PC)											
  q8_codegen_test.go:111	0x100444e68		bc787ae6		FMOVS (R23)(R24<<2), F6										
  q8_codegen_test.go:111	0x100444e6c		38b86aab		MOVB (R21)(R24), R11										
  q8_codegen_test.go:111	0x100444e70		1e220167		SCVTFWS R11, F7											
  q8_codegen_test.go:112	0x100444e74		9100070b		ADD $1, R24, R11										
  q8_codegen_test.go:111	0x100444e78		1f0710c4		FMADDS F7, F4, F6, F4										
  q8_codegen_test.go:112	0x100444e7c		eb0b013f		CMP R11, R9											
  q8_codegen_test.go:112	0x100444e80		54000569		BLS 43(PC)											
  q8_codegen_test.go:112	0x100444e84		bc6b7ae6		FMOVS (R23)(R11<<2), F6										
  q8_codegen_test.go:112	0x100444e88		38ab6aab		MOVB (R21)(R11), R11										
  q8_codegen_test.go:112	0x100444e8c		1e220167		SCVTFWS R11, F7											
  q8_codegen_test.go:113	0x100444e90		91000b0b		ADD $2, R24, R11										
  q8_codegen_test.go:112	0x100444e94		1f0714c5		FMADDS F7, F5, F6, F5										
  q8_codegen_test.go:113	0x100444e98		eb0b013f		CMP R11, R9											
  q8_codegen_test.go:113	0x100444e9c		54000469		BLS 35(PC)											
  q8_codegen_test.go:113	0x100444ea0		bc6b7ae6		FMOVS (R23)(R11<<2), F6										
  q8_codegen_test.go:113	0x100444ea4		38ab6aab		MOVB (R21)(R11), R11										
  q8_codegen_test.go:113	0x100444ea8		1e220167		SCVTFWS R11, F7											
  q8_codegen_test.go:114	0x100444eac		91000f0b		ADD $3, R24, R11										
  q8_codegen_test.go:113	0x100444eb0		1f070cc3		FMADDS F7, F3, F6, F3										
  q8_codegen_test.go:114	0x100444eb4		eb0b013f		CMP R11, R9											
  q8_codegen_test.go:114	0x100444eb8		54fffc28		BHI -31(PC)											
  q8_codegen_test.go:114	0x100444ebc		1400001a		JMP 26(PC)											
  q8_codegen_test.go:116	0x100444ec0		1e252884		FADDS F5, F4, F4										
  q8_codegen_test.go:116	0x100444ec4		1e222862		FADDS F2, F3, F2										
  q8_codegen_test.go:116	0x100444ec8		1e222882		FADDS F2, F4, F2										
  q8_codegen_test.go:117	0x100444ecc		14000006		JMP 6(PC)											
  q8_codegen_test.go:118	0x100444ed0		bc787ae3		FMOVS (R23)(R24<<2), F3										
  q8_codegen_test.go:118	0x100444ed4		38b86abe		MOVB (R21)(R24), R30										
  q8_codegen_test.go:118	0x100444ed8		1e2203c4		SCVTFWS R30, F4											
  q8_codegen_test.go:118	0x100444edc		1f040862		FMADDS F4, F2, F3, F2										
  q8_codegen_test.go:117	0x100444ee0		91000718		ADD $1, R24, R24										
  q8_codegen_test.go:117	0x100444ee4		eb1a031f		CMP R26, R24											
  q8_codegen_test.go:117	0x100444ee8		54fff8ca		BGE -58(PC)											
  q8_codegen_test.go:118	0x100444eec		eb09031f		CMP R9, R24											
  q8_codegen_test.go:118	0x100444ef0		54ffff03		BCC -8(PC)											
  q8_codegen_test.go:118	0x100444ef4		1400000a		JMP 10(PC)											
  q8_codegen_test.go:122	0x100444ef8		9b103d10		MADD R16, R15, R8, R16										
  q8_codegen_test.go:122	0x100444efc		eb10019f		CMP R16, R12											
  q8_codegen_test.go:122	0x100444f00		54fff5e8		BHI -81(PC)											
  q8_codegen_test.go:122	0x100444f04		14000004		JMP 4(PC)											
  q8_codegen_test.go:127	0x100444f08		a97ffbfd		LDP -8(RSP), (R29, R30)										
  q8_codegen_test.go:127	0x100444f0c		9104c3ff		ADD $304, RSP, RSP										
  q8_codegen_test.go:127	0x100444f10		d65f03c0		RET												
  q8_codegen_test.go:122	0x100444f14		aa1003e0		MOVD R16, R0											
  q8_codegen_test.go:122	0x100444f18		97f1162a		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:118	0x100444f1c		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:118	0x100444f20		97f11628		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:114	0x100444f24		97f11627		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:113	0x100444f28		97f11626		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:112	0x100444f2c		97f11625		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:111	0x100444f30		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:111	0x100444f34		97f11623		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:105	0x100444f38		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:105	0x100444f3c		aa1703e1		MOVD R23, R1											
  q8_codegen_test.go:105	0x100444f40		97f11620		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:105	0x100444f44		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:105	0x100444f48		97f1161e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:21		0x100444f4c		f94043e0		MOVD 128(RSP), R0										
  q8_codegen_test.go:21		0x100444f50		f940a3e1		MOVD 320(RSP), R1										
  q8_codegen_test.go:23		0x100444f54		f9404fe2		MOVD 152(RSP), R2										
  q8_codegen_test.go:105	0x100444f58		f94087e3		MOVD 264(RSP), R3										
  q8_codegen_test.go:105	0x100444f5c		f94037e4		MOVD 104(RSP), R4										
  q8_codegen_test.go:101	0x100444f60		f9407be5		MOVD 240(RSP), R5										
  q8_codegen_test.go:24		0x100444f64		f9408fe6		MOVD 280(RSP), R6										
  q8_codegen_test.go:104	0x100444f68		f94057e7		MOVD 168(RSP), R7										
  q8_codegen_test.go:101	0x100444f6c		f9404be8		MOVD 144(RSP), R8										
  q8_codegen_test.go:73		0x100444f70		f9405be9		MOVD 176(RSP), R9										
  q8_codegen_test.go:72		0x100444f74		f94077ea		MOVD 232(RSP), R10										
  q8_codegen_test.go:87		0x100444f78		f9407feb		MOVD 248(RSP), R11										
  q8_codegen_test.go:101	0x100444f7c		f94027ec		MOVD 72(RSP), R12										
  q8_codegen_test.go:25		0x100444f80		f9405fed		MOVD 184(RSP), R13										
  q8_codegen_test.go:101	0x100444f84		f94073ee		MOVD 224(RSP), R14										
  q8_codegen_test.go:101	0x100444f88		f94053ef		MOVD 160(RSP), R15										
  q8_codegen_test.go:72		0x100444f8c		f94093f1		MOVD 288(RSP), R17										
  q8_codegen_test.go:75		0x100444f90		f9403bf3		MOVD 112(RSP), R19										
  q8_codegen_test.go:23		0x100444f94		f9406ff4		MOVD 216(RSP), R20										
  q8_codegen_test.go:82		0x100444f98		f9408bf5		MOVD 272(RSP), R21										
  q8_codegen_test.go:104	0x100444f9c		f9406bf6		MOVD 208(RSP), R22										
  q8_codegen_test.go:101	0x100444fa0		f94067f7		MOVD 200(RSP), R23										
  q8_codegen_test.go:75		0x100444fa4		f9402bf8		MOVD 80(RSP), R24										
  q8_codegen_test.go:83		0x100444fa8		f9402ff9		MOVD 88(RSP), R25										
  q8_codegen_test.go:75		0x100444fac		f94033fa		MOVD 96(RSP), R26										
  q8_codegen_test.go:83		0x100444fb0		f94083fe		MOVD 256(RSP), R30										
  q8_codegen_test.go:72		0x100444fb4		f94063f0		MOVD 192(RSP), R16										
  q8_codegen_test.go:72		0x100444fb8		eb8a1a1f		CMP R10->6, R16											
  q8_codegen_test.go:72		0x100444fbc		5400056a		BGE 43(PC)											
  q8_codegen_test.go:73		0x100444fc0		91000601		ADD $1, R16, R1											
  q8_codegen_test.go:73		0x100444fc4		f90063e1		MOVD R1, 192(RSP)										
  q8_codegen_test.go:73		0x100444fc8		d37ae420		LSL $6, R1, R0											
  q8_codegen_test.go:72		0x100444fcc		bc707a22		FMOVS (R17)(R16<<2), F2										
  q8_codegen_test.go:73		0x100444fd0		d37ae60d		LSL $6, R16, R13										
  q8_codegen_test.go:73		0x100444fd4		eb01193f		CMP R1<<6, R9											
  q8_codegen_test.go:73		0x100444fd8		9a80b120		CSEL LT, R9, R0, R0										
  q8_codegen_test.go:74		0x100444fdc		cb101806		SUB R16<<6, R0, R6										
  q8_codegen_test.go:74		0x100444fe0		f10100df		CMP $64, R6											
  q8_codegen_test.go:73		0x100444fe4		54000140		BEQ 10(PC)											
  q8_codegen_test.go:74		0x100444fe8		1e2703e3		FMOVS ZR, F3											
  q8_codegen_test.go:74		0x100444fec		1e2703e4		FMOVS ZR, F4											
  q8_codegen_test.go:74		0x100444ff0		1e2703e5		FMOVS ZR, F5											
  q8_codegen_test.go:74		0x100444ff4		1e2703e6		FMOVS ZR, F6											
  q8_codegen_test.go:74		0x100444ff8		1e2703e7		FMOVS ZR, F7											
  q8_codegen_test.go:74		0x100444ffc		1e2703e8		FMOVS ZR, F8											
  q8_codegen_test.go:74		0x100445000		1e2703e9		FMOVS ZR, F9											
  q8_codegen_test.go:74		0x100445004		1e2703ea		FMOVS ZR, F10											
  q8_codegen_test.go:74		0x100445008		14000040		JMP 64(PC)											
  q8_codegen_test.go:75		0x10044500c		eb1a001f		CMP R26, R0											
  q8_codegen_test.go:75		0x100445010		54000548		BHI 42(PC)											
  q8_codegen_test.go:75		0x100445014		eb10181f		CMP R16<<6, R0											
  q8_codegen_test.go:75		0x100445018		540004e3		BCC 39(PC)											
  q8_codegen_test.go:75		0x10044501c		8b1023c6		ADD R16<<8, R30, R6										
  q8_codegen_test.go:75		0x100445020		eb18001f		CMP R24, R0											
  q8_codegen_test.go:75		0x100445024		54000448		BHI 34(PC)											
  q8_codegen_test.go:75		0x100445028		8b10216d		ADD R16<<8, R11, R13										
  q8_codegen_test.go:75		0x10044502c		eb13001f		CMP R19, R0											
  q8_codegen_test.go:75		0x100445030		540003a8		BHI 29(PC)											
  q8_codegen_test.go:72		0x100445034		bd0027e2		FMOVS F2, 36(RSP)										
  q8_codegen_test.go:72		0x100445038		bd0037e1		FMOVS F1, 52(RSP)										
  q8_codegen_test.go:72		0x10044503c		bd003fe0		FMOVS F0, 60(RSP)										
  q8_codegen_test.go:75		0x100445040		8b101aa2		ADD R16<<6, R21, R2										
  q8_codegen_test.go:75		0x100445044		aa0603e0		MOVD R6, R0											
  q8_codegen_test.go:75		0x100445048		aa0d03e1		MOVD R13, R1											
  q8_codegen_test.go:75		0x10044504c		97fbc3bd		CALL github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.dotQ8PairBlock64(SB)		
  q8_codegen_test.go:76		0x100445050		bd403fe2		FMOVS 60(RSP), F2										
  q8_codegen_test.go:76		0x100445054		bd4027e3		FMOVS 36(RSP), F3										
  q8_codegen_test.go:76		0x100445058		1f000860		FMADDS F0, F2, F3, F0										
  q8_codegen_test.go:77		0x10044505c		bd4037e2		FMOVS 52(RSP), F2										
  q8_codegen_test.go:77		0x100445060		1f010861		FMADDS F1, F2, F3, F1										
  q8_codegen_test.go:78		0x100445064		17ffffba		JMP -70(PC)											
  q8_codegen_test.go:101	0x100445068		9b087dcb		MUL R8, R14, R11										
  q8_codegen_test.go:101	0x10044506c		8b0b09eb		ADD R11<<2, R15, R11										
  q8_codegen_test.go:101	0x100445070		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:101	0x100445074		54000169		BLS 11(PC)											
  q8_codegen_test.go:101	0x100445078		bc2b78a0		FMOVS F0, (R5)(R11<<2)										
  q8_codegen_test.go:101	0x10044507c		9b083eeb		MADD R8, R15, R23, R11										
  q8_codegen_test.go:101	0x100445080		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:101	0x100445084		540000c9		BLS 6(PC)											
  q8_codegen_test.go:101	0x100445088		bc2b78a1		FMOVS F1, (R5)(R11<<2)										
  q8_codegen_test.go:22		0x10044508c		f9403feb		MOVD 120(RSP), R11										
  q8_codegen_test.go:26		0x100445090		f94047f3		MOVD 136(RSP), R19										
  q8_codegen_test.go:104	0x100445094		aa1603f0		MOVD R22, R16											
  q8_codegen_test.go:102	0x100445098		17ffff4b		JMP -181(PC)											
  q8_codegen_test.go:101	0x10044509c		97f115c9		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:101	0x1004450a0		97f115c8		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:75		0x1004450a4		aa1303e1		MOVD R19, R1											
  q8_codegen_test.go:75		0x1004450a8		97f115c6		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:75		0x1004450ac		aa1803e1		MOVD R24, R1											
  q8_codegen_test.go:75		0x1004450b0		97f115c4		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:75		0x1004450b4		97f115c3		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:75		0x1004450b8		aa1a03e1		MOVD R26, R1											
  q8_codegen_test.go:75		0x1004450bc		97f115c1		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:82		0x1004450c0		1e2202ce		SCVTFWS R22, F14										
  q8_codegen_test.go:86		0x1004450c4		bc647bcf		FMOVS (R30)(R4<<2), F15										
  q8_codegen_test.go:87		0x1004450c8		bc6d7970		FMOVS (R11)(R13<<2), F16									
  q8_codegen_test.go:88		0x1004450cc		bc707971		FMOVS (R11)(R16<<2), F17									
  q8_codegen_test.go:89		0x1004450d0		bc747972		FMOVS (R11)(R20<<2), F18									
  q8_codegen_test.go:90		0x1004450d4		bc647973		FMOVS (R11)(R4<<2), F19										
  q8_codegen_test.go:86		0x1004450d8		1f0f1dc7		FMADDS F15, F7, F14, F7										
  q8_codegen_test.go:87		0x1004450dc		1f102168		FMADDS F16, F8, F11, F8										
  q8_codegen_test.go:88		0x1004450e0		1f11298a		FMADDS F17, F10, F12, F10									
  q8_codegen_test.go:89		0x1004450e4		1f1215a5		FMADDS F18, F5, F13, F5										
  q8_codegen_test.go:90		0x1004450e8		1f1311c4		FMADDS F19, F4, F14, F4										
  q8_codegen_test.go:23		0x1004450ec		f9404fe2		MOVD 152(RSP), R2										
  q8_codegen_test.go:105	0x1004450f0		f94087e3		MOVD 264(RSP), R3										
  q8_codegen_test.go:105	0x1004450f4		f94037e4		MOVD 104(RSP), R4										
  q8_codegen_test.go:104	0x1004450f8		f94057e7		MOVD 168(RSP), R7										
  q8_codegen_test.go:23		0x1004450fc		f9406ff4		MOVD 216(RSP), R20										
  q8_codegen_test.go:104	0x100445100		f9406bf6		MOVD 208(RSP), R22										
  q8_codegen_test.go:81		0x100445104		aa0603ed		MOVD R6, R13											
  q8_codegen_test.go:81		0x100445108		910011a6		ADD $4, R13, R6											
  q8_codegen_test.go:81		0x10044510c		eb06001f		CMP R6, R0											
  q8_codegen_test.go:81		0x100445110		5400044b		BLT 34(PC)											
  q8_codegen_test.go:82		0x100445114		eb0901bf		CMP R9, R13											
  q8_codegen_test.go:82		0x100445118		54000942		BCS 74(PC)											
  q8_codegen_test.go:82		0x10044511c		910005b0		ADD $1, R13, R16										
  q8_codegen_test.go:82		0x100445120		38ad6aa2		MOVB (R21)(R13), R2										
  q8_codegen_test.go:82		0x100445124		eb10013f		CMP R16, R9											
  q8_codegen_test.go:82		0x100445128		54000889		BLS 68(PC)											
  q8_codegen_test.go:82		0x10044512c		910009b4		ADD $2, R13, R20										
  q8_codegen_test.go:82		0x100445130		38b06aa3		MOVB (R21)(R16), R3										
  q8_codegen_test.go:82		0x100445134		eb14013f		CMP R20, R9											
  q8_codegen_test.go:82		0x100445138		540007c9		BLS 62(PC)											
  q8_codegen_test.go:82		0x10044513c		91000da4		ADD $3, R13, R4											
  q8_codegen_test.go:82		0x100445140		38b46aa7		MOVB (R21)(R20), R7										
  q8_codegen_test.go:82		0x100445144		eb04013f		CMP R4, R9											
  q8_codegen_test.go:82		0x100445148		54000729		BLS 57(PC)											
  q8_codegen_test.go:82		0x10044514c		38a46ab6		MOVB (R21)(R4), R22										
  q8_codegen_test.go:83		0x100445150		eb1901bf		CMP R25, R13											
  q8_codegen_test.go:83		0x100445154		54000682		BCS 52(PC)											
  q8_codegen_test.go:82		0x100445158		1e22004b		SCVTFWS R2, F11											
  q8_codegen_test.go:83		0x10044515c		bc6d7bcc		FMOVS (R30)(R13<<2), F12									
  q8_codegen_test.go:83		0x100445160		1f0c2569		FMADDS F12, F9, F11, F9										
  q8_codegen_test.go:84		0x100445164		eb10033f		CMP R16, R25											
  q8_codegen_test.go:84		0x100445168		54000589		BLS 44(PC)											
  q8_codegen_test.go:82		0x10044516c		1e22006c		SCVTFWS R3, F12											
  q8_codegen_test.go:84		0x100445170		bc707bcd		FMOVS (R30)(R16<<2), F13									
  q8_codegen_test.go:84		0x100445174		1f0d1986		FMADDS F13, F6, F12, F6										
  q8_codegen_test.go:85		0x100445178		eb14033f		CMP R20, R25											
  q8_codegen_test.go:85		0x10044517c		54000489		BLS 36(PC)											
  q8_codegen_test.go:82		0x100445180		1e2200ed		SCVTFWS R7, F13											
  q8_codegen_test.go:85		0x100445184		bc747bce		FMOVS (R30)(R20<<2), F14									
  q8_codegen_test.go:85		0x100445188		1f0e0da3		FMADDS F14, F3, F13, F3										
  q8_codegen_test.go:86		0x10044518c		eb04033f		CMP R4, R25											
  q8_codegen_test.go:86		0x100445190		54fff988		BHI -52(PC)											
  q8_codegen_test.go:86		0x100445194		1400001c		JMP 28(PC)											
  q8_codegen_test.go:92		0x100445198		1e262926		FADDS F6, F9, F6										
  q8_codegen_test.go:92		0x10044519c		1e272863		FADDS F7, F3, F3										
  q8_codegen_test.go:92		0x1004451a0		1e2a2907		FADDS F10, F8, F7										
  q8_codegen_test.go:92		0x1004451a4		1e2428a4		FADDS F4, F5, F4										
  q8_codegen_test.go:92		0x1004451a8		1e262863		FADDS F6, F3, F3										
  q8_codegen_test.go:92		0x1004451ac		1e272884		FADDS F7, F4, F4										
  q8_codegen_test.go:93		0x1004451b0		14000007		JMP 7(PC)											
  q8_codegen_test.go:94		0x1004451b4		1e2200c5		SCVTFWS R6, F5											
  q8_codegen_test.go:95		0x1004451b8		bc6d7bc6		FMOVS (R30)(R13<<2), F6										
  q8_codegen_test.go:96		0x1004451bc		bc6d7967		FMOVS (R11)(R13<<2), F7										
  q8_codegen_test.go:95		0x1004451c0		1f060ca3		FMADDS F6, F3, F5, F3										
  q8_codegen_test.go:96		0x1004451c4		1f0710a4		FMADDS F7, F4, F5, F4										
  q8_codegen_test.go:93		0x1004451c8		910005ad		ADD $1, R13, R13										
  q8_codegen_test.go:93		0x1004451cc		eb0001bf		CMP R0, R13											
  q8_codegen_test.go:93		0x1004451d0		540000ea		BGE 7(PC)											
  q8_codegen_test.go:94		0x1004451d4		eb0901bf		CMP R9, R13											
  q8_codegen_test.go:94		0x1004451d8		54000142		BCS 10(PC)											
  q8_codegen_test.go:94		0x1004451dc		38ad6aa6		MOVB (R21)(R13), R6										
  q8_codegen_test.go:95		0x1004451e0		eb1901bf		CMP R25, R13											
  q8_codegen_test.go:95		0x1004451e4		54fffe83		BCC -12(PC)											
  q8_codegen_test.go:95		0x1004451e8		14000004		JMP 4(PC)											
  q8_codegen_test.go:98		0x1004451ec		1f030040		FMADDS F3, F0, F2, F0										
  q8_codegen_test.go:99		0x1004451f0		1f040441		FMADDS F4, F1, F2, F1										
  q8_codegen_test.go:99		0x1004451f4		17ffff56		JMP -170(PC)											
  q8_codegen_test.go:95		0x1004451f8		aa1903e0		MOVD R25, R0											
  q8_codegen_test.go:95		0x1004451fc		97f11571		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:94		0x100445200		97f11570		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:86		0x100445204		aa1903e0		MOVD R25, R0											
  q8_codegen_test.go:86		0x100445208		97f1156e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:85		0x10044520c		aa1403e0		MOVD R20, R0											
  q8_codegen_test.go:85		0x100445210		aa1903e1		MOVD R25, R1											
  q8_codegen_test.go:85		0x100445214		97f1156b		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:84		0x100445218		aa1003e0		MOVD R16, R0											
  q8_codegen_test.go:84		0x10044521c		aa1903e1		MOVD R25, R1											
  q8_codegen_test.go:84		0x100445220		97f11568		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:83		0x100445224		aa1903e0		MOVD R25, R0											
  q8_codegen_test.go:83		0x100445228		97f11566		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:82		0x10044522c		97f11565		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:82		0x100445230		aa1403e0		MOVD R20, R0											
  q8_codegen_test.go:82		0x100445234		97f11563		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:82		0x100445238		aa1003e0		MOVD R16, R0											
  q8_codegen_test.go:82		0x10044523c		97f11561		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:82		0x100445240		97f11560		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:70		0x100445244		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:70		0x100445248		97f1155e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:70		0x10044524c		97f1155d		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:70		0x100445250		d37ef720		LSL $2, R25, R0											
  q8_codegen_test.go:70		0x100445254		aa1803e1		MOVD R24, R1											
  q8_codegen_test.go:70		0x100445258		97f1155a		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:70		0x10044525c		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:70		0x100445260		97f11558		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:60		0x100445264		1f070481		FMADDS F7, F1, F4, F1										
  q8_codegen_test.go:61		0x100445268		1f080882		FMADDS F8, F2, F4, F2										
  q8_codegen_test.go:62		0x10044526c		1f060080		FMADDS F6, F0, F4, F0										
  q8_codegen_test.go:63		0x100445270		1f050c83		FMADDS F5, F3, F4, F3										
  q8_codegen_test.go:27		0x100445274		f94087e0		MOVD 264(RSP), R0										
  q8_codegen_test.go:27		0x100445278		f94037e4		MOVD 104(RSP), R4										
  q8_codegen_test.go:30		0x10044527c		aa0103e3		MOVD R1, R3											
  q8_codegen_test.go:30		0x100445280		eb8a187f		CMP R10->6, R3											
  q8_codegen_test.go:30		0x100445284		5400114a		BGE 138(PC)											
  q8_codegen_test.go:30		0x100445288		bd002fe3		FMOVS F3, 44(RSP)										
  q8_codegen_test.go:30		0x10044528c		bd0033e0		FMOVS F0, 48(RSP)										
  q8_codegen_test.go:30		0x100445290		bd003be2		FMOVS F2, 56(RSP)										
  q8_codegen_test.go:30		0x100445294		bd0043e1		FMOVS F1, 64(RSP)										
  q8_codegen_test.go:32		0x100445298		91000461		ADD $1, R3, R1											
  q8_codegen_test.go:32		0x10044529c		d37ae420		LSL $6, R1, R0											
  q8_codegen_test.go:30		0x1004452a0		bc637a24		FMOVS (R17)(R3<<2), F4										
  q8_codegen_test.go:30		0x1004452a4		bd002be4		FMOVS F4, 40(RSP)										
  q8_codegen_test.go:32		0x1004452a8		d37ae463		LSL $6, R3, R3											
  q8_codegen_test.go:32		0x1004452ac		eb01193f		CMP R1<<6, R9											
  q8_codegen_test.go:32		0x1004452b0		9a80b120		CSEL LT, R9, R0, R0										
  q8_codegen_test.go:32		0x1004452b4		1e2703e5		FMOVS ZR, F5											
  q8_codegen_test.go:32		0x1004452b8		1e2703e6		FMOVS ZR, F6											
  q8_codegen_test.go:32		0x1004452bc		1e2703e7		FMOVS ZR, F7											
  q8_codegen_test.go:32		0x1004452c0		1e2703e8		FMOVS ZR, F8											
  q8_codegen_test.go:32		0x1004452c4		1e2703e9		FMOVS ZR, F9											
  q8_codegen_test.go:32		0x1004452c8		1e2703ea		FMOVS ZR, F10											
  q8_codegen_test.go:32		0x1004452cc		1e2703eb		FMOVS ZR, F11											
  q8_codegen_test.go:32		0x1004452d0		1e2703ec		FMOVS ZR, F12											
  q8_codegen_test.go:32		0x1004452d4		1e2703ed		FMOVS ZR, F13											
  q8_codegen_test.go:32		0x1004452d8		1e2703ee		FMOVS ZR, F14											
  q8_codegen_test.go:32		0x1004452dc		1e2703ef		FMOVS ZR, F15											
  q8_codegen_test.go:32		0x1004452e0		1e2703f0		FMOVS ZR, F16											
  q8_codegen_test.go:32		0x1004452e4		1e2703f1		FMOVS ZR, F17											
  q8_codegen_test.go:32		0x1004452e8		1e2703f2		FMOVS ZR, F18											
  q8_codegen_test.go:32		0x1004452ec		1e2703f3		FMOVS ZR, F19											
  q8_codegen_test.go:32		0x1004452f0		1e2703f4		FMOVS ZR, F20											
  q8_codegen_test.go:32		0x1004452f4		1400002b		JMP 43(PC)											
  q8_codegen_test.go:36		0x1004452f8		bd0047e7		FMOVS F7, 68(RSP)										
  q8_codegen_test.go:34		0x1004452fc		1e2202d8		SCVTFWS R22, F24										
  q8_codegen_test.go:38		0x100445300		bc627b39		FMOVS (R25)(R2<<2), F25										
  q8_codegen_test.go:39		0x100445304		bc63797a		FMOVS (R11)(R3<<2), F26										
  q8_codegen_test.go:40		0x100445308		bc67797b		FMOVS (R11)(R7<<2), F27										
  q8_codegen_test.go:41		0x10044530c		bc6d797c		FMOVS (R11)(R13<<2), F28									
  q8_codegen_test.go:42		0x100445310		bc62797d		FMOVS (R11)(R2<<2), F29										
  q8_codegen_test.go:43		0x100445314		bc637bde		FMOVS (R30)(R3<<2), F30										
  q8_codegen_test.go:44		0x100445318		bc677bdf		FMOVS (R30)(R7<<2), F31										
  q8_codegen_test.go:45		0x10044531c		bc6d7bc3		FMOVS (R30)(R13<<2), F3										
  q8_codegen_test.go:46		0x100445320		bc627bc0		FMOVS (R30)(R2<<2), F0										
  q8_codegen_test.go:47		0x100445324		bc637ae2		FMOVS (R23)(R3<<2), F2										
  q8_codegen_test.go:48		0x100445328		bc677ae1		FMOVS (R23)(R7<<2), F1										
  q8_codegen_test.go:49		0x10044532c		bc6d7ae4		FMOVS (R23)(R13<<2), F4										
  q8_codegen_test.go:50		0x100445330		bc627ae7		FMOVS (R23)(R2<<2), F7										
  q8_codegen_test.go:38		0x100445334		1f192709		FMADDS F25, F9, F24, F9										
  q8_codegen_test.go:39		0x100445338		1f1a4ab2		FMADDS F26, F18, F21, F18									
  q8_codegen_test.go:40		0x10044533c		1f1b2aca		FMADDS F27, F10, F22, F10									
  q8_codegen_test.go:41		0x100445340		1f1c32ec		FMADDS F28, F12, F23, F12									
  q8_codegen_test.go:42		0x100445344		1f1d2f0b		FMADDS F29, F11, F24, F11									
  q8_codegen_test.go:43		0x100445348		1f1e1aa6		FMADDS F30, F6, F21, F6										
  q8_codegen_test.go:44		0x10044534c		1f1f46d1		FMADDS F31, F17, F22, F17									
  q8_codegen_test.go:45		0x100445350		1f0336ed		FMADDS F3, F13, F23, F13									
  q8_codegen_test.go:46		0x100445354		1f004f13		FMADDS F0, F19, F24, F19									
  q8_codegen_test.go:47		0x100445358		1f023aae		FMADDS F2, F14, F21, F14									
  q8_codegen_test.go:48		0x10044535c		1f0142d0		FMADDS F1, F16, F22, F16									
  q8_codegen_test.go:49		0x100445360		1f043eef		FMADDS F4, F15, F23, F15									
  q8_codegen_test.go:50		0x100445364		1f071705		FMADDS F7, F5, F24, F5										
  q8_codegen_test.go:23		0x100445368		f9404fe2		MOVD 152(RSP), R2										
  q8_codegen_test.go:24		0x10044536c		f9408fe6		MOVD 280(RSP), R6										
  q8_codegen_test.go:26		0x100445370		f94057e7		MOVD 168(RSP), R7										
  q8_codegen_test.go:25		0x100445374		f9405fed		MOVD 184(RSP), R13										
  q8_codegen_test.go:26		0x100445378		f94047f0		MOVD 136(RSP), R16										
  q8_codegen_test.go:23		0x10044537c		f9406ff4		MOVD 216(RSP), R20										
  q8_codegen_test.go:66		0x100445380		f9406bf6		MOVD 208(RSP), R22										
  q8_codegen_test.go:62		0x100445384		bd4033e0		FMOVS 48(RSP), F0										
  q8_codegen_test.go:60		0x100445388		bd4043e1		FMOVS 64(RSP), F1										
  q8_codegen_test.go:61		0x10044538c		bd403be2		FMOVS 56(RSP), F2										
  q8_codegen_test.go:63		0x100445390		bd402fe3		FMOVS 44(RSP), F3										
  q8_codegen_test.go:60		0x100445394		bd402be4		FMOVS 40(RSP), F4										
  q8_codegen_test.go:33		0x100445398		aa0403e3		MOVD R4, R3											
  q8_codegen_test.go:33		0x10044539c		bd4047e7		FMOVS 68(RSP), F7										
  q8_codegen_test.go:33		0x1004453a0		91001064		ADD $4, R3, R4											
  q8_codegen_test.go:33		0x1004453a4		eb04001f		CMP R4, R0											
  q8_codegen_test.go:33		0x1004453a8		5400044b		BLT 34(PC)											
  q8_codegen_test.go:34		0x1004453ac		eb09007f		CMP R9, R3											
  q8_codegen_test.go:34		0x1004453b0		54000d02		BCS 104(PC)											
  q8_codegen_test.go:34		0x1004453b4		91000467		ADD $1, R3, R7											
  q8_codegen_test.go:34		0x1004453b8		38a36ab0		MOVB (R21)(R3), R16										
  q8_codegen_test.go:34		0x1004453bc		eb07013f		CMP R7, R9											
  q8_codegen_test.go:34		0x1004453c0		54000c69		BLS 99(PC)											
  q8_codegen_test.go:34		0x1004453c4		9100086d		ADD $2, R3, R13											
  q8_codegen_test.go:34		0x1004453c8		38a76aa6		MOVB (R21)(R7), R6										
  q8_codegen_test.go:34		0x1004453cc		eb0d013f		CMP R13, R9											
  q8_codegen_test.go:34		0x1004453d0		54000bc9		BLS 94(PC)											
  q8_codegen_test.go:34		0x1004453d4		91000c62		ADD $3, R3, R2											
  q8_codegen_test.go:34		0x1004453d8		38ad6ab4		MOVB (R21)(R13), R20										
  q8_codegen_test.go:34		0x1004453dc		eb02013f		CMP R2, R9											
  q8_codegen_test.go:34		0x1004453e0		54000b29		BLS 89(PC)											
  q8_codegen_test.go:34		0x1004453e4		38a26ab6		MOVB (R21)(R2), R22										
  q8_codegen_test.go:35		0x1004453e8		eb18007f		CMP R24, R3											
  q8_codegen_test.go:35		0x1004453ec		54000a82		BCS 84(PC)											
  q8_codegen_test.go:34		0x1004453f0		1e220215		SCVTFWS R16, F21										
  q8_codegen_test.go:35		0x1004453f4		bc637b36		FMOVS (R25)(R3<<2), F22										
  q8_codegen_test.go:35		0x1004453f8		1f1622a8		FMADDS F22, F8, F21, F8										
  q8_codegen_test.go:36		0x1004453fc		eb07031f		CMP R7, R24											
  q8_codegen_test.go:36		0x100445400		540009a9		BLS 77(PC)											
  q8_codegen_test.go:34		0x100445404		1e2200d6		SCVTFWS R6, F22											
  q8_codegen_test.go:36		0x100445408		bc677b37		FMOVS (R25)(R7<<2), F23										
  q8_codegen_test.go:36		0x10044540c		1f171ec7		FMADDS F23, F7, F22, F7										
  q8_codegen_test.go:37		0x100445410		eb0d031f		CMP R13, R24											
  q8_codegen_test.go:37		0x100445414		540008c9		BLS 70(PC)											
  q8_codegen_test.go:34		0x100445418		1e220297		SCVTFWS R20, F23										
  q8_codegen_test.go:37		0x10044541c		bc6d7b38		FMOVS (R25)(R13<<2), F24									
  q8_codegen_test.go:37		0x100445420		1f1852f4		FMADDS F24, F20, F23, F20									
  q8_codegen_test.go:38		0x100445424		eb02031f		CMP R2, R24											
  q8_codegen_test.go:38		0x100445428		54fff688		BHI -76(PC)											
  q8_codegen_test.go:38		0x10044542c		1400003e		JMP 62(PC)											
  q8_codegen_test.go:52		0x100445430		1e272907		FADDS F7, F8, F7										
  q8_codegen_test.go:52		0x100445434		1e292a88		FADDS F9, F20, F8										
  q8_codegen_test.go:52		0x100445438		1e2a2a49		FADDS F10, F18, F9										
  q8_codegen_test.go:52		0x10044543c		1e2b298a		FADDS F11, F12, F10										
  q8_codegen_test.go:52		0x100445440		1e3128c6		FADDS F17, F6, F6										
  q8_codegen_test.go:52		0x100445444		1e3329ab		FADDS F19, F13, F11										
  q8_codegen_test.go:52		0x100445448		1e3029cc		FADDS F16, F14, F12										
  q8_codegen_test.go:52		0x10044544c		1e2529e5		FADDS F5, F15, F5										
  q8_codegen_test.go:52		0x100445450		1e272907		FADDS F7, F8, F7										
  q8_codegen_test.go:52		0x100445454		1e2a2928		FADDS F10, F9, F8										
  q8_codegen_test.go:52		0x100445458		1e2b28c6		FADDS F11, F6, F6										
  q8_codegen_test.go:52		0x10044545c		1e252985		FADDS F5, F12, F5										
  q8_codegen_test.go:53		0x100445460		1400000b		JMP 11(PC)											
  q8_codegen_test.go:54		0x100445464		1e220089		SCVTFWS R4, F9											
  q8_codegen_test.go:55		0x100445468		bc637b2a		FMOVS (R25)(R3<<2), F10										
  q8_codegen_test.go:56		0x10044546c		bc63796b		FMOVS (R11)(R3<<2), F11										
  q8_codegen_test.go:57		0x100445470		bc637bcc		FMOVS (R30)(R3<<2), F12										
  q8_codegen_test.go:58		0x100445474		bc637aed		FMOVS (R23)(R3<<2), F13										
  q8_codegen_test.go:55		0x100445478		1f0a1d27		FMADDS F10, F7, F9, F7										
  q8_codegen_test.go:56		0x10044547c		1f0b2128		FMADDS F11, F8, F9, F8										
  q8_codegen_test.go:57		0x100445480		1f0c1926		FMADDS F12, F6, F9, F6										
  q8_codegen_test.go:58		0x100445484		1f0d1525		FMADDS F13, F5, F9, F5										
  q8_codegen_test.go:53		0x100445488		91000463		ADD $1, R3, R3											
  q8_codegen_test.go:53		0x10044548c		eb00007f		CMP R0, R3											
  q8_codegen_test.go:53		0x100445490		54ffeeaa		BGE -139(PC)											
  q8_codegen_test.go:54		0x100445494		eb09007f		CMP R9, R3											
  q8_codegen_test.go:54		0x100445498		54000442		BCS 34(PC)											
  q8_codegen_test.go:54		0x10044549c		38a36aa4		MOVB (R21)(R3), R4										
  q8_codegen_test.go:55		0x1004454a0		eb18007f		CMP R24, R3											
  q8_codegen_test.go:55		0x1004454a4		54fffe03		BCC -16(PC)											
  q8_codegen_test.go:55		0x1004454a8		1400001c		JMP 28(PC)											
  q8_codegen_test.go:65		0x1004454ac		9b087dc3		MUL R8, R14, R3											
  q8_codegen_test.go:65		0x1004454b0		8b0309e3		ADD R3<<2, R15, R3										
  q8_codegen_test.go:65		0x1004454b4		eb03019f		CMP R3, R12											
  q8_codegen_test.go:65		0x1004454b8		540002e9		BLS 23(PC)											
  q8_codegen_test.go:65		0x1004454bc		bc2378a1		FMOVS F1, (R5)(R3<<2)										
  q8_codegen_test.go:65		0x1004454c0		9b083e63		MADD R8, R15, R19, R3										
  q8_codegen_test.go:65		0x1004454c4		eb03019f		CMP R3, R12											
  q8_codegen_test.go:65		0x1004454c8		54000249		BLS 18(PC)											
  q8_codegen_test.go:65		0x1004454cc		bc2378a2		FMOVS F2, (R5)(R3<<2)										
  q8_codegen_test.go:66		0x1004454d0		9b083f43		MADD R8, R15, R26, R3										
  q8_codegen_test.go:66		0x1004454d4		eb03019f		CMP R3, R12											
  q8_codegen_test.go:66		0x1004454d8		540001a9		BLS 13(PC)											
  q8_codegen_test.go:66		0x1004454dc		bc2378a0		FMOVS F0, (R5)(R3<<2)										
  q8_codegen_test.go:66		0x1004454e0		9b083ec3		MADD R8, R15, R22, R3										
  q8_codegen_test.go:66		0x1004454e4		eb03019f		CMP R3, R12											
  q8_codegen_test.go:66		0x1004454e8		54000109		BLS 8(PC)											
  q8_codegen_test.go:66		0x1004454ec		bc2378a3		FMOVS F3, (R5)(R3<<2)										
  q8_codegen_test.go:21		0x1004454f0		f94043e0		MOVD 128(RSP), R0										
  q8_codegen_test.go:21		0x1004454f4		f940a3e1		MOVD 320(RSP), R1										
  q8_codegen_test.go:27		0x1004454f8		f94087e3		MOVD 264(RSP), R3										
  q8_codegen_test.go:22		0x1004454fc		f9403feb		MOVD 120(RSP), R11										
  q8_codegen_test.go:26		0x100445500		aa1003f3		MOVD R16, R19											
  q8_codegen_test.go:66		0x100445504		17fffdb3		JMP -589(PC)											
  q8_codegen_test.go:66		0x100445508		97f114ae		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:66		0x10044550c		97f114ad		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:65		0x100445510		97f114ac		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:65		0x100445514		97f114ab		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:55		0x100445518		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:55		0x10044551c		97f114a9		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:54		0x100445520		97f114a8		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:38		0x100445524		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:38		0x100445528		97f114a6		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:37		0x10044552c		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:37		0x100445530		97f114a4		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:36		0x100445534		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:36		0x100445538		97f114a2		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:35		0x10044553c		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:35		0x100445540		97f114a0		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:34		0x100445544		97f1149f		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:34		0x100445548		97f1149e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:34		0x10044554c		97f1149d		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:34		0x100445550		97f1149c		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:28		0x100445554		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:28		0x100445558		97f1149a		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:28		0x10044555c		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:28		0x100445560		97f11498		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:28		0x100445564		aa1e03e0		MOVD R30, R0											
  q8_codegen_test.go:28		0x100445568		97f11496		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:28		0x10044556c		97f11495		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:27		0x100445570		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:27		0x100445574		aa1e03e1		MOVD R30, R1											
  q8_codegen_test.go:27		0x100445578		97f11492		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:27		0x10044557c		aa1e03e0		MOVD R30, R0											
  q8_codegen_test.go:27		0x100445580		97f11490		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:27		0x100445584		d37ef700		LSL $2, R24, R0											
  q8_codegen_test.go:27		0x100445588		aa1603e1		MOVD R22, R1											
  q8_codegen_test.go:27		0x10044558c		97f1148d		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:27		0x100445590		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:27		0x100445594		97f1148b		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:25		0x100445598		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:25		0x10044559c		aa1903e1		MOVD R25, R1											
  q8_codegen_test.go:25		0x1004455a0		97f11488		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:25		0x1004455a4		aa1903e0		MOVD R25, R0											
  q8_codegen_test.go:25		0x1004455a8		aa1803e1		MOVD R24, R1											
  q8_codegen_test.go:25		0x1004455ac		97f11485		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:24		0x1004455b0		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:24		0x1004455b4		aa1503e1		MOVD R21, R1											
  q8_codegen_test.go:24		0x1004455b8		97f11482		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:24		0x1004455bc		aa1503e0		MOVD R21, R0											
  q8_codegen_test.go:24		0x1004455c0		aa1303e1		MOVD R19, R1											
  q8_codegen_test.go:24		0x1004455c4		97f1147f		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:22		0x1004455c8		97f001c6		CALL runtime.panicdivide(SB)									
  q8_codegen_test.go:22		0x1004455cc		d503201f		NOOP												
  q8_codegen_test.go:17		0x1004455d0		a90087e0		STP (R0, R1), 8(RSP)										
  q8_codegen_test.go:17		0x1004455d4		aa1e03e3		MOVD R30, R3											
  q8_codegen_test.go:17		0x1004455d8		97f10c16		CALL runtime.morestack.abi0(SB)									
  q8_codegen_test.go:17		0x1004455dc		a94087e0		LDP 8(RSP), (R0, R1)										
  q8_codegen_test.go:17		0x1004455e0		17fffd48		JMP github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.newQ8CodegenProbe.func1(SB)	
  q8_codegen_test.go:17		0x1004455e4		00000000		?												
  q8_codegen_test.go:17		0x1004455e8		00000000		?												
  q8_codegen_test.go:17		0x1004455ec		00000000		?												

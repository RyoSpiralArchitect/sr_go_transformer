TEXT github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.newQ8CodegenProbe.func1(SB) /Users/ryohiga/SpiralReality/sr_go_transformer/cmd/monolith/q8_codegen_test.go
  q8_codegen_test.go:20		0x100444b30		f9400b90		MOVD 16(R28), R16										
  q8_codegen_test.go:20		0x100444b34		d102c3f1		SUB $176, RSP, R17										
  q8_codegen_test.go:20		0x100444b38		eb10023f		CMP R16, R17											
  q8_codegen_test.go:20		0x100444b3c		540055a9		BLS 685(PC)											
  q8_codegen_test.go:20		0x100444b40		d104c3f4		SUB $304, RSP, R20										
  q8_codegen_test.go:20		0x100444b44		a93ffa9d		STP (R29, R30), -8(R20)										
  q8_codegen_test.go:20		0x100444b48		9100029f		MOVD R20, RSP											
  q8_codegen_test.go:20		0x100444b4c		d10023fd		SUB $8, RSP, R29										
  q8_codegen_test.go:23		0x100444b50		f900a3e1		MOVD R1, 320(RSP)										
  q8_codegen_test.go:20		0x100444b54		f9400743		MOVD 8(R26), R3											
  q8_codegen_test.go:21		0x100444b58		a9419464		LDP 24(R3), (R4, R5)										
  q8_codegen_test.go:21		0x100444b5c		f9007be5		MOVD R5, 240(RSP)										
  q8_codegen_test.go:21		0x100444b60		f9003be4		MOVD R4, 112(RSP)										
  q8_codegen_test.go:21		0x100444b64		a9439c66		LDP 56(R3), (R6, R7)										
  q8_codegen_test.go:21		0x100444b68		f9008fe6		MOVD R6, 280(RSP)										
  q8_codegen_test.go:21		0x100444b6c		f9005be7		MOVD R7, 176(RSP)										
  q8_codegen_test.go:22		0x100444b70		a9452468		LDP 80(R3), (R8, R9)										
  q8_codegen_test.go:22		0x100444b74		f9005fe8		MOVD R8, 184(RSP)										
  q8_codegen_test.go:22		0x100444b78		f9004fe9		MOVD R9, 152(RSP)										
  q8_codegen_test.go:22		0x100444b7c		a9462c6a		LDP 96(R3), (R10, R11)										
  q8_codegen_test.go:22		0x100444b80		f90063ea		MOVD R10, 192(RSP)										
  q8_codegen_test.go:22		0x100444b84		f90043eb		MOVD R11, 128(RSP)										
  q8_codegen_test.go:21		0x100444b88		f940146c		MOVD 40(R3), R12										
  q8_codegen_test.go:21		0x100444b8c		f9002bec		MOVD R12, 80(RSP)										
  q8_codegen_test.go:21		0x100444b90		f9400463		MOVD 8(R3), R3											
  q8_codegen_test.go:21		0x100444b94		f90087e3		MOVD R3, 264(RSP)										
  q8_codegen_test.go:23		0x100444b98		14000002		JMP 2(PC)											
  q8_codegen_test.go:23		0x100444b9c		91000400		ADD $1, R0, R0											
  q8_codegen_test.go:23		0x100444ba0		eb00003f		CMP R0, R1											
  q8_codegen_test.go:23		0x100444ba4		54001b2d		BLE 217(PC)											
  q8_codegen_test.go:24		0x100444ba8		b400520b		CBZ R11, 656(PC)										
  q8_codegen_test.go:23		0x100444bac		f90047e0		MOVD R0, 136(RSP)										
  q8_codegen_test.go:24		0x100444bb0		9acb0c0d		SDIV R11, R0, R13										
  q8_codegen_test.go:24		0x100444bb4		f90077ed		MOVD R13, 232(RSP)										
  q8_codegen_test.go:24		0x100444bb8		9acb0c1b		SDIV R11, R0, R27										
  q8_codegen_test.go:24		0x100444bbc		9b0b836e		MSUB R11, R0, R27, R14										
  q8_codegen_test.go:24		0x100444bc0		d37ef5af		LSL $2, R13, R15										
  q8_codegen_test.go:24		0x100444bc4		f9004bef		MOVD R15, 144(RSP)										
  q8_codegen_test.go:24		0x100444bc8		d37be9ce		LSL $5, R14, R14										
  q8_codegen_test.go:24		0x100444bcc		f90053ee		MOVD R14, 160(RSP)										
  q8_codegen_test.go:24		0x100444bd0		aa0e03e2		MOVD R14, R2											
  q8_codegen_test.go:25		0x100444bd4		14000003		JMP 3(PC)											
  q8_codegen_test.go:28		0x100444bd8		aa1103ef		MOVD R17, R15											
  q8_codegen_test.go:25		0x100444bdc		aa1303ee		MOVD R19, R14											
  q8_codegen_test.go:25		0x100444be0		91008050		ADD $32, R2, R16										
  q8_codegen_test.go:25		0x100444be4		eb10013f		CMP R16, R9											
  q8_codegen_test.go:25		0x100444be8		9a90b130		CSEL LT, R9, R16, R16										
  q8_codegen_test.go:25		0x100444bec		eb1001df		CMP R16, R14											
  q8_codegen_test.go:25		0x100444bf0		54fffd6a		BGE -21(PC)											
  q8_codegen_test.go:26		0x100444bf4		f94044d0		MOVD 136(R6), R16										
  q8_codegen_test.go:26		0x100444bf8		f9400a11		MOVD 16(R16), R17										
  q8_codegen_test.go:26		0x100444bfc		910005d3		ADD $1, R14, R19										
  q8_codegen_test.go:26		0x100444c00		9b087e74		MUL R8, R19, R20										
  q8_codegen_test.go:26		0x100444c04		9b087dd5		MUL R8, R14, R21										
  q8_codegen_test.go:26		0x100444c08		eb14023f		CMP R20, R17											
  q8_codegen_test.go:26		0x100444c0c		54004e83		BCC 628(PC)											
  q8_codegen_test.go:26		0x100444c10		eb15029f		CMP R21, R20											
  q8_codegen_test.go:26		0x100444c14		54004de3		BCC 623(PC)											
  q8_codegen_test.go:26		0x100444c18		f9400214		MOVD (R16), R20											
  q8_codegen_test.go:26		0x100444c1c		cb1102b6		SUB R17, R21, R22										
  q8_codegen_test.go:26		0x100444c20		8a96feb6		AND R22->63, R21, R22										
  q8_codegen_test.go:27		0x100444c24		f9401617		MOVD 40(R16), R23										
  q8_codegen_test.go:27		0x100444c28		9b0a7e78		MUL R10, R19, R24										
  q8_codegen_test.go:26		0x100444c2c		8b160294		ADD R22, R20, R20										
  q8_codegen_test.go:26		0x100444c30		cb150231		SUB R21, R17, R17										
  q8_codegen_test.go:27		0x100444c34		9b0a7dd5		MUL R10, R14, R21										
  q8_codegen_test.go:27		0x100444c38		eb1802ff		CMP R24, R23											
  q8_codegen_test.go:27		0x100444c3c		54004c43		BCC 610(PC)											
  q8_codegen_test.go:27		0x100444c40		eb15031f		CMP R21, R24											
  q8_codegen_test.go:27		0x100444c44		54004ba3		BCC 605(PC)											
  q8_codegen_test.go:26		0x100444c48		f90073f3		MOVD R19, 224(RSP)										
  q8_codegen_test.go:27		0x100444c4c		f9400e10		MOVD 24(R16), R16										
  q8_codegen_test.go:27		0x100444c50		cb1702b6		SUB R23, R21, R22										
  q8_codegen_test.go:27		0x100444c54		8a96feb5		AND R22->63, R21, R21										
  q8_codegen_test.go:28		0x100444c58		910011f6		ADD $4, R15, R22										
  q8_codegen_test.go:27		0x100444c5c		8b150a10		ADD R21<<2, R16, R16										
  q8_codegen_test.go:28		0x100444c60		eb1600ff		CMP R22, R7											
  q8_codegen_test.go:28		0x100444c64		540005cb		BLT 46(PC)											
  q8_codegen_test.go:29		0x100444c68		910005f1		ADD $1, R15, R17										
  q8_codegen_test.go:29		0x100444c6c		9b117d15		MUL R17, R8, R21										
  q8_codegen_test.go:29		0x100444c70		9b087db7		MUL R8, R13, R23										
  q8_codegen_test.go:29		0x100444c74		eb15009f		CMP R21, R4											
  q8_codegen_test.go:29		0x100444c78		540049c3		BCC 590(PC)											
  q8_codegen_test.go:29		0x100444c7c		eb170abf		CMP R23<<2, R21											
  q8_codegen_test.go:29		0x100444c80		54004923		BCC 585(PC)											
  q8_codegen_test.go:29		0x100444c84		cb170898		SUB R23<<2, R4, R24										
  q8_codegen_test.go:29		0x100444c88		cb1803f8		NEG R24, R24											
  q8_codegen_test.go:29		0x100444c8c		8a98fef8		AND R24->63, R23, R24										
  q8_codegen_test.go:29		0x100444c90		910009f9		ADD $2, R15, R25										
  q8_codegen_test.go:29		0x100444c94		9b197d1a		MUL R25, R8, R26										
  q8_codegen_test.go:29		0x100444c98		cb170ab7		SUB R23<<2, R21, R23										
  q8_codegen_test.go:29		0x100444c9c		8b181078		ADD R24<<4, R3, R24										
  q8_codegen_test.go:29		0x100444ca0		eb1a009f		CMP R26, R4											
  q8_codegen_test.go:29		0x100444ca4		540047c3		BCC 574(PC)											
  q8_codegen_test.go:29		0x100444ca8		eb15035f		CMP R21, R26											
  q8_codegen_test.go:29		0x100444cac		54004723		BCC 569(PC)											
  q8_codegen_test.go:29		0x100444cb0		cb0402be		SUB R4, R21, R30										
  q8_codegen_test.go:29		0x100444cb4		8a9efeb5		AND R30->63, R21, R21										
  q8_codegen_test.go:30		0x100444cb8		91000dfe		ADD $3, R15, R30										
  q8_codegen_test.go:30		0x100444cbc		9b087fcb		MUL R8, R30, R11										
  q8_codegen_test.go:29		0x100444cc0		8b150875		ADD R21<<2, R3, R21										
  q8_codegen_test.go:30		0x100444cc4		eb0b009f		CMP R11, R4											
  q8_codegen_test.go:30		0x100444cc8		54004623		BCC 561(PC)											
  q8_codegen_test.go:30		0x100444ccc		eb1a017f		CMP R26, R11											
  q8_codegen_test.go:30		0x100444cd0		540045a3		BCC 557(PC)											
  q8_codegen_test.go:30		0x100444cd4		cb040341		SUB R4, R26, R1											
  q8_codegen_test.go:30		0x100444cd8		8a81ff5a		AND R1->63, R26, R26										
  q8_codegen_test.go:30		0x100444cdc		9b087ed6		MUL R8, R22, R22										
  q8_codegen_test.go:30		0x100444ce0		8b1a087a		ADD R26<<2, R3, R26										
  q8_codegen_test.go:30		0x100444ce4		eb16009f		CMP R22, R4											
  q8_codegen_test.go:30		0x100444ce8		540044a3		BCC 549(PC)											
  q8_codegen_test.go:30		0x100444cec		eb0b02df		CMP R11, R22											
  q8_codegen_test.go:30		0x100444cf0		54004423		BCC 545(PC)											
  q8_codegen_test.go:30		0x100444cf4		f9006ffe		MOVD R30, 216(RSP)										
  q8_codegen_test.go:30		0x100444cf8		cb040176		SUB R4, R11, R22										
  q8_codegen_test.go:30		0x100444cfc		8a96fd6b		AND R22->63, R11, R11										
  q8_codegen_test.go:30		0x100444d00		8b0b086b		ADD R11<<2, R3, R11										
  q8_codegen_test.go:32		0x100444d04		aa1f03f6		MOVD ZR, R22											
  q8_codegen_test.go:32		0x100444d08		1e2703e0		FMOVS ZR, F0											
  q8_codegen_test.go:32		0x100444d0c		1e2703e1		FMOVS ZR, F1											
  q8_codegen_test.go:32		0x100444d10		1e2703e2		FMOVS ZR, F2											
  q8_codegen_test.go:32		0x100444d14		1e2703e3		FMOVS ZR, F3											
  q8_codegen_test.go:32		0x100444d18		14000160		JMP 352(PC)											
  q8_codegen_test.go:71		0x100444d1c		910009f5		ADD $2, R15, R21										
  q8_codegen_test.go:71		0x100444d20		eb1500ff		CMP R21, R7											
  q8_codegen_test.go:71		0x100444d24		540004ab		BLT 37(PC)											
  q8_codegen_test.go:72		0x100444d28		910005f6		ADD $1, R15, R22										
  q8_codegen_test.go:72		0x100444d2c		9b167d17		MUL R22, R8, R23										
  q8_codegen_test.go:72		0x100444d30		9b087db8		MUL R8, R13, R24										
  q8_codegen_test.go:72		0x100444d34		eb17009f		CMP R23, R4											
  q8_codegen_test.go:72		0x100444d38		540029e3		BCC 335(PC)											
  q8_codegen_test.go:72		0x100444d3c		eb180aff		CMP R24<<2, R23											
  q8_codegen_test.go:72		0x100444d40		54002943		BCC 330(PC)											
  q8_codegen_test.go:72		0x100444d44		cb180899		SUB R24<<2, R4, R25										
  q8_codegen_test.go:72		0x100444d48		cb1903fa		NEG R25, R26											
  q8_codegen_test.go:72		0x100444d4c		8a9aff1a		AND R26->63, R24, R26										
  q8_codegen_test.go:72		0x100444d50		9b157d1e		MUL R21, R8, R30										
  q8_codegen_test.go:72		0x100444d54		cb180af8		SUB R24<<2, R23, R24										
  q8_codegen_test.go:72		0x100444d58		8b1a107a		ADD R26<<4, R3, R26										
  q8_codegen_test.go:72		0x100444d5c		eb1e009f		CMP R30, R4											
  q8_codegen_test.go:72		0x100444d60		54002803		BCC 320(PC)											
  q8_codegen_test.go:72		0x100444d64		eb1703df		CMP R23, R30											
  q8_codegen_test.go:72		0x100444d68		54002763		BCC 315(PC)											
  q8_codegen_test.go:26		0x100444d6c		f9003ff1		MOVD R17, 120(RSP)										
  q8_codegen_test.go:26		0x100444d70		f9008bf4		MOVD R20, 272(RSP)										
  q8_codegen_test.go:27		0x100444d74		f90093f0		MOVD R16, 288(RSP)										
  q8_codegen_test.go:71		0x100444d78		f9006ff5		MOVD R21, 216(RSP)										
  q8_codegen_test.go:72		0x100444d7c		f9006bf6		MOVD R22, 208(RSP)										
  q8_codegen_test.go:72		0x100444d80		f90033f8		MOVD R24, 96(RSP)										
  q8_codegen_test.go:72		0x100444d84		f90037f9		MOVD R25, 104(RSP)										
  q8_codegen_test.go:72		0x100444d88		f90083fa		MOVD R26, 256(RSP)										
  q8_codegen_test.go:25		0x100444d8c		f90057ee		MOVD R14, 168(RSP)										
  q8_codegen_test.go:72		0x100444d90		cb0402fe		SUB R4, R23, R30										
  q8_codegen_test.go:72		0x100444d94		8a9efefe		AND R30->63, R23, R30										
  q8_codegen_test.go:72		0x100444d98		8b1e087e		ADD R30<<2, R3, R30										
  q8_codegen_test.go:72		0x100444d9c		f9007ffe		MOVD R30, 248(RSP)										
  q8_codegen_test.go:72		0x100444da0		cb170097		SUB R23, R4, R23										
  q8_codegen_test.go:72		0x100444da4		f9002ff7		MOVD R23, 88(RSP)										
  q8_codegen_test.go:74		0x100444da8		aa1f03eb		MOVD ZR, R11											
  q8_codegen_test.go:74		0x100444dac		1e2703e0		FMOVS ZR, F0											
  q8_codegen_test.go:74		0x100444db0		1e2703e1		FMOVS ZR, F1											
  q8_codegen_test.go:74		0x100444db4		14000086		JMP 134(PC)											
  q8_codegen_test.go:24		0x100444db8		aa0f03f1		MOVD R15, R17											
  q8_codegen_test.go:71		0x100444dbc		14000003		JMP 3(PC)											
  q8_codegen_test.go:124	0x100444dc0		bc2f78a0		FMOVS F0, (R5)(R15<<2)										
  q8_codegen_test.go:106	0x100444dc4		aa1503ef		MOVD R21, R15											
  q8_codegen_test.go:106	0x100444dc8		eb0701ff		CMP R7, R15											
  q8_codegen_test.go:106	0x100444dcc		54fff06a		BGE -125(PC)											
  q8_codegen_test.go:107	0x100444dd0		910005f5		ADD $1, R15, R21										
  q8_codegen_test.go:107	0x100444dd4		9b087eb6		MUL R8, R21, R22										
  q8_codegen_test.go:107	0x100444dd8		9b087df7		MUL R8, R15, R23										
  q8_codegen_test.go:107	0x100444ddc		eb16009f		CMP R22, R4											
  q8_codegen_test.go:107	0x100444de0		54000b63		BCC 91(PC)											
  q8_codegen_test.go:107	0x100444de4		eb1702df		CMP R23, R22											
  q8_codegen_test.go:107	0x100444de8		54000ac3		BCC 86(PC)											
  q8_codegen_test.go:107	0x100444dec		cb0402f6		SUB R4, R23, R22										
  q8_codegen_test.go:107	0x100444df0		8a96fef6		AND R22->63, R23, R22										
  q8_codegen_test.go:107	0x100444df4		8b160876		ADD R22<<2, R3, R22										
  q8_codegen_test.go:109	0x100444df8		aa1f03f7		MOVD ZR, R23											
  q8_codegen_test.go:109	0x100444dfc		1e2703e0		FMOVS ZR, F0											
  q8_codegen_test.go:109	0x100444e00		14000003		JMP 3(PC)											
  q8_codegen_test.go:122	0x100444e04		1f020020		FMADDS F2, F0, F1, F0										
  q8_codegen_test.go:109	0x100444e08		aa1803f7		MOVD R24, R23											
  q8_codegen_test.go:109	0x100444e0c		eb0a02ff		CMP R10, R23											
  q8_codegen_test.go:109	0x100444e10		5400074a		BGE 58(PC)											
  q8_codegen_test.go:110	0x100444e14		910006f8		ADD $1, R23, R24										
  q8_codegen_test.go:110	0x100444e18		d37ae719		LSL $6, R24, R25										
  q8_codegen_test.go:109	0x100444e1c		bc777a01		FMOVS (R16)(R23<<2), F1										
  q8_codegen_test.go:110	0x100444e20		d37ae6f7		LSL $6, R23, R23										
  q8_codegen_test.go:110	0x100444e24		eb18191f		CMP R24<<6, R8											
  q8_codegen_test.go:110	0x100444e28		9a99b119		CSEL LT, R8, R25, R25										
  q8_codegen_test.go:110	0x100444e2c		1e2703e2		FMOVS ZR, F2											
  q8_codegen_test.go:110	0x100444e30		1e2703e3		FMOVS ZR, F3											
  q8_codegen_test.go:110	0x100444e34		1e2703e4		FMOVS ZR, F4											
  q8_codegen_test.go:110	0x100444e38		1e2703e5		FMOVS ZR, F5											
  q8_codegen_test.go:110	0x100444e3c		14000006		JMP 6(PC)											
  q8_codegen_test.go:116	0x100444e40		bc777ac6		FMOVS (R22)(R23<<2), F6										
  q8_codegen_test.go:116	0x100444e44		38b76a9e		MOVB (R20)(R23), R30										
  q8_codegen_test.go:116	0x100444e48		1e2203c7		SCVTFWS R30, F7											
  q8_codegen_test.go:116	0x100444e4c		1f0708c2		FMADDS F7, F2, F6, F2										
  q8_codegen_test.go:112	0x100444e50		aa1a03f7		MOVD R26, R23											
  q8_codegen_test.go:112	0x100444e54		910012fa		ADD $4, R23, R26										
  q8_codegen_test.go:112	0x100444e58		eb1a033f		CMP R26, R25											
  q8_codegen_test.go:112	0x100444e5c		5400032b		BLT 25(PC)											
  q8_codegen_test.go:113	0x100444e60		eb0802ff		CMP R8, R23											
  q8_codegen_test.go:113	0x100444e64		540006a2		BCS 53(PC)											
  q8_codegen_test.go:113	0x100444e68		bc777ac6		FMOVS (R22)(R23<<2), F6										
  q8_codegen_test.go:113	0x100444e6c		38b76a9e		MOVB (R20)(R23), R30										
  q8_codegen_test.go:113	0x100444e70		1e2203c7		SCVTFWS R30, F7											
  q8_codegen_test.go:114	0x100444e74		910006fe		ADD $1, R23, R30										
  q8_codegen_test.go:113	0x100444e78		1f070cc3		FMADDS F7, F3, F6, F3										
  q8_codegen_test.go:114	0x100444e7c		eb1e011f		CMP R30, R8											
  q8_codegen_test.go:114	0x100444e80		54000589		BLS 44(PC)											
  q8_codegen_test.go:114	0x100444e84		bc7e7ac6		FMOVS (R22)(R30<<2), F6										
  q8_codegen_test.go:114	0x100444e88		38be6a9e		MOVB (R20)(R30), R30										
  q8_codegen_test.go:114	0x100444e8c		1e2203c7		SCVTFWS R30, F7											
  q8_codegen_test.go:115	0x100444e90		91000afe		ADD $2, R23, R30										
  q8_codegen_test.go:114	0x100444e94		1f0710c4		FMADDS F7, F4, F6, F4										
  q8_codegen_test.go:115	0x100444e98		eb1e011f		CMP R30, R8											
  q8_codegen_test.go:115	0x100444e9c		54000469		BLS 35(PC)											
  q8_codegen_test.go:115	0x100444ea0		bc7e7ac6		FMOVS (R22)(R30<<2), F6										
  q8_codegen_test.go:115	0x100444ea4		38be6a9e		MOVB (R20)(R30), R30										
  q8_codegen_test.go:115	0x100444ea8		1e2203c7		SCVTFWS R30, F7											
  q8_codegen_test.go:116	0x100444eac		91000ef7		ADD $3, R23, R23										
  q8_codegen_test.go:115	0x100444eb0		1f0714c5		FMADDS F7, F5, F6, F5										
  q8_codegen_test.go:116	0x100444eb4		eb17011f		CMP R23, R8											
  q8_codegen_test.go:116	0x100444eb8		54fffc48		BHI -30(PC)											
  q8_codegen_test.go:116	0x100444ebc		14000019		JMP 25(PC)											
  q8_codegen_test.go:118	0x100444ec0		1e242863		FADDS F4, F3, F3										
  q8_codegen_test.go:118	0x100444ec4		1e2228a2		FADDS F2, F5, F2										
  q8_codegen_test.go:118	0x100444ec8		1e222862		FADDS F2, F3, F2										
  q8_codegen_test.go:119	0x100444ecc		14000006		JMP 6(PC)											
  q8_codegen_test.go:120	0x100444ed0		bc777ac3		FMOVS (R22)(R23<<2), F3										
  q8_codegen_test.go:120	0x100444ed4		38b76a9a		MOVB (R20)(R23), R26										
  q8_codegen_test.go:120	0x100444ed8		1e220344		SCVTFWS R26, F4											
  q8_codegen_test.go:120	0x100444edc		1f040862		FMADDS F4, F2, F3, F2										
  q8_codegen_test.go:119	0x100444ee0		910006f7		ADD $1, R23, R23										
  q8_codegen_test.go:119	0x100444ee4		eb1902ff		CMP R25, R23											
  q8_codegen_test.go:119	0x100444ee8		54fff8ea		BGE -57(PC)											
  q8_codegen_test.go:120	0x100444eec		eb0802ff		CMP R8, R23											
  q8_codegen_test.go:120	0x100444ef0		54ffff03		BCC -8(PC)											
  q8_codegen_test.go:120	0x100444ef4		14000009		JMP 9(PC)											
  q8_codegen_test.go:124	0x100444ef8		9b0f392f		MADD R15, R14, R9, R15										
  q8_codegen_test.go:124	0x100444efc		eb0f019f		CMP R15, R12											
  q8_codegen_test.go:124	0x100444f00		54fff608		BHI -80(PC)											
  q8_codegen_test.go:124	0x100444f04		14000004		JMP 4(PC)											
  q8_codegen_test.go:129	0x100444f08		a97ffbfd		LDP -8(RSP), (R29, R30)										
  q8_codegen_test.go:129	0x100444f0c		9104c3ff		ADD $304, RSP, RSP										
  q8_codegen_test.go:129	0x100444f10		d65f03c0		RET												
  q8_codegen_test.go:124	0x100444f14		97f1162b		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:120	0x100444f18		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:120	0x100444f1c		97f11629		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:116	0x100444f20		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:116	0x100444f24		97f11627		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:115	0x100444f28		aa1e03e0		MOVD R30, R0											
  q8_codegen_test.go:115	0x100444f2c		97f11625		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:114	0x100444f30		aa1e03e0		MOVD R30, R0											
  q8_codegen_test.go:114	0x100444f34		97f11623		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:113	0x100444f38		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:113	0x100444f3c		97f11621		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:107	0x100444f40		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:107	0x100444f44		aa1603e1		MOVD R22, R1											
  q8_codegen_test.go:107	0x100444f48		97f1161e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:107	0x100444f4c		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:107	0x100444f50		97f1161c		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:23		0x100444f54		f94047e0		MOVD 136(RSP), R0										
  q8_codegen_test.go:23		0x100444f58		f940a3e1		MOVD 320(RSP), R1										
  q8_codegen_test.go:25		0x100444f5c		f94053e2		MOVD 160(RSP), R2										
  q8_codegen_test.go:107	0x100444f60		f94087e3		MOVD 264(RSP), R3										
  q8_codegen_test.go:107	0x100444f64		f9403be4		MOVD 112(RSP), R4										
  q8_codegen_test.go:103	0x100444f68		f9407be5		MOVD 240(RSP), R5										
  q8_codegen_test.go:26		0x100444f6c		f9408fe6		MOVD 280(RSP), R6										
  q8_codegen_test.go:106	0x100444f70		f9405be7		MOVD 176(RSP), R7										
  q8_codegen_test.go:75		0x100444f74		f9405fe8		MOVD 184(RSP), R8										
  q8_codegen_test.go:103	0x100444f78		f9404fe9		MOVD 152(RSP), R9										
  q8_codegen_test.go:74		0x100444f7c		f94063ea		MOVD 192(RSP), R10										
  q8_codegen_test.go:103	0x100444f80		f9402bec		MOVD 80(RSP), R12										
  q8_codegen_test.go:103	0x100444f84		f94077ed		MOVD 232(RSP), R13										
  q8_codegen_test.go:103	0x100444f88		f94057ee		MOVD 168(RSP), R14										
  q8_codegen_test.go:28		0x100444f8c		f9404bef		MOVD 144(RSP), R15										
  q8_codegen_test.go:74		0x100444f90		f94093f0		MOVD 288(RSP), R16										
  q8_codegen_test.go:77		0x100444f94		f9403ff1		MOVD 120(RSP), R17										
  q8_codegen_test.go:25		0x100444f98		f94073f3		MOVD 224(RSP), R19										
  q8_codegen_test.go:84		0x100444f9c		f9408bf4		MOVD 272(RSP), R20										
  q8_codegen_test.go:106	0x100444fa0		f9406ff5		MOVD 216(RSP), R21										
  q8_codegen_test.go:103	0x100444fa4		f9406bf6		MOVD 208(RSP), R22										
  q8_codegen_test.go:77		0x100444fa8		f9402ff7		MOVD 88(RSP), R23										
  q8_codegen_test.go:85		0x100444fac		f94033f8		MOVD 96(RSP), R24										
  q8_codegen_test.go:77		0x100444fb0		f94037f9		MOVD 104(RSP), R25										
  q8_codegen_test.go:85		0x100444fb4		f94083fa		MOVD 256(RSP), R26										
  q8_codegen_test.go:89		0x100444fb8		f9407ffe		MOVD 248(RSP), R30										
  q8_codegen_test.go:74		0x100444fbc		f94067eb		MOVD 200(RSP), R11										
  q8_codegen_test.go:74		0x100444fc0		1e204002		FMOVS F0, F2											
  q8_codegen_test.go:74		0x100444fc4		1e204020		FMOVS F1, F0											
  q8_codegen_test.go:74		0x100444fc8		1e204041		FMOVS F2, F1											
  q8_codegen_test.go:74		0x100444fcc		eb0a017f		CMP R10, R11											
  q8_codegen_test.go:74		0x100444fd0		5400056a		BGE 43(PC)											
  q8_codegen_test.go:75		0x100444fd4		91000561		ADD $1, R11, R1											
  q8_codegen_test.go:75		0x100444fd8		f90067e1		MOVD R1, 200(RSP)										
  q8_codegen_test.go:75		0x100444fdc		d37ae420		LSL $6, R1, R0											
  q8_codegen_test.go:74		0x100444fe0		bc6b7a02		FMOVS (R16)(R11<<2), F2										
  q8_codegen_test.go:75		0x100444fe4		d37ae56f		LSL $6, R11, R15										
  q8_codegen_test.go:75		0x100444fe8		eb01191f		CMP R1<<6, R8											
  q8_codegen_test.go:75		0x100444fec		9a80b100		CSEL LT, R8, R0, R0										
  q8_codegen_test.go:76		0x100444ff0		cb0b1806		SUB R11<<6, R0, R6										
  q8_codegen_test.go:76		0x100444ff4		f10100df		CMP $64, R6											
  q8_codegen_test.go:75		0x100444ff8		54000140		BEQ 10(PC)											
  q8_codegen_test.go:76		0x100444ffc		1e2703e3		FMOVS ZR, F3											
  q8_codegen_test.go:76		0x100445000		1e2703e4		FMOVS ZR, F4											
  q8_codegen_test.go:76		0x100445004		1e2703e5		FMOVS ZR, F5											
  q8_codegen_test.go:76		0x100445008		1e2703e6		FMOVS ZR, F6											
  q8_codegen_test.go:76		0x10044500c		1e2703e7		FMOVS ZR, F7											
  q8_codegen_test.go:76		0x100445010		1e2703e8		FMOVS ZR, F8											
  q8_codegen_test.go:76		0x100445014		1e2703e9		FMOVS ZR, F9											
  q8_codegen_test.go:76		0x100445018		1e2703ea		FMOVS ZR, F10											
  q8_codegen_test.go:76		0x10044501c		14000040		JMP 64(PC)											
  q8_codegen_test.go:77		0x100445020		eb19001f		CMP R25, R0											
  q8_codegen_test.go:77		0x100445024		54000548		BHI 42(PC)											
  q8_codegen_test.go:77		0x100445028		eb0b181f		CMP R11<<6, R0											
  q8_codegen_test.go:77		0x10044502c		540004e3		BCC 39(PC)											
  q8_codegen_test.go:77		0x100445030		8b0b2346		ADD R11<<8, R26, R6										
  q8_codegen_test.go:77		0x100445034		eb17001f		CMP R23, R0											
  q8_codegen_test.go:77		0x100445038		54000448		BHI 34(PC)											
  q8_codegen_test.go:77		0x10044503c		8b0b23cf		ADD R11<<8, R30, R15										
  q8_codegen_test.go:77		0x100445040		eb11001f		CMP R17, R0											
  q8_codegen_test.go:77		0x100445044		540003a8		BHI 29(PC)											
  q8_codegen_test.go:74		0x100445048		bd002fe2		FMOVS F2, 44(RSP)										
  q8_codegen_test.go:74		0x10044504c		bd003fe0		FMOVS F0, 60(RSP)										
  q8_codegen_test.go:74		0x100445050		bd0047e1		FMOVS F1, 68(RSP)										
  q8_codegen_test.go:77		0x100445054		8b0b1a82		ADD R11<<6, R20, R2										
  q8_codegen_test.go:77		0x100445058		aa0603e0		MOVD R6, R0											
  q8_codegen_test.go:77		0x10044505c		aa0f03e1		MOVD R15, R1											
  q8_codegen_test.go:77		0x100445060		97fbc3b8		CALL github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.dotQ8PairBlock64(SB)		
  q8_codegen_test.go:78		0x100445064		bd4047e2		FMOVS 68(RSP), F2										
  q8_codegen_test.go:78		0x100445068		bd402fe3		FMOVS 44(RSP), F3										
  q8_codegen_test.go:78		0x10044506c		1f000860		FMADDS F0, F2, F3, F0										
  q8_codegen_test.go:79		0x100445070		bd403fe2		FMOVS 60(RSP), F2										
  q8_codegen_test.go:79		0x100445074		1f010861		FMADDS F1, F2, F3, F1										
  q8_codegen_test.go:80		0x100445078		17ffffb7		JMP -73(PC)											
  q8_codegen_test.go:103	0x10044507c		9b097dab		MUL R9, R13, R11										
  q8_codegen_test.go:103	0x100445080		8b0b09cb		ADD R11<<2, R14, R11										
  q8_codegen_test.go:103	0x100445084		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:103	0x100445088		54000169		BLS 11(PC)											
  q8_codegen_test.go:103	0x10044508c		bc2b78a1		FMOVS F1, (R5)(R11<<2)										
  q8_codegen_test.go:103	0x100445090		9b093acb		MADD R9, R14, R22, R11										
  q8_codegen_test.go:103	0x100445094		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:103	0x100445098		540000c9		BLS 6(PC)											
  q8_codegen_test.go:103	0x10044509c		bc2b78a0		FMOVS F0, (R5)(R11<<2)										
  q8_codegen_test.go:24		0x1004450a0		f94043eb		MOVD 128(RSP), R11										
  q8_codegen_test.go:28		0x1004450a4		aa0f03f1		MOVD R15, R17											
  q8_codegen_test.go:106	0x1004450a8		aa1503ef		MOVD R21, R15											
  q8_codegen_test.go:104	0x1004450ac		17ffff47		JMP -185(PC)											
  q8_codegen_test.go:103	0x1004450b0		97f115c4		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:103	0x1004450b4		97f115c3		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:77		0x1004450b8		aa1103e1		MOVD R17, R1											
  q8_codegen_test.go:77		0x1004450bc		97f115c1		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:77		0x1004450c0		aa1703e1		MOVD R23, R1											
  q8_codegen_test.go:77		0x1004450c4		97f115bf		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:77		0x1004450c8		97f115be		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:77		0x1004450cc		aa1903e1		MOVD R25, R1											
  q8_codegen_test.go:77		0x1004450d0		97f115bc		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:84		0x1004450d4		1e2202ae		SCVTFWS R21, F14										
  q8_codegen_test.go:88		0x1004450d8		bc647b4f		FMOVS (R26)(R4<<2), F15										
  q8_codegen_test.go:89		0x1004450dc		bc6f7bd0		FMOVS (R30)(R15<<2), F16									
  q8_codegen_test.go:90		0x1004450e0		bc6b7bd1		FMOVS (R30)(R11<<2), F17									
  q8_codegen_test.go:91		0x1004450e4		bc737bd2		FMOVS (R30)(R19<<2), F18									
  q8_codegen_test.go:92		0x1004450e8		bc647bd3		FMOVS (R30)(R4<<2), F19										
  q8_codegen_test.go:88		0x1004450ec		1f0f15c5		FMADDS F15, F5, F14, F5										
  q8_codegen_test.go:89		0x1004450f0		1f101d67		FMADDS F16, F7, F11, F7										
  q8_codegen_test.go:90		0x1004450f4		1f112188		FMADDS F17, F8, F12, F8										
  q8_codegen_test.go:91		0x1004450f8		1f1229aa		FMADDS F18, F10, F13, F10									
  q8_codegen_test.go:92		0x1004450fc		1f1311c4		FMADDS F19, F4, F14, F4										
  q8_codegen_test.go:25		0x100445100		f94053e2		MOVD 160(RSP), R2										
  q8_codegen_test.go:107	0x100445104		f94087e3		MOVD 264(RSP), R3										
  q8_codegen_test.go:107	0x100445108		f9403be4		MOVD 112(RSP), R4										
  q8_codegen_test.go:106	0x10044510c		f9405be7		MOVD 176(RSP), R7										
  q8_codegen_test.go:25		0x100445110		f94073f3		MOVD 224(RSP), R19										
  q8_codegen_test.go:106	0x100445114		f9406ff5		MOVD 216(RSP), R21										
  q8_codegen_test.go:83		0x100445118		aa0603ef		MOVD R6, R15											
  q8_codegen_test.go:83		0x10044511c		910011e6		ADD $4, R15, R6											
  q8_codegen_test.go:83		0x100445120		eb06001f		CMP R6, R0											
  q8_codegen_test.go:83		0x100445124		5400044b		BLT 34(PC)											
  q8_codegen_test.go:84		0x100445128		eb0801ff		CMP R8, R15											
  q8_codegen_test.go:84		0x10044512c		54000922		BCS 73(PC)											
  q8_codegen_test.go:84		0x100445130		910005eb		ADD $1, R15, R11										
  q8_codegen_test.go:84		0x100445134		38af6a82		MOVB (R20)(R15), R2										
  q8_codegen_test.go:84		0x100445138		eb0b011f		CMP R11, R8											
  q8_codegen_test.go:84		0x10044513c		54000889		BLS 68(PC)											
  q8_codegen_test.go:84		0x100445140		910009f3		ADD $2, R15, R19										
  q8_codegen_test.go:84		0x100445144		38ab6a83		MOVB (R20)(R11), R3										
  q8_codegen_test.go:84		0x100445148		eb13011f		CMP R19, R8											
  q8_codegen_test.go:84		0x10044514c		540007c9		BLS 62(PC)											
  q8_codegen_test.go:84		0x100445150		91000de4		ADD $3, R15, R4											
  q8_codegen_test.go:84		0x100445154		38b36a87		MOVB (R20)(R19), R7										
  q8_codegen_test.go:84		0x100445158		eb04011f		CMP R4, R8											
  q8_codegen_test.go:84		0x10044515c		54000729		BLS 57(PC)											
  q8_codegen_test.go:84		0x100445160		38a46a95		MOVB (R20)(R4), R21										
  q8_codegen_test.go:85		0x100445164		eb1801ff		CMP R24, R15											
  q8_codegen_test.go:85		0x100445168		54000682		BCS 52(PC)											
  q8_codegen_test.go:84		0x10044516c		1e22004b		SCVTFWS R2, F11											
  q8_codegen_test.go:85		0x100445170		bc6f7b4c		FMOVS (R26)(R15<<2), F12									
  q8_codegen_test.go:85		0x100445174		1f0c0d63		FMADDS F12, F3, F11, F3										
  q8_codegen_test.go:86		0x100445178		eb0b031f		CMP R11, R24											
  q8_codegen_test.go:86		0x10044517c		540005a9		BLS 45(PC)											
  q8_codegen_test.go:84		0x100445180		1e22006c		SCVTFWS R3, F12											
  q8_codegen_test.go:86		0x100445184		bc6b7b4d		FMOVS (R26)(R11<<2), F13									
  q8_codegen_test.go:86		0x100445188		1f0d2589		FMADDS F13, F9, F12, F9										
  q8_codegen_test.go:87		0x10044518c		eb13031f		CMP R19, R24											
  q8_codegen_test.go:87		0x100445190		540004a9		BLS 37(PC)											
  q8_codegen_test.go:84		0x100445194		1e2200ed		SCVTFWS R7, F13											
  q8_codegen_test.go:87		0x100445198		bc737b4e		FMOVS (R26)(R19<<2), F14									
  q8_codegen_test.go:87		0x10044519c		1f0e19a6		FMADDS F14, F6, F13, F6										
  q8_codegen_test.go:88		0x1004451a0		eb04031f		CMP R4, R24											
  q8_codegen_test.go:88		0x1004451a4		54fff988		BHI -52(PC)											
  q8_codegen_test.go:88		0x1004451a8		1400001d		JMP 29(PC)											
  q8_codegen_test.go:94		0x1004451ac		1e292863		FADDS F9, F3, F3										
  q8_codegen_test.go:94		0x1004451b0		1e2528c5		FADDS F5, F6, F5										
  q8_codegen_test.go:94		0x1004451b4		1e2828e6		FADDS F8, F7, F6										
  q8_codegen_test.go:94		0x1004451b8		1e242944		FADDS F4, F10, F4										
  q8_codegen_test.go:94		0x1004451bc		1e2328a3		FADDS F3, F5, F3										
  q8_codegen_test.go:94		0x1004451c0		1e262884		FADDS F6, F4, F4										
  q8_codegen_test.go:95		0x1004451c4		14000007		JMP 7(PC)											
  q8_codegen_test.go:96		0x1004451c8		1e2200c5		SCVTFWS R6, F5											
  q8_codegen_test.go:97		0x1004451cc		bc6f7b46		FMOVS (R26)(R15<<2), F6										
  q8_codegen_test.go:98		0x1004451d0		bc6f7bc7		FMOVS (R30)(R15<<2), F7										
  q8_codegen_test.go:97		0x1004451d4		1f060ca3		FMADDS F6, F3, F5, F3										
  q8_codegen_test.go:98		0x1004451d8		1f0710a4		FMADDS F7, F4, F5, F4										
  q8_codegen_test.go:95		0x1004451dc		910005ef		ADD $1, R15, R15										
  q8_codegen_test.go:95		0x1004451e0		eb0001ff		CMP R0, R15											
  q8_codegen_test.go:95		0x1004451e4		540000ea		BGE 7(PC)											
  q8_codegen_test.go:96		0x1004451e8		eb0801ff		CMP R8, R15											
  q8_codegen_test.go:96		0x1004451ec		54000162		BCS 11(PC)											
  q8_codegen_test.go:96		0x1004451f0		38af6a86		MOVB (R20)(R15), R6										
  q8_codegen_test.go:97		0x1004451f4		eb1801ff		CMP R24, R15											
  q8_codegen_test.go:97		0x1004451f8		54fffe83		BCC -12(PC)											
  q8_codegen_test.go:97		0x1004451fc		14000005		JMP 5(PC)											
  q8_codegen_test.go:100	0x100445200		1f030443		FMADDS F3, F1, F2, F3										
  q8_codegen_test.go:101	0x100445204		1f040041		FMADDS F4, F0, F2, F1										
  q8_codegen_test.go:74		0x100445208		1e204060		FMOVS F3, F0											
  q8_codegen_test.go:101	0x10044520c		17ffff52		JMP -174(PC)											
  q8_codegen_test.go:97		0x100445210		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:97		0x100445214		97f1156b		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:96		0x100445218		97f1156a		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:88		0x10044521c		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:88		0x100445220		97f11568		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:87		0x100445224		aa1303e0		MOVD R19, R0											
  q8_codegen_test.go:87		0x100445228		aa1803e1		MOVD R24, R1											
  q8_codegen_test.go:87		0x10044522c		97f11565		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:86		0x100445230		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:86		0x100445234		97f11563		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:85		0x100445238		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:85		0x10044523c		97f11561		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:84		0x100445240		97f11560		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:84		0x100445244		aa1303e0		MOVD R19, R0											
  q8_codegen_test.go:84		0x100445248		97f1155e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:84		0x10044524c		97f1155d		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:84		0x100445250		97f1155c		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:72		0x100445254		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:72		0x100445258		aa1e03e1		MOVD R30, R1											
  q8_codegen_test.go:72		0x10044525c		97f11559		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:72		0x100445260		aa1e03e0		MOVD R30, R0											
  q8_codegen_test.go:72		0x100445264		97f11557		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:72		0x100445268		d37ef700		LSL $2, R24, R0											
  q8_codegen_test.go:72		0x10044526c		aa1703e1		MOVD R23, R1											
  q8_codegen_test.go:72		0x100445270		97f11554		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:72		0x100445274		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:72		0x100445278		97f11552		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:62		0x10044527c		1f060080		FMADDS F6, F0, F4, F0										
  q8_codegen_test.go:63		0x100445280		1f070481		FMADDS F7, F1, F4, F1										
  q8_codegen_test.go:64		0x100445284		1f050882		FMADDS F5, F2, F4, F2										
  q8_codegen_test.go:65		0x100445288		1f080c83		FMADDS F8, F3, F4, F3										
  q8_codegen_test.go:23		0x10044528c		f94047e0		MOVD 136(RSP), R0										
  q8_codegen_test.go:29		0x100445290		f94087e3		MOVD 264(RSP), R3										
  q8_codegen_test.go:32		0x100445294		aa0103f6		MOVD R1, R22											
  q8_codegen_test.go:32		0x100445298		eb0a02df		CMP R10, R22											
  q8_codegen_test.go:32		0x10044529c		5400114a		BGE 138(PC)											
  q8_codegen_test.go:32		0x1004452a0		bd0037e3		FMOVS F3, 52(RSP)										
  q8_codegen_test.go:32		0x1004452a4		bd003be2		FMOVS F2, 56(RSP)										
  q8_codegen_test.go:32		0x1004452a8		bd0043e1		FMOVS F1, 64(RSP)										
  q8_codegen_test.go:32		0x1004452ac		bd004be0		FMOVS F0, 72(RSP)										
  q8_codegen_test.go:34		0x1004452b0		910006c1		ADD $1, R22, R1											
  q8_codegen_test.go:34		0x1004452b4		d37ae420		LSL $6, R1, R0											
  q8_codegen_test.go:32		0x1004452b8		bc767a04		FMOVS (R16)(R22<<2), F4										
  q8_codegen_test.go:32		0x1004452bc		bd0033e4		FMOVS F4, 48(RSP)										
  q8_codegen_test.go:34		0x1004452c0		d37ae6d6		LSL $6, R22, R22										
  q8_codegen_test.go:34		0x1004452c4		eb01191f		CMP R1<<6, R8											
  q8_codegen_test.go:34		0x1004452c8		9a80b100		CSEL LT, R8, R0, R0										
  q8_codegen_test.go:34		0x1004452cc		1e2703e5		FMOVS ZR, F5											
  q8_codegen_test.go:34		0x1004452d0		1e2703e6		FMOVS ZR, F6											
  q8_codegen_test.go:34		0x1004452d4		1e2703e7		FMOVS ZR, F7											
  q8_codegen_test.go:34		0x1004452d8		1e2703e8		FMOVS ZR, F8											
  q8_codegen_test.go:34		0x1004452dc		1e2703e9		FMOVS ZR, F9											
  q8_codegen_test.go:34		0x1004452e0		1e2703ea		FMOVS ZR, F10											
  q8_codegen_test.go:34		0x1004452e4		1e2703eb		FMOVS ZR, F11											
  q8_codegen_test.go:34		0x1004452e8		1e2703ec		FMOVS ZR, F12											
  q8_codegen_test.go:34		0x1004452ec		1e2703ed		FMOVS ZR, F13											
  q8_codegen_test.go:34		0x1004452f0		1e2703ee		FMOVS ZR, F14											
  q8_codegen_test.go:34		0x1004452f4		1e2703ef		FMOVS ZR, F15											
  q8_codegen_test.go:34		0x1004452f8		1e2703f0		FMOVS ZR, F16											
  q8_codegen_test.go:34		0x1004452fc		1e2703f1		FMOVS ZR, F17											
  q8_codegen_test.go:34		0x100445300		1e2703f2		FMOVS ZR, F18											
  q8_codegen_test.go:34		0x100445304		1e2703f3		FMOVS ZR, F19											
  q8_codegen_test.go:34		0x100445308		1e2703f4		FMOVS ZR, F20											
  q8_codegen_test.go:34		0x10044530c		1400002b		JMP 43(PC)											
  q8_codegen_test.go:39		0x100445310		bd004fe6		FMOVS F6, 76(RSP)										
  q8_codegen_test.go:36		0x100445314		1e2203d8		SCVTFWS R30, F24										
  q8_codegen_test.go:40		0x100445318		bc627b19		FMOVS (R24)(R2<<2), F25										
  q8_codegen_test.go:41		0x10044531c		bc767aba		FMOVS (R21)(R22<<2), F26									
  q8_codegen_test.go:42		0x100445320		bc647abb		FMOVS (R21)(R4<<2), F27										
  q8_codegen_test.go:43		0x100445324		bc6f7abc		FMOVS (R21)(R15<<2), F28									
  q8_codegen_test.go:44		0x100445328		bc627abd		FMOVS (R21)(R2<<2), F29										
  q8_codegen_test.go:45		0x10044532c		bc767b5e		FMOVS (R26)(R22<<2), F30									
  q8_codegen_test.go:46		0x100445330		bc647b5f		FMOVS (R26)(R4<<2), F31										
  q8_codegen_test.go:47		0x100445334		bc6f7b43		FMOVS (R26)(R15<<2), F3										
  q8_codegen_test.go:48		0x100445338		bc627b42		FMOVS (R26)(R2<<2), F2										
  q8_codegen_test.go:49		0x10044533c		bc767961		FMOVS (R11)(R22<<2), F1										
  q8_codegen_test.go:50		0x100445340		bc647960		FMOVS (R11)(R4<<2), F0										
  q8_codegen_test.go:51		0x100445344		bc6f7964		FMOVS (R11)(R15<<2), F4										
  q8_codegen_test.go:52		0x100445348		bc627966		FMOVS (R11)(R2<<2), F6										
  q8_codegen_test.go:40		0x10044534c		1f195314		FMADDS F25, F20, F24, F20									
  q8_codegen_test.go:41		0x100445350		1f1a26a9		FMADDS F26, F9, F21, F9										
  q8_codegen_test.go:42		0x100445354		1f1b3ace		FMADDS F27, F14, F22, F14									
  q8_codegen_test.go:43		0x100445358		1f1c2aea		FMADDS F28, F10, F23, F10									
  q8_codegen_test.go:44		0x10044535c		1f1d370d		FMADDS F29, F13, F24, F13									
  q8_codegen_test.go:45		0x100445360		1f1e2eab		FMADDS F30, F11, F21, F11									
  q8_codegen_test.go:46		0x100445364		1f1f16c5		FMADDS F31, F5, F22, F5										
  q8_codegen_test.go:47		0x100445368		1f034ef3		FMADDS F3, F19, F23, F19									
  q8_codegen_test.go:48		0x10044536c		1f023f0f		FMADDS F2, F15, F24, F15									
  q8_codegen_test.go:49		0x100445370		1f0132ac		FMADDS F1, F12, F21, F12									
  q8_codegen_test.go:50		0x100445374		1f0042d0		FMADDS F0, F16, F22, F16									
  q8_codegen_test.go:51		0x100445378		1f044af2		FMADDS F4, F18, F23, F18									
  q8_codegen_test.go:52		0x10044537c		1f064711		FMADDS F6, F17, F24, F17									
  q8_codegen_test.go:25		0x100445380		f94053e2		MOVD 160(RSP), R2										
  q8_codegen_test.go:29		0x100445384		f9403be4		MOVD 112(RSP), R4										
  q8_codegen_test.go:26		0x100445388		f9408fe6		MOVD 280(RSP), R6										
  q8_codegen_test.go:28		0x10044538c		f9405be7		MOVD 176(RSP), R7										
  q8_codegen_test.go:28		0x100445390		f9404bef		MOVD 144(RSP), R15										
  q8_codegen_test.go:25		0x100445394		f94073f3		MOVD 224(RSP), R19										
  q8_codegen_test.go:68		0x100445398		f9406ffe		MOVD 216(RSP), R30										
  q8_codegen_test.go:62		0x10044539c		bd404be0		FMOVS 72(RSP), F0										
  q8_codegen_test.go:63		0x1004453a0		bd4043e1		FMOVS 64(RSP), F1										
  q8_codegen_test.go:64		0x1004453a4		bd403be2		FMOVS 56(RSP), F2										
  q8_codegen_test.go:65		0x1004453a8		bd4037e3		FMOVS 52(RSP), F3										
  q8_codegen_test.go:62		0x1004453ac		bd4033e4		FMOVS 48(RSP), F4										
  q8_codegen_test.go:35		0x1004453b0		aa0303f6		MOVD R3, R22											
  q8_codegen_test.go:35		0x1004453b4		bd404fe6		FMOVS 76(RSP), F6										
  q8_codegen_test.go:35		0x1004453b8		910012c3		ADD $4, R22, R3											
  q8_codegen_test.go:35		0x1004453bc		eb03001f		CMP R3, R0											
  q8_codegen_test.go:35		0x1004453c0		5400044b		BLT 34(PC)											
  q8_codegen_test.go:36		0x1004453c4		eb0802df		CMP R8, R22											
  q8_codegen_test.go:36		0x1004453c8		54000d22		BCS 105(PC)											
  q8_codegen_test.go:36		0x1004453cc		910006c4		ADD $1, R22, R4											
  q8_codegen_test.go:36		0x1004453d0		38b66a87		MOVB (R20)(R22), R7										
  q8_codegen_test.go:36		0x1004453d4		eb04011f		CMP R4, R8											
  q8_codegen_test.go:36		0x1004453d8		54000c89		BLS 100(PC)											
  q8_codegen_test.go:36		0x1004453dc		91000acf		ADD $2, R22, R15										
  q8_codegen_test.go:36		0x1004453e0		38a46a86		MOVB (R20)(R4), R6										
  q8_codegen_test.go:36		0x1004453e4		eb0f011f		CMP R15, R8											
  q8_codegen_test.go:36		0x1004453e8		54000be9		BLS 95(PC)											
  q8_codegen_test.go:36		0x1004453ec		91000ec2		ADD $3, R22, R2											
  q8_codegen_test.go:36		0x1004453f0		38af6a93		MOVB (R20)(R15), R19										
  q8_codegen_test.go:36		0x1004453f4		eb02011f		CMP R2, R8											
  q8_codegen_test.go:36		0x1004453f8		54000b49		BLS 90(PC)											
  q8_codegen_test.go:36		0x1004453fc		38a26a9e		MOVB (R20)(R2), R30										
  q8_codegen_test.go:37		0x100445400		eb1702df		CMP R23, R22											
  q8_codegen_test.go:37		0x100445404		54000a82		BCS 84(PC)											
  q8_codegen_test.go:36		0x100445408		1e2200f5		SCVTFWS R7, F21											
  q8_codegen_test.go:37		0x10044540c		bc767b16		FMOVS (R24)(R22<<2), F22									
  q8_codegen_test.go:37		0x100445410		1f1622a8		FMADDS F22, F8, F21, F8										
  q8_codegen_test.go:38		0x100445414		eb0402ff		CMP R4, R23											
  q8_codegen_test.go:38		0x100445418		540009a9		BLS 77(PC)											
  q8_codegen_test.go:36		0x10044541c		1e2200d6		SCVTFWS R6, F22											
  q8_codegen_test.go:38		0x100445420		bc647b17		FMOVS (R24)(R4<<2), F23										
  q8_codegen_test.go:38		0x100445424		1f171ec7		FMADDS F23, F7, F22, F7										
  q8_codegen_test.go:39		0x100445428		eb0f02ff		CMP R15, R23											
  q8_codegen_test.go:39		0x10044542c		540008c9		BLS 70(PC)											
  q8_codegen_test.go:36		0x100445430		1e220277		SCVTFWS R19, F23										
  q8_codegen_test.go:39		0x100445434		bc6f7b18		FMOVS (R24)(R15<<2), F24									
  q8_codegen_test.go:39		0x100445438		1f181ae6		FMADDS F24, F6, F23, F6										
  q8_codegen_test.go:40		0x10044543c		eb0202ff		CMP R2, R23											
  q8_codegen_test.go:40		0x100445440		54fff688		BHI -76(PC)											
  q8_codegen_test.go:40		0x100445444		1400003e		JMP 62(PC)											
  q8_codegen_test.go:54		0x100445448		1e272907		FADDS F7, F8, F7										
  q8_codegen_test.go:54		0x10044544c		1e3428c6		FADDS F20, F6, F6										
  q8_codegen_test.go:54		0x100445450		1e2e2928		FADDS F14, F9, F8										
  q8_codegen_test.go:54		0x100445454		1e2d2949		FADDS F13, F10, F9										
  q8_codegen_test.go:54		0x100445458		1e252965		FADDS F5, F11, F5										
  q8_codegen_test.go:54		0x10044545c		1e2f2a6a		FADDS F15, F19, F10										
  q8_codegen_test.go:54		0x100445460		1e30298b		FADDS F16, F12, F11										
  q8_codegen_test.go:54		0x100445464		1e312a4c		FADDS F17, F18, F12										
  q8_codegen_test.go:54		0x100445468		1e2728c6		FADDS F7, F6, F6										
  q8_codegen_test.go:54		0x10044546c		1e282927		FADDS F8, F9, F7										
  q8_codegen_test.go:54		0x100445470		1e252945		FADDS F5, F10, F5										
  q8_codegen_test.go:54		0x100445474		1e2b2988		FADDS F11, F12, F8										
  q8_codegen_test.go:55		0x100445478		1400000b		JMP 11(PC)											
  q8_codegen_test.go:56		0x10044547c		1e220069		SCVTFWS R3, F9											
  q8_codegen_test.go:57		0x100445480		bc767b0a		FMOVS (R24)(R22<<2), F10									
  q8_codegen_test.go:58		0x100445484		bc767aab		FMOVS (R21)(R22<<2), F11									
  q8_codegen_test.go:59		0x100445488		bc767b4c		FMOVS (R26)(R22<<2), F12									
  q8_codegen_test.go:60		0x10044548c		bc76796d		FMOVS (R11)(R22<<2), F13									
  q8_codegen_test.go:57		0x100445490		1f0a1926		FMADDS F10, F6, F9, F6										
  q8_codegen_test.go:58		0x100445494		1f0b1d27		FMADDS F11, F7, F9, F7										
  q8_codegen_test.go:59		0x100445498		1f0c1525		FMADDS F12, F5, F9, F5										
  q8_codegen_test.go:60		0x10044549c		1f0d2128		FMADDS F13, F8, F9, F8										
  q8_codegen_test.go:55		0x1004454a0		910006d6		ADD $1, R22, R22										
  q8_codegen_test.go:55		0x1004454a4		eb0002df		CMP R0, R22											
  q8_codegen_test.go:55		0x1004454a8		54ffeeaa		BGE -139(PC)											
  q8_codegen_test.go:56		0x1004454ac		eb0802df		CMP R8, R22											
  q8_codegen_test.go:56		0x1004454b0		54000422		BCS 33(PC)											
  q8_codegen_test.go:56		0x1004454b4		38b66a83		MOVB (R20)(R22), R3										
  q8_codegen_test.go:57		0x1004454b8		eb1702df		CMP R23, R22											
  q8_codegen_test.go:57		0x1004454bc		54fffe03		BCC -16(PC)											
  q8_codegen_test.go:57		0x1004454c0		1400001a		JMP 26(PC)											
  q8_codegen_test.go:67		0x1004454c4		9b097dab		MUL R9, R13, R11										
  q8_codegen_test.go:67		0x1004454c8		8b0b09cb		ADD R11<<2, R14, R11										
  q8_codegen_test.go:67		0x1004454cc		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:67		0x1004454d0		540002a9		BLS 21(PC)											
  q8_codegen_test.go:67		0x1004454d4		bc2b78a0		FMOVS F0, (R5)(R11<<2)										
  q8_codegen_test.go:67		0x1004454d8		9b093a2b		MADD R9, R14, R17, R11										
  q8_codegen_test.go:67		0x1004454dc		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:67		0x1004454e0		54000209		BLS 16(PC)											
  q8_codegen_test.go:67		0x1004454e4		bc2b78a1		FMOVS F1, (R5)(R11<<2)										
  q8_codegen_test.go:68		0x1004454e8		9b093b2b		MADD R9, R14, R25, R11										
  q8_codegen_test.go:68		0x1004454ec		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:68		0x1004454f0		54000169		BLS 11(PC)											
  q8_codegen_test.go:68		0x1004454f4		bc2b78a2		FMOVS F2, (R5)(R11<<2)										
  q8_codegen_test.go:68		0x1004454f8		9b093bcb		MADD R9, R14, R30, R11										
  q8_codegen_test.go:68		0x1004454fc		eb0b019f		CMP R11, R12											
  q8_codegen_test.go:68		0x100445500		540000c9		BLS 6(PC)											
  q8_codegen_test.go:68		0x100445504		bc2b78a3		FMOVS F3, (R5)(R11<<2)										
  q8_codegen_test.go:23		0x100445508		f940a3e1		MOVD 320(RSP), R1										
  q8_codegen_test.go:24		0x10044550c		f94043eb		MOVD 128(RSP), R11										
  q8_codegen_test.go:28		0x100445510		aa0f03f1		MOVD R15, R17											
  q8_codegen_test.go:68		0x100445514		17fffdb1		JMP -591(PC)											
  q8_codegen_test.go:68		0x100445518		97f114aa		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:68		0x10044551c		97f114a9		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:67		0x100445520		97f114a8		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:67		0x100445524		97f114a7		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:57		0x100445528		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:57		0x10044552c		aa1703e1		MOVD R23, R1											
  q8_codegen_test.go:57		0x100445530		97f114a4		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:56		0x100445534		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:56		0x100445538		97f114a2		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:40		0x10044553c		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:40		0x100445540		97f114a0		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:39		0x100445544		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:39		0x100445548		97f1149e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:38		0x10044554c		aa1703e0		MOVD R23, R0											
  q8_codegen_test.go:38		0x100445550		97f1149c		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:37		0x100445554		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:37		0x100445558		aa1703e1		MOVD R23, R1											
  q8_codegen_test.go:37		0x10044555c		97f11499		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:36		0x100445560		97f11498		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:36		0x100445564		97f11497		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:36		0x100445568		97f11496		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:36		0x10044556c		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:36		0x100445570		97f11494		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:30		0x100445574		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:30		0x100445578		97f11492		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:30		0x10044557c		aa1603e0		MOVD R22, R0											
  q8_codegen_test.go:30		0x100445580		97f11490		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:30		0x100445584		aa1a03e0		MOVD R26, R0											
  q8_codegen_test.go:30		0x100445588		97f1148e		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:30		0x10044558c		97f1148d		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:29		0x100445590		aa1503e0		MOVD R21, R0											
  q8_codegen_test.go:29		0x100445594		aa1a03e1		MOVD R26, R1											
  q8_codegen_test.go:29		0x100445598		97f1148a		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:29		0x10044559c		aa1a03e0		MOVD R26, R0											
  q8_codegen_test.go:29		0x1004455a0		97f11488		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:29		0x1004455a4		d37ef6e0		LSL $2, R23, R0											
  q8_codegen_test.go:29		0x1004455a8		aa1503e1		MOVD R21, R1											
  q8_codegen_test.go:29		0x1004455ac		97f11485		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:29		0x1004455b0		aa1503e0		MOVD R21, R0											
  q8_codegen_test.go:29		0x1004455b4		97f11483		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:27		0x1004455b8		aa1503e0		MOVD R21, R0											
  q8_codegen_test.go:27		0x1004455bc		aa1803e1		MOVD R24, R1											
  q8_codegen_test.go:27		0x1004455c0		97f11480		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:27		0x1004455c4		aa1803e0		MOVD R24, R0											
  q8_codegen_test.go:27		0x1004455c8		aa1703e1		MOVD R23, R1											
  q8_codegen_test.go:27		0x1004455cc		97f1147d		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:26		0x1004455d0		aa1503e0		MOVD R21, R0											
  q8_codegen_test.go:26		0x1004455d4		aa1403e1		MOVD R20, R1											
  q8_codegen_test.go:26		0x1004455d8		97f1147a		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:26		0x1004455dc		aa1403e0		MOVD R20, R0											
  q8_codegen_test.go:26		0x1004455e0		aa1103e1		MOVD R17, R1											
  q8_codegen_test.go:26		0x1004455e4		97f11477		CALL runtime.panicBounds(SB)									
  q8_codegen_test.go:24		0x1004455e8		97f001be		CALL runtime.panicdivide(SB)									
  q8_codegen_test.go:24		0x1004455ec		d503201f		NOOP												
  q8_codegen_test.go:20		0x1004455f0		a90087e0		STP (R0, R1), 8(RSP)										
  q8_codegen_test.go:20		0x1004455f4		aa1e03e3		MOVD R30, R3											
  q8_codegen_test.go:20		0x1004455f8		97f10c0e		CALL runtime.morestack.abi0(SB)									
  q8_codegen_test.go:20		0x1004455fc		a94087e0		LDP 8(RSP), (R0, R1)										
  q8_codegen_test.go:20		0x100445600		17fffd4c		JMP github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.newQ8CodegenProbe.func1(SB)	
  q8_codegen_test.go:20		0x100445604		00000000		?												
  q8_codegen_test.go:20		0x100445608		00000000		?												
  q8_codegen_test.go:20		0x10044560c		00000000		?												

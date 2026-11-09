TEXT github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.q8CachedRangeProbe(SB) /Users/ryohiga/SpiralReality/sr_go_transformer/cmd/monolith/q8_codegen_test.go
  q8_codegen_test.go:26		0x1003e7b40		f9400b90		MOVD 16(R28), R16									
  q8_codegen_test.go:26		0x1003e7b44		d102c3f1		SUB $176, RSP, R17									
  q8_codegen_test.go:26		0x1003e7b48		eb10023f		CMP R16, R17										
  q8_codegen_test.go:26		0x1003e7b4c		54005589		BLS 684(PC)										
  q8_codegen_test.go:26		0x1003e7b50		d104c3f4		SUB $304, RSP, R20									
  q8_codegen_test.go:26		0x1003e7b54		a93ffa9d		STP (R29, R30), -8(R20)									
  q8_codegen_test.go:26		0x1003e7b58		9100029f		MOVD R20, RSP										
  q8_codegen_test.go:26		0x1003e7b5c		d10023fd		SUB $8, RSP, R29									
  q8_codegen_test.go:29		0x1003e7b60		f900a7e2		MOVD R2, 328(RSP)									
  q8_codegen_test.go:27		0x1003e7b64		a9419003		LDP 24(R0), (R3, R4)									
  q8_codegen_test.go:27		0x1003e7b68		f9007be4		MOVD R4, 240(RSP)									
  q8_codegen_test.go:27		0x1003e7b6c		f9003be3		MOVD R3, 112(RSP)									
  q8_codegen_test.go:27		0x1003e7b70		a9439805		LDP 56(R0), (R5, R6)									
  q8_codegen_test.go:27		0x1003e7b74		f9008fe5		MOVD R5, 280(RSP)									
  q8_codegen_test.go:27		0x1003e7b78		f9005be6		MOVD R6, 176(RSP)									
  q8_codegen_test.go:28		0x1003e7b7c		a9452007		LDP 80(R0), (R7, R8)									
  q8_codegen_test.go:28		0x1003e7b80		f9005fe7		MOVD R7, 184(RSP)									
  q8_codegen_test.go:28		0x1003e7b84		f9004fe8		MOVD R8, 152(RSP)									
  q8_codegen_test.go:28		0x1003e7b88		a9462809		LDP 96(R0), (R9, R10)									
  q8_codegen_test.go:28		0x1003e7b8c		f90063e9		MOVD R9, 192(RSP)									
  q8_codegen_test.go:28		0x1003e7b90		f90043ea		MOVD R10, 128(RSP)									
  q8_codegen_test.go:27		0x1003e7b94		f940140b		MOVD 40(R0), R11									
  q8_codegen_test.go:27		0x1003e7b98		f9002beb		MOVD R11, 80(RSP)									
  q8_codegen_test.go:27		0x1003e7b9c		f940040c		MOVD 8(R0), R12										
  q8_codegen_test.go:27		0x1003e7ba0		f90087ec		MOVD R12, 264(RSP)									
  q8_codegen_test.go:29		0x1003e7ba4		14000002		JMP 2(PC)										
  q8_codegen_test.go:29		0x1003e7ba8		91000421		ADD $1, R1, R1										
  q8_codegen_test.go:29		0x1003e7bac		eb01005f		CMP R1, R2										
  q8_codegen_test.go:29		0x1003e7bb0		54001b2d		BLE 217(PC)										
  q8_codegen_test.go:30		0x1003e7bb4		b400520a		CBZ R10, 656(PC)									
  q8_codegen_test.go:29		0x1003e7bb8		f90047e1		MOVD R1, 136(RSP)									
  q8_codegen_test.go:30		0x1003e7bbc		9aca0c2d		SDIV R10, R1, R13									
  q8_codegen_test.go:30		0x1003e7bc0		f90077ed		MOVD R13, 232(RSP)									
  q8_codegen_test.go:30		0x1003e7bc4		9aca0c3b		SDIV R10, R1, R27									
  q8_codegen_test.go:30		0x1003e7bc8		9b0a876e		MSUB R10, R1, R27, R14									
  q8_codegen_test.go:30		0x1003e7bcc		d37ef5af		LSL $2, R13, R15									
  q8_codegen_test.go:30		0x1003e7bd0		f9004bef		MOVD R15, 144(RSP)									
  q8_codegen_test.go:30		0x1003e7bd4		d37be9ce		LSL $5, R14, R14									
  q8_codegen_test.go:30		0x1003e7bd8		f90053ee		MOVD R14, 160(RSP)									
  q8_codegen_test.go:30		0x1003e7bdc		aa0e03e0		MOVD R14, R0										
  q8_codegen_test.go:31		0x1003e7be0		14000003		JMP 3(PC)										
  q8_codegen_test.go:34		0x1003e7be4		aa1103ef		MOVD R17, R15										
  q8_codegen_test.go:31		0x1003e7be8		aa1303ee		MOVD R19, R14										
  q8_codegen_test.go:31		0x1003e7bec		91008010		ADD $32, R0, R16									
  q8_codegen_test.go:31		0x1003e7bf0		eb10011f		CMP R16, R8										
  q8_codegen_test.go:31		0x1003e7bf4		9a90b110		CSEL LT, R8, R16, R16									
  q8_codegen_test.go:31		0x1003e7bf8		eb1001df		CMP R16, R14										
  q8_codegen_test.go:31		0x1003e7bfc		54fffd6a		BGE -21(PC)										
  q8_codegen_test.go:32		0x1003e7c00		f94044b0		MOVD 136(R5), R16									
  q8_codegen_test.go:32		0x1003e7c04		f9400a11		MOVD 16(R16), R17									
  q8_codegen_test.go:32		0x1003e7c08		910005d3		ADD $1, R14, R19									
  q8_codegen_test.go:32		0x1003e7c0c		9b077e74		MUL R7, R19, R20									
  q8_codegen_test.go:32		0x1003e7c10		9b077dd5		MUL R7, R14, R21									
  q8_codegen_test.go:32		0x1003e7c14		eb14023f		CMP R20, R17										
  q8_codegen_test.go:32		0x1003e7c18		54004e83		BCC 628(PC)										
  q8_codegen_test.go:32		0x1003e7c1c		eb15029f		CMP R21, R20										
  q8_codegen_test.go:32		0x1003e7c20		54004de3		BCC 623(PC)										
  q8_codegen_test.go:32		0x1003e7c24		f9400214		MOVD (R16), R20										
  q8_codegen_test.go:32		0x1003e7c28		cb1102b6		SUB R17, R21, R22									
  q8_codegen_test.go:32		0x1003e7c2c		8a96feb6		AND R22->63, R21, R22									
  q8_codegen_test.go:33		0x1003e7c30		f9401617		MOVD 40(R16), R23									
  q8_codegen_test.go:33		0x1003e7c34		9b097e78		MUL R9, R19, R24									
  q8_codegen_test.go:32		0x1003e7c38		8b160294		ADD R22, R20, R20									
  q8_codegen_test.go:32		0x1003e7c3c		cb150231		SUB R21, R17, R17									
  q8_codegen_test.go:33		0x1003e7c40		9b097dd5		MUL R9, R14, R21									
  q8_codegen_test.go:33		0x1003e7c44		eb1802ff		CMP R24, R23										
  q8_codegen_test.go:33		0x1003e7c48		54004c43		BCC 610(PC)										
  q8_codegen_test.go:33		0x1003e7c4c		eb15031f		CMP R21, R24										
  q8_codegen_test.go:33		0x1003e7c50		54004ba3		BCC 605(PC)										
  q8_codegen_test.go:32		0x1003e7c54		f90073f3		MOVD R19, 224(RSP)									
  q8_codegen_test.go:33		0x1003e7c58		f9400e10		MOVD 24(R16), R16									
  q8_codegen_test.go:33		0x1003e7c5c		cb1702b6		SUB R23, R21, R22									
  q8_codegen_test.go:33		0x1003e7c60		8a96feb5		AND R22->63, R21, R21									
  q8_codegen_test.go:34		0x1003e7c64		910011f6		ADD $4, R15, R22									
  q8_codegen_test.go:33		0x1003e7c68		8b150a10		ADD R21<<2, R16, R16									
  q8_codegen_test.go:34		0x1003e7c6c		eb1600df		CMP R22, R6										
  q8_codegen_test.go:34		0x1003e7c70		540005cb		BLT 46(PC)										
  q8_codegen_test.go:35		0x1003e7c74		910005f1		ADD $1, R15, R17									
  q8_codegen_test.go:35		0x1003e7c78		9b117cf5		MUL R17, R7, R21									
  q8_codegen_test.go:35		0x1003e7c7c		9b077db7		MUL R7, R13, R23									
  q8_codegen_test.go:35		0x1003e7c80		eb15007f		CMP R21, R3										
  q8_codegen_test.go:35		0x1003e7c84		540049c3		BCC 590(PC)										
  q8_codegen_test.go:35		0x1003e7c88		eb170abf		CMP R23<<2, R21										
  q8_codegen_test.go:35		0x1003e7c8c		54004923		BCC 585(PC)										
  q8_codegen_test.go:35		0x1003e7c90		cb170878		SUB R23<<2, R3, R24									
  q8_codegen_test.go:35		0x1003e7c94		cb1803f8		NEG R24, R24										
  q8_codegen_test.go:35		0x1003e7c98		8a98fef8		AND R24->63, R23, R24									
  q8_codegen_test.go:35		0x1003e7c9c		910009f9		ADD $2, R15, R25									
  q8_codegen_test.go:35		0x1003e7ca0		9b197cfa		MUL R25, R7, R26									
  q8_codegen_test.go:35		0x1003e7ca4		cb170ab7		SUB R23<<2, R21, R23									
  q8_codegen_test.go:35		0x1003e7ca8		8b181198		ADD R24<<4, R12, R24									
  q8_codegen_test.go:35		0x1003e7cac		eb1a007f		CMP R26, R3										
  q8_codegen_test.go:35		0x1003e7cb0		540047c3		BCC 574(PC)										
  q8_codegen_test.go:35		0x1003e7cb4		eb15035f		CMP R21, R26										
  q8_codegen_test.go:35		0x1003e7cb8		54004723		BCC 569(PC)										
  q8_codegen_test.go:35		0x1003e7cbc		cb0302be		SUB R3, R21, R30									
  q8_codegen_test.go:35		0x1003e7cc0		8a9efeb5		AND R30->63, R21, R21									
  q8_codegen_test.go:36		0x1003e7cc4		91000dfe		ADD $3, R15, R30									
  q8_codegen_test.go:36		0x1003e7cc8		9b077fca		MUL R7, R30, R10									
  q8_codegen_test.go:35		0x1003e7ccc		8b150995		ADD R21<<2, R12, R21									
  q8_codegen_test.go:36		0x1003e7cd0		eb0a007f		CMP R10, R3										
  q8_codegen_test.go:36		0x1003e7cd4		54004623		BCC 561(PC)										
  q8_codegen_test.go:36		0x1003e7cd8		eb1a015f		CMP R26, R10										
  q8_codegen_test.go:36		0x1003e7cdc		540045a3		BCC 557(PC)										
  q8_codegen_test.go:36		0x1003e7ce0		cb030342		SUB R3, R26, R2										
  q8_codegen_test.go:36		0x1003e7ce4		8a82ff5a		AND R2->63, R26, R26									
  q8_codegen_test.go:36		0x1003e7ce8		9b077ed6		MUL R7, R22, R22									
  q8_codegen_test.go:36		0x1003e7cec		8b1a099a		ADD R26<<2, R12, R26									
  q8_codegen_test.go:36		0x1003e7cf0		eb16007f		CMP R22, R3										
  q8_codegen_test.go:36		0x1003e7cf4		540044a3		BCC 549(PC)										
  q8_codegen_test.go:36		0x1003e7cf8		eb0a02df		CMP R10, R22										
  q8_codegen_test.go:36		0x1003e7cfc		54004423		BCC 545(PC)										
  q8_codegen_test.go:36		0x1003e7d00		f9006ffe		MOVD R30, 216(RSP)									
  q8_codegen_test.go:36		0x1003e7d04		cb030156		SUB R3, R10, R22									
  q8_codegen_test.go:36		0x1003e7d08		8a96fd4a		AND R22->63, R10, R10									
  q8_codegen_test.go:36		0x1003e7d0c		8b0a098a		ADD R10<<2, R12, R10									
  q8_codegen_test.go:38		0x1003e7d10		aa1f03f6		MOVD ZR, R22										
  q8_codegen_test.go:38		0x1003e7d14		1e2703e0		FMOVS ZR, F0										
  q8_codegen_test.go:38		0x1003e7d18		1e2703e1		FMOVS ZR, F1										
  q8_codegen_test.go:38		0x1003e7d1c		1e2703e2		FMOVS ZR, F2										
  q8_codegen_test.go:38		0x1003e7d20		1e2703e3		FMOVS ZR, F3										
  q8_codegen_test.go:38		0x1003e7d24		14000160		JMP 352(PC)										
  q8_codegen_test.go:77		0x1003e7d28		910009f5		ADD $2, R15, R21									
  q8_codegen_test.go:77		0x1003e7d2c		eb1500df		CMP R21, R6										
  q8_codegen_test.go:77		0x1003e7d30		540004ab		BLT 37(PC)										
  q8_codegen_test.go:78		0x1003e7d34		910005f6		ADD $1, R15, R22									
  q8_codegen_test.go:78		0x1003e7d38		9b167cf7		MUL R22, R7, R23									
  q8_codegen_test.go:78		0x1003e7d3c		9b077db8		MUL R7, R13, R24									
  q8_codegen_test.go:78		0x1003e7d40		eb17007f		CMP R23, R3										
  q8_codegen_test.go:78		0x1003e7d44		540029e3		BCC 335(PC)										
  q8_codegen_test.go:78		0x1003e7d48		eb180aff		CMP R24<<2, R23										
  q8_codegen_test.go:78		0x1003e7d4c		54002943		BCC 330(PC)										
  q8_codegen_test.go:78		0x1003e7d50		cb180879		SUB R24<<2, R3, R25									
  q8_codegen_test.go:78		0x1003e7d54		cb1903fa		NEG R25, R26										
  q8_codegen_test.go:78		0x1003e7d58		8a9aff1a		AND R26->63, R24, R26									
  q8_codegen_test.go:78		0x1003e7d5c		9b157cfe		MUL R21, R7, R30									
  q8_codegen_test.go:78		0x1003e7d60		cb180af8		SUB R24<<2, R23, R24									
  q8_codegen_test.go:78		0x1003e7d64		8b1a119a		ADD R26<<4, R12, R26									
  q8_codegen_test.go:78		0x1003e7d68		eb1e007f		CMP R30, R3										
  q8_codegen_test.go:78		0x1003e7d6c		54002803		BCC 320(PC)										
  q8_codegen_test.go:78		0x1003e7d70		eb1703df		CMP R23, R30										
  q8_codegen_test.go:78		0x1003e7d74		54002763		BCC 315(PC)										
  q8_codegen_test.go:32		0x1003e7d78		f9003ff1		MOVD R17, 120(RSP)									
  q8_codegen_test.go:32		0x1003e7d7c		f9008bf4		MOVD R20, 272(RSP)									
  q8_codegen_test.go:33		0x1003e7d80		f90093f0		MOVD R16, 288(RSP)									
  q8_codegen_test.go:77		0x1003e7d84		f9006ff5		MOVD R21, 216(RSP)									
  q8_codegen_test.go:78		0x1003e7d88		f9006bf6		MOVD R22, 208(RSP)									
  q8_codegen_test.go:78		0x1003e7d8c		f90033f8		MOVD R24, 96(RSP)									
  q8_codegen_test.go:78		0x1003e7d90		f90037f9		MOVD R25, 104(RSP)									
  q8_codegen_test.go:78		0x1003e7d94		f90083fa		MOVD R26, 256(RSP)									
  q8_codegen_test.go:31		0x1003e7d98		f90057ee		MOVD R14, 168(RSP)									
  q8_codegen_test.go:78		0x1003e7d9c		cb0302fe		SUB R3, R23, R30									
  q8_codegen_test.go:78		0x1003e7da0		8a9efefe		AND R30->63, R23, R30									
  q8_codegen_test.go:78		0x1003e7da4		8b1e099e		ADD R30<<2, R12, R30									
  q8_codegen_test.go:78		0x1003e7da8		f9007ffe		MOVD R30, 248(RSP)									
  q8_codegen_test.go:78		0x1003e7dac		cb170077		SUB R23, R3, R23									
  q8_codegen_test.go:78		0x1003e7db0		f9002ff7		MOVD R23, 88(RSP)									
  q8_codegen_test.go:80		0x1003e7db4		aa1f03ea		MOVD ZR, R10										
  q8_codegen_test.go:80		0x1003e7db8		1e2703e0		FMOVS ZR, F0										
  q8_codegen_test.go:80		0x1003e7dbc		1e2703e1		FMOVS ZR, F1										
  q8_codegen_test.go:80		0x1003e7dc0		14000086		JMP 134(PC)										
  q8_codegen_test.go:30		0x1003e7dc4		aa0f03f1		MOVD R15, R17										
  q8_codegen_test.go:77		0x1003e7dc8		14000003		JMP 3(PC)										
  q8_codegen_test.go:130	0x1003e7dcc		bc2f7880		FMOVS F0, (R4)(R15<<2)									
  q8_codegen_test.go:112	0x1003e7dd0		aa1503ef		MOVD R21, R15										
  q8_codegen_test.go:112	0x1003e7dd4		eb0601ff		CMP R6, R15										
  q8_codegen_test.go:112	0x1003e7dd8		54fff06a		BGE -125(PC)										
  q8_codegen_test.go:113	0x1003e7ddc		910005f5		ADD $1, R15, R21									
  q8_codegen_test.go:113	0x1003e7de0		9b077eb6		MUL R7, R21, R22									
  q8_codegen_test.go:113	0x1003e7de4		9b077df7		MUL R7, R15, R23									
  q8_codegen_test.go:113	0x1003e7de8		eb16007f		CMP R22, R3										
  q8_codegen_test.go:113	0x1003e7dec		54000b63		BCC 91(PC)										
  q8_codegen_test.go:113	0x1003e7df0		eb1702df		CMP R23, R22										
  q8_codegen_test.go:113	0x1003e7df4		54000ac3		BCC 86(PC)										
  q8_codegen_test.go:113	0x1003e7df8		cb0302f6		SUB R3, R23, R22									
  q8_codegen_test.go:113	0x1003e7dfc		8a96fef6		AND R22->63, R23, R22									
  q8_codegen_test.go:113	0x1003e7e00		8b160996		ADD R22<<2, R12, R22									
  q8_codegen_test.go:115	0x1003e7e04		aa1f03f7		MOVD ZR, R23										
  q8_codegen_test.go:115	0x1003e7e08		1e2703e0		FMOVS ZR, F0										
  q8_codegen_test.go:115	0x1003e7e0c		14000003		JMP 3(PC)										
  q8_codegen_test.go:128	0x1003e7e10		1f020020		FMADDS F2, F0, F1, F0									
  q8_codegen_test.go:115	0x1003e7e14		aa1803f7		MOVD R24, R23										
  q8_codegen_test.go:115	0x1003e7e18		eb0902ff		CMP R9, R23										
  q8_codegen_test.go:115	0x1003e7e1c		5400074a		BGE 58(PC)										
  q8_codegen_test.go:116	0x1003e7e20		910006f8		ADD $1, R23, R24									
  q8_codegen_test.go:116	0x1003e7e24		d37ae719		LSL $6, R24, R25									
  q8_codegen_test.go:115	0x1003e7e28		bc777a01		FMOVS (R16)(R23<<2), F1									
  q8_codegen_test.go:116	0x1003e7e2c		d37ae6f7		LSL $6, R23, R23									
  q8_codegen_test.go:116	0x1003e7e30		eb1818ff		CMP R24<<6, R7										
  q8_codegen_test.go:116	0x1003e7e34		9a99b0f9		CSEL LT, R7, R25, R25									
  q8_codegen_test.go:116	0x1003e7e38		1e2703e2		FMOVS ZR, F2										
  q8_codegen_test.go:116	0x1003e7e3c		1e2703e3		FMOVS ZR, F3										
  q8_codegen_test.go:116	0x1003e7e40		1e2703e4		FMOVS ZR, F4										
  q8_codegen_test.go:116	0x1003e7e44		1e2703e5		FMOVS ZR, F5										
  q8_codegen_test.go:116	0x1003e7e48		14000006		JMP 6(PC)										
  q8_codegen_test.go:122	0x1003e7e4c		bc777ac6		FMOVS (R22)(R23<<2), F6									
  q8_codegen_test.go:122	0x1003e7e50		38b76a9e		MOVB (R20)(R23), R30									
  q8_codegen_test.go:122	0x1003e7e54		1e2203c7		SCVTFWS R30, F7										
  q8_codegen_test.go:122	0x1003e7e58		1f070cc3		FMADDS F7, F3, F6, F3									
  q8_codegen_test.go:118	0x1003e7e5c		aa1a03f7		MOVD R26, R23										
  q8_codegen_test.go:118	0x1003e7e60		910012fa		ADD $4, R23, R26									
  q8_codegen_test.go:118	0x1003e7e64		eb1a033f		CMP R26, R25										
  q8_codegen_test.go:118	0x1003e7e68		5400032b		BLT 25(PC)										
  q8_codegen_test.go:119	0x1003e7e6c		eb0702ff		CMP R7, R23										
  q8_codegen_test.go:119	0x1003e7e70		540006a2		BCS 53(PC)										
  q8_codegen_test.go:119	0x1003e7e74		bc777ac6		FMOVS (R22)(R23<<2), F6									
  q8_codegen_test.go:119	0x1003e7e78		38b76a9e		MOVB (R20)(R23), R30									
  q8_codegen_test.go:119	0x1003e7e7c		1e2203c7		SCVTFWS R30, F7										
  q8_codegen_test.go:120	0x1003e7e80		910006fe		ADD $1, R23, R30									
  q8_codegen_test.go:119	0x1003e7e84		1f0710c4		FMADDS F7, F4, F6, F4									
  q8_codegen_test.go:120	0x1003e7e88		eb1e00ff		CMP R30, R7										
  q8_codegen_test.go:120	0x1003e7e8c		54000589		BLS 44(PC)										
  q8_codegen_test.go:120	0x1003e7e90		bc7e7ac6		FMOVS (R22)(R30<<2), F6									
  q8_codegen_test.go:120	0x1003e7e94		38be6a9e		MOVB (R20)(R30), R30									
  q8_codegen_test.go:120	0x1003e7e98		1e2203c7		SCVTFWS R30, F7										
  q8_codegen_test.go:121	0x1003e7e9c		91000afe		ADD $2, R23, R30									
  q8_codegen_test.go:120	0x1003e7ea0		1f0714c5		FMADDS F7, F5, F6, F5									
  q8_codegen_test.go:121	0x1003e7ea4		eb1e00ff		CMP R30, R7										
  q8_codegen_test.go:121	0x1003e7ea8		54000469		BLS 35(PC)										
  q8_codegen_test.go:121	0x1003e7eac		bc7e7ac6		FMOVS (R22)(R30<<2), F6									
  q8_codegen_test.go:121	0x1003e7eb0		38be6a9e		MOVB (R20)(R30), R30									
  q8_codegen_test.go:121	0x1003e7eb4		1e2203c7		SCVTFWS R30, F7										
  q8_codegen_test.go:122	0x1003e7eb8		91000ef7		ADD $3, R23, R23									
  q8_codegen_test.go:121	0x1003e7ebc		1f0708c2		FMADDS F7, F2, F6, F2									
  q8_codegen_test.go:122	0x1003e7ec0		eb1700ff		CMP R23, R7										
  q8_codegen_test.go:122	0x1003e7ec4		54fffc48		BHI -30(PC)										
  q8_codegen_test.go:122	0x1003e7ec8		14000019		JMP 25(PC)										
  q8_codegen_test.go:124	0x1003e7ecc		1e252884		FADDS F5, F4, F4									
  q8_codegen_test.go:124	0x1003e7ed0		1e232842		FADDS F3, F2, F2									
  q8_codegen_test.go:124	0x1003e7ed4		1e222882		FADDS F2, F4, F2									
  q8_codegen_test.go:125	0x1003e7ed8		14000006		JMP 6(PC)										
  q8_codegen_test.go:126	0x1003e7edc		bc777ac3		FMOVS (R22)(R23<<2), F3									
  q8_codegen_test.go:126	0x1003e7ee0		38b76a9a		MOVB (R20)(R23), R26									
  q8_codegen_test.go:126	0x1003e7ee4		1e220344		SCVTFWS R26, F4										
  q8_codegen_test.go:126	0x1003e7ee8		1f040862		FMADDS F4, F2, F3, F2									
  q8_codegen_test.go:125	0x1003e7eec		910006f7		ADD $1, R23, R23									
  q8_codegen_test.go:125	0x1003e7ef0		eb1902ff		CMP R25, R23										
  q8_codegen_test.go:125	0x1003e7ef4		54fff8ea		BGE -57(PC)										
  q8_codegen_test.go:126	0x1003e7ef8		eb0702ff		CMP R7, R23										
  q8_codegen_test.go:126	0x1003e7efc		54ffff03		BCC -8(PC)										
  q8_codegen_test.go:126	0x1003e7f00		14000009		JMP 9(PC)										
  q8_codegen_test.go:130	0x1003e7f04		9b0f390f		MADD R15, R14, R8, R15									
  q8_codegen_test.go:130	0x1003e7f08		eb0f017f		CMP R15, R11										
  q8_codegen_test.go:130	0x1003e7f0c		54fff608		BHI -80(PC)										
  q8_codegen_test.go:130	0x1003e7f10		14000004		JMP 4(PC)										
  q8_codegen_test.go:135	0x1003e7f14		a97ffbfd		LDP -8(RSP), (R29, R30)									
  q8_codegen_test.go:135	0x1003e7f18		9104c3ff		ADD $304, RSP, RSP									
  q8_codegen_test.go:135	0x1003e7f1c		d65f03c0		RET											
  q8_codegen_test.go:130	0x1003e7f20		97f28a28		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:126	0x1003e7f24		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:126	0x1003e7f28		97f28a26		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:122	0x1003e7f2c		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:122	0x1003e7f30		97f28a24		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:121	0x1003e7f34		aa1e03e0		MOVD R30, R0										
  q8_codegen_test.go:121	0x1003e7f38		97f28a22		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:120	0x1003e7f3c		aa1e03e0		MOVD R30, R0										
  q8_codegen_test.go:120	0x1003e7f40		97f28a20		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:119	0x1003e7f44		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:119	0x1003e7f48		97f28a1e		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:113	0x1003e7f4c		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:113	0x1003e7f50		aa1603e1		MOVD R22, R1										
  q8_codegen_test.go:113	0x1003e7f54		97f28a1b		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:113	0x1003e7f58		aa1603e0		MOVD R22, R0										
  q8_codegen_test.go:113	0x1003e7f5c		97f28a19		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:31		0x1003e7f60		f94053e0		MOVD 160(RSP), R0									
  q8_codegen_test.go:29		0x1003e7f64		f94047e1		MOVD 136(RSP), R1									
  q8_codegen_test.go:29		0x1003e7f68		f940a7e2		MOVD 328(RSP), R2									
  q8_codegen_test.go:113	0x1003e7f6c		f9403be3		MOVD 112(RSP), R3									
  q8_codegen_test.go:109	0x1003e7f70		f9407be4		MOVD 240(RSP), R4									
  q8_codegen_test.go:32		0x1003e7f74		f9408fe5		MOVD 280(RSP), R5									
  q8_codegen_test.go:112	0x1003e7f78		f9405be6		MOVD 176(RSP), R6									
  q8_codegen_test.go:81		0x1003e7f7c		f9405fe7		MOVD 184(RSP), R7									
  q8_codegen_test.go:109	0x1003e7f80		f9404fe8		MOVD 152(RSP), R8									
  q8_codegen_test.go:80		0x1003e7f84		f94063e9		MOVD 192(RSP), R9									
  q8_codegen_test.go:109	0x1003e7f88		f9402beb		MOVD 80(RSP), R11									
  q8_codegen_test.go:113	0x1003e7f8c		f94087ec		MOVD 264(RSP), R12									
  q8_codegen_test.go:109	0x1003e7f90		f94077ed		MOVD 232(RSP), R13									
  q8_codegen_test.go:109	0x1003e7f94		f94057ee		MOVD 168(RSP), R14									
  q8_codegen_test.go:34		0x1003e7f98		f9404bef		MOVD 144(RSP), R15									
  q8_codegen_test.go:80		0x1003e7f9c		f94093f0		MOVD 288(RSP), R16									
  q8_codegen_test.go:83		0x1003e7fa0		f9403ff1		MOVD 120(RSP), R17									
  q8_codegen_test.go:31		0x1003e7fa4		f94073f3		MOVD 224(RSP), R19									
  q8_codegen_test.go:90		0x1003e7fa8		f9408bf4		MOVD 272(RSP), R20									
  q8_codegen_test.go:112	0x1003e7fac		f9406ff5		MOVD 216(RSP), R21									
  q8_codegen_test.go:109	0x1003e7fb0		f9406bf6		MOVD 208(RSP), R22									
  q8_codegen_test.go:83		0x1003e7fb4		f9402ff7		MOVD 88(RSP), R23									
  q8_codegen_test.go:91		0x1003e7fb8		f94033f8		MOVD 96(RSP), R24									
  q8_codegen_test.go:83		0x1003e7fbc		f94037f9		MOVD 104(RSP), R25									
  q8_codegen_test.go:91		0x1003e7fc0		f94083fa		MOVD 256(RSP), R26									
  q8_codegen_test.go:95		0x1003e7fc4		f9407ffe		MOVD 248(RSP), R30									
  q8_codegen_test.go:80		0x1003e7fc8		f94067ea		MOVD 200(RSP), R10									
  q8_codegen_test.go:80		0x1003e7fcc		1e204002		FMOVS F0, F2										
  q8_codegen_test.go:80		0x1003e7fd0		1e204020		FMOVS F1, F0										
  q8_codegen_test.go:80		0x1003e7fd4		1e204041		FMOVS F2, F1										
  q8_codegen_test.go:80		0x1003e7fd8		eb09015f		CMP R9, R10										
  q8_codegen_test.go:80		0x1003e7fdc		5400056a		BGE 43(PC)										
  q8_codegen_test.go:81		0x1003e7fe0		91000542		ADD $1, R10, R2										
  q8_codegen_test.go:81		0x1003e7fe4		f90067e2		MOVD R2, 200(RSP)									
  q8_codegen_test.go:81		0x1003e7fe8		d37ae441		LSL $6, R2, R1										
  q8_codegen_test.go:80		0x1003e7fec		bc6a7a02		FMOVS (R16)(R10<<2), F2									
  q8_codegen_test.go:81		0x1003e7ff0		d37ae54f		LSL $6, R10, R15									
  q8_codegen_test.go:81		0x1003e7ff4		eb0218ff		CMP R2<<6, R7										
  q8_codegen_test.go:81		0x1003e7ff8		9a81b0e1		CSEL LT, R7, R1, R1									
  q8_codegen_test.go:82		0x1003e7ffc		cb0a1825		SUB R10<<6, R1, R5									
  q8_codegen_test.go:82		0x1003e8000		f10100bf		CMP $64, R5										
  q8_codegen_test.go:81		0x1003e8004		54000140		BEQ 10(PC)										
  q8_codegen_test.go:82		0x1003e8008		1e2703e3		FMOVS ZR, F3										
  q8_codegen_test.go:82		0x1003e800c		1e2703e4		FMOVS ZR, F4										
  q8_codegen_test.go:82		0x1003e8010		1e2703e5		FMOVS ZR, F5										
  q8_codegen_test.go:82		0x1003e8014		1e2703e6		FMOVS ZR, F6										
  q8_codegen_test.go:82		0x1003e8018		1e2703e7		FMOVS ZR, F7										
  q8_codegen_test.go:82		0x1003e801c		1e2703e8		FMOVS ZR, F8										
  q8_codegen_test.go:82		0x1003e8020		1e2703e9		FMOVS ZR, F9										
  q8_codegen_test.go:82		0x1003e8024		1e2703ea		FMOVS ZR, F10										
  q8_codegen_test.go:82		0x1003e8028		14000040		JMP 64(PC)										
  q8_codegen_test.go:83		0x1003e802c		eb19003f		CMP R25, R1										
  q8_codegen_test.go:83		0x1003e8030		54000548		BHI 42(PC)										
  q8_codegen_test.go:83		0x1003e8034		eb0a183f		CMP R10<<6, R1										
  q8_codegen_test.go:83		0x1003e8038		540004e3		BCC 39(PC)										
  q8_codegen_test.go:83		0x1003e803c		8b0a2345		ADD R10<<8, R26, R5									
  q8_codegen_test.go:83		0x1003e8040		eb17003f		CMP R23, R1										
  q8_codegen_test.go:83		0x1003e8044		54000448		BHI 34(PC)										
  q8_codegen_test.go:83		0x1003e8048		8b0a23cf		ADD R10<<8, R30, R15									
  q8_codegen_test.go:83		0x1003e804c		eb11003f		CMP R17, R1										
  q8_codegen_test.go:83		0x1003e8050		540003a8		BHI 29(PC)										
  q8_codegen_test.go:80		0x1003e8054		bd002fe2		FMOVS F2, 44(RSP)									
  q8_codegen_test.go:80		0x1003e8058		bd003fe0		FMOVS F0, 60(RSP)									
  q8_codegen_test.go:80		0x1003e805c		bd0047e1		FMOVS F1, 68(RSP)									
  q8_codegen_test.go:83		0x1003e8060		8b0a1a82		ADD R10<<6, R20, R2									
  q8_codegen_test.go:83		0x1003e8064		aa0503e0		MOVD R5, R0										
  q8_codegen_test.go:83		0x1003e8068		aa0f03e1		MOVD R15, R1										
  q8_codegen_test.go:83		0x1003e806c		97fd37b5		CALL github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.dotQ8PairBlock64(SB)	
  q8_codegen_test.go:84		0x1003e8070		bd4047e2		FMOVS 68(RSP), F2									
  q8_codegen_test.go:84		0x1003e8074		bd402fe3		FMOVS 44(RSP), F3									
  q8_codegen_test.go:84		0x1003e8078		1f000860		FMADDS F0, F2, F3, F0									
  q8_codegen_test.go:85		0x1003e807c		bd403fe2		FMOVS 60(RSP), F2									
  q8_codegen_test.go:85		0x1003e8080		1f010861		FMADDS F1, F2, F3, F1									
  q8_codegen_test.go:86		0x1003e8084		17ffffb7		JMP -73(PC)										
  q8_codegen_test.go:109	0x1003e8088		9b087daa		MUL R8, R13, R10									
  q8_codegen_test.go:109	0x1003e808c		8b0a09ca		ADD R10<<2, R14, R10									
  q8_codegen_test.go:109	0x1003e8090		eb0a017f		CMP R10, R11										
  q8_codegen_test.go:109	0x1003e8094		54000169		BLS 11(PC)										
  q8_codegen_test.go:109	0x1003e8098		bc2a7881		FMOVS F1, (R4)(R10<<2)									
  q8_codegen_test.go:109	0x1003e809c		9b083aca		MADD R8, R14, R22, R10									
  q8_codegen_test.go:109	0x1003e80a0		eb0a017f		CMP R10, R11										
  q8_codegen_test.go:109	0x1003e80a4		540000c9		BLS 6(PC)										
  q8_codegen_test.go:109	0x1003e80a8		bc2a7880		FMOVS F0, (R4)(R10<<2)									
  q8_codegen_test.go:30		0x1003e80ac		f94043ea		MOVD 128(RSP), R10									
  q8_codegen_test.go:34		0x1003e80b0		aa0f03f1		MOVD R15, R17										
  q8_codegen_test.go:112	0x1003e80b4		aa1503ef		MOVD R21, R15										
  q8_codegen_test.go:110	0x1003e80b8		17ffff47		JMP -185(PC)										
  q8_codegen_test.go:109	0x1003e80bc		97f289c1		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:109	0x1003e80c0		97f289c0		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:83		0x1003e80c4		aa1103e0		MOVD R17, R0										
  q8_codegen_test.go:83		0x1003e80c8		97f289be		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:83		0x1003e80cc		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:83		0x1003e80d0		97f289bc		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:83		0x1003e80d4		97f289bb		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:83		0x1003e80d8		aa1903e0		MOVD R25, R0										
  q8_codegen_test.go:83		0x1003e80dc		97f289b9		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:90		0x1003e80e0		1e2202ae		SCVTFWS R21, F14									
  q8_codegen_test.go:94		0x1003e80e4		bc637b4f		FMOVS (R26)(R3<<2), F15									
  q8_codegen_test.go:95		0x1003e80e8		bc6f7bd0		FMOVS (R30)(R15<<2), F16								
  q8_codegen_test.go:96		0x1003e80ec		bc6a7bd1		FMOVS (R30)(R10<<2), F17								
  q8_codegen_test.go:97		0x1003e80f0		bc737bd2		FMOVS (R30)(R19<<2), F18								
  q8_codegen_test.go:98		0x1003e80f4		bc637bd3		FMOVS (R30)(R3<<2), F19									
  q8_codegen_test.go:94		0x1003e80f8		1f0f15c5		FMADDS F15, F5, F14, F5									
  q8_codegen_test.go:95		0x1003e80fc		1f101d67		FMADDS F16, F7, F11, F7									
  q8_codegen_test.go:96		0x1003e8100		1f112188		FMADDS F17, F8, F12, F8									
  q8_codegen_test.go:97		0x1003e8104		1f1229aa		FMADDS F18, F10, F13, F10								
  q8_codegen_test.go:98		0x1003e8108		1f1311c4		FMADDS F19, F4, F14, F4									
  q8_codegen_test.go:31		0x1003e810c		f94053e0		MOVD 160(RSP), R0									
  q8_codegen_test.go:113	0x1003e8110		f9403be3		MOVD 112(RSP), R3									
  q8_codegen_test.go:112	0x1003e8114		f9405be6		MOVD 176(RSP), R6									
  q8_codegen_test.go:113	0x1003e8118		f94087ec		MOVD 264(RSP), R12									
  q8_codegen_test.go:31		0x1003e811c		f94073f3		MOVD 224(RSP), R19									
  q8_codegen_test.go:112	0x1003e8120		f9406ff5		MOVD 216(RSP), R21									
  q8_codegen_test.go:89		0x1003e8124		aa0503ef		MOVD R5, R15										
  q8_codegen_test.go:89		0x1003e8128		910011e5		ADD $4, R15, R5										
  q8_codegen_test.go:89		0x1003e812c		eb05003f		CMP R5, R1										
  q8_codegen_test.go:89		0x1003e8130		5400044b		BLT 34(PC)										
  q8_codegen_test.go:90		0x1003e8134		eb0701ff		CMP R7, R15										
  q8_codegen_test.go:90		0x1003e8138		54000922		BCS 73(PC)										
  q8_codegen_test.go:90		0x1003e813c		910005ea		ADD $1, R15, R10									
  q8_codegen_test.go:90		0x1003e8140		38af6a80		MOVB (R20)(R15), R0									
  q8_codegen_test.go:90		0x1003e8144		eb0a00ff		CMP R10, R7										
  q8_codegen_test.go:90		0x1003e8148		54000889		BLS 68(PC)										
  q8_codegen_test.go:90		0x1003e814c		910009f3		ADD $2, R15, R19									
  q8_codegen_test.go:90		0x1003e8150		38aa6a8c		MOVB (R20)(R10), R12									
  q8_codegen_test.go:90		0x1003e8154		eb1300ff		CMP R19, R7										
  q8_codegen_test.go:90		0x1003e8158		540007c9		BLS 62(PC)										
  q8_codegen_test.go:90		0x1003e815c		91000de3		ADD $3, R15, R3										
  q8_codegen_test.go:90		0x1003e8160		38b36a86		MOVB (R20)(R19), R6									
  q8_codegen_test.go:90		0x1003e8164		eb0300ff		CMP R3, R7										
  q8_codegen_test.go:90		0x1003e8168		54000729		BLS 57(PC)										
  q8_codegen_test.go:90		0x1003e816c		38a36a95		MOVB (R20)(R3), R21									
  q8_codegen_test.go:91		0x1003e8170		eb1801ff		CMP R24, R15										
  q8_codegen_test.go:91		0x1003e8174		54000682		BCS 52(PC)										
  q8_codegen_test.go:90		0x1003e8178		1e22000b		SCVTFWS R0, F11										
  q8_codegen_test.go:91		0x1003e817c		bc6f7b4c		FMOVS (R26)(R15<<2), F12								
  q8_codegen_test.go:91		0x1003e8180		1f0c0d63		FMADDS F12, F3, F11, F3									
  q8_codegen_test.go:92		0x1003e8184		eb0a031f		CMP R10, R24										
  q8_codegen_test.go:92		0x1003e8188		540005a9		BLS 45(PC)										
  q8_codegen_test.go:90		0x1003e818c		1e22018c		SCVTFWS R12, F12									
  q8_codegen_test.go:92		0x1003e8190		bc6a7b4d		FMOVS (R26)(R10<<2), F13								
  q8_codegen_test.go:92		0x1003e8194		1f0d2589		FMADDS F13, F9, F12, F9									
  q8_codegen_test.go:93		0x1003e8198		eb13031f		CMP R19, R24										
  q8_codegen_test.go:93		0x1003e819c		540004a9		BLS 37(PC)										
  q8_codegen_test.go:90		0x1003e81a0		1e2200cd		SCVTFWS R6, F13										
  q8_codegen_test.go:93		0x1003e81a4		bc737b4e		FMOVS (R26)(R19<<2), F14								
  q8_codegen_test.go:93		0x1003e81a8		1f0e19a6		FMADDS F14, F6, F13, F6									
  q8_codegen_test.go:94		0x1003e81ac		eb03031f		CMP R3, R24										
  q8_codegen_test.go:94		0x1003e81b0		54fff988		BHI -52(PC)										
  q8_codegen_test.go:94		0x1003e81b4		1400001d		JMP 29(PC)										
  q8_codegen_test.go:100	0x1003e81b8		1e292863		FADDS F9, F3, F3									
  q8_codegen_test.go:100	0x1003e81bc		1e2528c5		FADDS F5, F6, F5									
  q8_codegen_test.go:100	0x1003e81c0		1e2828e6		FADDS F8, F7, F6									
  q8_codegen_test.go:100	0x1003e81c4		1e242944		FADDS F4, F10, F4									
  q8_codegen_test.go:100	0x1003e81c8		1e2328a3		FADDS F3, F5, F3									
  q8_codegen_test.go:100	0x1003e81cc		1e262884		FADDS F6, F4, F4									
  q8_codegen_test.go:101	0x1003e81d0		14000007		JMP 7(PC)										
  q8_codegen_test.go:102	0x1003e81d4		1e2200a5		SCVTFWS R5, F5										
  q8_codegen_test.go:103	0x1003e81d8		bc6f7b46		FMOVS (R26)(R15<<2), F6									
  q8_codegen_test.go:104	0x1003e81dc		bc6f7bc7		FMOVS (R30)(R15<<2), F7									
  q8_codegen_test.go:103	0x1003e81e0		1f060ca3		FMADDS F6, F3, F5, F3									
  q8_codegen_test.go:104	0x1003e81e4		1f0710a4		FMADDS F7, F4, F5, F4									
  q8_codegen_test.go:101	0x1003e81e8		910005ef		ADD $1, R15, R15									
  q8_codegen_test.go:101	0x1003e81ec		eb0101ff		CMP R1, R15										
  q8_codegen_test.go:101	0x1003e81f0		540000ea		BGE 7(PC)										
  q8_codegen_test.go:102	0x1003e81f4		eb0701ff		CMP R7, R15										
  q8_codegen_test.go:102	0x1003e81f8		54000162		BCS 11(PC)										
  q8_codegen_test.go:102	0x1003e81fc		38af6a85		MOVB (R20)(R15), R5									
  q8_codegen_test.go:103	0x1003e8200		eb1801ff		CMP R24, R15										
  q8_codegen_test.go:103	0x1003e8204		54fffe83		BCC -12(PC)										
  q8_codegen_test.go:103	0x1003e8208		14000005		JMP 5(PC)										
  q8_codegen_test.go:106	0x1003e820c		1f030443		FMADDS F3, F1, F2, F3									
  q8_codegen_test.go:107	0x1003e8210		1f040041		FMADDS F4, F0, F2, F1									
  q8_codegen_test.go:80		0x1003e8214		1e204060		FMOVS F3, F0										
  q8_codegen_test.go:107	0x1003e8218		17ffff52		JMP -174(PC)										
  q8_codegen_test.go:103	0x1003e821c		aa1803e0		MOVD R24, R0										
  q8_codegen_test.go:103	0x1003e8220		97f28968		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:102	0x1003e8224		97f28967		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:94		0x1003e8228		aa1803e0		MOVD R24, R0										
  q8_codegen_test.go:94		0x1003e822c		97f28965		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:93		0x1003e8230		aa1303e0		MOVD R19, R0										
  q8_codegen_test.go:93		0x1003e8234		aa1803e1		MOVD R24, R1										
  q8_codegen_test.go:93		0x1003e8238		97f28962		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:92		0x1003e823c		aa1803e0		MOVD R24, R0										
  q8_codegen_test.go:92		0x1003e8240		97f28960		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:91		0x1003e8244		aa1803e0		MOVD R24, R0										
  q8_codegen_test.go:91		0x1003e8248		97f2895e		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:90		0x1003e824c		97f2895d		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:90		0x1003e8250		aa1303e0		MOVD R19, R0										
  q8_codegen_test.go:90		0x1003e8254		97f2895b		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:90		0x1003e8258		97f2895a		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:90		0x1003e825c		97f28959		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:78		0x1003e8260		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:78		0x1003e8264		aa1e03e1		MOVD R30, R1										
  q8_codegen_test.go:78		0x1003e8268		97f28956		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:78		0x1003e826c		aa1e03e0		MOVD R30, R0										
  q8_codegen_test.go:78		0x1003e8270		97f28954		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:78		0x1003e8274		d37ef700		LSL $2, R24, R0										
  q8_codegen_test.go:78		0x1003e8278		aa1703e1		MOVD R23, R1										
  q8_codegen_test.go:78		0x1003e827c		97f28951		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:78		0x1003e8280		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:78		0x1003e8284		97f2894f		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:68		0x1003e8288		1f060080		FMADDS F6, F0, F4, F0									
  q8_codegen_test.go:69		0x1003e828c		1f070481		FMADDS F7, F1, F4, F1									
  q8_codegen_test.go:70		0x1003e8290		1f050882		FMADDS F5, F2, F4, F2									
  q8_codegen_test.go:71		0x1003e8294		1f080c83		FMADDS F8, F3, F4, F3									
  q8_codegen_test.go:29		0x1003e8298		f94047e1		MOVD 136(RSP), R1									
  q8_codegen_test.go:35		0x1003e829c		f94087ec		MOVD 264(RSP), R12									
  q8_codegen_test.go:38		0x1003e82a0		aa0203f6		MOVD R2, R22										
  q8_codegen_test.go:38		0x1003e82a4		eb0902df		CMP R9, R22										
  q8_codegen_test.go:38		0x1003e82a8		5400114a		BGE 138(PC)										
  q8_codegen_test.go:38		0x1003e82ac		bd0037e3		FMOVS F3, 52(RSP)									
  q8_codegen_test.go:38		0x1003e82b0		bd003be2		FMOVS F2, 56(RSP)									
  q8_codegen_test.go:38		0x1003e82b4		bd0043e1		FMOVS F1, 64(RSP)									
  q8_codegen_test.go:38		0x1003e82b8		bd004be0		FMOVS F0, 72(RSP)									
  q8_codegen_test.go:40		0x1003e82bc		910006c2		ADD $1, R22, R2										
  q8_codegen_test.go:40		0x1003e82c0		d37ae441		LSL $6, R2, R1										
  q8_codegen_test.go:38		0x1003e82c4		bc767a04		FMOVS (R16)(R22<<2), F4									
  q8_codegen_test.go:38		0x1003e82c8		bd0033e4		FMOVS F4, 48(RSP)									
  q8_codegen_test.go:40		0x1003e82cc		d37ae6d6		LSL $6, R22, R22									
  q8_codegen_test.go:40		0x1003e82d0		eb0218ff		CMP R2<<6, R7										
  q8_codegen_test.go:40		0x1003e82d4		9a81b0e1		CSEL LT, R7, R1, R1									
  q8_codegen_test.go:40		0x1003e82d8		1e2703e5		FMOVS ZR, F5										
  q8_codegen_test.go:40		0x1003e82dc		1e2703e6		FMOVS ZR, F6										
  q8_codegen_test.go:40		0x1003e82e0		1e2703e7		FMOVS ZR, F7										
  q8_codegen_test.go:40		0x1003e82e4		1e2703e8		FMOVS ZR, F8										
  q8_codegen_test.go:40		0x1003e82e8		1e2703e9		FMOVS ZR, F9										
  q8_codegen_test.go:40		0x1003e82ec		1e2703ea		FMOVS ZR, F10										
  q8_codegen_test.go:40		0x1003e82f0		1e2703eb		FMOVS ZR, F11										
  q8_codegen_test.go:40		0x1003e82f4		1e2703ec		FMOVS ZR, F12										
  q8_codegen_test.go:40		0x1003e82f8		1e2703ed		FMOVS ZR, F13										
  q8_codegen_test.go:40		0x1003e82fc		1e2703ee		FMOVS ZR, F14										
  q8_codegen_test.go:40		0x1003e8300		1e2703ef		FMOVS ZR, F15										
  q8_codegen_test.go:40		0x1003e8304		1e2703f0		FMOVS ZR, F16										
  q8_codegen_test.go:40		0x1003e8308		1e2703f1		FMOVS ZR, F17										
  q8_codegen_test.go:40		0x1003e830c		1e2703f2		FMOVS ZR, F18										
  q8_codegen_test.go:40		0x1003e8310		1e2703f3		FMOVS ZR, F19										
  q8_codegen_test.go:40		0x1003e8314		1e2703f4		FMOVS ZR, F20										
  q8_codegen_test.go:40		0x1003e8318		1400002b		JMP 43(PC)										
  q8_codegen_test.go:45		0x1003e831c		bd004fe6		FMOVS F6, 76(RSP)									
  q8_codegen_test.go:42		0x1003e8320		1e2203d8		SCVTFWS R30, F24									
  q8_codegen_test.go:46		0x1003e8324		bc607b19		FMOVS (R24)(R0<<2), F25									
  q8_codegen_test.go:47		0x1003e8328		bc767aba		FMOVS (R21)(R22<<2), F26								
  q8_codegen_test.go:48		0x1003e832c		bc637abb		FMOVS (R21)(R3<<2), F27									
  q8_codegen_test.go:49		0x1003e8330		bc6f7abc		FMOVS (R21)(R15<<2), F28								
  q8_codegen_test.go:50		0x1003e8334		bc607abd		FMOVS (R21)(R0<<2), F29									
  q8_codegen_test.go:51		0x1003e8338		bc767b5e		FMOVS (R26)(R22<<2), F30								
  q8_codegen_test.go:52		0x1003e833c		bc637b5f		FMOVS (R26)(R3<<2), F31									
  q8_codegen_test.go:53		0x1003e8340		bc6f7b43		FMOVS (R26)(R15<<2), F3									
  q8_codegen_test.go:54		0x1003e8344		bc607b42		FMOVS (R26)(R0<<2), F2									
  q8_codegen_test.go:55		0x1003e8348		bc767941		FMOVS (R10)(R22<<2), F1									
  q8_codegen_test.go:56		0x1003e834c		bc637940		FMOVS (R10)(R3<<2), F0									
  q8_codegen_test.go:57		0x1003e8350		bc6f7944		FMOVS (R10)(R15<<2), F4									
  q8_codegen_test.go:58		0x1003e8354		bc607946		FMOVS (R10)(R0<<2), F6									
  q8_codegen_test.go:46		0x1003e8358		1f195314		FMADDS F25, F20, F24, F20								
  q8_codegen_test.go:47		0x1003e835c		1f1a26a9		FMADDS F26, F9, F21, F9									
  q8_codegen_test.go:48		0x1003e8360		1f1b3ace		FMADDS F27, F14, F22, F14								
  q8_codegen_test.go:49		0x1003e8364		1f1c2aea		FMADDS F28, F10, F23, F10								
  q8_codegen_test.go:50		0x1003e8368		1f1d370d		FMADDS F29, F13, F24, F13								
  q8_codegen_test.go:51		0x1003e836c		1f1e2eab		FMADDS F30, F11, F21, F11								
  q8_codegen_test.go:52		0x1003e8370		1f1f16c5		FMADDS F31, F5, F22, F5									
  q8_codegen_test.go:53		0x1003e8374		1f034ef3		FMADDS F3, F19, F23, F19								
  q8_codegen_test.go:54		0x1003e8378		1f023f0f		FMADDS F2, F15, F24, F15								
  q8_codegen_test.go:55		0x1003e837c		1f0132ac		FMADDS F1, F12, F21, F12								
  q8_codegen_test.go:56		0x1003e8380		1f0042d0		FMADDS F0, F16, F22, F16								
  q8_codegen_test.go:57		0x1003e8384		1f044af2		FMADDS F4, F18, F23, F18								
  q8_codegen_test.go:58		0x1003e8388		1f064711		FMADDS F6, F17, F24, F17								
  q8_codegen_test.go:31		0x1003e838c		f94053e0		MOVD 160(RSP), R0									
  q8_codegen_test.go:35		0x1003e8390		f9403be3		MOVD 112(RSP), R3									
  q8_codegen_test.go:32		0x1003e8394		f9408fe5		MOVD 280(RSP), R5									
  q8_codegen_test.go:34		0x1003e8398		f9405be6		MOVD 176(RSP), R6									
  q8_codegen_test.go:34		0x1003e839c		f9404bef		MOVD 144(RSP), R15									
  q8_codegen_test.go:31		0x1003e83a0		f94073f3		MOVD 224(RSP), R19									
  q8_codegen_test.go:74		0x1003e83a4		f9406ffe		MOVD 216(RSP), R30									
  q8_codegen_test.go:68		0x1003e83a8		bd404be0		FMOVS 72(RSP), F0									
  q8_codegen_test.go:69		0x1003e83ac		bd4043e1		FMOVS 64(RSP), F1									
  q8_codegen_test.go:70		0x1003e83b0		bd403be2		FMOVS 56(RSP), F2									
  q8_codegen_test.go:71		0x1003e83b4		bd4037e3		FMOVS 52(RSP), F3									
  q8_codegen_test.go:68		0x1003e83b8		bd4033e4		FMOVS 48(RSP), F4									
  q8_codegen_test.go:41		0x1003e83bc		aa0c03f6		MOVD R12, R22										
  q8_codegen_test.go:41		0x1003e83c0		bd404fe6		FMOVS 76(RSP), F6									
  q8_codegen_test.go:41		0x1003e83c4		910012cc		ADD $4, R22, R12									
  q8_codegen_test.go:41		0x1003e83c8		eb0c003f		CMP R12, R1										
  q8_codegen_test.go:41		0x1003e83cc		5400044b		BLT 34(PC)										
  q8_codegen_test.go:42		0x1003e83d0		eb0702df		CMP R7, R22										
  q8_codegen_test.go:42		0x1003e83d4		54000d22		BCS 105(PC)										
  q8_codegen_test.go:42		0x1003e83d8		910006c3		ADD $1, R22, R3										
  q8_codegen_test.go:42		0x1003e83dc		38b66a86		MOVB (R20)(R22), R6									
  q8_codegen_test.go:42		0x1003e83e0		eb0300ff		CMP R3, R7										
  q8_codegen_test.go:42		0x1003e83e4		54000c89		BLS 100(PC)										
  q8_codegen_test.go:42		0x1003e83e8		91000acf		ADD $2, R22, R15									
  q8_codegen_test.go:42		0x1003e83ec		38a36a85		MOVB (R20)(R3), R5									
  q8_codegen_test.go:42		0x1003e83f0		eb0f00ff		CMP R15, R7										
  q8_codegen_test.go:42		0x1003e83f4		54000be9		BLS 95(PC)										
  q8_codegen_test.go:42		0x1003e83f8		91000ec0		ADD $3, R22, R0										
  q8_codegen_test.go:42		0x1003e83fc		38af6a93		MOVB (R20)(R15), R19									
  q8_codegen_test.go:42		0x1003e8400		eb0000ff		CMP R0, R7										
  q8_codegen_test.go:42		0x1003e8404		54000b49		BLS 90(PC)										
  q8_codegen_test.go:42		0x1003e8408		38a06a9e		MOVB (R20)(R0), R30									
  q8_codegen_test.go:43		0x1003e840c		eb1702df		CMP R23, R22										
  q8_codegen_test.go:43		0x1003e8410		54000a82		BCS 84(PC)										
  q8_codegen_test.go:42		0x1003e8414		1e2200d5		SCVTFWS R6, F21										
  q8_codegen_test.go:43		0x1003e8418		bc767b16		FMOVS (R24)(R22<<2), F22								
  q8_codegen_test.go:43		0x1003e841c		1f1622a8		FMADDS F22, F8, F21, F8									
  q8_codegen_test.go:44		0x1003e8420		eb0302ff		CMP R3, R23										
  q8_codegen_test.go:44		0x1003e8424		540009a9		BLS 77(PC)										
  q8_codegen_test.go:42		0x1003e8428		1e2200b6		SCVTFWS R5, F22										
  q8_codegen_test.go:44		0x1003e842c		bc637b17		FMOVS (R24)(R3<<2), F23									
  q8_codegen_test.go:44		0x1003e8430		1f171ec7		FMADDS F23, F7, F22, F7									
  q8_codegen_test.go:45		0x1003e8434		eb0f02ff		CMP R15, R23										
  q8_codegen_test.go:45		0x1003e8438		540008c9		BLS 70(PC)										
  q8_codegen_test.go:42		0x1003e843c		1e220277		SCVTFWS R19, F23									
  q8_codegen_test.go:45		0x1003e8440		bc6f7b18		FMOVS (R24)(R15<<2), F24								
  q8_codegen_test.go:45		0x1003e8444		1f181ae6		FMADDS F24, F6, F23, F6									
  q8_codegen_test.go:46		0x1003e8448		eb0002ff		CMP R0, R23										
  q8_codegen_test.go:46		0x1003e844c		54fff688		BHI -76(PC)										
  q8_codegen_test.go:46		0x1003e8450		1400003e		JMP 62(PC)										
  q8_codegen_test.go:60		0x1003e8454		1e272907		FADDS F7, F8, F7									
  q8_codegen_test.go:60		0x1003e8458		1e3428c6		FADDS F20, F6, F6									
  q8_codegen_test.go:60		0x1003e845c		1e2e2928		FADDS F14, F9, F8									
  q8_codegen_test.go:60		0x1003e8460		1e2d2949		FADDS F13, F10, F9									
  q8_codegen_test.go:60		0x1003e8464		1e252965		FADDS F5, F11, F5									
  q8_codegen_test.go:60		0x1003e8468		1e2f2a6a		FADDS F15, F19, F10									
  q8_codegen_test.go:60		0x1003e846c		1e30298b		FADDS F16, F12, F11									
  q8_codegen_test.go:60		0x1003e8470		1e312a4c		FADDS F17, F18, F12									
  q8_codegen_test.go:60		0x1003e8474		1e2728c6		FADDS F7, F6, F6									
  q8_codegen_test.go:60		0x1003e8478		1e282927		FADDS F8, F9, F7									
  q8_codegen_test.go:60		0x1003e847c		1e252945		FADDS F5, F10, F5									
  q8_codegen_test.go:60		0x1003e8480		1e2b2988		FADDS F11, F12, F8									
  q8_codegen_test.go:61		0x1003e8484		1400000b		JMP 11(PC)										
  q8_codegen_test.go:62		0x1003e8488		1e220189		SCVTFWS R12, F9										
  q8_codegen_test.go:63		0x1003e848c		bc767b0a		FMOVS (R24)(R22<<2), F10								
  q8_codegen_test.go:64		0x1003e8490		bc767aab		FMOVS (R21)(R22<<2), F11								
  q8_codegen_test.go:65		0x1003e8494		bc767b4c		FMOVS (R26)(R22<<2), F12								
  q8_codegen_test.go:66		0x1003e8498		bc76794d		FMOVS (R10)(R22<<2), F13								
  q8_codegen_test.go:63		0x1003e849c		1f0a1926		FMADDS F10, F6, F9, F6									
  q8_codegen_test.go:64		0x1003e84a0		1f0b1d27		FMADDS F11, F7, F9, F7									
  q8_codegen_test.go:65		0x1003e84a4		1f0c1525		FMADDS F12, F5, F9, F5									
  q8_codegen_test.go:66		0x1003e84a8		1f0d2128		FMADDS F13, F8, F9, F8									
  q8_codegen_test.go:61		0x1003e84ac		910006d6		ADD $1, R22, R22									
  q8_codegen_test.go:61		0x1003e84b0		eb0102df		CMP R1, R22										
  q8_codegen_test.go:61		0x1003e84b4		54ffeeaa		BGE -139(PC)										
  q8_codegen_test.go:62		0x1003e84b8		eb0702df		CMP R7, R22										
  q8_codegen_test.go:62		0x1003e84bc		54000422		BCS 33(PC)										
  q8_codegen_test.go:62		0x1003e84c0		38b66a8c		MOVB (R20)(R22), R12									
  q8_codegen_test.go:63		0x1003e84c4		eb1702df		CMP R23, R22										
  q8_codegen_test.go:63		0x1003e84c8		54fffe03		BCC -16(PC)										
  q8_codegen_test.go:63		0x1003e84cc		1400001a		JMP 26(PC)										
  q8_codegen_test.go:73		0x1003e84d0		9b087daa		MUL R8, R13, R10									
  q8_codegen_test.go:73		0x1003e84d4		8b0a09ca		ADD R10<<2, R14, R10									
  q8_codegen_test.go:73		0x1003e84d8		eb0a017f		CMP R10, R11										
  q8_codegen_test.go:73		0x1003e84dc		540002a9		BLS 21(PC)										
  q8_codegen_test.go:73		0x1003e84e0		bc2a7880		FMOVS F0, (R4)(R10<<2)									
  q8_codegen_test.go:73		0x1003e84e4		9b083a2a		MADD R8, R14, R17, R10									
  q8_codegen_test.go:73		0x1003e84e8		eb0a017f		CMP R10, R11										
  q8_codegen_test.go:73		0x1003e84ec		54000209		BLS 16(PC)										
  q8_codegen_test.go:73		0x1003e84f0		bc2a7881		FMOVS F1, (R4)(R10<<2)									
  q8_codegen_test.go:74		0x1003e84f4		9b083b2a		MADD R8, R14, R25, R10									
  q8_codegen_test.go:74		0x1003e84f8		eb0a017f		CMP R10, R11										
  q8_codegen_test.go:74		0x1003e84fc		54000169		BLS 11(PC)										
  q8_codegen_test.go:74		0x1003e8500		bc2a7882		FMOVS F2, (R4)(R10<<2)									
  q8_codegen_test.go:74		0x1003e8504		9b083bca		MADD R8, R14, R30, R10									
  q8_codegen_test.go:74		0x1003e8508		eb0a017f		CMP R10, R11										
  q8_codegen_test.go:74		0x1003e850c		540000c9		BLS 6(PC)										
  q8_codegen_test.go:74		0x1003e8510		bc2a7883		FMOVS F3, (R4)(R10<<2)									
  q8_codegen_test.go:29		0x1003e8514		f940a7e2		MOVD 328(RSP), R2									
  q8_codegen_test.go:30		0x1003e8518		f94043ea		MOVD 128(RSP), R10									
  q8_codegen_test.go:34		0x1003e851c		aa0f03f1		MOVD R15, R17										
  q8_codegen_test.go:74		0x1003e8520		17fffdb1		JMP -591(PC)										
  q8_codegen_test.go:74		0x1003e8524		97f288a7		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:74		0x1003e8528		97f288a6		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:73		0x1003e852c		97f288a5		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:73		0x1003e8530		97f288a4		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:63		0x1003e8534		aa1603e0		MOVD R22, R0										
  q8_codegen_test.go:63		0x1003e8538		aa1703e1		MOVD R23, R1										
  q8_codegen_test.go:63		0x1003e853c		97f288a1		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:62		0x1003e8540		aa1603e0		MOVD R22, R0										
  q8_codegen_test.go:62		0x1003e8544		97f2889f		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:46		0x1003e8548		aa1703e1		MOVD R23, R1										
  q8_codegen_test.go:46		0x1003e854c		97f2889d		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:45		0x1003e8550		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:45		0x1003e8554		97f2889b		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:44		0x1003e8558		aa1703e0		MOVD R23, R0										
  q8_codegen_test.go:44		0x1003e855c		97f28899		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:43		0x1003e8560		aa1603e0		MOVD R22, R0										
  q8_codegen_test.go:43		0x1003e8564		aa1703e1		MOVD R23, R1										
  q8_codegen_test.go:43		0x1003e8568		97f28896		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:42		0x1003e856c		97f28895		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:42		0x1003e8570		97f28894		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:42		0x1003e8574		97f28893		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:42		0x1003e8578		aa1603e0		MOVD R22, R0										
  q8_codegen_test.go:42		0x1003e857c		97f28891		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:36		0x1003e8580		aa1603e0		MOVD R22, R0										
  q8_codegen_test.go:36		0x1003e8584		97f2888f		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:36		0x1003e8588		aa1603e0		MOVD R22, R0										
  q8_codegen_test.go:36		0x1003e858c		97f2888d		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:36		0x1003e8590		aa1a03e0		MOVD R26, R0										
  q8_codegen_test.go:36		0x1003e8594		97f2888b		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:36		0x1003e8598		97f2888a		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:35		0x1003e859c		aa1503e0		MOVD R21, R0										
  q8_codegen_test.go:35		0x1003e85a0		aa1a03e1		MOVD R26, R1										
  q8_codegen_test.go:35		0x1003e85a4		97f28887		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:35		0x1003e85a8		aa1a03e0		MOVD R26, R0										
  q8_codegen_test.go:35		0x1003e85ac		97f28885		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:35		0x1003e85b0		d37ef6e0		LSL $2, R23, R0										
  q8_codegen_test.go:35		0x1003e85b4		aa1503e1		MOVD R21, R1										
  q8_codegen_test.go:35		0x1003e85b8		97f28882		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:35		0x1003e85bc		aa1503e0		MOVD R21, R0										
  q8_codegen_test.go:35		0x1003e85c0		97f28880		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:33		0x1003e85c4		aa1503e0		MOVD R21, R0										
  q8_codegen_test.go:33		0x1003e85c8		aa1803e1		MOVD R24, R1										
  q8_codegen_test.go:33		0x1003e85cc		97f2887d		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:33		0x1003e85d0		aa1803e0		MOVD R24, R0										
  q8_codegen_test.go:33		0x1003e85d4		aa1703e1		MOVD R23, R1										
  q8_codegen_test.go:33		0x1003e85d8		97f2887a		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:32		0x1003e85dc		aa1503e0		MOVD R21, R0										
  q8_codegen_test.go:32		0x1003e85e0		aa1403e1		MOVD R20, R1										
  q8_codegen_test.go:32		0x1003e85e4		97f28877		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:32		0x1003e85e8		aa1403e0		MOVD R20, R0										
  q8_codegen_test.go:32		0x1003e85ec		aa1103e1		MOVD R17, R1										
  q8_codegen_test.go:32		0x1003e85f0		97f28874		CALL runtime.panicBounds(SB)								
  q8_codegen_test.go:30		0x1003e85f4		97f175bb		CALL runtime.panicdivide(SB)								
  q8_codegen_test.go:30		0x1003e85f8		d503201f		NOOP											
  q8_codegen_test.go:26		0x1003e85fc		a90087e0		STP (R0, R1), 8(RSP)									
  q8_codegen_test.go:26		0x1003e8600		f9000fe2		MOVD R2, 24(RSP)									
  q8_codegen_test.go:26		0x1003e8604		aa1e03e3		MOVD R30, R3										
  q8_codegen_test.go:26		0x1003e8608		97f2802a		CALL runtime.morestack_noctxt.abi0(SB)							
  q8_codegen_test.go:26		0x1003e860c		a94087e0		LDP 8(RSP), (R0, R1)									
  q8_codegen_test.go:26		0x1003e8610		f9400fe2		MOVD 24(RSP), R2									
  q8_codegen_test.go:26		0x1003e8614		17fffd4b		JMP github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.q8CachedRangeProbe(SB)	
  q8_codegen_test.go:26		0x1003e8618		00000000		?											
  q8_codegen_test.go:26		0x1003e861c		00000000		?											

TEXT github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.linearQ8Into.func1(SB) /Users/ryohiga/SpiralReality/sr_go_transformer/cmd/monolith/monolith.go
  monolith.go:4151	0x10040be30		f9400b90		MOVD 16(R28), R16									
  monolith.go:4151	0x10040be34		d102c3f1		SUB $176, RSP, R17									
  monolith.go:4151	0x10040be38		eb10023f		CMP R16, R17										
  monolith.go:4151	0x10040be3c		540055c9		BLS 686(PC)										
  monolith.go:4151	0x10040be40		d104c3f4		SUB $304, RSP, R20									
  monolith.go:4151	0x10040be44		a93ffa9d		STP (R29, R30), -8(R20)									
  monolith.go:4151	0x10040be48		9100029f		MOVD R20, RSP										
  monolith.go:4151	0x10040be4c		d10023fd		SUB $8, RSP, R29									
  monolith.go:4152	0x10040be50		f900a3e1		MOVD R1, 320(RSP)									
  monolith.go:4151	0x10040be54		a9419343		LDP 24(R26), (R3, R4)									
  monolith.go:4151	0x10040be58		f9005fe4		MOVD R4, 184(RSP)									
  monolith.go:4151	0x10040be5c		f9008fe3		MOVD R3, 280(RSP)									
  monolith.go:4151	0x10040be60		a9429b45		LDP 40(R26), (R5, R6)									
  monolith.go:4151	0x10040be64		f90063e5		MOVD R5, 192(RSP)									
  monolith.go:4151	0x10040be68		f9005be6		MOVD R6, 176(RSP)									
  monolith.go:4151	0x10040be6c		a944a347		LDP 72(R26), (R7, R8)									
  monolith.go:4151	0x10040be70		f9003be7		MOVD R7, 112(RSP)									
  monolith.go:4151	0x10040be74		f9007be8		MOVD R8, 240(RSP)									
  monolith.go:4151	0x10040be78		a940ab49		LDP 8(R26), (R9, R10)									
  monolith.go:4151	0x10040be7c		f9004fea		MOVD R10, 152(RSP)									
  monolith.go:4151	0x10040be80		f90043e9		MOVD R9, 128(RSP)									
  monolith.go:4151	0x10040be84		f9402f4b		MOVD 88(R26), R11									
  monolith.go:4151	0x10040be88		f9002beb		MOVD R11, 80(RSP)									
  monolith.go:4151	0x10040be8c		f9401f4c		MOVD 56(R26), R12									
  monolith.go:4151	0x10040be90		f90087ec		MOVD R12, 264(RSP)									
  monolith.go:4152	0x10040be94		14000002		JMP 2(PC)										
  monolith.go:4152	0x10040be98		91000400		ADD $1, R0, R0										
  monolith.go:4152	0x10040be9c		eb00003f		CMP R0, R1										
  monolith.go:4152	0x10040bea0		54001b2d		BLE 217(PC)										
  monolith.go:4153	0x10040bea4		b4005249		CBZ R9, 658(PC)										
  monolith.go:4152	0x10040bea8		f90047e0		MOVD R0, 136(RSP)									
  monolith.go:4153	0x10040beac		9ac90c0d		SDIV R9, R0, R13									
  monolith.go:4153	0x10040beb0		f90077ed		MOVD R13, 232(RSP)									
  monolith.go:4153	0x10040beb4		9ac90c1b		SDIV R9, R0, R27									
  monolith.go:4153	0x10040beb8		9b09836e		MSUB R9, R0, R27, R14									
  monolith.go:4153	0x10040bebc		d37ef5af		LSL $2, R13, R15									
  monolith.go:4153	0x10040bec0		f9004bef		MOVD R15, 144(RSP)									
  monolith.go:4153	0x10040bec4		d37be9ce		LSL $5, R14, R14									
  monolith.go:4153	0x10040bec8		f90053ee		MOVD R14, 160(RSP)									
  monolith.go:4153	0x10040becc		aa0e03e2		MOVD R14, R2										
  monolith.go:4154	0x10040bed0		14000003		JMP 3(PC)										
  monolith.go:4157	0x10040bed4		aa1103ef		MOVD R17, R15										
  monolith.go:4154	0x10040bed8		aa1303ee		MOVD R19, R14										
  monolith.go:4154	0x10040bedc		91008050		ADD $32, R2, R16									
  monolith.go:4154	0x10040bee0		eb10015f		CMP R16, R10										
  monolith.go:4154	0x10040bee4		9a90b150		CSEL LT, R10, R16, R16									
  monolith.go:4154	0x10040bee8		eb1001df		CMP R16, R14										
  monolith.go:4154	0x10040beec		54fffd6a		BGE -21(PC)										
  monolith.go:4155	0x10040bef0		f9404470		MOVD 136(R3), R16									
  monolith.go:4155	0x10040bef4		f9400a11		MOVD 16(R16), R17									
  monolith.go:4155	0x10040bef8		910005d3		ADD $1, R14, R19									
  monolith.go:4155	0x10040befc		9b047e74		MUL R4, R19, R20									
  monolith.go:4155	0x10040bf00		9b047dd5		MUL R4, R14, R21									
  monolith.go:4155	0x10040bf04		eb14023f		CMP R20, R17										
  monolith.go:4155	0x10040bf08		54004ec3		BCC 630(PC)										
  monolith.go:4155	0x10040bf0c		eb15029f		CMP R21, R20										
  monolith.go:4155	0x10040bf10		54004e23		BCC 625(PC)										
  monolith.go:4155	0x10040bf14		f9400214		MOVD (R16), R20										
  monolith.go:4155	0x10040bf18		cb1102b6		SUB R17, R21, R22									
  monolith.go:4155	0x10040bf1c		8a96feb6		AND R22->63, R21, R22									
  monolith.go:4156	0x10040bf20		f9401617		MOVD 40(R16), R23									
  monolith.go:4156	0x10040bf24		9b057e78		MUL R5, R19, R24									
  monolith.go:4155	0x10040bf28		8b160294		ADD R22, R20, R20									
  monolith.go:4155	0x10040bf2c		cb150231		SUB R21, R17, R17									
  monolith.go:4156	0x10040bf30		9b057dd5		MUL R5, R14, R21									
  monolith.go:4156	0x10040bf34		eb1802ff		CMP R24, R23										
  monolith.go:4156	0x10040bf38		54004c83		BCC 612(PC)										
  monolith.go:4156	0x10040bf3c		eb15031f		CMP R21, R24										
  monolith.go:4156	0x10040bf40		54004be3		BCC 607(PC)										
  monolith.go:4155	0x10040bf44		f90073f3		MOVD R19, 224(RSP)									
  monolith.go:4156	0x10040bf48		f9400e10		MOVD 24(R16), R16									
  monolith.go:4156	0x10040bf4c		cb1702b6		SUB R23, R21, R22									
  monolith.go:4156	0x10040bf50		8a96feb5		AND R22->63, R21, R21									
  monolith.go:4157	0x10040bf54		910011f6		ADD $4, R15, R22									
  monolith.go:4156	0x10040bf58		8b150a10		ADD R21<<2, R16, R16									
  monolith.go:4157	0x10040bf5c		eb1600df		CMP R22, R6										
  monolith.go:4157	0x10040bf60		540005cb		BLT 46(PC)										
  monolith.go:4158	0x10040bf64		910005f1		ADD $1, R15, R17									
  monolith.go:4158	0x10040bf68		9b117c95		MUL R17, R4, R21									
  monolith.go:4158	0x10040bf6c		9b047db7		MUL R4, R13, R23									
  monolith.go:4158	0x10040bf70		eb1500ff		CMP R21, R7										
  monolith.go:4158	0x10040bf74		54004a03		BCC 592(PC)										
  monolith.go:4158	0x10040bf78		eb170abf		CMP R23<<2, R21										
  monolith.go:4158	0x10040bf7c		54004963		BCC 587(PC)										
  monolith.go:4158	0x10040bf80		cb1708f8		SUB R23<<2, R7, R24									
  monolith.go:4158	0x10040bf84		cb1803f8		NEG R24, R24										
  monolith.go:4158	0x10040bf88		8a98fef8		AND R24->63, R23, R24									
  monolith.go:4158	0x10040bf8c		910009f9		ADD $2, R15, R25									
  monolith.go:4158	0x10040bf90		9b197c9a		MUL R25, R4, R26									
  monolith.go:4158	0x10040bf94		cb170ab7		SUB R23<<2, R21, R23									
  monolith.go:4158	0x10040bf98		8b181198		ADD R24<<4, R12, R24									
  monolith.go:4158	0x10040bf9c		eb1a00ff		CMP R26, R7										
  monolith.go:4158	0x10040bfa0		54004803		BCC 576(PC)										
  monolith.go:4158	0x10040bfa4		eb15035f		CMP R21, R26										
  monolith.go:4158	0x10040bfa8		54004763		BCC 571(PC)										
  monolith.go:4158	0x10040bfac		cb0702be		SUB R7, R21, R30									
  monolith.go:4158	0x10040bfb0		8a9efeb5		AND R30->63, R21, R21									
  monolith.go:4159	0x10040bfb4		91000dfe		ADD $3, R15, R30									
  monolith.go:4159	0x10040bfb8		9b047fc9		MUL R4, R30, R9										
  monolith.go:4158	0x10040bfbc		8b150995		ADD R21<<2, R12, R21									
  monolith.go:4159	0x10040bfc0		eb0900ff		CMP R9, R7										
  monolith.go:4159	0x10040bfc4		54004663		BCC 563(PC)										
  monolith.go:4159	0x10040bfc8		eb1a013f		CMP R26, R9										
  monolith.go:4159	0x10040bfcc		540045e3		BCC 559(PC)										
  monolith.go:4159	0x10040bfd0		cb070341		SUB R7, R26, R1										
  monolith.go:4159	0x10040bfd4		8a81ff5a		AND R1->63, R26, R26									
  monolith.go:4159	0x10040bfd8		9b047ed6		MUL R4, R22, R22									
  monolith.go:4159	0x10040bfdc		8b1a099a		ADD R26<<2, R12, R26									
  monolith.go:4159	0x10040bfe0		eb1600ff		CMP R22, R7										
  monolith.go:4159	0x10040bfe4		540044e3		BCC 551(PC)										
  monolith.go:4159	0x10040bfe8		eb0902df		CMP R9, R22										
  monolith.go:4159	0x10040bfec		54004463		BCC 547(PC)										
  monolith.go:4159	0x10040bff0		f9006ffe		MOVD R30, 216(RSP)									
  monolith.go:4159	0x10040bff4		cb070136		SUB R7, R9, R22										
  monolith.go:4159	0x10040bff8		8a96fd29		AND R22->63, R9, R9									
  monolith.go:4159	0x10040bffc		8b090989		ADD R9<<2, R12, R9									
  monolith.go:4161	0x10040c000		aa1f03f6		MOVD ZR, R22										
  monolith.go:4161	0x10040c004		1e2703e0		FMOVS ZR, F0										
  monolith.go:4161	0x10040c008		1e2703e1		FMOVS ZR, F1										
  monolith.go:4161	0x10040c00c		1e2703e2		FMOVS ZR, F2										
  monolith.go:4161	0x10040c010		1e2703e3		FMOVS ZR, F3										
  monolith.go:4161	0x10040c014		14000161		JMP 353(PC)										
  monolith.go:4200	0x10040c018		910009f5		ADD $2, R15, R21									
  monolith.go:4200	0x10040c01c		eb1500df		CMP R21, R6										
  monolith.go:4200	0x10040c020		540004ab		BLT 37(PC)										
  monolith.go:4201	0x10040c024		910005f6		ADD $1, R15, R22									
  monolith.go:4201	0x10040c028		9b167c97		MUL R22, R4, R23									
  monolith.go:4201	0x10040c02c		9b047db8		MUL R4, R13, R24									
  monolith.go:4201	0x10040c030		eb1700ff		CMP R23, R7										
  monolith.go:4201	0x10040c034		54002a03		BCC 336(PC)										
  monolith.go:4201	0x10040c038		eb180aff		CMP R24<<2, R23										
  monolith.go:4201	0x10040c03c		54002963		BCC 331(PC)										
  monolith.go:4201	0x10040c040		cb1808f9		SUB R24<<2, R7, R25									
  monolith.go:4201	0x10040c044		cb1903fa		NEG R25, R26										
  monolith.go:4201	0x10040c048		8a9aff1a		AND R26->63, R24, R26									
  monolith.go:4201	0x10040c04c		9b157c9e		MUL R21, R4, R30									
  monolith.go:4201	0x10040c050		cb180af8		SUB R24<<2, R23, R24									
  monolith.go:4201	0x10040c054		8b1a119a		ADD R26<<4, R12, R26									
  monolith.go:4201	0x10040c058		eb1e00ff		CMP R30, R7										
  monolith.go:4201	0x10040c05c		54002823		BCC 321(PC)										
  monolith.go:4201	0x10040c060		eb1703df		CMP R23, R30										
  monolith.go:4201	0x10040c064		54002783		BCC 316(PC)										
  monolith.go:4155	0x10040c068		f9003ff1		MOVD R17, 120(RSP)									
  monolith.go:4155	0x10040c06c		f9008bf4		MOVD R20, 272(RSP)									
  monolith.go:4156	0x10040c070		f90093f0		MOVD R16, 288(RSP)									
  monolith.go:4200	0x10040c074		f9006ff5		MOVD R21, 216(RSP)									
  monolith.go:4201	0x10040c078		f9006bf6		MOVD R22, 208(RSP)									
  monolith.go:4201	0x10040c07c		f90033f8		MOVD R24, 96(RSP)									
  monolith.go:4201	0x10040c080		f90037f9		MOVD R25, 104(RSP)									
  monolith.go:4201	0x10040c084		f90083fa		MOVD R26, 256(RSP)									
  monolith.go:4154	0x10040c088		f90057ee		MOVD R14, 168(RSP)									
  monolith.go:4201	0x10040c08c		cb0702fe		SUB R7, R23, R30									
  monolith.go:4201	0x10040c090		8a9efefe		AND R30->63, R23, R30									
  monolith.go:4201	0x10040c094		8b1e099e		ADD R30<<2, R12, R30									
  monolith.go:4201	0x10040c098		f9007ffe		MOVD R30, 248(RSP)									
  monolith.go:4201	0x10040c09c		cb1700f7		SUB R23, R7, R23									
  monolith.go:4201	0x10040c0a0		f9002ff7		MOVD R23, 88(RSP)									
  monolith.go:4203	0x10040c0a4		aa1f03e9		MOVD ZR, R9										
  monolith.go:4203	0x10040c0a8		1e2703e0		FMOVS ZR, F0										
  monolith.go:4203	0x10040c0ac		1e2703e1		FMOVS ZR, F1										
  monolith.go:4203	0x10040c0b0		14000086		JMP 134(PC)										
  monolith.go:4153	0x10040c0b4		aa0f03f1		MOVD R15, R17										
  monolith.go:4200	0x10040c0b8		14000003		JMP 3(PC)										
  monolith.go:4253	0x10040c0bc		bc2f7900		FMOVS F0, (R8)(R15<<2)									
  monolith.go:4235	0x10040c0c0		aa1503ef		MOVD R21, R15										
  monolith.go:4235	0x10040c0c4		eb0601ff		CMP R6, R15										
  monolith.go:4235	0x10040c0c8		54fff06a		BGE -125(PC)										
  monolith.go:4236	0x10040c0cc		910005f5		ADD $1, R15, R21									
  monolith.go:4236	0x10040c0d0		9b047eb6		MUL R4, R21, R22									
  monolith.go:4236	0x10040c0d4		9b047df7		MUL R4, R15, R23									
  monolith.go:4236	0x10040c0d8		eb1600ff		CMP R22, R7										
  monolith.go:4236	0x10040c0dc		54000b63		BCC 91(PC)										
  monolith.go:4236	0x10040c0e0		eb1702df		CMP R23, R22										
  monolith.go:4236	0x10040c0e4		54000ac3		BCC 86(PC)										
  monolith.go:4236	0x10040c0e8		cb0702f6		SUB R7, R23, R22									
  monolith.go:4236	0x10040c0ec		8a96fef6		AND R22->63, R23, R22									
  monolith.go:4236	0x10040c0f0		8b160996		ADD R22<<2, R12, R22									
  monolith.go:4238	0x10040c0f4		aa1f03f7		MOVD ZR, R23										
  monolith.go:4238	0x10040c0f8		1e2703e0		FMOVS ZR, F0										
  monolith.go:4238	0x10040c0fc		14000003		JMP 3(PC)										
  monolith.go:4251	0x10040c100		1f020020		FMADDS F2, F0, F1, F0									
  monolith.go:4238	0x10040c104		aa1803f7		MOVD R24, R23										
  monolith.go:4238	0x10040c108		eb0502ff		CMP R5, R23										
  monolith.go:4238	0x10040c10c		5400074a		BGE 58(PC)										
  monolith.go:4239	0x10040c110		910006f8		ADD $1, R23, R24									
  monolith.go:4239	0x10040c114		d37ae719		LSL $6, R24, R25									
  monolith.go:4238	0x10040c118		bc777a01		FMOVS (R16)(R23<<2), F1									
  monolith.go:4239	0x10040c11c		d37ae6f7		LSL $6, R23, R23									
  monolith.go:4239	0x10040c120		eb18189f		CMP R24<<6, R4										
  monolith.go:4239	0x10040c124		9a99b099		CSEL LT, R4, R25, R25									
  monolith.go:4239	0x10040c128		1e2703e2		FMOVS ZR, F2										
  monolith.go:4239	0x10040c12c		1e2703e3		FMOVS ZR, F3										
  monolith.go:4239	0x10040c130		1e2703e4		FMOVS ZR, F4										
  monolith.go:4239	0x10040c134		1e2703e5		FMOVS ZR, F5										
  monolith.go:4239	0x10040c138		14000006		JMP 6(PC)										
  monolith.go:4245	0x10040c13c		bc777ac6		FMOVS (R22)(R23<<2), F6									
  monolith.go:4245	0x10040c140		38b76a9e		MOVB (R20)(R23), R30									
  monolith.go:4245	0x10040c144		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4245	0x10040c148		1f0708c2		FMADDS F7, F2, F6, F2									
  monolith.go:4241	0x10040c14c		aa1a03f7		MOVD R26, R23										
  monolith.go:4241	0x10040c150		910012fa		ADD $4, R23, R26									
  monolith.go:4241	0x10040c154		eb1a033f		CMP R26, R25										
  monolith.go:4241	0x10040c158		5400032b		BLT 25(PC)										
  monolith.go:4242	0x10040c15c		eb0402ff		CMP R4, R23										
  monolith.go:4242	0x10040c160		540006a2		BCS 53(PC)										
  monolith.go:4242	0x10040c164		bc777ac6		FMOVS (R22)(R23<<2), F6									
  monolith.go:4242	0x10040c168		38b76a9e		MOVB (R20)(R23), R30									
  monolith.go:4242	0x10040c16c		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4243	0x10040c170		910006fe		ADD $1, R23, R30									
  monolith.go:4242	0x10040c174		1f070cc3		FMADDS F7, F3, F6, F3									
  monolith.go:4243	0x10040c178		eb1e009f		CMP R30, R4										
  monolith.go:4243	0x10040c17c		54000589		BLS 44(PC)										
  monolith.go:4243	0x10040c180		bc7e7ac6		FMOVS (R22)(R30<<2), F6									
  monolith.go:4243	0x10040c184		38be6a9e		MOVB (R20)(R30), R30									
  monolith.go:4243	0x10040c188		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4244	0x10040c18c		91000afe		ADD $2, R23, R30									
  monolith.go:4243	0x10040c190		1f0710c4		FMADDS F7, F4, F6, F4									
  monolith.go:4244	0x10040c194		eb1e009f		CMP R30, R4										
  monolith.go:4244	0x10040c198		54000469		BLS 35(PC)										
  monolith.go:4244	0x10040c19c		bc7e7ac6		FMOVS (R22)(R30<<2), F6									
  monolith.go:4244	0x10040c1a0		38be6a9e		MOVB (R20)(R30), R30									
  monolith.go:4244	0x10040c1a4		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4245	0x10040c1a8		91000ef7		ADD $3, R23, R23									
  monolith.go:4244	0x10040c1ac		1f0714c5		FMADDS F7, F5, F6, F5									
  monolith.go:4245	0x10040c1b0		eb17009f		CMP R23, R4										
  monolith.go:4245	0x10040c1b4		54fffc48		BHI -30(PC)										
  monolith.go:4245	0x10040c1b8		14000019		JMP 25(PC)										
  monolith.go:4247	0x10040c1bc		1e242863		FADDS F4, F3, F3									
  monolith.go:4247	0x10040c1c0		1e2228a2		FADDS F2, F5, F2									
  monolith.go:4247	0x10040c1c4		1e222862		FADDS F2, F3, F2									
  monolith.go:4248	0x10040c1c8		14000006		JMP 6(PC)										
  monolith.go:4249	0x10040c1cc		bc777ac3		FMOVS (R22)(R23<<2), F3									
  monolith.go:4249	0x10040c1d0		38b76a9a		MOVB (R20)(R23), R26									
  monolith.go:4249	0x10040c1d4		1e220344		SCVTFWS R26, F4										
  monolith.go:4249	0x10040c1d8		1f040862		FMADDS F4, F2, F3, F2									
  monolith.go:4248	0x10040c1dc		910006f7		ADD $1, R23, R23									
  monolith.go:4248	0x10040c1e0		eb1902ff		CMP R25, R23										
  monolith.go:4248	0x10040c1e4		54fff8ea		BGE -57(PC)										
  monolith.go:4249	0x10040c1e8		eb0402ff		CMP R4, R23										
  monolith.go:4249	0x10040c1ec		54ffff03		BCC -8(PC)										
  monolith.go:4249	0x10040c1f0		14000009		JMP 9(PC)										
  monolith.go:4253	0x10040c1f4		9b0f394f		MADD R15, R14, R10, R15									
  monolith.go:4253	0x10040c1f8		eb0f017f		CMP R15, R11										
  monolith.go:4253	0x10040c1fc		54fff608		BHI -80(PC)										
  monolith.go:4253	0x10040c200		14000004		JMP 4(PC)										
  monolith.go:4258	0x10040c204		a97ffbfd		LDP -8(RSP), (R29, R30)									
  monolith.go:4258	0x10040c208		9104c3ff		ADD $304, RSP, RSP									
  monolith.go:4258	0x10040c20c		d65f03c0		RET											
  monolith.go:4253	0x10040c210		97f1f96c		CALL runtime.panicBounds(SB)								
  monolith.go:4249	0x10040c214		aa1703e0		MOVD R23, R0										
  monolith.go:4249	0x10040c218		97f1f96a		CALL runtime.panicBounds(SB)								
  monolith.go:4245	0x10040c21c		aa1703e0		MOVD R23, R0										
  monolith.go:4245	0x10040c220		97f1f968		CALL runtime.panicBounds(SB)								
  monolith.go:4244	0x10040c224		aa1e03e0		MOVD R30, R0										
  monolith.go:4244	0x10040c228		97f1f966		CALL runtime.panicBounds(SB)								
  monolith.go:4243	0x10040c22c		aa1e03e0		MOVD R30, R0										
  monolith.go:4243	0x10040c230		97f1f964		CALL runtime.panicBounds(SB)								
  monolith.go:4242	0x10040c234		aa1703e0		MOVD R23, R0										
  monolith.go:4242	0x10040c238		97f1f962		CALL runtime.panicBounds(SB)								
  monolith.go:4236	0x10040c23c		aa1703e0		MOVD R23, R0										
  monolith.go:4236	0x10040c240		aa1603e1		MOVD R22, R1										
  monolith.go:4236	0x10040c244		97f1f95f		CALL runtime.panicBounds(SB)								
  monolith.go:4236	0x10040c248		aa1603e0		MOVD R22, R0										
  monolith.go:4236	0x10040c24c		97f1f95d		CALL runtime.panicBounds(SB)								
  monolith.go:4152	0x10040c250		f94047e0		MOVD 136(RSP), R0									
  monolith.go:4152	0x10040c254		f940a3e1		MOVD 320(RSP), R1									
  monolith.go:4154	0x10040c258		f94053e2		MOVD 160(RSP), R2									
  monolith.go:4155	0x10040c25c		f9408fe3		MOVD 280(RSP), R3									
  monolith.go:4204	0x10040c260		f9405fe4		MOVD 184(RSP), R4									
  monolith.go:4203	0x10040c264		f94063e5		MOVD 192(RSP), R5									
  monolith.go:4235	0x10040c268		f9405be6		MOVD 176(RSP), R6									
  monolith.go:4236	0x10040c26c		f9403be7		MOVD 112(RSP), R7									
  monolith.go:4232	0x10040c270		f9407be8		MOVD 240(RSP), R8									
  monolith.go:4232	0x10040c274		f9404fea		MOVD 152(RSP), R10									
  monolith.go:4232	0x10040c278		f9402beb		MOVD 80(RSP), R11									
  monolith.go:4236	0x10040c27c		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4232	0x10040c280		f94077ed		MOVD 232(RSP), R13									
  monolith.go:4232	0x10040c284		f94057ee		MOVD 168(RSP), R14									
  monolith.go:4157	0x10040c288		f9404bef		MOVD 144(RSP), R15									
  monolith.go:4203	0x10040c28c		f94093f0		MOVD 288(RSP), R16									
  monolith.go:4206	0x10040c290		f9403ff1		MOVD 120(RSP), R17									
  monolith.go:4154	0x10040c294		f94073f3		MOVD 224(RSP), R19									
  monolith.go:4213	0x10040c298		f9408bf4		MOVD 272(RSP), R20									
  monolith.go:4235	0x10040c29c		f9406ff5		MOVD 216(RSP), R21									
  monolith.go:4232	0x10040c2a0		f9406bf6		MOVD 208(RSP), R22									
  monolith.go:4206	0x10040c2a4		f9402ff7		MOVD 88(RSP), R23									
  monolith.go:4214	0x10040c2a8		f94033f8		MOVD 96(RSP), R24									
  monolith.go:4206	0x10040c2ac		f94037f9		MOVD 104(RSP), R25									
  monolith.go:4214	0x10040c2b0		f94083fa		MOVD 256(RSP), R26									
  monolith.go:4218	0x10040c2b4		f9407ffe		MOVD 248(RSP), R30									
  monolith.go:4203	0x10040c2b8		f94067e9		MOVD 200(RSP), R9									
  monolith.go:4203	0x10040c2bc		1e204002		FMOVS F0, F2										
  monolith.go:4203	0x10040c2c0		1e204020		FMOVS F1, F0										
  monolith.go:4203	0x10040c2c4		1e204041		FMOVS F2, F1										
  monolith.go:4203	0x10040c2c8		eb05013f		CMP R5, R9										
  monolith.go:4203	0x10040c2cc		5400056a		BGE 43(PC)										
  monolith.go:4204	0x10040c2d0		91000521		ADD $1, R9, R1										
  monolith.go:4204	0x10040c2d4		f90067e1		MOVD R1, 200(RSP)									
  monolith.go:4204	0x10040c2d8		d37ae420		LSL $6, R1, R0										
  monolith.go:4203	0x10040c2dc		bc697a02		FMOVS (R16)(R9<<2), F2									
  monolith.go:4204	0x10040c2e0		d37ae52f		LSL $6, R9, R15										
  monolith.go:4204	0x10040c2e4		eb01189f		CMP R1<<6, R4										
  monolith.go:4204	0x10040c2e8		9a80b080		CSEL LT, R4, R0, R0									
  monolith.go:4205	0x10040c2ec		cb091803		SUB R9<<6, R0, R3									
  monolith.go:4205	0x10040c2f0		f101007f		CMP $64, R3										
  monolith.go:4204	0x10040c2f4		54000140		BEQ 10(PC)										
  monolith.go:4205	0x10040c2f8		1e2703e3		FMOVS ZR, F3										
  monolith.go:4205	0x10040c2fc		1e2703e4		FMOVS ZR, F4										
  monolith.go:4205	0x10040c300		1e2703e5		FMOVS ZR, F5										
  monolith.go:4205	0x10040c304		1e2703e6		FMOVS ZR, F6										
  monolith.go:4205	0x10040c308		1e2703e7		FMOVS ZR, F7										
  monolith.go:4205	0x10040c30c		1e2703e8		FMOVS ZR, F8										
  monolith.go:4205	0x10040c310		1e2703e9		FMOVS ZR, F9										
  monolith.go:4205	0x10040c314		1e2703ea		FMOVS ZR, F10										
  monolith.go:4205	0x10040c318		14000041		JMP 65(PC)										
  monolith.go:4206	0x10040c31c		eb19001f		CMP R25, R0										
  monolith.go:4206	0x10040c320		54000568		BHI 43(PC)										
  monolith.go:4206	0x10040c324		eb09181f		CMP R9<<6, R0										
  monolith.go:4206	0x10040c328		54000503		BCC 40(PC)										
  monolith.go:4206	0x10040c32c		8b092343		ADD R9<<8, R26, R3									
  monolith.go:4206	0x10040c330		eb17001f		CMP R23, R0										
  monolith.go:4206	0x10040c334		54000468		BHI 35(PC)										
  monolith.go:4206	0x10040c338		8b0923cf		ADD R9<<8, R30, R15									
  monolith.go:4206	0x10040c33c		eb11001f		CMP R17, R0										
  monolith.go:4206	0x10040c340		540003c8		BHI 30(PC)										
  monolith.go:4203	0x10040c344		bd002fe2		FMOVS F2, 44(RSP)									
  monolith.go:4203	0x10040c348		bd003fe0		FMOVS F0, 60(RSP)									
  monolith.go:4203	0x10040c34c		bd0047e1		FMOVS F1, 68(RSP)									
  monolith.go:4206	0x10040c350		8b091a82		ADD R9<<6, R20, R2									
  monolith.go:4206	0x10040c354		aa0303e0		MOVD R3, R0										
  monolith.go:4206	0x10040c358		aa0f03e1		MOVD R15, R1										
  monolith.go:4206	0x10040c35c		97fca6f9		CALL github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.dotQ8PairBlock64(SB)	
  monolith.go:4207	0x10040c360		bd4047e2		FMOVS 68(RSP), F2									
  monolith.go:4207	0x10040c364		bd402fe3		FMOVS 44(RSP), F3									
  monolith.go:4207	0x10040c368		1f000860		FMADDS F0, F2, F3, F0									
  monolith.go:4208	0x10040c36c		bd403fe2		FMOVS 60(RSP), F2									
  monolith.go:4208	0x10040c370		1f010861		FMADDS F1, F2, F3, F1									
  monolith.go:4209	0x10040c374		17ffffb7		JMP -73(PC)										
  monolith.go:4232	0x10040c378		9b0a7da9		MUL R10, R13, R9									
  monolith.go:4232	0x10040c37c		8b0909c9		ADD R9<<2, R14, R9									
  monolith.go:4232	0x10040c380		9b0a3ad1		MADD R10, R14, R22, R17									
  monolith.go:4232	0x10040c384		eb09017f		CMP R9, R11										
  monolith.go:4232	0x10040c388		54000169		BLS 11(PC)										
  monolith.go:4232	0x10040c38c		bc297901		FMOVS F1, (R8)(R9<<2)									
  monolith.go:4232	0x10040c390		eb11017f		CMP R17, R11										
  monolith.go:4232	0x10040c394		540000c9		BLS 6(PC)										
  monolith.go:4232	0x10040c398		bc317900		FMOVS F0, (R8)(R17<<2)									
  monolith.go:4153	0x10040c39c		f94043e9		MOVD 128(RSP), R9									
  monolith.go:4157	0x10040c3a0		aa0f03f1		MOVD R15, R17										
  monolith.go:4235	0x10040c3a4		aa1503ef		MOVD R21, R15										
  monolith.go:4233	0x10040c3a8		17ffff47		JMP -185(PC)										
  monolith.go:4232	0x10040c3ac		aa1103e0		MOVD R17, R0										
  monolith.go:4232	0x10040c3b0		97f1f904		CALL runtime.panicBounds(SB)								
  monolith.go:4232	0x10040c3b4		97f1f903		CALL runtime.panicBounds(SB)								
  monolith.go:4206	0x10040c3b8		aa1103e1		MOVD R17, R1										
  monolith.go:4206	0x10040c3bc		97f1f901		CALL runtime.panicBounds(SB)								
  monolith.go:4206	0x10040c3c0		aa1703e1		MOVD R23, R1										
  monolith.go:4206	0x10040c3c4		97f1f8ff		CALL runtime.panicBounds(SB)								
  monolith.go:4206	0x10040c3c8		97f1f8fe		CALL runtime.panicBounds(SB)								
  monolith.go:4206	0x10040c3cc		aa1903e1		MOVD R25, R1										
  monolith.go:4206	0x10040c3d0		97f1f8fc		CALL runtime.panicBounds(SB)								
  monolith.go:4213	0x10040c3d4		1e2202ae		SCVTFWS R21, F14									
  monolith.go:4217	0x10040c3d8		bc677b4f		FMOVS (R26)(R7<<2), F15									
  monolith.go:4218	0x10040c3dc		bc6f7bd0		FMOVS (R30)(R15<<2), F16								
  monolith.go:4219	0x10040c3e0		bc697bd1		FMOVS (R30)(R9<<2), F17									
  monolith.go:4220	0x10040c3e4		bc737bd2		FMOVS (R30)(R19<<2), F18								
  monolith.go:4221	0x10040c3e8		bc677bd3		FMOVS (R30)(R7<<2), F19									
  monolith.go:4217	0x10040c3ec		1f0f21c8		FMADDS F15, F8, F14, F8									
  monolith.go:4218	0x10040c3f0		1f101966		FMADDS F16, F6, F11, F6									
  monolith.go:4219	0x10040c3f4		1f111d87		FMADDS F17, F7, F12, F7									
  monolith.go:4220	0x10040c3f8		1f1229aa		FMADDS F18, F10, F13, F10								
  monolith.go:4221	0x10040c3fc		1f1311c4		FMADDS F19, F4, F14, F4									
  monolith.go:4154	0x10040c400		f94053e2		MOVD 160(RSP), R2									
  monolith.go:4235	0x10040c404		f9405be6		MOVD 176(RSP), R6									
  monolith.go:4236	0x10040c408		f9403be7		MOVD 112(RSP), R7									
  monolith.go:4236	0x10040c40c		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4154	0x10040c410		f94073f3		MOVD 224(RSP), R19									
  monolith.go:4235	0x10040c414		f9406ff5		MOVD 216(RSP), R21									
  monolith.go:4212	0x10040c418		aa0303ef		MOVD R3, R15										
  monolith.go:4212	0x10040c41c		910011e3		ADD $4, R15, R3										
  monolith.go:4212	0x10040c420		eb03001f		CMP R3, R0										
  monolith.go:4212	0x10040c424		5400044b		BLT 34(PC)										
  monolith.go:4213	0x10040c428		eb0401ff		CMP R4, R15										
  monolith.go:4213	0x10040c42c		54000922		BCS 73(PC)										
  monolith.go:4213	0x10040c430		910005e9		ADD $1, R15, R9										
  monolith.go:4213	0x10040c434		38af6a82		MOVB (R20)(R15), R2									
  monolith.go:4213	0x10040c438		eb09009f		CMP R9, R4										
  monolith.go:4213	0x10040c43c		54000889		BLS 68(PC)										
  monolith.go:4213	0x10040c440		910009f3		ADD $2, R15, R19									
  monolith.go:4213	0x10040c444		38a96a8c		MOVB (R20)(R9), R12									
  monolith.go:4213	0x10040c448		eb13009f		CMP R19, R4										
  monolith.go:4213	0x10040c44c		540007c9		BLS 62(PC)										
  monolith.go:4213	0x10040c450		91000de7		ADD $3, R15, R7										
  monolith.go:4213	0x10040c454		38b36a86		MOVB (R20)(R19), R6									
  monolith.go:4213	0x10040c458		eb07009f		CMP R7, R4										
  monolith.go:4213	0x10040c45c		54000729		BLS 57(PC)										
  monolith.go:4213	0x10040c460		38a76a95		MOVB (R20)(R7), R21									
  monolith.go:4214	0x10040c464		eb1801ff		CMP R24, R15										
  monolith.go:4214	0x10040c468		54000682		BCS 52(PC)										
  monolith.go:4213	0x10040c46c		1e22004b		SCVTFWS R2, F11										
  monolith.go:4214	0x10040c470		bc6f7b4c		FMOVS (R26)(R15<<2), F12								
  monolith.go:4214	0x10040c474		1f0c0d63		FMADDS F12, F3, F11, F3									
  monolith.go:4215	0x10040c478		eb09031f		CMP R9, R24										
  monolith.go:4215	0x10040c47c		540005a9		BLS 45(PC)										
  monolith.go:4213	0x10040c480		1e22018c		SCVTFWS R12, F12									
  monolith.go:4215	0x10040c484		bc697b4d		FMOVS (R26)(R9<<2), F13									
  monolith.go:4215	0x10040c488		1f0d2589		FMADDS F13, F9, F12, F9									
  monolith.go:4216	0x10040c48c		eb13031f		CMP R19, R24										
  monolith.go:4216	0x10040c490		540004a9		BLS 37(PC)										
  monolith.go:4213	0x10040c494		1e2200cd		SCVTFWS R6, F13										
  monolith.go:4216	0x10040c498		bc737b4e		FMOVS (R26)(R19<<2), F14								
  monolith.go:4216	0x10040c49c		1f0e15a5		FMADDS F14, F5, F13, F5									
  monolith.go:4217	0x10040c4a0		eb07031f		CMP R7, R24										
  monolith.go:4217	0x10040c4a4		54fff988		BHI -52(PC)										
  monolith.go:4217	0x10040c4a8		1400001d		JMP 29(PC)										
  monolith.go:4223	0x10040c4ac		1e292863		FADDS F9, F3, F3									
  monolith.go:4223	0x10040c4b0		1e2828a5		FADDS F8, F5, F5									
  monolith.go:4223	0x10040c4b4		1e2728c6		FADDS F7, F6, F6									
  monolith.go:4223	0x10040c4b8		1e242944		FADDS F4, F10, F4									
  monolith.go:4223	0x10040c4bc		1e2328a3		FADDS F3, F5, F3									
  monolith.go:4223	0x10040c4c0		1e262884		FADDS F6, F4, F4									
  monolith.go:4224	0x10040c4c4		14000007		JMP 7(PC)										
  monolith.go:4225	0x10040c4c8		1e220065		SCVTFWS R3, F5										
  monolith.go:4226	0x10040c4cc		bc6f7b46		FMOVS (R26)(R15<<2), F6									
  monolith.go:4227	0x10040c4d0		bc6f7bc7		FMOVS (R30)(R15<<2), F7									
  monolith.go:4226	0x10040c4d4		1f060ca3		FMADDS F6, F3, F5, F3									
  monolith.go:4227	0x10040c4d8		1f0710a4		FMADDS F7, F4, F5, F4									
  monolith.go:4224	0x10040c4dc		910005ef		ADD $1, R15, R15									
  monolith.go:4224	0x10040c4e0		eb0001ff		CMP R0, R15										
  monolith.go:4224	0x10040c4e4		540000ea		BGE 7(PC)										
  monolith.go:4225	0x10040c4e8		eb0401ff		CMP R4, R15										
  monolith.go:4225	0x10040c4ec		54000162		BCS 11(PC)										
  monolith.go:4225	0x10040c4f0		38af6a83		MOVB (R20)(R15), R3									
  monolith.go:4226	0x10040c4f4		eb1801ff		CMP R24, R15										
  monolith.go:4226	0x10040c4f8		54fffe83		BCC -12(PC)										
  monolith.go:4226	0x10040c4fc		14000005		JMP 5(PC)										
  monolith.go:4229	0x10040c500		1f030443		FMADDS F3, F1, F2, F3									
  monolith.go:4230	0x10040c504		1f040041		FMADDS F4, F0, F2, F1									
  monolith.go:4203	0x10040c508		1e204060		FMOVS F3, F0										
  monolith.go:4230	0x10040c50c		17ffff51		JMP -175(PC)										
  monolith.go:4226	0x10040c510		aa1803e0		MOVD R24, R0										
  monolith.go:4226	0x10040c514		97f1f8ab		CALL runtime.panicBounds(SB)								
  monolith.go:4225	0x10040c518		97f1f8aa		CALL runtime.panicBounds(SB)								
  monolith.go:4217	0x10040c51c		aa1803e0		MOVD R24, R0										
  monolith.go:4217	0x10040c520		97f1f8a8		CALL runtime.panicBounds(SB)								
  monolith.go:4216	0x10040c524		aa1303e0		MOVD R19, R0										
  monolith.go:4216	0x10040c528		aa1803e1		MOVD R24, R1										
  monolith.go:4216	0x10040c52c		97f1f8a5		CALL runtime.panicBounds(SB)								
  monolith.go:4215	0x10040c530		aa1803e0		MOVD R24, R0										
  monolith.go:4215	0x10040c534		97f1f8a3		CALL runtime.panicBounds(SB)								
  monolith.go:4214	0x10040c538		aa1803e0		MOVD R24, R0										
  monolith.go:4214	0x10040c53c		97f1f8a1		CALL runtime.panicBounds(SB)								
  monolith.go:4213	0x10040c540		97f1f8a0		CALL runtime.panicBounds(SB)								
  monolith.go:4213	0x10040c544		aa1303e0		MOVD R19, R0										
  monolith.go:4213	0x10040c548		97f1f89e		CALL runtime.panicBounds(SB)								
  monolith.go:4213	0x10040c54c		97f1f89d		CALL runtime.panicBounds(SB)								
  monolith.go:4213	0x10040c550		97f1f89c		CALL runtime.panicBounds(SB)								
  monolith.go:4201	0x10040c554		aa1703e0		MOVD R23, R0										
  monolith.go:4201	0x10040c558		aa1e03e1		MOVD R30, R1										
  monolith.go:4201	0x10040c55c		97f1f899		CALL runtime.panicBounds(SB)								
  monolith.go:4201	0x10040c560		aa1e03e0		MOVD R30, R0										
  monolith.go:4201	0x10040c564		97f1f897		CALL runtime.panicBounds(SB)								
  monolith.go:4201	0x10040c568		d37ef700		LSL $2, R24, R0										
  monolith.go:4201	0x10040c56c		aa1703e1		MOVD R23, R1										
  monolith.go:4201	0x10040c570		97f1f894		CALL runtime.panicBounds(SB)								
  monolith.go:4201	0x10040c574		aa1703e0		MOVD R23, R0										
  monolith.go:4201	0x10040c578		97f1f892		CALL runtime.panicBounds(SB)								
  monolith.go:4191	0x10040c57c		1f060080		FMADDS F6, F0, F4, F0									
  monolith.go:4192	0x10040c580		1f070481		FMADDS F7, F1, F4, F1									
  monolith.go:4193	0x10040c584		1f050882		FMADDS F5, F2, F4, F2									
  monolith.go:4194	0x10040c588		1f080c83		FMADDS F8, F3, F4, F3									
  monolith.go:4152	0x10040c58c		f94047e0		MOVD 136(RSP), R0									
  monolith.go:4158	0x10040c590		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4161	0x10040c594		aa0103f6		MOVD R1, R22										
  monolith.go:4161	0x10040c598		eb0502df		CMP R5, R22										
  monolith.go:4161	0x10040c59c		5400114a		BGE 138(PC)										
  monolith.go:4161	0x10040c5a0		bd0037e3		FMOVS F3, 52(RSP)									
  monolith.go:4161	0x10040c5a4		bd003be2		FMOVS F2, 56(RSP)									
  monolith.go:4161	0x10040c5a8		bd0043e1		FMOVS F1, 64(RSP)									
  monolith.go:4161	0x10040c5ac		bd004be0		FMOVS F0, 72(RSP)									
  monolith.go:4163	0x10040c5b0		910006c1		ADD $1, R22, R1										
  monolith.go:4163	0x10040c5b4		d37ae420		LSL $6, R1, R0										
  monolith.go:4161	0x10040c5b8		bc767a04		FMOVS (R16)(R22<<2), F4									
  monolith.go:4161	0x10040c5bc		bd0033e4		FMOVS F4, 48(RSP)									
  monolith.go:4163	0x10040c5c0		d37ae6d6		LSL $6, R22, R22									
  monolith.go:4163	0x10040c5c4		eb01189f		CMP R1<<6, R4										
  monolith.go:4163	0x10040c5c8		9a80b080		CSEL LT, R4, R0, R0									
  monolith.go:4163	0x10040c5cc		1e2703e5		FMOVS ZR, F5										
  monolith.go:4163	0x10040c5d0		1e2703e6		FMOVS ZR, F6										
  monolith.go:4163	0x10040c5d4		1e2703e7		FMOVS ZR, F7										
  monolith.go:4163	0x10040c5d8		1e2703e8		FMOVS ZR, F8										
  monolith.go:4163	0x10040c5dc		1e2703e9		FMOVS ZR, F9										
  monolith.go:4163	0x10040c5e0		1e2703ea		FMOVS ZR, F10										
  monolith.go:4163	0x10040c5e4		1e2703eb		FMOVS ZR, F11										
  monolith.go:4163	0x10040c5e8		1e2703ec		FMOVS ZR, F12										
  monolith.go:4163	0x10040c5ec		1e2703ed		FMOVS ZR, F13										
  monolith.go:4163	0x10040c5f0		1e2703ee		FMOVS ZR, F14										
  monolith.go:4163	0x10040c5f4		1e2703ef		FMOVS ZR, F15										
  monolith.go:4163	0x10040c5f8		1e2703f0		FMOVS ZR, F16										
  monolith.go:4163	0x10040c5fc		1e2703f1		FMOVS ZR, F17										
  monolith.go:4163	0x10040c600		1e2703f2		FMOVS ZR, F18										
  monolith.go:4163	0x10040c604		1e2703f3		FMOVS ZR, F19										
  monolith.go:4163	0x10040c608		1e2703f4		FMOVS ZR, F20										
  monolith.go:4163	0x10040c60c		1400002b		JMP 43(PC)										
  monolith.go:4168	0x10040c610		bd004fe6		FMOVS F6, 76(RSP)									
  monolith.go:4165	0x10040c614		1e2203d8		SCVTFWS R30, F24									
  monolith.go:4169	0x10040c618		bc627b19		FMOVS (R24)(R2<<2), F25									
  monolith.go:4170	0x10040c61c		bc767aba		FMOVS (R21)(R22<<2), F26								
  monolith.go:4171	0x10040c620		bc677abb		FMOVS (R21)(R7<<2), F27									
  monolith.go:4172	0x10040c624		bc6f7abc		FMOVS (R21)(R15<<2), F28								
  monolith.go:4173	0x10040c628		bc627abd		FMOVS (R21)(R2<<2), F29									
  monolith.go:4174	0x10040c62c		bc767b5e		FMOVS (R26)(R22<<2), F30								
  monolith.go:4175	0x10040c630		bc677b5f		FMOVS (R26)(R7<<2), F31									
  monolith.go:4176	0x10040c634		bc6f7b43		FMOVS (R26)(R15<<2), F3									
  monolith.go:4177	0x10040c638		bc627b42		FMOVS (R26)(R2<<2), F2									
  monolith.go:4178	0x10040c63c		bc767921		FMOVS (R9)(R22<<2), F1									
  monolith.go:4179	0x10040c640		bc677920		FMOVS (R9)(R7<<2), F0									
  monolith.go:4180	0x10040c644		bc6f7924		FMOVS (R9)(R15<<2), F4									
  monolith.go:4181	0x10040c648		bc627926		FMOVS (R9)(R2<<2), F6									
  monolith.go:4169	0x10040c64c		1f195314		FMADDS F25, F20, F24, F20								
  monolith.go:4170	0x10040c650		1f1a26a9		FMADDS F26, F9, F21, F9									
  monolith.go:4171	0x10040c654		1f1b4ad2		FMADDS F27, F18, F22, F18								
  monolith.go:4172	0x10040c658		1f1c2aea		FMADDS F28, F10, F23, F10								
  monolith.go:4173	0x10040c65c		1f1d330c		FMADDS F29, F12, F24, F12								
  monolith.go:4174	0x10040c660		1f1e2eab		FMADDS F30, F11, F21, F11								
  monolith.go:4175	0x10040c664		1f1f16c5		FMADDS F31, F5, F22, F5									
  monolith.go:4176	0x10040c668		1f034ef3		FMADDS F3, F19, F23, F19								
  monolith.go:4177	0x10040c66c		1f02370d		FMADDS F2, F13, F24, F13								
  monolith.go:4178	0x10040c670		1f0146b1		FMADDS F1, F17, F21, F17								
  monolith.go:4179	0x10040c674		1f003ace		FMADDS F0, F14, F22, F14								
  monolith.go:4180	0x10040c678		1f0442f0		FMADDS F4, F16, F23, F16								
  monolith.go:4181	0x10040c67c		1f063f0f		FMADDS F6, F15, F24, F15								
  monolith.go:4154	0x10040c680		f94053e2		MOVD 160(RSP), R2									
  monolith.go:4155	0x10040c684		f9408fe3		MOVD 280(RSP), R3									
  monolith.go:4157	0x10040c688		f9405be6		MOVD 176(RSP), R6									
  monolith.go:4158	0x10040c68c		f9403be7		MOVD 112(RSP), R7									
  monolith.go:4157	0x10040c690		f9404bef		MOVD 144(RSP), R15									
  monolith.go:4154	0x10040c694		f94073f3		MOVD 224(RSP), R19									
  monolith.go:4197	0x10040c698		f9406ffe		MOVD 216(RSP), R30									
  monolith.go:4191	0x10040c69c		bd404be0		FMOVS 72(RSP), F0									
  monolith.go:4192	0x10040c6a0		bd4043e1		FMOVS 64(RSP), F1									
  monolith.go:4193	0x10040c6a4		bd403be2		FMOVS 56(RSP), F2									
  monolith.go:4194	0x10040c6a8		bd4037e3		FMOVS 52(RSP), F3									
  monolith.go:4191	0x10040c6ac		bd4033e4		FMOVS 48(RSP), F4									
  monolith.go:4164	0x10040c6b0		aa0c03f6		MOVD R12, R22										
  monolith.go:4164	0x10040c6b4		bd404fe6		FMOVS 76(RSP), F6									
  monolith.go:4164	0x10040c6b8		910012cc		ADD $4, R22, R12									
  monolith.go:4164	0x10040c6bc		eb0c001f		CMP R12, R0										
  monolith.go:4164	0x10040c6c0		5400044b		BLT 34(PC)										
  monolith.go:4165	0x10040c6c4		eb0402df		CMP R4, R22										
  monolith.go:4165	0x10040c6c8		54000d42		BCS 106(PC)										
  monolith.go:4165	0x10040c6cc		910006c7		ADD $1, R22, R7										
  monolith.go:4165	0x10040c6d0		38b66a86		MOVB (R20)(R22), R6									
  monolith.go:4165	0x10040c6d4		eb07009f		CMP R7, R4										
  monolith.go:4165	0x10040c6d8		54000ca9		BLS 101(PC)										
  monolith.go:4165	0x10040c6dc		91000acf		ADD $2, R22, R15									
  monolith.go:4165	0x10040c6e0		38a76a83		MOVB (R20)(R7), R3									
  monolith.go:4165	0x10040c6e4		eb0f009f		CMP R15, R4										
  monolith.go:4165	0x10040c6e8		54000c09		BLS 96(PC)										
  monolith.go:4165	0x10040c6ec		91000ec2		ADD $3, R22, R2										
  monolith.go:4165	0x10040c6f0		38af6a93		MOVB (R20)(R15), R19									
  monolith.go:4165	0x10040c6f4		eb02009f		CMP R2, R4										
  monolith.go:4165	0x10040c6f8		54000b69		BLS 91(PC)										
  monolith.go:4165	0x10040c6fc		38a26a9e		MOVB (R20)(R2), R30									
  monolith.go:4166	0x10040c700		eb1702df		CMP R23, R22										
  monolith.go:4166	0x10040c704		54000aa2		BCS 85(PC)										
  monolith.go:4165	0x10040c708		1e2200d5		SCVTFWS R6, F21										
  monolith.go:4166	0x10040c70c		bc767b16		FMOVS (R24)(R22<<2), F22								
  monolith.go:4166	0x10040c710		1f1622a8		FMADDS F22, F8, F21, F8									
  monolith.go:4167	0x10040c714		eb0702ff		CMP R7, R23										
  monolith.go:4167	0x10040c718		540009c9		BLS 78(PC)										
  monolith.go:4165	0x10040c71c		1e220076		SCVTFWS R3, F22										
  monolith.go:4167	0x10040c720		bc677b17		FMOVS (R24)(R7<<2), F23									
  monolith.go:4167	0x10040c724		1f171ec7		FMADDS F23, F7, F22, F7									
  monolith.go:4168	0x10040c728		eb0f02ff		CMP R15, R23										
  monolith.go:4168	0x10040c72c		540008e9		BLS 71(PC)										
  monolith.go:4165	0x10040c730		1e220277		SCVTFWS R19, F23									
  monolith.go:4168	0x10040c734		bc6f7b18		FMOVS (R24)(R15<<2), F24								
  monolith.go:4168	0x10040c738		1f181ae6		FMADDS F24, F6, F23, F6									
  monolith.go:4169	0x10040c73c		eb0202ff		CMP R2, R23										
  monolith.go:4169	0x10040c740		54fff688		BHI -76(PC)										
  monolith.go:4169	0x10040c744		1400003f		JMP 63(PC)										
  monolith.go:4183	0x10040c748		1e272907		FADDS F7, F8, F7									
  monolith.go:4183	0x10040c74c		1e3428c6		FADDS F20, F6, F6									
  monolith.go:4183	0x10040c750		1e322928		FADDS F18, F9, F8									
  monolith.go:4183	0x10040c754		1e2c2949		FADDS F12, F10, F9									
  monolith.go:4183	0x10040c758		1e252965		FADDS F5, F11, F5									
  monolith.go:4183	0x10040c75c		1e2d2a6a		FADDS F13, F19, F10									
  monolith.go:4183	0x10040c760		1e2e2a2b		FADDS F14, F17, F11									
  monolith.go:4183	0x10040c764		1e2f2a0c		FADDS F15, F16, F12									
  monolith.go:4183	0x10040c768		1e2728c6		FADDS F7, F6, F6									
  monolith.go:4183	0x10040c76c		1e282927		FADDS F8, F9, F7									
  monolith.go:4183	0x10040c770		1e252945		FADDS F5, F10, F5									
  monolith.go:4183	0x10040c774		1e2b2988		FADDS F11, F12, F8									
  monolith.go:4184	0x10040c778		1400000b		JMP 11(PC)										
  monolith.go:4185	0x10040c77c		1e220189		SCVTFWS R12, F9										
  monolith.go:4186	0x10040c780		bc767b0a		FMOVS (R24)(R22<<2), F10								
  monolith.go:4187	0x10040c784		bc767aab		FMOVS (R21)(R22<<2), F11								
  monolith.go:4188	0x10040c788		bc767b4c		FMOVS (R26)(R22<<2), F12								
  monolith.go:4189	0x10040c78c		bc76792d		FMOVS (R9)(R22<<2), F13									
  monolith.go:4186	0x10040c790		1f0a1926		FMADDS F10, F6, F9, F6									
  monolith.go:4187	0x10040c794		1f0b1d27		FMADDS F11, F7, F9, F7									
  monolith.go:4188	0x10040c798		1f0c1525		FMADDS F12, F5, F9, F5									
  monolith.go:4189	0x10040c79c		1f0d2128		FMADDS F13, F8, F9, F8									
  monolith.go:4184	0x10040c7a0		910006d6		ADD $1, R22, R22									
  monolith.go:4184	0x10040c7a4		eb0002df		CMP R0, R22										
  monolith.go:4184	0x10040c7a8		54ffeeaa		BGE -139(PC)										
  monolith.go:4185	0x10040c7ac		eb0402df		CMP R4, R22										
  monolith.go:4185	0x10040c7b0		54000442		BCS 34(PC)										
  monolith.go:4185	0x10040c7b4		38b66a8c		MOVB (R20)(R22), R12									
  monolith.go:4186	0x10040c7b8		eb1702df		CMP R23, R22										
  monolith.go:4186	0x10040c7bc		54fffe03		BCC -16(PC)										
  monolith.go:4186	0x10040c7c0		1400001b		JMP 27(PC)										
  monolith.go:4196	0x10040c7c4		9b0a7da9		MUL R10, R13, R9									
  monolith.go:4196	0x10040c7c8		8b0909c9		ADD R9<<2, R14, R9									
  monolith.go:4196	0x10040c7cc		9b0a3a30		MADD R10, R14, R17, R16									
  monolith.go:4196	0x10040c7d0		eb09017f		CMP R9, R11										
  monolith.go:4196	0x10040c7d4		540002a9		BLS 21(PC)										
  monolith.go:4196	0x10040c7d8		bc297900		FMOVS F0, (R8)(R9<<2)									
  monolith.go:4196	0x10040c7dc		eb10017f		CMP R16, R11										
  monolith.go:4196	0x10040c7e0		54000209		BLS 16(PC)										
  monolith.go:4196	0x10040c7e4		bc307901		FMOVS F1, (R8)(R16<<2)									
  monolith.go:4197	0x10040c7e8		9b0a3b29		MADD R10, R14, R25, R9									
  monolith.go:4197	0x10040c7ec		9b0a3bce		MADD R10, R14, R30, R14									
  monolith.go:4197	0x10040c7f0		eb09017f		CMP R9, R11										
  monolith.go:4197	0x10040c7f4		54000149		BLS 10(PC)										
  monolith.go:4197	0x10040c7f8		bc297902		FMOVS F2, (R8)(R9<<2)									
  monolith.go:4197	0x10040c7fc		eb0e017f		CMP R14, R11										
  monolith.go:4197	0x10040c800		540000c9		BLS 6(PC)										
  monolith.go:4197	0x10040c804		bc2e7903		FMOVS F3, (R8)(R14<<2)									
  monolith.go:4152	0x10040c808		f940a3e1		MOVD 320(RSP), R1									
  monolith.go:4153	0x10040c80c		f94043e9		MOVD 128(RSP), R9									
  monolith.go:4157	0x10040c810		aa0f03f1		MOVD R15, R17										
  monolith.go:4197	0x10040c814		17fffdb0		JMP -592(PC)										
  monolith.go:4197	0x10040c818		97f1f7ea		CALL runtime.panicBounds(SB)								
  monolith.go:4197	0x10040c81c		97f1f7e9		CALL runtime.panicBounds(SB)								
  monolith.go:4196	0x10040c820		aa1003e0		MOVD R16, R0										
  monolith.go:4196	0x10040c824		97f1f7e7		CALL runtime.panicBounds(SB)								
  monolith.go:4196	0x10040c828		97f1f7e6		CALL runtime.panicBounds(SB)								
  monolith.go:4186	0x10040c82c		aa1603e0		MOVD R22, R0										
  monolith.go:4186	0x10040c830		aa1703e1		MOVD R23, R1										
  monolith.go:4186	0x10040c834		97f1f7e3		CALL runtime.panicBounds(SB)								
  monolith.go:4185	0x10040c838		aa1603e0		MOVD R22, R0										
  monolith.go:4185	0x10040c83c		97f1f7e1		CALL runtime.panicBounds(SB)								
  monolith.go:4169	0x10040c840		aa1703e0		MOVD R23, R0										
  monolith.go:4169	0x10040c844		97f1f7df		CALL runtime.panicBounds(SB)								
  monolith.go:4168	0x10040c848		aa1703e0		MOVD R23, R0										
  monolith.go:4168	0x10040c84c		97f1f7dd		CALL runtime.panicBounds(SB)								
  monolith.go:4167	0x10040c850		aa1703e0		MOVD R23, R0										
  monolith.go:4167	0x10040c854		97f1f7db		CALL runtime.panicBounds(SB)								
  monolith.go:4166	0x10040c858		aa1603e0		MOVD R22, R0										
  monolith.go:4166	0x10040c85c		aa1703e1		MOVD R23, R1										
  monolith.go:4166	0x10040c860		97f1f7d8		CALL runtime.panicBounds(SB)								
  monolith.go:4165	0x10040c864		97f1f7d7		CALL runtime.panicBounds(SB)								
  monolith.go:4165	0x10040c868		97f1f7d6		CALL runtime.panicBounds(SB)								
  monolith.go:4165	0x10040c86c		97f1f7d5		CALL runtime.panicBounds(SB)								
  monolith.go:4165	0x10040c870		aa1603e0		MOVD R22, R0										
  monolith.go:4165	0x10040c874		97f1f7d3		CALL runtime.panicBounds(SB)								
  monolith.go:4159	0x10040c878		aa1603e0		MOVD R22, R0										
  monolith.go:4159	0x10040c87c		97f1f7d1		CALL runtime.panicBounds(SB)								
  monolith.go:4159	0x10040c880		aa1603e0		MOVD R22, R0										
  monolith.go:4159	0x10040c884		97f1f7cf		CALL runtime.panicBounds(SB)								
  monolith.go:4159	0x10040c888		aa1a03e0		MOVD R26, R0										
  monolith.go:4159	0x10040c88c		97f1f7cd		CALL runtime.panicBounds(SB)								
  monolith.go:4159	0x10040c890		97f1f7cc		CALL runtime.panicBounds(SB)								
  monolith.go:4158	0x10040c894		aa1503e0		MOVD R21, R0										
  monolith.go:4158	0x10040c898		aa1a03e1		MOVD R26, R1										
  monolith.go:4158	0x10040c89c		97f1f7c9		CALL runtime.panicBounds(SB)								
  monolith.go:4158	0x10040c8a0		aa1a03e0		MOVD R26, R0										
  monolith.go:4158	0x10040c8a4		97f1f7c7		CALL runtime.panicBounds(SB)								
  monolith.go:4158	0x10040c8a8		d37ef6e0		LSL $2, R23, R0										
  monolith.go:4158	0x10040c8ac		aa1503e1		MOVD R21, R1										
  monolith.go:4158	0x10040c8b0		97f1f7c4		CALL runtime.panicBounds(SB)								
  monolith.go:4158	0x10040c8b4		aa1503e0		MOVD R21, R0										
  monolith.go:4158	0x10040c8b8		97f1f7c2		CALL runtime.panicBounds(SB)								
  monolith.go:4156	0x10040c8bc		aa1503e0		MOVD R21, R0										
  monolith.go:4156	0x10040c8c0		aa1803e1		MOVD R24, R1										
  monolith.go:4156	0x10040c8c4		97f1f7bf		CALL runtime.panicBounds(SB)								
  monolith.go:4156	0x10040c8c8		aa1803e0		MOVD R24, R0										
  monolith.go:4156	0x10040c8cc		aa1703e1		MOVD R23, R1										
  monolith.go:4156	0x10040c8d0		97f1f7bc		CALL runtime.panicBounds(SB)								
  monolith.go:4155	0x10040c8d4		aa1503e0		MOVD R21, R0										
  monolith.go:4155	0x10040c8d8		aa1403e1		MOVD R20, R1										
  monolith.go:4155	0x10040c8dc		97f1f7b9		CALL runtime.panicBounds(SB)								
  monolith.go:4155	0x10040c8e0		aa1403e0		MOVD R20, R0										
  monolith.go:4155	0x10040c8e4		aa1103e1		MOVD R17, R1										
  monolith.go:4155	0x10040c8e8		97f1f7b6		CALL runtime.panicBounds(SB)								
  monolith.go:4153	0x10040c8ec		97f0e4fd		CALL runtime.panicdivide(SB)								
  monolith.go:4153	0x10040c8f0		d503201f		NOOP											
  monolith.go:4151	0x10040c8f4		a90087e0		STP (R0, R1), 8(RSP)									
  monolith.go:4151	0x10040c8f8		aa1e03e3		MOVD R30, R3										
  monolith.go:4151	0x10040c8fc		97f1ef4d		CALL runtime.morestack.abi0(SB)								
  monolith.go:4151	0x10040c900		a94087e0		LDP 8(RSP), (R0, R1)									
  monolith.go:4151	0x10040c904		17fffd4b		JMP github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.linearQ8Into.func1(SB)	
  monolith.go:4151	0x10040c908		00000000		?											
  monolith.go:4151	0x10040c90c		00000000		?											

TEXT github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.linearQ8Range(SB) /Users/ryohiga/SpiralReality/sr_go_transformer/cmd/monolith/monolith.go
  monolith.go:4174	0x1003360f0		f9400b90		MOVD 16(R28), R16									
  monolith.go:4174	0x1003360f4		d102c3f1		SUB $176, RSP, R17									
  monolith.go:4174	0x1003360f8		eb10023f		CMP R16, R17										
  monolith.go:4174	0x1003360fc		54005589		BLS 684(PC)										
  monolith.go:4174	0x100336100		d104c3f4		SUB $304, RSP, R20									
  monolith.go:4174	0x100336104		a93ffa9d		STP (R29, R30), -8(R20)									
  monolith.go:4174	0x100336108		9100029f		MOVD R20, RSP										
  monolith.go:4174	0x10033610c		d10023fd		SUB $8, RSP, R29									
  monolith.go:4177	0x100336110		f900a7e2		MOVD R2, 328(RSP)									
  monolith.go:4175	0x100336114		a9411003		LDP 16(R0), (R3, R4)									
  monolith.go:4175	0x100336118		f9007be4		MOVD R4, 240(RSP)									
  monolith.go:4175	0x10033611c		f9003be3		MOVD R3, 112(RSP)									
  monolith.go:4175	0x100336120		a9431805		LDP 48(R0), (R5, R6)									
  monolith.go:4175	0x100336124		f9008fe5		MOVD R5, 280(RSP)									
  monolith.go:4175	0x100336128		f9005be6		MOVD R6, 176(RSP)									
  monolith.go:4176	0x10033612c		a9442007		LDP 64(R0), (R7, R8)									
  monolith.go:4176	0x100336130		f9005fe7		MOVD R7, 184(RSP)									
  monolith.go:4176	0x100336134		f9004fe8		MOVD R8, 152(RSP)									
  monolith.go:4176	0x100336138		a9452809		LDP 80(R0), (R9, R10)									
  monolith.go:4176	0x10033613c		f90063e9		MOVD R9, 192(RSP)									
  monolith.go:4176	0x100336140		f90043ea		MOVD R10, 128(RSP)									
  monolith.go:4175	0x100336144		f940100b		MOVD 32(R0), R11									
  monolith.go:4175	0x100336148		f9002beb		MOVD R11, 80(RSP)									
  monolith.go:4175	0x10033614c		f940000c		MOVD (R0), R12										
  monolith.go:4175	0x100336150		f90087ec		MOVD R12, 264(RSP)									
  monolith.go:4177	0x100336154		14000002		JMP 2(PC)										
  monolith.go:4177	0x100336158		91000421		ADD $1, R1, R1										
  monolith.go:4177	0x10033615c		eb01005f		CMP R1, R2										
  monolith.go:4177	0x100336160		54001b2d		BLE 217(PC)										
  monolith.go:4178	0x100336164		b400520a		CBZ R10, 656(PC)									
  monolith.go:4177	0x100336168		f90047e1		MOVD R1, 136(RSP)									
  monolith.go:4178	0x10033616c		9aca0c2d		SDIV R10, R1, R13									
  monolith.go:4178	0x100336170		f90077ed		MOVD R13, 232(RSP)									
  monolith.go:4178	0x100336174		9aca0c3b		SDIV R10, R1, R27									
  monolith.go:4178	0x100336178		9b0a876e		MSUB R10, R1, R27, R14									
  monolith.go:4178	0x10033617c		d37ef5af		LSL $2, R13, R15									
  monolith.go:4178	0x100336180		f9004bef		MOVD R15, 144(RSP)									
  monolith.go:4178	0x100336184		d37be9ce		LSL $5, R14, R14									
  monolith.go:4178	0x100336188		f90053ee		MOVD R14, 160(RSP)									
  monolith.go:4178	0x10033618c		aa0e03e0		MOVD R14, R0										
  monolith.go:4179	0x100336190		14000003		JMP 3(PC)										
  monolith.go:4182	0x100336194		aa1103ef		MOVD R17, R15										
  monolith.go:4179	0x100336198		aa1303ee		MOVD R19, R14										
  monolith.go:4179	0x10033619c		91008010		ADD $32, R0, R16									
  monolith.go:4179	0x1003361a0		eb10011f		CMP R16, R8										
  monolith.go:4179	0x1003361a4		9a90b110		CSEL LT, R8, R16, R16									
  monolith.go:4179	0x1003361a8		eb1001df		CMP R16, R14										
  monolith.go:4179	0x1003361ac		54fffd6a		BGE -21(PC)										
  monolith.go:4180	0x1003361b0		f94044b0		MOVD 136(R5), R16									
  monolith.go:4180	0x1003361b4		f9400a11		MOVD 16(R16), R17									
  monolith.go:4180	0x1003361b8		910005d3		ADD $1, R14, R19									
  monolith.go:4180	0x1003361bc		9b077e74		MUL R7, R19, R20									
  monolith.go:4180	0x1003361c0		9b077dd5		MUL R7, R14, R21									
  monolith.go:4180	0x1003361c4		eb14023f		CMP R20, R17										
  monolith.go:4180	0x1003361c8		54004e83		BCC 628(PC)										
  monolith.go:4180	0x1003361cc		eb15029f		CMP R21, R20										
  monolith.go:4180	0x1003361d0		54004de3		BCC 623(PC)										
  monolith.go:4180	0x1003361d4		f9400214		MOVD (R16), R20										
  monolith.go:4180	0x1003361d8		cb1102b6		SUB R17, R21, R22									
  monolith.go:4180	0x1003361dc		8a96feb6		AND R22->63, R21, R22									
  monolith.go:4181	0x1003361e0		f9401617		MOVD 40(R16), R23									
  monolith.go:4181	0x1003361e4		9b097e78		MUL R9, R19, R24									
  monolith.go:4180	0x1003361e8		8b160294		ADD R22, R20, R20									
  monolith.go:4180	0x1003361ec		cb150231		SUB R21, R17, R17									
  monolith.go:4181	0x1003361f0		9b097dd5		MUL R9, R14, R21									
  monolith.go:4181	0x1003361f4		eb1802ff		CMP R24, R23										
  monolith.go:4181	0x1003361f8		54004c43		BCC 610(PC)										
  monolith.go:4181	0x1003361fc		eb15031f		CMP R21, R24										
  monolith.go:4181	0x100336200		54004ba3		BCC 605(PC)										
  monolith.go:4180	0x100336204		f90073f3		MOVD R19, 224(RSP)									
  monolith.go:4181	0x100336208		f9400e10		MOVD 24(R16), R16									
  monolith.go:4181	0x10033620c		cb1702b6		SUB R23, R21, R22									
  monolith.go:4181	0x100336210		8a96feb5		AND R22->63, R21, R21									
  monolith.go:4182	0x100336214		910011f6		ADD $4, R15, R22									
  monolith.go:4181	0x100336218		8b150a10		ADD R21<<2, R16, R16									
  monolith.go:4182	0x10033621c		eb1600df		CMP R22, R6										
  monolith.go:4182	0x100336220		540005cb		BLT 46(PC)										
  monolith.go:4183	0x100336224		910005f1		ADD $1, R15, R17									
  monolith.go:4183	0x100336228		9b117cf5		MUL R17, R7, R21									
  monolith.go:4183	0x10033622c		9b077db7		MUL R7, R13, R23									
  monolith.go:4183	0x100336230		eb15007f		CMP R21, R3										
  monolith.go:4183	0x100336234		540049c3		BCC 590(PC)										
  monolith.go:4183	0x100336238		eb170abf		CMP R23<<2, R21										
  monolith.go:4183	0x10033623c		54004923		BCC 585(PC)										
  monolith.go:4183	0x100336240		cb170878		SUB R23<<2, R3, R24									
  monolith.go:4183	0x100336244		cb1803f8		NEG R24, R24										
  monolith.go:4183	0x100336248		8a98fef8		AND R24->63, R23, R24									
  monolith.go:4183	0x10033624c		910009f9		ADD $2, R15, R25									
  monolith.go:4183	0x100336250		9b197cfa		MUL R25, R7, R26									
  monolith.go:4183	0x100336254		cb170ab7		SUB R23<<2, R21, R23									
  monolith.go:4183	0x100336258		8b181198		ADD R24<<4, R12, R24									
  monolith.go:4183	0x10033625c		eb1a007f		CMP R26, R3										
  monolith.go:4183	0x100336260		540047c3		BCC 574(PC)										
  monolith.go:4183	0x100336264		eb15035f		CMP R21, R26										
  monolith.go:4183	0x100336268		54004723		BCC 569(PC)										
  monolith.go:4183	0x10033626c		cb0302be		SUB R3, R21, R30									
  monolith.go:4183	0x100336270		8a9efeb5		AND R30->63, R21, R21									
  monolith.go:4184	0x100336274		91000dfe		ADD $3, R15, R30									
  monolith.go:4184	0x100336278		9b077fca		MUL R7, R30, R10									
  monolith.go:4183	0x10033627c		8b150995		ADD R21<<2, R12, R21									
  monolith.go:4184	0x100336280		eb0a007f		CMP R10, R3										
  monolith.go:4184	0x100336284		54004623		BCC 561(PC)										
  monolith.go:4184	0x100336288		eb1a015f		CMP R26, R10										
  monolith.go:4184	0x10033628c		540045a3		BCC 557(PC)										
  monolith.go:4184	0x100336290		cb030342		SUB R3, R26, R2										
  monolith.go:4184	0x100336294		8a82ff5a		AND R2->63, R26, R26									
  monolith.go:4184	0x100336298		9b077ed6		MUL R7, R22, R22									
  monolith.go:4184	0x10033629c		8b1a099a		ADD R26<<2, R12, R26									
  monolith.go:4184	0x1003362a0		eb16007f		CMP R22, R3										
  monolith.go:4184	0x1003362a4		540044a3		BCC 549(PC)										
  monolith.go:4184	0x1003362a8		eb0a02df		CMP R10, R22										
  monolith.go:4184	0x1003362ac		54004423		BCC 545(PC)										
  monolith.go:4184	0x1003362b0		f9006ffe		MOVD R30, 216(RSP)									
  monolith.go:4184	0x1003362b4		cb030156		SUB R3, R10, R22									
  monolith.go:4184	0x1003362b8		8a96fd4a		AND R22->63, R10, R10									
  monolith.go:4184	0x1003362bc		8b0a098a		ADD R10<<2, R12, R10									
  monolith.go:4186	0x1003362c0		aa1f03f6		MOVD ZR, R22										
  monolith.go:4186	0x1003362c4		1e2703e0		FMOVS ZR, F0										
  monolith.go:4186	0x1003362c8		1e2703e1		FMOVS ZR, F1										
  monolith.go:4186	0x1003362cc		1e2703e2		FMOVS ZR, F2										
  monolith.go:4186	0x1003362d0		1e2703e3		FMOVS ZR, F3										
  monolith.go:4186	0x1003362d4		14000160		JMP 352(PC)										
  monolith.go:4225	0x1003362d8		910009f5		ADD $2, R15, R21									
  monolith.go:4225	0x1003362dc		eb1500df		CMP R21, R6										
  monolith.go:4225	0x1003362e0		540004ab		BLT 37(PC)										
  monolith.go:4226	0x1003362e4		910005f6		ADD $1, R15, R22									
  monolith.go:4226	0x1003362e8		9b167cf7		MUL R22, R7, R23									
  monolith.go:4226	0x1003362ec		9b077db8		MUL R7, R13, R24									
  monolith.go:4226	0x1003362f0		eb17007f		CMP R23, R3										
  monolith.go:4226	0x1003362f4		540029e3		BCC 335(PC)										
  monolith.go:4226	0x1003362f8		eb180aff		CMP R24<<2, R23										
  monolith.go:4226	0x1003362fc		54002943		BCC 330(PC)										
  monolith.go:4226	0x100336300		cb180879		SUB R24<<2, R3, R25									
  monolith.go:4226	0x100336304		cb1903fa		NEG R25, R26										
  monolith.go:4226	0x100336308		8a9aff1a		AND R26->63, R24, R26									
  monolith.go:4226	0x10033630c		9b157cfe		MUL R21, R7, R30									
  monolith.go:4226	0x100336310		cb180af8		SUB R24<<2, R23, R24									
  monolith.go:4226	0x100336314		8b1a119a		ADD R26<<4, R12, R26									
  monolith.go:4226	0x100336318		eb1e007f		CMP R30, R3										
  monolith.go:4226	0x10033631c		54002803		BCC 320(PC)										
  monolith.go:4226	0x100336320		eb1703df		CMP R23, R30										
  monolith.go:4226	0x100336324		54002763		BCC 315(PC)										
  monolith.go:4180	0x100336328		f9003ff1		MOVD R17, 120(RSP)									
  monolith.go:4180	0x10033632c		f9008bf4		MOVD R20, 272(RSP)									
  monolith.go:4181	0x100336330		f90093f0		MOVD R16, 288(RSP)									
  monolith.go:4225	0x100336334		f9006ff5		MOVD R21, 216(RSP)									
  monolith.go:4226	0x100336338		f9006bf6		MOVD R22, 208(RSP)									
  monolith.go:4226	0x10033633c		f90033f8		MOVD R24, 96(RSP)									
  monolith.go:4226	0x100336340		f90037f9		MOVD R25, 104(RSP)									
  monolith.go:4226	0x100336344		f90083fa		MOVD R26, 256(RSP)									
  monolith.go:4179	0x100336348		f90057ee		MOVD R14, 168(RSP)									
  monolith.go:4226	0x10033634c		cb0302fe		SUB R3, R23, R30									
  monolith.go:4226	0x100336350		8a9efefe		AND R30->63, R23, R30									
  monolith.go:4226	0x100336354		8b1e099e		ADD R30<<2, R12, R30									
  monolith.go:4226	0x100336358		f9007ffe		MOVD R30, 248(RSP)									
  monolith.go:4226	0x10033635c		cb170077		SUB R23, R3, R23									
  monolith.go:4226	0x100336360		f9002ff7		MOVD R23, 88(RSP)									
  monolith.go:4228	0x100336364		aa1f03ea		MOVD ZR, R10										
  monolith.go:4228	0x100336368		1e2703e0		FMOVS ZR, F0										
  monolith.go:4228	0x10033636c		1e2703e1		FMOVS ZR, F1										
  monolith.go:4228	0x100336370		14000086		JMP 134(PC)										
  monolith.go:4178	0x100336374		aa0f03f1		MOVD R15, R17										
  monolith.go:4225	0x100336378		14000003		JMP 3(PC)										
  monolith.go:4278	0x10033637c		bc2f7880		FMOVS F0, (R4)(R15<<2)									
  monolith.go:4260	0x100336380		aa1503ef		MOVD R21, R15										
  monolith.go:4260	0x100336384		eb0601ff		CMP R6, R15										
  monolith.go:4260	0x100336388		54fff06a		BGE -125(PC)										
  monolith.go:4261	0x10033638c		910005f5		ADD $1, R15, R21									
  monolith.go:4261	0x100336390		9b077eb6		MUL R7, R21, R22									
  monolith.go:4261	0x100336394		9b077df7		MUL R7, R15, R23									
  monolith.go:4261	0x100336398		eb16007f		CMP R22, R3										
  monolith.go:4261	0x10033639c		54000b63		BCC 91(PC)										
  monolith.go:4261	0x1003363a0		eb1702df		CMP R23, R22										
  monolith.go:4261	0x1003363a4		54000ac3		BCC 86(PC)										
  monolith.go:4261	0x1003363a8		cb0302f6		SUB R3, R23, R22									
  monolith.go:4261	0x1003363ac		8a96fef6		AND R22->63, R23, R22									
  monolith.go:4261	0x1003363b0		8b160996		ADD R22<<2, R12, R22									
  monolith.go:4263	0x1003363b4		aa1f03f7		MOVD ZR, R23										
  monolith.go:4263	0x1003363b8		1e2703e0		FMOVS ZR, F0										
  monolith.go:4263	0x1003363bc		14000003		JMP 3(PC)										
  monolith.go:4276	0x1003363c0		1f020020		FMADDS F2, F0, F1, F0									
  monolith.go:4263	0x1003363c4		aa1803f7		MOVD R24, R23										
  monolith.go:4263	0x1003363c8		eb0902ff		CMP R9, R23										
  monolith.go:4263	0x1003363cc		5400074a		BGE 58(PC)										
  monolith.go:4264	0x1003363d0		910006f8		ADD $1, R23, R24									
  monolith.go:4264	0x1003363d4		d37ae719		LSL $6, R24, R25									
  monolith.go:4263	0x1003363d8		bc777a01		FMOVS (R16)(R23<<2), F1									
  monolith.go:4264	0x1003363dc		d37ae6f7		LSL $6, R23, R23									
  monolith.go:4264	0x1003363e0		eb1818ff		CMP R24<<6, R7										
  monolith.go:4264	0x1003363e4		9a99b0f9		CSEL LT, R7, R25, R25									
  monolith.go:4264	0x1003363e8		1e2703e2		FMOVS ZR, F2										
  monolith.go:4264	0x1003363ec		1e2703e3		FMOVS ZR, F3										
  monolith.go:4264	0x1003363f0		1e2703e4		FMOVS ZR, F4										
  monolith.go:4264	0x1003363f4		1e2703e5		FMOVS ZR, F5										
  monolith.go:4264	0x1003363f8		14000006		JMP 6(PC)										
  monolith.go:4270	0x1003363fc		bc777ac6		FMOVS (R22)(R23<<2), F6									
  monolith.go:4270	0x100336400		38b76a9e		MOVB (R20)(R23), R30									
  monolith.go:4270	0x100336404		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4270	0x100336408		1f070cc3		FMADDS F7, F3, F6, F3									
  monolith.go:4266	0x10033640c		aa1a03f7		MOVD R26, R23										
  monolith.go:4266	0x100336410		910012fa		ADD $4, R23, R26									
  monolith.go:4266	0x100336414		eb1a033f		CMP R26, R25										
  monolith.go:4266	0x100336418		5400032b		BLT 25(PC)										
  monolith.go:4267	0x10033641c		eb0702ff		CMP R7, R23										
  monolith.go:4267	0x100336420		540006a2		BCS 53(PC)										
  monolith.go:4267	0x100336424		bc777ac6		FMOVS (R22)(R23<<2), F6									
  monolith.go:4267	0x100336428		38b76a9e		MOVB (R20)(R23), R30									
  monolith.go:4267	0x10033642c		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4268	0x100336430		910006fe		ADD $1, R23, R30									
  monolith.go:4267	0x100336434		1f0710c4		FMADDS F7, F4, F6, F4									
  monolith.go:4268	0x100336438		eb1e00ff		CMP R30, R7										
  monolith.go:4268	0x10033643c		54000589		BLS 44(PC)										
  monolith.go:4268	0x100336440		bc7e7ac6		FMOVS (R22)(R30<<2), F6									
  monolith.go:4268	0x100336444		38be6a9e		MOVB (R20)(R30), R30									
  monolith.go:4268	0x100336448		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4269	0x10033644c		91000afe		ADD $2, R23, R30									
  monolith.go:4268	0x100336450		1f0714c5		FMADDS F7, F5, F6, F5									
  monolith.go:4269	0x100336454		eb1e00ff		CMP R30, R7										
  monolith.go:4269	0x100336458		54000469		BLS 35(PC)										
  monolith.go:4269	0x10033645c		bc7e7ac6		FMOVS (R22)(R30<<2), F6									
  monolith.go:4269	0x100336460		38be6a9e		MOVB (R20)(R30), R30									
  monolith.go:4269	0x100336464		1e2203c7		SCVTFWS R30, F7										
  monolith.go:4270	0x100336468		91000ef7		ADD $3, R23, R23									
  monolith.go:4269	0x10033646c		1f0708c2		FMADDS F7, F2, F6, F2									
  monolith.go:4270	0x100336470		eb1700ff		CMP R23, R7										
  monolith.go:4270	0x100336474		54fffc48		BHI -30(PC)										
  monolith.go:4270	0x100336478		14000019		JMP 25(PC)										
  monolith.go:4272	0x10033647c		1e252884		FADDS F5, F4, F4									
  monolith.go:4272	0x100336480		1e232842		FADDS F3, F2, F2									
  monolith.go:4272	0x100336484		1e222882		FADDS F2, F4, F2									
  monolith.go:4273	0x100336488		14000006		JMP 6(PC)										
  monolith.go:4274	0x10033648c		bc777ac3		FMOVS (R22)(R23<<2), F3									
  monolith.go:4274	0x100336490		38b76a9a		MOVB (R20)(R23), R26									
  monolith.go:4274	0x100336494		1e220344		SCVTFWS R26, F4										
  monolith.go:4274	0x100336498		1f040862		FMADDS F4, F2, F3, F2									
  monolith.go:4273	0x10033649c		910006f7		ADD $1, R23, R23									
  monolith.go:4273	0x1003364a0		eb1902ff		CMP R25, R23										
  monolith.go:4273	0x1003364a4		54fff8ea		BGE -57(PC)										
  monolith.go:4274	0x1003364a8		eb0702ff		CMP R7, R23										
  monolith.go:4274	0x1003364ac		54ffff03		BCC -8(PC)										
  monolith.go:4274	0x1003364b0		14000009		JMP 9(PC)										
  monolith.go:4278	0x1003364b4		9b0f390f		MADD R15, R14, R8, R15									
  monolith.go:4278	0x1003364b8		eb0f017f		CMP R15, R11										
  monolith.go:4278	0x1003364bc		54fff608		BHI -80(PC)										
  monolith.go:4278	0x1003364c0		14000004		JMP 4(PC)										
  monolith.go:4283	0x1003364c4		a97ffbfd		LDP -8(RSP), (R29, R30)									
  monolith.go:4283	0x1003364c8		9104c3ff		ADD $304, RSP, RSP									
  monolith.go:4283	0x1003364cc		d65f03c0		RET											
  monolith.go:4278	0x1003364d0		97f550bc		CALL runtime.panicBounds(SB)								
  monolith.go:4274	0x1003364d4		aa1703e0		MOVD R23, R0										
  monolith.go:4274	0x1003364d8		97f550ba		CALL runtime.panicBounds(SB)								
  monolith.go:4270	0x1003364dc		aa1703e0		MOVD R23, R0										
  monolith.go:4270	0x1003364e0		97f550b8		CALL runtime.panicBounds(SB)								
  monolith.go:4269	0x1003364e4		aa1e03e0		MOVD R30, R0										
  monolith.go:4269	0x1003364e8		97f550b6		CALL runtime.panicBounds(SB)								
  monolith.go:4268	0x1003364ec		aa1e03e0		MOVD R30, R0										
  monolith.go:4268	0x1003364f0		97f550b4		CALL runtime.panicBounds(SB)								
  monolith.go:4267	0x1003364f4		aa1703e0		MOVD R23, R0										
  monolith.go:4267	0x1003364f8		97f550b2		CALL runtime.panicBounds(SB)								
  monolith.go:4261	0x1003364fc		aa1703e0		MOVD R23, R0										
  monolith.go:4261	0x100336500		aa1603e1		MOVD R22, R1										
  monolith.go:4261	0x100336504		97f550af		CALL runtime.panicBounds(SB)								
  monolith.go:4261	0x100336508		aa1603e0		MOVD R22, R0										
  monolith.go:4261	0x10033650c		97f550ad		CALL runtime.panicBounds(SB)								
  monolith.go:4179	0x100336510		f94053e0		MOVD 160(RSP), R0									
  monolith.go:4177	0x100336514		f94047e1		MOVD 136(RSP), R1									
  monolith.go:4177	0x100336518		f940a7e2		MOVD 328(RSP), R2									
  monolith.go:4261	0x10033651c		f9403be3		MOVD 112(RSP), R3									
  monolith.go:4257	0x100336520		f9407be4		MOVD 240(RSP), R4									
  monolith.go:4180	0x100336524		f9408fe5		MOVD 280(RSP), R5									
  monolith.go:4260	0x100336528		f9405be6		MOVD 176(RSP), R6									
  monolith.go:4229	0x10033652c		f9405fe7		MOVD 184(RSP), R7									
  monolith.go:4257	0x100336530		f9404fe8		MOVD 152(RSP), R8									
  monolith.go:4228	0x100336534		f94063e9		MOVD 192(RSP), R9									
  monolith.go:4257	0x100336538		f9402beb		MOVD 80(RSP), R11									
  monolith.go:4261	0x10033653c		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4257	0x100336540		f94077ed		MOVD 232(RSP), R13									
  monolith.go:4257	0x100336544		f94057ee		MOVD 168(RSP), R14									
  monolith.go:4182	0x100336548		f9404bef		MOVD 144(RSP), R15									
  monolith.go:4228	0x10033654c		f94093f0		MOVD 288(RSP), R16									
  monolith.go:4231	0x100336550		f9403ff1		MOVD 120(RSP), R17									
  monolith.go:4179	0x100336554		f94073f3		MOVD 224(RSP), R19									
  monolith.go:4238	0x100336558		f9408bf4		MOVD 272(RSP), R20									
  monolith.go:4260	0x10033655c		f9406ff5		MOVD 216(RSP), R21									
  monolith.go:4257	0x100336560		f9406bf6		MOVD 208(RSP), R22									
  monolith.go:4231	0x100336564		f9402ff7		MOVD 88(RSP), R23									
  monolith.go:4239	0x100336568		f94033f8		MOVD 96(RSP), R24									
  monolith.go:4231	0x10033656c		f94037f9		MOVD 104(RSP), R25									
  monolith.go:4239	0x100336570		f94083fa		MOVD 256(RSP), R26									
  monolith.go:4243	0x100336574		f9407ffe		MOVD 248(RSP), R30									
  monolith.go:4228	0x100336578		f94067ea		MOVD 200(RSP), R10									
  monolith.go:4228	0x10033657c		1e204002		FMOVS F0, F2										
  monolith.go:4228	0x100336580		1e204020		FMOVS F1, F0										
  monolith.go:4228	0x100336584		1e204041		FMOVS F2, F1										
  monolith.go:4228	0x100336588		eb09015f		CMP R9, R10										
  monolith.go:4228	0x10033658c		5400056a		BGE 43(PC)										
  monolith.go:4229	0x100336590		91000542		ADD $1, R10, R2										
  monolith.go:4229	0x100336594		f90067e2		MOVD R2, 200(RSP)									
  monolith.go:4229	0x100336598		d37ae441		LSL $6, R2, R1										
  monolith.go:4228	0x10033659c		bc6a7a02		FMOVS (R16)(R10<<2), F2									
  monolith.go:4229	0x1003365a0		d37ae54f		LSL $6, R10, R15									
  monolith.go:4229	0x1003365a4		eb0218ff		CMP R2<<6, R7										
  monolith.go:4229	0x1003365a8		9a81b0e1		CSEL LT, R7, R1, R1									
  monolith.go:4230	0x1003365ac		cb0a1825		SUB R10<<6, R1, R5									
  monolith.go:4230	0x1003365b0		f10100bf		CMP $64, R5										
  monolith.go:4229	0x1003365b4		54000140		BEQ 10(PC)										
  monolith.go:4230	0x1003365b8		1e2703e3		FMOVS ZR, F3										
  monolith.go:4230	0x1003365bc		1e2703e4		FMOVS ZR, F4										
  monolith.go:4230	0x1003365c0		1e2703e5		FMOVS ZR, F5										
  monolith.go:4230	0x1003365c4		1e2703e6		FMOVS ZR, F6										
  monolith.go:4230	0x1003365c8		1e2703e7		FMOVS ZR, F7										
  monolith.go:4230	0x1003365cc		1e2703e8		FMOVS ZR, F8										
  monolith.go:4230	0x1003365d0		1e2703e9		FMOVS ZR, F9										
  monolith.go:4230	0x1003365d4		1e2703ea		FMOVS ZR, F10										
  monolith.go:4230	0x1003365d8		14000040		JMP 64(PC)										
  monolith.go:4231	0x1003365dc		eb19003f		CMP R25, R1										
  monolith.go:4231	0x1003365e0		54000548		BHI 42(PC)										
  monolith.go:4231	0x1003365e4		eb0a183f		CMP R10<<6, R1										
  monolith.go:4231	0x1003365e8		540004e3		BCC 39(PC)										
  monolith.go:4231	0x1003365ec		8b0a2345		ADD R10<<8, R26, R5									
  monolith.go:4231	0x1003365f0		eb17003f		CMP R23, R1										
  monolith.go:4231	0x1003365f4		54000448		BHI 34(PC)										
  monolith.go:4231	0x1003365f8		8b0a23cf		ADD R10<<8, R30, R15									
  monolith.go:4231	0x1003365fc		eb11003f		CMP R17, R1										
  monolith.go:4231	0x100336600		540003a8		BHI 29(PC)										
  monolith.go:4228	0x100336604		bd002fe2		FMOVS F2, 44(RSP)									
  monolith.go:4228	0x100336608		bd003fe0		FMOVS F0, 60(RSP)									
  monolith.go:4228	0x10033660c		bd0047e1		FMOVS F1, 68(RSP)									
  monolith.go:4231	0x100336610		8b0a1a82		ADD R10<<6, R20, R2									
  monolith.go:4231	0x100336614		aa0503e0		MOVD R5, R0										
  monolith.go:4231	0x100336618		aa0f03e1		MOVD R15, R1										
  monolith.go:4231	0x10033661c		9400016d		CALL github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.dotQ8PairBlock64(SB)	
  monolith.go:4232	0x100336620		bd4047e2		FMOVS 68(RSP), F2									
  monolith.go:4232	0x100336624		bd402fe3		FMOVS 44(RSP), F3									
  monolith.go:4232	0x100336628		1f000860		FMADDS F0, F2, F3, F0									
  monolith.go:4233	0x10033662c		bd403fe2		FMOVS 60(RSP), F2									
  monolith.go:4233	0x100336630		1f010861		FMADDS F1, F2, F3, F1									
  monolith.go:4234	0x100336634		17ffffb7		JMP -73(PC)										
  monolith.go:4257	0x100336638		9b087daa		MUL R8, R13, R10									
  monolith.go:4257	0x10033663c		8b0a09ca		ADD R10<<2, R14, R10									
  monolith.go:4257	0x100336640		eb0a017f		CMP R10, R11										
  monolith.go:4257	0x100336644		54000169		BLS 11(PC)										
  monolith.go:4257	0x100336648		bc2a7881		FMOVS F1, (R4)(R10<<2)									
  monolith.go:4257	0x10033664c		9b083aca		MADD R8, R14, R22, R10									
  monolith.go:4257	0x100336650		eb0a017f		CMP R10, R11										
  monolith.go:4257	0x100336654		540000c9		BLS 6(PC)										
  monolith.go:4257	0x100336658		bc2a7880		FMOVS F0, (R4)(R10<<2)									
  monolith.go:4178	0x10033665c		f94043ea		MOVD 128(RSP), R10									
  monolith.go:4182	0x100336660		aa0f03f1		MOVD R15, R17										
  monolith.go:4260	0x100336664		aa1503ef		MOVD R21, R15										
  monolith.go:4258	0x100336668		17ffff47		JMP -185(PC)										
  monolith.go:4257	0x10033666c		97f55055		CALL runtime.panicBounds(SB)								
  monolith.go:4257	0x100336670		97f55054		CALL runtime.panicBounds(SB)								
  monolith.go:4231	0x100336674		aa1103e0		MOVD R17, R0										
  monolith.go:4231	0x100336678		97f55052		CALL runtime.panicBounds(SB)								
  monolith.go:4231	0x10033667c		aa1703e0		MOVD R23, R0										
  monolith.go:4231	0x100336680		97f55050		CALL runtime.panicBounds(SB)								
  monolith.go:4231	0x100336684		97f5504f		CALL runtime.panicBounds(SB)								
  monolith.go:4231	0x100336688		aa1903e0		MOVD R25, R0										
  monolith.go:4231	0x10033668c		97f5504d		CALL runtime.panicBounds(SB)								
  monolith.go:4238	0x100336690		1e2202ae		SCVTFWS R21, F14									
  monolith.go:4242	0x100336694		bc637b4f		FMOVS (R26)(R3<<2), F15									
  monolith.go:4243	0x100336698		bc6f7bd0		FMOVS (R30)(R15<<2), F16								
  monolith.go:4244	0x10033669c		bc6a7bd1		FMOVS (R30)(R10<<2), F17								
  monolith.go:4245	0x1003366a0		bc737bd2		FMOVS (R30)(R19<<2), F18								
  monolith.go:4246	0x1003366a4		bc637bd3		FMOVS (R30)(R3<<2), F19									
  monolith.go:4242	0x1003366a8		1f0f15c5		FMADDS F15, F5, F14, F5									
  monolith.go:4243	0x1003366ac		1f101d67		FMADDS F16, F7, F11, F7									
  monolith.go:4244	0x1003366b0		1f112188		FMADDS F17, F8, F12, F8									
  monolith.go:4245	0x1003366b4		1f1229aa		FMADDS F18, F10, F13, F10								
  monolith.go:4246	0x1003366b8		1f1311c4		FMADDS F19, F4, F14, F4									
  monolith.go:4179	0x1003366bc		f94053e0		MOVD 160(RSP), R0									
  monolith.go:4261	0x1003366c0		f9403be3		MOVD 112(RSP), R3									
  monolith.go:4260	0x1003366c4		f9405be6		MOVD 176(RSP), R6									
  monolith.go:4261	0x1003366c8		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4179	0x1003366cc		f94073f3		MOVD 224(RSP), R19									
  monolith.go:4260	0x1003366d0		f9406ff5		MOVD 216(RSP), R21									
  monolith.go:4237	0x1003366d4		aa0503ef		MOVD R5, R15										
  monolith.go:4237	0x1003366d8		910011e5		ADD $4, R15, R5										
  monolith.go:4237	0x1003366dc		eb05003f		CMP R5, R1										
  monolith.go:4237	0x1003366e0		5400044b		BLT 34(PC)										
  monolith.go:4238	0x1003366e4		eb0701ff		CMP R7, R15										
  monolith.go:4238	0x1003366e8		54000922		BCS 73(PC)										
  monolith.go:4238	0x1003366ec		910005ea		ADD $1, R15, R10									
  monolith.go:4238	0x1003366f0		38af6a80		MOVB (R20)(R15), R0									
  monolith.go:4238	0x1003366f4		eb0a00ff		CMP R10, R7										
  monolith.go:4238	0x1003366f8		54000889		BLS 68(PC)										
  monolith.go:4238	0x1003366fc		910009f3		ADD $2, R15, R19									
  monolith.go:4238	0x100336700		38aa6a8c		MOVB (R20)(R10), R12									
  monolith.go:4238	0x100336704		eb1300ff		CMP R19, R7										
  monolith.go:4238	0x100336708		540007c9		BLS 62(PC)										
  monolith.go:4238	0x10033670c		91000de3		ADD $3, R15, R3										
  monolith.go:4238	0x100336710		38b36a86		MOVB (R20)(R19), R6									
  monolith.go:4238	0x100336714		eb0300ff		CMP R3, R7										
  monolith.go:4238	0x100336718		54000729		BLS 57(PC)										
  monolith.go:4238	0x10033671c		38a36a95		MOVB (R20)(R3), R21									
  monolith.go:4239	0x100336720		eb1801ff		CMP R24, R15										
  monolith.go:4239	0x100336724		54000682		BCS 52(PC)										
  monolith.go:4238	0x100336728		1e22000b		SCVTFWS R0, F11										
  monolith.go:4239	0x10033672c		bc6f7b4c		FMOVS (R26)(R15<<2), F12								
  monolith.go:4239	0x100336730		1f0c0d63		FMADDS F12, F3, F11, F3									
  monolith.go:4240	0x100336734		eb0a031f		CMP R10, R24										
  monolith.go:4240	0x100336738		540005a9		BLS 45(PC)										
  monolith.go:4238	0x10033673c		1e22018c		SCVTFWS R12, F12									
  monolith.go:4240	0x100336740		bc6a7b4d		FMOVS (R26)(R10<<2), F13								
  monolith.go:4240	0x100336744		1f0d2589		FMADDS F13, F9, F12, F9									
  monolith.go:4241	0x100336748		eb13031f		CMP R19, R24										
  monolith.go:4241	0x10033674c		540004a9		BLS 37(PC)										
  monolith.go:4238	0x100336750		1e2200cd		SCVTFWS R6, F13										
  monolith.go:4241	0x100336754		bc737b4e		FMOVS (R26)(R19<<2), F14								
  monolith.go:4241	0x100336758		1f0e19a6		FMADDS F14, F6, F13, F6									
  monolith.go:4242	0x10033675c		eb03031f		CMP R3, R24										
  monolith.go:4242	0x100336760		54fff988		BHI -52(PC)										
  monolith.go:4242	0x100336764		1400001d		JMP 29(PC)										
  monolith.go:4248	0x100336768		1e292863		FADDS F9, F3, F3									
  monolith.go:4248	0x10033676c		1e2528c5		FADDS F5, F6, F5									
  monolith.go:4248	0x100336770		1e2828e6		FADDS F8, F7, F6									
  monolith.go:4248	0x100336774		1e242944		FADDS F4, F10, F4									
  monolith.go:4248	0x100336778		1e2328a3		FADDS F3, F5, F3									
  monolith.go:4248	0x10033677c		1e262884		FADDS F6, F4, F4									
  monolith.go:4249	0x100336780		14000007		JMP 7(PC)										
  monolith.go:4250	0x100336784		1e2200a5		SCVTFWS R5, F5										
  monolith.go:4251	0x100336788		bc6f7b46		FMOVS (R26)(R15<<2), F6									
  monolith.go:4252	0x10033678c		bc6f7bc7		FMOVS (R30)(R15<<2), F7									
  monolith.go:4251	0x100336790		1f060ca3		FMADDS F6, F3, F5, F3									
  monolith.go:4252	0x100336794		1f0710a4		FMADDS F7, F4, F5, F4									
  monolith.go:4249	0x100336798		910005ef		ADD $1, R15, R15									
  monolith.go:4249	0x10033679c		eb0101ff		CMP R1, R15										
  monolith.go:4249	0x1003367a0		540000ea		BGE 7(PC)										
  monolith.go:4250	0x1003367a4		eb0701ff		CMP R7, R15										
  monolith.go:4250	0x1003367a8		54000162		BCS 11(PC)										
  monolith.go:4250	0x1003367ac		38af6a85		MOVB (R20)(R15), R5									
  monolith.go:4251	0x1003367b0		eb1801ff		CMP R24, R15										
  monolith.go:4251	0x1003367b4		54fffe83		BCC -12(PC)										
  monolith.go:4251	0x1003367b8		14000005		JMP 5(PC)										
  monolith.go:4254	0x1003367bc		1f030443		FMADDS F3, F1, F2, F3									
  monolith.go:4255	0x1003367c0		1f040041		FMADDS F4, F0, F2, F1									
  monolith.go:4228	0x1003367c4		1e204060		FMOVS F3, F0										
  monolith.go:4255	0x1003367c8		17ffff52		JMP -174(PC)										
  monolith.go:4251	0x1003367cc		aa1803e0		MOVD R24, R0										
  monolith.go:4251	0x1003367d0		97f54ffc		CALL runtime.panicBounds(SB)								
  monolith.go:4250	0x1003367d4		97f54ffb		CALL runtime.panicBounds(SB)								
  monolith.go:4242	0x1003367d8		aa1803e0		MOVD R24, R0										
  monolith.go:4242	0x1003367dc		97f54ff9		CALL runtime.panicBounds(SB)								
  monolith.go:4241	0x1003367e0		aa1303e0		MOVD R19, R0										
  monolith.go:4241	0x1003367e4		aa1803e1		MOVD R24, R1										
  monolith.go:4241	0x1003367e8		97f54ff6		CALL runtime.panicBounds(SB)								
  monolith.go:4240	0x1003367ec		aa1803e0		MOVD R24, R0										
  monolith.go:4240	0x1003367f0		97f54ff4		CALL runtime.panicBounds(SB)								
  monolith.go:4239	0x1003367f4		aa1803e0		MOVD R24, R0										
  monolith.go:4239	0x1003367f8		97f54ff2		CALL runtime.panicBounds(SB)								
  monolith.go:4238	0x1003367fc		97f54ff1		CALL runtime.panicBounds(SB)								
  monolith.go:4238	0x100336800		aa1303e0		MOVD R19, R0										
  monolith.go:4238	0x100336804		97f54fef		CALL runtime.panicBounds(SB)								
  monolith.go:4238	0x100336808		97f54fee		CALL runtime.panicBounds(SB)								
  monolith.go:4238	0x10033680c		97f54fed		CALL runtime.panicBounds(SB)								
  monolith.go:4226	0x100336810		aa1703e0		MOVD R23, R0										
  monolith.go:4226	0x100336814		aa1e03e1		MOVD R30, R1										
  monolith.go:4226	0x100336818		97f54fea		CALL runtime.panicBounds(SB)								
  monolith.go:4226	0x10033681c		aa1e03e0		MOVD R30, R0										
  monolith.go:4226	0x100336820		97f54fe8		CALL runtime.panicBounds(SB)								
  monolith.go:4226	0x100336824		d37ef700		LSL $2, R24, R0										
  monolith.go:4226	0x100336828		aa1703e1		MOVD R23, R1										
  monolith.go:4226	0x10033682c		97f54fe5		CALL runtime.panicBounds(SB)								
  monolith.go:4226	0x100336830		aa1703e0		MOVD R23, R0										
  monolith.go:4226	0x100336834		97f54fe3		CALL runtime.panicBounds(SB)								
  monolith.go:4216	0x100336838		1f060080		FMADDS F6, F0, F4, F0									
  monolith.go:4217	0x10033683c		1f070481		FMADDS F7, F1, F4, F1									
  monolith.go:4218	0x100336840		1f050882		FMADDS F5, F2, F4, F2									
  monolith.go:4219	0x100336844		1f080c83		FMADDS F8, F3, F4, F3									
  monolith.go:4177	0x100336848		f94047e1		MOVD 136(RSP), R1									
  monolith.go:4183	0x10033684c		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4186	0x100336850		aa0203f6		MOVD R2, R22										
  monolith.go:4186	0x100336854		eb0902df		CMP R9, R22										
  monolith.go:4186	0x100336858		5400114a		BGE 138(PC)										
  monolith.go:4186	0x10033685c		bd0037e3		FMOVS F3, 52(RSP)									
  monolith.go:4186	0x100336860		bd003be2		FMOVS F2, 56(RSP)									
  monolith.go:4186	0x100336864		bd0043e1		FMOVS F1, 64(RSP)									
  monolith.go:4186	0x100336868		bd004be0		FMOVS F0, 72(RSP)									
  monolith.go:4188	0x10033686c		910006c2		ADD $1, R22, R2										
  monolith.go:4188	0x100336870		d37ae441		LSL $6, R2, R1										
  monolith.go:4186	0x100336874		bc767a04		FMOVS (R16)(R22<<2), F4									
  monolith.go:4186	0x100336878		bd0033e4		FMOVS F4, 48(RSP)									
  monolith.go:4188	0x10033687c		d37ae6d6		LSL $6, R22, R22									
  monolith.go:4188	0x100336880		eb0218ff		CMP R2<<6, R7										
  monolith.go:4188	0x100336884		9a81b0e1		CSEL LT, R7, R1, R1									
  monolith.go:4188	0x100336888		1e2703e5		FMOVS ZR, F5										
  monolith.go:4188	0x10033688c		1e2703e6		FMOVS ZR, F6										
  monolith.go:4188	0x100336890		1e2703e7		FMOVS ZR, F7										
  monolith.go:4188	0x100336894		1e2703e8		FMOVS ZR, F8										
  monolith.go:4188	0x100336898		1e2703e9		FMOVS ZR, F9										
  monolith.go:4188	0x10033689c		1e2703ea		FMOVS ZR, F10										
  monolith.go:4188	0x1003368a0		1e2703eb		FMOVS ZR, F11										
  monolith.go:4188	0x1003368a4		1e2703ec		FMOVS ZR, F12										
  monolith.go:4188	0x1003368a8		1e2703ed		FMOVS ZR, F13										
  monolith.go:4188	0x1003368ac		1e2703ee		FMOVS ZR, F14										
  monolith.go:4188	0x1003368b0		1e2703ef		FMOVS ZR, F15										
  monolith.go:4188	0x1003368b4		1e2703f0		FMOVS ZR, F16										
  monolith.go:4188	0x1003368b8		1e2703f1		FMOVS ZR, F17										
  monolith.go:4188	0x1003368bc		1e2703f2		FMOVS ZR, F18										
  monolith.go:4188	0x1003368c0		1e2703f3		FMOVS ZR, F19										
  monolith.go:4188	0x1003368c4		1e2703f4		FMOVS ZR, F20										
  monolith.go:4188	0x1003368c8		1400002b		JMP 43(PC)										
  monolith.go:4193	0x1003368cc		bd004fe6		FMOVS F6, 76(RSP)									
  monolith.go:4190	0x1003368d0		1e2203d8		SCVTFWS R30, F24									
  monolith.go:4194	0x1003368d4		bc607b19		FMOVS (R24)(R0<<2), F25									
  monolith.go:4195	0x1003368d8		bc767aba		FMOVS (R21)(R22<<2), F26								
  monolith.go:4196	0x1003368dc		bc637abb		FMOVS (R21)(R3<<2), F27									
  monolith.go:4197	0x1003368e0		bc6f7abc		FMOVS (R21)(R15<<2), F28								
  monolith.go:4198	0x1003368e4		bc607abd		FMOVS (R21)(R0<<2), F29									
  monolith.go:4199	0x1003368e8		bc767b5e		FMOVS (R26)(R22<<2), F30								
  monolith.go:4200	0x1003368ec		bc637b5f		FMOVS (R26)(R3<<2), F31									
  monolith.go:4201	0x1003368f0		bc6f7b43		FMOVS (R26)(R15<<2), F3									
  monolith.go:4202	0x1003368f4		bc607b42		FMOVS (R26)(R0<<2), F2									
  monolith.go:4203	0x1003368f8		bc767941		FMOVS (R10)(R22<<2), F1									
  monolith.go:4204	0x1003368fc		bc637940		FMOVS (R10)(R3<<2), F0									
  monolith.go:4205	0x100336900		bc6f7944		FMOVS (R10)(R15<<2), F4									
  monolith.go:4206	0x100336904		bc607946		FMOVS (R10)(R0<<2), F6									
  monolith.go:4194	0x100336908		1f195314		FMADDS F25, F20, F24, F20								
  monolith.go:4195	0x10033690c		1f1a26a9		FMADDS F26, F9, F21, F9									
  monolith.go:4196	0x100336910		1f1b3ace		FMADDS F27, F14, F22, F14								
  monolith.go:4197	0x100336914		1f1c2aea		FMADDS F28, F10, F23, F10								
  monolith.go:4198	0x100336918		1f1d370d		FMADDS F29, F13, F24, F13								
  monolith.go:4199	0x10033691c		1f1e2eab		FMADDS F30, F11, F21, F11								
  monolith.go:4200	0x100336920		1f1f16c5		FMADDS F31, F5, F22, F5									
  monolith.go:4201	0x100336924		1f034ef3		FMADDS F3, F19, F23, F19								
  monolith.go:4202	0x100336928		1f023f0f		FMADDS F2, F15, F24, F15								
  monolith.go:4203	0x10033692c		1f0132ac		FMADDS F1, F12, F21, F12								
  monolith.go:4204	0x100336930		1f0042d0		FMADDS F0, F16, F22, F16								
  monolith.go:4205	0x100336934		1f044af2		FMADDS F4, F18, F23, F18								
  monolith.go:4206	0x100336938		1f064711		FMADDS F6, F17, F24, F17								
  monolith.go:4179	0x10033693c		f94053e0		MOVD 160(RSP), R0									
  monolith.go:4183	0x100336940		f9403be3		MOVD 112(RSP), R3									
  monolith.go:4180	0x100336944		f9408fe5		MOVD 280(RSP), R5									
  monolith.go:4182	0x100336948		f9405be6		MOVD 176(RSP), R6									
  monolith.go:4182	0x10033694c		f9404bef		MOVD 144(RSP), R15									
  monolith.go:4179	0x100336950		f94073f3		MOVD 224(RSP), R19									
  monolith.go:4222	0x100336954		f9406ffe		MOVD 216(RSP), R30									
  monolith.go:4216	0x100336958		bd404be0		FMOVS 72(RSP), F0									
  monolith.go:4217	0x10033695c		bd4043e1		FMOVS 64(RSP), F1									
  monolith.go:4218	0x100336960		bd403be2		FMOVS 56(RSP), F2									
  monolith.go:4219	0x100336964		bd4037e3		FMOVS 52(RSP), F3									
  monolith.go:4216	0x100336968		bd4033e4		FMOVS 48(RSP), F4									
  monolith.go:4189	0x10033696c		aa0c03f6		MOVD R12, R22										
  monolith.go:4189	0x100336970		bd404fe6		FMOVS 76(RSP), F6									
  monolith.go:4189	0x100336974		910012cc		ADD $4, R22, R12									
  monolith.go:4189	0x100336978		eb0c003f		CMP R12, R1										
  monolith.go:4189	0x10033697c		5400044b		BLT 34(PC)										
  monolith.go:4190	0x100336980		eb0702df		CMP R7, R22										
  monolith.go:4190	0x100336984		54000d22		BCS 105(PC)										
  monolith.go:4190	0x100336988		910006c3		ADD $1, R22, R3										
  monolith.go:4190	0x10033698c		38b66a86		MOVB (R20)(R22), R6									
  monolith.go:4190	0x100336990		eb0300ff		CMP R3, R7										
  monolith.go:4190	0x100336994		54000c89		BLS 100(PC)										
  monolith.go:4190	0x100336998		91000acf		ADD $2, R22, R15									
  monolith.go:4190	0x10033699c		38a36a85		MOVB (R20)(R3), R5									
  monolith.go:4190	0x1003369a0		eb0f00ff		CMP R15, R7										
  monolith.go:4190	0x1003369a4		54000be9		BLS 95(PC)										
  monolith.go:4190	0x1003369a8		91000ec0		ADD $3, R22, R0										
  monolith.go:4190	0x1003369ac		38af6a93		MOVB (R20)(R15), R19									
  monolith.go:4190	0x1003369b0		eb0000ff		CMP R0, R7										
  monolith.go:4190	0x1003369b4		54000b49		BLS 90(PC)										
  monolith.go:4190	0x1003369b8		38a06a9e		MOVB (R20)(R0), R30									
  monolith.go:4191	0x1003369bc		eb1702df		CMP R23, R22										
  monolith.go:4191	0x1003369c0		54000a82		BCS 84(PC)										
  monolith.go:4190	0x1003369c4		1e2200d5		SCVTFWS R6, F21										
  monolith.go:4191	0x1003369c8		bc767b16		FMOVS (R24)(R22<<2), F22								
  monolith.go:4191	0x1003369cc		1f1622a8		FMADDS F22, F8, F21, F8									
  monolith.go:4192	0x1003369d0		eb0302ff		CMP R3, R23										
  monolith.go:4192	0x1003369d4		540009a9		BLS 77(PC)										
  monolith.go:4190	0x1003369d8		1e2200b6		SCVTFWS R5, F22										
  monolith.go:4192	0x1003369dc		bc637b17		FMOVS (R24)(R3<<2), F23									
  monolith.go:4192	0x1003369e0		1f171ec7		FMADDS F23, F7, F22, F7									
  monolith.go:4193	0x1003369e4		eb0f02ff		CMP R15, R23										
  monolith.go:4193	0x1003369e8		540008c9		BLS 70(PC)										
  monolith.go:4190	0x1003369ec		1e220277		SCVTFWS R19, F23									
  monolith.go:4193	0x1003369f0		bc6f7b18		FMOVS (R24)(R15<<2), F24								
  monolith.go:4193	0x1003369f4		1f181ae6		FMADDS F24, F6, F23, F6									
  monolith.go:4194	0x1003369f8		eb0002ff		CMP R0, R23										
  monolith.go:4194	0x1003369fc		54fff688		BHI -76(PC)										
  monolith.go:4194	0x100336a00		1400003e		JMP 62(PC)										
  monolith.go:4208	0x100336a04		1e272907		FADDS F7, F8, F7									
  monolith.go:4208	0x100336a08		1e3428c6		FADDS F20, F6, F6									
  monolith.go:4208	0x100336a0c		1e2e2928		FADDS F14, F9, F8									
  monolith.go:4208	0x100336a10		1e2d2949		FADDS F13, F10, F9									
  monolith.go:4208	0x100336a14		1e252965		FADDS F5, F11, F5									
  monolith.go:4208	0x100336a18		1e2f2a6a		FADDS F15, F19, F10									
  monolith.go:4208	0x100336a1c		1e30298b		FADDS F16, F12, F11									
  monolith.go:4208	0x100336a20		1e312a4c		FADDS F17, F18, F12									
  monolith.go:4208	0x100336a24		1e2728c6		FADDS F7, F6, F6									
  monolith.go:4208	0x100336a28		1e282927		FADDS F8, F9, F7									
  monolith.go:4208	0x100336a2c		1e252945		FADDS F5, F10, F5									
  monolith.go:4208	0x100336a30		1e2b2988		FADDS F11, F12, F8									
  monolith.go:4209	0x100336a34		1400000b		JMP 11(PC)										
  monolith.go:4210	0x100336a38		1e220189		SCVTFWS R12, F9										
  monolith.go:4211	0x100336a3c		bc767b0a		FMOVS (R24)(R22<<2), F10								
  monolith.go:4212	0x100336a40		bc767aab		FMOVS (R21)(R22<<2), F11								
  monolith.go:4213	0x100336a44		bc767b4c		FMOVS (R26)(R22<<2), F12								
  monolith.go:4214	0x100336a48		bc76794d		FMOVS (R10)(R22<<2), F13								
  monolith.go:4211	0x100336a4c		1f0a1926		FMADDS F10, F6, F9, F6									
  monolith.go:4212	0x100336a50		1f0b1d27		FMADDS F11, F7, F9, F7									
  monolith.go:4213	0x100336a54		1f0c1525		FMADDS F12, F5, F9, F5									
  monolith.go:4214	0x100336a58		1f0d2128		FMADDS F13, F8, F9, F8									
  monolith.go:4209	0x100336a5c		910006d6		ADD $1, R22, R22									
  monolith.go:4209	0x100336a60		eb0102df		CMP R1, R22										
  monolith.go:4209	0x100336a64		54ffeeaa		BGE -139(PC)										
  monolith.go:4210	0x100336a68		eb0702df		CMP R7, R22										
  monolith.go:4210	0x100336a6c		54000422		BCS 33(PC)										
  monolith.go:4210	0x100336a70		38b66a8c		MOVB (R20)(R22), R12									
  monolith.go:4211	0x100336a74		eb1702df		CMP R23, R22										
  monolith.go:4211	0x100336a78		54fffe03		BCC -16(PC)										
  monolith.go:4211	0x100336a7c		1400001a		JMP 26(PC)										
  monolith.go:4221	0x100336a80		9b087daa		MUL R8, R13, R10									
  monolith.go:4221	0x100336a84		8b0a09ca		ADD R10<<2, R14, R10									
  monolith.go:4221	0x100336a88		eb0a017f		CMP R10, R11										
  monolith.go:4221	0x100336a8c		540002a9		BLS 21(PC)										
  monolith.go:4221	0x100336a90		bc2a7880		FMOVS F0, (R4)(R10<<2)									
  monolith.go:4221	0x100336a94		9b083a2a		MADD R8, R14, R17, R10									
  monolith.go:4221	0x100336a98		eb0a017f		CMP R10, R11										
  monolith.go:4221	0x100336a9c		54000209		BLS 16(PC)										
  monolith.go:4221	0x100336aa0		bc2a7881		FMOVS F1, (R4)(R10<<2)									
  monolith.go:4222	0x100336aa4		9b083b2a		MADD R8, R14, R25, R10									
  monolith.go:4222	0x100336aa8		eb0a017f		CMP R10, R11										
  monolith.go:4222	0x100336aac		54000169		BLS 11(PC)										
  monolith.go:4222	0x100336ab0		bc2a7882		FMOVS F2, (R4)(R10<<2)									
  monolith.go:4222	0x100336ab4		9b083bca		MADD R8, R14, R30, R10									
  monolith.go:4222	0x100336ab8		eb0a017f		CMP R10, R11										
  monolith.go:4222	0x100336abc		540000c9		BLS 6(PC)										
  monolith.go:4222	0x100336ac0		bc2a7883		FMOVS F3, (R4)(R10<<2)									
  monolith.go:4177	0x100336ac4		f940a7e2		MOVD 328(RSP), R2									
  monolith.go:4178	0x100336ac8		f94043ea		MOVD 128(RSP), R10									
  monolith.go:4182	0x100336acc		aa0f03f1		MOVD R15, R17										
  monolith.go:4222	0x100336ad0		17fffdb1		JMP -591(PC)										
  monolith.go:4222	0x100336ad4		97f54f3b		CALL runtime.panicBounds(SB)								
  monolith.go:4222	0x100336ad8		97f54f3a		CALL runtime.panicBounds(SB)								
  monolith.go:4221	0x100336adc		97f54f39		CALL runtime.panicBounds(SB)								
  monolith.go:4221	0x100336ae0		97f54f38		CALL runtime.panicBounds(SB)								
  monolith.go:4211	0x100336ae4		aa1603e0		MOVD R22, R0										
  monolith.go:4211	0x100336ae8		aa1703e1		MOVD R23, R1										
  monolith.go:4211	0x100336aec		97f54f35		CALL runtime.panicBounds(SB)								
  monolith.go:4210	0x100336af0		aa1603e0		MOVD R22, R0										
  monolith.go:4210	0x100336af4		97f54f33		CALL runtime.panicBounds(SB)								
  monolith.go:4194	0x100336af8		aa1703e1		MOVD R23, R1										
  monolith.go:4194	0x100336afc		97f54f31		CALL runtime.panicBounds(SB)								
  monolith.go:4193	0x100336b00		aa1703e0		MOVD R23, R0										
  monolith.go:4193	0x100336b04		97f54f2f		CALL runtime.panicBounds(SB)								
  monolith.go:4192	0x100336b08		aa1703e0		MOVD R23, R0										
  monolith.go:4192	0x100336b0c		97f54f2d		CALL runtime.panicBounds(SB)								
  monolith.go:4191	0x100336b10		aa1603e0		MOVD R22, R0										
  monolith.go:4191	0x100336b14		aa1703e1		MOVD R23, R1										
  monolith.go:4191	0x100336b18		97f54f2a		CALL runtime.panicBounds(SB)								
  monolith.go:4190	0x100336b1c		97f54f29		CALL runtime.panicBounds(SB)								
  monolith.go:4190	0x100336b20		97f54f28		CALL runtime.panicBounds(SB)								
  monolith.go:4190	0x100336b24		97f54f27		CALL runtime.panicBounds(SB)								
  monolith.go:4190	0x100336b28		aa1603e0		MOVD R22, R0										
  monolith.go:4190	0x100336b2c		97f54f25		CALL runtime.panicBounds(SB)								
  monolith.go:4184	0x100336b30		aa1603e0		MOVD R22, R0										
  monolith.go:4184	0x100336b34		97f54f23		CALL runtime.panicBounds(SB)								
  monolith.go:4184	0x100336b38		aa1603e0		MOVD R22, R0										
  monolith.go:4184	0x100336b3c		97f54f21		CALL runtime.panicBounds(SB)								
  monolith.go:4184	0x100336b40		aa1a03e0		MOVD R26, R0										
  monolith.go:4184	0x100336b44		97f54f1f		CALL runtime.panicBounds(SB)								
  monolith.go:4184	0x100336b48		97f54f1e		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336b4c		aa1503e0		MOVD R21, R0										
  monolith.go:4183	0x100336b50		aa1a03e1		MOVD R26, R1										
  monolith.go:4183	0x100336b54		97f54f1b		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336b58		aa1a03e0		MOVD R26, R0										
  monolith.go:4183	0x100336b5c		97f54f19		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336b60		d37ef6e0		LSL $2, R23, R0										
  monolith.go:4183	0x100336b64		aa1503e1		MOVD R21, R1										
  monolith.go:4183	0x100336b68		97f54f16		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336b6c		aa1503e0		MOVD R21, R0										
  monolith.go:4183	0x100336b70		97f54f14		CALL runtime.panicBounds(SB)								
  monolith.go:4181	0x100336b74		aa1503e0		MOVD R21, R0										
  monolith.go:4181	0x100336b78		aa1803e1		MOVD R24, R1										
  monolith.go:4181	0x100336b7c		97f54f11		CALL runtime.panicBounds(SB)								
  monolith.go:4181	0x100336b80		aa1803e0		MOVD R24, R0										
  monolith.go:4181	0x100336b84		aa1703e1		MOVD R23, R1										
  monolith.go:4181	0x100336b88		97f54f0e		CALL runtime.panicBounds(SB)								
  monolith.go:4180	0x100336b8c		aa1503e0		MOVD R21, R0										
  monolith.go:4180	0x100336b90		aa1403e1		MOVD R20, R1										
  monolith.go:4180	0x100336b94		97f54f0b		CALL runtime.panicBounds(SB)								
  monolith.go:4180	0x100336b98		aa1403e0		MOVD R20, R0										
  monolith.go:4180	0x100336b9c		aa1103e1		MOVD R17, R1										
  monolith.go:4180	0x100336ba0		97f54f08		CALL runtime.panicBounds(SB)								
  monolith.go:4178	0x100336ba4		97f43c4f		CALL runtime.panicdivide(SB)								
  monolith.go:4178	0x100336ba8		d503201f		NOOP											
  monolith.go:4174	0x100336bac		a90087e0		STP (R0, R1), 8(RSP)									
  monolith.go:4174	0x100336bb0		f9000fe2		MOVD R2, 24(RSP)									
  monolith.go:4174	0x100336bb4		aa1e03e3		MOVD R30, R3										
  monolith.go:4174	0x100336bb8		97f546be		CALL runtime.morestack_noctxt.abi0(SB)							
  monolith.go:4174	0x100336bbc		a94087e0		LDP 8(RSP), (R0, R1)									
  monolith.go:4174	0x100336bc0		f9400fe2		MOVD 24(RSP), R2									
  monolith.go:4174	0x100336bc4		17fffd4b		JMP github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.linearQ8Range(SB)	
  monolith.go:4174	0x100336bc8		00000000		?											
  monolith.go:4174	0x100336bcc		00000000		?											

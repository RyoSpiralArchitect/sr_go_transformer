TEXT github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.linearQ8Range(SB) /Users/ryohiga/SpiralReality/sr_go_transformer/cmd/monolith/monolith.go
  monolith.go:4172	0x100336060		f9400b90		MOVD 16(R28), R16									
  monolith.go:4172	0x100336064		d102c3f1		SUB $176, RSP, R17									
  monolith.go:4172	0x100336068		eb10023f		CMP R16, R17										
  monolith.go:4172	0x10033606c		54005609		BLS 688(PC)										
  monolith.go:4172	0x100336070		d104c3f4		SUB $304, RSP, R20									
  monolith.go:4172	0x100336074		a93ffa9d		STP (R29, R30), -8(R20)									
  monolith.go:4172	0x100336078		9100029f		MOVD R20, RSP										
  monolith.go:4172	0x10033607c		d10023fd		SUB $8, RSP, R29									
  monolith.go:4176	0x100336080		f900a7e2		MOVD R2, 328(RSP)									
  monolith.go:4173	0x100336084		a9411003		LDP 16(R0), (R3, R4)									
  monolith.go:4173	0x100336088		f9007be4		MOVD R4, 240(RSP)									
  monolith.go:4173	0x10033608c		f90037e3		MOVD R3, 104(RSP)									
  monolith.go:4173	0x100336090		a9431805		LDP 48(R0), (R5, R6)									
  monolith.go:4173	0x100336094		f9008fe5		MOVD R5, 280(RSP)									
  monolith.go:4173	0x100336098		f90057e6		MOVD R6, 168(RSP)									
  monolith.go:4174	0x10033609c		a94120a7		LDP 16(R5), (R7, R8)									
  monolith.go:4174	0x1003360a0		f9005be8		MOVD R8, 176(RSP)									
  monolith.go:4174	0x1003360a4		f9004be7		MOVD R7, 144(RSP)									
  monolith.go:4175	0x1003360a8		9100fd09		ADD $63, R8, R9										
  monolith.go:4175	0x1003360ac		937ffd29		ASR $63, R9, R9										
  monolith.go:4175	0x1003360b0		8b49e909		ADD R9>>58, R8, R9									
  monolith.go:4175	0x1003360b4		9100fd29		ADD $63, R9, R9										
  monolith.go:4175	0x1003360b8		f90077e9		MOVD R9, 232(RSP)									
  monolith.go:4175	0x1003360bc		91007cea		ADD $31, R7, R10									
  monolith.go:4175	0x1003360c0		937ffd4a		ASR $63, R10, R10									
  monolith.go:4175	0x1003360c4		8b4aecea		ADD R10>>59, R7, R10									
  monolith.go:4175	0x1003360c8		91007d4a		ADD $31, R10, R10									
  monolith.go:4173	0x1003360cc		f940100b		MOVD 32(R0), R11									
  monolith.go:4173	0x1003360d0		f90027eb		MOVD R11, 72(RSP)									
  monolith.go:4173	0x1003360d4		f940000c		MOVD (R0), R12										
  monolith.go:4173	0x1003360d8		f90087ec		MOVD R12, 264(RSP)									
  monolith.go:4175	0x1003360dc		9346fd2d		ASR $6, R9, R13										
  monolith.go:4175	0x1003360e0		f9005fed		MOVD R13, 184(RSP)									
  monolith.go:4175	0x1003360e4		9345fd4a		ASR $5, R10, R10									
  monolith.go:4175	0x1003360e8		f9003fea		MOVD R10, 120(RSP)									
  monolith.go:4176	0x1003360ec		14000002		JMP 2(PC)										
  monolith.go:4176	0x1003360f0		91000421		ADD $1, R1, R1										
  monolith.go:4176	0x1003360f4		eb01005f		CMP R1, R2										
  monolith.go:4176	0x1003360f8		54001b6d		BLE 219(PC)										
  monolith.go:4177	0x1003360fc		b400514a		CBZ R10, 650(PC)									
  monolith.go:4176	0x100336100		f90043e1		MOVD R1, 128(RSP)									
  monolith.go:4177	0x100336104		9aca0c2e		SDIV R10, R1, R14									
  monolith.go:4177	0x100336108		f90073ee		MOVD R14, 224(RSP)									
  monolith.go:4177	0x10033610c		9aca0c3b		SDIV R10, R1, R27									
  monolith.go:4177	0x100336110		9b0a876f		MSUB R10, R1, R27, R15									
  monolith.go:4177	0x100336114		d37ef5d0		LSL $2, R14, R16									
  monolith.go:4177	0x100336118		f90047f0		MOVD R16, 136(RSP)									
  monolith.go:4177	0x10033611c		d37be9ef		LSL $5, R15, R15									
  monolith.go:4177	0x100336120		f9004fef		MOVD R15, 152(RSP)									
  monolith.go:4177	0x100336124		aa0f03e0		MOVD R15, R0										
  monolith.go:4178	0x100336128		14000003		JMP 3(PC)										
  monolith.go:4181	0x10033612c		aa1303f0		MOVD R19, R16										
  monolith.go:4178	0x100336130		aa1403ef		MOVD R20, R15										
  monolith.go:4178	0x100336134		91008011		ADD $32, R0, R17									
  monolith.go:4178	0x100336138		eb1100ff		CMP R17, R7										
  monolith.go:4178	0x10033613c		9a91b0f1		CSEL LT, R7, R17, R17									
  monolith.go:4178	0x100336140		eb1101ff		CMP R17, R15										
  monolith.go:4178	0x100336144		54fffd6a		BGE -21(PC)										
  monolith.go:4179	0x100336148		f94044b1		MOVD 136(R5), R17									
  monolith.go:4179	0x10033614c		f9400a33		MOVD 16(R17), R19									
  monolith.go:4179	0x100336150		910005f4		ADD $1, R15, R20									
  monolith.go:4179	0x100336154		9b087e95		MUL R8, R20, R21									
  monolith.go:4179	0x100336158		9b087df6		MUL R8, R15, R22									
  monolith.go:4179	0x10033615c		eb15027f		CMP R21, R19										
  monolith.go:4179	0x100336160		54004dc3		BCC 622(PC)										
  monolith.go:4179	0x100336164		eb1602bf		CMP R22, R21										
  monolith.go:4179	0x100336168		54004d23		BCC 617(PC)										
  monolith.go:4179	0x10033616c		f9400235		MOVD (R17), R21										
  monolith.go:4179	0x100336170		cb1302d7		SUB R19, R22, R23									
  monolith.go:4179	0x100336174		8a97fed7		AND R23->63, R22, R23									
  monolith.go:4180	0x100336178		f9401638		MOVD 40(R17), R24									
  monolith.go:4180	0x10033617c		9b0d7e99		MUL R13, R20, R25									
  monolith.go:4179	0x100336180		8b1702b5		ADD R23, R21, R21									
  monolith.go:4179	0x100336184		cb160273		SUB R22, R19, R19									
  monolith.go:4180	0x100336188		9b0d7df6		MUL R13, R15, R22									
  monolith.go:4180	0x10033618c		eb19031f		CMP R25, R24										
  monolith.go:4180	0x100336190		54004b83		BCC 604(PC)										
  monolith.go:4180	0x100336194		eb16033f		CMP R22, R25										
  monolith.go:4180	0x100336198		54004ae3		BCC 599(PC)										
  monolith.go:4179	0x10033619c		f9006ff4		MOVD R20, 216(RSP)									
  monolith.go:4180	0x1003361a0		f9400e31		MOVD 24(R17), R17									
  monolith.go:4180	0x1003361a4		cb1802d7		SUB R24, R22, R23									
  monolith.go:4180	0x1003361a8		8a97fed6		AND R23->63, R22, R22									
  monolith.go:4181	0x1003361ac		91001217		ADD $4, R16, R23									
  monolith.go:4180	0x1003361b0		8b160a31		ADD R22<<2, R17, R17									
  monolith.go:4181	0x1003361b4		eb1700df		CMP R23, R6										
  monolith.go:4181	0x1003361b8		540005eb		BLT 47(PC)										
  monolith.go:4182	0x1003361bc		91000613		ADD $1, R16, R19									
  monolith.go:4182	0x1003361c0		9b137d16		MUL R19, R8, R22									
  monolith.go:4182	0x1003361c4		9b087dd8		MUL R8, R14, R24									
  monolith.go:4182	0x1003361c8		eb16007f		CMP R22, R3										
  monolith.go:4182	0x1003361cc		54004903		BCC 584(PC)										
  monolith.go:4182	0x1003361d0		eb180adf		CMP R24<<2, R22										
  monolith.go:4182	0x1003361d4		54004863		BCC 579(PC)										
  monolith.go:4182	0x1003361d8		cb180879		SUB R24<<2, R3, R25									
  monolith.go:4182	0x1003361dc		cb1903f9		NEG R25, R25										
  monolith.go:4182	0x1003361e0		8a99ff19		AND R25->63, R24, R25									
  monolith.go:4182	0x1003361e4		91000a1a		ADD $2, R16, R26									
  monolith.go:4182	0x1003361e8		9b1a7d1e		MUL R26, R8, R30									
  monolith.go:4182	0x1003361ec		cb180ad8		SUB R24<<2, R22, R24									
  monolith.go:4182	0x1003361f0		8b191199		ADD R25<<4, R12, R25									
  monolith.go:4182	0x1003361f4		eb1e007f		CMP R30, R3										
  monolith.go:4182	0x1003361f8		54004703		BCC 568(PC)										
  monolith.go:4182	0x1003361fc		eb1603df		CMP R22, R30										
  monolith.go:4182	0x100336200		54004663		BCC 563(PC)										
  monolith.go:4182	0x100336204		cb0302ca		SUB R3, R22, R10									
  monolith.go:4182	0x100336208		8a8afeca		AND R10->63, R22, R10									
  monolith.go:4183	0x10033620c		91000e16		ADD $3, R16, R22									
  monolith.go:4183	0x100336210		9b087ec2		MUL R8, R22, R2										
  monolith.go:4182	0x100336214		8b0a098a		ADD R10<<2, R12, R10									
  monolith.go:4183	0x100336218		eb02007f		CMP R2, R3										
  monolith.go:4183	0x10033621c		54004563		BCC 555(PC)										
  monolith.go:4183	0x100336220		eb1e005f		CMP R30, R2										
  monolith.go:4183	0x100336224		540044e3		BCC 551(PC)										
  monolith.go:4183	0x100336228		cb0303c1		SUB R3, R30, R1										
  monolith.go:4183	0x10033622c		8a81ffde		AND R1->63, R30, R30									
  monolith.go:4183	0x100336230		9b087ef7		MUL R8, R23, R23									
  monolith.go:4183	0x100336234		8b1e099e		ADD R30<<2, R12, R30									
  monolith.go:4183	0x100336238		eb17007f		CMP R23, R3										
  monolith.go:4183	0x10033623c		540043e3		BCC 543(PC)										
  monolith.go:4183	0x100336240		eb0202ff		CMP R2, R23										
  monolith.go:4183	0x100336244		54004363		BCC 539(PC)										
  monolith.go:4183	0x100336248		f9006bf6		MOVD R22, 208(RSP)									
  monolith.go:4183	0x10033624c		cb030057		SUB R3, R2, R23										
  monolith.go:4183	0x100336250		8a97fc57		AND R23->63, R2, R23									
  monolith.go:4183	0x100336254		8b170997		ADD R23<<2, R12, R23									
  monolith.go:4173	0x100336258		aa0c03e1		MOVD R12, R1										
  monolith.go:4185	0x10033625c		aa1f03ec		MOVD ZR, R12										
  monolith.go:4185	0x100336260		1e2703e0		FMOVS ZR, F0										
  monolith.go:4185	0x100336264		1e2703e1		FMOVS ZR, F1										
  monolith.go:4185	0x100336268		1e2703e2		FMOVS ZR, F2										
  monolith.go:4185	0x10033626c		1e2703e3		FMOVS ZR, F3										
  monolith.go:4185	0x100336270		1400015b		JMP 347(PC)										
  monolith.go:4224	0x100336274		91000a16		ADD $2, R16, R22									
  monolith.go:4224	0x100336278		eb1600df		CMP R22, R6										
  monolith.go:4224	0x10033627c		540004ab		BLT 37(PC)										
  monolith.go:4225	0x100336280		91000617		ADD $1, R16, R23									
  monolith.go:4225	0x100336284		9b177d18		MUL R23, R8, R24									
  monolith.go:4225	0x100336288		9b087dd9		MUL R8, R14, R25									
  monolith.go:4225	0x10033628c		eb18007f		CMP R24, R3										
  monolith.go:4225	0x100336290		54002943		BCC 330(PC)										
  monolith.go:4225	0x100336294		eb190b1f		CMP R25<<2, R24										
  monolith.go:4225	0x100336298		540028a3		BCC 325(PC)										
  monolith.go:4225	0x10033629c		cb19087a		SUB R25<<2, R3, R26									
  monolith.go:4225	0x1003362a0		cb1a03fe		NEG R26, R30										
  monolith.go:4225	0x1003362a4		8a9eff3e		AND R30->63, R25, R30									
  monolith.go:4225	0x1003362a8		9b167d0a		MUL R22, R8, R10									
  monolith.go:4225	0x1003362ac		cb190b19		SUB R25<<2, R24, R25									
  monolith.go:4225	0x1003362b0		8b1e119e		ADD R30<<4, R12, R30									
  monolith.go:4225	0x1003362b4		eb0a007f		CMP R10, R3										
  monolith.go:4225	0x1003362b8		54002783		BCC 316(PC)										
  monolith.go:4225	0x1003362bc		eb18015f		CMP R24, R10										
  monolith.go:4225	0x1003362c0		54002703		BCC 312(PC)										
  monolith.go:4179	0x1003362c4		f9003bf3		MOVD R19, 112(RSP)									
  monolith.go:4179	0x1003362c8		f9008bf5		MOVD R21, 272(RSP)									
  monolith.go:4180	0x1003362cc		f90093f1		MOVD R17, 288(RSP)									
  monolith.go:4224	0x1003362d0		f9006bf6		MOVD R22, 208(RSP)									
  monolith.go:4225	0x1003362d4		f90067f7		MOVD R23, 200(RSP)									
  monolith.go:4225	0x1003362d8		f9002ff9		MOVD R25, 88(RSP)									
  monolith.go:4225	0x1003362dc		f90033fa		MOVD R26, 96(RSP)									
  monolith.go:4225	0x1003362e0		f90083fe		MOVD R30, 256(RSP)									
  monolith.go:4178	0x1003362e4		f90053ef		MOVD R15, 160(RSP)									
  monolith.go:4225	0x1003362e8		cb03030a		SUB R3, R24, R10									
  monolith.go:4225	0x1003362ec		8a8aff0a		AND R10->63, R24, R10									
  monolith.go:4225	0x1003362f0		8b0a098a		ADD R10<<2, R12, R10									
  monolith.go:4225	0x1003362f4		f9007fea		MOVD R10, 248(RSP)									
  monolith.go:4225	0x1003362f8		cb180078		SUB R24, R3, R24									
  monolith.go:4225	0x1003362fc		f9002bf8		MOVD R24, 80(RSP)									
  monolith.go:4227	0x100336300		aa1f03f0		MOVD ZR, R16										
  monolith.go:4227	0x100336304		1e2703e0		FMOVS ZR, F0										
  monolith.go:4227	0x100336308		1e2703e1		FMOVS ZR, F1										
  monolith.go:4227	0x10033630c		14000082		JMP 130(PC)										
  monolith.go:4177	0x100336310		aa1003f3		MOVD R16, R19										
  monolith.go:4224	0x100336314		14000003		JMP 3(PC)										
  monolith.go:4277	0x100336318		bc307880		FMOVS F0, (R4)(R16<<2)									
  monolith.go:4259	0x10033631c		aa1603f0		MOVD R22, R16										
  monolith.go:4259	0x100336320		eb06021f		CMP R6, R16										
  monolith.go:4259	0x100336324		54fff04a		BGE -126(PC)										
  monolith.go:4260	0x100336328		91000616		ADD $1, R16, R22									
  monolith.go:4260	0x10033632c		9b087ed7		MUL R8, R22, R23									
  monolith.go:4260	0x100336330		9b087e18		MUL R8, R16, R24									
  monolith.go:4260	0x100336334		eb17007f		CMP R23, R3										
  monolith.go:4260	0x100336338		54000b43		BCC 90(PC)										
  monolith.go:4260	0x10033633c		eb1802ff		CMP R24, R23										
  monolith.go:4260	0x100336340		54000aa3		BCC 85(PC)										
  monolith.go:4260	0x100336344		cb030317		SUB R3, R24, R23									
  monolith.go:4260	0x100336348		8a97ff17		AND R23->63, R24, R23									
  monolith.go:4260	0x10033634c		8b170997		ADD R23<<2, R12, R23									
  monolith.go:4262	0x100336350		aa1f03f8		MOVD ZR, R24										
  monolith.go:4262	0x100336354		1e2703e0		FMOVS ZR, F0										
  monolith.go:4262	0x100336358		14000003		JMP 3(PC)										
  monolith.go:4275	0x10033635c		1f020020		FMADDS F2, F0, F1, F0									
  monolith.go:4262	0x100336360		aa1903f8		MOVD R25, R24										
  monolith.go:4262	0x100336364		eb891b1f		CMP R9->6, R24										
  monolith.go:4262	0x100336368		5400076a		BGE 59(PC)										
  monolith.go:4263	0x10033636c		91000719		ADD $1, R24, R25									
  monolith.go:4263	0x100336370		d37ae73a		LSL $6, R25, R26									
  monolith.go:4262	0x100336374		bc787a21		FMOVS (R17)(R24<<2), F1									
  monolith.go:4263	0x100336378		d37ae718		LSL $6, R24, R24									
  monolith.go:4263	0x10033637c		eb19191f		CMP R25<<6, R8										
  monolith.go:4263	0x100336380		9a9ab11a		CSEL LT, R8, R26, R26									
  monolith.go:4263	0x100336384		1e2703e2		FMOVS ZR, F2										
  monolith.go:4263	0x100336388		1e2703e3		FMOVS ZR, F3										
  monolith.go:4263	0x10033638c		1e2703e4		FMOVS ZR, F4										
  monolith.go:4263	0x100336390		1e2703e5		FMOVS ZR, F5										
  monolith.go:4263	0x100336394		14000007		JMP 7(PC)										
  monolith.go:4269	0x100336398		bc6a7ae6		FMOVS (R23)(R10<<2), F6									
  monolith.go:4269	0x10033639c		38aa6aaa		MOVB (R21)(R10), R10									
  monolith.go:4269	0x1003363a0		1e220147		SCVTFWS R10, F7										
  monolith.go:4269	0x1003363a4		1f0714c5		FMADDS F7, F5, F6, F5									
  monolith.go:4177	0x1003363a8		f9403fea		MOVD 120(RSP), R10									
  monolith.go:4265	0x1003363ac		aa1e03f8		MOVD R30, R24										
  monolith.go:4265	0x1003363b0		9100131e		ADD $4, R24, R30									
  monolith.go:4265	0x1003363b4		eb1e035f		CMP R30, R26										
  monolith.go:4265	0x1003363b8		5400032b		BLT 25(PC)										
  monolith.go:4266	0x1003363bc		eb08031f		CMP R8, R24										
  monolith.go:4266	0x1003363c0		54000662		BCS 51(PC)										
  monolith.go:4266	0x1003363c4		bc787ae6		FMOVS (R23)(R24<<2), F6									
  monolith.go:4266	0x1003363c8		38b86aaa		MOVB (R21)(R24), R10									
  monolith.go:4266	0x1003363cc		1e220147		SCVTFWS R10, F7										
  monolith.go:4267	0x1003363d0		9100070a		ADD $1, R24, R10									
  monolith.go:4266	0x1003363d4		1f0710c4		FMADDS F7, F4, F6, F4									
  monolith.go:4267	0x1003363d8		eb0a011f		CMP R10, R8										
  monolith.go:4267	0x1003363dc		54000569		BLS 43(PC)										
  monolith.go:4267	0x1003363e0		bc6a7ae6		FMOVS (R23)(R10<<2), F6									
  monolith.go:4267	0x1003363e4		38aa6aaa		MOVB (R21)(R10), R10									
  monolith.go:4267	0x1003363e8		1e220147		SCVTFWS R10, F7										
  monolith.go:4268	0x1003363ec		91000b0a		ADD $2, R24, R10									
  monolith.go:4267	0x1003363f0		1f0708c2		FMADDS F7, F2, F6, F2									
  monolith.go:4268	0x1003363f4		eb0a011f		CMP R10, R8										
  monolith.go:4268	0x1003363f8		54000469		BLS 35(PC)										
  monolith.go:4268	0x1003363fc		bc6a7ae6		FMOVS (R23)(R10<<2), F6									
  monolith.go:4268	0x100336400		38aa6aaa		MOVB (R21)(R10), R10									
  monolith.go:4268	0x100336404		1e220147		SCVTFWS R10, F7										
  monolith.go:4269	0x100336408		91000f0a		ADD $3, R24, R10									
  monolith.go:4268	0x10033640c		1f070cc3		FMADDS F7, F3, F6, F3									
  monolith.go:4269	0x100336410		eb0a011f		CMP R10, R8										
  monolith.go:4269	0x100336414		54fffc28		BHI -31(PC)										
  monolith.go:4269	0x100336418		1400001a		JMP 26(PC)										
  monolith.go:4271	0x10033641c		1e222882		FADDS F2, F4, F2									
  monolith.go:4271	0x100336420		1e252863		FADDS F5, F3, F3									
  monolith.go:4271	0x100336424		1e232842		FADDS F3, F2, F2									
  monolith.go:4272	0x100336428		14000006		JMP 6(PC)										
  monolith.go:4273	0x10033642c		bc787ae3		FMOVS (R23)(R24<<2), F3									
  monolith.go:4273	0x100336430		38b86abe		MOVB (R21)(R24), R30									
  monolith.go:4273	0x100336434		1e2203c4		SCVTFWS R30, F4										
  monolith.go:4273	0x100336438		1f040862		FMADDS F4, F2, F3, F2									
  monolith.go:4272	0x10033643c		91000718		ADD $1, R24, R24									
  monolith.go:4272	0x100336440		eb1a031f		CMP R26, R24										
  monolith.go:4272	0x100336444		54fff8ca		BGE -58(PC)										
  monolith.go:4273	0x100336448		eb08031f		CMP R8, R24										
  monolith.go:4273	0x10033644c		54ffff03		BCC -8(PC)										
  monolith.go:4273	0x100336450		1400000a		JMP 10(PC)										
  monolith.go:4277	0x100336454		9b103cf0		MADD R16, R15, R7, R16									
  monolith.go:4277	0x100336458		eb10017f		CMP R16, R11										
  monolith.go:4277	0x10033645c		54fff5e8		BHI -81(PC)										
  monolith.go:4277	0x100336460		14000004		JMP 4(PC)										
  monolith.go:4282	0x100336464		a97ffbfd		LDP -8(RSP), (R29, R30)									
  monolith.go:4282	0x100336468		9104c3ff		ADD $304, RSP, RSP									
  monolith.go:4282	0x10033646c		d65f03c0		RET											
  monolith.go:4277	0x100336470		aa1003e0		MOVD R16, R0										
  monolith.go:4277	0x100336474		97f550d3		CALL runtime.panicBounds(SB)								
  monolith.go:4273	0x100336478		aa1803e0		MOVD R24, R0										
  monolith.go:4273	0x10033647c		97f550d1		CALL runtime.panicBounds(SB)								
  monolith.go:4269	0x100336480		97f550d0		CALL runtime.panicBounds(SB)								
  monolith.go:4268	0x100336484		97f550cf		CALL runtime.panicBounds(SB)								
  monolith.go:4267	0x100336488		97f550ce		CALL runtime.panicBounds(SB)								
  monolith.go:4266	0x10033648c		aa1803e0		MOVD R24, R0										
  monolith.go:4266	0x100336490		97f550cc		CALL runtime.panicBounds(SB)								
  monolith.go:4260	0x100336494		aa1803e0		MOVD R24, R0										
  monolith.go:4260	0x100336498		aa1703e1		MOVD R23, R1										
  monolith.go:4260	0x10033649c		97f550c9		CALL runtime.panicBounds(SB)								
  monolith.go:4260	0x1003364a0		aa1703e0		MOVD R23, R0										
  monolith.go:4260	0x1003364a4		97f550c7		CALL runtime.panicBounds(SB)								
  monolith.go:4178	0x1003364a8		f9404fe0		MOVD 152(RSP), R0									
  monolith.go:4176	0x1003364ac		f94043e1		MOVD 128(RSP), R1									
  monolith.go:4176	0x1003364b0		f940a7e2		MOVD 328(RSP), R2									
  monolith.go:4260	0x1003364b4		f94037e3		MOVD 104(RSP), R3									
  monolith.go:4256	0x1003364b8		f9407be4		MOVD 240(RSP), R4									
  monolith.go:4179	0x1003364bc		f9408fe5		MOVD 280(RSP), R5									
  monolith.go:4259	0x1003364c0		f94057e6		MOVD 168(RSP), R6									
  monolith.go:4256	0x1003364c4		f9404be7		MOVD 144(RSP), R7									
  monolith.go:4228	0x1003364c8		f9405be8		MOVD 176(RSP), R8									
  monolith.go:4227	0x1003364cc		f94077e9		MOVD 232(RSP), R9									
  monolith.go:4242	0x1003364d0		f9407fea		MOVD 248(RSP), R10									
  monolith.go:4256	0x1003364d4		f94027eb		MOVD 72(RSP), R11									
  monolith.go:4260	0x1003364d8		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4180	0x1003364dc		f9405fed		MOVD 184(RSP), R13									
  monolith.go:4256	0x1003364e0		f94073ee		MOVD 224(RSP), R14									
  monolith.go:4256	0x1003364e4		f94053ef		MOVD 160(RSP), R15									
  monolith.go:4227	0x1003364e8		f94093f1		MOVD 288(RSP), R17									
  monolith.go:4230	0x1003364ec		f9403bf3		MOVD 112(RSP), R19									
  monolith.go:4178	0x1003364f0		f9406ff4		MOVD 216(RSP), R20									
  monolith.go:4237	0x1003364f4		f9408bf5		MOVD 272(RSP), R21									
  monolith.go:4259	0x1003364f8		f9406bf6		MOVD 208(RSP), R22									
  monolith.go:4256	0x1003364fc		f94067f7		MOVD 200(RSP), R23									
  monolith.go:4230	0x100336500		f9402bf8		MOVD 80(RSP), R24									
  monolith.go:4238	0x100336504		f9402ff9		MOVD 88(RSP), R25									
  monolith.go:4230	0x100336508		f94033fa		MOVD 96(RSP), R26									
  monolith.go:4238	0x10033650c		f94083fe		MOVD 256(RSP), R30									
  monolith.go:4227	0x100336510		f94063f0		MOVD 192(RSP), R16									
  monolith.go:4227	0x100336514		eb891a1f		CMP R9->6, R16										
  monolith.go:4227	0x100336518		5400056a		BGE 43(PC)										
  monolith.go:4228	0x10033651c		91000602		ADD $1, R16, R2										
  monolith.go:4228	0x100336520		f90063e2		MOVD R2, 192(RSP)									
  monolith.go:4228	0x100336524		d37ae441		LSL $6, R2, R1										
  monolith.go:4227	0x100336528		bc707a22		FMOVS (R17)(R16<<2), F2									
  monolith.go:4228	0x10033652c		d37ae60d		LSL $6, R16, R13									
  monolith.go:4228	0x100336530		eb02191f		CMP R2<<6, R8										
  monolith.go:4228	0x100336534		9a81b101		CSEL LT, R8, R1, R1									
  monolith.go:4229	0x100336538		cb101825		SUB R16<<6, R1, R5									
  monolith.go:4229	0x10033653c		f10100bf		CMP $64, R5										
  monolith.go:4228	0x100336540		54000140		BEQ 10(PC)										
  monolith.go:4229	0x100336544		1e2703e3		FMOVS ZR, F3										
  monolith.go:4229	0x100336548		1e2703e4		FMOVS ZR, F4										
  monolith.go:4229	0x10033654c		1e2703e5		FMOVS ZR, F5										
  monolith.go:4229	0x100336550		1e2703e6		FMOVS ZR, F6										
  monolith.go:4229	0x100336554		1e2703e7		FMOVS ZR, F7										
  monolith.go:4229	0x100336558		1e2703e8		FMOVS ZR, F8										
  monolith.go:4229	0x10033655c		1e2703e9		FMOVS ZR, F9										
  monolith.go:4229	0x100336560		1e2703ea		FMOVS ZR, F10										
  monolith.go:4229	0x100336564		14000040		JMP 64(PC)										
  monolith.go:4230	0x100336568		eb1a003f		CMP R26, R1										
  monolith.go:4230	0x10033656c		54000548		BHI 42(PC)										
  monolith.go:4230	0x100336570		eb10183f		CMP R16<<6, R1										
  monolith.go:4230	0x100336574		540004e3		BCC 39(PC)										
  monolith.go:4230	0x100336578		8b1023c5		ADD R16<<8, R30, R5									
  monolith.go:4230	0x10033657c		eb18003f		CMP R24, R1										
  monolith.go:4230	0x100336580		54000448		BHI 34(PC)										
  monolith.go:4230	0x100336584		8b10214d		ADD R16<<8, R10, R13									
  monolith.go:4230	0x100336588		eb13003f		CMP R19, R1										
  monolith.go:4230	0x10033658c		540003a8		BHI 29(PC)										
  monolith.go:4227	0x100336590		bd0027e2		FMOVS F2, 36(RSP)									
  monolith.go:4227	0x100336594		bd0037e1		FMOVS F1, 52(RSP)									
  monolith.go:4227	0x100336598		bd003fe0		FMOVS F0, 60(RSP)									
  monolith.go:4230	0x10033659c		8b101aa2		ADD R16<<6, R21, R2									
  monolith.go:4230	0x1003365a0		aa0503e0		MOVD R5, R0										
  monolith.go:4230	0x1003365a4		aa0d03e1		MOVD R13, R1										
  monolith.go:4230	0x1003365a8		9400016a		CALL github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.dotQ8PairBlock64(SB)	
  monolith.go:4231	0x1003365ac		bd403fe2		FMOVS 60(RSP), F2									
  monolith.go:4231	0x1003365b0		bd4027e3		FMOVS 36(RSP), F3									
  monolith.go:4231	0x1003365b4		1f000860		FMADDS F0, F2, F3, F0									
  monolith.go:4232	0x1003365b8		bd4037e2		FMOVS 52(RSP), F2									
  monolith.go:4232	0x1003365bc		1f010861		FMADDS F1, F2, F3, F1									
  monolith.go:4233	0x1003365c0		17ffffba		JMP -70(PC)										
  monolith.go:4256	0x1003365c4		9b077dca		MUL R7, R14, R10									
  monolith.go:4256	0x1003365c8		8b0a09ea		ADD R10<<2, R15, R10									
  monolith.go:4256	0x1003365cc		eb0a017f		CMP R10, R11										
  monolith.go:4256	0x1003365d0		54000169		BLS 11(PC)										
  monolith.go:4256	0x1003365d4		bc2a7880		FMOVS F0, (R4)(R10<<2)									
  monolith.go:4256	0x1003365d8		9b073eea		MADD R7, R15, R23, R10									
  monolith.go:4256	0x1003365dc		eb0a017f		CMP R10, R11										
  monolith.go:4256	0x1003365e0		540000c9		BLS 6(PC)										
  monolith.go:4256	0x1003365e4		bc2a7881		FMOVS F1, (R4)(R10<<2)									
  monolith.go:4177	0x1003365e8		f9403fea		MOVD 120(RSP), R10									
  monolith.go:4181	0x1003365ec		f94047f3		MOVD 136(RSP), R19									
  monolith.go:4259	0x1003365f0		aa1603f0		MOVD R22, R16										
  monolith.go:4257	0x1003365f4		17ffff4b		JMP -181(PC)										
  monolith.go:4256	0x1003365f8		97f55072		CALL runtime.panicBounds(SB)								
  monolith.go:4256	0x1003365fc		97f55071		CALL runtime.panicBounds(SB)								
  monolith.go:4230	0x100336600		aa1303e0		MOVD R19, R0										
  monolith.go:4230	0x100336604		97f5506f		CALL runtime.panicBounds(SB)								
  monolith.go:4230	0x100336608		aa1803e0		MOVD R24, R0										
  monolith.go:4230	0x10033660c		97f5506d		CALL runtime.panicBounds(SB)								
  monolith.go:4230	0x100336610		97f5506c		CALL runtime.panicBounds(SB)								
  monolith.go:4230	0x100336614		aa1a03e0		MOVD R26, R0										
  monolith.go:4230	0x100336618		97f5506a		CALL runtime.panicBounds(SB)								
  monolith.go:4237	0x10033661c		1e2202ce		SCVTFWS R22, F14									
  monolith.go:4241	0x100336620		bc637bcf		FMOVS (R30)(R3<<2), F15									
  monolith.go:4242	0x100336624		bc6d7950		FMOVS (R10)(R13<<2), F16								
  monolith.go:4243	0x100336628		bc707951		FMOVS (R10)(R16<<2), F17								
  monolith.go:4244	0x10033662c		bc747952		FMOVS (R10)(R20<<2), F18								
  monolith.go:4245	0x100336630		bc637953		FMOVS (R10)(R3<<2), F19									
  monolith.go:4241	0x100336634		1f0f1dc7		FMADDS F15, F7, F14, F7									
  monolith.go:4242	0x100336638		1f102168		FMADDS F16, F8, F11, F8									
  monolith.go:4243	0x10033663c		1f11298a		FMADDS F17, F10, F12, F10								
  monolith.go:4244	0x100336640		1f1215a5		FMADDS F18, F5, F13, F5									
  monolith.go:4245	0x100336644		1f1311c4		FMADDS F19, F4, F14, F4									
  monolith.go:4178	0x100336648		f9404fe0		MOVD 152(RSP), R0									
  monolith.go:4260	0x10033664c		f94037e3		MOVD 104(RSP), R3									
  monolith.go:4259	0x100336650		f94057e6		MOVD 168(RSP), R6									
  monolith.go:4260	0x100336654		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4178	0x100336658		f9406ff4		MOVD 216(RSP), R20									
  monolith.go:4259	0x10033665c		f9406bf6		MOVD 208(RSP), R22									
  monolith.go:4236	0x100336660		aa0503ed		MOVD R5, R13										
  monolith.go:4236	0x100336664		910011a5		ADD $4, R13, R5										
  monolith.go:4236	0x100336668		eb05003f		CMP R5, R1										
  monolith.go:4236	0x10033666c		5400044b		BLT 34(PC)										
  monolith.go:4237	0x100336670		eb0801bf		CMP R8, R13										
  monolith.go:4237	0x100336674		54000942		BCS 74(PC)										
  monolith.go:4237	0x100336678		910005b0		ADD $1, R13, R16									
  monolith.go:4237	0x10033667c		38ad6aa0		MOVB (R21)(R13), R0									
  monolith.go:4237	0x100336680		eb10011f		CMP R16, R8										
  monolith.go:4237	0x100336684		54000889		BLS 68(PC)										
  monolith.go:4237	0x100336688		910009b4		ADD $2, R13, R20									
  monolith.go:4237	0x10033668c		38b06aac		MOVB (R21)(R16), R12									
  monolith.go:4237	0x100336690		eb14011f		CMP R20, R8										
  monolith.go:4237	0x100336694		540007c9		BLS 62(PC)										
  monolith.go:4237	0x100336698		91000da3		ADD $3, R13, R3										
  monolith.go:4237	0x10033669c		38b46aa6		MOVB (R21)(R20), R6									
  monolith.go:4237	0x1003366a0		eb03011f		CMP R3, R8										
  monolith.go:4237	0x1003366a4		54000729		BLS 57(PC)										
  monolith.go:4237	0x1003366a8		38a36ab6		MOVB (R21)(R3), R22									
  monolith.go:4238	0x1003366ac		eb1901bf		CMP R25, R13										
  monolith.go:4238	0x1003366b0		54000682		BCS 52(PC)										
  monolith.go:4237	0x1003366b4		1e22000b		SCVTFWS R0, F11										
  monolith.go:4238	0x1003366b8		bc6d7bcc		FMOVS (R30)(R13<<2), F12								
  monolith.go:4238	0x1003366bc		1f0c2569		FMADDS F12, F9, F11, F9									
  monolith.go:4239	0x1003366c0		eb10033f		CMP R16, R25										
  monolith.go:4239	0x1003366c4		54000589		BLS 44(PC)										
  monolith.go:4237	0x1003366c8		1e22018c		SCVTFWS R12, F12									
  monolith.go:4239	0x1003366cc		bc707bcd		FMOVS (R30)(R16<<2), F13								
  monolith.go:4239	0x1003366d0		1f0d1986		FMADDS F13, F6, F12, F6									
  monolith.go:4240	0x1003366d4		eb14033f		CMP R20, R25										
  monolith.go:4240	0x1003366d8		54000489		BLS 36(PC)										
  monolith.go:4237	0x1003366dc		1e2200cd		SCVTFWS R6, F13										
  monolith.go:4240	0x1003366e0		bc747bce		FMOVS (R30)(R20<<2), F14								
  monolith.go:4240	0x1003366e4		1f0e0da3		FMADDS F14, F3, F13, F3									
  monolith.go:4241	0x1003366e8		eb03033f		CMP R3, R25										
  monolith.go:4241	0x1003366ec		54fff988		BHI -52(PC)										
  monolith.go:4241	0x1003366f0		1400001c		JMP 28(PC)										
  monolith.go:4247	0x1003366f4		1e262926		FADDS F6, F9, F6									
  monolith.go:4247	0x1003366f8		1e272863		FADDS F7, F3, F3									
  monolith.go:4247	0x1003366fc		1e2a2907		FADDS F10, F8, F7									
  monolith.go:4247	0x100336700		1e2428a4		FADDS F4, F5, F4									
  monolith.go:4247	0x100336704		1e262863		FADDS F6, F3, F3									
  monolith.go:4247	0x100336708		1e272884		FADDS F7, F4, F4									
  monolith.go:4248	0x10033670c		14000007		JMP 7(PC)										
  monolith.go:4249	0x100336710		1e2200a5		SCVTFWS R5, F5										
  monolith.go:4250	0x100336714		bc6d7bc6		FMOVS (R30)(R13<<2), F6									
  monolith.go:4251	0x100336718		bc6d7947		FMOVS (R10)(R13<<2), F7									
  monolith.go:4250	0x10033671c		1f060ca3		FMADDS F6, F3, F5, F3									
  monolith.go:4251	0x100336720		1f0710a4		FMADDS F7, F4, F5, F4									
  monolith.go:4248	0x100336724		910005ad		ADD $1, R13, R13									
  monolith.go:4248	0x100336728		eb0101bf		CMP R1, R13										
  monolith.go:4248	0x10033672c		540000ea		BGE 7(PC)										
  monolith.go:4249	0x100336730		eb0801bf		CMP R8, R13										
  monolith.go:4249	0x100336734		54000142		BCS 10(PC)										
  monolith.go:4249	0x100336738		38ad6aa5		MOVB (R21)(R13), R5									
  monolith.go:4250	0x10033673c		eb1901bf		CMP R25, R13										
  monolith.go:4250	0x100336740		54fffe83		BCC -12(PC)										
  monolith.go:4250	0x100336744		14000004		JMP 4(PC)										
  monolith.go:4253	0x100336748		1f030040		FMADDS F3, F0, F2, F0									
  monolith.go:4254	0x10033674c		1f040441		FMADDS F4, F1, F2, F1									
  monolith.go:4254	0x100336750		17ffff56		JMP -170(PC)										
  monolith.go:4250	0x100336754		aa1903e0		MOVD R25, R0										
  monolith.go:4250	0x100336758		97f5501a		CALL runtime.panicBounds(SB)								
  monolith.go:4249	0x10033675c		97f55019		CALL runtime.panicBounds(SB)								
  monolith.go:4241	0x100336760		aa1903e0		MOVD R25, R0										
  monolith.go:4241	0x100336764		97f55017		CALL runtime.panicBounds(SB)								
  monolith.go:4240	0x100336768		aa1403e0		MOVD R20, R0										
  monolith.go:4240	0x10033676c		aa1903e1		MOVD R25, R1										
  monolith.go:4240	0x100336770		97f55014		CALL runtime.panicBounds(SB)								
  monolith.go:4239	0x100336774		aa1003e0		MOVD R16, R0										
  monolith.go:4239	0x100336778		aa1903e1		MOVD R25, R1										
  monolith.go:4239	0x10033677c		97f55011		CALL runtime.panicBounds(SB)								
  monolith.go:4238	0x100336780		aa1903e0		MOVD R25, R0										
  monolith.go:4238	0x100336784		97f5500f		CALL runtime.panicBounds(SB)								
  monolith.go:4237	0x100336788		97f5500e		CALL runtime.panicBounds(SB)								
  monolith.go:4237	0x10033678c		aa1403e0		MOVD R20, R0										
  monolith.go:4237	0x100336790		97f5500c		CALL runtime.panicBounds(SB)								
  monolith.go:4237	0x100336794		aa1003e0		MOVD R16, R0										
  monolith.go:4237	0x100336798		97f5500a		CALL runtime.panicBounds(SB)								
  monolith.go:4237	0x10033679c		97f55009		CALL runtime.panicBounds(SB)								
  monolith.go:4225	0x1003367a0		aa1803e0		MOVD R24, R0										
  monolith.go:4225	0x1003367a4		97f55007		CALL runtime.panicBounds(SB)								
  monolith.go:4225	0x1003367a8		97f55006		CALL runtime.panicBounds(SB)								
  monolith.go:4225	0x1003367ac		d37ef720		LSL $2, R25, R0										
  monolith.go:4225	0x1003367b0		aa1803e1		MOVD R24, R1										
  monolith.go:4225	0x1003367b4		97f55003		CALL runtime.panicBounds(SB)								
  monolith.go:4225	0x1003367b8		aa1803e0		MOVD R24, R0										
  monolith.go:4225	0x1003367bc		97f55001		CALL runtime.panicBounds(SB)								
  monolith.go:4215	0x1003367c0		1f070481		FMADDS F7, F1, F4, F1									
  monolith.go:4216	0x1003367c4		1f080882		FMADDS F8, F2, F4, F2									
  monolith.go:4217	0x1003367c8		1f060080		FMADDS F6, F0, F4, F0									
  monolith.go:4218	0x1003367cc		1f050c83		FMADDS F5, F3, F4, F3									
  monolith.go:4182	0x1003367d0		f94087e1		MOVD 264(RSP), R1									
  monolith.go:4182	0x1003367d4		f94037e3		MOVD 104(RSP), R3									
  monolith.go:4185	0x1003367d8		aa0203ec		MOVD R2, R12										
  monolith.go:4185	0x1003367dc		eb89199f		CMP R9->6, R12										
  monolith.go:4185	0x1003367e0		5400114a		BGE 138(PC)										
  monolith.go:4185	0x1003367e4		bd002fe3		FMOVS F3, 44(RSP)									
  monolith.go:4185	0x1003367e8		bd0033e0		FMOVS F0, 48(RSP)									
  monolith.go:4185	0x1003367ec		bd003be2		FMOVS F2, 56(RSP)									
  monolith.go:4185	0x1003367f0		bd0043e1		FMOVS F1, 64(RSP)									
  monolith.go:4187	0x1003367f4		91000582		ADD $1, R12, R2										
  monolith.go:4187	0x1003367f8		d37ae441		LSL $6, R2, R1										
  monolith.go:4185	0x1003367fc		bc6c7a24		FMOVS (R17)(R12<<2), F4									
  monolith.go:4185	0x100336800		bd002be4		FMOVS F4, 40(RSP)									
  monolith.go:4187	0x100336804		d37ae58c		LSL $6, R12, R12									
  monolith.go:4187	0x100336808		eb02191f		CMP R2<<6, R8										
  monolith.go:4187	0x10033680c		9a81b101		CSEL LT, R8, R1, R1									
  monolith.go:4187	0x100336810		1e2703e5		FMOVS ZR, F5										
  monolith.go:4187	0x100336814		1e2703e6		FMOVS ZR, F6										
  monolith.go:4187	0x100336818		1e2703e7		FMOVS ZR, F7										
  monolith.go:4187	0x10033681c		1e2703e8		FMOVS ZR, F8										
  monolith.go:4187	0x100336820		1e2703e9		FMOVS ZR, F9										
  monolith.go:4187	0x100336824		1e2703ea		FMOVS ZR, F10										
  monolith.go:4187	0x100336828		1e2703eb		FMOVS ZR, F11										
  monolith.go:4187	0x10033682c		1e2703ec		FMOVS ZR, F12										
  monolith.go:4187	0x100336830		1e2703ed		FMOVS ZR, F13										
  monolith.go:4187	0x100336834		1e2703ee		FMOVS ZR, F14										
  monolith.go:4187	0x100336838		1e2703ef		FMOVS ZR, F15										
  monolith.go:4187	0x10033683c		1e2703f0		FMOVS ZR, F16										
  monolith.go:4187	0x100336840		1e2703f1		FMOVS ZR, F17										
  monolith.go:4187	0x100336844		1e2703f2		FMOVS ZR, F18										
  monolith.go:4187	0x100336848		1e2703f3		FMOVS ZR, F19										
  monolith.go:4187	0x10033684c		1e2703f4		FMOVS ZR, F20										
  monolith.go:4187	0x100336850		1400002b		JMP 43(PC)										
  monolith.go:4191	0x100336854		bd0047e7		FMOVS F7, 68(RSP)									
  monolith.go:4189	0x100336858		1e2202d8		SCVTFWS R22, F24									
  monolith.go:4193	0x10033685c		bc607b39		FMOVS (R25)(R0<<2), F25									
  monolith.go:4194	0x100336860		bc6c795a		FMOVS (R10)(R12<<2), F26								
  monolith.go:4195	0x100336864		bc66795b		FMOVS (R10)(R6<<2), F27									
  monolith.go:4196	0x100336868		bc6d795c		FMOVS (R10)(R13<<2), F28								
  monolith.go:4197	0x10033686c		bc60795d		FMOVS (R10)(R0<<2), F29									
  monolith.go:4198	0x100336870		bc6c7bde		FMOVS (R30)(R12<<2), F30								
  monolith.go:4199	0x100336874		bc667bdf		FMOVS (R30)(R6<<2), F31									
  monolith.go:4200	0x100336878		bc6d7bc3		FMOVS (R30)(R13<<2), F3									
  monolith.go:4201	0x10033687c		bc607bc0		FMOVS (R30)(R0<<2), F0									
  monolith.go:4202	0x100336880		bc6c7ae2		FMOVS (R23)(R12<<2), F2									
  monolith.go:4203	0x100336884		bc667ae1		FMOVS (R23)(R6<<2), F1									
  monolith.go:4204	0x100336888		bc6d7ae4		FMOVS (R23)(R13<<2), F4									
  monolith.go:4205	0x10033688c		bc607ae7		FMOVS (R23)(R0<<2), F7									
  monolith.go:4193	0x100336890		1f192709		FMADDS F25, F9, F24, F9									
  monolith.go:4194	0x100336894		1f1a4ab2		FMADDS F26, F18, F21, F18								
  monolith.go:4195	0x100336898		1f1b2aca		FMADDS F27, F10, F22, F10								
  monolith.go:4196	0x10033689c		1f1c32ec		FMADDS F28, F12, F23, F12								
  monolith.go:4197	0x1003368a0		1f1d2f0b		FMADDS F29, F11, F24, F11								
  monolith.go:4198	0x1003368a4		1f1e1aa6		FMADDS F30, F6, F21, F6									
  monolith.go:4199	0x1003368a8		1f1f46d1		FMADDS F31, F17, F22, F17								
  monolith.go:4200	0x1003368ac		1f0336ed		FMADDS F3, F13, F23, F13								
  monolith.go:4201	0x1003368b0		1f004f13		FMADDS F0, F19, F24, F19								
  monolith.go:4202	0x1003368b4		1f023aae		FMADDS F2, F14, F21, F14								
  monolith.go:4203	0x1003368b8		1f0142d0		FMADDS F1, F16, F22, F16								
  monolith.go:4204	0x1003368bc		1f043eef		FMADDS F4, F15, F23, F15								
  monolith.go:4205	0x1003368c0		1f071705		FMADDS F7, F5, F24, F5									
  monolith.go:4178	0x1003368c4		f9404fe0		MOVD 152(RSP), R0									
  monolith.go:4179	0x1003368c8		f9408fe5		MOVD 280(RSP), R5									
  monolith.go:4181	0x1003368cc		f94057e6		MOVD 168(RSP), R6									
  monolith.go:4180	0x1003368d0		f9405fed		MOVD 184(RSP), R13									
  monolith.go:4181	0x1003368d4		f94047f0		MOVD 136(RSP), R16									
  monolith.go:4178	0x1003368d8		f9406ff4		MOVD 216(RSP), R20									
  monolith.go:4221	0x1003368dc		f9406bf6		MOVD 208(RSP), R22									
  monolith.go:4217	0x1003368e0		bd4033e0		FMOVS 48(RSP), F0									
  monolith.go:4215	0x1003368e4		bd4043e1		FMOVS 64(RSP), F1									
  monolith.go:4216	0x1003368e8		bd403be2		FMOVS 56(RSP), F2									
  monolith.go:4218	0x1003368ec		bd402fe3		FMOVS 44(RSP), F3									
  monolith.go:4215	0x1003368f0		bd402be4		FMOVS 40(RSP), F4									
  monolith.go:4188	0x1003368f4		aa0303ec		MOVD R3, R12										
  monolith.go:4188	0x1003368f8		bd4047e7		FMOVS 68(RSP), F7									
  monolith.go:4188	0x1003368fc		91001183		ADD $4, R12, R3										
  monolith.go:4188	0x100336900		eb03003f		CMP R3, R1										
  monolith.go:4188	0x100336904		5400044b		BLT 34(PC)										
  monolith.go:4189	0x100336908		eb08019f		CMP R8, R12										
  monolith.go:4189	0x10033690c		54000d02		BCS 104(PC)										
  monolith.go:4189	0x100336910		91000586		ADD $1, R12, R6										
  monolith.go:4189	0x100336914		38ac6ab0		MOVB (R21)(R12), R16									
  monolith.go:4189	0x100336918		eb06011f		CMP R6, R8										
  monolith.go:4189	0x10033691c		54000c69		BLS 99(PC)										
  monolith.go:4189	0x100336920		9100098d		ADD $2, R12, R13									
  monolith.go:4189	0x100336924		38a66aa5		MOVB (R21)(R6), R5									
  monolith.go:4189	0x100336928		eb0d011f		CMP R13, R8										
  monolith.go:4189	0x10033692c		54000bc9		BLS 94(PC)										
  monolith.go:4189	0x100336930		91000d80		ADD $3, R12, R0										
  monolith.go:4189	0x100336934		38ad6ab4		MOVB (R21)(R13), R20									
  monolith.go:4189	0x100336938		eb00011f		CMP R0, R8										
  monolith.go:4189	0x10033693c		54000b29		BLS 89(PC)										
  monolith.go:4189	0x100336940		38a06ab6		MOVB (R21)(R0), R22									
  monolith.go:4190	0x100336944		eb18019f		CMP R24, R12										
  monolith.go:4190	0x100336948		54000a82		BCS 84(PC)										
  monolith.go:4189	0x10033694c		1e220215		SCVTFWS R16, F21									
  monolith.go:4190	0x100336950		bc6c7b36		FMOVS (R25)(R12<<2), F22								
  monolith.go:4190	0x100336954		1f1622a8		FMADDS F22, F8, F21, F8									
  monolith.go:4191	0x100336958		eb06031f		CMP R6, R24										
  monolith.go:4191	0x10033695c		540009a9		BLS 77(PC)										
  monolith.go:4189	0x100336960		1e2200b6		SCVTFWS R5, F22										
  monolith.go:4191	0x100336964		bc667b37		FMOVS (R25)(R6<<2), F23									
  monolith.go:4191	0x100336968		1f171ec7		FMADDS F23, F7, F22, F7									
  monolith.go:4192	0x10033696c		eb0d031f		CMP R13, R24										
  monolith.go:4192	0x100336970		540008c9		BLS 70(PC)										
  monolith.go:4189	0x100336974		1e220297		SCVTFWS R20, F23									
  monolith.go:4192	0x100336978		bc6d7b38		FMOVS (R25)(R13<<2), F24								
  monolith.go:4192	0x10033697c		1f1852f4		FMADDS F24, F20, F23, F20								
  monolith.go:4193	0x100336980		eb00031f		CMP R0, R24										
  monolith.go:4193	0x100336984		54fff688		BHI -76(PC)										
  monolith.go:4193	0x100336988		1400003e		JMP 62(PC)										
  monolith.go:4207	0x10033698c		1e272907		FADDS F7, F8, F7									
  monolith.go:4207	0x100336990		1e292a88		FADDS F9, F20, F8									
  monolith.go:4207	0x100336994		1e2a2a49		FADDS F10, F18, F9									
  monolith.go:4207	0x100336998		1e2b298a		FADDS F11, F12, F10									
  monolith.go:4207	0x10033699c		1e3128c6		FADDS F17, F6, F6									
  monolith.go:4207	0x1003369a0		1e3329ab		FADDS F19, F13, F11									
  monolith.go:4207	0x1003369a4		1e3029cc		FADDS F16, F14, F12									
  monolith.go:4207	0x1003369a8		1e2529e5		FADDS F5, F15, F5									
  monolith.go:4207	0x1003369ac		1e272907		FADDS F7, F8, F7									
  monolith.go:4207	0x1003369b0		1e2a2928		FADDS F10, F9, F8									
  monolith.go:4207	0x1003369b4		1e2b28c6		FADDS F11, F6, F6									
  monolith.go:4207	0x1003369b8		1e252985		FADDS F5, F12, F5									
  monolith.go:4208	0x1003369bc		1400000b		JMP 11(PC)										
  monolith.go:4209	0x1003369c0		1e220069		SCVTFWS R3, F9										
  monolith.go:4210	0x1003369c4		bc6c7b2a		FMOVS (R25)(R12<<2), F10								
  monolith.go:4211	0x1003369c8		bc6c794b		FMOVS (R10)(R12<<2), F11								
  monolith.go:4212	0x1003369cc		bc6c7bcc		FMOVS (R30)(R12<<2), F12								
  monolith.go:4213	0x1003369d0		bc6c7aed		FMOVS (R23)(R12<<2), F13								
  monolith.go:4210	0x1003369d4		1f0a1d27		FMADDS F10, F7, F9, F7									
  monolith.go:4211	0x1003369d8		1f0b2128		FMADDS F11, F8, F9, F8									
  monolith.go:4212	0x1003369dc		1f0c1926		FMADDS F12, F6, F9, F6									
  monolith.go:4213	0x1003369e0		1f0d1525		FMADDS F13, F5, F9, F5									
  monolith.go:4208	0x1003369e4		9100058c		ADD $1, R12, R12									
  monolith.go:4208	0x1003369e8		eb01019f		CMP R1, R12										
  monolith.go:4208	0x1003369ec		54ffeeaa		BGE -139(PC)										
  monolith.go:4209	0x1003369f0		eb08019f		CMP R8, R12										
  monolith.go:4209	0x1003369f4		54000442		BCS 34(PC)										
  monolith.go:4209	0x1003369f8		38ac6aa3		MOVB (R21)(R12), R3									
  monolith.go:4210	0x1003369fc		eb18019f		CMP R24, R12										
  monolith.go:4210	0x100336a00		54fffe03		BCC -16(PC)										
  monolith.go:4210	0x100336a04		1400001c		JMP 28(PC)										
  monolith.go:4220	0x100336a08		9b077dca		MUL R7, R14, R10									
  monolith.go:4220	0x100336a0c		8b0a09ea		ADD R10<<2, R15, R10									
  monolith.go:4220	0x100336a10		eb0a017f		CMP R10, R11										
  monolith.go:4220	0x100336a14		540002e9		BLS 23(PC)										
  monolith.go:4220	0x100336a18		bc2a7881		FMOVS F1, (R4)(R10<<2)									
  monolith.go:4220	0x100336a1c		9b073e6a		MADD R7, R15, R19, R10									
  monolith.go:4220	0x100336a20		eb0a017f		CMP R10, R11										
  monolith.go:4220	0x100336a24		54000249		BLS 18(PC)										
  monolith.go:4220	0x100336a28		bc2a7882		FMOVS F2, (R4)(R10<<2)									
  monolith.go:4221	0x100336a2c		9b073f4a		MADD R7, R15, R26, R10									
  monolith.go:4221	0x100336a30		eb0a017f		CMP R10, R11										
  monolith.go:4221	0x100336a34		540001a9		BLS 13(PC)										
  monolith.go:4221	0x100336a38		bc2a7880		FMOVS F0, (R4)(R10<<2)									
  monolith.go:4221	0x100336a3c		9b073eca		MADD R7, R15, R22, R10									
  monolith.go:4221	0x100336a40		eb0a017f		CMP R10, R11										
  monolith.go:4221	0x100336a44		54000109		BLS 8(PC)										
  monolith.go:4221	0x100336a48		bc2a7883		FMOVS F3, (R4)(R10<<2)									
  monolith.go:4176	0x100336a4c		f94043e1		MOVD 128(RSP), R1									
  monolith.go:4176	0x100336a50		f940a7e2		MOVD 328(RSP), R2									
  monolith.go:4177	0x100336a54		f9403fea		MOVD 120(RSP), R10									
  monolith.go:4182	0x100336a58		f94087ec		MOVD 264(RSP), R12									
  monolith.go:4181	0x100336a5c		aa1003f3		MOVD R16, R19										
  monolith.go:4221	0x100336a60		17fffdb3		JMP -589(PC)										
  monolith.go:4221	0x100336a64		97f54f57		CALL runtime.panicBounds(SB)								
  monolith.go:4221	0x100336a68		97f54f56		CALL runtime.panicBounds(SB)								
  monolith.go:4220	0x100336a6c		97f54f55		CALL runtime.panicBounds(SB)								
  monolith.go:4220	0x100336a70		97f54f54		CALL runtime.panicBounds(SB)								
  monolith.go:4210	0x100336a74		aa1803e0		MOVD R24, R0										
  monolith.go:4210	0x100336a78		97f54f52		CALL runtime.panicBounds(SB)								
  monolith.go:4209	0x100336a7c		97f54f51		CALL runtime.panicBounds(SB)								
  monolith.go:4193	0x100336a80		aa1803e1		MOVD R24, R1										
  monolith.go:4193	0x100336a84		97f54f4f		CALL runtime.panicBounds(SB)								
  monolith.go:4192	0x100336a88		aa1803e0		MOVD R24, R0										
  monolith.go:4192	0x100336a8c		97f54f4d		CALL runtime.panicBounds(SB)								
  monolith.go:4191	0x100336a90		aa1803e0		MOVD R24, R0										
  monolith.go:4191	0x100336a94		97f54f4b		CALL runtime.panicBounds(SB)								
  monolith.go:4190	0x100336a98		aa1803e0		MOVD R24, R0										
  monolith.go:4190	0x100336a9c		97f54f49		CALL runtime.panicBounds(SB)								
  monolith.go:4189	0x100336aa0		97f54f48		CALL runtime.panicBounds(SB)								
  monolith.go:4189	0x100336aa4		97f54f47		CALL runtime.panicBounds(SB)								
  monolith.go:4189	0x100336aa8		97f54f46		CALL runtime.panicBounds(SB)								
  monolith.go:4189	0x100336aac		97f54f45		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336ab0		aa1703e0		MOVD R23, R0										
  monolith.go:4183	0x100336ab4		97f54f43		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336ab8		aa1703e0		MOVD R23, R0										
  monolith.go:4183	0x100336abc		97f54f41		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336ac0		aa1e03e0		MOVD R30, R0										
  monolith.go:4183	0x100336ac4		97f54f3f		CALL runtime.panicBounds(SB)								
  monolith.go:4183	0x100336ac8		97f54f3e		CALL runtime.panicBounds(SB)								
  monolith.go:4182	0x100336acc		aa1603e0		MOVD R22, R0										
  monolith.go:4182	0x100336ad0		aa1e03e1		MOVD R30, R1										
  monolith.go:4182	0x100336ad4		97f54f3b		CALL runtime.panicBounds(SB)								
  monolith.go:4182	0x100336ad8		aa1e03e0		MOVD R30, R0										
  monolith.go:4182	0x100336adc		97f54f39		CALL runtime.panicBounds(SB)								
  monolith.go:4182	0x100336ae0		d37ef700		LSL $2, R24, R0										
  monolith.go:4182	0x100336ae4		aa1603e1		MOVD R22, R1										
  monolith.go:4182	0x100336ae8		97f54f36		CALL runtime.panicBounds(SB)								
  monolith.go:4182	0x100336aec		aa1603e0		MOVD R22, R0										
  monolith.go:4182	0x100336af0		97f54f34		CALL runtime.panicBounds(SB)								
  monolith.go:4180	0x100336af4		aa1603e0		MOVD R22, R0										
  monolith.go:4180	0x100336af8		aa1903e1		MOVD R25, R1										
  monolith.go:4180	0x100336afc		97f54f31		CALL runtime.panicBounds(SB)								
  monolith.go:4180	0x100336b00		aa1903e0		MOVD R25, R0										
  monolith.go:4180	0x100336b04		aa1803e1		MOVD R24, R1										
  monolith.go:4180	0x100336b08		97f54f2e		CALL runtime.panicBounds(SB)								
  monolith.go:4179	0x100336b0c		aa1603e0		MOVD R22, R0										
  monolith.go:4179	0x100336b10		aa1503e1		MOVD R21, R1										
  monolith.go:4179	0x100336b14		97f54f2b		CALL runtime.panicBounds(SB)								
  monolith.go:4179	0x100336b18		aa1503e0		MOVD R21, R0										
  monolith.go:4179	0x100336b1c		aa1303e1		MOVD R19, R1										
  monolith.go:4179	0x100336b20		97f54f28		CALL runtime.panicBounds(SB)								
  monolith.go:4177	0x100336b24		97f43c6f		CALL runtime.panicdivide(SB)								
  monolith.go:4177	0x100336b28		d503201f		NOOP											
  monolith.go:4172	0x100336b2c		a90087e0		STP (R0, R1), 8(RSP)									
  monolith.go:4172	0x100336b30		f9000fe2		MOVD R2, 24(RSP)									
  monolith.go:4172	0x100336b34		aa1e03e3		MOVD R30, R3										
  monolith.go:4172	0x100336b38		97f546de		CALL runtime.morestack_noctxt.abi0(SB)							
  monolith.go:4172	0x100336b3c		a94087e0		LDP 8(RSP), (R0, R1)									
  monolith.go:4172	0x100336b40		f9400fe2		MOVD 24(RSP), R2									
  monolith.go:4172	0x100336b44		17fffd47		JMP github.com/RyoSpiralArchitect/sr_go_tranformer/cmd/monolith.linearQ8Range(SB)	
  monolith.go:4172	0x100336b48		00000000		?											
  monolith.go:4172	0x100336b4c		00000000		?											

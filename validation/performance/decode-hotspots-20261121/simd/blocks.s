TEXT github.com/RyoSpiralArchitect/sr_go_tranformer.dotQ4TwoRowOutputPair64(SB) github.com/RyoSpiralArchitect/sr_go_tranformer/monolith.go
  monolith.go:4691	0x1001d0d20		2d401404		FLDPS (R0), (F4, F5)
  monolith.go:4692	0x1001d0d24		2d401c26		FLDPS (R1), (F6, F7)
  monolith.go:4693	0x1001d0d28		39400044		MOVBU (R2), R4
  monolith.go:4693	0x1001d0d2c		90001905		ADRP 3276800(PC), R5
  monolith.go:4693	0x1001d0d30		913900a5		ADD $3648, R5, R5
  monolith.go:4693	0x1001d0d34		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4694	0x1001d0d38		2d402488		FLDPS (R4), (F8, F9)
  monolith.go:4694	0x1001d0d3c		1e2703ea		FMOVS ZR, F10
  monolith.go:4694	0x1001d0d40		1f04290b		FMADDS F4, F10, F8, F11
  monolith.go:4695	0x1001d0d44		1f05292c		FMADDS F5, F10, F9, F12
  monolith.go:4696	0x1001d0d48		1f062908		FMADDS F6, F10, F8, F8
  monolith.go:4697	0x1001d0d4c		1f072929		FMADDS F7, F10, F9, F9
  monolith.go:4698	0x1001d0d50		39400064		MOVBU (R3), R4
  monolith.go:4698	0x1001d0d54		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4701	0x1001d0d58		2d40388d		FLDPS (R4), (F13, F14)
  monolith.go:4699	0x1001d0d5c		1f0429a4		FMADDS F4, F10, F13, F4
  monolith.go:4700	0x1001d0d60		1f0529c5		FMADDS F5, F10, F14, F5
  monolith.go:4701	0x1001d0d64		1f0629a6		FMADDS F6, F10, F13, F6
  monolith.go:4702	0x1001d0d68		1f0729c7		FMADDS F7, F10, F14, F7
  monolith.go:4705	0x1001d0d6c		2d41380d		FLDPS 8(R0), (F13, F14)
  monolith.go:4706	0x1001d0d70		2d41402f		FLDPS 8(R1), (F15, F16)
  monolith.go:4707	0x1001d0d74		39400444		MOVBU 1(R2), R4
  monolith.go:4707	0x1001d0d78		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4708	0x1001d0d7c		2d404891		FLDPS (R4), (F17, F18)
  monolith.go:4708	0x1001d0d80		1f0d2a33		FMADDS F13, F10, F17, F19
  monolith.go:4709	0x1001d0d84		1f0e2a54		FMADDS F14, F10, F18, F20
  monolith.go:4710	0x1001d0d88		1f0f2a31		FMADDS F15, F10, F17, F17
  monolith.go:4711	0x1001d0d8c		1f102a52		FMADDS F16, F10, F18, F18
  monolith.go:4712	0x1001d0d90		39400464		MOVBU 1(R3), R4
  monolith.go:4712	0x1001d0d94		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4713	0x1001d0d98		2d405895		FLDPS (R4), (F21, F22)
  monolith.go:4713	0x1001d0d9c		1f0d2aad		FMADDS F13, F10, F21, F13
  monolith.go:4714	0x1001d0da0		1f0e2ace		FMADDS F14, F10, F22, F14
  monolith.go:4715	0x1001d0da4		1f0f2aaf		FMADDS F15, F10, F21, F15
  monolith.go:4716	0x1001d0da8		1f102aca		FMADDS F16, F10, F22, F10
  monolith.go:4719	0x1001d0dac		2d425410		FLDPS 16(R0), (F16, F21)
  monolith.go:4720	0x1001d0db0		2d425c36		FLDPS 16(R1), (F22, F23)
  monolith.go:4721	0x1001d0db4		39400844		MOVBU 2(R2), R4
  monolith.go:4721	0x1001d0db8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4724	0x1001d0dbc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4722	0x1001d0dc0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4723	0x1001d0dc4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4724	0x1001d0dc8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4725	0x1001d0dcc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4726	0x1001d0dd0		39400864		MOVBU 2(R3), R4
  monolith.go:4726	0x1001d0dd4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4729	0x1001d0dd8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4727	0x1001d0ddc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4728	0x1001d0de0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4729	0x1001d0de4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4730	0x1001d0de8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4733	0x1001d0dec		2d435410		FLDPS 24(R0), (F16, F21)
  monolith.go:4734	0x1001d0df0		2d435c36		FLDPS 24(R1), (F22, F23)
  monolith.go:4735	0x1001d0df4		39400c44		MOVBU 3(R2), R4
  monolith.go:4735	0x1001d0df8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4736	0x1001d0dfc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4736	0x1001d0e00		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4737	0x1001d0e04		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4738	0x1001d0e08		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4739	0x1001d0e0c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4740	0x1001d0e10		39400c64		MOVBU 3(R3), R4
  monolith.go:4740	0x1001d0e14		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4743	0x1001d0e18		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4741	0x1001d0e1c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4742	0x1001d0e20		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4743	0x1001d0e24		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4744	0x1001d0e28		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4747	0x1001d0e2c		2d445410		FLDPS 32(R0), (F16, F21)
  monolith.go:4748	0x1001d0e30		2d445c36		FLDPS 32(R1), (F22, F23)
  monolith.go:4749	0x1001d0e34		39401044		MOVBU 4(R2), R4
  monolith.go:4749	0x1001d0e38		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4750	0x1001d0e3c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4750	0x1001d0e40		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4751	0x1001d0e44		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4752	0x1001d0e48		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4753	0x1001d0e4c		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4754	0x1001d0e50		39401064		MOVBU 4(R3), R4
  monolith.go:4754	0x1001d0e54		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4757	0x1001d0e58		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4755	0x1001d0e5c		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4756	0x1001d0e60		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4757	0x1001d0e64		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4758	0x1001d0e68		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4761	0x1001d0e6c		2d455410		FLDPS 40(R0), (F16, F21)
  monolith.go:4762	0x1001d0e70		2d455c36		FLDPS 40(R1), (F22, F23)
  monolith.go:4763	0x1001d0e74		39401444		MOVBU 5(R2), R4
  monolith.go:4763	0x1001d0e78		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4764	0x1001d0e7c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4764	0x1001d0e80		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4765	0x1001d0e84		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4766	0x1001d0e88		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4767	0x1001d0e8c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4768	0x1001d0e90		39401464		MOVBU 5(R3), R4
  monolith.go:4768	0x1001d0e94		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4769	0x1001d0e98		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4769	0x1001d0e9c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4770	0x1001d0ea0		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4771	0x1001d0ea4		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4772	0x1001d0ea8		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4775	0x1001d0eac		2d465410		FLDPS 48(R0), (F16, F21)
  monolith.go:4776	0x1001d0eb0		2d465c36		FLDPS 48(R1), (F22, F23)
  monolith.go:4777	0x1001d0eb4		39401844		MOVBU 6(R2), R4
  monolith.go:4777	0x1001d0eb8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4778	0x1001d0ebc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4778	0x1001d0ec0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4779	0x1001d0ec4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4780	0x1001d0ec8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4781	0x1001d0ecc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4782	0x1001d0ed0		39401864		MOVBU 6(R3), R4
  monolith.go:4782	0x1001d0ed4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4785	0x1001d0ed8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4783	0x1001d0edc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4784	0x1001d0ee0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4785	0x1001d0ee4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4786	0x1001d0ee8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4789	0x1001d0eec		2d475410		FLDPS 56(R0), (F16, F21)
  monolith.go:4790	0x1001d0ef0		2d475c36		FLDPS 56(R1), (F22, F23)
  monolith.go:4791	0x1001d0ef4		39401c44		MOVBU 7(R2), R4
  monolith.go:4791	0x1001d0ef8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4792	0x1001d0efc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4792	0x1001d0f00		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4793	0x1001d0f04		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4794	0x1001d0f08		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4795	0x1001d0f0c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4796	0x1001d0f10		39401c64		MOVBU 7(R3), R4
  monolith.go:4796	0x1001d0f14		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4797	0x1001d0f18		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4797	0x1001d0f1c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4798	0x1001d0f20		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4799	0x1001d0f24		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4800	0x1001d0f28		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4803	0x1001d0f2c		2d485410		FLDPS 64(R0), (F16, F21)
  monolith.go:4804	0x1001d0f30		2d485c36		FLDPS 64(R1), (F22, F23)
  monolith.go:4805	0x1001d0f34		39402044		MOVBU 8(R2), R4
  monolith.go:4805	0x1001d0f38		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4808	0x1001d0f3c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4806	0x1001d0f40		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4807	0x1001d0f44		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4808	0x1001d0f48		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4809	0x1001d0f4c		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4810	0x1001d0f50		39402064		MOVBU 8(R3), R4
  monolith.go:4810	0x1001d0f54		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4811	0x1001d0f58		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4811	0x1001d0f5c		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4812	0x1001d0f60		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4813	0x1001d0f64		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4814	0x1001d0f68		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4817	0x1001d0f6c		2d495410		FLDPS 72(R0), (F16, F21)
  monolith.go:4818	0x1001d0f70		2d495c36		FLDPS 72(R1), (F22, F23)
  monolith.go:4819	0x1001d0f74		39402444		MOVBU 9(R2), R4
  monolith.go:4819	0x1001d0f78		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4820	0x1001d0f7c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4820	0x1001d0f80		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4821	0x1001d0f84		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4822	0x1001d0f88		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4823	0x1001d0f8c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4824	0x1001d0f90		39402464		MOVBU 9(R3), R4
  monolith.go:4824	0x1001d0f94		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4825	0x1001d0f98		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4825	0x1001d0f9c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4826	0x1001d0fa0		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4827	0x1001d0fa4		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4828	0x1001d0fa8		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4831	0x1001d0fac		2d4a5410		FLDPS 80(R0), (F16, F21)
  monolith.go:4832	0x1001d0fb0		2d4a5c36		FLDPS 80(R1), (F22, F23)
  monolith.go:4833	0x1001d0fb4		39402844		MOVBU 10(R2), R4
  monolith.go:4833	0x1001d0fb8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4834	0x1001d0fbc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4834	0x1001d0fc0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4835	0x1001d0fc4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4836	0x1001d0fc8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4837	0x1001d0fcc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4838	0x1001d0fd0		39402864		MOVBU 10(R3), R4
  monolith.go:4838	0x1001d0fd4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4841	0x1001d0fd8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4839	0x1001d0fdc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4840	0x1001d0fe0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4841	0x1001d0fe4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4842	0x1001d0fe8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4845	0x1001d0fec		2d4b5410		FLDPS 88(R0), (F16, F21)
  monolith.go:4846	0x1001d0ff0		2d4b5c36		FLDPS 88(R1), (F22, F23)
  monolith.go:4847	0x1001d0ff4		39402c44		MOVBU 11(R2), R4
  monolith.go:4847	0x1001d0ff8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4848	0x1001d0ffc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4848	0x1001d1000		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4849	0x1001d1004		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4850	0x1001d1008		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4851	0x1001d100c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4852	0x1001d1010		39402c64		MOVBU 11(R3), R4
  monolith.go:4852	0x1001d1014		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4855	0x1001d1018		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4853	0x1001d101c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4854	0x1001d1020		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4855	0x1001d1024		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4856	0x1001d1028		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4859	0x1001d102c		2d4c5410		FLDPS 96(R0), (F16, F21)
  monolith.go:4860	0x1001d1030		2d4c5c36		FLDPS 96(R1), (F22, F23)
  monolith.go:4861	0x1001d1034		39403044		MOVBU 12(R2), R4
  monolith.go:4861	0x1001d1038		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4864	0x1001d103c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4862	0x1001d1040		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4863	0x1001d1044		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4864	0x1001d1048		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4865	0x1001d104c		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4866	0x1001d1050		39403064		MOVBU 12(R3), R4
  monolith.go:4866	0x1001d1054		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4867	0x1001d1058		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4867	0x1001d105c		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4868	0x1001d1060		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4869	0x1001d1064		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4870	0x1001d1068		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4873	0x1001d106c		2d4d5410		FLDPS 104(R0), (F16, F21)
  monolith.go:4874	0x1001d1070		2d4d5c36		FLDPS 104(R1), (F22, F23)
  monolith.go:4875	0x1001d1074		39403444		MOVBU 13(R2), R4
  monolith.go:4875	0x1001d1078		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4876	0x1001d107c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4876	0x1001d1080		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4877	0x1001d1084		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4878	0x1001d1088		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4879	0x1001d108c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4880	0x1001d1090		39403464		MOVBU 13(R3), R4
  monolith.go:4880	0x1001d1094		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4883	0x1001d1098		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4881	0x1001d109c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4882	0x1001d10a0		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4883	0x1001d10a4		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4884	0x1001d10a8		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4887	0x1001d10ac		2d4e5410		FLDPS 112(R0), (F16, F21)
  monolith.go:4888	0x1001d10b0		2d4e5c36		FLDPS 112(R1), (F22, F23)
  monolith.go:4889	0x1001d10b4		39403844		MOVBU 14(R2), R4
  monolith.go:4889	0x1001d10b8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4890	0x1001d10bc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4890	0x1001d10c0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4891	0x1001d10c4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4892	0x1001d10c8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4893	0x1001d10cc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4894	0x1001d10d0		39403864		MOVBU 14(R3), R4
  monolith.go:4894	0x1001d10d4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4895	0x1001d10d8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4895	0x1001d10dc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4896	0x1001d10e0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4897	0x1001d10e4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4898	0x1001d10e8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4901	0x1001d10ec		2d4f5410		FLDPS 120(R0), (F16, F21)
  monolith.go:4902	0x1001d10f0		2d4f5c36		FLDPS 120(R1), (F22, F23)
  monolith.go:4903	0x1001d10f4		39403c44		MOVBU 15(R2), R4
  monolith.go:4903	0x1001d10f8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4904	0x1001d10fc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4904	0x1001d1100		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4905	0x1001d1104		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4906	0x1001d1108		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4907	0x1001d110c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4908	0x1001d1110		39403c64		MOVBU 15(R3), R4
  monolith.go:4908	0x1001d1114		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4909	0x1001d1118		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4909	0x1001d111c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4910	0x1001d1120		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4911	0x1001d1124		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4912	0x1001d1128		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4915	0x1001d112c		2d505410		FLDPS 128(R0), (F16, F21)
  monolith.go:4916	0x1001d1130		2d505c36		FLDPS 128(R1), (F22, F23)
  monolith.go:4917	0x1001d1134		39404044		MOVBU 16(R2), R4
  monolith.go:4917	0x1001d1138		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4920	0x1001d113c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4918	0x1001d1140		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4919	0x1001d1144		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4920	0x1001d1148		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4921	0x1001d114c		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4922	0x1001d1150		39404064		MOVBU 16(R3), R4
  monolith.go:4922	0x1001d1154		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4925	0x1001d1158		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4923	0x1001d115c		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4924	0x1001d1160		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4925	0x1001d1164		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4926	0x1001d1168		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4929	0x1001d116c		2d515410		FLDPS 136(R0), (F16, F21)
  monolith.go:4930	0x1001d1170		2d515c36		FLDPS 136(R1), (F22, F23)
  monolith.go:4931	0x1001d1174		39404444		MOVBU 17(R2), R4
  monolith.go:4931	0x1001d1178		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4932	0x1001d117c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4932	0x1001d1180		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4933	0x1001d1184		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4934	0x1001d1188		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4935	0x1001d118c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4936	0x1001d1190		39404464		MOVBU 17(R3), R4
  monolith.go:4936	0x1001d1194		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4937	0x1001d1198		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4937	0x1001d119c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4938	0x1001d11a0		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4939	0x1001d11a4		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4940	0x1001d11a8		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4943	0x1001d11ac		2d525410		FLDPS 144(R0), (F16, F21)
  monolith.go:4944	0x1001d11b0		2d525c36		FLDPS 144(R1), (F22, F23)
  monolith.go:4945	0x1001d11b4		39404844		MOVBU 18(R2), R4
  monolith.go:4945	0x1001d11b8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4948	0x1001d11bc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4946	0x1001d11c0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4947	0x1001d11c4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4948	0x1001d11c8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4949	0x1001d11cc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4950	0x1001d11d0		39404864		MOVBU 18(R3), R4
  monolith.go:4950	0x1001d11d4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4951	0x1001d11d8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4951	0x1001d11dc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4952	0x1001d11e0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4953	0x1001d11e4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4954	0x1001d11e8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4957	0x1001d11ec		2d535410		FLDPS 152(R0), (F16, F21)
  monolith.go:4958	0x1001d11f0		2d535c36		FLDPS 152(R1), (F22, F23)
  monolith.go:4959	0x1001d11f4		39404c44		MOVBU 19(R2), R4
  monolith.go:4959	0x1001d11f8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4960	0x1001d11fc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4960	0x1001d1200		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4961	0x1001d1204		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4962	0x1001d1208		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4963	0x1001d120c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4964	0x1001d1210		39404c64		MOVBU 19(R3), R4
  monolith.go:4964	0x1001d1214		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4967	0x1001d1218		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4965	0x1001d121c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4966	0x1001d1220		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4967	0x1001d1224		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4968	0x1001d1228		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4971	0x1001d122c		2d545410		FLDPS 160(R0), (F16, F21)
  monolith.go:4972	0x1001d1230		2d545c36		FLDPS 160(R1), (F22, F23)
  monolith.go:4973	0x1001d1234		39405044		MOVBU 20(R2), R4
  monolith.go:4973	0x1001d1238		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4974	0x1001d123c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4974	0x1001d1240		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:4975	0x1001d1244		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:4976	0x1001d1248		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:4977	0x1001d124c		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:4978	0x1001d1250		39405064		MOVBU 20(R3), R4
  monolith.go:4978	0x1001d1254		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4981	0x1001d1258		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4979	0x1001d125c		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:4980	0x1001d1260		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:4981	0x1001d1264		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:4982	0x1001d1268		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:4985	0x1001d126c		2d555410		FLDPS 168(R0), (F16, F21)
  monolith.go:4986	0x1001d1270		2d555c36		FLDPS 168(R1), (F22, F23)
  monolith.go:4987	0x1001d1274		39405444		MOVBU 21(R2), R4
  monolith.go:4987	0x1001d1278		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4990	0x1001d127c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4988	0x1001d1280		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:4989	0x1001d1284		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:4990	0x1001d1288		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:4991	0x1001d128c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:4992	0x1001d1290		39405464		MOVBU 21(R3), R4
  monolith.go:4992	0x1001d1294		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:4995	0x1001d1298		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:4993	0x1001d129c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:4994	0x1001d12a0		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:4995	0x1001d12a4		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:4996	0x1001d12a8		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:4999	0x1001d12ac		2d565410		FLDPS 176(R0), (F16, F21)
  monolith.go:5000	0x1001d12b0		2d565c36		FLDPS 176(R1), (F22, F23)
  monolith.go:5001	0x1001d12b4		39405844		MOVBU 22(R2), R4
  monolith.go:5001	0x1001d12b8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5002	0x1001d12bc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5002	0x1001d12c0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:5003	0x1001d12c4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:5004	0x1001d12c8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:5005	0x1001d12cc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:5006	0x1001d12d0		39405864		MOVBU 22(R3), R4
  monolith.go:5006	0x1001d12d4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5009	0x1001d12d8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5007	0x1001d12dc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:5008	0x1001d12e0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:5009	0x1001d12e4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:5010	0x1001d12e8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:5013	0x1001d12ec		2d575410		FLDPS 184(R0), (F16, F21)
  monolith.go:5014	0x1001d12f0		2d575c36		FLDPS 184(R1), (F22, F23)
  monolith.go:5015	0x1001d12f4		39405c44		MOVBU 23(R2), R4
  monolith.go:5015	0x1001d12f8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5016	0x1001d12fc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5016	0x1001d1300		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:5017	0x1001d1304		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:5018	0x1001d1308		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:5019	0x1001d130c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:5020	0x1001d1310		39405c64		MOVBU 23(R3), R4
  monolith.go:5020	0x1001d1314		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5021	0x1001d1318		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5021	0x1001d131c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:5022	0x1001d1320		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:5023	0x1001d1324		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:5024	0x1001d1328		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:5027	0x1001d132c		2d585410		FLDPS 192(R0), (F16, F21)
  monolith.go:5028	0x1001d1330		2d585c36		FLDPS 192(R1), (F22, F23)
  monolith.go:5029	0x1001d1334		39406044		MOVBU 24(R2), R4
  monolith.go:5029	0x1001d1338		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5030	0x1001d133c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5030	0x1001d1340		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:5031	0x1001d1344		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:5032	0x1001d1348		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:5033	0x1001d134c		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:5034	0x1001d1350		39406064		MOVBU 24(R3), R4
  monolith.go:5034	0x1001d1354		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5035	0x1001d1358		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5035	0x1001d135c		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:5036	0x1001d1360		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:5037	0x1001d1364		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:5038	0x1001d1368		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:5041	0x1001d136c		2d595410		FLDPS 200(R0), (F16, F21)
  monolith.go:5042	0x1001d1370		2d595c36		FLDPS 200(R1), (F22, F23)
  monolith.go:5043	0x1001d1374		39406444		MOVBU 25(R2), R4
  monolith.go:5043	0x1001d1378		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5044	0x1001d137c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5044	0x1001d1380		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:5045	0x1001d1384		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:5046	0x1001d1388		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:5047	0x1001d138c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:5048	0x1001d1390		39406464		MOVBU 25(R3), R4
  monolith.go:5048	0x1001d1394		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5049	0x1001d1398		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5049	0x1001d139c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:5050	0x1001d13a0		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:5051	0x1001d13a4		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:5052	0x1001d13a8		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:5055	0x1001d13ac		2d5a5410		FLDPS 208(R0), (F16, F21)
  monolith.go:5056	0x1001d13b0		2d5a5c36		FLDPS 208(R1), (F22, F23)
  monolith.go:5057	0x1001d13b4		39406844		MOVBU 26(R2), R4
  monolith.go:5057	0x1001d13b8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5060	0x1001d13bc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5058	0x1001d13c0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:5059	0x1001d13c4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:5060	0x1001d13c8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:5061	0x1001d13cc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:5062	0x1001d13d0		39406864		MOVBU 26(R3), R4
  monolith.go:5062	0x1001d13d4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5063	0x1001d13d8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5063	0x1001d13dc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:5064	0x1001d13e0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:5065	0x1001d13e4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:5066	0x1001d13e8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:5069	0x1001d13ec		2d5b5410		FLDPS 216(R0), (F16, F21)
  monolith.go:5070	0x1001d13f0		2d5b5c36		FLDPS 216(R1), (F22, F23)
  monolith.go:5071	0x1001d13f4		39406c44		MOVBU 27(R2), R4
  monolith.go:5071	0x1001d13f8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5074	0x1001d13fc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5072	0x1001d1400		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:5073	0x1001d1404		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:5074	0x1001d1408		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:5075	0x1001d140c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:5076	0x1001d1410		39406c64		MOVBU 27(R3), R4
  monolith.go:5076	0x1001d1414		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5079	0x1001d1418		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5077	0x1001d141c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:5078	0x1001d1420		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:5079	0x1001d1424		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:5080	0x1001d1428		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:5083	0x1001d142c		2d5c5410		FLDPS 224(R0), (F16, F21)
  monolith.go:5084	0x1001d1430		2d5c5c36		FLDPS 224(R1), (F22, F23)
  monolith.go:5085	0x1001d1434		39407044		MOVBU 28(R2), R4
  monolith.go:5085	0x1001d1438		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5088	0x1001d143c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5086	0x1001d1440		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:5087	0x1001d1444		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:5088	0x1001d1448		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:5089	0x1001d144c		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:5090	0x1001d1450		39407064		MOVBU 28(R3), R4
  monolith.go:5090	0x1001d1454		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5093	0x1001d1458		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5091	0x1001d145c		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:5092	0x1001d1460		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:5093	0x1001d1464		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:5094	0x1001d1468		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:5097	0x1001d146c		2d5d5410		FLDPS 232(R0), (F16, F21)
  monolith.go:5098	0x1001d1470		2d5d5c36		FLDPS 232(R1), (F22, F23)
  monolith.go:5099	0x1001d1474		39407444		MOVBU 29(R2), R4
  monolith.go:5099	0x1001d1478		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5102	0x1001d147c		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5100	0x1001d1480		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:5101	0x1001d1484		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:5102	0x1001d1488		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:5103	0x1001d148c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:5104	0x1001d1490		39407464		MOVBU 29(R3), R4
  monolith.go:5104	0x1001d1494		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5105	0x1001d1498		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5105	0x1001d149c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:5106	0x1001d14a0		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:5107	0x1001d14a4		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:5108	0x1001d14a8		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:5111	0x1001d14ac		2d5e5410		FLDPS 240(R0), (F16, F21)
  monolith.go:5112	0x1001d14b0		2d5e5c36		FLDPS 240(R1), (F22, F23)
  monolith.go:5113	0x1001d14b4		39407844		MOVBU 30(R2), R4
  monolith.go:5113	0x1001d14b8		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5116	0x1001d14bc		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5114	0x1001d14c0		1f102f0b		FMADDS F16, F11, F24, F11
  monolith.go:5115	0x1001d14c4		1f15332c		FMADDS F21, F12, F25, F12
  monolith.go:5116	0x1001d14c8		1f162308		FMADDS F22, F8, F24, F8
  monolith.go:5117	0x1001d14cc		1f172729		FMADDS F23, F9, F25, F9
  monolith.go:5118	0x1001d14d0		39407864		MOVBU 30(R3), R4
  monolith.go:5118	0x1001d14d4		8b040ca4		ADD R4<<3, R5, R4
  monolith.go:5121	0x1001d14d8		2d406498		FLDPS (R4), (F24, F25)
  monolith.go:5119	0x1001d14dc		1f101304		FMADDS F16, F4, F24, F4
  monolith.go:5120	0x1001d14e0		1f151725		FMADDS F21, F5, F25, F5
  monolith.go:5121	0x1001d14e4		1f161b06		FMADDS F22, F6, F24, F6
  monolith.go:5122	0x1001d14e8		1f171f27		FMADDS F23, F7, F25, F7
  monolith.go:5125	0x1001d14ec		2d5f5410		FLDPS 248(R0), (F16, F21)
  monolith.go:5126	0x1001d14f0		2d5f5c36		FLDPS 248(R1), (F22, F23)
  monolith.go:5127	0x1001d14f4		39407c40		MOVBU 31(R2), R0
  monolith.go:5127	0x1001d14f8		8b000ca0		ADD R0<<3, R5, R0
  monolith.go:5128	0x1001d14fc		2d406418		FLDPS (R0), (F24, F25)
  monolith.go:5128	0x1001d1500		1f104f13		FMADDS F16, F19, F24, F19
  monolith.go:5129	0x1001d1504		1f155334		FMADDS F21, F20, F25, F20
  monolith.go:5130	0x1001d1508		1f164711		FMADDS F22, F17, F24, F17
  monolith.go:5131	0x1001d150c		1f174b32		FMADDS F23, F18, F25, F18
  monolith.go:5132	0x1001d1510		39407c60		MOVBU 31(R3), R0
  monolith.go:5132	0x1001d1514		8b000ca0		ADD R0<<3, R5, R0
  monolith.go:5133	0x1001d1518		2d406418		FLDPS (R0), (F24, F25)
  monolith.go:5133	0x1001d151c		1f10370d		FMADDS F16, F13, F24, F13
  monolith.go:5134	0x1001d1520		1f153b2e		FMADDS F21, F14, F25, F14
  monolith.go:5135	0x1001d1524		1f163f0f		FMADDS F22, F15, F24, F15
  monolith.go:5136	0x1001d1528		1f172b2a		FMADDS F23, F10, F25, F10
  monolith.go:5138	0x1001d152c		1e2b298b		FADDS F11, F12, F11
  monolith.go:5138	0x1001d1530		1e332a8c		FADDS F19, F20, F12
  monolith.go:5138	0x1001d1534		1e2c2960		FADDS F12, F11, F0
  monolith.go:5138	0x1001d1538		1e2428a4		FADDS F4, F5, F4
  monolith.go:5138	0x1001d153c		1e2d29c5		FADDS F13, F14, F5
  monolith.go:5138	0x1001d1540		1e252881		FADDS F5, F4, F1
  monolith.go:5138	0x1001d1544		1e282924		FADDS F8, F9, F4
  monolith.go:5138	0x1001d1548		1e322a25		FADDS F18, F17, F5
  monolith.go:5138	0x1001d154c		1e2428a2		FADDS F4, F5, F2
  monolith.go:5138	0x1001d1550		1e2628e4		FADDS F6, F7, F4
  monolith.go:5138	0x1001d1554		1e2a29e5		FADDS F10, F15, F5
  monolith.go:5138	0x1001d1558		1e2428a3		FADDS F4, F5, F3
  monolith.go:5138	0x1001d155c		d65f03c0		RET

TEXT github.com/RyoSpiralArchitect/sr_go_tranformer.simdQ4Block(SB) github.com/RyoSpiralArchitect/sr_go_tranformer/kernel_test.go
  kernel_test.go:8		0x1001d1a90		4f00e404		VMOVI $0, V4.B16
  kernel_test.go:121		0x1001d1a94		4f00e485		VMOVI $4, V5.B16
  kernel_test.go:123		0x1001d1a98		4f07e786		VMOVI $252, V6.B16
  kernel_test.go:10		0x1001d1a9c		3dc00047		FMOVQ (R2), F7
  kernel_test.go:11		0x1001d1aa0		4e2544e8		VSSHL V5.B16, V7.B16, V8.B16
  kernel_test.go:11		0x1001d1aa4		4e264508		VSSHL V6.B16, V8.B16, V8.B16
  kernel_test.go:11		0x1001d1aa8		4e2644e7		VSSHL V6.B16, V7.B16, V7.B16
  kernel_test.go:15		0x1001d1aac		4e073909		VZIP1 V7.B16, V8.B16, V9.B16
  kernel_test.go:18		0x1001d1ab0		0f08a52a		VSXTL V9.B8, V10.H8
  kernel_test.go:21		0x1001d1ab4		0f10a54b		VSXTL V10.H4, V11.S4
  kernel_test.go:21		0x1001d1ab8		4e21d96b		SCVTF V11.S4, V11.S4
  kernel_test.go:31		0x1001d1abc		4f10a54a		VSXTL2 V10.H8, V10.S4
  kernel_test.go:31		0x1001d1ac0		4e21d94a		SCVTF V10.S4, V10.S4
  kernel_test.go:42		0x1001d1ac4		4f08a529		VSXTL2 V9.B16, V9.H8
  kernel_test.go:45		0x1001d1ac8		0f10a52c		VSXTL V9.H4, V12.S4
  kernel_test.go:45		0x1001d1acc		4e21d98c		SCVTF V12.S4, V12.S4
  kernel_test.go:55		0x1001d1ad0		4f10a529		VSXTL2 V9.H8, V9.S4
  kernel_test.go:55		0x1001d1ad4		4e21d929		SCVTF V9.S4, V9.S4
  kernel_test.go:67		0x1001d1ad8		4e077907		VZIP2 V7.B16, V8.B16, V7.B16
  kernel_test.go:70		0x1001d1adc		0f08a4e8		VSXTL V7.B8, V8.H8
  kernel_test.go:73		0x1001d1ae0		0f10a50d		VSXTL V8.H4, V13.S4
  kernel_test.go:73		0x1001d1ae4		4e21d9ad		SCVTF V13.S4, V13.S4
  kernel_test.go:83		0x1001d1ae8		4f10a508		VSXTL2 V8.H8, V8.S4
  kernel_test.go:83		0x1001d1aec		4e21d908		SCVTF V8.S4, V8.S4
  kernel_test.go:94		0x1001d1af0		4f08a4e7		VSXTL2 V7.B16, V7.H8
  kernel_test.go:97		0x1001d1af4		0f10a4ee		VSXTL V7.H4, V14.S4
  kernel_test.go:97		0x1001d1af8		4e21d9ce		SCVTF V14.S4, V14.S4
  kernel_test.go:107		0x1001d1afc		4f10a4e7		VSXTL2 V7.H8, V7.S4
  kernel_test.go:107		0x1001d1b00		4e21d8e7		SCVTF V7.S4, V7.S4
  kernel_test.go:12		0x1001d1b04		3dc0006f		FMOVQ (R3), F15
  kernel_test.go:13		0x1001d1b08		4e2545f0		VSSHL V5.B16, V15.B16, V16.B16
  kernel_test.go:13		0x1001d1b0c		4e264610		VSSHL V6.B16, V16.B16, V16.B16
  kernel_test.go:13		0x1001d1b10		4e2645ef		VSSHL V6.B16, V15.B16, V15.B16
  kernel_test.go:16		0x1001d1b14		4e0f3a11		VZIP1 V15.B16, V16.B16, V17.B16
  kernel_test.go:19		0x1001d1b18		0f08a632		VSXTL V17.B8, V18.H8
  kernel_test.go:22		0x1001d1b1c		0f10a653		VSXTL V18.H4, V19.S4
  kernel_test.go:22		0x1001d1b20		4e21da73		SCVTF V19.S4, V19.S4
  kernel_test.go:32		0x1001d1b24		4f10a652		VSXTL2 V18.H8, V18.S4
  kernel_test.go:32		0x1001d1b28		4e21da52		SCVTF V18.S4, V18.S4
  kernel_test.go:43		0x1001d1b2c		4f08a631		VSXTL2 V17.B16, V17.H8
  kernel_test.go:46		0x1001d1b30		0f10a634		VSXTL V17.H4, V20.S4
  kernel_test.go:46		0x1001d1b34		4e21da94		SCVTF V20.S4, V20.S4
  kernel_test.go:56		0x1001d1b38		4f10a631		VSXTL2 V17.H8, V17.S4
  kernel_test.go:56		0x1001d1b3c		4e21da31		SCVTF V17.S4, V17.S4
  kernel_test.go:68		0x1001d1b40		4e0f7a0f		VZIP2 V15.B16, V16.B16, V15.B16
  kernel_test.go:71		0x1001d1b44		0f08a5f0		VSXTL V15.B8, V16.H8
  kernel_test.go:74		0x1001d1b48		0f10a615		VSXTL V16.H4, V21.S4
  kernel_test.go:74		0x1001d1b4c		4e21dab5		SCVTF V21.S4, V21.S4
  kernel_test.go:84		0x1001d1b50		4f10a610		VSXTL2 V16.H8, V16.S4
  kernel_test.go:84		0x1001d1b54		4e21da10		SCVTF V16.S4, V16.S4
  kernel_test.go:95		0x1001d1b58		4f08a5ef		VSXTL2 V15.B16, V15.H8
  kernel_test.go:98		0x1001d1b5c		0f10a5f6		VSXTL V15.H4, V22.S4
  kernel_test.go:98		0x1001d1b60		4e21dad6		SCVTF V22.S4, V22.S4
  kernel_test.go:108		0x1001d1b64		4f10a5ef		VSXTL2 V15.H8, V15.S4
  kernel_test.go:108		0x1001d1b68		4e21d9ef		SCVTF V15.S4, V15.S4
  kernel_test.go:23		0x1001d1b6c		3dc00017		FMOVQ (R0), F23
  kernel_test.go:24		0x1001d1b70		4ea41c98		VMOV V4.B16, V24.B16
  kernel_test.go:24		0x1001d1b74		4e2bcee4		VFMLA V11.S4, V23.S4, V4.S4
  kernel_test.go:25		0x1001d1b78		4eb81f19		VMOV V24.B16, V25.B16
  kernel_test.go:25		0x1001d1b7c		4e33cef8		VFMLA V19.S4, V23.S4, V24.S4
  kernel_test.go:26		0x1001d1b80		3dc00037		FMOVQ (R1), F23
  kernel_test.go:27		0x1001d1b84		4eb91f3a		VMOV V25.B16, V26.B16
  kernel_test.go:27		0x1001d1b88		4e2bcef9		VFMLA V11.S4, V23.S4, V25.S4
  kernel_test.go:28		0x1001d1b8c		4e33cefa		VFMLA V19.S4, V23.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1b90		3dc0040b		FMOVQ 16(R0), F11
  kernel_test.go:34		0x1001d1b94		4e2acd64		VFMLA V10.S4, V11.S4, V4.S4
  kernel_test.go:35		0x1001d1b98		4e32cd78		VFMLA V18.S4, V11.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1b9c		3dc0042b		FMOVQ 16(R1), F11
  kernel_test.go:37		0x1001d1ba0		4e2acd79		VFMLA V10.S4, V11.S4, V25.S4
  kernel_test.go:38		0x1001d1ba4		4e32cd7a		VFMLA V18.S4, V11.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1ba8		3dc0080a		FMOVQ 32(R0), F10
  kernel_test.go:48		0x1001d1bac		4e2ccd44		VFMLA V12.S4, V10.S4, V4.S4
  kernel_test.go:49		0x1001d1bb0		4e34cd58		VFMLA V20.S4, V10.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1bb4		3dc0082a		FMOVQ 32(R1), F10
  kernel_test.go:51		0x1001d1bb8		4e2ccd59		VFMLA V12.S4, V10.S4, V25.S4
  kernel_test.go:52		0x1001d1bbc		4e34cd5a		VFMLA V20.S4, V10.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1bc0		3dc00c0a		FMOVQ 48(R0), F10
  kernel_test.go:58		0x1001d1bc4		4e29cd44		VFMLA V9.S4, V10.S4, V4.S4
  kernel_test.go:59		0x1001d1bc8		4e31cd58		VFMLA V17.S4, V10.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1bcc		3dc00c2a		FMOVQ 48(R1), F10
  kernel_test.go:61		0x1001d1bd0		4e29cd59		VFMLA V9.S4, V10.S4, V25.S4
  kernel_test.go:62		0x1001d1bd4		4e31cd5a		VFMLA V17.S4, V10.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1bd8		3dc01009		FMOVQ 64(R0), F9
  kernel_test.go:76		0x1001d1bdc		4e2dcd24		VFMLA V13.S4, V9.S4, V4.S4
  kernel_test.go:77		0x1001d1be0		4e35cd38		VFMLA V21.S4, V9.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1be4		3dc01029		FMOVQ 64(R1), F9
  kernel_test.go:79		0x1001d1be8		4e2dcd39		VFMLA V13.S4, V9.S4, V25.S4
  kernel_test.go:80		0x1001d1bec		4e35cd3a		VFMLA V21.S4, V9.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1bf0		3dc01409		FMOVQ 80(R0), F9
  kernel_test.go:86		0x1001d1bf4		4e28cd24		VFMLA V8.S4, V9.S4, V4.S4
  kernel_test.go:87		0x1001d1bf8		4e30cd38		VFMLA V16.S4, V9.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1bfc		3dc01429		FMOVQ 80(R1), F9
  kernel_test.go:89		0x1001d1c00		4e28cd39		VFMLA V8.S4, V9.S4, V25.S4
  kernel_test.go:90		0x1001d1c04		4e30cd3a		VFMLA V16.S4, V9.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1c08		3dc01808		FMOVQ 96(R0), F8
  kernel_test.go:100		0x1001d1c0c		4e2ecd04		VFMLA V14.S4, V8.S4, V4.S4
  kernel_test.go:101		0x1001d1c10		4e36cd18		VFMLA V22.S4, V8.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1c14		3dc01828		FMOVQ 96(R1), F8
  kernel_test.go:103		0x1001d1c18		4e2ecd19		VFMLA V14.S4, V8.S4, V25.S4
  kernel_test.go:104		0x1001d1c1c		4e36cd1a		VFMLA V22.S4, V8.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1c20		3dc01c08		FMOVQ 112(R0), F8
  kernel_test.go:110		0x1001d1c24		4e27cd04		VFMLA V7.S4, V8.S4, V4.S4
  kernel_test.go:111		0x1001d1c28		4e2fcd18		VFMLA V15.S4, V8.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1c2c		3dc01c28		FMOVQ 112(R1), F8
  kernel_test.go:113		0x1001d1c30		4e27cd19		VFMLA V7.S4, V8.S4, V25.S4
  kernel_test.go:114		0x1001d1c34		4e2fcd1a		VFMLA V15.S4, V8.S4, V26.S4
  slice_gen_arm64.go:58		0x1001d1c38		3dc00447		FMOVQ 16(R2), F7
  kernel_test.go:121		0x1001d1c3c		4e2544e8		VSSHL V5.B16, V7.B16, V8.B16
  kernel_test.go:121		0x1001d1c40		4e264508		VSSHL V6.B16, V8.B16, V8.B16
  kernel_test.go:121		0x1001d1c44		4e2644e7		VSSHL V6.B16, V7.B16, V7.B16
  kernel_test.go:125		0x1001d1c48		4e073909		VZIP1 V7.B16, V8.B16, V9.B16
  kernel_test.go:128		0x1001d1c4c		0f08a52a		VSXTL V9.B8, V10.H8
  kernel_test.go:131		0x1001d1c50		0f10a54b		VSXTL V10.H4, V11.S4
  kernel_test.go:131		0x1001d1c54		4e21d96b		SCVTF V11.S4, V11.S4
  kernel_test.go:141		0x1001d1c58		4f10a54a		VSXTL2 V10.H8, V10.S4
  kernel_test.go:141		0x1001d1c5c		4e21d94a		SCVTF V10.S4, V10.S4
  kernel_test.go:152		0x1001d1c60		4f08a529		VSXTL2 V9.B16, V9.H8
  kernel_test.go:155		0x1001d1c64		0f10a52c		VSXTL V9.H4, V12.S4
  kernel_test.go:155		0x1001d1c68		4e21d98c		SCVTF V12.S4, V12.S4
  kernel_test.go:165		0x1001d1c6c		4f10a529		VSXTL2 V9.H8, V9.S4
  kernel_test.go:165		0x1001d1c70		4e21d929		SCVTF V9.S4, V9.S4
  kernel_test.go:177		0x1001d1c74		4e077907		VZIP2 V7.B16, V8.B16, V7.B16
  kernel_test.go:180		0x1001d1c78		0f08a4e8		VSXTL V7.B8, V8.H8
  kernel_test.go:183		0x1001d1c7c		0f10a50d		VSXTL V8.H4, V13.S4
  kernel_test.go:183		0x1001d1c80		4e21d9ad		SCVTF V13.S4, V13.S4
  kernel_test.go:193		0x1001d1c84		4f10a508		VSXTL2 V8.H8, V8.S4
  kernel_test.go:193		0x1001d1c88		4e21d908		SCVTF V8.S4, V8.S4
  kernel_test.go:204		0x1001d1c8c		4f08a4e7		VSXTL2 V7.B16, V7.H8
  kernel_test.go:207		0x1001d1c90		0f10a4ee		VSXTL V7.H4, V14.S4
  kernel_test.go:207		0x1001d1c94		4e21d9ce		SCVTF V14.S4, V14.S4
  kernel_test.go:217		0x1001d1c98		4f10a4e7		VSXTL2 V7.H8, V7.S4
  kernel_test.go:217		0x1001d1c9c		4e21d8e7		SCVTF V7.S4, V7.S4
  slice_gen_arm64.go:58		0x1001d1ca0		3dc0046f		FMOVQ 16(R3), F15
  kernel_test.go:123		0x1001d1ca4		4e2545e5		VSSHL V5.B16, V15.B16, V5.B16
  kernel_test.go:123		0x1001d1ca8		4e2644a5		VSSHL V6.B16, V5.B16, V5.B16
  kernel_test.go:123		0x1001d1cac		4e2645e6		VSSHL V6.B16, V15.B16, V6.B16
  kernel_test.go:126		0x1001d1cb0		4e0638af		VZIP1 V6.B16, V5.B16, V15.B16
  kernel_test.go:129		0x1001d1cb4		0f08a5f0		VSXTL V15.B8, V16.H8
  kernel_test.go:132		0x1001d1cb8		0f10a611		VSXTL V16.H4, V17.S4
  kernel_test.go:132		0x1001d1cbc		4e21da31		SCVTF V17.S4, V17.S4
  kernel_test.go:142		0x1001d1cc0		4f10a610		VSXTL2 V16.H8, V16.S4
  kernel_test.go:142		0x1001d1cc4		4e21da10		SCVTF V16.S4, V16.S4
  kernel_test.go:153		0x1001d1cc8		4f08a5ef		VSXTL2 V15.B16, V15.H8
  kernel_test.go:156		0x1001d1ccc		0f10a5f2		VSXTL V15.H4, V18.S4
  kernel_test.go:156		0x1001d1cd0		4e21da52		SCVTF V18.S4, V18.S4
  kernel_test.go:166		0x1001d1cd4		4f10a5ef		VSXTL2 V15.H8, V15.S4
  kernel_test.go:166		0x1001d1cd8		4e21d9ef		SCVTF V15.S4, V15.S4
  kernel_test.go:178		0x1001d1cdc		4e0678a5		VZIP2 V6.B16, V5.B16, V5.B16
  kernel_test.go:181		0x1001d1ce0		0f08a4a6		VSXTL V5.B8, V6.H8
  kernel_test.go:184		0x1001d1ce4		0f10a4d3		VSXTL V6.H4, V19.S4
  kernel_test.go:184		0x1001d1ce8		4e21da73		SCVTF V19.S4, V19.S4
  kernel_test.go:194		0x1001d1cec		4f10a4c6		VSXTL2 V6.H8, V6.S4
  kernel_test.go:194		0x1001d1cf0		4e21d8c6		SCVTF V6.S4, V6.S4
  kernel_test.go:205		0x1001d1cf4		4f08a4a5		VSXTL2 V5.B16, V5.H8
  kernel_test.go:208		0x1001d1cf8		0f10a4b4		VSXTL V5.H4, V20.S4
  kernel_test.go:208		0x1001d1cfc		4e21da94		SCVTF V20.S4, V20.S4
  kernel_test.go:218		0x1001d1d00		4f10a4a5		VSXTL2 V5.H8, V5.S4
  kernel_test.go:218		0x1001d1d04		4e21d8a5		SCVTF V5.S4, V5.S4
  slice_gen_arm64.go:106	0x1001d1d08		3dc02015		FMOVQ 128(R0), F21
  kernel_test.go:134		0x1001d1d0c		4e2bcea4		VFMLA V11.S4, V21.S4, V4.S4
  kernel_test.go:135		0x1001d1d10		4e31ceb8		VFMLA V17.S4, V21.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1d14		3dc02035		FMOVQ 128(R1), F21
  kernel_test.go:137		0x1001d1d18		4e2bceb9		VFMLA V11.S4, V21.S4, V25.S4
  kernel_test.go:138		0x1001d1d1c		4e31ceba		VFMLA V17.S4, V21.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1d20		3dc0240b		FMOVQ 144(R0), F11
  kernel_test.go:144		0x1001d1d24		4e2acd64		VFMLA V10.S4, V11.S4, V4.S4
  kernel_test.go:145		0x1001d1d28		4e30cd78		VFMLA V16.S4, V11.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1d2c		3dc0242b		FMOVQ 144(R1), F11
  kernel_test.go:147		0x1001d1d30		4e2acd79		VFMLA V10.S4, V11.S4, V25.S4
  kernel_test.go:148		0x1001d1d34		4e30cd7a		VFMLA V16.S4, V11.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1d38		3dc0280a		FMOVQ 160(R0), F10
  kernel_test.go:158		0x1001d1d3c		4e2ccd44		VFMLA V12.S4, V10.S4, V4.S4
  kernel_test.go:159		0x1001d1d40		4e32cd58		VFMLA V18.S4, V10.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1d44		3dc0282a		FMOVQ 160(R1), F10
  kernel_test.go:161		0x1001d1d48		4e2ccd59		VFMLA V12.S4, V10.S4, V25.S4
  kernel_test.go:162		0x1001d1d4c		4e32cd5a		VFMLA V18.S4, V10.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1d50		3dc02c0a		FMOVQ 176(R0), F10
  kernel_test.go:168		0x1001d1d54		4e29cd44		VFMLA V9.S4, V10.S4, V4.S4
  kernel_test.go:169		0x1001d1d58		4e2fcd58		VFMLA V15.S4, V10.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1d5c		3dc02c2a		FMOVQ 176(R1), F10
  kernel_test.go:171		0x1001d1d60		4e29cd59		VFMLA V9.S4, V10.S4, V25.S4
  kernel_test.go:172		0x1001d1d64		4e2fcd5a		VFMLA V15.S4, V10.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1d68		3dc03009		FMOVQ 192(R0), F9
  kernel_test.go:186		0x1001d1d6c		4e2dcd24		VFMLA V13.S4, V9.S4, V4.S4
  kernel_test.go:187		0x1001d1d70		4e33cd38		VFMLA V19.S4, V9.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1d74		3dc03029		FMOVQ 192(R1), F9
  kernel_test.go:189		0x1001d1d78		4e2dcd39		VFMLA V13.S4, V9.S4, V25.S4
  kernel_test.go:190		0x1001d1d7c		4e33cd3a		VFMLA V19.S4, V9.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1d80		3dc03409		FMOVQ 208(R0), F9
  kernel_test.go:196		0x1001d1d84		4e28cd24		VFMLA V8.S4, V9.S4, V4.S4
  kernel_test.go:197		0x1001d1d88		4e26cd38		VFMLA V6.S4, V9.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1d8c		3dc03429		FMOVQ 208(R1), F9
  kernel_test.go:199		0x1001d1d90		4e28cd39		VFMLA V8.S4, V9.S4, V25.S4
  kernel_test.go:200		0x1001d1d94		4e26cd3a		VFMLA V6.S4, V9.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1d98		3dc03806		FMOVQ 224(R0), F6
  kernel_test.go:210		0x1001d1d9c		4e2eccc4		VFMLA V14.S4, V6.S4, V4.S4
  kernel_test.go:211		0x1001d1da0		4e34ccd8		VFMLA V20.S4, V6.S4, V24.S4
  slice_gen_arm64.go:106	0x1001d1da4		3dc03826		FMOVQ 224(R1), F6
  kernel_test.go:213		0x1001d1da8		4e2eccd9		VFMLA V14.S4, V6.S4, V25.S4
  kernel_test.go:214		0x1001d1dac		4e34ccda		VFMLA V20.S4, V6.S4, V26.S4
  slice_gen_arm64.go:106	0x1001d1db0		3dc03c06		FMOVQ 240(R0), F6
  kernel_test.go:220		0x1001d1db4		4e27ccc4		VFMLA V7.S4, V6.S4, V4.S4
  kernel_test.go:221		0x1001d1db8		4e25ccd8		VFMLA V5.S4, V6.S4, V24.S4
  kernel_test.go:229		0x1001d1dbc		6e38d484		VFADDP V24.S4, V4.S4, V4.S4
  slice_gen_arm64.go:106	0x1001d1dc0		3dc03c26		FMOVQ 240(R1), F6
  kernel_test.go:223		0x1001d1dc4		4e27ccd9		VFMLA V7.S4, V6.S4, V25.S4
  kernel_test.go:224		0x1001d1dc8		4e25ccda		VFMLA V5.S4, V6.S4, V26.S4
  kernel_test.go:229		0x1001d1dcc		6e3ad725		VFADDP V26.S4, V25.S4, V5.S4
  kernel_test.go:230		0x1001d1dd0		6e25d484		VFADDP V5.S4, V4.S4, V4.S4
  kernel_test.go:231		0x1001d1dd4		5e040480		VMOV V4.S[0], V0
  kernel_test.go:231		0x1001d1dd8		5e0c0481		VMOV V4.S[1], V1
  kernel_test.go:231		0x1001d1ddc		5e140482		VMOV V4.S[2], V2
  kernel_test.go:231		0x1001d1de0		5e1c0483		VMOV V4.S[3], V3
  kernel_test.go:33		0x1001d1de4		d503201f		NOOP
  kernel_test.go:36		0x1001d1de8		d503201f		NOOP
  kernel_test.go:47		0x1001d1dec		d503201f		NOOP
  kernel_test.go:50		0x1001d1df0		d503201f		NOOP
  kernel_test.go:57		0x1001d1df4		d503201f		NOOP
  kernel_test.go:60		0x1001d1df8		d503201f		NOOP
  kernel_test.go:75		0x1001d1dfc		d503201f		NOOP
  kernel_test.go:78		0x1001d1e00		d503201f		NOOP
  kernel_test.go:85		0x1001d1e04		d503201f		NOOP
  kernel_test.go:88		0x1001d1e08		d503201f		NOOP
  kernel_test.go:99		0x1001d1e0c		d503201f		NOOP
  kernel_test.go:102		0x1001d1e10		d503201f		NOOP
  kernel_test.go:109		0x1001d1e14		d503201f		NOOP
  kernel_test.go:112		0x1001d1e18		d503201f		NOOP
  kernel_test.go:120		0x1001d1e1c		d503201f		NOOP
  kernel_test.go:122		0x1001d1e20		d503201f		NOOP
  kernel_test.go:133		0x1001d1e24		d503201f		NOOP
  kernel_test.go:136		0x1001d1e28		d503201f		NOOP
  kernel_test.go:143		0x1001d1e2c		d503201f		NOOP
  kernel_test.go:146		0x1001d1e30		d503201f		NOOP
  kernel_test.go:157		0x1001d1e34		d503201f		NOOP
  kernel_test.go:160		0x1001d1e38		d503201f		NOOP
  kernel_test.go:167		0x1001d1e3c		d503201f		NOOP
  kernel_test.go:170		0x1001d1e40		d503201f		NOOP
  kernel_test.go:185		0x1001d1e44		d503201f		NOOP
  kernel_test.go:188		0x1001d1e48		d503201f		NOOP
  kernel_test.go:195		0x1001d1e4c		d503201f		NOOP
  kernel_test.go:198		0x1001d1e50		d503201f		NOOP
  kernel_test.go:209		0x1001d1e54		d503201f		NOOP
  kernel_test.go:212		0x1001d1e58		d503201f		NOOP
  kernel_test.go:219		0x1001d1e5c		d503201f		NOOP
  kernel_test.go:222		0x1001d1e60		d503201f		NOOP
  kernel_test.go:231		0x1001d1e64		d65f03c0		RET
  kernel_test.go:231		0x1001d1e68		00000000		?
  kernel_test.go:231		0x1001d1e6c		00000000		?

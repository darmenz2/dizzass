
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   1068c: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   10690: e28db010     	add	r11, sp, #16
   10694: e59f6108     	ldr	r6, [pc, #0x108]        @ 0x107a4 <.text+0x6a4>
   10698: e1a05000     	mov	r5, r0
   1069c: e1a04001     	mov	r4, r1
   106a0: e79f6006     	ldr	r6, [pc, r6]
   106a4: e5960000     	ldr	r0, [r6]
   106a8: e59f70f8     	ldr	r7, [pc, #0xf8]         @ 0x107a8 <.text+0x6a8>
   106ac: e2401001     	sub	r1, r0, #1
   106b0: e0000190     	mul	r0, r0, r1
   106b4: e79f7007     	ldr	r7, [pc, r7]
   106b8: e3100001     	tst	r0, #1
   106bc: 0a000002     	beq	0x106cc <.text+0x5cc>   @ imm = #0x8
   106c0: e5970000     	ldr	r0, [r7]
   106c4: e3500009     	cmp	r0, #9
   106c8: ca00000f     	bgt	0x1070c <.text+0x60c>   @ imm = #0x3c
   106cc: e3a00001     	mov	r0, #1
   106d0: e1800084     	orr	r0, r0, r4, lsl #1
   106d4: e1a01fc0     	asr	r1, r0, #31
   106d8: e0800f21     	add	r0, r0, r1, lsr #30
   106dc: e3a01001     	mov	r1, #1
   106e0: e3c00003     	bic	r0, r0, #3
   106e4: e2800004     	add	r0, r0, #4
   106e8: eb160d31     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x5834c4
   106ec: e5961000     	ldr	r1, [r6]
   106f0: e2412001     	sub	r2, r1, #1
   106f4: e0010291     	mul	r1, r1, r2
   106f8: e3110001     	tst	r1, #1
   106fc: 0a00000b     	beq	0x10730 <.text+0x630>   @ imm = #0x2c
   10700: e5971000     	ldr	r1, [r7]
   10704: e3510009     	cmp	r1, #9
   10708: da000008     	ble	0x10730 <.text+0x630>   @ imm = #0x20
   1070c: e3a00001     	mov	r0, #1
   10710: e1800084     	orr	r0, r0, r4, lsl #1
   10714: e1a01fc0     	asr	r1, r0, #31
   10718: e0800f21     	add	r0, r0, r1, lsr #30
   1071c: e3a01001     	mov	r1, #1
   10720: e3c00003     	bic	r0, r0, #3
   10724: e2800004     	add	r0, r0, #4
   10728: eb160d21     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x583484
   1072c: eaffffe6     	b	0x106cc <.text+0x5cc>   @ imm = #-0x68
   10730: e3550000     	cmp	r5, #0
   10734: 0a000011     	beq	0x10780 <.text+0x680>   @ imm = #0x44
   10738: e3540001     	cmp	r4, #1
   1073c: e1a01000     	mov	r1, r0
   10740: ba00000c     	blt	0x10778 <.text+0x678>   @ imm = #0x30
   10744: e59f2060     	ldr	r2, [pc, #0x60]         @ 0x107ac <.text+0x6ac>
   10748: e1a01000     	mov	r1, r0
   1074c: e08f2002     	add	r2, pc, r2
   10750: e5d53000     	ldrb	r3, [r5]
   10754: e2544001     	subs	r4, r4, #1
   10758: e7d23223     	ldrb	r3, [r2, r3, lsr #4]
   1075c: e5c13000     	strb	r3, [r1]
   10760: e4d53001     	ldrb	r3, [r5], #1
   10764: e203300f     	and	r3, r3, #15
   10768: e7d23003     	ldrb	r3, [r2, r3]
   1076c: e5c13001     	strb	r3, [r1, #0x1]
   10770: e2811002     	add	r1, r1, #2
   10774: 1afffff5     	bne	0x10750 <.text+0x650>   @ imm = #-0x2c
   10778: e3a02000     	mov	r2, #0
   1077c: e5c12000     	strb	r2, [r1]
   10780: e5961000     	ldr	r1, [r6]
   10784: e2412001     	sub	r2, r1, #1
   10788: e0010291     	mul	r1, r1, r2
   1078c: e3110001     	tst	r1, #1
   10790: 0a000002     	beq	0x107a0 <.text+0x6a0>   @ imm = #0x8
   10794: e5971000     	ldr	r1, [r7]
   10798: e3510009     	cmp	r1, #9
   1079c: cafffff7     	bgt	0x10780 <.text+0x680>   @ imm = #-0x24
   107a0: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
   107a4: 005cf6ec     	subseq	pc, r12, r12, ror #13
   107a8: 005ce6c0     	subseq	lr, r12, r0, asr #13
   107ac: 005cf968     	subseq	pc, r12, r8, ror #18
   107b0: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   107b4: e28db018     	add	r11, sp, #24
   107b8: e24dd008     	sub	sp, sp, #8
   107bc: e59f81a0     	ldr	r8, [pc, #0x1a0]        @ 0x10964 <.text+0x864>
   107c0: e79f8008     	ldr	r8, [pc, r8]
   107c4: e5983000     	ldr	r3, [r8]
   107c8: e2437001     	sub	r7, r3, #1
   107cc: e0030793     	mul	r3, r3, r7
   107d0: e3130001     	tst	r3, #1
   107d4: e5983000     	ldr	r3, [r8]
   107d8: e3520000     	cmp	r2, #0
   107dc: e59f5184     	ldr	r5, [pc, #0x184]        @ 0x10968 <.text+0x868>
   107e0: e1a06002     	mov	r6, r2
   107e4: e2437001     	sub	r7, r3, #1
   107e8: 13006001     	movwne	r6, #0x1
   107ec: e0070793     	mul	r7, r3, r7
   107f0: e79f5005     	ldr	r5, [pc, r5]
   107f4: e5d14000     	ldrb	r4, [r1]
   107f8: e3540000     	cmp	r4, #0
   107fc: e1a03004     	mov	r3, r4
   10800: 13003001     	movwne	r3, #0x1
   10804: e3170001     	tst	r7, #1
   10808: 0a000002     	beq	0x10818 <.text+0x718>   @ imm = #0x8
   1080c: e5957000     	ldr	r7, [r5]
   10810: e3570009     	cmp	r7, #9
   10814: caffffee     	bgt	0x107d4 <.text+0x6d4>   @ imm = #-0x48
   10818: e0163003     	ands	r3, r6, r3
   1081c: 0a000012     	beq	0x1086c <.text+0x76c>   @ imm = #0x48
   10820: e59f6144     	ldr	r6, [pc, #0x144]        @ 0x1096c <.text+0x86c>
   10824: e2811001     	add	r1, r1, #1
   10828: e08f6006     	add	r6, pc, r6
   1082c: e5d17000     	ldrb	r7, [r1]
   10830: e3570000     	cmp	r7, #0
   10834: 0a000011     	beq	0x10880 <.text+0x780>   @ imm = #0x44
   10838: e6ef3074     	uxtb	r3, r4
   1083c: e7967107     	ldr	r7, [r6, r7, lsl #2]
   10840: e7963103     	ldr	r3, [r6, r3, lsl #2]
   10844: e1874003     	orr	r4, r7, r3
   10848: e3740001     	cmn	r4, #1
   1084c: da000016     	ble	0x108ac <.text+0x7ac>   @ imm = #0x58
   10850: e1873203     	orr	r3, r7, r3, lsl #4
   10854: e4c03001     	strb	r3, [r0], #1
   10858: e5d14001     	ldrb	r4, [r1, #0x1]
   1085c: e2522001     	subs	r2, r2, #1
   10860: 12811002     	addne	r1, r1, #2
   10864: 13540000     	cmpne	r4, #0
   10868: 1affffef     	bne	0x1082c <.text+0x72c>   @ imm = #-0x44
   1086c: e1820004     	orr	r0, r2, r4
   10870: e16f0f10     	clz	r0, r0
   10874: e1a002a0     	lsr	r0, r0, #5
   10878: e24bd018     	sub	sp, r11, #24
   1087c: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   10880: e5980000     	ldr	r0, [r8]
   10884: e59f60e4     	ldr	r6, [pc, #0xe4]         @ 0x10970 <.text+0x870>
   10888: e2401001     	sub	r1, r0, #1
   1088c: e08f6006     	add	r6, pc, r6
   10890: e0000190     	mul	r0, r0, r1
   10894: e3100001     	tst	r0, #1
   10898: 0a000013     	beq	0x108ec <.text+0x7ec>   @ imm = #0x4c
   1089c: e5950000     	ldr	r0, [r5]
   108a0: e3500009     	cmp	r0, #9
   108a4: ca000023     	bgt	0x10938 <.text+0x838>   @ imm = #0x8c
   108a8: ea00000f     	b	0x108ec <.text+0x7ec>   @ imm = #0x3c
   108ac: e59f00d8     	ldr	r0, [pc, #0xd8]         @ 0x1098c <.text+0x88c>
   108b0: e3a07001     	mov	r7, #1
   108b4: e59f10d4     	ldr	r1, [pc, #0xd4]         @ 0x10990 <.text+0x890>
   108b8: e59f20d4     	ldr	r2, [pc, #0xd4]         @ 0x10994 <.text+0x894>
   108bc: e08f0000     	add	r0, pc, r0
   108c0: e59f30d0     	ldr	r3, [pc, #0xd0]         @ 0x10998 <.text+0x898>
   108c4: e08f1001     	add	r1, pc, r1
   108c8: e08f2002     	add	r2, pc, r2
   108cc: e58d7000     	str	r7, [sp]
   108d0: e08f3003     	add	r3, pc, r3
   108d4: e58d3004     	str	r3, [sp, #0x4]
   108d8: e3a030e6     	mov	r3, #230
   108dc: eb03a5f8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xe97e0
   108e0: e3a00000     	mov	r0, #0
   108e4: e24bd018     	sub	sp, r11, #24
   108e8: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   108ec: e59f0080     	ldr	r0, [pc, #0x80]         @ 0x10974 <.text+0x874>
   108f0: e3a03001     	mov	r3, #1
   108f4: e59f107c     	ldr	r1, [pc, #0x7c]         @ 0x10978 <.text+0x878>
   108f8: e59f207c     	ldr	r2, [pc, #0x7c]         @ 0x1097c <.text+0x87c>
   108fc: e08f0000     	add	r0, pc, r0
   10900: e08f1001     	add	r1, pc, r1
   10904: e88d0048     	stm	sp, {r3, r6}
   10908: e08f2002     	add	r2, pc, r2
   1090c: e3a030dc     	mov	r3, #220
   10910: eb03a5eb     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xe97ac
   10914: e5980000     	ldr	r0, [r8]
   10918: e2401001     	sub	r1, r0, #1
   1091c: e0010190     	mul	r1, r0, r1
   10920: e3a00000     	mov	r0, #0
   10924: e3110001     	tst	r1, #1
   10928: 0affffd2     	beq	0x10878 <.text+0x778>   @ imm = #-0xb8
   1092c: e5951000     	ldr	r1, [r5]
   10930: e351000a     	cmp	r1, #10
   10934: baffffcf     	blt	0x10878 <.text+0x778>   @ imm = #-0xc4
   10938: e59f0040     	ldr	r0, [pc, #0x40]         @ 0x10980 <.text+0x880>
   1093c: e3a03001     	mov	r3, #1
   10940: e59f103c     	ldr	r1, [pc, #0x3c]         @ 0x10984 <.text+0x884>
   10944: e59f203c     	ldr	r2, [pc, #0x3c]         @ 0x10988 <.text+0x888>
   10948: e08f0000     	add	r0, pc, r0
   1094c: e08f1001     	add	r1, pc, r1
   10950: e88d0048     	stm	sp, {r3, r6}
   10954: e08f2002     	add	r2, pc, r2
   10958: e3a030dc     	mov	r3, #220
   1095c: eb03a5d8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xe9760
   10960: eaffffe1     	b	0x108ec <.text+0x7ec>   @ imm = #-0x7c
   10964: 005ce8f0     	ldrsheq	lr, [r12], #-128
   10968: 005cf1b0     	ldrheq	pc, [r12], #-16
   1096c: 0059fae0     	subseq	pc, r9, r0, ror #21
   10970: 005cf83e     	subseq	pc, r12, lr, lsr r8
   10974: 005cf7c8     	subseq	pc, r12, r8, asr #15
   10978: 005cf70c     	subseq	pc, r12, r12, lsl #14
   1097c: 005cf723     	subseq	pc, r12, r3, lsr #14

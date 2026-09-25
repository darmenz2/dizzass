
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  107648: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
  10764c: e28db010     	add	r11, sp, #16
  107650: e24dd010     	sub	sp, sp, #16
  107654: e1a05000     	mov	r5, r0
  107658: e59f031c     	ldr	r0, [pc, #0x31c]        @ 0x10797c <.text+0xf787c>
  10765c: e08f0000     	add	r0, pc, r0
  107660: e5d00000     	ldrb	r0, [r0]
  107664: e3500000     	cmp	r0, #0
  107668: 0a000027     	beq	0x10770c <.text+0xf760c> @ imm = #0x9c
  10766c: e59f631c     	ldr	r6, [pc, #0x31c]        @ 0x107990 <.text+0xf7890>
  107670: e1a04001     	mov	r4, r1
  107674: e79f6006     	ldr	r6, [pc, r6]
  107678: e5960000     	ldr	r0, [r6]
  10767c: e2401001     	sub	r1, r0, #1
  107680: e0000190     	mul	r0, r0, r1
  107684: e3100001     	tst	r0, #1
  107688: e5960000     	ldr	r0, [r6]
  10768c: e59f7300     	ldr	r7, [pc, #0x300]        @ 0x107994 <.text+0xf7894>
  107690: e2401001     	sub	r1, r0, #1
  107694: e0030190     	mul	r3, r0, r1
  107698: e79f7007     	ldr	r7, [pc, r7]
  10769c: e59f12f4     	ldr	r1, [pc, #0x2f4]        @ 0x107998 <.text+0xf7898>
  1076a0: e3a00000     	mov	r0, #0
  1076a4: e79f1001     	ldr	r1, [pc, r1]
  1076a8: e1510005     	cmp	r1, r5
  1076ac: e3a01000     	mov	r1, #0
  1076b0: c3001001     	movwgt	r1, #0x1
  1076b4: e3750001     	cmn	r5, #1
  1076b8: c3000001     	movwgt	r0, #0x1
  1076bc: e3130001     	tst	r3, #1
  1076c0: 0a000002     	beq	0x1076d0 <.text+0xf75d0> @ imm = #0x8
  1076c4: e5973000     	ldr	r3, [r7]
  1076c8: e3530009     	cmp	r3, #9
  1076cc: caffffed     	bgt	0x107688 <.text+0xf7588> @ imm = #-0x4c
  1076d0: e0100001     	ands	r0, r0, r1
  1076d4: 0a000028     	beq	0x10777c <.text+0xf767c> @ imm = #0xa0
  1076d8: e3540c01     	cmp	r4, #256
  1076dc: 3a000031     	blo	0x1077a8 <.text+0xf76a8> @ imm = #0xc4
  1076e0: e5960000     	ldr	r0, [r6]
  1076e4: e59f52cc     	ldr	r5, [pc, #0x2cc]        @ 0x1079b8 <.text+0xf78b8>
  1076e8: e2401001     	sub	r1, r0, #1
  1076ec: e08f5005     	add	r5, pc, r5
  1076f0: e0000190     	mul	r0, r0, r1
  1076f4: e3100001     	tst	r0, #1
  1076f8: 0a00007f     	beq	0x1078fc <.text+0xf77fc> @ imm = #0x1fc
  1076fc: e5970000     	ldr	r0, [r7]
  107700: e3500009     	cmp	r0, #9
  107704: ca000090     	bgt	0x10794c <.text+0xf784c> @ imm = #0x240
  107708: ea00007b     	b	0x1078fc <.text+0xf77fc> @ imm = #0x1ec
  10770c: e59f026c     	ldr	r0, [pc, #0x26c]        @ 0x107980 <.text+0xf7880>
  107710: e3a07001     	mov	r7, #1
  107714: e59f1268     	ldr	r1, [pc, #0x268]        @ 0x107984 <.text+0xf7884>
  107718: e59f2268     	ldr	r2, [pc, #0x268]        @ 0x107988 <.text+0xf7888>
  10771c: e08f0000     	add	r0, pc, r0
  107720: e59f3264     	ldr	r3, [pc, #0x264]        @ 0x10798c <.text+0xf788c>
  107724: e08f1001     	add	r1, pc, r1
  107728: e08f2002     	add	r2, pc, r2
  10772c: e58d7000     	str	r7, [sp]
  107730: e08f3003     	add	r3, pc, r3
  107734: e58d3004     	str	r3, [sp, #0x4]
  107738: e3a03fc7     	mov	r3, #796
  10773c: ebffca60     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd680
  107740: e3e00000     	mvn	r0, #0
  107744: e59f129c     	ldr	r1, [pc, #0x29c]        @ 0x1079e8 <.text+0xf78e8>
  107748: e79f1001     	ldr	r1, [pc, r1]
  10774c: e59f2298     	ldr	r2, [pc, #0x298]        @ 0x1079ec <.text+0xf78ec>
  107750: e79f2002     	ldr	r2, [pc, r2]
  107754: e5913000     	ldr	r3, [r1]
  107758: e2437001     	sub	r7, r3, #1
  10775c: e0030793     	mul	r3, r3, r7
  107760: e3130001     	tst	r3, #1
  107764: 0a000002     	beq	0x107774 <.text+0xf7674> @ imm = #0x8
  107768: e5923000     	ldr	r3, [r2]
  10776c: e3530009     	cmp	r3, #9
  107770: cafffff7     	bgt	0x107754 <.text+0xf7654> @ imm = #-0x24
  107774: e24bd010     	sub	sp, r11, #16
  107778: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  10777c: e5960000     	ldr	r0, [r6]
  107780: e59f4214     	ldr	r4, [pc, #0x214]        @ 0x10799c <.text+0xf789c>
  107784: e2401001     	sub	r1, r0, #1
  107788: e08f4004     	add	r4, pc, r4
  10778c: e0000190     	mul	r0, r0, r1
  107790: e3100001     	tst	r0, #1
  107794: 0a00003a     	beq	0x107884 <.text+0xf7784> @ imm = #0xe8
  107798: e5970000     	ldr	r0, [r7]
  10779c: e3500009     	cmp	r0, #9
  1077a0: ca00004a     	bgt	0x1078d0 <.text+0xf77d0> @ imm = #0x128
  1077a4: ea000036     	b	0x107884 <.text+0xf7784> @ imm = #0xd8
  1077a8: e59fc224     	ldr	r12, [pc, #0x224]       @ 0x1079d4 <.text+0xf78d4>
  1077ac: e3a00000     	mov	r0, #0
  1077b0: e79fc00c     	ldr	r12, [pc, r12]
  1077b4: ea000002     	b	0x1077c4 <.text+0xf76c4> @ imm = #0x8
  1077b8: e2800001     	add	r0, r0, #1
  1077bc: e3500040     	cmp	r0, #64
  1077c0: 0a000020     	beq	0x107848 <.text+0xf7748> @ imm = #0x80
  1077c4: e0853305     	add	r3, r5, r5, lsl #6
  1077c8: e08c3183     	add	r3, r12, r3, lsl #3
  1077cc: e7931180     	ldr	r1, [r3, r0, lsl #3]
  1077d0: e1510004     	cmp	r1, r4
  1077d4: 0a00000c     	beq	0x10780c <.text+0xf770c> @ imm = #0x30
  1077d8: e5961000     	ldr	r1, [r6]
  1077dc: e2413001     	sub	r3, r1, #1
  1077e0: e0010391     	mul	r1, r1, r3
  1077e4: e3110001     	tst	r1, #1
  1077e8: e5961000     	ldr	r1, [r6]
  1077ec: e2413001     	sub	r3, r1, #1
  1077f0: e0010391     	mul	r1, r1, r3
  1077f4: e3110001     	tst	r1, #1
  1077f8: 0affffee     	beq	0x1077b8 <.text+0xf76b8> @ imm = #-0x48
  1077fc: e5971000     	ldr	r1, [r7]
  107800: e3510009     	cmp	r1, #9
  107804: cafffff7     	bgt	0x1077e8 <.text+0xf76e8> @ imm = #-0x24
  107808: eaffffea     	b	0x1077b8 <.text+0xf76b8> @ imm = #-0x58
  10780c: e0831180     	add	r1, r3, r0, lsl #3
  107810: e5812004     	str	r2, [r1, #0x4]
  107814: e5931204     	ldr	r1, [r3, #0x204]
  107818: e3510001     	cmp	r1, #1
  10781c: ba000016     	blt	0x10787c <.text+0xf777c> @ imm = #0x58
  107820: e5933200     	ldr	r3, [r3, #0x200]
  107824: e3a07000     	mov	r7, #0
  107828: e0830180     	add	r0, r3, r0, lsl #3
  10782c: e2803004     	add	r3, r0, #4
  107830: e3a00000     	mov	r0, #0
  107834: e7832487     	str	r2, [r3, r7, lsl #9]
  107838: e2877001     	add	r7, r7, #1
  10783c: e1570001     	cmp	r7, r1
  107840: bafffffb     	blt	0x107834 <.text+0xf7734> @ imm = #-0x14
  107844: eaffffbe     	b	0x107744 <.text+0xf7644> @ imm = #-0x108
  107848: e59f0188     	ldr	r0, [pc, #0x188]        @ 0x1079d8 <.text+0xf78d8>
  10784c: e3a07001     	mov	r7, #1
  107850: e59f1184     	ldr	r1, [pc, #0x184]        @ 0x1079dc <.text+0xf78dc>
  107854: e59f2184     	ldr	r2, [pc, #0x184]        @ 0x1079e0 <.text+0xf78e0>
  107858: e08f0000     	add	r0, pc, r0
  10785c: e59f3180     	ldr	r3, [pc, #0x180]        @ 0x1079e4 <.text+0xf78e4>
  107860: e08f1001     	add	r1, pc, r1
  107864: e08f2002     	add	r2, pc, r2
  107868: e58d7000     	str	r7, [sp]
  10786c: e08f3003     	add	r3, pc, r3
  107870: e98d0018     	stmib	sp, {r3, r4}
  107874: e300332e     	movw	r3, #0x32e
  107878: eaffffaf     	b	0x10773c <.text+0xf763c> @ imm = #-0x144
  10787c: e3a00000     	mov	r0, #0
  107880: eaffffaf     	b	0x107744 <.text+0xf7644> @ imm = #-0x144
  107884: e59f0114     	ldr	r0, [pc, #0x114]        @ 0x1079a0 <.text+0xf78a0>
  107888: e3a03001     	mov	r3, #1
  10788c: e59f1110     	ldr	r1, [pc, #0x110]        @ 0x1079a4 <.text+0xf78a4>
  107890: e59f2110     	ldr	r2, [pc, #0x110]        @ 0x1079a8 <.text+0xf78a8>
  107894: e08f0000     	add	r0, pc, r0
  107898: e08f1001     	add	r1, pc, r1
  10789c: e88d0038     	stm	sp, {r3, r4, r5}
  1078a0: e08f2002     	add	r2, pc, r2
  1078a4: e3003321     	movw	r3, #0x321
  1078a8: ebffca05     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd7ec
  1078ac: e5960000     	ldr	r0, [r6]
  1078b0: e2401001     	sub	r1, r0, #1
  1078b4: e0010190     	mul	r1, r0, r1
  1078b8: e3e00000     	mvn	r0, #0
  1078bc: e3110001     	tst	r1, #1
  1078c0: 0affff9f     	beq	0x107744 <.text+0xf7644> @ imm = #-0x184
  1078c4: e5971000     	ldr	r1, [r7]
  1078c8: e351000a     	cmp	r1, #10
  1078cc: baffff9c     	blt	0x107744 <.text+0xf7644> @ imm = #-0x190
  1078d0: e59f00d4     	ldr	r0, [pc, #0xd4]         @ 0x1079ac <.text+0xf78ac>
  1078d4: e3a03001     	mov	r3, #1
  1078d8: e59f10d0     	ldr	r1, [pc, #0xd0]         @ 0x1079b0 <.text+0xf78b0>
  1078dc: e59f20d0     	ldr	r2, [pc, #0xd0]         @ 0x1079b4 <.text+0xf78b4>
  1078e0: e08f0000     	add	r0, pc, r0
  1078e4: e08f1001     	add	r1, pc, r1
  1078e8: e88d0038     	stm	sp, {r3, r4, r5}
  1078ec: e08f2002     	add	r2, pc, r2
  1078f0: e3003321     	movw	r3, #0x321
  1078f4: ebffc9f2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd838
  1078f8: eaffffe1     	b	0x107884 <.text+0xf7784> @ imm = #-0x7c
  1078fc: e59f00b8     	ldr	r0, [pc, #0xb8]         @ 0x1079bc <.text+0xf78bc>
  107900: e3a03001     	mov	r3, #1
  107904: e59f10b4     	ldr	r1, [pc, #0xb4]         @ 0x1079c0 <.text+0xf78c0>
  107908: e59f20b4     	ldr	r2, [pc, #0xb4]         @ 0x1079c4 <.text+0xf78c4>
  10790c: e08f0000     	add	r0, pc, r0
  107910: e08f1001     	add	r1, pc, r1
  107914: e88d0028     	stm	sp, {r3, r5}
  107918: e08f2002     	add	r2, pc, r2
  10791c: e3003326     	movw	r3, #0x326
  107920: e58d4008     	str	r4, [sp, #0x8]
  107924: ebffc9e6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd868
  107928: e5960000     	ldr	r0, [r6]
  10792c: e2401001     	sub	r1, r0, #1
  107930: e0010190     	mul	r1, r0, r1
  107934: e3e00000     	mvn	r0, #0
  107938: e3110001     	tst	r1, #1
  10793c: 0affff80     	beq	0x107744 <.text+0xf7644> @ imm = #-0x200
  107940: e5971000     	ldr	r1, [r7]
  107944: e351000a     	cmp	r1, #10
  107948: baffff7d     	blt	0x107744 <.text+0xf7644> @ imm = #-0x20c
  10794c: e59f0074     	ldr	r0, [pc, #0x74]         @ 0x1079c8 <.text+0xf78c8>
  107950: e3a03001     	mov	r3, #1
  107954: e59f1070     	ldr	r1, [pc, #0x70]         @ 0x1079cc <.text+0xf78cc>
  107958: e59f2070     	ldr	r2, [pc, #0x70]         @ 0x1079d0 <.text+0xf78d0>
  10795c: e08f0000     	add	r0, pc, r0
  107960: e08f1001     	add	r1, pc, r1
  107964: e88d0028     	stm	sp, {r3, r5}
  107968: e08f2002     	add	r2, pc, r2
  10796c: e3003326     	movw	r3, #0x326
  107970: e58d4008     	str	r4, [sp, #0x8]
  107974: ebffc9d2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd8b8
  107978: eaffffdf     	b	0x1078fc <.text+0xf77fc> @ imm = #-0x84
  10797c: 0054d70c     	subseq	sp, r4, r12, lsl #14
  107980: 004e5d47     	subeq	r5, lr, r7, asr #26
  107984: 004e5d46     	subeq	r5, lr, r6, asr #26
  107988: 004e5d68     	subeq	r5, lr, r8, ror #26
  10798c: 004e5dd0     	ldrdeq	r5, r6, [lr], #-208
  107990: 004d82e4     	subeq	r8, sp, r4, ror #5
  107994: 004d8680     	subeq	r8, sp, r0, lsl #13
  107998: 0054d6c0     	subseq	sp, r4, r0, asr #13
  10799c: 004e5d92     	umaaleq	r5, lr, r2, sp
  1079a0: 004e5bcf     	subeq	r5, lr, pc, asr #23
  1079a4: 004e5bd2     	ldrdeq	r5, r6, [lr], #-178
  1079a8: 004e5bf0     	strdeq	r5, r6, [lr], #-176
  1079ac: 004e5b83     	subeq	r5, lr, r3, lsl #23
  1079b0: 004e5b86     	subeq	r5, lr, r6, lsl #23
  1079b4: 004e5ba4     	subeq	r5, lr, r4, lsr #23
  1079b8: 004e5e44     	subeq	r5, lr, r4, asr #28
  1079bc: 004e5b57     	subeq	r5, lr, r7, asr r11
  1079c0: 004e5b5a     	subeq	r5, lr, r10, asr r11
  1079c4: 004e5b78     	subeq	r5, lr, r8, ror r11
  1079c8: 004e5b07     	subeq	r5, lr, r7, lsl #22
  1079cc: 004e5b0a     	subeq	r5, lr, r10, lsl #22
  1079d0: 004e5b28     	subeq	r5, lr, r8, lsr #22
  1079d4: 0054d5b0     	ldrheq	sp, [r4], #-80
  1079d8: 004e5c0b     	subeq	r5, lr, r11, lsl #24
  1079dc: 004e5c0a     	subeq	r5, lr, r10, lsl #24
  1079e0: 004e5c2c     	subeq	r5, lr, r12, lsr #24
  1079e4: 004e5ce9     	subeq	r5, lr, r9, ror #25
  1079e8: 004d8210     	subeq	r8, sp, r0, lsl r2
  1079ec: 004d85c8     	subeq	r8, sp, r8, asr #11

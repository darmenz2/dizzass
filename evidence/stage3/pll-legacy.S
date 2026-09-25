
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ff288: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   ff28c: e28db01c     	add	r11, sp, #28
   ff290: e24dd004     	sub	sp, sp, #4
   ff294: ed2d8b06     	vpush	{d8, d9, d10}
   ff298: e24dd030     	sub	sp, sp, #48
   ff29c: e3a02000     	mov	r2, #0
   ff2a0: e58d1014     	str	r1, [sp, #0x14]
   ff2a4: e5812018     	str	r2, [r1, #0x18]
   ff2a8: e5812010     	str	r2, [r1, #0x10]
   ff2ac: e5812008     	str	r2, [r1, #0x8]
   ff2b0: e5812000     	str	r2, [r1]
   ff2b4: e5906020     	ldr	r6, [r0, #0x20]
   ff2b8: e581201c     	str	r2, [r1, #0x1c]
   ff2bc: e3560001     	cmp	r6, #1
   ff2c0: e5812014     	str	r2, [r1, #0x14]
   ff2c4: e581200c     	str	r2, [r1, #0xc]
   ff2c8: e5812004     	str	r2, [r1, #0x4]
   ff2cc: ba0000be     	blt	0xff5cc <.text+0xef4cc> @ imm = #0x2f8
   ff2d0: e59f3370     	ldr	r3, [pc, #0x370]        @ 0xff648 <.text+0xef548>
   ff2d4: e79f3003     	ldr	r3, [pc, r3]
   ff2d8: e5931000     	ldr	r1, [r3]
   ff2dc: e2412001     	sub	r2, r1, #1
   ff2e0: e0010291     	mul	r1, r1, r2
   ff2e4: e3110001     	tst	r1, #1
   ff2e8: e5931000     	ldr	r1, [r3]
   ff2ec: e2412001     	sub	r2, r1, #1
   ff2f0: e0010291     	mul	r1, r1, r2
   ff2f4: e59f2350     	ldr	r2, [pc, #0x350]        @ 0xff64c <.text+0xef54c>
   ff2f8: e79f2002     	ldr	r2, [pc, r2]
   ff2fc: e5905028     	ldr	r5, [r0, #0x28]
   ff300: ed904b0c     	vldr	d4, [r0, #48]
   ff304: e3110001     	tst	r1, #1
   ff308: 0a000002     	beq	0xff318 <.text+0xef218> @ imm = #0x8
   ff30c: e5921000     	ldr	r1, [r2]
   ff310: e3510009     	cmp	r1, #9
   ff314: cafffff3     	bgt	0xff2e8 <.text+0xef1e8> @ imm = #-0x34
   ff318: e3a01000     	mov	r1, #0
   ff31c: ed9f1bc3     	vldr	d1, [pc, #780]          @ 0xff630 <.text+0xef530>
   ff320: e58d1020     	str	r1, [sp, #0x20]
   ff324: e3a01000     	mov	r1, #0
   ff328: ed9f2bc2     	vldr	d2, [pc, #776]          @ 0xff638 <.text+0xef538>
   ff32c: e3a07000     	mov	r7, #0
   ff330: ed9f3bc2     	vldr	d3, [pc, #776]          @ 0xff640 <.text+0xef540>
   ff334: e58d1024     	str	r1, [sp, #0x24]
   ff338: e3a01000     	mov	r1, #0
   ff33c: e58d7028     	str	r7, [sp, #0x28]
   ff340: e58d5010     	str	r5, [sp, #0x10]
   ff344: ea000003     	b	0xff358 <.text+0xef258> @ imm = #0xc
   ff348: e59d602c     	ldr	r6, [sp, #0x2c]
   ff34c: e2466001     	sub	r6, r6, #1
   ff350: e3560000     	cmp	r6, #0
   ff354: da000095     	ble	0xff5b0 <.text+0xef4b0> @ imm = #0x254
   ff358: e3550001     	cmp	r5, #1
   ff35c: e58d602c     	str	r6, [sp, #0x2c]
   ff360: bafffff8     	blt	0xff348 <.text+0xef248> @ imm = #-0x20
   ff364: e1a0c001     	mov	r12, r1
   ff368: e5931000     	ldr	r1, [r3]
   ff36c: e2417001     	sub	r7, r1, #1
   ff370: e0010791     	mul	r1, r1, r7
   ff374: e3110001     	tst	r1, #1
   ff378: e5931000     	ldr	r1, [r3]
   ff37c: ee056a10     	vmov	s10, r6
   ff380: e2417001     	sub	r7, r1, #1
   ff384: eeb85bc5     	vcvt.f64.s32	d5, s10
   ff388: e0010791     	mul	r1, r1, r7
   ff38c: e3110001     	tst	r1, #1
   ff390: 0a000002     	beq	0xff3a0 <.text+0xef2a0> @ imm = #0x8
   ff394: e5921000     	ldr	r1, [r2]
   ff398: e3510009     	cmp	r1, #9
   ff39c: cafffff5     	bgt	0xff378 <.text+0xef278> @ imm = #-0x2c
   ff3a0: e3a06003     	mov	r6, #3
   ff3a4: e3a07001     	mov	r7, #1
   ff3a8: e1a04005     	mov	r4, r5
   ff3ac: e3a0e001     	mov	lr, #1
   ff3b0: e1a0100c     	mov	r1, r12
   ff3b4: ea00000b     	b	0xff3e8 <.text+0xef2e8> @ imm = #0x2c
   ff3b8: e59d601c     	ldr	r6, [sp, #0x1c]
   ff3bc: e1a0c001     	mov	r12, r1
   ff3c0: e59d7018     	ldr	r7, [sp, #0x18]
   ff3c4: e28e1001     	add	r1, lr, #1
   ff3c8: e59d5010     	ldr	r5, [sp, #0x10]
   ff3cc: e2444001     	sub	r4, r4, #1
   ff3d0: e0877006     	add	r7, r7, r6
   ff3d4: e2866002     	add	r6, r6, #2
   ff3d8: e15e0005     	cmp	lr, r5
   ff3dc: e1a0e001     	mov	lr, r1
   ff3e0: e1a0100c     	mov	r1, r12
   ff3e4: aaffffd7     	bge	0xff348 <.text+0xef248> @ imm = #-0xa4
   ff3e8: e15e0005     	cmp	lr, r5
   ff3ec: e58d601c     	str	r6, [sp, #0x1c]
   ff3f0: e58d7018     	str	r7, [sp, #0x18]
   ff3f4: caffffef     	bgt	0xff3b8 <.text+0xef2b8> @ imm = #-0x44
   ff3f8: ee06ea10     	vmov	s12, lr
   ff3fc: e3a0a000     	mov	r10, #0
   ff400: eeb86bc6     	vcvt.f64.s32	d6, s12
   ff404: e5909024     	ldr	r9, [r0, #0x24]
   ff408: ed907b00     	vldr	d7, [r0]
   ff40c: ea000003     	b	0xff420 <.text+0xef320> @ imm = #0xc
   ff410: e28aa001     	add	r10, r10, #1
   ff414: e087700e     	add	r7, r7, lr
   ff418: e154000a     	cmp	r4, r10
   ff41c: 0affffe5     	beq	0xff3b8 <.text+0xef2b8> @ imm = #-0x6c
   ff420: e5936000     	ldr	r6, [r3]
   ff424: e08e800a     	add	r8, lr, r10
   ff428: e2465001     	sub	r5, r6, #1
   ff42c: e0060596     	mul	r6, r6, r5
   ff430: e3160001     	tst	r6, #1
   ff434: ee088a10     	vmov	s16, r8
   ff438: eeb88bc8     	vcvt.f64.s32	d8, s16
   ff43c: ee288b00     	vmul.f64	d8, d8, d0
   ff440: ee288b06     	vmul.f64	d8, d8, d6
   ff444: ee288b05     	vmul.f64	d8, d8, d5
   ff448: ee888b07     	vdiv.f64	d8, d8, d7
   ff44c: eebd8bc8     	vcvt.s32.f64	s16, d8
   ff450: ee18ca10     	vmov	r12, s16
   ff454: eeb88bc8     	vcvt.f64.s32	d8, s16
   ff458: e5935000     	ldr	r5, [r3]
   ff45c: e2456001     	sub	r6, r5, #1
   ff460: e0050695     	mul	r5, r5, r6
   ff464: e3150001     	tst	r5, #1
   ff468: 0a000002     	beq	0xff478 <.text+0xef378> @ imm = #0x8
   ff46c: e5925000     	ldr	r5, [r2]
   ff470: e3550009     	cmp	r5, #9
   ff474: caffffee     	bgt	0xff434 <.text+0xef334> @ imm = #-0x48
   ff478: e159000c     	cmp	r9, r12
   ff47c: baffffe3     	blt	0xff410 <.text+0xef310> @ imm = #-0x74
   ff480: ee278b08     	vmul.f64	d8, d7, d8
   ff484: e5935000     	ldr	r5, [r3]
   ff488: e2456001     	sub	r6, r5, #1
   ff48c: e0050695     	mul	r5, r5, r6
   ff490: e3150001     	tst	r5, #1
   ff494: ee888b05     	vdiv.f64	d8, d8, d5
   ff498: e5935000     	ldr	r5, [r3]
   ff49c: ed909b06     	vldr	d9, [r0, #24]
   ff4a0: e2456001     	sub	r6, r5, #1
   ff4a4: e0050695     	mul	r5, r5, r6
   ff4a8: e3150001     	tst	r5, #1
   ff4ac: 0a000002     	beq	0xff4bc <.text+0xef3bc> @ imm = #0x8
   ff4b0: e5925000     	ldr	r5, [r2]
   ff4b4: e3550009     	cmp	r5, #9
   ff4b8: cafffff6     	bgt	0xff498 <.text+0xef398> @ imm = #-0x28
   ff4bc: ee399b01     	vadd.f64	d9, d9, d1
   ff4c0: eeb48bc9     	vcmpe.f64	d8, d9
   ff4c4: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff4c8: 4affffd0     	bmi	0xff410 <.text+0xef310> @ imm = #-0xc0
   ff4cc: eeb48bc3     	vcmpe.f64	d8, d3
   ff4d0: e59d502c     	ldr	r5, [sp, #0x2c]
   ff4d4: e3a06000     	mov	r6, #0
   ff4d8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff4dc: ed909b02     	vldr	d9, [r0, #8]
   ff4e0: ee399b02     	vadd.f64	d9, d9, d2
   ff4e4: eeb48bc9     	vcmpe.f64	d8, d9
   ff4e8: c3006001     	movwgt	r6, #0x1
   ff4ec: e2555001     	subs	r5, r5, #1
   ff4f0: 13005001     	movwne	r5, #0x1
   ff4f4: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff4f8: caffffc4     	bgt	0xff410 <.text+0xef310> @ imm = #-0xf0
   ff4fc: e0155006     	ands	r5, r5, r6
   ff500: 1affffc2     	bne	0xff410 <.text+0xef310> @ imm = #-0xf8
   ff504: ee097a10     	vmov	s18, r7
   ff508: eeb89bc9     	vcvt.f64.s32	d9, s18
   ff50c: e59d5028     	ldr	r5, [sp, #0x28]
   ff510: e3550001     	cmp	r5, #1
   ff514: ee889b09     	vdiv.f64	d9, d8, d9
   ff518: ee309b49     	vsub.f64	d9, d0, d9
   ff51c: eeb09bc9     	vabs.f64	d9, d9
   ff520: ba000003     	blt	0xff534 <.text+0xef434> @ imm = #0xc
   ff524: e3510001     	cmp	r1, #1
   ff528: a59d5024     	ldrge	r5, [sp, #0x24]
   ff52c: a3550001     	cmpge	r5, #1
   ff530: aa000011     	bge	0xff57c <.text+0xef47c> @ imm = #0x44
   ff534: eeb49bc2     	vcmpe.f64	d9, d2
   ff538: e59d5014     	ldr	r5, [sp, #0x14]
   ff53c: e59d602c     	ldr	r6, [sp, #0x2c]
   ff540: e3a01001     	mov	r1, #1
   ff544: e5856008     	str	r6, [r5, #0x8]
   ff548: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff54c: e585c00c     	str	r12, [r5, #0xc]
   ff550: e5858010     	str	r8, [r5, #0x10]
   ff554: e585e014     	str	lr, [r5, #0x14]
   ff558: e5851018     	str	r1, [r5, #0x18]
   ff55c: ed858b00     	vstr	d8, [r5]
   ff560: 4a00000d     	bmi	0xff59c <.text+0xef49c> @ imm = #0x34
   ff564: eeb04b49     	vmov.f64	d4, d9
   ff568: e1a0100c     	mov	r1, r12
   ff56c: e58de020     	str	lr, [sp, #0x20]
   ff570: e58d8024     	str	r8, [sp, #0x24]
   ff574: e58d6028     	str	r6, [sp, #0x28]
   ff578: eaffffa4     	b	0xff410 <.text+0xef310> @ imm = #-0x170
   ff57c: ee34ab02     	vadd.f64	d10, d4, d2
   ff580: eeb49bca     	vcmpe.f64	d9, d10
   ff584: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff588: 4affffe9     	bmi	0xff534 <.text+0xef434> @ imm = #-0x5c
   ff58c: e59d5020     	ldr	r5, [sp, #0x20]
   ff590: e3550000     	cmp	r5, #0
   ff594: caffff9d     	bgt	0xff410 <.text+0xef310> @ imm = #-0x18c
   ff598: eaffffe5     	b	0xff534 <.text+0xef434> @ imm = #-0x6c
   ff59c: e1a0100c     	mov	r1, r12
   ff5a0: e08e000a     	add	r0, lr, r10
   ff5a4: e58d0024     	str	r0, [sp, #0x24]
   ff5a8: e58de020     	str	lr, [sp, #0x20]
   ff5ac: e58d6028     	str	r6, [sp, #0x28]
   ff5b0: e59d0028     	ldr	r0, [sp, #0x28]
   ff5b4: e3500001     	cmp	r0, #1
   ff5b8: ba000003     	blt	0xff5cc <.text+0xef4cc> @ imm = #0xc
   ff5bc: e3510001     	cmp	r1, #1
   ff5c0: a59d0024     	ldrge	r0, [sp, #0x24]
   ff5c4: a3500001     	cmpge	r0, #1
   ff5c8: aa000012     	bge	0xff618 <.text+0xef518> @ imm = #0x48
   ff5cc: e59f007c     	ldr	r0, [pc, #0x7c]         @ 0xff650 <.text+0xef550>
   ff5d0: e3a07001     	mov	r7, #1
   ff5d4: e59f1078     	ldr	r1, [pc, #0x78]         @ 0xff654 <.text+0xef554>
   ff5d8: e59f2078     	ldr	r2, [pc, #0x78]         @ 0xff658 <.text+0xef558>
   ff5dc: e08f0000     	add	r0, pc, r0
   ff5e0: e59f3074     	ldr	r3, [pc, #0x74]         @ 0xff65c <.text+0xef55c>
   ff5e4: e08f1001     	add	r1, pc, r1
   ff5e8: e08f2002     	add	r2, pc, r2
   ff5ec: ed8d0b02     	vstr	d0, [sp, #8]
   ff5f0: e08f3003     	add	r3, pc, r3
   ff5f4: e58d3004     	str	r3, [sp, #0x4]
   ff5f8: e3a03049     	mov	r3, #73
   ff5fc: e58d7000     	str	r7, [sp]
   ff600: ebffeaaf     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x5544
   ff604: e3e00000     	mvn	r0, #0
   ff608: e24bd038     	sub	sp, r11, #56
   ff60c: ecbd8b06     	vpop	{d8, d9, d10}
   ff610: e28dd004     	add	sp, sp, #4
   ff614: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   ff618: e59d1020     	ldr	r1, [sp, #0x20]
   ff61c: e3a00000     	mov	r0, #0
   ff620: e3510000     	cmp	r1, #0
   ff624: cafffff7     	bgt	0xff608 <.text+0xef508> @ imm = #-0x24
   ff628: eaffffe7     	b	0xff5cc <.text+0xef4cc> @ imm = #-0x64
   ff62c: e320f000     	nop
   ff630: 9999999a     	ldmibls	r9, {r1, r3, r4, r7, r8, r11, r12, pc}
   ff634: bfb99999     	svclt	#0xb99999
   ff638: 9999999a     	ldmibls	r9, {r1, r3, r4, r7, r8, r11, r12, pc}
   ff63c: 3fb99999     	svclo	#0xb99999
   ff640: 33333333     	teqlo	r3, #-872415232
   ff644: 40a86a33     	adcmi	r6, r8, r3, lsr r10
   ff648: 004dfb50     	subeq	pc, sp, r0, asr r11
   ff64c: 004e00a0     	subeq	r0, lr, r0, lsr #1
   ff650: 004edb2e     	subeq	sp, lr, lr, lsr #22
   ff654: 004edb2d     	subeq	sp, lr, sp, lsr #22
   ff658: 004edb49     	subeq	sp, lr, r9, asr #22
   ff65c: 004edb4c     	subeq	sp, lr, r12, asr #22

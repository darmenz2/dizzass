
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  10e000: e7d30002     	ldrb	r0, [r3, r2]
  10e004: e2200078     	eor	r0, r0, #120
  10e008: e7c30002     	strb	r0, [r3, r2]
  10e00c: eaffffef     	b	0x10dfd0 <.text+0xfded0> @ imm = #-0x44
  10e010: e3a02000     	mov	r2, #0
  10e014: e3520000     	cmp	r2, #0
  10e018: 1a000007     	bne	0x10e03c <.text+0xfdf3c> @ imm = #0x1c
  10e01c: e59f309c     	ldr	r3, [pc, #0x9c]         @ 0x10e0c0 <.text+0xfdfc0>
  10e020: e08f3003     	add	r3, pc, r3
  10e024: e7d30002     	ldrb	r0, [r3, r2]
  10e028: e2200037     	eor	r0, r0, #55
  10e02c: e7c30002     	strb	r0, [r3, r2]
  10e030: e2822001     	add	r2, r2, #1
  10e034: e3520020     	cmp	r2, #32
  10e038: 1afffff9     	bne	0x10e024 <.text+0xfdf24> @ imm = #-0x1c
  10e03c: e59c0000     	ldr	r0, [r12]
  10e040: e2401001     	sub	r1, r0, #1
  10e044: e0000190     	mul	r0, r0, r1
  10e048: e3100001     	tst	r0, #1
  10e04c: e59c0000     	ldr	r0, [r12]
  10e050: e2401001     	sub	r1, r0, #1
  10e054: e0000190     	mul	r0, r0, r1
  10e058: e3100001     	tst	r0, #1
  10e05c: 0a000002     	beq	0x10e06c <.text+0xfdf6c> @ imm = #0x8
  10e060: e59e0000     	ldr	r0, [lr]
  10e064: e3500009     	cmp	r0, #9
  10e068: cafffff7     	bgt	0x10e04c <.text+0xfdf4c> @ imm = #-0x24
  10e06c: e3a00000     	mov	r0, #0
  10e070: e3500000     	cmp	r0, #0
  10e074: 18bd8800     	popne	{r11, pc}
  10e078: e59f1044     	ldr	r1, [pc, #0x44]         @ 0x10e0c4 <.text+0xfdfc4>
  10e07c: e08f1001     	add	r1, pc, r1
  10e080: e7d12000     	ldrb	r2, [r1, r0]
  10e084: e22220b4     	eor	r2, r2, #180
  10e088: e7c12000     	strb	r2, [r1, r0]
  10e08c: e2800001     	add	r0, r0, #1
  10e090: e3500021     	cmp	r0, #33
  10e094: 1afffff9     	bne	0x10e080 <.text+0xfdf80> @ imm = #-0x1c
  10e098: e8bd8800     	pop	{r11, pc}
  10e09c: 004d0918     	subeq	r0, sp, r8, lsl r9
  10e0a0: 004d1974     	subeq	r1, sp, r4, ror r9
  10e0a4: 004dfd48     	subeq	pc, sp, r8, asr #26
  10e0a8: 004dfc9b     	umaaleq	pc, sp, r11, r12
  10e0ac: 004dfc93     	umaaleq	pc, sp, r3, r12
  10e0b0: 004dfc42     	subeq	pc, sp, r2, asr #24
  10e0b4: 004dfc36     	subeq	pc, sp, r6, lsr r12
  10e0b8: 004dfc16     	subeq	pc, sp, r6, lsl r12
  10e0bc: 004dfbb1     	strheq	pc, [sp], #-177
  10e0c0: 004dfb4f     	subeq	pc, sp, pc, asr #22
  10e0c4: 004dfb13     	subeq	pc, sp, r3, lsl r11
  10e0c8: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  10e0cc: e28db01c     	add	r11, sp, #28
  10e0d0: e24dd004     	sub	sp, sp, #4
  10e0d4: e59f93cc     	ldr	r9, [pc, #0x3cc]        @ 0x10e4a8 <.text+0xfe3a8>
  10e0d8: e1a04000     	mov	r4, r0
  10e0dc: e1a05001     	mov	r5, r1
  10e0e0: e79f9009     	ldr	r9, [pc, r9]
  10e0e4: e5990000     	ldr	r0, [r9]
  10e0e8: e59f83bc     	ldr	r8, [pc, #0x3bc]        @ 0x10e4ac <.text+0xfe3ac>
  10e0ec: e2401001     	sub	r1, r0, #1
  10e0f0: e0000190     	mul	r0, r0, r1
  10e0f4: e79f8008     	ldr	r8, [pc, r8]
  10e0f8: e3100001     	tst	r0, #1
  10e0fc: 0a000002     	beq	0x10e10c <.text+0xfe00c> @ imm = #0x8
  10e100: e5980000     	ldr	r0, [r8]
  10e104: e3500009     	cmp	r0, #9
  10e108: ca00000d     	bgt	0x10e144 <.text+0xfe044> @ imm = #0x34
  10e10c: e24d6030     	sub	r6, sp, #48
  10e110: e1a0d006     	mov	sp, r6
  10e114: e1a00005     	mov	r0, r5
  10e118: e3001902     	movw	r1, #0x902
  10e11c: eb12156e     	bl	0x5936dc <.text+0x5835dc> @ imm = #0x4855b8
  10e120: e1a07000     	mov	r7, r0
  10e124: e5990000     	ldr	r0, [r9]
  10e128: e2401001     	sub	r1, r0, #1
  10e12c: e0000190     	mul	r0, r0, r1
  10e130: e3100001     	tst	r0, #1
  10e134: 0a000007     	beq	0x10e158 <.text+0xfe058> @ imm = #0x1c
  10e138: e5980000     	ldr	r0, [r8]
  10e13c: e3500009     	cmp	r0, #9
  10e140: da000004     	ble	0x10e158 <.text+0xfe058> @ imm = #0x10
  10e144: e24dd030     	sub	sp, sp, #48
  10e148: e1a00005     	mov	r0, r5
  10e14c: e3001902     	movw	r1, #0x902
  10e150: eb121561     	bl	0x5936dc <.text+0x5835dc> @ imm = #0x485584
  10e154: eaffffec     	b	0x10e10c <.text+0xfe00c> @ imm = #-0x50
  10e158: e3770001     	cmn	r7, #1
  10e15c: da00000c     	ble	0x10e194 <.text+0xfe094> @ imm = #0x30
  10e160: e5990000     	ldr	r0, [r9]
  10e164: e305842a     	movw	r8, #0x542a
  10e168: e348802c     	movt	r8, #0x802c
  10e16c: e2401001     	sub	r1, r0, #1
  10e170: e0000190     	mul	r0, r0, r1
  10e174: e3100001     	tst	r0, #1
  10e178: 0a000017     	beq	0x10e1dc <.text+0xfe0dc> @ imm = #0x5c
  10e17c: e59f033c     	ldr	r0, [pc, #0x33c]        @ 0x10e4c0 <.text+0xfe3c0>
  10e180: e79f0000     	ldr	r0, [pc, r0]
  10e184: e5900000     	ldr	r0, [r0]
  10e188: e3500009     	cmp	r0, #9
  10e18c: ca000028     	bgt	0x10e234 <.text+0xfe134> @ imm = #0xa0
  10e190: ea000011     	b	0x10e1dc <.text+0xfe0dc> @ imm = #0x44
  10e194: e59f0314     	ldr	r0, [pc, #0x314]        @ 0x10e4b0 <.text+0xfe3b0>
  10e198: e59f1314     	ldr	r1, [pc, #0x314]        @ 0x10e4b4 <.text+0xfe3b4>
  10e19c: e59f2314     	ldr	r2, [pc, #0x314]        @ 0x10e4b8 <.text+0xfe3b8>
  10e1a0: e08f0000     	add	r0, pc, r0
  10e1a4: e59f3310     	ldr	r3, [pc, #0x310]        @ 0x10e4bc <.text+0xfe3bc>
  10e1a8: e08f1001     	add	r1, pc, r1
  10e1ac: e08f2002     	add	r2, pc, r2
  10e1b0: e08f3003     	add	r3, pc, r3
  10e1b4: e24dd010     	sub	sp, sp, #16
  10e1b8: e3a07001     	mov	r7, #1
  10e1bc: e58d7000     	str	r7, [sp]
  10e1c0: e98d0028     	stmib	sp, {r3, r5}
  10e1c4: e3a0302c     	mov	r3, #44
  10e1c8: ebffafbd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1410c
  10e1cc: e28dd010     	add	sp, sp, #16
  10e1d0: e3e00000     	mvn	r0, #0
  10e1d4: e24bd01c     	sub	sp, r11, #28
  10e1d8: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  10e1dc: e1a00004     	mov	r0, r4
  10e1e0: e3a01000     	mov	r1, #0
  10e1e4: e3a0a000     	mov	r10, #0
  10e1e8: eb125fbb     	bl	0x5a60dc <.text+0x595fdc> @ imm = #0x497eec
  10e1ec: e1a00005     	mov	r0, r5
  10e1f0: eb1255aa     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x4956a8
  10e1f4: e284101c     	add	r1, r4, #28
  10e1f8: e1a02006     	mov	r2, r6
  10e1fc: e8810481     	stm	r1, {r0, r7, r10}
  10e200: e1a00007     	mov	r0, r7
  10e204: e1a01008     	mov	r1, r8
  10e208: eb1224d0     	bl	0x597550 <.text+0x587450> @ imm = #0x489340
  10e20c: e5991000     	ldr	r1, [r9]
  10e210: e2412001     	sub	r2, r1, #1
  10e214: e0010291     	mul	r1, r1, r2
  10e218: e3110001     	tst	r1, #1
  10e21c: 0a000011     	beq	0x10e268 <.text+0xfe168> @ imm = #0x44
  10e220: e59f129c     	ldr	r1, [pc, #0x29c]        @ 0x10e4c4 <.text+0xfe3c4>
  10e224: e79f1001     	ldr	r1, [pc, r1]
  10e228: e5911000     	ldr	r1, [r1]
  10e22c: e3510009     	cmp	r1, #9
  10e230: da00000c     	ble	0x10e268 <.text+0xfe168> @ imm = #0x30
  10e234: e1a00004     	mov	r0, r4
  10e238: e3a01000     	mov	r1, #0
  10e23c: e3a0a000     	mov	r10, #0
  10e240: eb125fa5     	bl	0x5a60dc <.text+0x595fdc> @ imm = #0x497e94
  10e244: e1a00005     	mov	r0, r5
  10e248: eb125594     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x495650
  10e24c: e284101c     	add	r1, r4, #28
  10e250: e1a02006     	mov	r2, r6
  10e254: e8810481     	stm	r1, {r0, r7, r10}
  10e258: e1a00007     	mov	r0, r7
  10e25c: e1a01008     	mov	r1, r8
  10e260: eb1224ba     	bl	0x597550 <.text+0x587450> @ imm = #0x4892e8
  10e264: eaffffdc     	b	0x10e1dc <.text+0xfe0dc> @ imm = #-0x90
  10e268: e3500000     	cmp	r0, #0
  10e26c: 0a00000f     	beq	0x10e2b0 <.text+0xfe1b0> @ imm = #0x3c
  10e270: e59f0250     	ldr	r0, [pc, #0x250]        @ 0x10e4c8 <.text+0xfe3c8>
  10e274: e59f1250     	ldr	r1, [pc, #0x250]        @ 0x10e4cc <.text+0xfe3cc>
  10e278: e59f2250     	ldr	r2, [pc, #0x250]        @ 0x10e4d0 <.text+0xfe3d0>
  10e27c: e08f0000     	add	r0, pc, r0
  10e280: e59f324c     	ldr	r3, [pc, #0x24c]        @ 0x10e4d4 <.text+0xfe3d4>
  10e284: e08f1001     	add	r1, pc, r1
  10e288: e08f2002     	add	r2, pc, r2
  10e28c: e08f3003     	add	r3, pc, r3
  10e290: e24dd008     	sub	sp, sp, #8
  10e294: e3a07001     	mov	r7, #1
  10e298: e58d3004     	str	r3, [sp, #0x4]
  10e29c: e3a03036     	mov	r3, #54
  10e2a0: e58d7000     	str	r7, [sp]
  10e2a4: ebffaf86     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x141e8
  10e2a8: e28dd008     	add	sp, sp, #8
  10e2ac: eaffffc7     	b	0x10e1d0 <.text+0xfe0d0> @ imm = #-0xe4
  10e2b0: e3a00c07     	mov	r0, #1792
  10e2b4: e896002e     	ldm	r6, {r1, r2, r3, r5}
  10e2b8: e3c33e9b     	bic	r3, r3, #2480
  10e2bc: e1c601b6     	strh	r0, [r6, #22]
  10e2c0: e30f0a14     	movw	r0, #0xfa14
  10e2c4: e34f0fff     	movt	r0, #0xffff
  10e2c8: e3833e8b     	orr	r3, r3, #2224
  10e2cc: e0010000     	and	r0, r1, r0
  10e2d0: e3c21001     	bic	r1, r2, #1
  10e2d4: e3072fb4     	movw	r2, #0x7fb4
  10e2d8: e886000b     	stm	r6, {r0, r1, r3}
  10e2dc: e34f2fff     	movt	r2, #0xffff
  10e2e0: e305142b     	movw	r1, #0x542b
  10e2e4: e0052002     	and	r2, r5, r2
  10e2e8: e586200c     	str	r2, [r6, #0xc]
  10e2ec: e344102c     	movt	r1, #0x402c
  10e2f0: e1a00007     	mov	r0, r7
  10e2f4: e1a02006     	mov	r2, r6
  10e2f8: eb122494     	bl	0x597550 <.text+0x587450> @ imm = #0x489250
  10e2fc: e3500000     	cmp	r0, #0
  10e300: 0a00000c     	beq	0x10e338 <.text+0xfe238> @ imm = #0x30
  10e304: e5990000     	ldr	r0, [r9]
  10e308: e59f41c8     	ldr	r4, [pc, #0x1c8]        @ 0x10e4d8 <.text+0xfe3d8>
  10e30c: e2401001     	sub	r1, r0, #1
  10e310: e59f51c4     	ldr	r5, [pc, #0x1c4]        @ 0x10e4dc <.text+0xfe3dc>
  10e314: e08f4004     	add	r4, pc, r4
  10e318: e0000190     	mul	r0, r0, r1
  10e31c: e79f5005     	ldr	r5, [pc, r5]
  10e320: e3100001     	tst	r0, #1
  10e324: 0a000019     	beq	0x10e390 <.text+0xfe290> @ imm = #0x64
  10e328: e5950000     	ldr	r0, [r5]
  10e32c: e3500009     	cmp	r0, #9
  10e330: ca00002b     	bgt	0x10e3e4 <.text+0xfe2e4> @ imm = #0xac
  10e334: ea000015     	b	0x10e390 <.text+0xfe290> @ imm = #0x54
  10e338: e30c1200     	movw	r1, #0xc200
  10e33c: e1a00004     	mov	r0, r4
  10e340: e3401001     	movt	r1, #0x1
  10e344: eb000073     	bl	0x10e518 <.text+0xfe418> @ imm = #0x1cc
  10e348: e3500000     	cmp	r0, #0
  10e34c: 0a00000c     	beq	0x10e384 <.text+0xfe284> @ imm = #0x30
  10e350: e5990000     	ldr	r0, [r9]
  10e354: e59f419c     	ldr	r4, [pc, #0x19c]        @ 0x10e4f8 <.text+0xfe3f8>
  10e358: e2401001     	sub	r1, r0, #1
  10e35c: e59f5198     	ldr	r5, [pc, #0x198]        @ 0x10e4fc <.text+0xfe3fc>
  10e360: e08f4004     	add	r4, pc, r4
  10e364: e0000190     	mul	r0, r0, r1
  10e368: e79f5005     	ldr	r5, [pc, r5]
  10e36c: e3100001     	tst	r0, #1
  10e370: 0a000028     	beq	0x10e418 <.text+0xfe318> @ imm = #0xa0
  10e374: e5950000     	ldr	r0, [r5]
  10e378: e3500009     	cmp	r0, #9
  10e37c: ca00003a     	bgt	0x10e46c <.text+0xfe36c> @ imm = #0xe8
  10e380: ea000024     	b	0x10e418 <.text+0xfe318> @ imm = #0x90
  10e384: e3a00000     	mov	r0, #0
  10e388: e24bd01c     	sub	sp, r11, #28
  10e38c: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  10e390: e59f0148     	ldr	r0, [pc, #0x148]        @ 0x10e4e0 <.text+0xfe3e0>
  10e394: e59f1148     	ldr	r1, [pc, #0x148]        @ 0x10e4e4 <.text+0xfe3e4>
  10e398: e59f2148     	ldr	r2, [pc, #0x148]        @ 0x10e4e8 <.text+0xfe3e8>
  10e39c: e08f0000     	add	r0, pc, r0
  10e3a0: e08f1001     	add	r1, pc, r1
  10e3a4: e08f2002     	add	r2, pc, r2
  10e3a8: e24dd008     	sub	sp, sp, #8
  10e3ac: e3a03001     	mov	r3, #1
  10e3b0: e88d0018     	stm	sp, {r3, r4}
  10e3b4: e3a03043     	mov	r3, #67
  10e3b8: ebffaf41     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x142fc
  10e3bc: e28dd008     	add	sp, sp, #8
  10e3c0: e5990000     	ldr	r0, [r9]
  10e3c4: e2401001     	sub	r1, r0, #1
  10e3c8: e0010190     	mul	r1, r0, r1
  10e3cc: e3e00000     	mvn	r0, #0
  10e3d0: e3110001     	tst	r1, #1
  10e3d4: 0a000031     	beq	0x10e4a0 <.text+0xfe3a0> @ imm = #0xc4
  10e3d8: e5951000     	ldr	r1, [r5]
  10e3dc: e351000a     	cmp	r1, #10
  10e3e0: ba00002e     	blt	0x10e4a0 <.text+0xfe3a0> @ imm = #0xb8
  10e3e4: e59f0100     	ldr	r0, [pc, #0x100]        @ 0x10e4ec <.text+0xfe3ec>
  10e3e8: e59f1100     	ldr	r1, [pc, #0x100]        @ 0x10e4f0 <.text+0xfe3f0>
  10e3ec: e59f2100     	ldr	r2, [pc, #0x100]        @ 0x10e4f4 <.text+0xfe3f4>
  10e3f0: e08f0000     	add	r0, pc, r0
  10e3f4: e08f1001     	add	r1, pc, r1
  10e3f8: e08f2002     	add	r2, pc, r2
  10e3fc: e24dd008     	sub	sp, sp, #8
  10e400: e3a03001     	mov	r3, #1
  10e404: e88d0018     	stm	sp, {r3, r4}
  10e408: e3a03043     	mov	r3, #67
  10e40c: ebffaf2c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x14350
  10e410: e28dd008     	add	sp, sp, #8
  10e414: eaffffdd     	b	0x10e390 <.text+0xfe290> @ imm = #-0x8c
  10e418: e59f00e0     	ldr	r0, [pc, #0xe0]         @ 0x10e500 <.text+0xfe400>
  10e41c: e59f10e0     	ldr	r1, [pc, #0xe0]         @ 0x10e504 <.text+0xfe404>
  10e420: e59f20e0     	ldr	r2, [pc, #0xe0]         @ 0x10e508 <.text+0xfe408>
  10e424: e08f0000     	add	r0, pc, r0
  10e428: e08f1001     	add	r1, pc, r1
  10e42c: e08f2002     	add	r2, pc, r2
  10e430: e24dd008     	sub	sp, sp, #8
  10e434: e3a03001     	mov	r3, #1
  10e438: e88d0018     	stm	sp, {r3, r4}
  10e43c: e3a03048     	mov	r3, #72
  10e440: ebffaf1f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x14384
  10e444: e28dd008     	add	sp, sp, #8
  10e448: e5990000     	ldr	r0, [r9]
  10e44c: e2401001     	sub	r1, r0, #1
  10e450: e0010190     	mul	r1, r0, r1
  10e454: e3e00000     	mvn	r0, #0
  10e458: e3110001     	tst	r1, #1
  10e45c: 0a00000f     	beq	0x10e4a0 <.text+0xfe3a0> @ imm = #0x3c
  10e460: e5951000     	ldr	r1, [r5]
  10e464: e3510009     	cmp	r1, #9
  10e468: da00000c     	ble	0x10e4a0 <.text+0xfe3a0> @ imm = #0x30
  10e46c: e59f0098     	ldr	r0, [pc, #0x98]         @ 0x10e50c <.text+0xfe40c>
  10e470: e59f1098     	ldr	r1, [pc, #0x98]         @ 0x10e510 <.text+0xfe410>
  10e474: e59f2098     	ldr	r2, [pc, #0x98]         @ 0x10e514 <.text+0xfe414>
  10e478: e08f0000     	add	r0, pc, r0
  10e47c: e08f1001     	add	r1, pc, r1
  10e480: e08f2002     	add	r2, pc, r2
  10e484: e24dd008     	sub	sp, sp, #8
  10e488: e3a03001     	mov	r3, #1
  10e48c: e88d0018     	stm	sp, {r3, r4}
  10e490: e3a03048     	mov	r3, #72
  10e494: ebffaf0a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x143d8
  10e498: e28dd008     	add	sp, sp, #8
  10e49c: eaffffdd     	b	0x10e418 <.text+0xfe318> @ imm = #-0x8c
  10e4a0: e24bd01c     	sub	sp, r11, #28
  10e4a4: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  10e4a8: 004d0d44     	subeq	r0, sp, r4, asr #26
  10e4ac: 004d12a4     	subeq	r1, sp, r4, lsr #5
  10e4b0: 004dfa10     	subeq	pc, sp, r0, lsl r10
  10e4b4: 004dfa0f     	subeq	pc, sp, pc, lsl #20
  10e4b8: 004dfa2c     	subeq	pc, sp, r12, lsr #20
  10e4bc: 004dfa33     	subeq	pc, sp, r3, lsr r10
  10e4c0: 004d1218     	subeq	r1, sp, r8, lsl r2
  10e4c4: 004d1174     	subeq	r1, sp, r4, ror r1
  10e4c8: 004df934     	subeq	pc, sp, r4, lsr r9
  10e4cc: 004df933     	subeq	pc, sp, r3, lsr r9
  10e4d0: 004df950     	subeq	pc, sp, r0, asr r9
  10e4d4: 004df96a     	subeq	pc, sp, r10, ror #18
  10e4d8: 004df8ff     	<unknown>
  10e4dc: 004d107c     	subeq	r1, sp, r12, ror r0
  10e4e0: 004df814     	subeq	pc, sp, r4, lsl r8
  10e4e4: 004df817     	subeq	pc, sp, r7, lsl r8
  10e4e8: 004df834     	subeq	pc, sp, r4, lsr r8
  10e4ec: 004df7c0     	subeq	pc, sp, r0, asr #15
  10e4f0: 004df7c3     	subeq	pc, sp, r3, asr #15
  10e4f4: 004df7e0     	subeq	pc, sp, r0, ror #15
  10e4f8: 004df8d0     	<unknown>
  10e4fc: 004d1030     	subeq	r1, sp, r0, lsr r0
  10e500: 004df78c     	subeq	pc, sp, r12, lsl #15
  10e504: 004df78f     	subeq	pc, sp, pc, lsl #15
  10e508: 004df7ac     	subeq	pc, sp, r12, lsr #15
  10e50c: 004df738     	subeq	pc, sp, r8, lsr r7
  10e510: 004df73b     	subeq	pc, sp, r11, lsr r7
  10e514: 004df758     	subeq	pc, sp, r8, asr r7

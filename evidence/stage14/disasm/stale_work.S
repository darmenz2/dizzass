
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   32040: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   32044: e28db01c     	add	r11, sp, #28
   32048: e24dd004     	sub	sp, sp, #4
   3204c: ed2d8b02     	vpush	{d8}
   32050: e24dd020     	sub	sp, sp, #32
   32054: e1a04000     	mov	r4, r0
   32058: e59001b8     	ldr	r0, [r0, #0x1b8]
   3205c: e59f2464     	ldr	r2, [pc, #0x464]        @ 0x324c8 <.text+0x223c8>
   32060: e79f2002     	ldr	r2, [pc, r2]
   32064: e1500002     	cmp	r0, r2
   32068: 1a00010f     	bne	0x324ac <.text+0x223ac> @ imm = #0x43c
   3206c: e59fa458     	ldr	r10, [pc, #0x458]       @ 0x324cc <.text+0x223cc>
   32070: e79fa00a     	ldr	r10, [pc, r10]
   32074: e59a0000     	ldr	r0, [r10]
   32078: e2402001     	sub	r2, r0, #1
   3207c: e0000290     	mul	r0, r0, r2
   32080: e3100001     	tst	r0, #1
   32084: e5940184     	ldr	r0, [r4, #0x184]
   32088: e594716c     	ldr	r7, [r4, #0x16c]
   3208c: ed9f8be1     	vldr	d8, [pc, #900]          @ 0x32418 <.text+0x22318>
   32090: e350003c     	cmp	r0, #60
   32094: ee000a10     	vmov	s0, r0
   32098: eeb80bc0     	vcvt.f64.s32	d0, s0
   3209c: e59a2000     	ldr	r2, [r10]
   320a0: e59f6428     	ldr	r6, [pc, #0x428]        @ 0x324d0 <.text+0x223d0>
   320a4: e2423001     	sub	r3, r2, #1
   320a8: e0020392     	mul	r2, r2, r3
   320ac: e79f6006     	ldr	r6, [pc, r6]
   320b0: ceb08b40     	vmovgt.f64	d8, d0
   320b4: e3120001     	tst	r2, #1
   320b8: 0a000002     	beq	0x320c8 <.text+0x21fc8> @ imm = #0x8
   320bc: e5960000     	ldr	r0, [r6]
   320c0: e3500009     	cmp	r0, #9
   320c4: caffffee     	bgt	0x32084 <.text+0x21f84> @ imm = #-0x48
   320c8: e3510000     	cmp	r1, #0
   320cc: 0a00001c     	beq	0x32144 <.text+0x22044> @ imm = #0x70
   320d0: e28d0010     	add	r0, sp, #16
   320d4: ebff8054     	bl	0x1222c <.text+0x212c>  @ imm = #-0x1feb0
   320d8: e5940170     	ldr	r0, [r4, #0x170]
   320dc: e59d2010     	ldr	r2, [sp, #0x10]
   320e0: e5941174     	ldr	r1, [r4, #0x174]
   320e4: e59d3014     	ldr	r3, [sp, #0x14]
   320e8: e0520000     	subs	r0, r2, r0
   320ec: e0c31001     	sbc	r1, r3, r1
   320f0: eb157c95     	bl	0x59134c <.text+0x58124c> @ imm = #0x55f254
   320f4: ed9f0bf1     	vldr	d0, [pc, #964]          @ 0x324c0 <.text+0x223c0>
   320f8: ec410b11     	vmov	d1, r0, r1
   320fc: e3a00000     	mov	r0, #0
   32100: eeb48bc0     	vcmpe.f64	d8, d0
   32104: eef1fa10     	vmrs	APSR_nzcv, fpscr
   32108: 4eb08b40     	vmovmi.f64	d8, d0
   3210c: eeb48bc1     	vcmpe.f64	d8, d1
   32110: eef1fa10     	vmrs	APSR_nzcv, fpscr
   32114: 8a0000e5     	bhi	0x324b0 <.text+0x223b0> @ imm = #0x394
   32118: e59a0000     	ldr	r0, [r10]
   3211c: e59f43e8     	ldr	r4, [pc, #0x3e8]        @ 0x3250c <.text+0x2240c>
   32120: e2401001     	sub	r1, r0, #1
   32124: e08f4004     	add	r4, pc, r4
   32128: e0000190     	mul	r0, r0, r1
   3212c: e3100001     	tst	r0, #1
   32130: 0a0000ba     	beq	0x32420 <.text+0x22320> @ imm = #0x2e8
   32134: e5960000     	ldr	r0, [r6]
   32138: e3500009     	cmp	r0, #9
   3213c: ca0000cc     	bgt	0x32474 <.text+0x22374> @ imm = #0x330
   32140: ea0000b6     	b	0x32420 <.text+0x22320> @ imm = #0x2d8
   32144: e59a0000     	ldr	r0, [r10]
   32148: e2401001     	sub	r1, r0, #1
   3214c: e0000190     	mul	r0, r0, r1
   32150: e3100001     	tst	r0, #1
   32154: e59a0000     	ldr	r0, [r10]
   32158: e2401001     	sub	r1, r0, #1
   3215c: e0010190     	mul	r1, r0, r1
   32160: e5d703fc     	ldrb	r0, [r7, #0x3fc]
   32164: e3110001     	tst	r1, #1
   32168: 0a000002     	beq	0x32178 <.text+0x22078> @ imm = #0x8
   3216c: e5961000     	ldr	r1, [r6]
   32170: e3510009     	cmp	r1, #9
   32174: cafffff6     	bgt	0x32154 <.text+0x22054> @ imm = #-0x28
   32178: e3500000     	cmp	r0, #0
   3217c: 15d703fe     	ldrbne	r0, [r7, #0x3fe]
   32180: 13500000     	cmpne	r0, #0
   32184: 1a00000a     	bne	0x321b4 <.text+0x220b4> @ imm = #0x28
   32188: e59a0000     	ldr	r0, [r10]
   3218c: e59f4340     	ldr	r4, [pc, #0x340]        @ 0x324d4 <.text+0x223d4>
   32190: e2401001     	sub	r1, r0, #1
   32194: e08f4004     	add	r4, pc, r4
   32198: e0000190     	mul	r0, r0, r1
   3219c: e3100001     	tst	r0, #1
   321a0: 0a00000c     	beq	0x321d8 <.text+0x220d8> @ imm = #0x30
   321a4: e5960000     	ldr	r0, [r6]
   321a8: e3500009     	cmp	r0, #9
   321ac: ca00001e     	bgt	0x3222c <.text+0x2212c> @ imm = #0x78
   321b0: ea000008     	b	0x321d8 <.text+0x220d8> @ imm = #0x20
   321b4: e59a0000     	ldr	r0, [r10]
   321b8: e2401001     	sub	r1, r0, #1
   321bc: e0000190     	mul	r0, r0, r1
   321c0: e3100001     	tst	r0, #1
   321c4: 0a000026     	beq	0x32264 <.text+0x22164> @ imm = #0x98
   321c8: e5960000     	ldr	r0, [r6]
   321cc: e3500009     	cmp	r0, #9
   321d0: ca00002e     	bgt	0x32290 <.text+0x22190> @ imm = #0xb8
   321d4: ea000022     	b	0x32264 <.text+0x22164> @ imm = #0x88
   321d8: e59f02f8     	ldr	r0, [pc, #0x2f8]        @ 0x324d8 <.text+0x223d8>
   321dc: e3a05002     	mov	r5, #2
   321e0: e59f12f4     	ldr	r1, [pc, #0x2f4]        @ 0x324dc <.text+0x223dc>
   321e4: e59f22f4     	ldr	r2, [pc, #0x2f4]        @ 0x324e0 <.text+0x223e0>
   321e8: e08f0000     	add	r0, pc, r0
   321ec: e5973068     	ldr	r3, [r7, #0x68]
   321f0: e08f1001     	add	r1, pc, r1
   321f4: e08f2002     	add	r2, pc, r2
   321f8: e58d3008     	str	r3, [sp, #0x8]
   321fc: e30038c8     	movw	r3, #0x8c8
   32200: e58d5000     	str	r5, [sp]
   32204: e58d4004     	str	r4, [sp, #0x4]
   32208: eb031fad     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xc7eb4
   3220c: e59a0000     	ldr	r0, [r10]
   32210: e2401001     	sub	r1, r0, #1
   32214: e0000190     	mul	r0, r0, r1
   32218: e3100001     	tst	r0, #1
   3221c: 0a0000a2     	beq	0x324ac <.text+0x223ac> @ imm = #0x288
   32220: e5960000     	ldr	r0, [r6]
   32224: e350000a     	cmp	r0, #10
   32228: ba00009f     	blt	0x324ac <.text+0x223ac> @ imm = #0x27c
   3222c: e59f02b0     	ldr	r0, [pc, #0x2b0]        @ 0x324e4 <.text+0x223e4>
   32230: e3a05002     	mov	r5, #2
   32234: e59f12ac     	ldr	r1, [pc, #0x2ac]        @ 0x324e8 <.text+0x223e8>
   32238: e59f22ac     	ldr	r2, [pc, #0x2ac]        @ 0x324ec <.text+0x223ec>
   3223c: e08f0000     	add	r0, pc, r0
   32240: e5973068     	ldr	r3, [r7, #0x68]
   32244: e08f1001     	add	r1, pc, r1
   32248: e08f2002     	add	r2, pc, r2
   3224c: e58d3008     	str	r3, [sp, #0x8]
   32250: e30038c8     	movw	r3, #0x8c8
   32254: e58d5000     	str	r5, [sp]
   32258: e58d4004     	str	r4, [sp, #0x4]
   3225c: eb031f98     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xc7e60
   32260: eaffffdc     	b	0x321d8 <.text+0x220d8> @ imm = #-0x90
   32264: e2875030     	add	r5, r7, #48
   32268: e1a00005     	mov	r0, r5
   3226c: eb15d19d     	bl	0x5a68e8 <.text+0x5967e8> @ imm = #0x574674
   32270: e59a1000     	ldr	r1, [r10]
   32274: e2412001     	sub	r2, r1, #1
   32278: e0010291     	mul	r1, r1, r2
   3227c: e3110001     	tst	r1, #1
   32280: 0a000005     	beq	0x3229c <.text+0x2219c> @ imm = #0x14
   32284: e5961000     	ldr	r1, [r6]
   32288: e3510009     	cmp	r1, #9
   3228c: da000002     	ble	0x3229c <.text+0x2219c> @ imm = #0x8
   32290: e2870030     	add	r0, r7, #48
   32294: eb15d193     	bl	0x5a68e8 <.text+0x5967e8> @ imm = #0x57464c
   32298: eafffff1     	b	0x32264 <.text+0x22164> @ imm = #-0x3c
   3229c: e3500000     	cmp	r0, #0
   322a0: 1a00001a     	bne	0x32310 <.text+0x22210> @ imm = #0x68
   322a4: e3a02001     	mov	r2, #1
   322a8: e3540000     	cmp	r4, #0
   322ac: 0a000004     	beq	0x322c4 <.text+0x221c4> @ imm = #0x10
   322b0: e594818c     	ldr	r8, [r4, #0x18c]
   322b4: e3580000     	cmp	r8, #0
   322b8: 159793d0     	ldrne	r9, [r7, #0x3d0]
   322bc: 13590000     	cmpne	r9, #0
   322c0: 1a000009     	bne	0x322ec <.text+0x221ec> @ imm = #0x24
   322c4: e59a0000     	ldr	r0, [r10]
   322c8: e1a08002     	mov	r8, r2
   322cc: e2401001     	sub	r1, r0, #1
   322d0: e0000190     	mul	r0, r0, r1
   322d4: e3100001     	tst	r0, #1
   322d8: 0a00002a     	beq	0x32388 <.text+0x22288> @ imm = #0xa8
   322dc: e5960000     	ldr	r0, [r6]
   322e0: e3500009     	cmp	r0, #9
   322e4: ca000031     	bgt	0x323b0 <.text+0x222b0> @ imm = #0xc4
   322e8: ea000026     	b	0x32388 <.text+0x22288> @ imm = #0x98
   322ec: e59a0000     	ldr	r0, [r10]
   322f0: e2401001     	sub	r1, r0, #1
   322f4: e0000190     	mul	r0, r0, r1
   322f8: e3100001     	tst	r0, #1
   322fc: 0a000010     	beq	0x32344 <.text+0x22244> @ imm = #0x40
   32300: e5960000     	ldr	r0, [r6]
   32304: e3500009     	cmp	r0, #9
   32308: ca00001a     	bgt	0x32378 <.text+0x22278> @ imm = #0x68
   3230c: ea00000c     	b	0x32344 <.text+0x22244> @ imm = #0x30
   32310: eb1583b3     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x560ecc
   32314: e59f21d4     	ldr	r2, [pc, #0x1d4]        @ 0x324f0 <.text+0x223f0>
   32318: e59f11d4     	ldr	r1, [pc, #0x1d4]        @ 0x324f4 <.text+0x223f4>
   3231c: e5900000     	ldr	r0, [r0]
   32320: e08f2002     	add	r2, pc, r2
   32324: e59f31cc     	ldr	r3, [pc, #0x1cc]        @ 0x324f8 <.text+0x223f8>
   32328: e08f1001     	add	r1, pc, r1
   3232c: e58d0000     	str	r0, [sp]
   32330: e1a00002     	mov	r0, r2
   32334: e08f3003     	add	r3, pc, r3
   32338: e3002249     	movw	r2, #0x249
   3233c: ebff77d5     	bl	0x10298 <.text+0x198>   @ imm = #-0x220ac
   32340: eaffffd7     	b	0x322a4 <.text+0x221a4> @ imm = #-0xa4
   32344: e1a00008     	mov	r0, r8
   32348: e1a01009     	mov	r1, r9
   3234c: eb15c502     	bl	0x5a375c <.text+0x59365c> @ imm = #0x571408
   32350: e59a1000     	ldr	r1, [r10]
   32354: e16f0f10     	clz	r0, r0
   32358: e2412001     	sub	r2, r1, #1
   3235c: e0010291     	mul	r1, r1, r2
   32360: e1a022a0     	lsr	r2, r0, #5
   32364: e3110001     	tst	r1, #1
   32368: 0affffd5     	beq	0x322c4 <.text+0x221c4> @ imm = #-0xac
   3236c: e5960000     	ldr	r0, [r6]
   32370: e3500009     	cmp	r0, #9
   32374: daffffd2     	ble	0x322c4 <.text+0x221c4> @ imm = #-0xb8
   32378: e1a00008     	mov	r0, r8
   3237c: e1a01009     	mov	r1, r9
   32380: eb15c4f5     	bl	0x5a375c <.text+0x59365c> @ imm = #0x5713d4
   32384: eaffffee     	b	0x32344 <.text+0x22244> @ imm = #-0x48
   32388: e1a00005     	mov	r0, r5
   3238c: eb15d1b9     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x5746e4
   32390: e59a1000     	ldr	r1, [r10]
   32394: e2412001     	sub	r2, r1, #1
   32398: e0010291     	mul	r1, r1, r2
   3239c: e3110001     	tst	r1, #1
   323a0: 0a000005     	beq	0x323bc <.text+0x222bc> @ imm = #0x14
   323a4: e5961000     	ldr	r1, [r6]
   323a8: e3510009     	cmp	r1, #9
   323ac: da000002     	ble	0x323bc <.text+0x222bc> @ imm = #0x8
   323b0: e1a00005     	mov	r0, r5
   323b4: eb15d1af     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x5746bc
   323b8: eafffff2     	b	0x32388 <.text+0x22288> @ imm = #-0x38
   323bc: e3500000     	cmp	r0, #0
   323c0: 1a000007     	bne	0x323e4 <.text+0x222e4> @ imm = #0x1c
   323c4: e59f013c     	ldr	r0, [pc, #0x13c]        @ 0x32508 <.text+0x22408>
   323c8: e79f0000     	ldr	r0, [pc, r0]
   323cc: e5900000     	ldr	r0, [r0]
   323d0: e12fff30     	blx	r0
   323d4: e3a00001     	mov	r0, #1
   323d8: e3580000     	cmp	r8, #0
   323dc: 1affff3b     	bne	0x320d0 <.text+0x21fd0> @ imm = #-0x314
   323e0: ea000032     	b	0x324b0 <.text+0x223b0> @ imm = #0xc8
   323e4: eb15837e     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x560df8
   323e8: e59f210c     	ldr	r2, [pc, #0x10c]        @ 0x324fc <.text+0x223fc>
   323ec: e59f110c     	ldr	r1, [pc, #0x10c]        @ 0x32500 <.text+0x22400>
   323f0: e5900000     	ldr	r0, [r0]
   323f4: e08f2002     	add	r2, pc, r2
   323f8: e59f3104     	ldr	r3, [pc, #0x104]        @ 0x32504 <.text+0x22404>
   323fc: e08f1001     	add	r1, pc, r1
   32400: e58d0000     	str	r0, [sp]
   32404: e1a00002     	mov	r0, r2
   32408: e08f3003     	add	r3, pc, r3
   3240c: e300224f     	movw	r2, #0x24f
   32410: ebff77a0     	bl	0x10298 <.text+0x198>   @ imm = #-0x22180
   32414: eaffffea     	b	0x323c4 <.text+0x222c4> @ imm = #-0x58
   32418: 00000000     	andeq	r0, r0, r0
   3241c: 4082c000     	addmi	r12, r2, r0
   32420: e59f00e8     	ldr	r0, [pc, #0xe8]         @ 0x32510 <.text+0x22410>
   32424: e3a05002     	mov	r5, #2
   32428: e59f10e4     	ldr	r1, [pc, #0xe4]         @ 0x32514 <.text+0x22414>
   3242c: e59f20e4     	ldr	r2, [pc, #0xe4]         @ 0x32518 <.text+0x22418>
   32430: e08f0000     	add	r0, pc, r0
   32434: e5973068     	ldr	r3, [r7, #0x68]
   32438: e08f1001     	add	r1, pc, r1
   3243c: e08f2002     	add	r2, pc, r2
   32440: e58d3008     	str	r3, [sp, #0x8]
   32444: e3a03e8e     	mov	r3, #2272
   32448: e58d5000     	str	r5, [sp]
   3244c: e58d4004     	str	r4, [sp, #0x4]
   32450: eb031f1b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xc7c6c
   32454: e59a0000     	ldr	r0, [r10]
   32458: e2401001     	sub	r1, r0, #1
   3245c: e0000190     	mul	r0, r0, r1
   32460: e3100001     	tst	r0, #1
   32464: 0a000010     	beq	0x324ac <.text+0x223ac> @ imm = #0x40
   32468: e5960000     	ldr	r0, [r6]
   3246c: e3500009     	cmp	r0, #9
   32470: da00000d     	ble	0x324ac <.text+0x223ac> @ imm = #0x34
   32474: e59f00a0     	ldr	r0, [pc, #0xa0]         @ 0x3251c <.text+0x2241c>
   32478: e3a05002     	mov	r5, #2
   3247c: e59f109c     	ldr	r1, [pc, #0x9c]         @ 0x32520 <.text+0x22420>
   32480: e59f209c     	ldr	r2, [pc, #0x9c]         @ 0x32524 <.text+0x22424>
   32484: e08f0000     	add	r0, pc, r0
   32488: e5973068     	ldr	r3, [r7, #0x68]
   3248c: e08f1001     	add	r1, pc, r1
   32490: e08f2002     	add	r2, pc, r2
   32494: e58d3008     	str	r3, [sp, #0x8]
   32498: e3a03e8e     	mov	r3, #2272
   3249c: e58d5000     	str	r5, [sp]
   324a0: e58d4004     	str	r4, [sp, #0x4]
   324a4: eb031f06     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xc7c18
   324a8: eaffffdc     	b	0x32420 <.text+0x22320> @ imm = #-0x90
   324ac: e3a00001     	mov	r0, #1
   324b0: e24bd028     	sub	sp, r11, #40
   324b4: ecbd8b02     	vpop	{d8}
   324b8: e28dd004     	add	sp, sp, #4
   324bc: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   324c0: 00000000     	andeq	r0, r0, r0
   324c4: 40140000     	andsmi	r0, r4, r0
   324c8: 005de720     	subseq	lr, sp, r0, lsr #14
   324cc: 005ad860     	subseq	sp, r10, r0, ror #16
   324d0: 005acbbc     	ldrheq	r12, [r10], #-188
   324d4: 005b0c99     	<unknown>
   324d8: 005affcf     	subseq	pc, r10, pc, asr #31
   324dc: 005aff9c     	<unknown>
   324e0: 005affc9     	subseq	pc, r10, r9, asr #31
   324e4: 005aff7b     	subseq	pc, r10, r11, ror pc
   324e8: 005aff48     	subseq	pc, r10, r8, asr #30
   324ec: 005aff75     	subseq	pc, r10, r5, ror pc
   324f0: 005b034f     	subseq	r0, r11, pc, asr #6
   324f4: 005afe95     	<unknown>
   324f8: 005b0366     	subseq	r0, r11, r6, ror #6
   324fc: 005b027b     	subseq	r0, r11, r11, ror r2
   32500: 005afdc1     	subseq	pc, r10, r1, asr #27
   32504: 005b02ae     	subseq	r0, r11, lr, lsr #5
   32508: 005ac3d8     	ldrsbeq	r12, [r10], #-56
   3250c: 005b0d36     	subseq	r0, r11, r6, lsr sp
   32510: 005afd87     	subseq	pc, r10, r7, lsl #27
   32514: 005afd54     	subseq	pc, r10, r4, asr sp
   32518: 005afd81     	subseq	pc, r10, r1, lsl #27
   3251c: 005afd33     	subseq	pc, r10, r3, lsr sp
   32520: 005afd00     	subseq	pc, r10, r0, lsl #26
   32524: 005afd2d     	subseq	pc, r10, sp, lsr #26

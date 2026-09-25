
/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   a2218: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   a221c: e28db01c     	add	r11, sp, #28
   a2220: e24dd004     	sub	sp, sp, #4
   a2224: ed2d8b10     	vpush	{d8, d9, d10, d11, d12, d13, d14, d15}
   a2228: e24dd058     	sub	sp, sp, #88
   a222c: e1a08000     	mov	r8, r0
   a2230: e5900018     	ldr	r0, [r0, #0x18]
   a2234: e3a04000     	mov	r4, #0
   a2238: e58d0028     	str	r0, [sp, #0x28]
   a223c: e1a00008     	mov	r0, r8
   a2240: e58d4054     	str	r4, [sp, #0x54]
   a2244: e58d4050     	str	r4, [sp, #0x50]
   a2248: e58d404c     	str	r4, [sp, #0x4c]
   a224c: e58d4048     	str	r4, [sp, #0x48]
   a2250: e58d4044     	str	r4, [sp, #0x44]
   a2254: e58d4040     	str	r4, [sp, #0x40]
   a2258: ebfeff08     	bl	0x61e80 <.text+0x51d80> @ imm = #-0x403e0
   a225c: e3a00001     	mov	r0, #1
   a2260: e3a01000     	mov	r1, #0
   a2264: eb141230     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x5048c0
   a2268: e59f1fd4     	ldr	r1, [pc, #0xfd4]        @ 0xa3244 <.text+0x93144>
   a226c: e3a0000f     	mov	r0, #15
   a2270: e3a02000     	mov	r2, #0
   a2274: e3a03000     	mov	r3, #0
   a2278: e08f1001     	add	r1, pc, r1
   a227c: e58d4000     	str	r4, [sp]
   a2280: e3a09001     	mov	r9, #1
   a2284: eb13c61b     	bl	0x593af8 <.text+0x5839f8> @ imm = #0x4f186c
   a2288: e59f6fec     	ldr	r6, [pc, #0xfec]        @ 0xa327c <.text+0x9317c>
   a228c: e08f6006     	add	r6, pc, r6
   a2290: e2865038     	add	r5, r6, #56
   a2294: e1a00005     	mov	r0, r5
   a2298: eb140f9a     	bl	0x5a6108 <.text+0x596008> @ imm = #0x503e68
   a229c: e1a00005     	mov	r0, r5
   a22a0: e5869000     	str	r9, [r6]
   a22a4: e58d5038     	str	r5, [sp, #0x38]
   a22a8: eb141105     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x504414
   a22ac: e3010028     	movw	r0, #0x1028
   a22b0: e1a05008     	mov	r5, r8
   a22b4: e7f50000     	ldrb	r0, [r5, r0]!
   a22b8: e3500000     	cmp	r0, #0
   a22bc: 0a000f23     	beq	0xa5f50 <.text+0x95e50> @ imm = #0x3c8c
   a22c0: e28d0040     	add	r0, sp, #64
   a22c4: ed9f8be7     	vldr	d8, [pc, #924]          @ 0xa2668 <.text+0x92568>
   a22c8: e2800010     	add	r0, r0, #16
   a22cc: e58d0024     	str	r0, [sp, #0x24]
   a22d0: e59fafa8     	ldr	r10, [pc, #0xfa8]       @ 0xa3280 <.text+0x93180>
   a22d4: ed9f9be5     	vldr	d9, [pc, #916]          @ 0xa2670 <.text+0x92570>
   a22d8: ed9fabe6     	vldr	d10, [pc, #920]         @ 0xa2678 <.text+0x92578>
   a22dc: e79fa00a     	ldr	r10, [pc, r10]
   a22e0: e59f4f9c     	ldr	r4, [pc, #0xf9c]        @ 0xa3284 <.text+0x93184>
   a22e4: ed9fcbe5     	vldr	d12, [pc, #916]         @ 0xa2680 <.text+0x92580>
   a22e8: ed9fdbe6     	vldr	d13, [pc, #920]         @ 0xa2688 <.text+0x92588>
   a22ec: e79f4004     	ldr	r4, [pc, r4]
   a22f0: ed9febe6     	vldr	d14, [pc, #920]         @ 0xa2690 <.text+0x92590>
   a22f4: ed9ffbe7     	vldr	d15, [pc, #924]         @ 0xa2698 <.text+0x92598>
   a22f8: ed9fbbe8     	vldr	d11, [pc, #928]         @ 0xa26a0 <.text+0x925a0>
   a22fc: e58d5034     	str	r5, [sp, #0x34]
   a2300: ea000004     	b	0xa2318 <.text+0x92218> @ imm = #0x10
   a2304: e3a00ffa     	mov	r0, #1000
   a2308: eb01b30b     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6cc2c
   a230c: e5d50000     	ldrb	r0, [r5]
   a2310: e3500000     	cmp	r0, #0
   a2314: 0a000f0d     	beq	0xa5f50 <.text+0x95e50> @ imm = #0x3c34
   a2318: e5d80fe5     	ldrb	r0, [r8, #0xfe5]
   a231c: e3500000     	cmp	r0, #0
   a2320: 1a000006     	bne	0xa2340 <.text+0x92240> @ imm = #0x18
   a2324: e1a00008     	mov	r0, r8
   a2328: ebfefee8     	bl	0x61ed0 <.text+0x51dd0> @ imm = #-0x40460
   a232c: e59800dc     	ldr	r0, [r8, #0xdc]
   a2330: e598120c     	ldr	r1, [r8, #0x20c]
   a2334: e1510000     	cmp	r1, r0
   a2338: cafffff1     	bgt	0xa2304 <.text+0x92204> @ imm = #-0x3c
   a233c: e5c89fe5     	strb	r9, [r8, #0xfe5]
   a2340: e59a0000     	ldr	r0, [r10]
   a2344: e2401001     	sub	r1, r0, #1
   a2348: e0000190     	mul	r0, r0, r1
   a234c: e3100001     	tst	r0, #1
   a2350: e59a0000     	ldr	r0, [r10]
   a2354: e2401001     	sub	r1, r0, #1
   a2358: e0010190     	mul	r1, r0, r1
   a235c: e59800e8     	ldr	r0, [r8, #0xe8]
   a2360: e3110001     	tst	r1, #1
   a2364: 0a000002     	beq	0xa2374 <.text+0x92274> @ imm = #0x8
   a2368: e5941000     	ldr	r1, [r4]
   a236c: e3510009     	cmp	r1, #9
   a2370: cafffff6     	bgt	0xa2350 <.text+0x92250> @ imm = #-0x28
   a2374: e3500064     	cmp	r0, #100
   a2378: 1affffe1     	bne	0xa2304 <.text+0x92204> @ imm = #-0x7c
   a237c: e59a0000     	ldr	r0, [r10]
   a2380: e2401001     	sub	r1, r0, #1
   a2384: e0000190     	mul	r0, r0, r1
   a2388: e3100001     	tst	r0, #1
   a238c: e59a0000     	ldr	r0, [r10]
   a2390: e2401001     	sub	r1, r0, #1
   a2394: e0010190     	mul	r1, r0, r1
   a2398: e5d80024     	ldrb	r0, [r8, #0x24]
   a239c: e3110001     	tst	r1, #1
   a23a0: 0a000002     	beq	0xa23b0 <.text+0x922b0> @ imm = #0x8
   a23a4: e5941000     	ldr	r1, [r4]
   a23a8: e3510009     	cmp	r1, #9
   a23ac: cafffff6     	bgt	0xa238c <.text+0x9228c> @ imm = #-0x28
   a23b0: e3500000     	cmp	r0, #0
   a23b4: 0affffd2     	beq	0xa2304 <.text+0x92204> @ imm = #-0xb8
   a23b8: e5d50021     	ldrb	r0, [r5, #0x21]
   a23bc: e3500000     	cmp	r0, #0
   a23c0: 1affffcf     	bne	0xa2304 <.text+0x92204> @ imm = #-0xc4
   a23c4: e59a0000     	ldr	r0, [r10]
   a23c8: e2401001     	sub	r1, r0, #1
   a23cc: e0000190     	mul	r0, r0, r1
   a23d0: e3100001     	tst	r0, #1
   a23d4: e59a0000     	ldr	r0, [r10]
   a23d8: e2401001     	sub	r1, r0, #1
   a23dc: e0010190     	mul	r1, r0, r1
   a23e0: e5d80fe6     	ldrb	r0, [r8, #0xfe6]
   a23e4: e3110001     	tst	r1, #1
   a23e8: 0a000002     	beq	0xa23f8 <.text+0x922f8> @ imm = #0x8
   a23ec: e5941000     	ldr	r1, [r4]
   a23f0: e3510009     	cmp	r1, #9
   a23f4: cafffff6     	bgt	0xa23d4 <.text+0x922d4> @ imm = #-0x28
   a23f8: e3500000     	cmp	r0, #0
   a23fc: 0affffc0     	beq	0xa2304 <.text+0x92204> @ imm = #-0x100
   a2400: e5d800e4     	ldrb	r0, [r8, #0xe4]
   a2404: e3500000     	cmp	r0, #0
   a2408: 1affffbd     	bne	0xa2304 <.text+0x92204> @ imm = #-0x10c
   a240c: ebff8142     	bl	0x8291c <.text+0x7281c> @ imm = #-0x1faf8
   a2410: e3500000     	cmp	r0, #0
   a2414: 1affffba     	bne	0xa2304 <.text+0x92204> @ imm = #-0x118
   a2418: e59d5038     	ldr	r5, [sp, #0x38]
   a241c: e1a00005     	mov	r0, r5
   a2420: eb140f38     	bl	0x5a6108 <.text+0x596008> @ imm = #0x503ce0
   a2424: e59f7fd4     	ldr	r7, [pc, #0xfd4]        @ 0xa3400 <.text+0x93300>
   a2428: e1a00005     	mov	r0, r5
   a242c: e79f7007     	ldr	r7, [pc, r7]
   a2430: eb1410a3     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x50428c
   a2434: e3570003     	cmp	r7, #3
   a2438: 0a000010     	beq	0xa2480 <.text+0x92380> @ imm = #0x40
   a243c: e3570002     	cmp	r7, #2
   a2440: 0a000098     	beq	0xa26a8 <.text+0x925a8> @ imm = #0x260
   a2444: e3570001     	cmp	r7, #1
   a2448: 1a000e1d     	bne	0xa5cc4 <.text+0x95bc4> @ imm = #0x3874
   a244c: ed980b0a     	vldr	d0, [r8, #40]
   a2450: eeb40bcb     	vcmpe.f64	d0, d11
   a2454: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a2458: da0004bd     	ble	0xa3754 <.text+0x93654> @ imm = #0x12f4
   a245c: e59a0000     	ldr	r0, [r10]
   a2460: e2401001     	sub	r1, r0, #1
   a2464: e0000190     	mul	r0, r0, r1
   a2468: e3100001     	tst	r0, #1
   a246c: 0a000492     	beq	0xa36bc <.text+0x935bc> @ imm = #0x1248
   a2470: e5940000     	ldr	r0, [r4]
   a2474: e3500009     	cmp	r0, #9
   a2478: ca00049a     	bgt	0xa36e8 <.text+0x935e8> @ imm = #0x1268
   a247c: ea00048e     	b	0xa36bc <.text+0x935bc> @ imm = #0x1238
   a2480: e28d1040     	add	r1, sp, #64
   a2484: e2869020     	add	r9, r6, #32
   a2488: e1a00001     	mov	r0, r1
   a248c: e1a0c009     	mov	r12, r9
   a2490: e89000fc     	ldm	r0, {r2, r3, r4, r5, r6, r7}
   a2494: e1a00008     	mov	r0, r8
   a2498: e88c00fc     	stm	r12, {r2, r3, r4, r5, r6, r7}
   a249c: e3a0203c     	mov	r2, #60
   a24a0: eb000f3a     	bl	0xa6190 <.text+0x96090> @ imm = #0x3ce8
   a24a4: e3500002     	cmp	r0, #2
   a24a8: 1a0001ba     	bne	0xa2b98 <.text+0x92a98> @ imm = #0x6e8
   a24ac: e59f7ff4     	ldr	r7, [pc, #0xff4]        @ 0xa34a8 <.text+0x933a8>
   a24b0: e3a09003     	mov	r9, #3
   a24b4: e58d9000     	str	r9, [sp]
   a24b8: e300318a     	movw	r3, #0x18a
   a24bc: e08f7007     	add	r7, pc, r7
   a24c0: ed970b04     	vldr	d0, [r7, #16]
   a24c4: e5972018     	ldr	r2, [r7, #0x18]
   a24c8: e597101c     	ldr	r1, [r7, #0x1c]
   a24cc: e58d1018     	str	r1, [sp, #0x18]
   a24d0: e58d201c     	str	r2, [sp, #0x1c]
   a24d4: ed8d0b04     	vstr	d0, [sp, #16]
   a24d8: e5970008     	ldr	r0, [r7, #0x8]
   a24dc: e59f1fc8     	ldr	r1, [pc, #0xfc8]        @ 0xa34ac <.text+0x933ac>
   a24e0: e58d0008     	str	r0, [sp, #0x8]
   a24e4: e08f1001     	add	r1, pc, r1
   a24e8: e58d1004     	str	r1, [sp, #0x4]
   a24ec: e59f4fbc     	ldr	r4, [pc, #0xfbc]        @ 0xa34b0 <.text+0x933b0>
   a24f0: e59f5fbc     	ldr	r5, [pc, #0xfbc]        @ 0xa34b4 <.text+0x933b4>
   a24f4: e59f6fbc     	ldr	r6, [pc, #0xfbc]        @ 0xa34b8 <.text+0x933b8>
   a24f8: e08f4004     	add	r4, pc, r4
   a24fc: e08f5005     	add	r5, pc, r5
   a2500: e08f6006     	add	r6, pc, r6
   a2504: e1a00004     	mov	r0, r4
   a2508: e1a01005     	mov	r1, r5
   a250c: e1a02006     	mov	r2, r6
   a2510: eb015eeb     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57bac
   a2514: ed970b0a     	vldr	d0, [r7, #40]
   a2518: e300318d     	movw	r3, #0x18d
   a251c: e5972030     	ldr	r2, [r7, #0x30]
   a2520: e5971034     	ldr	r1, [r7, #0x34]
   a2524: e58d201c     	str	r2, [sp, #0x1c]
   a2528: e1a02006     	mov	r2, r6
   a252c: e58d1018     	str	r1, [sp, #0x18]
   a2530: ed8d0b04     	vstr	d0, [sp, #16]
   a2534: e58d9000     	str	r9, [sp]
   a2538: e5970020     	ldr	r0, [r7, #0x20]
   a253c: e59f1f78     	ldr	r1, [pc, #0xf78]        @ 0xa34bc <.text+0x933bc>
   a2540: e58d0008     	str	r0, [sp, #0x8]
   a2544: e1a00004     	mov	r0, r4
   a2548: e08f1001     	add	r1, pc, r1
   a254c: e58d1004     	str	r1, [sp, #0x4]
   a2550: e1a01005     	mov	r1, r5
   a2554: eb015eda     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57b68
   a2558: ed9d0b12     	vldr	d0, [sp, #72]
   a255c: e3a03e19     	mov	r3, #400
   a2560: e59d1054     	ldr	r1, [sp, #0x54]
   a2564: e59d2050     	ldr	r2, [sp, #0x50]
   a2568: e58d201c     	str	r2, [sp, #0x1c]
   a256c: e1a02006     	mov	r2, r6
   a2570: e58d1018     	str	r1, [sp, #0x18]
   a2574: ed8d0b04     	vstr	d0, [sp, #16]
   a2578: e58d9000     	str	r9, [sp]
   a257c: e59d0040     	ldr	r0, [sp, #0x40]
   a2580: e59f1f38     	ldr	r1, [pc, #0xf38]        @ 0xa34c0 <.text+0x933c0>
   a2584: e58d0008     	str	r0, [sp, #0x8]
   a2588: e1a00004     	mov	r0, r4
   a258c: e08f1001     	add	r1, pc, r1
   a2590: e58d1004     	str	r1, [sp, #0x4]
   a2594: e1a01005     	mov	r1, r5
   a2598: eb015ec9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57b24
   a259c: e598001c     	ldr	r0, [r8, #0x1c]
   a25a0: e59810dc     	ldr	r1, [r8, #0xdc]
   a25a4: e598220c     	ldr	r2, [r8, #0x20c]
   a25a8: e2414f7d     	sub	r4, r1, #500
   a25ac: e2425064     	sub	r5, r2, #100
   a25b0: ebfef9e6     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x41868
   a25b4: e1540000     	cmp	r4, r0
   a25b8: e1a06007     	mov	r6, r7
   a25bc: da000204     	ble	0xa2dd4 <.text+0x92cd4> @ imm = #0x810
   a25c0: e59a0000     	ldr	r0, [r10]
   a25c4: e59f2ef8     	ldr	r2, [pc, #0xef8]        @ 0xa34c4 <.text+0x933c4>
   a25c8: e2401001     	sub	r1, r0, #1
   a25cc: e0000190     	mul	r0, r0, r1
   a25d0: e79f2002     	ldr	r2, [pc, r2]
   a25d4: e3100001     	tst	r0, #1
   a25d8: e59a0000     	ldr	r0, [r10]
   a25dc: e2401001     	sub	r1, r0, #1
   a25e0: e0010190     	mul	r1, r0, r1
   a25e4: e59800dc     	ldr	r0, [r8, #0xdc]
   a25e8: e2400f7d     	sub	r0, r0, #500
   a25ec: e3110001     	tst	r1, #1
   a25f0: 0a000002     	beq	0xa2600 <.text+0x92500> @ imm = #0x8
   a25f4: e5921000     	ldr	r1, [r2]
   a25f8: e351000a     	cmp	r1, #10
   a25fc: aafffff5     	bge	0xa25d8 <.text+0x924d8> @ imm = #-0x2c
   a2600: e1500005     	cmp	r0, r5
   a2604: da0001f6     	ble	0xa2de4 <.text+0x92ce4> @ imm = #0x7d8
   a2608: e3a00002     	mov	r0, #2
   a260c: e30032be     	movw	r3, #0x2be
   a2610: e58d0000     	str	r0, [sp]
   a2614: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0xa35f0 <.text+0x934f0>
   a2618: e08f0000     	add	r0, pc, r0
   a261c: e58d0004     	str	r0, [sp, #0x4]
   a2620: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0xa3620 <.text+0x93520>
   a2624: e59f1ff8     	ldr	r1, [pc, #0xff8]        @ 0xa3624 <.text+0x93524>
   a2628: e59f2ff8     	ldr	r2, [pc, #0xff8]        @ 0xa3628 <.text+0x93528>
   a262c: e08f0000     	add	r0, pc, r0
   a2630: e08f1001     	add	r1, pc, r1
   a2634: e08f2002     	add	r2, pc, r2
   a2638: eb015ea1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57a84
   a263c: e59d4038     	ldr	r4, [sp, #0x38]
   a2640: e1a00004     	mov	r0, r4
   a2644: eb140eaf     	bl	0x5a6108 <.text+0x596008> @ imm = #0x503abc
   a2648: e3a00000     	mov	r0, #0
   a264c: e5860000     	str	r0, [r6]
   a2650: e1a00004     	mov	r0, r4
   a2654: eb14101a     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x504068
   a2658: e59f4fdc     	ldr	r4, [pc, #0xfdc]        @ 0xa363c <.text+0x9353c>
   a265c: e79f4004     	ldr	r4, [pc, r4]
   a2660: ea000d97     	b	0xa5cc4 <.text+0x95bc4> @ imm = #0x365c
   a2664: e320f000     	nop
   a2668: 00000000     	andeq	r0, r0, r0
   a266c: 403e0000     	eorsmi	r0, lr, r0
   a2670: 00000000     	andeq	r0, r0, r0
   a2674: 4058a000     	subsmi	r10, r8, r0
   a2678: 00000000     	andeq	r0, r0, r0
   a267c: bff00000     	svclt	#0xf00000
   a2680: 00000000     	andeq	r0, r0, r0
   a2684: 40590000     	subsmi	r0, r9, r0
   a2688: 00000000     	andeq	r0, r0, r0
   a268c: 3fe00000     	svclo	#0xe00000
   a2690: 00000000     	andeq	r0, r0, r0
   a2694: 40584000     	subsmi	r4, r8, r0
   a2698: 00000000     	andeq	r0, r0, r0
   a269c: 4072c000     	rsbsmi	r12, r2, r0
   a26a0: d2f1a9fc     	rscsle	r10, r1, #252, #18
   a26a4: 3f50624d     	svclo	#0x50624d
   a26a8: e59a0000     	ldr	r0, [r10]
   a26ac: e2401001     	sub	r1, r0, #1
   a26b0: e0000190     	mul	r0, r0, r1
   a26b4: e3100001     	tst	r0, #1
   a26b8: e59a0000     	ldr	r0, [r10]
   a26bc: e2401001     	sub	r1, r0, #1
   a26c0: e0010190     	mul	r1, r0, r1
   a26c4: e5980050     	ldr	r0, [r8, #0x50]
   a26c8: e3110001     	tst	r1, #1
   a26cc: 0a000002     	beq	0xa26dc <.text+0x925dc> @ imm = #0x8
   a26d0: e5941000     	ldr	r1, [r4]
   a26d4: e3510009     	cmp	r1, #9
   a26d8: cafffff6     	bgt	0xa26b8 <.text+0x925b8> @ imm = #-0x28
   a26dc: e59d5034     	ldr	r5, [sp, #0x34]
   a26e0: e3500000     	cmp	r0, #0
   a26e4: 0a000197     	beq	0xa2d48 <.text+0x92c48> @ imm = #0x65c
   a26e8: e1a00008     	mov	r0, r8
   a26ec: ebff00e7     	bl	0x62a90 <.text+0x52990> @ imm = #-0x3fc64
   a26f0: e1a00008     	mov	r0, r8
   a26f4: ebfefcf5     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x40c2c
   a26f8: e3500000     	cmp	r0, #0
   a26fc: 15d80108     	ldrbne	r0, [r8, #0x108]
   a2700: 13500000     	cmpne	r0, #0
   a2704: 1a000249     	bne	0xa3030 <.text+0x92f30> @ imm = #0x924
   a2708: e59a0000     	ldr	r0, [r10]
   a270c: e2401001     	sub	r1, r0, #1
   a2710: e0000190     	mul	r0, r0, r1
   a2714: e3100001     	tst	r0, #1
   a2718: e59a0000     	ldr	r0, [r10]
   a271c: e2401001     	sub	r1, r0, #1
   a2720: e0010190     	mul	r1, r0, r1
   a2724: e5d80ff0     	ldrb	r0, [r8, #0xff0]
   a2728: e3110001     	tst	r1, #1
   a272c: 0a000002     	beq	0xa273c <.text+0x9263c> @ imm = #0x8
   a2730: e5941000     	ldr	r1, [r4]
   a2734: e3510009     	cmp	r1, #9
   a2738: cafffff6     	bgt	0xa2718 <.text+0x92618> @ imm = #-0x28
   a273c: e3500000     	cmp	r0, #0
   a2740: 1a000003     	bne	0xa2754 <.text+0x92654> @ imm = #0xc
   a2744: e59d0028     	ldr	r0, [sp, #0x28]
   a2748: e5900088     	ldr	r0, [r0, #0x88]
   a274c: e3500007     	cmp	r0, #7
   a2750: 1a000246     	bne	0xa3070 <.text+0x92f70> @ imm = #0x918
   a2754: e59a0000     	ldr	r0, [r10]
   a2758: e2401001     	sub	r1, r0, #1
   a275c: e0000190     	mul	r0, r0, r1
   a2760: e3100001     	tst	r0, #1
   a2764: e59a0000     	ldr	r0, [r10]
   a2768: ed960b04     	vldr	d0, [r6, #16]
   a276c: e2401001     	sub	r1, r0, #1
   a2770: e0000190     	mul	r0, r0, r1
   a2774: e3100001     	tst	r0, #1
   a2778: 0a000002     	beq	0xa2788 <.text+0x92688> @ imm = #0x8
   a277c: e5940000     	ldr	r0, [r4]
   a2780: e3500009     	cmp	r0, #9
   a2784: cafffff6     	bgt	0xa2764 <.text+0x92664> @ imm = #-0x28
   a2788: eeb40bcc     	vcmpe.f64	d0, d12
   a278c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a2790: ba00000f     	blt	0xa27d4 <.text+0x926d4> @ imm = #0x3c
   a2794: e59a0000     	ldr	r0, [r10]
   a2798: e1a09006     	mov	r9, r6
   a279c: e2401001     	sub	r1, r0, #1
   a27a0: e0000190     	mul	r0, r0, r1
   a27a4: e3100001     	tst	r0, #1
   a27a8: 0a00050c     	beq	0xa3be0 <.text+0x93ae0> @ imm = #0x1430
   a27ac: e5940000     	ldr	r0, [r4]
   a27b0: e3500009     	cmp	r0, #9
   a27b4: ca000556     	bgt	0xa3d14 <.text+0x93c14> @ imm = #0x1558
   a27b8: ea000508     	b	0xa3be0 <.text+0x93ae0> @ imm = #0x1420
   a27bc: e59f4f50     	ldr	r4, [pc, #0xf50]        @ 0xa3714 <.text+0x93614>
   a27c0: eeb40bcc     	vcmpe.f64	d0, d12
   a27c4: e3a09001     	mov	r9, #1
   a27c8: e79f4004     	ldr	r4, [pc, r4]
   a27cc: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a27d0: aaffffef     	bge	0xa2794 <.text+0x92694> @ imm = #-0x44
   a27d4: e598001c     	ldr	r0, [r8, #0x1c]
   a27d8: e59850dc     	ldr	r5, [r8, #0xdc]
   a27dc: e598720c     	ldr	r7, [r8, #0x20c]
   a27e0: ebfef958     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x41aa0
   a27e4: e5941000     	ldr	r1, [r4]
   a27e8: e2852ffa     	add	r2, r5, #1000
   a27ec: e351000a     	cmp	r1, #10
   a27f0: e3a01000     	mov	r1, #0
   a27f4: b3001001     	movwlt	r1, #0x1
   a27f8: e1520000     	cmp	r2, r0
   a27fc: aa00000a     	bge	0xa282c <.text+0x9272c> @ imm = #0x28
   a2800: e59a0000     	ldr	r0, [r10]
   a2804: e2401001     	sub	r1, r0, #1
   a2808: e0010190     	mul	r1, r0, r1
   a280c: e59800dc     	ldr	r0, [r8, #0xdc]
   a2810: e2800ffa     	add	r0, r0, #1000
   a2814: e3110001     	tst	r1, #1
   a2818: 0a00000a     	beq	0xa2848 <.text+0x92748> @ imm = #0x28
   a281c: e5941000     	ldr	r1, [r4]
   a2820: e351000a     	cmp	r1, #10
   a2824: aafffff5     	bge	0xa2800 <.text+0x92700> @ imm = #-0x2c
   a2828: ea000006     	b	0xa2848 <.text+0x92748> @ imm = #0x18
   a282c: e59a0000     	ldr	r0, [r10]
   a2830: e2402001     	sub	r2, r0, #1
   a2834: e0000290     	mul	r0, r0, r2
   a2838: e1c90000     	bic	r0, r9, r0
   a283c: e1900001     	orrs	r0, r0, r1
   a2840: 0a0000d1     	beq	0xa2b8c <.text+0x92a8c> @ imm = #0x344
   a2844: ea0000c6     	b	0xa2b64 <.text+0x92a64> @ imm = #0x318
   a2848: e59a2000     	ldr	r2, [r10]
   a284c: e2871064     	add	r1, r7, #100
   a2850: e2423001     	sub	r3, r2, #1
   a2854: e0020392     	mul	r2, r2, r3
   a2858: e3120001     	tst	r2, #1
   a285c: e59a2000     	ldr	r2, [r10]
   a2860: e2423001     	sub	r3, r2, #1
   a2864: e0020392     	mul	r2, r2, r3
   a2868: e3120001     	tst	r2, #1
   a286c: 0a000002     	beq	0xa287c <.text+0x9277c> @ imm = #0x8
   a2870: e5942000     	ldr	r2, [r4]
   a2874: e3520009     	cmp	r2, #9
   a2878: cafffff7     	bgt	0xa285c <.text+0x9275c> @ imm = #-0x24
   a287c: e3a09001     	mov	r9, #1
   a2880: e1500001     	cmp	r0, r1
   a2884: ba0002f1     	blt	0xa3450 <.text+0x93350> @ imm = #0xbc4
   a2888: e28d1040     	add	r1, sp, #64
   a288c: e286c020     	add	r12, r6, #32
   a2890: e58dc030     	str	r12, [sp, #0x30]
   a2894: e1a04001     	mov	r4, r1
   a2898: e89400ed     	ldm	r4, {r0, r2, r3, r5, r6, r7}
   a289c: e88c00ed     	stm	r12, {r0, r2, r3, r5, r6, r7}
   a28a0: e1a00008     	mov	r0, r8
   a28a4: e3a02078     	mov	r2, #120
   a28a8: eb000e38     	bl	0xa6190 <.text+0x96090> @ imm = #0x38e0
   a28ac: e3500002     	cmp	r0, #2
   a28b0: 0a0002ef     	beq	0xa3474 <.text+0x93374> @ imm = #0xbbc
   a28b4: e1a00008     	mov	r0, r8
   a28b8: eb001042     	bl	0xa69c8 <.text+0x968c8> @ imm = #0x4108
   a28bc: e59f4e54     	ldr	r4, [pc, #0xe54]        @ 0xa3718 <.text+0x93618>
   a28c0: e3500000     	cmp	r0, #0
   a28c4: e79f4004     	ldr	r4, [pc, r4]
   a28c8: 0a000349     	beq	0xa35f4 <.text+0x934f4> @ imm = #0xd24
   a28cc: e59a0000     	ldr	r0, [r10]
   a28d0: ed9d0b12     	vldr	d0, [sp, #72]
   a28d4: e59f6e40     	ldr	r6, [pc, #0xe40]        @ 0xa371c <.text+0x9361c>
   a28d8: e2401001     	sub	r1, r0, #1
   a28dc: e08f6006     	add	r6, pc, r6
   a28e0: e0000190     	mul	r0, r0, r1
   a28e4: e5941000     	ldr	r1, [r4]
   a28e8: ed961b04     	vldr	d1, [r6, #16]
   a28ec: e351000a     	cmp	r1, #10
   a28f0: e3a01000     	mov	r1, #0
   a28f4: ee300b41     	vsub.f64	d0, d0, d1
   a28f8: b3001001     	movwlt	r1, #0x1
   a28fc: e1c90000     	bic	r0, r9, r0
   a2900: e1800001     	orr	r0, r0, r1
   a2904: eeb40bcd     	vcmpe.f64	d0, d13
   a2908: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a290c: da000346     	ble	0xa362c <.text+0x9352c> @ imm = #0xd18
   a2910: e3500000     	cmp	r0, #0
   a2914: 0a00004d     	beq	0xa2a50 <.text+0x92950> @ imm = #0x134
   a2918: e28d1040     	add	r1, sp, #64
   a291c: e2860008     	add	r0, r6, #8
   a2920: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a2924: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a2928: e3a07003     	mov	r7, #3
   a292c: e300318a     	movw	r3, #0x18a
   a2930: e59f9de8     	ldr	r9, [pc, #0xde8]        @ 0xa3720 <.text+0x93620>
   a2934: e58d7000     	str	r7, [sp]
   a2938: e08f9009     	add	r9, pc, r9
   a293c: ed990b04     	vldr	d0, [r9, #16]
   a2940: e5992018     	ldr	r2, [r9, #0x18]
   a2944: e599101c     	ldr	r1, [r9, #0x1c]
   a2948: e58d1018     	str	r1, [sp, #0x18]
   a294c: e58d201c     	str	r2, [sp, #0x1c]
   a2950: ed8d0b04     	vstr	d0, [sp, #16]
   a2954: e5990008     	ldr	r0, [r9, #0x8]
   a2958: e59f1dc4     	ldr	r1, [pc, #0xdc4]        @ 0xa3724 <.text+0x93624>
   a295c: e58d0008     	str	r0, [sp, #0x8]
   a2960: e08f1001     	add	r1, pc, r1
   a2964: e58d1004     	str	r1, [sp, #0x4]
   a2968: e59f4db8     	ldr	r4, [pc, #0xdb8]        @ 0xa3728 <.text+0x93628>
   a296c: e59f5db8     	ldr	r5, [pc, #0xdb8]        @ 0xa372c <.text+0x9362c>
   a2970: e59f6db8     	ldr	r6, [pc, #0xdb8]        @ 0xa3730 <.text+0x93630>
   a2974: e08f4004     	add	r4, pc, r4
   a2978: e08f5005     	add	r5, pc, r5
   a297c: e08f6006     	add	r6, pc, r6
   a2980: e1a00004     	mov	r0, r4
   a2984: e1a01005     	mov	r1, r5
   a2988: e1a02006     	mov	r2, r6
   a298c: eb015dcc     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57730
   a2990: ed990b0a     	vldr	d0, [r9, #40]
   a2994: e300318d     	movw	r3, #0x18d
   a2998: e5992030     	ldr	r2, [r9, #0x30]
   a299c: e5991034     	ldr	r1, [r9, #0x34]
   a29a0: e58d201c     	str	r2, [sp, #0x1c]
   a29a4: e1a02006     	mov	r2, r6
   a29a8: e58d1018     	str	r1, [sp, #0x18]
   a29ac: ed8d0b04     	vstr	d0, [sp, #16]
   a29b0: e58d7000     	str	r7, [sp]
   a29b4: e5990020     	ldr	r0, [r9, #0x20]
   a29b8: e59f1d74     	ldr	r1, [pc, #0xd74]        @ 0xa3734 <.text+0x93634>
   a29bc: e58d0008     	str	r0, [sp, #0x8]
   a29c0: e1a00004     	mov	r0, r4
   a29c4: e08f1001     	add	r1, pc, r1
   a29c8: e58d1004     	str	r1, [sp, #0x4]
   a29cc: e1a01005     	mov	r1, r5
   a29d0: eb015dbb     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x576ec
   a29d4: ed9d0b12     	vldr	d0, [sp, #72]
   a29d8: e3a03e19     	mov	r3, #400
   a29dc: e59d1054     	ldr	r1, [sp, #0x54]
   a29e0: e59d2050     	ldr	r2, [sp, #0x50]
   a29e4: e58d201c     	str	r2, [sp, #0x1c]
   a29e8: e1a02006     	mov	r2, r6
   a29ec: e58d1018     	str	r1, [sp, #0x18]
   a29f0: e1a06009     	mov	r6, r9
   a29f4: ed8d0b04     	vstr	d0, [sp, #16]
   a29f8: e58d7000     	str	r7, [sp]
   a29fc: e59d0040     	ldr	r0, [sp, #0x40]
   a2a00: e59f1d30     	ldr	r1, [pc, #0xd30]        @ 0xa3738 <.text+0x93638>
   a2a04: e58d0008     	str	r0, [sp, #0x8]
   a2a08: e1a00004     	mov	r0, r4
   a2a0c: e08f1001     	add	r1, pc, r1
   a2a10: e58d1004     	str	r1, [sp, #0x4]
   a2a14: e1a01005     	mov	r1, r5
   a2a18: eb015da9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x576a4
   a2a1c: e3a00ffa     	mov	r0, #1000
   a2a20: eb01b145     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6c514
   a2a24: e59a0000     	ldr	r0, [r10]
   a2a28: ed990b04     	vldr	d0, [r9, #16]
   a2a2c: e2401001     	sub	r1, r0, #1
   a2a30: e0000190     	mul	r0, r0, r1
   a2a34: e3100001     	tst	r0, #1
   a2a38: 0affff5f     	beq	0xa27bc <.text+0x926bc> @ imm = #-0x284
   a2a3c: e59f0cf8     	ldr	r0, [pc, #0xcf8]        @ 0xa373c <.text+0x9363c>
   a2a40: e79f0000     	ldr	r0, [pc, r0]
   a2a44: e5900000     	ldr	r0, [r0]
   a2a48: e3500009     	cmp	r0, #9
   a2a4c: daffff5a     	ble	0xa27bc <.text+0x926bc> @ imm = #-0x298
   a2a50: e28d1040     	add	r1, sp, #64
   a2a54: e2860008     	add	r0, r6, #8
   a2a58: e3a09003     	mov	r9, #3
   a2a5c: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a2a60: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a2a64: e300318a     	movw	r3, #0x18a
   a2a68: e59f6ce0     	ldr	r6, [pc, #0xce0]        @ 0xa3750 <.text+0x93650>
   a2a6c: e58d9000     	str	r9, [sp]
   a2a70: e08f6006     	add	r6, pc, r6
   a2a74: ed960b04     	vldr	d0, [r6, #16]
   a2a78: e1a07006     	mov	r7, r6
   a2a7c: e5962018     	ldr	r2, [r6, #0x18]
   a2a80: e596101c     	ldr	r1, [r6, #0x1c]
   a2a84: e58d1018     	str	r1, [sp, #0x18]
   a2a88: e58d201c     	str	r2, [sp, #0x1c]
   a2a8c: ed8d0b04     	vstr	d0, [sp, #16]
   a2a90: e5960008     	ldr	r0, [r6, #0x8]
   a2a94: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0xa3a7c <.text+0x9397c>
   a2a98: e58d0008     	str	r0, [sp, #0x8]
   a2a9c: e08f1001     	add	r1, pc, r1
   a2aa0: e58d1004     	str	r1, [sp, #0x4]
   a2aa4: e59f4fd4     	ldr	r4, [pc, #0xfd4]        @ 0xa3a80 <.text+0x93980>
   a2aa8: e59f5fd4     	ldr	r5, [pc, #0xfd4]        @ 0xa3a84 <.text+0x93984>
   a2aac: e59f6fd4     	ldr	r6, [pc, #0xfd4]        @ 0xa3a88 <.text+0x93988>
   a2ab0: e08f4004     	add	r4, pc, r4
   a2ab4: e08f5005     	add	r5, pc, r5
   a2ab8: e08f6006     	add	r6, pc, r6
   a2abc: e1a00004     	mov	r0, r4
   a2ac0: e1a01005     	mov	r1, r5
   a2ac4: e1a02006     	mov	r2, r6
   a2ac8: eb015d7d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x575f4
   a2acc: ed970b0a     	vldr	d0, [r7, #40]
   a2ad0: e300318d     	movw	r3, #0x18d
   a2ad4: e5972030     	ldr	r2, [r7, #0x30]
   a2ad8: e5971034     	ldr	r1, [r7, #0x34]
   a2adc: e58d201c     	str	r2, [sp, #0x1c]
   a2ae0: e1a02006     	mov	r2, r6
   a2ae4: e58d1018     	str	r1, [sp, #0x18]
   a2ae8: ed8d0b04     	vstr	d0, [sp, #16]
   a2aec: e58d9000     	str	r9, [sp]
   a2af0: e5970020     	ldr	r0, [r7, #0x20]
   a2af4: e59f1f90     	ldr	r1, [pc, #0xf90]        @ 0xa3a8c <.text+0x9398c>
   a2af8: e58d0008     	str	r0, [sp, #0x8]
   a2afc: e1a00004     	mov	r0, r4
   a2b00: e08f1001     	add	r1, pc, r1
   a2b04: e58d1004     	str	r1, [sp, #0x4]
   a2b08: e1a01005     	mov	r1, r5
   a2b0c: eb015d6c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x575b0
   a2b10: ed9d0b12     	vldr	d0, [sp, #72]
   a2b14: e3a03e19     	mov	r3, #400
   a2b18: e59d1054     	ldr	r1, [sp, #0x54]
   a2b1c: e59d2050     	ldr	r2, [sp, #0x50]
   a2b20: e58d201c     	str	r2, [sp, #0x1c]
   a2b24: e1a02006     	mov	r2, r6
   a2b28: e58d1018     	str	r1, [sp, #0x18]
   a2b2c: e1a06007     	mov	r6, r7
   a2b30: ed8d0b04     	vstr	d0, [sp, #16]
   a2b34: e58d9000     	str	r9, [sp]
   a2b38: e59d0040     	ldr	r0, [sp, #0x40]
   a2b3c: e59f1f4c     	ldr	r1, [pc, #0xf4c]        @ 0xa3a90 <.text+0x93990>
   a2b40: e58d0008     	str	r0, [sp, #0x8]
   a2b44: e1a00004     	mov	r0, r4
   a2b48: e08f1001     	add	r1, pc, r1
   a2b4c: e58d1004     	str	r1, [sp, #0x4]
   a2b50: e1a01005     	mov	r1, r5
   a2b54: eb015d5a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57568
   a2b58: e3a00ffa     	mov	r0, #1000
   a2b5c: eb01b0f6     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6c3d8
   a2b60: eaffff6c     	b	0xa2918 <.text+0x92818> @ imm = #-0x250
   a2b64: e598001c     	ldr	r0, [r8, #0x1c]
   a2b68: ebfef876     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x41e28
   a2b6c: e59a1000     	ldr	r1, [r10]
   a2b70: e2412001     	sub	r2, r1, #1
   a2b74: e0010291     	mul	r1, r1, r2
   a2b78: e3110001     	tst	r1, #1
   a2b7c: 0affff31     	beq	0xa2848 <.text+0x92748> @ imm = #-0x33c
   a2b80: e5941000     	ldr	r1, [r4]
   a2b84: e3510009     	cmp	r1, #9
   a2b88: daffff2e     	ble	0xa2848 <.text+0x92748> @ imm = #-0x348
   a2b8c: e598001c     	ldr	r0, [r8, #0x1c]
   a2b90: ebfef86c     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x41e50
   a2b94: eafffff2     	b	0xa2b64 <.text+0x92a64> @ imm = #-0x38
   a2b98: e59d0040     	ldr	r0, [sp, #0x40]
   a2b9c: e5981064     	ldr	r1, [r8, #0x64]
   a2ba0: e1500001     	cmp	r0, r1
   a2ba4: aa0000d8     	bge	0xa2f0c <.text+0x92e0c> @ imm = #0x360
   a2ba8: e59a0000     	ldr	r0, [r10]
   a2bac: e58d9030     	str	r9, [sp, #0x30]
   a2bb0: e3a09001     	mov	r9, #1
   a2bb4: e2401001     	sub	r1, r0, #1
   a2bb8: e59f6ff4     	ldr	r6, [pc, #0xff4]        @ 0xa3bb4 <.text+0x93ab4>
   a2bbc: e59f4ff4     	ldr	r4, [pc, #0xff4]        @ 0xa3bb8 <.text+0x93ab8>
   a2bc0: e0000190     	mul	r0, r0, r1
   a2bc4: e08f6006     	add	r6, pc, r6
   a2bc8: e79f4004     	ldr	r4, [pc, r4]
   a2bcc: e3100001     	tst	r0, #1
   a2bd0: e59a0000     	ldr	r0, [r10]
   a2bd4: ed9d0b12     	vldr	d0, [sp, #72]
   a2bd8: e2401001     	sub	r1, r0, #1
   a2bdc: ed961b0a     	vldr	d1, [r6, #40]
   a2be0: e0000190     	mul	r0, r0, r1
   a2be4: e3100001     	tst	r0, #1
   a2be8: 0a000002     	beq	0xa2bf8 <.text+0x92af8> @ imm = #0x8
   a2bec: e5940000     	ldr	r0, [r4]
   a2bf0: e3500009     	cmp	r0, #9
   a2bf4: cafffff5     	bgt	0xa2bd0 <.text+0x92ad0> @ imm = #-0x2c
   a2bf8: ee311b40     	vsub.f64	d1, d1, d0
   a2bfc: eeb41bc8     	vcmpe.f64	d1, d8
   a2c00: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a2c04: da0001ec     	ble	0xa33bc <.text+0x932bc> @ imm = #0x7b0
   a2c08: e3a00002     	mov	r0, #2
   a2c0c: ed8d0b02     	vstr	d0, [sp, #8]
   a2c10: e58d0000     	str	r0, [sp]
   a2c14: e30032e3     	movw	r3, #0x2e3
   a2c18: e59f0f9c     	ldr	r0, [pc, #0xf9c]        @ 0xa3bbc <.text+0x93abc>
   a2c1c: e08f0000     	add	r0, pc, r0
   a2c20: e58d0004     	str	r0, [sp, #0x4]
   a2c24: e59f0f94     	ldr	r0, [pc, #0xf94]        @ 0xa3bc0 <.text+0x93ac0>
   a2c28: e59f7f94     	ldr	r7, [pc, #0xf94]        @ 0xa3bc4 <.text+0x93ac4>
   a2c2c: e59f2f94     	ldr	r2, [pc, #0xf94]        @ 0xa3bc8 <.text+0x93ac8>
   a2c30: e08f0000     	add	r0, pc, r0
   a2c34: e08f7007     	add	r7, pc, r7
   a2c38: e08f2002     	add	r2, pc, r2
   a2c3c: e1a01007     	mov	r1, r7
   a2c40: e1a09002     	mov	r9, r2
   a2c44: eb015d1e     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57478
   a2c48: ed960b04     	vldr	d0, [r6, #16]
   a2c4c: e300318a     	movw	r3, #0x18a
   a2c50: e596101c     	ldr	r1, [r6, #0x1c]
   a2c54: e5962018     	ldr	r2, [r6, #0x18]
   a2c58: e58d1018     	str	r1, [sp, #0x18]
   a2c5c: e3a01003     	mov	r1, #3
   a2c60: e58d201c     	str	r2, [sp, #0x1c]
   a2c64: e1a02009     	mov	r2, r9
   a2c68: ed8d0b04     	vstr	d0, [sp, #16]
   a2c6c: e58d1000     	str	r1, [sp]
   a2c70: e5960008     	ldr	r0, [r6, #0x8]
   a2c74: e59f1f50     	ldr	r1, [pc, #0xf50]        @ 0xa3bcc <.text+0x93acc>
   a2c78: e58d0008     	str	r0, [sp, #0x8]
   a2c7c: e08f1001     	add	r1, pc, r1
   a2c80: e58d1004     	str	r1, [sp, #0x4]
   a2c84: e59f5f44     	ldr	r5, [pc, #0xf44]        @ 0xa3bd0 <.text+0x93ad0>
   a2c88: e1a01007     	mov	r1, r7
   a2c8c: e08f5005     	add	r5, pc, r5
   a2c90: e1a00005     	mov	r0, r5
   a2c94: eb015d0a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57428
   a2c98: ed960b0a     	vldr	d0, [r6, #40]
   a2c9c: e300318d     	movw	r3, #0x18d
   a2ca0: e5961034     	ldr	r1, [r6, #0x34]
   a2ca4: e5962030     	ldr	r2, [r6, #0x30]
   a2ca8: e58d1018     	str	r1, [sp, #0x18]
   a2cac: e3a01003     	mov	r1, #3
   a2cb0: e58d201c     	str	r2, [sp, #0x1c]
   a2cb4: e1a02009     	mov	r2, r9
   a2cb8: ed8d0b04     	vstr	d0, [sp, #16]
   a2cbc: e58d1000     	str	r1, [sp]
   a2cc0: e5960020     	ldr	r0, [r6, #0x20]
   a2cc4: e59f1f08     	ldr	r1, [pc, #0xf08]        @ 0xa3bd4 <.text+0x93ad4>
   a2cc8: e58d0008     	str	r0, [sp, #0x8]
   a2ccc: e1a00005     	mov	r0, r5
   a2cd0: e08f1001     	add	r1, pc, r1
   a2cd4: e58d1004     	str	r1, [sp, #0x4]
   a2cd8: e1a01007     	mov	r1, r7
   a2cdc: eb015cf8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x573e0
   a2ce0: ed9d0b12     	vldr	d0, [sp, #72]
   a2ce4: e3a03e19     	mov	r3, #400
   a2ce8: e59d1054     	ldr	r1, [sp, #0x54]
   a2cec: e59d2050     	ldr	r2, [sp, #0x50]
   a2cf0: e58d1018     	str	r1, [sp, #0x18]
   a2cf4: e3a01003     	mov	r1, #3
   a2cf8: e58d201c     	str	r2, [sp, #0x1c]
   a2cfc: e1a02009     	mov	r2, r9
   a2d00: ed8d0b04     	vstr	d0, [sp, #16]
   a2d04: e58d1000     	str	r1, [sp]
   a2d08: e59d0040     	ldr	r0, [sp, #0x40]
   a2d0c: e59f1ec4     	ldr	r1, [pc, #0xec4]        @ 0xa3bd8 <.text+0x93ad8>
   a2d10: e58d0008     	str	r0, [sp, #0x8]
   a2d14: e1a00005     	mov	r0, r5
   a2d18: e08f1001     	add	r1, pc, r1
   a2d1c: e58d1004     	str	r1, [sp, #0x4]
   a2d20: e1a01007     	mov	r1, r7
   a2d24: eb015ce6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57398
   a2d28: e59d5038     	ldr	r5, [sp, #0x38]
   a2d2c: e1a00005     	mov	r0, r5
   a2d30: eb140cf4     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5033d0
   a2d34: e3a00000     	mov	r0, #0
   a2d38: e5860000     	str	r0, [r6]
   a2d3c: e1a00005     	mov	r0, r5
   a2d40: eb140e5f     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x50397c
   a2d44: ea000bde     	b	0xa5cc4 <.text+0x95bc4> @ imm = #0x2f78
   a2d48: e3a00000     	mov	r0, #0
   a2d4c: e28d103c     	add	r1, sp, #60
   a2d50: e58d003c     	str	r0, [sp, #0x3c]
   a2d54: e1a00008     	mov	r0, r8
   a2d58: ebfeeb7d     	bl	0x5db54 <.text+0x4da54> @ imm = #-0x4520c
   a2d5c: e3500000     	cmp	r0, #0
   a2d60: 1a000c61     	bne	0xa5eec <.text+0x95dec> @ imm = #0x3184
   a2d64: e59a0000     	ldr	r0, [r10]
   a2d68: e2401001     	sub	r1, r0, #1
   a2d6c: e0000190     	mul	r0, r0, r1
   a2d70: e3100001     	tst	r0, #1
   a2d74: e59a0000     	ldr	r0, [r10]
   a2d78: e2401001     	sub	r1, r0, #1
   a2d7c: e0010190     	mul	r1, r0, r1
   a2d80: e5d80024     	ldrb	r0, [r8, #0x24]
   a2d84: e3110001     	tst	r1, #1
   a2d88: 0a000002     	beq	0xa2d98 <.text+0x92c98> @ imm = #0x8
   a2d8c: e5941000     	ldr	r1, [r4]
   a2d90: e3510009     	cmp	r1, #9
   a2d94: cafffff6     	bgt	0xa2d74 <.text+0x92c74> @ imm = #-0x28
   a2d98: e3500000     	cmp	r0, #0
   a2d9c: 0afffe51     	beq	0xa26e8 <.text+0x925e8> @ imm = #-0x6bc
   a2da0: ebfdefec     	bl	0x1ed58 <.text+0xec58>  @ imm = #-0x84050
   a2da4: ed981b0a     	vldr	d1, [r8, #40]
   a2da8: ee300b41     	vsub.f64	d0, d0, d1
   a2dac: eeb40bcf     	vcmpe.f64	d0, d15
   a2db0: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a2db4: 5afffe4b     	bpl	0xa26e8 <.text+0x925e8> @ imm = #-0x6d4
   a2db8: e59d003c     	ldr	r0, [sp, #0x3c]
   a2dbc: e5981058     	ldr	r1, [r8, #0x58]
   a2dc0: e0510000     	subs	r0, r1, r0
   a2dc4: 42600000     	rsbmi	r0, r0, #0
   a2dc8: e3500001     	cmp	r0, #1
   a2dcc: cafffd4c     	bgt	0xa2304 <.text+0x92204> @ imm = #-0xad0
   a2dd0: eafffe44     	b	0xa26e8 <.text+0x925e8> @ imm = #-0x6f0
   a2dd4: e598001c     	ldr	r0, [r8, #0x1c]
   a2dd8: ebfef7dc     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x42090
   a2ddc: e1500005     	cmp	r0, r5
   a2de0: cafffe08     	bgt	0xa2608 <.text+0x92508> @ imm = #-0x7e0
   a2de4: e1a00008     	mov	r0, r8
   a2de8: e1a01005     	mov	r1, r5
   a2dec: eb000e44     	bl	0xa6704 <.text+0x96604> @ imm = #0x3910
   a2df0: ed960b04     	vldr	d0, [r6, #16]
   a2df4: e3a09003     	mov	r9, #3
   a2df8: e5962018     	ldr	r2, [r6, #0x18]
   a2dfc: e1a07006     	mov	r7, r6
   a2e00: e596101c     	ldr	r1, [r6, #0x1c]
   a2e04: e300318a     	movw	r3, #0x18a
   a2e08: e58d1018     	str	r1, [sp, #0x18]
   a2e0c: e58d201c     	str	r2, [sp, #0x1c]
   a2e10: ed8d0b04     	vstr	d0, [sp, #16]
   a2e14: e58d9000     	str	r9, [sp]
   a2e18: e5960008     	ldr	r0, [r6, #0x8]
   a2e1c: e59f1db8     	ldr	r1, [pc, #0xdb8]        @ 0xa3bdc <.text+0x93adc>
   a2e20: e58d0008     	str	r0, [sp, #0x8]
   a2e24: e08f1001     	add	r1, pc, r1
   a2e28: e58d1004     	str	r1, [sp, #0x4]
   a2e2c: e59f4ff8     	ldr	r4, [pc, #0xff8]        @ 0xa3e2c <.text+0x93d2c>
   a2e30: e59f5ff8     	ldr	r5, [pc, #0xff8]        @ 0xa3e30 <.text+0x93d30>
   a2e34: e59f6ff8     	ldr	r6, [pc, #0xff8]        @ 0xa3e34 <.text+0x93d34>
   a2e38: e08f4004     	add	r4, pc, r4
   a2e3c: e08f5005     	add	r5, pc, r5
   a2e40: e08f6006     	add	r6, pc, r6
   a2e44: e1a00004     	mov	r0, r4
   a2e48: e1a01005     	mov	r1, r5
   a2e4c: e1a02006     	mov	r2, r6
   a2e50: eb015c9b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5726c
   a2e54: e5b70020     	ldr	r0, [r7, #0x20]!
   a2e58: e300318d     	movw	r3, #0x18d
   a2e5c: e58d9000     	str	r9, [sp]
   a2e60: ed970b02     	vldr	d0, [r7, #8]
   a2e64: e5972010     	ldr	r2, [r7, #0x10]
   a2e68: e5971014     	ldr	r1, [r7, #0x14]
   a2e6c: e58d201c     	str	r2, [sp, #0x1c]
   a2e70: e1a02006     	mov	r2, r6
   a2e74: e58d1018     	str	r1, [sp, #0x18]
   a2e78: ed8d0b04     	vstr	d0, [sp, #16]
   a2e7c: e59f1fb4     	ldr	r1, [pc, #0xfb4]        @ 0xa3e38 <.text+0x93d38>
   a2e80: e58d0008     	str	r0, [sp, #0x8]
   a2e84: e1a00004     	mov	r0, r4
   a2e88: e08f1001     	add	r1, pc, r1
   a2e8c: e58d1004     	str	r1, [sp, #0x4]
   a2e90: e1a01005     	mov	r1, r5
   a2e94: eb015c8a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57228
   a2e98: ed9d0b12     	vldr	d0, [sp, #72]
   a2e9c: e3a03e19     	mov	r3, #400
   a2ea0: e59d1054     	ldr	r1, [sp, #0x54]
   a2ea4: e59d2050     	ldr	r2, [sp, #0x50]
   a2ea8: e58d201c     	str	r2, [sp, #0x1c]
   a2eac: e1a02006     	mov	r2, r6
   a2eb0: e58d1018     	str	r1, [sp, #0x18]
   a2eb4: ed8d0b04     	vstr	d0, [sp, #16]
   a2eb8: e58d9000     	str	r9, [sp]
   a2ebc: e59d0040     	ldr	r0, [sp, #0x40]
   a2ec0: e59f1f74     	ldr	r1, [pc, #0xf74]        @ 0xa3e3c <.text+0x93d3c>
   a2ec4: e58d0008     	str	r0, [sp, #0x8]
   a2ec8: e1a00004     	mov	r0, r4
   a2ecc: e08f1001     	add	r1, pc, r1
   a2ed0: e58d1004     	str	r1, [sp, #0x4]
   a2ed4: e1a01005     	mov	r1, r5
   a2ed8: eb015c79     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x571e4
   a2edc: e897007e     	ldm	r7, {r1, r2, r3, r4, r5, r6}
   a2ee0: e28d0040     	add	r0, sp, #64
   a2ee4: e880007e     	stm	r0, {r1, r2, r3, r4, r5, r6}
   a2ee8: e3010388     	movw	r0, #0x1388
   a2eec: e59f6f4c     	ldr	r6, [pc, #0xf4c]        @ 0xa3e40 <.text+0x93d40>
   a2ef0: e08f6006     	add	r6, pc, r6
   a2ef4: eb01b010     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6c040
   a2ef8: e59f4f44     	ldr	r4, [pc, #0xf44]        @ 0xa3e44 <.text+0x93d44>
   a2efc: e3a09001     	mov	r9, #1
   a2f00: e79f4004     	ldr	r4, [pc, r4]
   a2f04: e59d5034     	ldr	r5, [sp, #0x34]
   a2f08: eafffcff     	b	0xa230c <.text+0x9220c> @ imm = #-0xc04
   a2f0c: e59f6f34     	ldr	r6, [pc, #0xf34]        @ 0xa3e48 <.text+0x93d48>
   a2f10: e3a09003     	mov	r9, #3
   a2f14: e58d9000     	str	r9, [sp]
   a2f18: e300318a     	movw	r3, #0x18a
   a2f1c: e08f6006     	add	r6, pc, r6
   a2f20: ed960b04     	vldr	d0, [r6, #16]
   a2f24: e1a07006     	mov	r7, r6
   a2f28: e5962018     	ldr	r2, [r6, #0x18]
   a2f2c: e596101c     	ldr	r1, [r6, #0x1c]
   a2f30: e58d1018     	str	r1, [sp, #0x18]
   a2f34: e58d201c     	str	r2, [sp, #0x1c]
   a2f38: ed8d0b04     	vstr	d0, [sp, #16]
   a2f3c: e5960008     	ldr	r0, [r6, #0x8]
   a2f40: e59f1f04     	ldr	r1, [pc, #0xf04]        @ 0xa3e4c <.text+0x93d4c>
   a2f44: e58d0008     	str	r0, [sp, #0x8]
   a2f48: e08f1001     	add	r1, pc, r1
   a2f4c: e58d1004     	str	r1, [sp, #0x4]
   a2f50: e59f4ef8     	ldr	r4, [pc, #0xef8]        @ 0xa3e50 <.text+0x93d50>
   a2f54: e59f5ef8     	ldr	r5, [pc, #0xef8]        @ 0xa3e54 <.text+0x93d54>
   a2f58: e59f6ef8     	ldr	r6, [pc, #0xef8]        @ 0xa3e58 <.text+0x93d58>
   a2f5c: e08f4004     	add	r4, pc, r4
   a2f60: e08f5005     	add	r5, pc, r5
   a2f64: e08f6006     	add	r6, pc, r6
   a2f68: e1a00004     	mov	r0, r4
   a2f6c: e1a01005     	mov	r1, r5
   a2f70: e1a02006     	mov	r2, r6
   a2f74: eb015c52     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57148
   a2f78: ed970b0a     	vldr	d0, [r7, #40]
   a2f7c: e300318d     	movw	r3, #0x18d
   a2f80: e5972030     	ldr	r2, [r7, #0x30]
   a2f84: e5971034     	ldr	r1, [r7, #0x34]
   a2f88: e58d201c     	str	r2, [sp, #0x1c]
   a2f8c: e1a02006     	mov	r2, r6
   a2f90: e58d1018     	str	r1, [sp, #0x18]
   a2f94: ed8d0b04     	vstr	d0, [sp, #16]
   a2f98: e58d9000     	str	r9, [sp]
   a2f9c: e5970020     	ldr	r0, [r7, #0x20]
   a2fa0: e59f1eb4     	ldr	r1, [pc, #0xeb4]        @ 0xa3e5c <.text+0x93d5c>
   a2fa4: e58d0008     	str	r0, [sp, #0x8]
   a2fa8: e1a00004     	mov	r0, r4
   a2fac: e08f1001     	add	r1, pc, r1
   a2fb0: e58d1004     	str	r1, [sp, #0x4]
   a2fb4: e1a01005     	mov	r1, r5
   a2fb8: eb015c41     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x57104
   a2fbc: ed9d0b12     	vldr	d0, [sp, #72]
   a2fc0: e3a03e19     	mov	r3, #400
   a2fc4: e59d1054     	ldr	r1, [sp, #0x54]
   a2fc8: e59d2050     	ldr	r2, [sp, #0x50]
   a2fcc: e58d201c     	str	r2, [sp, #0x1c]
   a2fd0: e1a02006     	mov	r2, r6
   a2fd4: e58d1018     	str	r1, [sp, #0x18]
   a2fd8: ed8d0b04     	vstr	d0, [sp, #16]
   a2fdc: e58d9000     	str	r9, [sp]
   a2fe0: e59d0040     	ldr	r0, [sp, #0x40]
   a2fe4: e59f1e74     	ldr	r1, [pc, #0xe74]        @ 0xa3e60 <.text+0x93d60>
   a2fe8: e58d0008     	str	r0, [sp, #0x8]
   a2fec: e1a00004     	mov	r0, r4
   a2ff0: e08f1001     	add	r1, pc, r1
   a2ff4: e58d1004     	str	r1, [sp, #0x4]
   a2ff8: e1a01005     	mov	r1, r5
   a2ffc: eb015c30     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x570c0
   a3000: e598001c     	ldr	r0, [r8, #0x1c]
   a3004: e598220c     	ldr	r2, [r8, #0x20c]
   a3008: e59810dc     	ldr	r1, [r8, #0xdc]
   a300c: e2422064     	sub	r2, r2, #100
   a3010: e58d2030     	str	r2, [sp, #0x30]
   a3014: e2414f7d     	sub	r4, r1, #500
   a3018: ebfef74c     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x422d0
   a301c: e1540000     	cmp	r4, r0
   a3020: da0000f7     	ble	0xa3404 <.text+0x93304> @ imm = #0x3dc
   a3024: e59800dc     	ldr	r0, [r8, #0xdc]
   a3028: e2400f7d     	sub	r0, r0, #500
   a302c: ea0000f6     	b	0xa340c <.text+0x9330c> @ imm = #0x3d8
   a3030: e59a0000     	ldr	r0, [r10]
   a3034: e2401001     	sub	r1, r0, #1
   a3038: e0000190     	mul	r0, r0, r1
   a303c: e3100001     	tst	r0, #1
   a3040: e59a0000     	ldr	r0, [r10]
   a3044: e2401001     	sub	r1, r0, #1
   a3048: e0020190     	mul	r2, r0, r1
   a304c: e598010c     	ldr	r0, [r8, #0x10c]
   a3050: e5951048     	ldr	r1, [r5, #0x48]
   a3054: e3120001     	tst	r2, #1
   a3058: 0a000002     	beq	0xa3068 <.text+0x92f68> @ imm = #0x8
   a305c: e5942000     	ldr	r2, [r4]
   a3060: e3520009     	cmp	r2, #9
   a3064: cafffff5     	bgt	0xa3040 <.text+0x92f40> @ imm = #-0x2c
   a3068: e1510000     	cmp	r1, r0
   a306c: 3afffda5     	blo	0xa2708 <.text+0x92608> @ imm = #-0x96c
   a3070: ed9d0b12     	vldr	d0, [sp, #72]
   a3074: eeb40bce     	vcmpe.f64	d0, d14
   a3078: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a307c: ba000081     	blt	0xa3288 <.text+0x93188> @ imm = #0x204
   a3080: e598001c     	ldr	r0, [r8, #0x1c]
   a3084: e59810dc     	ldr	r1, [r8, #0xdc]
   a3088: e598720c     	ldr	r7, [r8, #0x20c]
   a308c: e2415f7d     	sub	r5, r1, #500
   a3090: ebfef72e     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x42348
   a3094: e1550000     	cmp	r5, r0
   a3098: da000002     	ble	0xa30a8 <.text+0x92fa8> @ imm = #0x8
   a309c: e59800dc     	ldr	r0, [r8, #0xdc]
   a30a0: e2400f7d     	sub	r0, r0, #500
   a30a4: ea000008     	b	0xa30cc <.text+0x92fcc> @ imm = #0x20
   a30a8: e59a0000     	ldr	r0, [r10]
   a30ac: e2401001     	sub	r1, r0, #1
   a30b0: e0000190     	mul	r0, r0, r1
   a30b4: e3100001     	tst	r0, #1
   a30b8: 0a000062     	beq	0xa3248 <.text+0x93148> @ imm = #0x188
   a30bc: e5940000     	ldr	r0, [r4]
   a30c0: e3500009     	cmp	r0, #9
   a30c4: ca000069     	bgt	0xa3270 <.text+0x93170> @ imm = #0x1a4
   a30c8: ea00005e     	b	0xa3248 <.text+0x93148> @ imm = #0x178
   a30cc: e59a2000     	ldr	r2, [r10]
   a30d0: e2471064     	sub	r1, r7, #100
   a30d4: e2423001     	sub	r3, r2, #1
   a30d8: e0020392     	mul	r2, r2, r3
   a30dc: e3120001     	tst	r2, #1
   a30e0: e59a2000     	ldr	r2, [r10]
   a30e4: e2423001     	sub	r3, r2, #1
   a30e8: e0020392     	mul	r2, r2, r3
   a30ec: e3120001     	tst	r2, #1
   a30f0: 0a000002     	beq	0xa3100 <.text+0x93000> @ imm = #0x8
   a30f4: e5942000     	ldr	r2, [r4]
   a30f8: e3520009     	cmp	r2, #9
   a30fc: cafffff7     	bgt	0xa30e0 <.text+0x92fe0> @ imm = #-0x24
   a3100: e1500001     	cmp	r0, r1
   a3104: ca0000ef     	bgt	0xa34c8 <.text+0x933c8> @ imm = #0x3bc
   a3108: e1a00008     	mov	r0, r8
   a310c: eb000d7c     	bl	0xa6704 <.text+0x96604> @ imm = #0x35f0
   a3110: e28d1040     	add	r1, sp, #64
   a3114: e286c020     	add	r12, r6, #32
   a3118: e1a04001     	mov	r4, r1
   a311c: e89400ed     	ldm	r4, {r0, r2, r3, r5, r6, r7}
   a3120: e88c00ed     	stm	r12, {r0, r2, r3, r5, r6, r7}
   a3124: e1a00008     	mov	r0, r8
   a3128: e3a0203c     	mov	r2, #60
   a312c: e59f4f9c     	ldr	r4, [pc, #0xf9c]        @ 0xa40d0 <.text+0x93fd0>
   a3130: e79f4004     	ldr	r4, [pc, r4]
   a3134: e59f6f98     	ldr	r6, [pc, #0xf98]        @ 0xa40d4 <.text+0x93fd4>
   a3138: e08f6006     	add	r6, pc, r6
   a313c: e1a09006     	mov	r9, r6
   a3140: eb000c12     	bl	0xa6190 <.text+0x96090> @ imm = #0x3048
   a3144: ed960b04     	vldr	d0, [r6, #16]
   a3148: e300318a     	movw	r3, #0x18a
   a314c: e596101c     	ldr	r1, [r6, #0x1c]
   a3150: e5962018     	ldr	r2, [r6, #0x18]
   a3154: e58d1018     	str	r1, [sp, #0x18]
   a3158: e3a01003     	mov	r1, #3
   a315c: e58d201c     	str	r2, [sp, #0x1c]
   a3160: ed8d0b04     	vstr	d0, [sp, #16]
   a3164: e58d1000     	str	r1, [sp]
   a3168: e5960008     	ldr	r0, [r6, #0x8]
   a316c: e59f1f64     	ldr	r1, [pc, #0xf64]        @ 0xa40d8 <.text+0x93fd8>
   a3170: e58d0008     	str	r0, [sp, #0x8]
   a3174: e08f1001     	add	r1, pc, r1
   a3178: e58d1004     	str	r1, [sp, #0x4]
   a317c: e59f5f58     	ldr	r5, [pc, #0xf58]        @ 0xa40dc <.text+0x93fdc>
   a3180: e59f7f58     	ldr	r7, [pc, #0xf58]        @ 0xa40e0 <.text+0x93fe0>
   a3184: e59f6f58     	ldr	r6, [pc, #0xf58]        @ 0xa40e4 <.text+0x93fe4>
   a3188: e08f5005     	add	r5, pc, r5
   a318c: e08f7007     	add	r7, pc, r7
   a3190: e08f6006     	add	r6, pc, r6
   a3194: e1a00005     	mov	r0, r5
   a3198: e1a01007     	mov	r1, r7
   a319c: e1a02006     	mov	r2, r6
   a31a0: eb015bc7     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56f1c
   a31a4: ed990b0a     	vldr	d0, [r9, #40]
   a31a8: e1a06009     	mov	r6, r9
   a31ac: e5992030     	ldr	r2, [r9, #0x30]
   a31b0: e300318d     	movw	r3, #0x18d
   a31b4: e5991034     	ldr	r1, [r9, #0x34]
   a31b8: e5990020     	ldr	r0, [r9, #0x20]
   a31bc: e3a09003     	mov	r9, #3
   a31c0: e58d1018     	str	r1, [sp, #0x18]
   a31c4: e58d201c     	str	r2, [sp, #0x1c]
   a31c8: ed8d0b04     	vstr	d0, [sp, #16]
   a31cc: e58d9000     	str	r9, [sp]
   a31d0: e59f1f10     	ldr	r1, [pc, #0xf10]        @ 0xa40e8 <.text+0x93fe8>
   a31d4: e58d0008     	str	r0, [sp, #0x8]
   a31d8: e1a00005     	mov	r0, r5
   a31dc: e08f1001     	add	r1, pc, r1
   a31e0: e58d1004     	str	r1, [sp, #0x4]
   a31e4: e1a01007     	mov	r1, r7
   a31e8: e59f7efc     	ldr	r7, [pc, #0xefc]        @ 0xa40ec <.text+0x93fec>
   a31ec: e08f7007     	add	r7, pc, r7
   a31f0: e1a02007     	mov	r2, r7
   a31f4: eb015bb2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56ec8
   a31f8: ed9d0b12     	vldr	d0, [sp, #72]
   a31fc: e3a03e19     	mov	r3, #400
   a3200: e59d1054     	ldr	r1, [sp, #0x54]
   a3204: e59d2050     	ldr	r2, [sp, #0x50]
   a3208: e58d201c     	str	r2, [sp, #0x1c]
   a320c: e1a02007     	mov	r2, r7
   a3210: e58d1018     	str	r1, [sp, #0x18]
   a3214: ed8d0b04     	vstr	d0, [sp, #16]
   a3218: e58d9000     	str	r9, [sp]
   a321c: e59d0040     	ldr	r0, [sp, #0x40]
   a3220: e59f1ec8     	ldr	r1, [pc, #0xec8]        @ 0xa40f0 <.text+0x93ff0>
   a3224: e58d0008     	str	r0, [sp, #0x8]
   a3228: e1a00005     	mov	r0, r5
   a322c: e08f1001     	add	r1, pc, r1
   a3230: e58d1004     	str	r1, [sp, #0x4]
   a3234: e59f1eb8     	ldr	r1, [pc, #0xeb8]        @ 0xa40f4 <.text+0x93ff4>
   a3238: e08f1001     	add	r1, pc, r1
   a323c: eb015ba0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56e80
   a3240: eaffff8a     	b	0xa3070 <.text+0x92f70> @ imm = #-0x1d8
   a3244: 00545a77     	subseq	r5, r4, r7, ror r10
   a3248: e598001c     	ldr	r0, [r8, #0x1c]
   a324c: ebfef6bf     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x42504
   a3250: e59a1000     	ldr	r1, [r10]
   a3254: e2412001     	sub	r2, r1, #1
   a3258: e0010291     	mul	r1, r1, r2
   a325c: e3110001     	tst	r1, #1
   a3260: 0affff99     	beq	0xa30cc <.text+0x92fcc> @ imm = #-0x19c
   a3264: e5941000     	ldr	r1, [r4]
   a3268: e3510009     	cmp	r1, #9
   a326c: daffff96     	ble	0xa30cc <.text+0x92fcc> @ imm = #-0x1a8
   a3270: e598001c     	ldr	r0, [r8, #0x1c]
   a3274: ebfef6b5     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x4252c
   a3278: eafffff2     	b	0xa3248 <.text+0x93148> @ imm = #-0x38
   a327c: 005707bc     	ldrheq	r0, [r7], #-124
   a3280: 0053d828     	subseq	sp, r3, r8, lsr #16
   a3284: 0053c544     	subseq	r12, r3, r4, asr #10
   a3288: e286c020     	add	r12, r6, #32
   a328c: e2861008     	add	r1, r6, #8
   a3290: e89c00ed     	ldm	r12, {r0, r2, r3, r5, r6, r7}
   a3294: e88100ed     	stm	r1, {r0, r2, r3, r5, r6, r7}
   a3298: e59f6e58     	ldr	r6, [pc, #0xe58]        @ 0xa40f8 <.text+0x93ff8>
   a329c: e59d5038     	ldr	r5, [sp, #0x38]
   a32a0: e08f6006     	add	r6, pc, r6
   a32a4: e1a00005     	mov	r0, r5
   a32a8: eb140b96     	bl	0x5a6108 <.text+0x596008> @ imm = #0x502e58
   a32ac: e3a00003     	mov	r0, #3
   a32b0: e3a07003     	mov	r7, #3
   a32b4: e5860000     	str	r0, [r6]
   a32b8: e1a00005     	mov	r0, r5
   a32bc: eb140d00     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x503400
   a32c0: ed960b04     	vldr	d0, [r6, #16]
   a32c4: e300318a     	movw	r3, #0x18a
   a32c8: e5962018     	ldr	r2, [r6, #0x18]
   a32cc: e596101c     	ldr	r1, [r6, #0x1c]
   a32d0: e58d1018     	str	r1, [sp, #0x18]
   a32d4: e58d201c     	str	r2, [sp, #0x1c]
   a32d8: ed8d0b04     	vstr	d0, [sp, #16]
   a32dc: e58d7000     	str	r7, [sp]
   a32e0: e5960008     	ldr	r0, [r6, #0x8]
   a32e4: e59f1e10     	ldr	r1, [pc, #0xe10]        @ 0xa40fc <.text+0x93ffc>
   a32e8: e58d0008     	str	r0, [sp, #0x8]
   a32ec: e08f1001     	add	r1, pc, r1
   a32f0: e58d1004     	str	r1, [sp, #0x4]
   a32f4: e59f9e04     	ldr	r9, [pc, #0xe04]        @ 0xa4100 <.text+0x94000>
   a32f8: e59f7e04     	ldr	r7, [pc, #0xe04]        @ 0xa4104 <.text+0x94004>
   a32fc: e59f2e04     	ldr	r2, [pc, #0xe04]        @ 0xa4108 <.text+0x94008>
   a3300: e08f9009     	add	r9, pc, r9
   a3304: e08f7007     	add	r7, pc, r7
   a3308: e08f2002     	add	r2, pc, r2
   a330c: e1a00009     	mov	r0, r9
   a3310: e1a01007     	mov	r1, r7
   a3314: e1a05002     	mov	r5, r2
   a3318: eb015b69     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56da4
   a331c: ed960b0a     	vldr	d0, [r6, #40]
   a3320: e300318d     	movw	r3, #0x18d
   a3324: e5961034     	ldr	r1, [r6, #0x34]
   a3328: e5962030     	ldr	r2, [r6, #0x30]
   a332c: e58d1018     	str	r1, [sp, #0x18]
   a3330: e3a01003     	mov	r1, #3
   a3334: e58d201c     	str	r2, [sp, #0x1c]
   a3338: e1a02005     	mov	r2, r5
   a333c: ed8d0b04     	vstr	d0, [sp, #16]
   a3340: e58d1000     	str	r1, [sp]
   a3344: e5960020     	ldr	r0, [r6, #0x20]
   a3348: e59f1dbc     	ldr	r1, [pc, #0xdbc]        @ 0xa410c <.text+0x9400c>
   a334c: e58d0008     	str	r0, [sp, #0x8]
   a3350: e1a00009     	mov	r0, r9
   a3354: e08f1001     	add	r1, pc, r1
   a3358: e58d1004     	str	r1, [sp, #0x4]
   a335c: e1a01007     	mov	r1, r7
   a3360: eb015b57     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56d5c
   a3364: ed9d0b12     	vldr	d0, [sp, #72]
   a3368: e3a03e19     	mov	r3, #400
   a336c: e59d1054     	ldr	r1, [sp, #0x54]
   a3370: e3a09001     	mov	r9, #1
   a3374: e59d2050     	ldr	r2, [sp, #0x50]
   a3378: e58d1018     	str	r1, [sp, #0x18]
   a337c: e3a01003     	mov	r1, #3
   a3380: e58d201c     	str	r2, [sp, #0x1c]
   a3384: e1a02005     	mov	r2, r5
   a3388: ed8d0b04     	vstr	d0, [sp, #16]
   a338c: e58d1000     	str	r1, [sp]
   a3390: e59d0040     	ldr	r0, [sp, #0x40]
   a3394: e59f1d74     	ldr	r1, [pc, #0xd74]        @ 0xa4110 <.text+0x94010>
   a3398: e58d0008     	str	r0, [sp, #0x8]
   a339c: e08f1001     	add	r1, pc, r1
   a33a0: e58d1004     	str	r1, [sp, #0x4]
   a33a4: e59f0d68     	ldr	r0, [pc, #0xd68]        @ 0xa4114 <.text+0x94014>
   a33a8: e1a01007     	mov	r1, r7
   a33ac: e08f0000     	add	r0, pc, r0
   a33b0: eb015b43     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56d0c
   a33b4: e59d5034     	ldr	r5, [sp, #0x34]
   a33b8: eafffbd3     	b	0xa230c <.text+0x9220c> @ imm = #-0x10b4
   a33bc: e59d1024     	ldr	r1, [sp, #0x24]
   a33c0: e59d0040     	ldr	r0, [sp, #0x40]
   a33c4: e5962020     	ldr	r2, [r6, #0x20]
   a33c8: e5911004     	ldr	r1, [r1, #0x4]
   a33cc: e0522000     	subs	r2, r2, r0
   a33d0: e59d5034     	ldr	r5, [sp, #0x34]
   a33d4: 42622000     	rsbmi	r2, r2, #0
   a33d8: e3520001     	cmp	r2, #1
   a33dc: ca0000a4     	bgt	0xa3674 <.text+0x93574> @ imm = #0x290
   a33e0: e5982050     	ldr	r2, [r8, #0x50]
   a33e4: e3520000     	cmp	r2, #0
   a33e8: 0a000094     	beq	0xa3640 <.text+0x93540> @ imm = #0x250
   a33ec: e5961008     	ldr	r1, [r6, #0x8]
   a33f0: e0400001     	sub	r0, r0, r1
   a33f4: e3500003     	cmp	r0, #3
   a33f8: aa000094     	bge	0xa3650 <.text+0x93550> @ imm = #0x250
   a33fc: ea00009c     	b	0xa3674 <.text+0x93574> @ imm = #0x270
   a3400: 0057061c     	subseq	r0, r7, r12, lsl r6
   a3404: e598001c     	ldr	r0, [r8, #0x1c]
   a3408: ebfef650     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x426c0
   a340c: e59f4fa8     	ldr	r4, [pc, #0xfa8]        @ 0xa43bc <.text+0x942bc>
   a3410: e79f4004     	ldr	r4, [pc, r4]
   a3414: e59d1030     	ldr	r1, [sp, #0x30]
   a3418: e59f6fa0     	ldr	r6, [pc, #0xfa0]        @ 0xa43c0 <.text+0x942c0>
   a341c: e1500001     	cmp	r0, r1
   a3420: e08f6006     	add	r6, pc, r6
   a3424: ca000a26     	bgt	0xa5cc4 <.text+0x95bc4> @ imm = #0x2898
   a3428: e59a0000     	ldr	r0, [r10]
   a342c: e3a09001     	mov	r9, #1
   a3430: e2401001     	sub	r1, r0, #1
   a3434: e0000190     	mul	r0, r0, r1
   a3438: e3100001     	tst	r0, #1
   a343c: 0a000288     	beq	0xa3e64 <.text+0x93d64> @ imm = #0xa20
   a3440: e5940000     	ldr	r0, [r4]
   a3444: e3500009     	cmp	r0, #9
   a3448: ca0002d7     	bgt	0xa3fac <.text+0x93eac> @ imm = #0xb5c
   a344c: ea000284     	b	0xa3e64 <.text+0x93d64> @ imm = #0xa10
   a3450: e59a0000     	ldr	r0, [r10]
   a3454: e2401001     	sub	r1, r0, #1
   a3458: e0000190     	mul	r0, r0, r1
   a345c: e3100001     	tst	r0, #1
   a3460: 0a00032c     	beq	0xa4118 <.text+0x94018> @ imm = #0xcb0
   a3464: e5940000     	ldr	r0, [r4]
   a3468: e3500009     	cmp	r0, #9
   a346c: ca000380     	bgt	0xa4274 <.text+0x94174> @ imm = #0xe00
   a3470: ea000328     	b	0xa4118 <.text+0x94018> @ imm = #0xca0
   a3474: e59a0000     	ldr	r0, [r10]
   a3478: e59f6f44     	ldr	r6, [pc, #0xf44]        @ 0xa43c4 <.text+0x942c4>
   a347c: e2401001     	sub	r1, r0, #1
   a3480: e59f4f40     	ldr	r4, [pc, #0xf40]        @ 0xa43c8 <.text+0x942c8>
   a3484: e08f6006     	add	r6, pc, r6
   a3488: e0000190     	mul	r0, r0, r1
   a348c: e79f4004     	ldr	r4, [pc, r4]
   a3490: e3100001     	tst	r0, #1
   a3494: 0a0003d4     	beq	0xa43ec <.text+0x942ec> @ imm = #0xf50
   a3498: e5940000     	ldr	r0, [r4]
   a349c: e3500009     	cmp	r0, #9
   a34a0: ca000426     	bgt	0xa4540 <.text+0x94440> @ imm = #0x1098
   a34a4: ea0003d0     	b	0xa43ec <.text+0x942ec> @ imm = #0xf40
   a34a8: 0057058c     	subseq	r0, r7, r12, lsl #11
   a34ac: 00545960     	subseq	r5, r4, r0, ror #18
   a34b0: 00545833     	subseq	r5, r4, r3, lsr r8
   a34b4: 005457d0     	ldrsbeq	r5, [r4], #-112
   a34b8: 00545804     	subseq	r5, r4, r4, lsl #16
   a34bc: 00545913     	subseq	r5, r4, r3, lsl r9
   a34c0: 005458e6     	subseq	r5, r4, r6, ror #17
   a34c4: 0053c260     	subseq	r12, r3, r0, ror #4
   a34c8: e286c020     	add	r12, r6, #32
   a34cc: e2861008     	add	r1, r6, #8
   a34d0: e89c00ed     	ldm	r12, {r0, r2, r3, r5, r6, r7}
   a34d4: e88100ed     	stm	r1, {r0, r2, r3, r5, r6, r7}
   a34d8: e59f6eec     	ldr	r6, [pc, #0xeec]        @ 0xa43cc <.text+0x942cc>
   a34dc: e59d5038     	ldr	r5, [sp, #0x38]
   a34e0: e08f6006     	add	r6, pc, r6
   a34e4: e1a00005     	mov	r0, r5
   a34e8: eb140b06     	bl	0x5a6108 <.text+0x596008> @ imm = #0x502c18
   a34ec: e3a00003     	mov	r0, #3
   a34f0: e3a07003     	mov	r7, #3
   a34f4: e5860000     	str	r0, [r6]
   a34f8: e1a00005     	mov	r0, r5
   a34fc: eb140c70     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5031c0
   a3500: ed960b04     	vldr	d0, [r6, #16]
   a3504: e300318a     	movw	r3, #0x18a
   a3508: e5962018     	ldr	r2, [r6, #0x18]
   a350c: e596101c     	ldr	r1, [r6, #0x1c]
   a3510: e58d1018     	str	r1, [sp, #0x18]
   a3514: e58d201c     	str	r2, [sp, #0x1c]
   a3518: ed8d0b04     	vstr	d0, [sp, #16]
   a351c: e58d7000     	str	r7, [sp]
   a3520: e5960008     	ldr	r0, [r6, #0x8]
   a3524: e59f1ea4     	ldr	r1, [pc, #0xea4]        @ 0xa43d0 <.text+0x942d0>
   a3528: e58d0008     	str	r0, [sp, #0x8]
   a352c: e08f1001     	add	r1, pc, r1
   a3530: e58d1004     	str	r1, [sp, #0x4]
   a3534: e59f9e98     	ldr	r9, [pc, #0xe98]        @ 0xa43d4 <.text+0x942d4>
   a3538: e59f7e98     	ldr	r7, [pc, #0xe98]        @ 0xa43d8 <.text+0x942d8>
   a353c: e59f2e98     	ldr	r2, [pc, #0xe98]        @ 0xa43dc <.text+0x942dc>
   a3540: e08f9009     	add	r9, pc, r9
   a3544: e08f7007     	add	r7, pc, r7
   a3548: e08f2002     	add	r2, pc, r2
   a354c: e1a00009     	mov	r0, r9
   a3550: e1a01007     	mov	r1, r7
   a3554: e1a05002     	mov	r5, r2
   a3558: eb015ad9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56b64
   a355c: ed960b0a     	vldr	d0, [r6, #40]
   a3560: e300318d     	movw	r3, #0x18d
   a3564: e5961034     	ldr	r1, [r6, #0x34]
   a3568: e5962030     	ldr	r2, [r6, #0x30]
   a356c: e58d1018     	str	r1, [sp, #0x18]
   a3570: e3a01003     	mov	r1, #3
   a3574: e58d201c     	str	r2, [sp, #0x1c]
   a3578: e1a02005     	mov	r2, r5
   a357c: ed8d0b04     	vstr	d0, [sp, #16]
   a3580: e58d1000     	str	r1, [sp]
   a3584: e5960020     	ldr	r0, [r6, #0x20]
   a3588: e59f1e50     	ldr	r1, [pc, #0xe50]        @ 0xa43e0 <.text+0x942e0>
   a358c: e58d0008     	str	r0, [sp, #0x8]
   a3590: e1a00009     	mov	r0, r9
   a3594: e08f1001     	add	r1, pc, r1
   a3598: e58d1004     	str	r1, [sp, #0x4]
   a359c: e1a01007     	mov	r1, r7
   a35a0: eb015ac7     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56b1c
   a35a4: ed9d0b12     	vldr	d0, [sp, #72]
   a35a8: e59d1054     	ldr	r1, [sp, #0x54]
   a35ac: e59d2050     	ldr	r2, [sp, #0x50]
   a35b0: e58d1018     	str	r1, [sp, #0x18]
   a35b4: e3a01003     	mov	r1, #3
   a35b8: e58d201c     	str	r2, [sp, #0x1c]
   a35bc: e1a02005     	mov	r2, r5
   a35c0: ed8d0b04     	vstr	d0, [sp, #16]
   a35c4: e58d1000     	str	r1, [sp]
   a35c8: e59d0040     	ldr	r0, [sp, #0x40]
   a35cc: e59f1e10     	ldr	r1, [pc, #0xe10]        @ 0xa43e4 <.text+0x942e4>
   a35d0: e58d0008     	str	r0, [sp, #0x8]
   a35d4: e1a00009     	mov	r0, r9
   a35d8: e08f1001     	add	r1, pc, r1
   a35dc: e58d1004     	str	r1, [sp, #0x4]
   a35e0: e1a01007     	mov	r1, r7
   a35e4: e3a03e19     	mov	r3, #400
   a35e8: eb015ab5     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56ad4
   a35ec: ea000045     	b	0xa3708 <.text+0x93608> @ imm = #0x114
   a35f0: 00545719     	subseq	r5, r4, r9, lsl r7
   a35f4: e59a0000     	ldr	r0, [r10]
   a35f8: e59f6de8     	ldr	r6, [pc, #0xde8]        @ 0xa43e8 <.text+0x942e8>
   a35fc: e2401001     	sub	r1, r0, #1
   a3600: e08f6006     	add	r6, pc, r6
   a3604: e0000190     	mul	r0, r0, r1
   a3608: e3100001     	tst	r0, #1
   a360c: 0a000425     	beq	0xa46a8 <.text+0x945a8> @ imm = #0x1094
   a3610: e5940000     	ldr	r0, [r4]
   a3614: e3500009     	cmp	r0, #9
   a3618: ca000474     	bgt	0xa47f0 <.text+0x946f0> @ imm = #0x11d0
   a361c: ea000421     	b	0xa46a8 <.text+0x945a8> @ imm = #0x1084
   a3620: 005456ff     	ldrsheq	r5, [r4], #-111
   a3624: 0054569c     	<unknown>
   a3628: 005456d0     	ldrsbeq	r5, [r4], #-96
   a362c: e59d5030     	ldr	r5, [sp, #0x30]
   a3630: e3500000     	cmp	r0, #0
   a3634: 0a0006b2     	beq	0xa5104 <.text+0x95004> @ imm = #0x1ac8
   a3638: ea000659     	b	0xa4fa4 <.text+0x94ea4> @ imm = #0x1964
   a363c: 0053c1d4     	ldrsbeq	r12, [r3], #-20
   a3640: e596001c     	ldr	r0, [r6, #0x1c]
   a3644: e0410000     	sub	r0, r1, r0
   a3648: e3500003     	cmp	r0, #3
   a364c: da000008     	ble	0xa3674 <.text+0x93574> @ imm = #0x20
   a3650: eeb40bc9     	vcmpe.f64	d0, d9
   a3654: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a3658: 5a00000e     	bpl	0xa3698 <.text+0x93598> @ imm = #0x38
   a365c: ed961b04     	vldr	d1, [r6, #16]
   a3660: ee300b41     	vsub.f64	d0, d0, d1
   a3664: ed9f1b35     	vldr	d1, [pc, #212]          @ 0xa3740 <.text+0x93640>
   a3668: eeb40bc1     	vcmpe.f64	d0, d1
   a366c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a3670: ca000008     	bgt	0xa3698 <.text+0x93598> @ imm = #0x20
   a3674: e59a0000     	ldr	r0, [r10]
   a3678: e2401001     	sub	r1, r0, #1
   a367c: e0000190     	mul	r0, r0, r1
   a3680: e3100001     	tst	r0, #1
   a3684: 0a0004a8     	beq	0xa492c <.text+0x9482c> @ imm = #0x12a0
   a3688: e5940000     	ldr	r0, [r4]
   a368c: e3500009     	cmp	r0, #9
   a3690: ca0004af     	bgt	0xa4954 <.text+0x94854> @ imm = #0x12bc
   a3694: ea0004a4     	b	0xa492c <.text+0x9482c> @ imm = #0x1290
   a3698: e59a0000     	ldr	r0, [r10]
   a369c: e2401001     	sub	r1, r0, #1
   a36a0: e0000190     	mul	r0, r0, r1
   a36a4: e3100001     	tst	r0, #1
   a36a8: 0a000544     	beq	0xa4bc0 <.text+0x94ac0> @ imm = #0x1510
   a36ac: e5940000     	ldr	r0, [r4]
   a36b0: e3500009     	cmp	r0, #9
   a36b4: ca000556     	bgt	0xa4c14 <.text+0x94b14> @ imm = #0x1558
   a36b8: ea000540     	b	0xa4bc0 <.text+0x94ac0> @ imm = #0x1500
   a36bc: ebfdeda5     	bl	0x1ed58 <.text+0xec58>  @ imm = #-0x8496c
   a36c0: ed981b0a     	vldr	d1, [r8, #40]
   a36c4: e59a0000     	ldr	r0, [r10]
   a36c8: ee300b41     	vsub.f64	d0, d0, d1
   a36cc: e2401001     	sub	r1, r0, #1
   a36d0: e0000190     	mul	r0, r0, r1
   a36d4: e3100001     	tst	r0, #1
   a36d8: 0a000004     	beq	0xa36f0 <.text+0x935f0> @ imm = #0x10
   a36dc: e5940000     	ldr	r0, [r4]
   a36e0: e3500009     	cmp	r0, #9
   a36e4: da000001     	ble	0xa36f0 <.text+0x935f0> @ imm = #0x4
   a36e8: ebfded9a     	bl	0x1ed58 <.text+0xec58>  @ imm = #-0x84998
   a36ec: eafffff2     	b	0xa36bc <.text+0x935bc> @ imm = #-0x38
   a36f0: ed9f1b14     	vldr	d1, [pc, #80]           @ 0xa3748 <.text+0x93648>
   a36f4: eeb40bc1     	vcmpe.f64	d0, d1
   a36f8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a36fc: 5a000014     	bpl	0xa3754 <.text+0x93654> @ imm = #0x50
   a3700: e3a00ffa     	mov	r0, #1000
   a3704: eb01ae0c     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6b830
   a3708: e59d5034     	ldr	r5, [sp, #0x34]
   a370c: e3a09001     	mov	r9, #1
   a3710: eafffafd     	b	0xa230c <.text+0x9220c> @ imm = #-0x140c
   a3714: 0053c068     	subseq	r12, r3, r8, rrx
   a3718: 0053bf6c     	subseq	r11, r3, r12, ror #30
   a371c: 0057016c     	subseq	r0, r7, r12, ror #2
   a3720: 00570110     	subseq	r0, r7, r0, lsl r1
   a3724: 005454e4     	subseq	r5, r4, r4, ror #9
   a3728: 005453b7     	ldrheq	r5, [r4], #-55
   a372c: 00545354     	subseq	r5, r4, r4, asr r3
   a3730: 00545388     	subseq	r5, r4, r8, lsl #7
   a3734: 00545497     	<unknown>
   a3738: 00545466     	subseq	r5, r4, r6, ror #8
   a373c: 0053bdf0     	ldrsheq	r11, [r3], #-208
   a3740: 00000000     	andeq	r0, r0, r0
   a3744: bfe00000     	svclt	#0xe00000
   a3748: 00000000     	andeq	r0, r0, r0
   a374c: 404e0000     	submi	r0, lr, r0
   a3750: 0056ffd8     	ldrsbeq	pc, [r6], #-248
   a3754: e28d1040     	add	r1, sp, #64
   a3758: e286c020     	add	r12, r6, #32
   a375c: e1a04001     	mov	r4, r1
   a3760: e89400ed     	ldm	r4, {r0, r2, r3, r5, r6, r7}
   a3764: e88c00ed     	stm	r12, {r0, r2, r3, r5, r6, r7}
   a3768: e1a00008     	mov	r0, r8
   a376c: e3a0203c     	mov	r2, #60
   a3770: e59f4f10     	ldr	r4, [pc, #0xf10]        @ 0xa4688 <.text+0x94588>
   a3774: e79f4004     	ldr	r4, [pc, r4]
   a3778: eb000a84     	bl	0xa6190 <.text+0x96090> @ imm = #0x2a10
   a377c: e1a00008     	mov	r0, r8
   a3780: ebfefcc2     	bl	0x62a90 <.text+0x52990> @ imm = #-0x40cf8
   a3784: e1a00008     	mov	r0, r8
   a3788: ebfef8d0     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x41cc0
   a378c: e59d3034     	ldr	r3, [sp, #0x34]
   a3790: e3500000     	cmp	r0, #0
   a3794: 0a00001e     	beq	0xa3814 <.text+0x93714> @ imm = #0x78
   a3798: e59a0000     	ldr	r0, [r10]
   a379c: e2401001     	sub	r1, r0, #1
   a37a0: e0000190     	mul	r0, r0, r1
   a37a4: e3100001     	tst	r0, #1
   a37a8: e59a0000     	ldr	r0, [r10]
   a37ac: e2401001     	sub	r1, r0, #1
   a37b0: e0010190     	mul	r1, r0, r1
   a37b4: e5d80108     	ldrb	r0, [r8, #0x108]
   a37b8: e3110001     	tst	r1, #1
   a37bc: 0a000002     	beq	0xa37cc <.text+0x936cc> @ imm = #0x8
   a37c0: e5941000     	ldr	r1, [r4]
   a37c4: e3510009     	cmp	r1, #9
   a37c8: cafffff6     	bgt	0xa37a8 <.text+0x936a8> @ imm = #-0x28
   a37cc: e3500000     	cmp	r0, #0
   a37d0: 0a00000f     	beq	0xa3814 <.text+0x93714> @ imm = #0x3c
   a37d4: e59a0000     	ldr	r0, [r10]
   a37d8: e2401001     	sub	r1, r0, #1
   a37dc: e0000190     	mul	r0, r0, r1
   a37e0: e3100001     	tst	r0, #1
   a37e4: e59a0000     	ldr	r0, [r10]
   a37e8: e2401001     	sub	r1, r0, #1
   a37ec: e0020190     	mul	r2, r0, r1
   a37f0: e598010c     	ldr	r0, [r8, #0x10c]
   a37f4: e5931048     	ldr	r1, [r3, #0x48]
   a37f8: e3120001     	tst	r2, #1
   a37fc: 0a000002     	beq	0xa380c <.text+0x9370c> @ imm = #0x8
   a3800: e5942000     	ldr	r2, [r4]
   a3804: e3520009     	cmp	r2, #9
   a3808: cafffff5     	bgt	0xa37e4 <.text+0x936e4> @ imm = #-0x2c
   a380c: e1510000     	cmp	r1, r0
   a3810: 2a00009f     	bhs	0xa3a94 <.text+0x93994> @ imm = #0x27c
   a3814: e59a0000     	ldr	r0, [r10]
   a3818: e59f6e6c     	ldr	r6, [pc, #0xe6c]        @ 0xa468c <.text+0x9458c>
   a381c: e2401001     	sub	r1, r0, #1
   a3820: e08f6006     	add	r6, pc, r6
   a3824: e0000190     	mul	r0, r0, r1
   a3828: e3100001     	tst	r0, #1
   a382c: e59a0000     	ldr	r0, [r10]
   a3830: e59d3040     	ldr	r3, [sp, #0x40]
   a3834: e2401001     	sub	r1, r0, #1
   a3838: e0020190     	mul	r2, r0, r1
   a383c: e5960020     	ldr	r0, [r6, #0x20]
   a3840: e5941000     	ldr	r1, [r4]
   a3844: e0500003     	subs	r0, r0, r3
   a3848: 42600000     	rsbmi	r0, r0, #0
   a384c: e3120001     	tst	r2, #1
   a3850: 0a000001     	beq	0xa385c <.text+0x9375c> @ imm = #0x4
   a3854: e3510009     	cmp	r1, #9
   a3858: cafffff3     	bgt	0xa382c <.text+0x9372c> @ imm = #-0x34
   a385c: e3500001     	cmp	r0, #1
   a3860: ca000048     	bgt	0xa3988 <.text+0x93888> @ imm = #0x120
   a3864: e28d1040     	add	r1, sp, #64
   a3868: e286c008     	add	r12, r6, #8
   a386c: e89100ed     	ldm	r1, {r0, r2, r3, r5, r6, r7}
   a3870: e88c00ed     	stm	r12, {r0, r2, r3, r5, r6, r7}
   a3874: e59f6e14     	ldr	r6, [pc, #0xe14]        @ 0xa4690 <.text+0x94590>
   a3878: e59d5038     	ldr	r5, [sp, #0x38]
   a387c: e08f6006     	add	r6, pc, r6
   a3880: e1a00005     	mov	r0, r5
   a3884: eb140a1f     	bl	0x5a6108 <.text+0x596008> @ imm = #0x50287c
   a3888: e3a00002     	mov	r0, #2
   a388c: e5860000     	str	r0, [r6]
   a3890: e1a00005     	mov	r0, r5
   a3894: eb140b8a     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x502e28
   a3898: ed960b04     	vldr	d0, [r6, #16]
   a389c: e300318a     	movw	r3, #0x18a
   a38a0: e596101c     	ldr	r1, [r6, #0x1c]
   a38a4: e5962018     	ldr	r2, [r6, #0x18]
   a38a8: e58d1018     	str	r1, [sp, #0x18]
   a38ac: e3a01003     	mov	r1, #3
   a38b0: e58d201c     	str	r2, [sp, #0x1c]
   a38b4: ed8d0b04     	vstr	d0, [sp, #16]
   a38b8: e58d1000     	str	r1, [sp]
   a38bc: e5960008     	ldr	r0, [r6, #0x8]
   a38c0: e59f1dcc     	ldr	r1, [pc, #0xdcc]        @ 0xa4694 <.text+0x94594>
   a38c4: e58d0008     	str	r0, [sp, #0x8]
   a38c8: e08f1001     	add	r1, pc, r1
   a38cc: e58d1004     	str	r1, [sp, #0x4]
   a38d0: e59f5dc0     	ldr	r5, [pc, #0xdc0]        @ 0xa4698 <.text+0x94598>
   a38d4: e59f7dc0     	ldr	r7, [pc, #0xdc0]        @ 0xa469c <.text+0x9459c>
   a38d8: e59f2dc0     	ldr	r2, [pc, #0xdc0]        @ 0xa46a0 <.text+0x945a0>
   a38dc: e08f5005     	add	r5, pc, r5
   a38e0: e08f7007     	add	r7, pc, r7
   a38e4: e08f2002     	add	r2, pc, r2
   a38e8: e1a00005     	mov	r0, r5
   a38ec: e1a01007     	mov	r1, r7
   a38f0: e1a09002     	mov	r9, r2
   a38f4: eb0159f2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x567c8
   a38f8: ed960b0a     	vldr	d0, [r6, #40]
   a38fc: e300318d     	movw	r3, #0x18d
   a3900: e5961034     	ldr	r1, [r6, #0x34]
   a3904: e5962030     	ldr	r2, [r6, #0x30]
   a3908: e58d1018     	str	r1, [sp, #0x18]
   a390c: e3a01003     	mov	r1, #3
   a3910: e58d201c     	str	r2, [sp, #0x1c]
   a3914: e1a02009     	mov	r2, r9
   a3918: ed8d0b04     	vstr	d0, [sp, #16]
   a391c: e58d1000     	str	r1, [sp]
   a3920: e5960020     	ldr	r0, [r6, #0x20]
   a3924: e59f1d78     	ldr	r1, [pc, #0xd78]        @ 0xa46a4 <.text+0x945a4>
   a3928: e58d0008     	str	r0, [sp, #0x8]
   a392c: e1a00005     	mov	r0, r5
   a3930: e08f1001     	add	r1, pc, r1
   a3934: e58d1004     	str	r1, [sp, #0x4]
   a3938: e1a01007     	mov	r1, r7
   a393c: eb0159e0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56780
   a3940: ed9d0b12     	vldr	d0, [sp, #72]
   a3944: e3a03e19     	mov	r3, #400
   a3948: e59d1054     	ldr	r1, [sp, #0x54]
   a394c: e59d2050     	ldr	r2, [sp, #0x50]
   a3950: e58d1018     	str	r1, [sp, #0x18]
   a3954: e3a01003     	mov	r1, #3
   a3958: e58d201c     	str	r2, [sp, #0x1c]
   a395c: e1a02009     	mov	r2, r9
   a3960: ed8d0b04     	vstr	d0, [sp, #16]
   a3964: e58d1000     	str	r1, [sp]
   a3968: e59d0040     	ldr	r0, [sp, #0x40]
   a396c: e59f1fec     	ldr	r1, [pc, #0xfec]        @ 0xa4960 <.text+0x94860>
   a3970: e58d0008     	str	r0, [sp, #0x8]
   a3974: e1a00005     	mov	r0, r5
   a3978: e08f1001     	add	r1, pc, r1
   a397c: e58d1004     	str	r1, [sp, #0x4]
   a3980: e1a01007     	mov	r1, r7
   a3984: eb0159ce     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56738
   a3988: ed960b04     	vldr	d0, [r6, #16]
   a398c: e300318a     	movw	r3, #0x18a
   a3990: e596101c     	ldr	r1, [r6, #0x1c]
   a3994: e5962018     	ldr	r2, [r6, #0x18]
   a3998: e58d1018     	str	r1, [sp, #0x18]
   a399c: e3a01003     	mov	r1, #3
   a39a0: e58d201c     	str	r2, [sp, #0x1c]
   a39a4: ed8d0b04     	vstr	d0, [sp, #16]
   a39a8: e58d1000     	str	r1, [sp]
   a39ac: e5960008     	ldr	r0, [r6, #0x8]
   a39b0: e59f1fac     	ldr	r1, [pc, #0xfac]        @ 0xa4964 <.text+0x94864>
   a39b4: e58d0008     	str	r0, [sp, #0x8]
   a39b8: e08f1001     	add	r1, pc, r1
   a39bc: e58d1004     	str	r1, [sp, #0x4]
   a39c0: e59f5fa0     	ldr	r5, [pc, #0xfa0]        @ 0xa4968 <.text+0x94868>
   a39c4: e59f7fa0     	ldr	r7, [pc, #0xfa0]        @ 0xa496c <.text+0x9486c>
   a39c8: e59f2fa0     	ldr	r2, [pc, #0xfa0]        @ 0xa4970 <.text+0x94870>
   a39cc: e08f5005     	add	r5, pc, r5
   a39d0: e08f7007     	add	r7, pc, r7
   a39d4: e08f2002     	add	r2, pc, r2
   a39d8: e1a00005     	mov	r0, r5
   a39dc: e1a01007     	mov	r1, r7
   a39e0: e1a09002     	mov	r9, r2
   a39e4: eb0159b6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x566d8
   a39e8: ed960b0a     	vldr	d0, [r6, #40]
   a39ec: e300318d     	movw	r3, #0x18d
   a39f0: e5961034     	ldr	r1, [r6, #0x34]
   a39f4: e5962030     	ldr	r2, [r6, #0x30]
   a39f8: e58d1018     	str	r1, [sp, #0x18]
   a39fc: e3a01003     	mov	r1, #3
   a3a00: e58d201c     	str	r2, [sp, #0x1c]
   a3a04: e1a02009     	mov	r2, r9
   a3a08: ed8d0b04     	vstr	d0, [sp, #16]
   a3a0c: e58d1000     	str	r1, [sp]
   a3a10: e5960020     	ldr	r0, [r6, #0x20]
   a3a14: e59f1f58     	ldr	r1, [pc, #0xf58]        @ 0xa4974 <.text+0x94874>
   a3a18: e58d0008     	str	r0, [sp, #0x8]
   a3a1c: e1a00005     	mov	r0, r5
   a3a20: e08f1001     	add	r1, pc, r1
   a3a24: e58d1004     	str	r1, [sp, #0x4]
   a3a28: e1a01007     	mov	r1, r7
   a3a2c: eb0159a4     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56690
   a3a30: ed9d0b12     	vldr	d0, [sp, #72]
   a3a34: e3a03e19     	mov	r3, #400
   a3a38: e59d1054     	ldr	r1, [sp, #0x54]
   a3a3c: e59d2050     	ldr	r2, [sp, #0x50]
   a3a40: e58d1018     	str	r1, [sp, #0x18]
   a3a44: e3a01003     	mov	r1, #3
   a3a48: e58d201c     	str	r2, [sp, #0x1c]
   a3a4c: e1a02009     	mov	r2, r9
   a3a50: ed8d0b04     	vstr	d0, [sp, #16]
   a3a54: e58d1000     	str	r1, [sp]
   a3a58: e59d0040     	ldr	r0, [sp, #0x40]
   a3a5c: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0xa4a54 <.text+0x94954>
   a3a60: e58d0008     	str	r0, [sp, #0x8]
   a3a64: e1a00005     	mov	r0, r5
   a3a68: e08f1001     	add	r1, pc, r1
   a3a6c: e58d1004     	str	r1, [sp, #0x4]
   a3a70: e1a01007     	mov	r1, r7
   a3a74: eb015992     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56648
   a3a78: ea000891     	b	0xa5cc4 <.text+0x95bc4> @ imm = #0x2244
   a3a7c: 005453a8     	subseq	r5, r4, r8, lsr #7
   a3a80: 0054527b     	subseq	r5, r4, r11, ror r2
   a3a84: 00545218     	subseq	r5, r4, r8, lsl r2
   a3a88: 0054524c     	subseq	r5, r4, r12, asr #4
   a3a8c: 0054535b     	subseq	r5, r4, r11, asr r3
   a3a90: 0054532a     	subseq	r5, r4, r10, lsr #6
   a3a94: e59d5038     	ldr	r5, [sp, #0x38]
   a3a98: e1a00005     	mov	r0, r5
   a3a9c: eb140999     	bl	0x5a6108 <.text+0x596008> @ imm = #0x502664
   a3aa0: e59f6fb0     	ldr	r6, [pc, #0xfb0]        @ 0xa4a58 <.text+0x94958>
   a3aa4: e3a00002     	mov	r0, #2
   a3aa8: e08f6006     	add	r6, pc, r6
   a3aac: e5860000     	str	r0, [r6]
   a3ab0: e1a00005     	mov	r0, r5
   a3ab4: eb140b02     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x502c08
   a3ab8: ed960b04     	vldr	d0, [r6, #16]
   a3abc: e300318a     	movw	r3, #0x18a
   a3ac0: e596101c     	ldr	r1, [r6, #0x1c]
   a3ac4: e5962018     	ldr	r2, [r6, #0x18]
   a3ac8: e58d1018     	str	r1, [sp, #0x18]
   a3acc: e3a01003     	mov	r1, #3
   a3ad0: e58d201c     	str	r2, [sp, #0x1c]
   a3ad4: ed8d0b04     	vstr	d0, [sp, #16]
   a3ad8: e58d1000     	str	r1, [sp]
   a3adc: e5960008     	ldr	r0, [r6, #0x8]
   a3ae0: e59f1f74     	ldr	r1, [pc, #0xf74]        @ 0xa4a5c <.text+0x9495c>
   a3ae4: e58d0008     	str	r0, [sp, #0x8]
   a3ae8: e08f1001     	add	r1, pc, r1
   a3aec: e58d1004     	str	r1, [sp, #0x4]
   a3af0: e59f5f68     	ldr	r5, [pc, #0xf68]        @ 0xa4a60 <.text+0x94960>
   a3af4: e59f7f68     	ldr	r7, [pc, #0xf68]        @ 0xa4a64 <.text+0x94964>
   a3af8: e59f2f68     	ldr	r2, [pc, #0xf68]        @ 0xa4a68 <.text+0x94968>
   a3afc: e08f5005     	add	r5, pc, r5
   a3b00: e08f7007     	add	r7, pc, r7
   a3b04: e08f2002     	add	r2, pc, r2
   a3b08: e1a00005     	mov	r0, r5
   a3b0c: e1a01007     	mov	r1, r7
   a3b10: e1a09002     	mov	r9, r2
   a3b14: eb01596a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x565a8
   a3b18: ed960b0a     	vldr	d0, [r6, #40]
   a3b1c: e300318d     	movw	r3, #0x18d
   a3b20: e5961034     	ldr	r1, [r6, #0x34]
   a3b24: e5962030     	ldr	r2, [r6, #0x30]
   a3b28: e58d1018     	str	r1, [sp, #0x18]
   a3b2c: e3a01003     	mov	r1, #3
   a3b30: e58d201c     	str	r2, [sp, #0x1c]
   a3b34: e1a02009     	mov	r2, r9
   a3b38: ed8d0b04     	vstr	d0, [sp, #16]
   a3b3c: e58d1000     	str	r1, [sp]
   a3b40: e5960020     	ldr	r0, [r6, #0x20]
   a3b44: e59f1f20     	ldr	r1, [pc, #0xf20]        @ 0xa4a6c <.text+0x9496c>
   a3b48: e58d0008     	str	r0, [sp, #0x8]
   a3b4c: e1a00005     	mov	r0, r5
   a3b50: e08f1001     	add	r1, pc, r1
   a3b54: e58d1004     	str	r1, [sp, #0x4]
   a3b58: e1a01007     	mov	r1, r7
   a3b5c: eb015958     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56560
   a3b60: ed9d0b12     	vldr	d0, [sp, #72]
   a3b64: e3a03e19     	mov	r3, #400
   a3b68: e59d1054     	ldr	r1, [sp, #0x54]
   a3b6c: e59d2050     	ldr	r2, [sp, #0x50]
   a3b70: e58d1018     	str	r1, [sp, #0x18]
   a3b74: e3a01003     	mov	r1, #3
   a3b78: e58d201c     	str	r2, [sp, #0x1c]
   a3b7c: e1a02009     	mov	r2, r9
   a3b80: ed8d0b04     	vstr	d0, [sp, #16]
   a3b84: e58d1000     	str	r1, [sp]
   a3b88: e59d0040     	ldr	r0, [sp, #0x40]
   a3b8c: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0xa4b88 <.text+0x94a88>
   a3b90: e58d0008     	str	r0, [sp, #0x8]
   a3b94: e1a00005     	mov	r0, r5
   a3b98: e08f1001     	add	r1, pc, r1
   a3b9c: e58d1004     	str	r1, [sp, #0x4]
   a3ba0: e1a01007     	mov	r1, r7
   a3ba4: e59d5034     	ldr	r5, [sp, #0x34]
   a3ba8: eb015945     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56514
   a3bac: e3a09001     	mov	r9, #1
   a3bb0: eafff9d5     	b	0xa230c <.text+0x9220c> @ imm = #-0x18ac
   a3bb4: 0056fe84     	subseq	pc, r6, r4, lsl #29
   a3bb8: 0053bc68     	subseq	r11, r3, r8, ror #24
   a3bbc: 00545156     	subseq	r5, r4, r6, asr r1
   a3bc0: 005450cd     	subseq	r5, r4, sp, asr #1
   a3bc4: 00545098     	<unknown>
   a3bc8: 005450cc     	subseq	r5, r4, r12, asr #1
   a3bcc: 005451c8     	subseq	r5, r4, r8, asr #3
   a3bd0: 0054509f     	<unknown>
   a3bd4: 0054518b     	subseq	r5, r4, r11, lsl #3
   a3bd8: 0054515a     	subseq	r5, r4, r10, asr r1
   a3bdc: 00545020     	subseq	r5, r4, r0, lsr #32
   a3be0: e59d5038     	ldr	r5, [sp, #0x38]
   a3be4: e1a00005     	mov	r0, r5
   a3be8: eb140946     	bl	0x5a6108 <.text+0x596008> @ imm = #0x502518
   a3bec: e3a00003     	mov	r0, #3
   a3bf0: e3a07003     	mov	r7, #3
   a3bf4: e5860000     	str	r0, [r6]
   a3bf8: e1a00005     	mov	r0, r5
   a3bfc: eb140ab0     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x502ac0
   a3c00: ed960b04     	vldr	d0, [r6, #16]
   a3c04: e300318a     	movw	r3, #0x18a
   a3c08: e5962018     	ldr	r2, [r6, #0x18]
   a3c0c: e596101c     	ldr	r1, [r6, #0x1c]
   a3c10: e58d1018     	str	r1, [sp, #0x18]
   a3c14: e58d201c     	str	r2, [sp, #0x1c]
   a3c18: ed8d0b04     	vstr	d0, [sp, #16]
   a3c1c: e58d7000     	str	r7, [sp]
   a3c20: e5960008     	ldr	r0, [r6, #0x8]
   a3c24: e59f1f84     	ldr	r1, [pc, #0xf84]        @ 0xa4bb0 <.text+0x94ab0>
   a3c28: e58d0008     	str	r0, [sp, #0x8]
   a3c2c: e08f1001     	add	r1, pc, r1
   a3c30: e58d1004     	str	r1, [sp, #0x4]
   a3c34: e59f5f78     	ldr	r5, [pc, #0xf78]        @ 0xa4bb4 <.text+0x94ab4>
   a3c38: e08f5005     	add	r5, pc, r5
   a3c3c: e1a00005     	mov	r0, r5
   a3c40: e59f5f70     	ldr	r5, [pc, #0xf70]        @ 0xa4bb8 <.text+0x94ab8>
   a3c44: e59f7f70     	ldr	r7, [pc, #0xf70]        @ 0xa4bbc <.text+0x94abc>
   a3c48: e08f5005     	add	r5, pc, r5
   a3c4c: e08f7007     	add	r7, pc, r7
   a3c50: e1a01005     	mov	r1, r5
   a3c54: e1a02007     	mov	r2, r7
   a3c58: eb015919     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56464
   a3c5c: ed990b0a     	vldr	d0, [r9, #40]
   a3c60: e3a06003     	mov	r6, #3
   a3c64: e5992030     	ldr	r2, [r9, #0x30]
   a3c68: e300318d     	movw	r3, #0x18d
   a3c6c: e5991034     	ldr	r1, [r9, #0x34]
   a3c70: e58d201c     	str	r2, [sp, #0x1c]
   a3c74: e1a02007     	mov	r2, r7
   a3c78: e58d1018     	str	r1, [sp, #0x18]
   a3c7c: ed8d0b04     	vstr	d0, [sp, #16]
   a3c80: e58d6000     	str	r6, [sp]
   a3c84: e5990020     	ldr	r0, [r9, #0x20]
   a3c88: e59f1fbc     	ldr	r1, [pc, #0xfbc]        @ 0xa4c4c <.text+0x94b4c>
   a3c8c: e58d0008     	str	r0, [sp, #0x8]
   a3c90: e08f1001     	add	r1, pc, r1
   a3c94: e58d1004     	str	r1, [sp, #0x4]
   a3c98: e59f0fb0     	ldr	r0, [pc, #0xfb0]        @ 0xa4c50 <.text+0x94b50>
   a3c9c: e1a01005     	mov	r1, r5
   a3ca0: e08f0000     	add	r0, pc, r0
   a3ca4: eb015906     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56418
   a3ca8: ed9d0b12     	vldr	d0, [sp, #72]
   a3cac: e3a03e19     	mov	r3, #400
   a3cb0: e59d1054     	ldr	r1, [sp, #0x54]
   a3cb4: e59d2050     	ldr	r2, [sp, #0x50]
   a3cb8: e58d201c     	str	r2, [sp, #0x1c]
   a3cbc: e1a02007     	mov	r2, r7
   a3cc0: e58d6000     	str	r6, [sp]
   a3cc4: e1a06009     	mov	r6, r9
   a3cc8: e58d1018     	str	r1, [sp, #0x18]
   a3ccc: ed8d0b04     	vstr	d0, [sp, #16]
   a3cd0: e59d0040     	ldr	r0, [sp, #0x40]
   a3cd4: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0xa4cc0 <.text+0x94bc0>
   a3cd8: e58d0008     	str	r0, [sp, #0x8]
   a3cdc: e08f1001     	add	r1, pc, r1
   a3ce0: e58d1004     	str	r1, [sp, #0x4]
   a3ce4: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0xa4ce4 <.text+0x94be4>
   a3ce8: e1a01005     	mov	r1, r5
   a3cec: e08f0000     	add	r0, pc, r0
   a3cf0: eb0158f3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x563cc
   a3cf4: e59a0000     	ldr	r0, [r10]
   a3cf8: e2401001     	sub	r1, r0, #1
   a3cfc: e0000190     	mul	r0, r0, r1
   a3d00: e3100001     	tst	r0, #1
   a3d04: 0a0007ee     	beq	0xa5cc4 <.text+0x95bc4> @ imm = #0x1fb8
   a3d08: e5940000     	ldr	r0, [r4]
   a3d0c: e350000a     	cmp	r0, #10
   a3d10: ba0007eb     	blt	0xa5cc4 <.text+0x95bc4> @ imm = #0x1fac
   a3d14: e59d5038     	ldr	r5, [sp, #0x38]
   a3d18: e1a00005     	mov	r0, r5
   a3d1c: eb1408f9     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5023e4
   a3d20: e3a00003     	mov	r0, #3
   a3d24: e3a07003     	mov	r7, #3
   a3d28: e5860000     	str	r0, [r6]
   a3d2c: e1a00005     	mov	r0, r5
   a3d30: eb140a63     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x50298c
   a3d34: ed960b04     	vldr	d0, [r6, #16]
   a3d38: e300318a     	movw	r3, #0x18a
   a3d3c: e5962018     	ldr	r2, [r6, #0x18]
   a3d40: e596101c     	ldr	r1, [r6, #0x1c]
   a3d44: e58d1018     	str	r1, [sp, #0x18]
   a3d48: e58d201c     	str	r2, [sp, #0x1c]
   a3d4c: ed8d0b04     	vstr	d0, [sp, #16]
   a3d50: e58d7000     	str	r7, [sp]
   a3d54: e5960008     	ldr	r0, [r6, #0x8]
   a3d58: e59f1f88     	ldr	r1, [pc, #0xf88]        @ 0xa4ce8 <.text+0x94be8>
   a3d5c: e58d0008     	str	r0, [sp, #0x8]
   a3d60: e08f1001     	add	r1, pc, r1
   a3d64: e58d1004     	str	r1, [sp, #0x4]
   a3d68: e59f5f7c     	ldr	r5, [pc, #0xf7c]        @ 0xa4cec <.text+0x94bec>
   a3d6c: e08f5005     	add	r5, pc, r5
   a3d70: e1a00005     	mov	r0, r5
   a3d74: e59f5f74     	ldr	r5, [pc, #0xf74]        @ 0xa4cf0 <.text+0x94bf0>
   a3d78: e59f7f74     	ldr	r7, [pc, #0xf74]        @ 0xa4cf4 <.text+0x94bf4>
   a3d7c: e08f5005     	add	r5, pc, r5
   a3d80: e08f7007     	add	r7, pc, r7
   a3d84: e1a01005     	mov	r1, r5
   a3d88: e1a02007     	mov	r2, r7
   a3d8c: eb0158cc     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56330
   a3d90: ed990b0a     	vldr	d0, [r9, #40]
   a3d94: e3a06003     	mov	r6, #3
   a3d98: e5992030     	ldr	r2, [r9, #0x30]
   a3d9c: e300318d     	movw	r3, #0x18d
   a3da0: e5991034     	ldr	r1, [r9, #0x34]
   a3da4: e58d201c     	str	r2, [sp, #0x1c]
   a3da8: e1a02007     	mov	r2, r7
   a3dac: e58d1018     	str	r1, [sp, #0x18]
   a3db0: ed8d0b04     	vstr	d0, [sp, #16]
   a3db4: e58d6000     	str	r6, [sp]
   a3db8: e5990020     	ldr	r0, [r9, #0x20]
   a3dbc: e59f1f34     	ldr	r1, [pc, #0xf34]        @ 0xa4cf8 <.text+0x94bf8>
   a3dc0: e58d0008     	str	r0, [sp, #0x8]
   a3dc4: e08f1001     	add	r1, pc, r1
   a3dc8: e58d1004     	str	r1, [sp, #0x4]
   a3dcc: e59f0f28     	ldr	r0, [pc, #0xf28]        @ 0xa4cfc <.text+0x94bfc>
   a3dd0: e1a01005     	mov	r1, r5
   a3dd4: e08f0000     	add	r0, pc, r0
   a3dd8: eb0158b9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x562e4
   a3ddc: ed9d0b12     	vldr	d0, [sp, #72]
   a3de0: e3a03e19     	mov	r3, #400
   a3de4: e59d1054     	ldr	r1, [sp, #0x54]
   a3de8: e59d2050     	ldr	r2, [sp, #0x50]
   a3dec: e58d201c     	str	r2, [sp, #0x1c]
   a3df0: e1a02007     	mov	r2, r7
   a3df4: e58d6000     	str	r6, [sp]
   a3df8: e1a06009     	mov	r6, r9
   a3dfc: e58d1018     	str	r1, [sp, #0x18]
   a3e00: ed8d0b04     	vstr	d0, [sp, #16]
   a3e04: e59d0040     	ldr	r0, [sp, #0x40]
   a3e08: e59f1ef0     	ldr	r1, [pc, #0xef0]        @ 0xa4d00 <.text+0x94c00>
   a3e0c: e58d0008     	str	r0, [sp, #0x8]
   a3e10: e08f1001     	add	r1, pc, r1
   a3e14: e58d1004     	str	r1, [sp, #0x4]
   a3e18: e59f0ee4     	ldr	r0, [pc, #0xee4]        @ 0xa4d04 <.text+0x94c04>
   a3e1c: e1a01005     	mov	r1, r5
   a3e20: e08f0000     	add	r0, pc, r0
   a3e24: eb0158a6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56298
   a3e28: eaffff6c     	b	0xa3be0 <.text+0x93ae0> @ imm = #-0x250
   a3e2c: 00544ef3     	ldrsheq	r4, [r4], #-227
   a3e30: 00544e90     	<unknown>
   a3e34: 00544ec4     	subseq	r4, r4, r4, asr #29
   a3e38: 00544fd3     	ldrsbeq	r4, [r4], #-243
   a3e3c: 00544fa6     	subseq	r4, r4, r6, lsr #31
   a3e40: 0056fb58     	subseq	pc, r6, r8, asr r11
   a3e44: 0053b930     	subseq	r11, r3, r0, lsr r9
   a3e48: 0056fb2c     	subseq	pc, r6, r12, lsr #22
   a3e4c: 00544efc     	ldrsheq	r4, [r4], #-236
   a3e50: 00544dcf     	subseq	r4, r4, pc, asr #27
   a3e54: 00544d6c     	subseq	r4, r4, r12, ror #26
   a3e58: 00544da0     	subseq	r4, r4, r0, lsr #27
   a3e5c: 00544eaf     	subseq	r4, r4, pc, lsr #29
   a3e60: 00544e82     	subseq	r4, r4, r2, lsl #29
   a3e64: e59d1030     	ldr	r1, [sp, #0x30]
   a3e68: e1a00008     	mov	r0, r8
   a3e6c: eb000a24     	bl	0xa6704 <.text+0x96604> @ imm = #0x2890
   a3e70: ed960b04     	vldr	d0, [r6, #16]
   a3e74: e300318a     	movw	r3, #0x18a
   a3e78: e596101c     	ldr	r1, [r6, #0x1c]
   a3e7c: e5962018     	ldr	r2, [r6, #0x18]
   a3e80: e58d1018     	str	r1, [sp, #0x18]
   a3e84: e3a01003     	mov	r1, #3
   a3e88: e58d201c     	str	r2, [sp, #0x1c]
   a3e8c: ed8d0b04     	vstr	d0, [sp, #16]
   a3e90: e58d1000     	str	r1, [sp]
   a3e94: e5960008     	ldr	r0, [r6, #0x8]
   a3e98: e59f1e68     	ldr	r1, [pc, #0xe68]        @ 0xa4d08 <.text+0x94c08>
   a3e9c: e58d0008     	str	r0, [sp, #0x8]
   a3ea0: e08f1001     	add	r1, pc, r1
   a3ea4: e58d1004     	str	r1, [sp, #0x4]
   a3ea8: e59f5ff8     	ldr	r5, [pc, #0xff8]        @ 0xa4ea8 <.text+0x94da8>
   a3eac: e08f5005     	add	r5, pc, r5
   a3eb0: e1a00005     	mov	r0, r5
   a3eb4: e59f5ff0     	ldr	r5, [pc, #0xff0]        @ 0xa4eac <.text+0x94dac>
   a3eb8: e59f7ff0     	ldr	r7, [pc, #0xff0]        @ 0xa4eb0 <.text+0x94db0>
   a3ebc: e08f5005     	add	r5, pc, r5
   a3ec0: e08f7007     	add	r7, pc, r7
   a3ec4: e1a01005     	mov	r1, r5
   a3ec8: e1a02007     	mov	r2, r7
   a3ecc: eb01587c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x561f0
   a3ed0: e59f0fdc     	ldr	r0, [pc, #0xfdc]        @ 0xa4eb4 <.text+0x94db4>
   a3ed4: e3a06003     	mov	r6, #3
   a3ed8: e300318d     	movw	r3, #0x18d
   a3edc: e08f0000     	add	r0, pc, r0
   a3ee0: e5900020     	ldr	r0, [r0, #0x20]
   a3ee4: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0xa4edc <.text+0x94ddc>
   a3ee8: e08f1001     	add	r1, pc, r1
   a3eec: ed910b0a     	vldr	d0, [r1, #40]
   a3ef0: e59f1fe8     	ldr	r1, [pc, #0xfe8]        @ 0xa4ee0 <.text+0x94de0>
   a3ef4: ed8d0b04     	vstr	d0, [sp, #16]
   a3ef8: e08f1001     	add	r1, pc, r1
   a3efc: e58d6000     	str	r6, [sp]
   a3f00: e5912030     	ldr	r2, [r1, #0x30]
   a3f04: e5911034     	ldr	r1, [r1, #0x34]
   a3f08: e58d201c     	str	r2, [sp, #0x1c]
   a3f0c: e1a02007     	mov	r2, r7
   a3f10: e58d1018     	str	r1, [sp, #0x18]
   a3f14: e59f1fc8     	ldr	r1, [pc, #0xfc8]        @ 0xa4ee4 <.text+0x94de4>
   a3f18: e58d0008     	str	r0, [sp, #0x8]
   a3f1c: e08f1001     	add	r1, pc, r1
   a3f20: e58d1004     	str	r1, [sp, #0x4]
   a3f24: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0xa4ee8 <.text+0x94de8>
   a3f28: e1a01005     	mov	r1, r5
   a3f2c: e08f0000     	add	r0, pc, r0
   a3f30: eb015863     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5618c
   a3f34: ed9d0b12     	vldr	d0, [sp, #72]
   a3f38: e3a03e19     	mov	r3, #400
   a3f3c: e59d1054     	ldr	r1, [sp, #0x54]
   a3f40: e59d2050     	ldr	r2, [sp, #0x50]
   a3f44: e58d201c     	str	r2, [sp, #0x1c]
   a3f48: e1a02007     	mov	r2, r7
   a3f4c: e58d1018     	str	r1, [sp, #0x18]
   a3f50: ed8d0b04     	vstr	d0, [sp, #16]
   a3f54: e58d6000     	str	r6, [sp]
   a3f58: e59d0040     	ldr	r0, [sp, #0x40]
   a3f5c: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0xa4f48 <.text+0x94e48>
   a3f60: e58d0008     	str	r0, [sp, #0x8]
   a3f64: e08f1001     	add	r1, pc, r1
   a3f68: e58d1004     	str	r1, [sp, #0x4]
   a3f6c: e59f0fd8     	ldr	r0, [pc, #0xfd8]        @ 0xa4f4c <.text+0x94e4c>
   a3f70: e59d5034     	ldr	r5, [sp, #0x34]
   a3f74: e59f1fd4     	ldr	r1, [pc, #0xfd4]        @ 0xa4f50 <.text+0x94e50>
   a3f78: e08f0000     	add	r0, pc, r0
   a3f7c: e59f6fd0     	ldr	r6, [pc, #0xfd0]        @ 0xa4f54 <.text+0x94e54>
   a3f80: e08f1001     	add	r1, pc, r1
   a3f84: e08f6006     	add	r6, pc, r6
   a3f88: eb01584d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56134
   a3f8c: e59a0000     	ldr	r0, [r10]
   a3f90: e2401001     	sub	r1, r0, #1
   a3f94: e0000190     	mul	r0, r0, r1
   a3f98: e3100001     	tst	r0, #1
   a3f9c: 0afff8da     	beq	0xa230c <.text+0x9220c> @ imm = #-0x1c98
   a3fa0: e5940000     	ldr	r0, [r4]
   a3fa4: e350000a     	cmp	r0, #10
   a3fa8: bafff8d7     	blt	0xa230c <.text+0x9220c> @ imm = #-0x1ca4
   a3fac: e59d1030     	ldr	r1, [sp, #0x30]
   a3fb0: e1a00008     	mov	r0, r8
   a3fb4: eb0009d2     	bl	0xa6704 <.text+0x96604> @ imm = #0x2748
   a3fb8: ed960b04     	vldr	d0, [r6, #16]
   a3fbc: e300318a     	movw	r3, #0x18a
   a3fc0: e596101c     	ldr	r1, [r6, #0x1c]
   a3fc4: e5962018     	ldr	r2, [r6, #0x18]
   a3fc8: e58d1018     	str	r1, [sp, #0x18]
   a3fcc: e3a01003     	mov	r1, #3
   a3fd0: e58d201c     	str	r2, [sp, #0x1c]
   a3fd4: ed8d0b04     	vstr	d0, [sp, #16]
   a3fd8: e58d1000     	str	r1, [sp]
   a3fdc: e5960008     	ldr	r0, [r6, #0x8]
   a3fe0: e59f1f70     	ldr	r1, [pc, #0xf70]        @ 0xa4f58 <.text+0x94e58>
   a3fe4: e58d0008     	str	r0, [sp, #0x8]
   a3fe8: e08f1001     	add	r1, pc, r1
   a3fec: e58d1004     	str	r1, [sp, #0x4]
   a3ff0: e59f5f64     	ldr	r5, [pc, #0xf64]        @ 0xa4f5c <.text+0x94e5c>
   a3ff4: e08f5005     	add	r5, pc, r5
   a3ff8: e1a00005     	mov	r0, r5
   a3ffc: e59f5f5c     	ldr	r5, [pc, #0xf5c]        @ 0xa4f60 <.text+0x94e60>
   a4000: e59f7f5c     	ldr	r7, [pc, #0xf5c]        @ 0xa4f64 <.text+0x94e64>
   a4004: e08f5005     	add	r5, pc, r5
   a4008: e08f7007     	add	r7, pc, r7
   a400c: e1a01005     	mov	r1, r5
   a4010: e1a02007     	mov	r2, r7
   a4014: eb01582a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x560a8
   a4018: e59f0f48     	ldr	r0, [pc, #0xf48]        @ 0xa4f68 <.text+0x94e68>
   a401c: e3a06003     	mov	r6, #3
   a4020: e300318d     	movw	r3, #0x18d
   a4024: e08f0000     	add	r0, pc, r0
   a4028: e5900020     	ldr	r0, [r0, #0x20]
   a402c: e59f1f38     	ldr	r1, [pc, #0xf38]        @ 0xa4f6c <.text+0x94e6c>
   a4030: e08f1001     	add	r1, pc, r1
   a4034: ed910b0a     	vldr	d0, [r1, #40]
   a4038: e59f1f30     	ldr	r1, [pc, #0xf30]        @ 0xa4f70 <.text+0x94e70>
   a403c: ed8d0b04     	vstr	d0, [sp, #16]
   a4040: e08f1001     	add	r1, pc, r1
   a4044: e58d6000     	str	r6, [sp]
   a4048: e5912030     	ldr	r2, [r1, #0x30]
   a404c: e5911034     	ldr	r1, [r1, #0x34]
   a4050: e58d201c     	str	r2, [sp, #0x1c]
   a4054: e1a02007     	mov	r2, r7
   a4058: e58d1018     	str	r1, [sp, #0x18]
   a405c: e59f1f10     	ldr	r1, [pc, #0xf10]        @ 0xa4f74 <.text+0x94e74>
   a4060: e58d0008     	str	r0, [sp, #0x8]
   a4064: e08f1001     	add	r1, pc, r1
   a4068: e58d1004     	str	r1, [sp, #0x4]
   a406c: e59f0f04     	ldr	r0, [pc, #0xf04]        @ 0xa4f78 <.text+0x94e78>
   a4070: e1a01005     	mov	r1, r5
   a4074: e08f0000     	add	r0, pc, r0
   a4078: eb015811     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x56044
   a407c: ed9d0b12     	vldr	d0, [sp, #72]
   a4080: e3a03e19     	mov	r3, #400
   a4084: e59d1054     	ldr	r1, [sp, #0x54]
   a4088: e59d2050     	ldr	r2, [sp, #0x50]
   a408c: e58d201c     	str	r2, [sp, #0x1c]
   a4090: e1a02007     	mov	r2, r7
   a4094: e58d1018     	str	r1, [sp, #0x18]
   a4098: ed8d0b04     	vstr	d0, [sp, #16]
   a409c: e58d6000     	str	r6, [sp]
   a40a0: e59d0040     	ldr	r0, [sp, #0x40]
   a40a4: e59f1ed0     	ldr	r1, [pc, #0xed0]        @ 0xa4f7c <.text+0x94e7c>
   a40a8: e58d0008     	str	r0, [sp, #0x8]
   a40ac: e08f1001     	add	r1, pc, r1
   a40b0: e58d1004     	str	r1, [sp, #0x4]
   a40b4: e59f0ec4     	ldr	r0, [pc, #0xec4]        @ 0xa4f80 <.text+0x94e80>
   a40b8: e1a01005     	mov	r1, r5
   a40bc: e59f6ec0     	ldr	r6, [pc, #0xec0]        @ 0xa4f84 <.text+0x94e84>
   a40c0: e08f0000     	add	r0, pc, r0
   a40c4: e08f6006     	add	r6, pc, r6
   a40c8: eb0157fd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55ff4
   a40cc: eaffff64     	b	0xa3e64 <.text+0x93d64> @ imm = #-0x270
   a40d0: 0053b700     	subseq	r11, r3, r0, lsl #14
   a40d4: 0056f910     	subseq	pc, r6, r0, lsl r9
   a40d8: 00544cd0     	ldrsbeq	r4, [r4], #-192
   a40dc: 00544ba3     	subseq	r4, r4, r3, lsr #23
   a40e0: 00544b40     	subseq	r4, r4, r0, asr #22
   a40e4: 00544b74     	subseq	r4, r4, r4, ror r11
   a40e8: 00544c7f     	subseq	r4, r4, pc, ror r12
   a40ec: 00544b18     	subseq	r4, r4, r8, lsl r11
   a40f0: 00544c46     	subseq	r4, r4, r6, asr #24
   a40f4: 00544a94     	<unknown>
   a40f8: 0056f7a8     	subseq	pc, r6, r8, lsr #15
   a40fc: 00544b58     	subseq	r4, r4, r8, asr r11
   a4100: 00544a2b     	subseq	r4, r4, r11, lsr #20
   a4104: 005449c8     	subseq	r4, r4, r8, asr #19
   a4108: 005449fc     	ldrsheq	r4, [r4], #-156
   a410c: 00544b07     	subseq	r4, r4, r7, lsl #22
   a4110: 00544ad6     	ldrsbeq	r4, [r4], #-166
   a4114: 0054497f     	subseq	r4, r4, pc, ror r9
   a4118: e286c020     	add	r12, r6, #32
   a411c: e2861008     	add	r1, r6, #8
   a4120: e89c00ed     	ldm	r12, {r0, r2, r3, r5, r6, r7}
   a4124: e88100ed     	stm	r1, {r0, r2, r3, r5, r6, r7}
   a4128: e1a00008     	mov	r0, r8
   a412c: e59f6e54     	ldr	r6, [pc, #0xe54]        @ 0xa4f88 <.text+0x94e88>
   a4130: e08f6006     	add	r6, pc, r6
   a4134: e5961030     	ldr	r1, [r6, #0x30]
   a4138: e1a09006     	mov	r9, r6
   a413c: eb000970     	bl	0xa6704 <.text+0x96604> @ imm = #0x25c0
   a4140: e59d5038     	ldr	r5, [sp, #0x38]
   a4144: e1a00005     	mov	r0, r5
   a4148: eb1407ee     	bl	0x5a6108 <.text+0x596008> @ imm = #0x501fb8
   a414c: e3a00003     	mov	r0, #3
   a4150: e5860000     	str	r0, [r6]
   a4154: e1a00005     	mov	r0, r5
   a4158: e3a06003     	mov	r6, #3
   a415c: eb140958     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x502560
   a4160: ed990b04     	vldr	d0, [r9, #16]
   a4164: e300318a     	movw	r3, #0x18a
   a4168: e5992018     	ldr	r2, [r9, #0x18]
   a416c: e599101c     	ldr	r1, [r9, #0x1c]
   a4170: e58d1018     	str	r1, [sp, #0x18]
   a4174: e58d201c     	str	r2, [sp, #0x1c]
   a4178: ed8d0b04     	vstr	d0, [sp, #16]
   a417c: e58d6000     	str	r6, [sp]
   a4180: e5990008     	ldr	r0, [r9, #0x8]
   a4184: e59f1e00     	ldr	r1, [pc, #0xe00]        @ 0xa4f8c <.text+0x94e8c>
   a4188: e58d0008     	str	r0, [sp, #0x8]
   a418c: e08f1001     	add	r1, pc, r1
   a4190: e58d1004     	str	r1, [sp, #0x4]
   a4194: e59f5df4     	ldr	r5, [pc, #0xdf4]        @ 0xa4f90 <.text+0x94e90>
   a4198: e08f5005     	add	r5, pc, r5
   a419c: e1a00005     	mov	r0, r5
   a41a0: e59f5dec     	ldr	r5, [pc, #0xdec]        @ 0xa4f94 <.text+0x94e94>
   a41a4: e59f7dec     	ldr	r7, [pc, #0xdec]        @ 0xa4f98 <.text+0x94e98>
   a41a8: e08f5005     	add	r5, pc, r5
   a41ac: e08f7007     	add	r7, pc, r7
   a41b0: e1a01005     	mov	r1, r5
   a41b4: e1a02007     	mov	r2, r7
   a41b8: eb0157c1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55f04
   a41bc: ed990b0a     	vldr	d0, [r9, #40]
   a41c0: e3a06003     	mov	r6, #3
   a41c4: e5992030     	ldr	r2, [r9, #0x30]
   a41c8: e300318d     	movw	r3, #0x18d
   a41cc: e5991034     	ldr	r1, [r9, #0x34]
   a41d0: e58d201c     	str	r2, [sp, #0x1c]
   a41d4: e1a02007     	mov	r2, r7
   a41d8: e58d1018     	str	r1, [sp, #0x18]
   a41dc: ed8d0b04     	vstr	d0, [sp, #16]
   a41e0: e58d6000     	str	r6, [sp]
   a41e4: e5990020     	ldr	r0, [r9, #0x20]
   a41e8: e59f1dac     	ldr	r1, [pc, #0xdac]        @ 0xa4f9c <.text+0x94e9c>
   a41ec: e58d0008     	str	r0, [sp, #0x8]
   a41f0: e08f1001     	add	r1, pc, r1
   a41f4: e58d1004     	str	r1, [sp, #0x4]
   a41f8: e59f0da0     	ldr	r0, [pc, #0xda0]        @ 0xa4fa0 <.text+0x94ea0>
   a41fc: e1a01005     	mov	r1, r5
   a4200: e08f0000     	add	r0, pc, r0
   a4204: eb0157ae     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55eb8
   a4208: ed9d0b12     	vldr	d0, [sp, #72]
   a420c: e3a03e19     	mov	r3, #400
   a4210: e59d1054     	ldr	r1, [sp, #0x54]
   a4214: e59d2050     	ldr	r2, [sp, #0x50]
   a4218: e58d201c     	str	r2, [sp, #0x1c]
   a421c: e1a02007     	mov	r2, r7
   a4220: e58d6000     	str	r6, [sp]
   a4224: e1a06009     	mov	r6, r9
   a4228: e58d1018     	str	r1, [sp, #0x18]
   a422c: ed8d0b04     	vstr	d0, [sp, #16]
   a4230: e59d0040     	ldr	r0, [sp, #0x40]
   a4234: e59f1ffc     	ldr	r1, [pc, #0xffc]        @ 0xa5238 <.text+0x95138>
   a4238: e58d0008     	str	r0, [sp, #0x8]
   a423c: e08f1001     	add	r1, pc, r1
   a4240: e58d1004     	str	r1, [sp, #0x4]
   a4244: e59f0ff0     	ldr	r0, [pc, #0xff0]        @ 0xa523c <.text+0x9513c>
   a4248: e1a01005     	mov	r1, r5
   a424c: e08f0000     	add	r0, pc, r0
   a4250: eb01579b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55e6c
   a4254: e59a0000     	ldr	r0, [r10]
   a4258: e2401001     	sub	r1, r0, #1
   a425c: e0000190     	mul	r0, r0, r1
   a4260: e3100001     	tst	r0, #1
   a4264: 0a000696     	beq	0xa5cc4 <.text+0x95bc4> @ imm = #0x1a58
   a4268: e5940000     	ldr	r0, [r4]
   a426c: e350000a     	cmp	r0, #10
   a4270: ba000693     	blt	0xa5cc4 <.text+0x95bc4> @ imm = #0x1a4c
   a4274: e2860020     	add	r0, r6, #32
   a4278: e2861008     	add	r1, r6, #8
   a427c: e89000fc     	ldm	r0, {r2, r3, r4, r5, r6, r7}
   a4280: e1a00008     	mov	r0, r8
   a4284: e88100fc     	stm	r1, {r2, r3, r4, r5, r6, r7}
   a4288: e59f4fb0     	ldr	r4, [pc, #0xfb0]        @ 0xa5240 <.text+0x95140>
   a428c: e79f4004     	ldr	r4, [pc, r4]
   a4290: e59f6fac     	ldr	r6, [pc, #0xfac]        @ 0xa5244 <.text+0x95144>
   a4294: e08f6006     	add	r6, pc, r6
   a4298: e5961030     	ldr	r1, [r6, #0x30]
   a429c: e1a09006     	mov	r9, r6
   a42a0: eb000917     	bl	0xa6704 <.text+0x96604> @ imm = #0x245c
   a42a4: e59d5038     	ldr	r5, [sp, #0x38]
   a42a8: e1a00005     	mov	r0, r5
   a42ac: eb140795     	bl	0x5a6108 <.text+0x596008> @ imm = #0x501e54
   a42b0: e3a00003     	mov	r0, #3
   a42b4: e5860000     	str	r0, [r6]
   a42b8: e1a00005     	mov	r0, r5
   a42bc: e3a06003     	mov	r6, #3
   a42c0: eb1408ff     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5023fc
   a42c4: ed990b04     	vldr	d0, [r9, #16]
   a42c8: e300318a     	movw	r3, #0x18a
   a42cc: e5992018     	ldr	r2, [r9, #0x18]
   a42d0: e599101c     	ldr	r1, [r9, #0x1c]
   a42d4: e58d1018     	str	r1, [sp, #0x18]
   a42d8: e58d201c     	str	r2, [sp, #0x1c]
   a42dc: ed8d0b04     	vstr	d0, [sp, #16]
   a42e0: e58d6000     	str	r6, [sp]
   a42e4: e5990008     	ldr	r0, [r9, #0x8]
   a42e8: e59f1f58     	ldr	r1, [pc, #0xf58]        @ 0xa5248 <.text+0x95148>
   a42ec: e58d0008     	str	r0, [sp, #0x8]
   a42f0: e08f1001     	add	r1, pc, r1
   a42f4: e58d1004     	str	r1, [sp, #0x4]
   a42f8: e59f5f4c     	ldr	r5, [pc, #0xf4c]        @ 0xa524c <.text+0x9514c>
   a42fc: e08f5005     	add	r5, pc, r5
   a4300: e1a00005     	mov	r0, r5
   a4304: e59f5f44     	ldr	r5, [pc, #0xf44]        @ 0xa5250 <.text+0x95150>
   a4308: e59f7f44     	ldr	r7, [pc, #0xf44]        @ 0xa5254 <.text+0x95154>
   a430c: e08f5005     	add	r5, pc, r5
   a4310: e08f7007     	add	r7, pc, r7
   a4314: e1a01005     	mov	r1, r5
   a4318: e1a02007     	mov	r2, r7
   a431c: eb015768     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55da0
   a4320: ed990b0a     	vldr	d0, [r9, #40]
   a4324: e3a06003     	mov	r6, #3
   a4328: e5992030     	ldr	r2, [r9, #0x30]
   a432c: e300318d     	movw	r3, #0x18d
   a4330: e5991034     	ldr	r1, [r9, #0x34]
   a4334: e58d201c     	str	r2, [sp, #0x1c]
   a4338: e1a02007     	mov	r2, r7
   a433c: e58d1018     	str	r1, [sp, #0x18]
   a4340: ed8d0b04     	vstr	d0, [sp, #16]
   a4344: e58d6000     	str	r6, [sp]
   a4348: e5990020     	ldr	r0, [r9, #0x20]
   a434c: e59f1f04     	ldr	r1, [pc, #0xf04]        @ 0xa5258 <.text+0x95158>
   a4350: e58d0008     	str	r0, [sp, #0x8]
   a4354: e08f1001     	add	r1, pc, r1
   a4358: e58d1004     	str	r1, [sp, #0x4]
   a435c: e59f0ef8     	ldr	r0, [pc, #0xef8]        @ 0xa525c <.text+0x9515c>
   a4360: e1a01005     	mov	r1, r5
   a4364: e08f0000     	add	r0, pc, r0
   a4368: eb015755     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55d54
   a436c: ed9d0b12     	vldr	d0, [sp, #72]
   a4370: e3a03e19     	mov	r3, #400
   a4374: e59d1054     	ldr	r1, [sp, #0x54]
   a4378: e59d2050     	ldr	r2, [sp, #0x50]
   a437c: e58d201c     	str	r2, [sp, #0x1c]
   a4380: e1a02007     	mov	r2, r7
   a4384: e58d6000     	str	r6, [sp]
   a4388: e1a06009     	mov	r6, r9
   a438c: e58d1018     	str	r1, [sp, #0x18]
   a4390: ed8d0b04     	vstr	d0, [sp, #16]
   a4394: e59d0040     	ldr	r0, [sp, #0x40]
   a4398: e59f1ec0     	ldr	r1, [pc, #0xec0]        @ 0xa5260 <.text+0x95160>
   a439c: e58d0008     	str	r0, [sp, #0x8]
   a43a0: e08f1001     	add	r1, pc, r1
   a43a4: e58d1004     	str	r1, [sp, #0x4]
   a43a8: e59f0eb4     	ldr	r0, [pc, #0xeb4]        @ 0xa5264 <.text+0x95164>
   a43ac: e1a01005     	mov	r1, r5
   a43b0: e08f0000     	add	r0, pc, r0
   a43b4: eb015742     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55d08
   a43b8: eaffff56     	b	0xa4118 <.text+0x94018> @ imm = #-0x2a8
   a43bc: 0053b420     	subseq	r11, r3, r0, lsr #8
   a43c0: 0056f628     	subseq	pc, r6, r8, lsr #12
   a43c4: 0056f5c4     	subseq	pc, r6, r4, asr #11
   a43c8: 0053b3a4     	subseq	r11, r3, r4, lsr #7
   a43cc: 0056f568     	subseq	pc, r6, r8, ror #10
   a43d0: 00544918     	subseq	r4, r4, r8, lsl r9
   a43d4: 005447eb     	subseq	r4, r4, r11, ror #15
   a43d8: 00544788     	subseq	r4, r4, r8, lsl #15
   a43dc: 005447bc     	ldrheq	r4, [r4], #-124
   a43e0: 005448c7     	subseq	r4, r4, r7, asr #17
   a43e4: 0054489a     	<unknown>
   a43e8: 0056f448     	subseq	pc, r6, r8, asr #8
   a43ec: e59d1030     	ldr	r1, [sp, #0x30]
   a43f0: e286c008     	add	r12, r6, #8
   a43f4: e89100ed     	ldm	r1, {r0, r2, r3, r5, r6, r7}
   a43f8: e88c00ed     	stm	r12, {r0, r2, r3, r5, r6, r7}
   a43fc: e1a00008     	mov	r0, r8
   a4400: e59f9e60     	ldr	r9, [pc, #0xe60]        @ 0xa5268 <.text+0x95168>
   a4404: e08f9009     	add	r9, pc, r9
   a4408: e5991030     	ldr	r1, [r9, #0x30]
   a440c: eb0008bc     	bl	0xa6704 <.text+0x96604> @ imm = #0x22f0
   a4410: e59d5038     	ldr	r5, [sp, #0x38]
   a4414: e1a00005     	mov	r0, r5
   a4418: eb14073a     	bl	0x5a6108 <.text+0x596008> @ imm = #0x501ce8
   a441c: e3a00003     	mov	r0, #3
   a4420: e3a06003     	mov	r6, #3
   a4424: e5890000     	str	r0, [r9]
   a4428: e1a00005     	mov	r0, r5
   a442c: eb1408a4     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x502290
   a4430: ed990b04     	vldr	d0, [r9, #16]
   a4434: e300318a     	movw	r3, #0x18a
   a4438: e5992018     	ldr	r2, [r9, #0x18]
   a443c: e599101c     	ldr	r1, [r9, #0x1c]
   a4440: e58d1018     	str	r1, [sp, #0x18]
   a4444: e58d201c     	str	r2, [sp, #0x1c]
   a4448: ed8d0b04     	vstr	d0, [sp, #16]
   a444c: e58d6000     	str	r6, [sp]
   a4450: e5990008     	ldr	r0, [r9, #0x8]
   a4454: e59f1e10     	ldr	r1, [pc, #0xe10]        @ 0xa526c <.text+0x9516c>
   a4458: e58d0008     	str	r0, [sp, #0x8]
   a445c: e08f1001     	add	r1, pc, r1
   a4460: e58d1004     	str	r1, [sp, #0x4]
   a4464: e59f5e04     	ldr	r5, [pc, #0xe04]        @ 0xa5270 <.text+0x95170>
   a4468: e59f7e04     	ldr	r7, [pc, #0xe04]        @ 0xa5274 <.text+0x95174>
   a446c: e59f6e04     	ldr	r6, [pc, #0xe04]        @ 0xa5278 <.text+0x95178>
   a4470: e08f5005     	add	r5, pc, r5
   a4474: e08f7007     	add	r7, pc, r7
   a4478: e08f6006     	add	r6, pc, r6
   a447c: e1a00005     	mov	r0, r5
   a4480: e1a01007     	mov	r1, r7
   a4484: e1a02006     	mov	r2, r6
   a4488: eb01570d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55c34
   a448c: ed990b0a     	vldr	d0, [r9, #40]
   a4490: e300318d     	movw	r3, #0x18d
   a4494: e5992030     	ldr	r2, [r9, #0x30]
   a4498: e5991034     	ldr	r1, [r9, #0x34]
   a449c: e5990020     	ldr	r0, [r9, #0x20]
   a44a0: e3a09003     	mov	r9, #3
   a44a4: e58d201c     	str	r2, [sp, #0x1c]
   a44a8: e1a02006     	mov	r2, r6
   a44ac: e58d1018     	str	r1, [sp, #0x18]
   a44b0: ed8d0b04     	vstr	d0, [sp, #16]
   a44b4: e58d9000     	str	r9, [sp]
   a44b8: e59f1fd8     	ldr	r1, [pc, #0xfd8]        @ 0xa5498 <.text+0x95398>
   a44bc: e58d0008     	str	r0, [sp, #0x8]
   a44c0: e1a00005     	mov	r0, r5
   a44c4: e08f1001     	add	r1, pc, r1
   a44c8: e58d1004     	str	r1, [sp, #0x4]
   a44cc: e1a01007     	mov	r1, r7
   a44d0: eb0156fb     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55bec
   a44d4: ed9d0b12     	vldr	d0, [sp, #72]
   a44d8: e3a03e19     	mov	r3, #400
   a44dc: e59d1054     	ldr	r1, [sp, #0x54]
   a44e0: e59d2050     	ldr	r2, [sp, #0x50]
   a44e4: e58d201c     	str	r2, [sp, #0x1c]
   a44e8: e1a02006     	mov	r2, r6
   a44ec: e58d1018     	str	r1, [sp, #0x18]
   a44f0: ed8d0b04     	vstr	d0, [sp, #16]
   a44f4: e58d9000     	str	r9, [sp]
   a44f8: e59d0040     	ldr	r0, [sp, #0x40]
   a44fc: e59f1fdc     	ldr	r1, [pc, #0xfdc]        @ 0xa54e0 <.text+0x953e0>
   a4500: e58d0008     	str	r0, [sp, #0x8]
   a4504: e1a00005     	mov	r0, r5
   a4508: e08f1001     	add	r1, pc, r1
   a450c: e58d1004     	str	r1, [sp, #0x4]
   a4510: e59f6ff8     	ldr	r6, [pc, #0xff8]        @ 0xa5510 <.text+0x95410>
   a4514: e1a01007     	mov	r1, r7
   a4518: e08f6006     	add	r6, pc, r6
   a451c: eb0156e8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55ba0
   a4520: e59a0000     	ldr	r0, [r10]
   a4524: e2401001     	sub	r1, r0, #1
   a4528: e0000190     	mul	r0, r0, r1
   a452c: e3100001     	tst	r0, #1
   a4530: 0a0005e3     	beq	0xa5cc4 <.text+0x95bc4> @ imm = #0x178c
   a4534: e5940000     	ldr	r0, [r4]
   a4538: e350000a     	cmp	r0, #10
   a453c: ba0005e0     	blt	0xa5cc4 <.text+0x95bc4> @ imm = #0x1780
   a4540: e59d1030     	ldr	r1, [sp, #0x30]
   a4544: e2860008     	add	r0, r6, #8
   a4548: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a454c: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a4550: e1a00008     	mov	r0, r8
   a4554: e59f4fb8     	ldr	r4, [pc, #0xfb8]        @ 0xa5514 <.text+0x95414>
   a4558: e79f4004     	ldr	r4, [pc, r4]
   a455c: e59f6fb4     	ldr	r6, [pc, #0xfb4]        @ 0xa5518 <.text+0x95418>
   a4560: e08f6006     	add	r6, pc, r6
   a4564: e5961030     	ldr	r1, [r6, #0x30]
   a4568: e1a09006     	mov	r9, r6
   a456c: eb000864     	bl	0xa6704 <.text+0x96604> @ imm = #0x2190
   a4570: e59d5038     	ldr	r5, [sp, #0x38]
   a4574: e1a00005     	mov	r0, r5
   a4578: eb1406e2     	bl	0x5a6108 <.text+0x596008> @ imm = #0x501b88
   a457c: e3a00003     	mov	r0, #3
   a4580: e5860000     	str	r0, [r6]
   a4584: e1a00005     	mov	r0, r5
   a4588: e3a06003     	mov	r6, #3
   a458c: eb14084c     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x502130
   a4590: ed990b04     	vldr	d0, [r9, #16]
   a4594: e300318a     	movw	r3, #0x18a
   a4598: e5992018     	ldr	r2, [r9, #0x18]
   a459c: e599101c     	ldr	r1, [r9, #0x1c]
   a45a0: e58d1018     	str	r1, [sp, #0x18]
   a45a4: e58d201c     	str	r2, [sp, #0x1c]
   a45a8: ed8d0b04     	vstr	d0, [sp, #16]
   a45ac: e58d6000     	str	r6, [sp]
   a45b0: e5990008     	ldr	r0, [r9, #0x8]
   a45b4: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0xa5588 <.text+0x95488>
   a45b8: e58d0008     	str	r0, [sp, #0x8]
   a45bc: e08f1001     	add	r1, pc, r1
   a45c0: e58d1004     	str	r1, [sp, #0x4]
   a45c4: e59f5fc0     	ldr	r5, [pc, #0xfc0]        @ 0xa558c <.text+0x9548c>
   a45c8: e08f5005     	add	r5, pc, r5
   a45cc: e1a00005     	mov	r0, r5
   a45d0: e59f5fb8     	ldr	r5, [pc, #0xfb8]        @ 0xa5590 <.text+0x95490>
   a45d4: e59f7fb8     	ldr	r7, [pc, #0xfb8]        @ 0xa5594 <.text+0x95494>
   a45d8: e08f5005     	add	r5, pc, r5
   a45dc: e08f7007     	add	r7, pc, r7
   a45e0: e1a01005     	mov	r1, r5
   a45e4: e1a02007     	mov	r2, r7
   a45e8: eb0156b5     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55ad4
   a45ec: ed990b0a     	vldr	d0, [r9, #40]
   a45f0: e3a06003     	mov	r6, #3
   a45f4: e5992030     	ldr	r2, [r9, #0x30]
   a45f8: e300318d     	movw	r3, #0x18d
   a45fc: e5991034     	ldr	r1, [r9, #0x34]
   a4600: e58d201c     	str	r2, [sp, #0x1c]
   a4604: e1a02007     	mov	r2, r7
   a4608: e58d1018     	str	r1, [sp, #0x18]
   a460c: ed8d0b04     	vstr	d0, [sp, #16]
   a4610: e58d6000     	str	r6, [sp]
   a4614: e5990020     	ldr	r0, [r9, #0x20]
   a4618: e59f1f78     	ldr	r1, [pc, #0xf78]        @ 0xa5598 <.text+0x95498>
   a461c: e58d0008     	str	r0, [sp, #0x8]
   a4620: e08f1001     	add	r1, pc, r1
   a4624: e58d1004     	str	r1, [sp, #0x4]
   a4628: e59f0f6c     	ldr	r0, [pc, #0xf6c]        @ 0xa559c <.text+0x9549c>
   a462c: e1a01005     	mov	r1, r5
   a4630: e08f0000     	add	r0, pc, r0
   a4634: eb0156a2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55a88
   a4638: ed9d0b12     	vldr	d0, [sp, #72]
   a463c: e3a03e19     	mov	r3, #400
   a4640: e59d1054     	ldr	r1, [sp, #0x54]
   a4644: e59d2050     	ldr	r2, [sp, #0x50]
   a4648: e58d201c     	str	r2, [sp, #0x1c]
   a464c: e1a02007     	mov	r2, r7
   a4650: e58d6000     	str	r6, [sp]
   a4654: e1a06009     	mov	r6, r9
   a4658: e58d1018     	str	r1, [sp, #0x18]
   a465c: ed8d0b04     	vstr	d0, [sp, #16]
   a4660: e59d0040     	ldr	r0, [sp, #0x40]
   a4664: e59f1f34     	ldr	r1, [pc, #0xf34]        @ 0xa55a0 <.text+0x954a0>
   a4668: e58d0008     	str	r0, [sp, #0x8]
   a466c: e08f1001     	add	r1, pc, r1
   a4670: e58d1004     	str	r1, [sp, #0x4]
   a4674: e59f0f28     	ldr	r0, [pc, #0xf28]        @ 0xa55a4 <.text+0x954a4>
   a4678: e1a01005     	mov	r1, r5
   a467c: e08f0000     	add	r0, pc, r0
   a4680: eb01568f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55a3c
   a4684: eaffff58     	b	0xa43ec <.text+0x942ec> @ imm = #-0x2a0
   a4688: 0053b0bc     	ldrheq	r11, [r3], #-12
   a468c: 0056f228     	subseq	pc, r6, r8, lsr #4
   a4690: 0056f1cc     	subseq	pc, r6, r12, asr #3
   a4694: 0054457c     	subseq	r4, r4, r12, ror r5
   a4698: 0054444f     	subseq	r4, r4, pc, asr #8
   a469c: 005443ec     	subseq	r4, r4, r12, ror #7
   a46a0: 00544420     	subseq	r4, r4, r0, lsr #8
   a46a4: 0054452b     	subseq	r4, r4, r11, lsr #10
   a46a8: e59d1030     	ldr	r1, [sp, #0x30]
   a46ac: e286c008     	add	r12, r6, #8
   a46b0: e89100ed     	ldm	r1, {r0, r2, r3, r5, r6, r7}
   a46b4: e88c00ed     	stm	r12, {r0, r2, r3, r5, r6, r7}
   a46b8: e59f9fc8     	ldr	r9, [pc, #0xfc8]        @ 0xa5688 <.text+0x95588>
   a46bc: e59d5038     	ldr	r5, [sp, #0x38]
   a46c0: e08f9009     	add	r9, pc, r9
   a46c4: e1a00005     	mov	r0, r5
   a46c8: eb14068e     	bl	0x5a6108 <.text+0x596008> @ imm = #0x501a38
   a46cc: e3a00003     	mov	r0, #3
   a46d0: e3a06003     	mov	r6, #3
   a46d4: e5890000     	str	r0, [r9]
   a46d8: e1a00005     	mov	r0, r5
   a46dc: eb1407f8     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x501fe0
   a46e0: ed990b04     	vldr	d0, [r9, #16]
   a46e4: e300318a     	movw	r3, #0x18a
   a46e8: e5992018     	ldr	r2, [r9, #0x18]
   a46ec: e599101c     	ldr	r1, [r9, #0x1c]
   a46f0: e58d1018     	str	r1, [sp, #0x18]
   a46f4: e58d201c     	str	r2, [sp, #0x1c]
   a46f8: ed8d0b04     	vstr	d0, [sp, #16]
   a46fc: e58d6000     	str	r6, [sp]
   a4700: e5990008     	ldr	r0, [r9, #0x8]
   a4704: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0xa56f0 <.text+0x955f0>
   a4708: e58d0008     	str	r0, [sp, #0x8]
   a470c: e08f1001     	add	r1, pc, r1
   a4710: e58d1004     	str	r1, [sp, #0x4]
   a4714: e59f5fd8     	ldr	r5, [pc, #0xfd8]        @ 0xa56f4 <.text+0x955f4>
   a4718: e59f7fd8     	ldr	r7, [pc, #0xfd8]        @ 0xa56f8 <.text+0x955f8>
   a471c: e59f6fd8     	ldr	r6, [pc, #0xfd8]        @ 0xa56fc <.text+0x955fc>
   a4720: e08f5005     	add	r5, pc, r5
   a4724: e08f7007     	add	r7, pc, r7
   a4728: e08f6006     	add	r6, pc, r6
   a472c: e1a00005     	mov	r0, r5
   a4730: e1a01007     	mov	r1, r7
   a4734: e1a02006     	mov	r2, r6
   a4738: eb015661     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55984
   a473c: ed990b0a     	vldr	d0, [r9, #40]
   a4740: e300318d     	movw	r3, #0x18d
   a4744: e5992030     	ldr	r2, [r9, #0x30]
   a4748: e5991034     	ldr	r1, [r9, #0x34]
   a474c: e5990020     	ldr	r0, [r9, #0x20]
   a4750: e3a09003     	mov	r9, #3
   a4754: e58d201c     	str	r2, [sp, #0x1c]
   a4758: e1a02006     	mov	r2, r6
   a475c: e58d1018     	str	r1, [sp, #0x18]
   a4760: ed8d0b04     	vstr	d0, [sp, #16]
   a4764: e58d9000     	str	r9, [sp]
   a4768: e59f1f90     	ldr	r1, [pc, #0xf90]        @ 0xa5700 <.text+0x95600>
   a476c: e58d0008     	str	r0, [sp, #0x8]
   a4770: e1a00005     	mov	r0, r5
   a4774: e08f1001     	add	r1, pc, r1
   a4778: e58d1004     	str	r1, [sp, #0x4]
   a477c: e1a01007     	mov	r1, r7
   a4780: eb01564f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5593c
   a4784: ed9d0b12     	vldr	d0, [sp, #72]
   a4788: e3a03e19     	mov	r3, #400
   a478c: e59d1054     	ldr	r1, [sp, #0x54]
   a4790: e59d2050     	ldr	r2, [sp, #0x50]
   a4794: e58d201c     	str	r2, [sp, #0x1c]
   a4798: e1a02006     	mov	r2, r6
   a479c: e58d1018     	str	r1, [sp, #0x18]
   a47a0: ed8d0b04     	vstr	d0, [sp, #16]
   a47a4: e58d9000     	str	r9, [sp]
   a47a8: e59d0040     	ldr	r0, [sp, #0x40]
   a47ac: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0xa5798 <.text+0x95698>
   a47b0: e58d0008     	str	r0, [sp, #0x8]
   a47b4: e1a00005     	mov	r0, r5
   a47b8: e08f1001     	add	r1, pc, r1
   a47bc: e58d1004     	str	r1, [sp, #0x4]
   a47c0: e59f6fd4     	ldr	r6, [pc, #0xfd4]        @ 0xa579c <.text+0x9569c>
   a47c4: e1a01007     	mov	r1, r7
   a47c8: e08f6006     	add	r6, pc, r6
   a47cc: eb01563c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x558f0
   a47d0: e59a0000     	ldr	r0, [r10]
   a47d4: e2401001     	sub	r1, r0, #1
   a47d8: e0000190     	mul	r0, r0, r1
   a47dc: e3100001     	tst	r0, #1
   a47e0: 0a000537     	beq	0xa5cc4 <.text+0x95bc4> @ imm = #0x14dc
   a47e4: e5940000     	ldr	r0, [r4]
   a47e8: e350000a     	cmp	r0, #10
   a47ec: ba000534     	blt	0xa5cc4 <.text+0x95bc4> @ imm = #0x14d0
   a47f0: e59d1030     	ldr	r1, [sp, #0x30]
   a47f4: e2860008     	add	r0, r6, #8
   a47f8: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a47fc: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a4800: e59f4f98     	ldr	r4, [pc, #0xf98]        @ 0xa57a0 <.text+0x956a0>
   a4804: e79f4004     	ldr	r4, [pc, r4]
   a4808: e59f6f94     	ldr	r6, [pc, #0xf94]        @ 0xa57a4 <.text+0x956a4>
   a480c: e59d5038     	ldr	r5, [sp, #0x38]
   a4810: e08f6006     	add	r6, pc, r6
   a4814: e1a00005     	mov	r0, r5
   a4818: e1a09006     	mov	r9, r6
   a481c: eb140639     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5018e4
   a4820: e3a00003     	mov	r0, #3
   a4824: e5860000     	str	r0, [r6]
   a4828: e1a00005     	mov	r0, r5
   a482c: e3a06003     	mov	r6, #3
   a4830: eb1407a3     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x501e8c
   a4834: ed990b04     	vldr	d0, [r9, #16]
   a4838: e300318a     	movw	r3, #0x18a
   a483c: e5992018     	ldr	r2, [r9, #0x18]
   a4840: e599101c     	ldr	r1, [r9, #0x1c]
   a4844: e58d1018     	str	r1, [sp, #0x18]
   a4848: e58d201c     	str	r2, [sp, #0x1c]
   a484c: ed8d0b04     	vstr	d0, [sp, #16]
   a4850: e58d6000     	str	r6, [sp]
   a4854: e5990008     	ldr	r0, [r9, #0x8]
   a4858: e59f1f48     	ldr	r1, [pc, #0xf48]        @ 0xa57a8 <.text+0x956a8>
   a485c: e58d0008     	str	r0, [sp, #0x8]
   a4860: e08f1001     	add	r1, pc, r1
   a4864: e58d1004     	str	r1, [sp, #0x4]
   a4868: e59f5f3c     	ldr	r5, [pc, #0xf3c]        @ 0xa57ac <.text+0x956ac>
   a486c: e08f5005     	add	r5, pc, r5
   a4870: e1a00005     	mov	r0, r5
   a4874: e59f5f34     	ldr	r5, [pc, #0xf34]        @ 0xa57b0 <.text+0x956b0>
   a4878: e59f7f34     	ldr	r7, [pc, #0xf34]        @ 0xa57b4 <.text+0x956b4>
   a487c: e08f5005     	add	r5, pc, r5
   a4880: e08f7007     	add	r7, pc, r7
   a4884: e1a01005     	mov	r1, r5
   a4888: e1a02007     	mov	r2, r7
   a488c: eb01560c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55830
   a4890: ed990b0a     	vldr	d0, [r9, #40]
   a4894: e3a06003     	mov	r6, #3
   a4898: e5992030     	ldr	r2, [r9, #0x30]
   a489c: e300318d     	movw	r3, #0x18d
   a48a0: e5991034     	ldr	r1, [r9, #0x34]
   a48a4: e58d201c     	str	r2, [sp, #0x1c]
   a48a8: e1a02007     	mov	r2, r7
   a48ac: e58d1018     	str	r1, [sp, #0x18]
   a48b0: ed8d0b04     	vstr	d0, [sp, #16]
   a48b4: e58d6000     	str	r6, [sp]
   a48b8: e5990020     	ldr	r0, [r9, #0x20]
   a48bc: e59f1ef4     	ldr	r1, [pc, #0xef4]        @ 0xa57b8 <.text+0x956b8>
   a48c0: e58d0008     	str	r0, [sp, #0x8]
   a48c4: e08f1001     	add	r1, pc, r1
   a48c8: e58d1004     	str	r1, [sp, #0x4]
   a48cc: e59f0ee8     	ldr	r0, [pc, #0xee8]        @ 0xa57bc <.text+0x956bc>
   a48d0: e1a01005     	mov	r1, r5
   a48d4: e08f0000     	add	r0, pc, r0
   a48d8: eb0155f9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x557e4
   a48dc: ed9d0b12     	vldr	d0, [sp, #72]
   a48e0: e3a03e19     	mov	r3, #400
   a48e4: e59d1054     	ldr	r1, [sp, #0x54]
   a48e8: e59d2050     	ldr	r2, [sp, #0x50]
   a48ec: e58d201c     	str	r2, [sp, #0x1c]
   a48f0: e1a02007     	mov	r2, r7
   a48f4: e58d6000     	str	r6, [sp]
   a48f8: e1a06009     	mov	r6, r9
   a48fc: e58d1018     	str	r1, [sp, #0x18]
   a4900: ed8d0b04     	vstr	d0, [sp, #16]
   a4904: e59d0040     	ldr	r0, [sp, #0x40]
   a4908: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0xa5900 <.text+0x95800>
   a490c: e58d0008     	str	r0, [sp, #0x8]
   a4910: e08f1001     	add	r1, pc, r1
   a4914: e58d1004     	str	r1, [sp, #0x4]
   a4918: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0xa5904 <.text+0x95804>
   a491c: e1a01005     	mov	r1, r5
   a4920: e08f0000     	add	r0, pc, r0
   a4924: eb0155e6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55798
   a4928: eaffff5e     	b	0xa46a8 <.text+0x945a8> @ imm = #-0x288
   a492c: e1a00008     	mov	r0, r8
   a4930: eb000824     	bl	0xa69c8 <.text+0x968c8> @ imm = #0x2090
   a4934: e59a1000     	ldr	r1, [r10]
   a4938: e2412001     	sub	r2, r1, #1
   a493c: e0010291     	mul	r1, r1, r2
   a4940: e3110001     	tst	r1, #1
   a4944: 0a00000b     	beq	0xa4978 <.text+0x94878> @ imm = #0x2c
   a4948: e5941000     	ldr	r1, [r4]
   a494c: e3510009     	cmp	r1, #9
   a4950: da000008     	ble	0xa4978 <.text+0x94878> @ imm = #0x20
   a4954: e1a00008     	mov	r0, r8
   a4958: eb00081a     	bl	0xa69c8 <.text+0x968c8> @ imm = #0x2068
   a495c: eafffff2     	b	0xa492c <.text+0x9482c> @ imm = #-0x38
   a4960: 005444fa     	ldrsheq	r4, [r4], #-74
   a4964: 0054448c     	subseq	r4, r4, r12, lsl #9
   a4968: 0054435f     	subseq	r4, r4, pc, asr r3
   a496c: 005442fc     	ldrsheq	r4, [r4], #-44
   a4970: 00544330     	subseq	r4, r4, r0, lsr r3
   a4974: 0054443b     	subseq	r4, r4, r11, lsr r4
   a4978: e3500000     	cmp	r0, #0
   a497c: 0a00002b     	beq	0xa4a30 <.text+0x94930> @ imm = #0xac
   a4980: eeb0bb4f     	vmov.f64	d11, d15
   a4984: eeb0fb49     	vmov.f64	d15, d9
   a4988: eeb09b4a     	vmov.f64	d9, d10
   a498c: eeb0ab48     	vmov.f64	d10, d8
   a4990: ed9d8b12     	vldr	d8, [sp, #72]
   a4994: eeb48bcc     	vcmpe.f64	d8, d12
   a4998: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a499c: aa000033     	bge	0xa4a70 <.text+0x94970> @ imm = #0xcc
   a49a0: ed960b04     	vldr	d0, [r6, #16]
   a49a4: ee380b40     	vsub.f64	d0, d8, d0
   a49a8: eeb40bcd     	vcmpe.f64	d0, d13
   a49ac: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a49b0: da000075     	ble	0xa4b8c <.text+0x94a8c> @ imm = #0x1d4
   a49b4: e59d0040     	ldr	r0, [sp, #0x40]
   a49b8: e5961008     	ldr	r1, [r6, #0x8]
   a49bc: e1500001     	cmp	r0, r1
   a49c0: ca000071     	bgt	0xa4b8c <.text+0x94a8c> @ imm = #0x1c4
   a49c4: e59a0000     	ldr	r0, [r10]
   a49c8: e2401001     	sub	r1, r0, #1
   a49cc: e0000190     	mul	r0, r0, r1
   a49d0: e3100001     	tst	r0, #1
   a49d4: e59a0000     	ldr	r0, [r10]
   a49d8: e2401001     	sub	r1, r0, #1
   a49dc: e0020190     	mul	r2, r0, r1
   a49e0: e59d0050     	ldr	r0, [sp, #0x50]
   a49e4: e5961018     	ldr	r1, [r6, #0x18]
   a49e8: e3120001     	tst	r2, #1
   a49ec: 0a000002     	beq	0xa49fc <.text+0x948fc> @ imm = #0x8
   a49f0: e5942000     	ldr	r2, [r4]
   a49f4: e3520009     	cmp	r2, #9
   a49f8: cafffff5     	bgt	0xa49d4 <.text+0x948d4> @ imm = #-0x2c
   a49fc: e1500001     	cmp	r0, r1
   a4a00: aa000061     	bge	0xa4b8c <.text+0x94a8c> @ imm = #0x184
   a4a04: e28d1040     	add	r1, sp, #64
   a4a08: e2860008     	add	r0, r6, #8
   a4a0c: e3a09001     	mov	r9, #1
   a4a10: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a4a14: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a4a18: e59d5034     	ldr	r5, [sp, #0x34]
   a4a1c: e59f4eec     	ldr	r4, [pc, #0xeec]        @ 0xa5910 <.text+0x95810>
   a4a20: e79f4004     	ldr	r4, [pc, r4]
   a4a24: e59f6ee8     	ldr	r6, [pc, #0xee8]        @ 0xa5914 <.text+0x95814>
   a4a28: e08f6006     	add	r6, pc, r6
   a4a2c: ea00004f     	b	0xa4b70 <.text+0x94a70> @ imm = #0x13c
   a4a30: e59a0000     	ldr	r0, [r10]
   a4a34: e2401001     	sub	r1, r0, #1
   a4a38: e0000190     	mul	r0, r0, r1
   a4a3c: e3100001     	tst	r0, #1
   a4a40: 0a00020d     	beq	0xa527c <.text+0x9517c> @ imm = #0x834
   a4a44: e5940000     	ldr	r0, [r4]
   a4a48: e3500009     	cmp	r0, #9
   a4a4c: ca000252     	bgt	0xa539c <.text+0x9529c> @ imm = #0x948
   a4a50: ea000209     	b	0xa527c <.text+0x9517c> @ imm = #0x824
   a4a54: 0054440a     	subseq	r4, r4, r10, lsl #8
   a4a58: 0056efa0     	subseq	lr, r6, r0, lsr #31
   a4a5c: 0054435c     	subseq	r4, r4, r12, asr r3
   a4a60: 0054422f     	subseq	r4, r4, pc, lsr #4
   a4a64: 005441cc     	subseq	r4, r4, r12, asr #3
   a4a68: 00544200     	subseq	r4, r4, r0, lsl #4
   a4a6c: 0054430b     	subseq	r4, r4, r11, lsl #6
   a4a70: ed960b04     	vldr	d0, [r6, #16]
   a4a74: e1a05006     	mov	r5, r6
   a4a78: e596101c     	ldr	r1, [r6, #0x1c]
   a4a7c: e300318a     	movw	r3, #0x18a
   a4a80: e5962018     	ldr	r2, [r6, #0x18]
   a4a84: e58d1018     	str	r1, [sp, #0x18]
   a4a88: e3a01003     	mov	r1, #3
   a4a8c: e58d201c     	str	r2, [sp, #0x1c]
   a4a90: ed8d0b04     	vstr	d0, [sp, #16]
   a4a94: e58d1000     	str	r1, [sp]
   a4a98: e5960008     	ldr	r0, [r6, #0x8]
   a4a9c: e59f1fa4     	ldr	r1, [pc, #0xfa4]        @ 0xa5a48 <.text+0x95948>
   a4aa0: e58d0008     	str	r0, [sp, #0x8]
   a4aa4: e08f1001     	add	r1, pc, r1
   a4aa8: e58d1004     	str	r1, [sp, #0x4]
   a4aac: e59f9f98     	ldr	r9, [pc, #0xf98]        @ 0xa5a4c <.text+0x9594c>
   a4ab0: e59f7f98     	ldr	r7, [pc, #0xf98]        @ 0xa5a50 <.text+0x95950>
   a4ab4: e59f6f98     	ldr	r6, [pc, #0xf98]        @ 0xa5a54 <.text+0x95954>
   a4ab8: e08f9009     	add	r9, pc, r9
   a4abc: e08f7007     	add	r7, pc, r7
   a4ac0: e08f6006     	add	r6, pc, r6
   a4ac4: e1a00009     	mov	r0, r9
   a4ac8: e1a01007     	mov	r1, r7
   a4acc: e1a02006     	mov	r2, r6
   a4ad0: eb01557b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x555ec
   a4ad4: ed950b0a     	vldr	d0, [r5, #40]
   a4ad8: e300318d     	movw	r3, #0x18d
   a4adc: e5951034     	ldr	r1, [r5, #0x34]
   a4ae0: e5952030     	ldr	r2, [r5, #0x30]
   a4ae4: e58d1018     	str	r1, [sp, #0x18]
   a4ae8: e3a01003     	mov	r1, #3
   a4aec: e58d201c     	str	r2, [sp, #0x1c]
   a4af0: e1a02006     	mov	r2, r6
   a4af4: ed8d0b04     	vstr	d0, [sp, #16]
   a4af8: e58d1000     	str	r1, [sp]
   a4afc: e5950020     	ldr	r0, [r5, #0x20]
   a4b00: e59f1f50     	ldr	r1, [pc, #0xf50]        @ 0xa5a58 <.text+0x95958>
   a4b04: e58d0008     	str	r0, [sp, #0x8]
   a4b08: e1a00009     	mov	r0, r9
   a4b0c: e08f1001     	add	r1, pc, r1
   a4b10: e58d1004     	str	r1, [sp, #0x4]
   a4b14: e1a01007     	mov	r1, r7
   a4b18: eb015569     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x555a4
   a4b1c: ed9d0b12     	vldr	d0, [sp, #72]
   a4b20: e3a03e19     	mov	r3, #400
   a4b24: e59d1054     	ldr	r1, [sp, #0x54]
   a4b28: e59d2050     	ldr	r2, [sp, #0x50]
   a4b2c: e58d1018     	str	r1, [sp, #0x18]
   a4b30: e3a01003     	mov	r1, #3
   a4b34: e58d201c     	str	r2, [sp, #0x1c]
   a4b38: e1a02006     	mov	r2, r6
   a4b3c: ed8d0b04     	vstr	d0, [sp, #16]
   a4b40: e1a06005     	mov	r6, r5
   a4b44: e58d1000     	str	r1, [sp]
   a4b48: e59d0040     	ldr	r0, [sp, #0x40]
   a4b4c: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0xa5b24 <.text+0x95a24>
   a4b50: e58d0008     	str	r0, [sp, #0x8]
   a4b54: e1a00009     	mov	r0, r9
   a4b58: e08f1001     	add	r1, pc, r1
   a4b5c: e58d1004     	str	r1, [sp, #0x4]
   a4b60: e1a01007     	mov	r1, r7
   a4b64: e3a09001     	mov	r9, #1
   a4b68: e59d5034     	ldr	r5, [sp, #0x34]
   a4b6c: eb015554     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55550
   a4b70: eeb08b4a     	vmov.f64	d8, d10
   a4b74: eeb0ab49     	vmov.f64	d10, d9
   a4b78: eeb09b4f     	vmov.f64	d9, d15
   a4b7c: eeb0fb4b     	vmov.f64	d15, d11
   a4b80: ed9fbbda     	vldr	d11, [pc, #872]         @ 0xa4ef0 <.text+0x94df0>
   a4b84: eafff5e0     	b	0xa230c <.text+0x9220c> @ imm = #-0x2880
   a4b88: 005442da     	ldrsbeq	r4, [r4], #-42
   a4b8c: e59a0000     	ldr	r0, [r10]
   a4b90: e2401001     	sub	r1, r0, #1
   a4b94: e0000190     	mul	r0, r0, r1
   a4b98: e3100001     	tst	r0, #1
   a4b9c: 0a00023e     	beq	0xa549c <.text+0x9539c> @ imm = #0x8f8
   a4ba0: e5940000     	ldr	r0, [r4]
   a4ba4: e3500009     	cmp	r0, #9
   a4ba8: ca000249     	bgt	0xa54d4 <.text+0x953d4> @ imm = #0x924
   a4bac: ea00023a     	b	0xa549c <.text+0x9539c> @ imm = #0x8e8
   a4bb0: 00544218     	subseq	r4, r4, r8, lsl r2
   a4bb4: 005440f3     	ldrsheq	r4, [r4], #-3
   a4bb8: 00544084     	subseq	r4, r4, r4, lsl #1
   a4bbc: 005440b8     	ldrheq	r4, [r4], #-8
   a4bc0: e3a00003     	mov	r0, #3
   a4bc4: e3a03fbb     	mov	r3, #748
   a4bc8: e58d0000     	str	r0, [sp]
   a4bcc: e59f0f54     	ldr	r0, [pc, #0xf54]        @ 0xa5b28 <.text+0x95a28>
   a4bd0: e08f0000     	add	r0, pc, r0
   a4bd4: e58d0004     	str	r0, [sp, #0x4]
   a4bd8: e59f0f4c     	ldr	r0, [pc, #0xf4c]        @ 0xa5b2c <.text+0x95a2c>
   a4bdc: e59f1f4c     	ldr	r1, [pc, #0xf4c]        @ 0xa5b30 <.text+0x95a30>
   a4be0: e59f2f4c     	ldr	r2, [pc, #0xf4c]        @ 0xa5b34 <.text+0x95a34>
   a4be4: e08f0000     	add	r0, pc, r0
   a4be8: e08f1001     	add	r1, pc, r1
   a4bec: e08f2002     	add	r2, pc, r2
   a4bf0: eb015533     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x554cc
   a4bf4: e59a0000     	ldr	r0, [r10]
   a4bf8: e2401001     	sub	r1, r0, #1
   a4bfc: e0000190     	mul	r0, r0, r1
   a4c00: e3100001     	tst	r0, #1
   a4c04: 0a000012     	beq	0xa4c54 <.text+0x94b54> @ imm = #0x48
   a4c08: e5940000     	ldr	r0, [r4]
   a4c0c: e3500009     	cmp	r0, #9
   a4c10: da00000f     	ble	0xa4c54 <.text+0x94b54> @ imm = #0x3c
   a4c14: e3a00003     	mov	r0, #3
   a4c18: e3a03fbb     	mov	r3, #748
   a4c1c: e58d0000     	str	r0, [sp]
   a4c20: e59f0f10     	ldr	r0, [pc, #0xf10]        @ 0xa5b38 <.text+0x95a38>
   a4c24: e08f0000     	add	r0, pc, r0
   a4c28: e58d0004     	str	r0, [sp, #0x4]
   a4c2c: e59f0f08     	ldr	r0, [pc, #0xf08]        @ 0xa5b3c <.text+0x95a3c>
   a4c30: e59f1f08     	ldr	r1, [pc, #0xf08]        @ 0xa5b40 <.text+0x95a40>
   a4c34: e59f2f08     	ldr	r2, [pc, #0xf08]        @ 0xa5b44 <.text+0x95a44>
   a4c38: e08f0000     	add	r0, pc, r0
   a4c3c: e08f1001     	add	r1, pc, r1
   a4c40: e08f2002     	add	r2, pc, r2
   a4c44: eb01551e     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55478
   a4c48: eaffffdc     	b	0xa4bc0 <.text+0x94ac0> @ imm = #-0x90
   a4c4c: 005441cb     	subseq	r4, r4, r11, asr #3
   a4c50: 0054408b     	subseq	r4, r4, r11, lsl #1
   a4c54: e59d9030     	ldr	r9, [sp, #0x30]
   a4c58: e59a0000     	ldr	r0, [r10]
   a4c5c: e2401001     	sub	r1, r0, #1
   a4c60: e0000190     	mul	r0, r0, r1
   a4c64: e3100001     	tst	r0, #1
   a4c68: 0a000002     	beq	0xa4c78 <.text+0x94b78> @ imm = #0x8
   a4c6c: e5940000     	ldr	r0, [r4]
   a4c70: e3500009     	cmp	r0, #9
   a4c74: ca00000e     	bgt	0xa4cb4 <.text+0x94bb4> @ imm = #0x38
   a4c78: e598001c     	ldr	r0, [r8, #0x1c]
   a4c7c: e59840dc     	ldr	r4, [r8, #0xdc]
   a4c80: e598720c     	ldr	r7, [r8, #0x20c]
   a4c84: ebfef031     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x43f3c
   a4c88: e59a1000     	ldr	r1, [r10]
   a4c8c: e59f3eb4     	ldr	r3, [pc, #0xeb4]        @ 0xa5b48 <.text+0x95a48>
   a4c90: e2412001     	sub	r2, r1, #1
   a4c94: e0020291     	mul	r2, r1, r2
   a4c98: e79f3003     	ldr	r3, [pc, r3]
   a4c9c: e2441f7d     	sub	r1, r4, #500
   a4ca0: e3120001     	tst	r2, #1
   a4ca4: 0a000006     	beq	0xa4cc4 <.text+0x94bc4> @ imm = #0x18
   a4ca8: e5932000     	ldr	r2, [r3]
   a4cac: e3520009     	cmp	r2, #9
   a4cb0: da000003     	ble	0xa4cc4 <.text+0x94bc4> @ imm = #0xc
   a4cb4: e598001c     	ldr	r0, [r8, #0x1c]
   a4cb8: ebfef024     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x43f70
   a4cbc: eaffffed     	b	0xa4c78 <.text+0x94b78> @ imm = #-0x4c
   a4cc0: 00544196     	<unknown>
   a4cc4: e247c032     	sub	r12, r7, #50
   a4cc8: e1510000     	cmp	r1, r0
   a4ccc: da00000e     	ble	0xa4d0c <.text+0x94c0c> @ imm = #0x38
   a4cd0: e59800dc     	ldr	r0, [r8, #0xdc]
   a4cd4: e2400f7d     	sub	r0, r0, #500
   a4cd8: e150000c     	cmp	r0, r12
   a4cdc: da000010     	ble	0xa4d24 <.text+0x94c24> @ imm = #0x40
   a4ce0: ea000084     	b	0xa4ef8 <.text+0x94df8> @ imm = #0x210
   a4ce4: 0054403f     	subseq	r4, r4, pc, lsr r0
   a4ce8: 005440e4     	subseq	r4, r4, r4, ror #1
   a4cec: 00543fbf     	ldrheq	r3, [r4], #-255
   a4cf0: 00543f50     	subseq	r3, r4, r0, asr pc
   a4cf4: 00543f84     	subseq	r3, r4, r4, lsl #31
   a4cf8: 00544097     	<unknown>
   a4cfc: 00543f57     	subseq	r3, r4, r7, asr pc
   a4d00: 00544062     	subseq	r4, r4, r2, rrx
   a4d04: 00543f0b     	subseq	r3, r4, r11, lsl #30
   a4d08: 00543fa4     	subseq	r3, r4, r4, lsr #31
   a4d0c: e598001c     	ldr	r0, [r8, #0x1c]
   a4d10: e1a0400c     	mov	r4, r12
   a4d14: ebfef00d     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x43fcc
   a4d18: e1a0c004     	mov	r12, r4
   a4d1c: e150000c     	cmp	r0, r12
   a4d20: ca000074     	bgt	0xa4ef8 <.text+0x94df8> @ imm = #0x1d0
   a4d24: e28d1040     	add	r1, sp, #64
   a4d28: e1a00009     	mov	r0, r9
   a4d2c: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a4d30: e1a0100c     	mov	r1, r12
   a4d34: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a4d38: e1a00008     	mov	r0, r8
   a4d3c: e59f6fac     	ldr	r6, [pc, #0xfac]        @ 0xa5cf0 <.text+0x95bf0>
   a4d40: e08f6006     	add	r6, pc, r6
   a4d44: eb00066e     	bl	0xa6704 <.text+0x96604> @ imm = #0x19b8
   a4d48: e59f4ff4     	ldr	r4, [pc, #0xff4]        @ 0xa5d44 <.text+0x95c44>
   a4d4c: e3e07003     	mvn	r7, #3
   a4d50: e79f4004     	ldr	r4, [pc, r4]
   a4d54: e2977001     	adds	r7, r7, #1
   a4d58: 2a000056     	bhs	0xa4eb8 <.text+0x94db8> @ imm = #0x158
   a4d5c: e28d1040     	add	r1, sp, #64
   a4d60: e1a00008     	mov	r0, r8
   a4d64: e3a0203c     	mov	r2, #60
   a4d68: eb000508     	bl	0xa6190 <.text+0x96090> @ imm = #0x1420
   a4d6c: ed960b04     	vldr	d0, [r6, #16]
   a4d70: e300318a     	movw	r3, #0x18a
   a4d74: e596101c     	ldr	r1, [r6, #0x1c]
   a4d78: e5962018     	ldr	r2, [r6, #0x18]
   a4d7c: e58d1018     	str	r1, [sp, #0x18]
   a4d80: e3a01003     	mov	r1, #3
   a4d84: e58d201c     	str	r2, [sp, #0x1c]
   a4d88: ed8d0b04     	vstr	d0, [sp, #16]
   a4d8c: e58d1000     	str	r1, [sp]
   a4d90: e5960008     	ldr	r0, [r6, #0x8]
   a4d94: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0xa5d7c <.text+0x95c7c>
   a4d98: e58d0008     	str	r0, [sp, #0x8]
   a4d9c: e08f1001     	add	r1, pc, r1
   a4da0: e58d1004     	str	r1, [sp, #0x4]
   a4da4: e59f5fd4     	ldr	r5, [pc, #0xfd4]        @ 0xa5d80 <.text+0x95c80>
   a4da8: e59f1fd4     	ldr	r1, [pc, #0xfd4]        @ 0xa5d84 <.text+0x95c84>
   a4dac: e08f5005     	add	r5, pc, r5
   a4db0: e08f1001     	add	r1, pc, r1
   a4db4: e1a00005     	mov	r0, r5
   a4db8: e1a05006     	mov	r5, r6
   a4dbc: e59f6fc4     	ldr	r6, [pc, #0xfc4]        @ 0xa5d88 <.text+0x95c88>
   a4dc0: e1a09001     	mov	r9, r1
   a4dc4: e08f6006     	add	r6, pc, r6
   a4dc8: e1a02006     	mov	r2, r6
   a4dcc: eb0154bc     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x552f0
   a4dd0: ed950b0a     	vldr	d0, [r5, #40]
   a4dd4: e300318d     	movw	r3, #0x18d
   a4dd8: e5951034     	ldr	r1, [r5, #0x34]
   a4ddc: e5952030     	ldr	r2, [r5, #0x30]
   a4de0: e58d1018     	str	r1, [sp, #0x18]
   a4de4: e3a01003     	mov	r1, #3
   a4de8: e58d201c     	str	r2, [sp, #0x1c]
   a4dec: e1a02006     	mov	r2, r6
   a4df0: ed8d0b04     	vstr	d0, [sp, #16]
   a4df4: e58d1000     	str	r1, [sp]
   a4df8: e5950020     	ldr	r0, [r5, #0x20]
   a4dfc: e59f1f88     	ldr	r1, [pc, #0xf88]        @ 0xa5d8c <.text+0x95c8c>
   a4e00: e58d0008     	str	r0, [sp, #0x8]
   a4e04: e08f1001     	add	r1, pc, r1
   a4e08: e58d1004     	str	r1, [sp, #0x4]
   a4e0c: e59f0f7c     	ldr	r0, [pc, #0xf7c]        @ 0xa5d90 <.text+0x95c90>
   a4e10: e1a01009     	mov	r1, r9
   a4e14: e08f0000     	add	r0, pc, r0
   a4e18: eb0154a9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x552a4
   a4e1c: ed9d0b12     	vldr	d0, [sp, #72]
   a4e20: e3a03e19     	mov	r3, #400
   a4e24: e59d1054     	ldr	r1, [sp, #0x54]
   a4e28: e59d2050     	ldr	r2, [sp, #0x50]
   a4e2c: e58d1018     	str	r1, [sp, #0x18]
   a4e30: e3a01003     	mov	r1, #3
   a4e34: e58d201c     	str	r2, [sp, #0x1c]
   a4e38: e1a02006     	mov	r2, r6
   a4e3c: ed8d0b04     	vstr	d0, [sp, #16]
   a4e40: e1a06005     	mov	r6, r5
   a4e44: e58d1000     	str	r1, [sp]
   a4e48: e59d0040     	ldr	r0, [sp, #0x40]
   a4e4c: e59f1fd4     	ldr	r1, [pc, #0xfd4]        @ 0xa5e28 <.text+0x95d28>
   a4e50: e58d0008     	str	r0, [sp, #0x8]
   a4e54: e08f1001     	add	r1, pc, r1
   a4e58: e58d1004     	str	r1, [sp, #0x4]
   a4e5c: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0xa5e2c <.text+0x95d2c>
   a4e60: e59d9030     	ldr	r9, [sp, #0x30]
   a4e64: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0xa5e30 <.text+0x95d30>
   a4e68: e08f0000     	add	r0, pc, r0
   a4e6c: e08f1001     	add	r1, pc, r1
   a4e70: eb015493     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5524c
   a4e74: ed9d0b12     	vldr	d0, [sp, #72]
   a4e78: eeb40bc9     	vcmpe.f64	d0, d9
   a4e7c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a4e80: dd961b04     	vldrle	d1, [r6, #16]
   a4e84: de300b41     	vsuble.f64	d0, d0, d1
   a4e88: deb40bca     	vcmpele.f64	d0, d10
   a4e8c: def1fa10     	vmrsle	APSR_nzcv, fpscr
   a4e90: daffffaf     	ble	0xa4d54 <.text+0x94c54> @ imm = #-0x144
   a4e94: e59d0040     	ldr	r0, [sp, #0x40]
   a4e98: e5961008     	ldr	r1, [r6, #0x8]
   a4e9c: e1500001     	cmp	r0, r1
   a4ea0: aaffff6c     	bge	0xa4c58 <.text+0x94b58> @ imm = #-0x250
   a4ea4: ea000022     	b	0xa4f34 <.text+0x94e34> @ imm = #0x88
   a4ea8: 00543e7f     	subseq	r3, r4, pc, ror lr
   a4eac: 00543e10     	subseq	r3, r4, r0, lsl lr
   a4eb0: 00543e44     	subseq	r3, r4, r4, asr #28
   a4eb4: 0056eb6c     	subseq	lr, r6, r12, ror #22
   a4eb8: e59a0000     	ldr	r0, [r10]
   a4ebc: e2401001     	sub	r1, r0, #1
   a4ec0: e0000190     	mul	r0, r0, r1
   a4ec4: e3100001     	tst	r0, #1
   a4ec8: 0a0001ef     	beq	0xa568c <.text+0x9558c> @ imm = #0x7bc
   a4ecc: e5940000     	ldr	r0, [r4]
   a4ed0: e3500009     	cmp	r0, #9
   a4ed4: ca0001fd     	bgt	0xa56d0 <.text+0x955d0> @ imm = #0x7f4
   a4ed8: ea0001eb     	b	0xa568c <.text+0x9558c> @ imm = #0x7ac
   a4edc: 0056eb60     	subseq	lr, r6, r0, ror #22
   a4ee0: 0056eb50     	subseq	lr, r6, r0, asr r11
   a4ee4: 00543f3f     	subseq	r3, r4, pc, lsr pc
   a4ee8: 00543dff     	ldrsheq	r3, [r4], #-223
   a4eec: e320f000     	nop
   a4ef0: d2f1a9fc     	rscsle	r10, r1, #252, #18
   a4ef4: 3f50624d     	svclo	#0x50624d
   a4ef8: e59a0000     	ldr	r0, [r10]
   a4efc: e59f4fe4     	ldr	r4, [pc, #0xfe4]        @ 0xa5ee8 <.text+0x95de8>
   a4f00: e2401001     	sub	r1, r0, #1
   a4f04: e0000190     	mul	r0, r0, r1
   a4f08: e79f4004     	ldr	r4, [pc, r4]
   a4f0c: e3100001     	tst	r0, #1
   a4f10: e59a0000     	ldr	r0, [r10]
   a4f14: e2401001     	sub	r1, r0, #1
   a4f18: e0010190     	mul	r1, r0, r1
   a4f1c: e59d0040     	ldr	r0, [sp, #0x40]
   a4f20: e3110001     	tst	r1, #1
   a4f24: 0a000002     	beq	0xa4f34 <.text+0x94e34> @ imm = #0x8
   a4f28: e5941000     	ldr	r1, [r4]
   a4f2c: e351000a     	cmp	r1, #10
   a4f30: aafffff6     	bge	0xa4f10 <.text+0x94e10> @ imm = #-0x28
   a4f34: e59d3054     	ldr	r3, [sp, #0x54]
   a4f38: e59d2050     	ldr	r2, [sp, #0x50]
   a4f3c: e5860008     	str	r0, [r6, #0x8]
   a4f40: e1c621f8     	strd	r2, r3, [r6, #24]
   a4f44: ea000197     	b	0xa55a8 <.text+0x954a8> @ imm = #0x65c
   a4f48: 00543f0e     	subseq	r3, r4, lr, lsl #30
   a4f4c: 00543db3     	ldrheq	r3, [r4], #-211
   a4f50: 00543d4c     	subseq	r3, r4, r12, asr #26
   a4f54: 0056eac4     	subseq	lr, r6, r4, asr #21
   a4f58: 00543e5c     	subseq	r3, r4, r12, asr lr
   a4f5c: 00543d37     	subseq	r3, r4, r7, lsr sp
   a4f60: 00543cc8     	subseq	r3, r4, r8, asr #25
   a4f64: 00543cfc     	ldrsheq	r3, [r4], #-204
   a4f68: 0056ea24     	subseq	lr, r6, r4, lsr #20
   a4f6c: 0056ea18     	subseq	lr, r6, r8, lsl r10
   a4f70: 0056ea08     	subseq	lr, r6, r8, lsl #20
   a4f74: 00543df7     	ldrsheq	r3, [r4], #-215
   a4f78: 00543cb7     	ldrheq	r3, [r4], #-199
   a4f7c: 00543dc6     	subseq	r3, r4, r6, asr #27
   a4f80: 00543c6b     	subseq	r3, r4, r11, ror #24
   a4f84: 0056e984     	subseq	lr, r6, r4, lsl #19
   a4f88: 0056e918     	subseq	lr, r6, r8, lsl r9
   a4f8c: 00543cb8     	ldrheq	r3, [r4], #-200
   a4f90: 00543b93     	<unknown>
   a4f94: 00543b24     	subseq	r3, r4, r4, lsr #22
   a4f98: 00543b58     	subseq	r3, r4, r8, asr r11
   a4f9c: 00543c6b     	subseq	r3, r4, r11, ror #24
   a4fa0: 00543b2b     	subseq	r3, r4, r11, lsr #22
   a4fa4: e1a01005     	mov	r1, r5
   a4fa8: e2860008     	add	r0, r6, #8
   a4fac: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a4fb0: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a4fb4: e1a00008     	mov	r0, r8
   a4fb8: e59f4fa8     	ldr	r4, [pc, #0xfa8]        @ 0xa5f68 <.text+0x95e68>
   a4fbc: e79f4004     	ldr	r4, [pc, r4]
   a4fc0: e59f9fa4     	ldr	r9, [pc, #0xfa4]        @ 0xa5f6c <.text+0x95e6c>
   a4fc4: e08f9009     	add	r9, pc, r9
   a4fc8: e5991030     	ldr	r1, [r9, #0x30]
   a4fcc: eb0005cc     	bl	0xa6704 <.text+0x96604> @ imm = #0x1730
   a4fd0: e59d5038     	ldr	r5, [sp, #0x38]
   a4fd4: e1a00005     	mov	r0, r5
   a4fd8: eb14044a     	bl	0x5a6108 <.text+0x596008> @ imm = #0x501128
   a4fdc: e3a00003     	mov	r0, #3
   a4fe0: e3a06003     	mov	r6, #3
   a4fe4: e5890000     	str	r0, [r9]
   a4fe8: e1a00005     	mov	r0, r5
   a4fec: eb1405b4     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5016d0
   a4ff0: ed990b04     	vldr	d0, [r9, #16]
   a4ff4: e300318a     	movw	r3, #0x18a
   a4ff8: e5992018     	ldr	r2, [r9, #0x18]
   a4ffc: e599101c     	ldr	r1, [r9, #0x1c]
   a5000: e58d1018     	str	r1, [sp, #0x18]
   a5004: e58d201c     	str	r2, [sp, #0x1c]
   a5008: ed8d0b04     	vstr	d0, [sp, #16]
   a500c: e58d6000     	str	r6, [sp]
   a5010: e5990008     	ldr	r0, [r9, #0x8]
   a5014: e59f1f54     	ldr	r1, [pc, #0xf54]        @ 0xa5f70 <.text+0x95e70>
   a5018: e58d0008     	str	r0, [sp, #0x8]
   a501c: e08f1001     	add	r1, pc, r1
   a5020: e58d1004     	str	r1, [sp, #0x4]
   a5024: e59f5f48     	ldr	r5, [pc, #0xf48]        @ 0xa5f74 <.text+0x95e74>
   a5028: e59f7f48     	ldr	r7, [pc, #0xf48]        @ 0xa5f78 <.text+0x95e78>
   a502c: e59f6f48     	ldr	r6, [pc, #0xf48]        @ 0xa5f7c <.text+0x95e7c>
   a5030: e08f5005     	add	r5, pc, r5
   a5034: e08f7007     	add	r7, pc, r7
   a5038: e08f6006     	add	r6, pc, r6
   a503c: e1a00005     	mov	r0, r5
   a5040: e1a01007     	mov	r1, r7
   a5044: e1a02006     	mov	r2, r6
   a5048: eb01541d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x55074
   a504c: ed990b0a     	vldr	d0, [r9, #40]
   a5050: e300318d     	movw	r3, #0x18d
   a5054: e5992030     	ldr	r2, [r9, #0x30]
   a5058: e5991034     	ldr	r1, [r9, #0x34]
   a505c: e5990020     	ldr	r0, [r9, #0x20]
   a5060: e3a09003     	mov	r9, #3
   a5064: e58d201c     	str	r2, [sp, #0x1c]
   a5068: e1a02006     	mov	r2, r6
   a506c: e58d1018     	str	r1, [sp, #0x18]
   a5070: ed8d0b04     	vstr	d0, [sp, #16]
   a5074: e58d9000     	str	r9, [sp]
   a5078: e59f1f00     	ldr	r1, [pc, #0xf00]        @ 0xa5f80 <.text+0x95e80>
   a507c: e58d0008     	str	r0, [sp, #0x8]
   a5080: e1a00005     	mov	r0, r5
   a5084: e08f1001     	add	r1, pc, r1
   a5088: e58d1004     	str	r1, [sp, #0x4]
   a508c: e1a01007     	mov	r1, r7
   a5090: eb01540b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5502c
   a5094: ed9d0b12     	vldr	d0, [sp, #72]
   a5098: e3a03e19     	mov	r3, #400
   a509c: e59d1054     	ldr	r1, [sp, #0x54]
   a50a0: e59d2050     	ldr	r2, [sp, #0x50]
   a50a4: e58d201c     	str	r2, [sp, #0x1c]
   a50a8: e1a02006     	mov	r2, r6
   a50ac: e58d1018     	str	r1, [sp, #0x18]
   a50b0: ed8d0b04     	vstr	d0, [sp, #16]
   a50b4: e58d9000     	str	r9, [sp]
   a50b8: e59d0040     	ldr	r0, [sp, #0x40]
   a50bc: e59f1ec0     	ldr	r1, [pc, #0xec0]        @ 0xa5f84 <.text+0x95e84>
   a50c0: e58d0008     	str	r0, [sp, #0x8]
   a50c4: e1a00005     	mov	r0, r5
   a50c8: e08f1001     	add	r1, pc, r1
   a50cc: e58d1004     	str	r1, [sp, #0x4]
   a50d0: e59f6eb0     	ldr	r6, [pc, #0xeb0]        @ 0xa5f88 <.text+0x95e88>
   a50d4: e1a01007     	mov	r1, r7
   a50d8: e59d5030     	ldr	r5, [sp, #0x30]
   a50dc: e08f6006     	add	r6, pc, r6
   a50e0: eb0153f7     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54fdc
   a50e4: e59a0000     	ldr	r0, [r10]
   a50e8: e2401001     	sub	r1, r0, #1
   a50ec: e0000190     	mul	r0, r0, r1
   a50f0: e3100001     	tst	r0, #1
   a50f4: 0a0002f2     	beq	0xa5cc4 <.text+0x95bc4> @ imm = #0xbc8
   a50f8: e5940000     	ldr	r0, [r4]
   a50fc: e350000a     	cmp	r0, #10
   a5100: ba0002ef     	blt	0xa5cc4 <.text+0x95bc4> @ imm = #0xbbc
   a5104: e1a01005     	mov	r1, r5
   a5108: e2860008     	add	r0, r6, #8
   a510c: e89100fc     	ldm	r1, {r2, r3, r4, r5, r6, r7}
   a5110: e88000fc     	stm	r0, {r2, r3, r4, r5, r6, r7}
   a5114: e1a00008     	mov	r0, r8
   a5118: e59f7e6c     	ldr	r7, [pc, #0xe6c]        @ 0xa5f8c <.text+0x95e8c>
   a511c: e08f7007     	add	r7, pc, r7
   a5120: e5971030     	ldr	r1, [r7, #0x30]
   a5124: eb000576     	bl	0xa6704 <.text+0x96604> @ imm = #0x15d8
   a5128: e59d4038     	ldr	r4, [sp, #0x38]
   a512c: e1a00004     	mov	r0, r4
   a5130: eb1403f4     	bl	0x5a6108 <.text+0x596008> @ imm = #0x500fd0
   a5134: e3a09003     	mov	r9, #3
   a5138: e1a00004     	mov	r0, r4
   a513c: e5879000     	str	r9, [r7]
   a5140: eb14055f     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x50157c
   a5144: ed970b04     	vldr	d0, [r7, #16]
   a5148: e300318a     	movw	r3, #0x18a
   a514c: e5972018     	ldr	r2, [r7, #0x18]
   a5150: e597101c     	ldr	r1, [r7, #0x1c]
   a5154: e58d1018     	str	r1, [sp, #0x18]
   a5158: e58d201c     	str	r2, [sp, #0x1c]
   a515c: ed8d0b04     	vstr	d0, [sp, #16]
   a5160: e58d9000     	str	r9, [sp]
   a5164: e5970008     	ldr	r0, [r7, #0x8]
   a5168: e59f1e20     	ldr	r1, [pc, #0xe20]        @ 0xa5f90 <.text+0x95e90>
   a516c: e58d0008     	str	r0, [sp, #0x8]
   a5170: e08f1001     	add	r1, pc, r1
   a5174: e58d1004     	str	r1, [sp, #0x4]
   a5178: e59f4e14     	ldr	r4, [pc, #0xe14]        @ 0xa5f94 <.text+0x95e94>
   a517c: e59f5e14     	ldr	r5, [pc, #0xe14]        @ 0xa5f98 <.text+0x95e98>
   a5180: e59f6e14     	ldr	r6, [pc, #0xe14]        @ 0xa5f9c <.text+0x95e9c>
   a5184: e08f4004     	add	r4, pc, r4
   a5188: e08f5005     	add	r5, pc, r5
   a518c: e08f6006     	add	r6, pc, r6
   a5190: e1a00004     	mov	r0, r4
   a5194: e1a01005     	mov	r1, r5
   a5198: e1a02006     	mov	r2, r6
   a519c: eb0153c8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54f20
   a51a0: ed970b0a     	vldr	d0, [r7, #40]
   a51a4: e300318d     	movw	r3, #0x18d
   a51a8: e5972030     	ldr	r2, [r7, #0x30]
   a51ac: e5971034     	ldr	r1, [r7, #0x34]
   a51b0: e58d201c     	str	r2, [sp, #0x1c]
   a51b4: e1a02006     	mov	r2, r6
   a51b8: e58d1018     	str	r1, [sp, #0x18]
   a51bc: ed8d0b04     	vstr	d0, [sp, #16]
   a51c0: e58d9000     	str	r9, [sp]
   a51c4: e5970020     	ldr	r0, [r7, #0x20]
   a51c8: e59f1dd0     	ldr	r1, [pc, #0xdd0]        @ 0xa5fa0 <.text+0x95ea0>
   a51cc: e58d0008     	str	r0, [sp, #0x8]
   a51d0: e1a00004     	mov	r0, r4
   a51d4: e08f1001     	add	r1, pc, r1
   a51d8: e58d1004     	str	r1, [sp, #0x4]
   a51dc: e1a01005     	mov	r1, r5
   a51e0: eb0153b7     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54edc
   a51e4: ed9d0b12     	vldr	d0, [sp, #72]
   a51e8: e3a03e19     	mov	r3, #400
   a51ec: e59d1054     	ldr	r1, [sp, #0x54]
   a51f0: e59d2050     	ldr	r2, [sp, #0x50]
   a51f4: e58d201c     	str	r2, [sp, #0x1c]
   a51f8: e1a02006     	mov	r2, r6
   a51fc: e58d1018     	str	r1, [sp, #0x18]
   a5200: e1a06007     	mov	r6, r7
   a5204: ed8d0b04     	vstr	d0, [sp, #16]
   a5208: e58d9000     	str	r9, [sp]
   a520c: e59d0040     	ldr	r0, [sp, #0x40]
   a5210: e59d5030     	ldr	r5, [sp, #0x30]
   a5214: e59f1d88     	ldr	r1, [pc, #0xd88]        @ 0xa5fa4 <.text+0x95ea4>
   a5218: e58d0008     	str	r0, [sp, #0x8]
   a521c: e1a00004     	mov	r0, r4
   a5220: e08f1001     	add	r1, pc, r1
   a5224: e58d1004     	str	r1, [sp, #0x4]
   a5228: e59f1d78     	ldr	r1, [pc, #0xd78]        @ 0xa5fa8 <.text+0x95ea8>
   a522c: e08f1001     	add	r1, pc, r1
   a5230: eb0153a3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54e8c
   a5234: eaffff5a     	b	0xa4fa4 <.text+0x94ea4> @ imm = #-0x298
   a5238: 00543c36     	subseq	r3, r4, r6, lsr r12
   a523c: 00543adf     	ldrsbeq	r3, [r4], #-175
   a5240: 0053a5a4     	subseq	r10, r3, r4, lsr #11
   a5244: 0056e7b4     	ldrheq	lr, [r6], #-116
   a5248: 00543b54     	subseq	r3, r4, r4, asr r11
   a524c: 00543a2f     	subseq	r3, r4, pc, lsr #20
   a5250: 005439c0     	subseq	r3, r4, r0, asr #19
   a5254: 005439f4     	ldrsheq	r3, [r4], #-148
   a5258: 00543b07     	subseq	r3, r4, r7, lsl #22
   a525c: 005439c7     	subseq	r3, r4, r7, asr #19
   a5260: 00543ad2     	ldrsbeq	r3, [r4], #-162
   a5264: 0054397b     	subseq	r3, r4, r11, ror r9
   a5268: 0056e644     	subseq	lr, r6, r4, asr #12
   a526c: 005439e8     	subseq	r3, r4, r8, ror #19
   a5270: 005438bb     	ldrheq	r3, [r4], #-139
   a5274: 00543858     	subseq	r3, r4, r8, asr r8
   a5278: 0054388c     	subseq	r3, r4, r12, lsl #17
   a527c: ed960b04     	vldr	d0, [r6, #16]
   a5280: e1a05006     	mov	r5, r6
   a5284: e596101c     	ldr	r1, [r6, #0x1c]
   a5288: e300318a     	movw	r3, #0x18a
   a528c: e5962018     	ldr	r2, [r6, #0x18]
   a5290: e58d1018     	str	r1, [sp, #0x18]
   a5294: e3a01003     	mov	r1, #3
   a5298: e58d201c     	str	r2, [sp, #0x1c]
   a529c: ed8d0b04     	vstr	d0, [sp, #16]
   a52a0: e58d1000     	str	r1, [sp]
   a52a4: e5960008     	ldr	r0, [r6, #0x8]
   a52a8: e59f1d14     	ldr	r1, [pc, #0xd14]        @ 0xa5fc4 <.text+0x95ec4>
   a52ac: e58d0008     	str	r0, [sp, #0x8]
   a52b0: e08f1001     	add	r1, pc, r1
   a52b4: e58d1004     	str	r1, [sp, #0x4]
   a52b8: e59f9d08     	ldr	r9, [pc, #0xd08]        @ 0xa5fc8 <.text+0x95ec8>
   a52bc: e59f7d08     	ldr	r7, [pc, #0xd08]        @ 0xa5fcc <.text+0x95ecc>
   a52c0: e59f6d08     	ldr	r6, [pc, #0xd08]        @ 0xa5fd0 <.text+0x95ed0>
   a52c4: e08f9009     	add	r9, pc, r9
   a52c8: e08f7007     	add	r7, pc, r7
   a52cc: e08f6006     	add	r6, pc, r6
   a52d0: e1a00009     	mov	r0, r9
   a52d4: e1a01007     	mov	r1, r7
   a52d8: e1a02006     	mov	r2, r6
   a52dc: eb015378     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54de0
   a52e0: ed950b0a     	vldr	d0, [r5, #40]
   a52e4: e300318d     	movw	r3, #0x18d
   a52e8: e5951034     	ldr	r1, [r5, #0x34]
   a52ec: e5952030     	ldr	r2, [r5, #0x30]
   a52f0: e58d1018     	str	r1, [sp, #0x18]
   a52f4: e3a01003     	mov	r1, #3
   a52f8: e58d201c     	str	r2, [sp, #0x1c]
   a52fc: e1a02006     	mov	r2, r6
   a5300: ed8d0b04     	vstr	d0, [sp, #16]
   a5304: e58d1000     	str	r1, [sp]
   a5308: e5950020     	ldr	r0, [r5, #0x20]
   a530c: e59f1cc0     	ldr	r1, [pc, #0xcc0]        @ 0xa5fd4 <.text+0x95ed4>
   a5310: e58d0008     	str	r0, [sp, #0x8]
   a5314: e1a00009     	mov	r0, r9
   a5318: e08f1001     	add	r1, pc, r1
   a531c: e58d1004     	str	r1, [sp, #0x4]
   a5320: e1a01007     	mov	r1, r7
   a5324: eb015366     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54d98
   a5328: ed9d0b12     	vldr	d0, [sp, #72]
   a532c: e3a03e19     	mov	r3, #400
   a5330: e59d1054     	ldr	r1, [sp, #0x54]
   a5334: e59d2050     	ldr	r2, [sp, #0x50]
   a5338: e58d1018     	str	r1, [sp, #0x18]
   a533c: e3a01003     	mov	r1, #3
   a5340: e58d201c     	str	r2, [sp, #0x1c]
   a5344: e1a02006     	mov	r2, r6
   a5348: ed8d0b04     	vstr	d0, [sp, #16]
   a534c: e1a06005     	mov	r6, r5
   a5350: e58d1000     	str	r1, [sp]
   a5354: e59d0040     	ldr	r0, [sp, #0x40]
   a5358: e59f1c78     	ldr	r1, [pc, #0xc78]        @ 0xa5fd8 <.text+0x95ed8>
   a535c: e58d0008     	str	r0, [sp, #0x8]
   a5360: e1a00009     	mov	r0, r9
   a5364: e08f1001     	add	r1, pc, r1
   a5368: e58d1004     	str	r1, [sp, #0x4]
   a536c: e1a01007     	mov	r1, r7
   a5370: e3a09001     	mov	r9, #1
   a5374: e59d5034     	ldr	r5, [sp, #0x34]
   a5378: eb015351     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54d44
   a537c: e59a0000     	ldr	r0, [r10]
   a5380: e2401001     	sub	r1, r0, #1
   a5384: e0000190     	mul	r0, r0, r1
   a5388: e3100001     	tst	r0, #1
   a538c: 0afff3de     	beq	0xa230c <.text+0x9220c> @ imm = #-0x3088
   a5390: e5940000     	ldr	r0, [r4]
   a5394: e350000a     	cmp	r0, #10
   a5398: bafff3db     	blt	0xa230c <.text+0x9220c> @ imm = #-0x3094
   a539c: ed960b04     	vldr	d0, [r6, #16]
   a53a0: e1a05006     	mov	r5, r6
   a53a4: e596101c     	ldr	r1, [r6, #0x1c]
   a53a8: e300318a     	movw	r3, #0x18a
   a53ac: e5962018     	ldr	r2, [r6, #0x18]
   a53b0: e58d1018     	str	r1, [sp, #0x18]
   a53b4: e3a01003     	mov	r1, #3
   a53b8: e58d201c     	str	r2, [sp, #0x1c]
   a53bc: ed8d0b04     	vstr	d0, [sp, #16]
   a53c0: e58d1000     	str	r1, [sp]
   a53c4: e5960008     	ldr	r0, [r6, #0x8]
   a53c8: e59f1c0c     	ldr	r1, [pc, #0xc0c]        @ 0xa5fdc <.text+0x95edc>
   a53cc: e58d0008     	str	r0, [sp, #0x8]
   a53d0: e08f1001     	add	r1, pc, r1
   a53d4: e58d1004     	str	r1, [sp, #0x4]
   a53d8: e59f9c00     	ldr	r9, [pc, #0xc00]        @ 0xa5fe0 <.text+0x95ee0>
   a53dc: e59f7c00     	ldr	r7, [pc, #0xc00]        @ 0xa5fe4 <.text+0x95ee4>
   a53e0: e59f6c00     	ldr	r6, [pc, #0xc00]        @ 0xa5fe8 <.text+0x95ee8>
   a53e4: e08f9009     	add	r9, pc, r9
   a53e8: e08f7007     	add	r7, pc, r7
   a53ec: e08f6006     	add	r6, pc, r6
   a53f0: e1a00009     	mov	r0, r9
   a53f4: e1a01007     	mov	r1, r7
   a53f8: e1a02006     	mov	r2, r6
   a53fc: eb015330     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54cc0
   a5400: ed950b0a     	vldr	d0, [r5, #40]
   a5404: e300318d     	movw	r3, #0x18d
   a5408: e5951034     	ldr	r1, [r5, #0x34]
   a540c: e5952030     	ldr	r2, [r5, #0x30]
   a5410: e58d1018     	str	r1, [sp, #0x18]
   a5414: e3a01003     	mov	r1, #3
   a5418: e58d201c     	str	r2, [sp, #0x1c]
   a541c: e1a02006     	mov	r2, r6
   a5420: ed8d0b04     	vstr	d0, [sp, #16]
   a5424: e58d1000     	str	r1, [sp]
   a5428: e5950020     	ldr	r0, [r5, #0x20]
   a542c: e59f1bb8     	ldr	r1, [pc, #0xbb8]        @ 0xa5fec <.text+0x95eec>
   a5430: e58d0008     	str	r0, [sp, #0x8]
   a5434: e1a00009     	mov	r0, r9
   a5438: e08f1001     	add	r1, pc, r1
   a543c: e58d1004     	str	r1, [sp, #0x4]
   a5440: e1a01007     	mov	r1, r7
   a5444: eb01531e     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54c78
   a5448: ed9d0b12     	vldr	d0, [sp, #72]
   a544c: e3a03e19     	mov	r3, #400
   a5450: e59d1054     	ldr	r1, [sp, #0x54]
   a5454: e59d2050     	ldr	r2, [sp, #0x50]
   a5458: e58d1018     	str	r1, [sp, #0x18]
   a545c: e3a01003     	mov	r1, #3
   a5460: e58d201c     	str	r2, [sp, #0x1c]
   a5464: e1a02006     	mov	r2, r6
   a5468: ed8d0b04     	vstr	d0, [sp, #16]
   a546c: e1a06005     	mov	r6, r5
   a5470: e58d1000     	str	r1, [sp]
   a5474: e59d0040     	ldr	r0, [sp, #0x40]
   a5478: e59f1b70     	ldr	r1, [pc, #0xb70]        @ 0xa5ff0 <.text+0x95ef0>
   a547c: e58d0008     	str	r0, [sp, #0x8]
   a5480: e1a00009     	mov	r0, r9
   a5484: e08f1001     	add	r1, pc, r1
   a5488: e58d1004     	str	r1, [sp, #0x4]
   a548c: e1a01007     	mov	r1, r7
   a5490: eb01530b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54c2c
   a5494: eaffff78     	b	0xa527c <.text+0x9517c> @ imm = #-0x220
   a5498: 00543997     	<unknown>
   a549c: e59d0040     	ldr	r0, [sp, #0x40]
   a54a0: e58d002c     	str	r0, [sp, #0x2c]
   a54a4: e59d0024     	ldr	r0, [sp, #0x24]
   a54a8: e5907004     	ldr	r7, [r0, #0x4]
   a54ac: e1a00008     	mov	r0, r8
   a54b0: ebfef440     	bl	0x625b8 <.text+0x524b8> @ imm = #-0x42f00
   a54b4: e59a1000     	ldr	r1, [r10]
   a54b8: e2412001     	sub	r2, r1, #1
   a54bc: e0010291     	mul	r1, r1, r2
   a54c0: e3110001     	tst	r1, #1
   a54c4: 0a000006     	beq	0xa54e4 <.text+0x953e4> @ imm = #0x18
   a54c8: e5941000     	ldr	r1, [r4]
   a54cc: e3510009     	cmp	r1, #9
   a54d0: da000003     	ble	0xa54e4 <.text+0x953e4> @ imm = #0xc
   a54d4: e1a00008     	mov	r0, r8
   a54d8: ebfef436     	bl	0x625b8 <.text+0x524b8> @ imm = #-0x42f28
   a54dc: eaffffee     	b	0xa549c <.text+0x9539c> @ imm = #-0x48
   a54e0: 0054396a     	subseq	r3, r4, r10, ror #18
   a54e4: e3500061     	cmp	r0, #97
   a54e8: aa00000b     	bge	0xa551c <.text+0x9541c> @ imm = #0x2c
   a54ec: e59a0000     	ldr	r0, [r10]
   a54f0: e2401001     	sub	r1, r0, #1
   a54f4: e0000190     	mul	r0, r0, r1
   a54f8: e3100001     	tst	r0, #1
   a54fc: 0a000080     	beq	0xa5704 <.text+0x95604> @ imm = #0x200
   a5500: e5940000     	ldr	r0, [r4]
   a5504: e3500009     	cmp	r0, #9
   a5508: ca000094     	bgt	0xa5760 <.text+0x95660> @ imm = #0x250
   a550c: ea00007c     	b	0xa5704 <.text+0x95604> @ imm = #0x1f0
   a5510: 0056e530     	subseq	lr, r6, r0, lsr r5
   a5514: 0053a2d8     	ldrsbeq	r10, [r3], #-40
   a5518: 0056e4e8     	subseq	lr, r6, r8, ror #9
   a551c: e59a0000     	ldr	r0, [r10]
   a5520: e2401001     	sub	r1, r0, #1
   a5524: e0000190     	mul	r0, r0, r1
   a5528: e3100001     	tst	r0, #1
   a552c: e59a0000     	ldr	r0, [r10]
   a5530: ed960b04     	vldr	d0, [r6, #16]
   a5534: e2401001     	sub	r1, r0, #1
   a5538: e0000190     	mul	r0, r0, r1
   a553c: e3100001     	tst	r0, #1
   a5540: 0a000002     	beq	0xa5550 <.text+0x95450> @ imm = #0x8
   a5544: e5940000     	ldr	r0, [r4]
   a5548: e3500009     	cmp	r0, #9
   a554c: cafffff6     	bgt	0xa552c <.text+0x9542c> @ imm = #-0x28
   a5550: ee300b48     	vsub.f64	d0, d0, d8
   a5554: ed9f1beb     	vldr	d1, [pc, #940]          @ 0xa5908 <.text+0x95808>
   a5558: eeb40bc1     	vcmpe.f64	d0, d1
   a555c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a5560: da00018a     	ble	0xa5b90 <.text+0x95a90> @ imm = #0x628
   a5564: e59a0000     	ldr	r0, [r10]
   a5568: e2401001     	sub	r1, r0, #1
   a556c: e0000190     	mul	r0, r0, r1
   a5570: e3100001     	tst	r0, #1
   a5574: 0a0001f3     	beq	0xa5d48 <.text+0x95c48> @ imm = #0x7cc
   a5578: e5940000     	ldr	r0, [r4]
   a557c: e3500009     	cmp	r0, #9
   a5580: ca0001fa     	bgt	0xa5d70 <.text+0x95c70> @ imm = #0x7e8
   a5584: ea0001ef     	b	0xa5d48 <.text+0x95c48> @ imm = #0x7bc
   a5588: 00543888     	subseq	r3, r4, r8, lsl #17
   a558c: 00543763     	subseq	r3, r4, r3, ror #14
   a5590: 005436f4     	ldrsheq	r3, [r4], #-100
   a5594: 00543728     	subseq	r3, r4, r8, lsr #14
   a5598: 0054383b     	subseq	r3, r4, r11, lsr r8
   a559c: 005436fb     	ldrsheq	r3, [r4], #-107
   a55a0: 00543806     	subseq	r3, r4, r6, lsl #16
   a55a4: 005436af     	subseq	r3, r4, pc, lsr #13
   a55a8: ed960b04     	vldr	d0, [r6, #16]
   a55ac: e3a01003     	mov	r1, #3
   a55b0: e58d3018     	str	r3, [sp, #0x18]
   a55b4: e1a05006     	mov	r5, r6
   a55b8: e58d201c     	str	r2, [sp, #0x1c]
   a55bc: e300318a     	movw	r3, #0x18a
   a55c0: ed8d0b04     	vstr	d0, [sp, #16]
   a55c4: e58d1000     	str	r1, [sp]
   a55c8: e59f19dc     	ldr	r1, [pc, #0x9dc]        @ 0xa5fac <.text+0x95eac>
   a55cc: e58d0008     	str	r0, [sp, #0x8]
   a55d0: e08f1001     	add	r1, pc, r1
   a55d4: e58d1004     	str	r1, [sp, #0x4]
   a55d8: e59f99d0     	ldr	r9, [pc, #0x9d0]        @ 0xa5fb0 <.text+0x95eb0>
   a55dc: e59f79d0     	ldr	r7, [pc, #0x9d0]        @ 0xa5fb4 <.text+0x95eb4>
   a55e0: e59f69d0     	ldr	r6, [pc, #0x9d0]        @ 0xa5fb8 <.text+0x95eb8>
   a55e4: e08f9009     	add	r9, pc, r9
   a55e8: e08f7007     	add	r7, pc, r7
   a55ec: e08f6006     	add	r6, pc, r6
   a55f0: e1a00009     	mov	r0, r9
   a55f4: e1a01007     	mov	r1, r7
   a55f8: e1a02006     	mov	r2, r6
   a55fc: eb0152b0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54ac0
   a5600: ed950b0a     	vldr	d0, [r5, #40]
   a5604: e300318d     	movw	r3, #0x18d
   a5608: e5951034     	ldr	r1, [r5, #0x34]
   a560c: e5952030     	ldr	r2, [r5, #0x30]
   a5610: e58d1018     	str	r1, [sp, #0x18]
   a5614: e3a01003     	mov	r1, #3
   a5618: e58d201c     	str	r2, [sp, #0x1c]
   a561c: e1a02006     	mov	r2, r6
   a5620: ed8d0b04     	vstr	d0, [sp, #16]
   a5624: e58d1000     	str	r1, [sp]
   a5628: e5950020     	ldr	r0, [r5, #0x20]
   a562c: e59f1988     	ldr	r1, [pc, #0x988]        @ 0xa5fbc <.text+0x95ebc>
   a5630: e58d0008     	str	r0, [sp, #0x8]
   a5634: e1a00009     	mov	r0, r9
   a5638: e08f1001     	add	r1, pc, r1
   a563c: e58d1004     	str	r1, [sp, #0x4]
   a5640: e1a01007     	mov	r1, r7
   a5644: eb01529e     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54a78
   a5648: ed9d0b12     	vldr	d0, [sp, #72]
   a564c: e59d1054     	ldr	r1, [sp, #0x54]
   a5650: e59d2050     	ldr	r2, [sp, #0x50]
   a5654: e58d1018     	str	r1, [sp, #0x18]
   a5658: e3a01003     	mov	r1, #3
   a565c: e58d201c     	str	r2, [sp, #0x1c]
   a5660: e1a02006     	mov	r2, r6
   a5664: ed8d0b04     	vstr	d0, [sp, #16]
   a5668: e1a06005     	mov	r6, r5
   a566c: e58d1000     	str	r1, [sp]
   a5670: e59d0040     	ldr	r0, [sp, #0x40]
   a5674: e59f1944     	ldr	r1, [pc, #0x944]        @ 0xa5fc0 <.text+0x95ec0>
   a5678: e58d0008     	str	r0, [sp, #0x8]
   a567c: e1a00009     	mov	r0, r9
   a5680: e08f1001     	add	r1, pc, r1
   a5684: eafff7d4     	b	0xa35dc <.text+0x934dc> @ imm = #-0x20b0
   a5688: 0056e388     	subseq	lr, r6, r8, lsl #7
   a568c: e1c623d0     	ldrd	r2, r3, [r6, #48]
   a5690: e5960020     	ldr	r0, [r6, #0x20]
   a5694: e5860008     	str	r0, [r6, #0x8]
   a5698: e1a00008     	mov	r0, r8
   a569c: e1a01002     	mov	r1, r2
   a56a0: e1c621f8     	strd	r2, r3, [r6, #24]
   a56a4: eb000416     	bl	0xa6704 <.text+0x96604> @ imm = #0x1058
   a56a8: e59a0000     	ldr	r0, [r10]
   a56ac: e1c621d8     	ldrd	r2, r3, [r6, #24]
   a56b0: e2401001     	sub	r1, r0, #1
   a56b4: e0010190     	mul	r1, r0, r1
   a56b8: e5960008     	ldr	r0, [r6, #0x8]
   a56bc: e3110001     	tst	r1, #1
   a56c0: 0affffb8     	beq	0xa55a8 <.text+0x954a8> @ imm = #-0x120
   a56c4: e5941000     	ldr	r1, [r4]
   a56c8: e3510009     	cmp	r1, #9
   a56cc: daffffb5     	ble	0xa55a8 <.text+0x954a8> @ imm = #-0x12c
   a56d0: e1c623d0     	ldrd	r2, r3, [r6, #48]
   a56d4: e5960020     	ldr	r0, [r6, #0x20]
   a56d8: e5860008     	str	r0, [r6, #0x8]
   a56dc: e1a00008     	mov	r0, r8
   a56e0: e1a01002     	mov	r1, r2
   a56e4: e1c621f8     	strd	r2, r3, [r6, #24]
   a56e8: eb000405     	bl	0xa6704 <.text+0x96604> @ imm = #0x1014
   a56ec: eaffffe6     	b	0xa568c <.text+0x9558c> @ imm = #-0x68
   a56f0: 00543738     	subseq	r3, r4, r8, lsr r7
   a56f4: 0054360b     	subseq	r3, r4, r11, lsl #12
   a56f8: 005435a8     	subseq	r3, r4, r8, lsr #11
   a56fc: 005435dc     	ldrsbeq	r3, [r4], #-92
   a5700: 005436e7     	subseq	r3, r4, r7, ror #13
   a5704: e59d0050     	ldr	r0, [sp, #0x50]
   a5708: e3a03fc9     	mov	r3, #804
   a570c: e58d0020     	str	r0, [sp, #0x20]
   a5710: e3a00003     	mov	r0, #3
   a5714: e58d0000     	str	r0, [sp]
   a5718: e59f08f8     	ldr	r0, [pc, #0x8f8]        @ 0xa6018 <.text+0x95f18>
   a571c: e08f0000     	add	r0, pc, r0
   a5720: e58d0004     	str	r0, [sp, #0x4]
   a5724: e59f08f0     	ldr	r0, [pc, #0x8f0]        @ 0xa601c <.text+0x95f1c>
   a5728: e59f18f0     	ldr	r1, [pc, #0x8f0]        @ 0xa6020 <.text+0x95f20>
   a572c: e59f28f0     	ldr	r2, [pc, #0x8f0]        @ 0xa6024 <.text+0x95f24>
   a5730: e08f0000     	add	r0, pc, r0
   a5734: e08f1001     	add	r1, pc, r1
   a5738: e08f2002     	add	r2, pc, r2
   a573c: eb015260     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54980
   a5740: e59a0000     	ldr	r0, [r10]
   a5744: e2401001     	sub	r1, r0, #1
   a5748: e0000190     	mul	r0, r0, r1
   a574c: e3100001     	tst	r0, #1
   a5750: 0a00005e     	beq	0xa58d0 <.text+0x957d0> @ imm = #0x178
   a5754: e5940000     	ldr	r0, [r4]
   a5758: e3500009     	cmp	r0, #9
   a575c: da00005b     	ble	0xa58d0 <.text+0x957d0> @ imm = #0x16c
   a5760: e3a00003     	mov	r0, #3
   a5764: e3a03fc9     	mov	r3, #804
   a5768: e58d0000     	str	r0, [sp]
   a576c: e59f08dc     	ldr	r0, [pc, #0x8dc]        @ 0xa6050 <.text+0x95f50>
   a5770: e08f0000     	add	r0, pc, r0
   a5774: e58d0004     	str	r0, [sp, #0x4]
   a5778: e59f08d4     	ldr	r0, [pc, #0x8d4]        @ 0xa6054 <.text+0x95f54>
   a577c: e59f18d4     	ldr	r1, [pc, #0x8d4]        @ 0xa6058 <.text+0x95f58>
   a5780: e59f28d4     	ldr	r2, [pc, #0x8d4]        @ 0xa605c <.text+0x95f5c>
   a5784: e08f0000     	add	r0, pc, r0
   a5788: e08f1001     	add	r1, pc, r1
   a578c: e08f2002     	add	r2, pc, r2
   a5790: eb01524b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5492c
   a5794: eaffffda     	b	0xa5704 <.text+0x95604> @ imm = #-0x98
   a5798: 005436ba     	ldrheq	r3, [r4], #-106
   a579c: 0056e280     	subseq	lr, r6, r0, lsl #5
   a57a0: 0053a02c     	subseq	r10, r3, r12, lsr #32
   a57a4: 0056e238     	subseq	lr, r6, r8, lsr r2
   a57a8: 005435e4     	subseq	r3, r4, r4, ror #11
   a57ac: 005434bf     	ldrheq	r3, [r4], #-79
   a57b0: 00543450     	subseq	r3, r4, r0, asr r4
   a57b4: 00543484     	subseq	r3, r4, r4, lsl #9
   a57b8: 00543597     	<unknown>
   a57bc: 00543457     	subseq	r3, r4, r7, asr r4
   a57c0: e3500002     	cmp	r0, #2
   a57c4: 0a0000e0     	beq	0xa5b4c <.text+0x95a4c> @ imm = #0x380
   a57c8: e59f6890     	ldr	r6, [pc, #0x890]        @ 0xa6060 <.text+0x95f60>
   a57cc: e3a09003     	mov	r9, #3
   a57d0: e58d9000     	str	r9, [sp]
   a57d4: e300318a     	movw	r3, #0x18a
   a57d8: e08f6006     	add	r6, pc, r6
   a57dc: ed960b04     	vldr	d0, [r6, #16]
   a57e0: e1a07006     	mov	r7, r6
   a57e4: e5962018     	ldr	r2, [r6, #0x18]
   a57e8: e596101c     	ldr	r1, [r6, #0x1c]
   a57ec: e58d1018     	str	r1, [sp, #0x18]
   a57f0: e58d201c     	str	r2, [sp, #0x1c]
   a57f4: ed8d0b04     	vstr	d0, [sp, #16]
   a57f8: e5960008     	ldr	r0, [r6, #0x8]
   a57fc: e59f1860     	ldr	r1, [pc, #0x860]        @ 0xa6064 <.text+0x95f64>
   a5800: e58d0008     	str	r0, [sp, #0x8]
   a5804: e08f1001     	add	r1, pc, r1
   a5808: e58d1004     	str	r1, [sp, #0x4]
   a580c: e59f4854     	ldr	r4, [pc, #0x854]        @ 0xa6068 <.text+0x95f68>
   a5810: e59f5854     	ldr	r5, [pc, #0x854]        @ 0xa606c <.text+0x95f6c>
   a5814: e59f6854     	ldr	r6, [pc, #0x854]        @ 0xa6070 <.text+0x95f70>
   a5818: e08f4004     	add	r4, pc, r4
   a581c: e08f5005     	add	r5, pc, r5
   a5820: e08f6006     	add	r6, pc, r6
   a5824: e1a00004     	mov	r0, r4
   a5828: e1a01005     	mov	r1, r5
   a582c: e1a02006     	mov	r2, r6
   a5830: eb015223     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5488c
   a5834: ed970b0a     	vldr	d0, [r7, #40]
   a5838: e300318d     	movw	r3, #0x18d
   a583c: e5972030     	ldr	r2, [r7, #0x30]
   a5840: e5971034     	ldr	r1, [r7, #0x34]
   a5844: e58d201c     	str	r2, [sp, #0x1c]
   a5848: e1a02006     	mov	r2, r6
   a584c: e58d1018     	str	r1, [sp, #0x18]
   a5850: ed8d0b04     	vstr	d0, [sp, #16]
   a5854: e58d9000     	str	r9, [sp]
   a5858: e5970020     	ldr	r0, [r7, #0x20]
   a585c: e59f1810     	ldr	r1, [pc, #0x810]        @ 0xa6074 <.text+0x95f74>
   a5860: e58d0008     	str	r0, [sp, #0x8]
   a5864: e1a00004     	mov	r0, r4
   a5868: e08f1001     	add	r1, pc, r1
   a586c: e58d1004     	str	r1, [sp, #0x4]
   a5870: e1a01005     	mov	r1, r5
   a5874: eb015212     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54848
   a5878: ed9d0b12     	vldr	d0, [sp, #72]
   a587c: e3a03e19     	mov	r3, #400
   a5880: e59d1054     	ldr	r1, [sp, #0x54]
   a5884: e59d2050     	ldr	r2, [sp, #0x50]
   a5888: e58d201c     	str	r2, [sp, #0x1c]
   a588c: e1a02006     	mov	r2, r6
   a5890: e58d1018     	str	r1, [sp, #0x18]
   a5894: e1a06007     	mov	r6, r7
   a5898: ed8d0b04     	vstr	d0, [sp, #16]
   a589c: e58d9000     	str	r9, [sp]
   a58a0: e59d0040     	ldr	r0, [sp, #0x40]
   a58a4: e59f17cc     	ldr	r1, [pc, #0x7cc]        @ 0xa6078 <.text+0x95f78>
   a58a8: e58d0008     	str	r0, [sp, #0x8]
   a58ac: e1a00004     	mov	r0, r4
   a58b0: e08f1001     	add	r1, pc, r1
   a58b4: e58d1004     	str	r1, [sp, #0x4]
   a58b8: e1a01005     	mov	r1, r5
   a58bc: eb015200     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54800
   a58c0: e59f47b4     	ldr	r4, [pc, #0x7b4]        @ 0xa607c <.text+0x95f7c>
   a58c4: e3a09001     	mov	r9, #1
   a58c8: e79f4004     	ldr	r4, [pc, r4]
   a58cc: e59d5034     	ldr	r5, [sp, #0x34]
   a58d0: e59d0040     	ldr	r0, [sp, #0x40]
   a58d4: e5961008     	ldr	r1, [r6, #0x8]
   a58d8: e0410000     	sub	r0, r1, r0
   a58dc: e3700001     	cmn	r0, #1
   a58e0: ba00000c     	blt	0xa5918 <.text+0x95818> @ imm = #0x30
   a58e4: ed9d0b12     	vldr	d0, [sp, #72]
   a58e8: ed961b04     	vldr	d1, [r6, #16]
   a58ec: ee311b40     	vsub.f64	d1, d1, d0
   a58f0: eeb51bc0     	vcmpe.f64	d1, #0
   a58f4: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a58f8: da000007     	ble	0xa591c <.text+0x9581c> @ imm = #0x1c
   a58fc: ea000030     	b	0xa59c4 <.text+0x958c4> @ imm = #0xc0
   a5900: 00543562     	subseq	r3, r4, r2, ror #10
   a5904: 0054340b     	subseq	r3, r4, r11, lsl #8
   a5908: 00000000     	andeq	r0, r0, r0
   a590c: 3ff00000     	svclo	#0xf00000
   a5910: 00539e10     	subseq	r9, r3, r0, lsl lr
   a5914: 0056e020     	subseq	lr, r6, r0, lsr #32
   a5918: ed9d0b12     	vldr	d0, [sp, #72]
   a591c: e59a0000     	ldr	r0, [r10]
   a5920: e2401001     	sub	r1, r0, #1
   a5924: e0000190     	mul	r0, r0, r1
   a5928: e3100001     	tst	r0, #1
   a592c: e59a0000     	ldr	r0, [r10]
   a5930: e2401001     	sub	r1, r0, #1
   a5934: e0000190     	mul	r0, r0, r1
   a5938: e3100001     	tst	r0, #1
   a593c: 0a000002     	beq	0xa594c <.text+0x9584c> @ imm = #0x8
   a5940: e5940000     	ldr	r0, [r4]
   a5944: e3500009     	cmp	r0, #9
   a5948: cafffff7     	bgt	0xa592c <.text+0x9582c> @ imm = #-0x24
   a594c: eeb40bce     	vcmpe.f64	d0, d14
   a5950: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a5954: 5a000089     	bpl	0xa5b80 <.text+0x95a80> @ imm = #0x224
   a5958: e1a00008     	mov	r0, r8
   a595c: ebfef05b     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x43e94
   a5960: e3500000     	cmp	r0, #0
   a5964: 0a000085     	beq	0xa5b80 <.text+0x95a80> @ imm = #0x214
   a5968: e59a0000     	ldr	r0, [r10]
   a596c: e2401001     	sub	r1, r0, #1
   a5970: e0000190     	mul	r0, r0, r1
   a5974: e3100001     	tst	r0, #1
   a5978: e59a0000     	ldr	r0, [r10]
   a597c: e2401001     	sub	r1, r0, #1
   a5980: e0010190     	mul	r1, r0, r1
   a5984: e5d80108     	ldrb	r0, [r8, #0x108]
   a5988: e3110001     	tst	r1, #1
   a598c: 0a000002     	beq	0xa599c <.text+0x9589c> @ imm = #0x8
   a5990: e5941000     	ldr	r1, [r4]
   a5994: e3510009     	cmp	r1, #9
   a5998: cafffff6     	bgt	0xa5978 <.text+0x95878> @ imm = #-0x28
   a599c: e3500000     	cmp	r0, #0
   a59a0: 0a000076     	beq	0xa5b80 <.text+0x95a80> @ imm = #0x1d8
   a59a4: e1a00008     	mov	r0, r8
   a59a8: e5954048     	ldr	r4, [r5, #0x48]
   a59ac: ebfef13d     	bl	0x61ea8 <.text+0x51da8> @ imm = #-0x43b0c
   a59b0: e1540000     	cmp	r4, r0
   a59b4: e59f466c     	ldr	r4, [pc, #0x66c]        @ 0xa6028 <.text+0x95f28>
   a59b8: e3a09001     	mov	r9, #1
   a59bc: e79f4004     	ldr	r4, [pc, r4]
   a59c0: 2a00006e     	bhs	0xa5b80 <.text+0x95a80> @ imm = #0x1b8
   a59c4: e59a0000     	ldr	r0, [r10]
   a59c8: e2401001     	sub	r1, r0, #1
   a59cc: e0000190     	mul	r0, r0, r1
   a59d0: e3100001     	tst	r0, #1
   a59d4: 0a000002     	beq	0xa59e4 <.text+0x958e4> @ imm = #0x8
   a59d8: e5940000     	ldr	r0, [r4]
   a59dc: e3500009     	cmp	r0, #9
   a59e0: ca00000e     	bgt	0xa5a20 <.text+0x95920> @ imm = #0x38
   a59e4: e598001c     	ldr	r0, [r8, #0x1c]
   a59e8: e59840dc     	ldr	r4, [r8, #0xdc]
   a59ec: e598720c     	ldr	r7, [r8, #0x20c]
   a59f0: ebfeecd4     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x44cb0
   a59f4: e59a1000     	ldr	r1, [r10]
   a59f8: e2412001     	sub	r2, r1, #1
   a59fc: e0020291     	mul	r2, r1, r2
   a5a00: e2841ffa     	add	r1, r4, #1000
   a5a04: e59f4620     	ldr	r4, [pc, #0x620]        @ 0xa602c <.text+0x95f2c>
   a5a08: e79f4004     	ldr	r4, [pc, r4]
   a5a0c: e3120001     	tst	r2, #1
   a5a10: 0a000005     	beq	0xa5a2c <.text+0x9592c> @ imm = #0x14
   a5a14: e5942000     	ldr	r2, [r4]
   a5a18: e3520009     	cmp	r2, #9
   a5a1c: da000002     	ble	0xa5a2c <.text+0x9592c> @ imm = #0x8
   a5a20: e598001c     	ldr	r0, [r8, #0x1c]
   a5a24: ebfeecc7     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x44ce4
   a5a28: eaffffed     	b	0xa59e4 <.text+0x958e4> @ imm = #-0x4c
   a5a2c: e1510000     	cmp	r1, r0
   a5a30: e2872032     	add	r2, r7, #50
   a5a34: e58d202c     	str	r2, [sp, #0x2c]
   a5a38: aa000007     	bge	0xa5a5c <.text+0x9595c> @ imm = #0x1c
   a5a3c: e59800dc     	ldr	r0, [r8, #0xdc]
   a5a40: e2800ffa     	add	r0, r0, #1000
   a5a44: ea000006     	b	0xa5a64 <.text+0x95964> @ imm = #0x18
   a5a48: 005433a0     	subseq	r3, r4, r0, lsr #7
   a5a4c: 00543273     	subseq	r3, r4, r3, ror r2
   a5a50: 00543210     	subseq	r3, r4, r0, lsl r2
   a5a54: 00543244     	subseq	r3, r4, r4, asr #4
   a5a58: 0054334f     	subseq	r3, r4, pc, asr #6
   a5a5c: e598001c     	ldr	r0, [r8, #0x1c]
   a5a60: ebfeecb8     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x44d20
   a5a64: e59d102c     	ldr	r1, [sp, #0x2c]
   a5a68: e3a09001     	mov	r9, #1
   a5a6c: e1500001     	cmp	r0, r1
   a5a70: ba000042     	blt	0xa5b80 <.text+0x95a80> @ imm = #0x108
   a5a74: e59a0000     	ldr	r0, [r10]
   a5a78: e59d9030     	ldr	r9, [sp, #0x30]
   a5a7c: e2401001     	sub	r1, r0, #1
   a5a80: e0000190     	mul	r0, r0, r1
   a5a84: e3100001     	tst	r0, #1
   a5a88: 0a000004     	beq	0xa5aa0 <.text+0x959a0> @ imm = #0x10
   a5a8c: e59f059c     	ldr	r0, [pc, #0x59c]        @ 0xa6030 <.text+0x95f30>
   a5a90: e79f0000     	ldr	r0, [pc, r0]
   a5a94: e5900000     	ldr	r0, [r0]
   a5a98: e3500009     	cmp	r0, #9
   a5a9c: ca000014     	bgt	0xa5af4 <.text+0x959f4> @ imm = #0x50
   a5aa0: e59d102c     	ldr	r1, [sp, #0x2c]
   a5aa4: e1a00008     	mov	r0, r8
   a5aa8: eb000315     	bl	0xa6704 <.text+0x96604> @ imm = #0xc54
   a5aac: e28d1040     	add	r1, sp, #64
   a5ab0: e1a0c009     	mov	r12, r9
   a5ab4: e1a00001     	mov	r0, r1
   a5ab8: e89000fc     	ldm	r0, {r2, r3, r4, r5, r6, r7}
   a5abc: e1a00008     	mov	r0, r8
   a5ac0: e88c00fc     	stm	r12, {r2, r3, r4, r5, r6, r7}
   a5ac4: e3a0203c     	mov	r2, #60
   a5ac8: eb0001b0     	bl	0xa6190 <.text+0x96090> @ imm = #0x6c0
   a5acc: e59a1000     	ldr	r1, [r10]
   a5ad0: e2412001     	sub	r2, r1, #1
   a5ad4: e0010291     	mul	r1, r1, r2
   a5ad8: e3110001     	tst	r1, #1
   a5adc: 0affff37     	beq	0xa57c0 <.text+0x956c0> @ imm = #-0x324
   a5ae0: e59f154c     	ldr	r1, [pc, #0x54c]        @ 0xa6034 <.text+0x95f34>
   a5ae4: e79f1001     	ldr	r1, [pc, r1]
   a5ae8: e5911000     	ldr	r1, [r1]
   a5aec: e3510009     	cmp	r1, #9
   a5af0: daffff32     	ble	0xa57c0 <.text+0x956c0> @ imm = #-0x338
   a5af4: e59d102c     	ldr	r1, [sp, #0x2c]
   a5af8: e1a00008     	mov	r0, r8
   a5afc: eb000300     	bl	0xa6704 <.text+0x96604> @ imm = #0xc00
   a5b00: e28d1040     	add	r1, sp, #64
   a5b04: e1a0c009     	mov	r12, r9
   a5b08: e1a00001     	mov	r0, r1
   a5b0c: e89000fc     	ldm	r0, {r2, r3, r4, r5, r6, r7}
   a5b10: e1a00008     	mov	r0, r8
   a5b14: e88c00fc     	stm	r12, {r2, r3, r4, r5, r6, r7}
   a5b18: e3a0203c     	mov	r2, #60
   a5b1c: eb00019b     	bl	0xa6190 <.text+0x96090> @ imm = #0x66c
   a5b20: eaffffde     	b	0xa5aa0 <.text+0x959a0> @ imm = #-0x88
   a5b24: 0054331a     	subseq	r3, r4, r10, lsl r3
   a5b28: 005431cd     	subseq	r3, r4, sp, asr #3
   a5b2c: 00543147     	subseq	r3, r4, r7, asr #2
   a5b30: 005430e4     	subseq	r3, r4, r4, ror #1
   a5b34: 00543118     	subseq	r3, r4, r8, lsl r1
   a5b38: 00543179     	subseq	r3, r4, r9, ror r1
   a5b3c: 005430f3     	ldrsheq	r3, [r4], #-3
   a5b40: 00543090     	<unknown>
   a5b44: 005430c4     	subseq	r3, r4, r4, asr #1
   a5b48: 00539b98     	<unknown>
   a5b4c: e598020c     	ldr	r0, [r8, #0x20c]
   a5b50: e2401032     	sub	r1, r0, #50
   a5b54: e1a00008     	mov	r0, r8
   a5b58: eb0002e9     	bl	0xa6704 <.text+0x96604> @ imm = #0xba4
   a5b5c: e89900ee     	ldm	r9, {r1, r2, r3, r5, r6, r7}
   a5b60: e28d0040     	add	r0, sp, #64
   a5b64: e3a09001     	mov	r9, #1
   a5b68: e88000ee     	stm	r0, {r1, r2, r3, r5, r6, r7}
   a5b6c: e59f64c4     	ldr	r6, [pc, #0x4c4]        @ 0xa6038 <.text+0x95f38>
   a5b70: e59f44c4     	ldr	r4, [pc, #0x4c4]        @ 0xa603c <.text+0x95f3c>
   a5b74: e08f6006     	add	r6, pc, r6
   a5b78: e79f4004     	ldr	r4, [pc, r4]
   a5b7c: e59d5034     	ldr	r5, [sp, #0x34]
   a5b80: e59d0050     	ldr	r0, [sp, #0x50]
   a5b84: e59d1020     	ldr	r1, [sp, #0x20]
   a5b88: e1510000     	cmp	r1, r0
   a5b8c: 1a000058     	bne	0xa5cf4 <.text+0x95bf4> @ imm = #0x160
   a5b90: e3a00003     	mov	r0, #3
   a5b94: e3003352     	movw	r3, #0x352
   a5b98: e58d0000     	str	r0, [sp]
   a5b9c: e59f0454     	ldr	r0, [pc, #0x454]        @ 0xa5ff8 <.text+0x95ef8>
   a5ba0: e08f0000     	add	r0, pc, r0
   a5ba4: e58d0004     	str	r0, [sp, #0x4]
   a5ba8: e59f544c     	ldr	r5, [pc, #0x44c]        @ 0xa5ffc <.text+0x95efc>
   a5bac: e59f944c     	ldr	r9, [pc, #0x44c]        @ 0xa6000 <.text+0x95f00>
   a5bb0: e59f244c     	ldr	r2, [pc, #0x44c]        @ 0xa6004 <.text+0x95f04>
   a5bb4: e08f5005     	add	r5, pc, r5
   a5bb8: e08f9009     	add	r9, pc, r9
   a5bbc: e08f2002     	add	r2, pc, r2
   a5bc0: e1a00005     	mov	r0, r5
   a5bc4: e1a01009     	mov	r1, r9
   a5bc8: e1a05002     	mov	r5, r2
   a5bcc: eb01513c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x544f0
   a5bd0: ed960b04     	vldr	d0, [r6, #16]
   a5bd4: e300318a     	movw	r3, #0x18a
   a5bd8: e596101c     	ldr	r1, [r6, #0x1c]
   a5bdc: e5962018     	ldr	r2, [r6, #0x18]
   a5be0: e58d1018     	str	r1, [sp, #0x18]
   a5be4: e3a01003     	mov	r1, #3
   a5be8: e58d201c     	str	r2, [sp, #0x1c]
   a5bec: e1a02005     	mov	r2, r5
   a5bf0: ed8d0b04     	vstr	d0, [sp, #16]
   a5bf4: e58d1000     	str	r1, [sp]
   a5bf8: e5960008     	ldr	r0, [r6, #0x8]
   a5bfc: e59f1404     	ldr	r1, [pc, #0x404]        @ 0xa6008 <.text+0x95f08>
   a5c00: e58d0008     	str	r0, [sp, #0x8]
   a5c04: e08f1001     	add	r1, pc, r1
   a5c08: e58d1004     	str	r1, [sp, #0x4]
   a5c0c: e59f73f8     	ldr	r7, [pc, #0x3f8]        @ 0xa600c <.text+0x95f0c>
   a5c10: e1a01009     	mov	r1, r9
   a5c14: e08f7007     	add	r7, pc, r7
   a5c18: e1a00007     	mov	r0, r7
   a5c1c: eb015128     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x544a0
   a5c20: ed960b0a     	vldr	d0, [r6, #40]
   a5c24: e300318d     	movw	r3, #0x18d
   a5c28: e5961034     	ldr	r1, [r6, #0x34]
   a5c2c: e5962030     	ldr	r2, [r6, #0x30]
   a5c30: e58d1018     	str	r1, [sp, #0x18]
   a5c34: e3a01003     	mov	r1, #3
   a5c38: e58d201c     	str	r2, [sp, #0x1c]
   a5c3c: e1a02005     	mov	r2, r5
   a5c40: ed8d0b04     	vstr	d0, [sp, #16]
   a5c44: e58d1000     	str	r1, [sp]
   a5c48: e5960020     	ldr	r0, [r6, #0x20]
   a5c4c: e59f13bc     	ldr	r1, [pc, #0x3bc]        @ 0xa6010 <.text+0x95f10>
   a5c50: e58d0008     	str	r0, [sp, #0x8]
   a5c54: e1a00007     	mov	r0, r7
   a5c58: e08f1001     	add	r1, pc, r1
   a5c5c: e58d1004     	str	r1, [sp, #0x4]
   a5c60: e1a01009     	mov	r1, r9
   a5c64: eb015116     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54458
   a5c68: ed9d0b12     	vldr	d0, [sp, #72]
   a5c6c: e3a03e19     	mov	r3, #400
   a5c70: e59d1054     	ldr	r1, [sp, #0x54]
   a5c74: e59d2050     	ldr	r2, [sp, #0x50]
   a5c78: e58d1018     	str	r1, [sp, #0x18]
   a5c7c: e3a01003     	mov	r1, #3
   a5c80: e58d201c     	str	r2, [sp, #0x1c]
   a5c84: e1a02005     	mov	r2, r5
   a5c88: ed8d0b04     	vstr	d0, [sp, #16]
   a5c8c: e58d1000     	str	r1, [sp]
   a5c90: e59d0040     	ldr	r0, [sp, #0x40]
   a5c94: e59f1378     	ldr	r1, [pc, #0x378]        @ 0xa6014 <.text+0x95f14>
   a5c98: e58d0008     	str	r0, [sp, #0x8]
   a5c9c: e1a00007     	mov	r0, r7
   a5ca0: e08f1001     	add	r1, pc, r1
   a5ca4: e58d1004     	str	r1, [sp, #0x4]
   a5ca8: e1a01009     	mov	r1, r9
   a5cac: eb015104     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x54410
   a5cb0: eeb08b4a     	vmov.f64	d8, d10
   a5cb4: eeb0ab49     	vmov.f64	d10, d9
   a5cb8: eeb09b4f     	vmov.f64	d9, d15
   a5cbc: eeb0fb4b     	vmov.f64	d15, d11
   a5cc0: ed9fbba6     	vldr	d11, [pc, #664]         @ 0xa5f60 <.text+0x95e60>
   a5cc4: e59a0000     	ldr	r0, [r10]
   a5cc8: e3a09001     	mov	r9, #1
   a5ccc: e59d5034     	ldr	r5, [sp, #0x34]
   a5cd0: e2401001     	sub	r1, r0, #1
   a5cd4: e0000190     	mul	r0, r0, r1
   a5cd8: e3100001     	tst	r0, #1
   a5cdc: 0a000074     	beq	0xa5eb4 <.text+0x95db4> @ imm = #0x1d0
   a5ce0: e5940000     	ldr	r0, [r4]
   a5ce4: e3500009     	cmp	r0, #9
   a5ce8: ca00007b     	bgt	0xa5edc <.text+0x95ddc> @ imm = #0x1ec
   a5cec: ea000070     	b	0xa5eb4 <.text+0x95db4> @ imm = #0x1c0
   a5cf0: 0056dd08     	subseq	sp, r6, r8, lsl #26
   a5cf4: eeb08b4a     	vmov.f64	d8, d10
   a5cf8: e59d1040     	ldr	r1, [sp, #0x40]
   a5cfc: e5962008     	ldr	r2, [r6, #0x8]
   a5d00: e1510002     	cmp	r1, r2
   a5d04: eeb0ab49     	vmov.f64	d10, d9
   a5d08: eeb09b4f     	vmov.f64	d9, d15
   a5d0c: eeb0fb4b     	vmov.f64	d15, d11
   a5d10: ed9fbb92     	vldr	d11, [pc, #584]         @ 0xa5f60 <.text+0x95e60>
   a5d14: aafff17c     	bge	0xa230c <.text+0x9220c> @ imm = #-0x3a10
   a5d18: ed9d0b12     	vldr	d0, [sp, #72]
   a5d1c: ed961b04     	vldr	d1, [r6, #16]
   a5d20: ee300b41     	vsub.f64	d0, d0, d1
   a5d24: eeb40bca     	vcmpe.f64	d0, d10
   a5d28: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a5d2c: dafff176     	ble	0xa230c <.text+0x9220c> @ imm = #-0x3a28
   a5d30: e59d3054     	ldr	r3, [sp, #0x54]
   a5d34: e5861008     	str	r1, [r6, #0x8]
   a5d38: e5860018     	str	r0, [r6, #0x18]
   a5d3c: e586301c     	str	r3, [r6, #0x1c]
   a5d40: eafff171     	b	0xa230c <.text+0x9220c> @ imm = #-0x3a3c
   a5d44: 00539ae0     	subseq	r9, r3, r0, ror #21
   a5d48: e1a00008     	mov	r0, r8
   a5d4c: ebfeef5f     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x44284
   a5d50: e59a1000     	ldr	r1, [r10]
   a5d54: e2412001     	sub	r2, r1, #1
   a5d58: e0010291     	mul	r1, r1, r2
   a5d5c: e3110001     	tst	r1, #1
   a5d60: 0a00000b     	beq	0xa5d94 <.text+0x95c94> @ imm = #0x2c
   a5d64: e5941000     	ldr	r1, [r4]
   a5d68: e3510009     	cmp	r1, #9
   a5d6c: da000008     	ble	0xa5d94 <.text+0x95c94> @ imm = #0x20
   a5d70: e1a00008     	mov	r0, r8
   a5d74: ebfeef55     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x442ac
   a5d78: eafffff2     	b	0xa5d48 <.text+0x95c48> @ imm = #-0x38
   a5d7c: 005430a8     	subseq	r3, r4, r8, lsr #1
   a5d80: 00542f7f     	subseq	r2, r4, pc, ror pc
   a5d84: 00542f1c     	subseq	r2, r4, r12, lsl pc
   a5d88: 00542f40     	subseq	r2, r4, r0, asr #30
   a5d8c: 00543057     	subseq	r3, r4, r7, asr r0
   a5d90: 00542f17     	subseq	r2, r4, r7, lsl pc
   a5d94: e3500000     	cmp	r0, #0
   a5d98: 15d80108     	ldrbne	r0, [r8, #0x108]
   a5d9c: 13500000     	cmpne	r0, #0
   a5da0: 1a00003a     	bne	0xa5e90 <.text+0x95d90> @ imm = #0xe8
   a5da4: e59a0000     	ldr	r0, [r10]
   a5da8: e2401001     	sub	r1, r0, #1
   a5dac: e0000190     	mul	r0, r0, r1
   a5db0: e3100001     	tst	r0, #1
   a5db4: e59a0000     	ldr	r0, [r10]
   a5db8: e2401001     	sub	r1, r0, #1
   a5dbc: e0010190     	mul	r1, r0, r1
   a5dc0: e5980050     	ldr	r0, [r8, #0x50]
   a5dc4: e3110001     	tst	r1, #1
   a5dc8: 0a000002     	beq	0xa5dd8 <.text+0x95cd8> @ imm = #0x8
   a5dcc: e5941000     	ldr	r1, [r4]
   a5dd0: e3510009     	cmp	r1, #9
   a5dd4: cafffff6     	bgt	0xa5db4 <.text+0x95cb4> @ imm = #-0x28
   a5dd8: e3500000     	cmp	r0, #0
   a5ddc: 0a000014     	beq	0xa5e34 <.text+0x95d34> @ imm = #0x50
   a5de0: e59a0000     	ldr	r0, [r10]
   a5de4: e2401001     	sub	r1, r0, #1
   a5de8: e0000190     	mul	r0, r0, r1
   a5dec: e3100001     	tst	r0, #1
   a5df0: e59a0000     	ldr	r0, [r10]
   a5df4: e2401001     	sub	r1, r0, #1
   a5df8: e0010190     	mul	r1, r0, r1
   a5dfc: e5960008     	ldr	r0, [r6, #0x8]
   a5e00: e3110001     	tst	r1, #1
   a5e04: 0a000002     	beq	0xa5e14 <.text+0x95d14> @ imm = #0x8
   a5e08: e5941000     	ldr	r1, [r4]
   a5e0c: e3510009     	cmp	r1, #9
   a5e10: cafffff6     	bgt	0xa5df0 <.text+0x95cf0> @ imm = #-0x28
   a5e14: e59d102c     	ldr	r1, [sp, #0x2c]
   a5e18: e0400001     	sub	r0, r0, r1
   a5e1c: e3500004     	cmp	r0, #4
   a5e20: aa000007     	bge	0xa5e44 <.text+0x95d44> @ imm = #0x1c
   a5e24: eaffff59     	b	0xa5b90 <.text+0x95a90> @ imm = #-0x29c
   a5e28: 0054301e     	subseq	r3, r4, lr, lsl r0
   a5e2c: 00542ec3     	subseq	r2, r4, r3, asr #29
   a5e30: 00542e60     	subseq	r2, r4, r0, ror #28
   a5e34: e596001c     	ldr	r0, [r6, #0x1c]
   a5e38: e0400007     	sub	r0, r0, r7
   a5e3c: e3500003     	cmp	r0, #3
   a5e40: daffff52     	ble	0xa5b90 <.text+0x95a90> @ imm = #-0x2b8
   a5e44: e59a0000     	ldr	r0, [r10]
   a5e48: e2401001     	sub	r1, r0, #1
   a5e4c: e0000190     	mul	r0, r0, r1
   a5e50: e3100001     	tst	r0, #1
   a5e54: e59a0000     	ldr	r0, [r10]
   a5e58: ed960b04     	vldr	d0, [r6, #16]
   a5e5c: e2401001     	sub	r1, r0, #1
   a5e60: e0000190     	mul	r0, r0, r1
   a5e64: e3100001     	tst	r0, #1
   a5e68: 0a000002     	beq	0xa5e78 <.text+0x95d78> @ imm = #0x8
   a5e6c: e5940000     	ldr	r0, [r4]
   a5e70: e3500009     	cmp	r0, #9
   a5e74: cafffff6     	bgt	0xa5e54 <.text+0x95d54> @ imm = #-0x28
   a5e78: ee300b48     	vsub.f64	d0, d0, d8
   a5e7c: ed9f1b35     	vldr	d1, [pc, #212]          @ 0xa5f58 <.text+0x95e58>
   a5e80: eeb40bc1     	vcmpe.f64	d0, d1
   a5e84: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a5e88: cafffd97     	bgt	0xa54ec <.text+0x953ec> @ imm = #-0x9a4
   a5e8c: eaffff3f     	b	0xa5b90 <.text+0x95a90> @ imm = #-0x304
   a5e90: e1a00008     	mov	r0, r8
   a5e94: e5954048     	ldr	r4, [r5, #0x48]
   a5e98: ebfeeff8     	bl	0x61e80 <.text+0x51d80> @ imm = #-0x44020
   a5e9c: e1540000     	cmp	r4, r0
   a5ea0: e59f414c     	ldr	r4, [pc, #0x14c]        @ 0xa5ff4 <.text+0x95ef4>
   a5ea4: e3a09001     	mov	r9, #1
   a5ea8: e79f4004     	ldr	r4, [pc, r4]
   a5eac: 9affffbc     	bls	0xa5da4 <.text+0x95ca4> @ imm = #-0x110
   a5eb0: eaffff36     	b	0xa5b90 <.text+0x95a90> @ imm = #-0x328
   a5eb4: e3a00ffa     	mov	r0, #1000
   a5eb8: eb01a41f     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6907c
   a5ebc: e59a0000     	ldr	r0, [r10]
   a5ec0: e2401001     	sub	r1, r0, #1
   a5ec4: e0000190     	mul	r0, r0, r1
   a5ec8: e3100001     	tst	r0, #1
   a5ecc: 0afff10e     	beq	0xa230c <.text+0x9220c> @ imm = #-0x3bc8
   a5ed0: e5940000     	ldr	r0, [r4]
   a5ed4: e350000a     	cmp	r0, #10
   a5ed8: bafff10b     	blt	0xa230c <.text+0x9220c> @ imm = #-0x3bd4
   a5edc: e3a00ffa     	mov	r0, #1000
   a5ee0: eb01a415     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x69054
   a5ee4: eafffff2     	b	0xa5eb4 <.text+0x95db4> @ imm = #-0x38
   a5ee8: 00539928     	subseq	r9, r3, r8, lsr #18
   a5eec: e59f014c     	ldr	r0, [pc, #0x14c]        @ 0xa6040 <.text+0x95f40>
   a5ef0: e3a07001     	mov	r7, #1
   a5ef4: e59f1148     	ldr	r1, [pc, #0x148]        @ 0xa6044 <.text+0x95f44>
   a5ef8: e59f2148     	ldr	r2, [pc, #0x148]        @ 0xa6048 <.text+0x95f48>
   a5efc: e08f0000     	add	r0, pc, r0
   a5f00: e59f3144     	ldr	r3, [pc, #0x144]        @ 0xa604c <.text+0x95f4c>
   a5f04: e08f1001     	add	r1, pc, r1
   a5f08: e08f2002     	add	r2, pc, r2
   a5f0c: e58d7000     	str	r7, [sp]
   a5f10: e08f3003     	add	r3, pc, r3
   a5f14: e58d3004     	str	r3, [sp, #0x4]
   a5f18: e3003291     	movw	r3, #0x291
   a5f1c: eb015068     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x541a0
   a5f20: eb014b52     	bl	0xf8c70 <.text+0xe8b70> @ imm = #0x52d48
   a5f24: e30100b4     	movw	r0, #0x10b4
   a5f28: e3001bbc     	movw	r1, #0xbbc
   a5f2c: e0880000     	add	r0, r8, r0
   a5f30: ebfe8f58     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x5c2a0
   a5f34: e1a00008     	mov	r0, r8
   a5f38: ebff0410     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x3efc0
   a5f3c: e3a00000     	mov	r0, #0
   a5f40: e24bd060     	sub	sp, r11, #96
   a5f44: ecbd8b10     	vpop	{d8, d9, d10, d11, d12, d13, d14, d15}
   a5f48: e28dd004     	add	sp, sp, #4
   a5f4c: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   a5f50: e3a00000     	mov	r0, #0
   a5f54: eb13fcdd     	bl	0x5a52d0 <.text+0x5951d0> @ imm = #0x4ff374
   a5f58: 00000000     	andeq	r0, r0, r0
   a5f5c: 3ff00000     	svclo	#0xf00000
   a5f60: d2f1a9fc     	rscsle	r10, r1, #252, #18
   a5f64: 3f50624d     	svclo	#0x50624d
   a5f68: 00539874     	subseq	r9, r3, r4, ror r8
   a5f6c: 0056da84     	subseq	sp, r6, r4, lsl #21
   a5f70: 00542e28     	subseq	r2, r4, r8, lsr #28
   a5f74: 00542cfb     	ldrsheq	r2, [r4], #-203
   a5f78: 00542c98     	<unknown>
   a5f7c: 00542ccc     	subseq	r2, r4, r12, asr #25
   a5f80: 00542dd7     	ldrsbeq	r2, [r4], #-215
   a5f84: 00542daa     	subseq	r2, r4, r10, lsr #27
   a5f88: 0056d96c     	subseq	sp, r6, r12, ror #18
   a5f8c: 0056d92c     	subseq	sp, r6, r12, lsr #18
   a5f90: 00542cd4     	ldrsbeq	r2, [r4], #-196
   a5f94: 00542ba7     	subseq	r2, r4, r7, lsr #23
   a5f98: 00542b44     	subseq	r2, r4, r4, asr #22
   a5f9c: 00542b78     	subseq	r2, r4, r8, ror r11
   a5fa0: 00542c87     	subseq	r2, r4, r7, lsl #25
   a5fa4: 00542c52     	subseq	r2, r4, r2, asr r12
   a5fa8: 00542aa0     	subseq	r2, r4, r0, lsr #21
   a5fac: 00542874     	subseq	r2, r4, r4, ror r8
   a5fb0: 00542747     	subseq	r2, r4, r7, asr #14
   a5fb4: 005426e4     	subseq	r2, r4, r4, ror #13
   a5fb8: 00542718     	subseq	r2, r4, r8, lsl r7
   a5fbc: 00542823     	subseq	r2, r4, r3, lsr #16
   a5fc0: 005427f2     	ldrsheq	r2, [r4], #-114
   a5fc4: 00542b94     	<unknown>
   a5fc8: 00542a67     	subseq	r2, r4, r7, ror #20
   a5fcc: 00542a04     	subseq	r2, r4, r4, lsl #20
   a5fd0: 00542a38     	subseq	r2, r4, r8, lsr r10
   a5fd4: 00542b43     	subseq	r2, r4, r3, asr #22
   a5fd8: 00542b0e     	subseq	r2, r4, lr, lsl #22
   a5fdc: 00542a74     	subseq	r2, r4, r4, ror r10
   a5fe0: 00542947     	subseq	r2, r4, r7, asr #18
   a5fe4: 005428e4     	subseq	r2, r4, r4, ror #17
   a5fe8: 00542918     	subseq	r2, r4, r8, lsl r9
   a5fec: 00542a23     	subseq	r2, r4, r3, lsr #20
   a5ff0: 005429ee     	subseq	r2, r4, lr, ror #19
   a5ff4: 00538988     	subseq	r8, r3, r8, lsl #19
   a5ff8: 0054223f     	subseq	r2, r4, pc, lsr r2
   a5ffc: 00542177     	subseq	r2, r4, r7, ror r1
   a6000: 00542114     	subseq	r2, r4, r4, lsl r1
   a6004: 00542148     	subseq	r2, r4, r8, asr #2
   a6008: 00542240     	subseq	r2, r4, r0, asr #4
   a600c: 00542117     	subseq	r2, r4, r7, lsl r1
   a6010: 00542203     	subseq	r2, r4, r3, lsl #4
   a6014: 005421d2     	ldrsbeq	r2, [r4], #-18
   a6018: 005426a4     	subseq	r2, r4, r4, lsr #13
   a601c: 005425fb     	ldrsheq	r2, [r4], #-91
   a6020: 00542598     	<unknown>
   a6024: 005425cc     	subseq	r2, r4, r12, asr #11
   a6028: 00538e74     	subseq	r8, r3, r4, ror lr
   a602c: 00538e28     	subseq	r8, r3, r8, lsr #28
   a6030: 00538da0     	subseq	r8, r3, r0, lsr #27
   a6034: 00538d4c     	subseq	r8, r3, r12, asr #26
   a6038: 0056ced4     	ldrsbeq	r12, [r6], #-228
   a603c: 00538cb8     	ldrheq	r8, [r3], #-200
   a6040: 00541e01     	subseq	r1, r4, r1, lsl #28
   a6044: 00541dc8     	subseq	r1, r4, r8, asr #27
   a6048: 00541dfc     	ldrsheq	r1, [r4], #-220
   a604c: 00541dff     	ldrsheq	r1, [r4], #-223
   a6050: 00542650     	subseq	r2, r4, r0, asr r6
   a6054: 005425a7     	subseq	r2, r4, r7, lsr #11
   a6058: 00542544     	subseq	r2, r4, r4, asr #10
   a605c: 00542578     	subseq	r2, r4, r8, ror r5
   a6060: 0056d270     	subseq	sp, r6, r0, ror r2
   a6064: 00542640     	subseq	r2, r4, r0, asr #12
   a6068: 00542513     	subseq	r2, r4, r3, lsl r5
   a606c: 005424b0     	ldrheq	r2, [r4], #-64
   a6070: 005424e4     	subseq	r2, r4, r4, ror #9
   a6074: 005425f3     	ldrsheq	r2, [r4], #-83
   a6078: 005425c2     	subseq	r2, r4, r2, asr #11
   a607c: 00538f68     	subseq	r8, r3, r8, ror #30

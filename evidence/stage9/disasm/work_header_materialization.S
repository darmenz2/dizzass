
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   30550: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   30554: e28db01c     	add	r11, sp, #28
   30558: e24dd004     	sub	sp, sp, #4
   3055c: ed2d8b02     	vpush	{d8}
   30560: e24ddf5a     	sub	sp, sp, #360
   30564: e1a09000     	mov	r9, r0
   30568: e2800030     	add	r0, r0, #48
   3056c: e1a04001     	mov	r4, r1
   30570: e58d000c     	str	r0, [sp, #0xc]
   30574: eb15d967     	bl	0x5a6b18 <.text+0x596a18> @ imm = #0x57659c
   30578: e3500000     	cmp	r0, #0
   3057c: 1a00000f     	bne	0x305c0 <.text+0x204c0> @ imm = #0x3c
   30580: e59facb4     	ldr	r10, [pc, #0xcb4]       @ 0x3123c <.text+0x2113c>
   30584: e2846e19     	add	r6, r4, #400
   30588: e79fa00a     	ldr	r10, [pc, r10]
   3058c: e59a0000     	ldr	r0, [r10]
   30590: e59f8ca8     	ldr	r8, [pc, #0xca8]        @ 0x31240 <.text+0x21140>
   30594: e2401001     	sub	r1, r0, #1
   30598: e0000190     	mul	r0, r0, r1
   3059c: e79f8008     	ldr	r8, [pc, r8]
   305a0: e59f5c9c     	ldr	r5, [pc, #0xc9c]        @ 0x31244 <.text+0x21144>
   305a4: e08f5005     	add	r5, pc, r5
   305a8: e3100001     	tst	r0, #1
   305ac: 0a000010     	beq	0x305f4 <.text+0x204f4> @ imm = #0x40
   305b0: e5980000     	ldr	r0, [r8]
   305b4: e3500009     	cmp	r0, #9
   305b8: ca00002e     	bgt	0x30678 <.text+0x20578> @ imm = #0xb8
   305bc: ea00000c     	b	0x305f4 <.text+0x204f4> @ imm = #0x30
   305c0: eb158b07     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562c1c
   305c4: e59f2c64     	ldr	r2, [pc, #0xc64]        @ 0x31230 <.text+0x21130>
   305c8: e59f1c64     	ldr	r1, [pc, #0xc64]        @ 0x31234 <.text+0x21134>
   305cc: e5900000     	ldr	r0, [r0]
   305d0: e08f2002     	add	r2, pc, r2
   305d4: e59f3c5c     	ldr	r3, [pc, #0xc5c]        @ 0x31238 <.text+0x21138>
   305d8: e08f1001     	add	r1, pc, r1
   305dc: e58d0000     	str	r0, [sp]
   305e0: e1a00002     	mov	r0, r2
   305e4: e08f3003     	add	r3, pc, r3
   305e8: e300223d     	movw	r2, #0x23d
   305ec: ebff7f29     	bl	0x10298 <.text+0x198>   @ imm = #-0x2035c
   305f0: eaffffe2     	b	0x30580 <.text+0x20480> @ imm = #-0x78
   305f4: e2897d0f     	add	r7, r9, #960
   305f8: e59923cc     	ldr	r2, [r9, #0x3cc]
   305fc: e8970083     	ldm	r7, {r0, r1, r7}
   30600: e59f3c40     	ldr	r3, [pc, #0xc40]        @ 0x31248 <.text+0x21148>
   30604: e58d1014     	str	r1, [sp, #0x14]
   30608: e3001392     	movw	r1, #0x392
   3060c: e58d0010     	str	r0, [sp, #0x10]
   30610: e08f3003     	add	r3, pc, r3
   30614: e59903b4     	ldr	r0, [r9, #0x3b4]
   30618: e58d1004     	str	r1, [sp, #0x4]
   3061c: e28d1010     	add	r1, sp, #16
   30620: e0800007     	add	r0, r0, r7
   30624: e58d5000     	str	r5, [sp]
   30628: ebff85d3     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1e8b4
   3062c: e59903c0     	ldr	r0, [r9, #0x3c0]
   30630: e59913c4     	ldr	r1, [r9, #0x3c4]
   30634: e2902001     	adds	r2, r0, #1
   30638: e58923c0     	str	r2, [r9, #0x3c0]
   3063c: e2a13000     	adc	r3, r1, #0
   30640: e58933c4     	str	r3, [r9, #0x3c4]
   30644: e1c600f0     	strd	r0, r1, [r6]
   30648: e59903cc     	ldr	r0, [r9, #0x3cc]
   3064c: e5840198     	str	r0, [r4, #0x198]
   30650: e59d000c     	ldr	r0, [sp, #0xc]
   30654: eb15d907     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x57641c
   30658: e59a1000     	ldr	r1, [r10]
   3065c: e2412001     	sub	r2, r1, #1
   30660: e0010291     	mul	r1, r1, r2
   30664: e3110001     	tst	r1, #1
   30668: 0a00001c     	beq	0x306e0 <.text+0x205e0> @ imm = #0x70
   3066c: e5981000     	ldr	r1, [r8]
   30670: e3510009     	cmp	r1, #9
   30674: da000019     	ble	0x306e0 <.text+0x205e0> @ imm = #0x64
   30678: e2897d0f     	add	r7, r9, #960
   3067c: e59923cc     	ldr	r2, [r9, #0x3cc]
   30680: e8970083     	ldm	r7, {r0, r1, r7}
   30684: e59f3c50     	ldr	r3, [pc, #0xc50]        @ 0x312dc <.text+0x211dc>
   30688: e58d1014     	str	r1, [sp, #0x14]
   3068c: e3001392     	movw	r1, #0x392
   30690: e58d0010     	str	r0, [sp, #0x10]
   30694: e08f3003     	add	r3, pc, r3
   30698: e59903b4     	ldr	r0, [r9, #0x3b4]
   3069c: e58d1004     	str	r1, [sp, #0x4]
   306a0: e28d1010     	add	r1, sp, #16
   306a4: e0800007     	add	r0, r0, r7
   306a8: e58d5000     	str	r5, [sp]
   306ac: ebff85b2     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1e938
   306b0: e59903c0     	ldr	r0, [r9, #0x3c0]
   306b4: e59913c4     	ldr	r1, [r9, #0x3c4]
   306b8: e2902001     	adds	r2, r0, #1
   306bc: e58923c0     	str	r2, [r9, #0x3c0]
   306c0: e2a13000     	adc	r3, r1, #0
   306c4: e58933c4     	str	r3, [r9, #0x3c4]
   306c8: e1c600f0     	strd	r0, r1, [r6]
   306cc: e59903cc     	ldr	r0, [r9, #0x3cc]
   306d0: e5840198     	str	r0, [r4, #0x198]
   306d4: e59d000c     	ldr	r0, [sp, #0xc]
   306d8: eb15d8e6     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x576398
   306dc: eaffffc4     	b	0x305f4 <.text+0x204f4> @ imm = #-0xf0
   306e0: e3500000     	cmp	r0, #0
   306e4: 1a00000c     	bne	0x3071c <.text+0x2061c> @ imm = #0x30
   306e8: e59d000c     	ldr	r0, [sp, #0xc]
   306ec: eb15d87d     	bl	0x5a68e8 <.text+0x5967e8> @ imm = #0x5761f4
   306f0: e3500000     	cmp	r0, #0
   306f4: 1a000015     	bne	0x30750 <.text+0x20650> @ imm = #0x54
   306f8: e59a0000     	ldr	r0, [r10]
   306fc: e2401001     	sub	r1, r0, #1
   30700: e0000190     	mul	r0, r0, r1
   30704: e3100001     	tst	r0, #1
   30708: 0a000039     	beq	0x307f4 <.text+0x206f4> @ imm = #0xe4
   3070c: e5980000     	ldr	r0, [r8]
   30710: e3500009     	cmp	r0, #9
   30714: ca000053     	bgt	0x30868 <.text+0x20768> @ imm = #0x14c
   30718: ea000035     	b	0x307f4 <.text+0x206f4> @ imm = #0xd4
   3071c: eb158ab0     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562ac0
   30720: e59f2b24     	ldr	r2, [pc, #0xb24]        @ 0x3124c <.text+0x2114c>
   30724: e59f1b24     	ldr	r1, [pc, #0xb24]        @ 0x31250 <.text+0x21150>
   30728: e5900000     	ldr	r0, [r0]
   3072c: e08f2002     	add	r2, pc, r2
   30730: e59f3b1c     	ldr	r3, [pc, #0xb1c]        @ 0x31254 <.text+0x21154>
   30734: e08f1001     	add	r1, pc, r1
   30738: e58d0000     	str	r0, [sp]
   3073c: e1a00002     	mov	r0, r2
   30740: e08f3003     	add	r3, pc, r3
   30744: e300224f     	movw	r2, #0x24f
   30748: ebff7ed2     	bl	0x10298 <.text+0x198>   @ imm = #-0x204b8
   3074c: eaffffe5     	b	0x306e8 <.text+0x205e8> @ imm = #-0x6c
   30750: e59a0000     	ldr	r0, [r10]
   30754: e2401001     	sub	r1, r0, #1
   30758: e0000190     	mul	r0, r0, r1
   3075c: e3100001     	tst	r0, #1
   30760: 0a000002     	beq	0x30770 <.text+0x20670> @ imm = #0x8
   30764: e5980000     	ldr	r0, [r8]
   30768: e3500009     	cmp	r0, #9
   3076c: ca000013     	bgt	0x307c0 <.text+0x206c0> @ imm = #0x4c
   30770: eb158a9b     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562a6c
   30774: e59f2adc     	ldr	r2, [pc, #0xadc]        @ 0x31258 <.text+0x21158>
   30778: e59f1adc     	ldr	r1, [pc, #0xadc]        @ 0x3125c <.text+0x2115c>
   3077c: e5900000     	ldr	r0, [r0]
   30780: e08f2002     	add	r2, pc, r2
   30784: e59f3ad4     	ldr	r3, [pc, #0xad4]        @ 0x31260 <.text+0x21160>
   30788: e08f1001     	add	r1, pc, r1
   3078c: e58d0000     	str	r0, [sp]
   30790: e1a00002     	mov	r0, r2
   30794: e08f3003     	add	r3, pc, r3
   30798: e3002249     	movw	r2, #0x249
   3079c: ebff7ebd     	bl	0x10298 <.text+0x198>   @ imm = #-0x2050c
   307a0: e59a0000     	ldr	r0, [r10]
   307a4: e2401001     	sub	r1, r0, #1
   307a8: e0000190     	mul	r0, r0, r1
   307ac: e3100001     	tst	r0, #1
   307b0: 0affffd0     	beq	0x306f8 <.text+0x205f8> @ imm = #-0xc0
   307b4: e5980000     	ldr	r0, [r8]
   307b8: e3500009     	cmp	r0, #9
   307bc: daffffcd     	ble	0x306f8 <.text+0x205f8> @ imm = #-0xcc
   307c0: eb158a87     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562a1c
   307c4: e59f2b14     	ldr	r2, [pc, #0xb14]        @ 0x312e0 <.text+0x211e0>
   307c8: e59f1b14     	ldr	r1, [pc, #0xb14]        @ 0x312e4 <.text+0x211e4>
   307cc: e5900000     	ldr	r0, [r0]
   307d0: e08f2002     	add	r2, pc, r2
   307d4: e59f3b0c     	ldr	r3, [pc, #0xb0c]        @ 0x312e8 <.text+0x211e8>
   307d8: e08f1001     	add	r1, pc, r1
   307dc: e58d0000     	str	r0, [sp]
   307e0: e1a00002     	mov	r0, r2
   307e4: e08f3003     	add	r3, pc, r3
   307e8: e3002249     	movw	r2, #0x249
   307ec: ebff7ea9     	bl	0x10298 <.text+0x198>   @ imm = #-0x2055c
   307f0: eaffffde     	b	0x30770 <.text+0x20670> @ imm = #-0x88
   307f4: e28d607c     	add	r6, sp, #124
   307f8: e59903b4     	ldr	r0, [r9, #0x3b4]
   307fc: e59913b8     	ldr	r1, [r9, #0x3b8]
   30800: e1a02006     	mov	r2, r6
   30804: eb0361cb     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xd872c
   30808: e28d705c     	add	r7, sp, #92
   3080c: e1a00006     	mov	r0, r6
   30810: e3a01020     	mov	r1, #32
   30814: e1a02007     	mov	r2, r7
   30818: eb0361c6     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xd8718
   3081c: e59f3a40     	ldr	r3, [pc, #0xa40]        @ 0x31264 <.text+0x21164>
   30820: e28d601c     	add	r6, sp, #28
   30824: e300039b     	movw	r0, #0x39b
   30828: e1a01007     	mov	r1, r7
   3082c: e08f3003     	add	r3, pc, r3
   30830: e58d0004     	str	r0, [sp, #0x4]
   30834: e1a00006     	mov	r0, r6
   30838: e3a02020     	mov	r2, #32
   3083c: e58d5000     	str	r5, [sp]
   30840: ebff854d     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1eacc
   30844: e59a0000     	ldr	r0, [r10]
   30848: e2401001     	sub	r1, r0, #1
   3084c: e0010190     	mul	r1, r0, r1
   30850: e59903e8     	ldr	r0, [r9, #0x3e8]
   30854: e3110001     	tst	r1, #1
   30858: 0a000016     	beq	0x308b8 <.text+0x207b8> @ imm = #0x58
   3085c: e5981000     	ldr	r1, [r8]
   30860: e3510009     	cmp	r1, #9
   30864: da000013     	ble	0x308b8 <.text+0x207b8> @ imm = #0x4c
   30868: e28d607c     	add	r6, sp, #124
   3086c: e59903b4     	ldr	r0, [r9, #0x3b4]
   30870: e59913b8     	ldr	r1, [r9, #0x3b8]
   30874: e1a02006     	mov	r2, r6
   30878: eb0361ae     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xd86b8
   3087c: e28d705c     	add	r7, sp, #92
   30880: e1a00006     	mov	r0, r6
   30884: e3a01020     	mov	r1, #32
   30888: e1a02007     	mov	r2, r7
   3088c: eb0361a9     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xd86a4
   30890: e59f3a54     	ldr	r3, [pc, #0xa54]        @ 0x312ec <.text+0x211ec>
   30894: e300039b     	movw	r0, #0x39b
   30898: e58d0004     	str	r0, [sp, #0x4]
   3089c: e28d001c     	add	r0, sp, #28
   308a0: e08f3003     	add	r3, pc, r3
   308a4: e1a01007     	mov	r1, r7
   308a8: e3a02020     	mov	r2, #32
   308ac: e58d5000     	str	r5, [sp]
   308b0: ebff8531     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1eb3c
   308b4: eaffffce     	b	0x307f4 <.text+0x206f4> @ imm = #-0xc8
   308b8: e3500001     	cmp	r0, #1
   308bc: ba000036     	blt	0x3099c <.text+0x2089c> @ imm = #0xd8
   308c0: e59f29a0     	ldr	r2, [pc, #0x9a0]        @ 0x31268 <.text+0x21168>
   308c4: e79f2002     	ldr	r2, [pc, r2]
   308c8: e5920000     	ldr	r0, [r2]
   308cc: e59f3998     	ldr	r3, [pc, #0x998]        @ 0x3126c <.text+0x2116c>
   308d0: e2401001     	sub	r1, r0, #1
   308d4: e0000190     	mul	r0, r0, r1
   308d8: e79f3003     	ldr	r3, [pc, r3]
   308dc: e3100001     	tst	r0, #1
   308e0: e5920000     	ldr	r0, [r2]
   308e4: e2401001     	sub	r1, r0, #1
   308e8: e0000190     	mul	r0, r0, r1
   308ec: e3100001     	tst	r0, #1
   308f0: 0a000002     	beq	0x30900 <.text+0x20800> @ imm = #0x8
   308f4: e5930000     	ldr	r0, [r3]
   308f8: e3500009     	cmp	r0, #9
   308fc: cafffff7     	bgt	0x308e0 <.text+0x207e0> @ imm = #-0x24
   30900: e2860020     	add	r0, r6, #32
   30904: e58d0008     	str	r0, [sp, #0x8]
   30908: e59f6960     	ldr	r6, [pc, #0x960]        @ 0x31270 <.text+0x21170>
   3090c: e3a0a000     	mov	r10, #0
   30910: e59f795c     	ldr	r7, [pc, #0x95c]        @ 0x31274 <.text+0x21174>
   30914: e08f6006     	add	r6, pc, r6
   30918: e08f7007     	add	r7, pc, r7
   3091c: e59903d4     	ldr	r0, [r9, #0x3d4]
   30920: e3a02020     	mov	r2, #32
   30924: e1a03007     	mov	r3, r7
   30928: e790110a     	ldr	r1, [r0, r10, lsl #2]
   3092c: e300039d     	movw	r0, #0x39d
   30930: e58d0004     	str	r0, [sp, #0x4]
   30934: e59d0008     	ldr	r0, [sp, #0x8]
   30938: e58d6000     	str	r6, [sp]
   3093c: ebff850e     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1ebc8
   30940: e28d801c     	add	r8, sp, #28
   30944: e28d507c     	add	r5, sp, #124
   30948: e3a01040     	mov	r1, #64
   3094c: e1a00008     	mov	r0, r8
   30950: e1a02005     	mov	r2, r5
   30954: eb036177     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xd85dc
   30958: e1a00005     	mov	r0, r5
   3095c: e28d505c     	add	r5, sp, #92
   30960: e3a01020     	mov	r1, #32
   30964: e1a02005     	mov	r2, r5
   30968: eb036172     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xd85c8
   3096c: e300039f     	movw	r0, #0x39f
   30970: e1a01005     	mov	r1, r5
   30974: e58d0004     	str	r0, [sp, #0x4]
   30978: e1a00008     	mov	r0, r8
   3097c: e3a02020     	mov	r2, #32
   30980: e1a03007     	mov	r3, r7
   30984: e58d6000     	str	r6, [sp]
   30988: ebff84fb     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1ec14
   3098c: e59903e8     	ldr	r0, [r9, #0x3e8]
   30990: e28aa001     	add	r10, r10, #1
   30994: e15a0000     	cmp	r10, r0
   30998: baffffdf     	blt	0x3091c <.text+0x2081c> @ imm = #-0x84
   3099c: e59f08d4     	ldr	r0, [pc, #0x8d4]        @ 0x31278 <.text+0x21178>
   309a0: e79f0000     	ldr	r0, [pc, r0]
   309a4: e5900000     	ldr	r0, [r0]
   309a8: e59fa8cc     	ldr	r10, [pc, #0x8cc]       @ 0x3127c <.text+0x2117c>
   309ac: e2401001     	sub	r1, r0, #1
   309b0: e0000190     	mul	r0, r0, r1
   309b4: e79fa00a     	ldr	r10, [pc, r10]
   309b8: e3100001     	tst	r0, #1
   309bc: 0a000002     	beq	0x309cc <.text+0x208cc> @ imm = #0x8
   309c0: e59a0000     	ldr	r0, [r10]
   309c4: e3500009     	cmp	r0, #9
   309c8: ca00003f     	bgt	0x30acc <.text+0x209cc> @ imm = #0xfc
   309cc: e28dc01c     	add	r12, sp, #28
   309d0: e59d6038     	ldr	r6, [sp, #0x38]
   309d4: e89c10af     	ldm	r12, {r0, r1, r2, r3, r5, r7, r12}
   309d8: e6bf0f30     	rev	r0, r0
   309dc: e58d005c     	str	r0, [sp, #0x5c]
   309e0: e6bf0f31     	rev	r0, r1
   309e4: e58d0060     	str	r0, [sp, #0x60]
   309e8: e6bf0f32     	rev	r0, r2
   309ec: e59f888c     	ldr	r8, [pc, #0x88c]        @ 0x31280 <.text+0x21180>
   309f0: e58d0064     	str	r0, [sp, #0x64]
   309f4: e6bf0f33     	rev	r0, r3
   309f8: e58d0068     	str	r0, [sp, #0x68]
   309fc: e6bf0f35     	rev	r0, r5
   30a00: e58d006c     	str	r0, [sp, #0x6c]
   30a04: e6bf0f37     	rev	r0, r7
   30a08: e58d0070     	str	r0, [sp, #0x70]
   30a0c: e6bf0f3c     	rev	r0, r12
   30a10: e58d0074     	str	r0, [sp, #0x74]
   30a14: e6bf0f36     	rev	r0, r6
   30a18: e58d0078     	str	r0, [sp, #0x78]
   30a1c: e08f8008     	add	r8, pc, r8
   30a20: e59f185c     	ldr	r1, [pc, #0x85c]        @ 0x31284 <.text+0x21184>
   30a24: e30003a6     	movw	r0, #0x3a6
   30a28: e58d0004     	str	r0, [sp, #0x4]
   30a2c: e1a00004     	mov	r0, r4
   30a30: e08f1001     	add	r1, pc, r1
   30a34: e58d1000     	str	r1, [sp]
   30a38: e3a02070     	mov	r2, #112
   30a3c: e1a03008     	mov	r3, r8
   30a40: e1a05001     	mov	r5, r1
   30a44: e2891fa6     	add	r1, r9, #664
   30a48: ebff84cb     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1ecd4
   30a4c: e30003a7     	movw	r0, #0x3a7
   30a50: e28d105c     	add	r1, sp, #92
   30a54: e58d0004     	str	r0, [sp, #0x4]
   30a58: e2840024     	add	r0, r4, #36
   30a5c: e3a02020     	mov	r2, #32
   30a60: e1a03008     	mov	r3, r8
   30a64: e58d5000     	str	r5, [sp]
   30a68: ebff84c3     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1ecf4


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c33d0: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   c33d4: e28db018     	add	r11, sp, #24
   c33d8: e24dd010     	sub	sp, sp, #16
   c33dc: e59f62b8     	ldr	r6, [pc, #0x2b8]        @ 0xc369c <.text+0xb359c>
   c33e0: e1a04000     	mov	r4, r0
   c33e4: e79f6006     	ldr	r6, [pc, r6]
   c33e8: e5960000     	ldr	r0, [r6]
   c33ec: e59f72ac     	ldr	r7, [pc, #0x2ac]        @ 0xc36a0 <.text+0xb35a0>
   c33f0: e2401001     	sub	r1, r0, #1
   c33f4: e0000190     	mul	r0, r0, r1
   c33f8: e79f7007     	ldr	r7, [pc, r7]
   c33fc: e3100001     	tst	r0, #1
   c3400: 0a000002     	beq	0xc3410 <.text+0xb3310> @ imm = #0x8
   c3404: e5970000     	ldr	r0, [r7]
   c3408: e3500009     	cmp	r0, #9
   c340c: ca000010     	bgt	0xc3454 <.text+0xb3354> @ imm = #0x40
   c3410: eb00ec94     	bl	0xfe668 <.text+0xee568> @ imm = #0x3b250
   c3414: e5961000     	ldr	r1, [r6]
   c3418: e5943018     	ldr	r3, [r4, #0x18]
   c341c: e2412001     	sub	r2, r1, #1
   c3420: e1530000     	cmp	r3, r0
   c3424: e3a00000     	mov	r0, #0
   c3428: e0010291     	mul	r1, r1, r2
   c342c: b3000001     	movwlt	r0, #0x1
   c3430: e3a02000     	mov	r2, #0
   c3434: e3730001     	cmn	r3, #1
   c3438: c3002001     	movwgt	r2, #0x1
   c343c: e0020000     	and	r0, r2, r0
   c3440: e3110001     	tst	r1, #1
   c3444: 0a000004     	beq	0xc345c <.text+0xb335c> @ imm = #0x10
   c3448: e5971000     	ldr	r1, [r7]
   c344c: e3510009     	cmp	r1, #9
   c3450: da000001     	ble	0xc345c <.text+0xb335c> @ imm = #0x4
   c3454: eb00ec83     	bl	0xfe668 <.text+0xee568> @ imm = #0x3b20c
   c3458: eaffffec     	b	0xc3410 <.text+0xb3310> @ imm = #-0x50
   c345c: e3500000     	cmp	r0, #0
   c3460: 0a00002d     	beq	0xc351c <.text+0xb341c> @ imm = #0xb4
   c3464: e5960000     	ldr	r0, [r6]
   c3468: e2401001     	sub	r1, r0, #1
   c346c: e0000190     	mul	r0, r0, r1
   c3470: e3100001     	tst	r0, #1
   c3474: e5960000     	ldr	r0, [r6]
   c3478: e2401001     	sub	r1, r0, #1
   c347c: e0010190     	mul	r1, r0, r1
   c3480: e5d40318     	ldrb	r0, [r4, #0x318]
   c3484: e3110001     	tst	r1, #1
   c3488: 0a000002     	beq	0xc3498 <.text+0xb3398> @ imm = #0x8
   c348c: e5971000     	ldr	r1, [r7]
   c3490: e3510009     	cmp	r1, #9
   c3494: cafffff6     	bgt	0xc3474 <.text+0xb3374> @ imm = #-0x28
   c3498: e3a05000     	mov	r5, #0
   c349c: e3500000     	cmp	r0, #0
   c34a0: 1a00002c     	bne	0xc3558 <.text+0xb3458> @ imm = #0xb0
   c34a4: e2840e2e     	add	r0, r4, #736
   c34a8: e3a01000     	mov	r1, #0
   c34ac: eb138b0a     	bl	0x5a60dc <.text+0x595fdc> @ imm = #0x4e2c28
   c34b0: e2840fbe     	add	r0, r4, #760
   c34b4: e3a01b02     	mov	r1, #2048
   c34b8: e3a02001     	mov	r2, #1
   c34bc: e3a08001     	mov	r8, #1
   c34c0: eb00393a     	bl	0xd19b0 <.text+0xc18b0> @ imm = #0xe4e8
   c34c4: e5940018     	ldr	r0, [r4, #0x18]
   c34c8: eb00ee9b     	bl	0xfef3c <.text+0xeee3c> @ imm = #0x3ba6c
   c34cc: e1a05000     	mov	r5, r0
   c34d0: e5940018     	ldr	r0, [r4, #0x18]
   c34d4: e58402d0     	str	r0, [r4, #0x2d0]
   c34d8: e2840fae     	add	r0, r4, #696
   c34dc: e1a01005     	mov	r1, r5
   c34e0: eb00ee59     	bl	0xfee4c <.text+0xeed4c> @ imm = #0x3b964
   c34e4: e3500000     	cmp	r0, #0
   c34e8: 0a00001d     	beq	0xc3564 <.text+0xb3464> @ imm = #0x74
   c34ec: e59f01c0     	ldr	r0, [pc, #0x1c0]        @ 0xc36b4 <.text+0xb35b4>
   c34f0: e59f11c0     	ldr	r1, [pc, #0x1c0]        @ 0xc36b8 <.text+0xb35b8>
   c34f4: e59f21c0     	ldr	r2, [pc, #0x1c0]        @ 0xc36bc <.text+0xb35bc>
   c34f8: e08f0000     	add	r0, pc, r0
   c34fc: e59f31bc     	ldr	r3, [pc, #0x1bc]        @ 0xc36c0 <.text+0xb35c0>
   c3500: e08f1001     	add	r1, pc, r1
   c3504: e08f2002     	add	r2, pc, r2
   c3508: e58d8000     	str	r8, [sp]
   c350c: e08f3003     	add	r3, pc, r3
   c3510: e98d0028     	stmib	sp, {r3, r5}
   c3514: e3a03fb2     	mov	r3, #712
   c3518: ea00000c     	b	0xc3550 <.text+0xb3450> @ imm = #0x30
   c351c: e59f0180     	ldr	r0, [pc, #0x180]        @ 0xc36a4 <.text+0xb35a4>
   c3520: e2833001     	add	r3, r3, #1
   c3524: e59f117c     	ldr	r1, [pc, #0x17c]        @ 0xc36a8 <.text+0xb35a8>
   c3528: e3a06001     	mov	r6, #1
   c352c: e59f2178     	ldr	r2, [pc, #0x178]        @ 0xc36ac <.text+0xb35ac>
   c3530: e08f0000     	add	r0, pc, r0
   c3534: e59f7174     	ldr	r7, [pc, #0x174]        @ 0xc36b0 <.text+0xb35b0>
   c3538: e08f1001     	add	r1, pc, r1
   c353c: e08f2002     	add	r2, pc, r2
   c3540: e08f7007     	add	r7, pc, r7
   c3544: e88d00c0     	stm	sp, {r6, r7}
   c3548: e58d3008     	str	r3, [sp, #0x8]
   c354c: e3a03fae     	mov	r3, #696
   c3550: eb00dadb     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x36b6c
   c3554: e3e05000     	mvn	r5, #0
   c3558: e1a00005     	mov	r0, r5
   c355c: e24bd018     	sub	sp, r11, #24
   c3560: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   c3564: e5960000     	ldr	r0, [r6]
   c3568: e2401001     	sub	r1, r0, #1
   c356c: e0000190     	mul	r0, r0, r1
   c3570: e3100001     	tst	r0, #1
   c3574: 0a000002     	beq	0xc3584 <.text+0xb3484> @ imm = #0x8
   c3578: e5970000     	ldr	r0, [r7]
   c357c: e3500009     	cmp	r0, #9
   c3580: ca00000e     	bgt	0xc35c0 <.text+0xb34c0> @ imm = #0x38
   c3584: e59f2138     	ldr	r2, [pc, #0x138]        @ 0xc36c4 <.text+0xb35c4>
   c3588: e2840fc5     	add	r0, r4, #788
   c358c: e3a01000     	mov	r1, #0
   c3590: e1a03004     	mov	r3, r4
   c3594: e08f2002     	add	r2, pc, r2
   c3598: e3a05000     	mov	r5, #0
   c359c: eb13880a     	bl	0x5a55cc <.text+0x5954cc> @ imm = #0x4e2028
   c35a0: e5961000     	ldr	r1, [r6]
   c35a4: e2412001     	sub	r2, r1, #1
   c35a8: e0010291     	mul	r1, r1, r2
   c35ac: e3110001     	tst	r1, #1
   c35b0: 0a000009     	beq	0xc35dc <.text+0xb34dc> @ imm = #0x24
   c35b4: e5971000     	ldr	r1, [r7]
   c35b8: e3510009     	cmp	r1, #9
   c35bc: da000006     	ble	0xc35dc <.text+0xb34dc> @ imm = #0x18
   c35c0: e59f2110     	ldr	r2, [pc, #0x110]        @ 0xc36d8 <.text+0xb35d8>
   c35c4: e2840fc5     	add	r0, r4, #788
   c35c8: e3a01000     	mov	r1, #0
   c35cc: e1a03004     	mov	r3, r4
   c35d0: e08f2002     	add	r2, pc, r2
   c35d4: eb1387fc     	bl	0x5a55cc <.text+0x5954cc> @ imm = #0x4e1ff0
   c35d8: eaffffe9     	b	0xc3584 <.text+0xb3484> @ imm = #-0x5c
   c35dc: e3500000     	cmp	r0, #0
   c35e0: 0affffdc     	beq	0xc3558 <.text+0xb3458> @ imm = #-0x90
   c35e4: e5960000     	ldr	r0, [r6]
   c35e8: e59f80d8     	ldr	r8, [pc, #0xd8]         @ 0xc36c8 <.text+0xb35c8>
   c35ec: e2401001     	sub	r1, r0, #1
   c35f0: e08f8008     	add	r8, pc, r8
   c35f4: e0000190     	mul	r0, r0, r1
   c35f8: e3100001     	tst	r0, #1
   c35fc: 0a000002     	beq	0xc360c <.text+0xb350c> @ imm = #0x8
   c3600: e5970000     	ldr	r0, [r7]
   c3604: e3500009     	cmp	r0, #9
   c3608: ca000015     	bgt	0xc3664 <.text+0xb3564> @ imm = #0x54
   c360c: e59f00b8     	ldr	r0, [pc, #0xb8]         @ 0xc36cc <.text+0xb35cc>
   c3610: e3a05001     	mov	r5, #1
   c3614: e59f10b4     	ldr	r1, [pc, #0xb4]         @ 0xc36d0 <.text+0xb35d0>
   c3618: e59f20b4     	ldr	r2, [pc, #0xb4]         @ 0xc36d4 <.text+0xb35d4>
   c361c: e08f0000     	add	r0, pc, r0
   c3620: e5943018     	ldr	r3, [r4, #0x18]
   c3624: e08f1001     	add	r1, pc, r1
   c3628: e08f2002     	add	r2, pc, r2
   c362c: e88d0120     	stm	sp, {r5, r8}
   c3630: e2833001     	add	r3, r3, #1
   c3634: e58d3008     	str	r3, [sp, #0x8]
   c3638: e3a03e2d     	mov	r3, #720
   c363c: eb00daa0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x36a80
   c3640: e5960000     	ldr	r0, [r6]
   c3644: e3e05000     	mvn	r5, #0
   c3648: e2401001     	sub	r1, r0, #1
   c364c: e0000190     	mul	r0, r0, r1
   c3650: e3100001     	tst	r0, #1
   c3654: 0affffbf     	beq	0xc3558 <.text+0xb3458> @ imm = #-0x104
   c3658: e5970000     	ldr	r0, [r7]
   c365c: e3500009     	cmp	r0, #9
   c3660: daffffbc     	ble	0xc3558 <.text+0xb3458> @ imm = #-0x110
   c3664: e59f0070     	ldr	r0, [pc, #0x70]         @ 0xc36dc <.text+0xb35dc>
   c3668: e3a05001     	mov	r5, #1
   c366c: e59f106c     	ldr	r1, [pc, #0x6c]         @ 0xc36e0 <.text+0xb35e0>
   c3670: e59f206c     	ldr	r2, [pc, #0x6c]         @ 0xc36e4 <.text+0xb35e4>
   c3674: e08f0000     	add	r0, pc, r0
   c3678: e5943018     	ldr	r3, [r4, #0x18]
   c367c: e08f1001     	add	r1, pc, r1
   c3680: e08f2002     	add	r2, pc, r2
   c3684: e88d0120     	stm	sp, {r5, r8}
   c3688: e2833001     	add	r3, r3, #1
   c368c: e58d3008     	str	r3, [sp, #0x8]
   c3690: e3a03e2d     	mov	r3, #720
   c3694: eb00da8a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x36a28
   c3698: eaffffdb     	b	0xc360c <.text+0xb350c> @ imm = #-0x94
   c369c: 0051b90c     	subseq	r11, r1, r12, lsl #18
   c36a0: 0051bc70     	subseq	r11, r1, r0, ror r12
   c36a4: 00526121     	subseq	r6, r2, r1, lsr #2
   c36a8: 005260ee     	subseq	r6, r2, lr, ror #1
   c36ac: 0052611c     	subseq	r6, r2, r12, lsl r1
   c36b0: 00526123     	subseq	r6, r2, r3, lsr #2
   c36b4: 00526159     	subseq	r6, r2, r9, asr r1
   c36b8: 00526126     	subseq	r6, r2, r6, lsr #2
   c36bc: 00526154     	subseq	r6, r2, r4, asr r1
   c36c0: 0052616e     	subseq	r6, r2, lr, ror #2
   c36c4: 0000014c     	andeq	r0, r0, r12, asr #2
   c36c8: 005260af     	subseq	r6, r2, pc, lsr #1
   c36cc: 00526035     	subseq	r6, r2, r5, lsr r0
   c36d0: 00526002     	subseq	r6, r2, r2
   c36d4: 00526030     	subseq	r6, r2, r0, lsr r0
   c36d8: 00000110     	andeq	r0, r0, r0, lsl r1
   c36dc: 00525fdd     	ldrsbeq	r5, [r2], #-253
   c36e0: 00525faa     	subseq	r5, r2, r10, lsr #31
   c36e4: 00525fd8     	ldrsbeq	r5, [r2], #-248

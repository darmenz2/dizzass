
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c36e8: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   c36ec: e28db01c     	add	r11, sp, #28
   c36f0: e24dd00c     	sub	sp, sp, #12
   c36f4: e59f6288     	ldr	r6, [pc, #0x288]        @ 0xc3984 <.text+0xb3884>
   c36f8: e1a08000     	mov	r8, r0
   c36fc: e79f6006     	ldr	r6, [pc, r6]
   c3700: e5960000     	ldr	r0, [r6]
   c3704: e2401001     	sub	r1, r0, #1
   c3708: e0000190     	mul	r0, r0, r1
   c370c: e3100001     	tst	r0, #1
   c3710: 0a000004     	beq	0xc3728 <.text+0xb3628> @ imm = #0x10
   c3714: e59f026c     	ldr	r0, [pc, #0x26c]        @ 0xc3988 <.text+0xb3888>
   c3718: e79f0000     	ldr	r0, [pc, r0]
   c371c: e5900000     	ldr	r0, [r0]
   c3720: e3500009     	cmp	r0, #9
   c3724: ca000012     	bgt	0xc3774 <.text+0xb3674> @ imm = #0x48
   c3728: e24d5c01     	sub	r5, sp, #256
   c372c: e1a0d005     	mov	sp, r5
   c3730: e24d4040     	sub	r4, sp, #64
   c3734: e1a0d004     	mov	sp, r4
   c3738: e24d9008     	sub	r9, sp, #8
   c373c: e1a0d009     	mov	sp, r9
   c3740: eb00ea1d     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x3a874
   c3744: e1a07000     	mov	r7, r0
   c3748: eb00ea17     	bl	0xfdfac <.text+0xedeac> @ imm = #0x3a85c
   c374c: e5961000     	ldr	r1, [r6]
   c3750: e2412001     	sub	r2, r1, #1
   c3754: e0010291     	mul	r1, r1, r2
   c3758: e3110001     	tst	r1, #1
   c375c: 0a00000a     	beq	0xc378c <.text+0xb368c> @ imm = #0x28
   c3760: e59f1224     	ldr	r1, [pc, #0x224]        @ 0xc398c <.text+0xb388c>
   c3764: e79f1001     	ldr	r1, [pc, r1]
   c3768: e5911000     	ldr	r1, [r1]
   c376c: e3510009     	cmp	r1, #9
   c3770: da000005     	ble	0xc378c <.text+0xb368c> @ imm = #0x14
   c3774: e24ddc01     	sub	sp, sp, #256
   c3778: e24dd040     	sub	sp, sp, #64
   c377c: e24dd008     	sub	sp, sp, #8
   c3780: eb00ea0d     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x3a834
   c3784: eb00ea08     	bl	0xfdfac <.text+0xedeac> @ imm = #0x3a820
   c3788: eaffffe6     	b	0xc3728 <.text+0xb3628> @ imm = #-0x68
   c378c: e3a06000     	mov	r6, #0
   c3790: e3500000     	cmp	r0, #0
   c3794: 0a000005     	beq	0xc37b0 <.text+0xb36b0> @ imm = #0x14
   c3798: e3570006     	cmp	r7, #6
   c379c: 03500004     	cmpeq	r0, #4
   c37a0: 0a000002     	beq	0xc37b0 <.text+0xb36b0> @ imm = #0x8
   c37a4: e3a06002     	mov	r6, #2
   c37a8: e3570007     	cmp	r7, #7
   c37ac: 03006001     	movweq	r6, #0x1
   c37b0: e3a00009     	mov	r0, #9
   c37b4: e50b0028     	str	r0, [r11, #-0x28]
   c37b8: eb00ea3c     	bl	0xfe0b0 <.text+0xedfb0> @ imm = #0x3a8f0
   c37bc: e3500000     	cmp	r0, #0
   c37c0: 1a000005     	bne	0xc37dc <.text+0xb36dc> @ imm = #0x14
   c37c4: e3a0000b     	mov	r0, #11
   c37c8: e3560001     	cmp	r6, #1
   c37cc: 0300000a     	movweq	r0, #0xa
   c37d0: e3560000     	cmp	r6, #0
   c37d4: 03000009     	movweq	r0, #0x9
   c37d8: e50b0028     	str	r0, [r11, #-0x28]
   c37dc: e3a00001     	mov	r0, #1
   c37e0: e3a01000     	mov	r1, #0
   c37e4: e3a06001     	mov	r6, #1
   c37e8: e3a07000     	mov	r7, #0
   c37ec: eb138cce     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e3338
   c37f0: e5983018     	ldr	r3, [r8, #0x18]
   c37f4: e1a00004     	mov	r0, r4
   c37f8: e59f2190     	ldr	r2, [pc, #0x190]        @ 0xc3990 <.text+0xb3890>
   c37fc: e3a01040     	mov	r1, #64
   c3800: e08f2002     	add	r2, pc, r2
   c3804: eb136f53     	bl	0x59f558 <.text+0x58f458> @ imm = #0x4dbd4c
   c3808: e24dd008     	sub	sp, sp, #8
   c380c: e3a0000f     	mov	r0, #15
   c3810: e1a01004     	mov	r1, r4
   c3814: e3a02000     	mov	r2, #0
   c3818: e3a03000     	mov	r3, #0
   c381c: e58d7000     	str	r7, [sp]
   c3820: eb1340b4     	bl	0x593af8 <.text+0x5839f8> @ imm = #0x4d02d0
   c3824: e28dd008     	add	sp, sp, #8
   c3828: e2887fbe     	add	r7, r8, #760
   c382c: e2884e2e     	add	r4, r8, #736
   c3830: e2880fae     	add	r0, r8, #696
   c3834: e5c86318     	strb	r6, [r8, #0x318]
   c3838: e50b0024     	str	r0, [r11, #-0x24]
   c383c: ea000004     	b	0xc3854 <.text+0xb3754> @ imm = #0x10
   c3840: e1a00004     	mov	r0, r4
   c3844: eb138b9e     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e2e78
   c3848: e5d80318     	ldrb	r0, [r8, #0x318]
   c384c: e3500000     	cmp	r0, #0
   c3850: 0a000049     	beq	0xc397c <.text+0xb387c> @ imm = #0x124
   c3854: e1a00008     	mov	r0, r8
   c3858: ebfe5e3c     	bl	0x5b150 <.text+0x4b050> @ imm = #-0x68710
   c385c: e1a06000     	mov	r6, r0
   c3860: e3a00000     	mov	r0, #0
   c3864: e1a01009     	mov	r1, r9
   c3868: eb138caf     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e32bc
   c386c: e3560c01     	cmp	r6, #256
   c3870: e51b0024     	ldr	r0, [r11, #-0x24]
   c3874: 23a06c01     	movhs	r6, #256
   c3878: e1a01005     	mov	r1, r5
   c387c: e1a02006     	mov	r2, r6
   c3880: eb00eda5     	bl	0xfef1c <.text+0xeee1c> @ imm = #0x3b694
   c3884: e1a0a000     	mov	r10, r0
   c3888: e5990000     	ldr	r0, [r9]
   c388c: e3a01000     	mov	r1, #0
   c3890: eb138ca5     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e3294
   c3894: e35a0000     	cmp	r10, #0
   c3898: da00000c     	ble	0xc38d0 <.text+0xb37d0> @ imm = #0x30
   c389c: e59f60f0     	ldr	r6, [pc, #0xf0]         @ 0xc3994 <.text+0xb3894>
   c38a0: e79f6006     	ldr	r6, [pc, r6]
   c38a4: e5960000     	ldr	r0, [r6]
   c38a8: e2401001     	sub	r1, r0, #1
   c38ac: e0000190     	mul	r0, r0, r1
   c38b0: e3100001     	tst	r0, #1
   c38b4: 0a000008     	beq	0xc38dc <.text+0xb37dc> @ imm = #0x20
   c38b8: e59f00d8     	ldr	r0, [pc, #0xd8]         @ 0xc3998 <.text+0xb3898>
   c38bc: e79f0000     	ldr	r0, [pc, r0]
   c38c0: e5900000     	ldr	r0, [r0]
   c38c4: e3500009     	cmp	r0, #9
   c38c8: ca000015     	bgt	0xc3924 <.text+0xb3824> @ imm = #0x54
   c38cc: ea000002     	b	0xc38dc <.text+0xb37dc> @ imm = #0x8
   c38d0: e3a00005     	mov	r0, #5
   c38d4: eb012d98     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x4b660
   c38d8: eaffffda     	b	0xc3848 <.text+0xb3748> @ imm = #-0x98
   c38dc: e1a00004     	mov	r0, r4
   c38e0: eb138a08     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e2820
   c38e4: e1a00007     	mov	r0, r7
   c38e8: e1a01005     	mov	r1, r5
   c38ec: e1a0200a     	mov	r2, r10
   c38f0: eb0038b4     	bl	0xd1bc8 <.text+0xc1ac8> @ imm = #0xe2d0
   c38f4: e1a00007     	mov	r0, r7
   c38f8: eb0039eb     	bl	0xd20ac <.text+0xc1fac> @ imm = #0xe7ac
   c38fc: e5961000     	ldr	r1, [r6]
   c3900: e2412001     	sub	r2, r1, #1
   c3904: e0010291     	mul	r1, r1, r2
   c3908: e3110001     	tst	r1, #1
   c390c: 0a00000d     	beq	0xc3948 <.text+0xb3848> @ imm = #0x34
   c3910: e59f1084     	ldr	r1, [pc, #0x84]         @ 0xc399c <.text+0xb389c>
   c3914: e79f1001     	ldr	r1, [pc, r1]
   c3918: e5911000     	ldr	r1, [r1]
   c391c: e3510009     	cmp	r1, #9
   c3920: da000008     	ble	0xc3948 <.text+0xb3848> @ imm = #0x20
   c3924: e1a00004     	mov	r0, r4
   c3928: eb1389f6     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e27d8
   c392c: e1a00007     	mov	r0, r7
   c3930: e1a01005     	mov	r1, r5
   c3934: e1a0200a     	mov	r2, r10
   c3938: eb0038a2     	bl	0xd1bc8 <.text+0xc1ac8> @ imm = #0xe288
   c393c: e1a00007     	mov	r0, r7
   c3940: eb0039d9     	bl	0xd20ac <.text+0xc1fac> @ imm = #0xe764
   c3944: eaffffe4     	b	0xc38dc <.text+0xb37dc> @ imm = #-0x70
   c3948: e51b1028     	ldr	r1, [r11, #-0x28]
   c394c: e1500001     	cmp	r0, r1
   c3950: 3affffba     	blo	0xc3840 <.text+0xb3740> @ imm = #-0x118
   c3954: e59f6044     	ldr	r6, [pc, #0x44]         @ 0xc39a0 <.text+0xb38a0>
   c3958: e08f6006     	add	r6, pc, r6
   c395c: e1a00006     	mov	r0, r6
   c3960: eb1389e8     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e27a0
   c3964: e59f0038     	ldr	r0, [pc, #0x38]         @ 0xc39a4 <.text+0xb38a4>
   c3968: e08f0000     	add	r0, pc, r0
   c396c: eb138435     	bl	0x5a4a48 <.text+0x594948> @ imm = #0x4e10d4
   c3970: e1a00006     	mov	r0, r6
   c3974: eb138b52     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e2d48
   c3978: eaffffb0     	b	0xc3840 <.text+0xb3740> @ imm = #-0x140
   c397c: e3a00000     	mov	r0, #0
   c3980: eb138652     	bl	0x5a52d0 <.text+0x5951d0> @ imm = #0x4e1948
   c3984: 0051bea8     	subseq	r11, r1, r8, lsr #29
   c3988: 0051b8e8     	subseq	r11, r1, r8, ror #17
   c398c: 0051b89c     	<unknown>
   c3990: 00525f36     	subseq	r5, r2, r6, lsr pc
   c3994: 0051bd04     	subseq	r11, r1, r4, lsl #26
   c3998: 0051b744     	subseq	r11, r1, r4, asr #14
   c399c: 0051b6ec     	subseq	r11, r1, r12, ror #13
   c39a0: 0058fab0     	ldrheq	pc, [r8], #-160
   c39a4: 0058fab8     	ldrheq	pc, [r8], #-168
   c39a8: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   c39ac: e28db018     	add	r11, sp, #24
   c39b0: e24dd010     	sub	sp, sp, #16
   c39b4: e5905018     	ldr	r5, [r0, #0x18]
   c39b8: e3550000     	cmp	r5, #0
   c39bc: 4a000016     	bmi	0xc3a1c <.text+0xb391c> @ imm = #0x58
   c39c0: e1a04000     	mov	r4, r0
   c39c4: eb00eb27     	bl	0xfe668 <.text+0xee568> @ imm = #0x3ac9c
   c39c8: e1550000     	cmp	r5, r0
   c39cc: aa000011     	bge	0xc3a18 <.text+0xb3918> @ imm = #0x44
   c39d0: e5d40318     	ldrb	r0, [r4, #0x318]
   c39d4: e3500000     	cmp	r0, #0
   c39d8: 0a000054     	beq	0xc3b30 <.text+0xb3a30> @ imm = #0x150
   c39dc: e59f7164     	ldr	r7, [pc, #0x164]        @ 0xc3b48 <.text+0xb3a48>
   c39e0: e79f7007     	ldr	r7, [pc, r7]
   c39e4: e5970000     	ldr	r0, [r7]
   c39e8: e59f815c     	ldr	r8, [pc, #0x15c]        @ 0xc3b4c <.text+0xb3a4c>
   c39ec: e2401001     	sub	r1, r0, #1
   c39f0: e0000190     	mul	r0, r0, r1
   c39f4: e79f8008     	ldr	r8, [pc, r8]
   c39f8: e59f5150     	ldr	r5, [pc, #0x150]        @ 0xc3b50 <.text+0xb3a50>
   c39fc: e08f5005     	add	r5, pc, r5
   c3a00: e3100001     	tst	r0, #1
   c3a04: 0a000014     	beq	0xc3a5c <.text+0xb395c> @ imm = #0x50
   c3a08: e5980000     	ldr	r0, [r8]
   c3a0c: e3500009     	cmp	r0, #9
   c3a10: ca00002f     	bgt	0xc3ad4 <.text+0xb39d4> @ imm = #0xbc
   c3a14: ea000010     	b	0xc3a5c <.text+0xb395c> @ imm = #0x40
   c3a18: e5945018     	ldr	r5, [r4, #0x18]
   c3a1c: e59f0114     	ldr	r0, [pc, #0x114]        @ 0xc3b38 <.text+0xb3a38>
   c3a20: e3a06001     	mov	r6, #1
   c3a24: e59f1110     	ldr	r1, [pc, #0x110]        @ 0xc3b3c <.text+0xb3a3c>
   c3a28: e2857001     	add	r7, r5, #1
   c3a2c: e59f210c     	ldr	r2, [pc, #0x10c]        @ 0xc3b40 <.text+0xb3a40>
   c3a30: e08f0000     	add	r0, pc, r0
   c3a34: e59f3108     	ldr	r3, [pc, #0x108]        @ 0xc3b44 <.text+0xb3a44>
   c3a38: e08f1001     	add	r1, pc, r1
   c3a3c: e08f2002     	add	r2, pc, r2
   c3a40: e58d6000     	str	r6, [sp]
   c3a44: e08f3003     	add	r3, pc, r3
   c3a48: e98d0088     	stmib	sp, {r3, r7}
   c3a4c: e30032da     	movw	r3, #0x2da
   c3a50: eb00d99b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x3666c
   c3a54: e24bd018     	sub	sp, r11, #24
   c3a58: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   c3a5c: e1a00005     	mov	r0, r5
   c3a60: eb1389a8     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e26a0
   c3a64: e3a06000     	mov	r6, #0
   c3a68: e1a00005     	mov	r0, r5
   c3a6c: e5856018     	str	r6, [r5, #0x18]
   c3a70: e585601c     	str	r6, [r5, #0x1c]
   c3a74: eb138b12     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e2c48
   c3a78: e5940314     	ldr	r0, [r4, #0x314]
   c3a7c: e5c46318     	strb	r6, [r4, #0x318]
   c3a80: eb138333     	bl	0x5a4754 <.text+0x594654> @ imm = #0x4e0ccc
   c3a84: e5940314     	ldr	r0, [r4, #0x314]
   c3a88: e3a01000     	mov	r1, #0
   c3a8c: eb1388a6     	bl	0x5a5d2c <.text+0x595c2c> @ imm = #0x4e2298
   c3a90: e2846e2e     	add	r6, r4, #736
   c3a94: e1a00006     	mov	r0, r6
   c3a98: eb13899a     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e2668
   c3a9c: e2840fbe     	add	r0, r4, #760
   c3aa0: eb0039a7     	bl	0xd2144 <.text+0xc2044> @ imm = #0xe69c
   c3aa4: e1a00006     	mov	r0, r6
   c3aa8: eb138b05     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e2c14
   c3aac: e2840fae     	add	r0, r4, #696
   c3ab0: eb00ed0d     	bl	0xfeeec <.text+0xeedec> @ imm = #0x3b434
   c3ab4: e5970000     	ldr	r0, [r7]
   c3ab8: e2401001     	sub	r1, r0, #1
   c3abc: e0000190     	mul	r0, r0, r1
   c3ac0: e3100001     	tst	r0, #1
   c3ac4: 0a000019     	beq	0xc3b30 <.text+0xb3a30> @ imm = #0x64
   c3ac8: e5980000     	ldr	r0, [r8]
   c3acc: e3500009     	cmp	r0, #9
   c3ad0: da000016     	ble	0xc3b30 <.text+0xb3a30> @ imm = #0x58
   c3ad4: e1a00005     	mov	r0, r5
   c3ad8: eb13898a     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e2628
   c3adc: e3a06000     	mov	r6, #0
   c3ae0: e1a00005     	mov	r0, r5
   c3ae4: e5856018     	str	r6, [r5, #0x18]
   c3ae8: e585601c     	str	r6, [r5, #0x1c]
   c3aec: eb138af4     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e2bd0
   c3af0: e5940314     	ldr	r0, [r4, #0x314]
   c3af4: e5c46318     	strb	r6, [r4, #0x318]
   c3af8: eb138315     	bl	0x5a4754 <.text+0x594654> @ imm = #0x4e0c54
   c3afc: e5940314     	ldr	r0, [r4, #0x314]
   c3b00: e3a01000     	mov	r1, #0
   c3b04: eb138888     	bl	0x5a5d2c <.text+0x595c2c> @ imm = #0x4e2220
   c3b08: e2846e2e     	add	r6, r4, #736
   c3b0c: e1a00006     	mov	r0, r6
   c3b10: eb13897c     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e25f0
   c3b14: e2840fbe     	add	r0, r4, #760
   c3b18: eb003989     	bl	0xd2144 <.text+0xc2044> @ imm = #0xe624
   c3b1c: e1a00006     	mov	r0, r6
   c3b20: eb138ae7     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e2b9c
   c3b24: e2840fae     	add	r0, r4, #696
   c3b28: eb00ecef     	bl	0xfeeec <.text+0xeedec> @ imm = #0x3b3bc
   c3b2c: eaffffca     	b	0xc3a5c <.text+0xb395c> @ imm = #-0xd8
   c3b30: e24bd018     	sub	sp, r11, #24
   c3b34: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   c3b38: 00525c21     	subseq	r5, r2, r1, lsr #24
   c3b3c: 00525bee     	subseq	r5, r2, lr, ror #23
   c3b40: 00525c1c     	subseq	r5, r2, r12, lsl r12
   c3b44: 00525c1f     	subseq	r5, r2, pc, lsl r12
   c3b48: 0051ad68     	subseq	r10, r1, r8, ror #26
   c3b4c: 0051c108     	subseq	r12, r1, r8, lsl #2
   c3b50: 005701ec     	subseq	r0, r7, r12, ror #3
   c3b54: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   c3b58: e28db018     	add	r11, sp, #24
   c3b5c: e24dd010     	sub	sp, sp, #16
   c3b60: e28d500c     	add	r5, sp, #12
   c3b64: e1a04000     	mov	r4, r0
   c3b68: e1a00005     	mov	r0, r5
   c3b6c: eb13855d     	bl	0x5a50e8 <.text+0x594fe8> @ imm = #0x4e1574
   c3b70: e1a00005     	mov	r0, r5
   c3b74: e3a01001     	mov	r1, #1
   c3b78: eb13855e     	bl	0x5a50f8 <.text+0x594ff8> @ imm = #0x4e1578
   c3b7c: e59f0230     	ldr	r0, [pc, #0x230]        @ 0xc3db4 <.text+0xb3cb4>
   c3b80: e3a01000     	mov	r1, #0
   c3b84: e08f0000     	add	r0, pc, r0
   c3b88: eb138953     	bl	0x5a60dc <.text+0x595fdc> @ imm = #0x4e254c
   c3b8c: e59f0224     	ldr	r0, [pc, #0x224]        @ 0xc3db8 <.text+0xb3cb8>
   c3b90: e1a01005     	mov	r1, r5
   c3b94: e08f0000     	add	r0, pc, r0
   c3b98: eb13839a     	bl	0x5a4a08 <.text+0x594908> @ imm = #0x4e0e68
   c3b9c: e59f0218     	ldr	r0, [pc, #0x218]        @ 0xc3dbc <.text+0xb3cbc>
   c3ba0: e3a01000     	mov	r1, #0
   c3ba4: e08f0000     	add	r0, pc, r0
   c3ba8: eb13894b     	bl	0x5a60dc <.text+0x595fdc> @ imm = #0x4e252c
   c3bac: e59f020c     	ldr	r0, [pc, #0x20c]        @ 0xc3dc0 <.text+0xb3cc0>
   c3bb0: e1a01005     	mov	r1, r5
   c3bb4: e08f0000     	add	r0, pc, r0
   c3bb8: eb138392     	bl	0x5a4a08 <.text+0x594908> @ imm = #0x4e0e48
   c3bbc: e1a00005     	mov	r0, r5
   c3bc0: eb138546     	bl	0x5a50e0 <.text+0x594fe0> @ imm = #0x4e1518
   c3bc4: e59f21f8     	ldr	r2, [pc, #0x1f8]        @ 0xc3dc4 <.text+0xb3cc4>
   c3bc8: e3010060     	movw	r0, #0x1060
   c3bcc: e0840000     	add	r0, r4, r0
   c3bd0: e3a01000     	mov	r1, #0
   c3bd4: e08f2002     	add	r2, pc, r2
   c3bd8: e1a03004     	mov	r3, r4
   c3bdc: eb13867a     	bl	0x5a55cc <.text+0x5954cc> @ imm = #0x4e19e8
   c3be0: e3500000     	cmp	r0, #0
   c3be4: 0a00000e     	beq	0xc3c24 <.text+0xb3b24> @ imm = #0x38
   c3be8: e59f41d8     	ldr	r4, [pc, #0x1d8]        @ 0xc3dc8 <.text+0xb3cc8>
   c3bec: e79f4004     	ldr	r4, [pc, r4]
   c3bf0: e5940000     	ldr	r0, [r4]
   c3bf4: e59f61d0     	ldr	r6, [pc, #0x1d0]        @ 0xc3dcc <.text+0xb3ccc>
   c3bf8: e2401001     	sub	r1, r0, #1
   c3bfc: e0000190     	mul	r0, r0, r1
   c3c00: e79f6006     	ldr	r6, [pc, r6]
   c3c04: e59f71c4     	ldr	r7, [pc, #0x1c4]        @ 0xc3dd0 <.text+0xb3cd0>
   c3c08: e08f7007     	add	r7, pc, r7
   c3c0c: e3100001     	tst	r0, #1
   c3c10: 0a000046     	beq	0xc3d30 <.text+0xb3c30> @ imm = #0x118
   c3c14: e5960000     	ldr	r0, [r6]
   c3c18: e3500009     	cmp	r0, #9
   c3c1c: ca000056     	bgt	0xc3d7c <.text+0xb3c7c> @ imm = #0x158
   c3c20: ea000042     	b	0xc3d30 <.text+0xb3c30> @ imm = #0x108
   c3c24: e59f21c0     	ldr	r2, [pc, #0x1c0]        @ 0xc3dec <.text+0xb3cec>
   c3c28: e3010068     	movw	r0, #0x1068
   c3c2c: e0840000     	add	r0, r4, r0
   c3c30: e3a01000     	mov	r1, #0
   c3c34: e1a03004     	mov	r3, r4
   c3c38: e3a05000     	mov	r5, #0
   c3c3c: e79f2002     	ldr	r2, [pc, r2]
   c3c40: eb138661     	bl	0x5a55cc <.text+0x5954cc> @ imm = #0x4e1984
   c3c44: e3500000     	cmp	r0, #0
   c3c48: 0a000018     	beq	0xc3cb0 <.text+0xb3bb0> @ imm = #0x60
   c3c4c: e59f419c     	ldr	r4, [pc, #0x19c]        @ 0xc3df0 <.text+0xb3cf0>
   c3c50: e3a07001     	mov	r7, #1
   c3c54: e59f5198     	ldr	r5, [pc, #0x198]        @ 0xc3df4 <.text+0xb3cf4>
   c3c58: e3a03fc2     	mov	r3, #776
   c3c5c: e59f6194     	ldr	r6, [pc, #0x194]        @ 0xc3df8 <.text+0xb3cf8>
   c3c60: e08f4004     	add	r4, pc, r4
   c3c64: e59f0190     	ldr	r0, [pc, #0x190]        @ 0xc3dfc <.text+0xb3cfc>
   c3c68: e08f5005     	add	r5, pc, r5
   c3c6c: e08f6006     	add	r6, pc, r6
   c3c70: e58d7000     	str	r7, [sp]
   c3c74: e08f0000     	add	r0, pc, r0
   c3c78: e58d0004     	str	r0, [sp, #0x4]
   c3c7c: e1a00004     	mov	r0, r4
   c3c80: e1a01005     	mov	r1, r5
   c3c84: e1a02006     	mov	r2, r6
   c3c88: eb00d90d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x36434
   c3c8c: e59f016c     	ldr	r0, [pc, #0x16c]        @ 0xc3e00 <.text+0xb3d00>
   c3c90: e1a01005     	mov	r1, r5
   c3c94: e58d7000     	str	r7, [sp]
   c3c98: e1a02006     	mov	r2, r6
   c3c9c: e08f0000     	add	r0, pc, r0
   c3ca0: e58d0004     	str	r0, [sp, #0x4]
   c3ca4: e1a00004     	mov	r0, r4
   c3ca8: e3003322     	movw	r3, #0x322
   c3cac: ea00001c     	b	0xc3d24 <.text+0xb3c24> @ imm = #0x70
   c3cb0: e59f214c     	ldr	r2, [pc, #0x14c]        @ 0xc3e04 <.text+0xb3d04>
   c3cb4: e3010058     	movw	r0, #0x1058
   c3cb8: e0840000     	add	r0, r4, r0
   c3cbc: e3a01000     	mov	r1, #0
   c3cc0: e08f2002     	add	r2, pc, r2
   c3cc4: e1a03004     	mov	r3, r4
   c3cc8: eb13863f     	bl	0x5a55cc <.text+0x5954cc> @ imm = #0x4e18fc
   c3ccc: e3500000     	cmp	r0, #0
   c3cd0: 0a000034     	beq	0xc3da8 <.text+0xb3ca8> @ imm = #0xd0
   c3cd4: e59f812c     	ldr	r8, [pc, #0x12c]        @ 0xc3e08 <.text+0xb3d08>
   c3cd8: e3a04001     	mov	r4, #1
   c3cdc: e59f5128     	ldr	r5, [pc, #0x128]        @ 0xc3e0c <.text+0xb3d0c>
   c3ce0: e3003291     	movw	r3, #0x291
   c3ce4: e59f6124     	ldr	r6, [pc, #0x124]        @ 0xc3e10 <.text+0xb3d10>
   c3ce8: e08f8008     	add	r8, pc, r8
   c3cec: e08f5005     	add	r5, pc, r5
   c3cf0: e59f711c     	ldr	r7, [pc, #0x11c]        @ 0xc3e14 <.text+0xb3d14>
   c3cf4: e08f6006     	add	r6, pc, r6
   c3cf8: e1a00008     	mov	r0, r8
   c3cfc: e1a01005     	mov	r1, r5
   c3d00: e08f7007     	add	r7, pc, r7
   c3d04: e1a02006     	mov	r2, r6
   c3d08: e88d0090     	stm	sp, {r4, r7}
   c3d0c: eb00d8ec     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x363b0
   c3d10: e1a00008     	mov	r0, r8
   c3d14: e1a01005     	mov	r1, r5
   c3d18: e1a02006     	mov	r2, r6
   c3d1c: e3003327     	movw	r3, #0x327
   c3d20: e88d0090     	stm	sp, {r4, r7}
   c3d24: eb00d8e6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x36398
   c3d28: e3e05000     	mvn	r5, #0
   c3d2c: ea00001d     	b	0xc3da8 <.text+0xb3ca8> @ imm = #0x74
   c3d30: e59f009c     	ldr	r0, [pc, #0x9c]         @ 0xc3dd4 <.text+0xb3cd4>
   c3d34: e3a03001     	mov	r3, #1
   c3d38: e59f1098     	ldr	r1, [pc, #0x98]         @ 0xc3dd8 <.text+0xb3cd8>
   c3d3c: e59f2098     	ldr	r2, [pc, #0x98]         @ 0xc3ddc <.text+0xb3cdc>
   c3d40: e08f0000     	add	r0, pc, r0
   c3d44: e08f1001     	add	r1, pc, r1
   c3d48: e88d0088     	stm	sp, {r3, r7}
   c3d4c: e08f2002     	add	r2, pc, r2
   c3d50: e300331d     	movw	r3, #0x31d
   c3d54: eb00d8da     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x36368
   c3d58: e5940000     	ldr	r0, [r4]
   c3d5c: e3e05000     	mvn	r5, #0
   c3d60: e2401001     	sub	r1, r0, #1
   c3d64: e0000190     	mul	r0, r0, r1
   c3d68: e3100001     	tst	r0, #1
   c3d6c: 0a00000d     	beq	0xc3da8 <.text+0xb3ca8> @ imm = #0x34
   c3d70: e5960000     	ldr	r0, [r6]
   c3d74: e350000a     	cmp	r0, #10
   c3d78: ba00000a     	blt	0xc3da8 <.text+0xb3ca8> @ imm = #0x28
   c3d7c: e59f005c     	ldr	r0, [pc, #0x5c]         @ 0xc3de0 <.text+0xb3ce0>
   c3d80: e3a03001     	mov	r3, #1
   c3d84: e59f1058     	ldr	r1, [pc, #0x58]         @ 0xc3de4 <.text+0xb3ce4>
   c3d88: e59f2058     	ldr	r2, [pc, #0x58]         @ 0xc3de8 <.text+0xb3ce8>
   c3d8c: e08f0000     	add	r0, pc, r0
   c3d90: e08f1001     	add	r1, pc, r1
   c3d94: e88d0088     	stm	sp, {r3, r7}
   c3d98: e08f2002     	add	r2, pc, r2
   c3d9c: e300331d     	movw	r3, #0x31d
   c3da0: eb00d8c7     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x3631c
   c3da4: eaffffe1     	b	0xc3d30 <.text+0xb3c30> @ imm = #-0x7c
   c3da8: e1a00005     	mov	r0, r5
   c3dac: e24bd018     	sub	sp, r11, #24
   c3db0: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   c3db4: 0056ff64     	subseq	pc, r6, r4, ror #30
   c3db8: 0056ff6c     	subseq	pc, r6, r12, ror #30
   c3dbc: 0056fffc     	ldrsheq	pc, [r6], #-252
   c3dc0: 00570004     	subseq	r0, r7, r4
   c3dc4: 00000478     	andeq	r0, r0, r8, ror r4
   c3dc8: 0051b874     	subseq	r11, r1, r4, ror r8
   c3dcc: 0051b2b8     	ldrheq	r11, [r1], #-40
   c3dd0: 00525ac3     	subseq	r5, r2, r3, asr #21
   c3dd4: 00525911     	subseq	r5, r2, r1, lsl r9
   c3dd8: 005258e2     	subseq	r5, r2, r2, ror #17
   c3ddc: 0052590c     	subseq	r5, r2, r12, lsl #18
   c3de0: 005258c5     	subseq	r5, r2, r5, asr #17
   c3de4: 00525896     	<unknown>
   c3de8: 005258c0     	subseq	r5, r2, r0, asr #17
   c3dec: 0051bd34     	subseq	r11, r1, r4, lsr sp
   c3df0: 005259f1     	ldrsheq	r5, [r2], #-145
   c3df4: 005259be     	ldrheq	r5, [r2], #-158
   c3df8: 005259ec     	subseq	r5, r2, r12, ror #19
   c3dfc: 00525adc     	ldrsbeq	r5, [r2], #-172
   c3e00: 00525a59     	subseq	r5, r2, r9, asr r10
   c3e04: 00000e50     	andeq	r0, r0, r0, asr lr
   c3e08: 00525969     	subseq	r5, r2, r9, ror #18
   c3e0c: 0052593a     	subseq	r5, r2, r10, lsr r9
   c3e10: 00525964     	subseq	r5, r2, r4, ror #18
   c3e14: 00525a15     	subseq	r5, r2, r5, lsl r10
   c3e18: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   c3e1c: e28db018     	add	r11, sp, #24
   c3e20: e59f6210     	ldr	r6, [pc, #0x210]        @ 0xc4038 <.text+0xb3f38>
   c3e24: e1a08000     	mov	r8, r0
   c3e28: e79f6006     	ldr	r6, [pc, r6]
   c3e2c: e5960000     	ldr	r0, [r6]
   c3e30: e59f7204     	ldr	r7, [pc, #0x204]        @ 0xc403c <.text+0xb3f3c>
   c3e34: e2401001     	sub	r1, r0, #1
   c3e38: e0000190     	mul	r0, r0, r1
   c3e3c: e79f7007     	ldr	r7, [pc, r7]
   c3e40: e3011058     	movw	r1, #0x1058
   c3e44: e0884001     	add	r4, r8, r1
   c3e48: e3100001     	tst	r0, #1
   c3e4c: 0a000002     	beq	0xc3e5c <.text+0xb3d5c> @ imm = #0x8
   c3e50: e5970000     	ldr	r0, [r7]
   c3e54: e3500009     	cmp	r0, #9
   c3e58: ca00000a     	bgt	0xc3e88 <.text+0xb3d88> @ imm = #0x28
   c3e5c: eb00ea01     	bl	0xfe668 <.text+0xee568> @ imm = #0x3a804
   c3e60: e1a05000     	mov	r5, r0
   c3e64: e5960000     	ldr	r0, [r6]
   c3e68: e2401001     	sub	r1, r0, #1
   c3e6c: e0010190     	mul	r1, r0, r1
   c3e70: e5d40014     	ldrb	r0, [r4, #0x14]
   c3e74: e3110001     	tst	r1, #1
   c3e78: 0a000004     	beq	0xc3e90 <.text+0xb3d90> @ imm = #0x10
   c3e7c: e5971000     	ldr	r1, [r7]
   c3e80: e3510009     	cmp	r1, #9
   c3e84: da000001     	ble	0xc3e90 <.text+0xb3d90> @ imm = #0x4
   c3e88: eb00e9f6     	bl	0xfe668 <.text+0xee568> @ imm = #0x3a7d8
   c3e8c: eafffff2     	b	0xc3e5c <.text+0xb3d5c> @ imm = #-0x38
   c3e90: e3500000     	cmp	r0, #0
   c3e94: 0a00001e     	beq	0xc3f14 <.text+0xb3e14> @ imm = #0x78
   c3e98: e5960000     	ldr	r0, [r6]
   c3e9c: e2401001     	sub	r1, r0, #1
   c3ea0: e0000190     	mul	r0, r0, r1
   c3ea4: e3100001     	tst	r0, #1
   c3ea8: 0a000002     	beq	0xc3eb8 <.text+0xb3db8> @ imm = #0x8
   c3eac: e5970000     	ldr	r0, [r7]
   c3eb0: e3500009     	cmp	r0, #9
   c3eb4: ca00000e     	bgt	0xc3ef4 <.text+0xb3df4> @ imm = #0x38
   c3eb8: e5940010     	ldr	r0, [r4, #0x10]
   c3ebc: e3a01000     	mov	r1, #0
   c3ec0: e5c41014     	strb	r1, [r4, #0x14]
   c3ec4: eb138222     	bl	0x5a4754 <.text+0x594654> @ imm = #0x4e0888
   c3ec8: e5940010     	ldr	r0, [r4, #0x10]
   c3ecc: e3a01000     	mov	r1, #0
   c3ed0: eb138795     	bl	0x5a5d2c <.text+0x595c2c> @ imm = #0x4e1e54
   c3ed4: e5960000     	ldr	r0, [r6]
   c3ed8: e2401001     	sub	r1, r0, #1
   c3edc: e0000190     	mul	r0, r0, r1
   c3ee0: e3100001     	tst	r0, #1
   c3ee4: 0a00000a     	beq	0xc3f14 <.text+0xb3e14> @ imm = #0x28
   c3ee8: e5970000     	ldr	r0, [r7]
   c3eec: e3500009     	cmp	r0, #9
   c3ef0: da000007     	ble	0xc3f14 <.text+0xb3e14> @ imm = #0x1c
   c3ef4: e5940010     	ldr	r0, [r4, #0x10]
   c3ef8: e3a01000     	mov	r1, #0
   c3efc: e5c41014     	strb	r1, [r4, #0x14]
   c3f00: eb138213     	bl	0x5a4754 <.text+0x594654> @ imm = #0x4e084c
   c3f04: e5940010     	ldr	r0, [r4, #0x10]
   c3f08: e3a01000     	mov	r1, #0
   c3f0c: eb138786     	bl	0x5a5d2c <.text+0x595c2c> @ imm = #0x4e1e18
   c3f10: eaffffe8     	b	0xc3eb8 <.text+0xb3db8> @ imm = #-0x60
   c3f14: e5d4000c     	ldrb	r0, [r4, #0xc]
   c3f18: e3500000     	cmp	r0, #0
   c3f1c: 0a000006     	beq	0xc3f3c <.text+0xb3e3c> @ imm = #0x18
   c3f20: e5940008     	ldr	r0, [r4, #0x8]
   c3f24: e3a01000     	mov	r1, #0
   c3f28: e5c4100c     	strb	r1, [r4, #0xc]
   c3f2c: eb138208     	bl	0x5a4754 <.text+0x594654> @ imm = #0x4e0820
   c3f30: e5940008     	ldr	r0, [r4, #0x8]
   c3f34: e3a01000     	mov	r1, #0
   c3f38: eb13877b     	bl	0x5a5d2c <.text+0x595c2c> @ imm = #0x4e1dec
   c3f3c: e5960000     	ldr	r0, [r6]
   c3f40: e2401001     	sub	r1, r0, #1
   c3f44: e0000190     	mul	r0, r0, r1
   c3f48: e3100001     	tst	r0, #1
   c3f4c: e5960000     	ldr	r0, [r6]
   c3f50: e2401001     	sub	r1, r0, #1
   c3f54: e0010190     	mul	r1, r0, r1
   c3f58: e5d40004     	ldrb	r0, [r4, #0x4]
   c3f5c: e3110001     	tst	r1, #1
   c3f60: 0a000002     	beq	0xc3f70 <.text+0xb3e70> @ imm = #0x8
   c3f64: e5971000     	ldr	r1, [r7]
   c3f68: e3510009     	cmp	r1, #9
   c3f6c: cafffff6     	bgt	0xc3f4c <.text+0xb3e4c> @ imm = #-0x28
   c3f70: e3500000     	cmp	r0, #0
   c3f74: 0a000006     	beq	0xc3f94 <.text+0xb3e94> @ imm = #0x18
   c3f78: e5940000     	ldr	r0, [r4]
   c3f7c: e3a01000     	mov	r1, #0
   c3f80: e5c41004     	strb	r1, [r4, #0x4]
   c3f84: eb1381f2     	bl	0x5a4754 <.text+0x594654> @ imm = #0x4e07c8
   c3f88: e5940000     	ldr	r0, [r4]
   c3f8c: e3a01000     	mov	r1, #0
   c3f90: eb138765     	bl	0x5a5d2c <.text+0x595c2c> @ imm = #0x4e1d94
   c3f94: e59f00a4     	ldr	r0, [pc, #0xa4]         @ 0xc4040 <.text+0xb3f40>
   c3f98: e08f0000     	add	r0, pc, r0
   c3f9c: eb13826c     	bl	0x5a4954 <.text+0x594854> @ imm = #0x4e09b0
   c3fa0: e59f009c     	ldr	r0, [pc, #0x9c]         @ 0xc4044 <.text+0xb3f44>
   c3fa4: e08f0000     	add	r0, pc, r0
   c3fa8: eb138842     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x4e2108
   c3fac: e59f0094     	ldr	r0, [pc, #0x94]         @ 0xc4048 <.text+0xb3f48>
   c3fb0: e08f0000     	add	r0, pc, r0
   c3fb4: eb138266     	bl	0x5a4954 <.text+0x594854> @ imm = #0x4e0998
   c3fb8: e59f008c     	ldr	r0, [pc, #0x8c]         @ 0xc404c <.text+0xb3f4c>
   c3fbc: e08f0000     	add	r0, pc, r0
   c3fc0: eb13883c     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x4e20f0
   c3fc4: e3550001     	cmp	r5, #1
   c3fc8: ba000018     	blt	0xc4030 <.text+0xb3f30> @ imm = #0x60
   c3fcc: e5960000     	ldr	r0, [r6]
   c3fd0: e2401001     	sub	r1, r0, #1
   c3fd4: e0000190     	mul	r0, r0, r1
   c3fd8: e3100001     	tst	r0, #1
   c3fdc: e5960000     	ldr	r0, [r6]
   c3fe0: e2401001     	sub	r1, r0, #1
   c3fe4: e0000190     	mul	r0, r0, r1
   c3fe8: e3100001     	tst	r0, #1
   c3fec: 0a000002     	beq	0xc3ffc <.text+0xb3efc> @ imm = #0x8
   c3ff0: e5970000     	ldr	r0, [r7]
   c3ff4: e3500009     	cmp	r0, #9
   c3ff8: cafffff7     	bgt	0xc3fdc <.text+0xb3edc> @ imm = #-0x24
   c3ffc: e3a04000     	mov	r4, #0
   c4000: ea000002     	b	0xc4010 <.text+0xb3f10> @ imm = #0x8
   c4004: e2844e32     	add	r4, r4, #800
   c4008: e2555001     	subs	r5, r5, #1
   c400c: 0a000007     	beq	0xc4030 <.text+0xb3f30> @ imm = #0x1c
   c4010: e5980230     	ldr	r0, [r8, #0x230]
   c4014: e0800004     	add	r0, r0, r4
   c4018: e5d01318     	ldrb	r1, [r0, #0x318]
   c401c: e3510000     	cmp	r1, #0
   c4020: 0afffff7     	beq	0xc4004 <.text+0xb3f04> @ imm = #-0x24
   c4024: e5981200     	ldr	r1, [r8, #0x200]
   c4028: e12fff31     	blx	r1
   c402c: eafffff4     	b	0xc4004 <.text+0xb3f04> @ imm = #-0x30
   c4030: e3a00000     	mov	r0, #0
   c4034: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   c4038: 0051a9bc     	ldrheq	r10, [r1], #-156
   c403c: 0051bd4c     	subseq	r11, r1, r12, asr #26
   c4040: 0056fc20     	subseq	pc, r6, r0, lsr #24
   c4044: 0056fbfc     	ldrsheq	pc, [r6], #-188
   c4048: 0056fb50     	subseq	pc, r6, r0, asr r11
   c404c: 0056fb2c     	subseq	pc, r6, r12, lsr #22
   c4050: e12fff1e     	bx	lr
   c4054: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   c4058: e28db01c     	add	r11, sp, #28
   c405c: e24ddf77     	sub	sp, sp, #476
   c4060: e1a09000     	mov	r9, r0
   c4064: eb00e97f     	bl	0xfe668 <.text+0xee568> @ imm = #0x3a5fc
   c4068: e1a04000     	mov	r4, r0
   c406c: eb00e7d2     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x39f48
   c4070: e1a06000     	mov	r6, r0
   c4074: e3a00000     	mov	r0, #0
   c4078: e58d004c     	str	r0, [sp, #0x4c]
   c407c: eb00e7ca     	bl	0xfdfac <.text+0xedeac> @ imm = #0x39f28
   c4080: e3500000     	cmp	r0, #0
   c4084: 0a000006     	beq	0xc40a4 <.text+0xb3fa4> @ imm = #0x18
   c4088: e3560006     	cmp	r6, #6
   c408c: 03500004     	cmpeq	r0, #4
   c4090: 0a000003     	beq	0xc40a4 <.text+0xb3fa4> @ imm = #0xc
   c4094: e3a00002     	mov	r0, #2
   c4098: e3560007     	cmp	r6, #7
   c409c: 03000001     	movweq	r0, #0x1
   c40a0: e58d004c     	str	r0, [sp, #0x4c]
   c40a4: e58d4038     	str	r4, [sp, #0x38]
   c40a8: e3a07009     	mov	r7, #9
   c40ac: eb00e7ff     	bl	0xfe0b0 <.text+0xedfb0> @ imm = #0x39ffc
   c40b0: e3500000     	cmp	r0, #0
   c40b4: e3a00009     	mov	r0, #9
   c40b8: e58d0054     	str	r0, [sp, #0x54]
   c40bc: 1a000006     	bne	0xc40dc <.text+0xb3fdc> @ imm = #0x18
   c40c0: e59d004c     	ldr	r0, [sp, #0x4c]
   c40c4: e3a0100b     	mov	r1, #11
   c40c8: e3500001     	cmp	r0, #1
   c40cc: 0300100a     	movweq	r1, #0xa
   c40d0: e3500000     	cmp	r0, #0
   c40d4: 03001009     	movweq	r1, #0x9
   c40d8: e58d1054     	str	r1, [sp, #0x54]
   c40dc: eb00e7b6     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x39ed8
   c40e0: e1a06000     	mov	r6, r0
   c40e4: e3a00001     	mov	r0, #1
   c40e8: e3a01000     	mov	r1, #0
   c40ec: e3a08001     	mov	r8, #1
   c40f0: e3a04000     	mov	r4, #0
   c40f4: eb138a8c     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e2a30
   c40f8: e59f19a8     	ldr	r1, [pc, #0x9a8]        @ 0xc4aa8 <.text+0xb49a8>
   c40fc: e3a0000f     	mov	r0, #15
   c4100: e3a02000     	mov	r2, #0
   c4104: e3a03000     	mov	r3, #0
   c4108: e08f1001     	add	r1, pc, r1
   c410c: e58d4000     	str	r4, [sp]
   c4110: eb133e78     	bl	0x593af8 <.text+0x5839f8> @ imm = #0x4cf9e0
   c4114: e3010064     	movw	r0, #0x1064
   c4118: e1a01009     	mov	r1, r9
   c411c: e7e18000     	strb	r8, [r1, r0]!
   c4120: e24b8068     	sub	r8, r11, #104
   c4124: e59d004c     	ldr	r0, [sp, #0x4c]
   c4128: e58d1044     	str	r1, [sp, #0x44]
   c412c: e3500001     	cmp	r0, #1
   c4130: 03007008     	movweq	r7, #0x8
   c4134: e3500000     	cmp	r0, #0
   c4138: e28d0058     	add	r0, sp, #88
   c413c: 03007007     	movweq	r7, #0x7
   c4140: e2800088     	add	r0, r0, #136
   c4144: e58d000c     	str	r0, [sp, #0xc]
   c4148: e24b00f8     	sub	r0, r11, #248
   c414c: e2801024     	add	r1, r0, #36
   c4150: e2800018     	add	r0, r0, #24
   c4154: e58d0004     	str	r0, [sp, #0x4]
   c4158: e3880001     	orr	r0, r8, #1
   c415c: e58d0030     	str	r0, [sp, #0x30]
   c4160: e2880008     	add	r0, r8, #8
   c4164: e58d0034     	str	r0, [sp, #0x34]
   c4168: e3880006     	orr	r0, r8, #6
   c416c: e58d0048     	str	r0, [sp, #0x48]
   c4170: e3880007     	orr	r0, r8, #7
   c4174: e58d003c     	str	r0, [sp, #0x3c]
   c4178: e3860001     	orr	r0, r6, #1
   c417c: e58d1008     	str	r1, [sp, #0x8]
   c4180: e58d0010     	str	r0, [sp, #0x10]
   c4184: e59fa920     	ldr	r10, [pc, #0x920]       @ 0xc4aac <.text+0xb49ac>
   c4188: e79fa00a     	ldr	r10, [pc, r10]
   c418c: e59f591c     	ldr	r5, [pc, #0x91c]        @ 0xc4ab0 <.text+0xb49b0>
   c4190: e79f5005     	ldr	r5, [pc, r5]
   c4194: e59d4038     	ldr	r4, [sp, #0x38]
   c4198: e58d7040     	str	r7, [sp, #0x40]
   c419c: e3540001     	cmp	r4, #1
   c41a0: aa000015     	bge	0xc41fc <.text+0xb40fc> @ imm = #0x54
   c41a4: e59f6964     	ldr	r6, [pc, #0x964]        @ 0xc4b10 <.text+0xb4a10>
   c41a8: e08f6006     	add	r6, pc, r6
   c41ac: e1a00006     	mov	r0, r6
   c41b0: eb1387d4     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e1f50
   c41b4: e24b1024     	sub	r1, r11, #36
   c41b8: e3a00000     	mov	r0, #0
   c41bc: eb138a5a     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e2968
   c41c0: e59f094c     	ldr	r0, [pc, #0x94c]        @ 0xc4b14 <.text+0xb4a14>
   c41c4: e1a01006     	mov	r1, r6
   c41c8: e08f0000     	add	r0, pc, r0
   c41cc: eb1383c1     	bl	0x5a50d8 <.text+0x594fd8> @ imm = #0x4e0f04
   c41d0: e51b0024     	ldr	r0, [r11, #-0x24]
   c41d4: e3a01000     	mov	r1, #0
   c41d8: eb138a53     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e294c
   c41dc: e1a00006     	mov	r0, r6
   c41e0: eb138937     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e24dc
   c41e4: e59d0044     	ldr	r0, [sp, #0x44]
   c41e8: e5d00000     	ldrb	r0, [r0]
   c41ec: e3500000     	cmp	r0, #0
   c41f0: 0a000229     	beq	0xc4a9c <.text+0xb499c> @ imm = #0x8a4
   c41f4: e3540001     	cmp	r4, #1
   c41f8: baffffe9     	blt	0xc41a4 <.text+0xb40a4> @ imm = #-0x5c
   c41fc: e3a00000     	mov	r0, #0
   c4200: e3a07fc6     	mov	r7, #792
   c4204: e58d0050     	str	r0, [sp, #0x50]
   c4208: ea000002     	b	0xc4218 <.text+0xb4118> @ imm = #0x8
   c420c: e2877e32     	add	r7, r7, #800
   c4210: e2544001     	subs	r4, r4, #1
   c4214: 0a00021b     	beq	0xc4a88 <.text+0xb4988> @ imm = #0x86c
   c4218: e59a0000     	ldr	r0, [r10]
   c421c: e2401001     	sub	r1, r0, #1
   c4220: e0000190     	mul	r0, r0, r1
   c4224: e3100001     	tst	r0, #1
   c4228: 0a000002     	beq	0xc4238 <.text+0xb4138> @ imm = #0x8
   c422c: e5950000     	ldr	r0, [r5]
   c4230: e3500009     	cmp	r0, #9
   c4234: ca00000d     	bgt	0xc4270 <.text+0xb4170> @ imm = #0x34
   c4238: e1a00008     	mov	r0, r8
   c423c: e3a01000     	mov	r1, #0
   c4240: e3a02040     	mov	r2, #64
   c4244: e5996230     	ldr	r6, [r9, #0x230]
   c4248: eb137c8f     	bl	0x5a348c <.text+0x59338c> @ imm = #0x4df23c
   c424c: e59a0000     	ldr	r0, [r10]
   c4250: e2401001     	sub	r1, r0, #1
   c4254: e0010190     	mul	r1, r0, r1
   c4258: e7d60007     	ldrb	r0, [r6, r7]
   c425c: e3110001     	tst	r1, #1
   c4260: 0a000007     	beq	0xc4284 <.text+0xb4184> @ imm = #0x1c
   c4264: e5951000     	ldr	r1, [r5]
   c4268: e3510009     	cmp	r1, #9
   c426c: da000004     	ble	0xc4284 <.text+0xb4184> @ imm = #0x10
   c4270: e1a00008     	mov	r0, r8
   c4274: e3a01000     	mov	r1, #0
   c4278: e3a02040     	mov	r2, #64
   c427c: eb137c82     	bl	0x5a348c <.text+0x59338c> @ imm = #0x4df208
   c4280: eaffffec     	b	0xc4238 <.text+0xb4138> @ imm = #-0x50
   c4284: e3500000     	cmp	r0, #0
   c4288: 0a000022     	beq	0xc4318 <.text+0xb4218> @ imm = #0x88
   c428c: e1a05009     	mov	r5, r9
   c4290: e0869007     	add	r9, r6, r7
   c4294: e2496038     	sub	r6, r9, #56
   c4298: eb00e784     	bl	0xfe0b0 <.text+0xedfb0> @ imm = #0x39e10
   c429c: e1a08000     	mov	r8, r0
   c42a0: e1a00006     	mov	r0, r6
   c42a4: eb138797     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e1e5c
   c42a8: e249a020     	sub	r10, r9, #32
   c42ac: e1a0000a     	mov	r0, r10
   c42b0: eb00377d     	bl	0xd20ac <.text+0xc1fac> @ imm = #0xddf4
   c42b4: e59d1054     	ldr	r1, [sp, #0x54]
   c42b8: e1500001     	cmp	r0, r1
   c42bc: 2a000002     	bhs	0xc42cc <.text+0xb41cc> @ imm = #0x8
   c42c0: e1a00006     	mov	r0, r6
   c42c4: eb1388fe     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e23f8
   c42c8: ea00000c     	b	0xc4300 <.text+0xb4200> @ imm = #0x30
   c42cc: e59f07e8     	ldr	r0, [pc, #0x7e8]        @ 0xc4abc <.text+0xb49bc>
   c42d0: e79f0000     	ldr	r0, [pc, r0]
   c42d4: e5900000     	ldr	r0, [r0]
   c42d8: e2401001     	sub	r1, r0, #1
   c42dc: e0000190     	mul	r0, r0, r1
   c42e0: e3100001     	tst	r0, #1
   c42e4: 0a000018     	beq	0xc434c <.text+0xb424c> @ imm = #0x60
   c42e8: e59f07d0     	ldr	r0, [pc, #0x7d0]        @ 0xc4ac0 <.text+0xb49c0>
   c42ec: e79f0000     	ldr	r0, [pc, r0]
   c42f0: e5900000     	ldr	r0, [r0]
   c42f4: e3500009     	cmp	r0, #9
   c42f8: ca000023     	bgt	0xc438c <.text+0xb428c> @ imm = #0x8c
   c42fc: ea000012     	b	0xc434c <.text+0xb424c> @ imm = #0x48
   c4300: e59fa7ac     	ldr	r10, [pc, #0x7ac]       @ 0xc4ab4 <.text+0xb49b4>
   c4304: e1a09005     	mov	r9, r5
   c4308: e24b8068     	sub	r8, r11, #104
   c430c: e79fa00a     	ldr	r10, [pc, r10]
   c4310: e59f57a0     	ldr	r5, [pc, #0x7a0]        @ 0xc4ab8 <.text+0xb49b8>
   c4314: e79f5005     	ldr	r5, [pc, r5]
   c4318: e59a0000     	ldr	r0, [r10]
   c431c: e2401001     	sub	r1, r0, #1
   c4320: e0000190     	mul	r0, r0, r1
   c4324: e3100001     	tst	r0, #1
   c4328: e59a0000     	ldr	r0, [r10]
   c432c: e2401001     	sub	r1, r0, #1
   c4330: e0000190     	mul	r0, r0, r1
   c4334: e3100001     	tst	r0, #1
   c4338: 0affffb3     	beq	0xc420c <.text+0xb410c> @ imm = #-0x134
   c433c: e5950000     	ldr	r0, [r5]
   c4340: e3500009     	cmp	r0, #9
   c4344: cafffff7     	bgt	0xc4328 <.text+0xb4228> @ imm = #-0x24
   c4348: eaffffaf     	b	0xc420c <.text+0xb410c> @ imm = #-0x144
   c434c: e24b1069     	sub	r1, r11, #105
   c4350: e1a0000a     	mov	r0, r10
   c4354: eb0036a5     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #0xda94
   c4358: e59f0764     	ldr	r0, [pc, #0x764]        @ 0xc4ac4 <.text+0xb49c4>
   c435c: e79f0000     	ldr	r0, [pc, r0]
   c4360: e5900000     	ldr	r0, [r0]
   c4364: e2401001     	sub	r1, r0, #1
   c4368: e0010190     	mul	r1, r0, r1
   c436c: e55b0069     	ldrb	r0, [r11, #-0x69]
   c4370: e3110001     	tst	r1, #1
   c4374: 0a000008     	beq	0xc439c <.text+0xb429c> @ imm = #0x20
   c4378: e59f1748     	ldr	r1, [pc, #0x748]        @ 0xc4ac8 <.text+0xb49c8>
   c437c: e79f1001     	ldr	r1, [pc, r1]
   c4380: e5911000     	ldr	r1, [r1]
   c4384: e3510009     	cmp	r1, #9
   c4388: da000003     	ble	0xc439c <.text+0xb429c> @ imm = #0xc
   c438c: e24b1069     	sub	r1, r11, #105
   c4390: e1a0000a     	mov	r0, r10
   c4394: eb003695     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #0xda54
   c4398: eaffffeb     	b	0xc434c <.text+0xb424c> @ imm = #-0x54
   c439c: e35000aa     	cmp	r0, #170
   c43a0: 1a000015     	bne	0xc43fc <.text+0xb42fc> @ imm = #0x54
   c43a4: e24b1069     	sub	r1, r11, #105
   c43a8: e1a0000a     	mov	r0, r10
   c43ac: eb00368f     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #0xda3c
   c43b0: e55b0069     	ldrb	r0, [r11, #-0x69]
   c43b4: e3500055     	cmp	r0, #85
   c43b8: 1a00000f     	bne	0xc43fc <.text+0xb42fc> @ imm = #0x3c
   c43bc: e3580000     	cmp	r8, #0
   c43c0: 0a000012     	beq	0xc4410 <.text+0xb4310> @ imm = #0x48
   c43c4: e59f071c     	ldr	r0, [pc, #0x71c]        @ 0xc4ae8 <.text+0xb49e8>
   c43c8: e24b8068     	sub	r8, r11, #104
   c43cc: e79f0000     	ldr	r0, [pc, r0]
   c43d0: e5900000     	ldr	r0, [r0]
   c43d4: e2401001     	sub	r1, r0, #1
   c43d8: e0000190     	mul	r0, r0, r1
   c43dc: e3100001     	tst	r0, #1
   c43e0: 0a0000da     	beq	0xc4750 <.text+0xb4650> @ imm = #0x368
   c43e4: e59f0700     	ldr	r0, [pc, #0x700]        @ 0xc4aec <.text+0xb49ec>
   c43e8: e79f0000     	ldr	r0, [pc, r0]
   c43ec: e5900000     	ldr	r0, [r0]
   c43f0: e3500009     	cmp	r0, #9
   c43f4: ca0000f5     	bgt	0xc47d0 <.text+0xb46d0> @ imm = #0x3d4
   c43f8: ea0000d4     	b	0xc4750 <.text+0xb4650> @ imm = #0x350
   c43fc: e1a00006     	mov	r0, r6
   c4400: eb1388af     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e22bc
   c4404: e3a00001     	mov	r0, #1
   c4408: e58d0050     	str	r0, [sp, #0x50]
   c440c: eaffffbb     	b	0xc4300 <.text+0xb4200> @ imm = #-0x114
   c4410: e24b8068     	sub	r8, r11, #104
   c4414: e59d2040     	ldr	r2, [sp, #0x40]
   c4418: e1a0000a     	mov	r0, r10
   c441c: e1a01008     	mov	r1, r8
   c4420: eb0036be     	bl	0xd1f20 <.text+0xc1e20> @ imm = #0xdaf8
   c4424: e59d204c     	ldr	r2, [sp, #0x4c]
   c4428: e59d0048     	ldr	r0, [sp, #0x48]
   c442c: e3520000     	cmp	r2, #0
   c4430: 0a000002     	beq	0xc4440 <.text+0xb4340> @ imm = #0x8
   c4434: e3520001     	cmp	r2, #1
   c4438: e59d003c     	ldr	r0, [sp, #0x3c]
   c443c: 159d0034     	ldrne	r0, [sp, #0x34]
   c4440: e1d000d0     	ldrsb	r0, [r0]
   c4444: e59fa680     	ldr	r10, [pc, #0x680]       @ 0xc4acc <.text+0xb49cc>
   c4448: e3700001     	cmn	r0, #1
   c444c: e79fa00a     	ldr	r10, [pc, r10]
   c4450: da00000a     	ble	0xc4480 <.text+0xb4380> @ imm = #0x28
   c4454: e59a0000     	ldr	r0, [r10]
   c4458: e2401001     	sub	r1, r0, #1
   c445c: e0000190     	mul	r0, r0, r1
   c4460: e3100001     	tst	r0, #1
   c4464: 0a000103     	beq	0xc4878 <.text+0xb4778> @ imm = #0x40c
   c4468: e59f0690     	ldr	r0, [pc, #0x690]        @ 0xc4b00 <.text+0xb4a00>
   c446c: e79f0000     	ldr	r0, [pc, r0]
   c4470: e5900000     	ldr	r0, [r0]
   c4474: e3500009     	cmp	r0, #9
   c4478: ca00010a     	bgt	0xc48a8 <.text+0xb47a8> @ imm = #0x428
   c447c: ea0000fd     	b	0xc4878 <.text+0xb4778> @ imm = #0x3f4
   c4480: e59d0010     	ldr	r0, [sp, #0x10]
   c4484: e3500005     	cmp	r0, #5
   c4488: 1a000009     	bne	0xc44b4 <.text+0xb43b4> @ imm = #0x24
   c448c: e3881005     	orr	r1, r8, #5
   c4490: e3520001     	cmp	r2, #1
   c4494: 03881006     	orreq	r1, r8, #6
   c4498: e55b0064     	ldrb	r0, [r11, #-0x64]
   c449c: e3520002     	cmp	r2, #2
   c44a0: e5d11000     	ldrb	r1, [r1]
   c44a4: e1a00380     	lsl	r0, r0, #7
   c44a8: 33e0007f     	mvnlo	r0, #127
   c44ac: e18000a1     	orr	r0, r0, r1, lsr #1
   c44b0: ea000003     	b	0xc44c4 <.text+0xb43c4> @ imm = #0xc
   c44b4: e3880005     	orr	r0, r8, #5
   c44b8: e3520001     	cmp	r2, #1
   c44bc: 03880006     	orreq	r0, r8, #6
   c44c0: e5d00000     	ldrb	r0, [r0]
   c44c4: e59a1000     	ldr	r1, [r10]
   c44c8: e2412001     	sub	r2, r1, #1
   c44cc: e0010291     	mul	r1, r1, r2
   c44d0: e3110001     	tst	r1, #1
   c44d4: e59a2000     	ldr	r2, [r10]
   c44d8: e7e411d0     	ubfx	r1, r0, #0x3, #0x5
   c44dc: e2423001     	sub	r3, r2, #1
   c44e0: e0020392     	mul	r2, r2, r3
   c44e4: e3120001     	tst	r2, #1
   c44e8: 0a000004     	beq	0xc4500 <.text+0xb4400> @ imm = #0x10
   c44ec: e59f25dc     	ldr	r2, [pc, #0x5dc]        @ 0xc4ad0 <.text+0xb49d0>
   c44f0: e79f2002     	ldr	r2, [pc, r2]
   c44f4: e5922000     	ldr	r2, [r2]
   c44f8: e3520009     	cmp	r2, #9
   c44fc: cafffff4     	bgt	0xc44d4 <.text+0xb43d4> @ imm = #-0x30
   c4500: e59f05cc     	ldr	r0, [pc, #0x5cc]        @ 0xc4ad4 <.text+0xb49d4>
   c4504: e3a020a8     	mov	r2, #168
   c4508: e08f0000     	add	r0, pc, r0
   c450c: e10a0281     	smlabb	r10, r1, r2, r0
   c4510: e29a0008     	adds	r0, r10, #8
   c4514: 0a00007f     	beq	0xc4718 <.text+0xb4618> @ imm = #0x1fc
   c4518: e15b26b2     	ldrh	r2, [r11, #-98]
   c451c: e5190300     	ldr	r0, [r9, #-0x300]
   c4520: e58d6050     	str	r6, [sp, #0x50]
   c4524: e59d604c     	ldr	r6, [sp, #0x4c]
   c4528: e50b00f8     	str	r0, [r11, #-0xf8]
   c452c: e59a00ac     	ldr	r0, [r10, #0xac]
   c4530: e3560002     	cmp	r6, #2
   c4534: e50b00ec     	str	r0, [r11, #-0xec]
   c4538: e1a00402     	lsl	r0, r2, #8
   c453c: e50b10e8     	str	r1, [r11, #-0xe8]
   c4540: e1a01422     	lsr	r1, r2, #8
   c4544: 33e000ff     	mvnlo	r0, #255
   c4548: 330010ff     	movwlo	r1, #0xff
   c454c: e1800001     	orr	r0, r0, r1
   c4550: e30027f8     	movw	r2, #0x7f8
   c4554: e000c002     	and	r12, r0, r2
   c4558: e2011007     	and	r1, r1, #7
   c455c: e6ff0070     	uxth	r0, r0
   c4560: e59a2080     	ldr	r2, [r10, #0x80]
   c4564: e1a005a0     	lsr	r0, r0, #11
   c4568: e59a8078     	ldr	r8, [r10, #0x78]
   c456c: e1800a81     	orr	r0, r0, r1, lsl #21
   c4570: e59d1030     	ldr	r1, [sp, #0x30]
   c4574: e180028c     	orr	r0, r0, r12, lsl #5
   c4578: e58d002c     	str	r0, [sp, #0x2c]
   c457c: e1800002     	orr	r0, r0, r2
   c4580: e50b00e4     	str	r0, [r11, #-0xe4]
   c4584: e59d0004     	ldr	r0, [sp, #0x4]
   c4588: e3560001     	cmp	r6, #1
   c458c: e59a307c     	ldr	r3, [r10, #0x7c]
   c4590: e5808000     	str	r8, [r0]
   c4594: e5803004     	str	r3, [r0, #0x4]
   c4598: e24b0068     	sub	r0, r11, #104
   c459c: 01a00001     	moveq	r0, r1
   c45a0: e5900000     	ldr	r0, [r0]
   c45a4: e6bf0f30     	rev	r0, r0
   c45a8: e50b00d8     	str	r0, [r11, #-0xd8]
   c45ac: eb00386b     	bl	0xd2760 <.text+0xc2660> @ imm = #0xe1ac
   c45b0: e51b10d8     	ldr	r1, [r11, #-0xd8]
   c45b4: e50b00f4     	str	r0, [r11, #-0xf4]
   c45b8: e1a00001     	mov	r0, r1
   c45bc: eb003892     	bl	0xd280c <.text+0xc270c> @ imm = #0xe248
   c45c0: e50b00f0     	str	r0, [r11, #-0xf0]
   c45c4: e59a0058     	ldr	r0, [r10, #0x58]
   c45c8: e58d0018     	str	r0, [sp, #0x18]
   c45cc: e59a0070     	ldr	r0, [r10, #0x70]
   c45d0: e59a106c     	ldr	r1, [r10, #0x6c]
   c45d4: e6bf0f30     	rev	r0, r0
   c45d8: e59a2068     	ldr	r2, [r10, #0x68]
   c45dc: e50b0070     	str	r0, [r11, #-0x70]
   c45e0: e6bf0f31     	rev	r0, r1
   c45e4: e59ac064     	ldr	r12, [r10, #0x64]
   c45e8: e59a3080     	ldr	r3, [r10, #0x80]
   c45ec: e50b0074     	str	r0, [r11, #-0x74]
   c45f0: e6bf0f32     	rev	r0, r2
   c45f4: e59a6060     	ldr	r6, [r10, #0x60]
   c45f8: e58d3028     	str	r3, [sp, #0x28]
   c45fc: e59a308c     	ldr	r3, [r10, #0x8c]
   c4600: e50b0078     	str	r0, [r11, #-0x78]
   c4604: e6bf0f3c     	rev	r0, r12
   c4608: e59a905c     	ldr	r9, [r10, #0x5c]
   c460c: e58d3024     	str	r3, [sp, #0x24]
   c4610: e59a3090     	ldr	r3, [r10, #0x90]
   c4614: e50b007c     	str	r0, [r11, #-0x7c]
   c4618: e6bf0f36     	rev	r0, r6
   c461c: e58d3020     	str	r3, [sp, #0x20]
   c4620: e28d6058     	add	r6, sp, #88
   c4624: e59a3094     	ldr	r3, [r10, #0x94]
   c4628: e50b0080     	str	r0, [r11, #-0x80]
   c462c: e6bf0f39     	rev	r0, r9
   c4630: e58d301c     	str	r3, [sp, #0x1c]
   c4634: e59a3098     	ldr	r3, [r10, #0x98]
   c4638: e50b0084     	str	r0, [r11, #-0x84]
   c463c: e59d0018     	ldr	r0, [sp, #0x18]
   c4640: e58d3014     	str	r3, [sp, #0x14]
   c4644: e59a809c     	ldr	r8, [r10, #0x9c]
   c4648: e6bf0f30     	rev	r0, r0
   c464c: e59ae0a0     	ldr	lr, [r10, #0xa0]
   c4650: e59a30a4     	ldr	r3, [r10, #0xa4]
   c4654: e59aa0a8     	ldr	r10, [r10, #0xa8]
   c4658: e50b0088     	str	r0, [r11, #-0x88]
   c465c: e6bf0f3a     	rev	r0, r10
   c4660: e50b008c     	str	r0, [r11, #-0x8c]
   c4664: e6bf0f33     	rev	r0, r3
   c4668: e50b0090     	str	r0, [r11, #-0x90]
   c466c: e6bf0f3e     	rev	r0, lr
   c4670: e50b0094     	str	r0, [r11, #-0x94]
   c4674: e6bf0f38     	rev	r0, r8
   c4678: e50b0098     	str	r0, [r11, #-0x98]
   c467c: e59d0014     	ldr	r0, [sp, #0x14]
   c4680: e24b8068     	sub	r8, r11, #104
   c4684: e59d1028     	ldr	r1, [sp, #0x28]
   c4688: e6bf0f30     	rev	r0, r0
   c468c: e50b009c     	str	r0, [r11, #-0x9c]
   c4690: e59d001c     	ldr	r0, [sp, #0x1c]
   c4694: e6bf0f30     	rev	r0, r0
   c4698: e50b00a0     	str	r0, [r11, #-0xa0]
   c469c: e59d0020     	ldr	r0, [sp, #0x20]
   c46a0: e6bf0f30     	rev	r0, r0
   c46a4: e50b00a4     	str	r0, [r11, #-0xa4]
   c46a8: e59d0024     	ldr	r0, [sp, #0x24]
   c46ac: e6bf0f30     	rev	r0, r0
   c46b0: e50b00a8     	str	r0, [r11, #-0xa8]
   c46b4: e59d002c     	ldr	r0, [sp, #0x2c]
   c46b8: e1810000     	orr	r0, r1, r0
   c46bc: e6bf0f30     	rev	r0, r0
   c46c0: e50b00ac     	str	r0, [r11, #-0xac]
   c46c4: e1a00006     	mov	r0, r6
   c46c8: eb011294     	bl	0x109120 <.text+0xf9020> @ imm = #0x44a50
   c46cc: e24b10ac     	sub	r1, r11, #172
   c46d0: e1a00006     	mov	r0, r6
   c46d4: e3a02040     	mov	r2, #64
   c46d8: eb0112a4     	bl	0x109170 <.text+0xf9070> @ imm = #0x44a90
   c46dc: e59dc00c     	ldr	r12, [sp, #0xc]
   c46e0: e59d1008     	ldr	r1, [sp, #0x8]
   c46e4: e8bc004d     	ldm	r12!, {r0, r2, r3, r6}
   c46e8: e8a1004d     	stm	r1!, {r0, r2, r3, r6}
   c46ec: e89c004d     	ldm	r12, {r0, r2, r3, r6}
   c46f0: e881004d     	stm	r1, {r0, r2, r3, r6}
   c46f4: e24b00f8     	sub	r0, r11, #248
   c46f8: e59d6050     	ldr	r6, [sp, #0x50]
   c46fc: eb00d7b7     	bl	0xfa5e0 <.text+0xea4e0> @ imm = #0x35edc
   c4700: e59fa3d8     	ldr	r10, [pc, #0x3d8]       @ 0xc4ae0 <.text+0xb49e0>
   c4704: e1a09005     	mov	r9, r5
   c4708: e79fa00a     	ldr	r10, [pc, r10]
   c470c: e59f53d0     	ldr	r5, [pc, #0x3d0]        @ 0xc4ae4 <.text+0xb49e4>
   c4710: e79f5005     	ldr	r5, [pc, r5]
   c4714: ea000052     	b	0xc4864 <.text+0xb4764> @ imm = #0x148
   c4718: e59fa3b8     	ldr	r10, [pc, #0x3b8]       @ 0xc4ad8 <.text+0xb49d8>
   c471c: e1a09005     	mov	r9, r5
   c4720: e79fa00a     	ldr	r10, [pc, r10]
   c4724: e59a0000     	ldr	r0, [r10]
   c4728: e59f53ac     	ldr	r5, [pc, #0x3ac]        @ 0xc4adc <.text+0xb49dc>
   c472c: e2401001     	sub	r1, r0, #1
   c4730: e0000190     	mul	r0, r0, r1
   c4734: e79f5005     	ldr	r5, [pc, r5]
   c4738: e3100001     	tst	r0, #1
   c473c: 0a00007a     	beq	0xc492c <.text+0xb482c> @ imm = #0x1e8
   c4740: e5950000     	ldr	r0, [r5]
   c4744: e3500009     	cmp	r0, #9
   c4748: ca000083     	bgt	0xc495c <.text+0xb485c> @ imm = #0x20c
   c474c: ea000076     	b	0xc492c <.text+0xb482c> @ imm = #0x1d8
   c4750: e1a0000a     	mov	r0, r10
   c4754: e1a01008     	mov	r1, r8
   c4758: e3a02007     	mov	r2, #7
   c475c: eb0035ef     	bl	0xd1f20 <.text+0xc1e20> @ imm = #0xd7bc
   c4760: e55b1062     	ldrb	r1, [r11, #-0x62]
   c4764: e51b0068     	ldr	r0, [r11, #-0x68]
   c4768: e5192300     	ldr	r2, [r9, #-0x300]
   c476c: e201101f     	and	r1, r1, #31
   c4770: e15b36b4     	ldrh	r3, [r11, #-100]
   c4774: e58d2058     	str	r2, [sp, #0x58]
   c4778: e1cd35bc     	strh	r3, [sp, #92]
   c477c: e1cd16b4     	strh	r1, [sp, #100]
   c4780: e1a01820     	lsr	r1, r0, #16
   c4784: e6bf0f30     	rev	r0, r0
   c4788: e6bf1f31     	rev	r1, r1
   c478c: e7cf001f     	bfc	r0, #0, #16
   c4790: e1800861     	orr	r0, r0, r1, ror #16
   c4794: e58d0060     	str	r0, [sp, #0x60]
   c4798: eb0038b9     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe2e4
   c479c: e59f134c     	ldr	r1, [pc, #0x34c]        @ 0xc4af0 <.text+0xb49f0>
   c47a0: e79f1001     	ldr	r1, [pc, r1]
   c47a4: e5911000     	ldr	r1, [r1]
   c47a8: e2412001     	sub	r2, r1, #1
   c47ac: e0020291     	mul	r2, r1, r2
   c47b0: e55b1063     	ldrb	r1, [r11, #-0x63]
   c47b4: e3120001     	tst	r2, #1
   c47b8: 0a000018     	beq	0xc4820 <.text+0xb4720> @ imm = #0x60
   c47bc: e59f2330     	ldr	r2, [pc, #0x330]        @ 0xc4af4 <.text+0xb49f4>
   c47c0: e79f2002     	ldr	r2, [pc, r2]
   c47c4: e5922000     	ldr	r2, [r2]
   c47c8: e3520009     	cmp	r2, #9
   c47cc: da000013     	ble	0xc4820 <.text+0xb4720> @ imm = #0x4c
   c47d0: e1a0000a     	mov	r0, r10
   c47d4: e1a01008     	mov	r1, r8
   c47d8: e3a02007     	mov	r2, #7
   c47dc: eb0035cf     	bl	0xd1f20 <.text+0xc1e20> @ imm = #0xd73c
   c47e0: e55b1062     	ldrb	r1, [r11, #-0x62]
   c47e4: e51b0068     	ldr	r0, [r11, #-0x68]
   c47e8: e5192300     	ldr	r2, [r9, #-0x300]
   c47ec: e201101f     	and	r1, r1, #31
   c47f0: e15b36b4     	ldrh	r3, [r11, #-100]
   c47f4: e58d2058     	str	r2, [sp, #0x58]
   c47f8: e1cd35bc     	strh	r3, [sp, #92]
   c47fc: e1cd16b4     	strh	r1, [sp, #100]
   c4800: e1a01820     	lsr	r1, r0, #16
   c4804: e6bf0f30     	rev	r0, r0
   c4808: e6bf1f31     	rev	r1, r1
   c480c: e7cf001f     	bfc	r0, #0, #16
   c4810: e1800861     	orr	r0, r0, r1, ror #16
   c4814: e58d0060     	str	r0, [sp, #0x60]
   c4818: eb003899     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe264
   c481c: eaffffcb     	b	0xc4750 <.text+0xb4650> @ imm = #-0xd4
   c4820: e59fa2d0     	ldr	r10, [pc, #0x2d0]       @ 0xc4af8 <.text+0xb49f8>
   c4824: e1a09005     	mov	r9, r5
   c4828: e1500001     	cmp	r0, r1
   c482c: e79fa00a     	ldr	r10, [pc, r10]
   c4830: e59f52c4     	ldr	r5, [pc, #0x2c4]        @ 0xc4afc <.text+0xb49fc>
   c4834: e79f5005     	ldr	r5, [pc, r5]
   c4838: 0a000001     	beq	0xc4844 <.text+0xb4744> @ imm = #0x4
   c483c: e28d0058     	add	r0, sp, #88
   c4840: eb01103c     	bl	0x108938 <.text+0xf8838> @ imm = #0x440f0
   c4844: e59a0000     	ldr	r0, [r10]
   c4848: e2401001     	sub	r1, r0, #1
   c484c: e0000190     	mul	r0, r0, r1
   c4850: e3100001     	tst	r0, #1
   c4854: 0a000002     	beq	0xc4864 <.text+0xb4764> @ imm = #0x8
   c4858: e5950000     	ldr	r0, [r5]
   c485c: e3500009     	cmp	r0, #9
   c4860: cafffff7     	bgt	0xc4844 <.text+0xb4744> @ imm = #-0x24
   c4864: e1a00006     	mov	r0, r6
   c4868: eb138795     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1e54
   c486c: e3a00001     	mov	r0, #1
   c4870: e58d0050     	str	r0, [sp, #0x50]
   c4874: eafffea7     	b	0xc4318 <.text+0xb4218> @ imm = #-0x564
   c4878: e59a1000     	ldr	r1, [r10]
   c487c: e59f0280     	ldr	r0, [pc, #0x280]        @ 0xc4b04 <.text+0xb4a04>
   c4880: e2412001     	sub	r2, r1, #1
   c4884: e79f0000     	ldr	r0, [pc, r0]
   c4888: e0010291     	mul	r1, r1, r2
   c488c: e5192300     	ldr	r2, [r9, #-0x300]
   c4890: e58d2058     	str	r2, [sp, #0x58]
   c4894: e5900000     	ldr	r0, [r0]
   c4898: e3110001     	tst	r1, #1
   c489c: 0a000004     	beq	0xc48b4 <.text+0xb47b4> @ imm = #0x10
   c48a0: e3500009     	cmp	r0, #9
   c48a4: da000002     	ble	0xc48b4 <.text+0xb47b4> @ imm = #0x8
   c48a8: e5190300     	ldr	r0, [r9, #-0x300]
   c48ac: e58d0058     	str	r0, [sp, #0x58]
   c48b0: eafffff0     	b	0xc4878 <.text+0xb4778> @ imm = #-0x40
   c48b4: e59d204c     	ldr	r2, [sp, #0x4c]
   c48b8: e3520001     	cmp	r2, #1
   c48bc: 0a00000d     	beq	0xc48f8 <.text+0xb47f8> @ imm = #0x34
   c48c0: e1a09005     	mov	r9, r5
   c48c4: e59f523c     	ldr	r5, [pc, #0x23c]        @ 0xc4b08 <.text+0xb4a08>
   c48c8: e3520000     	cmp	r2, #0
   c48cc: e79f5005     	ldr	r5, [pc, r5]
   c48d0: 1a000010     	bne	0xc4918 <.text+0xb4818> @ imm = #0x40
   c48d4: e59a0000     	ldr	r0, [r10]
   c48d8: e2401001     	sub	r1, r0, #1
   c48dc: e0000190     	mul	r0, r0, r1
   c48e0: e3100001     	tst	r0, #1
   c48e4: 0a00001f     	beq	0xc4968 <.text+0xb4868> @ imm = #0x7c
   c48e8: e5950000     	ldr	r0, [r5]
   c48ec: e3500009     	cmp	r0, #9
   c48f0: ca000029     	bgt	0xc499c <.text+0xb489c> @ imm = #0xa4
   c48f4: ea00001b     	b	0xc4968 <.text+0xb4868> @ imm = #0x6c
   c48f8: e55b1063     	ldrb	r1, [r11, #-0x63]
   c48fc: e1a09005     	mov	r9, r5
   c4900: e5cd105c     	strb	r1, [sp, #0x5c]
   c4904: e55b0062     	ldrb	r0, [r11, #-0x62]
   c4908: e59d1030     	ldr	r1, [sp, #0x30]
   c490c: e59f51f8     	ldr	r5, [pc, #0x1f8]        @ 0xc4b0c <.text+0xb4a0c>
   c4910: e79f5005     	ldr	r5, [pc, r5]
   c4914: ea000025     	b	0xc49b0 <.text+0xb48b0> @ imm = #0x94
   c4918: e55b0063     	ldrb	r0, [r11, #-0x63]
   c491c: e55b1064     	ldrb	r1, [r11, #-0x64]
   c4920: e5cd105c     	strb	r1, [sp, #0x5c]
   c4924: e1a01008     	mov	r1, r8
   c4928: ea000020     	b	0xc49b0 <.text+0xb48b0> @ imm = #0x80
   c492c: e1a00006     	mov	r0, r6
   c4930: eb138763     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1d8c
   c4934: e59a0000     	ldr	r0, [r10]
   c4938: e2401001     	sub	r1, r0, #1
   c493c: e0000190     	mul	r0, r0, r1
   c4940: e3100001     	tst	r0, #1
   c4944: 0affffc8     	beq	0xc486c <.text+0xb476c> @ imm = #-0xe0
   c4948: e3a00001     	mov	r0, #1
   c494c: e58d0050     	str	r0, [sp, #0x50]
   c4950: e5950000     	ldr	r0, [r5]
   c4954: e350000a     	cmp	r0, #10
   c4958: bafffe6e     	blt	0xc4318 <.text+0xb4218> @ imm = #-0x648
   c495c: e1a00006     	mov	r0, r6
   c4960: eb138757     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1d5c
   c4964: eafffff0     	b	0xc492c <.text+0xb482c> @ imm = #-0x40
   c4968: e59a0000     	ldr	r0, [r10]
   c496c: e55b3064     	ldrb	r3, [r11, #-0x64]
   c4970: e2401001     	sub	r1, r0, #1
   c4974: e5cd305c     	strb	r3, [sp, #0x5c]
   c4978: e0020190     	mul	r2, r0, r1
   c497c: e55b0063     	ldrb	r0, [r11, #-0x63]
   c4980: e5951000     	ldr	r1, [r5]
   c4984: e3120001     	tst	r2, #1
   c4988: 0a000006     	beq	0xc49a8 <.text+0xb48a8> @ imm = #0x18
   c498c: e59d204c     	ldr	r2, [sp, #0x4c]
   c4990: e351000a     	cmp	r1, #10
   c4994: e1a01008     	mov	r1, r8
   c4998: ba000004     	blt	0xc49b0 <.text+0xb48b0> @ imm = #0x10
   c499c: e55b0064     	ldrb	r0, [r11, #-0x64]
   c49a0: e5cd005c     	strb	r0, [sp, #0x5c]
   c49a4: eaffffef     	b	0xc4968 <.text+0xb4868> @ imm = #-0x44
   c49a8: e1a01008     	mov	r1, r8
   c49ac: e59d204c     	ldr	r2, [sp, #0x4c]
   c49b0: e5cd005d     	strb	r0, [sp, #0x5d]
   c49b4: e3520000     	cmp	r2, #0
   c49b8: e5910000     	ldr	r0, [r1]
   c49bc: e59d8048     	ldr	r8, [sp, #0x48]
   c49c0: e1a01820     	lsr	r1, r0, #16
   c49c4: e6bf0f30     	rev	r0, r0
   c49c8: e6bf1f31     	rev	r1, r1
   c49cc: e7cf001f     	bfc	r0, #0, #16
   c49d0: e1800861     	orr	r0, r0, r1, ror #16
   c49d4: e58d0060     	str	r0, [sp, #0x60]
   c49d8: 0a00000c     	beq	0xc4a10 <.text+0xb4910> @ imm = #0x30
   c49dc: e3520001     	cmp	r2, #1
   c49e0: 1a000009     	bne	0xc4a0c <.text+0xb490c> @ imm = #0x24
   c49e4: e59a0000     	ldr	r0, [r10]
   c49e8: e2401001     	sub	r1, r0, #1
   c49ec: e0000190     	mul	r0, r0, r1
   c49f0: e3100001     	tst	r0, #1
   c49f4: 0a000002     	beq	0xc4a04 <.text+0xb4904> @ imm = #0x8
   c49f8: e5950000     	ldr	r0, [r5]
   c49fc: e350000a     	cmp	r0, #10
   c4a00: aafffff7     	bge	0xc49e4 <.text+0xb48e4> @ imm = #-0x24
   c4a04: e59d803c     	ldr	r8, [sp, #0x3c]
   c4a08: ea000000     	b	0xc4a10 <.text+0xb4910> @ imm = #0x0
   c4a0c: e59d8034     	ldr	r8, [sp, #0x34]
   c4a10: e59a0000     	ldr	r0, [r10]
   c4a14: e2401001     	sub	r1, r0, #1
   c4a18: e0000190     	mul	r0, r0, r1
   c4a1c: e3100001     	tst	r0, #1
   c4a20: 0a000002     	beq	0xc4a30 <.text+0xb4930> @ imm = #0x8
   c4a24: e5950000     	ldr	r0, [r5]
   c4a28: e3500009     	cmp	r0, #9
   c4a2c: ca00000c     	bgt	0xc4a64 <.text+0xb4964> @ imm = #0x30
   c4a30: e5d80000     	ldrb	r0, [r8]
   c4a34: e200001f     	and	r0, r0, #31
   c4a38: e1cd06b4     	strh	r0, [sp, #100]
   c4a3c: eb003810     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe040
   c4a40: e59a1000     	ldr	r1, [r10]
   c4a44: e2412001     	sub	r2, r1, #1
   c4a48: e0020291     	mul	r2, r1, r2
   c4a4c: e5dd105d     	ldrb	r1, [sp, #0x5d]
   c4a50: e3120001     	tst	r2, #1
   c4a54: 0a000007     	beq	0xc4a78 <.text+0xb4978> @ imm = #0x1c
   c4a58: e5952000     	ldr	r2, [r5]
   c4a5c: e3520009     	cmp	r2, #9
   c4a60: da000004     	ble	0xc4a78 <.text+0xb4978> @ imm = #0x10
   c4a64: e5d80000     	ldrb	r0, [r8]
   c4a68: e200001f     	and	r0, r0, #31
   c4a6c: e1cd06b4     	strh	r0, [sp, #100]
   c4a70: eb003803     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe00c
   c4a74: eaffffed     	b	0xc4a30 <.text+0xb4930> @ imm = #-0x4c
   c4a78: e24b8068     	sub	r8, r11, #104
   c4a7c: e1500001     	cmp	r0, r1
   c4a80: 0affff6f     	beq	0xc4844 <.text+0xb4744> @ imm = #-0x244
   c4a84: eaffff6c     	b	0xc483c <.text+0xb473c> @ imm = #-0x250
   c4a88: e59d0050     	ldr	r0, [sp, #0x50]
   c4a8c: e59d4038     	ldr	r4, [sp, #0x38]
   c4a90: e3100001     	tst	r0, #1
   c4a94: 0afffdc2     	beq	0xc41a4 <.text+0xb40a4> @ imm = #-0x8f8
   c4a98: eafffdd1     	b	0xc41e4 <.text+0xb40e4> @ imm = #-0x8bc
   c4a9c: e3a00000     	mov	r0, #0
   c4aa0: e24bd01c     	sub	sp, r11, #28
   c4aa4: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   c4aa8: 00525639     	subseq	r5, r2, r9, lsr r6
   c4aac: 0051baa0     	subseq	r11, r1, r0, lsr #21
   c4ab0: 0051a4b8     	ldrheq	r10, [r1], #-72
   c4ab4: 0051b91c     	subseq	r11, r1, r12, lsl r9
   c4ab8: 0051a334     	subseq	r10, r1, r4, lsr r3
   c4abc: 0051b958     	subseq	r11, r1, r8, asr r9
   c4ac0: 0051a35c     	subseq	r10, r1, r12, asr r3
   c4ac4: 0051b8cc     	subseq	r11, r1, r12, asr #17
   c4ac8: 0051a2cc     	subseq	r10, r1, r12, asr #5
   c4acc: 0051b7dc     	ldrsbeq	r11, [r1], #-124
   c4ad0: 0051a158     	subseq	r10, r1, r8, asr r1
   c4ad4: 0058ef48     	subseq	lr, r8, r8, asr #30
   c4ad8: 0051b508     	subseq	r11, r1, r8, lsl #10
   c4adc: 00519f14     	subseq	r9, r1, r4, lsl pc
   c4ae0: 0051b520     	subseq	r11, r1, r0, lsr #10
   c4ae4: 00519f38     	subseq	r9, r1, r8, lsr pc
   c4ae8: 0051b85c     	subseq	r11, r1, r12, asr r8
   c4aec: 0051a260     	subseq	r10, r1, r0, ror #4
   c4af0: 0051b488     	subseq	r11, r1, r8, lsl #9
   c4af4: 00519e88     	subseq	r9, r1, r8, lsl #29
   c4af8: 0051b3fc     	ldrsheq	r11, [r1], #-60
   c4afc: 00519e14     	subseq	r9, r1, r4, lsl lr
   c4b00: 0051a1dc     	ldrsbeq	r10, [r1], #-28
   c4b04: 00519dc4     	subseq	r9, r1, r4, asr #27
   c4b08: 00519d7c     	subseq	r9, r1, r12, ror sp
   c4b0c: 00519d38     	subseq	r9, r1, r8, lsr sp
   c4b10: 0058f260     	subseq	pc, r8, r0, ror #4
   c4b14: 0058f258     	subseq	pc, r8, r8, asr r2
   c4b18: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   c4b1c: e28db01c     	add	r11, sp, #28
   c4b20: e24dd08c     	sub	sp, sp, #140
   c4b24: e1a04000     	mov	r4, r0
   c4b28: eb00e6ce     	bl	0xfe668 <.text+0xee568> @ imm = #0x39b38
   c4b2c: e3a05000     	mov	r5, #0
   c4b30: e58d0008     	str	r0, [sp, #0x8]
   c4b34: e3a00001     	mov	r0, #1
   c4b38: e3a01000     	mov	r1, #0
   c4b3c: e50b5024     	str	r5, [r11, #-0x24]
   c4b40: e3a06001     	mov	r6, #1
   c4b44: e50b5028     	str	r5, [r11, #-0x28]
   c4b48: e50b502c     	str	r5, [r11, #-0x2c]
   c4b4c: e50b5030     	str	r5, [r11, #-0x30]
   c4b50: eb1387f5     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e1fd4
   c4b54: e59f14e0     	ldr	r1, [pc, #0x4e0]        @ 0xc503c <.text+0xb4f3c>
   c4b58: e3a0000f     	mov	r0, #15
   c4b5c: e3a02000     	mov	r2, #0
   c4b60: e3a03000     	mov	r3, #0
   c4b64: e08f1001     	add	r1, pc, r1
   c4b68: e58d5000     	str	r5, [sp]
   c4b6c: eb133be1     	bl	0x593af8 <.text+0x5839f8> @ imm = #0x4cef84
   c4b70: e301005c     	movw	r0, #0x105c
   c4b74: e58d400c     	str	r4, [sp, #0xc]
   c4b78: e7e46000     	strb	r6, [r4, r0]!
   c4b7c: e28d0020     	add	r0, sp, #32
   c4b80: e280103a     	add	r1, r0, #58
   c4b84: e58d4004     	str	r4, [sp, #0x4]
   c4b88: e58d1018     	str	r1, [sp, #0x18]
   c4b8c: e280101a     	add	r1, r0, #26
   c4b90: e3800002     	orr	r0, r0, #2
   c4b94: e58d1014     	str	r1, [sp, #0x14]
   c4b98: e58d0010     	str	r0, [sp, #0x10]
   c4b9c: e24b4030     	sub	r4, r11, #48
   c4ba0: e59f5498     	ldr	r5, [pc, #0x498]        @ 0xc5040 <.text+0xb4f40>
   c4ba4: e59f6498     	ldr	r6, [pc, #0x498]        @ 0xc5044 <.text+0xb4f44>
   c4ba8: e59f7498     	ldr	r7, [pc, #0x498]        @ 0xc5048 <.text+0xb4f48>
   c4bac: e08f5005     	add	r5, pc, r5
   c4bb0: e08f6006     	add	r6, pc, r6
   c4bb4: e08f7007     	add	r7, pc, r7
   c4bb8: ea000008     	b	0xc4be0 <.text+0xb4ae0> @ imm = #0x20
   c4bbc: e59d0004     	ldr	r0, [sp, #0x4]
   c4bc0: e24b4030     	sub	r4, r11, #48
   c4bc4: e5d00000     	ldrb	r0, [r0]
   c4bc8: e59f54b0     	ldr	r5, [pc, #0x4b0]        @ 0xc5080 <.text+0xb4f80>
   c4bcc: e59f64b0     	ldr	r6, [pc, #0x4b0]        @ 0xc5084 <.text+0xb4f84>
   c4bd0: e3500000     	cmp	r0, #0
   c4bd4: e08f5005     	add	r5, pc, r5
   c4bd8: e08f6006     	add	r6, pc, r6
   c4bdc: 0a000114     	beq	0xc5034 <.text+0xb4f34> @ imm = #0x450
   c4be0: e59f0464     	ldr	r0, [pc, #0x464]        @ 0xc504c <.text+0xb4f4c>
   c4be4: e79f0000     	ldr	r0, [pc, r0]
   c4be8: e5900000     	ldr	r0, [r0]
   c4bec: e2401001     	sub	r1, r0, #1
   c4bf0: e0000190     	mul	r0, r0, r1
   c4bf4: e3100001     	tst	r0, #1
   c4bf8: 0a000004     	beq	0xc4c10 <.text+0xb4b10> @ imm = #0x10
   c4bfc: e59f044c     	ldr	r0, [pc, #0x44c]        @ 0xc5050 <.text+0xb4f50>
   c4c00: e79f0000     	ldr	r0, [pc, r0]
   c4c04: e5900000     	ldr	r0, [r0]
   c4c08: e3500009     	cmp	r0, #9
   c4c0c: ca00001c     	bgt	0xc4c84 <.text+0xb4b84> @ imm = #0x70
   c4c10: e3a00001     	mov	r0, #1
   c4c14: e1a01004     	mov	r1, r4
   c4c18: eb1388f9     	bl	0x5a7004 <.text+0x596f04> @ imm = #0x4e23e4
   c4c1c: eb00e868     	bl	0xfedc4 <.text+0xeecc4> @ imm = #0x3a1a0
   c4c20: e1a02000     	mov	r2, r0
   c4c24: e1a03fc0     	asr	r3, r0, #31
   c4c28: e1a00004     	mov	r0, r4
   c4c2c: e1a01004     	mov	r1, r4
   c4c30: eb012a43     	bl	0x10f544 <.text+0xff444> @ imm = #0x4a90c
   c4c34: e1a00005     	mov	r0, r5
   c4c38: eb138532     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e14c8
   c4c3c: e1a00006     	mov	r0, r6
   c4c40: e1a01005     	mov	r1, r5
   c4c44: e1a02004     	mov	r2, r4
   c4c48: eb137fe2     	bl	0x5a4bd8 <.text+0x594ad8> @ imm = #0x4dff88
   c4c4c: e1a00005     	mov	r0, r5
   c4c50: eb13869b     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1a6c
   c4c54: e59f03f8     	ldr	r0, [pc, #0x3f8]        @ 0xc5054 <.text+0xb4f54>
   c4c58: e79f0000     	ldr	r0, [pc, r0]
   c4c5c: e5900000     	ldr	r0, [r0]
   c4c60: e2401001     	sub	r1, r0, #1
   c4c64: e0000190     	mul	r0, r0, r1
   c4c68: e3100001     	tst	r0, #1
   c4c6c: 0a000016     	beq	0xc4ccc <.text+0xb4bcc> @ imm = #0x58
   c4c70: e59f03e0     	ldr	r0, [pc, #0x3e0]        @ 0xc5058 <.text+0xb4f58>
   c4c74: e79f0000     	ldr	r0, [pc, r0]
   c4c78: e5900000     	ldr	r0, [r0]
   c4c7c: e3500009     	cmp	r0, #9
   c4c80: da000011     	ble	0xc4ccc <.text+0xb4bcc> @ imm = #0x44
   c4c84: e3a00001     	mov	r0, #1
   c4c88: e1a01004     	mov	r1, r4
   c4c8c: eb1388dc     	bl	0x5a7004 <.text+0x596f04> @ imm = #0x4e2370
   c4c90: eb00e84b     	bl	0xfedc4 <.text+0xeecc4> @ imm = #0x3a12c
   c4c94: e1a02000     	mov	r2, r0
   c4c98: e1a03fc0     	asr	r3, r0, #31
   c4c9c: e1a00004     	mov	r0, r4
   c4ca0: e1a01004     	mov	r1, r4
   c4ca4: eb012a26     	bl	0x10f544 <.text+0xff444> @ imm = #0x4a898
   c4ca8: e1a00005     	mov	r0, r5
   c4cac: eb138515     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e1454
   c4cb0: e1a00006     	mov	r0, r6
   c4cb4: e1a01005     	mov	r1, r5
   c4cb8: e1a02004     	mov	r2, r4
   c4cbc: eb137fc5     	bl	0x5a4bd8 <.text+0x594ad8> @ imm = #0x4dff14
   c4cc0: e1a00005     	mov	r0, r5
   c4cc4: eb13867e     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e19f8
   c4cc8: eaffffd0     	b	0xc4c10 <.text+0xb4b10> @ imm = #-0xc0
   c4ccc: e59d0008     	ldr	r0, [sp, #0x8]
   c4cd0: e3500001     	cmp	r0, #1
   c4cd4: baffffb8     	blt	0xc4bbc <.text+0xb4abc> @ imm = #-0x120
   c4cd8: e59da008     	ldr	r10, [sp, #0x8]
   c4cdc: e3a05fae     	mov	r5, #696
   c4ce0: ea000002     	b	0xc4cf0 <.text+0xb4bf0> @ imm = #0x8
   c4ce4: e25aa001     	subs	r10, r10, #1
   c4ce8: e2855e32     	add	r5, r5, #800
   c4cec: 0affffb2     	beq	0xc4bbc <.text+0xb4abc> @ imm = #-0x138
   c4cf0: e59d000c     	ldr	r0, [sp, #0xc]
   c4cf4: e5900230     	ldr	r0, [r0, #0x230]
   c4cf8: e0800005     	add	r0, r0, r5
   c4cfc: e58d001c     	str	r0, [sp, #0x1c]
   c4d00: e2400fae     	sub	r0, r0, #696
   c4d04: ebfe48b0     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x6dd40
   c4d08: e3500000     	cmp	r0, #0
   c4d0c: 0afffff4     	beq	0xc4ce4 <.text+0xb4be4> @ imm = #-0x30
   c4d10: e1a00007     	mov	r0, r7
   c4d14: eb1384fb     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e13ec
   c4d18: e1a00007     	mov	r0, r7
   c4d1c: e5974018     	ldr	r4, [r7, #0x18]
   c4d20: e597901c     	ldr	r9, [r7, #0x1c]
   c4d24: eb138666     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1998
   c4d28: e1540009     	cmp	r4, r9
   c4d2c: 0a0000b3     	beq	0xc5000 <.text+0xb4f00> @ imm = #0x2cc
   c4d30: e1a00007     	mov	r0, r7
   c4d34: eb1384f3     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e13cc
   c4d38: e1a00007     	mov	r0, r7
   c4d3c: e597401c     	ldr	r4, [r7, #0x1c]
   c4d40: eb13865f     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e197c
   c4d44: e1a00424     	lsr	r0, r4, #8
   c4d48: e3500002     	cmp	r0, #2
   c4d4c: 8a0000ab     	bhi	0xc5000 <.text+0xb4f00> @ imm = #0x2ac
   c4d50: e3a000a8     	mov	r0, #168
   c4d54: e0207094     	mla	r0, r4, r0, r7
   c4d58: e2909020     	adds	r9, r0, #32
   c4d5c: 0a0000a7     	beq	0xc5000 <.text+0xb4f00> @ imm = #0x29c
   c4d60: e59f02f4     	ldr	r0, [pc, #0x2f4]        @ 0xc505c <.text+0xb4f5c>
   c4d64: e79f0000     	ldr	r0, [pc, r0]
   c4d68: e5900000     	ldr	r0, [r0]
   c4d6c: e2401001     	sub	r1, r0, #1
   c4d70: e0000190     	mul	r0, r0, r1
   c4d74: e3100001     	tst	r0, #1
   c4d78: 0a000004     	beq	0xc4d90 <.text+0xb4c90> @ imm = #0x10
   c4d7c: e59f02dc     	ldr	r0, [pc, #0x2dc]        @ 0xc5060 <.text+0xb4f60>
   c4d80: e79f0000     	ldr	r0, [pc, r0]
   c4d84: e5900000     	ldr	r0, [r0]
   c4d88: e3500009     	cmp	r0, #9
   c4d8c: ca000052     	bgt	0xc4edc <.text+0xb4ddc> @ imm = #0x148
   c4d90: e59f42cc     	ldr	r4, [pc, #0x2cc]        @ 0xc5064 <.text+0xb4f64>
   c4d94: e3a000a8     	mov	r0, #168
   c4d98: e1a01009     	mov	r1, r9
   c4d9c: e3a020a8     	mov	r2, #168
   c4da0: e79f4004     	ldr	r4, [pc, r4]
   c4da4: e59f82bc     	ldr	r8, [pc, #0x2bc]        @ 0xc5068 <.text+0xb4f68>
   c4da8: e08f8008     	add	r8, pc, r8
   c4dac: e0208094     	mla	r0, r4, r0, r8
   c4db0: e2806008     	add	r6, r0, #8
   c4db4: e1a00006     	mov	r0, r6
   c4db8: eb13784a     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4de128
   c4dbc: e59f02a8     	ldr	r0, [pc, #0x2a8]        @ 0xc506c <.text+0xb4f6c>
   c4dc0: e79f0000     	ldr	r0, [pc, r0]
   c4dc4: e2800001     	add	r0, r0, #1
   c4dc8: e350001f     	cmp	r0, #31
   c4dcc: 83000000     	movwhi	r0, #0x0
   c4dd0: e5880000     	str	r0, [r8]
   c4dd4: e1a00007     	mov	r0, r7
   c4dd8: eb1384ca     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e1328
   c4ddc: e597001c     	ldr	r0, [r7, #0x1c]
   c4de0: e2800001     	add	r0, r0, #1
   c4de4: e1a01420     	lsr	r1, r0, #8
   c4de8: e3510002     	cmp	r1, #2
   c4dec: 83000000     	movwhi	r0, #0x0
   c4df0: e587001c     	str	r0, [r7, #0x1c]
   c4df4: e1a00007     	mov	r0, r7
   c4df8: eb138631     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e18c4
   c4dfc: e1a00184     	lsl	r0, r4, #3
   c4e00: e354001f     	cmp	r4, #31
   c4e04: e5cd0024     	strb	r0, [sp, #0x24]
   c4e08: e30a0a55     	movw	r0, #0xaa55
   c4e0c: e1cd02b0     	strh	r0, [sp, #32]
   c4e10: e3a00000     	mov	r0, #0
   c4e14: e58d0026     	str	r0, [sp, #0x26]
   c4e18: e3a00001     	mov	r0, #1
   c4e1c: e5cd0025     	strb	r0, [sp, #0x25]
   c4e20: e3030621     	movw	r0, #0x3621
   c4e24: 83006000     	movwhi	r6, #0x0
   c4e28: e2862040     	add	r2, r6, #64
   c4e2c: e1cd02b2     	strh	r0, [sp, #34]
   c4e30: e8920007     	ldm	r2, {r0, r1, r2}
   c4e34: e58d002a     	str	r0, [sp, #0x2a]
   c4e38: e5960000     	ldr	r0, [r6]
   c4e3c: e58d0036     	str	r0, [sp, #0x36]
   c4e40: e59d0014     	ldr	r0, [sp, #0x14]
   c4e44: e58d102e     	str	r1, [sp, #0x2e]
   c4e48: e2861004     	add	r1, r6, #4
   c4e4c: e58d2032     	str	r2, [sp, #0x32]
   c4e50: e3a02020     	mov	r2, #32
   c4e54: eb137823     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4de08c
   c4e58: e59d0018     	ldr	r0, [sp, #0x18]
   c4e5c: e2861024     	add	r1, r6, #36
   c4e60: e3a0201c     	mov	r2, #28
   c4e64: eb13781f     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4de07c
   c4e68: e59d4010     	ldr	r4, [sp, #0x10]
   c4e6c: e3a01054     	mov	r1, #84
   c4e70: e30f2fff     	movw	r2, #0xffff
   c4e74: e1a00004     	mov	r0, r4
   c4e78: eb00cbdd     	bl	0xf7df4 <.text+0xe7cf4> @ imm = #0x32f74
   c4e7c: e1a06000     	mov	r6, r0
   c4e80: e1a00004     	mov	r0, r4
   c4e84: e3a01054     	mov	r1, #84
   c4e88: e30f2fff     	movw	r2, #0xffff
   c4e8c: eb00cbd8     	bl	0xf7df4 <.text+0xe7cf4> @ imm = #0x32f60
   c4e90: e1a00420     	lsr	r0, r0, #8
   c4e94: e28d1020     	add	r1, sp, #32
   c4e98: e1800406     	orr	r0, r0, r6, lsl #8
   c4e9c: e1cd07b6     	strh	r0, [sp, #118]
   c4ea0: e59d001c     	ldr	r0, [sp, #0x1c]
   c4ea4: e3a02058     	mov	r2, #88
   c4ea8: eb00e817     	bl	0xfef0c <.text+0xeee0c> @ imm = #0x3a05c
   c4eac: e59f01bc     	ldr	r0, [pc, #0x1bc]        @ 0xc5070 <.text+0xb4f70>
   c4eb0: e79f0000     	ldr	r0, [pc, r0]
   c4eb4: e5900000     	ldr	r0, [r0]
   c4eb8: e2401001     	sub	r1, r0, #1
   c4ebc: e0000190     	mul	r0, r0, r1
   c4ec0: e3100001     	tst	r0, #1
   c4ec4: 0affff86     	beq	0xc4ce4 <.text+0xb4be4> @ imm = #-0x1e8
   c4ec8: e59f01a4     	ldr	r0, [pc, #0x1a4]        @ 0xc5074 <.text+0xb4f74>
   c4ecc: e79f0000     	ldr	r0, [pc, r0]
   c4ed0: e5900000     	ldr	r0, [r0]
   c4ed4: e350000a     	cmp	r0, #10
   c4ed8: baffff81     	blt	0xc4ce4 <.text+0xb4be4> @ imm = #-0x1fc
   c4edc: e59f41a4     	ldr	r4, [pc, #0x1a4]        @ 0xc5088 <.text+0xb4f88>
   c4ee0: e3a000a8     	mov	r0, #168
   c4ee4: e3a020a8     	mov	r2, #168
   c4ee8: e79f4004     	ldr	r4, [pc, r4]
   c4eec: e59f1198     	ldr	r1, [pc, #0x198]        @ 0xc508c <.text+0xb4f8c>
   c4ef0: e08f1001     	add	r1, pc, r1
   c4ef4: e0201094     	mla	r0, r4, r0, r1
   c4ef8: e1a08001     	mov	r8, r1
   c4efc: e1a01009     	mov	r1, r9
   c4f00: e2806008     	add	r6, r0, #8
   c4f04: e1a00006     	mov	r0, r6
   c4f08: eb1377f6     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4ddfd8
   c4f0c: e59f017c     	ldr	r0, [pc, #0x17c]        @ 0xc5090 <.text+0xb4f90>
   c4f10: e79f0000     	ldr	r0, [pc, r0]
   c4f14: e2800001     	add	r0, r0, #1
   c4f18: e350001f     	cmp	r0, #31
   c4f1c: 83000000     	movwhi	r0, #0x0
   c4f20: e5880000     	str	r0, [r8]
   c4f24: e1a00007     	mov	r0, r7
   c4f28: eb138476     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4e11d8
   c4f2c: e597001c     	ldr	r0, [r7, #0x1c]
   c4f30: e2800001     	add	r0, r0, #1
   c4f34: e1a01420     	lsr	r1, r0, #8
   c4f38: e3510002     	cmp	r1, #2
   c4f3c: 83000000     	movwhi	r0, #0x0
   c4f40: e587001c     	str	r0, [r7, #0x1c]
   c4f44: e1a00007     	mov	r0, r7
   c4f48: eb1385dd     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1774
   c4f4c: e1a00184     	lsl	r0, r4, #3
   c4f50: e354001f     	cmp	r4, #31
   c4f54: e5cd0024     	strb	r0, [sp, #0x24]
   c4f58: e30a0a55     	movw	r0, #0xaa55
   c4f5c: e1cd02b0     	strh	r0, [sp, #32]
   c4f60: e3a00000     	mov	r0, #0
   c4f64: e58d0026     	str	r0, [sp, #0x26]
   c4f68: e3a00001     	mov	r0, #1
   c4f6c: e5cd0025     	strb	r0, [sp, #0x25]
   c4f70: e3030621     	movw	r0, #0x3621
   c4f74: 83006000     	movwhi	r6, #0x0
   c4f78: e2862040     	add	r2, r6, #64
   c4f7c: e1cd02b2     	strh	r0, [sp, #34]
   c4f80: e8920007     	ldm	r2, {r0, r1, r2}
   c4f84: e58d002a     	str	r0, [sp, #0x2a]
   c4f88: e5960000     	ldr	r0, [r6]
   c4f8c: e58d0036     	str	r0, [sp, #0x36]
   c4f90: e59d0014     	ldr	r0, [sp, #0x14]
   c4f94: e58d102e     	str	r1, [sp, #0x2e]
   c4f98: e2861004     	add	r1, r6, #4
   c4f9c: e58d2032     	str	r2, [sp, #0x32]
   c4fa0: e3a02020     	mov	r2, #32
   c4fa4: eb1377cf     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4ddf3c
   c4fa8: e59d0018     	ldr	r0, [sp, #0x18]
   c4fac: e2861024     	add	r1, r6, #36
   c4fb0: e3a0201c     	mov	r2, #28
   c4fb4: eb1377cb     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4ddf2c
   c4fb8: e59d4010     	ldr	r4, [sp, #0x10]
   c4fbc: e3a01054     	mov	r1, #84
   c4fc0: e30f2fff     	movw	r2, #0xffff
   c4fc4: e1a00004     	mov	r0, r4
   c4fc8: eb00cb89     	bl	0xf7df4 <.text+0xe7cf4> @ imm = #0x32e24
   c4fcc: e1a06000     	mov	r6, r0
   c4fd0: e1a00004     	mov	r0, r4
   c4fd4: e3a01054     	mov	r1, #84
   c4fd8: e30f2fff     	movw	r2, #0xffff
   c4fdc: eb00cb84     	bl	0xf7df4 <.text+0xe7cf4> @ imm = #0x32e10
   c4fe0: e1a00420     	lsr	r0, r0, #8
   c4fe4: e28d1020     	add	r1, sp, #32
   c4fe8: e1800406     	orr	r0, r0, r6, lsl #8
   c4fec: e1cd07b6     	strh	r0, [sp, #118]
   c4ff0: e59d001c     	ldr	r0, [sp, #0x1c]
   c4ff4: e3a02058     	mov	r2, #88
   c4ff8: eb00e7c3     	bl	0xfef0c <.text+0xeee0c> @ imm = #0x39f0c
   c4ffc: eaffff63     	b	0xc4d90 <.text+0xb4c90> @ imm = #-0x274
   c5000: e59f0070     	ldr	r0, [pc, #0x70]         @ 0xc5078 <.text+0xb4f78>
   c5004: e79f0000     	ldr	r0, [pc, r0]
   c5008: e5900000     	ldr	r0, [r0]
   c500c: e2401001     	sub	r1, r0, #1
   c5010: e0000190     	mul	r0, r0, r1
   c5014: e3100001     	tst	r0, #1
   c5018: 0afffee7     	beq	0xc4bbc <.text+0xb4abc> @ imm = #-0x464
   c501c: e59f0058     	ldr	r0, [pc, #0x58]         @ 0xc507c <.text+0xb4f7c>
   c5020: e79f0000     	ldr	r0, [pc, r0]
   c5024: e5900000     	ldr	r0, [r0]
   c5028: e350000a     	cmp	r0, #10
   c502c: aafffff3     	bge	0xc5000 <.text+0xb4f00> @ imm = #-0x34
   c5030: eafffee1     	b	0xc4bbc <.text+0xb4abc> @ imm = #-0x47c
   c5034: e3a00000     	mov	r0, #0
   c5038: eb1380a4     	bl	0x5a52d0 <.text+0x5951d0> @ imm = #0x4e0290
   c503c: 00524c11     	subseq	r4, r2, r1, lsl r12
   c5040: 0056eff4     	ldrsheq	lr, [r6], #-244
   c5044: 0056f008     	subseq	pc, r6, r8
   c5048: 0056f034     	subseq	pc, r6, r4, lsr r0
   c504c: 0051a398     	<unknown>
   c5050: 0051a758     	subseq	r10, r1, r8, asr r7
   c5054: 0051a324     	subseq	r10, r1, r4, lsr #6
   c5058: 0051a6e4     	subseq	r10, r1, r4, ror #13
   c505c: 0051a218     	subseq	r10, r1, r8, lsl r2
   c5060: 0051a5d8     	ldrsbeq	r10, [r1], #-88
   c5064: 0058e6b0     	ldrheq	lr, [r8], #-96
   c5068: 0058e6a8     	subseq	lr, r8, r8, lsr #13
   c506c: 0058e690     	<unknown>
   c5070: 0051a0cc     	subseq	r10, r1, r12, asr #1
   c5074: 0051a48c     	subseq	r10, r1, r12, lsl #9
   c5078: 00519f78     	subseq	r9, r1, r8, ror pc
   c507c: 0051a338     	subseq	r10, r1, r8, lsr r3
   c5080: 0056efcc     	subseq	lr, r6, r12, asr #31
   c5084: 0056efe0     	subseq	lr, r6, r0, ror #31
   c5088: 0058e568     	subseq	lr, r8, r8, ror #10
   c508c: 0058e560     	subseq	lr, r8, r0, ror #10
   c5090: 0058e540     	subseq	lr, r8, r0, asr #10

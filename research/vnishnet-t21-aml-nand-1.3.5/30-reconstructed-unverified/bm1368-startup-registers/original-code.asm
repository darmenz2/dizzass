# L16: static disassembly of selected code; literal/data regions use directives.
# No instruction execution or automatic C-equivalence claim.

# analog-body 0xe35c0..0xe36fc (code)
   e35c0: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   e35c4: e28db018     	add	r11, sp, #24
   e35c8: e24dd010     	sub	sp, sp, #16
   e35cc: e1a04000     	mov	r4, r0
   e35d0: e2010007     	and	r0, r1, #7
   e35d4: e58d0000     	str	r0, [sp]
   e35d8: e1a00004     	mov	r0, r4
   e35dc: e3a01001     	mov	r1, #1
   e35e0: e3a02000     	mov	r2, #0
   e35e4: e3a03054     	mov	r3, #84
   e35e8: e3a05000     	mov	r5, #0
   e35ec: eb000520     	bl	0xe4a74 <.text+0xd4974> @ imm = #0x1480
   e35f0: e3500000     	cmp	r0, #0
   e35f4: 0a000031     	beq	0xe36c0 <.text+0xd35c0> @ imm = #0xc4
   e35f8: e59f80fc     	ldr	r8, [pc, #0xfc]         @ 0xe36fc <.text+0xd35fc>
   e35fc: e79f8008     	ldr	r8, [pc, r8]
   e3600: e5980000     	ldr	r0, [r8]
   e3604: e59f70f4     	ldr	r7, [pc, #0xf4]         @ 0xe3700 <.text+0xd3600>
   e3608: e2401001     	sub	r1, r0, #1
   e360c: e0000190     	mul	r0, r0, r1
   e3610: e79f7007     	ldr	r7, [pc, r7]
   e3614: e59f60e8     	ldr	r6, [pc, #0xe8]         @ 0xe3704 <.text+0xd3604>
   e3618: e08f6006     	add	r6, pc, r6
   e361c: e3100001     	tst	r0, #1
   e3620: 0a000002     	beq	0xe3630 <.text+0xd3530> @ imm = #0x8
   e3624: e5970000     	ldr	r0, [r7]
   e3628: e3500009     	cmp	r0, #9
   e362c: ca000015     	bgt	0xe3688 <.text+0xd3588> @ imm = #0x54
   e3630: e59f00d0     	ldr	r0, [pc, #0xd0]         @ 0xe3708 <.text+0xd3608>
   e3634: e3a05001     	mov	r5, #1
   e3638: e59f10cc     	ldr	r1, [pc, #0xcc]         @ 0xe370c <.text+0xd360c>
   e363c: e59f20cc     	ldr	r2, [pc, #0xcc]         @ 0xe3710 <.text+0xd3610>
   e3640: e08f0000     	add	r0, pc, r0
   e3644: e5943018     	ldr	r3, [r4, #0x18]
   e3648: e08f1001     	add	r1, pc, r1
   e364c: e08f2002     	add	r2, pc, r2
   e3650: e88d0060     	stm	sp, {r5, r6}
   e3654: e2833001     	add	r3, r3, #1
   e3658: e58d3008     	str	r3, [sp, #0x8]
   e365c: e30031a9     	movw	r3, #0x1a9
   e3660: eb005a97     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x16a5c
   e3664: e5980000     	ldr	r0, [r8]
   e3668: e3e05000     	mvn	r5, #0
   e366c: e2401001     	sub	r1, r0, #1
   e3670: e0000190     	mul	r0, r0, r1
   e3674: e3100001     	tst	r0, #1
   e3678: 0a000010     	beq	0xe36c0 <.text+0xd35c0> @ imm = #0x40
   e367c: e5970000     	ldr	r0, [r7]
   e3680: e3500009     	cmp	r0, #9
   e3684: da00000d     	ble	0xe36c0 <.text+0xd35c0> @ imm = #0x34
   e3688: e59f008c     	ldr	r0, [pc, #0x8c]         @ 0xe371c <.text+0xd361c>
   e368c: e3a05001     	mov	r5, #1
   e3690: e59f1088     	ldr	r1, [pc, #0x88]         @ 0xe3720 <.text+0xd3620>
   e3694: e59f2088     	ldr	r2, [pc, #0x88]         @ 0xe3724 <.text+0xd3624>
   e3698: e08f0000     	add	r0, pc, r0
   e369c: e5943018     	ldr	r3, [r4, #0x18]
   e36a0: e08f1001     	add	r1, pc, r1
   e36a4: e08f2002     	add	r2, pc, r2
   e36a8: e88d0060     	stm	sp, {r5, r6}
   e36ac: e2833001     	add	r3, r3, #1
   e36b0: e58d3008     	str	r3, [sp, #0x8]
   e36b4: e30031a9     	movw	r3, #0x1a9
   e36b8: eb005a81     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x16a04
   e36bc: eaffffdb     	b	0xe3630 <.text+0xd3530> @ imm = #-0x94
   e36c0: e59f004c     	ldr	r0, [pc, #0x4c]         @ 0xe3714 <.text+0xd3614>
   e36c4: e79f0000     	ldr	r0, [pc, r0]
   e36c8: e59f1048     	ldr	r1, [pc, #0x48]         @ 0xe3718 <.text+0xd3618>
   e36cc: e79f1001     	ldr	r1, [pc, r1]
   e36d0: e5902000     	ldr	r2, [r0]
   e36d4: e2423001     	sub	r3, r2, #1
   e36d8: e0020392     	mul	r2, r2, r3
   e36dc: e3120001     	tst	r2, #1
   e36e0: 0a000002     	beq	0xe36f0 <.text+0xd35f0> @ imm = #0x8
   e36e4: e5912000     	ldr	r2, [r1]
   e36e8: e3520009     	cmp	r2, #9
   e36ec: cafffff7     	bgt	0xe36d0 <.text+0xd35d0> @ imm = #-0x24
   e36f0: e1a00005     	mov	r0, r5
   e36f4: e24bd018     	sub	sp, r11, #24
   e36f8: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}

# analog-literals 0xe36fc..0xe3728 (data)
000e36fc: .byte 0xa0,0xb7,0x4f,0x00,0x0c,0xbb,0x4f,0x00,0x22,0x7e,0x50,0x00,0x98,0x7d,0x50,0x00
000e370c: .byte 0x97,0x7d,0x50,0x00,0xbd,0x7d,0x50,0x00,0xd8,0xb6,0x4f,0x00,0x50,0xba,0x4f,0x00
000e371c: .byte 0x40,0x7d,0x50,0x00,0x3f,0x7d,0x50,0x00,0x65,0x7d,0x50,0x00

# nonce-body 0xe3098..0xe3258 (code)
   e3098: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   e309c: e28db01c     	add	r11, sp, #28
   e30a0: e24dd00c     	sub	sp, sp, #12
   e30a4: e1a04000     	mov	r4, r0
   e30a8: e2210001     	eor	r0, r1, #1
   e30ac: e3081dee     	movw	r1, #0x8dee
   e30b0: e3a02000     	mov	r2, #0
   e30b4: e3481000     	movt	r1, #0x8000
   e30b8: e1800001     	orr	r0, r0, r1
   e30bc: e58d0000     	str	r0, [sp]
   e30c0: e1a00004     	mov	r0, r4
   e30c4: e3a01001     	mov	r1, #1
   e30c8: e3a0303c     	mov	r3, #60
   e30cc: e3a05000     	mov	r5, #0
   e30d0: eb000667     	bl	0xe4a74 <.text+0xd4974> @ imm = #0x199c
   e30d4: e3500000     	cmp	r0, #0
   e30d8: 0a00004f     	beq	0xe321c <.text+0xd311c> @ imm = #0x13c
   e30dc: e59f0174     	ldr	r0, [pc, #0x174]        @ 0xe3258 <.text+0xd3158>
   e30e0: e79f0000     	ldr	r0, [pc, r0]
   e30e4: e5900000     	ldr	r0, [r0]
   e30e8: e59fa16c     	ldr	r10, [pc, #0x16c]       @ 0xe325c <.text+0xd315c>
   e30ec: e2401001     	sub	r1, r0, #1
   e30f0: e59f9168     	ldr	r9, [pc, #0x168]        @ 0xe3260 <.text+0xd3160>
   e30f4: e08fa00a     	add	r10, pc, r10
   e30f8: e0000190     	mul	r0, r0, r1
   e30fc: e08f9009     	add	r9, pc, r9
   e3100: e3100001     	tst	r0, #1
   e3104: 0a000004     	beq	0xe311c <.text+0xd301c> @ imm = #0x10
   e3108: e59f0154     	ldr	r0, [pc, #0x154]        @ 0xe3264 <.text+0xd3164>
   e310c: e79f0000     	ldr	r0, [pc, r0]
   e3110: e5900000     	ldr	r0, [r0]
   e3114: e3500009     	cmp	r0, #9
   e3118: ca000025     	bgt	0xe31b4 <.text+0xd30b4> @ imm = #0x94
   e311c: e59f5144     	ldr	r5, [pc, #0x144]        @ 0xe3268 <.text+0xd3168>
   e3120: e3a08001     	mov	r8, #1
   e3124: e59f6140     	ldr	r6, [pc, #0x140]        @ 0xe326c <.text+0xd316c>
   e3128: e3003183     	movw	r3, #0x183
   e312c: e59f713c     	ldr	r7, [pc, #0x13c]        @ 0xe3270 <.text+0xd3170>
   e3130: e08f5005     	add	r5, pc, r5
   e3134: e5940018     	ldr	r0, [r4, #0x18]
   e3138: e08f6006     	add	r6, pc, r6
   e313c: e08f7007     	add	r7, pc, r7
   e3140: e88d0500     	stm	sp, {r8, r10}
   e3144: e2800001     	add	r0, r0, #1
   e3148: e58d0008     	str	r0, [sp, #0x8]
   e314c: e1a00005     	mov	r0, r5
   e3150: e1a01006     	mov	r1, r6
   e3154: e1a02007     	mov	r2, r7
   e3158: eb005bd9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x16f64
   e315c: e5940018     	ldr	r0, [r4, #0x18]
   e3160: e1a01006     	mov	r1, r6
   e3164: e88d0300     	stm	sp, {r8, r9}
   e3168: e1a02007     	mov	r2, r7
   e316c: e2800001     	add	r0, r0, #1
   e3170: e58d0008     	str	r0, [sp, #0x8]
   e3174: e1a00005     	mov	r0, r5
   e3178: e3003251     	movw	r3, #0x251
   e317c: eb005bd0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x16f40
   e3180: e59f00ec     	ldr	r0, [pc, #0xec]         @ 0xe3274 <.text+0xd3174>
   e3184: e3e05000     	mvn	r5, #0
   e3188: e79f0000     	ldr	r0, [pc, r0]
   e318c: e5900000     	ldr	r0, [r0]
   e3190: e2401001     	sub	r1, r0, #1
   e3194: e0000190     	mul	r0, r0, r1
   e3198: e3100001     	tst	r0, #1
   e319c: 0a00001e     	beq	0xe321c <.text+0xd311c> @ imm = #0x78
   e31a0: e59f00d0     	ldr	r0, [pc, #0xd0]         @ 0xe3278 <.text+0xd3178>
   e31a4: e79f0000     	ldr	r0, [pc, r0]
   e31a8: e5900000     	ldr	r0, [r0]
   e31ac: e3500009     	cmp	r0, #9
   e31b0: da000019     	ble	0xe321c <.text+0xd311c> @ imm = #0x64
   e31b4: e59f80c8     	ldr	r8, [pc, #0xc8]         @ 0xe3284 <.text+0xd3184>
   e31b8: e3a05001     	mov	r5, #1
   e31bc: e59f60c4     	ldr	r6, [pc, #0xc4]         @ 0xe3288 <.text+0xd3188>
   e31c0: e3003183     	movw	r3, #0x183
   e31c4: e59f70c0     	ldr	r7, [pc, #0xc0]         @ 0xe328c <.text+0xd318c>
   e31c8: e08f8008     	add	r8, pc, r8
   e31cc: e5940018     	ldr	r0, [r4, #0x18]
   e31d0: e08f6006     	add	r6, pc, r6
   e31d4: e08f7007     	add	r7, pc, r7
   e31d8: e88d0420     	stm	sp, {r5, r10}
   e31dc: e2800001     	add	r0, r0, #1
   e31e0: e58d0008     	str	r0, [sp, #0x8]
   e31e4: e1a00008     	mov	r0, r8
   e31e8: e1a01006     	mov	r1, r6
   e31ec: e1a02007     	mov	r2, r7
   e31f0: eb005bb3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x16ecc
   e31f4: e5940018     	ldr	r0, [r4, #0x18]
   e31f8: e1a01006     	mov	r1, r6
   e31fc: e88d0220     	stm	sp, {r5, r9}
   e3200: e1a02007     	mov	r2, r7
   e3204: e2800001     	add	r0, r0, #1
   e3208: e58d0008     	str	r0, [sp, #0x8]
   e320c: e1a00008     	mov	r0, r8
   e3210: e3003251     	movw	r3, #0x251
   e3214: eb005baa     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x16ea8
   e3218: eaffffbf     	b	0xe311c <.text+0xd301c> @ imm = #-0x104
   e321c: e59f0058     	ldr	r0, [pc, #0x58]         @ 0xe327c <.text+0xd317c>
   e3220: e79f0000     	ldr	r0, [pc, r0]
   e3224: e59f1054     	ldr	r1, [pc, #0x54]         @ 0xe3280 <.text+0xd3180>
   e3228: e79f1001     	ldr	r1, [pc, r1]
   e322c: e5902000     	ldr	r2, [r0]
   e3230: e2423001     	sub	r3, r2, #1
   e3234: e0020392     	mul	r2, r2, r3
   e3238: e3120001     	tst	r2, #1
   e323c: 0a000002     	beq	0xe324c <.text+0xd314c> @ imm = #0x8
   e3240: e5912000     	ldr	r2, [r1]
   e3244: e3520009     	cmp	r2, #9
   e3248: cafffff7     	bgt	0xe322c <.text+0xd312c> @ imm = #-0x24
   e324c: e1a00005     	mov	r0, r5
   e3250: e24bd01c     	sub	sp, r11, #28
   e3254: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}

# nonce-literals 0xe3258..0xe3290 (data)
000e3258: .byte 0x44,0xc1,0x4f,0x00,0xb4,0x87,0x50,0x00,0xe0,0x83,0x50,0x00,0x24,0xbb,0x4f,0x00
000e3268: .byte 0xa8,0x82,0x50,0x00,0xa7,0x82,0x50,0x00,0xcd,0x82,0x50,0x00,0x9c,0xc0,0x4f,0x00
000e3278: .byte 0x8c,0xba,0x4f,0x00,0x04,0xc0,0x4f,0x00,0x08,0xba,0x4f,0x00,0x10,0x82,0x50,0x00
000e3288: .byte 0x0f,0x82,0x50,0x00,0x35,0x82,0x50,0x00

# pattern-body 0xe3290..0xe32c0 (code)
   e3290: e92d4800     	push	{r11, lr}
   e3294: e1a0b00d     	mov	r11, sp
   e3298: e24dd008     	sub	sp, sp, #8
   e329c: e3051aa5     	movw	r1, #0x5aa5
   e32a0: e3a02000     	mov	r2, #0
   e32a4: e3451aa5     	movt	r1, #0x5aa5
   e32a8: e3a03068     	mov	r3, #104
   e32ac: e58d1000     	str	r1, [sp]
   e32b0: e3a01001     	mov	r1, #1
   e32b4: eb0005ee     	bl	0xe4a74 <.text+0xd4974> @ imm = #0x17b8
   e32b8: e1a0d00b     	mov	sp, r11
   e32bc: e8bd8800     	pop	{r11, pc}

# rmw-body 0xe3c04..0xe3dd0 (code)
   e3c04: e92d4bf0     	push	{r4, r5, r6, r7, r8, r9, r11, lr}
   e3c08: e28db018     	add	r11, sp, #24
   e3c0c: e24dd010     	sub	sp, sp, #16
   e3c10: e1a04000     	mov	r4, r0
   e3c14: e5900018     	ldr	r0, [r0, #0x18]
   e3c18: e28d200c     	add	r2, sp, #12
   e3c1c: e1a08001     	mov	r8, r1
   e3c20: e3a010a8     	mov	r1, #168
   e3c24: eb008d57     	bl	0x107188 <.text+0xf7088> @ imm = #0x2355c
   e3c28: e3e05000     	mvn	r5, #0
   e3c2c: e3500000     	cmp	r0, #0
   e3c30: 1a000063     	bne	0xe3dc4 <.text+0xd3cc4> @ imm = #0x18c
   e3c34: e5940018     	ldr	r0, [r4, #0x18]
   e3c38: e28d2008     	add	r2, sp, #8
   e3c3c: e3a01018     	mov	r1, #24
   e3c40: eb008d50     	bl	0x107188 <.text+0xf7088> @ imm = #0x23540
   e3c44: e3500000     	cmp	r0, #0
   e3c48: 1a00005d     	bne	0xe3dc4 <.text+0xd3cc4> @ imm = #0x174
   e3c4c: e59f917c     	ldr	r9, [pc, #0x17c]        @ 0xe3dd0 <.text+0xd3cd0>
   e3c50: e79f9009     	ldr	r9, [pc, r9]
   e3c54: e5990000     	ldr	r0, [r9]
   e3c58: e2401001     	sub	r1, r0, #1
   e3c5c: e0000190     	mul	r0, r0, r1
   e3c60: e3100001     	tst	r0, #1
   e3c64: e5990000     	ldr	r0, [r9]
   e3c68: e59f6164     	ldr	r6, [pc, #0x164]        @ 0xe3dd4 <.text+0xd3cd4>
   e3c6c: e2401001     	sub	r1, r0, #1
   e3c70: e0010190     	mul	r1, r0, r1
   e3c74: e79f6006     	ldr	r6, [pc, r6]
   e3c78: e59d000c     	ldr	r0, [sp, #0xc]
   e3c7c: e3110001     	tst	r1, #1
   e3c80: 0a000002     	beq	0xe3c90 <.text+0xd3b90> @ imm = #0x8
   e3c84: e5961000     	ldr	r1, [r6]
   e3c88: e3510009     	cmp	r1, #9
   e3c8c: cafffff4     	bgt	0xe3c64 <.text+0xd3b64> @ imm = #-0x30
   e3c90: e3580000     	cmp	r8, #0
   e3c94: 0a000008     	beq	0xe3cbc <.text+0xd3bbc> @ imm = #0x20
   e3c98: e5991000     	ldr	r1, [r9]
   e3c9c: e2412001     	sub	r2, r1, #1
   e3ca0: e0010291     	mul	r1, r1, r2
   e3ca4: e3110001     	tst	r1, #1
   e3ca8: 0a000009     	beq	0xe3cd4 <.text+0xd3bd4> @ imm = #0x24
   e3cac: e5961000     	ldr	r1, [r6]
   e3cb0: e3510009     	cmp	r1, #9
   e3cb4: ca000013     	bgt	0xe3d08 <.text+0xd3c08> @ imm = #0x4c
   e3cb8: ea000005     	b	0xe3cd4 <.text+0xd3bd4> @ imm = #0x14
   e3cbc: e59d2008     	ldr	r2, [sp, #0x8]
   e3cc0: e3c010f0     	bic	r1, r0, #240
   e3cc4: e58d100c     	str	r1, [sp, #0xc]
   e3cc8: e382080f     	orr	r0, r2, #983040
   e3ccc: e38024ff     	orr	r2, r0, #-16777216
   e3cd0: ea000010     	b	0xe3d18 <.text+0xd3c18> @ imm = #0x40
   e3cd4: e5991000     	ldr	r1, [r9]
   e3cd8: e5963000     	ldr	r3, [r6]
   e3cdc: e2412001     	sub	r2, r1, #1
   e3ce0: e0070291     	mul	r7, r1, r2
   e3ce4: e59d2008     	ldr	r2, [sp, #0x8]
   e3ce8: e300110f     	movw	r1, #0x10f
   e3cec: e1801001     	orr	r1, r0, r1
   e3cf0: e3c2260f     	bic	r2, r2, #15728640
   e3cf4: e58d100c     	str	r1, [sp, #0xc]
   e3cf8: e3170001     	tst	r7, #1
   e3cfc: 0a000005     	beq	0xe3d18 <.text+0xd3c18> @ imm = #0x14
   e3d00: e353000a     	cmp	r3, #10
   e3d04: ba000003     	blt	0xe3d18 <.text+0xd3c18> @ imm = #0xc
   e3d08: e300110f     	movw	r1, #0x10f
   e3d0c: e1801001     	orr	r1, r0, r1
   e3d10: e58d100c     	str	r1, [sp, #0xc]
   e3d14: eaffffee     	b	0xe3cd4 <.text+0xd3bd4> @ imm = #-0x48
   e3d18: e58d2008     	str	r2, [sp, #0x8]
   e3d1c: e1a00004     	mov	r0, r4
   e3d20: e58d1000     	str	r1, [sp]
   e3d24: e3a01001     	mov	r1, #1
   e3d28: e3a02000     	mov	r2, #0
   e3d2c: e3a030a8     	mov	r3, #168
   e3d30: eb00034f     	bl	0xe4a74 <.text+0xd4974> @ imm = #0xd3c
   e3d34: e3500000     	cmp	r0, #0
   e3d38: 1a000021     	bne	0xe3dc4 <.text+0xd3cc4> @ imm = #0x84
   e3d3c: e5990000     	ldr	r0, [r9]
   e3d40: e2401001     	sub	r1, r0, #1
   e3d44: e0000190     	mul	r0, r0, r1
   e3d48: e3100001     	tst	r0, #1
   e3d4c: 0a000002     	beq	0xe3d5c <.text+0xd3c5c> @ imm = #0x8
   e3d50: e5960000     	ldr	r0, [r6]
   e3d54: e3500009     	cmp	r0, #9
   e3d58: ca000011     	bgt	0xe3da4 <.text+0xd3ca4> @ imm = #0x44
   e3d5c: e59d0008     	ldr	r0, [sp, #0x8]
   e3d60: e3a01001     	mov	r1, #1
   e3d64: e58d0000     	str	r0, [sp]
   e3d68: e1a00004     	mov	r0, r4
   e3d6c: e3a02000     	mov	r2, #0
   e3d70: e3a03018     	mov	r3, #24
   e3d74: eb00033e     	bl	0xe4a74 <.text+0xd4974> @ imm = #0xcf8
   e3d78: e1a05000     	mov	r5, r0
   e3d7c: e5990000     	ldr	r0, [r9]
   e3d80: e3550000     	cmp	r5, #0
   e3d84: e2401001     	sub	r1, r0, #1
   e3d88: 13e05000     	mvnne	r5, #0
   e3d8c: e0000190     	mul	r0, r0, r1
   e3d90: e3100001     	tst	r0, #1
   e3d94: 0a00000a     	beq	0xe3dc4 <.text+0xd3cc4> @ imm = #0x28
   e3d98: e5960000     	ldr	r0, [r6]
   e3d9c: e3500009     	cmp	r0, #9
   e3da0: da000007     	ble	0xe3dc4 <.text+0xd3cc4> @ imm = #0x1c
   e3da4: e59d0008     	ldr	r0, [sp, #0x8]
   e3da8: e3a01001     	mov	r1, #1
   e3dac: e58d0000     	str	r0, [sp]
   e3db0: e1a00004     	mov	r0, r4
   e3db4: e3a02000     	mov	r2, #0
   e3db8: e3a03018     	mov	r3, #24
   e3dbc: eb00032c     	bl	0xe4a74 <.text+0xd4974> @ imm = #0xcb0
   e3dc0: eaffffe5     	b	0xe3d5c <.text+0xd3c5c> @ imm = #-0x6c
   e3dc4: e1a00005     	mov	r0, r5
   e3dc8: e24bd018     	sub	sp, r11, #24
   e3dcc: e8bd8bf0     	pop	{r4, r5, r6, r7, r8, r9, r11, pc}

# rmw-literals 0xe3dd0..0xe3dd8 (data)
000e3dd0: .byte 0xd4,0xbf,0x4f,0x00,0x5c,0xb3,0x4f,0x00

# constructor-body 0xe1450..0xe16b8 (code)
   e1450: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
   e1454: e28db010     	add	r11, sp, #16
   e1458: e59f1258     	ldr	r1, [pc, #0x258]        @ 0xe16b8 <.text+0xd15b8>
   e145c: e79f1001     	ldr	r1, [pc, r1]
   e1460: e58010dc     	str	r1, [r0, #0xdc]
   e1464: e59fc250     	ldr	r12, [pc, #0x250]       @ 0xe16bc <.text+0xd15bc>
   e1468: e79fc00c     	ldr	r12, [pc, r12]
   e146c: e59fe24c     	ldr	lr, [pc, #0x24c]        @ 0xe16c0 <.text+0xd15c0>
   e1470: e79fe00e     	ldr	lr, [pc, lr]
   e1474: e59f3248     	ldr	r3, [pc, #0x248]        @ 0xe16c4 <.text+0xd15c4>
   e1478: e79f3003     	ldr	r3, [pc, r3]
   e147c: e59f1244     	ldr	r1, [pc, #0x244]        @ 0xe16c8 <.text+0xd15c8>
   e1480: e79f1001     	ldr	r1, [pc, r1]
   e1484: e59f2240     	ldr	r2, [pc, #0x240]        @ 0xe16cc <.text+0xd15cc>
   e1488: e79f2002     	ldr	r2, [pc, r2]
   e148c: e59f423c     	ldr	r4, [pc, #0x23c]        @ 0xe16d0 <.text+0xd15d0>
   e1490: e79f4004     	ldr	r4, [pc, r4]
   e1494: e59f5238     	ldr	r5, [pc, #0x238]        @ 0xe16d4 <.text+0xd15d4>
   e1498: e79f5005     	ldr	r5, [pc, r5]
   e149c: e59f6234     	ldr	r6, [pc, #0x234]        @ 0xe16d8 <.text+0xd15d8>
   e14a0: e79f6006     	ldr	r6, [pc, r6]
   e14a4: e58060bc     	str	r6, [r0, #0xbc]
   e14a8: e58050c0     	str	r5, [r0, #0xc0]
   e14ac: e58040c4     	str	r4, [r0, #0xc4]
   e14b0: e58020c8     	str	r2, [r0, #0xc8]
   e14b4: e28020cc     	add	r2, r0, #204
   e14b8: e882400a     	stm	r2, {r1, r3, lr}
   e14bc: e580c0d8     	str	r12, [r0, #0xd8]
   e14c0: e59fc214     	ldr	r12, [pc, #0x214]       @ 0xe16dc <.text+0xd15dc>
   e14c4: e79fc00c     	ldr	r12, [pc, r12]
   e14c8: e59fe210     	ldr	lr, [pc, #0x210]        @ 0xe16e0 <.text+0xd15e0>
   e14cc: e79fe00e     	ldr	lr, [pc, lr]
   e14d0: e59f320c     	ldr	r3, [pc, #0x20c]        @ 0xe16e4 <.text+0xd15e4>
   e14d4: e79f3003     	ldr	r3, [pc, r3]
   e14d8: e59f6208     	ldr	r6, [pc, #0x208]        @ 0xe16e8 <.text+0xd15e8>
   e14dc: e79f6006     	ldr	r6, [pc, r6]
   e14e0: e59f5204     	ldr	r5, [pc, #0x204]        @ 0xe16ec <.text+0xd15ec>
   e14e4: e79f5005     	ldr	r5, [pc, r5]
   e14e8: e59f4200     	ldr	r4, [pc, #0x200]        @ 0xe16f0 <.text+0xd15f0>
   e14ec: e79f4004     	ldr	r4, [pc, r4]
   e14f0: e59f11fc     	ldr	r1, [pc, #0x1fc]        @ 0xe16f4 <.text+0xd15f4>
   e14f4: e79f1001     	ldr	r1, [pc, r1]
   e14f8: e59f21f8     	ldr	r2, [pc, #0x1f8]        @ 0xe16f8 <.text+0xd15f8>
   e14fc: e79f2002     	ldr	r2, [pc, r2]
   e1500: e580209c     	str	r2, [r0, #0x9c]
   e1504: e28020a0     	add	r2, r0, #160
   e1508: e8820072     	stm	r2, {r1, r4, r5, r6}
   e150c: e58030b0     	str	r3, [r0, #0xb0]
   e1510: e580e0b4     	str	lr, [r0, #0xb4]
   e1514: e580c0b8     	str	r12, [r0, #0xb8]
   e1518: e59fc1dc     	ldr	r12, [pc, #0x1dc]       @ 0xe16fc <.text+0xd15fc>
   e151c: e79fc00c     	ldr	r12, [pc, r12]
   e1520: e59fe1d8     	ldr	lr, [pc, #0x1d8]        @ 0xe1700 <.text+0xd1600>
   e1524: e79fe00e     	ldr	lr, [pc, lr]
   e1528: e59f31d4     	ldr	r3, [pc, #0x1d4]        @ 0xe1704 <.text+0xd1604>
   e152c: e79f3003     	ldr	r3, [pc, r3]
   e1530: e59f61d0     	ldr	r6, [pc, #0x1d0]        @ 0xe1708 <.text+0xd1608>
   e1534: e79f6006     	ldr	r6, [pc, r6]
   e1538: e59f51cc     	ldr	r5, [pc, #0x1cc]        @ 0xe170c <.text+0xd160c>
   e153c: e79f5005     	ldr	r5, [pc, r5]
   e1540: e59f41c8     	ldr	r4, [pc, #0x1c8]        @ 0xe1710 <.text+0xd1610>
   e1544: e79f4004     	ldr	r4, [pc, r4]
   e1548: e59f11c4     	ldr	r1, [pc, #0x1c4]        @ 0xe1714 <.text+0xd1614>
   e154c: e79f1001     	ldr	r1, [pc, r1]
   e1550: e59f21c0     	ldr	r2, [pc, #0x1c0]        @ 0xe1718 <.text+0xd1618>
   e1554: e79f2002     	ldr	r2, [pc, r2]
   e1558: e580207c     	str	r2, [r0, #0x7c]
   e155c: e2802080     	add	r2, r0, #128
   e1560: e8820072     	stm	r2, {r1, r4, r5, r6}
   e1564: e5803090     	str	r3, [r0, #0x90]
   e1568: e580e094     	str	lr, [r0, #0x94]
   e156c: e580c098     	str	r12, [r0, #0x98]
   e1570: e59fc1a4     	ldr	r12, [pc, #0x1a4]       @ 0xe171c <.text+0xd161c>
   e1574: e79fc00c     	ldr	r12, [pc, r12]
   e1578: e59fe1a0     	ldr	lr, [pc, #0x1a0]        @ 0xe1720 <.text+0xd1620>
   e157c: e79fe00e     	ldr	lr, [pc, lr]
   e1580: e59f319c     	ldr	r3, [pc, #0x19c]        @ 0xe1724 <.text+0xd1624>
   e1584: e79f3003     	ldr	r3, [pc, r3]
   e1588: e59f6198     	ldr	r6, [pc, #0x198]        @ 0xe1728 <.text+0xd1628>
   e158c: e79f6006     	ldr	r6, [pc, r6]
   e1590: e59f5194     	ldr	r5, [pc, #0x194]        @ 0xe172c <.text+0xd162c>
   e1594: e79f5005     	ldr	r5, [pc, r5]
   e1598: e59f4190     	ldr	r4, [pc, #0x190]        @ 0xe1730 <.text+0xd1630>
   e159c: e79f4004     	ldr	r4, [pc, r4]
   e15a0: e59f118c     	ldr	r1, [pc, #0x18c]        @ 0xe1734 <.text+0xd1634>
   e15a4: e79f1001     	ldr	r1, [pc, r1]
   e15a8: e59f2188     	ldr	r2, [pc, #0x188]        @ 0xe1738 <.text+0xd1638>
   e15ac: e79f2002     	ldr	r2, [pc, r2]
   e15b0: e580205c     	str	r2, [r0, #0x5c]
   e15b4: e2802060     	add	r2, r0, #96
   e15b8: e8820072     	stm	r2, {r1, r4, r5, r6}
   e15bc: e5803070     	str	r3, [r0, #0x70]
   e15c0: e580e074     	str	lr, [r0, #0x74]
   e15c4: e580c078     	str	r12, [r0, #0x78]
   e15c8: e59fc16c     	ldr	r12, [pc, #0x16c]       @ 0xe173c <.text+0xd163c>
   e15cc: e79fc00c     	ldr	r12, [pc, r12]
   e15d0: e59fe168     	ldr	lr, [pc, #0x168]        @ 0xe1740 <.text+0xd1640>
   e15d4: e79fe00e     	ldr	lr, [pc, lr]
   e15d8: e59f3164     	ldr	r3, [pc, #0x164]        @ 0xe1744 <.text+0xd1644>
   e15dc: e79f3003     	ldr	r3, [pc, r3]
   e15e0: e59f6160     	ldr	r6, [pc, #0x160]        @ 0xe1748 <.text+0xd1648>
   e15e4: e79f6006     	ldr	r6, [pc, r6]
   e15e8: e59f515c     	ldr	r5, [pc, #0x15c]        @ 0xe174c <.text+0xd164c>
   e15ec: e79f5005     	ldr	r5, [pc, r5]
   e15f0: e59f4158     	ldr	r4, [pc, #0x158]        @ 0xe1750 <.text+0xd1650>
   e15f4: e79f4004     	ldr	r4, [pc, r4]
   e15f8: e59f1154     	ldr	r1, [pc, #0x154]        @ 0xe1754 <.text+0xd1654>
   e15fc: e79f1001     	ldr	r1, [pc, r1]
   e1600: e59f2150     	ldr	r2, [pc, #0x150]        @ 0xe1758 <.text+0xd1658>
   e1604: e79f2002     	ldr	r2, [pc, r2]
   e1608: e580203c     	str	r2, [r0, #0x3c]
   e160c: e2802040     	add	r2, r0, #64
   e1610: e8820072     	stm	r2, {r1, r4, r5, r6}
   e1614: e5803050     	str	r3, [r0, #0x50]
   e1618: e580e054     	str	lr, [r0, #0x54]
   e161c: e580c058     	str	r12, [r0, #0x58]
   e1620: e59fc134     	ldr	r12, [pc, #0x134]       @ 0xe175c <.text+0xd165c>
   e1624: e79fc00c     	ldr	r12, [pc, r12]
   e1628: e59fe130     	ldr	lr, [pc, #0x130]        @ 0xe1760 <.text+0xd1660>
   e162c: e79fe00e     	ldr	lr, [pc, lr]
   e1630: e59f312c     	ldr	r3, [pc, #0x12c]        @ 0xe1764 <.text+0xd1664>
   e1634: e79f3003     	ldr	r3, [pc, r3]
   e1638: e59f6128     	ldr	r6, [pc, #0x128]        @ 0xe1768 <.text+0xd1668>
   e163c: e79f6006     	ldr	r6, [pc, r6]
   e1640: e59f5124     	ldr	r5, [pc, #0x124]        @ 0xe176c <.text+0xd166c>
   e1644: e79f5005     	ldr	r5, [pc, r5]
   e1648: e59f4120     	ldr	r4, [pc, #0x120]        @ 0xe1770 <.text+0xd1670>
   e164c: e79f4004     	ldr	r4, [pc, r4]
   e1650: e59f111c     	ldr	r1, [pc, #0x11c]        @ 0xe1774 <.text+0xd1674>
   e1654: e79f1001     	ldr	r1, [pc, r1]
   e1658: e59f2118     	ldr	r2, [pc, #0x118]        @ 0xe1778 <.text+0xd1678>
   e165c: e79f2002     	ldr	r2, [pc, r2]
   e1660: e580201c     	str	r2, [r0, #0x1c]
   e1664: e2802020     	add	r2, r0, #32
   e1668: e8820072     	stm	r2, {r1, r4, r5, r6}
   e166c: e5803030     	str	r3, [r0, #0x30]
   e1670: e580e034     	str	lr, [r0, #0x34]
   e1674: e580c038     	str	r12, [r0, #0x38]
   e1678: e59f10fc     	ldr	r1, [pc, #0xfc]         @ 0xe177c <.text+0xd167c>
   e167c: e79f1001     	ldr	r1, [pc, r1]
   e1680: e59f20f8     	ldr	r2, [pc, #0xf8]         @ 0xe1780 <.text+0xd1680>
   e1684: e79f2002     	ldr	r2, [pc, r2]
   e1688: e59f30f4     	ldr	r3, [pc, #0xf4]         @ 0xe1784 <.text+0xd1684>
   e168c: e79f3003     	ldr	r3, [pc, r3]
   e1690: e59f60f0     	ldr	r6, [pc, #0xf0]         @ 0xe1788 <.text+0xd1688>
   e1694: e79f6006     	ldr	r6, [pc, r6]
   e1698: e59f50ec     	ldr	r5, [pc, #0xec]         @ 0xe178c <.text+0xd168c>
   e169c: e79f5005     	ldr	r5, [pc, r5]
   e16a0: e9800060     	stmib	r0, {r5, r6}
   e16a4: e580300c     	str	r3, [r0, #0xc]
   e16a8: e5802010     	str	r2, [r0, #0x10]
   e16ac: e5801014     	str	r1, [r0, #0x14]
   e16b0: e3a00000     	mov	r0, #0
   e16b4: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}

# constructor-literals 0xe16b8..0xe1790 (data)
000e16b8: .byte 0xb0,0xdd,0x4f,0x00,0x50,0xd7,0x4f,0x00,0xc0,0xe1,0x4f,0x00,0x94,0xe6,0x4f,0x00
000e16c8: .byte 0x64,0xd4,0x4f,0x00,0xd4,0xea,0x4f,0x00,0x54,0xda,0x4f,0x00,0x60,0xe6,0x4f,0x00
000e16d8: .byte 0x18,0xe4,0x4f,0x00,0x74,0xd7,0x4f,0x00,0xfc,0xd4,0x4f,0x00,0x50,0xd8,0x4f,0x00
000e16e8: .byte 0x74,0xd7,0x4f,0x00,0x70,0xd5,0x4f,0x00,0x30,0xd7,0x4f,0x00,0xc0,0xe5,0x4f,0x00
000e16f8: .byte 0xac,0xdb,0x4f,0x00,0xcc,0xdf,0x4f,0x00,0x04,0xd1,0x4f,0x00,0xd8,0xd9,0x4f,0x00
000e1708: .byte 0x70,0xd8,0x4f,0x00,0xe0,0xdd,0x4f,0x00,0xd0,0xde,0x4f,0x00,0xb0,0xe8,0x4f,0x00
000e1718: .byte 0x1c,0xe9,0x4f,0x00,0x30,0xd5,0x4f,0x00,0x60,0xea,0x4f,0x00,0xe4,0xd7,0x4f,0x00
000e1728: .byte 0x48,0xea,0x4f,0x00,0xac,0xe9,0x4f,0x00,0x70,0xd7,0x4f,0x00,0x78,0xe4,0x4f,0x00
000e1738: .byte 0xe8,0xd5,0x4f,0x00,0x30,0xd7,0x4f,0x00,0xfc,0xe1,0x4f,0x00,0x28,0xd6,0x4f,0x00
000e1748: .byte 0x9c,0xdd,0x4f,0x00,0x44,0xd1,0x4f,0x00,0x34,0xd2,0x4f,0x00,0xdc,0xd1,0x4f,0x00
000e1758: .byte 0x2c,0xdb,0x4f,0x00,0x3c,0xe6,0x4f,0x00,0x60,0xe8,0x4f,0x00,0x38,0xdf,0x4f,0x00
000e1768: .byte 0xb8,0xd8,0x4f,0x00,0x9c,0xe2,0x4f,0x00,0x1c,0xdf,0x4f,0x00,0x8c,0xd4,0x4f,0x00
000e1778: .byte 0x04,0xd9,0x4f,0x00,0x84,0xdb,0x4f,0x00,0x44,0xe0,0x4f,0x00,0x18,0xdc,0x4f,0x00
000e1788: .byte 0x9c,0xe4,0x4f,0x00,0x8c,0xd3,0x4f,0x00

# source-init 0xe5448..0xe54cc (code)
   e5448: e3a02000     	mov	r2, #0
   e544c: e3520000     	cmp	r2, #0
   e5450: 1a00001d     	bne	0xe54cc <.text+0xd53cc> @ imm = #0x74
   e5454: e59f3c10     	ldr	r3, [pc, #0xc10]        @ 0xe606c <.text+0xd5f6c>
   e5458: e08f3003     	add	r3, pc, r3
   e545c: ea000002     	b	0xe546c <.text+0xd536c> @ imm = #0x8
   e5460: e351002a     	cmp	r1, #42
   e5464: e1a02001     	mov	r2, r1
   e5468: 0a000017     	beq	0xe54cc <.text+0xd53cc> @ imm = #0x5c
   e546c: e59e1000     	ldr	r1, [lr]
   e5470: e2410001     	sub	r0, r1, #1
   e5474: e0000091     	mul	r0, r1, r0
   e5478: e3100001     	tst	r0, #1
   e547c: 0a000002     	beq	0xe548c <.text+0xd538c> @ imm = #0x8
   e5480: e59c0000     	ldr	r0, [r12]
   e5484: e3500009     	cmp	r0, #9
   e5488: ca00000b     	bgt	0xe54bc <.text+0xd53bc> @ imm = #0x2c
   e548c: e7d30002     	ldrb	r0, [r3, r2]
   e5490: e22000d8     	eor	r0, r0, #216
   e5494: e7c30002     	strb	r0, [r3, r2]
   e5498: e59e0000     	ldr	r0, [lr]
   e549c: e2401001     	sub	r1, r0, #1
   e54a0: e0000190     	mul	r0, r0, r1
   e54a4: e2821001     	add	r1, r2, #1
   e54a8: e3100001     	tst	r0, #1
   e54ac: 0affffeb     	beq	0xe5460 <.text+0xd5360> @ imm = #-0x54
   e54b0: e59c0000     	ldr	r0, [r12]
   e54b4: e3500009     	cmp	r0, #9
   e54b8: daffffe8     	ble	0xe5460 <.text+0xd5360> @ imm = #-0x60
   e54bc: e7d30002     	ldrb	r0, [r3, r2]
   e54c0: e22000d8     	eor	r0, r0, #216
   e54c4: e7c30002     	strb	r0, [r3, r2]
   e54c8: eaffffef     	b	0xe548c <.text+0xd538c> @ imm = #-0x44

# function-init 0xe54fc..0xe5580 (code)
   e54fc: e3a02000     	mov	r2, #0
   e5500: e3520000     	cmp	r2, #0
   e5504: 1a00001d     	bne	0xe5580 <.text+0xd5480> @ imm = #0x74
   e5508: e59f3b60     	ldr	r3, [pc, #0xb60]        @ 0xe6070 <.text+0xd5f70>
   e550c: e08f3003     	add	r3, pc, r3
   e5510: ea000002     	b	0xe5520 <.text+0xd5420> @ imm = #0x8
   e5514: e351000b     	cmp	r1, #11
   e5518: e1a02001     	mov	r2, r1
   e551c: 0a000017     	beq	0xe5580 <.text+0xd5480> @ imm = #0x5c
   e5520: e59e0000     	ldr	r0, [lr]
   e5524: e2401001     	sub	r1, r0, #1
   e5528: e0000190     	mul	r0, r0, r1
   e552c: e3100001     	tst	r0, #1
   e5530: 0a000002     	beq	0xe5540 <.text+0xd5440> @ imm = #0x8
   e5534: e59c0000     	ldr	r0, [r12]
   e5538: e3500009     	cmp	r0, #9
   e553c: ca00000b     	bgt	0xe5570 <.text+0xd5470> @ imm = #0x2c
   e5540: e7d30002     	ldrb	r0, [r3, r2]
   e5544: e22000d1     	eor	r0, r0, #209
   e5548: e7c30002     	strb	r0, [r3, r2]
   e554c: e59e0000     	ldr	r0, [lr]
   e5550: e2401001     	sub	r1, r0, #1
   e5554: e0000190     	mul	r0, r0, r1
   e5558: e2821001     	add	r1, r2, #1
   e555c: e3100001     	tst	r0, #1
   e5560: 0affffeb     	beq	0xe5514 <.text+0xd5414> @ imm = #-0x54
   e5564: e59c0000     	ldr	r0, [r12]
   e5568: e3500009     	cmp	r0, #9
   e556c: daffffe8     	ble	0xe5514 <.text+0xd5414> @ imm = #-0x60
   e5570: e7d30002     	ldrb	r0, [r3, r2]
   e5574: e22000d1     	eor	r0, r0, #209
   e5578: e7c30002     	strb	r0, [r3, r2]
   e557c: eaffffef     	b	0xe5540 <.text+0xd5440> @ imm = #-0x44

# analog-init 0xe55ac..0xe5630 (code)
   e55ac: e3a02000     	mov	r2, #0
   e55b0: e3520000     	cmp	r2, #0
   e55b4: 1a00001d     	bne	0xe5630 <.text+0xd5530> @ imm = #0x74
   e55b8: e59f3ab8     	ldr	r3, [pc, #0xab8]        @ 0xe6078 <.text+0xd5f78>
   e55bc: e08f3003     	add	r3, pc, r3
   e55c0: ea000002     	b	0xe55d0 <.text+0xd54d0> @ imm = #0x8
   e55c4: e3510029     	cmp	r1, #41
   e55c8: e1a02001     	mov	r2, r1
   e55cc: 0a000017     	beq	0xe5630 <.text+0xd5530> @ imm = #0x5c
   e55d0: e59e0000     	ldr	r0, [lr]
   e55d4: e2401001     	sub	r1, r0, #1
   e55d8: e0000190     	mul	r0, r0, r1
   e55dc: e3100001     	tst	r0, #1
   e55e0: 0a000002     	beq	0xe55f0 <.text+0xd54f0> @ imm = #0x8
   e55e4: e59c0000     	ldr	r0, [r12]
   e55e8: e3500009     	cmp	r0, #9
   e55ec: ca00000b     	bgt	0xe5620 <.text+0xd5520> @ imm = #0x2c
   e55f0: e7d30002     	ldrb	r0, [r3, r2]
   e55f4: e220001e     	eor	r0, r0, #30
   e55f8: e7c30002     	strb	r0, [r3, r2]
   e55fc: e59e0000     	ldr	r0, [lr]
   e5600: e2401001     	sub	r1, r0, #1
   e5604: e0000190     	mul	r0, r0, r1
   e5608: e2821001     	add	r1, r2, #1
   e560c: e3100001     	tst	r0, #1
   e5610: 0affffeb     	beq	0xe55c4 <.text+0xd54c4> @ imm = #-0x54
   e5614: e59c0000     	ldr	r0, [r12]
   e5618: e3500009     	cmp	r0, #9
   e561c: daffffe8     	ble	0xe55c4 <.text+0xd54c4> @ imm = #-0x60
   e5620: e7d30002     	ldrb	r0, [r3, r2]
   e5624: e220001e     	eor	r0, r0, #30
   e5628: e7c30002     	strb	r0, [r3, r2]
   e562c: eaffffef     	b	0xe55f0 <.text+0xd54f0> @ imm = #-0x44

# nonce-init 0xe579c..0xe57c8 (code)
   e579c: e3a02000     	mov	r2, #0
   e57a0: e3520000     	cmp	r2, #0
   e57a4: 1a000007     	bne	0xe57c8 <.text+0xd56c8> @ imm = #0x1c
   e57a8: e59f38d8     	ldr	r3, [pc, #0x8d8]        @ 0xe6088 <.text+0xd5f88>
   e57ac: e08f3003     	add	r3, pc, r3
   e57b0: e7d30002     	ldrb	r0, [r3, r2]
   e57b4: e2200012     	eor	r0, r0, #18
   e57b8: e7c30002     	strb	r0, [r3, r2]
   e57bc: e2822001     	add	r2, r2, #1
   e57c0: e3520031     	cmp	r2, #49
   e57c4: 1afffff9     	bne	0xe57b0 <.text+0xd56b0> @ imm = #-0x1c

# core-init 0xe5f48..0xe5f74 (code)
   e5f48: e3a02000     	mov	r2, #0
   e5f4c: e3520000     	cmp	r2, #0
   e5f50: 1a000007     	bne	0xe5f74 <.text+0xd5e74> @ imm = #0x1c
   e5f54: e59f3180     	ldr	r3, [pc, #0x180]        @ 0xe60dc <.text+0xd5fdc>
   e5f58: e08f3003     	add	r3, pc, r3
   e5f5c: e7d30002     	ldrb	r0, [r3, r2]
   e5f60: e2200067     	eor	r0, r0, #103
   e5f64: e7c30002     	strb	r0, [r3, r2]
   e5f68: e2822001     	add	r2, r2, #1
   e5f6c: e3520027     	cmp	r2, #39
   e5f70: 1afffff9     	bne	0xe5f5c <.text+0xd5e5c> @ imm = #-0x1c

# init-literals-1 0xe606c..0xe607c (data)
000e606c: .byte 0x87,0x5f,0x50,0x00,0xfd,0x5e,0x50,0x00,0x84,0x5e,0x50,0x00,0x7e,0x5e,0x50,0x00

# init-literal-2 0xe6088..0xe608c (data)
000e6088: .byte 0x30,0x5d,0x50,0x00

# init-literal-3 0xe60dc..0xe60e0 (data)
000e60dc: .byte 0x50,0x59,0x50,0x00

# startup-entry-flags 0x557bc..0x5581c (code)
   557bc: e1a00005     	mov	r0, r5
   557c0: eb014691     	bl	0xa720c <.text+0x9710c> @ imm = #0x51a44
   557c4: e1a07000     	mov	r7, r0
   557c8: e1a00005     	mov	r0, r5
   557cc: eb014688     	bl	0xa71f4 <.text+0x970f4> @ imm = #0x51a20
   557d0: e50b0020     	str	r0, [r11, #-0x20]
   557d4: e5d70045     	ldrb	r0, [r7, #0x45]
   557d8: e50b0024     	str	r0, [r11, #-0x24]
   557dc: e5d70046     	ldrb	r0, [r7, #0x46]
   557e0: e50b0028     	str	r0, [r11, #-0x28]
   557e4: e5d70047     	ldrb	r0, [r7, #0x47]
   557e8: e58d0028     	str	r0, [sp, #0x28]
   557ec: e5d70048     	ldrb	r0, [r7, #0x48]
   557f0: e58d0024     	str	r0, [sp, #0x24]
   557f4: e5d70049     	ldrb	r0, [r7, #0x49]
   557f8: e58d002c     	str	r0, [sp, #0x2c]
   557fc: e5d7004a     	ldrb	r0, [r7, #0x4a]
   55800: e58d0020     	str	r0, [sp, #0x20]
   55804: e5d7004b     	ldrb	r0, [r7, #0x4b]
   55808: e58d001c     	str	r0, [sp, #0x1c]
   5580c: e5d7004c     	ldrb	r0, [r7, #0x4c]
   55810: e5d76044     	ldrb	r6, [r7, #0x44]
   55814: e58d0018     	str	r0, [sp, #0x18]
   55818: e5d7404d     	ldrb	r4, [r7, #0x4d]

# startup-rmw 0x55860..0x558f8 (code)
   55860: e3500005     	cmp	r0, #5
   55864: 1a000030     	bne	0x5592c <.text+0x4582c> @ imm = #0xc0
   55868: e1a00005     	mov	r0, r5
   5586c: eb01465d     	bl	0xa71e8 <.text+0x970e8> @ imm = #0x51974
   55870: e5d91024     	ldrb	r1, [r9, #0x24]
   55874: e3510000     	cmp	r1, #0
   55878: 0a00002b     	beq	0x5592c <.text+0x4582c> @ imm = #0xac
   5587c: e5991020     	ldr	r1, [r9, #0x20]
   55880: e2411003     	sub	r1, r1, #3
   55884: e3510003     	cmp	r1, #3
   55888: 3a000027     	blo	0x5592c <.text+0x4582c> @ imm = #0x9c
   5588c: e5900018     	ldr	r0, [r0, #0x18]
   55890: e5991038     	ldr	r1, [r9, #0x38]
   55894: e1510000     	cmp	r1, r0
   55898: da00000f     	ble	0x558dc <.text+0x457dc> @ imm = #0x3c
   5589c: e59f0fd0     	ldr	r0, [pc, #0xfd0]        @ 0x56874 <.text+0x46774>
   558a0: e3a06001     	mov	r6, #1
   558a4: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x56878 <.text+0x46778>
   558a8: e59f2fcc     	ldr	r2, [pc, #0xfcc]        @ 0x5687c <.text+0x4677c>
   558ac: e08f0000     	add	r0, pc, r0
   558b0: e5993018     	ldr	r3, [r9, #0x18]
   558b4: e08f1001     	add	r1, pc, r1
   558b8: e59f7ffc     	ldr	r7, [pc, #0xffc]        @ 0x568bc <.text+0x467bc>
   558bc: e08f2002     	add	r2, pc, r2
   558c0: e2833001     	add	r3, r3, #1
   558c4: e08f7007     	add	r7, pc, r7
   558c8: e88d00c0     	stm	sp, {r6, r7}
   558cc: e58d3008     	str	r3, [sp, #0x8]
   558d0: e3003767     	movw	r3, #0x767
   558d4: eb0291fa     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xa47e8
   558d8: ea000006     	b	0x558f8 <.text+0x457f8> @ imm = #0x18
   558dc: e599001c     	ldr	r0, [r9, #0x1c]
   558e0: e3a01000     	mov	r1, #0
   558e4: e59021a4     	ldr	r2, [r0, #0x1a4]
   558e8: e2890fae     	add	r0, r9, #696
   558ec: e12fff32     	blx	r2
   558f0: e3500000     	cmp	r0, #0
   558f4: 0a00000c     	beq	0x5592c <.text+0x4582c> @ imm = #0x30

# startup-analog 0x5630c..0x56378 (code)
   5630c: e3a0000a     	mov	r0, #10
   56310: eb02e309     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0xb8c24
   56314: e59d0020     	ldr	r0, [sp, #0x20]
   56318: e3100001     	tst	r0, #1
   5631c: 0a000015     	beq	0x56378 <.text+0x46278> @ imm = #0x54
   56320: e59d0014     	ldr	r0, [sp, #0x14]
   56324: e595100c     	ldr	r1, [r5, #0xc]
   56328: e5902190     	ldr	r2, [r0, #0x190]
   5632c: e1a0000a     	mov	r0, r10
   56330: e12fff32     	blx	r2
   56334: e3500000     	cmp	r0, #0
   56338: 0a00000e     	beq	0x56378 <.text+0x46278> @ imm = #0x38
   5633c: e59f0814     	ldr	r0, [pc, #0x814]        @ 0x56b58 <.text+0x46a58>
   56340: e3a06001     	mov	r6, #1
   56344: e59f1810     	ldr	r1, [pc, #0x810]        @ 0x56b5c <.text+0x46a5c>
   56348: e59f2810     	ldr	r2, [pc, #0x810]        @ 0x56b60 <.text+0x46a60>
   5634c: e08f0000     	add	r0, pc, r0
   56350: e5993018     	ldr	r3, [r9, #0x18]
   56354: e08f1001     	add	r1, pc, r1
   56358: e59f7804     	ldr	r7, [pc, #0x804]        @ 0x56b64 <.text+0x46a64>
   5635c: e08f2002     	add	r2, pc, r2
   56360: e2833001     	add	r3, r3, #1
   56364: e08f7007     	add	r7, pc, r7
   56368: e88d00c0     	stm	sp, {r6, r7}
   5636c: e58d3008     	str	r3, [sp, #0x8]
   56370: e30032af     	movw	r3, #0x2af
   56374: ea000019     	b	0x563e0 <.text+0x462e0> @ imm = #0x64

# startup-nonce 0x56554..0x565d4 (code)
   56554: e59d0018     	ldr	r0, [sp, #0x18]
   56558: e2000001     	and	r0, r0, #1
   5655c: e5981000     	ldr	r1, [r8]
   56560: e2412001     	sub	r2, r1, #1
   56564: e0010291     	mul	r1, r1, r2
   56568: e3110001     	tst	r1, #1
   5656c: 0a000002     	beq	0x5657c <.text+0x4647c> @ imm = #0x8
   56570: e5941000     	ldr	r1, [r4]
   56574: e3510009     	cmp	r1, #9
   56578: cafffff7     	bgt	0x5655c <.text+0x4645c> @ imm = #-0x24
   5657c: e3500000     	cmp	r0, #0
   56580: 0a000013     	beq	0x565d4 <.text+0x464d4> @ imm = #0x4c
   56584: e59d0014     	ldr	r0, [sp, #0x14]
   56588: e3a01000     	mov	r1, #0
   5658c: e5902178     	ldr	r2, [r0, #0x178]
   56590: e1a0000a     	mov	r0, r10
   56594: e12fff32     	blx	r2
   56598: e3500000     	cmp	r0, #0
   5659c: 0a00000c     	beq	0x565d4 <.text+0x464d4> @ imm = #0x30
   565a0: e5980000     	ldr	r0, [r8]
   565a4: e59f5608     	ldr	r5, [pc, #0x608]        @ 0x56bb4 <.text+0x46ab4>
   565a8: e2401001     	sub	r1, r0, #1
   565ac: e08f5005     	add	r5, pc, r5
   565b0: e0000190     	mul	r0, r0, r1
   565b4: e3100001     	tst	r0, #1
   565b8: 0a000041     	beq	0x566c4 <.text+0x465c4> @ imm = #0x104
   565bc: e59f05f4     	ldr	r0, [pc, #0x5f4]        @ 0x56bb8 <.text+0x46ab8>
   565c0: e79f0000     	ldr	r0, [pc, r0]
   565c4: e5900000     	ldr	r0, [r0]
   565c8: e3500009     	cmp	r0, #9
   565cc: ca000059     	bgt	0x56738 <.text+0x46638> @ imm = #0x164
   565d0: ea00003b     	b	0x566c4 <.text+0x465c4> @ imm = #0xec

# startup-pattern-gate 0x565d4..0x56604 (code)
   565d4: e59d000c     	ldr	r0, [sp, #0xc]
   565d8: e3100001     	tst	r0, #1
   565dc: 0a00008f     	beq	0x56820 <.text+0x46720> @ imm = #0x23c
   565e0: e5980000     	ldr	r0, [r8]
   565e4: e2401001     	sub	r1, r0, #1
   565e8: e0000190     	mul	r0, r0, r1
   565ec: e3100001     	tst	r0, #1
   565f0: 0a000065     	beq	0x5678c <.text+0x4668c> @ imm = #0x194
   565f4: e5940000     	ldr	r0, [r4]
   565f8: e3500009     	cmp	r0, #9
   565fc: ca00006e     	bgt	0x567bc <.text+0x466bc> @ imm = #0x1b8
   56600: ea000061     	b	0x5678c <.text+0x4668c> @ imm = #0x184

# startup-pattern 0x5678c..0x56820 (code)
   5678c: e59d0014     	ldr	r0, [sp, #0x14]
   56790: e590117c     	ldr	r1, [r0, #0x17c]
   56794: e1a0000a     	mov	r0, r10
   56798: e12fff31     	blx	r1
   5679c: e5981000     	ldr	r1, [r8]
   567a0: e2412001     	sub	r2, r1, #1
   567a4: e0010291     	mul	r1, r1, r2
   567a8: e3110001     	tst	r1, #1
   567ac: 0a000007     	beq	0x567d0 <.text+0x466d0> @ imm = #0x1c
   567b0: e5941000     	ldr	r1, [r4]
   567b4: e3510009     	cmp	r1, #9
   567b8: da000004     	ble	0x567d0 <.text+0x466d0> @ imm = #0x10
   567bc: e59d0014     	ldr	r0, [sp, #0x14]
   567c0: e590117c     	ldr	r1, [r0, #0x17c]
   567c4: e1a0000a     	mov	r0, r10
   567c8: e12fff31     	blx	r1
   567cc: eaffffee     	b	0x5678c <.text+0x4668c> @ imm = #-0x48
   567d0: e3500000     	cmp	r0, #0
   567d4: 0a000011     	beq	0x56820 <.text+0x46720> @ imm = #0x44
   567d8: e59f0400     	ldr	r0, [pc, #0x400]        @ 0x56be0 <.text+0x46ae0>
   567dc: e3a06001     	mov	r6, #1
   567e0: e59f13fc     	ldr	r1, [pc, #0x3fc]        @ 0x56be4 <.text+0x46ae4>
   567e4: e59f23fc     	ldr	r2, [pc, #0x3fc]        @ 0x56be8 <.text+0x46ae8>
   567e8: e08f0000     	add	r0, pc, r0
   567ec: e5993018     	ldr	r3, [r9, #0x18]
   567f0: e08f1001     	add	r1, pc, r1
   567f4: e59f73f0     	ldr	r7, [pc, #0x3f0]        @ 0x56bec <.text+0x46aec>
   567f8: e08f2002     	add	r2, pc, r2
   567fc: e2833001     	add	r3, r3, #1
   56800: e08f7007     	add	r7, pc, r7
   56804: e88d00c0     	stm	sp, {r6, r7}
   56808: e58d3008     	str	r3, [sp, #0x8]
   5680c: e30032db     	movw	r3, #0x2db
   56810: eb028e2b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xa38ac
   56814: e59f13d4     	ldr	r1, [pc, #0x3d4]        @ 0x56bf0 <.text+0x46af0>
   56818: e08f1001     	add	r1, pc, r1
   5681c: eafffdb4     	b	0x55ef4 <.text+0x45df4> @ imm = #-0x930

# driver 0x5eb3e0..0x5eb3e7 (data)
005eb3e0: .byte 0x7a,0x6c,0x77,0x68,0x7b,0x6c,0x1e

# source 0x5eb3e7..0x5eb411 (data)
005eb3e7: .byte 0xf7,0xac,0xb5,0xa8,0xf7,0xba,0xad,0xb1,0xb4,0xbc,0xf7,0xb4,0xb1,0xba,0xba,0xb1
005eb3f7: .byte 0xac,0xb5,0xb9,0xb1,0xb6,0xf7,0xab,0xaa,0xbb,0xf7,0xbb,0xb0,0xb1,0xa8,0xf7,0xbb
005eb407: .byte 0xb0,0xb1,0xa8,0xe9,0xeb,0xee,0xe0,0xf6,0xbb,0xd8

# function 0x5eb411..0x5eb41c (data)
005eb411: .byte 0x8a,0xa3,0xb4,0xb5,0xb0,0xb2,0xa5,0xb4,0xb5,0x8c,0xd1

# analog-format 0x5eb442..0x5eb46b (data)
005eb442: .byte 0x7d,0x76,0x7f,0x77,0x70,0x3d,0x3b,0x7a,0x3e,0x33,0x3e,0x78,0x7f,0x77,0x72,0x7b
005eb452: .byte 0x7a,0x3e,0x6a,0x71,0x3e,0x6d,0x7b,0x6a,0x3e,0x5f,0x50,0x5f,0x52,0x51,0x59,0x41
005eb462: .byte 0x53,0x4b,0x46,0x41,0x5d,0x4a,0x4c,0x52,0x1e

# nonce-format 0x5eb4e4..0x5eb515 (data)
005eb4e4: .byte 0x71,0x7a,0x73,0x7b,0x7c,0x31,0x37,0x76,0x32,0x3f,0x32,0x74,0x73,0x7b,0x7e,0x77
005eb4f4: .byte 0x76,0x32,0x66,0x7d,0x32,0x61,0x77,0x66,0x32,0x5c,0x5d,0x5c,0x51,0x57,0x4d,0x50
005eb504: .byte 0x5b,0x5c,0x4d,0x5d,0x44,0x57,0x40,0x54,0x5e,0x5d,0x45,0x4d,0x51,0x46,0x40,0x5e
005eb514: .byte 0x12

# core-format 0x5eb8b0..0x5eb8d7 (data)
005eb8b0: .byte 0x04,0x0f,0x06,0x0e,0x09,0x44,0x42,0x03,0x47,0x4a,0x47,0x01,0x06,0x0e,0x0b,0x02
005eb8c0: .byte 0x03,0x47,0x13,0x08,0x47,0x14,0x02,0x09,0x03,0x47,0x04,0x08,0x15,0x02,0x47,0x04
005eb8d0: .byte 0x08,0x0a,0x0a,0x06,0x09,0x03,0x67

# got-slot-0x94 0x5de630..0x5de634 (data)
005de630: .byte 0x04,0x3c,0x0e,0x00

# got-slot-0x80 0x5dfe04..0x5dfe08 (data)
005dfe04: .byte 0xc0,0x35,0x0e,0x00

# got-slot-0x6c 0x5dffdc..0x5dffe0 (data)
005dffdc: .byte 0x90,0x32,0x0e,0x00

# got-slot-0x68 0x5dff48..0x5dff4c (data)
005dff48: .byte 0x98,0x30,0x0e,0x00

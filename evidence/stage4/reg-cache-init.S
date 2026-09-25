
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  106a58: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  106a5c: e28db01c     	add	r11, sp, #28
  106a60: e24dd00c     	sub	sp, sp, #12
  106a64: e3500007     	cmp	r0, #7
  106a68: 8a000011     	bhi	0x106ab4 <.text+0xf69b4> @ imm = #0x44
  106a6c: e59fa354     	ldr	r10, [pc, #0x354]       @ 0x106dc8 <.text+0xf6cc8>
  106a70: e1a08001     	mov	r8, r1
  106a74: e1a04002     	mov	r4, r2
  106a78: e79fa00a     	ldr	r10, [pc, r10]
  106a7c: e28f1004     	add	r1, pc, #4
  106a80: e7910100     	ldr	r0, [r1, r0, lsl #2]
  106a84: e081f000     	add	pc, r1, r0
  106a88: 000000ac     	andeq	r0, r0, r12, lsr #1
  106a8c: 00000020     	andeq	r0, r0, r0, lsr #32
  106a90: 00000068     	andeq	r0, r0, r8, rrx
  106a94: 00000074     	andeq	r0, r0, r4, ror r0
  106a98: 00000080     	andeq	r0, r0, r0, lsl #1
  106a9c: 0000008c     	andeq	r0, r0, r12, lsl #1
  106aa0: 00000098     	muleq	r0, r8, r0
  106aa4: 000000a4     	andeq	r0, r0, r4, lsr #1
  106aa8: e59fa358     	ldr	r10, [pc, #0x358]       @ 0x106e08 <.text+0xf6d08>
  106aac: e79fa00a     	ldr	r10, [pc, r10]
  106ab0: ea00001f     	b	0x106b34 <.text+0xf6a34> @ imm = #0x7c
  106ab4: e59f4328     	ldr	r4, [pc, #0x328]        @ 0x106de4 <.text+0xf6ce4>
  106ab8: e79f4004     	ldr	r4, [pc, r4]
  106abc: e5940000     	ldr	r0, [r4]
  106ac0: e59f5320     	ldr	r5, [pc, #0x320]        @ 0x106de8 <.text+0xf6ce8>
  106ac4: e2401001     	sub	r1, r0, #1
  106ac8: e0000190     	mul	r0, r0, r1
  106acc: e79f5005     	ldr	r5, [pc, r5]
  106ad0: e59f6314     	ldr	r6, [pc, #0x314]        @ 0x106dec <.text+0xf6cec>
  106ad4: e08f6006     	add	r6, pc, r6
  106ad8: e3100001     	tst	r0, #1
  106adc: 0a000069     	beq	0x106c88 <.text+0xf6b88> @ imm = #0x1a4
  106ae0: e5950000     	ldr	r0, [r5]
  106ae4: e3500009     	cmp	r0, #9
  106ae8: ca000079     	bgt	0x106cd4 <.text+0xf6bd4> @ imm = #0x1e4
  106aec: ea000065     	b	0x106c88 <.text+0xf6b88> @ imm = #0x194
  106af0: e59fa2e0     	ldr	r10, [pc, #0x2e0]       @ 0x106dd8 <.text+0xf6cd8>
  106af4: e79fa00a     	ldr	r10, [pc, r10]
  106af8: ea00000d     	b	0x106b34 <.text+0xf6a34> @ imm = #0x34
  106afc: e59fa2c8     	ldr	r10, [pc, #0x2c8]       @ 0x106dcc <.text+0xf6ccc>
  106b00: e79fa00a     	ldr	r10, [pc, r10]
  106b04: ea00000a     	b	0x106b34 <.text+0xf6a34> @ imm = #0x28
  106b08: e59fa2c0     	ldr	r10, [pc, #0x2c0]       @ 0x106dd0 <.text+0xf6cd0>
  106b0c: e79fa00a     	ldr	r10, [pc, r10]
  106b10: ea000007     	b	0x106b34 <.text+0xf6a34> @ imm = #0x1c
  106b14: e59fa2b8     	ldr	r10, [pc, #0x2b8]       @ 0x106dd4 <.text+0xf6cd4>
  106b18: e79fa00a     	ldr	r10, [pc, r10]
  106b1c: ea000004     	b	0x106b34 <.text+0xf6a34> @ imm = #0x10
  106b20: e59fa2b4     	ldr	r10, [pc, #0x2b4]       @ 0x106ddc <.text+0xf6cdc>
  106b24: e79fa00a     	ldr	r10, [pc, r10]
  106b28: ea000001     	b	0x106b34 <.text+0xf6a34> @ imm = #0x4
  106b2c: e59fa2ac     	ldr	r10, [pc, #0x2ac]       @ 0x106de0 <.text+0xf6ce0>
  106b30: e79fa00a     	ldr	r10, [pc, r10]
  106b34: e3a00f82     	mov	r0, #520
  106b38: e1a01008     	mov	r1, r8
  106b3c: eb12341c     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x48d070
  106b40: e1a09000     	mov	r9, r0
  106b44: e59f02c0     	ldr	r0, [pc, #0x2c0]        @ 0x106e0c <.text+0xf6d0c>
  106b48: e3590000     	cmp	r9, #0
  106b4c: e08f0000     	add	r0, pc, r0
  106b50: e5809000     	str	r9, [r0]
  106b54: 0a00002f     	beq	0x106c18 <.text+0xf6b18> @ imm = #0xbc
  106b58: e59f02d8     	ldr	r0, [pc, #0x2d8]        @ 0x106e38 <.text+0xf6d38>
  106b5c: e3580001     	cmp	r8, #1
  106b60: e08f0000     	add	r0, pc, r0
  106b64: e5808000     	str	r8, [r0]
  106b68: ba000024     	blt	0x106c00 <.text+0xf6b00> @ imm = #0x90
  106b6c: e3a07000     	mov	r7, #0
  106b70: ea000002     	b	0x106b80 <.text+0xf6a80> @ imm = #0x8
  106b74: e2877001     	add	r7, r7, #1
  106b78: e1570008     	cmp	r7, r8
  106b7c: 0a00001f     	beq	0x106c00 <.text+0xf6b00> @ imm = #0x7c
  106b80: e3a00c02     	mov	r0, #512
  106b84: e1a01004     	mov	r1, r4
  106b88: eb123409     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x48d024
  106b8c: e1a05000     	mov	r5, r0
  106b90: e0870307     	add	r0, r7, r7, lsl #6
  106b94: e3550000     	cmp	r5, #0
  106b98: e0890180     	add	r0, r9, r0, lsl #3
  106b9c: e1a06000     	mov	r6, r0
  106ba0: e5a65200     	str	r5, [r6, #0x200]!
  106ba4: 0a000028     	beq	0x106c4c <.text+0xf6b4c> @ imm = #0xa0
  106ba8: e1a0100a     	mov	r1, r10
  106bac: e3a02c02     	mov	r2, #512
  106bb0: e5804204     	str	r4, [r0, #0x204]
  106bb4: eb1270cb     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x49c32c
  106bb8: e3540001     	cmp	r4, #1
  106bbc: baffffec     	blt	0x106b74 <.text+0xf6a74> @ imm = #-0x50
  106bc0: e1a00005     	mov	r0, r5
  106bc4: e1a0100a     	mov	r1, r10
  106bc8: e3a02c02     	mov	r2, #512
  106bcc: eb1270c5     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x49c314
  106bd0: e3540001     	cmp	r4, #1
  106bd4: 0affffe6     	beq	0x106b74 <.text+0xf6a74> @ imm = #-0x68
  106bd8: e3a05001     	mov	r5, #1
  106bdc: e5960000     	ldr	r0, [r6]
  106be0: e1a0100a     	mov	r1, r10
  106be4: e3a02c02     	mov	r2, #512
  106be8: e0800485     	add	r0, r0, r5, lsl #9
  106bec: eb1270bd     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x49c2f4
  106bf0: e2855001     	add	r5, r5, #1
  106bf4: e1540005     	cmp	r4, r5
  106bf8: 1afffff7     	bne	0x106bdc <.text+0xf6adc> @ imm = #-0x24
  106bfc: eaffffdc     	b	0x106b74 <.text+0xf6a74> @ imm = #-0x90
  106c00: e59f0244     	ldr	r0, [pc, #0x244]        @ 0x106e4c <.text+0xf6d4c>
  106c04: e3a01001     	mov	r1, #1
  106c08: e08f0000     	add	r0, pc, r0
  106c0c: e5c01000     	strb	r1, [r0]
  106c10: e3a00000     	mov	r0, #0
  106c14: ea00005d     	b	0x106d90 <.text+0xf6c90> @ imm = #0x174
  106c18: e59f41f0     	ldr	r4, [pc, #0x1f0]        @ 0x106e10 <.text+0xf6d10>
  106c1c: e79f4004     	ldr	r4, [pc, r4]
  106c20: e5940000     	ldr	r0, [r4]
  106c24: e59f51e8     	ldr	r5, [pc, #0x1e8]        @ 0x106e14 <.text+0xf6d14>
  106c28: e2401001     	sub	r1, r0, #1
  106c2c: e0000190     	mul	r0, r0, r1
  106c30: e79f5005     	ldr	r5, [pc, r5]
  106c34: e3100001     	tst	r0, #1
  106c38: 0a000030     	beq	0x106d00 <.text+0xf6c00> @ imm = #0xc0
  106c3c: e5950000     	ldr	r0, [r5]
  106c40: e3500009     	cmp	r0, #9
  106c44: ca000043     	bgt	0x106d58 <.text+0xf6c58> @ imm = #0x10c
  106c48: ea00002c     	b	0x106d00 <.text+0xf6c00> @ imm = #0xb0
  106c4c: e59f01e8     	ldr	r0, [pc, #0x1e8]        @ 0x106e3c <.text+0xf6d3c>
  106c50: e3a07001     	mov	r7, #1
  106c54: e59f11e4     	ldr	r1, [pc, #0x1e4]        @ 0x106e40 <.text+0xf6d40>
  106c58: e59f21e4     	ldr	r2, [pc, #0x1e4]        @ 0x106e44 <.text+0xf6d44>
  106c5c: e08f0000     	add	r0, pc, r0
  106c60: e59f31e0     	ldr	r3, [pc, #0x1e0]        @ 0x106e48 <.text+0xf6d48>
  106c64: e08f1001     	add	r1, pc, r1
  106c68: e08f2002     	add	r2, pc, r2
  106c6c: e58d7000     	str	r7, [sp]
  106c70: e08f3003     	add	r3, pc, r3
  106c74: e58d3004     	str	r3, [sp, #0x4]
  106c78: e30032c2     	movw	r3, #0x2c2
  106c7c: ebffcd10     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xcbc0
  106c80: e3e00000     	mvn	r0, #0
  106c84: ea000041     	b	0x106d90 <.text+0xf6c90> @ imm = #0x104
  106c88: e59f0160     	ldr	r0, [pc, #0x160]        @ 0x106df0 <.text+0xf6cf0>
  106c8c: e3a03001     	mov	r3, #1
  106c90: e59f115c     	ldr	r1, [pc, #0x15c]        @ 0x106df4 <.text+0xf6cf4>
  106c94: e59f215c     	ldr	r2, [pc, #0x15c]        @ 0x106df8 <.text+0xf6cf8>
  106c98: e08f0000     	add	r0, pc, r0
  106c9c: e08f1001     	add	r1, pc, r1
  106ca0: e88d0048     	stm	sp, {r3, r6}
  106ca4: e08f2002     	add	r2, pc, r2
  106ca8: e3a03e2b     	mov	r3, #688
  106cac: ebffcd04     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xcbf0
  106cb0: e5940000     	ldr	r0, [r4]
  106cb4: e2401001     	sub	r1, r0, #1
  106cb8: e0010190     	mul	r1, r0, r1
  106cbc: e3e00000     	mvn	r0, #0
  106cc0: e3110001     	tst	r1, #1
  106cc4: 0a000031     	beq	0x106d90 <.text+0xf6c90> @ imm = #0xc4
  106cc8: e5951000     	ldr	r1, [r5]
  106ccc: e351000a     	cmp	r1, #10
  106cd0: ba00002e     	blt	0x106d90 <.text+0xf6c90> @ imm = #0xb8
  106cd4: e59f0120     	ldr	r0, [pc, #0x120]        @ 0x106dfc <.text+0xf6cfc>
  106cd8: e3a03001     	mov	r3, #1
  106cdc: e59f111c     	ldr	r1, [pc, #0x11c]        @ 0x106e00 <.text+0xf6d00>
  106ce0: e59f211c     	ldr	r2, [pc, #0x11c]        @ 0x106e04 <.text+0xf6d04>
  106ce4: e08f0000     	add	r0, pc, r0
  106ce8: e08f1001     	add	r1, pc, r1
  106cec: e88d0048     	stm	sp, {r3, r6}
  106cf0: e08f2002     	add	r2, pc, r2
  106cf4: e3a03e2b     	mov	r3, #688
  106cf8: ebffccf1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xcc3c
  106cfc: eaffffe1     	b	0x106c88 <.text+0xf6b88> @ imm = #-0x7c
  106d00: e59f0110     	ldr	r0, [pc, #0x110]        @ 0x106e18 <.text+0xf6d18>
  106d04: e3a07001     	mov	r7, #1
  106d08: e59f110c     	ldr	r1, [pc, #0x10c]        @ 0x106e1c <.text+0xf6d1c>
  106d0c: e59f210c     	ldr	r2, [pc, #0x10c]        @ 0x106e20 <.text+0xf6d20>
  106d10: e08f0000     	add	r0, pc, r0
  106d14: e59f3108     	ldr	r3, [pc, #0x108]        @ 0x106e24 <.text+0xf6d24>
  106d18: e08f1001     	add	r1, pc, r1
  106d1c: e08f2002     	add	r2, pc, r2
  106d20: e58d7000     	str	r7, [sp]
  106d24: e08f3003     	add	r3, pc, r3
  106d28: e58d3004     	str	r3, [sp, #0x4]
  106d2c: e30032b6     	movw	r3, #0x2b6
  106d30: ebffcce3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xcc74
  106d34: e5940000     	ldr	r0, [r4]
  106d38: e2401001     	sub	r1, r0, #1
  106d3c: e0010190     	mul	r1, r0, r1
  106d40: e3e00000     	mvn	r0, #0
  106d44: e3110001     	tst	r1, #1
  106d48: 0a000010     	beq	0x106d90 <.text+0xf6c90> @ imm = #0x40
  106d4c: e5951000     	ldr	r1, [r5]
  106d50: e351000a     	cmp	r1, #10
  106d54: ba00000d     	blt	0x106d90 <.text+0xf6c90> @ imm = #0x34
  106d58: e59f00c8     	ldr	r0, [pc, #0xc8]         @ 0x106e28 <.text+0xf6d28>
  106d5c: e3a07001     	mov	r7, #1
  106d60: e59f10c4     	ldr	r1, [pc, #0xc4]         @ 0x106e2c <.text+0xf6d2c>
  106d64: e59f20c4     	ldr	r2, [pc, #0xc4]         @ 0x106e30 <.text+0xf6d30>
  106d68: e08f0000     	add	r0, pc, r0
  106d6c: e59f30c0     	ldr	r3, [pc, #0xc0]         @ 0x106e34 <.text+0xf6d34>
  106d70: e08f1001     	add	r1, pc, r1
  106d74: e08f2002     	add	r2, pc, r2
  106d78: e58d7000     	str	r7, [sp]
  106d7c: e08f3003     	add	r3, pc, r3
  106d80: e58d3004     	str	r3, [sp, #0x4]
  106d84: e30032b6     	movw	r3, #0x2b6
  106d88: ebffcccd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xcccc
  106d8c: eaffffdb     	b	0x106d00 <.text+0xf6c00> @ imm = #-0x94
  106d90: e59f10b8     	ldr	r1, [pc, #0xb8]         @ 0x106e50 <.text+0xf6d50>
  106d94: e79f1001     	ldr	r1, [pc, r1]
  106d98: e59f20b4     	ldr	r2, [pc, #0xb4]         @ 0x106e54 <.text+0xf6d54>
  106d9c: e79f2002     	ldr	r2, [pc, r2]
  106da0: e5913000     	ldr	r3, [r1]
  106da4: e2437001     	sub	r7, r3, #1
  106da8: e0030793     	mul	r3, r3, r7
  106dac: e3130001     	tst	r3, #1
  106db0: 0a000002     	beq	0x106dc0 <.text+0xf6cc0> @ imm = #0x8
  106db4: e5923000     	ldr	r3, [r2]
  106db8: e3530009     	cmp	r3, #9
  106dbc: cafffff7     	bgt	0x106da0 <.text+0xf6ca0> @ imm = #-0x24
  106dc0: e24bd01c     	sub	sp, r11, #28
  106dc4: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  106dc8: 004d8f88     	subeq	r8, sp, r8, lsl #31
  106dcc: 004d8018     	subeq	r8, sp, r8, lsl r0
  106dd0: 004d8a8c     	subeq	r8, sp, r12, lsl #21
  106dd4: 004d7bc8     	subeq	r7, sp, r8, asr #23
  106dd8: 004d836c     	subeq	r8, sp, r12, ror #6
  106ddc: 004d7ca4     	subeq	r7, sp, r4, lsr #25
  106de0: 004d8650     	subeq	r8, sp, r0, asr r6
  106de4: 004d836c     	subeq	r8, sp, r12, ror #6
  106de8: 004d88cc     	subeq	r8, sp, r12, asr #17
  106dec: 004e69c7     	subeq	r6, lr, r7, asr #19
  106df0: 004e67cb     	subeq	r6, lr, r11, asr #15
  106df4: 004e67ce     	subeq	r6, lr, lr, asr #15
  106df8: 004e67ec     	subeq	r6, lr, r12, ror #15
  106dfc: 004e677f     	subeq	r6, lr, pc, ror r7
  106e00: 004e6782     	subeq	r6, lr, r2, lsl #15
  106e04: 004e67a0     	subeq	r6, lr, r0, lsr #15
  106e08: 004d9414     	subeq	r9, sp, r4, lsl r4
  106e0c: 0054e214     	subseq	lr, r4, r4, lsl r2
  106e10: 004d8208     	subeq	r8, sp, r8, lsl #4
  106e14: 004d8768     	subeq	r8, sp, r8, ror #14
  106e18: 004e6753     	subeq	r6, lr, r3, asr r7
  106e1c: 004e6752     	subeq	r6, lr, r2, asr r7
  106e20: 004e6774     	subeq	r6, lr, r4, ror r7
  106e24: 004e6792     	umaaleq	r6, lr, r2, r7
  106e28: 004e66fb     	strdeq	r6, r7, [lr], #-107
  106e2c: 004e66fa     	strdeq	r6, r7, [lr], #-106
  106e30: 004e671c     	subeq	r6, lr, r12, lsl r7
  106e34: 004e673a     	subeq	r6, lr, r10, lsr r7
  106e38: 0054e204     	subseq	lr, r4, r4, lsl #4
  106e3c: 004e6807     	subeq	r6, lr, r7, lsl #16
  106e40: 004e6806     	subeq	r6, lr, r6, lsl #16
  106e44: 004e6828     	subeq	r6, lr, r8, lsr #16
  106e48: 004e6846     	subeq	r6, lr, r6, asr #16
  106e4c: 0054e160     	subseq	lr, r4, r0, ror #2
  106e50: 004d8090     	umaaleq	r8, sp, r0, r0
  106e54: 004d85fc     	strdeq	r8, r9, [sp], #-92

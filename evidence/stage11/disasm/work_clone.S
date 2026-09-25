
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   2ce84: e92d4bf0     	push	{r4, r5, r6, r7, r8, r9, r11, lr}
   2ce88: e28db018     	add	r11, sp, #24
   2ce8c: e24dd010     	sub	sp, sp, #16
   2ce90: e1a08001     	mov	r8, r1
   2ce94: e1a09000     	mov	r9, r0
   2ce98: e3a00001     	mov	r0, #1
   2ce9c: e3a01f9e     	mov	r1, #632
   2cea0: eb159b43     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x566d0c
   2cea4: e59f725c     	ldr	r7, [pc, #0x25c]        @ 0x2d108 <.text+0x1d008>
   2cea8: e1a05000     	mov	r5, r0
   2ceac: e79f7007     	ldr	r7, [pc, r7]
   2ceb0: e1a00007     	mov	r0, r7
   2ceb4: eb15e493     	bl	0x5a6108 <.text+0x596008> @ imm = #0x57924c
   2ceb8: e59f024c     	ldr	r0, [pc, #0x24c]        @ 0x2d10c <.text+0x1d00c>
   2cebc: e59f424c     	ldr	r4, [pc, #0x24c]        @ 0x2d110 <.text+0x1d010>
   2cec0: e08f0000     	add	r0, pc, r0
   2cec4: e79f4004     	ldr	r4, [pc, r4]
   2cec8: e2841001     	add	r1, r4, #1
   2cecc: e5801000     	str	r1, [r0]
   2ced0: e1a00007     	mov	r0, r7
   2ced4: eb15e5fa     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5797e8
   2ced8: e1a00005     	mov	r0, r5
   2cedc: e3a01000     	mov	r1, #0
   2cee0: e3a02f9e     	mov	r2, #632
   2cee4: eb15d968     	bl	0x5a348c <.text+0x59338c> @ imm = #0x5765a0
   2cee8: e59f3224     	ldr	r3, [pc, #0x224]        @ 0x2d114 <.text+0x1d014>
   2ceec: e3001874     	movw	r1, #0x874
   2cef0: e59f0220     	ldr	r0, [pc, #0x220]        @ 0x2d118 <.text+0x1d018>
   2cef4: e3a02f9e     	mov	r2, #632
   2cef8: e08f3003     	add	r3, pc, r3
   2cefc: e08f0000     	add	r0, pc, r0
   2cf00: e88d0003     	stm	sp, {r0, r1}
   2cf04: e1a00005     	mov	r0, r5
   2cf08: e1a01009     	mov	r1, r9
   2cf0c: ebff939a     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1b198
   2cf10: e58541bc     	str	r4, [r5, #0x1bc]
   2cf14: e599018c     	ldr	r0, [r9, #0x18c]
   2cf18: e3500000     	cmp	r0, #0
   2cf1c: 0a000001     	beq	0x2cf28 <.text+0x1ce28> @ imm = #0x4
   2cf20: eb15da5e     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x576978
   2cf24: e585018c     	str	r0, [r5, #0x18c]
   2cf28: e59971a8     	ldr	r7, [r9, #0x1a8]
   2cf2c: e3570000     	cmp	r7, #0
   2cf30: 0a00001a     	beq	0x2cfa0 <.text+0x1cea0> @ imm = #0x68
   2cf34: e59f61e0     	ldr	r6, [pc, #0x1e0]        @ 0x2d11c <.text+0x1d01c>
   2cf38: e79f6006     	ldr	r6, [pc, r6]
   2cf3c: e5960000     	ldr	r0, [r6]
   2cf40: e59f41d8     	ldr	r4, [pc, #0x1d8]        @ 0x2d120 <.text+0x1d020>
   2cf44: e2401001     	sub	r1, r0, #1
   2cf48: e0000190     	mul	r0, r0, r1
   2cf4c: e79f4004     	ldr	r4, [pc, r4]
   2cf50: e3100001     	tst	r0, #1
   2cf54: 0a000002     	beq	0x2cf64 <.text+0x1ce64> @ imm = #0x8
   2cf58: e5940000     	ldr	r0, [r4]
   2cf5c: e3500009     	cmp	r0, #9
   2cf60: ca00000a     	bgt	0x2cf90 <.text+0x1ce90> @ imm = #0x28
   2cf64: e1a00007     	mov	r0, r7
   2cf68: eb15da4c     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x576930
   2cf6c: e58501a8     	str	r0, [r5, #0x1a8]
   2cf70: e5960000     	ldr	r0, [r6]
   2cf74: e2401001     	sub	r1, r0, #1
   2cf78: e0000190     	mul	r0, r0, r1
   2cf7c: e3100001     	tst	r0, #1
   2cf80: 0a000006     	beq	0x2cfa0 <.text+0x1cea0> @ imm = #0x18
   2cf84: e5940000     	ldr	r0, [r4]
   2cf88: e3500009     	cmp	r0, #9
   2cf8c: da000003     	ble	0x2cfa0 <.text+0x1cea0> @ imm = #0xc
   2cf90: e1a00007     	mov	r0, r7
   2cf94: eb15da41     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x576904
   2cf98: e58501a8     	str	r0, [r5, #0x1a8]
   2cf9c: eafffff0     	b	0x2cf64 <.text+0x1ce64> @ imm = #-0x40
   2cfa0: e599119c     	ldr	r1, [r9, #0x19c]
   2cfa4: e59f0178     	ldr	r0, [pc, #0x178]        @ 0x2d124 <.text+0x1d024>
   2cfa8: e3510000     	cmp	r1, #0
   2cfac: e79f0000     	ldr	r0, [pc, r0]
   2cfb0: 0a00001d     	beq	0x2d02c <.text+0x1cf2c> @ imm = #0x74
   2cfb4: e59f216c     	ldr	r2, [pc, #0x16c]        @ 0x2d128 <.text+0x1d028>
   2cfb8: e79f2002     	ldr	r2, [pc, r2]
   2cfbc: e5903000     	ldr	r3, [r0]
   2cfc0: e2437001     	sub	r7, r3, #1
   2cfc4: e0030793     	mul	r3, r3, r7
   2cfc8: e3130001     	tst	r3, #1
   2cfcc: 0a000002     	beq	0x2cfdc <.text+0x1cedc> @ imm = #0x8
   2cfd0: e5923000     	ldr	r3, [r2]
   2cfd4: e3530009     	cmp	r3, #9
   2cfd8: cafffff7     	bgt	0x2cfbc <.text+0x1cebc> @ imm = #-0x24
   2cfdc: e3580000     	cmp	r8, #0
   2cfe0: 0a000022     	beq	0x2d070 <.text+0x1cf70> @ imm = #0x88
   2cfe4: e5950044     	ldr	r0, [r5, #0x44]
   2cfe8: e28d700c     	add	r7, sp, #12
   2cfec: e3a02004     	mov	r2, #4
   2cff0: e6bf0f30     	rev	r0, r0
   2cff4: e0800008     	add	r0, r0, r8
   2cff8: e6bf0f30     	rev	r0, r0
   2cffc: e5850044     	str	r0, [r5, #0x44]
   2d000: e1a00007     	mov	r0, r7
   2d004: ebff8de9     	bl	0x107b0 <.text+0x6b0>   @ imm = #-0x1c85c
   2d008: e59d000c     	ldr	r0, [sp, #0xc]
   2d00c: e3a01004     	mov	r1, #4
   2d010: e6bf0f30     	rev	r0, r0
   2d014: e0800008     	add	r0, r0, r8
   2d018: e6bf0f30     	rev	r0, r0
   2d01c: e58d000c     	str	r0, [sp, #0xc]
   2d020: e1a00007     	mov	r0, r7
   2d024: ebff8d98     	bl	0x1068c <.text+0x58c>   @ imm = #-0x1c9a0
   2d028: ea000012     	b	0x2d078 <.text+0x1cf78> @ imm = #0x48
   2d02c: e59f10f8     	ldr	r1, [pc, #0xf8]         @ 0x2d12c <.text+0x1d02c>
   2d030: e79f1001     	ldr	r1, [pc, r1]
   2d034: e5902000     	ldr	r2, [r0]
   2d038: e2423001     	sub	r3, r2, #1
   2d03c: e0020392     	mul	r2, r2, r3
   2d040: e3120001     	tst	r2, #1
   2d044: 0a000002     	beq	0x2d054 <.text+0x1cf54> @ imm = #0x8
   2d048: e5912000     	ldr	r2, [r1]
   2d04c: e3520009     	cmp	r2, #9
   2d050: cafffff7     	bgt	0x2d034 <.text+0x1cf34> @ imm = #-0x24
   2d054: e3580000     	cmp	r8, #0
   2d058: 15950044     	ldrne	r0, [r5, #0x44]
   2d05c: 16bf0f30     	revne	r0, r0
   2d060: 10800008     	addne	r0, r0, r8
   2d064: 16bf0f30     	revne	r0, r0
   2d068: 15850044     	strne	r0, [r5, #0x44]
   2d06c: ea000002     	b	0x2d07c <.text+0x1cf7c> @ imm = #0x8
   2d070: e1a00001     	mov	r0, r1
   2d074: eb15da09     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x576824
   2d078: e585019c     	str	r0, [r5, #0x19c]
   2d07c: e59961b0     	ldr	r6, [r9, #0x1b0]
   2d080: e3560000     	cmp	r6, #0
   2d084: 0a00001a     	beq	0x2d0f4 <.text+0x1cff4> @ imm = #0x68
   2d088: e59f70a0     	ldr	r7, [pc, #0xa0]         @ 0x2d130 <.text+0x1d030>
   2d08c: e79f7007     	ldr	r7, [pc, r7]
   2d090: e5970000     	ldr	r0, [r7]
   2d094: e59f4098     	ldr	r4, [pc, #0x98]         @ 0x2d134 <.text+0x1d034>
   2d098: e2401001     	sub	r1, r0, #1
   2d09c: e0000190     	mul	r0, r0, r1
   2d0a0: e79f4004     	ldr	r4, [pc, r4]
   2d0a4: e3100001     	tst	r0, #1
   2d0a8: 0a000002     	beq	0x2d0b8 <.text+0x1cfb8> @ imm = #0x8
   2d0ac: e5940000     	ldr	r0, [r4]
   2d0b0: e3500009     	cmp	r0, #9
   2d0b4: ca00000a     	bgt	0x2d0e4 <.text+0x1cfe4> @ imm = #0x28
   2d0b8: e1a00006     	mov	r0, r6
   2d0bc: eb15d9f7     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x5767dc
   2d0c0: e58501b0     	str	r0, [r5, #0x1b0]
   2d0c4: e5970000     	ldr	r0, [r7]
   2d0c8: e2401001     	sub	r1, r0, #1
   2d0cc: e0000190     	mul	r0, r0, r1
   2d0d0: e3100001     	tst	r0, #1
   2d0d4: 0a000006     	beq	0x2d0f4 <.text+0x1cff4> @ imm = #0x18
   2d0d8: e5940000     	ldr	r0, [r4]
   2d0dc: e3500009     	cmp	r0, #9
   2d0e0: da000003     	ble	0x2d0f4 <.text+0x1cff4> @ imm = #0xc
   2d0e4: e1a00006     	mov	r0, r6
   2d0e8: eb15d9ec     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x5767b0
   2d0ec: e58501b0     	str	r0, [r5, #0x1b0]
   2d0f0: eafffff0     	b	0x2d0b8 <.text+0x1cfb8> @ imm = #-0x40
   2d0f4: e5990254     	ldr	r0, [r9, #0x254]
   2d0f8: e5850254     	str	r0, [r5, #0x254]
   2d0fc: e1a00005     	mov	r0, r5
   2d100: e24bd018     	sub	sp, r11, #24
   2d104: e8bd8bf0     	pop	{r4, r5, r6, r7, r8, r9, r11, pc}

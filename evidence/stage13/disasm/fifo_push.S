
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d19f0: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   d19f4: e28db010     	add	r11, sp, #16
   d19f8: e1a05001     	mov	r5, r1
   d19fc: e5901000     	ldr	r1, [r0]
   d1a00: e1a04000     	mov	r4, r0
   d1a04: e3a00000     	mov	r0, #0
   d1a08: e3510000     	cmp	r1, #0
   d1a0c: 15941010     	ldrne	r1, [r4, #0x10]
   d1a10: 15942014     	ldrne	r2, [r4, #0x14]
   d1a14: 11520001     	cmpne	r2, r1
   d1a18: 1a00000c     	bne	0xd1a50 <.text+0xc1950> @ imm = #0x30
   d1a1c: e59f1184     	ldr	r1, [pc, #0x184]        @ 0xd1ba8 <.text+0xc1aa8>
   d1a20: e79f1001     	ldr	r1, [pc, r1]
   d1a24: e59f2180     	ldr	r2, [pc, #0x180]        @ 0xd1bac <.text+0xc1aac>
   d1a28: e79f2002     	ldr	r2, [pc, r2]
   d1a2c: e5913000     	ldr	r3, [r1]
   d1a30: e2437001     	sub	r7, r3, #1
   d1a34: e0030793     	mul	r3, r3, r7
   d1a38: e3130001     	tst	r3, #1
   d1a3c: 0a000002     	beq	0xd1a4c <.text+0xc194c> @ imm = #0x8
   d1a40: e5923000     	ldr	r3, [r2]
   d1a44: e3530009     	cmp	r3, #9
   d1a48: cafffff7     	bgt	0xd1a2c <.text+0xc192c> @ imm = #-0x24
   d1a4c: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
   d1a50: e59f6148     	ldr	r6, [pc, #0x148]        @ 0xd1ba0 <.text+0xc1aa0>
   d1a54: e79f6006     	ldr	r6, [pc, r6]
   d1a58: e5960000     	ldr	r0, [r6]
   d1a5c: e59f7140     	ldr	r7, [pc, #0x140]        @ 0xd1ba4 <.text+0xc1aa4>
   d1a60: e2401001     	sub	r1, r0, #1
   d1a64: e0000190     	mul	r0, r0, r1
   d1a68: e79f7007     	ldr	r7, [pc, r7]
   d1a6c: e3100001     	tst	r0, #1
   d1a70: 0a000002     	beq	0xd1a80 <.text+0xc1980> @ imm = #0x8
   d1a74: e5970000     	ldr	r0, [r7]
   d1a78: e3500009     	cmp	r0, #9
   d1a7c: ca00000f     	bgt	0xd1ac0 <.text+0xc19c0> @ imm = #0x3c
   d1a80: e5940008     	ldr	r0, [r4, #0x8]
   d1a84: e1a01005     	mov	r1, r5
   d1a88: e5942018     	ldr	r2, [r4, #0x18]
   d1a8c: eb134515     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4d1454
   d1a90: e5942018     	ldr	r2, [r4, #0x18]
   d1a94: e9940003     	ldmib	r4, {r0, r1}
   d1a98: e0811002     	add	r1, r1, r2
   d1a9c: e5841008     	str	r1, [r4, #0x8]
   d1aa0: e5962000     	ldr	r2, [r6]
   d1aa4: e2423001     	sub	r3, r2, #1
   d1aa8: e0020392     	mul	r2, r2, r3
   d1aac: e3120001     	tst	r2, #1
   d1ab0: 0a00000b     	beq	0xd1ae4 <.text+0xc19e4> @ imm = #0x2c
   d1ab4: e5972000     	ldr	r2, [r7]
   d1ab8: e3520009     	cmp	r2, #9
   d1abc: da000008     	ble	0xd1ae4 <.text+0xc19e4> @ imm = #0x20
   d1ac0: e5940008     	ldr	r0, [r4, #0x8]
   d1ac4: e1a01005     	mov	r1, r5
   d1ac8: e5942018     	ldr	r2, [r4, #0x18]
   d1acc: eb134505     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4d1414
   d1ad0: e5940008     	ldr	r0, [r4, #0x8]
   d1ad4: e5941018     	ldr	r1, [r4, #0x18]
   d1ad8: e0800001     	add	r0, r0, r1
   d1adc: e5840008     	str	r0, [r4, #0x8]
   d1ae0: eaffffe6     	b	0xd1a80 <.text+0xc1980> @ imm = #-0x68
   d1ae4: e1510000     	cmp	r1, r0
   d1ae8: 1a000014     	bne	0xd1b40 <.text+0xc1a40> @ imm = #0x50
   d1aec: e5960000     	ldr	r0, [r6]
   d1af0: e2401001     	sub	r1, r0, #1
   d1af4: e0000190     	mul	r0, r0, r1
   d1af8: e3100001     	tst	r0, #1
   d1afc: 0a000002     	beq	0xd1b0c <.text+0xc1a0c> @ imm = #0x8
   d1b00: e5970000     	ldr	r0, [r7]
   d1b04: e3500009     	cmp	r0, #9
   d1b08: ca000009     	bgt	0xd1b34 <.text+0xc1a34> @ imm = #0x24
   d1b0c: e5940000     	ldr	r0, [r4]
   d1b10: e5840008     	str	r0, [r4, #0x8]
   d1b14: e5960000     	ldr	r0, [r6]
   d1b18: e2401001     	sub	r1, r0, #1
   d1b1c: e0000190     	mul	r0, r0, r1
   d1b20: e3100001     	tst	r0, #1
   d1b24: 0a000005     	beq	0xd1b40 <.text+0xc1a40> @ imm = #0x14
   d1b28: e5970000     	ldr	r0, [r7]
   d1b2c: e3500009     	cmp	r0, #9
   d1b30: da000002     	ble	0xd1b40 <.text+0xc1a40> @ imm = #0x8
   d1b34: e5940000     	ldr	r0, [r4]
   d1b38: e5840008     	str	r0, [r4, #0x8]
   d1b3c: eafffff2     	b	0xd1b0c <.text+0xc1a0c> @ imm = #-0x38
   d1b40: e5960000     	ldr	r0, [r6]
   d1b44: e2401001     	sub	r1, r0, #1
   d1b48: e0000190     	mul	r0, r0, r1
   d1b4c: e3100001     	tst	r0, #1
   d1b50: 0a000002     	beq	0xd1b60 <.text+0xc1a60> @ imm = #0x8
   d1b54: e5970000     	ldr	r0, [r7]
   d1b58: e3500009     	cmp	r0, #9
   d1b5c: ca00000b     	bgt	0xd1b90 <.text+0xc1a90> @ imm = #0x2c
   d1b60: e5940014     	ldr	r0, [r4, #0x14]
   d1b64: e2800001     	add	r0, r0, #1
   d1b68: e5840014     	str	r0, [r4, #0x14]
   d1b6c: e5960000     	ldr	r0, [r6]
   d1b70: e2401001     	sub	r1, r0, #1
   d1b74: e0010190     	mul	r1, r0, r1
   d1b78: e3a00001     	mov	r0, #1
   d1b7c: e3110001     	tst	r1, #1
   d1b80: 0affffa5     	beq	0xd1a1c <.text+0xc191c> @ imm = #-0x16c
   d1b84: e5971000     	ldr	r1, [r7]
   d1b88: e3510009     	cmp	r1, #9
   d1b8c: daffffa2     	ble	0xd1a1c <.text+0xc191c> @ imm = #-0x178
   d1b90: e5940014     	ldr	r0, [r4, #0x14]
   d1b94: e2800001     	add	r0, r0, #1
   d1b98: e5840014     	str	r0, [r4, #0x14]
   d1b9c: eaffffef     	b	0xd1b60 <.text+0xc1a60> @ imm = #-0x44
   d1ba0: 0050ccec     	subseq	r12, r0, r12, ror #25
   d1ba4: 0050d430     	subseq	sp, r0, r0, lsr r4
   d1ba8: 0050cd20     	subseq	r12, r0, r0, lsr #26
   d1bac: 0050d470     	subseq	sp, r0, r0, ror r4

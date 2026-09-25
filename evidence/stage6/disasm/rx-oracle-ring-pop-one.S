
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d1df0: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   d1df4: e28db010     	add	r11, sp, #16
   d1df8: e59f6118     	ldr	r6, [pc, #0x118]        @ 0xd1f18 <.text+0xc1e18>
   d1dfc: e1a04000     	mov	r4, r0
   d1e00: e1a05001     	mov	r5, r1
   d1e04: e79f6006     	ldr	r6, [pc, r6]
   d1e08: e5960000     	ldr	r0, [r6]
   d1e0c: e2401001     	sub	r1, r0, #1
   d1e10: e0000190     	mul	r0, r0, r1
   d1e14: e3100001     	tst	r0, #1
   d1e18: e5960000     	ldr	r0, [r6]
   d1e1c: e59f70f8     	ldr	r7, [pc, #0xf8]         @ 0xd1f1c <.text+0xc1e1c>
   d1e20: e2401001     	sub	r1, r0, #1
   d1e24: e0000190     	mul	r0, r0, r1
   d1e28: e79f7007     	ldr	r7, [pc, r7]
   d1e2c: e5941000     	ldr	r1, [r4]
   d1e30: e3100001     	tst	r0, #1
   d1e34: 0a000002     	beq	0xd1e44 <.text+0xc1d44> @ imm = #0x8
   d1e38: e5970000     	ldr	r0, [r7]
   d1e3c: e3500009     	cmp	r0, #9
   d1e40: cafffff4     	bgt	0xd1e18 <.text+0xc1d18> @ imm = #-0x30
   d1e44: e3510000     	cmp	r1, #0
   d1e48: e3a00000     	mov	r0, #0
   d1e4c: 15941014     	ldrne	r1, [r4, #0x14]
   d1e50: 13510000     	cmpne	r1, #0
   d1e54: 0a000026     	beq	0xd1ef4 <.text+0xc1df4> @ imm = #0x98
   d1e58: e3550000     	cmp	r5, #0
   d1e5c: 0a000018     	beq	0xd1ec4 <.text+0xc1dc4> @ imm = #0x60
   d1e60: e5960000     	ldr	r0, [r6]
   d1e64: e2401001     	sub	r1, r0, #1
   d1e68: e0000190     	mul	r0, r0, r1
   d1e6c: e3100001     	tst	r0, #1
   d1e70: 0a000002     	beq	0xd1e80 <.text+0xc1d80> @ imm = #0x8
   d1e74: e5970000     	ldr	r0, [r7]
   d1e78: e3500009     	cmp	r0, #9
   d1e7c: ca00000b     	bgt	0xd1eb0 <.text+0xc1db0> @ imm = #0x2c
   d1e80: e594100c     	ldr	r1, [r4, #0xc]
   d1e84: e1a00005     	mov	r0, r5
   d1e88: e5942018     	ldr	r2, [r4, #0x18]
   d1e8c: eb134415     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4d1054
   d1e90: e5960000     	ldr	r0, [r6]
   d1e94: e2401001     	sub	r1, r0, #1
   d1e98: e0000190     	mul	r0, r0, r1
   d1e9c: e3100001     	tst	r0, #1
   d1ea0: 0a000007     	beq	0xd1ec4 <.text+0xc1dc4> @ imm = #0x1c
   d1ea4: e5970000     	ldr	r0, [r7]
   d1ea8: e3500009     	cmp	r0, #9
   d1eac: da000004     	ble	0xd1ec4 <.text+0xc1dc4> @ imm = #0x10
   d1eb0: e594100c     	ldr	r1, [r4, #0xc]
   d1eb4: e1a00005     	mov	r0, r5
   d1eb8: e5942018     	ldr	r2, [r4, #0x18]
   d1ebc: eb134409     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4d1024
   d1ec0: eaffffee     	b	0xd1e80 <.text+0xc1d80> @ imm = #-0x48
   d1ec4: e594100c     	ldr	r1, [r4, #0xc]
   d1ec8: e5942018     	ldr	r2, [r4, #0x18]
   d1ecc: e5940004     	ldr	r0, [r4, #0x4]
   d1ed0: e0811002     	add	r1, r1, r2
   d1ed4: e584100c     	str	r1, [r4, #0xc]
   d1ed8: e1510000     	cmp	r1, r0
   d1edc: 05940000     	ldreq	r0, [r4]
   d1ee0: 0584000c     	streq	r0, [r4, #0xc]
   d1ee4: e5940014     	ldr	r0, [r4, #0x14]
   d1ee8: e2400001     	sub	r0, r0, #1
   d1eec: e5840014     	str	r0, [r4, #0x14]
   d1ef0: e3a00001     	mov	r0, #1
   d1ef4: e5961000     	ldr	r1, [r6]
   d1ef8: e2412001     	sub	r2, r1, #1
   d1efc: e0010291     	mul	r1, r1, r2
   d1f00: e3110001     	tst	r1, #1
   d1f04: 0a000002     	beq	0xd1f14 <.text+0xc1e14> @ imm = #0x8
   d1f08: e5971000     	ldr	r1, [r7]
   d1f0c: e3510009     	cmp	r1, #9
   d1f10: cafffff7     	bgt	0xd1ef4 <.text+0xc1df4> @ imm = #-0x24
   d1f14: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}

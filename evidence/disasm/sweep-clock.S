
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ec9f0: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   ec9f4: e28db01c     	add	r11, sp, #28
   ec9f8: e24dd00c     	sub	sp, sp, #12
   ec9fc: e59f8148     	ldr	r8, [pc, #0x148]        @ 0xecb4c <.text+0xdca4c>
   eca00: e1a04000     	mov	r4, r0
   eca04: e1a06001     	mov	r6, r1
   eca08: e308a700     	movw	r10, #0x8700
   eca0c: e1a05002     	mov	r5, r2
   eca10: e348a000     	movt	r10, #0x8000
   eca14: e79f8008     	ldr	r8, [pc, r8]
   eca18: e5980000     	ldr	r0, [r8]
   eca1c: e59f912c     	ldr	r9, [pc, #0x12c]        @ 0xecb50 <.text+0xdca50>
   eca20: e2401001     	sub	r1, r0, #1
   eca24: e0000190     	mul	r0, r0, r1
   eca28: e79f9009     	ldr	r9, [pc, r9]
   eca2c: e3100001     	tst	r0, #1
   eca30: 0a000002     	beq	0xeca40 <.text+0xdc940> @ imm = #0x8
   eca34: e5990000     	ldr	r0, [r9]
   eca38: e3500009     	cmp	r0, #9
   eca3c: ca000012     	bgt	0xeca8c <.text+0xdc98c> @ imm = #0x48
   eca40: e2060003     	and	r0, r6, #3
   eca44: e2051007     	and	r1, r5, #7
   eca48: e3a02000     	mov	r2, #0
   eca4c: e3a0303c     	mov	r3, #60
   eca50: e1810200     	orr	r0, r1, r0, lsl #4
   eca54: e3a01001     	mov	r1, #1
   eca58: e180000a     	orr	r0, r0, r10
   eca5c: e58d0000     	str	r0, [sp]
   eca60: e1a00004     	mov	r0, r4
   eca64: e3a07000     	mov	r7, #0
   eca68: eb00079d     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x1e74
   eca6c: e5981000     	ldr	r1, [r8]
   eca70: e2412001     	sub	r2, r1, #1
   eca74: e0010291     	mul	r1, r1, r2
   eca78: e3110001     	tst	r1, #1
   eca7c: 0a00000d     	beq	0xecab8 <.text+0xdc9b8> @ imm = #0x34
   eca80: e5991000     	ldr	r1, [r9]
   eca84: e3510009     	cmp	r1, #9
   eca88: da00000a     	ble	0xecab8 <.text+0xdc9b8> @ imm = #0x28
   eca8c: e2060003     	and	r0, r6, #3
   eca90: e2051007     	and	r1, r5, #7
   eca94: e3a02000     	mov	r2, #0
   eca98: e3a0303c     	mov	r3, #60
   eca9c: e1810200     	orr	r0, r1, r0, lsl #4
   ecaa0: e3a01001     	mov	r1, #1
   ecaa4: e180000a     	orr	r0, r0, r10
   ecaa8: e58d0000     	str	r0, [sp]
   ecaac: e1a00004     	mov	r0, r4
   ecab0: eb00078b     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x1e2c
   ecab4: eaffffe1     	b	0xeca40 <.text+0xdc940> @ imm = #-0x7c
   ecab8: e3500000     	cmp	r0, #0
   ecabc: 0a00001f     	beq	0xecb40 <.text+0xdca40> @ imm = #0x7c
   ecac0: e59f808c     	ldr	r8, [pc, #0x8c]         @ 0xecb54 <.text+0xdca54>
   ecac4: e3a05001     	mov	r5, #1
   ecac8: e59f6088     	ldr	r6, [pc, #0x88]         @ 0xecb58 <.text+0xdca58>
   ecacc: e30032d3     	movw	r3, #0x2d3
   ecad0: e59f7084     	ldr	r7, [pc, #0x84]         @ 0xecb5c <.text+0xdca5c>
   ecad4: e08f8008     	add	r8, pc, r8
   ecad8: e5940018     	ldr	r0, [r4, #0x18]
   ecadc: e08f6006     	add	r6, pc, r6
   ecae0: e59f1078     	ldr	r1, [pc, #0x78]         @ 0xecb60 <.text+0xdca60>
   ecae4: e08f7007     	add	r7, pc, r7
   ecae8: e2800001     	add	r0, r0, #1
   ecaec: e58d0008     	str	r0, [sp, #0x8]
   ecaf0: e08f1001     	add	r1, pc, r1
   ecaf4: e58d1004     	str	r1, [sp, #0x4]
   ecaf8: e1a00008     	mov	r0, r8
   ecafc: e1a01006     	mov	r1, r6
   ecb00: e1a02007     	mov	r2, r7
   ecb04: e58d5000     	str	r5, [sp]
   ecb08: eb00356d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xd5b4
   ecb0c: e5940018     	ldr	r0, [r4, #0x18]
   ecb10: e1a02007     	mov	r2, r7
   ecb14: e59f1048     	ldr	r1, [pc, #0x48]         @ 0xecb64 <.text+0xdca64>
   ecb18: e3a03e3e     	mov	r3, #992
   ecb1c: e2800001     	add	r0, r0, #1
   ecb20: e58d0008     	str	r0, [sp, #0x8]
   ecb24: e08f1001     	add	r1, pc, r1
   ecb28: e58d1004     	str	r1, [sp, #0x4]
   ecb2c: e1a00008     	mov	r0, r8
   ecb30: e1a01006     	mov	r1, r6
   ecb34: e58d5000     	str	r5, [sp]
   ecb38: eb003561     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xd584
   ecb3c: e3e07000     	mvn	r7, #0
   ecb40: e1a00007     	mov	r0, r7
   ecb44: e24bd01c     	sub	sp, r11, #28
   ecb48: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   ecb4c: 004f300c     	subeq	r3, pc, r12
   ecb50: 004f33ec     	subeq	r3, pc, r12, ror #7
   ecb54: 004ff404     	subeq	pc, pc, r4, lsl #8
   ecb58: 004ff403     	subeq	pc, pc, r3, lsl #8
   ecb5c: 004ff425     	subeq	pc, pc, r5, lsr #8
   ecb60: 004ffaef     	subeq	pc, pc, pc, ror #21
   ecb64: 004ff7a4     	subeq	pc, pc, r4, lsr #15

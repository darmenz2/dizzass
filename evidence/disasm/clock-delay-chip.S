
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ecb68: e92d4bf0     	push	{r4, r5, r6, r7, r8, r9, r11, lr}
   ecb6c: e28db018     	add	r11, sp, #24
   ecb70: e24dd010     	sub	sp, sp, #16
   ecb74: e1a04001     	mov	r4, r1
   ecb78: e1a01302     	lsl	r1, r2, #6
   ecb7c: e6ef1071     	uxtb	r1, r1
   ecb80: e1a05000     	mov	r5, r0
   ecb84: e7c51213     	bfi	r1, r3, #4, #2
   ecb88: e59b0008     	ldr	r0, [r11, #0x8]
   ecb8c: e1a02004     	mov	r2, r4
   ecb90: e3a0303c     	mov	r3, #60
   ecb94: e7c21110     	bfi	r1, r0, #2, #1
   ecb98: e3a06001     	mov	r6, #1
   ecb9c: e3810902     	orr	r0, r1, #32768
   ecba0: e3a01001     	mov	r1, #1
   ecba4: e3800102     	orr	r0, r0, #-2147483648
   ecba8: e58d0000     	str	r0, [sp]
   ecbac: e1a00005     	mov	r0, r5
   ecbb0: eb00074b     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x1d2c
   ecbb4: e3500000     	cmp	r0, #0
   ecbb8: 0a000022     	beq	0xecc48 <.text+0xdcb48> @ imm = #0x88
   ecbbc: e59f90c0     	ldr	r9, [pc, #0xc0]         @ 0xecc84 <.text+0xdcb84>
   ecbc0: e30032d3     	movw	r3, #0x2d3
   ecbc4: e59f70bc     	ldr	r7, [pc, #0xbc]         @ 0xecc88 <.text+0xdcb88>
   ecbc8: e59f80bc     	ldr	r8, [pc, #0xbc]         @ 0xecc8c <.text+0xdcb8c>
   ecbcc: e08f9009     	add	r9, pc, r9
   ecbd0: e5950018     	ldr	r0, [r5, #0x18]
   ecbd4: e08f7007     	add	r7, pc, r7
   ecbd8: e59f10b0     	ldr	r1, [pc, #0xb0]         @ 0xecc90 <.text+0xdcb90>
   ecbdc: e08f8008     	add	r8, pc, r8
   ecbe0: e2800001     	add	r0, r0, #1
   ecbe4: e58d0008     	str	r0, [sp, #0x8]
   ecbe8: e08f1001     	add	r1, pc, r1
   ecbec: e58d1004     	str	r1, [sp, #0x4]
   ecbf0: e1a00009     	mov	r0, r9
   ecbf4: e1a01007     	mov	r1, r7
   ecbf8: e1a02008     	mov	r2, r8
   ecbfc: e58d6000     	str	r6, [sp]
   ecc00: eb00352f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xd4bc
   ecc04: e5950018     	ldr	r0, [r5, #0x18]
   ecc08: e300338b     	movw	r3, #0x38b
   ecc0c: e5941000     	ldr	r1, [r4]
   ecc10: e59f207c     	ldr	r2, [pc, #0x7c]         @ 0xecc94 <.text+0xdcb94>
   ecc14: e2800001     	add	r0, r0, #1
   ecc18: e2811001     	add	r1, r1, #1
   ecc1c: e58d0008     	str	r0, [sp, #0x8]
   ecc20: e08f2002     	add	r2, pc, r2
   ecc24: e58d2004     	str	r2, [sp, #0x4]
   ecc28: e58d100c     	str	r1, [sp, #0xc]
   ecc2c: e1a00009     	mov	r0, r9
   ecc30: e1a01007     	mov	r1, r7
   ecc34: e1a02008     	mov	r2, r8
   ecc38: e58d6000     	str	r6, [sp]
   ecc3c: eb003520     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xd480
   ecc40: e3e00000     	mvn	r0, #0
   ecc44: ea000000     	b	0xecc4c <.text+0xdcb4c> @ imm = #0x0
   ecc48: e3a00000     	mov	r0, #0
   ecc4c: e59f1044     	ldr	r1, [pc, #0x44]         @ 0xecc98 <.text+0xdcb98>
   ecc50: e79f1001     	ldr	r1, [pc, r1]
   ecc54: e59f2040     	ldr	r2, [pc, #0x40]         @ 0xecc9c <.text+0xdcb9c>
   ecc58: e79f2002     	ldr	r2, [pc, r2]
   ecc5c: e5913000     	ldr	r3, [r1]
   ecc60: e2437001     	sub	r7, r3, #1
   ecc64: e0030793     	mul	r3, r3, r7
   ecc68: e3130001     	tst	r3, #1
   ecc6c: 0a000002     	beq	0xecc7c <.text+0xdcb7c> @ imm = #0x8
   ecc70: e5923000     	ldr	r3, [r2]
   ecc74: e3530009     	cmp	r3, #9
   ecc78: cafffff7     	bgt	0xecc5c <.text+0xdcb5c> @ imm = #-0x24
   ecc7c: e24bd018     	sub	sp, r11, #24
   ecc80: e8bd8bf0     	pop	{r4, r5, r6, r7, r8, r9, r11, pc}
   ecc84: 004ff30c     	subeq	pc, pc, r12, lsl #6
   ecc88: 004ff30b     	subeq	pc, pc, r11, lsl #6
   ecc8c: 004ff32d     	subeq	pc, pc, sp, lsr #6
   ecc90: 004ff9f7     	<unknown>
   ecc94: 004ff5f1     	<unknown>
   ecc98: 004f2180     	subeq	r2, pc, r0, lsl #3
   ecc9c: 004f2538     	subeq	r2, pc, r8, lsr r5


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  108f38: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  108f3c: e28db01c     	add	r11, sp, #28
  108f40: e24dd0b4     	sub	sp, sp, #180
  108f44: e58d2004     	str	r2, [sp, #0x4]
  108f48: e1a08001     	mov	r8, r1
  108f4c: e59f11b8     	ldr	r1, [pc, #0x1b8]        @ 0x10910c <.text+0xf900c>
  108f50: e3580040     	cmp	r8, #64
  108f54: e1a0a008     	mov	r10, r8
  108f58: 23a0a040     	movhs	r10, #64
  108f5c: e79f1001     	ldr	r1, [pc, r1]
  108f60: e991008c     	ldmib	r1, {r2, r3, r7}
  108f64: e591c000     	ldr	r12, [r1]
  108f68: e58dc090     	str	r12, [sp, #0x90]
  108f6c: e28dc094     	add	r12, sp, #148
  108f70: e88c008c     	stm	r12, {r2, r3, r7}
  108f74: e1a07000     	mov	r7, r0
  108f78: e3a00000     	mov	r0, #0
  108f7c: e5916010     	ldr	r6, [r1, #0x10]
  108f80: e1a0200a     	mov	r2, r10
  108f84: e5915014     	ldr	r5, [r1, #0x14]
  108f88: e5914018     	ldr	r4, [r1, #0x18]
  108f8c: e591101c     	ldr	r1, [r1, #0x1c]
  108f90: e58d60a0     	str	r6, [sp, #0xa0]
  108f94: e58d50a4     	str	r5, [sp, #0xa4]
  108f98: e58d40a8     	str	r4, [sp, #0xa8]
  108f9c: e58d10ac     	str	r1, [sp, #0xac]
  108fa0: e1a01007     	mov	r1, r7
  108fa4: e58d000c     	str	r0, [sp, #0xc]
  108fa8: e58d0008     	str	r0, [sp, #0x8]
  108fac: e28d0008     	add	r0, sp, #8
  108fb0: e2809008     	add	r9, r0, #8
  108fb4: e1a00009     	mov	r0, r9
  108fb8: eb1267ca     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x499f28
  108fbc: e358003f     	cmp	r8, #63
  108fc0: 8a000001     	bhi	0x108fcc <.text+0xf8ecc> @ imm = #0x4
  108fc4: e58d800c     	str	r8, [sp, #0xc]
  108fc8: ea00004a     	b	0x1090f8 <.text+0xf8ff8> @ imm = #0x128
  108fcc: e59f013c     	ldr	r0, [pc, #0x13c]        @ 0x109110 <.text+0xf9010>
  108fd0: e79f0000     	ldr	r0, [pc, r0]
  108fd4: e5900000     	ldr	r0, [r0]
  108fd8: e2401001     	sub	r1, r0, #1
  108fdc: e0000190     	mul	r0, r0, r1
  108fe0: e3100001     	tst	r0, #1
  108fe4: 0a000004     	beq	0x108ffc <.text+0xf8efc> @ imm = #0x10
  108fe8: e59f0124     	ldr	r0, [pc, #0x124]        @ 0x109114 <.text+0xf9014>
  108fec: e79f0000     	ldr	r0, [pc, r0]
  108ff0: e5900000     	ldr	r0, [r0]
  108ff4: e3500009     	cmp	r0, #9
  108ff8: ca000024     	bgt	0x109090 <.text+0xf8f90> @ imm = #0x90
  108ffc: e28d6008     	add	r6, sp, #8
  109000: e1a01009     	mov	r1, r9
  109004: e3a02001     	mov	r2, #1
  109008: e1a00006     	mov	r0, r6
  10900c: ebfffeda     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x498
  109010: e087500a     	add	r5, r7, r10
  109014: e1a04008     	mov	r4, r8
  109018: e048800a     	sub	r8, r8, r10
  10901c: e1a00006     	mov	r0, r6
  109020: e1a01005     	mov	r1, r5
  109024: e1a02328     	lsr	r2, r8, #6
  109028: ebfffed3     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x4b4
  10902c: e3c8003f     	bic	r0, r8, #63
  109030: e0851000     	add	r1, r5, r0
  109034: e208503f     	and	r5, r8, #63
  109038: e1a00009     	mov	r0, r9
  10903c: e1a02005     	mov	r2, r5
  109040: eb1267a8     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x499ea0
  109044: e59f00cc     	ldr	r0, [pc, #0xcc]         @ 0x109118 <.text+0xf9018>
  109048: e79f0000     	ldr	r0, [pc, r0]
  10904c: e58d500c     	str	r5, [sp, #0xc]
  109050: e59d3008     	ldr	r3, [sp, #0x8]
  109054: e5900000     	ldr	r0, [r0]
  109058: e2401001     	sub	r1, r0, #1
  10905c: e0010190     	mul	r1, r0, r1
  109060: e2880040     	add	r0, r8, #64
  109064: e3c0203f     	bic	r2, r0, #63
  109068: e59f00ac     	ldr	r0, [pc, #0xac]         @ 0x10911c <.text+0xf901c>
  10906c: e0832002     	add	r2, r3, r2
  109070: e79f0000     	ldr	r0, [pc, r0]
  109074: e3110001     	tst	r1, #1
  109078: e58d2008     	str	r2, [sp, #0x8]
  10907c: e5900000     	ldr	r0, [r0]
  109080: 0a00001c     	beq	0x1090f8 <.text+0xf8ff8> @ imm = #0x70
  109084: e1a08004     	mov	r8, r4
  109088: e3500009     	cmp	r0, #9
  10908c: da000019     	ble	0x1090f8 <.text+0xf8ff8> @ imm = #0x64
  109090: e28d5008     	add	r5, sp, #8
  109094: e1a01009     	mov	r1, r9
  109098: e3a02001     	mov	r2, #1
  10909c: e1a00005     	mov	r0, r5
  1090a0: ebfffeb5     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x52c
  1090a4: e087600a     	add	r6, r7, r10
  1090a8: e1a04007     	mov	r4, r7
  1090ac: e048700a     	sub	r7, r8, r10
  1090b0: e1a00005     	mov	r0, r5
  1090b4: e1a01006     	mov	r1, r6
  1090b8: e1a02327     	lsr	r2, r7, #6
  1090bc: ebfffeae     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x548
  1090c0: e3c7003f     	bic	r0, r7, #63
  1090c4: e207503f     	and	r5, r7, #63
  1090c8: e0861000     	add	r1, r6, r0
  1090cc: e1a00009     	mov	r0, r9
  1090d0: e1a02005     	mov	r2, r5
  1090d4: eb126783     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x499e0c
  1090d8: e58d500c     	str	r5, [sp, #0xc]
  1090dc: e2871040     	add	r1, r7, #64
  1090e0: e59d0008     	ldr	r0, [sp, #0x8]
  1090e4: e3c1103f     	bic	r1, r1, #63
  1090e8: e1a07004     	mov	r7, r4
  1090ec: e0800001     	add	r0, r0, r1
  1090f0: e58d0008     	str	r0, [sp, #0x8]
  1090f4: eaffffc0     	b	0x108ffc <.text+0xf8efc> @ imm = #-0x100
  1090f8: e59d1004     	ldr	r1, [sp, #0x4]
  1090fc: e28d0008     	add	r0, sp, #8
  109100: eb0000a5     	bl	0x10939c <.text+0xf929c> @ imm = #0x294
  109104: e24bd01c     	sub	sp, r11, #28
  109108: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  10910c: 004d66f0     	strdeq	r6, r7, [sp], #-96
  109110: 004d5770     	subeq	r5, sp, r0, ror r7
  109114: 004d5eac     	subeq	r5, sp, r12, lsr #29
  109118: 004d56f8     	strdeq	r5, r6, [sp], #-104
  10911c: 004d5e28     	subeq	r5, sp, r8, lsr #28


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ee8e4: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   ee8e8: e28db01c     	add	r11, sp, #28
   ee8ec: e24dd01c     	sub	sp, sp, #28
   ee8f0: e1a04000     	mov	r4, r0
   ee8f4: e3a08000     	mov	r8, #0
   ee8f8: e3a00009     	mov	r0, #9
   ee8fc: e1a0a001     	mov	r10, r1
   ee900: e58d8018     	str	r8, [sp, #0x18]
   ee904: e35a0001     	cmp	r10, #1
   ee908: e58d8015     	str	r8, [sp, #0x15]
   ee90c: e1a07002     	mov	r7, r2
   ee910: e5cd0014     	strb	r0, [sp, #0x14]
   ee914: e3a00041     	mov	r0, #65
   ee918: 03000051     	movweq	r0, #0x51
   ee91c: e59b1008     	ldr	r1, [r11, #0x8]
   ee920: e5cd0013     	strb	r0, [sp, #0x13]
   ee924: e3520000     	cmp	r2, #0
   ee928: e3a00000     	mov	r0, #0
   ee92c: e1a05003     	mov	r5, r3
   ee930: 15970004     	ldrne	r0, [r7, #0x4]
   ee934: e28d6013     	add	r6, sp, #19
   ee938: e5cd101a     	strb	r1, [sp, #0x1a]
   ee93c: e5cd5016     	strb	r5, [sp, #0x16]
   ee940: e5cd0015     	strb	r0, [sp, #0x15]
   ee944: e1a00421     	lsr	r0, r1, #8
   ee948: e5cd0019     	strb	r0, [sp, #0x19]
   ee94c: e1a00821     	lsr	r0, r1, #16
   ee950: e5cd0018     	strb	r0, [sp, #0x18]
   ee954: e1a00c21     	lsr	r0, r1, #24
   ee958: e5cd0017     	strb	r0, [sp, #0x17]
   ee95c: e1a00006     	mov	r0, r6
   ee960: e3a01040     	mov	r1, #64
   ee964: eb002569     	bl	0xf7f10 <.text+0xe7e10> @ imm = #0x95a4
   ee968: e5cd001b     	strb	r0, [sp, #0x1b]
   ee96c: e1a00004     	mov	r0, r4
   ee970: e1a01006     	mov	r1, r6
   ee974: e3a02009     	mov	r2, #9
   ee978: ebff8f4b     	bl	0xd26ac <.text+0xc25ac> @ imm = #-0x1c2d4
   ee97c: e59f6144     	ldr	r6, [pc, #0x144]        @ 0xeeac8 <.text+0xde9c8>
   ee980: e79f6006     	ldr	r6, [pc, r6]
   ee984: e59f9140     	ldr	r9, [pc, #0x140]        @ 0xeeacc <.text+0xde9cc>
   ee988: e79f9009     	ldr	r9, [pc, r9]
   ee98c: e5991000     	ldr	r1, [r9]
   ee990: e351000a     	cmp	r1, #10
   ee994: b3008001     	movwlt	r8, #0x1
   ee998: e3500000     	cmp	r0, #0
   ee99c: 0a000009     	beq	0xee9c8 <.text+0xde8c8> @ imm = #0x24
   ee9a0: e5960000     	ldr	r0, [r6]
   ee9a4: e59f7124     	ldr	r7, [pc, #0x124]        @ 0xeead0 <.text+0xde9d0>
   ee9a8: e2401001     	sub	r1, r0, #1
   ee9ac: e08f7007     	add	r7, pc, r7
   ee9b0: e0000190     	mul	r0, r0, r1
   ee9b4: e3a01001     	mov	r1, #1
   ee9b8: e1c10000     	bic	r0, r1, r0
   ee9bc: e1900008     	orrs	r0, r0, r8
   ee9c0: 1a00001a     	bne	0xeea30 <.text+0xde930> @ imm = #0x68
   ee9c4: ea00002f     	b	0xeea88 <.text+0xde988> @ imm = #0xbc
   ee9c8: e59b3008     	ldr	r3, [r11, #0x8]
   ee9cc: e5960000     	ldr	r0, [r6]
   ee9d0: e2401001     	sub	r1, r0, #1
   ee9d4: e0010190     	mul	r1, r0, r1
   ee9d8: e5940018     	ldr	r0, [r4, #0x18]
   ee9dc: e3110001     	tst	r1, #1
   ee9e0: 0a000002     	beq	0xee9f0 <.text+0xde8f0> @ imm = #0x8
   ee9e4: e5991000     	ldr	r1, [r9]
   ee9e8: e3510009     	cmp	r1, #9
   ee9ec: cafffff6     	bgt	0xee9cc <.text+0xde8cc> @ imm = #-0x28
   ee9f0: e35a0000     	cmp	r10, #0
   ee9f4: 0a000003     	beq	0xeea08 <.text+0xde908> @ imm = #0xc
   ee9f8: e1a01005     	mov	r1, r5
   ee9fc: e1a02003     	mov	r2, r3
   eea00: eb006310     	bl	0x107648 <.text+0xf7548> @ imm = #0x18c40
   eea04: ea000004     	b	0xeea1c <.text+0xde91c> @ imm = #0x10
   eea08: e3570000     	cmp	r7, #0
   eea0c: e1a02005     	mov	r2, r5
   eea10: 15971000     	ldrne	r1, [r7]
   eea14: 03a01000     	moveq	r1, #0
   eea18: eb00652c     	bl	0x107ed0 <.text+0xf7dd0> @ imm = #0x194b0
   eea1c: e1a01000     	mov	r1, r0
   eea20: e3e00000     	mvn	r0, #0
   eea24: e3510000     	cmp	r1, #0
   eea28: 03a00000     	moveq	r0, #0
   eea2c: ea000023     	b	0xeeac0 <.text+0xde9c0> @ imm = #0x8c
   eea30: e59f009c     	ldr	r0, [pc, #0x9c]         @ 0xeead4 <.text+0xde9d4>
   eea34: e3a05001     	mov	r5, #1
   eea38: e59f1098     	ldr	r1, [pc, #0x98]         @ 0xeead8 <.text+0xde9d8>
   eea3c: e59f2098     	ldr	r2, [pc, #0x98]         @ 0xeeadc <.text+0xde9dc>
   eea40: e08f0000     	add	r0, pc, r0
   eea44: e5943018     	ldr	r3, [r4, #0x18]
   eea48: e08f1001     	add	r1, pc, r1
   eea4c: e08f2002     	add	r2, pc, r2
   eea50: e88d00a0     	stm	sp, {r5, r7}
   eea54: e2833001     	add	r3, r3, #1
   eea58: e58d3008     	str	r3, [sp, #0x8]
   eea5c: e3a03e16     	mov	r3, #352
   eea60: eb002d97     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xb65c
   eea64: e5960000     	ldr	r0, [r6]
   eea68: e2401001     	sub	r1, r0, #1
   eea6c: e0010190     	mul	r1, r0, r1
   eea70: e3e00000     	mvn	r0, #0
   eea74: e3110001     	tst	r1, #1
   eea78: 0a000010     	beq	0xeeac0 <.text+0xde9c0> @ imm = #0x40
   eea7c: e5991000     	ldr	r1, [r9]
   eea80: e351000a     	cmp	r1, #10
   eea84: ba00000d     	blt	0xeeac0 <.text+0xde9c0> @ imm = #0x34
   eea88: e59f0050     	ldr	r0, [pc, #0x50]         @ 0xeeae0 <.text+0xde9e0>
   eea8c: e3a05001     	mov	r5, #1
   eea90: e59f104c     	ldr	r1, [pc, #0x4c]         @ 0xeeae4 <.text+0xde9e4>
   eea94: e59f204c     	ldr	r2, [pc, #0x4c]         @ 0xeeae8 <.text+0xde9e8>
   eea98: e08f0000     	add	r0, pc, r0
   eea9c: e5943018     	ldr	r3, [r4, #0x18]
   eeaa0: e08f1001     	add	r1, pc, r1
   eeaa4: e08f2002     	add	r2, pc, r2
   eeaa8: e88d00a0     	stm	sp, {r5, r7}
   eeaac: e2833001     	add	r3, r3, #1
   eeab0: e58d3008     	str	r3, [sp, #0x8]
   eeab4: e3a03e16     	mov	r3, #352
   eeab8: eb002d81     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xb604
   eeabc: eaffffdb     	b	0xeea30 <.text+0xde930> @ imm = #-0x94
   eeac0: e24bd01c     	sub	sp, r11, #28
   eeac4: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   eeac8: 004f0774     	subeq	r0, pc, r4, ror r7
   eeacc: 004f0b34     	subeq	r0, pc, r4, lsr r11
   eead0: 004fdc06     	subeq	sp, pc, r6, lsl #24
   eead4: 004fd498     	umaaleq	sp, pc, r8, r4
   eead8: 004fd497     	umaaleq	sp, pc, r7, r4
   eeadc: 004fd4bd     	strheq	sp, [pc], #-77
   eeae0: 004fd440     	subeq	sp, pc, r0, asr #8
   eeae4: 004fd43f     	subeq	sp, pc, pc, lsr r4
   eeae8: 004fd465     	subeq	sp, pc, r5, ror #8

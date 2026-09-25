
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  106e58: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  106e5c: e28db01c     	add	r11, sp, #28
  106e60: e24dd00c     	sub	sp, sp, #12
  106e64: e58d1008     	str	r1, [sp, #0x8]
  106e68: e1a04002     	mov	r4, r2
  106e6c: e59f92b4     	ldr	r9, [pc, #0x2b4]        @ 0x107128 <.text+0xf7028>
  106e70: e79f9009     	ldr	r9, [pc, r9]
  106e74: e59f52b0     	ldr	r5, [pc, #0x2b0]        @ 0x10712c <.text+0xf702c>
  106e78: e79f5005     	ldr	r5, [pc, r5]
  106e7c: e5991000     	ldr	r1, [r9]
  106e80: e2412001     	sub	r2, r1, #1
  106e84: e0010291     	mul	r1, r1, r2
  106e88: e3110001     	tst	r1, #1
  106e8c: 0a000002     	beq	0x106e9c <.text+0xf6d9c> @ imm = #0x8
  106e90: e5951000     	ldr	r1, [r5]
  106e94: e3510009     	cmp	r1, #9
  106e98: cafffff7     	bgt	0x106e7c <.text+0xf6d7c> @ imm = #-0x24
  106e9c: e3500007     	cmp	r0, #7
  106ea0: 8a00000f     	bhi	0x106ee4 <.text+0xf6de4> @ imm = #0x3c
  106ea4: e59f6284     	ldr	r6, [pc, #0x284]        @ 0x107130 <.text+0xf7030>
  106ea8: e79f6006     	ldr	r6, [pc, r6]
  106eac: e28f1004     	add	r1, pc, #4
  106eb0: e7910100     	ldr	r0, [r1, r0, lsl #2]
  106eb4: e081f000     	add	pc, r1, r0
  106eb8: 000000c4     	andeq	r0, r0, r4, asr #1
  106ebc: 00000020     	andeq	r0, r0, r0, lsr #32
  106ec0: 00000060     	andeq	r0, r0, r0, rrx
  106ec4: 0000006c     	andeq	r0, r0, r12, rrx
  106ec8: 00000098     	muleq	r0, r8, r0
  106ecc: 000000a4     	andeq	r0, r0, r4, lsr #1
  106ed0: 000000b0     	strheq	r0, [r0], -r0
  106ed4: 000000bc     	strheq	r0, [r0], -r12
  106ed8: e59f627c     	ldr	r6, [pc, #0x27c]        @ 0x10715c <.text+0xf705c>
  106edc: e79f6006     	ldr	r6, [pc, r6]
  106ee0: ea000025     	b	0x106f7c <.text+0xf6e7c> @ imm = #0x94
  106ee4: e59f0260     	ldr	r0, [pc, #0x260]        @ 0x10714c <.text+0xf704c>
  106ee8: e3a07001     	mov	r7, #1
  106eec: e59f125c     	ldr	r1, [pc, #0x25c]        @ 0x107150 <.text+0xf7050>
  106ef0: e59f225c     	ldr	r2, [pc, #0x25c]        @ 0x107154 <.text+0xf7054>
  106ef4: e08f0000     	add	r0, pc, r0
  106ef8: e59f3258     	ldr	r3, [pc, #0x258]        @ 0x107158 <.text+0xf7058>
  106efc: e08f1001     	add	r1, pc, r1
  106f00: e08f2002     	add	r2, pc, r2
  106f04: e58d7000     	str	r7, [sp]
  106f08: e08f3003     	add	r3, pc, r3
  106f0c: e58d3004     	str	r3, [sp, #0x4]
  106f10: e3a03fb6     	mov	r3, #728
  106f14: ea000077     	b	0x1070f8 <.text+0xf6ff8> @ imm = #0x1dc
  106f18: e59f6220     	ldr	r6, [pc, #0x220]        @ 0x107140 <.text+0xf7040>
  106f1c: e79f6006     	ldr	r6, [pc, r6]
  106f20: ea000015     	b	0x106f7c <.text+0xf6e7c> @ imm = #0x54
  106f24: e59f6208     	ldr	r6, [pc, #0x208]        @ 0x107134 <.text+0xf7034>
  106f28: e79f6006     	ldr	r6, [pc, r6]
  106f2c: e5990000     	ldr	r0, [r9]
  106f30: e2401001     	sub	r1, r0, #1
  106f34: e0000190     	mul	r0, r0, r1
  106f38: e3100001     	tst	r0, #1
  106f3c: 0a00000e     	beq	0x106f7c <.text+0xf6e7c> @ imm = #0x38
  106f40: e5950000     	ldr	r0, [r5]
  106f44: e350000a     	cmp	r0, #10
  106f48: aafffff7     	bge	0x106f2c <.text+0xf6e2c> @ imm = #-0x24
  106f4c: ea00000a     	b	0x106f7c <.text+0xf6e7c> @ imm = #0x28
  106f50: e59f61e0     	ldr	r6, [pc, #0x1e0]        @ 0x107138 <.text+0xf7038>
  106f54: e79f6006     	ldr	r6, [pc, r6]
  106f58: ea000007     	b	0x106f7c <.text+0xf6e7c> @ imm = #0x1c
  106f5c: e59f61d8     	ldr	r6, [pc, #0x1d8]        @ 0x10713c <.text+0xf703c>
  106f60: e79f6006     	ldr	r6, [pc, r6]
  106f64: ea000004     	b	0x106f7c <.text+0xf6e7c> @ imm = #0x10
  106f68: e59f61d4     	ldr	r6, [pc, #0x1d4]        @ 0x107144 <.text+0xf7044>
  106f6c: e79f6006     	ldr	r6, [pc, r6]
  106f70: ea000001     	b	0x106f7c <.text+0xf6e7c> @ imm = #0x4
  106f74: e59f61cc     	ldr	r6, [pc, #0x1cc]        @ 0x107148 <.text+0xf7048>
  106f78: e79f6006     	ldr	r6, [pc, r6]
  106f7c: e59f31dc     	ldr	r3, [pc, #0x1dc]        @ 0x107160 <.text+0xf7060>
  106f80: e79f3003     	ldr	r3, [pc, r3]
  106f84: e3530000     	cmp	r3, #0
  106f88: 0a000041     	beq	0x107094 <.text+0xf6f94> @ imm = #0x104
  106f8c: e59d0008     	ldr	r0, [sp, #0x8]
  106f90: e3500001     	cmp	r0, #1
  106f94: ba00003c     	blt	0x10708c <.text+0xf6f8c> @ imm = #0xf0
  106f98: e5990000     	ldr	r0, [r9]
  106f9c: e2401001     	sub	r1, r0, #1
  106fa0: e0000190     	mul	r0, r0, r1
  106fa4: e3100001     	tst	r0, #1
  106fa8: e5990000     	ldr	r0, [r9]
  106fac: e2401001     	sub	r1, r0, #1
  106fb0: e0000190     	mul	r0, r0, r1
  106fb4: e3100001     	tst	r0, #1
  106fb8: 0a000002     	beq	0x106fc8 <.text+0xf6ec8> @ imm = #0x8
  106fbc: e5950000     	ldr	r0, [r5]
  106fc0: e3500009     	cmp	r0, #9
  106fc4: cafffff7     	bgt	0x106fa8 <.text+0xf6ea8> @ imm = #-0x24
  106fc8: e3a08000     	mov	r8, #0
  106fcc: ea000006     	b	0x106fec <.text+0xf6eec> @ imm = #0x18
  106fd0: e59d0008     	ldr	r0, [sp, #0x8]
  106fd4: e1a03005     	mov	r3, r5
  106fd8: e59f5194     	ldr	r5, [pc, #0x194]        @ 0x107174 <.text+0xf7074>
  106fdc: e2888001     	add	r8, r8, #1
  106fe0: e1580000     	cmp	r8, r0
  106fe4: e79f5005     	ldr	r5, [pc, r5]
  106fe8: 0a000027     	beq	0x10708c <.text+0xf6f8c> @ imm = #0x9c
  106fec: e5990000     	ldr	r0, [r9]
  106ff0: e2401001     	sub	r1, r0, #1
  106ff4: e0000190     	mul	r0, r0, r1
  106ff8: e3100001     	tst	r0, #1
  106ffc: e5990000     	ldr	r0, [r9]
  107000: e0881308     	add	r1, r8, r8, lsl #6
  107004: e2402001     	sub	r2, r0, #1
  107008: e0020290     	mul	r2, r0, r2
  10700c: e0830181     	add	r0, r3, r1, lsl #3
  107010: e1a0a000     	mov	r10, r0
  107014: e5ba7200     	ldr	r7, [r10, #0x200]!
  107018: e3120001     	tst	r2, #1
  10701c: 0a000002     	beq	0x10702c <.text+0xf6f2c> @ imm = #0x8
  107020: e5951000     	ldr	r1, [r5]
  107024: e3510009     	cmp	r1, #9
  107028: cafffff3     	bgt	0x106ffc <.text+0xf6efc> @ imm = #-0x34
  10702c: e3570000     	cmp	r7, #0
  107030: 0a000024     	beq	0x1070c8 <.text+0xf6fc8> @ imm = #0x90
  107034: e1a01006     	mov	r1, r6
  107038: e3a02c02     	mov	r2, #512
  10703c: e1a05003     	mov	r5, r3
  107040: eb126fa8     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x49bea0
  107044: e3540001     	cmp	r4, #1
  107048: baffffe0     	blt	0x106fd0 <.text+0xf6ed0> @ imm = #-0x80
  10704c: e1a00007     	mov	r0, r7
  107050: e1a01006     	mov	r1, r6
  107054: e3a02c02     	mov	r2, #512
  107058: eb126fa2     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x49be88
  10705c: e3540001     	cmp	r4, #1
  107060: 0affffda     	beq	0x106fd0 <.text+0xf6ed0> @ imm = #-0x98
  107064: e3a07001     	mov	r7, #1
  107068: e59a0000     	ldr	r0, [r10]
  10706c: e1a01006     	mov	r1, r6
  107070: e3a02c02     	mov	r2, #512
  107074: e0800487     	add	r0, r0, r7, lsl #9
  107078: eb126f9a     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x49be68
  10707c: e2877001     	add	r7, r7, #1
  107080: e1540007     	cmp	r4, r7
  107084: 1afffff7     	bne	0x107068 <.text+0xf6f68> @ imm = #-0x24
  107088: eaffffd0     	b	0x106fd0 <.text+0xf6ed0> @ imm = #-0xc0
  10708c: e3a00000     	mov	r0, #0
  107090: ea00001a     	b	0x107100 <.text+0xf7000> @ imm = #0x68
  107094: e59f00dc     	ldr	r0, [pc, #0xdc]         @ 0x107178 <.text+0xf7078>
  107098: e3a07001     	mov	r7, #1
  10709c: e59f10d8     	ldr	r1, [pc, #0xd8]         @ 0x10717c <.text+0xf707c>
  1070a0: e59f20d8     	ldr	r2, [pc, #0xd8]         @ 0x107180 <.text+0xf7080>
  1070a4: e08f0000     	add	r0, pc, r0
  1070a8: e59f30d4     	ldr	r3, [pc, #0xd4]         @ 0x107184 <.text+0xf7084>
  1070ac: e08f1001     	add	r1, pc, r1
  1070b0: e08f2002     	add	r2, pc, r2
  1070b4: e58d7000     	str	r7, [sp]
  1070b8: e08f3003     	add	r3, pc, r3
  1070bc: e58d3004     	str	r3, [sp, #0x4]
  1070c0: e30032dd     	movw	r3, #0x2dd
  1070c4: ea00000b     	b	0x1070f8 <.text+0xf6ff8> @ imm = #0x2c
  1070c8: e59f0094     	ldr	r0, [pc, #0x94]         @ 0x107164 <.text+0xf7064>
  1070cc: e3a07001     	mov	r7, #1
  1070d0: e59f1090     	ldr	r1, [pc, #0x90]         @ 0x107168 <.text+0xf7068>
  1070d4: e59f2090     	ldr	r2, [pc, #0x90]         @ 0x10716c <.text+0xf706c>
  1070d8: e08f0000     	add	r0, pc, r0
  1070dc: e59f308c     	ldr	r3, [pc, #0x8c]         @ 0x107170 <.text+0xf7070>
  1070e0: e08f1001     	add	r1, pc, r1
  1070e4: e08f2002     	add	r2, pc, r2
  1070e8: e58d7000     	str	r7, [sp]
  1070ec: e08f3003     	add	r3, pc, r3
  1070f0: e58d3004     	str	r3, [sp, #0x4]
  1070f4: e30032e5     	movw	r3, #0x2e5
  1070f8: ebffcbf1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd03c
  1070fc: e3e00000     	mvn	r0, #0
  107100: e5991000     	ldr	r1, [r9]
  107104: e2412001     	sub	r2, r1, #1
  107108: e0010291     	mul	r1, r1, r2
  10710c: e3110001     	tst	r1, #1
  107110: 0a000002     	beq	0x107120 <.text+0xf7020> @ imm = #0x8
  107114: e5951000     	ldr	r1, [r5]
  107118: e3510009     	cmp	r1, #9
  10711c: cafffff7     	bgt	0x107100 <.text+0xf7000> @ imm = #-0x24
  107120: e24bd01c     	sub	sp, r11, #28
  107124: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  107128: 004d8a78     	subeq	r8, sp, r8, ror r10
  10712c: 004d8e38     	subeq	r8, sp, r8, lsr lr
  107130: 004d8b58     	subeq	r8, sp, r8, asr r11
  107134: 004d7bf0     	strdeq	r7, r8, [sp], #-176
  107138: 004d8644     	subeq	r8, sp, r4, asr #12
  10713c: 004d7780     	subeq	r7, sp, r0, lsl #15
  107140: 004d7f44     	subeq	r7, sp, r4, asr #30
  107144: 004d785c     	subeq	r7, sp, r12, asr r8
  107148: 004d8208     	subeq	r8, sp, r8, lsl #4
  10714c: 004e656f     	subeq	r6, lr, pc, ror #10
  107150: 004e656e     	subeq	r6, lr, lr, ror #10
  107154: 004e6590     	umaaleq	r6, lr, r0, r5
  107158: 004e6593     	umaaleq	r6, lr, r3, r5
  10715c: 004d8fe4     	subeq	r8, sp, r4, ror #31
  107160: 0054dde0     	subseq	sp, r4, r0, ror #27
  107164: 004e638b     	subeq	r6, lr, r11, lsl #7
  107168: 004e638a     	subeq	r6, lr, r10, lsl #7
  10716c: 004e63ac     	subeq	r6, lr, r12, lsr #7
  107170: 004e63ef     	subeq	r6, lr, pc, ror #7
  107174: 004d8ccc     	subeq	r8, sp, r12, asr #25
  107178: 004e63bf     	strheq	r6, [lr], #-63
  10717c: 004e63be     	strheq	r6, [lr], #-62
  107180: 004e63e0     	subeq	r6, lr, r0, ror #7
  107184: 004e6423     	subeq	r6, lr, r3, lsr #8

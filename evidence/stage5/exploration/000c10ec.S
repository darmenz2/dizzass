
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c10ec: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   c10f0: e28db01c     	add	r11, sp, #28
   c10f4: e24ddf83     	sub	sp, sp, #524
   c10f8: e1a0a000     	mov	r10, r0
   c10fc: eb00f3ae     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x3ceb8
   c1100: e1a04000     	mov	r4, r0
   c1104: e3a06000     	mov	r6, #0
   c1108: eb00f3a7     	bl	0xfdfac <.text+0xedeac> @ imm = #0x3ce9c
   c110c: e3500000     	cmp	r0, #0
   c1110: 0a000015     	beq	0xc116c <.text+0xb106c> @ imm = #0x54
   c1114: e3540006     	cmp	r4, #6
   c1118: 03500004     	cmpeq	r0, #4
   c111c: 0a000012     	beq	0xc116c <.text+0xb106c> @ imm = #0x48
   c1120: e59f0820     	ldr	r0, [pc, #0x820]        @ 0xc1948 <.text+0xb1848>
   c1124: e79f0000     	ldr	r0, [pc, r0]
   c1128: e5901000     	ldr	r1, [r0]
   c112c: e2412001     	sub	r2, r1, #1
   c1130: e0010291     	mul	r1, r1, r2
   c1134: e3110001     	tst	r1, #1
   c1138: e5901000     	ldr	r1, [r0]
   c113c: e3a06002     	mov	r6, #2
   c1140: e3540007     	cmp	r4, #7
   c1144: e2412001     	sub	r2, r1, #1
   c1148: 03006001     	movweq	r6, #0x1
   c114c: e0010291     	mul	r1, r1, r2
   c1150: e3110001     	tst	r1, #1
   c1154: 0a000004     	beq	0xc116c <.text+0xb106c> @ imm = #0x10
   c1158: e59f17ec     	ldr	r1, [pc, #0x7ec]        @ 0xc194c <.text+0xb184c>
   c115c: e79f1001     	ldr	r1, [pc, r1]
   c1160: e5911000     	ldr	r1, [r1]
   c1164: e3510009     	cmp	r1, #9
   c1168: cafffff2     	bgt	0xc1138 <.text+0xb1038> @ imm = #-0x38
   c116c: e3a09009     	mov	r9, #9
   c1170: eb00f3ce     	bl	0xfe0b0 <.text+0xedfb0> @ imm = #0x3cf38
   c1174: e3500000     	cmp	r0, #0
   c1178: 1a000004     	bne	0xc1190 <.text+0xb1090> @ imm = #0x10
   c117c: e3a0900b     	mov	r9, #11
   c1180: e3560001     	cmp	r6, #1
   c1184: 0300900a     	movweq	r9, #0xa
   c1188: e3560000     	cmp	r6, #0
   c118c: 03009009     	movweq	r9, #0x9
   c1190: e3a00001     	mov	r0, #1
   c1194: e3a01000     	mov	r1, #0
   c1198: e3a07001     	mov	r7, #1
   c119c: e3a06000     	mov	r6, #0
   c11a0: eb139661     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x4e5984
   c11a4: e59a3018     	ldr	r3, [r10, #0x18]
   c11a8: e28d4038     	add	r4, sp, #56
   c11ac: e59f279c     	ldr	r2, [pc, #0x79c]        @ 0xc1950 <.text+0xb1850>
   c11b0: e3a01040     	mov	r1, #64
   c11b4: e1a00004     	mov	r0, r4
   c11b8: e08f2002     	add	r2, pc, r2
   c11bc: eb1378e5     	bl	0x59f558 <.text+0x58f458> @ imm = #0x4de394
   c11c0: e3a0000f     	mov	r0, #15
   c11c4: e1a01004     	mov	r1, r4
   c11c8: e3a02000     	mov	r2, #0
   c11cc: e3a03000     	mov	r3, #0
   c11d0: e58d6000     	str	r6, [sp]
   c11d4: eb134a47     	bl	0x593af8 <.text+0x5839f8> @ imm = #0x4d291c
   c11d8: e24b0060     	sub	r0, r11, #96
   c11dc: e5ca7318     	strb	r7, [r10, #0x318]
   c11e0: e3801001     	orr	r1, r0, #1
   c11e4: e58d1010     	str	r1, [sp, #0x10]
   c11e8: e24b10b0     	sub	r1, r11, #176
   c11ec: e28a7fbe     	add	r7, r10, #760
   c11f0: e2811018     	add	r1, r1, #24
   c11f4: e58d100c     	str	r1, [sp, #0xc]
   c11f8: e2801008     	add	r1, r0, #8
   c11fc: e58d1018     	str	r1, [sp, #0x18]
   c1200: e3801006     	orr	r1, r0, #6
   c1204: e3800007     	orr	r0, r0, #7
   c1208: e58d001c     	str	r0, [sp, #0x1c]
   c120c: e28a0fae     	add	r0, r10, #696
   c1210: e58d1020     	str	r1, [sp, #0x20]
   c1214: e28a5e2e     	add	r5, r10, #736
   c1218: e58d002c     	str	r0, [sp, #0x2c]
   c121c: e59f8730     	ldr	r8, [pc, #0x730]        @ 0xc1954 <.text+0xb1854>


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d2144: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   d2148: e28db010     	add	r11, sp, #16
   d214c: e5905000     	ldr	r5, [r0]
   d2150: e3550000     	cmp	r5, #0
   d2154: 0a00001d     	beq	0xd21d0 <.text+0xc20d0> @ imm = #0x74
   d2158: e59f6074     	ldr	r6, [pc, #0x74]         @ 0xd21d4 <.text+0xc20d4>
   d215c: e1a04000     	mov	r4, r0
   d2160: e79f6006     	ldr	r6, [pc, r6]
   d2164: e5960000     	ldr	r0, [r6]
   d2168: e59f7068     	ldr	r7, [pc, #0x68]         @ 0xd21d8 <.text+0xc20d8>
   d216c: e2401001     	sub	r1, r0, #1
   d2170: e0000190     	mul	r0, r0, r1
   d2174: e79f7007     	ldr	r7, [pc, r7]
   d2178: e3100001     	tst	r0, #1
   d217c: 0a000002     	beq	0xd218c <.text+0xc208c> @ imm = #0x8
   d2180: e5970000     	ldr	r0, [r7]
   d2184: e3500009     	cmp	r0, #9
   d2188: ca00000b     	bgt	0xd21bc <.text+0xc20bc> @ imm = #0x2c
   d218c: e1a00005     	mov	r0, r5
   d2190: eb1306bd     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4c1af4
   d2194: e3a00000     	mov	r0, #0
   d2198: e5840000     	str	r0, [r4]
   d219c: e5960000     	ldr	r0, [r6]
   d21a0: e2401001     	sub	r1, r0, #1
   d21a4: e0000190     	mul	r0, r0, r1
   d21a8: e3100001     	tst	r0, #1
   d21ac: 0a000007     	beq	0xd21d0 <.text+0xc20d0> @ imm = #0x1c
   d21b0: e5970000     	ldr	r0, [r7]
   d21b4: e3500009     	cmp	r0, #9
   d21b8: da000004     	ble	0xd21d0 <.text+0xc20d0> @ imm = #0x10
   d21bc: e1a00005     	mov	r0, r5
   d21c0: eb1306b1     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4c1ac4
   d21c4: e3a00000     	mov	r0, #0
   d21c8: e5840000     	str	r0, [r4]
   d21cc: eaffffee     	b	0xd218c <.text+0xc208c> @ imm = #-0x48
   d21d0: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
   d21d4: 0050d928     	subseq	sp, r0, r8, lsr #18
   d21d8: 0050c660     	subseq	r12, r0, r0, ror #12

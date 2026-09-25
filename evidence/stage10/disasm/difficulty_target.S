
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   2fe60: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   2fe64: e28db01c     	add	r11, sp, #28
   2fe68: e24dd004     	sub	sp, sp, #4
   2fe6c: ed2d8b02     	vpush	{d8}
   2fe70: e24dd030     	sub	sp, sp, #48
   2fe74: e58d000c     	str	r0, [sp, #0xc]
   2fe78: e3a00000     	mov	r0, #0
   2fe7c: eeb08b40     	vmov.f64	d8, d0
   2fe80: ebffe4ec     	bl	0x29238 <.text+0x19138> @ imm = #-0x6c50
   2fe84: e5900014     	ldr	r0, [r0, #0x14]
   2fe88: eeb58b40     	vcmp.f64	d8, #0
   2fe8c: e5904018     	ldr	r4, [r0, #0x18]
   2fe90: e28d0010     	add	r0, sp, #16
   2fe94: e2808008     	add	r8, r0, #8
   2fe98: eef1fa10     	vmrs	APSR_nzcv, fpscr
   2fe9c: 0a000039     	beq	0x2ff88 <.text+0x1fe88> @ imm = #0xe4
   2fea0: e5940034     	ldr	r0, [r4, #0x34]
   2fea4: e28f1f65     	add	r1, pc, #404
   2fea8: e3500001     	cmp	r0, #1
   2feac: 02811008     	addeq	r1, r1, #8
   2feb0: ed910b00     	vldr	d0, [r1]
   2feb4: ee808b08     	vdiv.f64	d8, d0, d8
   2feb8: ed9f0b64     	vldr	d0, [pc, #400]          @ 0x30050 <.text+0x1ff50>
   2febc: ee280b00     	vmul.f64	d0, d8, d0
   2fec0: ec510b10     	vmov	r0, r1, d0
   2fec4: eb15858f     	bl	0x591508 <.text+0x581408> @ imm = #0x56163c
   2fec8: e1a09000     	mov	r9, r0
   2fecc: e1a0a001     	mov	r10, r1
   2fed0: eb158518     	bl	0x591338 <.text+0x581238> @ imm = #0x561460
   2fed4: ed9f0b5f     	vldr	d0, [pc, #380]          @ 0x30058 <.text+0x1ff58>
   2fed8: ec410b11     	vmov	d1, r0, r1
   2fedc: ee018b00     	vmla.f64	d8, d1, d0
   2fee0: ed9f0b5e     	vldr	d0, [pc, #376]          @ 0x30060 <.text+0x1ff60>
   2fee4: ee280b00     	vmul.f64	d0, d8, d0
   2fee8: ec510b10     	vmov	r0, r1, d0
   2feec: eb158585     	bl	0x591508 <.text+0x581408> @ imm = #0x561614
   2fef0: e1a07000     	mov	r7, r0
   2fef4: e1a04001     	mov	r4, r1
   2fef8: eb15850e     	bl	0x591338 <.text+0x581238> @ imm = #0x561438
   2fefc: ed9f0b59     	vldr	d0, [pc, #356]          @ 0x30068 <.text+0x1ff68>
   2ff00: ec410b11     	vmov	d1, r0, r1
   2ff04: ee018b00     	vmla.f64	d8, d1, d0
   2ff08: ed9f0b58     	vldr	d0, [pc, #352]          @ 0x30070 <.text+0x1ff70>
   2ff0c: ee280b00     	vmul.f64	d0, d8, d0
   2ff10: ec510b10     	vmov	r0, r1, d0
   2ff14: eb15857b     	bl	0x591508 <.text+0x581408> @ imm = #0x5615ec
   2ff18: e1a05000     	mov	r5, r0
   2ff1c: e1a06001     	mov	r6, r1
   2ff20: eb158504     	bl	0x591338 <.text+0x581238> @ imm = #0x561410
   2ff24: ed9f0b53     	vldr	d0, [pc, #332]          @ 0x30078 <.text+0x1ff78>
   2ff28: ec410b11     	vmov	d1, r0, r1
   2ff2c: ee018b00     	vmla.f64	d8, d1, d0
   2ff30: ec510b18     	vmov	r0, r1, d8
   2ff34: eb158573     	bl	0x591508 <.text+0x581408> @ imm = #0x5615cc
   2ff38: e288c00c     	add	r12, r8, #12
   2ff3c: e59f3154     	ldr	r3, [pc, #0x154]        @ 0x30098 <.text+0x1ff98>
   2ff40: e59f2154     	ldr	r2, [pc, #0x154]        @ 0x3009c <.text+0x1ff9c>
   2ff44: e88800e0     	stm	r8, {r5, r6, r7}
   2ff48: e08f3003     	add	r3, pc, r3
   2ff4c: e08f2002     	add	r2, pc, r2
   2ff50: e88c0610     	stm	r12, {r4, r9, r10}
   2ff54: e58d0010     	str	r0, [sp, #0x10]
   2ff58: e3000bb4     	movw	r0, #0xbb4
   2ff5c: e58d0004     	str	r0, [sp, #0x4]
   2ff60: e59d000c     	ldr	r0, [sp, #0xc]
   2ff64: e58d1014     	str	r1, [sp, #0x14]
   2ff68: e28d1010     	add	r1, sp, #16
   2ff6c: e58d2000     	str	r2, [sp]
   2ff70: e3a02020     	mov	r2, #32
   2ff74: ebff8780     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1e200
   2ff78: e24bd028     	sub	sp, r11, #40
   2ff7c: ecbd8b02     	vpop	{d8}
   2ff80: e28dd004     	add	sp, sp, #4
   2ff84: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   2ff88: e59f50f0     	ldr	r5, [pc, #0xf0]         @ 0x30080 <.text+0x1ff80>
   2ff8c: e79f5005     	ldr	r5, [pc, r5]
   2ff90: e5950000     	ldr	r0, [r5]
   2ff94: e59f60e8     	ldr	r6, [pc, #0xe8]         @ 0x30084 <.text+0x1ff84>
   2ff98: e2401001     	sub	r1, r0, #1
   2ff9c: e0000190     	mul	r0, r0, r1
   2ffa0: e79f6006     	ldr	r6, [pc, r6]
   2ffa4: e59f70dc     	ldr	r7, [pc, #0xdc]         @ 0x30088 <.text+0x1ff88>
   2ffa8: e08f7007     	add	r7, pc, r7
   2ffac: e3100001     	tst	r0, #1
   2ffb0: 0a000002     	beq	0x2ffc0 <.text+0x1fec0> @ imm = #0x8
   2ffb4: e5960000     	ldr	r0, [r6]
   2ffb8: e3500009     	cmp	r0, #9
   2ffbc: ca000012     	bgt	0x3000c <.text+0x1ff0c> @ imm = #0x48
   2ffc0: e59f00c4     	ldr	r0, [pc, #0xc4]         @ 0x3008c <.text+0x1ff8c>
   2ffc4: e3a03001     	mov	r3, #1
   2ffc8: e59f10c0     	ldr	r1, [pc, #0xc0]         @ 0x30090 <.text+0x1ff90>
   2ffcc: e59f20c0     	ldr	r2, [pc, #0xc0]         @ 0x30094 <.text+0x1ff94>
   2ffd0: e08f0000     	add	r0, pc, r0
   2ffd4: e08f1001     	add	r1, pc, r1
   2ffd8: e88d0088     	stm	sp, {r3, r7}
   2ffdc: e08f2002     	add	r2, pc, r2
   2ffe0: e3003b8d     	movw	r3, #0xb8d
   2ffe4: eb032836     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xca0d8
   2ffe8: e5950000     	ldr	r0, [r5]
   2ffec: ed9f8b11     	vldr	d8, [pc, #68]           @ 0x30038 <.text+0x1ff38>
   2fff0: e2401001     	sub	r1, r0, #1
   2fff4: e0000190     	mul	r0, r0, r1
   2fff8: e3100001     	tst	r0, #1
   2fffc: 0affffa7     	beq	0x2fea0 <.text+0x1fda0> @ imm = #-0x164
   30000: e5960000     	ldr	r0, [r6]
   30004: e3500009     	cmp	r0, #9
   30008: daffffa4     	ble	0x2fea0 <.text+0x1fda0> @ imm = #-0x170
   3000c: e59f008c     	ldr	r0, [pc, #0x8c]         @ 0x300a0 <.text+0x1ffa0>
   30010: e3a03001     	mov	r3, #1
   30014: e59f1088     	ldr	r1, [pc, #0x88]         @ 0x300a4 <.text+0x1ffa4>
   30018: e59f2088     	ldr	r2, [pc, #0x88]         @ 0x300a8 <.text+0x1ffa8>
   3001c: e08f0000     	add	r0, pc, r0
   30020: e08f1001     	add	r1, pc, r1
   30024: e88d0088     	stm	sp, {r3, r7}
   30028: e08f2002     	add	r2, pc, r2
   3002c: e3003b8d     	movw	r3, #0xb8d
   30030: eb032823     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xca08c
   30034: eaffffe1     	b	0x2ffc0 <.text+0x1fec0> @ imm = #-0x7c
   30038: 00000000     	andeq	r0, r0, r0
   3003c: 3ff00000     	svclo	#0xf00000
   30040: 00000000     	andeq	r0, r0, r0
   30044: 4defffe0     	stclmi	p15, c15, [pc, #896]!
   30048: 00000000     	andeq	r0, r0, r0
   3004c: 4eefffe0     	cdpmi	p15, #0xe, c15, c15, c0, #0x7
   30050: 00000000     	andeq	r0, r0, r0
   30054: 33f00000     	mvnslo	r0, #0
   30058: 00000000     	andeq	r0, r0, r0
   3005c: cbf00000     	blgt	0xffc30064              @ imm = #-0x400000
   30060: 00000000     	andeq	r0, r0, r0
   30064: 37f00000     	ldrblo	r0, [r0, r0]!
   30068: 00000000     	andeq	r0, r0, r0
   3006c: c7f00000     	ldrbgt	r0, [r0, r0]!
   30070: 00000000     	andeq	r0, r0, r0
   30074: 3bf00000     	bllo	0xffc3007c              @ imm = #-0x400000
   30078: 00000000     	andeq	r0, r0, r0
   3007c: c3f00000     	mvnsgt	r0, #0
   30080: 005af508     	subseq	pc, r10, r8, lsl #10
   30084: 005aea78     	subseq	lr, r10, r8, ror r10
   30088: 005b242f     	subseq	r2, r11, pc, lsr #8
   3008c: 005b21e7     	subseq	r2, r11, r7, ror #3
   30090: 005b21b8     	ldrheq	r2, [r11], #-24
   30094: 005b21e1     	subseq	r2, r11, r1, ror #3
   30098: 005b2244     	subseq	r2, r11, r4, asr #4
   3009c: 005b2262     	subseq	r2, r11, r2, ror #4
   300a0: 005b219b     	<unknown>
   300a4: 005b216c     	subseq	r2, r11, r12, ror #2
   300a8: 005b2195     	<unknown>

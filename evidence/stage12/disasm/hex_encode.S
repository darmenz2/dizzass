
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   1068c: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   10690: e28db010     	add	r11, sp, #16
   10694: e59f6108     	ldr	r6, [pc, #0x108]        @ 0x107a4 <.text+0x6a4>
   10698: e1a05000     	mov	r5, r0
   1069c: e1a04001     	mov	r4, r1
   106a0: e79f6006     	ldr	r6, [pc, r6]
   106a4: e5960000     	ldr	r0, [r6]
   106a8: e59f70f8     	ldr	r7, [pc, #0xf8]         @ 0x107a8 <.text+0x6a8>
   106ac: e2401001     	sub	r1, r0, #1
   106b0: e0000190     	mul	r0, r0, r1
   106b4: e79f7007     	ldr	r7, [pc, r7]
   106b8: e3100001     	tst	r0, #1
   106bc: 0a000002     	beq	0x106cc <.text+0x5cc>   @ imm = #0x8
   106c0: e5970000     	ldr	r0, [r7]
   106c4: e3500009     	cmp	r0, #9
   106c8: ca00000f     	bgt	0x1070c <.text+0x60c>   @ imm = #0x3c
   106cc: e3a00001     	mov	r0, #1
   106d0: e1800084     	orr	r0, r0, r4, lsl #1
   106d4: e1a01fc0     	asr	r1, r0, #31
   106d8: e0800f21     	add	r0, r0, r1, lsr #30
   106dc: e3a01001     	mov	r1, #1
   106e0: e3c00003     	bic	r0, r0, #3
   106e4: e2800004     	add	r0, r0, #4
   106e8: eb160d31     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x5834c4
   106ec: e5961000     	ldr	r1, [r6]
   106f0: e2412001     	sub	r2, r1, #1
   106f4: e0010291     	mul	r1, r1, r2
   106f8: e3110001     	tst	r1, #1
   106fc: 0a00000b     	beq	0x10730 <.text+0x630>   @ imm = #0x2c
   10700: e5971000     	ldr	r1, [r7]
   10704: e3510009     	cmp	r1, #9
   10708: da000008     	ble	0x10730 <.text+0x630>   @ imm = #0x20
   1070c: e3a00001     	mov	r0, #1
   10710: e1800084     	orr	r0, r0, r4, lsl #1
   10714: e1a01fc0     	asr	r1, r0, #31
   10718: e0800f21     	add	r0, r0, r1, lsr #30
   1071c: e3a01001     	mov	r1, #1
   10720: e3c00003     	bic	r0, r0, #3
   10724: e2800004     	add	r0, r0, #4
   10728: eb160d21     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x583484
   1072c: eaffffe6     	b	0x106cc <.text+0x5cc>   @ imm = #-0x68
   10730: e3550000     	cmp	r5, #0
   10734: 0a000011     	beq	0x10780 <.text+0x680>   @ imm = #0x44
   10738: e3540001     	cmp	r4, #1
   1073c: e1a01000     	mov	r1, r0
   10740: ba00000c     	blt	0x10778 <.text+0x678>   @ imm = #0x30
   10744: e59f2060     	ldr	r2, [pc, #0x60]         @ 0x107ac <.text+0x6ac>
   10748: e1a01000     	mov	r1, r0
   1074c: e08f2002     	add	r2, pc, r2
   10750: e5d53000     	ldrb	r3, [r5]
   10754: e2544001     	subs	r4, r4, #1
   10758: e7d23223     	ldrb	r3, [r2, r3, lsr #4]
   1075c: e5c13000     	strb	r3, [r1]
   10760: e4d53001     	ldrb	r3, [r5], #1
   10764: e203300f     	and	r3, r3, #15
   10768: e7d23003     	ldrb	r3, [r2, r3]
   1076c: e5c13001     	strb	r3, [r1, #0x1]
   10770: e2811002     	add	r1, r1, #2
   10774: 1afffff5     	bne	0x10750 <.text+0x650>   @ imm = #-0x2c
   10778: e3a02000     	mov	r2, #0
   1077c: e5c12000     	strb	r2, [r1]
   10780: e5961000     	ldr	r1, [r6]
   10784: e2412001     	sub	r2, r1, #1
   10788: e0010291     	mul	r1, r1, r2
   1078c: e3110001     	tst	r1, #1
   10790: 0a000002     	beq	0x107a0 <.text+0x6a0>   @ imm = #0x8
   10794: e5971000     	ldr	r1, [r7]
   10798: e3510009     	cmp	r1, #9
   1079c: cafffff7     	bgt	0x10780 <.text+0x680>   @ imm = #-0x24
   107a0: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fa87c: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   fa880: e28db010     	add	r11, sp, #16
   fa884: e59f60a0     	ldr	r6, [pc, #0xa0]         @ 0xfa92c <.text+0xea82c>
   fa888: e79f6006     	ldr	r6, [pc, r6]
   fa88c: e5960000     	ldr	r0, [r6]
   fa890: e59f7098     	ldr	r7, [pc, #0x98]         @ 0xfa930 <.text+0xea830>
   fa894: e2401001     	sub	r1, r0, #1
   fa898: e0000190     	mul	r0, r0, r1
   fa89c: e79f7007     	ldr	r7, [pc, r7]
   fa8a0: e3100001     	tst	r0, #1
   fa8a4: 0a000002     	beq	0xfa8b4 <.text+0xea7b4> @ imm = #0x8
   fa8a8: e5970000     	ldr	r0, [r7]
   fa8ac: e3500009     	cmp	r0, #9
   fa8b0: ca000011     	bgt	0xfa8fc <.text+0xea7fc> @ imm = #0x44
   fa8b4: e59f5078     	ldr	r5, [pc, #0x78]         @ 0xfa934 <.text+0xea834>
   fa8b8: e08f5005     	add	r5, pc, r5
   fa8bc: e1a00005     	mov	r0, r5
   fa8c0: eb12ae10     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4ab840
   fa8c4: e59f006c     	ldr	r0, [pc, #0x6c]         @ 0xfa938 <.text+0xea838>
   fa8c8: e08f0000     	add	r0, pc, r0
   fa8cc: ebff5cb7     	bl	0xd1bb0 <.text+0xc1ab0> @ imm = #-0x28d24
   fa8d0: e1a04000     	mov	r4, r0
   fa8d4: e1a00005     	mov	r0, r5
   fa8d8: eb12af79     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4abde4
   fa8dc: e5960000     	ldr	r0, [r6]
   fa8e0: e2401001     	sub	r1, r0, #1
   fa8e4: e0000190     	mul	r0, r0, r1
   fa8e8: e3100001     	tst	r0, #1
   fa8ec: 0a00000c     	beq	0xfa924 <.text+0xea824> @ imm = #0x30
   fa8f0: e5970000     	ldr	r0, [r7]
   fa8f4: e3500009     	cmp	r0, #9
   fa8f8: da000009     	ble	0xfa924 <.text+0xea824> @ imm = #0x24
   fa8fc: e59f4038     	ldr	r4, [pc, #0x38]         @ 0xfa93c <.text+0xea83c>
   fa900: e08f4004     	add	r4, pc, r4
   fa904: e1a00004     	mov	r0, r4
   fa908: eb12adfe     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4ab7f8
   fa90c: e59f002c     	ldr	r0, [pc, #0x2c]         @ 0xfa940 <.text+0xea840>
   fa910: e08f0000     	add	r0, pc, r0
   fa914: ebff5ca5     	bl	0xd1bb0 <.text+0xc1ab0> @ imm = #-0x28d6c
   fa918: e1a00004     	mov	r0, r4
   fa91c: eb12af68     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4abda0
   fa920: eaffffe3     	b	0xfa8b4 <.text+0xea7b4> @ imm = #-0x74
   fa924: e1a00004     	mov	r0, r4
   fa928: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
   fa92c: 004e4b48     	subeq	r4, lr, r8, asr #22
   fa930: 004e5194     	umaaleq	r5, lr, r4, r1
   fa934: 0055a210     	subseq	r10, r5, r0, lsl r2
   fa938: 0055a218     	subseq	r10, r5, r8, lsl r2
   fa93c: 0055a1c8     	subseq	r10, r5, r8, asr #3
   fa940: 0055a1d0     	ldrsbeq	r10, [r5], #-16

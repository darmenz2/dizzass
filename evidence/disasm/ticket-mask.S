
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   eb750: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   eb754: e28db018     	add	r11, sp, #24
   eb758: e24dd010     	sub	sp, sp, #16
   eb75c: e1a04000     	mov	r4, r0
   eb760: e6ef0071     	uxtb	r0, r1
   eb764: e1a033a0     	lsr	r3, r0, #7
   eb768: e2017002     	and	r7, r1, #2
   eb76c: e1833381     	orr	r3, r3, r1, lsl #7
   eb770: e3a02008     	mov	r2, #8
   eb774: e1833287     	orr	r3, r3, r7, lsl #5
   eb778: e2017004     	and	r7, r1, #4
   eb77c: e2011008     	and	r1, r1, #8
   eb780: e00220a0     	and	r2, r2, r0, lsr #1
   eb784: e1833187     	orr	r3, r3, r7, lsl #3
   eb788: e3a05000     	mov	r5, #0
   eb78c: e1831081     	orr	r1, r3, r1, lsl #1
   eb790: e3a03014     	mov	r3, #20
   eb794: e1811002     	orr	r1, r1, r2
   eb798: e3a02004     	mov	r2, #4
   eb79c: e00221a0     	and	r2, r2, r0, lsr #3
   eb7a0: e1811002     	orr	r1, r1, r2
   eb7a4: e3a02002     	mov	r2, #2
   eb7a8: e00202a0     	and	r0, r2, r0, lsr #5
   eb7ac: e3a02000     	mov	r2, #0
   eb7b0: e1810000     	orr	r0, r1, r0
   eb7b4: e3a01001     	mov	r1, #1
   eb7b8: e6ef0070     	uxtb	r0, r0
   eb7bc: e58d0000     	str	r0, [sp]
   eb7c0: e1a00004     	mov	r0, r4
   eb7c4: eb000c46     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x3118
   eb7c8: e3500000     	cmp	r0, #0
   eb7cc: 0a000031     	beq	0xeb898 <.text+0xdb798> @ imm = #0xc4
   eb7d0: e59f80cc     	ldr	r8, [pc, #0xcc]         @ 0xeb8a4 <.text+0xdb7a4>
   eb7d4: e79f8008     	ldr	r8, [pc, r8]
   eb7d8: e5980000     	ldr	r0, [r8]
   eb7dc: e59f70c4     	ldr	r7, [pc, #0xc4]         @ 0xeb8a8 <.text+0xdb7a8>
   eb7e0: e2401001     	sub	r1, r0, #1
   eb7e4: e0000190     	mul	r0, r0, r1
   eb7e8: e79f7007     	ldr	r7, [pc, r7]
   eb7ec: e59f60b8     	ldr	r6, [pc, #0xb8]         @ 0xeb8ac <.text+0xdb7ac>
   eb7f0: e08f6006     	add	r6, pc, r6
   eb7f4: e3100001     	tst	r0, #1
   eb7f8: 0a000002     	beq	0xeb808 <.text+0xdb708> @ imm = #0x8
   eb7fc: e5970000     	ldr	r0, [r7]
   eb800: e3500009     	cmp	r0, #9
   eb804: ca000015     	bgt	0xeb860 <.text+0xdb760> @ imm = #0x54
   eb808: e59f00a0     	ldr	r0, [pc, #0xa0]         @ 0xeb8b0 <.text+0xdb7b0>
   eb80c: e3a05001     	mov	r5, #1
   eb810: e59f109c     	ldr	r1, [pc, #0x9c]         @ 0xeb8b4 <.text+0xdb7b4>
   eb814: e59f209c     	ldr	r2, [pc, #0x9c]         @ 0xeb8b8 <.text+0xdb7b8>
   eb818: e08f0000     	add	r0, pc, r0
   eb81c: e5943018     	ldr	r3, [r4, #0x18]
   eb820: e08f1001     	add	r1, pc, r1
   eb824: e08f2002     	add	r2, pc, r2
   eb828: e88d0060     	stm	sp, {r5, r6}
   eb82c: e2833001     	add	r3, r3, #1
   eb830: e58d3008     	str	r3, [sp, #0x8]
   eb834: e300340c     	movw	r3, #0x40c
   eb838: eb003a21     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xe884
   eb83c: e5980000     	ldr	r0, [r8]
   eb840: e3e05000     	mvn	r5, #0
   eb844: e2401001     	sub	r1, r0, #1
   eb848: e0000190     	mul	r0, r0, r1
   eb84c: e3100001     	tst	r0, #1
   eb850: 0a000010     	beq	0xeb898 <.text+0xdb798> @ imm = #0x40
   eb854: e5970000     	ldr	r0, [r7]
   eb858: e3500009     	cmp	r0, #9
   eb85c: da00000d     	ble	0xeb898 <.text+0xdb798> @ imm = #0x34
   eb860: e59f0054     	ldr	r0, [pc, #0x54]         @ 0xeb8bc <.text+0xdb7bc>
   eb864: e3a05001     	mov	r5, #1
   eb868: e59f1050     	ldr	r1, [pc, #0x50]         @ 0xeb8c0 <.text+0xdb7c0>
   eb86c: e59f2050     	ldr	r2, [pc, #0x50]         @ 0xeb8c4 <.text+0xdb7c4>
   eb870: e08f0000     	add	r0, pc, r0
   eb874: e5943018     	ldr	r3, [r4, #0x18]
   eb878: e08f1001     	add	r1, pc, r1
   eb87c: e08f2002     	add	r2, pc, r2
   eb880: e88d0060     	stm	sp, {r5, r6}
   eb884: e2833001     	add	r3, r3, #1
   eb888: e58d3008     	str	r3, [sp, #0x8]
   eb88c: e300340c     	movw	r3, #0x40c
   eb890: eb003a0b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xe82c
   eb894: eaffffdb     	b	0xeb808 <.text+0xdb708> @ imm = #-0x94
   eb898: e1a00005     	mov	r0, r5
   eb89c: e24bd018     	sub	sp, r11, #24
   eb8a0: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   eb8a4: 004f3ad4     	ldrdeq	r3, r4, [pc], #-164
   eb8a8: 004f3e10     	subeq	r3, pc, r0, lsl lr
   eb8ac: 00500b02     	subseq	r0, r0, r2, lsl #22
   eb8b0: 005006c0     	subseq	r0, r0, r0, asr #13
   eb8b4: 005006bf     	ldrheq	r0, [r0], #-111
   eb8b8: 005006e5     	subseq	r0, r0, r5, ror #13
   eb8bc: 00500668     	subseq	r0, r0, r8, ror #12
   eb8c0: 00500667     	subseq	r0, r0, r7, ror #12
   eb8c4: 0050068d     	subseq	r0, r0, sp, lsl #13

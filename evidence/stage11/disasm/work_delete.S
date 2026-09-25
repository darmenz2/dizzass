
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   2a330: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   2a334: e28db018     	add	r11, sp, #24
   2a338: e24dd018     	sub	sp, sp, #24
   2a33c: e59f815c     	ldr	r8, [pc, #0x15c]        @ 0x2a4a0 <.text+0x1a3a0>
   2a340: e1a04000     	mov	r4, r0
   2a344: e79f8008     	ldr	r8, [pc, r8]
   2a348: e5980000     	ldr	r0, [r8]
   2a34c: e2407001     	sub	r7, r0, #1
   2a350: e0000790     	mul	r0, r0, r7
   2a354: e3100001     	tst	r0, #1
   2a358: e5980000     	ldr	r0, [r8]
   2a35c: e2407001     	sub	r7, r0, #1
   2a360: e0000790     	mul	r0, r0, r7
   2a364: e59f7138     	ldr	r7, [pc, #0x138]        @ 0x2a4a4 <.text+0x1a3a4>
   2a368: e79f7007     	ldr	r7, [pc, r7]
   2a36c: e5945000     	ldr	r5, [r4]
   2a370: e3100001     	tst	r0, #1
   2a374: 0a000002     	beq	0x2a384 <.text+0x1a284> @ imm = #0x8
   2a378: e5970000     	ldr	r0, [r7]
   2a37c: e3500009     	cmp	r0, #9
   2a380: cafffff4     	bgt	0x2a358 <.text+0x1a258> @ imm = #-0x30
   2a384: e3550000     	cmp	r5, #0
   2a388: 0a000017     	beq	0x2a3ec <.text+0x1a2ec> @ imm = #0x5c
   2a38c: e595018c     	ldr	r0, [r5, #0x18c]
   2a390: e3500000     	cmp	r0, #0
   2a394: 0a000002     	beq	0x2a3a4 <.text+0x1a2a4> @ imm = #0x8
   2a398: eb15a63b     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x5698ec
   2a39c: e3a00000     	mov	r0, #0
   2a3a0: e585018c     	str	r0, [r5, #0x18c]
   2a3a4: e595019c     	ldr	r0, [r5, #0x19c]
   2a3a8: e3500000     	cmp	r0, #0
   2a3ac: 0a000002     	beq	0x2a3bc <.text+0x1a2bc> @ imm = #0x8
   2a3b0: eb15a635     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x5698d4
   2a3b4: e3a00000     	mov	r0, #0
   2a3b8: e585019c     	str	r0, [r5, #0x19c]
   2a3bc: e59561b0     	ldr	r6, [r5, #0x1b0]
   2a3c0: e3560000     	cmp	r6, #0
   2a3c4: 0a00002b     	beq	0x2a478 <.text+0x1a378> @ imm = #0xac
   2a3c8: e5980000     	ldr	r0, [r8]
   2a3cc: e2401001     	sub	r1, r0, #1
   2a3d0: e0000190     	mul	r0, r0, r1
   2a3d4: e3100001     	tst	r0, #1
   2a3d8: 0a000015     	beq	0x2a434 <.text+0x1a334> @ imm = #0x54
   2a3dc: e5970000     	ldr	r0, [r7]
   2a3e0: e3500009     	cmp	r0, #9
   2a3e4: ca00001e     	bgt	0x2a464 <.text+0x1a364> @ imm = #0x78
   2a3e8: ea000011     	b	0x2a434 <.text+0x1a334> @ imm = #0x44
   2a3ec: e59f00b4     	ldr	r0, [pc, #0xb4]         @ 0x2a4a8 <.text+0x1a3a8>
   2a3f0: e3a04001     	mov	r4, #1
   2a3f4: e59f60b0     	ldr	r6, [pc, #0xb0]         @ 0x2a4ac <.text+0x1a3ac>
   2a3f8: e28dc008     	add	r12, sp, #8
   2a3fc: e59f50ac     	ldr	r5, [pc, #0xac]         @ 0x2a4b0 <.text+0x1a3b0>
   2a400: e08f0000     	add	r0, pc, r0
   2a404: e59f70a8     	ldr	r7, [pc, #0xa8]         @ 0x2a4b4 <.text+0x1a3b4>
   2a408: e08f6006     	add	r6, pc, r6
   2a40c: e08f5005     	add	r5, pc, r5
   2a410: e08f7007     	add	r7, pc, r7
   2a414: e88d0090     	stm	sp, {r4, r7}
   2a418: e88c000e     	stm	r12, {r1, r2, r3}
   2a41c: e1a01006     	mov	r1, r6
   2a420: e1a02005     	mov	r2, r5
   2a424: e300317d     	movw	r3, #0x17d
   2a428: eb033f25     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xcfc94
   2a42c: e24bd018     	sub	sp, r11, #24
   2a430: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   2a434: e1a00006     	mov	r0, r6
   2a438: eb15a613     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x56984c
   2a43c: e3a00000     	mov	r0, #0
   2a440: e58501b0     	str	r0, [r5, #0x1b0]
   2a444: e5980000     	ldr	r0, [r8]
   2a448: e2401001     	sub	r1, r0, #1
   2a44c: e0000190     	mul	r0, r0, r1
   2a450: e3100001     	tst	r0, #1
   2a454: 0a000007     	beq	0x2a478 <.text+0x1a378> @ imm = #0x1c
   2a458: e5970000     	ldr	r0, [r7]
   2a45c: e3500009     	cmp	r0, #9
   2a460: da000004     	ble	0x2a478 <.text+0x1a378> @ imm = #0x10
   2a464: e1a00006     	mov	r0, r6
   2a468: eb15a607     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x56981c
   2a46c: e3a00000     	mov	r0, #0
   2a470: e58501b0     	str	r0, [r5, #0x1b0]
   2a474: eaffffee     	b	0x2a434 <.text+0x1a334> @ imm = #-0x48
   2a478: e59501a8     	ldr	r0, [r5, #0x1a8]
   2a47c: e3500000     	cmp	r0, #0
   2a480: 0a000000     	beq	0x2a488 <.text+0x1a388> @ imm = #0x0
   2a484: eb15a600     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x569800
   2a488: e1a00005     	mov	r0, r5
   2a48c: eb15a5fe     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x5697f8
   2a490: e3a00000     	mov	r0, #0
   2a494: e5840000     	str	r0, [r4]
   2a498: e24bd018     	sub	sp, r11, #24
   2a49c: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  1082b4: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
  1082b8: e28db010     	add	r11, sp, #16
  1082bc: e59f00fc     	ldr	r0, [pc, #0xfc]         @ 0x1083c0 <.text+0xf82c0>
  1082c0: e3a05000     	mov	r5, #0
  1082c4: e08f0000     	add	r0, pc, r0
  1082c8: e5c05000     	strb	r5, [r0]
  1082cc: e59f40f0     	ldr	r4, [pc, #0xf0]         @ 0x1083c4 <.text+0xf82c4>
  1082d0: e79f4004     	ldr	r4, [pc, r4]
  1082d4: e59f10ec     	ldr	r1, [pc, #0xec]         @ 0x1083c8 <.text+0xf82c8>
  1082d8: e79f1001     	ldr	r1, [pc, r1]
  1082dc: e3510001     	cmp	r1, #1
  1082e0: ba000010     	blt	0x108328 <.text+0xf8228> @ imm = #0x40
  1082e4: e3a06c02     	mov	r6, #512
  1082e8: e3a07000     	mov	r7, #0
  1082ec: ea000003     	b	0x108300 <.text+0xf8200> @ imm = #0xc
  1082f0: e2877001     	add	r7, r7, #1
  1082f4: e2866f82     	add	r6, r6, #520
  1082f8: e1570001     	cmp	r7, r1
  1082fc: aa000009     	bge	0x108328 <.text+0xf8228> @ imm = #0x24
  108300: e7940006     	ldr	r0, [r4, r6]
  108304: e3500000     	cmp	r0, #0
  108308: 0afffff8     	beq	0x1082f0 <.text+0xf81f0> @ imm = #-0x20
  10830c: eb122e5e     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x48b978
  108310: e7845006     	str	r5, [r4, r6]
  108314: e59f40b0     	ldr	r4, [pc, #0xb0]         @ 0x1083cc <.text+0xf82cc>
  108318: e79f4004     	ldr	r4, [pc, r4]
  10831c: e59f10ac     	ldr	r1, [pc, #0xac]         @ 0x1083d0 <.text+0xf82d0>
  108320: e79f1001     	ldr	r1, [pc, r1]
  108324: eafffff1     	b	0x1082f0 <.text+0xf81f0> @ imm = #-0x3c
  108328: e59f50a4     	ldr	r5, [pc, #0xa4]         @ 0x1083d4 <.text+0xf82d4>
  10832c: e3540000     	cmp	r4, #0
  108330: e08f5005     	add	r5, pc, r5
  108334: 0a000003     	beq	0x108348 <.text+0xf8248> @ imm = #0xc
  108338: e1a00004     	mov	r0, r4
  10833c: eb122e52     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x48b948
  108340: e3a00000     	mov	r0, #0
  108344: e5850000     	str	r0, [r5]
  108348: e59f0088     	ldr	r0, [pc, #0x88]         @ 0x1083d8 <.text+0xf82d8>
  10834c: e79f0000     	ldr	r0, [pc, r0]
  108350: e5901000     	ldr	r1, [r0]
  108354: e2412001     	sub	r2, r1, #1
  108358: e0020291     	mul	r2, r1, r2
  10835c: e59f1078     	ldr	r1, [pc, #0x78]         @ 0x1083dc <.text+0xf82dc>
  108360: e79f1001     	ldr	r1, [pc, r1]
  108364: e3120001     	tst	r2, #1
  108368: e59f2070     	ldr	r2, [pc, #0x70]         @ 0x1083e0 <.text+0xf82e0>
  10836c: e08f2002     	add	r2, pc, r2
  108370: 0a000002     	beq	0x108380 <.text+0xf8280> @ imm = #0x8
  108374: e5913000     	ldr	r3, [r1]
  108378: e3530009     	cmp	r3, #9
  10837c: ca00000a     	bgt	0x1083ac <.text+0xf82ac> @ imm = #0x28
  108380: e5903000     	ldr	r3, [r0]
  108384: e3a06000     	mov	r6, #0
  108388: e5856000     	str	r6, [r5]
  10838c: e2437001     	sub	r7, r3, #1
  108390: e5826000     	str	r6, [r2]
  108394: e0070793     	mul	r7, r3, r7
  108398: e5913000     	ldr	r3, [r1]
  10839c: e3170001     	tst	r7, #1
  1083a0: 0a000005     	beq	0x1083bc <.text+0xf82bc> @ imm = #0x14
  1083a4: e3530009     	cmp	r3, #9
  1083a8: da000003     	ble	0x1083bc <.text+0xf82bc> @ imm = #0xc
  1083ac: e3a03000     	mov	r3, #0
  1083b0: e5853000     	str	r3, [r5]
  1083b4: e5823000     	str	r3, [r2]
  1083b8: eafffff0     	b	0x108380 <.text+0xf8280> @ imm = #-0x40
  1083bc: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  1083c0: 0054caa4     	subseq	r12, r4, r4, lsr #21
  1083c4: 0054ca90     	<unknown>
  1083c8: 0054ca8c     	subseq	r12, r4, r12, lsl #21
  1083cc: 0054ca48     	subseq	r12, r4, r8, asr #20
  1083d0: 0054ca44     	subseq	r12, r4, r4, asr #20
  1083d4: 0054ca30     	subseq	r12, r4, r0, lsr r10
  1083d8: 004d63fc     	strdeq	r6, r7, [sp], #-60
  1083dc: 004d779c     	umaaleq	r7, sp, r12, r7
  1083e0: 0054c9f8     	ldrsheq	r12, [r4], #-152

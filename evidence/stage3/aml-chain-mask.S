
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  118180: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
  118184: e28db010     	add	r11, sp, #16
  118188: e1a06001     	mov	r6, r1
  11818c: e1a04000     	mov	r4, r0
  118190: e3a05001     	mov	r5, #1
  118194: ebff978c     	bl	0xfdfcc <.text+0xedecc> @ imm = #-0x1a1d0
  118198: e3011489     	movw	r1, #0x1489
  11819c: e1500001     	cmp	r0, r1
  1181a0: 0a000031     	beq	0x11826c <.text+0x10816c> @ imm = #0xc4
  1181a4: e3560000     	cmp	r6, #0
  1181a8: 0a000003     	beq	0x1181bc <.text+0x1080bc> @ imm = #0xc
  1181ac: e3a00001     	mov	r0, #1
  1181b0: e1a05410     	lsl	r5, r0, r4
  1181b4: e1a00005     	mov	r0, r5
  1181b8: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
  1181bc: e59f10b0     	ldr	r1, [pc, #0xb0]         @ 0x118274 <.text+0x108174>
  1181c0: e79f1001     	ldr	r1, [pc, r1]
  1181c4: e5912000     	ldr	r2, [r1]
  1181c8: e2423001     	sub	r3, r2, #1
  1181cc: e0020392     	mul	r2, r2, r3
  1181d0: e3120001     	tst	r2, #1
  1181d4: e5916000     	ldr	r6, [r1]
  1181d8: e3a03000     	mov	r3, #0
  1181dc: e59f2094     	ldr	r2, [pc, #0x94]         @ 0x118278 <.text+0x108178>
  1181e0: e3540002     	cmp	r4, #2
  1181e4: e2465001     	sub	r5, r6, #1
  1181e8: c3003001     	movwgt	r3, #0x1
  1181ec: e0060596     	mul	r6, r6, r5
  1181f0: e79f2002     	ldr	r2, [pc, r2]
  1181f4: e3160001     	tst	r6, #1
  1181f8: 0a000002     	beq	0x118208 <.text+0x108108> @ imm = #0x8
  1181fc: e5926000     	ldr	r6, [r2]
  118200: e3560009     	cmp	r6, #9
  118204: cafffff2     	bgt	0x1181d4 <.text+0x1080d4> @ imm = #-0x38
  118208: e3016398     	movw	r6, #0x1398
  11820c: e0400006     	sub	r0, r0, r6
  118210: e16f0f10     	clz	r0, r0
  118214: e3a05008     	mov	r5, #8
  118218: e1a002a0     	lsr	r0, r0, #5
  11821c: e0130000     	ands	r0, r3, r0
  118220: 1a000011     	bne	0x11826c <.text+0x10816c> @ imm = #0x44
  118224: e3a05004     	mov	r5, #4
  118228: e3540001     	cmp	r4, #1
  11822c: ca00000e     	bgt	0x11826c <.text+0x10816c> @ imm = #0x38
  118230: e5910000     	ldr	r0, [r1]
  118234: e2403001     	sub	r3, r0, #1
  118238: e0000390     	mul	r0, r0, r3
  11823c: e3100001     	tst	r0, #1
  118240: e5910000     	ldr	r0, [r1]
  118244: e3a05001     	mov	r5, #1
  118248: e3540001     	cmp	r4, #1
  11824c: e2403001     	sub	r3, r0, #1
  118250: 03005002     	movweq	r5, #0x2
  118254: e0000390     	mul	r0, r0, r3
  118258: e3100001     	tst	r0, #1
  11825c: 0a000002     	beq	0x11826c <.text+0x10816c> @ imm = #0x8
  118260: e5920000     	ldr	r0, [r2]
  118264: e3500009     	cmp	r0, #9
  118268: cafffff4     	bgt	0x118240 <.text+0x108140> @ imm = #-0x30
  11826c: e1a00005     	mov	r0, r5
  118270: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
  118274: 004c6484     	subeq	r6, r12, r4, lsl #9
  118278: 004c6b88     	subeq	r6, r12, r8, lsl #23

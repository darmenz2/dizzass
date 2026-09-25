
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  109170: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  109174: e28db01c     	add	r11, sp, #28
  109178: e24dd004     	sub	sp, sp, #4
  10917c: e59f4204     	ldr	r4, [pc, #0x204]        @ 0x109388 <.text+0xf9288>
  109180: e1a05000     	mov	r5, r0
  109184: e1a06001     	mov	r6, r1
  109188: e1a08002     	mov	r8, r2
  10918c: e79f4004     	ldr	r4, [pc, r4]
  109190: e5940000     	ldr	r0, [r4]
  109194: e59f91f0     	ldr	r9, [pc, #0x1f0]        @ 0x10938c <.text+0xf928c>
  109198: e2401001     	sub	r1, r0, #1
  10919c: e0000190     	mul	r0, r0, r1
  1091a0: e79f9009     	ldr	r9, [pc, r9]
  1091a4: e3100001     	tst	r0, #1
  1091a8: 0a000002     	beq	0x1091b8 <.text+0xf90b8> @ imm = #0x8
  1091ac: e5990000     	ldr	r0, [r9]
  1091b0: e3500009     	cmp	r0, #9
  1091b4: ca000012     	bgt	0x109204 <.text+0xf9104> @ imm = #0x48
  1091b8: e5950004     	ldr	r0, [r5, #0x4]
  1091bc: e1a01006     	mov	r1, r6
  1091c0: e2607040     	rsb	r7, r0, #64
  1091c4: e0850000     	add	r0, r5, r0
  1091c8: e1570008     	cmp	r7, r8
  1091cc: e2800008     	add	r0, r0, #8
  1091d0: 81a07008     	movhi	r7, r8
  1091d4: e1a02007     	mov	r2, r7
  1091d8: eb126742     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x499d08
  1091dc: e5940000     	ldr	r0, [r4]
  1091e0: e2401001     	sub	r1, r0, #1
  1091e4: e0010190     	mul	r1, r0, r1
  1091e8: e5950004     	ldr	r0, [r5, #0x4]
  1091ec: e0800008     	add	r0, r0, r8
  1091f0: e3110001     	tst	r1, #1
  1091f4: 0a00000b     	beq	0x109228 <.text+0xf9128> @ imm = #0x2c
  1091f8: e5991000     	ldr	r1, [r9]
  1091fc: e3510009     	cmp	r1, #9
  109200: da000008     	ble	0x109228 <.text+0xf9128> @ imm = #0x20
  109204: e5950004     	ldr	r0, [r5, #0x4]
  109208: e1a01006     	mov	r1, r6
  10920c: e2602040     	rsb	r2, r0, #64
  109210: e0850000     	add	r0, r5, r0
  109214: e1520008     	cmp	r2, r8
  109218: e2800008     	add	r0, r0, #8
  10921c: 81a02008     	movhi	r2, r8
  109220: eb126730     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x499cc0
  109224: eaffffe3     	b	0x1091b8 <.text+0xf90b8> @ imm = #-0x74
  109228: e350003f     	cmp	r0, #63
  10922c: 8a000001     	bhi	0x109238 <.text+0xf9138> @ imm = #0x4
  109230: e5850004     	str	r0, [r5, #0x4]
  109234: ea000047     	b	0x109358 <.text+0xf9258> @ imm = #0x11c
  109238: e5940000     	ldr	r0, [r4]
  10923c: e58d6000     	str	r6, [sp]
  109240: e2401001     	sub	r1, r0, #1
  109244: e0000190     	mul	r0, r0, r1
  109248: e3100001     	tst	r0, #1
  10924c: 0a000004     	beq	0x109264 <.text+0xf9164> @ imm = #0x10
  109250: e59f0138     	ldr	r0, [pc, #0x138]        @ 0x109390 <.text+0xf9290>
  109254: e79f0000     	ldr	r0, [pc, r0]
  109258: e5900000     	ldr	r0, [r0]
  10925c: e3500009     	cmp	r0, #9
  109260: ca000021     	bgt	0x1092ec <.text+0xf91ec> @ imm = #0x84
  109264: e2859008     	add	r9, r5, #8
  109268: e1a00005     	mov	r0, r5
  10926c: e3a02001     	mov	r2, #1
  109270: e1a01009     	mov	r1, r9
  109274: ebfffe40     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x700
  109278: e0866007     	add	r6, r6, r7
  10927c: e048a007     	sub	r10, r8, r7
  109280: e1a00005     	mov	r0, r5
  109284: e1a0232a     	lsr	r2, r10, #6
  109288: e1a01006     	mov	r1, r6
  10928c: ebfffe3a     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x718
  109290: e3ca003f     	bic	r0, r10, #63
  109294: e0861000     	add	r1, r6, r0
  109298: e20a603f     	and	r6, r10, #63
  10929c: e1a00009     	mov	r0, r9
  1092a0: e1a02006     	mov	r2, r6
  1092a4: eb12670f     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x499c3c
  1092a8: e5856004     	str	r6, [r5, #0x4]
  1092ac: e28a1040     	add	r1, r10, #64
  1092b0: e5950000     	ldr	r0, [r5]
  1092b4: e3c1103f     	bic	r1, r1, #63
  1092b8: e59d6000     	ldr	r6, [sp]
  1092bc: e0800001     	add	r0, r0, r1
  1092c0: e5850000     	str	r0, [r5]
  1092c4: e5940000     	ldr	r0, [r4]
  1092c8: e2401001     	sub	r1, r0, #1
  1092cc: e0000190     	mul	r0, r0, r1
  1092d0: e3100001     	tst	r0, #1
  1092d4: 0a00001f     	beq	0x109358 <.text+0xf9258> @ imm = #0x7c
  1092d8: e59f00b4     	ldr	r0, [pc, #0xb4]         @ 0x109394 <.text+0xf9294>
  1092dc: e79f0000     	ldr	r0, [pc, r0]
  1092e0: e5900000     	ldr	r0, [r0]
  1092e4: e3500009     	cmp	r0, #9
  1092e8: da00001a     	ble	0x109358 <.text+0xf9258> @ imm = #0x68
  1092ec: e2859008     	add	r9, r5, #8
  1092f0: e1a00005     	mov	r0, r5
  1092f4: e3a02001     	mov	r2, #1
  1092f8: e1a01009     	mov	r1, r9
  1092fc: ebfffe1e     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x788
  109300: e0866007     	add	r6, r6, r7
  109304: e1a0a004     	mov	r10, r4
  109308: e0484007     	sub	r4, r8, r7
  10930c: e1a00005     	mov	r0, r5
  109310: e1a01006     	mov	r1, r6
  109314: e1a02324     	lsr	r2, r4, #6
  109318: ebfffe17     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x7a4
  10931c: e3c4003f     	bic	r0, r4, #63
  109320: e0861000     	add	r1, r6, r0
  109324: e204603f     	and	r6, r4, #63
  109328: e1a00009     	mov	r0, r9
  10932c: e1a02006     	mov	r2, r6
  109330: eb1266ec     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x499bb0
  109334: e5856004     	str	r6, [r5, #0x4]
  109338: e2841040     	add	r1, r4, #64
  10933c: e5950000     	ldr	r0, [r5]
  109340: e3c1103f     	bic	r1, r1, #63
  109344: e1a0400a     	mov	r4, r10
  109348: e59d6000     	ldr	r6, [sp]
  10934c: e0800001     	add	r0, r0, r1
  109350: e5850000     	str	r0, [r5]
  109354: eaffffc2     	b	0x109264 <.text+0xf9164> @ imm = #-0xf8
  109358: e59f2038     	ldr	r2, [pc, #0x38]         @ 0x109398 <.text+0xf9298>
  10935c: e79f2002     	ldr	r2, [pc, r2]
  109360: e5940000     	ldr	r0, [r4]
  109364: e2401001     	sub	r1, r0, #1
  109368: e0000190     	mul	r0, r0, r1
  10936c: e3100001     	tst	r0, #1
  109370: 0a000002     	beq	0x109380 <.text+0xf9280> @ imm = #0x8
  109374: e5920000     	ldr	r0, [r2]
  109378: e3500009     	cmp	r0, #9
  10937c: cafffff7     	bgt	0x109360 <.text+0xf9260> @ imm = #-0x24
  109380: e24bd01c     	sub	sp, r11, #28
  109384: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  109388: 004d54b8     	strheq	r5, [sp], #-72
  10938c: 004d5bd8     	ldrdeq	r5, r6, [sp], #-184
  109390: 004d5b24     	subeq	r5, sp, r4, lsr #22
  109394: 004d5a9c     	umaaleq	r5, sp, r12, r10
  109398: 004d5a1c     	subeq	r5, sp, r12, lsl r10

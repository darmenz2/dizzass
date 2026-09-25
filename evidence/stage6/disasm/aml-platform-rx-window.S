
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  11bc00: 004d2ba0     	subeq	r2, sp, r0, lsr #23
  11bc04: 004d2b9f     	umaaleq	r2, sp, pc, r11
  11bc08: 004d2bc4     	subeq	r2, sp, r4, asr #23
  11bc0c: 004d2c54     	subeq	r2, sp, r4, asr r12
  11bc10: 00496e04     	subeq	r6, r9, r4, lsl #28
  11bc14: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
  11bc18: e28db010     	add	r11, sp, #16
  11bc1c: e24dd010     	sub	sp, sp, #16
  11bc20: e59f5114     	ldr	r5, [pc, #0x114]        @ 0x11bd3c <.text+0x10bc3c>
  11bc24: e1a04000     	mov	r4, r0
  11bc28: e79f5005     	ldr	r5, [pc, r5]
  11bc2c: e5950000     	ldr	r0, [r5]
  11bc30: e2402001     	sub	r2, r0, #1
  11bc34: e0000290     	mul	r0, r0, r2
  11bc38: e3100001     	tst	r0, #1
  11bc3c: e5950000     	ldr	r0, [r5]
  11bc40: e59f60f8     	ldr	r6, [pc, #0xf8]         @ 0x11bd40 <.text+0x10bc40>
  11bc44: e2402001     	sub	r2, r0, #1
  11bc48: e0000290     	mul	r0, r0, r2
  11bc4c: e79f6006     	ldr	r6, [pc, r6]
  11bc50: e3100001     	tst	r0, #1
  11bc54: 0a000002     	beq	0x11bc64 <.text+0x10bb64> @ imm = #0x8
  11bc58: e5960000     	ldr	r0, [r6]
  11bc5c: e3500009     	cmp	r0, #9
  11bc60: cafffff5     	bgt	0x11bc3c <.text+0x10bb3c> @ imm = #-0x2c
  11bc64: e3540003     	cmp	r4, #3
  11bc68: 3a00000a     	blo	0x11bc98 <.text+0x10bb98> @ imm = #0x28
  11bc6c: e5950000     	ldr	r0, [r5]
  11bc70: e59f70cc     	ldr	r7, [pc, #0xcc]         @ 0x11bd44 <.text+0x10bc44>
  11bc74: e2401001     	sub	r1, r0, #1
  11bc78: e08f7007     	add	r7, pc, r7
  11bc7c: e0000190     	mul	r0, r0, r1
  11bc80: e3100001     	tst	r0, #1
  11bc84: 0a00000a     	beq	0x11bcb4 <.text+0x10bbb4> @ imm = #0x28
  11bc88: e5960000     	ldr	r0, [r6]
  11bc8c: e3500009     	cmp	r0, #9
  11bc90: ca00001a     	bgt	0x11bd00 <.text+0x10bc00> @ imm = #0x68
  11bc94: ea000006     	b	0x11bcb4 <.text+0x10bbb4> @ imm = #0x18
  11bc98: e59f00c0     	ldr	r0, [pc, #0xc0]         @ 0x11bd60 <.text+0x10bc60>
  11bc9c: e2211001     	eor	r1, r1, #1
  11bca0: e08f0000     	add	r0, pc, r0
  11bca4: e7900104     	ldr	r0, [r0, r4, lsl #2]
  11bca8: e24bd010     	sub	sp, r11, #16
  11bcac: e8bd48f0     	pop	{r4, r5, r6, r7, r11, lr}
  11bcb0: ea0023bb     	b	0x124ba4 <.text+0x114aa4> @ imm = #0x8eec
  11bcb4: e59f008c     	ldr	r0, [pc, #0x8c]         @ 0x11bd48 <.text+0x10bc48>
  11bcb8: e3a03001     	mov	r3, #1
  11bcbc: e59f1088     	ldr	r1, [pc, #0x88]         @ 0x11bd4c <.text+0x10bc4c>
  11bcc0: e59f2088     	ldr	r2, [pc, #0x88]         @ 0x11bd50 <.text+0x10bc50>
  11bcc4: e08f0000     	add	r0, pc, r0
  11bcc8: e08f1001     	add	r1, pc, r1
  11bccc: e88d0088     	stm	sp, {r3, r7}
  11bcd0: e08f2002     	add	r2, pc, r2
  11bcd4: e3a03082     	mov	r3, #130
  11bcd8: e58d4008     	str	r4, [sp, #0x8]
  11bcdc: ebff78f8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x21c20
  11bce0: e5950000     	ldr	r0, [r5]
  11bce4: e2401001     	sub	r1, r0, #1
  11bce8: e0000190     	mul	r0, r0, r1
  11bcec: e3100001     	tst	r0, #1
  11bcf0: 0a00000e     	beq	0x11bd30 <.text+0x10bc30> @ imm = #0x38
  11bcf4: e5960000     	ldr	r0, [r6]
  11bcf8: e350000a     	cmp	r0, #10
  11bcfc: ba00000b     	blt	0x11bd30 <.text+0x10bc30> @ imm = #0x2c
  11bd00: e59f004c     	ldr	r0, [pc, #0x4c]         @ 0x11bd54 <.text+0x10bc54>
  11bd04: e3a03001     	mov	r3, #1
  11bd08: e59f1048     	ldr	r1, [pc, #0x48]         @ 0x11bd58 <.text+0x10bc58>
  11bd0c: e59f2048     	ldr	r2, [pc, #0x48]         @ 0x11bd5c <.text+0x10bc5c>
  11bd10: e08f0000     	add	r0, pc, r0
  11bd14: e08f1001     	add	r1, pc, r1
  11bd18: e88d0088     	stm	sp, {r3, r7}
  11bd1c: e08f2002     	add	r2, pc, r2
  11bd20: e3a03082     	mov	r3, #130
  11bd24: e58d4008     	str	r4, [sp, #0x8]
  11bd28: ebff78e5     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x21c6c
  11bd2c: eaffffe0     	b	0x11bcb4 <.text+0x10bbb4> @ imm = #-0x80
  11bd30: e3e00000     	mvn	r0, #0
  11bd34: e24bd010     	sub	sp, r11, #16
  11bd38: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  11bd3c: 004c397c     	subeq	r3, r12, r12, ror r9
  11bd40: 004c33b4     	strheq	r3, [r12], #-52
  11bd44: 004d2b74     	subeq	r2, sp, r4, ror r11
  11bd48: 004d2a64     	subeq	r2, sp, r4, ror #20
  11bd4c: 004d2a67     	subeq	r2, sp, r7, ror #20
  11bd50: 004d2a88     	subeq	r2, sp, r8, lsl #21
  11bd54: 004d2a18     	subeq	r2, sp, r8, lsl r10
  11bd58: 004d2a1b     	subeq	r2, sp, r11, lsl r10
  11bd5c: 004d2a3c     	subeq	r2, sp, r12, lsr r10
  11bd60: 00496d30     	subeq	r6, r9, r0, lsr sp
  11bd64: e3a00000     	mov	r0, #0
  11bd68: e12fff1e     	bx	lr
  11bd6c: e320f000     	nop
  11bd70: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
  11bd74: e28db010     	add	r11, sp, #16
  11bd78: e1a05001     	mov	r5, r1
  11bd7c: e1a04000     	mov	r4, r0
  11bd80: e59b6010     	ldr	r6, [r11, #0x10]
  11bd84: e59b700c     	ldr	r7, [r11, #0xc]
  11bd88: ebff888b     	bl	0xfdfbc <.text+0xedebc> @ imm = #-0x1ddd4
  11bd8c: e3801001     	orr	r1, r0, #1
  11bd90: e3510005     	cmp	r1, #5
  11bd94: 1a000002     	bne	0x11bda4 <.text+0x10bca4> @ imm = #0x8
  11bd98: ed9f0b6a     	vldr	d0, [pc, #424]          @ 0x11bf48 <.text+0x10be48>
  11bd9c: ed9f1b6b     	vldr	d1, [pc, #428]          @ 0x11bf50 <.text+0x10be50>
  11bda0: ea000034     	b	0x11be78 <.text+0x10bd78> @ imm = #0xd0
  11bda4: e3500002     	cmp	r0, #2
  11bda8: 0a00000e     	beq	0x11bde8 <.text+0x10bce8> @ imm = #0x38
  11bdac: e3500007     	cmp	r0, #7
  11bdb0: 1a00002e     	bne	0x11be70 <.text+0x10bd70> @ imm = #0xb8
  11bdb4: ee004a10     	vmov	s0, r4
  11bdb8: ed9f1b72     	vldr	d1, [pc, #456]          @ 0x11bf88 <.text+0x10be88>
  11bdbc: eeb80bc0     	vcvt.f64.s32	d0, s0
  11bdc0: ee810b00     	vdiv.f64	d0, d1, d0
  11bdc4: ed9f1b71     	vldr	d1, [pc, #452]          @ 0x11bf90 <.text+0x10be90>
  11bdc8: ee200b01     	vmul.f64	d0, d0, d1
  11bdcc: ed9f1b69     	vldr	d1, [pc, #420]          @ 0x11bf78 <.text+0x10be78>
  11bdd0: ee800b01     	vdiv.f64	d0, d0, d1
  11bdd4: ed9f1b6f     	vldr	d1, [pc, #444]          @ 0x11bf98 <.text+0x10be98>
  11bdd8: ee800b01     	vdiv.f64	d0, d0, d1
  11bddc: eebc0bc0     	vcvt.u32.f64	s0, d0
  11bde0: ee102a10     	vmov	r2, s0
  11bde4: ea000051     	b	0x11bf30 <.text+0x10be30> @ imm = #0x144
  11bde8: e59f01b8     	ldr	r0, [pc, #0x1b8]        @ 0x11bfa8 <.text+0x10bea8>
  11bdec: e79f0000     	ldr	r0, [pc, r0]
  11bdf0: e5901000     	ldr	r1, [r0]
  11bdf4: e2412001     	sub	r2, r1, #1
  11bdf8: e0010291     	mul	r1, r1, r2
  11bdfc: e3110001     	tst	r1, #1
  11be00: e0010597     	mul	r1, r7, r5
  11be04: ee004a10     	vmov	s0, r4
  11be08: ed9f1b56     	vldr	d1, [pc, #344]          @ 0x11bf68 <.text+0x10be68>
  11be0c: eeb80bc0     	vcvt.f64.s32	d0, s0
  11be10: e0010691     	mul	r1, r1, r6
  11be14: ee200b01     	vmul.f64	d0, d0, d1
  11be18: ee021a10     	vmov	s4, r1
  11be1c: ed9f1b55     	vldr	d1, [pc, #340]          @ 0x11bf78 <.text+0x10be78>
  11be20: ed9f3b52     	vldr	d3, [pc, #328]          @ 0x11bf70 <.text+0x10be70>
  11be24: eeb82b42     	vcvt.f64.u32	d2, s4
  11be28: e5901000     	ldr	r1, [r0]
  11be2c: e2412001     	sub	r2, r1, #1
  11be30: e0020291     	mul	r2, r1, r2
  11be34: ee200b01     	vmul.f64	d0, d0, d1
  11be38: e3120001     	tst	r2, #1
  11be3c: ee222b03     	vmul.f64	d2, d2, d3
  11be40: ee820b00     	vdiv.f64	d0, d2, d0
  11be44: ed9f1b4d     	vldr	d1, [pc, #308]          @ 0x11bf80 <.text+0x10be80>
  11be48: ee200b01     	vmul.f64	d0, d0, d1
  11be4c: eebc0bc0     	vcvt.u32.f64	s0, d0
  11be50: ee101a10     	vmov	r1, s0
  11be54: 0a00001d     	beq	0x11bed0 <.text+0x10bdd0> @ imm = #0x74
  11be58: e59f214c     	ldr	r2, [pc, #0x14c]        @ 0x11bfac <.text+0x10beac>
  11be5c: e79f2002     	ldr	r2, [pc, r2]
  11be60: e5922000     	ldr	r2, [r2]
  11be64: e352000a     	cmp	r2, #10
  11be68: aaffffe4     	bge	0x11be00 <.text+0x10bd00> @ imm = #-0x70
  11be6c: ea000017     	b	0x11bed0 <.text+0x10bdd0> @ imm = #0x5c
  11be70: ed9f0b38     	vldr	d0, [pc, #224]          @ 0x11bf58 <.text+0x10be58>
  11be74: ed9f1b39     	vldr	d1, [pc, #228]          @ 0x11bf60 <.text+0x10be60>
  11be78: ee025a10     	vmov	s4, r5
  11be7c: e3500007     	cmp	r0, #7
  11be80: ee034a10     	vmov	s6, r4
  11be84: eeb82bc2     	vcvt.f64.s32	d2, s4
  11be88: ee211b02     	vmul.f64	d1, d1, d2
  11be8c: ed9f2b37     	vldr	d2, [pc, #220]          @ 0x11bf70 <.text+0x10be70>
  11be90: eeb83bc3     	vcvt.f64.s32	d3, s6
  11be94: ee211b02     	vmul.f64	d1, d1, d2
  11be98: ee027a10     	vmov	s4, r7
  11be9c: ee200b03     	vmul.f64	d0, d0, d3
  11bea0: eeb82b42     	vcvt.f64.u32	d2, s4
  11bea4: ee211b02     	vmul.f64	d1, d1, d2
  11bea8: ee036a10     	vmov	s6, r6
  11beac: ed9f2b31     	vldr	d2, [pc, #196]          @ 0x11bf78 <.text+0x10be78>
  11beb0: eeb83bc3     	vcvt.f64.s32	d3, s6
  11beb4: ee200b02     	vmul.f64	d0, d0, d2
  11beb8: ee211b03     	vmul.f64	d1, d1, d3
  11bebc: ee810b00     	vdiv.f64	d0, d1, d0
  11bec0: eebc0bc0     	vcvt.u32.f64	s0, d0
  11bec4: ee101a10     	vmov	r1, s0
  11bec8: e1a02001     	mov	r2, r1
  11becc: 0a000017     	beq	0x11bf30 <.text+0x10be30> @ imm = #0x5c
  11bed0: e59f00d8     	ldr	r0, [pc, #0xd8]         @ 0x11bfb0 <.text+0x10beb0>
  11bed4: e79f0000     	ldr	r0, [pc, r0]
  11bed8: e5902000     	ldr	r2, [r0]
  11bedc: e2423001     	sub	r3, r2, #1
  11bee0: e0020392     	mul	r2, r2, r3
  11bee4: e3120001     	tst	r2, #1
  11bee8: ee001a10     	vmov	s0, r1
  11beec: ed9f1b29     	vldr	d1, [pc, #164]          @ 0x11bf98 <.text+0x10be98>
  11bef0: eeb80b40     	vcvt.f64.u32	d0, s0
  11bef4: e5902000     	ldr	r2, [r0]
  11bef8: e2423001     	sub	r3, r2, #1
  11befc: e0030392     	mul	r3, r2, r3
  11bf00: ee800b01     	vdiv.f64	d0, d0, d1
  11bf04: e3130001     	tst	r3, #1
  11bf08: ed9f1b24     	vldr	d1, [pc, #144]          @ 0x11bfa0 <.text+0x10bea0>
  11bf0c: ee200b01     	vmul.f64	d0, d0, d1
  11bf10: eebd0bc0     	vcvt.s32.f64	s0, d0
  11bf14: ee102a10     	vmov	r2, s0
  11bf18: 0a000004     	beq	0x11bf30 <.text+0x10be30> @ imm = #0x10
  11bf1c: e59f3090     	ldr	r3, [pc, #0x90]         @ 0x11bfb4 <.text+0x10beb4>
  11bf20: e79f3003     	ldr	r3, [pc, r3]
  11bf24: e5933000     	ldr	r3, [r3]
  11bf28: e3530009     	cmp	r3, #9
  11bf2c: caffffed     	bgt	0x11bee8 <.text+0x10bde8> @ imm = #-0x4c
  11bf30: e59f0080     	ldr	r0, [pc, #0x80]         @ 0x11bfb8 <.text+0x10beb8>
  11bf34: e08f0000     	add	r0, pc, r0
  11bf38: e5802000     	str	r2, [r0]
  11bf3c: e3a00000     	mov	r0, #0
  11bf40: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  11bf44: e320f000     	nop
  11bf48: 00000000     	andeq	r0, r0, r0
  11bf4c: 40a00000     	adcmi	r0, r0, r0
  11bf50: 9999999a     	ldmibls	r9, {r1, r3, r4, r7, r8, r11, r12, pc}
  11bf54: 3fd99999     	svclo	#0xd99999
  11bf58: 00000000     	andeq	r0, r0, r0
  11bf5c: 40900000     	addsmi	r0, r0, r0
  11bf60: 9999999a     	ldmibls	r9, {r1, r3, r4, r7, r8, r11, r12, pc}
  11bf64: 3fe99999     	svclo	#0xe99999
  11bf68: 00000000     	andeq	r0, r0, r0
  11bf6c: 40700000     	rsbsmi	r0, r0, r0
  11bf70: 00000000     	andeq	r0, r0, r0
  11bf74: 41700000     	cmnmi	r0, r0
  11bf78: 00000000     	andeq	r0, r0, r0
  11bf7c: 40590000     	subsmi	r0, r9, r0
  11bf80: 00000000     	andeq	r0, r0, r0
  11bf84: 3fd00000     	svclo	#0xd00000
  11bf88: 00000000     	andeq	r0, r0, r0
  11bf8c: 41a88000     	<unknown>
  11bf90: 00000000     	andeq	r0, r0, r0
  11bf94: 40518000     	subsmi	r8, r1, r0
  11bf98: 00000000     	andeq	r0, r0, r0
  11bf9c: 408f4000     	addmi	r4, pc, r0
  11bfa0: 00000000     	andeq	r0, r0, r0
  11bfa4: 3fe80000     	svclo	#0xe80000
  11bfa8: 004c3674     	subeq	r3, r12, r4, ror r6
  11bfac: 004c305c     	subeq	r3, r12, r12, asr r0
  11bfb0: 004c358c     	subeq	r3, r12, r12, lsl #11
  11bfb4: 004c2f98     	umaaleq	r2, r12, r8, pc
  11bfb8: 004d28d0     	ldrdeq	r2, r3, [sp], #-128
  11bfbc: e12fff1e     	bx	lr
  11bfc0: e92d4830     	push	{r4, r5, r11, lr}
  11bfc4: e28db008     	add	r11, sp, #8
  11bfc8: e59f4098     	ldr	r4, [pc, #0x98]         @ 0x11c068 <.text+0x10bf68>
  11bfcc: e79f4004     	ldr	r4, [pc, r4]
  11bfd0: e5940000     	ldr	r0, [r4]
  11bfd4: e59f5090     	ldr	r5, [pc, #0x90]         @ 0x11c06c <.text+0x10bf6c>
  11bfd8: e2401001     	sub	r1, r0, #1
  11bfdc: e0000190     	mul	r0, r0, r1
  11bfe0: e79f5005     	ldr	r5, [pc, r5]
  11bfe4: e3100001     	tst	r0, #1
  11bfe8: 0a000002     	beq	0x11bff8 <.text+0x10bef8> @ imm = #0x8
  11bfec: e5950000     	ldr	r0, [r5]
  11bff0: e3500009     	cmp	r0, #9
  11bff4: ca000010     	bgt	0x11c03c <.text+0x10bf3c> @ imm = #0x40
  11bff8: e30001c6     	movw	r0, #0x1c6
  11bffc: e3a01000     	mov	r1, #0
  11c000: eb0022e7     	bl	0x124ba4 <.text+0x114aa4> @ imm = #0x8b9c
  11c004: e30001c7     	movw	r0, #0x1c7
  11c008: e3a01000     	mov	r1, #0
  11c00c: eb0022e4     	bl	0x124ba4 <.text+0x114aa4> @ imm = #0x8b90
  11c010: e3a00f72     	mov	r0, #456
  11c014: e3a01000     	mov	r1, #0
  11c018: eb0022e1     	bl	0x124ba4 <.text+0x114aa4> @ imm = #0x8b84
  11c01c: e5940000     	ldr	r0, [r4]
  11c020: e2401001     	sub	r1, r0, #1
  11c024: e0000190     	mul	r0, r0, r1
  11c028: e3100001     	tst	r0, #1
  11c02c: 0a00000c     	beq	0x11c064 <.text+0x10bf64> @ imm = #0x30
  11c030: e5950000     	ldr	r0, [r5]
  11c034: e3500009     	cmp	r0, #9
  11c038: da000009     	ble	0x11c064 <.text+0x10bf64> @ imm = #0x24
  11c03c: e30001c6     	movw	r0, #0x1c6
  11c040: e3a01000     	mov	r1, #0
  11c044: eb0022d6     	bl	0x124ba4 <.text+0x114aa4> @ imm = #0x8b58
  11c048: e30001c7     	movw	r0, #0x1c7
  11c04c: e3a01000     	mov	r1, #0
  11c050: eb0022d3     	bl	0x124ba4 <.text+0x114aa4> @ imm = #0x8b4c
  11c054: e3a00f72     	mov	r0, #456
  11c058: e3a01000     	mov	r1, #0
  11c05c: eb0022d0     	bl	0x124ba4 <.text+0x114aa4> @ imm = #0x8b40
  11c060: eaffffe4     	b	0x11bff8 <.text+0x10bef8> @ imm = #-0x70
  11c064: e8bd8830     	pop	{r4, r5, r11, pc}
  11c068: 004c3510     	subeq	r3, r12, r0, lsl r5
  11c06c: 004c2f38     	subeq	r2, r12, r8, lsr pc
  11c070: e59f0004     	ldr	r0, [pc, #0x4]          @ 0x11c07c <.text+0x10bf7c>
  11c074: e79f0000     	ldr	r0, [pc, r0]
  11c078: e12fff1e     	bx	lr
  11c07c: 004d2790     	umaaleq	r2, sp, r0, r7
  11c080: e59f1058     	ldr	r1, [pc, #0x58]         @ 0x11c0e0 <.text+0x10bfe0>
  11c084: e79f1001     	ldr	r1, [pc, r1]
  11c088: e5912000     	ldr	r2, [r1]
  11c08c: e2423001     	sub	r3, r2, #1
  11c090: e0020392     	mul	r2, r2, r3
  11c094: e3120001     	tst	r2, #1
  11c098: e5912000     	ldr	r2, [r1]
  11c09c: e2423001     	sub	r3, r2, #1
  11c0a0: e0020392     	mul	r2, r2, r3
  11c0a4: e3120001     	tst	r2, #1
  11c0a8: 0a000004     	beq	0x11c0c0 <.text+0x10bfc0> @ imm = #0x10
  11c0ac: e59f2030     	ldr	r2, [pc, #0x30]         @ 0x11c0e4 <.text+0x10bfe4>
  11c0b0: e79f2002     	ldr	r2, [pc, r2]
  11c0b4: e5922000     	ldr	r2, [r2]
  11c0b8: e3520009     	cmp	r2, #9
  11c0bc: cafffff5     	bgt	0x11c098 <.text+0x10bf98> @ imm = #-0x2c
  11c0c0: e3500002     	cmp	r0, #2
  11c0c4: 859f0020     	ldrhi	r0, [pc, #0x20]         @ 0x11c0ec <.text+0x10bfec>
  11c0c8: 808f0000     	addhi	r0, pc, r0
  11c0cc: 812fff1e     	bxhi	lr
  11c0d0: e59f1010     	ldr	r1, [pc, #0x10]         @ 0x11c0e8 <.text+0x10bfe8>
  11c0d4: e08f1001     	add	r1, pc, r1
  11c0d8: e7910100     	ldr	r0, [r1, r0, lsl #2]
  11c0dc: e12fff1e     	bx	lr
  11c0e0: 004c2ef8     	strdeq	r2, r3, [r12], #-232
  11c0e4: 004c32a8     	subeq	r3, r12, r8, lsr #5
  11c0e8: 004bf32c     	subeq	pc, r11, r12, lsr #6
  11c0ec: 004a6477     	subeq	r6, r10, r7, ror r4
  11c0f0: e92d4830     	push	{r4, r5, r11, lr}
  11c0f4: e28db008     	add	r11, sp, #8
  11c0f8: e59f41b0     	ldr	r4, [pc, #0x1b0]        @ 0x11c2b0 <.text+0x10c1b0>
  11c0fc: e79f4004     	ldr	r4, [pc, r4]
  11c100: e5940000     	ldr	r0, [r4]
  11c104: e59f51a8     	ldr	r5, [pc, #0x1a8]        @ 0x11c2b4 <.text+0x10c1b4>
  11c108: e2401001     	sub	r1, r0, #1
  11c10c: e0000190     	mul	r0, r0, r1
  11c110: e79f5005     	ldr	r5, [pc, r5]
  11c114: e3100001     	tst	r0, #1
  11c118: 0a000002     	beq	0x11c128 <.text+0x10c028> @ imm = #0x8
  11c11c: e5950000     	ldr	r0, [r5]
  11c120: e3500009     	cmp	r0, #9
  11c124: ca00000b     	bgt	0x11c158 <.text+0x10c058> @ imm = #0x2c
  11c128: ebff7a13     	bl	0xfa97c <.text+0xea87c> @ imm = #-0x217b4
  11c12c: ebffb1ca     	bl	0x10885c <.text+0xf875c> @ imm = #-0x138d8
  11c130: e30001c6     	movw	r0, #0x1c6
  11c134: eb002288     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x8a20
  11c138: e5941000     	ldr	r1, [r4]
  11c13c: e2412001     	sub	r2, r1, #1
  11c140: e0010291     	mul	r1, r1, r2
  11c144: e3110001     	tst	r1, #1
  11c148: 0a000007     	beq	0x11c16c <.text+0x10c06c> @ imm = #0x1c
  11c14c: e5951000     	ldr	r1, [r5]
  11c150: e3510009     	cmp	r1, #9
  11c154: da000004     	ble	0x11c16c <.text+0x10c06c> @ imm = #0x10
  11c158: ebff7a07     	bl	0xfa97c <.text+0xea87c> @ imm = #-0x217e4
  11c15c: ebffb1be     	bl	0x10885c <.text+0xf875c> @ imm = #-0x13908
  11c160: e30001c6     	movw	r0, #0x1c6
  11c164: eb00227c     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x89f0
  11c168: eaffffee     	b	0x11c128 <.text+0x10c028> @ imm = #-0x48
  11c16c: e3500000     	cmp	r0, #0
  11c170: 0a000001     	beq	0x11c17c <.text+0x10c07c> @ imm = #0x4
  11c174: e30001c6     	movw	r0, #0x1c6
  11c178: eb00240e     	bl	0x1251b8 <.text+0x1150b8> @ imm = #0x9038
  11c17c: e5940000     	ldr	r0, [r4]
  11c180: e2401001     	sub	r1, r0, #1
  11c184: e0000190     	mul	r0, r0, r1
  11c188: e3100001     	tst	r0, #1
  11c18c: 0a000002     	beq	0x11c19c <.text+0x10c09c> @ imm = #0x8
  11c190: e5950000     	ldr	r0, [r5]
  11c194: e3500009     	cmp	r0, #9
  11c198: ca000009     	bgt	0x11c1c4 <.text+0x10c0c4> @ imm = #0x24
  11c19c: e30001b7     	movw	r0, #0x1b7
  11c1a0: eb00226d     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x89b4
  11c1a4: e5941000     	ldr	r1, [r4]
  11c1a8: e2412001     	sub	r2, r1, #1
  11c1ac: e0010291     	mul	r1, r1, r2
  11c1b0: e3110001     	tst	r1, #1
  11c1b4: 0a000005     	beq	0x11c1d0 <.text+0x10c0d0> @ imm = #0x14
  11c1b8: e5951000     	ldr	r1, [r5]
  11c1bc: e3510009     	cmp	r1, #9
  11c1c0: da000002     	ble	0x11c1d0 <.text+0x10c0d0> @ imm = #0x8
  11c1c4: e30001b7     	movw	r0, #0x1b7
  11c1c8: eb002263     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x898c
  11c1cc: eafffff2     	b	0x11c19c <.text+0x10c09c> @ imm = #-0x38
  11c1d0: e3500000     	cmp	r0, #0
  11c1d4: 0a000001     	beq	0x11c1e0 <.text+0x10c0e0> @ imm = #0x4
  11c1d8: e30001b7     	movw	r0, #0x1b7
  11c1dc: eb0023f5     	bl	0x1251b8 <.text+0x1150b8> @ imm = #0x8fd4
  11c1e0: e30001c7     	movw	r0, #0x1c7
  11c1e4: eb00225c     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x8970
  11c1e8: e3500000     	cmp	r0, #0
  11c1ec: 0a000001     	beq	0x11c1f8 <.text+0x10c0f8> @ imm = #0x4
  11c1f0: e30001c7     	movw	r0, #0x1c7
  11c1f4: eb0023ef     	bl	0x1251b8 <.text+0x1150b8> @ imm = #0x8fbc
  11c1f8: e3a00f6e     	mov	r0, #440
  11c1fc: eb002256     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x8958
  11c200: e3500000     	cmp	r0, #0
  11c204: 0a000001     	beq	0x11c210 <.text+0x10c110> @ imm = #0x4
  11c208: e3a00f6e     	mov	r0, #440
  11c20c: eb0023e9     	bl	0x1251b8 <.text+0x1150b8> @ imm = #0x8fa4
  11c210: e5940000     	ldr	r0, [r4]
  11c214: e2401001     	sub	r1, r0, #1
  11c218: e0000190     	mul	r0, r0, r1
  11c21c: e3100001     	tst	r0, #1
  11c220: 0a000002     	beq	0x11c230 <.text+0x10c130> @ imm = #0x8
  11c224: e5950000     	ldr	r0, [r5]
  11c228: e3500009     	cmp	r0, #9
  11c22c: ca000009     	bgt	0x11c258 <.text+0x10c158> @ imm = #0x24
  11c230: e3a00f72     	mov	r0, #456
  11c234: eb002248     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x8920
  11c238: e5941000     	ldr	r1, [r4]
  11c23c: e2412001     	sub	r2, r1, #1
  11c240: e0010291     	mul	r1, r1, r2
  11c244: e3110001     	tst	r1, #1
  11c248: 0a000005     	beq	0x11c264 <.text+0x10c164> @ imm = #0x14
  11c24c: e5951000     	ldr	r1, [r5]
  11c250: e3510009     	cmp	r1, #9
  11c254: da000002     	ble	0x11c264 <.text+0x10c164> @ imm = #0x8
  11c258: e3a00f72     	mov	r0, #456
  11c25c: eb00223e     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x88f8
  11c260: eafffff2     	b	0x11c230 <.text+0x10c130> @ imm = #-0x38
  11c264: e3500000     	cmp	r0, #0
  11c268: 0a000001     	beq	0x11c274 <.text+0x10c174> @ imm = #0x4
  11c26c: e3a00f72     	mov	r0, #456
  11c270: eb0023d0     	bl	0x1251b8 <.text+0x1150b8> @ imm = #0x8f40
  11c274: e30001b9     	movw	r0, #0x1b9
  11c278: eb002237     	bl	0x124b5c <.text+0x114a5c> @ imm = #0x88dc
  11c27c: e3500000     	cmp	r0, #0
  11c280: 0a000001     	beq	0x11c28c <.text+0x10c18c> @ imm = #0x4
  11c284: e30001b9     	movw	r0, #0x1b9
  11c288: eb0023ca     	bl	0x1251b8 <.text+0x1150b8> @ imm = #0x8f28
  11c28c: e5940000     	ldr	r0, [r4]
  11c290: e2401001     	sub	r1, r0, #1
  11c294: e0000190     	mul	r0, r0, r1
  11c298: e3100001     	tst	r0, #1
  11c29c: 0a000002     	beq	0x11c2ac <.text+0x10c1ac> @ imm = #0x8
  11c2a0: e5950000     	ldr	r0, [r5]
  11c2a4: e3500009     	cmp	r0, #9
  11c2a8: cafffff7     	bgt	0x11c28c <.text+0x10c18c> @ imm = #-0x24
  11c2ac: e8bd8830     	pop	{r4, r5, r11, pc}
  11c2b0: 004c3bac     	subeq	r3, r12, r12, lsr #23
  11c2b4: 004c25c0     	subeq	r2, r12, r0, asr #11

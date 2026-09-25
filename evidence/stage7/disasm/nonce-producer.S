
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c4480: e59d0010     	ldr	r0, [sp, #0x10]
   c4484: e3500005     	cmp	r0, #5
   c4488: 1a000009     	bne	0xc44b4 <.text+0xb43b4> @ imm = #0x24
   c448c: e3881005     	orr	r1, r8, #5
   c4490: e3520001     	cmp	r2, #1
   c4494: 03881006     	orreq	r1, r8, #6
   c4498: e55b0064     	ldrb	r0, [r11, #-0x64]
   c449c: e3520002     	cmp	r2, #2
   c44a0: e5d11000     	ldrb	r1, [r1]
   c44a4: e1a00380     	lsl	r0, r0, #7
   c44a8: 33e0007f     	mvnlo	r0, #127
   c44ac: e18000a1     	orr	r0, r0, r1, lsr #1
   c44b0: ea000003     	b	0xc44c4 <.text+0xb43c4> @ imm = #0xc
   c44b4: e3880005     	orr	r0, r8, #5
   c44b8: e3520001     	cmp	r2, #1
   c44bc: 03880006     	orreq	r0, r8, #6
   c44c0: e5d00000     	ldrb	r0, [r0]
   c44c4: e59a1000     	ldr	r1, [r10]
   c44c8: e2412001     	sub	r2, r1, #1
   c44cc: e0010291     	mul	r1, r1, r2
   c44d0: e3110001     	tst	r1, #1
   c44d4: e59a2000     	ldr	r2, [r10]
   c44d8: e7e411d0     	ubfx	r1, r0, #0x3, #0x5
   c44dc: e2423001     	sub	r3, r2, #1
   c44e0: e0020392     	mul	r2, r2, r3
   c44e4: e3120001     	tst	r2, #1
   c44e8: 0a000004     	beq	0xc4500 <.text+0xb4400> @ imm = #0x10
   c44ec: e59f25dc     	ldr	r2, [pc, #0x5dc]        @ 0xc4ad0 <.text+0xb49d0>
   c44f0: e79f2002     	ldr	r2, [pc, r2]
   c44f4: e5922000     	ldr	r2, [r2]
   c44f8: e3520009     	cmp	r2, #9
   c44fc: cafffff4     	bgt	0xc44d4 <.text+0xb43d4> @ imm = #-0x30
   c4500: e59f05cc     	ldr	r0, [pc, #0x5cc]        @ 0xc4ad4 <.text+0xb49d4>
   c4504: e3a020a8     	mov	r2, #168
   c4508: e08f0000     	add	r0, pc, r0
   c450c: e10a0281     	smlabb	r10, r1, r2, r0
   c4510: e29a0008     	adds	r0, r10, #8
   c4514: 0a00007f     	beq	0xc4718 <.text+0xb4618> @ imm = #0x1fc
   c4518: e15b26b2     	ldrh	r2, [r11, #-98]
   c451c: e5190300     	ldr	r0, [r9, #-0x300]
   c4520: e58d6050     	str	r6, [sp, #0x50]
   c4524: e59d604c     	ldr	r6, [sp, #0x4c]
   c4528: e50b00f8     	str	r0, [r11, #-0xf8]
   c452c: e59a00ac     	ldr	r0, [r10, #0xac]
   c4530: e3560002     	cmp	r6, #2
   c4534: e50b00ec     	str	r0, [r11, #-0xec]
   c4538: e1a00402     	lsl	r0, r2, #8
   c453c: e50b10e8     	str	r1, [r11, #-0xe8]
   c4540: e1a01422     	lsr	r1, r2, #8
   c4544: 33e000ff     	mvnlo	r0, #255
   c4548: 330010ff     	movwlo	r1, #0xff
   c454c: e1800001     	orr	r0, r0, r1
   c4550: e30027f8     	movw	r2, #0x7f8
   c4554: e000c002     	and	r12, r0, r2
   c4558: e2011007     	and	r1, r1, #7
   c455c: e6ff0070     	uxth	r0, r0
   c4560: e59a2080     	ldr	r2, [r10, #0x80]
   c4564: e1a005a0     	lsr	r0, r0, #11
   c4568: e59a8078     	ldr	r8, [r10, #0x78]
   c456c: e1800a81     	orr	r0, r0, r1, lsl #21
   c4570: e59d1030     	ldr	r1, [sp, #0x30]
   c4574: e180028c     	orr	r0, r0, r12, lsl #5
   c4578: e58d002c     	str	r0, [sp, #0x2c]
   c457c: e1800002     	orr	r0, r0, r2
   c4580: e50b00e4     	str	r0, [r11, #-0xe4]
   c4584: e59d0004     	ldr	r0, [sp, #0x4]
   c4588: e3560001     	cmp	r6, #1
   c458c: e59a307c     	ldr	r3, [r10, #0x7c]
   c4590: e5808000     	str	r8, [r0]
   c4594: e5803004     	str	r3, [r0, #0x4]
   c4598: e24b0068     	sub	r0, r11, #104
   c459c: 01a00001     	moveq	r0, r1
   c45a0: e5900000     	ldr	r0, [r0]
   c45a4: e6bf0f30     	rev	r0, r0
   c45a8: e50b00d8     	str	r0, [r11, #-0xd8]
   c45ac: eb00386b     	bl	0xd2760 <.text+0xc2660> @ imm = #0xe1ac
   c45b0: e51b10d8     	ldr	r1, [r11, #-0xd8]
   c45b4: e50b00f4     	str	r0, [r11, #-0xf4]
   c45b8: e1a00001     	mov	r0, r1
   c45bc: eb003892     	bl	0xd280c <.text+0xc270c> @ imm = #0xe248
   c45c0: e50b00f0     	str	r0, [r11, #-0xf0]
   c45c4: e59a0058     	ldr	r0, [r10, #0x58]
   c45c8: e58d0018     	str	r0, [sp, #0x18]
   c45cc: e59a0070     	ldr	r0, [r10, #0x70]
   c45d0: e59a106c     	ldr	r1, [r10, #0x6c]
   c45d4: e6bf0f30     	rev	r0, r0
   c45d8: e59a2068     	ldr	r2, [r10, #0x68]
   c45dc: e50b0070     	str	r0, [r11, #-0x70]
   c45e0: e6bf0f31     	rev	r0, r1
   c45e4: e59ac064     	ldr	r12, [r10, #0x64]
   c45e8: e59a3080     	ldr	r3, [r10, #0x80]
   c45ec: e50b0074     	str	r0, [r11, #-0x74]
   c45f0: e6bf0f32     	rev	r0, r2
   c45f4: e59a6060     	ldr	r6, [r10, #0x60]
   c45f8: e58d3028     	str	r3, [sp, #0x28]
   c45fc: e59a308c     	ldr	r3, [r10, #0x8c]
   c4600: e50b0078     	str	r0, [r11, #-0x78]
   c4604: e6bf0f3c     	rev	r0, r12
   c4608: e59a905c     	ldr	r9, [r10, #0x5c]
   c460c: e58d3024     	str	r3, [sp, #0x24]
   c4610: e59a3090     	ldr	r3, [r10, #0x90]
   c4614: e50b007c     	str	r0, [r11, #-0x7c]
   c4618: e6bf0f36     	rev	r0, r6
   c461c: e58d3020     	str	r3, [sp, #0x20]
   c4620: e28d6058     	add	r6, sp, #88
   c4624: e59a3094     	ldr	r3, [r10, #0x94]
   c4628: e50b0080     	str	r0, [r11, #-0x80]
   c462c: e6bf0f39     	rev	r0, r9
   c4630: e58d301c     	str	r3, [sp, #0x1c]
   c4634: e59a3098     	ldr	r3, [r10, #0x98]
   c4638: e50b0084     	str	r0, [r11, #-0x84]
   c463c: e59d0018     	ldr	r0, [sp, #0x18]
   c4640: e58d3014     	str	r3, [sp, #0x14]
   c4644: e59a809c     	ldr	r8, [r10, #0x9c]
   c4648: e6bf0f30     	rev	r0, r0
   c464c: e59ae0a0     	ldr	lr, [r10, #0xa0]
   c4650: e59a30a4     	ldr	r3, [r10, #0xa4]
   c4654: e59aa0a8     	ldr	r10, [r10, #0xa8]
   c4658: e50b0088     	str	r0, [r11, #-0x88]
   c465c: e6bf0f3a     	rev	r0, r10
   c4660: e50b008c     	str	r0, [r11, #-0x8c]
   c4664: e6bf0f33     	rev	r0, r3
   c4668: e50b0090     	str	r0, [r11, #-0x90]
   c466c: e6bf0f3e     	rev	r0, lr
   c4670: e50b0094     	str	r0, [r11, #-0x94]
   c4674: e6bf0f38     	rev	r0, r8
   c4678: e50b0098     	str	r0, [r11, #-0x98]
   c467c: e59d0014     	ldr	r0, [sp, #0x14]
   c4680: e24b8068     	sub	r8, r11, #104
   c4684: e59d1028     	ldr	r1, [sp, #0x28]
   c4688: e6bf0f30     	rev	r0, r0
   c468c: e50b009c     	str	r0, [r11, #-0x9c]
   c4690: e59d001c     	ldr	r0, [sp, #0x1c]
   c4694: e6bf0f30     	rev	r0, r0
   c4698: e50b00a0     	str	r0, [r11, #-0xa0]
   c469c: e59d0020     	ldr	r0, [sp, #0x20]
   c46a0: e6bf0f30     	rev	r0, r0
   c46a4: e50b00a4     	str	r0, [r11, #-0xa4]
   c46a8: e59d0024     	ldr	r0, [sp, #0x24]
   c46ac: e6bf0f30     	rev	r0, r0
   c46b0: e50b00a8     	str	r0, [r11, #-0xa8]
   c46b4: e59d002c     	ldr	r0, [sp, #0x2c]
   c46b8: e1810000     	orr	r0, r1, r0
   c46bc: e6bf0f30     	rev	r0, r0
   c46c0: e50b00ac     	str	r0, [r11, #-0xac]
   c46c4: e1a00006     	mov	r0, r6
   c46c8: eb011294     	bl	0x109120 <.text+0xf9020> @ imm = #0x44a50
   c46cc: e24b10ac     	sub	r1, r11, #172
   c46d0: e1a00006     	mov	r0, r6
   c46d4: e3a02040     	mov	r2, #64
   c46d8: eb0112a4     	bl	0x109170 <.text+0xf9070> @ imm = #0x44a90
   c46dc: e59dc00c     	ldr	r12, [sp, #0xc]
   c46e0: e59d1008     	ldr	r1, [sp, #0x8]
   c46e4: e8bc004d     	ldm	r12!, {r0, r2, r3, r6}
   c46e8: e8a1004d     	stm	r1!, {r0, r2, r3, r6}
   c46ec: e89c004d     	ldm	r12, {r0, r2, r3, r6}
   c46f0: e881004d     	stm	r1, {r0, r2, r3, r6}
   c46f4: e24b00f8     	sub	r0, r11, #248
   c46f8: e59d6050     	ldr	r6, [sp, #0x50]
   c46fc: eb00d7b7     	bl	0xfa5e0 <.text+0xea4e0> @ imm = #0x35edc

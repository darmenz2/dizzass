
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c4878: e59a1000     	ldr	r1, [r10]
   c487c: e59f0280     	ldr	r0, [pc, #0x280]        @ 0xc4b04 <.text+0xb4a04>
   c4880: e2412001     	sub	r2, r1, #1
   c4884: e79f0000     	ldr	r0, [pc, r0]
   c4888: e0010291     	mul	r1, r1, r2
   c488c: e5192300     	ldr	r2, [r9, #-0x300]
   c4890: e58d2058     	str	r2, [sp, #0x58]
   c4894: e5900000     	ldr	r0, [r0]
   c4898: e3110001     	tst	r1, #1
   c489c: 0a000004     	beq	0xc48b4 <.text+0xb47b4> @ imm = #0x10
   c48a0: e3500009     	cmp	r0, #9
   c48a4: da000002     	ble	0xc48b4 <.text+0xb47b4> @ imm = #0x8
   c48a8: e5190300     	ldr	r0, [r9, #-0x300]
   c48ac: e58d0058     	str	r0, [sp, #0x58]
   c48b0: eafffff0     	b	0xc4878 <.text+0xb4778> @ imm = #-0x40
   c48b4: e59d204c     	ldr	r2, [sp, #0x4c]
   c48b8: e3520001     	cmp	r2, #1
   c48bc: 0a00000d     	beq	0xc48f8 <.text+0xb47f8> @ imm = #0x34
   c48c0: e1a09005     	mov	r9, r5
   c48c4: e59f523c     	ldr	r5, [pc, #0x23c]        @ 0xc4b08 <.text+0xb4a08>
   c48c8: e3520000     	cmp	r2, #0
   c48cc: e79f5005     	ldr	r5, [pc, r5]
   c48d0: 1a000010     	bne	0xc4918 <.text+0xb4818> @ imm = #0x40
   c48d4: e59a0000     	ldr	r0, [r10]
   c48d8: e2401001     	sub	r1, r0, #1
   c48dc: e0000190     	mul	r0, r0, r1
   c48e0: e3100001     	tst	r0, #1
   c48e4: 0a00001f     	beq	0xc4968 <.text+0xb4868> @ imm = #0x7c
   c48e8: e5950000     	ldr	r0, [r5]
   c48ec: e3500009     	cmp	r0, #9
   c48f0: ca000029     	bgt	0xc499c <.text+0xb489c> @ imm = #0xa4
   c48f4: ea00001b     	b	0xc4968 <.text+0xb4868> @ imm = #0x6c
   c48f8: e55b1063     	ldrb	r1, [r11, #-0x63]
   c48fc: e1a09005     	mov	r9, r5
   c4900: e5cd105c     	strb	r1, [sp, #0x5c]
   c4904: e55b0062     	ldrb	r0, [r11, #-0x62]
   c4908: e59d1030     	ldr	r1, [sp, #0x30]
   c490c: e59f51f8     	ldr	r5, [pc, #0x1f8]        @ 0xc4b0c <.text+0xb4a0c>
   c4910: e79f5005     	ldr	r5, [pc, r5]
   c4914: ea000025     	b	0xc49b0 <.text+0xb48b0> @ imm = #0x94
   c4918: e55b0063     	ldrb	r0, [r11, #-0x63]
   c491c: e55b1064     	ldrb	r1, [r11, #-0x64]
   c4920: e5cd105c     	strb	r1, [sp, #0x5c]
   c4924: e1a01008     	mov	r1, r8
   c4928: ea000020     	b	0xc49b0 <.text+0xb48b0> @ imm = #0x80
   c492c: e1a00006     	mov	r0, r6
   c4930: eb138763     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1d8c
   c4934: e59a0000     	ldr	r0, [r10]
   c4938: e2401001     	sub	r1, r0, #1
   c493c: e0000190     	mul	r0, r0, r1
   c4940: e3100001     	tst	r0, #1
   c4944: 0affffc8     	beq	0xc486c <.text+0xb476c> @ imm = #-0xe0
   c4948: e3a00001     	mov	r0, #1
   c494c: e58d0050     	str	r0, [sp, #0x50]
   c4950: e5950000     	ldr	r0, [r5]
   c4954: e350000a     	cmp	r0, #10
   c4958: bafffe6e     	blt	0xc4318 <.text+0xb4218> @ imm = #-0x648
   c495c: e1a00006     	mov	r0, r6
   c4960: eb138757     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e1d5c
   c4964: eafffff0     	b	0xc492c <.text+0xb482c> @ imm = #-0x40
   c4968: e59a0000     	ldr	r0, [r10]
   c496c: e55b3064     	ldrb	r3, [r11, #-0x64]
   c4970: e2401001     	sub	r1, r0, #1
   c4974: e5cd305c     	strb	r3, [sp, #0x5c]
   c4978: e0020190     	mul	r2, r0, r1
   c497c: e55b0063     	ldrb	r0, [r11, #-0x63]
   c4980: e5951000     	ldr	r1, [r5]
   c4984: e3120001     	tst	r2, #1
   c4988: 0a000006     	beq	0xc49a8 <.text+0xb48a8> @ imm = #0x18
   c498c: e59d204c     	ldr	r2, [sp, #0x4c]
   c4990: e351000a     	cmp	r1, #10
   c4994: e1a01008     	mov	r1, r8
   c4998: ba000004     	blt	0xc49b0 <.text+0xb48b0> @ imm = #0x10
   c499c: e55b0064     	ldrb	r0, [r11, #-0x64]
   c49a0: e5cd005c     	strb	r0, [sp, #0x5c]
   c49a4: eaffffef     	b	0xc4968 <.text+0xb4868> @ imm = #-0x44
   c49a8: e1a01008     	mov	r1, r8
   c49ac: e59d204c     	ldr	r2, [sp, #0x4c]
   c49b0: e5cd005d     	strb	r0, [sp, #0x5d]
   c49b4: e3520000     	cmp	r2, #0
   c49b8: e5910000     	ldr	r0, [r1]
   c49bc: e59d8048     	ldr	r8, [sp, #0x48]
   c49c0: e1a01820     	lsr	r1, r0, #16
   c49c4: e6bf0f30     	rev	r0, r0
   c49c8: e6bf1f31     	rev	r1, r1
   c49cc: e7cf001f     	bfc	r0, #0, #16
   c49d0: e1800861     	orr	r0, r0, r1, ror #16
   c49d4: e58d0060     	str	r0, [sp, #0x60]
   c49d8: 0a00000c     	beq	0xc4a10 <.text+0xb4910> @ imm = #0x30
   c49dc: e3520001     	cmp	r2, #1
   c49e0: 1a000009     	bne	0xc4a0c <.text+0xb490c> @ imm = #0x24
   c49e4: e59a0000     	ldr	r0, [r10]
   c49e8: e2401001     	sub	r1, r0, #1
   c49ec: e0000190     	mul	r0, r0, r1
   c49f0: e3100001     	tst	r0, #1
   c49f4: 0a000002     	beq	0xc4a04 <.text+0xb4904> @ imm = #0x8
   c49f8: e5950000     	ldr	r0, [r5]
   c49fc: e350000a     	cmp	r0, #10
   c4a00: aafffff7     	bge	0xc49e4 <.text+0xb48e4> @ imm = #-0x24
   c4a04: e59d803c     	ldr	r8, [sp, #0x3c]
   c4a08: ea000000     	b	0xc4a10 <.text+0xb4910> @ imm = #0x0
   c4a0c: e59d8034     	ldr	r8, [sp, #0x34]
   c4a10: e59a0000     	ldr	r0, [r10]
   c4a14: e2401001     	sub	r1, r0, #1
   c4a18: e0000190     	mul	r0, r0, r1
   c4a1c: e3100001     	tst	r0, #1
   c4a20: 0a000002     	beq	0xc4a30 <.text+0xb4930> @ imm = #0x8
   c4a24: e5950000     	ldr	r0, [r5]
   c4a28: e3500009     	cmp	r0, #9
   c4a2c: ca00000c     	bgt	0xc4a64 <.text+0xb4964> @ imm = #0x30
   c4a30: e5d80000     	ldrb	r0, [r8]
   c4a34: e200001f     	and	r0, r0, #31
   c4a38: e1cd06b4     	strh	r0, [sp, #100]
   c4a3c: eb003810     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe040
   c4a40: e59a1000     	ldr	r1, [r10]
   c4a44: e2412001     	sub	r2, r1, #1
   c4a48: e0020291     	mul	r2, r1, r2
   c4a4c: e5dd105d     	ldrb	r1, [sp, #0x5d]
   c4a50: e3120001     	tst	r2, #1
   c4a54: 0a000007     	beq	0xc4a78 <.text+0xb4978> @ imm = #0x1c
   c4a58: e5952000     	ldr	r2, [r5]
   c4a5c: e3520009     	cmp	r2, #9
   c4a60: da000004     	ble	0xc4a78 <.text+0xb4978> @ imm = #0x10
   c4a64: e5d80000     	ldrb	r0, [r8]
   c4a68: e200001f     	and	r0, r0, #31
   c4a6c: e1cd06b4     	strh	r0, [sp, #100]
   c4a70: eb003803     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe00c
   c4a74: eaffffed     	b	0xc4a30 <.text+0xb4930> @ imm = #-0x4c
   c4a78: e24b8068     	sub	r8, r11, #104
   c4a7c: e1500001     	cmp	r0, r1
   c4a80: 0affff6f     	beq	0xc4844 <.text+0xb4744> @ imm = #-0x244
   c4a84: eaffff6c     	b	0xc483c <.text+0xb473c> @ imm = #-0x250

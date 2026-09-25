
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fa5e0: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
   fa5e4: e28db010     	add	r11, sp, #16
   fa5e8: e1a04000     	mov	r4, r0
   fa5ec: e59f00c4     	ldr	r0, [pc, #0xc4]         @ 0xfa6b8 <.text+0xea5b8>
   fa5f0: e08f0000     	add	r0, pc, r0
   fa5f4: eb12aec3     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4abb0c
   fa5f8: e59f00bc     	ldr	r0, [pc, #0xbc]         @ 0xfa6bc <.text+0xea5bc>
   fa5fc: e08f0000     	add	r0, pc, r0
   fa600: ebff5d6a     	bl	0xd1bb0 <.text+0xc1ab0> @ imm = #-0x28a58
   fa604: e3500000     	cmp	r0, #0
   fa608: 0a00001c     	beq	0xfa680 <.text+0xea580> @ imm = #0x70
   fa60c: e59f50ac     	ldr	r5, [pc, #0xac]         @ 0xfa6c0 <.text+0xea5c0>
   fa610: e79f5005     	ldr	r5, [pc, r5]
   fa614: e5950000     	ldr	r0, [r5]
   fa618: e59f60a4     	ldr	r6, [pc, #0xa4]         @ 0xfa6c4 <.text+0xea5c4>
   fa61c: e2401001     	sub	r1, r0, #1
   fa620: e0000190     	mul	r0, r0, r1
   fa624: e79f6006     	ldr	r6, [pc, r6]
   fa628: e3100001     	tst	r0, #1
   fa62c: 0a000002     	beq	0xfa63c <.text+0xea53c> @ imm = #0x8
   fa630: e5960000     	ldr	r0, [r6]
   fa634: e3500009     	cmp	r0, #9
   fa638: ca00000b     	bgt	0xfa66c <.text+0xea56c> @ imm = #0x2c
   fa63c: e59f0084     	ldr	r0, [pc, #0x84]         @ 0xfa6c8 <.text+0xea5c8>
   fa640: e3a01000     	mov	r1, #0
   fa644: e08f0000     	add	r0, pc, r0
   fa648: ebff5de8     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #-0x28860
   fa64c: e5950000     	ldr	r0, [r5]
   fa650: e2401001     	sub	r1, r0, #1
   fa654: e0000190     	mul	r0, r0, r1
   fa658: e3100001     	tst	r0, #1
   fa65c: 0a000007     	beq	0xfa680 <.text+0xea580> @ imm = #0x1c
   fa660: e5960000     	ldr	r0, [r6]
   fa664: e3500009     	cmp	r0, #9
   fa668: da000004     	ble	0xfa680 <.text+0xea580> @ imm = #0x10
   fa66c: e59f0058     	ldr	r0, [pc, #0x58]         @ 0xfa6cc <.text+0xea5cc>
   fa670: e3a01000     	mov	r1, #0
   fa674: e08f0000     	add	r0, pc, r0
   fa678: ebff5ddc     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #-0x28890
   fa67c: eaffffee     	b	0xfa63c <.text+0xea53c> @ imm = #-0x48
   fa680: e59f0048     	ldr	r0, [pc, #0x48]         @ 0xfa6d0 <.text+0xea5d0>
   fa684: e1a01004     	mov	r1, r4
   fa688: e08f0000     	add	r0, pc, r0
   fa68c: ebff5cd7     	bl	0xd19f0 <.text+0xc18f0> @ imm = #-0x28ca4
   fa690: e59f103c     	ldr	r1, [pc, #0x3c]         @ 0xfa6d4 <.text+0xea5d4>
   fa694: e59f003c     	ldr	r0, [pc, #0x3c]         @ 0xfa6d8 <.text+0xea5d8>
   fa698: e59f203c     	ldr	r2, [pc, #0x3c]         @ 0xfa6dc <.text+0xea5dc>
   fa69c: e08f1001     	add	r1, pc, r1
   fa6a0: e08f0000     	add	r0, pc, r0
   fa6a4: e79f2002     	ldr	r2, [pc, r2]
   fa6a8: e2822001     	add	r2, r2, #1
   fa6ac: e5812000     	str	r2, [r1]
   fa6b0: e8bd4c70     	pop	{r4, r5, r6, r10, r11, lr}
   fa6b4: ea12b002     	b	0x5a66c4 <.text+0x5965c4> @ imm = #0x4ac008
   fa6b8: 0055a4d8     	ldrsbeq	r10, [r5], #-72
   fa6bc: 0055a4e4     	subseq	r10, r5, r4, ror #9
   fa6c0: 004e4130     	subeq	r4, lr, r0, lsr r1
   fa6c4: 004e4874     	subeq	r4, lr, r4, ror r8
   fa6c8: 0055a49c     	<unknown>
   fa6cc: 0055a46c     	subseq	r10, r5, r12, ror #8
   fa6d0: 0055a458     	subseq	r10, r5, r8, asr r4
   fa6d4: 0055a460     	subseq	r10, r5, r0, ror #8
   fa6d8: 0055a428     	subseq	r10, r5, r8, lsr #8
   fa6dc: 0055a458     	subseq	r10, r5, r8, asr r4

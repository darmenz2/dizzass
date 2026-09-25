
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

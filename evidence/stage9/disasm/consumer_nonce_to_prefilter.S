
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   7511c: e2401001     	sub	r1, r0, #1
   75120: e58dc014     	str	r12, [sp, #0x14]
   75124: e58de020     	str	lr, [sp, #0x20]
   75128: e0000190     	mul	r0, r0, r1
   7512c: e3100001     	tst	r0, #1
   75130: 0a000005     	beq	0x7514c <.text+0x6504c> @ imm = #0x14
   75134: e5970000     	ldr	r0, [r7]
   75138: e3500009     	cmp	r0, #9
   7513c: ca00000e     	bgt	0x7517c <.text+0x6507c> @ imm = #0x38
   75140: ea000001     	b	0x7514c <.text+0x6504c> @ imm = #0x4
   75144: e3a03000     	mov	r3, #0
   75148: eaffff8e     	b	0x74f88 <.text+0x64e88> @ imm = #-0x1c8
   7514c: e59d0028     	ldr	r0, [sp, #0x28]
   75150: e1a0100a     	mov	r1, r10
   75154: ebfef781     	bl	0x32f60 <.text+0x22e60> @ imm = #-0x421fc
   75158: e5981000     	ldr	r1, [r8]

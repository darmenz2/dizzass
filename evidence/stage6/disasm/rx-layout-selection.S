
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c4074: e3a00000     	mov	r0, #0
   c4078: e58d004c     	str	r0, [sp, #0x4c]
   c407c: eb00e7ca     	bl	0xfdfac <.text+0xedeac> @ imm = #0x39f28
   c4080: e3500000     	cmp	r0, #0
   c4084: 0a000006     	beq	0xc40a4 <.text+0xb3fa4> @ imm = #0x18
   c4088: e3560006     	cmp	r6, #6
   c408c: 03500004     	cmpeq	r0, #4
   c4090: 0a000003     	beq	0xc40a4 <.text+0xb3fa4> @ imm = #0xc
   c4094: e3a00002     	mov	r0, #2
   c4098: e3560007     	cmp	r6, #7
   c409c: 03000001     	movweq	r0, #0x1
   c40a0: e58d004c     	str	r0, [sp, #0x4c]
   c40a4: e58d4038     	str	r4, [sp, #0x38]
   c40a8: e3a07009     	mov	r7, #9
   c40ac: eb00e7ff     	bl	0xfe0b0 <.text+0xedfb0> @ imm = #0x39ffc
   c40b0: e3500000     	cmp	r0, #0
   c40b4: e3a00009     	mov	r0, #9
   c40b8: e58d0054     	str	r0, [sp, #0x54]
   c40bc: 1a000006     	bne	0xc40dc <.text+0xb3fdc> @ imm = #0x18
   c40c0: e59d004c     	ldr	r0, [sp, #0x4c]
   c40c4: e3a0100b     	mov	r1, #11
   c40c8: e3500001     	cmp	r0, #1
   c40cc: 0300100a     	movweq	r1, #0xa
   c40d0: e3500000     	cmp	r0, #0
   c40d4: 03001009     	movweq	r1, #0x9
   c40d8: e58d1054     	str	r1, [sp, #0x54]

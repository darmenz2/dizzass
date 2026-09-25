
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  5a38a0: e92d4007     	push	{r0, r1, r2, lr}
  5a38a4: e58d0004     	str	r0, [sp, #0x4]
  5a38a8: eb000066     	bl	0x5a3a48 <.text+0x593948> @ imm = #0x198
  5a38ac: e2802001     	add	r2, r0, #1
  5a38b0: e1a00002     	mov	r0, r2
  5a38b4: e58d2000     	str	r2, [sp]
  5a38b8: ebffc20b     	bl	0x5940ec <.text+0x583fec> @ imm = #-0xf7d4
  5a38bc: e3500000     	cmp	r0, #0
  5a38c0: 0a000004     	beq	0x5a38d8 <.text+0x5937d8> @ imm = #0x10
  5a38c4: e59d2000     	ldr	r2, [sp]
  5a38c8: e59d1004     	ldr	r1, [sp, #0x4]
  5a38cc: e28dd00c     	add	sp, sp, #12
  5a38d0: e49de004     	ldr	lr, [sp], #4
  5a38d4: eafffd83     	b	0x5a2ee8 <.text+0x592de8> @ imm = #-0x9f4
  5a38d8: e28dd00c     	add	sp, sp, #12
  5a38dc: e49df004     	ldr	pc, [sp], #4

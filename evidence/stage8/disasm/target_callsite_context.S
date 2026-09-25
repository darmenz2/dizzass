
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   327b4: e79f9009     	ldr	r9, [pc, r9]
   327b8: e5990000     	ldr	r0, [r9]
   327bc: e12fff30     	blx	r0
   327c0: e2850e12     	add	r0, r5, #288
   327c4: e2851c01     	add	r1, r5, #256
   327c8: ebff7913     	bl	0x10c1c <.text+0xb1c>   @ imm = #-0x21bb4
   327cc: e1a01000     	mov	r1, r0
   327d0: e3a00000     	mov	r0, #0
   327d4: e3510000     	cmp	r1, #0
   327d8: 0a000169     	beq	0x32d84 <.text+0x22c84> @ imm = #0x5a4

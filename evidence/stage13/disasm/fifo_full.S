
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d1bb0: e5901010     	ldr	r1, [r0, #0x10]
   d1bb4: e5900014     	ldr	r0, [r0, #0x14]
   d1bb8: e0400001     	sub	r0, r0, r1
   d1bbc: e16f0f10     	clz	r0, r0
   d1bc0: e1a002a0     	lsr	r0, r0, #5
   d1bc4: e12fff1e     	bx	lr

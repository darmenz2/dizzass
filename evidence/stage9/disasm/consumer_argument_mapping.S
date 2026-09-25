
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   74f14: e59d2024     	ldr	r2, [sp, #0x24]
   74f18: e59d0054     	ldr	r0, [sp, #0x54]
   74f1c: e59d1060     	ldr	r1, [sp, #0x60]
   74f20: e1c220d0     	ldrd	r2, r3, [r2]
   74f24: e6bf0f30     	rev	r0, r0
   74f28: e58d2008     	str	r2, [sp, #0x8]
   74f2c: e2842d0a     	add	r2, r4, #640
   74f30: e59d4028     	ldr	r4, [sp, #0x28]
   74f34: e58d1000     	str	r1, [sp]
   74f38: e24b1020     	sub	r1, r11, #32
   74f3c: e58d300c     	str	r3, [sp, #0xc]
   74f40: e1a0300a     	mov	r3, r10
   74f44: e58d0010     	str	r0, [sp, #0x10]
   74f48: e1a00004     	mov	r0, r4
   74f4c: ebfeec56     	bl	0x300ac <.text+0x1ffac> @ imm = #-0x44ea8

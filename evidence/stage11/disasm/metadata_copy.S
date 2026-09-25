
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   30a6c: ed990bea     	vldr	d0, [r9, #936]
   30a70: ed840b68     	vstr	d0, [r4, #416]
   30a74: e59903d0     	ldr	r0, [r9, #0x3d0]
   30a78: eb15cb88     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572e20
   30a7c: e584018c     	str	r0, [r4, #0x18c]
   30a80: e59903ec     	ldr	r0, [r9, #0x3ec]
   30a84: eb15cb85     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572e14
   30a88: e58401a8     	str	r0, [r4, #0x1a8]
   30a8c: e3000396     	movw	r0, #0x396
   30a90: e0890000     	add	r0, r9, r0
   30a94: eb15cb81     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572e04
   30a98: e584019c     	str	r0, [r4, #0x19c]

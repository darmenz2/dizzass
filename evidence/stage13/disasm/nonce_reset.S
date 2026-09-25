
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fa944: e92d4c10     	push	{r4, r10, r11, lr}
   fa948: e28db008     	add	r11, sp, #8
   fa94c: e59f4020     	ldr	r4, [pc, #0x20]         @ 0xfa974 <.text+0xea874>
   fa950: e08f4004     	add	r4, pc, r4
   fa954: e1a00004     	mov	r0, r4
   fa958: eb12adea     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4ab7a8
   fa95c: e59f0014     	ldr	r0, [pc, #0x14]         @ 0xfa978 <.text+0xea878>
   fa960: e08f0000     	add	r0, pc, r0
   fa964: ebff5df0     	bl	0xd212c <.text+0xc202c> @ imm = #-0x28840
   fa968: e1a00004     	mov	r0, r4
   fa96c: e8bd4c10     	pop	{r4, r10, r11, lr}
   fa970: ea12af53     	b	0x5a66c4 <.text+0x5965c4> @ imm = #0x4abd4c
   fa974: 0055a178     	subseq	r10, r5, r8, ror r1
   fa978: 0055a180     	subseq	r10, r5, r0, lsl #3

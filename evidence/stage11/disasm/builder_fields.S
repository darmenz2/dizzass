
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   30d90: e3a00053     	mov	r0, #83
   30d94: e3a0203c     	mov	r2, #60
   30d98: e5c40250     	strb	r0, [r4, #0x250]
   30d9c: e3a00000     	mov	r0, #0
   30da0: e584916c     	str	r9, [r4, #0x16c]
   30da4: e59f1500     	ldr	r1, [pc, #0x500]        @ 0x312ac <.text+0x211ac>
   30da8: e79f1001     	ldr	r1, [pc, r1]
   30dac: e584215c     	str	r2, [r4, #0x15c]
   30db0: e5840160     	str	r0, [r4, #0x160]
   30db4: e58411b8     	str	r1, [r4, #0x1b8]

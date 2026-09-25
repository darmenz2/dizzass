
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c4d90: e59f42cc     	ldr	r4, [pc, #0x2cc]        @ 0xc5064 <.text+0xb4f64>
   c4d94: e3a000a8     	mov	r0, #168
   c4d98: e1a01009     	mov	r1, r9
   c4d9c: e3a020a8     	mov	r2, #168
   c4da0: e79f4004     	ldr	r4, [pc, r4]
   c4da4: e59f82bc     	ldr	r8, [pc, #0x2bc]        @ 0xc5068 <.text+0xb4f68>
   c4da8: e08f8008     	add	r8, pc, r8
   c4dac: e0208094     	mla	r0, r4, r0, r8
   c4db0: e2806008     	add	r6, r0, #8
   c4db4: e1a00006     	mov	r0, r6
   c4db8: eb13784a     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4de128
   c4dbc: e59f02a8     	ldr	r0, [pc, #0x2a8]        @ 0xc506c <.text+0xb4f6c>
   c4dc0: e79f0000     	ldr	r0, [pc, r0]
   c4dc4: e2800001     	add	r0, r0, #1
   c4dc8: e350001f     	cmp	r0, #31
   c4dcc: 83000000     	movwhi	r0, #0x0
   c4dd0: e5880000     	str	r0, [r8]
   c4dd4: e1a00007     	mov	r0, r7

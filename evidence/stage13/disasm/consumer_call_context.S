
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   74da8: e5d9017c     	ldrb	r0, [r9, #0x17c]
   74dac: e3500000     	cmp	r0, #0
   74db0: 1a000162     	bne	0x75340 <.text+0x65240> @ imm = #0x588
   74db4: e28d0040     	add	r0, sp, #64
   74db8: eb021648     	bl	0xfa6e0 <.text+0xea5e0> @ imm = #0x85920
   74dbc: e59d003c     	ldr	r0, [sp, #0x3c]
   74dc0: e5d00000     	ldrb	r0, [r0]
   74dc4: e3500000     	cmp	r0, #0
   74dc8: 0a000003     	beq	0x74ddc <.text+0x64cdc> @ imm = #0xc
   74dcc: ebfed4ce     	bl	0x2a10c <.text+0x1a00c> @ imm = #-0x4acc8
   74dd0: ebfed5e2     	bl	0x2a560 <.text+0x1a460> @ imm = #-0x4a878
   74dd4: e3500000     	cmp	r0, #0
   74dd8: 1a00002d     	bne	0x74e94 <.text+0x64d94> @ imm = #0xb4

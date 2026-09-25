
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   34d54: e92d4830     	push	{r4, r5, r11, lr}
   34d58: e28db008     	add	r11, sp, #8
   34d5c: e1a05000     	mov	r5, r0
   34d60: e59f0060     	ldr	r0, [pc, #0x60]         @ 0x34dc8 <.text+0x24cc8>
   34d64: e79f0000     	ldr	r0, [pc, r0]
   34d68: eb15c4e6     	bl	0x5a6108 <.text+0x596008> @ imm = #0x571398
   34d6c: e59f0058     	ldr	r0, [pc, #0x58]         @ 0x34dcc <.text+0x24ccc>
   34d70: e3a04001     	mov	r4, #1
   34d74: e79f0000     	ldr	r0, [pc, r0]
   34d78: e5900000     	ldr	r0, [r0]
   34d7c: e3500001     	cmp	r0, #1
   34d80: ba00000b     	blt	0x34db4 <.text+0x24cb4> @ imm = #0x2c
   34d84: e59f1044     	ldr	r1, [pc, #0x44]         @ 0x34dd0 <.text+0x24cd0>
   34d88: e3a02000     	mov	r2, #0
   34d8c: e79f1001     	ldr	r1, [pc, r1]
   34d90: e5911000     	ldr	r1, [r1]
   34d94: e7913102     	ldr	r3, [r1, r2, lsl #2]
   34d98: e1530005     	cmp	r3, r5
   34d9c: 0a000003     	beq	0x34db0 <.text+0x24cb0> @ imm = #0xc
   34da0: e2822001     	add	r2, r2, #1
   34da4: e1520000     	cmp	r2, r0
   34da8: bafffff9     	blt	0x34d94 <.text+0x24c94> @ imm = #-0x1c
   34dac: ea000000     	b	0x34db4 <.text+0x24cb4> @ imm = #0x0
   34db0: e3a04000     	mov	r4, #0
   34db4: e59f0018     	ldr	r0, [pc, #0x18]         @ 0x34dd4 <.text+0x24cd4>
   34db8: e79f0000     	ldr	r0, [pc, r0]
   34dbc: eb15c640     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x571900
   34dc0: e1a00004     	mov	r0, r4
   34dc4: e8bd8830     	pop	{r4, r5, r11, pc}
   34dc8: 005aacf8     	ldrsheq	r10, [r10], #-200
   34dcc: 005a9c2c     	subseq	r9, r10, r12, lsr #24
   34dd0: 005aa164     	subseq	r10, r10, r4, ror #2
   34dd4: 005aaca4     	subseq	r10, r10, r4, lsr #25

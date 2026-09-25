
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fa5a4: e92d4800     	push	{r11, lr}
   fa5a8: e1a0b00d     	mov	r11, sp
   fa5ac: e59f0024     	ldr	r0, [pc, #0x24]         @ 0xfa5d8 <.text+0xea4d8>
   fa5b0: e3a01000     	mov	r1, #0
   fa5b4: e08f0000     	add	r0, pc, r0
   fa5b8: eb12aec7     	bl	0x5a60dc <.text+0x595fdc> @ imm = #0x4abb1c
   fa5bc: e59f0018     	ldr	r0, [pc, #0x18]         @ 0xfa5dc <.text+0xea4dc>
   fa5c0: e3a01a01     	mov	r1, #4096
   fa5c4: e3a02048     	mov	r2, #72
   fa5c8: e08f0000     	add	r0, pc, r0
   fa5cc: ebff5cf7     	bl	0xd19b0 <.text+0xc18b0> @ imm = #-0x28c24
   fa5d0: e3a00000     	mov	r0, #0
   fa5d4: e8bd8800     	pop	{r11, pc}
   fa5d8: 0055a514     	subseq	r10, r5, r4, lsl r5
   fa5dc: 0055a518     	subseq	r10, r5, r8, lsl r5

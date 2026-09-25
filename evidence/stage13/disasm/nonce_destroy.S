
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fa97c: e92d4830     	push	{r4, r5, r11, lr}
   fa980: e28db008     	add	r11, sp, #8
   fa984: e59f4080     	ldr	r4, [pc, #0x80]         @ 0xfaa0c <.text+0xea90c>
   fa988: e79f4004     	ldr	r4, [pc, r4]
   fa98c: e5940000     	ldr	r0, [r4]
   fa990: e59f5078     	ldr	r5, [pc, #0x78]         @ 0xfaa10 <.text+0xea910>
   fa994: e2401001     	sub	r1, r0, #1
   fa998: e0000190     	mul	r0, r0, r1
   fa99c: e79f5005     	ldr	r5, [pc, r5]
   fa9a0: e3100001     	tst	r0, #1
   fa9a4: 0a000002     	beq	0xfa9b4 <.text+0xea8b4> @ imm = #0x8
   fa9a8: e5950000     	ldr	r0, [r5]
   fa9ac: e3500009     	cmp	r0, #9
   fa9b0: ca00000d     	bgt	0xfa9ec <.text+0xea8ec> @ imm = #0x34
   fa9b4: e59f0058     	ldr	r0, [pc, #0x58]         @ 0xfaa14 <.text+0xea914>
   fa9b8: e08f0000     	add	r0, pc, r0
   fa9bc: ebff5de0     	bl	0xd2144 <.text+0xc2044> @ imm = #-0x28880
   fa9c0: e59f0050     	ldr	r0, [pc, #0x50]         @ 0xfaa18 <.text+0xea918>
   fa9c4: e08f0000     	add	r0, pc, r0
   fa9c8: eb12adba     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x4ab6e8
   fa9cc: e5940000     	ldr	r0, [r4]
   fa9d0: e2401001     	sub	r1, r0, #1
   fa9d4: e0000190     	mul	r0, r0, r1
   fa9d8: e3100001     	tst	r0, #1
   fa9dc: 0a000009     	beq	0xfaa08 <.text+0xea908> @ imm = #0x24
   fa9e0: e5950000     	ldr	r0, [r5]
   fa9e4: e3500009     	cmp	r0, #9
   fa9e8: da000006     	ble	0xfaa08 <.text+0xea908> @ imm = #0x18
   fa9ec: e59f0028     	ldr	r0, [pc, #0x28]         @ 0xfaa1c <.text+0xea91c>
   fa9f0: e08f0000     	add	r0, pc, r0
   fa9f4: ebff5dd2     	bl	0xd2144 <.text+0xc2044> @ imm = #-0x288b8
   fa9f8: e59f0020     	ldr	r0, [pc, #0x20]         @ 0xfaa20 <.text+0xea920>
   fa9fc: e08f0000     	add	r0, pc, r0
   faa00: eb12adac     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x4ab6b0
   faa04: eaffffea     	b	0xfa9b4 <.text+0xea8b4> @ imm = #-0x58
   faa08: e8bd8830     	pop	{r4, r5, r11, pc}
   faa0c: 004e4ac8     	subeq	r4, lr, r8, asr #21
   faa10: 004e4174     	subeq	r4, lr, r4, ror r1
   faa14: 0055a128     	subseq	r10, r5, r8, lsr #2
   faa18: 0055a104     	subseq	r10, r5, r4, lsl #2
   faa1c: 0055a0f0     	ldrsheq	r10, [r5], #-0
   faa20: 0055a0cc     	subseq	r10, r5, r12, asr #1


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d2090: eaffffed     	b	0xd204c <.text+0xc1f4c> @ imm = #-0x4c
   d2094: e3a07000     	mov	r7, #0
   d2098: e1a00007     	mov	r0, r7
   d209c: e24bd01c     	sub	sp, r11, #28
   d20a0: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   d20a4: 0050e080     	subseq	lr, r0, r0, lsl #1
   d20a8: 0050d6f0     	ldrsheq	sp, [r0], #-96
   d20ac: e5900014     	ldr	r0, [r0, #0x14]
   d20b0: e12fff1e     	bx	lr
   d20b4: e92d4800     	push	{r11, lr}
   d20b8: e1a0b00d     	mov	r11, sp
   d20bc: e59f2060     	ldr	r2, [pc, #0x60]         @ 0xd2124 <.text+0xc2024>
   d20c0: e79f2002     	ldr	r2, [pc, r2]
   d20c4: e5921000     	ldr	r1, [r2]
   d20c8: e2413001     	sub	r3, r1, #1
   d20cc: e0010391     	mul	r1, r1, r3
   d20d0: e3110001     	tst	r1, #1
   d20d4: e5921000     	ldr	r1, [r2]
   d20d8: e2413001     	sub	r3, r1, #1
   d20dc: e0030391     	mul	r3, r1, r3
   d20e0: e5901018     	ldr	r1, [r0, #0x18]
   d20e4: e3130001     	tst	r3, #1
   d20e8: 0a000004     	beq	0xd2100 <.text+0xc2000> @ imm = #0x10
   d20ec: e59f3034     	ldr	r3, [pc, #0x34]         @ 0xd2128 <.text+0xc2028>
   d20f0: e79f3003     	ldr	r3, [pc, r3]
   d20f4: e5933000     	ldr	r3, [r3]
   d20f8: e3530009     	cmp	r3, #9
   d20fc: cafffff4     	bgt	0xd20d4 <.text+0xc1fd4> @ imm = #-0x30

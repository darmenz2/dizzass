
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ed974: e92d4c10     	push	{r4, r10, r11, lr}
   ed978: e28db008     	add	r11, sp, #8
   ed97c: e1a04000     	mov	r4, r0
   ed980: eb004191     	bl	0xfdfcc <.text+0xedecc> @ imm = #0x10644
   ed984: e1a01000     	mov	r1, r0
   ed988: e3010398     	movw	r0, #0x1398
   ed98c: e1510000     	cmp	r1, r0
   ed990: 0a000007     	beq	0xed9b4 <.text+0xdd8b4> @ imm = #0x1c
   ed994: e3012397     	movw	r2, #0x1397
   ed998: e3a00000     	mov	r0, #0
   ed99c: e1510002     	cmp	r1, r2
   ed9a0: 1a000004     	bne	0xed9b8 <.text+0xdd8b8> @ imm = #0x10
   ed9a4: e30003fe     	movw	r0, #0x3fe
   ed9a8: e0000aa4     	and	r0, r0, r4, lsr #21
   ed9ac: e1800fa4     	orr	r0, r0, r4, lsr #31
   ed9b0: e8bd8c10     	pop	{r4, r10, r11, pc}
   ed9b4: e1a00c24     	lsr	r0, r4, #24
   ed9b8: e8bd8c10     	pop	{r4, r10, r11, pc}

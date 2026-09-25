
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   2a560: e92d4800     	push	{r11, lr}
   2a564: e1a0b00d     	mov	r11, sp
   2a568: e59021fc     	ldr	r2, [r0, #0x1fc]
   2a56c: e1a01000     	mov	r1, r0
   2a570: e3a00001     	mov	r0, #1
   2a574: e3520001     	cmp	r2, #1
   2a578: 18bd8800     	popne	{r11, pc}
   2a57c: e59fe06c     	ldr	lr, [pc, #0x6c]         @ 0x2a5f0 <.text+0x1a4f0>
   2a580: e79fe00e     	ldr	lr, [pc, lr]
   2a584: e59ec000     	ldr	r12, [lr]
   2a588: e24c3001     	sub	r3, r12, #1
   2a58c: e003039c     	mul	r3, r12, r3
   2a590: e3130001     	tst	r3, #1
   2a594: e59e3000     	ldr	r3, [lr]
   2a598: e2432001     	sub	r2, r3, #1
   2a59c: e0020293     	mul	r2, r3, r2
   2a5a0: e5d133fc     	ldrb	r3, [r1, #0x3fc]
   2a5a4: e3120001     	tst	r2, #1
   2a5a8: 0a000004     	beq	0x2a5c0 <.text+0x1a4c0> @ imm = #0x10
   2a5ac: e59f2040     	ldr	r2, [pc, #0x40]         @ 0x2a5f4 <.text+0x1a4f4>
   2a5b0: e79f2002     	ldr	r2, [pc, r2]
   2a5b4: e5922000     	ldr	r2, [r2]
   2a5b8: e3520009     	cmp	r2, #9
   2a5bc: cafffff4     	bgt	0x2a594 <.text+0x1a494> @ imm = #-0x30
   2a5c0: e3530000     	cmp	r3, #0
   2a5c4: 0a000004     	beq	0x2a5dc <.text+0x1a4dc> @ imm = #0x10
   2a5c8: e5d123fe     	ldrb	r2, [r1, #0x3fe]
   2a5cc: e3520000     	cmp	r2, #0
   2a5d0: 15d12209     	ldrbne	r2, [r1, #0x209]
   2a5d4: 13520000     	cmpne	r2, #0
   2a5d8: 1a000000     	bne	0x2a5e0 <.text+0x1a4e0> @ imm = #0x0
   2a5dc: e8bd8800     	pop	{r11, pc}
   2a5e0: e5d101ea     	ldrb	r0, [r1, #0x1ea]
   2a5e4: e3500000     	cmp	r0, #0
   2a5e8: 13000001     	movwne	r0, #0x1
   2a5ec: e8bd8800     	pop	{r11, pc}
   2a5f0: 005b5a34     	subseq	r5, r11, r4, lsr r10
   2a5f4: 005b4cb8     	ldrheq	r4, [r11], #-200

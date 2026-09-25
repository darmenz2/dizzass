
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   f7f10: e3510000     	cmp	r1, #0
   f7f14: 0a00002e     	beq	0xf7fd4 <.text+0xe7ed4> @ imm = #0xb8
   f7f18: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   f7f1c: e28db01c     	add	r11, sp, #28
   f7f20: e24dd004     	sub	sp, sp, #4
   f7f24: e3a0c080     	mov	r12, #128
   f7f28: e3a02000     	mov	r2, #0
   f7f2c: e3a03001     	mov	r3, #1
   f7f30: e3a08001     	mov	r8, #1
   f7f34: e3a05001     	mov	r5, #1
   f7f38: e3a0e001     	mov	lr, #1
   f7f3c: e3a07001     	mov	r7, #1
   f7f40: e1a0a00e     	mov	r10, lr
   f7f44: e1a0e005     	mov	lr, r5
   f7f48: e58d3000     	str	r3, [sp]
   f7f4c: e1a03000     	mov	r3, r0
   f7f50: e2825001     	add	r5, r2, #1
   f7f54: e4d39001     	ldrb	r9, [r3], #1
   f7f58: e7e660dc     	ubfx	r6, r12, #0x1, #0x7
   f7f5c: e6ef4075     	uxtb	r4, r5
   f7f60: e3540008     	cmp	r4, #8
   f7f64: 01a00003     	moveq	r0, r3
   f7f68: e2542008     	subs	r2, r4, #8
   f7f6c: 11a02005     	movne	r2, r5
   f7f70: e3540008     	cmp	r4, #8
   f7f74: 03006080     	movweq	r6, #0x80
   f7f78: e01c3009     	ands	r3, r12, r9
   f7f7c: 13003001     	movwne	r3, #0x1
   f7f80: e59d4000     	ldr	r4, [sp]
   f7f84: e0273003     	eor	r3, r7, r3
   f7f88: e2511001     	subs	r1, r1, #1
   f7f8c: e0235008     	eor	r5, r3, r8
   f7f90: e1a0700a     	mov	r7, r10
   f7f94: e1a08004     	mov	r8, r4
   f7f98: e1a0c006     	mov	r12, r6
   f7f9c: 1affffe7     	bne	0xf7f40 <.text+0xe7e40> @ imm = #-0x64
   f7fa0: e6ef0073     	uxtb	r0, r3
   f7fa4: e3500000     	cmp	r0, #0
   f7fa8: 13000001     	movwne	r0, #0x1
   f7fac: e6ef107a     	uxtb	r1, r10
   f7fb0: e3510000     	cmp	r1, #0
   f7fb4: 13001001     	movwne	r1, #0x1
   f7fb8: e31e00ff     	tst	lr, #255
   f7fbc: e1a01201     	lsl	r1, r1, #4
   f7fc0: 0a000007     	beq	0xf7fe4 <.text+0xe7ee4> @ imm = #0x1c
   f7fc4: e31500ff     	tst	r5, #255
   f7fc8: 0a000009     	beq	0xf7ff4 <.text+0xe7ef4> @ imm = #0x24
   f7fcc: e381100c     	orr	r1, r1, #12
   f7fd0: ea000014     	b	0xf8028 <.text+0xe7f28> @ imm = #0x50
   f7fd4: e3a00001     	mov	r0, #1
   f7fd8: e3a0101e     	mov	r1, #30
   f7fdc: e1810000     	orr	r0, r1, r0
   f7fe0: e12fff1e     	bx	lr
   f7fe4: e31500ff     	tst	r5, #255
   f7fe8: 0a000002     	beq	0xf7ff8 <.text+0xe7ef8> @ imm = #0x8
   f7fec: e3811004     	orr	r1, r1, #4
   f7ff0: ea00000c     	b	0xf8028 <.text+0xe7f28> @ imm = #0x30
   f7ff4: e3811008     	orr	r1, r1, #8
   f7ff8: e59f2040     	ldr	r2, [pc, #0x40]         @ 0xf8040 <.text+0xe7f40>
   f7ffc: e79f2002     	ldr	r2, [pc, r2]
   f8000: e59f303c     	ldr	r3, [pc, #0x3c]         @ 0xf8044 <.text+0xe7f44>
   f8004: e79f3003     	ldr	r3, [pc, r3]
   f8008: e5927000     	ldr	r7, [r2]
   f800c: e2476001     	sub	r6, r7, #1
   f8010: e0070697     	mul	r7, r7, r6
   f8014: e3170001     	tst	r7, #1
   f8018: 0a000002     	beq	0xf8028 <.text+0xe7f28> @ imm = #0x8
   f801c: e5937000     	ldr	r7, [r3]
   f8020: e3570009     	cmp	r7, #9
   f8024: cafffff7     	bgt	0xf8008 <.text+0xe7f08> @ imm = #-0x24
   f8028: e31400ff     	tst	r4, #255
   f802c: 13811002     	orrne	r1, r1, #2
   f8030: e24bd01c     	sub	sp, r11, #28
   f8034: e8bd4ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   f8038: e1810000     	orr	r0, r1, r0
   f803c: e12fff1e     	bx	lr
   f8040: 004e6e28     	subeq	r6, lr, r8, lsr #28
   f8044: 004e7394     	umaaleq	r7, lr, r4, r3

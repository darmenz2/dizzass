
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d26ac: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   d26b0: e28db018     	add	r11, sp, #24
   d26b4: e59f8094     	ldr	r8, [pc, #0x94]         @ 0xd2750 <.text+0xc2650>
   d26b8: e1a06000     	mov	r6, r0
   d26bc: e1a05001     	mov	r5, r1
   d26c0: e1a04002     	mov	r4, r2
   d26c4: e79f8008     	ldr	r8, [pc, r8]
   d26c8: e5980000     	ldr	r0, [r8]
   d26cc: e59f7080     	ldr	r7, [pc, #0x80]         @ 0xd2754 <.text+0xc2654>
   d26d0: e2401001     	sub	r1, r0, #1
   d26d4: e0000190     	mul	r0, r0, r1
   d26d8: e79f7007     	ldr	r7, [pc, r7]
   d26dc: e3100001     	tst	r0, #1
   d26e0: 0a000002     	beq	0xd26f0 <.text+0xc25f0> @ imm = #0x8
   d26e4: e5970000     	ldr	r0, [r7]
   d26e8: e3500009     	cmp	r0, #9
   d26ec: ca00000e     	bgt	0xd272c <.text+0xc262c> @ imm = #0x38
   d26f0: e59f0060     	ldr	r0, [pc, #0x60]         @ 0xd2758 <.text+0xc2658>
   d26f4: e1a01005     	mov	r1, r5
   d26f8: e1a02004     	mov	r2, r4
   d26fc: e79f0000     	ldr	r0, [pc, r0]
   d2700: e5903018     	ldr	r3, [r0, #0x18]
   d2704: e1a00006     	mov	r0, r6
   d2708: e12fff33     	blx	r3
   d270c: e5981000     	ldr	r1, [r8]
   d2710: e2412001     	sub	r2, r1, #1
   d2714: e0010291     	mul	r1, r1, r2
   d2718: e3110001     	tst	r1, #1
   d271c: 0a00000a     	beq	0xd274c <.text+0xc264c> @ imm = #0x28
   d2720: e5971000     	ldr	r1, [r7]
   d2724: e3510009     	cmp	r1, #9
   d2728: da000007     	ble	0xd274c <.text+0xc264c> @ imm = #0x1c
   d272c: e59f0028     	ldr	r0, [pc, #0x28]         @ 0xd275c <.text+0xc265c>
   d2730: e1a01005     	mov	r1, r5
   d2734: e1a02004     	mov	r2, r4
   d2738: e79f0000     	ldr	r0, [pc, r0]
   d273c: e5903018     	ldr	r3, [r0, #0x18]
   d2740: e1a00006     	mov	r0, r6
   d2744: e12fff33     	blx	r3
   d2748: eaffffe8     	b	0xd26f0 <.text+0xc25f0> @ imm = #-0x60
   d274c: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   d2750: 0050c64c     	subseq	r12, r0, r12, asr #12
   d2754: 0050bfd0     	ldrsbeq	r11, [r0], #-240
   d2758: 0050cd50     	subseq	r12, r0, r0, asr sp
   d275c: 0050cd14     	subseq	r12, r0, r4, lsl sp


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c36e8: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   c36ec: e28db01c     	add	r11, sp, #28
   c36f0: e24dd00c     	sub	sp, sp, #12
   c36f4: e59f6288     	ldr	r6, [pc, #0x288]        @ 0xc3984 <.text+0xb3884>
   c36f8: e1a08000     	mov	r8, r0
   c36fc: e79f6006     	ldr	r6, [pc, r6]
   c3700: e5960000     	ldr	r0, [r6]
   c3704: e2401001     	sub	r1, r0, #1
   c3708: e0000190     	mul	r0, r0, r1
   c370c: e3100001     	tst	r0, #1
   c3710: 0a000004     	beq	0xc3728 <.text+0xb3628> @ imm = #0x10
   c3714: e59f026c     	ldr	r0, [pc, #0x26c]        @ 0xc3988 <.text+0xb3888>
   c3718: e79f0000     	ldr	r0, [pc, r0]
   c371c: e5900000     	ldr	r0, [r0]
   c3720: e3500009     	cmp	r0, #9
   c3724: ca000012     	bgt	0xc3774 <.text+0xb3674> @ imm = #0x48
   c3728: e24d5c01     	sub	r5, sp, #256
   c372c: e1a0d005     	mov	sp, r5
   c3730: e24d4040     	sub	r4, sp, #64
   c3734: e1a0d004     	mov	sp, r4
   c3738: e24d9008     	sub	r9, sp, #8
   c373c: e1a0d009     	mov	sp, r9
   c3740: eb00ea1d     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x3a874
   c3744: e1a07000     	mov	r7, r0
   c3748: eb00ea17     	bl	0xfdfac <.text+0xedeac> @ imm = #0x3a85c
   c374c: e5961000     	ldr	r1, [r6]
   c3750: e2412001     	sub	r2, r1, #1
   c3754: e0010291     	mul	r1, r1, r2
   c3758: e3110001     	tst	r1, #1
   c375c: 0a00000a     	beq	0xc378c <.text+0xb368c> @ imm = #0x28
   c3760: e59f1224     	ldr	r1, [pc, #0x224]        @ 0xc398c <.text+0xb388c>
   c3764: e79f1001     	ldr	r1, [pc, r1]
   c3768: e5911000     	ldr	r1, [r1]
   c376c: e3510009     	cmp	r1, #9
   c3770: da000005     	ble	0xc378c <.text+0xb368c> @ imm = #0x14
   c3774: e24ddc01     	sub	sp, sp, #256
   c3778: e24dd040     	sub	sp, sp, #64
   c377c: e24dd008     	sub	sp, sp, #8
   c3780: eb00ea0d     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x3a834
   c3784: eb00ea08     	bl	0xfdfac <.text+0xedeac> @ imm = #0x3a820
   c3788: eaffffe6     	b	0xc3728 <.text+0xb3628> @ imm = #-0x68
   c378c: e3a06000     	mov	r6, #0
   c3790: e3500000     	cmp	r0, #0
   c3794: 0a000005     	beq	0xc37b0 <.text+0xb36b0> @ imm = #0x14
   c3798: e3570006     	cmp	r7, #6
   c379c: 03500004     	cmpeq	r0, #4
   c37a0: 0a000002     	beq	0xc37b0 <.text+0xb36b0> @ imm = #0x8
   c37a4: e3a06002     	mov	r6, #2
   c37a8: e3570007     	cmp	r7, #7
   c37ac: 03006001     	movweq	r6, #0x1
   c37b0: e3a00009     	mov	r0, #9
   c37b4: e50b0028     	str	r0, [r11, #-0x28]
   c37b8: eb00ea3c     	bl	0xfe0b0 <.text+0xedfb0> @ imm = #0x3a8f0
   c37bc: e3500000     	cmp	r0, #0
   c37c0: 1a000005     	bne	0xc37dc <.text+0xb36dc> @ imm = #0x14
   c37c4: e3a0000b     	mov	r0, #11
   c37c8: e3560001     	cmp	r6, #1
   c37cc: 0300000a     	movweq	r0, #0xa
   c37d0: e3560000     	cmp	r6, #0
   c37d4: 03000009     	movweq	r0, #0x9
   c37d8: e50b0028     	str	r0, [r11, #-0x28]


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fa6e0: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   fa6e4: e28db018     	add	r11, sp, #24
   fa6e8: e59f80ac     	ldr	r8, [pc, #0xac]         @ 0xfa79c <.text+0xea69c>
   fa6ec: e1a04000     	mov	r4, r0
   fa6f0: e79f8008     	ldr	r8, [pc, r8]
   fa6f4: e5980000     	ldr	r0, [r8]
   fa6f8: e59f70a0     	ldr	r7, [pc, #0xa0]         @ 0xfa7a0 <.text+0xea6a0>
   fa6fc: e2401001     	sub	r1, r0, #1
   fa700: e0000190     	mul	r0, r0, r1
   fa704: e79f7007     	ldr	r7, [pc, r7]
   fa708: e3100001     	tst	r0, #1
   fa70c: 0a000002     	beq	0xfa71c <.text+0xea61c> @ imm = #0x8
   fa710: e5970000     	ldr	r0, [r7]
   fa714: e3500009     	cmp	r0, #9
   fa718: ca000012     	bgt	0xfa768 <.text+0xea668> @ imm = #0x48
   fa71c: e59f6080     	ldr	r6, [pc, #0x80]         @ 0xfa7a4 <.text+0xea6a4>
   fa720: e08f6006     	add	r6, pc, r6
   fa724: e1a00006     	mov	r0, r6
   fa728: eb12ae76     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4ab9d8
   fa72c: e59f0074     	ldr	r0, [pc, #0x74]         @ 0xfa7a8 <.text+0xea6a8>
   fa730: e1a01004     	mov	r1, r4
   fa734: e08f0000     	add	r0, pc, r0
   fa738: ebff5dac     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #-0x28950
   fa73c: e1a05000     	mov	r5, r0
   fa740: e1a00006     	mov	r0, r6
   fa744: eb12afde     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4abf78
   fa748: e5980000     	ldr	r0, [r8]
   fa74c: e2401001     	sub	r1, r0, #1
   fa750: e0000190     	mul	r0, r0, r1
   fa754: e3100001     	tst	r0, #1
   fa758: 0a00000d     	beq	0xfa794 <.text+0xea694> @ imm = #0x34
   fa75c: e5970000     	ldr	r0, [r7]
   fa760: e3500009     	cmp	r0, #9
   fa764: da00000a     	ble	0xfa794 <.text+0xea694> @ imm = #0x28
   fa768: e59f503c     	ldr	r5, [pc, #0x3c]         @ 0xfa7ac <.text+0xea6ac>
   fa76c: e08f5005     	add	r5, pc, r5
   fa770: e1a00005     	mov	r0, r5
   fa774: eb12ae63     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4ab98c
   fa778: e59f0030     	ldr	r0, [pc, #0x30]         @ 0xfa7b0 <.text+0xea6b0>
   fa77c: e1a01004     	mov	r1, r4
   fa780: e08f0000     	add	r0, pc, r0
   fa784: ebff5d99     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #-0x2899c
   fa788: e1a00005     	mov	r0, r5
   fa78c: eb12afcc     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4abf30
   fa790: eaffffe1     	b	0xfa71c <.text+0xea61c> @ imm = #-0x7c
   fa794: e1a00005     	mov	r0, r5
   fa798: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   fa79c: 004e4c58     	subeq	r4, lr, r8, asr r12
   fa7a0: 004e52a0     	subeq	r5, lr, r0, lsr #5
   fa7a4: 0055a3a8     	subseq	r10, r5, r8, lsr #7
   fa7a8: 0055a3ac     	subseq	r10, r5, r12, lsr #7
   fa7ac: 0055a35c     	subseq	r10, r5, r12, asr r3
   fa7b0: 0055a360     	subseq	r10, r5, r0, ror #6


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   aa600: e58d7000     	str	r7, [sp]
   aa604: e3003166     	movw	r3, #0x166
   aa608: eafffb69     	b	0xa93b4 <.text+0x992b4> @ imm = #-0x125c
   aa60c: 0053e8cf     	subseq	lr, r3, pc, asr #17
   aa610: 0053e8ce     	subseq	lr, r3, lr, asr #17
   aa614: 0053e8e9     	subseq	lr, r3, r9, ror #17
   aa618: 0053e98a     	subseq	lr, r3, r10, lsl #19
   aa61c: e59f0fdc     	ldr	r0, [pc, #0xfdc]        @ 0xab600 <.text+0x9b500>
   aa620: e79f0000     	ldr	r0, [pc, r0]
   aa624: e5900000     	ldr	r0, [r0]
   aa628: e59f4fd4     	ldr	r4, [pc, #0xfd4]        @ 0xab604 <.text+0x9b504>
   aa62c: e2401001     	sub	r1, r0, #1
   aa630: e51b9028     	ldr	r9, [r11, #-0x28]
   aa634: e08f4004     	add	r4, pc, r4
   aa638: e0000190     	mul	r0, r0, r1
   aa63c: e3100001     	tst	r0, #1
   aa640: 0a00005a     	beq	0xaa7b0 <.text+0x9a6b0> @ imm = #0x168
   aa644: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0xab608 <.text+0x9b508>
   aa648: e79f0000     	ldr	r0, [pc, r0]
   aa64c: e5900000     	ldr	r0, [r0]
   aa650: e3500009     	cmp	r0, #9
   aa654: ca000071     	bgt	0xaa820 <.text+0x9a720> @ imm = #0x1c4
   aa658: ea000054     	b	0xaa7b0 <.text+0x9a6b0> @ imm = #0x150
   aa65c: 0053ee34     	subseq	lr, r3, r4, lsr lr
   aa660: e59f0ffc     	ldr	r0, [pc, #0xffc]        @ 0xab664 <.text+0x9b564>
   aa664: e59f1ffc     	ldr	r1, [pc, #0xffc]        @ 0xab668 <.text+0x9b568>
   aa668: e59f2ffc     	ldr	r2, [pc, #0xffc]        @ 0xab66c <.text+0x9b56c>
   aa66c: e08f0000     	add	r0, pc, r0
   aa670: e59f3ff8     	ldr	r3, [pc, #0xff8]        @ 0xab670 <.text+0x9b570>
   aa674: e08f1001     	add	r1, pc, r1
   aa678: e08f2002     	add	r2, pc, r2
   aa67c: e08f3003     	add	r3, pc, r3
   aa680: e24dd008     	sub	sp, sp, #8
   aa684: e3a07001     	mov	r7, #1
   aa688: e58d3004     	str	r3, [sp, #0x4]
   aa68c: e3a03fb1     	mov	r3, #708
   aa690: e58d7000     	str	r7, [sp]
   aa694: eb013e8a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x4fa28
   aa698: e28dd008     	add	sp, sp, #8
   aa69c: e3550000     	cmp	r5, #0
   aa6a0: 1affff5e     	bne	0xaa420 <.text+0x9a320> @ imm = #-0x288
   aa6a4: e59f0ffc     	ldr	r0, [pc, #0xffc]        @ 0xab6a8 <.text+0x9b5a8>
   aa6a8: e59f1ffc     	ldr	r1, [pc, #0xffc]        @ 0xab6ac <.text+0x9b5ac>
   aa6ac: e59f2ffc     	ldr	r2, [pc, #0xffc]        @ 0xab6b0 <.text+0x9b5b0>
   aa6b0: e08f0000     	add	r0, pc, r0
   aa6b4: e59f3ff8     	ldr	r3, [pc, #0xff8]        @ 0xab6b4 <.text+0x9b5b4>
   aa6b8: e08f1001     	add	r1, pc, r1
   aa6bc: e08f2002     	add	r2, pc, r2
   aa6c0: e08f3003     	add	r3, pc, r3
   aa6c4: e24dd008     	sub	sp, sp, #8
   aa6c8: e3a07001     	mov	r7, #1
   aa6cc: e58d3004     	str	r3, [sp, #0x4]
   aa6d0: e58d7000     	str	r7, [sp]
   aa6d4: e30035ea     	movw	r3, #0x5ea
   aa6d8: eafff8e6     	b	0xa8a78 <.text+0x98978> @ imm = #-0x1c68
   aa6dc: 005365f4     	ldrsheq	r6, [r3], #-84
   aa6e0: 00535c34     	subseq	r5, r3, r4, lsr r12
   aa6e4: 0053ed98     	<unknown>
   aa6e8: e51b0178     	ldr	r0, [r11, #-0x178]
   aa6ec: e51b117c     	ldr	r1, [r11, #-0x17c]
   aa6f0: e5900000     	ldr	r0, [r0]
   aa6f4: e5912000     	ldr	r2, [r1]
   aa6f8: e59f1fb8     	ldr	r1, [pc, #0xfb8]        @ 0xab6b8 <.text+0x9b5b8>
   aa6fc: e51b31ec     	ldr	r3, [r11, #-0x1ec]
   aa700: e08f1001     	add	r1, pc, r1
   aa704: e583008c     	str	r0, [r3, #0x8c]
   aa708: e51b0110     	ldr	r0, [r11, #-0x110]
   aa70c: e5832090     	str	r2, [r3, #0x90]
   aa710: e5904000     	ldr	r4, [r0]
   aa714: e1a00004     	mov	r0, r4
   aa718: eb13e3ba     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f8ee8
   aa71c: e3500000     	cmp	r0, #0
   aa720: 0a0002f2     	beq	0xab2f0 <.text+0x9b1f0> @ imm = #0xbc8
   aa724: e59f1f90     	ldr	r1, [pc, #0xf90]        @ 0xab6bc <.text+0x9b5bc>
   aa728: e1a00004     	mov	r0, r4
   aa72c: e08f1001     	add	r1, pc, r1
   aa730: eb13e3b4     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f8ed0
   aa734: e3500000     	cmp	r0, #0
   aa738: 0a000012     	beq	0xaa788 <.text+0x9a688> @ imm = #0x48
   aa73c: e59f1f7c     	ldr	r1, [pc, #0xf7c]        @ 0xab6c0 <.text+0x9b5c0>
   aa740: e1a00004     	mov	r0, r4
   aa744: e08f1001     	add	r1, pc, r1
   aa748: eb13e3ae     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f8eb8
   aa74c: e3500000     	cmp	r0, #0
   aa750: 0a00000e     	beq	0xaa790 <.text+0x9a690> @ imm = #0x38
   aa754: e59f0f68     	ldr	r0, [pc, #0xf68]        @ 0xab6c4 <.text+0x9b5c4>
   aa758: e79f0000     	ldr	r0, [pc, r0]
   aa75c: e5900000     	ldr	r0, [r0]
   aa760: e2401001     	sub	r1, r0, #1
   aa764: e0000190     	mul	r0, r0, r1
   aa768: e3100001     	tst	r0, #1
   aa76c: 0a00029b     	beq	0xab1e0 <.text+0x9b0e0> @ imm = #0xa6c
   aa770: e59f0f50     	ldr	r0, [pc, #0xf50]        @ 0xab6c8 <.text+0x9b5c8>
   aa774: e79f0000     	ldr	r0, [pc, r0]
   aa778: e5900000     	ldr	r0, [r0]
   aa77c: e3500009     	cmp	r0, #9
   aa780: ca0002a6     	bgt	0xab220 <.text+0x9b120> @ imm = #0xa98
   aa784: ea000295     	b	0xab1e0 <.text+0x9b0e0> @ imm = #0xa54
   aa788: e3a05001     	mov	r5, #1
   aa78c: ea0002d7     	b	0xab2f0 <.text+0x9b1f0> @ imm = #0xb5c
   aa790: e3a05003     	mov	r5, #3
   aa794: ea0002d5     	b	0xab2f0 <.text+0x9b1f0> @ imm = #0xb54
   aa798: 0053e733     	subseq	lr, r3, r3, lsr r7
   aa79c: 0053e732     	subseq	lr, r3, r2, lsr r7
   aa7a0: 0053e74d     	subseq	lr, r3, sp, asr #14
   aa7a4: 0053ed69     	subseq	lr, r3, r9, ror #26
   aa7a8: 005364dc     	ldrsbeq	r6, [r3], #-76
   aa7ac: 00535b18     	subseq	r5, r3, r8, lsl r11
   aa7b0: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0xab79c <.text+0x9b69c>
   aa7b4: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0xab7a0 <.text+0x9b6a0>
   aa7b8: e59f2fe4     	ldr	r2, [pc, #0xfe4]        @ 0xab7a4 <.text+0x9b6a4>
   aa7bc: e08f0000     	add	r0, pc, r0
   aa7c0: e08f1001     	add	r1, pc, r1
   aa7c4: e08f2002     	add	r2, pc, r2
   aa7c8: e24dd010     	sub	sp, sp, #16
   aa7cc: e51b30c0     	ldr	r3, [r11, #-0xc0]
   aa7d0: e3a07001     	mov	r7, #1
   aa7d4: e58d7000     	str	r7, [sp]
   aa7d8: e283305c     	add	r3, r3, #92
   aa7dc: e98d0210     	stmib	sp, {r4, r9}
   aa7e0: e58d300c     	str	r3, [sp, #0xc]
   aa7e4: e300315f     	movw	r3, #0x15f
   aa7e8: eb013e35     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x4f8d4
   aa7ec: e28dd010     	add	sp, sp, #16
   aa7f0: e59f0fb0     	ldr	r0, [pc, #0xfb0]        @ 0xab7a8 <.text+0x9b6a8>
   aa7f4: e79f0000     	ldr	r0, [pc, r0]
   aa7f8: e5900000     	ldr	r0, [r0]
   aa7fc: e2401001     	sub	r1, r0, #1
   aa800: e0000190     	mul	r0, r0, r1
   aa804: e3100001     	tst	r0, #1
   aa808: 0afffb88     	beq	0xa9630 <.text+0x99530> @ imm = #-0x11e0
   aa80c: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0xab800 <.text+0x9b700>
   aa810: e79f0000     	ldr	r0, [pc, r0]
   aa814: e5900000     	ldr	r0, [r0]
   aa818: e350000a     	cmp	r0, #10
   aa81c: bafffb83     	blt	0xa9630 <.text+0x99530> @ imm = #-0x11f4
   aa820: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0xab820 <.text+0x9b720>
   aa824: e59f1ff8     	ldr	r1, [pc, #0xff8]        @ 0xab824 <.text+0x9b724>
   aa828: e59f2ff8     	ldr	r2, [pc, #0xff8]        @ 0xab828 <.text+0x9b728>
   aa82c: e08f0000     	add	r0, pc, r0
   aa830: e08f1001     	add	r1, pc, r1
   aa834: e08f2002     	add	r2, pc, r2
   aa838: e24dd010     	sub	sp, sp, #16
   aa83c: e51b30c0     	ldr	r3, [r11, #-0xc0]
   aa840: e3a07001     	mov	r7, #1
   aa844: e58d7000     	str	r7, [sp]
   aa848: e283305c     	add	r3, r3, #92
   aa84c: e98d0210     	stmib	sp, {r4, r9}
   aa850: e58d300c     	str	r3, [sp, #0xc]
   aa854: e300315f     	movw	r3, #0x15f
   aa858: eb013e19     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x4f864
   aa85c: e28dd010     	add	sp, sp, #16
   aa860: eaffffd2     	b	0xaa7b0 <.text+0x9a6b0> @ imm = #-0xb8
   aa864: 00536468     	subseq	r6, r3, r8, ror #8
   aa868: 00535aa8     	subseq	r5, r3, r8, lsr #21
   aa86c: e59f3fb8     	ldr	r3, [pc, #0xfb8]        @ 0xab82c <.text+0x9b72c>
   aa870: e08f3003     	add	r3, pc, r3
   aa874: e24dd010     	sub	sp, sp, #16
   aa878: e1a00004     	mov	r0, r4
   aa87c: e1a01006     	mov	r1, r6
   aa880: e3a02000     	mov	r2, #0
   aa884: e58d8000     	str	r8, [sp]
   aa888: e98d0220     	stmib	sp, {r5, r9}
   aa88c: e58d700c     	str	r7, [sp, #0xc]

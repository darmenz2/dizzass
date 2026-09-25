
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ab1b0: e3a07001     	mov	r7, #1
   ab1b4: e58d3008     	str	r3, [sp, #0x8]
   ab1b8: e30032cd     	movw	r3, #0x2cd
   ab1bc: e58d7000     	str	r7, [sp]
   ab1c0: e58d4004     	str	r4, [sp, #0x4]
   ab1c4: eb013bbe     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x4eef8
   ab1c8: e28dd010     	add	sp, sp, #16
   ab1cc: eaffffd3     	b	0xab120 <.text+0x9b020> @ imm = #-0xb4
   ab1d0: 0053dd2f     	subseq	sp, r3, pc, lsr #26
   ab1d4: 0053dd2e     	subseq	sp, r3, lr, lsr #26
   ab1d8: 0053dd49     	subseq	sp, r3, r9, asr #26
   ab1dc: 0053e4b2     	ldrheq	lr, [r3], #-66
   ab1e0: e59f1fa4     	ldr	r1, [pc, #0xfa4]        @ 0xac18c <.text+0x9c08c>
   ab1e4: e1a00004     	mov	r0, r4
   ab1e8: e08f1001     	add	r1, pc, r1
   ab1ec: eb13e105     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f8414
   ab1f0: e59f1f98     	ldr	r1, [pc, #0xf98]        @ 0xac190 <.text+0x9c090>
   ab1f4: e79f1001     	ldr	r1, [pc, r1]
   ab1f8: e5911000     	ldr	r1, [r1]
   ab1fc: e2412001     	sub	r2, r1, #1
   ab200: e0010291     	mul	r1, r1, r2
   ab204: e3110001     	tst	r1, #1
   ab208: 0a00000a     	beq	0xab238 <.text+0x9b138> @ imm = #0x28
   ab20c: e59f1f80     	ldr	r1, [pc, #0xf80]        @ 0xac194 <.text+0x9c094>
   ab210: e79f1001     	ldr	r1, [pc, r1]
   ab214: e5911000     	ldr	r1, [r1]
   ab218: e3510009     	cmp	r1, #9
   ab21c: da000005     	ble	0xab238 <.text+0x9b138> @ imm = #0x14
   ab220: e59f1f70     	ldr	r1, [pc, #0xf70]        @ 0xac198 <.text+0x9c098>
   ab224: e1a00004     	mov	r0, r4
   ab228: e08f1001     	add	r1, pc, r1
   ab22c: eb13e0f5     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f83d4
   ab230: eaffffea     	b	0xab1e0 <.text+0x9b0e0> @ imm = #-0x58
   ab234: 0053e4a0     	subseq	lr, r3, r0, lsr #9
   ab238: e3500000     	cmp	r0, #0
   ab23c: 0a000019     	beq	0xab2a8 <.text+0x9b1a8> @ imm = #0x64
   ab240: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0xac23c <.text+0x9c13c>
   ab244: e1a00004     	mov	r0, r4
   ab248: e08f1001     	add	r1, pc, r1
   ab24c: eb13e0ed     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f83b4
   ab250: e3500000     	cmp	r0, #0
   ab254: 0a000015     	beq	0xab2b0 <.text+0x9b1b0> @ imm = #0x54
   ab258: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0xac240 <.text+0x9c140>
   ab25c: e1a00004     	mov	r0, r4
   ab260: e08f1001     	add	r1, pc, r1
   ab264: eb13e0e7     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f839c
   ab268: e3500000     	cmp	r0, #0
   ab26c: 0a000011     	beq	0xab2b8 <.text+0x9b1b8> @ imm = #0x44
   ab270: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0xac26c <.text+0x9c16c>
   ab274: e1a00004     	mov	r0, r4
   ab278: e08f1001     	add	r1, pc, r1
   ab27c: eb13e0e1     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f8384
   ab280: e3500000     	cmp	r0, #0
   ab284: 0a000018     	beq	0xab2ec <.text+0x9b1ec> @ imm = #0x60
   ab288: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0xac270 <.text+0x9c170>
   ab28c: e1a00004     	mov	r0, r4
   ab290: e08f1001     	add	r1, pc, r1
   ab294: eb13e0db     	bl	0x5a3608 <.text+0x593508> @ imm = #0x4f836c
   ab298: e3a05008     	mov	r5, #8
   ab29c: e3500000     	cmp	r0, #0
   ab2a0: 03005007     	movweq	r5, #0x7
   ab2a4: ea000011     	b	0xab2f0 <.text+0x9b1f0> @ imm = #0x44
   ab2a8: e3a05005     	mov	r5, #5
   ab2ac: ea00000f     	b	0xab2f0 <.text+0x9b1f0> @ imm = #0x3c
   ab2b0: e3a05004     	mov	r5, #4
   ab2b4: ea00000d     	b	0xab2f0 <.text+0x9b1f0> @ imm = #0x34
   ab2b8: e3a05002     	mov	r5, #2
   ab2bc: ea00000b     	b	0xab2f0 <.text+0x9b1f0> @ imm = #0x2c
   ab2c0: 0053e4cc     	subseq	lr, r3, r12, asr #9
   ab2c4: 0053e4bd     	ldrheq	lr, [r3], #-77
   ab2c8: 0053e4a9     	subseq	lr, r3, r9, lsr #9
   ab2cc: 0053e473     	subseq	lr, r3, r3, ror r4
   ab2d0: 0053e45f     	subseq	lr, r3, pc, asr r4
   ab2d4: 0053e44c     	subseq	lr, r3, r12, asr #8
   ab2d8: 0053e43a     	subseq	lr, r3, r10, lsr r4
   ab2dc: 0053e3fc     	ldrsheq	lr, [r3], #-60
   ab2e0: 0053e3e7     	subseq	lr, r3, r7, ror #7
   ab2e4: 0053e3d4     	ldrsbeq	lr, [r3], #-52
   ab2e8: 0053e3a5     	subseq	lr, r3, r5, lsr #7
   ab2ec: e3a05006     	mov	r5, #6
   ab2f0: e51b21ec     	ldr	r2, [r11, #-0x1ec]
   ab2f4: e51b3120     	ldr	r3, [r11, #-0x120]
   ab2f8: e51b0104     	ldr	r0, [r11, #-0x104]
   ab2fc: e5825088     	str	r5, [r2, #0x88]
   ab300: e51b1108     	ldr	r1, [r11, #-0x108]
   ab304: e593c000     	ldr	r12, [r3]
   ab308: e51b310c     	ldr	r3, [r11, #-0x10c]
   ab30c: e51b7124     	ldr	r7, [r11, #-0x124]
   ab310: e51b612c     	ldr	r6, [r11, #-0x12c]
   ab314: e51b5100     	ldr	r5, [r11, #-0x100]
   ab318: e51b411c     	ldr	r4, [r11, #-0x11c]
   ab31c: e5900000     	ldr	r0, [r0]
   ab320: e5911000     	ldr	r1, [r1]
   ab324: e5933000     	ldr	r3, [r3]
   ab328: e5977000     	ldr	r7, [r7]
   ab32c: e5966000     	ldr	r6, [r6]
   ab330: e5955000     	ldr	r5, [r5]
   ab334: e5944000     	ldr	r4, [r4]
   ab338: e5823094     	str	r3, [r2, #0x94]
   ab33c: e5821098     	str	r1, [r2, #0x98]
   ab340: e282109c     	add	r1, r2, #156
   ab344: e88110c1     	stm	r1, {r0, r6, r7, r12}
   ab348: e51b0118     	ldr	r0, [r11, #-0x118]
   ab34c: e51b1128     	ldr	r1, [r11, #-0x128]
   ab350: e58250ac     	str	r5, [r2, #0xac]
   ab354: e3a05001     	mov	r5, #1
   ab358: e58240b0     	str	r4, [r2, #0xb0]
   ab35c: e5900000     	ldr	r0, [r0]
   ab360: e5911000     	ldr	r1, [r1]
   ab364: e58200b4     	str	r0, [r2, #0xb4]
   ab368: e58210b8     	str	r1, [r2, #0xb8]
   ab36c: e3550000     	cmp	r5, #0
   ab370: 1afffc2a     	bne	0xaa420 <.text+0x9a320> @ imm = #-0xf58
   ab374: eafffcca     	b	0xaa6a4 <.text+0x9a5a4> @ imm = #-0xcd8
   ab378: 0053dd0a     	subseq	sp, r3, r10, lsl #26
   ab37c: 0053db37     	subseq	sp, r3, r7, lsr r11
   ab380: 0053db36     	subseq	sp, r3, r6, lsr r11
   ab384: 0053db51     	subseq	sp, r3, r1, asr r11
   ab388: 0053dd1a     	subseq	sp, r3, r10, lsl sp
   ab38c: 0053dae6     	subseq	sp, r3, r6, ror #21
   ab390: e59f1f88     	ldr	r1, [pc, #0xf88]        @ 0xac320 <.text+0x9c220>
   ab394: e3a00000     	mov	r0, #0
   ab398: e5850000     	str	r0, [r5]
   ab39c: e5860000     	str	r0, [r6]
   ab3a0: e08f1001     	add	r1, pc, r1
   ab3a4: e5870000     	str	r0, [r7]
   ab3a8: e5840000     	str	r0, [r4]
   ab3ac: e51b0040     	ldr	r0, [r11, #-0x40]
   ab3b0: eb029cfc     	bl	0x1527a8 <.text+0x1426a8> @ imm = #0xa73f0
   ab3b4: e1a08000     	mov	r8, r0
   ab3b8: e59f0f64     	ldr	r0, [pc, #0xf64]        @ 0xac324 <.text+0x9c224>
   ab3bc: e79f0000     	ldr	r0, [pc, r0]
   ab3c0: e5900000     	ldr	r0, [r0]
   ab3c4: e2401001     	sub	r1, r0, #1
   ab3c8: e0000190     	mul	r0, r0, r1
   ab3cc: e3100001     	tst	r0, #1
   ab3d0: 0a000023     	beq	0xab464 <.text+0x9b364> @ imm = #0x8c
   ab3d4: e59f0f4c     	ldr	r0, [pc, #0xf4c]        @ 0xac328 <.text+0x9c228>
   ab3d8: e79f0000     	ldr	r0, [pc, r0]
   ab3dc: e5900000     	ldr	r0, [r0]
   ab3e0: e3500009     	cmp	r0, #9
   ab3e4: da00001e     	ble	0xab464 <.text+0x9b364> @ imm = #0x78
   ab3e8: e59f1f3c     	ldr	r1, [pc, #0xf3c]        @ 0xac32c <.text+0x9c22c>
   ab3ec: e3a00000     	mov	r0, #0
   ab3f0: e5850000     	str	r0, [r5]
   ab3f4: e5860000     	str	r0, [r6]
   ab3f8: e08f1001     	add	r1, pc, r1
   ab3fc: e5870000     	str	r0, [r7]
   ab400: e5840000     	str	r0, [r4]
   ab404: e51b0040     	ldr	r0, [r11, #-0x40]
   ab408: eb029ce6     	bl	0x1527a8 <.text+0x1426a8> @ imm = #0xa7398
   ab40c: eaffffdf     	b	0xab390 <.text+0x9b290> @ imm = #-0x84
   ab410: 005358ec     	subseq	r5, r3, r12, ror #17
   ab414: 00534f1c     	subseq	r4, r3, r12, lsl pc
   ab418: 0053da8f     	subseq	sp, r3, pc, lsl #21
   ab41c: 0053da8e     	subseq	sp, r3, lr, lsl #21
   ab420: 0053daa9     	subseq	sp, r3, r9, lsr #21
   ab424: 0053e1a1     	subseq	lr, r3, r1, lsr #3
   ab428: 0053e2e5     	subseq	lr, r3, r5, ror #5
   ab42c: 0053e1cf     	subseq	lr, r3, pc, asr #3
   ab430: 0053e303     	subseq	lr, r3, r3, lsl #6
   ab434: 0053e30e     	subseq	lr, r3, lr, lsl #6
   ab438: 005357e0     	subseq	r5, r3, r0, ror #15
   ab43c: 0053e2ca     	subseq	lr, r3, r10, asr #5
   ab440: 00534e14     	subseq	r4, r3, r4, lsl lr
   ab444: 00535790     	<unknown>
   ab448: 0053e12b     	subseq	lr, r3, r11, lsr #2
   ab44c: 0053e12c     	subseq	lr, r3, r12, lsr #2

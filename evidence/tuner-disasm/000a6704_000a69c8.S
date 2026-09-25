
/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   a6704: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   a6708: e28db01c     	add	r11, sp, #28
   a670c: e24dd01c     	sub	sp, sp, #28
   a6710: e1a05001     	mov	r5, r1
   a6714: e1a08000     	mov	r8, r0
   a6718: eb015e27     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x5789c
   a671c: e598720c     	ldr	r7, [r8, #0x20c]
   a6720: e1570005     	cmp	r7, r5
   a6724: 0a000085     	beq	0xa6940 <.text+0x96840> @ imm = #0x214
   a6728: e59f9248     	ldr	r9, [pc, #0x248]        @ 0xa6978 <.text+0x96878>
   a672c: e1a06000     	mov	r6, r0
   a6730: e79f9009     	ldr	r9, [pc, r9]
   a6734: e5990000     	ldr	r0, [r9]
   a6738: e59fa23c     	ldr	r10, [pc, #0x23c]       @ 0xa697c <.text+0x9687c>
   a673c: e2401001     	sub	r1, r0, #1
   a6740: e0000190     	mul	r0, r0, r1
   a6744: e79fa00a     	ldr	r10, [pc, r10]
   a6748: e59f4230     	ldr	r4, [pc, #0x230]        @ 0xa6980 <.text+0x96880>
   a674c: e08f4004     	add	r4, pc, r4
   a6750: e3100001     	tst	r0, #1
   a6754: 0a000002     	beq	0xa6764 <.text+0x96664> @ imm = #0x8
   a6758: e59a0000     	ldr	r0, [r10]
   a675c: e3500009     	cmp	r0, #9
   a6760: ca000018     	bgt	0xa67c8 <.text+0x966c8> @ imm = #0x60
   a6764: e59f0218     	ldr	r0, [pc, #0x218]        @ 0xa6984 <.text+0x96884>
   a6768: e3a03003     	mov	r3, #3
   a676c: e59f1214     	ldr	r1, [pc, #0x214]        @ 0xa6988 <.text+0x96888>
   a6770: e59f2214     	ldr	r2, [pc, #0x214]        @ 0xa698c <.text+0x9688c>
   a6774: e08f0000     	add	r0, pc, r0
   a6778: e08f1001     	add	r1, pc, r1
   a677c: e88d0098     	stm	sp, {r3, r4, r7}
   a6780: e08f2002     	add	r2, pc, r2
   a6784: e3a03f69     	mov	r3, #420
   a6788: e58d500c     	str	r5, [sp, #0xc]
   a678c: eb014e4c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x53930
   a6790: e5990000     	ldr	r0, [r9]
   a6794: e3a01000     	mov	r1, #0
   a6798: e1570005     	cmp	r7, r5
   a679c: e2402001     	sub	r2, r0, #1
   a67a0: b3001001     	movwlt	r1, #0x1
   a67a4: e0020290     	mul	r2, r0, r2
   a67a8: e2560006     	subs	r0, r6, #6
   a67ac: 13000001     	movwne	r0, #0x1
   a67b0: e0000001     	and	r0, r0, r1
   a67b4: e3120001     	tst	r2, #1
   a67b8: 0a00000e     	beq	0xa67f8 <.text+0x966f8> @ imm = #0x38
   a67bc: e59a1000     	ldr	r1, [r10]
   a67c0: e3510009     	cmp	r1, #9
   a67c4: da00000b     	ble	0xa67f8 <.text+0x966f8> @ imm = #0x2c
   a67c8: e59f01ec     	ldr	r0, [pc, #0x1ec]        @ 0xa69bc <.text+0x968bc>
   a67cc: e3a03003     	mov	r3, #3
   a67d0: e59f11e8     	ldr	r1, [pc, #0x1e8]        @ 0xa69c0 <.text+0x968c0>
   a67d4: e59f21e8     	ldr	r2, [pc, #0x1e8]        @ 0xa69c4 <.text+0x968c4>
   a67d8: e08f0000     	add	r0, pc, r0
   a67dc: e08f1001     	add	r1, pc, r1
   a67e0: e88d0098     	stm	sp, {r3, r4, r7}
   a67e4: e08f2002     	add	r2, pc, r2
   a67e8: e3a03f69     	mov	r3, #420
   a67ec: e58d500c     	str	r5, [sp, #0xc]
   a67f0: eb014e33     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x538cc
   a67f4: eaffffda     	b	0xa6764 <.text+0x96664> @ imm = #-0x98
   a67f8: e3500000     	cmp	r0, #0
   a67fc: 0a000025     	beq	0xa6898 <.text+0x96798> @ imm = #0x94
   a6800: e1a00008     	mov	r0, r8
   a6804: ebfed9cd     	bl	0x5cf40 <.text+0x4ce40> @ imm = #-0x498cc
   a6808: e59f1190     	ldr	r1, [pc, #0x190]        @ 0xa69a0 <.text+0x968a0>
   a680c: e28d0010     	add	r0, sp, #16
   a6810: e1a02008     	mov	r2, r8
   a6814: e79f1001     	ldr	r1, [pc, r1]
   a6818: eb13f820     	bl	0x5a48a0 <.text+0x5947a0> @ imm = #0x4fe080
   a681c: eb015de6     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x57798
   a6820: e3500000     	cmp	r0, #0
   a6824: 0a000037     	beq	0xa6908 <.text+0x96808> @ imm = #0xdc
   a6828: e1a00008     	mov	r0, r8
   a682c: e3a01001     	mov	r1, #1
   a6830: e1a02005     	mov	r2, r5
   a6834: ebfeea4d     	bl	0x61170 <.text+0x51070> @ imm = #-0x456cc
   a6838: e30031b6     	movw	r3, #0x1b6
   a683c: e3500000     	cmp	r0, #0
   a6840: 0a000037     	beq	0xa6924 <.text+0x96824> @ imm = #0xdc
   a6844: e59f0160     	ldr	r0, [pc, #0x160]        @ 0xa69ac <.text+0x968ac>
   a6848: e3a06001     	mov	r6, #1
   a684c: e59f115c     	ldr	r1, [pc, #0x15c]        @ 0xa69b0 <.text+0x968b0>
   a6850: e59f215c     	ldr	r2, [pc, #0x15c]        @ 0xa69b4 <.text+0x968b4>
   a6854: e08f0000     	add	r0, pc, r0
   a6858: e59f7158     	ldr	r7, [pc, #0x158]        @ 0xa69b8 <.text+0x968b8>
   a685c: e08f1001     	add	r1, pc, r1
   a6860: e08f2002     	add	r2, pc, r2
   a6864: e08f7007     	add	r7, pc, r7
   a6868: e88d00c0     	stm	sp, {r6, r7}
   a686c: eb014e14     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x53850
   a6870: e28d0010     	add	r0, sp, #16
   a6874: e3a01000     	mov	r1, #0
   a6878: eb13f80a     	bl	0x5a48a8 <.text+0x5947a8> @ imm = #0x4fe028
   a687c: e1a00008     	mov	r0, r8
   a6880: ebfed9d9     	bl	0x5cfec <.text+0x4ceec> @ imm = #-0x4989c
   a6884: e30100b4     	movw	r0, #0x10b4
   a6888: e30017d9     	movw	r1, #0x7d9
   a688c: e0880000     	add	r0, r8, r0
   a6890: ebfe8d00     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x5cc00
   a6894: ea000018     	b	0xa68fc <.text+0x967fc> @ imm = #0x60
   a6898: e1a00008     	mov	r0, r8
   a689c: e1a01005     	mov	r1, r5
   a68a0: e3a02064     	mov	r2, #100
   a68a4: e3a0300a     	mov	r3, #10
   a68a8: ebfede36     	bl	0x5e188 <.text+0x4e088> @ imm = #-0x48728
   a68ac: e3500000     	cmp	r0, #0
   a68b0: 0a000020     	beq	0xa6938 <.text+0x96838> @ imm = #0x80
   a68b4: e59f00d4     	ldr	r0, [pc, #0xd4]         @ 0xa6990 <.text+0x96890>
   a68b8: e3a07001     	mov	r7, #1
   a68bc: e59f10d0     	ldr	r1, [pc, #0xd0]         @ 0xa6994 <.text+0x96894>
   a68c0: e59f20d0     	ldr	r2, [pc, #0xd0]         @ 0xa6998 <.text+0x96898>
   a68c4: e08f0000     	add	r0, pc, r0
   a68c8: e59f30cc     	ldr	r3, [pc, #0xcc]         @ 0xa699c <.text+0x9689c>
   a68cc: e08f1001     	add	r1, pc, r1
   a68d0: e08f2002     	add	r2, pc, r2
   a68d4: e58d7000     	str	r7, [sp]
   a68d8: e08f3003     	add	r3, pc, r3
   a68dc: e98d0028     	stmib	sp, {r3, r5}
   a68e0: e3a03f6a     	mov	r3, #424
   a68e4: eb014df6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x537d8
   a68e8: e30100b4     	movw	r0, #0x10b4
   a68ec: e30017d5     	movw	r1, #0x7d5
   a68f0: e0880000     	add	r0, r8, r0
   a68f4: e1a02005     	mov	r2, r5
   a68f8: ebfe8ce6     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x5cc68
   a68fc: e1a00008     	mov	r0, r8
   a6900: ebfee009     	bl	0x5e92c <.text+0x4e82c> @ imm = #-0x47fdc
   a6904: ea00000b     	b	0xa6938 <.text+0x96838> @ imm = #0x2c
   a6908: e1a00008     	mov	r0, r8
   a690c: e3a01001     	mov	r1, #1
   a6910: e1a02005     	mov	r2, r5
   a6914: ebfee9bc     	bl	0x6100c <.text+0x50f0c> @ imm = #-0x45910
   a6918: e30031b1     	movw	r3, #0x1b1
   a691c: e3500000     	cmp	r0, #0
   a6920: 1affffc7     	bne	0xa6844 <.text+0x96744> @ imm = #-0xe4
   a6924: e28d0010     	add	r0, sp, #16
   a6928: e3a01000     	mov	r1, #0
   a692c: eb13f7dd     	bl	0x5a48a8 <.text+0x5947a8> @ imm = #0x4fdf74
   a6930: e1a00008     	mov	r0, r8
   a6934: ebfed9ac     	bl	0x5cfec <.text+0x4ceec> @ imm = #-0x49950
   a6938: e3010388     	movw	r0, #0x1388
   a693c: eb01a17e     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x685f8
   a6940: e59f005c     	ldr	r0, [pc, #0x5c]         @ 0xa69a4 <.text+0x968a4>
   a6944: e79f0000     	ldr	r0, [pc, r0]
   a6948: e59f1058     	ldr	r1, [pc, #0x58]         @ 0xa69a8 <.text+0x968a8>
   a694c: e79f1001     	ldr	r1, [pc, r1]
   a6950: e5902000     	ldr	r2, [r0]
   a6954: e2423001     	sub	r3, r2, #1
   a6958: e0020392     	mul	r2, r2, r3
   a695c: e3120001     	tst	r2, #1
   a6960: 0a000002     	beq	0xa6970 <.text+0x96870> @ imm = #0x8
   a6964: e5912000     	ldr	r2, [r1]
   a6968: e3520009     	cmp	r2, #9
   a696c: cafffff7     	bgt	0xa6950 <.text+0x96850> @ imm = #-0x24
   a6970: e24bd01c     	sub	sp, r11, #28
   a6974: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   a6978: 005381a0     	subseq	r8, r3, r0, lsr #3
   a697c: 0053920c     	subseq	r9, r3, r12, lsl #4
   a6980: 0054173d     	subseq	r1, r4, sp, lsr r7
   a6984: 005415b7     	ldrheq	r1, [r4], #-87
   a6988: 00541554     	subseq	r1, r4, r4, asr r5
   a698c: 00541584     	subseq	r1, r4, r4, lsl #11
   a6990: 00541439     	subseq	r1, r4, r9, lsr r4
   a6994: 00541400     	subseq	r1, r4, r0, lsl #8
   a6998: 00541434     	subseq	r1, r4, r4, lsr r4
   a699c: 005415d5     	ldrsbeq	r1, [r4], #-85
   a69a0: 00538840     	subseq	r8, r3, r0, asr #16
   a69a4: 00537f8c     	subseq	r7, r3, r12, lsl #31
   a69a8: 00539004     	subseq	r9, r3, r4
   a69ac: 005414a9     	subseq	r1, r4, r9, lsr #9
   a69b0: 00541470     	subseq	r1, r4, r0, ror r4
   a69b4: 005414a4     	subseq	r1, r4, r4, lsr #9
   a69b8: 00541668     	subseq	r1, r4, r8, ror #12
   a69bc: 00541553     	subseq	r1, r4, r3, asr r5
   a69c0: 005414f0     	ldrsheq	r1, [r4], #-64
   a69c4: 00541520     	subseq	r1, r4, r0, lsr #10


/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   9c1f8: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   9c1fc: e28db01c     	add	r11, sp, #28
   9c200: e24dd004     	sub	sp, sp, #4
   9c204: ed2d8b08     	vpush	{d8, d9, d10, d11}
   9c208: e24dd068     	sub	sp, sp, #104
   9c20c: e1a05001     	mov	r5, r1
   9c210: e28d4030     	add	r4, sp, #48
   9c214: e8b500cc     	ldm	r5!, {r2, r3, r6, r7}
   9c218: e1a09000     	mov	r9, r0
   9c21c: e1a00004     	mov	r0, r4
   9c220: e8a000cc     	stm	r0!, {r2, r3, r6, r7}
   9c224: e89500cc     	ldm	r5, {r2, r3, r6, r7}
   9c228: e88000cc     	stm	r0, {r2, r3, r6, r7}
   9c22c: e1a00009     	mov	r0, r9
   9c230: e58d1014     	str	r1, [sp, #0x14]
   9c234: ebffb08e     	bl	0x88474 <.text+0x78374> @ imm = #-0x13dc8
   9c238: e1a00009     	mov	r0, r9
   9c23c: e1a01004     	mov	r1, r4
   9c240: ebffb08b     	bl	0x88474 <.text+0x78374> @ imm = #-0x13dd4
   9c244: e59f0f78     	ldr	r0, [pc, #0xf78]        @ 0x9d1c4 <.text+0x8d0c4>
   9c248: e3a03003     	mov	r3, #3
   9c24c: e59f1f74     	ldr	r1, [pc, #0xf74]        @ 0x9d1c8 <.text+0x8d0c8>
   9c250: e59f2f74     	ldr	r2, [pc, #0xf74]        @ 0x9d1cc <.text+0x8d0cc>
   9c254: e08f0000     	add	r0, pc, r0
   9c258: e59f7f70     	ldr	r7, [pc, #0xf70]        @ 0x9d1d0 <.text+0x8d0d0>
   9c25c: e08f1001     	add	r1, pc, r1
   9c260: e08f2002     	add	r2, pc, r2
   9c264: e08f7007     	add	r7, pc, r7
   9c268: e88d0088     	stm	sp, {r3, r7}
   9c26c: e3a03fa5     	mov	r3, #660
   9c270: eb017793     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5de4c
   9c274: e5990018     	ldr	r0, [r9, #0x18]
   9c278: eb002be3     	bl	0xa720c <.text+0x9710c> @ imm = #0xaf8c
   9c27c: e58d002c     	str	r0, [sp, #0x2c]
   9c280: eb0188f8     	bl	0xfe668 <.text+0xee568> @ imm = #0x623e0
   9c284: e28d1050     	add	r1, sp, #80
   9c288: e1a06000     	mov	r6, r0
   9c28c: e2811008     	add	r1, r1, #8
   9c290: e58d1010     	str	r1, [sp, #0x10]
   9c294: e59f8ffc     	ldr	r8, [pc, #0xffc]        @ 0x9d298 <.text+0x8d198>
   9c298: e3500000     	cmp	r0, #0
   9c29c: e3a00000     	mov	r0, #0
   9c2a0: e3a0a000     	mov	r10, #0
   9c2a4: c3000001     	movwgt	r0, #0x1
   9c2a8: e3a04e32     	mov	r4, #800
   9c2ac: e79f8008     	ldr	r8, [pc, r8]
   9c2b0: e3a01000     	mov	r1, #0
   9c2b4: e59f7fe0     	ldr	r7, [pc, #0xfe0]        @ 0x9d29c <.text+0x8d19c>
   9c2b8: e79f7007     	ldr	r7, [pc, r7]
   9c2bc: e58d1018     	str	r1, [sp, #0x18]
   9c2c0: e5981000     	ldr	r1, [r8]
   9c2c4: e2412001     	sub	r2, r1, #1
   9c2c8: e0010291     	mul	r1, r1, r2
   9c2cc: e3110001     	tst	r1, #1
   9c2d0: 0a000002     	beq	0x9c2e0 <.text+0x8c1e0> @ imm = #0x8
   9c2d4: e5971000     	ldr	r1, [r7]
   9c2d8: e3510009     	cmp	r1, #9
   9c2dc: cafffff7     	bgt	0x9c2c0 <.text+0x8c1c0> @ imm = #-0x24
   9c2e0: e3100001     	tst	r0, #1
   9c2e4: 0a00008d     	beq	0x9c520 <.text+0x8c420> @ imm = #0x234
   9c2e8: e3a05000     	mov	r5, #0
   9c2ec: e58d601c     	str	r6, [sp, #0x1c]
   9c2f0: ea000002     	b	0x9c300 <.text+0x8c200> @ imm = #0x8
   9c2f4: e2855001     	add	r5, r5, #1
   9c2f8: e1550006     	cmp	r5, r6
   9c2fc: 0a000087     	beq	0x9c520 <.text+0x8c420> @ imm = #0x21c
   9c300: e5990230     	ldr	r0, [r9, #0x230]
   9c304: e0270495     	mla	r7, r5, r4, r0
   9c308: e58d0024     	str	r0, [sp, #0x24]
   9c30c: e1a00007     	mov	r0, r7
   9c310: ebfeeb2d     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x4534c
   9c314: e3500000     	cmp	r0, #0
   9c318: 0a000071     	beq	0x9c4e4 <.text+0x8c3e4> @ imm = #0x1c4
   9c31c: e2874fae     	add	r4, r7, #696
   9c320: e599214c     	ldr	r2, [r9, #0x14c]
   9c324: e3a01000     	mov	r1, #0
   9c328: e1a00004     	mov	r0, r4
   9c32c: e12fff32     	blx	r2
   9c330: e3500000     	cmp	r0, #0
   9c334: 1a000500     	bne	0x9d73c <.text+0x8d63c> @ imm = #0x1400
   9c338: e3a0000a     	mov	r0, #10
   9c33c: eb01cafe     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72bf8
   9c340: e5992150     	ldr	r2, [r9, #0x150]
   9c344: e1a00004     	mov	r0, r4
   9c348: e3a01001     	mov	r1, #1
   9c34c: e12fff32     	blx	r2
   9c350: e3500000     	cmp	r0, #0
   9c354: 1a000508     	bne	0x9d77c <.text+0x8d67c> @ imm = #0x1420
   9c358: e3a0000a     	mov	r0, #10
   9c35c: eb01caf6     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72bd8
   9c360: e5996188     	ldr	r6, [r9, #0x188]
   9c364: e1a00004     	mov	r0, r4
   9c368: e3a01000     	mov	r1, #0
   9c36c: e3a02000     	mov	r2, #0
   9c370: e3a03001     	mov	r3, #1
   9c374: e12fff36     	blx	r6
   9c378: e3500000     	cmp	r0, #0
   9c37c: 1a000511     	bne	0x9d7c8 <.text+0x8d6c8> @ imm = #0x1444
   9c380: e3a0000a     	mov	r0, #10
   9c384: eb01caec     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72bb0
   9c388: e59921a4     	ldr	r2, [r9, #0x1a4]
   9c38c: e1a00004     	mov	r0, r4
   9c390: e3a01000     	mov	r1, #0
   9c394: e12fff32     	blx	r2
   9c398: e5981000     	ldr	r1, [r8]
   9c39c: e3a03001     	mov	r3, #1
   9c3a0: e2412001     	sub	r2, r1, #1
   9c3a4: e0010291     	mul	r1, r1, r2
   9c3a8: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x9d390 <.text+0x8d290>
   9c3ac: e79f2002     	ldr	r2, [pc, r2]
   9c3b0: e59d6024     	ldr	r6, [sp, #0x24]
   9c3b4: e1c31001     	bic	r1, r3, r1
   9c3b8: e5922000     	ldr	r2, [r2]
   9c3bc: e352000a     	cmp	r2, #10
   9c3c0: e3a02000     	mov	r2, #0
   9c3c4: b3002001     	movwlt	r2, #0x1
   9c3c8: e1811002     	orr	r1, r1, r2
   9c3cc: e3500000     	cmp	r0, #0
   9c3d0: 1a00050e     	bne	0x9d810 <.text+0x8d710> @ imm = #0x1438
   9c3d4: e3510000     	cmp	r1, #0
   9c3d8: e58d5020     	str	r5, [sp, #0x20]
   9c3dc: 0a00000f     	beq	0x9c420 <.text+0x8c320> @ imm = #0x3c
   9c3e0: e3a0000a     	mov	r0, #10
   9c3e4: eb01cad4     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72b50
   9c3e8: e5992154     	ldr	r2, [r9, #0x154]
   9c3ec: e1a00004     	mov	r0, r4
   9c3f0: e3a01008     	mov	r1, #8
   9c3f4: e12fff32     	blx	r2
   9c3f8: e5981000     	ldr	r1, [r8]
   9c3fc: e2412001     	sub	r2, r1, #1
   9c400: e0010291     	mul	r1, r1, r2
   9c404: e3110001     	tst	r1, #1
   9c408: 0a00000b     	beq	0x9c43c <.text+0x8c33c> @ imm = #0x2c
   9c40c: e59f1fc8     	ldr	r1, [pc, #0xfc8]        @ 0x9d3dc <.text+0x8d2dc>
   9c410: e79f1001     	ldr	r1, [pc, r1]
   9c414: e5911000     	ldr	r1, [r1]
   9c418: e3510009     	cmp	r1, #9
   9c41c: da000006     	ble	0x9c43c <.text+0x8c33c> @ imm = #0x18
   9c420: e3a0000a     	mov	r0, #10
   9c424: eb01cac4     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72b10
   9c428: e5992154     	ldr	r2, [r9, #0x154]
   9c42c: e1a00004     	mov	r0, r4
   9c430: e3a01008     	mov	r1, #8
   9c434: e12fff32     	blx	r2
   9c438: eaffffe8     	b	0x9c3e0 <.text+0x8c2e0> @ imm = #-0x60
   9c43c: e3500000     	cmp	r0, #0
   9c440: 1a0004f7     	bne	0x9d824 <.text+0x8d724> @ imm = #0x13dc
   9c444: e3a0000a     	mov	r0, #10
   9c448: e58d4028     	str	r4, [sp, #0x28]
   9c44c: eb01caba     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72ae8
   9c450: e59d002c     	ldr	r0, [sp, #0x2c]
   9c454: e5900010     	ldr	r0, [r0, #0x10]
   9c458: e3500001     	cmp	r0, #1
   9c45c: ba00001a     	blt	0x9c4cc <.text+0x8c3cc> @ imm = #0x68
   9c460: e2875088     	add	r5, r7, #136
   9c464: e3a04000     	mov	r4, #0
   9c468: e3a0a000     	mov	r10, #0
   9c46c: e5956000     	ldr	r6, [r5]
   9c470: e3060400     	movw	r0, #0x6400
   9c474: e3400037     	movt	r0, #0x37
   9c478: e0867004     	add	r7, r6, r4
   9c47c: e5971008     	ldr	r1, [r7, #0x8]
   9c480: eb13d29a     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4f4a68
   9c484: e30017b1     	movw	r1, #0x7b1
   9c488: e5993158     	ldr	r3, [r9, #0x158]
   9c48c: e34c14ce     	movt	r1, #0xc4ce
   9c490: e7500110     	smmla	r0, r0, r1, r0
   9c494: e1a01440     	asr	r1, r0, #8
   9c498: e0810fa0     	add	r0, r1, r0, lsr #31
   9c49c: e280200b     	add	r2, r0, #11
   9c4a0: e59d0028     	ldr	r0, [sp, #0x28]
   9c4a4: e1a01007     	mov	r1, r7
   9c4a8: e12fff33     	blx	r3
   9c4ac: e3500000     	cmp	r0, #0
   9c4b0: 1a00037a     	bne	0x9d2a0 <.text+0x8d1a0> @ imm = #0xde8
   9c4b4: e59d002c     	ldr	r0, [sp, #0x2c]
   9c4b8: e28aa001     	add	r10, r10, #1
   9c4bc: e2844060     	add	r4, r4, #96
   9c4c0: e5900010     	ldr	r0, [r0, #0x10]
   9c4c4: e15a0000     	cmp	r10, r0
   9c4c8: baffffe7     	blt	0x9c46c <.text+0x8c36c> @ imm = #-0x64
   9c4cc: e3a0000a     	mov	r0, #10
   9c4d0: eb01ca99     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72a64
   9c4d4: e59d601c     	ldr	r6, [sp, #0x1c]
   9c4d8: e3a0a000     	mov	r10, #0
   9c4dc: e59d5020     	ldr	r5, [sp, #0x20]
   9c4e0: e3a04e32     	mov	r4, #800
   9c4e4: e5980000     	ldr	r0, [r8]
   9c4e8: e59f2f60     	ldr	r2, [pc, #0xf60]        @ 0x9d450 <.text+0x8d350>
   9c4ec: e2401001     	sub	r1, r0, #1
   9c4f0: e0000190     	mul	r0, r0, r1
   9c4f4: e79f2002     	ldr	r2, [pc, r2]
   9c4f8: e3100001     	tst	r0, #1
   9c4fc: e5980000     	ldr	r0, [r8]
   9c500: e2401001     	sub	r1, r0, #1
   9c504: e0000190     	mul	r0, r0, r1
   9c508: e3100001     	tst	r0, #1
   9c50c: 0affff78     	beq	0x9c2f4 <.text+0x8c1f4> @ imm = #-0x220
   9c510: e5920000     	ldr	r0, [r2]
   9c514: e3500009     	cmp	r0, #9
   9c518: cafffff7     	bgt	0x9c4fc <.text+0x8c3fc> @ imm = #-0x24
   9c51c: eaffff74     	b	0x9c2f4 <.text+0x8c1f4> @ imm = #-0x230
   9c520: eb018850     	bl	0xfe668 <.text+0xee568> @ imm = #0x62140
   9c524: e3a01004     	mov	r1, #4
   9c528: e1a04000     	mov	r4, r0
   9c52c: eb13dda0     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x4f7680
   9c530: e58d0028     	str	r0, [sp, #0x28]
   9c534: e1a00004     	mov	r0, r4
   9c538: e3a01001     	mov	r1, #1
   9c53c: eb13dd9c     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x4f7670
   9c540: e1a06000     	mov	r6, r0
   9c544: e1a01004     	mov	r1, r4
   9c548: e3a00007     	mov	r0, #7
   9c54c: e58d402c     	str	r4, [sp, #0x2c]
   9c550: e58d6020     	str	r6, [sp, #0x20]
   9c554: e3510001     	cmp	r1, #1
   9c558: e58d001c     	str	r0, [sp, #0x1c]
   9c55c: ba000044     	blt	0x9c674 <.text+0x8c574> @ imm = #0x110
   9c560: e3a06000     	mov	r6, #0
   9c564: e1a07001     	mov	r7, r1
   9c568: e3a04000     	mov	r4, #0
   9c56c: ea000003     	b	0x9c580 <.text+0x8c480> @ imm = #0xc
   9c570: e2844001     	add	r4, r4, #1
   9c574: e2866e32     	add	r6, r6, #800
   9c578: e2577001     	subs	r7, r7, #1
   9c57c: 0a000031     	beq	0x9c648 <.text+0x8c548> @ imm = #0xc4
   9c580: e5980000     	ldr	r0, [r8]
   9c584: e2401001     	sub	r1, r0, #1
   9c588: e0000190     	mul	r0, r0, r1
   9c58c: e3100001     	tst	r0, #1
   9c590: 0a000004     	beq	0x9c5a8 <.text+0x8c4a8> @ imm = #0x10
   9c594: e59f0eb8     	ldr	r0, [pc, #0xeb8]        @ 0x9d454 <.text+0x8d354>
   9c598: e79f0000     	ldr	r0, [pc, r0]
   9c59c: e5900000     	ldr	r0, [r0]
   9c5a0: e3500009     	cmp	r0, #9
   9c5a4: ca00000d     	bgt	0x9c5e0 <.text+0x8c4e0> @ imm = #0x34
   9c5a8: e5990230     	ldr	r0, [r9, #0x230]
   9c5ac: e0805006     	add	r5, r0, r6
   9c5b0: e1a00005     	mov	r0, r5
   9c5b4: ebfeea84     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x455f0
   9c5b8: e5981000     	ldr	r1, [r8]
   9c5bc: e2412001     	sub	r2, r1, #1
   9c5c0: e0010291     	mul	r1, r1, r2
   9c5c4: e3110001     	tst	r1, #1
   9c5c8: 0a000008     	beq	0x9c5f0 <.text+0x8c4f0> @ imm = #0x20
   9c5cc: e59f1e84     	ldr	r1, [pc, #0xe84]        @ 0x9d458 <.text+0x8d358>
   9c5d0: e79f1001     	ldr	r1, [pc, r1]
   9c5d4: e5911000     	ldr	r1, [r1]
   9c5d8: e3510009     	cmp	r1, #9
   9c5dc: da000003     	ble	0x9c5f0 <.text+0x8c4f0> @ imm = #0xc
   9c5e0: e5990230     	ldr	r0, [r9, #0x230]
   9c5e4: e0800006     	add	r0, r0, r6
   9c5e8: ebfeea77     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x45624
   9c5ec: eaffffed     	b	0x9c5a8 <.text+0x8c4a8> @ imm = #-0x4c
   9c5f0: e3500000     	cmp	r0, #0
   9c5f4: 0a000004     	beq	0x9c60c <.text+0x8c50c> @ imm = #0x10
   9c5f8: e599115c     	ldr	r1, [r9, #0x15c]
   9c5fc: e2850fae     	add	r0, r5, #696
   9c600: e12fff31     	blx	r1
   9c604: e3500000     	cmp	r0, #0
   9c608: 1a000134     	bne	0x9cae0 <.text+0x8c9e0> @ imm = #0x4d0
   9c60c: e5980000     	ldr	r0, [r8]
   9c610: e2401001     	sub	r1, r0, #1
   9c614: e0000190     	mul	r0, r0, r1
   9c618: e3100001     	tst	r0, #1
   9c61c: e5980000     	ldr	r0, [r8]
   9c620: e2401001     	sub	r1, r0, #1
   9c624: e0000190     	mul	r0, r0, r1
   9c628: e3100001     	tst	r0, #1
   9c62c: 0affffcf     	beq	0x9c570 <.text+0x8c470> @ imm = #-0xc4
   9c630: e59f0e24     	ldr	r0, [pc, #0xe24]        @ 0x9d45c <.text+0x8d35c>
   9c634: e79f0000     	ldr	r0, [pc, r0]
   9c638: e5900000     	ldr	r0, [r0]
   9c63c: e3500009     	cmp	r0, #9
   9c640: cafffff5     	bgt	0x9c61c <.text+0x8c51c> @ imm = #-0x2c
   9c644: eaffffc9     	b	0x9c570 <.text+0x8c470> @ imm = #-0xdc
   9c648: e5980000     	ldr	r0, [r8]
   9c64c: e59f4e0c     	ldr	r4, [pc, #0xe0c]        @ 0x9d460 <.text+0x8d360>
   9c650: e2401001     	sub	r1, r0, #1
   9c654: e0000190     	mul	r0, r0, r1
   9c658: e79f4004     	ldr	r4, [pc, r4]
   9c65c: e3100001     	tst	r0, #1
   9c660: 0a00000e     	beq	0x9c6a0 <.text+0x8c5a0> @ imm = #0x38
   9c664: e5940000     	ldr	r0, [r4]
   9c668: e3500009     	cmp	r0, #9
   9c66c: ca000015     	bgt	0x9c6c8 <.text+0x8c5c8> @ imm = #0x54
   9c670: ea00000a     	b	0x9c6a0 <.text+0x8c5a0> @ imm = #0x28
   9c674: e5980000     	ldr	r0, [r8]
   9c678: e2401001     	sub	r1, r0, #1
   9c67c: e0000190     	mul	r0, r0, r1
   9c680: e3100001     	tst	r0, #1
   9c684: 0a000031     	beq	0x9c750 <.text+0x8c650> @ imm = #0xc4
   9c688: e59f0df8     	ldr	r0, [pc, #0xdf8]        @ 0x9d488 <.text+0x8d388>
   9c68c: e79f0000     	ldr	r0, [pc, r0]
   9c690: e5900000     	ldr	r0, [r0]
   9c694: e3500009     	cmp	r0, #9
   9c698: ca000038     	bgt	0x9c780 <.text+0x8c680> @ imm = #0xe0
   9c69c: ea00002b     	b	0x9c750 <.text+0x8c650> @ imm = #0xac
   9c6a0: e3a00096     	mov	r0, #150
   9c6a4: eb01ca24     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72890
   9c6a8: e5980000     	ldr	r0, [r8]
   9c6ac: e2401001     	sub	r1, r0, #1
   9c6b0: e0000190     	mul	r0, r0, r1
   9c6b4: e3100001     	tst	r0, #1
   9c6b8: 0a000005     	beq	0x9c6d4 <.text+0x8c5d4> @ imm = #0x14
   9c6bc: e5940000     	ldr	r0, [r4]
   9c6c0: e3500009     	cmp	r0, #9
   9c6c4: da000002     	ble	0x9c6d4 <.text+0x8c5d4> @ imm = #0x8
   9c6c8: e3a00096     	mov	r0, #150
   9c6cc: eb01ca1a     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x72868
   9c6d0: eafffff2     	b	0x9c6a0 <.text+0x8c5a0> @ imm = #-0x38
   9c6d4: e59d5020     	ldr	r5, [sp, #0x20]
   9c6d8: e3a04000     	mov	r4, #0
   9c6dc: e59d602c     	ldr	r6, [sp, #0x2c]
   9c6e0: e3a07000     	mov	r7, #0
   9c6e4: ea000004     	b	0x9c6fc <.text+0x8c5fc> @ imm = #0x10
   9c6e8: e2877001     	add	r7, r7, #1
   9c6ec: e2844e32     	add	r4, r4, #800
   9c6f0: e2855001     	add	r5, r5, #1
   9c6f4: e2566001     	subs	r6, r6, #1
   9c6f8: 0a000023     	beq	0x9c78c <.text+0x8c68c> @ imm = #0x8c
   9c6fc: e5990230     	ldr	r0, [r9, #0x230]
   9c700: e0800004     	add	r0, r0, r4
   9c704: ebfeea30     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x45740
   9c708: e3500000     	cmp	r0, #0
   9c70c: 03a00001     	moveq	r0, #1
   9c710: 05c50000     	strbeq	r0, [r5]
   9c714: e5980000     	ldr	r0, [r8]
   9c718: e2401001     	sub	r1, r0, #1
   9c71c: e0000190     	mul	r0, r0, r1
   9c720: e3100001     	tst	r0, #1
   9c724: e5980000     	ldr	r0, [r8]
   9c728: e2401001     	sub	r1, r0, #1
   9c72c: e0000190     	mul	r0, r0, r1
   9c730: e3100001     	tst	r0, #1
   9c734: 0affffeb     	beq	0x9c6e8 <.text+0x8c5e8> @ imm = #-0x54
   9c738: e59f0ff4     	ldr	r0, [pc, #0xff4]        @ 0x9d734 <.text+0x8d634>
   9c73c: e79f0000     	ldr	r0, [pc, r0]
   9c740: e5900000     	ldr	r0, [r0]
   9c744: e3500009     	cmp	r0, #9
   9c748: cafffff5     	bgt	0x9c724 <.text+0x8c624> @ imm = #-0x2c
   9c74c: eaffffe5     	b	0x9c6e8 <.text+0x8c5e8> @ imm = #-0x6c
   9c750: e3a00096     	mov	r0, #150
   9c754: eb01c9f8     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x727e0
   9c758: e5980000     	ldr	r0, [r8]
   9c75c: e2401001     	sub	r1, r0, #1
   9c760: e0000190     	mul	r0, r0, r1
   9c764: e3100001     	tst	r0, #1
   9c768: 0a000007     	beq	0x9c78c <.text+0x8c68c> @ imm = #0x1c
   9c76c: e59f0fc4     	ldr	r0, [pc, #0xfc4]        @ 0x9d738 <.text+0x8d638>
   9c770: e79f0000     	ldr	r0, [pc, r0]
   9c774: e5900000     	ldr	r0, [r0]
   9c778: e350000a     	cmp	r0, #10
   9c77c: ba000002     	blt	0x9c78c <.text+0x8c68c> @ imm = #0x8
   9c780: e3a00096     	mov	r0, #150
   9c784: eb01c9ec     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x727b0
   9c788: eafffff0     	b	0x9c750 <.text+0x8c650> @ imm = #-0x40
   9c78c: e59f7fe0     	ldr	r7, [pc, #0xfe0]        @ 0x9d774 <.text+0x8d674>
   9c790: e79f7007     	ldr	r7, [pc, r7]
   9c794: e5980000     	ldr	r0, [r8]
   9c798: e2401001     	sub	r1, r0, #1
   9c79c: e0000190     	mul	r0, r0, r1
   9c7a0: e3100001     	tst	r0, #1
   9c7a4: 0a000002     	beq	0x9c7b4 <.text+0x8c6b4> @ imm = #0x8
   9c7a8: e5970000     	ldr	r0, [r7]
   9c7ac: e3500009     	cmp	r0, #9
   9c7b0: cafffff7     	bgt	0x9c794 <.text+0x8c694> @ imm = #-0x24
   9c7b4: e59f4fbc     	ldr	r4, [pc, #0xfbc]        @ 0x9d778 <.text+0x8d678>
   9c7b8: e28d5050     	add	r5, sp, #80
   9c7bc: e59d6020     	ldr	r6, [sp, #0x20]
   9c7c0: e3a0300a     	mov	r3, #10
   9c7c4: e59d102c     	ldr	r1, [sp, #0x2c]
   9c7c8: e08f4004     	add	r4, pc, r4
   9c7cc: e3530000     	cmp	r3, #0
   9c7d0: 1a00000a     	bne	0x9c800 <.text+0x8c700> @ imm = #0x28
   9c7d4: ea0000a8     	b	0x9ca7c <.text+0x8c97c> @ imm = #0x2a0
   9c7d8: e59d102c     	ldr	r1, [sp, #0x2c]
   9c7dc: e28d5050     	add	r5, sp, #80
   9c7e0: e59f4fdc     	ldr	r4, [pc, #0xfdc]        @ 0x9d7c4 <.text+0x8d6c4>
   9c7e4: e3a0a000     	mov	r10, #0
   9c7e8: e59d6020     	ldr	r6, [sp, #0x20]
   9c7ec: e1500001     	cmp	r0, r1
   9c7f0: e08f4004     	add	r4, pc, r4
   9c7f4: aa0000a0     	bge	0x9ca7c <.text+0x8c97c> @ imm = #0x280
   9c7f8: e3530000     	cmp	r3, #0
   9c7fc: 0a00009e     	beq	0x9ca7c <.text+0x8c97c> @ imm = #0x278
   9c800: e28d0030     	add	r0, sp, #48
   9c804: e58d0060     	str	r0, [sp, #0x60]
   9c808: e59d0028     	ldr	r0, [sp, #0x28]
   9c80c: e58d1058     	str	r1, [sp, #0x58]
   9c810: e58d0054     	str	r0, [sp, #0x54]
   9c814: e58d3024     	str	r3, [sp, #0x24]
   9c818: e58d6050     	str	r6, [sp, #0x50]
   9c81c: eb0185fc     	bl	0xfe014 <.text+0xedf14> @ imm = #0x617f0
   9c820: e59d302c     	ldr	r3, [sp, #0x2c]
   9c824: e58d005c     	str	r0, [sp, #0x5c]
   9c828: e3530001     	cmp	r3, #1
   9c82c: ba000021     	blt	0x9c8b8 <.text+0x8c7b8> @ imm = #0x84
   9c830: e59d0028     	ldr	r0, [sp, #0x28]
   9c834: e580a000     	str	r10, [r0]
   9c838: 0a00001e     	beq	0x9c8b8 <.text+0x8c7b8> @ imm = #0x78
   9c83c: e3a00001     	mov	r0, #1
   9c840: e3a01000     	mov	r1, #0
   9c844: ea000004     	b	0x9c85c <.text+0x8c75c> @ imm = #0x10
   9c848: e2411001     	sub	r1, r1, #1
   9c84c: e2800001     	add	r0, r0, #1
   9c850: e0832001     	add	r2, r3, r1
   9c854: e3520001     	cmp	r2, #1
   9c858: 0a000016     	beq	0x9c8b8 <.text+0x8c7b8> @ imm = #0x58
   9c85c: e5982000     	ldr	r2, [r8]
   9c860: e2425001     	sub	r5, r2, #1
   9c864: e0020592     	mul	r2, r2, r5
   9c868: e3120001     	tst	r2, #1
   9c86c: 0a000002     	beq	0x9c87c <.text+0x8c77c> @ imm = #0x8
   9c870: e5972000     	ldr	r2, [r7]
   9c874: e3520009     	cmp	r2, #9
   9c878: ca00000a     	bgt	0x9c8a8 <.text+0x8c7a8> @ imm = #0x28
   9c87c: e59d2054     	ldr	r2, [sp, #0x54]
   9c880: e0422101     	sub	r2, r2, r1, lsl #2
   9c884: e582a004     	str	r10, [r2, #0x4]
   9c888: e5982000     	ldr	r2, [r8]
   9c88c: e2425001     	sub	r5, r2, #1
   9c890: e0020592     	mul	r2, r2, r5
   9c894: e3120001     	tst	r2, #1
   9c898: 0affffea     	beq	0x9c848 <.text+0x8c748> @ imm = #-0x58
   9c89c: e5972000     	ldr	r2, [r7]
   9c8a0: e3520009     	cmp	r2, #9
   9c8a4: daffffe7     	ble	0x9c848 <.text+0x8c748> @ imm = #-0x64
   9c8a8: e59d2054     	ldr	r2, [sp, #0x54]
   9c8ac: e0422101     	sub	r2, r2, r1, lsl #2
   9c8b0: e582a004     	str	r10, [r2, #0x4]
   9c8b4: eafffff0     	b	0x9c87c <.text+0x8c77c> @ imm = #-0x40
   9c8b8: e5980000     	ldr	r0, [r8]
   9c8bc: e28d5050     	add	r5, sp, #80
   9c8c0: e2401001     	sub	r1, r0, #1
   9c8c4: e0000190     	mul	r0, r0, r1
   9c8c8: e3100001     	tst	r0, #1
   9c8cc: 0a000002     	beq	0x9c8dc <.text+0x8c7dc> @ imm = #0x8
   9c8d0: e5970000     	ldr	r0, [r7]
   9c8d4: e3500009     	cmp	r0, #9
   9c8d8: ca00000e     	bgt	0x9c918 <.text+0x8c818> @ imm = #0x38
   9c8dc: e1a00009     	mov	r0, r9
   9c8e0: e3a010d0     	mov	r1, #208
   9c8e4: e1a02006     	mov	r2, r6
   9c8e8: e58d5000     	str	r5, [sp]
   9c8ec: e58d4004     	str	r4, [sp, #0x4]
   9c8f0: ebff02a0     	bl	0x5d378 <.text+0x4d278> @ imm = #-0x3f580
   9c8f4: e5981000     	ldr	r1, [r8]
   9c8f8: e59d302c     	ldr	r3, [sp, #0x2c]
   9c8fc: e2412001     	sub	r2, r1, #1
   9c900: e0010291     	mul	r1, r1, r2
   9c904: e3110001     	tst	r1, #1
   9c908: 0a00000a     	beq	0x9c938 <.text+0x8c838> @ imm = #0x28
   9c90c: e5971000     	ldr	r1, [r7]
   9c910: e3510009     	cmp	r1, #9
   9c914: da000007     	ble	0x9c938 <.text+0x8c838> @ imm = #0x1c
   9c918: e1a00009     	mov	r0, r9
   9c91c: e3a010d0     	mov	r1, #208
   9c920: e1a02006     	mov	r2, r6
   9c924: e58d5000     	str	r5, [sp]
   9c928: e58d4004     	str	r4, [sp, #0x4]
   9c92c: ebff0291     	bl	0x5d378 <.text+0x4d278> @ imm = #-0x3f5bc
   9c930: e59d302c     	ldr	r3, [sp, #0x2c]
   9c934: eaffffe8     	b	0x9c8dc <.text+0x8c7dc> @ imm = #-0x60
   9c938: e3500000     	cmp	r0, #0
   9c93c: 1a000056     	bne	0x9ca9c <.text+0x8c99c> @ imm = #0x158
   9c940: e3530001     	cmp	r3, #1
   9c944: ba00003c     	blt	0x9ca3c <.text+0x8c93c> @ imm = #0xf0
   9c948: e59d5028     	ldr	r5, [sp, #0x28]
   9c94c: e3a06000     	mov	r6, #0
   9c950: e1a0a003     	mov	r10, r3
   9c954: e3a00000     	mov	r0, #0
   9c958: ea000004     	b	0x9c970 <.text+0x8c870> @ imm = #0x10
   9c95c: e1a00004     	mov	r0, r4
   9c960: e25aa001     	subs	r10, r10, #1
   9c964: e2866e32     	add	r6, r6, #800
   9c968: e2855004     	add	r5, r5, #4
   9c96c: 0a000033     	beq	0x9ca40 <.text+0x8c940> @ imm = #0xcc
   9c970: e1a04000     	mov	r4, r0
   9c974: e5980000     	ldr	r0, [r8]
   9c978: e2401001     	sub	r1, r0, #1
   9c97c: e0000190     	mul	r0, r0, r1
   9c980: e3100001     	tst	r0, #1
   9c984: 0a000002     	beq	0x9c994 <.text+0x8c894> @ imm = #0x8
   9c988: e5970000     	ldr	r0, [r7]
   9c98c: e3500009     	cmp	r0, #9
   9c990: ca00000a     	bgt	0x9c9c0 <.text+0x8c8c0> @ imm = #0x28
   9c994: e5990230     	ldr	r0, [r9, #0x230]
   9c998: e0800006     	add	r0, r0, r6
   9c99c: ebfee98a     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x459d8
   9c9a0: e5981000     	ldr	r1, [r8]
   9c9a4: e2412001     	sub	r2, r1, #1
   9c9a8: e0010291     	mul	r1, r1, r2
   9c9ac: e3110001     	tst	r1, #1
   9c9b0: 0a000006     	beq	0x9c9d0 <.text+0x8c8d0> @ imm = #0x18
   9c9b4: e5971000     	ldr	r1, [r7]
   9c9b8: e3510009     	cmp	r1, #9
   9c9bc: da000003     	ble	0x9c9d0 <.text+0x8c8d0> @ imm = #0xc
   9c9c0: e5990230     	ldr	r0, [r9, #0x230]
   9c9c4: e0800006     	add	r0, r0, r6
   9c9c8: ebfee97f     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x45a04
   9c9cc: eafffff0     	b	0x9c994 <.text+0x8c894> @ imm = #-0x40
   9c9d0: e3500000     	cmp	r0, #0
   9c9d4: 0affffe0     	beq	0x9c95c <.text+0x8c85c> @ imm = #-0x80
   9c9d8: e5980000     	ldr	r0, [r8]
   9c9dc: e2401001     	sub	r1, r0, #1
   9c9e0: e0000190     	mul	r0, r0, r1
   9c9e4: e3100001     	tst	r0, #1
   9c9e8: 0a000002     	beq	0x9c9f8 <.text+0x8c8f8> @ imm = #0x8
   9c9ec: e5970000     	ldr	r0, [r7]
   9c9f0: e3500009     	cmp	r0, #9
   9c9f4: ca00000e     	bgt	0x9ca34 <.text+0x8c934> @ imm = #0x38
   9c9f8: e5957000     	ldr	r7, [r5]
   9c9fc: eb018584     	bl	0xfe014 <.text+0xedf14> @ imm = #0x61610
   9ca00: e5981000     	ldr	r1, [r8]
   9ca04: e1570000     	cmp	r7, r0
   9ca08: e59f7f78     	ldr	r7, [pc, #0xf78]        @ 0x9d988 <.text+0x8d888>
   9ca0c: e1a00004     	mov	r0, r4
   9ca10: e2412001     	sub	r2, r1, #1
   9ca14: a2800001     	addge	r0, r0, #1
   9ca18: e0010291     	mul	r1, r1, r2
   9ca1c: e79f7007     	ldr	r7, [pc, r7]
   9ca20: e3110001     	tst	r1, #1
   9ca24: 0affffcd     	beq	0x9c960 <.text+0x8c860> @ imm = #-0xcc
   9ca28: e5971000     	ldr	r1, [r7]
   9ca2c: e3510009     	cmp	r1, #9
   9ca30: daffffca     	ble	0x9c960 <.text+0x8c860> @ imm = #-0xd8
   9ca34: eb018576     	bl	0xfe014 <.text+0xedf14> @ imm = #0x615d8
   9ca38: eaffffee     	b	0x9c9f8 <.text+0x8c8f8> @ imm = #-0x48
   9ca3c: e3a00000     	mov	r0, #0
   9ca40: e5981000     	ldr	r1, [r8]
   9ca44: e59d3024     	ldr	r3, [sp, #0x24]
   9ca48: e2412001     	sub	r2, r1, #1
   9ca4c: e2433001     	sub	r3, r3, #1
   9ca50: e0010291     	mul	r1, r1, r2
   9ca54: e3110001     	tst	r1, #1
   9ca58: e5981000     	ldr	r1, [r8]
   9ca5c: e2412001     	sub	r2, r1, #1
   9ca60: e0010291     	mul	r1, r1, r2
   9ca64: e3110001     	tst	r1, #1
   9ca68: 0affff5a     	beq	0x9c7d8 <.text+0x8c6d8> @ imm = #-0x298
   9ca6c: e5971000     	ldr	r1, [r7]
   9ca70: e3510009     	cmp	r1, #9
   9ca74: cafffff7     	bgt	0x9ca58 <.text+0x8c958> @ imm = #-0x24
   9ca78: eaffff56     	b	0x9c7d8 <.text+0x8c6d8> @ imm = #-0x2a8
   9ca7c: e59d201c     	ldr	r2, [sp, #0x1c]
   9ca80: e2420001     	sub	r0, r2, #1
   9ca84: e3520000     	cmp	r2, #0
   9ca88: 1afffeb1     	bne	0x9c554 <.text+0x8c454> @ imm = #-0x53c
   9ca8c: e3a04000     	mov	r4, #0
   9ca90: e3560000     	cmp	r6, #0
   9ca94: 1a000028     	bne	0x9cb3c <.text+0x8ca3c> @ imm = #0xa0
   9ca98: ea00003c     	b	0x9cb90 <.text+0x8ca90> @ imm = #0xf0
   9ca9c: e3a00001     	mov	r0, #1
   9caa0: e300312a     	movw	r3, #0x12a
   9caa4: e58d0000     	str	r0, [sp]
   9caa8: e59f0f88     	ldr	r0, [pc, #0xf88]        @ 0x9da38 <.text+0x8d938>
   9caac: e08f0000     	add	r0, pc, r0
   9cab0: e58d0004     	str	r0, [sp, #0x4]
   9cab4: e59f0f80     	ldr	r0, [pc, #0xf80]        @ 0x9da3c <.text+0x8d93c>
   9cab8: e59f1f80     	ldr	r1, [pc, #0xf80]        @ 0x9da40 <.text+0x8d940>
   9cabc: e59f2f80     	ldr	r2, [pc, #0xf80]        @ 0x9da44 <.text+0x8d944>
   9cac0: e08f0000     	add	r0, pc, r0
   9cac4: e08f1001     	add	r1, pc, r1
   9cac8: e08f2002     	add	r2, pc, r2
   9cacc: eb01757c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5d5f0
   9cad0: e3e04000     	mvn	r4, #0
   9cad4: e3560000     	cmp	r6, #0
   9cad8: 1a000017     	bne	0x9cb3c <.text+0x8ca3c> @ imm = #0x5c
   9cadc: ea00002b     	b	0x9cb90 <.text+0x8ca90> @ imm = #0xac
   9cae0: e3a01001     	mov	r1, #1
   9cae4: e5950018     	ldr	r0, [r5, #0x18]
   9cae8: e58d1000     	str	r1, [sp]
   9caec: e3a03f46     	mov	r3, #280
   9caf0: e59f1f50     	ldr	r1, [pc, #0xf50]        @ 0x9da48 <.text+0x8d948>
   9caf4: e2800001     	add	r0, r0, #1
   9caf8: e58d0008     	str	r0, [sp, #0x8]
   9cafc: e08f1001     	add	r1, pc, r1
   9cb00: e58d1004     	str	r1, [sp, #0x4]
   9cb04: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x9daf8 <.text+0x8d9f8>
   9cb08: e59f1fec     	ldr	r1, [pc, #0xfec]        @ 0x9dafc <.text+0x8d9fc>
   9cb0c: e59f2fec     	ldr	r2, [pc, #0xfec]        @ 0x9db00 <.text+0x8da00>
   9cb10: e08f0000     	add	r0, pc, r0
   9cb14: e08f1001     	add	r1, pc, r1
   9cb18: e08f2002     	add	r2, pc, r2
   9cb1c: eb017568     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5d5a0
   9cb20: e59f7fdc     	ldr	r7, [pc, #0xfdc]        @ 0x9db04 <.text+0x8da04>
   9cb24: e3e04000     	mvn	r4, #0
   9cb28: e28d5050     	add	r5, sp, #80
   9cb2c: e79f7007     	ldr	r7, [pc, r7]
   9cb30: e59d6020     	ldr	r6, [sp, #0x20]
   9cb34: e3560000     	cmp	r6, #0
   9cb38: 0a000014     	beq	0x9cb90 <.text+0x8ca90> @ imm = #0x50
   9cb3c: e5980000     	ldr	r0, [r8]
   9cb40: e2401001     	sub	r1, r0, #1
   9cb44: e0000190     	mul	r0, r0, r1
   9cb48: e3100001     	tst	r0, #1
   9cb4c: 0a000002     	beq	0x9cb5c <.text+0x8ca5c> @ imm = #0x8
   9cb50: e5970000     	ldr	r0, [r7]
   9cb54: e3500009     	cmp	r0, #9
   9cb58: ca000009     	bgt	0x9cb84 <.text+0x8ca84> @ imm = #0x24
   9cb5c: e1a00006     	mov	r0, r6
   9cb60: eb13dc49     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f7124
   9cb64: e5980000     	ldr	r0, [r8]
   9cb68: e2401001     	sub	r1, r0, #1
   9cb6c: e0000190     	mul	r0, r0, r1
   9cb70: e3100001     	tst	r0, #1
   9cb74: 0a000005     	beq	0x9cb90 <.text+0x8ca90> @ imm = #0x14
   9cb78: e5970000     	ldr	r0, [r7]
   9cb7c: e3500009     	cmp	r0, #9
   9cb80: da000002     	ble	0x9cb90 <.text+0x8ca90> @ imm = #0x8
   9cb84: e1a00006     	mov	r0, r6
   9cb88: eb13dc3f     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f70fc
   9cb8c: eafffff2     	b	0x9cb5c <.text+0x8ca5c> @ imm = #-0x38
   9cb90: e59d0028     	ldr	r0, [sp, #0x28]
   9cb94: e3500000     	cmp	r0, #0
   9cb98: 0a000014     	beq	0x9cbf0 <.text+0x8caf0> @ imm = #0x50
   9cb9c: e5980000     	ldr	r0, [r8]
   9cba0: e2401001     	sub	r1, r0, #1
   9cba4: e0000190     	mul	r0, r0, r1
   9cba8: e3100001     	tst	r0, #1
   9cbac: 0a000002     	beq	0x9cbbc <.text+0x8cabc> @ imm = #0x8
   9cbb0: e5970000     	ldr	r0, [r7]
   9cbb4: e3500009     	cmp	r0, #9
   9cbb8: ca000009     	bgt	0x9cbe4 <.text+0x8cae4> @ imm = #0x24
   9cbbc: e59d0028     	ldr	r0, [sp, #0x28]
   9cbc0: eb13dc31     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f70c4
   9cbc4: e5980000     	ldr	r0, [r8]
   9cbc8: e2401001     	sub	r1, r0, #1
   9cbcc: e0000190     	mul	r0, r0, r1
   9cbd0: e3100001     	tst	r0, #1
   9cbd4: 0a000005     	beq	0x9cbf0 <.text+0x8caf0> @ imm = #0x14
   9cbd8: e5970000     	ldr	r0, [r7]
   9cbdc: e3500009     	cmp	r0, #9
   9cbe0: da000002     	ble	0x9cbf0 <.text+0x8caf0> @ imm = #0x8
   9cbe4: e59d0028     	ldr	r0, [sp, #0x28]
   9cbe8: eb13dc27     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f709c
   9cbec: eafffff2     	b	0x9cbbc <.text+0x8cabc> @ imm = #-0x38
   9cbf0: e3540000     	cmp	r4, #0
   9cbf4: 1a000318     	bne	0x9d85c <.text+0x8d75c> @ imm = #0xc60
   9cbf8: eb01869a     	bl	0xfe668 <.text+0xee568> @ imm = #0x61a68
   9cbfc: e1a04000     	mov	r4, r0
   9cc00: e59d0010     	ldr	r0, [sp, #0x10]
   9cc04: e580a000     	str	r10, [r0]
   9cc08: e580a004     	str	r10, [r0, #0x4]
   9cc0c: e580a008     	str	r10, [r0, #0x8]
   9cc10: eb018694     	bl	0xfe668 <.text+0xee568> @ imm = #0x61a50
   9cc14: e3a01001     	mov	r1, #1
   9cc18: e1a07000     	mov	r7, r0
   9cc1c: eb13dbe4     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x4f6f90
   9cc20: e1a06000     	mov	r6, r0
   9cc24: e58d0050     	str	r0, [sp, #0x50]
   9cc28: e1a00007     	mov	r0, r7
   9cc2c: e3a01004     	mov	r1, #4
   9cc30: eb13dbdf     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x4f6f7c
   9cc34: e28d1030     	add	r1, sp, #48
   9cc38: e58d0054     	str	r0, [sp, #0x54]
   9cc3c: e1a00009     	mov	r0, r9
   9cc40: ebffae0b     	bl	0x88474 <.text+0x78374> @ imm = #-0x147d4
   9cc44: e3540001     	cmp	r4, #1
   9cc48: e58d402c     	str	r4, [sp, #0x2c]
   9cc4c: ba000034     	blt	0x9cd24 <.text+0x8cc24> @ imm = #0xd0
   9cc50: e3a04000     	mov	r4, #0
   9cc54: e3a07000     	mov	r7, #0
   9cc58: e3a05000     	mov	r5, #0
   9cc5c: e3a0a000     	mov	r10, #0
   9cc60: ea000006     	b	0x9cc80 <.text+0x8cb80> @ imm = #0x18
   9cc64: e59d002c     	ldr	r0, [sp, #0x2c]
   9cc68: e2455001     	sub	r5, r5, #1
   9cc6c: e28aa001     	add	r10, r10, #1
   9cc70: e2844e32     	add	r4, r4, #800
   9cc74: e2877028     	add	r7, r7, #40
   9cc78: e0900005     	adds	r0, r0, r5
   9cc7c: 0a000022     	beq	0x9cd0c <.text+0x8cc0c> @ imm = #0x88
   9cc80: e5990230     	ldr	r0, [r9, #0x230]
   9cc84: e59d8048     	ldr	r8, [sp, #0x48]
   9cc88: e0806004     	add	r6, r0, r4
   9cc8c: e1a00006     	mov	r0, r6
   9cc90: ebfee8cd     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x45ccc
   9cc94: e3500000     	cmp	r0, #0
   9cc98: 0a000007     	beq	0x9ccbc <.text+0x8cbbc> @ imm = #0x1c
   9cc9c: e1a00006     	mov	r0, r6
   9cca0: e0888007     	add	r8, r8, r7
   9cca4: ebfee8c6     	bl	0x56fc4 <.text+0x46ec4> @ imm = #-0x45ce8
   9cca8: e5c80004     	strb	r0, [r8, #0x4]
   9ccac: e1a00006     	mov	r0, r6
   9ccb0: ebfee8c5     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x45cec
   9ccb4: e5c80005     	strb	r0, [r8, #0x5]
   9ccb8: ea000002     	b	0x9ccc8 <.text+0x8cbc8> @ imm = #0x8
   9ccbc: e59d0050     	ldr	r0, [sp, #0x50]
   9ccc0: e3a01001     	mov	r1, #1
   9ccc4: e7401005     	strb	r1, [r0, -r5]
   9ccc8: e59f8f5c     	ldr	r8, [pc, #0xf5c]        @ 0x9dc2c <.text+0x8db2c>
   9cccc: e79f8008     	ldr	r8, [pc, r8]
   9ccd0: e5980000     	ldr	r0, [r8]
   9ccd4: e2401001     	sub	r1, r0, #1
   9ccd8: e0000190     	mul	r0, r0, r1
   9ccdc: e3100001     	tst	r0, #1
   9cce0: e5980000     	ldr	r0, [r8]
   9cce4: e2401001     	sub	r1, r0, #1
   9cce8: e0000190     	mul	r0, r0, r1
   9ccec: e3100001     	tst	r0, #1
   9ccf0: 0affffdb     	beq	0x9cc64 <.text+0x8cb64> @ imm = #-0x94
   9ccf4: e59f0fd8     	ldr	r0, [pc, #0xfd8]        @ 0x9dcd4 <.text+0x8dbd4>
   9ccf8: e79f0000     	ldr	r0, [pc, r0]
   9ccfc: e5900000     	ldr	r0, [r0]
   9cd00: e3500009     	cmp	r0, #9
   9cd04: cafffff5     	bgt	0x9cce0 <.text+0x8cbe0> @ imm = #-0x2c
   9cd08: eaffffd5     	b	0x9cc64 <.text+0x8cb64> @ imm = #-0xac
   9cd0c: e59d6050     	ldr	r6, [sp, #0x50]
   9cd10: e28d5050     	add	r5, sp, #80
   9cd14: e59f7fbc     	ldr	r7, [pc, #0xfbc]        @ 0x9dcd8 <.text+0x8dbd8>
   9cd18: e3a0a000     	mov	r10, #0
   9cd1c: e79f7007     	ldr	r7, [pc, r7]
   9cd20: ea000001     	b	0x9cd2c <.text+0x8cc2c> @ imm = #0x4
   9cd24: e59f7fa4     	ldr	r7, [pc, #0xfa4]        @ 0x9dcd0 <.text+0x8dbd0>
   9cd28: e79f7007     	ldr	r7, [pc, r7]
   9cd2c: e28d0030     	add	r0, sp, #48
   9cd30: e58d0060     	str	r0, [sp, #0x60]
   9cd34: eb0184b6     	bl	0xfe014 <.text+0xedf14> @ imm = #0x612d8
   9cd38: e59d302c     	ldr	r3, [sp, #0x2c]
   9cd3c: e3a010e0     	mov	r1, #224
   9cd40: e58d005c     	str	r0, [sp, #0x5c]
   9cd44: e1a02006     	mov	r2, r6
   9cd48: e58d3058     	str	r3, [sp, #0x58]
   9cd4c: e58d5000     	str	r5, [sp]
   9cd50: e59f0f84     	ldr	r0, [pc, #0xf84]        @ 0x9dcdc <.text+0x8dbdc>
   9cd54: e08f0000     	add	r0, pc, r0
   9cd58: e58d0004     	str	r0, [sp, #0x4]
   9cd5c: e1a00009     	mov	r0, r9
   9cd60: ebff0184     	bl	0x5d378 <.text+0x4d278> @ imm = #-0x3f9f0
   9cd64: e59d5054     	ldr	r5, [sp, #0x54]
   9cd68: e3550000     	cmp	r5, #0
   9cd6c: 0a000016     	beq	0x9cdcc <.text+0x8cccc> @ imm = #0x58
   9cd70: e5980000     	ldr	r0, [r8]
   9cd74: e2401001     	sub	r1, r0, #1
   9cd78: e0000190     	mul	r0, r0, r1
   9cd7c: e3100001     	tst	r0, #1
   9cd80: 0a000002     	beq	0x9cd90 <.text+0x8cc90> @ imm = #0x8
   9cd84: e5970000     	ldr	r0, [r7]
   9cd88: e3500009     	cmp	r0, #9
   9cd8c: ca00000a     	bgt	0x9cdbc <.text+0x8ccbc> @ imm = #0x28
   9cd90: e1a00005     	mov	r0, r5
   9cd94: eb13dbbc     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f6ef0
   9cd98: e5980000     	ldr	r0, [r8]
   9cd9c: e58da054     	str	r10, [sp, #0x54]
   9cda0: e2401001     	sub	r1, r0, #1
   9cda4: e0010190     	mul	r1, r0, r1
   9cda8: e5970000     	ldr	r0, [r7]
   9cdac: e3110001     	tst	r1, #1
   9cdb0: 0a000005     	beq	0x9cdcc <.text+0x8cccc> @ imm = #0x14
   9cdb4: e3500009     	cmp	r0, #9
   9cdb8: da000003     	ble	0x9cdcc <.text+0x8cccc> @ imm = #0xc
   9cdbc: e1a00005     	mov	r0, r5
   9cdc0: eb13dbb1     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f6ec4
   9cdc4: e58da054     	str	r10, [sp, #0x54]
   9cdc8: eafffff0     	b	0x9cd90 <.text+0x8cc90> @ imm = #-0x40
   9cdcc: e5980000     	ldr	r0, [r8]
   9cdd0: e2401001     	sub	r1, r0, #1
   9cdd4: e0000190     	mul	r0, r0, r1
   9cdd8: e3100001     	tst	r0, #1
   9cddc: e5980000     	ldr	r0, [r8]
   9cde0: e59d5050     	ldr	r5, [sp, #0x50]
   9cde4: e2401001     	sub	r1, r0, #1
   9cde8: e0000190     	mul	r0, r0, r1
   9cdec: e3100001     	tst	r0, #1
   9cdf0: 0a000002     	beq	0x9ce00 <.text+0x8cd00> @ imm = #0x8
   9cdf4: e5970000     	ldr	r0, [r7]
   9cdf8: e3500009     	cmp	r0, #9
   9cdfc: cafffff6     	bgt	0x9cddc <.text+0x8ccdc> @ imm = #-0x28
   9ce00: e3550000     	cmp	r5, #0
   9ce04: 0a000016     	beq	0x9ce64 <.text+0x8cd64> @ imm = #0x58
   9ce08: e5980000     	ldr	r0, [r8]
   9ce0c: e2401001     	sub	r1, r0, #1
   9ce10: e0000190     	mul	r0, r0, r1
   9ce14: e3100001     	tst	r0, #1
   9ce18: 0a000002     	beq	0x9ce28 <.text+0x8cd28> @ imm = #0x8
   9ce1c: e5970000     	ldr	r0, [r7]
   9ce20: e3500009     	cmp	r0, #9
   9ce24: ca00000a     	bgt	0x9ce54 <.text+0x8cd54> @ imm = #0x28
   9ce28: e1a00005     	mov	r0, r5
   9ce2c: eb13db96     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f6e58
   9ce30: e5980000     	ldr	r0, [r8]
   9ce34: e58da050     	str	r10, [sp, #0x50]
   9ce38: e2401001     	sub	r1, r0, #1
   9ce3c: e0010190     	mul	r1, r0, r1
   9ce40: e5970000     	ldr	r0, [r7]
   9ce44: e3110001     	tst	r1, #1
   9ce48: 0a000005     	beq	0x9ce64 <.text+0x8cd64> @ imm = #0x14
   9ce4c: e3500009     	cmp	r0, #9
   9ce50: da000003     	ble	0x9ce64 <.text+0x8cd64> @ imm = #0xc
   9ce54: e1a00005     	mov	r0, r5
   9ce58: eb13db8b     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4f6e2c
   9ce5c: e58da050     	str	r10, [sp, #0x50]
   9ce60: eafffff0     	b	0x9ce28 <.text+0x8cd28> @ imm = #-0x40
   9ce64: e5980000     	ldr	r0, [r8]
   9ce68: e2401001     	sub	r1, r0, #1
   9ce6c: e0000190     	mul	r0, r0, r1
   9ce70: e3100001     	tst	r0, #1
   9ce74: 0a000002     	beq	0x9ce84 <.text+0x8cd84> @ imm = #0x8
   9ce78: e5970000     	ldr	r0, [r7]
   9ce7c: e3500009     	cmp	r0, #9
   9ce80: ca000009     	bgt	0x9ceac <.text+0x8cdac> @ imm = #0x24
   9ce84: eb0185f7     	bl	0xfe668 <.text+0xee568> @ imm = #0x617dc
   9ce88: e1a0a000     	mov	r10, r0
   9ce8c: e5980000     	ldr	r0, [r8]
   9ce90: e2401001     	sub	r1, r0, #1
   9ce94: e0000190     	mul	r0, r0, r1
   9ce98: e3100001     	tst	r0, #1
   9ce9c: 0a000004     	beq	0x9ceb4 <.text+0x8cdb4> @ imm = #0x10
   9cea0: e5970000     	ldr	r0, [r7]
   9cea4: e3500009     	cmp	r0, #9
   9cea8: da000001     	ble	0x9ceb4 <.text+0x8cdb4> @ imm = #0x4
   9ceac: eb0185ed     	bl	0xfe668 <.text+0xee568> @ imm = #0x617b4
   9ceb0: eafffff3     	b	0x9ce84 <.text+0x8cd84> @ imm = #-0x34
   9ceb4: e35a0001     	cmp	r10, #1
   9ceb8: ba000065     	blt	0x9d054 <.text+0x8cf54> @ imm = #0x194
   9cebc: e3a05000     	mov	r5, #0
   9cec0: ea000006     	b	0x9cee0 <.text+0x8cde0> @ imm = #0x18
   9cec4: e59f7e48     	ldr	r7, [pc, #0xe48]        @ 0x9dd14 <.text+0x8dc14>
   9cec8: e3500000     	cmp	r0, #0
   9cecc: e79f7007     	ldr	r7, [pc, r7]
   9ced0: 1a000142     	bne	0x9d3e0 <.text+0x8d2e0> @ imm = #0x508
   9ced4: e25aa001     	subs	r10, r10, #1
   9ced8: e2855e32     	add	r5, r5, #800
   9cedc: 0a00005c     	beq	0x9d054 <.text+0x8cf54> @ imm = #0x170
   9cee0: e5980000     	ldr	r0, [r8]
   9cee4: e2401001     	sub	r1, r0, #1
   9cee8: e0000190     	mul	r0, r0, r1
   9ceec: e3100001     	tst	r0, #1
   9cef0: 0a000002     	beq	0x9cf00 <.text+0x8ce00> @ imm = #0x8
   9cef4: e5970000     	ldr	r0, [r7]
   9cef8: e3500009     	cmp	r0, #9
   9cefc: ca00000b     	bgt	0x9cf30 <.text+0x8ce30> @ imm = #0x2c
   9cf00: e5990230     	ldr	r0, [r9, #0x230]
   9cf04: e0806005     	add	r6, r0, r5
   9cf08: e1a00006     	mov	r0, r6
   9cf0c: ebfee82e     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x45f48
   9cf10: e5981000     	ldr	r1, [r8]
   9cf14: e2412001     	sub	r2, r1, #1
   9cf18: e0010291     	mul	r1, r1, r2
   9cf1c: e3110001     	tst	r1, #1
   9cf20: 0a000006     	beq	0x9cf40 <.text+0x8ce40> @ imm = #0x18
   9cf24: e5971000     	ldr	r1, [r7]
   9cf28: e3510009     	cmp	r1, #9
   9cf2c: da000003     	ble	0x9cf40 <.text+0x8ce40> @ imm = #0xc
   9cf30: e5990230     	ldr	r0, [r9, #0x230]
   9cf34: e0800005     	add	r0, r0, r5
   9cf38: ebfee823     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x45f74
   9cf3c: eaffffef     	b	0x9cf00 <.text+0x8ce00> @ imm = #-0x44
   9cf40: e3500000     	cmp	r0, #0
   9cf44: 0affffe2     	beq	0x9ced4 <.text+0x8cdd4> @ imm = #-0x78
   9cf48: e2867fae     	add	r7, r6, #696
   9cf4c: e5994188     	ldr	r4, [r9, #0x188]
   9cf50: e3a01000     	mov	r1, #0
   9cf54: e3a02000     	mov	r2, #0
   9cf58: e1a00007     	mov	r0, r7
   9cf5c: e3a03000     	mov	r3, #0
   9cf60: e12fff34     	blx	r4
   9cf64: e3500000     	cmp	r0, #0
   9cf68: 1a0000f9     	bne	0x9d354 <.text+0x8d254> @ imm = #0x3e4
   9cf6c: e5980000     	ldr	r0, [r8]
   9cf70: e2401001     	sub	r1, r0, #1
   9cf74: e0000190     	mul	r0, r0, r1
   9cf78: e3100001     	tst	r0, #1
   9cf7c: 0a000004     	beq	0x9cf94 <.text+0x8ce94> @ imm = #0x10
   9cf80: e59f0d6c     	ldr	r0, [pc, #0xd6c]        @ 0x9dcf4 <.text+0x8dbf4>
   9cf84: e79f0000     	ldr	r0, [pc, r0]
   9cf88: e5900000     	ldr	r0, [r0]
   9cf8c: e3500009     	cmp	r0, #9
   9cf90: ca00000c     	bgt	0x9cfc8 <.text+0x8cec8> @ imm = #0x30
   9cf94: e5991160     	ldr	r1, [r9, #0x160]
   9cf98: e1a00007     	mov	r0, r7
   9cf9c: e12fff31     	blx	r1
   9cfa0: e5981000     	ldr	r1, [r8]
   9cfa4: e2412001     	sub	r2, r1, #1
   9cfa8: e0010291     	mul	r1, r1, r2
   9cfac: e3110001     	tst	r1, #1
   9cfb0: 0a000008     	beq	0x9cfd8 <.text+0x8ced8> @ imm = #0x20
   9cfb4: e59f1d3c     	ldr	r1, [pc, #0xd3c]        @ 0x9dcf8 <.text+0x8dbf8>
   9cfb8: e79f1001     	ldr	r1, [pc, r1]
   9cfbc: e5911000     	ldr	r1, [r1]
   9cfc0: e3510009     	cmp	r1, #9
   9cfc4: da000003     	ble	0x9cfd8 <.text+0x8ced8> @ imm = #0xc
   9cfc8: e5991160     	ldr	r1, [r9, #0x160]
   9cfcc: e1a00007     	mov	r0, r7
   9cfd0: e12fff31     	blx	r1
   9cfd4: eaffffee     	b	0x9cf94 <.text+0x8ce94> @ imm = #-0x48
   9cfd8: e3500000     	cmp	r0, #0
   9cfdc: 1a0000ec     	bne	0x9d394 <.text+0x8d294> @ imm = #0x3b0
   9cfe0: e5980000     	ldr	r0, [r8]
   9cfe4: e2401001     	sub	r1, r0, #1
   9cfe8: e0000190     	mul	r0, r0, r1
   9cfec: e3100001     	tst	r0, #1
   9cff0: 0a000004     	beq	0x9d008 <.text+0x8cf08> @ imm = #0x10
   9cff4: e59f0d10     	ldr	r0, [pc, #0xd10]        @ 0x9dd0c <.text+0x8dc0c>
   9cff8: e79f0000     	ldr	r0, [pc, r0]
   9cffc: e5900000     	ldr	r0, [r0]
   9d000: e3500009     	cmp	r0, #9
   9d004: ca00000d     	bgt	0x9d040 <.text+0x8cf40> @ imm = #0x34
   9d008: e5992150     	ldr	r2, [r9, #0x150]
   9d00c: e1a00007     	mov	r0, r7
   9d010: e3a01000     	mov	r1, #0
   9d014: e12fff32     	blx	r2
   9d018: e5981000     	ldr	r1, [r8]
   9d01c: e2412001     	sub	r2, r1, #1
   9d020: e0010291     	mul	r1, r1, r2
   9d024: e3110001     	tst	r1, #1
   9d028: 0affffa5     	beq	0x9cec4 <.text+0x8cdc4> @ imm = #-0x16c
   9d02c: e59f1cdc     	ldr	r1, [pc, #0xcdc]        @ 0x9dd10 <.text+0x8dc10>
   9d030: e79f1001     	ldr	r1, [pc, r1]
   9d034: e5911000     	ldr	r1, [r1]
   9d038: e3510009     	cmp	r1, #9
   9d03c: daffffa0     	ble	0x9cec4 <.text+0x8cdc4> @ imm = #-0x180
   9d040: e5992150     	ldr	r2, [r9, #0x150]
   9d044: e1a00007     	mov	r0, r7
   9d048: e3a01000     	mov	r1, #0
   9d04c: e12fff32     	blx	r2
   9d050: eaffffec     	b	0x9d008 <.text+0x8cf08> @ imm = #-0x50
   9d054: e5980000     	ldr	r0, [r8]
   9d058: e2401001     	sub	r1, r0, #1
   9d05c: e0000190     	mul	r0, r0, r1
   9d060: e3100001     	tst	r0, #1
   9d064: 0a000002     	beq	0x9d074 <.text+0x8cf74> @ imm = #0x8
   9d068: e5970000     	ldr	r0, [r7]
   9d06c: e3500009     	cmp	r0, #9
   9d070: ca00000b     	bgt	0x9d0a4 <.text+0x8cfa4> @ imm = #0x2c
   9d074: e5990018     	ldr	r0, [r9, #0x18]
   9d078: eb002863     	bl	0xa720c <.text+0x9710c> @ imm = #0xa18c
   9d07c: e1a05000     	mov	r5, r0
   9d080: eb018578     	bl	0xfe668 <.text+0xee568> @ imm = #0x615e0
   9d084: e5981000     	ldr	r1, [r8]
   9d088: e2412001     	sub	r2, r1, #1
   9d08c: e0010291     	mul	r1, r1, r2
   9d090: e3110001     	tst	r1, #1
   9d094: 0a000006     	beq	0x9d0b4 <.text+0x8cfb4> @ imm = #0x18
   9d098: e5971000     	ldr	r1, [r7]
   9d09c: e3510009     	cmp	r1, #9
   9d0a0: da000003     	ble	0x9d0b4 <.text+0x8cfb4> @ imm = #0xc
   9d0a4: e5990018     	ldr	r0, [r9, #0x18]
   9d0a8: eb002857     	bl	0xa720c <.text+0x9710c> @ imm = #0xa15c
   9d0ac: eb01856d     	bl	0xfe668 <.text+0xee568> @ imm = #0x615b4
   9d0b0: eaffffef     	b	0x9d074 <.text+0x8cf74> @ imm = #-0x44
   9d0b4: e3500001     	cmp	r0, #1
   9d0b8: ba000045     	blt	0x9d1d4 <.text+0x8d0d4> @ imm = #0x114
   9d0bc: e59d1014     	ldr	r1, [sp, #0x14]
   9d0c0: e3a02000     	mov	r2, #0
   9d0c4: e59dc048     	ldr	r12, [sp, #0x48]
   9d0c8: e3a0a000     	mov	r10, #0
   9d0cc: e5958010     	ldr	r8, [r5, #0x10]
   9d0d0: e591e018     	ldr	lr, [r1, #0x18]
   9d0d4: e3a01000     	mov	r1, #0
   9d0d8: e3580001     	cmp	r8, #1
   9d0dc: aa000005     	bge	0x9d0f8 <.text+0x8cff8> @ imm = #0x14
   9d0e0: ea000024     	b	0x9d178 <.text+0x8d078> @ imm = #0x90
   9d0e4: e28aa001     	add	r10, r10, #1
   9d0e8: e15a0000     	cmp	r10, r0
   9d0ec: 0a00003a     	beq	0x9d1dc <.text+0x8d0dc> @ imm = #0xe8
   9d0f0: e3580001     	cmp	r8, #1
   9d0f4: ba00001f     	blt	0x9d178 <.text+0x8d078> @ imm = #0x7c
   9d0f8: e59f3c48     	ldr	r3, [pc, #0xc48]        @ 0x9dd48 <.text+0x8dc48>
   9d0fc: e79f3003     	ldr	r3, [pc, r3]
   9d100: e5933000     	ldr	r3, [r3]
   9d104: e2434001     	sub	r4, r3, #1
   9d108: e0030493     	mul	r3, r3, r4
   9d10c: e3130001     	tst	r3, #1
   9d110: e59f3c34     	ldr	r3, [pc, #0xc34]        @ 0x9dd4c <.text+0x8dc4c>
   9d114: e08a410a     	add	r4, r10, r10, lsl #2
   9d118: e79f3003     	ldr	r3, [pc, r3]
   9d11c: e5933000     	ldr	r3, [r3]
   9d120: e2437001     	sub	r7, r3, #1
   9d124: e0070793     	mul	r7, r3, r7
   9d128: e08e3184     	add	r3, lr, r4, lsl #3
   9d12c: e08c4184     	add	r4, r12, r4, lsl #3
   9d130: e5933020     	ldr	r3, [r3, #0x20]
   9d134: e5944020     	ldr	r4, [r4, #0x20]
   9d138: e3170001     	tst	r7, #1
   9d13c: 0a000004     	beq	0x9d154 <.text+0x8d054> @ imm = #0x10
   9d140: e59f5c08     	ldr	r5, [pc, #0xc08]        @ 0x9dd50 <.text+0x8dc50>
   9d144: e79f5005     	ldr	r5, [pc, r5]
   9d148: e5957000     	ldr	r7, [r5]
   9d14c: e3570009     	cmp	r7, #9
   9d150: caffffee     	bgt	0x9d110 <.text+0x8d010> @ imm = #-0x48
   9d154: e2844024     	add	r4, r4, #36
   9d158: e2833024     	add	r3, r3, #36
   9d15c: e1a07008     	mov	r7, r8
   9d160: e4936038     	ldr	r6, [r3], #56
   9d164: e2577001     	subs	r7, r7, #1
   9d168: e4945038     	ldr	r5, [r4], #56
   9d16c: e0861001     	add	r1, r6, r1
   9d170: e0852002     	add	r2, r5, r2
   9d174: 1afffff9     	bne	0x9d160 <.text+0x8d060> @ imm = #-0x1c
   9d178: e59f3bd4     	ldr	r3, [pc, #0xbd4]        @ 0x9dd54 <.text+0x8dc54>
   9d17c: e79f3003     	ldr	r3, [pc, r3]
   9d180: e5933000     	ldr	r3, [r3]
   9d184: e59f7bcc     	ldr	r7, [pc, #0xbcc]        @ 0x9dd58 <.text+0x8dc58>
   9d188: e2434001     	sub	r4, r3, #1
   9d18c: e0030493     	mul	r3, r3, r4
   9d190: e79f7007     	ldr	r7, [pc, r7]
   9d194: e3130001     	tst	r3, #1
   9d198: e59f3bbc     	ldr	r3, [pc, #0xbbc]        @ 0x9dd5c <.text+0x8dc5c>
   9d19c: e79f3003     	ldr	r3, [pc, r3]
   9d1a0: e5933000     	ldr	r3, [r3]
   9d1a4: e2434001     	sub	r4, r3, #1
   9d1a8: e0030493     	mul	r3, r3, r4
   9d1ac: e3130001     	tst	r3, #1
   9d1b0: 0affffcb     	beq	0x9d0e4 <.text+0x8cfe4> @ imm = #-0xd4
   9d1b4: e5973000     	ldr	r3, [r7]
   9d1b8: e3530009     	cmp	r3, #9
   9d1bc: cafffff5     	bgt	0x9d198 <.text+0x8d098> @ imm = #-0x2c
   9d1c0: eaffffc7     	b	0x9d0e4 <.text+0x8cfe4> @ imm = #-0xe4
   9d1c4: 0054b671     	subseq	r11, r4, r1, ror r6
   9d1c8: 0054b672     	subseq	r11, r4, r2, ror r6
   9d1cc: 0054b69c     	<unknown>
   9d1d0: 0054b6a3     	subseq	r11, r4, r3, lsr #13
   9d1d4: e3a01000     	mov	r1, #0
   9d1d8: e3a02000     	mov	r2, #0
   9d1dc: e59d5018     	ldr	r5, [sp, #0x18]
   9d1e0: e3a04e32     	mov	r4, #800
   9d1e4: e59f8b74     	ldr	r8, [pc, #0xb74]        @ 0x9dd60 <.text+0x8dc60>
   9d1e8: e3550000     	cmp	r5, #0
   9d1ec: e79f8008     	ldr	r8, [pc, r8]
   9d1f0: 0a000001     	beq	0x9d1fc <.text+0x8d0fc> @ imm = #0x4
   9d1f4: e1520001     	cmp	r2, r1
   9d1f8: 9a000007     	bls	0x9d21c <.text+0x8d11c> @ imm = #0x1c
   9d1fc: e28d0030     	add	r0, sp, #48
   9d200: e59d1014     	ldr	r1, [sp, #0x14]
   9d204: e8b000cc     	ldm	r0!, {r2, r3, r6, r7}
   9d208: e8a100cc     	stm	r1!, {r2, r3, r6, r7}
   9d20c: e89000cc     	ldm	r0, {r2, r3, r6, r7}
   9d210: e88100cc     	stm	r1, {r2, r3, r6, r7}
   9d214: e59f7b48     	ldr	r7, [pc, #0xb48]        @ 0x9dd64 <.text+0x8dc64>
   9d218: e79f7007     	ldr	r7, [pc, r7]
   9d21c: e3010388     	movw	r0, #0x1388
   9d220: eb01c745     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x71d14
   9d224: e5990018     	ldr	r0, [r9, #0x18]
   9d228: eb0027f7     	bl	0xa720c <.text+0x9710c> @ imm = #0x9fdc
   9d22c: e58d002c     	str	r0, [sp, #0x2c]
   9d230: eb01850c     	bl	0xfe668 <.text+0xee568> @ imm = #0x61430
   9d234: e2855001     	add	r5, r5, #1
   9d238: e1a06000     	mov	r6, r0
   9d23c: e3500000     	cmp	r0, #0
   9d240: e3a00000     	mov	r0, #0
   9d244: c3000001     	movwgt	r0, #0x1
   9d248: e3550003     	cmp	r5, #3
   9d24c: e3a0a000     	mov	r10, #0
   9d250: e58d5018     	str	r5, [sp, #0x18]
   9d254: 1afffc19     	bne	0x9c2c0 <.text+0x8c1c0> @ imm = #-0xf9c
   9d258: e3560001     	cmp	r6, #1
   9d25c: ba00018e     	blt	0x9d89c <.text+0x8d79c> @ imm = #0x638
   9d260: e59f8b00     	ldr	r8, [pc, #0xb00]        @ 0x9dd68 <.text+0x8dc68>
   9d264: e3a05000     	mov	r5, #0
   9d268: e59faafc     	ldr	r10, [pc, #0xafc]       @ 0x9dd6c <.text+0x8dc6c>
   9d26c: e59f4afc     	ldr	r4, [pc, #0xafc]        @ 0x9dd70 <.text+0x8dc70>
   9d270: e08f8008     	add	r8, pc, r8
   9d274: e59f9af8     	ldr	r9, [pc, #0xaf8]        @ 0x9dd74 <.text+0x8dc74>
   9d278: e08fa00a     	add	r10, pc, r10
   9d27c: e08f4004     	add	r4, pc, r4
   9d280: ed9f8b7a     	vldr	d8, [pc, #488]          @ 0x9d470 <.text+0x8d370>
   9d284: e08f9009     	add	r9, pc, r9
   9d288: ed9f9b7a     	vldr	d9, [pc, #488]          @ 0x9d478 <.text+0x8d378>
   9d28c: ed9fab7b     	vldr	d10, [pc, #492]         @ 0x9d480 <.text+0x8d380>
   9d290: ed9fbb74     	vldr	d11, [pc, #464]         @ 0x9d468 <.text+0x8d368>
   9d294: ea00008b     	b	0x9d4c8 <.text+0x8d3c8> @ imm = #0x22c
   9d298: 005434bc     	ldrheq	r3, [r4], #-76
   9d29c: 00542ee4     	subseq	r2, r4, r4, ror #29
   9d2a0: e59d1020     	ldr	r1, [sp, #0x20]
   9d2a4: e3a00e32     	mov	r0, #800
   9d2a8: e59d2024     	ldr	r2, [sp, #0x24]
   9d2ac: e3a05001     	mov	r5, #1
   9d2b0: e7967004     	ldr	r7, [r6, r4]
   9d2b4: e0232091     	mla	r3, r1, r0, r2
   9d2b8: e59f69f0     	ldr	r6, [pc, #0x9f0]        @ 0x9dcb0 <.text+0x8dbb0>
   9d2bc: e59f09f0     	ldr	r0, [pc, #0x9f0]        @ 0x9dcb4 <.text+0x8dbb4>
   9d2c0: e2877001     	add	r7, r7, #1
   9d2c4: e59f19ec     	ldr	r1, [pc, #0x9ec]        @ 0x9dcb8 <.text+0x8dbb8>
   9d2c8: e08f6006     	add	r6, pc, r6
   9d2cc: e59f29e8     	ldr	r2, [pc, #0x9e8]        @ 0x9dcbc <.text+0x8dbbc>
   9d2d0: e08f0000     	add	r0, pc, r0
   9d2d4: e08f1001     	add	r1, pc, r1
   9d2d8: e5933018     	ldr	r3, [r3, #0x18]
   9d2dc: e08f2002     	add	r2, pc, r2
   9d2e0: e88d0060     	stm	sp, {r5, r6}
   9d2e4: e2833001     	add	r3, r3, #1
   9d2e8: e58d3008     	str	r3, [sp, #0x8]
   9d2ec: e3a030be     	mov	r3, #190
   9d2f0: e58d700c     	str	r7, [sp, #0xc]
   9d2f4: eb017372     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5cdc8
   9d2f8: e30100b4     	movw	r0, #0x10b4
   9d2fc: e3001fa3     	movw	r1, #0xfa3
   9d300: e0890000     	add	r0, r9, r0
   9d304: ebfeb263     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x53674
   9d308: e1a00009     	mov	r0, r9
   9d30c: ebff271b     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x36394
   9d310: e3a00000     	mov	r0, #0
   9d314: ebff9585     	bl	0x82930 <.text+0x72830> @ imm = #-0x1a9ec
   9d318: e59f7928     	ldr	r7, [pc, #0x928]        @ 0x9dc48 <.text+0x8db48>
   9d31c: e3e00000     	mvn	r0, #0
   9d320: e79f7007     	ldr	r7, [pc, r7]
   9d324: e5981000     	ldr	r1, [r8]
   9d328: e2412001     	sub	r2, r1, #1
   9d32c: e0010291     	mul	r1, r1, r2
   9d330: e3110001     	tst	r1, #1
   9d334: 0a000002     	beq	0x9d344 <.text+0x8d244> @ imm = #0x8
   9d338: e5971000     	ldr	r1, [r7]
   9d33c: e3510009     	cmp	r1, #9
   9d340: cafffff7     	bgt	0x9d324 <.text+0x8d224> @ imm = #-0x24
   9d344: e24bd040     	sub	sp, r11, #64
   9d348: ecbd8b08     	vpop	{d8, d9, d10, d11}
   9d34c: e28dd004     	add	sp, sp, #4
   9d350: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   9d354: e5963018     	ldr	r3, [r6, #0x18]
   9d358: e3a06001     	mov	r6, #1
   9d35c: e59f097c     	ldr	r0, [pc, #0x97c]        @ 0x9dce0 <.text+0x8dbe0>
   9d360: e59f197c     	ldr	r1, [pc, #0x97c]        @ 0x9dce4 <.text+0x8dbe4>
   9d364: e2833001     	add	r3, r3, #1
   9d368: e59f2978     	ldr	r2, [pc, #0x978]        @ 0x9dce8 <.text+0x8dbe8>
   9d36c: e08f0000     	add	r0, pc, r0
   9d370: e59f7974     	ldr	r7, [pc, #0x974]        @ 0x9dcec <.text+0x8dbec>
   9d374: e08f1001     	add	r1, pc, r1
   9d378: e08f2002     	add	r2, pc, r2
   9d37c: e08f7007     	add	r7, pc, r7
   9d380: e88d00c0     	stm	sp, {r6, r7}
   9d384: e58d3008     	str	r3, [sp, #0x8]
   9d388: e30031bb     	movw	r3, #0x1bb
   9d38c: ea00000e     	b	0x9d3cc <.text+0x8d2cc> @ imm = #0x38
   9d390: 00542df0     	ldrsheq	r2, [r4], #-208
   9d394: e5963018     	ldr	r3, [r6, #0x18]
   9d398: e3a06001     	mov	r6, #1
   9d39c: e59f0958     	ldr	r0, [pc, #0x958]        @ 0x9dcfc <.text+0x8dbfc>
   9d3a0: e59f1958     	ldr	r1, [pc, #0x958]        @ 0x9dd00 <.text+0x8dc00>
   9d3a4: e2833001     	add	r3, r3, #1
   9d3a8: e59f2954     	ldr	r2, [pc, #0x954]        @ 0x9dd04 <.text+0x8dc04>
   9d3ac: e08f0000     	add	r0, pc, r0
   9d3b0: e59f7950     	ldr	r7, [pc, #0x950]        @ 0x9dd08 <.text+0x8dc08>
   9d3b4: e08f1001     	add	r1, pc, r1
   9d3b8: e08f2002     	add	r2, pc, r2
   9d3bc: e08f7007     	add	r7, pc, r7
   9d3c0: e88d00c0     	stm	sp, {r6, r7}
   9d3c4: e58d3008     	str	r3, [sp, #0x8]
   9d3c8: e3a03d07     	mov	r3, #448
   9d3cc: eb01733c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5ccf0
   9d3d0: e59f7918     	ldr	r7, [pc, #0x918]        @ 0x9dcf0 <.text+0x8dbf0>
   9d3d4: e79f7007     	ldr	r7, [pc, r7]
   9d3d8: ea000011     	b	0x9d424 <.text+0x8d324> @ imm = #0x44
   9d3dc: 00542d8c     	subseq	r2, r4, r12, lsl #27
   9d3e0: e5963018     	ldr	r3, [r6, #0x18]
   9d3e4: e3a06001     	mov	r6, #1
   9d3e8: e59f0928     	ldr	r0, [pc, #0x928]        @ 0x9dd18 <.text+0x8dc18>
   9d3ec: e59f1928     	ldr	r1, [pc, #0x928]        @ 0x9dd1c <.text+0x8dc1c>
   9d3f0: e2833001     	add	r3, r3, #1
   9d3f4: e59f2924     	ldr	r2, [pc, #0x924]        @ 0x9dd20 <.text+0x8dc20>
   9d3f8: e08f0000     	add	r0, pc, r0
   9d3fc: e59f7920     	ldr	r7, [pc, #0x920]        @ 0x9dd24 <.text+0x8dc24>
   9d400: e08f1001     	add	r1, pc, r1
   9d404: e08f2002     	add	r2, pc, r2
   9d408: e08f7007     	add	r7, pc, r7
   9d40c: e88d00c0     	stm	sp, {r6, r7}
   9d410: e59f7910     	ldr	r7, [pc, #0x910]        @ 0x9dd28 <.text+0x8dc28>
   9d414: e79f7007     	ldr	r7, [pc, r7]
   9d418: e58d3008     	str	r3, [sp, #0x8]
   9d41c: e30031c5     	movw	r3, #0x1c5
   9d420: eb017327     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5cc9c
   9d424: e5980000     	ldr	r0, [r8]
   9d428: e59f48fc     	ldr	r4, [pc, #0x8fc]        @ 0x9dd2c <.text+0x8dc2c>
   9d42c: e2401001     	sub	r1, r0, #1
   9d430: e08f4004     	add	r4, pc, r4
   9d434: e0000190     	mul	r0, r0, r1
   9d438: e3100001     	tst	r0, #1
   9d43c: 0a000123     	beq	0x9d8d0 <.text+0x8d7d0> @ imm = #0x48c
   9d440: e5970000     	ldr	r0, [r7]
   9d444: e3500009     	cmp	r0, #9
   9d448: ca00013b     	bgt	0x9d93c <.text+0x8d83c> @ imm = #0x4ec
   9d44c: ea00011f     	b	0x9d8d0 <.text+0x8d7d0> @ imm = #0x47c
   9d450: 00542ca8     	subseq	r2, r4, r8, lsr #25
   9d454: 00542c04     	subseq	r2, r4, r4, lsl #24
   9d458: 00542bcc     	subseq	r2, r4, r12, asr #23
   9d45c: 00542b68     	subseq	r2, r4, r8, ror #22
   9d460: 00542b44     	subseq	r2, r4, r4, asr #22
   9d464: e320f000     	nop
   9d468: 00000000     	andeq	r0, r0, r0
   9d46c: 40590000     	subsmi	r0, r9, r0
		...
   9d478: d2f1a9fc     	rscsle	r10, r1, #252, #18
   9d47c: 3f50624d     	svclo	#0x50624d
   9d480: 66666666     	strbtvs	r6, [r6], -r6, ror #12
   9d484: 40ba8a66     	adcsmi	r8, r10, r6, ror #20
   9d488: 00542b10     	subseq	r2, r4, r0, lsl r11
   9d48c: e3a01003     	mov	r1, #3
   9d490: e2850001     	add	r0, r5, #1
   9d494: e58d1000     	str	r1, [sp]
   9d498: e1a02004     	mov	r2, r4
   9d49c: e59f192c     	ldr	r1, [pc, #0x92c]        @ 0x9ddd0 <.text+0x8dcd0>
   9d4a0: e3003276     	movw	r3, #0x276
   9d4a4: e58d0008     	str	r0, [sp, #0x8]
   9d4a8: e1a00008     	mov	r0, r8
   9d4ac: e08f1001     	add	r1, pc, r1
   9d4b0: e58d1004     	str	r1, [sp, #0x4]
   9d4b4: e1a0100a     	mov	r1, r10
   9d4b8: eb017301     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5cc04
   9d4bc: e2855001     	add	r5, r5, #1
   9d4c0: e1550006     	cmp	r5, r6
   9d4c4: 0a0000f4     	beq	0x9d89c <.text+0x8d79c> @ imm = #0x3d0
   9d4c8: e59d0014     	ldr	r0, [sp, #0x14]
   9d4cc: e0852105     	add	r2, r5, r5, lsl #2
   9d4d0: e5971000     	ldr	r1, [r7]
   9d4d4: e5900018     	ldr	r0, [r0, #0x18]
   9d4d8: e351000a     	cmp	r1, #10
   9d4dc: e3a01000     	mov	r1, #0
   9d4e0: e080c182     	add	r12, r0, r2, lsl #3
   9d4e4: b3001001     	movwlt	r1, #0x1
   9d4e8: e5dc2004     	ldrb	r2, [r12, #0x4]
   9d4ec: e3520000     	cmp	r2, #0
   9d4f0: 0a000069     	beq	0x9d69c <.text+0x8d59c> @ imm = #0x1a4
   9d4f4: e59f1884     	ldr	r1, [pc, #0x884]        @ 0x9dd80 <.text+0x8dc80>
   9d4f8: e79f1001     	ldr	r1, [pc, r1]
   9d4fc: e5911000     	ldr	r1, [r1]
   9d500: e2412001     	sub	r2, r1, #1
   9d504: e0020291     	mul	r2, r1, r2
   9d508: e5dc1005     	ldrb	r1, [r12, #0x5]
   9d50c: e3120001     	tst	r2, #1
   9d510: 0a000002     	beq	0x9d520 <.text+0x8d420> @ imm = #0x8
   9d514: e5972000     	ldr	r2, [r7]
   9d518: e3520009     	cmp	r2, #9
   9d51c: cafffff4     	bgt	0x9d4f4 <.text+0x8d3f4> @ imm = #-0x30
   9d520: e59d002c     	ldr	r0, [sp, #0x2c]
   9d524: e3510000     	cmp	r1, #0
   9d528: 0affffd7     	beq	0x9d48c <.text+0x8d38c> @ imm = #-0xa4
   9d52c: e59f1850     	ldr	r1, [pc, #0x850]        @ 0x9dd84 <.text+0x8dc84>
   9d530: e79f1001     	ldr	r1, [pc, r1]
   9d534: e5911000     	ldr	r1, [r1]
   9d538: e2412001     	sub	r2, r1, #1
   9d53c: e0010291     	mul	r1, r1, r2
   9d540: e3110001     	tst	r1, #1
   9d544: e59f183c     	ldr	r1, [pc, #0x83c]        @ 0x9dd88 <.text+0x8dc88>
   9d548: e79f1001     	ldr	r1, [pc, r1]
   9d54c: e5911000     	ldr	r1, [r1]
   9d550: e2412001     	sub	r2, r1, #1
   9d554: e0020291     	mul	r2, r1, r2
   9d558: e5901010     	ldr	r1, [r0, #0x10]
   9d55c: e3120001     	tst	r2, #1
   9d560: 0a000002     	beq	0x9d570 <.text+0x8d470> @ imm = #0x8
   9d564: e5972000     	ldr	r2, [r7]
   9d568: e3520009     	cmp	r2, #9
   9d56c: cafffff4     	bgt	0x9d544 <.text+0x8d444> @ imm = #-0x30
   9d570: e3510001     	cmp	r1, #1
   9d574: baffffd0     	blt	0x9d4bc <.text+0x8d3bc> @ imm = #-0xc0
   9d578: e59f180c     	ldr	r1, [pc, #0x80c]        @ 0x9dd8c <.text+0x8dc8c>
   9d57c: e1a0e006     	mov	lr, r6
   9d580: e79f1001     	ldr	r1, [pc, r1]
   9d584: e5911000     	ldr	r1, [r1]
   9d588: e2412001     	sub	r2, r1, #1
   9d58c: e0010291     	mul	r1, r1, r2
   9d590: e3110001     	tst	r1, #1
   9d594: e59f17f4     	ldr	r1, [pc, #0x7f4]        @ 0x9dd90 <.text+0x8dc90>
   9d598: e79f1001     	ldr	r1, [pc, r1]
   9d59c: e5911000     	ldr	r1, [r1]
   9d5a0: e2412001     	sub	r2, r1, #1
   9d5a4: e0010291     	mul	r1, r1, r2
   9d5a8: e3110001     	tst	r1, #1
   9d5ac: 0a000002     	beq	0x9d5bc <.text+0x8d4bc> @ imm = #0x8
   9d5b0: e5971000     	ldr	r1, [r7]
   9d5b4: e3510009     	cmp	r1, #9
   9d5b8: cafffff5     	bgt	0x9d594 <.text+0x8d494> @ imm = #-0x2c
   9d5bc: eeb00b48     	vmov.f64	d0, d8
   9d5c0: e59d002c     	ldr	r0, [sp, #0x2c]
   9d5c4: e28c2020     	add	r2, r12, #32
   9d5c8: e3a03000     	mov	r3, #0
   9d5cc: e3a07000     	mov	r7, #0
   9d5d0: e3a01000     	mov	r1, #0
   9d5d4: e5926000     	ldr	r6, [r2]
   9d5d8: e2877001     	add	r7, r7, #1
   9d5dc: e0866003     	add	r6, r6, r3
   9d5e0: e2833038     	add	r3, r3, #56
   9d5e4: ed961a09     	vldr	s2, [r6, #36]
   9d5e8: eeb81bc1     	vcvt.f64.s32	d1, s2
   9d5ec: e5d64030     	ldrb	r4, [r6, #0x30]
   9d5f0: ed962b0a     	vldr	d2, [r6, #40]
   9d5f4: eeb42bc9     	vcmpe.f64	d2, d9
   9d5f8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   9d5fc: 4eb02b4a     	vmovmi.f64	d2, d10
   9d600: e3540000     	cmp	r4, #0
   9d604: ee811b02     	vdiv.f64	d1, d1, d2
   9d608: ee211b0b     	vmul.f64	d1, d1, d11
   9d60c: ee302b01     	vadd.f64	d2, d0, d1
   9d610: ed861b04     	vstr	d1, [r6, #16]
   9d614: e2246001     	eor	r6, r4, #1
   9d618: 0eb00b42     	vmoveq.f64	d0, d2
   9d61c: e0811006     	add	r1, r1, r6
   9d620: e5906010     	ldr	r6, [r0, #0x10]
   9d624: e1570006     	cmp	r7, r6
   9d628: baffffe9     	blt	0x9d5d4 <.text+0x8d4d4> @ imm = #-0x5c
   9d62c: e59f2760     	ldr	r2, [pc, #0x760]        @ 0x9dd94 <.text+0x8dc94>
   9d630: e79f2002     	ldr	r2, [pc, r2]
   9d634: e5922000     	ldr	r2, [r2]
   9d638: e59f7758     	ldr	r7, [pc, #0x758]        @ 0x9dd98 <.text+0x8dc98>
   9d63c: e2423001     	sub	r3, r2, #1
   9d640: e0020392     	mul	r2, r2, r3
   9d644: e79f7007     	ldr	r7, [pc, r7]
   9d648: e3120001     	tst	r2, #1
   9d64c: e59f2748     	ldr	r2, [pc, #0x748]        @ 0x9dd9c <.text+0x8dc9c>
   9d650: e79f2002     	ldr	r2, [pc, r2]
   9d654: e5922000     	ldr	r2, [r2]
   9d658: e2423001     	sub	r3, r2, #1
   9d65c: e0020392     	mul	r2, r2, r3
   9d660: e3120001     	tst	r2, #1
   9d664: 0a000002     	beq	0x9d674 <.text+0x8d574> @ imm = #0x8
   9d668: e5972000     	ldr	r2, [r7]
   9d66c: e3520009     	cmp	r2, #9
   9d670: cafffff5     	bgt	0x9d64c <.text+0x8d54c> @ imm = #-0x2c
   9d674: e59f4724     	ldr	r4, [pc, #0x724]        @ 0x9dda0 <.text+0x8dca0>
   9d678: e3510000     	cmp	r1, #0
   9d67c: e1a0600e     	mov	r6, lr
   9d680: e08f4004     	add	r4, pc, r4
   9d684: 0affff8c     	beq	0x9d4bc <.text+0x8d3bc> @ imm = #-0x1d0
   9d688: ee011a10     	vmov	s2, r1
   9d68c: eeb81bc1     	vcvt.f64.s32	d1, s2
   9d690: ee800b01     	vdiv.f64	d0, d0, d1
   9d694: ed8c0b04     	vstr	d0, [r12, #16]
   9d698: eaffff87     	b	0x9d4bc <.text+0x8d3bc> @ imm = #-0x1e4
   9d69c: e59f06d4     	ldr	r0, [pc, #0x6d4]        @ 0x9dd78 <.text+0x8dc78>
   9d6a0: e79f0000     	ldr	r0, [pc, r0]
   9d6a4: e5900000     	ldr	r0, [r0]
   9d6a8: e2402001     	sub	r2, r0, #1
   9d6ac: e0000290     	mul	r0, r0, r2
   9d6b0: e3a02001     	mov	r2, #1
   9d6b4: e1c20000     	bic	r0, r2, r0
   9d6b8: e1900001     	orrs	r0, r0, r1
   9d6bc: 0a000012     	beq	0x9d70c <.text+0x8d60c> @ imm = #0x48
   9d6c0: e3a01003     	mov	r1, #3
   9d6c4: e2850001     	add	r0, r5, #1
   9d6c8: e88d0202     	stm	sp, {r1, r9}
   9d6cc: e1a0100a     	mov	r1, r10
   9d6d0: e1a02004     	mov	r2, r4
   9d6d4: e58d0008     	str	r0, [sp, #0x8]
   9d6d8: e1a00008     	mov	r0, r8
   9d6dc: e3003271     	movw	r3, #0x271
   9d6e0: eb017277     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c9dc
   9d6e4: e59f0690     	ldr	r0, [pc, #0x690]        @ 0x9dd7c <.text+0x8dc7c>
   9d6e8: e79f0000     	ldr	r0, [pc, r0]
   9d6ec: e5900000     	ldr	r0, [r0]
   9d6f0: e2401001     	sub	r1, r0, #1
   9d6f4: e0000190     	mul	r0, r0, r1
   9d6f8: e3100001     	tst	r0, #1
   9d6fc: 0affff6e     	beq	0x9d4bc <.text+0x8d3bc> @ imm = #-0x248
   9d700: e5970000     	ldr	r0, [r7]
   9d704: e350000a     	cmp	r0, #10
   9d708: baffff6b     	blt	0x9d4bc <.text+0x8d3bc> @ imm = #-0x254
   9d70c: e3a01003     	mov	r1, #3
   9d710: e2850001     	add	r0, r5, #1
   9d714: e88d0202     	stm	sp, {r1, r9}
   9d718: e1a0100a     	mov	r1, r10
   9d71c: e1a02004     	mov	r2, r4
   9d720: e58d0008     	str	r0, [sp, #0x8]
   9d724: e1a00008     	mov	r0, r8
   9d728: e3003271     	movw	r3, #0x271
   9d72c: eb017264     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c990
   9d730: eaffffe2     	b	0x9d6c0 <.text+0x8d5c0> @ imm = #-0x78
   9d734: 00542a60     	subseq	r2, r4, r0, ror #20
   9d738: 00542a2c     	subseq	r2, r4, r12, lsr #20
   9d73c: e5980000     	ldr	r0, [r8]
   9d740: e59f44e8     	ldr	r4, [pc, #0x4e8]        @ 0x9dc30 <.text+0x8db30>
   9d744: e2401001     	sub	r1, r0, #1
   9d748: e59d6024     	ldr	r6, [sp, #0x24]
   9d74c: e08f4004     	add	r4, pc, r4
   9d750: e0000190     	mul	r0, r0, r1
   9d754: e3100001     	tst	r0, #1
   9d758: 0a00008b     	beq	0x9d98c <.text+0x8d88c> @ imm = #0x22c
   9d75c: e59f04d0     	ldr	r0, [pc, #0x4d0]        @ 0x9dc34 <.text+0x8db34>
   9d760: e79f0000     	ldr	r0, [pc, r0]
   9d764: e5900000     	ldr	r0, [r0]
   9d768: e3500009     	cmp	r0, #9
   9d76c: ca0000a0     	bgt	0x9d9f4 <.text+0x8d8f4> @ imm = #0x280
   9d770: ea000085     	b	0x9d98c <.text+0x8d88c> @ imm = #0x214
   9d774: 00542a0c     	subseq	r2, r4, r12, lsl #20
   9d778: 00001f00     	andeq	r1, r0, r0, lsl #30
   9d77c: e3a00e32     	mov	r0, #800
   9d780: e59d1024     	ldr	r1, [sp, #0x24]
   9d784: e0201095     	mla	r0, r5, r0, r1
   9d788: e3a06001     	mov	r6, #1
   9d78c: e5903018     	ldr	r3, [r0, #0x18]
   9d790: e59f04b4     	ldr	r0, [pc, #0x4b4]        @ 0x9dc4c <.text+0x8db4c>
   9d794: e59f14b4     	ldr	r1, [pc, #0x4b4]        @ 0x9dc50 <.text+0x8db50>
   9d798: e2833001     	add	r3, r3, #1
   9d79c: e59f24b0     	ldr	r2, [pc, #0x4b0]        @ 0x9dc54 <.text+0x8db54>
   9d7a0: e08f0000     	add	r0, pc, r0
   9d7a4: e59f74ac     	ldr	r7, [pc, #0x4ac]        @ 0x9dc58 <.text+0x8db58>
   9d7a8: e08f1001     	add	r1, pc, r1
   9d7ac: e08f2002     	add	r2, pc, r2
   9d7b0: e08f7007     	add	r7, pc, r7
   9d7b4: e88d00c0     	stm	sp, {r6, r7}
   9d7b8: e58d3008     	str	r3, [sp, #0x8]
   9d7bc: e3a0309d     	mov	r3, #157
   9d7c0: eafffecb     	b	0x9d2f4 <.text+0x8d1f4> @ imm = #-0x4d4
   9d7c4: 00001ed8     	ldrdeq	r1, r2, [r0], -r8
   9d7c8: e3a00e32     	mov	r0, #800
   9d7cc: e59d1024     	ldr	r1, [sp, #0x24]
   9d7d0: e0201095     	mla	r0, r5, r0, r1
   9d7d4: e3a06001     	mov	r6, #1
   9d7d8: e5903018     	ldr	r3, [r0, #0x18]
   9d7dc: e59f0478     	ldr	r0, [pc, #0x478]        @ 0x9dc5c <.text+0x8db5c>
   9d7e0: e59f1478     	ldr	r1, [pc, #0x478]        @ 0x9dc60 <.text+0x8db60>
   9d7e4: e2833001     	add	r3, r3, #1
   9d7e8: e59f2474     	ldr	r2, [pc, #0x474]        @ 0x9dc64 <.text+0x8db64>
   9d7ec: e08f0000     	add	r0, pc, r0
   9d7f0: e59f7470     	ldr	r7, [pc, #0x470]        @ 0x9dc68 <.text+0x8db68>
   9d7f4: e08f1001     	add	r1, pc, r1
   9d7f8: e08f2002     	add	r2, pc, r2
   9d7fc: e08f7007     	add	r7, pc, r7
   9d800: e88d00c0     	stm	sp, {r6, r7}
   9d804: e58d3008     	str	r3, [sp, #0x8]
   9d808: e3a030a4     	mov	r3, #164
   9d80c: eafffeb8     	b	0x9d2f4 <.text+0x8d1f4> @ imm = #-0x520
   9d810: e59f4454     	ldr	r4, [pc, #0x454]        @ 0x9dc6c <.text+0x8db6c>
   9d814: e3510000     	cmp	r1, #0
   9d818: e08f4004     	add	r4, pc, r4
   9d81c: 0a0000f1     	beq	0x9dbe8 <.text+0x8dae8> @ imm = #0x3c4
   9d820: ea0000d6     	b	0x9db80 <.text+0x8da80> @ imm = #0x358
   9d824: e5980000     	ldr	r0, [r8]
   9d828: e59f445c     	ldr	r4, [pc, #0x45c]        @ 0x9dc8c <.text+0x8db8c>
   9d82c: e2401001     	sub	r1, r0, #1
   9d830: e59d5020     	ldr	r5, [sp, #0x20]
   9d834: e08f4004     	add	r4, pc, r4
   9d838: e0000190     	mul	r0, r0, r1
   9d83c: e3100001     	tst	r0, #1
   9d840: 0a000081     	beq	0x9da4c <.text+0x8d94c> @ imm = #0x204
   9d844: e59f0444     	ldr	r0, [pc, #0x444]        @ 0x9dc90 <.text+0x8db90>
   9d848: e79f0000     	ldr	r0, [pc, r0]
   9d84c: e5900000     	ldr	r0, [r0]
   9d850: e3500009     	cmp	r0, #9
   9d854: ca000096     	bgt	0x9dab4 <.text+0x8d9b4> @ imm = #0x258
   9d858: ea00007b     	b	0x9da4c <.text+0x8d94c> @ imm = #0x1ec
   9d85c: e59f045c     	ldr	r0, [pc, #0x45c]        @ 0x9dcc0 <.text+0x8dbc0>
   9d860: e3a07001     	mov	r7, #1
   9d864: e59f1458     	ldr	r1, [pc, #0x458]        @ 0x9dcc4 <.text+0x8dbc4>
   9d868: e59f2458     	ldr	r2, [pc, #0x458]        @ 0x9dcc8 <.text+0x8dbc8>
   9d86c: e08f0000     	add	r0, pc, r0
   9d870: e59f3454     	ldr	r3, [pc, #0x454]        @ 0x9dccc <.text+0x8dbcc>
   9d874: e08f1001     	add	r1, pc, r1
   9d878: e08f2002     	add	r2, pc, r2
   9d87c: e58d7000     	str	r7, [sp]
   9d880: e08f3003     	add	r3, pc, r3
   9d884: e58d3004     	str	r3, [sp, #0x4]
   9d888: e30032a2     	movw	r3, #0x2a2
   9d88c: eb01720c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c830
   9d890: e30100b4     	movw	r0, #0x10b4
   9d894: e3001fa4     	movw	r1, #0xfa4
   9d898: eafffe98     	b	0x9d300 <.text+0x8d200> @ imm = #-0x5a0
   9d89c: e59f8500     	ldr	r8, [pc, #0x500]        @ 0x9dda4 <.text+0x8dca4>
   9d8a0: e79f8008     	ldr	r8, [pc, r8]
   9d8a4: e5980000     	ldr	r0, [r8]
   9d8a8: e59f44f8     	ldr	r4, [pc, #0x4f8]        @ 0x9dda8 <.text+0x8dca8>
   9d8ac: e2401001     	sub	r1, r0, #1
   9d8b0: e08f4004     	add	r4, pc, r4
   9d8b4: e0000190     	mul	r0, r0, r1
   9d8b8: e3100001     	tst	r0, #1
   9d8bc: 0a000091     	beq	0x9db08 <.text+0x8da08> @ imm = #0x244
   9d8c0: e5970000     	ldr	r0, [r7]
   9d8c4: e3500009     	cmp	r0, #9
   9d8c8: ca0000a1     	bgt	0x9db54 <.text+0x8da54> @ imm = #0x284
   9d8cc: ea00008d     	b	0x9db08 <.text+0x8da08> @ imm = #0x234
   9d8d0: e59f0458     	ldr	r0, [pc, #0x458]        @ 0x9dd30 <.text+0x8dc30>
   9d8d4: e3a03001     	mov	r3, #1
   9d8d8: e59f1454     	ldr	r1, [pc, #0x454]        @ 0x9dd34 <.text+0x8dc34>
   9d8dc: e59f2454     	ldr	r2, [pc, #0x454]        @ 0x9dd38 <.text+0x8dc38>
   9d8e0: e08f0000     	add	r0, pc, r0
   9d8e4: e08f1001     	add	r1, pc, r1
   9d8e8: e88d0018     	stm	sp, {r3, r4}
   9d8ec: e08f2002     	add	r2, pc, r2
   9d8f0: e3a03fab     	mov	r3, #684
   9d8f4: eb0171f2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c7c8
   9d8f8: e30100b4     	movw	r0, #0x10b4
   9d8fc: e3001fa5     	movw	r1, #0xfa5
   9d900: e0890000     	add	r0, r9, r0
   9d904: ebfeb0e3     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x53c74
   9d908: e1a00009     	mov	r0, r9
   9d90c: ebff259b     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x36994
   9d910: e3a00000     	mov	r0, #0
   9d914: ebff9405     	bl	0x82930 <.text+0x72830> @ imm = #-0x1afec
   9d918: e5980000     	ldr	r0, [r8]
   9d91c: e2401001     	sub	r1, r0, #1
   9d920: e0010190     	mul	r1, r0, r1
   9d924: e3e00000     	mvn	r0, #0
   9d928: e3110001     	tst	r1, #1
   9d92c: 0afffe7c     	beq	0x9d324 <.text+0x8d224> @ imm = #-0x610
   9d930: e5971000     	ldr	r1, [r7]
   9d934: e351000a     	cmp	r1, #10
   9d938: bafffe79     	blt	0x9d324 <.text+0x8d224> @ imm = #-0x61c
   9d93c: e59f03f8     	ldr	r0, [pc, #0x3f8]        @ 0x9dd3c <.text+0x8dc3c>
   9d940: e3a03001     	mov	r3, #1
   9d944: e59f13f4     	ldr	r1, [pc, #0x3f4]        @ 0x9dd40 <.text+0x8dc40>
   9d948: e59f23f4     	ldr	r2, [pc, #0x3f4]        @ 0x9dd44 <.text+0x8dc44>
   9d94c: e08f0000     	add	r0, pc, r0
   9d950: e08f1001     	add	r1, pc, r1
   9d954: e88d0018     	stm	sp, {r3, r4}
   9d958: e08f2002     	add	r2, pc, r2
   9d95c: e3a03fab     	mov	r3, #684
   9d960: eb0171d7     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c75c
   9d964: e30100b4     	movw	r0, #0x10b4
   9d968: e3001fa5     	movw	r1, #0xfa5
   9d96c: e0890000     	add	r0, r9, r0
   9d970: ebfeb0c8     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x53ce0
   9d974: e1a00009     	mov	r0, r9
   9d978: ebff2580     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x36a00
   9d97c: e3a00000     	mov	r0, #0
   9d980: ebff93ea     	bl	0x82930 <.text+0x72830> @ imm = #-0x1b058
   9d984: eaffffd1     	b	0x9d8d0 <.text+0x8d7d0> @ imm = #-0xbc
   9d988: 00542780     	subseq	r2, r4, r0, lsl #15
   9d98c: e3a00e32     	mov	r0, #800
   9d990: e3a07001     	mov	r7, #1
   9d994: e0206095     	mla	r0, r5, r0, r6
   9d998: e5903018     	ldr	r3, [r0, #0x18]
   9d99c: e59f0294     	ldr	r0, [pc, #0x294]        @ 0x9dc38 <.text+0x8db38>
   9d9a0: e59f1294     	ldr	r1, [pc, #0x294]        @ 0x9dc3c <.text+0x8db3c>
   9d9a4: e2833001     	add	r3, r3, #1
   9d9a8: e59f2290     	ldr	r2, [pc, #0x290]        @ 0x9dc40 <.text+0x8db40>
   9d9ac: e08f0000     	add	r0, pc, r0
   9d9b0: e08f1001     	add	r1, pc, r1
   9d9b4: e58d3008     	str	r3, [sp, #0x8]
   9d9b8: e08f2002     	add	r2, pc, r2
   9d9bc: e3a03096     	mov	r3, #150
   9d9c0: e58d7000     	str	r7, [sp]
   9d9c4: e58d4004     	str	r4, [sp, #0x4]
   9d9c8: eb0171bd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c6f4
   9d9cc: e5980000     	ldr	r0, [r8]
   9d9d0: e2401001     	sub	r1, r0, #1
   9d9d4: e0000190     	mul	r0, r0, r1
   9d9d8: e3100001     	tst	r0, #1
   9d9dc: 0afffe45     	beq	0x9d2f8 <.text+0x8d1f8> @ imm = #-0x6ec
   9d9e0: e59f025c     	ldr	r0, [pc, #0x25c]        @ 0x9dc44 <.text+0x8db44>
   9d9e4: e79f0000     	ldr	r0, [pc, r0]
   9d9e8: e5900000     	ldr	r0, [r0]
   9d9ec: e350000a     	cmp	r0, #10
   9d9f0: bafffe40     	blt	0x9d2f8 <.text+0x8d1f8> @ imm = #-0x700
   9d9f4: e3a00e32     	mov	r0, #800
   9d9f8: e3a07001     	mov	r7, #1
   9d9fc: e0206095     	mla	r0, r5, r0, r6
   9da00: e5903018     	ldr	r3, [r0, #0x18]
   9da04: e59f03ac     	ldr	r0, [pc, #0x3ac]        @ 0x9ddb8 <.text+0x8dcb8>
   9da08: e59f13ac     	ldr	r1, [pc, #0x3ac]        @ 0x9ddbc <.text+0x8dcbc>
   9da0c: e2833001     	add	r3, r3, #1
   9da10: e59f23a8     	ldr	r2, [pc, #0x3a8]        @ 0x9ddc0 <.text+0x8dcc0>
   9da14: e08f0000     	add	r0, pc, r0
   9da18: e08f1001     	add	r1, pc, r1
   9da1c: e58d3008     	str	r3, [sp, #0x8]
   9da20: e08f2002     	add	r2, pc, r2
   9da24: e3a03096     	mov	r3, #150
   9da28: e58d7000     	str	r7, [sp]
   9da2c: e58d4004     	str	r4, [sp, #0x4]
   9da30: eb0171a3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c68c
   9da34: eaffffd4     	b	0x9d98c <.text+0x8d88c> @ imm = #-0xb0
   9da38: 0054b051     	subseq	r11, r4, r1, asr r0
   9da3c: 0054ae58     	subseq	r10, r4, r8, asr lr
   9da40: 0054ae0a     	subseq	r10, r4, r10, lsl #28
   9da44: 0054ae34     	subseq	r10, r4, r4, lsr lr
   9da48: 0054afdf     	ldrsbeq	r10, [r4], #-255
   9da4c: e3a00e32     	mov	r0, #800
   9da50: e3a07001     	mov	r7, #1
   9da54: e0206095     	mla	r0, r5, r0, r6
   9da58: e5903018     	ldr	r3, [r0, #0x18]
   9da5c: e59f0230     	ldr	r0, [pc, #0x230]        @ 0x9dc94 <.text+0x8db94>
   9da60: e59f1230     	ldr	r1, [pc, #0x230]        @ 0x9dc98 <.text+0x8db98>
   9da64: e2833001     	add	r3, r3, #1
   9da68: e59f222c     	ldr	r2, [pc, #0x22c]        @ 0x9dc9c <.text+0x8db9c>
   9da6c: e08f0000     	add	r0, pc, r0
   9da70: e08f1001     	add	r1, pc, r1
   9da74: e58d3008     	str	r3, [sp, #0x8]
   9da78: e08f2002     	add	r2, pc, r2
   9da7c: e3a030b2     	mov	r3, #178
   9da80: e58d7000     	str	r7, [sp]
   9da84: e58d4004     	str	r4, [sp, #0x4]
   9da88: eb01718d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c634
   9da8c: e5980000     	ldr	r0, [r8]
   9da90: e2401001     	sub	r1, r0, #1
   9da94: e0000190     	mul	r0, r0, r1
   9da98: e3100001     	tst	r0, #1
   9da9c: 0afffe15     	beq	0x9d2f8 <.text+0x8d1f8> @ imm = #-0x7ac
   9daa0: e59f01f8     	ldr	r0, [pc, #0x1f8]        @ 0x9dca0 <.text+0x8dba0>
   9daa4: e79f0000     	ldr	r0, [pc, r0]
   9daa8: e5900000     	ldr	r0, [r0]
   9daac: e350000a     	cmp	r0, #10
   9dab0: bafffe10     	blt	0x9d2f8 <.text+0x8d1f8> @ imm = #-0x7c0
   9dab4: e3a00e32     	mov	r0, #800
   9dab8: e3a07001     	mov	r7, #1
   9dabc: e0206095     	mla	r0, r5, r0, r6
   9dac0: e5903018     	ldr	r3, [r0, #0x18]
   9dac4: e59f01d8     	ldr	r0, [pc, #0x1d8]        @ 0x9dca4 <.text+0x8dba4>
   9dac8: e59f11d8     	ldr	r1, [pc, #0x1d8]        @ 0x9dca8 <.text+0x8dba8>
   9dacc: e2833001     	add	r3, r3, #1
   9dad0: e59f21d4     	ldr	r2, [pc, #0x1d4]        @ 0x9dcac <.text+0x8dbac>
   9dad4: e08f0000     	add	r0, pc, r0
   9dad8: e08f1001     	add	r1, pc, r1
   9dadc: e58d3008     	str	r3, [sp, #0x8]
   9dae0: e08f2002     	add	r2, pc, r2
   9dae4: e3a030b2     	mov	r3, #178
   9dae8: e58d7000     	str	r7, [sp]
   9daec: e58d4004     	str	r4, [sp, #0x4]
   9daf0: eb017173     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c5cc
   9daf4: eaffffd4     	b	0x9da4c <.text+0x8d94c> @ imm = #-0xb0
   9daf8: 0054adb5     	ldrheq	r10, [r4], #-213
   9dafc: 0054adba     	ldrheq	r10, [r4], #-218
   9db00: 0054ade4     	subseq	r10, r4, r4, ror #27
   9db04: 00542670     	subseq	r2, r4, r0, ror r6
   9db08: e59f029c     	ldr	r0, [pc, #0x29c]        @ 0x9ddac <.text+0x8dcac>
   9db0c: e3a03003     	mov	r3, #3
   9db10: e59f1298     	ldr	r1, [pc, #0x298]        @ 0x9ddb0 <.text+0x8dcb0>
   9db14: e59f2298     	ldr	r2, [pc, #0x298]        @ 0x9ddb4 <.text+0x8dcb4>
   9db18: e08f0000     	add	r0, pc, r0
   9db1c: e08f1001     	add	r1, pc, r1
   9db20: e88d0018     	stm	sp, {r3, r4}
   9db24: e08f2002     	add	r2, pc, r2
   9db28: e30032bb     	movw	r3, #0x2bb
   9db2c: eb017164     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c590
   9db30: e5980000     	ldr	r0, [r8]
   9db34: e2401001     	sub	r1, r0, #1
   9db38: e0010190     	mul	r1, r0, r1
   9db3c: e3a00000     	mov	r0, #0
   9db40: e3110001     	tst	r1, #1
   9db44: 0afffdf6     	beq	0x9d324 <.text+0x8d224> @ imm = #-0x828
   9db48: e5971000     	ldr	r1, [r7]
   9db4c: e3510009     	cmp	r1, #9
   9db50: dafffdf3     	ble	0x9d324 <.text+0x8d224> @ imm = #-0x834
   9db54: e59f0268     	ldr	r0, [pc, #0x268]        @ 0x9ddc4 <.text+0x8dcc4>
   9db58: e3a03003     	mov	r3, #3
   9db5c: e59f1264     	ldr	r1, [pc, #0x264]        @ 0x9ddc8 <.text+0x8dcc8>
   9db60: e59f2264     	ldr	r2, [pc, #0x264]        @ 0x9ddcc <.text+0x8dccc>
   9db64: e08f0000     	add	r0, pc, r0
   9db68: e08f1001     	add	r1, pc, r1
   9db6c: e88d0018     	stm	sp, {r3, r4}
   9db70: e08f2002     	add	r2, pc, r2
   9db74: e30032bb     	movw	r3, #0x2bb
   9db78: eb017151     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c544
   9db7c: eaffffe1     	b	0x9db08 <.text+0x8da08> @ imm = #-0x7c
   9db80: e3a00e32     	mov	r0, #800
   9db84: e3a07001     	mov	r7, #1
   9db88: e0206095     	mla	r0, r5, r0, r6
   9db8c: e5903018     	ldr	r3, [r0, #0x18]
   9db90: e59f00d8     	ldr	r0, [pc, #0xd8]         @ 0x9dc70 <.text+0x8db70>
   9db94: e59f10d8     	ldr	r1, [pc, #0xd8]         @ 0x9dc74 <.text+0x8db74>
   9db98: e2833001     	add	r3, r3, #1
   9db9c: e59f20d4     	ldr	r2, [pc, #0xd4]         @ 0x9dc78 <.text+0x8db78>
   9dba0: e08f0000     	add	r0, pc, r0
   9dba4: e08f1001     	add	r1, pc, r1
   9dba8: e58d3008     	str	r3, [sp, #0x8]
   9dbac: e08f2002     	add	r2, pc, r2
   9dbb0: e3a030ab     	mov	r3, #171
   9dbb4: e58d7000     	str	r7, [sp]
   9dbb8: e58d4004     	str	r4, [sp, #0x4]
   9dbbc: eb017140     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c500
   9dbc0: e5980000     	ldr	r0, [r8]
   9dbc4: e2401001     	sub	r1, r0, #1
   9dbc8: e0000190     	mul	r0, r0, r1
   9dbcc: e3100001     	tst	r0, #1
   9dbd0: 0afffdc8     	beq	0x9d2f8 <.text+0x8d1f8> @ imm = #-0x8e0
   9dbd4: e59f00a0     	ldr	r0, [pc, #0xa0]         @ 0x9dc7c <.text+0x8db7c>
   9dbd8: e79f0000     	ldr	r0, [pc, r0]
   9dbdc: e5900000     	ldr	r0, [r0]
   9dbe0: e350000a     	cmp	r0, #10
   9dbe4: bafffdc3     	blt	0x9d2f8 <.text+0x8d1f8> @ imm = #-0x8f4
   9dbe8: e3a00e32     	mov	r0, #800
   9dbec: e3a07001     	mov	r7, #1
   9dbf0: e0206095     	mla	r0, r5, r0, r6
   9dbf4: e5903018     	ldr	r3, [r0, #0x18]
   9dbf8: e59f0080     	ldr	r0, [pc, #0x80]         @ 0x9dc80 <.text+0x8db80>
   9dbfc: e59f1080     	ldr	r1, [pc, #0x80]         @ 0x9dc84 <.text+0x8db84>
   9dc00: e2833001     	add	r3, r3, #1
   9dc04: e59f207c     	ldr	r2, [pc, #0x7c]         @ 0x9dc88 <.text+0x8db88>
   9dc08: e08f0000     	add	r0, pc, r0
   9dc0c: e08f1001     	add	r1, pc, r1
   9dc10: e58d3008     	str	r3, [sp, #0x8]
   9dc14: e08f2002     	add	r2, pc, r2
   9dc18: e3a030ab     	mov	r3, #171
   9dc1c: e58d7000     	str	r7, [sp]
   9dc20: e58d4004     	str	r4, [sp, #0x4]
   9dc24: eb017126     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x5c498
   9dc28: eaffffd4     	b	0x9db80 <.text+0x8da80> @ imm = #-0xb0
   9dc2c: 00542a9c     	<unknown>
   9dc30: 0054a294     	<unknown>
   9dc34: 00541a3c     	subseq	r1, r4, r12, lsr r10
   9dc38: 00549f6c     	subseq	r9, r4, r12, ror #30
   9dc3c: 00549f1e     	subseq	r9, r4, lr, lsl pc
   9dc40: 00549f44     	subseq	r9, r4, r4, asr #30
   9dc44: 005417b8     	ldrheq	r1, [r4], #-120
   9dc48: 00541e7c     	subseq	r1, r4, r12, ror lr
   9dc4c: 0054a178     	subseq	r10, r4, r8, ror r1
   9dc50: 0054a126     	subseq	r10, r4, r6, lsr #2
   9dc54: 0054a150     	subseq	r10, r4, r0, asr r1
   9dc58: 0054a252     	subseq	r10, r4, r2, asr r2
   9dc5c: 0054a12c     	subseq	r10, r4, r12, lsr #2
   9dc60: 0054a0da     	ldrsbeq	r10, [r4], #-10
   9dc64: 0054a104     	subseq	r10, r4, r4, lsl #2
   9dc68: 0054a230     	subseq	r10, r4, r0, lsr r2
   9dc6c: 0054a23e     	subseq	r10, r4, lr, lsr r2
   9dc70: 00549d78     	subseq	r9, r4, r8, ror sp
   9dc74: 00549d2a     	subseq	r9, r4, r10, lsr #26
   9dc78: 00549d50     	subseq	r9, r4, r0, asr sp
   9dc7c: 005415c4     	subseq	r1, r4, r4, asr #11
   9dc80: 00549d10     	subseq	r9, r4, r0, lsl sp
   9dc84: 00549cc2     	subseq	r9, r4, r2, asr #25
   9dc88: 00549ce8     	subseq	r9, r4, r8, ror #25
   9dc8c: 0054a24c     	subseq	r10, r4, r12, asr #4
   9dc90: 00541954     	subseq	r1, r4, r4, asr r9
   9dc94: 00549eac     	subseq	r9, r4, r12, lsr #29
   9dc98: 00549e5e     	subseq	r9, r4, lr, asr lr
   9dc9c: 00549e84     	subseq	r9, r4, r4, lsl #29
   9dca0: 005416f8     	ldrsheq	r1, [r4], #-104
   9dca4: 00549e44     	subseq	r9, r4, r4, asr #28
   9dca8: 00549df6     	ldrsheq	r9, [r4], #-214
   9dcac: 00549e1c     	subseq	r9, r4, r12, lsl lr
   9dcb0: 0054a7dd     	ldrsbeq	r10, [r4], #-125
   9dcb4: 0054a648     	subseq	r10, r4, r8, asr #12
   9dcb8: 0054a5fa     	ldrsheq	r10, [r4], #-90
   9dcbc: 0054a620     	subseq	r10, r4, r0, lsr #12
   9dcc0: 0054a0ac     	subseq	r10, r4, r12, lsr #1
   9dcc4: 0054a05a     	subseq	r10, r4, r10, asr r0
   9dcc8: 0054a084     	subseq	r10, r4, r4, lsl #1
   9dccc: 0054a09f     	<unknown>
   9dcd0: 00542474     	subseq	r2, r4, r4, ror r4
   9dcd4: 005424a4     	subseq	r2, r4, r4, lsr #9
   9dcd8: 00542480     	subseq	r2, r4, r0, lsl #9
   9dcdc: 00001ba0     	andeq	r1, r0, r0, lsr #23
   9dce0: 0054a5ac     	subseq	r10, r4, r12, lsr #11
   9dce4: 0054a55a     	subseq	r10, r4, r10, asr r5
   9dce8: 0054a584     	subseq	r10, r4, r4, lsl #11
   9dcec: 0054a6b0     	ldrheq	r10, [r4], #-96
   9dcf0: 00541dc8     	subseq	r1, r4, r8, asr #27
   9dcf4: 00542218     	subseq	r2, r4, r8, lsl r2
   9dcf8: 005421e4     	subseq	r2, r4, r4, ror #3
   9dcfc: 0054a56c     	subseq	r10, r4, r12, ror #10
   9dd00: 0054a51a     	subseq	r10, r4, r10, lsl r5
   9dd04: 0054a544     	subseq	r10, r4, r4, asr #10
   9dd08: 0054a760     	subseq	r10, r4, r0, ror #14
   9dd0c: 005421a4     	subseq	r2, r4, r4, lsr #3
   9dd10: 0054216c     	subseq	r2, r4, r12, ror #2
   9dd14: 005422d0     	ldrsbeq	r2, [r4], #-32
   9dd18: 0054a520     	subseq	r10, r4, r0, lsr #10
   9dd1c: 0054a4ce     	subseq	r10, r4, lr, asr #9
   9dd20: 0054a4f8     	ldrsheq	r10, [r4], #-72
   9dd24: 0054a5fa     	ldrsheq	r10, [r4], #-90
   9dd28: 00541d88     	subseq	r1, r4, r8, lsl #27
   9dd2c: 0054a505     	subseq	r10, r4, r5, lsl #10
   9dd30: 0054a038     	subseq	r10, r4, r8, lsr r0
   9dd34: 00549fea     	subseq	r9, r4, r10, ror #31
   9dd38: 0054a010     	subseq	r10, r4, r0, lsl r0
   9dd3c: 00549fcc     	subseq	r9, r4, r12, asr #31
   9dd40: 00549f7e     	subseq	r9, r4, lr, ror pc
   9dd44: 00549fa4     	subseq	r9, r4, r4, lsr #31
   9dd48: 0054266c     	subseq	r2, r4, r12, ror #12
   9dd4c: 00542650     	subseq	r2, r4, r0, asr r6
   9dd50: 00542058     	subseq	r2, r4, r8, asr r0
   9dd54: 005425ec     	subseq	r2, r4, r12, ror #11
   9dd58: 0054200c     	subseq	r2, r4, r12
   9dd5c: 005425cc     	subseq	r2, r4, r12, asr #11
   9dd60: 0054257c     	subseq	r2, r4, r12, ror r5
   9dd64: 00541f84     	subseq	r1, r4, r4, lsl #31
   9dd68: 0054a655     	subseq	r10, r4, r5, asr r6
   9dd6c: 0054a656     	subseq	r10, r4, r6, asr r6
   9dd70: 0054a680     	subseq	r10, r4, r0, lsl #13
   9dd74: 0054a6e8     	subseq	r10, r4, r8, ror #13
   9dd78: 005420c8     	subseq	r2, r4, r8, asr #1
   9dd7c: 00542080     	subseq	r2, r4, r0, lsl #1
   9dd80: 00542270     	subseq	r2, r4, r0, ror r2
   9dd84: 00542238     	subseq	r2, r4, r8, lsr r2
   9dd88: 00542220     	subseq	r2, r4, r0, lsr #4
   9dd8c: 005421e8     	subseq	r2, r4, r8, ror #3
   9dd90: 005421d0     	ldrsbeq	r2, [r4], #-16
   9dd94: 00542138     	subseq	r2, r4, r8, lsr r1
   9dd98: 00541b58     	subseq	r1, r4, r8, asr r11
   9dd9c: 00542118     	subseq	r2, r4, r8, lsl r1
   9dda0: 0054a27c     	subseq	r10, r4, r12, ror r2
   9dda4: 00541ec8     	subseq	r1, r4, r8, asr #29
   9dda8: 0054a09c     	<unknown>
   9ddac: 00549dad     	subseq	r9, r4, sp, lsr #27
   9ddb0: 00549db2     	ldrheq	r9, [r4], #-210
   9ddb4: 00549dd8     	ldrsbeq	r9, [r4], #-216
   9ddb8: 00549f04     	subseq	r9, r4, r4, lsl #30
   9ddbc: 00549eb6     	ldrheq	r9, [r4], #-230
   9ddc0: 00549edc     	ldrsbeq	r9, [r4], #-236
   9ddc4: 00549d61     	subseq	r9, r4, r1, ror #26
   9ddc8: 00549d66     	subseq	r9, r4, r6, ror #26
   9ddcc: 00549d8c     	subseq	r9, r4, r12, lsl #27
   9ddd0: 0054a4d8     	ldrsbeq	r10, [r4], #-72
   9ddd4: e320f000     	nop

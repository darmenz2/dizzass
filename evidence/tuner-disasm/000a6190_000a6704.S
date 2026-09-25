
/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   a6190: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   a6194: e28db01c     	add	r11, sp, #28
   a6198: e24dd004     	sub	sp, sp, #4
   a619c: ed2d8b02     	vpush	{d8}
   a61a0: e24dd030     	sub	sp, sp, #48
   a61a4: e1a06002     	mov	r6, r2
   a61a8: e1a09001     	mov	r9, r1
   a61ac: e1a04000     	mov	r4, r0
   a61b0: ebfeef32     	bl	0x61e80 <.text+0x51d80> @ imm = #-0x44338
   a61b4: e58d0028     	str	r0, [sp, #0x28]
   a61b8: e3a05000     	mov	r5, #0
   a61bc: e59f04ec     	ldr	r0, [pc, #0x4ec]        @ 0xa66b0 <.text+0x965b0>
   a61c0: e1a07009     	mov	r7, r9
   a61c4: e59f14e8     	ldr	r1, [pc, #0x4e8]        @ 0xa66b4 <.text+0x965b4>
   a61c8: e59f24e8     	ldr	r2, [pc, #0x4e8]        @ 0xa66b8 <.text+0x965b8>
   a61cc: e08f0000     	add	r0, pc, r0
   a61d0: e5948018     	ldr	r8, [r4, #0x18]
   a61d4: e08f1001     	add	r1, pc, r1
   a61d8: e59f34dc     	ldr	r3, [pc, #0x4dc]        @ 0xa66bc <.text+0x965bc>
   a61dc: e08f2002     	add	r2, pc, r2
   a61e0: e58d502c     	str	r5, [sp, #0x2c]
   a61e4: e5895000     	str	r5, [r9]
   a61e8: e08f3003     	add	r3, pc, r3
   a61ec: e5a75008     	str	r5, [r7, #0x8]!
   a61f0: e58d7020     	str	r7, [sp, #0x20]
   a61f4: e3a07003     	mov	r7, #3
   a61f8: e589500c     	str	r5, [r9, #0xc]
   a61fc: e5895010     	str	r5, [r9, #0x10]
   a6200: e5895014     	str	r5, [r9, #0x14]
   a6204: e58d3004     	str	r3, [sp, #0x4]
   a6208: e3a03f46     	mov	r3, #280
   a620c: e58d7000     	str	r7, [sp]
   a6210: eb014fab     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x53eac
   a6214: e3560001     	cmp	r6, #1
   a6218: ba000048     	blt	0xa6340 <.text+0x96240> @ imm = #0x120
   a621c: e3010070     	movw	r0, #0x1070
   a6220: e2665000     	rsb	r5, r6, #0
   a6224: e0840000     	add	r0, r4, r0
   a6228: e58d0024     	str	r0, [sp, #0x24]
   a622c: e59fa48c     	ldr	r10, [pc, #0x48c]       @ 0xa66c0 <.text+0x965c0>
   a6230: e3a07001     	mov	r7, #1
   a6234: e79fa00a     	ldr	r10, [pc, r10]
   a6238: ea000005     	b	0xa6254 <.text+0x96154> @ imm = #0x14
   a623c: e3a00ffa     	mov	r0, #1000
   a6240: eb01a33d     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x68cf4
   a6244: e2877001     	add	r7, r7, #1
   a6248: e0850007     	add	r0, r5, r7
   a624c: e3500001     	cmp	r0, #1
   a6250: 0a00003a     	beq	0xa6340 <.text+0x96240> @ imm = #0xe8
   a6254: e28d102c     	add	r1, sp, #44
   a6258: e1a00004     	mov	r0, r4
   a625c: ebfede3c     	bl	0x5db54 <.text+0x4da54> @ imm = #-0x48710
   a6260: e3500000     	cmp	r0, #0
   a6264: 1a000042     	bne	0xa6374 <.text+0x96274> @ imm = #0x108
   a6268: e59d002c     	ldr	r0, [sp, #0x2c]
   a626c: e5991000     	ldr	r1, [r9]
   a6270: e0810000     	add	r0, r1, r0
   a6274: e5890000     	str	r0, [r9]
   a6278: e1a00004     	mov	r0, r4
   a627c: ebfef0cd     	bl	0x625b8 <.text+0x524b8> @ imm = #-0x43ccc
   a6280: ee000a10     	vmov	s0, r0
   a6284: eeb80bc0     	vcvt.f64.s32	d0, s0
   a6288: ed991b02     	vldr	d1, [r9, #8]
   a628c: ee310b00     	vadd.f64	d0, d1, d0
   a6290: ed890b02     	vstr	d0, [r9, #8]
   a6294: eb016015     	bl	0xfe2f0 <.text+0xee1f0> @ imm = #0x58054
   a6298: e5991014     	ldr	r1, [r9, #0x14]
   a629c: e0810000     	add	r0, r1, r0
   a62a0: e5890014     	str	r0, [r9, #0x14]
   a62a4: e1a00004     	mov	r0, r4
   a62a8: ebfeee08     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x447e0
   a62ac: e3500000     	cmp	r0, #0
   a62b0: 0affffe1     	beq	0xa623c <.text+0x9613c> @ imm = #-0x7c
   a62b4: e59a0000     	ldr	r0, [r10]
   a62b8: e2401001     	sub	r1, r0, #1
   a62bc: e0000190     	mul	r0, r0, r1
   a62c0: e3100001     	tst	r0, #1
   a62c4: e59a0000     	ldr	r0, [r10]
   a62c8: e2401001     	sub	r1, r0, #1
   a62cc: e0010190     	mul	r1, r0, r1
   a62d0: e5d40108     	ldrb	r0, [r4, #0x108]
   a62d4: e3110001     	tst	r1, #1
   a62d8: 0a000004     	beq	0xa62f0 <.text+0x961f0> @ imm = #0x10
   a62dc: e59f1400     	ldr	r1, [pc, #0x400]        @ 0xa66e4 <.text+0x965e4>
   a62e0: e79f1001     	ldr	r1, [pc, r1]
   a62e4: e5911000     	ldr	r1, [r1]
   a62e8: e3510009     	cmp	r1, #9
   a62ec: cafffff4     	bgt	0xa62c4 <.text+0x961c4> @ imm = #-0x30
   a62f0: e3500000     	cmp	r0, #0
   a62f4: 0affffd0     	beq	0xa623c <.text+0x9613c> @ imm = #-0xc0
   a62f8: e59d0024     	ldr	r0, [sp, #0x24]
   a62fc: e59d1028     	ldr	r1, [sp, #0x28]
   a6300: e5900000     	ldr	r0, [r0]
   a6304: e0500001     	subs	r0, r0, r1
   a6308: e3a00000     	mov	r0, #0
   a630c: e0d00fc1     	sbcs	r0, r0, r1, asr #31
   a6310: baffffc9     	blt	0xa623c <.text+0x9613c> @ imm = #-0xdc
   a6314: e59a0000     	ldr	r0, [r10]
   a6318: e59f83c8     	ldr	r8, [pc, #0x3c8]        @ 0xa66e8 <.text+0x965e8>
   a631c: e2401001     	sub	r1, r0, #1
   a6320: e0000190     	mul	r0, r0, r1
   a6324: e79f8008     	ldr	r8, [pc, r8]
   a6328: e3100001     	tst	r0, #1
   a632c: 0a000048     	beq	0xa6454 <.text+0x96354> @ imm = #0x120
   a6330: e5980000     	ldr	r0, [r8]
   a6334: e3500009     	cmp	r0, #9
   a6338: ca000062     	bgt	0xa64c8 <.text+0x963c8> @ imm = #0x188
   a633c: ea000044     	b	0xa6454 <.text+0x96354> @ imm = #0x110
   a6340: e59fa3a4     	ldr	r10, [pc, #0x3a4]       @ 0xa66ec <.text+0x965ec>
   a6344: e79fa00a     	ldr	r10, [pc, r10]
   a6348: e59a0000     	ldr	r0, [r10]
   a634c: e59f539c     	ldr	r5, [pc, #0x39c]        @ 0xa66f0 <.text+0x965f0>
   a6350: e2401001     	sub	r1, r0, #1
   a6354: e0000190     	mul	r0, r0, r1
   a6358: e79f5005     	ldr	r5, [pc, r5]
   a635c: e3100001     	tst	r0, #1
   a6360: 0a00006d     	beq	0xa651c <.text+0x9641c> @ imm = #0x1b4
   a6364: e5950000     	ldr	r0, [r5]
   a6368: e3500009     	cmp	r0, #9
   a636c: ca000086     	bgt	0xa658c <.text+0x9648c> @ imm = #0x218
   a6370: ea000069     	b	0xa651c <.text+0x9641c> @ imm = #0x1a4
   a6374: e59a0000     	ldr	r0, [r10]
   a6378: e59f5344     	ldr	r5, [pc, #0x344]        @ 0xa66c4 <.text+0x965c4>
   a637c: e2401001     	sub	r1, r0, #1
   a6380: e59f7340     	ldr	r7, [pc, #0x340]        @ 0xa66c8 <.text+0x965c8>
   a6384: e08f5005     	add	r5, pc, r5
   a6388: e0000190     	mul	r0, r0, r1
   a638c: e79f7007     	ldr	r7, [pc, r7]
   a6390: e3100001     	tst	r0, #1
   a6394: 0a000002     	beq	0xa63a4 <.text+0x962a4> @ imm = #0x8
   a6398: e5970000     	ldr	r0, [r7]
   a639c: e3500009     	cmp	r0, #9
   a63a0: ca000019     	bgt	0xa640c <.text+0x9630c> @ imm = #0x64
   a63a4: e59f0320     	ldr	r0, [pc, #0x320]        @ 0xa66cc <.text+0x965cc>
   a63a8: e3a06001     	mov	r6, #1
   a63ac: e59f131c     	ldr	r1, [pc, #0x31c]        @ 0xa66d0 <.text+0x965d0>
   a63b0: e3a03f47     	mov	r3, #284
   a63b4: e59f2318     	ldr	r2, [pc, #0x318]        @ 0xa66d4 <.text+0x965d4>
   a63b8: e08f0000     	add	r0, pc, r0
   a63bc: e08f1001     	add	r1, pc, r1
   a63c0: e58d6000     	str	r6, [sp]
   a63c4: e08f2002     	add	r2, pc, r2
   a63c8: e58d5004     	str	r5, [sp, #0x4]
   a63cc: eb014f3c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x53cf0
   a63d0: eb014a26     	bl	0xf8c70 <.text+0xe8b70> @ imm = #0x52898
   a63d4: e30100b4     	movw	r0, #0x10b4
   a63d8: e3001bbc     	movw	r1, #0xbbc
   a63dc: e0840000     	add	r0, r4, r0
   a63e0: ebfe8e2c     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x5c750
   a63e4: e1a00004     	mov	r0, r4
   a63e8: ebff02e4     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x3f470
   a63ec: e59a0000     	ldr	r0, [r10]
   a63f0: e2401001     	sub	r1, r0, #1
   a63f4: e0000190     	mul	r0, r0, r1
   a63f8: e3100001     	tst	r0, #1
   a63fc: 0a0000a3     	beq	0xa6690 <.text+0x96590> @ imm = #0x28c
   a6400: e5970000     	ldr	r0, [r7]
   a6404: e350000a     	cmp	r0, #10
   a6408: ba0000a0     	blt	0xa6690 <.text+0x96590> @ imm = #0x280
   a640c: e59f02c4     	ldr	r0, [pc, #0x2c4]        @ 0xa66d8 <.text+0x965d8>
   a6410: e3a03001     	mov	r3, #1
   a6414: e59f12c0     	ldr	r1, [pc, #0x2c0]        @ 0xa66dc <.text+0x965dc>
   a6418: e59f22c0     	ldr	r2, [pc, #0x2c0]        @ 0xa66e0 <.text+0x965e0>
   a641c: e08f0000     	add	r0, pc, r0
   a6420: e08f1001     	add	r1, pc, r1
   a6424: e88d0028     	stm	sp, {r3, r5}
   a6428: e08f2002     	add	r2, pc, r2
   a642c: e3a03f47     	mov	r3, #284
   a6430: eb014f23     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x53c8c
   a6434: eb014a0d     	bl	0xf8c70 <.text+0xe8b70> @ imm = #0x52834
   a6438: e30100b4     	movw	r0, #0x10b4
   a643c: e3001bbc     	movw	r1, #0xbbc
   a6440: e0840000     	add	r0, r4, r0
   a6444: ebfe8e13     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x5c7b4
   a6448: e1a00004     	mov	r0, r4
   a644c: ebff02cb     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x3f4d4
   a6450: eaffffd3     	b	0xa63a4 <.text+0x962a4> @ imm = #-0xb4
   a6454: e5990000     	ldr	r0, [r9]
   a6458: e1a01007     	mov	r1, r7
   a645c: eb13aaa3     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4eaa8c
   a6460: ee007a10     	vmov	s0, r7
   a6464: ed9f8b8f     	vldr	d8, [pc, #572]          @ 0xa66a8 <.text+0x965a8>
   a6468: eeb80bc0     	vcvt.f64.s32	d0, s0
   a646c: e5991014     	ldr	r1, [r9, #0x14]
   a6470: ed991b02     	vldr	d1, [r9, #8]
   a6474: e5890000     	str	r0, [r9]
   a6478: e1a00001     	mov	r0, r1
   a647c: ee810b00     	vdiv.f64	d0, d1, d0
   a6480: e1a01007     	mov	r1, r7
   a6484: eeb40bc8     	vcmpe.f64	d0, d8
   a6488: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a648c: 4eb08b40     	vmovmi.f64	d8, d0
   a6490: eb13aa96     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4eaa58
   a6494: e5890014     	str	r0, [r9, #0x14]
   a6498: e3a06002     	mov	r6, #2
   a649c: ed898b02     	vstr	d8, [r9, #8]
   a64a0: e594020c     	ldr	r0, [r4, #0x20c]
   a64a4: e5890010     	str	r0, [r9, #0x10]
   a64a8: e59a0000     	ldr	r0, [r10]
   a64ac: e2401001     	sub	r1, r0, #1
   a64b0: e0000190     	mul	r0, r0, r1
   a64b4: e3100001     	tst	r0, #1
   a64b8: 0a000074     	beq	0xa6690 <.text+0x96590> @ imm = #0x1d0
   a64bc: e5980000     	ldr	r0, [r8]
   a64c0: e350000a     	cmp	r0, #10
   a64c4: ba000071     	blt	0xa6690 <.text+0x96590> @ imm = #0x1c4
   a64c8: e5990000     	ldr	r0, [r9]
   a64cc: e1a01007     	mov	r1, r7
   a64d0: eb13aa86     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4eaa18
   a64d4: ee007a10     	vmov	s0, r7
   a64d8: ed9f8b72     	vldr	d8, [pc, #456]          @ 0xa66a8 <.text+0x965a8>
   a64dc: eeb80bc0     	vcvt.f64.s32	d0, s0
   a64e0: e5991014     	ldr	r1, [r9, #0x14]
   a64e4: ed991b02     	vldr	d1, [r9, #8]
   a64e8: e5890000     	str	r0, [r9]
   a64ec: e1a00001     	mov	r0, r1
   a64f0: ee810b00     	vdiv.f64	d0, d1, d0
   a64f4: e1a01007     	mov	r1, r7
   a64f8: eeb40bc8     	vcmpe.f64	d0, d8
   a64fc: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a6500: 4eb08b40     	vmovmi.f64	d8, d0
   a6504: eb13aa79     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4ea9e4
   a6508: e5890014     	str	r0, [r9, #0x14]
   a650c: ed898b02     	vstr	d8, [r9, #8]
   a6510: e594020c     	ldr	r0, [r4, #0x20c]
   a6514: e5890010     	str	r0, [r9, #0x10]
   a6518: eaffffcd     	b	0xa6454 <.text+0x96354> @ imm = #-0xcc
   a651c: e5990000     	ldr	r0, [r9]
   a6520: e1a01006     	mov	r1, r6
   a6524: eb13aa71     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4ea9c4
   a6528: ee006a10     	vmov	s0, r6
   a652c: e1a07000     	mov	r7, r0
   a6530: e1a01006     	mov	r1, r6
   a6534: eeb80bc0     	vcvt.f64.s32	d0, s0
   a6538: e5990014     	ldr	r0, [r9, #0x14]
   a653c: ed991b02     	vldr	d1, [r9, #8]
   a6540: e5897000     	str	r7, [r9]
   a6544: ee818b00     	vdiv.f64	d8, d1, d0
   a6548: eb13aa68     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4ea9a0
   a654c: e5890014     	str	r0, [r9, #0x14]
   a6550: ed898b02     	vstr	d8, [r9, #8]
   a6554: e59830c4     	ldr	r3, [r8, #0xc4]
   a6558: e1500003     	cmp	r0, r3
   a655c: b1a03000     	movlt	r3, r0
   a6560: e5893014     	str	r3, [r9, #0x14]
   a6564: e594020c     	ldr	r0, [r4, #0x20c]
   a6568: e5890010     	str	r0, [r9, #0x10]
   a656c: e59a0000     	ldr	r0, [r10]
   a6570: e2401001     	sub	r1, r0, #1
   a6574: e0000190     	mul	r0, r0, r1
   a6578: e3100001     	tst	r0, #1
   a657c: 0a000017     	beq	0xa65e0 <.text+0x964e0> @ imm = #0x5c
   a6580: e5950000     	ldr	r0, [r5]
   a6584: e3500009     	cmp	r0, #9
   a6588: da000014     	ble	0xa65e0 <.text+0x964e0> @ imm = #0x50
   a658c: e5990000     	ldr	r0, [r9]
   a6590: e1a01006     	mov	r1, r6
   a6594: eb13aa55     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4ea954
   a6598: ee006a10     	vmov	s0, r6
   a659c: eeb80bc0     	vcvt.f64.s32	d0, s0
   a65a0: e5991014     	ldr	r1, [r9, #0x14]
   a65a4: ed991b02     	vldr	d1, [r9, #8]
   a65a8: e5890000     	str	r0, [r9]
   a65ac: e1a00001     	mov	r0, r1
   a65b0: e1a01006     	mov	r1, r6
   a65b4: ee818b00     	vdiv.f64	d8, d1, d0
   a65b8: eb13aa4c     	bl	0x590ef0 <.text+0x580df0> @ imm = #0x4ea930
   a65bc: e5890014     	str	r0, [r9, #0x14]
   a65c0: ed898b02     	vstr	d8, [r9, #8]
   a65c4: e59810c4     	ldr	r1, [r8, #0xc4]
   a65c8: e1500001     	cmp	r0, r1
   a65cc: b1a01000     	movlt	r1, r0
   a65d0: e5891014     	str	r1, [r9, #0x14]
   a65d4: e594020c     	ldr	r0, [r4, #0x20c]
   a65d8: e5890010     	str	r0, [r9, #0x10]
   a65dc: eaffffce     	b	0xa651c <.text+0x9641c> @ imm = #-0xc8
   a65e0: ed9f0b30     	vldr	d0, [pc, #192]          @ 0xa66a8 <.text+0x965a8>
   a65e4: eeb48bc0     	vcmpe.f64	d8, d0
   a65e8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   a65ec: da000018     	ble	0xa6654 <.text+0x96554> @ imm = #0x60
   a65f0: e59a0000     	ldr	r0, [r10]
   a65f4: e59d6020     	ldr	r6, [sp, #0x20]
   a65f8: e2401001     	sub	r1, r0, #1
   a65fc: e0000190     	mul	r0, r0, r1
   a6600: e3001000     	movw	r1, #0x0
   a6604: e3441059     	movt	r1, #0x4059
   a6608: e3100001     	tst	r0, #1
   a660c: 0a000002     	beq	0xa661c <.text+0x9651c> @ imm = #0x8
   a6610: e5950000     	ldr	r0, [r5]
   a6614: e3500009     	cmp	r0, #9
   a6618: ca000009     	bgt	0xa6644 <.text+0x96544> @ imm = #0x24
   a661c: e3a00000     	mov	r0, #0
   a6620: e1c600f0     	strd	r0, r1, [r6]
   a6624: e59a0000     	ldr	r0, [r10]
   a6628: e2402001     	sub	r2, r0, #1
   a662c: e0000290     	mul	r0, r0, r2
   a6630: e3100001     	tst	r0, #1
   a6634: 0a000005     	beq	0xa6650 <.text+0x96550> @ imm = #0x14
   a6638: e5950000     	ldr	r0, [r5]
   a663c: e3500009     	cmp	r0, #9
   a6640: da000002     	ble	0xa6650 <.text+0x96550> @ imm = #0x8
   a6644: e3a00000     	mov	r0, #0
   a6648: e1c600f0     	strd	r0, r1, [r6]
   a664c: eafffff2     	b	0xa661c <.text+0x9651c> @ imm = #-0x38
   a6650: eeb08b40     	vmov.f64	d8, d0
   a6654: e59f0098     	ldr	r0, [pc, #0x98]         @ 0xa66f4 <.text+0x965f4>
   a6658: e59f1098     	ldr	r1, [pc, #0x98]         @ 0xa66f8 <.text+0x965f8>
   a665c: e59f2098     	ldr	r2, [pc, #0x98]         @ 0xa66fc <.text+0x965fc>
   a6660: e08f0000     	add	r0, pc, r0
   a6664: e59f6094     	ldr	r6, [pc, #0x94]         @ 0xa6700 <.text+0x96600>
   a6668: e08f1001     	add	r1, pc, r1
   a666c: e58d3018     	str	r3, [sp, #0x18]
   a6670: e08f2002     	add	r2, pc, r2
   a6674: e3a03003     	mov	r3, #3
   a6678: e08f6006     	add	r6, pc, r6
   a667c: ed8d8b04     	vstr	d8, [sp, #16]
   a6680: e88d00c8     	stm	sp, {r3, r6, r7}
   a6684: e300313e     	movw	r3, #0x13e
   a6688: eb014e8d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x53a34
   a668c: e3a06000     	mov	r6, #0
   a6690: e1a00006     	mov	r0, r6
   a6694: e24bd028     	sub	sp, r11, #40
   a6698: ecbd8b02     	vpop	{d8}
   a669c: e28dd004     	add	sp, sp, #4
   a66a0: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   a66a4: e320f000     	nop
   a66a8: 00000000     	andeq	r0, r0, r0
   a66ac: 40590000     	subsmi	r0, r9, r0
   a66b0: 00541b5f     	subseq	r1, r4, pc, asr r11
   a66b4: 00541af8     	ldrsheq	r1, [r4], #-168
   a66b8: 00541b28     	subseq	r1, r4, r8, lsr #22
   a66bc: 00541c0d     	subseq	r1, r4, sp, lsl #24
   a66c0: 005397e4     	subseq	r9, r3, r4, ror #15
   a66c4: 0054198b     	subseq	r1, r4, r11, lsl #19
   a66c8: 00538b08     	subseq	r8, r3, r8, lsl #22
   a66cc: 00541945     	subseq	r1, r4, r5, asr #18
   a66d0: 00541910     	subseq	r1, r4, r0, lsl r9
   a66d4: 00541940     	subseq	r1, r4, r0, asr #18
   a66d8: 005418e1     	subseq	r1, r4, r1, ror #17
   a66dc: 005418ac     	subseq	r1, r4, r12, lsr #17
   a66e0: 005418dc     	ldrsbeq	r1, [r4], #-140
   a66e4: 00538bb4     	ldrheq	r8, [r3], #-180
   a66e8: 00538b70     	subseq	r8, r3, r0, ror r11
   a66ec: 005396d4     	ldrsbeq	r9, [r3], #-100
   a66f0: 00538b3c     	subseq	r8, r3, r12, lsr r11
   a66f4: 005416cb     	subseq	r1, r4, r11, asr #13
   a66f8: 00541664     	subseq	r1, r4, r4, ror #12
   a66fc: 00541694     	<unknown>
   a6700: 0054179a     	<unknown>

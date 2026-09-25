
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  107188: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
  10718c: e28db010     	add	r11, sp, #16
  107190: e24dd010     	sub	sp, sp, #16
  107194: e1a05000     	mov	r5, r0
  107198: e59f03fc     	ldr	r0, [pc, #0x3fc]        @ 0x10759c <.text+0xf749c>
  10719c: e08f0000     	add	r0, pc, r0
  1071a0: e5d00000     	ldrb	r0, [r0]
  1071a4: e3500000     	cmp	r0, #0
  1071a8: 0a000017     	beq	0x10720c <.text+0xf710c> @ imm = #0x5c
  1071ac: e3550000     	cmp	r5, #0
  1071b0: 4a000024     	bmi	0x107248 <.text+0xf7148> @ imm = #0x90
  1071b4: e59f0408     	ldr	r0, [pc, #0x408]        @ 0x1075c4 <.text+0xf74c4>
  1071b8: e79f0000     	ldr	r0, [pc, r0]
  1071bc: e1500005     	cmp	r0, r5
  1071c0: da000020     	ble	0x107248 <.text+0xf7148> @ imm = #0x80
  1071c4: e1a04001     	mov	r4, r1
  1071c8: e3510c01     	cmp	r1, #256
  1071cc: 3a00002c     	blo	0x107284 <.text+0xf7184> @ imm = #0xb0
  1071d0: e59f5414     	ldr	r5, [pc, #0x414]        @ 0x1075ec <.text+0xf74ec>
  1071d4: e79f5005     	ldr	r5, [pc, r5]
  1071d8: e5950000     	ldr	r0, [r5]
  1071dc: e59f640c     	ldr	r6, [pc, #0x40c]        @ 0x1075f0 <.text+0xf74f0>
  1071e0: e2401001     	sub	r1, r0, #1
  1071e4: e0000190     	mul	r0, r0, r1
  1071e8: e79f6006     	ldr	r6, [pc, r6]
  1071ec: e59f7400     	ldr	r7, [pc, #0x400]        @ 0x1075f4 <.text+0xf74f4>
  1071f0: e08f7007     	add	r7, pc, r7
  1071f4: e3100001     	tst	r0, #1
  1071f8: 0a0000a7     	beq	0x10749c <.text+0xf739c> @ imm = #0x29c
  1071fc: e5960000     	ldr	r0, [r6]
  107200: e3500009     	cmp	r0, #9
  107204: ca0000b8     	bgt	0x1074ec <.text+0xf73ec> @ imm = #0x2e0
  107208: ea0000a3     	b	0x10749c <.text+0xf739c> @ imm = #0x28c
  10720c: e59f438c     	ldr	r4, [pc, #0x38c]        @ 0x1075a0 <.text+0xf74a0>
  107210: e79f4004     	ldr	r4, [pc, r4]
  107214: e5940000     	ldr	r0, [r4]
  107218: e59f5384     	ldr	r5, [pc, #0x384]        @ 0x1075a4 <.text+0xf74a4>
  10721c: e2401001     	sub	r1, r0, #1
  107220: e0000190     	mul	r0, r0, r1
  107224: e79f5005     	ldr	r5, [pc, r5]
  107228: e59f6378     	ldr	r6, [pc, #0x378]        @ 0x1075a8 <.text+0xf74a8>
  10722c: e08f6006     	add	r6, pc, r6
  107230: e3100001     	tst	r0, #1
  107234: 0a00005a     	beq	0x1073a4 <.text+0xf72a4> @ imm = #0x168
  107238: e5950000     	ldr	r0, [r5]
  10723c: e3500009     	cmp	r0, #9
  107240: ca00006a     	bgt	0x1073f0 <.text+0xf72f0> @ imm = #0x1a8
  107244: ea000056     	b	0x1073a4 <.text+0xf72a4> @ imm = #0x158
  107248: e59f4378     	ldr	r4, [pc, #0x378]        @ 0x1075c8 <.text+0xf74c8>
  10724c: e79f4004     	ldr	r4, [pc, r4]
  107250: e5940000     	ldr	r0, [r4]
  107254: e59f6370     	ldr	r6, [pc, #0x370]        @ 0x1075cc <.text+0xf74cc>
  107258: e2401001     	sub	r1, r0, #1
  10725c: e0000190     	mul	r0, r0, r1
  107260: e79f6006     	ldr	r6, [pc, r6]
  107264: e59f7364     	ldr	r7, [pc, #0x364]        @ 0x1075d0 <.text+0xf74d0>
  107268: e08f7007     	add	r7, pc, r7
  10726c: e3100001     	tst	r0, #1
  107270: 0a000069     	beq	0x10741c <.text+0xf731c> @ imm = #0x1a4
  107274: e5960000     	ldr	r0, [r6]
  107278: e3500009     	cmp	r0, #9
  10727c: ca00007a     	bgt	0x10746c <.text+0xf736c> @ imm = #0x1e8
  107280: ea000065     	b	0x10741c <.text+0xf731c> @ imm = #0x194
  107284: e59f6384     	ldr	r6, [pc, #0x384]        @ 0x107610 <.text+0xf7510>
  107288: e3a00000     	mov	r0, #0
  10728c: e79f6006     	ldr	r6, [pc, r6]
  107290: e59f737c     	ldr	r7, [pc, #0x37c]        @ 0x107614 <.text+0xf7514>
  107294: e79f7007     	ldr	r7, [pc, r7]
  107298: e5971000     	ldr	r1, [r7]
  10729c: e351000a     	cmp	r1, #10
  1072a0: b3000001     	movwlt	r0, #0x1
  1072a4: e3520000     	cmp	r2, #0
  1072a8: 0a00002e     	beq	0x107368 <.text+0xf7268> @ imm = #0xb8
  1072ac: e5960000     	ldr	r0, [r6]
  1072b0: e2401001     	sub	r1, r0, #1
  1072b4: e0010190     	mul	r1, r0, r1
  1072b8: e59f0374     	ldr	r0, [pc, #0x374]        @ 0x107634 <.text+0xf7534>
  1072bc: e79f0000     	ldr	r0, [pc, r0]
  1072c0: e3110001     	tst	r1, #1
  1072c4: 0a000002     	beq	0x1072d4 <.text+0xf71d4> @ imm = #0x8
  1072c8: e5971000     	ldr	r1, [r7]
  1072cc: e3510009     	cmp	r1, #9
  1072d0: cafffff5     	bgt	0x1072ac <.text+0xf71ac> @ imm = #-0x2c
  1072d4: e0851305     	add	r1, r5, r5, lsl #6
  1072d8: e0800181     	add	r0, r0, r1, lsl #3
  1072dc: e3a01000     	mov	r1, #0
  1072e0: e5963000     	ldr	r3, [r6]
  1072e4: e2435001     	sub	r5, r3, #1
  1072e8: e0030593     	mul	r3, r3, r5
  1072ec: e3130001     	tst	r3, #1
  1072f0: e5963000     	ldr	r3, [r6]
  1072f4: e2435001     	sub	r5, r3, #1
  1072f8: e0050593     	mul	r5, r3, r5
  1072fc: e7903181     	ldr	r3, [r0, r1, lsl #3]
  107300: e3150001     	tst	r5, #1
  107304: 0a000002     	beq	0x107314 <.text+0xf7214> @ imm = #0x8
  107308: e5975000     	ldr	r5, [r7]
  10730c: e3550009     	cmp	r5, #9
  107310: cafffff6     	bgt	0x1072f0 <.text+0xf71f0> @ imm = #-0x28
  107314: e1530004     	cmp	r3, r4
  107318: 0a00001c     	beq	0x107390 <.text+0xf7290> @ imm = #0x70
  10731c: e2811001     	add	r1, r1, #1
  107320: e3510040     	cmp	r1, #64
  107324: 1affffed     	bne	0x1072e0 <.text+0xf71e0> @ imm = #-0x4c
  107328: e59f0308     	ldr	r0, [pc, #0x308]        @ 0x107638 <.text+0xf7538>
  10732c: e3a07001     	mov	r7, #1
  107330: e59f1304     	ldr	r1, [pc, #0x304]        @ 0x10763c <.text+0xf753c>
  107334: e59f2304     	ldr	r2, [pc, #0x304]        @ 0x107640 <.text+0xf7540>
  107338: e08f0000     	add	r0, pc, r0
  10733c: e59f3300     	ldr	r3, [pc, #0x300]        @ 0x107644 <.text+0xf7544>
  107340: e08f1001     	add	r1, pc, r1
  107344: e08f2002     	add	r2, pc, r2
  107348: e58d7000     	str	r7, [sp]
  10734c: e08f3003     	add	r3, pc, r3
  107350: e98d0018     	stmib	sp, {r3, r4}
  107354: e3a03fc3     	mov	r3, #780
  107358: ebffcb59     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd29c
  10735c: e3e00000     	mvn	r0, #0
  107360: e24bd010     	sub	sp, r11, #16
  107364: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  107368: e5961000     	ldr	r1, [r6]
  10736c: e59f42a4     	ldr	r4, [pc, #0x2a4]        @ 0x107618 <.text+0xf7518>
  107370: e2412001     	sub	r2, r1, #1
  107374: e08f4004     	add	r4, pc, r4
  107378: e0010291     	mul	r1, r1, r2
  10737c: e3a02001     	mov	r2, #1
  107380: e1c21001     	bic	r1, r2, r1
  107384: e1910000     	orrs	r0, r1, r0
  107388: 1a000063     	bne	0x10751c <.text+0xf741c> @ imm = #0x18c
  10738c: ea000075     	b	0x107568 <.text+0xf7468> @ imm = #0x1d4
  107390: e0800181     	add	r0, r0, r1, lsl #3
  107394: e5900004     	ldr	r0, [r0, #0x4]
  107398: e5820000     	str	r0, [r2]
  10739c: e3a00000     	mov	r0, #0
  1073a0: ea00007b     	b	0x107594 <.text+0xf7494> @ imm = #0x1ec
  1073a4: e59f0200     	ldr	r0, [pc, #0x200]        @ 0x1075ac <.text+0xf74ac>
  1073a8: e3a03001     	mov	r3, #1
  1073ac: e59f11fc     	ldr	r1, [pc, #0x1fc]        @ 0x1075b0 <.text+0xf74b0>
  1073b0: e59f21fc     	ldr	r2, [pc, #0x1fc]        @ 0x1075b4 <.text+0xf74b4>
  1073b4: e08f0000     	add	r0, pc, r0
  1073b8: e08f1001     	add	r1, pc, r1
  1073bc: e88d0048     	stm	sp, {r3, r6}
  1073c0: e08f2002     	add	r2, pc, r2
  1073c4: e30032f7     	movw	r3, #0x2f7
  1073c8: ebffcb3d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd30c
  1073cc: e5940000     	ldr	r0, [r4]
  1073d0: e2401001     	sub	r1, r0, #1
  1073d4: e0010190     	mul	r1, r0, r1
  1073d8: e3e00000     	mvn	r0, #0
  1073dc: e3110001     	tst	r1, #1
  1073e0: 0a00006b     	beq	0x107594 <.text+0xf7494> @ imm = #0x1ac
  1073e4: e5951000     	ldr	r1, [r5]
  1073e8: e351000a     	cmp	r1, #10
  1073ec: ba000068     	blt	0x107594 <.text+0xf7494> @ imm = #0x1a0
  1073f0: e59f01c0     	ldr	r0, [pc, #0x1c0]        @ 0x1075b8 <.text+0xf74b8>
  1073f4: e3a03001     	mov	r3, #1
  1073f8: e59f11bc     	ldr	r1, [pc, #0x1bc]        @ 0x1075bc <.text+0xf74bc>
  1073fc: e59f21bc     	ldr	r2, [pc, #0x1bc]        @ 0x1075c0 <.text+0xf74c0>
  107400: e08f0000     	add	r0, pc, r0
  107404: e08f1001     	add	r1, pc, r1
  107408: e88d0048     	stm	sp, {r3, r6}
  10740c: e08f2002     	add	r2, pc, r2
  107410: e30032f7     	movw	r3, #0x2f7
  107414: ebffcb2a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd358
  107418: eaffffe1     	b	0x1073a4 <.text+0xf72a4> @ imm = #-0x7c
  10741c: e59f01b0     	ldr	r0, [pc, #0x1b0]        @ 0x1075d4 <.text+0xf74d4>
  107420: e3a03001     	mov	r3, #1
  107424: e59f11ac     	ldr	r1, [pc, #0x1ac]        @ 0x1075d8 <.text+0xf74d8>
  107428: e59f21ac     	ldr	r2, [pc, #0x1ac]        @ 0x1075dc <.text+0xf74dc>
  10742c: e08f0000     	add	r0, pc, r0
  107430: e08f1001     	add	r1, pc, r1
  107434: e88d0088     	stm	sp, {r3, r7}
  107438: e08f2002     	add	r2, pc, r2
  10743c: e3a03fbf     	mov	r3, #764
  107440: e58d5008     	str	r5, [sp, #0x8]
  107444: ebffcb1e     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd388
  107448: e5940000     	ldr	r0, [r4]
  10744c: e2401001     	sub	r1, r0, #1
  107450: e0010190     	mul	r1, r0, r1
  107454: e3e00000     	mvn	r0, #0
  107458: e3110001     	tst	r1, #1
  10745c: 0a00004c     	beq	0x107594 <.text+0xf7494> @ imm = #0x130
  107460: e5961000     	ldr	r1, [r6]
  107464: e351000a     	cmp	r1, #10
  107468: ba000049     	blt	0x107594 <.text+0xf7494> @ imm = #0x124
  10746c: e59f016c     	ldr	r0, [pc, #0x16c]        @ 0x1075e0 <.text+0xf74e0>
  107470: e3a03001     	mov	r3, #1
  107474: e59f1168     	ldr	r1, [pc, #0x168]        @ 0x1075e4 <.text+0xf74e4>
  107478: e59f2168     	ldr	r2, [pc, #0x168]        @ 0x1075e8 <.text+0xf74e8>
  10747c: e08f0000     	add	r0, pc, r0
  107480: e08f1001     	add	r1, pc, r1
  107484: e88d0088     	stm	sp, {r3, r7}
  107488: e08f2002     	add	r2, pc, r2
  10748c: e3a03fbf     	mov	r3, #764
  107490: e58d5008     	str	r5, [sp, #0x8]
  107494: ebffcb0a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd3d8
  107498: eaffffdf     	b	0x10741c <.text+0xf731c> @ imm = #-0x84
  10749c: e59f0154     	ldr	r0, [pc, #0x154]        @ 0x1075f8 <.text+0xf74f8>
  1074a0: e3a03001     	mov	r3, #1
  1074a4: e59f1150     	ldr	r1, [pc, #0x150]        @ 0x1075fc <.text+0xf74fc>
  1074a8: e59f2150     	ldr	r2, [pc, #0x150]        @ 0x107600 <.text+0xf7500>
  1074ac: e08f0000     	add	r0, pc, r0
  1074b0: e08f1001     	add	r1, pc, r1
  1074b4: e88d0088     	stm	sp, {r3, r7}
  1074b8: e08f2002     	add	r2, pc, r2
  1074bc: e3003301     	movw	r3, #0x301
  1074c0: e58d4008     	str	r4, [sp, #0x8]
  1074c4: ebffcafe     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd408
  1074c8: e5950000     	ldr	r0, [r5]
  1074cc: e2401001     	sub	r1, r0, #1
  1074d0: e0010190     	mul	r1, r0, r1
  1074d4: e3e00000     	mvn	r0, #0
  1074d8: e3110001     	tst	r1, #1
  1074dc: 0a00002c     	beq	0x107594 <.text+0xf7494> @ imm = #0xb0
  1074e0: e5961000     	ldr	r1, [r6]
  1074e4: e351000a     	cmp	r1, #10
  1074e8: ba000029     	blt	0x107594 <.text+0xf7494> @ imm = #0xa4
  1074ec: e59f0110     	ldr	r0, [pc, #0x110]        @ 0x107604 <.text+0xf7504>
  1074f0: e3a03001     	mov	r3, #1
  1074f4: e59f110c     	ldr	r1, [pc, #0x10c]        @ 0x107608 <.text+0xf7508>
  1074f8: e59f210c     	ldr	r2, [pc, #0x10c]        @ 0x10760c <.text+0xf750c>
  1074fc: e08f0000     	add	r0, pc, r0
  107500: e08f1001     	add	r1, pc, r1
  107504: e88d0088     	stm	sp, {r3, r7}
  107508: e08f2002     	add	r2, pc, r2
  10750c: e3003301     	movw	r3, #0x301
  107510: e58d4008     	str	r4, [sp, #0x8]
  107514: ebffcaea     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd458
  107518: eaffffdf     	b	0x10749c <.text+0xf739c> @ imm = #-0x84
  10751c: e59f00f8     	ldr	r0, [pc, #0xf8]         @ 0x10761c <.text+0xf751c>
  107520: e3a03001     	mov	r3, #1
  107524: e59f10f4     	ldr	r1, [pc, #0xf4]         @ 0x107620 <.text+0xf7520>
  107528: e59f20f4     	ldr	r2, [pc, #0xf4]         @ 0x107624 <.text+0xf7524>
  10752c: e08f0000     	add	r0, pc, r0
  107530: e08f1001     	add	r1, pc, r1
  107534: e88d0018     	stm	sp, {r3, r4}
  107538: e08f2002     	add	r2, pc, r2
  10753c: e3003306     	movw	r3, #0x306
  107540: ebffcadf     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd484
  107544: e5960000     	ldr	r0, [r6]
  107548: e2401001     	sub	r1, r0, #1
  10754c: e0010190     	mul	r1, r0, r1
  107550: e3e00000     	mvn	r0, #0
  107554: e3110001     	tst	r1, #1
  107558: 0a00000d     	beq	0x107594 <.text+0xf7494> @ imm = #0x34
  10755c: e5971000     	ldr	r1, [r7]
  107560: e351000a     	cmp	r1, #10
  107564: ba00000a     	blt	0x107594 <.text+0xf7494> @ imm = #0x28
  107568: e59f00b8     	ldr	r0, [pc, #0xb8]         @ 0x107628 <.text+0xf7528>
  10756c: e3a03001     	mov	r3, #1
  107570: e59f10b4     	ldr	r1, [pc, #0xb4]         @ 0x10762c <.text+0xf752c>
  107574: e59f20b4     	ldr	r2, [pc, #0xb4]         @ 0x107630 <.text+0xf7530>
  107578: e08f0000     	add	r0, pc, r0
  10757c: e08f1001     	add	r1, pc, r1
  107580: e88d0018     	stm	sp, {r3, r4}
  107584: e08f2002     	add	r2, pc, r2
  107588: e3003306     	movw	r3, #0x306
  10758c: ebffcacc     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xd4d0
  107590: eaffffe1     	b	0x10751c <.text+0xf741c> @ imm = #-0x7c
  107594: e24bd010     	sub	sp, r11, #16
  107598: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  10759c: 0054dbcc     	subseq	sp, r4, r12, asr #23
  1075a0: 004d7a50     	subeq	r7, sp, r0, asr r10
  1075a4: 004d7df0     	strdeq	r7, r8, [sp], #-208
  1075a8: 004e62d4     	ldrdeq	r6, r7, [lr], #-36
  1075ac: 004e60af     	subeq	r6, lr, pc, lsr #1
  1075b0: 004e60b2     	strheq	r6, [lr], #-2
  1075b4: 004e60d0     	ldrdeq	r6, r7, [lr], #-0
  1075b8: 004e6063     	subeq	r6, lr, r3, rrx
  1075bc: 004e6066     	subeq	r6, lr, r6, rrx
  1075c0: 004e6084     	subeq	r6, lr, r4, lsl #1
  1075c4: 0054dbac     	subseq	sp, r4, r12, lsr #23
  1075c8: 004d7a14     	subeq	r7, sp, r4, lsl r10
  1075cc: 004d7db4     	strheq	r7, [sp], #-212
  1075d0: 004e62b2     	strheq	r6, [lr], #-34
  1075d4: 004e6037     	subeq	r6, lr, r7, lsr r0
  1075d8: 004e603a     	subeq	r6, lr, r10, lsr r0
  1075dc: 004e6058     	subeq	r6, lr, r8, asr r0
  1075e0: 004e5fe7     	subeq	r5, lr, r7, ror #31
  1075e4: 004e5fea     	subeq	r5, lr, r10, ror #31
  1075e8: 004e6008     	subeq	r6, lr, r8
  1075ec: 004d7a8c     	subeq	r7, sp, r12, lsl #21
  1075f0: 004d7e2c     	subeq	r7, sp, r12, lsr #28
  1075f4: 004e6340     	subeq	r6, lr, r0, asr #6
  1075f8: 004e5fb7     	strheq	r5, [lr], #-247
  1075fc: 004e5fba     	strheq	r5, [lr], #-250
  107600: 004e5fd8     	ldrdeq	r5, r6, [lr], #-248
  107604: 004e5f67     	subeq	r5, lr, r7, ror #30
  107608: 004e5f6a     	subeq	r5, lr, r10, ror #30
  10760c: 004e5f88     	subeq	r5, lr, r8, lsl #31
  107610: 004d79d4     	ldrdeq	r7, r8, [sp], #-148
  107614: 004d7d80     	subeq	r7, sp, r0, lsl #27
  107618: 004e61d2     	ldrdeq	r6, r7, [lr], #-18
  10761c: 004e5f37     	subeq	r5, lr, r7, lsr pc
  107620: 004e5f3a     	subeq	r5, lr, r10, lsr pc
  107624: 004e5f58     	subeq	r5, lr, r8, asr pc
  107628: 004e5eeb     	subeq	r5, lr, r11, ror #29
  10762c: 004e5eee     	subeq	r5, lr, lr, ror #29
  107630: 004e5f0c     	subeq	r5, lr, r12, lsl #30
  107634: 0054daa4     	subseq	sp, r4, r4, lsr #21
  107638: 004e612b     	subeq	r6, lr, r11, lsr #2
  10763c: 004e612a     	subeq	r6, lr, r10, lsr #2
  107640: 004e614c     	subeq	r6, lr, r12, asr #2
  107644: 004e6209     	subeq	r6, lr, r9, lsl #4

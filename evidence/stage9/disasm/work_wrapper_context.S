
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   300ac: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   300b0: e28db01c     	add	r11, sp, #28
   300b4: e24dd00c     	sub	sp, sp, #12
   300b8: e50b3028     	str	r3, [r11, #-0x28]
   300bc: e1a06001     	mov	r6, r1
   300c0: e50b0024     	str	r0, [r11, #-0x24]
   300c4: e1a0a002     	mov	r10, r2
   300c8: e59f0408     	ldr	r0, [pc, #0x408]        @ 0x304d8 <.text+0x203d8>
   300cc: e79f0000     	ldr	r0, [pc, r0]
   300d0: e5900000     	ldr	r0, [r0]
   300d4: e2401001     	sub	r1, r0, #1
   300d8: e0000190     	mul	r0, r0, r1
   300dc: e3100001     	tst	r0, #1
   300e0: 0a000004     	beq	0x300f8 <.text+0x1fff8> @ imm = #0x10
   300e4: e59f03f0     	ldr	r0, [pc, #0x3f0]        @ 0x304dc <.text+0x203dc>
   300e8: e79f0000     	ldr	r0, [pc, r0]
   300ec: e5900000     	ldr	r0, [r0]
   300f0: e3500009     	cmp	r0, #9
   300f4: ca000027     	bgt	0x30198 <.text+0x20098> @ imm = #0x9c
   300f8: e1a0000d     	mov	r0, sp
   300fc: e2407008     	sub	r7, r0, #8
   30100: e1a0d007     	mov	sp, r7
   30104: e59b1018     	ldr	r1, [r11, #0x18]
   30108: e5001008     	str	r1, [r0, #-0x8]
   3010c: e3a01f9e     	mov	r1, #632
   30110: e51b0024     	ldr	r0, [r11, #-0x24]
   30114: e5908000     	ldr	r8, [r0]
   30118: e3a00001     	mov	r0, #1
   3011c: eb158ea4     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x563a90
   30120: e59f53b8     	ldr	r5, [pc, #0x3b8]        @ 0x304e0 <.text+0x203e0>
   30124: e1a04000     	mov	r4, r0
   30128: e79f5005     	ldr	r5, [pc, r5]
   3012c: e1a00005     	mov	r0, r5
   30130: eb15d7f4     	bl	0x5a6108 <.text+0x596008> @ imm = #0x575fd0
   30134: e59f93a8     	ldr	r9, [pc, #0x3a8]        @ 0x304e4 <.text+0x203e4>
   30138: e79f9009     	ldr	r9, [pc, r9]
   3013c: e59f13a4     	ldr	r1, [pc, #0x3a4]        @ 0x304e8 <.text+0x203e8>
   30140: e2890001     	add	r0, r9, #1
   30144: e08f1001     	add	r1, pc, r1
   30148: e5810000     	str	r0, [r1]
   3014c: e1a00005     	mov	r0, r5
   30150: eb15d95b     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x57656c
   30154: e58491bc     	str	r9, [r4, #0x1bc]
   30158: e5864000     	str	r4, [r6]
   3015c: e28a4030     	add	r4, r10, #48
   30160: e1a00004     	mov	r0, r4
   30164: eb15da6b     	bl	0x5a6b18 <.text+0x596a18> @ imm = #0x5769ac
   30168: e59f137c     	ldr	r1, [pc, #0x37c]        @ 0x304ec <.text+0x203ec>
   3016c: e79f1001     	ldr	r1, [pc, r1]
   30170: e5911000     	ldr	r1, [r1]
   30174: e2412001     	sub	r2, r1, #1
   30178: e0010291     	mul	r1, r1, r2
   3017c: e3110001     	tst	r1, #1
   30180: 0a00001d     	beq	0x301fc <.text+0x200fc> @ imm = #0x74
   30184: e59f1364     	ldr	r1, [pc, #0x364]        @ 0x304f0 <.text+0x203f0>
   30188: e79f1001     	ldr	r1, [pc, r1]
   3018c: e5911000     	ldr	r1, [r1]
   30190: e3510009     	cmp	r1, #9
   30194: da000018     	ble	0x301fc <.text+0x200fc> @ imm = #0x60
   30198: e1a0000d     	mov	r0, sp
   3019c: e240d008     	sub	sp, r0, #8
   301a0: e59b1018     	ldr	r1, [r11, #0x18]
   301a4: e5001008     	str	r1, [r0, #-0x8]
   301a8: e3a00001     	mov	r0, #1
   301ac: e3a01f9e     	mov	r1, #632
   301b0: eb158e7f     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x5639fc
   301b4: e59f5384     	ldr	r5, [pc, #0x384]        @ 0x30540 <.text+0x20440>
   301b8: e1a04000     	mov	r4, r0
   301bc: e79f5005     	ldr	r5, [pc, r5]
   301c0: e1a00005     	mov	r0, r5
   301c4: eb15d7cf     	bl	0x5a6108 <.text+0x596008> @ imm = #0x575f3c
   301c8: e59f7374     	ldr	r7, [pc, #0x374]        @ 0x30544 <.text+0x20444>
   301cc: e79f7007     	ldr	r7, [pc, r7]
   301d0: e59f1370     	ldr	r1, [pc, #0x370]        @ 0x30548 <.text+0x20448>
   301d4: e2870001     	add	r0, r7, #1
   301d8: e08f1001     	add	r1, pc, r1
   301dc: e5810000     	str	r0, [r1]
   301e0: e1a00005     	mov	r0, r5
   301e4: eb15d936     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5764d8
   301e8: e28a0030     	add	r0, r10, #48
   301ec: e58471bc     	str	r7, [r4, #0x1bc]
   301f0: e5864000     	str	r4, [r6]
   301f4: eb15da47     	bl	0x5a6b18 <.text+0x596a18> @ imm = #0x57691c
   301f8: eaffffbe     	b	0x300f8 <.text+0x1fff8> @ imm = #-0x108
   301fc: e59b9014     	ldr	r9, [r11, #0x14]
   30200: e3500000     	cmp	r0, #0
   30204: e59b5010     	ldr	r5, [r11, #0x10]
   30208: 1a000037     	bne	0x302ec <.text+0x201ec> @ imm = #0xdc
   3020c: e59f32ec     	ldr	r3, [pc, #0x2ec]        @ 0x30500 <.text+0x20400>
   30210: e59f02ec     	ldr	r0, [pc, #0x2ec]        @ 0x30504 <.text+0x20404>
   30214: e59b1018     	ldr	r1, [r11, #0x18]
   30218: e08f3003     	add	r3, pc, r3
   3021c: e08f0000     	add	r0, pc, r0
   30220: e58a53c0     	str	r5, [r10, #0x3c0]
   30224: e58a93c4     	str	r9, [r10, #0x3c4]
   30228: e6bf1f31     	rev	r1, r1
   3022c: e5871000     	str	r1, [r7]
   30230: e24dd008     	sub	sp, sp, #8
   30234: e3001bc7     	movw	r1, #0xbc7
   30238: e88d0003     	stm	sp, {r0, r1}
   3023c: e28a0fa6     	add	r0, r10, #664
   30240: e1a01007     	mov	r1, r7
   30244: e3a02004     	mov	r2, #4
   30248: ebff86cb     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1e4d4
   3024c: e28dd008     	add	sp, sp, #8
   30250: e51b0028     	ldr	r0, [r11, #-0x28]
   30254: ed9a1bea     	vldr	d1, [r10, #936]
   30258: ed900bea     	vldr	d0, [r0, #936]
   3025c: e1a00004     	mov	r0, r4
   30260: eeb41bc0     	vcmpe.f64	d1, d0
   30264: eef1fa10     	vmrs	APSR_nzcv, fpscr
   30268: 4d8a0bea     	vstrmi	d0, [r10, #936]
   3026c: eb15da01     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x576804
   30270: e3500000     	cmp	r0, #0
   30274: 1a00002b     	bne	0x30328 <.text+0x20228> @ imm = #0xac
   30278: e51b5028     	ldr	r5, [r11, #-0x28]
   3027c: e2854030     	add	r4, r5, #48
   30280: e1a00004     	mov	r0, r4
   30284: eb15da23     	bl	0x5a6b18 <.text+0x596a18> @ imm = #0x57688c
   30288: e3500000     	cmp	r0, #0
   3028c: 1a000034     	bne	0x30364 <.text+0x20264> @ imm = #0xd0
   30290: e59b0010     	ldr	r0, [r11, #0x10]
   30294: e2900001     	adds	r0, r0, #1
   30298: e58503c0     	str	r0, [r5, #0x3c0]
   3029c: e1a00004     	mov	r0, r4
   302a0: e2a91000     	adc	r1, r9, #0
   302a4: e58513c4     	str	r1, [r5, #0x3c4]
   302a8: eb15d9f2     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x5767c8
   302ac: e3500000     	cmp	r0, #0
   302b0: 1a00003a     	bne	0x303a0 <.text+0x202a0> @ imm = #0xe8
   302b4: e59f0270     	ldr	r0, [pc, #0x270]        @ 0x3052c <.text+0x2042c>
   302b8: e59b4008     	ldr	r4, [r11, #0x8]
   302bc: e79f0000     	ldr	r0, [pc, r0]
   302c0: e5900000     	ldr	r0, [r0]
   302c4: e2401001     	sub	r1, r0, #1
   302c8: e0000190     	mul	r0, r0, r1
   302cc: e3100001     	tst	r0, #1
   302d0: 0a000041     	beq	0x303dc <.text+0x202dc> @ imm = #0x104
   302d4: e59f0254     	ldr	r0, [pc, #0x254]        @ 0x30530 <.text+0x20430>
   302d8: e79f0000     	ldr	r0, [pc, r0]
   302dc: e5900000     	ldr	r0, [r0]
   302e0: e3500009     	cmp	r0, #9
   302e4: ca000060     	bgt	0x3046c <.text+0x2036c> @ imm = #0x180
   302e8: ea00003b     	b	0x303dc <.text+0x202dc> @ imm = #0xec
   302ec: eb158bbc     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562ef0
   302f0: e59f21fc     	ldr	r2, [pc, #0x1fc]        @ 0x304f4 <.text+0x203f4>
   302f4: e59f11fc     	ldr	r1, [pc, #0x1fc]        @ 0x304f8 <.text+0x203f8>
   302f8: e5900000     	ldr	r0, [r0]
   302fc: e08f2002     	add	r2, pc, r2
   30300: e59f31f4     	ldr	r3, [pc, #0x1f4]        @ 0x304fc <.text+0x203fc>
   30304: e08f1001     	add	r1, pc, r1
   30308: e08f3003     	add	r3, pc, r3
   3030c: e24dd008     	sub	sp, sp, #8
   30310: e58d0000     	str	r0, [sp]
   30314: e1a00002     	mov	r0, r2
   30318: e300223d     	movw	r2, #0x23d
   3031c: ebff7fdd     	bl	0x10298 <.text+0x198>   @ imm = #-0x2008c
   30320: e28dd008     	add	sp, sp, #8
   30324: eaffffb8     	b	0x3020c <.text+0x2010c> @ imm = #-0x120
   30328: eb158bad     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562eb4
   3032c: e59f21d4     	ldr	r2, [pc, #0x1d4]        @ 0x30508 <.text+0x20408>
   30330: e59f11d4     	ldr	r1, [pc, #0x1d4]        @ 0x3050c <.text+0x2040c>
   30334: e5900000     	ldr	r0, [r0]
   30338: e08f2002     	add	r2, pc, r2
   3033c: e59f31cc     	ldr	r3, [pc, #0x1cc]        @ 0x30510 <.text+0x20410>
   30340: e08f1001     	add	r1, pc, r1
   30344: e08f3003     	add	r3, pc, r3
   30348: e24dd008     	sub	sp, sp, #8
   3034c: e58d0000     	str	r0, [sp]
   30350: e1a00002     	mov	r0, r2
   30354: e300224f     	movw	r2, #0x24f
   30358: ebff7fce     	bl	0x10298 <.text+0x198>   @ imm = #-0x200c8
   3035c: e28dd008     	add	sp, sp, #8
   30360: eaffffc4     	b	0x30278 <.text+0x20178> @ imm = #-0xf0
   30364: eb158b9e     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562e78
   30368: e59f21a4     	ldr	r2, [pc, #0x1a4]        @ 0x30514 <.text+0x20414>
   3036c: e59f11a4     	ldr	r1, [pc, #0x1a4]        @ 0x30518 <.text+0x20418>
   30370: e5900000     	ldr	r0, [r0]
   30374: e08f2002     	add	r2, pc, r2
   30378: e59f319c     	ldr	r3, [pc, #0x19c]        @ 0x3051c <.text+0x2041c>
   3037c: e08f1001     	add	r1, pc, r1
   30380: e08f3003     	add	r3, pc, r3
   30384: e24dd008     	sub	sp, sp, #8
   30388: e58d0000     	str	r0, [sp]
   3038c: e1a00002     	mov	r0, r2
   30390: e300223d     	movw	r2, #0x23d
   30394: ebff7fbf     	bl	0x10298 <.text+0x198>   @ imm = #-0x20104
   30398: e28dd008     	add	sp, sp, #8
   3039c: eaffffbb     	b	0x30290 <.text+0x20190> @ imm = #-0x114
   303a0: eb158b8f     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562e3c
   303a4: e59f2174     	ldr	r2, [pc, #0x174]        @ 0x30520 <.text+0x20420>
   303a8: e59f1174     	ldr	r1, [pc, #0x174]        @ 0x30524 <.text+0x20424>
   303ac: e5900000     	ldr	r0, [r0]
   303b0: e08f2002     	add	r2, pc, r2
   303b4: e59f316c     	ldr	r3, [pc, #0x16c]        @ 0x30528 <.text+0x20428>
   303b8: e08f1001     	add	r1, pc, r1
   303bc: e08f3003     	add	r3, pc, r3
   303c0: e24dd008     	sub	sp, sp, #8
   303c4: e58d0000     	str	r0, [sp]
   303c8: e1a00002     	mov	r0, r2
   303cc: e300224f     	movw	r2, #0x24f
   303d0: ebff7fb0     	bl	0x10298 <.text+0x198>   @ imm = #-0x20140
   303d4: e28dd008     	add	sp, sp, #8
   303d8: eaffffb5     	b	0x302b4 <.text+0x201b4> @ imm = #-0x12c
   303dc: e5961000     	ldr	r1, [r6]
   303e0: e1a0000a     	mov	r0, r10
   303e4: eb000059     	bl	0x30550 <.text+0x20450> @ imm = #0x164
   303e8: e5960000     	ldr	r0, [r6]
   303ec: e580516c     	str	r5, [r0, #0x16c]
   303f0: e5960000     	ldr	r0, [r6]
   303f4: e5808168     	str	r8, [r0, #0x168]
   303f8: e5960000     	ldr	r0, [r6]
   303fc: e59f1130     	ldr	r1, [pc, #0x130]        @ 0x30534 <.text+0x20434>
   30400: e79f1001     	ldr	r1, [pc, r1]
   30404: e58011b8     	str	r1, [r0, #0x1b8]
   30408: e5960000     	ldr	r0, [r6]
   3040c: e590016c     	ldr	r0, [r0, #0x16c]
   30410: e5901098     	ldr	r1, [r0, #0x98]
   30414: e2811001     	add	r1, r1, #1
   30418: e5801098     	str	r1, [r0, #0x98]
   3041c: e5960000     	ldr	r0, [r6]
   30420: e3a01001     	mov	r1, #1
   30424: e5804160     	str	r4, [r0, #0x160]
   30428: e5960000     	ldr	r0, [r6]
   3042c: e5c01180     	strb	r1, [r0, #0x180]
   30430: e5960000     	ldr	r0, [r6]
   30434: e5971000     	ldr	r1, [r7]
   30438: e5801254     	str	r1, [r0, #0x254]
   3043c: e59f00f4     	ldr	r0, [pc, #0xf4]         @ 0x30538 <.text+0x20438>
   30440: e79f0000     	ldr	r0, [pc, r0]
   30444: e5900000     	ldr	r0, [r0]
   30448: e2401001     	sub	r1, r0, #1
   3044c: e0000190     	mul	r0, r0, r1
   30450: e3100001     	tst	r0, #1
   30454: 0a00001d     	beq	0x304d0 <.text+0x203d0> @ imm = #0x74
   30458: e59f00dc     	ldr	r0, [pc, #0xdc]         @ 0x3053c <.text+0x2043c>
   3045c: e79f0000     	ldr	r0, [pc, r0]
   30460: e5900000     	ldr	r0, [r0]
   30464: e3500009     	cmp	r0, #9
   30468: da000018     	ble	0x304d0 <.text+0x203d0> @ imm = #0x60
   3046c: e5961000     	ldr	r1, [r6]
   30470: e1a0000a     	mov	r0, r10
   30474: eb000035     	bl	0x30550 <.text+0x20450> @ imm = #0xd4
   30478: e5960000     	ldr	r0, [r6]
   3047c: e580516c     	str	r5, [r0, #0x16c]
   30480: e5960000     	ldr	r0, [r6]
   30484: e5808168     	str	r8, [r0, #0x168]
   30488: e5960000     	ldr	r0, [r6]
   3048c: e59f10b8     	ldr	r1, [pc, #0xb8]         @ 0x3054c <.text+0x2044c>
   30490: e79f1001     	ldr	r1, [pc, r1]
   30494: e58011b8     	str	r1, [r0, #0x1b8]
   30498: e5960000     	ldr	r0, [r6]
   3049c: e590016c     	ldr	r0, [r0, #0x16c]
   304a0: e5901098     	ldr	r1, [r0, #0x98]
   304a4: e2811001     	add	r1, r1, #1
   304a8: e5801098     	str	r1, [r0, #0x98]
   304ac: e5960000     	ldr	r0, [r6]
   304b0: e3a01001     	mov	r1, #1
   304b4: e5804160     	str	r4, [r0, #0x160]
   304b8: e5960000     	ldr	r0, [r6]
   304bc: e5c01180     	strb	r1, [r0, #0x180]
   304c0: e5960000     	ldr	r0, [r6]
   304c4: e5971000     	ldr	r1, [r7]
   304c8: e5801254     	str	r1, [r0, #0x254]
   304cc: eaffffc2     	b	0x303dc <.text+0x202dc> @ imm = #-0xf8
   304d0: e24bd01c     	sub	sp, r11, #28
   304d4: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   304d8: 005af54c     	subseq	pc, r10, r12, asr #10
   304dc: 005ae890     	<unknown>
   304e0: 005af934     	subseq	pc, r10, r4, lsr r9
   304e4: 005e06c8     	subseq	r0, lr, r8, asr #13
   304e8: 005e06bc     	ldrheq	r0, [lr], #-108
   304ec: 005af4ac     	subseq	pc, r10, r12, lsr #9
   304f0: 005ae7f0     	ldrsheq	lr, [r10], #-112
   304f4: 005b2373     	subseq	r2, r11, r3, ror r3
   304f8: 005b1eb9     	ldrheq	r1, [r11], #-233
   304fc: 005b2c4c     	subseq	r2, r11, r12, asr #24
   30500: 005b1f74     	subseq	r1, r11, r4, ror pc
   30504: 005b1f92     	<unknown>
   30508: 005b2337     	subseq	r2, r11, r7, lsr r3
   3050c: 005b1e7d     	subseq	r1, r11, sp, ror lr
   30510: 005b2372     	subseq	r2, r11, r2, ror r3
   30514: 005b22fb     	ldrsheq	r2, [r11], #-43
   30518: 005b1e41     	subseq	r1, r11, r1, asr #28
   3051c: 005b2bd4     	ldrsbeq	r2, [r11], #-180
   30520: 005b22bf     	ldrheq	r2, [r11], #-47
   30524: 005b1e05     	subseq	r1, r11, r5, lsl #28
   30528: 005b22fa     	ldrsheq	r2, [r11], #-42
   3052c: 005af35c     	subseq	pc, r10, r12, asr r3
   30530: 005ae6a0     	subseq	lr, r10, r0, lsr #13
   30534: 005e0380     	subseq	r0, lr, r0, lsl #7
   30538: 005af1d8     	ldrsbeq	pc, [r10], #-24
   3053c: 005ae51c     	subseq	lr, r10, r12, lsl r5
   30540: 005af8a0     	subseq	pc, r10, r0, lsr #17
   30544: 005e0634     	subseq	r0, lr, r4, lsr r6
   30548: 005e0628     	subseq	r0, lr, r8, lsr #12
   3054c: 005e02f0     	ldrsheq	r0, [lr], #-32

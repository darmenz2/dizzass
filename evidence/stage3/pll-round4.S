
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ff660: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   ff664: e28db01c     	add	r11, sp, #28
   ff668: e24dd004     	sub	sp, sp, #4
   ff66c: ed2d8b0a     	vpush	{d8, d9, d10, d11, d12}
   ff670: e24dd058     	sub	sp, sp, #88
   ff674: e50b004c     	str	r0, [r11, #-0x4c]
   ff678: e59f053c     	ldr	r0, [pc, #0x53c]        @ 0xffbbc <.text+0xefabc>
   ff67c: e79f0000     	ldr	r0, [pc, r0]
   ff680: e5900000     	ldr	r0, [r0]
   ff684: e2403001     	sub	r3, r0, #1
   ff688: e0000390     	mul	r0, r0, r3
   ff68c: e3100001     	tst	r0, #1
   ff690: 0a000004     	beq	0xff6a8 <.text+0xef5a8> @ imm = #0x10
   ff694: e59f0524     	ldr	r0, [pc, #0x524]        @ 0xffbc0 <.text+0xefac0>
   ff698: e79f0000     	ldr	r0, [pc, r0]
   ff69c: e5900000     	ldr	r0, [r0]
   ff6a0: e3500009     	cmp	r0, #9
   ff6a4: ca000017     	bgt	0xff708 <.text+0xef608> @ imm = #0x5c
   ff6a8: e51b204c     	ldr	r2, [r11, #-0x4c]
   ff6ac: e3a00000     	mov	r0, #0
   ff6b0: ed921b0c     	vldr	d1, [r2, #48]
   ff6b4: e5810000     	str	r0, [r1]
   ff6b8: e5810004     	str	r0, [r1, #0x4]
   ff6bc: e5810008     	str	r0, [r1, #0x8]
   ff6c0: e581000c     	str	r0, [r1, #0xc]
   ff6c4: e5810010     	str	r0, [r1, #0x10]
   ff6c8: e5810014     	str	r0, [r1, #0x14]
   ff6cc: e5810018     	str	r0, [r1, #0x18]
   ff6d0: e581001c     	str	r0, [r1, #0x1c]
   ff6d4: e59f04e8     	ldr	r0, [pc, #0x4e8]        @ 0xffbc4 <.text+0xefac4>
   ff6d8: e79f0000     	ldr	r0, [pc, r0]
   ff6dc: e5900000     	ldr	r0, [r0]
   ff6e0: e2403001     	sub	r3, r0, #1
   ff6e4: e0000390     	mul	r0, r0, r3
   ff6e8: e5923020     	ldr	r3, [r2, #0x20]
   ff6ec: e3100001     	tst	r0, #1
   ff6f0: 0a00000e     	beq	0xff730 <.text+0xef630> @ imm = #0x38
   ff6f4: e59f04cc     	ldr	r0, [pc, #0x4cc]        @ 0xffbc8 <.text+0xefac8>
   ff6f8: e79f0000     	ldr	r0, [pc, r0]
   ff6fc: e5900000     	ldr	r0, [r0]
   ff700: e3500009     	cmp	r0, #9
   ff704: da000009     	ble	0xff730 <.text+0xef630> @ imm = #0x24
   ff708: e3a00000     	mov	r0, #0
   ff70c: e5810000     	str	r0, [r1]
   ff710: e5810004     	str	r0, [r1, #0x4]
   ff714: e5810008     	str	r0, [r1, #0x8]
   ff718: e581000c     	str	r0, [r1, #0xc]
   ff71c: e5810010     	str	r0, [r1, #0x10]
   ff720: e5810014     	str	r0, [r1, #0x14]
   ff724: e5810018     	str	r0, [r1, #0x18]
   ff728: e581001c     	str	r0, [r1, #0x1c]
   ff72c: eaffffdd     	b	0xff6a8 <.text+0xef5a8> @ imm = #-0x8c
   ff730: e3530001     	cmp	r3, #1
   ff734: ba000108     	blt	0xffb5c <.text+0xefa5c> @ imm = #0x420
   ff738: e2630000     	rsb	r0, r3, #0
   ff73c: e58d0024     	str	r0, [sp, #0x24]
   ff740: e1a00083     	lsl	r0, r3, #1
   ff744: e0832083     	add	r2, r3, r3, lsl #1
   ff748: e58d001c     	str	r0, [sp, #0x1c]
   ff74c: e2430001     	sub	r0, r3, #1
   ff750: e58d0020     	str	r0, [sp, #0x20]
   ff754: e51b004c     	ldr	r0, [r11, #-0x4c]
   ff758: ed9f2be8     	vldr	d2, [pc, #928]          @ 0xffb00 <.text+0xefa00>
   ff75c: ed9f3be9     	vldr	d3, [pc, #932]          @ 0xffb08 <.text+0xefa08>
   ff760: e5907028     	ldr	r7, [r0, #0x28]
   ff764: e3a00000     	mov	r0, #0
   ff768: e58d0048     	str	r0, [sp, #0x48]
   ff76c: e3a00000     	mov	r0, #0
   ff770: e58d0040     	str	r0, [sp, #0x40]
   ff774: e3a00000     	mov	r0, #0
   ff778: ed9f4be4     	vldr	d4, [pc, #912]          @ 0xffb10 <.text+0xefa10>
   ff77c: ed9f5be5     	vldr	d5, [pc, #916]          @ 0xffb18 <.text+0xefa18>
   ff780: ed9f6be6     	vldr	d6, [pc, #920]          @ 0xffb20 <.text+0xefa20>
   ff784: e58d0044     	str	r0, [sp, #0x44]
   ff788: e3a00000     	mov	r0, #0
   ff78c: e58d004c     	str	r0, [sp, #0x4c]
   ff790: e58d7018     	str	r7, [sp, #0x18]
   ff794: e3570000     	cmp	r7, #0
   ff798: e58d2014     	str	r2, [sp, #0x14]
   ff79c: 4a0000c7     	bmi	0xffac0 <.text+0xef9c0> @ imm = #0x31c
   ff7a0: ee073a10     	vmov	s14, r3
   ff7a4: e3a00000     	mov	r0, #0
   ff7a8: e3a0e001     	mov	lr, #1
   ff7ac: e1a05003     	mov	r5, r3
   ff7b0: eeb87bc7     	vcvt.f64.s32	d7, s14
   ff7b4: e58d003c     	str	r0, [sp, #0x3c]
   ff7b8: e51b004c     	ldr	r0, [r11, #-0x4c]
   ff7bc: e59d6020     	ldr	r6, [sp, #0x20]
   ff7c0: e590a024     	ldr	r10, [r0, #0x24]
   ff7c4: ed908b00     	vldr	d8, [r0]
   ff7c8: e59d0024     	ldr	r0, [sp, #0x24]
   ff7cc: e58d0050     	str	r0, [sp, #0x50]
   ff7d0: ea000011     	b	0xff81c <.text+0xef71c> @ imm = #0x44
   ff7d4: e59d0024     	ldr	r0, [sp, #0x24]
   ff7d8: e59d2050     	ldr	r2, [sp, #0x50]
   ff7dc: e59d5034     	ldr	r5, [sp, #0x34]
   ff7e0: e0822000     	add	r2, r2, r0
   ff7e4: e58d2050     	str	r2, [sp, #0x50]
   ff7e8: e59d2030     	ldr	r2, [sp, #0x30]
   ff7ec: e59d001c     	ldr	r0, [sp, #0x1c]
   ff7f0: e0855002     	add	r5, r5, r2
   ff7f4: e59d602c     	ldr	r6, [sp, #0x2c]
   ff7f8: e0822000     	add	r2, r2, r0
   ff7fc: e59d0020     	ldr	r0, [sp, #0x20]
   ff800: e59de038     	ldr	lr, [sp, #0x38]
   ff804: e0866000     	add	r6, r6, r0
   ff808: e59d7018     	ldr	r7, [sp, #0x18]
   ff80c: e59d0028     	ldr	r0, [sp, #0x28]
   ff810: e28ee001     	add	lr, lr, #1
   ff814: e1500007     	cmp	r0, r7
   ff818: aa0000a8     	bge	0xffac0 <.text+0xef9c0> @ imm = #0x2a0
   ff81c: e59d703c     	ldr	r7, [sp, #0x3c]
   ff820: e58d2030     	str	r2, [sp, #0x30]
   ff824: e2870001     	add	r0, r7, #1
   ff828: e58d003c     	str	r0, [sp, #0x3c]
   ff82c: ee090a10     	vmov	s18, r0
   ff830: eeb89bc9     	vcvt.f64.s32	d9, s18
   ff834: e58d5034     	str	r5, [sp, #0x34]
   ff838: e58d602c     	str	r6, [sp, #0x2c]
   ff83c: e58de038     	str	lr, [sp, #0x38]
   ff840: e58d7028     	str	r7, [sp, #0x28]
   ff844: ea000015     	b	0xff8a0 <.text+0xef7a0> @ imm = #0x54
   ff848: eeb4bbc6     	vcmpe.f64	d11, d6
   ff84c: e59d203c     	ldr	r2, [sp, #0x3c]
   ff850: e3a00001     	mov	r0, #1
   ff854: e5813008     	str	r3, [r1, #0x8]
   ff858: e581800c     	str	r8, [r1, #0xc]
   ff85c: e5812010     	str	r2, [r1, #0x10]
   ff860: eeb01b4b     	vmov.f64	d1, d11
   ff864: e581e014     	str	lr, [r1, #0x14]
   ff868: e5810018     	str	r0, [r1, #0x18]
   ff86c: e28d0040     	add	r0, sp, #64
   ff870: e58d304c     	str	r3, [sp, #0x4c]
   ff874: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff878: ed81ab00     	vstr	d10, [r1]
   ff87c: e8804104     	stm	r0, {r2, r8, lr}
   ff880: 4a0000a8     	bmi	0xffb28 <.text+0xefa28> @ imm = #0x2a0
   ff884: e59d0050     	ldr	r0, [sp, #0x50]
   ff888: e24ee001     	sub	lr, lr, #1
   ff88c: e2866001     	add	r6, r6, #1
   ff890: e2477001     	sub	r7, r7, #1
   ff894: e0855000     	add	r5, r5, r0
   ff898: e35e0000     	cmp	lr, #0
   ff89c: da000074     	ble	0xffa74 <.text+0xef974> @ imm = #0x1d0
   ff8a0: e59f0330     	ldr	r0, [pc, #0x330]        @ 0xffbd8 <.text+0xefad8>
   ff8a4: e79f0000     	ldr	r0, [pc, r0]
   ff8a8: e5900000     	ldr	r0, [r0]
   ff8ac: e2404001     	sub	r4, r0, #1
   ff8b0: e0000490     	mul	r0, r0, r4
   ff8b4: e3100001     	tst	r0, #1
   ff8b8: ee0a5a10     	vmov	s20, r5
   ff8bc: e3a09000     	mov	r9, #0
   ff8c0: e3a0c000     	mov	r12, #0
   ff8c4: eeb8abca     	vcvt.f64.s32	d10, s20
   ff8c8: ee2aab00     	vmul.f64	d10, d10, d0
   ff8cc: ee2aab02     	vmul.f64	d10, d10, d2
   ff8d0: ee8aab03     	vdiv.f64	d10, d10, d3
   ff8d4: ee3aab04     	vadd.f64	d10, d10, d4
   ff8d8: eebdabca     	vcvt.s32.f64	s20, d10
   ff8dc: ee1a8a10     	vmov	r8, s20
   ff8e0: eeb8abca     	vcvt.f64.s32	d10, s20
   ff8e4: e59f02f0     	ldr	r0, [pc, #0x2f0]        @ 0xffbdc <.text+0xefadc>
   ff8e8: e79f0000     	ldr	r0, [pc, r0]
   ff8ec: e5900000     	ldr	r0, [r0]
   ff8f0: ee28ab0a     	vmul.f64	d10, d8, d10
   ff8f4: e2404001     	sub	r4, r0, #1
   ff8f8: e0020490     	mul	r2, r0, r4
   ff8fc: e3a04000     	mov	r4, #0
   ff900: e15a0008     	cmp	r10, r8
   ff904: ee8aab07     	vdiv.f64	d10, d10, d7
   ff908: a3009001     	movwge	r9, #0x1
   ff90c: e3580007     	cmp	r8, #7
   ff910: c300c001     	movwgt	r12, #0x1
   ff914: eeb4abc5     	vcmpe.f64	d10, d5
   ff918: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff91c: 93004001     	movwls	r4, #0x1
   ff920: e2530001     	subs	r0, r3, #1
   ff924: 13000001     	movwne	r0, #0x1
   ff928: e3120001     	tst	r2, #1
   ff92c: 0a000004     	beq	0xff944 <.text+0xef844> @ imm = #0x10
   ff930: e59f22a8     	ldr	r2, [pc, #0x2a8]        @ 0xffbe0 <.text+0xefae0>
   ff934: e79f2002     	ldr	r2, [pc, r2]
   ff938: e5922000     	ldr	r2, [r2]
   ff93c: e3520009     	cmp	r2, #9
   ff940: caffffdc     	bgt	0xff8b8 <.text+0xef7b8> @ imm = #-0x90
   ff944: e00c2009     	and	r2, r12, r9
   ff948: e1800004     	orr	r0, r0, r4
   ff94c: e0120000     	ands	r0, r2, r0
   ff950: 0affffcb     	beq	0xff884 <.text+0xef784> @ imm = #-0xd4
   ff954: e51b004c     	ldr	r0, [r11, #-0x4c]
   ff958: ed90bb06     	vldr	d11, [r0, #24]
   ff95c: eeb4abcb     	vcmpe.f64	d10, d11
   ff960: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff964: baffffc6     	blt	0xff884 <.text+0xef784> @ imm = #-0xe8
   ff968: e59f0274     	ldr	r0, [pc, #0x274]        @ 0xffbe4 <.text+0xefae4>
   ff96c: e79f0000     	ldr	r0, [pc, r0]
   ff970: e5900000     	ldr	r0, [r0]
   ff974: e2402001     	sub	r2, r0, #1
   ff978: e0000290     	mul	r0, r0, r2
   ff97c: e3100001     	tst	r0, #1
   ff980: e59f0260     	ldr	r0, [pc, #0x260]        @ 0xffbe8 <.text+0xefae8>
   ff984: e79f0000     	ldr	r0, [pc, r0]
   ff988: e5900000     	ldr	r0, [r0]
   ff98c: e2402001     	sub	r2, r0, #1
   ff990: e0000290     	mul	r0, r0, r2
   ff994: e51b204c     	ldr	r2, [r11, #-0x4c]
   ff998: ed92bb02     	vldr	d11, [r2, #8]
   ff99c: e3100001     	tst	r0, #1
   ff9a0: 0a000004     	beq	0xff9b8 <.text+0xef8b8> @ imm = #0x10
   ff9a4: e59f0240     	ldr	r0, [pc, #0x240]        @ 0xffbec <.text+0xefaec>
   ff9a8: e79f0000     	ldr	r0, [pc, r0]
   ff9ac: e5900000     	ldr	r0, [r0]
   ff9b0: e3500009     	cmp	r0, #9
   ff9b4: cafffff1     	bgt	0xff980 <.text+0xef880> @ imm = #-0x3c
   ff9b8: eeb4abcb     	vcmpe.f64	d10, d11
   ff9bc: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ff9c0: 8affffaf     	bhi	0xff884 <.text+0xef784> @ imm = #-0x144
   ff9c4: ee8abb09     	vdiv.f64	d11, d10, d9
   ff9c8: ee0cea10     	vmov	s24, lr
   ff9cc: eeb8cbcc     	vcvt.f64.s32	d12, s24
   ff9d0: e59d004c     	ldr	r0, [sp, #0x4c]
   ff9d4: e3500001     	cmp	r0, #1
   ff9d8: ee8bbb0c     	vdiv.f64	d11, d11, d12
   ff9dc: ee3bbb40     	vsub.f64	d11, d11, d0
   ff9e0: eeb0bbcb     	vabs.f64	d11, d11
   ff9e4: baffff97     	blt	0xff848 <.text+0xef748> @ imm = #-0x1a4
   ff9e8: e59d0044     	ldr	r0, [sp, #0x44]
   ff9ec: e3500001     	cmp	r0, #1
   ff9f0: a59d0040     	ldrge	r0, [sp, #0x40]
   ff9f4: a3500001     	cmpge	r0, #1
   ff9f8: baffff92     	blt	0xff848 <.text+0xef748> @ imm = #-0x1b8
   ff9fc: e59f01ec     	ldr	r0, [pc, #0x1ec]        @ 0xffbf0 <.text+0xefaf0>
   ffa00: e79f0000     	ldr	r0, [pc, r0]
   ffa04: e5900000     	ldr	r0, [r0]
   ffa08: e2402001     	sub	r2, r0, #1
   ffa0c: e0000290     	mul	r0, r0, r2
   ffa10: e3100001     	tst	r0, #1
   ffa14: ee31cb06     	vadd.f64	d12, d1, d6
   ffa18: e59f01d4     	ldr	r0, [pc, #0x1d4]        @ 0xffbf4 <.text+0xefaf4>
   ffa1c: e3a04000     	mov	r4, #0
   ffa20: e79f0000     	ldr	r0, [pc, r0]
   ffa24: e5900000     	ldr	r0, [r0]
   ffa28: e2402001     	sub	r2, r0, #1
   ffa2c: eeb4bbcc     	vcmpe.f64	d11, d12
   ffa30: e0020290     	mul	r2, r0, r2
   ffa34: e59d0048     	ldr	r0, [sp, #0x48]
   ffa38: eef1fa10     	vmrs	APSR_nzcv, fpscr
   ffa3c: 43004001     	movwmi	r4, #0x1
   ffa40: e3500001     	cmp	r0, #1
   ffa44: e3a00000     	mov	r0, #0
   ffa48: b3000001     	movwlt	r0, #0x1
   ffa4c: e3120001     	tst	r2, #1
   ffa50: 0a000004     	beq	0xffa68 <.text+0xef968> @ imm = #0x10
   ffa54: e59f219c     	ldr	r2, [pc, #0x19c]        @ 0xffbf8 <.text+0xefaf8>
   ffa58: e79f2002     	ldr	r2, [pc, r2]
   ffa5c: e5922000     	ldr	r2, [r2]
   ffa60: e3520009     	cmp	r2, #9
   ffa64: caffffea     	bgt	0xffa14 <.text+0xef914> @ imm = #-0x58
   ffa68: e1940000     	orrs	r0, r4, r0
   ffa6c: 1affff75     	bne	0xff848 <.text+0xef748> @ imm = #-0x22c
   ffa70: eaffff83     	b	0xff884 <.text+0xef784> @ imm = #-0x1f4
   ffa74: e59f0150     	ldr	r0, [pc, #0x150]        @ 0xffbcc <.text+0xefacc>
   ffa78: e79f0000     	ldr	r0, [pc, r0]
   ffa7c: e5900000     	ldr	r0, [r0]
   ffa80: e2407001     	sub	r7, r0, #1
   ffa84: e0000790     	mul	r0, r0, r7
   ffa88: e3100001     	tst	r0, #1
   ffa8c: e59f013c     	ldr	r0, [pc, #0x13c]        @ 0xffbd0 <.text+0xefad0>
   ffa90: e79f0000     	ldr	r0, [pc, r0]
   ffa94: e5900000     	ldr	r0, [r0]
   ffa98: e2407001     	sub	r7, r0, #1
   ffa9c: e0000790     	mul	r0, r0, r7
   ffaa0: e3100001     	tst	r0, #1
   ffaa4: 0affff4a     	beq	0xff7d4 <.text+0xef6d4> @ imm = #-0x2d8
   ffaa8: e59f0124     	ldr	r0, [pc, #0x124]        @ 0xffbd4 <.text+0xefad4>
   ffaac: e79f0000     	ldr	r0, [pc, r0]
   ffab0: e5900000     	ldr	r0, [r0]
   ffab4: e3500009     	cmp	r0, #9
   ffab8: cafffff3     	bgt	0xffa8c <.text+0xef98c> @ imm = #-0x34
   ffabc: eaffff44     	b	0xff7d4 <.text+0xef6d4> @ imm = #-0x2f0
   ffac0: e59d0024     	ldr	r0, [sp, #0x24]
   ffac4: e2433001     	sub	r3, r3, #1
   ffac8: e59d2014     	ldr	r2, [sp, #0x14]
   ffacc: e3530000     	cmp	r3, #0
   ffad0: e2800001     	add	r0, r0, #1
   ffad4: e58d0024     	str	r0, [sp, #0x24]
   ffad8: e59d001c     	ldr	r0, [sp, #0x1c]
   ffadc: e2422003     	sub	r2, r2, #3
   ffae0: e2400002     	sub	r0, r0, #2
   ffae4: e58d001c     	str	r0, [sp, #0x1c]
   ffae8: e59d0020     	ldr	r0, [sp, #0x20]
   ffaec: e2400001     	sub	r0, r0, #1
   ffaf0: e58d0020     	str	r0, [sp, #0x20]
   ffaf4: caffff26     	bgt	0xff794 <.text+0xef694> @ imm = #-0x368
   ffaf8: ea00000f     	b	0xffb3c <.text+0xefa3c> @ imm = #0x3c
   ffafc: e320f000     	nop
   ffb00: 00000000     	andeq	r0, r0, r0
   ffb04: 40100000     	andsmi	r0, r0, r0
   ffb08: 00000000     	andeq	r0, r0, r0
   ffb0c: 40590000     	subsmi	r0, r9, r0
   ffb10: 00000000     	andeq	r0, r0, r0
   ffb14: 3fe00000     	svclo	#0xe00000
   ffb18: 00000000     	andeq	r0, r0, r0
   ffb1c: 40ca0680     	sbcmi	r0, r10, r0, lsl #13
   ffb20: 9999999a     	ldmibls	r9, {r1, r3, r4, r7, r8, r11, r12, pc}
   ffb24: 3fb99999     	svclo	#0xb99999
   ffb28: e59d003c     	ldr	r0, [sp, #0x3c]
   ffb2c: e58de048     	str	lr, [sp, #0x48]
   ffb30: e58d0040     	str	r0, [sp, #0x40]
   ffb34: e58d8044     	str	r8, [sp, #0x44]
   ffb38: e58d304c     	str	r3, [sp, #0x4c]
   ffb3c: e59d004c     	ldr	r0, [sp, #0x4c]
   ffb40: e3500001     	cmp	r0, #1
   ffb44: ba000004     	blt	0xffb5c <.text+0xefa5c> @ imm = #0x10
   ffb48: e59d0044     	ldr	r0, [sp, #0x44]
   ffb4c: e3500001     	cmp	r0, #1
   ffb50: a59d0040     	ldrge	r0, [sp, #0x40]
   ffb54: a3500001     	cmpge	r0, #1
   ffb58: aa000012     	bge	0xffba8 <.text+0xefaa8> @ imm = #0x48
   ffb5c: e59f0098     	ldr	r0, [pc, #0x98]         @ 0xffbfc <.text+0xefafc>
   ffb60: e3a07001     	mov	r7, #1
   ffb64: e59f1094     	ldr	r1, [pc, #0x94]         @ 0xffc00 <.text+0xefb00>
   ffb68: e59f2094     	ldr	r2, [pc, #0x94]         @ 0xffc04 <.text+0xefb04>
   ffb6c: e08f0000     	add	r0, pc, r0
   ffb70: e59f3090     	ldr	r3, [pc, #0x90]         @ 0xffc08 <.text+0xefb08>
   ffb74: e08f1001     	add	r1, pc, r1
   ffb78: e08f2002     	add	r2, pc, r2
   ffb7c: ed8d0b02     	vstr	d0, [sp, #8]
   ffb80: e08f3003     	add	r3, pc, r3
   ffb84: e58d3004     	str	r3, [sp, #0x4]
   ffb88: e3a03080     	mov	r3, #128
   ffb8c: e58d7000     	str	r7, [sp]
   ffb90: ebffe94b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x5ad4
   ffb94: e3e00000     	mvn	r0, #0
   ffb98: e24bd048     	sub	sp, r11, #72
   ffb9c: ecbd8b0a     	vpop	{d8, d9, d10, d11, d12}
   ffba0: e28dd004     	add	sp, sp, #4
   ffba4: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   ffba8: e59d1048     	ldr	r1, [sp, #0x48]
   ffbac: e3a00000     	mov	r0, #0
   ffbb0: e3510000     	cmp	r1, #0
   ffbb4: cafffff7     	bgt	0xffb98 <.text+0xefa98> @ imm = #-0x24
   ffbb8: eaffffe7     	b	0xffb5c <.text+0xefa5c> @ imm = #-0x64
   ffbbc: 004defc8     	subeq	lr, sp, r8, asr #31
   ffbc0: 004df6e0     	subeq	pc, sp, r0, ror #13
   ffbc4: 004def6c     	subeq	lr, sp, r12, ror #30
   ffbc8: 004df680     	subeq	pc, sp, r0, lsl #13
   ffbcc: 004debcc     	subeq	lr, sp, r12, asr #23
   ffbd0: 004debb4     	strheq	lr, [sp], #-180
   ffbd4: 004df2cc     	subeq	pc, sp, r12, asr #5
   ffbd8: 004deda0     	subeq	lr, sp, r0, lsr #27
   ffbdc: 004ded5c     	subeq	lr, sp, r12, asr sp
   ffbe0: 004df444     	subeq	pc, sp, r4, asr #8
   ffbe4: 004decd8     	ldrdeq	lr, pc, [sp], #-200
   ffbe8: 004decc0     	subeq	lr, sp, r0, asr #25
   ffbec: 004df3d0     	<unknown>
   ffbf0: 004dec44     	subeq	lr, sp, r4, asr #24
   ffbf4: 004dec24     	subeq	lr, sp, r4, lsr #24
   ffbf8: 004df320     	subeq	pc, sp, r0, lsr #6
   ffbfc: 004ed59e     	umaaleq	sp, lr, lr, r5
   ffc00: 004ed59d     	umaaleq	sp, lr, sp, r5
   ffc04: 004ed5b9     	strheq	sp, [lr], #-89
   ffc08: 004ed5df     	ldrdeq	sp, lr, [lr], #-95

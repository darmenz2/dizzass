
/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   8af50: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   8af54: e28db01c     	add	r11, sp, #28
   8af58: e24dd004     	sub	sp, sp, #4
   8af5c: ed2d8b0e     	vpush	{d8, d9, d10, d11, d12, d13, d14}
   8af60: e24ddfee     	sub	sp, sp, #952
   8af64: eb01cdbf     	bl	0xfe668 <.text+0xee568> @ imm = #0x736fc
   8af68: e58d0034     	str	r0, [sp, #0x34]
   8af6c: e3a01000     	mov	r1, #0
   8af70: e59f5fdc     	ldr	r5, [pc, #0xfdc]        @ 0x8bf54 <.text+0x7be54>
   8af74: e3a04000     	mov	r4, #0
   8af78: e59f6fd8     	ldr	r6, [pc, #0xfd8]        @ 0x8bf58 <.text+0x7be58>
   8af7c: e08f5005     	add	r5, pc, r5
   8af80: e79f6006     	ldr	r6, [pc, r6]
   8af84: e5960018     	ldr	r0, [r6, #0x18]
   8af88: e58d0044     	str	r0, [sp, #0x44]
   8af8c: e3020034     	movw	r0, #0x2034
   8af90: e7950000     	ldr	r0, [r5, r0]
   8af94: e58d0040     	str	r0, [sp, #0x40]
   8af98: e3a00001     	mov	r0, #1
   8af9c: eb146ee2     	bl	0x5a6b2c <.text+0x596a2c> @ imm = #0x51bb88
   8afa0: e59f1fb4     	ldr	r1, [pc, #0xfb4]        @ 0x8bf5c <.text+0x7be5c>
   8afa4: e3a0000f     	mov	r0, #15
   8afa8: e3a02000     	mov	r2, #0
   8afac: e3a03000     	mov	r3, #0
   8afb0: e08f1001     	add	r1, pc, r1
   8afb4: e58d4000     	str	r4, [sp]
   8afb8: eb1422ce     	bl	0x593af8 <.text+0x5839f8> @ imm = #0x508b38
   8afbc: e5950004     	ldr	r0, [r5, #0x4]
   8afc0: e3a03003     	mov	r3, #3
   8afc4: e5901004     	ldr	r1, [r0, #0x4]
   8afc8: e59f2ff8     	ldr	r2, [pc, #0xff8]        @ 0x8bfc8 <.text+0x7bec8>
   8afcc: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x8bfcc <.text+0x7becc>
   8afd0: e08f2002     	add	r2, pc, r2
   8afd4: e58d3000     	str	r3, [sp]
   8afd8: e58d2004     	str	r2, [sp, #0x4]
   8afdc: e08f0000     	add	r0, pc, r0
   8afe0: e58d1008     	str	r1, [sp, #0x8]
   8afe4: e301355e     	movw	r3, #0x155e
   8afe8: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x8bfd0 <.text+0x7bed0>
   8afec: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x8bfd4 <.text+0x7bed4>
   8aff0: e08f1001     	add	r1, pc, r1
   8aff4: e08f2002     	add	r2, pc, r2
   8aff8: eb01bc31     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6f0c4
   8affc: e24baf56     	sub	r10, r11, #344
   8b000: e1a00006     	mov	r0, r6
   8b004: e5955004     	ldr	r5, [r5, #0x4]
   8b008: e1a0100a     	mov	r1, r10
   8b00c: e50b4148     	str	r4, [r11, #-0x148]
   8b010: e50b414c     	str	r4, [r11, #-0x14c]
   8b014: e50b4150     	str	r4, [r11, #-0x150]
   8b018: e50b4154     	str	r4, [r11, #-0x154]
   8b01c: e50b4158     	str	r4, [r11, #-0x158]
   8b020: ebffdc85     	bl	0x8223c <.text+0x7213c> @ imm = #-0x8dec
   8b024: e595000c     	ldr	r0, [r5, #0xc]
   8b028: e5951010     	ldr	r1, [r5, #0x10]
   8b02c: e50b1154     	str	r1, [r11, #-0x154]
   8b030: e1a0100a     	mov	r1, r10
   8b034: e50b0150     	str	r0, [r11, #-0x150]
   8b038: e1a00006     	mov	r0, r6
   8b03c: e50b4158     	str	r4, [r11, #-0x158]
   8b040: ebffe423     	bl	0x840d4 <.text+0x73fd4> @ imm = #-0x6f74
   8b044: e51b014c     	ldr	r0, [r11, #-0x14c]
   8b048: e58d00c4     	str	r0, [sp, #0xc4]
   8b04c: e3500000     	cmp	r0, #0
   8b050: e58d60c0     	str	r6, [sp, #0xc0]
   8b054: 0a000026     	beq	0x8b0f4 <.text+0x7aff4> @ imm = #0x98
   8b058: e51b4148     	ldr	r4, [r11, #-0x148]
   8b05c: e3540001     	cmp	r4, #1
   8b060: ba00001e     	blt	0x8b0e0 <.text+0x7afe0> @ imm = #0x78
   8b064: e59d00c4     	ldr	r0, [sp, #0xc4]
   8b068: e3a09000     	mov	r9, #0
   8b06c: e59f6f64     	ldr	r6, [pc, #0xf64]        @ 0x8bfd8 <.text+0x7bed8>
   8b070: e3a08000     	mov	r8, #0
   8b074: e2805008     	add	r5, r0, #8
   8b078: e79f6006     	ldr	r6, [pc, r6]
   8b07c: e59f7f58     	ldr	r7, [pc, #0xf58]        @ 0x8bfdc <.text+0x7bedc>
   8b080: e79f7007     	ldr	r7, [pc, r7]
   8b084: ea000003     	b	0x8b098 <.text+0x7af98> @ imm = #0xc
   8b088: e2888001     	add	r8, r8, #1
   8b08c: e285500c     	add	r5, r5, #12
   8b090: e2544001     	subs	r4, r4, #1
   8b094: 0a000011     	beq	0x8b0e0 <.text+0x7afe0> @ imm = #0x44
   8b098: e5950000     	ldr	r0, [r5]
   8b09c: e3500000     	cmp	r0, #0
   8b0a0: 0a000001     	beq	0x8b0ac <.text+0x7afac> @ imm = #0x4
   8b0a4: eb1422f8     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x508be0
   8b0a8: e5859000     	str	r9, [r5]
   8b0ac: e5960000     	ldr	r0, [r6]
   8b0b0: e2401001     	sub	r1, r0, #1
   8b0b4: e0000190     	mul	r0, r0, r1
   8b0b8: e3100001     	tst	r0, #1
   8b0bc: e5960000     	ldr	r0, [r6]
   8b0c0: e2401001     	sub	r1, r0, #1
   8b0c4: e0000190     	mul	r0, r0, r1
   8b0c8: e3100001     	tst	r0, #1
   8b0cc: 0affffed     	beq	0x8b088 <.text+0x7af88> @ imm = #-0x4c
   8b0d0: e5970000     	ldr	r0, [r7]
   8b0d4: e3500009     	cmp	r0, #9
   8b0d8: cafffff7     	bgt	0x8b0bc <.text+0x7afbc> @ imm = #-0x24
   8b0dc: eaffffe9     	b	0x8b088 <.text+0x7af88> @ imm = #-0x5c
   8b0e0: e59d00c4     	ldr	r0, [sp, #0xc4]
   8b0e4: eb1422e8     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x508ba0
   8b0e8: e59d60c0     	ldr	r6, [sp, #0xc0]
   8b0ec: e3a00000     	mov	r0, #0
   8b0f0: e50b014c     	str	r0, [r11, #-0x14c]
   8b0f4: e59f4ee4     	ldr	r4, [pc, #0xee4]        @ 0x8bfe0 <.text+0x7bee0>
   8b0f8: e79f4004     	ldr	r4, [pc, r4]
   8b0fc: e5940000     	ldr	r0, [r4]
   8b100: e59f9edc     	ldr	r9, [pc, #0xedc]        @ 0x8bfe4 <.text+0x7bee4>
   8b104: e2401001     	sub	r1, r0, #1
   8b108: e0000190     	mul	r0, r0, r1
   8b10c: e79f9009     	ldr	r9, [pc, r9]
   8b110: e3100001     	tst	r0, #1
   8b114: 0a000002     	beq	0x8b124 <.text+0x7b024> @ imm = #0x8
   8b118: e5990000     	ldr	r0, [r9]
   8b11c: e3500009     	cmp	r0, #9
   8b120: ca000011     	bgt	0x8b16c <.text+0x7b06c> @ imm = #0x44
   8b124: e5960018     	ldr	r0, [r6, #0x18]
   8b128: eb007037     	bl	0xa720c <.text+0x9710c> @ imm = #0x1c0dc
   8b12c: e1a08000     	mov	r8, r0
   8b130: eb01cd4c     	bl	0xfe668 <.text+0xee568> @ imm = #0x73530
   8b134: e59f1eac     	ldr	r1, [pc, #0xeac]        @ 0x8bfe8 <.text+0x7bee8>
   8b138: e08f1001     	add	r1, pc, r1
   8b13c: e5912008     	ldr	r2, [r1, #0x8]
   8b140: e591100c     	ldr	r1, [r1, #0xc]
   8b144: e58620dc     	str	r2, [r6, #0xdc]
   8b148: e58610cc     	str	r1, [r6, #0xcc]
   8b14c: e5942000     	ldr	r2, [r4]
   8b150: e2423001     	sub	r3, r2, #1
   8b154: e0020392     	mul	r2, r2, r3
   8b158: e3120001     	tst	r2, #1
   8b15c: 0a00000b     	beq	0x8b190 <.text+0x7b090> @ imm = #0x2c
   8b160: e5992000     	ldr	r2, [r9]
   8b164: e3520009     	cmp	r2, #9
   8b168: da000008     	ble	0x8b190 <.text+0x7b090> @ imm = #0x20
   8b16c: e5960018     	ldr	r0, [r6, #0x18]
   8b170: eb007025     	bl	0xa720c <.text+0x9710c> @ imm = #0x1c094
   8b174: eb01cd3b     	bl	0xfe668 <.text+0xee568> @ imm = #0x734ec
   8b178: e59f0e6c     	ldr	r0, [pc, #0xe6c]        @ 0x8bfec <.text+0x7beec>
   8b17c: e08f0000     	add	r0, pc, r0
   8b180: e1c000d8     	ldrd	r0, r1, [r0, #8]
   8b184: e58600dc     	str	r0, [r6, #0xdc]
   8b188: e58610cc     	str	r1, [r6, #0xcc]
   8b18c: eaffffe4     	b	0x8b124 <.text+0x7b024> @ imm = #-0x70
   8b190: e59fce58     	ldr	r12, [pc, #0xe58]       @ 0x8bff0 <.text+0x7bef0>
   8b194: e3500001     	cmp	r0, #1
   8b198: e08fc00c     	add	r12, pc, r12
   8b19c: ba000028     	blt	0x8b244 <.text+0x7b144> @ imm = #0xa0
   8b1a0: e5942000     	ldr	r2, [r4]
   8b1a4: e2423001     	sub	r3, r2, #1
   8b1a8: e0020392     	mul	r2, r2, r3
   8b1ac: e3120001     	tst	r2, #1
   8b1b0: e5942000     	ldr	r2, [r4]
   8b1b4: e2423001     	sub	r3, r2, #1
   8b1b8: e0020392     	mul	r2, r2, r3
   8b1bc: e3120001     	tst	r2, #1
   8b1c0: 0a000002     	beq	0x8b1d0 <.text+0x7b0d0> @ imm = #0x8
   8b1c4: e5992000     	ldr	r2, [r9]
   8b1c8: e3520009     	cmp	r2, #9
   8b1cc: cafffff7     	bgt	0x8b1b0 <.text+0x7b0b0> @ imm = #-0x24
   8b1d0: e3a02000     	mov	r2, #0
   8b1d4: e5963100     	ldr	r3, [r6, #0x100]
   8b1d8: e0827082     	add	r7, r2, r2, lsl #1
   8b1dc: e7831107     	str	r1, [r3, r7, lsl #2]
   8b1e0: e5981010     	ldr	r1, [r8, #0x10]
   8b1e4: e3510001     	cmp	r1, #1
   8b1e8: ba00000f     	blt	0x8b22c <.text+0x7b12c> @ imm = #0x3c
   8b1ec: e0831107     	add	r1, r3, r7, lsl #2
   8b1f0: e3a03000     	mov	r3, #0
   8b1f4: e2811008     	add	r1, r1, #8
   8b1f8: e3a07000     	mov	r7, #0
   8b1fc: e59c5020     	ldr	r5, [r12, #0x20]
   8b200: e0826102     	add	r6, r2, r2, lsl #2
   8b204: e0856186     	add	r6, r5, r6, lsl #3
   8b208: e5915000     	ldr	r5, [r1]
   8b20c: e5966020     	ldr	r6, [r6, #0x20]
   8b210: e7966003     	ldr	r6, [r6, r3]
   8b214: e2833038     	add	r3, r3, #56
   8b218: e7856107     	str	r6, [r5, r7, lsl #2]
   8b21c: e2877001     	add	r7, r7, #1
   8b220: e5986010     	ldr	r6, [r8, #0x10]
   8b224: e1570006     	cmp	r7, r6
   8b228: bafffff3     	blt	0x8b1fc <.text+0x7b0fc> @ imm = #-0x34
   8b22c: e59d60c0     	ldr	r6, [sp, #0xc0]
   8b230: e2822001     	add	r2, r2, #1
   8b234: e1520000     	cmp	r2, r0
   8b238: 0a000001     	beq	0x8b244 <.text+0x7b144> @ imm = #0x4
   8b23c: e59c100c     	ldr	r1, [r12, #0xc]
   8b240: eaffffe3     	b	0x8b1d4 <.text+0x7b0d4> @ imm = #-0x74
   8b244: e5941000     	ldr	r1, [r4]
   8b248: e3000fe8     	movw	r0, #0xfe8
   8b24c: e59f8fb4     	ldr	r8, [pc, #0xfb4]        @ 0x8c208 <.text+0x7c108>
   8b250: e2412001     	sub	r2, r1, #1
   8b254: e59d3044     	ldr	r3, [sp, #0x44]
   8b258: e59d7040     	ldr	r7, [sp, #0x40]
   8b25c: e08f8008     	add	r8, pc, r8
   8b260: e0010291     	mul	r1, r1, r2
   8b264: e3110001     	tst	r1, #1
   8b268: 0a000002     	beq	0x8b278 <.text+0x7b178> @ imm = #0x8
   8b26c: e5991000     	ldr	r1, [r9]
   8b270: e3510009     	cmp	r1, #9
   8b274: ca000043     	bgt	0x8b388 <.text+0x7b288> @ imm = #0x10c
   8b278: e0861000     	add	r1, r6, r0
   8b27c: e58d10c4     	str	r1, [sp, #0xc4]
   8b280: e2861050     	add	r1, r6, #80
   8b284: e58d10bc     	str	r1, [sp, #0xbc]
   8b288: e3a010c8     	mov	r1, #200
   8b28c: e3a02001     	mov	r2, #1
   8b290: e0213197     	mla	r1, r7, r1, r3
   8b294: e5c82000     	strb	r2, [r8]
   8b298: e2812f52     	add	r2, r1, #328
   8b29c: e58d207c     	str	r2, [sp, #0x7c]
   8b2a0: e2812f55     	add	r2, r1, #340
   8b2a4: e58d2078     	str	r2, [sp, #0x78]
   8b2a8: e2812e15     	add	r2, r1, #336
   8b2ac: e58d208c     	str	r2, [sp, #0x8c]
   8b2b0: e2812f56     	add	r2, r1, #344
   8b2b4: e58d2060     	str	r2, [sp, #0x60]
   8b2b8: e2812f4e     	add	r2, r1, #312
   8b2bc: e58d20b0     	str	r2, [sp, #0xb0]
   8b2c0: e2812f66     	add	r2, r1, #408
   8b2c4: e58d205c     	str	r2, [sp, #0x5c]
   8b2c8: e2812f61     	add	r2, r1, #388
   8b2cc: e58d2058     	str	r2, [sp, #0x58]
   8b2d0: e2812f62     	add	r2, r1, #392
   8b2d4: e58d2068     	str	r2, [sp, #0x68]
   8b2d8: e2812d06     	add	r2, r1, #384
   8b2dc: e58d2098     	str	r2, [sp, #0x98]
   8b2e0: e2812e19     	add	r2, r1, #400
   8b2e4: e58d2094     	str	r2, [sp, #0x94]
   8b2e8: e2812e1a     	add	r2, r1, #416
   8b2ec: e58d20a0     	str	r2, [sp, #0xa0]
   8b2f0: e2812f51     	add	r2, r1, #324
   8b2f4: e58d20a8     	str	r2, [sp, #0xa8]
   8b2f8: e2812f76     	add	r2, r1, #472
   8b2fc: e58d2084     	str	r2, [sp, #0x84]
   8b300: e2812e1e     	add	r2, r1, #480
   8b304: e58d2088     	str	r2, [sp, #0x88]
   8b308: e2812e1d     	add	r2, r1, #464
   8b30c: e58d2080     	str	r2, [sp, #0x80]
   8b310: e2812f72     	add	r2, r1, #456
   8b314: e58d2074     	str	r2, [sp, #0x74]
   8b318: e2812d07     	add	r2, r1, #448
   8b31c: e58d2090     	str	r2, [sp, #0x90]
   8b320: e2812f7b     	add	r2, r1, #492
   8b324: e58d206c     	str	r2, [sp, #0x6c]
   8b328: e2812f7a     	add	r2, r1, #488
   8b32c: e58d2064     	str	r2, [sp, #0x64]
   8b330: e2812e1f     	add	r2, r1, #496
   8b334: e58d2070     	str	r2, [sp, #0x70]
   8b338: e2812f4f     	add	r2, r1, #316
   8b33c: e2811f4d     	add	r1, r1, #308
   8b340: e58d10b4     	str	r1, [sp, #0xb4]
   8b344: e5941000     	ldr	r1, [r4]
   8b348: e58d20ac     	str	r2, [sp, #0xac]
   8b34c: e2412001     	sub	r2, r1, #1
   8b350: e0010291     	mul	r1, r1, r2
   8b354: e30120b4     	movw	r2, #0x10b4
   8b358: e0862002     	add	r2, r6, r2
   8b35c: e58d20b8     	str	r2, [sp, #0xb8]
   8b360: e28a205c     	add	r2, r10, #92
   8b364: e58d20a4     	str	r2, [sp, #0xa4]
   8b368: e28d2f5e     	add	r2, sp, #376
   8b36c: e282205c     	add	r2, r2, #92
   8b370: e58d209c     	str	r2, [sp, #0x9c]
   8b374: e3110001     	tst	r1, #1
   8b378: 0a000016     	beq	0x8b3d8 <.text+0x7b2d8> @ imm = #0x58
   8b37c: e5991000     	ldr	r1, [r9]
   8b380: e3510009     	cmp	r1, #9
   8b384: da000013     	ble	0x8b3d8 <.text+0x7b2d8> @ imm = #0x4c
   8b388: e3a01001     	mov	r1, #1
   8b38c: e5c81000     	strb	r1, [r8]
   8b390: eaffffb8     	b	0x8b278 <.text+0x7b178> @ imm = #-0x120
   8b394: e3550000     	cmp	r5, #0
   8b398: 0a000017     	beq	0x8b3fc <.text+0x7b2fc> @ imm = #0x5c
   8b39c: e3a00ffa     	mov	r0, #1000
   8b3a0: eb020ee5     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x83b94
   8b3a4: e59f6fc4     	ldr	r6, [pc, #0xfc4]        @ 0x8c370 <.text+0x7c270>
   8b3a8: e08f6006     	add	r6, pc, r6
   8b3ac: e1a00006     	mov	r0, r6
   8b3b0: eb146b54     	bl	0x5a6108 <.text+0x596008> @ imm = #0x51ad50
   8b3b4: e59f0fb8     	ldr	r0, [pc, #0xfb8]        @ 0x8c374 <.text+0x7c274>
   8b3b8: e3a01001     	mov	r1, #1
   8b3bc: e08f0000     	add	r0, pc, r0
   8b3c0: e5c01000     	strb	r1, [r0]
   8b3c4: e1a00006     	mov	r0, r6
   8b3c8: eb146cbd     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51b2f4
   8b3cc: e5d80000     	ldrb	r0, [r8]
   8b3d0: e3500000     	cmp	r0, #0
   8b3d4: 0a0021bd     	beq	0x93ad0 <.text+0x839d0> @ imm = #0x86f4
   8b3d8: e5940000     	ldr	r0, [r4]
   8b3dc: e2401001     	sub	r1, r0, #1
   8b3e0: e0000190     	mul	r0, r0, r1
   8b3e4: e3100001     	tst	r0, #1
   8b3e8: 0a000037     	beq	0x8b4cc <.text+0x7b3cc> @ imm = #0xdc
   8b3ec: e5990000     	ldr	r0, [r9]
   8b3f0: e3500009     	cmp	r0, #9
   8b3f4: ca000045     	bgt	0x8b510 <.text+0x7b410> @ imm = #0x114
   8b3f8: ea000033     	b	0x8b4cc <.text+0x7b3cc> @ imm = #0xcc
   8b3fc: e59f6fe0     	ldr	r6, [pc, #0xfe0]        @ 0x8c3e4 <.text+0x7c2e4>
   8b400: e08f6006     	add	r6, pc, r6
   8b404: e1a00006     	mov	r0, r6
   8b408: eb146b3e     	bl	0x5a6108 <.text+0x596008> @ imm = #0x51acf8
   8b40c: e59f5ff8     	ldr	r5, [pc, #0xff8]        @ 0x8c40c <.text+0x7c30c>
   8b410: e1a00006     	mov	r0, r6
   8b414: e08f5005     	add	r5, pc, r5
   8b418: e5d57000     	ldrb	r7, [r5]
   8b41c: eb146ca8     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51b2a0
   8b420: e3570001     	cmp	r7, #1
   8b424: 1a000007     	bne	0x8b448 <.text+0x7b348> @ imm = #0x1c
   8b428: e59f6fe0     	ldr	r6, [pc, #0xfe0]        @ 0x8c410 <.text+0x7c310>
   8b42c: e08f6006     	add	r6, pc, r6
   8b430: e1a00006     	mov	r0, r6
   8b434: eb146b33     	bl	0x5a6108 <.text+0x596008> @ imm = #0x51accc
   8b438: e3a00000     	mov	r0, #0
   8b43c: e5c50000     	strb	r0, [r5]
   8b440: e1a00006     	mov	r0, r6
   8b444: eb146c9e     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51b278
   8b448: e59d50c0     	ldr	r5, [sp, #0xc0]
   8b44c: e5d50024     	ldrb	r0, [r5, #0x24]
   8b450: e3500000     	cmp	r0, #0
   8b454: 0a0000a4     	beq	0x8b6ec <.text+0x7b5ec> @ imm = #0x290
   8b458: e5940000     	ldr	r0, [r4]
   8b45c: e2401001     	sub	r1, r0, #1
   8b460: e0000190     	mul	r0, r0, r1
   8b464: e3100001     	tst	r0, #1
   8b468: e5940000     	ldr	r0, [r4]
   8b46c: e2401001     	sub	r1, r0, #1
   8b470: e0010190     	mul	r1, r0, r1
   8b474: e5d50fe5     	ldrb	r0, [r5, #0xfe5]
   8b478: e3110001     	tst	r1, #1
   8b47c: 0a000002     	beq	0x8b48c <.text+0x7b38c> @ imm = #0x8
   8b480: e5991000     	ldr	r1, [r9]
   8b484: e3510009     	cmp	r1, #9
   8b488: cafffff6     	bgt	0x8b468 <.text+0x7b368> @ imm = #-0x28
   8b48c: e3500000     	cmp	r0, #0
   8b490: 0a000095     	beq	0x8b6ec <.text+0x7b5ec> @ imm = #0x254
   8b494: ed9f8bf5     	vldr	d8, [pc, #980]          @ 0x8b870 <.text+0x7b770>
   8b498: ed950b0a     	vldr	d0, [r5, #40]
   8b49c: eeb40bc8     	vcmpe.f64	d0, d8
   8b4a0: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8b4a4: da000031     	ble	0x8b570 <.text+0x7b470> @ imm = #0xc4
   8b4a8: e5940000     	ldr	r0, [r4]
   8b4ac: e2401001     	sub	r1, r0, #1
   8b4b0: e0000190     	mul	r0, r0, r1
   8b4b4: e3100001     	tst	r0, #1
   8b4b8: 0a00001b     	beq	0x8b52c <.text+0x7b42c> @ imm = #0x6c
   8b4bc: e5990000     	ldr	r0, [r9]
   8b4c0: e3500009     	cmp	r0, #9
   8b4c4: ca000023     	bgt	0x8b558 <.text+0x7b458> @ imm = #0x8c
   8b4c8: ea000017     	b	0x8b52c <.text+0x7b42c> @ imm = #0x5c
   8b4cc: e59f6fa4     	ldr	r6, [pc, #0xfa4]        @ 0x8c478 <.text+0x7c378>
   8b4d0: e08f6006     	add	r6, pc, r6
   8b4d4: e1a00006     	mov	r0, r6
   8b4d8: eb146b0a     	bl	0x5a6108 <.text+0x596008> @ imm = #0x51ac28
   8b4dc: e59f0ff4     	ldr	r0, [pc, #0xff4]        @ 0x8c4d8 <.text+0x7c3d8>
   8b4e0: e08f0000     	add	r0, pc, r0
   8b4e4: e5d05000     	ldrb	r5, [r0]
   8b4e8: e1a00006     	mov	r0, r6
   8b4ec: eb146c74     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51b1d0
   8b4f0: e5940000     	ldr	r0, [r4]
   8b4f4: e2401001     	sub	r1, r0, #1
   8b4f8: e0000190     	mul	r0, r0, r1
   8b4fc: e3100001     	tst	r0, #1
   8b500: 0affffa3     	beq	0x8b394 <.text+0x7b294> @ imm = #-0x174
   8b504: e5990000     	ldr	r0, [r9]
   8b508: e3500009     	cmp	r0, #9
   8b50c: daffffa0     	ble	0x8b394 <.text+0x7b294> @ imm = #-0x180
   8b510: e59f6fc4     	ldr	r6, [pc, #0xfc4]        @ 0x8c4dc <.text+0x7c3dc>
   8b514: e08f6006     	add	r6, pc, r6
   8b518: e1a00006     	mov	r0, r6
   8b51c: eb146af9     	bl	0x5a6108 <.text+0x596008> @ imm = #0x51abe4
   8b520: e1a00006     	mov	r0, r6
   8b524: eb146c66     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51b198
   8b528: eaffffe7     	b	0x8b4cc <.text+0x7b3cc> @ imm = #-0x64
   8b52c: ebfe4e09     	bl	0x1ed58 <.text+0xec58>  @ imm = #-0x6c7dc
   8b530: ed951b0a     	vldr	d1, [r5, #40]
   8b534: e5940000     	ldr	r0, [r4]
   8b538: ee300b41     	vsub.f64	d0, d0, d1
   8b53c: e2401001     	sub	r1, r0, #1
   8b540: e0000190     	mul	r0, r0, r1
   8b544: e3100001     	tst	r0, #1
   8b548: 0a000004     	beq	0x8b560 <.text+0x7b460> @ imm = #0x10
   8b54c: e5990000     	ldr	r0, [r9]
   8b550: e3500009     	cmp	r0, #9
   8b554: da000001     	ble	0x8b560 <.text+0x7b460> @ imm = #0x4
   8b558: ebfe4dfe     	bl	0x1ed58 <.text+0xec58>  @ imm = #-0x6c808
   8b55c: eafffff2     	b	0x8b52c <.text+0x7b42c> @ imm = #-0x38
   8b560: ed9f1bc4     	vldr	d1, [pc, #784]          @ 0x8b878 <.text+0x7b778>
   8b564: eeb40bc1     	vcmpe.f64	d0, d1
   8b568: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8b56c: 4a00005e     	bmi	0x8b6ec <.text+0x7b5ec> @ imm = #0x178
   8b570: e5d50fe6     	ldrb	r0, [r5, #0xfe6]
   8b574: e3500000     	cmp	r0, #0
   8b578: 0a00005b     	beq	0x8b6ec <.text+0x7b5ec> @ imm = #0x16c
   8b57c: e5940000     	ldr	r0, [r4]
   8b580: e2401001     	sub	r1, r0, #1
   8b584: e0000190     	mul	r0, r0, r1
   8b588: e3100001     	tst	r0, #1
   8b58c: e5940000     	ldr	r0, [r4]
   8b590: e2401001     	sub	r1, r0, #1
   8b594: e0000190     	mul	r0, r0, r1
   8b598: e59d10c4     	ldr	r1, [sp, #0xc4]
   8b59c: ed910b00     	vldr	d0, [r1]
   8b5a0: e3100001     	tst	r0, #1
   8b5a4: 0a000002     	beq	0x8b5b4 <.text+0x7b4b4> @ imm = #0x8
   8b5a8: e5990000     	ldr	r0, [r9]
   8b5ac: e3500009     	cmp	r0, #9
   8b5b0: cafffff5     	bgt	0x8b58c <.text+0x7b48c> @ imm = #-0x2c
   8b5b4: eeb40bc8     	vcmpe.f64	d0, d8
   8b5b8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8b5bc: da000007     	ble	0x8b5e0 <.text+0x7b4e0> @ imm = #0x1c
   8b5c0: ebfe4de4     	bl	0x1ed58 <.text+0xec58>  @ imm = #-0x6c870
   8b5c4: e59d00c4     	ldr	r0, [sp, #0xc4]
   8b5c8: ed901b00     	vldr	d1, [r0]
   8b5cc: ee300b41     	vsub.f64	d0, d0, d1
   8b5d0: ed9f1baa     	vldr	d1, [pc, #680]          @ 0x8b880 <.text+0x7b780>
   8b5d4: eeb40bc1     	vcmpe.f64	d0, d1
   8b5d8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8b5dc: 4a000042     	bmi	0x8b6ec <.text+0x7b5ec> @ imm = #0x108
   8b5e0: e5950050     	ldr	r0, [r5, #0x50]
   8b5e4: e3500000     	cmp	r0, #0
   8b5e8: 1a000048     	bne	0x8b710 <.text+0x7b610> @ imm = #0x120
   8b5ec: ebfe4dd9     	bl	0x1ed58 <.text+0xec58>  @ imm = #-0x6c89c
   8b5f0: ed951b0a     	vldr	d1, [r5, #40]
   8b5f4: ee300b41     	vsub.f64	d0, d0, d1
   8b5f8: ed9f1ba2     	vldr	d1, [pc, #648]          @ 0x8b888 <.text+0x7b788>
   8b5fc: eeb40bc1     	vcmpe.f64	d0, d1
   8b600: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8b604: 5a000041     	bpl	0x8b710 <.text+0x7b610> @ imm = #0x104
   8b608: e5940000     	ldr	r0, [r4]
   8b60c: e2401001     	sub	r1, r0, #1
   8b610: e0000190     	mul	r0, r0, r1
   8b614: e3100001     	tst	r0, #1
   8b618: 0a000002     	beq	0x8b628 <.text+0x7b528> @ imm = #0x8
   8b61c: e5990000     	ldr	r0, [r9]
   8b620: e3500009     	cmp	r0, #9
   8b624: ca00000a     	bgt	0x8b654 <.text+0x7b554> @ imm = #0x28
   8b628: e24b1f56     	sub	r1, r11, #344
   8b62c: e1a00005     	mov	r0, r5
   8b630: ebff4947     	bl	0x5db54 <.text+0x4da54> @ imm = #-0x2dae4
   8b634: e5941000     	ldr	r1, [r4]
   8b638: e2412001     	sub	r2, r1, #1
   8b63c: e0010291     	mul	r1, r1, r2
   8b640: e3110001     	tst	r1, #1
   8b644: 0a000006     	beq	0x8b664 <.text+0x7b564> @ imm = #0x18
   8b648: e5991000     	ldr	r1, [r9]
   8b64c: e3510009     	cmp	r1, #9
   8b650: da000003     	ble	0x8b664 <.text+0x7b564> @ imm = #0xc
   8b654: e24b1f56     	sub	r1, r11, #344
   8b658: e1a00005     	mov	r0, r5
   8b65c: ebff493c     	bl	0x5db54 <.text+0x4da54> @ imm = #-0x2db10
   8b660: eafffff0     	b	0x8b628 <.text+0x7b528> @ imm = #-0x40
   8b664: e3500000     	cmp	r0, #0
   8b668: 0a00000d     	beq	0x8b6a4 <.text+0x7b5a4> @ imm = #0x34
   8b66c: e59f0ff4     	ldr	r0, [pc, #0xff4]        @ 0x8c668 <.text+0x7c568>
   8b670: e3a07002     	mov	r7, #2
   8b674: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0x8c66c <.text+0x7c56c>
   8b678: e59f2ff0     	ldr	r2, [pc, #0xff0]        @ 0x8c670 <.text+0x7c570>
   8b67c: e08f0000     	add	r0, pc, r0
   8b680: e59f3fec     	ldr	r3, [pc, #0xfec]        @ 0x8c674 <.text+0x7c574>
   8b684: e08f1001     	add	r1, pc, r1
   8b688: e08f2002     	add	r2, pc, r2
   8b68c: e58d7000     	str	r7, [sp]
   8b690: e08f3003     	add	r3, pc, r3
   8b694: e58d3004     	str	r3, [sp, #0x4]
   8b698: e3003e45     	movw	r3, #0xe45
   8b69c: eb01ba88     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ea20
   8b6a0: ea000011     	b	0x8b6ec <.text+0x7b5ec> @ imm = #0x44
   8b6a4: e5940000     	ldr	r0, [r4]
   8b6a8: e2401001     	sub	r1, r0, #1
   8b6ac: e0000190     	mul	r0, r0, r1
   8b6b0: e3100001     	tst	r0, #1
   8b6b4: e5940000     	ldr	r0, [r4]
   8b6b8: e51b3158     	ldr	r3, [r11, #-0x158]
   8b6bc: e2401001     	sub	r1, r0, #1
   8b6c0: e5957058     	ldr	r7, [r5, #0x58]
   8b6c4: e0020190     	mul	r2, r0, r1
   8b6c8: e0570003     	subs	r0, r7, r3
   8b6cc: e5991000     	ldr	r1, [r9]
   8b6d0: 42600000     	rsbmi	r0, r0, #0
   8b6d4: e3120001     	tst	r2, #1
   8b6d8: 0a000001     	beq	0x8b6e4 <.text+0x7b5e4> @ imm = #0x4
   8b6dc: e3510009     	cmp	r1, #9
   8b6e0: cafffff3     	bgt	0x8b6b4 <.text+0x7b5b4> @ imm = #-0x34
   8b6e4: e3500003     	cmp	r0, #3
   8b6e8: ba000008     	blt	0x8b710 <.text+0x7b610> @ imm = #0x20
   8b6ec: e5940000     	ldr	r0, [r4]
   8b6f0: e2401001     	sub	r1, r0, #1
   8b6f4: e0000190     	mul	r0, r0, r1
   8b6f8: e3100001     	tst	r0, #1
   8b6fc: 0a0004fb     	beq	0x8caf0 <.text+0x7c9f0> @ imm = #0x13ec
   8b700: e5990000     	ldr	r0, [r9]
   8b704: e3500009     	cmp	r0, #9
   8b708: ca000502     	bgt	0x8cb18 <.text+0x7ca18> @ imm = #0x1408
   8b70c: ea0004f7     	b	0x8caf0 <.text+0x7c9f0> @ imm = #0x13dc
   8b710: e5940000     	ldr	r0, [r4]
   8b714: e59f6fd4     	ldr	r6, [pc, #0xfd4]        @ 0x8c6f0 <.text+0x7c5f0>
   8b718: e2401001     	sub	r1, r0, #1
   8b71c: e08f6006     	add	r6, pc, r6
   8b720: e0000190     	mul	r0, r0, r1
   8b724: e3100001     	tst	r0, #1
   8b728: e5940000     	ldr	r0, [r4]
   8b72c: e2401001     	sub	r1, r0, #1
   8b730: e0010190     	mul	r1, r0, r1
   8b734: e3020030     	movw	r0, #0x2030
   8b738: e7960000     	ldr	r0, [r6, r0]
   8b73c: e3110001     	tst	r1, #1
   8b740: 0a000002     	beq	0x8b750 <.text+0x7b650> @ imm = #0x8
   8b744: e5991000     	ldr	r1, [r9]
   8b748: e3510009     	cmp	r1, #9
   8b74c: cafffff5     	bgt	0x8b728 <.text+0x7b628> @ imm = #-0x2c
   8b750: e3500008     	cmp	r0, #8
   8b754: 8a0020d7     	bhi	0x93ab8 <.text+0x839b8> @ imm = #0x835c
   8b758: e28f1004     	add	r1, pc, #4
   8b75c: e7910100     	ldr	r0, [r1, r0, lsl #2]
   8b760: e081f000     	add	pc, r1, r0
   8b764: 00000024     	andeq	r0, r0, r4, lsr #32
   8b768: 0000007c     	andeq	r0, r0, r12, ror r0
   8b76c: 000000a0     	andeq	r0, r0, r0, lsr #1
   8b770: 00000134     	andeq	r0, r0, r4, lsr r1
   8b774: 00000230     	andeq	r0, r0, r0, lsr r2
   8b778: 000002c0     	andeq	r0, r0, r0, asr #5
   8b77c: 000003b4     	strheq	r0, [r0], -r4
   8b780: 0000044c     	andeq	r0, r0, r12, asr #8
   8b784: 000006dc     	ldrdeq	r0, r1, [r0], -r12
   8b788: e5940000     	ldr	r0, [r4]
   8b78c: e3a02000     	mov	r2, #0
   8b790: e59d30b4     	ldr	r3, [sp, #0xb4]
   8b794: e2401001     	sub	r1, r0, #1
   8b798: e0000190     	mul	r0, r0, r1
   8b79c: e5991000     	ldr	r1, [r9]
   8b7a0: e5d33000     	ldrb	r3, [r3]
   8b7a4: e351000a     	cmp	r1, #10
   8b7a8: e3a01001     	mov	r1, #1
   8b7ac: b3002001     	movwlt	r2, #0x1
   8b7b0: e3530000     	cmp	r3, #0
   8b7b4: e1c10000     	bic	r0, r1, r0
   8b7b8: e59f1fc8     	ldr	r1, [pc, #0xfc8]        @ 0x8c788 <.text+0x7c688>
   8b7bc: e1800002     	orr	r0, r0, r2
   8b7c0: e79f1001     	ldr	r1, [pc, r1]
   8b7c4: e58d104c     	str	r1, [sp, #0x4c]
   8b7c8: 0a0001d1     	beq	0x8bf14 <.text+0x7be14> @ imm = #0x744
   8b7cc: e59f8fb8     	ldr	r8, [pc, #0xfb8]        @ 0x8c78c <.text+0x7c68c>
   8b7d0: e3500000     	cmp	r0, #0
   8b7d4: e08f8008     	add	r8, pc, r8
   8b7d8: 0a0004de     	beq	0x8cb58 <.text+0x7ca58> @ imm = #0x1378
   8b7dc: ea0004d0     	b	0x8cb24 <.text+0x7ca24> @ imm = #0x1340
   8b7e0: e5940000     	ldr	r0, [r4]
   8b7e4: e2401001     	sub	r1, r0, #1
   8b7e8: e0000190     	mul	r0, r0, r1
   8b7ec: e3100001     	tst	r0, #1
   8b7f0: 0a000767     	beq	0x8d594 <.text+0x7d494> @ imm = #0x1d9c
   8b7f4: e5990000     	ldr	r0, [r9]
   8b7f8: e3500009     	cmp	r0, #9
   8b7fc: ca000770     	bgt	0x8d5c4 <.text+0x7d4c4> @ imm = #0x1dc0
   8b800: ea000763     	b	0x8d594 <.text+0x7d494> @ imm = #0x1d8c
   8b804: e5940000     	ldr	r0, [r4]
   8b808: e2401001     	sub	r1, r0, #1
   8b80c: e0000190     	mul	r0, r0, r1
   8b810: e3100001     	tst	r0, #1
   8b814: e5940000     	ldr	r0, [r4]
   8b818: e59d20b0     	ldr	r2, [sp, #0xb0]
   8b81c: e2401001     	sub	r1, r0, #1
   8b820: e0010190     	mul	r1, r0, r1
   8b824: e59d00c4     	ldr	r0, [sp, #0xc4]
   8b828: e5928000     	ldr	r8, [r2]
   8b82c: e5d00061     	ldrb	r0, [r0, #0x61]
   8b830: e3110001     	tst	r1, #1
   8b834: 0a000002     	beq	0x8b844 <.text+0x7b744> @ imm = #0x8
   8b838: e5991000     	ldr	r1, [r9]
   8b83c: e3510009     	cmp	r1, #9
   8b840: cafffff3     	bgt	0x8b814 <.text+0x7b714> @ imm = #-0x34
   8b844: e3500000     	cmp	r0, #0
   8b848: 1a00209a     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x8268
   8b84c: e59d50c0     	ldr	r5, [sp, #0xc0]
   8b850: e5967008     	ldr	r7, [r6, #0x8]
   8b854: e595001c     	ldr	r0, [r5, #0x1c]
   8b858: ebff553c     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x2ab10
   8b85c: e1570000     	cmp	r7, r0
   8b860: da00035b     	ble	0x8c5d4 <.text+0x7c4d4> @ imm = #0xd6c
   8b864: e5961008     	ldr	r1, [r6, #0x8]
   8b868: ea00035c     	b	0x8c5e0 <.text+0x7c4e0> @ imm = #0xd70
   8b86c: e320f000     	nop
   8b870: d2f1a9fc     	rscsle	r10, r1, #252, #18
   8b874: 3f50624d     	svclo	#0x50624d
   8b878: 00000000     	andeq	r0, r0, r0
   8b87c: 4072c000     	rsbsmi	r12, r2, r0
   8b880: 00000000     	andeq	r0, r0, r0
   8b884: 404e0000     	submi	r0, lr, r0
   8b888: 00000000     	andeq	r0, r0, r0
   8b88c: 40668000     	rsbmi	r8, r6, r0
   8b890: 00000000     	andeq	r0, r0, r0
   8b894: 40568000     	subsmi	r8, r6, r0
   8b898: e59d00b4     	ldr	r0, [sp, #0xb4]
   8b89c: e5d00000     	ldrb	r0, [r0]
   8b8a0: e3500000     	cmp	r0, #0
   8b8a4: 0a00019e     	beq	0x8bf24 <.text+0x7be24> @ imm = #0x678
   8b8a8: e59d00c4     	ldr	r0, [sp, #0xc4]
   8b8ac: e5d00061     	ldrb	r0, [r0, #0x61]
   8b8b0: e3500000     	cmp	r0, #0
   8b8b4: 1a00207f     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x81fc
   8b8b8: e59d00c0     	ldr	r0, [sp, #0xc0]
   8b8bc: e3021028     	movw	r1, #0x2028
   8b8c0: e7968001     	ldr	r8, [r6, r1]
   8b8c4: e5900018     	ldr	r0, [r0, #0x18]
   8b8c8: eb006e4f     	bl	0xa720c <.text+0x9710c> @ imm = #0x1b93c
   8b8cc: e1a07000     	mov	r7, r0
   8b8d0: eb01cb64     	bl	0xfe668 <.text+0xee568> @ imm = #0x72d90
   8b8d4: e3500001     	cmp	r0, #1
   8b8d8: ba00025e     	blt	0x8c258 <.text+0x7c158> @ imm = #0x978
   8b8dc: e5973028     	ldr	r3, [r7, #0x28]
   8b8e0: e3a01000     	mov	r1, #0
   8b8e4: e3a02000     	mov	r2, #0
   8b8e8: e3530001     	cmp	r3, #1
   8b8ec: aa000005     	bge	0x8b908 <.text+0x7b808> @ imm = #0x14
   8b8f0: ea00001a     	b	0x8b960 <.text+0x7b860> @ imm = #0x68
   8b8f4: e2822001     	add	r2, r2, #1
   8b8f8: e1520000     	cmp	r2, r0
   8b8fc: 0a000255     	beq	0x8c258 <.text+0x7c158> @ imm = #0x954
   8b900: e3530001     	cmp	r3, #1
   8b904: ba000015     	blt	0x8b960 <.text+0x7b860> @ imm = #0x54
   8b908: e5943000     	ldr	r3, [r4]
   8b90c: e2436001     	sub	r6, r3, #1
   8b910: e0030693     	mul	r3, r3, r6
   8b914: e3130001     	tst	r3, #1
   8b918: e5943000     	ldr	r3, [r4]
   8b91c: e2436001     	sub	r6, r3, #1
   8b920: e0030693     	mul	r3, r3, r6
   8b924: e3130001     	tst	r3, #1
   8b928: 0a000002     	beq	0x8b938 <.text+0x7b838> @ imm = #0x8
   8b92c: e5993000     	ldr	r3, [r9]
   8b930: e3530009     	cmp	r3, #9
   8b934: cafffff7     	bgt	0x8b918 <.text+0x7b818> @ imm = #-0x24
   8b938: e3a06000     	mov	r6, #0
   8b93c: e3a05000     	mov	r5, #0
   8b940: e7983102     	ldr	r3, [r8, r2, lsl #2]
   8b944: e2855001     	add	r5, r5, #1
   8b948: e7a31006     	str	r1, [r3, r6]!
   8b94c: e2866008     	add	r6, r6, #8
   8b950: e5831004     	str	r1, [r3, #0x4]
   8b954: e5973028     	ldr	r3, [r7, #0x28]
   8b958: e1550003     	cmp	r5, r3
   8b95c: bafffff7     	blt	0x8b940 <.text+0x7b840> @ imm = #-0x24
   8b960: e5946000     	ldr	r6, [r4]
   8b964: e2465001     	sub	r5, r6, #1
   8b968: e0060596     	mul	r6, r6, r5
   8b96c: e3160001     	tst	r6, #1
   8b970: e5946000     	ldr	r6, [r4]
   8b974: e2465001     	sub	r5, r6, #1
   8b978: e0060596     	mul	r6, r6, r5
   8b97c: e3160001     	tst	r6, #1
   8b980: 0affffdb     	beq	0x8b8f4 <.text+0x7b7f4> @ imm = #-0x94
   8b984: e5996000     	ldr	r6, [r9]
   8b988: e3560009     	cmp	r6, #9
   8b98c: cafffff7     	bgt	0x8b970 <.text+0x7b870> @ imm = #-0x24
   8b990: eaffffd7     	b	0x8b8f4 <.text+0x7b7f4> @ imm = #-0xa4
   8b994: e59d00c4     	ldr	r0, [sp, #0xc4]
   8b998: e5d00061     	ldrb	r0, [r0, #0x61]
   8b99c: e3500000     	cmp	r0, #0
   8b9a0: 1a002044     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x8110
   8b9a4: e5940000     	ldr	r0, [r4]
   8b9a8: e2401001     	sub	r1, r0, #1
   8b9ac: e0000190     	mul	r0, r0, r1
   8b9b0: e3100001     	tst	r0, #1
   8b9b4: e5940000     	ldr	r0, [r4]
   8b9b8: e2401001     	sub	r1, r0, #1
   8b9bc: e0010190     	mul	r1, r0, r1
   8b9c0: e3020034     	movw	r0, #0x2034
   8b9c4: e7960000     	ldr	r0, [r6, r0]
   8b9c8: e3110001     	tst	r1, #1
   8b9cc: 0a000002     	beq	0x8b9dc <.text+0x7b8dc> @ imm = #0x8
   8b9d0: e5991000     	ldr	r1, [r9]
   8b9d4: e3510009     	cmp	r1, #9
   8b9d8: cafffff5     	bgt	0x8b9b4 <.text+0x7b8b4> @ imm = #-0x2c
   8b9dc: e59d50c0     	ldr	r5, [sp, #0xc0]
   8b9e0: e3500001     	cmp	r0, #1
   8b9e4: e59f8fdc     	ldr	r8, [pc, #0xfdc]        @ 0x8c9c8 <.text+0x7c8c8>
   8b9e8: e08f8008     	add	r8, pc, r8
   8b9ec: 0a000334     	beq	0x8c6c4 <.text+0x7c5c4> @ imm = #0xcd0
   8b9f0: e59f7fd4     	ldr	r7, [pc, #0xfd4]        @ 0x8c9cc <.text+0x7c8cc>
   8b9f4: e3500000     	cmp	r0, #0
   8b9f8: e08f7007     	add	r7, pc, r7
   8b9fc: 1a0008d7     	bne	0x8dd60 <.text+0x7dc60> @ imm = #0x235c
   8ba00: e5940000     	ldr	r0, [r4]
   8ba04: e2401001     	sub	r1, r0, #1
   8ba08: e0000190     	mul	r0, r0, r1
   8ba0c: e3100001     	tst	r0, #1
   8ba10: 0a000738     	beq	0x8d6f8 <.text+0x7d5f8> @ imm = #0x1ce0
   8ba14: e5990000     	ldr	r0, [r9]
   8ba18: e3500009     	cmp	r0, #9
   8ba1c: ca000745     	bgt	0x8d738 <.text+0x7d638> @ imm = #0x1d14
   8ba20: ea000734     	b	0x8d6f8 <.text+0x7d5f8> @ imm = #0x1cd0
   8ba24: e59d00c4     	ldr	r0, [sp, #0xc4]
   8ba28: e5d00061     	ldrb	r0, [r0, #0x61]
   8ba2c: e3500000     	cmp	r0, #0
   8ba30: 1a002020     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x8080
   8ba34: e5940000     	ldr	r0, [r4]
   8ba38: e2401001     	sub	r1, r0, #1
   8ba3c: e0000190     	mul	r0, r0, r1
   8ba40: e3100001     	tst	r0, #1
   8ba44: e5940000     	ldr	r0, [r4]
   8ba48: e2401001     	sub	r1, r0, #1
   8ba4c: e0010190     	mul	r1, r0, r1
   8ba50: e3020034     	movw	r0, #0x2034
   8ba54: e7960000     	ldr	r0, [r6, r0]
   8ba58: e3110001     	tst	r1, #1
   8ba5c: 0a000002     	beq	0x8ba6c <.text+0x7b96c> @ imm = #0x8
   8ba60: e5991000     	ldr	r1, [r9]
   8ba64: e3510009     	cmp	r1, #9
   8ba68: cafffff5     	bgt	0x8ba44 <.text+0x7b944> @ imm = #-0x2c
   8ba6c: e59d50c0     	ldr	r5, [sp, #0xc0]
   8ba70: e3500001     	cmp	r0, #1
   8ba74: e59f7ffc     	ldr	r7, [pc, #0xffc]        @ 0x8ca78 <.text+0x7c978>
   8ba78: e08f7007     	add	r7, pc, r7
   8ba7c: 0a00031c     	beq	0x8c6f4 <.text+0x7c5f4> @ imm = #0xc70
   8ba80: e3500000     	cmp	r0, #0
   8ba84: 1a00031f     	bne	0x8c708 <.text+0x7c608> @ imm = #0xc7c
   8ba88: e59d00ac     	ldr	r0, [sp, #0xac]
   8ba8c: e3a02000     	mov	r2, #0
   8ba90: e5903000     	ldr	r3, [r0]
   8ba94: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x8ca94 <.text+0x7c994>
   8ba98: e08f0000     	add	r0, pc, r0
   8ba9c: e2801008     	add	r1, r0, #8
   8baa0: e1a00005     	mov	r0, r5
   8baa4: eb005075     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x141d4
   8baa8: e3500000     	cmp	r0, #0
   8baac: 1a000315     	bne	0x8c708 <.text+0x7c608> @ imm = #0xc54
   8bab0: e59f6fe0     	ldr	r6, [pc, #0xfe0]        @ 0x8ca98 <.text+0x7c998>
   8bab4: e08f6006     	add	r6, pc, r6
   8bab8: e1a00006     	mov	r0, r6
   8babc: eb146991     	bl	0x5a6108 <.text+0x596008> @ imm = #0x51a644
   8bac0: e1a00006     	mov	r0, r6
   8bac4: e5d75000     	ldrb	r5, [r7]
   8bac8: eb146afd     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51abf4
   8bacc: e3550000     	cmp	r5, #0
   8bad0: 1a000972     	bne	0x8e0a0 <.text+0x7dfa0> @ imm = #0x25c8
   8bad4: e59f1ff8     	ldr	r1, [pc, #0xff8]        @ 0x8cad4 <.text+0x7c9d4>
   8bad8: e3020034     	movw	r0, #0x2034
   8badc: e08f1001     	add	r1, pc, r1
   8bae0: e7910000     	ldr	r0, [r1, r0]
   8bae4: e3500001     	cmp	r0, #1
   8bae8: 0a0003e3     	beq	0x8ca7c <.text+0x7c97c> @ imm = #0xf8c
   8baec: e3500000     	cmp	r0, #0
   8baf0: 1a00096a     	bne	0x8e0a0 <.text+0x7dfa0> @ imm = #0x25a8
   8baf4: e5940000     	ldr	r0, [r4]
   8baf8: e2401001     	sub	r1, r0, #1
   8bafc: e0000190     	mul	r0, r0, r1
   8bb00: e3100001     	tst	r0, #1
   8bb04: 0a000715     	beq	0x8d760 <.text+0x7d660> @ imm = #0x1c54
   8bb08: e5990000     	ldr	r0, [r9]
   8bb0c: e3500009     	cmp	r0, #9
   8bb10: ca00071f     	bgt	0x8d794 <.text+0x7d694> @ imm = #0x1c7c
   8bb14: ea000711     	b	0x8d760 <.text+0x7d660> @ imm = #0x1c44
   8bb18: e59d00b4     	ldr	r0, [sp, #0xb4]
   8bb1c: e5d00000     	ldrb	r0, [r0]
   8bb20: e3500000     	cmp	r0, #0
   8bb24: 0a00010d     	beq	0x8bf60 <.text+0x7be60> @ imm = #0x434
   8bb28: e2860d81     	add	r0, r6, #8256
   8bb2c: ed1f0ba9     	vldr	d0, [pc, #-676]         @ 0x8b890 <.text+0x7b790>
   8bb30: e3021038     	movw	r1, #0x2038
   8bb34: ed908b00     	vldr	d8, [r0]
   8bb38: e0860001     	add	r0, r6, r1
   8bb3c: eeb48bc0     	vcmpe.f64	d8, d0
   8bb40: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8bb44: ed901b00     	vldr	d1, [r0]
   8bb48: e59d00c4     	ldr	r0, [sp, #0xc4]
   8bb4c: e5d00061     	ldrb	r0, [r0, #0x61]
   8bb50: 4eb08b41     	vmovmi.f64	d8, d1
   8bb54: e3500000     	cmp	r0, #0
   8bb58: 1a001fd6     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x7f58
   8bb5c: e5961008     	ldr	r1, [r6, #0x8]
   8bb60: e59d00bc     	ldr	r0, [sp, #0xbc]
   8bb64: ebff1287     	bl	0x50588 <.text+0x40488> @ imm = #-0x3b5e4
   8bb68: e59d50c0     	ldr	r5, [sp, #0xc0]
   8bb6c: e1a0a000     	mov	r10, r0
   8bb70: e1a0100a     	mov	r1, r10
   8bb74: e1a00005     	mov	r0, r5
   8bb78: eb002437     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x90dc
   8bb7c: e3500000     	cmp	r0, #0
   8bb80: 0a0002e9     	beq	0x8c72c <.text+0x7c62c> @ imm = #0xba4
   8bb84: e5940000     	ldr	r0, [r4]
   8bb88: e59f5fd4     	ldr	r5, [pc, #0xfd4]        @ 0x8cb64 <.text+0x7ca64>
   8bb8c: e2401001     	sub	r1, r0, #1
   8bb90: e08f5005     	add	r5, pc, r5
   8bb94: e0000190     	mul	r0, r0, r1
   8bb98: e3100001     	tst	r0, #1
   8bb9c: 0a00070d     	beq	0x8d7d8 <.text+0x7d6d8> @ imm = #0x1c34
   8bba0: e5990000     	ldr	r0, [r9]
   8bba4: e3500009     	cmp	r0, #9
   8bba8: ca00071f     	bgt	0x8d82c <.text+0x7d72c> @ imm = #0x1c7c
   8bbac: ea000709     	b	0x8d7d8 <.text+0x7d6d8> @ imm = #0x1c24
   8bbb0: e59f0fb0     	ldr	r0, [pc, #0xfb0]        @ 0x8cb68 <.text+0x7ca68>
   8bbb4: e79f0000     	ldr	r0, [pc, r0]
   8bbb8: e5961004     	ldr	r1, [r6, #0x4]
   8bbbc: e58d1030     	str	r1, [sp, #0x30]
   8bbc0: e5900018     	ldr	r0, [r0, #0x18]
   8bbc4: eb006d90     	bl	0xa720c <.text+0x9710c> @ imm = #0x1b640
   8bbc8: e3a0a000     	mov	r10, #0
   8bbcc: e1a08000     	mov	r8, r0
   8bbd0: e58da0d8     	str	r10, [sp, #0xd8]
   8bbd4: e28d10c8     	add	r1, sp, #200
   8bbd8: e58da0d4     	str	r10, [sp, #0xd4]
   8bbdc: e58da0d0     	str	r10, [sp, #0xd0]
   8bbe0: e58da0cc     	str	r10, [sp, #0xcc]
   8bbe4: e58da0c8     	str	r10, [sp, #0xc8]
   8bbe8: e59f0f7c     	ldr	r0, [pc, #0xf7c]        @ 0x8cb6c <.text+0x7ca6c>
   8bbec: e79f0000     	ldr	r0, [pc, r0]
   8bbf0: ebffd991     	bl	0x8223c <.text+0x7213c> @ imm = #-0x99bc
   8bbf4: e59fef74     	ldr	lr, [pc, #0xf74]        @ 0x8cb70 <.text+0x7ca70>
   8bbf8: e59d20d8     	ldr	r2, [sp, #0xd8]
   8bbfc: e08fe00e     	add	lr, pc, lr
   8bc00: e58d203c     	str	r2, [sp, #0x3c]
   8bc04: e3520001     	cmp	r2, #1
   8bc08: e1ce00d8     	ldrd	r0, r1, [lr, #8]
   8bc0c: e58d00cc     	str	r0, [sp, #0xcc]
   8bc10: e58d10d0     	str	r1, [sp, #0xd0]
   8bc14: ba0000a2     	blt	0x8bea4 <.text+0x7bda4> @ imm = #0x288
   8bc18: e59d00c8     	ldr	r0, [sp, #0xc8]
   8bc1c: e58d0048     	str	r0, [sp, #0x48]
   8bc20: e59d00d4     	ldr	r0, [sp, #0xd4]
   8bc24: e58d004c     	str	r0, [sp, #0x4c]
   8bc28: e58d8038     	str	r8, [sp, #0x38]
   8bc2c: ea000003     	b	0x8bc40 <.text+0x7bb40> @ imm = #0xc
   8bc30: e59d003c     	ldr	r0, [sp, #0x3c]
   8bc34: e28aa001     	add	r10, r10, #1
   8bc38: e15a0000     	cmp	r10, r0
   8bc3c: 0a000096     	beq	0x8be9c <.text+0x7bd9c> @ imm = #0x258
   8bc40: e59f0fb8     	ldr	r0, [pc, #0xfb8]        @ 0x8cc00 <.text+0x7cb00>
   8bc44: e08a210a     	add	r2, r10, r10, lsl #2
   8bc48: e79f0000     	ldr	r0, [pc, r0]
   8bc4c: e59e1020     	ldr	r1, [lr, #0x20]
   8bc50: e58da054     	str	r10, [sp, #0x54]
   8bc54: e5900018     	ldr	r0, [r0, #0x18]
   8bc58: e0815182     	add	r5, r1, r2, lsl #3
   8bc5c: eb006d6a     	bl	0xa720c <.text+0x9710c> @ imm = #0x1b5a8
   8bc60: e1a0c005     	mov	r12, r5
   8bc64: e5908018     	ldr	r8, [r0, #0x18]
   8bc68: e5bce020     	ldr	lr, [r12, #0x20]!
   8bc6c: e3580001     	cmp	r8, #1
   8bc70: e58d5050     	str	r5, [sp, #0x50]
   8bc74: e59ea000     	ldr	r10, [lr]
   8bc78: 0a00001e     	beq	0x8bcf8 <.text+0x7bbf8> @ imm = #0x78
   8bc7c: ba00001d     	blt	0x8bcf8 <.text+0x7bbf8> @ imm = #0x74
   8bc80: e28e7038     	add	r7, lr, #56
   8bc84: e2481001     	sub	r1, r8, #1
   8bc88: e3a02001     	mov	r2, #1
   8bc8c: e1a0600a     	mov	r6, r10
   8bc90: ea000005     	b	0x8bcac <.text+0x7bbac> @ imm = #0x14
   8bc94: e2822001     	add	r2, r2, #1
   8bc98: e2877038     	add	r7, r7, #56
   8bc9c: e2511001     	subs	r1, r1, #1
   8bca0: e1a0a005     	mov	r10, r5
   8bca4: e1a06000     	mov	r6, r0
   8bca8: 0a000014     	beq	0x8bd00 <.text+0x7bc00> @ imm = #0x50
   8bcac: e5940000     	ldr	r0, [r4]
   8bcb0: e2403001     	sub	r3, r0, #1
   8bcb4: e0000390     	mul	r0, r0, r3
   8bcb8: e3100001     	tst	r0, #1
   8bcbc: e5943000     	ldr	r3, [r4]
   8bcc0: e5970000     	ldr	r0, [r7]
   8bcc4: e2435001     	sub	r5, r3, #1
   8bcc8: e15a0000     	cmp	r10, r0
   8bccc: e0030593     	mul	r3, r3, r5
   8bcd0: e1a0500a     	mov	r5, r10
   8bcd4: b1a05000     	movlt	r5, r0
   8bcd8: e1560000     	cmp	r6, r0
   8bcdc: d1a00006     	movle	r0, r6
   8bce0: e3130001     	tst	r3, #1
   8bce4: 0affffea     	beq	0x8bc94 <.text+0x7bb94> @ imm = #-0x58
   8bce8: e5993000     	ldr	r3, [r9]
   8bcec: e3530009     	cmp	r3, #9
   8bcf0: cafffff1     	bgt	0x8bcbc <.text+0x7bbbc> @ imm = #-0x3c
   8bcf4: eaffffe6     	b	0x8bc94 <.text+0x7bb94> @ imm = #-0x68
   8bcf8: e1a0500a     	mov	r5, r10
   8bcfc: e1a0000a     	mov	r0, r10
   8bd00: e3a0a001     	mov	r10, #1
   8bd04: e1a02000     	mov	r2, r0
   8bd08: ea000005     	b	0x8bd24 <.text+0x7bc24> @ imm = #0x14
   8bd0c: e156000a     	cmp	r6, r10
   8bd10: c1a00002     	movgt	r0, r2
   8bd14: e2822003     	add	r2, r2, #3
   8bd18: c1a0a006     	movgt	r10, r6
   8bd1c: e1520005     	cmp	r2, r5
   8bd20: ca00000a     	bgt	0x8bd50 <.text+0x7bc50> @ imm = #0x28
   8bd24: e3a06000     	mov	r6, #0
   8bd28: e3580001     	cmp	r8, #1
   8bd2c: bafffff6     	blt	0x8bd0c <.text+0x7bc0c> @ imm = #-0x28
   8bd30: e1a0700e     	mov	r7, lr
   8bd34: e1a03008     	mov	r3, r8
   8bd38: e4971038     	ldr	r1, [r7], #56
   8bd3c: e1510002     	cmp	r1, r2
   8bd40: 02866001     	addeq	r6, r6, #1
   8bd44: e2533001     	subs	r3, r3, #1
   8bd48: 1afffffa     	bne	0x8bd38 <.text+0x7bc38> @ imm = #-0x18
   8bd4c: eaffffee     	b	0x8bd0c <.text+0x7bc0c> @ imm = #-0x48
   8bd50: e59da054     	ldr	r10, [sp, #0x54]
   8bd54: e59d204c     	ldr	r2, [sp, #0x4c]
   8bd58: e08a108a     	add	r1, r10, r10, lsl #1
   8bd5c: e7a20101     	str	r0, [r2, r1, lsl #2]!
   8bd60: e59d7050     	ldr	r7, [sp, #0x50]
   8bd64: e5d73005     	ldrb	r3, [r7, #0x5]
   8bd68: e3530000     	cmp	r3, #0
   8bd6c: 0a000007     	beq	0x8bd90 <.text+0x7bc90> @ imm = #0x1c
   8bd70: e59d3048     	ldr	r3, [sp, #0x48]
   8bd74: ee003a10     	vmov	s0, r3
   8bd78: eeb80bc0     	vcvt.f64.s32	d0, s0
   8bd7c: ed971b02     	vldr	d1, [r7, #8]
   8bd80: ee310b00     	vadd.f64	d0, d1, d0
   8bd84: eebd0bc0     	vcvt.s32.f64	s0, d0
   8bd88: ee103a10     	vmov	r3, s0
   8bd8c: e58d3048     	str	r3, [sp, #0x48]
   8bd90: e59fefe0     	ldr	lr, [pc, #0xfe0]        @ 0x8cd78 <.text+0x7cc78>
   8bd94: e5943000     	ldr	r3, [r4]
   8bd98: e59d8038     	ldr	r8, [sp, #0x38]
   8bd9c: e08fe00e     	add	lr, pc, lr
   8bda0: e2437001     	sub	r7, r3, #1
   8bda4: e0030793     	mul	r3, r3, r7
   8bda8: e3130001     	tst	r3, #1
   8bdac: e5943000     	ldr	r3, [r4]
   8bdb0: e2437001     	sub	r7, r3, #1
   8bdb4: e0070793     	mul	r7, r3, r7
   8bdb8: e5983010     	ldr	r3, [r8, #0x10]
   8bdbc: e3170001     	tst	r7, #1
   8bdc0: 0a000002     	beq	0x8bdd0 <.text+0x7bcd0> @ imm = #0x8
   8bdc4: e5997000     	ldr	r7, [r9]
   8bdc8: e3570009     	cmp	r7, #9
   8bdcc: cafffff6     	bgt	0x8bdac <.text+0x7bcac> @ imm = #-0x28
   8bdd0: e3530001     	cmp	r3, #1
   8bdd4: baffff95     	blt	0x8bc30 <.text+0x7bb30> @ imm = #-0x1ac
   8bdd8: e59c3000     	ldr	r3, [r12]
   8bddc: e59d504c     	ldr	r5, [sp, #0x4c]
   8bde0: e0851101     	add	r1, r5, r1, lsl #2
   8bde4: e5933000     	ldr	r3, [r3]
   8bde8: e5b17008     	ldr	r7, [r1, #0x8]!
   8bdec: e0530000     	subs	r0, r3, r0
   8bdf0: 11a00003     	movne	r0, r3
   8bdf4: e5870000     	str	r0, [r7]
   8bdf8: e5980010     	ldr	r0, [r8, #0x10]
   8bdfc: e3500002     	cmp	r0, #2
   8be00: baffff8a     	blt	0x8bc30 <.text+0x7bb30> @ imm = #-0x1d8
   8be04: e3a00001     	mov	r0, #1
   8be08: e3a03038     	mov	r3, #56
   8be0c: e59c7000     	ldr	r7, [r12]
   8be10: e5926000     	ldr	r6, [r2]
   8be14: e5915000     	ldr	r5, [r1]
   8be18: e7977003     	ldr	r7, [r7, r3]
   8be1c: e2833038     	add	r3, r3, #56
   8be20: e0576006     	subs	r6, r7, r6
   8be24: 11a06007     	movne	r6, r7
   8be28: e7856100     	str	r6, [r5, r0, lsl #2]
   8be2c: e2800001     	add	r0, r0, #1
   8be30: e5987010     	ldr	r7, [r8, #0x10]
   8be34: e1500007     	cmp	r0, r7
   8be38: bafffff3     	blt	0x8be0c <.text+0x7bd0c> @ imm = #-0x34
   8be3c: eaffff7b     	b	0x8bc30 <.text+0x7bb30> @ imm = #-0x214
   8be40: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x8ce2c <.text+0x7cd2c>
   8be44: e3a07001     	mov	r7, #1
   8be48: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x8ce30 <.text+0x7cd30>
   8be4c: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x8ce34 <.text+0x7cd34>
   8be50: e08f0000     	add	r0, pc, r0
   8be54: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x8ce38 <.text+0x7cd38>
   8be58: e08f1001     	add	r1, pc, r1
   8be5c: e08f2002     	add	r2, pc, r2
   8be60: e58d7000     	str	r7, [sp]
   8be64: e08f3003     	add	r3, pc, r3
   8be68: e58d3004     	str	r3, [sp, #0x4]
   8be6c: e3013549     	movw	r3, #0x1549
   8be70: eb01b893     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6e24c
   8be74: e59d00b8     	ldr	r0, [sp, #0xb8]
   8be78: e3001fa2     	movw	r1, #0xfa2
   8be7c: ebfef785     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x421ec
   8be80: e59d00c0     	ldr	r0, [sp, #0xc0]
   8be84: ebff6c3d     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x24f0c
   8be88: e59f1fac     	ldr	r1, [pc, #0xfac]        @ 0x8ce3c <.text+0x7cd3c>
   8be8c: e3a00000     	mov	r0, #0
   8be90: e08f1001     	add	r1, pc, r1
   8be94: e5c10000     	strb	r0, [r1]
   8be98: ea001f06     	b	0x93ab8 <.text+0x839b8> @ imm = #0x7c18
   8be9c: e59d0048     	ldr	r0, [sp, #0x48]
   8bea0: e58d00c8     	str	r0, [sp, #0xc8]
   8bea4: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x8ce98 <.text+0x7cd98>
   8bea8: e3a07003     	mov	r7, #3
   8beac: e59f1fe8     	ldr	r1, [pc, #0xfe8]        @ 0x8ce9c <.text+0x7cd9c>
   8beb0: e59f2fe8     	ldr	r2, [pc, #0xfe8]        @ 0x8cea0 <.text+0x7cda0>
   8beb4: e08f0000     	add	r0, pc, r0
   8beb8: e59f3fe4     	ldr	r3, [pc, #0xfe4]        @ 0x8cea4 <.text+0x7cda4>
   8bebc: e08f1001     	add	r1, pc, r1
   8bec0: e08f2002     	add	r2, pc, r2
   8bec4: e58d7000     	str	r7, [sp]
   8bec8: e08f3003     	add	r3, pc, r3
   8becc: e58d3004     	str	r3, [sp, #0x4]
   8bed0: e300373b     	movw	r3, #0x73b
   8bed4: eb01b87a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6e1e8
   8bed8: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x8cea8 <.text+0x7cda8>
   8bedc: e28d10c8     	add	r1, sp, #200
   8bee0: e79f0000     	ldr	r0, [pc, r0]
   8bee4: ebffe07a     	bl	0x840d4 <.text+0x73fd4> @ imm = #-0x7e18
   8bee8: e59d0030     	ldr	r0, [sp, #0x30]
   8beec: e28d10e0     	add	r1, sp, #224
   8bef0: e5900000     	ldr	r0, [r0]
   8bef4: e58d0048     	str	r0, [sp, #0x48]
   8bef8: e59f0fac     	ldr	r0, [pc, #0xfac]        @ 0x8ceac <.text+0x7cdac>
   8befc: e08f0000     	add	r0, pc, r0
   8bf00: eb14469d     	bl	0x59d97c <.text+0x58d87c> @ imm = #0x511a74
   8bf04: e3500000     	cmp	r0, #0
   8bf08: 0a000039     	beq	0x8bff4 <.text+0x7bef4> @ imm = #0xe4
   8bf0c: eb0318d5     	bl	0x152268 <.text+0x142168> @ imm = #0xc6354
   8bf10: ea00003e     	b	0x8c010 <.text+0x7bf10> @ imm = #0xf8
   8bf14: e59d604c     	ldr	r6, [sp, #0x4c]
   8bf18: e3500000     	cmp	r0, #0
   8bf1c: 0a000a70     	beq	0x8e8e4 <.text+0x7e7e4> @ imm = #0x29c0
   8bf20: ea000a62     	b	0x8e8b0 <.text+0x7e7b0> @ imm = #0x2988
   8bf24: e5940000     	ldr	r0, [r4]
   8bf28: e59d50c0     	ldr	r5, [sp, #0xc0]
   8bf2c: e2401001     	sub	r1, r0, #1
   8bf30: e59d6098     	ldr	r6, [sp, #0x98]
   8bf34: e59d7094     	ldr	r7, [sp, #0x94]
   8bf38: e0000190     	mul	r0, r0, r1
   8bf3c: e3100001     	tst	r0, #1
   8bf40: 0a00064c     	beq	0x8d878 <.text+0x7d778> @ imm = #0x1930
   8bf44: e5990000     	ldr	r0, [r9]
   8bf48: e3500009     	cmp	r0, #9
   8bf4c: ca00065b     	bgt	0x8d8c0 <.text+0x7d7c0> @ imm = #0x196c
   8bf50: ea000648     	b	0x8d878 <.text+0x7d778> @ imm = #0x1920
   8bf54: 00585a4c     	subseq	r5, r8, r12, asr #20
   8bf58: 00585a48     	subseq	r5, r8, r8, asr #20
   8bf5c: 0055c40b     	subseq	r12, r5, r11, lsl #8
   8bf60: e59d00c4     	ldr	r0, [sp, #0xc4]
   8bf64: e5d00061     	ldrb	r0, [r0, #0x61]
   8bf68: e3500000     	cmp	r0, #0
   8bf6c: 1a001ed1     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x7b44
   8bf70: e9960005     	ldmib	r6, {r0, r2}
   8bf74: e59d50c0     	ldr	r5, [sp, #0xc0]
   8bf78: e5901010     	ldr	r1, [r0, #0x10]
   8bf7c: e59d00bc     	ldr	r0, [sp, #0xbc]
   8bf80: e1520001     	cmp	r2, r1
   8bf84: e595801c     	ldr	r8, [r5, #0x1c]
   8bf88: c1a01002     	movgt	r1, r2
   8bf8c: ebff117d     	bl	0x50588 <.text+0x40488> @ imm = #-0x3ba0c
   8bf90: e1a01000     	mov	r1, r0
   8bf94: e1a00005     	mov	r0, r5
   8bf98: eb00232f     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x8cbc
   8bf9c: e3500000     	cmp	r0, #0
   8bfa0: 0a0001fa     	beq	0x8c790 <.text+0x7c690> @ imm = #0x7e8
   8bfa4: e5940000     	ldr	r0, [r4]
   8bfa8: e2401001     	sub	r1, r0, #1
   8bfac: e0000190     	mul	r0, r0, r1
   8bfb0: e3100001     	tst	r0, #1
   8bfb4: 0a00066b     	beq	0x8d968 <.text+0x7d868> @ imm = #0x19ac
   8bfb8: e5990000     	ldr	r0, [r9]
   8bfbc: e3500009     	cmp	r0, #9
   8bfc0: ca00067e     	bgt	0x8d9c0 <.text+0x7d8c0> @ imm = #0x19f8
   8bfc4: ea000667     	b	0x8d968 <.text+0x7d868> @ imm = #0x199c
   8bfc8: 0055c1a2     	subseq	r12, r5, r2, lsr #3
   8bfcc: 0055bf03     	subseq	r11, r5, r3, lsl #30
   8bfd0: 0055be61     	subseq	r11, r5, r1, ror #28
   8bfd4: 0055be87     	subseq	r11, r5, r7, lsl #29
   8bfd8: 00554c8c     	subseq	r4, r5, r12, lsl #25
   8bfdc: 00553c80     	subseq	r3, r5, r0, lsl #25
   8bfe0: 00554c0c     	subseq	r4, r5, r12, lsl #24
   8bfe4: 00553bf4     	ldrsheq	r3, [r5], #-180
   8bfe8: 00585890     	<unknown>
   8bfec: 0058584c     	subseq	r5, r8, r12, asr #16
   8bff0: 00585830     	subseq	r5, r8, r0, lsr r8
   8bff4: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x8cfc4 <.text+0x7cec4>
   8bff8: e28d2f5e     	add	r2, sp, #376
   8bffc: e3a01000     	mov	r1, #0
   8c000: e08f0000     	add	r0, pc, r0
   8c004: eb02aeb6     	bl	0x137ae4 <.text+0x1279e4> @ imm = #0xabad8
   8c008: e3500000     	cmp	r0, #0
   8c00c: 0a00018c     	beq	0x8c644 <.text+0x7c544> @ imm = #0x630
   8c010: e58d004c     	str	r0, [sp, #0x4c]
   8c014: eb01c993     	bl	0xfe668 <.text+0xee568> @ imm = #0x7264c
   8c018: e1a05000     	mov	r5, r0
   8c01c: e3a00000     	mov	r0, #0
   8c020: eb147018     	bl	0x5a8088 <.text+0x597f88> @ imm = #0x51c060
   8c024: e24b7e19     	sub	r7, r11, #400
   8c028: e50b0198     	str	r0, [r11, #-0x198]
   8c02c: e24b0f66     	sub	r0, r11, #408
   8c030: e50b1194     	str	r1, [r11, #-0x194]
   8c034: e1a01007     	mov	r1, r7
   8c038: eb146cd4     	bl	0x5a7390 <.text+0x597290> @ imm = #0x51b350
   8c03c: e59f2f84     	ldr	r2, [pc, #0xf84]        @ 0x8cfc8 <.text+0x7cec8>
   8c040: e24bec01     	sub	lr, r11, #256
   8c044: e24e0063     	sub	r0, lr, #99
   8c048: e3a0100b     	mov	r1, #11
   8c04c: e08f2002     	add	r2, pc, r2
   8c050: e1a03007     	mov	r3, r7
   8c054: eb147004     	bl	0x5a806c <.text+0x597f6c> @ imm = #0x51c010
   8c058: eb032881     	bl	0x156264 <.text+0x146164> @ imm = #0xca204
   8c05c: e3550001     	cmp	r5, #1
   8c060: e58d0054     	str	r0, [sp, #0x54]
   8c064: e58d5050     	str	r5, [sp, #0x50]
   8c068: ba000037     	blt	0x8c14c <.text+0x7c04c> @ imm = #0xdc
   8c06c: e59d00d4     	ldr	r0, [sp, #0xd4]
   8c070: e3a06000     	mov	r6, #0
   8c074: e3a05000     	mov	r5, #0
   8c078: e2808008     	add	r8, r0, #8
   8c07c: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x8d058 <.text+0x7cf58>
   8c080: e79f0000     	ldr	r0, [pc, r0]
   8c084: e5900230     	ldr	r0, [r0, #0x230]
   8c088: e0800006     	add	r0, r0, r6
   8c08c: ebff1f9c     	bl	0x53f04 <.text+0x43e04> @ imm = #-0x38190
   8c090: e1a07000     	mov	r7, r0
   8c094: e5981000     	ldr	r1, [r8]
   8c098: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0x8d05c <.text+0x7cf5c>
   8c09c: e24b2f67     	sub	r2, r11, #412
   8c0a0: e79f0000     	ldr	r0, [pc, r0]
   8c0a4: e2800050     	add	r0, r0, #80
   8c0a8: ebff1204     	bl	0x508c0 <.text+0x407c0> @ imm = #-0x3b7f0
   8c0ac: e5180008     	ldr	r0, [r8, #-0x8]
   8c0b0: e3570000     	cmp	r7, #0
   8c0b4: e51b119c     	ldr	r1, [r11, #-0x19c]
   8c0b8: e59f2fa0     	ldr	r2, [pc, #0xfa0]        @ 0x8d060 <.text+0x7cf60>
   8c0bc: e08f2002     	add	r2, pc, r2
   8c0c0: 01a07002     	moveq	r7, r2
   8c0c4: e58d7000     	str	r7, [sp]
   8c0c8: e59f2f94     	ldr	r2, [pc, #0xf94]        @ 0x8d064 <.text+0x7cf64>
   8c0cc: e58d0008     	str	r0, [sp, #0x8]
   8c0d0: e08f2002     	add	r2, pc, r2
   8c0d4: e58d2004     	str	r2, [sp, #0x4]
   8c0d8: e59f0ffc     	ldr	r0, [pc, #0xffc]        @ 0x8d0dc <.text+0x7cfdc>
   8c0dc: e58d1010     	str	r1, [sp, #0x10]
   8c0e0: e3a01000     	mov	r1, #0
   8c0e4: e08f0000     	add	r0, pc, r0
   8c0e8: e58d000c     	str	r0, [sp, #0xc]
   8c0ec: e59f2fec     	ldr	r2, [pc, #0xfec]        @ 0x8d0e0 <.text+0x7cfe0>
   8c0f0: e24b0f56     	sub	r0, r11, #344
   8c0f4: e59f3fe8     	ldr	r3, [pc, #0xfe8]        @ 0x8d0e4 <.text+0x7cfe4>
   8c0f8: e08f2002     	add	r2, pc, r2
   8c0fc: e08f3003     	add	r3, pc, r3
   8c100: eb02de9d     	bl	0x143b7c <.text+0x133a7c> @ imm = #0xb7a74
   8c104: e1a0a000     	mov	r10, r0
   8c108: e51b019c     	ldr	r0, [r11, #-0x19c]
   8c10c: e3500000     	cmp	r0, #0
   8c110: 0a000002     	beq	0x8c120 <.text+0x7c020> @ imm = #0x8
   8c114: eb141edc     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x507b70
   8c118: e3a00000     	mov	r0, #0
   8c11c: e50b019c     	str	r0, [r11, #-0x19c]
   8c120: e35a0000     	cmp	r10, #0
   8c124: 0a00002a     	beq	0x8c1d4 <.text+0x7c0d4> @ imm = #0xa8
   8c128: e59d0054     	ldr	r0, [sp, #0x54]
   8c12c: e1a0100a     	mov	r1, r10
   8c130: eb032a5a     	bl	0x156aa0 <.text+0x1469a0> @ imm = #0xca968
   8c134: e59d0050     	ldr	r0, [sp, #0x50]
   8c138: e2855001     	add	r5, r5, #1
   8c13c: e2866e32     	add	r6, r6, #800
   8c140: e288800c     	add	r8, r8, #12
   8c144: e1500005     	cmp	r0, r5
   8c148: 1affffcb     	bne	0x8c07c <.text+0x7bf7c> @ imm = #-0xd4
   8c14c: e28d70c8     	add	r7, sp, #200
   8c150: e24b6c01     	sub	r6, r11, #256
   8c154: e2466063     	sub	r6, r6, #99
   8c158: e8970083     	ldm	r7, {r0, r1, r7}
   8c15c: e59fefcc     	ldr	lr, [pc, #0xfcc]        @ 0x8d130 <.text+0x7d030>
   8c160: e59fcfcc     	ldr	r12, [pc, #0xfcc]       @ 0x8d134 <.text+0x7d034>
   8c164: e59d2054     	ldr	r2, [sp, #0x54]
   8c168: e08fe00e     	add	lr, pc, lr
   8c16c: e58d2020     	str	r2, [sp, #0x20]
   8c170: e08fc00c     	add	r12, pc, r12
   8c174: e59f5fbc     	ldr	r5, [pc, #0xfbc]        @ 0x8d138 <.text+0x7d038>
   8c178: e59f2fbc     	ldr	r2, [pc, #0xfbc]        @ 0x8d13c <.text+0x7d03c>
   8c17c: e59f3fbc     	ldr	r3, [pc, #0xfbc]        @ 0x8d140 <.text+0x7d040>
   8c180: e08f5005     	add	r5, pc, r5
   8c184: e58d5004     	str	r5, [sp, #0x4]
   8c188: e08f2002     	add	r2, pc, r2
   8c18c: e58d1010     	str	r1, [sp, #0x10]
   8c190: e28d1014     	add	r1, sp, #20
   8c194: e58d6000     	str	r6, [sp]
   8c198: e08f3003     	add	r3, pc, r3
   8c19c: e58d0008     	str	r0, [sp, #0x8]
   8c1a0: e3a05000     	mov	r5, #0
   8c1a4: e58de00c     	str	lr, [sp, #0xc]
   8c1a8: e59f0ff0     	ldr	r0, [pc, #0xff0]        @ 0x8d1a0 <.text+0x7d0a0>
   8c1ac: e08f0000     	add	r0, pc, r0
   8c1b0: e8811081     	stm	r1, {r0, r7, r12}
   8c1b4: e24b0f56     	sub	r0, r11, #344
   8c1b8: e3a01000     	mov	r1, #0
   8c1bc: eb02de6e     	bl	0x143b7c <.text+0x133a7c> @ imm = #0xb79b8
   8c1c0: e3500000     	cmp	r0, #0
   8c1c4: 0a000010     	beq	0x8c20c <.text+0x7c10c> @ imm = #0x40
   8c1c8: e1a02000     	mov	r2, r0
   8c1cc: e3a05001     	mov	r5, #1
   8c1d0: ea00001d     	b	0x8c24c <.text+0x7c14c> @ imm = #0x74
   8c1d4: e5940000     	ldr	r0, [r4]
   8c1d8: e59f6fdc     	ldr	r6, [pc, #0xfdc]        @ 0x8d1bc <.text+0x7d0bc>
   8c1dc: e2401001     	sub	r1, r0, #1
   8c1e0: e59f8fd8     	ldr	r8, [pc, #0xfd8]        @ 0x8d1c0 <.text+0x7d0c0>
   8c1e4: e08f6006     	add	r6, pc, r6
   8c1e8: e0000190     	mul	r0, r0, r1
   8c1ec: e08f8008     	add	r8, pc, r8
   8c1f0: e3100001     	tst	r0, #1
   8c1f4: 0a0005ff     	beq	0x8d9f8 <.text+0x7d8f8> @ imm = #0x17fc
   8c1f8: e5990000     	ldr	r0, [r9]
   8c1fc: e3500009     	cmp	r0, #9
   8c200: ca000613     	bgt	0x8da54 <.text+0x7d954> @ imm = #0x184c
   8c204: ea0005fb     	b	0x8d9f8 <.text+0x7d8f8> @ imm = #0x17ec
   8c208: 005877bc     	ldrheq	r7, [r8], #-124
   8c20c: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x8d200 <.text+0x7d100>
   8c210: e3a07001     	mov	r7, #1
   8c214: e59f1fe8     	ldr	r1, [pc, #0xfe8]        @ 0x8d204 <.text+0x7d104>
   8c218: e59f2fe8     	ldr	r2, [pc, #0xfe8]        @ 0x8d208 <.text+0x7d108>
   8c21c: e08f0000     	add	r0, pc, r0
   8c220: e59f3fe4     	ldr	r3, [pc, #0xfe4]        @ 0x8d20c <.text+0x7d10c>
   8c224: e08f1001     	add	r1, pc, r1
   8c228: e08f2002     	add	r2, pc, r2
   8c22c: e58d7000     	str	r7, [sp]
   8c230: e08f3003     	add	r3, pc, r3
   8c234: e58d3004     	str	r3, [sp, #0x4]
   8c238: e59d30a4     	ldr	r3, [sp, #0xa4]
   8c23c: e58d3008     	str	r3, [sp, #0x8]
   8c240: e30036a6     	movw	r3, #0x6a6
   8c244: eb01b79e     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6de78
   8c248: e3a02000     	mov	r2, #0
   8c24c: e59f8ff8     	ldr	r8, [pc, #0xff8]        @ 0x8d24c <.text+0x7d14c>
   8c250: e08f8008     	add	r8, pc, r8
   8c254: ea001cdd     	b	0x935d0 <.text+0x834d0> @ imm = #0x7374
   8c258: e59f2ff0     	ldr	r2, [pc, #0xff0]        @ 0x8d250 <.text+0x7d150>
   8c25c: e3a08000     	mov	r8, #0
   8c260: e302a034     	movw	r10, #0x2034
   8c264: e08f2002     	add	r2, pc, r2
   8c268: ea000003     	b	0x8c27c <.text+0x7c17c> @ imm = #0xc
   8c26c: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x8d254 <.text+0x7d154>
   8c270: e3580005     	cmp	r8, #5
   8c274: e08f2002     	add	r2, pc, r2
   8c278: 0a000140     	beq	0x8c780 <.text+0x7c680> @ imm = #0x500
   8c27c: e59d00c4     	ldr	r0, [sp, #0xc4]
   8c280: e5d00061     	ldrb	r0, [r0, #0x61]
   8c284: e3500000     	cmp	r0, #0
   8c288: 1a001e0a     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x7828
   8c28c: e792000a     	ldr	r0, [r2, r10]
   8c290: e3500001     	cmp	r0, #1
   8c294: 0a00000b     	beq	0x8c2c8 <.text+0x7c1c8> @ imm = #0x2c
   8c298: e59d50c0     	ldr	r5, [sp, #0xc0]
   8c29c: e3500000     	cmp	r0, #0
   8c2a0: e59f7fec     	ldr	r7, [pc, #0xfec]        @ 0x8d294 <.text+0x7d194>
   8c2a4: e08f7007     	add	r7, pc, r7
   8c2a8: 1a000014     	bne	0x8c300 <.text+0x7c200> @ imm = #0x50
   8c2ac: e59d00ac     	ldr	r0, [sp, #0xac]
   8c2b0: e2821008     	add	r1, r2, #8
   8c2b4: e3a02000     	mov	r2, #0
   8c2b8: e5903000     	ldr	r3, [r0]
   8c2bc: e1a00005     	mov	r0, r5
   8c2c0: eb004e6e     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x139b8
   8c2c4: ea00000b     	b	0x8c2f8 <.text+0x7c1f8> @ imm = #0x2c
   8c2c8: e5940000     	ldr	r0, [r4]
   8c2cc: e59d50c0     	ldr	r5, [sp, #0xc0]
   8c2d0: e2401001     	sub	r1, r0, #1
   8c2d4: e59f7fbc     	ldr	r7, [pc, #0xfbc]        @ 0x8d298 <.text+0x7d198>
   8c2d8: e0000190     	mul	r0, r0, r1
   8c2dc: e08f7007     	add	r7, pc, r7
   8c2e0: e3100001     	tst	r0, #1
   8c2e4: 0a00007d     	beq	0x8c4e0 <.text+0x7c3e0> @ imm = #0x1f4
   8c2e8: e5990000     	ldr	r0, [r9]
   8c2ec: e3500009     	cmp	r0, #9
   8c2f0: ca000087     	bgt	0x8c514 <.text+0x7c414> @ imm = #0x21c
   8c2f4: ea000079     	b	0x8c4e0 <.text+0x7c3e0> @ imm = #0x1e4
   8c2f8: e3500000     	cmp	r0, #0
   8c2fc: 0a00001d     	beq	0x8c378 <.text+0x7c278> @ imm = #0x74
   8c300: e1a00005     	mov	r0, r5
   8c304: e3a01001     	mov	r1, #1
   8c308: eb002409     	bl	0x95334 <.text+0x85234> @ imm = #0x9024
   8c30c: e3500000     	cmp	r0, #0
   8c310: 1a000148     	bne	0x8c838 <.text+0x7c738> @ imm = #0x520
   8c314: e59f6f80     	ldr	r6, [pc, #0xf80]        @ 0x8d29c <.text+0x7d19c>
   8c318: e08f6006     	add	r6, pc, r6
   8c31c: e1a00006     	mov	r0, r6
   8c320: eb146778     	bl	0x5a6108 <.text+0x596008> @ imm = #0x519de0
   8c324: e1a00006     	mov	r0, r6
   8c328: e5d75000     	ldrb	r5, [r7]
   8c32c: eb1468e4     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51a390
   8c330: e59f3fec     	ldr	r3, [pc, #0xfec]        @ 0x8d324 <.text+0x7d224>
   8c334: e3550000     	cmp	r5, #0
   8c338: e3a07005     	mov	r7, #5
   8c33c: e08f3003     	add	r3, pc, r3
   8c340: 1a001ddc     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x7770
   8c344: e5940000     	ldr	r0, [r4]
   8c348: e59d50c0     	ldr	r5, [sp, #0xc0]
   8c34c: e2401001     	sub	r1, r0, #1
   8c350: e59d60a0     	ldr	r6, [sp, #0xa0]
   8c354: e0000190     	mul	r0, r0, r1
   8c358: e3100001     	tst	r0, #1
   8c35c: 0a00002c     	beq	0x8c414 <.text+0x7c314> @ imm = #0xb0
   8c360: e5990000     	ldr	r0, [r9]
   8c364: e3500009     	cmp	r0, #9
   8c368: ca000039     	bgt	0x8c454 <.text+0x7c354> @ imm = #0xe4
   8c36c: ea000028     	b	0x8c414 <.text+0x7c314> @ imm = #0xa0
   8c370: 00587674     	subseq	r7, r8, r4, ror r6
   8c374: 00587679     	subseq	r7, r8, r9, ror r6
   8c378: e59fafa8     	ldr	r10, [pc, #0xfa8]       @ 0x8d328 <.text+0x7d228>
   8c37c: e08fa00a     	add	r10, pc, r10
   8c380: e1a0000a     	mov	r0, r10
   8c384: eb14675f     	bl	0x5a6108 <.text+0x596008> @ imm = #0x519d7c
   8c388: e1a0000a     	mov	r0, r10
   8c38c: e5d75000     	ldrb	r5, [r7]
   8c390: e302a034     	movw	r10, #0x2034
   8c394: eb1468ca     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51a328
   8c398: e3550000     	cmp	r5, #0
   8c39c: e59d50c0     	ldr	r5, [sp, #0xc0]
   8c3a0: 1affffdb     	bne	0x8c314 <.text+0x7c214> @ imm = #-0x94
   8c3a4: e59f0f80     	ldr	r0, [pc, #0xf80]        @ 0x8d32c <.text+0x7d22c>
   8c3a8: e08f0000     	add	r0, pc, r0
   8c3ac: e790000a     	ldr	r0, [r0, r10]
   8c3b0: e3500001     	cmp	r0, #1
   8c3b4: 0a00000b     	beq	0x8c3e8 <.text+0x7c2e8> @ imm = #0x2c
   8c3b8: e3500000     	cmp	r0, #0
   8c3bc: 1affffd4     	bne	0x8c314 <.text+0x7c214> @ imm = #-0xb0
   8c3c0: e5940000     	ldr	r0, [r4]
   8c3c4: e2401001     	sub	r1, r0, #1
   8c3c8: e0000190     	mul	r0, r0, r1
   8c3cc: e3100001     	tst	r0, #1
   8c3d0: 0a000055     	beq	0x8c52c <.text+0x7c42c> @ imm = #0x154
   8c3d4: e5990000     	ldr	r0, [r9]
   8c3d8: e3500009     	cmp	r0, #9
   8c3dc: ca00005f     	bgt	0x8c560 <.text+0x7c460> @ imm = #0x17c
   8c3e0: ea000051     	b	0x8c52c <.text+0x7c42c> @ imm = #0x144
   8c3e4: 0058761c     	subseq	r7, r8, r12, lsl r6
   8c3e8: e5940000     	ldr	r0, [r4]
   8c3ec: e2401001     	sub	r1, r0, #1
   8c3f0: e0000190     	mul	r0, r0, r1
   8c3f4: e3100001     	tst	r0, #1
   8c3f8: 0a00005e     	beq	0x8c578 <.text+0x7c478> @ imm = #0x178
   8c3fc: e5990000     	ldr	r0, [r9]
   8c400: e3500009     	cmp	r0, #9
   8c404: ca00006a     	bgt	0x8c5b4 <.text+0x7c4b4> @ imm = #0x1a8
   8c408: ea00005a     	b	0x8c578 <.text+0x7c478> @ imm = #0x168
   8c40c: 00587621     	subseq	r7, r8, r1, lsr #12
   8c410: 005875f0     	ldrsheq	r7, [r8], #-80
   8c414: e5931004     	ldr	r1, [r3, #0x4]
   8c418: e1a00005     	mov	r0, r5
   8c41c: e1a02006     	mov	r2, r6
   8c420: e1a03008     	mov	r3, r8
   8c424: e58d7000     	str	r7, [sp]
   8c428: eb0025be     	bl	0x95b28 <.text+0x85a28> @ imm = #0x96f8
   8c42c: e59f3fec     	ldr	r3, [pc, #0xfec]        @ 0x8d420 <.text+0x7d320>
   8c430: e5941000     	ldr	r1, [r4]
   8c434: e08f3003     	add	r3, pc, r3
   8c438: e2412001     	sub	r2, r1, #1
   8c43c: e0010291     	mul	r1, r1, r2
   8c440: e3110001     	tst	r1, #1
   8c444: 0a00000c     	beq	0x8c47c <.text+0x7c37c> @ imm = #0x30
   8c448: e5991000     	ldr	r1, [r9]
   8c44c: e3510009     	cmp	r1, #9
   8c450: da000009     	ble	0x8c47c <.text+0x7c37c> @ imm = #0x24
   8c454: e5931004     	ldr	r1, [r3, #0x4]
   8c458: e1a00005     	mov	r0, r5
   8c45c: e1a02006     	mov	r2, r6
   8c460: e1a03008     	mov	r3, r8
   8c464: e58d7000     	str	r7, [sp]
   8c468: eb0025ae     	bl	0x95b28 <.text+0x85a28> @ imm = #0x96b8
   8c46c: e59f3fb0     	ldr	r3, [pc, #0xfb0]        @ 0x8d424 <.text+0x7d324>
   8c470: e08f3003     	add	r3, pc, r3
   8c474: eaffffe6     	b	0x8c414 <.text+0x7c314> @ imm = #-0x68
   8c478: 0058754c     	subseq	r7, r8, r12, asr #10
   8c47c: e3500000     	cmp	r0, #0
   8c480: 0a0000be     	beq	0x8c780 <.text+0x7c680> @ imm = #0x2f8
   8c484: e59d00a8     	ldr	r0, [sp, #0xa8]
   8c488: e5931008     	ldr	r1, [r3, #0x8]
   8c48c: e5902000     	ldr	r2, [r0]
   8c490: e1a00005     	mov	r0, r5
   8c494: eb0021b3     	bl	0x94b68 <.text+0x84a68> @ imm = #0x86cc
   8c498: e3500000     	cmp	r0, #0
   8c49c: 1a0000d6     	bne	0x8c7fc <.text+0x7c6fc> @ imm = #0x358
   8c4a0: e5940000     	ldr	r0, [r4]
   8c4a4: e2888001     	add	r8, r8, #1
   8c4a8: e2401001     	sub	r1, r0, #1
   8c4ac: e0000190     	mul	r0, r0, r1
   8c4b0: e3100001     	tst	r0, #1
   8c4b4: e5940000     	ldr	r0, [r4]
   8c4b8: e2401001     	sub	r1, r0, #1
   8c4bc: e0000190     	mul	r0, r0, r1
   8c4c0: e3100001     	tst	r0, #1
   8c4c4: 0affff68     	beq	0x8c26c <.text+0x7c16c> @ imm = #-0x260
   8c4c8: e5990000     	ldr	r0, [r9]
   8c4cc: e3500009     	cmp	r0, #9
   8c4d0: cafffff7     	bgt	0x8c4b4 <.text+0x7c3b4> @ imm = #-0x24
   8c4d4: eaffff64     	b	0x8c26c <.text+0x7c16c> @ imm = #-0x270
   8c4d8: 00587554     	subseq	r7, r8, r4, asr r5
   8c4dc: 00587508     	subseq	r7, r8, r8, lsl #10
   8c4e0: e2821008     	add	r1, r2, #8
   8c4e4: e1a00005     	mov	r0, r5
   8c4e8: eb003f42     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xfd08
   8c4ec: e5941000     	ldr	r1, [r4]
   8c4f0: e2412001     	sub	r2, r1, #1
   8c4f4: e0010291     	mul	r1, r1, r2
   8c4f8: e3110001     	tst	r1, #1
   8c4fc: 0affff7d     	beq	0x8c2f8 <.text+0x7c1f8> @ imm = #-0x20c
   8c500: e5991000     	ldr	r1, [r9]
   8c504: e59f2fe8     	ldr	r2, [pc, #0xfe8]        @ 0x8d4f4 <.text+0x7d3f4>
   8c508: e3510009     	cmp	r1, #9
   8c50c: e08f2002     	add	r2, pc, r2
   8c510: daffff78     	ble	0x8c2f8 <.text+0x7c1f8> @ imm = #-0x220
   8c514: e2821008     	add	r1, r2, #8
   8c518: e1a00005     	mov	r0, r5
   8c51c: eb003f35     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xfcd4
   8c520: e59f2ff4     	ldr	r2, [pc, #0xff4]        @ 0x8d51c <.text+0x7d41c>
   8c524: e08f2002     	add	r2, pc, r2
   8c528: eaffffec     	b	0x8c4e0 <.text+0x7c3e0> @ imm = #-0x50
   8c52c: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x8d520 <.text+0x7d420>
   8c530: e08f0000     	add	r0, pc, r0
   8c534: e2801008     	add	r1, r0, #8
   8c538: e1a00005     	mov	r0, r5
   8c53c: eb005307     	bl	0xa1160 <.text+0x91060> @ imm = #0x14c1c
   8c540: e5940000     	ldr	r0, [r4]
   8c544: e2401001     	sub	r1, r0, #1
   8c548: e0000190     	mul	r0, r0, r1
   8c54c: e3100001     	tst	r0, #1
   8c550: 0affff6f     	beq	0x8c314 <.text+0x7c214> @ imm = #-0x244
   8c554: e5990000     	ldr	r0, [r9]
   8c558: e350000a     	cmp	r0, #10
   8c55c: baffff6c     	blt	0x8c314 <.text+0x7c214> @ imm = #-0x250
   8c560: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0x8d524 <.text+0x7d424>
   8c564: e08f0000     	add	r0, pc, r0
   8c568: e2801008     	add	r1, r0, #8
   8c56c: e1a00005     	mov	r0, r5
   8c570: eb0052fa     	bl	0xa1160 <.text+0x91060> @ imm = #0x14be8
   8c574: eaffffec     	b	0x8c52c <.text+0x7c42c> @ imm = #-0x50
   8c578: e59f0fa8     	ldr	r0, [pc, #0xfa8]        @ 0x8d528 <.text+0x7d428>
   8c57c: e3021030     	movw	r1, #0x2030
   8c580: e08f0000     	add	r0, pc, r0
   8c584: e7902001     	ldr	r2, [r0, r1]
   8c588: e2801008     	add	r1, r0, #8
   8c58c: e1a00005     	mov	r0, r5
   8c590: eb004610     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0x11840
   8c594: e5940000     	ldr	r0, [r4]
   8c598: e2401001     	sub	r1, r0, #1
   8c59c: e0000190     	mul	r0, r0, r1
   8c5a0: e3100001     	tst	r0, #1
   8c5a4: 0affff5a     	beq	0x8c314 <.text+0x7c214> @ imm = #-0x298
   8c5a8: e5990000     	ldr	r0, [r9]
   8c5ac: e350000a     	cmp	r0, #10
   8c5b0: baffff57     	blt	0x8c314 <.text+0x7c214> @ imm = #-0x2a4
   8c5b4: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x8d590 <.text+0x7d490>
   8c5b8: e3021030     	movw	r1, #0x2030
   8c5bc: e08f0000     	add	r0, pc, r0
   8c5c0: e7902001     	ldr	r2, [r0, r1]
   8c5c4: e2801008     	add	r1, r0, #8
   8c5c8: e1a00005     	mov	r0, r5
   8c5cc: eb004601     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0x11804
   8c5d0: eaffffe8     	b	0x8c578 <.text+0x7c478> @ imm = #-0x60
   8c5d4: e595001c     	ldr	r0, [r5, #0x1c]
   8c5d8: ebff51dc     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x2b890
   8c5dc: e1a01000     	mov	r1, r0
   8c5e0: e59d00bc     	ldr	r0, [sp, #0xbc]
   8c5e4: ebff0fe7     	bl	0x50588 <.text+0x40488> @ imm = #-0x3c064
   8c5e8: e1a01000     	mov	r1, r0
   8c5ec: e1a00005     	mov	r0, r5
   8c5f0: eb002199     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x8664
   8c5f4: e3500000     	cmp	r0, #0
   8c5f8: 0a00001e     	beq	0x8c678 <.text+0x7c578> @ imm = #0x78
   8c5fc: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x8d5cc <.text+0x7d4cc>
   8c600: e3a07001     	mov	r7, #1
   8c604: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0x8d5d0 <.text+0x7d4d0>
   8c608: e59f2fc4     	ldr	r2, [pc, #0xfc4]        @ 0x8d5d4 <.text+0x7d4d4>
   8c60c: e08f0000     	add	r0, pc, r0
   8c610: e59f3fc0     	ldr	r3, [pc, #0xfc0]        @ 0x8d5d8 <.text+0x7d4d8>
   8c614: e08f1001     	add	r1, pc, r1
   8c618: e08f2002     	add	r2, pc, r2
   8c61c: e58d7000     	str	r7, [sp]
   8c620: e08f3003     	add	r3, pc, r3
   8c624: e58d3004     	str	r3, [sp, #0x4]
   8c628: e30132c1     	movw	r3, #0x12c1
   8c62c: eb01b6a4     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6da90
   8c630: e59d00b8     	ldr	r0, [sp, #0xb8]
   8c634: e30017da     	movw	r1, #0x7da
   8c638: ebfef596     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x429a8
   8c63c: e1a00005     	mov	r0, r5
   8c640: eafffe0f     	b	0x8be84 <.text+0x7bd84> @ imm = #-0x7c4
   8c644: e5940000     	ldr	r0, [r4]
   8c648: e2401001     	sub	r1, r0, #1
   8c64c: e0000190     	mul	r0, r0, r1
   8c650: e3100001     	tst	r0, #1
   8c654: 0a00051e     	beq	0x8dad4 <.text+0x7d9d4> @ imm = #0x1478
   8c658: e5990000     	ldr	r0, [r9]
   8c65c: e3500009     	cmp	r0, #9
   8c660: ca000548     	bgt	0x8db88 <.text+0x7da88> @ imm = #0x1520
   8c664: ea00051a     	b	0x8dad4 <.text+0x7d9d4> @ imm = #0x1468
   8c668: 0055b7ce     	subseq	r11, r5, lr, asr #15
   8c66c: 0055b7cd     	subseq	r11, r5, sp, asr #15
   8c670: 0055b7f3     	ldrsheq	r11, [r5], #-115
   8c674: 0055bd35     	subseq	r11, r5, r5, lsr sp
   8c678: e59f2fe4     	ldr	r2, [pc, #0xfe4]        @ 0x8d664 <.text+0x7d564>
   8c67c: e3020034     	movw	r0, #0x2034
   8c680: e08f2002     	add	r2, pc, r2
   8c684: e7920000     	ldr	r0, [r2, r0]
   8c688: e3500001     	cmp	r0, #1
   8c68c: 0a000054     	beq	0x8c7e4 <.text+0x7c6e4> @ imm = #0x150
   8c690: e59f7fd0     	ldr	r7, [pc, #0xfd0]        @ 0x8d668 <.text+0x7d568>
   8c694: e3500000     	cmp	r0, #0
   8c698: e08f7007     	add	r7, pc, r7
   8c69c: 1a00057c     	bne	0x8dc94 <.text+0x7db94> @ imm = #0x15f0
   8c6a0: e5940000     	ldr	r0, [r4]
   8c6a4: e2401001     	sub	r1, r0, #1
   8c6a8: e0000190     	mul	r0, r0, r1
   8c6ac: e3100001     	tst	r0, #1
   8c6b0: 0a00055c     	beq	0x8dc28 <.text+0x7db28> @ imm = #0x1570
   8c6b4: e5990000     	ldr	r0, [r9]
   8c6b8: e3500009     	cmp	r0, #9
   8c6bc: ca000569     	bgt	0x8dc68 <.text+0x7db68> @ imm = #0x15a4
   8c6c0: ea000558     	b	0x8dc28 <.text+0x7db28> @ imm = #0x1560
   8c6c4: e5940000     	ldr	r0, [r4]
   8c6c8: e59f7ff0     	ldr	r7, [pc, #0xff0]        @ 0x8d6c0 <.text+0x7d5c0>
   8c6cc: e2401001     	sub	r1, r0, #1
   8c6d0: e08f7007     	add	r7, pc, r7
   8c6d4: e0000190     	mul	r0, r0, r1
   8c6d8: e3100001     	tst	r0, #1
   8c6dc: 0a000587     	beq	0x8dd00 <.text+0x7dc00> @ imm = #0x161c
   8c6e0: e5990000     	ldr	r0, [r9]
   8c6e4: e3500009     	cmp	r0, #9
   8c6e8: ca000591     	bgt	0x8dd34 <.text+0x7dc34> @ imm = #0x1644
   8c6ec: ea000583     	b	0x8dd00 <.text+0x7dc00> @ imm = #0x160c
   8c6f0: 005852ac     	subseq	r5, r8, r12, lsr #5
   8c6f4: e2861008     	add	r1, r6, #8
   8c6f8: e1a00005     	mov	r0, r5
   8c6fc: eb003ebd     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xfaf4
   8c700: e3500000     	cmp	r0, #0
   8c704: 0afffce9     	beq	0x8bab0 <.text+0x7b9b0> @ imm = #-0xc5c
   8c708: e5940000     	ldr	r0, [r4]
   8c70c: e2401001     	sub	r1, r0, #1
   8c710: e0000190     	mul	r0, r0, r1
   8c714: e3100001     	tst	r0, #1
   8c718: 0a000642     	beq	0x8e028 <.text+0x7df28> @ imm = #0x1908
   8c71c: e5990000     	ldr	r0, [r9]
   8c720: e3500009     	cmp	r0, #9
   8c724: ca00064a     	bgt	0x8e054 <.text+0x7df54> @ imm = #0x1928
   8c728: ea00063e     	b	0x8e028 <.text+0x7df28> @ imm = #0x18f8
   8c72c: e3a00014     	mov	r0, #20
   8c730: eb020a01     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x82804
   8c734: e1a00005     	mov	r0, r5
   8c738: eb00240c     	bl	0x95770 <.text+0x85670> @ imm = #0x9030
   8c73c: e3020034     	movw	r0, #0x2034
   8c740: e7960000     	ldr	r0, [r6, r0]
   8c744: e3500001     	cmp	r0, #1
   8c748: 0a000059     	beq	0x8c8b4 <.text+0x7c7b4> @ imm = #0x164
   8c74c: e59f7fa0     	ldr	r7, [pc, #0xfa0]        @ 0x8d6f4 <.text+0x7d5f4>
   8c750: e3500000     	cmp	r0, #0
   8c754: e08f7007     	add	r7, pc, r7
   8c758: 1a000068     	bne	0x8c900 <.text+0x7c800> @ imm = #0x1a0
   8c75c: e59d00ac     	ldr	r0, [sp, #0xac]
   8c760: e3a02000     	mov	r2, #0
   8c764: e5903000     	ldr	r3, [r0]
   8c768: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x8d75c <.text+0x7d65c>
   8c76c: e08f0000     	add	r0, pc, r0
   8c770: e2801008     	add	r1, r0, #8
   8c774: e1a00005     	mov	r0, r5
   8c778: eb004d40     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x13500
   8c77c: ea000051     	b	0x8c8c8 <.text+0x7c7c8> @ imm = #0x144
   8c780: e3a00001     	mov	r0, #1
   8c784: ea000e09     	b	0x8ffb0 <.text+0x7feb0> @ imm = #0x3824
   8c788: 00585208     	subseq	r5, r8, r8, lsl #4
   8c78c: 00587260     	subseq	r7, r8, r0, ror #4
   8c790: e3a00014     	mov	r0, #20
   8c794: eb0209e8     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x827a0
   8c798: e1a00005     	mov	r0, r5
   8c79c: eb0023f3     	bl	0x95770 <.text+0x85670> @ imm = #0x8fcc
   8c7a0: e3020034     	movw	r0, #0x2034
   8c7a4: e7960000     	ldr	r0, [r6, r0]
   8c7a8: e3500001     	cmp	r0, #1
   8c7ac: 0a000087     	beq	0x8c9d0 <.text+0x7c8d0> @ imm = #0x21c
   8c7b0: e59f7ff4     	ldr	r7, [pc, #0xff4]        @ 0x8d7ac <.text+0x7d6ac>
   8c7b4: e3500000     	cmp	r0, #0
   8c7b8: e08f7007     	add	r7, pc, r7
   8c7bc: 1a000096     	bne	0x8ca1c <.text+0x7c91c> @ imm = #0x258
   8c7c0: e59d00ac     	ldr	r0, [sp, #0xac]
   8c7c4: e3a02000     	mov	r2, #0
   8c7c8: e5903000     	ldr	r3, [r0]
   8c7cc: e59f0fdc     	ldr	r0, [pc, #0xfdc]        @ 0x8d7b0 <.text+0x7d6b0>
   8c7d0: e08f0000     	add	r0, pc, r0
   8c7d4: e2801008     	add	r1, r0, #8
   8c7d8: e1a00005     	mov	r0, r5
   8c7dc: eb004d27     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x1349c
   8c7e0: ea00007f     	b	0x8c9e4 <.text+0x7c8e4> @ imm = #0x1fc
   8c7e4: e2821008     	add	r1, r2, #8
   8c7e8: e1a00005     	mov	r0, r5
   8c7ec: eb003e81     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xfa04
   8c7f0: e59f7fbc     	ldr	r7, [pc, #0xfbc]        @ 0x8d7b4 <.text+0x7d6b4>
   8c7f4: e08f7007     	add	r7, pc, r7
   8c7f8: ea000523     	b	0x8dc8c <.text+0x7db8c> @ imm = #0x148c
   8c7fc: e59f0fb4     	ldr	r0, [pc, #0xfb4]        @ 0x8d7b8 <.text+0x7d6b8>
   8c800: e3a07001     	mov	r7, #1
   8c804: e59f1fb0     	ldr	r1, [pc, #0xfb0]        @ 0x8d7bc <.text+0x7d6bc>
   8c808: e59f2fb0     	ldr	r2, [pc, #0xfb0]        @ 0x8d7c0 <.text+0x7d6c0>
   8c80c: e08f0000     	add	r0, pc, r0
   8c810: e59f3fac     	ldr	r3, [pc, #0xfac]        @ 0x8d7c4 <.text+0x7d6c4>
   8c814: e08f1001     	add	r1, pc, r1
   8c818: e08f2002     	add	r2, pc, r2
   8c81c: e58d7000     	str	r7, [sp]
   8c820: e08f3003     	add	r3, pc, r3
   8c824: e58d3004     	str	r3, [sp, #0x4]
   8c828: e301332b     	movw	r3, #0x132b
   8c82c: eb01b624     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6d890
   8c830: e30017d9     	movw	r1, #0x7d9
   8c834: ea00000d     	b	0x8c870 <.text+0x7c770> @ imm = #0x34
   8c838: e59f0f88     	ldr	r0, [pc, #0xf88]        @ 0x8d7c8 <.text+0x7d6c8>
   8c83c: e3a07001     	mov	r7, #1
   8c840: e59f1f84     	ldr	r1, [pc, #0xf84]        @ 0x8d7cc <.text+0x7d6cc>
   8c844: e59f2f84     	ldr	r2, [pc, #0xf84]        @ 0x8d7d0 <.text+0x7d6d0>
   8c848: e08f0000     	add	r0, pc, r0
   8c84c: e59f3f80     	ldr	r3, [pc, #0xf80]        @ 0x8d7d4 <.text+0x7d6d4>
   8c850: e08f1001     	add	r1, pc, r1
   8c854: e08f2002     	add	r2, pc, r2
   8c858: e58d7000     	str	r7, [sp]
   8c85c: e08f3003     	add	r3, pc, r3
   8c860: e58d3004     	str	r3, [sp, #0x4]
   8c864: e301331b     	movw	r3, #0x131b
   8c868: eb01b615     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6d854
   8c86c: e3001fa1     	movw	r1, #0xfa1
   8c870: e59d00b8     	ldr	r0, [sp, #0xb8]
   8c874: ebfef507     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x42be4
   8c878: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x8d864 <.text+0x7d764>
   8c87c: e3a07001     	mov	r7, #1
   8c880: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x8d868 <.text+0x7d768>
   8c884: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x8d86c <.text+0x7d76c>
   8c888: e08f0000     	add	r0, pc, r0
   8c88c: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x8d870 <.text+0x7d770>
   8c890: e08f1001     	add	r1, pc, r1
   8c894: e08f2002     	add	r2, pc, r2
   8c898: e58d7000     	str	r7, [sp]
   8c89c: e08f3003     	add	r3, pc, r3
   8c8a0: e58d3004     	str	r3, [sp, #0x4]
   8c8a4: e3013397     	movw	r3, #0x1397
   8c8a8: eb01b605     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6d814
   8c8ac: e1a00005     	mov	r0, r5
   8c8b0: eafffd73     	b	0x8be84 <.text+0x7bd84> @ imm = #-0xa34
   8c8b4: e2861008     	add	r1, r6, #8
   8c8b8: e1a00005     	mov	r0, r5
   8c8bc: eb003e4d     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xf934
   8c8c0: e59f7fac     	ldr	r7, [pc, #0xfac]        @ 0x8d874 <.text+0x7d774>
   8c8c4: e08f7007     	add	r7, pc, r7
   8c8c8: e5941000     	ldr	r1, [r4]
   8c8cc: e2412001     	sub	r2, r1, #1
   8c8d0: e0010291     	mul	r1, r1, r2
   8c8d4: e3110001     	tst	r1, #1
   8c8d8: e5941000     	ldr	r1, [r4]
   8c8dc: e2412001     	sub	r2, r1, #1
   8c8e0: e0010291     	mul	r1, r1, r2
   8c8e4: e3110001     	tst	r1, #1
   8c8e8: 0a000002     	beq	0x8c8f8 <.text+0x7c7f8> @ imm = #0x8
   8c8ec: e5991000     	ldr	r1, [r9]
   8c8f0: e3510009     	cmp	r1, #9
   8c8f4: cafffff7     	bgt	0x8c8d8 <.text+0x7c7d8> @ imm = #-0x24
   8c8f8: e3500000     	cmp	r0, #0
   8c8fc: 0a000015     	beq	0x8c958 <.text+0x7c858> @ imm = #0x54
   8c900: e1a00005     	mov	r0, r5
   8c904: e3a01001     	mov	r1, #1
   8c908: e3a05001     	mov	r5, #1
   8c90c: eb002288     	bl	0x95334 <.text+0x85234> @ imm = #0x8a20
   8c910: e3500000     	cmp	r0, #0
   8c914: 0a000018     	beq	0x8c97c <.text+0x7c87c> @ imm = #0x60
   8c918: e59f0fb4     	ldr	r0, [pc, #0xfb4]        @ 0x8d8d4 <.text+0x7d7d4>
   8c91c: e59f1fb4     	ldr	r1, [pc, #0xfb4]        @ 0x8d8d8 <.text+0x7d7d8>
   8c920: e59f2fb4     	ldr	r2, [pc, #0xfb4]        @ 0x8d8dc <.text+0x7d7dc>
   8c924: e08f0000     	add	r0, pc, r0
   8c928: e59f3fb0     	ldr	r3, [pc, #0xfb0]        @ 0x8d8e0 <.text+0x7d7e0>
   8c92c: e08f1001     	add	r1, pc, r1
   8c930: e08f2002     	add	r2, pc, r2
   8c934: e58d5000     	str	r5, [sp]
   8c938: e08f3003     	add	r3, pc, r3
   8c93c: e58d3004     	str	r3, [sp, #0x4]
   8c940: e301349f     	movw	r3, #0x149f
   8c944: eb01b5de     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6d778
   8c948: e59d00b8     	ldr	r0, [sp, #0xb8]
   8c94c: e3001fa1     	movw	r1, #0xfa1
   8c950: ebfef4d0     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x42cc0
   8c954: ea0018ad     	b	0x92c10 <.text+0x82b10> @ imm = #0x62b4
   8c958: e59f6ffc     	ldr	r6, [pc, #0xffc]        @ 0x8d95c <.text+0x7d85c>
   8c95c: e08f6006     	add	r6, pc, r6
   8c960: e1a00006     	mov	r0, r6
   8c964: eb1465e7     	bl	0x5a6108 <.text+0x596008> @ imm = #0x51979c
   8c968: e1a00006     	mov	r0, r6
   8c96c: e5d75000     	ldrb	r5, [r7]
   8c970: eb146753     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x519d4c
   8c974: e3550000     	cmp	r5, #0
   8c978: 0a000047     	beq	0x8ca9c <.text+0x7c99c> @ imm = #0x11c
   8c97c: e59f6fdc     	ldr	r6, [pc, #0xfdc]        @ 0x8d960 <.text+0x7d860>
   8c980: e08f6006     	add	r6, pc, r6
   8c984: e1a00006     	mov	r0, r6
   8c988: eb1465de     	bl	0x5a6108 <.text+0x596008> @ imm = #0x519778
   8c98c: e1a00006     	mov	r0, r6
   8c990: e5d75000     	ldrb	r5, [r7]
   8c994: eb14674a     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x519d28
   8c998: e3550000     	cmp	r5, #0
   8c99c: 1a001c45     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x7114
   8c9a0: e5940000     	ldr	r0, [r4]
   8c9a4: e59d50c0     	ldr	r5, [sp, #0xc0]
   8c9a8: e2401001     	sub	r1, r0, #1
   8c9ac: e0000190     	mul	r0, r0, r1
   8c9b0: e3100001     	tst	r0, #1
   8c9b4: 0a0005cd     	beq	0x8e0f0 <.text+0x7dff0> @ imm = #0x1734
   8c9b8: e5990000     	ldr	r0, [r9]
   8c9bc: e3500009     	cmp	r0, #9
   8c9c0: ca0005d4     	bgt	0x8e118 <.text+0x7e018> @ imm = #0x1750
   8c9c4: ea0005c9     	b	0x8e0f0 <.text+0x7dff0> @ imm = #0x1724
   8c9c8: 0058704c     	subseq	r7, r8, r12, asr #32
   8c9cc: 00587020     	subseq	r7, r8, r0, lsr #32
   8c9d0: e2861008     	add	r1, r6, #8
   8c9d4: e1a00005     	mov	r0, r5
   8c9d8: eb003e06     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xf818
   8c9dc: e59f7f80     	ldr	r7, [pc, #0xf80]        @ 0x8d964 <.text+0x7d864>
   8c9e0: e08f7007     	add	r7, pc, r7
   8c9e4: e5941000     	ldr	r1, [r4]
   8c9e8: e2412001     	sub	r2, r1, #1
   8c9ec: e0010291     	mul	r1, r1, r2
   8c9f0: e3110001     	tst	r1, #1
   8c9f4: e5941000     	ldr	r1, [r4]
   8c9f8: e2412001     	sub	r2, r1, #1
   8c9fc: e0010291     	mul	r1, r1, r2
   8ca00: e3110001     	tst	r1, #1
   8ca04: 0a000002     	beq	0x8ca14 <.text+0x7c914> @ imm = #0x8
   8ca08: e5991000     	ldr	r1, [r9]
   8ca0c: e3510009     	cmp	r1, #9
   8ca10: cafffff7     	bgt	0x8c9f4 <.text+0x7c8f4> @ imm = #-0x24
   8ca14: e3500000     	cmp	r0, #0
   8ca18: 0a00000d     	beq	0x8ca54 <.text+0x7c954> @ imm = #0x34
   8ca1c: e1a00005     	mov	r0, r5
   8ca20: e3a01001     	mov	r1, #1
   8ca24: eb002242     	bl	0x95334 <.text+0x85234> @ imm = #0x8908
   8ca28: e3500000     	cmp	r0, #0
   8ca2c: 0a0006c0     	beq	0x8e534 <.text+0x7e434> @ imm = #0x1b00
   8ca30: e5940000     	ldr	r0, [r4]
   8ca34: e2401001     	sub	r1, r0, #1
   8ca38: e0000190     	mul	r0, r0, r1
   8ca3c: e3100001     	tst	r0, #1
   8ca40: 0a000672     	beq	0x8e410 <.text+0x7e310> @ imm = #0x19c8
   8ca44: e5990000     	ldr	r0, [r9]
   8ca48: e3500009     	cmp	r0, #9
   8ca4c: ca000685     	bgt	0x8e468 <.text+0x7e368> @ imm = #0x1a14
   8ca50: ea00066e     	b	0x8e410 <.text+0x7e310> @ imm = #0x19b8
   8ca54: e5940000     	ldr	r0, [r4]
   8ca58: e2401001     	sub	r1, r0, #1
   8ca5c: e0000190     	mul	r0, r0, r1
   8ca60: e3100001     	tst	r0, #1
   8ca64: 0a000699     	beq	0x8e4d0 <.text+0x7e3d0> @ imm = #0x1a64
   8ca68: e5990000     	ldr	r0, [r9]
   8ca6c: e3500009     	cmp	r0, #9
   8ca70: ca0006a5     	bgt	0x8e50c <.text+0x7e40c> @ imm = #0x1a94
   8ca74: ea000695     	b	0x8e4d0 <.text+0x7e3d0> @ imm = #0x1a54
   8ca78: 00586fbc     	ldrheq	r6, [r8], #-252
   8ca7c: e3020030     	movw	r0, #0x2030
   8ca80: e7912000     	ldr	r2, [r1, r0]
   8ca84: e2811008     	add	r1, r1, #8
   8ca88: e59d00c0     	ldr	r0, [sp, #0xc0]
   8ca8c: eb0044d1     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0x11344
   8ca90: ea000582     	b	0x8e0a0 <.text+0x7dfa0> @ imm = #0x1608
   8ca94: 00584f30     	subseq	r4, r8, r0, lsr pc
   8ca98: 00586f68     	subseq	r6, r8, r8, ror #30
   8ca9c: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0x8da94 <.text+0x7d994>
   8caa0: e3020034     	movw	r0, #0x2034
   8caa4: e08f1001     	add	r1, pc, r1
   8caa8: e7910000     	ldr	r0, [r1, r0]
   8caac: e3500001     	cmp	r0, #1
   8cab0: 0a000008     	beq	0x8cad8 <.text+0x7c9d8> @ imm = #0x20
   8cab4: e3500000     	cmp	r0, #0
   8cab8: 1affffaf     	bne	0x8c97c <.text+0x7c87c> @ imm = #-0x144
   8cabc: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x8da98 <.text+0x7d998>
   8cac0: e08f0000     	add	r0, pc, r0
   8cac4: e2801008     	add	r1, r0, #8
   8cac8: e59d00c0     	ldr	r0, [sp, #0xc0]
   8cacc: eb0051a3     	bl	0xa1160 <.text+0x91060> @ imm = #0x1468c
   8cad0: eaffffa9     	b	0x8c97c <.text+0x7c87c> @ imm = #-0x15c
   8cad4: 00584eec     	subseq	r4, r8, r12, ror #29
   8cad8: e3020030     	movw	r0, #0x2030
   8cadc: e7912000     	ldr	r2, [r1, r0]
   8cae0: e2811008     	add	r1, r1, #8
   8cae4: e59d00c0     	ldr	r0, [sp, #0xc0]
   8cae8: eb0044ba     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0x112e8
   8caec: eaffffa2     	b	0x8c97c <.text+0x7c87c> @ imm = #-0x178
   8caf0: e3a00ffa     	mov	r0, #1000
   8caf4: eb020910     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x82440
   8caf8: e5940000     	ldr	r0, [r4]
   8cafc: e2401001     	sub	r1, r0, #1
   8cb00: e0000190     	mul	r0, r0, r1
   8cb04: e3100001     	tst	r0, #1
   8cb08: 0afffa2f     	beq	0x8b3cc <.text+0x7b2cc> @ imm = #-0x1744
   8cb0c: e5990000     	ldr	r0, [r9]
   8cb10: e350000a     	cmp	r0, #10
   8cb14: bafffa2c     	blt	0x8b3cc <.text+0x7b2cc> @ imm = #-0x1750
   8cb18: e3a00ffa     	mov	r0, #1000
   8cb1c: eb020906     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x82418
   8cb20: eafffff2     	b	0x8caf0 <.text+0x7c9f0> @ imm = #-0x38
   8cb24: e5940000     	ldr	r0, [r4]
   8cb28: e59da04c     	ldr	r10, [sp, #0x4c]
   8cb2c: e2401001     	sub	r1, r0, #1
   8cb30: e0020190     	mul	r2, r0, r1
   8cb34: e3a01000     	mov	r1, #0
   8cb38: e58d1178     	str	r1, [sp, #0x178]
   8cb3c: e3011049     	movw	r1, #0x1049
   8cb40: e5990000     	ldr	r0, [r9]
   8cb44: e7fa1001     	ldrb	r1, [r10, r1]!
   8cb48: e3120001     	tst	r2, #1
   8cb4c: 0a000008     	beq	0x8cb74 <.text+0x7ca74> @ imm = #0x20
   8cb50: e3500009     	cmp	r0, #9
   8cb54: da000006     	ble	0x8cb74 <.text+0x7ca74> @ imm = #0x18
   8cb58: e3a00000     	mov	r0, #0
   8cb5c: e58d0178     	str	r0, [sp, #0x178]
   8cb60: eaffffef     	b	0x8cb24 <.text+0x7ca24> @ imm = #-0x44
   8cb64: 0055b932     	subseq	r11, r5, r2, lsr r9
   8cb68: 00584e14     	subseq	r4, r8, r4, lsl lr
   8cb6c: 00584ddc     	ldrsbeq	r4, [r8], #-220
   8cb70: 00584dcc     	subseq	r4, r8, r12, asr #27
   8cb74: e3510000     	cmp	r1, #0
   8cb78: 1a001bce     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x6f38
   8cb7c: e3020048     	movw	r0, #0x2048
   8cb80: e7d60000     	ldrb	r0, [r6, r0]
   8cb84: e3500000     	cmp	r0, #0
   8cb88: 0a00016d     	beq	0x8d144 <.text+0x7d044> @ imm = #0x5b4
   8cb8c: e3000ff9     	movw	r0, #0xff9
   8cb90: ed9f9bee     	vldr	d9, [pc, #952]          @ 0x8cf50 <.text+0x7ce50>
   8cb94: e04a0000     	sub	r0, r10, r0
   8cb98: e58d003c     	str	r0, [sp, #0x3c]
   8cb9c: e3a00000     	mov	r0, #0
   8cba0: ed9fabec     	vldr	d10, [pc, #944]         @ 0x8cf58 <.text+0x7ce58>
   8cba4: e58d0048     	str	r0, [sp, #0x48]
   8cba8: ed9fbbec     	vldr	d11, [pc, #944]         @ 0x8cf60 <.text+0x7ce60>
   8cbac: e58da038     	str	r10, [sp, #0x38]
   8cbb0: e5da0000     	ldrb	r0, [r10]
   8cbb4: e59f1f10     	ldr	r1, [pc, #0xf10]        @ 0x8dacc <.text+0x7d9cc>
   8cbb8: e3500000     	cmp	r0, #0
   8cbbc: e08f1001     	add	r1, pc, r1
   8cbc0: 1a001bbc     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x6ef0
   8cbc4: e3020034     	movw	r0, #0x2034
   8cbc8: e7910000     	ldr	r0, [r1, r0]
   8cbcc: e3500001     	cmp	r0, #1
   8cbd0: 0a00000b     	beq	0x8cc04 <.text+0x7cb04> @ imm = #0x2c
   8cbd4: e59d604c     	ldr	r6, [sp, #0x4c]
   8cbd8: e3500000     	cmp	r0, #0
   8cbdc: 1a00001a     	bne	0x8cc4c <.text+0x7cb4c> @ imm = #0x68
   8cbe0: e59f0ee8     	ldr	r0, [pc, #0xee8]        @ 0x8dad0 <.text+0x7d9d0>
   8cbe4: e3a02000     	mov	r2, #0
   8cbe8: e3a03f4b     	mov	r3, #300
   8cbec: e08f0000     	add	r0, pc, r0
   8cbf0: e2801008     	add	r1, r0, #8
   8cbf4: e1a00006     	mov	r0, r6
   8cbf8: eb004c20     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x13080
   8cbfc: ea000004     	b	0x8cc14 <.text+0x7cb14> @ imm = #0x10
   8cc00: 00584d80     	subseq	r4, r8, r0, lsl #27
   8cc04: e59d604c     	ldr	r6, [sp, #0x4c]
   8cc08: e2811008     	add	r1, r1, #8
   8cc0c: e1a00006     	mov	r0, r6
   8cc10: eb003d78     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xf5e0
   8cc14: e5941000     	ldr	r1, [r4]
   8cc18: e2412001     	sub	r2, r1, #1
   8cc1c: e0010291     	mul	r1, r1, r2
   8cc20: e3110001     	tst	r1, #1
   8cc24: e5941000     	ldr	r1, [r4]
   8cc28: e2412001     	sub	r2, r1, #1
   8cc2c: e0010291     	mul	r1, r1, r2
   8cc30: e3110001     	tst	r1, #1
   8cc34: 0a000002     	beq	0x8cc44 <.text+0x7cb44> @ imm = #0x8
   8cc38: e5991000     	ldr	r1, [r9]
   8cc3c: e3510009     	cmp	r1, #9
   8cc40: cafffff7     	bgt	0x8cc24 <.text+0x7cb24> @ imm = #-0x24
   8cc44: e3500000     	cmp	r0, #0
   8cc48: 0a00002d     	beq	0x8cd04 <.text+0x7cc04> @ imm = #0xb4
   8cc4c: e1a00006     	mov	r0, r6
   8cc50: e3a01001     	mov	r1, #1
   8cc54: eb0021b6     	bl	0x95334 <.text+0x85234> @ imm = #0x86d8
   8cc58: e3500000     	cmp	r0, #0
   8cc5c: 1a00018f     	bne	0x8d2a0 <.text+0x7d1a0> @ imm = #0x63c
   8cc60: e59f6fb8     	ldr	r6, [pc, #0xfb8]        @ 0x8dc20 <.text+0x7db20>
   8cc64: e08f6006     	add	r6, pc, r6
   8cc68: e1a00006     	mov	r0, r6
   8cc6c: eb146525     	bl	0x5a6108 <.text+0x596008> @ imm = #0x519494
   8cc70: e1a00006     	mov	r0, r6
   8cc74: e5d85000     	ldrb	r5, [r8]
   8cc78: eb146691     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x519a44
   8cc7c: e59f0fa0     	ldr	r0, [pc, #0xfa0]        @ 0x8dc24 <.text+0x7db24>
   8cc80: e3550000     	cmp	r5, #0
   8cc84: e08f0000     	add	r0, pc, r0
   8cc88: 1a001b8a     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x6e28
   8cc8c: e59d604c     	ldr	r6, [sp, #0x4c]
   8cc90: e3021034     	movw	r1, #0x2034
   8cc94: ed960a3c     	vldr	s0, [r6, #240]
   8cc98: eeb88bc0     	vcvt.f64.s32	d8, s0
   8cc9c: e6907001     	ldr	r7, [r0], r1
   8cca0: e5900000     	ldr	r0, [r0]
   8cca4: e3500001     	cmp	r0, #1
   8cca8: 0a00000b     	beq	0x8ccdc <.text+0x7cbdc> @ imm = #0x2c
   8ccac: e59d50c0     	ldr	r5, [sp, #0xc0]
   8ccb0: e3500000     	cmp	r0, #0
   8ccb4: 1a000061     	bne	0x8ce40 <.text+0x7cd40> @ imm = #0x184
   8ccb8: e5940000     	ldr	r0, [r4]
   8ccbc: e2401001     	sub	r1, r0, #1
   8ccc0: e0000190     	mul	r0, r0, r1
   8ccc4: e3100001     	tst	r0, #1
   8ccc8: 0a00002b     	beq	0x8cd7c <.text+0x7cc7c> @ imm = #0xac
   8cccc: e5990000     	ldr	r0, [r9]
   8ccd0: e3500009     	cmp	r0, #9
   8ccd4: ca000037     	bgt	0x8cdb8 <.text+0x7ccb8> @ imm = #0xdc
   8ccd8: ea000027     	b	0x8cd7c <.text+0x7cc7c> @ imm = #0x9c
   8ccdc: e5940000     	ldr	r0, [r4]
   8cce0: e59d50c0     	ldr	r5, [sp, #0xc0]
   8cce4: e2401001     	sub	r1, r0, #1
   8cce8: e0000190     	mul	r0, r0, r1
   8ccec: e3100001     	tst	r0, #1
   8ccf0: 0a000038     	beq	0x8cdd8 <.text+0x7ccd8> @ imm = #0xe0
   8ccf4: e5990000     	ldr	r0, [r9]
   8ccf8: e3500009     	cmp	r0, #9
   8ccfc: ca000043     	bgt	0x8ce10 <.text+0x7cd10> @ imm = #0x10c
   8cd00: ea000034     	b	0x8cdd8 <.text+0x7ccd8> @ imm = #0xd0
   8cd04: e59f7fec     	ldr	r7, [pc, #0xfec]        @ 0x8dcf8 <.text+0x7dbf8>
   8cd08: e08f7007     	add	r7, pc, r7
   8cd0c: e1a00007     	mov	r0, r7
   8cd10: eb1464fc     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5193f0
   8cd14: e1a00007     	mov	r0, r7
   8cd18: e5d85000     	ldrb	r5, [r8]
   8cd1c: eb146668     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5199a0
   8cd20: e3550000     	cmp	r5, #0
   8cd24: 1affffcd     	bne	0x8cc60 <.text+0x7cb60> @ imm = #-0xcc
   8cd28: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x8dcfc <.text+0x7dbfc>
   8cd2c: e3020034     	movw	r0, #0x2034
   8cd30: e08f1001     	add	r1, pc, r1
   8cd34: e7910000     	ldr	r0, [r1, r0]
   8cd38: e3500001     	cmp	r0, #1
   8cd3c: 0a000007     	beq	0x8cd60 <.text+0x7cc60> @ imm = #0x1c
   8cd40: e3500000     	cmp	r0, #0
   8cd44: 1affffc5     	bne	0x8cc60 <.text+0x7cb60> @ imm = #-0xec
   8cd48: e59f0ffc     	ldr	r0, [pc, #0xffc]        @ 0x8dd4c <.text+0x7dc4c>
   8cd4c: e08f0000     	add	r0, pc, r0
   8cd50: e2801008     	add	r1, r0, #8
   8cd54: e1a00006     	mov	r0, r6
   8cd58: eb005100     	bl	0xa1160 <.text+0x91060> @ imm = #0x14400
   8cd5c: eaffffbf     	b	0x8cc60 <.text+0x7cb60> @ imm = #-0x104
   8cd60: e3020030     	movw	r0, #0x2030
   8cd64: e7912000     	ldr	r2, [r1, r0]
   8cd68: e2811008     	add	r1, r1, #8
   8cd6c: e1a00006     	mov	r0, r6
   8cd70: eb004418     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0x11060
   8cd74: eaffffb9     	b	0x8cc60 <.text+0x7cb60> @ imm = #-0x11c
   8cd78: 00584c2c     	subseq	r4, r8, r12, lsr #24
   8cd7c: e59f0fcc     	ldr	r0, [pc, #0xfcc]        @ 0x8dd50 <.text+0x7dc50>
   8cd80: eeb00b48     	vmov.f64	d0, d8
   8cd84: e3a02000     	mov	r2, #0
   8cd88: e08f0000     	add	r0, pc, r0
   8cd8c: e2801008     	add	r1, r0, #8
   8cd90: e1a00007     	mov	r0, r7
   8cd94: eb005183     	bl	0xa13a8 <.text+0x912a8> @ imm = #0x1460c
   8cd98: e5940000     	ldr	r0, [r4]
   8cd9c: e2401001     	sub	r1, r0, #1
   8cda0: e0000190     	mul	r0, r0, r1
   8cda4: e3100001     	tst	r0, #1
   8cda8: 0a000024     	beq	0x8ce40 <.text+0x7cd40> @ imm = #0x90
   8cdac: e5990000     	ldr	r0, [r9]
   8cdb0: e350000a     	cmp	r0, #10
   8cdb4: ba000021     	blt	0x8ce40 <.text+0x7cd40> @ imm = #0x84
   8cdb8: e59f0f94     	ldr	r0, [pc, #0xf94]        @ 0x8dd54 <.text+0x7dc54>
   8cdbc: eeb00b48     	vmov.f64	d0, d8
   8cdc0: e3a02000     	mov	r2, #0
   8cdc4: e08f0000     	add	r0, pc, r0
   8cdc8: e2801008     	add	r1, r0, #8
   8cdcc: e1a00007     	mov	r0, r7
   8cdd0: eb005174     	bl	0xa13a8 <.text+0x912a8> @ imm = #0x145d0
   8cdd4: eaffffe8     	b	0x8cd7c <.text+0x7cc7c> @ imm = #-0x60
   8cdd8: e59f0fe8     	ldr	r0, [pc, #0xfe8]        @ 0x8ddc8 <.text+0x7dcc8>
   8cddc: eeb00b48     	vmov.f64	d0, d8
   8cde0: e08f0000     	add	r0, pc, r0
   8cde4: e2801008     	add	r1, r0, #8
   8cde8: e1a00007     	mov	r0, r7
   8cdec: eb00448d     	bl	0x9e028 <.text+0x8df28> @ imm = #0x11234
   8cdf0: e5940000     	ldr	r0, [r4]
   8cdf4: e2401001     	sub	r1, r0, #1
   8cdf8: e0000190     	mul	r0, r0, r1
   8cdfc: e3100001     	tst	r0, #1
   8ce00: 0a00000e     	beq	0x8ce40 <.text+0x7cd40> @ imm = #0x38
   8ce04: e5990000     	ldr	r0, [r9]
   8ce08: e3500009     	cmp	r0, #9
   8ce0c: da00000b     	ble	0x8ce40 <.text+0x7cd40> @ imm = #0x2c
   8ce10: e59f0fb4     	ldr	r0, [pc, #0xfb4]        @ 0x8ddcc <.text+0x7dccc>
   8ce14: eeb00b48     	vmov.f64	d0, d8
   8ce18: e08f0000     	add	r0, pc, r0
   8ce1c: e2801008     	add	r1, r0, #8
   8ce20: e1a00007     	mov	r0, r7
   8ce24: eb00447f     	bl	0x9e028 <.text+0x8df28> @ imm = #0x111fc
   8ce28: eaffffea     	b	0x8cdd8 <.text+0x7ccd8> @ imm = #-0x58
   8ce2c: 0055b08f     	subseq	r11, r5, pc, lsl #1
   8ce30: 0055aff9     	ldrsheq	r10, [r5], #-249
   8ce34: 0055b01f     	subseq	r11, r5, pc, lsl r0
   8ce38: 0055ba50     	subseq	r11, r5, r0, asr r10
   8ce3c: 00586b88     	subseq	r6, r8, r8, lsl #23
   8ce40: e28d1f5e     	add	r1, sp, #376
   8ce44: e1a00006     	mov	r0, r6
   8ce48: ebff4341     	bl	0x5db54 <.text+0x4da54> @ imm = #-0x2f2fc
   8ce4c: e3500000     	cmp	r0, #0
   8ce50: 1a0000ee     	bne	0x8d210 <.text+0x7d110> @ imm = #0x3b8
   8ce54: e59d0178     	ldr	r0, [sp, #0x178]
   8ce58: e3a07e32     	mov	r7, #800
   8ce5c: e350003b     	cmp	r0, #59
   8ce60: ca000092     	bgt	0x8d0b0 <.text+0x7cfb0> @ imm = #0x248
   8ce64: e5960018     	ldr	r0, [r6, #0x18]
   8ce68: eb0068e7     	bl	0xa720c <.text+0x9710c> @ imm = #0x1a39c
   8ce6c: e58d0054     	str	r0, [sp, #0x54]
   8ce70: eb01c5fc     	bl	0xfe668 <.text+0xee568> @ imm = #0x717f0
   8ce74: e3500001     	cmp	r0, #1
   8ce78: e58d0050     	str	r0, [sp, #0x50]
   8ce7c: ba00005f     	blt	0x8d000 <.text+0x7cf00> @ imm = #0x17c
   8ce80: e59fcfcc     	ldr	r12, [pc, #0xfcc]       @ 0x8de54 <.text+0x7dd54>
   8ce84: eeb08b49     	vmov.f64	d8, d9
   8ce88: e3a0a000     	mov	r10, #0
   8ce8c: e3a05000     	mov	r5, #0
   8ce90: e08fc00c     	add	r12, pc, r12
   8ce94: ea00000b     	b	0x8cec8 <.text+0x7cdc8> @ imm = #0x2c
   8ce98: 0055b02b     	subseq	r11, r5, r11, lsr #32
   8ce9c: 0055af95     	<unknown>
   8cea0: 0055afbb     	ldrheq	r10, [r5], #-251
   8cea4: 0055b90b     	subseq	r11, r5, r11, lsl #18
   8cea8: 00584ae8     	subseq	r4, r8, r8, ror #21
   8ceac: 0055afc4     	subseq	r10, r5, r4, asr #31
   8ceb0: e59fcfa0     	ldr	r12, [pc, #0xfa0]       @ 0x8de58 <.text+0x7dd58>
   8ceb4: e08fc00c     	add	r12, pc, r12
   8ceb8: e59d0050     	ldr	r0, [sp, #0x50]
   8cebc: e28aa001     	add	r10, r10, #1
   8cec0: e15a0000     	cmp	r10, r0
   8cec4: 0a000040     	beq	0x8cfcc <.text+0x7cecc> @ imm = #0x100
   8cec8: e5960230     	ldr	r0, [r6, #0x230]
   8cecc: e020079a     	mla	r0, r10, r7, r0
   8ced0: e59c8020     	ldr	r8, [r12, #0x20]
   8ced4: ebff283c     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x35f10
   8ced8: e3500000     	cmp	r0, #0
   8cedc: 0afffff3     	beq	0x8ceb0 <.text+0x7cdb0> @ imm = #-0x34
   8cee0: e5940000     	ldr	r0, [r4]
   8cee4: e2401001     	sub	r1, r0, #1
   8cee8: e0000190     	mul	r0, r0, r1
   8ceec: e3100001     	tst	r0, #1
   8cef0: e59d0054     	ldr	r0, [sp, #0x54]
   8cef4: e5900010     	ldr	r0, [r0, #0x10]
   8cef8: ee000a10     	vmov	s0, r0
   8cefc: eeb80bc0     	vcvt.f64.s32	d0, s0
   8cf00: e5941000     	ldr	r1, [r4]
   8cf04: e2412001     	sub	r2, r1, #1
   8cf08: e0010291     	mul	r1, r1, r2
   8cf0c: e3110001     	tst	r1, #1
   8cf10: 0a000002     	beq	0x8cf20 <.text+0x7ce20> @ imm = #0x8
   8cf14: e5991000     	ldr	r1, [r9]
   8cf18: e3510009     	cmp	r1, #9
   8cf1c: cafffff3     	bgt	0x8cef0 <.text+0x7cdf0> @ imm = #-0x34
   8cf20: ee388b00     	vadd.f64	d8, d8, d0
   8cf24: e59fcfb4     	ldr	r12, [pc, #0xfb4]       @ 0x8dee0 <.text+0x7dde0>
   8cf28: e3500001     	cmp	r0, #1
   8cf2c: e08fc00c     	add	r12, pc, r12
   8cf30: baffffe0     	blt	0x8ceb8 <.text+0x7cdb8> @ imm = #-0x80
   8cf34: e08a110a     	add	r1, r10, r10, lsl #2
   8cf38: e3a02000     	mov	r2, #0
   8cf3c: e0881181     	add	r1, r8, r1, lsl #3
   8cf40: e5911020     	ldr	r1, [r1, #0x20]
   8cf44: e2811030     	add	r1, r1, #48
   8cf48: ea00000c     	b	0x8cf80 <.text+0x7ce80> @ imm = #0x30
   8cf4c: e320f000     	nop
		...
   8cf5c: 40590000     	subsmi	r0, r9, r0
   8cf60: 00000000     	andeq	r0, r0, r0
   8cf64: 40540000     	subsmi	r0, r4, r0
   8cf68: e2233001     	eor	r3, r3, #1
   8cf6c: e2822001     	add	r2, r2, #1
   8cf70: e0855003     	add	r5, r5, r3
   8cf74: e2811038     	add	r1, r1, #56
   8cf78: e2500001     	subs	r0, r0, #1
   8cf7c: 0a00000d     	beq	0x8cfb8 <.text+0x7ceb8> @ imm = #0x34
   8cf80: e5943000     	ldr	r3, [r4]
   8cf84: e2436001     	sub	r6, r3, #1
   8cf88: e0030693     	mul	r3, r3, r6
   8cf8c: e3130001     	tst	r3, #1
   8cf90: e5946000     	ldr	r6, [r4]
   8cf94: e5d13000     	ldrb	r3, [r1]
   8cf98: e2467001     	sub	r7, r6, #1
   8cf9c: e0070796     	mul	r7, r6, r7
   8cfa0: e3170001     	tst	r7, #1
   8cfa4: 0affffef     	beq	0x8cf68 <.text+0x7ce68> @ imm = #-0x44
   8cfa8: e5997000     	ldr	r7, [r9]
   8cfac: e3570009     	cmp	r7, #9
   8cfb0: cafffff6     	bgt	0x8cf90 <.text+0x7ce90> @ imm = #-0x28
   8cfb4: eaffffeb     	b	0x8cf68 <.text+0x7ce68> @ imm = #-0x54
   8cfb8: e59d604c     	ldr	r6, [sp, #0x4c]
   8cfbc: e3a07e32     	mov	r7, #800
   8cfc0: eaffffbc     	b	0x8ceb8 <.text+0x7cdb8> @ imm = #-0x110
   8cfc4: 0055aec0     	subseq	r10, r5, r0, asr #29
   8cfc8: 0055b807     	subseq	r11, r5, r7, lsl #16
   8cfcc: eeb58b40     	vcmp.f64	d8, #0
   8cfd0: e59f8fa0     	ldr	r8, [pc, #0xfa0]        @ 0x8df78 <.text+0x7de78>
   8cfd4: e59da038     	ldr	r10, [sp, #0x38]
   8cfd8: e08f8008     	add	r8, pc, r8
   8cfdc: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8cfe0: 0a000006     	beq	0x8d000 <.text+0x7cf00> @ imm = #0x18
   8cfe4: ee005a10     	vmov	s0, r5
   8cfe8: eeb80bc0     	vcvt.f64.s32	d0, s0
   8cfec: ee800b08     	vdiv.f64	d0, d0, d8
   8cff0: ee200b0a     	vmul.f64	d0, d0, d10
   8cff4: eeb40bcb     	vcmpe.f64	d0, d11
   8cff8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8cffc: 5a00002b     	bpl	0x8d0b0 <.text+0x7cfb0> @ imm = #0xac
   8d000: e5940000     	ldr	r0, [r4]
   8d004: e2401001     	sub	r1, r0, #1
   8d008: e0000190     	mul	r0, r0, r1
   8d00c: e3100001     	tst	r0, #1
   8d010: 0a000002     	beq	0x8d020 <.text+0x7cf20> @ imm = #0x8
   8d014: e5990000     	ldr	r0, [r9]
   8d018: e3500009     	cmp	r0, #9
   8d01c: ca00000b     	bgt	0x8d050 <.text+0x7cf50> @ imm = #0x2c
   8d020: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x8e00c <.text+0x7df0c>
   8d024: e08f0000     	add	r0, pc, r0
   8d028: e5905008     	ldr	r5, [r0, #0x8]
   8d02c: eb01d691     	bl	0x102a78 <.text+0xf2978> @ imm = #0x75a44
   8d030: e5941000     	ldr	r1, [r4]
   8d034: e2412001     	sub	r2, r1, #1
   8d038: e0010291     	mul	r1, r1, r2
   8d03c: e3110001     	tst	r1, #1
   8d040: 0a000008     	beq	0x8d068 <.text+0x7cf68> @ imm = #0x20
   8d044: e5991000     	ldr	r1, [r9]
   8d048: e3510009     	cmp	r1, #9
   8d04c: da000005     	ble	0x8d068 <.text+0x7cf68> @ imm = #0x14
   8d050: eb01d688     	bl	0x102a78 <.text+0xf2978> @ imm = #0x75a20
   8d054: eafffff1     	b	0x8d020 <.text+0x7cf20> @ imm = #-0x3c
   8d058: 00584948     	subseq	r4, r8, r8, asr #18
   8d05c: 00584928     	subseq	r4, r8, r8, lsr #18
   8d060: 00536483     	subseq	r6, r3, r3, lsl #9
   8d064: 0055ae7e     	subseq	r10, r5, lr, ror lr
   8d068: e1550000     	cmp	r5, r0
   8d06c: aa00000f     	bge	0x8d0b0 <.text+0x7cfb0> @ imm = #0x3c
   8d070: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x8e064 <.text+0x7df64>
   8d074: e08f0000     	add	r0, pc, r0
   8d078: e5900008     	ldr	r0, [r0, #0x8]
   8d07c: e2801f4b     	add	r1, r0, #300
   8d080: e59d003c     	ldr	r0, [sp, #0x3c]
   8d084: ebff0d3f     	bl	0x50588 <.text+0x40488> @ imm = #-0x3cb04
   8d088: e1a01000     	mov	r1, r0
   8d08c: e1a00006     	mov	r0, r6
   8d090: eb001ef1     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x7bc4
   8d094: e3500000     	cmp	r0, #0
   8d098: 1a00006e     	bne	0x8d258 <.text+0x7d158> @ imm = #0x1b8
   8d09c: e59d0048     	ldr	r0, [sp, #0x48]
   8d0a0: e2800001     	add	r0, r0, #1
   8d0a4: e58d0048     	str	r0, [sp, #0x48]
   8d0a8: e3500003     	cmp	r0, #3
   8d0ac: 1afffebf     	bne	0x8cbb0 <.text+0x7cab0> @ imm = #-0x504
   8d0b0: eb01c56c     	bl	0xfe668 <.text+0xee568> @ imm = #0x715b0
   8d0b4: e3500001     	cmp	r0, #1
   8d0b8: ba00004c     	blt	0x8d1f0 <.text+0x7d0f0> @ imm = #0x130
   8d0bc: e59f2fd8     	ldr	r2, [pc, #0xfd8]        @ 0x8e09c <.text+0x7df9c>
   8d0c0: e1a06000     	mov	r6, r0
   8d0c4: ed1f8b5f     	vldr	d8, [pc, #-380]         @ 0x8cf50 <.text+0x7ce50>
   8d0c8: e3a05010     	mov	r5, #16
   8d0cc: e08f2002     	add	r2, pc, r2
   8d0d0: e3a07000     	mov	r7, #0
   8d0d4: e3a08000     	mov	r8, #0
   8d0d8: ea000008     	b	0x8d100 <.text+0x7d000> @ imm = #0x20
   8d0dc: 0055b1fc     	ldrsheq	r11, [r5], #-28
   8d0e0: 0055b764     	subseq	r11, r5, r4, ror #14
   8d0e4: 0055b1dd     	ldrsbeq	r11, [r5], #-29
   8d0e8: e59f2ffc     	ldr	r2, [pc, #0xffc]        @ 0x8e0ec <.text+0x7dfec>
   8d0ec: e2877e32     	add	r7, r7, #800
   8d0f0: e2566001     	subs	r6, r6, #1
   8d0f4: e2855028     	add	r5, r5, #40
   8d0f8: e08f2002     	add	r2, pc, r2
   8d0fc: 0a000028     	beq	0x8d1a4 <.text+0x7d0a4> @ imm = #0xa0
   8d100: e59d004c     	ldr	r0, [sp, #0x4c]
   8d104: e592a020     	ldr	r10, [r2, #0x20]
   8d108: e5900230     	ldr	r0, [r0, #0x230]
   8d10c: e0800007     	add	r0, r0, r7
   8d110: ebff27ad     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3614c
   8d114: e3500000     	cmp	r0, #0
   8d118: 0afffff2     	beq	0x8d0e8 <.text+0x7cfe8> @ imm = #-0x38
   8d11c: e08a0005     	add	r0, r10, r5
   8d120: e2888001     	add	r8, r8, #1
   8d124: ed900b00     	vldr	d0, [r0]
   8d128: ee388b00     	vadd.f64	d8, d8, d0
   8d12c: eaffffed     	b	0x8d0e8 <.text+0x7cfe8> @ imm = #-0x4c
   8d130: 0055b0e8     	subseq	r11, r5, r8, ror #1
   8d134: 0055b0e5     	subseq	r11, r5, r5, ror #1
   8d138: 0055b0c7     	subseq	r11, r5, r7, asr #1
   8d13c: 0055b700     	subseq	r11, r5, r0, lsl #14
   8d140: 0055b701     	subseq	r11, r5, r1, lsl #14
   8d144: e59d00a8     	ldr	r0, [sp, #0xa8]
   8d148: e5961008     	ldr	r1, [r6, #0x8]
   8d14c: e59d604c     	ldr	r6, [sp, #0x4c]
   8d150: e5902000     	ldr	r2, [r0]
   8d154: e1a00006     	mov	r0, r6
   8d158: eb001e82     	bl	0x94b68 <.text+0x84a68> @ imm = #0x7a08
   8d15c: e3500000     	cmp	r0, #0
   8d160: 0a000017     	beq	0x8d1c4 <.text+0x7d0c4> @ imm = #0x5c
   8d164: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x8e134 <.text+0x7e034>
   8d168: e3a07001     	mov	r7, #1
   8d16c: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0x8e138 <.text+0x7e038>
   8d170: e59f2fc4     	ldr	r2, [pc, #0xfc4]        @ 0x8e13c <.text+0x7e03c>
   8d174: e08f0000     	add	r0, pc, r0
   8d178: e59f3fc0     	ldr	r3, [pc, #0xfc0]        @ 0x8e140 <.text+0x7e040>
   8d17c: e08f1001     	add	r1, pc, r1
   8d180: e08f2002     	add	r2, pc, r2
   8d184: e58d7000     	str	r7, [sp]
   8d188: e08f3003     	add	r3, pc, r3
   8d18c: e58d3004     	str	r3, [sp, #0x4]
   8d190: e30131fa     	movw	r3, #0x11fa
   8d194: eb01b3ca     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6cf28
   8d198: e30017d9     	movw	r1, #0x7d9
   8d19c: ea00004d     	b	0x8d2d8 <.text+0x7d1d8> @ imm = #0x134
   8d1a0: 0055ada2     	subseq	r10, r5, r2, lsr #27
   8d1a4: e3580001     	cmp	r8, #1
   8d1a8: ba000060     	blt	0x8d330 <.text+0x7d230> @ imm = #0x180
   8d1ac: ee008a10     	vmov	s0, r8
   8d1b0: eeb80bc0     	vcvt.f64.s32	d0, s0
   8d1b4: ee880b00     	vdiv.f64	d0, d8, d0
   8d1b8: ea00005d     	b	0x8d334 <.text+0x7d234> @ imm = #0x174
   8d1bc: 0055b683     	subseq	r11, r5, r3, lsl #13
   8d1c0: 0058682c     	subseq	r6, r8, r12, lsr #16
   8d1c4: e5940000     	ldr	r0, [r4]
   8d1c8: e59f7fd4     	ldr	r7, [pc, #0xfd4]        @ 0x8e1a4 <.text+0x7e0a4>
   8d1cc: e2401001     	sub	r1, r0, #1
   8d1d0: e08f7007     	add	r7, pc, r7
   8d1d4: e0000190     	mul	r0, r0, r1
   8d1d8: e3100001     	tst	r0, #1
   8d1dc: 0a000508     	beq	0x8e604 <.text+0x7e504> @ imm = #0x1420
   8d1e0: e5990000     	ldr	r0, [r9]
   8d1e4: e3500009     	cmp	r0, #9
   8d1e8: ca000510     	bgt	0x8e630 <.text+0x7e530> @ imm = #0x1440
   8d1ec: ea000504     	b	0x8e604 <.text+0x7e504> @ imm = #0x1410
   8d1f0: e59f2ff0     	ldr	r2, [pc, #0xff0]        @ 0x8e1e8 <.text+0x7e0e8>
   8d1f4: ed1f0bab     	vldr	d0, [pc, #-684]         @ 0x8cf50 <.text+0x7ce50>
   8d1f8: e08f2002     	add	r2, pc, r2
   8d1fc: ea00004c     	b	0x8d334 <.text+0x7d234> @ imm = #0x130
   8d200: 0055acc3     	subseq	r10, r5, r3, asr #25
   8d204: 0055ac2d     	subseq	r10, r5, sp, lsr #24
   8d208: 0055ac53     	subseq	r10, r5, r3, asr r12
   8d20c: 0055b66e     	subseq	r11, r5, lr, ror #12
   8d210: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x8e1ec <.text+0x7e0ec>
   8d214: e3a07001     	mov	r7, #1
   8d218: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x8e1f0 <.text+0x7e0f0>
   8d21c: e59f2fd0     	ldr	r2, [pc, #0xfd0]        @ 0x8e1f4 <.text+0x7e0f4>
   8d220: e08f0000     	add	r0, pc, r0
   8d224: e59f3fcc     	ldr	r3, [pc, #0xfcc]        @ 0x8e1f8 <.text+0x7e0f8>
   8d228: e08f1001     	add	r1, pc, r1
   8d22c: e08f2002     	add	r2, pc, r2
   8d230: e58d7000     	str	r7, [sp]
   8d234: e08f3003     	add	r3, pc, r3
   8d238: e58d3004     	str	r3, [sp, #0x4]
   8d23c: e3013217     	movw	r3, #0x1217
   8d240: eb01b39f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ce7c
   8d244: e3001bbc     	movw	r1, #0xbbc
   8d248: ea000023     	b	0x8d2dc <.text+0x7d1dc> @ imm = #0x8c
   8d24c: 005867c8     	subseq	r6, r8, r8, asr #15
   8d250: 00584764     	subseq	r4, r8, r4, ror #14
   8d254: 00584754     	subseq	r4, r8, r4, asr r7
   8d258: e59f0f9c     	ldr	r0, [pc, #0xf9c]        @ 0x8e1fc <.text+0x7e0fc>
   8d25c: e3a07001     	mov	r7, #1
   8d260: e59f1f98     	ldr	r1, [pc, #0xf98]        @ 0x8e200 <.text+0x7e100>
   8d264: e59f2f98     	ldr	r2, [pc, #0xf98]        @ 0x8e204 <.text+0x7e104>
   8d268: e08f0000     	add	r0, pc, r0
   8d26c: e59f3f94     	ldr	r3, [pc, #0xf94]        @ 0x8e208 <.text+0x7e108>
   8d270: e08f1001     	add	r1, pc, r1
   8d274: e08f2002     	add	r2, pc, r2
   8d278: e58d7000     	str	r7, [sp]
   8d27c: e08f3003     	add	r3, pc, r3
   8d280: e58d3004     	str	r3, [sp, #0x4]
   8d284: e3013221     	movw	r3, #0x1221
   8d288: eb01b38d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ce34
   8d28c: e30017da     	movw	r1, #0x7da
   8d290: ea000010     	b	0x8d2d8 <.text+0x7d1d8> @ imm = #0x40
   8d294: 00586790     	<unknown>
   8d298: 00586758     	subseq	r6, r8, r8, asr r7
   8d29c: 00586704     	subseq	r6, r8, r4, lsl #14
   8d2a0: e59f0f64     	ldr	r0, [pc, #0xf64]        @ 0x8e20c <.text+0x7e10c>
   8d2a4: e3a07001     	mov	r7, #1
   8d2a8: e59f1f60     	ldr	r1, [pc, #0xf60]        @ 0x8e210 <.text+0x7e110>
   8d2ac: e59f2f60     	ldr	r2, [pc, #0xf60]        @ 0x8e214 <.text+0x7e114>
   8d2b0: e08f0000     	add	r0, pc, r0
   8d2b4: e59f3f5c     	ldr	r3, [pc, #0xf5c]        @ 0x8e218 <.text+0x7e118>
   8d2b8: e08f1001     	add	r1, pc, r1
   8d2bc: e08f2002     	add	r2, pc, r2
   8d2c0: e58d7000     	str	r7, [sp]
   8d2c4: e08f3003     	add	r3, pc, r3
   8d2c8: e58d3004     	str	r3, [sp, #0x4]
   8d2cc: e301320c     	movw	r3, #0x120c
   8d2d0: eb01b37b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6cdec
   8d2d4: e3001fa1     	movw	r1, #0xfa1
   8d2d8: e59d50c0     	ldr	r5, [sp, #0xc0]
   8d2dc: e30100b4     	movw	r0, #0x10b4
   8d2e0: e0860000     	add	r0, r6, r0
   8d2e4: ebfef26b     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x43654
   8d2e8: e59f6f2c     	ldr	r6, [pc, #0xf2c]        @ 0x8e21c <.text+0x7e11c>
   8d2ec: e08f6006     	add	r6, pc, r6
   8d2f0: e59f0f28     	ldr	r0, [pc, #0xf28]        @ 0x8e220 <.text+0x7e120>
   8d2f4: e3a07001     	mov	r7, #1
   8d2f8: e59f1f24     	ldr	r1, [pc, #0xf24]        @ 0x8e224 <.text+0x7e124>
   8d2fc: e59f2f24     	ldr	r2, [pc, #0xf24]        @ 0x8e228 <.text+0x7e128>
   8d300: e08f0000     	add	r0, pc, r0
   8d304: e59f3f20     	ldr	r3, [pc, #0xf20]        @ 0x8e22c <.text+0x7e12c>
   8d308: e08f1001     	add	r1, pc, r1
   8d30c: e08f2002     	add	r2, pc, r2
   8d310: e58d7000     	str	r7, [sp]
   8d314: e08f3003     	add	r3, pc, r3
   8d318: e58d3004     	str	r3, [sp, #0x4]
   8d31c: e301328f     	movw	r3, #0x128f
   8d320: ea0004c6     	b	0x8e640 <.text+0x7e540> @ imm = #0x1318
   8d324: 0058468c     	subseq	r4, r8, r12, lsl #13
   8d328: 005866a0     	subseq	r6, r8, r0, lsr #13
   8d32c: 00584620     	subseq	r4, r8, r0, lsr #12
   8d330: ed1f0bfa     	vldr	d0, [pc, #-1000]        @ 0x8cf50 <.text+0x7ce50>
   8d334: e3020038     	movw	r0, #0x2038
   8d338: e59d604c     	ldr	r6, [sp, #0x4c]
   8d33c: e0820000     	add	r0, r2, r0
   8d340: e24b1f56     	sub	r1, r11, #344
   8d344: e3a08000     	mov	r8, #0
   8d348: e1a05002     	mov	r5, r2
   8d34c: ed800b00     	vstr	d0, [r0]
   8d350: e1a00006     	mov	r0, r6
   8d354: e50b8148     	str	r8, [r11, #-0x148]
   8d358: e50b814c     	str	r8, [r11, #-0x14c]
   8d35c: e50b8150     	str	r8, [r11, #-0x150]
   8d360: e50b8154     	str	r8, [r11, #-0x154]
   8d364: e50b8158     	str	r8, [r11, #-0x158]
   8d368: ebffd3b3     	bl	0x8223c <.text+0x7213c> @ imm = #-0xb134
   8d36c: e5960018     	ldr	r0, [r6, #0x18]
   8d370: e5957004     	ldr	r7, [r5, #0x4]
   8d374: eb0067a4     	bl	0xa720c <.text+0x9710c> @ imm = #0x19e90
   8d378: e1a06000     	mov	r6, r0
   8d37c: eb01c4b9     	bl	0xfe668 <.text+0xee568> @ imm = #0x712e4
   8d380: e597500c     	ldr	r5, [r7, #0xc]
   8d384: e3500001     	cmp	r0, #1
   8d388: e5971010     	ldr	r1, [r7, #0x10]
   8d38c: e50b5150     	str	r5, [r11, #-0x150]
   8d390: e50b1154     	str	r1, [r11, #-0x154]
   8d394: ba000023     	blt	0x8d428 <.text+0x7d328> @ imm = #0x8c
   8d398: e3a0e000     	mov	lr, #0
   8d39c: e51bc14c     	ldr	r12, [r11, #-0x14c]
   8d3a0: e08e308e     	add	r3, lr, lr, lsl #1
   8d3a4: e78c5103     	str	r5, [r12, r3, lsl #2]
   8d3a8: e5965010     	ldr	r5, [r6, #0x10]
   8d3ac: e3550001     	cmp	r5, #1
   8d3b0: ba000015     	blt	0x8d40c <.text+0x7d30c> @ imm = #0x54
   8d3b4: e5945000     	ldr	r5, [r4]
   8d3b8: e2452001     	sub	r2, r5, #1
   8d3bc: e0020295     	mul	r2, r5, r2
   8d3c0: e3120001     	tst	r2, #1
   8d3c4: e5942000     	ldr	r2, [r4]
   8d3c8: e2425001     	sub	r5, r2, #1
   8d3cc: e0020592     	mul	r2, r2, r5
   8d3d0: e3120001     	tst	r2, #1
   8d3d4: 0a000002     	beq	0x8d3e4 <.text+0x7d2e4> @ imm = #0x8
   8d3d8: e5992000     	ldr	r2, [r9]
   8d3dc: e3520009     	cmp	r2, #9
   8d3e0: cafffff7     	bgt	0x8d3c4 <.text+0x7d2c4> @ imm = #-0x24
   8d3e4: e08c2103     	add	r2, r12, r3, lsl #2
   8d3e8: e3a03000     	mov	r3, #0
   8d3ec: e2822008     	add	r2, r2, #8
   8d3f0: e5925000     	ldr	r5, [r2]
   8d3f4: e597100c     	ldr	r1, [r7, #0xc]
   8d3f8: e7851103     	str	r1, [r5, r3, lsl #2]
   8d3fc: e2833001     	add	r3, r3, #1
   8d400: e5961010     	ldr	r1, [r6, #0x10]
   8d404: e1530001     	cmp	r3, r1
   8d408: bafffff8     	blt	0x8d3f0 <.text+0x7d2f0> @ imm = #-0x20
   8d40c: e28ee001     	add	lr, lr, #1
   8d410: e15e0000     	cmp	lr, r0
   8d414: 0a000003     	beq	0x8d428 <.text+0x7d328> @ imm = #0xc
   8d418: e597500c     	ldr	r5, [r7, #0xc]
   8d41c: eaffffde     	b	0x8d39c <.text+0x7d29c> @ imm = #-0x88
   8d420: 00584594     	<unknown>
   8d424: 00584558     	subseq	r4, r8, r8, asr r5
   8d428: e59d604c     	ldr	r6, [sp, #0x4c]
   8d42c: e24b1f56     	sub	r1, r11, #344
   8d430: e1a00006     	mov	r0, r6
   8d434: ebffe5b6     	bl	0x86b14 <.text+0x76a14> @ imm = #-0x6928
   8d438: e5991000     	ldr	r1, [r9]
   8d43c: e351000a     	cmp	r1, #10
   8d440: b3008001     	movwlt	r8, #0x1
   8d444: e3500000     	cmp	r0, #0
   8d448: 0a00000a     	beq	0x8d478 <.text+0x7d378> @ imm = #0x28
   8d44c: e5940000     	ldr	r0, [r4]
   8d450: e59d50c0     	ldr	r5, [sp, #0xc0]
   8d454: e2401001     	sub	r1, r0, #1
   8d458: e59f6fac     	ldr	r6, [pc, #0xfac]        @ 0x8e40c <.text+0x7e30c>
   8d45c: e0000190     	mul	r0, r0, r1
   8d460: e3a01001     	mov	r1, #1
   8d464: e08f6006     	add	r6, pc, r6
   8d468: e1c10000     	bic	r0, r1, r0
   8d46c: e1900008     	orrs	r0, r0, r8
   8d470: 0a000494     	beq	0x8e6c8 <.text+0x7e5c8> @ imm = #0x1250
   8d474: ea000479     	b	0x8e660 <.text+0x7e560> @ imm = #0x11e4
   8d478: e5940000     	ldr	r0, [r4]
   8d47c: e51b714c     	ldr	r7, [r11, #-0x14c]
   8d480: e2401001     	sub	r1, r0, #1
   8d484: e0000190     	mul	r0, r0, r1
   8d488: e3100001     	tst	r0, #1
   8d48c: 0a000002     	beq	0x8d49c <.text+0x7d39c> @ imm = #0x8
   8d490: e5990000     	ldr	r0, [r9]
   8d494: e3500009     	cmp	r0, #9
   8d498: cafffff6     	bgt	0x8d478 <.text+0x7d378> @ imm = #-0x28
   8d49c: e59f3ffc     	ldr	r3, [pc, #0xffc]        @ 0x8e4a0 <.text+0x7e3a0>
   8d4a0: e3570000     	cmp	r7, #0
   8d4a4: e08f3003     	add	r3, pc, r3
   8d4a8: 0a0004c8     	beq	0x8e7d0 <.text+0x7e6d0> @ imm = #0x1320
   8d4ac: e5940000     	ldr	r0, [r4]
   8d4b0: e2401001     	sub	r1, r0, #1
   8d4b4: e0000190     	mul	r0, r0, r1
   8d4b8: e3100001     	tst	r0, #1
   8d4bc: e5940000     	ldr	r0, [r4]
   8d4c0: e51b5148     	ldr	r5, [r11, #-0x148]
   8d4c4: e2401001     	sub	r1, r0, #1
   8d4c8: e0000190     	mul	r0, r0, r1
   8d4cc: e3100001     	tst	r0, #1
   8d4d0: 0a000002     	beq	0x8d4e0 <.text+0x7d3e0> @ imm = #0x8
   8d4d4: e5990000     	ldr	r0, [r9]
   8d4d8: e3500009     	cmp	r0, #9
   8d4dc: cafffff6     	bgt	0x8d4bc <.text+0x7d3bc> @ imm = #-0x28
   8d4e0: e3550001     	cmp	r5, #1
   8d4e4: ba000020     	blt	0x8d56c <.text+0x7d46c> @ imm = #0x80
   8d4e8: e2876008     	add	r6, r7, #8
   8d4ec: e3a07000     	mov	r7, #0
   8d4f0: ea000003     	b	0x8d504 <.text+0x7d404> @ imm = #0xc
   8d4f4: 005844bc     	ldrheq	r4, [r8], #-76
   8d4f8: e286600c     	add	r6, r6, #12
   8d4fc: e2555001     	subs	r5, r5, #1
   8d500: 0a000009     	beq	0x8d52c <.text+0x7d42c> @ imm = #0x24
   8d504: e5960000     	ldr	r0, [r6]
   8d508: e3500000     	cmp	r0, #0
   8d50c: 0afffff9     	beq	0x8d4f8 <.text+0x7d3f8> @ imm = #-0x1c
   8d510: eb1419dd     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x506774
   8d514: e5867000     	str	r7, [r6]
   8d518: eafffff6     	b	0x8d4f8 <.text+0x7d3f8> @ imm = #-0x28
   8d51c: 005844a4     	subseq	r4, r8, r4, lsr #9
   8d520: 00584498     	<unknown>
   8d524: 00584464     	subseq	r4, r8, r4, ror #8
   8d528: 00584448     	subseq	r4, r8, r8, asr #8
   8d52c: e5940000     	ldr	r0, [r4]
   8d530: e59d604c     	ldr	r6, [sp, #0x4c]
   8d534: e2401001     	sub	r1, r0, #1
   8d538: e0000190     	mul	r0, r0, r1
   8d53c: e3100001     	tst	r0, #1
   8d540: e5940000     	ldr	r0, [r4]
   8d544: e51b714c     	ldr	r7, [r11, #-0x14c]
   8d548: e2401001     	sub	r1, r0, #1
   8d54c: e0000190     	mul	r0, r0, r1
   8d550: e3100001     	tst	r0, #1
   8d554: 0a000002     	beq	0x8d564 <.text+0x7d464> @ imm = #0x8
   8d558: e5990000     	ldr	r0, [r9]
   8d55c: e3500009     	cmp	r0, #9
   8d560: cafffff6     	bgt	0x8d540 <.text+0x7d440> @ imm = #-0x28
   8d564: e3570000     	cmp	r7, #0
   8d568: 0a00047e     	beq	0x8e768 <.text+0x7e668> @ imm = #0x11f8
   8d56c: e5940000     	ldr	r0, [r4]
   8d570: e2401001     	sub	r1, r0, #1
   8d574: e0000190     	mul	r0, r0, r1
   8d578: e3100001     	tst	r0, #1
   8d57c: 0a000466     	beq	0x8e71c <.text+0x7e61c> @ imm = #0x1198
   8d580: e5990000     	ldr	r0, [r9]
   8d584: e3500009     	cmp	r0, #9
   8d588: ca00046f     	bgt	0x8e74c <.text+0x7e64c> @ imm = #0x11bc
   8d58c: ea000462     	b	0x8e71c <.text+0x7e61c> @ imm = #0x1188
   8d590: 0058440c     	subseq	r4, r8, r12, lsl #8
   8d594: eb01c433     	bl	0xfe668 <.text+0xee568> @ imm = #0x710cc
   8d598: e1a0a000     	mov	r10, r0
   8d59c: e5940000     	ldr	r0, [r4]
   8d5a0: e2401001     	sub	r1, r0, #1
   8d5a4: e0010190     	mul	r1, r0, r1
   8d5a8: e59d00c4     	ldr	r0, [sp, #0xc4]
   8d5ac: e5d00061     	ldrb	r0, [r0, #0x61]
   8d5b0: e3110001     	tst	r1, #1
   8d5b4: 0a000008     	beq	0x8d5dc <.text+0x7d4dc> @ imm = #0x20
   8d5b8: e5991000     	ldr	r1, [r9]
   8d5bc: e3510009     	cmp	r1, #9
   8d5c0: da000005     	ble	0x8d5dc <.text+0x7d4dc> @ imm = #0x14
   8d5c4: eb01c427     	bl	0xfe668 <.text+0xee568> @ imm = #0x7109c
   8d5c8: eafffff1     	b	0x8d594 <.text+0x7d494> @ imm = #-0x3c
   8d5cc: 0055a8d3     	ldrsbeq	r10, [r5], #-131
   8d5d0: 0055a83d     	subseq	r10, r5, sp, lsr r8
   8d5d4: 0055a863     	subseq	r10, r5, r3, ror #16
   8d5d8: 0055aea2     	subseq	r10, r5, r2, lsr #29
   8d5dc: e59f5fe8     	ldr	r5, [pc, #0xfe8]        @ 0x8e5cc <.text+0x7e4cc>
   8d5e0: e3500000     	cmp	r0, #0
   8d5e4: e08f5005     	add	r5, pc, r5
   8d5e8: 1a001932     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x64c8
   8d5ec: e9950005     	ldmib	r5, {r0, r2}
   8d5f0: e5901014     	ldr	r1, [r0, #0x14]
   8d5f4: e59d00bc     	ldr	r0, [sp, #0xbc]
   8d5f8: e1520001     	cmp	r2, r1
   8d5fc: b1a01002     	movlt	r1, r2
   8d600: ebff0be0     	bl	0x50588 <.text+0x40488> @ imm = #-0x3d080
   8d604: e59d60c0     	ldr	r6, [sp, #0xc0]
   8d608: e1a01000     	mov	r1, r0
   8d60c: e1a00006     	mov	r0, r6
   8d610: eb001d91     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x7644
   8d614: e3500000     	cmp	r0, #0
   8d618: 0a000013     	beq	0x8d66c <.text+0x7d56c> @ imm = #0x4c
   8d61c: e59f0fd0     	ldr	r0, [pc, #0xfd0]        @ 0x8e5f4 <.text+0x7e4f4>
   8d620: e3a07001     	mov	r7, #1
   8d624: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x8e5f8 <.text+0x7e4f8>
   8d628: e59f2fcc     	ldr	r2, [pc, #0xfcc]        @ 0x8e5fc <.text+0x7e4fc>
   8d62c: e08f0000     	add	r0, pc, r0
   8d630: e59f3fc8     	ldr	r3, [pc, #0xfc8]        @ 0x8e600 <.text+0x7e500>
   8d634: e08f1001     	add	r1, pc, r1
   8d638: e08f2002     	add	r2, pc, r2
   8d63c: e58d7000     	str	r7, [sp]
   8d640: e08f3003     	add	r3, pc, r3
   8d644: e58d3004     	str	r3, [sp, #0x4]
   8d648: e30133b5     	movw	r3, #0x13b5
   8d64c: eb01b29c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ca70
   8d650: e59d00b8     	ldr	r0, [sp, #0xb8]
   8d654: e30017da     	movw	r1, #0x7da
   8d658: ebfef18e     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x439c8
   8d65c: e1a00006     	mov	r0, r6
   8d660: eafffa07     	b	0x8be84 <.text+0x7bd84> @ imm = #-0x17e4
   8d664: 00584348     	subseq	r4, r8, r8, asr #6
   8d668: 0058639c     	<unknown>
   8d66c: e1a00006     	mov	r0, r6
   8d670: eb00203e     	bl	0x95770 <.text+0x85670> @ imm = #0x80f8
   8d674: e3020034     	movw	r0, #0x2034
   8d678: e1a02005     	mov	r2, r5
   8d67c: e7950000     	ldr	r0, [r5, r0]
   8d680: e3500001     	cmp	r0, #1
   8d684: 0a00000e     	beq	0x8d6c4 <.text+0x7d5c4> @ imm = #0x38
   8d688: e59d50c0     	ldr	r5, [sp, #0xc0]
   8d68c: e3500000     	cmp	r0, #0
   8d690: e59f7fc0     	ldr	r7, [pc, #0xfc0]        @ 0x8e658 <.text+0x7e558>
   8d694: e08f7007     	add	r7, pc, r7
   8d698: 1a000d42     	bne	0x90ba8 <.text+0x80aa8> @ imm = #0x3508
   8d69c: e5940000     	ldr	r0, [r4]
   8d6a0: e2401001     	sub	r1, r0, #1
   8d6a4: e0000190     	mul	r0, r0, r1
   8d6a8: e3100001     	tst	r0, #1
   8d6ac: 0a000d0e     	beq	0x90aec <.text+0x809ec> @ imm = #0x3438
   8d6b0: e5990000     	ldr	r0, [r9]
   8d6b4: e3500009     	cmp	r0, #9
   8d6b8: ca000d1b     	bgt	0x90b2c <.text+0x80a2c> @ imm = #0x346c
   8d6bc: ea000d0a     	b	0x90aec <.text+0x809ec> @ imm = #0x3428
   8d6c0: 00586348     	subseq	r6, r8, r8, asr #6
   8d6c4: e5940000     	ldr	r0, [r4]
   8d6c8: e59d50c0     	ldr	r5, [sp, #0xc0]
   8d6cc: e2401001     	sub	r1, r0, #1
   8d6d0: e59f7f84     	ldr	r7, [pc, #0xf84]        @ 0x8e65c <.text+0x7e55c>
   8d6d4: e0000190     	mul	r0, r0, r1
   8d6d8: e08f7007     	add	r7, pc, r7
   8d6dc: e3100001     	tst	r0, #1
   8d6e0: 0a000d1a     	beq	0x90b50 <.text+0x80a50> @ imm = #0x3468
   8d6e4: e5990000     	ldr	r0, [r9]
   8d6e8: e3500009     	cmp	r0, #9
   8d6ec: ca000d24     	bgt	0x90b84 <.text+0x80a84> @ imm = #0x3490
   8d6f0: ea000d16     	b	0x90b50 <.text+0x80a50> @ imm = #0x3458
   8d6f4: 005862e0     	subseq	r6, r8, r0, ror #5
   8d6f8: e59d00ac     	ldr	r0, [sp, #0xac]
   8d6fc: e2861008     	add	r1, r6, #8
   8d700: e3a02000     	mov	r2, #0
   8d704: e5903000     	ldr	r3, [r0]
   8d708: e1a00005     	mov	r0, r5
   8d70c: eb00495b     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x1256c
   8d710: e5941000     	ldr	r1, [r4]
   8d714: e2412001     	sub	r2, r1, #1
   8d718: e0010291     	mul	r1, r1, r2
   8d71c: e3110001     	tst	r1, #1
   8d720: 0a00018c     	beq	0x8dd58 <.text+0x7dc58> @ imm = #0x630
   8d724: e5991000     	ldr	r1, [r9]
   8d728: e59f6fe4     	ldr	r6, [pc, #0xfe4]        @ 0x8e714 <.text+0x7e614>
   8d72c: e351000a     	cmp	r1, #10
   8d730: e08f6006     	add	r6, pc, r6
   8d734: ba000187     	blt	0x8dd58 <.text+0x7dc58> @ imm = #0x61c
   8d738: e59d00ac     	ldr	r0, [sp, #0xac]
   8d73c: e2861008     	add	r1, r6, #8
   8d740: e3a02000     	mov	r2, #0
   8d744: e5903000     	ldr	r3, [r0]
   8d748: e1a00005     	mov	r0, r5
   8d74c: eb00494b     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x1252c
   8d750: e59f6fc0     	ldr	r6, [pc, #0xfc0]        @ 0x8e718 <.text+0x7e618>
   8d754: e08f6006     	add	r6, pc, r6
   8d758: eaffffe6     	b	0x8d6f8 <.text+0x7d5f8> @ imm = #-0x68
   8d75c: 0058425c     	subseq	r4, r8, r12, asr r2
   8d760: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x8e760 <.text+0x7e660>
   8d764: e08f0000     	add	r0, pc, r0
   8d768: e2801008     	add	r1, r0, #8
   8d76c: e59d00c0     	ldr	r0, [sp, #0xc0]
   8d770: eb004e7a     	bl	0xa1160 <.text+0x91060> @ imm = #0x139e8
   8d774: e5940000     	ldr	r0, [r4]
   8d778: e2401001     	sub	r1, r0, #1
   8d77c: e0000190     	mul	r0, r0, r1
   8d780: e3100001     	tst	r0, #1
   8d784: 0a000245     	beq	0x8e0a0 <.text+0x7dfa0> @ imm = #0x914
   8d788: e5990000     	ldr	r0, [r9]
   8d78c: e350000a     	cmp	r0, #10
   8d790: ba000242     	blt	0x8e0a0 <.text+0x7dfa0> @ imm = #0x908
   8d794: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x8e764 <.text+0x7e664>
   8d798: e08f0000     	add	r0, pc, r0
   8d79c: e2801008     	add	r1, r0, #8
   8d7a0: e59d00c0     	ldr	r0, [sp, #0xc0]
   8d7a4: eb004e6d     	bl	0xa1160 <.text+0x91060> @ imm = #0x139b4
   8d7a8: eaffffec     	b	0x8d760 <.text+0x7d660> @ imm = #-0x50
   8d7ac: 0058627c     	subseq	r6, r8, r12, ror r2
   8d7b0: 005841f8     	ldrsheq	r4, [r8], #-24
   8d7b4: 00586240     	subseq	r6, r8, r0, asr #4
   8d7b8: 0055a63e     	subseq	r10, r5, lr, lsr r6
   8d7bc: 0055a63d     	subseq	r10, r5, sp, lsr r6
   8d7c0: 0055a663     	subseq	r10, r5, r3, ror #12
   8d7c4: 0055a89d     	<unknown>
   8d7c8: 0055a697     	<unknown>
   8d7cc: 0055a601     	subseq	r10, r5, r1, lsl #12
   8d7d0: 0055a627     	subseq	r10, r5, r7, lsr #12
   8d7d4: 0055ac1c     	subseq	r10, r5, r12, lsl r12
   8d7d8: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x8e7c4 <.text+0x7e6c4>
   8d7dc: e3a03001     	mov	r3, #1
   8d7e0: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x8e7c8 <.text+0x7e6c8>
   8d7e4: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x8e7cc <.text+0x7e6cc>
   8d7e8: e08f0000     	add	r0, pc, r0
   8d7ec: e08f1001     	add	r1, pc, r1
   8d7f0: e88d0028     	stm	sp, {r3, r5}
   8d7f4: e08f2002     	add	r2, pc, r2
   8d7f8: e3013495     	movw	r3, #0x1495
   8d7fc: eb01b230     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c8c0
   8d800: e59d00b8     	ldr	r0, [sp, #0xb8]
   8d804: e30017da     	movw	r1, #0x7da
   8d808: ebfef122     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x43b78
   8d80c: e5940000     	ldr	r0, [r4]
   8d810: e2401001     	sub	r1, r0, #1
   8d814: e0000190     	mul	r0, r0, r1
   8d818: e3100001     	tst	r0, #1
   8d81c: 0a0014fb     	beq	0x92c10 <.text+0x82b10> @ imm = #0x53ec
   8d820: e5990000     	ldr	r0, [r9]
   8d824: e350000a     	cmp	r0, #10
   8d828: ba0014f8     	blt	0x92c10 <.text+0x82b10> @ imm = #0x53e0
   8d82c: e59f0fdc     	ldr	r0, [pc, #0xfdc]        @ 0x8e810 <.text+0x7e710>
   8d830: e3a03001     	mov	r3, #1
   8d834: e59f1fd8     	ldr	r1, [pc, #0xfd8]        @ 0x8e814 <.text+0x7e714>
   8d838: e59f2fd8     	ldr	r2, [pc, #0xfd8]        @ 0x8e818 <.text+0x7e718>
   8d83c: e08f0000     	add	r0, pc, r0
   8d840: e08f1001     	add	r1, pc, r1
   8d844: e88d0028     	stm	sp, {r3, r5}
   8d848: e08f2002     	add	r2, pc, r2
   8d84c: e3013495     	movw	r3, #0x1495
   8d850: eb01b21b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c86c
   8d854: e59d00b8     	ldr	r0, [sp, #0xb8]
   8d858: e30017da     	movw	r1, #0x7da
   8d85c: ebfef10d     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x43bcc
   8d860: eaffffdc     	b	0x8d7d8 <.text+0x7d6d8> @ imm = #-0x90
   8d864: 0055a657     	subseq	r10, r5, r7, asr r6
   8d868: 0055a5c1     	subseq	r10, r5, r1, asr #11
   8d86c: 0055a5e7     	subseq	r10, r5, r7, ror #11
   8d870: 0055ab4c     	subseq	r10, r5, r12, asr #22
   8d874: 00586170     	subseq	r6, r8, r0, ror r1
   8d878: e1a00005     	mov	r0, r5
   8d87c: ebff5483     	bl	0x62a90 <.text+0x52990> @ imm = #-0x2adf4
   8d880: e1a00005     	mov	r0, r5
   8d884: eeb09b40     	vmov.f64	d9, d0
   8d888: ebff5446     	bl	0x629a8 <.text+0x528a8> @ imm = #-0x2aee8
   8d88c: e5940000     	ldr	r0, [r4]
   8d890: eeb0ab40     	vmov.f64	d10, d0
   8d894: e596a000     	ldr	r10, [r6]
   8d898: e2401001     	sub	r1, r0, #1
   8d89c: e0010190     	mul	r1, r0, r1
   8d8a0: e59d00c4     	ldr	r0, [sp, #0xc4]
   8d8a4: ed978b00     	vldr	d8, [r7]
   8d8a8: e5d00061     	ldrb	r0, [r0, #0x61]
   8d8ac: e3110001     	tst	r1, #1
   8d8b0: 0a00000b     	beq	0x8d8e4 <.text+0x7d7e4> @ imm = #0x2c
   8d8b4: e5991000     	ldr	r1, [r9]
   8d8b8: e3510009     	cmp	r1, #9
   8d8bc: da000008     	ble	0x8d8e4 <.text+0x7d7e4> @ imm = #0x20
   8d8c0: e1a00005     	mov	r0, r5
   8d8c4: ebff5471     	bl	0x62a90 <.text+0x52990> @ imm = #-0x2ae3c
   8d8c8: e1a00005     	mov	r0, r5
   8d8cc: ebff5435     	bl	0x629a8 <.text+0x528a8> @ imm = #-0x2af2c
   8d8d0: eaffffe8     	b	0x8d878 <.text+0x7d778> @ imm = #-0x60
   8d8d4: 0055a5bb     	ldrheq	r10, [r5], #-91
   8d8d8: 0055a525     	subseq	r10, r5, r5, lsr #10
   8d8dc: 0055a54b     	subseq	r10, r5, r11, asr #10
   8d8e0: 0055ad8c     	subseq	r10, r5, r12, lsl #27
   8d8e4: e59f2fc0     	ldr	r2, [pc, #0xfc0]        @ 0x8e8ac <.text+0x7e7ac>
   8d8e8: e3500000     	cmp	r0, #0
   8d8ec: e08f2002     	add	r2, pc, r2
   8d8f0: 1a001870     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x61c0
   8d8f4: e3020034     	movw	r0, #0x2034
   8d8f8: e7920000     	ldr	r0, [r2, r0]
   8d8fc: e3500001     	cmp	r0, #1
   8d900: 0a00000b     	beq	0x8d934 <.text+0x7d834> @ imm = #0x2c
   8d904: e3500000     	cmp	r0, #0
   8d908: 1a0009e7     	bne	0x900ac <.text+0x7ffac> @ imm = #0x279c
   8d90c: e5940000     	ldr	r0, [r4]
   8d910: e59d50c0     	ldr	r5, [sp, #0xc0]
   8d914: e2401001     	sub	r1, r0, #1
   8d918: e0000190     	mul	r0, r0, r1
   8d91c: e3100001     	tst	r0, #1
   8d920: 0a0009ab     	beq	0x8ffd4 <.text+0x7fed4> @ imm = #0x26ac
   8d924: e5990000     	ldr	r0, [r9]
   8d928: e3500009     	cmp	r0, #9
   8d92c: ca0009b8     	bgt	0x90014 <.text+0x7ff14> @ imm = #0x26e0
   8d930: ea0009a7     	b	0x8ffd4 <.text+0x7fed4> @ imm = #0x269c
   8d934: e5940000     	ldr	r0, [r4]
   8d938: e59d50c0     	ldr	r5, [sp, #0xc0]
   8d93c: e2401001     	sub	r1, r0, #1
   8d940: e0000190     	mul	r0, r0, r1
   8d944: e3100001     	tst	r0, #1
   8d948: 0a0009c0     	beq	0x90050 <.text+0x7ff50> @ imm = #0x2700
   8d94c: e5990000     	ldr	r0, [r9]
   8d950: e3500009     	cmp	r0, #9
   8d954: ca0009ca     	bgt	0x90084 <.text+0x7ff84> @ imm = #0x2728
   8d958: ea0009bc     	b	0x90050 <.text+0x7ff50> @ imm = #0x26f0
   8d95c: 005860c0     	subseq	r6, r8, r0, asr #1
   8d960: 0058609c     	<unknown>
   8d964: 00586054     	subseq	r6, r8, r4, asr r0
   8d968: e59f0f80     	ldr	r0, [pc, #0xf80]        @ 0x8e8f0 <.text+0x7e7f0>
   8d96c: e3a07001     	mov	r7, #1
   8d970: e59f1f7c     	ldr	r1, [pc, #0xf7c]        @ 0x8e8f4 <.text+0x7e7f4>
   8d974: e59f2f7c     	ldr	r2, [pc, #0xf7c]        @ 0x8e8f8 <.text+0x7e7f8>
   8d978: e08f0000     	add	r0, pc, r0
   8d97c: e59f3f78     	ldr	r3, [pc, #0xf78]        @ 0x8e8fc <.text+0x7e7fc>
   8d980: e08f1001     	add	r1, pc, r1
   8d984: e08f2002     	add	r2, pc, r2
   8d988: e58d7000     	str	r7, [sp]
   8d98c: e08f3003     	add	r3, pc, r3
   8d990: e58d3004     	str	r3, [sp, #0x4]
   8d994: e3013502     	movw	r3, #0x1502
   8d998: eb01b1c9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c724
   8d99c: e5940000     	ldr	r0, [r4]
   8d9a0: e30077da     	movw	r7, #0x7da
   8d9a4: e2401001     	sub	r1, r0, #1
   8d9a8: e0000190     	mul	r0, r0, r1
   8d9ac: e3100001     	tst	r0, #1
   8d9b0: 0a0002bb     	beq	0x8e4a4 <.text+0x7e3a4> @ imm = #0xaec
   8d9b4: e5990000     	ldr	r0, [r9]
   8d9b8: e350000a     	cmp	r0, #10
   8d9bc: ba0002b8     	blt	0x8e4a4 <.text+0x7e3a4> @ imm = #0xae0
   8d9c0: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x8e9ac <.text+0x7e8ac>
   8d9c4: e3a07001     	mov	r7, #1
   8d9c8: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x8e9b0 <.text+0x7e8b0>
   8d9cc: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x8e9b4 <.text+0x7e8b4>
   8d9d0: e08f0000     	add	r0, pc, r0
   8d9d4: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x8e9b8 <.text+0x7e8b8>
   8d9d8: e08f1001     	add	r1, pc, r1
   8d9dc: e08f2002     	add	r2, pc, r2
   8d9e0: e58d7000     	str	r7, [sp]
   8d9e4: e08f3003     	add	r3, pc, r3
   8d9e8: e58d3004     	str	r3, [sp, #0x4]
   8d9ec: e3013502     	movw	r3, #0x1502
   8d9f0: eb01b1b3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c6cc
   8d9f4: eaffffdb     	b	0x8d968 <.text+0x7d868> @ imm = #-0x94
   8d9f8: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0x8e9bc <.text+0x7e8bc>
   8d9fc: e2853001     	add	r3, r5, #1
   8da00: e59f1fb8     	ldr	r1, [pc, #0xfb8]        @ 0x8e9c0 <.text+0x7e8c0>
   8da04: e3a07001     	mov	r7, #1
   8da08: e59f2fb4     	ldr	r2, [pc, #0xfb4]        @ 0x8e9c4 <.text+0x7e8c4>
   8da0c: e08f0000     	add	r0, pc, r0
   8da10: e58d3008     	str	r3, [sp, #0x8]
   8da14: e08f1001     	add	r1, pc, r1
   8da18: e59d30a4     	ldr	r3, [sp, #0xa4]
   8da1c: e08f2002     	add	r2, pc, r2
   8da20: e58d300c     	str	r3, [sp, #0xc]
   8da24: e3003696     	movw	r3, #0x696
   8da28: e58d7000     	str	r7, [sp]
   8da2c: e58d6004     	str	r6, [sp, #0x4]
   8da30: eb01b1a3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c68c
   8da34: e5940000     	ldr	r0, [r4]
   8da38: e2401001     	sub	r1, r0, #1
   8da3c: e0000190     	mul	r0, r0, r1
   8da40: e3100001     	tst	r0, #1
   8da44: 0a000014     	beq	0x8da9c <.text+0x7d99c> @ imm = #0x50
   8da48: e5990000     	ldr	r0, [r9]
   8da4c: e3500009     	cmp	r0, #9
   8da50: da000011     	ble	0x8da9c <.text+0x7d99c> @ imm = #0x44
   8da54: e59f0ffc     	ldr	r0, [pc, #0xffc]        @ 0x8ea58 <.text+0x7e958>
   8da58: e2853001     	add	r3, r5, #1
   8da5c: e59f1ff8     	ldr	r1, [pc, #0xff8]        @ 0x8ea5c <.text+0x7e95c>
   8da60: e3a07001     	mov	r7, #1
   8da64: e59f2ff4     	ldr	r2, [pc, #0xff4]        @ 0x8ea60 <.text+0x7e960>
   8da68: e08f0000     	add	r0, pc, r0
   8da6c: e58d3008     	str	r3, [sp, #0x8]
   8da70: e08f1001     	add	r1, pc, r1
   8da74: e59d30a4     	ldr	r3, [sp, #0xa4]
   8da78: e08f2002     	add	r2, pc, r2
   8da7c: e58d300c     	str	r3, [sp, #0xc]
   8da80: e3003696     	movw	r3, #0x696
   8da84: e58d7000     	str	r7, [sp]
   8da88: e58d6004     	str	r6, [sp, #0x4]
   8da8c: eb01b18c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c630
   8da90: eaffffd8     	b	0x8d9f8 <.text+0x7d8f8> @ imm = #-0xa0
   8da94: 00583f24     	subseq	r3, r8, r4, lsr #30
   8da98: 00583f08     	subseq	r3, r8, r8, lsl #30
   8da9c: e59d0054     	ldr	r0, [sp, #0x54]
   8daa0: e3500000     	cmp	r0, #0
   8daa4: 0a0016c7     	beq	0x935c8 <.text+0x834c8> @ imm = #0x5b1c
   8daa8: e5940000     	ldr	r0, [r4]
   8daac: e2401001     	sub	r1, r0, #1
   8dab0: e0000190     	mul	r0, r0, r1
   8dab4: e3100001     	tst	r0, #1
   8dab8: 0a0016a9     	beq	0x93564 <.text+0x83464> @ imm = #0x5aa4
   8dabc: e5990000     	ldr	r0, [r9]
   8dac0: e3500009     	cmp	r0, #9
   8dac4: ca0016b0     	bgt	0x9358c <.text+0x8348c> @ imm = #0x5ac0
   8dac8: ea0016a5     	b	0x93564 <.text+0x83464> @ imm = #0x5a94
   8dacc: 00583e0c     	subseq	r3, r8, r12, lsl #28
   8dad0: 00583ddc     	ldrsbeq	r3, [r8], #-220
   8dad4: e3a00001     	mov	r0, #1
   8dad8: e59f6fe4     	ldr	r6, [pc, #0xfe4]        @ 0x8eac4 <.text+0x7e9c4>
   8dadc: e59f7fe4     	ldr	r7, [pc, #0xfe4]        @ 0x8eac8 <.text+0x7e9c8>
   8dae0: e30036bb     	movw	r3, #0x6bb
   8dae4: e59fafe0     	ldr	r10, [pc, #0xfe0]       @ 0x8eacc <.text+0x7e9cc>
   8dae8: e08f6006     	add	r6, pc, r6
   8daec: e58d0000     	str	r0, [sp]
   8daf0: e08f7007     	add	r7, pc, r7
   8daf4: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x8eaf4 <.text+0x7e9f4>
   8daf8: e08fa00a     	add	r10, pc, r10
   8dafc: e1a01007     	mov	r1, r7
   8db00: e08f0000     	add	r0, pc, r0
   8db04: e58d0004     	str	r0, [sp, #0x4]
   8db08: e59f8fe8     	ldr	r8, [pc, #0xfe8]        @ 0x8eaf8 <.text+0x7e9f8>
   8db0c: e1a0200a     	mov	r2, r10
   8db10: e59d009c     	ldr	r0, [sp, #0x9c]
   8db14: e58d000c     	str	r0, [sp, #0xc]
   8db18: e1a00006     	mov	r0, r6
   8db1c: e08f8008     	add	r8, pc, r8
   8db20: e58d8008     	str	r8, [sp, #0x8]
   8db24: eb01b166     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c598
   8db28: e3a00002     	mov	r0, #2
   8db2c: e1a01007     	mov	r1, r7
   8db30: e58d0000     	str	r0, [sp]
   8db34: e1a0200a     	mov	r2, r10
   8db38: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x8eb38 <.text+0x7ea38>
   8db3c: e30036bd     	movw	r3, #0x6bd
   8db40: e08f0000     	add	r0, pc, r0
   8db44: e58d0004     	str	r0, [sp, #0x4]
   8db48: e59f5fec     	ldr	r5, [pc, #0xfec]        @ 0x8eb3c <.text+0x7ea3c>
   8db4c: e1a00006     	mov	r0, r6
   8db50: e08f5005     	add	r5, pc, r5
   8db54: e58d5008     	str	r5, [sp, #0x8]
   8db58: eb01b159     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c564
   8db5c: e1a00008     	mov	r0, r8
   8db60: e1a01005     	mov	r1, r5
   8db64: eb14465b     	bl	0x59f4d8 <.text+0x58f3d8> @ imm = #0x51196c
   8db68: e5940000     	ldr	r0, [r4]
   8db6c: e2401001     	sub	r1, r0, #1
   8db70: e0000190     	mul	r0, r0, r1
   8db74: e3100001     	tst	r0, #1
   8db78: 0afff8e3     	beq	0x8bf0c <.text+0x7be0c> @ imm = #-0x1c74
   8db7c: e5990000     	ldr	r0, [r9]
   8db80: e3500009     	cmp	r0, #9
   8db84: dafff8e0     	ble	0x8bf0c <.text+0x7be0c> @ imm = #-0x1c80
   8db88: e3a00001     	mov	r0, #1
   8db8c: e59f8ff4     	ldr	r8, [pc, #0xff4]        @ 0x8eb88 <.text+0x7ea88>
   8db90: e59f7ff4     	ldr	r7, [pc, #0xff4]        @ 0x8eb8c <.text+0x7ea8c>
   8db94: e30036bb     	movw	r3, #0x6bb
   8db98: e59faff0     	ldr	r10, [pc, #0xff0]       @ 0x8eb90 <.text+0x7ea90>
   8db9c: e08f8008     	add	r8, pc, r8
   8dba0: e58d0000     	str	r0, [sp]
   8dba4: e08f7007     	add	r7, pc, r7
   8dba8: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x8eb94 <.text+0x7ea94>
   8dbac: e08fa00a     	add	r10, pc, r10
   8dbb0: e1a01007     	mov	r1, r7
   8dbb4: e08f0000     	add	r0, pc, r0
   8dbb8: e58d0004     	str	r0, [sp, #0x4]
   8dbbc: e59f5fd4     	ldr	r5, [pc, #0xfd4]        @ 0x8eb98 <.text+0x7ea98>
   8dbc0: e1a0200a     	mov	r2, r10
   8dbc4: e59d009c     	ldr	r0, [sp, #0x9c]
   8dbc8: e58d000c     	str	r0, [sp, #0xc]
   8dbcc: e1a00008     	mov	r0, r8
   8dbd0: e08f5005     	add	r5, pc, r5
   8dbd4: e58d5008     	str	r5, [sp, #0x8]
   8dbd8: eb01b139     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c4e4
   8dbdc: e3a00002     	mov	r0, #2
   8dbe0: e1a01007     	mov	r1, r7
   8dbe4: e58d0000     	str	r0, [sp]
   8dbe8: e1a0200a     	mov	r2, r10
   8dbec: e59f0fa8     	ldr	r0, [pc, #0xfa8]        @ 0x8eb9c <.text+0x7ea9c>
   8dbf0: e30036bd     	movw	r3, #0x6bd
   8dbf4: e08f0000     	add	r0, pc, r0
   8dbf8: e58d0004     	str	r0, [sp, #0x4]
   8dbfc: e59f6ff8     	ldr	r6, [pc, #0xff8]        @ 0x8ebfc <.text+0x7eafc>
   8dc00: e1a00008     	mov	r0, r8
   8dc04: e08f6006     	add	r6, pc, r6
   8dc08: e58d6008     	str	r6, [sp, #0x8]
   8dc0c: eb01b12c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c4b0
   8dc10: e1a00005     	mov	r0, r5
   8dc14: e1a01006     	mov	r1, r6
   8dc18: eb14462e     	bl	0x59f4d8 <.text+0x58f3d8> @ imm = #0x5118b8
   8dc1c: eaffffac     	b	0x8dad4 <.text+0x7d9d4> @ imm = #-0x150
   8dc20: 00585db8     	ldrheq	r5, [r8], #-216
   8dc24: 00583d44     	subseq	r3, r8, r4, asr #26
   8dc28: e59d00ac     	ldr	r0, [sp, #0xac]
   8dc2c: e2821008     	add	r1, r2, #8
   8dc30: e3a02000     	mov	r2, #0
   8dc34: e5903000     	ldr	r3, [r0]
   8dc38: e1a00005     	mov	r0, r5
   8dc3c: eb00480f     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x1203c
   8dc40: e5941000     	ldr	r1, [r4]
   8dc44: e2412001     	sub	r2, r1, #1
   8dc48: e0010291     	mul	r1, r1, r2
   8dc4c: e3110001     	tst	r1, #1
   8dc50: 0a00000d     	beq	0x8dc8c <.text+0x7db8c> @ imm = #0x34
   8dc54: e5991000     	ldr	r1, [r9]
   8dc58: e59f2fa0     	ldr	r2, [pc, #0xfa0]        @ 0x8ec00 <.text+0x7eb00>
   8dc5c: e351000a     	cmp	r1, #10
   8dc60: e08f2002     	add	r2, pc, r2
   8dc64: ba000008     	blt	0x8dc8c <.text+0x7db8c> @ imm = #0x20
   8dc68: e59d00ac     	ldr	r0, [sp, #0xac]
   8dc6c: e2821008     	add	r1, r2, #8
   8dc70: e3a02000     	mov	r2, #0
   8dc74: e5903000     	ldr	r3, [r0]
   8dc78: e1a00005     	mov	r0, r5
   8dc7c: eb0047ff     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x11ffc
   8dc80: e59f2ff0     	ldr	r2, [pc, #0xff0]        @ 0x8ec78 <.text+0x7eb78>
   8dc84: e08f2002     	add	r2, pc, r2
   8dc88: eaffffe6     	b	0x8dc28 <.text+0x7db28> @ imm = #-0x68
   8dc8c: e3500000     	cmp	r0, #0
   8dc90: 0a00000f     	beq	0x8dcd4 <.text+0x7dbd4> @ imm = #0x3c
   8dc94: e1a00005     	mov	r0, r5
   8dc98: e3a01001     	mov	r1, #1
   8dc9c: eb001da4     	bl	0x95334 <.text+0x85234> @ imm = #0x7690
   8dca0: e59f3fd4     	ldr	r3, [pc, #0xfd4]        @ 0x8ec7c <.text+0x7eb7c>
   8dca4: e3500000     	cmp	r0, #0
   8dca8: e08f3003     	add	r3, pc, r3
   8dcac: 0a000643     	beq	0x8f5c0 <.text+0x7f4c0> @ imm = #0x190c
   8dcb0: e5940000     	ldr	r0, [r4]
   8dcb4: e2401001     	sub	r1, r0, #1
   8dcb8: e0000190     	mul	r0, r0, r1
   8dcbc: e3100001     	tst	r0, #1
   8dcc0: 0a0005ed     	beq	0x8f47c <.text+0x7f37c> @ imm = #0x17b4
   8dcc4: e5990000     	ldr	r0, [r9]
   8dcc8: e3500009     	cmp	r0, #9
   8dccc: ca000608     	bgt	0x8f4f4 <.text+0x7f3f4> @ imm = #0x1820
   8dcd0: ea0005e9     	b	0x8f47c <.text+0x7f37c> @ imm = #0x17a4
   8dcd4: e5940000     	ldr	r0, [r4]
   8dcd8: e2401001     	sub	r1, r0, #1
   8dcdc: e0000190     	mul	r0, r0, r1
   8dce0: e3100001     	tst	r0, #1
   8dce4: 0a00061a     	beq	0x8f554 <.text+0x7f454> @ imm = #0x1868
   8dce8: e5990000     	ldr	r0, [r9]
   8dcec: e3500009     	cmp	r0, #9
   8dcf0: ca000626     	bgt	0x8f590 <.text+0x7f490> @ imm = #0x1898
   8dcf4: ea000616     	b	0x8f554 <.text+0x7f454> @ imm = #0x1858
   8dcf8: 00585d14     	subseq	r5, r8, r4, lsl sp
   8dcfc: 00583c98     	<unknown>
   8dd00: e2861008     	add	r1, r6, #8
   8dd04: e1a00005     	mov	r0, r5
   8dd08: eb00393a     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xe4e8
   8dd0c: e5941000     	ldr	r1, [r4]
   8dd10: e2412001     	sub	r2, r1, #1
   8dd14: e0010291     	mul	r1, r1, r2
   8dd18: e3110001     	tst	r1, #1
   8dd1c: 0a00000d     	beq	0x8dd58 <.text+0x7dc58> @ imm = #0x34
   8dd20: e5991000     	ldr	r1, [r9]
   8dd24: e59f6f84     	ldr	r6, [pc, #0xf84]        @ 0x8ecb0 <.text+0x7ebb0>
   8dd28: e3510009     	cmp	r1, #9
   8dd2c: e08f6006     	add	r6, pc, r6
   8dd30: da000008     	ble	0x8dd58 <.text+0x7dc58> @ imm = #0x20
   8dd34: e2861008     	add	r1, r6, #8
   8dd38: e1a00005     	mov	r0, r5
   8dd3c: eb00392d     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xe4b4
   8dd40: e59f6f6c     	ldr	r6, [pc, #0xf6c]        @ 0x8ecb4 <.text+0x7ebb4>
   8dd44: e08f6006     	add	r6, pc, r6
   8dd48: eaffffec     	b	0x8dd00 <.text+0x7dc00> @ imm = #-0x50
   8dd4c: 00583c7c     	subseq	r3, r8, r12, ror r12
   8dd50: 00583c40     	subseq	r3, r8, r0, asr #24
   8dd54: 00583c04     	subseq	r3, r8, r4, lsl #24
   8dd58: e3500000     	cmp	r0, #0
   8dd5c: 0a00001b     	beq	0x8ddd0 <.text+0x7dcd0> @ imm = #0x6c
   8dd60: e1a00005     	mov	r0, r5
   8dd64: e3a01001     	mov	r1, #1
   8dd68: e3a05001     	mov	r5, #1
   8dd6c: eb001d70     	bl	0x95334 <.text+0x85234> @ imm = #0x75c0
   8dd70: e3500000     	cmp	r0, #0
   8dd74: 0a00001e     	beq	0x8ddf4 <.text+0x7dcf4> @ imm = #0x78
   8dd78: e59f0f38     	ldr	r0, [pc, #0xf38]        @ 0x8ecb8 <.text+0x7ebb8>
   8dd7c: e59f1f38     	ldr	r1, [pc, #0xf38]        @ 0x8ecbc <.text+0x7ebbc>
   8dd80: e59f2f38     	ldr	r2, [pc, #0xf38]        @ 0x8ecc0 <.text+0x7ebc0>
   8dd84: e08f0000     	add	r0, pc, r0
   8dd88: e59f3f34     	ldr	r3, [pc, #0xf34]        @ 0x8ecc4 <.text+0x7ebc4>
   8dd8c: e08f1001     	add	r1, pc, r1
   8dd90: e08f2002     	add	r2, pc, r2
   8dd94: e58d5000     	str	r5, [sp]
   8dd98: e08f3003     	add	r3, pc, r3
   8dd9c: e58d3004     	str	r3, [sp, #0x4]
   8dda0: e3013467     	movw	r3, #0x1467
   8dda4: eb01b0c6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c318
   8dda8: e59d00b8     	ldr	r0, [sp, #0xb8]
   8ddac: e3001fa1     	movw	r1, #0xfa1
   8ddb0: ebfeefb8     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x44120
   8ddb4: e59d00c0     	ldr	r0, [sp, #0xc0]
   8ddb8: ebff6470     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x26e40
   8ddbc: e3a00000     	mov	r0, #0
   8ddc0: e5c70000     	strb	r0, [r7]
   8ddc4: ea00173b     	b	0x93ab8 <.text+0x839b8> @ imm = #0x5cec
   8ddc8: 00583be8     	subseq	r3, r8, r8, ror #23
   8ddcc: 00583bb0     	ldrheq	r3, [r8], #-176
   8ddd0: e59f6fc8     	ldr	r6, [pc, #0xfc8]        @ 0x8eda0 <.text+0x7eca0>
   8ddd4: e08f6006     	add	r6, pc, r6
   8ddd8: e1a00006     	mov	r0, r6
   8dddc: eb1460c9     	bl	0x5a6108 <.text+0x596008> @ imm = #0x518324
   8dde0: e1a00006     	mov	r0, r6
   8dde4: e5d85000     	ldrb	r5, [r8]
   8dde8: eb146235     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5188d4
   8ddec: e3550000     	cmp	r5, #0
   8ddf0: 0a000019     	beq	0x8de5c <.text+0x7dd5c> @ imm = #0x64
   8ddf4: e59f6fe0     	ldr	r6, [pc, #0xfe0]        @ 0x8eddc <.text+0x7ecdc>
   8ddf8: e08f6006     	add	r6, pc, r6
   8ddfc: e1a00006     	mov	r0, r6
   8de00: eb1460c0     	bl	0x5a6108 <.text+0x596008> @ imm = #0x518300
   8de04: e1a00006     	mov	r0, r6
   8de08: e5d85000     	ldrb	r5, [r8]
   8de0c: eb14622c     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5188b0
   8de10: e59f2fc8     	ldr	r2, [pc, #0xfc8]        @ 0x8ede0 <.text+0x7ece0>
   8de14: e3550000     	cmp	r5, #0
   8de18: e08f2002     	add	r2, pc, r2
   8de1c: 1a001725     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x5c94
   8de20: e3020034     	movw	r0, #0x2034
   8de24: e59d1090     	ldr	r1, [sp, #0x90]
   8de28: e7920000     	ldr	r0, [r2, r0]
   8de2c: ed910b00     	vldr	d0, [r1]
   8de30: e3500000     	cmp	r0, #0
   8de34: 0a000022     	beq	0x8dec4 <.text+0x7ddc4> @ imm = #0x88
   8de38: e3500001     	cmp	r0, #1
   8de3c: 1a000028     	bne	0x8dee4 <.text+0x7dde4> @ imm = #0xa0
   8de40: e3020030     	movw	r0, #0x2030
   8de44: e7921000     	ldr	r1, [r2, r0]
   8de48: e2820008     	add	r0, r2, #8
   8de4c: eb0041c5     	bl	0x9e568 <.text+0x8e468> @ imm = #0x10714
   8de50: ea00001d     	b	0x8decc <.text+0x7ddcc> @ imm = #0x74
   8de54: 00583b38     	subseq	r3, r8, r8, lsr r11
   8de58: 00583b14     	subseq	r3, r8, r4, lsl r11
   8de5c: e5940000     	ldr	r0, [r4]
   8de60: e59f3fb4     	ldr	r3, [pc, #0xfb4]        @ 0x8ee1c <.text+0x7ed1c>
   8de64: e2401001     	sub	r1, r0, #1
   8de68: e08f3003     	add	r3, pc, r3
   8de6c: e0000190     	mul	r0, r0, r1
   8de70: e3100001     	tst	r0, #1
   8de74: e5940000     	ldr	r0, [r4]
   8de78: e2401001     	sub	r1, r0, #1
   8de7c: e0010190     	mul	r1, r0, r1
   8de80: e3020034     	movw	r0, #0x2034
   8de84: e7930000     	ldr	r0, [r3, r0]
   8de88: e3110001     	tst	r1, #1
   8de8c: 0a000002     	beq	0x8de9c <.text+0x7dd9c> @ imm = #0x8
   8de90: e5991000     	ldr	r1, [r9]
   8de94: e3510009     	cmp	r1, #9
   8de98: cafffff5     	bgt	0x8de74 <.text+0x7dd74> @ imm = #-0x2c
   8de9c: e3500001     	cmp	r0, #1
   8dea0: 0a00005a     	beq	0x8e010 <.text+0x7df10> @ imm = #0x168
   8dea4: e3500000     	cmp	r0, #0
   8dea8: 1affffd1     	bne	0x8ddf4 <.text+0x7dcf4> @ imm = #-0xbc
   8deac: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0x8ee70 <.text+0x7ed70>
   8deb0: e08f0000     	add	r0, pc, r0
   8deb4: e2801008     	add	r1, r0, #8
   8deb8: e59d00c0     	ldr	r0, [sp, #0xc0]
   8debc: eb004ca7     	bl	0xa1160 <.text+0x91060> @ imm = #0x1329c
   8dec0: eaffffcb     	b	0x8ddf4 <.text+0x7dcf4> @ imm = #-0xd4
   8dec4: e2820008     	add	r0, r2, #8
   8dec8: eb004e0c     	bl	0xa1700 <.text+0x91600> @ imm = #0x13830
   8decc: e59f1ffc     	ldr	r1, [pc, #0xffc]        @ 0x8eed0 <.text+0x7edd0>
   8ded0: e3500000     	cmp	r0, #0
   8ded4: e08f1001     	add	r1, pc, r1
   8ded8: 0a000010     	beq	0x8df20 <.text+0x7de20> @ imm = #0x40
   8dedc: ea000036     	b	0x8dfbc <.text+0x7debc> @ imm = #0xd8
   8dee0: 00583a9c     	<unknown>
   8dee4: e59f0fe8     	ldr	r0, [pc, #0xfe8]        @ 0x8eed4 <.text+0x7edd4>
   8dee8: e3a07002     	mov	r7, #2
   8deec: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0x8eed8 <.text+0x7edd8>
   8def0: e59f2fe4     	ldr	r2, [pc, #0xfe4]        @ 0x8eedc <.text+0x7eddc>
   8def4: e08f0000     	add	r0, pc, r0
   8def8: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0x8eee0 <.text+0x7ede0>
   8defc: e08f1001     	add	r1, pc, r1
   8df00: e08f2002     	add	r2, pc, r2
   8df04: e58d7000     	str	r7, [sp]
   8df08: e08f3003     	add	r3, pc, r3
   8df0c: e58d3004     	str	r3, [sp, #0x4]
   8df10: e300376d     	movw	r3, #0x76d
   8df14: eb01b06a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c1a8
   8df18: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0x8eee4 <.text+0x7ede4>
   8df1c: e08f1001     	add	r1, pc, r1
   8df20: e3020034     	movw	r0, #0x2034
   8df24: e7910000     	ldr	r0, [r1, r0]
   8df28: e3500000     	cmp	r0, #0
   8df2c: 0a000012     	beq	0x8df7c <.text+0x7de7c> @ imm = #0x48
   8df30: e3500001     	cmp	r0, #1
   8df34: 0a000020     	beq	0x8dfbc <.text+0x7debc> @ imm = #0x80
   8df38: e59f0fa8     	ldr	r0, [pc, #0xfa8]        @ 0x8eee8 <.text+0x7ede8>
   8df3c: e3a07002     	mov	r7, #2
   8df40: e59f1fa4     	ldr	r1, [pc, #0xfa4]        @ 0x8eeec <.text+0x7edec>
   8df44: e59f2fa4     	ldr	r2, [pc, #0xfa4]        @ 0x8eef0 <.text+0x7edf0>
   8df48: e08f0000     	add	r0, pc, r0
   8df4c: e59f3fa0     	ldr	r3, [pc, #0xfa0]        @ 0x8eef4 <.text+0x7edf4>
   8df50: e08f1001     	add	r1, pc, r1
   8df54: e08f2002     	add	r2, pc, r2
   8df58: e58d7000     	str	r7, [sp]
   8df5c: e08f3003     	add	r3, pc, r3
   8df60: e58d3004     	str	r3, [sp, #0x4]
   8df64: e300375f     	movw	r3, #0x75f
   8df68: eb01b055     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6c154
   8df6c: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0x8ef64 <.text+0x7ee64>
   8df70: e08f1001     	add	r1, pc, r1
   8df74: ea000008     	b	0x8df9c <.text+0x7de9c> @ imm = #0x20
   8df78: 00585a5c     	subseq	r5, r8, r12, asr r10
   8df7c: e59d0074     	ldr	r0, [sp, #0x74]
   8df80: ed900b00     	vldr	d0, [r0]
   8df84: e2810008     	add	r0, r1, #8
   8df88: eb004eb6     	bl	0xa1a68 <.text+0x91968> @ imm = #0x13ad8
   8df8c: e59f1fd4     	ldr	r1, [pc, #0xfd4]        @ 0x8ef68 <.text+0x7ee68>
   8df90: e3500000     	cmp	r0, #0
   8df94: e08f1001     	add	r1, pc, r1
   8df98: 1a000007     	bne	0x8dfbc <.text+0x7debc> @ imm = #0x1c
   8df9c: e59d0080     	ldr	r0, [sp, #0x80]
   8dfa0: e5912004     	ldr	r2, [r1, #0x4]
   8dfa4: e2811008     	add	r1, r1, #8
   8dfa8: ed900b00     	vldr	d0, [r0]
   8dfac: e59d00c0     	ldr	r0, [sp, #0xc0]
   8dfb0: ebffec58     	bl	0x89118 <.text+0x79018> @ imm = #-0x4ea0
   8dfb4: e3500000     	cmp	r0, #0
   8dfb8: 1a0016be     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x5af8
   8dfbc: e59d0088     	ldr	r0, [sp, #0x88]
   8dfc0: e5905000     	ldr	r5, [r0]
   8dfc4: eb01bffc     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x6fff0
   8dfc8: e59f3ff8     	ldr	r3, [pc, #0xff8]        @ 0x8efc8 <.text+0x7eec8>
   8dfcc: e3500006     	cmp	r0, #6
   8dfd0: e08f3003     	add	r3, pc, r3
   8dfd4: 1a001295     	bne	0x92a30 <.text+0x82930> @ imm = #0x4a54
   8dfd8: e3020034     	movw	r0, #0x2034
   8dfdc: e7930000     	ldr	r0, [r3, r0]
   8dfe0: e3500001     	cmp	r0, #1
   8dfe4: 0a001291     	beq	0x92a30 <.text+0x82930> @ imm = #0x4a44
   8dfe8: e5940000     	ldr	r0, [r4]
   8dfec: e2401001     	sub	r1, r0, #1
   8dff0: e0000190     	mul	r0, r0, r1
   8dff4: e3100001     	tst	r0, #1
   8dff8: 0a001279     	beq	0x929e4 <.text+0x828e4> @ imm = #0x49e4
   8dffc: e5990000     	ldr	r0, [r9]
   8e000: e3500009     	cmp	r0, #9
   8e004: ca001280     	bgt	0x92a0c <.text+0x8290c> @ imm = #0x4a00
   8e008: ea001275     	b	0x929e4 <.text+0x828e4> @ imm = #0x49d4
   8e00c: 005839a4     	subseq	r3, r8, r4, lsr #19
   8e010: e3020030     	movw	r0, #0x2030
   8e014: e2831008     	add	r1, r3, #8
   8e018: e7932000     	ldr	r2, [r3, r0]
   8e01c: e59d00c0     	ldr	r0, [sp, #0xc0]
   8e020: eb003f6c     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xfdb0
   8e024: eaffff72     	b	0x8ddf4 <.text+0x7dcf4> @ imm = #-0x238
   8e028: e1a00005     	mov	r0, r5
   8e02c: e3a01001     	mov	r1, #1
   8e030: eb001cbf     	bl	0x95334 <.text+0x85234> @ imm = #0x72fc
   8e034: e5941000     	ldr	r1, [r4]
   8e038: e2412001     	sub	r2, r1, #1
   8e03c: e0010291     	mul	r1, r1, r2
   8e040: e3110001     	tst	r1, #1
   8e044: 0a000007     	beq	0x8e068 <.text+0x7df68> @ imm = #0x1c
   8e048: e5991000     	ldr	r1, [r9]
   8e04c: e3510009     	cmp	r1, #9
   8e050: da000004     	ble	0x8e068 <.text+0x7df68> @ imm = #0x10
   8e054: e1a00005     	mov	r0, r5
   8e058: e3a01001     	mov	r1, #1
   8e05c: eb001cb4     	bl	0x95334 <.text+0x85234> @ imm = #0x72d0
   8e060: eafffff0     	b	0x8e028 <.text+0x7df28> @ imm = #-0x40
   8e064: 00583954     	subseq	r3, r8, r4, asr r9
   8e068: e3500000     	cmp	r0, #0
   8e06c: 0a00000b     	beq	0x8e0a0 <.text+0x7dfa0> @ imm = #0x2c
   8e070: e5940000     	ldr	r0, [r4]
   8e074: e59f5fcc     	ldr	r5, [pc, #0xfcc]        @ 0x8f048 <.text+0x7ef48>
   8e078: e2401001     	sub	r1, r0, #1
   8e07c: e08f5005     	add	r5, pc, r5
   8e080: e0000190     	mul	r0, r0, r1
   8e084: e3100001     	tst	r0, #1
   8e088: 0a0011b0     	beq	0x92750 <.text+0x82650> @ imm = #0x46c0
   8e08c: e5990000     	ldr	r0, [r9]
   8e090: e3500009     	cmp	r0, #9
   8e094: ca0011c2     	bgt	0x927a4 <.text+0x826a4> @ imm = #0x4708
   8e098: ea0011ac     	b	0x92750 <.text+0x82650> @ imm = #0x46b0
   8e09c: 005838fc     	ldrsheq	r3, [r8], #-140
   8e0a0: e59f6fe4     	ldr	r6, [pc, #0xfe4]        @ 0x8f08c <.text+0x7ef8c>
   8e0a4: e08f6006     	add	r6, pc, r6
   8e0a8: e1a00006     	mov	r0, r6
   8e0ac: eb146015     	bl	0x5a6108 <.text+0x596008> @ imm = #0x518054
   8e0b0: e1a00006     	mov	r0, r6
   8e0b4: e5d75000     	ldrb	r5, [r7]
   8e0b8: eb146181     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x518604
   8e0bc: e3550000     	cmp	r5, #0
   8e0c0: 1a00167c     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x59f0
   8e0c4: e5940000     	ldr	r0, [r4]
   8e0c8: e59d50c0     	ldr	r5, [sp, #0xc0]
   8e0cc: e2401001     	sub	r1, r0, #1
   8e0d0: e0000190     	mul	r0, r0, r1
   8e0d4: e3100001     	tst	r0, #1
   8e0d8: 0a0011c0     	beq	0x927e0 <.text+0x826e0> @ imm = #0x4700
   8e0dc: e5990000     	ldr	r0, [r9]
   8e0e0: e3500009     	cmp	r0, #9
   8e0e4: ca0011c7     	bgt	0x92808 <.text+0x82708> @ imm = #0x471c
   8e0e8: ea0011bc     	b	0x927e0 <.text+0x826e0> @ imm = #0x46f0
   8e0ec: 005838d0     	ldrsbeq	r3, [r8], #-128
   8e0f0: e1a00005     	mov	r0, r5
   8e0f4: eb00251b     	bl	0x97568 <.text+0x87468> @ imm = #0x946c
   8e0f8: e5941000     	ldr	r1, [r4]
   8e0fc: e2412001     	sub	r2, r1, #1
   8e100: e0010291     	mul	r1, r1, r2
   8e104: e3110001     	tst	r1, #1
   8e108: 0a000005     	beq	0x8e124 <.text+0x7e024> @ imm = #0x14
   8e10c: e5991000     	ldr	r1, [r9]
   8e110: e3510009     	cmp	r1, #9
   8e114: da000002     	ble	0x8e124 <.text+0x7e024> @ imm = #0x8
   8e118: e1a00005     	mov	r0, r5
   8e11c: eb002511     	bl	0x97568 <.text+0x87468> @ imm = #0x9444
   8e120: eafffff2     	b	0x8e0f0 <.text+0x7dff0> @ imm = #-0x38
   8e124: e3500000     	cmp	r0, #0
   8e128: 0a000005     	beq	0x8e144 <.text+0x7e044> @ imm = #0x14
   8e12c: e3a00005     	mov	r0, #5
   8e130: ea00079e     	b	0x8ffb0 <.text+0x7feb0> @ imm = #0x1e78
   8e134: 00559d6b     	subseq	r9, r5, r11, ror #26
   8e138: 00559cd5     	ldrsbeq	r9, [r5], #-197
   8e13c: 00559cfb     	ldrsheq	r9, [r5], #-203
   8e140: 0055a2c0     	subseq	r10, r5, r0, asr #5
   8e144: e59f5fe4     	ldr	r5, [pc, #0xfe4]        @ 0x8f130 <.text+0x7f030>
   8e148: e302004c     	movw	r0, #0x204c
   8e14c: e08f5005     	add	r5, pc, r5
   8e150: e7950000     	ldr	r0, [r5, r0]
   8e154: e3500000     	cmp	r0, #0
   8e158: 0a000046     	beq	0x8e278 <.text+0x7e178> @ imm = #0x118
   8e15c: e3500001     	cmp	r0, #1
   8e160: 0a001283     	beq	0x92b74 <.text+0x82a74> @ imm = #0x4a0c
   8e164: e3500002     	cmp	r0, #2
   8e168: 1a001652     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x5948
   8e16c: e3020034     	movw	r0, #0x2034
   8e170: e7950000     	ldr	r0, [r5, r0]
   8e174: e3500000     	cmp	r0, #0
   8e178: 0a00000a     	beq	0x8e1a8 <.text+0x7e0a8> @ imm = #0x28
   8e17c: e3500001     	cmp	r0, #1
   8e180: 1a00002a     	bne	0x8e230 <.text+0x7e130> @ imm = #0xa8
   8e184: e3020030     	movw	r0, #0x2030
   8e188: eeb00b48     	vmov.f64	d0, d8
   8e18c: e7951000     	ldr	r1, [r5, r0]
   8e190: e2850008     	add	r0, r5, #8
   8e194: eb00408b     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0x1022c
   8e198: e3500000     	cmp	r0, #0
   8e19c: 1a000006     	bne	0x8e1bc <.text+0x7e0bc> @ imm = #0x18
   8e1a0: ea00002f     	b	0x8e264 <.text+0x7e164> @ imm = #0xbc
   8e1a4: 005837f8     	ldrsheq	r3, [r8], #-120
   8e1a8: eeb00b48     	vmov.f64	d0, d8
   8e1ac: e2850008     	add	r0, r5, #8
   8e1b0: eb004cec     	bl	0xa1568 <.text+0x91468> @ imm = #0x133b0
   8e1b4: e3500000     	cmp	r0, #0
   8e1b8: 0a000029     	beq	0x8e264 <.text+0x7e164> @ imm = #0xa4
   8e1bc: e5940000     	ldr	r0, [r4]
   8e1c0: e59f5fe4     	ldr	r5, [pc, #0xfe4]        @ 0x8f1ac <.text+0x7f0ac>
   8e1c4: e2401001     	sub	r1, r0, #1
   8e1c8: e08f5005     	add	r5, pc, r5
   8e1cc: e0000190     	mul	r0, r0, r1
   8e1d0: e3100001     	tst	r0, #1
   8e1d4: 0a001257     	beq	0x92b38 <.text+0x82a38> @ imm = #0x495c
   8e1d8: e5990000     	ldr	r0, [r9]
   8e1dc: e3500009     	cmp	r0, #9
   8e1e0: ca00125f     	bgt	0x92b64 <.text+0x82a64> @ imm = #0x497c
   8e1e4: ea001253     	b	0x92b38 <.text+0x82a38> @ imm = #0x494c
   8e1e8: 005837d0     	ldrsbeq	r3, [r8], #-112
   8e1ec: 00559c2a     	subseq	r9, r5, r10, lsr #24
   8e1f0: 00559c29     	subseq	r9, r5, r9, lsr #24
   8e1f4: 00559c4f     	subseq	r9, r5, pc, asr #24
   8e1f8: 0055a272     	subseq	r10, r5, r2, ror r2
   8e1fc: 00559c77     	subseq	r9, r5, r7, ror r12
   8e200: 00559be1     	subseq	r9, r5, r1, ror #23
   8e204: 00559c07     	subseq	r9, r5, r7, lsl #24
   8e208: 0055a246     	subseq	r10, r5, r6, asr #4
   8e20c: 00559c2f     	subseq	r9, r5, pc, lsr #24
   8e210: 00559b99     	<unknown>
   8e214: 00559bbf     	ldrheq	r9, [r5], #-191
   8e218: 0055a1b4     	ldrheq	r10, [r5], #-20
   8e21c: 0058572c     	subseq	r5, r8, r12, lsr #14
   8e220: 00559bdf     	ldrsbeq	r9, [r5], #-191
   8e224: 00559b49     	subseq	r9, r5, r9, asr #22
   8e228: 00559b6f     	subseq	r9, r5, pc, ror #22
   8e22c: 0055a0d4     	ldrsbeq	r10, [r5], #-4
   8e230: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x8f20c <.text+0x7f10c>
   8e234: e3a06002     	mov	r6, #2
   8e238: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x8f210 <.text+0x7f110>
   8e23c: e59f2fd0     	ldr	r2, [pc, #0xfd0]        @ 0x8f214 <.text+0x7f114>
   8e240: e08f0000     	add	r0, pc, r0
   8e244: e59f3fcc     	ldr	r3, [pc, #0xfcc]        @ 0x8f218 <.text+0x7f118>
   8e248: e08f1001     	add	r1, pc, r1
   8e24c: e08f2002     	add	r2, pc, r2
   8e250: e58d6000     	str	r6, [sp]
   8e254: e08f3003     	add	r3, pc, r3
   8e258: e58d3004     	str	r3, [sp, #0x4]
   8e25c: e3a03e75     	mov	r3, #1872
   8e260: eb01af97     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6be5c
   8e264: e59f5fe4     	ldr	r5, [pc, #0xfe4]        @ 0x8f250 <.text+0x7f150>
   8e268: e302004c     	movw	r0, #0x204c
   8e26c: e3a01000     	mov	r1, #0
   8e270: e08f5005     	add	r5, pc, r5
   8e274: e7851000     	str	r1, [r5, r0]
   8e278: e3020034     	movw	r0, #0x2034
   8e27c: e7950000     	ldr	r0, [r5, r0]
   8e280: e3500000     	cmp	r0, #0
   8e284: 0a00002e     	beq	0x8e344 <.text+0x7e244> @ imm = #0xb8
   8e288: e3500001     	cmp	r0, #1
   8e28c: 1a000035     	bne	0x8e368 <.text+0x7e268> @ imm = #0xd4
   8e290: e3020030     	movw	r0, #0x2030
   8e294: eeb00b48     	vmov.f64	d0, d8
   8e298: e7951000     	ldr	r1, [r5, r0]
   8e29c: e2850008     	add	r0, r5, #8
   8e2a0: eb0040b0     	bl	0x9e568 <.text+0x8e468> @ imm = #0x102c0
   8e2a4: e1a06000     	mov	r6, r0
   8e2a8: e5955008     	ldr	r5, [r5, #0x8]
   8e2ac: eb01d1f1     	bl	0x102a78 <.text+0xf2978> @ imm = #0x747c4
   8e2b0: e3a01000     	mov	r1, #0
   8e2b4: e1550000     	cmp	r5, r0
   8e2b8: a3001001     	movwge	r1, #0x1
   8e2bc: e3560000     	cmp	r6, #0
   8e2c0: 1a0012a3     	bne	0x92d54 <.text+0x82c54> @ imm = #0x4a8c
   8e2c4: e5940000     	ldr	r0, [r4]
   8e2c8: e2402001     	sub	r2, r0, #1
   8e2cc: e0000290     	mul	r0, r0, r2
   8e2d0: e3100001     	tst	r0, #1
   8e2d4: 0a000002     	beq	0x8e2e4 <.text+0x7e1e4> @ imm = #0x8
   8e2d8: e5990000     	ldr	r0, [r9]
   8e2dc: e3500009     	cmp	r0, #9
   8e2e0: cafffff7     	bgt	0x8e2c4 <.text+0x7e1c4> @ imm = #-0x24
   8e2e4: e3510000     	cmp	r1, #0
   8e2e8: 0a00002f     	beq	0x8e3ac <.text+0x7e2ac> @ imm = #0xbc
   8e2ec: e59d00c0     	ldr	r0, [sp, #0xc0]
   8e2f0: e3a01001     	mov	r1, #1
   8e2f4: e3a05001     	mov	r5, #1
   8e2f8: eb001c0d     	bl	0x95334 <.text+0x85234> @ imm = #0x7034
   8e2fc: e3500000     	cmp	r0, #0
   8e300: 0a000002     	beq	0x8e310 <.text+0x7e210> @ imm = #0x8
   8e304: e59d00b8     	ldr	r0, [sp, #0xb8]
   8e308: e3001fa1     	movw	r1, #0xfa1
   8e30c: ebfeee61     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x4467c
   8e310: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x8f2e0 <.text+0x7f1e0>
   8e314: e59f1fc8     	ldr	r1, [pc, #0xfc8]        @ 0x8f2e4 <.text+0x7f1e4>
   8e318: e59f2fc8     	ldr	r2, [pc, #0xfc8]        @ 0x8f2e8 <.text+0x7f1e8>
   8e31c: e08f0000     	add	r0, pc, r0
   8e320: e59f3fc4     	ldr	r3, [pc, #0xfc4]        @ 0x8f2ec <.text+0x7f1ec>
   8e324: e08f1001     	add	r1, pc, r1
   8e328: e08f2002     	add	r2, pc, r2
   8e32c: e58d5000     	str	r5, [sp]
   8e330: e08f3003     	add	r3, pc, r3
   8e334: e58d3004     	str	r3, [sp, #0x4]
   8e338: e30134c6     	movw	r3, #0x14c6
   8e33c: eb01af60     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6bd80
   8e340: ea001232     	b	0x92c10 <.text+0x82b10> @ imm = #0x48c8
   8e344: e5940000     	ldr	r0, [r4]
   8e348: e2401001     	sub	r1, r0, #1
   8e34c: e0000190     	mul	r0, r0, r1
   8e350: e3100001     	tst	r0, #1
   8e354: 0a001260     	beq	0x92cdc <.text+0x82bdc> @ imm = #0x4980
   8e358: e5990000     	ldr	r0, [r9]
   8e35c: e3500009     	cmp	r0, #9
   8e360: ca001272     	bgt	0x92d30 <.text+0x82c30> @ imm = #0x49c8
   8e364: ea00125c     	b	0x92cdc <.text+0x82bdc> @ imm = #0x4970
   8e368: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x8f35c <.text+0x7f25c>
   8e36c: e3a06002     	mov	r6, #2
   8e370: e59f1fe8     	ldr	r1, [pc, #0xfe8]        @ 0x8f360 <.text+0x7f260>
   8e374: e59f2fe8     	ldr	r2, [pc, #0xfe8]        @ 0x8f364 <.text+0x7f264>
   8e378: e08f0000     	add	r0, pc, r0
   8e37c: e59f3fe4     	ldr	r3, [pc, #0xfe4]        @ 0x8f368 <.text+0x7f268>
   8e380: e08f1001     	add	r1, pc, r1
   8e384: e08f2002     	add	r2, pc, r2
   8e388: e58d6000     	str	r6, [sp]
   8e38c: e08f3003     	add	r3, pc, r3
   8e390: e58d3004     	str	r3, [sp, #0x4]
   8e394: e300376d     	movw	r3, #0x76d
   8e398: eb01af49     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6bd24
   8e39c: e5955008     	ldr	r5, [r5, #0x8]
   8e3a0: eb01d1b4     	bl	0x102a78 <.text+0xf2978> @ imm = #0x746d0
   8e3a4: e1550000     	cmp	r5, r0
   8e3a8: aaffffcf     	bge	0x8e2ec <.text+0x7e1ec> @ imm = #-0xc4
   8e3ac: e59d0064     	ldr	r0, [sp, #0x64]
   8e3b0: e5900000     	ldr	r0, [r0]
   8e3b4: e59f1ffc     	ldr	r1, [pc, #0xffc]        @ 0x8f3b8 <.text+0x7f2b8>
   8e3b8: e08f1001     	add	r1, pc, r1
   8e3bc: e1a05001     	mov	r5, r1
   8e3c0: e5911008     	ldr	r1, [r1, #0x8]
   8e3c4: e0801001     	add	r1, r0, r1
   8e3c8: e59d00bc     	ldr	r0, [sp, #0xbc]
   8e3cc: ebff086d     	bl	0x50588 <.text+0x40488> @ imm = #-0x3de4c
   8e3d0: e5850008     	str	r0, [r5, #0x8]
   8e3d4: e1a0100a     	mov	r1, r10
   8e3d8: e59d00c0     	ldr	r0, [sp, #0xc0]
   8e3dc: eb001a1e     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x6878
   8e3e0: e3500000     	cmp	r0, #0
   8e3e4: 0a0012c9     	beq	0x92f10 <.text+0x82e10> @ imm = #0x4b24
   8e3e8: e5940000     	ldr	r0, [r4]
   8e3ec: e2401001     	sub	r1, r0, #1
   8e3f0: e0000190     	mul	r0, r0, r1
   8e3f4: e3100001     	tst	r0, #1
   8e3f8: 0a001272     	beq	0x92dc8 <.text+0x82cc8> @ imm = #0x49c8
   8e3fc: e5990000     	ldr	r0, [r9]
   8e400: e3500009     	cmp	r0, #9
   8e404: ca001287     	bgt	0x92e28 <.text+0x82d28> @ imm = #0x4a1c
   8e408: ea00126e     	b	0x92dc8 <.text+0x82cc8> @ imm = #0x49b8
   8e40c: 005855b4     	ldrheq	r5, [r8], #-84
   8e410: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x8f404 <.text+0x7f304>
   8e414: e3a07001     	mov	r7, #1
   8e418: e59f1fe8     	ldr	r1, [pc, #0xfe8]        @ 0x8f408 <.text+0x7f308>
   8e41c: e59f2fe8     	ldr	r2, [pc, #0xfe8]        @ 0x8f40c <.text+0x7f30c>
   8e420: e08f0000     	add	r0, pc, r0
   8e424: e59f3fe4     	ldr	r3, [pc, #0xfe4]        @ 0x8f410 <.text+0x7f310>
   8e428: e08f1001     	add	r1, pc, r1
   8e42c: e08f2002     	add	r2, pc, r2
   8e430: e58d7000     	str	r7, [sp]
   8e434: e08f3003     	add	r3, pc, r3
   8e438: e58d3004     	str	r3, [sp, #0x4]
   8e43c: e301350c     	movw	r3, #0x150c
   8e440: eb01af1f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6bc7c
   8e444: e5940000     	ldr	r0, [r4]
   8e448: e3007fa1     	movw	r7, #0xfa1
   8e44c: e2401001     	sub	r1, r0, #1
   8e450: e0000190     	mul	r0, r0, r1
   8e454: e3100001     	tst	r0, #1
   8e458: 0a000011     	beq	0x8e4a4 <.text+0x7e3a4> @ imm = #0x44
   8e45c: e5990000     	ldr	r0, [r9]
   8e460: e350000a     	cmp	r0, #10
   8e464: ba00000e     	blt	0x8e4a4 <.text+0x7e3a4> @ imm = #0x38
   8e468: e59f0ff0     	ldr	r0, [pc, #0xff0]        @ 0x8f460 <.text+0x7f360>
   8e46c: e3a07001     	mov	r7, #1
   8e470: e59f1fec     	ldr	r1, [pc, #0xfec]        @ 0x8f464 <.text+0x7f364>
   8e474: e59f2fec     	ldr	r2, [pc, #0xfec]        @ 0x8f468 <.text+0x7f368>
   8e478: e08f0000     	add	r0, pc, r0
   8e47c: e59f3fe8     	ldr	r3, [pc, #0xfe8]        @ 0x8f46c <.text+0x7f36c>
   8e480: e08f1001     	add	r1, pc, r1
   8e484: e08f2002     	add	r2, pc, r2
   8e488: e58d7000     	str	r7, [sp]
   8e48c: e08f3003     	add	r3, pc, r3
   8e490: e58d3004     	str	r3, [sp, #0x4]
   8e494: e301350c     	movw	r3, #0x150c
   8e498: eb01af09     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6bc24
   8e49c: eaffffdb     	b	0x8e410 <.text+0x7e310> @ imm = #-0x94
   8e4a0: 00583524     	subseq	r3, r8, r4, lsr #10
   8e4a4: e5940000     	ldr	r0, [r4]
   8e4a8: e59f5fc0     	ldr	r5, [pc, #0xfc0]        @ 0x8f470 <.text+0x7f370>
   8e4ac: e2401001     	sub	r1, r0, #1
   8e4b0: e08f5005     	add	r5, pc, r5
   8e4b4: e0000190     	mul	r0, r0, r1
   8e4b8: e3100001     	tst	r0, #1
   8e4bc: 0a001335     	beq	0x93198 <.text+0x83098> @ imm = #0x4cd4
   8e4c0: e5990000     	ldr	r0, [r9]
   8e4c4: e3500009     	cmp	r0, #9
   8e4c8: ca00134d     	bgt	0x93204 <.text+0x83104> @ imm = #0x4d34
   8e4cc: ea001331     	b	0x93198 <.text+0x83098> @ imm = #0x4cc4
   8e4d0: e59f6f9c     	ldr	r6, [pc, #0xf9c]        @ 0x8f474 <.text+0x7f374>
   8e4d4: e08f6006     	add	r6, pc, r6
   8e4d8: e1a00006     	mov	r0, r6
   8e4dc: eb145f09     	bl	0x5a6108 <.text+0x596008> @ imm = #0x517c24
   8e4e0: e1a00006     	mov	r0, r6
   8e4e4: e5d75000     	ldrb	r5, [r7]
   8e4e8: eb146075     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5181d4
   8e4ec: e5940000     	ldr	r0, [r4]
   8e4f0: e2401001     	sub	r1, r0, #1
   8e4f4: e0000190     	mul	r0, r0, r1
   8e4f8: e3100001     	tst	r0, #1
   8e4fc: 0a000009     	beq	0x8e528 <.text+0x7e428> @ imm = #0x24
   8e500: e5990000     	ldr	r0, [r9]
   8e504: e3500009     	cmp	r0, #9
   8e508: da000006     	ble	0x8e528 <.text+0x7e428> @ imm = #0x18
   8e50c: e59f6f64     	ldr	r6, [pc, #0xf64]        @ 0x8f478 <.text+0x7f378>
   8e510: e08f6006     	add	r6, pc, r6
   8e514: e1a00006     	mov	r0, r6
   8e518: eb145efa     	bl	0x5a6108 <.text+0x596008> @ imm = #0x517be8
   8e51c: e1a00006     	mov	r0, r6
   8e520: eb146067     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x51819c
   8e524: eaffffe9     	b	0x8e4d0 <.text+0x7e3d0> @ imm = #-0x5c
   8e528: e3550000     	cmp	r5, #0
   8e52c: e59d50c0     	ldr	r5, [sp, #0xc0]
   8e530: 0a000008     	beq	0x8e558 <.text+0x7e458> @ imm = #0x20
   8e534: e5940000     	ldr	r0, [r4]
   8e538: e2401001     	sub	r1, r0, #1
   8e53c: e0000190     	mul	r0, r0, r1
   8e540: e3100001     	tst	r0, #1
   8e544: 0a001342     	beq	0x93254 <.text+0x83154> @ imm = #0x4d08
   8e548: e5990000     	ldr	r0, [r9]
   8e54c: e3500009     	cmp	r0, #9
   8e550: ca00134e     	bgt	0x93290 <.text+0x83190> @ imm = #0x4d38
   8e554: ea00133e     	b	0x93254 <.text+0x83154> @ imm = #0x4cf8
   8e558: e5940000     	ldr	r0, [r4]
   8e55c: e59f2fec     	ldr	r2, [pc, #0xfec]        @ 0x8f550 <.text+0x7f450>
   8e560: e2401001     	sub	r1, r0, #1
   8e564: e08f2002     	add	r2, pc, r2
   8e568: e0000190     	mul	r0, r0, r1
   8e56c: e3100001     	tst	r0, #1
   8e570: e5940000     	ldr	r0, [r4]
   8e574: e2401001     	sub	r1, r0, #1
   8e578: e0010190     	mul	r1, r0, r1
   8e57c: e3020034     	movw	r0, #0x2034
   8e580: e7920000     	ldr	r0, [r2, r0]
   8e584: e3110001     	tst	r1, #1
   8e588: 0a000002     	beq	0x8e598 <.text+0x7e498> @ imm = #0x8
   8e58c: e5991000     	ldr	r1, [r9]
   8e590: e3510009     	cmp	r1, #9
   8e594: cafffff5     	bgt	0x8e570 <.text+0x7e470> @ imm = #-0x2c
   8e598: e3500001     	cmp	r0, #1
   8e59c: 0a00000b     	beq	0x8e5d0 <.text+0x7e4d0> @ imm = #0x2c
   8e5a0: e3500000     	cmp	r0, #0
   8e5a4: 1affffe2     	bne	0x8e534 <.text+0x7e434> @ imm = #-0x78
   8e5a8: e5940000     	ldr	r0, [r4]
   8e5ac: e2401001     	sub	r1, r0, #1
   8e5b0: e0000190     	mul	r0, r0, r1
   8e5b4: e3100001     	tst	r0, #1
   8e5b8: 0a001369     	beq	0x93364 <.text+0x83264> @ imm = #0x4da4
   8e5bc: e5990000     	ldr	r0, [r9]
   8e5c0: e3500009     	cmp	r0, #9
   8e5c4: ca001373     	bgt	0x93398 <.text+0x83298> @ imm = #0x4dcc
   8e5c8: ea001365     	b	0x93364 <.text+0x83264> @ imm = #0x4d94
   8e5cc: 005833e4     	subseq	r3, r8, r4, ror #7
   8e5d0: e5940000     	ldr	r0, [r4]
   8e5d4: e2401001     	sub	r1, r0, #1
   8e5d8: e0000190     	mul	r0, r0, r1
   8e5dc: e3100001     	tst	r0, #1
   8e5e0: 0a001372     	beq	0x933b0 <.text+0x832b0> @ imm = #0x4dc8
   8e5e4: e5990000     	ldr	r0, [r9]
   8e5e8: e3500009     	cmp	r0, #9
   8e5ec: ca00137e     	bgt	0x933ec <.text+0x832ec> @ imm = #0x4df8
   8e5f0: ea00136e     	b	0x933b0 <.text+0x832b0> @ imm = #0x4db8
   8e5f4: 005598b3     	ldrheq	r9, [r5], #-131
   8e5f8: 0055981d     	subseq	r9, r5, sp, lsl r8
   8e5fc: 00559843     	subseq	r9, r5, r3, asr #16
   8e600: 00559e82     	subseq	r9, r5, r2, lsl #29
   8e604: e5940000     	ldr	r0, [r4]
   8e608: e3022048     	movw	r2, #0x2048
   8e60c: e3a03001     	mov	r3, #1
   8e610: e2401001     	sub	r1, r0, #1
   8e614: e7c73002     	strb	r3, [r7, r2]
   8e618: e0010190     	mul	r1, r0, r1
   8e61c: e5990000     	ldr	r0, [r9]
   8e620: e3110001     	tst	r1, #1
   8e624: 0afff958     	beq	0x8cb8c <.text+0x7ca8c> @ imm = #-0x1aa0
   8e628: e3500009     	cmp	r0, #9
   8e62c: dafff956     	ble	0x8cb8c <.text+0x7ca8c> @ imm = #-0x1aa8
   8e630: e3020048     	movw	r0, #0x2048
   8e634: e3a01001     	mov	r1, #1
   8e638: e7c71000     	strb	r1, [r7, r0]
   8e63c: eafffff0     	b	0x8e604 <.text+0x7e504> @ imm = #-0x40
   8e640: eb01ae9f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ba7c
   8e644: e1a00005     	mov	r0, r5
   8e648: ebff624c     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x276d0
   8e64c: e3a00000     	mov	r0, #0
   8e650: e5c60000     	strb	r0, [r6]
   8e654: ea001517     	b	0x93ab8 <.text+0x839b8> @ imm = #0x545c
   8e658: 005853a0     	subseq	r5, r8, r0, lsr #7
   8e65c: 0058535c     	subseq	r5, r8, r12, asr r3
   8e660: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x8f64c <.text+0x7f54c>
   8e664: e3a07001     	mov	r7, #1
   8e668: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x8f650 <.text+0x7f550>
   8e66c: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x8f654 <.text+0x7f554>
   8e670: e08f0000     	add	r0, pc, r0
   8e674: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x8f658 <.text+0x7f558>
   8e678: e08f1001     	add	r1, pc, r1
   8e67c: e08f2002     	add	r2, pc, r2
   8e680: e58d7000     	str	r7, [sp]
   8e684: e08f3003     	add	r3, pc, r3
   8e688: e58d3004     	str	r3, [sp, #0x4]
   8e68c: e301323d     	movw	r3, #0x123d
   8e690: eb01ae8b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ba2c
   8e694: e59d104c     	ldr	r1, [sp, #0x4c]
   8e698: e30100b4     	movw	r0, #0x10b4
   8e69c: e0810000     	add	r0, r1, r0
   8e6a0: e30017da     	movw	r1, #0x7da
   8e6a4: ebfeed7b     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x44a14
   8e6a8: e5940000     	ldr	r0, [r4]
   8e6ac: e2401001     	sub	r1, r0, #1
   8e6b0: e0000190     	mul	r0, r0, r1
   8e6b4: e3100001     	tst	r0, #1
   8e6b8: 0afffb0c     	beq	0x8d2f0 <.text+0x7d1f0> @ imm = #-0x13d0
   8e6bc: e5990000     	ldr	r0, [r9]
   8e6c0: e3500009     	cmp	r0, #9
   8e6c4: dafffb09     	ble	0x8d2f0 <.text+0x7d1f0> @ imm = #-0x13dc
   8e6c8: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x8f6a4 <.text+0x7f5a4>
   8e6cc: e3a07001     	mov	r7, #1
   8e6d0: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x8f6a8 <.text+0x7f5a8>
   8e6d4: e59f2fd0     	ldr	r2, [pc, #0xfd0]        @ 0x8f6ac <.text+0x7f5ac>
   8e6d8: e08f0000     	add	r0, pc, r0
   8e6dc: e59f3fcc     	ldr	r3, [pc, #0xfcc]        @ 0x8f6b0 <.text+0x7f5b0>
   8e6e0: e08f1001     	add	r1, pc, r1
   8e6e4: e08f2002     	add	r2, pc, r2
   8e6e8: e58d7000     	str	r7, [sp]
   8e6ec: e08f3003     	add	r3, pc, r3
   8e6f0: e58d3004     	str	r3, [sp, #0x4]
   8e6f4: e301323d     	movw	r3, #0x123d
   8e6f8: eb01ae71     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6b9c4
   8e6fc: e59d104c     	ldr	r1, [sp, #0x4c]
   8e700: e30100b4     	movw	r0, #0x10b4
   8e704: e0810000     	add	r0, r1, r0
   8e708: e30017da     	movw	r1, #0x7da
   8e70c: ebfeed61     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x44a7c
   8e710: eaffffd2     	b	0x8e660 <.text+0x7e560> @ imm = #-0xb8
   8e714: 00583298     	<unknown>
   8e718: 00583274     	subseq	r3, r8, r4, ror r2
   8e71c: e1a00007     	mov	r0, r7
   8e720: eb141559     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x505564
   8e724: e5940000     	ldr	r0, [r4]
   8e728: e3a02000     	mov	r2, #0
   8e72c: e50b214c     	str	r2, [r11, #-0x14c]
   8e730: e2401001     	sub	r1, r0, #1
   8e734: e0010190     	mul	r1, r0, r1
   8e738: e5990000     	ldr	r0, [r9]
   8e73c: e3110001     	tst	r1, #1
   8e740: 0a000008     	beq	0x8e768 <.text+0x7e668> @ imm = #0x20
   8e744: e3500009     	cmp	r0, #9
   8e748: da000006     	ble	0x8e768 <.text+0x7e668> @ imm = #0x18
   8e74c: e1a00007     	mov	r0, r7
   8e750: eb14154d     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x505534
   8e754: e3a00000     	mov	r0, #0
   8e758: e50b014c     	str	r0, [r11, #-0x14c]
   8e75c: eaffffee     	b	0x8e71c <.text+0x7e61c> @ imm = #-0x48
   8e760: 00583264     	subseq	r3, r8, r4, ror #4
   8e764: 00583230     	subseq	r3, r8, r0, lsr r2
   8e768: e5940000     	ldr	r0, [r4]
   8e76c: e59f3fcc     	ldr	r3, [pc, #0xfcc]        @ 0x8f740 <.text+0x7f640>
   8e770: e2401001     	sub	r1, r0, #1
   8e774: e08f3003     	add	r3, pc, r3
   8e778: e0000190     	mul	r0, r0, r1
   8e77c: e3100001     	tst	r0, #1
   8e780: 0a000002     	beq	0x8e790 <.text+0x7e690> @ imm = #0x8
   8e784: e5990000     	ldr	r0, [r9]
   8e788: e3500009     	cmp	r0, #9
   8e78c: ca000009     	bgt	0x8e7b8 <.text+0x7e6b8> @ imm = #0x24
   8e790: e5940000     	ldr	r0, [r4]
   8e794: e3a02000     	mov	r2, #0
   8e798: e50b214c     	str	r2, [r11, #-0x14c]
   8e79c: e2401001     	sub	r1, r0, #1
   8e7a0: e0010190     	mul	r1, r0, r1
   8e7a4: e5990000     	ldr	r0, [r9]
   8e7a8: e3110001     	tst	r1, #1
   8e7ac: 0a000007     	beq	0x8e7d0 <.text+0x7e6d0> @ imm = #0x1c
   8e7b0: e3500009     	cmp	r0, #9
   8e7b4: da000005     	ble	0x8e7d0 <.text+0x7e6d0> @ imm = #0x14
   8e7b8: e3a00000     	mov	r0, #0
   8e7bc: e50b014c     	str	r0, [r11, #-0x14c]
   8e7c0: eafffff2     	b	0x8e790 <.text+0x7e690> @ imm = #-0x38
   8e7c4: 005596f7     	ldrsheq	r9, [r5], #-103
   8e7c8: 00559665     	subseq	r9, r5, r5, ror #12
   8e7cc: 00559687     	subseq	r9, r5, r7, lsl #13
   8e7d0: e5960018     	ldr	r0, [r6, #0x18]
   8e7d4: e5935004     	ldr	r5, [r3, #0x4]
   8e7d8: eb00628b     	bl	0xa720c <.text+0x9710c> @ imm = #0x18a2c
   8e7dc: e1a06000     	mov	r6, r0
   8e7e0: eb01bfa0     	bl	0xfe668 <.text+0xee568> @ imm = #0x6fe80
   8e7e4: e59feffc     	ldr	lr, [pc, #0xffc]        @ 0x8f7e8 <.text+0x7f6e8>
   8e7e8: e3500001     	cmp	r0, #1
   8e7ec: e595100c     	ldr	r1, [r5, #0xc]
   8e7f0: e08fe00e     	add	lr, pc, lr
   8e7f4: e5952010     	ldr	r2, [r5, #0x10]
   8e7f8: e58e2008     	str	r2, [lr, #0x8]
   8e7fc: e58e100c     	str	r1, [lr, #0xc]
   8e800: ba000025     	blt	0x8e89c <.text+0x7e79c> @ imm = #0x94
   8e804: e5962010     	ldr	r2, [r6, #0x10]
   8e808: e3a0c000     	mov	r12, #0
   8e80c: ea000005     	b	0x8e828 <.text+0x7e728> @ imm = #0x14
   8e810: 005596a3     	subseq	r9, r5, r3, lsr #13
   8e814: 00559611     	subseq	r9, r5, r1, lsl r6
   8e818: 00559633     	subseq	r9, r5, r3, lsr r6
   8e81c: e28cc001     	add	r12, r12, #1
   8e820: e15c0000     	cmp	r12, r0
   8e824: 0a00001c     	beq	0x8e89c <.text+0x7e79c> @ imm = #0x70
   8e828: e5943000     	ldr	r3, [r4]
   8e82c: e2437001     	sub	r7, r3, #1
   8e830: e0030793     	mul	r3, r3, r7
   8e834: e3130001     	tst	r3, #1
   8e838: e5943000     	ldr	r3, [r4]
   8e83c: e2437001     	sub	r7, r3, #1
   8e840: e0030793     	mul	r3, r3, r7
   8e844: e3130001     	tst	r3, #1
   8e848: 0a000002     	beq	0x8e858 <.text+0x7e758> @ imm = #0x8
   8e84c: e5993000     	ldr	r3, [r9]
   8e850: e3530009     	cmp	r3, #9
   8e854: cafffff7     	bgt	0x8e838 <.text+0x7e738> @ imm = #-0x24
   8e858: e3520001     	cmp	r2, #1
   8e85c: baffffee     	blt	0x8e81c <.text+0x7e71c> @ imm = #-0x48
   8e860: e59e2020     	ldr	r2, [lr, #0x20]
   8e864: e08c310c     	add	r3, r12, r12, lsl #2
   8e868: e3a07000     	mov	r7, #0
   8e86c: e3a05000     	mov	r5, #0
   8e870: e0822183     	add	r2, r2, r3, lsl #3
   8e874: e2823020     	add	r3, r2, #32
   8e878: e5932000     	ldr	r2, [r3]
   8e87c: e2855001     	add	r5, r5, #1
   8e880: e59e100c     	ldr	r1, [lr, #0xc]
   8e884: e7821007     	str	r1, [r2, r7]
   8e888: e2877038     	add	r7, r7, #56
   8e88c: e5962010     	ldr	r2, [r6, #0x10]
   8e890: e1550002     	cmp	r5, r2
   8e894: bafffff7     	blt	0x8e878 <.text+0x7e778> @ imm = #-0x24
   8e898: eaffffdf     	b	0x8e81c <.text+0x7e71c> @ imm = #-0x84
   8e89c: e3a00002     	mov	r0, #2
   8e8a0: e3a01000     	mov	r1, #0
   8e8a4: eb0019d2     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x6748
   8e8a8: ea001482     	b	0x93ab8 <.text+0x839b8> @ imm = #0x5208
   8e8ac: 005830dc     	ldrsbeq	r3, [r8], #-12
   8e8b0: e5960018     	ldr	r0, [r6, #0x18]
   8e8b4: eb00624e     	bl	0xa71f4 <.text+0x970f4> @ imm = #0x18938
   8e8b8: e1a07000     	mov	r7, r0
   8e8bc: e5940000     	ldr	r0, [r4]
   8e8c0: e2401001     	sub	r1, r0, #1
   8e8c4: e0010190     	mul	r1, r0, r1
   8e8c8: e3010049     	movw	r0, #0x1049
   8e8cc: e7d60000     	ldrb	r0, [r6, r0]
   8e8d0: e3110001     	tst	r1, #1
   8e8d4: 0a000009     	beq	0x8e900 <.text+0x7e800> @ imm = #0x24
   8e8d8: e5991000     	ldr	r1, [r9]
   8e8dc: e3510009     	cmp	r1, #9
   8e8e0: da000006     	ble	0x8e900 <.text+0x7e800> @ imm = #0x18
   8e8e4: e5960018     	ldr	r0, [r6, #0x18]
   8e8e8: eb006241     	bl	0xa71f4 <.text+0x970f4> @ imm = #0x18904
   8e8ec: eaffffef     	b	0x8e8b0 <.text+0x7e7b0> @ imm = #-0x44
   8e8f0: 00559567     	subseq	r9, r5, r7, ror #10
   8e8f4: 005594d1     	ldrsbeq	r9, [r5], #-65
   8e8f8: 005594f7     	ldrsheq	r9, [r5], #-71
   8e8fc: 00559b36     	subseq	r9, r5, r6, lsr r11
   8e900: e59f3ffc     	ldr	r3, [pc, #0xffc]        @ 0x8f904 <.text+0x7f804>
   8e904: e3500000     	cmp	r0, #0
   8e908: e08f3003     	add	r3, pc, r3
   8e90c: 1a001469     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x51a4
   8e910: e5940000     	ldr	r0, [r4]
   8e914: e2401001     	sub	r1, r0, #1
   8e918: e0000190     	mul	r0, r0, r1
   8e91c: e3100001     	tst	r0, #1
   8e920: 0a000002     	beq	0x8e930 <.text+0x7e830> @ imm = #0x8
   8e924: e5990000     	ldr	r0, [r9]
   8e928: e3500009     	cmp	r0, #9
   8e92c: ca000012     	bgt	0x8e97c <.text+0x7e87c> @ imm = #0x48
   8e930: e9930005     	ldmib	r3, {r0, r2}
   8e934: e5901014     	ldr	r1, [r0, #0x14]
   8e938: e2860050     	add	r0, r6, #80
   8e93c: e1520001     	cmp	r2, r1
   8e940: b1a01002     	movlt	r1, r2
   8e944: ebff070f     	bl	0x50588 <.text+0x40488> @ imm = #-0x3e3c4
   8e948: e1a01000     	mov	r1, r0
   8e94c: e1a00006     	mov	r0, r6
   8e950: eb0018c1     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x6304
   8e954: e59f3ff4     	ldr	r3, [pc, #0xff4]        @ 0x8f950 <.text+0x7f850>
   8e958: e5941000     	ldr	r1, [r4]
   8e95c: e08f3003     	add	r3, pc, r3
   8e960: e2412001     	sub	r2, r1, #1
   8e964: e0010291     	mul	r1, r1, r2
   8e968: e3110001     	tst	r1, #1
   8e96c: 0a000015     	beq	0x8e9c8 <.text+0x7e8c8> @ imm = #0x54
   8e970: e5991000     	ldr	r1, [r9]
   8e974: e3510009     	cmp	r1, #9
   8e978: da000012     	ble	0x8e9c8 <.text+0x7e8c8> @ imm = #0x48
   8e97c: e9930005     	ldmib	r3, {r0, r2}
   8e980: e5901014     	ldr	r1, [r0, #0x14]
   8e984: e2860050     	add	r0, r6, #80
   8e988: e1520001     	cmp	r2, r1
   8e98c: b1a01002     	movlt	r1, r2
   8e990: ebff06fc     	bl	0x50588 <.text+0x40488> @ imm = #-0x3e410
   8e994: e1a01000     	mov	r1, r0
   8e998: e1a00006     	mov	r0, r6
   8e99c: eb0018ae     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x62b8
   8e9a0: e59f3fec     	ldr	r3, [pc, #0xfec]        @ 0x8f994 <.text+0x7f894>
   8e9a4: e08f3003     	add	r3, pc, r3
   8e9a8: eaffffe0     	b	0x8e930 <.text+0x7e830> @ imm = #-0x80
   8e9ac: 0055950f     	subseq	r9, r5, pc, lsl #10
   8e9b0: 00559479     	subseq	r9, r5, r9, ror r4
   8e9b4: 0055949f     	<unknown>
   8e9b8: 00559ade     	ldrsbeq	r9, [r5], #-174
   8e9bc: 005594d3     	ldrsbeq	r9, [r5], #-67
   8e9c0: 0055943d     	subseq	r9, r5, sp, lsr r4
   8e9c4: 0055945f     	subseq	r9, r5, pc, asr r4
   8e9c8: e59d50c0     	ldr	r5, [sp, #0xc0]
   8e9cc: e3500000     	cmp	r0, #0
   8e9d0: 0a000023     	beq	0x8ea64 <.text+0x7e964> @ imm = #0x8c
   8e9d4: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0x8f998 <.text+0x7f898>
   8e9d8: e3a07001     	mov	r7, #1
   8e9dc: e59f1fb8     	ldr	r1, [pc, #0xfb8]        @ 0x8f99c <.text+0x7f89c>
   8e9e0: e59f2fb8     	ldr	r2, [pc, #0xfb8]        @ 0x8f9a0 <.text+0x7f8a0>
   8e9e4: e08f0000     	add	r0, pc, r0
   8e9e8: e59f3fb4     	ldr	r3, [pc, #0xfb4]        @ 0x8f9a4 <.text+0x7f8a4>
   8e9ec: e08f1001     	add	r1, pc, r1
   8e9f0: e08f2002     	add	r2, pc, r2
   8e9f4: e58d7000     	str	r7, [sp]
   8e9f8: e08f3003     	add	r3, pc, r3
   8e9fc: e58d3004     	str	r3, [sp, #0x4]
   8ea00: e301325a     	movw	r3, #0x125a
   8ea04: eb01adae     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6b6b8
   8ea08: e30017da     	movw	r1, #0x7da
   8ea0c: e59f6f94     	ldr	r6, [pc, #0xf94]        @ 0x8f9a8 <.text+0x7f8a8>
   8ea10: e30100b4     	movw	r0, #0x10b4
   8ea14: e59d204c     	ldr	r2, [sp, #0x4c]
   8ea18: e08f6006     	add	r6, pc, r6
   8ea1c: e0820000     	add	r0, r2, r0
   8ea20: ebfeec9c     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x44d90
   8ea24: e59f0f80     	ldr	r0, [pc, #0xf80]        @ 0x8f9ac <.text+0x7f8ac>
   8ea28: e3a07001     	mov	r7, #1
   8ea2c: e59f1f7c     	ldr	r1, [pc, #0xf7c]        @ 0x8f9b0 <.text+0x7f8b0>
   8ea30: e59f2f7c     	ldr	r2, [pc, #0xf7c]        @ 0x8f9b4 <.text+0x7f8b4>
   8ea34: e08f0000     	add	r0, pc, r0
   8ea38: e59f3f78     	ldr	r3, [pc, #0xf78]        @ 0x8f9b8 <.text+0x7f8b8>
   8ea3c: e08f1001     	add	r1, pc, r1
   8ea40: e08f2002     	add	r2, pc, r2
   8ea44: e58d7000     	str	r7, [sp]
   8ea48: e08f3003     	add	r3, pc, r3
   8ea4c: e58d3004     	str	r3, [sp, #0x4]
   8ea50: e3013295     	movw	r3, #0x1295
   8ea54: eafffef9     	b	0x8e640 <.text+0x7e540> @ imm = #-0x41c
   8ea58: 00559477     	subseq	r9, r5, r7, ror r4
   8ea5c: 005593e1     	subseq	r9, r5, r1, ror #7
   8ea60: 00559403     	subseq	r9, r5, r3, lsl #8
   8ea64: e1a00006     	mov	r0, r6
   8ea68: eb001b40     	bl	0x95770 <.text+0x85670> @ imm = #0x6d00
   8ea6c: e59f1ffc     	ldr	r1, [pc, #0xffc]        @ 0x8fa70 <.text+0x7f970>
   8ea70: e3020034     	movw	r0, #0x2034
   8ea74: e08f1001     	add	r1, pc, r1
   8ea78: e7910000     	ldr	r0, [r1, r0]
   8ea7c: e59f8ff0     	ldr	r8, [pc, #0xff0]        @ 0x8fa74 <.text+0x7f974>
   8ea80: e08f8008     	add	r8, pc, r8
   8ea84: e3500001     	cmp	r0, #1
   8ea88: 1a000010     	bne	0x8ead0 <.text+0x7e9d0> @ imm = #0x40
   8ea8c: e2811008     	add	r1, r1, #8
   8ea90: e1a00006     	mov	r0, r6
   8ea94: eb0035d7     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xd75c
   8ea98: e3500000     	cmp	r0, #0
   8ea9c: 0a00009b     	beq	0x8ed10 <.text+0x7ec10> @ imm = #0x26c
   8eaa0: e5940000     	ldr	r0, [r4]
   8eaa4: e2401001     	sub	r1, r0, #1
   8eaa8: e0000190     	mul	r0, r0, r1
   8eaac: e3100001     	tst	r0, #1
   8eab0: 0a000011     	beq	0x8eafc <.text+0x7e9fc> @ imm = #0x44
   8eab4: e5990000     	ldr	r0, [r9]
   8eab8: e3500009     	cmp	r0, #9
   8eabc: ca000019     	bgt	0x8eb28 <.text+0x7ea28> @ imm = #0x64
   8eac0: ea00000d     	b	0x8eafc <.text+0x7e9fc> @ imm = #0x34
   8eac4: 005593f7     	ldrsheq	r9, [r5], #-55
   8eac8: 00559361     	subseq	r9, r5, r1, ror #6
   8eacc: 00559383     	subseq	r9, r5, r3, lsl #7
   8ead0: e5940000     	ldr	r0, [r4]
   8ead4: e2401001     	sub	r1, r0, #1
   8ead8: e0000190     	mul	r0, r0, r1
   8eadc: e3100001     	tst	r0, #1
   8eae0: 0a00002e     	beq	0x8eba0 <.text+0x7eaa0> @ imm = #0xb8
   8eae4: e5990000     	ldr	r0, [r9]
   8eae8: e3500009     	cmp	r0, #9
   8eaec: ca000040     	bgt	0x8ebf4 <.text+0x7eaf4> @ imm = #0x100
   8eaf0: ea00002a     	b	0x8eba0 <.text+0x7eaa0> @ imm = #0xa8
   8eaf4: 005593e8     	subseq	r9, r5, r8, ror #7
   8eaf8: 005593a4     	subseq	r9, r5, r4, lsr #7
   8eafc: e1a00006     	mov	r0, r6
   8eb00: e3a01000     	mov	r1, #0
   8eb04: eb001a0a     	bl	0x95334 <.text+0x85234> @ imm = #0x6828
   8eb08: e5941000     	ldr	r1, [r4]
   8eb0c: e2412001     	sub	r2, r1, #1
   8eb10: e0010291     	mul	r1, r1, r2
   8eb14: e3110001     	tst	r1, #1
   8eb18: 0a000008     	beq	0x8eb40 <.text+0x7ea40> @ imm = #0x20
   8eb1c: e5991000     	ldr	r1, [r9]
   8eb20: e3510009     	cmp	r1, #9
   8eb24: da000005     	ble	0x8eb40 <.text+0x7ea40> @ imm = #0x14
   8eb28: e1a00006     	mov	r0, r6
   8eb2c: e3a01000     	mov	r1, #0
   8eb30: eb0019ff     	bl	0x95334 <.text+0x85234> @ imm = #0x67fc
   8eb34: eafffff0     	b	0x8eafc <.text+0x7e9fc> @ imm = #-0x40
   8eb38: 00559cbc     	ldrheq	r9, [r5], #-204
   8eb3c: 00559cc7     	subseq	r9, r5, r7, asr #25
   8eb40: e3500000     	cmp	r0, #0
   8eb44: 0a00007a     	beq	0x8ed34 <.text+0x7ec34> @ imm = #0x1e8
   8eb48: e59f0f98     	ldr	r0, [pc, #0xf98]        @ 0x8fae8 <.text+0x7f9e8>
   8eb4c: e3a07001     	mov	r7, #1
   8eb50: e59f1f94     	ldr	r1, [pc, #0xf94]        @ 0x8faec <.text+0x7f9ec>
   8eb54: e59f2f94     	ldr	r2, [pc, #0xf94]        @ 0x8faf0 <.text+0x7f9f0>
   8eb58: e08f0000     	add	r0, pc, r0
   8eb5c: e59f3f90     	ldr	r3, [pc, #0xf90]        @ 0x8faf4 <.text+0x7f9f4>
   8eb60: e08f1001     	add	r1, pc, r1
   8eb64: e08f2002     	add	r2, pc, r2
   8eb68: e58d7000     	str	r7, [sp]
   8eb6c: e08f3003     	add	r3, pc, r3
   8eb70: e58d3004     	str	r3, [sp, #0x4]
   8eb74: e301326d     	movw	r3, #0x126d
   8eb78: eb01ad51     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6b544
   8eb7c: e3001fa1     	movw	r1, #0xfa1
   8eb80: e59d50c0     	ldr	r5, [sp, #0xc0]
   8eb84: eaffffa0     	b	0x8ea0c <.text+0x7e90c> @ imm = #-0x180
   8eb88: 00559343     	subseq	r9, r5, r3, asr #6
   8eb8c: 005592ad     	subseq	r9, r5, sp, lsr #5
   8eb90: 005592cf     	subseq	r9, r5, pc, asr #5
   8eb94: 00559334     	subseq	r9, r5, r4, lsr r3
   8eb98: 005592f0     	ldrsheq	r9, [r5], #-32
   8eb9c: 00559c08     	subseq	r9, r5, r8, lsl #24
   8eba0: e59d008c     	ldr	r0, [sp, #0x8c]
   8eba4: e5905000     	ldr	r5, [r0]
   8eba8: eb01bd03     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x6f40c
   8ebac: e59f2f44     	ldr	r2, [pc, #0xf44]        @ 0x8faf8 <.text+0x7f9f8>
   8ebb0: e3021034     	movw	r1, #0x2034
   8ebb4: e2500006     	subs	r0, r0, #6
   8ebb8: e08f2002     	add	r2, pc, r2
   8ebbc: 13000001     	movwne	r0, #0x1
   8ebc0: e7921001     	ldr	r1, [r2, r1]
   8ebc4: e5942000     	ldr	r2, [r4]
   8ebc8: e2423001     	sub	r3, r2, #1
   8ebcc: e2411001     	sub	r1, r1, #1
   8ebd0: e16f1f11     	clz	r1, r1
   8ebd4: e0020392     	mul	r2, r2, r3
   8ebd8: e1a012a1     	lsr	r1, r1, #5
   8ebdc: e1800001     	orr	r0, r0, r1
   8ebe0: e3120001     	tst	r2, #1
   8ebe4: 0a000006     	beq	0x8ec04 <.text+0x7eb04> @ imm = #0x18
   8ebe8: e5991000     	ldr	r1, [r9]
   8ebec: e3510009     	cmp	r1, #9
   8ebf0: da000003     	ble	0x8ec04 <.text+0x7eb04> @ imm = #0xc
   8ebf4: eb01bcf0     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x6f3c0
   8ebf8: eaffffe8     	b	0x8eba0 <.text+0x7eaa0> @ imm = #-0x60
   8ebfc: 00559c13     	subseq	r9, r5, r3, lsl r12
   8ec00: 00582d68     	subseq	r2, r8, r8, ror #26
   8ec04: e3500000     	cmp	r0, #0
   8ec08: 1a000003     	bne	0x8ec1c <.text+0x7eb1c> @ imm = #0xc
   8ec0c: e1a00006     	mov	r0, r6
   8ec10: ebff4eda     	bl	0x62780 <.text+0x52680> @ imm = #-0x2c498
   8ec14: e1500005     	cmp	r0, r5
   8ec18: aa00001a     	bge	0x8ec88 <.text+0x7eb88> @ imm = #0x68
   8ec1c: e5940000     	ldr	r0, [r4]
   8ec20: e59d5078     	ldr	r5, [sp, #0x78]
   8ec24: e2401001     	sub	r1, r0, #1
   8ec28: e0000190     	mul	r0, r0, r1
   8ec2c: e3100001     	tst	r0, #1
   8ec30: 0a000002     	beq	0x8ec40 <.text+0x7eb40> @ imm = #0x8
   8ec34: e5990000     	ldr	r0, [r9]
   8ec38: e3500009     	cmp	r0, #9
   8ec3c: ca00000a     	bgt	0x8ec6c <.text+0x7eb6c> @ imm = #0x28
   8ec40: e1a00006     	mov	r0, r6
   8ec44: ebff4e5b     	bl	0x625b8 <.text+0x524b8> @ imm = #-0x2c694
   8ec48: e5941000     	ldr	r1, [r4]
   8ec4c: e2412001     	sub	r2, r1, #1
   8ec50: e0020291     	mul	r2, r1, r2
   8ec54: e5951000     	ldr	r1, [r5]
   8ec58: e3120001     	tst	r2, #1
   8ec5c: 0a000007     	beq	0x8ec80 <.text+0x7eb80> @ imm = #0x1c
   8ec60: e5992000     	ldr	r2, [r9]
   8ec64: e3520009     	cmp	r2, #9
   8ec68: da000004     	ble	0x8ec80 <.text+0x7eb80> @ imm = #0x10
   8ec6c: e1a00006     	mov	r0, r6
   8ec70: ebff4e50     	bl	0x625b8 <.text+0x524b8> @ imm = #-0x2c6c0
   8ec74: eafffff1     	b	0x8ec40 <.text+0x7eb40> @ imm = #-0x3c
   8ec78: 00582d44     	subseq	r2, r8, r4, asr #26
   8ec7c: 00582d20     	subseq	r2, r8, r0, lsr #26
   8ec80: e1500001     	cmp	r0, r1
   8ec84: aa00000f     	bge	0x8ecc8 <.text+0x7ebc8> @ imm = #0x3c
   8ec88: e5940000     	ldr	r0, [r4]
   8ec8c: e59d707c     	ldr	r7, [sp, #0x7c]
   8ec90: e2401001     	sub	r1, r0, #1
   8ec94: e0000190     	mul	r0, r0, r1
   8ec98: e3100001     	tst	r0, #1
   8ec9c: 0a0000fb     	beq	0x8f090 <.text+0x7ef90> @ imm = #0x3ec
   8eca0: e5990000     	ldr	r0, [r9]
   8eca4: e3500009     	cmp	r0, #9
   8eca8: ca00010c     	bgt	0x8f0e0 <.text+0x7efe0> @ imm = #0x430
   8ecac: ea0000f7     	b	0x8f090 <.text+0x7ef90> @ imm = #0x3dc
   8ecb0: 00582c9c     	<unknown>
   8ecb4: 00582c84     	subseq	r2, r8, r4, lsl #25
   8ecb8: 0055915b     	subseq	r9, r5, r11, asr r1
   8ecbc: 005590c5     	subseq	r9, r5, r5, asr #1
   8ecc0: 005590eb     	subseq	r9, r5, r11, ror #1
   8ecc4: 0055992c     	subseq	r9, r5, r12, lsr #18
   8ecc8: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0x8fc94 <.text+0x7fb94>
   8eccc: e3020034     	movw	r0, #0x2034
   8ecd0: e08f1001     	add	r1, pc, r1
   8ecd4: e7910000     	ldr	r0, [r1, r0]
   8ecd8: e3500001     	cmp	r0, #1
   8ecdc: 0affff6a     	beq	0x8ea8c <.text+0x7e98c> @ imm = #-0x258
   8ece0: e3500000     	cmp	r0, #0
   8ece4: 1affff6d     	bne	0x8eaa0 <.text+0x7e9a0> @ imm = #-0x24c
   8ece8: e59d00ac     	ldr	r0, [sp, #0xac]
   8ecec: e3a02000     	mov	r2, #0
   8ecf0: e5903000     	ldr	r3, [r0]
   8ecf4: e59f0fd8     	ldr	r0, [pc, #0xfd8]        @ 0x8fcd4 <.text+0x7fbd4>
   8ecf8: e08f0000     	add	r0, pc, r0
   8ecfc: e2801008     	add	r1, r0, #8
   8ed00: e1a00006     	mov	r0, r6
   8ed04: eb0043dd     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0x10f74
   8ed08: e3500000     	cmp	r0, #0
   8ed0c: 1affff63     	bne	0x8eaa0 <.text+0x7e9a0> @ imm = #-0x274
   8ed10: e59f6ffc     	ldr	r6, [pc, #0xffc]        @ 0x8fd14 <.text+0x7fc14>
   8ed14: e08f6006     	add	r6, pc, r6
   8ed18: e1a00006     	mov	r0, r6
   8ed1c: eb145cf9     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5173e4
   8ed20: e1a00006     	mov	r0, r6
   8ed24: e5d85000     	ldrb	r5, [r8]
   8ed28: eb145e65     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x517994
   8ed2c: e3550000     	cmp	r5, #0
   8ed30: 0a00001b     	beq	0x8eda4 <.text+0x7eca4> @ imm = #0x6c
   8ed34: e59f6fdc     	ldr	r6, [pc, #0xfdc]        @ 0x8fd18 <.text+0x7fc18>
   8ed38: e08f6006     	add	r6, pc, r6
   8ed3c: e1a00006     	mov	r0, r6
   8ed40: eb145cf0     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5173c0
   8ed44: e1a00006     	mov	r0, r6
   8ed48: e5d85000     	ldrb	r5, [r8]
   8ed4c: eb145e5c     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x517970
   8ed50: e59f3fc4     	ldr	r3, [pc, #0xfc4]        @ 0x8fd1c <.text+0x7fc1c>
   8ed54: e3550000     	cmp	r5, #0
   8ed58: e59d604c     	ldr	r6, [sp, #0x4c]
   8ed5c: e08f3003     	add	r3, pc, r3
   8ed60: 1a001354     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x4d50
   8ed64: ed960a3c     	vldr	s0, [r6, #240]
   8ed68: e3020034     	movw	r0, #0x2034
   8ed6c: e1a01003     	mov	r1, r3
   8ed70: eeb80bc0     	vcvt.f64.s32	d0, s0
   8ed74: e6910000     	ldr	r0, [r1], r0
   8ed78: e5911000     	ldr	r1, [r1]
   8ed7c: e3510001     	cmp	r1, #1
   8ed80: 0a000017     	beq	0x8ede4 <.text+0x7ece4> @ imm = #0x5c
   8ed84: e3510000     	cmp	r1, #0
   8ed88: 1a00001b     	bne	0x8edfc <.text+0x7ecfc> @ imm = #0x6c
   8ed8c: e2831008     	add	r1, r3, #8
   8ed90: e3a02000     	mov	r2, #0
   8ed94: e1a05003     	mov	r5, r3
   8ed98: eb004982     	bl	0xa13a8 <.text+0x912a8> @ imm = #0x12608
   8ed9c: ea000013     	b	0x8edf0 <.text+0x7ecf0> @ imm = #0x4c
   8eda0: 00584c48     	subseq	r4, r8, r8, asr #24
   8eda4: e59f1fa4     	ldr	r1, [pc, #0xfa4]        @ 0x8fd50 <.text+0x7fc50>
   8eda8: e3020034     	movw	r0, #0x2034
   8edac: e08f1001     	add	r1, pc, r1
   8edb0: e7910000     	ldr	r0, [r1, r0]
   8edb4: e3500001     	cmp	r0, #1
   8edb8: 0a00007c     	beq	0x8efb0 <.text+0x7eeb0> @ imm = #0x1f0
   8edbc: e3500000     	cmp	r0, #0
   8edc0: 1affffdb     	bne	0x8ed34 <.text+0x7ec34> @ imm = #-0x94
   8edc4: e59f0f88     	ldr	r0, [pc, #0xf88]        @ 0x8fd54 <.text+0x7fc54>
   8edc8: e08f0000     	add	r0, pc, r0
   8edcc: e2801008     	add	r1, r0, #8
   8edd0: e59d004c     	ldr	r0, [sp, #0x4c]
   8edd4: eb0048e1     	bl	0xa1160 <.text+0x91060> @ imm = #0x12384
   8edd8: eaffffd5     	b	0x8ed34 <.text+0x7ec34> @ imm = #-0xac
   8eddc: 00584c24     	subseq	r4, r8, r4, lsr #24
   8ede0: 00582bb0     	ldrheq	r2, [r8], #-176
   8ede4: e2831008     	add	r1, r3, #8
   8ede8: e1a05003     	mov	r5, r3
   8edec: eb003c8d     	bl	0x9e028 <.text+0x8df28> @ imm = #0xf234
   8edf0: e3020034     	movw	r0, #0x2034
   8edf4: e1a03005     	mov	r3, r5
   8edf8: e7951000     	ldr	r1, [r5, r0]
   8edfc: e3510001     	cmp	r1, #1
   8ee00: 0a000006     	beq	0x8ee20 <.text+0x7ed20> @ imm = #0x18
   8ee04: e3510000     	cmp	r1, #0
   8ee08: 1a00000b     	bne	0x8ee3c <.text+0x7ed3c> @ imm = #0x2c
   8ee0c: e2831008     	add	r1, r3, #8
   8ee10: e1a00006     	mov	r0, r6
   8ee14: eb0048d1     	bl	0xa1160 <.text+0x91060> @ imm = #0x12344
   8ee18: ea000005     	b	0x8ee34 <.text+0x7ed34> @ imm = #0x14
   8ee1c: 00582b60     	subseq	r2, r8, r0, ror #22
   8ee20: e3020030     	movw	r0, #0x2030
   8ee24: e2831008     	add	r1, r3, #8
   8ee28: e7932000     	ldr	r2, [r3, r0]
   8ee2c: e1a00006     	mov	r0, r6
   8ee30: eb003be8     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xefa0
   8ee34: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0x8fe1c <.text+0x7fd1c>
   8ee38: e08f3003     	add	r3, pc, r3
   8ee3c: e5970000     	ldr	r0, [r7]
   8ee40: e3500000     	cmp	r0, #0
   8ee44: 0a00002b     	beq	0x8eef8 <.text+0x7edf8> @ imm = #0xac
   8ee48: eb01be06     	bl	0xfe668 <.text+0xee568> @ imm = #0x6f818
   8ee4c: e1a06000     	mov	r6, r0
   8ee50: eb01bc6f     	bl	0xfe014 <.text+0xedf14> @ imm = #0x6f1bc
   8ee54: e59fcfc4     	ldr	r12, [pc, #0xfc4]       @ 0x8fe20 <.text+0x7fd20>
   8ee58: e3560001     	cmp	r6, #1
   8ee5c: e08fc00c     	add	r12, pc, r12
   8ee60: ba000041     	blt	0x8ef6c <.text+0x7ee6c> @ imm = #0x104
   8ee64: e59c1020     	ldr	r1, [r12, #0x20]
   8ee68: e3a02000     	mov	r2, #0
   8ee6c: ea000003     	b	0x8ee80 <.text+0x7ed80> @ imm = #0xc
   8ee70: 00582b18     	subseq	r2, r8, r8, lsl r11
   8ee74: e2822001     	add	r2, r2, #1
   8ee78: e1520006     	cmp	r2, r6
   8ee7c: 0a00003a     	beq	0x8ef6c <.text+0x7ee6c> @ imm = #0xe8
   8ee80: e0823102     	add	r3, r2, r2, lsl #2
   8ee84: e0813183     	add	r3, r1, r3, lsl #3
   8ee88: e5d37004     	ldrb	r7, [r3, #0x4]
   8ee8c: e3570000     	cmp	r7, #0
   8ee90: 0afffff7     	beq	0x8ee74 <.text+0x7ed74> @ imm = #-0x24
   8ee94: e3500001     	cmp	r0, #1
   8ee98: bafffff5     	blt	0x8ee74 <.text+0x7ed74> @ imm = #-0x2c
   8ee9c: e5d37005     	ldrb	r7, [r3, #0x5]
   8eea0: e3570000     	cmp	r7, #0
   8eea4: 0afffff2     	beq	0x8ee74 <.text+0x7ed74> @ imm = #-0x38
   8eea8: e5933020     	ldr	r3, [r3, #0x20]
   8eeac: e1a07000     	mov	r7, r0
   8eeb0: e2833030     	add	r3, r3, #48
   8eeb4: e5d35000     	ldrb	r5, [r3]
   8eeb8: e3550000     	cmp	r5, #0
   8eebc: 1a00010f     	bne	0x8f300 <.text+0x7f200> @ imm = #0x43c
   8eec0: e2833038     	add	r3, r3, #56
   8eec4: e2577001     	subs	r7, r7, #1
   8eec8: 1afffff9     	bne	0x8eeb4 <.text+0x7edb4> @ imm = #-0x1c
   8eecc: eaffffe8     	b	0x8ee74 <.text+0x7ed74> @ imm = #-0x60
   8eed0: 00582af4     	ldrsheq	r2, [r8], #-164
   8eed4: 00558feb     	subseq	r8, r5, r11, ror #31
   8eed8: 00558f55     	subseq	r8, r5, r5, asr pc
   8eedc: 00558f7b     	subseq	r8, r5, r11, ror pc
   8eee0: 00559685     	subseq	r9, r5, r5, lsl #13
   8eee4: 00582aac     	subseq	r2, r8, r12, lsr #21
   8eee8: 00558f97     	<unknown>
   8eeec: 00558f01     	subseq	r8, r5, r1, lsl #30
   8eef0: 00558f27     	subseq	r8, r5, r7, lsr #30
   8eef4: 00559631     	subseq	r9, r5, r1, lsr r6
   8eef8: e5940000     	ldr	r0, [r4]
   8eefc: e2401001     	sub	r1, r0, #1
   8ef00: e0000190     	mul	r0, r0, r1
   8ef04: e3100001     	tst	r0, #1
   8ef08: e5940000     	ldr	r0, [r4]
   8ef0c: e2401001     	sub	r1, r0, #1
   8ef10: e0010190     	mul	r1, r0, r1
   8ef14: e3020034     	movw	r0, #0x2034
   8ef18: e7930000     	ldr	r0, [r3, r0]
   8ef1c: e3110001     	tst	r1, #1
   8ef20: 0a000002     	beq	0x8ef30 <.text+0x7ee30> @ imm = #0x8
   8ef24: e5991000     	ldr	r1, [r9]
   8ef28: e3510009     	cmp	r1, #9
   8ef2c: cafffff5     	bgt	0x8ef08 <.text+0x7ee08> @ imm = #-0x2c
   8ef30: e3500000     	cmp	r0, #0
   8ef34: 0a000024     	beq	0x8efcc <.text+0x7eecc> @ imm = #0x90
   8ef38: e3500001     	cmp	r0, #1
   8ef3c: 1a000028     	bne	0x8efe4 <.text+0x7eee4> @ imm = #0xa0
   8ef40: e5940000     	ldr	r0, [r4]
   8ef44: e2401001     	sub	r1, r0, #1
   8ef48: e0000190     	mul	r0, r0, r1
   8ef4c: e3100001     	tst	r0, #1
   8ef50: 0a00007e     	beq	0x8f150 <.text+0x7f050> @ imm = #0x1f8
   8ef54: e5990000     	ldr	r0, [r9]
   8ef58: e3500009     	cmp	r0, #9
   8ef5c: ca00008a     	bgt	0x8f18c <.text+0x7f08c> @ imm = #0x228
   8ef60: ea00007a     	b	0x8f150 <.text+0x7f050> @ imm = #0x1e8
   8ef64: 00582a58     	subseq	r2, r8, r8, asr r10
   8ef68: 00582a34     	subseq	r2, r8, r4, lsr r10
   8ef6c: e59d00b0     	ldr	r0, [sp, #0xb0]
   8ef70: ed900a00     	vldr	s0, [r0]
   8ef74: e3020034     	movw	r0, #0x2034
   8ef78: eeb88bc0     	vcvt.f64.s32	d8, s0
   8ef7c: e79c0000     	ldr	r0, [r12, r0]
   8ef80: e3500000     	cmp	r0, #0
   8ef84: 0a000026     	beq	0x8f024 <.text+0x7ef24> @ imm = #0x98
   8ef88: e3500001     	cmp	r0, #1
   8ef8c: 1a00002e     	bne	0x8f04c <.text+0x7ef4c> @ imm = #0xb8
   8ef90: e3020030     	movw	r0, #0x2030
   8ef94: eeb00b48     	vmov.f64	d0, d8
   8ef98: e79c1000     	ldr	r1, [r12, r0]
   8ef9c: e28c0008     	add	r0, r12, #8
   8efa0: eb003d08     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xf420
   8efa4: e59fcfc4     	ldr	r12, [pc, #0xfc4]       @ 0x8ff70 <.text+0x7fe70>
   8efa8: e08fc00c     	add	r12, pc, r12
   8efac: ea0000a8     	b	0x8f254 <.text+0x7f154> @ imm = #0x2a0
   8efb0: e3020030     	movw	r0, #0x2030
   8efb4: e7912000     	ldr	r2, [r1, r0]
   8efb8: e2811008     	add	r1, r1, #8
   8efbc: e59d004c     	ldr	r0, [sp, #0x4c]
   8efc0: eb003b84     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xee10
   8efc4: eaffff5a     	b	0x8ed34 <.text+0x7ec34> @ imm = #-0x298
   8efc8: 005829f8     	ldrsheq	r2, [r8], #-152
   8efcc: ed9f0bfb     	vldr	d0, [pc, #1004]         @ 0x8f3c0 <.text+0x7f2c0>
   8efd0: e2830008     	add	r0, r3, #8
   8efd4: eb004963     	bl	0xa1568 <.text+0x91468> @ imm = #0x1258c
   8efd8: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x8ffbc <.text+0x7febc>
   8efdc: e08f3003     	add	r3, pc, r3
   8efe0: ea000072     	b	0x8f1b0 <.text+0x7f0b0> @ imm = #0x1c8
   8efe4: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x8ffc0 <.text+0x7fec0>
   8efe8: e3a07002     	mov	r7, #2
   8efec: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x8ffc4 <.text+0x7fec4>
   8eff0: e59f2fd0     	ldr	r2, [pc, #0xfd0]        @ 0x8ffc8 <.text+0x7fec8>
   8eff4: e08f0000     	add	r0, pc, r0
   8eff8: e59f3fcc     	ldr	r3, [pc, #0xfcc]        @ 0x8ffcc <.text+0x7fecc>
   8effc: e08f1001     	add	r1, pc, r1
   8f000: e08f2002     	add	r2, pc, r2
   8f004: e58d7000     	str	r7, [sp]
   8f008: e08f3003     	add	r3, pc, r3
   8f00c: e58d3004     	str	r3, [sp, #0x4]
   8f010: e3a03e75     	mov	r3, #1872
   8f014: eb01ac2a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6b0a8
   8f018: e59f3fb0     	ldr	r3, [pc, #0xfb0]        @ 0x8ffd0 <.text+0x7fed0>
   8f01c: e08f3003     	add	r3, pc, r3
   8f020: ea000064     	b	0x8f1b8 <.text+0x7f0b8> @ imm = #0x190
   8f024: e5940000     	ldr	r0, [r4]
   8f028: e2401001     	sub	r1, r0, #1
   8f02c: e0000190     	mul	r0, r0, r1
   8f030: e3100001     	tst	r0, #1
   8f034: 0a0000cc     	beq	0x8f36c <.text+0x7f26c> @ imm = #0x330
   8f038: e5990000     	ldr	r0, [r9]
   8f03c: e3500009     	cmp	r0, #9
   8f040: ca0000d6     	bgt	0x8f3a0 <.text+0x7f2a0> @ imm = #0x358
   8f044: ea0000c8     	b	0x8f36c <.text+0x7f26c> @ imm = #0x320
   8f048: 005593fc     	ldrsheq	r9, [r5], #-60
   8f04c: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x90038 <.text+0x7ff38>
   8f050: e3a07002     	mov	r7, #2
   8f054: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x9003c <.text+0x7ff3c>
   8f058: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x90040 <.text+0x7ff40>
   8f05c: e08f0000     	add	r0, pc, r0
   8f060: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x90044 <.text+0x7ff44>
   8f064: e08f1001     	add	r1, pc, r1
   8f068: e08f2002     	add	r2, pc, r2
   8f06c: e58d7000     	str	r7, [sp]
   8f070: e08f3003     	add	r3, pc, r3
   8f074: e58d3004     	str	r3, [sp, #0x4]
   8f078: e3a03e75     	mov	r3, #1872
   8f07c: eb01ac10     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6b040
   8f080: e59fcfc0     	ldr	r12, [pc, #0xfc0]       @ 0x90048 <.text+0x7ff48>
   8f084: e08fc00c     	add	r12, pc, r12
   8f088: ea00009c     	b	0x8f300 <.text+0x7f200> @ imm = #0x270
   8f08c: 00584978     	subseq	r4, r8, r8, ror r9
   8f090: e5970000     	ldr	r0, [r7]
   8f094: e59f1fb0     	ldr	r1, [pc, #0xfb0]        @ 0x9004c <.text+0x7ff4c>
   8f098: e08f1001     	add	r1, pc, r1
   8f09c: e1a03001     	mov	r3, r1
   8f0a0: e5911004     	ldr	r1, [r1, #0x4]
   8f0a4: e5932008     	ldr	r2, [r3, #0x8]
   8f0a8: e0825000     	add	r5, r2, r0
   8f0ac: e59d004c     	ldr	r0, [sp, #0x4c]
   8f0b0: e5835008     	str	r5, [r3, #0x8]
   8f0b4: e5916014     	ldr	r6, [r1, #0x14]
   8f0b8: e590001c     	ldr	r0, [r0, #0x1c]
   8f0bc: ebff4721     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2e37c
   8f0c0: e5941000     	ldr	r1, [r4]
   8f0c4: e2412001     	sub	r2, r1, #1
   8f0c8: e0010291     	mul	r1, r1, r2
   8f0cc: e3110001     	tst	r1, #1
   8f0d0: 0a00000d     	beq	0x8f10c <.text+0x7f00c> @ imm = #0x34
   8f0d4: e5991000     	ldr	r1, [r9]
   8f0d8: e3510009     	cmp	r1, #9
   8f0dc: da00000a     	ble	0x8f10c <.text+0x7f00c> @ imm = #0x28
   8f0e0: e5970000     	ldr	r0, [r7]
   8f0e4: e59f1fb0     	ldr	r1, [pc, #0xfb0]        @ 0x9009c <.text+0x7ff9c>
   8f0e8: e08f1001     	add	r1, pc, r1
   8f0ec: e1a02001     	mov	r2, r1
   8f0f0: e5911008     	ldr	r1, [r1, #0x8]
   8f0f4: e0810000     	add	r0, r1, r0
   8f0f8: e5820008     	str	r0, [r2, #0x8]
   8f0fc: e59d004c     	ldr	r0, [sp, #0x4c]
   8f100: e590001c     	ldr	r0, [r0, #0x1c]
   8f104: ebff470f     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2e3c4
   8f108: eaffffe0     	b	0x8f090 <.text+0x7ef90> @ imm = #-0x80
   8f10c: e1560000     	cmp	r6, r0
   8f110: aa000007     	bge	0x8f134 <.text+0x7f034> @ imm = #0x1c
   8f114: e59f0f84     	ldr	r0, [pc, #0xf84]        @ 0x900a0 <.text+0x7ffa0>
   8f118: e08f0000     	add	r0, pc, r0
   8f11c: e5900004     	ldr	r0, [r0, #0x4]
   8f120: e5900014     	ldr	r0, [r0, #0x14]
   8f124: e1550000     	cmp	r5, r0
   8f128: ca000006     	bgt	0x8f148 <.text+0x7f048> @ imm = #0x18
   8f12c: ea001261     	b	0x93ab8 <.text+0x839b8> @ imm = #0x4984
   8f130: 0058287c     	subseq	r2, r8, r12, ror r8
   8f134: e59d004c     	ldr	r0, [sp, #0x4c]
   8f138: e590001c     	ldr	r0, [r0, #0x1c]
   8f13c: ebff4701     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2e3fc
   8f140: e1550000     	cmp	r5, r0
   8f144: da00125b     	ble	0x93ab8 <.text+0x839b8> @ imm = #0x496c
   8f148: e3a00008     	mov	r0, #8
   8f14c: eafffdd3     	b	0x8e8a0 <.text+0x7e7a0> @ imm = #-0x8b4
   8f150: e3020030     	movw	r0, #0x2030
   8f154: ed9f0b99     	vldr	d0, [pc, #612]          @ 0x8f3c0 <.text+0x7f2c0>
   8f158: e7931000     	ldr	r1, [r3, r0]
   8f15c: e2830008     	add	r0, r3, #8
   8f160: eb003c98     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xf260
   8f164: e59f3fe8     	ldr	r3, [pc, #0xfe8]        @ 0x90154 <.text+0x80054>
   8f168: e5941000     	ldr	r1, [r4]
   8f16c: e08f3003     	add	r3, pc, r3
   8f170: e2412001     	sub	r2, r1, #1
   8f174: e0010291     	mul	r1, r1, r2
   8f178: e3110001     	tst	r1, #1
   8f17c: 0a00000b     	beq	0x8f1b0 <.text+0x7f0b0> @ imm = #0x2c
   8f180: e5991000     	ldr	r1, [r9]
   8f184: e3510009     	cmp	r1, #9
   8f188: da000008     	ble	0x8f1b0 <.text+0x7f0b0> @ imm = #0x20
   8f18c: e3020030     	movw	r0, #0x2030
   8f190: ed9f0b8a     	vldr	d0, [pc, #552]          @ 0x8f3c0 <.text+0x7f2c0>
   8f194: e7931000     	ldr	r1, [r3, r0]
   8f198: e2830008     	add	r0, r3, #8
   8f19c: eb003c89     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xf224
   8f1a0: e59f3fb0     	ldr	r3, [pc, #0xfb0]        @ 0x90158 <.text+0x80058>
   8f1a4: e08f3003     	add	r3, pc, r3
   8f1a8: eaffffe8     	b	0x8f150 <.text+0x7f050> @ imm = #-0x60
   8f1ac: 00582800     	subseq	r2, r8, r0, lsl #16
   8f1b0: e3500000     	cmp	r0, #0
   8f1b4: 1a00001c     	bne	0x8f22c <.text+0x7f12c> @ imm = #0x70
   8f1b8: e596001c     	ldr	r0, [r6, #0x1c]
   8f1bc: e1a05006     	mov	r5, r6
   8f1c0: e9930102     	ldmib	r3, {r1, r8}
   8f1c4: e1a07003     	mov	r7, r3
   8f1c8: e5916014     	ldr	r6, [r1, #0x14]
   8f1cc: ebff46dd     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2e48c
   8f1d0: e1560000     	cmp	r6, r0
   8f1d4: aa000010     	bge	0x8f21c <.text+0x7f11c> @ imm = #0x40
   8f1d8: e5970004     	ldr	r0, [r7, #0x4]
   8f1dc: e5900014     	ldr	r0, [r0, #0x14]
   8f1e0: e1580000     	cmp	r8, r0
   8f1e4: aa000010     	bge	0x8f22c <.text+0x7f12c> @ imm = #0x40
   8f1e8: e5940000     	ldr	r0, [r4]
   8f1ec: e2401001     	sub	r1, r0, #1
   8f1f0: e0000190     	mul	r0, r0, r1
   8f1f4: e3100001     	tst	r0, #1
   8f1f8: 0a000085     	beq	0x8f414 <.text+0x7f314> @ imm = #0x214
   8f1fc: e5990000     	ldr	r0, [r9]
   8f200: e3500009     	cmp	r0, #9
   8f204: ca00008f     	bgt	0x8f448 <.text+0x7f348> @ imm = #0x23c
   8f208: ea000081     	b	0x8f414 <.text+0x7f314> @ imm = #0x204
   8f20c: 00558c9f     	<unknown>
   8f210: 00558c09     	subseq	r8, r5, r9, lsl #24
   8f214: 00558c2f     	subseq	r8, r5, pc, lsr #24
   8f218: 00559339     	subseq	r9, r5, r9, lsr r3
   8f21c: e595001c     	ldr	r0, [r5, #0x1c]
   8f220: ebff46c8     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2e4e0
   8f224: e1580000     	cmp	r8, r0
   8f228: baffffee     	blt	0x8f1e8 <.text+0x7f0e8> @ imm = #-0x48
   8f22c: e5940000     	ldr	r0, [r4]
   8f230: e2401001     	sub	r1, r0, #1
   8f234: e0000190     	mul	r0, r0, r1
   8f238: e3100001     	tst	r0, #1
   8f23c: 0a000061     	beq	0x8f3c8 <.text+0x7f2c8> @ imm = #0x184
   8f240: e5990000     	ldr	r0, [r9]
   8f244: e3500009     	cmp	r0, #9
   8f248: ca000069     	bgt	0x8f3f4 <.text+0x7f2f4> @ imm = #0x1a4
   8f24c: ea00005d     	b	0x8f3c8 <.text+0x7f2c8> @ imm = #0x174
   8f250: 00582758     	subseq	r2, r8, r8, asr r7
   8f254: e3500000     	cmp	r0, #0
   8f258: 0a000028     	beq	0x8f300 <.text+0x7f200> @ imm = #0xa0
   8f25c: e59d008c     	ldr	r0, [sp, #0x8c]
   8f260: e5905000     	ldr	r5, [r0]
   8f264: eb01bb54     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x6ed50
   8f268: e59f1fb4     	ldr	r1, [pc, #0xfb4]        @ 0x90224 <.text+0x80124>
   8f26c: e3500006     	cmp	r0, #6
   8f270: e08f1001     	add	r1, pc, r1
   8f274: 1afffd88     	bne	0x8e89c <.text+0x7e79c> @ imm = #-0x9e0
   8f278: e3020034     	movw	r0, #0x2034
   8f27c: e7910000     	ldr	r0, [r1, r0]
   8f280: e3500001     	cmp	r0, #1
   8f284: 0afffd84     	beq	0x8e89c <.text+0x7e79c> @ imm = #-0x9f0
   8f288: e5940000     	ldr	r0, [r4]
   8f28c: e59d604c     	ldr	r6, [sp, #0x4c]
   8f290: e2401001     	sub	r1, r0, #1
   8f294: e0000190     	mul	r0, r0, r1
   8f298: e3100001     	tst	r0, #1
   8f29c: 0a000002     	beq	0x8f2ac <.text+0x7f1ac> @ imm = #0x8
   8f2a0: e5990000     	ldr	r0, [r9]
   8f2a4: e3500009     	cmp	r0, #9
   8f2a8: ca000009     	bgt	0x8f2d4 <.text+0x7f1d4> @ imm = #0x24
   8f2ac: e1a00006     	mov	r0, r6
   8f2b0: ebff4d32     	bl	0x62780 <.text+0x52680> @ imm = #-0x2cb38
   8f2b4: e5941000     	ldr	r1, [r4]
   8f2b8: e2412001     	sub	r2, r1, #1
   8f2bc: e0010291     	mul	r1, r1, r2
   8f2c0: e3110001     	tst	r1, #1
   8f2c4: 0a000009     	beq	0x8f2f0 <.text+0x7f1f0> @ imm = #0x24
   8f2c8: e5991000     	ldr	r1, [r9]
   8f2cc: e3510009     	cmp	r1, #9
   8f2d0: da000006     	ble	0x8f2f0 <.text+0x7f1f0> @ imm = #0x18
   8f2d4: e1a00006     	mov	r0, r6
   8f2d8: ebff4d28     	bl	0x62780 <.text+0x52680> @ imm = #-0x2cb60
   8f2dc: eafffff2     	b	0x8f2ac <.text+0x7f1ac> @ imm = #-0x38
   8f2e0: 00558bc3     	subseq	r8, r5, r3, asr #23
   8f2e4: 00558b2d     	subseq	r8, r5, sp, lsr #22
   8f2e8: 00558b53     	subseq	r8, r5, r3, asr r11
   8f2ec: 00559427     	subseq	r9, r5, r7, lsr #8
   8f2f0: e59fcfcc     	ldr	r12, [pc, #0xfcc]       @ 0x902c4 <.text+0x801c4>
   8f2f4: e1500005     	cmp	r0, r5
   8f2f8: e08fc00c     	add	r12, pc, r12
   8f2fc: bafffd66     	blt	0x8e89c <.text+0x7e79c> @ imm = #-0xa68
   8f300: e59d504c     	ldr	r5, [sp, #0x4c]
   8f304: e1a0700c     	mov	r7, r12
   8f308: e99c0102     	ldmib	r12, {r1, r8}
   8f30c: e595001c     	ldr	r0, [r5, #0x1c]
   8f310: e5916014     	ldr	r6, [r1, #0x14]
   8f314: ebff468b     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2e5d4
   8f318: e1560000     	cmp	r6, r0
   8f31c: aa000004     	bge	0x8f334 <.text+0x7f234> @ imm = #0x10
   8f320: e5970004     	ldr	r0, [r7, #0x4]
   8f324: e5900014     	ldr	r0, [r0, #0x14]
   8f328: e1580000     	cmp	r8, r0
   8f32c: aafffd5a     	bge	0x8e89c <.text+0x7e79c> @ imm = #-0xa98
   8f330: ea000003     	b	0x8f344 <.text+0x7f244> @ imm = #0xc
   8f334: e595001c     	ldr	r0, [r5, #0x1c]
   8f338: ebff4682     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2e5f8
   8f33c: e1580000     	cmp	r8, r0
   8f340: aafffd55     	bge	0x8e89c <.text+0x7e79c> @ imm = #-0xaac
   8f344: e59d007c     	ldr	r0, [sp, #0x7c]
   8f348: e5971008     	ldr	r1, [r7, #0x8]
   8f34c: e5900000     	ldr	r0, [r0]
   8f350: e0810000     	add	r0, r1, r0
   8f354: e5870008     	str	r0, [r7, #0x8]
   8f358: ea0011d6     	b	0x93ab8 <.text+0x839b8> @ imm = #0x4758
   8f35c: 00558b67     	subseq	r8, r5, r7, ror #22
   8f360: 00558ad1     	ldrsbeq	r8, [r5], #-161
   8f364: 00558af7     	ldrsheq	r8, [r5], #-167
   8f368: 00559201     	subseq	r9, r5, r1, lsl #4
   8f36c: eeb00b48     	vmov.f64	d0, d8
   8f370: e28c0008     	add	r0, r12, #8
   8f374: eb00487b     	bl	0xa1568 <.text+0x91468> @ imm = #0x121ec
   8f378: e59fcfe0     	ldr	r12, [pc, #0xfe0]       @ 0x90360 <.text+0x80260>
   8f37c: e5941000     	ldr	r1, [r4]
   8f380: e08fc00c     	add	r12, pc, r12
   8f384: e2412001     	sub	r2, r1, #1
   8f388: e0010291     	mul	r1, r1, r2
   8f38c: e3110001     	tst	r1, #1
   8f390: 0affffaf     	beq	0x8f254 <.text+0x7f154> @ imm = #-0x144
   8f394: e5991000     	ldr	r1, [r9]
   8f398: e3510009     	cmp	r1, #9
   8f39c: daffffac     	ble	0x8f254 <.text+0x7f154> @ imm = #-0x150
   8f3a0: eeb00b48     	vmov.f64	d0, d8
   8f3a4: e28c0008     	add	r0, r12, #8
   8f3a8: eb00486e     	bl	0xa1568 <.text+0x91468> @ imm = #0x121b8
   8f3ac: e59fcff8     	ldr	r12, [pc, #0xff8]       @ 0x903ac <.text+0x802ac>
   8f3b0: e08fc00c     	add	r12, pc, r12
   8f3b4: eaffffec     	b	0x8f36c <.text+0x7f26c> @ imm = #-0x50
   8f3b8: 00582610     	subseq	r2, r8, r0, lsl r6
   8f3bc: e320f000     	nop
   8f3c0: 00000000     	andeq	r0, r0, r0
   8f3c4: 40588000     	subsmi	r8, r8, r0
   8f3c8: e3a00007     	mov	r0, #7
   8f3cc: e3a01000     	mov	r1, #0
   8f3d0: eb001707     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x5c1c
   8f3d4: e5940000     	ldr	r0, [r4]
   8f3d8: e2401001     	sub	r1, r0, #1
   8f3dc: e0000190     	mul	r0, r0, r1
   8f3e0: e3100001     	tst	r0, #1
   8f3e4: 0a0011b3     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x46cc
   8f3e8: e5990000     	ldr	r0, [r9]
   8f3ec: e350000a     	cmp	r0, #10
   8f3f0: ba0011b0     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x46c0
   8f3f4: e3a00007     	mov	r0, #7
   8f3f8: e3a01000     	mov	r1, #0
   8f3fc: eb0016fc     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x5bf0
   8f400: eafffff0     	b	0x8f3c8 <.text+0x7f2c8> @ imm = #-0x40
   8f404: 00558abf     	ldrheq	r8, [r5], #-175
   8f408: 00558a29     	subseq	r8, r5, r9, lsr #20
   8f40c: 00558a4f     	subseq	r8, r5, pc, asr #20
   8f410: 00559290     	<unknown>
   8f414: e5940000     	ldr	r0, [r4]
   8f418: e5973008     	ldr	r3, [r7, #0x8]
   8f41c: e2401001     	sub	r1, r0, #1
   8f420: e0010190     	mul	r1, r0, r1
   8f424: e59d007c     	ldr	r0, [sp, #0x7c]
   8f428: e5902000     	ldr	r2, [r0]
   8f42c: e5990000     	ldr	r0, [r9]
   8f430: e3110001     	tst	r1, #1
   8f434: e0832002     	add	r2, r3, r2
   8f438: e5872008     	str	r2, [r7, #0x8]
   8f43c: 0a00119d     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x4674
   8f440: e350000a     	cmp	r0, #10
   8f444: ba00119b     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x466c
   8f448: e59d007c     	ldr	r0, [sp, #0x7c]
   8f44c: e5971008     	ldr	r1, [r7, #0x8]
   8f450: e5900000     	ldr	r0, [r0]
   8f454: e0810000     	add	r0, r1, r0
   8f458: e5870008     	str	r0, [r7, #0x8]
   8f45c: eaffffec     	b	0x8f414 <.text+0x7f314> @ imm = #-0x50
   8f460: 00558a67     	subseq	r8, r5, r7, ror #20
   8f464: 005589d1     	ldrsbeq	r8, [r5], #-145
   8f468: 005589f7     	ldrsheq	r8, [r5], #-151
   8f46c: 00559238     	subseq	r9, r5, r8, lsr r2
   8f470: 00559275     	subseq	r9, r5, r5, ror r2
   8f474: 00584548     	subseq	r4, r8, r8, asr #10
   8f478: 0058450c     	subseq	r4, r8, r12, lsl #10
   8f47c: e59f0fcc     	ldr	r0, [pc, #0xfcc]        @ 0x90450 <.text+0x80350>
   8f480: e3a07001     	mov	r7, #1
   8f484: e59f1fc8     	ldr	r1, [pc, #0xfc8]        @ 0x90454 <.text+0x80354>
   8f488: e59f2fc8     	ldr	r2, [pc, #0xfc8]        @ 0x90458 <.text+0x80358>
   8f48c: e08f0000     	add	r0, pc, r0
   8f490: e59f3fc4     	ldr	r3, [pc, #0xfc4]        @ 0x9045c <.text+0x8035c>
   8f494: e08f1001     	add	r1, pc, r1
   8f498: e08f2002     	add	r2, pc, r2
   8f49c: e58d7000     	str	r7, [sp]
   8f4a0: e08f3003     	add	r3, pc, r3
   8f4a4: e58d3004     	str	r3, [sp, #0x4]
   8f4a8: e30132c9     	movw	r3, #0x12c9
   8f4ac: eb01ab04     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ac10
   8f4b0: e59d00b8     	ldr	r0, [sp, #0xb8]
   8f4b4: e3001fa1     	movw	r1, #0xfa1
   8f4b8: ebfee9f6     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x45828
   8f4bc: e59d00c0     	ldr	r0, [sp, #0xc0]
   8f4c0: ebff5eae     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x28548
   8f4c4: e5940000     	ldr	r0, [r4]
   8f4c8: e3a02000     	mov	r2, #0
   8f4cc: e2401001     	sub	r1, r0, #1
   8f4d0: e0010190     	mul	r1, r0, r1
   8f4d4: e5990000     	ldr	r0, [r9]
   8f4d8: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0x904c0 <.text+0x803c0>
   8f4dc: e08f3003     	add	r3, pc, r3
   8f4e0: e3110001     	tst	r1, #1
   8f4e4: e5c32000     	strb	r2, [r3]
   8f4e8: 0a001172     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x45c8
   8f4ec: e350000a     	cmp	r0, #10
   8f4f0: ba001170     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x45c0
   8f4f4: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x904c4 <.text+0x803c4>
   8f4f8: e3a07001     	mov	r7, #1
   8f4fc: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0x904c8 <.text+0x803c8>
   8f500: e59f2fc4     	ldr	r2, [pc, #0xfc4]        @ 0x904cc <.text+0x803cc>
   8f504: e08f0000     	add	r0, pc, r0
   8f508: e59f3fc0     	ldr	r3, [pc, #0xfc0]        @ 0x904d0 <.text+0x803d0>
   8f50c: e08f1001     	add	r1, pc, r1
   8f510: e08f2002     	add	r2, pc, r2
   8f514: e58d7000     	str	r7, [sp]
   8f518: e08f3003     	add	r3, pc, r3
   8f51c: e58d3004     	str	r3, [sp, #0x4]
   8f520: e30132c9     	movw	r3, #0x12c9
   8f524: eb01aae6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6ab98
   8f528: e59d00b8     	ldr	r0, [sp, #0xb8]
   8f52c: e3001fa1     	movw	r1, #0xfa1
   8f530: ebfee9d8     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x458a0
   8f534: e59d00c0     	ldr	r0, [sp, #0xc0]
   8f538: ebff5e90     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x285c0
   8f53c: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0x90538 <.text+0x80438>
   8f540: e3a00000     	mov	r0, #0
   8f544: e08f1001     	add	r1, pc, r1
   8f548: e5c10000     	strb	r0, [r1]
   8f54c: eaffffca     	b	0x8f47c <.text+0x7f37c> @ imm = #-0xd8
   8f550: 00582464     	subseq	r2, r8, r4, ror #8
   8f554: e59f6fe0     	ldr	r6, [pc, #0xfe0]        @ 0x9053c <.text+0x8043c>
   8f558: e08f6006     	add	r6, pc, r6
   8f55c: e1a00006     	mov	r0, r6
   8f560: eb145ae8     	bl	0x5a6108 <.text+0x596008> @ imm = #0x516ba0
   8f564: e1a00006     	mov	r0, r6
   8f568: e5d75000     	ldrb	r5, [r7]
   8f56c: eb145c54     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x517150
   8f570: e5940000     	ldr	r0, [r4]
   8f574: e2401001     	sub	r1, r0, #1
   8f578: e0000190     	mul	r0, r0, r1
   8f57c: e3100001     	tst	r0, #1
   8f580: 0a000009     	beq	0x8f5ac <.text+0x7f4ac> @ imm = #0x24
   8f584: e5990000     	ldr	r0, [r9]
   8f588: e3500009     	cmp	r0, #9
   8f58c: da000006     	ble	0x8f5ac <.text+0x7f4ac> @ imm = #0x18
   8f590: e59f6fe0     	ldr	r6, [pc, #0xfe0]        @ 0x90578 <.text+0x80478>
   8f594: e08f6006     	add	r6, pc, r6
   8f598: e1a00006     	mov	r0, r6
   8f59c: eb145ad9     	bl	0x5a6108 <.text+0x596008> @ imm = #0x516b64
   8f5a0: e1a00006     	mov	r0, r6
   8f5a4: eb145c46     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x517118
   8f5a8: eaffffe9     	b	0x8f554 <.text+0x7f454> @ imm = #-0x5c
   8f5ac: e59f3fc8     	ldr	r3, [pc, #0xfc8]        @ 0x9057c <.text+0x8047c>
   8f5b0: e3550000     	cmp	r5, #0
   8f5b4: e59d50c0     	ldr	r5, [sp, #0xc0]
   8f5b8: e08f3003     	add	r3, pc, r3
   8f5bc: 0a000010     	beq	0x8f604 <.text+0x7f504> @ imm = #0x40
   8f5c0: e302004c     	movw	r0, #0x204c
   8f5c4: e7930000     	ldr	r0, [r3, r0]
   8f5c8: e3500002     	cmp	r0, #2
   8f5cc: 1a000061     	bne	0x8f758 <.text+0x7f658> @ imm = #0x184
   8f5d0: ee008a10     	vmov	s0, r8
   8f5d4: e3020034     	movw	r0, #0x2034
   8f5d8: eeb80bc0     	vcvt.f64.s32	d0, s0
   8f5dc: e7930000     	ldr	r0, [r3, r0]
   8f5e0: e3500000     	cmp	r0, #0
   8f5e4: 0a000012     	beq	0x8f634 <.text+0x7f534> @ imm = #0x48
   8f5e8: e3500001     	cmp	r0, #1
   8f5ec: 1a00001a     	bne	0x8f65c <.text+0x7f55c> @ imm = #0x68
   8f5f0: e3020030     	movw	r0, #0x2030
   8f5f4: e7931000     	ldr	r1, [r3, r0]
   8f5f8: e2830008     	add	r0, r3, #8
   8f5fc: eb003b71     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xedc4
   8f600: ea00000d     	b	0x8f63c <.text+0x7f53c> @ imm = #0x34
   8f604: e3020034     	movw	r0, #0x2034
   8f608: e7930000     	ldr	r0, [r3, r0]
   8f60c: e3500001     	cmp	r0, #1
   8f610: 0a00001a     	beq	0x8f680 <.text+0x7f580> @ imm = #0x68
   8f614: e3500000     	cmp	r0, #0
   8f618: 1affffe8     	bne	0x8f5c0 <.text+0x7f4c0> @ imm = #-0x60
   8f61c: e2831008     	add	r1, r3, #8
   8f620: e1a00005     	mov	r0, r5
   8f624: eb0046cd     	bl	0xa1160 <.text+0x91060> @ imm = #0x11b34
   8f628: e59f3fd0     	ldr	r3, [pc, #0xfd0]        @ 0x90600 <.text+0x80500>
   8f62c: e08f3003     	add	r3, pc, r3
   8f630: eaffffe2     	b	0x8f5c0 <.text+0x7f4c0> @ imm = #-0x78
   8f634: e2830008     	add	r0, r3, #8
   8f638: eb0047ca     	bl	0xa1568 <.text+0x91468> @ imm = #0x11f28
   8f63c: e3a01001     	mov	r1, #1
   8f640: e3500000     	cmp	r0, #0
   8f644: 03a01000     	moveq	r1, #0
   8f648: ea00003e     	b	0x8f748 <.text+0x7f648> @ imm = #0xf8
   8f64c: 0055886f     	subseq	r8, r5, pc, ror #16
   8f650: 005587d9     	ldrsbeq	r8, [r5], #-121
   8f654: 005587ff     	ldrsheq	r8, [r5], #-127
   8f658: 00558e3e     	subseq	r8, r5, lr, lsr lr
   8f65c: e5940000     	ldr	r0, [r4]
   8f660: e2401001     	sub	r1, r0, #1
   8f664: e0000190     	mul	r0, r0, r1
   8f668: e3100001     	tst	r0, #1
   8f66c: 0a000010     	beq	0x8f6b4 <.text+0x7f5b4> @ imm = #0x40
   8f670: e5990000     	ldr	r0, [r9]
   8f674: e3500009     	cmp	r0, #9
   8f678: ca000022     	bgt	0x8f708 <.text+0x7f608> @ imm = #0x88
   8f67c: ea00000c     	b	0x8f6b4 <.text+0x7f5b4> @ imm = #0x30
   8f680: e5940000     	ldr	r0, [r4]
   8f684: e2401001     	sub	r1, r0, #1
   8f688: e0000190     	mul	r0, r0, r1
   8f68c: e3100001     	tst	r0, #1
   8f690: 0a00003d     	beq	0x8f78c <.text+0x7f68c> @ imm = #0xf4
   8f694: e5990000     	ldr	r0, [r9]
   8f698: e3500009     	cmp	r0, #9
   8f69c: ca000049     	bgt	0x8f7c8 <.text+0x7f6c8> @ imm = #0x124
   8f6a0: ea000039     	b	0x8f78c <.text+0x7f68c> @ imm = #0xe4
   8f6a4: 00558807     	subseq	r8, r5, r7, lsl #16
   8f6a8: 00558771     	subseq	r8, r5, r1, ror r7
   8f6ac: 00558797     	<unknown>
   8f6b0: 00558dd6     	ldrsbeq	r8, [r5], #-214
   8f6b4: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x90690 <.text+0x80590>
   8f6b8: e3a06002     	mov	r6, #2
   8f6bc: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x90694 <.text+0x80594>
   8f6c0: e59f2fd0     	ldr	r2, [pc, #0xfd0]        @ 0x90698 <.text+0x80598>
   8f6c4: e08f0000     	add	r0, pc, r0
   8f6c8: e59f3fcc     	ldr	r3, [pc, #0xfcc]        @ 0x9069c <.text+0x8059c>
   8f6cc: e08f1001     	add	r1, pc, r1
   8f6d0: e08f2002     	add	r2, pc, r2
   8f6d4: e58d6000     	str	r6, [sp]
   8f6d8: e08f3003     	add	r3, pc, r3
   8f6dc: e58d3004     	str	r3, [sp, #0x4]
   8f6e0: e3a03e75     	mov	r3, #1872
   8f6e4: eb01aa76     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a9d8
   8f6e8: e5940000     	ldr	r0, [r4]
   8f6ec: e2401001     	sub	r1, r0, #1
   8f6f0: e0000190     	mul	r0, r0, r1
   8f6f4: e3100001     	tst	r0, #1
   8f6f8: 0a000011     	beq	0x8f744 <.text+0x7f644> @ imm = #0x44
   8f6fc: e5990000     	ldr	r0, [r9]
   8f700: e350000a     	cmp	r0, #10
   8f704: ba00000e     	blt	0x8f744 <.text+0x7f644> @ imm = #0x38
   8f708: e59f0f90     	ldr	r0, [pc, #0xf90]        @ 0x906a0 <.text+0x805a0>
   8f70c: e3a06002     	mov	r6, #2
   8f710: e59f1ff8     	ldr	r1, [pc, #0xff8]        @ 0x90710 <.text+0x80610>
   8f714: e59f2ff8     	ldr	r2, [pc, #0xff8]        @ 0x90714 <.text+0x80614>
   8f718: e08f0000     	add	r0, pc, r0
   8f71c: e59f3ff4     	ldr	r3, [pc, #0xff4]        @ 0x90718 <.text+0x80618>
   8f720: e08f1001     	add	r1, pc, r1
   8f724: e08f2002     	add	r2, pc, r2
   8f728: e58d6000     	str	r6, [sp]
   8f72c: e08f3003     	add	r3, pc, r3
   8f730: e58d3004     	str	r3, [sp, #0x4]
   8f734: e3a03e75     	mov	r3, #1872
   8f738: eb01aa61     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a984
   8f73c: eaffffdc     	b	0x8f6b4 <.text+0x7f5b4> @ imm = #-0x90
   8f740: 00582254     	subseq	r2, r8, r4, asr r2
   8f744: e3a01000     	mov	r1, #0
   8f748: e59f3fcc     	ldr	r3, [pc, #0xfcc]        @ 0x9071c <.text+0x8061c>
   8f74c: e302004c     	movw	r0, #0x204c
   8f750: e08f3003     	add	r3, pc, r3
   8f754: e7831000     	str	r1, [r3, r0]
   8f758: e59d00b4     	ldr	r0, [sp, #0xb4]
   8f75c: e5d00000     	ldrb	r0, [r0]
   8f760: e3500000     	cmp	r0, #0
   8f764: 0a000033     	beq	0x8f838 <.text+0x7f738> @ imm = #0xcc
   8f768: e5940000     	ldr	r0, [r4]
   8f76c: e2401001     	sub	r1, r0, #1
   8f770: e0000190     	mul	r0, r0, r1
   8f774: e3100001     	tst	r0, #1
   8f778: 0a00001b     	beq	0x8f7ec <.text+0x7f6ec> @ imm = #0x6c
   8f77c: e5990000     	ldr	r0, [r9]
   8f780: e3500009     	cmp	r0, #9
   8f784: ca000022     	bgt	0x8f814 <.text+0x7f714> @ imm = #0x88
   8f788: ea000017     	b	0x8f7ec <.text+0x7f6ec> @ imm = #0x5c
   8f78c: e3020030     	movw	r0, #0x2030
   8f790: e2831008     	add	r1, r3, #8
   8f794: e7932000     	ldr	r2, [r3, r0]
   8f798: e1a00005     	mov	r0, r5
   8f79c: eb00398d     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xe634
   8f7a0: e59f3f78     	ldr	r3, [pc, #0xf78]        @ 0x90720 <.text+0x80620>
   8f7a4: e5940000     	ldr	r0, [r4]
   8f7a8: e08f3003     	add	r3, pc, r3
   8f7ac: e2401001     	sub	r1, r0, #1
   8f7b0: e0000190     	mul	r0, r0, r1
   8f7b4: e3100001     	tst	r0, #1
   8f7b8: 0affff80     	beq	0x8f5c0 <.text+0x7f4c0> @ imm = #-0x200
   8f7bc: e5990000     	ldr	r0, [r9]
   8f7c0: e350000a     	cmp	r0, #10
   8f7c4: baffff7d     	blt	0x8f5c0 <.text+0x7f4c0> @ imm = #-0x20c
   8f7c8: e3020030     	movw	r0, #0x2030
   8f7cc: e2831008     	add	r1, r3, #8
   8f7d0: e7932000     	ldr	r2, [r3, r0]
   8f7d4: e1a00005     	mov	r0, r5
   8f7d8: eb00397e     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xe5f8
   8f7dc: e59f3fc8     	ldr	r3, [pc, #0xfc8]        @ 0x907ac <.text+0x806ac>
   8f7e0: e08f3003     	add	r3, pc, r3
   8f7e4: eaffffe8     	b	0x8f78c <.text+0x7f68c> @ imm = #-0x60
   8f7e8: 005821d8     	ldrsbeq	r2, [r8], #-24
   8f7ec: e1a00005     	mov	r0, r5
   8f7f0: ebff48b6     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x2dd28
   8f7f4: e5941000     	ldr	r1, [r4]
   8f7f8: e2412001     	sub	r2, r1, #1
   8f7fc: e0010291     	mul	r1, r1, r2
   8f800: e3110001     	tst	r1, #1
   8f804: 0a000005     	beq	0x8f820 <.text+0x7f720> @ imm = #0x14
   8f808: e5991000     	ldr	r1, [r9]
   8f80c: e3510009     	cmp	r1, #9
   8f810: da000002     	ble	0x8f820 <.text+0x7f720> @ imm = #0x8
   8f814: e1a00005     	mov	r0, r5
   8f818: ebff48ac     	bl	0x61ad0 <.text+0x519d0> @ imm = #-0x2dd50
   8f81c: eafffff2     	b	0x8f7ec <.text+0x7f6ec> @ imm = #-0x38
   8f820: e59f3f88     	ldr	r3, [pc, #0xf88]        @ 0x907b0 <.text+0x806b0>
   8f824: e3500000     	cmp	r0, #0
   8f828: 15d50108     	ldrbne	r0, [r5, #0x108]
   8f82c: e08f3003     	add	r3, pc, r3
   8f830: 13500000     	cmpne	r0, #0
   8f834: 1a000033     	bne	0x8f908 <.text+0x7f808> @ imm = #0xcc
   8f838: e302004c     	movw	r0, #0x204c
   8f83c: e7930000     	ldr	r0, [r3, r0]
   8f840: e3500001     	cmp	r0, #1
   8f844: 0a000011     	beq	0x8f890 <.text+0x7f790> @ imm = #0x44
   8f848: e3500000     	cmp	r0, #0
   8f84c: 1a001099     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x4264
   8f850: ee008a10     	vmov	s0, r8
   8f854: e3020034     	movw	r0, #0x2034
   8f858: eeb88bc0     	vcvt.f64.s32	d8, s0
   8f85c: e7930000     	ldr	r0, [r3, r0]
   8f860: e3500000     	cmp	r0, #0
   8f864: 0a00003a     	beq	0x8f954 <.text+0x7f854> @ imm = #0xe8
   8f868: e3500001     	cmp	r0, #1
   8f86c: 1a000076     	bne	0x8fa4c <.text+0x7f94c> @ imm = #0x1d8
   8f870: e3020030     	movw	r0, #0x2030
   8f874: eeb00b48     	vmov.f64	d0, d8
   8f878: e7931000     	ldr	r1, [r3, r0]
   8f87c: e2830008     	add	r0, r3, #8
   8f880: eb003b38     	bl	0x9e568 <.text+0x8e468> @ imm = #0xece0
   8f884: e3500000     	cmp	r0, #0
   8f888: 1a000036     	bne	0x8f968 <.text+0x7f868> @ imm = #0xd8
   8f88c: ea0000cd     	b	0x8fbc8 <.text+0x7fac8> @ imm = #0x334
   8f890: e5940000     	ldr	r0, [r4]
   8f894: e2401001     	sub	r1, r0, #1
   8f898: e0000190     	mul	r0, r0, r1
   8f89c: e3100001     	tst	r0, #1
   8f8a0: e5940000     	ldr	r0, [r4]
   8f8a4: ee008a10     	vmov	s0, r8
   8f8a8: e2401001     	sub	r1, r0, #1
   8f8ac: eeb88bc0     	vcvt.f64.s32	d8, s0
   8f8b0: e0010190     	mul	r1, r0, r1
   8f8b4: e3020034     	movw	r0, #0x2034
   8f8b8: e7930000     	ldr	r0, [r3, r0]
   8f8bc: e3110001     	tst	r1, #1
   8f8c0: 0a000002     	beq	0x8f8d0 <.text+0x7f7d0> @ imm = #0x8
   8f8c4: e5991000     	ldr	r1, [r9]
   8f8c8: e3510009     	cmp	r1, #9
   8f8cc: cafffff3     	bgt	0x8f8a0 <.text+0x7f7a0> @ imm = #-0x34
   8f8d0: e3500000     	cmp	r0, #0
   8f8d4: 0a000067     	beq	0x8fa78 <.text+0x7f978> @ imm = #0x19c
   8f8d8: e3500001     	cmp	r0, #1
   8f8dc: 1a00006b     	bne	0x8fa90 <.text+0x7f990> @ imm = #0x1ac
   8f8e0: e5940000     	ldr	r0, [r4]
   8f8e4: e2401001     	sub	r1, r0, #1
   8f8e8: e0000190     	mul	r0, r0, r1
   8f8ec: e3100001     	tst	r0, #1
   8f8f0: 0a0000ba     	beq	0x8fbe0 <.text+0x7fae0> @ imm = #0x2e8
   8f8f4: e5990000     	ldr	r0, [r9]
   8f8f8: e3500009     	cmp	r0, #9
   8f8fc: ca0000c6     	bgt	0x8fc1c <.text+0x7fb1c> @ imm = #0x318
   8f900: ea0000b6     	b	0x8fbe0 <.text+0x7fae0> @ imm = #0x2d8
   8f904: 005820c0     	subseq	r2, r8, r0, asr #1
   8f908: e59d00c4     	ldr	r0, [sp, #0xc4]
   8f90c: e5905088     	ldr	r5, [r0, #0x88]
   8f910: e59d00c0     	ldr	r0, [sp, #0xc0]
   8f914: ebff4959     	bl	0x61e80 <.text+0x51d80> @ imm = #-0x2da9c
   8f918: e59f3fbc     	ldr	r3, [pc, #0xfbc]        @ 0x908dc <.text+0x807dc>
   8f91c: e1550000     	cmp	r5, r0
   8f920: e59d50c0     	ldr	r5, [sp, #0xc0]
   8f924: e08f3003     	add	r3, pc, r3
   8f928: 3affffc2     	blo	0x8f838 <.text+0x7f738> @ imm = #-0xf8
   8f92c: e5940000     	ldr	r0, [r4]
   8f930: e2401001     	sub	r1, r0, #1
   8f934: e0000190     	mul	r0, r0, r1
   8f938: e3100001     	tst	r0, #1
   8f93c: 0a0000d5     	beq	0x8fc98 <.text+0x7fb98> @ imm = #0x354
   8f940: e5990000     	ldr	r0, [r9]
   8f944: e3500009     	cmp	r0, #9
   8f948: ca0000dd     	bgt	0x8fcc4 <.text+0x7fbc4> @ imm = #0x374
   8f94c: ea0000d1     	b	0x8fc98 <.text+0x7fb98> @ imm = #0x344
   8f950: 0058206c     	subseq	r2, r8, r12, rrx
   8f954: eeb00b48     	vmov.f64	d0, d8
   8f958: e2830008     	add	r0, r3, #8
   8f95c: eb004767     	bl	0xa1700 <.text+0x91600> @ imm = #0x11d9c
   8f960: e3500000     	cmp	r0, #0
   8f964: 0a000097     	beq	0x8fbc8 <.text+0x7fac8> @ imm = #0x25c
   8f968: eb01bb3e     	bl	0xfe668 <.text+0xee568> @ imm = #0x6ecf8
   8f96c: e3500001     	cmp	r0, #1
   8f970: ba000061     	blt	0x8fafc <.text+0x7f9fc> @ imm = #0x184
   8f974: e59f2fb0     	ldr	r2, [pc, #0xfb0]        @ 0x9092c <.text+0x8082c>
   8f978: e1a06000     	mov	r6, r0
   8f97c: ed9f0be7     	vldr	d0, [pc, #924]          @ 0x8fd20 <.text+0x7fc20>
   8f980: e3a05010     	mov	r5, #16
   8f984: e08f2002     	add	r2, pc, r2
   8f988: e3a07000     	mov	r7, #0
   8f98c: e3a00000     	mov	r0, #0
   8f990: ea000011     	b	0x8f9dc <.text+0x7f8dc> @ imm = #0x44
   8f994: 00582024     	subseq	r2, r8, r4, lsr #32
   8f998: 005584fb     	ldrsheq	r8, [r5], #-75
   8f99c: 00558465     	subseq	r8, r5, r5, ror #8
   8f9a0: 0055848b     	subseq	r8, r5, r11, lsl #9
   8f9a4: 00558aca     	subseq	r8, r5, r10, asr #21
   8f9a8: 00584000     	subseq	r4, r8, r0
   8f9ac: 005584ab     	subseq	r8, r5, r11, lsr #9
   8f9b0: 00558415     	subseq	r8, r5, r5, lsl r4
   8f9b4: 0055843b     	subseq	r8, r5, r11, lsr r4
   8f9b8: 005589d0     	ldrsbeq	r8, [r5], #-144
   8f9bc: e59f2f6c     	ldr	r2, [pc, #0xf6c]        @ 0x90930 <.text+0x80830>
   8f9c0: eeb00b49     	vmov.f64	d0, d9
   8f9c4: e1a00008     	mov	r0, r8
   8f9c8: e08f2002     	add	r2, pc, r2
   8f9cc: e2877e32     	add	r7, r7, #800
   8f9d0: e2566001     	subs	r6, r6, #1
   8f9d4: e2855028     	add	r5, r5, #40
   8f9d8: 0a00003c     	beq	0x8fad0 <.text+0x7f9d0> @ imm = #0xf0
   8f9dc: e1a08000     	mov	r8, r0
   8f9e0: e59d00c0     	ldr	r0, [sp, #0xc0]
   8f9e4: eeb09b40     	vmov.f64	d9, d0
   8f9e8: e592a020     	ldr	r10, [r2, #0x20]
   8f9ec: e5900230     	ldr	r0, [r0, #0x230]
   8f9f0: e0800007     	add	r0, r0, r7
   8f9f4: ebff1d74     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x38a30
   8f9f8: e3500000     	cmp	r0, #0
   8f9fc: 0affffee     	beq	0x8f9bc <.text+0x7f8bc> @ imm = #-0x48
   8fa00: e5940000     	ldr	r0, [r4]
   8fa04: e59f2f28     	ldr	r2, [pc, #0xf28]        @ 0x90934 <.text+0x80834>
   8fa08: e2401001     	sub	r1, r0, #1
   8fa0c: e08f2002     	add	r2, pc, r2
   8fa10: e0000190     	mul	r0, r0, r1
   8fa14: e3100001     	tst	r0, #1
   8fa18: e08a1005     	add	r1, r10, r5
   8fa1c: e5940000     	ldr	r0, [r4]
   8fa20: ed910b00     	vldr	d0, [r1]
   8fa24: e2401001     	sub	r1, r0, #1
   8fa28: ee390b00     	vadd.f64	d0, d9, d0
   8fa2c: e0010190     	mul	r1, r0, r1
   8fa30: e2880001     	add	r0, r8, #1
   8fa34: e3110001     	tst	r1, #1
   8fa38: 0affffe3     	beq	0x8f9cc <.text+0x7f8cc> @ imm = #-0x74
   8fa3c: e5991000     	ldr	r1, [r9]
   8fa40: e3510009     	cmp	r1, #9
   8fa44: cafffff3     	bgt	0x8fa18 <.text+0x7f918> @ imm = #-0x34
   8fa48: eaffffdf     	b	0x8f9cc <.text+0x7f8cc> @ imm = #-0x84
   8fa4c: e5940000     	ldr	r0, [r4]
   8fa50: e2401001     	sub	r1, r0, #1
   8fa54: e0000190     	mul	r0, r0, r1
   8fa58: e3100001     	tst	r0, #1
   8fa5c: 0a0000bd     	beq	0x8fd58 <.text+0x7fc58> @ imm = #0x2f4
   8fa60: e5990000     	ldr	r0, [r9]
   8fa64: e3500009     	cmp	r0, #9
   8fa68: ca0000cf     	bgt	0x8fdac <.text+0x7fcac> @ imm = #0x33c
   8fa6c: ea0000b9     	b	0x8fd58 <.text+0x7fc58> @ imm = #0x2e4
   8fa70: 00581f54     	subseq	r1, r8, r4, asr pc
   8fa74: 00583fb4     	ldrheq	r3, [r8], #-244
   8fa78: eeb00b48     	vmov.f64	d0, d8
   8fa7c: e2830008     	add	r0, r3, #8
   8fa80: eb0046b8     	bl	0xa1568 <.text+0x91468> @ imm = #0x11ae0
   8fa84: e59f3fb4     	ldr	r3, [pc, #0xfb4]        @ 0x90a40 <.text+0x80940>
   8fa88: e08f3003     	add	r3, pc, r3
   8fa8c: ea00006a     	b	0x8fc3c <.text+0x7fb3c> @ imm = #0x1a8
   8fa90: e59f0fac     	ldr	r0, [pc, #0xfac]        @ 0x90a44 <.text+0x80944>
   8fa94: e3a07002     	mov	r7, #2
   8fa98: e59f1fa8     	ldr	r1, [pc, #0xfa8]        @ 0x90a48 <.text+0x80948>
   8fa9c: e59f2fa8     	ldr	r2, [pc, #0xfa8]        @ 0x90a4c <.text+0x8094c>
   8faa0: e08f0000     	add	r0, pc, r0
   8faa4: e59f3fa4     	ldr	r3, [pc, #0xfa4]        @ 0x90a50 <.text+0x80950>
   8faa8: e08f1001     	add	r1, pc, r1
   8faac: e08f2002     	add	r2, pc, r2
   8fab0: e58d7000     	str	r7, [sp]
   8fab4: e08f3003     	add	r3, pc, r3
   8fab8: e58d3004     	str	r3, [sp, #0x4]
   8fabc: e3a03e75     	mov	r3, #1872
   8fac0: eb01a97f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a5fc
   8fac4: e59f3f88     	ldr	r3, [pc, #0xf88]        @ 0x90a54 <.text+0x80954>
   8fac8: e08f3003     	add	r3, pc, r3
   8facc: ea000067     	b	0x8fc70 <.text+0x7fb70> @ imm = #0x19c
   8fad0: e3500001     	cmp	r0, #1
   8fad4: ba000008     	blt	0x8fafc <.text+0x7f9fc> @ imm = #0x20
   8fad8: ee010a10     	vmov	s2, r0
   8fadc: eeb81bc1     	vcvt.f64.s32	d1, s2
   8fae0: ee800b01     	vdiv.f64	d0, d0, d1
   8fae4: ea000005     	b	0x8fb00 <.text+0x7fa00> @ imm = #0x14
   8fae8: 00558387     	subseq	r8, r5, r7, lsl #7
   8faec: 005582f1     	ldrsheq	r8, [r5], #-33
   8faf0: 00558317     	subseq	r8, r5, r7, lsl r3
   8faf4: 0055890c     	subseq	r8, r5, r12, lsl #18
   8faf8: 00581e10     	subseq	r1, r8, r0, lsl lr
   8fafc: ed9f0b87     	vldr	d0, [pc, #540]          @ 0x8fd20 <.text+0x7fc20>
   8fb00: e59f6fe0     	ldr	r6, [pc, #0xfe0]        @ 0x90ae8 <.text+0x809e8>
   8fb04: e5940000     	ldr	r0, [r4]
   8fb08: e08f6006     	add	r6, pc, r6
   8fb0c: e2401001     	sub	r1, r0, #1
   8fb10: e0000190     	mul	r0, r0, r1
   8fb14: e3100001     	tst	r0, #1
   8fb18: e5940000     	ldr	r0, [r4]
   8fb1c: e2401001     	sub	r1, r0, #1
   8fb20: e0000190     	mul	r0, r0, r1
   8fb24: e3100001     	tst	r0, #1
   8fb28: 0a000002     	beq	0x8fb38 <.text+0x7fa38> @ imm = #0x8
   8fb2c: e5990000     	ldr	r0, [r9]
   8fb30: e3500009     	cmp	r0, #9
   8fb34: cafffff7     	bgt	0x8fb18 <.text+0x7fa18> @ imm = #-0x24
   8fb38: eeb40bc8     	vcmpe.f64	d0, d8
   8fb3c: e3a07000     	mov	r7, #0
   8fb40: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8fb44: aa000016     	bge	0x8fba4 <.text+0x7faa4> @ imm = #0x58
   8fb48: ed9f1b76     	vldr	d1, [pc, #472]          @ 0x8fd28 <.text+0x7fc28>
   8fb4c: e3a07032     	mov	r7, #50
   8fb50: ee381b01     	vadd.f64	d1, d8, d1
   8fb54: eeb41bc0     	vcmpe.f64	d1, d0
   8fb58: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8fb5c: da000010     	ble	0x8fba4 <.text+0x7faa4> @ imm = #0x40
   8fb60: ed9f2b72     	vldr	d2, [pc, #456]          @ 0x8fd30 <.text+0x7fc30>
   8fb64: ee311b02     	vadd.f64	d1, d1, d2
   8fb68: ee300b02     	vadd.f64	d0, d0, d2
   8fb6c: ee801b01     	vdiv.f64	d1, d0, d1
   8fb70: eeb51bc0     	vcmpe.f64	d1, #0
   8fb74: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8fb78: ed9f0b68     	vldr	d0, [pc, #416]          @ 0x8fd20 <.text+0x7fc20>
   8fb7c: ed9f2b6d     	vldr	d2, [pc, #436]          @ 0x8fd38 <.text+0x7fc38>
   8fb80: 4eb01b40     	vmovmi.f64	d1, d0
   8fb84: ed9f0b6d     	vldr	d0, [pc, #436]          @ 0x8fd40 <.text+0x7fc40>
   8fb88: eeb41bc0     	vcmpe.f64	d1, d0
   8fb8c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   8fb90: ceb01b40     	vmovgt.f64	d1, d0
   8fb94: ed9f0b6b     	vldr	d0, [pc, #428]          @ 0x8fd48 <.text+0x7fc48>
   8fb98: ee010b02     	vmla.f64	d0, d1, d2
   8fb9c: eb14185d     	bl	0x595d18 <.text+0x585c18> @ imm = #0x506174
   8fba0: e1a07000     	mov	r7, r0
   8fba4: e5940000     	ldr	r0, [r4]
   8fba8: e2401001     	sub	r1, r0, #1
   8fbac: e0000190     	mul	r0, r0, r1
   8fbb0: e3100001     	tst	r0, #1
   8fbb4: 0a00008a     	beq	0x8fde4 <.text+0x7fce4> @ imm = #0x228
   8fbb8: e5990000     	ldr	r0, [r9]
   8fbbc: e3500009     	cmp	r0, #9
   8fbc0: ca000093     	bgt	0x8fe14 <.text+0x7fd14> @ imm = #0x24c
   8fbc4: ea000086     	b	0x8fde4 <.text+0x7fce4> @ imm = #0x218
   8fbc8: e59f2fcc     	ldr	r2, [pc, #0xfcc]        @ 0x90b9c <.text+0x80a9c>
   8fbcc: e302004c     	movw	r0, #0x204c
   8fbd0: e3a01002     	mov	r1, #2
   8fbd4: e08f2002     	add	r2, pc, r2
   8fbd8: e7821000     	str	r1, [r2, r0]
   8fbdc: ea000026     	b	0x8fc7c <.text+0x7fb7c> @ imm = #0x98
   8fbe0: e3020030     	movw	r0, #0x2030
   8fbe4: eeb00b48     	vmov.f64	d0, d8
   8fbe8: e7931000     	ldr	r1, [r3, r0]
   8fbec: e2830008     	add	r0, r3, #8
   8fbf0: eb0039f4     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xe7d0
   8fbf4: e59f3fe4     	ldr	r3, [pc, #0xfe4]        @ 0x90be0 <.text+0x80ae0>
   8fbf8: e5941000     	ldr	r1, [r4]
   8fbfc: e08f3003     	add	r3, pc, r3
   8fc00: e2412001     	sub	r2, r1, #1
   8fc04: e0010291     	mul	r1, r1, r2
   8fc08: e3110001     	tst	r1, #1
   8fc0c: 0a00000a     	beq	0x8fc3c <.text+0x7fb3c> @ imm = #0x28
   8fc10: e5991000     	ldr	r1, [r9]
   8fc14: e3510009     	cmp	r1, #9
   8fc18: da000007     	ble	0x8fc3c <.text+0x7fb3c> @ imm = #0x1c
   8fc1c: e3020030     	movw	r0, #0x2030
   8fc20: eeb00b48     	vmov.f64	d0, d8
   8fc24: e7931000     	ldr	r1, [r3, r0]
   8fc28: e2830008     	add	r0, r3, #8
   8fc2c: eb0039e5     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xe794
   8fc30: e59f3fac     	ldr	r3, [pc, #0xfac]        @ 0x90be4 <.text+0x80ae4>
   8fc34: e08f3003     	add	r3, pc, r3
   8fc38: eaffffe8     	b	0x8fbe0 <.text+0x7fae0> @ imm = #-0x60
   8fc3c: e3500000     	cmp	r0, #0
   8fc40: 0a00000a     	beq	0x8fc70 <.text+0x7fb70> @ imm = #0x28
   8fc44: e59d00c0     	ldr	r0, [sp, #0xc0]
   8fc48: e5935008     	ldr	r5, [r3, #0x8]
   8fc4c: e590001c     	ldr	r0, [r0, #0x1c]
   8fc50: ebff443e     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x2ef08
   8fc54: e59f3f8c     	ldr	r3, [pc, #0xf8c]        @ 0x90be8 <.text+0x80ae8>
   8fc58: e59d1060     	ldr	r1, [sp, #0x60]
   8fc5c: e08f3003     	add	r3, pc, r3
   8fc60: e5911000     	ldr	r1, [r1]
   8fc64: e0810000     	add	r0, r1, r0
   8fc68: e1550000     	cmp	r5, r0
   8fc6c: aa000004     	bge	0x8fc84 <.text+0x7fb84> @ imm = #0x10
   8fc70: e302004c     	movw	r0, #0x204c
   8fc74: e3a01002     	mov	r1, #2
   8fc78: e7831000     	str	r1, [r3, r0]
   8fc7c: e3a00003     	mov	r0, #3
   8fc80: ea0000ca     	b	0x8ffb0 <.text+0x7feb0> @ imm = #0x328
   8fc84: e5930008     	ldr	r0, [r3, #0x8]
   8fc88: e0400001     	sub	r0, r0, r1
   8fc8c: e5830008     	str	r0, [r3, #0x8]
   8fc90: ea000f88     	b	0x93ab8 <.text+0x839b8> @ imm = #0x3e20
   8fc94: 00581cf8     	ldrsheq	r1, [r8], #-200
   8fc98: e1a00005     	mov	r0, r5
   8fc9c: e3a01001     	mov	r1, #1
   8fca0: eb0015a3     	bl	0x95334 <.text+0x85234> @ imm = #0x568c
   8fca4: e5941000     	ldr	r1, [r4]
   8fca8: e2412001     	sub	r2, r1, #1
   8fcac: e0010291     	mul	r1, r1, r2
   8fcb0: e3110001     	tst	r1, #1
   8fcb4: 0a000007     	beq	0x8fcd8 <.text+0x7fbd8> @ imm = #0x1c
   8fcb8: e5991000     	ldr	r1, [r9]
   8fcbc: e3510009     	cmp	r1, #9
   8fcc0: da000004     	ble	0x8fcd8 <.text+0x7fbd8> @ imm = #0x10
   8fcc4: e1a00005     	mov	r0, r5
   8fcc8: e3a01001     	mov	r1, #1
   8fccc: eb001598     	bl	0x95334 <.text+0x85234> @ imm = #0x5660
   8fcd0: eafffff0     	b	0x8fc98 <.text+0x7fb98> @ imm = #-0x40
   8fcd4: 00581cd0     	ldrsbeq	r1, [r8], #-192
   8fcd8: e59f3ff4     	ldr	r3, [pc, #0xff4]        @ 0x90cd4 <.text+0x80bd4>
   8fcdc: e3500000     	cmp	r0, #0
   8fce0: e08f3003     	add	r3, pc, r3
   8fce4: 0afffed3     	beq	0x8f838 <.text+0x7f738> @ imm = #-0x4b4
   8fce8: e5940000     	ldr	r0, [r4]
   8fcec: e59f5fe4     	ldr	r5, [pc, #0xfe4]        @ 0x90cd8 <.text+0x80bd8>
   8fcf0: e2401001     	sub	r1, r0, #1
   8fcf4: e08f5005     	add	r5, pc, r5
   8fcf8: e0000190     	mul	r0, r0, r1
   8fcfc: e3100001     	tst	r0, #1
   8fd00: 0a00006b     	beq	0x8feb4 <.text+0x7fdb4> @ imm = #0x1ac
   8fd04: e5990000     	ldr	r0, [r9]
   8fd08: e3500009     	cmp	r0, #9
   8fd0c: ca000083     	bgt	0x8ff20 <.text+0x7fe20> @ imm = #0x20c
   8fd10: ea000067     	b	0x8feb4 <.text+0x7fdb4> @ imm = #0x19c
   8fd14: 00583d08     	subseq	r3, r8, r8, lsl #26
   8fd18: 00583ce4     	subseq	r3, r8, r4, ror #25
   8fd1c: 00581c6c     	subseq	r1, r8, r12, ror #24
		...
   8fd2c: c0140000     	andsgt	r0, r4, r0
   8fd30: 00000000     	andeq	r0, r0, r0
   8fd34: c0440000     	subgt	r0, r4, r0
   8fd38: 00000000     	andeq	r0, r0, r0
   8fd3c: c0690000     	rsbgt	r0, r9, r0
   8fd40: 00000000     	andeq	r0, r0, r0
   8fd44: 3ff00000     	svclo	#0xf00000
   8fd48: 00000000     	andeq	r0, r0, r0
   8fd4c: 4072c000     	rsbsmi	r12, r2, r0
   8fd50: 00581c1c     	subseq	r1, r8, r12, lsl r12
   8fd54: 00581c00     	subseq	r1, r8, r0, lsl #24
   8fd58: e59f0fa0     	ldr	r0, [pc, #0xfa0]        @ 0x90d00 <.text+0x80c00>
   8fd5c: e3a07002     	mov	r7, #2
   8fd60: e59f1f9c     	ldr	r1, [pc, #0xf9c]        @ 0x90d04 <.text+0x80c04>
   8fd64: e59f2f9c     	ldr	r2, [pc, #0xf9c]        @ 0x90d08 <.text+0x80c08>
   8fd68: e08f0000     	add	r0, pc, r0
   8fd6c: e59f3f98     	ldr	r3, [pc, #0xf98]        @ 0x90d0c <.text+0x80c0c>
   8fd70: e08f1001     	add	r1, pc, r1
   8fd74: e08f2002     	add	r2, pc, r2
   8fd78: e58d7000     	str	r7, [sp]
   8fd7c: e08f3003     	add	r3, pc, r3
   8fd80: e58d3004     	str	r3, [sp, #0x4]
   8fd84: e300376d     	movw	r3, #0x76d
   8fd88: eb01a8cd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a334
   8fd8c: e5940000     	ldr	r0, [r4]
   8fd90: e2401001     	sub	r1, r0, #1
   8fd94: e0000190     	mul	r0, r0, r1
   8fd98: e3100001     	tst	r0, #1
   8fd9c: 0affff89     	beq	0x8fbc8 <.text+0x7fac8> @ imm = #-0x1dc
   8fda0: e5990000     	ldr	r0, [r9]
   8fda4: e350000a     	cmp	r0, #10
   8fda8: baffff86     	blt	0x8fbc8 <.text+0x7fac8> @ imm = #-0x1e8
   8fdac: e59f0f5c     	ldr	r0, [pc, #0xf5c]        @ 0x90d10 <.text+0x80c10>
   8fdb0: e3a07002     	mov	r7, #2
   8fdb4: e59f1f58     	ldr	r1, [pc, #0xf58]        @ 0x90d14 <.text+0x80c14>
   8fdb8: e59f2f58     	ldr	r2, [pc, #0xf58]        @ 0x90d18 <.text+0x80c18>
   8fdbc: e08f0000     	add	r0, pc, r0
   8fdc0: e59f3f54     	ldr	r3, [pc, #0xf54]        @ 0x90d1c <.text+0x80c1c>
   8fdc4: e08f1001     	add	r1, pc, r1
   8fdc8: e08f2002     	add	r2, pc, r2
   8fdcc: e58d7000     	str	r7, [sp]
   8fdd0: e08f3003     	add	r3, pc, r3
   8fdd4: e58d3004     	str	r3, [sp, #0x4]
   8fdd8: e300376d     	movw	r3, #0x76d
   8fddc: eb01a8b8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a2e0
   8fde0: eaffffdc     	b	0x8fd58 <.text+0x7fc58> @ imm = #-0x90
   8fde4: e59f0f34     	ldr	r0, [pc, #0xf34]        @ 0x90d20 <.text+0x80c20>
   8fde8: e08f0000     	add	r0, pc, r0
   8fdec: e5905008     	ldr	r5, [r0, #0x8]
   8fdf0: eb01cb20     	bl	0x102a78 <.text+0xf2978> @ imm = #0x72c80
   8fdf4: e5941000     	ldr	r1, [r4]
   8fdf8: e2412001     	sub	r2, r1, #1
   8fdfc: e0010291     	mul	r1, r1, r2
   8fe00: e3110001     	tst	r1, #1
   8fe04: 0a000006     	beq	0x8fe24 <.text+0x7fd24> @ imm = #0x18
   8fe08: e5991000     	ldr	r1, [r9]
   8fe0c: e3510009     	cmp	r1, #9
   8fe10: da000003     	ble	0x8fe24 <.text+0x7fd24> @ imm = #0xc
   8fe14: eb01cb17     	bl	0x102a78 <.text+0xf2978> @ imm = #0x72c5c
   8fe18: eafffff1     	b	0x8fde4 <.text+0x7fce4> @ imm = #-0x3c
   8fe1c: 00581b90     	<unknown>
   8fe20: 00581b6c     	subseq	r1, r8, r12, ror #22
   8fe24: e1550000     	cmp	r5, r0
   8fe28: ba000016     	blt	0x8fe88 <.text+0x7fd88> @ imm = #0x58
   8fe2c: e59d00c0     	ldr	r0, [sp, #0xc0]
   8fe30: e3a01001     	mov	r1, #1
   8fe34: e3a05001     	mov	r5, #1
   8fe38: eb00153d     	bl	0x95334 <.text+0x85234> @ imm = #0x54f4
   8fe3c: e3500000     	cmp	r0, #0
   8fe40: 0a000010     	beq	0x8fe88 <.text+0x7fd88> @ imm = #0x40
   8fe44: e59f0fe0     	ldr	r0, [pc, #0xfe0]        @ 0x90e2c <.text+0x80d2c>
   8fe48: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x90e30 <.text+0x80d30>
   8fe4c: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x90e34 <.text+0x80d34>
   8fe50: e08f0000     	add	r0, pc, r0
   8fe54: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x90e38 <.text+0x80d38>
   8fe58: e08f1001     	add	r1, pc, r1
   8fe5c: e08f2002     	add	r2, pc, r2
   8fe60: e58d5000     	str	r5, [sp]
   8fe64: e08f3003     	add	r3, pc, r3
   8fe68: e58d3004     	str	r3, [sp, #0x4]
   8fe6c: e30132e9     	movw	r3, #0x12e9
   8fe70: eb01a893     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a24c
   8fe74: e59d00b8     	ldr	r0, [sp, #0xb8]
   8fe78: e3001fa1     	movw	r1, #0xfa1
   8fe7c: ebfee785     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x461ec
   8fe80: e59d00c0     	ldr	r0, [sp, #0xc0]
   8fe84: eafff9ef     	b	0x8e648 <.text+0x7e548> @ imm = #-0x1844
   8fe88: e5940000     	ldr	r0, [r4]
   8fe8c: e59f3fa8     	ldr	r3, [pc, #0xfa8]        @ 0x90e3c <.text+0x80d3c>
   8fe90: e2401001     	sub	r1, r0, #1
   8fe94: e08f3003     	add	r3, pc, r3
   8fe98: e0000190     	mul	r0, r0, r1
   8fe9c: e3100001     	tst	r0, #1
   8fea0: 0a000033     	beq	0x8ff74 <.text+0x7fe74> @ imm = #0xcc
   8fea4: e5990000     	ldr	r0, [r9]
   8fea8: e3500009     	cmp	r0, #9
   8feac: ca00003b     	bgt	0x8ffa0 <.text+0x7fea0> @ imm = #0xec
   8feb0: ea00002f     	b	0x8ff74 <.text+0x7fe74> @ imm = #0xbc
   8feb4: e59f0f84     	ldr	r0, [pc, #0xf84]        @ 0x90e40 <.text+0x80d40>
   8feb8: e3a03001     	mov	r3, #1
   8febc: e59f1f80     	ldr	r1, [pc, #0xf80]        @ 0x90e44 <.text+0x80d44>
   8fec0: e59f2f80     	ldr	r2, [pc, #0xf80]        @ 0x90e48 <.text+0x80d48>
   8fec4: e08f0000     	add	r0, pc, r0
   8fec8: e08f1001     	add	r1, pc, r1
   8fecc: e88d0028     	stm	sp, {r3, r5}
   8fed0: e08f2002     	add	r2, pc, r2
   8fed4: e30132d9     	movw	r3, #0x12d9
   8fed8: eb01a879     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a1e4
   8fedc: e59d00b8     	ldr	r0, [sp, #0xb8]
   8fee0: e3001fa1     	movw	r1, #0xfa1
   8fee4: ebfee76b     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x46254
   8fee8: e59d00c0     	ldr	r0, [sp, #0xc0]
   8feec: ebff5c23     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x28f74
   8fef0: e5940000     	ldr	r0, [r4]
   8fef4: e3a02000     	mov	r2, #0
   8fef8: e2401001     	sub	r1, r0, #1
   8fefc: e0010190     	mul	r1, r0, r1
   8ff00: e5990000     	ldr	r0, [r9]
   8ff04: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x90ee8 <.text+0x80de8>
   8ff08: e08f3003     	add	r3, pc, r3
   8ff0c: e3110001     	tst	r1, #1
   8ff10: e5c32000     	strb	r2, [r3]
   8ff14: 0a000ee7     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x3b9c
   8ff18: e350000a     	cmp	r0, #10
   8ff1c: ba000ee5     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x3b94
   8ff20: e59f0fc4     	ldr	r0, [pc, #0xfc4]        @ 0x90eec <.text+0x80dec>
   8ff24: e3a03001     	mov	r3, #1
   8ff28: e59f1fc0     	ldr	r1, [pc, #0xfc0]        @ 0x90ef0 <.text+0x80df0>
   8ff2c: e59f2fc0     	ldr	r2, [pc, #0xfc0]        @ 0x90ef4 <.text+0x80df4>
   8ff30: e08f0000     	add	r0, pc, r0
   8ff34: e08f1001     	add	r1, pc, r1
   8ff38: e88d0028     	stm	sp, {r3, r5}
   8ff3c: e08f2002     	add	r2, pc, r2
   8ff40: e30132d9     	movw	r3, #0x12d9
   8ff44: eb01a85e     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6a178
   8ff48: e59d00b8     	ldr	r0, [sp, #0xb8]
   8ff4c: e3001fa1     	movw	r1, #0xfa1
   8ff50: ebfee750     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x462c0
   8ff54: e59d00c0     	ldr	r0, [sp, #0xc0]
   8ff58: ebff5c08     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x28fe0
   8ff5c: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x90f44 <.text+0x80e44>
   8ff60: e3a00000     	mov	r0, #0
   8ff64: e08f1001     	add	r1, pc, r1
   8ff68: e5c10000     	strb	r0, [r1]
   8ff6c: eaffffd0     	b	0x8feb4 <.text+0x7fdb4> @ imm = #-0xc0
   8ff70: 00581a20     	subseq	r1, r8, r0, lsr #20
   8ff74: e5940000     	ldr	r0, [r4]
   8ff78: e5932008     	ldr	r2, [r3, #0x8]
   8ff7c: e2401001     	sub	r1, r0, #1
   8ff80: e0822007     	add	r2, r2, r7
   8ff84: e5832008     	str	r2, [r3, #0x8]
   8ff88: e0010190     	mul	r1, r0, r1
   8ff8c: e5990000     	ldr	r0, [r9]
   8ff90: e3110001     	tst	r1, #1
   8ff94: 0a000ec7     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x3b1c
   8ff98: e350000a     	cmp	r0, #10
   8ff9c: ba000ec5     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x3b14
   8ffa0: e5930008     	ldr	r0, [r3, #0x8]
   8ffa4: e0800007     	add	r0, r0, r7
   8ffa8: e5830008     	str	r0, [r3, #0x8]
   8ffac: eafffff0     	b	0x8ff74 <.text+0x7fe74> @ imm = #-0x40
   8ffb0: e3a01001     	mov	r1, #1
   8ffb4: eb00140e     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x5038
   8ffb8: ea000ebe     	b	0x93ab8 <.text+0x839b8> @ imm = #0x3af8
   8ffbc: 005819ec     	subseq	r1, r8, r12, ror #19
   8ffc0: 00557eeb     	subseq	r7, r5, r11, ror #29
   8ffc4: 00557e55     	subseq	r7, r5, r5, asr lr
   8ffc8: 00557e7b     	subseq	r7, r5, r11, ror lr
   8ffcc: 00558585     	subseq	r8, r5, r5, lsl #11
   8ffd0: 005819ac     	subseq	r1, r8, r12, lsr #19
   8ffd4: e59d00ac     	ldr	r0, [sp, #0xac]
   8ffd8: e2821008     	add	r1, r2, #8
   8ffdc: e3a02000     	mov	r2, #0
   8ffe0: e5903000     	ldr	r3, [r0]
   8ffe4: e1a00005     	mov	r0, r5
   8ffe8: eb003f24     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0xfc90
   8ffec: e5941000     	ldr	r1, [r4]
   8fff0: e2412001     	sub	r2, r1, #1
   8fff4: e0010291     	mul	r1, r1, r2
   8fff8: e3110001     	tst	r1, #1
   8fffc: 0a000028     	beq	0x900a4 <.text+0x7ffa4> @ imm = #0xa0
   90000: e5991000     	ldr	r1, [r9]
   90004: e59f2ff4     	ldr	r2, [pc, #0xff4]        @ 0x91000 <.text+0x80f00>
   90008: e351000a     	cmp	r1, #10
   9000c: e08f2002     	add	r2, pc, r2
   90010: ba000023     	blt	0x900a4 <.text+0x7ffa4> @ imm = #0x8c
   90014: e59d00ac     	ldr	r0, [sp, #0xac]
   90018: e2821008     	add	r1, r2, #8
   9001c: e3a02000     	mov	r2, #0
   90020: e5903000     	ldr	r3, [r0]
   90024: e1a00005     	mov	r0, r5
   90028: eb003f14     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0xfc50
   9002c: e59f2ffc     	ldr	r2, [pc, #0xffc]        @ 0x91030 <.text+0x80f30>
   90030: e08f2002     	add	r2, pc, r2
   90034: eaffffe6     	b	0x8ffd4 <.text+0x7fed4> @ imm = #-0x68
   90038: 00557e83     	subseq	r7, r5, r3, lsl #29
   9003c: 00557ded     	subseq	r7, r5, sp, ror #27
   90040: 00557e13     	subseq	r7, r5, r3, lsl lr
   90044: 0055851d     	subseq	r8, r5, sp, lsl r5
   90048: 00581944     	subseq	r1, r8, r4, asr #18
   9004c: 00581930     	subseq	r1, r8, r0, lsr r9
   90050: e2821008     	add	r1, r2, #8
   90054: e1a00005     	mov	r0, r5
   90058: eb003066     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xc198
   9005c: e5941000     	ldr	r1, [r4]
   90060: e2412001     	sub	r2, r1, #1
   90064: e0010291     	mul	r1, r1, r2
   90068: e3110001     	tst	r1, #1
   9006c: 0a00000c     	beq	0x900a4 <.text+0x7ffa4> @ imm = #0x30
   90070: e5991000     	ldr	r1, [r9]
   90074: e59f2fb8     	ldr	r2, [pc, #0xfb8]        @ 0x91034 <.text+0x80f34>
   90078: e3510009     	cmp	r1, #9
   9007c: e08f2002     	add	r2, pc, r2
   90080: da000007     	ble	0x900a4 <.text+0x7ffa4> @ imm = #0x1c
   90084: e2821008     	add	r1, r2, #8
   90088: e1a00005     	mov	r0, r5
   9008c: eb003059     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xc164
   90090: e59f2fa0     	ldr	r2, [pc, #0xfa0]        @ 0x91038 <.text+0x80f38>
   90094: e08f2002     	add	r2, pc, r2
   90098: eaffffec     	b	0x90050 <.text+0x7ff50> @ imm = #-0x50
   9009c: 005818e0     	subseq	r1, r8, r0, ror #17
   900a0: 005818b0     	ldrheq	r1, [r8], #-128
   900a4: e3500000     	cmp	r0, #0
   900a8: 0a00002b     	beq	0x9015c <.text+0x8005c> @ imm = #0xac
   900ac: e59d00c0     	ldr	r0, [sp, #0xc0]
   900b0: e3a01001     	mov	r1, #1
   900b4: e3a05001     	mov	r5, #1
   900b8: eb00149d     	bl	0x95334 <.text+0x85234> @ imm = #0x5274
   900bc: e3500000     	cmp	r0, #0
   900c0: 0a000030     	beq	0x90188 <.text+0x80088> @ imm = #0xc0
   900c4: e59f0f70     	ldr	r0, [pc, #0xf70]        @ 0x9103c <.text+0x80f3c>
   900c8: e59f1f70     	ldr	r1, [pc, #0xf70]        @ 0x91040 <.text+0x80f40>
   900cc: e59f2f70     	ldr	r2, [pc, #0xf70]        @ 0x91044 <.text+0x80f44>
   900d0: e08f0000     	add	r0, pc, r0
   900d4: e59f3f6c     	ldr	r3, [pc, #0xf6c]        @ 0x91048 <.text+0x80f48>
   900d8: e08f1001     	add	r1, pc, r1
   900dc: e08f2002     	add	r2, pc, r2
   900e0: e58d5000     	str	r5, [sp]
   900e4: e08f3003     	add	r3, pc, r3
   900e8: e58d3004     	str	r3, [sp, #0x4]
   900ec: e301334c     	movw	r3, #0x134c
   900f0: eb01a7f3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x69fcc
   900f4: e3001fa1     	movw	r1, #0xfa1
   900f8: e59d50c0     	ldr	r5, [sp, #0xc0]
   900fc: e59f8fdc     	ldr	r8, [pc, #0xfdc]        @ 0x910e0 <.text+0x80fe0>
   90100: e08f8008     	add	r8, pc, r8
   90104: e59d00b8     	ldr	r0, [sp, #0xb8]
   90108: ebfee6e2     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x46478
   9010c: e59f0ff4     	ldr	r0, [pc, #0xff4]        @ 0x91108 <.text+0x81008>
   90110: e3a07001     	mov	r7, #1
   90114: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0x9110c <.text+0x8100c>
   90118: e59f2ff0     	ldr	r2, [pc, #0xff0]        @ 0x91110 <.text+0x81010>
   9011c: e08f0000     	add	r0, pc, r0
   90120: e59f3fec     	ldr	r3, [pc, #0xfec]        @ 0x91114 <.text+0x81014>
   90124: e08f1001     	add	r1, pc, r1
   90128: e08f2002     	add	r2, pc, r2
   9012c: e58d7000     	str	r7, [sp]
   90130: e08f3003     	add	r3, pc, r3
   90134: e58d3004     	str	r3, [sp, #0x4]
   90138: e301339d     	movw	r3, #0x139d
   9013c: eb01a7e0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x69f80
   90140: e1a00005     	mov	r0, r5
   90144: ebff5b8d     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x291cc
   90148: e3a00000     	mov	r0, #0
   9014c: e5c80000     	strb	r0, [r8]
   90150: ea000e58     	b	0x93ab8 <.text+0x839b8> @ imm = #0x3960
   90154: 0058185c     	subseq	r1, r8, r12, asr r8
   90158: 00581824     	subseq	r1, r8, r4, lsr #16
   9015c: e59f6ff8     	ldr	r6, [pc, #0xff8]        @ 0x9115c <.text+0x8105c>
   90160: e08f6006     	add	r6, pc, r6
   90164: e1a00006     	mov	r0, r6
   90168: eb1457e6     	bl	0x5a6108 <.text+0x596008> @ imm = #0x515f98
   9016c: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0x91160 <.text+0x81060>
   90170: e08f0000     	add	r0, pc, r0
   90174: e5d05000     	ldrb	r5, [r0]
   90178: e1a00006     	mov	r0, r6
   9017c: eb145950     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x516540
   90180: e3550000     	cmp	r5, #0
   90184: 0a000040     	beq	0x9028c <.text+0x8018c> @ imm = #0x100
   90188: e59f6fd4     	ldr	r6, [pc, #0xfd4]        @ 0x91164 <.text+0x81064>
   9018c: e08f6006     	add	r6, pc, r6
   90190: e1a00006     	mov	r0, r6
   90194: eb1457db     	bl	0x5a6108 <.text+0x596008> @ imm = #0x515f6c
   90198: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x91168 <.text+0x81068>
   9019c: e08f0000     	add	r0, pc, r0
   901a0: e5d05000     	ldrb	r5, [r0]
   901a4: e1a00006     	mov	r0, r6
   901a8: eb145945     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x516514
   901ac: e59f2fb8     	ldr	r2, [pc, #0xfb8]        @ 0x9116c <.text+0x8106c>
   901b0: e3550000     	cmp	r5, #0
   901b4: e08f2002     	add	r2, pc, r2
   901b8: 1a000e3e     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x38f8
   901bc: e59d00c0     	ldr	r0, [sp, #0xc0]
   901c0: e5900018     	ldr	r0, [r0, #0x18]
   901c4: e5906008     	ldr	r6, [r0, #0x8]
   901c8: e3560000     	cmp	r6, #0
   901cc: 0a000049     	beq	0x902f8 <.text+0x801f8> @ imm = #0x124
   901d0: e59f1f98     	ldr	r1, [pc, #0xf98]        @ 0x91170 <.text+0x81070>
   901d4: e1a00006     	mov	r0, r6
   901d8: e08f1001     	add	r1, pc, r1
   901dc: eb144d5e     	bl	0x5a375c <.text+0x59365c> @ imm = #0x513578
   901e0: e3500000     	cmp	r0, #0
   901e4: 0a00000f     	beq	0x90228 <.text+0x80128> @ imm = #0x3c
   901e8: e59f1f84     	ldr	r1, [pc, #0xf84]        @ 0x91174 <.text+0x81074>
   901ec: e1a00006     	mov	r0, r6
   901f0: e08f1001     	add	r1, pc, r1
   901f4: eb144d58     	bl	0x5a375c <.text+0x59365c> @ imm = #0x513560
   901f8: e3500000     	cmp	r0, #0
   901fc: 0a000009     	beq	0x90228 <.text+0x80128> @ imm = #0x24
   90200: e59f1f70     	ldr	r1, [pc, #0xf70]        @ 0x91178 <.text+0x81078>
   90204: e1a00006     	mov	r0, r6
   90208: e08f1001     	add	r1, pc, r1
   9020c: eb144d52     	bl	0x5a375c <.text+0x59365c> @ imm = #0x513548
   90210: e3500000     	cmp	r0, #0
   90214: 0a000003     	beq	0x90228 <.text+0x80128> @ imm = #0xc
   90218: e59f2f5c     	ldr	r2, [pc, #0xf5c]        @ 0x9117c <.text+0x8107c>
   9021c: e08f2002     	add	r2, pc, r2
   90220: ea000034     	b	0x902f8 <.text+0x801f8> @ imm = #0xd0
   90224: 00581758     	subseq	r1, r8, r8, asr r7
   90228: ee890b0a     	vdiv.f64	d0, d9, d10
   9022c: e5940000     	ldr	r0, [r4]
   90230: e2401001     	sub	r1, r0, #1
   90234: e0000190     	mul	r0, r0, r1
   90238: e3100001     	tst	r0, #1
   9023c: ed9f1be3     	vldr	d1, [pc, #908]          @ 0x905d0 <.text+0x804d0>
   90240: ee200b01     	vmul.f64	d0, d0, d1
   90244: e5940000     	ldr	r0, [r4]
   90248: e2401001     	sub	r1, r0, #1
   9024c: e0000190     	mul	r0, r0, r1
   90250: e3100001     	tst	r0, #1
   90254: 0a000002     	beq	0x90264 <.text+0x80164> @ imm = #0x8
   90258: e5990000     	ldr	r0, [r9]
   9025c: e3500009     	cmp	r0, #9
   90260: cafffff7     	bgt	0x90244 <.text+0x80144> @ imm = #-0x24
   90264: ed9f1bdb     	vldr	d1, [pc, #876]          @ 0x905d8 <.text+0x804d8>
   90268: e59f2fe4     	ldr	r2, [pc, #0xfe4]        @ 0x91254 <.text+0x81154>
   9026c: eeb40bc1     	vcmpe.f64	d0, d1
   90270: e08f2002     	add	r2, pc, r2
   90274: eef1fa10     	vmrs	APSR_nzcv, fpscr
   90278: 5a000012     	bpl	0x902c8 <.text+0x801c8> @ imm = #0x48
   9027c: ed9f0bd7     	vldr	d0, [pc, #860]          @ 0x905e0 <.text+0x804e0>
   90280: e08aa08a     	add	r10, r10, r10, lsl #1
   90284: ee388b00     	vadd.f64	d8, d8, d0
   90288: ea00001a     	b	0x902f8 <.text+0x801f8> @ imm = #0x68
   9028c: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0x91258 <.text+0x81158>
   90290: e3020034     	movw	r0, #0x2034
   90294: e08f1001     	add	r1, pc, r1
   90298: e7910000     	ldr	r0, [r1, r0]
   9029c: e3500001     	cmp	r0, #1
   902a0: 0a000042     	beq	0x903b0 <.text+0x802b0> @ imm = #0x108
   902a4: e3500000     	cmp	r0, #0
   902a8: 1affffb6     	bne	0x90188 <.text+0x80088> @ imm = #-0x128
   902ac: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x91298 <.text+0x81198>
   902b0: e08f0000     	add	r0, pc, r0
   902b4: e2801008     	add	r1, r0, #8
   902b8: e59d00c0     	ldr	r0, [sp, #0xc0]
   902bc: eb0043a7     	bl	0xa1160 <.text+0x91060> @ imm = #0x10e9c
   902c0: eaffffb0     	b	0x90188 <.text+0x80088> @ imm = #-0x140
   902c4: 005816d0     	ldrsbeq	r1, [r8], #-96
   902c8: ed9f1bc6     	vldr	d1, [pc, #792]          @ 0x905e8 <.text+0x804e8>
   902cc: eeb40bc1     	vcmpe.f64	d0, d1
   902d0: eef1fa10     	vmrs	APSR_nzcv, fpscr
   902d4: 5a000007     	bpl	0x902f8 <.text+0x801f8> @ imm = #0x1c
   902d8: ee00aa10     	vmov	s0, r10
   902dc: ed9f1bc3     	vldr	d1, [pc, #780]          @ 0x905f0 <.text+0x804f0>
   902e0: eeb80bc0     	vcvt.f64.s32	d0, s0
   902e4: ee200b01     	vmul.f64	d0, d0, d1
   902e8: eebd0bc0     	vcvt.s32.f64	s0, d0
   902ec: ee10aa10     	vmov	r10, s0
   902f0: ed9f1bc0     	vldr	d1, [pc, #768]          @ 0x905f8 <.text+0x804f8>
   902f4: ee388b01     	vadd.f64	d8, d8, d1
   902f8: e5940000     	ldr	r0, [r4]
   902fc: e2401001     	sub	r1, r0, #1
   90300: e0000190     	mul	r0, r0, r1
   90304: e3100001     	tst	r0, #1
   90308: e5940000     	ldr	r0, [r4]
   9030c: e2401001     	sub	r1, r0, #1
   90310: e0010190     	mul	r1, r0, r1
   90314: e3020034     	movw	r0, #0x2034
   90318: e7920000     	ldr	r0, [r2, r0]
   9031c: e3110001     	tst	r1, #1
   90320: 0a000002     	beq	0x90330 <.text+0x80230> @ imm = #0x8
   90324: e5991000     	ldr	r1, [r9]
   90328: e3510009     	cmp	r1, #9
   9032c: cafffff5     	bgt	0x90308 <.text+0x80208> @ imm = #-0x2c
   90330: e59f8f64     	ldr	r8, [pc, #0xf64]        @ 0x9129c <.text+0x8119c>
   90334: e3500000     	cmp	r0, #0
   90338: e08f8008     	add	r8, pc, r8
   9033c: 0a000008     	beq	0x90364 <.text+0x80264> @ imm = #0x20
   90340: e3500001     	cmp	r0, #1
   90344: 1a00000f     	bne	0x90388 <.text+0x80288> @ imm = #0x3c
   90348: e3020030     	movw	r0, #0x2030
   9034c: eeb00b48     	vmov.f64	d0, d8
   90350: e7921000     	ldr	r1, [r2, r0]
   90354: e2820008     	add	r0, r2, #8
   90358: eb00381a     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xe068
   9035c: ea000019     	b	0x903c8 <.text+0x802c8> @ imm = #0x64
   90360: 00581648     	subseq	r1, r8, r8, asr #12
   90364: e5940000     	ldr	r0, [r4]
   90368: e2401001     	sub	r1, r0, #1
   9036c: e0000190     	mul	r0, r0, r1
   90370: e3100001     	tst	r0, #1
   90374: 0a000081     	beq	0x90580 <.text+0x80480> @ imm = #0x204
   90378: e5990000     	ldr	r0, [r9]
   9037c: e3500009     	cmp	r0, #9
   90380: ca00008b     	bgt	0x905b4 <.text+0x804b4> @ imm = #0x22c
   90384: ea00007d     	b	0x90580 <.text+0x80480> @ imm = #0x1f4
   90388: e5940000     	ldr	r0, [r4]
   9038c: e2401001     	sub	r1, r0, #1
   90390: e0000190     	mul	r0, r0, r1
   90394: e3100001     	tst	r0, #1
   90398: 0a000099     	beq	0x90604 <.text+0x80504> @ imm = #0x264
   9039c: e5990000     	ldr	r0, [r9]
   903a0: e3500009     	cmp	r0, #9
   903a4: ca0000ab     	bgt	0x90658 <.text+0x80558> @ imm = #0x2ac
   903a8: ea000095     	b	0x90604 <.text+0x80504> @ imm = #0x254
   903ac: 00581618     	subseq	r1, r8, r8, lsl r6
   903b0: e3020030     	movw	r0, #0x2030
   903b4: e7912000     	ldr	r2, [r1, r0]
   903b8: e2811008     	add	r1, r1, #8
   903bc: e59d00c0     	ldr	r0, [sp, #0xc0]
   903c0: eb003684     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xda10
   903c4: eaffff6f     	b	0x90188 <.text+0x80088> @ imm = #-0x244
   903c8: e3500000     	cmp	r0, #0
   903cc: 0a0000b4     	beq	0x906a4 <.text+0x805a4> @ imm = #0x2d0
   903d0: e59d0068     	ldr	r0, [sp, #0x68]
   903d4: e5905000     	ldr	r5, [r0]
   903d8: eb01b6f7     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x6dbdc
   903dc: e3500006     	cmp	r0, #6
   903e0: 1a000020     	bne	0x90468 <.text+0x80368> @ imm = #0x80
   903e4: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x913b8 <.text+0x812b8>
   903e8: e3020034     	movw	r0, #0x2034
   903ec: e08f1001     	add	r1, pc, r1
   903f0: e7910000     	ldr	r0, [r1, r0]
   903f4: e3500001     	cmp	r0, #1
   903f8: 0a00001a     	beq	0x90468 <.text+0x80368> @ imm = #0x68
   903fc: e5940000     	ldr	r0, [r4]
   90400: e2401001     	sub	r1, r0, #1
   90404: e0000190     	mul	r0, r0, r1
   90408: e3100001     	tst	r0, #1
   9040c: 0a000002     	beq	0x9041c <.text+0x8031c> @ imm = #0x8
   90410: e5990000     	ldr	r0, [r9]
   90414: e3500009     	cmp	r0, #9
   90418: ca000009     	bgt	0x90444 <.text+0x80344> @ imm = #0x24
   9041c: e59d00c0     	ldr	r0, [sp, #0xc0]
   90420: ebff48d6     	bl	0x62780 <.text+0x52680> @ imm = #-0x2dca8
   90424: e5941000     	ldr	r1, [r4]
   90428: e2412001     	sub	r2, r1, #1
   9042c: e0010291     	mul	r1, r1, r2
   90430: e3110001     	tst	r1, #1
   90434: 0a000009     	beq	0x90460 <.text+0x80360> @ imm = #0x24
   90438: e5991000     	ldr	r1, [r9]
   9043c: e3510009     	cmp	r1, #9
   90440: da000006     	ble	0x90460 <.text+0x80360> @ imm = #0x18
   90444: e59d00c0     	ldr	r0, [sp, #0xc0]
   90448: ebff48cc     	bl	0x62780 <.text+0x52680> @ imm = #-0x2dcd0
   9044c: eafffff2     	b	0x9041c <.text+0x8031c> @ imm = #-0x38
   90450: 00557a53     	subseq	r7, r5, r3, asr r10
   90454: 005579bd     	ldrheq	r7, [r5], #-157
   90458: 005579e3     	subseq	r7, r5, r3, ror #19
   9045c: 00557fd8     	ldrsbeq	r7, [r5], #-248
   90460: e1500005     	cmp	r0, r5
   90464: aa00008e     	bge	0x906a4 <.text+0x805a4> @ imm = #0x238
   90468: e59f0f90     	ldr	r0, [pc, #0xf90]        @ 0x91400 <.text+0x81300>
   9046c: e08f0000     	add	r0, pc, r0
   90470: e5905008     	ldr	r5, [r0, #0x8]
   90474: eb01c97f     	bl	0x102a78 <.text+0xf2978> @ imm = #0x725fc
   90478: e1550000     	cmp	r5, r0
   9047c: e59d50c0     	ldr	r5, [sp, #0xc0]
   90480: e59da05c     	ldr	r10, [sp, #0x5c]
   90484: ba000012     	blt	0x904d4 <.text+0x803d4> @ imm = #0x48
   90488: e1a00005     	mov	r0, r5
   9048c: e3a01001     	mov	r1, #1
   90490: eb0013a7     	bl	0x95334 <.text+0x85234> @ imm = #0x4e9c
   90494: e3500000     	cmp	r0, #0
   90498: 0a00000d     	beq	0x904d4 <.text+0x803d4> @ imm = #0x34
   9049c: e5940000     	ldr	r0, [r4]
   904a0: e2401001     	sub	r1, r0, #1
   904a4: e0000190     	mul	r0, r0, r1
   904a8: e3100001     	tst	r0, #1
   904ac: 0a0000e6     	beq	0x9084c <.text+0x8074c> @ imm = #0x398
   904b0: e5990000     	ldr	r0, [r9]
   904b4: e3500009     	cmp	r0, #9
   904b8: ca0000f9     	bgt	0x908a4 <.text+0x807a4> @ imm = #0x3e4
   904bc: ea0000e2     	b	0x9084c <.text+0x8074c> @ imm = #0x388
   904c0: 0058353c     	subseq	r3, r8, r12, lsr r5
   904c4: 005579db     	ldrsbeq	r7, [r5], #-155
   904c8: 00557945     	subseq	r7, r5, r5, asr #18
   904cc: 0055796b     	subseq	r7, r5, r11, ror #18
   904d0: 00557f60     	subseq	r7, r5, r0, ror #30
   904d4: e595001c     	ldr	r0, [r5, #0x1c]
   904d8: e1a08005     	mov	r8, r5
   904dc: e59f6fc4     	ldr	r6, [pc, #0xfc4]        @ 0x914a8 <.text+0x813a8>
   904e0: e08f6006     	add	r6, pc, r6
   904e4: e5965008     	ldr	r5, [r6, #0x8]
   904e8: ebff4218     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x2f7a0
   904ec: e1550000     	cmp	r5, r0
   904f0: da00000b     	ble	0x90524 <.text+0x80424> @ imm = #0x2c
   904f4: e59d7058     	ldr	r7, [sp, #0x58]
   904f8: e598001c     	ldr	r0, [r8, #0x1c]
   904fc: e5962008     	ldr	r2, [r6, #0x8]
   90500: e5971000     	ldr	r1, [r7]
   90504: e0815002     	add	r5, r1, r2
   90508: ebff420e     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2f7c8
   9050c: e1550000     	cmp	r5, r0
   90510: aa00000a     	bge	0x90540 <.text+0x80440> @ imm = #0x28
   90514: e5970000     	ldr	r0, [r7]
   90518: e5961008     	ldr	r1, [r6, #0x8]
   9051c: e0800001     	add	r0, r0, r1
   90520: ea000008     	b	0x90548 <.text+0x80448> @ imm = #0x20
   90524: e5967004     	ldr	r7, [r6, #0x4]
   90528: e1a05008     	mov	r5, r8
   9052c: e59f8f78     	ldr	r8, [pc, #0xf78]        @ 0x914ac <.text+0x813ac>
   90530: e08f8008     	add	r8, pc, r8
   90534: ea0000ff     	b	0x90938 <.text+0x80838> @ imm = #0x3fc
   90538: 005834d4     	ldrsbeq	r3, [r8], #-68
   9053c: 005834c4     	subseq	r3, r8, r4, asr #9
   90540: e598001c     	ldr	r0, [r8, #0x1c]
   90544: ebff41ff     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2f804
   90548: e5941000     	ldr	r1, [r4]
   9054c: e1a05008     	mov	r5, r8
   90550: e59f8f58     	ldr	r8, [pc, #0xf58]        @ 0x914b0 <.text+0x813b0>
   90554: e2412001     	sub	r2, r1, #1
   90558: e08f8008     	add	r8, pc, r8
   9055c: e0010291     	mul	r1, r1, r2
   90560: e3110001     	tst	r1, #1
   90564: 0a0000dd     	beq	0x908e0 <.text+0x807e0> @ imm = #0x374
   90568: e5991000     	ldr	r1, [r9]
   9056c: e3510009     	cmp	r1, #9
   90570: ca0000e7     	bgt	0x90914 <.text+0x80814> @ imm = #0x39c
   90574: ea0000d9     	b	0x908e0 <.text+0x807e0> @ imm = #0x364
   90578: 00583488     	subseq	r3, r8, r8, lsl #9
   9057c: 00581410     	subseq	r1, r8, r0, lsl r4
   90580: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x91580 <.text+0x81480>
   90584: eeb00b48     	vmov.f64	d0, d8
   90588: e08f0000     	add	r0, pc, r0
   9058c: e2800008     	add	r0, r0, #8
   90590: eb0043f4     	bl	0xa1568 <.text+0x91468> @ imm = #0x10fd0
   90594: e5941000     	ldr	r1, [r4]
   90598: e2412001     	sub	r2, r1, #1
   9059c: e0010291     	mul	r1, r1, r2
   905a0: e3110001     	tst	r1, #1
   905a4: 0affff87     	beq	0x903c8 <.text+0x802c8> @ imm = #-0x1e4
   905a8: e5991000     	ldr	r1, [r9]
   905ac: e3510009     	cmp	r1, #9
   905b0: daffff84     	ble	0x903c8 <.text+0x802c8> @ imm = #-0x1f0
   905b4: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x91584 <.text+0x81484>
   905b8: eeb00b48     	vmov.f64	d0, d8
   905bc: e08f0000     	add	r0, pc, r0
   905c0: e2800008     	add	r0, r0, #8
   905c4: eb0043e7     	bl	0xa1568 <.text+0x91468> @ imm = #0x10f9c
   905c8: eaffffec     	b	0x90580 <.text+0x80480> @ imm = #-0x50
   905cc: e320f000     	nop
   905d0: 00000000     	andeq	r0, r0, r0
   905d4: 40590000     	subsmi	r0, r9, r0
   905d8: 00000000     	andeq	r0, r0, r0
   905dc: 4052c000     	subsmi	r12, r2, r0
   905e0: 00000000     	andeq	r0, r0, r0
   905e4: bff80000     	svclt	#0xf80000
   905e8: 00000000     	andeq	r0, r0, r0
   905ec: 40554000     	subsmi	r4, r5, r0
   905f0: 00000000     	andeq	r0, r0, r0
   905f4: 40040000     	andmi	r0, r4, r0
   905f8: 00000000     	andeq	r0, r0, r0
   905fc: bff00000     	svclt	#0xf00000
   90600: 0058139c     	<unknown>
   90604: e59f0fe0     	ldr	r0, [pc, #0xfe0]        @ 0x915ec <.text+0x814ec>
   90608: e3a06002     	mov	r6, #2
   9060c: e59f1fdc     	ldr	r1, [pc, #0xfdc]        @ 0x915f0 <.text+0x814f0>
   90610: e59f2fdc     	ldr	r2, [pc, #0xfdc]        @ 0x915f4 <.text+0x814f4>
   90614: e08f0000     	add	r0, pc, r0
   90618: e59f3fd8     	ldr	r3, [pc, #0xfd8]        @ 0x915f8 <.text+0x814f8>
   9061c: e08f1001     	add	r1, pc, r1
   90620: e08f2002     	add	r2, pc, r2
   90624: e58d6000     	str	r6, [sp]
   90628: e08f3003     	add	r3, pc, r3
   9062c: e58d3004     	str	r3, [sp, #0x4]
   90630: e3a03e75     	mov	r3, #1872
   90634: eb01a6a2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x69a88
   90638: e5940000     	ldr	r0, [r4]
   9063c: e2401001     	sub	r1, r0, #1
   90640: e0000190     	mul	r0, r0, r1
   90644: e3100001     	tst	r0, #1
   90648: 0a000015     	beq	0x906a4 <.text+0x805a4> @ imm = #0x54
   9064c: e5990000     	ldr	r0, [r9]
   90650: e350000a     	cmp	r0, #10
   90654: ba000012     	blt	0x906a4 <.text+0x805a4> @ imm = #0x48
   90658: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x91644 <.text+0x81544>
   9065c: e3a06002     	mov	r6, #2
   90660: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0x91648 <.text+0x81548>
   90664: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x9164c <.text+0x8154c>
   90668: e08f0000     	add	r0, pc, r0
   9066c: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x91650 <.text+0x81550>
   90670: e08f1001     	add	r1, pc, r1
   90674: e08f2002     	add	r2, pc, r2
   90678: e58d6000     	str	r6, [sp]
   9067c: e08f3003     	add	r3, pc, r3
   90680: e58d3004     	str	r3, [sp, #0x4]
   90684: e3a03e75     	mov	r3, #1872
   90688: eb01a68d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x69a34
   9068c: eaffffdc     	b	0x90604 <.text+0x80504> @ imm = #-0x90
   90690: 0055781b     	subseq	r7, r5, r11, lsl r8
   90694: 00557785     	subseq	r7, r5, r5, lsl #15
   90698: 005577ab     	subseq	r7, r5, r11, lsr #15
   9069c: 00557eb5     	ldrheq	r7, [r5], #-229
   906a0: 005577c7     	subseq	r7, r5, r7, asr #15
   906a4: e59f0fd0     	ldr	r0, [pc, #0xfd0]        @ 0x9167c <.text+0x8157c>
   906a8: e08f0000     	add	r0, pc, r0
   906ac: e5905008     	ldr	r5, [r0, #0x8]
   906b0: eb01c8f0     	bl	0x102a78 <.text+0xf2978> @ imm = #0x723c0
   906b4: e1550000     	cmp	r5, r0
   906b8: ba000019     	blt	0x90724 <.text+0x80624> @ imm = #0x64
   906bc: e59d00c0     	ldr	r0, [sp, #0xc0]
   906c0: e3a01001     	mov	r1, #1
   906c4: e3a05001     	mov	r5, #1
   906c8: eb001319     	bl	0x95334 <.text+0x85234> @ imm = #0x4c64
   906cc: e3500000     	cmp	r0, #0
   906d0: 0a000013     	beq	0x90724 <.text+0x80624> @ imm = #0x4c
   906d4: e59f0fa4     	ldr	r0, [pc, #0xfa4]        @ 0x91680 <.text+0x81580>
   906d8: e59f1fa4     	ldr	r1, [pc, #0xfa4]        @ 0x91684 <.text+0x81584>
   906dc: e59f2fa4     	ldr	r2, [pc, #0xfa4]        @ 0x91688 <.text+0x81588>
   906e0: e08f0000     	add	r0, pc, r0
   906e4: e59f3ffc     	ldr	r3, [pc, #0xffc]        @ 0x916e8 <.text+0x815e8>
   906e8: e08f1001     	add	r1, pc, r1
   906ec: e08f2002     	add	r2, pc, r2
   906f0: e58d5000     	str	r5, [sp]
   906f4: e08f3003     	add	r3, pc, r3
   906f8: e58d3004     	str	r3, [sp, #0x4]
   906fc: e301337a     	movw	r3, #0x137a
   90700: eb01a66f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x699bc
   90704: e3001fa1     	movw	r1, #0xfa1
   90708: e59d50c0     	ldr	r5, [sp, #0xc0]
   9070c: eafffe7c     	b	0x90104 <.text+0x80004> @ imm = #-0x610
   90710: 00557731     	subseq	r7, r5, r1, lsr r7
   90714: 00557757     	subseq	r7, r5, r7, asr r7
   90718: 00557e61     	subseq	r7, r5, r1, ror #28
   9071c: 00581278     	subseq	r1, r8, r8, ror r2
   90720: 00581220     	subseq	r1, r8, r0, lsr #4
   90724: e59f0fc0     	ldr	r0, [pc, #0xfc0]        @ 0x916ec <.text+0x815ec>
   90728: e3a03000     	mov	r3, #0
   9072c: e59d60c0     	ldr	r6, [sp, #0xc0]
   90730: e08f0000     	add	r0, pc, r0
   90734: e59d20a0     	ldr	r2, [sp, #0xa0]
   90738: e5901004     	ldr	r1, [r0, #0x4]
   9073c: e1a05000     	mov	r5, r0
   90740: e3a00001     	mov	r0, #1
   90744: e58d0000     	str	r0, [sp]
   90748: e1a00006     	mov	r0, r6
   9074c: eb0014f5     	bl	0x95b28 <.text+0x85a28> @ imm = #0x53d4
   90750: e596001c     	ldr	r0, [r6, #0x1c]
   90754: e5951008     	ldr	r1, [r5, #0x8]
   90758: e081500a     	add	r5, r1, r10
   9075c: ebff4179     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2fa1c
   90760: e1550000     	cmp	r5, r0
   90764: aa000012     	bge	0x907b4 <.text+0x806b4> @ imm = #0x48
   90768: e5940000     	ldr	r0, [r4]
   9076c: e59f2fd8     	ldr	r2, [pc, #0xfd8]        @ 0x9174c <.text+0x8164c>
   90770: e2401001     	sub	r1, r0, #1
   90774: e08f2002     	add	r2, pc, r2
   90778: e0000190     	mul	r0, r0, r1
   9077c: e3100001     	tst	r0, #1
   90780: e5940000     	ldr	r0, [r4]
   90784: e2401001     	sub	r1, r0, #1
   90788: e0010190     	mul	r1, r0, r1
   9078c: e5920008     	ldr	r0, [r2, #0x8]
   90790: e080000a     	add	r0, r0, r10
   90794: e3110001     	tst	r1, #1
   90798: 0a000009     	beq	0x907c4 <.text+0x806c4> @ imm = #0x24
   9079c: e5991000     	ldr	r1, [r9]
   907a0: e351000a     	cmp	r1, #10
   907a4: aafffff5     	bge	0x90780 <.text+0x80680> @ imm = #-0x2c
   907a8: ea000005     	b	0x907c4 <.text+0x806c4> @ imm = #0x14
   907ac: 005811e8     	subseq	r1, r8, r8, ror #3
   907b0: 0058119c     	<unknown>
   907b4: e596001c     	ldr	r0, [r6, #0x1c]
   907b8: ebff4162     	bl	0x60d48 <.text+0x50c48> @ imm = #-0x2fa78
   907bc: e59f2fd8     	ldr	r2, [pc, #0xfd8]        @ 0x9179c <.text+0x8169c>
   907c0: e08f2002     	add	r2, pc, r2
   907c4: e5921004     	ldr	r1, [r2, #0x4]
   907c8: e5911014     	ldr	r1, [r1, #0x14]
   907cc: e1500001     	cmp	r0, r1
   907d0: b1a01000     	movlt	r1, r0
   907d4: e59d00bc     	ldr	r0, [sp, #0xbc]
   907d8: e5821008     	str	r1, [r2, #0x8]
   907dc: ebfeff69     	bl	0x50588 <.text+0x40488> @ imm = #-0x4025c
   907e0: e59f1fb8     	ldr	r1, [pc, #0xfb8]        @ 0x917a0 <.text+0x816a0>
   907e4: e08f1001     	add	r1, pc, r1
   907e8: e5810008     	str	r0, [r1, #0x8]
   907ec: e1a00006     	mov	r0, r6
   907f0: eb0013de     	bl	0x95770 <.text+0x85670> @ imm = #0x4f78
   907f4: e59f0fa8     	ldr	r0, [pc, #0xfa8]        @ 0x917a4 <.text+0x816a4>
   907f8: e08f0000     	add	r0, pc, r0
   907fc: e5901008     	ldr	r1, [r0, #0x8]
   90800: e1a00006     	mov	r0, r6
   90804: eb001114     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x4450
   90808: e3500000     	cmp	r0, #0
   9080c: 0a000ca9     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x32a4
   90810: e59f0f90     	ldr	r0, [pc, #0xf90]        @ 0x917a8 <.text+0x816a8>
   90814: e3a07001     	mov	r7, #1
   90818: e59f1f8c     	ldr	r1, [pc, #0xf8c]        @ 0x917ac <.text+0x816ac>
   9081c: e59f2f8c     	ldr	r2, [pc, #0xf8c]        @ 0x917b0 <.text+0x816b0>
   90820: e08f0000     	add	r0, pc, r0
   90824: e59f3f88     	ldr	r3, [pc, #0xf88]        @ 0x917b4 <.text+0x816b4>
   90828: e08f1001     	add	r1, pc, r1
   9082c: e08f2002     	add	r2, pc, r2
   90830: e58d7000     	str	r7, [sp]
   90834: e08f3003     	add	r3, pc, r3
   90838: e58d3004     	str	r3, [sp, #0x4]
   9083c: e3013388     	movw	r3, #0x1388
   90840: eb01a61f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6987c
   90844: e30017da     	movw	r1, #0x7da
   90848: eafffe2a     	b	0x900f8 <.text+0x7fff8> @ imm = #-0x758
   9084c: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x9184c <.text+0x8174c>
   90850: e3a07001     	mov	r7, #1
   90854: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0x91850 <.text+0x81750>
   90858: e59f2ff4     	ldr	r2, [pc, #0xff4]        @ 0x91854 <.text+0x81754>
   9085c: e08f0000     	add	r0, pc, r0
   90860: e59f3ff0     	ldr	r3, [pc, #0xff0]        @ 0x91858 <.text+0x81758>
   90864: e08f1001     	add	r1, pc, r1
   90868: e08f2002     	add	r2, pc, r2
   9086c: e58d7000     	str	r7, [sp]
   90870: e08f3003     	add	r3, pc, r3
   90874: e58d3004     	str	r3, [sp, #0x4]
   90878: e3013363     	movw	r3, #0x1363
   9087c: eb01a610     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x69840
   90880: e5940000     	ldr	r0, [r4]
   90884: e2401001     	sub	r1, r0, #1
   90888: e0000190     	mul	r0, r0, r1
   9088c: e3001fa1     	movw	r1, #0xfa1
   90890: e3100001     	tst	r0, #1
   90894: 0afffe1a     	beq	0x90104 <.text+0x80004> @ imm = #-0x798
   90898: e5990000     	ldr	r0, [r9]
   9089c: e350000a     	cmp	r0, #10
   908a0: bafffe17     	blt	0x90104 <.text+0x80004> @ imm = #-0x7a4
   908a4: e59f0fb0     	ldr	r0, [pc, #0xfb0]        @ 0x9185c <.text+0x8175c>
   908a8: e3a07001     	mov	r7, #1
   908ac: e59f1fac     	ldr	r1, [pc, #0xfac]        @ 0x91860 <.text+0x81760>
   908b0: e59f2fac     	ldr	r2, [pc, #0xfac]        @ 0x91864 <.text+0x81764>
   908b4: e08f0000     	add	r0, pc, r0
   908b8: e59f3fa8     	ldr	r3, [pc, #0xfa8]        @ 0x91868 <.text+0x81768>
   908bc: e08f1001     	add	r1, pc, r1
   908c0: e08f2002     	add	r2, pc, r2
   908c4: e58d7000     	str	r7, [sp]
   908c8: e08f3003     	add	r3, pc, r3
   908cc: e58d3004     	str	r3, [sp, #0x4]
   908d0: e3013363     	movw	r3, #0x1363
   908d4: eb01a5fa     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x697e8
   908d8: eaffffdb     	b	0x9084c <.text+0x8074c> @ imm = #-0x94
   908dc: 005810a4     	subseq	r1, r8, r4, lsr #1
   908e0: e5941000     	ldr	r1, [r4]
   908e4: e5967004     	ldr	r7, [r6, #0x4]
   908e8: e2412001     	sub	r2, r1, #1
   908ec: e0020291     	mul	r2, r1, r2
   908f0: e5973014     	ldr	r3, [r7, #0x14]
   908f4: e5991000     	ldr	r1, [r9]
   908f8: e1500003     	cmp	r0, r3
   908fc: b1a03000     	movlt	r3, r0
   90900: e5863008     	str	r3, [r6, #0x8]
   90904: e3120001     	tst	r2, #1
   90908: 0a00000a     	beq	0x90938 <.text+0x80838> @ imm = #0x28
   9090c: e3510009     	cmp	r1, #9
   90910: da000008     	ble	0x90938 <.text+0x80838> @ imm = #0x20
   90914: e5961004     	ldr	r1, [r6, #0x4]
   90918: e5911014     	ldr	r1, [r1, #0x14]
   9091c: e1500001     	cmp	r0, r1
   90920: b1a01000     	movlt	r1, r0
   90924: e5861008     	str	r1, [r6, #0x8]
   90928: eaffffec     	b	0x908e0 <.text+0x807e0> @ imm = #-0x50
   9092c: 00581044     	subseq	r1, r8, r4, asr #32
   90930: 00581000     	subseq	r1, r8, r0
   90934: 00580fbc     	ldrheq	r0, [r8], #-252
   90938: e5940000     	ldr	r0, [r4]
   9093c: e2401001     	sub	r1, r0, #1
   90940: e0000190     	mul	r0, r0, r1
   90944: e3100001     	tst	r0, #1
   90948: 0a000002     	beq	0x90958 <.text+0x80858> @ imm = #0x8
   9094c: e5990000     	ldr	r0, [r9]
   90950: e3500009     	cmp	r0, #9
   90954: ca000019     	bgt	0x909c0 <.text+0x808c0> @ imm = #0x64
   90958: ed9a0b00     	vldr	d0, [r10]
   9095c: e2861008     	add	r1, r6, #8
   90960: e1a00005     	mov	r0, r5
   90964: e1a02007     	mov	r2, r7
   90968: ebffe1ea     	bl	0x89118 <.text+0x79018> @ imm = #-0x7858
   9096c: e59f0fd0     	ldr	r0, [pc, #0xfd0]        @ 0x91944 <.text+0x81844>
   90970: e08f0000     	add	r0, pc, r0
   90974: e5901008     	ldr	r1, [r0, #0x8]
   90978: e59d00bc     	ldr	r0, [sp, #0xbc]
   9097c: ebfeff01     	bl	0x50588 <.text+0x40488> @ imm = #-0x403fc
   90980: e1a01000     	mov	r1, r0
   90984: e59f0fbc     	ldr	r0, [pc, #0xfbc]        @ 0x91948 <.text+0x81848>
   90988: e08f0000     	add	r0, pc, r0
   9098c: e5801008     	str	r1, [r0, #0x8]
   90990: e1a00005     	mov	r0, r5
   90994: eb0010b0     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x42c0
   90998: e59f6fac     	ldr	r6, [pc, #0xfac]        @ 0x9194c <.text+0x8184c>
   9099c: e5941000     	ldr	r1, [r4]
   909a0: e08f6006     	add	r6, pc, r6
   909a4: e2412001     	sub	r2, r1, #1
   909a8: e0010291     	mul	r1, r1, r2
   909ac: e3110001     	tst	r1, #1
   909b0: 0a000015     	beq	0x90a0c <.text+0x8090c> @ imm = #0x54
   909b4: e5991000     	ldr	r1, [r9]
   909b8: e3510009     	cmp	r1, #9
   909bc: da000012     	ble	0x90a0c <.text+0x8090c> @ imm = #0x48
   909c0: ed9a0b00     	vldr	d0, [r10]
   909c4: e2861008     	add	r1, r6, #8
   909c8: e1a00005     	mov	r0, r5
   909cc: e1a02007     	mov	r2, r7
   909d0: ebffe1d0     	bl	0x89118 <.text+0x79018> @ imm = #-0x78c0
   909d4: e59f0f74     	ldr	r0, [pc, #0xf74]        @ 0x91950 <.text+0x81850>
   909d8: e08f0000     	add	r0, pc, r0
   909dc: e5901008     	ldr	r1, [r0, #0x8]
   909e0: e59d00bc     	ldr	r0, [sp, #0xbc]
   909e4: ebfefee7     	bl	0x50588 <.text+0x40488> @ imm = #-0x40464
   909e8: e1a01000     	mov	r1, r0
   909ec: e59f0f60     	ldr	r0, [pc, #0xf60]        @ 0x91954 <.text+0x81854>
   909f0: e08f0000     	add	r0, pc, r0
   909f4: e5801008     	str	r1, [r0, #0x8]
   909f8: e1a00005     	mov	r0, r5
   909fc: eb001096     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x4258
   90a00: e59f6f50     	ldr	r6, [pc, #0xf50]        @ 0x91958 <.text+0x81858>
   90a04: e08f6006     	add	r6, pc, r6
   90a08: eaffffd2     	b	0x90958 <.text+0x80858> @ imm = #-0xb8
   90a0c: e3500000     	cmp	r0, #0
   90a10: 0a000008     	beq	0x90a38 <.text+0x80938> @ imm = #0x20
   90a14: e5940000     	ldr	r0, [r4]
   90a18: e2401001     	sub	r1, r0, #1
   90a1c: e0000190     	mul	r0, r0, r1
   90a20: e3100001     	tst	r0, #1
   90a24: 0a00000b     	beq	0x90a58 <.text+0x80958> @ imm = #0x2c
   90a28: e5990000     	ldr	r0, [r9]
   90a2c: e3500009     	cmp	r0, #9
   90a30: ca00001e     	bgt	0x90ab0 <.text+0x809b0> @ imm = #0x78
   90a34: ea000007     	b	0x90a58 <.text+0x80958> @ imm = #0x1c
   90a38: e3a00004     	mov	r0, #4
   90a3c: eafffd5b     	b	0x8ffb0 <.text+0x7feb0> @ imm = #-0xa94
   90a40: 00580f40     	subseq	r0, r8, r0, asr #30
   90a44: 0055743f     	subseq	r7, r5, pc, lsr r4
   90a48: 005573a9     	subseq	r7, r5, r9, lsr #7
   90a4c: 005573cf     	subseq	r7, r5, pc, asr #7
   90a50: 00557ad9     	ldrsbeq	r7, [r5], #-169
   90a54: 00580f00     	subseq	r0, r8, r0, lsl #30
   90a58: e59f0fd0     	ldr	r0, [pc, #0xfd0]        @ 0x91a30 <.text+0x81930>
   90a5c: e3a07001     	mov	r7, #1
   90a60: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x91a34 <.text+0x81934>
   90a64: e59f2fcc     	ldr	r2, [pc, #0xfcc]        @ 0x91a38 <.text+0x81938>
   90a68: e08f0000     	add	r0, pc, r0
   90a6c: e59f3fc8     	ldr	r3, [pc, #0xfc8]        @ 0x91a3c <.text+0x8193c>
   90a70: e08f1001     	add	r1, pc, r1
   90a74: e08f2002     	add	r2, pc, r2
   90a78: e58d7000     	str	r7, [sp]
   90a7c: e08f3003     	add	r3, pc, r3
   90a80: e58d3004     	str	r3, [sp, #0x4]
   90a84: e3013372     	movw	r3, #0x1372
   90a88: eb01a58d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x69634
   90a8c: e5940000     	ldr	r0, [r4]
   90a90: e2401001     	sub	r1, r0, #1
   90a94: e0000190     	mul	r0, r0, r1
   90a98: e30017da     	movw	r1, #0x7da
   90a9c: e3100001     	tst	r0, #1
   90aa0: 0afffd97     	beq	0x90104 <.text+0x80004> @ imm = #-0x9a4
   90aa4: e5990000     	ldr	r0, [r9]
   90aa8: e350000a     	cmp	r0, #10
   90aac: bafffd94     	blt	0x90104 <.text+0x80004> @ imm = #-0x9b0
   90ab0: e59f0fe8     	ldr	r0, [pc, #0xfe8]        @ 0x91aa0 <.text+0x819a0>
   90ab4: e3a07001     	mov	r7, #1
   90ab8: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0x91aa4 <.text+0x819a4>
   90abc: e59f2fe4     	ldr	r2, [pc, #0xfe4]        @ 0x91aa8 <.text+0x819a8>
   90ac0: e08f0000     	add	r0, pc, r0
   90ac4: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0x91aac <.text+0x819ac>
   90ac8: e08f1001     	add	r1, pc, r1
   90acc: e08f2002     	add	r2, pc, r2
   90ad0: e58d7000     	str	r7, [sp]
   90ad4: e08f3003     	add	r3, pc, r3
   90ad8: e58d3004     	str	r3, [sp, #0x4]
   90adc: e3013372     	movw	r3, #0x1372
   90ae0: eb01a577     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x695dc
   90ae4: eaffffdb     	b	0x90a58 <.text+0x80958> @ imm = #-0x94
   90ae8: 00582f10     	subseq	r2, r8, r0, lsl pc
   90aec: e59d00ac     	ldr	r0, [sp, #0xac]
   90af0: e2821008     	add	r1, r2, #8
   90af4: e3a02000     	mov	r2, #0
   90af8: e5903000     	ldr	r3, [r0]
   90afc: e1a00005     	mov	r0, r5
   90b00: eb003c5e     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0xf178
   90b04: e5941000     	ldr	r1, [r4]
   90b08: e2412001     	sub	r2, r1, #1
   90b0c: e0010291     	mul	r1, r1, r2
   90b10: e3110001     	tst	r1, #1
   90b14: 0a000021     	beq	0x90ba0 <.text+0x80aa0> @ imm = #0x84
   90b18: e5991000     	ldr	r1, [r9]
   90b1c: e59f2f8c     	ldr	r2, [pc, #0xf8c]        @ 0x91ab0 <.text+0x819b0>
   90b20: e351000a     	cmp	r1, #10
   90b24: e08f2002     	add	r2, pc, r2
   90b28: ba00001c     	blt	0x90ba0 <.text+0x80aa0> @ imm = #0x70
   90b2c: e59d00ac     	ldr	r0, [sp, #0xac]
   90b30: e2821008     	add	r1, r2, #8
   90b34: e3a02000     	mov	r2, #0
   90b38: e5903000     	ldr	r3, [r0]
   90b3c: e1a00005     	mov	r0, r5
   90b40: eb003c4e     	bl	0x9fc80 <.text+0x8fb80> @ imm = #0xf138
   90b44: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0x91b2c <.text+0x81a2c>
   90b48: e08f2002     	add	r2, pc, r2
   90b4c: eaffffe6     	b	0x90aec <.text+0x809ec> @ imm = #-0x68
   90b50: e2821008     	add	r1, r2, #8
   90b54: e1a00005     	mov	r0, r5
   90b58: eb002da6     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xb698
   90b5c: e5941000     	ldr	r1, [r4]
   90b60: e2412001     	sub	r2, r1, #1
   90b64: e0010291     	mul	r1, r1, r2
   90b68: e3110001     	tst	r1, #1
   90b6c: 0a00000b     	beq	0x90ba0 <.text+0x80aa0> @ imm = #0x2c
   90b70: e5991000     	ldr	r1, [r9]
   90b74: e59f2fb4     	ldr	r2, [pc, #0xfb4]        @ 0x91b30 <.text+0x81a30>
   90b78: e3510009     	cmp	r1, #9
   90b7c: e08f2002     	add	r2, pc, r2
   90b80: da000006     	ble	0x90ba0 <.text+0x80aa0> @ imm = #0x18
   90b84: e2821008     	add	r1, r2, #8
   90b88: e1a00005     	mov	r0, r5
   90b8c: eb002d99     	bl	0x9c1f8 <.text+0x8c0f8> @ imm = #0xb664
   90b90: e59f2ff8     	ldr	r2, [pc, #0xff8]        @ 0x91b90 <.text+0x81a90>
   90b94: e08f2002     	add	r2, pc, r2
   90b98: eaffffec     	b	0x90b50 <.text+0x80a50> @ imm = #-0x50
   90b9c: 00580df4     	ldrsheq	r0, [r8], #-212
   90ba0: e3500000     	cmp	r0, #0
   90ba4: 0a000010     	beq	0x90bec <.text+0x80aec> @ imm = #0x40
   90ba8: e1a00005     	mov	r0, r5
   90bac: e3a01001     	mov	r1, #1
   90bb0: eb0011df     	bl	0x95334 <.text+0x85234> @ imm = #0x477c
   90bb4: e3500000     	cmp	r0, #0
   90bb8: 0a000015     	beq	0x90c14 <.text+0x80b14> @ imm = #0x54
   90bbc: e5940000     	ldr	r0, [r4]
   90bc0: e2401001     	sub	r1, r0, #1
   90bc4: e0000190     	mul	r0, r0, r1
   90bc8: e3100001     	tst	r0, #1
   90bcc: 0a000054     	beq	0x90d24 <.text+0x80c24> @ imm = #0x150
   90bd0: e5990000     	ldr	r0, [r9]
   90bd4: e3500009     	cmp	r0, #9
   90bd8: ca00006f     	bgt	0x90d9c <.text+0x80c9c> @ imm = #0x1bc
   90bdc: ea000050     	b	0x90d24 <.text+0x80c24> @ imm = #0x140
   90be0: 00580dcc     	subseq	r0, r8, r12, asr #27
   90be4: 00580d94     	<unknown>
   90be8: 00580d6c     	subseq	r0, r8, r12, ror #26
   90bec: e59f6ff0     	ldr	r6, [pc, #0xff0]        @ 0x91be4 <.text+0x81ae4>
   90bf0: e08f6006     	add	r6, pc, r6
   90bf4: e1a00006     	mov	r0, r6
   90bf8: eb145542     	bl	0x5a6108 <.text+0x596008> @ imm = #0x515508
   90bfc: e1a00006     	mov	r0, r6
   90c00: e5d75000     	ldrb	r5, [r7]
   90c04: eb1456ae     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x515ab8
   90c08: e3550000     	cmp	r5, #0
   90c0c: e59d50c0     	ldr	r5, [sp, #0xc0]
   90c10: 0a000012     	beq	0x90c60 <.text+0x80b60> @ imm = #0x48
   90c14: e59f6fcc     	ldr	r6, [pc, #0xfcc]        @ 0x91be8 <.text+0x81ae8>
   90c18: e08f6006     	add	r6, pc, r6
   90c1c: e1a00006     	mov	r0, r6
   90c20: eb145538     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5154e0
   90c24: e1a00006     	mov	r0, r6
   90c28: e5d75000     	ldrb	r5, [r7]
   90c2c: eb1456a4     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x515a90
   90c30: e3550000     	cmp	r5, #0
   90c34: 1a000b9f     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x2e7c
   90c38: e5940000     	ldr	r0, [r4]
   90c3c: e59d70c0     	ldr	r7, [sp, #0xc0]
   90c40: e2401001     	sub	r1, r0, #1
   90c44: e0000190     	mul	r0, r0, r1
   90c48: e3100001     	tst	r0, #1
   90c4c: 0a000069     	beq	0x90df8 <.text+0x80cf8> @ imm = #0x1a4
   90c50: e5990000     	ldr	r0, [r9]
   90c54: e3500009     	cmp	r0, #9
   90c58: ca000070     	bgt	0x90e20 <.text+0x80d20> @ imm = #0x1c0
   90c5c: ea000065     	b	0x90df8 <.text+0x80cf8> @ imm = #0x194
   90c60: e5940000     	ldr	r0, [r4]
   90c64: e59f2fb8     	ldr	r2, [pc, #0xfb8]        @ 0x91c24 <.text+0x81b24>
   90c68: e2401001     	sub	r1, r0, #1
   90c6c: e08f2002     	add	r2, pc, r2
   90c70: e0000190     	mul	r0, r0, r1
   90c74: e3100001     	tst	r0, #1
   90c78: e5940000     	ldr	r0, [r4]
   90c7c: e2401001     	sub	r1, r0, #1
   90c80: e0010190     	mul	r1, r0, r1
   90c84: e3020034     	movw	r0, #0x2034
   90c88: e7920000     	ldr	r0, [r2, r0]
   90c8c: e3110001     	tst	r1, #1
   90c90: 0a000002     	beq	0x90ca0 <.text+0x80ba0> @ imm = #0x8
   90c94: e5991000     	ldr	r1, [r9]
   90c98: e3510009     	cmp	r1, #9
   90c9c: cafffff5     	bgt	0x90c78 <.text+0x80b78> @ imm = #-0x2c
   90ca0: e3500001     	cmp	r0, #1
   90ca4: 0a00000c     	beq	0x90cdc <.text+0x80bdc> @ imm = #0x30
   90ca8: e3500000     	cmp	r0, #0
   90cac: 1affffd8     	bne	0x90c14 <.text+0x80b14> @ imm = #-0xa0
   90cb0: e5940000     	ldr	r0, [r4]
   90cb4: e2401001     	sub	r1, r0, #1
   90cb8: e0000190     	mul	r0, r0, r1
   90cbc: e3100001     	tst	r0, #1
   90cc0: 0a00008c     	beq	0x90ef8 <.text+0x80df8> @ imm = #0x230
   90cc4: e5990000     	ldr	r0, [r9]
   90cc8: e3500009     	cmp	r0, #9
   90ccc: ca000096     	bgt	0x90f2c <.text+0x80e2c> @ imm = #0x258
   90cd0: ea000088     	b	0x90ef8 <.text+0x80df8> @ imm = #0x220
   90cd4: 00580ce8     	subseq	r0, r8, r8, ror #25
   90cd8: 005578c6     	subseq	r7, r5, r6, asr #17
   90cdc: e5940000     	ldr	r0, [r4]
   90ce0: e2401001     	sub	r1, r0, #1
   90ce4: e0000190     	mul	r0, r0, r1
   90ce8: e3100001     	tst	r0, #1
   90cec: 0a000095     	beq	0x90f48 <.text+0x80e48> @ imm = #0x254
   90cf0: e5990000     	ldr	r0, [r9]
   90cf4: e3500009     	cmp	r0, #9
   90cf8: ca0000a1     	bgt	0x90f84 <.text+0x80e84> @ imm = #0x284
   90cfc: ea000091     	b	0x90f48 <.text+0x80e48> @ imm = #0x244
   90d00: 00557177     	subseq	r7, r5, r7, ror r1
   90d04: 005570e1     	subseq	r7, r5, r1, ror #1
   90d08: 00557107     	subseq	r7, r5, r7, lsl #2
   90d0c: 00557811     	subseq	r7, r5, r1, lsl r8
   90d10: 00557123     	subseq	r7, r5, r3, lsr #2
   90d14: 0055708d     	subseq	r7, r5, sp, lsl #1
   90d18: 005570b3     	ldrheq	r7, [r5], #-3
   90d1c: 005577bd     	ldrheq	r7, [r5], #-125
   90d20: 00580be0     	subseq	r0, r8, r0, ror #23
   90d24: e59f0efc     	ldr	r0, [pc, #0xefc]        @ 0x91c28 <.text+0x81b28>
   90d28: e3a07001     	mov	r7, #1
   90d2c: e59f1ef8     	ldr	r1, [pc, #0xef8]        @ 0x91c2c <.text+0x81b2c>
   90d30: e59f2ef8     	ldr	r2, [pc, #0xef8]        @ 0x91c30 <.text+0x81b30>
   90d34: e08f0000     	add	r0, pc, r0
   90d38: e59f3ef4     	ldr	r3, [pc, #0xef4]        @ 0x91c34 <.text+0x81b34>
   90d3c: e08f1001     	add	r1, pc, r1
   90d40: e08f2002     	add	r2, pc, r2
   90d44: e58d7000     	str	r7, [sp]
   90d48: e08f3003     	add	r3, pc, r3
   90d4c: e58d3004     	str	r3, [sp, #0x4]
   90d50: e30133bf     	movw	r3, #0x13bf
   90d54: eb01a4da     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x69368
   90d58: e59d00b8     	ldr	r0, [sp, #0xb8]
   90d5c: e3001fa1     	movw	r1, #0xfa1
   90d60: ebfee3cc     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x470d0
   90d64: e59d00c0     	ldr	r0, [sp, #0xc0]
   90d68: ebff5884     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x29df0
   90d6c: e5940000     	ldr	r0, [r4]
   90d70: e3a02000     	mov	r2, #0
   90d74: e2401001     	sub	r1, r0, #1
   90d78: e0010190     	mul	r1, r0, r1
   90d7c: e5990000     	ldr	r0, [r9]
   90d80: e59f3eb0     	ldr	r3, [pc, #0xeb0]        @ 0x91c38 <.text+0x81b38>
   90d84: e08f3003     	add	r3, pc, r3
   90d88: e3110001     	tst	r1, #1
   90d8c: e5c32000     	strb	r2, [r3]
   90d90: 0a000b48     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x2d20
   90d94: e350000a     	cmp	r0, #10
   90d98: ba000b46     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x2d18
   90d9c: e59f0e98     	ldr	r0, [pc, #0xe98]        @ 0x91c3c <.text+0x81b3c>
   90da0: e3a07001     	mov	r7, #1
   90da4: e59f1e94     	ldr	r1, [pc, #0xe94]        @ 0x91c40 <.text+0x81b40>
   90da8: e59f2e94     	ldr	r2, [pc, #0xe94]        @ 0x91c44 <.text+0x81b44>
   90dac: e08f0000     	add	r0, pc, r0
   90db0: e59f3e90     	ldr	r3, [pc, #0xe90]        @ 0x91c48 <.text+0x81b48>
   90db4: e08f1001     	add	r1, pc, r1
   90db8: e08f2002     	add	r2, pc, r2
   90dbc: e58d7000     	str	r7, [sp]
   90dc0: e08f3003     	add	r3, pc, r3
   90dc4: e58d3004     	str	r3, [sp, #0x4]
   90dc8: e30133bf     	movw	r3, #0x13bf
   90dcc: eb01a4bc     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x692f0
   90dd0: e59d00b8     	ldr	r0, [sp, #0xb8]
   90dd4: e3001fa1     	movw	r1, #0xfa1
   90dd8: ebfee3ae     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x47148
   90ddc: e59d00c0     	ldr	r0, [sp, #0xc0]
   90de0: ebff5866     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x29e68
   90de4: e59f1e60     	ldr	r1, [pc, #0xe60]        @ 0x91c4c <.text+0x81b4c>
   90de8: e3a00000     	mov	r0, #0
   90dec: e08f1001     	add	r1, pc, r1
   90df0: e5c10000     	strb	r0, [r1]
   90df4: eaffffca     	b	0x90d24 <.text+0x80c24> @ imm = #-0xd8
   90df8: e1a00007     	mov	r0, r7
   90dfc: eb0019d9     	bl	0x97568 <.text+0x87468> @ imm = #0x6764
   90e00: e5941000     	ldr	r1, [r4]
   90e04: e2412001     	sub	r2, r1, #1
   90e08: e0010291     	mul	r1, r1, r2
   90e0c: e3110001     	tst	r1, #1
   90e10: 0a00000d     	beq	0x90e4c <.text+0x80d4c> @ imm = #0x34
   90e14: e5991000     	ldr	r1, [r9]
   90e18: e3510009     	cmp	r1, #9
   90e1c: da00000a     	ble	0x90e4c <.text+0x80d4c> @ imm = #0x28
   90e20: e1a00007     	mov	r0, r7
   90e24: eb0019cf     	bl	0x97568 <.text+0x87468> @ imm = #0x673c
   90e28: eafffff2     	b	0x90df8 <.text+0x80cf8> @ imm = #-0x38
   90e2c: 0055708f     	subseq	r7, r5, pc, lsl #1
   90e30: 00556ff9     	ldrsheq	r6, [r5], #-249
   90e34: 0055701f     	subseq	r7, r5, pc, lsl r0
   90e38: 00557784     	subseq	r7, r5, r4, lsl #15
   90e3c: 00580b34     	subseq	r0, r8, r4, lsr r11
   90e40: 0055701b     	subseq	r7, r5, r11, lsl r0
   90e44: 00556f89     	subseq	r6, r5, r9, lsl #31
   90e48: 00556fab     	subseq	r6, r5, r11, lsr #31
   90e4c: e3500000     	cmp	r0, #0
   90e50: 0a00007d     	beq	0x9104c <.text+0x80f4c> @ imm = #0x1f4
   90e54: e5970018     	ldr	r0, [r7, #0x18]
   90e58: eb0058eb     	bl	0xa720c <.text+0x9710c> @ imm = #0x163ac
   90e5c: eb01b601     	bl	0xfe668 <.text+0xee568> @ imm = #0x6d804
   90e60: e3500001     	cmp	r0, #1
   90e64: ba000007     	blt	0x90e88 <.text+0x80d88> @ imm = #0x1c
   90e68: e1a06000     	mov	r6, r0
   90e6c: e3a05000     	mov	r5, #0
   90e70: e5970230     	ldr	r0, [r7, #0x230]
   90e74: e0800005     	add	r0, r0, r5
   90e78: ebff1853     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x39eb4
   90e7c: e2855e32     	add	r5, r5, #800
   90e80: e2566001     	subs	r6, r6, #1
   90e84: 1afffff9     	bne	0x90e70 <.text+0x80d70> @ imm = #-0x1c
   90e88: e1a00007     	mov	r0, r7
   90e8c: eb001b1b     	bl	0x97b00 <.text+0x87a00> @ imm = #0x6c6c
   90e90: e5970018     	ldr	r0, [r7, #0x18]
   90e94: eb0058dc     	bl	0xa720c <.text+0x9710c> @ imm = #0x16370
   90e98: eb01b5f2     	bl	0xfe668 <.text+0xee568> @ imm = #0x6d7c8
   90e9c: e3500001     	cmp	r0, #1
   90ea0: ba000007     	blt	0x90ec4 <.text+0x80dc4> @ imm = #0x1c
   90ea4: e1a06000     	mov	r6, r0
   90ea8: e3a05000     	mov	r5, #0
   90eac: e5970230     	ldr	r0, [r7, #0x230]
   90eb0: e0800005     	add	r0, r0, r5
   90eb4: ebff1844     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x39ef0
   90eb8: e2855e32     	add	r5, r5, #800
   90ebc: e2566001     	subs	r6, r6, #1
   90ec0: 1afffff9     	bne	0x90eac <.text+0x80dac> @ imm = #-0x1c
   90ec4: e5940000     	ldr	r0, [r4]
   90ec8: e2401001     	sub	r1, r0, #1
   90ecc: e0000190     	mul	r0, r0, r1
   90ed0: e3100001     	tst	r0, #1
   90ed4: 0a000032     	beq	0x90fa4 <.text+0x80ea4> @ imm = #0xc8
   90ed8: e5990000     	ldr	r0, [r9]
   90edc: e3500009     	cmp	r0, #9
   90ee0: ca00003e     	bgt	0x90fe0 <.text+0x80ee0> @ imm = #0xf8
   90ee4: ea00002e     	b	0x90fa4 <.text+0x80ea4> @ imm = #0xb8
   90ee8: 00582b10     	subseq	r2, r8, r0, lsl r11
   90eec: 00556faf     	subseq	r6, r5, pc, lsr #31
   90ef0: 00556f1d     	subseq	r6, r5, sp, lsl pc
   90ef4: 00556f3f     	subseq	r6, r5, pc, lsr pc
   90ef8: e59f0fc8     	ldr	r0, [pc, #0xfc8]        @ 0x91ec8 <.text+0x81dc8>
   90efc: e08f0000     	add	r0, pc, r0
   90f00: e2801008     	add	r1, r0, #8
   90f04: e1a00005     	mov	r0, r5
   90f08: eb004094     	bl	0xa1160 <.text+0x91060> @ imm = #0x10250
   90f0c: e5940000     	ldr	r0, [r4]
   90f10: e2401001     	sub	r1, r0, #1
   90f14: e0000190     	mul	r0, r0, r1
   90f18: e3100001     	tst	r0, #1
   90f1c: 0affff3c     	beq	0x90c14 <.text+0x80b14> @ imm = #-0x310
   90f20: e5990000     	ldr	r0, [r9]
   90f24: e350000a     	cmp	r0, #10
   90f28: baffff39     	blt	0x90c14 <.text+0x80b14> @ imm = #-0x31c
   90f2c: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x91f18 <.text+0x81e18>
   90f30: e08f0000     	add	r0, pc, r0
   90f34: e2801008     	add	r1, r0, #8
   90f38: e1a00005     	mov	r0, r5
   90f3c: eb004087     	bl	0xa1160 <.text+0x91060> @ imm = #0x1021c
   90f40: eaffffec     	b	0x90ef8 <.text+0x80df8> @ imm = #-0x50
   90f44: 00582ab4     	ldrheq	r2, [r8], #-164
   90f48: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x91f1c <.text+0x81e1c>
   90f4c: e3020030     	movw	r0, #0x2030
   90f50: e08f1001     	add	r1, pc, r1
   90f54: e7912000     	ldr	r2, [r1, r0]
   90f58: e2811008     	add	r1, r1, #8
   90f5c: e1a00005     	mov	r0, r5
   90f60: eb00339c     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xce70
   90f64: e5940000     	ldr	r0, [r4]
   90f68: e2401001     	sub	r1, r0, #1
   90f6c: e0000190     	mul	r0, r0, r1
   90f70: e3100001     	tst	r0, #1
   90f74: 0affff26     	beq	0x90c14 <.text+0x80b14> @ imm = #-0x368
   90f78: e5990000     	ldr	r0, [r9]
   90f7c: e350000a     	cmp	r0, #10
   90f80: baffff23     	blt	0x90c14 <.text+0x80b14> @ imm = #-0x374
   90f84: e59f1f94     	ldr	r1, [pc, #0xf94]        @ 0x91f20 <.text+0x81e20>
   90f88: e3020030     	movw	r0, #0x2030
   90f8c: e08f1001     	add	r1, pc, r1
   90f90: e7912000     	ldr	r2, [r1, r0]
   90f94: e2811008     	add	r1, r1, #8
   90f98: e1a00005     	mov	r0, r5
   90f9c: eb00338d     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xce34
   90fa0: eaffffe8     	b	0x90f48 <.text+0x80e48> @ imm = #-0x60
   90fa4: e59d00a8     	ldr	r0, [sp, #0xa8]
   90fa8: e5902000     	ldr	r2, [r0]
   90fac: e59f0fe0     	ldr	r0, [pc, #0xfe0]        @ 0x91f94 <.text+0x81e94>
   90fb0: e08f0000     	add	r0, pc, r0
   90fb4: e5901008     	ldr	r1, [r0, #0x8]
   90fb8: e1a00007     	mov	r0, r7
   90fbc: eb000ee9     	bl	0x94b68 <.text+0x84a68> @ imm = #0x3ba4
   90fc0: e5941000     	ldr	r1, [r4]
   90fc4: e2412001     	sub	r2, r1, #1
   90fc8: e0010291     	mul	r1, r1, r2
   90fcc: e3110001     	tst	r1, #1
   90fd0: 0a00000b     	beq	0x91004 <.text+0x80f04> @ imm = #0x2c
   90fd4: e5991000     	ldr	r1, [r9]
   90fd8: e3510009     	cmp	r1, #9
   90fdc: da000008     	ble	0x91004 <.text+0x80f04> @ imm = #0x20
   90fe0: e59d00a8     	ldr	r0, [sp, #0xa8]
   90fe4: e5902000     	ldr	r2, [r0]
   90fe8: e59f0fa8     	ldr	r0, [pc, #0xfa8]        @ 0x91f98 <.text+0x81e98>
   90fec: e08f0000     	add	r0, pc, r0
   90ff0: e5901008     	ldr	r1, [r0, #0x8]
   90ff4: e1a00007     	mov	r0, r7
   90ff8: eb000eda     	bl	0x94b68 <.text+0x84a68> @ imm = #0x3b68
   90ffc: eaffffe8     	b	0x90fa4 <.text+0x80ea4> @ imm = #-0x60
   91000: 005809bc     	ldrheq	r0, [r8], #-156
   91004: e3500000     	cmp	r0, #0
   91008: 0a00000f     	beq	0x9104c <.text+0x80f4c> @ imm = #0x3c
   9100c: e5940000     	ldr	r0, [r4]
   91010: e2401001     	sub	r1, r0, #1
   91014: e0000190     	mul	r0, r0, r1
   91018: e3100001     	tst	r0, #1
   9101c: 0a000057     	beq	0x91180 <.text+0x81080> @ imm = #0x15c
   91020: e5990000     	ldr	r0, [r9]
   91024: e3500009     	cmp	r0, #9
   91028: ca000072     	bgt	0x911f8 <.text+0x810f8> @ imm = #0x1c8
   9102c: ea000053     	b	0x91180 <.text+0x81080> @ imm = #0x14c
   91030: 00580998     	<unknown>
   91034: 0058094c     	subseq	r0, r8, r12, asr #18
   91038: 00580934     	subseq	r0, r8, r4, lsr r9
   9103c: 00556e0f     	subseq	r6, r5, pc, lsl #28
   91040: 00556d79     	subseq	r6, r5, r9, ror sp
   91044: 00556d9f     	<unknown>
   91048: 00557394     	<unknown>
   9104c: e59f5f48     	ldr	r5, [pc, #0xf48]        @ 0x91f9c <.text+0x81e9c>
   91050: e302202c     	movw	r2, #0x202c
   91054: e1a00007     	mov	r0, r7
   91058: e08f5005     	add	r5, pc, r5
   9105c: e2856008     	add	r6, r5, #8
   91060: e1a01005     	mov	r1, r5
   91064: e7b13002     	ldr	r3, [r1, r2]!
   91068: e2832001     	add	r2, r3, #1
   9106c: e5812000     	str	r2, [r1]
   91070: e0851283     	add	r1, r5, r3, lsl #5
   91074: e1a02006     	mov	r2, r6
   91078: e2811028     	add	r1, r1, #40
   9107c: ebffe305     	bl	0x89c98 <.text+0x79b98> @ imm = #-0x73ec
   91080: e3020038     	movw	r0, #0x2038
   91084: ed9f0bdf     	vldr	d0, [pc, #892]          @ 0x91408 <.text+0x81308>
   91088: e0850000     	add	r0, r5, r0
   9108c: ed908b00     	vldr	d8, [r0]
   91090: e3020034     	movw	r0, #0x2034
   91094: e7950000     	ldr	r0, [r5, r0]
   91098: eeb48bc0     	vcmpe.f64	d8, d0
   9109c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   910a0: ceb08b40     	vmovgt.f64	d8, d0
   910a4: e3500000     	cmp	r0, #0
   910a8: 0a00000d     	beq	0x910e4 <.text+0x80fe4> @ imm = #0x34
   910ac: e3500001     	cmp	r0, #1
   910b0: 1a000018     	bne	0x91118 <.text+0x81018> @ imm = #0x60
   910b4: e3020030     	movw	r0, #0x2030
   910b8: eeb00b48     	vmov.f64	d0, d8
   910bc: e7951000     	ldr	r1, [r5, r0]
   910c0: e1a00006     	mov	r0, r6
   910c4: eb0034bf     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xd2fc
   910c8: e59fcffc     	ldr	r12, [pc, #0xffc]       @ 0x920cc <.text+0x81fcc>
   910cc: e3500000     	cmp	r0, #0
   910d0: e08fc00c     	add	r12, pc, r12
   910d4: e59d50c0     	ldr	r5, [sp, #0xc0]
   910d8: 0a000075     	beq	0x912b4 <.text+0x811b4> @ imm = #0x1d4
   910dc: ea00009e     	b	0x9135c <.text+0x8125c> @ imm = #0x278
   910e0: 00582918     	subseq	r2, r8, r8, lsl r9
   910e4: e5940000     	ldr	r0, [r4]
   910e8: e2401001     	sub	r1, r0, #1
   910ec: e0000190     	mul	r0, r0, r1
   910f0: e3100001     	tst	r0, #1
   910f4: 0a000058     	beq	0x9125c <.text+0x8115c> @ imm = #0x160
   910f8: e5990000     	ldr	r0, [r9]
   910fc: e3500009     	cmp	r0, #9
   91100: ca000060     	bgt	0x91288 <.text+0x81188> @ imm = #0x180
   91104: ea000054     	b	0x9125c <.text+0x8115c> @ imm = #0x150
   91108: 00556dc3     	subseq	r6, r5, r3, asr #27
   9110c: 00556d2d     	subseq	r6, r5, sp, lsr #26
   91110: 00556d53     	subseq	r6, r5, r3, asr sp
   91114: 005572e8     	subseq	r7, r5, r8, ror #5
   91118: e59f0fb0     	ldr	r0, [pc, #0xfb0]        @ 0x920d0 <.text+0x81fd0>
   9111c: e3a07002     	mov	r7, #2
   91120: e59f1fac     	ldr	r1, [pc, #0xfac]        @ 0x920d4 <.text+0x81fd4>
   91124: e59f2fac     	ldr	r2, [pc, #0xfac]        @ 0x920d8 <.text+0x81fd8>
   91128: e08f0000     	add	r0, pc, r0
   9112c: e59f3fa8     	ldr	r3, [pc, #0xfa8]        @ 0x920dc <.text+0x81fdc>
   91130: e08f1001     	add	r1, pc, r1
   91134: e08f2002     	add	r2, pc, r2
   91138: e58d7000     	str	r7, [sp]
   9113c: e08f3003     	add	r3, pc, r3
   91140: e58d3004     	str	r3, [sp, #0x4]
   91144: e3a03e75     	mov	r3, #1872
   91148: eb01a3dd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x68f74
   9114c: e59fcf8c     	ldr	r12, [pc, #0xf8c]       @ 0x920e0 <.text+0x81fe0>
   91150: e59d50c0     	ldr	r5, [sp, #0xc0]
   91154: e08fc00c     	add	r12, pc, r12
   91158: ea000055     	b	0x912b4 <.text+0x811b4> @ imm = #0x154
   9115c: 005828bc     	ldrheq	r2, [r8], #-140
   91160: 005828c4     	subseq	r2, r8, r4, asr #17
   91164: 00582890     	<unknown>
   91168: 00582898     	<unknown>
   9116c: 00580814     	subseq	r0, r8, r4, lsl r8
   91170: 00557469     	subseq	r7, r5, r9, ror #8
   91174: 0055745b     	subseq	r7, r5, r11, asr r4
   91178: 0055744d     	subseq	r7, r5, sp, asr #8
   9117c: 005807ac     	subseq	r0, r8, r12, lsr #15
   91180: e59f0f5c     	ldr	r0, [pc, #0xf5c]        @ 0x920e4 <.text+0x81fe4>
   91184: e3a07001     	mov	r7, #1
   91188: e59f1f58     	ldr	r1, [pc, #0xf58]        @ 0x920e8 <.text+0x81fe8>
   9118c: e59f2f58     	ldr	r2, [pc, #0xf58]        @ 0x920ec <.text+0x81fec>
   91190: e08f0000     	add	r0, pc, r0
   91194: e59f3f54     	ldr	r3, [pc, #0xf54]        @ 0x920f0 <.text+0x81ff0>
   91198: e08f1001     	add	r1, pc, r1
   9119c: e08f2002     	add	r2, pc, r2
   911a0: e58d7000     	str	r7, [sp]
   911a4: e08f3003     	add	r3, pc, r3
   911a8: e58d3004     	str	r3, [sp, #0x4]
   911ac: e30133cf     	movw	r3, #0x13cf
   911b0: eb01a3c3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x68f0c
   911b4: e59d00b8     	ldr	r0, [sp, #0xb8]
   911b8: e30017d9     	movw	r1, #0x7d9
   911bc: ebfee2b5     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x4752c
   911c0: e59d00c0     	ldr	r0, [sp, #0xc0]
   911c4: ebff576d     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2a24c
   911c8: e5940000     	ldr	r0, [r4]
   911cc: e3a02000     	mov	r2, #0
   911d0: e2401001     	sub	r1, r0, #1
   911d4: e0010190     	mul	r1, r0, r1
   911d8: e5990000     	ldr	r0, [r9]
   911dc: e59f3f10     	ldr	r3, [pc, #0xf10]        @ 0x920f4 <.text+0x81ff4>
   911e0: e08f3003     	add	r3, pc, r3
   911e4: e3110001     	tst	r1, #1
   911e8: e5c32000     	strb	r2, [r3]
   911ec: 0a000a31     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x28c4
   911f0: e350000a     	cmp	r0, #10
   911f4: ba000a2f     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x28bc
   911f8: e59f0ef8     	ldr	r0, [pc, #0xef8]        @ 0x920f8 <.text+0x81ff8>
   911fc: e3a07001     	mov	r7, #1
   91200: e59f1ef4     	ldr	r1, [pc, #0xef4]        @ 0x920fc <.text+0x81ffc>
   91204: e59f2ef4     	ldr	r2, [pc, #0xef4]        @ 0x92100 <.text+0x82000>
   91208: e08f0000     	add	r0, pc, r0
   9120c: e59f3ef0     	ldr	r3, [pc, #0xef0]        @ 0x92104 <.text+0x82004>
   91210: e08f1001     	add	r1, pc, r1
   91214: e08f2002     	add	r2, pc, r2
   91218: e58d7000     	str	r7, [sp]
   9121c: e08f3003     	add	r3, pc, r3
   91220: e58d3004     	str	r3, [sp, #0x4]
   91224: e30133cf     	movw	r3, #0x13cf
   91228: eb01a3a5     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x68e94
   9122c: e59d00b8     	ldr	r0, [sp, #0xb8]
   91230: e30017d9     	movw	r1, #0x7d9
   91234: ebfee297     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x475a4
   91238: e59d00c0     	ldr	r0, [sp, #0xc0]
   9123c: ebff574f     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2a2c4
   91240: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x92218 <.text+0x82118>
   91244: e3a00000     	mov	r0, #0
   91248: e08f1001     	add	r1, pc, r1
   9124c: e5c10000     	strb	r0, [r1]
   91250: eaffffca     	b	0x91180 <.text+0x81080> @ imm = #-0xd8
   91254: 00580758     	subseq	r0, r8, r8, asr r7
   91258: 00580734     	subseq	r0, r8, r4, lsr r7
   9125c: eeb00b48     	vmov.f64	d0, d8
   91260: e1a00006     	mov	r0, r6
   91264: eb0040bf     	bl	0xa1568 <.text+0x91468> @ imm = #0x102fc
   91268: e5941000     	ldr	r1, [r4]
   9126c: e2412001     	sub	r2, r1, #1
   91270: e0010291     	mul	r1, r1, r2
   91274: e3110001     	tst	r1, #1
   91278: 0a000008     	beq	0x912a0 <.text+0x811a0> @ imm = #0x20
   9127c: e5991000     	ldr	r1, [r9]
   91280: e3510009     	cmp	r1, #9
   91284: da000005     	ble	0x912a0 <.text+0x811a0> @ imm = #0x14
   91288: eeb00b48     	vmov.f64	d0, d8
   9128c: e1a00006     	mov	r0, r6
   91290: eb0040b4     	bl	0xa1568 <.text+0x91468> @ imm = #0x102d0
   91294: eafffff0     	b	0x9125c <.text+0x8115c> @ imm = #-0x40
   91298: 00580718     	subseq	r0, r8, r8, lsl r7
   9129c: 005826e0     	subseq	r2, r8, r0, ror #13
   912a0: e59fcfe4     	ldr	r12, [pc, #0xfe4]       @ 0x9228c <.text+0x8218c>
   912a4: e3500000     	cmp	r0, #0
   912a8: e08fc00c     	add	r12, pc, r12
   912ac: e59d50c0     	ldr	r5, [sp, #0xc0]
   912b0: 1a000029     	bne	0x9135c <.text+0x8125c> @ imm = #0xa4
   912b4: e302002c     	movw	r0, #0x202c
   912b8: e79c0000     	ldr	r0, [r12, r0]
   912bc: e3500005     	cmp	r0, #5
   912c0: ba0000c0     	blt	0x915c8 <.text+0x814c8> @ imm = #0x300
   912c4: e5941000     	ldr	r1, [r4]
   912c8: e2412001     	sub	r2, r1, #1
   912cc: e0010291     	mul	r1, r1, r2
   912d0: e3110001     	tst	r1, #1
   912d4: e5941000     	ldr	r1, [r4]
   912d8: ed9c0b06     	vldr	d0, [r12, #24]
   912dc: e2412001     	sub	r2, r1, #1
   912e0: e0010291     	mul	r1, r1, r2
   912e4: e3110001     	tst	r1, #1
   912e8: 0a000002     	beq	0x912f8 <.text+0x811f8> @ imm = #0x8
   912ec: e5991000     	ldr	r1, [r9]
   912f0: e3510009     	cmp	r1, #9
   912f4: cafffff6     	bgt	0x912d4 <.text+0x811d4> @ imm = #-0x28
   912f8: e2400001     	sub	r0, r0, #1
   912fc: e28c1038     	add	r1, r12, #56
   91300: e3a02000     	mov	r2, #0
   91304: ed9f1b41     	vldr	d1, [pc, #260]          @ 0x91410 <.text+0x81310>
   91308: e5943000     	ldr	r3, [r4]
   9130c: e2437001     	sub	r7, r3, #1
   91310: e0030793     	mul	r3, r3, r7
   91314: e3130001     	tst	r3, #1
   91318: e5943000     	ldr	r3, [r4]
   9131c: ed912b00     	vldr	d2, [r1]
   91320: e2437001     	sub	r7, r3, #1
   91324: e0030793     	mul	r3, r3, r7
   91328: e3130001     	tst	r3, #1
   9132c: 0a000002     	beq	0x9133c <.text+0x8123c> @ imm = #0x8
   91330: e5993000     	ldr	r3, [r9]
   91334: e3530009     	cmp	r3, #9
   91338: cafffff6     	bgt	0x91318 <.text+0x81218> @ imm = #-0x28
   9133c: ee322b01     	vadd.f64	d2, d2, d1
   91340: eeb40bc2     	vcmpe.f64	d0, d2
   91344: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91348: 4a00009e     	bmi	0x915c8 <.text+0x814c8> @ imm = #0x278
   9134c: e2822001     	add	r2, r2, #1
   91350: e2500001     	subs	r0, r0, #1
   91354: e2811020     	add	r1, r1, #32
   91358: 1affffea     	bne	0x91308 <.text+0x81208> @ imm = #-0x58
   9135c: e302202c     	movw	r2, #0x202c
   91360: e3a03000     	mov	r3, #0
   91364: e79c0002     	ldr	r0, [r12, r2]
   91368: e50b3148     	str	r3, [r11, #-0x148]
   9136c: e50b314c     	str	r3, [r11, #-0x14c]
   91370: e3500001     	cmp	r0, #1
   91374: e50b3150     	str	r3, [r11, #-0x150]
   91378: e08c1280     	add	r1, r12, r0, lsl #5
   9137c: e50b3154     	str	r3, [r11, #-0x154]
   91380: e50b3158     	str	r3, [r11, #-0x158]
   91384: ed918b06     	vldr	d8, [r1, #24]
   91388: ba0000b1     	blt	0x91654 <.text+0x81554> @ imm = #0x2c4
   9138c: e3e00000     	mvn	r0, #0
   91390: ed9f9b20     	vldr	d9, [pc, #128]          @ 0x91418 <.text+0x81318>
   91394: ed9fab21     	vldr	d10, [pc, #132]         @ 0x91420 <.text+0x81320>
   91398: e58d0038     	str	r0, [sp, #0x38]
   9139c: e3020038     	movw	r0, #0x2038
   913a0: e08c0000     	add	r0, r12, r0
   913a4: e58d003c     	str	r0, [sp, #0x3c]
   913a8: e58da048     	str	r10, [sp, #0x48]
   913ac: e35a0001     	cmp	r10, #1
   913b0: aa000006     	bge	0x913d0 <.text+0x812d0> @ imm = #0x18
   913b4: ea000075     	b	0x91590 <.text+0x81490> @ imm = #0x1d4
   913b8: 005805dc     	ldrsbeq	r0, [r8], #-92
   913bc: e2833001     	add	r3, r3, #1
   913c0: e1530000     	cmp	r3, r0
   913c4: aa00008c     	bge	0x915fc <.text+0x814fc> @ imm = #0x230
   913c8: e35a0001     	cmp	r10, #1
   913cc: ba00006f     	blt	0x91590 <.text+0x81490> @ imm = #0x1bc
   913d0: eeb0bb49     	vmov.f64	d11, d9
   913d4: e08c0283     	add	r0, r12, r3, lsl #5
   913d8: e1a0600a     	mov	r6, r10
   913dc: e3a08010     	mov	r8, #16
   913e0: e3a07000     	mov	r7, #0
   913e4: e3a05000     	mov	r5, #0
   913e8: e3a0a000     	mov	r10, #0
   913ec: e58d004c     	str	r0, [sp, #0x4c]
   913f0: e2800040     	add	r0, r0, #64
   913f4: e58d3050     	str	r3, [sp, #0x50]
   913f8: e58d0054     	str	r0, [sp, #0x54]
   913fc: ea00000e     	b	0x9143c <.text+0x8133c> @ imm = #0x38
   91400: 0058055c     	subseq	r0, r8, r12, asr r5
   91404: e320f000     	nop
   91408: 00000000     	andeq	r0, r0, r0
   9140c: 4058c000     	subsmi	r12, r8, r0
   91410: 00000000     	andeq	r0, r0, r0
   91414: 3fe00000     	svclo	#0xe00000
		...
   91424: bff00000     	svclt	#0xf00000
   91428: e28aa001     	add	r10, r10, #1
   9142c: e2877e32     	add	r7, r7, #800
   91430: e2888028     	add	r8, r8, #40
   91434: e2566001     	subs	r6, r6, #1
   91438: 0a00001d     	beq	0x914b4 <.text+0x813b4> @ imm = #0x74
   9143c: e59d00c0     	ldr	r0, [sp, #0xc0]
   91440: e5900230     	ldr	r0, [r0, #0x230]
   91444: e0800007     	add	r0, r0, r7
   91448: ebff16df     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3a484
   9144c: e3500000     	cmp	r0, #0
   91450: 0a000005     	beq	0x9146c <.text+0x8136c> @ imm = #0x14
   91454: e59d0054     	ldr	r0, [sp, #0x54]
   91458: e2855001     	add	r5, r5, #1
   9145c: e5900000     	ldr	r0, [r0]
   91460: e0800008     	add	r0, r0, r8
   91464: ed900b00     	vldr	d0, [r0]
   91468: ee3bbb00     	vadd.f64	d11, d11, d0
   9146c: e5940000     	ldr	r0, [r4]
   91470: e59fcfd0     	ldr	r12, [pc, #0xfd0]       @ 0x92448 <.text+0x82348>
   91474: e2401001     	sub	r1, r0, #1
   91478: e08fc00c     	add	r12, pc, r12
   9147c: e0000190     	mul	r0, r0, r1
   91480: e3100001     	tst	r0, #1
   91484: e5940000     	ldr	r0, [r4]
   91488: e2401001     	sub	r1, r0, #1
   9148c: e0000190     	mul	r0, r0, r1
   91490: e3100001     	tst	r0, #1
   91494: 0affffe3     	beq	0x91428 <.text+0x81328> @ imm = #-0x74
   91498: e5990000     	ldr	r0, [r9]
   9149c: e3500009     	cmp	r0, #9
   914a0: cafffff7     	bgt	0x91484 <.text+0x81384> @ imm = #-0x24
   914a4: eaffffdf     	b	0x91428 <.text+0x81328> @ imm = #-0x84
   914a8: 005804e8     	subseq	r0, r8, r8, ror #9
   914ac: 005824e8     	subseq	r2, r8, r8, ror #9
   914b0: 005824c0     	subseq	r2, r8, r0, asr #9
   914b4: e5940000     	ldr	r0, [r4]
   914b8: e59d304c     	ldr	r3, [sp, #0x4c]
   914bc: e2401001     	sub	r1, r0, #1
   914c0: e0000190     	mul	r0, r0, r1
   914c4: e3100001     	tst	r0, #1
   914c8: ed930b0e     	vldr	d0, [r3, #56]
   914cc: e5940000     	ldr	r0, [r4]
   914d0: eeb40bc8     	vcmpe.f64	d0, d8
   914d4: e2401001     	sub	r1, r0, #1
   914d8: e0020190     	mul	r2, r0, r1
   914dc: e3a00000     	mov	r0, #0
   914e0: eef1fa10     	vmrs	APSR_nzcv, fpscr
   914e4: e1a01005     	mov	r1, r5
   914e8: 43000001     	movwmi	r0, #0x1
   914ec: e3550000     	cmp	r5, #0
   914f0: 13001001     	movwne	r1, #0x1
   914f4: e3120001     	tst	r2, #1
   914f8: 0a000002     	beq	0x91508 <.text+0x81408> @ imm = #0x8
   914fc: e5992000     	ldr	r2, [r9]
   91500: e3520009     	cmp	r2, #9
   91504: caffffef     	bgt	0x914c8 <.text+0x813c8> @ imm = #-0x44
   91508: e59da048     	ldr	r10, [sp, #0x48]
   9150c: e0110000     	ands	r0, r1, r0
   91510: e59d3050     	ldr	r3, [sp, #0x50]
   91514: 0a00001b     	beq	0x91588 <.text+0x81488> @ imm = #0x6c
   91518: e5940000     	ldr	r0, [r4]
   9151c: e302202c     	movw	r2, #0x202c
   91520: e2401001     	sub	r1, r0, #1
   91524: e0000190     	mul	r0, r0, r1
   91528: e3100001     	tst	r0, #1
   9152c: ee015a10     	vmov	s2, r5
   91530: eeb81bc1     	vcvt.f64.s32	d1, s2
   91534: e59d103c     	ldr	r1, [sp, #0x3c]
   91538: e5940000     	ldr	r0, [r4]
   9153c: ed912b00     	vldr	d2, [r1]
   91540: e2401001     	sub	r1, r0, #1
   91544: e0000190     	mul	r0, r0, r1
   91548: e3100001     	tst	r0, #1
   9154c: 0a000002     	beq	0x9155c <.text+0x8145c> @ imm = #0x8
   91550: e5990000     	ldr	r0, [r9]
   91554: e3500009     	cmp	r0, #9
   91558: cafffff3     	bgt	0x9152c <.text+0x8142c> @ imm = #-0x34
   9155c: ee8b1b01     	vdiv.f64	d1, d11, d1
   91560: e59d50c0     	ldr	r5, [sp, #0xc0]
   91564: ee322b0a     	vadd.f64	d2, d2, d10
   91568: eeb41bc2     	vcmpe.f64	d1, d2
   9156c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91570: da000006     	ble	0x91590 <.text+0x81490> @ imm = #0x18
   91574: eeb08b40     	vmov.f64	d8, d0
   91578: e58d3038     	str	r3, [sp, #0x38]
   9157c: ea000003     	b	0x91590 <.text+0x81490> @ imm = #0xc
   91580: 00580440     	subseq	r0, r8, r0, asr #8
   91584: 0058040c     	subseq	r0, r8, r12, lsl #8
   91588: e59d50c0     	ldr	r5, [sp, #0xc0]
   9158c: e302202c     	movw	r2, #0x202c
   91590: e5940000     	ldr	r0, [r4]
   91594: e2401001     	sub	r1, r0, #1
   91598: e0000190     	mul	r0, r0, r1
   9159c: e3100001     	tst	r0, #1
   915a0: e5940000     	ldr	r0, [r4]
   915a4: e2401001     	sub	r1, r0, #1
   915a8: e0010190     	mul	r1, r0, r1
   915ac: e79c0002     	ldr	r0, [r12, r2]
   915b0: e3110001     	tst	r1, #1
   915b4: 0affff80     	beq	0x913bc <.text+0x812bc> @ imm = #-0x200
   915b8: e5991000     	ldr	r1, [r9]
   915bc: e3510009     	cmp	r1, #9
   915c0: cafffff6     	bgt	0x915a0 <.text+0x814a0> @ imm = #-0x28
   915c4: eaffff7c     	b	0x913bc <.text+0x812bc> @ imm = #-0x210
   915c8: e5940000     	ldr	r0, [r4]
   915cc: e2401001     	sub	r1, r0, #1
   915d0: e0000190     	mul	r0, r0, r1
   915d4: e3100001     	tst	r0, #1
   915d8: 0a00002b     	beq	0x9168c <.text+0x8158c> @ imm = #0xac
   915dc: e5990000     	ldr	r0, [r9]
   915e0: e3500009     	cmp	r0, #9
   915e4: ca000038     	bgt	0x916cc <.text+0x815cc> @ imm = #0xe0
   915e8: ea000027     	b	0x9168c <.text+0x8158c> @ imm = #0x9c
   915ec: 005568cb     	subseq	r6, r5, r11, asr #17
   915f0: 00556835     	subseq	r6, r5, r5, lsr r8
   915f4: 0055685b     	subseq	r6, r5, r11, asr r8
   915f8: 00556f65     	subseq	r6, r5, r5, ror #30
   915fc: e59d7038     	ldr	r7, [sp, #0x38]
   91600: e3770001     	cmn	r7, #1
   91604: 1a000013     	bne	0x91658 <.text+0x81558> @ imm = #0x4c
   91608: e3500001     	cmp	r0, #1
   9160c: ba000010     	blt	0x91654 <.text+0x81554> @ imm = #0x40
   91610: e28c1038     	add	r1, r12, #56
   91614: e3e07000     	mvn	r7, #0
   91618: e3a02000     	mov	r2, #0
   9161c: ed910b00     	vldr	d0, [r1]
   91620: e2811020     	add	r1, r1, #32
   91624: eeb40bc8     	vcmpe.f64	d0, d8
   91628: eef1fa10     	vmrs	APSR_nzcv, fpscr
   9162c: ceb08b40     	vmovgt.f64	d8, d0
   91630: c1a07002     	movgt	r7, r2
   91634: e2822001     	add	r2, r2, #1
   91638: e1500002     	cmp	r0, r2
   9163c: 1afffff6     	bne	0x9161c <.text+0x8151c> @ imm = #-0x28
   91640: ea000004     	b	0x91658 <.text+0x81558> @ imm = #0x10
   91644: 00556877     	subseq	r6, r5, r7, ror r8
   91648: 005567e1     	subseq	r6, r5, r1, ror #15
   9164c: 00556807     	subseq	r6, r5, r7, lsl #16
   91650: 00556f11     	subseq	r6, r5, r1, lsl pc
   91654: e3e07000     	mvn	r7, #0
   91658: e5940000     	ldr	r0, [r4]
   9165c: e2401001     	sub	r1, r0, #1
   91660: e0000190     	mul	r0, r0, r1
   91664: e3100001     	tst	r0, #1
   91668: 0a000052     	beq	0x917b8 <.text+0x816b8> @ imm = #0x148
   9166c: e5990000     	ldr	r0, [r9]
   91670: e3500009     	cmp	r0, #9
   91674: ca000066     	bgt	0x91814 <.text+0x81714> @ imm = #0x198
   91678: ea00004e     	b	0x917b8 <.text+0x816b8> @ imm = #0x138
   9167c: 00580320     	subseq	r0, r8, r0, lsr #6
   91680: 005567ff     	ldrsheq	r6, [r5], #-127
   91684: 00556769     	subseq	r6, r5, r9, ror #14
   91688: 0055678f     	subseq	r6, r5, pc, lsl #15
   9168c: e59c0008     	ldr	r0, [r12, #0x8]
   91690: e2801019     	add	r1, r0, #25
   91694: e59d00bc     	ldr	r0, [sp, #0xbc]
   91698: ebfefbba     	bl	0x50588 <.text+0x40488> @ imm = #-0x41118
   9169c: e59fcfec     	ldr	r12, [pc, #0xfec]       @ 0x92690 <.text+0x82590>
   916a0: e1a06000     	mov	r6, r0
   916a4: e5940000     	ldr	r0, [r4]
   916a8: e08fc00c     	add	r12, pc, r12
   916ac: e2401001     	sub	r1, r0, #1
   916b0: e0010190     	mul	r1, r0, r1
   916b4: e59c0008     	ldr	r0, [r12, #0x8]
   916b8: e3110001     	tst	r1, #1
   916bc: 0a00000b     	beq	0x916f0 <.text+0x815f0> @ imm = #0x2c
   916c0: e5991000     	ldr	r1, [r9]
   916c4: e3510009     	cmp	r1, #9
   916c8: da000008     	ble	0x916f0 <.text+0x815f0> @ imm = #0x20
   916cc: e59c0008     	ldr	r0, [r12, #0x8]
   916d0: e2801019     	add	r1, r0, #25
   916d4: e59d00bc     	ldr	r0, [sp, #0xbc]
   916d8: ebfefbaa     	bl	0x50588 <.text+0x40488> @ imm = #-0x41158
   916dc: e59fcfb0     	ldr	r12, [pc, #0xfb0]       @ 0x92694 <.text+0x82594>
   916e0: e08fc00c     	add	r12, pc, r12
   916e4: eaffffe8     	b	0x9168c <.text+0x8158c> @ imm = #-0x60
   916e8: 00556ef4     	ldrsheq	r6, [r5], #-228
   916ec: 00580298     	<unknown>
   916f0: e1560000     	cmp	r6, r0
   916f4: 1a000015     	bne	0x91750 <.text+0x81650> @ imm = #0x54
   916f8: eb01c4de     	bl	0x102a78 <.text+0xf2978> @ imm = #0x71378
   916fc: e59fcfe8     	ldr	r12, [pc, #0xfe8]       @ 0x926ec <.text+0x825ec>
   91700: e1560000     	cmp	r6, r0
   91704: e08fc00c     	add	r12, pc, r12
   91708: ba000010     	blt	0x91750 <.text+0x81650> @ imm = #0x40
   9170c: e1a00005     	mov	r0, r5
   91710: e3a01001     	mov	r1, #1
   91714: eb000f06     	bl	0x95334 <.text+0x85234> @ imm = #0x3c18
   91718: e59fcfd0     	ldr	r12, [pc, #0xfd0]       @ 0x926f0 <.text+0x825f0>
   9171c: e3500000     	cmp	r0, #0
   91720: e08fc00c     	add	r12, pc, r12
   91724: 0a000009     	beq	0x91750 <.text+0x81650> @ imm = #0x24
   91728: e5940000     	ldr	r0, [r4]
   9172c: e2401001     	sub	r1, r0, #1
   91730: e0000190     	mul	r0, r0, r1
   91734: e3100001     	tst	r0, #1
   91738: 0a000087     	beq	0x9195c <.text+0x8185c> @ imm = #0x21c
   9173c: e5990000     	ldr	r0, [r9]
   91740: e3500009     	cmp	r0, #9
   91744: ca0000a2     	bgt	0x919d4 <.text+0x818d4> @ imm = #0x288
   91748: ea000083     	b	0x9195c <.text+0x8185c> @ imm = #0x20c
   9174c: 00580254     	subseq	r0, r8, r4, asr r2
   91750: e5940000     	ldr	r0, [r4]
   91754: e2401001     	sub	r1, r0, #1
   91758: e0000190     	mul	r0, r0, r1
   9175c: e3100001     	tst	r0, #1
   91760: 0a000002     	beq	0x91770 <.text+0x81670> @ imm = #0x8
   91764: e5990000     	ldr	r0, [r9]
   91768: e3500009     	cmp	r0, #9
   9176c: c58c6008     	strgt	r6, [r12, #0x8]
   91770: e5940000     	ldr	r0, [r4]
   91774: e58c6008     	str	r6, [r12, #0x8]
   91778: e2401001     	sub	r1, r0, #1
   9177c: e0010190     	mul	r1, r0, r1
   91780: e5990000     	ldr	r0, [r9]
   91784: e3110001     	tst	r1, #1
   91788: 0a0008ca     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x2328
   9178c: e350000a     	cmp	r0, #10
   91790: ba0008c8     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x2320
   91794: e58c6008     	str	r6, [r12, #0x8]
   91798: eafffff4     	b	0x91770 <.text+0x81670> @ imm = #-0x30
   9179c: 00580208     	subseq	r0, r8, r8, lsl #4
   917a0: 005801e4     	subseq	r0, r8, r4, ror #3
   917a4: 005801d0     	ldrsbeq	r0, [r8], #-16
   917a8: 005566bf     	ldrheq	r6, [r5], #-111
   917ac: 00556629     	subseq	r6, r5, r9, lsr #12
   917b0: 0055664f     	subseq	r6, r5, pc, asr #12
   917b4: 00556c8e     	subseq	r6, r5, lr, lsl #25
   917b8: e24b1f56     	sub	r1, r11, #344
   917bc: e1a00005     	mov	r0, r5
   917c0: ebffc29d     	bl	0x8223c <.text+0x7213c> @ imm = #-0xf58c
   917c4: e5950018     	ldr	r0, [r5, #0x18]
   917c8: eb00568f     	bl	0xa720c <.text+0x9710c> @ imm = #0x15a3c
   917cc: e1a08000     	mov	r8, r0
   917d0: eb01b3a4     	bl	0xfe668 <.text+0xee568> @ imm = #0x6ce90
   917d4: e5941000     	ldr	r1, [r4]
   917d8: e59f2ffc     	ldr	r2, [pc, #0xffc]        @ 0x927dc <.text+0x826dc>
   917dc: e08f2002     	add	r2, pc, r2
   917e0: e082c287     	add	r12, r2, r7, lsl #5
   917e4: e2412001     	sub	r2, r1, #1
   917e8: e58dc024     	str	r12, [sp, #0x24]
   917ec: e0020291     	mul	r2, r1, r2
   917f0: e5bc602c     	ldr	r6, [r12, #0x2c]!
   917f4: e5991000     	ldr	r1, [r9]
   917f8: e51c3004     	ldr	r3, [r12, #-0x4]
   917fc: e50b6150     	str	r6, [r11, #-0x150]
   91800: e50b3154     	str	r3, [r11, #-0x154]
   91804: e3120001     	tst	r2, #1
   91808: 0a000017     	beq	0x9186c <.text+0x8176c> @ imm = #0x5c
   9180c: e3510009     	cmp	r1, #9
   91810: da000015     	ble	0x9186c <.text+0x8176c> @ imm = #0x54
   91814: e24b1f56     	sub	r1, r11, #344
   91818: e1a00005     	mov	r0, r5
   9181c: ebffc286     	bl	0x8223c <.text+0x7213c> @ imm = #-0xf5e8
   91820: e5950018     	ldr	r0, [r5, #0x18]
   91824: eb005678     	bl	0xa720c <.text+0x9710c> @ imm = #0x159e0
   91828: e59f0fe4     	ldr	r0, [pc, #0xfe4]        @ 0x92814 <.text+0x82714>
   9182c: e08f0000     	add	r0, pc, r0
   91830: e0805287     	add	r5, r0, r7, lsl #5
   91834: eb01b38b     	bl	0xfe668 <.text+0xee568> @ imm = #0x6ce2c
   91838: e1c502d8     	ldrd	r0, r1, [r5, #40]
   9183c: e59d50c0     	ldr	r5, [sp, #0xc0]
   91840: e50b1150     	str	r1, [r11, #-0x150]
   91844: e50b0154     	str	r0, [r11, #-0x154]
   91848: eaffffda     	b	0x917b8 <.text+0x816b8> @ imm = #-0x98
   9184c: 00556683     	subseq	r6, r5, r3, lsl #13
   91850: 005565ed     	subseq	r6, r5, sp, ror #11
   91854: 00556613     	subseq	r6, r5, r3, lsl r6
   91858: 00556d78     	subseq	r6, r5, r8, ror sp
   9185c: 0055662b     	subseq	r6, r5, r11, lsr #12
   91860: 00556595     	<unknown>
   91864: 005565bb     	ldrheq	r6, [r5], #-91
   91868: 00556d20     	subseq	r6, r5, r0, lsr #26
   9186c: e3500001     	cmp	r0, #1
   91870: ba00002a     	blt	0x91920 <.text+0x81820> @ imm = #0xa8
   91874: e59d1024     	ldr	r1, [sp, #0x24]
   91878: e3a0a000     	mov	r10, #0
   9187c: e281e040     	add	lr, r1, #64
   91880: e51b114c     	ldr	r1, [r11, #-0x14c]
   91884: e08a508a     	add	r5, r10, r10, lsl #1
   91888: e7816105     	str	r6, [r1, r5, lsl #2]
   9188c: e5981010     	ldr	r1, [r8, #0x10]
   91890: e3510001     	cmp	r1, #1
   91894: ba00000f     	blt	0x918d8 <.text+0x817d8> @ imm = #0x3c
   91898: e3a06000     	mov	r6, #0
   9189c: e3a01000     	mov	r1, #0
   918a0: e59e2000     	ldr	r2, [lr]
   918a4: e08a310a     	add	r3, r10, r10, lsl #2
   918a8: e51b714c     	ldr	r7, [r11, #-0x14c]
   918ac: e0822183     	add	r2, r2, r3, lsl #3
   918b0: e0873105     	add	r3, r7, r5, lsl #2
   918b4: e5922020     	ldr	r2, [r2, #0x20]
   918b8: e5933008     	ldr	r3, [r3, #0x8]
   918bc: e7922006     	ldr	r2, [r2, r6]
   918c0: e2866038     	add	r6, r6, #56
   918c4: e7832101     	str	r2, [r3, r1, lsl #2]
   918c8: e2811001     	add	r1, r1, #1
   918cc: e5982010     	ldr	r2, [r8, #0x10]
   918d0: e1510002     	cmp	r1, r2
   918d4: bafffff1     	blt	0x918a0 <.text+0x817a0> @ imm = #-0x3c
   918d8: e5941000     	ldr	r1, [r4]
   918dc: e59d50c0     	ldr	r5, [sp, #0xc0]
   918e0: e2412001     	sub	r2, r1, #1
   918e4: e0010291     	mul	r1, r1, r2
   918e8: e3110001     	tst	r1, #1
   918ec: e5941000     	ldr	r1, [r4]
   918f0: e2412001     	sub	r2, r1, #1
   918f4: e0010291     	mul	r1, r1, r2
   918f8: e3110001     	tst	r1, #1
   918fc: 0a000002     	beq	0x9190c <.text+0x8180c> @ imm = #0x8
   91900: e5991000     	ldr	r1, [r9]
   91904: e3510009     	cmp	r1, #9
   91908: cafffff7     	bgt	0x918ec <.text+0x817ec> @ imm = #-0x24
   9190c: e28aa001     	add	r10, r10, #1
   91910: e15a0000     	cmp	r10, r0
   91914: 0a000001     	beq	0x91920 <.text+0x81820> @ imm = #0x4
   91918: e59c6000     	ldr	r6, [r12]
   9191c: eaffffd7     	b	0x91880 <.text+0x81780> @ imm = #-0xa4
   91920: e5940000     	ldr	r0, [r4]
   91924: e2401001     	sub	r1, r0, #1
   91928: e0000190     	mul	r0, r0, r1
   9192c: e3100001     	tst	r0, #1
   91930: 0a000042     	beq	0x91a40 <.text+0x81940> @ imm = #0x108
   91934: e5990000     	ldr	r0, [r9]
   91938: e3500009     	cmp	r0, #9
   9193c: ca000051     	bgt	0x91a88 <.text+0x81988> @ imm = #0x144
   91940: ea00003e     	b	0x91a40 <.text+0x81940> @ imm = #0xf8
   91944: 00580058     	subseq	r0, r8, r8, asr r0
   91948: 00580040     	subseq	r0, r8, r0, asr #32
   9194c: 00580028     	subseq	r0, r8, r8, lsr #32
   91950: 0057fff0     	ldrsheq	pc, [r7], #-240
   91954: 0057ffd8     	ldrsbeq	pc, [r7], #-248
   91958: 0057ffc4     	subseq	pc, r7, r4, asr #31
   9195c: e59f0f54     	ldr	r0, [pc, #0xf54]        @ 0x928b8 <.text+0x827b8>
   91960: e3a07001     	mov	r7, #1
   91964: e59f1f50     	ldr	r1, [pc, #0xf50]        @ 0x928bc <.text+0x827bc>
   91968: e59f2f50     	ldr	r2, [pc, #0xf50]        @ 0x928c0 <.text+0x827c0>
   9196c: e08f0000     	add	r0, pc, r0
   91970: e59f3f4c     	ldr	r3, [pc, #0xf4c]        @ 0x928c4 <.text+0x827c4>
   91974: e08f1001     	add	r1, pc, r1
   91978: e08f2002     	add	r2, pc, r2
   9197c: e58d7000     	str	r7, [sp]
   91980: e08f3003     	add	r3, pc, r3
   91984: e58d3004     	str	r3, [sp, #0x4]
   91988: e301342c     	movw	r3, #0x142c
   9198c: eb01a1cc     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x68730
   91990: e59d00b8     	ldr	r0, [sp, #0xb8]
   91994: e3001fa1     	movw	r1, #0xfa1
   91998: ebfee0be     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x47d08
   9199c: e59d00c0     	ldr	r0, [sp, #0xc0]
   919a0: ebff5576     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2aa28
   919a4: e5940000     	ldr	r0, [r4]
   919a8: e3a02000     	mov	r2, #0
   919ac: e2401001     	sub	r1, r0, #1
   919b0: e0010190     	mul	r1, r0, r1
   919b4: e5990000     	ldr	r0, [r9]
   919b8: e59f3fc4     	ldr	r3, [pc, #0xfc4]        @ 0x92984 <.text+0x82884>
   919bc: e08f3003     	add	r3, pc, r3
   919c0: e3110001     	tst	r1, #1
   919c4: e5c32000     	strb	r2, [r3]
   919c8: 0a00083a     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x20e8
   919cc: e350000a     	cmp	r0, #10
   919d0: ba000838     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x20e0
   919d4: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x929d4 <.text+0x828d4>
   919d8: e3a07001     	mov	r7, #1
   919dc: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0x929d8 <.text+0x828d8>
   919e0: e59f2ff4     	ldr	r2, [pc, #0xff4]        @ 0x929dc <.text+0x828dc>
   919e4: e08f0000     	add	r0, pc, r0
   919e8: e59f3ff0     	ldr	r3, [pc, #0xff0]        @ 0x929e0 <.text+0x828e0>
   919ec: e08f1001     	add	r1, pc, r1
   919f0: e08f2002     	add	r2, pc, r2
   919f4: e58d7000     	str	r7, [sp]
   919f8: e08f3003     	add	r3, pc, r3
   919fc: e58d3004     	str	r3, [sp, #0x4]
   91a00: e301342c     	movw	r3, #0x142c
   91a04: eb01a1ae     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x686b8
   91a08: e59d00b8     	ldr	r0, [sp, #0xb8]
   91a0c: e3001fa1     	movw	r1, #0xfa1
   91a10: ebfee0a0     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x47d80
   91a14: e59d00c0     	ldr	r0, [sp, #0xc0]
   91a18: ebff5558     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2aaa0
   91a1c: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0x92a18 <.text+0x82918>
   91a20: e3a00000     	mov	r0, #0
   91a24: e08f1001     	add	r1, pc, r1
   91a28: e5c10000     	strb	r0, [r1]
   91a2c: eaffffca     	b	0x9195c <.text+0x8185c> @ imm = #-0xd8
   91a30: 00556477     	subseq	r6, r5, r7, ror r4
   91a34: 005563e1     	subseq	r6, r5, r1, ror #7
   91a38: 00556407     	subseq	r6, r5, r7, lsl #8
   91a3c: 00556a46     	subseq	r6, r5, r6, asr #20
   91a40: e5950018     	ldr	r0, [r5, #0x18]
   91a44: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x92a1c <.text+0x8291c>
   91a48: e08f1001     	add	r1, pc, r1
   91a4c: e5917004     	ldr	r7, [r1, #0x4]
   91a50: eb0055ed     	bl	0xa720c <.text+0x9710c> @ imm = #0x157b4
   91a54: e1a06000     	mov	r6, r0
   91a58: eb01b302     	bl	0xfe668 <.text+0xee568> @ imm = #0x6cc08
   91a5c: e1a0a000     	mov	r10, r0
   91a60: e1a00005     	mov	r0, r5
   91a64: ebff2d63     	bl	0x5cff8 <.text+0x4cef8> @ imm = #-0x34a74
   91a68: e5942000     	ldr	r2, [r4]
   91a6c: e2421001     	sub	r1, r2, #1
   91a70: e0010192     	mul	r1, r2, r1
   91a74: e3110001     	tst	r1, #1
   91a78: 0a00000d     	beq	0x91ab4 <.text+0x819b4> @ imm = #0x34
   91a7c: e5991000     	ldr	r1, [r9]
   91a80: e3510009     	cmp	r1, #9
   91a84: da00000a     	ble	0x91ab4 <.text+0x819b4> @ imm = #0x28
   91a88: e5950018     	ldr	r0, [r5, #0x18]
   91a8c: eb0055de     	bl	0xa720c <.text+0x9710c> @ imm = #0x15778
   91a90: eb01b2f4     	bl	0xfe668 <.text+0xee568> @ imm = #0x6cbd0
   91a94: e1a00005     	mov	r0, r5
   91a98: ebff2d56     	bl	0x5cff8 <.text+0x4cef8> @ imm = #-0x34aa8
   91a9c: eaffffe7     	b	0x91a40 <.text+0x81940> @ imm = #-0x64
   91aa0: 0055641f     	subseq	r6, r5, pc, lsl r4
   91aa4: 00556389     	subseq	r6, r5, r9, lsl #7
   91aa8: 005563af     	subseq	r6, r5, pc, lsr #7
   91aac: 005569ee     	subseq	r6, r5, lr, ror #19
   91ab0: 0057fea4     	subseq	pc, r7, r4, lsr #29
   91ab4: e3500001     	cmp	r0, #1
   91ab8: ba0001d7     	blt	0x9221c <.text+0x8211c> @ imm = #0x75c
   91abc: e5942000     	ldr	r2, [r4]
   91ac0: e2421001     	sub	r1, r2, #1
   91ac4: e0010192     	mul	r1, r2, r1
   91ac8: e3110001     	tst	r1, #1
   91acc: e5943000     	ldr	r3, [r4]
   91ad0: e5962010     	ldr	r2, [r6, #0x10]
   91ad4: e2431001     	sub	r1, r3, #1
   91ad8: e0010193     	mul	r1, r3, r1
   91adc: e3110001     	tst	r1, #1
   91ae0: 0a000002     	beq	0x91af0 <.text+0x819f0> @ imm = #0x8
   91ae4: e5991000     	ldr	r1, [r9]
   91ae8: e3510009     	cmp	r1, #9
   91aec: cafffff6     	bgt	0x91acc <.text+0x819cc> @ imm = #-0x28
   91af0: e58d0050     	str	r0, [sp, #0x50]
   91af4: e0000092     	mul	r0, r2, r0
   91af8: e35a0001     	cmp	r10, #1
   91afc: e58d7048     	str	r7, [sp, #0x48]
   91b00: e58d203c     	str	r2, [sp, #0x3c]
   91b04: e58d004c     	str	r0, [sp, #0x4c]
   91b08: e58da02c     	str	r10, [sp, #0x2c]
   91b0c: ba00004f     	blt	0x91c50 <.text+0x81b50> @ imm = #0x13c
   91b10: ed9fabee     	vldr	d10, [pc, #952]         @ 0x91ed0 <.text+0x81dd0>
   91b14: e3a06000     	mov	r6, #0
   91b18: e59d0024     	ldr	r0, [sp, #0x24]
   91b1c: e3a08e32     	mov	r8, #800
   91b20: eeb0bb4a     	vmov.f64	d11, d10
   91b24: e2805040     	add	r5, r0, #64
   91b28: ea000004     	b	0x91b40 <.text+0x81a40> @ imm = #0x10
   91b2c: 0057fe80     	subseq	pc, r7, r0, lsl #29
   91b30: 0057fe4c     	subseq	pc, r7, r12, asr #28
   91b34: e2866001     	add	r6, r6, #1
   91b38: e156000a     	cmp	r6, r10
   91b3c: 0a000045     	beq	0x91c58 <.text+0x81b58> @ imm = #0x114
   91b40: e59d00c0     	ldr	r0, [sp, #0xc0]
   91b44: e5900230     	ldr	r0, [r0, #0x230]
   91b48: e0200896     	mla	r0, r6, r8, r0
   91b4c: ebff151e     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3ab88
   91b50: e3500000     	cmp	r0, #0
   91b54: 0a000025     	beq	0x91bf0 <.text+0x81af0> @ imm = #0x94
   91b58: e5950000     	ldr	r0, [r5]
   91b5c: e0861106     	add	r1, r6, r6, lsl #2
   91b60: e59d203c     	ldr	r2, [sp, #0x3c]
   91b64: e0800181     	add	r0, r0, r1, lsl #3
   91b68: e3520001     	cmp	r2, #1
   91b6c: ed900b04     	vldr	d0, [r0, #16]
   91b70: ee3bbb00     	vadd.f64	d11, d11, d0
   91b74: ba00001d     	blt	0x91bf0 <.text+0x81af0> @ imm = #0x74
   91b78: e51b014c     	ldr	r0, [r11, #-0x14c]
   91b7c: e0861086     	add	r1, r6, r6, lsl #1
   91b80: e0800101     	add	r0, r0, r1, lsl #2
   91b84: e3a01000     	mov	r1, #0
   91b88: e5900008     	ldr	r0, [r0, #0x8]
   91b8c: ea000005     	b	0x91ba8 <.text+0x81aa8> @ imm = #0x14
   91b90: 0057fe34     	subseq	pc, r7, r4, lsr lr
   91b94: ee3aab00     	vadd.f64	d10, d10, d0
   91b98: e2811001     	add	r1, r1, #1
   91b9c: e2800004     	add	r0, r0, #4
   91ba0: e2522001     	subs	r2, r2, #1
   91ba4: 0a000010     	beq	0x91bec <.text+0x81aec> @ imm = #0x40
   91ba8: e5943000     	ldr	r3, [r4]
   91bac: e2437001     	sub	r7, r3, #1
   91bb0: e0030793     	mul	r3, r3, r7
   91bb4: e3130001     	tst	r3, #1
   91bb8: ed900a00     	vldr	s0, [r0]
   91bbc: eeb80bc0     	vcvt.f64.s32	d0, s0
   91bc0: e5943000     	ldr	r3, [r4]
   91bc4: e2437001     	sub	r7, r3, #1
   91bc8: e0030793     	mul	r3, r3, r7
   91bcc: e3130001     	tst	r3, #1
   91bd0: 0affffef     	beq	0x91b94 <.text+0x81a94> @ imm = #-0x44
   91bd4: e5993000     	ldr	r3, [r9]
   91bd8: e3530009     	cmp	r3, #9
   91bdc: cafffff5     	bgt	0x91bb8 <.text+0x81ab8> @ imm = #-0x2c
   91be0: eaffffeb     	b	0x91b94 <.text+0x81a94> @ imm = #-0x54
   91be4: 00581e2c     	subseq	r1, r8, r12, lsr #28
   91be8: 00581e04     	subseq	r1, r8, r4, lsl #28
   91bec: e59da02c     	ldr	r10, [sp, #0x2c]
   91bf0: e5940000     	ldr	r0, [r4]
   91bf4: e2401001     	sub	r1, r0, #1
   91bf8: e0000190     	mul	r0, r0, r1
   91bfc: e3100001     	tst	r0, #1
   91c00: e5940000     	ldr	r0, [r4]
   91c04: e2401001     	sub	r1, r0, #1
   91c08: e0000190     	mul	r0, r0, r1
   91c0c: e3100001     	tst	r0, #1
   91c10: 0affffc7     	beq	0x91b34 <.text+0x81a34> @ imm = #-0xe4
   91c14: e5990000     	ldr	r0, [r9]
   91c18: e3500009     	cmp	r0, #9
   91c1c: cafffff7     	bgt	0x91c00 <.text+0x81b00> @ imm = #-0x24
   91c20: eaffffc3     	b	0x91b34 <.text+0x81a34> @ imm = #-0xf4
   91c24: 0057fd5c     	subseq	pc, r7, r12, asr sp
   91c28: 005561ab     	subseq	r6, r5, r11, lsr #3
   91c2c: 00556115     	subseq	r6, r5, r5, lsl r1
   91c30: 0055613b     	subseq	r6, r5, r11, lsr r1
   91c34: 00556730     	subseq	r6, r5, r0, lsr r7
   91c38: 00581c94     	<unknown>
   91c3c: 00556133     	subseq	r6, r5, r3, lsr r1
   91c40: 0055609d     	<unknown>
   91c44: 005560c3     	subseq	r6, r5, r3, asr #1
   91c48: 005566b8     	ldrheq	r6, [r5], #-104
   91c4c: 00581c2c     	subseq	r1, r8, r12, lsr #24
   91c50: ed9fbb9e     	vldr	d11, [pc, #632]         @ 0x91ed0 <.text+0x81dd0>
   91c54: eeb0ab4b     	vmov.f64	d10, d11
   91c58: e5940000     	ldr	r0, [r4]
   91c5c: e59d50c0     	ldr	r5, [sp, #0xc0]
   91c60: e2401001     	sub	r1, r0, #1
   91c64: e59d8050     	ldr	r8, [sp, #0x50]
   91c68: e59d604c     	ldr	r6, [sp, #0x4c]
   91c6c: e0000190     	mul	r0, r0, r1
   91c70: e59d7048     	ldr	r7, [sp, #0x48]
   91c74: e3100001     	tst	r0, #1
   91c78: 0a000002     	beq	0x91c88 <.text+0x81b88> @ imm = #0x8
   91c7c: e5990000     	ldr	r0, [r9]
   91c80: e3500009     	cmp	r0, #9
   91c84: ca000049     	bgt	0x91db0 <.text+0x81cb0> @ imm = #0x124
   91c88: ee008a10     	vmov	s0, r8
   91c8c: ee016a10     	vmov	s2, r6
   91c90: eeb80bc0     	vcvt.f64.s32	d0, s0
   91c94: eeb8cbc1     	vcvt.f64.s32	d12, s2
   91c98: e5950124     	ldr	r0, [r5, #0x124]
   91c9c: ee8a8b0c     	vdiv.f64	d8, d10, d12
   91ca0: ee8bdb00     	vdiv.f64	d13, d11, d0
   91ca4: eeb00b48     	vmov.f64	d0, d8
   91ca8: e12fff30     	blx	r0
   91cac: ed9feb89     	vldr	d14, [pc, #548]         @ 0x91ed8 <.text+0x81dd8>
   91cb0: ed9f1b8a     	vldr	d1, [pc, #552]          @ 0x91ee0 <.text+0x81de0>
   91cb4: eeb4dbce     	vcmpe.f64	d13, d14
   91cb8: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91cbc: eeb09b40     	vmov.f64	d9, d0
   91cc0: ed970a03     	vldr	s0, [r7, #12]
   91cc4: eeb80bc0     	vcvt.f64.s32	d0, s0
   91cc8: e5950124     	ldr	r0, [r5, #0x124]
   91ccc: ceb0db4e     	vmovgt.f64	d13, d14
   91cd0: eeb4dbc1     	vcmpe.f64	d13, d1
   91cd4: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91cd8: 4eb0db41     	vmovmi.f64	d13, d1
   91cdc: e12fff30     	blx	r0
   91ce0: ee8d2b0e     	vdiv.f64	d2, d13, d14
   91ce4: ee200b0c     	vmul.f64	d0, d0, d12
   91ce8: ed9f1b7e     	vldr	d1, [pc, #504]          @ 0x91ee8 <.text+0x81de8>
   91cec: ee293b0c     	vmul.f64	d3, d9, d12
   91cf0: ed9f4b7e     	vldr	d4, [pc, #504]          @ 0x91ef0 <.text+0x81df0>
   91cf4: ee800b01     	vdiv.f64	d0, d0, d1
   91cf8: eeb42bc4     	vcmpe.f64	d2, d4
   91cfc: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91d00: ee831b01     	vdiv.f64	d1, d3, d1
   91d04: 4eb02b44     	vmovmi.f64	d2, d4
   91d08: ee802b02     	vdiv.f64	d2, d0, d2
   91d0c: ed9f3b79     	vldr	d3, [pc, #484]          @ 0x91ef8 <.text+0x81df8>
   91d10: ee200b03     	vmul.f64	d0, d0, d3
   91d14: ed9f3b79     	vldr	d3, [pc, #484]          @ 0x91f00 <.text+0x81e00>
   91d18: eeb41bc3     	vcmpe.f64	d1, d3
   91d1c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91d20: eeb42bc0     	vcmpe.f64	d2, d0
   91d24: ceb03b41     	vmovgt.f64	d3, d1
   91d28: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91d2c: ed9f1b75     	vldr	d1, [pc, #468]          @ 0x91f08 <.text+0x81e08>
   91d30: ceb02b40     	vmovgt.f64	d2, d0
   91d34: ee820b03     	vdiv.f64	d0, d2, d3
   91d38: eeb40bc1     	vcmpe.f64	d0, d1
   91d3c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91d40: 4eb00b41     	vmovmi.f64	d0, d1
   91d44: ed9f1b71     	vldr	d1, [pc, #452]          @ 0x91f10 <.text+0x81e10>
   91d48: eeb40bc1     	vcmpe.f64	d0, d1
   91d4c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91d50: ceb00b41     	vmovgt.f64	d0, d1
   91d54: ee188b00     	vnmls.f64	d8, d8, d0
   91d58: eeb00b48     	vmov.f64	d0, d8
   91d5c: eb140fed     	bl	0x595d18 <.text+0x585c18> @ imm = #0x503fb4
   91d60: e5942000     	ldr	r2, [r4]
   91d64: e3500096     	cmp	r0, #150
   91d68: a3a00096     	movge	r0, #150
   91d6c: e3700096     	cmn	r0, #150
   91d70: e2421001     	sub	r1, r2, #1
   91d74: d3e00095     	mvnle	r0, #149
   91d78: e58d0054     	str	r0, [sp, #0x54]
   91d7c: e35a0001     	cmp	r10, #1
   91d80: e0010192     	mul	r1, r2, r1
   91d84: e1a02000     	mov	r2, r0
   91d88: e16f0f10     	clz	r0, r0
   91d8c: e3a02000     	mov	r2, #0
   91d90: e1a002a0     	lsr	r0, r0, #5
   91d94: b3002001     	movwlt	r2, #0x1
   91d98: e1800002     	orr	r0, r0, r2
   91d9c: e3110001     	tst	r1, #1
   91da0: 0a000039     	beq	0x91e8c <.text+0x81d8c> @ imm = #0xe4
   91da4: e5991000     	ldr	r1, [r9]
   91da8: e3510009     	cmp	r1, #9
   91dac: da000036     	ble	0x91e8c <.text+0x81d8c> @ imm = #0xd8
   91db0: ee008a10     	vmov	s0, r8
   91db4: ee016a10     	vmov	s2, r6
   91db8: eeb80bc0     	vcvt.f64.s32	d0, s0
   91dbc: eeb8cbc1     	vcvt.f64.s32	d12, s2
   91dc0: e5950124     	ldr	r0, [r5, #0x124]
   91dc4: ee8a8b0c     	vdiv.f64	d8, d10, d12
   91dc8: ee8bdb00     	vdiv.f64	d13, d11, d0
   91dcc: eeb00b48     	vmov.f64	d0, d8
   91dd0: e12fff30     	blx	r0
   91dd4: ed9feb3f     	vldr	d14, [pc, #252]         @ 0x91ed8 <.text+0x81dd8>
   91dd8: ed9f1b40     	vldr	d1, [pc, #256]          @ 0x91ee0 <.text+0x81de0>
   91ddc: eeb4dbce     	vcmpe.f64	d13, d14
   91de0: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91de4: eeb09b40     	vmov.f64	d9, d0
   91de8: ed970a03     	vldr	s0, [r7, #12]
   91dec: eeb80bc0     	vcvt.f64.s32	d0, s0
   91df0: e5950124     	ldr	r0, [r5, #0x124]
   91df4: ceb0db4e     	vmovgt.f64	d13, d14
   91df8: eeb4dbc1     	vcmpe.f64	d13, d1
   91dfc: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91e00: 4eb0db41     	vmovmi.f64	d13, d1
   91e04: e12fff30     	blx	r0
   91e08: ee8d2b0e     	vdiv.f64	d2, d13, d14
   91e0c: ee200b0c     	vmul.f64	d0, d0, d12
   91e10: ed9f1b34     	vldr	d1, [pc, #208]          @ 0x91ee8 <.text+0x81de8>
   91e14: ee293b0c     	vmul.f64	d3, d9, d12
   91e18: ed9f4b34     	vldr	d4, [pc, #208]          @ 0x91ef0 <.text+0x81df0>
   91e1c: ee800b01     	vdiv.f64	d0, d0, d1
   91e20: eeb42bc4     	vcmpe.f64	d2, d4
   91e24: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91e28: ee831b01     	vdiv.f64	d1, d3, d1
   91e2c: 4eb02b44     	vmovmi.f64	d2, d4
   91e30: ee802b02     	vdiv.f64	d2, d0, d2
   91e34: ed9f3b2f     	vldr	d3, [pc, #188]          @ 0x91ef8 <.text+0x81df8>
   91e38: ee200b03     	vmul.f64	d0, d0, d3
   91e3c: ed9f3b2f     	vldr	d3, [pc, #188]          @ 0x91f00 <.text+0x81e00>
   91e40: eeb41bc3     	vcmpe.f64	d1, d3
   91e44: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91e48: eeb42bc0     	vcmpe.f64	d2, d0
   91e4c: ceb03b41     	vmovgt.f64	d3, d1
   91e50: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91e54: ed9f1b2b     	vldr	d1, [pc, #172]          @ 0x91f08 <.text+0x81e08>
   91e58: ceb02b40     	vmovgt.f64	d2, d0
   91e5c: ee820b03     	vdiv.f64	d0, d2, d3
   91e60: eeb40bc1     	vcmpe.f64	d0, d1
   91e64: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91e68: 4eb00b41     	vmovmi.f64	d0, d1
   91e6c: ed9f1b27     	vldr	d1, [pc, #156]          @ 0x91f10 <.text+0x81e10>
   91e70: eeb40bc1     	vcmpe.f64	d0, d1
   91e74: eef1fa10     	vmrs	APSR_nzcv, fpscr
   91e78: ceb00b41     	vmovgt.f64	d0, d1
   91e7c: ee188b00     	vnmls.f64	d8, d8, d0
   91e80: eeb00b48     	vmov.f64	d0, d8
   91e84: eb140fa3     	bl	0x595d18 <.text+0x585c18> @ imm = #0x503e8c
   91e88: eaffff7e     	b	0x91c88 <.text+0x81b88> @ imm = #-0x208
   91e8c: e59d603c     	ldr	r6, [sp, #0x3c]
   91e90: e3500000     	cmp	r0, #0
   91e94: 1a0000e0     	bne	0x9221c <.text+0x8211c> @ imm = #0x380
   91e98: e59d0054     	ldr	r0, [sp, #0x54]
   91e9c: e3a07e32     	mov	r7, #800
   91ea0: e59d50c0     	ldr	r5, [sp, #0xc0]
   91ea4: e3a08000     	mov	r8, #0
   91ea8: e3a01000     	mov	r1, #0
   91eac: e0000690     	mul	r0, r0, r6
   91eb0: e58d0028     	str	r0, [sp, #0x28]
   91eb4: e3a00000     	mov	r0, #0
   91eb8: e58d0050     	str	r0, [sp, #0x50]
   91ebc: e3a00000     	mov	r0, #0
   91ec0: e58d004c     	str	r0, [sp, #0x4c]
   91ec4: ea000021     	b	0x91f50 <.text+0x81e50> @ imm = #0x84
   91ec8: 0057facc     	subseq	pc, r7, r12, asr #21
   91ecc: e320f000     	nop
		...
   91edc: 40590000     	subsmi	r0, r9, r0
   91ee0: 00000000     	andeq	r0, r0, r0
   91ee4: 4057c000     	subsmi	r12, r7, r0
   91ee8: 00000000     	andeq	r0, r0, r0
   91eec: 408f4000     	addmi	r4, pc, r0
   91ef0: 47ae147b     	<unknown>
   91ef4: 3f847ae1     	svclo	#0x847ae1
   91ef8: cccccccd     	stclgt	p12, c12, [r12], {205}
   91efc: 3ff0cccc     	svclo	#0xf0cccc
   91f00: e826d695     	stmda	r6!, {r0, r2, r4, r7, r9, r10, r12, lr, pc}
   91f04: 3e112e0b     	cdplo	p14, #0x1, c2, c1, c11, #0x0
   91f08: 00000000     	andeq	r0, r0, r0
   91f0c: 3fe00000     	svclo	#0xe00000
   91f10: cccccccd     	stclgt	p12, c12, [r12], {205}
   91f14: 3ffccccc     	svclo	#0xfccccc
   91f18: 0057fa98     	<unknown>
   91f1c: 0057fa78     	subseq	pc, r7, r8, ror r10
   91f20: 0057fa3c     	subseq	pc, r7, r12, lsr r10
   91f24: e59d8030     	ldr	r8, [sp, #0x30]
   91f28: e3a07e32     	mov	r7, #800
   91f2c: e59d1028     	ldr	r1, [sp, #0x28]
   91f30: e59d50c0     	ldr	r5, [sp, #0xc0]
   91f34: e59da02c     	ldr	r10, [sp, #0x2c]
   91f38: e0888001     	add	r8, r8, r1
   91f3c: e58d0050     	str	r0, [sp, #0x50]
   91f40: e59d1038     	ldr	r1, [sp, #0x38]
   91f44: e2811001     	add	r1, r1, #1
   91f48: e151000a     	cmp	r1, r10
   91f4c: 0a00006d     	beq	0x92108 <.text+0x82008> @ imm = #0x1b4
   91f50: e5950230     	ldr	r0, [r5, #0x230]
   91f54: e0200791     	mla	r0, r1, r7, r0
   91f58: e58d1038     	str	r1, [sp, #0x38]
   91f5c: ebff141a     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3af98
   91f60: e3560001     	cmp	r6, #1
   91f64: bafffff5     	blt	0x91f40 <.text+0x81e40> @ imm = #-0x2c
   91f68: e3500000     	cmp	r0, #0
   91f6c: 0afffff3     	beq	0x91f40 <.text+0x81e40> @ imm = #-0x34
   91f70: e59d1038     	ldr	r1, [sp, #0x38]
   91f74: e3a05000     	mov	r5, #0
   91f78: e51b014c     	ldr	r0, [r11, #-0x14c]
   91f7c: e3a02000     	mov	r2, #0
   91f80: e58d8030     	str	r8, [sp, #0x30]
   91f84: e0811081     	add	r1, r1, r1, lsl #1
   91f88: e0800101     	add	r0, r0, r1, lsl #2
   91f8c: e2808008     	add	r8, r0, #8
   91f90: ea00000b     	b	0x91fc4 <.text+0x81ec4> @ imm = #0x2c
   91f94: 0057fa18     	subseq	pc, r7, r8, lsl r10
   91f98: 0057f9dc     	ldrsbeq	pc, [r7], #-156
   91f9c: 0057f970     	subseq	pc, r7, r0, ror r9
   91fa0: e0811002     	add	r1, r1, r2
   91fa4: e59d2048     	ldr	r2, [sp, #0x48]
   91fa8: e59d603c     	ldr	r6, [sp, #0x3c]
   91fac: e2455001     	sub	r5, r5, #1
   91fb0: e2822001     	add	r2, r2, #1
   91fb4: e58d104c     	str	r1, [sp, #0x4c]
   91fb8: e0961005     	adds	r1, r6, r5
   91fbc: e58d0050     	str	r0, [sp, #0x50]
   91fc0: 0affffd7     	beq	0x91f24 <.text+0x81e24> @ imm = #-0xa4
   91fc4: e5940000     	ldr	r0, [r4]
   91fc8: e58d2048     	str	r2, [sp, #0x48]
   91fcc: e2401001     	sub	r1, r0, #1
   91fd0: e0000190     	mul	r0, r0, r1
   91fd4: e3100001     	tst	r0, #1
   91fd8: 0a000002     	beq	0x91fe8 <.text+0x81ee8> @ imm = #0x8
   91fdc: e5990000     	ldr	r0, [r9]
   91fe0: e3500009     	cmp	r0, #9
   91fe4: ca000022     	bgt	0x92074 <.text+0x81f74> @ imm = #0x88
   91fe8: e5980000     	ldr	r0, [r8]
   91fec: e710a105     	ldr	r10, [r0, -r5, lsl #2]
   91ff0: e59d0054     	ldr	r0, [sp, #0x54]
   91ff4: e08a6000     	add	r6, r10, r0
   91ff8: e59d00bc     	ldr	r0, [sp, #0xbc]
   91ffc: e1a01006     	mov	r1, r6
   92000: ebfef933     	bl	0x504d4 <.text+0x403d4> @ imm = #-0x41b34
   92004: e1a07000     	mov	r7, r0
   92008: e59d00c0     	ldr	r0, [sp, #0xc0]
   9200c: e5900018     	ldr	r0, [r0, #0x18]
   92010: e5900000     	ldr	r0, [r0]
   92014: e59f1fbc     	ldr	r1, [pc, #0xfbc]        @ 0x92fd8 <.text+0x82ed8>
   92018: e08f1001     	add	r1, pc, r1
   9201c: eb1445ce     	bl	0x5a375c <.text+0x59365c> @ imm = #0x511738
   92020: e30011c3     	movw	r1, #0x1c3
   92024: e1570001     	cmp	r7, r1
   92028: e30011c3     	movw	r1, #0x1c3
   9202c: e5982000     	ldr	r2, [r8]
   92030: b1a01007     	movlt	r1, r7
   92034: e3500000     	cmp	r0, #0
   92038: 11a01007     	movne	r1, r7
   9203c: e59d0050     	ldr	r0, [sp, #0x50]
   92040: e7021105     	str	r1, [r2, -r5, lsl #2]
   92044: e1510006     	cmp	r1, r6
   92048: 12800001     	addne	r0, r0, #1
   9204c: e5942000     	ldr	r2, [r4]
   92050: e2423001     	sub	r3, r2, #1
   92054: e0030392     	mul	r3, r2, r3
   92058: e59d204c     	ldr	r2, [sp, #0x4c]
   9205c: e042200a     	sub	r2, r2, r10
   92060: e3130001     	tst	r3, #1
   92064: 0affffcd     	beq	0x91fa0 <.text+0x81ea0> @ imm = #-0xcc
   92068: e5993000     	ldr	r3, [r9]
   9206c: e3530009     	cmp	r3, #9
   92070: daffffca     	ble	0x91fa0 <.text+0x81ea0> @ imm = #-0xd8
   92074: e5980000     	ldr	r0, [r8]
   92078: e59d1054     	ldr	r1, [sp, #0x54]
   9207c: e7100105     	ldr	r0, [r0, -r5, lsl #2]
   92080: e0801001     	add	r1, r0, r1
   92084: e59d00bc     	ldr	r0, [sp, #0xbc]
   92088: ebfef911     	bl	0x504d4 <.text+0x403d4> @ imm = #-0x41bbc
   9208c: e1a06000     	mov	r6, r0
   92090: e59d00c0     	ldr	r0, [sp, #0xc0]
   92094: e5900018     	ldr	r0, [r0, #0x18]
   92098: e5900000     	ldr	r0, [r0]
   9209c: e59f1f9c     	ldr	r1, [pc, #0xf9c]        @ 0x93040 <.text+0x82f40>
   920a0: e08f1001     	add	r1, pc, r1
   920a4: eb1445ac     	bl	0x5a375c <.text+0x59365c> @ imm = #0x5116b0
   920a8: e30021c3     	movw	r2, #0x1c3
   920ac: e1560002     	cmp	r6, r2
   920b0: e30021c3     	movw	r2, #0x1c3
   920b4: e5981000     	ldr	r1, [r8]
   920b8: b1a02006     	movlt	r2, r6
   920bc: e3500000     	cmp	r0, #0
   920c0: 11a02006     	movne	r2, r6
   920c4: e7012105     	str	r2, [r1, -r5, lsl #2]
   920c8: eaffffc6     	b	0x91fe8 <.text+0x81ee8> @ imm = #-0xe8
   920cc: 0057f8f8     	ldrsheq	pc, [r7], #-136
   920d0: 00555db7     	ldrheq	r5, [r5], #-215
   920d4: 00555d21     	subseq	r5, r5, r1, lsr #26
   920d8: 00555d47     	subseq	r5, r5, r7, asr #26
   920dc: 00556451     	subseq	r6, r5, r1, asr r4
   920e0: 0057f874     	subseq	pc, r7, r4, ror r8
   920e4: 00555d4f     	subseq	r5, r5, pc, asr #26
   920e8: 00555cb9     	ldrheq	r5, [r5], #-201
   920ec: 00555cdf     	ldrsbeq	r5, [r5], #-207
   920f0: 005562a4     	subseq	r6, r5, r4, lsr #5
   920f4: 00581838     	subseq	r1, r8, r8, lsr r8
   920f8: 00555cd7     	ldrsbeq	r5, [r5], #-199
   920fc: 00555c41     	subseq	r5, r5, r1, asr #24
   92100: 00555c67     	subseq	r5, r5, r7, ror #24
   92104: 0055622c     	subseq	r6, r5, r12, lsr #4
   92108: e5940000     	ldr	r0, [r4]
   9210c: e2401001     	sub	r1, r0, #1
   92110: e0000190     	mul	r0, r0, r1
   92114: e3100001     	tst	r0, #1
   92118: e5940000     	ldr	r0, [r4]
   9211c: e2401001     	sub	r1, r0, #1
   92120: e0000190     	mul	r0, r0, r1
   92124: e3100001     	tst	r0, #1
   92128: 0a000002     	beq	0x92138 <.text+0x82038> @ imm = #0x8
   9212c: e5990000     	ldr	r0, [r9]
   92130: e3500009     	cmp	r0, #9
   92134: cafffff7     	bgt	0x92118 <.text+0x82018> @ imm = #-0x24
   92138: e59d004c     	ldr	r0, [sp, #0x4c]
   9213c: e1580000     	cmp	r8, r0
   92140: 0a000035     	beq	0x9221c <.text+0x8211c> @ imm = #0xd4
   92144: e5940000     	ldr	r0, [r4]
   92148: e59f5fa0     	ldr	r5, [pc, #0xfa0]        @ 0x930f0 <.text+0x82ff0>
   9214c: e2401001     	sub	r1, r0, #1
   92150: e08f5005     	add	r5, pc, r5
   92154: e0000190     	mul	r0, r0, r1
   92158: e3100001     	tst	r0, #1
   9215c: 0a000002     	beq	0x9216c <.text+0x8206c> @ imm = #0x8
   92160: e5990000     	ldr	r0, [r9]
   92164: e3500009     	cmp	r0, #9
   92168: ca000018     	bgt	0x921d0 <.text+0x820d0> @ imm = #0x60
   9216c: e59f0fcc     	ldr	r0, [pc, #0xfcc]        @ 0x93140 <.text+0x83040>
   92170: e3a07003     	mov	r7, #3
   92174: e59f1fc8     	ldr	r1, [pc, #0xfc8]        @ 0x93144 <.text+0x83044>
   92178: e59f2fc8     	ldr	r2, [pc, #0xfc8]        @ 0x93148 <.text+0x83048>
   9217c: e08f0000     	add	r0, pc, r0
   92180: e59d604c     	ldr	r6, [sp, #0x4c]
   92184: e08f1001     	add	r1, pc, r1
   92188: e58d7000     	str	r7, [sp]
   9218c: e08f2002     	add	r2, pc, r2
   92190: e0483006     	sub	r3, r8, r6
   92194: e98d0120     	stmib	sp, {r5, r8}
   92198: e58d3010     	str	r3, [sp, #0x10]
   9219c: e59d3050     	ldr	r3, [sp, #0x50]
   921a0: e58d3014     	str	r3, [sp, #0x14]
   921a4: e3003f53     	movw	r3, #0xf53
   921a8: e58d600c     	str	r6, [sp, #0xc]
   921ac: eb019fc4     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x67f10
   921b0: e5940000     	ldr	r0, [r4]
   921b4: e2401001     	sub	r1, r0, #1
   921b8: e0000190     	mul	r0, r0, r1
   921bc: e3100001     	tst	r0, #1
   921c0: 0a000015     	beq	0x9221c <.text+0x8211c> @ imm = #0x54
   921c4: e5990000     	ldr	r0, [r9]
   921c8: e3500009     	cmp	r0, #9
   921cc: da000012     	ble	0x9221c <.text+0x8211c> @ imm = #0x48
   921d0: e59f0fb0     	ldr	r0, [pc, #0xfb0]        @ 0x93188 <.text+0x83088>
   921d4: e3a07003     	mov	r7, #3
   921d8: e59f1fac     	ldr	r1, [pc, #0xfac]        @ 0x9318c <.text+0x8308c>
   921dc: e59f2fac     	ldr	r2, [pc, #0xfac]        @ 0x93190 <.text+0x83090>
   921e0: e08f0000     	add	r0, pc, r0
   921e4: e59d604c     	ldr	r6, [sp, #0x4c]
   921e8: e08f1001     	add	r1, pc, r1
   921ec: e58d7000     	str	r7, [sp]
   921f0: e08f2002     	add	r2, pc, r2
   921f4: e0483006     	sub	r3, r8, r6
   921f8: e98d0120     	stmib	sp, {r5, r8}
   921fc: e58d3010     	str	r3, [sp, #0x10]
   92200: e59d3050     	ldr	r3, [sp, #0x50]
   92204: e58d3014     	str	r3, [sp, #0x14]
   92208: e3003f53     	movw	r3, #0xf53
   9220c: e58d600c     	str	r6, [sp, #0xc]
   92210: eb019fab     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x67eac
   92214: eaffffd4     	b	0x9216c <.text+0x8206c> @ imm = #-0xb0
   92218: 005817d0     	ldrsbeq	r1, [r8], #-112
   9221c: e59d00c0     	ldr	r0, [sp, #0xc0]
   92220: e5900018     	ldr	r0, [r0, #0x18]
   92224: eb0053f8     	bl	0xa720c <.text+0x9710c> @ imm = #0x14fe0
   92228: e1a08000     	mov	r8, r0
   9222c: eb01b10d     	bl	0xfe668 <.text+0xee568> @ imm = #0x6c434
   92230: e51b1154     	ldr	r1, [r11, #-0x154]
   92234: e3500001     	cmp	r0, #1
   92238: e59fef54     	ldr	lr, [pc, #0xf54]        @ 0x93194 <.text+0x83094>
   9223c: e08fe00e     	add	lr, pc, lr
   92240: e58e1008     	str	r1, [lr, #0x8]
   92244: ba00004f     	blt	0x92388 <.text+0x82288> @ imm = #0x13c
   92248: e5941000     	ldr	r1, [r4]
   9224c: e2412001     	sub	r2, r1, #1
   92250: e0010291     	mul	r1, r1, r2
   92254: e3110001     	tst	r1, #1
   92258: e5941000     	ldr	r1, [r4]
   9225c: e2412001     	sub	r2, r1, #1
   92260: e0010291     	mul	r1, r1, r2
   92264: e5982010     	ldr	r2, [r8, #0x10]
   92268: e3110001     	tst	r1, #1
   9226c: 0a000002     	beq	0x9227c <.text+0x8217c> @ imm = #0x8
   92270: e5991000     	ldr	r1, [r9]
   92274: e3510009     	cmp	r1, #9
   92278: cafffff6     	bgt	0x92258 <.text+0x82158> @ imm = #-0x28
   9227c: e3a0c000     	mov	r12, #0
   92280: e3520001     	cmp	r2, #1
   92284: aa000006     	bge	0x922a4 <.text+0x821a4> @ imm = #0x18
   92288: ea000031     	b	0x92354 <.text+0x82254> @ imm = #0xc4
   9228c: 0057f720     	subseq	pc, r7, r0, lsr #14
   92290: e28cc001     	add	r12, r12, #1
   92294: e15c0000     	cmp	r12, r0
   92298: 0a00003a     	beq	0x92388 <.text+0x82288> @ imm = #0xe8
   9229c: e3520001     	cmp	r2, #1
   922a0: ba00002b     	blt	0x92354 <.text+0x82254> @ imm = #0xac
   922a4: e59e2020     	ldr	r2, [lr, #0x20]
   922a8: e08c310c     	add	r3, r12, r12, lsl #2
   922ac: e3a06000     	mov	r6, #0
   922b0: e3a05000     	mov	r5, #0
   922b4: e0822183     	add	r2, r2, r3, lsl #3
   922b8: e2823020     	add	r3, r2, #32
   922bc: ea000003     	b	0x922d0 <.text+0x821d0> @ imm = #0xc
   922c0: e2866038     	add	r6, r6, #56
   922c4: e1570002     	cmp	r7, r2
   922c8: e1a05007     	mov	r5, r7
   922cc: aa000020     	bge	0x92354 <.text+0x82254> @ imm = #0x80
   922d0: e5942000     	ldr	r2, [r4]
   922d4: e2427001     	sub	r7, r2, #1
   922d8: e0020792     	mul	r2, r2, r7
   922dc: e3120001     	tst	r2, #1
   922e0: 0a000002     	beq	0x922f0 <.text+0x821f0> @ imm = #0x8
   922e4: e5992000     	ldr	r2, [r9]
   922e8: e3520009     	cmp	r2, #9
   922ec: ca000010     	bgt	0x92334 <.text+0x82234> @ imm = #0x40
   922f0: e51b214c     	ldr	r2, [r11, #-0x14c]
   922f4: e08c708c     	add	r7, r12, r12, lsl #1
   922f8: e0822107     	add	r2, r2, r7, lsl #2
   922fc: e5937000     	ldr	r7, [r3]
   92300: e5922008     	ldr	r2, [r2, #0x8]
   92304: e7922105     	ldr	r2, [r2, r5, lsl #2]
   92308: e7872006     	str	r2, [r7, r6]
   9230c: e5942000     	ldr	r2, [r4]
   92310: e2427001     	sub	r7, r2, #1
   92314: e0010792     	mul	r1, r2, r7
   92318: e5982010     	ldr	r2, [r8, #0x10]
   9231c: e2857001     	add	r7, r5, #1
   92320: e3110001     	tst	r1, #1
   92324: 0affffe5     	beq	0x922c0 <.text+0x821c0> @ imm = #-0x6c
   92328: e5991000     	ldr	r1, [r9]
   9232c: e3510009     	cmp	r1, #9
   92330: daffffe2     	ble	0x922c0 <.text+0x821c0> @ imm = #-0x78
   92334: e51b114c     	ldr	r1, [r11, #-0x14c]
   92338: e08c208c     	add	r2, r12, r12, lsl #1
   9233c: e0811102     	add	r1, r1, r2, lsl #2
   92340: e5932000     	ldr	r2, [r3]
   92344: e5911008     	ldr	r1, [r1, #0x8]
   92348: e7911105     	ldr	r1, [r1, r5, lsl #2]
   9234c: e7821006     	str	r1, [r2, r6]
   92350: eaffffe6     	b	0x922f0 <.text+0x821f0> @ imm = #-0x68
   92354: e5941000     	ldr	r1, [r4]
   92358: e2413001     	sub	r3, r1, #1
   9235c: e0010391     	mul	r1, r1, r3
   92360: e3110001     	tst	r1, #1
   92364: e5941000     	ldr	r1, [r4]
   92368: e2413001     	sub	r3, r1, #1
   9236c: e0010391     	mul	r1, r1, r3
   92370: e3110001     	tst	r1, #1
   92374: 0affffc5     	beq	0x92290 <.text+0x82190> @ imm = #-0xec
   92378: e5991000     	ldr	r1, [r9]
   9237c: e3510009     	cmp	r1, #9
   92380: cafffff7     	bgt	0x92364 <.text+0x82264> @ imm = #-0x24
   92384: eaffffc1     	b	0x92290 <.text+0x82190> @ imm = #-0xfc
   92388: e3a00d81     	mov	r0, #8256
   9238c: e3a05000     	mov	r5, #0
   92390: e1a0100e     	mov	r1, lr
   92394: e7a15000     	str	r5, [r1, r0]!
   92398: e5815004     	str	r5, [r1, #0x4]
   9239c: eb01b0b1     	bl	0xfe668 <.text+0xee568> @ imm = #0x6c2c4
   923a0: e3500001     	cmp	r0, #1
   923a4: ba000052     	blt	0x924f4 <.text+0x823f4> @ imm = #0x148
   923a8: e59d0024     	ldr	r0, [sp, #0x24]
   923ac: e3a0a001     	mov	r10, #1
   923b0: e3a06010     	mov	r6, #16
   923b4: e3a08000     	mov	r8, #0
   923b8: e3a07000     	mov	r7, #0
   923bc: e2800040     	add	r0, r0, #64
   923c0: e58d0054     	str	r0, [sp, #0x54]
   923c4: ea000006     	b	0x923e4 <.text+0x822e4> @ imm = #0x18
   923c8: e28a1001     	add	r1, r10, #1
   923cc: e2877001     	add	r7, r7, #1
   923d0: e2866028     	add	r6, r6, #40
   923d4: e2855e32     	add	r5, r5, #800
   923d8: e15a0000     	cmp	r10, r0
   923dc: e1a0a001     	mov	r10, r1
   923e0: aa000039     	bge	0x924cc <.text+0x823cc> @ imm = #0xe4
   923e4: e5940000     	ldr	r0, [r4]
   923e8: e2401001     	sub	r1, r0, #1
   923ec: e0000190     	mul	r0, r0, r1
   923f0: e3100001     	tst	r0, #1
   923f4: 0a000002     	beq	0x92404 <.text+0x82304> @ imm = #0x8
   923f8: e5990000     	ldr	r0, [r9]
   923fc: e3500009     	cmp	r0, #9
   92400: ca00000b     	bgt	0x92434 <.text+0x82334> @ imm = #0x2c
   92404: e59d00c0     	ldr	r0, [sp, #0xc0]
   92408: e5900230     	ldr	r0, [r0, #0x230]
   9240c: e0800005     	add	r0, r0, r5
   92410: ebff12ed     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3b44c
   92414: e5941000     	ldr	r1, [r4]
   92418: e2412001     	sub	r2, r1, #1
   9241c: e0010291     	mul	r1, r1, r2
   92420: e3110001     	tst	r1, #1
   92424: 0a000008     	beq	0x9244c <.text+0x8234c> @ imm = #0x20
   92428: e5991000     	ldr	r1, [r9]
   9242c: e3510009     	cmp	r1, #9
   92430: da000005     	ble	0x9244c <.text+0x8234c> @ imm = #0x14
   92434: e59d00c0     	ldr	r0, [sp, #0xc0]
   92438: e5900230     	ldr	r0, [r0, #0x230]
   9243c: e0800005     	add	r0, r0, r5
   92440: ebff12e1     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3b47c
   92444: eaffffee     	b	0x92404 <.text+0x82304> @ imm = #-0x48
   92448: 0057f550     	subseq	pc, r7, r0, asr r5
   9244c: e3500000     	cmp	r0, #0
   92450: 0a00000a     	beq	0x92480 <.text+0x82380> @ imm = #0x28
   92454: e59d0054     	ldr	r0, [sp, #0x54]
   92458: e2888001     	add	r8, r8, #1
   9245c: e5900000     	ldr	r0, [r0]
   92460: e0800006     	add	r0, r0, r6
   92464: ed900b00     	vldr	d0, [r0]
   92468: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x93468 <.text+0x83368>
   9246c: e08f0000     	add	r0, pc, r0
   92470: e2800d81     	add	r0, r0, #8256
   92474: ed901b00     	vldr	d1, [r0]
   92478: ee300b01     	vadd.f64	d0, d0, d1
   9247c: ed800b00     	vstr	d0, [r0]
   92480: e5940000     	ldr	r0, [r4]
   92484: e2401001     	sub	r1, r0, #1
   92488: e0000190     	mul	r0, r0, r1
   9248c: e3100001     	tst	r0, #1
   92490: 0a000002     	beq	0x924a0 <.text+0x823a0> @ imm = #0x8
   92494: e5990000     	ldr	r0, [r9]
   92498: e3500009     	cmp	r0, #9
   9249c: ca000008     	bgt	0x924c4 <.text+0x823c4> @ imm = #0x20
   924a0: eb01b070     	bl	0xfe668 <.text+0xee568> @ imm = #0x6c1c0
   924a4: e5941000     	ldr	r1, [r4]
   924a8: e2412001     	sub	r2, r1, #1
   924ac: e0010291     	mul	r1, r1, r2
   924b0: e3110001     	tst	r1, #1
   924b4: 0affffc3     	beq	0x923c8 <.text+0x822c8> @ imm = #-0xf4
   924b8: e5991000     	ldr	r1, [r9]
   924bc: e3510009     	cmp	r1, #9
   924c0: daffffc0     	ble	0x923c8 <.text+0x822c8> @ imm = #-0x100
   924c4: eb01b067     	bl	0xfe668 <.text+0xee568> @ imm = #0x6c19c
   924c8: eafffff4     	b	0x924a0 <.text+0x823a0> @ imm = #-0x30
   924cc: e3580001     	cmp	r8, #1
   924d0: ba000007     	blt	0x924f4 <.text+0x823f4> @ imm = #0x1c
   924d4: ee008a10     	vmov	s0, r8
   924d8: eeb80bc0     	vcvt.f64.s32	d0, s0
   924dc: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x934b8 <.text+0x833b8>
   924e0: e08f0000     	add	r0, pc, r0
   924e4: e2800d81     	add	r0, r0, #8256
   924e8: ed901b00     	vldr	d1, [r0]
   924ec: ee810b00     	vdiv.f64	d0, d1, d0
   924f0: ed800b00     	vstr	d0, [r0]
   924f4: e59d50c0     	ldr	r5, [sp, #0xc0]
   924f8: e24b1f56     	sub	r1, r11, #344
   924fc: e1a00005     	mov	r0, r5
   92500: ebffd183     	bl	0x86b14 <.text+0x76a14> @ imm = #-0xb9f4
   92504: e3500000     	cmp	r0, #0
   92508: 0a00000c     	beq	0x92540 <.text+0x82440> @ imm = #0x30
   9250c: e59f0fa8     	ldr	r0, [pc, #0xfa8]        @ 0x934bc <.text+0x833bc>
   92510: e3a07001     	mov	r7, #1
   92514: e59f1fa4     	ldr	r1, [pc, #0xfa4]        @ 0x934c0 <.text+0x833c0>
   92518: e59f2fa4     	ldr	r2, [pc, #0xfa4]        @ 0x934c4 <.text+0x833c4>
   9251c: e08f0000     	add	r0, pc, r0
   92520: e59f3fa0     	ldr	r3, [pc, #0xfa0]        @ 0x934c8 <.text+0x833c8>
   92524: e08f1001     	add	r1, pc, r1
   92528: e08f2002     	add	r2, pc, r2
   9252c: e58d7000     	str	r7, [sp]
   92530: e08f3003     	add	r3, pc, r3
   92534: e58d3004     	str	r3, [sp, #0x4]
   92538: e301341b     	movw	r3, #0x141b
   9253c: eaffe83a     	b	0x8c62c <.text+0x7c52c> @ imm = #-0x5f18
   92540: e51b614c     	ldr	r6, [r11, #-0x14c]
   92544: e3560000     	cmp	r6, #0
   92548: 0a000069     	beq	0x926f4 <.text+0x825f4> @ imm = #0x1a4
   9254c: e5940000     	ldr	r0, [r4]
   92550: e2401001     	sub	r1, r0, #1
   92554: e0000190     	mul	r0, r0, r1
   92558: e3100001     	tst	r0, #1
   9255c: e5940000     	ldr	r0, [r4]
   92560: e51b5148     	ldr	r5, [r11, #-0x148]
   92564: e2401001     	sub	r1, r0, #1
   92568: e0000190     	mul	r0, r0, r1
   9256c: e3100001     	tst	r0, #1
   92570: 0a000002     	beq	0x92580 <.text+0x82480> @ imm = #0x8
   92574: e5990000     	ldr	r0, [r9]
   92578: e3500009     	cmp	r0, #9
   9257c: cafffff6     	bgt	0x9255c <.text+0x8245c> @ imm = #-0x28
   92580: e3550001     	cmp	r5, #1
   92584: ba000028     	blt	0x9262c <.text+0x8252c> @ imm = #0xa0
   92588: e2866008     	add	r6, r6, #8
   9258c: e3a08000     	mov	r8, #0
   92590: e3a07000     	mov	r7, #0
   92594: ea000003     	b	0x925a8 <.text+0x824a8> @ imm = #0xc
   92598: e2877001     	add	r7, r7, #1
   9259c: e286600c     	add	r6, r6, #12
   925a0: e2555001     	subs	r5, r5, #1
   925a4: 0a00001d     	beq	0x92620 <.text+0x82520> @ imm = #0x74
   925a8: e5940000     	ldr	r0, [r4]
   925ac: e2401001     	sub	r1, r0, #1
   925b0: e0000190     	mul	r0, r0, r1
   925b4: e3100001     	tst	r0, #1
   925b8: e5940000     	ldr	r0, [r4]
   925bc: e2401001     	sub	r1, r0, #1
   925c0: e0010190     	mul	r1, r0, r1
   925c4: e5960000     	ldr	r0, [r6]
   925c8: e3110001     	tst	r1, #1
   925cc: 0a000002     	beq	0x925dc <.text+0x824dc> @ imm = #0x8
   925d0: e5991000     	ldr	r1, [r9]
   925d4: e3510009     	cmp	r1, #9
   925d8: cafffff6     	bgt	0x925b8 <.text+0x824b8> @ imm = #-0x28
   925dc: e3500000     	cmp	r0, #0
   925e0: 0a000001     	beq	0x925ec <.text+0x824ec> @ imm = #0x4
   925e4: eb1405a8     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x5016a0
   925e8: e5868000     	str	r8, [r6]
   925ec: e5940000     	ldr	r0, [r4]
   925f0: e2401001     	sub	r1, r0, #1
   925f4: e0000190     	mul	r0, r0, r1
   925f8: e3100001     	tst	r0, #1
   925fc: e5940000     	ldr	r0, [r4]
   92600: e2401001     	sub	r1, r0, #1
   92604: e0000190     	mul	r0, r0, r1
   92608: e3100001     	tst	r0, #1
   9260c: 0affffe1     	beq	0x92598 <.text+0x82498> @ imm = #-0x7c
   92610: e5990000     	ldr	r0, [r9]
   92614: e3500009     	cmp	r0, #9
   92618: cafffff7     	bgt	0x925fc <.text+0x824fc> @ imm = #-0x24
   9261c: eaffffdd     	b	0x92598 <.text+0x82498> @ imm = #-0x8c
   92620: e51b614c     	ldr	r6, [r11, #-0x14c]
   92624: e3560000     	cmp	r6, #0
   92628: 0a00001a     	beq	0x92698 <.text+0x82598> @ imm = #0x68
   9262c: e5940000     	ldr	r0, [r4]
   92630: e2401001     	sub	r1, r0, #1
   92634: e0000190     	mul	r0, r0, r1
   92638: e3100001     	tst	r0, #1
   9263c: 0a000002     	beq	0x9264c <.text+0x8254c> @ imm = #0x8
   92640: e5990000     	ldr	r0, [r9]
   92644: e3500009     	cmp	r0, #9
   92648: ca00000b     	bgt	0x9267c <.text+0x8257c> @ imm = #0x2c
   9264c: e1a00006     	mov	r0, r6
   92650: eb14058d     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x501634
   92654: e5940000     	ldr	r0, [r4]
   92658: e3a02000     	mov	r2, #0
   9265c: e50b214c     	str	r2, [r11, #-0x14c]
   92660: e2401001     	sub	r1, r0, #1
   92664: e0010190     	mul	r1, r0, r1
   92668: e5990000     	ldr	r0, [r9]
   9266c: e3110001     	tst	r1, #1
   92670: 0a000008     	beq	0x92698 <.text+0x82598> @ imm = #0x20
   92674: e3500009     	cmp	r0, #9
   92678: da000006     	ble	0x92698 <.text+0x82598> @ imm = #0x18
   9267c: e1a00006     	mov	r0, r6
   92680: eb140581     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x501604
   92684: e3a00000     	mov	r0, #0
   92688: e50b014c     	str	r0, [r11, #-0x14c]
   9268c: eaffffee     	b	0x9264c <.text+0x8254c> @ imm = #-0x48
   92690: 0057f320     	subseq	pc, r7, r0, lsr #6
   92694: 0057f2e8     	subseq	pc, r7, r8, ror #5
   92698: e5940000     	ldr	r0, [r4]
   9269c: e2401001     	sub	r1, r0, #1
   926a0: e0000190     	mul	r0, r0, r1
   926a4: e3100001     	tst	r0, #1
   926a8: 0a000002     	beq	0x926b8 <.text+0x825b8> @ imm = #0x8
   926ac: e5990000     	ldr	r0, [r9]
   926b0: e3500009     	cmp	r0, #9
   926b4: ca000009     	bgt	0x926e0 <.text+0x825e0> @ imm = #0x24
   926b8: e5940000     	ldr	r0, [r4]
   926bc: e3a02000     	mov	r2, #0
   926c0: e50b214c     	str	r2, [r11, #-0x14c]
   926c4: e2401001     	sub	r1, r0, #1
   926c8: e0010190     	mul	r1, r0, r1
   926cc: e5990000     	ldr	r0, [r9]
   926d0: e3110001     	tst	r1, #1
   926d4: 0a000006     	beq	0x926f4 <.text+0x825f4> @ imm = #0x18
   926d8: e3500009     	cmp	r0, #9
   926dc: da000004     	ble	0x926f4 <.text+0x825f4> @ imm = #0x10
   926e0: e3a00000     	mov	r0, #0
   926e4: e50b014c     	str	r0, [r11, #-0x14c]
   926e8: eafffff2     	b	0x926b8 <.text+0x825b8> @ imm = #-0x38
   926ec: 0057f2c4     	subseq	pc, r7, r4, asr #5
   926f0: 0057f2a8     	subseq	pc, r7, r8, lsr #5
   926f4: e5940000     	ldr	r0, [r4]
   926f8: e2401001     	sub	r1, r0, #1
   926fc: e0000190     	mul	r0, r0, r1
   92700: e3100001     	tst	r0, #1
   92704: 0a000002     	beq	0x92714 <.text+0x82614> @ imm = #0x8
   92708: e5990000     	ldr	r0, [r9]
   9270c: e3500009     	cmp	r0, #9
   92710: ca00000a     	bgt	0x92740 <.text+0x82640> @ imm = #0x28
   92714: e3a00005     	mov	r0, #5
   92718: e3a01000     	mov	r1, #0
   9271c: eb000a34     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x28d0
   92720: e5940000     	ldr	r0, [r4]
   92724: e2401001     	sub	r1, r0, #1
   92728: e0000190     	mul	r0, r0, r1
   9272c: e3100001     	tst	r0, #1
   92730: 0a0004e0     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x1380
   92734: e5990000     	ldr	r0, [r9]
   92738: e350000a     	cmp	r0, #10
   9273c: ba0004dd     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x1374
   92740: e3a00005     	mov	r0, #5
   92744: e3a01000     	mov	r1, #0
   92748: eb000a29     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x28a4
   9274c: eafffff0     	b	0x92714 <.text+0x82614> @ imm = #-0x40
   92750: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0x9372c <.text+0x8362c>
   92754: e3a03001     	mov	r3, #1
   92758: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x93730 <.text+0x83630>
   9275c: e59f2fd0     	ldr	r2, [pc, #0xfd0]        @ 0x93734 <.text+0x83634>
   92760: e08f0000     	add	r0, pc, r0
   92764: e08f1001     	add	r1, pc, r1
   92768: e88d0028     	stm	sp, {r3, r5}
   9276c: e08f2002     	add	r2, pc, r2
   92770: e301343f     	movw	r3, #0x143f
   92774: eb019e52     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x67948
   92778: e59d00b8     	ldr	r0, [sp, #0xb8]
   9277c: e3001fa1     	movw	r1, #0xfa1
   92780: ebfedd44     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x48af0
   92784: e5940000     	ldr	r0, [r4]
   92788: e2401001     	sub	r1, r0, #1
   9278c: e0000190     	mul	r0, r0, r1
   92790: e3100001     	tst	r0, #1
   92794: 0a0004c7     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x131c
   92798: e5990000     	ldr	r0, [r9]
   9279c: e350000a     	cmp	r0, #10
   927a0: ba0004c4     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x1310
   927a4: e59f0f8c     	ldr	r0, [pc, #0xf8c]        @ 0x93738 <.text+0x83638>
   927a8: e3a03001     	mov	r3, #1
   927ac: e59f1ffc     	ldr	r1, [pc, #0xffc]        @ 0x937b0 <.text+0x836b0>
   927b0: e59f2ffc     	ldr	r2, [pc, #0xffc]        @ 0x937b4 <.text+0x836b4>
   927b4: e08f0000     	add	r0, pc, r0
   927b8: e08f1001     	add	r1, pc, r1
   927bc: e88d0028     	stm	sp, {r3, r5}
   927c0: e08f2002     	add	r2, pc, r2
   927c4: e301343f     	movw	r3, #0x143f
   927c8: eb019e3d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x678f4
   927cc: e59d00b8     	ldr	r0, [sp, #0xb8]
   927d0: e3001fa1     	movw	r1, #0xfa1
   927d4: ebfedd2f     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x48b44
   927d8: eaffffdc     	b	0x92750 <.text+0x82650> @ imm = #-0x90
   927dc: 0057f1ec     	subseq	pc, r7, r12, ror #3
   927e0: e1a00005     	mov	r0, r5
   927e4: eb00135f     	bl	0x97568 <.text+0x87468> @ imm = #0x4d7c
   927e8: e5941000     	ldr	r1, [r4]
   927ec: e2412001     	sub	r2, r1, #1
   927f0: e0010291     	mul	r1, r1, r2
   927f4: e3110001     	tst	r1, #1
   927f8: 0a000006     	beq	0x92818 <.text+0x82718> @ imm = #0x18
   927fc: e5991000     	ldr	r1, [r9]
   92800: e3510009     	cmp	r1, #9
   92804: da000003     	ble	0x92818 <.text+0x82718> @ imm = #0xc
   92808: e1a00005     	mov	r0, r5
   9280c: eb001355     	bl	0x97568 <.text+0x87468> @ imm = #0x4d54
   92810: eafffff2     	b	0x927e0 <.text+0x826e0> @ imm = #-0x38
   92814: 0057f19c     	<unknown>
   92818: e3500000     	cmp	r0, #0
   9281c: 0a0000c3     	beq	0x92b30 <.text+0x82a30> @ imm = #0x30c
   92820: e5950018     	ldr	r0, [r5, #0x18]
   92824: eb005278     	bl	0xa720c <.text+0x9710c> @ imm = #0x149e0
   92828: eb01af8e     	bl	0xfe668 <.text+0xee568> @ imm = #0x6be38
   9282c: e3500001     	cmp	r0, #1
   92830: ba000024     	blt	0x928c8 <.text+0x827c8> @ imm = #0x90
   92834: e1a06000     	mov	r6, r0
   92838: e3a05000     	mov	r5, #0
   9283c: e3a07000     	mov	r7, #0
   92840: ea000003     	b	0x92854 <.text+0x82754> @ imm = #0xc
   92844: e2877001     	add	r7, r7, #1
   92848: e2855e32     	add	r5, r5, #800
   9284c: e2566001     	subs	r6, r6, #1
   92850: 0a00001c     	beq	0x928c8 <.text+0x827c8> @ imm = #0x70
   92854: e5940000     	ldr	r0, [r4]
   92858: e2401001     	sub	r1, r0, #1
   9285c: e0000190     	mul	r0, r0, r1
   92860: e3100001     	tst	r0, #1
   92864: 0a000002     	beq	0x92874 <.text+0x82774> @ imm = #0x8
   92868: e5990000     	ldr	r0, [r9]
   9286c: e3500009     	cmp	r0, #9
   92870: ca00000b     	bgt	0x928a4 <.text+0x827a4> @ imm = #0x2c
   92874: e59d00c0     	ldr	r0, [sp, #0xc0]
   92878: e5900230     	ldr	r0, [r0, #0x230]
   9287c: e0800005     	add	r0, r0, r5
   92880: ebff11d1     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3b8bc
   92884: e5940000     	ldr	r0, [r4]
   92888: e2401001     	sub	r1, r0, #1
   9288c: e0000190     	mul	r0, r0, r1
   92890: e3100001     	tst	r0, #1
   92894: 0affffea     	beq	0x92844 <.text+0x82744> @ imm = #-0x58
   92898: e5990000     	ldr	r0, [r9]
   9289c: e3500009     	cmp	r0, #9
   928a0: daffffe7     	ble	0x92844 <.text+0x82744> @ imm = #-0x64
   928a4: e59d00c0     	ldr	r0, [sp, #0xc0]
   928a8: e5900230     	ldr	r0, [r0, #0x230]
   928ac: e0800005     	add	r0, r0, r5
   928b0: ebff11c5     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3b8ec
   928b4: eaffffee     	b	0x92874 <.text+0x82774> @ imm = #-0x48
   928b8: 00555573     	subseq	r5, r5, r3, ror r5
   928bc: 005554dd     	ldrsbeq	r5, [r5], #-77
   928c0: 00555503     	subseq	r5, r5, r3, lsl #10
   928c4: 00555c68     	subseq	r5, r5, r8, ror #24
   928c8: e59d70c0     	ldr	r7, [sp, #0xc0]
   928cc: e1a00007     	mov	r0, r7
   928d0: eb00148a     	bl	0x97b00 <.text+0x87a00> @ imm = #0x5228
   928d4: e5970018     	ldr	r0, [r7, #0x18]
   928d8: eb00524b     	bl	0xa720c <.text+0x9710c> @ imm = #0x1492c
   928dc: eb01af61     	bl	0xfe668 <.text+0xee568> @ imm = #0x6bd84
   928e0: e3500001     	cmp	r0, #1
   928e4: ba000007     	blt	0x92908 <.text+0x82808> @ imm = #0x1c
   928e8: e1a06000     	mov	r6, r0
   928ec: e3a05000     	mov	r5, #0
   928f0: e5970230     	ldr	r0, [r7, #0x230]
   928f4: e0800005     	add	r0, r0, r5
   928f8: ebff11b3     	bl	0x56fcc <.text+0x46ecc> @ imm = #-0x3b934
   928fc: e2855e32     	add	r5, r5, #800
   92900: e2566001     	subs	r6, r6, #1
   92904: 1afffff9     	bne	0x928f0 <.text+0x827f0> @ imm = #-0x1c
   92908: e5940000     	ldr	r0, [r4]
   9290c: e2401001     	sub	r1, r0, #1
   92910: e0000190     	mul	r0, r0, r1
   92914: e3100001     	tst	r0, #1
   92918: 0a000002     	beq	0x92928 <.text+0x82828> @ imm = #0x8
   9291c: e5990000     	ldr	r0, [r9]
   92920: e3500009     	cmp	r0, #9
   92924: ca00000e     	bgt	0x92964 <.text+0x82864> @ imm = #0x38
   92928: e59d00a8     	ldr	r0, [sp, #0xa8]
   9292c: e5902000     	ldr	r2, [r0]
   92930: e59f0fac     	ldr	r0, [pc, #0xfac]        @ 0x938e4 <.text+0x837e4>
   92934: e08f0000     	add	r0, pc, r0
   92938: e5901008     	ldr	r1, [r0, #0x8]
   9293c: e1a00007     	mov	r0, r7
   92940: eb000888     	bl	0x94b68 <.text+0x84a68> @ imm = #0x2220
   92944: e5941000     	ldr	r1, [r4]
   92948: e2412001     	sub	r2, r1, #1
   9294c: e0010291     	mul	r1, r1, r2
   92950: e3110001     	tst	r1, #1
   92954: 0a00000b     	beq	0x92988 <.text+0x82888> @ imm = #0x2c
   92958: e5991000     	ldr	r1, [r9]
   9295c: e3510009     	cmp	r1, #9
   92960: da000008     	ble	0x92988 <.text+0x82888> @ imm = #0x20
   92964: e59d00a8     	ldr	r0, [sp, #0xa8]
   92968: e5902000     	ldr	r2, [r0]
   9296c: e59f0fc4     	ldr	r0, [pc, #0xfc4]        @ 0x93938 <.text+0x83838>
   92970: e08f0000     	add	r0, pc, r0
   92974: e5901008     	ldr	r1, [r0, #0x8]
   92978: e1a00007     	mov	r0, r7
   9297c: eb000879     	bl	0x94b68 <.text+0x84a68> @ imm = #0x21e4
   92980: eaffffe8     	b	0x92928 <.text+0x82828> @ imm = #-0x60
   92984: 0058105c     	subseq	r1, r8, r12, asr r0
   92988: e3500000     	cmp	r0, #0
   9298c: 0a000449     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x1124
   92990: e59f0fe8     	ldr	r0, [pc, #0xfe8]        @ 0x93980 <.text+0x83880>
   92994: e3a07001     	mov	r7, #1
   92998: e59f1fe4     	ldr	r1, [pc, #0xfe4]        @ 0x93984 <.text+0x83884>
   9299c: e59f2fe4     	ldr	r2, [pc, #0xfe4]        @ 0x93988 <.text+0x83888>
   929a0: e08f0000     	add	r0, pc, r0
   929a4: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0x9398c <.text+0x8388c>
   929a8: e08f1001     	add	r1, pc, r1
   929ac: e08f2002     	add	r2, pc, r2
   929b0: e58d7000     	str	r7, [sp]
   929b4: e08f3003     	add	r3, pc, r3
   929b8: e58d3004     	str	r3, [sp, #0x4]
   929bc: e301344d     	movw	r3, #0x144d
   929c0: eb019dbf     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x676fc
   929c4: e59d00b8     	ldr	r0, [sp, #0xb8]
   929c8: e30017d9     	movw	r1, #0x7d9
   929cc: ebfedcb1     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x48d3c
   929d0: ea000438     	b	0x93ab8 <.text+0x839b8> @ imm = #0x10e0
   929d4: 005554fb     	ldrsheq	r5, [r5], #-75
   929d8: 00555465     	subseq	r5, r5, r5, ror #8
   929dc: 0055548b     	subseq	r5, r5, r11, lsl #9
   929e0: 00555bf0     	ldrsheq	r5, [r5], #-176
   929e4: e59d00c0     	ldr	r0, [sp, #0xc0]
   929e8: ebff3f64     	bl	0x62780 <.text+0x52680> @ imm = #-0x30270
   929ec: e5941000     	ldr	r1, [r4]
   929f0: e2412001     	sub	r2, r1, #1
   929f4: e0010291     	mul	r1, r1, r2
   929f8: e3110001     	tst	r1, #1
   929fc: 0a000007     	beq	0x92a20 <.text+0x82920> @ imm = #0x1c
   92a00: e5991000     	ldr	r1, [r9]
   92a04: e3510009     	cmp	r1, #9
   92a08: da000004     	ble	0x92a20 <.text+0x82920> @ imm = #0x10
   92a0c: e59d00c0     	ldr	r0, [sp, #0xc0]
   92a10: ebff3f5a     	bl	0x62780 <.text+0x52680> @ imm = #-0x30298
   92a14: eafffff2     	b	0x929e4 <.text+0x828e4> @ imm = #-0x38
   92a18: 00580ff4     	ldrsheq	r0, [r8], #-244
   92a1c: 0057ef80     	subseq	lr, r7, r0, lsl #31
   92a20: e59f3fd0     	ldr	r3, [pc, #0xfd0]        @ 0x939f8 <.text+0x838f8>
   92a24: e1500005     	cmp	r0, r5
   92a28: e08f3003     	add	r3, pc, r3
   92a2c: aa000421     	bge	0x93ab8 <.text+0x839b8> @ imm = #0x1084
   92a30: e5940000     	ldr	r0, [r4]
   92a34: e59d50c0     	ldr	r5, [sp, #0xc0]
   92a38: e2401001     	sub	r1, r0, #1
   92a3c: e59d6084     	ldr	r6, [sp, #0x84]
   92a40: e0000190     	mul	r0, r0, r1
   92a44: e3100001     	tst	r0, #1
   92a48: 0a000002     	beq	0x92a58 <.text+0x82958> @ imm = #0x8
   92a4c: e5990000     	ldr	r0, [r9]
   92a50: e3500009     	cmp	r0, #9
   92a54: ca000013     	bgt	0x92aa8 <.text+0x829a8> @ imm = #0x4c
   92a58: e5932004     	ldr	r2, [r3, #0x4]
   92a5c: e2831008     	add	r1, r3, #8
   92a60: ed960b00     	vldr	d0, [r6]
   92a64: e1a00005     	mov	r0, r5
   92a68: ebffdb1a     	bl	0x896d8 <.text+0x795d8> @ imm = #-0x9398
   92a6c: e59f0f88     	ldr	r0, [pc, #0xf88]        @ 0x939fc <.text+0x838fc>
   92a70: e08f0000     	add	r0, pc, r0
   92a74: e5901008     	ldr	r1, [r0, #0x8]
   92a78: e1a00005     	mov	r0, r5
   92a7c: eb000876     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x21d8
   92a80: e59f3f78     	ldr	r3, [pc, #0xf78]        @ 0x93a00 <.text+0x83900>
   92a84: e5941000     	ldr	r1, [r4]
   92a88: e08f3003     	add	r3, pc, r3
   92a8c: e2412001     	sub	r2, r1, #1
   92a90: e0010291     	mul	r1, r1, r2
   92a94: e3110001     	tst	r1, #1
   92a98: 0a00000f     	beq	0x92adc <.text+0x829dc> @ imm = #0x3c
   92a9c: e5991000     	ldr	r1, [r9]
   92aa0: e3510009     	cmp	r1, #9
   92aa4: da00000c     	ble	0x92adc <.text+0x829dc> @ imm = #0x30
   92aa8: e5932004     	ldr	r2, [r3, #0x4]
   92aac: e2831008     	add	r1, r3, #8
   92ab0: ed960b00     	vldr	d0, [r6]
   92ab4: e1a00005     	mov	r0, r5
   92ab8: ebffdb06     	bl	0x896d8 <.text+0x795d8> @ imm = #-0x93e8
   92abc: e59f0fcc     	ldr	r0, [pc, #0xfcc]        @ 0x93a90 <.text+0x83990>
   92ac0: e08f0000     	add	r0, pc, r0
   92ac4: e5901008     	ldr	r1, [r0, #0x8]
   92ac8: e1a00005     	mov	r0, r5
   92acc: eb000862     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x2188
   92ad0: e59f3ff4     	ldr	r3, [pc, #0xff4]        @ 0x93acc <.text+0x839cc>
   92ad4: e08f3003     	add	r3, pc, r3
   92ad8: eaffffde     	b	0x92a58 <.text+0x82958> @ imm = #-0x88
   92adc: e59f6ffc     	ldr	r6, [pc, #0xffc]        @ 0x93ae0 <.text+0x839e0>
   92ae0: e3500000     	cmp	r0, #0
   92ae4: e08f6006     	add	r6, pc, r6
   92ae8: 0a000010     	beq	0x92b30 <.text+0x82a30> @ imm = #0x40
   92aec: e59f0ff0     	ldr	r0, [pc, #0xff0]        @ 0x93ae4 <.text+0x839e4>
   92af0: e3a07001     	mov	r7, #1
   92af4: e59f1fec     	ldr	r1, [pc, #0xfec]        @ 0x93ae8 <.text+0x839e8>
   92af8: e59f2fec     	ldr	r2, [pc, #0xfec]        @ 0x93aec <.text+0x839ec>
   92afc: e08f0000     	add	r0, pc, r0
   92b00: e59f3fe8     	ldr	r3, [pc, #0xfe8]        @ 0x93af0 <.text+0x839f0>
   92b04: e08f1001     	add	r1, pc, r1
   92b08: e08f2002     	add	r2, pc, r2
   92b0c: e58d7000     	str	r7, [sp]
   92b10: e08f3003     	add	r3, pc, r3
   92b14: e58d3004     	str	r3, [sp, #0x4]
   92b18: e3013479     	movw	r3, #0x1479
   92b1c: eb019d68     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x675a0
   92b20: e59d00b8     	ldr	r0, [sp, #0xb8]
   92b24: e30017da     	movw	r1, #0x7da
   92b28: ebfedc5a     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x48e98
   92b2c: eaffeec4     	b	0x8e644 <.text+0x7e544> @ imm = #-0x44f0
   92b30: e3a00006     	mov	r0, #6
   92b34: eafff51d     	b	0x8ffb0 <.text+0x7feb0> @ imm = #-0x2b8c
   92b38: e5940000     	ldr	r0, [r4]
   92b3c: e302204c     	movw	r2, #0x204c
   92b40: e3a03001     	mov	r3, #1
   92b44: e2401001     	sub	r1, r0, #1
   92b48: e7853002     	str	r3, [r5, r2]
   92b4c: e0010190     	mul	r1, r0, r1
   92b50: e5990000     	ldr	r0, [r9]
   92b54: e3110001     	tst	r1, #1
   92b58: 0a000005     	beq	0x92b74 <.text+0x82a74> @ imm = #0x14
   92b5c: e350000a     	cmp	r0, #10
   92b60: ba000003     	blt	0x92b74 <.text+0x82a74> @ imm = #0xc
   92b64: e302004c     	movw	r0, #0x204c
   92b68: e3a01001     	mov	r1, #1
   92b6c: e7851000     	str	r1, [r5, r0]
   92b70: eafffff0     	b	0x92b38 <.text+0x82a38> @ imm = #-0x40
   92b74: e3020034     	movw	r0, #0x2034
   92b78: e7950000     	ldr	r0, [r5, r0]
   92b7c: e3500000     	cmp	r0, #0
   92b80: 0a000009     	beq	0x92bac <.text+0x82aac> @ imm = #0x24
   92b84: e3500001     	cmp	r0, #1
   92b88: 1a000010     	bne	0x92bd0 <.text+0x82ad0> @ imm = #0x40
   92b8c: e3020030     	movw	r0, #0x2030
   92b90: eeb00b48     	vmov.f64	d0, d8
   92b94: e7951000     	ldr	r1, [r5, r0]
   92b98: e2850008     	add	r0, r5, #8
   92b9c: eb002e09     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xb824
   92ba0: e59f5fc4     	ldr	r5, [pc, #0xfc4]        @ 0x93b6c <.text+0x83a6c>
   92ba4: e08f5005     	add	r5, pc, r5
   92ba8: ea0000af     	b	0x92e6c <.text+0x82d6c> @ imm = #0x2bc
   92bac: e5940000     	ldr	r0, [r4]
   92bb0: e2401001     	sub	r1, r0, #1
   92bb4: e0000190     	mul	r0, r0, r1
   92bb8: e3100001     	tst	r0, #1
   92bbc: 0a0000e3     	beq	0x92f50 <.text+0x82e50> @ imm = #0x38c
   92bc0: e5990000     	ldr	r0, [r9]
   92bc4: e3500009     	cmp	r0, #9
   92bc8: ca0000ed     	bgt	0x92f84 <.text+0x82e84> @ imm = #0x3b4
   92bcc: ea0000df     	b	0x92f50 <.text+0x82e50> @ imm = #0x37c
   92bd0: e59f0ff4     	ldr	r0, [pc, #0xff4]        @ 0x93bcc <.text+0x83acc>
   92bd4: e3a06002     	mov	r6, #2
   92bd8: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0x93bd0 <.text+0x83ad0>
   92bdc: e59f2ff0     	ldr	r2, [pc, #0xff0]        @ 0x93bd4 <.text+0x83ad4>
   92be0: e08f0000     	add	r0, pc, r0
   92be4: e59f3fec     	ldr	r3, [pc, #0xfec]        @ 0x93bd8 <.text+0x83ad8>
   92be8: e08f1001     	add	r1, pc, r1
   92bec: e08f2002     	add	r2, pc, r2
   92bf0: e58d6000     	str	r6, [sp]
   92bf4: e08f3003     	add	r3, pc, r3
   92bf8: e58d3004     	str	r3, [sp, #0x4]
   92bfc: e3a03e75     	mov	r3, #1872
   92c00: eb019d2f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x674bc
   92c04: e59f5fd0     	ldr	r5, [pc, #0xfd0]        @ 0x93bdc <.text+0x83adc>
   92c08: e08f5005     	add	r5, pc, r5
   92c0c: ea0000a3     	b	0x92ea0 <.text+0x82da0> @ imm = #0x28c
   92c10: e5940000     	ldr	r0, [r4]
   92c14: e59f5fc4     	ldr	r5, [pc, #0xfc4]        @ 0x93be0 <.text+0x83ae0>
   92c18: e2401001     	sub	r1, r0, #1
   92c1c: e08f5005     	add	r5, pc, r5
   92c20: e0000190     	mul	r0, r0, r1
   92c24: e3100001     	tst	r0, #1
   92c28: 0a000002     	beq	0x92c38 <.text+0x82b38> @ imm = #0x8
   92c2c: e5990000     	ldr	r0, [r9]
   92c30: e3500009     	cmp	r0, #9
   92c34: ca000017     	bgt	0x92c98 <.text+0x82b98> @ imm = #0x5c
   92c38: e59f0fa4     	ldr	r0, [pc, #0xfa4]        @ 0x93be4 <.text+0x83ae4>
   92c3c: e3a03001     	mov	r3, #1
   92c40: e59f1fa0     	ldr	r1, [pc, #0xfa0]        @ 0x93be8 <.text+0x83ae8>
   92c44: e59f2fa0     	ldr	r2, [pc, #0xfa0]        @ 0x93bec <.text+0x83aec>
   92c48: e08f0000     	add	r0, pc, r0
   92c4c: e08f1001     	add	r1, pc, r1
   92c50: e88d0028     	stm	sp, {r3, r5}
   92c54: e08f2002     	add	r2, pc, r2
   92c58: e3013526     	movw	r3, #0x1526
   92c5c: eb019d18     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x67460
   92c60: e59d00c0     	ldr	r0, [sp, #0xc0]
   92c64: ebff50c5     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2bcec
   92c68: e5940000     	ldr	r0, [r4]
   92c6c: e3a02000     	mov	r2, #0
   92c70: e2401001     	sub	r1, r0, #1
   92c74: e0010190     	mul	r1, r0, r1
   92c78: e5990000     	ldr	r0, [r9]
   92c7c: e59f3fd4     	ldr	r3, [pc, #0xfd4]        @ 0x93c58 <.text+0x83b58>
   92c80: e08f3003     	add	r3, pc, r3
   92c84: e3110001     	tst	r1, #1
   92c88: e5c32000     	strb	r2, [r3]
   92c8c: 0a000389     	beq	0x93ab8 <.text+0x839b8> @ imm = #0xe24
   92c90: e350000a     	cmp	r0, #10
   92c94: ba000387     	blt	0x93ab8 <.text+0x839b8> @ imm = #0xe1c
   92c98: e59f0ff4     	ldr	r0, [pc, #0xff4]        @ 0x93c94 <.text+0x83b94>
   92c9c: e3a03001     	mov	r3, #1
   92ca0: e59f1ff0     	ldr	r1, [pc, #0xff0]        @ 0x93c98 <.text+0x83b98>
   92ca4: e59f2ff0     	ldr	r2, [pc, #0xff0]        @ 0x93c9c <.text+0x83b9c>
   92ca8: e08f0000     	add	r0, pc, r0
   92cac: e08f1001     	add	r1, pc, r1
   92cb0: e88d0028     	stm	sp, {r3, r5}
   92cb4: e08f2002     	add	r2, pc, r2
   92cb8: e3013526     	movw	r3, #0x1526
   92cbc: eb019d00     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x67400
   92cc0: e59d00c0     	ldr	r0, [sp, #0xc0]
   92cc4: ebff50ad     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2bd4c
   92cc8: e59f1fd0     	ldr	r1, [pc, #0xfd0]        @ 0x93ca0 <.text+0x83ba0>
   92ccc: e3a00000     	mov	r0, #0
   92cd0: e08f1001     	add	r1, pc, r1
   92cd4: e5c10000     	strb	r0, [r1]
   92cd8: eaffffd6     	b	0x92c38 <.text+0x82b38> @ imm = #-0xa8
   92cdc: eeb00b48     	vmov.f64	d0, d8
   92ce0: e2850008     	add	r0, r5, #8
   92ce4: eb003a85     	bl	0xa1700 <.text+0x91600> @ imm = #0xea14
   92ce8: e1a08000     	mov	r8, r0
   92cec: e59f0fe0     	ldr	r0, [pc, #0xfe0]        @ 0x93cd4 <.text+0x83bd4>
   92cf0: e08f0000     	add	r0, pc, r0
   92cf4: e5906008     	ldr	r6, [r0, #0x8]
   92cf8: eb01bf5e     	bl	0x102a78 <.text+0xf2978> @ imm = #0x6fd78
   92cfc: e59f5fd4     	ldr	r5, [pc, #0xfd4]        @ 0x93cd8 <.text+0x83bd8>
   92d00: e1560000     	cmp	r6, r0
   92d04: e5941000     	ldr	r1, [r4]
   92d08: e08f5005     	add	r5, pc, r5
   92d0c: e2412001     	sub	r2, r1, #1
   92d10: e0020291     	mul	r2, r1, r2
   92d14: e3a01000     	mov	r1, #0
   92d18: a3001001     	movwge	r1, #0x1
   92d1c: e3120001     	tst	r2, #1
   92d20: 0a000009     	beq	0x92d4c <.text+0x82c4c> @ imm = #0x24
   92d24: e5990000     	ldr	r0, [r9]
   92d28: e3500009     	cmp	r0, #9
   92d2c: da000006     	ble	0x92d4c <.text+0x82c4c> @ imm = #0x18
   92d30: eeb00b48     	vmov.f64	d0, d8
   92d34: e2850008     	add	r0, r5, #8
   92d38: eb003a70     	bl	0xa1700 <.text+0x91600> @ imm = #0xe9c0
   92d3c: eb01bf4d     	bl	0x102a78 <.text+0xf2978> @ imm = #0x6fd34
   92d40: e59f5f94     	ldr	r5, [pc, #0xf94]        @ 0x93cdc <.text+0x83bdc>
   92d44: e08f5005     	add	r5, pc, r5
   92d48: eaffffe3     	b	0x92cdc <.text+0x82bdc> @ imm = #-0x74
   92d4c: e3580000     	cmp	r8, #0
   92d50: 0affed5b     	beq	0x8e2c4 <.text+0x7e1c4> @ imm = #-0x4a94
   92d54: e5940000     	ldr	r0, [r4]
   92d58: e2402001     	sub	r2, r0, #1
   92d5c: e0000290     	mul	r0, r0, r2
   92d60: e3100001     	tst	r0, #1
   92d64: 0a000002     	beq	0x92d74 <.text+0x82c74> @ imm = #0x8
   92d68: e5990000     	ldr	r0, [r9]
   92d6c: e3500009     	cmp	r0, #9
   92d70: cafffff7     	bgt	0x92d54 <.text+0x82c54> @ imm = #-0x24
   92d74: e5940000     	ldr	r0, [r4]
   92d78: e3a03001     	mov	r3, #1
   92d7c: e2402001     	sub	r2, r0, #1
   92d80: e0000290     	mul	r0, r0, r2
   92d84: e5992000     	ldr	r2, [r9]
   92d88: e352000a     	cmp	r2, #10
   92d8c: e1c30000     	bic	r0, r3, r0
   92d90: e3a03000     	mov	r3, #0
   92d94: b3003001     	movwlt	r3, #0x1
   92d98: e1800003     	orr	r0, r0, r3
   92d9c: e3510000     	cmp	r1, #0
   92da0: 0a000003     	beq	0x92db4 <.text+0x82cb4> @ imm = #0xc
   92da4: e59d50c0     	ldr	r5, [sp, #0xc0]
   92da8: e3500000     	cmp	r0, #0
   92dac: 0a000085     	beq	0x92fc8 <.text+0x82ec8> @ imm = #0x214
   92db0: ea000079     	b	0x92f9c <.text+0x82e9c> @ imm = #0x1e4
   92db4: e59f7fd0     	ldr	r7, [pc, #0xfd0]        @ 0x93d8c <.text+0x83c8c>
   92db8: e3500000     	cmp	r0, #0
   92dbc: e08f7007     	add	r7, pc, r7
   92dc0: 0a0000d8     	beq	0x93128 <.text+0x83028> @ imm = #0x360
   92dc4: ea0000ca     	b	0x930f4 <.text+0x82ff4> @ imm = #0x328
   92dc8: e59f0fc0     	ldr	r0, [pc, #0xfc0]        @ 0x93d90 <.text+0x83c90>
   92dcc: e3a07001     	mov	r7, #1
   92dd0: e59f1fbc     	ldr	r1, [pc, #0xfbc]        @ 0x93d94 <.text+0x83c94>
   92dd4: e59f2fbc     	ldr	r2, [pc, #0xfbc]        @ 0x93d98 <.text+0x83c98>
   92dd8: e08f0000     	add	r0, pc, r0
   92ddc: e59f3fb8     	ldr	r3, [pc, #0xfb8]        @ 0x93d9c <.text+0x83c9c>
   92de0: e08f1001     	add	r1, pc, r1
   92de4: e08f2002     	add	r2, pc, r2
   92de8: e58d7000     	str	r7, [sp]
   92dec: e08f3003     	add	r3, pc, r3
   92df0: e58d3004     	str	r3, [sp, #0x4]
   92df4: e30134cd     	movw	r3, #0x14cd
   92df8: eb019cb1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x672c4
   92dfc: e59d00b8     	ldr	r0, [sp, #0xb8]
   92e00: e30017da     	movw	r1, #0x7da
   92e04: ebfedba3     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x49174
   92e08: e5940000     	ldr	r0, [r4]
   92e0c: e2401001     	sub	r1, r0, #1
   92e10: e0000190     	mul	r0, r0, r1
   92e14: e3100001     	tst	r0, #1
   92e18: 0affff7c     	beq	0x92c10 <.text+0x82b10> @ imm = #-0x210
   92e1c: e5990000     	ldr	r0, [r9]
   92e20: e350000a     	cmp	r0, #10
   92e24: baffff79     	blt	0x92c10 <.text+0x82b10> @ imm = #-0x21c
   92e28: e59f0f70     	ldr	r0, [pc, #0xf70]        @ 0x93da0 <.text+0x83ca0>
   92e2c: e3a07001     	mov	r7, #1
   92e30: e59f1f6c     	ldr	r1, [pc, #0xf6c]        @ 0x93da4 <.text+0x83ca4>
   92e34: e59f2f6c     	ldr	r2, [pc, #0xf6c]        @ 0x93da8 <.text+0x83ca8>
   92e38: e08f0000     	add	r0, pc, r0
   92e3c: e59f3f68     	ldr	r3, [pc, #0xf68]        @ 0x93dac <.text+0x83cac>
   92e40: e08f1001     	add	r1, pc, r1
   92e44: e08f2002     	add	r2, pc, r2
   92e48: e58d7000     	str	r7, [sp]
   92e4c: e08f3003     	add	r3, pc, r3
   92e50: e58d3004     	str	r3, [sp, #0x4]
   92e54: e30134cd     	movw	r3, #0x14cd
   92e58: eb019c99     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x67264
   92e5c: e59d00b8     	ldr	r0, [sp, #0xb8]
   92e60: e30017da     	movw	r1, #0x7da
   92e64: ebfedb8b     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x491d4
   92e68: eaffffd6     	b	0x92dc8 <.text+0x82cc8> @ imm = #-0xa8
   92e6c: e3500000     	cmp	r0, #0
   92e70: 0a00000a     	beq	0x92ea0 <.text+0x82da0> @ imm = #0x28
   92e74: e59d00c0     	ldr	r0, [sp, #0xc0]
   92e78: e5956008     	ldr	r6, [r5, #0x8]
   92e7c: e590001c     	ldr	r0, [r0, #0x1c]
   92e80: ebff37b2     	bl	0x60d50 <.text+0x50c50> @ imm = #-0x32138
   92e84: e59f5fc8     	ldr	r5, [pc, #0xfc8]        @ 0x93e54 <.text+0x83d54>
   92e88: e59d1064     	ldr	r1, [sp, #0x64]
   92e8c: e08f5005     	add	r5, pc, r5
   92e90: e5911000     	ldr	r1, [r1]
   92e94: e0810000     	add	r0, r1, r0
   92e98: e1560000     	cmp	r6, r0
   92e9c: aa000022     	bge	0x92f2c <.text+0x82e2c> @ imm = #0x88
   92ea0: e59d0064     	ldr	r0, [sp, #0x64]
   92ea4: e5951008     	ldr	r1, [r5, #0x8]
   92ea8: e5900000     	ldr	r0, [r0]
   92eac: e0811080     	add	r1, r1, r0, lsl #1
   92eb0: e59d00bc     	ldr	r0, [sp, #0xbc]
   92eb4: ebfef5b3     	bl	0x50588 <.text+0x40488> @ imm = #-0x42934
   92eb8: e5850008     	str	r0, [r5, #0x8]
   92ebc: e1a0100a     	mov	r1, r10
   92ec0: e59d00c0     	ldr	r0, [sp, #0xc0]
   92ec4: eb000764     	bl	0x94c5c <.text+0x84b5c> @ imm = #0x1d90
   92ec8: e3500000     	cmp	r0, #0
   92ecc: 0a00000f     	beq	0x92f10 <.text+0x82e10> @ imm = #0x3c
   92ed0: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0x93ed0 <.text+0x83dd0>
   92ed4: e3a07001     	mov	r7, #1
   92ed8: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0x93ed4 <.text+0x83dd4>
   92edc: e59f2ff4     	ldr	r2, [pc, #0xff4]        @ 0x93ed8 <.text+0x83dd8>
   92ee0: e08f0000     	add	r0, pc, r0
   92ee4: e59f3ff0     	ldr	r3, [pc, #0xff0]        @ 0x93edc <.text+0x83ddc>
   92ee8: e08f1001     	add	r1, pc, r1
   92eec: e08f2002     	add	r2, pc, r2
   92ef0: e58d7000     	str	r7, [sp]
   92ef4: e08f3003     	add	r3, pc, r3
   92ef8: e58d3004     	str	r3, [sp, #0x4]
   92efc: e30134de     	movw	r3, #0x14de
   92f00: eb019c6f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x671bc
   92f04: e59d00b8     	ldr	r0, [sp, #0xb8]
   92f08: e30017da     	movw	r1, #0x7da
   92f0c: eaffe68f     	b	0x8c950 <.text+0x7c850> @ imm = #-0x65c4
   92f10: e59f2fec     	ldr	r2, [pc, #0xfec]        @ 0x93f04 <.text+0x83e04>
   92f14: e302004c     	movw	r0, #0x204c
   92f18: e3a01002     	mov	r1, #2
   92f1c: e08f2002     	add	r2, pc, r2
   92f20: e7821000     	str	r1, [r2, r0]
   92f24: e3a00007     	mov	r0, #7
   92f28: eafff420     	b	0x8ffb0 <.text+0x7feb0> @ imm = #-0x2f80
   92f2c: e5940000     	ldr	r0, [r4]
   92f30: e2402001     	sub	r2, r0, #1
   92f34: e0000290     	mul	r0, r0, r2
   92f38: e3100001     	tst	r0, #1
   92f3c: 0a000082     	beq	0x9314c <.text+0x8304c> @ imm = #0x208
   92f40: e5990000     	ldr	r0, [r9]
   92f44: e3500009     	cmp	r0, #9
   92f48: ca00008a     	bgt	0x93178 <.text+0x83078> @ imm = #0x228
   92f4c: ea00007e     	b	0x9314c <.text+0x8304c> @ imm = #0x1f8
   92f50: eeb00b48     	vmov.f64	d0, d8
   92f54: e2850008     	add	r0, r5, #8
   92f58: eb003982     	bl	0xa1568 <.text+0x91468> @ imm = #0xe608
   92f5c: e59f5fa4     	ldr	r5, [pc, #0xfa4]        @ 0x93f08 <.text+0x83e08>
   92f60: e5941000     	ldr	r1, [r4]
   92f64: e08f5005     	add	r5, pc, r5
   92f68: e2412001     	sub	r2, r1, #1
   92f6c: e0010291     	mul	r1, r1, r2
   92f70: e3110001     	tst	r1, #1
   92f74: 0affffbc     	beq	0x92e6c <.text+0x82d6c> @ imm = #-0x110
   92f78: e5991000     	ldr	r1, [r9]
   92f7c: e3510009     	cmp	r1, #9
   92f80: daffffb9     	ble	0x92e6c <.text+0x82d6c> @ imm = #-0x11c
   92f84: eeb00b48     	vmov.f64	d0, d8
   92f88: e2850008     	add	r0, r5, #8
   92f8c: eb003975     	bl	0xa1568 <.text+0x91468> @ imm = #0xe5d4
   92f90: e59f5fe0     	ldr	r5, [pc, #0xfe0]        @ 0x93f78 <.text+0x83e78>
   92f94: e08f5005     	add	r5, pc, r5
   92f98: eaffffec     	b	0x92f50 <.text+0x82e50> @ imm = #-0x50
   92f9c: e1a00005     	mov	r0, r5
   92fa0: e3a01001     	mov	r1, #1
   92fa4: eb0008e2     	bl	0x95334 <.text+0x85234> @ imm = #0x2388
   92fa8: e5941000     	ldr	r1, [r4]
   92fac: e2412001     	sub	r2, r1, #1
   92fb0: e0010291     	mul	r1, r1, r2
   92fb4: e3110001     	tst	r1, #1
   92fb8: 0a000007     	beq	0x92fdc <.text+0x82edc> @ imm = #0x1c
   92fbc: e5991000     	ldr	r1, [r9]
   92fc0: e3510009     	cmp	r1, #9
   92fc4: da000004     	ble	0x92fdc <.text+0x82edc> @ imm = #0x10
   92fc8: e1a00005     	mov	r0, r5
   92fcc: e3a01001     	mov	r1, #1
   92fd0: eb0008d7     	bl	0x95334 <.text+0x85234> @ imm = #0x235c
   92fd4: eafffff0     	b	0x92f9c <.text+0x82e9c> @ imm = #-0x40
   92fd8: 00555616     	subseq	r5, r5, r6, lsl r6
   92fdc: e3500000     	cmp	r0, #0
   92fe0: 0a000017     	beq	0x93044 <.text+0x82f44> @ imm = #0x5c
   92fe4: e5940000     	ldr	r0, [r4]
   92fe8: e2401001     	sub	r1, r0, #1
   92fec: e0000190     	mul	r0, r0, r1
   92ff0: e3100001     	tst	r0, #1
   92ff4: 0a000002     	beq	0x93004 <.text+0x82f04> @ imm = #0x8
   92ff8: e5990000     	ldr	r0, [r9]
   92ffc: e3500009     	cmp	r0, #9
   93000: ca00000a     	bgt	0x93030 <.text+0x82f30> @ imm = #0x28
   93004: e59d00b8     	ldr	r0, [sp, #0xb8]
   93008: e3001fa1     	movw	r1, #0xfa1
   9300c: ebfedb21     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x4937c
   93010: e5940000     	ldr	r0, [r4]
   93014: e2401001     	sub	r1, r0, #1
   93018: e0000190     	mul	r0, r0, r1
   9301c: e3100001     	tst	r0, #1
   93020: 0a000007     	beq	0x93044 <.text+0x82f44> @ imm = #0x1c
   93024: e5990000     	ldr	r0, [r9]
   93028: e3500009     	cmp	r0, #9
   9302c: da000004     	ble	0x93044 <.text+0x82f44> @ imm = #0x10
   93030: e59d00b8     	ldr	r0, [sp, #0xb8]
   93034: e3001fa1     	movw	r1, #0xfa1
   93038: ebfedb16     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x493a8
   9303c: eafffff0     	b	0x93004 <.text+0x82f04> @ imm = #-0x40
   93040: 0055558e     	subseq	r5, r5, lr, lsl #11
   93044: e5940000     	ldr	r0, [r4]
   93048: e2401001     	sub	r1, r0, #1
   9304c: e0000190     	mul	r0, r0, r1
   93050: e3100001     	tst	r0, #1
   93054: 0a000002     	beq	0x93064 <.text+0x82f64> @ imm = #0x8
   93058: e5990000     	ldr	r0, [r9]
   9305c: e3500009     	cmp	r0, #9
   93060: ca000014     	bgt	0x930b8 <.text+0x82fb8> @ imm = #0x50
   93064: e59f0f30     	ldr	r0, [pc, #0xf30]        @ 0x93f9c <.text+0x83e9c>
   93068: e3a07001     	mov	r7, #1
   9306c: e59f1f2c     	ldr	r1, [pc, #0xf2c]        @ 0x93fa0 <.text+0x83ea0>
   93070: e59f2f2c     	ldr	r2, [pc, #0xf2c]        @ 0x93fa4 <.text+0x83ea4>
   93074: e08f0000     	add	r0, pc, r0
   93078: e59f3f28     	ldr	r3, [pc, #0xf28]        @ 0x93fa8 <.text+0x83ea8>
   9307c: e08f1001     	add	r1, pc, r1
   93080: e08f2002     	add	r2, pc, r2
   93084: e58d7000     	str	r7, [sp]
   93088: e08f3003     	add	r3, pc, r3
   9308c: e58d3004     	str	r3, [sp, #0x4]
   93090: e30134bc     	movw	r3, #0x14bc
   93094: eb019c0a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x67028
   93098: e5940000     	ldr	r0, [r4]
   9309c: e2401001     	sub	r1, r0, #1
   930a0: e0000190     	mul	r0, r0, r1
   930a4: e3100001     	tst	r0, #1
   930a8: 0afffed8     	beq	0x92c10 <.text+0x82b10> @ imm = #-0x4a0
   930ac: e5990000     	ldr	r0, [r9]
   930b0: e350000a     	cmp	r0, #10
   930b4: bafffed5     	blt	0x92c10 <.text+0x82b10> @ imm = #-0x4ac
   930b8: e59f0eec     	ldr	r0, [pc, #0xeec]        @ 0x93fac <.text+0x83eac>
   930bc: e3a07001     	mov	r7, #1
   930c0: e59f1ee8     	ldr	r1, [pc, #0xee8]        @ 0x93fb0 <.text+0x83eb0>
   930c4: e59f2ee8     	ldr	r2, [pc, #0xee8]        @ 0x93fb4 <.text+0x83eb4>
   930c8: e08f0000     	add	r0, pc, r0
   930cc: e59f3ee4     	ldr	r3, [pc, #0xee4]        @ 0x93fb8 <.text+0x83eb8>
   930d0: e08f1001     	add	r1, pc, r1
   930d4: e08f2002     	add	r2, pc, r2
   930d8: e58d7000     	str	r7, [sp]
   930dc: e08f3003     	add	r3, pc, r3
   930e0: e58d3004     	str	r3, [sp, #0x4]
   930e4: e30134bc     	movw	r3, #0x14bc
   930e8: eb019bf5     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66fd4
   930ec: eaffffdc     	b	0x93064 <.text+0x82f64> @ imm = #-0x90
   930f0: 0055550f     	subseq	r5, r5, pc, lsl #10
   930f4: e5940000     	ldr	r0, [r4]
   930f8: e5973008     	ldr	r3, [r7, #0x8]
   930fc: e2401001     	sub	r1, r0, #1
   93100: e0010190     	mul	r1, r0, r1
   93104: e59d0064     	ldr	r0, [sp, #0x64]
   93108: e5902000     	ldr	r2, [r0]
   9310c: e5990000     	ldr	r0, [r9]
   93110: e3110001     	tst	r1, #1
   93114: e0832002     	add	r2, r3, r2
   93118: e5872008     	str	r2, [r7, #0x8]
   9311c: 0a000265     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x994
   93120: e350000a     	cmp	r0, #10
   93124: ba000263     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x98c
   93128: e59d0064     	ldr	r0, [sp, #0x64]
   9312c: e5971008     	ldr	r1, [r7, #0x8]
   93130: e5900000     	ldr	r0, [r0]
   93134: e0810000     	add	r0, r1, r0
   93138: e5870008     	str	r0, [r7, #0x8]
   9313c: eaffffec     	b	0x930f4 <.text+0x82ff4> @ imm = #-0x50
   93140: 00554d63     	subseq	r4, r5, r3, ror #26
   93144: 00554ccd     	subseq	r4, r5, sp, asr #25
   93148: 00554cef     	subseq	r4, r5, pc, ror #25
   9314c: e5940000     	ldr	r0, [r4]
   93150: e5953008     	ldr	r3, [r5, #0x8]
   93154: e2402001     	sub	r2, r0, #1
   93158: e0433001     	sub	r3, r3, r1
   9315c: e5853008     	str	r3, [r5, #0x8]
   93160: e0020290     	mul	r2, r0, r2
   93164: e5990000     	ldr	r0, [r9]
   93168: e3120001     	tst	r2, #1
   9316c: 0a000251     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x944
   93170: e350000a     	cmp	r0, #10
   93174: ba00024f     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x93c
   93178: e5950008     	ldr	r0, [r5, #0x8]
   9317c: e0400001     	sub	r0, r0, r1
   93180: e5850008     	str	r0, [r5, #0x8]
   93184: eafffff0     	b	0x9314c <.text+0x8304c> @ imm = #-0x40
   93188: 00554cff     	ldrsheq	r4, [r5], #-207
   9318c: 00554c69     	subseq	r4, r5, r9, ror #24
   93190: 00554c8b     	subseq	r4, r5, r11, lsl #25
   93194: 0057e78c     	subseq	lr, r7, r12, lsl #15
   93198: e59d00b8     	ldr	r0, [sp, #0xb8]
   9319c: e1a01007     	mov	r1, r7
   931a0: ebfedabc     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x49510
   931a4: e59f0e10     	ldr	r0, [pc, #0xe10]        @ 0x93fbc <.text+0x83ebc>
   931a8: e3a03001     	mov	r3, #1
   931ac: e59f1e0c     	ldr	r1, [pc, #0xe0c]        @ 0x93fc0 <.text+0x83ec0>
   931b0: e59f2e0c     	ldr	r2, [pc, #0xe0c]        @ 0x93fc4 <.text+0x83ec4>
   931b4: e08f0000     	add	r0, pc, r0
   931b8: e08f1001     	add	r1, pc, r1
   931bc: e88d0028     	stm	sp, {r3, r5}
   931c0: e08f2002     	add	r2, pc, r2
   931c4: e301352d     	movw	r3, #0x152d
   931c8: eb019bbd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66ef4
   931cc: e59d00c0     	ldr	r0, [sp, #0xc0]
   931d0: ebff4f6a     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2c258
   931d4: e5940000     	ldr	r0, [r4]
   931d8: e3a02000     	mov	r2, #0
   931dc: e2401001     	sub	r1, r0, #1
   931e0: e0010190     	mul	r1, r0, r1
   931e4: e5990000     	ldr	r0, [r9]
   931e8: e59f3dd8     	ldr	r3, [pc, #0xdd8]        @ 0x93fc8 <.text+0x83ec8>
   931ec: e08f3003     	add	r3, pc, r3
   931f0: e3110001     	tst	r1, #1
   931f4: e5c32000     	strb	r2, [r3]
   931f8: 0a00022e     	beq	0x93ab8 <.text+0x839b8> @ imm = #0x8b8
   931fc: e350000a     	cmp	r0, #10
   93200: ba00022c     	blt	0x93ab8 <.text+0x839b8> @ imm = #0x8b0
   93204: e59d00b8     	ldr	r0, [sp, #0xb8]
   93208: e1a01007     	mov	r1, r7
   9320c: ebfedaa1     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x4957c
   93210: e59f0db4     	ldr	r0, [pc, #0xdb4]        @ 0x93fcc <.text+0x83ecc>
   93214: e3a03001     	mov	r3, #1
   93218: e59f1db0     	ldr	r1, [pc, #0xdb0]        @ 0x93fd0 <.text+0x83ed0>
   9321c: e59f2db0     	ldr	r2, [pc, #0xdb0]        @ 0x93fd4 <.text+0x83ed4>
   93220: e08f0000     	add	r0, pc, r0
   93224: e08f1001     	add	r1, pc, r1
   93228: e88d0028     	stm	sp, {r3, r5}
   9322c: e08f2002     	add	r2, pc, r2
   93230: e301352d     	movw	r3, #0x152d
   93234: eb019ba2     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66e88
   93238: e59d00c0     	ldr	r0, [sp, #0xc0]
   9323c: ebff4f4f     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2c2c4
   93240: e59f1d90     	ldr	r1, [pc, #0xd90]        @ 0x93fd8 <.text+0x83ed8>
   93244: e3a00000     	mov	r0, #0
   93248: e08f1001     	add	r1, pc, r1
   9324c: e5c10000     	strb	r0, [r1]
   93250: eaffffd0     	b	0x93198 <.text+0x83098> @ imm = #-0xc0
   93254: e59f6d8c     	ldr	r6, [pc, #0xd8c]        @ 0x93fe8 <.text+0x83ee8>
   93258: e08f6006     	add	r6, pc, r6
   9325c: e1a00006     	mov	r0, r6
   93260: eb144ba8     	bl	0x5a6108 <.text+0x596008> @ imm = #0x512ea0
   93264: e1a00006     	mov	r0, r6
   93268: e5d75000     	ldrb	r5, [r7]
   9326c: eb144d14     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x513450
   93270: e5940000     	ldr	r0, [r4]
   93274: e2401001     	sub	r1, r0, #1
   93278: e0000190     	mul	r0, r0, r1
   9327c: e3100001     	tst	r0, #1
   93280: 0a000009     	beq	0x932ac <.text+0x831ac> @ imm = #0x24
   93284: e5990000     	ldr	r0, [r9]
   93288: e3500009     	cmp	r0, #9
   9328c: da000006     	ble	0x932ac <.text+0x831ac> @ imm = #0x18
   93290: e59f6ddc     	ldr	r6, [pc, #0xddc]        @ 0x94074 <.text+0x83f74>
   93294: e08f6006     	add	r6, pc, r6
   93298: e1a00006     	mov	r0, r6
   9329c: eb144b99     	bl	0x5a6108 <.text+0x596008> @ imm = #0x512e64
   932a0: e1a00006     	mov	r0, r6
   932a4: eb144d06     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x513418
   932a8: eaffffe9     	b	0x93254 <.text+0x83154> @ imm = #-0x5c
   932ac: e59f3d38     	ldr	r3, [pc, #0xd38]        @ 0x93fec <.text+0x83eec>
   932b0: e3550000     	cmp	r5, #0
   932b4: e08f3003     	add	r3, pc, r3
   932b8: 1a0001fe     	bne	0x93ab8 <.text+0x839b8> @ imm = #0x7f8
   932bc: e3020034     	movw	r0, #0x2034
   932c0: e59d1070     	ldr	r1, [sp, #0x70]
   932c4: e7930000     	ldr	r0, [r3, r0]
   932c8: ed918b00     	vldr	d8, [r1]
   932cc: e3500000     	cmp	r0, #0
   932d0: 0a00000a     	beq	0x93300 <.text+0x83200> @ imm = #0x28
   932d4: e3500001     	cmp	r0, #1
   932d8: 1a000011     	bne	0x93324 <.text+0x83224> @ imm = #0x44
   932dc: e5940000     	ldr	r0, [r4]
   932e0: e2401001     	sub	r1, r0, #1
   932e4: e0000190     	mul	r0, r0, r1
   932e8: e3100001     	tst	r0, #1
   932ec: 0a000046     	beq	0x9340c <.text+0x8330c> @ imm = #0x118
   932f0: e5990000     	ldr	r0, [r9]
   932f4: e3500009     	cmp	r0, #9
   932f8: ca000052     	bgt	0x93448 <.text+0x83348> @ imm = #0x148
   932fc: ea000042     	b	0x9340c <.text+0x8330c> @ imm = #0x108
   93300: e5940000     	ldr	r0, [r4]
   93304: e2401001     	sub	r1, r0, #1
   93308: e0000190     	mul	r0, r0, r1
   9330c: e3100001     	tst	r0, #1
   93310: 0a000055     	beq	0x9346c <.text+0x8336c> @ imm = #0x154
   93314: e5990000     	ldr	r0, [r9]
   93318: e3500009     	cmp	r0, #9
   9331c: ca00005f     	bgt	0x934a0 <.text+0x833a0> @ imm = #0x17c
   93320: ea000051     	b	0x9346c <.text+0x8336c> @ imm = #0x144
   93324: e59f0cd0     	ldr	r0, [pc, #0xcd0]        @ 0x93ffc <.text+0x83efc>
   93328: e3a07002     	mov	r7, #2
   9332c: e59f1ccc     	ldr	r1, [pc, #0xccc]        @ 0x94000 <.text+0x83f00>
   93330: e59f2ccc     	ldr	r2, [pc, #0xccc]        @ 0x94004 <.text+0x83f04>
   93334: e08f0000     	add	r0, pc, r0
   93338: e59f3cc8     	ldr	r3, [pc, #0xcc8]        @ 0x94008 <.text+0x83f08>
   9333c: e08f1001     	add	r1, pc, r1
   93340: e08f2002     	add	r2, pc, r2
   93344: e58d7000     	str	r7, [sp]
   93348: e08f3003     	add	r3, pc, r3
   9334c: e58d3004     	str	r3, [sp, #0x4]
   93350: e3a03e75     	mov	r3, #1872
   93354: eb019b5a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66d68
   93358: e59f3cac     	ldr	r3, [pc, #0xcac]        @ 0x9400c <.text+0x83f0c>
   9335c: e08f3003     	add	r3, pc, r3
   93360: ea000072     	b	0x93530 <.text+0x83430> @ imm = #0x1c8
   93364: e59f0c70     	ldr	r0, [pc, #0xc70]        @ 0x93fdc <.text+0x83edc>
   93368: e08f0000     	add	r0, pc, r0
   9336c: e2801008     	add	r1, r0, #8
   93370: e1a00005     	mov	r0, r5
   93374: eb003779     	bl	0xa1160 <.text+0x91060> @ imm = #0xdde4
   93378: e5940000     	ldr	r0, [r4]
   9337c: e2401001     	sub	r1, r0, #1
   93380: e0000190     	mul	r0, r0, r1
   93384: e3100001     	tst	r0, #1
   93388: 0affec69     	beq	0x8e534 <.text+0x7e434> @ imm = #-0x4e5c
   9338c: e5990000     	ldr	r0, [r9]
   93390: e350000a     	cmp	r0, #10
   93394: baffec66     	blt	0x8e534 <.text+0x7e434> @ imm = #-0x4e68
   93398: e59f0c40     	ldr	r0, [pc, #0xc40]        @ 0x93fe0 <.text+0x83ee0>
   9339c: e08f0000     	add	r0, pc, r0
   933a0: e2801008     	add	r1, r0, #8
   933a4: e1a00005     	mov	r0, r5
   933a8: eb00376c     	bl	0xa1160 <.text+0x91060> @ imm = #0xddb0
   933ac: eaffffec     	b	0x93364 <.text+0x83264> @ imm = #-0x50
   933b0: e59f1c2c     	ldr	r1, [pc, #0xc2c]        @ 0x93fe4 <.text+0x83ee4>
   933b4: e3020030     	movw	r0, #0x2030
   933b8: e08f1001     	add	r1, pc, r1
   933bc: e7912000     	ldr	r2, [r1, r0]
   933c0: e2811008     	add	r1, r1, #8
   933c4: e1a00005     	mov	r0, r5
   933c8: eb002a82     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xaa08
   933cc: e5940000     	ldr	r0, [r4]
   933d0: e2401001     	sub	r1, r0, #1
   933d4: e0000190     	mul	r0, r0, r1
   933d8: e3100001     	tst	r0, #1
   933dc: 0affec54     	beq	0x8e534 <.text+0x7e434> @ imm = #-0x4eb0
   933e0: e5990000     	ldr	r0, [r9]
   933e4: e350000a     	cmp	r0, #10
   933e8: baffec51     	blt	0x8e534 <.text+0x7e434> @ imm = #-0x4ebc
   933ec: e59f1c7c     	ldr	r1, [pc, #0xc7c]        @ 0x94070 <.text+0x83f70>
   933f0: e3020030     	movw	r0, #0x2030
   933f4: e08f1001     	add	r1, pc, r1
   933f8: e7912000     	ldr	r2, [r1, r0]
   933fc: e2811008     	add	r1, r1, #8
   93400: e1a00005     	mov	r0, r5
   93404: eb002a73     	bl	0x9ddd8 <.text+0x8dcd8> @ imm = #0xa9cc
   93408: eaffffe8     	b	0x933b0 <.text+0x832b0> @ imm = #-0x60
   9340c: e3020030     	movw	r0, #0x2030
   93410: eeb00b48     	vmov.f64	d0, d8
   93414: e7931000     	ldr	r1, [r3, r0]
   93418: e2830008     	add	r0, r3, #8
   9341c: eb002be9     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xafa4
   93420: e59f3bc8     	ldr	r3, [pc, #0xbc8]        @ 0x93ff0 <.text+0x83ef0>
   93424: e5941000     	ldr	r1, [r4]
   93428: e08f3003     	add	r3, pc, r3
   9342c: e2412001     	sub	r2, r1, #1
   93430: e0010291     	mul	r1, r1, r2
   93434: e3110001     	tst	r1, #1
   93438: 0a000023     	beq	0x934cc <.text+0x833cc> @ imm = #0x8c
   9343c: e5991000     	ldr	r1, [r9]
   93440: e3510009     	cmp	r1, #9
   93444: da000020     	ble	0x934cc <.text+0x833cc> @ imm = #0x80
   93448: e3020030     	movw	r0, #0x2030
   9344c: eeb00b48     	vmov.f64	d0, d8
   93450: e7931000     	ldr	r1, [r3, r0]
   93454: e2830008     	add	r0, r3, #8
   93458: eb002bda     	bl	0x9e3c8 <.text+0x8e2c8> @ imm = #0xaf68
   9345c: e59f3b90     	ldr	r3, [pc, #0xb90]        @ 0x93ff4 <.text+0x83ef4>
   93460: e08f3003     	add	r3, pc, r3
   93464: eaffffe8     	b	0x9340c <.text+0x8330c> @ imm = #-0x60
   93468: 0057e55c     	subseq	lr, r7, r12, asr r5
   9346c: eeb00b48     	vmov.f64	d0, d8
   93470: e2830008     	add	r0, r3, #8
   93474: eb00383b     	bl	0xa1568 <.text+0x91468> @ imm = #0xe0ec
   93478: e59f3b78     	ldr	r3, [pc, #0xb78]        @ 0x93ff8 <.text+0x83ef8>
   9347c: e5941000     	ldr	r1, [r4]
   93480: e08f3003     	add	r3, pc, r3
   93484: e2412001     	sub	r2, r1, #1
   93488: e0010291     	mul	r1, r1, r2
   9348c: e3110001     	tst	r1, #1
   93490: 0a00000d     	beq	0x934cc <.text+0x833cc> @ imm = #0x34
   93494: e5991000     	ldr	r1, [r9]
   93498: e3510009     	cmp	r1, #9
   9349c: da00000a     	ble	0x934cc <.text+0x833cc> @ imm = #0x28
   934a0: eeb00b48     	vmov.f64	d0, d8
   934a4: e2830008     	add	r0, r3, #8
   934a8: eb00382e     	bl	0xa1568 <.text+0x91468> @ imm = #0xe0b8
   934ac: e59f3bc4     	ldr	r3, [pc, #0xbc4]        @ 0x94078 <.text+0x83f78>
   934b0: e08f3003     	add	r3, pc, r3
   934b4: eaffffec     	b	0x9346c <.text+0x8336c> @ imm = #-0x50
   934b8: 0057e4e8     	subseq	lr, r7, r8, ror #9
   934bc: 005549c3     	subseq	r4, r5, r3, asr #19
   934c0: 0055492d     	subseq	r4, r5, sp, lsr #18
   934c4: 00554953     	subseq	r4, r5, r3, asr r9
   934c8: 00554f92     	<unknown>
   934cc: e3500000     	cmp	r0, #0
   934d0: 0a000016     	beq	0x93530 <.text+0x83430> @ imm = #0x58
   934d4: e5940000     	ldr	r0, [r4]
   934d8: e2401001     	sub	r1, r0, #1
   934dc: e0000190     	mul	r0, r0, r1
   934e0: e3100001     	tst	r0, #1
   934e4: e5940000     	ldr	r0, [r4]
   934e8: e2401001     	sub	r1, r0, #1
   934ec: e0020190     	mul	r2, r0, r1
   934f0: e5931004     	ldr	r1, [r3, #0x4]
   934f4: e5930008     	ldr	r0, [r3, #0x8]
   934f8: e5911010     	ldr	r1, [r1, #0x10]
   934fc: e3120001     	tst	r2, #1
   93500: 0a000002     	beq	0x93510 <.text+0x83410> @ imm = #0x8
   93504: e5992000     	ldr	r2, [r9]
   93508: e3520009     	cmp	r2, #9
   9350c: cafffff4     	bgt	0x934e4 <.text+0x833e4> @ imm = #-0x30
   93510: e1500001     	cmp	r0, r1
   93514: da000005     	ble	0x93530 <.text+0x83430> @ imm = #0x14
   93518: e59d1064     	ldr	r1, [sp, #0x64]
   9351c: e5982030     	ldr	r2, [r8, #0x30]
   93520: e5911000     	ldr	r1, [r1]
   93524: e0400001     	sub	r0, r0, r1
   93528: e1500002     	cmp	r0, r2
   9352c: aa00000a     	bge	0x9355c <.text+0x8345c> @ imm = #0x28
   93530: e59d006c     	ldr	r0, [sp, #0x6c]
   93534: e5931008     	ldr	r1, [r3, #0x8]
   93538: e5900000     	ldr	r0, [r0]
   9353c: e0801001     	add	r1, r0, r1
   93540: e59d00bc     	ldr	r0, [sp, #0xbc]
   93544: ebfef40f     	bl	0x50588 <.text+0x40488> @ imm = #-0x42fc4
   93548: e59f1ac0     	ldr	r1, [pc, #0xac0]        @ 0x94010 <.text+0x83f10>
   9354c: e08f1001     	add	r1, pc, r1
   93550: e5810008     	str	r0, [r1, #0x8]
   93554: e3a00007     	mov	r0, #7
   93558: eafff294     	b	0x8ffb0 <.text+0x7feb0> @ imm = #-0x35b0
   9355c: e5830008     	str	r0, [r3, #0x8]
   93560: ea000154     	b	0x93ab8 <.text+0x839b8> @ imm = #0x550
   93564: e59d0054     	ldr	r0, [sp, #0x54]
   93568: e5b01004     	ldr	r1, [r0, #0x4]!
   9356c: e5942000     	ldr	r2, [r4]
   93570: e2423001     	sub	r3, r2, #1
   93574: e0020392     	mul	r2, r2, r3
   93578: e3120001     	tst	r2, #1
   9357c: 0a000005     	beq	0x93598 <.text+0x83498> @ imm = #0x14
   93580: e5992000     	ldr	r2, [r9]
   93584: e3520009     	cmp	r2, #9
   93588: da000002     	ble	0x93598 <.text+0x83498> @ imm = #0x8
   9358c: e59d0054     	ldr	r0, [sp, #0x54]
   93590: e5900004     	ldr	r0, [r0, #0x4]
   93594: eafffff2     	b	0x93564 <.text+0x83464> @ imm = #-0x38
   93598: e3710001     	cmn	r1, #1
   9359c: 0a000009     	beq	0x935c8 <.text+0x834c8> @ imm = #0x24
   935a0: f57ff05b     	dmb	ish
   935a4: e1901f9f     	ldrex	r1, [r0]
   935a8: e2412001     	sub	r2, r1, #1
   935ac: e1803f92     	strex	r3, r2, [r0]
   935b0: e3530000     	cmp	r3, #0
   935b4: 1afffffa     	bne	0x935a4 <.text+0x834a4> @ imm = #-0x18
   935b8: e3510001     	cmp	r1, #1
   935bc: 1a000001     	bne	0x935c8 <.text+0x834c8> @ imm = #0x4
   935c0: e59d0054     	ldr	r0, [sp, #0x54]
   935c4: eb031f2b     	bl	0x15b278 <.text+0x14b178> @ imm = #0xc7cac
   935c8: e3a02000     	mov	r2, #0
   935cc: e3a05000     	mov	r5, #0
   935d0: e5940000     	ldr	r0, [r4]
   935d4: e2401001     	sub	r1, r0, #1
   935d8: e0000190     	mul	r0, r0, r1
   935dc: e3100001     	tst	r0, #1
   935e0: 0a000002     	beq	0x935f0 <.text+0x834f0> @ imm = #0x8
   935e4: e5990000     	ldr	r0, [r9]
   935e8: e3500009     	cmp	r0, #9
   935ec: cafffff7     	bgt	0x935d0 <.text+0x834d0> @ imm = #-0x24
   935f0: e3550000     	cmp	r5, #0
   935f4: 0a000028     	beq	0x9369c <.text+0x8359c> @ imm = #0xa0
   935f8: e59d504c     	ldr	r5, [sp, #0x4c]
   935fc: e59d1048     	ldr	r1, [sp, #0x48]
   93600: e1a00005     	mov	r0, r5
   93604: eb02fe77     	bl	0x152fe8 <.text+0x142ee8> @ imm = #0xbf9dc
   93608: e59f1a14     	ldr	r1, [pc, #0xa14]        @ 0x94024 <.text+0x83f24>
   9360c: e1a00005     	mov	r0, r5
   93610: e3a02002     	mov	r2, #2
   93614: e08f1001     	add	r1, pc, r1
   93618: eb025e35     	bl	0x12aef4 <.text+0x11adf4> @ imm = #0x978d4
   9361c: e3500000     	cmp	r0, #0
   93620: 0a000028     	beq	0x936c8 <.text+0x835c8> @ imm = #0xa0
   93624: e59f09fc     	ldr	r0, [pc, #0x9fc]        @ 0x94028 <.text+0x83f28>
   93628: e3a07001     	mov	r7, #1
   9362c: e59f19f8     	ldr	r1, [pc, #0x9f8]        @ 0x9402c <.text+0x83f2c>
   93630: e59f29f8     	ldr	r2, [pc, #0x9f8]        @ 0x94030 <.text+0x83f30>
   93634: e08f0000     	add	r0, pc, r0
   93638: e59f39f4     	ldr	r3, [pc, #0x9f4]        @ 0x94034 <.text+0x83f34>
   9363c: e08f1001     	add	r1, pc, r1
   93640: e08f2002     	add	r2, pc, r2
   93644: e58d7000     	str	r7, [sp]
   93648: e08f3003     	add	r3, pc, r3
   9364c: e58d3004     	str	r3, [sp, #0x4]
   93650: e30036ce     	movw	r3, #0x6ce
   93654: eb019a9a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66a68
   93658: e3550000     	cmp	r5, #0
   9365c: e3e06000     	mvn	r6, #0
   93660: 11a00005     	movne	r0, r5
   93664: 15b01004     	ldrne	r1, [r0, #0x4]!
   93668: 13710001     	cmnne	r1, #1
   9366c: 0a000058     	beq	0x937d4 <.text+0x836d4> @ imm = #0x160
   93670: f57ff05b     	dmb	ish
   93674: e1901f9f     	ldrex	r1, [r0]
   93678: e2412001     	sub	r2, r1, #1
   9367c: e1803f92     	strex	r3, r2, [r0]
   93680: e3530000     	cmp	r3, #0
   93684: 1afffffa     	bne	0x93674 <.text+0x83574> @ imm = #-0x18
   93688: e3510001     	cmp	r1, #1
   9368c: 1a000050     	bne	0x937d4 <.text+0x836d4> @ imm = #0x140
   93690: e1a00005     	mov	r0, r5
   93694: eb031ef7     	bl	0x15b278 <.text+0x14b178> @ imm = #0xc7bdc
   93698: ea00004d     	b	0x937d4 <.text+0x836d4> @ imm = #0x134
   9369c: e5940000     	ldr	r0, [r4]
   936a0: e59f596c     	ldr	r5, [pc, #0x96c]        @ 0x94014 <.text+0x83f14>
   936a4: e2401001     	sub	r1, r0, #1
   936a8: e08f5005     	add	r5, pc, r5
   936ac: e0000190     	mul	r0, r0, r1
   936b0: e3100001     	tst	r0, #1
   936b4: 0a000020     	beq	0x9373c <.text+0x8363c> @ imm = #0x80
   936b8: e5990000     	ldr	r0, [r9]
   936bc: e3500009     	cmp	r0, #9
   936c0: ca00002f     	bgt	0x93784 <.text+0x83684> @ imm = #0xbc
   936c4: ea00001c     	b	0x9373c <.text+0x8363c> @ imm = #0x70
   936c8: e3550000     	cmp	r5, #0
   936cc: 11a00005     	movne	r0, r5
   936d0: 15b01004     	ldrne	r1, [r0, #0x4]!
   936d4: 13710001     	cmnne	r1, #1
   936d8: 1a000008     	bne	0x93700 <.text+0x83600> @ imm = #0x20
   936dc: e5940000     	ldr	r0, [r4]
   936e0: e2401001     	sub	r1, r0, #1
   936e4: e0000190     	mul	r0, r0, r1
   936e8: e3100001     	tst	r0, #1
   936ec: 0a0000b1     	beq	0x939b8 <.text+0x838b8> @ imm = #0x2c4
   936f0: e5990000     	ldr	r0, [r9]
   936f4: e3500009     	cmp	r0, #9
   936f8: ca0000ba     	bgt	0x939e8 <.text+0x838e8> @ imm = #0x2e8
   936fc: ea0000ad     	b	0x939b8 <.text+0x838b8> @ imm = #0x2b4
   93700: f57ff05b     	dmb	ish
   93704: e1901f9f     	ldrex	r1, [r0]
   93708: e2412001     	sub	r2, r1, #1
   9370c: e1803f92     	strex	r3, r2, [r0]
   93710: e3530000     	cmp	r3, #0
   93714: 1afffffa     	bne	0x93704 <.text+0x83604> @ imm = #-0x18
   93718: e3510001     	cmp	r1, #1
   9371c: 1affffee     	bne	0x936dc <.text+0x835dc> @ imm = #-0x48
   93720: e1a00005     	mov	r0, r5
   93724: eb031ed3     	bl	0x15b278 <.text+0x14b178> @ imm = #0xc7b4c
   93728: eaffffeb     	b	0x936dc <.text+0x835dc> @ imm = #-0x54
   9372c: 0055477f     	subseq	r4, r5, pc, ror r7
   93730: 005546ed     	subseq	r4, r5, sp, ror #13
   93734: 0055470f     	subseq	r4, r5, pc, lsl #14
   93738: 0055472b     	subseq	r4, r5, r11, lsr #14
   9373c: e59f08d4     	ldr	r0, [pc, #0x8d4]        @ 0x94018 <.text+0x83f18>
   93740: e3a03001     	mov	r3, #1
   93744: e59f18d0     	ldr	r1, [pc, #0x8d0]        @ 0x9401c <.text+0x83f1c>
   93748: e59f28d0     	ldr	r2, [pc, #0x8d0]        @ 0x94020 <.text+0x83f20>
   9374c: e08f0000     	add	r0, pc, r0
   93750: e08f1001     	add	r1, pc, r1
   93754: e88d0028     	stm	sp, {r3, r5}
   93758: e08f2002     	add	r2, pc, r2
   9375c: e30036c6     	movw	r3, #0x6c6
   93760: eb019a57     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6695c
   93764: e5940000     	ldr	r0, [r4]
   93768: e2401001     	sub	r1, r0, #1
   9376c: e0000190     	mul	r0, r0, r1
   93770: e3100001     	tst	r0, #1
   93774: 0a00000f     	beq	0x937b8 <.text+0x836b8> @ imm = #0x3c
   93778: e5990000     	ldr	r0, [r9]
   9377c: e3500009     	cmp	r0, #9
   93780: da00000c     	ble	0x937b8 <.text+0x836b8> @ imm = #0x30
   93784: e59f08f0     	ldr	r0, [pc, #0x8f0]        @ 0x9407c <.text+0x83f7c>
   93788: e3a03001     	mov	r3, #1
   9378c: e59f18ec     	ldr	r1, [pc, #0x8ec]        @ 0x94080 <.text+0x83f80>
   93790: e59f28ec     	ldr	r2, [pc, #0x8ec]        @ 0x94084 <.text+0x83f84>
   93794: e08f0000     	add	r0, pc, r0
   93798: e08f1001     	add	r1, pc, r1
   9379c: e88d0028     	stm	sp, {r3, r5}
   937a0: e08f2002     	add	r2, pc, r2
   937a4: e30036c6     	movw	r3, #0x6c6
   937a8: eb019a45     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66914
   937ac: eaffffe2     	b	0x9373c <.text+0x8363c> @ imm = #-0x78
   937b0: 00554699     	<unknown>
   937b4: 005546bb     	ldrheq	r4, [r5], #-107
   937b8: e59d004c     	ldr	r0, [sp, #0x4c]
   937bc: e3e06000     	mvn	r6, #0
   937c0: e3500000     	cmp	r0, #0
   937c4: 11a07000     	movne	r7, r0
   937c8: 15b71004     	ldrne	r1, [r7, #0x4]!
   937cc: 13710001     	cmnne	r1, #1
   937d0: 1a00006e     	bne	0x93990 <.text+0x83890> @ imm = #0x1b8
   937d4: e59d00d4     	ldr	r0, [sp, #0xd4]
   937d8: e58d0054     	str	r0, [sp, #0x54]
   937dc: e3500000     	cmp	r0, #0
   937e0: 0a000047     	beq	0x93904 <.text+0x83804> @ imm = #0x11c
   937e4: e59d50d8     	ldr	r5, [sp, #0xd8]
   937e8: e58d6050     	str	r6, [sp, #0x50]
   937ec: e3550001     	cmp	r5, #1
   937f0: ba00003c     	blt	0x938e8 <.text+0x837e8> @ imm = #0xf0
   937f4: e59d0054     	ldr	r0, [sp, #0x54]
   937f8: e3a0a000     	mov	r10, #0
   937fc: e3a08000     	mov	r8, #0
   93800: e2807008     	add	r7, r0, #8
   93804: ea000003     	b	0x93818 <.text+0x83718> @ imm = #0xc
   93808: e2888001     	add	r8, r8, #1
   9380c: e287700c     	add	r7, r7, #12
   93810: e2555001     	subs	r5, r5, #1
   93814: 0a000033     	beq	0x938e8 <.text+0x837e8> @ imm = #0xcc
   93818: e5940000     	ldr	r0, [r4]
   9381c: e2401001     	sub	r1, r0, #1
   93820: e0000190     	mul	r0, r0, r1
   93824: e3100001     	tst	r0, #1
   93828: e5940000     	ldr	r0, [r4]
   9382c: e5976000     	ldr	r6, [r7]
   93830: e2401001     	sub	r1, r0, #1
   93834: e0000190     	mul	r0, r0, r1
   93838: e3100001     	tst	r0, #1
   9383c: 0a000002     	beq	0x9384c <.text+0x8374c> @ imm = #0x8
   93840: e5990000     	ldr	r0, [r9]
   93844: e3500009     	cmp	r0, #9
   93848: cafffff6     	bgt	0x93828 <.text+0x83728> @ imm = #-0x28
   9384c: e3560000     	cmp	r6, #0
   93850: 0a000016     	beq	0x938b0 <.text+0x837b0> @ imm = #0x58
   93854: e5940000     	ldr	r0, [r4]
   93858: e2401001     	sub	r1, r0, #1
   9385c: e0000190     	mul	r0, r0, r1
   93860: e3100001     	tst	r0, #1
   93864: 0a000002     	beq	0x93874 <.text+0x83774> @ imm = #0x8
   93868: e5990000     	ldr	r0, [r9]
   9386c: e3500009     	cmp	r0, #9
   93870: ca00000a     	bgt	0x938a0 <.text+0x837a0> @ imm = #0x28
   93874: e1a00006     	mov	r0, r6
   93878: eb140103     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x50040c
   9387c: e587a000     	str	r10, [r7]
   93880: e5940000     	ldr	r0, [r4]
   93884: e2401001     	sub	r1, r0, #1
   93888: e0000190     	mul	r0, r0, r1
   9388c: e3100001     	tst	r0, #1
   93890: 0a000006     	beq	0x938b0 <.text+0x837b0> @ imm = #0x18
   93894: e5990000     	ldr	r0, [r9]
   93898: e3500009     	cmp	r0, #9
   9389c: da000003     	ble	0x938b0 <.text+0x837b0> @ imm = #0xc
   938a0: e1a00006     	mov	r0, r6
   938a4: eb1400f8     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x5003e0
   938a8: e587a000     	str	r10, [r7]
   938ac: eafffff0     	b	0x93874 <.text+0x83774> @ imm = #-0x40
   938b0: e5940000     	ldr	r0, [r4]
   938b4: e2401001     	sub	r1, r0, #1
   938b8: e0000190     	mul	r0, r0, r1
   938bc: e3100001     	tst	r0, #1
   938c0: e5940000     	ldr	r0, [r4]
   938c4: e2401001     	sub	r1, r0, #1
   938c8: e0000190     	mul	r0, r0, r1
   938cc: e3100001     	tst	r0, #1
   938d0: 0affffcc     	beq	0x93808 <.text+0x83708> @ imm = #-0xd0
   938d4: e5990000     	ldr	r0, [r9]
   938d8: e3500009     	cmp	r0, #9
   938dc: cafffff7     	bgt	0x938c0 <.text+0x837c0> @ imm = #-0x24
   938e0: eaffffc8     	b	0x93808 <.text+0x83708> @ imm = #-0xe0
   938e4: 0057e094     	<unknown>
   938e8: e59d0054     	ldr	r0, [sp, #0x54]
   938ec: eb1400e6     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x500398
   938f0: e3a00000     	mov	r0, #0
   938f4: e58d00d4     	str	r0, [sp, #0xd4]
   938f8: e59f873c     	ldr	r8, [pc, #0x73c]        @ 0x9403c <.text+0x83f3c>
   938fc: e59d6050     	ldr	r6, [sp, #0x50]
   93900: e08f8008     	add	r8, pc, r8
   93904: e3560000     	cmp	r6, #0
   93908: 0a00000b     	beq	0x9393c <.text+0x8383c> @ imm = #0x2c
   9390c: e5940000     	ldr	r0, [r4]
   93910: e59f5728     	ldr	r5, [pc, #0x728]        @ 0x94040 <.text+0x83f40>
   93914: e2401001     	sub	r1, r0, #1
   93918: e08f5005     	add	r5, pc, r5
   9391c: e0000190     	mul	r0, r0, r1
   93920: e3100001     	tst	r0, #1
   93924: 0a000036     	beq	0x93a04 <.text+0x83904> @ imm = #0xd8
   93928: e5990000     	ldr	r0, [r9]
   9392c: e3500009     	cmp	r0, #9
   93930: ca000048     	bgt	0x93a58 <.text+0x83958> @ imm = #0x120
   93934: ea000032     	b	0x93a04 <.text+0x83904> @ imm = #0xc8
   93938: 0057e058     	subseq	lr, r7, r8, asr r0
   9393c: e59f0718     	ldr	r0, [pc, #0x718]        @ 0x9405c <.text+0x83f5c>
   93940: e3a07002     	mov	r7, #2
   93944: e59f1714     	ldr	r1, [pc, #0x714]        @ 0x94060 <.text+0x83f60>
   93948: e59f2714     	ldr	r2, [pc, #0x714]        @ 0x94064 <.text+0x83f64>
   9394c: e08f0000     	add	r0, pc, r0
   93950: e59f3710     	ldr	r3, [pc, #0x710]        @ 0x94068 <.text+0x83f68>
   93954: e08f1001     	add	r1, pc, r1
   93958: e59d60c0     	ldr	r6, [sp, #0xc0]
   9395c: e08f2002     	add	r2, pc, r2
   93960: e08f3003     	add	r3, pc, r3
   93964: e5867020     	str	r7, [r6, #0x20]
   93968: e3a07003     	mov	r7, #3
   9396c: e58d3004     	str	r3, [sp, #0x4]
   93970: e301353d     	movw	r3, #0x153d
   93974: e58d7000     	str	r7, [sp]
   93978: eb0199d1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66744
   9397c: ea000044     	b	0x93a94 <.text+0x83994> @ imm = #0x110
   93980: 0055453f     	subseq	r4, r5, pc, lsr r5
   93984: 005544a9     	subseq	r4, r5, r9, lsr #9
   93988: 005544cf     	subseq	r4, r5, pc, asr #9
   9398c: 00554a94     	<unknown>
   93990: f57ff05b     	dmb	ish
   93994: e1971f9f     	ldrex	r1, [r7]
   93998: e2412001     	sub	r2, r1, #1
   9399c: e1873f92     	strex	r3, r2, [r7]
   939a0: e3530000     	cmp	r3, #0
   939a4: 1afffffa     	bne	0x93994 <.text+0x83894> @ imm = #-0x18
   939a8: e3510001     	cmp	r1, #1
   939ac: 1affff88     	bne	0x937d4 <.text+0x836d4> @ imm = #-0x1e0
   939b0: eb031e30     	bl	0x15b278 <.text+0x14b178> @ imm = #0xc78c0
   939b4: eaffff86     	b	0x937d4 <.text+0x836d4> @ imm = #-0x1e8
   939b8: e59f0678     	ldr	r0, [pc, #0x678]        @ 0x94038 <.text+0x83f38>
   939bc: e08f0000     	add	r0, pc, r0
   939c0: eb1421c7     	bl	0x59c0e4 <.text+0x58bfe4> @ imm = #0x50871c
   939c4: e5940000     	ldr	r0, [r4]
   939c8: e3a06000     	mov	r6, #0
   939cc: e2401001     	sub	r1, r0, #1
   939d0: e0000190     	mul	r0, r0, r1
   939d4: e3100001     	tst	r0, #1
   939d8: 0affff7d     	beq	0x937d4 <.text+0x836d4> @ imm = #-0x20c
   939dc: e5990000     	ldr	r0, [r9]
   939e0: e3500009     	cmp	r0, #9
   939e4: daffff7a     	ble	0x937d4 <.text+0x836d4> @ imm = #-0x218
   939e8: e59f0698     	ldr	r0, [pc, #0x698]        @ 0x94088 <.text+0x83f88>
   939ec: e08f0000     	add	r0, pc, r0
   939f0: eb1421bb     	bl	0x59c0e4 <.text+0x58bfe4> @ imm = #0x5086ec
   939f4: eaffffef     	b	0x939b8 <.text+0x838b8> @ imm = #-0x44
   939f8: 0057dfa0     	subseq	sp, r7, r0, lsr #31
   939fc: 0057df58     	subseq	sp, r7, r8, asr pc
   93a00: 0057df40     	subseq	sp, r7, r0, asr #30
   93a04: e59f0638     	ldr	r0, [pc, #0x638]        @ 0x94044 <.text+0x83f44>
   93a08: e3a03001     	mov	r3, #1
   93a0c: e59f1634     	ldr	r1, [pc, #0x634]        @ 0x94048 <.text+0x83f48>
   93a10: e59f2634     	ldr	r2, [pc, #0x634]        @ 0x9404c <.text+0x83f4c>
   93a14: e08f0000     	add	r0, pc, r0
   93a18: e08f1001     	add	r1, pc, r1
   93a1c: e88d0028     	stm	sp, {r3, r5}
   93a20: e08f2002     	add	r2, pc, r2
   93a24: e3013539     	movw	r3, #0x1539
   93a28: eb0199a5     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66694
   93a2c: e3a00008     	mov	r0, #8
   93a30: e3a01000     	mov	r1, #0
   93a34: eb00056e     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x15b8
   93a38: e5940000     	ldr	r0, [r4]
   93a3c: e2401001     	sub	r1, r0, #1
   93a40: e0000190     	mul	r0, r0, r1
   93a44: e3100001     	tst	r0, #1
   93a48: 0a000011     	beq	0x93a94 <.text+0x83994> @ imm = #0x44
   93a4c: e5990000     	ldr	r0, [r9]
   93a50: e350000a     	cmp	r0, #10
   93a54: ba00000e     	blt	0x93a94 <.text+0x83994> @ imm = #0x38
   93a58: e59f05f0     	ldr	r0, [pc, #0x5f0]        @ 0x94050 <.text+0x83f50>
   93a5c: e3a03001     	mov	r3, #1
   93a60: e59f15ec     	ldr	r1, [pc, #0x5ec]        @ 0x94054 <.text+0x83f54>
   93a64: e59f25ec     	ldr	r2, [pc, #0x5ec]        @ 0x94058 <.text+0x83f58>
   93a68: e08f0000     	add	r0, pc, r0
   93a6c: e08f1001     	add	r1, pc, r1
   93a70: e88d0028     	stm	sp, {r3, r5}
   93a74: e08f2002     	add	r2, pc, r2
   93a78: e3013539     	movw	r3, #0x1539
   93a7c: eb019990     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x66640
   93a80: e3a00008     	mov	r0, #8
   93a84: e3a01000     	mov	r1, #0
   93a88: eb000559     	bl	0x94ff4 <.text+0x84ef4> @ imm = #0x1564
   93a8c: eaffffdc     	b	0x93a04 <.text+0x83904> @ imm = #-0x90
   93a90: 0057df08     	subseq	sp, r7, r8, lsl #30
   93a94: e3a00000     	mov	r0, #0
   93a98: e5c80000     	strb	r0, [r8]
   93a9c: e3a00003     	mov	r0, #3
   93aa0: ebfedcac     	bl	0x4ad58 <.text+0x3ac58> @ imm = #-0x48d50
   93aa4: e59d50c0     	ldr	r5, [sp, #0xc0]
   93aa8: e1a00005     	mov	r0, r5
   93aac: eb004973     	bl	0xa6080 <.text+0x95f80> @ imm = #0x125cc
   93ab0: e1a00005     	mov	r0, r5
   93ab4: eb003979     	bl	0xa20a0 <.text+0x91fa0> @ imm = #0xe5e4
   93ab8: e3a00ffa     	mov	r0, #1000
   93abc: eb01ed1e     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x7b478
   93ac0: e59f85a4     	ldr	r8, [pc, #0x5a4]        @ 0x9406c <.text+0x83f6c>
   93ac4: e08f8008     	add	r8, pc, r8
   93ac8: eaffde3f     	b	0x8b3cc <.text+0x7b2cc> @ imm = #-0x8704
   93acc: 0057def4     	ldrsheq	sp, [r7], #-228
   93ad0: e59f04a4     	ldr	r0, [pc, #0x4a4]        @ 0x93f7c <.text+0x83e7c>
   93ad4: e3a05000     	mov	r5, #0
   93ad8: e08f0000     	add	r0, pc, r0
   93adc: ea000009     	b	0x93b08 <.text+0x83a08> @ imm = #0x24
   93ae0: 0057ff34     	subseq	pc, r7, r4, lsr pc
   93ae4: 005543e3     	subseq	r4, r5, r3, ror #7
   93ae8: 0055434d     	subseq	r4, r5, sp, asr #6
   93aec: 00554373     	subseq	r4, r5, r3, ror r3
   93af0: 005549b2     	ldrheq	r4, [r5], #-146
   93af4: e59f0484     	ldr	r0, [pc, #0x484]        @ 0x93f80 <.text+0x83e80>
   93af8: e2855001     	add	r5, r5, #1
   93afc: e3550c01     	cmp	r5, #256
   93b00: e08f0000     	add	r0, pc, r0
   93b04: 0a000054     	beq	0x93c5c <.text+0x83b5c> @ imm = #0x150
   93b08: e080a285     	add	r10, r0, r5, lsl #5
   93b0c: eb01aad5     	bl	0xfe668 <.text+0xee568> @ imm = #0x6ab54
   93b10: e37a0028     	cmn	r10, #40
   93b14: 0afffff6     	beq	0x93af4 <.text+0x839f4> @ imm = #-0x28
   93b18: e1a06000     	mov	r6, r0
   93b1c: e5940000     	ldr	r0, [r4]
   93b20: e2401001     	sub	r1, r0, #1
   93b24: e0000190     	mul	r0, r0, r1
   93b28: e3100001     	tst	r0, #1
   93b2c: e5940000     	ldr	r0, [r4]
   93b30: e1a0800a     	mov	r8, r10
   93b34: e5b87040     	ldr	r7, [r8, #0x40]!
   93b38: e2401001     	sub	r1, r0, #1
   93b3c: e0000190     	mul	r0, r0, r1
   93b40: e3100001     	tst	r0, #1
   93b44: 0a000002     	beq	0x93b54 <.text+0x83a54> @ imm = #0x8
   93b48: e5990000     	ldr	r0, [r9]
   93b4c: e3500009     	cmp	r0, #9
   93b50: cafffff5     	bgt	0x93b2c <.text+0x83a2c> @ imm = #-0x2c
   93b54: e3570000     	cmp	r7, #0
   93b58: 0affffe5     	beq	0x93af4 <.text+0x839f4> @ imm = #-0x6c
   93b5c: e3560001     	cmp	r6, #1
   93b60: ba000024     	blt	0x93bf8 <.text+0x83af8> @ imm = #0x90
   93b64: e3a0a020     	mov	r10, #32
   93b68: ea000003     	b	0x93b7c <.text+0x83a7c> @ imm = #0xc
   93b6c: 0057de24     	subseq	sp, r7, r4, lsr #28
   93b70: e2566001     	subs	r6, r6, #1
   93b74: e28aa028     	add	r10, r10, #40
   93b78: 0a00001c     	beq	0x93bf0 <.text+0x83af0> @ imm = #0x70
   93b7c: e5940000     	ldr	r0, [r4]
   93b80: e2401001     	sub	r1, r0, #1
   93b84: e0000190     	mul	r0, r0, r1
   93b88: e3100001     	tst	r0, #1
   93b8c: e5940000     	ldr	r0, [r4]
   93b90: e2401001     	sub	r1, r0, #1
   93b94: e0010190     	mul	r1, r0, r1
   93b98: e797000a     	ldr	r0, [r7, r10]
   93b9c: e3110001     	tst	r1, #1
   93ba0: 0a000002     	beq	0x93bb0 <.text+0x83ab0> @ imm = #0x8
   93ba4: e5991000     	ldr	r1, [r9]
   93ba8: e3510009     	cmp	r1, #9
   93bac: cafffff6     	bgt	0x93b8c <.text+0x83a8c> @ imm = #-0x28
   93bb0: e3500000     	cmp	r0, #0
   93bb4: 0affffed     	beq	0x93b70 <.text+0x83a70> @ imm = #-0x4c
   93bb8: eb140033     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x5000cc
   93bbc: e3a00000     	mov	r0, #0
   93bc0: e787000a     	str	r0, [r7, r10]
   93bc4: e5987000     	ldr	r7, [r8]
   93bc8: eaffffe8     	b	0x93b70 <.text+0x83a70> @ imm = #-0x60
   93bcc: 005542ff     	ldrsheq	r4, [r5], #-47
   93bd0: 00554269     	subseq	r4, r5, r9, ror #4
   93bd4: 0055428f     	subseq	r4, r5, pc, lsl #5
   93bd8: 00554999     	<unknown>
   93bdc: 0057ddc0     	subseq	sp, r7, r0, asr #27
   93be0: 00554ad7     	ldrsbeq	r4, [r5], #-167
   93be4: 00554297     	<unknown>
   93be8: 00554205     	subseq	r4, r5, r5, lsl #4
   93bec: 00554227     	subseq	r4, r5, r7, lsr #4
   93bf0: e3570000     	cmp	r7, #0
   93bf4: 0a000003     	beq	0x93c08 <.text+0x83b08> @ imm = #0xc
   93bf8: e1a00007     	mov	r0, r7
   93bfc: eb140022     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x500088
   93c00: e3a00000     	mov	r0, #0
   93c04: e5880000     	str	r0, [r8]
   93c08: e5940000     	ldr	r0, [r4]
   93c0c: e3a02000     	mov	r2, #0
   93c10: e2401001     	sub	r1, r0, #1
   93c14: e0000190     	mul	r0, r0, r1
   93c18: e3100001     	tst	r0, #1
   93c1c: 0a000002     	beq	0x93c2c <.text+0x83b2c> @ imm = #0x8
   93c20: e5990000     	ldr	r0, [r9]
   93c24: e3500009     	cmp	r0, #9
   93c28: c5882000     	strgt	r2, [r8]
   93c2c: e5940000     	ldr	r0, [r4]
   93c30: e5882000     	str	r2, [r8]
   93c34: e2401001     	sub	r1, r0, #1
   93c38: e0000190     	mul	r0, r0, r1
   93c3c: e3100001     	tst	r0, #1
   93c40: 0affffab     	beq	0x93af4 <.text+0x839f4> @ imm = #-0x154
   93c44: e5990000     	ldr	r0, [r9]
   93c48: e3500009     	cmp	r0, #9
   93c4c: daffffa8     	ble	0x93af4 <.text+0x839f4> @ imm = #-0x160
   93c50: e5882000     	str	r2, [r8]
   93c54: eafffff4     	b	0x93c2c <.text+0x83b2c> @ imm = #-0x30
   93c58: 0057fd98     	<unknown>
   93c5c: e59d00c0     	ldr	r0, [sp, #0xc0]
   93c60: eb001f0e     	bl	0x9b8a0 <.text+0x8b7a0> @ imm = #0x7c38
   93c64: eb01aa7f     	bl	0xfe668 <.text+0xee568> @ imm = #0x6a9fc
   93c68: e59f3314     	ldr	r3, [pc, #0x314]        @ 0x93f84 <.text+0x83e84>
   93c6c: e08f3003     	add	r3, pc, r3
   93c70: e5935020     	ldr	r5, [r3, #0x20]
   93c74: e3550000     	cmp	r5, #0
   93c78: 0a000035     	beq	0x93d54 <.text+0x83c54> @ imm = #0xd4
   93c7c: e1a06000     	mov	r6, r0
   93c80: e3500001     	cmp	r0, #1
   93c84: ba000017     	blt	0x93ce8 <.text+0x83be8> @ imm = #0x5c
   93c88: e3a07020     	mov	r7, #32
   93c8c: e3a08000     	mov	r8, #0
   93c90: ea000006     	b	0x93cb0 <.text+0x83bb0> @ imm = #0x18
   93c94: 00554237     	subseq	r4, r5, r7, lsr r2
   93c98: 005541a5     	subseq	r4, r5, r5, lsr #3
   93c9c: 005541c7     	subseq	r4, r5, r7, asr #3
   93ca0: 0057fd48     	subseq	pc, r7, r8, asr #26
   93ca4: e2877028     	add	r7, r7, #40
   93ca8: e2566001     	subs	r6, r6, #1
   93cac: 0a00000b     	beq	0x93ce0 <.text+0x83be0> @ imm = #0x2c
   93cb0: e7950007     	ldr	r0, [r5, r7]
   93cb4: e3500000     	cmp	r0, #0
   93cb8: 0afffff9     	beq	0x93ca4 <.text+0x83ba4> @ imm = #-0x1c
   93cbc: eb13fff2     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4fffc8
   93cc0: e59f32c0     	ldr	r3, [pc, #0x2c0]        @ 0x93f88 <.text+0x83e88>
   93cc4: e7858007     	str	r8, [r5, r7]
   93cc8: e08f3003     	add	r3, pc, r3
   93ccc: e5935020     	ldr	r5, [r3, #0x20]
   93cd0: eafffff3     	b	0x93ca4 <.text+0x83ba4> @ imm = #-0x34
   93cd4: 0057dcd8     	ldrsbeq	sp, [r7], #-200
   93cd8: 0057dcc0     	subseq	sp, r7, r0, asr #25
   93cdc: 0057dc84     	subseq	sp, r7, r4, lsl #25
   93ce0: e3550000     	cmp	r5, #0
   93ce4: 0a000005     	beq	0x93d00 <.text+0x83c00> @ imm = #0x14
   93ce8: e1a00005     	mov	r0, r5
   93cec: eb13ffe6     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4fff98
   93cf0: e59f3294     	ldr	r3, [pc, #0x294]        @ 0x93f8c <.text+0x83e8c>
   93cf4: e3a00000     	mov	r0, #0
   93cf8: e08f3003     	add	r3, pc, r3
   93cfc: e5830020     	str	r0, [r3, #0x20]
   93d00: e5940000     	ldr	r0, [r4]
   93d04: e2401001     	sub	r1, r0, #1
   93d08: e0000190     	mul	r0, r0, r1
   93d0c: e3100001     	tst	r0, #1
   93d10: 0a000002     	beq	0x93d20 <.text+0x83c20> @ imm = #0x8
   93d14: e5990000     	ldr	r0, [r9]
   93d18: e3500009     	cmp	r0, #9
   93d1c: ca000009     	bgt	0x93d48 <.text+0x83c48> @ imm = #0x24
   93d20: e5940000     	ldr	r0, [r4]
   93d24: e3a02000     	mov	r2, #0
   93d28: e5832020     	str	r2, [r3, #0x20]
   93d2c: e2401001     	sub	r1, r0, #1
   93d30: e0010190     	mul	r1, r0, r1
   93d34: e5990000     	ldr	r0, [r9]
   93d38: e3110001     	tst	r1, #1
   93d3c: 0a000004     	beq	0x93d54 <.text+0x83c54> @ imm = #0x10
   93d40: e3500009     	cmp	r0, #9
   93d44: da000002     	ble	0x93d54 <.text+0x83c54> @ imm = #0x8
   93d48: e3a00000     	mov	r0, #0
   93d4c: e5830020     	str	r0, [r3, #0x20]
   93d50: eafffff2     	b	0x93d20 <.text+0x83c20> @ imm = #-0x38
   93d54: eb01aa43     	bl	0xfe668 <.text+0xee568> @ imm = #0x6a90c
   93d58: e59f3230     	ldr	r3, [pc, #0x230]        @ 0x93f90 <.text+0x83e90>
   93d5c: e1a08000     	mov	r8, r0
   93d60: e3020028     	movw	r0, #0x2028
   93d64: e08f3003     	add	r3, pc, r3
   93d68: e7930000     	ldr	r0, [r3, r0]
   93d6c: e3500000     	cmp	r0, #0
   93d70: 0a00004c     	beq	0x93ea8 <.text+0x83da8> @ imm = #0x130
   93d74: e3580001     	cmp	r8, #1
   93d78: ba000044     	blt	0x93e90 <.text+0x83d90> @ imm = #0x110
   93d7c: e3a07000     	mov	r7, #0
   93d80: e302a028     	movw	r10, #0x2028
   93d84: e3a05000     	mov	r5, #0
   93d88: ea00000b     	b	0x93dbc <.text+0x83cbc> @ imm = #0x2c
   93d8c: 0057dc0c     	subseq	sp, r7, r12, lsl #24
   93d90: 00554107     	subseq	r4, r5, r7, lsl #2
   93d94: 00554071     	subseq	r4, r5, r1, ror r0
   93d98: 00554097     	<unknown>
   93d9c: 005546d6     	ldrsbeq	r4, [r5], #-102
   93da0: 005540a7     	subseq	r4, r5, r7, lsr #1
   93da4: 00554011     	subseq	r4, r5, r1, lsl r0
   93da8: 00554037     	subseq	r4, r5, r7, lsr r0
   93dac: 00554676     	subseq	r4, r5, r6, ror r6
   93db0: e2855001     	add	r5, r5, #1
   93db4: e1580005     	cmp	r8, r5
   93db8: 0a000026     	beq	0x93e58 <.text+0x83d58> @ imm = #0x98
   93dbc: e7906105     	ldr	r6, [r0, r5, lsl #2]
   93dc0: e3560000     	cmp	r6, #0
   93dc4: 0afffff9     	beq	0x93db0 <.text+0x83cb0> @ imm = #-0x1c
   93dc8: e5940000     	ldr	r0, [r4]
   93dcc: e2401001     	sub	r1, r0, #1
   93dd0: e0000190     	mul	r0, r0, r1
   93dd4: e3100001     	tst	r0, #1
   93dd8: 0a000002     	beq	0x93de8 <.text+0x83ce8> @ imm = #0x8
   93ddc: e5990000     	ldr	r0, [r9]
   93de0: e3500009     	cmp	r0, #9
   93de4: ca000011     	bgt	0x93e30 <.text+0x83d30> @ imm = #0x44
   93de8: e1a00006     	mov	r0, r6
   93dec: eb13ffa6     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4ffe98
   93df0: e59f319c     	ldr	r3, [pc, #0x19c]        @ 0x93f94 <.text+0x83e94>
   93df4: e08f3003     	add	r3, pc, r3
   93df8: e1a00003     	mov	r0, r3
   93dfc: e7b0100a     	ldr	r1, [r0, r10]!
   93e00: e7817105     	str	r7, [r1, r5, lsl #2]
   93e04: e5901000     	ldr	r1, [r0]
   93e08: e7817105     	str	r7, [r1, r5, lsl #2]
   93e0c: e5941000     	ldr	r1, [r4]
   93e10: e5900000     	ldr	r0, [r0]
   93e14: e2412001     	sub	r2, r1, #1
   93e18: e0010291     	mul	r1, r1, r2
   93e1c: e3110001     	tst	r1, #1
   93e20: 0affffe2     	beq	0x93db0 <.text+0x83cb0> @ imm = #-0x78
   93e24: e5991000     	ldr	r1, [r9]
   93e28: e3510009     	cmp	r1, #9
   93e2c: daffffdf     	ble	0x93db0 <.text+0x83cb0> @ imm = #-0x84
   93e30: e1a00006     	mov	r0, r6
   93e34: eb13ff94     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4ffe50
   93e38: e59f024c     	ldr	r0, [pc, #0x24c]        @ 0x9408c <.text+0x83f8c>
   93e3c: e08f0000     	add	r0, pc, r0
   93e40: e7b0100a     	ldr	r1, [r0, r10]!
   93e44: e7817105     	str	r7, [r1, r5, lsl #2]
   93e48: e5900000     	ldr	r0, [r0]
   93e4c: e7807105     	str	r7, [r0, r5, lsl #2]
   93e50: eaffffe4     	b	0x93de8 <.text+0x83ce8> @ imm = #-0x70
   93e54: 0057db3c     	subseq	sp, r7, r12, lsr r11
   93e58: e5941000     	ldr	r1, [r4]
   93e5c: e2412001     	sub	r2, r1, #1
   93e60: e0010291     	mul	r1, r1, r2
   93e64: e3110001     	tst	r1, #1
   93e68: e5941000     	ldr	r1, [r4]
   93e6c: e2412001     	sub	r2, r1, #1
   93e70: e0010291     	mul	r1, r1, r2
   93e74: e3110001     	tst	r1, #1
   93e78: 0a000002     	beq	0x93e88 <.text+0x83d88> @ imm = #0x8
   93e7c: e5991000     	ldr	r1, [r9]
   93e80: e3510009     	cmp	r1, #9
   93e84: cafffff7     	bgt	0x93e68 <.text+0x83d68> @ imm = #-0x24
   93e88: e3500000     	cmp	r0, #0
   93e8c: 0a000005     	beq	0x93ea8 <.text+0x83da8> @ imm = #0x14
   93e90: eb13ff7d     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4ffdf4
   93e94: e59f30fc     	ldr	r3, [pc, #0xfc]         @ 0x93f98 <.text+0x83e98>
   93e98: e3020028     	movw	r0, #0x2028
   93e9c: e3a01000     	mov	r1, #0
   93ea0: e08f3003     	add	r3, pc, r3
   93ea4: e7831000     	str	r1, [r3, r0]
   93ea8: e59d7034     	ldr	r7, [sp, #0x34]
   93eac: e59d8044     	ldr	r8, [sp, #0x44]
   93eb0: e3570001     	cmp	r7, #1
   93eb4: ba000014     	blt	0x93f0c <.text+0x83e0c> @ imm = #0x50
   93eb8: e5930020     	ldr	r0, [r3, #0x20]
   93ebc: e3500000     	cmp	r0, #0
   93ec0: 0a000011     	beq	0x93f0c <.text+0x83e0c> @ imm = #0x44
   93ec4: e2805020     	add	r5, r0, #32
   93ec8: e3a06000     	mov	r6, #0
   93ecc: ea000006     	b	0x93eec <.text+0x83dec> @ imm = #0x18
   93ed0: 00553fff     	ldrsheq	r3, [r5], #-255
   93ed4: 00553f69     	subseq	r3, r5, r9, ror #30
   93ed8: 00553f8f     	subseq	r3, r5, pc, lsl #31
   93edc: 005545ce     	subseq	r4, r5, lr, asr #11
   93ee0: e2855028     	add	r5, r5, #40
   93ee4: e2577001     	subs	r7, r7, #1
   93ee8: 0a000007     	beq	0x93f0c <.text+0x83e0c> @ imm = #0x1c
   93eec: e5950000     	ldr	r0, [r5]
   93ef0: e3500000     	cmp	r0, #0
   93ef4: 0afffff9     	beq	0x93ee0 <.text+0x83de0> @ imm = #-0x1c
   93ef8: eb13ff63     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4ffd8c
   93efc: e5856000     	str	r6, [r5]
   93f00: eafffff6     	b	0x93ee0 <.text+0x83de0> @ imm = #-0x28
   93f04: 0057daac     	subseq	sp, r7, r12, lsr #21
   93f08: 0057da64     	subseq	sp, r7, r4, ror #20
   93f0c: e59d1040     	ldr	r1, [sp, #0x40]
   93f10: e3a000c8     	mov	r0, #200
   93f14: e0208091     	mla	r0, r1, r0, r8
   93f18: e5900130     	ldr	r0, [r0, #0x130]
   93f1c: e3500000     	cmp	r0, #0
   93f20: 1a000012     	bne	0x93f70 <.text+0x83e70> @ imm = #0x48
   93f24: e5940000     	ldr	r0, [r4]
   93f28: e2401001     	sub	r1, r0, #1
   93f2c: e0000190     	mul	r0, r0, r1
   93f30: e3100001     	tst	r0, #1
   93f34: 0a000002     	beq	0x93f44 <.text+0x83e44> @ imm = #0x8
   93f38: e5990000     	ldr	r0, [r9]
   93f3c: e3500009     	cmp	r0, #9
   93f40: ca000008     	bgt	0x93f68 <.text+0x83e68> @ imm = #0x20
   93f44: eb002e77     	bl	0x9f928 <.text+0x8f828> @ imm = #0xb9dc
   93f48: e5940000     	ldr	r0, [r4]
   93f4c: e2401001     	sub	r1, r0, #1
   93f50: e0000190     	mul	r0, r0, r1
   93f54: e3100001     	tst	r0, #1
   93f58: 0a000004     	beq	0x93f70 <.text+0x83e70> @ imm = #0x10
   93f5c: e5990000     	ldr	r0, [r9]
   93f60: e3500009     	cmp	r0, #9
   93f64: da000001     	ble	0x93f70 <.text+0x83e70> @ imm = #0x4
   93f68: eb002e6e     	bl	0x9f928 <.text+0x8f828> @ imm = #0xb9b8
   93f6c: eafffff4     	b	0x93f44 <.text+0x83e44> @ imm = #-0x30
   93f70: e3a00000     	mov	r0, #0
   93f74: eb1444d5     	bl	0x5a52d0 <.text+0x5951d0> @ imm = #0x511354
   93f78: 0057da34     	subseq	sp, r7, r4, lsr r10
   93f7c: 0057cef0     	ldrsheq	r12, [r7], #-224
   93f80: 0057cec8     	subseq	r12, r7, r8, asr #29
   93f84: 0057cd5c     	subseq	r12, r7, r12, asr sp
   93f88: 0057cd00     	subseq	r12, r7, r0, lsl #26
   93f8c: 0057ccd0     	ldrsbeq	r12, [r7], #-192
   93f90: 0057cc64     	subseq	r12, r7, r4, ror #24
   93f94: 0057cbd4     	ldrsbeq	r12, [r7], #-180
   93f98: 0057cb28     	subseq	r12, r7, r8, lsr #22
   93f9c: 00553e6b     	subseq	r3, r5, r11, ror #28
   93fa0: 00553dd5     	ldrsbeq	r3, [r5], #-213
   93fa4: 00553dfb     	ldrsheq	r3, [r5], #-219
   93fa8: 005546cf     	subseq	r4, r5, pc, asr #13
   93fac: 00553e17     	subseq	r3, r5, r7, lsl lr
   93fb0: 00553d81     	subseq	r3, r5, r1, lsl #27
   93fb4: 00553da7     	subseq	r3, r5, r7, lsr #27
   93fb8: 0055467b     	subseq	r4, r5, r11, ror r6
   93fbc: 00553d2b     	subseq	r3, r5, r11, lsr #26
   93fc0: 00553c99     	<unknown>
   93fc4: 00553cbb     	ldrheq	r3, [r5], #-203
   93fc8: 0057f82c     	subseq	pc, r7, r12, lsr #16
   93fcc: 00553cbf     	ldrheq	r3, [r5], #-207
   93fd0: 00553c2d     	subseq	r3, r5, sp, lsr #24
   93fd4: 00553c4f     	subseq	r3, r5, pc, asr #24
   93fd8: 0057f7d0     	ldrsbeq	pc, [r7], #-112
   93fdc: 0057d660     	subseq	sp, r7, r0, ror #12
   93fe0: 0057d62c     	subseq	sp, r7, r12, lsr #12
   93fe4: 0057d610     	subseq	sp, r7, r0, lsl r6
   93fe8: 0057f7c4     	subseq	pc, r7, r4, asr #15
   93fec: 0057d714     	subseq	sp, r7, r4, lsl r7
   93ff0: 0057d5a0     	subseq	sp, r7, r0, lsr #11
   93ff4: 0057d568     	subseq	sp, r7, r8, ror #10
   93ff8: 0057d548     	subseq	sp, r7, r8, asr #10
   93ffc: 00553bab     	subseq	r3, r5, r11, lsr #23
   94000: 00553b15     	subseq	r3, r5, r5, lsl r11
   94004: 00553b3b     	subseq	r3, r5, r11, lsr r11
   94008: 00554245     	subseq	r4, r5, r5, asr #4
   9400c: 0057d66c     	subseq	sp, r7, r12, ror #12
   94010: 0057d47c     	subseq	sp, r7, r12, ror r4
   94014: 00554186     	subseq	r4, r5, r6, lsl #3
   94018: 00553793     	<unknown>
   9401c: 00553701     	subseq	r3, r5, r1, lsl #14
   94020: 00553723     	subseq	r3, r5, r3, lsr #14
   94024: 005538ac     	subseq	r3, r5, r12, lsr #17
   94028: 005538ab     	subseq	r3, r5, r11, lsr #17
   9402c: 00553815     	subseq	r3, r5, r5, lsl r8
   94030: 0055383b     	subseq	r3, r5, r11, lsr r8
   94034: 00554148     	subseq	r4, r5, r8, asr #2
   94038: 0055385e     	subseq	r3, r5, lr, asr r8
   9403c: 0057f118     	subseq	pc, r7, r8, lsl r1
   94040: 00553e78     	subseq	r3, r5, r8, ror lr
   94044: 005534cb     	subseq	r3, r5, r11, asr #9
   94048: 00553439     	subseq	r3, r5, r9, lsr r4
   9404c: 0055345b     	subseq	r3, r5, r11, asr r4
   94050: 00553477     	subseq	r3, r5, r7, ror r4
   94054: 005533e5     	subseq	r3, r5, r5, ror #7
   94058: 00553407     	subseq	r3, r5, r7, lsl #8
   9405c: 00553593     	<unknown>
   94060: 005534fd     	ldrsheq	r3, [r5], #-77
   94064: 0055351f     	subseq	r3, r5, pc, lsl r5
   94068: 00553e53     	subseq	r3, r5, r3, asr lr
   9406c: 0057ef54     	subseq	lr, r7, r4, asr pc
   94070: 0057d5d4     	ldrsbeq	sp, [r7], #-84
   94074: 0057f788     	subseq	pc, r7, r8, lsl #15
   94078: 0057d518     	subseq	sp, r7, r8, lsl r5
   9407c: 0055374b     	subseq	r3, r5, r11, asr #14
   94080: 005536b9     	ldrheq	r3, [r5], #-105
   94084: 005536db     	ldrsbeq	r3, [r5], #-107
   94088: 0055382e     	subseq	r3, r5, lr, lsr #16
   9408c: 0057cb8c     	subseq	r12, r7, r12, lsl #23


/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   94c5c: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   94c60: e28db01c     	add	r11, sp, #28
   94c64: e24dd024     	sub	sp, sp, #36
   94c68: e59f8318     	ldr	r8, [pc, #0x318]        @ 0x94f88 <.text+0x84e88>
   94c6c: e1a0a000     	mov	r10, r0
   94c70: e5909018     	ldr	r9, [r0, #0x18]
   94c74: e3020034     	movw	r0, #0x2034
   94c78: e08f8008     	add	r8, pc, r8
   94c7c: e1a04001     	mov	r4, r1
   94c80: e7985000     	ldr	r5, [r8, r0]
   94c84: eb01a4cc     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x69330
   94c88: e1a07000     	mov	r7, r0
   94c8c: e59a020c     	ldr	r0, [r10, #0x20c]
   94c90: e3a06000     	mov	r6, #0
   94c94: e1500004     	cmp	r0, r4
   94c98: 0a000088     	beq	0x94ec0 <.text+0x84dc0> @ imm = #0x220
   94c9c: e3570006     	cmp	r7, #6
   94ca0: 0a000021     	beq	0x94d2c <.text+0x84c2c> @ imm = #0x84
   94ca4: e1500004     	cmp	r0, r4
   94ca8: ca00001f     	bgt	0x94d2c <.text+0x84c2c> @ imm = #0x7c
   94cac: e1a0000a     	mov	r0, r10
   94cb0: e58d5010     	str	r5, [sp, #0x10]
   94cb4: e1a05009     	mov	r5, r9
   94cb8: e58d9014     	str	r9, [sp, #0x14]
   94cbc: ebff209f     	bl	0x5cf40 <.text+0x4ce40> @ imm = #-0x37d84
   94cc0: e59f12d4     	ldr	r1, [pc, #0x2d4]        @ 0x94f9c <.text+0x84e9c>
   94cc4: e28d0018     	add	r0, sp, #24
   94cc8: e1a0200a     	mov	r2, r10
   94ccc: e79f1001     	ldr	r1, [pc, r1]
   94cd0: eb143ef2     	bl	0x5a48a0 <.text+0x5947a0> @ imm = #0x50fbc8
   94cd4: e1a0000a     	mov	r0, r10
   94cd8: e3570000     	cmp	r7, #0
   94cdc: 0a000025     	beq	0x94d78 <.text+0x84c78> @ imm = #0x94
   94ce0: e3a01000     	mov	r1, #0
   94ce4: e1a02004     	mov	r2, r4
   94ce8: ebff3120     	bl	0x61170 <.text+0x51070> @ imm = #-0x33b80
   94cec: e3500000     	cmp	r0, #0
   94cf0: 0a000032     	beq	0x94dc0 <.text+0x84cc0> @ imm = #0xc8
   94cf4: e59f02cc     	ldr	r0, [pc, #0x2cc]        @ 0x94fc8 <.text+0x84ec8>
   94cf8: e3a07001     	mov	r7, #1
   94cfc: e59f12c8     	ldr	r1, [pc, #0x2c8]        @ 0x94fcc <.text+0x84ecc>
   94d00: e59f22c8     	ldr	r2, [pc, #0x2c8]        @ 0x94fd0 <.text+0x84ed0>
   94d04: e08f0000     	add	r0, pc, r0
   94d08: e59f32c4     	ldr	r3, [pc, #0x2c4]        @ 0x94fd4 <.text+0x84ed4>
   94d0c: e08f1001     	add	r1, pc, r1
   94d10: e08f2002     	add	r2, pc, r2
   94d14: e58d7000     	str	r7, [sp]
   94d18: e08f3003     	add	r3, pc, r3
   94d1c: e58d3004     	str	r3, [sp, #0x4]
   94d20: e3003dbe     	movw	r3, #0xdbe
   94d24: eb0194e6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x65398
   94d28: ea000024     	b	0x94dc0 <.text+0x84cc0> @ imm = #0x90
   94d2c: e1a0000a     	mov	r0, r10
   94d30: e1a01004     	mov	r1, r4
   94d34: ebff24d2     	bl	0x5e084 <.text+0x4df84> @ imm = #-0x36cb8
   94d38: e3500000     	cmp	r0, #0
   94d3c: 0a00005f     	beq	0x94ec0 <.text+0x84dc0> @ imm = #0x17c
   94d40: e59f0244     	ldr	r0, [pc, #0x244]        @ 0x94f8c <.text+0x84e8c>
   94d44: e3a07001     	mov	r7, #1
   94d48: e59f1240     	ldr	r1, [pc, #0x240]        @ 0x94f90 <.text+0x84e90>
   94d4c: e59f2240     	ldr	r2, [pc, #0x240]        @ 0x94f94 <.text+0x84e94>
   94d50: e08f0000     	add	r0, pc, r0
   94d54: e59f323c     	ldr	r3, [pc, #0x23c]        @ 0x94f98 <.text+0x84e98>
   94d58: e08f1001     	add	r1, pc, r1
   94d5c: e08f2002     	add	r2, pc, r2
   94d60: e58d7000     	str	r7, [sp]
   94d64: e08f3003     	add	r3, pc, r3
   94d68: e98d0018     	stmib	sp, {r3, r4}
   94d6c: e3003dad     	movw	r3, #0xdad
   94d70: eb0194d3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6534c
   94d74: ea000050     	b	0x94ebc <.text+0x84dbc> @ imm = #0x140
   94d78: e3a01001     	mov	r1, #1
   94d7c: e1a02004     	mov	r2, r4
   94d80: ebff30a1     	bl	0x6100c <.text+0x50f0c> @ imm = #-0x33d7c
   94d84: e3500000     	cmp	r0, #0
   94d88: 0a00000c     	beq	0x94dc0 <.text+0x84cc0> @ imm = #0x30
   94d8c: e59f920c     	ldr	r9, [pc, #0x20c]        @ 0x94fa0 <.text+0x84ea0>
   94d90: e79f9009     	ldr	r9, [pc, r9]
   94d94: e5990000     	ldr	r0, [r9]
   94d98: e59f7204     	ldr	r7, [pc, #0x204]        @ 0x94fa4 <.text+0x84ea4>
   94d9c: e2401001     	sub	r1, r0, #1
   94da0: e0000190     	mul	r0, r0, r1
   94da4: e79f7007     	ldr	r7, [pc, r7]
   94da8: e3100001     	tst	r0, #1
   94dac: 0a000052     	beq	0x94efc <.text+0x84dfc> @ imm = #0x148
   94db0: e5970000     	ldr	r0, [r7]
   94db4: e3500009     	cmp	r0, #9
   94db8: ca000064     	bgt	0x94f50 <.text+0x84e50> @ imm = #0x190
   94dbc: ea00004e     	b	0x94efc <.text+0x84dfc> @ imm = #0x138
   94dc0: e28d0018     	add	r0, sp, #24
   94dc4: e3a01000     	mov	r1, #0
   94dc8: eb143eb6     	bl	0x5a48a8 <.text+0x5947a8> @ imm = #0x50fad8
   94dcc: e1a0000a     	mov	r0, r10
   94dd0: ebff2085     	bl	0x5cfec <.text+0x4ceec> @ imm = #-0x37dec
   94dd4: e59f01fc     	ldr	r0, [pc, #0x1fc]        @ 0x94fd8 <.text+0x84ed8>
   94dd8: e08f0000     	add	r0, pc, r0
   94ddc: e5d00000     	ldrb	r0, [r0]
   94de0: e3500000     	cmp	r0, #0
   94de4: 0a000034     	beq	0x94ebc <.text+0x84dbc> @ imm = #0xd0
   94de8: e59d2010     	ldr	r2, [sp, #0x10]
   94dec: e3a000c8     	mov	r0, #200
   94df0: e59d1014     	ldr	r1, [sp, #0x14]
   94df4: e0201092     	mla	r0, r2, r0, r1
   94df8: e5900144     	ldr	r0, [r0, #0x144]
   94dfc: e3500001     	cmp	r0, #1
   94e00: ba000015     	blt	0x94e5c <.text+0x84d5c> @ imm = #0x54
   94e04: e3500ffa     	cmp	r0, #1000
   94e08: 3a000013     	blo	0x94e5c <.text+0x84d5c> @ imm = #0x4c
   94e0c: e3041dd3     	movw	r1, #0x4dd3
   94e10: e59f51c4     	ldr	r5, [pc, #0x1c4]        @ 0x94fdc <.text+0x84edc>
   94e14: e3411062     	movt	r1, #0x1062
   94e18: e59f91c0     	ldr	r9, [pc, #0x1c0]        @ 0x94fe0 <.text+0x84ee0>
   94e1c: e0810190     	umull	r0, r1, r0, r1
   94e20: e08f5005     	add	r5, pc, r5
   94e24: e08f9009     	add	r9, pc, r9
   94e28: e1a06321     	lsr	r6, r1, #6
   94e2c: e1a00005     	mov	r0, r5
   94e30: eb1444b4     	bl	0x5a6108 <.text+0x596008> @ imm = #0x5112d0
   94e34: e1a00005     	mov	r0, r5
   94e38: e5d97000     	ldrb	r7, [r9]
   94e3c: eb144620     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x511880
   94e40: e3570000     	cmp	r7, #0
   94e44: 1a000004     	bne	0x94e5c <.text+0x84d5c> @ imm = #0x10
   94e48: e3a00ffa     	mov	r0, #1000
   94e4c: e2466001     	sub	r6, r6, #1
   94e50: eb01e839     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x7a0e4
   94e54: e3560000     	cmp	r6, #0
   94e58: cafffff3     	bgt	0x94e2c <.text+0x84d2c> @ imm = #-0x34
   94e5c: e59f0180     	ldr	r0, [pc, #0x180]        @ 0x94fe4 <.text+0x84ee4>
   94e60: e79f0000     	ldr	r0, [pc, r0]
   94e64: e5901000     	ldr	r1, [r0]
   94e68: e2412001     	sub	r2, r1, #1
   94e6c: e0020291     	mul	r2, r1, r2
   94e70: e59f1170     	ldr	r1, [pc, #0x170]        @ 0x94fe8 <.text+0x84ee8>
   94e74: e79f1001     	ldr	r1, [pc, r1]
   94e78: e3120001     	tst	r2, #1
   94e7c: 0a000002     	beq	0x94e8c <.text+0x84d8c> @ imm = #0x8
   94e80: e5912000     	ldr	r2, [r1]
   94e84: e3520009     	cmp	r2, #9
   94e88: c5884008     	strgt	r4, [r8, #0x8]
   94e8c: e5902000     	ldr	r2, [r0]
   94e90: e3a06000     	mov	r6, #0
   94e94: e5884008     	str	r4, [r8, #0x8]
   94e98: e2423001     	sub	r3, r2, #1
   94e9c: e0030392     	mul	r3, r2, r3
   94ea0: e5912000     	ldr	r2, [r1]
   94ea4: e3130001     	tst	r3, #1
   94ea8: 0a000004     	beq	0x94ec0 <.text+0x84dc0> @ imm = #0x10
   94eac: e3520009     	cmp	r2, #9
   94eb0: da000002     	ble	0x94ec0 <.text+0x84dc0> @ imm = #0x8
   94eb4: e5884008     	str	r4, [r8, #0x8]
   94eb8: eafffff3     	b	0x94e8c <.text+0x84d8c> @ imm = #-0x34
   94ebc: e3e06000     	mvn	r6, #0
   94ec0: e59f0124     	ldr	r0, [pc, #0x124]        @ 0x94fec <.text+0x84eec>
   94ec4: e79f0000     	ldr	r0, [pc, r0]
   94ec8: e59f1120     	ldr	r1, [pc, #0x120]        @ 0x94ff0 <.text+0x84ef0>
   94ecc: e79f1001     	ldr	r1, [pc, r1]
   94ed0: e5902000     	ldr	r2, [r0]
   94ed4: e2423001     	sub	r3, r2, #1
   94ed8: e0020392     	mul	r2, r2, r3
   94edc: e3120001     	tst	r2, #1
   94ee0: 0a000002     	beq	0x94ef0 <.text+0x84df0> @ imm = #0x8
   94ee4: e5912000     	ldr	r2, [r1]
   94ee8: e3520009     	cmp	r2, #9
   94eec: cafffff7     	bgt	0x94ed0 <.text+0x84dd0> @ imm = #-0x24
   94ef0: e1a00006     	mov	r0, r6
   94ef4: e24bd01c     	sub	sp, r11, #28
   94ef8: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   94efc: e59f00a4     	ldr	r0, [pc, #0xa4]         @ 0x94fa8 <.text+0x84ea8>
   94f00: e3a06001     	mov	r6, #1
   94f04: e59f10a0     	ldr	r1, [pc, #0xa0]         @ 0x94fac <.text+0x84eac>
   94f08: e59f20a0     	ldr	r2, [pc, #0xa0]         @ 0x94fb0 <.text+0x84eb0>
   94f0c: e08f0000     	add	r0, pc, r0
   94f10: e59f309c     	ldr	r3, [pc, #0x9c]         @ 0x94fb4 <.text+0x84eb4>
   94f14: e08f1001     	add	r1, pc, r1
   94f18: e08f2002     	add	r2, pc, r2
   94f1c: e58d6000     	str	r6, [sp]
   94f20: e08f3003     	add	r3, pc, r3
   94f24: e58d3004     	str	r3, [sp, #0x4]
   94f28: e3003dba     	movw	r3, #0xdba
   94f2c: eb019464     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x65190
   94f30: e5990000     	ldr	r0, [r9]
   94f34: e2401001     	sub	r1, r0, #1
   94f38: e0000190     	mul	r0, r0, r1
   94f3c: e3100001     	tst	r0, #1
   94f40: 0affff9e     	beq	0x94dc0 <.text+0x84cc0> @ imm = #-0x188
   94f44: e5970000     	ldr	r0, [r7]
   94f48: e350000a     	cmp	r0, #10
   94f4c: baffff9b     	blt	0x94dc0 <.text+0x84cc0> @ imm = #-0x194
   94f50: e59f0060     	ldr	r0, [pc, #0x60]         @ 0x94fb8 <.text+0x84eb8>
   94f54: e3a06001     	mov	r6, #1
   94f58: e59f105c     	ldr	r1, [pc, #0x5c]         @ 0x94fbc <.text+0x84ebc>
   94f5c: e59f205c     	ldr	r2, [pc, #0x5c]         @ 0x94fc0 <.text+0x84ec0>
   94f60: e08f0000     	add	r0, pc, r0
   94f64: e59f3058     	ldr	r3, [pc, #0x58]         @ 0x94fc4 <.text+0x84ec4>
   94f68: e08f1001     	add	r1, pc, r1
   94f6c: e08f2002     	add	r2, pc, r2
   94f70: e58d6000     	str	r6, [sp]
   94f74: e08f3003     	add	r3, pc, r3
   94f78: e58d3004     	str	r3, [sp, #0x4]
   94f7c: e3003dba     	movw	r3, #0xdba
   94f80: eb01944f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x6513c
   94f84: eaffffdc     	b	0x94efc <.text+0x84dfc> @ imm = #-0x90
   94f88: 0057bd50     	subseq	r11, r7, r0, asr sp
   94f8c: 0055218f     	subseq	r2, r5, pc, lsl #3
   94f90: 005520f9     	ldrsheq	r2, [r5], #-9
   94f94: 0055211f     	subseq	r2, r5, pc, lsl r1
   94f98: 005527a7     	subseq	r2, r5, r7, lsr #15
   94f9c: 0054a388     	subseq	r10, r4, r8, lsl #7
   94fa0: 0054a510     	subseq	r10, r4, r0, lsl r5
   94fa4: 0054b158     	subseq	r11, r4, r8, asr r1
   94fa8: 00551fd3     	ldrsbeq	r1, [r5], #-243
   94fac: 00551f3d     	subseq	r1, r5, sp, lsr pc
   94fb0: 00551f63     	subseq	r1, r5, r3, ror #30
   94fb4: 0055261f     	subseq	r2, r5, pc, lsl r6
   94fb8: 00551f7f     	subseq	r1, r5, pc, ror pc
   94fbc: 00551ee9     	subseq	r1, r5, r9, ror #29
   94fc0: 00551f0f     	subseq	r1, r5, pc, lsl #30
   94fc4: 005525cb     	subseq	r2, r5, r11, asr #11
   94fc8: 005521db     	ldrsbeq	r2, [r5], #-27
   94fcc: 00552145     	subseq	r2, r5, r5, asr #2
   94fd0: 0055216b     	subseq	r2, r5, r11, ror #2
   94fd4: 00552827     	subseq	r2, r5, r7, lsr #16
   94fd8: 0057dc40     	subseq	sp, r7, r0, asr #24
   94fdc: 0057dbfc     	ldrsheq	sp, [r7], #-188
   94fe0: 0057dc10     	subseq	sp, r7, r0, lsl r12
   94fe4: 0054a440     	subseq	r10, r4, r0, asr #8
   94fe8: 0054b088     	subseq	r11, r4, r8, lsl #1
   94fec: 0054a3dc     	ldrsbeq	r10, [r4], #-60
   94ff0: 0054b030     	subseq	r11, r4, r0, lsr r0
   94ff4: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   94ff8: e28db01c     	add	r11, sp, #28
   94ffc: e24dd00c     	sub	sp, sp, #12
   95000: e59f52ec     	ldr	r5, [pc, #0x2ec]        @ 0x952f4 <.text+0x851f4>
   95004: e3510000     	cmp	r1, #0
   95008: e1a09000     	mov	r9, r0
   9500c: e79f5005     	ldr	r5, [pc, r5]
   95010: 11a00005     	movne	r0, r5
   95014: 1b0001d5     	blne	0x95770 <.text+0x85670> @ imm = #0x754
   95018: e59f82d8     	ldr	r8, [pc, #0x2d8]        @ 0x952f8 <.text+0x851f8>
   9501c: e302002c     	movw	r0, #0x202c
   95020: e3a01000     	mov	r1, #0
   95024: e08f8008     	add	r8, pc, r8
   95028: e7881000     	str	r1, [r8, r0]
   9502c: e5986008     	ldr	r6, [r8, #0x8]
   95030: e595020c     	ldr	r0, [r5, #0x20c]
   95034: e1500006     	cmp	r0, r6
   95038: 0a000030     	beq	0x95100 <.text+0x85000> @ imm = #0xc0
   9503c: e59f42b8     	ldr	r4, [pc, #0x2b8]        @ 0x952fc <.text+0x851fc>
   95040: e2857050     	add	r7, r5, #80
   95044: e79f4004     	ldr	r4, [pc, r4]
   95048: e5940000     	ldr	r0, [r4]
   9504c: e59fa2ac     	ldr	r10, [pc, #0x2ac]       @ 0x95300 <.text+0x85200>
   95050: e2401001     	sub	r1, r0, #1
   95054: e0000190     	mul	r0, r0, r1
   95058: e79fa00a     	ldr	r10, [pc, r10]
   9505c: e3100001     	tst	r0, #1
   95060: 0a000002     	beq	0x95070 <.text+0x84f70> @ imm = #0x8
   95064: e59a0000     	ldr	r0, [r10]
   95068: e3500009     	cmp	r0, #9
   9506c: ca00000d     	bgt	0x950a8 <.text+0x84fa8> @ imm = #0x34
   95070: e1a00007     	mov	r0, r7
   95074: e1a01006     	mov	r1, r6
   95078: ebfeed42     	bl	0x50588 <.text+0x40488> @ imm = #-0x44af8
   9507c: e1a01000     	mov	r1, r0
   95080: e1a00005     	mov	r0, r5
   95084: ebfffef4     	bl	0x94c5c <.text+0x84b5c> @ imm = #-0x430
   95088: e5941000     	ldr	r1, [r4]
   9508c: e2412001     	sub	r2, r1, #1
   95090: e0010291     	mul	r1, r1, r2
   95094: e3110001     	tst	r1, #1
   95098: 0a000009     	beq	0x950c4 <.text+0x84fc4> @ imm = #0x24
   9509c: e59a1000     	ldr	r1, [r10]
   950a0: e3510009     	cmp	r1, #9
   950a4: da000006     	ble	0x950c4 <.text+0x84fc4> @ imm = #0x18
   950a8: e1a00007     	mov	r0, r7
   950ac: e1a01006     	mov	r1, r6
   950b0: ebfeed34     	bl	0x50588 <.text+0x40488> @ imm = #-0x44b30
   950b4: e1a01000     	mov	r1, r0
   950b8: e1a00005     	mov	r0, r5
   950bc: ebfffee6     	bl	0x94c5c <.text+0x84b5c> @ imm = #-0x468
   950c0: eaffffea     	b	0x95070 <.text+0x84f70> @ imm = #-0x58
   950c4: e3500000     	cmp	r0, #0
   950c8: 0a00000c     	beq	0x95100 <.text+0x85000> @ imm = #0x30
   950cc: e5940000     	ldr	r0, [r4]
   950d0: e59f622c     	ldr	r6, [pc, #0x22c]        @ 0x95304 <.text+0x85204>
   950d4: e2401001     	sub	r1, r0, #1
   950d8: e59f7228     	ldr	r7, [pc, #0x228]        @ 0x95308 <.text+0x85208>
   950dc: e08f6006     	add	r6, pc, r6
   950e0: e0000190     	mul	r0, r0, r1
   950e4: e08f7007     	add	r7, pc, r7
   950e8: e3100001     	tst	r0, #1
   950ec: 0a000029     	beq	0x95198 <.text+0x85098> @ imm = #0xa4
   950f0: e59a0000     	ldr	r0, [r10]
   950f4: e3500009     	cmp	r0, #9
   950f8: ca000040     	bgt	0x95200 <.text+0x85100> @ imm = #0x100
   950fc: ea000025     	b	0x95198 <.text+0x85098> @ imm = #0x94
   95100: e5d500b0     	ldrb	r0, [r5, #0xb0]
   95104: e3500000     	cmp	r0, #0
   95108: 0a000069     	beq	0x952b4 <.text+0x851b4> @ imm = #0x1a4
   9510c: e59f4210     	ldr	r4, [pc, #0x210]        @ 0x95324 <.text+0x85224>
   95110: e79f4004     	ldr	r4, [pc, r4]
   95114: e59f520c     	ldr	r5, [pc, #0x20c]        @ 0x95328 <.text+0x85228>
   95118: e79f5005     	ldr	r5, [pc, r5]
   9511c: e5940000     	ldr	r0, [r4]
   95120: e2401001     	sub	r1, r0, #1
   95124: e0000190     	mul	r0, r0, r1
   95128: e3100001     	tst	r0, #1
   9512c: 0a000002     	beq	0x9513c <.text+0x8503c> @ imm = #0x8
   95130: e5950000     	ldr	r0, [r5]
   95134: e3500009     	cmp	r0, #9
   95138: cafffff7     	bgt	0x9511c <.text+0x8501c> @ imm = #-0x24
   9513c: e3590006     	cmp	r9, #6
   95140: 2a000008     	bhs	0x95168 <.text+0x85068> @ imm = #0x20
   95144: e5940000     	ldr	r0, [r4]
   95148: e2401001     	sub	r1, r0, #1
   9514c: e0000190     	mul	r0, r0, r1
   95150: e3100001     	tst	r0, #1
   95154: 0a000049     	beq	0x95280 <.text+0x85180> @ imm = #0x124
   95158: e5950000     	ldr	r0, [r5]
   9515c: e3500009     	cmp	r0, #9
   95160: ca000050     	bgt	0x952a8 <.text+0x851a8> @ imm = #0x140
   95164: ea000045     	b	0x95280 <.text+0x85180> @ imm = #0x114
   95168: e2490006     	sub	r0, r9, #6
   9516c: e3500003     	cmp	r0, #3
   95170: 2a00004f     	bhs	0x952b4 <.text+0x851b4> @ imm = #0x13c
   95174: e5940000     	ldr	r0, [r4]
   95178: e2401001     	sub	r1, r0, #1
   9517c: e0000190     	mul	r0, r0, r1
   95180: e3100001     	tst	r0, #1
   95184: 0a000030     	beq	0x9524c <.text+0x8514c> @ imm = #0xc0
   95188: e5950000     	ldr	r0, [r5]
   9518c: e3500009     	cmp	r0, #9
   95190: ca000037     	bgt	0x95274 <.text+0x85174> @ imm = #0xdc
   95194: ea00002c     	b	0x9524c <.text+0x8514c> @ imm = #0xb0
   95198: e59f016c     	ldr	r0, [pc, #0x16c]        @ 0x9530c <.text+0x8520c>
   9519c: e3a03001     	mov	r3, #1
   951a0: e59f1168     	ldr	r1, [pc, #0x168]        @ 0x95310 <.text+0x85210>
   951a4: e59f2168     	ldr	r2, [pc, #0x168]        @ 0x95314 <.text+0x85214>
   951a8: e08f0000     	add	r0, pc, r0
   951ac: e08f1001     	add	r1, pc, r1
   951b0: e88d0048     	stm	sp, {r3, r6}
   951b4: e08f2002     	add	r2, pc, r2
   951b8: e3003de1     	movw	r3, #0xde1
   951bc: eb0193c0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x64f00
   951c0: e30100b4     	movw	r0, #0x10b4
   951c4: e30017da     	movw	r1, #0x7da
   951c8: e0850000     	add	r0, r5, r0
   951cc: ebfed2b1     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x4b53c
   951d0: e1a00005     	mov	r0, r5
   951d4: ebff4769     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2e25c
   951d8: e5940000     	ldr	r0, [r4]
   951dc: e3a02000     	mov	r2, #0
   951e0: e5c72000     	strb	r2, [r7]
   951e4: e2401001     	sub	r1, r0, #1
   951e8: e0010190     	mul	r1, r0, r1
   951ec: e59a0000     	ldr	r0, [r10]
   951f0: e3110001     	tst	r1, #1
   951f4: 0a000030     	beq	0x952bc <.text+0x851bc> @ imm = #0xc0
   951f8: e350000a     	cmp	r0, #10
   951fc: ba00002e     	blt	0x952bc <.text+0x851bc> @ imm = #0xb8
   95200: e59f0110     	ldr	r0, [pc, #0x110]        @ 0x95318 <.text+0x85218>
   95204: e3a03001     	mov	r3, #1
   95208: e59f110c     	ldr	r1, [pc, #0x10c]        @ 0x9531c <.text+0x8521c>
   9520c: e59f210c     	ldr	r2, [pc, #0x10c]        @ 0x95320 <.text+0x85220>
   95210: e08f0000     	add	r0, pc, r0
   95214: e08f1001     	add	r1, pc, r1
   95218: e88d0048     	stm	sp, {r3, r6}
   9521c: e08f2002     	add	r2, pc, r2
   95220: e3003de1     	movw	r3, #0xde1
   95224: eb0193a6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x64e98
   95228: e30100b4     	movw	r0, #0x10b4
   9522c: e30017da     	movw	r1, #0x7da
   95230: e0850000     	add	r0, r5, r0
   95234: ebfed297     	bl	0x49c98 <.text+0x39b98> @ imm = #-0x4b5a4
   95238: e1a00005     	mov	r0, r5
   9523c: ebff474f     	bl	0x66f80 <.text+0x56e80> @ imm = #-0x2e2c4
   95240: e3a00000     	mov	r0, #0
   95244: e5c70000     	strb	r0, [r7]
   95248: eaffffd2     	b	0x95198 <.text+0x85098> @ imm = #-0xb8
   9524c: e3a00000     	mov	r0, #0
   95250: ebfed6c0     	bl	0x4ad58 <.text+0x3ac58> @ imm = #-0x4a500
   95254: e5940000     	ldr	r0, [r4]
   95258: e2401001     	sub	r1, r0, #1
   9525c: e0000190     	mul	r0, r0, r1
   95260: e3100001     	tst	r0, #1
   95264: 0a000012     	beq	0x952b4 <.text+0x851b4> @ imm = #0x48
   95268: e5950000     	ldr	r0, [r5]
   9526c: e3500009     	cmp	r0, #9
   95270: da00000f     	ble	0x952b4 <.text+0x851b4> @ imm = #0x3c
   95274: e3a00000     	mov	r0, #0
   95278: ebfed6b6     	bl	0x4ad58 <.text+0x3ac58> @ imm = #-0x4a528
   9527c: eafffff2     	b	0x9524c <.text+0x8514c> @ imm = #-0x38
   95280: e3a00001     	mov	r0, #1
   95284: ebfed6b3     	bl	0x4ad58 <.text+0x3ac58> @ imm = #-0x4a534
   95288: e5940000     	ldr	r0, [r4]
   9528c: e2401001     	sub	r1, r0, #1
   95290: e0000190     	mul	r0, r0, r1
   95294: e3100001     	tst	r0, #1
   95298: 0a000005     	beq	0x952b4 <.text+0x851b4> @ imm = #0x14
   9529c: e5950000     	ldr	r0, [r5]
   952a0: e350000a     	cmp	r0, #10
   952a4: ba000002     	blt	0x952b4 <.text+0x851b4> @ imm = #0x8
   952a8: e3a00001     	mov	r0, #1
   952ac: ebfed6a9     	bl	0x4ad58 <.text+0x3ac58> @ imm = #-0x4a55c
   952b0: eafffff2     	b	0x95280 <.text+0x85180> @ imm = #-0x38
   952b4: e3020030     	movw	r0, #0x2030
   952b8: e7889000     	str	r9, [r8, r0]
   952bc: e59f0068     	ldr	r0, [pc, #0x68]         @ 0x9532c <.text+0x8522c>
   952c0: e79f0000     	ldr	r0, [pc, r0]
   952c4: e59f1064     	ldr	r1, [pc, #0x64]         @ 0x95330 <.text+0x85230>
   952c8: e79f1001     	ldr	r1, [pc, r1]
   952cc: e5902000     	ldr	r2, [r0]
   952d0: e2423001     	sub	r3, r2, #1
   952d4: e0020392     	mul	r2, r2, r3
   952d8: e3120001     	tst	r2, #1
   952dc: 0a000002     	beq	0x952ec <.text+0x851ec> @ imm = #0x8
   952e0: e5912000     	ldr	r2, [r1]
   952e4: e3520009     	cmp	r2, #9
   952e8: cafffff7     	bgt	0x952cc <.text+0x851cc> @ imm = #-0x24
   952ec: e24bd01c     	sub	sp, r11, #28
   952f0: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   952f4: 0057b9bc     	ldrheq	r11, [r7], #-156
   952f8: 0057b9a4     	subseq	r11, r7, r4, lsr #19
   952fc: 0054af64     	subseq	r10, r4, r4, ror #30
   95300: 0054a200     	subseq	r10, r4, r0, lsl #4
   95304: 005523e6     	subseq	r2, r5, r6, ror #7
   95308: 0057d934     	subseq	sp, r7, r4, lsr r9
   9530c: 00551d37     	subseq	r1, r5, r7, lsr sp
   95310: 00551ca5     	subseq	r1, r5, r5, lsr #25
   95314: 00551cc7     	subseq	r1, r5, r7, asr #25
   95318: 00551ccf     	subseq	r1, r5, pc, asr #25
   9531c: 00551c3d     	subseq	r1, r5, sp, lsr r12
   95320: 00551c5f     	subseq	r1, r5, pc, asr r12
   95324: 0054ae98     	<unknown>
   95328: 0054a140     	subseq	r10, r4, r0, asr #2
   9532c: 0054ace8     	subseq	r10, r4, r8, ror #25
   95330: 00549f90     	<unknown>
   95334: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   95338: e28db01c     	add	r11, sp, #28
   9533c: e24dd014     	sub	sp, sp, #20
   95340: e59f73f4     	ldr	r7, [pc, #0x3f4]        @ 0x9573c <.text+0x8563c>
   95344: e1a04000     	mov	r4, r0
   95348: e1a06001     	mov	r6, r1
   9534c: e79f7007     	ldr	r7, [pc, r7]
   95350: e5970000     	ldr	r0, [r7]
   95354: e2401001     	sub	r1, r0, #1
   95358: e0000190     	mul	r0, r0, r1
   9535c: e3100001     	tst	r0, #1
   95360: e5970000     	ldr	r0, [r7]
   95364: e59f53d4     	ldr	r5, [pc, #0x3d4]        @ 0x95740 <.text+0x85640>
   95368: e2401001     	sub	r1, r0, #1
   9536c: e0010190     	mul	r1, r0, r1
   95370: e79f5005     	ldr	r5, [pc, r5]
   95374: e5d400b0     	ldrb	r0, [r4, #0xb0]
   95378: e3110001     	tst	r1, #1
   9537c: 0a000002     	beq	0x9538c <.text+0x8528c> @ imm = #0x8
   95380: e5951000     	ldr	r1, [r5]
   95384: e3510009     	cmp	r1, #9
   95388: cafffff4     	bgt	0x95360 <.text+0x85260> @ imm = #-0x30
   9538c: e3500000     	cmp	r0, #0
   95390: 0a000006     	beq	0x953b0 <.text+0x852b0> @ imm = #0x18
   95394: e59410b8     	ldr	r1, [r4, #0xb8]
   95398: e5940fc8     	ldr	r0, [r4, #0xfc8]
   9539c: ebfed9ee     	bl	0x4bb5c <.text+0x3ba5c> @ imm = #-0x49848
   953a0: e1a01000     	mov	r1, r0
   953a4: e3e00000     	mvn	r0, #0
   953a8: e3510000     	cmp	r1, #0
   953ac: 0a0000d8     	beq	0x95714 <.text+0x85614> @ imm = #0x360
   953b0: e58d6010     	str	r6, [sp, #0x10]
   953b4: e5970000     	ldr	r0, [r7]
   953b8: e2401001     	sub	r1, r0, #1
   953bc: e0000190     	mul	r0, r0, r1
   953c0: e3100001     	tst	r0, #1
   953c4: 0a000002     	beq	0x953d4 <.text+0x852d4> @ imm = #0x8
   953c8: e5950000     	ldr	r0, [r5]
   953cc: e3500009     	cmp	r0, #9
   953d0: cafffff7     	bgt	0x953b4 <.text+0x852b4> @ imm = #-0x24
   953d4: e59f9368     	ldr	r9, [pc, #0x368]        @ 0x95744 <.text+0x85644>
   953d8: e3e060b3     	mvn	r6, #179
   953dc: e59fa364     	ldr	r10, [pc, #0x364]       @ 0x95748 <.text+0x85648>
   953e0: e08f9009     	add	r9, pc, r9
   953e4: e08fa00a     	add	r10, pc, r10
   953e8: e1a00009     	mov	r0, r9
   953ec: eb144345     	bl	0x5a6108 <.text+0x596008> @ imm = #0x510d14
   953f0: e1a00009     	mov	r0, r9
   953f4: e5da8000     	ldrb	r8, [r10]
   953f8: eb1444b1     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x5112c4
   953fc: e3580000     	cmp	r8, #0
   95400: 1a00001c     	bne	0x95478 <.text+0x85378> @ imm = #0x70
   95404: e5970000     	ldr	r0, [r7]
   95408: e2401001     	sub	r1, r0, #1
   9540c: e0000190     	mul	r0, r0, r1
   95410: e3100001     	tst	r0, #1
   95414: 0a000002     	beq	0x95424 <.text+0x85324> @ imm = #0x8
   95418: e5950000     	ldr	r0, [r5]
   9541c: e3500009     	cmp	r0, #9
   95420: ca000009     	bgt	0x9544c <.text+0x8534c> @ imm = #0x24
   95424: e1a00004     	mov	r0, r4
   95428: ebfed659     	bl	0x4ad94 <.text+0x3ac94> @ imm = #-0x4a69c
   9542c: e5971000     	ldr	r1, [r7]
   95430: e2412001     	sub	r2, r1, #1
   95434: e0010291     	mul	r1, r1, r2
   95438: e3110001     	tst	r1, #1
   9543c: 0a000005     	beq	0x95458 <.text+0x85358> @ imm = #0x14
   95440: e5951000     	ldr	r1, [r5]
   95444: e3510009     	cmp	r1, #9
   95448: da000002     	ble	0x95458 <.text+0x85358> @ imm = #0x8
   9544c: e1a00004     	mov	r0, r4
   95450: ebfed64f     	bl	0x4ad94 <.text+0x3ac94> @ imm = #-0x4a6c4
   95454: eafffff2     	b	0x95424 <.text+0x85324> @ imm = #-0x38
   95458: e3500000     	cmp	r0, #0
   9545c: 0a000005     	beq	0x95478 <.text+0x85378> @ imm = #0x14
   95460: e3a00ffa     	mov	r0, #1000
   95464: eb01e6b4     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x79ad0
   95468: e2966001     	adds	r6, r6, #1
   9546c: 3affffdd     	blo	0x953e8 <.text+0x852e8> @ imm = #-0x8c
   95470: e3e00000     	mvn	r0, #0
   95474: ea0000a6     	b	0x95714 <.text+0x85614> @ imm = #0x298
   95478: e5970000     	ldr	r0, [r7]
   9547c: e2401001     	sub	r1, r0, #1
   95480: e0000190     	mul	r0, r0, r1
   95484: e3100001     	tst	r0, #1
   95488: 0a000002     	beq	0x95498 <.text+0x85398> @ imm = #0x8
   9548c: e5950000     	ldr	r0, [r5]
   95490: e3500009     	cmp	r0, #9
   95494: cafffff7     	bgt	0x95478 <.text+0x85378> @ imm = #-0x24
   95498: e59d0010     	ldr	r0, [sp, #0x10]
   9549c: e3500000     	cmp	r0, #0
   954a0: 0a000003     	beq	0x954b4 <.text+0x853b4> @ imm = #0xc
   954a4: e59f02a0     	ldr	r0, [pc, #0x2a0]        @ 0x9574c <.text+0x8564c>
   954a8: e5941038     	ldr	r1, [r4, #0x38]
   954ac: e08f0000     	add	r0, pc, r0
   954b0: ebfeed3f     	bl	0x509b4 <.text+0x408b4> @ imm = #-0x44b04
   954b4: e5940018     	ldr	r0, [r4, #0x18]
   954b8: e594a038     	ldr	r10, [r4, #0x38]
   954bc: eb004749     	bl	0xa71e8 <.text+0x970e8> @ imm = #0x11d24
   954c0: e59f9288     	ldr	r9, [pc, #0x288]        @ 0x95750 <.text+0x85650>
   954c4: e35a0000     	cmp	r10, #0
   954c8: e08f9009     	add	r9, pc, r9
   954cc: 0a00004b     	beq	0x95600 <.text+0x85500> @ imm = #0x12c
   954d0: e59f127c     	ldr	r1, [pc, #0x27c]        @ 0x95754 <.text+0x85654>
   954d4: e1a06000     	mov	r6, r0
   954d8: e1a0000a     	mov	r0, r10
   954dc: e08f1001     	add	r1, pc, r1
   954e0: eb14389d     	bl	0x5a375c <.text+0x59365c> @ imm = #0x50e274
   954e4: e3500000     	cmp	r0, #0
   954e8: 0a000044     	beq	0x95600 <.text+0x85500> @ imm = #0x110
   954ec: e5968014     	ldr	r8, [r6, #0x14]
   954f0: e3580001     	cmp	r8, #1
   954f4: ba000041     	blt	0x95600 <.text+0x85500> @ imm = #0x104
   954f8: e5960010     	ldr	r0, [r6, #0x10]
   954fc: e3a09000     	mov	r9, #0
   95500: e2806004     	add	r6, r0, #4
   95504: ea000002     	b	0x95514 <.text+0x85414> @ imm = #0x8
   95508: e2588001     	subs	r8, r8, #1
   9550c: e2866018     	add	r6, r6, #24
   95510: 0a000026     	beq	0x955b0 <.text+0x854b0> @ imm = #0x98
   95514: e5970000     	ldr	r0, [r7]
   95518: e2401001     	sub	r1, r0, #1
   9551c: e0000190     	mul	r0, r0, r1
   95520: e3100001     	tst	r0, #1
   95524: 0a000002     	beq	0x95534 <.text+0x85434> @ imm = #0x8
   95528: e5950000     	ldr	r0, [r5]
   9552c: e3500009     	cmp	r0, #9
   95530: ca00000a     	bgt	0x95560 <.text+0x85460> @ imm = #0x28
   95534: e5160004     	ldr	r0, [r6, #-0x4]
   95538: e1a0100a     	mov	r1, r10
   9553c: eb143886     	bl	0x5a375c <.text+0x59365c> @ imm = #0x50e218
   95540: e5971000     	ldr	r1, [r7]
   95544: e2412001     	sub	r2, r1, #1
   95548: e0010291     	mul	r1, r1, r2
   9554c: e3110001     	tst	r1, #1
   95550: 0a000006     	beq	0x95570 <.text+0x85470> @ imm = #0x18
   95554: e5951000     	ldr	r1, [r5]
   95558: e3510009     	cmp	r1, #9
   9555c: da000003     	ble	0x95570 <.text+0x85470> @ imm = #0xc
   95560: e5160004     	ldr	r0, [r6, #-0x4]
   95564: e1a0100a     	mov	r1, r10
   95568: eb14387b     	bl	0x5a375c <.text+0x59365c> @ imm = #0x50e1ec
   9556c: eafffff0     	b	0x95534 <.text+0x85434> @ imm = #-0x40
   95570: e3500000     	cmp	r0, #0
   95574: 0a000010     	beq	0x955bc <.text+0x854bc> @ imm = #0x40
   95578: e5970000     	ldr	r0, [r7]
   9557c: e2899001     	add	r9, r9, #1
   95580: e2401001     	sub	r1, r0, #1
   95584: e0000190     	mul	r0, r0, r1
   95588: e3100001     	tst	r0, #1
   9558c: e5970000     	ldr	r0, [r7]
   95590: e2401001     	sub	r1, r0, #1
   95594: e0000190     	mul	r0, r0, r1
   95598: e3100001     	tst	r0, #1
   9559c: 0affffd9     	beq	0x95508 <.text+0x85408> @ imm = #-0x9c
   955a0: e5950000     	ldr	r0, [r5]
   955a4: e3500009     	cmp	r0, #9
   955a8: cafffff7     	bgt	0x9558c <.text+0x8548c> @ imm = #-0x24
   955ac: eaffffd5     	b	0x95508 <.text+0x85408> @ imm = #-0xac
   955b0: e59f91a0     	ldr	r9, [pc, #0x1a0]        @ 0x95758 <.text+0x85658>
   955b4: e08f9009     	add	r9, pc, r9
   955b8: ea000010     	b	0x95600 <.text+0x85500> @ imm = #0x40
   955bc: e59f9198     	ldr	r9, [pc, #0x198]        @ 0x9575c <.text+0x8565c>
   955c0: e3560004     	cmp	r6, #4
   955c4: e08f9009     	add	r9, pc, r9
   955c8: 0a00000c     	beq	0x95600 <.text+0x85500> @ imm = #0x30
   955cc: e5970000     	ldr	r0, [r7]
   955d0: e2401001     	sub	r1, r0, #1
   955d4: e0000190     	mul	r0, r0, r1
   955d8: e3100001     	tst	r0, #1
   955dc: e5970000     	ldr	r0, [r7]
   955e0: e5969000     	ldr	r9, [r6]
   955e4: e2401001     	sub	r1, r0, #1
   955e8: e0000190     	mul	r0, r0, r1
   955ec: e3100001     	tst	r0, #1
   955f0: 0a000002     	beq	0x95600 <.text+0x85500> @ imm = #0x8
   955f4: e5950000     	ldr	r0, [r5]
   955f8: e3500009     	cmp	r0, #9
   955fc: cafffff6     	bgt	0x955dc <.text+0x854dc> @ imm = #-0x28
   95600: e59f0158     	ldr	r0, [pc, #0x158]        @ 0x95760 <.text+0x85660>
   95604: e3a06003     	mov	r6, #3
   95608: e59f1154     	ldr	r1, [pc, #0x154]        @ 0x95764 <.text+0x85664>
   9560c: e59f2154     	ldr	r2, [pc, #0x154]        @ 0x95768 <.text+0x85668>
   95610: e08f0000     	add	r0, pc, r0
   95614: e59f3150     	ldr	r3, [pc, #0x150]        @ 0x9576c <.text+0x8566c>
   95618: e08f1001     	add	r1, pc, r1
   9561c: e08f2002     	add	r2, pc, r2
   95620: e58d6000     	str	r6, [sp]
   95624: e08f3003     	add	r3, pc, r3
   95628: e98d0208     	stmib	sp, {r3, r9}
   9562c: e30131b3     	movw	r3, #0x11b3
   95630: eb0192a3     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x64a8c
   95634: e5d410b0     	ldrb	r1, [r4, #0xb0]
   95638: e3a00000     	mov	r0, #0
   9563c: e3510000     	cmp	r1, #0
   95640: 0a000033     	beq	0x95714 <.text+0x85614> @ imm = #0xcc
   95644: e5971000     	ldr	r1, [r7]
   95648: e2412001     	sub	r2, r1, #1
   9564c: e0010291     	mul	r1, r1, r2
   95650: e3110001     	tst	r1, #1
   95654: e5971000     	ldr	r1, [r7]
   95658: e2412001     	sub	r2, r1, #1
   9565c: e0020291     	mul	r2, r1, r2
   95660: e5d410c8     	ldrb	r1, [r4, #0xc8]
   95664: e3120001     	tst	r2, #1
   95668: 0a000002     	beq	0x95678 <.text+0x85578> @ imm = #0x8
   9566c: e5952000     	ldr	r2, [r5]
   95670: e3520009     	cmp	r2, #9
   95674: cafffff6     	bgt	0x95654 <.text+0x85554> @ imm = #-0x28
   95678: e3510000     	cmp	r1, #0
   9567c: 0a000024     	beq	0x95714 <.text+0x85614> @ imm = #0x90
   95680: e59400b4     	ldr	r0, [r4, #0xb4]
   95684: e3500000     	cmp	r0, #0
   95688: 0a000002     	beq	0x95698 <.text+0x85598> @ imm = #0x8
   9568c: eb13f97e     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4fe5f8
   95690: e3a00000     	mov	r0, #0
   95694: e58400b4     	str	r0, [r4, #0xb4]
   95698: e5970000     	ldr	r0, [r7]
   9569c: e2401001     	sub	r1, r0, #1
   956a0: e0000190     	mul	r0, r0, r1
   956a4: e3100001     	tst	r0, #1
   956a8: 0a000002     	beq	0x956b8 <.text+0x855b8> @ imm = #0x8
   956ac: e5950000     	ldr	r0, [r5]
   956b0: e3500009     	cmp	r0, #9
   956b4: ca00000f     	bgt	0x956f8 <.text+0x855f8> @ imm = #0x3c
   956b8: e5940038     	ldr	r0, [r4, #0x38]
   956bc: eb143877     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x50e1dc
   956c0: e5941038     	ldr	r1, [r4, #0x38]
   956c4: e58400b4     	str	r0, [r4, #0xb4]
   956c8: e1a00001     	mov	r0, r1
   956cc: ebfee202     	bl	0x4dedc <.text+0x3dddc> @ imm = #-0x477f8
   956d0: e5971000     	ldr	r1, [r7]
   956d4: e3500000     	cmp	r0, #0
   956d8: 13e00000     	mvnne	r0, #0
   956dc: e2412001     	sub	r2, r1, #1
   956e0: e0010291     	mul	r1, r1, r2
   956e4: e3110001     	tst	r1, #1
   956e8: 0a000009     	beq	0x95714 <.text+0x85614> @ imm = #0x24
   956ec: e5951000     	ldr	r1, [r5]
   956f0: e3510009     	cmp	r1, #9
   956f4: da000006     	ble	0x95714 <.text+0x85614> @ imm = #0x18
   956f8: e5940038     	ldr	r0, [r4, #0x38]
   956fc: eb143867     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x50e19c
   95700: e5941038     	ldr	r1, [r4, #0x38]
   95704: e58400b4     	str	r0, [r4, #0xb4]
   95708: e1a00001     	mov	r0, r1
   9570c: ebfee1f2     	bl	0x4dedc <.text+0x3dddc> @ imm = #-0x47838
   95710: eaffffe8     	b	0x956b8 <.text+0x855b8> @ imm = #-0x60
   95714: e5971000     	ldr	r1, [r7]
   95718: e2412001     	sub	r2, r1, #1
   9571c: e0010291     	mul	r1, r1, r2
   95720: e3110001     	tst	r1, #1
   95724: 0a000002     	beq	0x95734 <.text+0x85634> @ imm = #0x8
   95728: e5951000     	ldr	r1, [r5]
   9572c: e3510009     	cmp	r1, #9
   95730: cafffff7     	bgt	0x95714 <.text+0x85614> @ imm = #-0x24
   95734: e24bd01c     	sub	sp, r11, #28
   95738: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   9573c: 00549e78     	subseq	r9, r4, r8, ror lr
   95740: 0054aaa0     	subseq	r10, r4, r0, lsr #21
   95744: 0057d63c     	subseq	sp, r7, r12, lsr r6
   95748: 0057d650     	subseq	sp, r7, r0, asr r6
   9574c: 00552034     	subseq	r2, r5, r4, lsr r0
   95750: 0055203f     	subseq	r2, r5, pc, lsr r0
   95754: 005519fa     	ldrsheq	r1, [r5], #-154
   95758: 00551f53     	subseq	r1, r5, r3, asr pc
   9575c: 00551f43     	subseq	r1, r5, r3, asr #30
   95760: 005518cf     	subseq	r1, r5, pc, asr #17
   95764: 00551839     	subseq	r1, r5, r9, lsr r8
   95768: 0055185f     	subseq	r1, r5, pc, asr r8
   9576c: 00551ecd     	subseq	r1, r5, sp, asr #29
   95770: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   95774: e28db01c     	add	r11, sp, #28
   95778: e24dd03c     	sub	sp, sp, #60
   9577c: e1a07000     	mov	r7, r0
   95780: e5900018     	ldr	r0, [r0, #0x18]
   95784: eb0046a0     	bl	0xa720c <.text+0x9710c> @ imm = #0x11a80
   95788: e28d1028     	add	r1, sp, #40
   9578c: e3a05000     	mov	r5, #0
   95790: e58d0024     	str	r0, [sp, #0x24]
   95794: e1a00007     	mov	r0, r7
   95798: e58d5038     	str	r5, [sp, #0x38]
   9579c: e58d5034     	str	r5, [sp, #0x34]
   957a0: e58d5030     	str	r5, [sp, #0x30]
   957a4: e58d502c     	str	r5, [sp, #0x2c]
   957a8: e58d5028     	str	r5, [sp, #0x28]
   957ac: ebffb2a2     	bl	0x8223c <.text+0x7213c> @ imm = #-0x13578
   957b0: e59f4338     	ldr	r4, [pc, #0x338]        @ 0x95af0 <.text+0x859f0>
   957b4: e08f4004     	add	r4, pc, r4
   957b8: e1c480d8     	ldrd	r8, r9, [r4, #8]
   957bc: e58d802c     	str	r8, [sp, #0x2c]
   957c0: e58780dc     	str	r8, [r7, #0xdc]
   957c4: e58d9030     	str	r9, [sp, #0x30]
   957c8: e58790cc     	str	r9, [r7, #0xcc]
   957cc: e58d5028     	str	r5, [sp, #0x28]
   957d0: e59d0038     	ldr	r0, [sp, #0x38]
   957d4: e58d001c     	str	r0, [sp, #0x1c]
   957d8: e3500001     	cmp	r0, #1
   957dc: ba000059     	blt	0x95948 <.text+0x85848> @ imm = #0x164
   957e0: e58d7018     	str	r7, [sp, #0x18]
   957e4: e287c050     	add	r12, r7, #80
   957e8: e59f2304     	ldr	r2, [pc, #0x304]        @ 0x95af4 <.text+0x859f4>
   957ec: e79f2002     	ldr	r2, [pc, r2]
   957f0: e5920000     	ldr	r0, [r2]
   957f4: e2401001     	sub	r1, r0, #1
   957f8: e0000190     	mul	r0, r0, r1
   957fc: e3100001     	tst	r0, #1
   95800: e5920000     	ldr	r0, [r2]
   95804: e2401001     	sub	r1, r0, #1
   95808: e0000190     	mul	r0, r0, r1
   9580c: e59f12e4     	ldr	r1, [pc, #0x2e4]        @ 0x95af8 <.text+0x859f8>
   95810: e79f1001     	ldr	r1, [pc, r1]
   95814: e59d3034     	ldr	r3, [sp, #0x34]
   95818: e3100001     	tst	r0, #1
   9581c: 0a000002     	beq	0x9582c <.text+0x8572c> @ imm = #0x8
   95820: e5910000     	ldr	r0, [r1]
   95824: e3500009     	cmp	r0, #9
   95828: cafffff4     	bgt	0x95800 <.text+0x85700> @ imm = #-0x30
   9582c: e59d6024     	ldr	r6, [sp, #0x24]
   95830: e3a01000     	mov	r1, #0
   95834: e58d3014     	str	r3, [sp, #0x14]
   95838: ea000004     	b	0x95850 <.text+0x85750> @ imm = #0x10
   9583c: e59d1020     	ldr	r1, [sp, #0x20]
   95840: e59d001c     	ldr	r0, [sp, #0x1c]
   95844: e2811001     	add	r1, r1, #1
   95848: e1510000     	cmp	r1, r0
   9584c: aa00003b     	bge	0x95940 <.text+0x85840> @ imm = #0xec
   95850: e58d1020     	str	r1, [sp, #0x20]
   95854: e0811101     	add	r1, r1, r1, lsl #2
   95858: e5940020     	ldr	r0, [r4, #0x20]
   9585c: e0800181     	add	r0, r0, r1, lsl #3
   95860: e5d01004     	ldrb	r1, [r0, #0x4]
   95864: e3510000     	cmp	r1, #0
   95868: 15d01005     	ldrbne	r1, [r0, #0x5]
   9586c: 13510000     	cmpne	r1, #0
   95870: 0afffff1     	beq	0x9583c <.text+0x8573c> @ imm = #-0x3c
   95874: e59d1018     	ldr	r1, [sp, #0x18]
   95878: e5911100     	ldr	r1, [r1, #0x100]
   9587c: e59f7278     	ldr	r7, [pc, #0x278]        @ 0x95afc <.text+0x859fc>
   95880: e79f7007     	ldr	r7, [pc, r7]
   95884: e5972000     	ldr	r2, [r7]
   95888: e59f5270     	ldr	r5, [pc, #0x270]        @ 0x95b00 <.text+0x85a00>
   9588c: e2423001     	sub	r3, r2, #1
   95890: e0020392     	mul	r2, r2, r3
   95894: e79f5005     	ldr	r5, [pc, r5]
   95898: e3120001     	tst	r2, #1
   9589c: e5972000     	ldr	r2, [r7]
   958a0: e2423001     	sub	r3, r2, #1
   958a4: e0030392     	mul	r3, r2, r3
   958a8: e5962010     	ldr	r2, [r6, #0x10]
   958ac: e3130001     	tst	r3, #1
   958b0: 0a000002     	beq	0x958c0 <.text+0x857c0> @ imm = #0x8
   958b4: e5953000     	ldr	r3, [r5]
   958b8: e3530009     	cmp	r3, #9
   958bc: cafffff6     	bgt	0x9589c <.text+0x8579c> @ imm = #-0x28
   958c0: e3520001     	cmp	r2, #1
   958c4: baffffdc     	blt	0x9583c <.text+0x8573c> @ imm = #-0x90
   958c8: e59d2020     	ldr	r2, [sp, #0x20]
   958cc: e2808020     	add	r8, r0, #32
   958d0: e3a07000     	mov	r7, #0
   958d4: e3a05000     	mov	r5, #0
   958d8: e0822082     	add	r2, r2, r2, lsl #1
   958dc: e0811102     	add	r1, r1, r2, lsl #2
   958e0: e281a008     	add	r10, r1, #8
   958e4: e59d1014     	ldr	r1, [sp, #0x14]
   958e8: e0811102     	add	r1, r1, r2, lsl #2
   958ec: e2819008     	add	r9, r1, #8
   958f0: e5980000     	ldr	r0, [r8]
   958f4: e1a0600c     	mov	r6, r12
   958f8: e594100c     	ldr	r1, [r4, #0xc]
   958fc: e7900007     	ldr	r0, [r0, r7]
   95900: e3500000     	cmp	r0, #0
   95904: 11a01000     	movne	r1, r0
   95908: e1a0000c     	mov	r0, r12
   9590c: ebfeeaf0     	bl	0x504d4 <.text+0x403d4> @ imm = #-0x45440
   95910: e5991000     	ldr	r1, [r9]
   95914: e1a0c006     	mov	r12, r6
   95918: e59d6024     	ldr	r6, [sp, #0x24]
   9591c: e2877038     	add	r7, r7, #56
   95920: e7810105     	str	r0, [r1, r5, lsl #2]
   95924: e59a1000     	ldr	r1, [r10]
   95928: e7810105     	str	r0, [r1, r5, lsl #2]
   9592c: e2855001     	add	r5, r5, #1
   95930: e5960010     	ldr	r0, [r6, #0x10]
   95934: e1550000     	cmp	r5, r0
   95938: baffffec     	blt	0x958f0 <.text+0x857f0> @ imm = #-0x50
   9593c: eaffffbe     	b	0x9583c <.text+0x8573c> @ imm = #-0x108
   95940: e1c480d8     	ldrd	r8, r9, [r4, #8]
   95944: e59d7018     	ldr	r7, [sp, #0x18]
   95948: e59f61b4     	ldr	r6, [pc, #0x1b4]        @ 0x95b04 <.text+0x85a04>
   9594c: e79f6006     	ldr	r6, [pc, r6]
   95950: e5960000     	ldr	r0, [r6]
   95954: e59fa1ac     	ldr	r10, [pc, #0x1ac]       @ 0x95b08 <.text+0x85a08>
   95958: e2401001     	sub	r1, r0, #1
   9595c: e0000190     	mul	r0, r0, r1
   95960: e79fa00a     	ldr	r10, [pc, r10]
   95964: e59f41a0     	ldr	r4, [pc, #0x1a0]        @ 0x95b0c <.text+0x85a0c>
   95968: e08f4004     	add	r4, pc, r4
   9596c: e3100001     	tst	r0, #1
   95970: 0a000002     	beq	0x95980 <.text+0x85880> @ imm = #0x8
   95974: e59a0000     	ldr	r0, [r10]
   95978: e3500009     	cmp	r0, #9
   9597c: ca000015     	bgt	0x959d8 <.text+0x858d8> @ imm = #0x54
   95980: e59f0188     	ldr	r0, [pc, #0x188]        @ 0x95b10 <.text+0x85a10>
   95984: e3a03003     	mov	r3, #3
   95988: e59f1184     	ldr	r1, [pc, #0x184]        @ 0x95b14 <.text+0x85a14>
   9598c: e59f2184     	ldr	r2, [pc, #0x184]        @ 0x95b18 <.text+0x85a18>
   95990: e08f0000     	add	r0, pc, r0
   95994: e08f1001     	add	r1, pc, r1
   95998: e88d0318     	stm	sp, {r3, r4, r8, r9}
   9599c: e08f2002     	add	r2, pc, r2
   959a0: e3003654     	movw	r3, #0x654
   959a4: eb0191c6     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x64718
   959a8: e28d1028     	add	r1, sp, #40
   959ac: e1a00007     	mov	r0, r7
   959b0: ebffb9c7     	bl	0x840d4 <.text+0x73fd4> @ imm = #-0x118e4
   959b4: e5960000     	ldr	r0, [r6]
   959b8: e59d5034     	ldr	r5, [sp, #0x34]
   959bc: e2401001     	sub	r1, r0, #1
   959c0: e0000190     	mul	r0, r0, r1
   959c4: e3100001     	tst	r0, #1
   959c8: 0a000010     	beq	0x95a10 <.text+0x85910> @ imm = #0x40
   959cc: e59a0000     	ldr	r0, [r10]
   959d0: e3500009     	cmp	r0, #9
   959d4: da00000d     	ble	0x95a10 <.text+0x85910> @ imm = #0x34
   959d8: e59f013c     	ldr	r0, [pc, #0x13c]        @ 0x95b1c <.text+0x85a1c>
   959dc: e3a03003     	mov	r3, #3
   959e0: e59f1138     	ldr	r1, [pc, #0x138]        @ 0x95b20 <.text+0x85a20>
   959e4: e59f2138     	ldr	r2, [pc, #0x138]        @ 0x95b24 <.text+0x85a24>
   959e8: e08f0000     	add	r0, pc, r0
   959ec: e08f1001     	add	r1, pc, r1
   959f0: e88d0318     	stm	sp, {r3, r4, r8, r9}
   959f4: e08f2002     	add	r2, pc, r2
   959f8: e3003654     	movw	r3, #0x654
   959fc: eb0191b0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x646c0
   95a00: e28d1028     	add	r1, sp, #40
   95a04: e1a00007     	mov	r0, r7
   95a08: ebffb9b1     	bl	0x840d4 <.text+0x73fd4> @ imm = #-0x1193c
   95a0c: eaffffdb     	b	0x95980 <.text+0x85880> @ imm = #-0x94
   95a10: e3550000     	cmp	r5, #0
   95a14: 0a000033     	beq	0x95ae8 <.text+0x859e8> @ imm = #0xcc
   95a18: e59d4038     	ldr	r4, [sp, #0x38]
   95a1c: e3540001     	cmp	r4, #1
   95a20: ba000017     	blt	0x95a84 <.text+0x85984> @ imm = #0x5c
   95a24: e2857008     	add	r7, r5, #8
   95a28: e3a08000     	mov	r8, #0
   95a2c: ea000002     	b	0x95a3c <.text+0x8593c> @ imm = #0x8
   95a30: e2544001     	subs	r4, r4, #1
   95a34: e287700c     	add	r7, r7, #12
   95a38: 0a000011     	beq	0x95a84 <.text+0x85984> @ imm = #0x44
   95a3c: e5960000     	ldr	r0, [r6]
   95a40: e2401001     	sub	r1, r0, #1
   95a44: e0000190     	mul	r0, r0, r1
   95a48: e3100001     	tst	r0, #1
   95a4c: e5960000     	ldr	r0, [r6]
   95a50: e2401001     	sub	r1, r0, #1
   95a54: e0010190     	mul	r1, r0, r1
   95a58: e5970000     	ldr	r0, [r7]
   95a5c: e3110001     	tst	r1, #1
   95a60: 0a000002     	beq	0x95a70 <.text+0x85970> @ imm = #0x8
   95a64: e59a1000     	ldr	r1, [r10]
   95a68: e3510009     	cmp	r1, #9
   95a6c: cafffff6     	bgt	0x95a4c <.text+0x8594c> @ imm = #-0x28
   95a70: e3500000     	cmp	r0, #0
   95a74: 0affffed     	beq	0x95a30 <.text+0x85930> @ imm = #-0x4c
   95a78: eb13f883     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4fe20c
   95a7c: e5878000     	str	r8, [r7]
   95a80: eaffffea     	b	0x95a30 <.text+0x85930> @ imm = #-0x58
   95a84: e5960000     	ldr	r0, [r6]
   95a88: e2401001     	sub	r1, r0, #1
   95a8c: e0000190     	mul	r0, r0, r1
   95a90: e3100001     	tst	r0, #1
   95a94: 0a000002     	beq	0x95aa4 <.text+0x859a4> @ imm = #0x8
   95a98: e59a0000     	ldr	r0, [r10]
   95a9c: e3500009     	cmp	r0, #9
   95aa0: ca00000b     	bgt	0x95ad4 <.text+0x859d4> @ imm = #0x2c
   95aa4: e1a00005     	mov	r0, r5
   95aa8: eb13f877     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4fe1dc
   95aac: e5960000     	ldr	r0, [r6]
   95ab0: e3a02000     	mov	r2, #0
   95ab4: e58d2034     	str	r2, [sp, #0x34]
   95ab8: e2401001     	sub	r1, r0, #1
   95abc: e0010190     	mul	r1, r0, r1
   95ac0: e59a0000     	ldr	r0, [r10]
   95ac4: e3110001     	tst	r1, #1
   95ac8: 0a000006     	beq	0x95ae8 <.text+0x859e8> @ imm = #0x18
   95acc: e3500009     	cmp	r0, #9
   95ad0: da000004     	ble	0x95ae8 <.text+0x859e8> @ imm = #0x10
   95ad4: e1a00005     	mov	r0, r5
   95ad8: eb13f86b     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4fe1ac
   95adc: e3a00000     	mov	r0, #0
   95ae0: e58d0034     	str	r0, [sp, #0x34]
   95ae4: eaffffee     	b	0x95aa4 <.text+0x859a4> @ imm = #-0x48
   95ae8: e24bd01c     	sub	sp, r11, #28
   95aec: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   95af0: 0057b214     	subseq	r11, r7, r4, lsl r2
   95af4: 0054a700     	subseq	r10, r4, r0, lsl #14
   95af8: 005499a0     	subseq	r9, r4, r0, lsr #19
   95afc: 0054a66c     	subseq	r10, r4, r12, ror #12
   95b00: 0054991c     	subseq	r9, r4, r12, lsl r9
   95b04: 0054a5a0     	subseq	r10, r4, r0, lsr #11
   95b08: 00549850     	subseq	r9, r4, r0, asr r8
   95b0c: 00551c01     	subseq	r1, r5, r1, lsl #24
   95b10: 0055154f     	subseq	r1, r5, pc, asr #10
   95b14: 005514bd     	ldrheq	r1, [r5], #-77
   95b18: 005514df     	ldrsbeq	r1, [r5], #-79
   95b1c: 005514f7     	ldrsheq	r1, [r5], #-71
   95b20: 00551465     	subseq	r1, r5, r5, ror #8
   95b24: 00551487     	subseq	r1, r5, r7, lsl #9

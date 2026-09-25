
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  1079f0: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
  1079f4: e28db010     	add	r11, sp, #16
  1079f8: e24dd010     	sub	sp, sp, #16
  1079fc: e1a05000     	mov	r5, r0
  107a00: e59f0420     	ldr	r0, [pc, #0x420]        @ 0x107e28 <.text+0xf7d28>
  107a04: e08f0000     	add	r0, pc, r0
  107a08: e5d00000     	ldrb	r0, [r0]
  107a0c: e3500000     	cmp	r0, #0
  107a10: 0a000015     	beq	0x107a6c <.text+0xf796c> @ imm = #0x54
  107a14: e3550000     	cmp	r5, #0
  107a18: 4a000022     	bmi	0x107aa8 <.text+0xf79a8> @ imm = #0x88
  107a1c: e59f042c     	ldr	r0, [pc, #0x42c]        @ 0x107e50 <.text+0xf7d50>
  107a20: e79f0000     	ldr	r0, [pc, r0]
  107a24: e1500005     	cmp	r0, r5
  107a28: da00001e     	ble	0x107aa8 <.text+0xf79a8> @ imm = #0x78
  107a2c: e1a04002     	mov	r4, r2
  107a30: e3520c01     	cmp	r2, #256
  107a34: 3a00002b     	blo	0x107ae8 <.text+0xf79e8> @ imm = #0xac
  107a38: e59f0424     	ldr	r0, [pc, #0x424]        @ 0x107e64 <.text+0xf7d64>
  107a3c: e3a07001     	mov	r7, #1
  107a40: e59f1420     	ldr	r1, [pc, #0x420]        @ 0x107e68 <.text+0xf7d68>
  107a44: e59f2420     	ldr	r2, [pc, #0x420]        @ 0x107e6c <.text+0xf7d6c>
  107a48: e08f0000     	add	r0, pc, r0
  107a4c: e59f341c     	ldr	r3, [pc, #0x41c]        @ 0x107e70 <.text+0xf7d70>
  107a50: e08f1001     	add	r1, pc, r1
  107a54: e08f2002     	add	r2, pc, r2
  107a58: e58d7000     	str	r7, [sp]
  107a5c: e08f3003     	add	r3, pc, r3
  107a60: e98d0018     	stmib	sp, {r3, r4}
  107a64: e300334a     	movw	r3, #0x34a
  107a68: ea00001a     	b	0x107ad8 <.text+0xf79d8> @ imm = #0x68
  107a6c: e59f43b8     	ldr	r4, [pc, #0x3b8]        @ 0x107e2c <.text+0xf7d2c>
  107a70: e79f4004     	ldr	r4, [pc, r4]
  107a74: e5940000     	ldr	r0, [r4]
  107a78: e59f53b0     	ldr	r5, [pc, #0x3b0]        @ 0x107e30 <.text+0xf7d30>
  107a7c: e2401001     	sub	r1, r0, #1
  107a80: e0000190     	mul	r0, r0, r1
  107a84: e79f5005     	ldr	r5, [pc, r5]
  107a88: e59f63a4     	ldr	r6, [pc, #0x3a4]        @ 0x107e34 <.text+0xf7d34>
  107a8c: e08f6006     	add	r6, pc, r6
  107a90: e3100001     	tst	r0, #1
  107a94: 0a000073     	beq	0x107c68 <.text+0xf7b68> @ imm = #0x1cc
  107a98: e5950000     	ldr	r0, [r5]
  107a9c: e3500009     	cmp	r0, #9
  107aa0: ca000083     	bgt	0x107cb4 <.text+0xf7bb4> @ imm = #0x20c
  107aa4: ea00006f     	b	0x107c68 <.text+0xf7b68> @ imm = #0x1bc
  107aa8: e59f03a4     	ldr	r0, [pc, #0x3a4]        @ 0x107e54 <.text+0xf7d54>
  107aac: e3a07001     	mov	r7, #1
  107ab0: e59f13a0     	ldr	r1, [pc, #0x3a0]        @ 0x107e58 <.text+0xf7d58>
  107ab4: e59f23a0     	ldr	r2, [pc, #0x3a0]        @ 0x107e5c <.text+0xf7d5c>
  107ab8: e08f0000     	add	r0, pc, r0
  107abc: e59f339c     	ldr	r3, [pc, #0x39c]        @ 0x107e60 <.text+0xf7d60>
  107ac0: e08f1001     	add	r1, pc, r1
  107ac4: e08f2002     	add	r2, pc, r2
  107ac8: e58d7000     	str	r7, [sp]
  107acc: e08f3003     	add	r3, pc, r3
  107ad0: e98d0028     	stmib	sp, {r3, r5}
  107ad4: e3003345     	movw	r3, #0x345
  107ad8: ebffc979     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xda1c
  107adc: e3e00000     	mvn	r0, #0
  107ae0: e24bd010     	sub	sp, r11, #16
  107ae4: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  107ae8: e3530000     	cmp	r3, #0
  107aec: 0a000047     	beq	0x107c10 <.text+0xf7b10> @ imm = #0x11c
  107af0: e3510000     	cmp	r1, #0
  107af4: 4a000036     	bmi	0x107bd4 <.text+0xf7ad4> @ imm = #0xd8
  107af8: e59f0384     	ldr	r0, [pc, #0x384]        @ 0x107e84 <.text+0xf7d84>
  107afc: e0852305     	add	r2, r5, r5, lsl #6
  107b00: e79f0000     	ldr	r0, [pc, r0]
  107b04: e0800182     	add	r0, r0, r2, lsl #3
  107b08: e5902204     	ldr	r2, [r0, #0x204]
  107b0c: e1520001     	cmp	r2, r1
  107b10: da00002f     	ble	0x107bd4 <.text+0xf7ad4> @ imm = #0xbc
  107b14: e59f5390     	ldr	r5, [pc, #0x390]        @ 0x107eac <.text+0xf7dac>
  107b18: e79f5005     	ldr	r5, [pc, r5]
  107b1c: e5952000     	ldr	r2, [r5]
  107b20: e2427001     	sub	r7, r2, #1
  107b24: e0020792     	mul	r2, r2, r7
  107b28: e3120001     	tst	r2, #1
  107b2c: e5952000     	ldr	r2, [r5]
  107b30: e59f6378     	ldr	r6, [pc, #0x378]        @ 0x107eb0 <.text+0xf7db0>
  107b34: e2427001     	sub	r7, r2, #1
  107b38: e0070792     	mul	r7, r2, r7
  107b3c: e79f6006     	ldr	r6, [pc, r6]
  107b40: e5902200     	ldr	r2, [r0, #0x200]
  107b44: e3170001     	tst	r7, #1
  107b48: 0a000002     	beq	0x107b58 <.text+0xf7a58> @ imm = #0x8
  107b4c: e5967000     	ldr	r7, [r6]
  107b50: e3570009     	cmp	r7, #9
  107b54: cafffff4     	bgt	0x107b2c <.text+0xf7a2c> @ imm = #-0x30
  107b58: e0821481     	add	r1, r2, r1, lsl #9
  107b5c: e3a02000     	mov	r2, #0
  107b60: e5950000     	ldr	r0, [r5]
  107b64: e2407001     	sub	r7, r0, #1
  107b68: e0000790     	mul	r0, r0, r7
  107b6c: e3100001     	tst	r0, #1
  107b70: e5950000     	ldr	r0, [r5]
  107b74: e2407001     	sub	r7, r0, #1
  107b78: e0070790     	mul	r7, r0, r7
  107b7c: e7910182     	ldr	r0, [r1, r2, lsl #3]
  107b80: e3170001     	tst	r7, #1
  107b84: 0a000002     	beq	0x107b94 <.text+0xf7a94> @ imm = #0x8
  107b88: e5967000     	ldr	r7, [r6]
  107b8c: e3570009     	cmp	r7, #9
  107b90: cafffff6     	bgt	0x107b70 <.text+0xf7a70> @ imm = #-0x28
  107b94: e1500004     	cmp	r0, r4
  107b98: 0a000029     	beq	0x107c44 <.text+0xf7b44> @ imm = #0xa4
  107b9c: e2822001     	add	r2, r2, #1
  107ba0: e3520040     	cmp	r2, #64
  107ba4: 1affffed     	bne	0x107b60 <.text+0xf7a60> @ imm = #-0x4c
  107ba8: e5950000     	ldr	r0, [r5]
  107bac: e59f7300     	ldr	r7, [pc, #0x300]        @ 0x107eb4 <.text+0xf7db4>
  107bb0: e2401001     	sub	r1, r0, #1
  107bb4: e08f7007     	add	r7, pc, r7
  107bb8: e0000190     	mul	r0, r0, r1
  107bbc: e3100001     	tst	r0, #1
  107bc0: 0a000066     	beq	0x107d60 <.text+0xf7c60> @ imm = #0x198
  107bc4: e5960000     	ldr	r0, [r6]
  107bc8: e3500009     	cmp	r0, #9
  107bcc: ca000077     	bgt	0x107db0 <.text+0xf7cb0> @ imm = #0x1dc
  107bd0: ea000062     	b	0x107d60 <.text+0xf7c60> @ imm = #0x188
  107bd4: e59f42ac     	ldr	r4, [pc, #0x2ac]        @ 0x107e88 <.text+0xf7d88>
  107bd8: e79f4004     	ldr	r4, [pc, r4]
  107bdc: e5940000     	ldr	r0, [r4]
  107be0: e59f62a4     	ldr	r6, [pc, #0x2a4]        @ 0x107e8c <.text+0xf7d8c>
  107be4: e2401001     	sub	r1, r0, #1
  107be8: e0000190     	mul	r0, r0, r1
  107bec: e79f6006     	ldr	r6, [pc, r6]
  107bf0: e59f7298     	ldr	r7, [pc, #0x298]        @ 0x107e90 <.text+0xf7d90>
  107bf4: e08f7007     	add	r7, pc, r7
  107bf8: e3100001     	tst	r0, #1
  107bfc: 0a000037     	beq	0x107ce0 <.text+0xf7be0> @ imm = #0xdc
  107c00: e5960000     	ldr	r0, [r6]
  107c04: e3500009     	cmp	r0, #9
  107c08: ca000048     	bgt	0x107d30 <.text+0xf7c30> @ imm = #0x120
  107c0c: ea000033     	b	0x107ce0 <.text+0xf7be0> @ imm = #0xcc
  107c10: e59f025c     	ldr	r0, [pc, #0x25c]        @ 0x107e74 <.text+0xf7d74>
  107c14: e3a07001     	mov	r7, #1
  107c18: e59f1258     	ldr	r1, [pc, #0x258]        @ 0x107e78 <.text+0xf7d78>
  107c1c: e59f2258     	ldr	r2, [pc, #0x258]        @ 0x107e7c <.text+0xf7d7c>
  107c20: e08f0000     	add	r0, pc, r0
  107c24: e59f3254     	ldr	r3, [pc, #0x254]        @ 0x107e80 <.text+0xf7d80>
  107c28: e08f1001     	add	r1, pc, r1
  107c2c: e08f2002     	add	r2, pc, r2
  107c30: e58d7000     	str	r7, [sp]
  107c34: e08f3003     	add	r3, pc, r3
  107c38: e58d3004     	str	r3, [sp, #0x4]
  107c3c: e300334f     	movw	r3, #0x34f
  107c40: eaffffa4     	b	0x107ad8 <.text+0xf79d8> @ imm = #-0x170
  107c44: e5950000     	ldr	r0, [r5]
  107c48: e2407001     	sub	r7, r0, #1
  107c4c: e0000790     	mul	r0, r0, r7
  107c50: e3100001     	tst	r0, #1
  107c54: 0a000061     	beq	0x107de0 <.text+0xf7ce0> @ imm = #0x184
  107c58: e5960000     	ldr	r0, [r6]
  107c5c: e3500009     	cmp	r0, #9
  107c60: ca00006a     	bgt	0x107e10 <.text+0xf7d10> @ imm = #0x1a8
  107c64: ea00005d     	b	0x107de0 <.text+0xf7ce0> @ imm = #0x174
  107c68: e59f01c8     	ldr	r0, [pc, #0x1c8]        @ 0x107e38 <.text+0xf7d38>
  107c6c: e3a03001     	mov	r3, #1
  107c70: e59f11c4     	ldr	r1, [pc, #0x1c4]        @ 0x107e3c <.text+0xf7d3c>
  107c74: e59f21c4     	ldr	r2, [pc, #0x1c4]        @ 0x107e40 <.text+0xf7d40>
  107c78: e08f0000     	add	r0, pc, r0
  107c7c: e08f1001     	add	r1, pc, r1
  107c80: e88d0048     	stm	sp, {r3, r6}
  107c84: e08f2002     	add	r2, pc, r2
  107c88: e3a03d0d     	mov	r3, #832
  107c8c: ebffc90c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xdbd0
  107c90: e5940000     	ldr	r0, [r4]
  107c94: e2401001     	sub	r1, r0, #1
  107c98: e0010190     	mul	r1, r0, r1
  107c9c: e3e00000     	mvn	r0, #0
  107ca0: e3110001     	tst	r1, #1
  107ca4: 0a00005d     	beq	0x107e20 <.text+0xf7d20> @ imm = #0x174
  107ca8: e5951000     	ldr	r1, [r5]
  107cac: e351000a     	cmp	r1, #10
  107cb0: ba00005a     	blt	0x107e20 <.text+0xf7d20> @ imm = #0x168
  107cb4: e59f0188     	ldr	r0, [pc, #0x188]        @ 0x107e44 <.text+0xf7d44>
  107cb8: e3a03001     	mov	r3, #1
  107cbc: e59f1184     	ldr	r1, [pc, #0x184]        @ 0x107e48 <.text+0xf7d48>
  107cc0: e59f2184     	ldr	r2, [pc, #0x184]        @ 0x107e4c <.text+0xf7d4c>
  107cc4: e08f0000     	add	r0, pc, r0
  107cc8: e08f1001     	add	r1, pc, r1
  107ccc: e88d0048     	stm	sp, {r3, r6}
  107cd0: e08f2002     	add	r2, pc, r2
  107cd4: e3a03d0d     	mov	r3, #832
  107cd8: ebffc8f9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xdc1c
  107cdc: eaffffe1     	b	0x107c68 <.text+0xf7b68> @ imm = #-0x7c
  107ce0: e59f01ac     	ldr	r0, [pc, #0x1ac]        @ 0x107e94 <.text+0xf7d94>
  107ce4: e3a03001     	mov	r3, #1
  107ce8: e59f11a8     	ldr	r1, [pc, #0x1a8]        @ 0x107e98 <.text+0xf7d98>
  107cec: e59f21a8     	ldr	r2, [pc, #0x1a8]        @ 0x107e9c <.text+0xf7d9c>
  107cf0: e08f0000     	add	r0, pc, r0
  107cf4: e08f1001     	add	r1, pc, r1
  107cf8: e88d0088     	stm	sp, {r3, r7}
  107cfc: e08f2002     	add	r2, pc, r2
  107d00: e3003355     	movw	r3, #0x355
  107d04: e58d5008     	str	r5, [sp, #0x8]
  107d08: ebffc8ed     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xdc4c
  107d0c: e5940000     	ldr	r0, [r4]
  107d10: e2401001     	sub	r1, r0, #1
  107d14: e0010190     	mul	r1, r0, r1
  107d18: e3e00000     	mvn	r0, #0
  107d1c: e3110001     	tst	r1, #1
  107d20: 0a00003e     	beq	0x107e20 <.text+0xf7d20> @ imm = #0xf8
  107d24: e5961000     	ldr	r1, [r6]
  107d28: e351000a     	cmp	r1, #10
  107d2c: ba00003b     	blt	0x107e20 <.text+0xf7d20> @ imm = #0xec
  107d30: e59f0168     	ldr	r0, [pc, #0x168]        @ 0x107ea0 <.text+0xf7da0>
  107d34: e3a03001     	mov	r3, #1
  107d38: e59f1164     	ldr	r1, [pc, #0x164]        @ 0x107ea4 <.text+0xf7da4>
  107d3c: e59f2164     	ldr	r2, [pc, #0x164]        @ 0x107ea8 <.text+0xf7da8>
  107d40: e08f0000     	add	r0, pc, r0
  107d44: e08f1001     	add	r1, pc, r1
  107d48: e88d0088     	stm	sp, {r3, r7}
  107d4c: e08f2002     	add	r2, pc, r2
  107d50: e3003355     	movw	r3, #0x355
  107d54: e58d5008     	str	r5, [sp, #0x8]
  107d58: ebffc8d9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xdc9c
  107d5c: eaffffdf     	b	0x107ce0 <.text+0xf7be0> @ imm = #-0x84
  107d60: e59f0150     	ldr	r0, [pc, #0x150]        @ 0x107eb8 <.text+0xf7db8>
  107d64: e3a03001     	mov	r3, #1
  107d68: e59f114c     	ldr	r1, [pc, #0x14c]        @ 0x107ebc <.text+0xf7dbc>
  107d6c: e59f214c     	ldr	r2, [pc, #0x14c]        @ 0x107ec0 <.text+0xf7dc0>
  107d70: e08f0000     	add	r0, pc, r0
  107d74: e08f1001     	add	r1, pc, r1
  107d78: e88d0088     	stm	sp, {r3, r7}
  107d7c: e08f2002     	add	r2, pc, r2
  107d80: e300335b     	movw	r3, #0x35b
  107d84: e58d4008     	str	r4, [sp, #0x8]
  107d88: ebffc8cd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xdccc
  107d8c: e5950000     	ldr	r0, [r5]
  107d90: e2401001     	sub	r1, r0, #1
  107d94: e0010190     	mul	r1, r0, r1
  107d98: e3e00000     	mvn	r0, #0
  107d9c: e3110001     	tst	r1, #1
  107da0: 0a00001e     	beq	0x107e20 <.text+0xf7d20> @ imm = #0x78
  107da4: e5961000     	ldr	r1, [r6]
  107da8: e351000a     	cmp	r1, #10
  107dac: ba00001b     	blt	0x107e20 <.text+0xf7d20> @ imm = #0x6c
  107db0: e59f010c     	ldr	r0, [pc, #0x10c]        @ 0x107ec4 <.text+0xf7dc4>
  107db4: e3a03001     	mov	r3, #1
  107db8: e59f1108     	ldr	r1, [pc, #0x108]        @ 0x107ec8 <.text+0xf7dc8>
  107dbc: e59f2108     	ldr	r2, [pc, #0x108]        @ 0x107ecc <.text+0xf7dcc>
  107dc0: e08f0000     	add	r0, pc, r0
  107dc4: e08f1001     	add	r1, pc, r1
  107dc8: e88d0088     	stm	sp, {r3, r7}
  107dcc: e08f2002     	add	r2, pc, r2
  107dd0: e300335b     	movw	r3, #0x35b
  107dd4: e58d4008     	str	r4, [sp, #0x8]
  107dd8: ebffc8b9     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xdd1c
  107ddc: eaffffdf     	b	0x107d60 <.text+0xf7c60> @ imm = #-0x84
  107de0: e0810182     	add	r0, r1, r2, lsl #3
  107de4: e5900004     	ldr	r0, [r0, #0x4]
  107de8: e5830000     	str	r0, [r3]
  107dec: e5950000     	ldr	r0, [r5]
  107df0: e2407001     	sub	r7, r0, #1
  107df4: e0070790     	mul	r7, r0, r7
  107df8: e3a00000     	mov	r0, #0
  107dfc: e3170001     	tst	r7, #1
  107e00: 0a000006     	beq	0x107e20 <.text+0xf7d20> @ imm = #0x18
  107e04: e5967000     	ldr	r7, [r6]
  107e08: e3570009     	cmp	r7, #9
  107e0c: da000003     	ble	0x107e20 <.text+0xf7d20> @ imm = #0xc
  107e10: e0810182     	add	r0, r1, r2, lsl #3
  107e14: e5900004     	ldr	r0, [r0, #0x4]
  107e18: e5830000     	str	r0, [r3]
  107e1c: eaffffef     	b	0x107de0 <.text+0xf7ce0> @ imm = #-0x44
  107e20: e24bd010     	sub	sp, r11, #16
  107e24: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  107e28: 0054d364     	subseq	sp, r4, r4, ror #6
  107e2c: 004d7280     	subeq	r7, sp, r0, lsl #5
  107e30: 004d75e4     	subeq	r7, sp, r4, ror #11
  107e34: 004e5a74     	subeq	r5, lr, r4, ror r10
  107e38: 004e57eb     	subeq	r5, lr, r11, ror #15
  107e3c: 004e57ee     	subeq	r5, lr, lr, ror #15
  107e40: 004e580c     	subeq	r5, lr, r12, lsl #16
  107e44: 004e579f     	umaaleq	r5, lr, pc, r7
  107e48: 004e57a2     	subeq	r5, lr, r2, lsr #15
  107e4c: 004e57c0     	subeq	r5, lr, r0, asr #15
  107e50: 0054d344     	subseq	sp, r4, r4, asr #6
  107e54: 004e59ab     	subeq	r5, lr, r11, lsr #19
  107e58: 004e59aa     	subeq	r5, lr, r10, lsr #19
  107e5c: 004e59cc     	subeq	r5, lr, r12, asr #19
  107e60: 004e5a4e     	subeq	r5, lr, lr, asr #20
  107e64: 004e5a1b     	subeq	r5, lr, r11, lsl r10
  107e68: 004e5a1a     	subeq	r5, lr, r10, lsl r10
  107e6c: 004e5a3c     	subeq	r5, lr, r12, lsr r10
  107e70: 004e5ad4     	ldrdeq	r5, r6, [lr], #-164
  107e74: 004e5843     	subeq	r5, lr, r3, asr #16
  107e78: 004e5842     	subeq	r5, lr, r2, asr #16
  107e7c: 004e5864     	subeq	r5, lr, r4, ror #16
  107e80: 004e5912     	subeq	r5, lr, r2, lsl r9
  107e84: 0054d260     	subseq	sp, r4, r0, ror #4
  107e88: 004d7118     	subeq	r7, sp, r8, lsl r1
  107e8c: 004d747c     	subeq	r7, sp, r12, ror r4
  107e90: 004e5983     	subeq	r5, lr, r3, lsl #19
  107e94: 004e5773     	subeq	r5, lr, r3, ror r7
  107e98: 004e5776     	subeq	r5, lr, r6, ror r7
  107e9c: 004e5794     	umaaleq	r5, lr, r4, r7
  107ea0: 004e5723     	subeq	r5, lr, r3, lsr #14
  107ea4: 004e5726     	subeq	r5, lr, r6, lsr #14
  107ea8: 004e5744     	subeq	r5, lr, r4, asr #14
  107eac: 004d71d8     	ldrdeq	r7, r8, [sp], #-24
  107eb0: 004d752c     	subeq	r7, sp, r12, lsr #10
  107eb4: 004e59a1     	subeq	r5, lr, r1, lsr #19
  107eb8: 004e56f3     	strdeq	r5, r6, [lr], #-99
  107ebc: 004e56f6     	strdeq	r5, r6, [lr], #-102
  107ec0: 004e5714     	subeq	r5, lr, r4, lsl r7
  107ec4: 004e56a3     	subeq	r5, lr, r3, lsr #13
  107ec8: 004e56a6     	subeq	r5, lr, r6, lsr #13
  107ecc: 004e56c4     	subeq	r5, lr, r4, asr #13

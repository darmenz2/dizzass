
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   30a6c: ed990bea     	vldr	d0, [r9, #936]
   30a70: ed840b68     	vstr	d0, [r4, #416]
   30a74: e59903d0     	ldr	r0, [r9, #0x3d0]
   30a78: eb15cb88     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572e20
   30a7c: e584018c     	str	r0, [r4, #0x18c]
   30a80: e59903ec     	ldr	r0, [r9, #0x3ec]
   30a84: eb15cb85     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572e14
   30a88: e58401a8     	str	r0, [r4, #0x1a8]
   30a8c: e3000396     	movw	r0, #0x396
   30a90: e0890000     	add	r0, r9, r0
   30a94: eb15cb81     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572e04
   30a98: e584019c     	str	r0, [r4, #0x19c]
   30a9c: e59d000c     	ldr	r0, [sp, #0xc]
   30aa0: eb15d7f4     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x575fd0
   30aa4: e59f17dc     	ldr	r1, [pc, #0x7dc]        @ 0x31288 <.text+0x21188>
   30aa8: e79f1001     	ldr	r1, [pc, r1]
   30aac: e5911000     	ldr	r1, [r1]
   30ab0: e2412001     	sub	r2, r1, #1
   30ab4: e0010291     	mul	r1, r1, r2
   30ab8: e3110001     	tst	r1, #1
   30abc: 0a000039     	beq	0x30ba8 <.text+0x20aa8> @ imm = #0xe4
   30ac0: e59a1000     	ldr	r1, [r10]
   30ac4: e3510009     	cmp	r1, #9
   30ac8: da000036     	ble	0x30ba8 <.text+0x20aa8> @ imm = #0xd8
   30acc: e28dc01c     	add	r12, sp, #28
   30ad0: e59d5038     	ldr	r5, [sp, #0x38]
   30ad4: e89c10cf     	ldm	r12, {r0, r1, r2, r3, r6, r7, r12}
   30ad8: e6bf0f30     	rev	r0, r0
   30adc: e58d005c     	str	r0, [sp, #0x5c]
   30ae0: e6bf0f31     	rev	r0, r1
   30ae4: e58d0060     	str	r0, [sp, #0x60]
   30ae8: e6bf0f32     	rev	r0, r2
   30aec: e59f87fc     	ldr	r8, [pc, #0x7fc]        @ 0x312f0 <.text+0x211f0>
   30af0: e58d0064     	str	r0, [sp, #0x64]
   30af4: e6bf0f33     	rev	r0, r3
   30af8: e58d0068     	str	r0, [sp, #0x68]
   30afc: e6bf0f36     	rev	r0, r6
   30b00: e58d006c     	str	r0, [sp, #0x6c]
   30b04: e6bf0f37     	rev	r0, r7
   30b08: e58d0070     	str	r0, [sp, #0x70]
   30b0c: e6bf0f3c     	rev	r0, r12
   30b10: e58d0074     	str	r0, [sp, #0x74]
   30b14: e6bf0f35     	rev	r0, r5
   30b18: e58d0078     	str	r0, [sp, #0x78]
   30b1c: e08f8008     	add	r8, pc, r8
   30b20: e59f17cc     	ldr	r1, [pc, #0x7cc]        @ 0x312f4 <.text+0x211f4>
   30b24: e30003a6     	movw	r0, #0x3a6
   30b28: e58d0004     	str	r0, [sp, #0x4]
   30b2c: e1a00004     	mov	r0, r4
   30b30: e08f1001     	add	r1, pc, r1
   30b34: e58d1000     	str	r1, [sp]
   30b38: e3a02070     	mov	r2, #112
   30b3c: e1a03008     	mov	r3, r8
   30b40: e1a05001     	mov	r5, r1
   30b44: e2891fa6     	add	r1, r9, #664
   30b48: ebff848b     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1edd4
   30b4c: e30003a7     	movw	r0, #0x3a7
   30b50: e28d105c     	add	r1, sp, #92
   30b54: e58d0004     	str	r0, [sp, #0x4]
   30b58: e2840024     	add	r0, r4, #36
   30b5c: e3a02020     	mov	r2, #32
   30b60: e1a03008     	mov	r3, r8
   30b64: e58d5000     	str	r5, [sp]
   30b68: ebff8483     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1edf4
   30b6c: ed990bea     	vldr	d0, [r9, #936]
   30b70: ed840b68     	vstr	d0, [r4, #416]
   30b74: e59903d0     	ldr	r0, [r9, #0x3d0]
   30b78: eb15cb48     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572d20
   30b7c: e584018c     	str	r0, [r4, #0x18c]
   30b80: e59903ec     	ldr	r0, [r9, #0x3ec]
   30b84: eb15cb45     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572d14
   30b88: e58401a8     	str	r0, [r4, #0x1a8]
   30b8c: e3000396     	movw	r0, #0x396
   30b90: e0890000     	add	r0, r9, r0
   30b94: eb15cb41     	bl	0x5a38a0 <.text+0x5937a0> @ imm = #0x572d04
   30b98: e584019c     	str	r0, [r4, #0x19c]
   30b9c: e59d000c     	ldr	r0, [sp, #0xc]
   30ba0: eb15d7b4     	bl	0x5a6a78 <.text+0x596978> @ imm = #0x575ed0
   30ba4: eaffff88     	b	0x309cc <.text+0x208cc> @ imm = #-0x1e0
   30ba8: e59f86dc     	ldr	r8, [pc, #0x6dc]        @ 0x3128c <.text+0x2118c>
   30bac: e3500000     	cmp	r0, #0
   30bb0: e79f8008     	ldr	r8, [pc, r8]
   30bb4: 1a00000b     	bne	0x30be8 <.text+0x20ae8> @ imm = #0x2c
   30bb8: e5980000     	ldr	r0, [r8]
   30bbc: e284ac01     	add	r10, r4, #256
   30bc0: e2401001     	sub	r1, r0, #1
   30bc4: e0000190     	mul	r0, r0, r1
   30bc8: e3100001     	tst	r0, #1
   30bcc: 0a00002e     	beq	0x30c8c <.text+0x20b8c> @ imm = #0xb8
   30bd0: e59f06c4     	ldr	r0, [pc, #0x6c4]        @ 0x3129c <.text+0x2119c>
   30bd4: e79f0000     	ldr	r0, [pc, r0]
   30bd8: e5900000     	ldr	r0, [r0]
   30bdc: e3500009     	cmp	r0, #9
   30be0: ca00007f     	bgt	0x30de4 <.text+0x20ce4> @ imm = #0x1fc
   30be4: ea000028     	b	0x30c8c <.text+0x20b8c> @ imm = #0xa0
   30be8: e5980000     	ldr	r0, [r8]
   30bec: e2401001     	sub	r1, r0, #1
   30bf0: e0000190     	mul	r0, r0, r1
   30bf4: e3100001     	tst	r0, #1
   30bf8: 0a000002     	beq	0x30c08 <.text+0x20b08> @ imm = #0x8
   30bfc: e59a0000     	ldr	r0, [r10]
   30c00: e3500009     	cmp	r0, #9
   30c04: ca000013     	bgt	0x30c58 <.text+0x20b58> @ imm = #0x4c
   30c08: eb158975     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x5625d4
   30c0c: e59f267c     	ldr	r2, [pc, #0x67c]        @ 0x31290 <.text+0x21190>
   30c10: e59f167c     	ldr	r1, [pc, #0x67c]        @ 0x31294 <.text+0x21194>
   30c14: e5900000     	ldr	r0, [r0]
   30c18: e08f2002     	add	r2, pc, r2
   30c1c: e59f3674     	ldr	r3, [pc, #0x674]        @ 0x31298 <.text+0x21198>
   30c20: e08f1001     	add	r1, pc, r1
   30c24: e58d0000     	str	r0, [sp]
   30c28: e1a00002     	mov	r0, r2
   30c2c: e08f3003     	add	r3, pc, r3
   30c30: e300224f     	movw	r2, #0x24f
   30c34: ebff7d97     	bl	0x10298 <.text+0x198>   @ imm = #-0x209a4
   30c38: e5980000     	ldr	r0, [r8]
   30c3c: e2401001     	sub	r1, r0, #1
   30c40: e0000190     	mul	r0, r0, r1
   30c44: e3100001     	tst	r0, #1
   30c48: 0affffda     	beq	0x30bb8 <.text+0x20ab8> @ imm = #-0x98
   30c4c: e59a0000     	ldr	r0, [r10]
   30c50: e3500009     	cmp	r0, #9
   30c54: daffffd7     	ble	0x30bb8 <.text+0x20ab8> @ imm = #-0xa4
   30c58: eb158961     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x562584
   30c5c: e59f2694     	ldr	r2, [pc, #0x694]        @ 0x312f8 <.text+0x211f8>
   30c60: e59f1694     	ldr	r1, [pc, #0x694]        @ 0x312fc <.text+0x211fc>
   30c64: e5900000     	ldr	r0, [r0]
   30c68: e08f2002     	add	r2, pc, r2
   30c6c: e59f368c     	ldr	r3, [pc, #0x68c]        @ 0x31300 <.text+0x21200>
   30c70: e08f1001     	add	r1, pc, r1
   30c74: e58d0000     	str	r0, [sp]
   30c78: e1a00002     	mov	r0, r2
   30c7c: e08f3003     	add	r3, pc, r3
   30c80: e300224f     	movw	r2, #0x24f
   30c84: ebff7d83     	bl	0x10298 <.text+0x198>   @ imm = #-0x209f4
   30c88: eaffffde     	b	0x30c08 <.text+0x20b08> @ imm = #-0x88
   30c8c: e59f060c     	ldr	r0, [pc, #0x60c]        @ 0x312a0 <.text+0x211a0>
   30c90: e79f0000     	ldr	r0, [pc, r0]
   30c94: e5900000     	ldr	r0, [r0]
   30c98: e12fff30     	blx	r0
   30c9c: e894004f     	ldm	r4, {r0, r1, r2, r3, r6}
   30ca0: e284c014     	add	r12, r4, #20
   30ca4: e6bf0f30     	rev	r0, r0
   30ca8: e89c10a0     	ldm	r12, {r5, r7, r12}
   30cac: e50b006c     	str	r0, [r11, #-0x6c]
   30cb0: e6bf0f31     	rev	r0, r1
   30cb4: e50b0068     	str	r0, [r11, #-0x68]
   30cb8: e6bf0f32     	rev	r0, r2
   30cbc: e50b0064     	str	r0, [r11, #-0x64]
   30cc0: e6bf0f33     	rev	r0, r3
   30cc4: e50b0060     	str	r0, [r11, #-0x60]
   30cc8: e6bf0f36     	rev	r0, r6
   30ccc: e50b005c     	str	r0, [r11, #-0x5c]
   30cd0: e6bf0f35     	rev	r0, r5
   30cd4: e50b0058     	str	r0, [r11, #-0x58]
   30cd8: e6bf0f37     	rev	r0, r7
   30cdc: e2847020     	add	r7, r4, #32
   30ce0: e50b0054     	str	r0, [r11, #-0x54]
   30ce4: e6bf0f3c     	rev	r0, r12
   30ce8: e50b0050     	str	r0, [r11, #-0x50]
   30cec: e897008f     	ldm	r7, {r0, r1, r2, r3, r7}
   30cf0: e6bf0f30     	rev	r0, r0
   30cf4: e5946034     	ldr	r6, [r4, #0x34]
   30cf8: e5945038     	ldr	r5, [r4, #0x38]
   30cfc: e594c03c     	ldr	r12, [r4, #0x3c]
   30d00: e50b004c     	str	r0, [r11, #-0x4c]
   30d04: e6bf0f31     	rev	r0, r1
   30d08: e50b0048     	str	r0, [r11, #-0x48]
   30d0c: e6bf0f32     	rev	r0, r2
   30d10: e50b0044     	str	r0, [r11, #-0x44]
   30d14: e6bf0f33     	rev	r0, r3
   30d18: e50b0040     	str	r0, [r11, #-0x40]
   30d1c: e6bf0f37     	rev	r0, r7
   30d20: e50b003c     	str	r0, [r11, #-0x3c]
   30d24: e6bf0f36     	rev	r0, r6
   30d28: e50b0038     	str	r0, [r11, #-0x38]
   30d2c: e6bf0f35     	rev	r0, r5
   30d30: e28d507c     	add	r5, sp, #124
   30d34: e50b0034     	str	r0, [r11, #-0x34]
   30d38: e6bf0f3c     	rev	r0, r12
   30d3c: e50b0030     	str	r0, [r11, #-0x30]
   30d40: e1a00005     	mov	r0, r5
   30d44: eb0360f5     	bl	0x109120 <.text+0xf9020> @ imm = #0xd83d4
   30d48: e24b106c     	sub	r1, r11, #108
   30d4c: e1a00005     	mov	r0, r5
   30d50: e3a02040     	mov	r2, #64
   30d54: eb036105     	bl	0x109170 <.text+0xf9070> @ imm = #0xd8414
   30d58: e59f3544     	ldr	r3, [pc, #0x544]        @ 0x312a4 <.text+0x211a4>
   30d5c: e3000151     	movw	r0, #0x151
   30d60: e59f1540     	ldr	r1, [pc, #0x540]        @ 0x312a8 <.text+0x211a8>
   30d64: e3a02020     	mov	r2, #32
   30d68: e58d0004     	str	r0, [sp, #0x4]
   30d6c: e08f3003     	add	r3, pc, r3
   30d70: e08f1001     	add	r1, pc, r1
   30d74: e58d1000     	str	r1, [sp]
   30d78: e2840080     	add	r0, r4, #128
   30d7c: e2851088     	add	r1, r5, #136
   30d80: ebff83fd     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1f00c
   30d84: ed940b68     	vldr	d0, [r4, #416]
   30d88: e1a0000a     	mov	r0, r10
   30d8c: ebfffc33     	bl	0x2fe60 <.text+0x1fd60> @ imm = #-0xf34
   30d90: e3a00053     	mov	r0, #83
   30d94: e3a0203c     	mov	r2, #60
   30d98: e5c40250     	strb	r0, [r4, #0x250]
   30d9c: e3a00000     	mov	r0, #0
   30da0: e584916c     	str	r9, [r4, #0x16c]
   30da4: e59f1500     	ldr	r1, [pc, #0x500]        @ 0x312ac <.text+0x211ac>
   30da8: e79f1001     	ldr	r1, [pc, r1]
   30dac: e584215c     	str	r2, [r4, #0x15c]
   30db0: e5840160     	str	r0, [r4, #0x160]
   30db4: e58411b8     	str	r1, [r4, #0x1b8]
   30db8: e5980000     	ldr	r0, [r8]
   30dbc: ed948b68     	vldr	d8, [r4, #416]
   30dc0: e2401001     	sub	r1, r0, #1
   30dc4: e0000190     	mul	r0, r0, r1
   30dc8: e3100001     	tst	r0, #1
   30dcc: 0a000051     	beq	0x30f18 <.text+0x20e18> @ imm = #0x144
   30dd0: e59f04d8     	ldr	r0, [pc, #0x4d8]        @ 0x312b0 <.text+0x211b0>
   30dd4: e79f0000     	ldr	r0, [pc, r0]
   30dd8: e5900000     	ldr	r0, [r0]
   30ddc: e3500009     	cmp	r0, #9
   30de0: da00004c     	ble	0x30f18 <.text+0x20e18> @ imm = #0x130
   30de4: e59f0518     	ldr	r0, [pc, #0x518]        @ 0x31304 <.text+0x21204>
   30de8: e79f0000     	ldr	r0, [pc, r0]
   30dec: e5900000     	ldr	r0, [r0]
   30df0: e12fff30     	blx	r0
   30df4: e894008f     	ldm	r4, {r0, r1, r2, r3, r7}
   30df8: e6bf0f30     	rev	r0, r0
   30dfc: e5946014     	ldr	r6, [r4, #0x14]
   30e00: e5945018     	ldr	r5, [r4, #0x18]
   30e04: e594c01c     	ldr	r12, [r4, #0x1c]
   30e08: e50b006c     	str	r0, [r11, #-0x6c]
   30e0c: e6bf0f31     	rev	r0, r1
   30e10: e50b0068     	str	r0, [r11, #-0x68]
   30e14: e6bf0f32     	rev	r0, r2
   30e18: e50b0064     	str	r0, [r11, #-0x64]
   30e1c: e6bf0f33     	rev	r0, r3
   30e20: e50b0060     	str	r0, [r11, #-0x60]
   30e24: e6bf0f37     	rev	r0, r7
   30e28: e50b005c     	str	r0, [r11, #-0x5c]
   30e2c: e6bf0f36     	rev	r0, r6
   30e30: e50b0058     	str	r0, [r11, #-0x58]
   30e34: e6bf0f35     	rev	r0, r5
   30e38: e2847020     	add	r7, r4, #32
   30e3c: e50b0054     	str	r0, [r11, #-0x54]
   30e40: e6bf0f3c     	rev	r0, r12
   30e44: e50b0050     	str	r0, [r11, #-0x50]
   30e48: e897008f     	ldm	r7, {r0, r1, r2, r3, r7}
   30e4c: e6bf0f30     	rev	r0, r0
   30e50: e5946034     	ldr	r6, [r4, #0x34]
   30e54: e5945038     	ldr	r5, [r4, #0x38]
   30e58: e594c03c     	ldr	r12, [r4, #0x3c]
   30e5c: e50b004c     	str	r0, [r11, #-0x4c]
   30e60: e6bf0f31     	rev	r0, r1
   30e64: e50b0048     	str	r0, [r11, #-0x48]
   30e68: e6bf0f32     	rev	r0, r2
   30e6c: e50b0044     	str	r0, [r11, #-0x44]
   30e70: e6bf0f33     	rev	r0, r3
   30e74: e50b0040     	str	r0, [r11, #-0x40]
   30e78: e6bf0f37     	rev	r0, r7
   30e7c: e50b003c     	str	r0, [r11, #-0x3c]
   30e80: e6bf0f36     	rev	r0, r6
   30e84: e50b0038     	str	r0, [r11, #-0x38]
   30e88: e6bf0f35     	rev	r0, r5
   30e8c: e28d507c     	add	r5, sp, #124
   30e90: e50b0034     	str	r0, [r11, #-0x34]
   30e94: e6bf0f3c     	rev	r0, r12
   30e98: e50b0030     	str	r0, [r11, #-0x30]
   30e9c: e1a00005     	mov	r0, r5
   30ea0: eb03609e     	bl	0x109120 <.text+0xf9020> @ imm = #0xd8278
   30ea4: e24b106c     	sub	r1, r11, #108
   30ea8: e1a00005     	mov	r0, r5
   30eac: e3a02040     	mov	r2, #64
   30eb0: eb0360ae     	bl	0x109170 <.text+0xf9070> @ imm = #0xd82b8
   30eb4: e59f344c     	ldr	r3, [pc, #0x44c]        @ 0x31308 <.text+0x21208>
   30eb8: e3000151     	movw	r0, #0x151
   30ebc: e59f1448     	ldr	r1, [pc, #0x448]        @ 0x3130c <.text+0x2120c>
   30ec0: e3a02020     	mov	r2, #32
   30ec4: e58d0004     	str	r0, [sp, #0x4]
   30ec8: e08f3003     	add	r3, pc, r3
   30ecc: e08f1001     	add	r1, pc, r1
   30ed0: e58d1000     	str	r1, [sp]
   30ed4: e2840080     	add	r0, r4, #128
   30ed8: e2851088     	add	r1, r5, #136
   30edc: ebff83a6     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1f168
   30ee0: ed940b68     	vldr	d0, [r4, #416]
   30ee4: e1a0000a     	mov	r0, r10
   30ee8: ebfffbdc     	bl	0x2fe60 <.text+0x1fd60> @ imm = #-0x1090
   30eec: e3a00053     	mov	r0, #83
   30ef0: e3a0203c     	mov	r2, #60
   30ef4: e5c40250     	strb	r0, [r4, #0x250]
   30ef8: e3a00000     	mov	r0, #0
   30efc: e584916c     	str	r9, [r4, #0x16c]
   30f00: e59f1408     	ldr	r1, [pc, #0x408]        @ 0x31310 <.text+0x21210>
   30f04: e79f1001     	ldr	r1, [pc, r1]
   30f08: e584215c     	str	r2, [r4, #0x15c]
   30f0c: e5840160     	str	r0, [r4, #0x160]
   30f10: e58411b8     	str	r1, [r4, #0x1b8]
   30f14: eaffff5c     	b	0x30c8c <.text+0x20b8c> @ imm = #-0x290
   30f18: eeb58b40     	vcmp.f64	d8, #0
   30f1c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   30f20: 1a000021     	bne	0x30fac <.text+0x20eac> @ imm = #0x84
   30f24: e59f6388     	ldr	r6, [pc, #0x388]        @ 0x312b4 <.text+0x211b4>
   30f28: e79f6006     	ldr	r6, [pc, r6]
   30f2c: e5960000     	ldr	r0, [r6]
   30f30: e2401001     	sub	r1, r0, #1
   30f34: e0000190     	mul	r0, r0, r1
   30f38: e3100001     	tst	r0, #1
   30f3c: 0a000004     	beq	0x30f54 <.text+0x20e54> @ imm = #0x10
   30f40: e59f0370     	ldr	r0, [pc, #0x370]        @ 0x312b8 <.text+0x211b8>
   30f44: e79f0000     	ldr	r0, [pc, r0]
   30f48: e5900000     	ldr	r0, [r0]
   30f4c: e3500009     	cmp	r0, #9
   30f50: ca00000d     	bgt	0x30f8c <.text+0x20e8c> @ imm = #0x34
   30f54: e3a00018     	mov	r0, #24
   30f58: e5905000     	ldr	r5, [r0]
   30f5c: e3a00000     	mov	r0, #0
   30f60: ebffe0b4     	bl	0x29238 <.text+0x19138> @ imm = #-0x7d30
   30f64: e5961000     	ldr	r1, [r6]
   30f68: e2412001     	sub	r2, r1, #1
   30f6c: e0010291     	mul	r1, r1, r2
   30f70: e3110001     	tst	r1, #1
   30f74: 0a000007     	beq	0x30f98 <.text+0x20e98> @ imm = #0x1c
   30f78: e59f133c     	ldr	r1, [pc, #0x33c]        @ 0x312bc <.text+0x211bc>
   30f7c: e79f1001     	ldr	r1, [pc, r1]
   30f80: e5911000     	ldr	r1, [r1]
   30f84: e3510009     	cmp	r1, #9
   30f88: da000002     	ble	0x30f98 <.text+0x20e98> @ imm = #0x8
   30f8c: e3a00000     	mov	r0, #0
   30f90: ebffe0a8     	bl	0x29238 <.text+0x19138> @ imm = #-0x7d60
   30f94: eaffffee     	b	0x30f54 <.text+0x20e54> @ imm = #-0x48
   30f98: e3500000     	cmp	r0, #0
   30f9c: ed9f8b97     	vldr	d8, [pc, #604]          @ 0x31200 <.text+0x21100>
   30fa0: 15900014     	ldrne	r0, [r0, #0x14]
   30fa4: 13500000     	cmpne	r0, #0
   30fa8: 1a00002a     	bne	0x31058 <.text+0x20f58> @ imm = #0xa8
   30fac: eeb00b48     	vmov.f64	d0, d8
   30fb0: eb1595f0     	bl	0x596778 <.text+0x586678> @ imm = #0x5657c0
   30fb4: ec510b10     	vmov	r0, r1, d0
   30fb8: ed848b78     	vstr	d8, [r4, #480]
   30fbc: ed898b6a     	vstr	d8, [r9, #424]
   30fc0: eb158150     	bl	0x591508 <.text+0x581408> @ imm = #0x560540
   30fc4: e594216c     	ldr	r2, [r4, #0x16c]
   30fc8: e3a03000     	mov	r3, #0
   30fcc: e58d3000     	str	r3, [sp]
   30fd0: e3a03008     	mov	r3, #8
   30fd4: e2822090     	add	r2, r2, #144
   30fd8: ebfff100     	bl	0x2d3e0 <.text+0x1d2e0> @ imm = #-0x3c00
   30fdc: ed990b66     	vldr	d0, [r9, #408]
   30fe0: eeb48b40     	vcmp.f64	d8, d0
   30fe4: eef1fa10     	vmrs	APSR_nzcv, fpscr
   30fe8: 1a000007     	bne	0x3100c <.text+0x20f0c> @ imm = #0x1c
   30fec: e59901b0     	ldr	r0, [r9, #0x1b0]
   30ff0: e2800001     	add	r0, r0, #1
   30ff4: e58901b0     	str	r0, [r9, #0x1b0]
   30ff8: e59f52cc     	ldr	r5, [pc, #0x2cc]        @ 0x312cc <.text+0x211cc>
   30ffc: e79f5005     	ldr	r5, [pc, r5]
   31000: e59f62c8     	ldr	r6, [pc, #0x2c8]        @ 0x312d0 <.text+0x211d0>
   31004: e79f6006     	ldr	r6, [pc, r6]
   31008: ea000056     	b	0x31168 <.text+0x21068> @ imm = #0x158
   3100c: e59f52c0     	ldr	r5, [pc, #0x2c0]        @ 0x312d4 <.text+0x211d4>
   31010: eeb48bc0     	vcmpe.f64	d8, d0
   31014: e79f5005     	ldr	r5, [pc, r5]
   31018: e59f62b8     	ldr	r6, [pc, #0x2b8]        @ 0x312d8 <.text+0x211d8>
   3101c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   31020: e79f6006     	ldr	r6, [pc, r6]
   31024: 4a000002     	bmi	0x31034 <.text+0x20f34> @ imm = #0x8
   31028: eeb50b40     	vcmp.f64	d0, #0
   3102c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   31030: 1a00004c     	bne	0x31168 <.text+0x21068> @ imm = #0x130
   31034: e5950000     	ldr	r0, [r5]
   31038: e2401001     	sub	r1, r0, #1
   3103c: e0000190     	mul	r0, r0, r1
   31040: e3100001     	tst	r0, #1
   31044: 0a000038     	beq	0x3112c <.text+0x2102c> @ imm = #0xe0
   31048: e5960000     	ldr	r0, [r6]
   3104c: e3500009     	cmp	r0, #9
   31050: ca000040     	bgt	0x31158 <.text+0x21058> @ imm = #0x100
   31054: ea000034     	b	0x3112c <.text+0x2102c> @ imm = #0xd0
   31058: e59f0260     	ldr	r0, [pc, #0x260]        @ 0x312c0 <.text+0x211c0>
   3105c: e79f0000     	ldr	r0, [pc, r0]
   31060: e5900000     	ldr	r0, [r0]
   31064: e2401001     	sub	r1, r0, #1
   31068: e0000190     	mul	r0, r0, r1
   3106c: e3100001     	tst	r0, #1
   31070: e1ca01d8     	ldrd	r0, r1, [r10, #24]
   31074: eb1580af     	bl	0x591338 <.text+0x581238> @ imm = #0x5602bc
   31078: e1a08000     	mov	r8, r0
   3107c: e1a06001     	mov	r6, r1
   31080: e1ca01d0     	ldrd	r0, r1, [r10, #16]
   31084: eb1580ab     	bl	0x591338 <.text+0x581238> @ imm = #0x5602ac
   31088: ec410b11     	vmov	d1, r0, r1
   3108c: ed9f0b5d     	vldr	d0, [pc, #372]          @ 0x31208 <.text+0x21108>
   31090: e59a0008     	ldr	r0, [r10, #0x8]
   31094: ee218b00     	vmul.f64	d8, d1, d0
   31098: e59a100c     	ldr	r1, [r10, #0xc]
   3109c: ec468b11     	vmov	d1, r8, r6
   310a0: ed9f0b5a     	vldr	d0, [pc, #360]          @ 0x31210 <.text+0x21110>
   310a4: e89a0140     	ldm	r10, {r6, r8}
   310a8: ee018b00     	vmla.f64	d8, d1, d0
   310ac: eb1580a1     	bl	0x591338 <.text+0x581238> @ imm = #0x560284
   310b0: ec410b11     	vmov	d1, r0, r1
   310b4: ed9f0b57     	vldr	d0, [pc, #348]          @ 0x31218 <.text+0x21118>
   310b8: e1a00006     	mov	r0, r6
   310bc: e1a01008     	mov	r1, r8
   310c0: ee018b00     	vmla.f64	d8, d1, d0
   310c4: eb15809b     	bl	0x591338 <.text+0x581238> @ imm = #0x56026c
   310c8: ec410b10     	vmov	d0, r0, r1
   310cc: e5950034     	ldr	r0, [r5, #0x34]
   310d0: ed9f1b4a     	vldr	d1, [pc, #296]          @ 0x31200 <.text+0x21100>
   310d4: e28f1f51     	add	r1, pc, #324
   310d8: ee380b00     	vadd.f64	d0, d8, d0
   310dc: eeb50b40     	vcmp.f64	d0, #0
   310e0: eef1fa10     	vmrs	APSR_nzcv, fpscr
   310e4: 0eb00b41     	vmoveq.f64	d0, d1
   310e8: e3500001     	cmp	r0, #1
   310ec: 02811008     	addeq	r1, r1, #8
   310f0: e59f01cc     	ldr	r0, [pc, #0x1cc]        @ 0x312c4 <.text+0x211c4>
   310f4: ed911b00     	vldr	d1, [r1]
   310f8: e79f0000     	ldr	r0, [pc, r0]
   310fc: ee818b00     	vdiv.f64	d8, d1, d0
   31100: e5900000     	ldr	r0, [r0]
   31104: e2401001     	sub	r1, r0, #1
   31108: e0000190     	mul	r0, r0, r1
   3110c: e3100001     	tst	r0, #1
   31110: 0affffa5     	beq	0x30fac <.text+0x20eac> @ imm = #-0x16c
   31114: e59f01ac     	ldr	r0, [pc, #0x1ac]        @ 0x312c8 <.text+0x211c8>
   31118: e79f0000     	ldr	r0, [pc, r0]
   3111c: e5900000     	ldr	r0, [r0]
   31120: e3500009     	cmp	r0, #9
   31124: caffffd1     	bgt	0x31070 <.text+0x20f70> @ imm = #-0xbc
   31128: eaffff9f     	b	0x30fac <.text+0x20eac> @ imm = #-0x184
   3112c: e3a00001     	mov	r0, #1
   31130: e58901b0     	str	r0, [r9, #0x1b0]
   31134: ed898b66     	vstr	d8, [r9, #408]
   31138: e5950000     	ldr	r0, [r5]
   3113c: e2401001     	sub	r1, r0, #1
   31140: e0000190     	mul	r0, r0, r1
   31144: e3100001     	tst	r0, #1
   31148: 0a000006     	beq	0x31168 <.text+0x21068> @ imm = #0x18
   3114c: e5960000     	ldr	r0, [r6]
   31150: e3500009     	cmp	r0, #9
   31154: da000003     	ble	0x31168 <.text+0x21068> @ imm = #0xc
   31158: e3a00001     	mov	r0, #1
   3115c: e58901b0     	str	r0, [r9, #0x1b0]
   31160: ed898b66     	vstr	d8, [r9, #408]
   31164: eafffff0     	b	0x3112c <.text+0x2102c> @ imm = #-0x40
   31168: ed990b68     	vldr	d0, [r9, #416]
   3116c: eeb48b40     	vcmp.f64	d8, d0
   31170: eef1fa10     	vmrs	APSR_nzcv, fpscr
   31174: 1a000003     	bne	0x31188 <.text+0x21088> @ imm = #0xc
   31178: e59901b4     	ldr	r0, [r9, #0x1b4]
   3117c: e2800001     	add	r0, r0, #1
   31180: e58901b4     	str	r0, [r9, #0x1b4]
   31184: ea000004     	b	0x3119c <.text+0x2109c> @ imm = #0x10
   31188: eeb48bc0     	vcmpe.f64	d8, d0
   3118c: eef1fa10     	vmrs	APSR_nzcv, fpscr
   31190: c3a00001     	movgt	r0, #1
   31194: c58901b4     	strgt	r0, [r9, #0x1b4]
   31198: cd898b68     	vstrgt	d8, [r9, #416]
   3119c: e5950000     	ldr	r0, [r5]
   311a0: e2401001     	sub	r1, r0, #1
   311a4: e0000190     	mul	r0, r0, r1
   311a8: e3100001     	tst	r0, #1
   311ac: 0a000002     	beq	0x311bc <.text+0x210bc> @ imm = #0x8
   311b0: e5960000     	ldr	r0, [r6]
   311b4: e3500009     	cmp	r0, #9
   311b8: ca000009     	bgt	0x311e4 <.text+0x210e4> @ imm = #0x24
   311bc: e2840e17     	add	r0, r4, #368
   311c0: ebff8419     	bl	0x1222c <.text+0x212c>  @ imm = #-0x1ef9c
   311c4: e5950000     	ldr	r0, [r5]
   311c8: e2401001     	sub	r1, r0, #1
   311cc: e0000190     	mul	r0, r0, r1
   311d0: e3100001     	tst	r0, #1
   311d4: 0a000005     	beq	0x311f0 <.text+0x210f0> @ imm = #0x14
   311d8: e5960000     	ldr	r0, [r6]
   311dc: e3500009     	cmp	r0, #9
   311e0: da000002     	ble	0x311f0 <.text+0x210f0> @ imm = #0x8
   311e4: e2840e17     	add	r0, r4, #368
   311e8: ebff840f     	bl	0x1222c <.text+0x212c>  @ imm = #-0x1efc4
   311ec: eafffff2     	b	0x311bc <.text+0x210bc> @ imm = #-0x38
   311f0: e24bd028     	sub	sp, r11, #40
   311f4: ecbd8b02     	vpop	{d8}
   311f8: e28dd004     	add	sp, sp, #4
   311fc: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   31200: 00000000     	andeq	r0, r0, r0
   31204: 3ff00000     	svclo	#0xf00000
   31208: 00000000     	andeq	r0, r0, r0
   3120c: 47f00000     	ldrbmi	r0, [r0, r0]!
   31210: 00000000     	andeq	r0, r0, r0
   31214: 4bf00000     	blmi	0xffc3121c              @ imm = #-0x400000
   31218: 00000000     	andeq	r0, r0, r0
   3121c: 43f00000     	mvnsmi	r0, #0
   31220: 00000000     	andeq	r0, r0, r0
   31224: 4defffe0     	stclmi	p15, c15, [pc, #896]!
   31228: 00000000     	andeq	r0, r0, r0

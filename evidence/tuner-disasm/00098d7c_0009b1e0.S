
/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   98d7c: e92d4800     	push	{r11, lr}
   98d80: e3a00000     	mov	r0, #0
   98d84: e3500000     	cmp	r0, #0
   98d88: 1a000007     	bne	0x98dac <.text+0x88cac> @ imm = #0x1c
   98d8c: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x99d60 <.text+0x89c60>
   98d90: e08f1001     	add	r1, pc, r1
   98d94: e7d12000     	ldrb	r2, [r1, r0]
   98d98: e222205c     	eor	r2, r2, #92
   98d9c: e7c12000     	strb	r2, [r1, r0]
   98da0: e2800001     	add	r0, r0, #1
   98da4: e3500007     	cmp	r0, #7
   98da8: 1afffff9     	bne	0x98d94 <.text+0x88c94> @ imm = #-0x1c
   98dac: e3a00000     	mov	r0, #0
   98db0: e3500000     	cmp	r0, #0
   98db4: 1a000007     	bne	0x98dd8 <.text+0x88cd8> @ imm = #0x1c
   98db8: e59f1fe8     	ldr	r1, [pc, #0xfe8]        @ 0x99da8 <.text+0x89ca8>
   98dbc: e08f1001     	add	r1, pc, r1
   98dc0: e7d12000     	ldrb	r2, [r1, r0]
   98dc4: e2222083     	eor	r2, r2, #131
   98dc8: e7c12000     	strb	r2, [r1, r0]
   98dcc: e2800001     	add	r0, r0, #1
   98dd0: e350002a     	cmp	r0, #42
   98dd4: 1afffff9     	bne	0x98dc0 <.text+0x88cc0> @ imm = #-0x1c
   98dd8: e3a00000     	mov	r0, #0
   98ddc: e3500000     	cmp	r0, #0
   98de0: 1a000007     	bne	0x98e04 <.text+0x88d04> @ imm = #0x1c
   98de4: e59f1fc0     	ldr	r1, [pc, #0xfc0]        @ 0x99dac <.text+0x89cac>
   98de8: e08f1001     	add	r1, pc, r1
   98dec: e7d12000     	ldrb	r2, [r1, r0]
   98df0: e22220ee     	eor	r2, r2, #238
   98df4: e7c12000     	strb	r2, [r1, r0]
   98df8: e2800001     	add	r0, r0, #1
   98dfc: e350000b     	cmp	r0, #11
   98e00: 1afffff9     	bne	0x98dec <.text+0x88cec> @ imm = #-0x1c
   98e04: e3a00000     	mov	r0, #0
   98e08: e3500000     	cmp	r0, #0
   98e0c: 1a000007     	bne	0x98e30 <.text+0x88d30> @ imm = #0x1c
   98e10: e59f1f98     	ldr	r1, [pc, #0xf98]        @ 0x99db0 <.text+0x89cb0>
   98e14: e08f1001     	add	r1, pc, r1
   98e18: e7d12000     	ldrb	r2, [r1, r0]
   98e1c: e222201f     	eor	r2, r2, #31
   98e20: e7c12000     	strb	r2, [r1, r0]
   98e24: e2800001     	add	r0, r0, #1
   98e28: e3500020     	cmp	r0, #32
   98e2c: 1afffff9     	bne	0x98e18 <.text+0x88d18> @ imm = #-0x1c
   98e30: e3a00000     	mov	r0, #0
   98e34: e3500000     	cmp	r0, #0
   98e38: 1a000007     	bne	0x98e5c <.text+0x88d5c> @ imm = #0x1c
   98e3c: e59f1ff4     	ldr	r1, [pc, #0xff4]        @ 0x99e38 <.text+0x89d38>
   98e40: e08f1001     	add	r1, pc, r1
   98e44: e7d12000     	ldrb	r2, [r1, r0]
   98e48: e22220ca     	eor	r2, r2, #202
   98e4c: e7c12000     	strb	r2, [r1, r0]
   98e50: e2800001     	add	r0, r0, #1
   98e54: e350001a     	cmp	r0, #26
   98e58: 1afffff9     	bne	0x98e44 <.text+0x88d44> @ imm = #-0x1c
   98e5c: e3a00000     	mov	r0, #0
   98e60: e3500000     	cmp	r0, #0
   98e64: 1a000007     	bne	0x98e88 <.text+0x88d88> @ imm = #0x1c
   98e68: e59f1fcc     	ldr	r1, [pc, #0xfcc]        @ 0x99e3c <.text+0x89d3c>
   98e6c: e08f1001     	add	r1, pc, r1
   98e70: e7d12000     	ldrb	r2, [r1, r0]
   98e74: e2222026     	eor	r2, r2, #38
   98e78: e7c12000     	strb	r2, [r1, r0]
   98e7c: e2800001     	add	r0, r0, #1
   98e80: e3500016     	cmp	r0, #22
   98e84: 1afffff9     	bne	0x98e70 <.text+0x88d70> @ imm = #-0x1c
   98e88: e59fefb0     	ldr	lr, [pc, #0xfb0]        @ 0x99e40 <.text+0x89d40>
   98e8c: e79fe00e     	ldr	lr, [pc, lr]
   98e90: e59e1000     	ldr	r1, [lr]
   98e94: e2412001     	sub	r2, r1, #1
   98e98: e0010291     	mul	r1, r1, r2
   98e9c: e3110001     	tst	r1, #1
   98ea0: e59e1000     	ldr	r1, [lr]
   98ea4: e59fcf98     	ldr	r12, [pc, #0xf98]       @ 0x99e44 <.text+0x89d44>
   98ea8: e2412001     	sub	r2, r1, #1
   98eac: e0010291     	mul	r1, r1, r2
   98eb0: e79fc00c     	ldr	r12, [pc, r12]
   98eb4: e3110001     	tst	r1, #1
   98eb8: 0a000002     	beq	0x98ec8 <.text+0x88dc8> @ imm = #0x8
   98ebc: e59c1000     	ldr	r1, [r12]
   98ec0: e3510009     	cmp	r1, #9
   98ec4: cafffff5     	bgt	0x98ea0 <.text+0x88da0> @ imm = #-0x2c
   98ec8: e3a02000     	mov	r2, #0
   98ecc: e3520000     	cmp	r2, #0
   98ed0: 1a00001d     	bne	0x98f4c <.text+0x88e4c> @ imm = #0x74
   98ed4: e59f3fd8     	ldr	r3, [pc, #0xfd8]        @ 0x99eb4 <.text+0x89db4>
   98ed8: e08f3003     	add	r3, pc, r3
   98edc: ea000002     	b	0x98eec <.text+0x88dec> @ imm = #0x8
   98ee0: e3510009     	cmp	r1, #9
   98ee4: e1a02001     	mov	r2, r1
   98ee8: 0a000017     	beq	0x98f4c <.text+0x88e4c> @ imm = #0x5c
   98eec: e59e1000     	ldr	r1, [lr]
   98ef0: e2410001     	sub	r0, r1, #1
   98ef4: e0000091     	mul	r0, r1, r0
   98ef8: e3100001     	tst	r0, #1
   98efc: 0a000002     	beq	0x98f0c <.text+0x88e0c> @ imm = #0x8
   98f00: e59c0000     	ldr	r0, [r12]
   98f04: e3500009     	cmp	r0, #9
   98f08: ca00000b     	bgt	0x98f3c <.text+0x88e3c> @ imm = #0x2c
   98f0c: e7d30002     	ldrb	r0, [r3, r2]
   98f10: e2200006     	eor	r0, r0, #6
   98f14: e7c30002     	strb	r0, [r3, r2]
   98f18: e59e0000     	ldr	r0, [lr]
   98f1c: e2401001     	sub	r1, r0, #1
   98f20: e0000190     	mul	r0, r0, r1
   98f24: e2821001     	add	r1, r2, #1
   98f28: e3100001     	tst	r0, #1
   98f2c: 0affffeb     	beq	0x98ee0 <.text+0x88de0> @ imm = #-0x54
   98f30: e59c0000     	ldr	r0, [r12]
   98f34: e3500009     	cmp	r0, #9
   98f38: daffffe8     	ble	0x98ee0 <.text+0x88de0> @ imm = #-0x60
   98f3c: e7d30002     	ldrb	r0, [r3, r2]
   98f40: e2200006     	eor	r0, r0, #6
   98f44: e7c30002     	strb	r0, [r3, r2]
   98f48: eaffffef     	b	0x98f0c <.text+0x88e0c> @ imm = #-0x44
   98f4c: e59e0000     	ldr	r0, [lr]
   98f50: e2401001     	sub	r1, r0, #1
   98f54: e0000190     	mul	r0, r0, r1
   98f58: e3100001     	tst	r0, #1
   98f5c: e59e0000     	ldr	r0, [lr]
   98f60: e2401001     	sub	r1, r0, #1
   98f64: e0000190     	mul	r0, r0, r1
   98f68: e3100001     	tst	r0, #1
   98f6c: 0a000002     	beq	0x98f7c <.text+0x88e7c> @ imm = #0x8
   98f70: e59c0000     	ldr	r0, [r12]
   98f74: e3500009     	cmp	r0, #9
   98f78: cafffff7     	bgt	0x98f5c <.text+0x88e5c> @ imm = #-0x24
   98f7c: e3a02000     	mov	r2, #0
   98f80: e3520000     	cmp	r2, #0
   98f84: 1a00001d     	bne	0x99000 <.text+0x88f00> @ imm = #0x74
   98f88: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x99f6c <.text+0x89e6c>
   98f8c: e08f3003     	add	r3, pc, r3
   98f90: ea000002     	b	0x98fa0 <.text+0x88ea0> @ imm = #0x8
   98f94: e3510009     	cmp	r1, #9
   98f98: e1a02001     	mov	r2, r1
   98f9c: 0a000017     	beq	0x99000 <.text+0x88f00> @ imm = #0x5c
   98fa0: e59e0000     	ldr	r0, [lr]
   98fa4: e2401001     	sub	r1, r0, #1
   98fa8: e0000190     	mul	r0, r0, r1
   98fac: e3100001     	tst	r0, #1
   98fb0: 0a000002     	beq	0x98fc0 <.text+0x88ec0> @ imm = #0x8
   98fb4: e59c0000     	ldr	r0, [r12]
   98fb8: e3500009     	cmp	r0, #9
   98fbc: ca00000b     	bgt	0x98ff0 <.text+0x88ef0> @ imm = #0x2c
   98fc0: e7d30002     	ldrb	r0, [r3, r2]
   98fc4: e2200066     	eor	r0, r0, #102
   98fc8: e7c30002     	strb	r0, [r3, r2]
   98fcc: e59e0000     	ldr	r0, [lr]
   98fd0: e2401001     	sub	r1, r0, #1
   98fd4: e0000190     	mul	r0, r0, r1
   98fd8: e2821001     	add	r1, r2, #1
   98fdc: e3100001     	tst	r0, #1
   98fe0: 0affffeb     	beq	0x98f94 <.text+0x88e94> @ imm = #-0x54
   98fe4: e59c0000     	ldr	r0, [r12]
   98fe8: e3500009     	cmp	r0, #9
   98fec: daffffe8     	ble	0x98f94 <.text+0x88e94> @ imm = #-0x60
   98ff0: e7d30002     	ldrb	r0, [r3, r2]
   98ff4: e2200066     	eor	r0, r0, #102
   98ff8: e7c30002     	strb	r0, [r3, r2]
   98ffc: eaffffef     	b	0x98fc0 <.text+0x88ec0> @ imm = #-0x44
   99000: e3a02000     	mov	r2, #0
   99004: e3520000     	cmp	r2, #0
   99008: 1a00001d     	bne	0x99084 <.text+0x88f84> @ imm = #0x74
   9900c: e59f3ff8     	ldr	r3, [pc, #0xff8]        @ 0x9a00c <.text+0x89f0c>
   99010: e08f3003     	add	r3, pc, r3
   99014: ea000002     	b	0x99024 <.text+0x88f24> @ imm = #0x8
   99018: e351001b     	cmp	r1, #27
   9901c: e1a02001     	mov	r2, r1
   99020: 0a000017     	beq	0x99084 <.text+0x88f84> @ imm = #0x5c
   99024: e59e0000     	ldr	r0, [lr]
   99028: e2401001     	sub	r1, r0, #1
   9902c: e0000190     	mul	r0, r0, r1
   99030: e3100001     	tst	r0, #1
   99034: 0a000002     	beq	0x99044 <.text+0x88f44> @ imm = #0x8
   99038: e59c0000     	ldr	r0, [r12]
   9903c: e3500009     	cmp	r0, #9
   99040: ca00000b     	bgt	0x99074 <.text+0x88f74> @ imm = #0x2c
   99044: e7d30002     	ldrb	r0, [r3, r2]
   99048: e2200084     	eor	r0, r0, #132
   9904c: e7c30002     	strb	r0, [r3, r2]
   99050: e59e0000     	ldr	r0, [lr]
   99054: e2401001     	sub	r1, r0, #1
   99058: e0000190     	mul	r0, r0, r1
   9905c: e2821001     	add	r1, r2, #1
   99060: e3100001     	tst	r0, #1
   99064: 0affffeb     	beq	0x99018 <.text+0x88f18> @ imm = #-0x54
   99068: e59c0000     	ldr	r0, [r12]
   9906c: e3500009     	cmp	r0, #9
   99070: daffffe8     	ble	0x99018 <.text+0x88f18> @ imm = #-0x60
   99074: e7d30002     	ldrb	r0, [r3, r2]
   99078: e2200084     	eor	r0, r0, #132
   9907c: e7c30002     	strb	r0, [r3, r2]
   99080: eaffffef     	b	0x99044 <.text+0x88f44> @ imm = #-0x44
   99084: e59e0000     	ldr	r0, [lr]
   99088: e2401001     	sub	r1, r0, #1
   9908c: e0000190     	mul	r0, r0, r1
   99090: e3100001     	tst	r0, #1
   99094: e59e0000     	ldr	r0, [lr]
   99098: e2401001     	sub	r1, r0, #1
   9909c: e0000190     	mul	r0, r0, r1
   990a0: e3100001     	tst	r0, #1
   990a4: 0a000002     	beq	0x990b4 <.text+0x88fb4> @ imm = #0x8
   990a8: e59c0000     	ldr	r0, [r12]
   990ac: e3500009     	cmp	r0, #9
   990b0: cafffff7     	bgt	0x99094 <.text+0x88f94> @ imm = #-0x24
   990b4: e3a02000     	mov	r2, #0
   990b8: e3520000     	cmp	r2, #0
   990bc: 1a00001d     	bne	0x99138 <.text+0x89038> @ imm = #0x74
   990c0: e59f3fb4     	ldr	r3, [pc, #0xfb4]        @ 0x9a07c <.text+0x89f7c>
   990c4: e08f3003     	add	r3, pc, r3
   990c8: ea000002     	b	0x990d8 <.text+0x88fd8> @ imm = #0x8
   990cc: e3510023     	cmp	r1, #35
   990d0: e1a02001     	mov	r2, r1
   990d4: 0a000017     	beq	0x99138 <.text+0x89038> @ imm = #0x5c
   990d8: e59e0000     	ldr	r0, [lr]
   990dc: e2401001     	sub	r1, r0, #1
   990e0: e0000190     	mul	r0, r0, r1
   990e4: e3100001     	tst	r0, #1
   990e8: 0a000002     	beq	0x990f8 <.text+0x88ff8> @ imm = #0x8
   990ec: e59c0000     	ldr	r0, [r12]
   990f0: e3500009     	cmp	r0, #9
   990f4: ca00000b     	bgt	0x99128 <.text+0x89028> @ imm = #0x2c
   990f8: e7d30002     	ldrb	r0, [r3, r2]
   990fc: e2200066     	eor	r0, r0, #102
   99100: e7c30002     	strb	r0, [r3, r2]
   99104: e59e0000     	ldr	r0, [lr]
   99108: e2401001     	sub	r1, r0, #1
   9910c: e0000190     	mul	r0, r0, r1
   99110: e2821001     	add	r1, r2, #1
   99114: e3100001     	tst	r0, #1
   99118: 0affffeb     	beq	0x990cc <.text+0x88fcc> @ imm = #-0x54
   9911c: e59c0000     	ldr	r0, [r12]
   99120: e3500009     	cmp	r0, #9
   99124: daffffe8     	ble	0x990cc <.text+0x88fcc> @ imm = #-0x60
   99128: e7d30002     	ldrb	r0, [r3, r2]
   9912c: e2200066     	eor	r0, r0, #102
   99130: e7c30002     	strb	r0, [r3, r2]
   99134: eaffffef     	b	0x990f8 <.text+0x88ff8> @ imm = #-0x44
   99138: e3a02000     	mov	r2, #0
   9913c: e3520000     	cmp	r2, #0
   99140: 1a00001d     	bne	0x991bc <.text+0x890bc> @ imm = #0x74
   99144: e59f3f34     	ldr	r3, [pc, #0xf34]        @ 0x9a080 <.text+0x89f80>
   99148: e08f3003     	add	r3, pc, r3
   9914c: ea000002     	b	0x9915c <.text+0x8905c> @ imm = #0x8
   99150: e3510006     	cmp	r1, #6
   99154: e1a02001     	mov	r2, r1
   99158: 0a000017     	beq	0x991bc <.text+0x890bc> @ imm = #0x5c
   9915c: e59e0000     	ldr	r0, [lr]
   99160: e2401001     	sub	r1, r0, #1
   99164: e0000190     	mul	r0, r0, r1
   99168: e3100001     	tst	r0, #1
   9916c: 0a000002     	beq	0x9917c <.text+0x8907c> @ imm = #0x8
   99170: e59c0000     	ldr	r0, [r12]
   99174: e3500009     	cmp	r0, #9
   99178: ca00000b     	bgt	0x991ac <.text+0x890ac> @ imm = #0x2c
   9917c: e7d30002     	ldrb	r0, [r3, r2]
   99180: e2200052     	eor	r0, r0, #82
   99184: e7c30002     	strb	r0, [r3, r2]
   99188: e59e0000     	ldr	r0, [lr]
   9918c: e2401001     	sub	r1, r0, #1
   99190: e0000190     	mul	r0, r0, r1
   99194: e2821001     	add	r1, r2, #1
   99198: e3100001     	tst	r0, #1
   9919c: 0affffeb     	beq	0x99150 <.text+0x89050> @ imm = #-0x54
   991a0: e59c0000     	ldr	r0, [r12]
   991a4: e3500009     	cmp	r0, #9
   991a8: daffffe8     	ble	0x99150 <.text+0x89050> @ imm = #-0x60
   991ac: e7d30002     	ldrb	r0, [r3, r2]
   991b0: e2200052     	eor	r0, r0, #82
   991b4: e7c30002     	strb	r0, [r3, r2]
   991b8: eaffffef     	b	0x9917c <.text+0x8907c> @ imm = #-0x44
   991bc: e3a02000     	mov	r2, #0
   991c0: e3520000     	cmp	r2, #0
   991c4: 1a000007     	bne	0x991e8 <.text+0x890e8> @ imm = #0x1c
   991c8: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0x9a1b0 <.text+0x8a0b0>
   991cc: e08f3003     	add	r3, pc, r3
   991d0: e7d30002     	ldrb	r0, [r3, r2]
   991d4: e2200062     	eor	r0, r0, #98
   991d8: e7c30002     	strb	r0, [r3, r2]
   991dc: e2822001     	add	r2, r2, #1
   991e0: e352001a     	cmp	r2, #26
   991e4: 1afffff9     	bne	0x991d0 <.text+0x890d0> @ imm = #-0x1c
   991e8: e59e0000     	ldr	r0, [lr]
   991ec: e2401001     	sub	r1, r0, #1
   991f0: e0000190     	mul	r0, r0, r1
   991f4: e3100001     	tst	r0, #1
   991f8: e59e0000     	ldr	r0, [lr]
   991fc: e2401001     	sub	r1, r0, #1
   99200: e0000190     	mul	r0, r0, r1
   99204: e3100001     	tst	r0, #1
   99208: 0a000002     	beq	0x99218 <.text+0x89118> @ imm = #0x8
   9920c: e59c0000     	ldr	r0, [r12]
   99210: e3500009     	cmp	r0, #9
   99214: cafffff7     	bgt	0x991f8 <.text+0x890f8> @ imm = #-0x24
   99218: e3a02000     	mov	r2, #0
   9921c: e3520000     	cmp	r2, #0
   99220: 1a000007     	bne	0x99244 <.text+0x89144> @ imm = #0x1c
   99224: e59f3ff4     	ldr	r3, [pc, #0xff4]        @ 0x9a220 <.text+0x8a120>
   99228: e08f3003     	add	r3, pc, r3
   9922c: e7d30002     	ldrb	r0, [r3, r2]
   99230: e22000ef     	eor	r0, r0, #239
   99234: e7c30002     	strb	r0, [r3, r2]
   99238: e2822001     	add	r2, r2, #1
   9923c: e3520008     	cmp	r2, #8
   99240: 1afffff9     	bne	0x9922c <.text+0x8912c> @ imm = #-0x1c
   99244: e59e0000     	ldr	r0, [lr]
   99248: e2401001     	sub	r1, r0, #1
   9924c: e0000190     	mul	r0, r0, r1
   99250: e3100001     	tst	r0, #1
   99254: e59e0000     	ldr	r0, [lr]
   99258: e2401001     	sub	r1, r0, #1
   9925c: e0000190     	mul	r0, r0, r1
   99260: e3100001     	tst	r0, #1
   99264: 0a000002     	beq	0x99274 <.text+0x89174> @ imm = #0x8
   99268: e59c0000     	ldr	r0, [r12]
   9926c: e3500009     	cmp	r0, #9
   99270: cafffff7     	bgt	0x99254 <.text+0x89154> @ imm = #-0x24
   99274: e3a02000     	mov	r2, #0
   99278: e3520000     	cmp	r2, #0
   9927c: 1a000007     	bne	0x992a0 <.text+0x891a0> @ imm = #0x1c
   99280: e59f3fb4     	ldr	r3, [pc, #0xfb4]        @ 0x9a23c <.text+0x8a13c>
   99284: e08f3003     	add	r3, pc, r3
   99288: e7d30002     	ldrb	r0, [r3, r2]
   9928c: e22000cb     	eor	r0, r0, #203
   99290: e7c30002     	strb	r0, [r3, r2]
   99294: e2822001     	add	r2, r2, #1
   99298: e3520005     	cmp	r2, #5
   9929c: 1afffff9     	bne	0x99288 <.text+0x89188> @ imm = #-0x1c
   992a0: e3a02000     	mov	r2, #0
   992a4: e3520000     	cmp	r2, #0
   992a8: 1a00001d     	bne	0x99324 <.text+0x89224> @ imm = #0x74
   992ac: e59f3ff8     	ldr	r3, [pc, #0xff8]        @ 0x9a2ac <.text+0x8a1ac>
   992b0: e08f3003     	add	r3, pc, r3
   992b4: ea000002     	b	0x992c4 <.text+0x891c4> @ imm = #0x8
   992b8: e3510007     	cmp	r1, #7
   992bc: e1a02001     	mov	r2, r1
   992c0: 0a000017     	beq	0x99324 <.text+0x89224> @ imm = #0x5c
   992c4: e59e0000     	ldr	r0, [lr]
   992c8: e2401001     	sub	r1, r0, #1
   992cc: e0000190     	mul	r0, r0, r1
   992d0: e3100001     	tst	r0, #1
   992d4: 0a000002     	beq	0x992e4 <.text+0x891e4> @ imm = #0x8
   992d8: e59c0000     	ldr	r0, [r12]
   992dc: e3500009     	cmp	r0, #9
   992e0: ca00000b     	bgt	0x99314 <.text+0x89214> @ imm = #0x2c
   992e4: e7d30002     	ldrb	r0, [r3, r2]
   992e8: e220003d     	eor	r0, r0, #61
   992ec: e7c30002     	strb	r0, [r3, r2]
   992f0: e59e0000     	ldr	r0, [lr]
   992f4: e2401001     	sub	r1, r0, #1
   992f8: e0000190     	mul	r0, r0, r1
   992fc: e2821001     	add	r1, r2, #1
   99300: e3100001     	tst	r0, #1
   99304: 0affffeb     	beq	0x992b8 <.text+0x891b8> @ imm = #-0x54
   99308: e59c0000     	ldr	r0, [r12]
   9930c: e3500009     	cmp	r0, #9
   99310: daffffe8     	ble	0x992b8 <.text+0x891b8> @ imm = #-0x60
   99314: e7d30002     	ldrb	r0, [r3, r2]
   99318: e220003d     	eor	r0, r0, #61
   9931c: e7c30002     	strb	r0, [r3, r2]
   99320: eaffffef     	b	0x992e4 <.text+0x891e4> @ imm = #-0x44
   99324: e3a02000     	mov	r2, #0
   99328: e3520000     	cmp	r2, #0
   9932c: 1a00001d     	bne	0x993a8 <.text+0x892a8> @ imm = #0x74
   99330: e59f3fbc     	ldr	r3, [pc, #0xfbc]        @ 0x9a2f4 <.text+0x8a1f4>
   99334: e08f3003     	add	r3, pc, r3
   99338: ea000002     	b	0x99348 <.text+0x89248> @ imm = #0x8
   9933c: e351000b     	cmp	r1, #11
   99340: e1a02001     	mov	r2, r1
   99344: 0a000017     	beq	0x993a8 <.text+0x892a8> @ imm = #0x5c
   99348: e59e0000     	ldr	r0, [lr]
   9934c: e2401001     	sub	r1, r0, #1
   99350: e0000190     	mul	r0, r0, r1
   99354: e3100001     	tst	r0, #1
   99358: 0a000002     	beq	0x99368 <.text+0x89268> @ imm = #0x8
   9935c: e59c0000     	ldr	r0, [r12]
   99360: e3500009     	cmp	r0, #9
   99364: ca00000b     	bgt	0x99398 <.text+0x89298> @ imm = #0x2c
   99368: e7d30002     	ldrb	r0, [r3, r2]
   9936c: e220008e     	eor	r0, r0, #142
   99370: e7c30002     	strb	r0, [r3, r2]
   99374: e59e0000     	ldr	r0, [lr]
   99378: e2401001     	sub	r1, r0, #1
   9937c: e0000190     	mul	r0, r0, r1
   99380: e2821001     	add	r1, r2, #1
   99384: e3100001     	tst	r0, #1
   99388: 0affffeb     	beq	0x9933c <.text+0x8923c> @ imm = #-0x54
   9938c: e59c0000     	ldr	r0, [r12]
   99390: e3500009     	cmp	r0, #9
   99394: daffffe8     	ble	0x9933c <.text+0x8923c> @ imm = #-0x60
   99398: e7d30002     	ldrb	r0, [r3, r2]
   9939c: e220008e     	eor	r0, r0, #142
   993a0: e7c30002     	strb	r0, [r3, r2]
   993a4: eaffffef     	b	0x99368 <.text+0x89268> @ imm = #-0x44
   993a8: e3a02000     	mov	r2, #0
   993ac: e3520000     	cmp	r2, #0
   993b0: 1a000007     	bne	0x993d4 <.text+0x892d4> @ imm = #0x1c
   993b4: e59f3fa8     	ldr	r3, [pc, #0xfa8]        @ 0x9a364 <.text+0x8a264>
   993b8: e08f3003     	add	r3, pc, r3
   993bc: e7d30002     	ldrb	r0, [r3, r2]
   993c0: e2200013     	eor	r0, r0, #19
   993c4: e7c30002     	strb	r0, [r3, r2]
   993c8: e2822001     	add	r2, r2, #1
   993cc: e352000a     	cmp	r2, #10
   993d0: 1afffff9     	bne	0x993bc <.text+0x892bc> @ imm = #-0x1c
   993d4: e59e0000     	ldr	r0, [lr]
   993d8: e2401001     	sub	r1, r0, #1
   993dc: e0000190     	mul	r0, r0, r1
   993e0: e3100001     	tst	r0, #1
   993e4: e59e0000     	ldr	r0, [lr]
   993e8: e2401001     	sub	r1, r0, #1
   993ec: e0000190     	mul	r0, r0, r1
   993f0: e3100001     	tst	r0, #1
   993f4: 0a000002     	beq	0x99404 <.text+0x89304> @ imm = #0x8
   993f8: e59c0000     	ldr	r0, [r12]
   993fc: e3500009     	cmp	r0, #9
   99400: cafffff7     	bgt	0x993e4 <.text+0x892e4> @ imm = #-0x24
   99404: e3a02000     	mov	r2, #0
   99408: e3520000     	cmp	r2, #0
   9940c: 1a00001d     	bne	0x99488 <.text+0x89388> @ imm = #0x74
   99410: e59f3f50     	ldr	r3, [pc, #0xf50]        @ 0x9a368 <.text+0x8a268>
   99414: e08f3003     	add	r3, pc, r3
   99418: ea000002     	b	0x99428 <.text+0x89328> @ imm = #0x8
   9941c: e351002a     	cmp	r1, #42
   99420: e1a02001     	mov	r2, r1
   99424: 0a000017     	beq	0x99488 <.text+0x89388> @ imm = #0x5c
   99428: e59e0000     	ldr	r0, [lr]
   9942c: e2401001     	sub	r1, r0, #1
   99430: e0000190     	mul	r0, r0, r1
   99434: e3100001     	tst	r0, #1
   99438: 0a000002     	beq	0x99448 <.text+0x89348> @ imm = #0x8
   9943c: e59c0000     	ldr	r0, [r12]
   99440: e3500009     	cmp	r0, #9
   99444: ca00000b     	bgt	0x99478 <.text+0x89378> @ imm = #0x2c
   99448: e7d30002     	ldrb	r0, [r3, r2]
   9944c: e22000e8     	eor	r0, r0, #232
   99450: e7c30002     	strb	r0, [r3, r2]
   99454: e59e0000     	ldr	r0, [lr]
   99458: e2401001     	sub	r1, r0, #1
   9945c: e0000190     	mul	r0, r0, r1
   99460: e2821001     	add	r1, r2, #1
   99464: e3100001     	tst	r0, #1
   99468: 0affffeb     	beq	0x9941c <.text+0x8931c> @ imm = #-0x54
   9946c: e59c0000     	ldr	r0, [r12]
   99470: e3500009     	cmp	r0, #9
   99474: daffffe8     	ble	0x9941c <.text+0x8931c> @ imm = #-0x60
   99478: e7d30002     	ldrb	r0, [r3, r2]
   9947c: e22000e8     	eor	r0, r0, #232
   99480: e7c30002     	strb	r0, [r3, r2]
   99484: eaffffef     	b	0x99448 <.text+0x89348> @ imm = #-0x44
   99488: e3a02000     	mov	r2, #0
   9948c: e3520000     	cmp	r2, #0
   99490: 1a00001d     	bne	0x9950c <.text+0x8940c> @ imm = #0x74
   99494: e59f3ed0     	ldr	r3, [pc, #0xed0]        @ 0x9a36c <.text+0x8a26c>
   99498: e08f3003     	add	r3, pc, r3
   9949c: ea000002     	b	0x994ac <.text+0x893ac> @ imm = #0x8
   994a0: e351001d     	cmp	r1, #29
   994a4: e1a02001     	mov	r2, r1
   994a8: 0a000017     	beq	0x9950c <.text+0x8940c> @ imm = #0x5c
   994ac: e59e0000     	ldr	r0, [lr]
   994b0: e2401001     	sub	r1, r0, #1
   994b4: e0000190     	mul	r0, r0, r1
   994b8: e3100001     	tst	r0, #1
   994bc: 0a000002     	beq	0x994cc <.text+0x893cc> @ imm = #0x8
   994c0: e59c0000     	ldr	r0, [r12]
   994c4: e3500009     	cmp	r0, #9
   994c8: ca00000b     	bgt	0x994fc <.text+0x893fc> @ imm = #0x2c
   994cc: e7d30002     	ldrb	r0, [r3, r2]
   994d0: e2200054     	eor	r0, r0, #84
   994d4: e7c30002     	strb	r0, [r3, r2]
   994d8: e59e0000     	ldr	r0, [lr]
   994dc: e2401001     	sub	r1, r0, #1
   994e0: e0000190     	mul	r0, r0, r1
   994e4: e2821001     	add	r1, r2, #1
   994e8: e3100001     	tst	r0, #1
   994ec: 0affffeb     	beq	0x994a0 <.text+0x893a0> @ imm = #-0x54
   994f0: e59c0000     	ldr	r0, [r12]
   994f4: e3500009     	cmp	r0, #9
   994f8: daffffe8     	ble	0x994a0 <.text+0x893a0> @ imm = #-0x60
   994fc: e7d30002     	ldrb	r0, [r3, r2]
   99500: e2200054     	eor	r0, r0, #84
   99504: e7c30002     	strb	r0, [r3, r2]
   99508: eaffffef     	b	0x994cc <.text+0x893cc> @ imm = #-0x44
   9950c: e59e0000     	ldr	r0, [lr]
   99510: e2401001     	sub	r1, r0, #1
   99514: e0000190     	mul	r0, r0, r1
   99518: e3100001     	tst	r0, #1
   9951c: e59e0000     	ldr	r0, [lr]
   99520: e2401001     	sub	r1, r0, #1
   99524: e0000190     	mul	r0, r0, r1
   99528: e3100001     	tst	r0, #1
   9952c: 0a000002     	beq	0x9953c <.text+0x8943c> @ imm = #0x8
   99530: e59c0000     	ldr	r0, [r12]
   99534: e3500009     	cmp	r0, #9
   99538: cafffff7     	bgt	0x9951c <.text+0x8941c> @ imm = #-0x24
   9953c: e3a02000     	mov	r2, #0
   99540: e3520000     	cmp	r2, #0
   99544: 1a00001d     	bne	0x995c0 <.text+0x894c0> @ imm = #0x74
   99548: e59f3fe4     	ldr	r3, [pc, #0xfe4]        @ 0x9a534 <.text+0x8a434>
   9954c: e08f3003     	add	r3, pc, r3
   99550: ea000002     	b	0x99560 <.text+0x89460> @ imm = #0x8
   99554: e3510007     	cmp	r1, #7
   99558: e1a02001     	mov	r2, r1
   9955c: 0a000017     	beq	0x995c0 <.text+0x894c0> @ imm = #0x5c
   99560: e59e0000     	ldr	r0, [lr]
   99564: e2401001     	sub	r1, r0, #1
   99568: e0000190     	mul	r0, r0, r1
   9956c: e3100001     	tst	r0, #1
   99570: 0a000002     	beq	0x99580 <.text+0x89480> @ imm = #0x8
   99574: e59c0000     	ldr	r0, [r12]
   99578: e3500009     	cmp	r0, #9
   9957c: ca00000b     	bgt	0x995b0 <.text+0x894b0> @ imm = #0x2c
   99580: e7d30002     	ldrb	r0, [r3, r2]
   99584: e2200094     	eor	r0, r0, #148
   99588: e7c30002     	strb	r0, [r3, r2]
   9958c: e59e0000     	ldr	r0, [lr]
   99590: e2401001     	sub	r1, r0, #1
   99594: e0000190     	mul	r0, r0, r1
   99598: e2821001     	add	r1, r2, #1
   9959c: e3100001     	tst	r0, #1
   995a0: 0affffeb     	beq	0x99554 <.text+0x89454> @ imm = #-0x54
   995a4: e59c0000     	ldr	r0, [r12]
   995a8: e3500009     	cmp	r0, #9
   995ac: daffffe8     	ble	0x99554 <.text+0x89454> @ imm = #-0x60
   995b0: e7d30002     	ldrb	r0, [r3, r2]
   995b4: e2200094     	eor	r0, r0, #148
   995b8: e7c30002     	strb	r0, [r3, r2]
   995bc: eaffffef     	b	0x99580 <.text+0x89480> @ imm = #-0x44
   995c0: e3a02000     	mov	r2, #0
   995c4: e3520000     	cmp	r2, #0
   995c8: 1a00001d     	bne	0x99644 <.text+0x89544> @ imm = #0x74
   995cc: e59f3fd0     	ldr	r3, [pc, #0xfd0]        @ 0x9a5a4 <.text+0x8a4a4>
   995d0: e08f3003     	add	r3, pc, r3
   995d4: ea000002     	b	0x995e4 <.text+0x894e4> @ imm = #0x8
   995d8: e3510022     	cmp	r1, #34
   995dc: e1a02001     	mov	r2, r1
   995e0: 0a000017     	beq	0x99644 <.text+0x89544> @ imm = #0x5c
   995e4: e59e0000     	ldr	r0, [lr]
   995e8: e2401001     	sub	r1, r0, #1
   995ec: e0000190     	mul	r0, r0, r1
   995f0: e3100001     	tst	r0, #1
   995f4: 0a000002     	beq	0x99604 <.text+0x89504> @ imm = #0x8
   995f8: e59c0000     	ldr	r0, [r12]
   995fc: e3500009     	cmp	r0, #9
   99600: ca00000b     	bgt	0x99634 <.text+0x89534> @ imm = #0x2c
   99604: e7d30002     	ldrb	r0, [r3, r2]
   99608: e2200065     	eor	r0, r0, #101
   9960c: e7c30002     	strb	r0, [r3, r2]
   99610: e59e0000     	ldr	r0, [lr]
   99614: e2401001     	sub	r1, r0, #1
   99618: e0000190     	mul	r0, r0, r1
   9961c: e2821001     	add	r1, r2, #1
   99620: e3100001     	tst	r0, #1
   99624: 0affffeb     	beq	0x995d8 <.text+0x894d8> @ imm = #-0x54
   99628: e59c0000     	ldr	r0, [r12]
   9962c: e3500009     	cmp	r0, #9
   99630: daffffe8     	ble	0x995d8 <.text+0x894d8> @ imm = #-0x60
   99634: e7d30002     	ldrb	r0, [r3, r2]
   99638: e2200065     	eor	r0, r0, #101
   9963c: e7c30002     	strb	r0, [r3, r2]
   99640: eaffffef     	b	0x99604 <.text+0x89504> @ imm = #-0x44
   99644: e3a02000     	mov	r2, #0
   99648: e3520000     	cmp	r2, #0
   9964c: 1a000007     	bne	0x99670 <.text+0x89570> @ imm = #0x1c
   99650: e59f3f50     	ldr	r3, [pc, #0xf50]        @ 0x9a5a8 <.text+0x8a4a8>
   99654: e08f3003     	add	r3, pc, r3
   99658: e7d30002     	ldrb	r0, [r3, r2]
   9965c: e2200064     	eor	r0, r0, #100
   99660: e7c30002     	strb	r0, [r3, r2]
   99664: e2822001     	add	r2, r2, #1
   99668: e3520028     	cmp	r2, #40
   9966c: 1afffff9     	bne	0x99658 <.text+0x89558> @ imm = #-0x1c
   99670: e3a02000     	mov	r2, #0
   99674: e3520000     	cmp	r2, #0
   99678: 1a00001d     	bne	0x996f4 <.text+0x895f4> @ imm = #0x74
   9967c: e59f3f28     	ldr	r3, [pc, #0xf28]        @ 0x9a5ac <.text+0x8a4ac>
   99680: e08f3003     	add	r3, pc, r3
   99684: ea000002     	b	0x99694 <.text+0x89594> @ imm = #0x8
   99688: e3510025     	cmp	r1, #37
   9968c: e1a02001     	mov	r2, r1
   99690: 0a000017     	beq	0x996f4 <.text+0x895f4> @ imm = #0x5c
   99694: e59e0000     	ldr	r0, [lr]
   99698: e2401001     	sub	r1, r0, #1
   9969c: e0000190     	mul	r0, r0, r1
   996a0: e3100001     	tst	r0, #1
   996a4: 0a000002     	beq	0x996b4 <.text+0x895b4> @ imm = #0x8
   996a8: e59c0000     	ldr	r0, [r12]
   996ac: e3500009     	cmp	r0, #9
   996b0: ca00000b     	bgt	0x996e4 <.text+0x895e4> @ imm = #0x2c
   996b4: e7d30002     	ldrb	r0, [r3, r2]
   996b8: e2200006     	eor	r0, r0, #6
   996bc: e7c30002     	strb	r0, [r3, r2]
   996c0: e59e0000     	ldr	r0, [lr]
   996c4: e2401001     	sub	r1, r0, #1
   996c8: e0000190     	mul	r0, r0, r1
   996cc: e2821001     	add	r1, r2, #1
   996d0: e3100001     	tst	r0, #1
   996d4: 0affffeb     	beq	0x99688 <.text+0x89588> @ imm = #-0x54
   996d8: e59c0000     	ldr	r0, [r12]
   996dc: e3500009     	cmp	r0, #9
   996e0: daffffe8     	ble	0x99688 <.text+0x89588> @ imm = #-0x60
   996e4: e7d30002     	ldrb	r0, [r3, r2]
   996e8: e2200006     	eor	r0, r0, #6
   996ec: e7c30002     	strb	r0, [r3, r2]
   996f0: eaffffef     	b	0x996b4 <.text+0x895b4> @ imm = #-0x44
   996f4: e59e0000     	ldr	r0, [lr]
   996f8: e2401001     	sub	r1, r0, #1
   996fc: e0000190     	mul	r0, r0, r1
   99700: e3100001     	tst	r0, #1
   99704: e59e0000     	ldr	r0, [lr]
   99708: e2401001     	sub	r1, r0, #1
   9970c: e0000190     	mul	r0, r0, r1
   99710: e3100001     	tst	r0, #1
   99714: 0a000002     	beq	0x99724 <.text+0x89624> @ imm = #0x8
   99718: e59c0000     	ldr	r0, [r12]
   9971c: e3500009     	cmp	r0, #9
   99720: cafffff7     	bgt	0x99704 <.text+0x89604> @ imm = #-0x24
   99724: e3a02000     	mov	r2, #0
   99728: e3520000     	cmp	r2, #0
   9972c: 1a000007     	bne	0x99750 <.text+0x89650> @ imm = #0x1c
   99730: e59f3fc0     	ldr	r3, [pc, #0xfc0]        @ 0x9a6f8 <.text+0x8a5f8>
   99734: e08f3003     	add	r3, pc, r3
   99738: e7d30002     	ldrb	r0, [r3, r2]
   9973c: e2200019     	eor	r0, r0, #25
   99740: e7c30002     	strb	r0, [r3, r2]
   99744: e2822001     	add	r2, r2, #1
   99748: e3520017     	cmp	r2, #23
   9974c: 1afffff9     	bne	0x99738 <.text+0x89638> @ imm = #-0x1c
   99750: e3a02000     	mov	r2, #0
   99754: e3520000     	cmp	r2, #0
   99758: 1a00001d     	bne	0x997d4 <.text+0x896d4> @ imm = #0x74
   9975c: e59f3f98     	ldr	r3, [pc, #0xf98]        @ 0x9a6fc <.text+0x8a5fc>
   99760: e08f3003     	add	r3, pc, r3
   99764: ea000002     	b	0x99774 <.text+0x89674> @ imm = #0x8
   99768: e351001e     	cmp	r1, #30
   9976c: e1a02001     	mov	r2, r1
   99770: 0a000017     	beq	0x997d4 <.text+0x896d4> @ imm = #0x5c
   99774: e59e0000     	ldr	r0, [lr]
   99778: e2401001     	sub	r1, r0, #1
   9977c: e0000190     	mul	r0, r0, r1
   99780: e3100001     	tst	r0, #1
   99784: 0a000002     	beq	0x99794 <.text+0x89694> @ imm = #0x8
   99788: e59c0000     	ldr	r0, [r12]
   9978c: e3500009     	cmp	r0, #9
   99790: ca00000b     	bgt	0x997c4 <.text+0x896c4> @ imm = #0x2c
   99794: e7d30002     	ldrb	r0, [r3, r2]
   99798: e2200061     	eor	r0, r0, #97
   9979c: e7c30002     	strb	r0, [r3, r2]
   997a0: e59e0000     	ldr	r0, [lr]
   997a4: e2401001     	sub	r1, r0, #1
   997a8: e0000190     	mul	r0, r0, r1
   997ac: e2821001     	add	r1, r2, #1
   997b0: e3100001     	tst	r0, #1
   997b4: 0affffeb     	beq	0x99768 <.text+0x89668> @ imm = #-0x54
   997b8: e59c0000     	ldr	r0, [r12]
   997bc: e3500009     	cmp	r0, #9
   997c0: daffffe8     	ble	0x99768 <.text+0x89668> @ imm = #-0x60
   997c4: e7d30002     	ldrb	r0, [r3, r2]
   997c8: e2200061     	eor	r0, r0, #97
   997cc: e7c30002     	strb	r0, [r3, r2]
   997d0: eaffffef     	b	0x99794 <.text+0x89694> @ imm = #-0x44
   997d4: e59e0000     	ldr	r0, [lr]
   997d8: e2401001     	sub	r1, r0, #1
   997dc: e0000190     	mul	r0, r0, r1
   997e0: e3100001     	tst	r0, #1
   997e4: e59e0000     	ldr	r0, [lr]
   997e8: e2401001     	sub	r1, r0, #1
   997ec: e0000190     	mul	r0, r0, r1
   997f0: e3100001     	tst	r0, #1
   997f4: 0a000002     	beq	0x99804 <.text+0x89704> @ imm = #0x8
   997f8: e59c0000     	ldr	r0, [r12]
   997fc: e3500009     	cmp	r0, #9
   99800: cafffff7     	bgt	0x997e4 <.text+0x896e4> @ imm = #-0x24
   99804: e3a02000     	mov	r2, #0
   99808: e3520000     	cmp	r2, #0
   9980c: 1a000007     	bne	0x99830 <.text+0x89730> @ imm = #0x1c
   99810: e59f3fc4     	ldr	r3, [pc, #0xfc4]        @ 0x9a7dc <.text+0x8a6dc>
   99814: e08f3003     	add	r3, pc, r3
   99818: e7d30002     	ldrb	r0, [r3, r2]
   9981c: e22000aa     	eor	r0, r0, #170
   99820: e7c30002     	strb	r0, [r3, r2]
   99824: e2822001     	add	r2, r2, #1
   99828: e3520018     	cmp	r2, #24
   9982c: 1afffff9     	bne	0x99818 <.text+0x89718> @ imm = #-0x1c
   99830: e3a02000     	mov	r2, #0
   99834: e3520000     	cmp	r2, #0
   99838: 1a000007     	bne	0x9985c <.text+0x8975c> @ imm = #0x1c
   9983c: e59f3f9c     	ldr	r3, [pc, #0xf9c]        @ 0x9a7e0 <.text+0x8a6e0>
   99840: e08f3003     	add	r3, pc, r3
   99844: e7d30002     	ldrb	r0, [r3, r2]
   99848: e220009b     	eor	r0, r0, #155
   9984c: e7c30002     	strb	r0, [r3, r2]
   99850: e2822001     	add	r2, r2, #1
   99854: e3520014     	cmp	r2, #20
   99858: 1afffff9     	bne	0x99844 <.text+0x89744> @ imm = #-0x1c
   9985c: e3a02000     	mov	r2, #0
   99860: e3520000     	cmp	r2, #0
   99864: 1a00001d     	bne	0x998e0 <.text+0x897e0> @ imm = #0x74
   99868: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0x9a850 <.text+0x8a750>
   9986c: e08f3003     	add	r3, pc, r3
   99870: ea000002     	b	0x99880 <.text+0x89780> @ imm = #0x8
   99874: e3510030     	cmp	r1, #48
   99878: e1a02001     	mov	r2, r1
   9987c: 0a000017     	beq	0x998e0 <.text+0x897e0> @ imm = #0x5c
   99880: e59e0000     	ldr	r0, [lr]
   99884: e2401001     	sub	r1, r0, #1
   99888: e0000190     	mul	r0, r0, r1
   9988c: e3100001     	tst	r0, #1
   99890: 0a000002     	beq	0x998a0 <.text+0x897a0> @ imm = #0x8
   99894: e59c0000     	ldr	r0, [r12]
   99898: e3500009     	cmp	r0, #9
   9989c: ca00000b     	bgt	0x998d0 <.text+0x897d0> @ imm = #0x2c
   998a0: e7d30002     	ldrb	r0, [r3, r2]
   998a4: e220001d     	eor	r0, r0, #29
   998a8: e7c30002     	strb	r0, [r3, r2]
   998ac: e59e0000     	ldr	r0, [lr]
   998b0: e2401001     	sub	r1, r0, #1
   998b4: e0000190     	mul	r0, r0, r1
   998b8: e2821001     	add	r1, r2, #1
   998bc: e3100001     	tst	r0, #1
   998c0: 0affffeb     	beq	0x99874 <.text+0x89774> @ imm = #-0x54
   998c4: e59c0000     	ldr	r0, [r12]
   998c8: e3500009     	cmp	r0, #9
   998cc: daffffe8     	ble	0x99874 <.text+0x89774> @ imm = #-0x60
   998d0: e7d30002     	ldrb	r0, [r3, r2]
   998d4: e220001d     	eor	r0, r0, #29
   998d8: e7c30002     	strb	r0, [r3, r2]
   998dc: eaffffef     	b	0x998a0 <.text+0x897a0> @ imm = #-0x44
   998e0: e3a02000     	mov	r2, #0
   998e4: e3520000     	cmp	r2, #0
   998e8: 1a00001d     	bne	0x99964 <.text+0x89864> @ imm = #0x74
   998ec: e59f3fa8     	ldr	r3, [pc, #0xfa8]        @ 0x9a89c <.text+0x8a79c>
   998f0: e08f3003     	add	r3, pc, r3
   998f4: ea000002     	b	0x99904 <.text+0x89804> @ imm = #0x8
   998f8: e351001e     	cmp	r1, #30
   998fc: e1a02001     	mov	r2, r1
   99900: 0a000017     	beq	0x99964 <.text+0x89864> @ imm = #0x5c
   99904: e59e0000     	ldr	r0, [lr]
   99908: e2401001     	sub	r1, r0, #1
   9990c: e0000190     	mul	r0, r0, r1
   99910: e3100001     	tst	r0, #1
   99914: 0a000002     	beq	0x99924 <.text+0x89824> @ imm = #0x8
   99918: e59c0000     	ldr	r0, [r12]
   9991c: e3500009     	cmp	r0, #9
   99920: ca00000b     	bgt	0x99954 <.text+0x89854> @ imm = #0x2c
   99924: e7d30002     	ldrb	r0, [r3, r2]
   99928: e22000ca     	eor	r0, r0, #202
   9992c: e7c30002     	strb	r0, [r3, r2]
   99930: e59e0000     	ldr	r0, [lr]
   99934: e2401001     	sub	r1, r0, #1
   99938: e0000190     	mul	r0, r0, r1
   9993c: e2821001     	add	r1, r2, #1
   99940: e3100001     	tst	r0, #1
   99944: 0affffeb     	beq	0x998f8 <.text+0x897f8> @ imm = #-0x54
   99948: e59c0000     	ldr	r0, [r12]
   9994c: e3500009     	cmp	r0, #9
   99950: daffffe8     	ble	0x998f8 <.text+0x897f8> @ imm = #-0x60
   99954: e7d30002     	ldrb	r0, [r3, r2]
   99958: e22000ca     	eor	r0, r0, #202
   9995c: e7c30002     	strb	r0, [r3, r2]
   99960: eaffffef     	b	0x99924 <.text+0x89824> @ imm = #-0x44
   99964: e59e0000     	ldr	r0, [lr]
   99968: e2401001     	sub	r1, r0, #1
   9996c: e0000190     	mul	r0, r0, r1
   99970: e3100001     	tst	r0, #1
   99974: e59e0000     	ldr	r0, [lr]
   99978: e2401001     	sub	r1, r0, #1
   9997c: e0000190     	mul	r0, r0, r1
   99980: e3100001     	tst	r0, #1
   99984: 0a000002     	beq	0x99994 <.text+0x89894> @ imm = #0x8
   99988: e59c0000     	ldr	r0, [r12]
   9998c: e3500009     	cmp	r0, #9
   99990: cafffff7     	bgt	0x99974 <.text+0x89874> @ imm = #-0x24
   99994: e3a02000     	mov	r2, #0
   99998: e3520000     	cmp	r2, #0
   9999c: 1a000007     	bne	0x999c0 <.text+0x898c0> @ imm = #0x1c
   999a0: e59f3fd4     	ldr	r3, [pc, #0xfd4]        @ 0x9a97c <.text+0x8a87c>
   999a4: e08f3003     	add	r3, pc, r3
   999a8: e7d30002     	ldrb	r0, [r3, r2]
   999ac: e220003c     	eor	r0, r0, #60
   999b0: e7c30002     	strb	r0, [r3, r2]
   999b4: e2822001     	add	r2, r2, #1
   999b8: e352000c     	cmp	r2, #12
   999bc: 1afffff9     	bne	0x999a8 <.text+0x898a8> @ imm = #-0x1c
   999c0: e3a02000     	mov	r2, #0
   999c4: e3520000     	cmp	r2, #0
   999c8: 1a00001d     	bne	0x99a44 <.text+0x89944> @ imm = #0x74
   999cc: e59f3fac     	ldr	r3, [pc, #0xfac]        @ 0x9a980 <.text+0x8a880>
   999d0: e08f3003     	add	r3, pc, r3
   999d4: ea000002     	b	0x999e4 <.text+0x898e4> @ imm = #0x8
   999d8: e3510029     	cmp	r1, #41
   999dc: e1a02001     	mov	r2, r1
   999e0: 0a000017     	beq	0x99a44 <.text+0x89944> @ imm = #0x5c
   999e4: e59e0000     	ldr	r0, [lr]
   999e8: e2401001     	sub	r1, r0, #1
   999ec: e0000190     	mul	r0, r0, r1
   999f0: e3100001     	tst	r0, #1
   999f4: 0a000002     	beq	0x99a04 <.text+0x89904> @ imm = #0x8
   999f8: e59c0000     	ldr	r0, [r12]
   999fc: e3500009     	cmp	r0, #9
   99a00: ca00000b     	bgt	0x99a34 <.text+0x89934> @ imm = #0x2c
   99a04: e7d30002     	ldrb	r0, [r3, r2]
   99a08: e2200052     	eor	r0, r0, #82
   99a0c: e7c30002     	strb	r0, [r3, r2]
   99a10: e59e0000     	ldr	r0, [lr]
   99a14: e2401001     	sub	r1, r0, #1
   99a18: e0000190     	mul	r0, r0, r1
   99a1c: e2821001     	add	r1, r2, #1
   99a20: e3100001     	tst	r0, #1
   99a24: 0affffeb     	beq	0x999d8 <.text+0x898d8> @ imm = #-0x54
   99a28: e59c0000     	ldr	r0, [r12]
   99a2c: e3500009     	cmp	r0, #9
   99a30: daffffe8     	ble	0x999d8 <.text+0x898d8> @ imm = #-0x60
   99a34: e7d30002     	ldrb	r0, [r3, r2]
   99a38: e2200052     	eor	r0, r0, #82
   99a3c: e7c30002     	strb	r0, [r3, r2]
   99a40: eaffffef     	b	0x99a04 <.text+0x89904> @ imm = #-0x44
   99a44: e3a02000     	mov	r2, #0
   99a48: e3520000     	cmp	r2, #0
   99a4c: 1a000007     	bne	0x99a70 <.text+0x89970> @ imm = #0x1c
   99a50: e59f3fb0     	ldr	r3, [pc, #0xfb0]        @ 0x9aa08 <.text+0x8a908>
   99a54: e08f3003     	add	r3, pc, r3
   99a58: e7d30002     	ldrb	r0, [r3, r2]
   99a5c: e2200059     	eor	r0, r0, #89
   99a60: e7c30002     	strb	r0, [r3, r2]
   99a64: e2822001     	add	r2, r2, #1
   99a68: e3520015     	cmp	r2, #21
   99a6c: 1afffff9     	bne	0x99a58 <.text+0x89958> @ imm = #-0x1c
   99a70: e3a02000     	mov	r2, #0
   99a74: e3520000     	cmp	r2, #0
   99a78: 1a00001d     	bne	0x99af4 <.text+0x899f4> @ imm = #0x74
   99a7c: e59f3ff4     	ldr	r3, [pc, #0xff4]        @ 0x9aa78 <.text+0x8a978>
   99a80: e08f3003     	add	r3, pc, r3
   99a84: ea000002     	b	0x99a94 <.text+0x89994> @ imm = #0x8
   99a88: e3510029     	cmp	r1, #41
   99a8c: e1a02001     	mov	r2, r1
   99a90: 0a000017     	beq	0x99af4 <.text+0x899f4> @ imm = #0x5c
   99a94: e59e0000     	ldr	r0, [lr]
   99a98: e2401001     	sub	r1, r0, #1
   99a9c: e0000190     	mul	r0, r0, r1
   99aa0: e3100001     	tst	r0, #1
   99aa4: 0a000002     	beq	0x99ab4 <.text+0x899b4> @ imm = #0x8
   99aa8: e59c0000     	ldr	r0, [r12]
   99aac: e3500009     	cmp	r0, #9
   99ab0: ca00000b     	bgt	0x99ae4 <.text+0x899e4> @ imm = #0x2c
   99ab4: e7d30002     	ldrb	r0, [r3, r2]
   99ab8: e22000d7     	eor	r0, r0, #215
   99abc: e7c30002     	strb	r0, [r3, r2]
   99ac0: e59e0000     	ldr	r0, [lr]
   99ac4: e2401001     	sub	r1, r0, #1
   99ac8: e0000190     	mul	r0, r0, r1
   99acc: e2821001     	add	r1, r2, #1
   99ad0: e3100001     	tst	r0, #1
   99ad4: 0affffeb     	beq	0x99a88 <.text+0x89988> @ imm = #-0x54
   99ad8: e59c0000     	ldr	r0, [r12]
   99adc: e3500009     	cmp	r0, #9
   99ae0: daffffe8     	ble	0x99a88 <.text+0x89988> @ imm = #-0x60
   99ae4: e7d30002     	ldrb	r0, [r3, r2]
   99ae8: e22000d7     	eor	r0, r0, #215
   99aec: e7c30002     	strb	r0, [r3, r2]
   99af0: eaffffef     	b	0x99ab4 <.text+0x899b4> @ imm = #-0x44
   99af4: e3a02000     	mov	r2, #0
   99af8: e3520000     	cmp	r2, #0
   99afc: 1a000007     	bne	0x99b20 <.text+0x89a20> @ imm = #0x1c
   99b00: e59f3f74     	ldr	r3, [pc, #0xf74]        @ 0x9aa7c <.text+0x8a97c>
   99b04: e08f3003     	add	r3, pc, r3
   99b08: e7d30002     	ldrb	r0, [r3, r2]
   99b0c: e220004d     	eor	r0, r0, #77
   99b10: e7c30002     	strb	r0, [r3, r2]
   99b14: e2822001     	add	r2, r2, #1
   99b18: e3520024     	cmp	r2, #36
   99b1c: 1afffff9     	bne	0x99b08 <.text+0x89a08> @ imm = #-0x1c
   99b20: e3a02000     	mov	r2, #0
   99b24: e3520000     	cmp	r2, #0
   99b28: 1a00001d     	bne	0x99ba4 <.text+0x89aa4> @ imm = #0x74
   99b2c: e59f3f4c     	ldr	r3, [pc, #0xf4c]        @ 0x9aa80 <.text+0x8a980>
   99b30: e08f3003     	add	r3, pc, r3
   99b34: ea000002     	b	0x99b44 <.text+0x89a44> @ imm = #0x8
   99b38: e351000b     	cmp	r1, #11
   99b3c: e1a02001     	mov	r2, r1
   99b40: 0a000017     	beq	0x99ba4 <.text+0x89aa4> @ imm = #0x5c
   99b44: e59e0000     	ldr	r0, [lr]
   99b48: e2401001     	sub	r1, r0, #1
   99b4c: e0000190     	mul	r0, r0, r1
   99b50: e3100001     	tst	r0, #1
   99b54: 0a000002     	beq	0x99b64 <.text+0x89a64> @ imm = #0x8
   99b58: e59c0000     	ldr	r0, [r12]
   99b5c: e3500009     	cmp	r0, #9
   99b60: ca00000b     	bgt	0x99b94 <.text+0x89a94> @ imm = #0x2c
   99b64: e7d30002     	ldrb	r0, [r3, r2]
   99b68: e22000ce     	eor	r0, r0, #206
   99b6c: e7c30002     	strb	r0, [r3, r2]
   99b70: e59e0000     	ldr	r0, [lr]
   99b74: e2401001     	sub	r1, r0, #1
   99b78: e0000190     	mul	r0, r0, r1
   99b7c: e2821001     	add	r1, r2, #1
   99b80: e3100001     	tst	r0, #1
   99b84: 0affffeb     	beq	0x99b38 <.text+0x89a38> @ imm = #-0x54
   99b88: e59c0000     	ldr	r0, [r12]
   99b8c: e3500009     	cmp	r0, #9
   99b90: daffffe8     	ble	0x99b38 <.text+0x89a38> @ imm = #-0x60
   99b94: e7d30002     	ldrb	r0, [r3, r2]
   99b98: e22000ce     	eor	r0, r0, #206
   99b9c: e7c30002     	strb	r0, [r3, r2]
   99ba0: eaffffef     	b	0x99b64 <.text+0x89a64> @ imm = #-0x44
   99ba4: e3a02000     	mov	r2, #0
   99ba8: e3520000     	cmp	r2, #0
   99bac: 1a000007     	bne	0x99bd0 <.text+0x89ad0> @ imm = #0x1c
   99bb0: e59f3fe4     	ldr	r3, [pc, #0xfe4]        @ 0x9ab9c <.text+0x8aa9c>
   99bb4: e08f3003     	add	r3, pc, r3
   99bb8: e7d30002     	ldrb	r0, [r3, r2]
   99bbc: e2200059     	eor	r0, r0, #89
   99bc0: e7c30002     	strb	r0, [r3, r2]
   99bc4: e2822001     	add	r2, r2, #1
   99bc8: e3520027     	cmp	r2, #39
   99bcc: 1afffff9     	bne	0x99bb8 <.text+0x89ab8> @ imm = #-0x1c
   99bd0: e3a02000     	mov	r2, #0
   99bd4: e3520000     	cmp	r2, #0
   99bd8: 1a00001d     	bne	0x99c54 <.text+0x89b54> @ imm = #0x74
   99bdc: e59f3fbc     	ldr	r3, [pc, #0xfbc]        @ 0x9aba0 <.text+0x8aaa0>
   99be0: e08f3003     	add	r3, pc, r3
   99be4: ea000002     	b	0x99bf4 <.text+0x89af4> @ imm = #0x8
   99be8: e3510017     	cmp	r1, #23
   99bec: e1a02001     	mov	r2, r1
   99bf0: 0a000017     	beq	0x99c54 <.text+0x89b54> @ imm = #0x5c
   99bf4: e59e0000     	ldr	r0, [lr]
   99bf8: e2401001     	sub	r1, r0, #1
   99bfc: e0000190     	mul	r0, r0, r1
   99c00: e3100001     	tst	r0, #1
   99c04: 0a000002     	beq	0x99c14 <.text+0x89b14> @ imm = #0x8
   99c08: e59c0000     	ldr	r0, [r12]
   99c0c: e3500009     	cmp	r0, #9
   99c10: ca00000b     	bgt	0x99c44 <.text+0x89b44> @ imm = #0x2c
   99c14: e7d30002     	ldrb	r0, [r3, r2]
   99c18: e22000e2     	eor	r0, r0, #226
   99c1c: e7c30002     	strb	r0, [r3, r2]
   99c20: e59e0000     	ldr	r0, [lr]
   99c24: e2401001     	sub	r1, r0, #1
   99c28: e0000190     	mul	r0, r0, r1
   99c2c: e2821001     	add	r1, r2, #1
   99c30: e3100001     	tst	r0, #1
   99c34: 0affffeb     	beq	0x99be8 <.text+0x89ae8> @ imm = #-0x54
   99c38: e59c0000     	ldr	r0, [r12]
   99c3c: e3500009     	cmp	r0, #9
   99c40: daffffe8     	ble	0x99be8 <.text+0x89ae8> @ imm = #-0x60
   99c44: e7d30002     	ldrb	r0, [r3, r2]
   99c48: e22000e2     	eor	r0, r0, #226
   99c4c: e7c30002     	strb	r0, [r3, r2]
   99c50: eaffffef     	b	0x99c14 <.text+0x89b14> @ imm = #-0x44
   99c54: e3a02000     	mov	r2, #0
   99c58: e3520000     	cmp	r2, #0
   99c5c: 1a000007     	bne	0x99c80 <.text+0x89b80> @ imm = #0x1c
   99c60: e59f3fc0     	ldr	r3, [pc, #0xfc0]        @ 0x9ac28 <.text+0x8ab28>
   99c64: e08f3003     	add	r3, pc, r3
   99c68: e7d30002     	ldrb	r0, [r3, r2]
   99c6c: e22000a0     	eor	r0, r0, #160
   99c70: e7c30002     	strb	r0, [r3, r2]
   99c74: e2822001     	add	r2, r2, #1
   99c78: e3520014     	cmp	r2, #20
   99c7c: 1afffff9     	bne	0x99c68 <.text+0x89b68> @ imm = #-0x1c
   99c80: e59e0000     	ldr	r0, [lr]
   99c84: e2401001     	sub	r1, r0, #1
   99c88: e0000190     	mul	r0, r0, r1
   99c8c: e3100001     	tst	r0, #1
   99c90: e59e0000     	ldr	r0, [lr]
   99c94: e2401001     	sub	r1, r0, #1
   99c98: e0000190     	mul	r0, r0, r1
   99c9c: e3100001     	tst	r0, #1
   99ca0: 0a000002     	beq	0x99cb0 <.text+0x89bb0> @ imm = #0x8
   99ca4: e59c0000     	ldr	r0, [r12]
   99ca8: e3500009     	cmp	r0, #9
   99cac: cafffff7     	bgt	0x99c90 <.text+0x89b90> @ imm = #-0x24
   99cb0: e3a02000     	mov	r2, #0
   99cb4: e3520000     	cmp	r2, #0
   99cb8: 1a000007     	bne	0x99cdc <.text+0x89bdc> @ imm = #0x1c
   99cbc: e59f3fd4     	ldr	r3, [pc, #0xfd4]        @ 0x9ac98 <.text+0x8ab98>
   99cc0: e08f3003     	add	r3, pc, r3
   99cc4: e7d30002     	ldrb	r0, [r3, r2]
   99cc8: e2200055     	eor	r0, r0, #85
   99ccc: e7c30002     	strb	r0, [r3, r2]
   99cd0: e2822001     	add	r2, r2, #1
   99cd4: e352001f     	cmp	r2, #31
   99cd8: 1afffff9     	bne	0x99cc4 <.text+0x89bc4> @ imm = #-0x1c
   99cdc: e3a02000     	mov	r2, #0
   99ce0: e3520000     	cmp	r2, #0
   99ce4: 1a00001e     	bne	0x99d64 <.text+0x89c64> @ imm = #0x78
   99ce8: e59f3fac     	ldr	r3, [pc, #0xfac]        @ 0x9ac9c <.text+0x8ab9c>
   99cec: e08f3003     	add	r3, pc, r3
   99cf0: ea000002     	b	0x99d00 <.text+0x89c00> @ imm = #0x8
   99cf4: e351002c     	cmp	r1, #44
   99cf8: e1a02001     	mov	r2, r1
   99cfc: 0a000018     	beq	0x99d64 <.text+0x89c64> @ imm = #0x60
   99d00: e59e0000     	ldr	r0, [lr]
   99d04: e2401001     	sub	r1, r0, #1
   99d08: e0000190     	mul	r0, r0, r1
   99d0c: e3100001     	tst	r0, #1
   99d10: 0a000002     	beq	0x99d20 <.text+0x89c20> @ imm = #0x8
   99d14: e59c0000     	ldr	r0, [r12]
   99d18: e3500009     	cmp	r0, #9
   99d1c: ca00000b     	bgt	0x99d50 <.text+0x89c50> @ imm = #0x2c
   99d20: e7d30002     	ldrb	r0, [r3, r2]
   99d24: e220003b     	eor	r0, r0, #59
   99d28: e7c30002     	strb	r0, [r3, r2]
   99d2c: e59e0000     	ldr	r0, [lr]
   99d30: e2401001     	sub	r1, r0, #1
   99d34: e0000190     	mul	r0, r0, r1
   99d38: e2821001     	add	r1, r2, #1
   99d3c: e3100001     	tst	r0, #1
   99d40: 0affffeb     	beq	0x99cf4 <.text+0x89bf4> @ imm = #-0x54
   99d44: e59c0000     	ldr	r0, [r12]
   99d48: e3500009     	cmp	r0, #9
   99d4c: daffffe8     	ble	0x99cf4 <.text+0x89bf4> @ imm = #-0x60
   99d50: e7d30002     	ldrb	r0, [r3, r2]
   99d54: e220003b     	eor	r0, r0, #59
   99d58: e7c30002     	strb	r0, [r3, r2]
   99d5c: eaffffef     	b	0x99d20 <.text+0x89c20> @ imm = #-0x44
   99d60: 0054e0ba     	ldrheq	lr, [r4], #-10
   99d64: e3a02000     	mov	r2, #0
   99d68: e3520000     	cmp	r2, #0
   99d6c: 1a000007     	bne	0x99d90 <.text+0x89c90> @ imm = #0x1c
   99d70: e59f3f28     	ldr	r3, [pc, #0xf28]        @ 0x9aca0 <.text+0x8aba0>
   99d74: e08f3003     	add	r3, pc, r3
   99d78: e7d30002     	ldrb	r0, [r3, r2]
   99d7c: e2200084     	eor	r0, r0, #132
   99d80: e7c30002     	strb	r0, [r3, r2]
   99d84: e2822001     	add	r2, r2, #1
   99d88: e3520005     	cmp	r2, #5
   99d8c: 1afffff9     	bne	0x99d78 <.text+0x89c78> @ imm = #-0x1c
   99d90: e3a02000     	mov	r2, #0
   99d94: e3520000     	cmp	r2, #0
   99d98: 1a000020     	bne	0x99e20 <.text+0x89d20> @ imm = #0x80
   99d9c: e59f3ff8     	ldr	r3, [pc, #0xff8]        @ 0x9ad9c <.text+0x8ac9c>
   99da0: e08f3003     	add	r3, pc, r3
   99da4: ea000005     	b	0x99dc0 <.text+0x89cc0> @ imm = #0x14
   99da8: 0054e095     	<unknown>
   99dac: 0054e093     	<unknown>
   99db0: 0054e072     	subseq	lr, r4, r2, ror r0
   99db4: e3510019     	cmp	r1, #25
   99db8: e1a02001     	mov	r2, r1
   99dbc: 0a000017     	beq	0x99e20 <.text+0x89d20> @ imm = #0x5c
   99dc0: e59e0000     	ldr	r0, [lr]
   99dc4: e2401001     	sub	r1, r0, #1
   99dc8: e0000190     	mul	r0, r0, r1
   99dcc: e3100001     	tst	r0, #1
   99dd0: 0a000002     	beq	0x99de0 <.text+0x89ce0> @ imm = #0x8
   99dd4: e59c0000     	ldr	r0, [r12]
   99dd8: e3500009     	cmp	r0, #9
   99ddc: ca00000b     	bgt	0x99e10 <.text+0x89d10> @ imm = #0x2c
   99de0: e7d30002     	ldrb	r0, [r3, r2]
   99de4: e2200086     	eor	r0, r0, #134
   99de8: e7c30002     	strb	r0, [r3, r2]
   99dec: e59e0000     	ldr	r0, [lr]
   99df0: e2401001     	sub	r1, r0, #1
   99df4: e0000190     	mul	r0, r0, r1
   99df8: e2821001     	add	r1, r2, #1
   99dfc: e3100001     	tst	r0, #1
   99e00: 0affffeb     	beq	0x99db4 <.text+0x89cb4> @ imm = #-0x54
   99e04: e59c0000     	ldr	r0, [r12]
   99e08: e3500009     	cmp	r0, #9
   99e0c: daffffe8     	ble	0x99db4 <.text+0x89cb4> @ imm = #-0x60
   99e10: e7d30002     	ldrb	r0, [r3, r2]
   99e14: e2200086     	eor	r0, r0, #134
   99e18: e7c30002     	strb	r0, [r3, r2]
   99e1c: eaffffef     	b	0x99de0 <.text+0x89ce0> @ imm = #-0x44
   99e20: e3a02000     	mov	r2, #0
   99e24: e3520000     	cmp	r2, #0
   99e28: 1a000022     	bne	0x99eb8 <.text+0x89db8> @ imm = #0x88
   99e2c: e59f3fd8     	ldr	r3, [pc, #0xfd8]        @ 0x9ae0c <.text+0x8ad0c>
   99e30: e08f3003     	add	r3, pc, r3
   99e34: ea000006     	b	0x99e54 <.text+0x89d54> @ imm = #0x18
   99e38: 0054e066     	subseq	lr, r4, r6, rrx
   99e3c: 0054e054     	subseq	lr, r4, r4, asr r0
   99e40: 00546b60     	subseq	r6, r4, r0, ror #22
   99e44: 00546198     	<unknown>
   99e48: e351000f     	cmp	r1, #15
   99e4c: e1a02001     	mov	r2, r1
   99e50: 0a000018     	beq	0x99eb8 <.text+0x89db8> @ imm = #0x60
   99e54: e59e0000     	ldr	r0, [lr]
   99e58: e2401001     	sub	r1, r0, #1
   99e5c: e0000190     	mul	r0, r0, r1
   99e60: e3100001     	tst	r0, #1
   99e64: 0a000002     	beq	0x99e74 <.text+0x89d74> @ imm = #0x8
   99e68: e59c0000     	ldr	r0, [r12]
   99e6c: e3500009     	cmp	r0, #9
   99e70: ca00000b     	bgt	0x99ea4 <.text+0x89da4> @ imm = #0x2c
   99e74: e7d30002     	ldrb	r0, [r3, r2]
   99e78: e2200048     	eor	r0, r0, #72
   99e7c: e7c30002     	strb	r0, [r3, r2]
   99e80: e59e0000     	ldr	r0, [lr]
   99e84: e2401001     	sub	r1, r0, #1
   99e88: e0000190     	mul	r0, r0, r1
   99e8c: e2821001     	add	r1, r2, #1
   99e90: e3100001     	tst	r0, #1
   99e94: 0affffeb     	beq	0x99e48 <.text+0x89d48> @ imm = #-0x54
   99e98: e59c0000     	ldr	r0, [r12]
   99e9c: e3500009     	cmp	r0, #9
   99ea0: daffffe8     	ble	0x99e48 <.text+0x89d48> @ imm = #-0x60
   99ea4: e7d30002     	ldrb	r0, [r3, r2]
   99ea8: e2200048     	eor	r0, r0, #72
   99eac: e7c30002     	strb	r0, [r3, r2]
   99eb0: eaffffef     	b	0x99e74 <.text+0x89d74> @ imm = #-0x44
   99eb4: 0054dffe     	ldrsheq	sp, [r4], #-254
   99eb8: e59e0000     	ldr	r0, [lr]
   99ebc: e2401001     	sub	r1, r0, #1
   99ec0: e0000190     	mul	r0, r0, r1
   99ec4: e3100001     	tst	r0, #1
   99ec8: e59e0000     	ldr	r0, [lr]
   99ecc: e2401001     	sub	r1, r0, #1
   99ed0: e0000190     	mul	r0, r0, r1
   99ed4: e3100001     	tst	r0, #1
   99ed8: 0a000002     	beq	0x99ee8 <.text+0x89de8> @ imm = #0x8
   99edc: e59c0000     	ldr	r0, [r12]
   99ee0: e3500009     	cmp	r0, #9
   99ee4: cafffff7     	bgt	0x99ec8 <.text+0x89dc8> @ imm = #-0x24
   99ee8: e3a02000     	mov	r2, #0
   99eec: e3520000     	cmp	r2, #0
   99ef0: 1a00001e     	bne	0x99f70 <.text+0x89e70> @ imm = #0x78
   99ef4: e59f3fdc     	ldr	r3, [pc, #0xfdc]        @ 0x9aed8 <.text+0x8add8>
   99ef8: e08f3003     	add	r3, pc, r3
   99efc: ea000002     	b	0x99f0c <.text+0x89e0c> @ imm = #0x8
   99f00: e3510009     	cmp	r1, #9
   99f04: e1a02001     	mov	r2, r1
   99f08: 0a000018     	beq	0x99f70 <.text+0x89e70> @ imm = #0x60
   99f0c: e59e0000     	ldr	r0, [lr]
   99f10: e2401001     	sub	r1, r0, #1
   99f14: e0000190     	mul	r0, r0, r1
   99f18: e3100001     	tst	r0, #1
   99f1c: 0a000002     	beq	0x99f2c <.text+0x89e2c> @ imm = #0x8
   99f20: e59c0000     	ldr	r0, [r12]
   99f24: e3500009     	cmp	r0, #9
   99f28: ca00000b     	bgt	0x99f5c <.text+0x89e5c> @ imm = #0x2c
   99f2c: e7d30002     	ldrb	r0, [r3, r2]
   99f30: e2200080     	eor	r0, r0, #128
   99f34: e7c30002     	strb	r0, [r3, r2]
   99f38: e59e0000     	ldr	r0, [lr]
   99f3c: e2401001     	sub	r1, r0, #1
   99f40: e0000190     	mul	r0, r0, r1
   99f44: e2821001     	add	r1, r2, #1
   99f48: e3100001     	tst	r0, #1
   99f4c: 0affffeb     	beq	0x99f00 <.text+0x89e00> @ imm = #-0x54
   99f50: e59c0000     	ldr	r0, [r12]
   99f54: e3500009     	cmp	r0, #9
   99f58: daffffe8     	ble	0x99f00 <.text+0x89e00> @ imm = #-0x60
   99f5c: e7d30002     	ldrb	r0, [r3, r2]
   99f60: e2200080     	eor	r0, r0, #128
   99f64: e7c30002     	strb	r0, [r3, r2]
   99f68: eaffffef     	b	0x99f2c <.text+0x89e2c> @ imm = #-0x44
   99f6c: 0054df53     	subseq	sp, r4, r3, asr pc
   99f70: e3a02000     	mov	r2, #0
   99f74: e3520000     	cmp	r2, #0
   99f78: 1a000007     	bne	0x99f9c <.text+0x89e9c> @ imm = #0x1c
   99f7c: e59f3fc4     	ldr	r3, [pc, #0xfc4]        @ 0x9af48 <.text+0x8ae48>
   99f80: e08f3003     	add	r3, pc, r3
   99f84: e7d30002     	ldrb	r0, [r3, r2]
   99f88: e22000d3     	eor	r0, r0, #211
   99f8c: e7c30002     	strb	r0, [r3, r2]
   99f90: e2822001     	add	r2, r2, #1
   99f94: e3520005     	cmp	r2, #5
   99f98: 1afffff9     	bne	0x99f84 <.text+0x89e84> @ imm = #-0x1c
   99f9c: e3a02000     	mov	r2, #0
   99fa0: e3520000     	cmp	r2, #0
   99fa4: 1a000007     	bne	0x99fc8 <.text+0x89ec8> @ imm = #0x1c
   99fa8: e59f3f9c     	ldr	r3, [pc, #0xf9c]        @ 0x9af4c <.text+0x8ae4c>
   99fac: e08f3003     	add	r3, pc, r3
   99fb0: e7d30002     	ldrb	r0, [r3, r2]
   99fb4: e22000d7     	eor	r0, r0, #215
   99fb8: e7c30002     	strb	r0, [r3, r2]
   99fbc: e2822001     	add	r2, r2, #1
   99fc0: e3520007     	cmp	r2, #7
   99fc4: 1afffff9     	bne	0x99fb0 <.text+0x89eb0> @ imm = #-0x1c
   99fc8: e3a02000     	mov	r2, #0
   99fcc: e3520000     	cmp	r2, #0
   99fd0: 1a000007     	bne	0x99ff4 <.text+0x89ef4> @ imm = #0x1c
   99fd4: e59f3fe8     	ldr	r3, [pc, #0xfe8]        @ 0x9afc4 <.text+0x8aec4>
   99fd8: e08f3003     	add	r3, pc, r3
   99fdc: e7d30002     	ldrb	r0, [r3, r2]
   99fe0: e2200077     	eor	r0, r0, #119
   99fe4: e7c30002     	strb	r0, [r3, r2]
   99fe8: e2822001     	add	r2, r2, #1
   99fec: e3520014     	cmp	r2, #20
   99ff0: 1afffff9     	bne	0x99fdc <.text+0x89edc> @ imm = #-0x1c
   99ff4: e3a02000     	mov	r2, #0
   99ff8: e3520000     	cmp	r2, #0
   99ffc: 1a000020     	bne	0x9a084 <.text+0x89f84> @ imm = #0x80
   9a000: e59f3fc0     	ldr	r3, [pc, #0xfc0]        @ 0x9afc8 <.text+0x8aec8>
   9a004: e08f3003     	add	r3, pc, r3
   9a008: ea000003     	b	0x9a01c <.text+0x89f1c> @ imm = #0xc
   9a00c: 0054ded8     	ldrsbeq	sp, [r4], #-232
   9a010: e351001c     	cmp	r1, #28
   9a014: e1a02001     	mov	r2, r1
   9a018: 0a000019     	beq	0x9a084 <.text+0x89f84> @ imm = #0x64
   9a01c: e59e0000     	ldr	r0, [lr]
   9a020: e2401001     	sub	r1, r0, #1
   9a024: e0000190     	mul	r0, r0, r1
   9a028: e3100001     	tst	r0, #1
   9a02c: 0a000002     	beq	0x9a03c <.text+0x89f3c> @ imm = #0x8
   9a030: e59c0000     	ldr	r0, [r12]
   9a034: e3500009     	cmp	r0, #9
   9a038: ca00000b     	bgt	0x9a06c <.text+0x89f6c> @ imm = #0x2c
   9a03c: e7d30002     	ldrb	r0, [r3, r2]
   9a040: e2200059     	eor	r0, r0, #89
   9a044: e7c30002     	strb	r0, [r3, r2]
   9a048: e59e0000     	ldr	r0, [lr]
   9a04c: e2401001     	sub	r1, r0, #1
   9a050: e0000190     	mul	r0, r0, r1
   9a054: e2821001     	add	r1, r2, #1
   9a058: e3100001     	tst	r0, #1
   9a05c: 0affffeb     	beq	0x9a010 <.text+0x89f10> @ imm = #-0x54
   9a060: e59c0000     	ldr	r0, [r12]
   9a064: e3500009     	cmp	r0, #9
   9a068: daffffe8     	ble	0x9a010 <.text+0x89f10> @ imm = #-0x60
   9a06c: e7d30002     	ldrb	r0, [r3, r2]
   9a070: e2200059     	eor	r0, r0, #89
   9a074: e7c30002     	strb	r0, [r3, r2]
   9a078: eaffffef     	b	0x9a03c <.text+0x89f3c> @ imm = #-0x44
   9a07c: 0054de3f     	subseq	sp, r4, pc, lsr lr
   9a080: 0054ddde     	ldrsbeq	sp, [r4], #-222
   9a084: e59e0000     	ldr	r0, [lr]
   9a088: e2401001     	sub	r1, r0, #1
   9a08c: e0000190     	mul	r0, r0, r1
   9a090: e3100001     	tst	r0, #1
   9a094: e59e0000     	ldr	r0, [lr]
   9a098: e2401001     	sub	r1, r0, #1
   9a09c: e0000190     	mul	r0, r0, r1
   9a0a0: e3100001     	tst	r0, #1
   9a0a4: 0a000002     	beq	0x9a0b4 <.text+0x89fb4> @ imm = #0x8
   9a0a8: e59c0000     	ldr	r0, [r12]
   9a0ac: e3500009     	cmp	r0, #9
   9a0b0: cafffff7     	bgt	0x9a094 <.text+0x89f94> @ imm = #-0x24
   9a0b4: e3a02000     	mov	r2, #0
   9a0b8: e3520000     	cmp	r2, #0
   9a0bc: 1a000007     	bne	0x9a0e0 <.text+0x89fe0> @ imm = #0x1c
   9a0c0: e59f3f70     	ldr	r3, [pc, #0xf70]        @ 0x9b038 <.text+0x8af38>
   9a0c4: e08f3003     	add	r3, pc, r3
   9a0c8: e7d30002     	ldrb	r0, [r3, r2]
   9a0cc: e2200092     	eor	r0, r0, #146
   9a0d0: e7c30002     	strb	r0, [r3, r2]
   9a0d4: e2822001     	add	r2, r2, #1
   9a0d8: e3520016     	cmp	r2, #22
   9a0dc: 1afffff9     	bne	0x9a0c8 <.text+0x89fc8> @ imm = #-0x1c
   9a0e0: e3a02000     	mov	r2, #0
   9a0e4: e3520000     	cmp	r2, #0
   9a0e8: 1a000007     	bne	0x9a10c <.text+0x8a00c> @ imm = #0x1c
   9a0ec: e59f3f48     	ldr	r3, [pc, #0xf48]        @ 0x9b03c <.text+0x8af3c>
   9a0f0: e08f3003     	add	r3, pc, r3
   9a0f4: e7d30002     	ldrb	r0, [r3, r2]
   9a0f8: e2200054     	eor	r0, r0, #84
   9a0fc: e7c30002     	strb	r0, [r3, r2]
   9a100: e2822001     	add	r2, r2, #1
   9a104: e352002a     	cmp	r2, #42
   9a108: 1afffff9     	bne	0x9a0f4 <.text+0x89ff4> @ imm = #-0x1c
   9a10c: e59e0000     	ldr	r0, [lr]
   9a110: e2401001     	sub	r1, r0, #1
   9a114: e0000190     	mul	r0, r0, r1
   9a118: e3100001     	tst	r0, #1
   9a11c: e59e0000     	ldr	r0, [lr]
   9a120: e2401001     	sub	r1, r0, #1
   9a124: e0000190     	mul	r0, r0, r1
   9a128: e3100001     	tst	r0, #1
   9a12c: 0a000002     	beq	0x9a13c <.text+0x8a03c> @ imm = #0x8
   9a130: e59c0000     	ldr	r0, [r12]
   9a134: e3500009     	cmp	r0, #9
   9a138: cafffff7     	bgt	0x9a11c <.text+0x8a01c> @ imm = #-0x24
   9a13c: e3a02000     	mov	r2, #0
   9a140: e3520000     	cmp	r2, #0
   9a144: 1a000007     	bne	0x9a168 <.text+0x8a068> @ imm = #0x1c
   9a148: e59f3fc8     	ldr	r3, [pc, #0xfc8]        @ 0x9b118 <.text+0x8b018>
   9a14c: e08f3003     	add	r3, pc, r3
   9a150: e7d30002     	ldrb	r0, [r3, r2]
   9a154: e22000c8     	eor	r0, r0, #200
   9a158: e7c30002     	strb	r0, [r3, r2]
   9a15c: e2822001     	add	r2, r2, #1
   9a160: e352000d     	cmp	r2, #13
   9a164: 1afffff9     	bne	0x9a150 <.text+0x8a050> @ imm = #-0x1c
   9a168: e59e0000     	ldr	r0, [lr]
   9a16c: e2401001     	sub	r1, r0, #1
   9a170: e0000190     	mul	r0, r0, r1
   9a174: e3100001     	tst	r0, #1
   9a178: e59e0000     	ldr	r0, [lr]
   9a17c: e2401001     	sub	r1, r0, #1
   9a180: e0000190     	mul	r0, r0, r1
   9a184: e3100001     	tst	r0, #1
   9a188: 0a000002     	beq	0x9a198 <.text+0x8a098> @ imm = #0x8
   9a18c: e59c0000     	ldr	r0, [r12]
   9a190: e3500009     	cmp	r0, #9
   9a194: cafffff7     	bgt	0x9a178 <.text+0x8a078> @ imm = #-0x24
   9a198: e3a02000     	mov	r2, #0
   9a19c: e3520000     	cmp	r2, #0
   9a1a0: 1a00001f     	bne	0x9a224 <.text+0x8a124> @ imm = #0x7c
   9a1a4: e59f3f70     	ldr	r3, [pc, #0xf70]        @ 0x9b11c <.text+0x8b01c>
   9a1a8: e08f3003     	add	r3, pc, r3
   9a1ac: ea000003     	b	0x9a1c0 <.text+0x8a0c0> @ imm = #0xc
   9a1b0: 0054dd60     	subseq	sp, r4, r0, ror #26
   9a1b4: e3510007     	cmp	r1, #7
   9a1b8: e1a02001     	mov	r2, r1
   9a1bc: 0a000018     	beq	0x9a224 <.text+0x8a124> @ imm = #0x60
   9a1c0: e59e0000     	ldr	r0, [lr]
   9a1c4: e2401001     	sub	r1, r0, #1
   9a1c8: e0000190     	mul	r0, r0, r1
   9a1cc: e3100001     	tst	r0, #1
   9a1d0: 0a000002     	beq	0x9a1e0 <.text+0x8a0e0> @ imm = #0x8
   9a1d4: e59c0000     	ldr	r0, [r12]
   9a1d8: e3500009     	cmp	r0, #9
   9a1dc: ca00000b     	bgt	0x9a210 <.text+0x8a110> @ imm = #0x2c
   9a1e0: e7d30002     	ldrb	r0, [r3, r2]
   9a1e4: e2200020     	eor	r0, r0, #32
   9a1e8: e7c30002     	strb	r0, [r3, r2]
   9a1ec: e59e0000     	ldr	r0, [lr]
   9a1f0: e2401001     	sub	r1, r0, #1
   9a1f4: e0000190     	mul	r0, r0, r1
   9a1f8: e2821001     	add	r1, r2, #1
   9a1fc: e3100001     	tst	r0, #1
   9a200: 0affffeb     	beq	0x9a1b4 <.text+0x8a0b4> @ imm = #-0x54
   9a204: e59c0000     	ldr	r0, [r12]
   9a208: e3500009     	cmp	r0, #9
   9a20c: daffffe8     	ble	0x9a1b4 <.text+0x8a0b4> @ imm = #-0x60
   9a210: e7d30002     	ldrb	r0, [r3, r2]
   9a214: e2200020     	eor	r0, r0, #32
   9a218: e7c30002     	strb	r0, [r3, r2]
   9a21c: eaffffef     	b	0x9a1e0 <.text+0x8a0e0> @ imm = #-0x44
   9a220: 0054dd1e     	subseq	sp, r4, lr, lsl sp
   9a224: e3a02000     	mov	r2, #0
   9a228: e3520000     	cmp	r2, #0
   9a22c: 1a00001f     	bne	0x9a2b0 <.text+0x8a1b0> @ imm = #0x7c
   9a230: e59f3ee8     	ldr	r3, [pc, #0xee8]        @ 0x9b120 <.text+0x8b020>
   9a234: e08f3003     	add	r3, pc, r3
   9a238: ea000003     	b	0x9a24c <.text+0x8a14c> @ imm = #0xc
   9a23c: 0054dcca     	subseq	sp, r4, r10, asr #25
   9a240: e3510006     	cmp	r1, #6
   9a244: e1a02001     	mov	r2, r1
   9a248: 0a000018     	beq	0x9a2b0 <.text+0x8a1b0> @ imm = #0x60
   9a24c: e59e0000     	ldr	r0, [lr]
   9a250: e2401001     	sub	r1, r0, #1
   9a254: e0000190     	mul	r0, r0, r1
   9a258: e3100001     	tst	r0, #1
   9a25c: 0a000002     	beq	0x9a26c <.text+0x8a16c> @ imm = #0x8
   9a260: e59c0000     	ldr	r0, [r12]
   9a264: e3500009     	cmp	r0, #9
   9a268: ca00000b     	bgt	0x9a29c <.text+0x8a19c> @ imm = #0x2c
   9a26c: e7d30002     	ldrb	r0, [r3, r2]
   9a270: e2200021     	eor	r0, r0, #33
   9a274: e7c30002     	strb	r0, [r3, r2]
   9a278: e59e0000     	ldr	r0, [lr]
   9a27c: e2401001     	sub	r1, r0, #1
   9a280: e0000190     	mul	r0, r0, r1
   9a284: e2821001     	add	r1, r2, #1
   9a288: e3100001     	tst	r0, #1
   9a28c: 0affffeb     	beq	0x9a240 <.text+0x8a140> @ imm = #-0x54
   9a290: e59c0000     	ldr	r0, [r12]
   9a294: e3500009     	cmp	r0, #9
   9a298: daffffe8     	ble	0x9a240 <.text+0x8a140> @ imm = #-0x60
   9a29c: e7d30002     	ldrb	r0, [r3, r2]
   9a2a0: e2200021     	eor	r0, r0, #33
   9a2a4: e7c30002     	strb	r0, [r3, r2]
   9a2a8: eaffffef     	b	0x9a26c <.text+0x8a16c> @ imm = #-0x44
   9a2ac: 0054dca3     	subseq	sp, r4, r3, lsr #25
   9a2b0: e3a02000     	mov	r2, #0
   9a2b4: e3520000     	cmp	r2, #0
   9a2b8: 1a000007     	bne	0x9a2dc <.text+0x8a1dc> @ imm = #0x1c
   9a2bc: e59f3e60     	ldr	r3, [pc, #0xe60]        @ 0x9b124 <.text+0x8b024>
   9a2c0: e08f3003     	add	r3, pc, r3
   9a2c4: e7d30002     	ldrb	r0, [r3, r2]
   9a2c8: e220000d     	eor	r0, r0, #13
   9a2cc: e7c30002     	strb	r0, [r3, r2]
   9a2d0: e2822001     	add	r2, r2, #1
   9a2d4: e352001f     	cmp	r2, #31
   9a2d8: 1afffff9     	bne	0x9a2c4 <.text+0x8a1c4> @ imm = #-0x1c
   9a2dc: e3a02000     	mov	r2, #0
   9a2e0: e3520000     	cmp	r2, #0
   9a2e4: 1a000021     	bne	0x9a370 <.text+0x8a270> @ imm = #0x84
   9a2e8: e59f3e38     	ldr	r3, [pc, #0xe38]        @ 0x9b128 <.text+0x8b028>
   9a2ec: e08f3003     	add	r3, pc, r3
   9a2f0: ea000003     	b	0x9a304 <.text+0x8a204> @ imm = #0xc
   9a2f4: 0054dc26     	subseq	sp, r4, r6, lsr #24
   9a2f8: e3510006     	cmp	r1, #6
   9a2fc: e1a02001     	mov	r2, r1
   9a300: 0a00001a     	beq	0x9a370 <.text+0x8a270> @ imm = #0x68
   9a304: e59e0000     	ldr	r0, [lr]
   9a308: e2401001     	sub	r1, r0, #1
   9a30c: e0000190     	mul	r0, r0, r1
   9a310: e3100001     	tst	r0, #1
   9a314: 0a000002     	beq	0x9a324 <.text+0x8a224> @ imm = #0x8
   9a318: e59c0000     	ldr	r0, [r12]
   9a31c: e3500009     	cmp	r0, #9
   9a320: ca00000b     	bgt	0x9a354 <.text+0x8a254> @ imm = #0x2c
   9a324: e7d30002     	ldrb	r0, [r3, r2]
   9a328: e220008b     	eor	r0, r0, #139
   9a32c: e7c30002     	strb	r0, [r3, r2]
   9a330: e59e0000     	ldr	r0, [lr]
   9a334: e2401001     	sub	r1, r0, #1
   9a338: e0000190     	mul	r0, r0, r1
   9a33c: e2821001     	add	r1, r2, #1
   9a340: e3100001     	tst	r0, #1
   9a344: 0affffeb     	beq	0x9a2f8 <.text+0x8a1f8> @ imm = #-0x54
   9a348: e59c0000     	ldr	r0, [r12]
   9a34c: e3500009     	cmp	r0, #9
   9a350: daffffe8     	ble	0x9a2f8 <.text+0x8a1f8> @ imm = #-0x60
   9a354: e7d30002     	ldrb	r0, [r3, r2]
   9a358: e220008b     	eor	r0, r0, #139
   9a35c: e7c30002     	strb	r0, [r3, r2]
   9a360: eaffffef     	b	0x9a324 <.text+0x8a224> @ imm = #-0x44
   9a364: 0054dbad     	subseq	sp, r4, sp, lsr #23
   9a368: 0054db5b     	subseq	sp, r4, r11, asr r11
   9a36c: 0054db01     	subseq	sp, r4, r1, lsl #22
   9a370: e59e0000     	ldr	r0, [lr]
   9a374: e2401001     	sub	r1, r0, #1
   9a378: e0000190     	mul	r0, r0, r1
   9a37c: e3100001     	tst	r0, #1
   9a380: e59e0000     	ldr	r0, [lr]
   9a384: e2401001     	sub	r1, r0, #1
   9a388: e0000190     	mul	r0, r0, r1
   9a38c: e3100001     	tst	r0, #1
   9a390: 0a000002     	beq	0x9a3a0 <.text+0x8a2a0> @ imm = #0x8
   9a394: e59c0000     	ldr	r0, [r12]
   9a398: e3500009     	cmp	r0, #9
   9a39c: cafffff7     	bgt	0x9a380 <.text+0x8a280> @ imm = #-0x24
   9a3a0: e3a02000     	mov	r2, #0
   9a3a4: e3520000     	cmp	r2, #0
   9a3a8: 1a000007     	bne	0x9a3cc <.text+0x8a2cc> @ imm = #0x1c
   9a3ac: e59f3d78     	ldr	r3, [pc, #0xd78]        @ 0x9b12c <.text+0x8b02c>
   9a3b0: e08f3003     	add	r3, pc, r3
   9a3b4: e7d30002     	ldrb	r0, [r3, r2]
   9a3b8: e2200097     	eor	r0, r0, #151
   9a3bc: e7c30002     	strb	r0, [r3, r2]
   9a3c0: e2822001     	add	r2, r2, #1
   9a3c4: e3520025     	cmp	r2, #37
   9a3c8: 1afffff9     	bne	0x9a3b4 <.text+0x8a2b4> @ imm = #-0x1c
   9a3cc: e3a02000     	mov	r2, #0
   9a3d0: e3520000     	cmp	r2, #0
   9a3d4: 1a000007     	bne	0x9a3f8 <.text+0x8a2f8> @ imm = #0x1c
   9a3d8: e59f3d50     	ldr	r3, [pc, #0xd50]        @ 0x9b130 <.text+0x8b030>
   9a3dc: e08f3003     	add	r3, pc, r3
   9a3e0: e7d30002     	ldrb	r0, [r3, r2]
   9a3e4: e2200066     	eor	r0, r0, #102
   9a3e8: e7c30002     	strb	r0, [r3, r2]
   9a3ec: e2822001     	add	r2, r2, #1
   9a3f0: e3520019     	cmp	r2, #25
   9a3f4: 1afffff9     	bne	0x9a3e0 <.text+0x8a2e0> @ imm = #-0x1c
   9a3f8: e3a02000     	mov	r2, #0
   9a3fc: e3520000     	cmp	r2, #0
   9a400: 1a000007     	bne	0x9a424 <.text+0x8a324> @ imm = #0x1c
   9a404: e59f3d28     	ldr	r3, [pc, #0xd28]        @ 0x9b134 <.text+0x8b034>
   9a408: e08f3003     	add	r3, pc, r3
   9a40c: e7d30002     	ldrb	r0, [r3, r2]
   9a410: e22000c5     	eor	r0, r0, #197
   9a414: e7c30002     	strb	r0, [r3, r2]
   9a418: e2822001     	add	r2, r2, #1
   9a41c: e352002a     	cmp	r2, #42
   9a420: 1afffff9     	bne	0x9a40c <.text+0x8a30c> @ imm = #-0x1c
   9a424: e59f3d0c     	ldr	r3, [pc, #0xd0c]        @ 0x9b138 <.text+0x8b038>
   9a428: e3a02000     	mov	r2, #0
   9a42c: e08f3003     	add	r3, pc, r3
   9a430: e7d30002     	ldrb	r0, [r3, r2]
   9a434: e2200017     	eor	r0, r0, #23
   9a438: e7c30002     	strb	r0, [r3, r2]
   9a43c: e2822001     	add	r2, r2, #1
   9a440: e3520024     	cmp	r2, #36
   9a444: 1afffff9     	bne	0x9a430 <.text+0x8a330> @ imm = #-0x1c
   9a448: e3a02000     	mov	r2, #0
   9a44c: e3520000     	cmp	r2, #0
   9a450: 1a000007     	bne	0x9a474 <.text+0x8a374> @ imm = #0x1c
   9a454: e59f3ce0     	ldr	r3, [pc, #0xce0]        @ 0x9b13c <.text+0x8b03c>
   9a458: e08f3003     	add	r3, pc, r3
   9a45c: e7d30002     	ldrb	r0, [r3, r2]
   9a460: e2200021     	eor	r0, r0, #33
   9a464: e7c30002     	strb	r0, [r3, r2]
   9a468: e2822001     	add	r2, r2, #1
   9a46c: e3520024     	cmp	r2, #36
   9a470: 1afffff9     	bne	0x9a45c <.text+0x8a35c> @ imm = #-0x1c
   9a474: e3a02000     	mov	r2, #0
   9a478: e3520000     	cmp	r2, #0
   9a47c: 1a000007     	bne	0x9a4a0 <.text+0x8a3a0> @ imm = #0x1c
   9a480: e59f3cb8     	ldr	r3, [pc, #0xcb8]        @ 0x9b140 <.text+0x8b040>
   9a484: e08f3003     	add	r3, pc, r3
   9a488: e7d30002     	ldrb	r0, [r3, r2]
   9a48c: e2200087     	eor	r0, r0, #135
   9a490: e7c30002     	strb	r0, [r3, r2]
   9a494: e2822001     	add	r2, r2, #1
   9a498: e352000a     	cmp	r2, #10
   9a49c: 1afffff9     	bne	0x9a488 <.text+0x8a388> @ imm = #-0x1c
   9a4a0: e3a02000     	mov	r2, #0
   9a4a4: e3520000     	cmp	r2, #0
   9a4a8: 1a00001d     	bne	0x9a524 <.text+0x8a424> @ imm = #0x74
   9a4ac: e59f3c90     	ldr	r3, [pc, #0xc90]        @ 0x9b144 <.text+0x8b044>
   9a4b0: e08f3003     	add	r3, pc, r3
   9a4b4: ea000002     	b	0x9a4c4 <.text+0x8a3c4> @ imm = #0x8
   9a4b8: e3510023     	cmp	r1, #35
   9a4bc: e1a02001     	mov	r2, r1
   9a4c0: 0a000017     	beq	0x9a524 <.text+0x8a424> @ imm = #0x5c
   9a4c4: e59e0000     	ldr	r0, [lr]
   9a4c8: e2401001     	sub	r1, r0, #1
   9a4cc: e0000190     	mul	r0, r0, r1
   9a4d0: e3100001     	tst	r0, #1
   9a4d4: 0a000002     	beq	0x9a4e4 <.text+0x8a3e4> @ imm = #0x8
   9a4d8: e59c0000     	ldr	r0, [r12]
   9a4dc: e3500009     	cmp	r0, #9
   9a4e0: ca00000b     	bgt	0x9a514 <.text+0x8a414> @ imm = #0x2c
   9a4e4: e7d30002     	ldrb	r0, [r3, r2]
   9a4e8: e22000ec     	eor	r0, r0, #236
   9a4ec: e7c30002     	strb	r0, [r3, r2]
   9a4f0: e59e0000     	ldr	r0, [lr]
   9a4f4: e2401001     	sub	r1, r0, #1
   9a4f8: e0000190     	mul	r0, r0, r1
   9a4fc: e2821001     	add	r1, r2, #1
   9a500: e3100001     	tst	r0, #1
   9a504: 0affffeb     	beq	0x9a4b8 <.text+0x8a3b8> @ imm = #-0x54
   9a508: e59c0000     	ldr	r0, [r12]
   9a50c: e3500009     	cmp	r0, #9
   9a510: daffffe8     	ble	0x9a4b8 <.text+0x8a3b8> @ imm = #-0x60
   9a514: e7d30002     	ldrb	r0, [r3, r2]
   9a518: e22000ec     	eor	r0, r0, #236
   9a51c: e7c30002     	strb	r0, [r3, r2]
   9a520: eaffffef     	b	0x9a4e4 <.text+0x8a3e4> @ imm = #-0x44
   9a524: e59f2c1c     	ldr	r2, [pc, #0xc1c]        @ 0x9b148 <.text+0x8b048>
   9a528: e3a03000     	mov	r3, #0
   9a52c: e08f2002     	add	r2, pc, r2
   9a530: ea000003     	b	0x9a544 <.text+0x8a444> @ imm = #0xc
   9a534: 0054da6a     	subseq	sp, r4, r10, ror #20
   9a538: e3510030     	cmp	r1, #48
   9a53c: e1a03001     	mov	r3, r1
   9a540: 0a00001a     	beq	0x9a5b0 <.text+0x8a4b0> @ imm = #0x68
   9a544: e59e0000     	ldr	r0, [lr]
   9a548: e2401001     	sub	r1, r0, #1
   9a54c: e0000190     	mul	r0, r0, r1
   9a550: e3100001     	tst	r0, #1
   9a554: 0a000002     	beq	0x9a564 <.text+0x8a464> @ imm = #0x8
   9a558: e59c0000     	ldr	r0, [r12]
   9a55c: e3500009     	cmp	r0, #9
   9a560: ca00000b     	bgt	0x9a594 <.text+0x8a494> @ imm = #0x2c
   9a564: e7d20003     	ldrb	r0, [r2, r3]
   9a568: e22000b7     	eor	r0, r0, #183
   9a56c: e7c20003     	strb	r0, [r2, r3]
   9a570: e59e0000     	ldr	r0, [lr]
   9a574: e2401001     	sub	r1, r0, #1
   9a578: e0000190     	mul	r0, r0, r1
   9a57c: e2831001     	add	r1, r3, #1
   9a580: e3100001     	tst	r0, #1
   9a584: 0affffeb     	beq	0x9a538 <.text+0x8a438> @ imm = #-0x54
   9a588: e59c0000     	ldr	r0, [r12]
   9a58c: e3500009     	cmp	r0, #9
   9a590: daffffe8     	ble	0x9a538 <.text+0x8a438> @ imm = #-0x60
   9a594: e7d20003     	ldrb	r0, [r2, r3]
   9a598: e22000b7     	eor	r0, r0, #183
   9a59c: e7c20003     	strb	r0, [r2, r3]
   9a5a0: eaffffef     	b	0x9a564 <.text+0x8a464> @ imm = #-0x44
   9a5a4: 0054d9ed     	subseq	sp, r4, sp, ror #19
   9a5a8: 0054d98b     	subseq	sp, r4, r11, lsl #19
   9a5ac: 0054d987     	subseq	sp, r4, r7, lsl #19
   9a5b0: e59f3b94     	ldr	r3, [pc, #0xb94]        @ 0x9b14c <.text+0x8b04c>
   9a5b4: e3a02000     	mov	r2, #0
   9a5b8: e08f3003     	add	r3, pc, r3
   9a5bc: e7d30002     	ldrb	r0, [r3, r2]
   9a5c0: e22000e1     	eor	r0, r0, #225
   9a5c4: e7c30002     	strb	r0, [r3, r2]
   9a5c8: e2822001     	add	r2, r2, #1
   9a5cc: e3520030     	cmp	r2, #48
   9a5d0: 1afffff9     	bne	0x9a5bc <.text+0x8a4bc> @ imm = #-0x1c
   9a5d4: e3a02000     	mov	r2, #0
   9a5d8: e3520000     	cmp	r2, #0
   9a5dc: 1a000007     	bne	0x9a600 <.text+0x8a500> @ imm = #0x1c
   9a5e0: e59f3b68     	ldr	r3, [pc, #0xb68]        @ 0x9b150 <.text+0x8b050>
   9a5e4: e08f3003     	add	r3, pc, r3
   9a5e8: e7d30002     	ldrb	r0, [r3, r2]
   9a5ec: e2200086     	eor	r0, r0, #134
   9a5f0: e7c30002     	strb	r0, [r3, r2]
   9a5f4: e2822001     	add	r2, r2, #1
   9a5f8: e3520030     	cmp	r2, #48
   9a5fc: 1afffff9     	bne	0x9a5e8 <.text+0x8a4e8> @ imm = #-0x1c
   9a600: e3a02000     	mov	r2, #0
   9a604: e3520000     	cmp	r2, #0
   9a608: 1a000007     	bne	0x9a62c <.text+0x8a52c> @ imm = #0x1c
   9a60c: e59f3b40     	ldr	r3, [pc, #0xb40]        @ 0x9b154 <.text+0x8b054>
   9a610: e08f3003     	add	r3, pc, r3
   9a614: e7d30002     	ldrb	r0, [r3, r2]
   9a618: e22000d1     	eor	r0, r0, #209
   9a61c: e7c30002     	strb	r0, [r3, r2]
   9a620: e2822001     	add	r2, r2, #1
   9a624: e352002e     	cmp	r2, #46
   9a628: 1afffff9     	bne	0x9a614 <.text+0x8a514> @ imm = #-0x1c
   9a62c: e3a02000     	mov	r2, #0
   9a630: e3520000     	cmp	r2, #0
   9a634: 1a000007     	bne	0x9a658 <.text+0x8a558> @ imm = #0x1c
   9a638: e59f3b18     	ldr	r3, [pc, #0xb18]        @ 0x9b158 <.text+0x8b058>
   9a63c: e08f3003     	add	r3, pc, r3
   9a640: e7d30002     	ldrb	r0, [r3, r2]
   9a644: e2200075     	eor	r0, r0, #117
   9a648: e7c30002     	strb	r0, [r3, r2]
   9a64c: e2822001     	add	r2, r2, #1
   9a650: e352001c     	cmp	r2, #28
   9a654: 1afffff9     	bne	0x9a640 <.text+0x8a540> @ imm = #-0x1c
   9a658: e59e0000     	ldr	r0, [lr]
   9a65c: e2401001     	sub	r1, r0, #1
   9a660: e0000190     	mul	r0, r0, r1
   9a664: e3100001     	tst	r0, #1
   9a668: e59e0000     	ldr	r0, [lr]
   9a66c: e2401001     	sub	r1, r0, #1
   9a670: e0000190     	mul	r0, r0, r1
   9a674: e3100001     	tst	r0, #1
   9a678: 0a000002     	beq	0x9a688 <.text+0x8a588> @ imm = #0x8
   9a67c: e59c0000     	ldr	r0, [r12]
   9a680: e3500009     	cmp	r0, #9
   9a684: cafffff7     	bgt	0x9a668 <.text+0x8a568> @ imm = #-0x24
   9a688: e3a02000     	mov	r2, #0
   9a68c: e3520000     	cmp	r2, #0
   9a690: 1a000007     	bne	0x9a6b4 <.text+0x8a5b4> @ imm = #0x1c
   9a694: e59f3ac0     	ldr	r3, [pc, #0xac0]        @ 0x9b15c <.text+0x8b05c>
   9a698: e08f3003     	add	r3, pc, r3
   9a69c: e7d30002     	ldrb	r0, [r3, r2]
   9a6a0: e220000a     	eor	r0, r0, #10
   9a6a4: e7c30002     	strb	r0, [r3, r2]
   9a6a8: e2822001     	add	r2, r2, #1
   9a6ac: e352001e     	cmp	r2, #30
   9a6b0: 1afffff9     	bne	0x9a69c <.text+0x8a59c> @ imm = #-0x1c
   9a6b4: e3a02000     	mov	r2, #0
   9a6b8: e3520000     	cmp	r2, #0
   9a6bc: 1a000007     	bne	0x9a6e0 <.text+0x8a5e0> @ imm = #0x1c
   9a6c0: e59f3a98     	ldr	r3, [pc, #0xa98]        @ 0x9b160 <.text+0x8b060>
   9a6c4: e08f3003     	add	r3, pc, r3
   9a6c8: e7d30002     	ldrb	r0, [r3, r2]
   9a6cc: e220006b     	eor	r0, r0, #107
   9a6d0: e7c30002     	strb	r0, [r3, r2]
   9a6d4: e2822001     	add	r2, r2, #1
   9a6d8: e3520011     	cmp	r2, #17
   9a6dc: 1afffff9     	bne	0x9a6c8 <.text+0x8a5c8> @ imm = #-0x1c
   9a6e0: e3a02000     	mov	r2, #0
   9a6e4: e3520000     	cmp	r2, #0
   9a6e8: 1a00001f     	bne	0x9a76c <.text+0x8a66c> @ imm = #0x7c
   9a6ec: e59f3a70     	ldr	r3, [pc, #0xa70]        @ 0x9b164 <.text+0x8b064>
   9a6f0: e08f3003     	add	r3, pc, r3
   9a6f4: ea000004     	b	0x9a70c <.text+0x8a60c> @ imm = #0x10
   9a6f8: 0054d8f8     	ldrsheq	sp, [r4], #-136
   9a6fc: 0054d8e3     	subseq	sp, r4, r3, ror #17
   9a700: e3510016     	cmp	r1, #22
   9a704: e1a02001     	mov	r2, r1
   9a708: 0a000017     	beq	0x9a76c <.text+0x8a66c> @ imm = #0x5c
   9a70c: e59e0000     	ldr	r0, [lr]
   9a710: e2401001     	sub	r1, r0, #1
   9a714: e0000190     	mul	r0, r0, r1
   9a718: e3100001     	tst	r0, #1
   9a71c: 0a000002     	beq	0x9a72c <.text+0x8a62c> @ imm = #0x8
   9a720: e59c0000     	ldr	r0, [r12]
   9a724: e3500009     	cmp	r0, #9
   9a728: ca00000b     	bgt	0x9a75c <.text+0x8a65c> @ imm = #0x2c
   9a72c: e7d30002     	ldrb	r0, [r3, r2]
   9a730: e2200078     	eor	r0, r0, #120
   9a734: e7c30002     	strb	r0, [r3, r2]
   9a738: e59e0000     	ldr	r0, [lr]
   9a73c: e2401001     	sub	r1, r0, #1
   9a740: e0000190     	mul	r0, r0, r1
   9a744: e2821001     	add	r1, r2, #1
   9a748: e3100001     	tst	r0, #1
   9a74c: 0affffeb     	beq	0x9a700 <.text+0x8a600> @ imm = #-0x54
   9a750: e59c0000     	ldr	r0, [r12]
   9a754: e3500009     	cmp	r0, #9
   9a758: daffffe8     	ble	0x9a700 <.text+0x8a600> @ imm = #-0x60
   9a75c: e7d30002     	ldrb	r0, [r3, r2]
   9a760: e2200078     	eor	r0, r0, #120
   9a764: e7c30002     	strb	r0, [r3, r2]
   9a768: eaffffef     	b	0x9a72c <.text+0x8a62c> @ imm = #-0x44
   9a76c: e3a02000     	mov	r2, #0
   9a770: e3520000     	cmp	r2, #0
   9a774: 1a000007     	bne	0x9a798 <.text+0x8a698> @ imm = #0x1c
   9a778: e59f39e8     	ldr	r3, [pc, #0x9e8]        @ 0x9b168 <.text+0x8b068>
   9a77c: e08f3003     	add	r3, pc, r3
   9a780: e7d30002     	ldrb	r0, [r3, r2]
   9a784: e2200025     	eor	r0, r0, #37
   9a788: e7c30002     	strb	r0, [r3, r2]
   9a78c: e2822001     	add	r2, r2, #1
   9a790: e3520004     	cmp	r2, #4
   9a794: 1afffff9     	bne	0x9a780 <.text+0x8a680> @ imm = #-0x1c
   9a798: e3a02000     	mov	r2, #0
   9a79c: e3520000     	cmp	r2, #0
   9a7a0: 1a000007     	bne	0x9a7c4 <.text+0x8a6c4> @ imm = #0x1c
   9a7a4: e59f39c0     	ldr	r3, [pc, #0x9c0]        @ 0x9b16c <.text+0x8b06c>
   9a7a8: e08f3003     	add	r3, pc, r3
   9a7ac: e7d30002     	ldrb	r0, [r3, r2]
   9a7b0: e220006b     	eor	r0, r0, #107
   9a7b4: e7c30002     	strb	r0, [r3, r2]
   9a7b8: e2822001     	add	r2, r2, #1
   9a7bc: e3520034     	cmp	r2, #52
   9a7c0: 1afffff9     	bne	0x9a7ac <.text+0x8a6ac> @ imm = #-0x1c
   9a7c4: e3a02000     	mov	r2, #0
   9a7c8: e3520000     	cmp	r2, #0
   9a7cc: 1a000020     	bne	0x9a854 <.text+0x8a754> @ imm = #0x80
   9a7d0: e59f3998     	ldr	r3, [pc, #0x998]        @ 0x9b170 <.text+0x8b070>
   9a7d4: e08f3003     	add	r3, pc, r3
   9a7d8: ea000004     	b	0x9a7f0 <.text+0x8a6f0> @ imm = #0x10
   9a7dc: 0054d84d     	subseq	sp, r4, sp, asr #16
   9a7e0: 0054d839     	subseq	sp, r4, r9, lsr r8
   9a7e4: e351002a     	cmp	r1, #42
   9a7e8: e1a02001     	mov	r2, r1
   9a7ec: 0a000018     	beq	0x9a854 <.text+0x8a754> @ imm = #0x60
   9a7f0: e59e0000     	ldr	r0, [lr]
   9a7f4: e2401001     	sub	r1, r0, #1
   9a7f8: e0000190     	mul	r0, r0, r1
   9a7fc: e3100001     	tst	r0, #1
   9a800: 0a000002     	beq	0x9a810 <.text+0x8a710> @ imm = #0x8
   9a804: e59c0000     	ldr	r0, [r12]
   9a808: e3500009     	cmp	r0, #9
   9a80c: ca00000b     	bgt	0x9a840 <.text+0x8a740> @ imm = #0x2c
   9a810: e7d30002     	ldrb	r0, [r3, r2]
   9a814: e220001b     	eor	r0, r0, #27
   9a818: e7c30002     	strb	r0, [r3, r2]
   9a81c: e59e0000     	ldr	r0, [lr]
   9a820: e2401001     	sub	r1, r0, #1
   9a824: e0000190     	mul	r0, r0, r1
   9a828: e2821001     	add	r1, r2, #1
   9a82c: e3100001     	tst	r0, #1
   9a830: 0affffeb     	beq	0x9a7e4 <.text+0x8a6e4> @ imm = #-0x54
   9a834: e59c0000     	ldr	r0, [r12]
   9a838: e3500009     	cmp	r0, #9
   9a83c: daffffe8     	ble	0x9a7e4 <.text+0x8a6e4> @ imm = #-0x60
   9a840: e7d30002     	ldrb	r0, [r3, r2]
   9a844: e220001b     	eor	r0, r0, #27
   9a848: e7c30002     	strb	r0, [r3, r2]
   9a84c: eaffffef     	b	0x9a810 <.text+0x8a710> @ imm = #-0x44
   9a850: 0054d821     	subseq	sp, r4, r1, lsr #16
   9a854: e59e0000     	ldr	r0, [lr]
   9a858: e2401001     	sub	r1, r0, #1
   9a85c: e0000190     	mul	r0, r0, r1
   9a860: e3100001     	tst	r0, #1
   9a864: e59e0000     	ldr	r0, [lr]
   9a868: e2401001     	sub	r1, r0, #1
   9a86c: e0000190     	mul	r0, r0, r1
   9a870: e3100001     	tst	r0, #1
   9a874: 0a000002     	beq	0x9a884 <.text+0x8a784> @ imm = #0x8
   9a878: e59c0000     	ldr	r0, [r12]
   9a87c: e3500009     	cmp	r0, #9
   9a880: cafffff7     	bgt	0x9a864 <.text+0x8a764> @ imm = #-0x24
   9a884: e3a02000     	mov	r2, #0
   9a888: e3520000     	cmp	r2, #0
   9a88c: 1a00001e     	bne	0x9a90c <.text+0x8a80c> @ imm = #0x78
   9a890: e59f38dc     	ldr	r3, [pc, #0x8dc]        @ 0x9b174 <.text+0x8b074>
   9a894: e08f3003     	add	r3, pc, r3
   9a898: ea000003     	b	0x9a8ac <.text+0x8a7ac> @ imm = #0xc
   9a89c: 0054d7cd     	subseq	sp, r4, sp, asr #15
   9a8a0: e3510024     	cmp	r1, #36
   9a8a4: e1a02001     	mov	r2, r1
   9a8a8: 0a000017     	beq	0x9a90c <.text+0x8a80c> @ imm = #0x5c
   9a8ac: e59e0000     	ldr	r0, [lr]
   9a8b0: e2401001     	sub	r1, r0, #1
   9a8b4: e0000190     	mul	r0, r0, r1
   9a8b8: e3100001     	tst	r0, #1
   9a8bc: 0a000002     	beq	0x9a8cc <.text+0x8a7cc> @ imm = #0x8
   9a8c0: e59c0000     	ldr	r0, [r12]
   9a8c4: e3500009     	cmp	r0, #9
   9a8c8: ca00000b     	bgt	0x9a8fc <.text+0x8a7fc> @ imm = #0x2c
   9a8cc: e7d30002     	ldrb	r0, [r3, r2]
   9a8d0: e2200078     	eor	r0, r0, #120
   9a8d4: e7c30002     	strb	r0, [r3, r2]
   9a8d8: e59e0000     	ldr	r0, [lr]
   9a8dc: e2401001     	sub	r1, r0, #1
   9a8e0: e0000190     	mul	r0, r0, r1
   9a8e4: e2821001     	add	r1, r2, #1
   9a8e8: e3100001     	tst	r0, #1
   9a8ec: 0affffeb     	beq	0x9a8a0 <.text+0x8a7a0> @ imm = #-0x54
   9a8f0: e59c0000     	ldr	r0, [r12]
   9a8f4: e3500009     	cmp	r0, #9
   9a8f8: daffffe8     	ble	0x9a8a0 <.text+0x8a7a0> @ imm = #-0x60
   9a8fc: e7d30002     	ldrb	r0, [r3, r2]
   9a900: e2200078     	eor	r0, r0, #120
   9a904: e7c30002     	strb	r0, [r3, r2]
   9a908: eaffffef     	b	0x9a8cc <.text+0x8a7cc> @ imm = #-0x44
   9a90c: e3a02000     	mov	r2, #0
   9a910: e3520000     	cmp	r2, #0
   9a914: 1a000007     	bne	0x9a938 <.text+0x8a838> @ imm = #0x1c
   9a918: e59f3858     	ldr	r3, [pc, #0x858]        @ 0x9b178 <.text+0x8b078>
   9a91c: e08f3003     	add	r3, pc, r3
   9a920: e7d30002     	ldrb	r0, [r3, r2]
   9a924: e2200070     	eor	r0, r0, #112
   9a928: e7c30002     	strb	r0, [r3, r2]
   9a92c: e2822001     	add	r2, r2, #1
   9a930: e352002d     	cmp	r2, #45
   9a934: 1afffff9     	bne	0x9a920 <.text+0x8a820> @ imm = #-0x1c
   9a938: e3a02000     	mov	r2, #0
   9a93c: e3520000     	cmp	r2, #0
   9a940: 1a000007     	bne	0x9a964 <.text+0x8a864> @ imm = #0x1c
   9a944: e59f3830     	ldr	r3, [pc, #0x830]        @ 0x9b17c <.text+0x8b07c>
   9a948: e08f3003     	add	r3, pc, r3
   9a94c: e7d30002     	ldrb	r0, [r3, r2]
   9a950: e2200084     	eor	r0, r0, #132
   9a954: e7c30002     	strb	r0, [r3, r2]
   9a958: e2822001     	add	r2, r2, #1
   9a95c: e352002e     	cmp	r2, #46
   9a960: 1afffff9     	bne	0x9a94c <.text+0x8a84c> @ imm = #-0x1c
   9a964: e3a02000     	mov	r2, #0
   9a968: e3520000     	cmp	r2, #0
   9a96c: 1a00001f     	bne	0x9a9f0 <.text+0x8a8f0> @ imm = #0x7c
   9a970: e59f3808     	ldr	r3, [pc, #0x808]        @ 0x9b180 <.text+0x8b080>
   9a974: e08f3003     	add	r3, pc, r3
   9a978: ea000004     	b	0x9a990 <.text+0x8a890> @ imm = #0x10
   9a97c: 0054d737     	subseq	sp, r4, r7, lsr r7
   9a980: 0054d717     	subseq	sp, r4, r7, lsl r7
   9a984: e3510046     	cmp	r1, #70
   9a988: e1a02001     	mov	r2, r1
   9a98c: 0a000017     	beq	0x9a9f0 <.text+0x8a8f0> @ imm = #0x5c
   9a990: e59e0000     	ldr	r0, [lr]
   9a994: e2401001     	sub	r1, r0, #1
   9a998: e0000190     	mul	r0, r0, r1
   9a99c: e3100001     	tst	r0, #1
   9a9a0: 0a000002     	beq	0x9a9b0 <.text+0x8a8b0> @ imm = #0x8
   9a9a4: e59c0000     	ldr	r0, [r12]
   9a9a8: e3500009     	cmp	r0, #9
   9a9ac: ca00000b     	bgt	0x9a9e0 <.text+0x8a8e0> @ imm = #0x2c
   9a9b0: e7d30002     	ldrb	r0, [r3, r2]
   9a9b4: e22000d0     	eor	r0, r0, #208
   9a9b8: e7c30002     	strb	r0, [r3, r2]
   9a9bc: e59e0000     	ldr	r0, [lr]
   9a9c0: e2401001     	sub	r1, r0, #1
   9a9c4: e0000190     	mul	r0, r0, r1
   9a9c8: e2821001     	add	r1, r2, #1
   9a9cc: e3100001     	tst	r0, #1
   9a9d0: 0affffeb     	beq	0x9a984 <.text+0x8a884> @ imm = #-0x54
   9a9d4: e59c0000     	ldr	r0, [r12]
   9a9d8: e3500009     	cmp	r0, #9
   9a9dc: daffffe8     	ble	0x9a984 <.text+0x8a884> @ imm = #-0x60
   9a9e0: e7d30002     	ldrb	r0, [r3, r2]
   9a9e4: e22000d0     	eor	r0, r0, #208
   9a9e8: e7c30002     	strb	r0, [r3, r2]
   9a9ec: eaffffef     	b	0x9a9b0 <.text+0x8a8b0> @ imm = #-0x44
   9a9f0: e3a02000     	mov	r2, #0
   9a9f4: e3520000     	cmp	r2, #0
   9a9f8: 1a000021     	bne	0x9aa84 <.text+0x8a984> @ imm = #0x84
   9a9fc: e59f3780     	ldr	r3, [pc, #0x780]        @ 0x9b184 <.text+0x8b084>
   9aa00: e08f3003     	add	r3, pc, r3
   9aa04: ea000003     	b	0x9aa18 <.text+0x8a918> @ imm = #0xc
   9aa08: 0054d6bc     	ldrheq	sp, [r4], #-108
   9aa0c: e3510013     	cmp	r1, #19
   9aa10: e1a02001     	mov	r2, r1
   9aa14: 0a00001a     	beq	0x9aa84 <.text+0x8a984> @ imm = #0x68
   9aa18: e59e0000     	ldr	r0, [lr]
   9aa1c: e2401001     	sub	r1, r0, #1
   9aa20: e0000190     	mul	r0, r0, r1
   9aa24: e3100001     	tst	r0, #1
   9aa28: 0a000002     	beq	0x9aa38 <.text+0x8a938> @ imm = #0x8
   9aa2c: e59c0000     	ldr	r0, [r12]
   9aa30: e3500009     	cmp	r0, #9
   9aa34: ca00000b     	bgt	0x9aa68 <.text+0x8a968> @ imm = #0x2c
   9aa38: e7d30002     	ldrb	r0, [r3, r2]
   9aa3c: e22000c5     	eor	r0, r0, #197
   9aa40: e7c30002     	strb	r0, [r3, r2]
   9aa44: e59e0000     	ldr	r0, [lr]
   9aa48: e2401001     	sub	r1, r0, #1
   9aa4c: e0000190     	mul	r0, r0, r1
   9aa50: e2821001     	add	r1, r2, #1
   9aa54: e3100001     	tst	r0, #1
   9aa58: 0affffeb     	beq	0x9aa0c <.text+0x8a90c> @ imm = #-0x54
   9aa5c: e59c0000     	ldr	r0, [r12]
   9aa60: e3500009     	cmp	r0, #9
   9aa64: daffffe8     	ble	0x9aa0c <.text+0x8a90c> @ imm = #-0x60
   9aa68: e7d30002     	ldrb	r0, [r3, r2]
   9aa6c: e22000c5     	eor	r0, r0, #197
   9aa70: e7c30002     	strb	r0, [r3, r2]
   9aa74: eaffffef     	b	0x9aa38 <.text+0x8a938> @ imm = #-0x44
   9aa78: 0054d6a5     	subseq	sp, r4, r5, lsr #13
   9aa7c: 0054d64a     	subseq	sp, r4, r10, asr #12
   9aa80: 0054d642     	subseq	sp, r4, r2, asr #12
   9aa84: e59f36fc     	ldr	r3, [pc, #0x6fc]        @ 0x9b188 <.text+0x8b088>
   9aa88: e3a02000     	mov	r2, #0
   9aa8c: e08f3003     	add	r3, pc, r3
   9aa90: e7d30002     	ldrb	r0, [r3, r2]
   9aa94: e220005b     	eor	r0, r0, #91
   9aa98: e7c30002     	strb	r0, [r3, r2]
   9aa9c: e2822001     	add	r2, r2, #1
   9aaa0: e352000a     	cmp	r2, #10
   9aaa4: 1afffff9     	bne	0x9aa90 <.text+0x8a990> @ imm = #-0x1c
   9aaa8: e59f36dc     	ldr	r3, [pc, #0x6dc]        @ 0x9b18c <.text+0x8b08c>
   9aaac: e3a02000     	mov	r2, #0
   9aab0: e08f3003     	add	r3, pc, r3
   9aab4: e7d30002     	ldrb	r0, [r3, r2]
   9aab8: e220009c     	eor	r0, r0, #156
   9aabc: e7c30002     	strb	r0, [r3, r2]
   9aac0: e2822001     	add	r2, r2, #1
   9aac4: e352000a     	cmp	r2, #10
   9aac8: 1afffff9     	bne	0x9aab4 <.text+0x8a9b4> @ imm = #-0x1c
   9aacc: e3a02000     	mov	r2, #0
   9aad0: e3520000     	cmp	r2, #0
   9aad4: 1a000007     	bne	0x9aaf8 <.text+0x8a9f8> @ imm = #0x1c
   9aad8: e59f36b0     	ldr	r3, [pc, #0x6b0]        @ 0x9b190 <.text+0x8b090>
   9aadc: e08f3003     	add	r3, pc, r3
   9aae0: e7d30002     	ldrb	r0, [r3, r2]
   9aae4: e2200032     	eor	r0, r0, #50
   9aae8: e7c30002     	strb	r0, [r3, r2]
   9aaec: e2822001     	add	r2, r2, #1
   9aaf0: e352000a     	cmp	r2, #10
   9aaf4: 1afffff9     	bne	0x9aae0 <.text+0x8a9e0> @ imm = #-0x1c
   9aaf8: e59e0000     	ldr	r0, [lr]
   9aafc: e2401001     	sub	r1, r0, #1
   9ab00: e0000190     	mul	r0, r0, r1
   9ab04: e3100001     	tst	r0, #1
   9ab08: e59e0000     	ldr	r0, [lr]
   9ab0c: e2401001     	sub	r1, r0, #1
   9ab10: e0000190     	mul	r0, r0, r1
   9ab14: e3100001     	tst	r0, #1
   9ab18: 0a000002     	beq	0x9ab28 <.text+0x8aa28> @ imm = #0x8
   9ab1c: e59c0000     	ldr	r0, [r12]
   9ab20: e3500009     	cmp	r0, #9
   9ab24: cafffff7     	bgt	0x9ab08 <.text+0x8aa08> @ imm = #-0x24
   9ab28: e3a02000     	mov	r2, #0
   9ab2c: e3520000     	cmp	r2, #0
   9ab30: 1a000007     	bne	0x9ab54 <.text+0x8aa54> @ imm = #0x1c
   9ab34: e59f3658     	ldr	r3, [pc, #0x658]        @ 0x9b194 <.text+0x8b094>
   9ab38: e08f3003     	add	r3, pc, r3
   9ab3c: e7d30002     	ldrb	r0, [r3, r2]
   9ab40: e22000da     	eor	r0, r0, #218
   9ab44: e7c30002     	strb	r0, [r3, r2]
   9ab48: e2822001     	add	r2, r2, #1
   9ab4c: e3520065     	cmp	r2, #101
   9ab50: 1afffff9     	bne	0x9ab3c <.text+0x8aa3c> @ imm = #-0x1c
   9ab54: e59e0000     	ldr	r0, [lr]
   9ab58: e2401001     	sub	r1, r0, #1
   9ab5c: e0000190     	mul	r0, r0, r1
   9ab60: e3100001     	tst	r0, #1
   9ab64: e59e0000     	ldr	r0, [lr]
   9ab68: e2401001     	sub	r1, r0, #1
   9ab6c: e0000190     	mul	r0, r0, r1
   9ab70: e3100001     	tst	r0, #1
   9ab74: 0a000002     	beq	0x9ab84 <.text+0x8aa84> @ imm = #0x8
   9ab78: e59c0000     	ldr	r0, [r12]
   9ab7c: e3500009     	cmp	r0, #9
   9ab80: cafffff7     	bgt	0x9ab64 <.text+0x8aa64> @ imm = #-0x24
   9ab84: e3a02000     	mov	r2, #0
   9ab88: e3520000     	cmp	r2, #0
   9ab8c: 1a00001f     	bne	0x9ac10 <.text+0x8ab10> @ imm = #0x7c
   9ab90: e59f3600     	ldr	r3, [pc, #0x600]        @ 0x9b198 <.text+0x8b098>
   9ab94: e08f3003     	add	r3, pc, r3
   9ab98: ea000004     	b	0x9abb0 <.text+0x8aab0> @ imm = #0x10
   9ab9c: 0054d5c9     	subseq	sp, r4, r9, asr #11
   9aba0: 0054d5c4     	subseq	sp, r4, r4, asr #11
   9aba4: e351002f     	cmp	r1, #47
   9aba8: e1a02001     	mov	r2, r1
   9abac: 0a000017     	beq	0x9ac10 <.text+0x8ab10> @ imm = #0x5c
   9abb0: e59e0000     	ldr	r0, [lr]
   9abb4: e2401001     	sub	r1, r0, #1
   9abb8: e0000190     	mul	r0, r0, r1
   9abbc: e3100001     	tst	r0, #1
   9abc0: 0a000002     	beq	0x9abd0 <.text+0x8aad0> @ imm = #0x8
   9abc4: e59c0000     	ldr	r0, [r12]
   9abc8: e3500009     	cmp	r0, #9
   9abcc: ca00000b     	bgt	0x9ac00 <.text+0x8ab00> @ imm = #0x2c
   9abd0: e7d30002     	ldrb	r0, [r3, r2]
   9abd4: e22000d0     	eor	r0, r0, #208
   9abd8: e7c30002     	strb	r0, [r3, r2]
   9abdc: e59e0000     	ldr	r0, [lr]
   9abe0: e2401001     	sub	r1, r0, #1
   9abe4: e0000190     	mul	r0, r0, r1
   9abe8: e2821001     	add	r1, r2, #1
   9abec: e3100001     	tst	r0, #1
   9abf0: 0affffeb     	beq	0x9aba4 <.text+0x8aaa4> @ imm = #-0x54
   9abf4: e59c0000     	ldr	r0, [r12]
   9abf8: e3500009     	cmp	r0, #9
   9abfc: daffffe8     	ble	0x9aba4 <.text+0x8aaa4> @ imm = #-0x60
   9ac00: e7d30002     	ldrb	r0, [r3, r2]
   9ac04: e22000d0     	eor	r0, r0, #208
   9ac08: e7c30002     	strb	r0, [r3, r2]
   9ac0c: eaffffef     	b	0x9abd0 <.text+0x8aad0> @ imm = #-0x44
   9ac10: e3a02000     	mov	r2, #0
   9ac14: e3520000     	cmp	r2, #0
   9ac18: 1a000021     	bne	0x9aca4 <.text+0x8aba4> @ imm = #0x84
   9ac1c: e59f3578     	ldr	r3, [pc, #0x578]        @ 0x9b19c <.text+0x8b09c>
   9ac20: e08f3003     	add	r3, pc, r3
   9ac24: ea000003     	b	0x9ac38 <.text+0x8ab38> @ imm = #0xc
   9ac28: 0054d557     	subseq	sp, r4, r7, asr r5
   9ac2c: e3510032     	cmp	r1, #50
   9ac30: e1a02001     	mov	r2, r1
   9ac34: 0a00001a     	beq	0x9aca4 <.text+0x8aba4> @ imm = #0x68
   9ac38: e59e0000     	ldr	r0, [lr]
   9ac3c: e2401001     	sub	r1, r0, #1
   9ac40: e0000190     	mul	r0, r0, r1
   9ac44: e3100001     	tst	r0, #1
   9ac48: 0a000002     	beq	0x9ac58 <.text+0x8ab58> @ imm = #0x8
   9ac4c: e59c0000     	ldr	r0, [r12]
   9ac50: e3500009     	cmp	r0, #9
   9ac54: ca00000b     	bgt	0x9ac88 <.text+0x8ab88> @ imm = #0x2c
   9ac58: e7d30002     	ldrb	r0, [r3, r2]
   9ac5c: e2200053     	eor	r0, r0, #83
   9ac60: e7c30002     	strb	r0, [r3, r2]
   9ac64: e59e0000     	ldr	r0, [lr]
   9ac68: e2401001     	sub	r1, r0, #1
   9ac6c: e0000190     	mul	r0, r0, r1
   9ac70: e2821001     	add	r1, r2, #1
   9ac74: e3100001     	tst	r0, #1
   9ac78: 0affffeb     	beq	0x9ac2c <.text+0x8ab2c> @ imm = #-0x54
   9ac7c: e59c0000     	ldr	r0, [r12]
   9ac80: e3500009     	cmp	r0, #9
   9ac84: daffffe8     	ble	0x9ac2c <.text+0x8ab2c> @ imm = #-0x60
   9ac88: e7d30002     	ldrb	r0, [r3, r2]
   9ac8c: e2200053     	eor	r0, r0, #83
   9ac90: e7c30002     	strb	r0, [r3, r2]
   9ac94: eaffffef     	b	0x9ac58 <.text+0x8ab58> @ imm = #-0x44
   9ac98: 0054d50f     	subseq	sp, r4, pc, lsl #10
   9ac9c: 0054d502     	subseq	sp, r4, r2, lsl #10
   9aca0: 0054d4a6     	subseq	sp, r4, r6, lsr #9
   9aca4: e59e0000     	ldr	r0, [lr]
   9aca8: e2401001     	sub	r1, r0, #1
   9acac: e0000190     	mul	r0, r0, r1
   9acb0: e3100001     	tst	r0, #1
   9acb4: e59e0000     	ldr	r0, [lr]
   9acb8: e2401001     	sub	r1, r0, #1
   9acbc: e0000190     	mul	r0, r0, r1
   9acc0: e3100001     	tst	r0, #1
   9acc4: 0a000002     	beq	0x9acd4 <.text+0x8abd4> @ imm = #0x8
   9acc8: e59c0000     	ldr	r0, [r12]
   9accc: e3500009     	cmp	r0, #9
   9acd0: cafffff7     	bgt	0x9acb4 <.text+0x8abb4> @ imm = #-0x24
   9acd4: e3a02000     	mov	r2, #0
   9acd8: e3520000     	cmp	r2, #0
   9acdc: 1a000007     	bne	0x9ad00 <.text+0x8ac00> @ imm = #0x1c
   9ace0: e59f34b8     	ldr	r3, [pc, #0x4b8]        @ 0x9b1a0 <.text+0x8b0a0>
   9ace4: e08f3003     	add	r3, pc, r3
   9ace8: e7d30002     	ldrb	r0, [r3, r2]
   9acec: e22000ba     	eor	r0, r0, #186
   9acf0: e7c30002     	strb	r0, [r3, r2]
   9acf4: e2822001     	add	r2, r2, #1
   9acf8: e3520032     	cmp	r2, #50
   9acfc: 1afffff9     	bne	0x9ace8 <.text+0x8abe8> @ imm = #-0x1c
   9ad00: e3a02000     	mov	r2, #0
   9ad04: e3520000     	cmp	r2, #0
   9ad08: 1a000007     	bne	0x9ad2c <.text+0x8ac2c> @ imm = #0x1c
   9ad0c: e59f3490     	ldr	r3, [pc, #0x490]        @ 0x9b1a4 <.text+0x8b0a4>
   9ad10: e08f3003     	add	r3, pc, r3
   9ad14: e7d30002     	ldrb	r0, [r3, r2]
   9ad18: e22000dd     	eor	r0, r0, #221
   9ad1c: e7c30002     	strb	r0, [r3, r2]
   9ad20: e2822001     	add	r2, r2, #1
   9ad24: e3520039     	cmp	r2, #57
   9ad28: 1afffff9     	bne	0x9ad14 <.text+0x8ac14> @ imm = #-0x1c
   9ad2c: e3a02000     	mov	r2, #0
   9ad30: e3520000     	cmp	r2, #0
   9ad34: 1a000007     	bne	0x9ad58 <.text+0x8ac58> @ imm = #0x1c
   9ad38: e59f3468     	ldr	r3, [pc, #0x468]        @ 0x9b1a8 <.text+0x8b0a8>
   9ad3c: e08f3003     	add	r3, pc, r3
   9ad40: e7d30002     	ldrb	r0, [r3, r2]
   9ad44: e22000dc     	eor	r0, r0, #220
   9ad48: e7c30002     	strb	r0, [r3, r2]
   9ad4c: e2822001     	add	r2, r2, #1
   9ad50: e3520023     	cmp	r2, #35
   9ad54: 1afffff9     	bne	0x9ad40 <.text+0x8ac40> @ imm = #-0x1c
   9ad58: e3a02000     	mov	r2, #0
   9ad5c: e3520000     	cmp	r2, #0
   9ad60: 1a000007     	bne	0x9ad84 <.text+0x8ac84> @ imm = #0x1c
   9ad64: e59f3440     	ldr	r3, [pc, #0x440]        @ 0x9b1ac <.text+0x8b0ac>
   9ad68: e08f3003     	add	r3, pc, r3
   9ad6c: e7d30002     	ldrb	r0, [r3, r2]
   9ad70: e220005a     	eor	r0, r0, #90
   9ad74: e7c30002     	strb	r0, [r3, r2]
   9ad78: e2822001     	add	r2, r2, #1
   9ad7c: e3520020     	cmp	r2, #32
   9ad80: 1afffff9     	bne	0x9ad6c <.text+0x8ac6c> @ imm = #-0x1c
   9ad84: e3a02000     	mov	r2, #0
   9ad88: e3520000     	cmp	r2, #0
   9ad8c: 1a00001f     	bne	0x9ae10 <.text+0x8ad10> @ imm = #0x7c
   9ad90: e59f3418     	ldr	r3, [pc, #0x418]        @ 0x9b1b0 <.text+0x8b0b0>
   9ad94: e08f3003     	add	r3, pc, r3
   9ad98: ea000003     	b	0x9adac <.text+0x8acac> @ imm = #0xc
   9ad9c: 0054d47f     	subseq	sp, r4, pc, ror r4
   9ada0: e3510029     	cmp	r1, #41
   9ada4: e1a02001     	mov	r2, r1
   9ada8: 0a000018     	beq	0x9ae10 <.text+0x8ad10> @ imm = #0x60
   9adac: e59e0000     	ldr	r0, [lr]
   9adb0: e2401001     	sub	r1, r0, #1
   9adb4: e0000190     	mul	r0, r0, r1
   9adb8: e3100001     	tst	r0, #1
   9adbc: 0a000002     	beq	0x9adcc <.text+0x8accc> @ imm = #0x8
   9adc0: e59c0000     	ldr	r0, [r12]
   9adc4: e3500009     	cmp	r0, #9
   9adc8: ca00000b     	bgt	0x9adfc <.text+0x8acfc> @ imm = #0x2c
   9adcc: e7d30002     	ldrb	r0, [r3, r2]
   9add0: e22000dc     	eor	r0, r0, #220
   9add4: e7c30002     	strb	r0, [r3, r2]
   9add8: e59e0000     	ldr	r0, [lr]
   9addc: e2401001     	sub	r1, r0, #1
   9ade0: e0000190     	mul	r0, r0, r1
   9ade4: e2821001     	add	r1, r2, #1
   9ade8: e3100001     	tst	r0, #1
   9adec: 0affffeb     	beq	0x9ada0 <.text+0x8aca0> @ imm = #-0x54
   9adf0: e59c0000     	ldr	r0, [r12]
   9adf4: e3500009     	cmp	r0, #9
   9adf8: daffffe8     	ble	0x9ada0 <.text+0x8aca0> @ imm = #-0x60
   9adfc: e7d30002     	ldrb	r0, [r3, r2]
   9ae00: e22000dc     	eor	r0, r0, #220
   9ae04: e7c30002     	strb	r0, [r3, r2]
   9ae08: eaffffef     	b	0x9adcc <.text+0x8accc> @ imm = #-0x44
   9ae0c: 0054d408     	subseq	sp, r4, r8, lsl #8
   9ae10: e3a02000     	mov	r2, #0
   9ae14: e3520000     	cmp	r2, #0
   9ae18: 1a000007     	bne	0x9ae3c <.text+0x8ad3c> @ imm = #0x1c
   9ae1c: e59f3390     	ldr	r3, [pc, #0x390]        @ 0x9b1b4 <.text+0x8b0b4>
   9ae20: e08f3003     	add	r3, pc, r3
   9ae24: e7d30002     	ldrb	r0, [r3, r2]
   9ae28: e2200010     	eor	r0, r0, #16
   9ae2c: e7c30002     	strb	r0, [r3, r2]
   9ae30: e2822001     	add	r2, r2, #1
   9ae34: e352001b     	cmp	r2, #27
   9ae38: 1afffff9     	bne	0x9ae24 <.text+0x8ad24> @ imm = #-0x1c
   9ae3c: e3a02000     	mov	r2, #0
   9ae40: e3520000     	cmp	r2, #0
   9ae44: 1a000007     	bne	0x9ae68 <.text+0x8ad68> @ imm = #0x1c
   9ae48: e59f3368     	ldr	r3, [pc, #0x368]        @ 0x9b1b8 <.text+0x8b0b8>
   9ae4c: e08f3003     	add	r3, pc, r3
   9ae50: e7d30002     	ldrb	r0, [r3, r2]
   9ae54: e2200052     	eor	r0, r0, #82
   9ae58: e7c30002     	strb	r0, [r3, r2]
   9ae5c: e2822001     	add	r2, r2, #1
   9ae60: e3520017     	cmp	r2, #23
   9ae64: 1afffff9     	bne	0x9ae50 <.text+0x8ad50> @ imm = #-0x1c
   9ae68: e3a02000     	mov	r2, #0
   9ae6c: e3520000     	cmp	r2, #0
   9ae70: 1a000007     	bne	0x9ae94 <.text+0x8ad94> @ imm = #0x1c
   9ae74: e59f3340     	ldr	r3, [pc, #0x340]        @ 0x9b1bc <.text+0x8b0bc>
   9ae78: e08f3003     	add	r3, pc, r3
   9ae7c: e7d30002     	ldrb	r0, [r3, r2]
   9ae80: e220000d     	eor	r0, r0, #13
   9ae84: e7c30002     	strb	r0, [r3, r2]
   9ae88: e2822001     	add	r2, r2, #1
   9ae8c: e3520025     	cmp	r2, #37
   9ae90: 1afffff9     	bne	0x9ae7c <.text+0x8ad7c> @ imm = #-0x1c
   9ae94: e3a02000     	mov	r2, #0
   9ae98: e3520000     	cmp	r2, #0
   9ae9c: 1a000007     	bne	0x9aec0 <.text+0x8adc0> @ imm = #0x1c
   9aea0: e59f3318     	ldr	r3, [pc, #0x318]        @ 0x9b1c0 <.text+0x8b0c0>
   9aea4: e08f3003     	add	r3, pc, r3
   9aea8: e7d30002     	ldrb	r0, [r3, r2]
   9aeac: e22000f0     	eor	r0, r0, #240
   9aeb0: e7c30002     	strb	r0, [r3, r2]
   9aeb4: e2822001     	add	r2, r2, #1
   9aeb8: e3520009     	cmp	r2, #9
   9aebc: 1afffff9     	bne	0x9aea8 <.text+0x8ada8> @ imm = #-0x1c
   9aec0: e3a02000     	mov	r2, #0
   9aec4: e3520000     	cmp	r2, #0
   9aec8: 1a000020     	bne	0x9af50 <.text+0x8ae50> @ imm = #0x80
   9aecc: e59f32f0     	ldr	r3, [pc, #0x2f0]        @ 0x9b1c4 <.text+0x8b0c4>
   9aed0: e08f3003     	add	r3, pc, r3
   9aed4: ea000003     	b	0x9aee8 <.text+0x8ade8> @ imm = #0xc
   9aed8: 0054d34f     	subseq	sp, r4, pc, asr #6
   9aedc: e351000b     	cmp	r1, #11
   9aee0: e1a02001     	mov	r2, r1
   9aee4: 0a000019     	beq	0x9af50 <.text+0x8ae50> @ imm = #0x64
   9aee8: e59e0000     	ldr	r0, [lr]
   9aeec: e2401001     	sub	r1, r0, #1
   9aef0: e0000190     	mul	r0, r0, r1
   9aef4: e3100001     	tst	r0, #1
   9aef8: 0a000002     	beq	0x9af08 <.text+0x8ae08> @ imm = #0x8
   9aefc: e59c0000     	ldr	r0, [r12]
   9af00: e3500009     	cmp	r0, #9
   9af04: ca00000b     	bgt	0x9af38 <.text+0x8ae38> @ imm = #0x2c
   9af08: e7d30002     	ldrb	r0, [r3, r2]
   9af0c: e22000de     	eor	r0, r0, #222
   9af10: e7c30002     	strb	r0, [r3, r2]
   9af14: e59e0000     	ldr	r0, [lr]
   9af18: e2401001     	sub	r1, r0, #1
   9af1c: e0000190     	mul	r0, r0, r1
   9af20: e2821001     	add	r1, r2, #1
   9af24: e3100001     	tst	r0, #1
   9af28: 0affffeb     	beq	0x9aedc <.text+0x8addc> @ imm = #-0x54
   9af2c: e59c0000     	ldr	r0, [r12]
   9af30: e3500009     	cmp	r0, #9
   9af34: daffffe8     	ble	0x9aedc <.text+0x8addc> @ imm = #-0x60
   9af38: e7d30002     	ldrb	r0, [r3, r2]
   9af3c: e22000de     	eor	r0, r0, #222
   9af40: e7c30002     	strb	r0, [r3, r2]
   9af44: eaffffef     	b	0x9af08 <.text+0x8ae08> @ imm = #-0x44
   9af48: 0054d2d0     	ldrsbeq	sp, [r4], #-32
   9af4c: 0054d2a9     	subseq	sp, r4, r9, lsr #5
   9af50: e59e0000     	ldr	r0, [lr]
   9af54: e2401001     	sub	r1, r0, #1
   9af58: e0000190     	mul	r0, r0, r1
   9af5c: e3100001     	tst	r0, #1
   9af60: e59e0000     	ldr	r0, [lr]
   9af64: e2401001     	sub	r1, r0, #1
   9af68: e0000190     	mul	r0, r0, r1
   9af6c: e3100001     	tst	r0, #1
   9af70: 0a000002     	beq	0x9af80 <.text+0x8ae80> @ imm = #0x8
   9af74: e59c0000     	ldr	r0, [r12]
   9af78: e3500009     	cmp	r0, #9
   9af7c: cafffff7     	bgt	0x9af60 <.text+0x8ae60> @ imm = #-0x24
   9af80: e3a02000     	mov	r2, #0
   9af84: e3520000     	cmp	r2, #0
   9af88: 1a000007     	bne	0x9afac <.text+0x8aeac> @ imm = #0x1c
   9af8c: e59f3234     	ldr	r3, [pc, #0x234]        @ 0x9b1c8 <.text+0x8b0c8>
   9af90: e08f3003     	add	r3, pc, r3
   9af94: e7d30002     	ldrb	r0, [r3, r2]
   9af98: e22000ed     	eor	r0, r0, #237
   9af9c: e7c30002     	strb	r0, [r3, r2]
   9afa0: e2822001     	add	r2, r2, #1
   9afa4: e3520021     	cmp	r2, #33
   9afa8: 1afffff9     	bne	0x9af94 <.text+0x8ae94> @ imm = #-0x1c
   9afac: e3a02000     	mov	r2, #0
   9afb0: e3520000     	cmp	r2, #0
   9afb4: 1a000021     	bne	0x9b040 <.text+0x8af40> @ imm = #0x84
   9afb8: e59f320c     	ldr	r3, [pc, #0x20c]        @ 0x9b1cc <.text+0x8b0cc>
   9afbc: e08f3003     	add	r3, pc, r3
   9afc0: ea000004     	b	0x9afd8 <.text+0x8aed8> @ imm = #0x10
   9afc4: 0054d284     	subseq	sp, r4, r4, lsl #5
   9afc8: 0054d26c     	subseq	sp, r4, r12, ror #4
   9afcc: e3510011     	cmp	r1, #17
   9afd0: e1a02001     	mov	r2, r1
   9afd4: 0a000019     	beq	0x9b040 <.text+0x8af40> @ imm = #0x64
   9afd8: e59e0000     	ldr	r0, [lr]
   9afdc: e2401001     	sub	r1, r0, #1
   9afe0: e0000190     	mul	r0, r0, r1
   9afe4: e3100001     	tst	r0, #1
   9afe8: 0a000002     	beq	0x9aff8 <.text+0x8aef8> @ imm = #0x8
   9afec: e59c0000     	ldr	r0, [r12]
   9aff0: e3500009     	cmp	r0, #9
   9aff4: ca00000b     	bgt	0x9b028 <.text+0x8af28> @ imm = #0x2c
   9aff8: e7d30002     	ldrb	r0, [r3, r2]
   9affc: e22000d6     	eor	r0, r0, #214
   9b000: e7c30002     	strb	r0, [r3, r2]
   9b004: e59e0000     	ldr	r0, [lr]
   9b008: e2401001     	sub	r1, r0, #1
   9b00c: e0000190     	mul	r0, r0, r1
   9b010: e2821001     	add	r1, r2, #1
   9b014: e3100001     	tst	r0, #1
   9b018: 0affffeb     	beq	0x9afcc <.text+0x8aecc> @ imm = #-0x54
   9b01c: e59c0000     	ldr	r0, [r12]
   9b020: e3500009     	cmp	r0, #9
   9b024: daffffe8     	ble	0x9afcc <.text+0x8aecc> @ imm = #-0x60
   9b028: e7d30002     	ldrb	r0, [r3, r2]
   9b02c: e22000d6     	eor	r0, r0, #214
   9b030: e7c30002     	strb	r0, [r3, r2]
   9b034: eaffffef     	b	0x9aff8 <.text+0x8aef8> @ imm = #-0x44
   9b038: 0054d1c8     	subseq	sp, r4, r8, asr #3
   9b03c: 0054d1b2     	ldrheq	sp, [r4], #-18
   9b040: e3a02000     	mov	r2, #0
   9b044: e3520000     	cmp	r2, #0
   9b048: 1a000007     	bne	0x9b06c <.text+0x8af6c> @ imm = #0x1c
   9b04c: e59f317c     	ldr	r3, [pc, #0x17c]        @ 0x9b1d0 <.text+0x8b0d0>
   9b050: e08f3003     	add	r3, pc, r3
   9b054: e7d30002     	ldrb	r0, [r3, r2]
   9b058: e2200099     	eor	r0, r0, #153
   9b05c: e7c30002     	strb	r0, [r3, r2]
   9b060: e2822001     	add	r2, r2, #1
   9b064: e3520005     	cmp	r2, #5
   9b068: 1afffff9     	bne	0x9b054 <.text+0x8af54> @ imm = #-0x1c
   9b06c: e3a02000     	mov	r2, #0
   9b070: e3520000     	cmp	r2, #0
   9b074: 1a000007     	bne	0x9b098 <.text+0x8af98> @ imm = #0x1c
   9b078: e59f3154     	ldr	r3, [pc, #0x154]        @ 0x9b1d4 <.text+0x8b0d4>
   9b07c: e08f3003     	add	r3, pc, r3
   9b080: e7d30002     	ldrb	r0, [r3, r2]
   9b084: e2200039     	eor	r0, r0, #57
   9b088: e7c30002     	strb	r0, [r3, r2]
   9b08c: e2822001     	add	r2, r2, #1
   9b090: e3520016     	cmp	r2, #22
   9b094: 1afffff9     	bne	0x9b080 <.text+0x8af80> @ imm = #-0x1c
   9b098: e59e0000     	ldr	r0, [lr]
   9b09c: e2401001     	sub	r1, r0, #1
   9b0a0: e0000190     	mul	r0, r0, r1
   9b0a4: e3100001     	tst	r0, #1
   9b0a8: e59e0000     	ldr	r0, [lr]
   9b0ac: e2401001     	sub	r1, r0, #1
   9b0b0: e0000190     	mul	r0, r0, r1
   9b0b4: e3100001     	tst	r0, #1
   9b0b8: 0a000002     	beq	0x9b0c8 <.text+0x8afc8> @ imm = #0x8
   9b0bc: e59c0000     	ldr	r0, [r12]
   9b0c0: e3500009     	cmp	r0, #9
   9b0c4: cafffff7     	bgt	0x9b0a8 <.text+0x8afa8> @ imm = #-0x24
   9b0c8: e3a02000     	mov	r2, #0
   9b0cc: e3520000     	cmp	r2, #0
   9b0d0: 1a000007     	bne	0x9b0f4 <.text+0x8aff4> @ imm = #0x1c
   9b0d4: e59f30fc     	ldr	r3, [pc, #0xfc]         @ 0x9b1d8 <.text+0x8b0d8>
   9b0d8: e08f3003     	add	r3, pc, r3
   9b0dc: e7d30002     	ldrb	r0, [r3, r2]
   9b0e0: e2200093     	eor	r0, r0, #147
   9b0e4: e7c30002     	strb	r0, [r3, r2]
   9b0e8: e2822001     	add	r2, r2, #1
   9b0ec: e3520011     	cmp	r2, #17
   9b0f0: 1afffff9     	bne	0x9b0dc <.text+0x8afdc> @ imm = #-0x1c
   9b0f4: e59e0000     	ldr	r0, [lr]
   9b0f8: e2401001     	sub	r1, r0, #1
   9b0fc: e0000190     	mul	r0, r0, r1
   9b100: e3100001     	tst	r0, #1
   9b104: 08bd8800     	popeq	{r11, pc}
   9b108: e59c0000     	ldr	r0, [r12]
   9b10c: e3500009     	cmp	r0, #9
   9b110: cafffff7     	bgt	0x9b0f4 <.text+0x8aff4> @ imm = #-0x24
   9b114: e8bd8800     	pop	{r11, pc}
   9b118: 0054d180     	subseq	sp, r4, r0, lsl #3
   9b11c: 0054d131     	subseq	sp, r4, r1, lsr r1
   9b120: 0054d0ac     	subseq	sp, r4, r12, lsr #1
   9b124: 0054d026     	subseq	sp, r4, r6, lsr #32
   9b128: 0054d019     	subseq	sp, r4, r9, lsl r0
   9b12c: 0054cf5b     	subseq	r12, r4, r11, asr pc
   9b130: 0054cf54     	subseq	r12, r4, r4, asr pc
   9b134: 0054cf41     	subseq	r12, r4, r1, asr #30
   9b138: 0054cf47     	subseq	r12, r4, r7, asr #30
   9b13c: 0054cf3f     	subseq	r12, r4, pc, lsr pc
   9b140: 0054cf37     	subseq	r12, r4, r7, lsr pc
   9b144: 0054cf15     	subseq	r12, r4, r5, lsl pc
   9b148: 0054cebc     	ldrheq	r12, [r4], #-236
   9b14c: 0054ce60     	subseq	r12, r4, r0, ror #28
   9b150: 0054ce64     	subseq	r12, r4, r4, ror #28
   9b154: 0054ce68     	subseq	r12, r4, r8, ror #28
   9b158: 0054ce6a     	subseq	r12, r4, r10, ror #28
   9b15c: 0054ce2a     	subseq	r12, r4, r10, lsr #28
   9b160: 0054ce1c     	subseq	r12, r4, r12, lsl lr
   9b164: 0054ce01     	subseq	r12, r4, r1, lsl #28
   9b168: 0054cd8b     	subseq	r12, r4, r11, lsl #27
   9b16c: 0054cd63     	subseq	r12, r4, r3, ror #26
   9b170: 0054cd6b     	subseq	r12, r4, r11, ror #26
   9b174: 0054ccd5     	ldrsbeq	r12, [r4], #-197
   9b178: 0054cc71     	subseq	r12, r4, r1, ror r12
   9b17c: 0054cc72     	subseq	r12, r4, r2, ror r12
   9b180: 0054cc74     	subseq	r12, r4, r4, ror r12
   9b184: 0054cc2e     	subseq	r12, r4, lr, lsr #24
   9b188: 0054cbb5     	ldrheq	r12, [r4], #-181
   9b18c: 0054cb9b     	<unknown>
   9b190: 0054cb79     	subseq	r12, r4, r9, ror r11
   9b194: 0054cb27     	subseq	r12, r4, r7, lsr #22
   9b198: 0054cb30     	subseq	r12, r4, r0, lsr r11
   9b19c: 0054cad3     	ldrsbeq	r12, [r4], #-163
   9b1a0: 0054ca41     	subseq	r12, r4, r1, asr #20
   9b1a4: 0054ca47     	subseq	r12, r4, r7, asr #20
   9b1a8: 0054ca54     	subseq	r12, r4, r4, asr r10
   9b1ac: 0054ca4b     	subseq	r12, r4, r11, asr #20
   9b1b0: 0054ca3f     	subseq	r12, r4, pc, lsr r10
   9b1b4: 0054c9dc     	ldrsbeq	r12, [r4], #-156
   9b1b8: 0054c9cb     	subseq	r12, r4, r11, asr #19
   9b1bc: 0054c9b6     	ldrheq	r12, [r4], #-150
   9b1c0: 0054c9af     	subseq	r12, r4, pc, lsr #19
   9b1c4: 0054c98c     	subseq	r12, r4, r12, lsl #19
   9b1c8: 0054c8d7     	ldrsbeq	r12, [r4], #-135
   9b1cc: 0054c8cc     	subseq	r12, r4, r12, asr #17
   9b1d0: 0054c849     	subseq	r12, r4, r9, asr #16
   9b1d4: 0054c822     	subseq	r12, r4, r2, lsr #16
   9b1d8: 0054c7dc     	ldrsbeq	r12, [r4], #-124
   9b1dc: 00000000     	andeq	r0, r0, r0


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   bfe5c: e3a00000     	mov	r0, #0
   bfe60: e3500000     	cmp	r0, #0
   bfe64: 1a000007     	bne	0xbfe88 <.text+0xafd88> @ imm = #0x1c
   bfe68: e59f1184     	ldr	r1, [pc, #0x184]        @ 0xbfff4 <.text+0xafef4>
   bfe6c: e08f1001     	add	r1, pc, r1
   bfe70: e7d12000     	ldrb	r2, [r1, r0]
   bfe74: e222201a     	eor	r2, r2, #26
   bfe78: e7c12000     	strb	r2, [r1, r0]
   bfe7c: e2800001     	add	r0, r0, #1
   bfe80: e350000d     	cmp	r0, #13
   bfe84: 1afffff9     	bne	0xbfe70 <.text+0xafd70> @ imm = #-0x1c
   bfe88: e3a00000     	mov	r0, #0
   bfe8c: e3500000     	cmp	r0, #0
   bfe90: 1a000007     	bne	0xbfeb4 <.text+0xafdb4> @ imm = #0x1c
   bfe94: e59f115c     	ldr	r1, [pc, #0x15c]        @ 0xbfff8 <.text+0xafef8>
   bfe98: e08f1001     	add	r1, pc, r1
   bfe9c: e7d12000     	ldrb	r2, [r1, r0]
   bfea0: e22220af     	eor	r2, r2, #175
   bfea4: e7c12000     	strb	r2, [r1, r0]
   bfea8: e2800001     	add	r0, r0, #1
   bfeac: e350002f     	cmp	r0, #47
   bfeb0: 1afffff9     	bne	0xbfe9c <.text+0xafd9c> @ imm = #-0x1c
   bfeb4: e3a00000     	mov	r0, #0
   bfeb8: e3500000     	cmp	r0, #0
   bfebc: 1a000007     	bne	0xbfee0 <.text+0xafde0> @ imm = #0x1c
   bfec0: e59f1134     	ldr	r1, [pc, #0x134]        @ 0xbfffc <.text+0xafefc>
   bfec4: e08f1001     	add	r1, pc, r1
   bfec8: e7d12000     	ldrb	r2, [r1, r0]
   bfecc: e22220b8     	eor	r2, r2, #184
   bfed0: e7c12000     	strb	r2, [r1, r0]
   bfed4: e2800001     	add	r0, r0, #1
   bfed8: e3500007     	cmp	r0, #7
   bfedc: 1afffff9     	bne	0xbfec8 <.text+0xafdc8> @ imm = #-0x1c
   bfee0: e3a00000     	mov	r0, #0
   bfee4: e3500000     	cmp	r0, #0
   bfee8: 1a000007     	bne	0xbff0c <.text+0xafe0c> @ imm = #0x1c
   bfeec: e59f110c     	ldr	r1, [pc, #0x10c]        @ 0xc0000 <.text+0xaff00>
   bfef0: e08f1001     	add	r1, pc, r1
   bfef4: e7d12000     	ldrb	r2, [r1, r0]
   bfef8: e2222028     	eor	r2, r2, #40
   bfefc: e7c12000     	strb	r2, [r1, r0]
   bff00: e2800001     	add	r0, r0, #1
   bff04: e350000b     	cmp	r0, #11
   bff08: 1afffff9     	bne	0xbfef4 <.text+0xafdf4> @ imm = #-0x1c
   bff0c: e59fc0f0     	ldr	r12, [pc, #0xf0]        @ 0xc0004 <.text+0xaff04>
   bff10: e79fc00c     	ldr	r12, [pc, r12]
   bff14: e59c1000     	ldr	r1, [r12]
   bff18: e2412001     	sub	r2, r1, #1
   bff1c: e0010291     	mul	r1, r1, r2
   bff20: e3110001     	tst	r1, #1
   bff24: e59c1000     	ldr	r1, [r12]
   bff28: e2412001     	sub	r2, r1, #1
   bff2c: e0020291     	mul	r2, r1, r2
   bff30: e59f10d0     	ldr	r1, [pc, #0xd0]         @ 0xc0008 <.text+0xaff08>
   bff34: e79f1001     	ldr	r1, [pc, r1]
   bff38: e3120001     	tst	r2, #1
   bff3c: 0a000002     	beq	0xbff4c <.text+0xafe4c> @ imm = #0x8
   bff40: e5912000     	ldr	r2, [r1]
   bff44: e3520009     	cmp	r2, #9
   bff48: cafffff5     	bgt	0xbff24 <.text+0xafe24> @ imm = #-0x2c
   bff4c: e3a02000     	mov	r2, #0
   bff50: e3520000     	cmp	r2, #0
   bff54: 1a000007     	bne	0xbff78 <.text+0xafe78> @ imm = #0x1c
   bff58: e59f30ac     	ldr	r3, [pc, #0xac]         @ 0xc000c <.text+0xaff0c>
   bff5c: e08f3003     	add	r3, pc, r3
   bff60: e7d30002     	ldrb	r0, [r3, r2]
   bff64: e220008a     	eor	r0, r0, #138
   bff68: e7c30002     	strb	r0, [r3, r2]
   bff6c: e2822001     	add	r2, r2, #1
   bff70: e3520027     	cmp	r2, #39
   bff74: 1afffff9     	bne	0xbff60 <.text+0xafe60> @ imm = #-0x1c
   bff78: e3a02000     	mov	r2, #0
   bff7c: e3520000     	cmp	r2, #0
   bff80: 1a000007     	bne	0xbffa4 <.text+0xafea4> @ imm = #0x1c
   bff84: e59f3084     	ldr	r3, [pc, #0x84]         @ 0xc0010 <.text+0xaff10>
   bff88: e08f3003     	add	r3, pc, r3
   bff8c: e7d30002     	ldrb	r0, [r3, r2]
   bff90: e2200036     	eor	r0, r0, #54
   bff94: e7c30002     	strb	r0, [r3, r2]
   bff98: e2822001     	add	r2, r2, #1
   bff9c: e3520017     	cmp	r2, #23
   bffa0: 1afffff9     	bne	0xbff8c <.text+0xafe8c> @ imm = #-0x1c
   bffa4: e3a02000     	mov	r2, #0
   bffa8: e3520000     	cmp	r2, #0
   bffac: 1a000007     	bne	0xbffd0 <.text+0xafed0> @ imm = #0x1c
   bffb0: e59f305c     	ldr	r3, [pc, #0x5c]         @ 0xc0014 <.text+0xaff14>
   bffb4: e08f3003     	add	r3, pc, r3
   bffb8: e7d30002     	ldrb	r0, [r3, r2]
   bffbc: e22000da     	eor	r0, r0, #218
   bffc0: e7c30002     	strb	r0, [r3, r2]
   bffc4: e2822001     	add	r2, r2, #1
   bffc8: e3520025     	cmp	r2, #37
   bffcc: 1afffff9     	bne	0xbffb8 <.text+0xafeb8> @ imm = #-0x1c
   bffd0: e59c0000     	ldr	r0, [r12]
   bffd4: e2402001     	sub	r2, r0, #1
   bffd8: e0000290     	mul	r0, r0, r2
   bffdc: e3100001     	tst	r0, #1
   bffe0: 012fff1e     	bxeq	lr
   bffe4: e5910000     	ldr	r0, [r1]
   bffe8: e3500009     	cmp	r0, #9
   bffec: cafffff7     	bgt	0xbffd0 <.text+0xafed0> @ imm = #-0x24
   bfff0: e12fff1e     	bx	lr
   bfff4: 005295ca     	subseq	r9, r2, r10, asr #11
   bfff8: 005295ab     	subseq	r9, r2, r11, lsr #11
   bfffc: 005295ae     	subseq	r9, r2, lr, lsr #11
   c0000: 00529589     	subseq	r9, r2, r9, lsl #11
   c0004: 0051fb78     	subseq	pc, r1, r8, ror r11
   c0008: 0051e8a0     	subseq	lr, r1, r0, lsr #17
   c000c: 00529528     	subseq	r9, r2, r8, lsr #10
   c0010: 00529523     	subseq	r9, r2, r3, lsr #10
   c0014: 0052950e     	subseq	r9, r2, lr, lsl #10

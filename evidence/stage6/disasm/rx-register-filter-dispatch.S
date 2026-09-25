
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d2a84: e92d4830     	push	{r4, r5, r11, lr}
   d2a88: e28db008     	add	r11, sp, #8
   d2a8c: eb00ad4a     	bl	0xfdfbc <.text+0xedebc> @ imm = #0x2b528
   d2a90: e3500004     	cmp	r0, #4
   d2a94: 8a000009     	bhi	0xd2ac0 <.text+0xc29c0> @ imm = #0x24
   d2a98: e28f1004     	add	r1, pc, #4
   d2a9c: e7910100     	ldr	r0, [r1, r0, lsl #2]
   d2aa0: e081f000     	add	pc, r1, r0
   d2aa4: 00000014     	andeq	r0, r0, r4, lsl r0
   d2aa8: 00000024     	andeq	r0, r0, r4, lsr #32
   d2aac: 00000058     	andeq	r0, r0, r8, asr r0
   d2ab0: 00000060     	andeq	r0, r0, r0, rrx
   d2ab4: 00000094     	muleq	r0, r4, r0
   d2ab8: e8bd4830     	pop	{r4, r5, r11, lr}
   d2abc: ea000ac2     	b	0xd55cc <.text+0xc54cc> @ imm = #0x2b08
   d2ac0: e3e00000     	mvn	r0, #0
   d2ac4: ea000028     	b	0xd2b6c <.text+0xc2a6c> @ imm = #0xa0
   d2ac8: e59f4124     	ldr	r4, [pc, #0x124]        @ 0xd2bf4 <.text+0xc2af4>
   d2acc: e79f4004     	ldr	r4, [pc, r4]
   d2ad0: e5940000     	ldr	r0, [r4]
   d2ad4: e59f511c     	ldr	r5, [pc, #0x11c]        @ 0xd2bf8 <.text+0xc2af8>
   d2ad8: e2401001     	sub	r1, r0, #1
   d2adc: e0000190     	mul	r0, r0, r1
   d2ae0: e79f5005     	ldr	r5, [pc, r5]
   d2ae4: e3100001     	tst	r0, #1
   d2ae8: 0a000020     	beq	0xd2b70 <.text+0xc2a70> @ imm = #0x80
   d2aec: e5950000     	ldr	r0, [r5]
   d2af0: e3500009     	cmp	r0, #9
   d2af4: ca000026     	bgt	0xd2b94 <.text+0xc2a94> @ imm = #0x98
   d2af8: ea00001c     	b	0xd2b70 <.text+0xc2a70> @ imm = #0x70
   d2afc: e8bd4830     	pop	{r4, r5, r11, lr}
   d2b00: ea006907     	b	0xecf24 <.text+0xdce24> @ imm = #0x1a41c
   d2b04: e59f40f0     	ldr	r4, [pc, #0xf0]         @ 0xd2bfc <.text+0xc2afc>
   d2b08: e79f4004     	ldr	r4, [pc, r4]
   d2b0c: e5940000     	ldr	r0, [r4]
   d2b10: e59f50e8     	ldr	r5, [pc, #0xe8]         @ 0xd2c00 <.text+0xc2b00>
   d2b14: e2401001     	sub	r1, r0, #1
   d2b18: e0000190     	mul	r0, r0, r1
   d2b1c: e79f5005     	ldr	r5, [pc, r5]
   d2b20: e3100001     	tst	r0, #1
   d2b24: 0a00001c     	beq	0xd2b9c <.text+0xc2a9c> @ imm = #0x70
   d2b28: e5950000     	ldr	r0, [r5]
   d2b2c: e3500009     	cmp	r0, #9
   d2b30: ca000022     	bgt	0xd2bc0 <.text+0xc2ac0> @ imm = #0x88
   d2b34: ea000018     	b	0xd2b9c <.text+0xc2a9c> @ imm = #0x60
   d2b38: e59f40c4     	ldr	r4, [pc, #0xc4]         @ 0xd2c04 <.text+0xc2b04>
   d2b3c: e79f4004     	ldr	r4, [pc, r4]
   d2b40: e5940000     	ldr	r0, [r4]
   d2b44: e59f50bc     	ldr	r5, [pc, #0xbc]         @ 0xd2c08 <.text+0xc2b08>
   d2b48: e2401001     	sub	r1, r0, #1
   d2b4c: e0000190     	mul	r0, r0, r1
   d2b50: e79f5005     	ldr	r5, [pc, r5]
   d2b54: e3100001     	tst	r0, #1
   d2b58: 0a00001a     	beq	0xd2bc8 <.text+0xc2ac8> @ imm = #0x68
   d2b5c: e5950000     	ldr	r0, [r5]
   d2b60: e3500009     	cmp	r0, #9
   d2b64: ca000020     	bgt	0xd2bec <.text+0xc2aec> @ imm = #0x80
   d2b68: ea000016     	b	0xd2bc8 <.text+0xc2ac8> @ imm = #0x58
   d2b6c: e8bd8830     	pop	{r4, r5, r11, pc}
   d2b70: eb00203b     	bl	0xdac64 <.text+0xcab64> @ imm = #0x80ec
   d2b74: e5941000     	ldr	r1, [r4]
   d2b78: e2412001     	sub	r2, r1, #1
   d2b7c: e0010291     	mul	r1, r1, r2
   d2b80: e3110001     	tst	r1, #1
   d2b84: 0afffff8     	beq	0xd2b6c <.text+0xc2a6c> @ imm = #-0x20
   d2b88: e5951000     	ldr	r1, [r5]
   d2b8c: e351000a     	cmp	r1, #10
   d2b90: bafffff5     	blt	0xd2b6c <.text+0xc2a6c> @ imm = #-0x2c
   d2b94: eb002032     	bl	0xdac64 <.text+0xcab64> @ imm = #0x80c8
   d2b98: eafffff4     	b	0xd2b70 <.text+0xc2a70> @ imm = #-0x30
   d2b9c: eb00318d     	bl	0xdf1d8 <.text+0xcf0d8> @ imm = #0xc634
   d2ba0: e5941000     	ldr	r1, [r4]
   d2ba4: e2412001     	sub	r2, r1, #1
   d2ba8: e0010291     	mul	r1, r1, r2
   d2bac: e3110001     	tst	r1, #1
   d2bb0: 0affffed     	beq	0xd2b6c <.text+0xc2a6c> @ imm = #-0x4c
   d2bb4: e5951000     	ldr	r1, [r5]
   d2bb8: e351000a     	cmp	r1, #10
   d2bbc: baffffea     	blt	0xd2b6c <.text+0xc2a6c> @ imm = #-0x58
   d2bc0: eb003184     	bl	0xdf1d8 <.text+0xcf0d8> @ imm = #0xc610
   d2bc4: eafffff4     	b	0xd2b9c <.text+0xc2a9c> @ imm = #-0x30
   d2bc8: eb0043fd     	bl	0xe3bc4 <.text+0xd3ac4> @ imm = #0x10ff4
   d2bcc: e5941000     	ldr	r1, [r4]
   d2bd0: e2412001     	sub	r2, r1, #1
   d2bd4: e0010291     	mul	r1, r1, r2
   d2bd8: e3110001     	tst	r1, #1
   d2bdc: 0affffe2     	beq	0xd2b6c <.text+0xc2a6c> @ imm = #-0x78
   d2be0: e5951000     	ldr	r1, [r5]
   d2be4: e351000a     	cmp	r1, #10
   d2be8: baffffdf     	blt	0xd2b6c <.text+0xc2a6c> @ imm = #-0x84
   d2bec: eb0043f4     	bl	0xe3bc4 <.text+0xd3ac4> @ imm = #0x10fd0
   d2bf0: eafffff4     	b	0xd2bc8 <.text+0xc2ac8> @ imm = #-0x30


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   2a1bc: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   2a1c0: e28db010     	add	r11, sp, #16
   2a1c4: e1a04000     	mov	r4, r0
   2a1c8: e590018c     	ldr	r0, [r0, #0x18c]
   2a1cc: e3500000     	cmp	r0, #0
   2a1d0: 0a000002     	beq	0x2a1e0 <.text+0x1a0e0> @ imm = #0x8
   2a1d4: eb15a6ac     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x569ab0
   2a1d8: e3a00000     	mov	r0, #0
   2a1dc: e584018c     	str	r0, [r4, #0x18c]
   2a1e0: e594019c     	ldr	r0, [r4, #0x19c]
   2a1e4: e3500000     	cmp	r0, #0
   2a1e8: 0a000002     	beq	0x2a1f8 <.text+0x1a0f8> @ imm = #0x8
   2a1ec: eb15a6a6     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x569a98
   2a1f0: e3a00000     	mov	r0, #0
   2a1f4: e584019c     	str	r0, [r4, #0x19c]
   2a1f8: e59401b0     	ldr	r0, [r4, #0x1b0]
   2a1fc: e3500000     	cmp	r0, #0
   2a200: 0a000002     	beq	0x2a210 <.text+0x1a110> @ imm = #0x8
   2a204: eb15a6a0     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x569a80
   2a208: e3a00000     	mov	r0, #0
   2a20c: e58401b0     	str	r0, [r4, #0x1b0]
   2a210: e59f6110     	ldr	r6, [pc, #0x110]        @ 0x2a328 <.text+0x1a228>
   2a214: e79f6006     	ldr	r6, [pc, r6]
   2a218: e5960000     	ldr	r0, [r6]
   2a21c: e2401001     	sub	r1, r0, #1
   2a220: e0000190     	mul	r0, r0, r1
   2a224: e3100001     	tst	r0, #1
   2a228: e5960000     	ldr	r0, [r6]
   2a22c: e59f70f8     	ldr	r7, [pc, #0xf8]         @ 0x2a32c <.text+0x1a22c>
   2a230: e2401001     	sub	r1, r0, #1
   2a234: e0000190     	mul	r0, r0, r1
   2a238: e79f7007     	ldr	r7, [pc, r7]
   2a23c: e59451a8     	ldr	r5, [r4, #0x1a8]
   2a240: e3100001     	tst	r0, #1
   2a244: 0a000002     	beq	0x2a254 <.text+0x1a154> @ imm = #0x8
   2a248: e5970000     	ldr	r0, [r7]
   2a24c: e3500009     	cmp	r0, #9
   2a250: cafffff4     	bgt	0x2a228 <.text+0x1a128> @ imm = #-0x30
   2a254: e3550000     	cmp	r5, #0
   2a258: 0a000018     	beq	0x2a2c0 <.text+0x1a1c0> @ imm = #0x60
   2a25c: e5960000     	ldr	r0, [r6]
   2a260: e2401001     	sub	r1, r0, #1
   2a264: e0000190     	mul	r0, r0, r1
   2a268: e3100001     	tst	r0, #1
   2a26c: 0a000002     	beq	0x2a27c <.text+0x1a17c> @ imm = #0x8
   2a270: e5970000     	ldr	r0, [r7]
   2a274: e3500009     	cmp	r0, #9
   2a278: ca00000b     	bgt	0x2a2ac <.text+0x1a1ac> @ imm = #0x2c
   2a27c: e1a00005     	mov	r0, r5
   2a280: eb15a681     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x569a04
   2a284: e3a00000     	mov	r0, #0
   2a288: e58401a8     	str	r0, [r4, #0x1a8]
   2a28c: e5960000     	ldr	r0, [r6]
   2a290: e2401001     	sub	r1, r0, #1
   2a294: e0000190     	mul	r0, r0, r1
   2a298: e3100001     	tst	r0, #1
   2a29c: 0a000007     	beq	0x2a2c0 <.text+0x1a1c0> @ imm = #0x1c
   2a2a0: e5970000     	ldr	r0, [r7]
   2a2a4: e3500009     	cmp	r0, #9
   2a2a8: da000004     	ble	0x2a2c0 <.text+0x1a1c0> @ imm = #0x10
   2a2ac: e1a00005     	mov	r0, r5
   2a2b0: eb15a675     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x5699d4
   2a2b4: e3a00000     	mov	r0, #0
   2a2b8: e58401a8     	str	r0, [r4, #0x1a8]
   2a2bc: eaffffee     	b	0x2a27c <.text+0x1a17c> @ imm = #-0x48
   2a2c0: e5960000     	ldr	r0, [r6]
   2a2c4: e2401001     	sub	r1, r0, #1
   2a2c8: e0000190     	mul	r0, r0, r1
   2a2cc: e3100001     	tst	r0, #1
   2a2d0: 0a000002     	beq	0x2a2e0 <.text+0x1a1e0> @ imm = #0x8
   2a2d4: e5970000     	ldr	r0, [r7]
   2a2d8: e3500009     	cmp	r0, #9
   2a2dc: ca00000b     	bgt	0x2a310 <.text+0x1a210> @ imm = #0x2c
   2a2e0: e1a00004     	mov	r0, r4
   2a2e4: e3a01000     	mov	r1, #0
   2a2e8: e3a02f9e     	mov	r2, #632
   2a2ec: eb15e466     	bl	0x5a348c <.text+0x59338c> @ imm = #0x579198
   2a2f0: e5960000     	ldr	r0, [r6]
   2a2f4: e2401001     	sub	r1, r0, #1
   2a2f8: e0000190     	mul	r0, r0, r1
   2a2fc: e3100001     	tst	r0, #1
   2a300: 0a000007     	beq	0x2a324 <.text+0x1a224> @ imm = #0x1c
   2a304: e5970000     	ldr	r0, [r7]
   2a308: e3500009     	cmp	r0, #9
   2a30c: da000004     	ble	0x2a324 <.text+0x1a224> @ imm = #0x10
   2a310: e1a00004     	mov	r0, r4
   2a314: e3a01000     	mov	r1, #0
   2a318: e3a02f9e     	mov	r2, #632
   2a31c: eb15e45a     	bl	0x5a348c <.text+0x59338c> @ imm = #0x579168
   2a320: eaffffee     	b	0x2a2e0 <.text+0x1a1e0> @ imm = #-0x48
   2a324: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}

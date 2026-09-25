
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d1f20: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   d1f24: e28db01c     	add	r11, sp, #28
   d1f28: e24dd004     	sub	sp, sp, #4
   d1f2c: e59f9170     	ldr	r9, [pc, #0x170]        @ 0xd20a4 <.text+0xc1fa4>
   d1f30: e1a06000     	mov	r6, r0
   d1f34: e1a0a001     	mov	r10, r1
   d1f38: e1a08002     	mov	r8, r2
   d1f3c: e79f9009     	ldr	r9, [pc, r9]
   d1f40: e5990000     	ldr	r0, [r9]
   d1f44: e2401001     	sub	r1, r0, #1
   d1f48: e0000190     	mul	r0, r0, r1
   d1f4c: e3100001     	tst	r0, #1
   d1f50: e5990000     	ldr	r0, [r9]
   d1f54: e59f414c     	ldr	r4, [pc, #0x14c]        @ 0xd20a8 <.text+0xc1fa8>
   d1f58: e2401001     	sub	r1, r0, #1
   d1f5c: e0000190     	mul	r0, r0, r1
   d1f60: e79f4004     	ldr	r4, [pc, r4]
   d1f64: e3100001     	tst	r0, #1
   d1f68: 0a000002     	beq	0xd1f78 <.text+0xc1e78> @ imm = #0x8
   d1f6c: e5940000     	ldr	r0, [r4]
   d1f70: e3500009     	cmp	r0, #9
   d1f74: cafffff5     	bgt	0xd1f50 <.text+0xc1e50> @ imm = #-0x2c
   d1f78: e3580000     	cmp	r8, #0
   d1f7c: 0a000044     	beq	0xd2094 <.text+0xc1f94> @ imm = #0x110
   d1f80: e5960014     	ldr	r0, [r6, #0x14]
   d1f84: e3a07000     	mov	r7, #0
   d1f88: e3500000     	cmp	r0, #0
   d1f8c: 1a00000d     	bne	0xd1fc8 <.text+0xc1ec8> @ imm = #0x34
   d1f90: ea000040     	b	0xd2098 <.text+0xc1f98> @ imm = #0x100
   d1f94: e1520000     	cmp	r2, r0
   d1f98: e3a02001     	mov	r2, #1
   d1f9c: 05960000     	ldreq	r0, [r6]
   d1fa0: 0586000c     	streq	r0, [r6, #0xc]
   d1fa4: e5960014     	ldr	r0, [r6, #0x14]
   d1fa8: e2400001     	sub	r0, r0, #1
   d1fac: e5860014     	str	r0, [r6, #0x14]
   d1fb0: e0827007     	add	r7, r2, r7
   d1fb4: e08aa001     	add	r10, r10, r1
   d1fb8: e1570008     	cmp	r7, r8
   d1fbc: 2a000035     	bhs	0xd2098 <.text+0xc1f98> @ imm = #0xd4
   d1fc0: e3500000     	cmp	r0, #0
   d1fc4: 0a000033     	beq	0xd2098 <.text+0xc1f98> @ imm = #0xcc
   d1fc8: e5961000     	ldr	r1, [r6]
   d1fcc: e3510000     	cmp	r1, #0
   d1fd0: 0a00001a     	beq	0xd2040 <.text+0xc1f40> @ imm = #0x68
   d1fd4: e5990000     	ldr	r0, [r9]
   d1fd8: e2401001     	sub	r1, r0, #1
   d1fdc: e0000190     	mul	r0, r0, r1
   d1fe0: e3100001     	tst	r0, #1
   d1fe4: e5990000     	ldr	r0, [r9]
   d1fe8: e2401001     	sub	r1, r0, #1
   d1fec: e0000190     	mul	r0, r0, r1
   d1ff0: e3100001     	tst	r0, #1
   d1ff4: 0a000002     	beq	0xd2004 <.text+0xc1f04> @ imm = #0x8
   d1ff8: e5940000     	ldr	r0, [r4]
   d1ffc: e3500009     	cmp	r0, #9
   d2000: cafffff7     	bgt	0xd1fe4 <.text+0xc1ee4> @ imm = #-0x24
   d2004: e35a0000     	cmp	r10, #0
   d2008: 0a000003     	beq	0xd201c <.text+0xc1f1c> @ imm = #0xc
   d200c: e596100c     	ldr	r1, [r6, #0xc]
   d2010: e1a0000a     	mov	r0, r10
   d2014: e5962018     	ldr	r2, [r6, #0x18]
   d2018: eb1343b2     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x4d0ec8
   d201c: e5990000     	ldr	r0, [r9]
   d2020: e2401001     	sub	r1, r0, #1
   d2024: e0000190     	mul	r0, r0, r1
   d2028: e3100001     	tst	r0, #1
   d202c: 0a000006     	beq	0xd204c <.text+0xc1f4c> @ imm = #0x18
   d2030: e5940000     	ldr	r0, [r4]
   d2034: e3500009     	cmp	r0, #9
   d2038: ca000010     	bgt	0xd2080 <.text+0xc1f80> @ imm = #0x40
   d203c: ea000002     	b	0xd204c <.text+0xc1f4c> @ imm = #0x8
   d2040: e5961018     	ldr	r1, [r6, #0x18]
   d2044: e3a02000     	mov	r2, #0
   d2048: eaffffd8     	b	0xd1fb0 <.text+0xc1eb0> @ imm = #-0xa0
   d204c: e596200c     	ldr	r2, [r6, #0xc]
   d2050: e5961018     	ldr	r1, [r6, #0x18]
   d2054: e5960004     	ldr	r0, [r6, #0x4]
   d2058: e0822001     	add	r2, r2, r1
   d205c: e586200c     	str	r2, [r6, #0xc]
   d2060: e5993000     	ldr	r3, [r9]
   d2064: e2435001     	sub	r5, r3, #1
   d2068: e0030593     	mul	r3, r3, r5
   d206c: e3130001     	tst	r3, #1
   d2070: 0affffc7     	beq	0xd1f94 <.text+0xc1e94> @ imm = #-0xe4
   d2074: e5943000     	ldr	r3, [r4]
   d2078: e3530009     	cmp	r3, #9
   d207c: daffffc4     	ble	0xd1f94 <.text+0xc1e94> @ imm = #-0xf0
   d2080: e596000c     	ldr	r0, [r6, #0xc]
   d2084: e5961018     	ldr	r1, [r6, #0x18]
   d2088: e0800001     	add	r0, r0, r1
   d208c: e586000c     	str	r0, [r6, #0xc]
   d2090: eaffffed     	b	0xd204c <.text+0xc1f4c> @ imm = #-0x4c
   d2094: e3a07000     	mov	r7, #0
   d2098: e1a00007     	mov	r0, r7
   d209c: e24bd01c     	sub	sp, r11, #28
   d20a0: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}

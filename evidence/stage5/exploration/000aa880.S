
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   aa880: e3a02000     	mov	r2, #0
   aa884: e58d8000     	str	r8, [sp]
   aa888: e98d0220     	stmib	sp, {r5, r9}
   aa88c: e58d700c     	str	r7, [sp, #0xc]
   aa890: eb026f5a     	bl	0x146600 <.text+0x136500> @ imm = #0x9bd68
   aa894: e28dd010     	add	sp, sp, #16
   aa898: e59f1f90     	ldr	r1, [pc, #0xf90]        @ 0xab830 <.text+0x9b730>
   aa89c: e79f1001     	ldr	r1, [pc, r1]
   aa8a0: e5911000     	ldr	r1, [r1]
   aa8a4: e2412001     	sub	r2, r1, #1
   aa8a8: e0010291     	mul	r1, r1, r2
   aa8ac: e3110001     	tst	r1, #1
   aa8b0: 0a000010     	beq	0xaa8f8 <.text+0x9a7f8> @ imm = #0x40
   aa8b4: e59f1f78     	ldr	r1, [pc, #0xf78]        @ 0xab834 <.text+0x9b734>
   aa8b8: e79f1001     	ldr	r1, [pc, r1]
   aa8bc: e5911000     	ldr	r1, [r1]
   aa8c0: e3510009     	cmp	r1, #9
   aa8c4: da00000b     	ble	0xaa8f8 <.text+0x9a7f8> @ imm = #0x2c
   aa8c8: e59f3f68     	ldr	r3, [pc, #0xf68]        @ 0xab838 <.text+0x9b738>
   aa8cc: e08f3003     	add	r3, pc, r3
   aa8d0: e24dd010     	sub	sp, sp, #16
   aa8d4: e1a00004     	mov	r0, r4
   aa8d8: e1a01006     	mov	r1, r6
   aa8dc: e3a02000     	mov	r2, #0
   aa8e0: e58d8000     	str	r8, [sp]
   aa8e4: e98d0220     	stmib	sp, {r5, r9}
   aa8e8: e58d700c     	str	r7, [sp, #0xc]
   aa8ec: eb026f43     	bl	0x146600 <.text+0x136500> @ imm = #0x9bd0c
   aa8f0: e28dd010     	add	sp, sp, #16
   aa8f4: eaffffdc     	b	0xaa86c <.text+0x9a76c> @ imm = #-0x90
   aa8f8: e3500000     	cmp	r0, #0
   aa8fc: 0a000014     	beq	0xaa954 <.text+0x9a854> @ imm = #0x50
   aa900: e59f0f34     	ldr	r0, [pc, #0xf34]        @ 0xab83c <.text+0x9b73c>
   aa904: e59f1f34     	ldr	r1, [pc, #0xf34]        @ 0xab840 <.text+0x9b740>
   aa908: e59f2f34     	ldr	r2, [pc, #0xf34]        @ 0xab844 <.text+0x9b744>
   aa90c: e08f0000     	add	r0, pc, r0
   aa910: e59f3f30     	ldr	r3, [pc, #0xf30]        @ 0xab848 <.text+0x9b748>
   aa914: e08f1001     	add	r1, pc, r1
   aa918: e08f2002     	add	r2, pc, r2
   aa91c: e08f3003     	add	r3, pc, r3
   aa920: e24dd010     	sub	sp, sp, #16
   aa924: e3a06001     	mov	r6, #1
   aa928: e58d3004     	str	r3, [sp, #0x4]
   aa92c: e58d6000     	str	r6, [sp]
   aa930: e51b7154     	ldr	r7, [r11, #-0x154]
   aa934: e59f3f10     	ldr	r3, [pc, #0xf10]        @ 0xab84c <.text+0x9b74c>
   aa938: e287705c     	add	r7, r7, #92
   aa93c: e58d700c     	str	r7, [sp, #0xc]
   aa940: e08f3003     	add	r3, pc, r3
   aa944: e58d3008     	str	r3, [sp, #0x8]
   aa948: e3003219     	movw	r3, #0x219
   aa94c: eafff771     	b	0xa8718 <.text+0x98618> @ imm = #-0x223c
   aa950: 005362f8     	ldrsheq	r6, [r3], #-40
   aa954: e51b0114     	ldr	r0, [r11, #-0x114]
   aa958: e51b61ec     	ldr	r6, [r11, #-0x1ec]
   aa95c: e5900000     	ldr	r0, [r0]
   aa960: e3500001     	cmp	r0, #1
   aa964: a51b00fc     	ldrge	r0, [r11, #-0xfc]
   aa968: a5900000     	ldrge	r0, [r0]
   aa96c: a3500001     	cmpge	r0, #1
   aa970: bafffe25     	blt	0xaa20c <.text+0x9a10c> @ imm = #-0x76c
   aa974: e59f1ff8     	ldr	r1, [pc, #0xff8]        @ 0xab974 <.text+0x9b874>
   aa978: e1a00004     	mov	r0, r4
   aa97c: e08f1001     	add	r1, pc, r1
   aa980: eb029f88     	bl	0x1527a8 <.text+0x1426a8> @ imm = #0xa7e20
   aa984: e3500000     	cmp	r0, #0
   aa988: 0a000025     	beq	0xaaa24 <.text+0x9a924> @ imm = #0x94
   aa98c: e1a09000     	mov	r9, r0
   aa990: e59f0fe0     	ldr	r0, [pc, #0xfe0]        @ 0xab978 <.text+0x9b878>
   aa994: e79f0000     	ldr	r0, [pc, r0]
   aa998: e5900000     	ldr	r0, [r0]
   aa99c: e2401001     	sub	r1, r0, #1
   aa9a0: e0000190     	mul	r0, r0, r1
   aa9a4: e3100001     	tst	r0, #1
   aa9a8: e59f0fcc     	ldr	r0, [pc, #0xfcc]        @ 0xab97c <.text+0x9b87c>
   aa9ac: e79f0000     	ldr	r0, [pc, r0]
   aa9b0: e5900000     	ldr	r0, [r0]
   aa9b4: e2401001     	sub	r1, r0, #1
   aa9b8: e0010190     	mul	r1, r0, r1
   aa9bc: e5990000     	ldr	r0, [r9]
   aa9c0: e3110001     	tst	r1, #1
   aa9c4: 0a000004     	beq	0xaa9dc <.text+0x9a8dc> @ imm = #0x10
   aa9c8: e59f1fb0     	ldr	r1, [pc, #0xfb0]        @ 0xab980 <.text+0x9b880>
   aa9cc: e79f1001     	ldr	r1, [pc, r1]
   aa9d0: e5911000     	ldr	r1, [r1]
   aa9d4: e3510009     	cmp	r1, #9
   aa9d8: cafffff2     	bgt	0xaa9a8 <.text+0x9a8a8> @ imm = #-0x38
   aa9dc: e3500001     	cmp	r0, #1
   aa9e0: 1a00000f     	bne	0xaaa24 <.text+0x9a924> @ imm = #0x3c
   aa9e4: e59f0f98     	ldr	r0, [pc, #0xf98]        @ 0xab984 <.text+0x9b884>
   aa9e8: e79f0000     	ldr	r0, [pc, r0]
   aa9ec: e51b61ec     	ldr	r6, [r11, #-0x1ec]
   aa9f0: e51b5114     	ldr	r5, [r11, #-0x114]
   aa9f4: e5900000     	ldr	r0, [r0]
   aa9f8: e2401001     	sub	r1, r0, #1
   aa9fc: e0000190     	mul	r0, r0, r1
   aaa00: e3100001     	tst	r0, #1
   aaa04: 0a000017     	beq	0xaaa68 <.text+0x9a968> @ imm = #0x5c
   aaa08: e59f0fec     	ldr	r0, [pc, #0xfec]        @ 0xab9fc <.text+0x9b8fc>
   aaa0c: e79f0000     	ldr	r0, [pc, r0]
   aaa10: e5900000     	ldr	r0, [r0]
   aaa14: e3500009     	cmp	r0, #9
   aaa18: ca000024     	bgt	0xaaab0 <.text+0x9a9b0> @ imm = #0x90
   aaa1c: ea000011     	b	0xaaa68 <.text+0x9a968> @ imm = #0x44
   aaa20: 00535938     	subseq	r5, r3, r8, lsr r9
   aaa24: e59f0fd4     	ldr	r0, [pc, #0xfd4]        @ 0xaba00 <.text+0x9b900>
   aaa28: e59f1fd4     	ldr	r1, [pc, #0xfd4]        @ 0xaba04 <.text+0x9b904>
   aaa2c: e59f2fd4     	ldr	r2, [pc, #0xfd4]        @ 0xaba08 <.text+0x9b908>
   aaa30: e08f0000     	add	r0, pc, r0
   aaa34: e59f3fd0     	ldr	r3, [pc, #0xfd0]        @ 0xaba0c <.text+0x9b90c>
   aaa38: e08f1001     	add	r1, pc, r1
   aaa3c: e08f2002     	add	r2, pc, r2
   aaa40: e08f3003     	add	r3, pc, r3
   aaa44: e24dd008     	sub	sp, sp, #8
   aaa48: e3a07001     	mov	r7, #1
   aaa4c: e58d3004     	str	r3, [sp, #0x4]
   aaa50: e58d7000     	str	r7, [sp]
   aaa54: e3003225     	movw	r3, #0x225
   aaa58: eafffa55     	b	0xa93b4 <.text+0x992b4> @ imm = #-0x16ac
   aaa5c: 0053eb18     	subseq	lr, r3, r8, lsl r11
   aaa60: 0053eb13     	subseq	lr, r3, r3, lsl r11
   aaa64: 0053eb0c     	subseq	lr, r3, r12, lsl #22
   aaa68: e5957000     	ldr	r7, [r5]
   aaa6c: e3a01004     	mov	r1, #4
   aaa70: e1a00007     	mov	r0, r7
   aaa74: eb13a44e     	bl	0x593bb4 <.text+0x583ab4> @ imm = #0x4e9138
   aaa78: e586005c     	str	r0, [r6, #0x5c]
   aaa7c: e1a04000     	mov	r4, r0
   aaa80: e59f0f88     	ldr	r0, [pc, #0xf88]        @ 0xaba10 <.text+0x9b910>
   aaa84: e79f0000     	ldr	r0, [pc, r0]
   aaa88: e5900000     	ldr	r0, [r0]
   aaa8c: e2401001     	sub	r1, r0, #1
   aaa90: e0000190     	mul	r0, r0, r1
   aaa94: e3100001     	tst	r0, #1
   aaa98: 0a000010     	beq	0xaaae0 <.text+0x9a9e0> @ imm = #0x40
   aaa9c: e59f0f70     	ldr	r0, [pc, #0xf70]        @ 0xaba14 <.text+0x9b914>

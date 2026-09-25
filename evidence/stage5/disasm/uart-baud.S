
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  10e518: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  10e51c: e28db01c     	add	r11, sp, #28
  10e520: e24dd034     	sub	sp, sp, #52
  10e524: e1a05000     	mov	r5, r0
  10e528: e5900020     	ldr	r0, [r0, #0x20]
  10e52c: e1a04001     	mov	r4, r1
  10e530: e305142a     	movw	r1, #0x542a
  10e534: e28d2008     	add	r2, sp, #8
  10e538: e348102c     	movt	r1, #0x802c
  10e53c: eb122403     	bl	0x597550 <.text+0x587450> @ imm = #0x48900c
  10e540: e3500000     	cmp	r0, #0
  10e544: 0a00000c     	beq	0x10e57c <.text+0xfe47c> @ imm = #0x30
  10e548: e59f0148     	ldr	r0, [pc, #0x148]        @ 0x10e698 <.text+0xfe598>
  10e54c: e3a07001     	mov	r7, #1
  10e550: e59f1144     	ldr	r1, [pc, #0x144]        @ 0x10e69c <.text+0xfe59c>
  10e554: e59f2144     	ldr	r2, [pc, #0x144]        @ 0x10e6a0 <.text+0xfe5a0>
  10e558: e08f0000     	add	r0, pc, r0
  10e55c: e59f3140     	ldr	r3, [pc, #0x140]        @ 0x10e6a4 <.text+0xfe5a4>
  10e560: e08f1001     	add	r1, pc, r1
  10e564: e08f2002     	add	r2, pc, r2
  10e568: e58d7000     	str	r7, [sp]
  10e56c: e08f3003     	add	r3, pc, r3
  10e570: e58d3004     	str	r3, [sp, #0x4]
  10e574: e3a03054     	mov	r3, #84
  10e578: ea000012     	b	0x10e5c8 <.text+0xfe4c8> @ imm = #0x48
  10e57c: e59f9124     	ldr	r9, [pc, #0x124]        @ 0x10e6a8 <.text+0xfe5a8>
  10e580: e301a000     	movw	r10, #0x1000
  10e584: e305642b     	movw	r6, #0x542b
  10e588: e30e7ff0     	movw	r7, #0xeff0
  10e58c: e341a000     	movt	r10, #0x1000
  10e590: e344602c     	movt	r6, #0x402c
  10e594: e79f9009     	ldr	r9, [pc, r9]
  10e598: e34e7ff0     	movt	r7, #0xeff0
  10e59c: e5990000     	ldr	r0, [r9]
  10e5a0: e59f8104     	ldr	r8, [pc, #0x104]        @ 0x10e6ac <.text+0xfe5ac>
  10e5a4: e2401001     	sub	r1, r0, #1
  10e5a8: e0000190     	mul	r0, r0, r1
  10e5ac: e79f8008     	ldr	r8, [pc, r8]
  10e5b0: e3100001     	tst	r0, #1
  10e5b4: 0a000007     	beq	0x10e5d8 <.text+0xfe4d8> @ imm = #0x1c
  10e5b8: e5980000     	ldr	r0, [r8]
  10e5bc: e3500009     	cmp	r0, #9
  10e5c0: ca000016     	bgt	0x10e620 <.text+0xfe520> @ imm = #0x58
  10e5c4: ea000003     	b	0x10e5d8 <.text+0xfe4d8> @ imm = #0xc
  10e5c8: ebffaebd     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1450c
  10e5cc: e3e00000     	mvn	r0, #0
  10e5d0: e24bd01c     	sub	sp, r11, #28
  10e5d4: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  10e5d8: e59d0010     	ldr	r0, [sp, #0x10]
  10e5dc: e28d2008     	add	r2, sp, #8
  10e5e0: e58d4030     	str	r4, [sp, #0x30]
  10e5e4: e1a01006     	mov	r1, r6
  10e5e8: e0000007     	and	r0, r0, r7
  10e5ec: e58d402c     	str	r4, [sp, #0x2c]
  10e5f0: e180000a     	orr	r0, r0, r10
  10e5f4: e58d0010     	str	r0, [sp, #0x10]
  10e5f8: e5950020     	ldr	r0, [r5, #0x20]
  10e5fc: eb1223d3     	bl	0x597550 <.text+0x587450> @ imm = #0x488f4c
  10e600: e5991000     	ldr	r1, [r9]
  10e604: e2412001     	sub	r2, r1, #1
  10e608: e0010291     	mul	r1, r1, r2
  10e60c: e3110001     	tst	r1, #1
  10e610: 0a00000d     	beq	0x10e64c <.text+0xfe54c> @ imm = #0x34
  10e614: e5981000     	ldr	r1, [r8]
  10e618: e3510009     	cmp	r1, #9
  10e61c: da00000a     	ble	0x10e64c <.text+0xfe54c> @ imm = #0x28
  10e620: e59d0010     	ldr	r0, [sp, #0x10]
  10e624: e28d2008     	add	r2, sp, #8
  10e628: e58d4030     	str	r4, [sp, #0x30]
  10e62c: e1a01006     	mov	r1, r6
  10e630: e0000007     	and	r0, r0, r7
  10e634: e58d402c     	str	r4, [sp, #0x2c]
  10e638: e180000a     	orr	r0, r0, r10
  10e63c: e58d0010     	str	r0, [sp, #0x10]
  10e640: e5950020     	ldr	r0, [r5, #0x20]
  10e644: eb1223c1     	bl	0x597550 <.text+0x587450> @ imm = #0x488f04
  10e648: eaffffe2     	b	0x10e5d8 <.text+0xfe4d8> @ imm = #-0x78
  10e64c: e3500000     	cmp	r0, #0
  10e650: 0a00000c     	beq	0x10e688 <.text+0xfe588> @ imm = #0x30
  10e654: e59f0054     	ldr	r0, [pc, #0x54]         @ 0x10e6b0 <.text+0xfe5b0>
  10e658: e3a07001     	mov	r7, #1
  10e65c: e59f1050     	ldr	r1, [pc, #0x50]         @ 0x10e6b4 <.text+0xfe5b4>
  10e660: e59f2050     	ldr	r2, [pc, #0x50]         @ 0x10e6b8 <.text+0xfe5b8>
  10e664: e08f0000     	add	r0, pc, r0
  10e668: e59f304c     	ldr	r3, [pc, #0x4c]         @ 0x10e6bc <.text+0xfe5bc>
  10e66c: e08f1001     	add	r1, pc, r1
  10e670: e08f2002     	add	r2, pc, r2
  10e674: e58d7000     	str	r7, [sp]
  10e678: e08f3003     	add	r3, pc, r3
  10e67c: e58d3004     	str	r3, [sp, #0x4]
  10e680: e3a03061     	mov	r3, #97
  10e684: eaffffcf     	b	0x10e5c8 <.text+0xfe4c8> @ imm = #-0xc4
  10e688: e5854024     	str	r4, [r5, #0x24]
  10e68c: e3a00000     	mov	r0, #0
  10e690: e24bd01c     	sub	sp, r11, #28
  10e694: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  10e698: 004df658     	subeq	pc, sp, r8, asr r6
  10e69c: 004df657     	subeq	pc, sp, r7, asr r6
  10e6a0: 004df674     	subeq	pc, sp, r4, ror r6
  10e6a4: 004df68a     	subeq	pc, sp, r10, lsl #13
  10e6a8: 004d0e3c     	subeq	r0, sp, r12, lsr lr
  10e6ac: 004d1484     	subeq	r1, sp, r4, lsl #9
  10e6b0: 004df54c     	subeq	pc, sp, r12, asr #10
  10e6b4: 004df54b     	subeq	pc, sp, r11, asr #10
  10e6b8: 004df568     	subeq	pc, sp, r8, ror #10
  10e6bc: 004df59b     	umaaleq	pc, sp, r11, r5

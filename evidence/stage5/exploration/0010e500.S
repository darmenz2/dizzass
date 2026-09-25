
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  10e500: 004df78c     	subeq	pc, sp, r12, lsl #15
  10e504: 004df78f     	subeq	pc, sp, pc, lsl #15
  10e508: 004df7ac     	subeq	pc, sp, r12, lsr #15
  10e50c: 004df738     	subeq	pc, sp, r8, lsr r7
  10e510: 004df73b     	subeq	pc, sp, r11, lsr r7
  10e514: 004df758     	subeq	pc, sp, r8, asr r7
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
  10e6c0: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  10e6c4: e28db01c     	add	r11, sp, #28
  10e6c8: e24dd004     	sub	sp, sp, #4
  10e6cc: e1a07002     	mov	r7, r2
  10e6d0: e1a06001     	mov	r6, r1
  10e6d4: e1a05000     	mov	r5, r0
  10e6d8: eb125e8a     	bl	0x5a6108 <.text+0x596008> @ imm = #0x497a28
  10e6dc: e5950020     	ldr	r0, [r5, #0x20]
  10e6e0: e1a01006     	mov	r1, r6
  10e6e4: e1a02007     	mov	r2, r7
  10e6e8: eb1267e5     	bl	0x5a8684 <.text+0x598584> @ imm = #0x499f94
  10e6ec: e1a04000     	mov	r4, r0
  10e6f0: e1a00005     	mov	r0, r5
  10e6f4: eb125ff2     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x497fc8
  10e6f8: e1540007     	cmp	r4, r7
  10e6fc: 0a00005c     	beq	0x10e874 <.text+0xfe774> @ imm = #0x170
  10e700: eb1212b7     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x484adc
  10e704: e1a08000     	mov	r8, r0
  10e708: e5900000     	ldr	r0, [r0]
  10e70c: e350000b     	cmp	r0, #11
  10e710: 1a000058     	bne	0x10e878 <.text+0xfe778> @ imm = #0x160
  10e714: e59f9214     	ldr	r9, [pc, #0x214]        @ 0x10e930 <.text+0xfe830>
  10e718: e79f9009     	ldr	r9, [pc, r9]
  10e71c: e5990000     	ldr	r0, [r9]
  10e720: e59fa20c     	ldr	r10, [pc, #0x20c]       @ 0x10e934 <.text+0xfe834>
  10e724: e2401001     	sub	r1, r0, #1
  10e728: e0000190     	mul	r0, r0, r1
  10e72c: e79fa00a     	ldr	r10, [pc, r10]
  10e730: e3100001     	tst	r0, #1
  10e734: 0a000002     	beq	0x10e744 <.text+0xfe644> @ imm = #0x8
  10e738: e59a0000     	ldr	r0, [r10]
  10e73c: e3500009     	cmp	r0, #9
  10e740: ca000012     	bgt	0x10e790 <.text+0xfe690> @ imm = #0x48
  10e744: e3a00014     	mov	r0, #20
  10e748: eb0001fb     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x7ec
  10e74c: e1a00005     	mov	r0, r5
  10e750: eb125e6c     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4979b0
  10e754: e5950020     	ldr	r0, [r5, #0x20]
  10e758: e1a01006     	mov	r1, r6
  10e75c: e1a02007     	mov	r2, r7
  10e760: eb1267c7     	bl	0x5a8684 <.text+0x598584> @ imm = #0x499f1c
  10e764: e1a04000     	mov	r4, r0
  10e768: e1a00005     	mov	r0, r5
  10e76c: eb125fd4     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x497f50
  10e770: e5990000     	ldr	r0, [r9]
  10e774: e2401001     	sub	r1, r0, #1
  10e778: e0000190     	mul	r0, r0, r1
  10e77c: e3100001     	tst	r0, #1
  10e780: 0a00000d     	beq	0x10e7bc <.text+0xfe6bc> @ imm = #0x34
  10e784: e59a0000     	ldr	r0, [r10]
  10e788: e3500009     	cmp	r0, #9
  10e78c: da00000a     	ble	0x10e7bc <.text+0xfe6bc> @ imm = #0x28
  10e790: e3a00014     	mov	r0, #20
  10e794: eb0001e8     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x7a0
  10e798: e1a00005     	mov	r0, r5
  10e79c: eb125e59     	bl	0x5a6108 <.text+0x596008> @ imm = #0x497964
  10e7a0: e5950020     	ldr	r0, [r5, #0x20]
  10e7a4: e1a01006     	mov	r1, r6
  10e7a8: e1a02007     	mov	r2, r7
  10e7ac: eb1267b4     	bl	0x5a8684 <.text+0x598584> @ imm = #0x499ed0
  10e7b0: e1a00005     	mov	r0, r5
  10e7b4: eb125fc2     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x497f08
  10e7b8: eaffffe1     	b	0x10e744 <.text+0xfe644> @ imm = #-0x7c
  10e7bc: e1540007     	cmp	r4, r7
  10e7c0: 0a00002b     	beq	0x10e874 <.text+0xfe774> @ imm = #0xac
  10e7c4: e5980000     	ldr	r0, [r8]
  10e7c8: e350000b     	cmp	r0, #11
  10e7cc: 1a000029     	bne	0x10e878 <.text+0xfe778> @ imm = #0xa4
  10e7d0: e3a00014     	mov	r0, #20
  10e7d4: eb0001d8     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x760
  10e7d8: e1a00005     	mov	r0, r5
  10e7dc: eb125e49     	bl	0x5a6108 <.text+0x596008> @ imm = #0x497924
  10e7e0: e5950020     	ldr	r0, [r5, #0x20]
  10e7e4: e1a01006     	mov	r1, r6
  10e7e8: e1a02007     	mov	r2, r7
  10e7ec: eb1267a4     	bl	0x5a8684 <.text+0x598584> @ imm = #0x499e90
  10e7f0: e1a04000     	mov	r4, r0
  10e7f4: e1a00005     	mov	r0, r5
  10e7f8: eb125fb1     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x497ec4
  10e7fc: e1540007     	cmp	r4, r7
  10e800: 0a00001b     	beq	0x10e874 <.text+0xfe774> @ imm = #0x6c
  10e804: e5990000     	ldr	r0, [r9]
  10e808: e2401001     	sub	r1, r0, #1
  10e80c: e0000190     	mul	r0, r0, r1
  10e810: e3100001     	tst	r0, #1
  10e814: e5990000     	ldr	r0, [r9]
  10e818: e2401001     	sub	r1, r0, #1
  10e81c: e0010190     	mul	r1, r0, r1
  10e820: e5980000     	ldr	r0, [r8]
  10e824: e3110001     	tst	r1, #1
  10e828: 0a000002     	beq	0x10e838 <.text+0xfe738> @ imm = #0x8
  10e82c: e59a1000     	ldr	r1, [r10]
  10e830: e3510009     	cmp	r1, #9
  10e834: cafffff6     	bgt	0x10e814 <.text+0xfe714> @ imm = #-0x28
  10e838: e350000b     	cmp	r0, #11
  10e83c: 1a00000d     	bne	0x10e878 <.text+0xfe778> @ imm = #0x34
  10e840: e3a00014     	mov	r0, #20
  10e844: eb0001bc     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6f0
  10e848: e1a00005     	mov	r0, r5
  10e84c: eb125e2d     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4978b4
  10e850: e5950020     	ldr	r0, [r5, #0x20]
  10e854: e1a01006     	mov	r1, r6
  10e858: e1a02007     	mov	r2, r7
  10e85c: eb126788     	bl	0x5a8684 <.text+0x598584> @ imm = #0x499e20
  10e860: e1a04000     	mov	r4, r0
  10e864: e1a00005     	mov	r0, r5
  10e868: eb125f95     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x497e54
  10e86c: e1540007     	cmp	r4, r7
  10e870: 1a000003     	bne	0x10e884 <.text+0xfe784> @ imm = #0xc
  10e874: e1a04007     	mov	r4, r7
  10e878: e1a00004     	mov	r0, r4
  10e87c: e24bd01c     	sub	sp, r11, #28
  10e880: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  10e884: e5980000     	ldr	r0, [r8]
  10e888: e350000b     	cmp	r0, #11
  10e88c: 1afffff9     	bne	0x10e878 <.text+0xfe778> @ imm = #-0x1c
  10e890: e3a00014     	mov	r0, #20
  10e894: eb0001a8     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x6a0
  10e898: e1a00005     	mov	r0, r5
  10e89c: eb125e19     	bl	0x5a6108 <.text+0x596008> @ imm = #0x497864
  10e8a0: e5950020     	ldr	r0, [r5, #0x20]
  10e8a4: e1a01006     	mov	r1, r6
  10e8a8: e1a02007     	mov	r2, r7
  10e8ac: eb126774     	bl	0x5a8684 <.text+0x598584> @ imm = #0x499dd0
  10e8b0: e1a06000     	mov	r6, r0
  10e8b4: e1a00005     	mov	r0, r5
  10e8b8: eb125f81     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x497e04
  10e8bc: e1560007     	cmp	r6, r7
  10e8c0: e1a04007     	mov	r4, r7
  10e8c4: 0affffeb     	beq	0x10e878 <.text+0xfe778> @ imm = #-0x54
  10e8c8: e5980000     	ldr	r0, [r8]
  10e8cc: e350000b     	cmp	r0, #11
  10e8d0: 1a000014     	bne	0x10e928 <.text+0xfe828> @ imm = #0x50
  10e8d4: e5990000     	ldr	r0, [r9]
  10e8d8: e2401001     	sub	r1, r0, #1
  10e8dc: e0000190     	mul	r0, r0, r1
  10e8e0: e3100001     	tst	r0, #1
  10e8e4: 0a000002     	beq	0x10e8f4 <.text+0xfe7f4> @ imm = #0x8
  10e8e8: e59a0000     	ldr	r0, [r10]
  10e8ec: e3500009     	cmp	r0, #9
  10e8f0: ca000009     	bgt	0x10e91c <.text+0xfe81c> @ imm = #0x24
  10e8f4: e3a00014     	mov	r0, #20
  10e8f8: eb00018f     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x63c
  10e8fc: e5990000     	ldr	r0, [r9]
  10e900: e2401001     	sub	r1, r0, #1
  10e904: e0000190     	mul	r0, r0, r1
  10e908: e3100001     	tst	r0, #1
  10e90c: 0a000005     	beq	0x10e928 <.text+0xfe828> @ imm = #0x14
  10e910: e59a0000     	ldr	r0, [r10]
  10e914: e350000a     	cmp	r0, #10
  10e918: ba000002     	blt	0x10e928 <.text+0xfe828> @ imm = #0x8
  10e91c: e3a00014     	mov	r0, #20
  10e920: eb000185     	bl	0x10ef3c <.text+0xfee3c> @ imm = #0x614
  10e924: eafffff2     	b	0x10e8f4 <.text+0xfe7f4> @ imm = #-0x38
  10e928: e1a04006     	mov	r4, r6
  10e92c: eaffffd1     	b	0x10e878 <.text+0xfe778> @ imm = #-0xbc
  10e930: 004d0008     	subeq	r0, sp, r8
  10e934: 004d1078     	subeq	r1, sp, r8, ror r0
  10e938: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
  10e93c: e28db010     	add	r11, sp, #16
  10e940: e24dd008     	sub	sp, sp, #8
  10e944: e1a06000     	mov	r6, r0
  10e948: e5900020     	ldr	r0, [r0, #0x20]
  10e94c: e1a04002     	mov	r4, r2
  10e950: e28d2004     	add	r2, sp, #4
  10e954: e1a05001     	mov	r5, r1
  10e958: e305141b     	movw	r1, #0x541b
  10e95c: eb1222fb     	bl	0x597550 <.text+0x587450> @ imm = #0x488bec
  10e960: e1a01000     	mov	r1, r0
  10e964: e3a00000     	mov	r0, #0
  10e968: e3510000     	cmp	r1, #0
  10e96c: 1a000006     	bne	0x10e98c <.text+0xfe88c> @ imm = #0x18
  10e970: e59d1004     	ldr	r1, [sp, #0x4]
  10e974: e3510000     	cmp	r1, #0
  10e978: 0a000003     	beq	0x10e98c <.text+0xfe88c> @ imm = #0xc
  10e97c: e5960020     	ldr	r0, [r6, #0x20]
  10e980: e1a01005     	mov	r1, r5
  10e984: e1a02004     	mov	r2, r4
  10e988: eb1266c2     	bl	0x5a8498 <.text+0x598398> @ imm = #0x499b08
  10e98c: e24bd010     	sub	sp, r11, #16
  10e990: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
  10e994: e5900020     	ldr	r0, [r0, #0x20]
  10e998: e3a01002     	mov	r1, #2
  10e99c: ea125664     	b	0x5a4334 <.text+0x594234> @ imm = #0x495990
  10e9a0: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
  10e9a4: e28db010     	add	r11, sp, #16
  10e9a8: e1a04000     	mov	r4, r0
  10e9ac: e590001c     	ldr	r0, [r0, #0x1c]
  10e9b0: e3500000     	cmp	r0, #0
  10e9b4: 0a000002     	beq	0x10e9c4 <.text+0xfe8c4> @ imm = #0x8
  10e9b8: eb1214b3     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4852cc
  10e9bc: e3a00000     	mov	r0, #0
  10e9c0: e584001c     	str	r0, [r4, #0x1c]
  10e9c4: e5940020     	ldr	r0, [r4, #0x20]
  10e9c8: e3700001     	cmn	r0, #1
  10e9cc: 0a000002     	beq	0x10e9dc <.text+0xfe8dc> @ imm = #0x8
  10e9d0: eb1265d1     	bl	0x5a811c <.text+0x59801c> @ imm = #0x499744
  10e9d4: e3e00000     	mvn	r0, #0
  10e9d8: e5840020     	str	r0, [r4, #0x20]
  10e9dc: e59f5070     	ldr	r5, [pc, #0x70]         @ 0x10ea54 <.text+0xfe954>
  10e9e0: e79f5005     	ldr	r5, [pc, r5]
  10e9e4: e5950000     	ldr	r0, [r5]
  10e9e8: e59f6068     	ldr	r6, [pc, #0x68]         @ 0x10ea58 <.text+0xfe958>
  10e9ec: e2401001     	sub	r1, r0, #1
  10e9f0: e0000190     	mul	r0, r0, r1
  10e9f4: e79f6006     	ldr	r6, [pc, r6]
  10e9f8: e3100001     	tst	r0, #1
  10e9fc: 0a000002     	beq	0x10ea0c <.text+0xfe90c> @ imm = #0x8
  10ea00: e5960000     	ldr	r0, [r6]
  10ea04: e3500009     	cmp	r0, #9
  10ea08: ca00000b     	bgt	0x10ea3c <.text+0xfe93c> @ imm = #0x2c
  10ea0c: e1a00004     	mov	r0, r4
  10ea10: eb125da8     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x4976a0
  10ea14: e3a00000     	mov	r0, #0
  10ea18: e5840024     	str	r0, [r4, #0x24]
  10ea1c: e5950000     	ldr	r0, [r5]
  10ea20: e2401001     	sub	r1, r0, #1
  10ea24: e0000190     	mul	r0, r0, r1
  10ea28: e3100001     	tst	r0, #1
  10ea2c: 0a000007     	beq	0x10ea50 <.text+0xfe950> @ imm = #0x1c
  10ea30: e5960000     	ldr	r0, [r6]
  10ea34: e3500009     	cmp	r0, #9
  10ea38: da000004     	ble	0x10ea50 <.text+0xfe950> @ imm = #0x10
  10ea3c: e1a00004     	mov	r0, r4
  10ea40: eb125d9c     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x497670
  10ea44: e3a00000     	mov	r0, #0
  10ea48: e5840024     	str	r0, [r4, #0x24]
  10ea4c: eaffffee     	b	0x10ea0c <.text+0xfe90c> @ imm = #-0x48
  10ea50: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
  10ea54: 004d08e0     	subeq	r0, sp, r0, ror #17
  10ea58: 004cff48     	subeq	pc, r12, r8, asr #30
  10ea5c: e92d4800     	push	{r11, lr}
  10ea60: e59fc2a0     	ldr	r12, [pc, #0x2a0]       @ 0x10ed08 <.text+0xfec08>
  10ea64: e79fc00c     	ldr	r12, [pc, r12]
  10ea68: e59c0000     	ldr	r0, [r12]
  10ea6c: e2401001     	sub	r1, r0, #1
  10ea70: e0000190     	mul	r0, r0, r1
  10ea74: e3100001     	tst	r0, #1
  10ea78: e59c0000     	ldr	r0, [r12]
  10ea7c: e59fe288     	ldr	lr, [pc, #0x288]        @ 0x10ed0c <.text+0xfec0c>
  10ea80: e2401001     	sub	r1, r0, #1
  10ea84: e0000190     	mul	r0, r0, r1
  10ea88: e79fe00e     	ldr	lr, [pc, lr]
  10ea8c: e3100001     	tst	r0, #1
  10ea90: 0a000002     	beq	0x10eaa0 <.text+0xfe9a0> @ imm = #0x8
  10ea94: e59e0000     	ldr	r0, [lr]
  10ea98: e3500009     	cmp	r0, #9
  10ea9c: cafffff5     	bgt	0x10ea78 <.text+0xfe978> @ imm = #-0x2c
  10eaa0: e3a02000     	mov	r2, #0
  10eaa4: e3520000     	cmp	r2, #0
  10eaa8: 1a000007     	bne	0x10eacc <.text+0xfe9cc> @ imm = #0x1c
  10eaac: e59f325c     	ldr	r3, [pc, #0x25c]        @ 0x10ed10 <.text+0xfec10>
  10eab0: e08f3003     	add	r3, pc, r3
  10eab4: e7d30002     	ldrb	r0, [r3, r2]
  10eab8: e22000e0     	eor	r0, r0, #224
  10eabc: e7c30002     	strb	r0, [r3, r2]
  10eac0: e2822001     	add	r2, r2, #1
  10eac4: e3520007     	cmp	r2, #7
  10eac8: 1afffff9     	bne	0x10eab4 <.text+0xfe9b4> @ imm = #-0x1c
  10eacc: e3a02000     	mov	r2, #0
  10ead0: e3520000     	cmp	r2, #0
  10ead4: 1a00001d     	bne	0x10eb50 <.text+0xfea50> @ imm = #0x74
  10ead8: e59f3234     	ldr	r3, [pc, #0x234]        @ 0x10ed14 <.text+0xfec14>
  10eadc: e08f3003     	add	r3, pc, r3
  10eae0: ea000002     	b	0x10eaf0 <.text+0xfe9f0> @ imm = #0x8
  10eae4: e3500021     	cmp	r0, #33
  10eae8: e1a02000     	mov	r2, r0
  10eaec: 0a000017     	beq	0x10eb50 <.text+0xfea50> @ imm = #0x5c
  10eaf0: e59c0000     	ldr	r0, [r12]
  10eaf4: e2401001     	sub	r1, r0, #1
  10eaf8: e0000190     	mul	r0, r0, r1
  10eafc: e3100001     	tst	r0, #1
  10eb00: 0a000002     	beq	0x10eb10 <.text+0xfea10> @ imm = #0x8
  10eb04: e59e0000     	ldr	r0, [lr]
  10eb08: e3500009     	cmp	r0, #9
  10eb0c: ca00000b     	bgt	0x10eb40 <.text+0xfea40> @ imm = #0x2c
  10eb10: e7d30002     	ldrb	r0, [r3, r2]
  10eb14: e22000aa     	eor	r0, r0, #170
  10eb18: e7c30002     	strb	r0, [r3, r2]
  10eb1c: e59c0000     	ldr	r0, [r12]
  10eb20: e2401001     	sub	r1, r0, #1
  10eb24: e0010190     	mul	r1, r0, r1
  10eb28: e2820001     	add	r0, r2, #1
  10eb2c: e3110001     	tst	r1, #1
  10eb30: 0affffeb     	beq	0x10eae4 <.text+0xfe9e4> @ imm = #-0x54
  10eb34: e59e1000     	ldr	r1, [lr]
  10eb38: e3510009     	cmp	r1, #9
  10eb3c: daffffe8     	ble	0x10eae4 <.text+0xfe9e4> @ imm = #-0x60
  10eb40: e7d30002     	ldrb	r0, [r3, r2]
  10eb44: e22000aa     	eor	r0, r0, #170
  10eb48: e7c30002     	strb	r0, [r3, r2]
  10eb4c: eaffffef     	b	0x10eb10 <.text+0xfea10> @ imm = #-0x44
  10eb50: e3a02000     	mov	r2, #0
  10eb54: e3520000     	cmp	r2, #0
  10eb58: 1a000007     	bne	0x10eb7c <.text+0xfea7c> @ imm = #0x1c
  10eb5c: e59f31b4     	ldr	r3, [pc, #0x1b4]        @ 0x10ed18 <.text+0xfec18>
  10eb60: e08f3003     	add	r3, pc, r3
  10eb64: e7d30002     	ldrb	r0, [r3, r2]
  10eb68: e220001d     	eor	r0, r0, #29
  10eb6c: e7c30002     	strb	r0, [r3, r2]
  10eb70: e2822001     	add	r2, r2, #1
  10eb74: e352000b     	cmp	r2, #11
  10eb78: 1afffff9     	bne	0x10eb64 <.text+0xfea64> @ imm = #-0x1c
  10eb7c: e3a02000     	mov	r2, #0
  10eb80: e3520000     	cmp	r2, #0
  10eb84: 1a00001d     	bne	0x10ec00 <.text+0xfeb00> @ imm = #0x74
  10eb88: e59f318c     	ldr	r3, [pc, #0x18c]        @ 0x10ed1c <.text+0xfec1c>
  10eb8c: e08f3003     	add	r3, pc, r3
  10eb90: ea000002     	b	0x10eba0 <.text+0xfeaa0> @ imm = #0x8
  10eb94: e3500013     	cmp	r0, #19
  10eb98: e1a02000     	mov	r2, r0
  10eb9c: 0a000017     	beq	0x10ec00 <.text+0xfeb00> @ imm = #0x5c
  10eba0: e59c0000     	ldr	r0, [r12]
  10eba4: e2401001     	sub	r1, r0, #1
  10eba8: e0000190     	mul	r0, r0, r1
  10ebac: e3100001     	tst	r0, #1
  10ebb0: 0a000002     	beq	0x10ebc0 <.text+0xfeac0> @ imm = #0x8
  10ebb4: e59e0000     	ldr	r0, [lr]
  10ebb8: e3500009     	cmp	r0, #9
  10ebbc: ca00000b     	bgt	0x10ebf0 <.text+0xfeaf0> @ imm = #0x2c
  10ebc0: e7d30002     	ldrb	r0, [r3, r2]
  10ebc4: e22000cf     	eor	r0, r0, #207
  10ebc8: e7c30002     	strb	r0, [r3, r2]
  10ebcc: e59c0000     	ldr	r0, [r12]
  10ebd0: e2401001     	sub	r1, r0, #1
  10ebd4: e0010190     	mul	r1, r0, r1
  10ebd8: e2820001     	add	r0, r2, #1
  10ebdc: e3110001     	tst	r1, #1
  10ebe0: 0affffeb     	beq	0x10eb94 <.text+0xfea94> @ imm = #-0x54
  10ebe4: e59e1000     	ldr	r1, [lr]
  10ebe8: e3510009     	cmp	r1, #9
  10ebec: daffffe8     	ble	0x10eb94 <.text+0xfea94> @ imm = #-0x60
  10ebf0: e7d30002     	ldrb	r0, [r3, r2]
  10ebf4: e22000cf     	eor	r0, r0, #207
  10ebf8: e7c30002     	strb	r0, [r3, r2]
  10ebfc: eaffffef     	b	0x10ebc0 <.text+0xfeac0> @ imm = #-0x44
  10ec00: e59c0000     	ldr	r0, [r12]
  10ec04: e2401001     	sub	r1, r0, #1
  10ec08: e0000190     	mul	r0, r0, r1
  10ec0c: e3100001     	tst	r0, #1
  10ec10: e59c0000     	ldr	r0, [r12]
  10ec14: e2401001     	sub	r1, r0, #1
  10ec18: e0000190     	mul	r0, r0, r1
  10ec1c: e3100001     	tst	r0, #1
  10ec20: 0a000002     	beq	0x10ec30 <.text+0xfeb30> @ imm = #0x8
  10ec24: e59e0000     	ldr	r0, [lr]
  10ec28: e3500009     	cmp	r0, #9
  10ec2c: cafffff7     	bgt	0x10ec10 <.text+0xfeb10> @ imm = #-0x24
  10ec30: e59f30e8     	ldr	r3, [pc, #0xe8]         @ 0x10ed20 <.text+0xfec20>
  10ec34: e3a02000     	mov	r2, #0
  10ec38: e08f3003     	add	r3, pc, r3
  10ec3c: e7d30002     	ldrb	r0, [r3, r2]
  10ec40: e2200065     	eor	r0, r0, #101
  10ec44: e7c30002     	strb	r0, [r3, r2]
  10ec48: e2822001     	add	r2, r2, #1
  10ec4c: e352001d     	cmp	r2, #29
  10ec50: 1afffff9     	bne	0x10ec3c <.text+0xfeb3c> @ imm = #-0x1c
  10ec54: e3a02000     	mov	r2, #0
  10ec58: e3520000     	cmp	r2, #0
  10ec5c: 1a00001d     	bne	0x10ecd8 <.text+0xfebd8> @ imm = #0x74
  10ec60: e59f30bc     	ldr	r3, [pc, #0xbc]         @ 0x10ed24 <.text+0xfec24>
  10ec64: e08f3003     	add	r3, pc, r3
  10ec68: ea000002     	b	0x10ec78 <.text+0xfeb78> @ imm = #0x8
  10ec6c: e350001d     	cmp	r0, #29
  10ec70: e1a02000     	mov	r2, r0
  10ec74: 0a000017     	beq	0x10ecd8 <.text+0xfebd8> @ imm = #0x5c
  10ec78: e59c0000     	ldr	r0, [r12]
  10ec7c: e2401001     	sub	r1, r0, #1
  10ec80: e0000190     	mul	r0, r0, r1
  10ec84: e3100001     	tst	r0, #1
  10ec88: 0a000002     	beq	0x10ec98 <.text+0xfeb98> @ imm = #0x8
  10ec8c: e59e0000     	ldr	r0, [lr]
  10ec90: e3500009     	cmp	r0, #9
  10ec94: ca00000b     	bgt	0x10ecc8 <.text+0xfebc8> @ imm = #0x2c
  10ec98: e7d30002     	ldrb	r0, [r3, r2]
  10ec9c: e220009e     	eor	r0, r0, #158
  10eca0: e7c30002     	strb	r0, [r3, r2]
  10eca4: e59c0000     	ldr	r0, [r12]
  10eca8: e2401001     	sub	r1, r0, #1
  10ecac: e0010190     	mul	r1, r0, r1
  10ecb0: e2820001     	add	r0, r2, #1
  10ecb4: e3110001     	tst	r1, #1
  10ecb8: 0affffeb     	beq	0x10ec6c <.text+0xfeb6c> @ imm = #-0x54
  10ecbc: e59e1000     	ldr	r1, [lr]
  10ecc0: e3510009     	cmp	r1, #9
  10ecc4: daffffe8     	ble	0x10ec6c <.text+0xfeb6c> @ imm = #-0x60
  10ecc8: e7d30002     	ldrb	r0, [r3, r2]
  10eccc: e220009e     	eor	r0, r0, #158
  10ecd0: e7c30002     	strb	r0, [r3, r2]
  10ecd4: eaffffef     	b	0x10ec98 <.text+0xfeb98> @ imm = #-0x44
  10ecd8: e3a00000     	mov	r0, #0
  10ecdc: e3500000     	cmp	r0, #0
  10ece0: 18bd8800     	popne	{r11, pc}
  10ece4: e59f103c     	ldr	r1, [pc, #0x3c]         @ 0x10ed28 <.text+0xfec28>
  10ece8: e08f1001     	add	r1, pc, r1
  10ecec: e7d12000     	ldrb	r2, [r1, r0]
  10ecf0: e2222070     	eor	r2, r2, #112
  10ecf4: e7c12000     	strb	r2, [r1, r0]
  10ecf8: e2800001     	add	r0, r0, #1
  10ecfc: e350001b     	cmp	r0, #27
  10ed00: 1afffff9     	bne	0x10ecec <.text+0xfebec> @ imm = #-0x1c
  10ed04: e8bd8800     	pop	{r11, pc}
  10ed08: 004cfbec     	subeq	pc, r12, r12, ror #23
  10ed0c: 004d0c48     	subeq	r0, sp, r8, asr #24
  10ed10: 004df100     	subeq	pc, sp, r0, lsl #2
  10ed14: 004df0db     	<unknown>
  10ed18: 004df078     	subeq	pc, sp, r8, ror r0
  10ed1c: 004df057     	subeq	pc, sp, r7, asr r0
  10ed20: 004defbe     	strheq	lr, [sp], #-254
  10ed24: 004defaf     	subeq	lr, sp, pc, lsr #31
  10ed28: 004def48     	subeq	lr, sp, r8, asr #30
  10ed2c: e92d4bf0     	push	{r4, r5, r6, r7, r8, r9, r11, lr}
  10ed30: e28db018     	add	r11, sp, #24
  10ed34: e24dd010     	sub	sp, sp, #16
  10ed38: e3700001     	cmn	r0, #1
  10ed3c: da000010     	ble	0x10ed84 <.text+0xfec84> @ imm = #0x40
  10ed40: e59f9140     	ldr	r9, [pc, #0x140]        @ 0x10ee88 <.text+0xfed88>
  10ed44: e79f9009     	ldr	r9, [pc, r9]
  10ed48: e5991000     	ldr	r1, [r9]
  10ed4c: e59f8138     	ldr	r8, [pc, #0x138]        @ 0x10ee8c <.text+0xfed8c>
  10ed50: e2412001     	sub	r2, r1, #1
  10ed54: e0020291     	mul	r2, r1, r2
  10ed58: e79f8008     	ldr	r8, [pc, r8]
  10ed5c: e3041240     	movw	r1, #0x4240
  10ed60: e340100f     	movt	r1, #0xf
  10ed64: e3120001     	tst	r2, #1
  10ed68: e3042dd3     	movw	r2, #0x4dd3
  10ed6c: e3412062     	movt	r2, #0x1062
  10ed70: 0a000008     	beq	0x10ed98 <.text+0xfec98> @ imm = #0x20
  10ed74: e5983000     	ldr	r3, [r8]
  10ed78: e3530009     	cmp	r3, #9
  10ed7c: ca000015     	bgt	0x10edd8 <.text+0xfecd8> @ imm = #0x54
  10ed80: ea000004     	b	0x10ed98 <.text+0xfec98> @ imm = #0x10
  10ed84: eb121116     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x484458
  10ed88: e3a01016     	mov	r1, #22
  10ed8c: e3e05000     	mvn	r5, #0
  10ed90: e5801000     	str	r1, [r0]
  10ed94: ea000038     	b	0x10ee7c <.text+0xfed7c> @ imm = #0xe0
  10ed98: e0853290     	umull	r3, r5, r0, r2
  10ed9c: e3a04ffa     	mov	r4, #1000
  10eda0: e5993000     	ldr	r3, [r9]
  10eda4: e3a06000     	mov	r6, #0
  10eda8: e2437001     	sub	r7, r3, #1
  10edac: e0070793     	mul	r7, r3, r7
  10edb0: e5983000     	ldr	r3, [r8]
  10edb4: e1a05325     	lsr	r5, r5, #6
  10edb8: e0640495     	mls	r4, r5, r4, r0
  10edbc: e88d0060     	stm	sp, {r5, r6}
  10edc0: e3170001     	tst	r7, #1
  10edc4: e0040194     	mul	r4, r4, r1
  10edc8: e58d4008     	str	r4, [sp, #0x8]
  10edcc: 0a000009     	beq	0x10edf8 <.text+0xfecf8> @ imm = #0x24
  10edd0: e3530009     	cmp	r3, #9
  10edd4: da000007     	ble	0x10edf8 <.text+0xfecf8> @ imm = #0x1c
  10edd8: e0873290     	umull	r3, r7, r0, r2
  10eddc: e3a06000     	mov	r6, #0
  10ede0: e1a03327     	lsr	r3, r7, #6
  10ede4: e3a07ffa     	mov	r7, #1000
  10ede8: e0670793     	mls	r7, r3, r7, r0
  10edec: e0070197     	mul	r7, r7, r1
  10edf0: e88d00c8     	stm	sp, {r3, r6, r7}
  10edf4: eaffffe7     	b	0x10ed98 <.text+0xfec98> @ imm = #-0x64
  10edf8: e1a0400d     	mov	r4, sp
  10edfc: e5990000     	ldr	r0, [r9]
  10ee00: e2401001     	sub	r1, r0, #1
  10ee04: e0000190     	mul	r0, r0, r1
  10ee08: e3100001     	tst	r0, #1
  10ee0c: 0a000002     	beq	0x10ee1c <.text+0xfed1c> @ imm = #0x8
  10ee10: e5980000     	ldr	r0, [r8]
  10ee14: e3500009     	cmp	r0, #9
  10ee18: ca00000b     	bgt	0x10ee4c <.text+0xfed4c> @ imm = #0x2c
  10ee1c: e1a00004     	mov	r0, r4
  10ee20: e1a01004     	mov	r1, r4
  10ee24: eb1261d6     	bl	0x5a7584 <.text+0x597484> @ imm = #0x498758
  10ee28: e1a05000     	mov	r5, r0
  10ee2c: e5990000     	ldr	r0, [r9]
  10ee30: e2401001     	sub	r1, r0, #1
  10ee34: e0000190     	mul	r0, r0, r1
  10ee38: e3100001     	tst	r0, #1
  10ee3c: 0a000006     	beq	0x10ee5c <.text+0xfed5c> @ imm = #0x18
  10ee40: e5980000     	ldr	r0, [r8]
  10ee44: e3500009     	cmp	r0, #9
  10ee48: da000003     	ble	0x10ee5c <.text+0xfed5c> @ imm = #0xc
  10ee4c: e1a00004     	mov	r0, r4
  10ee50: e1a01004     	mov	r1, r4
  10ee54: eb1261ca     	bl	0x5a7584 <.text+0x597484> @ imm = #0x498728
  10ee58: eaffffef     	b	0x10ee1c <.text+0xfed1c> @ imm = #-0x44
  10ee5c: e3550000     	cmp	r5, #0
  10ee60: 0a000004     	beq	0x10ee78 <.text+0xfed78> @ imm = #0x10
  10ee64: eb1210de     	bl	0x5931e4 <.text+0x5830e4> @ imm = #0x484378
  10ee68: e5900000     	ldr	r0, [r0]
  10ee6c: e3500004     	cmp	r0, #4
  10ee70: 0affffe1     	beq	0x10edfc <.text+0xfecfc> @ imm = #-0x7c
  10ee74: ea000000     	b	0x10ee7c <.text+0xfed7c> @ imm = #0x0
  10ee78: e3a05000     	mov	r5, #0
  10ee7c: e1a00005     	mov	r0, r5
  10ee80: e24bd018     	sub	sp, r11, #24
  10ee84: e8bd8bf0     	pop	{r4, r5, r6, r7, r8, r9, r11, pc}
  10ee88: 004d00e0     	subeq	r0, sp, r0, ror #1
  10ee8c: 004d0640     	subeq	r0, sp, r0, asr #12
  10ee90: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
  10ee94: e28db010     	add	r11, sp, #16
  10ee98: e3a01d07     	mov	r1, #448
  10ee9c: eb12120e     	bl	0x5936dc <.text+0x5835dc> @ imm = #0x484838
  10eea0: e3700001     	cmn	r0, #1
  10eea4: 0a00000d     	beq	0x10eee0 <.text+0xfede0> @ imm = #0x34
  10eea8: e59f5084     	ldr	r5, [pc, #0x84]         @ 0x10ef34 <.text+0xfee34>
  10eeac: e1a04000     	mov	r4, r0
  10eeb0: e79f5005     	ldr	r5, [pc, r5]
  10eeb4: e5950000     	ldr	r0, [r5]
  10eeb8: e59f6078     	ldr	r6, [pc, #0x78]         @ 0x10ef38 <.text+0xfee38>
  10eebc: e2401001     	sub	r1, r0, #1
  10eec0: e0000190     	mul	r0, r0, r1
  10eec4: e79f6006     	ldr	r6, [pc, r6]
  10eec8: e3100001     	tst	r0, #1
  10eecc: 0a000005     	beq	0x10eee8 <.text+0xfede8> @ imm = #0x14
  10eed0: e5960000     	ldr	r0, [r6]
  10eed4: e3500009     	cmp	r0, #9
  10eed8: ca00000f     	bgt	0x10ef1c <.text+0xfee1c> @ imm = #0x3c
  10eedc: ea000001     	b	0x10eee8 <.text+0xfede8> @ imm = #0x4
  10eee0: e3e00000     	mvn	r0, #0
  10eee4: ea000011     	b	0x10ef30 <.text+0xfee30> @ imm = #0x44
  10eee8: e1a00004     	mov	r0, r4
  10eeec: eb126499     	bl	0x5a8158 <.text+0x598058> @ imm = #0x499264
  10eef0: e1a00004     	mov	r0, r4
  10eef4: eb126488     	bl	0x5a811c <.text+0x59801c> @ imm = #0x499220
  10eef8: e5950000     	ldr	r0, [r5]
  10eefc: e2401001     	sub	r1, r0, #1
  10ef00: e0010190     	mul	r1, r0, r1
  10ef04: e3a00000     	mov	r0, #0
  10ef08: e3110001     	tst	r1, #1
  10ef0c: 0a000007     	beq	0x10ef30 <.text+0xfee30> @ imm = #0x1c
  10ef10: e5961000     	ldr	r1, [r6]
  10ef14: e3510009     	cmp	r1, #9
  10ef18: da000004     	ble	0x10ef30 <.text+0xfee30> @ imm = #0x10
  10ef1c: e1a00004     	mov	r0, r4
  10ef20: eb12648c     	bl	0x5a8158 <.text+0x598058> @ imm = #0x499230
  10ef24: e1a00004     	mov	r0, r4
  10ef28: eb12647b     	bl	0x5a811c <.text+0x59801c> @ imm = #0x4991ec
  10ef2c: eaffffed     	b	0x10eee8 <.text+0xfede8> @ imm = #-0x4c
  10ef30: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
  10ef34: 004cff78     	subeq	pc, r12, r8, ror pc
  10ef38: 004cf8c0     	subeq	pc, r12, r0, asr #17

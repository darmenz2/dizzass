
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
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

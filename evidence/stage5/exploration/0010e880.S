
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
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

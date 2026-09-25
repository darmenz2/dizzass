
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  117f7c: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  117f80: e28db01c     	add	r11, sp, #28
  117f84: e24dd00c     	sub	sp, sp, #12
  117f88: e59fa1b8     	ldr	r10, [pc, #0x1b8]       @ 0x118148 <.text+0x108048>
  117f8c: e1a09000     	mov	r9, r0
  117f90: e1a08001     	mov	r8, r1
  117f94: e1a05002     	mov	r5, r2
  117f98: e3a02001     	mov	r2, #1
  117f9c: e79fa00a     	ldr	r10, [pc, r10]
  117fa0: e59a0000     	ldr	r0, [r10]
  117fa4: e59f41a0     	ldr	r4, [pc, #0x1a0]        @ 0x11814c <.text+0x10804c>
  117fa8: e2401001     	sub	r1, r0, #1
  117fac: e0000190     	mul	r0, r0, r1
  117fb0: e79f4004     	ldr	r4, [pc, r4]
  117fb4: e5941000     	ldr	r1, [r4]
  117fb8: e1c20000     	bic	r0, r2, r0
  117fbc: e3a02000     	mov	r2, #0
  117fc0: e351000a     	cmp	r1, #10
  117fc4: b3002001     	movwlt	r2, #0x1
  117fc8: e1800002     	orr	r0, r0, r2
  117fcc: e3590000     	cmp	r9, #0
  117fd0: 0a000002     	beq	0x117fe0 <.text+0x107ee0> @ imm = #0x8
  117fd4: e3500000     	cmp	r0, #0
  117fd8: 1a000022     	bne	0x118068 <.text+0x107f68> @ imm = #0x88
  117fdc: ea00002d     	b	0x118098 <.text+0x107f98> @ imm = #0xb4
  117fe0: e59f5168     	ldr	r5, [pc, #0x168]        @ 0x118150 <.text+0x108050>
  117fe4: e3500000     	cmp	r0, #0
  117fe8: e08f5005     	add	r5, pc, r5
  117fec: 0a000012     	beq	0x11803c <.text+0x107f3c> @ imm = #0x48
  117ff0: e59f015c     	ldr	r0, [pc, #0x15c]        @ 0x118154 <.text+0x108054>
  117ff4: e3a03001     	mov	r3, #1
  117ff8: e59f1158     	ldr	r1, [pc, #0x158]        @ 0x118158 <.text+0x108058>
  117ffc: e59f2158     	ldr	r2, [pc, #0x158]        @ 0x11815c <.text+0x10805c>
  118000: e08f0000     	add	r0, pc, r0
  118004: e08f1001     	add	r1, pc, r1
  118008: e88d0028     	stm	sp, {r3, r5}
  11800c: e08f2002     	add	r2, pc, r2
  118010: e3a03016     	mov	r3, #22
  118014: ebff882a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1df58
  118018: e59a0000     	ldr	r0, [r10]
  11801c: e2401001     	sub	r1, r0, #1
  118020: e0010190     	mul	r1, r0, r1
  118024: e3e00000     	mvn	r0, #0
  118028: e3110001     	tst	r1, #1
  11802c: 0a000033     	beq	0x118100 <.text+0x108000> @ imm = #0xcc
  118030: e5941000     	ldr	r1, [r4]
  118034: e351000a     	cmp	r1, #10
  118038: ba000030     	blt	0x118100 <.text+0x108000> @ imm = #0xc0
  11803c: e59f011c     	ldr	r0, [pc, #0x11c]        @ 0x118160 <.text+0x108060>
  118040: e3a03001     	mov	r3, #1
  118044: e59f1118     	ldr	r1, [pc, #0x118]        @ 0x118164 <.text+0x108064>
  118048: e59f2118     	ldr	r2, [pc, #0x118]        @ 0x118168 <.text+0x108068>
  11804c: e08f0000     	add	r0, pc, r0
  118050: e08f1001     	add	r1, pc, r1
  118054: e88d0028     	stm	sp, {r3, r5}
  118058: e08f2002     	add	r2, pc, r2
  11805c: e3a03016     	mov	r3, #22
  118060: ebff8817     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1dfa4
  118064: eaffffe1     	b	0x117ff0 <.text+0x107ef0> @ imm = #-0x7c
  118068: e2857002     	add	r7, r5, #2
  11806c: e1a00007     	mov	r0, r7
  118070: eb11f01d     	bl	0x5940ec <.text+0x583fec> @ imm = #0x47c074
  118074: e1a06000     	mov	r6, r0
  118078: e59a0000     	ldr	r0, [r10]
  11807c: e2401001     	sub	r1, r0, #1
  118080: e0000190     	mul	r0, r0, r1
  118084: e3100001     	tst	r0, #1
  118088: 0a000005     	beq	0x1180a4 <.text+0x107fa4> @ imm = #0x14
  11808c: e5940000     	ldr	r0, [r4]
  118090: e3500009     	cmp	r0, #9
  118094: da000002     	ble	0x1180a4 <.text+0x107fa4> @ imm = #0x8
  118098: e2850002     	add	r0, r5, #2
  11809c: eb11f012     	bl	0x5940ec <.text+0x583fec> @ imm = #0x47c048
  1180a0: eafffff0     	b	0x118068 <.text+0x107f68> @ imm = #-0x40
  1180a4: e3560000     	cmp	r6, #0
  1180a8: 0a000016     	beq	0x118108 <.text+0x108008> @ imm = #0x58
  1180ac: e30a1a55     	movw	r1, #0xaa55
  1180b0: e1a00006     	mov	r0, r6
  1180b4: e0c010b2     	strh	r1, [r0], #2
  1180b8: e1a01008     	mov	r1, r8
  1180bc: e1a02005     	mov	r2, r5
  1180c0: eb122b88     	bl	0x5a2ee8 <.text+0x592de8> @ imm = #0x48ae20
  1180c4: e59f50b0     	ldr	r5, [pc, #0xb0]         @ 0x11817c <.text+0x10807c>
  1180c8: e08f5005     	add	r5, pc, r5
  1180cc: e1a00005     	mov	r0, r5
  1180d0: eb12380c     	bl	0x5a6108 <.text+0x596008> @ imm = #0x48e030
  1180d4: e1a00009     	mov	r0, r9
  1180d8: e1a01006     	mov	r1, r6
  1180dc: e1a02007     	mov	r2, r7
  1180e0: ebffd976     	bl	0x10e6c0 <.text+0xfe5c0> @ imm = #-0x9a28
  1180e4: e1a04000     	mov	r4, r0
  1180e8: e1a00005     	mov	r0, r5
  1180ec: eb123974     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x48e5d0
  1180f0: e1a00006     	mov	r0, r6
  1180f4: eb11eee4     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x47bb90
  1180f8: e0540007     	subs	r0, r4, r7
  1180fc: 13e00000     	mvnne	r0, #0
  118100: e24bd01c     	sub	sp, r11, #28
  118104: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  118108: e59f005c     	ldr	r0, [pc, #0x5c]         @ 0x11816c <.text+0x10806c>
  11810c: e3a07001     	mov	r7, #1
  118110: e59f1058     	ldr	r1, [pc, #0x58]         @ 0x118170 <.text+0x108070>
  118114: e59f2058     	ldr	r2, [pc, #0x58]         @ 0x118174 <.text+0x108074>
  118118: e08f0000     	add	r0, pc, r0
  11811c: e59f3054     	ldr	r3, [pc, #0x54]         @ 0x118178 <.text+0x108078>
  118120: e08f1001     	add	r1, pc, r1
  118124: e08f2002     	add	r2, pc, r2
  118128: e58d7000     	str	r7, [sp]
  11812c: e08f3003     	add	r3, pc, r3
  118130: e58d3004     	str	r3, [sp, #0x4]
  118134: e3a0301c     	mov	r3, #28
  118138: ebff87e1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1e07c
  11813c: e3e00000     	mvn	r0, #0
  118140: e24bd01c     	sub	sp, r11, #28
  118144: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  118148: 004c6e88     	subeq	r6, r12, r8, lsl #29
  11814c: 004c73e8     	subeq	r7, r12, r8, ror #7
  118150: 004d62ab     	subeq	r6, sp, r11, lsr #5
  118154: 004d625c     	subeq	r6, sp, r12, asr r2
  118158: 004d625f     	subeq	r6, sp, pc, asr r2
  11815c: 004d627c     	subeq	r6, sp, r12, ror r2
  118160: 004d6210     	subeq	r6, sp, r0, lsl r2
  118164: 004d6213     	subeq	r6, sp, r3, lsl r2
  118168: 004d6230     	subeq	r6, sp, r0, lsr r2
  11816c: 004d6144     	subeq	r6, sp, r4, asr #2
  118170: 004d6143     	subeq	r6, sp, r3, asr #2
  118174: 004d6164     	subeq	r6, sp, r4, ror #2
  118178: 004d6184     	subeq	r6, sp, r4, lsl #3
  11817c: 0053de88     	subseq	sp, r3, r8, lsl #29

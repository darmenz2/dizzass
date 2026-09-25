
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c0e40: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   c0e44: e28db018     	add	r11, sp, #24
   c0e48: e24dd010     	sub	sp, sp, #16
   c0e4c: e1a05000     	mov	r5, r0
   c0e50: eb00f604     	bl	0xfe668 <.text+0xee568> @ imm = #0x3d810
   c0e54: e5954018     	ldr	r4, [r5, #0x18]
   c0e58: e3540000     	cmp	r4, #0
   c0e5c: 4a000012     	bmi	0xc0eac <.text+0xb0dac> @ imm = #0x48
   c0e60: e1540000     	cmp	r4, r0
   c0e64: aa000010     	bge	0xc0eac <.text+0xb0dac> @ imm = #0x40
   c0e68: e5d50318     	ldrb	r0, [r5, #0x318]
   c0e6c: e3a06000     	mov	r6, #0
   c0e70: e3500000     	cmp	r0, #0
   c0e74: 1a000085     	bne	0xc1090 <.text+0xb0f90> @ imm = #0x214
   c0e78: e59f8240     	ldr	r8, [pc, #0x240]        @ 0xc10c0 <.text+0xb0fc0>
   c0e7c: e79f8008     	ldr	r8, [pc, r8]
   c0e80: e5980000     	ldr	r0, [r8]
   c0e84: e59f7238     	ldr	r7, [pc, #0x238]        @ 0xc10c4 <.text+0xb0fc4>
   c0e88: e2401001     	sub	r1, r0, #1
   c0e8c: e0000190     	mul	r0, r0, r1
   c0e90: e79f7007     	ldr	r7, [pc, r7]
   c0e94: e3100001     	tst	r0, #1
   c0e98: 0a000035     	beq	0xc0f74 <.text+0xb0e74> @ imm = #0xd4
   c0e9c: e5970000     	ldr	r0, [r7]
   c0ea0: e3500009     	cmp	r0, #9
   c0ea4: ca000042     	bgt	0xc0fb4 <.text+0xb0eb4> @ imm = #0x108
   c0ea8: ea000031     	b	0xc0f74 <.text+0xb0e74> @ imm = #0xc4
   c0eac: e59f81e8     	ldr	r8, [pc, #0x1e8]        @ 0xc109c <.text+0xb0f9c>
   c0eb0: e79f8008     	ldr	r8, [pc, r8]
   c0eb4: e5980000     	ldr	r0, [r8]
   c0eb8: e59f71e0     	ldr	r7, [pc, #0x1e0]        @ 0xc10a0 <.text+0xb0fa0>
   c0ebc: e2401001     	sub	r1, r0, #1
   c0ec0: e0000190     	mul	r0, r0, r1
   c0ec4: e79f7007     	ldr	r7, [pc, r7]
   c0ec8: e59f51d4     	ldr	r5, [pc, #0x1d4]        @ 0xc10a4 <.text+0xb0fa4>
   c0ecc: e08f5005     	add	r5, pc, r5
   c0ed0: e3100001     	tst	r0, #1
   c0ed4: 0a000002     	beq	0xc0ee4 <.text+0xb0de4> @ imm = #0x8
   c0ed8: e5970000     	ldr	r0, [r7]
   c0edc: e3500009     	cmp	r0, #9
   c0ee0: ca000015     	bgt	0xc0f3c <.text+0xb0e3c> @ imm = #0x54
   c0ee4: e59f01bc     	ldr	r0, [pc, #0x1bc]        @ 0xc10a8 <.text+0xb0fa8>
   c0ee8: e2843001     	add	r3, r4, #1
   c0eec: e59f11b8     	ldr	r1, [pc, #0x1b8]        @ 0xc10ac <.text+0xb0fac>
   c0ef0: e3a06001     	mov	r6, #1
   c0ef4: e59f21b4     	ldr	r2, [pc, #0x1b4]        @ 0xc10b0 <.text+0xb0fb0>
   c0ef8: e08f0000     	add	r0, pc, r0
   c0efc: e08f1001     	add	r1, pc, r1
   c0f00: e58d3008     	str	r3, [sp, #0x8]
   c0f04: e08f2002     	add	r2, pc, r2
   c0f08: e300317f     	movw	r3, #0x17f
   c0f0c: e58d6000     	str	r6, [sp]
   c0f10: e58d5004     	str	r5, [sp, #0x4]
   c0f14: eb00e46a     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x391a8
   c0f18: e5980000     	ldr	r0, [r8]
   c0f1c: e3e06000     	mvn	r6, #0
   c0f20: e2401001     	sub	r1, r0, #1
   c0f24: e0000190     	mul	r0, r0, r1
   c0f28: e3100001     	tst	r0, #1
   c0f2c: 0a000057     	beq	0xc1090 <.text+0xb0f90> @ imm = #0x15c
   c0f30: e5970000     	ldr	r0, [r7]
   c0f34: e350000a     	cmp	r0, #10
   c0f38: ba000054     	blt	0xc1090 <.text+0xb0f90> @ imm = #0x150
   c0f3c: e59f0170     	ldr	r0, [pc, #0x170]        @ 0xc10b4 <.text+0xb0fb4>
   c0f40: e2843001     	add	r3, r4, #1
   c0f44: e59f116c     	ldr	r1, [pc, #0x16c]        @ 0xc10b8 <.text+0xb0fb8>
   c0f48: e3a06001     	mov	r6, #1
   c0f4c: e59f2168     	ldr	r2, [pc, #0x168]        @ 0xc10bc <.text+0xb0fbc>
   c0f50: e08f0000     	add	r0, pc, r0
   c0f54: e08f1001     	add	r1, pc, r1
   c0f58: e58d3008     	str	r3, [sp, #0x8]
   c0f5c: e08f2002     	add	r2, pc, r2
   c0f60: e300317f     	movw	r3, #0x17f
   c0f64: e58d6000     	str	r6, [sp]
   c0f68: e58d5004     	str	r5, [sp, #0x4]
   c0f6c: eb00e454     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x39150
   c0f70: eaffffdb     	b	0xc0ee4 <.text+0xb0de4> @ imm = #-0x94
   c0f74: e1a00004     	mov	r0, r4
   c0f78: eb00f7ef     	bl	0xfef3c <.text+0xeee3c> @ imm = #0x3dfbc
   c0f7c: e1a06000     	mov	r6, r0
   c0f80: e5950018     	ldr	r0, [r5, #0x18]
   c0f84: e58502d0     	str	r0, [r5, #0x2d0]
   c0f88: e2850fae     	add	r0, r5, #696
   c0f8c: e1a01006     	mov	r1, r6
   c0f90: eb00f7ad     	bl	0xfee4c <.text+0xeed4c> @ imm = #0x3deb4
   c0f94: e5981000     	ldr	r1, [r8]
   c0f98: e2412001     	sub	r2, r1, #1
   c0f9c: e0010291     	mul	r1, r1, r2
   c0fa0: e3110001     	tst	r1, #1
   c0fa4: 0a00000a     	beq	0xc0fd4 <.text+0xb0ed4> @ imm = #0x28
   c0fa8: e5971000     	ldr	r1, [r7]
   c0fac: e3510009     	cmp	r1, #9
   c0fb0: da000007     	ble	0xc0fd4 <.text+0xb0ed4> @ imm = #0x1c
   c0fb4: e1a00004     	mov	r0, r4
   c0fb8: eb00f7df     	bl	0xfef3c <.text+0xeee3c> @ imm = #0x3df7c
   c0fbc: e1a01000     	mov	r1, r0
   c0fc0: e5950018     	ldr	r0, [r5, #0x18]
   c0fc4: e58502d0     	str	r0, [r5, #0x2d0]
   c0fc8: e2850fae     	add	r0, r5, #696
   c0fcc: eb00f79e     	bl	0xfee4c <.text+0xeed4c> @ imm = #0x3de78
   c0fd0: eaffffe7     	b	0xc0f74 <.text+0xb0e74> @ imm = #-0x64
   c0fd4: e3500000     	cmp	r0, #0
   c0fd8: 0a00000c     	beq	0xc1010 <.text+0xb0f10> @ imm = #0x30
   c0fdc: e59f00e4     	ldr	r0, [pc, #0xe4]         @ 0xc10c8 <.text+0xb0fc8>
   c0fe0: e3a07001     	mov	r7, #1
   c0fe4: e59f10e0     	ldr	r1, [pc, #0xe0]         @ 0xc10cc <.text+0xb0fcc>
   c0fe8: e59f20e0     	ldr	r2, [pc, #0xe0]         @ 0xc10d0 <.text+0xb0fd0>
   c0fec: e08f0000     	add	r0, pc, r0
   c0ff0: e59f30dc     	ldr	r3, [pc, #0xdc]         @ 0xc10d4 <.text+0xb0fd4>
   c0ff4: e08f1001     	add	r1, pc, r1
   c0ff8: e08f2002     	add	r2, pc, r2
   c0ffc: e58d7000     	str	r7, [sp]
   c1000: e08f3003     	add	r3, pc, r3
   c1004: e98d0048     	stmib	sp, {r3, r6}
   c1008: e3a03f63     	mov	r3, #396
   c100c: ea00001d     	b	0xc1088 <.text+0xb0f88> @ imm = #0x74
   c1010: e2850e2e     	add	r0, r5, #736
   c1014: e3a01000     	mov	r1, #0
   c1018: e3a06000     	mov	r6, #0
   c101c: eb13942e     	bl	0x5a60dc <.text+0x595fdc> @ imm = #0x4e50b8
   c1020: e2850fbe     	add	r0, r5, #760
   c1024: e3a01b02     	mov	r1, #2048
   c1028: e3a02001     	mov	r2, #1
   c102c: e3a04001     	mov	r4, #1
   c1030: eb00425e     	bl	0xd19b0 <.text+0xc18b0> @ imm = #0x10978
   c1034: e59f209c     	ldr	r2, [pc, #0x9c]         @ 0xc10d8 <.text+0xb0fd8>
   c1038: e2850fc5     	add	r0, r5, #788
   c103c: e3a01000     	mov	r1, #0
   c1040: e1a03005     	mov	r3, r5
   c1044: e08f2002     	add	r2, pc, r2
   c1048: eb13915f     	bl	0x5a55cc <.text+0x5954cc> @ imm = #0x4e457c
   c104c: e3500000     	cmp	r0, #0
   c1050: 0a00000e     	beq	0xc1090 <.text+0xb0f90> @ imm = #0x38
   c1054: e59f0080     	ldr	r0, [pc, #0x80]         @ 0xc10dc <.text+0xb0fdc>
   c1058: e59f1080     	ldr	r1, [pc, #0x80]         @ 0xc10e0 <.text+0xb0fe0>
   c105c: e59f2080     	ldr	r2, [pc, #0x80]         @ 0xc10e4 <.text+0xb0fe4>
   c1060: e08f0000     	add	r0, pc, r0
   c1064: e5953018     	ldr	r3, [r5, #0x18]
   c1068: e08f1001     	add	r1, pc, r1
   c106c: e59f7074     	ldr	r7, [pc, #0x74]         @ 0xc10e8 <.text+0xb0fe8>
   c1070: e08f2002     	add	r2, pc, r2
   c1074: e2833001     	add	r3, r3, #1
   c1078: e08f7007     	add	r7, pc, r7
   c107c: e88d0090     	stm	sp, {r4, r7}
   c1080: e58d3008     	str	r3, [sp, #0x8]
   c1084: e3003197     	movw	r3, #0x197
   c1088: eb00e40d     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x39034
   c108c: e3e06000     	mvn	r6, #0
   c1090: e1a00006     	mov	r0, r6
   c1094: e24bd018     	sub	sp, r11, #24
   c1098: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
   c109c: 0051de40     	subseq	sp, r1, r0, asr #28
   c10a0: 0051e1a4     	subseq	lr, r1, r4, lsr #3
   c10a4: 0052866c     	subseq	r8, r2, r12, ror #12
   c10a8: 0052862e     	subseq	r8, r2, lr, lsr #12
   c10ac: 005285f8     	ldrsheq	r8, [r2], #-88
   c10b0: 00528629     	subseq	r8, r2, r9, lsr #12
   c10b4: 005285d6     	ldrsbeq	r8, [r2], #-86
   c10b8: 005285a0     	subseq	r8, r2, r0, lsr #11
   c10bc: 005285d1     	ldrsbeq	r8, [r2], #-81
   c10c0: 0051de74     	subseq	sp, r1, r4, ror lr
   c10c4: 0051e1d8     	ldrsbeq	lr, [r1], #-24
   c10c8: 0052853a     	subseq	r8, r2, r10, lsr r5
   c10cc: 00528500     	subseq	r8, r2, r0, lsl #10
   c10d0: 00528535     	subseq	r8, r2, r5, lsr r5
   c10d4: 0052854f     	subseq	r8, r2, pc, asr #10
   c10d8: 000000a0     	andeq	r0, r0, r0, lsr #1
   c10dc: 005284c6     	subseq	r8, r2, r6, asr #9
   c10e0: 0052848c     	subseq	r8, r2, r12, lsl #9
   c10e4: 005284bd     	ldrheq	r8, [r2], #-77
   c10e8: 005284fc     	ldrsheq	r8, [r2], #-76

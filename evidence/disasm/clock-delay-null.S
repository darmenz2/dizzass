
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ecca0: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   ecca4: e28db01c     	add	r11, sp, #28
   ecca8: e24dd00c     	sub	sp, sp, #12
   eccac: e1a08000     	mov	r8, r0
   eccb0: e59f0158     	ldr	r0, [pc, #0x158]        @ 0xece10 <.text+0xdcd10>
   eccb4: e1a07001     	mov	r7, r1
   eccb8: e3089000     	movw	r9, #0x8000
   eccbc: e1a05003     	mov	r5, r3
   eccc0: e1a06002     	mov	r6, r2
   eccc4: e79f0000     	ldr	r0, [pc, r0]
   eccc8: e3489000     	movt	r9, #0x8000
   ecccc: e5900000     	ldr	r0, [r0]
   eccd0: e59fa13c     	ldr	r10, [pc, #0x13c]       @ 0xece14 <.text+0xdcd14>
   eccd4: e2401001     	sub	r1, r0, #1
   eccd8: e0000190     	mul	r0, r0, r1
   eccdc: e79fa00a     	ldr	r10, [pc, r10]
   ecce0: e3100001     	tst	r0, #1
   ecce4: 0a000002     	beq	0xeccf4 <.text+0xdcbf4> @ imm = #0x8
   ecce8: e59a0000     	ldr	r0, [r10]
   eccec: e3500009     	cmp	r0, #9
   eccf0: ca000015     	bgt	0xecd4c <.text+0xdcc4c> @ imm = #0x54
   eccf4: e1a00307     	lsl	r0, r7, #6
   eccf8: e3a01001     	mov	r1, #1
   eccfc: e6ef0070     	uxtb	r0, r0
   ecd00: e3a02000     	mov	r2, #0
   ecd04: e7c50216     	bfi	r0, r6, #4, #2
   ecd08: e3a0303c     	mov	r3, #60
   ecd0c: e3a04000     	mov	r4, #0
   ecd10: e7c20115     	bfi	r0, r5, #2, #1
   ecd14: e1800009     	orr	r0, r0, r9
   ecd18: e58d0000     	str	r0, [sp]
   ecd1c: e1a00008     	mov	r0, r8
   ecd20: eb0006ef     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x1bbc
   ecd24: e59f10ec     	ldr	r1, [pc, #0xec]         @ 0xece18 <.text+0xdcd18>
   ecd28: e79f1001     	ldr	r1, [pc, r1]
   ecd2c: e5911000     	ldr	r1, [r1]
   ecd30: e2412001     	sub	r2, r1, #1
   ecd34: e0010291     	mul	r1, r1, r2
   ecd38: e3110001     	tst	r1, #1
   ecd3c: 0a00000e     	beq	0xecd7c <.text+0xdcc7c> @ imm = #0x38
   ecd40: e59a1000     	ldr	r1, [r10]
   ecd44: e3510009     	cmp	r1, #9
   ecd48: da00000b     	ble	0xecd7c <.text+0xdcc7c> @ imm = #0x2c
   ecd4c: e1a00307     	lsl	r0, r7, #6
   ecd50: e3a01001     	mov	r1, #1
   ecd54: e6ef0070     	uxtb	r0, r0
   ecd58: e3a02000     	mov	r2, #0
   ecd5c: e7c50216     	bfi	r0, r6, #4, #2
   ecd60: e3a0303c     	mov	r3, #60
   ecd64: e7c20115     	bfi	r0, r5, #2, #1
   ecd68: e1800009     	orr	r0, r0, r9
   ecd6c: e58d0000     	str	r0, [sp]
   ecd70: e1a00008     	mov	r0, r8
   ecd74: eb0006da     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x1b68
   ecd78: eaffffdd     	b	0xeccf4 <.text+0xdcbf4> @ imm = #-0x8c
   ecd7c: e3500000     	cmp	r0, #0
   ecd80: 0a00001f     	beq	0xece04 <.text+0xdcd04> @ imm = #0x7c
   ecd84: e59f4090     	ldr	r4, [pc, #0x90]         @ 0xece1c <.text+0xdcd1c>
   ecd88: e3a07001     	mov	r7, #1
   ecd8c: e59f508c     	ldr	r5, [pc, #0x8c]         @ 0xece20 <.text+0xdcd20>
   ecd90: e30032d3     	movw	r3, #0x2d3
   ecd94: e59f6088     	ldr	r6, [pc, #0x88]         @ 0xece24 <.text+0xdcd24>
   ecd98: e08f4004     	add	r4, pc, r4
   ecd9c: e5980018     	ldr	r0, [r8, #0x18]
   ecda0: e08f5005     	add	r5, pc, r5
   ecda4: e59f107c     	ldr	r1, [pc, #0x7c]         @ 0xece28 <.text+0xdcd28>
   ecda8: e08f6006     	add	r6, pc, r6
   ecdac: e2800001     	add	r0, r0, #1
   ecdb0: e58d0008     	str	r0, [sp, #0x8]
   ecdb4: e08f1001     	add	r1, pc, r1
   ecdb8: e58d1004     	str	r1, [sp, #0x4]
   ecdbc: e1a00004     	mov	r0, r4
   ecdc0: e1a01005     	mov	r1, r5
   ecdc4: e1a02006     	mov	r2, r6
   ecdc8: e58d7000     	str	r7, [sp]
   ecdcc: eb0034bc     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xd2f0
   ecdd0: e5980018     	ldr	r0, [r8, #0x18]
   ecdd4: e1a02006     	mov	r2, r6
   ecdd8: e59f104c     	ldr	r1, [pc, #0x4c]         @ 0xece2c <.text+0xdcd2c>
   ecddc: e30033a6     	movw	r3, #0x3a6
   ecde0: e2800001     	add	r0, r0, #1
   ecde4: e58d0008     	str	r0, [sp, #0x8]
   ecde8: e08f1001     	add	r1, pc, r1
   ecdec: e58d1004     	str	r1, [sp, #0x4]
   ecdf0: e1a00004     	mov	r0, r4
   ecdf4: e1a01005     	mov	r1, r5
   ecdf8: e58d7000     	str	r7, [sp]
   ecdfc: eb0034b0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xd2c0
   ece00: e3e04000     	mvn	r4, #0
   ece04: e1a00004     	mov	r0, r4
   ece08: e24bd01c     	sub	sp, r11, #28
   ece0c: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   ece10: 004f2d78     	subeq	r2, pc, r8, ror sp
   ece14: 004f2fd8     	ldrdeq	r2, r3, [pc], #-248
   ece18: 004f2d14     	subeq	r2, pc, r4, lsl sp
   ece1c: 004ff140     	subeq	pc, pc, r0, asr #2
   ece20: 004ff13f     	subeq	pc, pc, pc, lsr r1
   ece24: 004ff161     	subeq	pc, pc, r1, ror #2
   ece28: 004ff82b     	subeq	pc, pc, r11, lsr #16
   ece2c: 004ff45b     	subeq	pc, pc, r11, asr r4
   ece30: e30c0200     	movw	r0, #0xc200
   ece34: e3400001     	movt	r0, #0x1
   ece38: e12fff1e     	bx	lr

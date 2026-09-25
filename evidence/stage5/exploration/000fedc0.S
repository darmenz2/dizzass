
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fedc0: 00555e68     	subseq	r5, r5, r8, ror #28
   fedc4: e92d4830     	push	{r4, r5, r11, lr}
   fedc8: e28db008     	add	r11, sp, #8
   fedcc: e59f4068     	ldr	r4, [pc, #0x68]         @ 0xfee3c <.text+0xeed3c>
   fedd0: e79f4004     	ldr	r4, [pc, r4]
   fedd4: e5940000     	ldr	r0, [r4]
   fedd8: e59f5060     	ldr	r5, [pc, #0x60]         @ 0xfee40 <.text+0xeed40>
   feddc: e2401001     	sub	r1, r0, #1
   fede0: e0000190     	mul	r0, r0, r1
   fede4: e79f5005     	ldr	r5, [pc, r5]
   fede8: e3100001     	tst	r0, #1
   fedec: 0a000002     	beq	0xfedfc <.text+0xeecfc> @ imm = #0x8
   fedf0: e5950000     	ldr	r0, [r5]
   fedf4: e3500009     	cmp	r0, #9
   fedf8: ca00000a     	bgt	0xfee28 <.text+0xeed28> @ imm = #0x28
   fedfc: e59f0040     	ldr	r0, [pc, #0x40]         @ 0xfee44 <.text+0xeed44>
   fee00: e79f0000     	ldr	r0, [pc, r0]
   fee04: e12fff30     	blx	r0
   fee08: e5941000     	ldr	r1, [r4]
   fee0c: e2412001     	sub	r2, r1, #1
   fee10: e0010291     	mul	r1, r1, r2
   fee14: e3110001     	tst	r1, #1
   fee18: 0a000006     	beq	0xfee38 <.text+0xeed38> @ imm = #0x18
   fee1c: e5951000     	ldr	r1, [r5]
   fee20: e3510009     	cmp	r1, #9
   fee24: da000003     	ble	0xfee38 <.text+0xeed38> @ imm = #0xc
   fee28: e59f0018     	ldr	r0, [pc, #0x18]         @ 0xfee48 <.text+0xeed48>
   fee2c: e79f0000     	ldr	r0, [pc, r0]
   fee30: e12fff30     	blx	r0
   fee34: eafffff0     	b	0xfedfc <.text+0xeecfc> @ imm = #-0x40
   fee38: e8bd8830     	pop	{r4, r5, r11, pc}
   fee3c: 004e08a4     	subeq	r0, lr, r4, lsr #17
   fee40: 004e0808     	subeq	r0, lr, r8, lsl #16
   fee44: 00555d40     	subseq	r5, r5, r0, asr #26
   fee48: 00555d14     	subseq	r5, r5, r4, lsl sp
   fee4c: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   fee50: e28db010     	add	r11, sp, #16
   fee54: e59f6080     	ldr	r6, [pc, #0x80]         @ 0xfeedc <.text+0xeeddc>
   fee58: e1a05000     	mov	r5, r0
   fee5c: e1a04001     	mov	r4, r1
   fee60: e79f6006     	ldr	r6, [pc, r6]
   fee64: e5960000     	ldr	r0, [r6]
   fee68: e59f7070     	ldr	r7, [pc, #0x70]         @ 0xfeee0 <.text+0xeede0>
   fee6c: e2401001     	sub	r1, r0, #1
   fee70: e0000190     	mul	r0, r0, r1
   fee74: e79f7007     	ldr	r7, [pc, r7]
   fee78: e3100001     	tst	r0, #1
   fee7c: 0a000002     	beq	0xfee8c <.text+0xeed8c> @ imm = #0x8
   fee80: e5970000     	ldr	r0, [r7]
   fee84: e3500009     	cmp	r0, #9
   fee88: ca00000c     	bgt	0xfeec0 <.text+0xeedc0> @ imm = #0x30
   fee8c: e59f2050     	ldr	r2, [pc, #0x50]         @ 0xfeee4 <.text+0xeede4>
   fee90: e1a00005     	mov	r0, r5
   fee94: e1a01004     	mov	r1, r4
   fee98: e79f2002     	ldr	r2, [pc, r2]
   fee9c: e12fff32     	blx	r2
   feea0: e5961000     	ldr	r1, [r6]
   feea4: e2412001     	sub	r2, r1, #1
   feea8: e0010291     	mul	r1, r1, r2
   feeac: e3110001     	tst	r1, #1
   feeb0: 0a000008     	beq	0xfeed8 <.text+0xeedd8> @ imm = #0x20
   feeb4: e5971000     	ldr	r1, [r7]
   feeb8: e3510009     	cmp	r1, #9
   feebc: da000005     	ble	0xfeed8 <.text+0xeedd8> @ imm = #0x14
   feec0: e59f2020     	ldr	r2, [pc, #0x20]         @ 0xfeee8 <.text+0xeede8>
   feec4: e1a00005     	mov	r0, r5
   feec8: e1a01004     	mov	r1, r4
   feecc: e79f2002     	ldr	r2, [pc, r2]
   feed0: e12fff32     	blx	r2
   feed4: eaffffec     	b	0xfee8c <.text+0xeed8c> @ imm = #-0x50
   feed8: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
   feedc: 004dfaf0     	<unknown>
   feee0: 004dfe0c     	subeq	pc, sp, r12, lsl #28
   feee4: 00555d78     	subseq	r5, r5, r8, ror sp
   feee8: 00555d44     	subseq	r5, r5, r4, asr #26
   feeec: e59f1004     	ldr	r1, [pc, #0x4]          @ 0xfeef8 <.text+0xeedf8>
   feef0: e79f1001     	ldr	r1, [pc, r1]
   feef4: e12fff11     	bx	r1
   feef8: 00555d24     	subseq	r5, r5, r4, lsr #26
   feefc: e59f2004     	ldr	r2, [pc, #0x4]          @ 0xfef08 <.text+0xeee08>
   fef00: e79f2002     	ldr	r2, [pc, r2]
   fef04: e12fff12     	bx	r2
   fef08: 00555d18     	subseq	r5, r5, r8, lsl sp
   fef0c: e59f3004     	ldr	r3, [pc, #0x4]          @ 0xfef18 <.text+0xeee18>
   fef10: e79f3003     	ldr	r3, [pc, r3]
   fef14: e12fff13     	bx	r3
   fef18: 00555d0c     	subseq	r5, r5, r12, lsl #26
   fef1c: e59f3004     	ldr	r3, [pc, #0x4]          @ 0xfef28 <.text+0xeee28>
   fef20: e79f3003     	ldr	r3, [pc, r3]
   fef24: e12fff13     	bx	r3
   fef28: 00555d00     	subseq	r5, r5, r0, lsl #26
   fef2c: e59f1004     	ldr	r1, [pc, #0x4]          @ 0xfef38 <.text+0xeee38>
   fef30: e79f1001     	ldr	r1, [pc, r1]
   fef34: e12fff11     	bx	r1
   fef38: 00555cf4     	ldrsheq	r5, [r5], #-196
   fef3c: e59f1004     	ldr	r1, [pc, #0x4]          @ 0xfef48 <.text+0xeee48>
   fef40: e79f1001     	ldr	r1, [pc, r1]
   fef44: e12fff11     	bx	r1
   fef48: 00555c04     	subseq	r5, r5, r4, lsl #24
   fef4c: e92d4800     	push	{r11, lr}
   fef50: e3a00000     	mov	r0, #0
   fef54: e3500000     	cmp	r0, #0
   fef58: 1a000007     	bne	0xfef7c <.text+0xeee7c> @ imm = #0x1c
   fef5c: e59f12f8     	ldr	r1, [pc, #0x2f8]        @ 0xff25c <.text+0xef15c>
   fef60: e08f1001     	add	r1, pc, r1
   fef64: e7d12000     	ldrb	r2, [r1, r0]
   fef68: e22220bb     	eor	r2, r2, #187
   fef6c: e7c12000     	strb	r2, [r1, r0]
   fef70: e2800001     	add	r0, r0, #1
   fef74: e3500007     	cmp	r0, #7
   fef78: 1afffff9     	bne	0xfef64 <.text+0xeee64> @ imm = #-0x1c
   fef7c: e59fc2dc     	ldr	r12, [pc, #0x2dc]       @ 0xff260 <.text+0xef160>
   fef80: e79fc00c     	ldr	r12, [pc, r12]
   fef84: e59c0000     	ldr	r0, [r12]
   fef88: e2401001     	sub	r1, r0, #1
   fef8c: e0000190     	mul	r0, r0, r1

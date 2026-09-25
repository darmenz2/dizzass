
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  108b7c: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  108b80: e28db01c     	add	r11, sp, #28
  108b84: e24ddf55     	sub	sp, sp, #340
  108b88: e3520001     	cmp	r2, #1
  108b8c: e58d000c     	str	r0, [sp, #0xc]
  108b90: e58d2008     	str	r2, [sp, #0x8]
  108b94: ba0000de     	blt	0x108f14 <.text+0xf8e14> @ imm = #0x378
  108b98: e59f937c     	ldr	r9, [pc, #0x37c]        @ 0x108f1c <.text+0xf8e1c>
  108b9c: e79f9009     	ldr	r9, [pc, r9]
  108ba0: e5990000     	ldr	r0, [r9]
  108ba4: e2402001     	sub	r2, r0, #1
  108ba8: e0000290     	mul	r0, r0, r2
  108bac: e3100001     	tst	r0, #1
  108bb0: e5990000     	ldr	r0, [r9]
  108bb4: e59fa364     	ldr	r10, [pc, #0x364]       @ 0x108f20 <.text+0xf8e20>
  108bb8: e2402001     	sub	r2, r0, #1
  108bbc: e0000290     	mul	r0, r0, r2
  108bc0: e79fa00a     	ldr	r10, [pc, r10]
  108bc4: e3100001     	tst	r0, #1
  108bc8: 0a000002     	beq	0x108bd8 <.text+0xf8ad8> @ imm = #0x8
  108bcc: e59a0000     	ldr	r0, [r10]
  108bd0: e3500009     	cmp	r0, #9
  108bd4: cafffff5     	bgt	0x108bb0 <.text+0xf8ab0> @ imm = #-0x2c
  108bd8: e59d000c     	ldr	r0, [sp, #0xc]
  108bdc: e28d5050     	add	r5, sp, #80
  108be0: e3a02000     	mov	r2, #0
  108be4: e2800088     	add	r0, r0, #136
  108be8: e58d0004     	str	r0, [sp, #0x4]
  108bec: ea00002c     	b	0x108ca4 <.text+0xf8ba4> @ imm = #0xb0
  108bf0: e59d400c     	ldr	r4, [sp, #0xc]
  108bf4: e58d7048     	str	r7, [sp, #0x48]
  108bf8: e284e088     	add	lr, r4, #136
  108bfc: e58da044     	str	r10, [sp, #0x44]
  108c00: e58d3040     	str	r3, [sp, #0x40]
  108c04: e58d604c     	str	r6, [sp, #0x4c]
  108c08: e58d803c     	str	r8, [sp, #0x3c]
  108c0c: e58d1038     	str	r1, [sp, #0x38]
  108c10: e58dc034     	str	r12, [sp, #0x34]
  108c14: e58d7010     	str	r7, [sp, #0x10]
  108c18: e58d5030     	str	r5, [sp, #0x30]
  108c1c: e89e4284     	ldm	lr, {r2, r7, r9, lr}
  108c20: e0822005     	add	r2, r2, r5
  108c24: e5842088     	str	r2, [r4, #0x88]
  108c28: e087200c     	add	r2, r7, r12
  108c2c: e584208c     	str	r2, [r4, #0x8c]
  108c30: e0892001     	add	r2, r9, r1
  108c34: e5842090     	str	r2, [r4, #0x90]
  108c38: e5942098     	ldr	r2, [r4, #0x98]
  108c3c: e08e5008     	add	r5, lr, r8
  108c40: e59470a0     	ldr	r7, [r4, #0xa0]
  108c44: e5845094     	str	r5, [r4, #0x94]
  108c48: e0821003     	add	r1, r2, r3
  108c4c: e594509c     	ldr	r5, [r4, #0x9c]
  108c50: e59420a4     	ldr	r2, [r4, #0xa4]
  108c54: e085000a     	add	r0, r5, r10
  108c58: e5841098     	str	r1, [r4, #0x98]
  108c5c: e584009c     	str	r0, [r4, #0x9c]
  108c60: e28d5050     	add	r5, sp, #80
  108c64: e59d0010     	ldr	r0, [sp, #0x10]
  108c68: e59d1018     	ldr	r1, [sp, #0x18]
  108c6c: e0870000     	add	r0, r7, r0
  108c70: e58400a0     	str	r0, [r4, #0xa0]
  108c74: e0820006     	add	r0, r2, r6
  108c78: e58400a4     	str	r0, [r4, #0xa4]
  108c7c: e59d2014     	ldr	r2, [sp, #0x14]
  108c80: e2811040     	add	r1, r1, #64
  108c84: e59d0008     	ldr	r0, [sp, #0x8]
  108c88: e59f92a0     	ldr	r9, [pc, #0x2a0]        @ 0x108f30 <.text+0xf8e30>
  108c8c: e2822001     	add	r2, r2, #1
  108c90: e1520000     	cmp	r2, r0
  108c94: e79f9009     	ldr	r9, [pc, r9]
  108c98: e59fa294     	ldr	r10, [pc, #0x294]       @ 0x108f34 <.text+0xf8e34>
  108c9c: e79fa00a     	ldr	r10, [pc, r10]
  108ca0: 0a00009b     	beq	0x108f14 <.text+0xf8e14> @ imm = #0x26c
  108ca4: e3a00000     	mov	r0, #0
  108ca8: e58d2014     	str	r2, [sp, #0x14]
  108cac: e7912000     	ldr	r2, [r1, r0]
  108cb0: e6bf2f32     	rev	r2, r2
  108cb4: e7852000     	str	r2, [r5, r0]
  108cb8: e2800004     	add	r0, r0, #4
  108cbc: e3500040     	cmp	r0, #64
  108cc0: 1afffff9     	bne	0x108cac <.text+0xf8bac> @ imm = #-0x1c
  108cc4: e5990000     	ldr	r0, [r9]
  108cc8: e58d1018     	str	r1, [sp, #0x18]
  108ccc: e2401001     	sub	r1, r0, #1
  108cd0: e0000190     	mul	r0, r0, r1
  108cd4: e3100001     	tst	r0, #1
  108cd8: e5990000     	ldr	r0, [r9]
  108cdc: e59de050     	ldr	lr, [sp, #0x50]
  108ce0: e2401001     	sub	r1, r0, #1
  108ce4: e0000190     	mul	r0, r0, r1
  108ce8: e3100001     	tst	r0, #1
  108cec: 0a000002     	beq	0x108cfc <.text+0xf8bfc> @ imm = #0x8
  108cf0: e59a0000     	ldr	r0, [r10]
  108cf4: e3500009     	cmp	r0, #9
  108cf8: cafffff6     	bgt	0x108cd8 <.text+0xf8bd8> @ imm = #-0x28
  108cfc: e3a0c010     	mov	r12, #16
  108d00: e3a08000     	mov	r8, #0
  108d04: ea000004     	b	0x108d1c <.text+0xf8c1c> @ imm = #0x10
  108d08: e2888001     	add	r8, r8, #1
  108d0c: e28cc001     	add	r12, r12, #1
  108d10: e3580030     	cmp	r8, #48
  108d14: e1a0e000     	mov	lr, r0
  108d18: 0a00002d     	beq	0x108dd4 <.text+0xf8cd4> @ imm = #0xb4
  108d1c: e5990000     	ldr	r0, [r9]
  108d20: e2401001     	sub	r1, r0, #1
  108d24: e0000190     	mul	r0, r0, r1
  108d28: e3100001     	tst	r0, #1
  108d2c: 0a000002     	beq	0x108d3c <.text+0xf8c3c> @ imm = #0x8
  108d30: e59a0000     	ldr	r0, [r10]
  108d34: e3500009     	cmp	r0, #9
  108d38: ca000016     	bgt	0x108d98 <.text+0xf8c98> @ imm = #0x58
  108d3c: e0853108     	add	r3, r5, r8, lsl #2
  108d40: e5991000     	ldr	r1, [r9]
  108d44: e5930004     	ldr	r0, [r3, #0x4]
  108d48: e2412001     	sub	r2, r1, #1
  108d4c: e5934038     	ldr	r4, [r3, #0x38]
  108d50: e0020291     	mul	r2, r1, r2
  108d54: e5935024     	ldr	r5, [r3, #0x24]
  108d58: e1a01960     	ror	r1, r0, #18
  108d5c: e02111a0     	eor	r1, r1, r0, lsr #3
  108d60: e08e5005     	add	r5, lr, r5
  108d64: e02173e0     	eor	r7, r1, r0, ror #7
  108d68: e1a019e4     	ror	r1, r4, #19
  108d6c: e0216524     	eor	r6, r1, r4, lsr #10
  108d70: e59a1000     	ldr	r1, [r10]
  108d74: e02648e4     	eor	r4, r6, r4, ror #17
  108d78: e3120001     	tst	r2, #1
  108d7c: e0854004     	add	r4, r5, r4
  108d80: e28d5050     	add	r5, sp, #80
  108d84: e0844007     	add	r4, r4, r7
  108d88: e5834040     	str	r4, [r3, #0x40]
  108d8c: 0affffdd     	beq	0x108d08 <.text+0xf8c08> @ imm = #-0x8c
  108d90: e3510009     	cmp	r1, #9
  108d94: daffffdb     	ble	0x108d08 <.text+0xf8c08> @ imm = #-0x94
  108d98: e0850108     	add	r0, r5, r8, lsl #2
  108d9c: e5901004     	ldr	r1, [r0, #0x4]
  108da0: e5903038     	ldr	r3, [r0, #0x38]
  108da4: e5902024     	ldr	r2, [r0, #0x24]
  108da8: e1a04961     	ror	r4, r1, #18
  108dac: e02441a1     	eor	r4, r4, r1, lsr #3
  108db0: e08e2002     	add	r2, lr, r2
  108db4: e02413e1     	eor	r1, r4, r1, ror #7
  108db8: e1a049e3     	ror	r4, r3, #19
  108dbc: e0244523     	eor	r4, r4, r3, lsr #10
  108dc0: e02438e3     	eor	r3, r4, r3, ror #17
  108dc4: e0822003     	add	r2, r2, r3
  108dc8: e0821001     	add	r1, r2, r1
  108dcc: e5801040     	str	r1, [r0, #0x40]
  108dd0: eaffffd9     	b	0x108d3c <.text+0xf8c3c> @ imm = #-0x9c
  108dd4: e59d0004     	ldr	r0, [sp, #0x4]
  108dd8: e28d1030     	add	r1, sp, #48
  108ddc: e3a0e000     	mov	lr, #0
  108de0: e8b000cc     	ldm	r0!, {r2, r3, r6, r7}
  108de4: e8a100cc     	stm	r1!, {r2, r3, r6, r7}
  108de8: e89000cc     	ldm	r0, {r2, r3, r6, r7}
  108dec: e88100cc     	stm	r1, {r2, r3, r6, r7}
  108df0: e59d003c     	ldr	r0, [sp, #0x3c]
  108df4: e58d002c     	str	r0, [sp, #0x2c]
  108df8: e59d5030     	ldr	r5, [sp, #0x30]
  108dfc: e59d9034     	ldr	r9, [sp, #0x34]
  108e00: e59d2038     	ldr	r2, [sp, #0x38]
  108e04: e59d4048     	ldr	r4, [sp, #0x48]
  108e08: e59d0044     	ldr	r0, [sp, #0x44]
  108e0c: e59d3040     	ldr	r3, [sp, #0x40]
  108e10: e59d104c     	ldr	r1, [sp, #0x4c]
  108e14: e58d1028     	str	r1, [sp, #0x28]
  108e18: ea000022     	b	0x108ea8 <.text+0xf8da8> @ imm = #0x88
  108e1c: e59d6024     	ldr	r6, [sp, #0x24]
  108e20: e000400a     	and	r4, r0, r10
  108e24: e59d3028     	ldr	r3, [sp, #0x28]
  108e28: e28ee001     	add	lr, lr, #1
  108e2c: e1c6500a     	bic	r5, r6, r10
  108e30: e59d8020     	ldr	r8, [sp, #0x20]
  108e34: e1854004     	orr	r4, r5, r4
  108e38: e1a0536a     	ror	r5, r10, #6
  108e3c: e02555ea     	eor	r5, r5, r10, ror #11
  108e40: e0822003     	add	r2, r2, r3
  108e44: e0255cea     	eor	r5, r5, r10, ror #25
  108e48: e35e0040     	cmp	lr, #64
  108e4c: e0822005     	add	r2, r2, r5
  108e50: e1a0900c     	mov	r9, r12
  108e54: e0822004     	add	r2, r2, r4
  108e58: e1a0416c     	ror	r4, r12, #2
  108e5c: e0822001     	add	r2, r2, r1
  108e60: e59d102c     	ldr	r1, [sp, #0x2c]
  108e64: e02446ec     	eor	r4, r4, r12, ror #13
  108e68: e1a07000     	mov	r7, r0
  108e6c: e0813002     	add	r3, r1, r2
  108e70: e59d101c     	ldr	r1, [sp, #0x1c]
  108e74: e0244b6c     	eor	r4, r4, r12, ror #22
  108e78: e58d802c     	str	r8, [sp, #0x2c]
  108e7c: e0285001     	eor	r5, r8, r1
  108e80: e0842002     	add	r2, r4, r2
  108e84: e0084001     	and	r4, r8, r1
  108e88: e005500c     	and	r5, r5, r12
  108e8c: e0254004     	eor	r4, r5, r4
  108e90: e58d6028     	str	r6, [sp, #0x28]
  108e94: e0825004     	add	r5, r2, r4
  108e98: e1a04000     	mov	r4, r0
  108e9c: e1a02001     	mov	r2, r1
  108ea0: e1a0000a     	mov	r0, r10
  108ea4: 0affff51     	beq	0x108bf0 <.text+0xf8af0> @ imm = #-0x2bc
  108ea8: e58d4024     	str	r4, [sp, #0x24]
  108eac: e1a0a003     	mov	r10, r3
  108eb0: e58d901c     	str	r9, [sp, #0x1c]
  108eb4: e1a0c005     	mov	r12, r5
  108eb8: e58d2020     	str	r2, [sp, #0x20]
  108ebc: e59f7060     	ldr	r7, [pc, #0x60]         @ 0x108f24 <.text+0xf8e24>
  108ec0: e79f7007     	ldr	r7, [pc, r7]
  108ec4: e5971000     	ldr	r1, [r7]
  108ec8: e59f9058     	ldr	r9, [pc, #0x58]         @ 0x108f28 <.text+0xf8e28>
  108ecc: e2412001     	sub	r2, r1, #1
  108ed0: e0010291     	mul	r1, r1, r2
  108ed4: e79f9009     	ldr	r9, [pc, r9]
  108ed8: e3110001     	tst	r1, #1
  108edc: e5974000     	ldr	r4, [r7]
  108ee0: e28d1050     	add	r1, sp, #80
  108ee4: e799210e     	ldr	r2, [r9, lr, lsl #2]
  108ee8: e2445001     	sub	r5, r4, #1
  108eec: e791110e     	ldr	r1, [r1, lr, lsl #2]
  108ef0: e0040594     	mul	r4, r4, r5
  108ef4: e3140001     	tst	r4, #1
  108ef8: 0affffc7     	beq	0x108e1c <.text+0xf8d1c> @ imm = #-0xe4
  108efc: e59f4028     	ldr	r4, [pc, #0x28]         @ 0x108f2c <.text+0xf8e2c>
  108f00: e79f4004     	ldr	r4, [pc, r4]
  108f04: e5944000     	ldr	r4, [r4]
  108f08: e3540009     	cmp	r4, #9
  108f0c: cafffff2     	bgt	0x108edc <.text+0xf8ddc> @ imm = #-0x38
  108f10: eaffffc1     	b	0x108e1c <.text+0xf8d1c> @ imm = #-0xfc
  108f14: e24bd01c     	sub	sp, r11, #28
  108f18: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  108f1c: 004d6288     	subeq	r6, sp, r8, lsl #5
  108f20: 004d67d8     	ldrdeq	r6, r7, [sp], #-120
  108f24: 004d5f64     	subeq	r5, sp, r4, ror #30
  108f28: 004d6d80     	subeq	r6, sp, r0, lsl #27
  108f2c: 004d6498     	umaaleq	r6, sp, r8, r4
  108f30: 004d6190     	umaaleq	r6, sp, r0, r1
  108f34: 004d66fc     	strdeq	r6, r7, [sp], #-108

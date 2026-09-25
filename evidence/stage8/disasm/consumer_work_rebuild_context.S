
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   74f14: e59d2024     	ldr	r2, [sp, #0x24]
   74f18: e59d0054     	ldr	r0, [sp, #0x54]
   74f1c: e59d1060     	ldr	r1, [sp, #0x60]
   74f20: e1c220d0     	ldrd	r2, r3, [r2]
   74f24: e6bf0f30     	rev	r0, r0
   74f28: e58d2008     	str	r2, [sp, #0x8]
   74f2c: e2842d0a     	add	r2, r4, #640
   74f30: e59d4028     	ldr	r4, [sp, #0x28]
   74f34: e58d1000     	str	r1, [sp]
   74f38: e24b1020     	sub	r1, r11, #32
   74f3c: e58d300c     	str	r3, [sp, #0xc]
   74f40: e1a0300a     	mov	r3, r10
   74f44: e58d0010     	str	r0, [sp, #0x10]
   74f48: e1a00004     	mov	r0, r4
   74f4c: ebfeec56     	bl	0x300ac <.text+0x1ffac> @ imm = #-0x44ea8
   74f50: e1a00006     	mov	r0, r6
   74f54: eb14c5da     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x531768
   74f58: e599019c     	ldr	r0, [r9, #0x19c]
   74f5c: e58d0020     	str	r0, [sp, #0x20]
   74f60: e5950018     	ldr	r0, [r5, #0x18]
   74f64: e51b1020     	ldr	r1, [r11, #-0x20]
   74f68: e58d1018     	str	r1, [sp, #0x18]
   74f6c: eb00c8a0     	bl	0xa71f4 <.text+0x970f4> @ imm = #0x32280
   74f70: e58d001c     	str	r0, [sp, #0x1c]
   74f74: e3a03000     	mov	r3, #0
   74f78: e5d40052     	ldrb	r0, [r4, #0x52]
   74f7c: e3a01000     	mov	r1, #0
   74f80: e3500000     	cmp	r0, #0
   74f84: 0a00000a     	beq	0x74fb4 <.text+0x64eb4> @ imm = #0x28
   74f88: e5980000     	ldr	r0, [r8]
   74f8c: e1a04001     	mov	r4, r1
   74f90: e1a0a003     	mov	r10, r3
   74f94: e2401001     	sub	r1, r0, #1
   74f98: e0000190     	mul	r0, r0, r1
   74f9c: e3100001     	tst	r0, #1
   74fa0: 0a0000cf     	beq	0x752e4 <.text+0x651e4> @ imm = #0x33c
   74fa4: e5970000     	ldr	r0, [r7]
   74fa8: e3500009     	cmp	r0, #9
   74fac: ca0000db     	bgt	0x75320 <.text+0x65220> @ imm = #0x36c
   74fb0: ea0000cb     	b	0x752e4 <.text+0x651e4> @ imm = #0x32c
   74fb4: e5980000     	ldr	r0, [r8]
   74fb8: e2401001     	sub	r1, r0, #1
   74fbc: e0000190     	mul	r0, r0, r1
   74fc0: e3100001     	tst	r0, #1
   74fc4: e59d0040     	ldr	r0, [sp, #0x40]
   74fc8: e3a03e32     	mov	r3, #800
   74fcc: e5954230     	ldr	r4, [r5, #0x230]
   74fd0: e5981000     	ldr	r1, [r8]
   74fd4: e02e4390     	mla	lr, r0, r3, r4
   74fd8: e59dc044     	ldr	r12, [sp, #0x44]
   74fdc: e2414001     	sub	r4, r1, #1
   74fe0: e59d2060     	ldr	r2, [sp, #0x60]
   74fe4: e0010491     	mul	r1, r1, r4
   74fe8: e08c408c     	add	r4, r12, r12, lsl #1
   74fec: e58d0014     	str	r0, [sp, #0x14]
   74ff0: e59e3088     	ldr	r3, [lr, #0x88]
   74ff4: e083c284     	add	r12, r3, r4, lsl #5
   74ff8: e3110001     	tst	r1, #1
   74ffc: e59c0048     	ldr	r0, [r12, #0x48]
   75000: 0a000002     	beq	0x75010 <.text+0x64f10> @ imm = #0x8
   75004: e5971000     	ldr	r1, [r7]
   75008: e3510009     	cmp	r1, #9
   7500c: caffffec     	bgt	0x74fc4 <.text+0x64ec4> @ imm = #-0x50
   75010: e1500002     	cmp	r0, r2
   75014: 1a000027     	bne	0x750b8 <.text+0x64fb8> @ imm = #0x9c
   75018: e59d0028     	ldr	r0, [sp, #0x28]
   7501c: e58d4020     	str	r4, [sp, #0x20]

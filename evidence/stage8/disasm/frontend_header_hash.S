
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   2d994: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   2d998: e28db01c     	add	r11, sp, #28
   2d99c: e24dd004     	sub	sp, sp, #4
   2d9a0: e59f9258     	ldr	r9, [pc, #0x258]        @ 0x2dc00 <.text+0x1db00>
   2d9a4: e1a04000     	mov	r4, r0
   2d9a8: e79f9009     	ldr	r9, [pc, r9]
   2d9ac: e5990000     	ldr	r0, [r9]
   2d9b0: e2401001     	sub	r1, r0, #1
   2d9b4: e0000190     	mul	r0, r0, r1
   2d9b8: e3100001     	tst	r0, #1
   2d9bc: 0a000004     	beq	0x2d9d4 <.text+0x1d8d4> @ imm = #0x10
   2d9c0: e59f023c     	ldr	r0, [pc, #0x23c]        @ 0x2dc04 <.text+0x1db04>
   2d9c4: e79f0000     	ldr	r0, [pc, r0]
   2d9c8: e5900000     	ldr	r0, [r0]
   2d9cc: e3500009     	cmp	r0, #9
   2d9d0: ca000048     	bgt	0x2daf8 <.text+0x1d9f8> @ imm = #0x120
   2d9d4: e1a0100d     	mov	r1, sp
   2d9d8: e2410050     	sub	r0, r1, #80
   2d9dc: e1a0d000     	mov	sp, r0
   2d9e0: e24da020     	sub	r10, sp, #32
   2d9e4: e1a0d00a     	mov	sp, r10
   2d9e8: e284e010     	add	lr, r4, #16
   2d9ec: e894008c     	ldm	r4, {r2, r3, r7}
   2d9f0: e6bf7f37     	rev	r7, r7
   2d9f4: e89e5020     	ldm	lr, {r5, r12, lr}
   2d9f8: e6bf2f32     	rev	r2, r2
   2d9fc: e6bf3f33     	rev	r3, r3
   2da00: e594600c     	ldr	r6, [r4, #0xc]
   2da04: e6bf5f35     	rev	r5, r5
   2da08: e594801c     	ldr	r8, [r4, #0x1c]
   2da0c: e6bfef3e     	rev	lr, lr
   2da10: e5012050     	str	r2, [r1, #-0x50]
   2da14: e2412040     	sub	r2, r1, #64
   2da18: e501304c     	str	r3, [r1, #-0x4c]
   2da1c: e6bf6f36     	rev	r6, r6
   2da20: e5017048     	str	r7, [r1, #-0x48]
   2da24: e2847020     	add	r7, r4, #32
   2da28: e6bfcf3c     	rev	r12, r12
   2da2c: e5016044     	str	r6, [r1, #-0x44]
   2da30: e8825020     	stm	r2, {r5, r12, lr}
   2da34: e6bf8f38     	rev	r8, r8
   2da38: e284e030     	add	lr, r4, #48
   2da3c: e5018034     	str	r8, [r1, #-0x34]
   2da40: e897008c     	ldm	r7, {r2, r3, r7}
   2da44: e6bf7f37     	rev	r7, r7
   2da48: e89e5020     	ldm	lr, {r5, r12, lr}
   2da4c: e6bf2f32     	rev	r2, r2
   2da50: e6bf3f33     	rev	r3, r3
   2da54: e594602c     	ldr	r6, [r4, #0x2c]
   2da58: e6bf5f35     	rev	r5, r5
   2da5c: e594803c     	ldr	r8, [r4, #0x3c]
   2da60: e6bfcf3c     	rev	r12, r12
   2da64: e5012030     	str	r2, [r1, #-0x30]
   2da68: e2412020     	sub	r2, r1, #32
   2da6c: e501302c     	str	r3, [r1, #-0x2c]
   2da70: e6bf6f36     	rev	r6, r6
   2da74: e5017028     	str	r7, [r1, #-0x28]
   2da78: e2847040     	add	r7, r4, #64
   2da7c: e6bfef3e     	rev	lr, lr
   2da80: e5016024     	str	r6, [r1, #-0x24]
   2da84: e8825020     	stm	r2, {r5, r12, lr}
   2da88: e6bf8f38     	rev	r8, r8
   2da8c: e241c010     	sub	r12, r1, #16
   2da90: e5018014     	str	r8, [r1, #-0x14]
   2da94: e897008c     	ldm	r7, {r2, r3, r7}
   2da98: e6bf3f33     	rev	r3, r3
   2da9c: e594604c     	ldr	r6, [r4, #0x4c]
   2daa0: e6bf2f32     	rev	r2, r2
   2daa4: e6bf7f37     	rev	r7, r7
   2daa8: e88c008c     	stm	r12, {r2, r3, r7}
   2daac: e6bf6f36     	rev	r6, r6
   2dab0: e5016004     	str	r6, [r1, #-0x4]
   2dab4: e3a01050     	mov	r1, #80
   2dab8: e1a0200a     	mov	r2, r10
   2dabc: eb036d1d     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xdb474
   2dac0: e2842e12     	add	r2, r4, #288
   2dac4: e1a0000a     	mov	r0, r10
   2dac8: e3a01020     	mov	r1, #32
   2dacc: eb036d19     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xdb464
   2dad0: e5990000     	ldr	r0, [r9]
   2dad4: e2401001     	sub	r1, r0, #1
   2dad8: e0000190     	mul	r0, r0, r1
   2dadc: e3100001     	tst	r0, #1
   2dae0: 0a000044     	beq	0x2dbf8 <.text+0x1daf8> @ imm = #0x110
   2dae4: e59f011c     	ldr	r0, [pc, #0x11c]        @ 0x2dc08 <.text+0x1db08>
   2dae8: e79f0000     	ldr	r0, [pc, r0]
   2daec: e5900000     	ldr	r0, [r0]
   2daf0: e3500009     	cmp	r0, #9
   2daf4: da00003f     	ble	0x2dbf8 <.text+0x1daf8> @ imm = #0xfc
   2daf8: e1a0100d     	mov	r1, sp
   2dafc: e2410050     	sub	r0, r1, #80
   2db00: e1a0d000     	mov	sp, r0
   2db04: e24d8020     	sub	r8, sp, #32
   2db08: e1a0d008     	mov	sp, r8
   2db0c: e284e010     	add	lr, r4, #16
   2db10: e894008c     	ldm	r4, {r2, r3, r7}
   2db14: e6bf7f37     	rev	r7, r7
   2db18: e89e5020     	ldm	lr, {r5, r12, lr}
   2db1c: e6bf2f32     	rev	r2, r2
   2db20: e6bf3f33     	rev	r3, r3
   2db24: e594600c     	ldr	r6, [r4, #0xc]
   2db28: e6bf5f35     	rev	r5, r5
   2db2c: e594a01c     	ldr	r10, [r4, #0x1c]
   2db30: e6bfef3e     	rev	lr, lr
   2db34: e5012050     	str	r2, [r1, #-0x50]
   2db38: e2412040     	sub	r2, r1, #64
   2db3c: e501304c     	str	r3, [r1, #-0x4c]
   2db40: e6bf6f36     	rev	r6, r6
   2db44: e5017048     	str	r7, [r1, #-0x48]
   2db48: e2847020     	add	r7, r4, #32
   2db4c: e6bfcf3c     	rev	r12, r12
   2db50: e5016044     	str	r6, [r1, #-0x44]
   2db54: e8825020     	stm	r2, {r5, r12, lr}
   2db58: e6bfaf3a     	rev	r10, r10
   2db5c: e284e030     	add	lr, r4, #48
   2db60: e501a034     	str	r10, [r1, #-0x34]
   2db64: e897008c     	ldm	r7, {r2, r3, r7}
   2db68: e6bf7f37     	rev	r7, r7
   2db6c: e89e5020     	ldm	lr, {r5, r12, lr}
   2db70: e6bf2f32     	rev	r2, r2
   2db74: e6bf3f33     	rev	r3, r3
   2db78: e594602c     	ldr	r6, [r4, #0x2c]
   2db7c: e6bf5f35     	rev	r5, r5
   2db80: e594a03c     	ldr	r10, [r4, #0x3c]
   2db84: e6bfcf3c     	rev	r12, r12
   2db88: e5012030     	str	r2, [r1, #-0x30]
   2db8c: e2412020     	sub	r2, r1, #32
   2db90: e501302c     	str	r3, [r1, #-0x2c]
   2db94: e6bf6f36     	rev	r6, r6
   2db98: e5017028     	str	r7, [r1, #-0x28]
   2db9c: e2847040     	add	r7, r4, #64
   2dba0: e6bfef3e     	rev	lr, lr
   2dba4: e5016024     	str	r6, [r1, #-0x24]
   2dba8: e8825020     	stm	r2, {r5, r12, lr}
   2dbac: e6bfaf3a     	rev	r10, r10
   2dbb0: e241c010     	sub	r12, r1, #16
   2dbb4: e501a014     	str	r10, [r1, #-0x14]
   2dbb8: e897008c     	ldm	r7, {r2, r3, r7}
   2dbbc: e6bf3f33     	rev	r3, r3
   2dbc0: e594604c     	ldr	r6, [r4, #0x4c]
   2dbc4: e6bf2f32     	rev	r2, r2
   2dbc8: e6bf7f37     	rev	r7, r7
   2dbcc: e88c008c     	stm	r12, {r2, r3, r7}
   2dbd0: e6bf6f36     	rev	r6, r6
   2dbd4: e5016004     	str	r6, [r1, #-0x4]
   2dbd8: e3a01050     	mov	r1, #80
   2dbdc: e1a02008     	mov	r2, r8
   2dbe0: eb036cd4     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xdb350
   2dbe4: e2842e12     	add	r2, r4, #288
   2dbe8: e1a00008     	mov	r0, r8
   2dbec: e3a01020     	mov	r1, #32
   2dbf0: eb036cd0     	bl	0x108f38 <.text+0xf8e38> @ imm = #0xdb340
   2dbf4: eaffff76     	b	0x2d9d4 <.text+0x1d8d4> @ imm = #-0x228
   2dbf8: e24bd01c     	sub	sp, r11, #28
   2dbfc: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   2dc00: 005b1e78     	subseq	r1, r11, r8, ror lr
   2dc04: 005b1d88     	subseq	r1, r11, r8, lsl #27
   2dc08: 005b1c64     	subseq	r1, r11, r4, ror #24

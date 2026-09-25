
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   74de4: e5952278     	ldr	r2, [r5, #0x278]
   74de8: e3a01000     	mov	r1, #0
   74dec: e59d004c     	ldr	r0, [sp, #0x4c]
   74df0: e1500002     	cmp	r0, r2
   74df4: 0a000013     	beq	0x74e48 <.text+0x64d48> @ imm = #0x4c
   74df8: e5981000     	ldr	r1, [r8]
   74dfc: e2412001     	sub	r2, r1, #1
   74e00: e0010291     	mul	r1, r1, r2
   74e04: e3110001     	tst	r1, #1
   74e08: e5981000     	ldr	r1, [r8]
   74e0c: e2412001     	sub	r2, r1, #1
   74e10: e0010291     	mul	r1, r1, r2
   74e14: e59526f0     	ldr	r2, [r5, #0x6f0]
   74e18: e3110001     	tst	r1, #1
   74e1c: 0a000002     	beq	0x74e2c <.text+0x64d2c> @ imm = #0x8
   74e20: e5971000     	ldr	r1, [r7]
   74e24: e3510009     	cmp	r1, #9
   74e28: cafffff6     	bgt	0x74e08 <.text+0x64d08> @ imm = #-0x28
   74e2c: e3a01001     	mov	r1, #1
   74e30: e1500002     	cmp	r0, r2
   74e34: 0a000003     	beq	0x74e48 <.text+0x64d48> @ imm = #0xc
   74e38: e5952b68     	ldr	r2, [r5, #0xb68]
   74e3c: e3a01002     	mov	r1, #2
   74e40: e1500002     	cmp	r0, r2
   74e44: 1a00000c     	bne	0x74e7c <.text+0x64d7c> @ imm = #0x30
   74e48: e3000478     	movw	r0, #0x478
   74e4c: e1045081     	smlabb	r4, r1, r0, r5
   74e50: e3740e26     	cmn	r4, #608
   74e54: 1594a27c     	ldrne	r10, [r4, #0x27c]
   74e58: 135a0000     	cmpne	r10, #0
   74e5c: 0a000006     	beq	0x74e7c <.text+0x64d7c> @ imm = #0x18
   74e60: e1a0000a     	mov	r0, r10
   74e64: ebfeffba     	bl	0x34d54 <.text+0x24c54> @ imm = #-0x40118
   74e68: e3500000     	cmp	r0, #0
   74e6c: 1a000002     	bne	0x74e7c <.text+0x64d7c> @ imm = #0x8
   74e70: e59a01fc     	ldr	r0, [r10, #0x1fc]
   74e74: e3500000     	cmp	r0, #0
   74e78: 1a000025     	bne	0x74f14 <.text+0x64e14> @ imm = #0x94

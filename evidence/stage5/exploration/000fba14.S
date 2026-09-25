
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fba14: e5987000     	ldr	r7, [r8]
   fba18: e3a04001     	mov	r4, #1
   fba1c: e2475001     	sub	r5, r7, #1
   fba20: e0070597     	mul	r7, r7, r5
   fba24: e5965000     	ldr	r5, [r6]
   fba28: e355000a     	cmp	r5, #10
   fba2c: e1c47007     	bic	r7, r4, r7
   fba30: e3a04000     	mov	r4, #0
   fba34: b3004001     	movwlt	r4, #0x1
   fba38: e1877004     	orr	r7, r7, r4
   fba3c: e3510008     	cmp	r1, #8
   fba40: 1a000004     	bne	0xfba58 <.text+0xeb958> @ imm = #0x10
   fba44: e59f5bc0     	ldr	r5, [pc, #0xbc0]        @ 0xfc60c <.text+0xec50c>
   fba48: e3570000     	cmp	r7, #0
   fba4c: e08f5005     	add	r5, pc, r5
   fba50: 1a00002a     	bne	0xfbb00 <.text+0xeba00> @ imm = #0xa8
   fba54: ea00003c     	b	0xfbb4c <.text+0xeba4c> @ imm = #0xf0
   fba58: e59f5bb0     	ldr	r5, [pc, #0xbb0]        @ 0xfc610 <.text+0xec510>
   fba5c: e3570000     	cmp	r7, #0
   fba60: e59f8bac     	ldr	r8, [pc, #0xbac]        @ 0xfc614 <.text+0xec514>
   fba64: e59fcbac     	ldr	r12, [pc, #0xbac]       @ 0xfc618 <.text+0xec518>
   fba68: e08f5005     	add	r5, pc, r5
   fba6c: e59feba8     	ldr	lr, [pc, #0xba8]        @ 0xfc61c <.text+0xec51c>
   fba70: e08f8008     	add	r8, pc, r8
   fba74: e08fc00c     	add	r12, pc, r12
   fba78: e1a0a005     	mov	r10, r5
   fba7c: e08fe00e     	add	lr, pc, lr
   fba80: 1a00003c     	bne	0xfbb78 <.text+0xeba78> @ imm = #0xf0
   fba84: ea00007d     	b	0xfbc80 <.text+0xebb80> @ imm = #0x1f4
   fba88: e59f0b90     	ldr	r0, [pc, #0xb90]        @ 0xfc620 <.text+0xec520>
   fba8c: e3a03001     	mov	r3, #1
   fba90: e59f1b8c     	ldr	r1, [pc, #0xb8c]        @ 0xfc624 <.text+0xec524>
   fba94: e59f2b8c     	ldr	r2, [pc, #0xb8c]        @ 0xfc628 <.text+0xec528>
   fba98: e08f0000     	add	r0, pc, r0
   fba9c: e08f1001     	add	r1, pc, r1
   fbaa0: e88d0028     	stm	sp, {r3, r5}
   fbaa4: e08f2002     	add	r2, pc, r2
   fbaa8: e3a0305d     	mov	r3, #93
   fbaac: ebfff984     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x19f0
   fbab0: e5980000     	ldr	r0, [r8]
   fbab4: e3e04000     	mvn	r4, #0
   fbab8: e2401001     	sub	r1, r0, #1
   fbabc: e0000190     	mul	r0, r0, r1
   fbac0: e3100001     	tst	r0, #1
   fbac4: 0a000781     	beq	0xfd8d0 <.text+0xed7d0> @ imm = #0x1e04
   fbac8: e5960000     	ldr	r0, [r6]
   fbacc: e350000a     	cmp	r0, #10
   fbad0: ba00077e     	blt	0xfd8d0 <.text+0xed7d0> @ imm = #0x1df8
   fbad4: e59f0b50     	ldr	r0, [pc, #0xb50]        @ 0xfc62c <.text+0xec52c>
   fbad8: e3a03001     	mov	r3, #1
   fbadc: e59f1b4c     	ldr	r1, [pc, #0xb4c]        @ 0xfc630 <.text+0xec530>
   fbae0: e59f2b4c     	ldr	r2, [pc, #0xb4c]        @ 0xfc634 <.text+0xec534>
   fbae4: e08f0000     	add	r0, pc, r0
   fbae8: e08f1001     	add	r1, pc, r1
   fbaec: e88d0028     	stm	sp, {r3, r5}
   fbaf0: e08f2002     	add	r2, pc, r2
   fbaf4: e3a0305d     	mov	r3, #93
   fbaf8: ebfff971     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1a3c
   fbafc: eaffffe1     	b	0xfba88 <.text+0xeb988> @ imm = #-0x7c
   fbb00: e59f0b30     	ldr	r0, [pc, #0xb30]        @ 0xfc638 <.text+0xec538>
   fbb04: e3a03001     	mov	r3, #1
   fbb08: e59f1b2c     	ldr	r1, [pc, #0xb2c]        @ 0xfc63c <.text+0xec53c>
   fbb0c: e59f2b2c     	ldr	r2, [pc, #0xb2c]        @ 0xfc640 <.text+0xec540>
   fbb10: e08f0000     	add	r0, pc, r0
   fbb14: e08f1001     	add	r1, pc, r1
   fbb18: e88d0028     	stm	sp, {r3, r5}
   fbb1c: e08f2002     	add	r2, pc, r2
   fbb20: e3a03062     	mov	r3, #98
   fbb24: ebfff966     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1a68
   fbb28: e5980000     	ldr	r0, [r8]
   fbb2c: e3e04000     	mvn	r4, #0
   fbb30: e2401001     	sub	r1, r0, #1
   fbb34: e0000190     	mul	r0, r0, r1
   fbb38: e3100001     	tst	r0, #1
   fbb3c: 0a000763     	beq	0xfd8d0 <.text+0xed7d0> @ imm = #0x1d8c
   fbb40: e5960000     	ldr	r0, [r6]
   fbb44: e350000a     	cmp	r0, #10
   fbb48: ba000760     	blt	0xfd8d0 <.text+0xed7d0> @ imm = #0x1d80
   fbb4c: e59f0af0     	ldr	r0, [pc, #0xaf0]        @ 0xfc644 <.text+0xec544>
   fbb50: e3a03001     	mov	r3, #1
   fbb54: e59f1aec     	ldr	r1, [pc, #0xaec]        @ 0xfc648 <.text+0xec548>
   fbb58: e59f2aec     	ldr	r2, [pc, #0xaec]        @ 0xfc64c <.text+0xec54c>
   fbb5c: e08f0000     	add	r0, pc, r0
   fbb60: e08f1001     	add	r1, pc, r1
   fbb64: e88d0028     	stm	sp, {r3, r5}
   fbb68: e08f2002     	add	r2, pc, r2
   fbb6c: e3a03062     	mov	r3, #98
   fbb70: ebfff953     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0x1ab4
   fbb74: eaffffe1     	b	0xfbb00 <.text+0xeba00> @ imm = #-0x7c
   fbb78: e59f4ad0     	ldr	r4, [pc, #0xad0]        @ 0xfc650 <.text+0xec550>
   fbb7c: e3500000     	cmp	r0, #0
   fbb80: e79f4004     	ldr	r4, [pc, r4]
   fbb84: e5969000     	ldr	r9, [r6]
   fbb88: e5947000     	ldr	r7, [r4]
   fbb8c: e2474001     	sub	r4, r7, #1
   fbb90: e0070497     	mul	r7, r7, r4
   fbb94: e59f4ab8     	ldr	r4, [pc, #0xab8]        @ 0xfc654 <.text+0xec554>
   fbb98: e5850000     	str	r0, [r5]
   fbb9c: e08f4004     	add	r4, pc, r4

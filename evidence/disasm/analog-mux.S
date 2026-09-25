
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ece3c: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
   ece40: e28db010     	add	r11, sp, #16
   ece44: e24dd010     	sub	sp, sp, #16
   ece48: e1a04000     	mov	r4, r0
   ece4c: e2010007     	and	r0, r1, #7
   ece50: e58d0000     	str	r0, [sp]
   ece54: e1a00004     	mov	r0, r4
   ece58: e3a01001     	mov	r1, #1
   ece5c: e3a02000     	mov	r2, #0
   ece60: e3a03054     	mov	r3, #84
   ece64: e3a06001     	mov	r6, #1
   ece68: e3a05000     	mov	r5, #0
   ece6c: eb00069c     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x1a70
   ece70: e3500000     	cmp	r0, #0
   ece74: 0a00000f     	beq	0xeceb8 <.text+0xdcdb8> @ imm = #0x3c
   ece78: e59f0044     	ldr	r0, [pc, #0x44]         @ 0xecec4 <.text+0xdcdc4>
   ece7c: e59f1044     	ldr	r1, [pc, #0x44]         @ 0xecec8 <.text+0xdcdc8>
   ece80: e59f2044     	ldr	r2, [pc, #0x44]         @ 0xececc <.text+0xdcdcc>
   ece84: e08f0000     	add	r0, pc, r0
   ece88: e5943018     	ldr	r3, [r4, #0x18]
   ece8c: e08f1001     	add	r1, pc, r1
   ece90: e59f5038     	ldr	r5, [pc, #0x38]         @ 0xeced0 <.text+0xdcdd0>
   ece94: e08f2002     	add	r2, pc, r2
   ece98: e2833001     	add	r3, r3, #1
   ece9c: e58d3008     	str	r3, [sp, #0x8]
   ecea0: e30033b6     	movw	r3, #0x3b6
   ecea4: e08f5005     	add	r5, pc, r5
   ecea8: e58d6000     	str	r6, [sp]
   eceac: e58d5004     	str	r5, [sp, #0x4]
   eceb0: eb003483     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xd20c
   eceb4: e3e05000     	mvn	r5, #0
   eceb8: e1a00005     	mov	r0, r5
   ecebc: e24bd010     	sub	sp, r11, #16
   ecec0: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
   ecec4: 004ff054     	subeq	pc, pc, r4, asr r0
   ecec8: 004ff053     	subeq	pc, pc, r3, asr r0
   ececc: 004ff075     	subeq	pc, pc, r5, ror r0
   eced0: 004ff3c9     	subeq	pc, pc, r9, asr #7

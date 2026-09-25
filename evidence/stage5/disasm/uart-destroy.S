
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  10e9a0: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
  10e9a4: e28db010     	add	r11, sp, #16
  10e9a8: e1a04000     	mov	r4, r0
  10e9ac: e590001c     	ldr	r0, [r0, #0x1c]
  10e9b0: e3500000     	cmp	r0, #0
  10e9b4: 0a000002     	beq	0x10e9c4 <.text+0xfe8c4> @ imm = #0x8
  10e9b8: eb1214b3     	bl	0x593c8c <.text+0x583b8c> @ imm = #0x4852cc
  10e9bc: e3a00000     	mov	r0, #0
  10e9c0: e584001c     	str	r0, [r4, #0x1c]
  10e9c4: e5940020     	ldr	r0, [r4, #0x20]
  10e9c8: e3700001     	cmn	r0, #1
  10e9cc: 0a000002     	beq	0x10e9dc <.text+0xfe8dc> @ imm = #0x8
  10e9d0: eb1265d1     	bl	0x5a811c <.text+0x59801c> @ imm = #0x499744
  10e9d4: e3e00000     	mvn	r0, #0
  10e9d8: e5840020     	str	r0, [r4, #0x20]
  10e9dc: e59f5070     	ldr	r5, [pc, #0x70]         @ 0x10ea54 <.text+0xfe954>
  10e9e0: e79f5005     	ldr	r5, [pc, r5]
  10e9e4: e5950000     	ldr	r0, [r5]
  10e9e8: e59f6068     	ldr	r6, [pc, #0x68]         @ 0x10ea58 <.text+0xfe958>
  10e9ec: e2401001     	sub	r1, r0, #1
  10e9f0: e0000190     	mul	r0, r0, r1
  10e9f4: e79f6006     	ldr	r6, [pc, r6]
  10e9f8: e3100001     	tst	r0, #1
  10e9fc: 0a000002     	beq	0x10ea0c <.text+0xfe90c> @ imm = #0x8
  10ea00: e5960000     	ldr	r0, [r6]
  10ea04: e3500009     	cmp	r0, #9
  10ea08: ca00000b     	bgt	0x10ea3c <.text+0xfe93c> @ imm = #0x2c
  10ea0c: e1a00004     	mov	r0, r4
  10ea10: eb125da8     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x4976a0
  10ea14: e3a00000     	mov	r0, #0
  10ea18: e5840024     	str	r0, [r4, #0x24]
  10ea1c: e5950000     	ldr	r0, [r5]
  10ea20: e2401001     	sub	r1, r0, #1
  10ea24: e0000190     	mul	r0, r0, r1
  10ea28: e3100001     	tst	r0, #1
  10ea2c: 0a000007     	beq	0x10ea50 <.text+0xfe950> @ imm = #0x1c
  10ea30: e5960000     	ldr	r0, [r6]
  10ea34: e3500009     	cmp	r0, #9
  10ea38: da000004     	ble	0x10ea50 <.text+0xfe950> @ imm = #0x10
  10ea3c: e1a00004     	mov	r0, r4
  10ea40: eb125d9c     	bl	0x5a60b8 <.text+0x595fb8> @ imm = #0x497670
  10ea44: e3a00000     	mov	r0, #0
  10ea48: e5840024     	str	r0, [r4, #0x24]
  10ea4c: eaffffee     	b	0x10ea0c <.text+0xfe90c> @ imm = #-0x48
  10ea50: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
  10ea54: 004d08e0     	subeq	r0, sp, r0, ror #17
  10ea58: 004cff48     	subeq	pc, r12, r8, asr #30

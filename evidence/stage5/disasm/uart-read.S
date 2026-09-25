
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  10e938: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
  10e93c: e28db010     	add	r11, sp, #16
  10e940: e24dd008     	sub	sp, sp, #8
  10e944: e1a06000     	mov	r6, r0
  10e948: e5900020     	ldr	r0, [r0, #0x20]
  10e94c: e1a04002     	mov	r4, r2
  10e950: e28d2004     	add	r2, sp, #4
  10e954: e1a05001     	mov	r5, r1
  10e958: e305141b     	movw	r1, #0x541b
  10e95c: eb1222fb     	bl	0x597550 <.text+0x587450> @ imm = #0x488bec
  10e960: e1a01000     	mov	r1, r0
  10e964: e3a00000     	mov	r0, #0
  10e968: e3510000     	cmp	r1, #0
  10e96c: 1a000006     	bne	0x10e98c <.text+0xfe88c> @ imm = #0x18
  10e970: e59d1004     	ldr	r1, [sp, #0x4]
  10e974: e3510000     	cmp	r1, #0
  10e978: 0a000003     	beq	0x10e98c <.text+0xfe88c> @ imm = #0xc
  10e97c: e5960020     	ldr	r0, [r6, #0x20]
  10e980: e1a01005     	mov	r1, r5
  10e984: e1a02004     	mov	r2, r4
  10e988: eb1266c2     	bl	0x5a8498 <.text+0x598398> @ imm = #0x499b08
  10e98c: e24bd010     	sub	sp, r11, #16
  10e990: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}

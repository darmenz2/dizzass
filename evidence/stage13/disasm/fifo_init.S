
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d19b0: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
   d19b4: e28db010     	add	r11, sp, #16
   d19b8: e1a06000     	mov	r6, r0
   d19bc: e0000192     	mul	r0, r2, r1
   d19c0: e1a04002     	mov	r4, r2
   d19c4: e1a05001     	mov	r5, r1
   d19c8: eb1309c7     	bl	0x5940ec <.text+0x583fec> @ imm = #0x4c271c
   d19cc: e3a02000     	mov	r2, #0
   d19d0: e0210594     	mla	r1, r4, r5, r0
   d19d4: e8860003     	stm	r6, {r0, r1}
   d19d8: e5860008     	str	r0, [r6, #0x8]
   d19dc: e586000c     	str	r0, [r6, #0xc]
   d19e0: e5865010     	str	r5, [r6, #0x10]
   d19e4: e5862014     	str	r2, [r6, #0x14]
   d19e8: e5864018     	str	r4, [r6, #0x18]
   d19ec: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}

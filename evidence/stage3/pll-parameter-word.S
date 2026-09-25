
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ec01c: e28d3020     	add	r3, sp, #32
   ec020: e3a07c3f     	mov	r7, #16128
   ec024: e3a06001     	mov	r6, #1
   ec028: e3a05000     	mov	r5, #0
   ec02c: e893000f     	ldm	r3, {r0, r1, r2, r3}
   ec030: e0070400     	and	r0, r7, r0, lsl #8
   ec034: e7db0811     	bfi	r0, r1, #16, #12
   ec038: e2021007     	and	r1, r2, #7
   ec03c: e3a02000     	mov	r2, #0
   ec040: e1800201     	orr	r0, r0, r1, lsl #4
   ec044: e2031007     	and	r1, r3, #7
   ec048: e1800001     	orr	r0, r0, r1
   ec04c: e3a01001     	mov	r1, #1
   ec050: e3807101     	orr	r7, r0, #1073741824
   ec054: e1a00004     	mov	r0, r4
   ec058: e3a03008     	mov	r3, #8
   ec05c: e58d7000     	str	r7, [sp]

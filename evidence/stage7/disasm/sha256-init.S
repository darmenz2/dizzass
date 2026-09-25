
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  109120: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
  109124: e28db010     	add	r11, sp, #16
  109128: e59f103c     	ldr	r1, [pc, #0x3c]         @ 0x10916c <.text+0xf906c>
  10912c: e3a07000     	mov	r7, #0
  109130: e79f1001     	ldr	r1, [pc, r1]
  109134: e2816010     	add	r6, r1, #16
  109138: e891500c     	ldm	r1, {r2, r3, r12, lr}
  10913c: e8960070     	ldm	r6, {r4, r5, r6}
  109140: e591101c     	ldr	r1, [r1, #0x1c]
  109144: e5802088     	str	r2, [r0, #0x88]
  109148: e2802098     	add	r2, r0, #152
  10914c: e580308c     	str	r3, [r0, #0x8c]
  109150: e580c090     	str	r12, [r0, #0x90]
  109154: e580e094     	str	lr, [r0, #0x94]
  109158: e8820070     	stm	r2, {r4, r5, r6}
  10915c: e58010a4     	str	r1, [r0, #0xa4]
  109160: e5807000     	str	r7, [r0]
  109164: e5807004     	str	r7, [r0, #0x4]
  109168: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
  10916c: 004d651c     	subeq	r6, sp, r12, lsl r5


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c4114: e3010064     	movw	r0, #0x1064
   c4118: e1a01009     	mov	r1, r9
   c411c: e7e18000     	strb	r8, [r1, r0]!
   c4120: e24b8068     	sub	r8, r11, #104
   c4124: e59d004c     	ldr	r0, [sp, #0x4c]
   c4128: e58d1044     	str	r1, [sp, #0x44]
   c412c: e3500001     	cmp	r0, #1
   c4130: 03007008     	movweq	r7, #0x8
   c4134: e3500000     	cmp	r0, #0
   c4138: e28d0058     	add	r0, sp, #88
   c413c: 03007007     	movweq	r7, #0x7
   c4140: e2800088     	add	r0, r0, #136
   c4144: e58d000c     	str	r0, [sp, #0xc]
   c4148: e24b00f8     	sub	r0, r11, #248
   c414c: e2801024     	add	r1, r0, #36
   c4150: e2800018     	add	r0, r0, #24
   c4154: e58d0004     	str	r0, [sp, #0x4]
   c4158: e3880001     	orr	r0, r8, #1
   c415c: e58d0030     	str	r0, [sp, #0x30]
   c4160: e2880008     	add	r0, r8, #8
   c4164: e58d0034     	str	r0, [sp, #0x34]
   c4168: e3880006     	orr	r0, r8, #6
   c416c: e58d0048     	str	r0, [sp, #0x48]
   c4170: e3880007     	orr	r0, r8, #7
   c4174: e58d003c     	str	r0, [sp, #0x3c]
   c4178: e3860001     	orr	r0, r6, #1
   c417c: e58d1008     	str	r1, [sp, #0x8]
   c4180: e58d0010     	str	r0, [sp, #0x10]


reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   30c9c: e894004f     	ldm	r4, {r0, r1, r2, r3, r6}
   30ca0: e284c014     	add	r12, r4, #20
   30ca4: e6bf0f30     	rev	r0, r0
   30ca8: e89c10a0     	ldm	r12, {r5, r7, r12}
   30cac: e50b006c     	str	r0, [r11, #-0x6c]
   30cb0: e6bf0f31     	rev	r0, r1
   30cb4: e50b0068     	str	r0, [r11, #-0x68]
   30cb8: e6bf0f32     	rev	r0, r2
   30cbc: e50b0064     	str	r0, [r11, #-0x64]
   30cc0: e6bf0f33     	rev	r0, r3
   30cc4: e50b0060     	str	r0, [r11, #-0x60]
   30cc8: e6bf0f36     	rev	r0, r6
   30ccc: e50b005c     	str	r0, [r11, #-0x5c]
   30cd0: e6bf0f35     	rev	r0, r5
   30cd4: e50b0058     	str	r0, [r11, #-0x58]
   30cd8: e6bf0f37     	rev	r0, r7
   30cdc: e2847020     	add	r7, r4, #32
   30ce0: e50b0054     	str	r0, [r11, #-0x54]
   30ce4: e6bf0f3c     	rev	r0, r12
   30ce8: e50b0050     	str	r0, [r11, #-0x50]
   30cec: e897008f     	ldm	r7, {r0, r1, r2, r3, r7}
   30cf0: e6bf0f30     	rev	r0, r0
   30cf4: e5946034     	ldr	r6, [r4, #0x34]
   30cf8: e5945038     	ldr	r5, [r4, #0x38]
   30cfc: e594c03c     	ldr	r12, [r4, #0x3c]
   30d00: e50b004c     	str	r0, [r11, #-0x4c]
   30d04: e6bf0f31     	rev	r0, r1
   30d08: e50b0048     	str	r0, [r11, #-0x48]
   30d0c: e6bf0f32     	rev	r0, r2
   30d10: e50b0044     	str	r0, [r11, #-0x44]
   30d14: e6bf0f33     	rev	r0, r3
   30d18: e50b0040     	str	r0, [r11, #-0x40]
   30d1c: e6bf0f37     	rev	r0, r7
   30d20: e50b003c     	str	r0, [r11, #-0x3c]
   30d24: e6bf0f36     	rev	r0, r6
   30d28: e50b0038     	str	r0, [r11, #-0x38]
   30d2c: e6bf0f35     	rev	r0, r5
   30d30: e28d507c     	add	r5, sp, #124
   30d34: e50b0034     	str	r0, [r11, #-0x34]
   30d38: e6bf0f3c     	rev	r0, r12
   30d3c: e50b0030     	str	r0, [r11, #-0x30]
   30d40: e1a00005     	mov	r0, r5
   30d44: eb0360f5     	bl	0x109120 <.text+0xf9020> @ imm = #0xd83d4
   30d48: e24b106c     	sub	r1, r11, #108
   30d4c: e1a00005     	mov	r0, r5
   30d50: e3a02040     	mov	r2, #64
   30d54: eb036105     	bl	0x109170 <.text+0xf9070> @ imm = #0xd8414
   30d58: e59f3544     	ldr	r3, [pc, #0x544]        @ 0x312a4 <.text+0x211a4>
   30d5c: e3000151     	movw	r0, #0x151
   30d60: e59f1540     	ldr	r1, [pc, #0x540]        @ 0x312a8 <.text+0x211a8>
   30d64: e3a02020     	mov	r2, #32
   30d68: e58d0004     	str	r0, [sp, #0x4]
   30d6c: e08f3003     	add	r3, pc, r3
   30d70: e08f1001     	add	r1, pc, r1
   30d74: e58d1000     	str	r1, [sp]
   30d78: e2840080     	add	r0, r4, #128
   30d7c: e2851088     	add	r1, r5, #136
   30d80: ebff83fd     	bl	0x11d7c <.text+0x1c7c>  @ imm = #-0x1f00c
   30d84: ed940b68     	vldr	d0, [r4, #416]
   30d88: e1a0000a     	mov	r0, r10
   30d8c: ebfffc33     	bl	0x2fe60 <.text+0x1fd60> @ imm = #-0xf34

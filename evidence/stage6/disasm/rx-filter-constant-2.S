
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ecf24: e59f0030     	ldr	r0, [pc, #0x30]         @ 0xecf5c <.text+0xdce5c>
   ecf28: e79f0000     	ldr	r0, [pc, r0]
   ecf2c: e59f102c     	ldr	r1, [pc, #0x2c]         @ 0xecf60 <.text+0xdce60>
   ecf30: e79f1001     	ldr	r1, [pc, r1]
   ecf34: e5902000     	ldr	r2, [r0]
   ecf38: e2423001     	sub	r3, r2, #1
   ecf3c: e0020392     	mul	r2, r2, r3
   ecf40: e3120001     	tst	r2, #1
   ecf44: 0a000002     	beq	0xecf54 <.text+0xdce54> @ imm = #0x8
   ecf48: e5912000     	ldr	r2, [r1]
   ecf4c: e3520009     	cmp	r2, #9
   ecf50: cafffff7     	bgt	0xecf34 <.text+0xdce34> @ imm = #-0x24
   ecf54: e3a00040     	mov	r0, #64
   ecf58: e12fff1e     	bx	lr


${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   e3bc4: e59f0030     	ldr	r0, [pc, #0x30]         @ 0xe3bfc <.text+0xd3afc>
   e3bc8: e79f0000     	ldr	r0, [pc, r0]
   e3bcc: e59f102c     	ldr	r1, [pc, #0x2c]         @ 0xe3c00 <.text+0xd3b00>
   e3bd0: e79f1001     	ldr	r1, [pc, r1]
   e3bd4: e5902000     	ldr	r2, [r0]
   e3bd8: e2423001     	sub	r3, r2, #1
   e3bdc: e0020392     	mul	r2, r2, r3
   e3be0: e3120001     	tst	r2, #1
   e3be4: 0a000002     	beq	0xe3bf4 <.text+0xd3af4> @ imm = #0x8
   e3be8: e5912000     	ldr	r2, [r1]
   e3bec: e3520009     	cmp	r2, #9
   e3bf0: cafffff7     	bgt	0xe3bd4 <.text+0xd3ad4> @ imm = #-0x24
   e3bf4: e3a00040     	mov	r0, #64
   e3bf8: e12fff1e     	bx	lr

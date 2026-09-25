
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   1ff00: e3a02000     	mov	r2, #0
   1ff04: e3520000     	cmp	r2, #0
   1ff08: 1a000007     	bne	0x1ff2c <.text+0xfe2c>  @ imm = #0x1c
   1ff0c: e59f3fd8     	ldr	r3, [pc, #0xfd8]        @ 0x20eec <.text+0x10dec>
   1ff10: e08f3003     	add	r3, pc, r3
   1ff14: e7d30002     	ldrb	r0, [r3, r2]
   1ff18: e220001a     	eor	r0, r0, #26
   1ff1c: e7c30002     	strb	r0, [r3, r2]
   1ff20: e2822001     	add	r2, r2, #1
   1ff24: e3520010     	cmp	r2, #16
   1ff28: 1afffff9     	bne	0x1ff14 <.text+0xfe14>  @ imm = #-0x1c

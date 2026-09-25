
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   d55cc: e59f0030     	ldr	r0, [pc, #0x30]         @ 0xd5604 <.text+0xc5504>
   d55d0: e79f0000     	ldr	r0, [pc, r0]
   d55d4: e59f102c     	ldr	r1, [pc, #0x2c]         @ 0xd5608 <.text+0xc5508>
   d55d8: e79f1001     	ldr	r1, [pc, r1]
   d55dc: e5902000     	ldr	r2, [r0]
   d55e0: e2423001     	sub	r3, r2, #1
   d55e4: e0020392     	mul	r2, r2, r3
   d55e8: e3120001     	tst	r2, #1
   d55ec: 0a000002     	beq	0xd55fc <.text+0xc54fc> @ imm = #0x8
   d55f0: e5912000     	ldr	r2, [r1]
   d55f4: e3520009     	cmp	r2, #9
   d55f8: cafffff7     	bgt	0xd55dc <.text+0xc54dc> @ imm = #-0x24
   d55fc: e3a00040     	mov	r0, #64
   d5600: e12fff1e     	bx	lr

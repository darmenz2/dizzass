
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   31070: e1ca01d8     	ldrd	r0, r1, [r10, #24]
   31074: eb1580af     	bl	0x591338 <.text+0x581238> @ imm = #0x5602bc
   31078: e1a08000     	mov	r8, r0
   3107c: e1a06001     	mov	r6, r1
   31080: e1ca01d0     	ldrd	r0, r1, [r10, #16]
   31084: eb1580ab     	bl	0x591338 <.text+0x581238> @ imm = #0x5602ac
   31088: ec410b11     	vmov	d1, r0, r1
   3108c: ed9f0b5d     	vldr	d0, [pc, #372]          @ 0x31208 <.text+0x21108>
   31090: e59a0008     	ldr	r0, [r10, #0x8]
   31094: ee218b00     	vmul.f64	d8, d1, d0
   31098: e59a100c     	ldr	r1, [r10, #0xc]
   3109c: ec468b11     	vmov	d1, r8, r6
   310a0: ed9f0b5a     	vldr	d0, [pc, #360]          @ 0x31210 <.text+0x21110>
   310a4: e89a0140     	ldm	r10, {r6, r8}
   310a8: ee018b00     	vmla.f64	d8, d1, d0
   310ac: eb1580a1     	bl	0x591338 <.text+0x581238> @ imm = #0x560284
   310b0: ec410b11     	vmov	d1, r0, r1
   310b4: ed9f0b57     	vldr	d0, [pc, #348]          @ 0x31218 <.text+0x21118>
   310b8: e1a00006     	mov	r0, r6
   310bc: e1a01008     	mov	r1, r8
   310c0: ee018b00     	vmla.f64	d8, d1, d0
   310c4: eb15809b     	bl	0x591338 <.text+0x581238> @ imm = #0x56026c
   310c8: ec410b10     	vmov	d0, r0, r1
   310cc: e5950034     	ldr	r0, [r5, #0x34]
   310d0: ed9f1b4a     	vldr	d1, [pc, #296]          @ 0x31200 <.text+0x21100>
   310d4: e28f1f51     	add	r1, pc, #324
   310d8: ee380b00     	vadd.f64	d0, d8, d0
   310dc: eeb50b40     	vcmp.f64	d0, #0
   310e0: eef1fa10     	vmrs	APSR_nzcv, fpscr
   310e4: 0eb00b41     	vmoveq.f64	d0, d1
   310e8: e3500001     	cmp	r0, #1
   310ec: 02811008     	addeq	r1, r1, #8
   310f0: e59f01cc     	ldr	r0, [pc, #0x1cc]        @ 0x312c4 <.text+0x211c4>
   310f4: ed911b00     	vldr	d1, [r1]
   310f8: e79f0000     	ldr	r0, [pc, r0]
   310fc: ee818b00     	vdiv.f64	d8, d1, d0

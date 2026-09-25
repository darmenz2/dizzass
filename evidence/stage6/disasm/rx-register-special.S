
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c4750: e1a0000a     	mov	r0, r10
   c4754: e1a01008     	mov	r1, r8
   c4758: e3a02007     	mov	r2, #7
   c475c: eb0035ef     	bl	0xd1f20 <.text+0xc1e20> @ imm = #0xd7bc
   c4760: e55b1062     	ldrb	r1, [r11, #-0x62]
   c4764: e51b0068     	ldr	r0, [r11, #-0x68]
   c4768: e5192300     	ldr	r2, [r9, #-0x300]
   c476c: e201101f     	and	r1, r1, #31
   c4770: e15b36b4     	ldrh	r3, [r11, #-100]
   c4774: e58d2058     	str	r2, [sp, #0x58]
   c4778: e1cd35bc     	strh	r3, [sp, #92]
   c477c: e1cd16b4     	strh	r1, [sp, #100]
   c4780: e1a01820     	lsr	r1, r0, #16
   c4784: e6bf0f30     	rev	r0, r0
   c4788: e6bf1f31     	rev	r1, r1
   c478c: e7cf001f     	bfc	r0, #0, #16
   c4790: e1800861     	orr	r0, r0, r1, ror #16
   c4794: e58d0060     	str	r0, [sp, #0x60]
   c4798: eb0038b9     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe2e4
   c479c: e59f134c     	ldr	r1, [pc, #0x34c]        @ 0xc4af0 <.text+0xb49f0>
   c47a0: e79f1001     	ldr	r1, [pc, r1]
   c47a4: e5911000     	ldr	r1, [r1]
   c47a8: e2412001     	sub	r2, r1, #1
   c47ac: e0020291     	mul	r2, r1, r2
   c47b0: e55b1063     	ldrb	r1, [r11, #-0x63]
   c47b4: e3120001     	tst	r2, #1
   c47b8: 0a000018     	beq	0xc4820 <.text+0xb4720> @ imm = #0x60
   c47bc: e59f2330     	ldr	r2, [pc, #0x330]        @ 0xc4af4 <.text+0xb49f4>
   c47c0: e79f2002     	ldr	r2, [pc, r2]
   c47c4: e5922000     	ldr	r2, [r2]
   c47c8: e3520009     	cmp	r2, #9
   c47cc: da000013     	ble	0xc4820 <.text+0xb4720> @ imm = #0x4c
   c47d0: e1a0000a     	mov	r0, r10
   c47d4: e1a01008     	mov	r1, r8
   c47d8: e3a02007     	mov	r2, #7
   c47dc: eb0035cf     	bl	0xd1f20 <.text+0xc1e20> @ imm = #0xd73c
   c47e0: e55b1062     	ldrb	r1, [r11, #-0x62]
   c47e4: e51b0068     	ldr	r0, [r11, #-0x68]
   c47e8: e5192300     	ldr	r2, [r9, #-0x300]
   c47ec: e201101f     	and	r1, r1, #31
   c47f0: e15b36b4     	ldrh	r3, [r11, #-100]
   c47f4: e58d2058     	str	r2, [sp, #0x58]
   c47f8: e1cd35bc     	strh	r3, [sp, #92]
   c47fc: e1cd16b4     	strh	r1, [sp, #100]
   c4800: e1a01820     	lsr	r1, r0, #16
   c4804: e6bf0f30     	rev	r0, r0
   c4808: e6bf1f31     	rev	r1, r1
   c480c: e7cf001f     	bfc	r0, #0, #16
   c4810: e1800861     	orr	r0, r0, r1, ror #16
   c4814: e58d0060     	str	r0, [sp, #0x60]
   c4818: eb003899     	bl	0xd2a84 <.text+0xc2984> @ imm = #0xe264
   c481c: eaffffcb     	b	0xc4750 <.text+0xb4650> @ imm = #-0xd4
   c4820: e59fa2d0     	ldr	r10, [pc, #0x2d0]       @ 0xc4af8 <.text+0xb49f8>
   c4824: e1a09005     	mov	r9, r5
   c4828: e1500001     	cmp	r0, r1
   c482c: e79fa00a     	ldr	r10, [pc, r10]
   c4830: e59f52c4     	ldr	r5, [pc, #0x2c4]        @ 0xc4afc <.text+0xb49fc>
   c4834: e79f5005     	ldr	r5, [pc, r5]
   c4838: 0a000001     	beq	0xc4844 <.text+0xb4744> @ imm = #0x4
   c483c: e28d0058     	add	r0, sp, #88
   c4840: eb01103c     	bl	0x108938 <.text+0xf8838> @ imm = #0x440f0

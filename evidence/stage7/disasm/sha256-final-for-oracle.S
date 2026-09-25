
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  10939c: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
  1093a0: e28db01c     	add	r11, sp, #28
  1093a4: e24dd004     	sub	sp, sp, #4
  1093a8: e59f8384     	ldr	r8, [pc, #0x384]        @ 0x109734 <.text+0xf9634>
  1093ac: e1a05000     	mov	r5, r0
  1093b0: e1a04001     	mov	r4, r1
  1093b4: e79f8008     	ldr	r8, [pc, r8]
  1093b8: e5980000     	ldr	r0, [r8]
  1093bc: e2401001     	sub	r1, r0, #1
  1093c0: e0000190     	mul	r0, r0, r1
  1093c4: e3100001     	tst	r0, #1
  1093c8: 0a000004     	beq	0x1093e0 <.text+0xf92e0> @ imm = #0x10
  1093cc: e59f0364     	ldr	r0, [pc, #0x364]        @ 0x109738 <.text+0xf9638>
  1093d0: e79f0000     	ldr	r0, [pc, r0]
  1093d4: e5900000     	ldr	r0, [r0]
  1093d8: e3500009     	cmp	r0, #9
  1093dc: ca00006d     	bgt	0x109598 <.text+0xf9498> @ imm = #0x1b4
  1093e0: e5959004     	ldr	r9, [r5, #0x4]
  1093e4: e3a07001     	mov	r7, #1
  1093e8: e2856008     	add	r6, r5, #8
  1093ec: e595a000     	ldr	r10, [r5]
  1093f0: e2091038     	and	r1, r9, #56
  1093f4: e0860009     	add	r0, r6, r9
  1093f8: e3510038     	cmp	r1, #56
  1093fc: e3a01000     	mov	r1, #0
  109400: 03007002     	movweq	r7, #0x2
  109404: e0692307     	rsb	r2, r9, r7, lsl #6
  109408: eb12681f     	bl	0x5a348c <.text+0x59338c> @ imm = #0x49a07c
  10940c: e5950004     	ldr	r0, [r5, #0x4]
  109410: e3a01080     	mov	r1, #128
  109414: e7c61000     	strb	r1, [r6, r0]
  109418: e08a1009     	add	r1, r10, r9
  10941c: e0860307     	add	r0, r6, r7, lsl #6
  109420: e1a022a1     	lsr	r2, r1, #5
  109424: e5402002     	strb	r2, [r0, #-0x2]
  109428: e1a026a1     	lsr	r2, r1, #13
  10942c: e5402003     	strb	r2, [r0, #-0x3]
  109430: e1a02aa1     	lsr	r2, r1, #21
  109434: e1a01181     	lsl	r1, r1, #3
  109438: e5402004     	strb	r2, [r0, #-0x4]
  10943c: e5401001     	strb	r1, [r0, #-0x1]
  109440: e1a00005     	mov	r0, r5
  109444: e1a01006     	mov	r1, r6
  109448: e1a02007     	mov	r2, r7
  10944c: ebfffdca     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0x8d8
  109450: e5950088     	ldr	r0, [r5, #0x88]
  109454: e5c40003     	strb	r0, [r4, #0x3]
  109458: e5950088     	ldr	r0, [r5, #0x88]
  10945c: e1a00420     	lsr	r0, r0, #8
  109460: e5c40002     	strb	r0, [r4, #0x2]
  109464: e1d508ba     	ldrh	r0, [r5, #138]
  109468: e5c40001     	strb	r0, [r4, #0x1]
  10946c: e5d5008b     	ldrb	r0, [r5, #0x8b]
  109470: e5c40000     	strb	r0, [r4]
  109474: e595008c     	ldr	r0, [r5, #0x8c]
  109478: e5c40007     	strb	r0, [r4, #0x7]
  10947c: e595008c     	ldr	r0, [r5, #0x8c]
  109480: e1a00420     	lsr	r0, r0, #8
  109484: e5c40006     	strb	r0, [r4, #0x6]
  109488: e1d508be     	ldrh	r0, [r5, #142]
  10948c: e5c40005     	strb	r0, [r4, #0x5]
  109490: e5d5008f     	ldrb	r0, [r5, #0x8f]
  109494: e5c40004     	strb	r0, [r4, #0x4]
  109498: e5950090     	ldr	r0, [r5, #0x90]
  10949c: e5c4000b     	strb	r0, [r4, #0xb]
  1094a0: e5950090     	ldr	r0, [r5, #0x90]
  1094a4: e1a00420     	lsr	r0, r0, #8
  1094a8: e5c4000a     	strb	r0, [r4, #0xa]
  1094ac: e1d509b2     	ldrh	r0, [r5, #146]
  1094b0: e5c40009     	strb	r0, [r4, #0x9]
  1094b4: e5d50093     	ldrb	r0, [r5, #0x93]
  1094b8: e5c40008     	strb	r0, [r4, #0x8]
  1094bc: e5950094     	ldr	r0, [r5, #0x94]
  1094c0: e5c4000f     	strb	r0, [r4, #0xf]
  1094c4: e5950094     	ldr	r0, [r5, #0x94]
  1094c8: e1a00420     	lsr	r0, r0, #8
  1094cc: e5c4000e     	strb	r0, [r4, #0xe]
  1094d0: e1d509b6     	ldrh	r0, [r5, #150]
  1094d4: e5c4000d     	strb	r0, [r4, #0xd]
  1094d8: e5d50097     	ldrb	r0, [r5, #0x97]
  1094dc: e5c4000c     	strb	r0, [r4, #0xc]
  1094e0: e5950098     	ldr	r0, [r5, #0x98]
  1094e4: e5c40013     	strb	r0, [r4, #0x13]
  1094e8: e5950098     	ldr	r0, [r5, #0x98]
  1094ec: e1a00420     	lsr	r0, r0, #8
  1094f0: e5c40012     	strb	r0, [r4, #0x12]
  1094f4: e1d509ba     	ldrh	r0, [r5, #154]
  1094f8: e5c40011     	strb	r0, [r4, #0x11]
  1094fc: e5d5009b     	ldrb	r0, [r5, #0x9b]
  109500: e5c40010     	strb	r0, [r4, #0x10]
  109504: e595009c     	ldr	r0, [r5, #0x9c]
  109508: e5c40017     	strb	r0, [r4, #0x17]
  10950c: e595009c     	ldr	r0, [r5, #0x9c]
  109510: e1a00420     	lsr	r0, r0, #8
  109514: e5c40016     	strb	r0, [r4, #0x16]
  109518: e1d509be     	ldrh	r0, [r5, #158]
  10951c: e5c40015     	strb	r0, [r4, #0x15]
  109520: e5d5009f     	ldrb	r0, [r5, #0x9f]
  109524: e5c40014     	strb	r0, [r4, #0x14]
  109528: e59500a0     	ldr	r0, [r5, #0xa0]
  10952c: e5c4001b     	strb	r0, [r4, #0x1b]
  109530: e59500a0     	ldr	r0, [r5, #0xa0]
  109534: e1a00420     	lsr	r0, r0, #8
  109538: e5c4001a     	strb	r0, [r4, #0x1a]
  10953c: e1d50ab2     	ldrh	r0, [r5, #162]
  109540: e5c40019     	strb	r0, [r4, #0x19]
  109544: e5d500a3     	ldrb	r0, [r5, #0xa3]
  109548: e5c40018     	strb	r0, [r4, #0x18]
  10954c: e59500a4     	ldr	r0, [r5, #0xa4]
  109550: e5c4001f     	strb	r0, [r4, #0x1f]
  109554: e59500a4     	ldr	r0, [r5, #0xa4]
  109558: e1a00420     	lsr	r0, r0, #8
  10955c: e5c4001e     	strb	r0, [r4, #0x1e]
  109560: e1d50ab6     	ldrh	r0, [r5, #166]
  109564: e5c4001d     	strb	r0, [r4, #0x1d]
  109568: e5d500a7     	ldrb	r0, [r5, #0xa7]
  10956c: e5c4001c     	strb	r0, [r4, #0x1c]
  109570: e5980000     	ldr	r0, [r8]
  109574: e2401001     	sub	r1, r0, #1
  109578: e0000190     	mul	r0, r0, r1
  10957c: e3100001     	tst	r0, #1
  109580: 0a000069     	beq	0x10972c <.text+0xf962c> @ imm = #0x1a4
  109584: e59f01b0     	ldr	r0, [pc, #0x1b0]        @ 0x10973c <.text+0xf963c>
  109588: e79f0000     	ldr	r0, [pc, r0]
  10958c: e5900000     	ldr	r0, [r0]
  109590: e3500009     	cmp	r0, #9
  109594: da000064     	ble	0x10972c <.text+0xf962c> @ imm = #0x190
  109598: e5956004     	ldr	r6, [r5, #0x4]
  10959c: e3a07001     	mov	r7, #1
  1095a0: e285a008     	add	r10, r5, #8
  1095a4: e5959000     	ldr	r9, [r5]
  1095a8: e2061038     	and	r1, r6, #56
  1095ac: e08a0006     	add	r0, r10, r6
  1095b0: e3510038     	cmp	r1, #56
  1095b4: e3a01000     	mov	r1, #0
  1095b8: 03007002     	movweq	r7, #0x2
  1095bc: e0662307     	rsb	r2, r6, r7, lsl #6
  1095c0: eb1267b1     	bl	0x5a348c <.text+0x59338c> @ imm = #0x499ec4
  1095c4: e5950004     	ldr	r0, [r5, #0x4]
  1095c8: e3a01080     	mov	r1, #128
  1095cc: e7ca1000     	strb	r1, [r10, r0]
  1095d0: e0891006     	add	r1, r9, r6
  1095d4: e08a0307     	add	r0, r10, r7, lsl #6
  1095d8: e1a022a1     	lsr	r2, r1, #5
  1095dc: e5402002     	strb	r2, [r0, #-0x2]
  1095e0: e1a026a1     	lsr	r2, r1, #13
  1095e4: e5402003     	strb	r2, [r0, #-0x3]
  1095e8: e1a02aa1     	lsr	r2, r1, #21
  1095ec: e1a01181     	lsl	r1, r1, #3
  1095f0: e5402004     	strb	r2, [r0, #-0x4]
  1095f4: e5401001     	strb	r1, [r0, #-0x1]
  1095f8: e1a00005     	mov	r0, r5
  1095fc: e1a0100a     	mov	r1, r10
  109600: e1a02007     	mov	r2, r7
  109604: ebfffd5c     	bl	0x108b7c <.text+0xf8a7c> @ imm = #-0xa90
  109608: e5950088     	ldr	r0, [r5, #0x88]
  10960c: e5c40003     	strb	r0, [r4, #0x3]
  109610: e5950088     	ldr	r0, [r5, #0x88]
  109614: e1a00420     	lsr	r0, r0, #8
  109618: e5c40002     	strb	r0, [r4, #0x2]
  10961c: e1d508ba     	ldrh	r0, [r5, #138]
  109620: e5c40001     	strb	r0, [r4, #0x1]
  109624: e5d5008b     	ldrb	r0, [r5, #0x8b]
  109628: e5c40000     	strb	r0, [r4]
  10962c: e595008c     	ldr	r0, [r5, #0x8c]
  109630: e5c40007     	strb	r0, [r4, #0x7]
  109634: e595008c     	ldr	r0, [r5, #0x8c]
  109638: e1a00420     	lsr	r0, r0, #8
  10963c: e5c40006     	strb	r0, [r4, #0x6]
  109640: e1d508be     	ldrh	r0, [r5, #142]
  109644: e5c40005     	strb	r0, [r4, #0x5]
  109648: e5d5008f     	ldrb	r0, [r5, #0x8f]
  10964c: e5c40004     	strb	r0, [r4, #0x4]
  109650: e5950090     	ldr	r0, [r5, #0x90]
  109654: e5c4000b     	strb	r0, [r4, #0xb]
  109658: e5950090     	ldr	r0, [r5, #0x90]
  10965c: e1a00420     	lsr	r0, r0, #8
  109660: e5c4000a     	strb	r0, [r4, #0xa]
  109664: e1d509b2     	ldrh	r0, [r5, #146]
  109668: e5c40009     	strb	r0, [r4, #0x9]
  10966c: e5d50093     	ldrb	r0, [r5, #0x93]
  109670: e5c40008     	strb	r0, [r4, #0x8]
  109674: e5950094     	ldr	r0, [r5, #0x94]
  109678: e5c4000f     	strb	r0, [r4, #0xf]
  10967c: e5950094     	ldr	r0, [r5, #0x94]
  109680: e1a00420     	lsr	r0, r0, #8
  109684: e5c4000e     	strb	r0, [r4, #0xe]
  109688: e1d509b6     	ldrh	r0, [r5, #150]
  10968c: e5c4000d     	strb	r0, [r4, #0xd]
  109690: e5d50097     	ldrb	r0, [r5, #0x97]
  109694: e5c4000c     	strb	r0, [r4, #0xc]
  109698: e5950098     	ldr	r0, [r5, #0x98]
  10969c: e5c40013     	strb	r0, [r4, #0x13]
  1096a0: e5950098     	ldr	r0, [r5, #0x98]
  1096a4: e1a00420     	lsr	r0, r0, #8
  1096a8: e5c40012     	strb	r0, [r4, #0x12]
  1096ac: e1d509ba     	ldrh	r0, [r5, #154]
  1096b0: e5c40011     	strb	r0, [r4, #0x11]
  1096b4: e5d5009b     	ldrb	r0, [r5, #0x9b]
  1096b8: e5c40010     	strb	r0, [r4, #0x10]
  1096bc: e595009c     	ldr	r0, [r5, #0x9c]
  1096c0: e5c40017     	strb	r0, [r4, #0x17]
  1096c4: e595009c     	ldr	r0, [r5, #0x9c]
  1096c8: e1a00420     	lsr	r0, r0, #8
  1096cc: e5c40016     	strb	r0, [r4, #0x16]
  1096d0: e1d509be     	ldrh	r0, [r5, #158]
  1096d4: e5c40015     	strb	r0, [r4, #0x15]
  1096d8: e5d5009f     	ldrb	r0, [r5, #0x9f]
  1096dc: e5c40014     	strb	r0, [r4, #0x14]
  1096e0: e59500a0     	ldr	r0, [r5, #0xa0]
  1096e4: e5c4001b     	strb	r0, [r4, #0x1b]
  1096e8: e59500a0     	ldr	r0, [r5, #0xa0]
  1096ec: e1a00420     	lsr	r0, r0, #8
  1096f0: e5c4001a     	strb	r0, [r4, #0x1a]
  1096f4: e1d50ab2     	ldrh	r0, [r5, #162]
  1096f8: e5c40019     	strb	r0, [r4, #0x19]
  1096fc: e5d500a3     	ldrb	r0, [r5, #0xa3]
  109700: e5c40018     	strb	r0, [r4, #0x18]
  109704: e59500a4     	ldr	r0, [r5, #0xa4]
  109708: e5c4001f     	strb	r0, [r4, #0x1f]
  10970c: e59500a4     	ldr	r0, [r5, #0xa4]
  109710: e1a00420     	lsr	r0, r0, #8
  109714: e5c4001e     	strb	r0, [r4, #0x1e]
  109718: e1d50ab6     	ldrh	r0, [r5, #166]
  10971c: e5c4001d     	strb	r0, [r4, #0x1d]
  109720: e5d500a7     	ldrb	r0, [r5, #0xa7]
  109724: e5c4001c     	strb	r0, [r4, #0x1c]
  109728: eaffff2c     	b	0x1093e0 <.text+0xf92e0> @ imm = #-0x350
  10972c: e24bd01c     	sub	sp, r11, #28
  109730: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
  109734: 004d601c     	subeq	r6, sp, r12, lsl r0
  109738: 004d6660     	subeq	r6, sp, r0, ror #12
  10973c: 004d64a8     	subeq	r6, sp, r8, lsr #9

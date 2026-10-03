# Original ARM code, read as data only; literal pools omitted here.

## index-to-address

reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   53d98: e0000091     	mul	r0, r1, r0
   53d9c: e12fff1e     	bx	lr

## startup-call

reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   56840: e1a00009     	mov	r0, r9
   56844: eb017b47     	bl	0xb5568 <.text+0xa5468> @ imm = #0x5ed1c

## board-accessor

reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   a720c: e3500000     	cmp	r0, #0
   a7210: 12800038     	addne	r0, r0, #56
   a7214: e12fff1e     	bx	lr

## caller

reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   b5568: e92d4ff0     	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
   b556c: e28db01c     	add	r11, sp, #28
   b5570: e24dd00c     	sub	sp, sp, #12
   b5574: e59f9360     	ldr	r9, [pc, #0x360]        @ 0xb58dc <.text+0xa57dc>
   b5578: e1a07000     	mov	r7, r0
   b557c: e79f9009     	ldr	r9, [pc, r9]
   b5580: e5990000     	ldr	r0, [r9]
   b5584: e59fa354     	ldr	r10, [pc, #0x354]       @ 0xb58e0 <.text+0xa57e0>
   b5588: e2401001     	sub	r1, r0, #1
   b558c: e0000190     	mul	r0, r0, r1
   b5590: e79fa00a     	ldr	r10, [pc, r10]
   b5594: e3100001     	tst	r0, #1
   b5598: 0a000002     	beq	0xb55a8 <.text+0xa54a8> @ imm = #0x8
   b559c: e59a0000     	ldr	r0, [r10]
   b55a0: e3500009     	cmp	r0, #9
   b55a4: ca000011     	bgt	0xb55f0 <.text+0xa54f0> @ imm = #0x44
   b55a8: e24d4008     	sub	r4, sp, #8
   b55ac: e1a0d004     	mov	sp, r4
   b55b0: e24d5008     	sub	r5, sp, #8
   b55b4: e1a0d005     	mov	sp, r5
   b55b8: e597001c     	ldr	r0, [r7, #0x1c]
   b55bc: e5900018     	ldr	r0, [r0, #0x18]
   b55c0: ebffc711     	bl	0xa720c <.text+0x9710c> @ imm = #-0xe3bc
   b55c4: e1a06000     	mov	r6, r0
   b55c8: e5990000     	ldr	r0, [r9]
   b55cc: e5d62030     	ldrb	r2, [r6, #0x30]
   b55d0: e2401001     	sub	r1, r0, #1
   b55d4: e597801c     	ldr	r8, [r7, #0x1c]
   b55d8: e0010190     	mul	r1, r0, r1
   b55dc: e3110001     	tst	r1, #1
   b55e0: 0a000008     	beq	0xb5608 <.text+0xa5508> @ imm = #0x20
   b55e4: e59a1000     	ldr	r1, [r10]
   b55e8: e3510009     	cmp	r1, #9
   b55ec: da000005     	ble	0xb5608 <.text+0xa5508> @ imm = #0x14
   b55f0: e24dd008     	sub	sp, sp, #8
   b55f4: e24dd008     	sub	sp, sp, #8
   b55f8: e597001c     	ldr	r0, [r7, #0x1c]
   b55fc: e5900018     	ldr	r0, [r0, #0x18]
   b5600: ebffc701     	bl	0xa720c <.text+0x9710c> @ imm = #-0xe3fc
   b5604: eaffffe7     	b	0xb55a8 <.text+0xa54a8> @ imm = #-0x64
   b5608: e3a00000     	mov	r0, #0
   b560c: e3520000     	cmp	r2, #0
   b5610: 0a0000a3     	beq	0xb58a4 <.text+0xa57a4> @ imm = #0x28c
   b5614: eb012264     	bl	0xfdfac <.text+0xedeac> @ imm = #0x48990
   b5618: e3500004     	cmp	r0, #4
   b561c: 0a00009f     	beq	0xb58a0 <.text+0xa57a0> @ imm = #0x27c
   b5620: e5960018     	ldr	r0, [r6, #0x18]
   b5624: e350000a     	cmp	r0, #10
   b5628: ba00009c     	blt	0xb58a0 <.text+0xa57a0> @ imm = #0x270
   b562c: e5991000     	ldr	r1, [r9]
   b5630: e2412001     	sub	r2, r1, #1
   b5634: e0010291     	mul	r1, r1, r2
   b5638: e3110001     	tst	r1, #1
   b563c: e5991000     	ldr	r1, [r9]
   b5640: e2412001     	sub	r2, r1, #1
   b5644: e0020291     	mul	r2, r1, r2
   b5648: e5961034     	ldr	r1, [r6, #0x34]
   b564c: e3120001     	tst	r2, #1
   b5650: 0a000002     	beq	0xb5660 <.text+0xa5560> @ imm = #0x8
   b5654: e59a2000     	ldr	r2, [r10]
   b5658: e3520009     	cmp	r2, #9
   b565c: cafffff6     	bgt	0xb563c <.text+0xa553c> @ imm = #-0x28
   b5660: e0500001     	subs	r0, r0, r1
   b5664: e50b0024     	str	r0, [r11, #-0x24]
   b5668: e3a00000     	mov	r0, #0
   b566c: 4a00008c     	bmi	0xb58a4 <.text+0xa57a4> @ imm = #0x230
   b5670: e2870fae     	add	r0, r7, #696
   b5674: e50b0028     	str	r0, [r11, #-0x28]
   b5678: ea000005     	b	0xb5694 <.text+0xa5594> @ imm = #0x14
   b567c: e51b1024     	ldr	r1, [r11, #-0x24]
   b5680: e0411000     	sub	r1, r1, r0
   b5684: e50b1024     	str	r1, [r11, #-0x24]
   b5688: e3710001     	cmn	r1, #1
   b568c: e1a00001     	mov	r0, r1
   b5690: da000082     	ble	0xb58a0 <.text+0xa57a0> @ imm = #0x208
   b5694: e5d60038     	ldrb	r0, [r6, #0x38]
   b5698: e3500000     	cmp	r0, #0
   b569c: 0a000012     	beq	0xb56ec <.text+0xa55ec> @ imm = #0x48
   b56a0: e5990000     	ldr	r0, [r9]
   b56a4: e2401001     	sub	r1, r0, #1
   b56a8: e0000190     	mul	r0, r0, r1
   b56ac: e3100001     	tst	r0, #1
   b56b0: e5961018     	ldr	r1, [r6, #0x18]
   b56b4: e51b3024     	ldr	r3, [r11, #-0x24]
   b56b8: e5960014     	ldr	r0, [r6, #0x14]
   b56bc: e0411003     	sub	r1, r1, r3
   b56c0: e5992000     	ldr	r2, [r9]
   b56c4: e0000091     	mul	r0, r1, r0
   b56c8: e2421001     	sub	r1, r2, #1
   b56cc: e0010192     	mul	r1, r2, r1
   b56d0: e280700e     	add	r7, r0, #14
   b56d4: e3110001     	tst	r1, #1
   b56d8: 0a000004     	beq	0xb56f0 <.text+0xa55f0> @ imm = #0x10
   b56dc: e59a0000     	ldr	r0, [r10]
   b56e0: e3500009     	cmp	r0, #9
   b56e4: cafffff1     	bgt	0xb56b0 <.text+0xa55b0> @ imm = #-0x3c
   b56e8: ea000000     	b	0xb56f0 <.text+0xa55f0> @ imm = #0x0
   b56ec: e3a07000     	mov	r7, #0
   b56f0: e5d60039     	ldrb	r0, [r6, #0x39]
   b56f4: e3500000     	cmp	r0, #0
   b56f8: 0a00002a     	beq	0xb57a8 <.text+0xa56a8> @ imm = #0xa8
   b56fc: e5990000     	ldr	r0, [r9]
   b5700: e2401001     	sub	r1, r0, #1
   b5704: e0000190     	mul	r0, r0, r1
   b5708: e3100001     	tst	r0, #1
   b570c: 0a000002     	beq	0xb571c <.text+0xa561c> @ imm = #0x8
   b5710: e59a0000     	ldr	r0, [r10]
   b5714: e3500009     	cmp	r0, #9
   b5718: ca000013     	bgt	0xb576c <.text+0xa566c> @ imm = #0x4c
   b571c: e5960014     	ldr	r0, [r6, #0x14]
   b5720: e51b1024     	ldr	r1, [r11, #-0x24]
   b5724: e0000190     	mul	r0, r0, r1
   b5728: e5840000     	str	r0, [r4]
   b572c: e5961000     	ldr	r1, [r6]
   b5730: ebfe7998     	bl	0x53d98 <.text+0x43c98> @ imm = #-0x619a0
   b5734: e5840004     	str	r0, [r4, #0x4]
   b5738: e1a01004     	mov	r1, r4
   b573c: e59831c0     	ldr	r3, [r8, #0x1c0]
   b5740: e1a02007     	mov	r2, r7
   b5744: e51b0028     	ldr	r0, [r11, #-0x28]
   b5748: e12fff33     	blx	r3
   b574c: e5991000     	ldr	r1, [r9]
   b5750: e2412001     	sub	r2, r1, #1
   b5754: e0010291     	mul	r1, r1, r2
   b5758: e3110001     	tst	r1, #1
   b575c: 0a00000f     	beq	0xb57a0 <.text+0xa56a0> @ imm = #0x3c
   b5760: e59a1000     	ldr	r1, [r10]
   b5764: e3510009     	cmp	r1, #9
   b5768: da00000c     	ble	0xb57a0 <.text+0xa56a0> @ imm = #0x30
   b576c: e5960014     	ldr	r0, [r6, #0x14]
   b5770: e51b1024     	ldr	r1, [r11, #-0x24]
   b5774: e0000190     	mul	r0, r0, r1
   b5778: e5840000     	str	r0, [r4]
   b577c: e5961000     	ldr	r1, [r6]
   b5780: ebfe7984     	bl	0x53d98 <.text+0x43c98> @ imm = #-0x619f0
   b5784: e5840004     	str	r0, [r4, #0x4]
   b5788: e1a01004     	mov	r1, r4
   b578c: e59831c0     	ldr	r3, [r8, #0x1c0]
   b5790: e1a02007     	mov	r2, r7
   b5794: e51b0028     	ldr	r0, [r11, #-0x28]
   b5798: e12fff33     	blx	r3
   b579c: eaffffde     	b	0xb571c <.text+0xa561c> @ imm = #-0x88
   b57a0: e3500000     	cmp	r0, #0
   b57a4: 1a000048     	bne	0xb58cc <.text+0xa57cc> @ imm = #0x120
   b57a8: e5d6003a     	ldrb	r0, [r6, #0x3a]
   b57ac: e3500000     	cmp	r0, #0
   b57b0: 0a00002c     	beq	0xb5868 <.text+0xa5768> @ imm = #0xb0
   b57b4: e5990000     	ldr	r0, [r9]
   b57b8: e2401001     	sub	r1, r0, #1
   b57bc: e0000190     	mul	r0, r0, r1
   b57c0: e3100001     	tst	r0, #1
   b57c4: 0a000002     	beq	0xb57d4 <.text+0xa56d4> @ imm = #0x8
   b57c8: e59a0000     	ldr	r0, [r10]
   b57cc: e3500009     	cmp	r0, #9
   b57d0: ca000014     	bgt	0xb5828 <.text+0xa5728> @ imm = #0x50
   b57d4: e5960014     	ldr	r0, [r6, #0x14]
   b57d8: e51b1024     	ldr	r1, [r11, #-0x24]
   b57dc: e0200190     	mla	r0, r0, r1, r0
   b57e0: e2400001     	sub	r0, r0, #1
   b57e4: e5850000     	str	r0, [r5]
   b57e8: e5961000     	ldr	r1, [r6]
   b57ec: ebfe7969     	bl	0x53d98 <.text+0x43c98> @ imm = #-0x61a5c
   b57f0: e5850004     	str	r0, [r5, #0x4]
   b57f4: e1a01005     	mov	r1, r5
   b57f8: e59831c0     	ldr	r3, [r8, #0x1c0]
   b57fc: e1a02007     	mov	r2, r7
   b5800: e51b0028     	ldr	r0, [r11, #-0x28]
   b5804: e12fff33     	blx	r3
   b5808: e5991000     	ldr	r1, [r9]
   b580c: e2412001     	sub	r2, r1, #1
   b5810: e0010291     	mul	r1, r1, r2
   b5814: e3110001     	tst	r1, #1
   b5818: 0a000010     	beq	0xb5860 <.text+0xa5760> @ imm = #0x40
   b581c: e59a1000     	ldr	r1, [r10]
   b5820: e3510009     	cmp	r1, #9
   b5824: da00000d     	ble	0xb5860 <.text+0xa5760> @ imm = #0x34
   b5828: e5960014     	ldr	r0, [r6, #0x14]
   b582c: e51b1024     	ldr	r1, [r11, #-0x24]
   b5830: e0200190     	mla	r0, r0, r1, r0
   b5834: e2400001     	sub	r0, r0, #1
   b5838: e5850000     	str	r0, [r5]
   b583c: e5961000     	ldr	r1, [r6]
   b5840: ebfe7954     	bl	0x53d98 <.text+0x43c98> @ imm = #-0x61ab0
   b5844: e5850004     	str	r0, [r5, #0x4]
   b5848: e1a01005     	mov	r1, r5
   b584c: e59831c0     	ldr	r3, [r8, #0x1c0]
   b5850: e1a02007     	mov	r2, r7
   b5854: e51b0028     	ldr	r0, [r11, #-0x28]
   b5858: e12fff33     	blx	r3
   b585c: eaffffdc     	b	0xb57d4 <.text+0xa56d4> @ imm = #-0x90
   b5860: e3500000     	cmp	r0, #0
   b5864: 1a00001a     	bne	0xb58d4 <.text+0xa57d4> @ imm = #0x68
   b5868: e5990000     	ldr	r0, [r9]
   b586c: e2401001     	sub	r1, r0, #1
   b5870: e0000190     	mul	r0, r0, r1
   b5874: e3100001     	tst	r0, #1
   b5878: e5990000     	ldr	r0, [r9]
   b587c: e2401001     	sub	r1, r0, #1
   b5880: e0010190     	mul	r1, r0, r1
   b5884: e5960034     	ldr	r0, [r6, #0x34]
   b5888: e3110001     	tst	r1, #1
   b588c: 0affff7a     	beq	0xb567c <.text+0xa557c> @ imm = #-0x218
   b5890: e59a1000     	ldr	r1, [r10]
   b5894: e3510009     	cmp	r1, #9
   b5898: cafffff6     	bgt	0xb5878 <.text+0xa5778> @ imm = #-0x28
   b589c: eaffff76     	b	0xb567c <.text+0xa557c> @ imm = #-0x228
   b58a0: e3a00000     	mov	r0, #0
   b58a4: e5992000     	ldr	r2, [r9]
   b58a8: e2421001     	sub	r1, r2, #1
   b58ac: e0010192     	mul	r1, r2, r1
   b58b0: e3110001     	tst	r1, #1
   b58b4: 0a000002     	beq	0xb58c4 <.text+0xa57c4> @ imm = #0x8
   b58b8: e59a1000     	ldr	r1, [r10]
   b58bc: e3510009     	cmp	r1, #9
   b58c0: cafffff7     	bgt	0xb58a4 <.text+0xa57a4> @ imm = #-0x24
   b58c4: e24bd01c     	sub	sp, r11, #28
   b58c8: e8bd8ff0     	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
   b58cc: e3e00000     	mvn	r0, #0
   b58d0: eafffff3     	b	0xb58a4 <.text+0xa57a4> @ imm = #-0x34
   b58d4: e3e00000     	mvn	r0, #0
   b58d8: eafffff1     	b	0xb58a4 <.text+0xa57a4> @ imm = #-0x3c

## method

reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   e4690: e92d4bf0     	push	{r4, r5, r6, r7, r8, r9, r11, lr}
   e4694: e28db018     	add	r11, sp, #24
   e4698: e24dd010     	sub	sp, sp, #16
   e469c: e59f80fc     	ldr	r8, [pc, #0xfc]         @ 0xe47a0 <.text+0xd46a0>
   e46a0: e1a05000     	mov	r5, r0
   e46a4: e1a04001     	mov	r4, r1
   e46a8: e1a06002     	mov	r6, r2
   e46ac: e79f8008     	ldr	r8, [pc, r8]
   e46b0: e5980000     	ldr	r0, [r8]
   e46b4: e59f90e8     	ldr	r9, [pc, #0xe8]         @ 0xe47a4 <.text+0xd46a4>
   e46b8: e2401001     	sub	r1, r0, #1
   e46bc: e0000190     	mul	r0, r0, r1
   e46c0: e79f9009     	ldr	r9, [pc, r9]
   e46c4: e3100001     	tst	r0, #1
   e46c8: 0a000002     	beq	0xe46d8 <.text+0xd45d8> @ imm = #0x8
   e46cc: e5990000     	ldr	r0, [r9]
   e46d0: e3500009     	cmp	r0, #9
   e46d4: ca000010     	bgt	0xe471c <.text+0xd461c> @ imm = #0x40
   e46d8: e3a00003     	mov	r0, #3
   e46dc: e3a01000     	mov	r1, #0
   e46e0: e1800806     	orr	r0, r0, r6, lsl #16
   e46e4: e58d0000     	str	r0, [sp]
   e46e8: e1a00005     	mov	r0, r5
   e46ec: e1a02004     	mov	r2, r4
   e46f0: e3a0302c     	mov	r3, #44
   e46f4: e3a07000     	mov	r7, #0
   e46f8: eb0000dd     	bl	0xe4a74 <.text+0xd4974> @ imm = #0x374
   e46fc: e5981000     	ldr	r1, [r8]
   e4700: e2412001     	sub	r2, r1, #1
   e4704: e0010291     	mul	r1, r1, r2
   e4708: e3110001     	tst	r1, #1
   e470c: 0a00000b     	beq	0xe4740 <.text+0xd4640> @ imm = #0x2c
   e4710: e5991000     	ldr	r1, [r9]
   e4714: e3510009     	cmp	r1, #9
   e4718: da000008     	ble	0xe4740 <.text+0xd4640> @ imm = #0x20
   e471c: e3a00003     	mov	r0, #3
   e4720: e3a01000     	mov	r1, #0
   e4724: e1800806     	orr	r0, r0, r6, lsl #16
   e4728: e58d0000     	str	r0, [sp]
   e472c: e1a00005     	mov	r0, r5
   e4730: e1a02004     	mov	r2, r4
   e4734: e3a0302c     	mov	r3, #44
   e4738: eb0000cd     	bl	0xe4a74 <.text+0xd4974> @ imm = #0x334
   e473c: eaffffe5     	b	0xe46d8 <.text+0xd45d8> @ imm = #-0x6c
   e4740: e3500000     	cmp	r0, #0
   e4744: 0a000012     	beq	0xe4794 <.text+0xd4694> @ imm = #0x48
   e4748: e59f0058     	ldr	r0, [pc, #0x58]         @ 0xe47a8 <.text+0xd46a8>
   e474c: e59f1058     	ldr	r1, [pc, #0x58]         @ 0xe47ac <.text+0xd46ac>
   e4750: e59f2058     	ldr	r2, [pc, #0x58]         @ 0xe47b0 <.text+0xd46b0>
   e4754: e08f0000     	add	r0, pc, r0
   e4758: e5953018     	ldr	r3, [r5, #0x18]
   e475c: e08f1001     	add	r1, pc, r1
   e4760: e5947000     	ldr	r7, [r4]
   e4764: e08f2002     	add	r2, pc, r2
   e4768: e59f6044     	ldr	r6, [pc, #0x44]         @ 0xe47b4 <.text+0xd46b4>
   e476c: e2833001     	add	r3, r3, #1
   e4770: e3a05001     	mov	r5, #1
   e4774: e2877001     	add	r7, r7, #1
   e4778: e08f6006     	add	r6, pc, r6
   e477c: e88d0060     	stm	sp, {r5, r6}
   e4780: e58d3008     	str	r3, [sp, #0x8]
   e4784: e30032d1     	movw	r3, #0x2d1
   e4788: e58d700c     	str	r7, [sp, #0xc]
   e478c: eb00564c     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x15930
   e4790: e3e07000     	mvn	r7, #0
   e4794: e1a00007     	mov	r0, r7
   e4798: e24bd018     	sub	sp, r11, #24
   e479c: e8bd8bf0     	pop	{r4, r5, r6, r7, r8, r9, r11, pc}

## format-init

reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   e5a6c: e3a02000     	mov	r2, #0
   e5a70: e3520000     	cmp	r2, #0
   e5a74: 1a000007     	bne	0xe5a98 <.text+0xd5998> @ imm = #0x1c
   e5a78: e59f3620     	ldr	r3, [pc, #0x620]        @ 0xe60a0 <.text+0xd5fa0>
   e5a7c: e08f3003     	add	r3, pc, r3
   e5a80: e7d30002     	ldrb	r0, [r3, r2]
   e5a84: e2200091     	eor	r0, r0, #145
   e5a88: e7c30002     	strb	r0, [r3, r2]
   e5a8c: e2822001     	add	r2, r2, #1
   e5a90: e352002f     	cmp	r2, #47
   e5a94: 1afffff9     	bne	0xe5a80 <.text+0xd5980> @ imm = #-0x1c

## selector

reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fdfac: e59f0004     	ldr	r0, [pc, #0x4]          @ 0xfdfb8 <.text+0xedeb8>
   fdfb0: e79f0000     	ldr	r0, [pc, r0]
   fdfb4: e12fff1e     	bx	lr

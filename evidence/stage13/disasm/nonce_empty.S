
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   fa7b4: e92d48f0     	push	{r4, r5, r6, r7, r11, lr}
   fa7b8: e28db010     	add	r11, sp, #16
   fa7bc: e59f60a0     	ldr	r6, [pc, #0xa0]         @ 0xfa864 <.text+0xea764>
   fa7c0: e79f6006     	ldr	r6, [pc, r6]
   fa7c4: e5960000     	ldr	r0, [r6]
   fa7c8: e59f7098     	ldr	r7, [pc, #0x98]         @ 0xfa868 <.text+0xea768>
   fa7cc: e2401001     	sub	r1, r0, #1
   fa7d0: e0000190     	mul	r0, r0, r1
   fa7d4: e79f7007     	ldr	r7, [pc, r7]
   fa7d8: e3100001     	tst	r0, #1
   fa7dc: 0a000002     	beq	0xfa7ec <.text+0xea6ec> @ imm = #0x8
   fa7e0: e5970000     	ldr	r0, [r7]
   fa7e4: e3500009     	cmp	r0, #9
   fa7e8: ca000011     	bgt	0xfa834 <.text+0xea734> @ imm = #0x44
   fa7ec: e59f5078     	ldr	r5, [pc, #0x78]         @ 0xfa86c <.text+0xea76c>
   fa7f0: e08f5005     	add	r5, pc, r5
   fa7f4: e1a00005     	mov	r0, r5
   fa7f8: eb12ae42     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4ab908
   fa7fc: e59f006c     	ldr	r0, [pc, #0x6c]         @ 0xfa870 <.text+0xea770>
   fa800: e08f0000     	add	r0, pc, r0
   fa804: ebff5d75     	bl	0xd1de0 <.text+0xc1ce0> @ imm = #-0x28a2c
   fa808: e1a04000     	mov	r4, r0
   fa80c: e1a00005     	mov	r0, r5
   fa810: eb12afab     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4abeac
   fa814: e5960000     	ldr	r0, [r6]
   fa818: e2401001     	sub	r1, r0, #1
   fa81c: e0000190     	mul	r0, r0, r1
   fa820: e3100001     	tst	r0, #1
   fa824: 0a00000c     	beq	0xfa85c <.text+0xea75c> @ imm = #0x30
   fa828: e5970000     	ldr	r0, [r7]
   fa82c: e3500009     	cmp	r0, #9
   fa830: da000009     	ble	0xfa85c <.text+0xea75c> @ imm = #0x24
   fa834: e59f4038     	ldr	r4, [pc, #0x38]         @ 0xfa874 <.text+0xea774>
   fa838: e08f4004     	add	r4, pc, r4
   fa83c: e1a00004     	mov	r0, r4
   fa840: eb12ae30     	bl	0x5a6108 <.text+0x596008> @ imm = #0x4ab8c0
   fa844: e59f002c     	ldr	r0, [pc, #0x2c]         @ 0xfa878 <.text+0xea778>
   fa848: e08f0000     	add	r0, pc, r0
   fa84c: ebff5d63     	bl	0xd1de0 <.text+0xc1ce0> @ imm = #-0x28a74
   fa850: e1a00004     	mov	r0, r4
   fa854: eb12af9a     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4abe68
   fa858: eaffffe3     	b	0xfa7ec <.text+0xea6ec> @ imm = #-0x74
   fa85c: e1a00004     	mov	r0, r4
   fa860: e8bd88f0     	pop	{r4, r5, r6, r7, r11, pc}
   fa864: 004e3e84     	subeq	r3, lr, r4, lsl #29
   fa868: 004e45a4     	subeq	r4, lr, r4, lsr #11
   fa86c: 0055a2d8     	ldrsbeq	r10, [r5], #-40
   fa870: 0055a2e0     	subseq	r10, r5, r0, ror #5
   fa874: 0055a290     	<unknown>
   fa878: 0055a298     	<unknown>

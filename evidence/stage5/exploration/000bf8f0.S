
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   bf8f0: e92d4bf0     	push	{r4, r5, r6, r7, r8, r9, r11, lr}
   bf8f4: e28db018     	add	r11, sp, #24
   bf8f8: e24dd010     	sub	sp, sp, #16
   bf8fc: e1a05000     	mov	r5, r0
   bf900: eb00fb58     	bl	0xfe668 <.text+0xee568> @ imm = #0x3ed60
   bf904: e59f8248     	ldr	r8, [pc, #0x248]        @ 0xbfb54 <.text+0xafa54>
   bf908: e3a02000     	mov	r2, #0
   bf90c: e79f8008     	ldr	r8, [pc, r8]
   bf910: e5954018     	ldr	r4, [r5, #0x18]
   bf914: e5981000     	ldr	r1, [r8]
   bf918: e59f9238     	ldr	r9, [pc, #0x238]        @ 0xbfb58 <.text+0xafa58>
   bf91c: e79f9009     	ldr	r9, [pc, r9]
   bf920: e5993000     	ldr	r3, [r9]
   bf924: e353000a     	cmp	r3, #10
   bf928: b3002001     	movwlt	r2, #0x1
   bf92c: e3540000     	cmp	r4, #0
   bf930: 4a000016     	bmi	0xbf990 <.text+0xaf890> @ imm = #0x58
   bf934: e1540000     	cmp	r4, r0
   bf938: aa000014     	bge	0xbf990 <.text+0xaf890> @ imm = #0x50
   bf93c: e5980000     	ldr	r0, [r8]
   bf940: e2401001     	sub	r1, r0, #1
   bf944: e0010190     	mul	r1, r0, r1
   bf948: e5d50318     	ldrb	r0, [r5, #0x318]
   bf94c: e3110001     	tst	r1, #1
   bf950: 0a000002     	beq	0xbf960 <.text+0xaf860> @ imm = #0x8
   bf954: e5991000     	ldr	r1, [r9]
   bf958: e3510009     	cmp	r1, #9
   bf95c: cafffff6     	bgt	0xbf93c <.text+0xaf83c> @ imm = #-0x28
   bf960: e3a06000     	mov	r6, #0
   bf964: e3500000     	cmp	r0, #0
   bf968: 1a000076     	bne	0xbfb48 <.text+0xafa48> @ imm = #0x1d8
   bf96c: e5980000     	ldr	r0, [r8]
   bf970: e2401001     	sub	r1, r0, #1
   bf974: e0000190     	mul	r0, r0, r1
   bf978: e3100001     	tst	r0, #1
   bf97c: 0a00002f     	beq	0xbfa40 <.text+0xaf940> @ imm = #0xbc
   bf980: e5990000     	ldr	r0, [r9]
   bf984: e3500009     	cmp	r0, #9
   bf988: ca00003c     	bgt	0xbfa80 <.text+0xaf980> @ imm = #0xf0
   bf98c: ea00002b     	b	0xbfa40 <.text+0xaf940> @ imm = #0xac
   bf990: e2410001     	sub	r0, r1, #1
   bf994: e59f51c0     	ldr	r5, [pc, #0x1c0]        @ 0xbfb5c <.text+0xafa5c>
   bf998: e0000091     	mul	r0, r1, r0
   bf99c: e3a01001     	mov	r1, #1
   bf9a0: e08f5005     	add	r5, pc, r5
   bf9a4: e1c10000     	bic	r0, r1, r0
   bf9a8: e1900002     	orrs	r0, r0, r2
   bf9ac: 0a000015     	beq	0xbfa08 <.text+0xaf908> @ imm = #0x54
   bf9b0: e59f01a8     	ldr	r0, [pc, #0x1a8]        @ 0xbfb60 <.text+0xafa60>
   bf9b4: e2843001     	add	r3, r4, #1
   bf9b8: e59f11a4     	ldr	r1, [pc, #0x1a4]        @ 0xbfb64 <.text+0xafa64>
   bf9bc: e3a07001     	mov	r7, #1
   bf9c0: e59f21a0     	ldr	r2, [pc, #0x1a0]        @ 0xbfb68 <.text+0xafa68>
   bf9c4: e08f0000     	add	r0, pc, r0
   bf9c8: e08f1001     	add	r1, pc, r1
   bf9cc: e58d3008     	str	r3, [sp, #0x8]
   bf9d0: e08f2002     	add	r2, pc, r2
   bf9d4: e3a03e1d     	mov	r3, #464
   bf9d8: e58d7000     	str	r7, [sp]
   bf9dc: e58d5004     	str	r5, [sp, #0x4]
   bf9e0: eb00e9b7     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x3a6dc
   bf9e4: e5980000     	ldr	r0, [r8]
   bf9e8: e3e06000     	mvn	r6, #0
   bf9ec: e2401001     	sub	r1, r0, #1
   bf9f0: e0000190     	mul	r0, r0, r1
   bf9f4: e3100001     	tst	r0, #1
   bf9f8: 0a000052     	beq	0xbfb48 <.text+0xafa48> @ imm = #0x148
   bf9fc: e5990000     	ldr	r0, [r9]
   bfa00: e350000a     	cmp	r0, #10
   bfa04: ba00004f     	blt	0xbfb48 <.text+0xafa48> @ imm = #0x13c
   bfa08: e59f015c     	ldr	r0, [pc, #0x15c]        @ 0xbfb6c <.text+0xafa6c>
   bfa0c: e2843001     	add	r3, r4, #1
   bfa10: e59f1158     	ldr	r1, [pc, #0x158]        @ 0xbfb70 <.text+0xafa70>
   bfa14: e3a07001     	mov	r7, #1
   bfa18: e59f2154     	ldr	r2, [pc, #0x154]        @ 0xbfb74 <.text+0xafa74>
   bfa1c: e08f0000     	add	r0, pc, r0
   bfa20: e08f1001     	add	r1, pc, r1
   bfa24: e58d3008     	str	r3, [sp, #0x8]
   bfa28: e08f2002     	add	r2, pc, r2
   bfa2c: e3a03e1d     	mov	r3, #464
   bfa30: e58d7000     	str	r7, [sp]
   bfa34: e58d5004     	str	r5, [sp, #0x4]
   bfa38: eb00e9a1     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x3a684
   bfa3c: eaffffdb     	b	0xbf9b0 <.text+0xaf8b0> @ imm = #-0x94
   bfa40: e1a00004     	mov	r0, r4
   bfa44: eb00fd3c     	bl	0xfef3c <.text+0xeee3c> @ imm = #0x3f4f0
   bfa48: e1a07000     	mov	r7, r0
   bfa4c: e5950018     	ldr	r0, [r5, #0x18]
   bfa50: e58502d0     	str	r0, [r5, #0x2d0]
   bfa54: e2850fae     	add	r0, r5, #696
   bfa58: e1a01007     	mov	r1, r7
   bfa5c: eb00fcfa     	bl	0xfee4c <.text+0xeed4c> @ imm = #0x3f3e8
   bfa60: e5981000     	ldr	r1, [r8]
   bfa64: e2412001     	sub	r2, r1, #1
   bfa68: e0010291     	mul	r1, r1, r2
   bfa6c: e3110001     	tst	r1, #1
   bfa70: 0a00000a     	beq	0xbfaa0 <.text+0xaf9a0> @ imm = #0x28
   bfa74: e5991000     	ldr	r1, [r9]
   bfa78: e3510009     	cmp	r1, #9
   bfa7c: da000007     	ble	0xbfaa0 <.text+0xaf9a0> @ imm = #0x1c
   bfa80: e1a00004     	mov	r0, r4
   bfa84: eb00fd2c     	bl	0xfef3c <.text+0xeee3c> @ imm = #0x3f4b0
   bfa88: e1a01000     	mov	r1, r0
   bfa8c: e5950018     	ldr	r0, [r5, #0x18]
   bfa90: e58502d0     	str	r0, [r5, #0x2d0]
   bfa94: e2850fae     	add	r0, r5, #696
   bfa98: eb00fceb     	bl	0xfee4c <.text+0xeed4c> @ imm = #0x3f3ac
   bfa9c: eaffffe7     	b	0xbfa40 <.text+0xaf940> @ imm = #-0x64
   bfaa0: e3500000     	cmp	r0, #0
   bfaa4: 0a000027     	beq	0xbfb48 <.text+0xafa48> @ imm = #0x9c
   bfaa8: e5980000     	ldr	r0, [r8]
   bfaac: e59f40c4     	ldr	r4, [pc, #0xc4]         @ 0xbfb78 <.text+0xafa78>
   bfab0: e2401001     	sub	r1, r0, #1
   bfab4: e08f4004     	add	r4, pc, r4
   bfab8: e0000190     	mul	r0, r0, r1
   bfabc: e3100001     	tst	r0, #1
   bfac0: 0a000002     	beq	0xbfad0 <.text+0xaf9d0> @ imm = #0x8
   bfac4: e5990000     	ldr	r0, [r9]
   bfac8: e3500009     	cmp	r0, #9
   bfacc: ca000012     	bgt	0xbfb1c <.text+0xafa1c> @ imm = #0x48
   bfad0: e59f00a4     	ldr	r0, [pc, #0xa4]         @ 0xbfb7c <.text+0xafa7c>
   bfad4: e3a03001     	mov	r3, #1
   bfad8: e59f10a0     	ldr	r1, [pc, #0xa0]         @ 0xbfb80 <.text+0xafa80>
   bfadc: e59f20a0     	ldr	r2, [pc, #0xa0]         @ 0xbfb84 <.text+0xafa84>
   bfae0: e08f0000     	add	r0, pc, r0
   bfae4: e08f1001     	add	r1, pc, r1
   bfae8: e88d0098     	stm	sp, {r3, r4, r7}
   bfaec: e08f2002     	add	r2, pc, r2
   bfaf0: e30031dd     	movw	r3, #0x1dd
   bfaf4: eb00e972     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x3a5c8
   bfaf8: e5980000     	ldr	r0, [r8]
   bfafc: e3e06000     	mvn	r6, #0
   bfb00: e2401001     	sub	r1, r0, #1
   bfb04: e0000190     	mul	r0, r0, r1
   bfb08: e3100001     	tst	r0, #1
   bfb0c: 0a00000d     	beq	0xbfb48 <.text+0xafa48> @ imm = #0x34
   bfb10: e5990000     	ldr	r0, [r9]
   bfb14: e3500009     	cmp	r0, #9
   bfb18: da00000a     	ble	0xbfb48 <.text+0xafa48> @ imm = #0x28
   bfb1c: e59f0064     	ldr	r0, [pc, #0x64]         @ 0xbfb88 <.text+0xafa88>
   bfb20: e3a03001     	mov	r3, #1
   bfb24: e59f1060     	ldr	r1, [pc, #0x60]         @ 0xbfb8c <.text+0xafa8c>
   bfb28: e59f2060     	ldr	r2, [pc, #0x60]         @ 0xbfb90 <.text+0xafa90>
   bfb2c: e08f0000     	add	r0, pc, r0
   bfb30: e08f1001     	add	r1, pc, r1
   bfb34: e88d0098     	stm	sp, {r3, r4, r7}
   bfb38: e08f2002     	add	r2, pc, r2
   bfb3c: e30031dd     	movw	r3, #0x1dd
   bfb40: eb00e95f     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x3a57c
   bfb44: eaffffe1     	b	0xbfad0 <.text+0xaf9d0> @ imm = #-0x7c
   bfb48: e1a00006     	mov	r0, r6
   bfb4c: e24bd018     	sub	sp, r11, #24
   bfb50: e8bd8bf0     	pop	{r4, r5, r6, r7, r8, r9, r11, pc}
   bfb54: 005206b0     	ldrheq	r0, [r2], #-96
   bfb58: 0051fd34     	subseq	pc, r1, r4, lsr sp
   bfb5c: 00529b0b     	subseq	r9, r2, r11, lsl #22
   bfb60: 00529aae     	subseq	r9, r2, lr, lsr #21
   bfb64: 00529a7b     	subseq	r9, r2, r11, ror r10
   bfb68: 00529aa9     	subseq	r9, r2, r9, lsr #21
   bfb6c: 00529a56     	subseq	r9, r2, r6, asr r10
   bfb70: 00529a23     	subseq	r9, r2, r3, lsr #20
   bfb74: 00529a51     	subseq	r9, r2, r1, asr r10
   bfb78: 00529a0e     	subseq	r9, r2, lr, lsl #20
   bfb7c: 00529992     	<unknown>
   bfb80: 0052995f     	subseq	r9, r2, pc, asr r9
   bfb84: 0052998d     	subseq	r9, r2, sp, lsl #19
   bfb88: 00529946     	subseq	r9, r2, r6, asr #18
   bfb8c: 00529913     	subseq	r9, r2, r3, lsl r9
   bfb90: 00529941     	subseq	r9, r2, r1, asr #18

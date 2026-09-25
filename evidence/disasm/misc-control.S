
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   ecf64: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
   ecf68: e28db018     	add	r11, sp, #24
   ecf6c: e24dd010     	sub	sp, sp, #16
   ecf70: e1a04000     	mov	r4, r0
   ecf74: e5900018     	ldr	r0, [r0, #0x18]
   ecf78: e28d200c     	add	r2, sp, #12
   ecf7c: e1a05001     	mov	r5, r1
   ecf80: e3a01018     	mov	r1, #24
   ecf84: eb00687f     	bl	0x107188 <.text+0xf7088> @ imm = #0x1a1fc
   ecf88: e3500000     	cmp	r0, #0
   ecf8c: 0a00000e     	beq	0xecfcc <.text+0xdcecc> @ imm = #0x38
   ecf90: e59f8200     	ldr	r8, [pc, #0x200]        @ 0xed198 <.text+0xdd098>
   ecf94: e79f8008     	ldr	r8, [pc, r8]
   ecf98: e5980000     	ldr	r0, [r8]
   ecf9c: e59f71f8     	ldr	r7, [pc, #0x1f8]        @ 0xed19c <.text+0xdd09c>
   ecfa0: e2401001     	sub	r1, r0, #1
   ecfa4: e0000190     	mul	r0, r0, r1
   ecfa8: e79f7007     	ldr	r7, [pc, r7]
   ecfac: e59f61ec     	ldr	r6, [pc, #0x1ec]        @ 0xed1a0 <.text+0xdd0a0>
   ecfb0: e08f6006     	add	r6, pc, r6
   ecfb4: e3100001     	tst	r0, #1
   ecfb8: 0a00002b     	beq	0xed06c <.text+0xdcf6c> @ imm = #0xac
   ecfbc: e5970000     	ldr	r0, [r7]
   ecfc0: e3500009     	cmp	r0, #9
   ecfc4: ca00003e     	bgt	0xed0c4 <.text+0xdcfc4> @ imm = #0xf8
   ecfc8: ea000027     	b	0xed06c <.text+0xdcf6c> @ imm = #0x9c
   ecfcc: e59d000c     	ldr	r0, [sp, #0xc]
   ecfd0: e30f2fff     	movw	r2, #0xffff
   ecfd4: e3550000     	cmp	r5, #0
   ecfd8: e3a0120f     	mov	r1, #-268435456
   ecfdc: e3402fbf     	movt	r2, #0xfbf
   ecfe0: e0000002     	and	r0, r0, r2
   ecfe4: 13a01501     	movne	r1, #4194304
   ecfe8: e1800001     	orr	r0, r0, r1
   ecfec: e58d000c     	str	r0, [sp, #0xc]
   ecff0: e3a01001     	mov	r1, #1
   ecff4: e58d0000     	str	r0, [sp]
   ecff8: e1a00004     	mov	r0, r4
   ecffc: e3a02000     	mov	r2, #0
   ed000: e3a03018     	mov	r3, #24
   ed004: e3a05000     	mov	r5, #0
   ed008: eb000635     	bl	0xee8e4 <.text+0xde7e4> @ imm = #0x18d4

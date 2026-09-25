
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   aa150: 00536a74     	subseq	r6, r3, r4, ror r10
   aa154: 0053f1ef     	subseq	pc, r3, pc, ror #3
   aa158: 005360ac     	subseq	r6, r3, r12, lsr #1
   aa15c: 00536a30     	subseq	r6, r3, r0, lsr r10
   aa160: 0053f161     	subseq	pc, r3, r1, ror #2
   aa164: 00536068     	subseq	r6, r3, r8, rrx
   aa168: 0053f174     	subseq	pc, r3, r4, ror r1
   aa16c: 0053f171     	subseq	pc, r3, r1, ror r1
   aa170: 0053eb7f     	subseq	lr, r3, pc, ror r11
   aa174: 0053eb7e     	subseq	lr, r3, lr, ror r11
   aa178: 0053eb99     	<unknown>
   aa17c: 0053f141     	subseq	pc, r3, r1, asr #2
   aa180: 00536930     	subseq	r6, r3, r0, lsr r9
   aa184: 00536914     	subseq	r6, r3, r4, lsl r9
   aa188: 00535f48     	subseq	r5, r3, r8, asr #30
   aa18c: 005368c0     	subseq	r6, r3, r0, asr #17
   aa190: 0053f0d4     	ldrsbeq	pc, [r3], #-4
   aa194: e59f1f80     	ldr	r1, [pc, #0xf80]        @ 0xab11c <.text+0x9b01c>
   aa198: e3a00000     	mov	r0, #0
   aa19c: e51b5114     	ldr	r5, [r11, #-0x114]
   aa1a0: e51b70fc     	ldr	r7, [r11, #-0xfc]
   aa1a4: e08f1001     	add	r1, pc, r1
   aa1a8: e5850000     	str	r0, [r5]
   aa1ac: e5870000     	str	r0, [r7]
   aa1b0: e51b002c     	ldr	r0, [r11, #-0x2c]
   aa1b4: eb02a17b     	bl	0x1527a8 <.text+0x1426a8> @ imm = #0xa85ec
   aa1b8: e3500000     	cmp	r0, #0
   aa1bc: 0a000003     	beq	0xaa1d0 <.text+0x9a0d0> @ imm = #0xc
   aa1c0: e1a04000     	mov	r4, r0
   aa1c4: e5900000     	ldr	r0, [r0]
   aa1c8: e3500000     	cmp	r0, #0
   aa1cc: 0a0000ea     	beq	0xaa57c <.text+0x9a47c> @ imm = #0x3a8
   aa1d0: e59f0ff8     	ldr	r0, [pc, #0xff8]        @ 0xab1d0 <.text+0x9b0d0>
   aa1d4: e59f1ff8     	ldr	r1, [pc, #0xff8]        @ 0xab1d4 <.text+0x9b0d4>
   aa1d8: e59f2ff8     	ldr	r2, [pc, #0xff8]        @ 0xab1d8 <.text+0x9b0d8>
   aa1dc: e08f0000     	add	r0, pc, r0
   aa1e0: e59f3ff4     	ldr	r3, [pc, #0xff4]        @ 0xab1dc <.text+0x9b0dc>
   aa1e4: e08f1001     	add	r1, pc, r1
   aa1e8: e08f2002     	add	r2, pc, r2
   aa1ec: e08f3003     	add	r3, pc, r3
   aa1f0: e24dd008     	sub	sp, sp, #8
   aa1f4: e3a07003     	mov	r7, #3
   aa1f8: e58d3004     	str	r3, [sp, #0x4]
   aa1fc: e3003213     	movw	r3, #0x213
   aa200: e58d7000     	str	r7, [sp]
   aa204: eb013fae     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x4feb8
   aa208: e28dd008     	add	sp, sp, #8
   aa20c: e51b2070     	ldr	r2, [r11, #-0x70]
   aa210: e3a05000     	mov	r5, #0
   aa214: e51b006c     	ldr	r0, [r11, #-0x6c]
   aa218: e51b1064     	ldr	r1, [r11, #-0x64]
   aa21c: e51b307c     	ldr	r3, [r11, #-0x7c]
   aa220: e5922000     	ldr	r2, [r2]
   aa224: e5900000     	ldr	r0, [r0]
   aa228: e5911000     	ldr	r1, [r1]
   aa22c: e5862038     	str	r2, [r6, #0x38]
   aa230: e5933000     	ldr	r3, [r3]
   aa234: e51b2078     	ldr	r2, [r11, #-0x78]
   aa238: e3530000     	cmp	r3, #0
   aa23c: 13003001     	movwne	r3, #0x1
   aa240: e5922000     	ldr	r2, [r2]
   aa244: e5c63087     	strb	r3, [r6, #0x87]
   aa248: e51b3074     	ldr	r3, [r11, #-0x74]
   aa24c: e5933000     	ldr	r3, [r3]
   aa250: e5863048     	str	r3, [r6, #0x48]
   aa254: e586104c     	str	r1, [r6, #0x4c]
   aa258: e5862050     	str	r2, [r6, #0x50]
   aa25c: e5860054     	str	r0, [r6, #0x54]
   aa260: e51b0068     	ldr	r0, [r11, #-0x68]
   aa264: ed900b00     	vldr	d0, [r0]
   aa268: e59f1fc4     	ldr	r1, [pc, #0xfc4]        @ 0xab234 <.text+0x9b134>
   aa26c: e51b0100     	ldr	r0, [r11, #-0x100]
   aa270: ed860b10     	vstr	d0, [r6, #64]
   aa274: e08f1001     	add	r1, pc, r1
   aa278: e51b411c     	ldr	r4, [r11, #-0x11c]
   aa27c: e5805000     	str	r5, [r0]
   aa280: e51b0104     	ldr	r0, [r11, #-0x104]
   aa284: e51b7118     	ldr	r7, [r11, #-0x118]
   aa288: e51b8120     	ldr	r8, [r11, #-0x120]
   aa28c: e5805000     	str	r5, [r0]
   aa290: e51b0108     	ldr	r0, [r11, #-0x108]
   aa294: e51b9124     	ldr	r9, [r11, #-0x124]
   aa298: e51ba12c     	ldr	r10, [r11, #-0x12c]
   aa29c: e5805000     	str	r5, [r0]
   aa2a0: e51b010c     	ldr	r0, [r11, #-0x10c]
   aa2a4: e51b6128     	ldr	r6, [r11, #-0x128]
   aa2a8: e5845000     	str	r5, [r4]
   aa2ac: e5805000     	str	r5, [r0]
   aa2b0: e51b0110     	ldr	r0, [r11, #-0x110]
   aa2b4: e5875000     	str	r5, [r7]
   aa2b8: e5885000     	str	r5, [r8]
   aa2bc: e5805000     	str	r5, [r0]
   aa2c0: e51b0040     	ldr	r0, [r11, #-0x40]
   aa2c4: e5895000     	str	r5, [r9]
   aa2c8: e58a5000     	str	r5, [r10]
   aa2cc: e5865000     	str	r5, [r6]
   aa2d0: eb02a134     	bl	0x1527a8 <.text+0x1426a8> @ imm = #0xa84d0
   aa2d4: e24dd058     	sub	sp, sp, #88
   aa2d8: e59f3fe0     	ldr	r3, [pc, #0xfe0]        @ 0xab2c0 <.text+0x9b1c0>
   aa2dc: e59f1fe0     	ldr	r1, [pc, #0xfe0]        @ 0xab2c4 <.text+0x9b1c4>
   aa2e0: e59f2fe0     	ldr	r2, [pc, #0xfe0]        @ 0xab2c8 <.text+0x9b1c8>
   aa2e4: e08f3003     	add	r3, pc, r3
   aa2e8: e08f1001     	add	r1, pc, r1
   aa2ec: e58d6054     	str	r6, [sp, #0x54]
   aa2f0: e08f2002     	add	r2, pc, r2
   aa2f4: e58d2040     	str	r2, [sp, #0x40]
   aa2f8: e58d4044     	str	r4, [sp, #0x44]
   aa2fc: e1a06000     	mov	r6, r0
   aa300: e58d1048     	str	r1, [sp, #0x48]
   aa304: e58d704c     	str	r7, [sp, #0x4c]
   aa308: e58d3050     	str	r3, [sp, #0x50]
   aa30c: e59f0fb8     	ldr	r0, [pc, #0xfb8]        @ 0xab2cc <.text+0x9b1cc>
   aa310: e59f1fb8     	ldr	r1, [pc, #0xfb8]        @ 0xab2d0 <.text+0x9b1d0>
   aa314: e59f2fb8     	ldr	r2, [pc, #0xfb8]        @ 0xab2d4 <.text+0x9b1d4>
   aa318: e08f0000     	add	r0, pc, r0
   aa31c: e59f3fb4     	ldr	r3, [pc, #0xfb4]        @ 0xab2d8 <.text+0x9b1d8>
   aa320: e08f1001     	add	r1, pc, r1
   aa324: e58d0038     	str	r0, [sp, #0x38]
   aa328: e08f2002     	add	r2, pc, r2
   aa32c: e51b0100     	ldr	r0, [r11, #-0x100]
   aa330: e08f3003     	add	r3, pc, r3
   aa334: e58d3020     	str	r3, [sp, #0x20]
   aa338: e58da024     	str	r10, [sp, #0x24]
   aa33c: e58d2028     	str	r2, [sp, #0x28]
   aa340: e58d902c     	str	r9, [sp, #0x2c]
   aa344: e58d1030     	str	r1, [sp, #0x30]
   aa348: e58d8034     	str	r8, [sp, #0x34]
   aa34c: e58d003c     	str	r0, [sp, #0x3c]
   aa350: e59f0f84     	ldr	r0, [pc, #0xf84]        @ 0xab2dc <.text+0x9b1dc>
   aa354: e59f1f84     	ldr	r1, [pc, #0xf84]        @ 0xab2e0 <.text+0x9b1e0>
   aa358: e59f2f84     	ldr	r2, [pc, #0xf84]        @ 0xab2e4 <.text+0x9b1e4>
   aa35c: e08f0000     	add	r0, pc, r0
   aa360: e08f1001     	add	r1, pc, r1
   aa364: e59f3f7c     	ldr	r3, [pc, #0xf7c]        @ 0xab2e8 <.text+0x9b1e8>
   aa368: e08f2002     	add	r2, pc, r2
   aa36c: e58d2000     	str	r2, [sp]
   aa370: e51b210c     	ldr	r2, [r11, #-0x10c]
   aa374: e08f3003     	add	r3, pc, r3
   aa378: e58d1008     	str	r1, [sp, #0x8]
   aa37c: e51b1108     	ldr	r1, [r11, #-0x108]
   aa380: e58d0010     	str	r0, [sp, #0x10]
   aa384: e51b0104     	ldr	r0, [r11, #-0x104]
   aa388: e58d2004     	str	r2, [sp, #0x4]
   aa38c: e3a02000     	mov	r2, #0
   aa390: e58d100c     	str	r1, [sp, #0xc]
   aa394: e58d0014     	str	r0, [sp, #0x14]
   aa398: e59f0fd8     	ldr	r0, [pc, #0xfd8]        @ 0xab378 <.text+0x9b278>
   aa39c: e51b4130     	ldr	r4, [r11, #-0x130]
   aa3a0: e08f0000     	add	r0, pc, r0
   aa3a4: e58d0018     	str	r0, [sp, #0x18]
   aa3a8: e51b0110     	ldr	r0, [r11, #-0x110]
   aa3ac: e58d001c     	str	r0, [sp, #0x1c]
   aa3b0: e1a00006     	mov	r0, r6
   aa3b4: e1a01004     	mov	r1, r4
   aa3b8: eb027090     	bl	0x146600 <.text+0x136500> @ imm = #0x9c240
   aa3bc: e28dd058     	add	sp, sp, #88
   aa3c0: e3500000     	cmp	r0, #0
   aa3c4: 0a00003f     	beq	0xaa4c8 <.text+0x9a3c8> @ imm = #0xfc
   aa3c8: e59f0fac     	ldr	r0, [pc, #0xfac]        @ 0xab37c <.text+0x9b27c>
   aa3cc: e59f1fac     	ldr	r1, [pc, #0xfac]        @ 0xab380 <.text+0x9b280>
   aa3d0: e59f2fac     	ldr	r2, [pc, #0xfac]        @ 0xab384 <.text+0x9b284>
   aa3d4: e08f0000     	add	r0, pc, r0
   aa3d8: e59f3fa8     	ldr	r3, [pc, #0xfa8]        @ 0xab388 <.text+0x9b288>
   aa3dc: e08f1001     	add	r1, pc, r1
   aa3e0: e08f2002     	add	r2, pc, r2
   aa3e4: e08f3003     	add	r3, pc, r3
   aa3e8: e24dd010     	sub	sp, sp, #16
   aa3ec: e3a06001     	mov	r6, #1
   aa3f0: e58d3004     	str	r3, [sp, #0x4]
   aa3f4: e58d6000     	str	r6, [sp]
   aa3f8: e284705c     	add	r7, r4, #92
   aa3fc: e59f3f88     	ldr	r3, [pc, #0xf88]        @ 0xab38c <.text+0x9b28c>
   aa400: e58d700c     	str	r7, [sp, #0xc]
   aa404: e08f3003     	add	r3, pc, r3
   aa408: e58d3008     	str	r3, [sp, #0x8]
   aa40c: e30032fb     	movw	r3, #0x2fb
   aa410: eb013f2b     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0x4fcac
   aa414: e28dd010     	add	sp, sp, #16
   aa418: e3550000     	cmp	r5, #0
   aa41c: 0a0000a0     	beq	0xaa6a4 <.text+0x9a5a4> @ imm = #0x280


${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c42b0: eb00377d     	bl	0xd20ac <.text+0xc1fac> @ imm = #0xddf4
   c42b4: e59d1054     	ldr	r1, [sp, #0x54]
   c42b8: e1500001     	cmp	r0, r1
   c42bc: 2a000002     	bhs	0xc42cc <.text+0xb41cc> @ imm = #0x8
   c42c0: e1a00006     	mov	r0, r6
   c42c4: eb1388fe     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e23f8
   c42c8: ea00000c     	b	0xc4300 <.text+0xb4200> @ imm = #0x30
   c42cc: e59f07e8     	ldr	r0, [pc, #0x7e8]        @ 0xc4abc <.text+0xb49bc>
   c42d0: e79f0000     	ldr	r0, [pc, r0]
   c42d4: e5900000     	ldr	r0, [r0]
   c42d8: e2401001     	sub	r1, r0, #1
   c42dc: e0000190     	mul	r0, r0, r1
   c42e0: e3100001     	tst	r0, #1
   c42e4: 0a000018     	beq	0xc434c <.text+0xb424c> @ imm = #0x60
   c42e8: e59f07d0     	ldr	r0, [pc, #0x7d0]        @ 0xc4ac0 <.text+0xb49c0>
   c42ec: e79f0000     	ldr	r0, [pc, r0]
   c42f0: e5900000     	ldr	r0, [r0]
   c42f4: e3500009     	cmp	r0, #9
   c42f8: ca000023     	bgt	0xc438c <.text+0xb428c> @ imm = #0x8c
   c42fc: ea000012     	b	0xc434c <.text+0xb424c> @ imm = #0x48
   c4300: e59fa7ac     	ldr	r10, [pc, #0x7ac]       @ 0xc4ab4 <.text+0xb49b4>
   c4304: e1a09005     	mov	r9, r5
   c4308: e24b8068     	sub	r8, r11, #104
   c430c: e79fa00a     	ldr	r10, [pc, r10]
   c4310: e59f57a0     	ldr	r5, [pc, #0x7a0]        @ 0xc4ab8 <.text+0xb49b8>
   c4314: e79f5005     	ldr	r5, [pc, r5]
   c4318: e59a0000     	ldr	r0, [r10]
   c431c: e2401001     	sub	r1, r0, #1
   c4320: e0000190     	mul	r0, r0, r1
   c4324: e3100001     	tst	r0, #1
   c4328: e59a0000     	ldr	r0, [r10]
   c432c: e2401001     	sub	r1, r0, #1
   c4330: e0000190     	mul	r0, r0, r1
   c4334: e3100001     	tst	r0, #1
   c4338: 0affffb3     	beq	0xc420c <.text+0xb410c> @ imm = #-0x134
   c433c: e5950000     	ldr	r0, [r5]
   c4340: e3500009     	cmp	r0, #9
   c4344: cafffff7     	bgt	0xc4328 <.text+0xb4228> @ imm = #-0x24
   c4348: eaffffaf     	b	0xc420c <.text+0xb410c> @ imm = #-0x144
   c434c: e24b1069     	sub	r1, r11, #105
   c4350: e1a0000a     	mov	r0, r10
   c4354: eb0036a5     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #0xda94
   c4358: e59f0764     	ldr	r0, [pc, #0x764]        @ 0xc4ac4 <.text+0xb49c4>
   c435c: e79f0000     	ldr	r0, [pc, r0]
   c4360: e5900000     	ldr	r0, [r0]
   c4364: e2401001     	sub	r1, r0, #1
   c4368: e0010190     	mul	r1, r0, r1
   c436c: e55b0069     	ldrb	r0, [r11, #-0x69]
   c4370: e3110001     	tst	r1, #1
   c4374: 0a000008     	beq	0xc439c <.text+0xb429c> @ imm = #0x20
   c4378: e59f1748     	ldr	r1, [pc, #0x748]        @ 0xc4ac8 <.text+0xb49c8>
   c437c: e79f1001     	ldr	r1, [pc, r1]
   c4380: e5911000     	ldr	r1, [r1]
   c4384: e3510009     	cmp	r1, #9
   c4388: da000003     	ble	0xc439c <.text+0xb429c> @ imm = #0xc
   c438c: e24b1069     	sub	r1, r11, #105
   c4390: e1a0000a     	mov	r0, r10
   c4394: eb003695     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #0xda54
   c4398: eaffffeb     	b	0xc434c <.text+0xb424c> @ imm = #-0x54
   c439c: e35000aa     	cmp	r0, #170
   c43a0: 1a000015     	bne	0xc43fc <.text+0xb42fc> @ imm = #0x54
   c43a4: e24b1069     	sub	r1, r11, #105
   c43a8: e1a0000a     	mov	r0, r10
   c43ac: eb00368f     	bl	0xd1df0 <.text+0xc1cf0> @ imm = #0xda3c
   c43b0: e55b0069     	ldrb	r0, [r11, #-0x69]
   c43b4: e3500055     	cmp	r0, #85
   c43b8: 1a00000f     	bne	0xc43fc <.text+0xb42fc> @ imm = #0x3c
   c43bc: e3580000     	cmp	r8, #0
   c43c0: 0a000012     	beq	0xc4410 <.text+0xb4310> @ imm = #0x48
   c43c4: e59f071c     	ldr	r0, [pc, #0x71c]        @ 0xc4ae8 <.text+0xb49e8>
   c43c8: e24b8068     	sub	r8, r11, #104
   c43cc: e79f0000     	ldr	r0, [pc, r0]
   c43d0: e5900000     	ldr	r0, [r0]
   c43d4: e2401001     	sub	r1, r0, #1
   c43d8: e0000190     	mul	r0, r0, r1
   c43dc: e3100001     	tst	r0, #1
   c43e0: 0a0000da     	beq	0xc4750 <.text+0xb4650> @ imm = #0x368
   c43e4: e59f0700     	ldr	r0, [pc, #0x700]        @ 0xc4aec <.text+0xb49ec>
   c43e8: e79f0000     	ldr	r0, [pc, r0]
   c43ec: e5900000     	ldr	r0, [r0]
   c43f0: e3500009     	cmp	r0, #9
   c43f4: ca0000f5     	bgt	0xc47d0 <.text+0xb46d0> @ imm = #0x3d4
   c43f8: ea0000d4     	b	0xc4750 <.text+0xb4650> @ imm = #0x350
   c43fc: e1a00006     	mov	r0, r6
   c4400: eb1388af     	bl	0x5a66c4 <.text+0x5965c4> @ imm = #0x4e22bc
   c4404: e3a00001     	mov	r0, #1
   c4408: e58d0050     	str	r0, [sp, #0x50]
   c440c: eaffffbb     	b	0xc4300 <.text+0xb4200> @ imm = #-0x114
   c4410: e24b8068     	sub	r8, r11, #104
   c4414: e59d2040     	ldr	r2, [sp, #0x40]
   c4418: e1a0000a     	mov	r0, r10
   c441c: e1a01008     	mov	r1, r8
   c4420: eb0036be     	bl	0xd1f20 <.text+0xc1e20> @ imm = #0xdaf8
   c4424: e59d204c     	ldr	r2, [sp, #0x4c]
   c4428: e59d0048     	ldr	r0, [sp, #0x48]
   c442c: e3520000     	cmp	r2, #0
   c4430: 0a000002     	beq	0xc4440 <.text+0xb4340> @ imm = #0x8
   c4434: e3520001     	cmp	r2, #1
   c4438: e59d003c     	ldr	r0, [sp, #0x3c]
   c443c: 159d0034     	ldrne	r0, [sp, #0x34]
   c4440: e1d000d0     	ldrsb	r0, [r0]
   c4444: e59fa680     	ldr	r10, [pc, #0x680]       @ 0xc4acc <.text+0xb49cc>
   c4448: e3700001     	cmn	r0, #1
   c444c: e79fa00a     	ldr	r10, [pc, r10]
   c4450: da00000a     	ble	0xc4480 <.text+0xb4380> @ imm = #0x28
   c4454: e59a0000     	ldr	r0, [r10]
   c4458: e2401001     	sub	r1, r0, #1
   c445c: e0000190     	mul	r0, r0, r1
   c4460: e3100001     	tst	r0, #1
   c4464: 0a000103     	beq	0xc4878 <.text+0xb4778> @ imm = #0x40c
   c4468: e59f0690     	ldr	r0, [pc, #0x690]        @ 0xc4b00 <.text+0xb4a00>
   c446c: e79f0000     	ldr	r0, [pc, r0]
   c4470: e5900000     	ldr	r0, [r0]
   c4474: e3500009     	cmp	r0, #9
   c4478: ca00010a     	bgt	0xc48a8 <.text+0xb47a8> @ imm = #0x428
   c447c: ea0000fd     	b	0xc4878 <.text+0xb4778> @ imm = #0x3f4

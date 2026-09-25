
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  107ed0: e92d4df0     	push	{r4, r5, r6, r7, r8, r10, r11, lr}
  107ed4: e28db018     	add	r11, sp, #24
  107ed8: e24dd010     	sub	sp, sp, #16
  107edc: e59f8360     	ldr	r8, [pc, #0x360]        @ 0x108244 <.text+0xf8144>
  107ee0: e79f8008     	ldr	r8, [pc, r8]
  107ee4: e5987000     	ldr	r7, [r8]
  107ee8: e2476001     	sub	r6, r7, #1
  107eec: e0070697     	mul	r7, r7, r6
  107ef0: e3170001     	tst	r7, #1
  107ef4: e5987000     	ldr	r7, [r8]
  107ef8: e59f6348     	ldr	r6, [pc, #0x348]        @ 0x108248 <.text+0xf8148>
  107efc: e2475001     	sub	r5, r7, #1
  107f00: e08f6006     	add	r6, pc, r6
  107f04: e0070597     	mul	r7, r7, r5
  107f08: e59f533c     	ldr	r5, [pc, #0x33c]        @ 0x10824c <.text+0xf814c>
  107f0c: e79f5005     	ldr	r5, [pc, r5]
  107f10: e5d66000     	ldrb	r6, [r6]
  107f14: e3170001     	tst	r7, #1
  107f18: 0a000002     	beq	0x107f28 <.text+0xf7e28> @ imm = #0x8
  107f1c: e5957000     	ldr	r7, [r5]
  107f20: e3570009     	cmp	r7, #9
  107f24: cafffff2     	bgt	0x107ef4 <.text+0xf7df4> @ imm = #-0x38
  107f28: e5957000     	ldr	r7, [r5]
  107f2c: e3a04000     	mov	r4, #0
  107f30: e357000a     	cmp	r7, #10
  107f34: b3004001     	movwlt	r4, #0x1
  107f38: e3560000     	cmp	r6, #0
  107f3c: 0a000021     	beq	0x107fc8 <.text+0xf7ec8> @ imm = #0x84
  107f40: e5987000     	ldr	r7, [r8]
  107f44: e3a04000     	mov	r4, #0
  107f48: e2476001     	sub	r6, r7, #1
  107f4c: e0070697     	mul	r7, r7, r6
  107f50: e59f6314     	ldr	r6, [pc, #0x314]        @ 0x10826c <.text+0xf816c>
  107f54: e79f6006     	ldr	r6, [pc, r6]
  107f58: e1560000     	cmp	r6, r0
  107f5c: e3a06000     	mov	r6, #0
  107f60: c3006001     	movwgt	r6, #0x1
  107f64: e3700001     	cmn	r0, #1
  107f68: c3004001     	movwgt	r4, #0x1
  107f6c: e3170001     	tst	r7, #1
  107f70: 0a000002     	beq	0x107f80 <.text+0xf7e80> @ imm = #0x8
  107f74: e5957000     	ldr	r7, [r5]
  107f78: e3570009     	cmp	r7, #9
  107f7c: caffffef     	bgt	0x107f40 <.text+0xf7e40> @ imm = #-0x44
  107f80: e0147006     	ands	r7, r4, r6
  107f84: 0a000019     	beq	0x107ff0 <.text+0xf7ef0> @ imm = #0x64
  107f88: e3520c01     	cmp	r2, #256
  107f8c: 3a000025     	blo	0x108028 <.text+0xf7f28> @ imm = #0x94
  107f90: e59f02e8     	ldr	r0, [pc, #0x2e8]        @ 0x108280 <.text+0xf8180>
  107f94: e3a06001     	mov	r6, #1
  107f98: e59f12e4     	ldr	r1, [pc, #0x2e4]        @ 0x108284 <.text+0xf8184>
  107f9c: e59f32e4     	ldr	r3, [pc, #0x2e4]        @ 0x108288 <.text+0xf8188>
  107fa0: e08f0000     	add	r0, pc, r0
  107fa4: e59f72e0     	ldr	r7, [pc, #0x2e0]        @ 0x10828c <.text+0xf818c>
  107fa8: e08f1001     	add	r1, pc, r1
  107fac: e08f3003     	add	r3, pc, r3
  107fb0: e08f7007     	add	r7, pc, r7
  107fb4: e88d00c0     	stm	sp, {r6, r7}
  107fb8: e58d2008     	str	r2, [sp, #0x8]
  107fbc: e1a02003     	mov	r2, r3
  107fc0: e3a03fdd     	mov	r3, #884
  107fc4: ea00005c     	b	0x10813c <.text+0xf803c> @ imm = #0x170
  107fc8: e5980000     	ldr	r0, [r8]
  107fcc: e59f627c     	ldr	r6, [pc, #0x27c]        @ 0x108250 <.text+0xf8150>
  107fd0: e2401001     	sub	r1, r0, #1
  107fd4: e08f6006     	add	r6, pc, r6
  107fd8: e0000190     	mul	r0, r0, r1
  107fdc: e3a01001     	mov	r1, #1
  107fe0: e1c10000     	bic	r0, r1, r0
  107fe4: e1900004     	orrs	r0, r0, r4
  107fe8: 1a00005f     	bne	0x10816c <.text+0xf806c> @ imm = #0x17c
  107fec: ea000071     	b	0x1081b8 <.text+0xf80b8> @ imm = #0x1c4
  107ff0: e59f3278     	ldr	r3, [pc, #0x278]        @ 0x108270 <.text+0xf8170>
  107ff4: e3a06001     	mov	r6, #1
  107ff8: e59f1274     	ldr	r1, [pc, #0x274]        @ 0x108274 <.text+0xf8174>
  107ffc: e59f2274     	ldr	r2, [pc, #0x274]        @ 0x108278 <.text+0xf8178>
  108000: e08f3003     	add	r3, pc, r3
  108004: e59f7270     	ldr	r7, [pc, #0x270]        @ 0x10827c <.text+0xf817c>
  108008: e08f1001     	add	r1, pc, r1
  10800c: e08f2002     	add	r2, pc, r2
  108010: e08f7007     	add	r7, pc, r7
  108014: e88d00c0     	stm	sp, {r6, r7}
  108018: e58d0008     	str	r0, [sp, #0x8]
  10801c: e1a00003     	mov	r0, r3
  108020: e300336f     	movw	r3, #0x36f
  108024: ea000044     	b	0x10813c <.text+0xf803c> @ imm = #0x110
  108028: e5987000     	ldr	r7, [r8]
  10802c: e2476001     	sub	r6, r7, #1
  108030: e0070697     	mul	r7, r7, r6
  108034: e3170001     	tst	r7, #1
  108038: e5987000     	ldr	r7, [r8]
  10803c: e2476001     	sub	r6, r7, #1
  108040: e0070697     	mul	r7, r7, r6
  108044: e59f6244     	ldr	r6, [pc, #0x244]        @ 0x108290 <.text+0xf8190>
  108048: e79f6006     	ldr	r6, [pc, r6]
  10804c: e3170001     	tst	r7, #1
  108050: 0a000002     	beq	0x108060 <.text+0xf7f60> @ imm = #0x8
  108054: e5957000     	ldr	r7, [r5]
  108058: e3570009     	cmp	r7, #9
  10805c: cafffff5     	bgt	0x108038 <.text+0xf7f38> @ imm = #-0x2c
  108060: e3510000     	cmp	r1, #0
  108064: 4a000027     	bmi	0x108108 <.text+0xf8008> @ imm = #0x9c
  108068: e5987000     	ldr	r7, [r8]
  10806c: e2474001     	sub	r4, r7, #1
  108070: e0070497     	mul	r7, r7, r4
  108074: e3170001     	tst	r7, #1
  108078: e5987000     	ldr	r7, [r8]
  10807c: e080c300     	add	r12, r0, r0, lsl #6
  108080: e2474001     	sub	r4, r7, #1
  108084: e00e0497     	mul	lr, r7, r4
  108088: e086418c     	add	r4, r6, r12, lsl #3
  10808c: e594c204     	ldr	r12, [r4, #0x204]
  108090: e31e0001     	tst	lr, #1
  108094: 0a000002     	beq	0x1080a4 <.text+0xf7fa4> @ imm = #0x8
  108098: e5957000     	ldr	r7, [r5]
  10809c: e3570009     	cmp	r7, #9
  1080a0: cafffff4     	bgt	0x108078 <.text+0xf7f78> @ imm = #-0x30
  1080a4: e15c0001     	cmp	r12, r1
  1080a8: da000016     	ble	0x108108 <.text+0xf8008> @ imm = #0x58
  1080ac: e5940200     	ldr	r0, [r4, #0x200]
  1080b0: e3a06000     	mov	r6, #0
  1080b4: e0801481     	add	r1, r0, r1, lsl #9
  1080b8: e7910186     	ldr	r0, [r1, r6, lsl #3]
  1080bc: e1500002     	cmp	r0, r2
  1080c0: 0a000020     	beq	0x108148 <.text+0xf8048> @ imm = #0x80
  1080c4: e2866001     	add	r6, r6, #1
  1080c8: e3560040     	cmp	r6, #64
  1080cc: 1afffff9     	bne	0x1080b8 <.text+0xf7fb8> @ imm = #-0x1c
  1080d0: e59f01cc     	ldr	r0, [pc, #0x1cc]        @ 0x1082a4 <.text+0xf81a4>
  1080d4: e3a06001     	mov	r6, #1
  1080d8: e59f11c8     	ldr	r1, [pc, #0x1c8]        @ 0x1082a8 <.text+0xf81a8>
  1080dc: e59f31c8     	ldr	r3, [pc, #0x1c8]        @ 0x1082ac <.text+0xf81ac>
  1080e0: e08f0000     	add	r0, pc, r0
  1080e4: e59f71c4     	ldr	r7, [pc, #0x1c4]        @ 0x1082b0 <.text+0xf81b0>
  1080e8: e08f1001     	add	r1, pc, r1
  1080ec: e08f3003     	add	r3, pc, r3
  1080f0: e08f7007     	add	r7, pc, r7
  1080f4: e88d00c0     	stm	sp, {r6, r7}
  1080f8: e58d2008     	str	r2, [sp, #0x8]
  1080fc: e1a02003     	mov	r2, r3
  108100: e3a03d0e     	mov	r3, #896
  108104: ea00000c     	b	0x10813c <.text+0xf803c> @ imm = #0x30
  108108: e59f3184     	ldr	r3, [pc, #0x184]        @ 0x108294 <.text+0xf8194>
  10810c: e3a06001     	mov	r6, #1
  108110: e59f1180     	ldr	r1, [pc, #0x180]        @ 0x108298 <.text+0xf8198>
  108114: e59f2180     	ldr	r2, [pc, #0x180]        @ 0x10829c <.text+0xf819c>
  108118: e08f3003     	add	r3, pc, r3
  10811c: e59f717c     	ldr	r7, [pc, #0x17c]        @ 0x1082a0 <.text+0xf81a0>
  108120: e08f1001     	add	r1, pc, r1
  108124: e08f2002     	add	r2, pc, r2
  108128: e08f7007     	add	r7, pc, r7
  10812c: e88d00c0     	stm	sp, {r6, r7}
  108130: e58d0008     	str	r0, [sp, #0x8]
  108134: e1a00003     	mov	r0, r3
  108138: e300337a     	movw	r3, #0x37a
  10813c: ebffc7e0     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xe080
  108140: e3e00000     	mvn	r0, #0
  108144: ea000034     	b	0x10821c <.text+0xf811c> @ imm = #0xd0
  108148: e5980000     	ldr	r0, [r8]
  10814c: e2402001     	sub	r2, r0, #1
  108150: e0000290     	mul	r0, r0, r2
  108154: e3100001     	tst	r0, #1
  108158: 0a000021     	beq	0x1081e4 <.text+0xf80e4> @ imm = #0x84
  10815c: e5950000     	ldr	r0, [r5]
  108160: e3500009     	cmp	r0, #9
  108164: ca000029     	bgt	0x108210 <.text+0xf8110> @ imm = #0xa4
  108168: ea00001d     	b	0x1081e4 <.text+0xf80e4> @ imm = #0x74
  10816c: e59f00e0     	ldr	r0, [pc, #0xe0]         @ 0x108254 <.text+0xf8154>
  108170: e3a03001     	mov	r3, #1
  108174: e59f10dc     	ldr	r1, [pc, #0xdc]         @ 0x108258 <.text+0xf8158>
  108178: e59f20dc     	ldr	r2, [pc, #0xdc]         @ 0x10825c <.text+0xf815c>
  10817c: e08f0000     	add	r0, pc, r0
  108180: e08f1001     	add	r1, pc, r1
  108184: e88d0048     	stm	sp, {r3, r6}
  108188: e08f2002     	add	r2, pc, r2
  10818c: e300336a     	movw	r3, #0x36a
  108190: ebffc7cb     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xe0d4
  108194: e5980000     	ldr	r0, [r8]
  108198: e2401001     	sub	r1, r0, #1
  10819c: e0010190     	mul	r1, r0, r1
  1081a0: e3e00000     	mvn	r0, #0
  1081a4: e3110001     	tst	r1, #1
  1081a8: 0a00001b     	beq	0x10821c <.text+0xf811c> @ imm = #0x6c
  1081ac: e5951000     	ldr	r1, [r5]
  1081b0: e351000a     	cmp	r1, #10
  1081b4: ba000018     	blt	0x10821c <.text+0xf811c> @ imm = #0x60
  1081b8: e59f00a0     	ldr	r0, [pc, #0xa0]         @ 0x108260 <.text+0xf8160>
  1081bc: e3a03001     	mov	r3, #1
  1081c0: e59f109c     	ldr	r1, [pc, #0x9c]         @ 0x108264 <.text+0xf8164>
  1081c4: e59f209c     	ldr	r2, [pc, #0x9c]         @ 0x108268 <.text+0xf8168>
  1081c8: e08f0000     	add	r0, pc, r0
  1081cc: e08f1001     	add	r1, pc, r1
  1081d0: e88d0048     	stm	sp, {r3, r6}
  1081d4: e08f2002     	add	r2, pc, r2
  1081d8: e300336a     	movw	r3, #0x36a
  1081dc: ebffc7b8     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #-0xe120
  1081e0: eaffffe1     	b	0x10816c <.text+0xf806c> @ imm = #-0x7c
  1081e4: e0810186     	add	r0, r1, r6, lsl #3
  1081e8: e5803004     	str	r3, [r0, #0x4]
  1081ec: e5980000     	ldr	r0, [r8]
  1081f0: e2402001     	sub	r2, r0, #1
  1081f4: e0020290     	mul	r2, r0, r2
  1081f8: e3a00000     	mov	r0, #0
  1081fc: e3120001     	tst	r2, #1
  108200: 0a000005     	beq	0x10821c <.text+0xf811c> @ imm = #0x14
  108204: e5952000     	ldr	r2, [r5]
  108208: e3520009     	cmp	r2, #9
  10820c: da000002     	ble	0x10821c <.text+0xf811c> @ imm = #0x8
  108210: e0810186     	add	r0, r1, r6, lsl #3
  108214: e5803004     	str	r3, [r0, #0x4]
  108218: eafffff1     	b	0x1081e4 <.text+0xf80e4> @ imm = #-0x3c
  10821c: e5981000     	ldr	r1, [r8]
  108220: e2412001     	sub	r2, r1, #1
  108224: e0010291     	mul	r1, r1, r2
  108228: e3110001     	tst	r1, #1
  10822c: 0a000002     	beq	0x10823c <.text+0xf813c> @ imm = #0x8
  108230: e5951000     	ldr	r1, [r5]
  108234: e3510009     	cmp	r1, #9
  108238: cafffff7     	bgt	0x10821c <.text+0xf811c> @ imm = #-0x24
  10823c: e24bd018     	sub	sp, r11, #24
  108240: e8bd8df0     	pop	{r4, r5, r6, r7, r8, r10, r11, pc}
  108244: 004d76c4     	subeq	r7, sp, r4, asr #13
  108248: 0054ce68     	subseq	r12, r4, r8, ror #28
  10824c: 004d70f4     	strdeq	r7, r8, [sp], #-4
  108250: 004e552c     	subeq	r5, lr, r12, lsr #10
  108254: 004e52e7     	subeq	r5, lr, r7, ror #5
  108258: 004e52ea     	subeq	r5, lr, r10, ror #5
  10825c: 004e5308     	subeq	r5, lr, r8, lsl #6
  108260: 004e529b     	umaaleq	r5, lr, r11, r2
  108264: 004e529e     	umaaleq	r5, lr, lr, r2
  108268: 004e52bc     	strheq	r5, [lr], #-44
  10826c: 0054ce10     	subseq	r12, r4, r0, lsl lr
  108270: 004e5463     	subeq	r5, lr, r3, ror #8
  108274: 004e5462     	subeq	r5, lr, r2, ror #8
  108278: 004e5484     	subeq	r5, lr, r4, lsl #9
  10827c: 004e550a     	subeq	r5, lr, r10, lsl #10
  108280: 004e54c3     	subeq	r5, lr, r3, asr #9
  108284: 004e54c2     	subeq	r5, lr, r2, asr #9
  108288: 004e54e4     	subeq	r5, lr, r4, ror #9
  10828c: 004e5580     	subeq	r5, lr, r0, lsl #11
  108290: 0054cd18     	subseq	r12, r4, r8, lsl sp
  108294: 004e534b     	subeq	r5, lr, r11, asr #6
  108298: 004e534a     	subeq	r5, lr, r10, asr #6
  10829c: 004e536c     	subeq	r5, lr, r12, ror #6
  1082a0: 004e544f     	subeq	r5, lr, pc, asr #8
  1082a4: 004e5383     	subeq	r5, lr, r3, lsl #7
  1082a8: 004e5382     	subeq	r5, lr, r2, lsl #7
  1082ac: 004e53a4     	subeq	r5, lr, r4, lsr #7
  1082b0: 004e5465     	subeq	r5, lr, r5, ror #8

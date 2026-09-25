
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c5094: e92d4800     	push	{r11, lr}
   c5098: e3a00000     	mov	r0, #0
   c509c: e3500000     	cmp	r0, #0
   c50a0: 1a000007     	bne	0xc50c4 <.text+0xb4fc4> @ imm = #0x1c
   c50a4: e59f1598     	ldr	r1, [pc, #0x598]        @ 0xc5644 <.text+0xb5544>
   c50a8: e08f1001     	add	r1, pc, r1
   c50ac: e7d12000     	ldrb	r2, [r1, r0]
   c50b0: e22220af     	eor	r2, r2, #175
   c50b4: e7c12000     	strb	r2, [r1, r0]
   c50b8: e2800001     	add	r0, r0, #1
   c50bc: e350000d     	cmp	r0, #13
   c50c0: 1afffff9     	bne	0xc50ac <.text+0xb4fac> @ imm = #-0x1c
   c50c4: e3a00000     	mov	r0, #0
   c50c8: e3500000     	cmp	r0, #0
   c50cc: 1a000007     	bne	0xc50f0 <.text+0xb4ff0> @ imm = #0x1c
   c50d0: e59f1570     	ldr	r1, [pc, #0x570]        @ 0xc5648 <.text+0xb5548>
   c50d4: e08f1001     	add	r1, pc, r1
   c50d8: e7d12000     	ldrb	r2, [r1, r0]
   c50dc: e2222009     	eor	r2, r2, #9
   c50e0: e7c12000     	strb	r2, [r1, r0]
   c50e4: e2800001     	add	r0, r0, #1
   c50e8: e350002b     	cmp	r0, #43
   c50ec: 1afffff9     	bne	0xc50d8 <.text+0xb4fd8> @ imm = #-0x1c
   c50f0: e59fe554     	ldr	lr, [pc, #0x554]        @ 0xc564c <.text+0xb554c>
   c50f4: e79fe00e     	ldr	lr, [pc, lr]
   c50f8: e59e1000     	ldr	r1, [lr]
   c50fc: e2412001     	sub	r2, r1, #1
   c5100: e0010291     	mul	r1, r1, r2
   c5104: e3110001     	tst	r1, #1
   c5108: e59e1000     	ldr	r1, [lr]
   c510c: e59fc53c     	ldr	r12, [pc, #0x53c]       @ 0xc5650 <.text+0xb5550>
   c5110: e2412001     	sub	r2, r1, #1
   c5114: e0010291     	mul	r1, r1, r2
   c5118: e79fc00c     	ldr	r12, [pc, r12]
   c511c: e3110001     	tst	r1, #1
   c5120: 0a000002     	beq	0xc5130 <.text+0xb5030> @ imm = #0x8
   c5124: e59c1000     	ldr	r1, [r12]
   c5128: e3510009     	cmp	r1, #9
   c512c: cafffff5     	bgt	0xc5108 <.text+0xb5008> @ imm = #-0x2c
   c5130: e3a02000     	mov	r2, #0
   c5134: e3520000     	cmp	r2, #0
   c5138: 1a000007     	bne	0xc515c <.text+0xb505c> @ imm = #0x1c
   c513c: e59f3510     	ldr	r3, [pc, #0x510]        @ 0xc5654 <.text+0xb5554>
   c5140: e08f3003     	add	r3, pc, r3
   c5144: e7d31002     	ldrb	r1, [r3, r2]
   c5148: e22110b1     	eor	r1, r1, #177
   c514c: e7c31002     	strb	r1, [r3, r2]
   c5150: e2822001     	add	r2, r2, #1
   c5154: e3520007     	cmp	r2, #7
   c5158: 1afffff9     	bne	0xc5144 <.text+0xb5044> @ imm = #-0x1c
   c515c: e3a02000     	mov	r2, #0
   c5160: e3520000     	cmp	r2, #0
   c5164: 1a000007     	bne	0xc5188 <.text+0xb5088> @ imm = #0x1c
   c5168: e59f34e8     	ldr	r3, [pc, #0x4e8]        @ 0xc5658 <.text+0xb5558>
   c516c: e08f3003     	add	r3, pc, r3
   c5170: e7d31002     	ldrb	r1, [r3, r2]
   c5174: e2211088     	eor	r1, r1, #136
   c5178: e7c31002     	strb	r1, [r3, r2]
   c517c: e2822001     	add	r2, r2, #1
   c5180: e352000b     	cmp	r2, #11
   c5184: 1afffff9     	bne	0xc5170 <.text+0xb5070> @ imm = #-0x1c
   c5188: e3a02000     	mov	r2, #0
   c518c: e3520000     	cmp	r2, #0
   c5190: 1a00001d     	bne	0xc520c <.text+0xb510c> @ imm = #0x74
   c5194: e59f34c0     	ldr	r3, [pc, #0x4c0]        @ 0xc565c <.text+0xb555c>
   c5198: e08f3003     	add	r3, pc, r3
   c519c: ea000002     	b	0xc51ac <.text+0xb50ac> @ imm = #0x8
   c51a0: e3510017     	cmp	r1, #23
   c51a4: e1a02001     	mov	r2, r1
   c51a8: 0a000017     	beq	0xc520c <.text+0xb510c> @ imm = #0x5c
   c51ac: e59e1000     	ldr	r1, [lr]
   c51b0: e2410001     	sub	r0, r1, #1
   c51b4: e0000091     	mul	r0, r1, r0
   c51b8: e3100001     	tst	r0, #1
   c51bc: 0a000002     	beq	0xc51cc <.text+0xb50cc> @ imm = #0x8
   c51c0: e59c0000     	ldr	r0, [r12]
   c51c4: e3500009     	cmp	r0, #9
   c51c8: ca00000b     	bgt	0xc51fc <.text+0xb50fc> @ imm = #0x2c
   c51cc: e7d30002     	ldrb	r0, [r3, r2]
   c51d0: e220008a     	eor	r0, r0, #138
   c51d4: e7c30002     	strb	r0, [r3, r2]
   c51d8: e59e0000     	ldr	r0, [lr]
   c51dc: e2401001     	sub	r1, r0, #1
   c51e0: e0000190     	mul	r0, r0, r1
   c51e4: e2821001     	add	r1, r2, #1
   c51e8: e3100001     	tst	r0, #1
   c51ec: 0affffeb     	beq	0xc51a0 <.text+0xb50a0> @ imm = #-0x54
   c51f0: e59c0000     	ldr	r0, [r12]
   c51f4: e3500009     	cmp	r0, #9
   c51f8: daffffe8     	ble	0xc51a0 <.text+0xb50a0> @ imm = #-0x60
   c51fc: e7d30002     	ldrb	r0, [r3, r2]
   c5200: e220008a     	eor	r0, r0, #138
   c5204: e7c30002     	strb	r0, [r3, r2]
   c5208: eaffffef     	b	0xc51cc <.text+0xb50cc> @ imm = #-0x44
   c520c: e59e0000     	ldr	r0, [lr]
   c5210: e2401001     	sub	r1, r0, #1
   c5214: e0000190     	mul	r0, r0, r1
   c5218: e3100001     	tst	r0, #1
   c521c: e59e0000     	ldr	r0, [lr]
   c5220: e2401001     	sub	r1, r0, #1
   c5224: e0000190     	mul	r0, r0, r1
   c5228: e3100001     	tst	r0, #1
   c522c: 0a000002     	beq	0xc523c <.text+0xb513c> @ imm = #0x8
   c5230: e59c0000     	ldr	r0, [r12]
   c5234: e3500009     	cmp	r0, #9
   c5238: cafffff7     	bgt	0xc521c <.text+0xb511c> @ imm = #-0x24
   c523c: e3a02000     	mov	r2, #0
   c5240: e3520000     	cmp	r2, #0
   c5244: 1a000007     	bne	0xc5268 <.text+0xb5168> @ imm = #0x1c
   c5248: e59f3410     	ldr	r3, [pc, #0x410]        @ 0xc5660 <.text+0xb5560>
   c524c: e08f3003     	add	r3, pc, r3
   c5250: e7d30002     	ldrb	r0, [r3, r2]
   c5254: e2200002     	eor	r0, r0, #2
   c5258: e7c30002     	strb	r0, [r3, r2]
   c525c: e2822001     	add	r2, r2, #1
   c5260: e3520025     	cmp	r2, #37
   c5264: 1afffff9     	bne	0xc5250 <.text+0xb5150> @ imm = #-0x1c
   c5268: e59e0000     	ldr	r0, [lr]
   c526c: e2401001     	sub	r1, r0, #1
   c5270: e0000190     	mul	r0, r0, r1
   c5274: e3100001     	tst	r0, #1
   c5278: e59e0000     	ldr	r0, [lr]
   c527c: e2401001     	sub	r1, r0, #1
   c5280: e0000190     	mul	r0, r0, r1
   c5284: e3100001     	tst	r0, #1
   c5288: 0a000002     	beq	0xc5298 <.text+0xb5198> @ imm = #0x8
   c528c: e59c0000     	ldr	r0, [r12]
   c5290: e3500009     	cmp	r0, #9
   c5294: cafffff7     	bgt	0xc5278 <.text+0xb5178> @ imm = #-0x24
   c5298: e3a02000     	mov	r2, #0
   c529c: e3520000     	cmp	r2, #0
   c52a0: 1a000007     	bne	0xc52c4 <.text+0xb51c4> @ imm = #0x1c
   c52a4: e59f33b8     	ldr	r3, [pc, #0x3b8]        @ 0xc5664 <.text+0xb5564>
   c52a8: e08f3003     	add	r3, pc, r3
   c52ac: e7d30002     	ldrb	r0, [r3, r2]
   c52b0: e220001b     	eor	r0, r0, #27
   c52b4: e7c30002     	strb	r0, [r3, r2]
   c52b8: e2822001     	add	r2, r2, #1
   c52bc: e352002c     	cmp	r2, #44
   c52c0: 1afffff9     	bne	0xc52ac <.text+0xb51ac> @ imm = #-0x1c
   c52c4: e59e0000     	ldr	r0, [lr]
   c52c8: e2401001     	sub	r1, r0, #1
   c52cc: e0000190     	mul	r0, r0, r1
   c52d0: e3100001     	tst	r0, #1
   c52d4: e59e0000     	ldr	r0, [lr]
   c52d8: e2401001     	sub	r1, r0, #1
   c52dc: e0000190     	mul	r0, r0, r1
   c52e0: e3100001     	tst	r0, #1
   c52e4: 0a000002     	beq	0xc52f4 <.text+0xb51f4> @ imm = #0x8
   c52e8: e59c0000     	ldr	r0, [r12]
   c52ec: e3500009     	cmp	r0, #9
   c52f0: cafffff7     	bgt	0xc52d4 <.text+0xb51d4> @ imm = #-0x24
   c52f4: e3a02000     	mov	r2, #0
   c52f8: e3520000     	cmp	r2, #0
   c52fc: 1a00001d     	bne	0xc5378 <.text+0xb5278> @ imm = #0x74
   c5300: e59f3360     	ldr	r3, [pc, #0x360]        @ 0xc5668 <.text+0xb5568>
   c5304: e08f3003     	add	r3, pc, r3
   c5308: ea000002     	b	0xc5318 <.text+0xb5218> @ imm = #0x8
   c530c: e351002a     	cmp	r1, #42
   c5310: e1a02001     	mov	r2, r1
   c5314: 0a000017     	beq	0xc5378 <.text+0xb5278> @ imm = #0x5c
   c5318: e59e0000     	ldr	r0, [lr]
   c531c: e2401001     	sub	r1, r0, #1
   c5320: e0000190     	mul	r0, r0, r1
   c5324: e3100001     	tst	r0, #1
   c5328: 0a000002     	beq	0xc5338 <.text+0xb5238> @ imm = #0x8
   c532c: e59c0000     	ldr	r0, [r12]
   c5330: e3500009     	cmp	r0, #9
   c5334: ca00000b     	bgt	0xc5368 <.text+0xb5268> @ imm = #0x2c
   c5338: e7d30002     	ldrb	r0, [r3, r2]
   c533c: e220002c     	eor	r0, r0, #44
   c5340: e7c30002     	strb	r0, [r3, r2]
   c5344: e59e0000     	ldr	r0, [lr]
   c5348: e2401001     	sub	r1, r0, #1
   c534c: e0000190     	mul	r0, r0, r1
   c5350: e2821001     	add	r1, r2, #1
   c5354: e3100001     	tst	r0, #1
   c5358: 0affffeb     	beq	0xc530c <.text+0xb520c> @ imm = #-0x54
   c535c: e59c0000     	ldr	r0, [r12]
   c5360: e3500009     	cmp	r0, #9
   c5364: daffffe8     	ble	0xc530c <.text+0xb520c> @ imm = #-0x60
   c5368: e7d30002     	ldrb	r0, [r3, r2]
   c536c: e220002c     	eor	r0, r0, #44
   c5370: e7c30002     	strb	r0, [r3, r2]
   c5374: eaffffef     	b	0xc5338 <.text+0xb5238> @ imm = #-0x44
   c5378: e59e0000     	ldr	r0, [lr]
   c537c: e2401001     	sub	r1, r0, #1
   c5380: e0000190     	mul	r0, r0, r1
   c5384: e3100001     	tst	r0, #1
   c5388: e59e0000     	ldr	r0, [lr]
   c538c: e2401001     	sub	r1, r0, #1
   c5390: e0000190     	mul	r0, r0, r1
   c5394: e3100001     	tst	r0, #1
   c5398: 0a000002     	beq	0xc53a8 <.text+0xb52a8> @ imm = #0x8
   c539c: e59c0000     	ldr	r0, [r12]
   c53a0: e3500009     	cmp	r0, #9
   c53a4: cafffff7     	bgt	0xc5388 <.text+0xb5288> @ imm = #-0x24
   c53a8: e3a02000     	mov	r2, #0
   c53ac: e3520000     	cmp	r2, #0
   c53b0: 1a00001d     	bne	0xc542c <.text+0xb532c> @ imm = #0x74
   c53b4: e59f32b0     	ldr	r3, [pc, #0x2b0]        @ 0xc566c <.text+0xb556c>
   c53b8: e08f3003     	add	r3, pc, r3
   c53bc: ea000002     	b	0xc53cc <.text+0xb52cc> @ imm = #0x8
   c53c0: e3510020     	cmp	r1, #32
   c53c4: e1a02001     	mov	r2, r1
   c53c8: 0a000017     	beq	0xc542c <.text+0xb532c> @ imm = #0x5c
   c53cc: e59e0000     	ldr	r0, [lr]
   c53d0: e2401001     	sub	r1, r0, #1
   c53d4: e0000190     	mul	r0, r0, r1
   c53d8: e3100001     	tst	r0, #1
   c53dc: 0a000002     	beq	0xc53ec <.text+0xb52ec> @ imm = #0x8
   c53e0: e59c0000     	ldr	r0, [r12]
   c53e4: e3500009     	cmp	r0, #9
   c53e8: ca00000b     	bgt	0xc541c <.text+0xb531c> @ imm = #0x2c
   c53ec: e7d30002     	ldrb	r0, [r3, r2]
   c53f0: e22000e7     	eor	r0, r0, #231
   c53f4: e7c30002     	strb	r0, [r3, r2]
   c53f8: e59e0000     	ldr	r0, [lr]
   c53fc: e2401001     	sub	r1, r0, #1
   c5400: e0000190     	mul	r0, r0, r1
   c5404: e2821001     	add	r1, r2, #1
   c5408: e3100001     	tst	r0, #1
   c540c: 0affffeb     	beq	0xc53c0 <.text+0xb52c0> @ imm = #-0x54
   c5410: e59c0000     	ldr	r0, [r12]
   c5414: e3500009     	cmp	r0, #9
   c5418: daffffe8     	ble	0xc53c0 <.text+0xb52c0> @ imm = #-0x60
   c541c: e7d30002     	ldrb	r0, [r3, r2]
   c5420: e22000e7     	eor	r0, r0, #231
   c5424: e7c30002     	strb	r0, [r3, r2]
   c5428: eaffffef     	b	0xc53ec <.text+0xb52ec> @ imm = #-0x44
   c542c: e3a02000     	mov	r2, #0
   c5430: e3520000     	cmp	r2, #0
   c5434: 1a000007     	bne	0xc5458 <.text+0xb5358> @ imm = #0x1c
   c5438: e59f3230     	ldr	r3, [pc, #0x230]        @ 0xc5670 <.text+0xb5570>
   c543c: e08f3003     	add	r3, pc, r3
   c5440: e7d30002     	ldrb	r0, [r3, r2]
   c5444: e220000f     	eor	r0, r0, #15
   c5448: e7c30002     	strb	r0, [r3, r2]
   c544c: e2822001     	add	r2, r2, #1
   c5450: e3520021     	cmp	r2, #33
   c5454: 1afffff9     	bne	0xc5440 <.text+0xb5340> @ imm = #-0x1c
   c5458: e3a02000     	mov	r2, #0
   c545c: e3520000     	cmp	r2, #0
   c5460: 1a000007     	bne	0xc5484 <.text+0xb5384> @ imm = #0x1c
   c5464: e59f3208     	ldr	r3, [pc, #0x208]        @ 0xc5674 <.text+0xb5574>
   c5468: e08f3003     	add	r3, pc, r3
   c546c: e7d30002     	ldrb	r0, [r3, r2]
   c5470: e22000bf     	eor	r0, r0, #191
   c5474: e7c30002     	strb	r0, [r3, r2]
   c5478: e2822001     	add	r2, r2, #1
   c547c: e352000b     	cmp	r2, #11
   c5480: 1afffff9     	bne	0xc546c <.text+0xb536c> @ imm = #-0x1c
   c5484: e59e0000     	ldr	r0, [lr]
   c5488: e2401001     	sub	r1, r0, #1
   c548c: e0000190     	mul	r0, r0, r1
   c5490: e3100001     	tst	r0, #1
   c5494: e59e0000     	ldr	r0, [lr]
   c5498: e2401001     	sub	r1, r0, #1
   c549c: e0000190     	mul	r0, r0, r1
   c54a0: e3100001     	tst	r0, #1
   c54a4: 0a000002     	beq	0xc54b4 <.text+0xb53b4> @ imm = #0x8
   c54a8: e59c0000     	ldr	r0, [r12]
   c54ac: e3500009     	cmp	r0, #9
   c54b0: cafffff7     	bgt	0xc5494 <.text+0xb5394> @ imm = #-0x24
   c54b4: e3a02000     	mov	r2, #0
   c54b8: e3520000     	cmp	r2, #0
   c54bc: 1a00001d     	bne	0xc5538 <.text+0xb5438> @ imm = #0x74
   c54c0: e59f31b0     	ldr	r3, [pc, #0x1b0]        @ 0xc5678 <.text+0xb5578>
   c54c4: e08f3003     	add	r3, pc, r3
   c54c8: ea000002     	b	0xc54d8 <.text+0xb53d8> @ imm = #0x8
   c54cc: e351000f     	cmp	r1, #15
   c54d0: e1a02001     	mov	r2, r1
   c54d4: 0a000017     	beq	0xc5538 <.text+0xb5438> @ imm = #0x5c
   c54d8: e59e0000     	ldr	r0, [lr]
   c54dc: e2401001     	sub	r1, r0, #1
   c54e0: e0000190     	mul	r0, r0, r1
   c54e4: e3100001     	tst	r0, #1
   c54e8: 0a000002     	beq	0xc54f8 <.text+0xb53f8> @ imm = #0x8
   c54ec: e59c0000     	ldr	r0, [r12]
   c54f0: e3500009     	cmp	r0, #9
   c54f4: ca00000b     	bgt	0xc5528 <.text+0xb5428> @ imm = #0x2c
   c54f8: e7d30002     	ldrb	r0, [r3, r2]
   c54fc: e220006e     	eor	r0, r0, #110
   c5500: e7c30002     	strb	r0, [r3, r2]
   c5504: e59e0000     	ldr	r0, [lr]
   c5508: e2401001     	sub	r1, r0, #1
   c550c: e0000190     	mul	r0, r0, r1
   c5510: e2821001     	add	r1, r2, #1
   c5514: e3100001     	tst	r0, #1
   c5518: 0affffeb     	beq	0xc54cc <.text+0xb53cc> @ imm = #-0x54
   c551c: e59c0000     	ldr	r0, [r12]
   c5520: e3500009     	cmp	r0, #9
   c5524: daffffe8     	ble	0xc54cc <.text+0xb53cc> @ imm = #-0x60
   c5528: e7d30002     	ldrb	r0, [r3, r2]
   c552c: e220006e     	eor	r0, r0, #110
   c5530: e7c30002     	strb	r0, [r3, r2]
   c5534: eaffffef     	b	0xc54f8 <.text+0xb53f8> @ imm = #-0x44
   c5538: e3a02000     	mov	r2, #0
   c553c: e3520000     	cmp	r2, #0
   c5540: 1a00001d     	bne	0xc55bc <.text+0xb54bc> @ imm = #0x74
   c5544: e59f3130     	ldr	r3, [pc, #0x130]        @ 0xc567c <.text+0xb557c>
   c5548: e08f3003     	add	r3, pc, r3
   c554c: ea000002     	b	0xc555c <.text+0xb545c> @ imm = #0x8
   c5550: e3510025     	cmp	r1, #37
   c5554: e1a02001     	mov	r2, r1
   c5558: 0a000017     	beq	0xc55bc <.text+0xb54bc> @ imm = #0x5c
   c555c: e59e0000     	ldr	r0, [lr]
   c5560: e2401001     	sub	r1, r0, #1
   c5564: e0000190     	mul	r0, r0, r1
   c5568: e3100001     	tst	r0, #1
   c556c: 0a000002     	beq	0xc557c <.text+0xb547c> @ imm = #0x8
   c5570: e59c0000     	ldr	r0, [r12]
   c5574: e3500009     	cmp	r0, #9
   c5578: ca00000b     	bgt	0xc55ac <.text+0xb54ac> @ imm = #0x2c
   c557c: e7d30002     	ldrb	r0, [r3, r2]
   c5580: e22000c2     	eor	r0, r0, #194
   c5584: e7c30002     	strb	r0, [r3, r2]
   c5588: e59e0000     	ldr	r0, [lr]
   c558c: e2401001     	sub	r1, r0, #1
   c5590: e0000190     	mul	r0, r0, r1
   c5594: e2821001     	add	r1, r2, #1
   c5598: e3100001     	tst	r0, #1
   c559c: 0affffeb     	beq	0xc5550 <.text+0xb5450> @ imm = #-0x54
   c55a0: e59c0000     	ldr	r0, [r12]
   c55a4: e3500009     	cmp	r0, #9
   c55a8: daffffe8     	ble	0xc5550 <.text+0xb5450> @ imm = #-0x60
   c55ac: e7d30002     	ldrb	r0, [r3, r2]
   c55b0: e22000c2     	eor	r0, r0, #194
   c55b4: e7c30002     	strb	r0, [r3, r2]
   c55b8: eaffffef     	b	0xc557c <.text+0xb547c> @ imm = #-0x44
   c55bc: e3a02000     	mov	r2, #0
   c55c0: e3520000     	cmp	r2, #0
   c55c4: 18bd8800     	popne	{r11, pc}
   c55c8: e59f30b0     	ldr	r3, [pc, #0xb0]         @ 0xc5680 <.text+0xb5580>
   c55cc: e08f3003     	add	r3, pc, r3
   c55d0: ea000002     	b	0xc55e0 <.text+0xb54e0> @ imm = #0x8
   c55d4: e351000e     	cmp	r1, #14
   c55d8: e1a02001     	mov	r2, r1
   c55dc: 0a000017     	beq	0xc5640 <.text+0xb5540> @ imm = #0x5c
   c55e0: e59e0000     	ldr	r0, [lr]
   c55e4: e2401001     	sub	r1, r0, #1
   c55e8: e0000190     	mul	r0, r0, r1
   c55ec: e3100001     	tst	r0, #1
   c55f0: 0a000002     	beq	0xc5600 <.text+0xb5500> @ imm = #0x8
   c55f4: e59c0000     	ldr	r0, [r12]
   c55f8: e3500009     	cmp	r0, #9
   c55fc: ca00000b     	bgt	0xc5630 <.text+0xb5530> @ imm = #0x2c
   c5600: e7d30002     	ldrb	r0, [r3, r2]
   c5604: e2200053     	eor	r0, r0, #83
   c5608: e7c30002     	strb	r0, [r3, r2]
   c560c: e59e0000     	ldr	r0, [lr]
   c5610: e2401001     	sub	r1, r0, #1
   c5614: e0000190     	mul	r0, r0, r1
   c5618: e2821001     	add	r1, r2, #1
   c561c: e3100001     	tst	r0, #1
   c5620: 0affffeb     	beq	0xc55d4 <.text+0xb54d4> @ imm = #-0x54
   c5624: e59c0000     	ldr	r0, [r12]
   c5628: e3500009     	cmp	r0, #9
   c562c: daffffe8     	ble	0xc55d4 <.text+0xb54d4> @ imm = #-0x60
   c5630: e7d30002     	ldrb	r0, [r3, r2]
   c5634: e2200053     	eor	r0, r0, #83
   c5638: e7c30002     	strb	r0, [r3, r2]
   c563c: eaffffef     	b	0xc5600 <.text+0xb5500> @ imm = #-0x44
   c5640: e8bd8800     	pop	{r11, pc}
   c5644: 00524571     	subseq	r4, r2, r1, ror r5
   c5648: 00524552     	subseq	r4, r2, r2, asr r5
   c564c: 0051abb4     	ldrheq	r10, [r1], #-180
   c5650: 005195b8     	ldrheq	r9, [r1], #-88
   c5654: 00524511     	subseq	r4, r2, r1, lsl r5
   c5658: 005244ec     	subseq	r4, r2, r12, ror #9
   c565c: 005244cb     	subseq	r4, r2, r11, asr #9
   c5660: 0052442e     	subseq	r4, r2, lr, lsr #8
   c5664: 005243f7     	ldrsheq	r4, [r2], #-55
   c5668: 005243c7     	subseq	r4, r2, r7, asr #7
   c566c: 0052433d     	subseq	r4, r2, sp, lsr r3
   c5670: 005242d9     	ldrsbeq	r4, [r2], #-41
   c5674: 005242ce     	subseq	r4, r2, lr, asr #5
   c5678: 0052427d     	subseq	r4, r2, sp, ror r2
   c567c: 00524208     	subseq	r4, r2, r8, lsl #4
   c5680: 005241a9     	subseq	r4, r2, r9, lsr #3
   c5684: 00000000     	andeq	r0, r0, r0


/mnt/data/vnish135_extract/ramdisk/usr/bin/cgminer:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   9ec48: e92d4800     	push	{r11, lr}
   9ec4c: e3a00000     	mov	r0, #0
   9ec50: e3500000     	cmp	r0, #0
   9ec54: 1a000007     	bne	0x9ec78 <.text+0x8eb78> @ imm = #0x1c
   9ec58: e59f1628     	ldr	r1, [pc, #0x628]        @ 0x9f288 <.text+0x8f188>
   9ec5c: e08f1001     	add	r1, pc, r1
   9ec60: e7d12000     	ldrb	r2, [r1, r0]
   9ec64: e2222029     	eor	r2, r2, #41
   9ec68: e7c12000     	strb	r2, [r1, r0]
   9ec6c: e2800001     	add	r0, r0, #1
   9ec70: e3500009     	cmp	r0, #9
   9ec74: 1afffff9     	bne	0x9ec60 <.text+0x8eb60> @ imm = #-0x1c
   9ec78: e3a00000     	mov	r0, #0
   9ec7c: e3500000     	cmp	r0, #0
   9ec80: 1a000007     	bne	0x9eca4 <.text+0x8eba4> @ imm = #0x1c
   9ec84: e59f1600     	ldr	r1, [pc, #0x600]        @ 0x9f28c <.text+0x8f18c>
   9ec88: e08f1001     	add	r1, pc, r1
   9ec8c: e7d12000     	ldrb	r2, [r1, r0]
   9ec90: e2222020     	eor	r2, r2, #32
   9ec94: e7c12000     	strb	r2, [r1, r0]
   9ec98: e2800001     	add	r0, r0, #1
   9ec9c: e350002e     	cmp	r0, #46
   9eca0: 1afffff9     	bne	0x9ec8c <.text+0x8eb8c> @ imm = #-0x1c
   9eca4: e59fc5e4     	ldr	r12, [pc, #0x5e4]       @ 0x9f290 <.text+0x8f190>
   9eca8: e79fc00c     	ldr	r12, [pc, r12]
   9ecac: e59c0000     	ldr	r0, [r12]
   9ecb0: e2401001     	sub	r1, r0, #1
   9ecb4: e0000190     	mul	r0, r0, r1
   9ecb8: e3100001     	tst	r0, #1
   9ecbc: e59c0000     	ldr	r0, [r12]
   9ecc0: e59fe5cc     	ldr	lr, [pc, #0x5cc]        @ 0x9f294 <.text+0x8f194>
   9ecc4: e2401001     	sub	r1, r0, #1
   9ecc8: e0000190     	mul	r0, r0, r1
   9eccc: e79fe00e     	ldr	lr, [pc, lr]
   9ecd0: e3100001     	tst	r0, #1
   9ecd4: 0a000002     	beq	0x9ece4 <.text+0x8ebe4> @ imm = #0x8
   9ecd8: e59e0000     	ldr	r0, [lr]
   9ecdc: e3500009     	cmp	r0, #9
   9ece0: cafffff5     	bgt	0x9ecbc <.text+0x8ebbc> @ imm = #-0x2c
   9ece4: e3a02000     	mov	r2, #0
   9ece8: e3520000     	cmp	r2, #0
   9ecec: 1a00001d     	bne	0x9ed68 <.text+0x8ec68> @ imm = #0x74
   9ecf0: e59f35a0     	ldr	r3, [pc, #0x5a0]        @ 0x9f298 <.text+0x8f198>
   9ecf4: e08f3003     	add	r3, pc, r3
   9ecf8: ea000002     	b	0x9ed08 <.text+0x8ec08> @ imm = #0x8
   9ecfc: e350000b     	cmp	r0, #11
   9ed00: e1a02000     	mov	r2, r0
   9ed04: 0a000017     	beq	0x9ed68 <.text+0x8ec68> @ imm = #0x5c
   9ed08: e59c0000     	ldr	r0, [r12]
   9ed0c: e2401001     	sub	r1, r0, #1
   9ed10: e0000190     	mul	r0, r0, r1
   9ed14: e3100001     	tst	r0, #1
   9ed18: 0a000002     	beq	0x9ed28 <.text+0x8ec28> @ imm = #0x8
   9ed1c: e59e0000     	ldr	r0, [lr]
   9ed20: e3500009     	cmp	r0, #9
   9ed24: ca00000b     	bgt	0x9ed58 <.text+0x8ec58> @ imm = #0x2c
   9ed28: e7d30002     	ldrb	r0, [r3, r2]
   9ed2c: e2200048     	eor	r0, r0, #72
   9ed30: e7c30002     	strb	r0, [r3, r2]
   9ed34: e59c0000     	ldr	r0, [r12]
   9ed38: e2401001     	sub	r1, r0, #1
   9ed3c: e0010190     	mul	r1, r0, r1
   9ed40: e2820001     	add	r0, r2, #1
   9ed44: e3110001     	tst	r1, #1
   9ed48: 0affffeb     	beq	0x9ecfc <.text+0x8ebfc> @ imm = #-0x54
   9ed4c: e59e1000     	ldr	r1, [lr]
   9ed50: e3510009     	cmp	r1, #9
   9ed54: daffffe8     	ble	0x9ecfc <.text+0x8ebfc> @ imm = #-0x60
   9ed58: e7d30002     	ldrb	r0, [r3, r2]
   9ed5c: e2200048     	eor	r0, r0, #72
   9ed60: e7c30002     	strb	r0, [r3, r2]
   9ed64: eaffffef     	b	0x9ed28 <.text+0x8ec28> @ imm = #-0x44
   9ed68: e59c0000     	ldr	r0, [r12]
   9ed6c: e2401001     	sub	r1, r0, #1
   9ed70: e0000190     	mul	r0, r0, r1
   9ed74: e3100001     	tst	r0, #1
   9ed78: e59c0000     	ldr	r0, [r12]
   9ed7c: e2401001     	sub	r1, r0, #1
   9ed80: e0000190     	mul	r0, r0, r1
   9ed84: e3100001     	tst	r0, #1
   9ed88: 0a000002     	beq	0x9ed98 <.text+0x8ec98> @ imm = #0x8
   9ed8c: e59e0000     	ldr	r0, [lr]
   9ed90: e3500009     	cmp	r0, #9
   9ed94: cafffff7     	bgt	0x9ed78 <.text+0x8ec78> @ imm = #-0x24
   9ed98: e3a02000     	mov	r2, #0
   9ed9c: e3520000     	cmp	r2, #0
   9eda0: 1a000007     	bne	0x9edc4 <.text+0x8ecc4> @ imm = #0x1c
   9eda4: e59f34f0     	ldr	r3, [pc, #0x4f0]        @ 0x9f29c <.text+0x8f19c>
   9eda8: e08f3003     	add	r3, pc, r3
   9edac: e7d30002     	ldrb	r0, [r3, r2]
   9edb0: e220005b     	eor	r0, r0, #91
   9edb4: e7c30002     	strb	r0, [r3, r2]
   9edb8: e2822001     	add	r2, r2, #1
   9edbc: e3520011     	cmp	r2, #17
   9edc0: 1afffff9     	bne	0x9edac <.text+0x8ecac> @ imm = #-0x1c
   9edc4: e3a02000     	mov	r2, #0
   9edc8: e3520000     	cmp	r2, #0
   9edcc: 1a000007     	bne	0x9edf0 <.text+0x8ecf0> @ imm = #0x1c
   9edd0: e59f34c8     	ldr	r3, [pc, #0x4c8]        @ 0x9f2a0 <.text+0x8f1a0>
   9edd4: e08f3003     	add	r3, pc, r3
   9edd8: e7d30002     	ldrb	r0, [r3, r2]
   9eddc: e2200025     	eor	r0, r0, #37
   9ede0: e7c30002     	strb	r0, [r3, r2]
   9ede4: e2822001     	add	r2, r2, #1
   9ede8: e3520007     	cmp	r2, #7
   9edec: 1afffff9     	bne	0x9edd8 <.text+0x8ecd8> @ imm = #-0x1c
   9edf0: e3a02000     	mov	r2, #0
   9edf4: e3520000     	cmp	r2, #0
   9edf8: 1a000007     	bne	0x9ee1c <.text+0x8ed1c> @ imm = #0x1c
   9edfc: e59f34a0     	ldr	r3, [pc, #0x4a0]        @ 0x9f2a4 <.text+0x8f1a4>
   9ee00: e08f3003     	add	r3, pc, r3
   9ee04: e7d30002     	ldrb	r0, [r3, r2]
   9ee08: e22000ee     	eor	r0, r0, #238
   9ee0c: e7c30002     	strb	r0, [r3, r2]
   9ee10: e2822001     	add	r2, r2, #1
   9ee14: e3520016     	cmp	r2, #22
   9ee18: 1afffff9     	bne	0x9ee04 <.text+0x8ed04> @ imm = #-0x1c
   9ee1c: e3a02000     	mov	r2, #0
   9ee20: e3520000     	cmp	r2, #0
   9ee24: 1a000007     	bne	0x9ee48 <.text+0x8ed48> @ imm = #0x1c
   9ee28: e59f3478     	ldr	r3, [pc, #0x478]        @ 0x9f2a8 <.text+0x8f1a8>
   9ee2c: e08f3003     	add	r3, pc, r3
   9ee30: e7d30002     	ldrb	r0, [r3, r2]
   9ee34: e1e00000     	mvn	r0, r0
   9ee38: e7c30002     	strb	r0, [r3, r2]
   9ee3c: e2822001     	add	r2, r2, #1
   9ee40: e3520017     	cmp	r2, #23
   9ee44: 1afffff9     	bne	0x9ee30 <.text+0x8ed30> @ imm = #-0x1c
   9ee48: e59f345c     	ldr	r3, [pc, #0x45c]        @ 0x9f2ac <.text+0x8f1ac>
   9ee4c: e3a02000     	mov	r2, #0
   9ee50: e08f3003     	add	r3, pc, r3
   9ee54: e7d30002     	ldrb	r0, [r3, r2]
   9ee58: e220009a     	eor	r0, r0, #154
   9ee5c: e7c30002     	strb	r0, [r3, r2]
   9ee60: e2822001     	add	r2, r2, #1
   9ee64: e3520010     	cmp	r2, #16
   9ee68: 1afffff9     	bne	0x9ee54 <.text+0x8ed54> @ imm = #-0x1c
   9ee6c: e3a02000     	mov	r2, #0
   9ee70: e3520000     	cmp	r2, #0
   9ee74: 1a000007     	bne	0x9ee98 <.text+0x8ed98> @ imm = #0x1c
   9ee78: e59f3430     	ldr	r3, [pc, #0x430]        @ 0x9f2b0 <.text+0x8f1b0>
   9ee7c: e08f3003     	add	r3, pc, r3
   9ee80: e7d30002     	ldrb	r0, [r3, r2]
   9ee84: e22000d5     	eor	r0, r0, #213
   9ee88: e7c30002     	strb	r0, [r3, r2]
   9ee8c: e2822001     	add	r2, r2, #1
   9ee90: e3520010     	cmp	r2, #16
   9ee94: 1afffff9     	bne	0x9ee80 <.text+0x8ed80> @ imm = #-0x1c
   9ee98: e3a02000     	mov	r2, #0
   9ee9c: e3520000     	cmp	r2, #0
   9eea0: 1a000007     	bne	0x9eec4 <.text+0x8edc4> @ imm = #0x1c
   9eea4: e59f3408     	ldr	r3, [pc, #0x408]        @ 0x9f2b4 <.text+0x8f1b4>
   9eea8: e08f3003     	add	r3, pc, r3
   9eeac: e7d30002     	ldrb	r0, [r3, r2]
   9eeb0: e22000ac     	eor	r0, r0, #172
   9eeb4: e7c30002     	strb	r0, [r3, r2]
   9eeb8: e2822001     	add	r2, r2, #1
   9eebc: e3520018     	cmp	r2, #24
   9eec0: 1afffff9     	bne	0x9eeac <.text+0x8edac> @ imm = #-0x1c
   9eec4: e3a02000     	mov	r2, #0
   9eec8: e3520000     	cmp	r2, #0
   9eecc: 1a00001d     	bne	0x9ef48 <.text+0x8ee48> @ imm = #0x74
   9eed0: e59f33e0     	ldr	r3, [pc, #0x3e0]        @ 0x9f2b8 <.text+0x8f1b8>
   9eed4: e08f3003     	add	r3, pc, r3
   9eed8: ea000002     	b	0x9eee8 <.text+0x8ede8> @ imm = #0x8
   9eedc: e3500014     	cmp	r0, #20
   9eee0: e1a02000     	mov	r2, r0
   9eee4: 0a000017     	beq	0x9ef48 <.text+0x8ee48> @ imm = #0x5c
   9eee8: e59c0000     	ldr	r0, [r12]
   9eeec: e2401001     	sub	r1, r0, #1
   9eef0: e0000190     	mul	r0, r0, r1
   9eef4: e3100001     	tst	r0, #1
   9eef8: 0a000002     	beq	0x9ef08 <.text+0x8ee08> @ imm = #0x8
   9eefc: e59e0000     	ldr	r0, [lr]
   9ef00: e3500009     	cmp	r0, #9
   9ef04: ca00000b     	bgt	0x9ef38 <.text+0x8ee38> @ imm = #0x2c
   9ef08: e7d30002     	ldrb	r0, [r3, r2]
   9ef0c: e22000f3     	eor	r0, r0, #243
   9ef10: e7c30002     	strb	r0, [r3, r2]
   9ef14: e59c0000     	ldr	r0, [r12]
   9ef18: e2401001     	sub	r1, r0, #1
   9ef1c: e0010190     	mul	r1, r0, r1
   9ef20: e2820001     	add	r0, r2, #1
   9ef24: e3110001     	tst	r1, #1
   9ef28: 0affffeb     	beq	0x9eedc <.text+0x8eddc> @ imm = #-0x54
   9ef2c: e59e1000     	ldr	r1, [lr]
   9ef30: e3510009     	cmp	r1, #9
   9ef34: daffffe8     	ble	0x9eedc <.text+0x8eddc> @ imm = #-0x60
   9ef38: e7d30002     	ldrb	r0, [r3, r2]
   9ef3c: e22000f3     	eor	r0, r0, #243
   9ef40: e7c30002     	strb	r0, [r3, r2]
   9ef44: eaffffef     	b	0x9ef08 <.text+0x8ee08> @ imm = #-0x44
   9ef48: e3a02000     	mov	r2, #0
   9ef4c: e3520000     	cmp	r2, #0
   9ef50: 1a000007     	bne	0x9ef74 <.text+0x8ee74> @ imm = #0x1c
   9ef54: e59f3360     	ldr	r3, [pc, #0x360]        @ 0x9f2bc <.text+0x8f1bc>
   9ef58: e08f3003     	add	r3, pc, r3
   9ef5c: e7d30002     	ldrb	r0, [r3, r2]
   9ef60: e22000ba     	eor	r0, r0, #186
   9ef64: e7c30002     	strb	r0, [r3, r2]
   9ef68: e2822001     	add	r2, r2, #1
   9ef6c: e352001e     	cmp	r2, #30
   9ef70: 1afffff9     	bne	0x9ef5c <.text+0x8ee5c> @ imm = #-0x1c
   9ef74: e59c0000     	ldr	r0, [r12]
   9ef78: e2401001     	sub	r1, r0, #1
   9ef7c: e0000190     	mul	r0, r0, r1
   9ef80: e3100001     	tst	r0, #1
   9ef84: e59c0000     	ldr	r0, [r12]
   9ef88: e2401001     	sub	r1, r0, #1
   9ef8c: e0000190     	mul	r0, r0, r1
   9ef90: e3100001     	tst	r0, #1
   9ef94: 0a000002     	beq	0x9efa4 <.text+0x8eea4> @ imm = #0x8
   9ef98: e59e0000     	ldr	r0, [lr]
   9ef9c: e3500009     	cmp	r0, #9
   9efa0: cafffff7     	bgt	0x9ef84 <.text+0x8ee84> @ imm = #-0x24
   9efa4: e3a02000     	mov	r2, #0
   9efa8: e3520000     	cmp	r2, #0
   9efac: 1a000007     	bne	0x9efd0 <.text+0x8eed0> @ imm = #0x1c
   9efb0: e59f3308     	ldr	r3, [pc, #0x308]        @ 0x9f2c0 <.text+0x8f1c0>
   9efb4: e08f3003     	add	r3, pc, r3
   9efb8: e7d30002     	ldrb	r0, [r3, r2]
   9efbc: e2200024     	eor	r0, r0, #36
   9efc0: e7c30002     	strb	r0, [r3, r2]
   9efc4: e2822001     	add	r2, r2, #1
   9efc8: e352002a     	cmp	r2, #42
   9efcc: 1afffff9     	bne	0x9efb8 <.text+0x8eeb8> @ imm = #-0x1c
   9efd0: e59c0000     	ldr	r0, [r12]
   9efd4: e2401001     	sub	r1, r0, #1
   9efd8: e0000190     	mul	r0, r0, r1
   9efdc: e3100001     	tst	r0, #1
   9efe0: e59c0000     	ldr	r0, [r12]
   9efe4: e2401001     	sub	r1, r0, #1
   9efe8: e0000190     	mul	r0, r0, r1
   9efec: e3100001     	tst	r0, #1
   9eff0: 0a000002     	beq	0x9f000 <.text+0x8ef00> @ imm = #0x8
   9eff4: e59e0000     	ldr	r0, [lr]
   9eff8: e3500009     	cmp	r0, #9
   9effc: cafffff7     	bgt	0x9efe0 <.text+0x8eee0> @ imm = #-0x24
   9f000: e3a02000     	mov	r2, #0
   9f004: e3520000     	cmp	r2, #0
   9f008: 1a000007     	bne	0x9f02c <.text+0x8ef2c> @ imm = #0x1c
   9f00c: e59f32b0     	ldr	r3, [pc, #0x2b0]        @ 0x9f2c4 <.text+0x8f1c4>
   9f010: e08f3003     	add	r3, pc, r3
   9f014: e7d30002     	ldrb	r0, [r3, r2]
   9f018: e2200005     	eor	r0, r0, #5
   9f01c: e7c30002     	strb	r0, [r3, r2]
   9f020: e2822001     	add	r2, r2, #1
   9f024: e3520022     	cmp	r2, #34
   9f028: 1afffff9     	bne	0x9f014 <.text+0x8ef14> @ imm = #-0x1c
   9f02c: e59f3294     	ldr	r3, [pc, #0x294]        @ 0x9f2c8 <.text+0x8f1c8>
   9f030: e3a02000     	mov	r2, #0
   9f034: e08f3003     	add	r3, pc, r3
   9f038: e7d30002     	ldrb	r0, [r3, r2]
   9f03c: e220002f     	eor	r0, r0, #47
   9f040: e7c30002     	strb	r0, [r3, r2]
   9f044: e2822001     	add	r2, r2, #1
   9f048: e352002a     	cmp	r2, #42
   9f04c: 1afffff9     	bne	0x9f038 <.text+0x8ef38> @ imm = #-0x1c
   9f050: e59f3274     	ldr	r3, [pc, #0x274]        @ 0x9f2cc <.text+0x8f1cc>
   9f054: e3a02000     	mov	r2, #0
   9f058: e08f3003     	add	r3, pc, r3
   9f05c: e7d30002     	ldrb	r0, [r3, r2]
   9f060: e22000c6     	eor	r0, r0, #198
   9f064: e7c30002     	strb	r0, [r3, r2]
   9f068: e2822001     	add	r2, r2, #1
   9f06c: e352002a     	cmp	r2, #42
   9f070: 1afffff9     	bne	0x9f05c <.text+0x8ef5c> @ imm = #-0x1c
   9f074: e3a02000     	mov	r2, #0
   9f078: e3520000     	cmp	r2, #0
   9f07c: 1a000007     	bne	0x9f0a0 <.text+0x8efa0> @ imm = #0x1c
   9f080: e59f3248     	ldr	r3, [pc, #0x248]        @ 0x9f2d0 <.text+0x8f1d0>
   9f084: e08f3003     	add	r3, pc, r3
   9f088: e7d30002     	ldrb	r0, [r3, r2]
   9f08c: e220008c     	eor	r0, r0, #140
   9f090: e7c30002     	strb	r0, [r3, r2]
   9f094: e2822001     	add	r2, r2, #1
   9f098: e352002a     	cmp	r2, #42
   9f09c: 1afffff9     	bne	0x9f088 <.text+0x8ef88> @ imm = #-0x1c
   9f0a0: e59c0000     	ldr	r0, [r12]
   9f0a4: e2401001     	sub	r1, r0, #1
   9f0a8: e0000190     	mul	r0, r0, r1
   9f0ac: e3100001     	tst	r0, #1
   9f0b0: e59c0000     	ldr	r0, [r12]
   9f0b4: e2401001     	sub	r1, r0, #1
   9f0b8: e0000190     	mul	r0, r0, r1
   9f0bc: e3100001     	tst	r0, #1
   9f0c0: 0a000002     	beq	0x9f0d0 <.text+0x8efd0> @ imm = #0x8
   9f0c4: e59e0000     	ldr	r0, [lr]
   9f0c8: e3500009     	cmp	r0, #9
   9f0cc: cafffff7     	bgt	0x9f0b0 <.text+0x8efb0> @ imm = #-0x24
   9f0d0: e3a02000     	mov	r2, #0
   9f0d4: e3520000     	cmp	r2, #0
   9f0d8: 1a000007     	bne	0x9f0fc <.text+0x8effc> @ imm = #0x1c
   9f0dc: e59f31f0     	ldr	r3, [pc, #0x1f0]        @ 0x9f2d4 <.text+0x8f1d4>
   9f0e0: e08f3003     	add	r3, pc, r3
   9f0e4: e7d30002     	ldrb	r0, [r3, r2]
   9f0e8: e22000e5     	eor	r0, r0, #229
   9f0ec: e7c30002     	strb	r0, [r3, r2]
   9f0f0: e2822001     	add	r2, r2, #1
   9f0f4: e3520025     	cmp	r2, #37
   9f0f8: 1afffff9     	bne	0x9f0e4 <.text+0x8efe4> @ imm = #-0x1c
   9f0fc: e3a02000     	mov	r2, #0
   9f100: e3520000     	cmp	r2, #0
   9f104: 1a000007     	bne	0x9f128 <.text+0x8f028> @ imm = #0x1c
   9f108: e59f31c8     	ldr	r3, [pc, #0x1c8]        @ 0x9f2d8 <.text+0x8f1d8>
   9f10c: e08f3003     	add	r3, pc, r3
   9f110: e7d30002     	ldrb	r0, [r3, r2]
   9f114: e22000d2     	eor	r0, r0, #210
   9f118: e7c30002     	strb	r0, [r3, r2]
   9f11c: e2822001     	add	r2, r2, #1
   9f120: e3520036     	cmp	r2, #54
   9f124: 1afffff9     	bne	0x9f110 <.text+0x8f010> @ imm = #-0x1c
   9f128: e59c0000     	ldr	r0, [r12]
   9f12c: e2401001     	sub	r1, r0, #1
   9f130: e0000190     	mul	r0, r0, r1
   9f134: e3100001     	tst	r0, #1
   9f138: e59c0000     	ldr	r0, [r12]
   9f13c: e2401001     	sub	r1, r0, #1
   9f140: e0000190     	mul	r0, r0, r1
   9f144: e3100001     	tst	r0, #1
   9f148: 0a000002     	beq	0x9f158 <.text+0x8f058> @ imm = #0x8
   9f14c: e59e0000     	ldr	r0, [lr]
   9f150: e3500009     	cmp	r0, #9
   9f154: cafffff7     	bgt	0x9f138 <.text+0x8f038> @ imm = #-0x24
   9f158: e3a02000     	mov	r2, #0
   9f15c: e3520000     	cmp	r2, #0
   9f160: 1a000007     	bne	0x9f184 <.text+0x8f084> @ imm = #0x1c
   9f164: e59f3170     	ldr	r3, [pc, #0x170]        @ 0x9f2dc <.text+0x8f1dc>
   9f168: e08f3003     	add	r3, pc, r3
   9f16c: e7d30002     	ldrb	r0, [r3, r2]
   9f170: e22000d9     	eor	r0, r0, #217
   9f174: e7c30002     	strb	r0, [r3, r2]
   9f178: e2822001     	add	r2, r2, #1
   9f17c: e3520022     	cmp	r2, #34
   9f180: 1afffff9     	bne	0x9f16c <.text+0x8f06c> @ imm = #-0x1c
   9f184: e3a02000     	mov	r2, #0
   9f188: e3520000     	cmp	r2, #0
   9f18c: 1a00001d     	bne	0x9f208 <.text+0x8f108> @ imm = #0x74
   9f190: e59f3148     	ldr	r3, [pc, #0x148]        @ 0x9f2e0 <.text+0x8f1e0>
   9f194: e08f3003     	add	r3, pc, r3
   9f198: ea000002     	b	0x9f1a8 <.text+0x8f0a8> @ imm = #0x8
   9f19c: e350001f     	cmp	r0, #31
   9f1a0: e1a02000     	mov	r2, r0
   9f1a4: 0a000017     	beq	0x9f208 <.text+0x8f108> @ imm = #0x5c
   9f1a8: e59c0000     	ldr	r0, [r12]
   9f1ac: e2401001     	sub	r1, r0, #1
   9f1b0: e0000190     	mul	r0, r0, r1
   9f1b4: e3100001     	tst	r0, #1
   9f1b8: 0a000002     	beq	0x9f1c8 <.text+0x8f0c8> @ imm = #0x8
   9f1bc: e59e0000     	ldr	r0, [lr]
   9f1c0: e3500009     	cmp	r0, #9
   9f1c4: ca00000b     	bgt	0x9f1f8 <.text+0x8f0f8> @ imm = #0x2c
   9f1c8: e7d30002     	ldrb	r0, [r3, r2]
   9f1cc: e22000bd     	eor	r0, r0, #189
   9f1d0: e7c30002     	strb	r0, [r3, r2]
   9f1d4: e59c0000     	ldr	r0, [r12]
   9f1d8: e2401001     	sub	r1, r0, #1
   9f1dc: e0010190     	mul	r1, r0, r1
   9f1e0: e2820001     	add	r0, r2, #1
   9f1e4: e3110001     	tst	r1, #1
   9f1e8: 0affffeb     	beq	0x9f19c <.text+0x8f09c> @ imm = #-0x54
   9f1ec: e59e1000     	ldr	r1, [lr]
   9f1f0: e3510009     	cmp	r1, #9
   9f1f4: daffffe8     	ble	0x9f19c <.text+0x8f09c> @ imm = #-0x60
   9f1f8: e7d30002     	ldrb	r0, [r3, r2]
   9f1fc: e22000bd     	eor	r0, r0, #189
   9f200: e7c30002     	strb	r0, [r3, r2]
   9f204: eaffffef     	b	0x9f1c8 <.text+0x8f0c8> @ imm = #-0x44
   9f208: e59c0000     	ldr	r0, [r12]
   9f20c: e2401001     	sub	r1, r0, #1
   9f210: e0000190     	mul	r0, r0, r1
   9f214: e3100001     	tst	r0, #1
   9f218: e59c0000     	ldr	r0, [r12]
   9f21c: e2401001     	sub	r1, r0, #1
   9f220: e0000190     	mul	r0, r0, r1
   9f224: e3100001     	tst	r0, #1
   9f228: 0a000002     	beq	0x9f238 <.text+0x8f138> @ imm = #0x8
   9f22c: e59e0000     	ldr	r0, [lr]
   9f230: e3500009     	cmp	r0, #9
   9f234: cafffff7     	bgt	0x9f218 <.text+0x8f118> @ imm = #-0x24
   9f238: e3a02000     	mov	r2, #0
   9f23c: e3520000     	cmp	r2, #0
   9f240: 1a000007     	bne	0x9f264 <.text+0x8f164> @ imm = #0x1c
   9f244: e59f3098     	ldr	r3, [pc, #0x98]         @ 0x9f2e4 <.text+0x8f1e4>
   9f248: e08f3003     	add	r3, pc, r3
   9f24c: e7d30002     	ldrb	r0, [r3, r2]
   9f250: e2200073     	eor	r0, r0, #115
   9f254: e7c30002     	strb	r0, [r3, r2]
   9f258: e2822001     	add	r2, r2, #1
   9f25c: e3520023     	cmp	r2, #35
   9f260: 1afffff9     	bne	0x9f24c <.text+0x8f14c> @ imm = #-0x1c
   9f264: e59c0000     	ldr	r0, [r12]
   9f268: e2401001     	sub	r1, r0, #1
   9f26c: e0000190     	mul	r0, r0, r1
   9f270: e3100001     	tst	r0, #1
   9f274: 08bd8800     	popeq	{r11, pc}
   9f278: e59e0000     	ldr	r0, [lr]
   9f27c: e3500009     	cmp	r0, #9
   9f280: cafffff7     	bgt	0x9f264 <.text+0x8f164> @ imm = #-0x24
   9f284: e8bd8800     	pop	{r11, pc}
   9f288: 00548c69     	subseq	r8, r4, r9, ror #24
   9f28c: 00548c46     	subseq	r8, r4, r6, asr #24
   9f290: 005406b4     	ldrheq	r0, [r4], #-100
   9f294: 00540a00     	subseq	r0, r4, r0, lsl #20
   9f298: 00548c08     	subseq	r8, r4, r8, lsl #24
   9f29c: 00548b5f     	subseq	r8, r4, pc, asr r11
   9f2a0: 00548b44     	subseq	r8, r4, r4, asr #22
   9f2a4: 00548b1f     	subseq	r8, r4, pc, lsl r11
   9f2a8: 00548b09     	subseq	r8, r4, r9, lsl #22
   9f2ac: 00548afc     	ldrsheq	r8, [r4], #-172
   9f2b0: 00548ae0     	subseq	r8, r4, r0, ror #21
   9f2b4: 00548ac4     	subseq	r8, r4, r4, asr #21
   9f2b8: 00548ab0     	ldrheq	r8, [r4], #-160
   9f2bc: 00548a40     	subseq	r8, r4, r0, asr #20
   9f2c0: 00548a02     	subseq	r8, r4, r2, lsl #20
   9f2c4: 005489d0     	ldrsbeq	r8, [r4], #-144
   9f2c8: 005489ce     	subseq	r8, r4, lr, asr #19
   9f2cc: 005489d4     	ldrsbeq	r8, [r4], #-148
   9f2d0: 005489d2     	ldrsbeq	r8, [r4], #-146
   9f2d4: 005489a0     	subseq	r8, r4, r0, lsr #19
   9f2d8: 00548999     	<unknown>
   9f2dc: 00548973     	subseq	r8, r4, r3, ror r9
   9f2e0: 00548969     	subseq	r8, r4, r9, ror #18
   9f2e4: 005488d4     	ldrsbeq	r8, [r4], #-132

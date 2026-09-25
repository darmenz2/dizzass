
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   32f74: e5905024     	ldr	r5, [r0, #0x24]
   32f78: e1a08000     	mov	r8, r0
   32f7c: e59500e8     	ldr	r0, [r5, #0xe8]
   32f80: e1500002     	cmp	r0, r2
   32f84: 0a00000e     	beq	0x32fc4 <.text+0x22ec4> @ imm = #0x38
   32f88: e59f9600     	ldr	r9, [pc, #0x600]        @ 0x33590 <.text+0x23490>
   32f8c: e1a04001     	mov	r4, r1
   32f90: e1a06002     	mov	r6, r2
   32f94: e79f9009     	ldr	r9, [pc, r9]
   32f98: e5990000     	ldr	r0, [r9]
   32f9c: e2401001     	sub	r1, r0, #1
   32fa0: e0000190     	mul	r0, r0, r1
   32fa4: e3100001     	tst	r0, #1
   32fa8: 0a000014     	beq	0x33000 <.text+0x22f00> @ imm = #0x50
   32fac: e59f05e0     	ldr	r0, [pc, #0x5e0]        @ 0x33594 <.text+0x23494>
   32fb0: e79f0000     	ldr	r0, [pc, r0]
   32fb4: e5900000     	ldr	r0, [r0]
   32fb8: e3500009     	cmp	r0, #9
   32fbc: ca00002b     	bgt	0x33070 <.text+0x22f70> @ imm = #0xac
   32fc0: ea00000e     	b	0x33000 <.text+0x22f00> @ imm = #0x38
   32fc4: e59f05b4     	ldr	r0, [pc, #0x5b4]        @ 0x33580 <.text+0x23480>
   32fc8: e3a07003     	mov	r7, #3
   32fcc: e59f15b0     	ldr	r1, [pc, #0x5b0]        @ 0x33584 <.text+0x23484>
   32fd0: e59f25b0     	ldr	r2, [pc, #0x5b0]        @ 0x33588 <.text+0x23488>
   32fd4: e08f0000     	add	r0, pc, r0
   32fd8: e59f35ac     	ldr	r3, [pc, #0x5ac]        @ 0x3358c <.text+0x2348c>
   32fdc: e08f1001     	add	r1, pc, r1
   32fe0: e08f2002     	add	r2, pc, r2
   32fe4: e58d7000     	str	r7, [sp]
   32fe8: e08f3003     	add	r3, pc, r3
   32fec: e58d3004     	str	r3, [sp, #0x4]
   32ff0: e3a03ec7     	mov	r3, #3184
   32ff4: eb031c32     	bl	0xfa0c4 <.text+0xe9fc4> @ imm = #0xc70c8
   32ff8: e3a07000     	mov	r7, #0
   32ffc: ea000147     	b	0x33520 <.text+0x23420> @ imm = #0x51c
   33000: e3a00000     	mov	r0, #0
   33004: e58560e8     	str	r6, [r5, #0xe8]
   33008: e3a07000     	mov	r7, #0
   3300c: ebffd889     	bl	0x29238 <.text+0x19138> @ imm = #-0x9ddc
   33010: e5900014     	ldr	r0, [r0, #0x14]
   33014: e590a018     	ldr	r10, [r0, #0x18]
   33018: e3a00000     	mov	r0, #0
   3301c: ebffd885     	bl	0x29238 <.text+0x19138> @ imm = #-0x9dec
   33020: e5900014     	ldr	r0, [r0, #0x14]
   33024: e584604c     	str	r6, [r4, #0x4c]
   33028: e5901208     	ldr	r1, [r0, #0x208]
   3302c: e1a00004     	mov	r0, r4
   33030: e12fff31     	blx	r1
   33034: e5990000     	ldr	r0, [r9]
   33038: e2401001     	sub	r1, r0, #1
   3303c: e0020190     	mul	r2, r0, r1
   33040: e59a1034     	ldr	r1, [r10, #0x34]
   33044: e594013c     	ldr	r0, [r4, #0x13c]
   33048: e3510001     	cmp	r1, #1
   3304c: e3a01000     	mov	r1, #0
   33050: 030f1fff     	movweq	r1, #0xffff
   33054: e3120001     	tst	r2, #1
   33058: 0a00000f     	beq	0x3309c <.text+0x22f9c> @ imm = #0x3c
   3305c: e59f2534     	ldr	r2, [pc, #0x534]        @ 0x33598 <.text+0x23498>
   33060: e79f2002     	ldr	r2, [pc, r2]
   33064: e5922000     	ldr	r2, [r2]
   33068: e3520009     	cmp	r2, #9
   3306c: da00000a     	ble	0x3309c <.text+0x22f9c> @ imm = #0x28
   33070: e3a00000     	mov	r0, #0
   33074: e58560e8     	str	r6, [r5, #0xe8]
   33078: ebffd86e     	bl	0x29238 <.text+0x19138> @ imm = #-0x9e48
   3307c: e3a00000     	mov	r0, #0
   33080: ebffd86c     	bl	0x29238 <.text+0x19138> @ imm = #-0x9e50
   33084: e5900014     	ldr	r0, [r0, #0x14]
   33088: e584604c     	str	r6, [r4, #0x4c]
   3308c: e5901208     	ldr	r1, [r0, #0x208]
   33090: e1a00004     	mov	r0, r4
   33094: e12fff31     	blx	r1
   33098: eaffffd8     	b	0x33000 <.text+0x22f00> @ imm = #-0xa0
   3309c: e1500001     	cmp	r0, r1
   330a0: 8a00011e     	bhi	0x33520 <.text+0x23420> @ imm = #0x478

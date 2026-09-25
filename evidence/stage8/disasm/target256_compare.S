
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   10c1c: e92d4c70     	push	{r4, r5, r6, r10, r11, lr}
   10c20: e28db010     	add	r11, sp, #16
   10c24: e59fc1e4     	ldr	r12, [pc, #0x1e4]       @ 0x10e10 <.text+0xd10>
   10c28: e1a06000     	mov	r6, r0
   10c2c: e79fc00c     	ldr	r12, [pc, r12]
   10c30: e59c0000     	ldr	r0, [r12]
   10c34: e2402001     	sub	r2, r0, #1
   10c38: e0000290     	mul	r0, r0, r2
   10c3c: e3100001     	tst	r0, #1
   10c40: e59c0000     	ldr	r0, [r12]
   10c44: e59f31c8     	ldr	r3, [pc, #0x1c8]        @ 0x10e14 <.text+0xd14>
   10c48: e2402001     	sub	r2, r0, #1
   10c4c: e0000290     	mul	r0, r0, r2
   10c50: e79f3003     	ldr	r3, [pc, r3]
   10c54: e591401c     	ldr	r4, [r1, #0x1c]
   10c58: e596201c     	ldr	r2, [r6, #0x1c]
   10c5c: e3100001     	tst	r0, #1
   10c60: 0a000002     	beq	0x10c70 <.text+0xb70>   @ imm = #0x8
   10c64: e5930000     	ldr	r0, [r3]
   10c68: e3500009     	cmp	r0, #9
   10c6c: cafffff3     	bgt	0x10c40 <.text+0xb40>   @ imm = #-0x34
   10c70: e3a00000     	mov	r0, #0
   10c74: e1520004     	cmp	r2, r4
   10c78: 8a00004b     	bhi	0x10dac <.text+0xcac>   @ imm = #0x12c
   10c7c: 3a000049     	blo	0x10da8 <.text+0xca8>   @ imm = #0x124
   10c80: e59c2000     	ldr	r2, [r12]
   10c84: e2424001     	sub	r4, r2, #1
   10c88: e0020492     	mul	r2, r2, r4
   10c8c: e3120001     	tst	r2, #1
   10c90: e59c2000     	ldr	r2, [r12]
   10c94: e2424001     	sub	r4, r2, #1
   10c98: e0050492     	mul	r5, r2, r4
   10c9c: e5912018     	ldr	r2, [r1, #0x18]
   10ca0: e5964018     	ldr	r4, [r6, #0x18]
   10ca4: e3150001     	tst	r5, #1
   10ca8: 0a000002     	beq	0x10cb8 <.text+0xbb8>   @ imm = #0x8
   10cac: e5935000     	ldr	r5, [r3]
   10cb0: e3550009     	cmp	r5, #9
   10cb4: cafffff5     	bgt	0x10c90 <.text+0xb90>   @ imm = #-0x2c
   10cb8: e1540002     	cmp	r4, r2
   10cbc: 8a00003a     	bhi	0x10dac <.text+0xcac>   @ imm = #0xe8
   10cc0: 3a000038     	blo	0x10da8 <.text+0xca8>   @ imm = #0xe0
   10cc4: e591e014     	ldr	lr, [r1, #0x14]
   10cc8: e5964014     	ldr	r4, [r6, #0x14]
   10ccc: e154000e     	cmp	r4, lr
   10cd0: 8a000035     	bhi	0x10dac <.text+0xcac>   @ imm = #0xd4
   10cd4: e59c2000     	ldr	r2, [r12]
   10cd8: e2425001     	sub	r5, r2, #1
   10cdc: e0020592     	mul	r2, r2, r5
   10ce0: e3120001     	tst	r2, #1
   10ce4: e59c2000     	ldr	r2, [r12]
   10ce8: e2425001     	sub	r5, r2, #1
   10cec: e0020592     	mul	r2, r2, r5
   10cf0: e3120001     	tst	r2, #1
   10cf4: 0a000002     	beq	0x10d04 <.text+0xc04>   @ imm = #0x8
   10cf8: e5932000     	ldr	r2, [r3]
   10cfc: e3520009     	cmp	r2, #9
   10d00: cafffff7     	bgt	0x10ce4 <.text+0xbe4>   @ imm = #-0x24
   10d04: e154000e     	cmp	r4, lr
   10d08: 3a000026     	blo	0x10da8 <.text+0xca8>   @ imm = #0x98
   10d0c: e5912010     	ldr	r2, [r1, #0x10]
   10d10: e5965010     	ldr	r5, [r6, #0x10]
   10d14: e1550002     	cmp	r5, r2
   10d18: 8a000023     	bhi	0x10dac <.text+0xcac>   @ imm = #0x8c
   10d1c: 3a000021     	blo	0x10da8 <.text+0xca8>   @ imm = #0x84
   10d20: e59c2000     	ldr	r2, [r12]
   10d24: e2425001     	sub	r5, r2, #1
   10d28: e0020592     	mul	r2, r2, r5
   10d2c: e3120001     	tst	r2, #1
   10d30: e59c2000     	ldr	r2, [r12]
   10d34: e596400c     	ldr	r4, [r6, #0xc]
   10d38: e2425001     	sub	r5, r2, #1
   10d3c: e0050592     	mul	r5, r2, r5
   10d40: e591200c     	ldr	r2, [r1, #0xc]
   10d44: e3150001     	tst	r5, #1
   10d48: 0a000002     	beq	0x10d58 <.text+0xc58>   @ imm = #0x8
   10d4c: e5935000     	ldr	r5, [r3]
   10d50: e3550009     	cmp	r5, #9
   10d54: cafffff5     	bgt	0x10d30 <.text+0xc30>   @ imm = #-0x2c
   10d58: e1540002     	cmp	r4, r2
   10d5c: 8a000012     	bhi	0x10dac <.text+0xcac>   @ imm = #0x48
   10d60: 3a000010     	blo	0x10da8 <.text+0xca8>   @ imm = #0x40
   10d64: e59c2000     	ldr	r2, [r12]
   10d68: e2425001     	sub	r5, r2, #1
   10d6c: e0020592     	mul	r2, r2, r5
   10d70: e3120001     	tst	r2, #1
   10d74: e59c2000     	ldr	r2, [r12]
   10d78: e5964008     	ldr	r4, [r6, #0x8]
   10d7c: e2425001     	sub	r5, r2, #1
   10d80: e0050592     	mul	r5, r2, r5
   10d84: e5912008     	ldr	r2, [r1, #0x8]
   10d88: e3150001     	tst	r5, #1
   10d8c: 0a000002     	beq	0x10d9c <.text+0xc9c>   @ imm = #0x8
   10d90: e5935000     	ldr	r5, [r3]
   10d94: e3550009     	cmp	r5, #9
   10d98: cafffff5     	bgt	0x10d74 <.text+0xc74>   @ imm = #-0x2c
   10d9c: e1540002     	cmp	r4, r2
   10da0: 8a000001     	bhi	0x10dac <.text+0xcac>   @ imm = #0x4
   10da4: 2a000001     	bhs	0x10db0 <.text+0xcb0>   @ imm = #0x4
   10da8: e3a00001     	mov	r0, #1
   10dac: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
   10db0: e59c2000     	ldr	r2, [r12]
   10db4: e2425001     	sub	r5, r2, #1
   10db8: e0020592     	mul	r2, r2, r5
   10dbc: e3120001     	tst	r2, #1
   10dc0: e59c2000     	ldr	r2, [r12]
   10dc4: e5964004     	ldr	r4, [r6, #0x4]
   10dc8: e2425001     	sub	r5, r2, #1
   10dcc: e0050592     	mul	r5, r2, r5
   10dd0: e5912004     	ldr	r2, [r1, #0x4]
   10dd4: e3150001     	tst	r5, #1
   10dd8: 0a000002     	beq	0x10de8 <.text+0xce8>   @ imm = #0x8
   10ddc: e5935000     	ldr	r5, [r3]
   10de0: e3550009     	cmp	r5, #9
   10de4: cafffff5     	bgt	0x10dc0 <.text+0xcc0>   @ imm = #-0x2c
   10de8: e1540002     	cmp	r4, r2
   10dec: 8affffee     	bhi	0x10dac <.text+0xcac>   @ imm = #-0x48
   10df0: e3a00001     	mov	r0, #1
   10df4: 3affffec     	blo	0x10dac <.text+0xcac>   @ imm = #-0x50
   10df8: e5911000     	ldr	r1, [r1]
   10dfc: e3a00000     	mov	r0, #0
   10e00: e5962000     	ldr	r2, [r6]
   10e04: e1520001     	cmp	r2, r1
   10e08: 93000001     	movwls	r0, #0x1
   10e0c: e8bd8c70     	pop	{r4, r5, r6, r10, r11, pc}
   10e10: 005ce4a0     	subseq	lr, r12, r0, lsr #9
   10e14: 005ced8c     	subseq	lr, r12, r12, lsl #27
   10e18: e92d4c10     	push	{r4, r10, r11, lr}

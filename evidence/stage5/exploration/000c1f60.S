
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c1f60: e92d4800     	push	{r11, lr}
   c1f64: e3a00000     	mov	r0, #0
   c1f68: e3500000     	cmp	r0, #0
   c1f6c: 1a000021     	bne	0xc1ff8 <.text+0xb1ef8> @ imm = #0x84
   c1f70: e59fe4e8     	ldr	lr, [pc, #0x4e8]        @ 0xc2460 <.text+0xb2360>
   c1f74: e79fe00e     	ldr	lr, [pc, lr]
   c1f78: e59fc4e4     	ldr	r12, [pc, #0x4e4]       @ 0xc2464 <.text+0xb2364>
   c1f7c: e79fc00c     	ldr	r12, [pc, r12]
   c1f80: e59f34e0     	ldr	r3, [pc, #0x4e0]        @ 0xc2468 <.text+0xb2368>
   c1f84: e08f3003     	add	r3, pc, r3
   c1f88: ea000002     	b	0xc1f98 <.text+0xb1e98> @ imm = #0x8
   c1f8c: e352000d     	cmp	r2, #13
   c1f90: e1a00002     	mov	r0, r2
   c1f94: 0a000017     	beq	0xc1ff8 <.text+0xb1ef8> @ imm = #0x5c
   c1f98: e59e2000     	ldr	r2, [lr]
   c1f9c: e2421001     	sub	r1, r2, #1
   c1fa0: e0010192     	mul	r1, r2, r1
   c1fa4: e3110001     	tst	r1, #1
   c1fa8: 0a000002     	beq	0xc1fb8 <.text+0xb1eb8> @ imm = #0x8
   c1fac: e59c1000     	ldr	r1, [r12]
   c1fb0: e3510009     	cmp	r1, #9
   c1fb4: ca00000b     	bgt	0xc1fe8 <.text+0xb1ee8> @ imm = #0x2c
   c1fb8: e7d31000     	ldrb	r1, [r3, r0]
   c1fbc: e22110a7     	eor	r1, r1, #167
   c1fc0: e7c31000     	strb	r1, [r3, r0]
   c1fc4: e59e1000     	ldr	r1, [lr]
   c1fc8: e2412001     	sub	r2, r1, #1
   c1fcc: e0010291     	mul	r1, r1, r2
   c1fd0: e2802001     	add	r2, r0, #1
   c1fd4: e3110001     	tst	r1, #1
   c1fd8: 0affffeb     	beq	0xc1f8c <.text+0xb1e8c> @ imm = #-0x54
   c1fdc: e59c1000     	ldr	r1, [r12]
   c1fe0: e3510009     	cmp	r1, #9
   c1fe4: daffffe8     	ble	0xc1f8c <.text+0xb1e8c> @ imm = #-0x60
   c1fe8: e7d31000     	ldrb	r1, [r3, r0]
   c1fec: e22110a7     	eor	r1, r1, #167
   c1ff0: e7c31000     	strb	r1, [r3, r0]
   c1ff4: eaffffef     	b	0xc1fb8 <.text+0xb1eb8> @ imm = #-0x44
   c1ff8: e59fe46c     	ldr	lr, [pc, #0x46c]        @ 0xc246c <.text+0xb236c>
   c1ffc: e79fe00e     	ldr	lr, [pc, lr]
   c2000: e59e1000     	ldr	r1, [lr]
   c2004: e2412001     	sub	r2, r1, #1
   c2008: e0010291     	mul	r1, r1, r2
   c200c: e3110001     	tst	r1, #1
   c2010: e59e1000     	ldr	r1, [lr]
   c2014: e59fc454     	ldr	r12, [pc, #0x454]       @ 0xc2470 <.text+0xb2370>
   c2018: e2412001     	sub	r2, r1, #1
   c201c: e0010291     	mul	r1, r1, r2
   c2020: e79fc00c     	ldr	r12, [pc, r12]
   c2024: e3110001     	tst	r1, #1
   c2028: 0a000002     	beq	0xc2038 <.text+0xb1f38> @ imm = #0x8
   c202c: e59c1000     	ldr	r1, [r12]
   c2030: e3510009     	cmp	r1, #9
   c2034: cafffff5     	bgt	0xc2010 <.text+0xb1f10> @ imm = #-0x2c
   c2038: e3a02000     	mov	r2, #0
   c203c: e3520000     	cmp	r2, #0
   c2040: 1a000002     	bne	0xc2050 <.text+0xb1f50> @ imm = #0x8
   c2044: e2822001     	add	r2, r2, #1
   c2048: e3520032     	cmp	r2, #50
   c204c: 1afffffc     	bne	0xc2044 <.text+0xb1f44> @ imm = #-0x10
   c2050: e3a02000     	mov	r2, #0
   c2054: e3520000     	cmp	r2, #0
   c2058: 1a00001d     	bne	0xc20d4 <.text+0xb1fd4> @ imm = #0x74
   c205c: e59f3410     	ldr	r3, [pc, #0x410]        @ 0xc2474 <.text+0xb2374>
   c2060: e08f3003     	add	r3, pc, r3
   c2064: ea000002     	b	0xc2074 <.text+0xb1f74> @ imm = #0x8
   c2068: e3510007     	cmp	r1, #7
   c206c: e1a02001     	mov	r2, r1
   c2070: 0a000017     	beq	0xc20d4 <.text+0xb1fd4> @ imm = #0x5c
   c2074: e59e1000     	ldr	r1, [lr]
   c2078: e2410001     	sub	r0, r1, #1
   c207c: e0000091     	mul	r0, r1, r0
   c2080: e3100001     	tst	r0, #1
   c2084: 0a000002     	beq	0xc2094 <.text+0xb1f94> @ imm = #0x8
   c2088: e59c0000     	ldr	r0, [r12]
   c208c: e3500009     	cmp	r0, #9
   c2090: ca00000b     	bgt	0xc20c4 <.text+0xb1fc4> @ imm = #0x2c
   c2094: e7d30002     	ldrb	r0, [r3, r2]
   c2098: e22000a2     	eor	r0, r0, #162
   c209c: e7c30002     	strb	r0, [r3, r2]
   c20a0: e59e0000     	ldr	r0, [lr]
   c20a4: e2401001     	sub	r1, r0, #1
   c20a8: e0000190     	mul	r0, r0, r1
   c20ac: e2821001     	add	r1, r2, #1
   c20b0: e3100001     	tst	r0, #1
   c20b4: 0affffeb     	beq	0xc2068 <.text+0xb1f68> @ imm = #-0x54
   c20b8: e59c0000     	ldr	r0, [r12]
   c20bc: e3500009     	cmp	r0, #9
   c20c0: daffffe8     	ble	0xc2068 <.text+0xb1f68> @ imm = #-0x60
   c20c4: e7d30002     	ldrb	r0, [r3, r2]
   c20c8: e22000a2     	eor	r0, r0, #162
   c20cc: e7c30002     	strb	r0, [r3, r2]
   c20d0: eaffffef     	b	0xc2094 <.text+0xb1f94> @ imm = #-0x44
   c20d4: e3a02000     	mov	r2, #0
   c20d8: e3520000     	cmp	r2, #0
   c20dc: 1a000007     	bne	0xc2100 <.text+0xb2000> @ imm = #0x1c
   c20e0: e59f3390     	ldr	r3, [pc, #0x390]        @ 0xc2478 <.text+0xb2378>
   c20e4: e08f3003     	add	r3, pc, r3
   c20e8: e7d30002     	ldrb	r0, [r3, r2]
   c20ec: e22000fe     	eor	r0, r0, #254
   c20f0: e7c30002     	strb	r0, [r3, r2]
   c20f4: e2822001     	add	r2, r2, #1
   c20f8: e352000b     	cmp	r2, #11
   c20fc: 1afffff9     	bne	0xc20e8 <.text+0xb1fe8> @ imm = #-0x1c
   c2100: e3a02000     	mov	r2, #0
   c2104: e3520000     	cmp	r2, #0
   c2108: 1a00001d     	bne	0xc2184 <.text+0xb2084> @ imm = #0x74
   c210c: e59f3368     	ldr	r3, [pc, #0x368]        @ 0xc247c <.text+0xb237c>
   c2110: e08f3003     	add	r3, pc, r3
   c2114: ea000002     	b	0xc2124 <.text+0xb2024> @ imm = #0x8
   c2118: e3510017     	cmp	r1, #23
   c211c: e1a02001     	mov	r2, r1
   c2120: 0a000017     	beq	0xc2184 <.text+0xb2084> @ imm = #0x5c
   c2124: e59e0000     	ldr	r0, [lr]
   c2128: e2401001     	sub	r1, r0, #1
   c212c: e0000190     	mul	r0, r0, r1
   c2130: e3100001     	tst	r0, #1
   c2134: 0a000002     	beq	0xc2144 <.text+0xb2044> @ imm = #0x8
   c2138: e59c0000     	ldr	r0, [r12]
   c213c: e3500009     	cmp	r0, #9
   c2140: ca00000b     	bgt	0xc2174 <.text+0xb2074> @ imm = #0x2c
   c2144: e7d30002     	ldrb	r0, [r3, r2]
   c2148: e2200022     	eor	r0, r0, #34
   c214c: e7c30002     	strb	r0, [r3, r2]
   c2150: e59e0000     	ldr	r0, [lr]
   c2154: e2401001     	sub	r1, r0, #1
   c2158: e0000190     	mul	r0, r0, r1
   c215c: e2821001     	add	r1, r2, #1
   c2160: e3100001     	tst	r0, #1
   c2164: 0affffeb     	beq	0xc2118 <.text+0xb2018> @ imm = #-0x54
   c2168: e59c0000     	ldr	r0, [r12]
   c216c: e3500009     	cmp	r0, #9
   c2170: daffffe8     	ble	0xc2118 <.text+0xb2018> @ imm = #-0x60
   c2174: e7d30002     	ldrb	r0, [r3, r2]
   c2178: e2200022     	eor	r0, r0, #34
   c217c: e7c30002     	strb	r0, [r3, r2]
   c2180: eaffffef     	b	0xc2144 <.text+0xb2044> @ imm = #-0x44
   c2184: e3a02000     	mov	r2, #0
   c2188: e3520000     	cmp	r2, #0
   c218c: 1a00001d     	bne	0xc2208 <.text+0xb2108> @ imm = #0x74
   c2190: e59f32e8     	ldr	r3, [pc, #0x2e8]        @ 0xc2480 <.text+0xb2380>
   c2194: e08f3003     	add	r3, pc, r3
   c2198: ea000002     	b	0xc21a8 <.text+0xb20a8> @ imm = #0x8
   c219c: e3510025     	cmp	r1, #37
   c21a0: e1a02001     	mov	r2, r1
   c21a4: 0a000017     	beq	0xc2208 <.text+0xb2108> @ imm = #0x5c
   c21a8: e59e0000     	ldr	r0, [lr]
   c21ac: e2401001     	sub	r1, r0, #1
   c21b0: e0000190     	mul	r0, r0, r1
   c21b4: e3100001     	tst	r0, #1
   c21b8: 0a000002     	beq	0xc21c8 <.text+0xb20c8> @ imm = #0x8
   c21bc: e59c0000     	ldr	r0, [r12]
   c21c0: e3500009     	cmp	r0, #9
   c21c4: ca00000b     	bgt	0xc21f8 <.text+0xb20f8> @ imm = #0x2c
   c21c8: e7d30002     	ldrb	r0, [r3, r2]
   c21cc: e22000ae     	eor	r0, r0, #174
   c21d0: e7c30002     	strb	r0, [r3, r2]
   c21d4: e59e0000     	ldr	r0, [lr]
   c21d8: e2401001     	sub	r1, r0, #1
   c21dc: e0000190     	mul	r0, r0, r1
   c21e0: e2821001     	add	r1, r2, #1
   c21e4: e3100001     	tst	r0, #1
   c21e8: 0affffeb     	beq	0xc219c <.text+0xb209c> @ imm = #-0x54
   c21ec: e59c0000     	ldr	r0, [r12]
   c21f0: e3500009     	cmp	r0, #9
   c21f4: daffffe8     	ble	0xc219c <.text+0xb209c> @ imm = #-0x60
   c21f8: e7d30002     	ldrb	r0, [r3, r2]
   c21fc: e22000ae     	eor	r0, r0, #174
   c2200: e7c30002     	strb	r0, [r3, r2]
   c2204: eaffffef     	b	0xc21c8 <.text+0xb20c8> @ imm = #-0x44
   c2208: e59e0000     	ldr	r0, [lr]
   c220c: e2401001     	sub	r1, r0, #1
   c2210: e0000190     	mul	r0, r0, r1
   c2214: e3100001     	tst	r0, #1
   c2218: e59e0000     	ldr	r0, [lr]
   c221c: e2401001     	sub	r1, r0, #1
   c2220: e0000190     	mul	r0, r0, r1
   c2224: e3100001     	tst	r0, #1
   c2228: 0a000002     	beq	0xc2238 <.text+0xb2138> @ imm = #0x8
   c222c: e59c0000     	ldr	r0, [r12]
   c2230: e3500009     	cmp	r0, #9
   c2234: cafffff7     	bgt	0xc2218 <.text+0xb2118> @ imm = #-0x24
   c2238: e3a02000     	mov	r2, #0
   c223c: e3520000     	cmp	r2, #0
   c2240: 1a00001d     	bne	0xc22bc <.text+0xb21bc> @ imm = #0x74
   c2244: e59f3238     	ldr	r3, [pc, #0x238]        @ 0xc2484 <.text+0xb2384>
   c2248: e08f3003     	add	r3, pc, r3
   c224c: ea000002     	b	0xc225c <.text+0xb215c> @ imm = #0x8
   c2250: e351002e     	cmp	r1, #46
   c2254: e1a02001     	mov	r2, r1
   c2258: 0a000017     	beq	0xc22bc <.text+0xb21bc> @ imm = #0x5c
   c225c: e59e0000     	ldr	r0, [lr]
   c2260: e2401001     	sub	r1, r0, #1
   c2264: e0000190     	mul	r0, r0, r1
   c2268: e3100001     	tst	r0, #1
   c226c: 0a000002     	beq	0xc227c <.text+0xb217c> @ imm = #0x8
   c2270: e59c0000     	ldr	r0, [r12]
   c2274: e3500009     	cmp	r0, #9
   c2278: ca00000b     	bgt	0xc22ac <.text+0xb21ac> @ imm = #0x2c
   c227c: e7d30002     	ldrb	r0, [r3, r2]
   c2280: e22000d9     	eor	r0, r0, #217
   c2284: e7c30002     	strb	r0, [r3, r2]
   c2288: e59e0000     	ldr	r0, [lr]
   c228c: e2401001     	sub	r1, r0, #1
   c2290: e0000190     	mul	r0, r0, r1
   c2294: e2821001     	add	r1, r2, #1
   c2298: e3100001     	tst	r0, #1
   c229c: 0affffeb     	beq	0xc2250 <.text+0xb2150> @ imm = #-0x54
   c22a0: e59c0000     	ldr	r0, [r12]
   c22a4: e3500009     	cmp	r0, #9
   c22a8: daffffe8     	ble	0xc2250 <.text+0xb2150> @ imm = #-0x60
   c22ac: e7d30002     	ldrb	r0, [r3, r2]
   c22b0: e22000d9     	eor	r0, r0, #217
   c22b4: e7c30002     	strb	r0, [r3, r2]
   c22b8: eaffffef     	b	0xc227c <.text+0xb217c> @ imm = #-0x44
   c22bc: e59e0000     	ldr	r0, [lr]
   c22c0: e2401001     	sub	r1, r0, #1
   c22c4: e0000190     	mul	r0, r0, r1
   c22c8: e3100001     	tst	r0, #1
   c22cc: e59e0000     	ldr	r0, [lr]
   c22d0: e2401001     	sub	r1, r0, #1
   c22d4: e0000190     	mul	r0, r0, r1
   c22d8: e3100001     	tst	r0, #1
   c22dc: 0a000002     	beq	0xc22ec <.text+0xb21ec> @ imm = #0x8
   c22e0: e59c0000     	ldr	r0, [r12]
   c22e4: e3500009     	cmp	r0, #9
   c22e8: cafffff7     	bgt	0xc22cc <.text+0xb21cc> @ imm = #-0x24
   c22ec: e3a02000     	mov	r2, #0
   c22f0: e3520000     	cmp	r2, #0
   c22f4: 1a000002     	bne	0xc2304 <.text+0xb2204> @ imm = #0x8
   c22f8: e2822001     	add	r2, r2, #1
   c22fc: e3520020     	cmp	r2, #32
   c2300: 1afffffc     	bne	0xc22f8 <.text+0xb21f8> @ imm = #-0x10
   c2304: e59e0000     	ldr	r0, [lr]
   c2308: e2401001     	sub	r1, r0, #1
   c230c: e0000190     	mul	r0, r0, r1
   c2310: e3100001     	tst	r0, #1
   c2314: e59e0000     	ldr	r0, [lr]
   c2318: e2401001     	sub	r1, r0, #1
   c231c: e0000190     	mul	r0, r0, r1
   c2320: e3100001     	tst	r0, #1
   c2324: 0a000002     	beq	0xc2334 <.text+0xb2234> @ imm = #0x8
   c2328: e59c0000     	ldr	r0, [r12]
   c232c: e3500009     	cmp	r0, #9
   c2330: cafffff7     	bgt	0xc2314 <.text+0xb2214> @ imm = #-0x24
   c2334: e3a02000     	mov	r2, #0
   c2338: e3520000     	cmp	r2, #0
   c233c: 1a00001d     	bne	0xc23b8 <.text+0xb22b8> @ imm = #0x74
   c2340: e59f3140     	ldr	r3, [pc, #0x140]        @ 0xc2488 <.text+0xb2388>
   c2344: e08f3003     	add	r3, pc, r3
   c2348: ea000002     	b	0xc2358 <.text+0xb2258> @ imm = #0x8
   c234c: e351000b     	cmp	r1, #11
   c2350: e1a02001     	mov	r2, r1
   c2354: 0a000017     	beq	0xc23b8 <.text+0xb22b8> @ imm = #0x5c
   c2358: e59e0000     	ldr	r0, [lr]
   c235c: e2401001     	sub	r1, r0, #1
   c2360: e0000190     	mul	r0, r0, r1
   c2364: e3100001     	tst	r0, #1
   c2368: 0a000002     	beq	0xc2378 <.text+0xb2278> @ imm = #0x8
   c236c: e59c0000     	ldr	r0, [r12]
   c2370: e3500009     	cmp	r0, #9
   c2374: ca00000b     	bgt	0xc23a8 <.text+0xb22a8> @ imm = #0x2c
   c2378: e7d30002     	ldrb	r0, [r3, r2]
   c237c: e2200074     	eor	r0, r0, #116
   c2380: e7c30002     	strb	r0, [r3, r2]
   c2384: e59e0000     	ldr	r0, [lr]
   c2388: e2401001     	sub	r1, r0, #1
   c238c: e0000190     	mul	r0, r0, r1
   c2390: e2821001     	add	r1, r2, #1
   c2394: e3100001     	tst	r0, #1
   c2398: 0affffeb     	beq	0xc234c <.text+0xb224c> @ imm = #-0x54
   c239c: e59c0000     	ldr	r0, [r12]
   c23a0: e3500009     	cmp	r0, #9
   c23a4: daffffe8     	ble	0xc234c <.text+0xb224c> @ imm = #-0x60
   c23a8: e7d30002     	ldrb	r0, [r3, r2]
   c23ac: e2200074     	eor	r0, r0, #116
   c23b0: e7c30002     	strb	r0, [r3, r2]
   c23b4: eaffffef     	b	0xc2378 <.text+0xb2278> @ imm = #-0x44
   c23b8: e3a02000     	mov	r2, #0
   c23bc: e3520000     	cmp	r2, #0
   c23c0: 1a000007     	bne	0xc23e4 <.text+0xb22e4> @ imm = #0x1c
   c23c4: e59f30c0     	ldr	r3, [pc, #0xc0]         @ 0xc248c <.text+0xb238c>
   c23c8: e08f3003     	add	r3, pc, r3
   c23cc: e7d30002     	ldrb	r0, [r3, r2]
   c23d0: e220008e     	eor	r0, r0, #142
   c23d4: e7c30002     	strb	r0, [r3, r2]
   c23d8: e2822001     	add	r2, r2, #1
   c23dc: e3520006     	cmp	r2, #6
   c23e0: 1afffff9     	bne	0xc23cc <.text+0xb22cc> @ imm = #-0x1c
   c23e4: e3a02000     	mov	r2, #0
   c23e8: e3520000     	cmp	r2, #0
   c23ec: 1a000007     	bne	0xc2410 <.text+0xb2310> @ imm = #0x1c
   c23f0: e59f3098     	ldr	r3, [pc, #0x98]         @ 0xc2490 <.text+0xb2390>
   c23f4: e08f3003     	add	r3, pc, r3
   c23f8: e7d30002     	ldrb	r0, [r3, r2]
   c23fc: e220002e     	eor	r0, r0, #46
   c2400: e7c30002     	strb	r0, [r3, r2]
   c2404: e2822001     	add	r2, r2, #1
   c2408: e3520021     	cmp	r2, #33
   c240c: 1afffff9     	bne	0xc23f8 <.text+0xb22f8> @ imm = #-0x1c
   c2410: e3a02000     	mov	r2, #0
   c2414: e3520000     	cmp	r2, #0
   c2418: 1a000007     	bne	0xc243c <.text+0xb233c> @ imm = #0x1c
   c241c: e59f3070     	ldr	r3, [pc, #0x70]         @ 0xc2494 <.text+0xb2394>
   c2420: e08f3003     	add	r3, pc, r3
   c2424: e7d30002     	ldrb	r0, [r3, r2]
   c2428: e2200026     	eor	r0, r0, #38
   c242c: e7c30002     	strb	r0, [r3, r2]
   c2430: e2822001     	add	r2, r2, #1
   c2434: e3520025     	cmp	r2, #37
   c2438: 1afffff9     	bne	0xc2424 <.text+0xb2324> @ imm = #-0x1c
   c243c: e59e0000     	ldr	r0, [lr]
   c2440: e2401001     	sub	r1, r0, #1
   c2444: e0000190     	mul	r0, r0, r1
   c2448: e3100001     	tst	r0, #1
   c244c: 08bd8800     	popeq	{r11, pc}
   c2450: e59c0000     	ldr	r0, [r12]
   c2454: e3500009     	cmp	r0, #9
   c2458: cafffff7     	bgt	0xc243c <.text+0xb233c> @ imm = #-0x24
   c245c: e8bd8800     	pop	{r11, pc}
   c2460: 0051dcb4     	ldrheq	sp, [r1], #-196
   c2464: 0051c6cc     	subseq	r12, r1, r12, asr #13
   c2468: 00527563     	subseq	r7, r2, r3, ror #10
   c246c: 0051dc2c     	subseq	sp, r1, r12, lsr #24
   c2470: 0051c628     	subseq	r12, r1, r8, lsr #12
   c2474: 005274c6     	subseq	r7, r2, r6, asr #9
   c2478: 00527449     	subseq	r7, r2, r9, asr #8
   c247c: 00527428     	subseq	r7, r2, r8, lsr #8
   c2480: 005273bb     	ldrheq	r7, [r2], #-59
   c2484: 0052732c     	subseq	r7, r2, r12, lsr #6
   c2488: 0052727e     	subseq	r7, r2, lr, ror r2
   c248c: 00527205     	subseq	r7, r2, r5, lsl #4
   c2490: 005271df     	ldrsbeq	r7, [r2], #-31
   c2494: 005271d4     	ldrsbeq	r7, [r2], #-20

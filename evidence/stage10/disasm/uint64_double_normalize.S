
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  5910e4: e3510601     	cmp	r1, #1048576
  5910e8: 3a00000e     	blo	0x591128 <.text+0x581028> @ imm = #0x38
  5910ec: e3510602     	cmp	r1, #2097152
  5910f0: 3a000006     	blo	0x591110 <.text+0x581010> @ imm = #0x18
  5910f4: e1b010a1     	lsrs	r1, r1, #1
  5910f8: e1b00060     	rrxs	r0, r0
  5910fc: e1a0c06c     	rrx	r12, r12
  591100: e2844001     	add	r4, r4, #1
  591104: e1a02a84     	lsl	r2, r4, #21
  591108: e3720501     	cmn	r2, #4194304
  59110c: 2a000055     	bhs	0x591268 <.text+0x581168> @ imm = #0x154
  591110: e35c0102     	cmp	r12, #-2147483648
  591114: 01b0c0a0     	lsrseq	r12, r0, #1
  591118: e2b00000     	adcs	r0, r0, #0
  59111c: e0a11a04     	adc	r1, r1, r4, lsl #20
  591120: e1811005     	orr	r1, r1, r5
  591124: e8bd8030     	pop	{r4, r5, pc}
  591128: e1b0c08c     	lsls	r12, r12, #1
  59112c: e0b00000     	adcs	r0, r0, r0
  591130: e0a11001     	adc	r1, r1, r1
  591134: e2544001     	subs	r4, r4, #1
  591138: 23510601     	cmphs	r1, #1048576
  59113c: 2afffff3     	bhs	0x591110 <.text+0x581010> @ imm = #-0x34
  591140: e3310000     	teq	r1, #0
  591144: 01a01000     	moveq	r1, r0
  591148: 03a00000     	moveq	r0, #0
  59114c: e16f3f11     	clz	r3, r1
  591150: 02833020     	addeq	r3, r3, #32
  591154: e243300b     	sub	r3, r3, #11
  591158: e2532020     	subs	r2, r3, #32
  59115c: aa000007     	bge	0x591180 <.text+0x581080> @ imm = #0x1c
  591160: e292200c     	adds	r2, r2, #12
  591164: da000004     	ble	0x59117c <.text+0x58107c> @ imm = #0x10
  591168: e282c014     	add	r12, r2, #20
  59116c: e262200c     	rsb	r2, r2, #12
  591170: e1a00c11     	lsl	r0, r1, r12
  591174: e1a01231     	lsr	r1, r1, r2
  591178: ea000004     	b	0x591190 <.text+0x581090> @ imm = #0x10
  59117c: e2822014     	add	r2, r2, #20
  591180: d262c020     	rsble	r12, r2, #32
  591184: e1a01211     	lsl	r1, r1, r2
  591188: d1811c30     	orrle	r1, r1, r0, lsr r12
  59118c: d1a00210     	lslle	r0, r0, r2
  591190: e0544003     	subs	r4, r4, r3
  591194: a0811a04     	addge	r1, r1, r4, lsl #20
  591198: a1811005     	orrge	r1, r1, r5
  59119c: a8bd8030     	popge	{r4, r5, pc}
  5911a0: e1e04004     	mvn	r4, r4
  5911a4: e254401f     	subs	r4, r4, #31
  5911a8: aa00000d     	bge	0x5911e4 <.text+0x5810e4> @ imm = #0x34
  5911ac: e294400c     	adds	r4, r4, #12
  5911b0: ca000005     	bgt	0x5911cc <.text+0x5810cc> @ imm = #0x14
  5911b4: e2844014     	add	r4, r4, #20
  5911b8: e2642020     	rsb	r2, r4, #32
  5911bc: e1a00430     	lsr	r0, r0, r4
  5911c0: e1800211     	orr	r0, r0, r1, lsl r2
  5911c4: e1851431     	orr	r1, r5, r1, lsr r4
  5911c8: e8bd8030     	pop	{r4, r5, pc}
  5911cc: e264400c     	rsb	r4, r4, #12
  5911d0: e2642020     	rsb	r2, r4, #32
  5911d4: e1a00230     	lsr	r0, r0, r2
  5911d8: e1800411     	orr	r0, r0, r1, lsl r4
  5911dc: e1a01005     	mov	r1, r5
  5911e0: e8bd8030     	pop	{r4, r5, pc}
  5911e4: e1a00431     	lsr	r0, r1, r4
  5911e8: e1a01005     	mov	r1, r5
  5911ec: e8bd8030     	pop	{r4, r5, pc}

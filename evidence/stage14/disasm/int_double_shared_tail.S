
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
  5911f0: e3340000     	teq	r4, #0
  5911f4: e2233601     	eor	r3, r3, #1048576
  5911f8: 02211601     	eoreq	r1, r1, #1048576
  5911fc: 02844001     	addeq	r4, r4, #1
  591200: 12455001     	subne	r5, r5, #1
  591204: eaffffa1     	b	0x591090 <.text+0x580f90> @ imm = #-0x17c
  591208: e1f0cac4     	mvns	r12, r4, asr #21
  59120c: 11f0cac5     	mvnsne	r12, r5, asr #21
  591210: 0a000018     	beq	0x591278 <.text+0x581178> @ imm = #0x60
  591214: e1340005     	teq	r4, r5
  591218: 01300002     	teqeq	r0, r2
  59121c: 0a000003     	beq	0x591230 <.text+0x581130> @ imm = #0xc
  591220: e194c000     	orrs	r12, r4, r0
  591224: 01a01003     	moveq	r1, r3
  591228: 01a00002     	moveq	r0, r2
  59122c: e8bd8030     	pop	{r4, r5, pc}
  591230: e1310003     	teq	r1, r3
  591234: 13a01000     	movne	r1, #0
  591238: 13a00000     	movne	r0, #0
  59123c: 18bd8030     	popne	{r4, r5, pc}
  591240: e1b0caa4     	lsrs	r12, r4, #21
  591244: 1a000003     	bne	0x591258 <.text+0x581158> @ imm = #0xc
  591248: e1b00080     	lsls	r0, r0, #1
  59124c: e0b11001     	adcs	r1, r1, r1
  591250: 23811102     	orrhs	r1, r1, #-2147483648
  591254: e8bd8030     	pop	{r4, r5, pc}
  591258: e2944501     	adds	r4, r4, #4194304
  59125c: 32811601     	addlo	r1, r1, #1048576
  591260: 38bd8030     	poplo	{r4, r5, pc}
  591264: e2015102     	and	r5, r1, #-2147483648
  591268: e385147f     	orr	r1, r5, #2130706432
  59126c: e381160f     	orr	r1, r1, #15728640
  591270: e3a00000     	mov	r0, #0
  591274: e8bd8030     	pop	{r4, r5, pc}
  591278: e1f0cac4     	mvns	r12, r4, asr #21
  59127c: 11a01003     	movne	r1, r3
  591280: 11a00002     	movne	r0, r2
  591284: 01f0cac5     	mvnseq	r12, r5, asr #21
  591288: 11a03001     	movne	r3, r1
  59128c: 11a02000     	movne	r2, r0
  591290: e1904601     	orrs	r4, r0, r1, lsl #12
  591294: 01925603     	orrseq	r5, r2, r3, lsl #12
  591298: 01310003     	teqeq	r1, r3
  59129c: 13811702     	orrne	r1, r1, #524288
  5912a0: e8bd8030     	pop	{r4, r5, pc}
  5912a4: e3300000     	teq	r0, #0
  5912a8: 03a01000     	moveq	r1, #0
  5912ac: 012fff1e     	bxeq	lr
  5912b0: e92d4030     	push	{r4, r5, lr}
  5912b4: e3a04b01     	mov	r4, #1024
  5912b8: e2844032     	add	r4, r4, #50
  5912bc: e3a05000     	mov	r5, #0
  5912c0: e3a01000     	mov	r1, #0
  5912c4: eaffff9d     	b	0x591140 <.text+0x581040> @ imm = #-0x18c
  5912c8: e3300000     	teq	r0, #0
  5912cc: 03a01000     	moveq	r1, #0
  5912d0: 012fff1e     	bxeq	lr
  5912d4: e92d4030     	push	{r4, r5, lr}
  5912d8: e3a04b01     	mov	r4, #1024
  5912dc: e2844032     	add	r4, r4, #50
  5912e0: e2105102     	ands	r5, r0, #-2147483648
  5912e4: 42600000     	rsbmi	r0, r0, #0
  5912e8: e3a01000     	mov	r1, #0
  5912ec: eaffff93     	b	0x591140 <.text+0x581040> @ imm = #-0x1b4
  5912f0: e1b02080     	lsls	r2, r0, #1
  5912f4: e1a011c2     	asr	r1, r2, #3
  5912f8: e1a01061     	rrx	r1, r1
  5912fc: e1a00e02     	lsl	r0, r2, #28
  591300: 121234ff     	andsne	r3, r2, #-16777216
  591304: 133304ff     	teqne	r3, #-16777216
  591308: 1221130e     	eorne	r1, r1, #939524096
  59130c: 112fff1e     	bxne	lr

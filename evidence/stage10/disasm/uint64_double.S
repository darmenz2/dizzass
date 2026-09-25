
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  591338: e1902001     	orrs	r2, r0, r1
  59133c: 012fff1e     	bxeq	lr
  591340: e92d4030     	push	{r4, r5, lr}
  591344: e3a05000     	mov	r5, #0
  591348: ea000006     	b	0x591368 <.text+0x581268> @ imm = #0x18
  59134c: e1902001     	orrs	r2, r0, r1
  591350: 012fff1e     	bxeq	lr
  591354: e92d4030     	push	{r4, r5, lr}
  591358: e2115102     	ands	r5, r1, #-2147483648
  59135c: 5a000001     	bpl	0x591368 <.text+0x581268> @ imm = #0x4
  591360: e2700000     	rsbs	r0, r0, #0
  591364: e2e11000     	rsc	r1, r1, #0
  591368: e3a04b01     	mov	r4, #1024
  59136c: e2844032     	add	r4, r4, #50
  591370: e1b0cb21     	lsrs	r12, r1, #22
  591374: 0affff5a     	beq	0x5910e4 <.text+0x580fe4> @ imm = #-0x298
  591378: e3a02003     	mov	r2, #3
  59137c: e1b0c1ac     	lsrs	r12, r12, #3
  591380: 12822003     	addne	r2, r2, #3
  591384: e1b0c1ac     	lsrs	r12, r12, #3
  591388: 12822003     	addne	r2, r2, #3
  59138c: e08221ac     	add	r2, r2, r12, lsr #3
  591390: e2623020     	rsb	r3, r2, #32
  591394: e1a0c310     	lsl	r12, r0, r3
  591398: e1a00230     	lsr	r0, r0, r2
  59139c: e1800311     	orr	r0, r0, r1, lsl r3
  5913a0: e1a01231     	lsr	r1, r1, r2
  5913a4: e0844002     	add	r4, r4, r2
  5913a8: eaffff4d     	b	0x5910e4 <.text+0x580fe4> @ imm = #-0x2cc

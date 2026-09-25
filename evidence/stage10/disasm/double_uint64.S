
reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
  591508: ed9f7b0a     	vldr	d7, [pc, #40]           @ 0x591538 <.text+0x581438>
  59150c: ec410b16     	vmov	d6, r0, r1
  591510: ed9f5b0a     	vldr	d5, [pc, #40]           @ 0x591540 <.text+0x581440>
  591514: ee267b07     	vmul.f64	d7, d6, d7
  591518: eebc7bc7     	vcvt.u32.f64	s14, d7
  59151c: eeb84b47     	vcvt.f64.u32	d4, s14
  591520: ee171a10     	vmov	r1, s14
  591524: ee046b45     	vmls.f64	d6, d4, d5
  591528: eefc7bc6     	vcvt.u32.f64	s15, d6
  59152c: ee170a90     	vmov	r0, s15
  591530: e12fff1e     	bx	lr
  591534: e320f000     	nop
  591538: 00000000     	andeq	r0, r0, r0
  59153c: 3df00000     	ldcllo	p0, c0, [r0, #0]!
  591540: 00000000     	andeq	r0, r0, r0
  591544: 41f00000     	mvnsmi	r0, r0

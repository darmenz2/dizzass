
${PROJECT}/reference/cgminer.vendor.elf:	file format elf32-littlearm

Disassembly of section .text:

00010100 <.text>:
   c4480: e59d0010     	ldr	r0, [sp, #0x10]
   c4484: e3500005     	cmp	r0, #5
   c4488: 1a000009     	bne	0xc44b4 <.text+0xb43b4> @ imm = #0x24
   c448c: e3881005     	orr	r1, r8, #5
   c4490: e3520001     	cmp	r2, #1
   c4494: 03881006     	orreq	r1, r8, #6
   c4498: e55b0064     	ldrb	r0, [r11, #-0x64]
   c449c: e3520002     	cmp	r2, #2
   c44a0: e5d11000     	ldrb	r1, [r1]
   c44a4: e1a00380     	lsl	r0, r0, #7
   c44a8: 33e0007f     	mvnlo	r0, #127
   c44ac: e18000a1     	orr	r0, r0, r1, lsr #1
   c44b0: ea000003     	b	0xc44c4 <.text+0xb43c4> @ imm = #0xc
   c44b4: e3880005     	orr	r0, r8, #5
   c44b8: e3520001     	cmp	r2, #1
   c44bc: 03880006     	orreq	r0, r8, #6
   c44c0: e5d00000     	ldrb	r0, [r0]
   c44c4: e59a1000     	ldr	r1, [r10]
   c44c8: e2412001     	sub	r2, r1, #1
   c44cc: e0010291     	mul	r1, r1, r2
   c44d0: e3110001     	tst	r1, #1
   c44d4: e59a2000     	ldr	r2, [r10]
   c44d8: e7e411d0     	ubfx	r1, r0, #0x3, #0x5

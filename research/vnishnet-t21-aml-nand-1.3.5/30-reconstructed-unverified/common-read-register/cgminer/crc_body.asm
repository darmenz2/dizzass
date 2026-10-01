000f7f10  000051e3  cmp      r1, #0
000f7f14  2e00000a  beq      #0xf7fd4
000f7f18  f04f2de9  push     {r4, r5, r6, r7, r8, sb, sl, fp, lr}
000f7f1c  1cb08de2  add      fp, sp, #0x1c
000f7f20  04d04de2  sub      sp, sp, #4
000f7f24  80c0a0e3  mov      ip, #0x80
000f7f28  0020a0e3  mov      r2, #0
000f7f2c  0130a0e3  mov      r3, #1
000f7f30  0180a0e3  mov      r8, #1
000f7f34  0150a0e3  mov      r5, #1
000f7f38  01e0a0e3  mov      lr, #1
000f7f3c  0170a0e3  mov      r7, #1
000f7f40  0ea0a0e1  mov      sl, lr
000f7f44  05e0a0e1  mov      lr, r5
000f7f48  00308de5  str      r3, [sp]
000f7f4c  0030a0e1  mov      r3, r0
000f7f50  015082e2  add      r5, r2, #1
000f7f54  0190d3e4  ldrb     sb, [r3], #1
000f7f58  dc60e6e7  ubfx     r6, ip, #1, #7
000f7f5c  7540efe6  uxtb     r4, r5
000f7f60  080054e3  cmp      r4, #8
000f7f64  0300a001  moveq    r0, r3
000f7f68  082054e2  subs     r2, r4, #8
000f7f6c  0520a011  movne    r2, r5
000f7f70  080054e3  cmp      r4, #8
000f7f74  80600003  movweq   r6, #0x80
000f7f78  09301ce0  ands     r3, ip, sb
000f7f7c  01300013  movwne   r3, #1
000f7f80  00409de5  ldr      r4, [sp]
000f7f84  033027e0  eor      r3, r7, r3
000f7f88  011051e2  subs     r1, r1, #1
000f7f8c  085023e0  eor      r5, r3, r8
000f7f90  0a70a0e1  mov      r7, sl
000f7f94  0480a0e1  mov      r8, r4
000f7f98  06c0a0e1  mov      ip, r6
000f7f9c  e7ffff1a  bne      #0xf7f40
000f7fa0  7300efe6  uxtb     r0, r3
000f7fa4  000050e3  cmp      r0, #0
000f7fa8  01000013  movwne   r0, #1
000f7fac  7a10efe6  uxtb     r1, sl
000f7fb0  000051e3  cmp      r1, #0
000f7fb4  01100013  movwne   r1, #1
000f7fb8  ff001ee3  tst      lr, #0xff
000f7fbc  0112a0e1  lsl      r1, r1, #4
000f7fc0  0700000a  beq      #0xf7fe4
000f7fc4  ff0015e3  tst      r5, #0xff
000f7fc8  0900000a  beq      #0xf7ff4
000f7fcc  0c1081e3  orr      r1, r1, #0xc
000f7fd0  140000ea  b        #0xf8028
000f7fd4  0100a0e3  mov      r0, #1
000f7fd8  1e10a0e3  mov      r1, #0x1e
000f7fdc  000081e1  orr      r0, r1, r0
000f7fe0  1eff2fe1  bx       lr
000f7fe4  ff0015e3  tst      r5, #0xff
000f7fe8  0200000a  beq      #0xf7ff8
000f7fec  041081e3  orr      r1, r1, #4
000f7ff0  0c0000ea  b        #0xf8028
000f7ff4  081081e3  orr      r1, r1, #8
000f7ff8  40209fe5  ldr      r2, [pc, #0x40]
000f7ffc  02209fe7  ldr      r2, [pc, r2]
000f8000  3c309fe5  ldr      r3, [pc, #0x3c]
000f8004  03309fe7  ldr      r3, [pc, r3]
000f8008  007092e5  ldr      r7, [r2]
000f800c  016047e2  sub      r6, r7, #1
000f8010  970607e0  mul      r7, r7, r6
000f8014  010017e3  tst      r7, #1
000f8018  0200000a  beq      #0xf8028
000f801c  007093e5  ldr      r7, [r3]
000f8020  090057e3  cmp      r7, #9
000f8024  f7ffffca  bgt      #0xf8008
000f8028  ff0014e3  tst      r4, #0xff
000f802c  02108113  orrne    r1, r1, #2
000f8030  1cd04be2  sub      sp, fp, #0x1c
000f8034  f04fbde8  pop      {r4, r5, r6, r7, r8, sb, sl, fp, lr}
000f8038  000081e1  orr      r0, r1, r0
000f803c  1eff2fe1  bx       lr

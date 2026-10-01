000fcc18  000051e3  cmp      r1, #0
000fcc1c  2e00000a  beq      #0xfccdc
000fcc20  f04f2de9  push     {r4, r5, r6, r7, r8, sb, sl, fp, lr}
000fcc24  1cb08de2  add      fp, sp, #0x1c
000fcc28  04d04de2  sub      sp, sp, #4
000fcc2c  80c0a0e3  mov      ip, #0x80
000fcc30  0020a0e3  mov      r2, #0
000fcc34  0130a0e3  mov      r3, #1
000fcc38  0180a0e3  mov      r8, #1
000fcc3c  0150a0e3  mov      r5, #1
000fcc40  01e0a0e3  mov      lr, #1
000fcc44  0170a0e3  mov      r7, #1
000fcc48  0ea0a0e1  mov      sl, lr
000fcc4c  05e0a0e1  mov      lr, r5
000fcc50  00308de5  str      r3, [sp]
000fcc54  0030a0e1  mov      r3, r0
000fcc58  015082e2  add      r5, r2, #1
000fcc5c  0190d3e4  ldrb     sb, [r3], #1
000fcc60  dc60e6e7  ubfx     r6, ip, #1, #7
000fcc64  7540efe6  uxtb     r4, r5
000fcc68  080054e3  cmp      r4, #8
000fcc6c  0300a001  moveq    r0, r3
000fcc70  082054e2  subs     r2, r4, #8
000fcc74  0520a011  movne    r2, r5
000fcc78  080054e3  cmp      r4, #8
000fcc7c  80600003  movweq   r6, #0x80
000fcc80  09301ce0  ands     r3, ip, sb
000fcc84  01300013  movwne   r3, #1
000fcc88  00409de5  ldr      r4, [sp]
000fcc8c  033027e0  eor      r3, r7, r3
000fcc90  011051e2  subs     r1, r1, #1
000fcc94  085023e0  eor      r5, r3, r8
000fcc98  0a70a0e1  mov      r7, sl
000fcc9c  0480a0e1  mov      r8, r4
000fcca0  06c0a0e1  mov      ip, r6
000fcca4  e7ffff1a  bne      #0xfcc48
000fcca8  7300efe6  uxtb     r0, r3
000fccac  000050e3  cmp      r0, #0
000fccb0  01000013  movwne   r0, #1
000fccb4  7a10efe6  uxtb     r1, sl
000fccb8  000051e3  cmp      r1, #0
000fccbc  01100013  movwne   r1, #1
000fccc0  ff001ee3  tst      lr, #0xff
000fccc4  0112a0e1  lsl      r1, r1, #4
000fccc8  0700000a  beq      #0xfccec
000fcccc  ff0015e3  tst      r5, #0xff
000fccd0  08108103  orreq    r1, r1, #8
000fccd4  0c108113  orrne    r1, r1, #0xc
000fccd8  050000ea  b        #0xfccf4
000fccdc  0100a0e3  mov      r0, #1
000fcce0  1e10a0e3  mov      r1, #0x1e
000fcce4  000081e1  orr      r0, r1, r0
000fcce8  1eff2fe1  bx       lr
000fccec  ff0015e3  tst      r5, #0xff
000fccf0  04108113  orrne    r1, r1, #4
000fccf4  ff0014e3  tst      r4, #0xff
000fccf8  02108113  orrne    r1, r1, #2
000fccfc  1cd04be2  sub      sp, fp, #0x1c
000fcd00  f04fbde8  pop      {r4, r5, r6, r7, r8, sb, sl, fp, lr}
000fcd04  000081e1  orr      r0, r1, r0
000fcd08  1eff2fe1  bx       lr

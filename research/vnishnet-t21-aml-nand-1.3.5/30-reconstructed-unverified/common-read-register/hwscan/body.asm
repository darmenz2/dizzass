000ea7e4  704c2de9  push     {r4, r5, r6, sl, fp, lr}
000ea7e8  10b08de2  add      fp, sp, #0x10
000ea7ec  18d04de2  sub      sp, sp, #0x18
000ea7f0  0040a0e1  mov      r4, r0
000ea7f4  0500a0e3  mov      r0, #5
000ea7f8  1100cde5  strb     r0, [sp, #0x11]
000ea7fc  4200a0e3  mov      r0, #0x42
000ea800  1102c4e7  bfi      r0, r1, #4, #1
000ea804  1000cde5  strb     r0, [sp, #0x10]
000ea808  000052e3  cmp      r2, #0
000ea80c  0000a0e3  mov      r0, #0
000ea810  10608de2  add      r6, sp, #0x10
000ea814  04009215  ldrne    r0, [r2, #4]
000ea818  1330cde5  strb     r3, [sp, #0x13]
000ea81c  2010a0e3  mov      r1, #0x20
000ea820  1200cde5  strb     r0, [sp, #0x12]
000ea824  0600a0e1  mov      r0, r6
000ea828  0050a0e3  mov      r5, #0
000ea82c  f94800eb  bl       #0xfcc18
000ea830  6c109fe5  ldr      r1, [pc, #0x6c]
000ea834  0520a0e3  mov      r2, #5
000ea838  01109fe7  ldr      r1, [pc, r1]
000ea83c  1400cde5  strb     r0, [sp, #0x14]
000ea840  0400a0e1  mov      r0, r4
000ea844  183091e5  ldr      r3, [r1, #0x18]
000ea848  0610a0e1  mov      r1, r6
000ea84c  33ff2fe1  blx      r3
000ea850  000050e3  cmp      r0, #0
000ea854  0f00000a  beq      #0xea898
000ea858  48009fe5  ldr      r0, [pc, #0x48]
000ea85c  0150a0e3  mov      r5, #1
000ea860  44109fe5  ldr      r1, [pc, #0x44]
000ea864  44209fe5  ldr      r2, [pc, #0x44]
000ea868  00008fe0  add      r0, pc, r0
000ea86c  183094e5  ldr      r3, [r4, #0x18]
000ea870  01108fe0  add      r1, pc, r1
000ea874  38609fe5  ldr      r6, [pc, #0x38]
000ea878  02208fe0  add      r2, pc, r2
000ea87c  013083e2  add      r3, r3, #1
000ea880  06608fe0  add      r6, pc, r6
000ea884  60008de8  stm      sp, {r5, r6}
000ea888  08308de5  str      r3, [sp, #8]
000ea88c  6730a0e3  mov      r3, #0x67
000ea890  865100eb  bl       #0xfeeb0
000ea894  0050e0e3  mvn      r5, #0
000ea898  0500a0e1  mov      r0, r5
000ea89c  10d04be2  sub      sp, fp, #0x10
000ea8a0  708cbde8  pop      {r4, r5, r6, sl, fp, pc}

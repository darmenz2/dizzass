000d253c  f04d2de9  push     {r4, r5, r6, r7, r8, sl, fp, lr}
000d2540  18b08de2  add      fp, sp, #0x18
000d2544  18d04de2  sub      sp, sp, #0x18
000d2548  0040a0e1  mov      r4, r0
000d254c  0500a0e3  mov      r0, #5
000d2550  1100cde5  strb     r0, [sp, #0x11]
000d2554  4200a0e3  mov      r0, #0x42
000d2558  1102c4e7  bfi      r0, r1, #4, #1
000d255c  1000cde5  strb     r0, [sp, #0x10]
000d2560  000052e3  cmp      r2, #0
000d2564  0000a0e3  mov      r0, #0
000d2568  10608de2  add      r6, sp, #0x10
000d256c  04009215  ldrne    r0, [r2, #4]
000d2570  1330cde5  strb     r3, [sp, #0x13]
000d2574  2010a0e3  mov      r1, #0x20
000d2578  1200cde5  strb     r0, [sp, #0x12]
000d257c  0600a0e1  mov      r0, r6
000d2580  0050a0e3  mov      r5, #0
000d2584  619600eb  bl       #0xf7f10
000d2588  f4109fe5  ldr      r1, [pc, #0xf4]
000d258c  0520a0e3  mov      r2, #5
000d2590  01109fe7  ldr      r1, [pc, r1]
000d2594  1400cde5  strb     r0, [sp, #0x14]
000d2598  0400a0e1  mov      r0, r4
000d259c  183091e5  ldr      r3, [r1, #0x18]
000d25a0  0610a0e1  mov      r1, r6
000d25a4  33ff2fe1  blx      r3
000d25a8  000050e3  cmp      r0, #0
000d25ac  3100000a  beq      #0xd2678
000d25b0  d0809fe5  ldr      r8, [pc, #0xd0]
000d25b4  08809fe7  ldr      r8, [pc, r8]
000d25b8  000098e5  ldr      r0, [r8]
000d25bc  c8709fe5  ldr      r7, [pc, #0xc8]
000d25c0  011040e2  sub      r1, r0, #1
000d25c4  900100e0  mul      r0, r0, r1
000d25c8  07709fe7  ldr      r7, [pc, r7]
000d25cc  bc609fe5  ldr      r6, [pc, #0xbc]
000d25d0  06608fe0  add      r6, pc, r6
000d25d4  010010e3  tst      r0, #1
000d25d8  0200000a  beq      #0xd25e8
000d25dc  000097e5  ldr      r0, [r7]
000d25e0  090050e3  cmp      r0, #9
000d25e4  150000ca  bgt      #0xd2640
000d25e8  a4009fe5  ldr      r0, [pc, #0xa4]
000d25ec  0150a0e3  mov      r5, #1
000d25f0  a0109fe5  ldr      r1, [pc, #0xa0]
000d25f4  a0209fe5  ldr      r2, [pc, #0xa0]
000d25f8  00008fe0  add      r0, pc, r0
000d25fc  183094e5  ldr      r3, [r4, #0x18]
000d2600  01108fe0  add      r1, pc, r1
000d2604  02208fe0  add      r2, pc, r2
000d2608  60008de8  stm      sp, {r5, r6}
000d260c  013083e2  add      r3, r3, #1
000d2610  08308de5  str      r3, [sp, #8]
000d2614  6730a0e3  mov      r3, #0x67
000d2618  a99e00eb  bl       #0xfa0c4
000d261c  000098e5  ldr      r0, [r8]
000d2620  0050e0e3  mvn      r5, #0
000d2624  011040e2  sub      r1, r0, #1
000d2628  900100e0  mul      r0, r0, r1
000d262c  010010e3  tst      r0, #1
000d2630  1000000a  beq      #0xd2678
000d2634  000097e5  ldr      r0, [r7]
000d2638  090050e3  cmp      r0, #9
000d263c  0d0000da  ble      #0xd2678
000d2640  58009fe5  ldr      r0, [pc, #0x58]
000d2644  0150a0e3  mov      r5, #1
000d2648  54109fe5  ldr      r1, [pc, #0x54]
000d264c  54209fe5  ldr      r2, [pc, #0x54]
000d2650  00008fe0  add      r0, pc, r0
000d2654  183094e5  ldr      r3, [r4, #0x18]
000d2658  01108fe0  add      r1, pc, r1
000d265c  02208fe0  add      r2, pc, r2
000d2660  60008de8  stm      sp, {r5, r6}
000d2664  013083e2  add      r3, r3, #1
000d2668  08308de5  str      r3, [sp, #8]
000d266c  6730a0e3  mov      r3, #0x67
000d2670  939e00eb  bl       #0xfa0c4
000d2674  dbffffea  b        #0xd25e8
000d2678  0500a0e1  mov      r0, r5
000d267c  18d04be2  sub      sp, fp, #0x18
000d2680  f08dbde8  pop      {r4, r5, r6, r7, r8, sl, fp, pc}

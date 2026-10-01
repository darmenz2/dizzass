00025428  f04f2de9    push       {r4, r5, r6, r7, r8, sb, sl, fp, lr}
0002542c  9cd04de2    sub        sp, sp, #0x9c
00025430  01a0a0e1    mov        sl, r1
00025434  00b0a0e1    mov        fp, r0
00025438  f4149fe5    ldr        r1, [pc, #0x4f4]
0002543c  89eb10eb    bl         #0x460268
00025440  0120b0e7    ldr        r2, [r0, r1]!
00025444  043090e5    ldr        r3, [r0, #4]
00025448  e8449fe5    ldr        r4, [pc, #0x4e8]
0002544c  031092e1    orrs       r1, r2, r3
00025450  04408fe0    add        r4, pc, r4
00025454  2000001a    bne        #0x254dc
00025458  30e084e2    add        lr, r4, #0x30
0002545c  00c0a0e3    mov        ip, #0
00025460  9f8fbee1    ldrexd     r8, sb, [lr]
00025464  1ff07ff5    clrex      
00025468  012098e2    adds       r2, r8, #1
0002546c  0030b9e2    adcs       r3, sb, #0
00025470  0060bce2    adcs       r6, ip, #0
00025474  0601001a    bne        #0x25894
00025478  0410a0e1    mov        r1, r4
0002547c  0b40a0e1    mov        r4, fp
00025480  0a70a0e1    mov        r7, sl
00025484  9fafbee1    ldrexd     sl, fp, [lr]
00025488  09602be0    eor        r6, fp, sb
0002548c  08502ae0    eor        r5, sl, r8
00025490  066095e1    orrs       r6, r5, r6
00025494  0800001a    bne        #0x254bc
00025498  0a80a0e1    mov        r8, sl
0002549c  926faee1    strexd     r6, r2, r3, [lr]
000254a0  0b90a0e1    mov        sb, fp
000254a4  04b0a0e1    mov        fp, r4
000254a8  07a0a0e1    mov        sl, r7
000254ac  0140a0e1    mov        r4, r1
000254b0  000056e3    cmp        r6, #0
000254b4  0700000a    beq        #0x254d8
000254b8  eaffffea    b          #0x25468
000254bc  0a80a0e1    mov        r8, sl
000254c0  1ff07ff5    clrex      
000254c4  0b90a0e1    mov        sb, fp
000254c8  04b0a0e1    mov        fp, r4
000254cc  07a0a0e1    mov        sl, r7
000254d0  0140a0e1    mov        r4, r1
000254d4  e3ffffea    b          #0x25468
000254d8  f020c0e1    strd       r2, r3, [r0]
000254dc  08008de2    add        r0, sp, #8
000254e0  201084e2    add        r1, r4, #0x20
000254e4  080080e2    add        r0, r0, #8
000254e8  9f6fb1e1    ldrexd     r6, r7, [r1]
000254ec  927fa1e1    strexd     r7, r2, r3, [r1]
000254f0  000057e3    cmp        r7, #0
000254f4  fbffff1a    bne        #0x254e8
000254f8  08608de2    add        r6, sp, #8
000254fc  0010a0e3    mov        r1, #0
00025500  0130a0e3    mov        r3, #1
00025504  0220a0e3    mov        r2, #2
00025508  003080e5    str        r3, [r0]
0002550c  060080e9    stmib      r0, {r1, r2}
00025510  0c1080e5    str        r1, [r0, #0xc]
00025514  0c108de5    str        r1, [sp, #0xc]
00025518  08108de5    str        r1, [sp, #8]
0002551c  0600a0e1    mov        r0, r6
00025520  0310a0e3    mov        r1, #3
00025524  0020a0e3    mov        r2, #0
00025528  a1d010eb    bl         #0x4597b4
0002552c  010070e3    cmn        r0, #1
00025530  7c00001a    bne        #0x25728
00025534  d0b310eb    bl         #0x45247c
00025538  001090e5    ldr        r1, [r0]
0002553c  040051e3    cmp        r1, #4
00025540  f5ffff0a    beq        #0x2551c
00025544  160051e3    cmp        r1, #0x16
00025548  b500008a    bhi        #0x25824
0002554c  0070a0e1    mov        r7, r0
00025550  000801e3    movw       r0, #0x1800
00025554  0120a0e3    mov        r2, #1
00025558  400040e3    movt       r0, #0x40
0002555c  120110e1    tst        r0, r2, lsl r1
00025560  af00000a    beq        #0x25824
00025564  0000a0e3    mov        r0, #0
00025568  0110a0e3    mov        r1, #1
0002556c  8fb410eb    bl         #0x4527b0
00025570  010070e3    cmn        r0, #1
00025574  0060e0e3    mvn        r6, #0
00025578  00009705    ldreq      r0, [r7]
0002557c  09005003    cmpeq      r0, #9
00025580  8200000a    beq        #0x25790
00025584  0100a0e3    mov        r0, #1
00025588  0110a0e3    mov        r1, #1
0002558c  87b410eb    bl         #0x4527b0
00025590  010070e3    cmn        r0, #1
00025594  00009705    ldreq      r0, [r7]
00025598  09005003    cmpeq      r0, #9
0002559c  8400000a    beq        #0x257b4
000255a0  0200a0e3    mov        r0, #2
000255a4  0110a0e3    mov        r1, #1
000255a8  80b410eb    bl         #0x4527b0
000255ac  010070e3    cmn        r0, #1
000255b0  00009705    ldreq      r0, [r7]
000255b4  09005003    cmpeq      r0, #9
000255b8  8c00000a    beq        #0x257f0
000255bc  0d00a0e3    mov        r0, #0xd
000255c0  0110a0e3    mov        r1, #1
000255c4  26d210eb    bl         #0x459e64
000255c8  010070e3    cmn        r0, #1
000255cc  9500000a    beq        #0x25828
000255d0  1e00a0e3    mov        r0, #0x1e
000255d4  e0b110eb    bl         #0x451d5c
000255d8  180084e5    str        r0, [r4, #0x18]
000255dc  08608de2    add        r6, sp, #8
000255e0  180094e5    ldr        r0, [r4, #0x18]
000255e4  0010a0e3    mov        r1, #0
000255e8  0600a0e1    mov        r0, r6
000255ec  8c20a0e3    mov        r2, #0x8c
000255f0  f2e710eb    bl         #0x45f5c0
000255f4  0b00a0e3    mov        r0, #0xb
000255f8  0010a0e3    mov        r1, #0
000255fc  0620a0e1    mov        r2, r6
00025600  c3d110eb    bl         #0x459d14
00025604  08009de5    ldr        r0, [sp, #8]
00025608  000050e3    cmp        r0, #0
0002560c  1100001a    bne        #0x25658
00025610  0100d4e5    ldrb       r0, [r4, #1]
00025614  000050e3    cmp        r0, #0
00025618  0400001a    bne        #0x25630
0002561c  0100a0e3    mov        r0, #1
00025620  5bf07ff5    dmb        ish
00025624  0100c4e5    strb       r0, [r4, #1]
00025628  0ffa02eb    bl         #0xe3e6c
0002562c  140084e5    str        r0, [r4, #0x14]
00025630  18039fe5    ldr        r0, [pc, #0x318]
00025634  041000e3    movw       r1, #4
00025638  001840e3    movt       r1, #0x800
0002563c  0020a0e3    mov        r2, #0
00025640  00008fe0    add        r0, pc, r0
00025644  8c108de5    str        r1, [sp, #0x8c]
00025648  08108de2    add        r1, sp, #8
0002564c  08008de5    str        r0, [sp, #8]
00025650  0b00a0e3    mov        r0, #0xb
00025654  aed110eb    bl         #0x459d14
00025658  08208de2    add        r2, sp, #8
0002565c  0700a0e3    mov        r0, #7
00025660  0010a0e3    mov        r1, #0
00025664  0060a0e3    mov        r6, #0
00025668  a9d110eb    bl         #0x459d14
0002566c  08009de5    ldr        r0, [sp, #8]
00025670  000050e3    cmp        r0, #0
00025674  1100001a    bne        #0x256c0
00025678  0100d4e5    ldrb       r0, [r4, #1]
0002567c  000050e3    cmp        r0, #0
00025680  0400001a    bne        #0x25698
00025684  0100a0e3    mov        r0, #1
00025688  5bf07ff5    dmb        ish
0002568c  0100c4e5    strb       r0, [r4, #1]
00025690  f5f902eb    bl         #0xe3e6c
00025694  140084e5    str        r0, [r4, #0x14]
00025698  b4029fe5    ldr        r0, [pc, #0x2b4]
0002569c  041000e3    movw       r1, #4
000256a0  001840e3    movt       r1, #0x800
000256a4  0020a0e3    mov        r2, #0
000256a8  00008fe0    add        r0, pc, r0
000256ac  8c108de5    str        r1, [sp, #0x8c]
000256b0  08108de2    add        r1, sp, #8
000256b4  08008de5    str        r0, [sp, #8]
000256b8  0700a0e3    mov        r0, #7
000256bc  94d110eb    bl         #0x459d14
000256c0  90029fe5    ldr        r0, [pc, #0x290]
000256c4  08b084e5    str        fp, [r4, #8]
000256c8  00008fe0    add        r0, pc, r0
000256cc  0ca084e5    str        sl, [r4, #0xc]
000256d0  17dcffeb    bl         #0x1c734
000256d4  80029fe5    ldr        r0, [pc, #0x280]
000256d8  00008fe0    add        r0, pc, r0
000256dc  000090e5    ldr        r0, [r0]
000256e0  5bf07ff5    dmb        ish
000256e4  000050e3    cmp        r0, #0
000256e8  5a00001a    bne        #0x25858
000256ec  62b310eb    bl         #0x45247c
000256f0  1c2084e2    add        r2, r4, #0x1c
000256f4  9f1f92e1    ldrex      r1, [r2]
000256f8  000051e3    cmp        r1, #0
000256fc  6600001a    bne        #0x2589c
00025700  903f82e1    strex      r3, r0, [r2]
00025704  000053e3    cmp        r3, #0
00025708  f9ffff1a    bne        #0x256f4
0002570c  5bf07ff5    dmb        ish
00025710  0120a0e3    mov        r2, #1
00025714  000052e3    cmp        r2, #0
00025718  6300000a    beq        #0x258ac
0002571c  0600a0e1    mov        r0, r6
00025720  9cd08de2    add        sp, sp, #0x9c
00025724  f08fbde8    pop        {r4, r5, r6, r7, r8, sb, sl, fp, pc}
00025728  0c929fe5    ldr        sb, [pc, #0x20c]
0002572c  066086e3    orr        r6, r6, #6
00025730  0050a0e3    mov        r5, #0
00025734  0070e0e3    mvn        r7, #0
00025738  09908fe0    add        sb, pc, sb
0002573c  180055e3    cmp        r5, #0x18
00025740  9dffff0a    beq        #0x255bc
00025744  050086e0    add        r0, r6, r5
00025748  085085e2    add        r5, r5, #8
0002574c  b000d0e1    ldrh       r0, [r0]
00025750  200010e3    tst        r0, #0x20
00025754  f8ffff0a    beq        #0x2573c
00025758  010077e3    cmn        r7, #1
0002575c  0300000a    beq        #0x25770
00025760  0700a0e1    mov        r0, r7
00025764  f9f710eb    bl         #0x463750
00025768  010070e3    cmn        r0, #1
0002576c  f2ffff1a    bne        #0x2573c
00025770  0900a0e1    mov        r0, sb
00025774  0210a0e3    mov        r1, #2
00025778  0020a0e3    mov        r2, #0
0002577c  7ab410eb    bl         #0x45296c
00025780  0070a0e1    mov        r7, r0
00025784  010070e3    cmn        r0, #1
00025788  ebffff1a    bne        #0x2573c
0002578c  240000ea    b          #0x25824
00025790  a8019fe5    ldr        r0, [pc, #0x1a8]
00025794  0210a0e3    mov        r1, #2
00025798  0020a0e3    mov        r2, #0
0002579c  00008fe0    add        r0, pc, r0
000257a0  71b410eb    bl         #0x45296c
000257a4  0060a0e1    mov        r6, r0
000257a8  010070e3    cmn        r0, #1
000257ac  74ffff1a    bne        #0x25584
000257b0  1b0000ea    b          #0x25824
000257b4  010076e3    cmn        r6, #1
000257b8  0300000a    beq        #0x257cc
000257bc  0600a0e1    mov        r0, r6
000257c0  e2f710eb    bl         #0x463750
000257c4  010070e3    cmn        r0, #1
000257c8  74ffff1a    bne        #0x255a0
000257cc  70019fe5    ldr        r0, [pc, #0x170]
000257d0  0210a0e3    mov        r1, #2
000257d4  0020a0e3    mov        r2, #0
000257d8  00008fe0    add        r0, pc, r0
000257dc  62b410eb    bl         #0x45296c
000257e0  0060a0e1    mov        r6, r0
000257e4  010070e3    cmn        r0, #1
000257e8  6cffff1a    bne        #0x255a0
000257ec  0c0000ea    b          #0x25824
000257f0  010076e3    cmn        r6, #1
000257f4  0300000a    beq        #0x25808
000257f8  0600a0e1    mov        r0, r6
000257fc  d3f710eb    bl         #0x463750
00025800  010070e3    cmn        r0, #1
00025804  6cffff1a    bne        #0x255bc
00025808  38019fe5    ldr        r0, [pc, #0x138]
0002580c  0210a0e3    mov        r1, #2
00025810  0020a0e3    mov        r2, #0
00025814  00008fe0    add        r0, pc, r0
00025818  53b410eb    bl         #0x45296c
0002581c  010070e3    cmn        r0, #1
00025820  65ffff1a    bne        #0x255bc
00025824  27b310eb    bl         #0x4524c8
00025828  1c219fe5    ldr        r2, [pc, #0x11c]
0002582c  02208fe0    add        r2, pc, r2
00025830  08008de2    add        r0, sp, #8
00025834  6130a0e3    mov        r3, #0x61
00025838  fff402eb    bl         #0xe2c3c
0002583c  0800dde5    ldrb       r0, [sp, #8]
00025840  030050e3    cmp        r0, #3
00025844  0200001a    bne        #0x25854
00025848  0c009de5    ldr        r0, [sp, #0xc]
0002584c  0c1090e5    ldr        r1, [r0, #0xc]
00025850  31ff2fe1    blx        r1
00025854  4cadffeb    bl         #0x10d8c
00025858  00019fe5    ldr        r0, [pc, #0x100]
0002585c  0120a0e3    mov        r2, #1
00025860  fc309fe5    ldr        r3, [pc, #0xfc]
00025864  fc109fe5    ldr        r1, [pc, #0xfc]
00025868  00008fe0    add        r0, pc, r0
0002586c  9b20cde5    strb       r2, [sp, #0x9b]
00025870  9b208de2    add        r2, sp, #0x9b
00025874  01108fe0    add        r1, pc, r1
00025878  03308fe0    add        r3, pc, r3
0002587c  08208de5    str        r2, [sp, #8]
00025880  08208de2    add        r2, sp, #8
00025884  00108de5    str        r1, [sp]
00025888  0010a0e3    mov        r1, #0
0002588c  85beffeb    bl         #0x152a8
00025890  95ffffea    b          #0x256ec
00025894  7abeffeb    bl         #0x15284
00025898  220000ea    b          #0x25928
0002589c  0020a0e3    mov        r2, #0
000258a0  1ff07ff5    clrex      
000258a4  000052e3    cmp        r2, #0
000258a8  9bffff1a    bne        #0x2571c
000258ac  000051e1    cmp        r1, r0
000258b0  0100000a    beq        #0x258bc
000258b4  51f810eb    bl         #0x463a00
000258b8  fdffffea    b          #0x258b4
000258bc  a8009fe5    ldr        r0, [pc, #0xa8]
000258c0  00008fe0    add        r0, pc, r0
000258c4  44abffeb    bl         #0x105dc
000258c8  8cbfffeb    bl         #0x15700
000258cc  0150a0e1    mov        r5, r1
000258d0  001091e5    ldr        r1, [r1]
000258d4  0070a0e1    mov        r7, r0
000258d8  000051e3    cmp        r1, #0
000258dc  0100000a    beq        #0x258e8
000258e0  0700a0e1    mov        r0, r7
000258e4  31ff2fe1    blx        r1
000258e8  040095e5    ldr        r0, [r5, #4]
000258ec  6560a0e3    mov        r6, #0x65
000258f0  000050e3    cmp        r0, #0
000258f4  76ffff0a    beq        #0x256d4
000258f8  0700a0e1    mov        r0, r7
000258fc  5bb510eb    bl         #0x452e70
00025900  73ffffea    b          #0x256d4
00025904  0060a0e1    mov        r6, r0
00025908  040095e5    ldr        r0, [r5, #4]
0002590c  000050e3    cmp        r0, #0
00025910  0100000a    beq        #0x2591c
00025914  0700a0e1    mov        r0, r7
00025918  54b510eb    bl         #0x452e70
0002591c  0600a0e1    mov        r0, r6
00025920  76bfffeb    bl         #0x15700
00025924  9dbfffeb    bl         #0x157a0
00025928  fedeffe7    trap       
0002592c  73bfffeb    bl         #0x15700
00025930  aabfffeb    bl         #0x157e0

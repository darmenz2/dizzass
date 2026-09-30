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

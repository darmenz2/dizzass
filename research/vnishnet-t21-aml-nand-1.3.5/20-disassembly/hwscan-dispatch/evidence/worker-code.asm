000e6524  f04d2de9    push       {r4, r5, r6, r7, r8, sl, fp, lr}
000e6528  18b08de2    add        fp, sp, #0x18
000e652c  10d04de2    sub        sp, sp, #0x10
000e6530  0050a0e1    mov        r5, r0
000e6534  0300a0e3    mov        r0, #3
000e6538  0140a0e1    mov        r4, r1
000e653c  de6100eb    bl         #0xfecbc
000e6540  d0059fe5    ldr        r0, [pc, #0x5d0]
000e6544  00008fe0    add        r0, pc, r0
000e6548  d66200eb    bl         #0xff0a8
000e654c  000050e3    cmp        r0, #0
000e6550  4400001a    bne        #0xe6668
000e6554  c8059fe5    ldr        r0, [pc, #0x5c8]
000e6558  ff1100e3    movw       r1, #0x1ff
000e655c  00008fe0    add        r0, pc, r0
000e6560  81cf0deb    bl         #0x45a36c
000e6564  0500a0e1    mov        r0, r5
000e6568  0410a0e1    mov        r1, r4
000e656c  360a00eb    bl         #0xe8e4c
000e6570  010070e3    cmn        r0, #1
000e6574  170000da    ble        #0xe65d8
000e6578  b8759fe5    ldr        r7, [pc, #0x5b8]
000e657c  0010a0e3    mov        r1, #0
000e6580  0020a0e3    mov        r2, #0
000e6584  0130a0e3    mov        r3, #1
000e6588  0140a0e3    mov        r4, #1
000e658c  07709fe7    ldr        r7, [pc, r7]
000e6590  00108de5    str        r1, [sp]
000e6594  0210a0e3    mov        r1, #2
000e6598  000097e5    ldr        r0, [r7]
000e659c  136400eb    bl         #0xff5f0
000e65a0  000050e3    cmp        r0, #0
000e65a4  1b00000a    beq        #0xe6618
000e65a8  8c059fe5    ldr        r0, [pc, #0x58c]
000e65ac  8c159fe5    ldr        r1, [pc, #0x58c]
000e65b0  8c259fe5    ldr        r2, [pc, #0x58c]
000e65b4  00008fe0    add        r0, pc, r0
000e65b8  88359fe5    ldr        r3, [pc, #0x588]
000e65bc  01108fe0    add        r1, pc, r1
000e65c0  02208fe0    add        r2, pc, r2
000e65c4  00408de5    str        r4, [sp]
000e65c8  03308fe0    add        r3, pc, r3
000e65cc  04308de5    str        r3, [sp, #4]
000e65d0  4d3fa0e3    mov        r3, #0x134
000e65d4  0b0000ea    b          #0xe6608
000e65d8  48059fe5    ldr        r0, [pc, #0x548]
000e65dc  0170a0e3    mov        r7, #1
000e65e0  44159fe5    ldr        r1, [pc, #0x544]
000e65e4  44259fe5    ldr        r2, [pc, #0x544]
000e65e8  00008fe0    add        r0, pc, r0
000e65ec  40359fe5    ldr        r3, [pc, #0x540]
000e65f0  01108fe0    add        r1, pc, r1
000e65f4  02208fe0    add        r2, pc, r2
000e65f8  00708de5    str        r7, [sp]
000e65fc  03308fe0    add        r3, pc, r3
000e6600  04308de5    str        r3, [sp, #4]
000e6604  2f3100e3    movw       r3, #0x12f
000e6608  286200eb    bl         #0xfeeb0
000e660c  0000e0e3    mvn        r0, #0
000e6610  18d04be2    sub        sp, fp, #0x18
000e6614  f08dbde8    pop        {r4, r5, r6, r7, r8, sl, fp, pc}
000e6618  fe0200eb    bl         #0xe7218
000e661c  000050e3    cmp        r0, #0
000e6620  f9ffff0a    beq        #0xe660c
000e6624  0040a0e1    mov        r4, r0
000e6628  ccfeffeb    bl         #0xe6160
000e662c  000050e3    cmp        r0, #0
000e6630  1500000a    beq        #0xe668c
000e6634  10059fe5    ldr        r0, [pc, #0x510]
000e6638  0170a0e3    mov        r7, #1
000e663c  0c159fe5    ldr        r1, [pc, #0x50c]
000e6640  0c259fe5    ldr        r2, [pc, #0x50c]
000e6644  00008fe0    add        r0, pc, r0
000e6648  08359fe5    ldr        r3, [pc, #0x508]
000e664c  01108fe0    add        r1, pc, r1
000e6650  02208fe0    add        r2, pc, r2
000e6654  00708de5    str        r7, [sp]
000e6658  03308fe0    add        r3, pc, r3
000e665c  04308de5    str        r3, [sp, #4]
000e6660  3d3100e3    movw       r3, #0x13d
000e6664  180000ea    b          #0xe66cc
000e6668  ac049fe5    ldr        r0, [pc, #0x4ac]
000e666c  0120a0e3    mov        r2, #1
000e6670  a8149fe5    ldr        r1, [pc, #0x4a8]
000e6674  00008fe0    add        r0, pc, r0
000e6678  01109fe7    ldr        r1, [pc, r1]
000e667c  003091e5    ldr        r3, [r1]
000e6680  1810a0e3    mov        r1, #0x18
000e6684  a6d20deb    bl         #0x45b124
000e6688  dfffffea    b          #0xe660c
000e668c  0400a0e1    mov        r0, r4
000e6690  5dffffeb    bl         #0xe640c
000e6694  000050e3    cmp        r0, #0
000e6698  4500000a    beq        #0xe67b4
000e669c  b8049fe5    ldr        r0, [pc, #0x4b8]
000e66a0  0170a0e3    mov        r7, #1
000e66a4  b4149fe5    ldr        r1, [pc, #0x4b4]
000e66a8  b4249fe5    ldr        r2, [pc, #0x4b4]
000e66ac  00008fe0    add        r0, pc, r0
000e66b0  b0349fe5    ldr        r3, [pc, #0x4b0]
000e66b4  01108fe0    add        r1, pc, r1
000e66b8  02208fe0    add        r2, pc, r2
000e66bc  00708de5    str        r7, [sp]
000e66c0  03308fe0    add        r3, pc, r3
000e66c4  04308de5    str        r3, [sp, #4]
000e66c8  423100e3    movw       r3, #0x142
000e66cc  f76100eb    bl         #0xfeeb0
000e66d0  db0400eb    bl         #0xe7a44
000e66d4  000050e3    cmp        r0, #0
000e66d8  1e00000a    beq        #0xe6758
000e66dc  28059fe5    ldr        r0, [pc, #0x528]
000e66e0  0370a0e3    mov        r7, #3
000e66e4  24159fe5    ldr        r1, [pc, #0x524]
000e66e8  24259fe5    ldr        r2, [pc, #0x524]
000e66ec  00008fe0    add        r0, pc, r0
000e66f0  20359fe5    ldr        r3, [pc, #0x520]
000e66f4  01108fe0    add        r1, pc, r1
000e66f8  02208fe0    add        r2, pc, r2
000e66fc  00708de5    str        r7, [sp]
000e6700  03308fe0    add        r3, pc, r3
000e6704  04308de5    str        r3, [sp, #4]
000e6708  893100e3    movw       r3, #0x189
000e670c  e76100eb    bl         #0xfeeb0
000e6710  100084e2    add        r0, r4, #0x10
000e6714  0110a0e3    mov        r1, #1
000e6718  587600eb    bl         #0x104080
000e671c  000050e3    cmp        r0, #0
000e6720  0c00000a    beq        #0xe6758
000e6724  f0049fe5    ldr        r0, [pc, #0x4f0]
000e6728  0270a0e3    mov        r7, #2
000e672c  ec149fe5    ldr        r1, [pc, #0x4ec]
000e6730  ec249fe5    ldr        r2, [pc, #0x4ec]
000e6734  00008fe0    add        r0, pc, r0
000e6738  e8349fe5    ldr        r3, [pc, #0x4e8]
000e673c  01108fe0    add        r1, pc, r1
000e6740  02208fe0    add        r2, pc, r2
000e6744  00708de5    str        r7, [sp]
000e6748  03308fe0    add        r3, pc, r3
000e674c  04308de5    str        r3, [sp, #4]
000e6750  633fa0e3    mov        r3, #0x18c
000e6754  d56100eb    bl         #0xfeeb0
000e6758  0400a0e1    mov        r0, r4
000e675c  ef0200eb    bl         #0xe7320
000e6760  cc0400eb    bl         #0xe7a98
000e6764  000050e3    cmp        r0, #0
000e6768  0c00000a    beq        #0xe67a0
000e676c  b8049fe5    ldr        r0, [pc, #0x4b8]
000e6770  0170a0e3    mov        r7, #1
000e6774  b4149fe5    ldr        r1, [pc, #0x4b4]
000e6778  b4249fe5    ldr        r2, [pc, #0x4b4]
000e677c  00008fe0    add        r0, pc, r0
000e6780  b0349fe5    ldr        r3, [pc, #0x4b0]
000e6784  01108fe0    add        r1, pc, r1
000e6788  02208fe0    add        r2, pc, r2
000e678c  00708de5    str        r7, [sp]
000e6790  03308fe0    add        r3, pc, r3
000e6794  04308de5    str        r3, [sp, #4]
000e6798  1730a0e3    mov        r3, #0x17
000e679c  c36100eb    bl         #0xfeeb0
000e67a0  a56800eb    bl         #0x100a3c
000e67a4  456200eb    bl         #0xff0c0
000e67a8  0000a0e3    mov        r0, #0
000e67ac  18d04be2    sub        sp, fp, #0x18
000e67b0  f08dbde8    pop        {r4, r5, r6, r7, r8, sl, fp, pc}
000e67b4  b0539fe5    ldr        r5, [pc, #0x3b0]
000e67b8  0400a0e1    mov        r0, r4
000e67bc  05509fe7    ldr        r5, [pc, r5]
000e67c0  001095e5    ldr        r1, [r5]
000e67c4  000051e3    cmp        r1, #0
000e67c8  01100013    movwne     r1, #1
000e67cc  0b0200eb    bl         #0xe7000
000e67d0  000095e5    ldr        r0, [r5]
000e67d4  000050e3    cmp        r0, #0
000e67d8  bcffff1a    bne        #0xe66d0
000e67dc  0c0094e5    ldr        r0, [r4, #0xc]
000e67e0  4c0200eb    bl         #0xe7118
000e67e4  000050e3    cmp        r0, #0
000e67e8  5800000a    beq        #0xe6950
000e67ec  0050a0e1    mov        r5, r0
000e67f0  930400eb    bl         #0xe7a44
000e67f4  000050e3    cmp        r0, #0
000e67f8  1e00000a    beq        #0xe6878
000e67fc  7c039fe5    ldr        r0, [pc, #0x37c]
000e6800  0360a0e3    mov        r6, #3
000e6804  78139fe5    ldr        r1, [pc, #0x378]
000e6808  78239fe5    ldr        r2, [pc, #0x378]
000e680c  00008fe0    add        r0, pc, r0
000e6810  74339fe5    ldr        r3, [pc, #0x374]
000e6814  01108fe0    add        r1, pc, r1
000e6818  02208fe0    add        r2, pc, r2
000e681c  00608de5    str        r6, [sp]
000e6820  03308fe0    add        r3, pc, r3
000e6824  04308de5    str        r3, [sp, #4]
000e6828  523100e3    movw       r3, #0x152
000e682c  9f6100eb    bl         #0xfeeb0
000e6830  100084e2    add        r0, r4, #0x10
000e6834  0010a0e3    mov        r1, #0
000e6838  107600eb    bl         #0x104080
000e683c  000050e3    cmp        r0, #0
000e6840  0c00000a    beq        #0xe6878
000e6844  44039fe5    ldr        r0, [pc, #0x344]
000e6848  0260a0e3    mov        r6, #2
000e684c  40139fe5    ldr        r1, [pc, #0x340]
000e6850  40239fe5    ldr        r2, [pc, #0x340]
000e6854  00008fe0    add        r0, pc, r0
000e6858  3c339fe5    ldr        r3, [pc, #0x33c]
000e685c  01108fe0    add        r1, pc, r1
000e6860  02208fe0    add        r2, pc, r2
000e6864  00608de5    str        r6, [sp]
000e6868  03308fe0    add        r3, pc, r3
000e686c  04308de5    str        r3, [sp, #4]
000e6870  553100e3    movw       r3, #0x155
000e6874  8d6100eb    bl         #0xfeeb0
000e6878  20839fe5    ldr        r8, [pc, #0x320]
000e687c  08809fe7    ldr        r8, [pc, r8]
000e6880  000098e5    ldr        r0, [r8]
000e6884  000050e3    cmp        r0, #0
000e6888  1400001a    bne        #0xe68e0
000e688c  000095e5    ldr        r0, [r5]
000e6890  a8fafceb    bl         #0x25338
000e6894  000050e3    cmp        r0, #0
000e6898  1000000a    beq        #0xe68e0
000e689c  0400a0e1    mov        r0, r4
000e68a0  2b0900eb    bl         #0xe8d54
000e68a4  000050e3    cmp        r0, #0
000e68a8  0c00000a    beq        #0xe68e0
000e68ac  f0029fe5    ldr        r0, [pc, #0x2f0]
000e68b0  0160a0e3    mov        r6, #1
000e68b4  ec129fe5    ldr        r1, [pc, #0x2ec]
000e68b8  ec229fe5    ldr        r2, [pc, #0x2ec]
000e68bc  00008fe0    add        r0, pc, r0
000e68c0  e8329fe5    ldr        r3, [pc, #0x2e8]
000e68c4  01108fe0    add        r1, pc, r1
000e68c8  02208fe0    add        r2, pc, r2
000e68cc  00608de5    str        r6, [sp]
000e68d0  03308fe0    add        r3, pc, r3
000e68d4  04308de5    str        r3, [sp, #4]
000e68d8  5b3100e3    movw       r3, #0x15b
000e68dc  736100eb    bl         #0xfeeb0
000e68e0  c20200eb    bl         #0xe73f0
000e68e4  000050e3    cmp        r0, #0
000e68e8  2500000a    beq        #0xe6984
000e68ec  0060a0e1    mov        r6, r0
000e68f0  000098e5    ldr        r0, [r8]
000e68f4  000050e3    cmp        r0, #0
000e68f8  2e00000a    beq        #0xe69b8
000e68fc  0400a0e1    mov        r0, r4
000e6900  7a0100eb    bl         #0xe6ef0
000e6904  001095e5    ldr        r1, [r5]
000e6908  0400a0e1    mov        r0, r4
000e690c  0620a0e1    mov        r2, r6
000e6910  b7fdffeb    bl         #0xe5ff4
000e6914  000050e3    cmp        r0, #0
000e6918  5800000a    beq        #0xe6a80
000e691c  c8029fe5    ldr        r0, [pc, #0x2c8]
000e6920  0170a0e3    mov        r7, #1
000e6924  c4129fe5    ldr        r1, [pc, #0x2c4]
000e6928  c4229fe5    ldr        r2, [pc, #0x2c4]
000e692c  00008fe0    add        r0, pc, r0
000e6930  c0329fe5    ldr        r3, [pc, #0x2c0]
000e6934  01108fe0    add        r1, pc, r1
000e6938  02208fe0    add        r2, pc, r2
000e693c  00708de5    str        r7, [sp]
000e6940  03308fe0    add        r3, pc, r3
000e6944  04308de5    str        r3, [sp, #4]
000e6948  823100e3    movw       r3, #0x182
000e694c  5effffea    b          #0xe66cc
000e6950  18029fe5    ldr        r0, [pc, #0x218]
000e6954  0170a0e3    mov        r7, #1
000e6958  14129fe5    ldr        r1, [pc, #0x214]
000e695c  14229fe5    ldr        r2, [pc, #0x214]
000e6960  00008fe0    add        r0, pc, r0
000e6964  10329fe5    ldr        r3, [pc, #0x210]
000e6968  01108fe0    add        r1, pc, r1
000e696c  02208fe0    add        r2, pc, r2
000e6970  00708de5    str        r7, [sp]
000e6974  03308fe0    add        r3, pc, r3
000e6978  04308de5    str        r3, [sp, #4]
000e697c  4d3100e3    movw       r3, #0x14d
000e6980  51ffffea    b          #0xe66cc
000e6984  28029fe5    ldr        r0, [pc, #0x228]
000e6988  0170a0e3    mov        r7, #1
000e698c  24129fe5    ldr        r1, [pc, #0x224]
000e6990  24229fe5    ldr        r2, [pc, #0x224]
000e6994  00008fe0    add        r0, pc, r0
000e6998  20329fe5    ldr        r3, [pc, #0x220]
000e699c  01108fe0    add        r1, pc, r1
000e69a0  02208fe0    add        r2, pc, r2
000e69a4  00708de5    str        r7, [sp]
000e69a8  03308fe0    add        r3, pc, r3
000e69ac  04308de5    str        r3, [sp, #4]
000e69b0  613100e3    movw       r3, #0x161
000e69b4  44ffffea    b          #0xe66cc
000e69b8  000095e5    ldr        r0, [r5]
000e69bc  000050e3    cmp        r0, #0
000e69c0  3b00000a    beq        #0xe6ab4
000e69c4  000097e5    ldr        r0, [r7]
000e69c8  007095e5    ldr        r7, [r5]
000e69cc  140900eb    bl         #0xe8e24
000e69d0  102096e5    ldr        r2, [r6, #0x10]
000e69d4  0010a0e1    mov        r1, r0
000e69d8  143096e5    ldr        r3, [r6, #0x14]
000e69dc  960fa0e3    mov        r0, #0x258
000e69e0  00008de5    str        r0, [sp]
000e69e4  0700a0e1    mov        r0, r7
000e69e8  76f5fceb    bl         #0x23fc8
000e69ec  000050e3    cmp        r0, #0
000e69f0  0300001a    bne        #0xe6a04
000e69f4  000095e5    ldr        r0, [r5]
000e69f8  09f1fceb    bl         #0x22e24
000e69fc  000050e3    cmp        r0, #0
000e6a00  bdffff0a    beq        #0xe68fc
000e6a04  000095e5    ldr        r0, [r5]
000e6a08  5e3fa0e3    mov        r3, #0x178
000e6a0c  c0119fe5    ldr        r1, [pc, #0x1c0]
000e6a10  c0519fe5    ldr        r5, [pc, #0x1c0]
000e6a14  000050e3    cmp        r0, #0
000e6a18  bc619fe5    ldr        r6, [pc, #0x1bc]
000e6a1c  01108fe0    add        r1, pc, r1
000e6a20  b8719fe5    ldr        r7, [pc, #0x1b8]
000e6a24  05508fe0    add        r5, pc, r5
000e6a28  b4219fe5    ldr        r2, [pc, #0x1b4]
000e6a2c  06608fe0    add        r6, pc, r6
000e6a30  07708fe0    add        r7, pc, r7
000e6a34  0010a011    movne      r1, r0
000e6a38  02208fe0    add        r2, pc, r2
000e6a3c  0100a0e3    mov        r0, #1
000e6a40  05008de8    stm        sp, {r0, r2}
000e6a44  0500a0e1    mov        r0, r5
000e6a48  0720a0e1    mov        r2, r7
000e6a4c  08108de5    str        r1, [sp, #8]
000e6a50  0610a0e1    mov        r1, r6
000e6a54  156100eb    bl         #0xfeeb0
000e6a58  88019fe5    ldr        r0, [pc, #0x188]
000e6a5c  0310a0e3    mov        r1, #3
000e6a60  00108de5    str        r1, [sp]
000e6a64  0610a0e1    mov        r1, r6
000e6a68  00008fe0    add        r0, pc, r0
000e6a6c  04008de5    str        r0, [sp, #4]
000e6a70  0500a0e1    mov        r0, r5
000e6a74  0720a0e1    mov        r2, r7
000e6a78  793100e3    movw       r3, #0x179
000e6a7c  1d0000ea    b          #0xe6af8
000e6a80  74019fe5    ldr        r0, [pc, #0x174]
000e6a84  0370a0e3    mov        r7, #3
000e6a88  70119fe5    ldr        r1, [pc, #0x170]
000e6a8c  70219fe5    ldr        r2, [pc, #0x170]
000e6a90  00008fe0    add        r0, pc, r0
000e6a94  6c319fe5    ldr        r3, [pc, #0x16c]
000e6a98  01108fe0    add        r1, pc, r1
000e6a9c  02208fe0    add        r2, pc, r2
000e6aa0  00708de5    str        r7, [sp]
000e6aa4  03308fe0    add        r3, pc, r3
000e6aa8  04308de5    str        r3, [sp, #4]
000e6aac  863100e3    movw       r3, #0x186
000e6ab0  05ffffea    b          #0xe66cc
000e6ab4  0c1095e5    ldr        r1, [r5, #0xc]
000e6ab8  0400a0e1    mov        r0, r4
000e6abc  21feffeb    bl         #0xe6348
000e6ac0  000050e3    cmp        r0, #0
000e6ac4  0f00000a    beq        #0xe6b08
000e6ac8  f4009fe5    ldr        r0, [pc, #0xf4]
000e6acc  0170a0e3    mov        r7, #1
000e6ad0  f0109fe5    ldr        r1, [pc, #0xf0]
000e6ad4  f0209fe5    ldr        r2, [pc, #0xf0]
000e6ad8  00008fe0    add        r0, pc, r0
000e6adc  ec309fe5    ldr        r3, [pc, #0xec]
000e6ae0  01108fe0    add        r1, pc, r1
000e6ae4  02208fe0    add        r2, pc, r2
000e6ae8  00708de5    str        r7, [sp]
000e6aec  03308fe0    add        r3, pc, r3
000e6af0  04308de5    str        r3, [sp, #4]
000e6af4  5a3fa0e3    mov        r3, #0x168
000e6af8  ec6000eb    bl         #0xfeeb0
000e6afc  0400a0e1    mov        r0, r4
000e6b00  fa0000eb    bl         #0xe6ef0
000e6b04  f1feffea    b          #0xe66d0
000e6b08  000098e5    ldr        r0, [r8]
000e6b0c  000050e3    cmp        r0, #0
000e6b10  79ffff1a    bne        #0xe68fc
000e6b14  aaffffea    b          #0xe69c4

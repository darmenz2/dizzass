# Original ANALOG_MUX_CTRL method

Parent task checkpoint: `8717119980ba3b15b4e8e195448436460f799f2f`, based on
`work/reconstruction` at `01299b84255542c16ee6d3f0c65a3e33e7aa876a`.
Fresh repository scopes were checked on 2026-10-02: no overlapping open PR
files or reservations for this method. No shared branch or existing source is
modified by this slice. This is a bounded ordinary effect projection.

## Original identities and bounds

| Image | Bytes | Full SHA256 |
| --- | ---: | --- |
| cgminer | 6228004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4883216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

All ends are exclusive. cgminer code `[e35c0,e36fc)` is 316 bytes, SHA256
`66b80d0c510d52d24e75c203cddd4039dd2404827a9143b3ec416e197d0814c7`.
The 44-byte literal pool `[e36fc,e3728)` has SHA256
`7b589d52da228d2b6afd416a5ec79264f078e8ad4c7e587f1f165fb485474362`.
The final pop at e36f8 prevents pool fallthrough. The next constructor method
starts at e3728. Unwind extent is corroboration, not a sole boundary proof.

hwscan code `[f3354,f33dc)` is 136 bytes, SHA256
`73089e7c276c3807b8b0c1852113c621dd32a6a46b43772f0726a32ca21442a6`.
Its 16-byte pool `[f33dc,f33ec)` has SHA256
`6ca72d86e1b3e0e58906bd877defa83a95d9c0ac9fe0c992e398eeda426a0eec`.
Its final pop is f33d8; the next +0x84 method starts at f33ec. It does not
contain cgminer's opaque blocks. No whole-body byte parity is asserted.

## Constructor identity

The reviewed constructor entry is cgminer e1450, hwscan f1d28. cgminer
e1548/e154c uses literal e1714, GOT cell 5dfe04 containing e35c0. e155c forms
output+0x80 and e1560 stores the retained r1 there. The corresponding hwscan
f1e20/f1e24 uses f1fec and GOT 4afbd8 containing f3354; f1e38 stores +0x80.
The seven constructor instructions are identical, with relocated literals
and GOT cells. Numeric original addresses remain data, never host pointers.
This identity does not establish a runtime call, T21 lifecycle or ASIC identity.

## Ordinary effect contract

Original arguments are r0=device and r1=input. cgminer e35d0 / hwscan f3364
mask input with 7. The sole writer calls at e35ec/f3384 receive the original
device, mode 1, NULL chip, register 0x54 and that low-three-bit word. They call
the already recovered BM1368 writer e4a74/f3d7c. No range rejection or meaning
of individual analog mux selections is inferred.

Exactly-zero writer status returns zero without a diagnostic. Any nonzero
status emits exactly one severity-1 line-425 diagnostic through fa0c4/feeb0,
then returns signed -1. The original current device+0x18 index is read at
e3644/f33a0 after the writer returns, then incremented modulo 2^32. A writer
callback's field mutation affects that index. The logger's result is ignored.
There is no wrapper retry, wait, second write, cached read, ACK or rollback.

The C entry calls the actual existing `vn135_bm1368_write_register_135`, which
uses the accepted SET_CONFIG encoder/CRC, a nine-byte payload and chain cache
fanout for mode 1. It reads the cache chain index after send. A send failure
may emit the writer's separate line-350 diagnostic before this line-425 event.
That lower diagnostic can also mutate the index subsequently read here.
Cache failure occurs after dispatch. Tests compose these implementations with
recording/refusal terminal callbacks; they provide no device acknowledgements.

Only the previously recovered pure `vn135_bm1398_analog_mux_word` is reused:
the BM1398 original ece4c and both BM1368 methods perform AND #7. The BM1398
writer, diagnostics and driver identity are not imported. This is a reviewed
computational reuse, not evidence that BM1398 is the T21 driver.

## Opaque predicates

cgminer contains three `x*(x-1)` low-32-bit products. Each subtraction and
multiply uses the same loaded x snapshot; no stability between separate loads
is assumed. Modulo 2, the product is `b*(b xor 1)`, which is zero for both
`b=0` and `b=1`. ARM wrap and low-32-bit multiplication preserve that bit.
Thus each following `TST #1` sets Z and its BEQ is always taken:

| x load | subtract/multiply | test/branch | taken target |
| --- | --- | --- | --- |
| e3600 | e3608/e360c | e361c/e3620 | e3630 |
| e3664 | e366c/e3670 | e3674/e3678 | e36c0 |
| e36d0 | e36d4/e36d8 | e36dc/e36e0 | e36f0 |

Consequently the extra logger at e36b8 and final back-edge e36ec are
unreachable in normal arithmetic. They are not a second log or retry.
The GOT cells 5deda4/5df124 identify x/y at 68b7e8/68b81c in .bss. The
ordinary path still performs valid GOT/global reads (including obtaining
y's pointer), which the effect projection omits. Dead branches do not read
y's value. Valid mapped storage, unaltered control flow, ordinary returning
callees and no memory faults are required; access/fault traces are excluded.
The proof needs no assumption that .bss remains zero. hwscan independently
has a straightforward one-log path without these predicates.

## Diagnostic metadata

Exact strings: module `driver`, source
`/tmp/build/libbitmain/src/chip/chip1368.c`, function `[redacted]`, format
`chain#%d - failed to set ANALOG_MUX_CTRL`. The function name is literal
redacted metadata, not an inferred recovered name.

| Text | cgminer | Bytes with NUL | XOR key | hwscan plaintext |
| --- | --- | ---: | ---: | --- |
| module | 5eb3e0 | 7 | 1e | 47d914 |
| source | 5eb3e7 | 42 | d8 | 47e7ef |
| function | 5eb411 | 11 | d1 | 47d359 |
| format | 5eb442 | 41 | 1e | 47e237 |

The packet pins method PC-relative references, the e5370 initializer's
registration, target/count/XOR code and literal witnesses for these strings.
For the new format, e55bc forms 5eb442, e55c4 checks count 41 and e55f4 XORs
0x1e. Text represents one completed ordinary initialization pass. Arbitrary
runtime string changes and original formatting internals are outside scope.

## Domain and verification limits

The typed device and callbacks are existing host projections, not original
struct layouts. Device, writer/context and reached storage remain valid for
synchronous returning calls with fixed callback identities. Fields may mutate
at callback boundaries. Failure requires a valid log/emit; success does not
read log. Temporary diagnostics and payloads cannot escape their callback.
Serialize concurrent effects externally; invalid pointers, races, nonlocal
returns, faults and aliasing callback code/storage are excluded.

The verifier pins full input identities, bounded exact bytes and reviewed
annotations, including independent packet and core-region hashes. Its explicit
checks remain active under Python -O. It neither executes nor interprets
instructions and does not automatically prove C equivalence. Authored host
tests and compiled semantic controls check the C projection and real lower
composition. Ghidra was readOnly/noanalysis; changes were discarded. No
firmware, emulator, boot, UART, hardware wait, ASIC, pool or production driver
registration was exercised. T21 runtime reachability and acceptance remain
unestablished.

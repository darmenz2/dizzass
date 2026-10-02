# Original per-chip drive-strength method

Parent: `2eddeee38d62fb2138acde90061b9268523dddd7`, task branch
`codex/hardware-reverse-20261002`. Integration ref remains
`01299b84255542c16ee6d3f0c65a3e33e7aa876a`. Fresh fetched refs and 19 open PR
scopes were checked on 2026-10-02; no recovered +0x84 body or overlapping PR
was found. The full recent issue #2 comment batch was unavailable through
anonymous API rate limits; this is a scope-check limitation, not evidence of
absence of all parallel research. Existing agreed interfaces are unchanged.

## Exact original bounds

| Image | File bytes | Full SHA256 |
| --- | ---: | --- |
| cgminer | 6228004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4883216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

All ends are exclusive. cgminer code `[e3728,e39dc)` is 692 bytes, SHA256
`ab79cf5615e41cef3bc606d43ce2c968eac107d2cd9fcd6d3f7a91d36641e7c0`.
Its 64-byte pool `[e39dc,e3a1c)` has SHA256
`39fc48af7ddeb65eb8d2865894d3582c1c207bbe4814c6a914e8a29eef081e9b`.
The pop at e39d8 prevents fallthrough; e3a1c is the next constructor method.

hwscan code `[f33ec,f34dc)` is 240 bytes, SHA256
`87406b9d1f21eb417d04ea324ec294966bc2d5d3a8d4f7678167024538fbb9b7`.
Its 32-byte pool `[f34dc,f34fc)` has SHA256
`ab08ee3c545629e6b4b6fed39c6261baf9e300cb0c7a8bfbdb9dc4844ad7a242`.
The pop at f34d8 prevents pool fallthrough; f34fc is the next +0x88 method.
hwscan has no cgminer opaque blocks; whole-body byte equality is not claimed.

## Constructor

At constructor e1450, e1540 loads literal e1710; e1544 resolves GOT 5df41c
containing e3728 using PC value e154c. The retained r4 is the second word
stored by e1560's `STM` at output+0x80: its resulting slot is +0x84.
hwscan constructor f1d28 uses f1e18/f1e1c, literal f1fe8, PC f1e24 and GOT
4af984 containing f33ec. f1e38 stores the corresponding r4 at +0x84.
The bounded nine constructor words match between images with relocated
literals/GOT. Numeric addresses identify original methods, not host pointers,
physical chips, runtime dispatch or a complete T21 lifetime.

## Cache read and conditional write

Original r0=device, r1=chip, r2=input. A valid readable non-NULL chip is required
before the cache call. cgminer e3784 zeroes the output, e378c reads chip+0,
e3790 reads device+0x18; e3794 calls 1079f0 with chain bits, chip bits,
register 0x58 and that output address. hwscan calls the corresponding 105a20
at f341c. These index arguments have the original signed 32-bit interpretation.

Any nonzero read status emits one severity-1 line-609 diagnostic, then returns
-1. There is no index argument and no writer call; output is never inspected
on this error path, including when a callback wrote a value before refusing.
On exactly-zero status, e3814..e3824 transform the output as
`(cached & ~0xf000) | ((input & 15) << 12)`. No other bit changes and high
input bits have no effect. The local output snapshot survives subsequent
cache-source mutations at the reader callback boundary.

The sole ordinary writer at e3844/f3484 invokes the previously recovered
e4a74/f3d7c: original device, mode 0, original chip pointer, register 0x58,
transformed word. Exactly zero returns 0 without logging. Any nonzero status
emits one severity-1 line-619 diagnostic, returns -1. The indexed failure
reloads current device+0x18 at e391c/f34a4 after the writer returns and adds
one modulo 2^32. The hardware wrapper does not return arbitrary lower status.

The C entry uses a typed reader signature already used by reset, with a thin
function binding to the existing `vn135_reg_cache_get_chip`. That getter uses
first-match stored-address lookup across 64 slots; no new cache or lookup is
introduced. It preserves output on error, omits original internal diagnostics
and has explicit structural guards in its existing host API. Those omissions
and adapter errors remain a boundary; full nested logger parity is not claimed.
The GET_STATUS send helper is unrelated and is not used as a cache read.

The actual BM1368 writer composes the accepted encoder/CRC and cache setter.
It captures chip wire address before send, then reads current device/chip
cache indices after send. Reader mutations therefore affect the transmitted
chip address and later send/cache mutations affect the destination. A send
failure may emit the writer's line-350 diagnostic first, with a mutation that
affects the wrapper's later line-619 index. A cache failure follows dispatch.
No retry, wait, second write, ACK, preflight, rollback or safe preset is added.
Selector 4 defaults are host fixture data, not proof of model identity.

## Opaque branch reduction

Each of seven ARM predicates multiplies one loaded x snapshot by x-1 and tests
bit 0. Modulo 2 the product is `b*(b xor 1)`, always zero for b=0 or 1; low
32-bit truncation preserves it. Each corresponding BEQ is always taken,
regardless of .bss values or changes between separate x loads:

| x load | test/BEQ | taken target |
| --- | --- | --- |
| e3748 | e375c/e3760 | e3770 |
| e3798 | e37a4/e37a8 | e37e0 |
| e37e8 | e37fc/e3800 | e3880 |
| e3854 | e3868/e386c | e3908 |
| e38b0 | e38c0/e38c4 | e39b0 |
| e3948 | e3958/e395c | e39b0 |
| e39b0 | e39bc/e39c0 | e39d0 |

Thus cache read e37d8, loggers e38fc/e39a4, their back-edges and e39cc's loop
are unreachable under normal ARM arithmetic. These are not retries or extra
ordinary diagnostics. GOT 5dfa28/5dfe1c identify x/y at 68b8ac/68b8dc in .bss.
Ordinary GOT/global reads still occur, including obtaining y's pointer; only
dead branches read y's value. The effect projection omits nonfaulting access
traces and requires valid mapped storage, ordinary returning callees, valid
callee-saved state and unaltered control flow. It does not model memory faults.

## Strings and logging boundary

Both paths use module `driver`, source
`/tmp/build/libbitmain/src/chip/chip1368.c`, literal function `[redacted]`.
The latter is not a recovered nonredacted name.

| Metadata | cgminer address | Bytes with NUL | XOR | hwscan plaintext |
| --- | --- | ---: | ---: | --- |
| module | 5eb3e0 | 7 | 1e | 47d914 |
| source | 5eb3e7 | 42 | d8 | 47e7ef |
| function | 5eb411 | 11 | d1 | 47d359 |
| read format | 5eb515 | 46 | f7 | 47e627 |
| write format | 5eb543 | 43 | cc | 47e655 |

Exact read format: `Failed to read cached drive strength register` (line609),
no index argument. Exact write format:
`chain#%d - failed to config drive strength` (line619), current index+1 bits.
The shared hwscan logger call f34c8 receives the selected arguments from the
two ordinary paths; it does not imply that their diagnostic shapes are equal.

The packet pins e5370's .init_array registration at 5dafe4, zero-counter,
target/count/XOR code and literals for all five texts. New read witnesses
cover e57c8..e584c, literal e608c, count46 at e57e0 and XORf7 at e5810;
new write witnesses cover e584c..e58d0, literal e6090, count43 at e5864 and
XORcc at e5894. Text is the result of one completed ordinary initializer pass.
Runtime string changes and variadic formatting internals are not projected.

## Projection domain and actual validation

Device index projects the chip device subobject+0x18, not the enclosing chain's
independent index. `vn135_chip_reference` names cache index+0 and wire word+4,
not original object layout. Required identities/callback associations remain
valid and fixed for synchronous returning calls. Fields may change through
other valid references at callbacks. Reader output, writer payload and logger
event are borrowed; no retention or aliasing with other locals is supported.
Successful cached read requires writer; failure requires logger. Log is not
accessed on success and writer is not accessed on read failure. Concurrent
effects need external serialization. Invalid pointers, faults, races and
nonlocal returns are outside scope.

The evidence checker pins full source identities, independent packet and every
region hash, exact bounded bytes and reviewed annotations. Explicit acceptance
checks survive Python -O. This is integrity of reviewed evidence, not automatic
C equivalence or original instruction execution/interpretation. Host tests
compose real existing cache/writer/encoder/CRC with recording/refusal callbacks;
compiled semantic controls must produce explicit oracle failures. Ghidra ran
readOnly/noanalysis with discarded changes. No firmware, emulator, boot, UART,
ASIC, real wait, pool or production driver registration was exercised. The
T21 runtime caller, hardware acceptance and operational drive setting meanings
remain unestablished. Actual run counts are recorded in validation.json.

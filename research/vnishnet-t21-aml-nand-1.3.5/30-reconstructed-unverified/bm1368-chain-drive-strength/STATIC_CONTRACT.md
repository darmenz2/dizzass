# Original chain drive-strength method

Parent: `f3d1bd1e32303424dbad5cdb17c859097224c646`, task branch
`codex/hardware-reverse-20261002`. Integration ref remains
`01299b84255542c16ee6d3f0c65a3e33e7aa876a`. Fresh remote refs and file scopes
of all 19 open PRs were checked on 2026-10-02; none overlaps this method.
The latest six of issue #2's 66 comments were read through the public API;
the latest is the R-17 report dated 2026-10-01. No +0x88 assignment was found
in that bounded comment read. This does not establish the absence of all
unpublished parallel research. Existing agreed interfaces remain unchanged.

## Exact original bounds

| Image | File bytes | Full SHA256 |
| --- | ---: | --- |
| cgminer | 6228004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4883216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

All ends are exclusive. cgminer code `[e3a1c,e3b88)` is 364 bytes, SHA256
`00a27102185f70ad1daf4b4cd6563a452f66f82d05dc00f3c16077fed104f66d`.
Its 52-byte pool `[e3b88,e3bbc)` has SHA256
`b49c9acc5d6f602266589be59a04b72c79f22508f8cbb34409b6cacc924e2776`.
The pop at e3b84 prevents pool fallthrough; e3bbc is the next method.

hwscan code `[f34fc,f35e8)` is 236 bytes, SHA256
`ecafb850f8afa258e94b955b9d659748d40256e2a96901ca2d199520e837b41b`.
Its 32-byte pool `[f35e8,f3608)` has SHA256
`d030e14b3df65ca118c24296117332ff4fc5e4aea87c0479e9fe8f81aa9a8a29`.
The pop at f35e4 prevents pool fallthrough. hwscan lacks the cgminer opaque
blocks; whole-body byte equality is not claimed.

## Constructor

At constructor e1450, e1538 loads literal e170c; e153c resolves GOT 5df324,
containing e3a1c, with PC value e1544. r5 is retained until e1560 stores
`{r1,r4,r5,r6}` at output+0x80, placing the method at slot +0x88.
hwscan constructor f1d28 uses f1e10/f1e14, literal f1fe4, PC f1e1c and GOT
4afe24 containing f34fc. f1e38 stores its r5 at +0x88. The bounded eleven
constructor words match between images, with relocated literal/GOT values.
Numeric method identities are not host function pointers or proof of T21
dispatch, runtime reachability or physical chip ownership.

## COMMON read and conditional broadcast write

Original r0=device and r1=input. e3a28/e3a30 initializes the local output to
zero. e3a38 reads device+0x18; e3a44 calls COMMON getter 107188 with those
signed 32-bit chain index bits, register 0x58 and the output address.
hwscan performs the corresponding read at f3518/f3524 through 10564c.
There is one ordinary cache read and no chip pointer or chip-index lookup.

Any nonzero read status emits one severity-1 line-635 diagnostic, then returns
-1. This diagnostic has no index argument. No writer is accessed, and output
is not inspected even if the reader wrote a value before returning failure.
On exactly-zero status, e3a8c..e3aa4 transforms the local word as
`(cached & ~0xf000) | ((input & 15) << 12)`. All other cached bits survive;
high input bits have no effect. Input and returned output are local snapshots,
not a second read from mutable cache storage.

The sole ordinary writer at e3ab8/f3590 calls existing e4a74/f3d7c with the
same device identity, mode 1, NULL chip pointer, register 0x58 and transformed
word. Exactly-zero status returns 0 without logging. Any nonzero status emits
one severity-1 line-645 diagnostic and returns -1. The indexed failure loads
current device+0x18 at e3ad4/f35ac after the writer returns and adds one modulo
2^32. It does not reuse the earlier cache-read index or propagate a lower
arbitrary error value as the method's result.

The C entry uses a chain-only typed reader with a thin binding to existing
`vn135_reg_cache_get_chain`. That getter searches the COMMON table's 64 stored
address slots and preserves output on failure. Its existing host interface
adds structural guards and omits original internal diagnostics and access
traces. Those adapter differences are an explicit boundary: this packet pins
the call identity and arguments, not a new proof of every nested getter effect.
There is no new cache, chip lookup, wire GET_STATUS read or pointer cast.

The existing BM1368 writer composes its encoder/CRC with recording or refusing
transport callbacks and the existing chain setter. It encodes mode 1 with
NULL chip address zero, sends once, and only after successful send loads the
then-current signed device index for cache dispatch. Reader/send mutations
may therefore change the cache destination without changing the captured
word sent. A send failure may emit the writer's line-350 diagnostic before
the wrapper's line-645 event; mutations there affect the wrapper's later
index. A later cache failure follows dispatch. There is no retry, wait, ACK,
rollback, second write, preflight or safe drive preset.

`vn135_reg_cache_set_chain` finds the slot in COMMON, updates its value and
updates the same numeric slot in every chip table. It does not separately
search each chip table's register addresses. The composed fixtures use
coherent slot layouts; divergent address arrangements do not justify a
different setter or a claim that every updated chip slot denotes register
0x58. Owned arrays, counts and storage must remain valid; selector fixtures
are test data, not evidence of model identity or recommended settings.

## Opaque branch reduction

Each of two ARM predicates multiplies one loaded x snapshot by x-1 and tests
bit 0. Modulo 2 this is `b*(b xor 1)`, zero for either b=0 or b=1. Low 32-bit
truncation preserves this bit. Each corresponding BEQ is always taken,
without any assumption about BSS initialization, x/y values or stability
between the two separate x loads:

| x load | test/BEQ | taken target |
| --- | --- | --- |
| e3a58 | e3a74/e3a78 | e3b04 |
| e3b2c | e3b3c/e3b40 | e3b7c |

Thus the duplicate read-failure logger e3b74 and back-edge e3b78 are dead.
Ordinary read failure logs once at e3b28, not as a retry loop. GOT 5dedd8 and
5df198 identify x/y at 68b7ec/68b820 in .bss. Obtaining y's pointer still
occurs on the ordinary failure path; only dead branches read y's value at
e3a7c/e3b44. The effect projection omits these nonfaulting access traces and
requires valid mapped storage, ordinary returning callees, preserved
callee-saved state and unaltered control flow. It does not model faults,
asynchronous machine-state changes or races.

## Strings and logging boundary

Both images use module `driver`, source
`/tmp/build/libbitmain/src/chip/chip1368.c` and literal function `[redacted]`.
The latter remains the original literal, not a recovered nonredacted name.

| Metadata | cgminer address | Bytes with NUL | XOR | hwscan plaintext |
| --- | --- | ---: | ---: | --- |
| module | 5eb3e0 | 7 | 1e | 47d914 |
| source | 5eb3e7 | 42 | d8 | 47e7ef |
| function | 5eb411 | 11 | d1 | 47d359 |
| read format | 5eb56e | 47 | a5 | 47e680 |
| write format | 5eb543 | 43 | cc | 47e655 |

Exact read format: `Failed to read cached driver strenght register`, line635,
without index. The `driver` and `strenght` spelling is retained. Exact write
format: `chain#%d - failed to config drive strength`, line645, fresh index+1
bits. hwscan shares logger callsite f35d4 between these ordinary failure paths;
the read path still has no index argument.

The packet pins e5370's .init_array registration at 5dafe4 and bounded
zero-counter, target/count/XOR instructions and literals for all five texts.
The new read witness is e5900..e592c, literal e6094, count47 at e5924 and
XORa5 at e5918. The reused write witness is e584c..e58d0, literal e6090,
count43 at e5864 and XORcc at e5894. Decoded text describes one completed
ordinary initializer pass; later string mutations and variadic formatting
internals are outside this projection.

## Projection domain and validation boundary

Device index projects the original device subobject+0x18. The host structs
and typed API are not vendor/native ABI replacements. Device, callback tables,
contexts and reached reader/writer/logger associations remain valid and fixed
for synchronous returning calls. Fields and reachable valid cache storage may
change at callback boundaries. Reader output, writer packet and diagnostic
objects are borrowed only for their callbacks; escaped temporary pointers
or aliases into other local storage are outside scope. Serialize concurrent
effects externally. Successful cache read requires writer; a reached failure
requires logger. Writer is not accessed on read failure, and logger is not
accessed on success. Invalid pointers, nonlocal returns and memory faults are
not inferred to succeed.

The new chain header reuses the prior drive-strength diagnostic/log types
while declaring a chain-only reader; no per-chip callback cast or artificial
chip argument is introduced. Separate opt-in compilation preserves the real
cgminer core and unchanged production source list.

The evidence checker independently pins the packet digest, full source
identities, each region's bounded bytes/hash and reviewed assembly annotations.
Its explicit acceptance checks remain enabled under Python -O. This establishes
integrity of reviewed static evidence, not automatic C equivalence, original
instruction execution or instruction interpretation. Host tests compose
existing cache/writer/encoder/CRC with controlled callbacks; compiled negative
controls must fail an explicit semantic oracle rather than crash or time out.
Actual commands and results are recorded in validation.json. Original ELF,
firmware, emulator, boot, UART, ASIC, live pool and production driver
registration are not exercised. No direct T21 caller, unusedness, physical
drive-level meaning or hardware acceptance is established.

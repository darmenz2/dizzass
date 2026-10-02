# Original per-chip CLOCK_DELAY_CTRL method

Base: `work/reconstruction` at `01299b84255542c16ee6d3f0c65a3e33e7aa876a`.
This is a bounded static-derived C projection, not original execution or a
complete source/ABI recovery. The implementation changes no existing source.

| Image | Bytes | SHA-256 |
| --- | ---: | --- |
| cgminer | 6228004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4883216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

All range ends are exclusive. The cgminer code is `[e33e0,e34b8)`, 216 bytes,
SHA-256 `7908fca036569ac33374f67f09cf0172f18e918654f5b7d590da6fd717366430`.
Its 20-byte literal pool `[e34b8,e34cc)` has SHA-256
`74d3c202e104ffb63c3a2f8cd8bec7fc436f5ad2f501f2103e7821c93a4db51d`.
The final `pop {...,pc}` at e34b4 prevents fallthrough into the pool; the sole
non-call branch at e3428 targets the return path e34ac. All five pool words
are consumed by PC-relative loads; none is a code branch target. The following
entry e34cc is independently established by the accepted constructor/pulse proof.

The corresponding hwscan code is `[f3174,f324c)`, also 216 bytes, SHA-256
`275315f6bf34601e73c7cb5e7db75048c13ad952de7326ab0ed54aace2a21240`.
Its pool `[f324c,f3260)` has SHA-256
`453a1d4d3cd56e572f2e232b53c49449b55ee586fb5dd02f63cf14dfda17b2d7`.
All 51 non-call ARM words are byte-identical between the methods. Only the
three BL words at offsets `0x40`, `0x94`, and `0xc4` differ. The hwscan writer
is f3d7c and its logger is feeb0; cgminer uses e4a74 and fa0c4 respectively.
This corroborates the ordinary wrapper contract, not whole-process parity.

## Constructor identity

cgminer e1578 loads the word at e1720 (`0x004fea60`); e157c dereferences
`e157c + 8 + 0x004fea60 = 0x5dffe4`, whose file word is e33e0. e15c0 stores
that retained address identity at output `+0x74`. The bounded constructor
artifact is `[e1578,e15c4)`. In hwscan, f1e50/f1e54 uses literal f1ff8
(`0x003bdc9c`) and GOT cell 4afaf8 to obtain f3174; f1e98 stores `+0x74`.
The earlier accepted full constructor proof remains unchanged.

These are numeric original addresses, never callable host pointers. Neither
a direct caller nor a complete indirect T21 startup path to this slot has
been established. Method-table presence must not be presented as reachability.

## Ordinary effect contract

The original ARM inputs are r0=device, r1=chip, r2=pulse, r3=clock.
e33ec/e33f8 retain device/chip identities. e33f4 takes `(clock << 3) & 0x38`;
e3404 inserts low two pulse bits into bits 6–7. e340c/e3414 supply constant
`0x80008000`. e3418 writes the fifth writer argument on the stack.
e33fc/e3400/e3408 arrange mode 0, register 0x3c, and the original chip pointer.
The sole writer call is e3420. e3424/e3428 compares exactly with zero.

Success skips all logging and returns zero. Failure emits two logger calls at
e3474 and e34a4, then uses e34a8's `mvn r5,#0` to return signed -1. The wrapper
does not return an arbitrary downstream status. There is no validation,
cache read, retry, wait, second write, rollback or acknowledgement handling.
e3444 and e3478 independently read device+0x18; each subsequent add increments
modulo 2^32. Mutations by the writer and first logger affect later diagnostics.
Logger results are ignored. Callbacks must obey normal callee-save semantics.

The reused e4a74 projection emits a nine-byte SET_CONFIG body, with mode 0
selecting unicast and per-chip cache update. It captures the transmitted address
before send but reads current device/chip cache indices after send. NULL chip
selects wire address/cache index zero in that existing writer. Cache errors can
occur after dispatch. No new wrapper preflight or automatic retry is introduced.
Tests exercise the existing writer/cache code rather than substituting those
operations with successful hardware implementations.

## Diagnostic metadata

Both calls use severity 1, module `driver`, source
`/tmp/build/libbitmain/src/chip/chip1368.c`, and function `[redacted]`.
The latter is literal metadata in both images, not a recovered function name.
The first format is `chain#%d - failed to send core command` at source line 387;
the second is `chain#%d - failed to set CLOCK_DELAY_CTRL` at line 538.

| cgminer address | Bytes including NUL | XOR key | Meaning |
| --- | ---: | ---: | --- |
| 5eb3e0 | 7 | 1e | module |
| 5eb3e7 | 42 | d8 | source |
| 5eb411 | 11 | d1 | function |
| 5eb8b0 | 39 | 67 | first format |
| 5eb4ba | 42 | d8 | second format |

The e5370 initializer is referenced by .init_array. Its literal/add/XOR/count
witnesses establish these decoded values on the reviewed ordinary initialization
path. Initialization code/literal extent `[e5370,e60e8)` has SHA-256
`64d918aa7b44291ada8e1ea902986873f0835da099c5eeee1a7d540226088db0`.
The existing reset proof also covers both format strings. hwscan stores the
same five texts plaintext at 47d914, 47e7ef, 47d359, 47e5a3 and 47e20d.
No runtime string mutation/relocation or full initializer parity is claimed.

## Projection and verification limits

The typed API reuses the existing device/chip and pulse callback abstractions.
Its required logger reports line/index events; formatting and original logger
internals remain an explicit omitted boundary. There is no new vendor ABI.
Storage, callback identities and lifetime remain valid across synchronous calls,
with external serialization. Invalid pointers, aliasing with ops/code, faults,
asynchronous mutation, races and original stack/access traces are out of scope.

The verifier checks pinned full input identities, bounded raw bytes, artifacts,
instruction facts and string evidence; it does not automatically prove the C
translation equivalent. Host tests and semantic controls validate the authored
projection using reviewed vectors. No original instructions are executed or
interpreted. Ghidra was used with `-readOnly -noanalysis`; temporary disassembly
changes were discarded. No firmware process, boot script, emulator, device,
UART, pool, hardware wait or production driver registration is exercised.

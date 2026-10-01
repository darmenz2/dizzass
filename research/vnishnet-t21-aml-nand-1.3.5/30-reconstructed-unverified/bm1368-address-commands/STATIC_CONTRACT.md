# Original BM1368 INACTIVE and SET_ADDRESS wrapper contracts

## Result

The original cgminer and hwscan images establish the same ordinary callback-visible contracts for both methods. INACTIVE forms `53 05 00 00 CRC5`; SET_ADDRESS forms `40 05 low8(chip_word_at_4) 00 CRC5`. Each calls the existing transport boundary once with the original device identity and exactly five body bytes. Exactly-zero transport status returns zero without a wrapper diagnostic. Every nonzero status logs the corresponding error once, ignores the logger return, and returns the word `0xffffffff` (signed -1).

SET_ADDRESS's transmitted address is captured before CRC and transport. On failure it independently rereads the full, then-current chip word at +4 for `%02x`. Both failure messages load the then-current device word at +0x18, then add one modulo 2^32 for `%d`. A typed implementation must preserve this distinction. The original does not validate or reject an address greater than 255; it truncates only the transmitted byte. `%02x` specifies a minimum width, not truncation of the diagnostic word.

This is a static proof of the wrappers' ordinary effect contract, conditional on the accepted CRC/encoder/transport dependencies. It is not original execution, formal instruction lifting, whole-process equivalence, or device acceptance. No ELF execution, instruction interpreter, emulator, historical oracle, model/OOM probe, hardware/device path, or real delay was used.

## Source identities and exact boundaries

The accepted source snapshot is work commit `5b7ee62ef22b6eaa9adf8c7b86e99273dc917f76`, tree `da72d5da5a659a2376012ce4cce2f6c3dbdaa100`. The implementation record below binds a specific accepted runtime prefix and exact header.

| ELF | File bytes | SHA256 |
| --- | ---: | --- |
| cgminer | 6228004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4883216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

All range ends below are exclusive.

| ELF / method | Entire code | Bytes / SHA256 | Literal pool | Pool SHA256 |
| --- | --- | --- | --- | --- |
| cgminer INACTIVE | e47b8..e48d8 | 288 / 94551474c9c8ebeb6dd8aa5d2b0e65e7bcd6e858e94da38833d3b508f8aa0b8b | e48d8..e48fc | 98f2f326123298edf2d81a0cf5c303199e5a153040121bd39208dfcc6b26de5e |
| cgminer SET_ADDRESS | e48fc..e49ac | 176 / 99c4084fce9271ef1ecfa3deb4d4cab9dc2d8bd7dc81d9e04279f60c55a5e27a | e49ac..e49bc | f63e1b101ee9e3a4225bd5470c2f4d2329aa5938f3fe51308d8e24818169be7f |
| hwscan INACTIVE | f3bcc..f3c64 | 152 / b55ce65c9961089462eb9cf20cb736ec1a8fcf68ee2c73b16590fdc8df6221bb | f3c64..f3c74 | fd356ef98af595eb2b7ca21ebb3f8d1e0ae57a196386066f043514abe9cbe72f |
| hwscan SET_ADDRESS | f3c74..f3d24 | 176 / a12ac06d3a3442fc0e504e109274ef9fca959ae20dc71226479055db141277a8 | f3d24..f3d34 | cc0a0a69576467249c20d7b4320676dcef92354d9826bee573c6e769f38599e1 |

These boundaries do not come from EHABI. Constructor pointers establish the entries. Every aligned four-byte word in the stated code regions decodes as one ARM instruction; every non-call immediate branch targets a word within that same code region. The only reached exit is the last `pop {...,pc}` at e48d4/e49a8/f3c60/f3d20; it prevents fallthrough into the pools. All pool words, including the dead-block references, are consumed by the bodies' PC-relative literal loads, and none is a branch target. The INACTIVE pool ends exactly at the separately established SET_ADDRESS entry. The SET_ADDRESS pool ends at a following independent `mov r0,#0; bx lr` leaf (e49bc/f3d34). The preceding return sequences e4794..e47a0 and f3bb0..f3bbc are also witnessed. Instructions that happen to decode from pool bytes are not classified as code.

## Constructor identities, independently checked in raw ELF

| ELF / offset | Literal load / GOT dereference | Literal -> GOT cell -> file word | Store |
| --- | --- | --- | --- |
| cgminer +b4 | e14c8 / e14cc (lr) | e16e0=004fd4fc -> 5de9d0 -> e47b8 | e1510 `str lr,[r0,#0xb4]` |
| cgminer +b8 | e14c0 / e14c4 (ip) | e16dc=004fd774 -> 5dec40 -> e48fc | e1514 `str ip,[r0,#0xb8]` |
| hwscan +b4 | f1da0 / f1da4 (lr) | f1fb8=003bdcf4 -> 4afaa0 -> f3bcc | f1de8 `str lr,[r0,#0xb4]` |
| hwscan +b8 | f1d98 / f1d9c (ip) | f1fb4=003bd7e0 -> 4af584 -> f3c74 | f1dec `str ip,[r0,#0xb8]` |

For each chain, the GOT cell equals `(GOT-load-address + 8 + literal_word) mod 2^32`. The 88-byte selected constructor blocks e14c0..e1518 and f1d98..f1df0 are byte-identical, SHA256 `be81be0574071e93e098850b25a0535415602592363241c47f8d0dc30c8cb0bb`. They contain no call or branch and do not overwrite ip/lr between their loads and respective stores. This proves numeric stored method identities, not a host-callable table, runtime table immutability, or a complete startup path.

## Inputs, construction, effect order, and returns

INACTIVE uses incoming r0 as device identity. It has no semantic chip argument. Incoming r1/r2/r3 and caller stack arguments are not read before being overwritten or ignored. cgminer saves r0 to r4 at e47c8; hwscan does so at f3bdc. The packet buffer is current sp+0x13, five bytes through sp+0x17. A little-endian word store of 0x553 writes `53 05 00 00`; a separate byte store initializes the last byte to zero. The CRC call receives `(buffer, 32)` and its result's low byte replaces that last byte.

SET_ADDRESS uses incoming r0=device and r1=chip. The device identity is kept in r5 and chip identity in r4. Incoming r2/r3 and caller stack arguments are unused. A little-endian halfword store of 0x540 writes `40 05`. The word load from chip+4 at e4920/f3c98 precedes CRC and transport. Its STRB at e4930/f3ca8 keeps only bits 7:0 at body byte 2. Separate zero stores initialize body byte 3 and the CRC byte. The same CRC call fills byte 4. No pointer or object field is modified by either wrapper; the direct stores are local stack construction and outgoing logger arguments.

| Reached event | cgminer INACTIVE / ADDRESS | hwscan INACTIVE / ADDRESS | Exact boundary arguments |
| --- | --- | --- | --- |
| CRC5 call | e47e4 / e4938 | f3bf8 / f3cb0 | r0=local five-byte buffer, r1=32; only first four bytes contribute |
| Transport call | e47f8 / e494c | f3c0c / f3cc4 | r0=original device identity, r1=buffer, r2=5 |
| Zero-status branch | e4800 / e4954 | f3c14 / f3ccc | Taken iff transport r0 equals zero |
| Failure log | e486c / e4998 | f3c50 / f3d10 | Exact ABI and strings below |
| Return | e48cc..e48d8 / e49a0..e49ac | f3c58..f3c64 / f3d18..f3d24 | 0 after zero status; 0xffffffff after failure log |

The original dependencies are CRC5 f7f10/fcc18, transport d26ac/ea8b8, and logger fa0c4/feeb0. The wrappers inspect only the transport result's zero/nonzero distinction. Positive nonzero and negative nonzero statuses have the same wrapper handling. The transport status itself is not returned. Logger return values are ignored. There is no retry, delay, cache update, rollback, final success log, or acknowledgment wait in either wrapper. This does not prove INACTIVE is a queue drain or physical power-off barrier.

Both methods use preserved registers for identities and the saved zero/failure result, requiring normal ARM callee-saved register behavior. SET_ADDRESS snapshots only the wire byte before calling downstream code. If a synchronous transport callback changes chip+4, the changed full word is used in the failure diagnostic; the sent body remains the original byte snapshot. If transport changes device+0x18, the failure diagnostic uses the changed index. The logger's own object mutations do not trigger further field reads in the ordinary wrapper path.

## Logger ABI, exact contents, and read timing

Every wrapper diagnostic passes:

- r0: module string `driver`
- r1: source string `/tmp/build/libbitmain/src/chip/chip1368.c`
- r2: function string `[redacted]` (literal ELF content, not this report's redaction)
- r3: source line 669 for INACTIVE, 699 for SET_ADDRESS
- stack word 0: severity 1
- stack word 1: format pointer
- stack word 2: `(current_device_index + 1) mod 2^32`, a full `%d` argument word
- stack word 3 for SET_ADDRESS only: full then-current chip+4 word, a `%02x` argument word

INACTIVE format: `chain#%d - failed to inactivate the chain`

SET_ADDRESS format: `chain#%d - failed to assign chip address to 0x%02x`

| Read / preparation | cgminer | hwscan |
| --- | --- | --- |
| INACTIVE device+0x18 load | e4850 | f3c2c |
| INACTIVE +1, stack argument | e4860/e4864 | f3c3c/f3c48 |
| SET_ADDRESS pre-send chip+4 load / truncating store | e4920/e4930 | f3c98/f3ca8 |
| SET_ADDRESS post-send device+0x18 load | e4968 | f3ce0 |
| SET_ADDRESS post-send full chip+4 load | e4970 | f3ce8 |
| SET_ADDRESS index +1 / stack argument | e497c/e498c | f3cf4/f3d04 |
| SET_ADDRESS full address stack argument | e4994 | f3d0c |

The failed send returns before these failure-field loads. There are no callbacks between the two SET_ADDRESS failure-field loads. The INACTIVE success path never dereferences device+0x18. SET_ADDRESS success reads chip+4 for packet construction but never performs a post-send field read. Do not replace these field reads with entry-time snapshots or replace the full diagnostic address with the transmitted byte.

## Exact encoded-string provenance

The cgminer initializer has complete code e5370..e6058 (SHA256 `818c84fbf1c84dfab1aa8f852a2cf68cdea95de726fc8f1734ba244d72352201`) and literal pool e6058..e60e8 (SHA256 `218d1258317bbbcbec9acd68e70c7c6f4b89d9bda7b53491bdad52b8caff9148`). Its final instruction is `pop {fp,pc}` at e6054. The following constructor starts at e60e8. Initialization-array slot 5dafe4 contains little-endian bytes `70 53 0e 00`, pointer e5370. This establishes registration, not a runtime startup-order guarantee.

| String | Exact cgminer encoded span | XOR key | Exact hwscan plain span | Zero / literal load / PC add | Count compare / XOR / increment / ordinary backedge |
| --- | --- | --- | --- | --- | --- |
| Module | 5eb3e0..5eb3e7, 7 bytes | 1e | 47d914..47d91b | e5374 / e5390 / e5394 | e539c / e53cc / e53e0 / e53e8 |
| Source | 5eb3e7..5eb411, 42 bytes | d8 | 47e7ef..47e819 | e5448 / e5454 / e5458 | e5460 / e5490 / e54a4 / e54ac |
| Function | 5eb411..5eb41c, 11 bytes | d1 | 47d359..47d364 | e54fc / e5508 / e550c | e5514 / e5544 / e5558 / e5560 |
| INACTIVE format | 5eb59d..5eb5c7, 42 bytes | db | 47e02d..47e057 | e595c / e5968 / e596c | e5980 / e5974 / e597c / e5984 |
| SET_ADDRESS format | 5eb5c7..5eb5fa, 51 bytes | d3 | 47e057..47e08a | e59b8 / e59c4 / e59c8 | e59d0 / e5a00 / e5a14 / e5a1c |

Every count includes the terminating NUL. The exact encoded bytes, decoded bytes, hashes, virtual addresses and all wrapper PC-relative reference chains are in `static-witness.json`. The initializer's actual count comparison and actual immediate XOR key are verified directly, not inferred from a recognizable string or a heuristic string catalog.

The INACTIVE loop starts with r2=0, loads the pointer via literal e6098, XORs and stores one byte at e5970/e5974/e5978, increments by one, compares to 42, and branches back while unequal. Thus it transforms precisely offsets 0..41 once on the ordinary path.

SET_ADDRESS starts r2=0, obtains its pointer via e609c, enters the parity check then the byte XOR at e59fc/e5a00/e5a04, increments to r1=r2+1, returns by the ordinary parity edge to e59d0, checks 51, assigns r2=r1 and exits when equal. It transforms precisely offsets 0..50 once. The module/source/function loops have the same zero-start, one-byte XOR, +1, exact-count structure, with the listed opaque parity guards. The comparison occurs before the next iteration and does not include a byte beyond the listed end.

Applying each witnessed XOR to its bounded encoded bytes produces exactly the corresponding bounded hwscan plain bytes, with one NUL at the final byte. This conclusion assumes one normal initializer pass, valid ordinary initializer/global storage, and no subsequent mutation of the literal strings. Repeating the XOR initializer would encode them again. Registration alone does not establish when arbitrary callers run relative to it.

## Opaque predicates and cross-ELF agreement

cgminer INACTIVE's failure path loads opaque x via GOT 5dfaf0 -> 68b8b8. It computes low32(x*(x-1)) at e4814/e4818 and tests bit 0 at e4828. One of consecutive integers is even; reduction modulo 2^32 preserves parity. Therefore e482c always branches to e483c for every input word, including x=0. The `*y > 9` route at e4830..e4838 cannot run. GOT 5df118 holds the y pointer 68b818; the ordinary path loads that pointer but never dereferences y.

After the one ordinary logger call, x is reread at e4870, then the same parity argument makes e4884 branch to e48cc. It does not matter whether the logger changed x. The block e4894..e48c8, including duplicate logger e48c4 and the backedge to e483c, is statically unreachable under ordinary instruction semantics. Thus cgminer does not log twice or retry the transport. Its extra opaque-global accesses are real raw memory accesses, so this simplification does not claim identical fault or memory-access traces.

The initializer uses the same parity fact for its opaque guards. The relevant GOT pointers are 5df560 -> 68af54 and 5decb0 -> 68ae10. Those globals are required to be ordinary readable storage. No initial x/y values are assumed, and they are not synthesized as file-backed data when they lie in BSS.

hwscan INACTIVE has the direct zero/nonzero branch and one failure log. Both SET_ADDRESS bodies directly follow that shape. Their body bytes, callback arguments, read timing, failure text/line/severity, and return values agree after the cgminer dead block is removed. The two images' machine code, literal pointers, full memory accesses, initializer mechanism and lower-level implementations are not asserted byte-identical.

## Accepted dependencies and implementation gate

Reuse these existing accepted pieces unchanged:

| Accepted file | SHA256 | Scope relied on here |
| --- | --- | --- |
| integration/bm1368_control.c | 6311c43f27b482114b7e18826727e2cd024b2bea4a74b911b5d73887757808f3 | 7-byte encoding with 55 aa prefix, 5-byte command body |
| reconstruction/support/crc5.c | d03fe3a245dffeddb2d644d91671b44430ca81a007ad15b49db294c1a700e1a2 | CRC5 polynomial x^5+x^2+1, initial 0x1f, MSB first, no final XOR |
| libbitmain/src/transport-dispatch.c | 5cd3632bf3610c8ec3a7d2ea9b3f9da7fc91bd26676598e41448d6376b531fd9 | Existing transport projection and selected explicit binding |
| integration/transport_dispatch_135.h | 7ca6a41c3fa943e068fb458c198164b2525aa04db43e9b0dc0e6cacda0855b36 | Device/payload identity, full 32-bit length, synchronous temporary lifetime |

For INACTIVE call the encoder with command INACTIVE and zeros for broadcast/address/register/value. For SET_ADDRESS read and normalize the original full address word to its low byte before invoking the existing encoder with SET_ADDRESS, broadcast/register/value zero. Passing the full >255 word directly into that encoder would trigger its new API guard and would not reproduce this original wrapper. Send encoder bytes 2..6, exactly five bytes; the encoder's 55 aa prefix is not part of the wrapper's transport argument and must not be sent twice.

The implemented wrappers preserve the existing typed source identity/index and chip-reference views and do not cast unrelated layouts. Their encoder error/length checks are unreachable for the pinned encoder with the normalized, fixed-size arguments used here; they are not recovered original branches. The stable device view and reached callback associations must exist. The opaque device identity may be NULL only if the selected transport accepts it and succeeds; that path does not read the diagnostic index or logger. SET_ADDRESS still requires a readable chip. On failure the diagnostic index and logger must be live. No original NULL-device fault behavior is invented. Only the new typed host calling convention is implemented; original ARM varargs and object layouts are not fabricated.

## Bounded original caller and cold-address provenance

The methods above are actual dependencies of cgminer’s inline address stage
55ad8..55b50 within coordinator 55774. This packet adds only that selected
stage and the small accessor/cold-address/delay windows below. It supplies no
standalone coordinator implementation, whole-program first-I/O claim or
hwscan startup caller.

Let C be the chain, D=C+2b8, Baddr the retained addressing owner, and V the
retained board view. These are original identities, not native C layouts.

1. 55ad8/55adc calls distinct delay entry 10ef3c with 10. 55ae0/55ae4 loads
   the current C+1c owner's model pointer; 55ae8 calls a720c. The witnessed
   a720c..a7218 accessor preserves zero or returns model+38 for nonzero input.
2. 55aec separately captures Baddr=[C+1c]. 55af0 forms D; 55af4 retains V.
   This can differ from an earlier owner/model retained elsewhere in startup.
3. 55afc/55b00 calls current Baddr+1c4 with D, selecting INACTIVE through
   the accepted constructor output base B+110 and local offset b4.
   The returned status is ignored: 55b04 replaces r0 with 30 and 55b08
   calls 10ed2c. That delay's result is ignored too.
4. Only after that call and delay, 55b0c reads V.word10. Signed count<1
   skips the loop. Thus nonpositive count does not skip INACTIVE or delay30.
5. Every iteration reloads C+88 (chip array) at 55b20 and Baddr+1c8
   (SET_ADDRESS method) at 55b24, then calls it at 55b30 with D and the
   current array plus byte offset. SET_ADDRESS's status is ignored:
   55b34 replaces r0 with 10; 55b38 calls 10ed2c.
6. 55b3c reloads V.word10 after that delay, including after the last or a
   failed call. The index increases by one and byte offset by 0x60.
   55b48/55b4c continues using signed index<count. The stage falls through
   to 55b50 and has no independent success/failure return.

Retained Baddr/V identities and live reloaded method/count/array fields are
distinct obligations. Replacing C.owner does not retarget the remaining
stage; replacing Baddr's address-method slot or C.chips affects the next
iteration. Mutating V.word10 can shorten or extend the loop, subject to live
storage for each reached chip, no pointer/offset wrap and finite progress.
There is no hidden clamp, entry-count snapshot, fail-fast branch, rollback,
second INACTIVE or immediate readback in the selected stage. The original
0x60 stride is not a native typed structure stride. Caller delays and their
status handling are separate from the wrappers, which contain no delay.

The selected 10ed2c windows 10ed5c..10ed70 and 10ed98..10edd0 show multiplier
0x10624dd3, high-word shift 6, subtraction of 1000 times the quotient, and
multiplication of the remainder by 1000000. On the reviewed ordinary delay path, these arithmetic premises support the
interpretation that 30 and 10 request milliseconds; this packet does not
re-prove the complete delay helper or elapsed scheduler time. The distinct 10ef3c entry is
preserved as its own call identity; this packet does not equate its other
thread-state effects to 10ed2c or implement either delay.

Cold setup already computes software chip addresses. Selected region
73688..736d0 stores the chip index at chip+0 and the return of
53d98(index, board.word0) at chip+4. The complete 53d98..53da0 leaf is
MUL/BX LR, establishing low32(index*board.word0). This is separate from the
wrapper, which transmits the current existing word's low byte. The cold
chip and live chip-reference types are separate projections and require an
explicit value adapter; no layout cast or address allocator is introduced.

The accepted L11 record establishes worker 7863c -> 55774(C,M,0), owner and
backend provenance, and constructor output base B+110. The present packet
binds those immutable dependencies without copying their complete graphs:

| Dependency | Bytes | SHA256 |
| --- | ---: | --- |
| bm1368-ticket-mask/STATIC_CONTRACT.md | 12209 | 8dba4e02de91e7406e9de4cb86dd171120a4d0db67a95fb5ae97ecf083367a60 |
| bm1368-ticket-mask/static-witness.json | 105160 | 206a3cbf5e6b450c6cc10817b41150d5794403b1065a784d7e1c30a659b5656f |
| bm1368-init/evidence/constructor-proof.json | 57477 | 10ef45e2a3a641ed8d9aded2e9d59c0fa1d0ae6df8a72500f876a5b27ad8c613 |

These paths are relative to the same reconstructed-unverified research
parent. The verifier checks their exact bytes. Broader startup operations,
missing register/group helpers, no-op method maps, and exploratory disassembly
are not part of this packet's verified region inventory.

## Historical implementation span and independent admission

The runtime record is exactly prefix [0,11280) of
libbitmain/src/chip/chip1368.c, SHA256
91cfb6f3bb640bcf3519027243970bcb37aeeb0275f96b931dd17cab940540d2,
Git blob 890e2bfc9ead81a9cafe5b34c917b37133ea0d5e. The prior 9245-byte
prefix is unchanged (SHA256
e4c05fb8bc541e6e6b2a216cbaecf7ef57cc3d85101d59b81e8ebd3d4e2af7e4).
This is a historical witness, so a later gated append beyond byte 11280 is
explicitly allowed by this static record. Current whole-file admission remains
the separate shared/L09/L12/A13 exact gates. Passing this verifier alone does
not admit arbitrary appended implementation into those gates.

The header integration/bm1368_address_commands_135.h is bound in full:
3621 bytes, SHA256
f06b44fb4c4bd0bac18102be55db8b2ac13ee7c7e4ee60ce74508edc9fb8e00f,
Git blob 23026eb1987b912797d77d94e75a8acf91002731. The verifier requires
its exact extent and contents. Existing common_read_register_135.h is also
bound as an unchanged typed-view dependency (3413 bytes, SHA256
12c317b0c79d00a50b8a22af60bfbb5669761c37d9c1a21afaa1c3be49f6ea3b).

## Verifier, controls and limits

Run from the repository root:

    python3 research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-address-commands/verify_evidence.py
    python3 research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-address-commands/tests/test_evidence.py

Add --cgminer PATH and/or --hwscan PATH for complete-original identity checks
and unique PT_LOAD comparisons of every selected byte range. The verifier's
default repository root is HERE.parents[3]; --root selects another checkout.
Normal Python and python -O use the same explicit validation checks.

static-witness.json holds bounded code/data bytes and exact hashes, complete
fixed operand annotations for designated code, method/branch/literal/GOT
records, the string loops, selected caller facts, dependencies and historical
runtime spans. static-pins.json fixes the reviewed metadata and range
identities; its own SHA256 is hardcoded in verify_evidence.py. Duplicate JSON
keys, nonfinite constants, malformed schemas, out-of-range data, overlapping
regions and changed evidence are rejected. The verifier uses only Python's
standard library. It has no CPU state, instruction dispatch, algorithmic
stepping, target execution, emulator, executable mapping or hardware path.
Resolving a fixed instruction's branch/immediate/literal fields and XORing
bounded data are static byte checks, not execution of the original code.

The control-flow, parity, read timing, ignored-result and caller conclusions
are reviewed manual reasoning. Fixed instruction checks bind their premises
and immutable metadata binds the recorded conclusions; neither turns the
checker into an automatic C/original equivalence proof. Hash identities verify
that the accepted artifacts were preserved, not that every semantic inference
was mechanically proved.

Focused controls alter transport length, status branching, word-versus-byte
address loads, constructor offset, initializer length/key, caller result
handling, reviewed status/read-site/address facts, dependency bytes, runtime
prefix bytes and header bytes. Instruction controls refresh local hashes and
operand-byte fields; independent pins still reject them. A changed metadata
hash with rewritten pins is also rejected. A positive control accepts an
append strictly after the recorded runtime prefix, while an appended header
is rejected. The finite named controls run in normal and optimized Python;
their purpose is detection of these specific failure classes, not a coverage
metric for all possible malformed artifacts or firmware behavior.

The ordinary wrapper domain requires stable device views/callback/context
associations, live reached chip/index storage, normal ARM callee-save behavior,
returning synchronous CRC/transport/logger calls, initialized unchanged
strings, and ordinary readable opaque globals. Synchronous chip/index changes
are in scope and must be visible through the specified late reads. Callbacks
must not retain packet/diagnostic temporaries, access another call's locals,
mutate raw caller stack slots or violate object lifetimes.

Excluded are original invalid-pointer/fault behavior, asynchronous races,
MMIO or fault effects of opaque reads, unaligned-access fault traces, raw
stack equivalence, allocation/OOM behavior, unwinding/nonreturning callees,
real timing, omitted lower-layer diagnostics, physical ASIC address assignment,
mining, power/thermal readiness and production startup integration. These are
limits on the conclusion, not validation performed by the original wrappers.

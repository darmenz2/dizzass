# Original BM1368 reset callback contract

## Result and scope

The two supplied original ELFs establish the same ordinary reset-level callback
contract. The cgminer body has additional opaque predicates and four statically
unreachable callback sites; hwscan has the corresponding direct control-flow
graph. No discrepancy with the typed header contract was found. A separate typed
host projection can preserve this contract without changing the existing
fail-fast reset API.

This conclusion is bounded to returning synchronous callbacks, ARM-conforming
callees in the original, stable callback/context identities in the host
projection, valid device/chip storage, ordinary readable opaque-global storage,
and initialized logging strings. Device/chip field changes performed during a
callback are explicitly inside the contract. The callbacks may write their own
current cache output but must not retain or access another call's output or
diagnostic temporary. Asynchronous mutation, raw stack access, invalid pointers,
fault/access traces, allocation/OOM behavior, and hardware timing are outside
this result.

Only ELF parsing, hashing, byte inspection, and disassembly were used. Neither
firmware executable, historical oracle, emulator, instruction interpreter,
hardware path, nor candidate implementation was run. The proof was checked against the supplied ELF bytes.
Host C validation is recorded separately in `validation.json`.

`static-witness.json` contains bounded code/data bytes, instruction annotations,
method-slot references, string facts and the reviewed callback graph.
`verify_evidence.py` validates those records and their independent pinned
identities without executing instructions. Optional complete-ELF data checks
compare every selected range against the original file identities; see README.
Control-flow and ABI deductions remain explicit static review, not a claim of
formally verified lifting or automatically established C/original equivalence.

## Identities and method slot

| Input | File bytes | SHA256 |
| --- | ---: | --- |
| cgminer | 6,228,004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4,883,216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

| Input | Code extent, exclusive end | Code SHA256 | Literal extent, exclusive end |
| --- | --- | --- | --- |
| cgminer | e1b64..e209c (1,336 bytes) | 2bd23924d4d03db29282966416498d869fd453cfe15e7620adc78c1dd6283d7c | e209c..e2130 (148 bytes) |
| hwscan | f2214..f25e0 (972 bytes) | 76a20509ee659c7b9ac040b7e1cced738ae34a25ba611607d5e555743e0cd030 | f25e0..f264c (108 bytes) |

The pool hashes are respectively
`465f42779dd7d7209d6c494655cb6d0b5da594fb2ac17169adb5c4f3a56a9e7c`
and `a260f5a09abfd1be39e88d7665757cafe3df9668d020ffc17cf59467e4925044`.

In cgminer, e1648 loads the word at e1770; e164c adds that displacement to
its ARM PC and dereferences 5df570, whose file word is e1b64. At e1664,
`r2 = r0 + 0x20`; e1668 stores `{r1,r4,r5,r6}` through r2. Therefore r4,
the second word, is the method at byte offset 0x24. The hwscan chain is
f1f20 → literal f2048 → f1f24 → GOT 4afe50 → f2214, followed by
f1f3c/f1f40's same base and STM. This is byte offset 36 decimal, not decimal
24. The new evidence contains the exact bytes for both chains.

## ARM inputs and callback ABI

Both prologues push nine words, set fp to the resulting sp + 0x1c, and
reserve 0x14 more bytes. Consequently fp equals entry-sp minus 8.

| Semantic argument | Original location | Proof |
| --- | --- | --- |
| Device identity | r0 | Copied into preserved r5 at e1b70 / f2220 |
| Chip identity | r1 | Copied into preserved r6 at e1b7c / f222c |
| Fast scalar, full word | r2 | Copied into r7 at e1b8c / f223c; compared to zero after R1 |
| Unused fourth scalar | r3 | First touch replaces it with `sp+0x10` at e1b84 / f2234; incoming value is never read |
| Clock scalar, full word | entry-sp+0 = fp+8 | Loaded at e1f10 / f2458 |
| Pulse scalar, full word | entry-sp+4 = fp+12 | Loaded at e1f0c / f2454 |

The clock and pulse stack values are loaded immediately before W5, then held
through its callback and D2. Passing their values in a typed host signature is
equivalent in the stated domain because no supported callback can mutate the
caller's argument slots. Do not invent a stack-mutating probe to test them.

The four reset-level effect boundaries are:

| Boundary | cgminer / hwscan destination | Original arguments |
| --- | --- | --- |
| Cache read | 1079f0 / 105a20 | r0 = freshly loaded device word at +0x18; r1 = freshly loaded chip word at +0; r2 = register; r3 = output pointer |
| Register write | e4a74 / f3d7c | r0 = device identity; r1 = 0; r2 = chip identity; r3 = register; stack word 0 = value |
| Delay | 10ed2c / 108180 | r0 = delay amount |
| Diagnostic | fa0c4 / feeb0 | r0 = module; r1 = source path; r2 = function string; r3 = line; stack word 0 = 1; word 1 = format; word 2 = chain index only for the indexed formats |

The reset does not validate pointers, indices, clock/pulse ranges or callback
statuses beyond the tests described below. That is a fact about the original
ordinary contract, not authorization for malformed-pointer probes. Original
R1 dereferences chip+0 unconditionally, even though the separate writer can
support a NULL chip for other callers.

## Exact ordinary control-flow correspondence

Let `d = fast != 0 ? 1 : 5`, and let Ri be the successful output of read Ri.
All equality tests are exactly zero/nonzero; there is no positive/negative
distinction. Addresses in the next table are call instructions, not the later
status tests.

| Event | cgminer | hwscan | Arguments / local result | Handling of nonzero callback result |
| --- | --- | --- | --- | --- |
| R1 | e1b94 | f2244 | read 0x18 into primary local | Diagnostic L844a; skip W1 |
| W1 | e1c00 | f22b0 | write 0x18, R1 & ~0x300 | Ignored |
| R2 | e1c20 | f22d0 | read 0xa8 into primary local | Diagnostic L816; skip R3, W2, W3 |
| R3 | e1ca4 | f2324 | read 0x18 into second local | Diagnostic L821; skip W2, W3 |
| W2 | e1d1c | f2394 | write 0xa8, R2 \| 0x1f0 | Skip W3; no reset-level diagnostic |
| W3 | e1d40 | f23b8 | write 0x18, (R3 & 0x00f0ffff) \| 0xf0000000 | Ignored |
| D1 | e1dc0 | f23c0 | wait d | Ignored |
| R4 | e1ddc | f23dc | read 0x18 into primary local | Diagnostic L844b; skip W4 |
| W4 | e1e74 | f2434 | write 0x18, R4 \| 0x300 | Ignored |
| W5 | e1f14 | f245c | write 0x3c, 0x80008b00 | Diagnostic L444; continue |
| D2 | e1f64 | f24a8 | wait d | Ignored |
| W6 | e1f90 | f24d4 | write 0x3c, 0x80008000 \| ((pulse & 3)<<6) \| ((clock & 7)<<3) | Diagnostic L387a, then L538; continue |
| D3 | e201c | f2560 | wait d | Ignored |
| W7 | e203c | f2580 | write 0x3c, 0x800082aa | Diagnostic L387b; continue |
| D4 | e2084 | f25c8 | wait d | Ignored |
| D5 | e208c | f25d0 | wait 10 | Ignored |
| Return | e2090/e2098 | f25d4/f25dc | Set r0 to zero, restore frame, return | Always zero if callbacks return |

Every write passes mode zero and the same device/chip pointer identities.
Nothing in this reset graph uses a writer return value except W2, W5, W6,
and W7. W2 controls only W3; the last three control only their listed logs.
The R1/R4 failures each skip their own write. R2/R3 failure converges at D1.
There is no reset retry, rollback, early error return, or final success log.
On the all-success path there are four reads, seven writes and five delays.
Every returning path reaches all five delays in the order d,d,d,d,10.

The W6 instructions are `lsl r0,pulse,#6`, `uxtb r0,r0`,
`bfi r0,clock,#3,#3`, then OR 0x8000 and 0x80000000. Hence the input masks
are truncation of full words, not range checks. Bits not specified by the
formula are zero. The fourth argument has no effect for every input word.

The delay helper disassembly independently supports millisecond units: it
divides the input by 1000 via multiplier 0x10624dd3/high-word/shift 6,
subtracts 1000 times that quotient, and multiplies the remainder by 1,000,000
before passing the seconds/nanoseconds structure onward. At the only reached
reset values (1,5,10), seconds are zero and nanoseconds are respectively
1,000,000 / 5,000,000 / 10,000,000. This identifies requested duration, not
scheduler or wall-clock equivalence. The host delay boundary can record it.

## Output locals, snapshots, and mutable rereads

The primary local is original sp+0x10. It is explicitly zeroed before R1
(e1b74/e1b78, f2224/f2228), R2 (e1c04/e1c0c, f22b4/f22bc), and R4
(e1dc4/e1dcc, f23c4/f23cc). The second local is sp+0xc; it is zeroed
alongside R2 at e1c14 / f22c4, before R2's callback, and passed to R3 only
if R2 succeeds. There is no intervening legitimate access to it. Both output
locals must therefore be initially zero for their reached cache callbacks.

Failure output values are never consumed in register construction. R2/R3
success values are read and normalized before W2; R3's normalized value is
saved locally across W2 for W3. A W2 callback may mutate the underlying cache
without changing the already saved W3 value. There is no implicit reread.

Conversely, each cache call freshly loads the indices from the live objects:

| Read | cgminer chip/device loads | hwscan chip/device loads |
| --- | --- | --- |
| R1 | e1b80 / e1b88 | f2230 / f2238 |
| R2 | e1c18 / e1c1c | f22c8 / f22cc |
| R3 | e1c94 / e1c9c | f2314 / f231c |
| R4 | e1dd4 / e1dd8 | f23d4 / f23d8 |

Do not snapshot a chain/chip index once for the method or substitute a copied
device/chip object. Read and write callback mutations, logger mutations, and
delay callback mutations can affect later events. The underlying writer has
its own verified pre-send/post-send field reads; this reset evidence covers
passing the original identities into that existing boundary and does not
replace the writer's separate proof.

## Diagnostics and string provenance

All messages use module `driver`, source
`/tmp/build/libbitmain/src/chip/chip1368.c`, and severity word 1. The function
string is literally `[redacted]` in both ELF images; that spelling is data,
not a placeholder introduced by this report.

| Diagnostic | cgminer / hwscan call | Line | Exact format | Chain load cgminer / hwscan |
| --- | --- | ---: | --- | --- |
| L844a | e1bd8 / f2288 | 844 | Failed to read cached misc contol register | None |
| L816 | e1c5c / f230c | 816 | Failed to read cached soft reset register | None |
| L821 | e1d6c / f2354 | 821 | Failed to read cached misc contol register | None |
| L844b | e1ea0 / f240c | 844 | Failed to read cached misc contol register | None |
| L444 | e1f5c / f24a0 | 444 | chain#%d - failed to set SWEEP_CLOCK_CTRL | e1f34 / f247c |
| L387a | e1fdc / f2520 | 387 | chain#%d - failed to send core command | e1fbc / f2500 |
| L538 | e2010 / f2554 | 538 | chain#%d - failed to set CLOCK_DELAY_CTRL | e1fe0 / f2524 |
| L387b | e207c / f25c0 | 387 | chain#%d - failed to send core command | e205c / f25a0 |

The original misspelling is `contol`. Cache messages take no formatting chain
argument. Each indexed diagnostic loads device+0x18 anew and adds 1 with
32-bit wrap before supplying `%d`'s word. L538 reloads after L387a returns:
if the first logger changes the device index, the second log sees that change.
All logger returns are ignored. A log event's function/source/format pointers
are stable decoded literals, while its chain word is the then-current field.

The independent string check resolves the PC-relative literal references in
each body. In cgminer each encoded range is decoded with the byte XOR key
actually present in its initializer, whose length comparison is also checked.
The resulting NUL-terminated bytes equal hwscan's plain string bytes exactly.
The complete encoded bytes, digest, initializer load/add/literal/XOR/length
instructions, decoded bytes, hwscan address and digest are in `static-witness.json`.

| Meaning | cgminer data | hwscan data | XOR key | Initializer XOR | Initializer byte count |
| --- | --- | --- | --- | --- | ---: |
| Module | 5eb3e0 | 47d914 | 1e | e53cc | 7 |
| Source | 5eb3e7 | 47e7ef | d8 | e5490 | 42 |
| Function | 5eb411 | 47d359 | d1 | e5544 | 11 |
| SWEEP | 5eb46b | 47e292 | eb | e5678 | 42 |
| CLOCK | 5eb4ba | 47e20d | d8 | e5758 | 42 |
| Core | 5eb8b0 | 47e5a3 | 67 | e5f60 | 39 |
| Misc | 5eb8d7 | 47e130 | 7a | e5fbc | 43 |
| Soft reset | 5eb902 | 47e84a | fa | e6018 | 42 |

The soft-reset proof does not depend on the historical heuristic catalog:
e5fdc loads literal e60e4, e5fe0 adds the PC to obtain 5eb902, e5fe8
compares against 42, and e6014/e6018/e601c load, XOR 0xfa, and store one
byte. e602c increments the loop index and e6034 returns to the length test
on the ordinary path. The counter starts at zero at e5fd0. The loop reaches
42 after decoding bytes 0..41, including the NUL. hwscan references plain
`Failed to read cached soft reset register` at 47e84a.

This establishes literal contents under normal initializer use. It does not
prove global startup ordering, immunity to repeated initializer execution, or
arbitrary external mutation of the decoded literals; those are deliberately
outside the reset callback contract.

## cgminer opaque predicates and cross-ELF equivalence

At every extra decision, the code loads a word x, computes `(x-1)` and then
the low 32 bits of `x*(x-1)`, and tests bit zero. One of two consecutive
integers is even. Reducing modulo 2^32 preserves parity, so the low bit is
zero for every 32-bit x, including wraparound at zero. There are no intervening
callbacks within these arithmetic sequences. Reading a different x on a later
sequence does not change this argument.

| Proven cgminer conditional edge | Effect |
| --- | --- |
| e1c80 → e1dbc | D1 runs once; bypasses alternate delay/read block |
| e1cd0 → e1d48 | R3 error reaches L821 once |
| e1d80 → e1c60 | Exit L821 without duplicate log loop |
| e1df0 → e1e28 | Consume R4 status without alternate delay/read block |
| e1e40 → e1e7c | R4 error reaches L844b once |
| e1eb4 → e1ef0 | Exit L844b without duplicate log loop |

The otherwise possible signed `>9`/`<10` tests after these parity predicates
cannot select their alternate path in the stated domain. The four unreachable
call instructions are duplicate L821 at e1db4, alternate D1 at e1e04,
alternate R4 at e1e20, and duplicate L844b at e1ee8. cgminer has 28 static
BL sites; removing these four leaves the same 24 callback sites as hwscan.
Each remaining site is paired above, with matching inputs, zero/nonzero
branches, continuation point, literal data, and final zero return.

This is callback-observable equivalence, not byte identity and not equality of
every raw memory access. cgminer additionally touches opaque globals. A fault,
memory-mapped I/O side effect, corrupted global pointer, nonreturning callback,
or violation of the callee-saved ABI would invalidate the ordinary argument.
None is part of the authorized test domain.

## Implementation gate and proof boundaries

The typed API preserves the observed six semantic argument order,
full-word masks, one reused primary output plus second output, pre-R2 zero
timing, identity pointers, callback ordering, independently reloaded fields,
diagnostic distinctions and final zero. It also explicitly states that its
typed host calling convention is not the original ARM ABI. No static semantic
mismatch blocks implementing that bounded projection.

Remaining limits must stay visible in the implementation/evidence packet:

1. A static proof plus host branch tests is not original execution, an
   instruction-by-instruction equivalence proof, or hardware acceptance.
2. The slot proof establishes a stored method identity. It does not bind a
   callable host method table or justify linking production device code.
3. Cache, writer, transport, UART and diagnostic internals remain their own
   boundaries. A nested fixture can prove composition of reviewed projections,
   but cannot claim omitted lower-layer diagnostics equal a whole firmware
   process log.
4. The delay arguments have millisecond meaning; real scheduling, EINTR,
   timing tolerances, physical reset completion and ASIC acknowledgments are
   not established by recording callbacks.
5. Stable callback tables/context identities and temporary pointer lifetimes
   are necessary host projection bounds. Mutable device/chip fields must not
   be accidentally folded into that stability restriction.
6. Failed output values must be ignored; preserved R2/R3 snapshots must not be
   replaced by additional reads; full-word zero/nonzero statuses and wrapped
   index words require defined host conversions.
7. No vendor execution, emulation, invalid-pointer or model/OOM probes,
   device I/O or real sleeps form part of this static proof.

The reconstructed entry is bounded by these limits. Recommended tests are all
reachable cache/write status paths including positive/negative failure codes,
ignored write/wait/logger status, full-word fast/clock/pulse and unused input,
zero initial outputs, discarded failure outputs, saved R3 across W2, mutations
at all callback classes, distinct L387a/L538 reloads, exact d,d,d,d,10, and
final zero. They should operate only on valid ordinary storage and record-only
lowest effect boundaries.

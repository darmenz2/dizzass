# BM1368 SWEEP_CLOCK_CTRL: independent bounded static proof

## Result

The original BM1368 methods at cgminer `e32c0` and hwscan `f30d4` have the same
ordinary observable contract: ignore incoming r1, use incoming r2 to form
`0x80008b00 | ((r2 & 3) << 1)`, and invoke the real register writer once with
the original device, mode 1, NULL chip, register `0x3c`, and that word. Zero
writer status returns zero. Any nonzero status produces the exact line-463
diagnostic using a **post-writer reload** of device+0x18, then returns -1.

The constructor installs this identity at output+0x70 in both originals. The
concrete cgminer startup coordinator call at `56034` uses cached owner B0,
device D=C+0x2b8, a currently loaded model word as r1, and r2=0. Its enabling
flag is bit 0 of **entry-time M.byte_80**, not a value first loaded at the call.
Consequently, when that selected BM1368 method is reached, this caller requests
the constant word `0x80008b00`; the model word passed as r1 has no numerical
effect on it.

These findings clear the static proof gate for the bounded setter. They do not
establish a full coordinator, all model applications, hardware success, native
cgminer driver integration, or a corresponding hwscan startup caller.

## Inputs, artifacts, and dependencies

Only ELF parsing, hashing, byte inspection and Capstone disassembly were used.
No vendor process, original-instruction interpreter/emulator/oracle, C candidate,
hardware, OS UART, real delay, model/Jansson/OOM/invalid-pointer probe, remote
write or Library change was performed. Authored host execution is recorded separately in `validation.json`.

| Input | File bytes | Verified SHA256 |
| --- | ---: | --- |
| cgminer | 6,228,004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4,883,216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

`static-witness.json` adds 24 local code/data regions containing 1,756 original
bytes. It records method boundaries, literal references, selected caller facts,
operand annotations and exact source identities. `static-pins.json` and the
verifier's fixed trust anchor bind those records. Optional whole-file identity
and selected-byte comparisons are documented in README.md. Selected caller
windows are not complete function extents.

The sibling L11 `bm1368-ticket-mask/STATIC_CONTRACT.md`, `static-witness.json`
and `static-pins.json` are explicitly hash-bound dependencies. They establish
the original object provenance, BM1368 selection at output B+0x110, and the
startup/resume worker route into `55774(C, M, 0)`. This proof extends that caller
with the sweep-specific flag, arguments and continuations. It does not duplicate
or independently broaden L11's selection/thread claims.

The verifier checks bounded bytes and address/operand facts, dependency
identities and immutable reviewed annotations. The stack-lifetime/no-overwrite
and opaque-parity conclusions below include manual static reasoning. This is
not a general alias analysis, instruction interpreter, automatic function
lifting tool or proof of C/original equivalence. The current C/header identities
are checked exactly; future source changes require deliberate reviewed updates.

## Exact method boundaries and constructor slot

| Input | Executable body, end exclusive | Instructions | Separate literal pool, end exclusive |
| --- | --- | ---: | --- |
| cgminer | e32c0..e33c8, 264 bytes | 66 | e33c8..e33e0, 24 bytes |
| hwscan | f30d4..f3164, 144 bytes | 36 | f3164..f3174, 16 bytes |

Code SHA256 values are respectively
`c8ce3cfeec1eb718aa71b4b7d8a129df9c3e047d622804279c68f249c1e3bc1b`
and `cd542fecf1188aafea36da6d09b8600ac16ec707e34bc3cfc6f11aaaa9ffc28d`.
Pool SHA256 values are
`abb3fca1f514a06067ff7e4e21cee99dba309208d364de4de073bb9699190cd9`
and `ecbc645fad5345b36211547ff60c75159789b296c36e248ac46cce38f07bb2a9`.

The immediately preceding methods return through POP-PC at `e32bc`/`f30d0`.
The sweep prologues begin at the stated entries, their internal branch targets
are inside the bodies, and their only external BL targets are the writer and
logger. The sweep bodies end in POP-PC at `e33c4`/`f3160`; no control edge falls
through to the pools. Every pool cell is referenced by an explicit PC-relative
LDR in the body. The next distinct method prologues begin at `e33e0`/`f3174`.
These are control-flow and literal-reference boundaries, not inferred EHABI
coverage extents. The two bodies are not byte-identical.

| Input | Constructor chain | Store |
| --- | --- | --- |
| cgminer | e1580 reads e1724=0x4fd7e4; e1584 dereferences PC+displacement=5ded70; cell contains e32c0 | e15bc: STR r3,[r0,#0x70] |
| hwscan | f1e58 reads f1ffc=0x3bdf4c; f1e5c dereferences PC+displacement=4afdb0; cell contains f30d4 | f1e94: STR r3,[r0,#0x70] |

No instruction between each indexed load and its store overwrites r3. With
L11's independently established cgminer output base B+0x110, this is B+0x180.
The constructor association is an initial numeric method identity, not proof
that a runtime slot cannot subsequently be changed.

## Ordinary arithmetic, one writer call, and failure timing

Cgminer preserves incoming r0 in r4 at `e32d0`, and incoming r2 in r5 at
`e32d8`. Incoming r1's first use is a replacement (`sub r1,r0,#1` at `e32ec`),
so it is ignored. At `e330c`, AND with 3 retains precisely r2 bits 0 and 1.
`e331c` shifts them to word bits 1 and 2 and ORs with `0x80008b00`, whose bits
1 and 2 are clear. All other input bits are discarded.

Hwscan preserves the device in r4 at `f30e0`, replaces r1 with 1 at `f30ec`,
and uses `bfi r0,r2,#1,#2` at `f30f0` after loading the same base constant.
BFI replaces exactly destination bits 1 and 2 with source bits 0 and 1.
Therefore the expression above is equal for every 32-bit r2 word. The four
possible words are `80008b00`, `80008b02`, `80008b04`, and `80008b06`.
This is bit algebra, not output from executing original instructions.

The ordinary cgminer edges `e32fc -> e330c` and `e3340 -> e3374` follow from
`x*(x-1) mod 2^32` having low bit zero for every 32-bit x, including x=0.
Each arithmetic sequence uses one loaded x; no callback intervenes inside the
sequence. Even a different x after the writer preserves this identity. The
subsequent signed-global tests cannot reach the duplicate writer block
`e3350..e3370`. Thus there is one reached writer call, `e332c -> e4a74`, matching
the direct hwscan call `f310c -> f3d7c`.

Both calls pass r0=the preserved original device, r1=1, r2=0, r3=0x3c, and the
fifth AAPCS argument at [sp]=the computed word. The wrapper does not implement
encoding, cache or transport internally; it calls the already reviewed actual
writer. A single wrapper-level call is not a claim that nested writer internals
have only one observable event.

At `e3374`/`f3110`, **exactly zero** is success; both positive and negative
nonzero statuses take failure. Success returns zero via `e33bc`/`f3158` with
no wrapper diagnostic. Failure reloads device+0x18 at `e3390`/`f3128`, after
the writer has returned, then adds one at `e33a0`/`f3138` with 32-bit wrap.
The log receives that resulting word as its `%d` argument. A writer-side index
mutation must therefore be visible to the wrapper diagnostic. Do not cache the
index before the writer or replace the device by a copy.

The logger calls are `e33b4 -> fa0c4` and `f3150 -> feeb0`; r3=0x1cf (463),
[sp]=1 (severity), [sp+4]=format and [sp+8]=the late index+1 word. The return
from the logger is ignored. The wrapper then returns all-ones/-1. There is no
retry, wrapper wait, second ordinary write, range validation, or rollback.

## All four literal strings, with direct initializer proof

The function string `[redacted]` is literal original data, not a redaction
invented in this report. Every decoded sequence includes its terminating NUL
and equals the independently plain hwscan sequence byte-for-byte.

| Meaning and exact text | cgminer address | hwscan address | Bytes incl. NUL | XOR key | Direct compare / XOR |
| --- | --- | --- | ---: | --- | --- |
| Module: `driver` | 5eb3e0 | 47d914 | 7 | 1e | e539c / e53cc |
| Source: `/tmp/build/libbitmain/src/chip/chip1368.c` | 5eb3e7 | 47e7ef | 42 | d8 | e5460 / e5490 |
| Function: `[redacted]` | 5eb411 | 47d359 | 11 | d1 | e5514 / e5544 |
| Format: `chain#%d - failed to set SWEEP_CLOCK_CTRL` | 5eb46b | 47e292 | 42 | eb | e5684 / e5678 |

The method's four PC-relative references are independently recorded; they
resolve to the above addresses, not merely to strings with matching spelling.
The source/module/function initializers start their counters at zero and use
the same even-product simplification to follow one XOR per byte.

The SWEEP initializer is particularly direct: `e5660` sets r2=0; `e566c` loads
literal `e607c`, and `e5670` adds PC to resolve `5eb46b`; `e5674/e5678/e567c`
load/XOR-0xeb/store one byte; `e5680` increments r2; `e5684` compares with 0x2a;
`e5688` loops while unequal. Hence bytes 0..41 are decoded exactly once on that
ordinary initializer passage. The prior heuristic catalog's 42-byte value is
not used to prove length. It happens to agree with this direct count.

This proves contents under ordinary one-time initialization. Global startup
ordering, repeating an in-place XOR initializer, or later arbitrary mutation
of its string storage remains outside the method contract.

## New caller proof: flag origin, owner lifetime and arguments

Use L11's descriptive objects: C is the incoming chain, M the incoming model,
and B0 is the owner observed early by this coordinator. These labels are not
claims of native structure layout compatibility.

1. `55784` preserves C in sb and `5578c` preserves M in r5. `a720c` returns
   M+0x38 for nonzero M; `557c4` holds this board view in r7. `a71f4` returns
   M+0x88; `557d0` stores that chip-view identity at [fp-0x20]. Valid readable
   model storage is required; NULL-preserving accessors do not validate it.
2. `557ec` loads byte [board-view+0x48] = [M+0x80]. `557f0` stores its
   zero-extended value at [sp+0x24]. `55ff4` reloads that saved word and `55ff8`
   tests bit 0. The byte is not read anew after intervening callbacks.
3. The prologue leaves fp=entry-SP-8 and sp=entry-SP-0x60, so sp+0x24 equals
   fp-0x34. Manual inspection of the complete bounded entry-to-call region and its
   frame references found exactly one store to this slot, at `557f0`, and no alternate
   store via its fp alias. Neither sp nor fp changes on a continuing path
   before the call; `55f04/55f08` change them only when returning. Outgoing
   argument stores reach sp+0, +4 and +8, not the saved flag. No pointer to the
   saved flag is passed to a callee. Under the ordinary ABI/no-raw-stack-access
   domain, model changes during callbacks therefore cannot change this flag.
4. `55828` loads B0=[C+0x1c] into r7. The early check/clear route must reach
   `5592c` successfully; `55938` then stores that same r7 at [sp+0x14]. The
   error branch that repurposes r7 cannot reach the save. This stack slot is
   not overwritten before sweep. It is the cached **owner identity**, not a
   cached method pointer. The method pointer is freshly loaded from B0+0x180
   at `5602c`.
5. `55af0` computes D=C+0x2b8 in sl; `55b8c` restores the saved M+0x88 view
   into r5. On the route reaching sweep, these callee-saved identities persist.
   `56020` reloads B0; `56024` sets r2=0; `56028` loads r1=[r5+0x1c]=[M+0xa4];
   `5602c` loads the method; `56030` places D in r0; `56034` BLX calls it.

The original still performs the r1 model-word load even though this particular
selected method ignores its value. This proof does not authorize omitting
valid-storage preconditions or inventing fault/MMIO equivalence. The method's
r2 is zero because of `56024`, independently of the worker's separate zero
third argument to the coordinator.

Replacing C+0x1c during an earlier callback does not retarget this call: it uses
B0. Mutating B0's slot can change the called method because that slot is loaded
at call time. Similarly, r1 is read at call time, while its model-view pointer
and the controlling flag were saved at entry. Arbitrary callbacks are not
proved unable to free/reuse an owner; the ordinary live-object domain is
required. B0 must not be silently conflated with the B1 owner that L11's optional
triple-reset path freshly loads.

## Precise continuations

Before the sweep gate, work-mode setup must succeed. The entry-time flag at
[sp+0x28] (M.byte_7f bit 0) may enable a separate B0+0x1ec call at `55f6c`;
if enabled, it too must return zero before `55ff4`. The gate then has these
ordinary outcomes:

- Flag bit clear: `55ffc -> 560b0`, with no sweep call
- Flag bit set: `56010 -> 56020`, then exactly one call at `56034`;
  `56048 -> 56074` skips the duplicate opaque block containing `5606c`
- Sweep status zero: `56078 -> 560b0`
- Sweep status nonzero: `5607c..56094 -> 560d4`. This outer layer logs severity
  1, source line 657 (0x291), reading **C+0x18** at `560e8` and adding one.
  It calls `56d18(C, error-string)` at `56118`, sets r6=-1 at `56120`, and the
  even-product edge `56130 -> 55f00` returns -1 through `55f08`. The duplicate
  error block `56148..56190` is unreachable under the same parity identity.

The outer error helper is an explicit boundary; its entire implementation and
effects are not claimed by this proof. Its diagnostic index is C+0x18, whereas
the method diagnostic reads D+0x18. These distinct objects and read times must
not be conflated. The coordinator failure route does not request the success
continuation's delay or later configuration.

Disabled and successful sweep converge at `560b0`; parity takes `560c0 ->
56194`, which calls the existing delay entry at `56198` with 10. After it,
`561a8` tests the previously retained M.byte_81 bit 0 (loaded/saved at
`557f4/557f8` and restored into r6 at `55c44`). If set, the ordinary path calls
slot B0+0x188 at `5620c` with D, [M+0x98], [M+0xa8], and zero. That is the
separate existing pulse-width configuration slot, which can write register
0x3c again; successful sweep therefore does not establish final persistence
of its value. A nonzero result from this later method follows its own error
route; zero or a clear flag reaches `562a0`.

At `562a0`, the coordinator's saved original third argument controls the
configured ticket-mask call. L11 proves the real worker supplies zero, so after
a delay argument 50 it invokes [B0+0x138] at `562c4` with D and [M+0xb0].
Ticket-mask success continues at `5630c`, which requests another delay 10 and
then further initialization. Sweep success alone is not coordinator success,
and this review does not claim the full remaining initialization succeeds.
Delay calls are code observations; no real waits were performed.

## Implementation gate and remaining limits

The typed projection in this packet preserves the three semantic arguments, full
32-bit masking, original device identity, mode-1 NULL-chip real-writer call,
zero/nonzero status distinction, exact logger metadata, late wrapped index
and final 0/-1. Numeric constructor identities remain noncallable. BM1398's
similarly named sweep helper has a different constant and field layout and is
not equivalent to this expression. Reuse the existing BM1368 writer/encoder/
cache/transport composition instead of introducing an alternate writer.

The ordinary domain requires returning synchronous ARM-conforming callees,
valid live objects, ordinary readable opaque-global storage and initialized
strings. Device-field mutation by the writer is included; raw stack mutation,
invalid pointers, faults, asynchronous races and arbitrary lifetime violation
are excluded. Static code/data verification establishes these bounded facts;
it is not an instruction-level equivalence proof or hardware/runtime acceptance.

No hwscan startup caller is established. The standalone hwscan method and its
constructor slot are independent evidence for the method contract only. No
new discovery scan is presented as an exhaustive indirect-call graph.

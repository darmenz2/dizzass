# BM1368 RX filter: existing logic and new static associations

Parent: `8ed6e6b4fe934f9853472f062b6d9738488fc06b`, task branch
`codex/hardware-reverse-20261002`. Integration ref remains
`01299b84255542c16ee6d3f0c65a3e33e7aa876a`. Fresh remote refs and all 19 open
PR file scopes were checked on 2026-10-02. Their heads match fetched refs;
none touches BM1368 hardware/research paths. Issue #2 still has 66 comments;
the latest six were read and its latest is R-17 comment 5928580588, dated
2026-10-01. No +0x90 assignment occurs in that bounded comment read.
Unpublished parallel work is not excluded by these checks.

## Reuse decision

`evidence/verified-slices.json` and `evidence/stage6/recovery-manifest.json`
already identify `rx-filter-constant-4` at `[e3bc4,e3bfc)`, size 56, SHA256
`becdc62d16e26e6b43f80c53febbe9bfdf8652e698047571d37354d28a0ff269`.
Stage6 also records full filter dispatcher `[d2a84,d2bf4)` and bounded normal
and special register-response decoding. These receipts are historical
evidence, not new test runs.

Existing `src/backend/work-gen/work-gen.c` implements
`vn135_work_rx_filtered_register(chip)` as
`chip <= 4u ? 0x40u : UINT32_MAX`. Its declaration is in
`include/xminer/recovery/work_rx.h`. Existing `vn135_work_rx_next` extracts
register fields and classifies an equal address as `VN135_RX_REGISTER_FILTERED`.
No second constant getter, dispatcher, parser, native work type or queue is
introduced. Placement of the dispatcher projection in work-gen is an existing
integration choice; it does not establish the original dispatcher's filename.

REUSE.json pins the reused paths and receipt separately from the new evidence
packet. Historical sources, API, verified-slices record and production build
list remain unchanged. This unit closes a static method association rather
than reconstructing an already present algorithm.

## Exact original method bounds

| Image | File bytes | Full SHA256 |
| --- | ---: | --- |
| cgminer | 6228004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4883216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

All ends are exclusive. cgminer code `[e3bc4,e3bfc)` is 56 bytes with the
stage6 SHA256 above. Its 8-byte pool `[e3bfc,e3c04)` has SHA256
`76c67a9436423dc04d495b6f63bfe873287411784bca07674034b4e236faf9c9`.
The BX LR at e3bf8 prevents pool fallthrough. hwscan code `[f3610,f3618)`
is 8 bytes, SHA256
`4fe40444ba4fa963fbe4230783e64a772a93d31a1ee99e83adc54d696880082b`:
MOV r0,#0x40 followed by BX LR. hwscan has no opaque prelude or method pool;
whole-body byte equality with cgminer is not claimed.

cgminer loads x through literal e3bfc, PC value e3bd0, GOT 5def80 and global
68b808; y uses e3c00, PC e3bd8, GOT 5dfba0 and global 68b8c0. e3bd4 loads one
x snapshot, e3bd8 subtracts one, and e3bdc multiplies that same snapshot by
x-1. Modulo 2 the product is `b*(b xor 1)`, always zero. ARM low-word
truncation preserves the low bit, so e3be4 always branches to e3bf4 under
ordinary arithmetic. The y-value read e3be8 and back-edge e3bf0 are dead;
the ordinary return is 0x40. No assumption that BSS values are zero is needed.

The projection requires valid mapped GOT/global storage, ordinary returning
control flow and no asynchronous machine-state alteration. cgminer's ordinary
pointer/global reads are not reproduced by the existing constant-return C
projection; faults and access traces are outside the return-value association.
This packet does not execute or interpret the instructions.

## Constructor identity

cgminer constructor e1450 loads literal e1704 at e1528, resolves GOT 5def0c
at e152c with PC e1534 and retains e3bc4 in r3. e1564 stores r3 at
output+0x90. hwscan constructor f1d28 uses f1e00/f1e04, literal f1fdc,
PC f1e0c and GOT 4af708, then stores f3610 at +0x90 at f1e3c.

This numeric constructor association and the direct dispatcher call below
are separate static facts. The RX prefixes do not establish an indirect
invocation through a live +0x90 object. Method identity does not prove
runtime object ownership, T21 model dispatch or hardware acceptance.

## Direct selector-4 dispatch

Dispatcher d2a84 calls raw-selector getter fdfbc at d2a8c, compares the
returned word with 4 and uses the jump table rooted at d2aa4 for values 0..4.
Entry d2ab4 contains offset 0x94, selecting d2b38 when the getter returns 4.
d2b40 loads one x snapshot; d2b48/d2b4c compute x*(x-1), whose even low bit
makes BEQ d2b58 select d2bc8. That ordinary BL calls e3bc4.

After its return, d2bcc/d2bd0/d2bd4 again use one x snapshot. The even low
bit makes BEQ d2bdc select the return epilogue d2b6c. The duplicate call
d2bec and its back-edge d2bf0 are dead under the same arithmetic/domain
conditions. Selector 4 therefore reaches the existing 0x40 return projection
without an extra ordinary call. The new association does not identify the
commercial model represented by raw selector 4 or revise the host API's
existing behavior for other selectors.

hwscan dispatcher `[eaa24,eaa88)` independently corroborates that direct
association. Its selector-4 table entry at eaa54 contains offset 0x3c and
selects eaa80. After the pop epilogue at eaa80, eaa84 tail-branches to f3610,
the corresponding 0x40-return method. This is a relocated direct dispatch
path, not a claim that the entire two dispatchers are byte-identical.

## Two bounded RX consumers

The ordinary special-path call at c4798 invokes d2a84. The corresponding
register-address byte is loaded at c47b0 from `[fp-0x63]`. Its same-snapshot
parity predicate takes c47b8 to c4820; CMP c4828 compares the getter result
with that byte. Equality takes c4838 directly to c4844. Inequality reaches
c483c and the shared lower call 108938 at c4840.

The ordinary normal-path call at c4a3c invokes the same dispatcher. Its
register-address byte is loaded at c4a4c from `[sp+0x5d]`; the parity
predicate takes c4a54 to c4a78. CMP c4a7c and BEQ c4a80 likewise skip to
c4844 on equality, while c4a84 goes to c483c on inequality. The compared
value 0x40 is thus a filtered register-address byte. Separate +0x8c/e3bbc
returns reply key 0x44; neither value establishes a physical core count.

The bounded consumer windows do not establish the complete chain of incoming
field extraction, path selection and reachability preconditions. They reuse
historical stage6 register-response slices; those classifications are not
freshly reconstructed or semantically rerun here. The new evidence establishes
conditional direct-call/compare/branch associations once the named register
paths are reached with valid state. It does not prove the
whole RX thread, all frame layouts, CRC validity, nonces, shares, queue
ownership or handler completion. 108938 remains an explicit lower boundary;
its complete implementation and queue semantics are not established by
skipping or reaching its callsite.

## Verification and remaining limits

The checker pins exact reference identities, bounded region bytes/hashes,
reviewed annotations and reuse receipts, with explicit acceptance checks
enabled under Python -O. Reused source/header text pins use canonical LF,
permitting only CRLF-to-LF normalization; historical files are not rewritten.
Negative checks test corruption of this static
evidence, not executed instruction effects. These checks are integrity of
reviewed evidence rather than automatic proof of C equivalence or physical
behavior. Exact current commands/results are recorded in validation.json.

Historical stage6 differential tests execute original instructions with
injected boundaries. They are not run by this unit, and their old result
counts are not counted as new validation. No host source changed, so no new
GCC/Clang, sanitizer or ARM compilation is claimed for this research slice.
Any native core boundary check is recorded separately from filter semantics.
No reference ELF, emulator, firmware, device, UART or real pool is executed.
Constructor association, a selector-4 static RX path and an existing filter
do not establish full T21 reachability, accepted pool shares or production
driver registration.

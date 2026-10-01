# Static decision proof and ABI projection

Inputs as data only:
- cgminer, 6,228,004 bytes, SHA256 `b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`
- hwscan, 4,883,216 bytes, SHA256 `951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`

The complete bounded outer cgminer routine starts at `0xd21dc`, returns through
`0xd24e8` or selected tail calls, and has literals through `0xd253c`. hwscan's
counterpart spans `0xea69c..0xea7c4`, with literals through `0xea7e4`. Embedded
jump tables are rendered as data, not instructions. `evidence/dispatch-proof.json`
contains the exact raw words, arithmetic and source-hashed windows. These are
selected outer-body boundaries, not evidence of a whole-program call graph.

## Inputs, guard and writes

AAPCS32 integer/pointer argument registers are `r0=platform`, `r1=chip`,
`r2=subtype`, `r3=caller output`. Original pointers and method words are 32 bits.
The C projection uses uint32_t selectors/method identities, native pointers only
for aligned host storage and opaque caller identity, and int32_t return values.
It does not recover vendor declarations or dereference original VMA values.

| Property | cgminer witness | hwscan witness |
| --- | --- | --- |
| platform unsigned bound | `d21ec CMP ip,#4`; `d21f0 BHI d24e8`; r0 already -1 | `ea6a4 CMP r0,#4`; `ea6a8 BHI ea768`; MVN r0,#0 |
| shared method store | `d22d8 STR r3,[r2,#0x18]` | `ea71c STR ip,[r0,#0x18]` |
| common method store | `d22e4 STR r2,[r4]` | `ea728 STR r0,[r3]` |
| chip unsigned bound | `d22d0 CMP r1,#7`; later `d22e8 BHI d24e8` | `ea714 CMP r1,#7`; later `ea72c BHI ea768` |

The chip comparison occurs before the stores, but its conditional branch occurs
after them; intervening loads/stores do not change condition flags. This yields
partial writes on invalid chip, unlike invalid platform. Output+0 receives the
common **function identity**, not a pointer to another table. There are no
rollback stores in this outer routine, including after constructor failure.

## Transport identity selection

| Platform | Subtype | cgminer | hwscan |
| --- | --- | --- | --- |
| 0 | zero | `10fa38` | `108724` |
| 0 | nonzero | `10f938` | `108698` |
| 1 | any | `11d0cc` | `10e5e0` |
| 2 | any | `117f7c` | `10c724` |
| 3 | any | `f8048` | `fcd0c` |
| 4 | any | `109740` | `106244` |

For cgminer, GOT `5df454` contains shared object `68bf68`, yielding send slot
`68bf80`; GOT `5dead4` contains common callback `d253c`. For hwscan, GOT `4afe54`
contains object `4e4c94`, yielding slot `4e4cac`; GOT `4af744` contains callback
`ea7e4`. All 16 selected GOT cells and their PC-relative literal math are frozen.
The new C function projects **cgminer** identity values; it does not return
hwscan addresses or assert identical implementation bodies at matching roles.

The object is shared, not per-output/per-device. Repeated selections through the
same slot replace its method even with distinct caller tables. The existing
native send API uses host callbacks and is not ABI-compatible with these raw
identity words; a future typed production binding must explicitly map supported
implementations rather than casting identities to function pointers.

## Selected constructor identities

| Chip | cgminer target / primary edge | hwscan target / tail edge |
| --- | --- | --- |
| 0 | `d2db8` / `d241c` | `eaa88` / `ea764` |
| 1 | `d8c78` / `d2450` | `ed998` / `ea778` |
| 2 | `ea7c8` / `d2388` | `f6768` / `ea784` |
| 3 | `dcbe0` / `d2484` | `ef940` / `ea790` |
| 4 | `e1450` / `d23c8` | `f1d28` / `ea79c` |
| 5 | `e60e8` / `d24b8` | `f42a8` / `ea7a8` |
| 6 | `f0560` / `d2408` | `f95c8` / `ea7b4` |
| 7 | `f4448` / `d2414` | `fb130` / `ea7c0` |

Each selected edge receives the original caller output address in r0. All hwscan
edges are tail calls. cgminer selectors 2/4/6/7 tail-call; the others call and
return after opaque predicates. All preserve the constructor result in r0.
The repeated opaque routes are unreachable under ordinary readable-memory
semantics because every uint32 product n*(n-1) has low bit zero. The new function
omits those unrelated reads. It therefore does not claim fault, memory-access
trace, asynchronous mutation, exception or nonlocal-return equivalence.

No constructor implementation is supplied here. Passing a required callback is
an explicit reconstruction boundary, not a claim the callback is a working chip
driver. Missing callbacks are outside the valid-call domain, never replaced by a
successful default. Constructor status and synchronous pointed-to changes are
preserved, including unusual positive statuses. The output table's complete
size, other fields and methods remain dependencies of the selected body.

## Caller and reuse evidence

cgminer `73dd4..73e30`: platform 2, chip read through r6, subtype byte from context
+2c and output base+110 reach d21dc at `73de8`; `73e28` checks its returned status.
The reconstructed backend's `src/backend/base.c` still exposes this exact call
through `cold_object(...,0xd21dc,...,0x110,...)`. This addition does not alter that
caller or silently supply constructor success to it.

hwscan `e7a9c` passes selected platform, fixed chip 2, subtype 1 and context+30,
then calls ea69c at `e7abc`, before PSU preparation. Another inspected call at
`e7c68` uses dynamic chip and temporary stack output yet reaches the same shared
store. Earlier model/string extraction and later calculations are not analyzed
or executed here. Chip selector 2 is not AML platform selector 2; the existing
BM1368 interface separately records chip selector 4.

Existing UART open/destroy and send dispatch already have C projections. The
new function does not own their fd, mutex, queue or teardown. Native borrowed-fd
channel lifetime, partial-start rollback and physical startup remain separate.
No pending R13–R16 change is required or imported.

## C view, aliasing and lifetime domain

The explicit views name only the shared +18 word, output+0 word and output-base
identity. Both words are aligned writable uint32_t objects; output is non-NULL,
its common field begins at that base, and its required storage stays alive.
No packed structures, integer-to-function-pointer casts or vendor/native struct
casts are used. Identities/views/ops/context association stay fixed. Only pointed
data may change synchronously inside the constructor callback.

The two writable slots may be the exact same uint32_t object. Original sequential
stores then leave the common method identity, and the C code does the same;
this is covered by host alias cases and the reverse-store semantic control.
Partial-byte overlap, overlap with view/ops/catalog, concurrent users, races and
asynchronous interruption are excluded. Ordinary uint32 words are not atomics;
external serialization is required across all users of the shared selection.

For platform>4, neither view nor callback table is accessed. For invalid chip
with valid platform/storage, the callback table is not accessed. These are
original early-return properties, not generic NULL-pointer validation for valid
selection. Hardware presence and correct source-level caller layout are never
inferred from a successful return.

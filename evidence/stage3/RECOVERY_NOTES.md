# Stage 3 — exact recovered boundaries

Reference ELF SHA-256: b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9.
No hardware or full Linux process execution. Names below are new integration names.

## PLL search

`0xff288` → `vn135_pll_search_legacy`; `0xff660` → `vn135_pll_search_round4`.
Original hard-float inputs: r0 constraints, d0 requested frequency, r1 output.
Observed constraints layout (bytes): reference double +0; upper VCO +8; unused
+16; lower VCO +24; maximum reference int32 +32; maximum feedback +36; maximum
post divider +40; unused +44; starting error double +48. Size 56.
Output: VCO double +0; reference +8; feedback +12; post1 +16; post2 +20;
candidate-written +24; zero word +28. Size 32.

Legacy loops reference descending, post2 ascending, post1 ascending from post2.
Feedback is truncation toward zero, signed saturating, of
`(((post1 * requested) * post2) * reference_divider) / reference_clock`.
VCO uses the reference clock, feedback and reference divider. Allowed VCO has
0.1 tolerance on both endpoints; reference != 1 also requires VCO <= 3125.1.
A new candidate wins if no positive tuple exists OR error < prior_error + 0.1.
This deliberately allows a slightly worse replacement. Early exit error < 0.1.
A zero-feedback candidate can be written but the function still returns -1.

Round4 loops reference descending, post1 from 1 through max_post + 1, post2
from post1 descending to 1. Feedback is truncation of
`(((reference_divider * post1 * post2) * requested) * 4 / 100) + 0.5`.
The literal 4/100 is not replaced with 1/reference_clock. Feedback must be at
least 8 and at most the configured maximum. Reference == 1 limits VCO to 13325.
VCO bounds have no 0.1 margin. Error uses `(VCO / post1) / post2`, in that order.
Candidate comparison and early success use the observed 0.1 tolerance.

Literal doubles are preserved from 0xff630..0xff648 and 0xffb00..0xffb28.
The extra record at 0x5ebea8 is byte-equal to the C constant, including the
unused +16 value 2400.0. It is referenced by PC-relative adds at 0xeb8f0 and
0xebd54. The enclosing chip1398 callers use the legacy search. Testing round4
with this record is a differential input, not evidence that this caller chooses it.
The firmware's T21 model dispatch is not proven here.

Only logging call 0xfa0c4 is injected during PLL comparison. Original dead
opaque-predicate paths need not be reconstructed as artificial C obfuscation.
The local interpreter still executes the observed instructions and branch tests.
New C API guards cover invalid pointers/non-finite numbers and bounded iterations;
these inputs are not treated as vendor-equivalent behavior.

## PLL word

0xec01c..0xec060 prepares SET_CONFIG(ctx, mode=1, chip=NULL, reg=8, value).
Four result dividers are loaded from stack+32. Word:
`0x40000000 | ((ref & 63) << 8) | ((fb & 4095) << 16) | ((post1 & 7) << 4) | (post2 & 7)`.
Only that argument slice is compared; the surrounding cache updates, writes,
rollback, device-state changes and delays are not reconstructed by this helper.

## AML send

`0x117f7c` original arguments: r0 UART handle, r1 payload, r2 payload length.
The original rejects a null handle. It allocates length+2 bytes, stores halfword
0xaa55 in little-endian order, copies the payload, enters serialization, makes
one write, exits serialization and frees the frame. Exact written length returns
0; other write counts return -1, without an automatic retry. Allocation failure
returns -1 before synchronization or write.

External calls injected in original execution:
- 0x5940ec allocate; 0x5a2ee8 copy; 0x593c8c release.
- 0x5a6108 serialization entry; 0x5a66c4 exit.
- 0x10e6c0 lower write; 0xfa0c4 logging, excluded from compared trace.

Allocation size, ordering, UART handle, complete bytes written, release and return
are compared. No claim that the callback bridge is ABI-compatible with original
internal structs or recovers the lower write function. Locking correctness under
real concurrency and write timing are not established by single-threaded tests.

`0x118180` calculates a chain mask. The model result from 0xfdfcc is a supplied
input, not a restored model resolver. The function lacks its own surviving source
path reference; placement in aml/chip.c follows its adjacency to the source-tagged
send routine and is an association, not proof of its original file ownership.

Framing and earlier SET_CONFIG encoding are separately checked boundaries. The
intervening platform dispatcher 0xd26ac has not been fully recovered, so they are
not presented as an end-to-end validated T21 command path.

## Validation limits

Reference instruction interpreter is local, bounded and incomplete. VFP uses
Python binary64 for finite inputs with default rounding and synthetic opcode
checks; no floating exception flags, alternate rounding/denormal modes or
independent CPU certification. Passing tests is not proof for all inputs.
New C tested with GCC and Clang; the same 3,219 cases are counted once. ARM
objects are cross-compiled but not executed on ARM or linked into full cgminer.
Original binary and existing machine configuration remain unchanged.

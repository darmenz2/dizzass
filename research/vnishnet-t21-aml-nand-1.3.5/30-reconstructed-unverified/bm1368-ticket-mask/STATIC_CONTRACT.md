# BM1368 TICKET_MASK method and startup caller: independent static review

## Finding

The standalone TICKET_MASK method is proved in both pinned originals. There is
also a concrete **cgminer startup and resume path** to its constructor slot;
the caller is not inferred from the method name or from a matching offset.
On a successful ordinary startup path the configured model mask is applied
at `0x562c4`. An optional earlier soft-reset sequence applies all ones three
times, but that is temporary: this real worker passes zero as the coordinator's
third argument, so the later model-mask call is not skipped.

This clears the missing static caller question for a bounded BM1368 setter.
It does **not** establish a completed board-initialization implementation,
a native cgminer driver binding, hardware success, or hwscan startup parity.
This static review performed no C execution, firmware execution, instruction
interpretation, hardware call or real delay. Authored host validation is recorded
separately in `validation.json`.

## Inputs and reproducibility

`static-witness.json` contains the verified complete input identities, all selected
code bytes and SHA256 hashes, literal cells, and a 37-byte string comparison.
Exploratory discovery-scan records are not included in the public witness. The
52 method instructions match after normalizing only the writer/logger call
targets and the internal branch target. The witness identifies 48 selected code
regions: 46 for cgminer and two for hwscan. Selected caller regions are bounded
windows, not complete function extents.

- cgminer: 6,228,004 bytes, SHA256
  `b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`
- hwscan: 4,883,216 bytes, SHA256
  `951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`

The public `static-witness.json` and `static-pins.json` retain the reviewed
regions and operand/proof facts. `verify_evidence.py` checks these bounded data
records; optional complete-ELF comparisons are described in README.md. There is
no CPU state, original instruction execution or automatically established
C/original equivalence. EHABI navigation aids are not function-extent proofs.

## Whole method and reuse proof

The methods start at cgminer `0xe2130` and hwscan `0xf264c`. Each has 208 code
bytes and a separate 16-byte literal pool. The established code hashes are:

- cgminer: `c0d1904a5e2e0988d16affcf79f93d91903b1b3ecbb594f5b9552b6c2b3a3a1d`
- hwscan: `761ca01152d6839fee0e38c14ffe99ae849add49ad5927316cdfd6dcd4ec1ce1`

Both bodies preserve the device argument in r4 and transform the second
argument into a byte. The masks/shifts assign input bits 0 through 7 to output
bits 7 through 0. More explicitly, the surviving terms are:

```
((x & 1) << 7) | ((x & 2) << 5) | ((x & 4) << 3) |
((x & 8) << 1) | ((x & 16) >> 1) | ((x & 32) >> 3) |
((x & 64) >> 5) | ((x & 128) >> 7)
```

The first and final UXTB and the intervening masks establish that bits 8..31
cannot affect the result. The pre-existing
`vn135_bm1398_ticket_mask_word` first restricts to the low byte, swaps adjacent
bits with masks 0x55, swaps two-bit groups with masks 0x33, then swaps nibbles.
Those stages map every original bit i to bit 7-i, with no carries or overlapping
output terms. This is an algebraic equality for all uint32 inputs, not a test
against an executed original. Reusing that pure helper is justified; its BM1398
name does not select a BM1398 driver. Its current source hash is frozen in
`static-witness.json`.

The wrapper then calls the existing writer exactly once:

- `e21a8 -> e4a74`, or `f26c4 -> f3d7c`
- r0 = preserved device, r1 = 1, r2 = 0, r3 = 0x14
- fifth AAPCS argument at [sp] = reversed byte as a word

Writer status zero returns zero. Any nonzero status reloads device+0x18 **after
the writer returns**, adds one modulo 2^32, and logs severity 1, source line
507 (0x1fb), then returns -1. The wrapper has no retry, wait, second write, or
extra register read. Nested writer behavior and diagnostics remain separate.

The exact TICKET_MASK format is independently matched: cgminer initializer
`e5698/e569c` resolves `0x5eb495`; `e56a4` compares with 0x25 and `e56d4` XORs
with 0x80. Exactly 37 decoded bytes, including NUL, equal plain hwscan bytes at
`0x47e2bc`: `chain#%d - failed to set TICKET_MASK`. The old heuristic 42-byte
catalog length is not used as evidence.

## Constructor and owner provenance

Let B be the original backend, M its model, C a chain object, and D the device
context embedded in C. These are descriptive names for observed original
objects, not recovered C declarations or native ABI-compatible structs.

1. Cold construction stores M at B+0x18 (`73424`) and allocates the chain array
   with stride 0x320 (`7343c..73450`). For each C, `735ec..735f0` computes
   C = [B+0x230] + index*0x320, `735f8` stores its index at C+0x18, and `735fc`
   stores B at C+0x1c.
2. The previously accepted L07 dispatch proof establishes that the call at
   `73de8` receives output B+0x110, platform 2, chip selector from the model,
   and subtype from the model byte. The ordinary zero result at `73e28` is
   required for successful registration; nonzero takes the error path.
3. With chip selector 4, L07's selected edge is `d23c0..d23c8`, tail-calling
   constructor `e1450` with that output base. This review re-read the selected
   edge and constructor bytes; the full selector jump-table proof remains an
   explicit dependency on L07, not a newly inferred model-selection claim.
4. Constructor `e1640` loads literal `e176c = 0x4fe29c`; indexed load `e1644`
   resolves GOT cell `0x5df8e8`, whose word is `0xe2130`. At `e1664` r2 is
   output+0x20 and `e1668` stores {r1,r4,r5,r6}; r5 is the third word, hence
   output+0x28. Therefore B+0x138 initially contains this method identity.
5. The independent hwscan constructor has the same slot placement:
   `f1f18/f1f1c`, literal `f2044 = 0x3bddd8`, GOT cell `0x4afcfc = 0xf264c`,
   and `f1f3c/f1f40` store the third word at output+0x28.

The startup owner is the same kind of backend object. Successful cold
registration stores B into the registered device's +0x14 at `73eb8`.
Preparation `7409c` obtains its device through incoming context+0x24 and then
loads B from device+0x14 at `740ec..740f4`. Thus the preparation entry itself
should not be mislabeled as taking B directly.

## Concrete startup and resume call chain

The observed startup route is:

```
prepare 7409c
  74914: create worker 7bfc0, argument B
worker 7bfc0
  7c05c: call 67ff8(B)
startup 67ff8
  69d98: call 6c89c(B)
hashboard initializer 6c89c
  6dc98: create worker 7863c, argument A = {B, C, B+0x50}
worker 7863c
  786a8: call 55774(C, [B+0x18], 0)
coordinator 55774
  55e3c / 55e70 / 55ea4: optional all-ones masks
  562c4: later configured model mask
```

The raw pointer math is recorded, including the PC-relative worker addresses:
`74908 + 8 + 0x76b0 = 0x7bfc0`, and
`6dc08 + 8 + 0xaa2c = 0x7863c`. The original call entry `0x5a55cc` has the
thread-create argument shape and is already used as the thread-create boundary
in the accepted preparation/resume work. No scheduler or thread was run here.

Startup saves the incoming B in sb at `68010`, then [sp+0x1c] at `6884c` on
the successful route that reaches `69d94/69d98`. The route that bypasses this
save goes to an earlier error path; the whole startup routine is not translated
by this review. The independent resume entry `70e30` preserves B in r4 and
calls the same `6c89c` at `71648/7164c`.

The launcher preserves B in r8 at `6c8ac`. `6dc70` writes A[0]=B, `6dc78..6dc8c`
compute and write A[1]=[B+0x230]+i*0x320, and `6ceec` plus `6dc80/6dc88` establish
A[2]=B+0x50. Loop updates are +0x320 for the chain and +12 for A. Creation
failure is checked and does not imply a worker ran.

The worker loads C from A+4 (`7864c`). Before calling the coordinator it requires
`56fcc(C)` to be nonzero. The predicate is C.byte_24 != 0 and unsigned
(C.word_20 - 3) > 2, so states 3, 4, 5 are excluded. It then loads M from
A[0]+0x18. Its third argument comes from `82d60(A[2])`; the entire helper is
`mov r0,#0; bx lr`, so the third argument is exactly zero in this original.

## Coordinator conditions, cached owners, and later overwrite

The coordinator's original r0 is C, kept in sb (`55784`). Its original r1 is M.
Accessor `a720c` returns M+0x38 for nonzero M, and `a71f4` returns M+0x88.
The coordinator dereferences these results, so valid readable M is a required
ordinary-call precondition; their NULL-preserving accessors are not validation.

- Flags from board-view offsets +0x44 through +0x4d are read at entry. The
  relevant soft-reset flag is bit0 of board-view+0x46, equivalently M+0x7e.
- `55828` loads B0=[C+0x1c], and `55938` saves B0 at [sp+0x14]. The earlier
  low-frequency/check/clear path must succeed before reaching this save.
- `55af0` sets sl=D=C+0x2b8. The model chip view is restored into r5 from
  [fp-0x20] at `55b8c`; r5 was used for other purposes between entry and here.
- At `55c20..55c28`, a clear soft-reset flag skips the triple-reset block.
  A set flag enters `55de4` through the ordinary opaque-predicate route.
- `55de4` reloads B1=[C+0x1c] into r6. Each of three stages first invokes
  B1+0x1e8 with D, requires status zero, then loads B1+0x138 and calls it with
  D and UINT32_MAX. Every mask status must be zero to proceed. The first two
  successful stages are separated by calls to the delay entry with argument
  200; a third 200 delay follows the triple block before work-mode setup.
  These are observations of code, not delays performed by this review.
- Any of these nonzero statuses takes `55eb0`, logs/records a chain error via
  `56d18`, and returns -1 at `55f00`. They are a fixed ordered three-stage
  sequence, not retry-on-failure behavior.
- Later work-mode and enabled configuration callbacks must also succeed.
  `562a0..562a8` skips the configured mask only if the original third argument
  is nonzero. For the real worker above it is zero. The caller then requests
  delay argument 50 and invokes [B0+0x138] at `562c4` with D and
  word [r5+0x28] = [M+0xb0]. Thus a successful final writer can replace the
  preceding 0xff register value with reverse8([M+0xb0]). Even when this word
  also reverses to 0xff, the later call still occurs.

B0 and B1 are intentionally distinguished: the all-ones sequence reloads the
owner's backend, while the final call uses the earlier saved backend. The code
does not establish that arbitrary earlier callbacks cannot replace C+0x1c or
mutate a table. Similarly the final model word is loaded at the final call,
whereas the flags were loaded at entry. A faithful caller projection must
preserve those observations rather than cache everything at entry or assume
all method owners remain identical.

The constructor association proves which BM1368 identity the relevant slot
receives. Actual execution still depends on successful selection, unchanged
or appropriately updated method slots, valid live objects, and the earlier
startup operations. It does not prove that every model enables the optional
triple-reset flag or that every runtime reaches this call. No final-register
persistence beyond this explicit call is claimed.

## hwscan boundary and remaining work

The hwscan method and constructor slot are independently proved. A bounded
A32 discovery scan found no direct branch to `f264c`, and no non-PC/non-SP
immediate load at offset 0x58 or 0x138 followed within 32 bytes by BLX of the
same register. Offset 0x28 candidates were in unrelated later code. This is
not an exhaustive indirect-call graph: a different base, stack table, long
register lifetime, or another calling pattern can escape the scan. Therefore
no corresponding hwscan startup coordinator is claimed.

A later L11 setter can reuse the proven pure transform and existing writer.
It should keep numeric method identities noncallable and expose any host ABI
projection honestly. The full coordinator, every intervening callback, thread
lifecycle, original model parser/application, and production transport binding
are separate work. This caller proof does not turn the existing host profile
field into a completed live startup path.

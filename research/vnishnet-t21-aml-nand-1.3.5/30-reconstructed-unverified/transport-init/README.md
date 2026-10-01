# L-07: bounded transport/chip-method initialization

The missing cgminer `0xd21dc` decision path is implemented in the existing
project-specific `libbitmain/src/transport-dispatch.c`, behind
`VN135_TRANSPORT_INITIALIZE_135`. Declaration: `integration/transport_initialize_135.h`.
Base: `d3a93f424467bc9e3f2fcfc03feeadc75848141d`, including merged L-06/#99 and the thermal-header build repair/#102.

## Behavior implemented

- Unsigned platform selector greater than four returns -1 before destination
  writes or callback access
- Select the original transport method, with zero/nonzero subtype distinction
  only for platform zero; publish its identity in the shared send slot
- Publish the common callback identity in caller output +0, then reject unsigned
  chip selector greater than seven with -1, preserving both writes
- Dispatch exactly the selected chip initializer through a required callback
  and return its full signed status without normalization or rollback
- Preserve synchronous pointed-to mutations. If shared and common slots are the
  exact same uint32 object, the second/common store wins, as in the original

The bounds use actual fixed array lengths. There are no default-success
constructors, allocation, UART/device operations or registration. The prior
2,305-byte send-dispatch/binding implementation is unchanged byte for byte.

## Exact proof boundary

[Static proof](STATIC_PROOF.md) connects both pinned original ELFs to the guards,
method tables, caller, store order and selected constructor targets. Method words
are **32-bit original address identities as data**, never callable host pointers.
The new view is a typed comparison projection; it is not the vendor's full method
table, a native cgminer struct or production transport registration. Output base
and common-slot association, uint32 alignment, stable identities and serialized
shared-state access are caller preconditions.

The eight constructor bodies and the common callback body remain explicit,
unimplemented dependencies of this function. Their required storage, method
signatures, effects and resource ownership cannot be inferred from successful
selection. Backend cold startup still requires those real implementations; this
change does not wire a synthetic initializer into it. Existing UART open/destroy
and native borrowed-fd adapters are retained, not duplicated or given invented
rollback semantics.

## Tests and reproduction

From the repository root:

```
make -C research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/transport-init test sanitize
python -B research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/transport-init/verify_evidence.py --cgminer reference/cgminer.vendor.elf
```

The optional `--hwscan /path/to/private/hwscan` regenerates its evidence too. It
reads bytes through the pinned lab renderer; no instruction interpreter runs.

- 767 newly authored host cases / 5,507 assertions cover 200 valid selector
  combinations, invalid unsigned bounds, retained partial writes, arbitrary
  signed constructor returns, synchronous callback mutations, exact-slot aliases
  additional callback-owned fields and repeated selection through one shared
  transport word
- Most constructor callbacks return explicit refusal -55. Dedicated return tests
  include zero only to verify unchanged status propagation; no method table is
  filled or successful hardware initialization simulated
- 15 separately compiled safe semantic controls must fail by ordinary test
  assertion/exit 1. Build failure, crash, signal or timeout is not a detection
- 15 frozen-data checker tests: one pristine plus 14 inconsistent-input controls
- GCC strict-warning host tests and ASan/UBSan passed locally. Leak detection is
  disabled, so no leak-test pass is claimed. Clang awaits exact-head CI
- 32 bounded windows / 1,460 bytes / 64 assembly-and-receipt artifacts regenerate
  from both pinned originals; the verifier also passes under Python -O

These are host decision and static consistency tests, not original-instruction
comparison, hardware acceptance or complete miner-runtime tests. Validation and
review receipts identify what was actually checked. This new workflow is
host/static-only; independently inherited repository workflows have their own
scope and must not be relabeled as part of this static pass.

## Historical source guard

The inherited A-13 workflow keeps every existing regression command. Its guard
retains the thermal repair's complete three-record historical transition group
and adds only the exact reviewed transport blob transition. Partial/reordered
thermal groups, altered source, mode/type changes, deletions, renames and missing
refs remain rejected. Independent guard-only checks cover 206 cases using Git
objects and shell records; they execute no compiled C or original instructions.
The detailed guard fixture/review receipts are in the delivery checkpoint.

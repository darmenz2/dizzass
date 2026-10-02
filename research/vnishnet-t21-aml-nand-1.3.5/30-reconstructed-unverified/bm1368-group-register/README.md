# BM1368 register-0x58 startup configuration

This unit implements the original common-cache and chip-cache read/modify/write methods e3a1c/e3728, with matching hwscan methods f34fc/f33ec. It also implements a typed projection of the actual cgminer group-end caller b58e4. These close the coordinator's optional common-register call at5639c and grouping call at564dc. The grouping function's exact original source file and a hwscan caller counterpart remain unproved.

The wrappers live in the proved original chip1368.c module, behind VN135_BM1368_DRIVE_STRENGTH_135. The caller lives in explicitly named integration/bm1368_group_register_135.c. It reuses the existing device/chip projections, cache getter/setter algorithms, register writer, encoder/CRC, dispatcher, AML framing and UART host interfaces. Its callable binding is an ordinary typed C function; numeric constructor addresses remain noncallable evidence identities.

The [wrapper contract](WRAPPER_CONTRACT.md) records cache-read arguments, preserved bits, mode selection, original spelling and late diagnostics. The [grouping contract](GROUPING_CONTRACT.md) records fixed count and captured owners, mutable field/method observations, defined 32-bit descriptor arithmetic, first-error handling and the actual coordinator failure path. The [closure plan](CONVERGENCE_PLAN.md) tracks the remaining named coordinator dependencies.

Tests execute only authored host code with recorded side effects and valid caller-owned storage. They include real multi-group cache/write/transport composition, partial progress, late mutations and sanitizer instrumentation in every translation unit. No original binary or instruction interpreter, actual device, wait, pool or mining operation runs. Host success is not a chip acknowledgement, production driver binding, complete startup, or hardware acceptance. Existing cache guards/omitted dependency diagnostics and the 32-slot/no-safe-reuse boundary remain in force.

Run from the repository root:

```sh
make -f research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-group-register/Makefile test sanitize
```

The standard-library verifier checks exact bounded original bytes, instruction-field facts, complete wrapper call/branch/literal inventories, constructor references, decoded strings, source spans and manually reviewed contract identities. Optional --cgminer and --hwscan inputs are read as ELF data for whole-file and selected-byte comparison. The default witness contains 74 ranges / 7,936 original bytes with 1,699 instruction annotations. It also checks 25 capture/return words against the unchanged accepted L11 dependency, supporting the optional common caller's retained flag and late setting/error reads. It does not execute control flow or prove C/original equivalence automatically.

The chip source is pinned as historical prefix[0,14347), while the new headers and grouping source are exact. A future appended suffix is outside this historical witness; separate current-source and historical-state gates still require their own reviewed transition. Source-baseline records accepted provenance, not a waiver for stale current dependencies. Semantic controls edit only L14's chip span or the new caller in isolated copies and count only fully compiled, clean fixture rejections.

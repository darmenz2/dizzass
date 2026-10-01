# Original BM1368 reset method

This adds a callable host projection of cgminer `0xe1b64` / hwscan `0xf2214`
to the observed `libbitmain/src/chip/chip1368.c` module, under the separate
`VN135_BM1368_RESET_135` gate. The accepted 3,803-byte nonce/constructor prefix
is unchanged. The new function preserves the original conditional cache/write
sequence, full-word input normalization, error diagnostics, five delay requests,
callback-visible field mutations and final zero return.

The original returns zero after normal completion even when reads or writes
fail. This status does not establish a successful reset, ASIC readiness or an
acknowledgment. The existing `dizzass_bm1368_reset_cores` fail-fast policy and its
strict input validation remain a distinct, unchanged adapter.

## Contract and composition

`integration/bm1368_reset_135.h` documents the exact callback projection. It
reuses the existing typed device index and chip index/wire-address views; these
are not firmware layouts. The six semantic inputs are device, chip, fast,
unused fourth scalar, clock and pulse. Nonzero fast selects 1 ms; zero selects
5 ms. Clock and pulse retain only their low 3 and 2 bits.

Each reached cache read reloads live device/chip indices. Writes pass the same
identities and mode zero. Cache-error messages have no chain argument; each
indexed error reloads the current device index and adds one with 32-bit wrap.
The two W6 failure diagnostics independently reload the field. Successful
R2/R3 values are saved across W2 without rereading the cache.

Callbacks are returning, synchronous and serialized. All reached callbacks and
objects must exist. Callback/context identities stay stable, while device/chip
fields may change through valid mutable references. Temporary output and
diagnostic pointers are borrowed only during their callback. Invalid pointers,
raw stack mutation, asynchronous mutation and fault/access traces are outside
the supported domain; no unsafe probes are used to approximate them.

The nested host fixture binds the actual existing cache getter, register writer,
encoder/CRC and transport/AML/UART projections. Lowest effects only record or
refuse operations; no OS UART, device, real sleep or network operation is used.
It adds no second cache or protocol implementation. Lower-layer diagnostic
omissions remain those of their existing APIs, so the tests do not claim
equality of every firmware-process log.

L08's constructor slot `0x24` identifies this original method. Its 54 stored
addresses remain noncallable numeric identities. This packet does not cast
them to host function pointers or add a production method-table binding.

## Evidence and reproduction

[STATIC_CONTRACT.md](STATIC_CONTRACT.md) pairs the ordinary callback graph in
both independently hashed ELFs. The static witness records selected code/data
bytes and operand facts. The verifier checks those bytes without executing or
interpreting original instructions. The cgminer-only opaque predicates reduce
to the parity identity `x * (x - 1) & 1 == 0`; the simpler hwscan body corroborates
the resulting graph. Cross-ELF strings include the original `contol` spelling
and the literal function string `[redacted]`.

From this directory:

    make test sanitize

From the repository root, optional complete-source data checks:

    python3 research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-reset/verify_evidence.py --cgminer reference/cgminer.vendor.elf

The optional `--hwscan PATH` checks the private second ELF without publishing
it. The default verifier uses bounded witnesses. Host tests exercise the newly
authored C and actual existing helper sources; these are not vendor differential
execution, a formal lifting proof, physical timing validation or hardware
acceptance. `validation.json` records only completed checks and their limits.

Local GCC 14.2 validation passes 131,110 reset cases / 17,362,511 checks
and 2,661 composed cases / 592,778 checks, ordinarily and with every linked TU
instrumented by ASan/UBSan. Twenty-seven separately compiled semantic controls
are caught by the required fixture failure, and 20 static test methods pass
normally and with Python `-O`. The existing constructor, nonce, fail-fast reset
and common-register host/sanitizer regressions also pass. Leak detection is
disabled. The unchanged CRC TU retains L09's narrow sanitizer-build
`-Wno-sign-conversion` exception; all TUs remain instrumented. Local Clang and a
full native build were not run; exact-head CI is a later publication check.

`source-baseline.json` is provenance for the accepted dependencies and preserved
source prefix, not a claim that those historical hashes describe every future
checkout. Existing current-source gates retain their immutable old manifests
and enforce the exact reviewed reset append through explicit compatibility
transitions. New source changes must be audited again.

The L11 compatibility repair bounds the 27 unchanged semantic mutations to the
independently pinned reset bytes [3803,7519), preserving the constructor prefix
and every later source byte. `make partition` runs Python-only partition tests
normally and with `-O`; it neither compiles nor executes the C controls. The
validation results above and their original receipts remain historical L10
results. This scoped mutation tool does not validate arbitrary later appends;
the separate current-checkout pins enforce the reviewed complete source.

No production source selection, board admission, protection, live transport,
queue draining, ACK handling or device binding is added. The delay boundary
means requested milliseconds; real scheduling and reset completion remain
unresolved. The public packet contains only the reviewed function evidence,
new source/tests and receipts, not a full firmware extraction.

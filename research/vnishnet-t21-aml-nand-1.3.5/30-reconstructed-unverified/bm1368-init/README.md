# BM1368 method-table constructor

This adds the missing cgminer `e1450` constructor to the existing original-path
`libbitmain/src/chip/chip1368.c`, under `VN135_BM1368_INITIALIZE_135`. The existing
nonce implementation is preserved byte-for-byte. The constructor assigns 54
method-address identities to a 56-word caller-owned array, preserves words 0
and 6 (byte offsets 0 and 0x18), then returns zero. It performs no method calls.

The [static proof](STATIC_PROOF.md) covers the complete straight-line body and
all GOT/literal/store edges in two independently hashed ARM ELFs. Their code
bodies are identical; their literal pools and method addresses differ. The C
API projects the pinned cgminer identities only. It does not execute either
original image or an original-instruction interpreter.

## Storage and meaning

`integration/bm1368_initialize_135.h` requires at least 56 aligned writable
uint32_t objects in ordinary caller-owned storage. The addresses are numeric
identities, never callable host function pointers. Do not cast this array into
a native cgminer structure or a vendor ABI. Method signatures and a reviewed
typed binding remain separate work. Existing reconstructed method fragments can
be reused only after their individual contracts are checked.

The original routine reads the current GOT while writing the output. This
projection assumes the pinned GOT contents stay stable, output does not alias
GOT/code/literals or the original callee save frame, and execution returns
normally. No malformed pointers, races, faults, asynchronous interruption,
relocation or bus-access trace equivalence is claimed. Logical store statements
follow the original mapping; a host compiler may reorder unobservable ordinary
RAM accesses. The routine supplies no lock, barrier, rollback or atomic publish.

Return zero establishes completion of this pure constructor. It does not prove
a working ASIC, UART, sensor, driver or control-board startup. The 54 entries
are not 54 newly reconstructed functions. The common output+0 identity remains
the outer initializer's responsibility; its packet/CRC prefix already has a
partial reconstruction in `integration/bm1368_control.c`.

## Existing caller composition

The host tests compile the existing L07 `vn135_transport_initialize_135` and
route its chip-selector-4 callback to this actual constructor. Other selected
constructor identities are explicitly refused with -55. Tests retain platform
selection, caller/output identity, shared send state, invalid-chip partial
writes and invalid-platform early return. No successful hardware stub, second
driver/core, global registration or production linkage is added.

Aligned shared-send aliases into each of the 56 output words are also covered.
At offset 0 the common identity wins; at offset 0x18 the selected send identity
survives; at every written method slot the constructor identity wins. Retaining
the selected send word after composition assumes disjoint storage (or the
preserved +0x18 slot), not arbitrary aliasing.

## Reproduction

From this directory, with Capstone 5.0.6 and pyelftools 0.32 installed:

    make test sanitize

Static verification against the repository source, from the repository root:

    python3 research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-init/verify_evidence.py --cgminer reference/cgminer.vendor.elf

The optional `--hwscan PATH` verifies the second private source without copying
it into the repository. Verification re-renders all eight code/data artifacts,
checks the 108 fixed GOT cells and mappings, and optionally compares every
published byte with the full source hashes. Literal pools are rendered as data.

Local GCC validation: 277 host cases / 17,161 checks, 57 separately compiled
safe semantic controls, 20 static-checker tests in ordinary and Python -O modes,
and the unchanged nonce bounds test's 33,047 checks. Constructor/composition and
nonce tests also pass ASan/UBSan. Leak detection is disabled; no leak-test pass
is claimed. These are authored host/static tests, not vendor differential
execution or full native/hardware acceptance. Clang and remote exact-head CI
are separate from this local validation snapshot.

The compile-time-disabled source is also checked against the accepted old
translation unit. Current-source compatibility preserves the historical nonce
prefix and old evidence witnesses while permitting only the reviewed exact
append. Unrelated source pins, earlier compatibility transitions and production
build selection remain enforced.

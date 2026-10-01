# Original BM1368 TICKET_MASK method

This implements cgminer `e2130` / hwscan `f264c` in the observed
`libbitmain/src/chip/chip1368.c` module, under the separate
`VN135_BM1368_TICKET_MASK_135` gate. The previous 7,519-byte source prefix is
unchanged. The 831-byte append reuses the existing pure bit-reversal helper and
actual BM1368 register writer.

The method reverses only the low eight input bits, then calls the writer once
with the same device, broadcast mode 1, NULL chip, register `0x14` and that byte
as a word. Zero writer status returns zero. On failure it reads the current
device index after the writer returns, adds one modulo 2^32, emits the original
line-507 TICKET_MASK diagnostic and returns -1. It adds no retry, delay, second
write or extra cache read. A failed result can follow packet dispatch.

The existing helper's BM1398 name identifies its earlier reconstruction. Its
scalar permutation is algebraically identical to both BM1368 bodies for every
uint32 input; calling it does not select a BM1398 driver. The actual BM1368
writer retains its own encoding, send-before-cache, broadcast fanout, status
normalization and lower diagnostic behavior.

## Original caller and interface boundary

[STATIC_CONTRACT.md](STATIC_CONTRACT.md) proves a concrete cgminer startup and
resume route through real thread arguments, cold ownership stores and the
constructor slot. The backend table starts at +0x110; slot +0x28 is read at
backend+0x138 by reset coordinator `55774`. An optional ordered sequence applies
UINT32_MAX three times. The real worker passes zero as the coordinator's third
argument, so its successful path later applies the current model word at
`562c4`. The all-ones mask is temporary.

The proof preserves the distinction between the earlier cached backend B0 and
the backend B1 reloaded for the triple sequence. Entry flags and the later
model-word read also have different lifetimes. Earlier callbacks, failures and
method-slot mutation remain explicit preconditions; the full coordinator is
not implemented here. No equivalent full hwscan startup caller is claimed.

`integration/bm1368_ticket_mask_135.h` exposes a typed synchronous host interface.
It preserves device identity and mutable index reads through the existing view;
it is not a vendor layout or varargs ABI. The reached diagnostic pointer is
borrowed only during its callback. Numeric constructor entries remain
noncallable identities, and production source selection is unchanged. This
method alone does not apply the existing host profile or establish ASIC readiness.

## Tests and reproduction

From this directory, with a C11 compiler and Python's standard library:

    make test sanitize

Optional full-source data comparison from the repository root:

    python3 research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-ticket-mask/verify_evidence.py --cgminer reference/cgminer.vendor.elf

The optional `--hwscan PATH` reads the second private ELF without publishing it.
Default verification uses bounded byte witnesses. Code and literal pools are
separate, and selected caller windows are not represented as whole functions.
The old heuristic 42-byte format range is corrected by direct initializer
evidence: 37 bytes including NUL, matching the independent hwscan literal.

The focused host fixture calls the actual pure helper, writer, encoder/CRC,
cache, dispatcher, AML and UART projections. A linker observer checks writer
arguments and then forwards to the real writer without substituting status.
Lowest effects record or refuse requests using caller-owned valid storage.
Coverage includes all 256 low-byte values, six high-word examples, targeted
send/cache/diagnostic-index cases, a bounded EAGAIN replay and an explicitly
mask-only four-call subsequence. That last fixture checks observed arguments
and cache effects; it does not supply successful missing coordinator callbacks.

GCC ordinary and all-TU ASan/UBSan runs pass 277 cases / 22,785 checks. Fifteen
separately compiled semantic controls must fail with the required fixture marker;
build errors, signals and timeouts are not detections. Ten focused evidence-test
categories exercise both normal and optimized Python. `validation.json` records
the final completed checks and existing-regression outcomes. Leak detection is
disabled, and the unchanged CRC TU retains the earlier narrow sanitizer-build
warning exception; every linked TU remains instrumented. Local Clang and a full
native build are separate from this host snapshot.

`source-baseline.json` records accepted dependency provenance. Immutable older
source/validation receipts retain their historical meanings. Current-source
gates enforce the exact ticket → reset → constructor → nonce transitions where
applicable. A13 preserves its eight previous states and adds one complete exact
state. L10's 27 semantic controls now mutate only their fixed reset span, leaving
the ticket append byte-identical. No original firmware execution, instruction
interpreter, model/OOM probe, physical I/O or real wait is part of this packet.

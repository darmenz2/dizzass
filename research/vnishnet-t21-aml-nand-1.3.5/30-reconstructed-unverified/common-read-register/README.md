# Common READ_REGISTER / GET_STATUS wrapper

This reconstructs the missing ordinary wrapper `d253c` (hwscan `ea7e4`) in its
proven original source path, `libbitmain/src/chip/chip.c`, behind
`VN135_COMMON_READ_REGISTER_135`. It reuses the existing command encoder, CRC5
and transport dispatcher. The existing encoder names this wire command
READ_REGISTER; the original diagnostic calls it GET_STATUS.

The callable host method normalizes broadcast bit 0, the optional chip address
word's low byte and the register's low byte. It sends one five-byte command
body through the current transport method. Zero status returns zero. Every
nonzero status reads the device-index projection after send returns, emits one
diagnostic with the observed argument bits, and returns -1.

There is no cache read/update, response parsing, ACK wait, retry or rollback in
this wrapper. A zero return is a synchronous callback result, not evidence of
an ASIC reply or working hardware. The logger hook represents one invocation;
it does not prove a line reaches a terminal or file.

## Source and boundary evidence

The two separately hashed ELFs establish the complete wrapper bodies, CRC call,
live transport selection, return paths, post-send index load and diagnostic
arguments. cgminer's parity-dead duplicate logging block is excluded by the
identity that n*(n-1) is even in uint32 arithmetic. Its encoded diagnostic strings
are supported by the bounded original initializer and .init_array entry;
hwscan supplies matching plaintext. Neither original program or initializer is
executed by this work.

See the [complete static contract](STATIC_CONTRACT.md) and
[checker scope/reproduction](STATIC_CHECKER.md). The public checker verifies all
17 unchanged dependencies and the selected code, literal, string, branch and
initializer witnesses with explicit checks that remain active under Python -O.
All 50 checker tests pass in both modes. Optional complete-image verification
checks 33 selected cgminer regions and 14 hwscan regions against full file hashes.

The original path is `/tmp/build/libbitmain/src/chip/chip.c`, module `driver`,
function text `[redacted]`, source line 103, severity 1, and format
`chain#%d - failed to send GET_STATUS command`. `[redacted]` is present in the
pinned input, not an inferred function name. Index plus one wraps modulo 2^32;
the original `%d` interprets those bits as signed. The host diagnostic exposes
`index_bits` explicitly and does not claim the original logger ABI or perform
a printf conversion.

The header defines a small explicit device identity/index view. It is not a
native cgminer or vendor struct layout. The chip input reuses the existing
`vn135_chip_reference`; its cache index is not used. Ordinary valid memory,
stable views/callback associations, external serialization and normal returns
are required. Pointed-to fields may change synchronously. No callback may
retain a borrowed temporary packet or diagnostic object. Host payload constness
is a boundary restriction, not proof that the original ARM pointer was const.

The failure branch requires a valid associated device-index word and logger.
The success branch does not read either. A NULL device identity is admitted
only when the selected callback accepts it and returns zero. Invalid, freed,
unaligned or original-stack/GOT aliasing pointers are not probed. Fault timing,
nonlocal returns, mutable original strings, races and exact stack geometry are
outside the normal host projection.

## Actual helper composition

Host tests call the existing L07 selector and L08 BM1368 table constructor,
check the known common/AML identities, and then call named C functions through
explicit typed host bindings. No ARM address is cast into a function pointer.
The actual path is the new wrapper → existing dispatcher → existing AML bridge
→ existing framing → existing legacy UART helper. Lowest writes are recorded
and refused; no device, PTY, socket, pool or OS I/O callback runs.

The reused encoder supplies seven bytes with the AML prefix. The wrapper passes
only bytes 2..6; selected AML framing adds exactly one prefix. Tests check this
framing, allocation/release order, separate outer/inner lock callbacks, and
post-send diagnostic state. The unchanged legacy UART helper may retry its
entire frame on EAGAIN: one wrapper send does not mean one lower write attempt.
That behavior is covered with five recorded refusals and five recorded sleeps,
with no real sleeping. This does not add a write-all policy. Existing lower
helpers' omitted diagnostics remain omitted; one log refers to this wrapper.

## Host validation

The current public suite passes 3,086 cases / 45,714 checks with GCC 14.2:
byte normalization and golden CRC vectors; NULL optional chip; zero/negative/
positive/extreme send statuses; failure-only index access; post-send and log
mutations; callback replacement for the next call; and complete refused-write
composition. Twenty separately compiled semantic controls are detected by
ordinary exit 1 and a failure marker. Compile errors, crashes and timeouts do
not count as detected controls.

ASan/UBSan pass on all eight compiled translation units and the same cases.
Leak detection is disabled. An initial sanitizer compile failed on the unchanged
CRC helper's uint8_t-promotion warning under the additional conversion flag.
The final runner scopes `-Wno-sign-conversion` to that unchanged CRC translation
unit during sanitizer compilation only; its shifted value is always 0..255.
All other warnings and all sanitizer instrumentation remain enabled. That failed
compile is retained in the validation record, not counted as a test pass.

From this directory, with Capstone 5.0.6 and pyelftools 0.32:

    make test sanitize

From the repository root, the original cgminer file is read only as data:

    python3 research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/common-read-register/verify_evidence.py --root . --cgminer reference/cgminer.vendor.elf

The optional `--hwscan PATH` verifies the separately retained second input;
neither complete executable is included in this candidate's evidence files.

No full native build, original-instruction oracle, hardware acceptance or local
Clang result is claimed by this local snapshot. Exact-head GCC/Clang CI is a
separate publication gate.

## Dependency and publication boundaries

The pre-edit audit verified every accepted C source, header and workflow and
found no complete existing wrapper. Build files enumerate sources explicitly;
the new original-path module is compiled only by this isolated target. Encoder,
CRC, dispatcher, AML, UART, selector and constructor sources remain unchanged,
so their current whole-file pins and historical compatibility records remain
valid. The incomplete old vendor/source and Stage14 inventories are historical
witnesses and are not rewritten. Pending runtime-stack work stays separate.

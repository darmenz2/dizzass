# Current-checkout dependency pins: thermal, transport and BM1368 appends

The historical evidence JSON files remain byte-identical. Their original base
commit/tree, reference SHA-256, ranges, strings, and dependency blob IDs remain
historical witnesses; this repair neither regenerates nor relabels them.

The six consuming checkers inspect the current checkout. Three dependency paths
therefore need narrowly scoped compatibility transitions:

| Consuming evidence | Historical pinned path | Required current checkout |
| --- | --- | --- |
| `bm1368_reply_key_135.json`, `chain_reset_cleanup_135.json`, `chip_sensor_check_135.json` | `integration/thermal-routes-135.mk` at `f68baf7a096b3b261e6249600b726eb120bebfbb` | `40d0fb336501875982f22ac6453ee4ddd58d8762` |
| `bm1368_pulse_width_135.json` | `libbitmain/src/transport-dispatch.c` at `8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef` | `d030308564c47bf409a3d381f16ddf262e6acf26` |
| `bm1368_frequency_135.json`, `bm1368_register_write_135.json`, `bm1368_pulse_width_135.json` | `libbitmain/src/chip/chip1368.c` at `c64374454e6e458ec1a175f21f03af141e29a3aa` | `1cd2c6e7612b494c28f0bbbab0e62434d104881d` |

The shared verifier requires the exact original expected pin and exact current
blob, never an arbitrary list of accepted hashes. For the thermal Makefile,
removing the single exact ` -Iinclude` addition in `ROUTES135_FLAGS` must reproduce
the original Git blob byte-for-byte. This is the include-path repair accepted in
[PR #102](https://github.com/darmenz2/dizzass/pull/102).

For transport dispatch, the first 2305 bytes must reproduce the original Git blob.
The exact new full blob additionally binds the complete appended initialization
implementation from [PR #103](https://github.com/darmenz2/dizzass/pull/103), and its
separate `VN135_TRANSPORT_INITIALIZE_135` gate is checked explicitly. This does not
relax the pre-existing dispatch implementation or certify a functioning miner.

For BM1368, all first 920 bytes still must reproduce the original nonce source
Git blob. The first 3803 bytes must reproduce the exact constructor-only blob
`0de837d281e81eb4503b4193b45ef076ec600b6e`, including its separately checked
`VN135_BM1368_INITIALIZE_135` gate. That preserved prefix's SHA-256 is
`b0d68763aa141ffa25e4df3b70e6e55a444cd59f44db405f51b9a80aea6a7a2a`.
The first 7519 bytes retain the complete L10 reset source, Git blob
`e024519eda8df9c1c85697548e8e0629f7c0f5cf`, SHA-256
`e3c8cecb8869c59847db357d26541e95123fa1cb4cf2ef04642a62c2e1e0738d`.
The bytes from 3803 through 7518 form the separately checked
`VN135_BM1368_RESET_135` gate, including its header inside the gate.

The complete current source is exactly 8350 bytes, Git blob
`1cd2c6e7612b494c28f0bbbab0e62434d104881d`, SHA-256
`ed818babcb847fb38094af8f08ae3c0ac6ef690192aa1e6030c3f8326e9968d9`.
Only bytes after the preserved L10 source form the new
`VN135_BM1368_TICKET_MASK_135` gate, including exactly its own header.
The outer transition pins the full source and exact reset prefix before
validating ticket gate shape. The existing reset-to-constructor and
constructor-to-nonce predicates then apply unchanged to the recovered layers.
Each header remains within its gate; no nested conditional, extra include,
else/elif branch or text outside the reviewed append is admitted.

All full-source and preserved-prefix identities remain independent checks.
Neither an arbitrary suffix nor a reset-only, constructor-only or nonce-only
source is accepted as the current checkout. The reset entry retains original
error continuation and does not replace the distinct fail-fast
`dizzass_bm1368_reset_cores` adapter. The ticket setter calls the existing pure
low-byte transform and actual BM1368 writer; it adds no duplicate CRC, cache,
protocol or transport implementation. No earlier source byte changes.

The constructor installs fixed original method identities; it does not execute
those methods, establish their complete ABIs, or imply production/hardware
acceptance. This transition preserves the historical evidence manifests.

The old blobs are only reconstruction witnesses. Substituting any old blob
into a current checkout fails: it would undo the include-path repair or delete
an exact initialization/reset/ticket append. No historical-replay acceptance
switch is added. Every other manifest dependency still must equal its original
blob. Dependencies must use canonical repository-relative paths and be
non-executable regular files, with no symlink parents. Missing files, renames,
symlinks, directories, FIFOs and executable mode changes fail closed.

All original reference/range/string/instruction predicates remain in the six
checkers. Explicit exceptions replace the pre-existing Python assertions in
five of them so `python3 -O` cannot silently remove evidence checks. Reading the
ELF through the existing parser treats it as data and executes no instructions.

The six workflows preserve every original regression command. They also run
these host-only controls in normal and optimized Python modes:

```
python3 integration/tests/test_current_dependency_pins_135.py
python3 -O integration/tests/test_current_dependency_pins_135.py
```

The three thermal-consuming workflows now watch the thermal Makefile and the
header behind PR #102's include-path change. All six watch this verifier, its
tests and this document. Frequency, register-write and pulse-width explicitly
watch both `libbitmain/src/chip/chip1368.c` and
`integration/bm1368_initialize_135.h`. Each retains push and manual coverage and
uses the same path list for pull requests, so the current-checkout checks run
before merge. Frequency and register-write use this helper for every immutable
dependency, just as pulse-width already does. None of these changes replaces original-instruction comparisons,
changes production source selection, or authorizes firmware processes, model/OOM
experiments or device operations.

The A-13 UART workflow keeps its historical baseline and complete raw `D/M/R/T`
diff command unchanged. `check_uart_posix_historical_135.py` preserves all six
originally accepted exact combinations and the complete eleven-record
constructor and reset groups. It adds exactly one complete eleven-record ticket
compatibility group. Its chip source destination is the exact 8350-byte blob;
every other record stays the same. The new group is derived from complete
historical/current tree metadata and candidate bytes, including modified
existing files. The earlier eight accepted states remain byte-identical;
only the ticket group's destination hashes are checked against the current
checkout. Modes, old/new blob IDs, status, ordering and paths remain bound;
partial or mixed groups fail. Metadata controls retain fixed hashes for all
eight old states and exhaustively check subsets of all fourteen distinct
records. The unfiltered PR workflow runs them normally and with `python3 -O`.
No separate historical guard or workflow regression command is broadened.

The L09 `common-read-register/verify_evidence.py` also actively checks chip1368.c.
Its immutable `source-baseline.json` still records the 3803-byte constructor-only
dependency, and its unchanged `static-pins.json` still anchors that receipt.
A self-contained outer transition admits only the exact 8350-byte ticket source,
recovers the exact 7519-byte L10 source and validates the ticket gate. It then
retains the reset gate transition and applies every original size, SHA-256 and
Git-blob predicate to the preserved 3803-byte constructor dependency. No helper
import or new workflow dependency is introduced. All 17 dependencies remain
active; the other 16 stay full-file pins, and the research index remains the
sole inactive provenance entry. Controls independently exercise every layer's
identity, preserved bytes and gate shape with matching-hash overrides, along
with prior-source rejection, receipt identities and unrelated dependencies.

L08's constructor evidence and prior validation receipts remain unchanged. Its
host builds and L09's host composition leave both later gates disabled. L10
host fixtures leave the ticket gate disabled. Each old configuration therefore
retains its original include and link closure.
The existing nonce, constructor, cache, register writer, encoder, CRC, dispatcher
and fail-fast implementations retain their previous bytes and contracts.

L10's semantic control runner now partitions only its pinned original reset
span rather than treating reset-to-EOF as one method. Both its constructor
prefix and reset span remain independently pinned; every mutant preserves
both the original prefix and later suffix byte-for-byte. All 27 existing
control definitions, exact replacement counts, compiler flags and required
fixture failures remain unchanged. Metadata-only partition controls run
normally and with Python `-O`. This scoped mutation helper is not a current-source
acceptance policy: the exact global gates above remain mandatory. L10's
source-baseline, static pins/witness, validation snapshot and logs stay immutable;
new compatibility results are recorded in the L11 packet.

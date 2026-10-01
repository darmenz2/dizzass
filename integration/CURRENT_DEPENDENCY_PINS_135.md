# Current-checkout dependency pins: thermal, transport and BM1368 appends

The historical evidence JSON files remain byte-identical. Their original base
commit/tree, reference SHA-256, ranges, strings, and dependency blob IDs remain
historical witnesses; this repair neither regenerates nor relabels them.

The six consuming checkers inspect the current checkout. Three exact changes
therefore need narrowly scoped compatibility transitions:

| Consuming evidence | Historical pinned path | Required current checkout |
| --- | --- | --- |
| `bm1368_reply_key_135.json`, `chain_reset_cleanup_135.json`, `chip_sensor_check_135.json` | `integration/thermal-routes-135.mk` at `f68baf7a096b3b261e6249600b726eb120bebfbb` | `40d0fb336501875982f22ac6453ee4ddd58d8762` |
| `bm1368_pulse_width_135.json` | `libbitmain/src/transport-dispatch.c` at `8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef` | `d030308564c47bf409a3d381f16ddf262e6acf26` |
| `bm1368_frequency_135.json`, `bm1368_register_write_135.json`, `bm1368_pulse_width_135.json` | `libbitmain/src/chip/chip1368.c` at `c64374454e6e458ec1a175f21f03af141e29a3aa` | `e024519eda8df9c1c85697548e8e0629f7c0f5cf` |

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
The complete current source is exactly 7519 bytes, Git blob
`e024519eda8df9c1c85697548e8e0629f7c0f5cf`, SHA-256
`e3c8cecb8869c59847db357d26541e95123fa1cb4cf2ef04642a62c2e1e0738d`.
Its remaining bytes form one separately checked `VN135_BM1368_RESET_135` gate,
including the new header inside that gate. No earlier source byte changes.
Both full-source identities and the preserved constructor identity are checked;
the historical nonce witness is then recovered using its existing predicates.
Neither an arbitrary suffix nor the constructor-only source is accepted as the
current checkout. The reset entry preserves original error continuation and
does not replace the distinct fail-fast `dizzass_bm1368_reset_cores` adapter.

The constructor installs fixed original method identities; it does not execute
those methods, establish their complete ABIs, or imply production/hardware
acceptance. This transition preserves the historical evidence manifests.

The old blobs are only reconstruction witnesses. Substituting any old blob
into a current checkout fails: it would undo the include-path repair or delete
an exact initialization/reset append. No historical-replay acceptance
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
originally accepted exact combinations and the complete eleven-record constructor
group. It adds exactly one complete eleven-record reset compatibility group.
That group's chip source record requires the exact new blob; every other record
remains the same. The groups were derived from the complete frozen baseline and
current tree metadata, including modified existing candidate files. The earlier
seven accepted states remain exact historical witnesses; only the reset group's
destination hashes are checked against the current checkout. Modes, old/new blob
IDs, status, ordering and paths remain bound; partial or mixed groups fail. Its host-only
`test_uart_posix_historical_135.py` controls run normally and with `python3 -O`
in that unfiltered pull-request workflow, including when either guard file
changes. This extraction does not broaden the separate frozen historical guards
in other stage-specific workflows.

The L09 `common-read-register/verify_evidence.py` also actively checks chip1368.c.
Its immutable `source-baseline.json` still records the 3803-byte constructor-only
dependency, and its unchanged `static-pins.json` still anchors that receipt.
A self-contained transition admits only the same exact 7519-byte source and
reset gate, recovers the preserved 3803-byte prefix, and applies every original
size, SHA-256 and Git-blob predicate to that prefix. No helper import or new
workflow dependency is introduced. All 17 dependencies remain active; the
other 16 stay full-file pins, and the research index remains the sole inactive
provenance entry. L09 controls reject changed reset bytes, changed preserved
bytes, prior source versions, changed receipt identities and every unrelated
active dependency in normal and optimized Python modes.

L08's constructor evidence and prior validation receipts remain unchanged. Its
host builds and L09's host composition leave the reset gate disabled, so the
new header and reset callbacks add no link dependency to those configurations.
The existing nonce, constructor, cache, register writer, encoder, CRC, dispatcher
and fail-fast implementations retain their previous bytes and contracts.

# Current-checkout dependency pins: thermal, transport and BM1368 constructor

The historical evidence JSON files remain byte-identical. Their original base
commit/tree, reference SHA-256, ranges, strings, and dependency blob IDs remain
historical witnesses; this repair neither regenerates nor relabels them.

The six consuming checkers inspect the current checkout. Three exact changes
therefore need a narrowly scoped compatibility transition:

| Consuming evidence | Historical pinned path | Required current checkout |
| --- | --- | --- |
| `bm1368_reply_key_135.json`, `chain_reset_cleanup_135.json`, `chip_sensor_check_135.json` | `integration/thermal-routes-135.mk` at `f68baf7a096b3b261e6249600b726eb120bebfbb` | `40d0fb336501875982f22ac6453ee4ddd58d8762` |
| `bm1368_pulse_width_135.json` | `libbitmain/src/transport-dispatch.c` at `8ceb8405390e3eaf9f7b34480eb3cdd040a3b0ef` | `d030308564c47bf409a3d381f16ddf262e6acf26` |
| `bm1368_frequency_135.json`, `bm1368_register_write_135.json`, `bm1368_pulse_width_135.json` | `libbitmain/src/chip/chip1368.c` at `c64374454e6e458ec1a175f21f03af141e29a3aa` | `0de837d281e81eb4503b4193b45ef076ec600b6e` |

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

For BM1368, all first 920 bytes must reproduce the original nonce source Git
blob. The exact 3803-byte current blob binds the complete appended constructor
under its separately checked `VN135_BM1368_INITIALIZE_135` gate. Its SHA-256 is
`b0d68763aa141ffa25e4df3b70e6e55a444cd59f44db405f51b9a80aea6a7a2a`.
The constructor installs fixed original method identities; it does not execute
those methods, establish their complete ABIs, or imply production/hardware
acceptance. This transition preserves the historical evidence manifests.

The old blobs are only reconstruction witnesses. Substituting any old blob
into a current checkout fails: it would undo the include-path repair or delete
an exact initialization append. No historical-replay acceptance
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
previously accepted exact combinations and adds one complete eleven-record
constructor compatibility group. Modes, old/new blob IDs, status, ordering and
paths remain bound; partial or mixed constructor groups fail. Its host-only
`test_uart_posix_historical_135.py` controls run normally and with `python3 -O`
in that unfiltered pull-request workflow, including when either guard file
changes. This extraction does not broaden the separate frozen historical guards
in other stage-specific workflows.

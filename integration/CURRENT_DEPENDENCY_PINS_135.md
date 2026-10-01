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
| `bm1368_frequency_135.json`, `bm1368_register_write_135.json`, `bm1368_pulse_width_135.json` | `libbitmain/src/chip/chip1368.c` at `c64374454e6e458ec1a175f21f03af141e29a3aa` | `890e2bfc9ead81a9cafe5b34c917b37133ea0d5e` |

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

The first 8350 bytes retain the complete L11 ticket source, Git blob
`1cd2c6e7612b494c28f0bbbab0e62434d104881d`, SHA-256
`ed818babcb847fb38094af8f08ae3c0ac6ef690192aa1e6030c3f8326e9968d9`.
Only bytes 7519 through 8349 form the independently checked
`VN135_BM1368_TICKET_MASK_135` gate, including exactly its own header.

The first 9245 bytes retain the complete L12 sweep source, Git blob
`f23565c15c9d174e644fc51a401e81dbe072dfd7`, SHA-256
`e4c05fb8bc541e6e6b2a216cbaecf7ef57cc3d85101d59b81e8ebd3d4e2af7e4`.
Only bytes 8350 through 9244 form the separately checked
`VN135_BM1368_SWEEP_CLOCK_135` gate, including exactly its own header.
The sweep transition pins its recovered source and exact ticket prefix before
validating sweep gate shape. The retained ticket-to-reset, reset-to-constructor
and constructor-to-nonce predicates then apply to the recovered layers.
Each header remains within its gate; no nested conditional, extra include,
else/elif branch or text outside the reviewed append is admitted.

The complete current source is exactly 11280 bytes, Git blob
`890e2bfc9ead81a9cafe5b34c917b37133ea0d5e`, SHA-256
`91cfb6f3bb640bcf3519027243970bcb37aeeb0275f96b931dd17cab940540d2`.
The 2035 bytes after the preserved L12 source form one independently checked
`VN135_BM1368_ADDRESS_COMMANDS_135` gate. It contains exactly the new
`integration/bm1368_address_commands_135.h` include followed by the existing
`integration/bm1368_control.h` include, both inside the gate. The new outer
transition requires the exact current source and the exact 9245-byte sweep
prefix before checking this two-include gate and terminal boundary. It then
applies every earlier sweep/ticket/reset/constructor/nonce predicate unchanged.
The appended INACTIVE and SET_ADDRESS wrappers reuse the existing encoder and
transport dispatcher; no old header, helper implementation or source byte changes.

All full-source and preserved-prefix identities remain independent checks.
Neither an arbitrary suffix nor a sweep-only, ticket-only, reset-only, constructor-only or
nonce-only source is accepted as the current checkout. The reset entry retains
original error continuation and does not replace the distinct fail-fast
`dizzass_bm1368_reset_cores` adapter. The ticket setter retains its existing pure
low-byte reversal and actual BM1368 writer. The sweep setter independently
encodes `0x80008b00 | ((field1_2 & 3u) << 1)` and calls that same writer;
it does not use the distinct BM1398 sweep encoding or replace the initial
no-op or pulse-width methods. No duplicate CRC, cache, protocol or transport
implementation is added and no earlier source byte changes.

The constructor installs fixed original method identities; it does not execute
those methods, establish their complete ABIs, or imply production/hardware
acceptance. This transition preserves the historical evidence manifests.

The old blobs are only reconstruction witnesses. Substituting any old blob
into a current checkout fails: it would undo the include-path repair or delete
an exact initialization/reset/ticket/sweep/address append. No historical-replay acceptance
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
constructor, reset, ticket and sweep groups. It adds exactly one complete eleven-record
address compatibility group. Its chip source destination is the exact 11280-byte
blob; every other record stays the same, as independently derived from every
historical/current tree leaf and actual candidate bytes/modes. The earlier ten
accepted states remain byte-identical; only the address group's destination hashes
are checked against the current checkout. Modes, old/new blob IDs, status,
ordering and paths remain bound; partial or mixed groups fail. Metadata controls
retain fixed hashes for all ten old states and exhaustively check subsets of all
sixteen distinct records. The unfiltered PR workflow runs them normally and with
`python3 -O`. No historical guard or workflow regression command is broadened.

The L09 `common-read-register/verify_evidence.py` also actively checks chip1368.c.
Its immutable `source-baseline.json` still records the 3803-byte constructor-only
dependency, and its unchanged `static-pins.json` still anchors that receipt.
A self-contained outer transition admits only the exact 11280-byte address source,
recovers the exact 9245-byte L12 source and validates the address gate. The retained
sweep transition recovers the exact 8350-byte L11 source and validates its gate. It then
retains the exact ticket-to-reset and reset-to-constructor transitions and
applies every original size, SHA-256 and
Git-blob predicate to the preserved 3803-byte constructor dependency. No helper
import or new workflow dependency is introduced. All 17 dependencies remain
active; the other 16 stay full-file pins, and the research index remains the
sole inactive provenance entry. Controls independently exercise every layer's
identity, preserved bytes and gate shape with matching-hash overrides, along
with prior-source rejection, receipt identities and unrelated dependencies.

L12's `bm1368-sweep-clock/verify_evidence.py` independently reads the current
chip source and sweep header. Its frozen `proof.runtime_sources` still records
exactly the accepted 9245-byte source and original sweep header; the witness,
metadata SHA and static pins are unchanged. A self-contained exact address-to-sweep
transition recovers the source witness before every existing runtime-source
size/SHA/Git-blob predicate is applied. The sweep header remains a full-file pin.
Independent controls cover previous-current rejection, each identity component,
preserved sweep bytes, exact gate shape and header drift. Matching-hash overrides
exercise the inner predicates without admitting altered metadata in real use.

L08's constructor evidence and prior validation receipts remain unchanged. Its
host builds and L09's host composition leave reset, ticket, sweep and address gates
disabled. L10 host fixtures leave ticket, sweep and address gates disabled; L11's
host fixtures leave sweep and address disabled; L12 leaves address disabled. Each old configuration therefore
retains its original include and link closure.
The existing nonce, constructor, cache, register writer, encoder, CRC, dispatcher
and fail-fast implementations retain their previous bytes and contracts.

L10's semantic control runner continues to partition only its pinned original
reset span [3803,7519). Both its constructor
prefix and reset span remain independently pinned; every mutant preserves
both the original prefix and later suffix byte-for-byte. All 27 existing
control definitions, exact replacement counts, compiler flags and required
fixture failures remain unchanged. Metadata-only partition controls run
normally and with Python `-O`. This scoped mutation helper is not a current-source
acceptance policy: the exact global gates above remain mandatory. L10's
source-baseline, static pins/witness, validation snapshot and logs stay immutable;
new compatibility results are recorded in the L13 address packet. L11's semantic
control runner likewise retains its exact [7519,8350) ticket span and original
prefix/witness hashes. Its 15 control definitions, flags and required clean
fixture failures remain unchanged, with every later sweep/address byte preserved in
each mutant. Neither span end is extended to EOF; historical L11 baselines,
static pins/witnesses and validation snapshots/logs remain unchanged.

L12's semantic runner likewise retains exactly its [8350,9245) sweep span,
original prefix/witness hashes and all 17 controls. Every address byte is preserved
in each mutant. None of the three old span endpoints is extended to EOF.

L08's older constructor mutation runner is unchanged. It splits at the constructor
gate and treats the remainder through EOF as its body. Its 54 method-word mutants
remain constructor-local, but its three return/overwrite mutants also alter later
return statements inside disabled gates. The new address gate stays disabled in
that suite. This retained baseline limitation is not byte-preserving suffix
partition coverage; no partition repair or old-witness rewrite is part of L13.

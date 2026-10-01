# BM1368 startup address commands

This reconstructs the original INACTIVE and SET_ADDRESS wrappers in
`libbitmain/src/chip/chip1368.c`. They use the existing command encoder, CRC5
and transport dispatcher, with explicit typed host bindings and recorded lower
operations. The real startup coordinator invokes these two methods before its
later configuration steps. Software chip addresses already come from the
accepted cold-setup projection; this pair transmits those supplied values.

The original method identities are INACTIVE `e47b8` / hwscan `f3bcc`, and
SET_ADDRESS `e48fc` / hwscan `f3c74`. Their constructor slots are +b4 and +b8.
The 54 numeric constructor identities remain noncallable data. This unit adds
two callable host projections, without a vendor-layout cast or native driver
registration.

## Observable behavior

Each method sends exactly one five-byte command body. The existing encoder
produces a seven-byte frame, so the wrapper removes its 55 aa prefix before
dispatch. The existing AML layer supplies that prefix once. INACTIVE sends
`53 05 00 00 CRC5`; SET_ADDRESS sends `40 05 low8(address) 00 CRC5`.

Exactly-zero transport status returns zero. Every nonzero status produces one
failure diagnostic and returns -1. The device index is read after the failed
send and incremented modulo 2^32. SET_ADDRESS also rereads the full address
word after failure for its `%02x` diagnostic. The sent byte therefore can
differ from the address in the error message after a synchronous callback
changes the chip object. The format's minimum display width does not truncate
the diagnostic argument.

The [typed API](../../../../integration/bm1368_address_commands_135.h) documents
valid storage, stable bindings, borrowed temporary lifetimes and mutation
boundaries. It reuses the existing common-read identity/index view and
`vn135_chip_reference`; these are named host projections, not original ARM
object layouts. Diagnostic arguments are recorded as data, without pretending
to reproduce the original variadic logger ABI.

The caller's inline addressing stage is a separate contract: it ignores both
method statuses, requests 30 ms after INACTIVE and 10 ms after each address,
and reloads the current chip array, method slot and signed count at the observed
points. Its retained owner and model-view identities are distinct from other
startup stages. The full coordinator is not implemented by this pair. The host
sequence fixture demonstrates continuing after a command failure; it does not
replace the missing coordinator or establish safe hardware behavior.

## Evidence and tests

[STATIC_CONTRACT.md](STATIC_CONTRACT.md) records both complete method bodies,
literal pools, constructor stores, exact string-initializer bounds and the
selected real caller. `static-witness.json` and `static-pins.json` contain
bounded byte evidence. The standard-library verifier checks data identities
and selected encoding/branch/reference facts. Ordinary control-flow and parity
conclusions remain reviewed static reasoning, not automatic C/original
equivalence. No original instructions are executed.

The host fixture separately compiles the actual command methods, encoder,
CRC5, dispatcher, AML framing and UART helper. It checks all wire-address bytes,
selected high-word aliases, positive and negative error statuses, post-callback
field changes, lock/cleanup ordering and bounded legacy UART replay. A short
addressing sequence ends in the actual common READ_REGISTER method. Every
terminal write and wait is a recording callback using bounded caller-owned
storage; no device, pool or operating-system I/O is supplied.

`tests/negative_controls.py` changes only the new 2,035-byte gated span. Its
34 compiled semantic controls must exit through the fixture assertion path;
compile failure, crash or timeout does not qualify. Previous source and any
later append remain byte-identical. Existing reset, ticket and sweep mutation
spans are unchanged. The older constructor suite retains its existing broader
disabled-body mutation partition; this unit does not claim that partition
preserves every disabled suffix byte.

Run from this directory:

```sh
make test sanitize
make CC=clang test sanitize
python3 -B verify_evidence.py --cgminer /path/to/cgminer.vendor.elf --hwscan /path/to/hwscan
```

Optional ELF comparison only hashes and reads bounded data from the two pinned
inputs. Compiler runs and source identities are recorded in `validation.json`.
The dedicated workflow uses GCC and Clang; local validation is identified by
its actual compiler, without claiming local Clang execution.

## Limits

There is no cache update, ACK wait, address allocator, retry in either wrapper,
rollback or readiness signal. Existing UART whole-frame replay remains an
explicit lower-layer behavior, including replay after a short write with stale
EAGAIN. INACTIVE is not established as a power-off, queue-drain or fresh-epoch
barrier. Production startup, physical replies, protections and safe slot reuse
remain outside this unit.

The static runtime record binds the accepted source prefix through byte 11,280
and the exact new header. Later separately gated appends do not rewrite that
historical proof. Independent current-checkout guards admit only their exact
reviewed full-source states. This distinction preserves old evidence without
treating an arbitrary future edit as an accepted runtime.

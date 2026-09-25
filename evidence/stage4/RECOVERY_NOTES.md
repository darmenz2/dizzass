# Stage 4: register cache and SET_CONFIG control flow

Reference SHA-256:
`b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
All disassembly comes from this unchanged ELF. No firmware entry point, Linux
process, network operation or physical ASIC was executed.

## Original memory layout and boundaries

| Object | Original layout |
|---|---|
| cache pointer | global `0x654d68` |
| chain count | signed 32-bit global `0x654d6c` |
| enabled flag | byte at `0x654d70` |
| register entry | `uint32_t address; uint32_t value;` (8 bytes) |
| table | 64 entries (512 bytes) |
| chain | common table + chip-table pointer at 512 + count at 516 (520 bytes) |

The new API uses an explicit context. Its native 64-bit chain record is 528 bytes;
ARM32 static assertions check the original 520-byte layout. Native allocation
traces are normalized by record type before comparison, not misrepresented as
identical host/ARM allocation byte counts.

| Routine | Original address | Restored scope |
|---|---|---|
| init | `0x106a58` | selector dispatch, allocations, copies, partial failure, flag |
| reset | `0x106e58` | prefix reset; does not change counts/enabled flag |
| get chain | `0x107188` | validation, 64-slot linear search, output/error |
| set chain | `0x107648` | common write, same-slot propagation to all chips |
| get chip | `0x1079f0` | validation and search within selected chip's table |
| set chip | `0x107ed0` | selected chip only; common value is unchanged |
| destroy | `0x1082b4` | disable, per-chip free, chain free, clear globals |
| SET_CONFIG | `0xee8e4` | CRC, one dispatch, conditional cache update, final return |

These boundaries were checked against prologues/epilogues and branch targets;
EHABI buckets alone were not used as proof of one function per interval.

## Defaults and lookup semantics

Eight 512-byte tables are extracted, not synthesized. See `cache-defaults.json`
and `tools/extract_reg_cache_defaults.py`. The selector is an internal 0..7 enum;
no physical model association or safe operating profile is asserted.

The cache searches by stored address and stops on the first match. It does not
index by `register >> 2`. Selector 5 includes non-aligned addresses, e.g. `0x25`,
and repeated `0xff` entries. A blanket rule rejecting every `0xff` address would
change the observed behavior. An initial native test assumed `0xff` was absent;
it was corrected to use an actually absent address, without changing the
reference-derived implementation or differential oracle.

Common writes propagate by SLOT, even if a chip table's keys have been reordered.
Per-chip writes do not modify the common value or other chips. Getters preserve
the caller's output on failure. Cache reset need not enable a disabled cache.

## Command/cache transaction

`SET_CONFIG` constructs the 9-byte packet and invokes `0xd26ac` before cache
validation. A nonzero transport result returns -1 without modifying cache.
After successful dispatch it calls common cache setter if mode != 0, otherwise
the selected chip setter (NULL chip means cache index 0 and wire address 0).

Header selection is `mode == 1 ? 0x51 : 0x41`, while cache fanout uses `mode != 0`.
These conditions are intentionally NOT collapsed into one Boolean predicate.
Wire addresses are truncated to one byte; cache register validation sees the
full 32-bit value. Thus register `0x108` is sent as `0x08`, then cache validation
fails. The reconstruction preserves this ordering but provides no live sender.

A failure return can follow a successful dispatch. Automatic retries or treating
that failure as proof that hardware was unchanged would be incorrect. Successful
write/dispatch is not an acknowledgement from a hash chip. Integrators must
preflight live requests and track uncertain outcomes outside this low-level API.

## Adaptations that are NOT recovered vendor behavior

- Explicit caller-owned context and native pointers replace global singleton.
- Invalid API pointers, negative/overflowing counts and re-init of an owned cache
  are refused (-2). Reset counts cannot exceed owned storage.
- Extra guards avoid dereferencing corrupt integration pointers. They do not
  turn a corrupted context into a verified runtime state.
- C names, headers, allocator callbacks and pure-default export are new.
- Diagnostic formatting/XOR constructors are not reconstructed here. Logging is
  suppressed in the oracle; redundant opaque parity predicates are not copied.
- Serialization is the caller's responsibility; no thread-safety claim is made.

Original allocation failures can retain partially allocated state; destroy is
required before retry. This behavior is tested with failure at every allocation
position. The integration does not silently report success or leak by retrying.

## Verification boundary

Complete original routines run in the existing bounded A32 interpreter with
calloc/free/memcpy/diagnostic hooks. New native C and original code are compared
for return, whole tables, enabled/count state, allocation/free ownership and
unchanged output on failure. Red zones catch out-of-allocation writes in tested
cases. SET_CONFIG tests execute ORIGINAL CRC and ORIGINAL cache calls together;
only the transport boundary and log calls are intercepted there.

This is an offline test harness, not an independently certified ARM emulator or
real board. No proof of UART receive, chip acknowledgements, sensor validity,
PSU safety, mining, timing, concurrency or T21 model binding is implied.

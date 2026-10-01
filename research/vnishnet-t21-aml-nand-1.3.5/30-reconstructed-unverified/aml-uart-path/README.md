# L-06: original AML UART pathname result

This adds the missing pure pathname getter to the existing
`libbitmain/src/aml/platform.c`, with its declaration in
`include/xminer/recovery/aml_platform.h`. It does not add another platform module,
startup caller, miner, device opener or production registration. The existing
chain-reset body is unchanged and checked by a source-region digest.

The function `vn135_aml_uart_path_135(uint32_t chain_index)` returns:

| Unsigned index | String contents |
|---|---|
| 0 | `/dev/ttyS3` |
| 1 | `/dev/ttyS2` |
| 2 | `/dev/ttyS1` |
| Every other uint32 value | Empty, non-NULL string |

The array's actual length guards every subscript. An invalid index does not
wrap and does not select a fallback UART. All results have static lifetime;
callers must not modify or free them. A caller needing a usable route must
inspect contents rather than test only for NULL. The strings identify logical
AML chain routes in this firmware, not measured physical connector wiring or
permission to access those devices.

## Evidence and exact scope

Both separately pinned ELF files contain the same unsigned decision and table:
`hwscan` getter `0x10e220`, `cgminer` getter `0x11c080` with its decision core at
`0x11c0c0`. The tables have exactly three inspected pointers. Out-of-range paths
return a pointer to a mapped NUL byte before indexing. See
[STATIC_PROOF.md](STATIC_PROOF.md) for literal arithmetic, callback assignments,
caller seams and the initialization assumptions.

In cgminer, the path strings are initially encoded. Three observed 11-byte XOR
loops in constructor `0x11c2b8`, referenced by its initialization array, decode
the three strings. This result is conditional on one normal initialization pass
and unchanged tables/strings. Re-running that XOR constructor would toggle the
strings back. The C getter exposes the initialized pathname result directly;
it does not reproduce initializer writes, opaque-predicate global reads,
original absolute pointer identities, writable-string behavior or faults caused
by invalid vendor mappings. It is a bounded return-content reconstruction,
not an assertion of complete instruction/memory-trace equivalence.

The two private references are data only:

- cgminer SHA-256 `b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`
- hwscan SHA-256 `951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`

No vendor process, instruction interpreter, emulator, boot script or original
constructor was run. XOR was applied only as a fixed data transformation to the
three known 11-byte path strings. No model/Jansson/OOM probes were resumed.

## Existing caller seam, without device success

The existing `src/backend/work-gen/chain-work-start.c` already has an explicit
selected-method `o->path` callback. Its original method slot and thunk correspond
to the getter mapped here. It still requires caller-selected method binding,
UART/open behavior and real lifecycle integration. This change does not wire it
into production or change its caller policy.

Eleven host composition cases compile the actual unchanged caller with the new
getter. Recording callbacks never access devices. Every attempted open is
intentionally refused with -55, so no created thread or successful transport is
invented. Cases cover the three routes, initial range rejection, already-running
short-circuit and index changes by earlier synchronous callbacks. Such a later
index change can reach the getter after the caller's initial range check; the
getter must still guard the full unsigned domain and return an empty string.
This is the existing offline projection's documented mutable-field behavior,
not proof of a live concurrent driver race.

## Checks

- 393,231 deterministic host result checks: all low-16-bit values under five
  selected high-word patterns, explicit boundaries and 65,536 pseudorandom
  values. This is not exhaustive testing of every 32-bit input
- Eight separately compiled, memory-safe semantic controls must be rejected by
  test exit 1. Compilation failures, crashes and signals do not count as detection
- Eleven existing-caller composition cases, with every attempted open refused
- Twelve static evidence tests, including eleven deliberately corrupted-data
  controls. These inspect data and do not execute original code
- GCC ordinary and AddressSanitizer/UndefinedBehaviorSanitizer runs cover the
  direct and composed host tests. Leak detection is disabled; no leak-check
  result is claimed. The getter itself allocates no memory
- Both private source regenerations reproduce all 66 assembly/receipt files
  for 33 windows totaling 1,308 bytes. Remote CI can regenerate cgminer only;
  the complete hwscan remains private

The expected normal-return status evidence from L-05 is preserved. No claim is
made about complete scanner/model behavior, actual UART existence, successful
controlboard startup, physical I/O, hashboards or first-share readiness.
R13/R14/R15/R16, protected settings and device registration are untouched.

## Reproduce

From this directory:

```sh
make test
make sanitize
# Optional byte regeneration with the existing hash-pinned static-analysis env:
python3 -B verify_evidence.py --cgminer-reference /path/to/cgminer.elf --hwscan-reference /path/to/private/hwscan.elf
```

Tests compile the actual tracked source and unchanged caller, not a copied
implementation. `source-baseline.json` pins the unchanged caller/dependencies
and old reset body. The static checker uses explicit checks even under Python
optimization. Its hashes are provenance/consistency records, not signatures
against coordinated edits to the evidence and checker. Hardware permissions and
the separate staged controlboard/fan/PSU/hashboard review remain prerequisites
for any later physical experiment.

# Original BM1368 cached A8/18 sequence

Parent: `5891d4afe62ead6b306475303144aae57ad78dc1`, task branch
`codex/hardware-reverse-20261002`. Integration ref remains
`01299b84255542c16ee6d3f0c65a3e33e7aa876a`. Fresh remote refs, actual AGENTS
and all 19 open PR file scopes were checked on 2026-10-02. PR heads are
unchanged and no candidate paths overlap. Five PR API base SHAs retain older
integration snapshots; their file lists were also compared with current-base
diffs and agree. The latest six of issue #2's 66 comments were read; its
latest remains R-17 comment 5928580588 dated 2026-10-01. Unpublished parallel
work is not excluded by that bounded read.

An exact numeric search across the whole checkout, including historical
manifests, src, reconstruction, integration and tests, found only constructor
identities and neighbouring boundaries for this method. No historical
verified-slice range contains e3c04. Existing COMMON getter and register
writer are reused; their code and interfaces are not reconstructed again.

## Exact original bounds

| Image | File bytes | Full SHA256 |
| --- | ---: | --- |
| cgminer | 6228004 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 |
| hwscan | 4883216 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |

All ends are exclusive. cgminer code `[e3c04,e3dd0)` is 460 bytes, SHA256
`763ee4325290cac5d9913b3e8907b979b09894b2f9bbbd3c21ce5764b80412f1`.
Its 8-byte pool `[e3dd0,e3dd8)` has SHA256
`dcf52df5a5f460b20a63a0040fb7d26454ba9f2b53b5b6a0e6eaa67f3fbf991c`.
The pop at e3dcc prevents pool fallthrough. hwscan code `[f3618,f36f0)` is
216 bytes, SHA256
`c32a75976b6e3f17ed1a24138469c512a857d46524c38708cbb9aec1f08a5b93`.
Its pop at f36ec ends the method without a literal pool. hwscan lacks the
cgminer opaque blocks; whole-body byte equality is not claimed.

## Constructor

cgminer constructor e1450 loads literal e1700 at e1520 and resolves GOT
5de630 at e1524 with PC value e152c, retaining e3c04 in lr. e1568 stores
that identity at output+0x94. hwscan constructor f1d28 uses f1df8/f1dfc,
literal f1fd8, PC f1e04 and GOT 4af9cc, then stores f3618 at +0x94 at f1e40.
The bounded nineteen constructor words match between images with relocated
literals/GOT values. These are numeric method identities rather than callable
host pointers or evidence of T21 runtime dispatch and device ownership.

## Two COMMON reads

Original r0=device and r1=flag. The method retains the flag as raw word bits;
its condition is exactly zero versus any nonzero value, not flag==1.
The first index load e3c14/f3628 reads device+0x18 and passes its signed
32-bit interpretation to COMMON getter 107188/10564c at e3c24/f3638,
register 0xa8 and a local output address. Any nonzero status immediately
returns -1; neither the second read nor either writer is accessed.

On exactly-zero status, e3c34/f3648 reloads current device+0x18 for the second
getter at e3c40/f3654, register 0x18 and a separate output address. A mutation
after the first read may therefore select a different chain for the second.
Any nonzero second status returns -1 without accessing writer. There is no
cache preflight, chip argument, wire GET_STATUS read or invented validation.

The original stack outputs at sp+0xc and sp+8 are uninitialized before their
getters. The C locals preserve that domain: each reached reader must assign
a valid uint32 word on exactly-zero return, and must not inspect incoming
indeterminate output before assigning it. A refusing reader may leave output
unassigned or write before refusing; the method ignores it on failure. Neither
a zero fallback nor a success-without-assignment fixture is justified.

The typed `vn135_bm1368_register_pair_cache_135` binding calls existing
`vn135_reg_cache_get_chain`, which searches COMMON's 64 stored-address slots
and preserves output on failure. Its structural guards and omitted original
internal diagnostics/access traces remain the existing host API's boundary.
This packet establishes the method's getter identity and arguments, not every
nested original getter effect or a new cache implementation.

## Local transforms and ordered writes

Both successful read outputs are captured before writing. The flag remains
the input word captured before the callbacks:

| Input flag | Transformed A8 | Transformed 18 |
| --- | --- | --- |
| nonzero | `cached_a8 \| 0x10f` | `cached_18 & ~0xf00000` |
| zero | `cached_a8 & ~0xf0` | `cached_18 \| 0xff0f0000` |

The zero-path mask for 18 combines OR 0x000f0000 and OR 0xff000000;
the nonzero path clears 0x00f00000. These are distinct bit positions. No
physical mode, power state or recommended setting is inferred from the flag
or masks. Later cache mutations do not reread or recompute either snapshot.

The first writer at e3d30/f36b0 calls existing e4a74/f3d7c with the original
device identity, mode 1, NULL chip, register 0xa8 and its transformed word.
Any nonzero result returns -1 and skips the second writer. Only exactly-zero
status allows e3d74/f36d4 to call the same writer with mode 1, NULL chip,
register 0x18 and the second captured word. Exactly-zero second status returns
0; every nonzero returns -1. Arbitrary lower status values are not propagated.

Existing writer composition performs encoder/CRC, one send per reached write,
then chain cache update after a successful send. It loads then-current signed
device index for cache dispatch after send. Device mutations at read/send
boundaries may change destinations without changing captured payload values.
Existing nested writer logging, including a send-failure line-350 event,
remains inside that callee; this wrapper adds no outer diagnostic or strings.

The chain setter uses COMMON's matched numeric slot for every chip table.
Coherent table layouts are required to interpret those slots as the same
register; no per-chip address search or replacement setter is added. Cache
storage, counts and arrays must remain owned and valid across callbacks.
An error may follow dispatch. Earlier successful sends/cache updates are
not rolled back when a later call fails. This sequence supplies no atomicity,
ACK, wait, retry, second attempt, preflight or hardware-state guarantee.

## Six products, five conditional parity tests

Each cgminer product uses one loaded x snapshot and x-1 from that same word.
Modulo 2, `b*(b xor 1)` is zero for b=0 and b=1; low 32-bit truncation
preserves bit 0. Separate x loads need not agree. The first product at
e3c54/e3c58/e3c5c is tested at e3c60, but no conditional instruction consumes
its flags before e3c7c overwrites them. The remaining five low-bit predicates
always take their BEQ whenever the relevant path is reached:

| x load | test/BEQ | taken target |
| --- | --- | --- |
| e3c64 | e3c7c/e3c80 | e3c90 |
| e3c98 | e3ca4/e3ca8 | e3cd4 |
| e3cd4 | e3cf8/e3cfc | e3d18 |
| e3d3c | e3d48/e3d4c | e3d5c |
| e3d7c | e3d90/e3d94 | e3dc4 |

Duplicate transformation block e3d08, the extra writer e3dbc and back-edges
e3c8c/e3d14/e3dc0 are dead under ordinary ARM arithmetic. There are at most
two ordinary getter calls and two ordinary writer calls, with the status gates
above. GOT 5dfc2c and 5defd8 identify x/y at 68b8c8/68b810 in .bss.

The nonzero-flag path still reads y's value at e3cd8 before the always-taken
branch; only its use by CMP e3d00 is dead. This ordinary read, pointer/global
reads and the discarded initial TST are omitted nonfaulting access traces,
not evidence that original memory access is absent. Other y-value reads at
e3c84/e3cac/e3d50/e3d98 are dead. Valid mapped storage and unaltered ordinary
control flow remain required; the projection does not model memory faults.

## Projection and validation boundary

`vn135_bm1368_configure_register_pair_135` uses a chain-only typed reader and
the existing writer operations. Device index projects device+0x18, not a
parent chain's independent index. The host structures and new filenames are
integration choices, not vendor/native ABI or recovered original method names.
Device identity, callback tables/contexts, code and reached associations stay
valid and fixed for synchronous returning callbacks. Fields and reachable
valid cache contents may mutate at boundaries. Output words and payloads are
borrowed only during callbacks; no retained temporary pointers or aliases into
other local storage are supported. Concurrent effects require external
serialization. Writer is required only after both reads succeed. Invalid
pointers, races, nonlocal returns and indeterminate-value reads are outside scope.

The evidence checker independently pins packet/source identities, bounded
region bytes/hashes and reviewed annotations; explicit acceptance checks remain
active under Python -O. This is integrity of reviewed evidence, not automatic
C equivalence or instruction execution/interpretation. Host tests compose
actual existing cache/writer/encoder/CRC with recording/refusal callbacks.
Compiled semantic controls must produce explicit oracle failures; crashes,
timeouts and compilation failures do not count as mutant detection. Commands
and actual run counts are recorded in validation.json.

Original ELF, firmware, emulator, boot, device, UART, ASIC and real pools are
not executed. No production driver/core registration or source-list change
is made. The direct T21 caller, chip/device lifetime, register pair's physical
meaning or safe setting, ASIC acceptance and pool-accepted shares remain
unestablished.

# Bounded two-ELF pathname proof

Names below are recovered roles, not original symbol names. Both references are
stripped ELF32 little-endian ARM. Addresses identify bytes; none is a host entry
point. The evidence plans separate code and known literal/data windows.

## Unsigned guard and three-entry lookup

hwscan `0x10e220` and cgminer `0x11c0c0` contain `CMP r0,#2`. Their next three
instructions use unsigned `HI`: load a relative empty-string pointer, add PC,
and return. Therefore values 3 through UINT32_MAX return before the table load;
a negative signed value explicitly converted to uint32 is in that interval.

For values 0..2, the remaining instructions form a table pointer and load
`table[index]` with a four-byte scaled index, then return. The mapped data is:

| Object | Pointer table | Entries | Invalid-result byte |
|---|---|---|---|
| hwscan | `0x4acf1c` | `0x4821c9`, `0x4821d4`, `0x4821df` | NUL at `0x48e00e` |
| cgminer | `0x5db408` | `0x5ee810`, `0x5ee81b`, `0x5ee826` | NUL at `0x5c2547` |

PC-relative arithmetic is checked independently:

- hwscan `0x10e228 + 8 + word[0x10e244] = 0x48e00e`
- hwscan `0x10e234 + 8 + word[0x10e240] = 0x4acf1c`
- cgminer `0x11c0c8 + 8 + word[0x11c0ec] = 0x5c2547`
- cgminer `0x11c0d4 + 8 + word[0x11c0e8] = 0x5db408`

The cgminer getter's earlier `0x11c080..0x11c0c0` sequence reads obfuscation
state and tests the low bit of x*(x-1). Consecutive integers include an even
factor; the low bit is zero even under modulo-2^32 multiplication. Under the
explicit readable-memory assumption, the branch at `0x11c0a8` reaches the guard.
The candidate omits those irrelevant value computations/global reads; it does
not claim equivalent faults, races or memory-access traces.

The relevant code ends at hwscan `0x10e240` and cgminer `0x11c0e0`; subsequent
words are literals, not instructions. cgminer EHABI coverage begins at
`0x11c070`, which includes a different small preceding getter. EHABI range
starts are therefore not silently substituted for this getter's entry.

## Initialized cgminer strings

hwscan contains plain NUL-terminated strings. cgminer's corresponding bytes are
encoded in its initial file image. Initialization-array slot `0x5db060` (entry
60) contains `0x11c2b8`, the constructor containing these selected loops:

| String target | Target-address add / literal | XOR instruction | Key | Bytes |
|---|---|---|---|---|
| `0x5ee810` | `0x11c4c4` / `0x11c5b4` | `0x11c4cc` | `0x40` | 11 |
| `0x5ee81b` | `0x11c4e8` / `0x11c5b8` | `0x11c520` | `0x99` | 11 |
| `0x5ee826` | `0x11c56c` / `0x11c5bc` | `0x11c574` | `0x5f` | 11 |

The decoded data is respectively `/dev/ttyS3\0`, `/dev/ttyS2\0`,
`/dev/ttyS1\0`, matching hwscan. The second loop includes another opaque parity
sequence; the same even-product identity resolves its ordinary progress path.
The committed evidence contains these loop instructions, their length compares,
literals, initial bytes and the constructor-array pointer. Fixed XOR of those
bytes is data decoding, not an original instruction interpreter.

This does not prove whole-program scheduling or exactly one constructor call
on every possible entry path. The reconstruction's contract expressly assumes
the initialized, unchanged table. It does not introduce a replacement mutable
startup/decryption system.

## AML callback installation and generic caller seam

Selected installation witnesses connect the table getter to the existing
platform callback slot:

- hwscan: `0xffd20 + 8 + word[0x100734] = 0x4c80a0`; getter GOT cell is
  `0xffd4c + 8 + word[0x100748] = 0x4af640`, whose value is `0x10e220`.
  Store `0xffd50` writes that callback into the slot
- cgminer: `0xfc12c + 8 + word[0xfd128] = 0x654b4c`; getter GOT cell is
  `0xfc158 + 8 + word[0xfd13c] = 0x5dec90`, whose value is `0x11c080`.
  Store `0xfc15c` writes that callback into the slot

The tiny generic thunks preserve index r0, load the live callback into r1 and
`BX r1`: hwscan `0x100d9c`, cgminer `0xfef3c`. Their literal arithmetic resolves
the same slots. Intervening code can alter live slots; this is an explicit
selected-method seam, not a universal assertion that AML is always installed.

The bounded callers show the returned pointer retained and passed onwards:

- hwscan `0xe94a0 -> 0x100d9c`, retains r0 in r6, then supplies it in r1 to
  open-dispatch `0x100d3c` at `0xe94bc`
- cgminer `0xc34c8 -> 0xfef3c`, retains r0 in r5, then supplies it in r1 to
  open-dispatch `0xfee4c` at `0xc34e0`

Neither selected sequence replaces an empty returned string with a fallback.
Their opening, descriptor ownership, configuration, cleanup and device effects
remain beyond this getter. The existing unchanged source
`src/backend/work-gen/chain-work-start.c` already exposes this selected path
through its explicit callback, with live method-slot and index inputs. The host
composition test proves its interaction with the new C getter while refusing
open; it does not prove that a production driver was integrated.

## Method limits

The generalized input claim comes from unsigned guard/table arithmetic and the
constant decoded data; host tests corroborate a large deterministic subset.
There is no differential execution of vendor code. The C function returns host
static string addresses, not ARM pointer values, and forbids mutation/freeing.
Unknown model, transport, PSU, UART and driver behavior stays unresolved.

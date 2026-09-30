# hwscan platform lookup and pure selection candidate

This is a small static reconstruction from the **separate hwscan ELF**, SHA-256
`951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`.
It is original analysis-derived C in an **unverified research tier**, not recovered
vendor source, a scanner, a miner or a production adapter. Base:
`work/reconstruction` at `87ff01aebbe58f520be9c9df78b150eb45fe5b68`.

## The missing piece

The existing [hwscan_profile consumer](../../../../integration/hwscan_profile.c)
reads JSON and accepts `platform="aml"` as ID 2. It does not implement the separate
scanner's CLI or platform lookup. Existing cgminer platform modules and tests
against `reference/cgminer.vendor.elf` cannot establish this hwscan behavior.
No existing scanner implementation, native core or runtime code is replaced here.

## Reconstructed behavior

`hwscan_platform_name_135(uint32_t)` corresponds to the leaf called at `0xe69cc`,
entering `0xe8e24`. Its eight A32 instructions occupy `[0xe8e24,0xe8e44)`.
Both paths return with `BX LR`; there are no calls or writes in this leaf.

| Unsigned input ID | Returned string contents |
|---:|---|
| 0 | xil |
| 1 | bb |
| 2 | aml |
| 3 | cv |
| 4 | stm |
| 5 through UINT32_MAX | unk |

The unsigned `HI` condition is essential: values with bit 31 set also select
`unk`, rather than indexing before or beyond the table. Two literal words at
`0xe8e44/0xe8e48` resolve to the five-pointer table at `0x4aced8` and the NUL-
terminated `unk` suffix at `0x47f59f`. Table and string bytes have individual
source offsets and hashes in `evidence/`.

`hwscan_platform_select_135(previous_id, argument)` is a **new normalized pure
research API** for the decision slice `[0xe907c,0xe9140)` inside a larger CLI
routine. It is not a recovered standalone vendor function or structure:

- NULL argument: preserve the supplied previous ID; return argument_present=0
  and label=NULL. The original branch bypasses assignment and its logging block
- Present NUL-terminated string: compare in the observed order `aml`, `bb`, `cv`,
  `stm`, `xil`; assign respectively 2, 1, 3, 4, 0 and return that label
- Any other string, including empty/uppercase/padded/prefix strings: assign 5
  and label `unk`. This records an unknown selection; it does not invent a CLI
  error return or authorize a fallback platform

The called comparator `[0x45f7dc,0x45f804)` loads unsigned bytes, compares until
a mismatch or NUL, subtracts the differing bytes and returns. All ten instructions
are preserved. The candidate reuses standard `strcmp` for its zero/equality
contract, rather than adding a duplicate string implementation. Inputs other
than NULL must be readable NUL-terminated strings; invalid-pointer behavior is
not modeled or tested.

The global pointer slot `0x4afb94` points to `0x4b0a70`, whose file-backed initial
word is 5. That proves the saved initializer only. The helper always takes its
previous ID explicitly; it does not assume the runtime global is still 5.

## Evidence versus inference

- Direct evidence: exact reference digest, raw instructions/literals/table and
  string bytes, direct caller, local branch destinations, unsigned comparison,
  assigned numeric IDs and the file-backed initializer
- Static local control-flow inference: the eight-instruction lookup's two
  return paths and the ten-instruction comparison loop support the reconstructed
  content-level semantics. This is not a whole-image CFG proof
- Authored normalization: C names/signatures, result carrier, NULL label for a
  skipped selection, and replacing absolute vendor string pointers with local
  immutable string storage
- Excluded: argv parsing, option-parser return semantics, global writes, logging,
  default-config/model generation, scanner dispatch, board detection, hardware
  initialization and invalid-pointer/fault behavior

The original selection global store at `0xe9168` and logger call at `0xe9180`
remain evidence context only. No vendor call is made by this candidate. Matching
string contents and numeric IDs does not reproduce vendor addresses, ABI layout,
allocation, timing, startup reachability or complete runtime behavior.

## Tests and reproduction

From this directory:

```sh
make test CC=gcc
make sanitize CC=gcc
```

These compile and run **only the new host C candidate**. Ten static-derived test
groups check known IDs, 5/UINT32_MAX/high-bit boundaries, every ID 5..65535, 10,000
fixed high-value samples, exact case-sensitive selection, absence, embedded NUL,
input preservation and known-name round trips. The ordinary run makes 75,707
checks. Eight Python tests hash/compare the frozen evidence and pin reviewed
instruction words; they do not interpret or execute ARM instructions.

`make sanitize` keeps leak detection enabled. In the current local tracing
executor, LeakSanitizer reported that ptrace is unsupported. The separate local
ASan/UBSan run explicitly used `detect_leaks=0`; it is not a leak-check pass.
Exact local results and limits are recorded in `validation.json`. The workflow
requests GCC and Clang ordinary and leak-enabled sanitizer checks; CI results
must be verified separately on the eventual commit. Clang was unavailable locally.

To regenerate all assembly/receipt files from your authorized read-only hwscan
input using the already hash-pinned lab packages:

```sh
../../../../tools/firmware_lab/.venv/bin/python -B verify_reference.py /path/to/hwscan.elf
```

The full hwscan ELF is not published in this change. `verify_reference.py` reads
it only as bytes, checks its digest and rerenders the bounded plan through the
existing reviewed static tools. It does not execute the target or emulate its
instructions. No vendor differential oracle is run: **all behavioral tests are
static-derived tests of this new C code, not differential-parity evidence**.

This candidate is not linked into production. Firmware/scanner execution,
model-header/Jansson OOM probes, hardware, flashing, pools, protections, R13/R14,
`get_work`, stop behavior and the 32-slot policy remain untouched.

# Public static evidence checker

`verify_evidence.py` verifies the reviewed READ_REGISTER / GET_STATUS wrapper
snapshot without running vendor code. No original executable, firmware process,
instruction interpreter, emulation, device command, fault probe, or network
operation is involved. It does not establish execution parity or hardware
acceptance.

## Running

Use Python 3.9 or newer with the exact packages in `requirements-static.txt`:
Capstone 5.0.6 and pyelftools 0.32. The optional original-ELF mode needs
pyelftools; self-contained mode needs only Capstone and Python's standard library.

From the repository root, with `EVIDENCE` set to this directory:

```sh
python "$EVIDENCE/verify_evidence.py" --root .
python "$EVIDENCE/tests/test_evidence.py" --root .
python -O "$EVIDENCE/verify_evidence.py" --root .
python -O "$EVIDENCE/tests/test_evidence.py" --root .
```

`--root` and `--source-root` are aliases. When installed at
`research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/common-read-register`,
the command also discovers the repository root automatically. A standalone copy
works without a source tree, reporting zero active dependency files checked.
Tests run directly from the repository root discover it too; `--root` makes the
target explicit. Without a repository, the five tests that need actual source
files report skips. This does not prevent the other snapshot and negative tests.

Add either or both original images to verify provenance directly:

```sh
python "$EVIDENCE/verify_evidence.py" --root . \
  --cgminer /path/to/cgminer.vendor.elf --hwscan /path/to/hwscan.vendor.elf
```

The images are read as bytes. Their complete size and SHA-256 must match before
pyelftools reads their ELF structure. Every selected body, pool, string, GOT
word, unwind entry, initializer slot, and bounded ELF metadata slice is then
compared with the public witnesses. The verifier re-renders all assembly from
the validated bytes in both modes. It never creates or launches an executable.
No full ELF is included in this evidence directory.

## What is checked

- Complete wrapper code: cgminer `0xd253c..0xd2684` (82 ARM instructions) and
  hwscan `0xea7e4..0xea8a4` (48 instructions), with separate literal pools
- Complete selected CRC code: cgminer `0xf7f10..0xf8040` (76 instructions),
  including its final `BX lr`, plus its eight-byte pool; hwscan
  `0xfcc18..0xfcd0c` (61 instructions)
- Complete bounded cgminer string initializer: `0xd2c0c..0xd2d94` (98
  instructions), its pool, and its separate alignment word
- Every call, immediate branch, indirect send and return in these bodies;
  every PC-relative immediate literal load and its consuming instruction;
  in-body direct branch destinations stay in code, never in pools
- Seven fixed parity predicates and their live edges/dead intervals, including
  the unreachable duplicate logger and initializer blocks. These use the
  integer identity that consecutive factors have an even product modulo 2^32
- Fixed words establishing the bit-zero broadcast input, optional word read at
  offset four, byte truncation, 32-bit CRC input length, five-byte send,
  current-method selection, index load after send, wrapping index increment,
  logger level/line/stack arguments, and zero or minus-one return
- Exact diagnostic path `/tmp/build/libbitmain/src/chip/chip.c`, module,
  function and GET_STATUS format; the four hwscan plaintext literals and the
  cgminer XOR/NOT keys, NUL-inclusive lengths and encoded bytes
- `.init_array` registration of `0xd2c0c` at slot `0x5dafd4`, including a
  bounded original ELF header, program headers, relevant section headers and
  section-name bytes proving the section type, name, size and slot membership
- Corroborating cgminer EHABI entries and the next entries used to calculate
  their coverage. hwscan has no selected exact unwind start; no such evidence
  is invented

`static-witnesses.json` and the image-specific `.asm` files preserve the
reviewed raw artifacts unchanged. `static-supplement.json` adds the six guard
GOT edges omitted by the original extractor, next EHABI entries and bounded ELF
metadata. `static-pins.json` records independent fixed range hashes, source
identities, all branch/call/return words, exact literals and named instruction
witnesses. Its entire file hash is a constant in `verify_evidence.py`; editing
payload bytes and their adjacent hashes cannot update the trust anchor.

`STATIC_CONTRACT.md` is the retained review narrative. Its reference to
`collect_static_review.py` describes the earlier extraction step. The public
entry point is `verify_evidence.py`; no private extractor is needed to run it.

## Accepted base versus active dependencies

`source-baseline.json` preserves all 18 source receipts from accepted commit
`98ad426482947cf29beed1371a63136f8aac2b0c`, tree
`70d1e1b0e8e3786db2b843503dabf90ad486c6d1`. These identify a fixed reviewed base;
the verifier does not pretend that a local working tree still has that commit
or independently authenticate Git history without its repository.

With `--root`, 17 unchanged dependency files must retain their recorded byte
length, SHA-256 and Git blob hash. The research index
`research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/README.md` remains
in the base provenance receipt but is deliberately excluded from active
full-file pins because integration updates that index. The new wrapper C/header,
host tests, build files, and research prose are outside the unchanged dependency
set and require their own code review and runtime tests.

## Assumptions and limits

The fixed bytes and their reviewed meanings are snapshot assumptions, not
claims that writable storage has these values in every running process. In
particular, static deobfuscation assumes readable admitted guard storage and
normal ABI-conforming callbacks; the displayed diagnostics assume their
initializer ran once and the string storage was not later changed. File GOT
contents are initial image addresses, not proof of the runtime-selected method.
The original logger's filtering/output and the effects inside callbacks remain
outside this wrapper's static contract.

The checker validates byte identity and the published static relationships.
It does not synthesize an ARM machine state, execute instruction paths, compare
an invented vendor oracle, or claim runtime ABI, fault timing, concurrent
behavior, physical acceptance, or a register response. All validation raises
explicit exceptions and remains effective with Python optimization enabled.

The negative suite rejects corrupted instruction bytes, CRC tails, metadata,
branches, literal and GOT edges, string keys/bounds/content, returns, code/data
boundaries, diagnostic values, initializer registration, ELF section names,
source receipts and actual dependency files. It also proves that an intentional
research-index change is accepted while the 17 active dependencies remain pinned.

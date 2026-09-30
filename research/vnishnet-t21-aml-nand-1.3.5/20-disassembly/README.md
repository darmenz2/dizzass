# Bounded disassembly

`entry-arm/slice.asm` is real linear Capstone 5.0.6 decoding of bytes `[0x1012c, 0x1016c)` from the exact reference ELF. `receipt.json` records source SHA-256, file offset 300, byte count 64, mode and slice SHA-256. Raw bytes are visible beside each decoded instruction; no vendor executable was run.

This one entry-point slice is deliberately bounded. It does not establish full function boundaries, complete control flow, literal-vs-code classification, runtime equivalence or a complete recovered source. The `.byte` line is preserved rather than invented as an instruction.

From repository root, after installing the hash-pinned analysis dependencies as documented:

```sh
tools/firmware_lab/.venv/bin/python -B tools/firmware_lab/scripts/disassemble_slice.py reference/cgminer.vendor.elf --start 0x1012c --end 0x1016c --mode arm --out /tmp/dizzass-entry-new
```

Choose a fresh output directory on each run; compare `slice.asm` and `receipt.json` with this directory. Do not execute the input.

## Expanded startup research

The [startup index and bounded slices](startup/README.md) add symbol/EHABI/initialization-array metadata for both cgminer and hwscan, 24 digest-pinned slices, an ELF entry map, and a provenance-linked GPIO/PWM/power/UART safety map. The original 64-byte slice above is retained unchanged. EHABI rows are unwind-coverage records, not proven whole-function boundaries; the expanded result does not claim complete source or runtime parity.

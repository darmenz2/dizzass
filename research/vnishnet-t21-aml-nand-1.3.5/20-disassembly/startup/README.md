# Reproducible ARM metadata and bounded startup disassembly

This additive research artifact strengthens the disassembly tier without modifying the upstream miner, runtime adapters, R13/R14, `get_work`, stop behavior, extracted scripts or the empty reconstructed tier. Base: `work/reconstruction` at `a482b4637c1bb8e2f201ba7d2a870c0fc10f0185`. No original C source, complete function recovery, runtime equivalence or hardware readiness is claimed.

## What is actually present

- cgminer: 1,570 EHABI rows, zero surviving function/mapping symbols, 185 init and one fini pointer
- hwscan: 653 EHABI rows, zero surviving function/mapping symbols, 48 init and one fini pointer
- 24 hash-pinned bounded slices: 6,120 cgminer bytes and 404 hwscan bytes, including explicitly separated startup/GOT/UART literal data
- Exact source identities, PT_LOAD file mappings, range hashes, ISA choices and evidence descriptions in every slice receipt
- [ELF entry map](STARTUP_ENTRY_MAP.md) and [selected stock-boot safety map](STARTUP_SAFETY_MAP.md)

The 2,223 EHABI rows are **unwind range starts, not a count of all functions**. `coverage_end_exclusive` is the next EHABI start; it is not a proven function end. `function_end_exclusive` is deliberately empty for every EHABI row. Adjacent functions can share unwind coverage, leaf routines may have no entry, and the final coverage end remains unknown. Symbol output tables contain headers but no data rows because the images are stripped.

The raw pointer and normalized address are both retained. Thumb pointers would be normalized by clearing bit zero while retaining their mode. All actual entry/array/EHABI pointers in these two inputs encode ARM at their targets; this does not prove all bytes in the ELF are A32 code. Synthetic tests cover Thumb and mixed code/data mapping symbols. No Thumb slice was fabricated to inflate coverage.

Metadata interpretation follows the official [Arm EHABI index-table specification](https://github.com/ARM-software/abi-aa/blob/2025Q4/ehabi32/ehabi32.rst#index-table-entries) and [Arm ELF symbol/mapping rules](https://github.com/ARM-software/abi-aa/blob/2025Q4/aaelf32/aaelf32.rst#symbol-values). The implementation reads PREL31 offsets and descriptor types; it does not execute unwind programs or emulate machine instructions.

## Reproduce from the private authorized extraction

Use the pinned packages and extraction procedure in [the lab README](../../../../tools/firmware_lab/README.md). The full firmware, hwscan ELF, full extraction manifest and credential material are not published here. The selected cgminer reference already exists separately in the repository.

From the repository root, after preparing `tools/firmware_lab/.venv`:

```sh
PY=tools/firmware_lab/.venv/bin/python
SCRIPTS=tools/firmware_lab/scripts
PLANS=research/vnishnet-t21-aml-nand-1.3.5/20-disassembly/startup
# Set these to the existing read-only extracted inputs; never launch either ELF.
CGMINER=/path/to/cgminer.vendor.elf
HWSCAN=/path/to/objects/951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077
$PY -m unittest discover -s tools/firmware_lab/tests -v
$PY "$SCRIPTS/index_arm_elf.py" "$CGMINER" --out /tmp/new-cgminer-index
$PY "$SCRIPTS/index_arm_elf.py" "$HWSCAN" --out /tmp/new-hwscan-index
$PY "$SCRIPTS/disassemble_plan.py" "$CGMINER" --plan "$PLANS/cgminer-plan.json" --out /tmp/new-cgminer-slices
$PY "$SCRIPTS/disassemble_plan.py" "$HWSCAN" --plan "$PLANS/hwscan-plan.json" --out /tmp/new-hwscan-slices
diff -r "$PLANS/cgminer-index" /tmp/new-cgminer-index
diff -r "$PLANS/hwscan-index" /tmp/new-hwscan-index
diff -r "$PLANS/cgminer-slices" /tmp/new-cgminer-slices
diff -r "$PLANS/hwscan-slices" /tmp/new-hwscan-slices
```

Use fresh output paths each time. Output locations must not be symlinks and cannot preexist. Source/range digest mismatch, unsupported ELF format, ambiguous file mappings, truncated/out-of-order EHABI records, or oversized inputs fail closed. The trusted local analysis model is unchanged: same-UID concurrent hostile filesystem mutation is out of scope, and a directory/venv is not a security sandbox.

## Verification and limits

Fresh synthetic tests and independent `readelf` cross-checks are recorded in `validation.json`; deterministic regeneration matches all four output directories byte for byte. Existing public GPIO/PSU/reset evidence ranges and the saved UART listing are cross-checked against the exact reference bytes. These are parser/static-analysis checks only. No vendor executable, startup script, instruction interpreter, model probe, physical bus, flash operation or pool client was run. No full CFG, whole-ELF disassembly, decompilation, all-startup-callee review, board experiment or electrical measurement was performed.

The safety map is a planning input. In particular, GPIO 437=1 is compatible with the existing research's software OFF label, but GPIO direction transitions, later initializers and unreviewed boot stages prevent treating that value as electrical isolation. Suppressing only S70miner leaves earlier GPIO/PWM operations and hwscan launch in place.

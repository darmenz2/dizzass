# VNishNet T21 AML NAND 1.3.5 static reference lab

Purpose: preserve exact firmware evidence and prepare bounded byte-level research for the real cgminer-based dizzass project. This is tooling, not a T21 implementation or a firmware release. It does not reconstruct the original C source and does not claim behavioral parity.

## Verified input

- `vnishnet-t21-aml-nand-v1.3.5.tar.gz`: 24,875,237 bytes, SHA-256 `20fabdd66255889315e61ae2a33ff2e4623566ca430f1cb8c90d9b938dc7b43c`
- Extracted `usr/bin/cgminer`: 6,228,004 bytes, SHA-256 `b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`
- Extracted `usr/bin/hwscan`: 4,883,216 bytes, SHA-256 `951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`
- `cgminer`: ELF32, little-endian ARM, EABI5/hard-float, entry `0x1012c`

The input digest matches the dizzass evidence at main commit `bf8cd0513440f91f8a34c69137d0436e6fc30c8a`. This verifies byte identity with that reference; vendor authenticity and licensing were not assessed. The project's chosen public cgminer base is `b8491c66e7e22f23a9edf095dd1337ee581e88bd`, not a proven exact VNish ancestor.

## Isolation and safety

The lab is a dedicated workspace and Python virtual environment. It is **not a VM or a container security boundary**. A nested namespace sandbox test failed with `Operation not permitted`. The original and derived binaries have read-only permissions and no execute bits; these permissions are reversible by the owner, not cryptographic or kernel-enforced immutability.

Only newly written analysis code and known analysis packages run. No firmware executable, boot script, installer, chroot, emulator, network client from firmware, or ASIC command is run. Never run `runme.sh`, `rcS`, `S11board`, `hwscan`, or the reference `cgminer`. Do not use `ldd` on the references; use `readelf` for static ELF metadata.

The unpacker uses the standard library only and pins the original digest before parsing. It:
- bounds original/member bytes (128 MiB), expanded input per layer (512 MiB), and entry count (100,000)
- imposes Linux CPU/address-space/per-file limits in its command-line entry point; these are not aggregate disk quotas
- rejects traversal, absolute/control-character names, duplicate normalized paths, sparse tar records, malformed strict hexadecimal newc fields, missing/trailing archive data, and oversized/truncated payloads
- verifies U-Boot header/data CRC and gzip integrity, then the reference ELF digest
- writes regular data only under content-derived SHA-256 filenames; links, devices, archive modes and ownership are metadata only
- stores link destinations without following or restoring them; no extracted pathname controls a filesystem write
- rejects preexisting output directories and symlinked object directories/final names

This is not a general untrusted multi-user extraction service. Concurrent hostile same-UID mutation is outside the workspace model. Never make the output directory shared/writable to another actor during analysis. The verifier assumes a bounded trusted manifest produced by this unpacker.

## Reproduce

Validated platform: Linux x86_64, Python 3.12.14. The lock contains the Linux x86_64 Capstone wheel and the platform-independent pyelftools wheel. On another platform create and independently review a new lock rather than dropping hash verification.

From this directory:

```sh
python3 -m venv .venv
# In the downloadable bundle the pinned wheels are already in tools/wheels.
# For a fresh repository copy, download the same hash-pinned official packages:
.venv/bin/python -m pip download --only-binary=:all: --require-hashes -r requirements.lock -d tools/wheels
.venv/bin/python -m pip install --no-index --find-links tools/wheels --require-hashes -r requirements.lock
.venv/bin/python -m unittest discover -s tests -v
mkdir -p derived
python3 scripts/unpack_firmware.py /path/to/vnishnet-t21-aml-nand-v1.3.5.tar.gz derived/run-a
python3 scripts/verify_output.py derived/run-a
python3 scripts/unpack_firmware.py /path/to/vnishnet-t21-aml-nand-v1.3.5.tar.gz derived/run-b
cmp derived/run-a/manifest.json derived/run-b/manifest.json
```

The firmware archive is intentionally not included. Keep its original bytes separate and read-only. Every new extraction needs a new output directory. `manifest.json` gives the provenance, path, original mode/type, byte offsets, size, and hashes for payload-bearing records. Locate `usr/bin/hwscan` or a startup script in `newc`, then inspect its corresponding `object` as data. All file-backed ramdisk regular bytes are preserved; hardlink groups retain original inode/nlink metadata rather than reconstructed filesystem links.

Static slice example:

```sh
.venv/bin/python scripts/disassemble_slice.py derived/run-a/cgminer.vendor.elf \
  --start 0x1012c --end 0x1016c --mode arm --out derived/entry-slice
readelf -hW derived/run-a/cgminer.vendor.elf
```

Disassembly is a linear interpretation with an explicitly chosen ARM/Thumb mode. Each receipt hashes the same bounded ELF snapshot used for slicing and records the file/virtual mapping. It does not prove function boundaries, distinguish literals from code automatically, establish a complete control-flow graph, or demonstrate runtime equivalence. No decompiler has been installed or claimed.

## Results and acceptance limits

- 34 parser/disassembly tests passed after review hardening; these are software safety tests, not hardware acceptance
- 62 outer tar entries; 466 newc entries: 210 regular, 198 symlinks, 58 directories
- 218 unique content-addressed objects verified; no unexpected object or executable bit
- Repeated extractions produce identical manifest SHA-256: `7f41a311008b1f2e680d8707a6c8132cdb19fdb008179559075e1be3ca61959d`
- ARM and Thumb decoding validated on synthetic `bx lr` bytes; static extraction/disassembly of the real reference succeeded

See `CHECKPOINT_RU.md` for startup findings and the next bounded research target. R12/R13/get_work/stop code, current shared branches, production settings, pool/devfee behavior, and hardware are outside this tooling change. GitHub publication must remain an isolated tooling PR; no R-stack promotion is implied.

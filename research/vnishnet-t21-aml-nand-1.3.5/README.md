# VNishNet T21 AML NAND 1.3.5 research tiers

This is a static reference workspace for the cgminer-first dizzass project. It is not a replacement miner, a flashable image, or evidence of runtime parity.

1. **10-extracted** contains an explicitly reviewed public subset of exact extracted bytes. The complete private extraction has 62 outer archive entries and 466 ramdisk entries, but it is deliberately not published in full.
2. **20-disassembly** contains actual linear ARM decoding and a source/range/digest receipt. A slice is not a complete disassembly or proof of function boundaries.
3. **30-reconstructed-unverified** is a reserved, explicitly empty implementation tier. No unavailable candidate code or historical test result is relabeled as recovered work.

**00-provenance** is common evidence: pinned archive identity, selected-file identities, fresh validation results and test logs. Credentials, private keys, their contents and their individual digests are excluded. The full extraction manifest also remains private.

The existing [reference ELF](../../reference/cgminer.vendor.elf) is the exact extracted `usr/bin/cgminer`; its Git blob identity and SHA-256 are recorded in [reference-subset.json](00-provenance/reference-subset.json). `hwscan` was extracted and hashed locally but is not included in this public subset. No fake binary placeholder is supplied.

## Fresh checks

The saved lab tooling was recovered and all 16 original bundle entries matched their saved sizes and SHA-256 hashes. Its 34 parser/disassembly tests passed with no skips. Two fresh extractions each verified 218 content-addressed objects and produced the same manifest SHA-256 `7f41a311008b1f2e680d8707a6c8132cdb19fdb008179559075e1be3ca61959d`. These are software/static-data checks only.

The complete original firmware, object store and full extraction manifest stay private. The archive must never be committed wholesale. Run the bounded tools from [tools/firmware_lab](../../tools/firmware_lab/README.md) only; never execute, source, emulate, chroot into or boot extracted vendor content. The analysis directory and Python venv are not a VM security boundary.

## Observed boot ordering

The exact `rcS` data orders startup scripts by name. `S11board` writes power GPIO and fan PWM settings before `S12hwscan` runs. `S12hwscan` reads `platform` from `etc/fw-info.json`; a failed hwscan prints `FAIL` but does not arrange a global boot stop. `S70miner` later starts cgminer using `/config/cgminer.conf`. This static observation is why ordinary stock boot cannot be described as a passive control-board check; electrical behavior and hardware success are untested.

The baseline for this change is `work/reconstruction` at `f646f18f304e295134ffd37e007a62bfa1dbfa30`. No existing source, tests, interfaces, shared branch, R12/R13 work, pool/devfee settings, hardware controls or 32-slot policy are modified. Coordination: [issue #2](https://github.com/darmenz2/dizzass/issues/2).

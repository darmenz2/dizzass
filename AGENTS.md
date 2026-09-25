# dizzass working rules

## Source and migration state

This repository is a private working copy of the public `ckolivas/cgminer` history, pinned at `b8491c66e7e22f23a9edf095dd1337ee581e88bd`. The pinned base is also kept on `upstream/ckolivas`. Do not rewrite that branch. Public Bitmain/S9 lineage is useful evidence, not proof of VNish 1.3.5's exact starting commit.

Stage 14 is considered imported only when `migration/STAGE14_IMPORT.json` exists and the files it describes are present. Until then this repository contains the public base and migration tooling, not the complete recovered modules. Never claim a transfer or test run solely because a script for it exists.

The authorized archive is `VNish135_modular_cgminer_stage14.zip`, SHA-256 `0c61e8acea79e1e6bad4b1058d50cbb60cf985fcf98ad3f9eb026d4b25178f50`, 790 files after removing the outer directory. The importer validates the full archive, internal inventory and original reference ELF. Do not silently accept another build or drop evidence files.

## Implementation

Preserve `src/`, `libbitmain/`, `include/xminer/recovery/`, `reconstruction/`, `tests/`, `tools/` and evidence paths. Keep the public core, its licenses, author attribution and history. Do not replace the core with a simulator or combine all reconstructed code into one C file.

Separate original behavior verified against ARM instructions from new adapters and hypotheses. Unknown code must stay explicitly unsupported, never succeed via an empty stub. Keep original reference bytes unchanged. Treat original firmware binaries as data; do not launch them as host processes.

After Stage 14 import the remaining work includes full consumer and ownership/freshness integration, unexplained queue-record bytes, register response checks, confirmed T21 model/driver dispatch, chain initialization, PSU/sensors/cooling/protections and autotuning. Inspect current files before assuming these are still missing.

## Verification and safety

Build recovered modules with `make -f Makefile.recovery all arm`. Stage-specific tests and differential tests require their real fixtures/reference files. Report which tests were actually run, their exit codes and limitations. Host, PTY and interpreter tests are not physical T21 acceptance.

The original `reconstruction/overlay-files.json` inventories the standalone overlay only. In this combined tree, the old whole-directory inventory checker also sees upstream and migration files; do not mistake that scope mismatch for damaged imported sources or rewrite checksums just to make a test green. Adapt inventory scope explicitly when adding combined-tree CI, preserving the original import proof.

No command in this task authorizes flashing NAND, deploying a replacement cgminer, changing production servers/pools/devfee, altering operating voltages/frequencies/cooling protections or contacting ASICs. No secrets, private signing keys or account credentials should be committed. Do not change repository visibility or force-push existing work.

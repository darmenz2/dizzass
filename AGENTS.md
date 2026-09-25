# dizzass working rules

## Architecture: cgminer first

The active goal is to extend the real public cgminer, NOT recreate the entire VNish binary as a parallel miner. The user's latest direction takes priority over the earlier address-by-address reconstruction plan.

Reuse native cgminer work/pool types, allocation and cleanup, Stratum, job lifecycle, share submission, SHA256, target arithmetic, API and logging wherever applicable. Inspect the actual upstream implementation before adding code. A native function with a similar name is a candidate for reuse, not proof of identical VNish behavior. Record meaningful differences and make small, separately tested patches when needed.

Do not add another miner main, a second production work/pool representation, duplicate SHA/target/network stacks or successful hardware stubs. Do not pass the normalized 632-byte recovery image or 68/72-byte recovery records as native upstream structs. Use named fields and a typed adapter at the driver boundary.

Reconstruct only missing VNish behavior and hardware-specific parts: confirmed model dispatch, controller transport, hashboard protocol, work/nonce framing, PLL, PSU/sensors/fans/protections and autotune. Do not assume chip1398 is the T21 driver until dispatch is verified. Preserve observed source paths when adding real modules; do not rename the upstream tree to imitate unavailable vendor sources.

## Repository and evidence

The public base is ckolivas/cgminer at b8491c66e7e22f23a9edf095dd1337ee581e88bd, also kept on upstream/ckolivas. Keep its history, attribution and licenses. Do not rewrite that branch. This is a chosen base, not a proven exact VNish ancestor.

Stage 14 has an import receipt in migration/STAGE14_IMPORT.json. Its original archive, evidence, reference ELF and historical tests are retained. Existing reconstruction/*, recovered src/* and libbitmain/* modules remain available to Makefile.recovery as comparison and porting material, not a second core linked wholesale into cgminer.

Makefile.am is restored to the pinned upstream blob. Do not re-add the blanket reconstruction/cgminer-overlay.am include. That file and tools/assemble_on_cgminer.py preserve the historical standalone overlay workflow; they are not the current native-runtime integration path. Add production driver sources explicitly only after implementing and testing the real native adapter.

The original reconstruction/overlay-files.json describes the standalone import. Do not rewrite its checksums to hide changes or treat upstream/integration files as archive corruption. Keep the import proof and scope checks explicitly.

## Build and tests

The native baseline uses the normal upstream Autotools build. The cgminer-native workflow builds the real core with the existing Icarus driver only to satisfy the upstream build configuration; it does not claim T21 support and does not access USB hardware or pools. Only the new host binary's --version is executed.

After configuring, list evaluated production sources with:
    make -s -f Makefile -f integration/native-check.mk dizzass-core-sources
Use integration/check_native_core.py to reject accidental legacy-core linkage. Its baseline policy must be revised explicitly when a reviewed native driver is added.

Keep historical checks separate: make -f Makefile.recovery all arm and stage-specific tests. Do not report these as full runtime or hardware acceptance. Read integration/CGMINER_FIRST_RU.md for the reuse map and next steps.

## Safety and reporting

Treat reference firmware executables as data; never launch them as host processes. No flashing NAND, changing production services/pools/devfee, sending hardware commands or altering voltages/frequencies/protections is authorized by a repository edit. Commit no secrets, private signing keys or credentials. Do not change visibility or force-push.

Unknown behavior stays unsupported. Distinguish native reuse, verified reconstructed logic, new adapter behavior and hypotheses. Report only tests actually run and their limits. A compiled baseline with a legacy driver is not a functioning T21 miner.

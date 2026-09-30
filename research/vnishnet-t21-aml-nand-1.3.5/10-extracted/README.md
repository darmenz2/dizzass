# Exact extracted public subset

`rootfs/` contains five exact files: firmware build metadata and four startup scripts relevant to boot order. They are data, stored without executable bits. Their source paths, sizes and SHA-256 hashes are in `../00-provenance/reference-subset.json`.

Do not run or source any script. In particular `S11board` changes GPIO/PWM state and is not a diagnostic harness.

The existing [reference ELF](../../../reference/cgminer.vendor.elf) is also part of the extracted evidence. The ELF already exists in the baseline and is not duplicated here. The separately extracted hwscan remains private. This directory is a selected subset, not a bootable or complete root filesystem.

Git stores these files as mode `100644` and does not preserve local read-only permissions. The private lab copies are mode `0400`; a Git checkout is normally owner-writable but not executable.

# Provenance and licenses

The new C helper implementations and local Python tools are provided under
GPL-3.0-only; see `reconstruction/COPYING.generated`. This does not relabel the
licenses of the supplied vendor binary or the user's prior analysis artifacts.

The supplied vendor ELF and disassembly derived from it are reference evidence.
They are not claimed to be new original source or relicensed upstream cgminer.
This reconstruction was made with direct binary inspection, not a clean-room
separation process.

The public `ckolivas/cgminer` source remains governed by its existing LICENSE,
COPYING, AUTHORS and individual-file notices. The assembly script preserves
those files; it neither removes attribution nor makes the selected upstream
commit a proven ancestor of the vendor fork.

New file paths used for support/tests/integration are explicitly distinguished
from original source paths observed in the binary.

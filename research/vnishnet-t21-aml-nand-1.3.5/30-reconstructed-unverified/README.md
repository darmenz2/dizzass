# Reconstructed candidates, explicitly unverified

This tier now contains one small [hwscan platform lookup/selection candidate](hwscan-platform/README.md). It reconstructs an eight-instruction pure name-lookup leaf and normalizes a bounded name-selection decision slice from the separately hashed hwscan ELF. Its C behavior is tested against static-derived vectors; no vendor differential execution or runtime parity is claimed. It is not linked into production and does not implement the scanner, driver, model loader or hardware initialization.

The earlier unavailable model candidate remains unrecovered. No lost implementation, historical test report or existing cgminer-only evidence is relabeled as recovered hwscan work. The original full source remains unavailable.

The extracted bytes and disassembly remain separate evidence tiers. Do not execute the vendor inputs, boot scripts or historical instruction-interpreter/model probes to validate this candidate. See its README for exact inputs/outputs, authored API normalization, source identities, tests and limitations.

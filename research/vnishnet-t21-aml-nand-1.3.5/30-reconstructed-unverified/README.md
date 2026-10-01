# Reconstructed candidates, explicitly unverified

This tier now contains one small [hwscan platform lookup/selection candidate](hwscan-platform/README.md). It reconstructs an eight-instruction pure name-lookup leaf and normalizes a bounded name-selection decision slice from the separately hashed hwscan ELF. Its C behavior is tested against static-derived vectors; no vendor differential execution or runtime parity is claimed. It is not linked into production and does not implement the scanner, driver, model loader or hardware initialization.

The earlier unavailable model candidate remains unrecovered. No lost implementation, historical test report or existing cgminer-only evidence is relabeled as recovered hwscan work. The original full source remains unavailable.

The extracted bytes and disassembly remain separate evidence tiers. Do not execute the vendor inputs, boot scripts or historical instruction-interpreter/model probes to validate this candidate. See its README for exact inputs/outputs, authored API normalization, source identities, tests and limitations.

## AML UART pathname result

[AML UART pathname reconstruction](aml-uart-path/README.md) adds the missing pure getter to the existing original-path AML platform module. It preserves the three routes and non-NULL empty-string result for unsigned out-of-range indices, with cross-ELF static evidence and host tests using the existing caller's explicit path seam. It performs no device I/O or production registration.

## Transport/chip initialization

The [bounded initializer](transport-init/README.md) adds the missing original selection and partial-write order, with explicit unresolved constructor callbacks and host/static tests. It does not register a production driver.

## BM1368 method-table construction

The [BM1368 constructor](bm1368-init/README.md) fills the 54 fixed method identities selected by chip 4 while preserving two caller-owned words. Its actual C body composes with the existing bounded initializer in host tests. It does not make those identities callable or establish hardware readiness.

## Common READ_REGISTER command method

The [common wrapper](common-read-register/README.md) reuses the existing encoder and actual transport seam, preserving bit/byte normalization, one-send status handling and failure diagnostics after callback mutation. Host composition calls the real reconstructed method through explicit typed bindings, with all lower writes recorded and refused. No cache or ACK behavior is inferred.

## Original BM1368 reset method

The [original reset projection](bm1368-reset/README.md) implements the conditional
cache/write/error graph and all five delay requests through explicit host
callbacks, reusing the existing cache and command/transport stack in its tests.
It preserves the original final zero even after errors; this is not a hardware
readiness signal. The existing fail-fast adapter remains separate and unchanged.

## BM1368 ticket-mask configuration

The [TICKET_MASK method](bm1368-ticket-mask/README.md) reuses the existing bit
permutation and actual register/cache/transport stack. Static owner and thread
evidence places the method on cgminer's startup and resume paths, including a
later model-mask application after temporary all-ones masks. Focused host tests
check exact broadcast arguments, fanout and post-writer error-index behavior;
the whole coordinator and production binding remain separate work.

## Original BM1368 SWEEP_CLOCK_CTRL method

[bm1368-sweep-clock](bm1368-sweep-clock/README.md) reconstructs the original
e32c0/f30d4 setter with its ignored second argument, distinct two-bit word,
actual register-write composition and late-index failure diagnostic. The
static caller extension proves entry flag and read lifetimes, and the focused
host sequence demonstrates later pulse-width overwrite. This does not restore
the full startup coordinator, native ABI or physical hardware behavior.

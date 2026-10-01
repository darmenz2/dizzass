# L-05: hwscan normal-return process status

Static-only continuation of [L-04](../hwscan-dispatch/README.md), based on
`work/reconstruction` commit `2857518613e6e0b7b13f69e8bc5e367df386da42`.
The digest-pinned input is the separate, private 4,883,216-byte `hwscan` ELF:
SHA-256 `951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`.
No target executable, instruction interpreter, boot script or hardware ran.

## Result

**On the traced normal-return path, the outer main discards the C worker's
return register and supplies its own zero status to process termination.**
This closes L-04's previously unresolved normal-return status boundary. It does
not establish that every invocation returns, that every exit is zero, or that
cleanup succeeds.

The decisive instructions are `0x25664: MOV r6,#0`, callback call at `0x256d0`,
`0x256d4: LDR r0,[pc,#0x280]` overwriting the callback result, and
`0x2571c: MOV r0,r6` in the ordinary epilogue. The libc startup bridge invokes
this outer main at `0x452348` and immediately passes its returned `r0` into
`0x1589c`. That routine saves the status across three cleanup calls, restores it,
and reaches `SVC #0` with ARM syscall number 248 (`exit_group`), with a syscall-1
fallback. See [the complete bounded chain and assumptions](STATUS_CHAIN.md).

Therefore a C-worker early `-1` can still lead to process status zero when the
wrapper and runtime take this normal-return route. L-04 already showed some
later worker failures joining a zero-return cleanup path. Neither kind of worker
failure is a reliable nonzero process-status signal on the closed route.

The unchanged extracted [S12hwscan](../../10-extracted/rootfs/etc/init.d/S12hwscan)
prints `OK` whenever the invoked `hwscan` command has zero shell status. It can
therefore print `OK` without establishing scan/model/hardware success. Moreover,
its `FAIL` branch ends with `echo "FAIL"`, with no explicit propagation of the
scanner's status: under ordinary shell semantics, if that echo succeeds,
`S12hwscan start` itself also returns zero. This second observation comes from
static shell-source reading; neither the script nor its shell was executed.

## Deliverable and limits

- 16 digest-pinned code/data windows, 3,152 source bytes and 32 assembly/receipt
  files; 29 direct-edge witnesses, 25 fixed-word witnesses, three PC-relative
  targets, one main-pointer cell and its GOT-offset calculation
- A data-only verifier checks every listed witness, byte/receipt identity and
  the existing S12hwscan source digest; optional private-reference regeneration
  compares every assembly/receipt file against the original source bytes
- 16 data-verifier tests, including 15 deliberately inconsistent metadata/hash
  controls; these test the checker, not target behavior
- The existing 49 lab tests and prior dispatch evidence remain separate and
  unchanged. Validation receipts distinguish local source regeneration from
  frozen-data-only CI capability

The names “outer main,” “Rust wrapper,” “libc startup” and “exit” are research
roles inferred from this binary's code and existing startup evidence, not
recovered symbols or exact original source declarations. Register interpretation
uses AAPCS32: integer results use r0 and r6 is callee-saved. Calls are assumed to
return through their observed ABI normally, without asynchronous termination,
corruption, unwind or a nonlocal exit. Unresolved cleanup and error paths are
not converted into success.

No runtime implementation is added. A function that merely returned zero would
not reconstruct argument conversion, Rust runtime handling, C scanner work or
cleanup. It would be a misleading success stub. This artifact belongs in the
existing disassembly tier; the extracted tier remains unchanged and the
reconstructed-unverified tier receives no fabricated scanner implementation.
Production cgminer, R13/R14/R15/R16 branches, model/OOM work and hardware settings
are outside this change.

## Reproduce without running firmware

From the repository root:

```sh
python3 -B research/vnishnet-t21-aml-nand-1.3.5/20-disassembly/hwscan-exit-status/verify_evidence.py
python3 -B -m unittest discover -s research/vnishnet-t21-aml-nand-1.3.5/20-disassembly/hwscan-exit-status/tests -v
# Optional, using the existing hash-pinned static-analysis environment:
python3 -B research/vnishnet-t21-aml-nand-1.3.5/20-disassembly/hwscan-exit-status/verify_evidence.py --reference /path/to/private/hwscan.elf
```

These commands parse data and disassemble bounded byte windows. They do not
load, invoke or emulate the target, test model logic, access devices or establish
vendor-runtime equivalence. Hashes are consistency/provenance records, not a
security signature against coordinated edits to all evidence and its checker.

# hwscan dispatch and first AML I/O boundary

This checkpoint closes a safety-relevant gap after the [pure platform lookup and
selector](../../30-reconstructed-unverified/hwscan-platform/README.md). It is a
bounded static map of the separate hwscan ELF, not a scanner implementation or
an executed trace. Base: `work/reconstruction` at
`4e12f7ed852c4e524664a90cc01cd57d71f9beb5`.

Source SHA-256:
`951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`.

## What changes the test plan

1. **CLI inspection already has side effects.** The C worker initializes logging
   with `/etc/zlog/hwscan.conf`. If that succeeds, it attempts
   `mkdir("/var/run/hwscan/", 0777)` before calling the CLI parser. The directory
   call's result is not checked here. `--help` or an invalid platform argument is
   therefore not a demonstrated passive way to inspect the original binary
2. **AML selection immediately reaches GPIO sysfs.** ID2 selects callback
   `0x10dce8`. Its first GPIO query reaches the explicit `access` syscall for
   `/sys/class/gpio/gpio439`, then can open unexport/export/direction files for
   writing. The two groups are GPIO439–441 as inputs and454–456 as outputs
3. **Platform initialization precedes discovery.** The callback order is AML
   GPIO initialization, I2C initialization, then PSU initialization, conditional
   on each preceding callback returning zero. Later preparation attempts PSU
   OFF, an unresolved intermediate callback, then PSU ON before connected-chain
   checks. None of these labels proves actual rail state or successful writes
4. **Worker success codes are not readiness.** Early failures return -1 from
   this C worker. Several later failures log an error, run shared cleanup and
   return0 if the callees return normally. Complete process-exit propagation
   through the wrapper/runtime is not established here

No new C implementation is added: the next boundary contains hardware-facing
callbacks and unresolved ownership/error contracts. Turning these into a
nominally successful scanner would invent behavior. The previous pure candidate
remains separate and unconnected to production.

## Selected call graph, with evidence scope

`callgraph.json` pins42 direct A32 edges and components for four indirect
transfers. The `evidence/` directory contains42 source-hashed windows totaling
7,540 bytes, separated code/data windows where identified, plus32 reviewed
path/diagnostic strings. This is a selected graph, not a whole-program CFG. Later indirect targets describe assigned callback values; unreviewed intervening callees could alter runtime slots.

| Stage | Static witness | Effect / limitation |
|---|---|---|
| Main-candidate callback | `0x256c0/0x256c8` resolve `0x25958` to `0x22424`; `0x256d0 -> 0x1c734`; `0x1c738 BLX r0` | The trampoline calls that callback. Complete libc startup and all runtime paths are not re-proved |
| Argument wrapper -> C worker | Direct transfers at `0x225c4` and `0x22630` to `0xe6524` | Wrapper contains allocation/conversion/cleanup dependencies; it is not reconstructed |
| Logger level/config | `0xe653c -> 0xfecbc`; `0xe6548 -> 0xff0a8 -> 0x3ac628` | Level setter writes memory. Configuration dependency is not proved I/O-free; its full effects remain unresolved |
| Directory attempt | `0xe6560 -> 0x45a36c`; `r7=39`, `SVC0` at `0x45a374` | First explicit kernel operation closed in the inspected worker prefix, after successful log initialization; path/mode as above |
| CLI | `0xe656c -> 0xe8e4c` | Nonnegative return continues. The parser can take help/model-generation/exit paths; the pure selector alone does not describe these effects |
| Platform initialization | `0xe659c -> 0xff5f0`, arguments `r0=selected ID,r1=2,r2=0,r3=1,stack[0]=0` | ID5 is rejected before callback setup with `Unknown control board`. IDs0..4 use a jump table; ID2 reaches AML. Other out-of-range IDs are not generalized from ID5 |
| AML callbacks | Case `0xffc5c`; indirect calls `0x1003b0`, `0x1003c8`, `0x100444` | Targets `0x10dce8`, `0x10cfe0`, `0x10e2ec`; [detailed GPIO/I/O proof](AML_IO_MAP.md) |
| Context/preparation | `0xe6618 -> 0xe7218`; `0xe6628 -> 0xe6160` | Allocation-associated context creation then chain/PSU/interface dependencies, not pure logic |
| Presence and further probing | `0xe6690 -> 0xe640c`; `0xe67cc -> 0xe7000` | Connected-chain checks occur after preparation. Reading presence is not the beginning of this program's hardware interaction |
| Model/data dependencies | `0xe67e0 -> 0xe7118`, `0xe68e0 -> 0xe73f0`, then the branches below | Underlying record identity, model algorithms, ownership and hardware protocols are not reconstructed |

The official [Linux ARM syscall table, v6.12](https://raw.githubusercontent.com/torvalds/linux/v6.12/arch/arm/tools/syscall.tbl)
corroborates syscall39=`mkdir`,33=`access`,5=`open`. Numbers and instructions are
firmware byte evidence; syscall names rely on that ABI attribution. Kernel
return values, filesystem state and electrical effects were never observed.

## Error and model-selection boundaries

- `0xe6570/0xe6574` rejects negative CLI returns. ID5 at `0xff5fc` reports
  `Unknown control board`; its caller reports `Failed to platform initialization`
- The platform callback initializer sets its internal initialized flag before
  invoking AML. A nonzero callback result returns-1; rollback of earlier callback
  assignments or GPIO operations is not established
- After platform success, `0xe6160` calls chain setup through
  `0xe7a9c -> 0xea69c`, then PSU preparation at `0x101e5c`. These must be treated
  as effectful/unresolved dependencies. Success proceeds to the OFF request
  `0xe620c -> 0xe7a98`, then `0xe624c -> 0x100b68`, then ON request
  `0xe6250 -> 0xe7a94`, then interface setup `0xe6294 -> 0xe6e88`.
  Failures have distinct messages for chain data, PSU initialization, OFF, ON
  and I2C interface. The intermediate callback is not assumed to be a delay or
  an electrical reset
- `0xe640c` checks recorded chain-presence results. A failure routes to
  `Not enough connected chains`; later missing chain/PSU records route to
  `Failed to get chain info` or `Failed to get psu info`
- In the non-null identifier branch at `0xe69c4`, the worker obtains the platform
  name and calls `0x23fc8` with the identifier pointer, platform string, two
  fields from the PSU-info record and stack value600. Nonzero result enters
  the diagnostic `Failed to detect model: %s`. Zero result is followed by
  `0x22e24`; its zero result permits the later data/packing path. These callee
  contracts and record-field meanings are unresolved; the identifier is not
  silently relabeled as a user-supplied CLI model
- The no-identifier branch calls `0xe6348` at `0xe6abc`. Nonzero result logs
  `Failed to detect model`. Zero result rejoins existing worker decisions.
  This establishes branch outcomes, not model detection correctness
- Separately, CLI model-generation logic at `0xe9224..0xe9268` refuses current
  platform ID5 with `Need specify platform to detect with model`. This is not
  proof that another named platform has a working backend. Earlier model/config
  callees and exit paths remain outside the pure candidate

The direct early failure return is `0xe660c: MVN r0,#0`. Later preparation,
connected-chain, chain-info, PSU-info and model failures can join cleanup at
`0xe66d0`; that path calls cleanup dependencies and ends with
`0xe67a8: MOV r0,#0`. This observation is deliberately limited to the C worker.
It does not establish the ultimate ELF process exit code, S12hwscan's printed
status, successful cleanup, power-off acknowledgement or board safety.

## What is proven about GPIO, and what is not

See [AML_IO_MAP.md](AML_IO_MAP.md) for the address-by-address witness. The evidence
closes the syscall path for a GPIO-directory existence query and for opening
sysfs streams with write intent. It identifies export/unexport/direction
formatting and close calls, whose results are not all checked by the local
helper. It **does not close the complete stdio buffer/flush path to a successful
write/writev syscall** and cannot prove a physical pin change. Reset output
levels, transients, pinmux, voltage, fan polarity and board compatibility remain
unmeasured. Earlier stock S11board operations remain relevant too.

## Next bounded target and test prerequisites

The next useful static target is chain/transport constructor `0xea69c`, invoked
before PSU preparation through `0xe7a9c`. Determine its caller-owned structures,
selected UART pathname callback, open/termios/ioctl/write operations and cleanup
contract. This is a concrete missing dependency for a controlboard-only plan;
no speculative complete scanner or synthetic hardware-success stub is proposed.

Before any separately authorized physical experiment, the owner needs a reviewed
boot arrangement excluding stock S11board/hwscan/cgminer; verified board/kernel
and pin ownership; independent power containment/measurement; and a plan that
separately contains GPIO, I2C, UART and PSU writes. A failed scan, unknown model,
missing hashboards, logging success or process exit status does not establish
those conditions. No boot setting, protection or hardware state was changed.

## Reproduce and validate without running firmware

From this directory:

```sh
python3 -B verify_evidence.py
# Optional exact source check with the existing pinned static-analysis venv:
../../../../tools/firmware_lab/.venv/bin/python -B verify_evidence.py --reference /path/to/private/hwscan.elf
```

The default checker uses committed text only: hashes, raw instruction words,
PC-relative arithmetic, direct branch targets, GOT values and strings. The
optional check reads the ELF as bounded bytes and regenerates all84 assembly/
receipt files through the existing static renderer. It does not load the target,
execute vendor or reconstructed code, emulate instructions or test a model.

`validation.json` records checks actually run. These are evidence consistency
checks, not behavioral/differential tests or runtime parity. The existing49 lab
checks remain unchanged; the lab workflow adds this data-only verifier. Full
firmware, private extraction manifest and credentials remain excluded. R13/R14,
`get_work`, stop behavior, the previous pure C candidate and production code are
unchanged.

# hwscan AML dispatch and first GPIO I/O

## Conclusion / reconstruction boundary

For platform ID `2` (the previously verified `aml` selector), the platform dispatcher at `0x000ff5f0` selects an AML initialization callback at `0x0010dce8`. This callback immediately enters the GPIO sysfs dependency chain. The earliest **explicitly decoded syscall in that local chain** is `access("/sys/class/gpio/gpio439", 0)` at `0x00463708`. Its result selects whether to unexport GPIO439 before exporting it and setting its direction. Actual AML initialization therefore crosses a hardware-facing boundary; it must not be presented as a side-effect-free helper or executed in this lab.

This finding does not claim to identify the program's first I/O: the accompanying worker-entry map identifies logging and directory setup before CLI/platform dispatch. It also does not prove that the formatting/library dependencies preceding this local syscall have no other effects.

## Source and method

- ELF object, treated only as data: the separate private `hwscan` ELF, not included in this publication
- Recomputed SHA-256: `951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`
- ELF32 little-endian ARM, stripped; there are no function symbols or mapping symbols. Names below are descriptive aliases, not recovered source symbol names.
- Used the existing `Snapshot` ELF parser and Capstone to read bytes, decode bounded A32 windows, and arithmetically resolve local PC-relative literal/GOT references. No firmware execution, sourcing, emulation, ARM interpreter, hardware access, flash access, or model/OOM probe was performed.
- Existing EHABI entry527 covers `0x000e5a88..0x001f72c8`; entry621 covers `0x00451d5c..0x0046ca34`. Both are merged `cantunwind` ranges, not function boundaries. Local mode evidence is aligned direct A32 calls, even callback addresses, coherent A32 instructions and literal references. Window extents below are selected evidence intervals, sometimes including literal pools, not independently proved complete functions.
- Linux ARM syscall names for numbers5 (`open`) and33 (`access`) are corroborated by the [upstream ARM syscall table](https://raw.githubusercontent.com/torvalds/linux/v6.12/arch/arm/tools/syscall.tbl). Firmware syscall numbers/instructions are direct byte evidence; names use that ABI attribution.

## Dispatch witness and callback order

1. `0x000ff788` compares platform ID against4. `0x000ff794..0x000ff79c` builds the relative jump-table base `0x000ff7a0`, loads its selected offset, and adds it to PC. Word `0x000ff7a8` (ID2) is `0x000004bc`, giving AML case `0x000ffc5c`.
2. `0x000ffcac` loads `GOT[0x004afdf0] = 0x0010dce8` into `r1`; `0x000ffcb0` stores it to callback slot `0x004c807c`. `r1` remains that callback through the case's later callback assignments and branch `0x000ffec4 -> 0x0010039c`.
3. `0x001003b0: blx r1` invokes AML initialization. The common dispatcher has set byte flag `0x004c8074` to1 at `0x001003ac` before calling. Nonzero result at `0x001003b8` returns `-1` via `0x000ff678`; no rollback is established in this window.
4. On zero result, `0x001003c4` loads callback slot `0x004c80dc`, then `0x001003c8: blx r0`. AML case assigned this slot to `0x0010cfe0`, the I2C-init alias. Nonzero result logs the failure and returns `-1`.
5. On I2C success, `0x00100438` logs the PSU-initialization message, then `0x00100440` loads slot `0x004c80c8` and `0x00100444: blx r0`. AML case assigned it `0x0010e2ec`, the PSU-init alias. Nonzero result logs and returns `-1`; otherwise `0x00100488` sets return value0.

The later indirect targets are the values assigned by the AML case; whole-program proof that intervening callees cannot replace the slots is not established.

The AML case installs fan/PWM callbacks, including slot `0x004c80b8 -> 0x0010cb6c`, but this common initialization window does not call that slot. It also installs a UART pathname getter at slot `0x004c80a0 -> 0x0010e220`. Installing pointers alone is not a proof that any installed callback is safe.

## AML initialization order and first explicit syscall

### Input GPIO group

`0x0010dcf4..0x0010dcfc` resolve table `0x00482188`, three little-endian words `[439, 440, 441]`. Counter setup and comparisons at `0x0010dcf8..0x0010dd2c` walk exactly these three entries on the successful loop path.

For each pin:

- `0x0010dd34 -> 0x001114c0` checks whether its sysfs directory exists
- If check returns nonzero, `0x0010dd44 -> 0x0011187c` attempts unexport; its return is not tested here
- `0x0010dd14 -> 0x00111308` attempts export/configure with `r0=pin, r1=0`, selecting direction string `"in"`
- Export/configure nonzero result branches at `0x0010dd20 -> 0x0010dda4`, logs `"chain#%d - failed to export plug GPIO pin"`, then returns `-1` at `0x0010de54`

The existence-check alias at `0x001114c0`:

- `0x001114dc` resolves format `0x004829e0 = "/sys/class/gpio/gpio%u"`
- `0x001114e4 -> 0x0045b70c` formats it in a256-byte local buffer (snprintf-like signature; complete library dependency not audited)
- `0x001114e8` places the buffer in `r0`; `0x001114ec` sets `r1=0`; `0x001114f0 -> 0x00463700`
- `0x00463700` preserves `r7`; `0x00463704: mov r7,#0x21`; `0x00463708: svc #0`; `0x0046370c` restores `r7`; `0x00463710` tail-calls the syscall-return/error helper `0x00452b1c`
- `0x001114f4..0x001114f8` convert return0 into boolean1 and any nonzero32-bit return into boolean0 (`clz`, then shift5)

Thus the first such query targets GPIO439, and existence is checked before the unexport/export paths.

### First write-intent sysfs path

Unexport alias `0x0011187c` invokes lock-like helper `0x00461ca0`, then:

- `0x001118a0` resolves `0x00482a4d = "/sys/class/gpio/unexport"`
- `0x001118a4` resolves mode `0x00482c4b = "w"`
- `0x001118a8 -> 0x0045a9f4` opens a stdio-like stream
- In that target, `0x0045aa30` sets `r7=5`; following calls/argument setup precede `0x0045aa48: svc #0` (`open`), with original path in `r0`, mode-derived flags in `r1`, and `r2=0666`
- If the stream is non-null, `0x001118c4 -> 0x0045aa9c` supplies stream, format `"%u"`, and pin; `0x001118cc -> 0x0045a60c` closes it. The formatting/flush/write internals are not completely traced here, so actual successful hardware mutation is not claimed

If the GPIO directory did not exist, the init loop bypasses unexport and directly calls export alias `0x00111308`. This alias similarly opens `/sys/class/gpio/export` in mode `"w"` at `0x00111338 -> 0x0045a9f4`, supplies pin to the `%u` stream-format call at `0x00111354`, then closes at `0x0011135c`. It formats `/sys/class/gpio/gpio%u/direction`, opens in mode `"w"` at `0x00111388`, and selects `"in"` for argument0 or `"out"` for nonzero at `0x001113a0..0x001113ac`. String-output and close calls are `0x001113b4 -> 0x0045ac5c` and `0x001113bc -> 0x0045a60c`. The helper checks stream-open failures, but these bounded instructions do not check the stream-format/string-output/close return values before returning0.

### Output GPIO group and remaining platform calls

`0x0010dd4c..0x0010dd54` resolve table `0x00482194 = [454,455,456]`. The loop repeats the same exists/unexport/export pattern, now `r1=1` at `0x0010dd68`, selecting `"out"`. Calls are `0x0010dd8c -> 0x001114c0`, optional `0x0010dd9c -> 0x0011187c`, and `0x0010dd6c -> 0x00111308`. Nonzero export/configure return branches to the reset-GPIO error at `0x0010de1c`, then returns `-1`.

After both groups succeed:

1. `0x0010dddc -> 0x00105f3c`; nonzero logs the error associated with string `0x004810da` and returns `-1`
2. `0x0010de60 -> 0x00112f0c`; nonzero logs the error associated with string `0x004810f3` and returns `-1`
3. `0x0010dea0` sets return0

Those two dependencies appear to initialize transport/synchronization/storage structures from local instructions, but their complete effect sets remain unproved. Do not infer purity from their non-device-looking prefixes.

## Bounded nearby anchors, not expanded implementations

- I2C-init alias `0x0010cfe0` resolves `/dev/i2c-1` at `0x00481010`, calls `0x0011196c` at `0x0010d00c`, and only on success calls `0x00111ab4` at `0x0010d058`. Complete device-open/ioctl/read/write behavior is not audited in this checkpoint
- UART getter `0x0010e220` bounds the input against2, then indexes `0x004acf1c`, whose entries are `0x004821c9` `/dev/ttyS3`, `0x004821d4` `/dev/ttyS2`, `0x004821df` `/dev/ttyS1`. The bounded getter loads a pointer and returns; UART opening occurs elsewhere and remains unproved
- Fan/PWM strings at `0x00481e72`, `0x00481e97`, `0x00481ebc` are `/sys/class/pwm/pwmchip0/pwm%d/{enable,period,duty_cycle}`. Local PC-relative references occur at `0x0010cbb0`, `0x0010cbe8`, `0x0010cc10` respectively. They anchor the installed fan callback region, but neither fan initialization order nor complete writes were traced
- AML PSU callback `0x0010e2ec` is identified by dispatcher assignment and nearby `/tmp/build/libbitmain/src/aml/psu.c` references. Its internals are intentionally left unresolved

## Remaining proof obligations / safe next step

Keep this checkpoint evidence-only. The next bounded target is the chain/transport constructor at `0xea69c`, called through `0xe7a9c` before PSU preparation; its UART/device ownership and effects must be established before choosing another meaningful reconstructed module. Still unproved: all logger/allocator/mutex dependencies, full stream write/flush paths, device error/cleanup behavior, complete control-flow coverage, exact function extents, concurrency behavior, board/kernel compatibility, and runtime parity. No R13/R14/get_work/stop changes were made.

## Reproducible bounded byte receipts

All starts/ends are virtual addresses; ends are exclusive. These exact windows include some literal pools and are not asserted function extents.

| Window | Start..end | SHA-256 |
|---|---|---|
| AML dispatch case | `0x000ffc5c..0x000ffec8` | `45a5bb182b64f13eec21c445ceb6961b9d6cf68000258241e61c7146dba977fb` |
| Common callback order | `0x0010039c..0x00100490` | `e61e29392596d458f544191b4b42d80b2d4222158ba5ed184434382a6918bb26` |
| AML platform init + literals | `0x0010dce8..0x0010def4` | `4813991c5c16f005b50dec6c42b1fe08c0a8ec34680af7aeb811033f6ee7c0ce` |
| GPIO existence check | `0x001114c0..0x00111508` | `6eb480e30ce530c15899e65071eb3e41e15d30b38360a92cc1ccf5dc2283ad02` |
| GPIO export | `0x00111308..0x001114c0` | `6404b918f27cd73a6bc79d9a52b57e0e596203a291ba8e12da6629aa5411b288` |
| GPIO unexport | `0x0011187c..0x0011196c` | `efe5365c9d0c91acab62058945248d7654e59b630099487f94eeefa388c5c1ee` |
| Access syscall wrapper | `0x00463700..0x00463714` | `86d728ca5cbbbad9f9e9991d65bab30d19d668975b8c081e261099ed6511fa2a` |
| Stream-open wrapper | `0x0045a9f4..0x0045aa9c` | `e6639b8078ac8329a50fa0963851158533ecf855110af8b9aaf5dc88e345ed2c` |
| AML GPIO tables | `0x00482188..0x004821a0` | `ed6f85c1e6e2b052f76a7dea9cca4ff0a9b7d9100e119733ed516ffa3c6eb3cd` |
| AML UART getter | `0x0010e220..0x0010e248` | `5653d02db27deb8ffe7224a114ea295d7b491a41d820875a76783c9a77453c30` |
| AML I2C init | `0x0010cfe0..0x0010d0d4` | `af7de65c8f3c1b66c98c726ec437fc444eca128c953459c13382b65eb2de6ebd` |


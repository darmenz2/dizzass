# Startup safety map: VNishNet T21 AML NAND 1.3.5

## Status and scope

Proposed read-only static report, 2026-09-30. Repository reference: [darmenz2/dizzass at a482b4637c1bb8e2f201ba7d2a870c0fc10f0185](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/AGENTS.md). The repository's cgminer-first and reference-as-data rules apply. No replacement miner, source recovery completeness, runtime parity, hardware readiness, or electrical safety is established.

The five local public-subset files were read as text/data only. Their computed Git blob identities match the pinned repository tree. No vendor script or ELF was executed, sourced, emulated, booted or flashed. No device, UART, GPIO, PWM, I2C, pool or production service was contacted or changed. No referenced test/oracle was run. No R13/R14, get_work, stop implementation, protection, slot policy, or firmware input was edited. The full extraction manifest and private firmware content were not read for this report.

**Main result:** avoiding S70miner alone does not make the selected stock startup path passive. S11board already requests GPIO direction/value/pull/edge changes and PWM enable before S12hwscan. S12hwscan then runs a separate opaque vendor executable. Software OFF labels and successful process/status checks do not establish absence of voltage or UART activity.

## Evidence vocabulary

- **Direct script fact:** exact text or shell control flow in the five reviewed files. The text requests operations; their success on a board is untested.
- **Existing repository interpretation:** named behavior and address associations documented by earlier integration work. Those earlier tests are not rerun or adopted as fresh results here.
- **Inference:** a reasoned relationship, such as an OFF-like intention inferred by comparing a script value with the repository's named PSU operation.
- **Unknown electrical/runtime effect:** actual pin routing, polarity, voltage, timing, kernel behavior, ASIC state, hardware success, or unreviewed callee behavior.

Names such as pwr_en, ch0_rst and fan_front_speed0 occur in script comments. They are source labels, not independently measured connector assignments. Binary procedure names in the address catalog are research labels, not demonstrated vendor symbols or source identity.

## Exact input identity

Paths below are relative to the public subset's rootfs/etc. Line references in the next sections refer to these exact bytes.

| Input | Bytes | SHA-256 | Git blob |
|---|---:|---|---|
| init.d/rcS | 420 | 5a35a9506728a7c10a9185dfe67378916316c123aa2f346860ba573e8a80b66e | 04b104f9598011d9b8d575fb50d85422b585ec4d |
| init.d/S11board | 2928 | bbc25a2137fd35ff97d6aa545992d21e4d7d35303fe5650b1b226fdd94b249c4 | e4dc880f5236987de74756258bb828fd87473ba5 |
| init.d/S12hwscan | 412 | 1f64fa20ab1c8cc003c5cb9ff361f1eff148974228be5d9b77cedde38468e756 | a8c6bbf56b1cfb832bb0512ecfb25cdc22756783 |
| init.d/S70miner | 1083 | 7f2ea119eaa2c08c9c3a17876a049d739c1d94cc2bb6666bc00940395971f81b | b9bcd290fdcd921392d487ccee3ebafefa1ed59d |
| fw-info.json | 233 | 98f31e84aa102d6a24dc868a175db96d428edd7a76bcebb94b552a8b0d092be7 | bf23831e13d1d13ffadf6f77b132b00715e4adde |

[fw-info.json lines 2–7](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/fw-info.json#L2-L7) declares Vnish, version 1.3.5, platform aml, install_type nand, build_name vnishnet and build time 2026-07-30 13:28:38. These fields identify the declared build; they do not name a T21 board model or prove physical compatibility. T21 in this report is the research package's target designation.

## Line-precise selected boot-stage map

| Stage / exact lines | Direct fact | Side-effect or evidence boundary |
|---|---|---|
| [rcS 3–11](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/rcS#L3-L11) | Iterates /etc/init.d/S??*; skips non-regular-file targets; sources /usr/sbin/export_tz on each surviving iteration | Other matched scripts and export_tz are outside this five-file subset. The selected names place S11board before S12hwscan before S70miner; this is not a complete boot inventory |
| [rcS 13–27](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/rcS#L13-L27) | A .sh suffix is sourced in a subshell with argument start; other names are invoked as a subprocess with start | The three selected S scripts use the subprocess branch. No explicit return-code gate or set -e is present in rcS; ordinarily returning errors do not stop the loop. Unreviewed sourced code could still affect shell state/control flow |
| [S11board 97–107](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L97-L107) | start calls config_board, then config_gpios, config_misc, then prints OK | OK is unconditional after those function calls. There is no aggregate validation of all preceding sysfs writes |
| [S11board 7–12](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L7-L12) | Exports 446 and 445 and requests input direction | recovery/ip_get are comments. Pin mux, external drive, signal levels and readback are unknown |
| [S11board 14–17](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L14-L17) | Exports 437, requests output direction, then writes value 1 | Definite output-configuration request before scanning. No active_low check, atomic initial-value request, readback, power-good or rail measurement appears here |
| [S11board 19–30](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L19-L30) | Exports 439/440/441, sets input direction and pull=down | Comments label chain-plug inputs. Pull support, bias effect, physical mapping and actual attachment detection remain unverified |
| [S11board 32–40](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L32-L40) | Exports 454/455/456 and requests output direction | Reset labels are comments. No explicit value write occurs here; the script does not establish the resulting initial level or absence of transitions |
| [S11board 42–47](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L42-L47) | Exports 453/438 and requests output direction | Green/red LED labels are comments. Initial output levels and electrical effects are not checked |
| [S11board 49–75](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L49-L75) | Only if the GPIO directory is absent, exports 447–450, sets input and edge=falling | Existing directories bypass both direction and edge writes. Presence of a directory therefore does not prove correct tachometer configuration; no RPM measurement is made |
| [S11board 77–87](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L77-L87) | Exports pwmchip0 channels 0/1, sets period=100000 and duty_cycle=100000, then enable=1 on both | Comments associate channel 0 with rear FAN2/FAN4, channel 1 with front FAN1/FAN3. Requested duty equals period; polarity, physical frequency, fan speed, actual enable success and cooling adequacy are unmeasured |
| [S11board 90–95](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S11board#L90-L95) | Writes 2 to /proc/sys/abi/cp15_barrier if that file exists | Kernel ABI-setting request, not a hardware-readiness check |
| [S12hwscan 8–22, 25–29](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S12hwscan#L8-L29) | Extracts the second whitespace field from lines matching platform in fw-info.json, strips quotes/commas, builds --platform aml for these bytes, and invokes hwscan synchronously | Text extraction is not a JSON parser. The invoked PATH-resolved binary's physical side effects are not specified by this script. Success prints OK; failure prints FAIL without an explicit nonzero propagation/global boot-stop operation |
| [S70miner 6–10, 16–30](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/research/vnishnet-t21-aml-nand-1.3.5/10-extracted/rootfs/etc/init.d/S70miner#L6-L30) | Creates the log directory if absent, sources export_tz, backgrounds /usr/bin/cgminer via start-stop-daemon with --default-config /config/cgminer.conf and /var/run/cgminer.pid, sleeps one second, then uses pidof cgminer for OK/FAIL | Launches the vendor program with an external configuration. pidof checks a name, not readiness, safe power, successful scan, exact process provenance, sensor health or pool state. Configuration contents were not inspected |

These are program-order requests within the inspected files, conditional on reaching the relevant line. They do not imply every write succeeds, fixed wall-clock sequencing of hardware, absence of earlier board changes, or successful entry into a later binary function.

## Cross-check against existing integration work

### GPIO and power

[GPIO_POWER_135_RU.md lines 12–19](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/GPIO_POWER_135_RU.md#L12-L19) associates 0x1248e4 with export/direction, 0x124b5c with a directory probe, 0x124ba4 with value writes, 0x124d64 with value reads, 0x124f70 with direction-only and 0x1251b8 with unexport.

[GPIO_POWER_135_RU.md lines 40–60](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/GPIO_POWER_135_RU.md#L40-L60) describes the AML on/off entries using GPIO 437: ready==1 selects value 0 for ON and 1 for OFF. OFF can return success without a write when ready is not 1. Backend start calls ON before voltage-setting; a subsequent voltage-setting failure has no OFF rollback in that described path.

**Inference, not measured fact:** the S11board value 1 is consistent with the repository's OFF label. The ordering still switches direction before that explicit value. Neither the comment pwr_en, value 1, a software return code nor the final OK establishes an electrically de-energized board.

[AML_POWER_GUARD_RU.md lines 9–25](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/AML_POWER_GUARD_RU.md#L9-L25) documents platform selector 2, three AML chains, reset table 454/455/456 and reset assert value 0. It expressly limits this to numerical bindings in the studied image rather than universal T21 physical pinout or measured polarity.

[AML_POWER_GUARD_RU.md lines 31–46](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/AML_POWER_GUARD_RU.md#L31-L46) also warns that a successful fopen can be followed by ignored fprintf/fclose results, reset returns can be ignored, and the described shutdown path has no rail-drop, nonce-cessation, hardware-ACK or RX-clear confirmation. This report does not modify or test stop behavior.

### PSU initialization can revisit GPIO after S11board

[I2C_INIT_135_RU.md lines 7–30](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/I2C_INIT_135_RU.md#L7-L30) distinguishes a software PSU I2C bus (SDA 477, SCL 476) from /dev/i2c-1. These are repository-observed numerical associations, not connector guidance.

[I2C_INIT_135_RU.md lines 50–80](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/I2C_INIT_135_RU.md#L50-L80) describes the AML PSU initializer checking/unexporting GPIO 437 as applicable, then setting direction; the software I2C initializer similarly exports/directions SDA and SCL. No new high/OFF policy is implied. The report's earlier description of S11board does not prove 437 remains untouched later. Actual reachability and ordering through the complete binary startup still need bounded static confirmation.

### hwscan and UART

[HWSCAN_TX88_IO_RU.md lines 10–20](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/HWSCAN_TX88_IO_RU.md#L10-L20) says physical hwscan is not implemented by that integration layer. The paths /var/run/hwscan/miner-model.json and hw-info.json are known from the image; the existence of paths or JSON schemas does not establish safe scanner side effects. [Lines 48–53](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/HWSCAN_TX88_IO_RU.md#L48-L53) do not establish atomic generation of the multi-file profile. S12hwscan has no profile freshness/consistency validation in the inspected script.

[UART_CHANNEL_RU.md lines 7–9](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/UART_CHANNEL_RU.md#L7-L9) calls its gate new opt-in POSIX behavior, not another recovered VNish function. Do not infer that it protects stock startup. [Lines 25–50](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/UART_CHANNEL_RU.md#L25-L50) describe a borrowed fd, exclusive transmission and soft stopping; [lines 68–85](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/UART_CHANNEL_RU.md#L68-L85) distinguish accepted write bytes from drain/ASIC ACK and require coordination with external fd users.

No UART device is explicitly opened in the four scripts. That is not evidence of UART inactivity after hwscan or cgminer launches. Neither S11board reset direction nor Linux-buffer flushing, time delay, software stop or epoch change is a demonstrated clean-device boundary. [AML_POWER_GUARD_RU.md lines 103–118](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/AML_POWER_GUARD_RU.md#L103-L118) and [HWSCAN_TX88_IO_RU.md lines 88–96](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/HWSCAN_TX88_IO_RU.md#L88-L96) retain the 32-slot/no-safe-reuse boundary.

The new native power guard is not registered in the main binary and does not itself start monitoring, per [AML_POWER_GUARD_RU.md lines 97–101](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/AML_POWER_GUARD_RU.md#L97-L101). It cannot be treated as an installed stock-boot protection.

## Bounded disassembly address catalog

The following bounds are copied from repository evidence at the pinned commit, not guessed from adjacent labels. All are half-open virtual-address intervals [start,end), for the cgminer reference whose SHA-256 is:

b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9

**They do not refer to the separate hwscan ELF.** A range hash is the identity of a chosen byte interval, not proof that every byte is executable or that the range is a complete function. Some bounds explicitly contain literal pools or are only prefixes. Each candidate must be tied to the actual ELF/load mapping and source-range digest before use.

| Repository label | Start | End exclusive | Bytes | Exact range SHA-256 | Evidence |
|---|---|---|---:|---|---|
| constructor_and_literal_pool | 0x730d8 | 0x7409c | 4036 | e279b07ce4487061ed9f2bfd2710230da14a7a593a9ccd9c4744909a113fbab6 | [backend_cold_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/backend_cold_135.json) |
| constructor_wrapper | 0xb5a4c | 0xb5ad4 | 136 | bbfe83c49ca06772b7007290190fc886998066ec0667c2db9ec035a52b8df25b | [backend_cold_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/backend_cold_135.json) |
| prepare | 0x7409c | 0x74acc | 2608 | 1b7eb49e0e5ddcde4d17ebbfc29977968049cc1827449b70c3692d1ec584b21d | [backend_prepare_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/backend_prepare_135.json) |
| fan_poll | 0x7755c | 0x776d0 | 372 | 0b29e4d41ba11ff5e52c88a7d44b63b6481db2ed1209862b8660f7bdd01ed43d | [backend_prepare_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/backend_prepare_135.json) |
| platform_callback_setup_prefix | 0xfb994 | 0xfd784 | 7664 | d6b3015ee9f0b81c068be966e245ea04df05018cf54924e18bf4a913f8144fea | [gpio_power_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/gpio_power_135.json) |
| gpio_helpers | 0x1248e4 | 0x125338 | 2644 | 50abca275f080ac5a5e81856c3cb90c3473dff1df20d490b8527417bfd56fe93 | [gpio_power_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/gpio_power_135.json) |
| power_wrappers | 0x102a94 | 0x102b08 | 116 | 4d7346005b15c85cf6087c533993e516c6f9abbdbb729874aa67a23c4c8c8860 | [gpio_power_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/gpio_power_135.json) |
| backend_start | 0x6c224 | 0x6c61c | 1016 | c8b060d125ca86bc217835425dda2c1f3853f48261b3036dca57243a8d26d6e8 | [gpio_power_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/gpio_power_135.json) |
| caller_value_slice | 0x7140c | 0x71450 | 68 | 6ac0f2ccf761c2c9da8e0a05778dfad65fa744df81c3e19c46b7eb46ea971dbc | [gpio_power_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/gpio_power_135.json) |
| platform_caller | 0x732ac | 0x732c8 | 28 | ccb3ba53933ab6b67d6d20c30198c133acd824cf6432d065e4331f472585f43a | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| platform_initializer_selection | 0xfbb98 | 0xfd794 | 7164 | b01ac8a837da4a6cd33e174c1e51d47ae8e77a1654caf989d921b194c3906b1c | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| psu_on_dispatch | 0xfe310 | 0xfe398 | 136 | 812409093d5c287d74d4e53088a25cee2efe8380f97811b0a8234c6926e45724 | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| psu_off_dispatch | 0xfe398 | 0xfe420 | 136 | 62acb01b67770576fa2cdf3c73f259de8be5959180c7b2321df2a5c4898d2b7d | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| chain_reset_dispatch | 0xfde14 | 0xfdeb4 | 160 | 8b37b80abb27e8277baedf59f33f01c00cf5f1c43d8bf90a48d38fa430a17a85 | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| aml_chain_reset | 0x11bc14 | 0x11bd64 | 336 | 4d148f2f5d715505837da5f884a8c06777f5510aa8a536072ec1ab398bd024b4 | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| aml_chain_count | 0x11b6c8 | 0x11b708 | 64 | a821d130d717504314f2f6761276d0c153ac1b1ff53dc01b583af770395c9bdf | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| aml_psu_on | 0x11c978 | 0x11ca74 | 252 | 5956c23e3e1999b8a81a6aebdb63ae70397082e987e41d0ff6be2007851f8a02 | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| aml_psu_off | 0x11ca74 | 0x11cbe0 | 364 | db1734f06e1b33e2384c7b61cbe3f53e20687510cf8b85cf3fb4f51bcfc09129 | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| gpio_stdio_write | 0x124ba4 | 0x124d64 | 448 | 81e0fd95b3a81467f337414077bafa50993e56551f4945c61a6b533ea9bf7a92 | [aml_power.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/aml_power.json) |
| registration | 0x125a28 | 0x125bf4 | 460 | f9bea251782f9de2c200cb4cd1eeec3153690709a715937a848f01c2d7aebdad | [i2c_init_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/i2c_init_135.json) |
| gpio_init | 0x126084 | 0x126d14 | 3216 | 4bb17839c9387a6f1470cd7fec84a86ff962af3fada7a8eb2125b5f94911b561 | [i2c_init_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/i2c_init_135.json) |
| aml_psu_init_getter | 0x11c5c0 | 0x11c978 | 952 | 623896d8e6c05f502dfac9ccb9cacae97520fe175bb4bb80593251fdba2221ac | [i2c_init_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/i2c_init_135.json) |
| aml_hw_init_getter | 0x119a1c | 0x119ccc | 688 | 6df318ffc7a123905564da7f6dcd8fb584229572d690780a8771d1dd5b645fa1 | [i2c_init_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/i2c_init_135.json) |
| psu_caller_prefix_with_literals | 0x100fc4 | 0x102144 | 4480 | de2fc4c0281cfb822037f183af536954d61c0b1bdb12d3c645679e63c679580c | [i2c_init_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/i2c_init_135.json) |
| getters_dispatch | 0xfe420 | 0xfe4c0 | 160 | 5ff86ae8230944378dae4198efb888339b717f761ec92afb9b5912fc76f7e1ff | [i2c_init_135.json](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/evidence/i2c_init_135.json) |

### ISA mode and literal-pool limits

- The selected JSON evidence above contains no explicit per-range ARM/Thumb mode field or mapping-symbol proof. ARM32Verify use in the historical oracles is corroborating evidence for an A32 interpretation, not independent mode proof. The oracles were read only.
- [aml_power_oracle.py lines 35–42](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/tests/aml_power_oracle.py#L35-L42) applies A32-style PC+8 literal calculations at specified AML locations. [gpio_power_135_oracle.py lines 12–14, 35–40](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/integration/tests/gpio_power_135_oracle.py#L12-L40) records entry addresses and selected callback addresses. These are research evidence, not a fresh decode.
- An existing [uart-open.S listing lines 7–10](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/evidence/stage5/disasm/uart-open.S#L7-L10) shows 0x10e0c8: e92d4ff0 (A32 push), 0x10e0cc: e28db01c and subsequent four-byte A32 instructions. This directly supports the saved listing's A32 interpretation at the UART-open entry. It is still necessary to compare that listing against the current reference bytes before claiming fresh verification.
- The same listing displays code through 0x10e4a4 and PC-relative data references into 0x10e4a8 onward. Lines 255–282 are literal words rendered as instructions by a linear decoder. Treat those words as literal-pool candidates, not operational behavior or Thumb evidence.
- [evidence/modules/libbitmain/src/uart.c.json lines 14–90](https://github.com/darmenz2/dizzass/blob/a482b4637c1bb8e2f201ba7d2a870c0fc10f0185/evidence/modules/libbitmain/src/uart.c.json#L14-L90) supplies candidate source-associated intervals [0x10e0c8,0x10e938) and [0x10ea5c,0x10ed2c), but explicitly says ownership is not proven. These are broader association buckets, not whole UART functions.
- No Thumb entry or Thumb-only startup span is independently established by the sources reviewed here. Do not force Thumb to obtain plausible output, extend through another function speculatively, or label every decoded word as code. Record undecided mode/data boundaries explicitly.

## Controlboard-test planning gaps

This is a planning gate list, not authorization or a procedure for energizing a board. Until the following are resolved, the reviewed stock boot path is not a supported passive controlboard diagnostic.

1. **Contain startup before first hardware-changing stage.** Identify an owner-reviewed boot/test arrangement that prevents all unreviewed startup scripts and vendor executables from reaching hardware. Merely suppressing S70miner is insufficient because S11board and S12hwscan precede it. No boot configuration was changed here.
2. **Account for pre-script state.** Boot ROM/bootloader, kernel/pinctrl, device tree, driver initialization, watchdog behavior and all omitted S?? scripts remain outside this subset. Their absence from the report is not evidence of no effects.
3. **Establish board identity and pin ownership.** Resolve exact controlboard/PSU/hashboard revision, actual GPIO controller numbering, pin mux, active_low, reset and power polarity, pull behavior, default output levels and all other GPIO consumers using appropriate hardware documentation and a separately authorized test plan.
4. **Resolve direction/value transitions and persistence.** Confirm what output-direction requests, export/unexport and initialization retries do electrically, including transient effects. A later binary initializer may revisit 437 and software-I2C pins even if S11board completed.
5. **Establish independent power containment and observation.** Define rail measurement, power-good criteria, discharge behavior, current limits and a verified means to de-energize independently of cgminer or software return values. Do not infer safe voltage from GPIO value or readback.
6. **Validate cooling and protection prerequisites.** Establish PWM polarity/frequency, which physical fans are controlled, tachometer wiring/RPM validity, sensor availability, thermal limits and watchdog coverage. Equal duty/period and successful enable writes do not prove cooling.
7. **Contain the scanner separately.** Identify the exact hwscan binary's static side-effect paths, device opens, bus writes and persistence before authorizing any scanner test. S12hwscan's name and platform argument do not make it read-only. Preserve profile-generation provenance/freshness and distinguish scanner success from independent physical validation.
8. **Establish UART lifecycle and a real clean-device boundary.** Identify device paths from evidence, exclusive TX/RX ownership, all fd aliases, configured electrical/serial modes, hardware cessation/reset acknowledgement and every outstanding RX queue. PTY results and POSIX soft stop do not establish these facts. Retain existing slot-reuse restrictions.
9. **Separate software receipt from acceptance.** Define explicit evidence for each attempted step, its observed result, unresolved effects and stop condition. The stock OK strings and pidof check are insufficient acceptance criteria. Preserve protections; unknown behavior stays unsupported.
10. **Obtain separate authority for any physical work.** This report authorizes no booting, flashing, network test, source-script execution, hardware commands, model/OOM probes, voltage/frequency changes, guard changes or production installation.

## Fresh verification performed for this report

- Read the pinned repository AGENTS.md and the named integration documentation/evidence through the GitHub connector.
- Read and line-number the five public-subset files without executing them.
- Compute each input's SHA-256 and Git blob SHA-1 using standard byte hashing; all five blob IDs match the pinned tree.
- Read selected historical oracle/listing text only to qualify address/mode labels; no oracle, model or vendor instructions were executed.
- Produce only this proposed report. Repository source, extracted evidence, runtime settings and the full extraction manifest were not modified.
- No new disassembly, build, differential test, physical scan, rail measurement or runtime comparison is claimed by this report.

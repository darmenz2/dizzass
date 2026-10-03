#!/usr/bin/env python3
"""Check the evaluated *baseline* cgminer source list; no builds or hardware I/O.
Deliberately strict until an explicitly reviewed native T21 adapter is added.
This checks linkage inputs, not mining behavior or complete absence of defects.
"""
from __future__ import annotations
import argparse
from pathlib import Path, PurePosixPath
import re
import sys

REQUIRED = frozenset({"cgminer.c", "util.c", "sha2.c", "api.c", "logging.c", "klist.c", "noncedup.c"})
# Union of cgminer_SOURCES entries in pinned upstream Makefile.am, blob
# 17d2fbde26b5e8cb614b61908b84d5937af48325. Keep this policy explicit: do not
# derive it from the build evidence being checked. A new native adapter needs
# a reviewed policy change even when it lives outside the recovery directories.
BASELINE_SOURCES = frozenset("""
    A1-board-selector-CCD.c A1-board-selector-CCR.c A1-board-selector.h
    A1-common.h A1-trimpot-mcp4x.c A1-trimpot-mcp4x.h
    api.c bench_block.h
    bf16-bitfury16.c bf16-bitfury16.h bf16-brd-control.c bf16-brd-control.h
    bf16-communication.c bf16-communication.h bf16-ctrldevice.c bf16-ctrldevice.h
    bf16-device.h bf16-gpiodevice.c bf16-gpiodevice.h
    bf16-mspcontrol.c bf16-mspcontrol.h bf16-spidevice.c bf16-spidevice.h
    bf16-uartdevice.c bf16-uartdevice.h bitmain-board-test.c bitmain-board-test.h
    cgminer.c compat.h crc.h crc16.c
    dm_compat.c dm_fan_ctrl.c dm_temp_ctrl.c dragonmint_t1.c
    driver-SPI-bitmine-A1.c driver-SPI-dragonmint-t1.c
    driver-avalon-miner.c driver-avalon-miner.h driver-avalon.c driver-avalon.h
    driver-avalon2.c driver-avalon2.h driver-avalon4.c driver-avalon4.h
    driver-avalon7.c driver-avalon7.h driver-avalon8.c driver-avalon8.h
    driver-bab.c driver-bflsc.c driver-bflsc.h driver-bitforce.c
    driver-bitfury.c driver-bitfury.h driver-bitfury16.c driver-bitfury16.h
    driver-bitmain.c driver-bitmain.h driver-blockerupter.c driver-blockerupter.h
    driver-btm-soc.c driver-btm-soc.h driver-cointerra.c driver-cointerra.h
    driver-drillbit.c driver-drillbit.h driver-hashfast.c driver-hashfast.h
    driver-hashratio.c driver-hashratio.h driver-icarus.c driver-klondike.c
    driver-knc.c driver-minion.c driver-modminer.c
    driver-spondoolies-sp10-p.c driver-spondoolies-sp10-p.h
    driver-spondoolies-sp10.c driver-spondoolies-sp10.h
    driver-spondoolies-sp30-p.c driver-spondoolies-sp30-p.h
    driver-spondoolies-sp30.c driver-spondoolies-sp30.h
    elist.h fpgautils.c fpgautils.h hf_protocol.h hf_protocol_be.h
    i2c-context.c i2c-context.h klist.c klist.h
    knc-asic.c knc-asic.h knc-transport-spi.c knc-transport.h
    libbitfury.c libbitfury.h logging.c logging.h mcp2210.c mcp2210.h
    miner.h noncedup.c sha2.c sha2.h spi-context.c spi-context.h
    usbutils.c usbutils.h uthash.h util.c util.h
""".split())


def validate(sources: str, symbols: str | None = None) -> list[str]:
    errors: list[str] = []
    names: list[str] = []
    for token in sources.split():
        path = PurePosixPath(token)
        if (path.is_absolute() or ".." in path.parts or "$" in token
                or "\\" in token or ":" in token or token.endswith(("/", "/."))):
            errors.append(f"unexpanded or unsafe source path: {token}")
            continue
        names.append(path.as_posix())
    present = set(names)
    for name in sorted(REQUIRED - present):
        errors.append(f"missing native core source: {name}")
    for name in sorted(present):
        if name not in BASELINE_SOURCES:
            errors.append(f"non-baseline module in production sources: {name}")
    if len(names) != len(present):
        errors.append("duplicate source entries")
    if symbols is not None and re.search(r"\bvn135_[A-Za-z0-9_]+", symbols):
        errors.append("recovery symbols present in the production binary")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, required=True,
                        help="output of native-check.mk dizzass-core-sources")
    parser.add_argument("--symbols", type=Path, help="optional nm --defined-only output")
    args = parser.parse_args()
    try:
        sources = args.sources.read_text(encoding="utf-8")
        symbols = args.symbols.read_text(encoding="utf-8") if args.symbols else None
    except (OSError, UnicodeError) as exc:
        print(f"Cannot read build evidence: {exc}", file=sys.stderr)
        return 2
    errors = validate(sources, symbols)
    if errors:
        print("Native core boundary FAILED:\n" + "\n".join(errors), file=sys.stderr)
        return 1
    print("Native baseline source boundary PASS; hardware/runtime behavior not tested here.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

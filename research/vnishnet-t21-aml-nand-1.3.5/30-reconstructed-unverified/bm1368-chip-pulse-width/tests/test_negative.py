#!/usr/bin/env python3
"""Compiled semantic controls for the new standalone e33e0 translation unit.

Only the new runtime source is copied/mutated. Every lower source and the host
assertions stay unchanged. A build error, signal, timeout or other exit does
not count as detection: each control must exit 1 at CHIP_PULSE135_FAIL.
"""
from __future__ import annotations
import argparse
import json
from pathlib import Path
import re
import shlex
import subprocess


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[5])
    parser.add_argument("--cc", default="cc")
    parser.add_argument("--build", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    output = args.build.resolve()
    output.mkdir(parents=True, exist_ok=False)
    source = root / "libbitmain/src/chip/chip1368-chip-pulse-width.c"
    original = source.read_text(encoding="utf-8")
    pattern = re.search(r"^REG1368_SRC = (.+)$", (root / "integration/bm1368-register-write-135.mk")
                        .read_text(encoding="utf-8"), re.MULTILINE)
    if pattern is None:
        raise RuntimeError("REG1368_SRC declaration missing")
    lower = [str(root / p) for p in shlex.split(pattern.group(1))]
    lower.append(str(root / "libbitmain/src/chip/chip1368-pulse-width.c"))
    flags = ["-std=c11", "-O1", "-g", "-Wall", "-Wextra", "-Wpedantic", "-Werror",
             "-fno-fast-math", "-ffp-contract=off", "-I" + str(root), "-I" + str(root / "include"),
             "-DVN135_BM1368_REGISTER_WRITE_135", "-DVN135_BM1368_FREQUENCY_135",
             "-DVN135_BM1368_PULSE_WIDTH_135", "-DVN135_BM1368_CHIP_PULSE_WIDTH_135"]
    controls = [
        ("broadcast-mode", "opaque, device, 0, chip,", "opaque, device, 1, chip,"),
        ("lost-chip-identity", "opaque, device, 0, chip,", "opaque, device, 0, chip ? NULL : chip,"),
        ("wrong-register", "chip, 0x3c, value", "chip, 0x18, value"),
        ("pulse-high-bit", "pulse_width & 3u", "pulse_width & 7u"),
        ("clock-high-bit", "clock_delay & 7u", "clock_delay & 15u"),
        ("pulse-shift", "3u) << 6", "3u) << 5"),
        ("clock-shift", "7u) << 3", "7u) << 2"),
        ("wrong-base", "0x80008000", "0x80008200"),
        ("positive-status-success", "value) == 0", "value) >= 0"),
        ("missing-first-log", "ops->log(opaque, 387, device->index + UINT32_C(1));", "(void)0;"),
        ("wrong-second-line", "ops->log(opaque, 538,", "ops->log(opaque, 569,"),
        ("unwrapped-index", "device->index + UINT32_C(1)", "device->index", 2),
        ("reused-first-index",
         "    ops->log(opaque, 387, device->index + UINT32_C(1));\n"
         "    ops->log(opaque, 538, device->index + UINT32_C(1));",
         "    const uint32_t cached = device->index + UINT32_C(1);\n"
         "    ops->log(opaque, 387, cached);\n    ops->log(opaque, 538, cached);"),
        ("failure-return-success", "    return -1;", "    return 0;"),
    ]
    test = str(Path(__file__).with_name("test_chip_pulse_width.c").resolve())
    receipts = []
    for entry in [("baseline", "", ""), *controls]:
        name, old, new, *counts = entry
        text = original
        if old:
            expected = counts[0] if counts else 1
            if original.count(old) != expected:
                raise RuntimeError(f"{name}: source partition no longer matches")
            text = original.replace(old, new)
        directory = output / name
        directory.mkdir()
        mutant = directory / "runtime.c"
        mutant.write_text(text, encoding="utf-8")
        executable = directory / "test"
        command = shlex.split(args.cc) + flags + lower + [str(mutant), test, "-o", str(executable)]
        build = subprocess.run(command, capture_output=True, text=True, timeout=60)
        (directory / "build.log").write_text(build.stdout + build.stderr, encoding="utf-8")
        if build.returncode:
            raise RuntimeError(f"{name}: compile failed; not semantic detection")
        run = subprocess.run([str(executable)], capture_output=True, text=True, timeout=45)
        (directory / "run.log").write_text(run.stdout + run.stderr, encoding="utf-8")
        accepted = (run.returncode == 0 and "BM1368_CHIP_PULSE135_HOST_PASS" in run.stdout) if name == "baseline" \
            else (run.returncode == 1 and "CHIP_PULSE135_FAIL" in run.stderr)
        receipts.append({"name": name, "compile_exit": build.returncode,
                         "run_exit": run.returncode, "expected_assertion": accepted})
        if not accepted:
            raise RuntimeError(f"{name}: expected assertion exit 1 was not observed")
    (output / "results.json").write_text(json.dumps(receipts, indent=2) + "\n", encoding="utf-8")
    print(f"BM1368_CHIP_PULSE135_CONTROLS_PASS controls={len(controls)} baseline=1")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

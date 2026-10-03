#!/usr/bin/env python3
"""Build authored host C and safe semantic controls, never execute reference ELF."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
SOURCE = "libbitmain/src/chip/chip1368-startup-registers.c"
SOURCES = [SOURCE, "libbitmain/src/chip/chip1368-register-write.c",
    "libbitmain/src/reg_cache.c", "integration/bm1368_control.c",
    "reconstruction/support/crc5.c", "integration/tests/test_bm1368_startup_registers_135.c"]
HEADERS = ["integration/bm1368_startup_registers_135.h",
    "integration/bm1368_register_write_135.h", "integration/bm1368_frequency_135.h",
    "integration/bm1368_control.h", "include/xminer/recovery/reg_cache.h",
    "include/xminer/recovery/chip1398.h", "include/xminer/recovery/pll.h",
    "reconstruction/data/reg_cache_defaults.inc"]
CONTROLS = Path(__file__).with_name("bm1368_startup_registers_controls_135.json")
MARKER = re.compile(r"STARTUP_REGISTERS_PASS cases=(\d+) checks=(\d+) simple=(\d+) rmw=(\d+) composition=(\d+) hardware=no\n")


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checked_inputs():
    result = {}
    for rel in SOURCES + HEADERS:
        path = ROOT / rel
        if not path.is_file() or path.is_symlink():
            raise ValueError("missing/nonregular source: " + rel)
        result[rel] = sha(path)
    return result


def execute(argv, timeout, env, logs):
    row = {"command": [str(x) for x in argv]}
    logs.append(row)
    try:
        p = subprocess.run(row["command"], cwd=ROOT, capture_output=True,
                           text=True, timeout=timeout, env=env)
    except subprocess.TimeoutExpired as exc:
        row.update(timeout=True, error=str(exc))
        raise
    row.update(exit=p.returncode, stdout=p.stdout, stderr=p.stderr)
    return p


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--cc", default="cc")
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--sanitize", action="store_true")
    p.add_argument("--mutants", action="store_true")
    a = p.parse_args()
    out = a.out.resolve()
    if out == ROOT or ROOT.is_relative_to(out):
        raise ValueError("output cannot contain source root")
    out.mkdir(parents=True, exist_ok=False)
    report = {"result": "incomplete", "source_sha256": checked_inputs(),
        "runner_sha256": sha(Path(__file__)), "controls_sha256": sha(CONTROLS),
        "compiler": a.cc, "all_six_tus_sanitized": a.sanitize,
        "leak_detection_enabled": a.sanitize, "hardware": False,
        "original_execution": False, "commands": [], "controls": []}
    flags = ["-I" + str(ROOT), "-I" + str(ROOT / "include"), "-std=c11", "-O1", "-g",
        "-Wall", "-Wextra", "-Wpedantic", "-Werror", "-Wshadow",
        "-DVN135_BM1368_STARTUP_REGISTERS_135", "-DVN135_BM1368_REGISTER_WRITE_135"]
    if a.sanitize:
        flags += ["-fsanitize=address,undefined", "-fno-omit-frame-pointer", "-fno-pie", "-no-pie"]
    env = dict(os.environ, ASAN_OPTIONS="detect_leaks=1:halt_on_error=1",
               UBSAN_OPTIONS="halt_on_error=1:print_stacktrace=1")
    sources = [ROOT / x for x in SOURCES]
    try:
        result = execute([a.cc, "--version"], 10, env, report["commands"])
        if result.returncode:
            raise RuntimeError("compiler unavailable")
        # Extra conversion diagnostics apply to the authored runtime alone.
        strict = [a.cc, *(x for x in flags if x != "-no-pie"), "-Wconversion", "-Wsign-conversion", "-fsyntax-only", ROOT / SOURCE]
        result = execute(strict, 20, env, report["commands"])
        if result.returncode:
            raise RuntimeError("authored runtime strict check failed")
        exe = out / "host-test"
        result = execute([a.cc, *flags, *sources, "-o", exe], 45, env, report["commands"])
        if result.returncode:
            raise RuntimeError("positive build failed")
        result = execute([exe], 25, env, report["commands"])
        marker = MARKER.fullmatch(result.stdout)
        if result.returncode or not marker:
            raise RuntimeError("positive test failed")
        numbers = [int(x) for x in marker.groups()]
        if numbers[0] != sum(numbers[2:]):
            raise ValueError("scenario subtotal mismatch")
        report.update(zip(["cases", "checks", "simple", "rmw", "composition"], numbers))
        report["executable_sha256"] = sha(exe)
        if a.mutants:
            original = (ROOT / SOURCE).read_text()
            controls = json.loads(CONTROLS.read_text())
            if len({x["name"] for x in controls}) != len(controls):
                raise ValueError("duplicate control")
            for i, c in enumerate(controls):
                if not c["before"] or c["before"] == c["after"] or original.count(c["before"]) != 1:
                    raise ValueError("invalid control contract: " + c["name"])
                changed = out / (c["name"] + ".c")
                changed.write_text(original.replace(c["before"], c["after"]))
                target = out / ("control-" + str(i))
                row = {"name": c["name"], "changed_source": SOURCE,
                       "changed_sha256": sha(changed), "commands": []}
                report["controls"].append(row)
                result = execute([a.cc, *flags, changed, *sources[1:], "-o", target], 45, env, row["commands"])
                if result.returncode:
                    raise RuntimeError("control build failed: " + c["name"])
                result = execute([target], 25, env, row["commands"])
                if result.returncode != 1 or not re.fullmatch(r"STARTUP_REGISTERS_ASSERT line=\d+ expression=.+\n", result.stderr):
                    raise RuntimeError("control must fail by assertion/exit1, not crash/build/timeout: " + c["name"])
                row.update(result="assertion_detected", executable_sha256=sha(target))
                target.unlink()
        if report["source_sha256"] != checked_inputs():
            raise RuntimeError("source changed during execution")
        if report["runner_sha256"] != sha(Path(__file__)) or report["controls_sha256"] != sha(CONTROLS):
            raise RuntimeError("runner/control changed during execution")
        report["result"] = "passed"
        print("STARTUP_REGISTERS_RUN_PASS cases=%s checks=%s controls=%s sanitize=%s" %
              (report["cases"], report["checks"], len(report["controls"]), a.sanitize))
    except BaseException as exc:
        report.update(result="failed", error=repr(exc))
        raise
    finally:
        (out / "report.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()

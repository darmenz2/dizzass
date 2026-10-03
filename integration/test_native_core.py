#!/usr/bin/env python3
"""Tests for build-boundary validation; not tests of cgminer itself."""
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest
from check_native_core import BASELINE_SOURCES, REQUIRED, validate

BASE = "\n".join(sorted(REQUIRED)) + "\nminer.h\n"


class BoundaryTests(unittest.TestCase):
    def test_native_sources(self):
        self.assertEqual(validate(BASE + "driver-icarus.c\nusbutils.c\n"), [])

    def test_catalog_matches_pinned_makefile_sources(self):
        makefile = Path(__file__).resolve().parent.parent / "Makefile.am"
        logical_lines = makefile.read_text(encoding="utf-8").replace("\\\n", " ")
        declared = set()
        for value in re.findall(r"^cgminer_SOURCES\s*(?::=|\+=|=)\s*(.*)$",
                                logical_lines, re.MULTILINE):
            declared.update(value.split())
        self.assertEqual(BASELINE_SOURCES, declared)
        self.assertLessEqual(REQUIRED, BASELINE_SOURCES)

    def test_every_upstream_optional_source_is_allowed(self):
        self.assertEqual(validate("\n".join(sorted(BASELINE_SOURCES))), [])
        for name in BASELINE_SOURCES - REQUIRED - {"miner.h"}:
            with self.subTest(name=name):
                self.assertEqual(validate(BASE + name), [])

    def test_missing_each_native_source(self):
        for name in REQUIRED:
            with self.subTest(name=name):
                self.assertTrue(validate(BASE.replace(name + "\n", "")))

    def test_recovery_and_mock_sources_rejected(self):
        for name in ("src/frontend/cgminer.c", "reconstruction/support/sha256_bytes.c",
                     "libbitmain/src/uart.c", "tests/fake_main.c", "reference/vendor.c"):
            with self.subTest(name=name):
                self.assertTrue(validate(BASE + name))

    def test_bad_paths(self):
        for name in ("../cgminer.c", "/tmp/cgminer.c", "$(extra_SOURCES)",
                     "C:/cgminer.c", "C:cgminer.c", "C:\\cgminer.c",
                     "src\\frontend\\cgminer.c", "driver-icarus.c/", "driver-icarus.c/."):
            with self.subTest(name=name):
                self.assertTrue(validate(BASE + name))

    def test_duplicate_entries(self):
        self.assertTrue(validate(BASE + "cgminer.c"))
        self.assertTrue(validate(BASE + "./cgminer.c"))

    def test_unreviewed_modules_rejected(self):
        for name in ("integration/native_jobs.c", "integration/native_nonce.c",
                     "integration/native/uart_safe.c", "vendor/new_core.c",
                     "cgminer-overlay.c", "driver-unreviewed.c", "unknown.h"):
            with self.subTest(name=name):
                errors = validate(BASE + name, "00000100 T main\n")
                self.assertIn(f"non-baseline module in production sources: {name}", errors)

    def test_normalized_paths(self):
        self.assertEqual(validate("./" + BASE), [])
        self.assertTrue(validate(BASE + "./reconstruction/support/target256.c"))

    def test_binary_symbols(self):
        self.assertEqual(validate(BASE, "00000100 T main\n00000200 T sha256\n"), [])
        self.assertTrue(validate(BASE, "00000100 T vn135_work_clone_atomic\n"))

    def test_evaluated_make_variables(self):
        # Real GNU make evaluates the list; no substitute cgminer binary is built.
        with tempfile.TemporaryDirectory(prefix="dizzass-source-list-") as tmp:
            root = Path(tmp)
            (root / "Makefile").write_text("core = " + " ".join(sorted(REQUIRED)) +
                                         "\ncgminer_SOURCES = $(core) miner.h\n", encoding="utf-8")
            inspector = Path(__file__).with_name("native-check.mk").resolve()
            cmd = ["make", "-s", "-f", "Makefile", "-f", str(inspector), "dizzass-core-sources"]
            result = subprocess.run(cmd, cwd=root, capture_output=True, text=True, check=True)
            self.assertEqual(validate(result.stdout), [])
            with (root / "Makefile").open("a", encoding="utf-8") as f:
                f.write("cgminer_SOURCES += reconstruction/support/sha256_bytes.c\n")
            result = subprocess.run(cmd, cwd=root, capture_output=True, text=True, check=True)
            self.assertTrue(validate(result.stdout))

    def test_make_evaluated_unreviewed_module_rejected(self):
        with tempfile.TemporaryDirectory(prefix="dizzass-source-list-") as tmp:
            root = Path(tmp)
            (root / "Makefile").write_text("core = " + " ".join(sorted(REQUIRED)) +
                                         "\nextra = integration/native_jobs.c\n"
                                         "cgminer_SOURCES = $(core) miner.h $(extra)\n",
                                         encoding="utf-8")
            inspector = Path(__file__).with_name("native-check.mk").resolve()
            result = subprocess.run(
                ["make", "-s", "-f", "Makefile", "-f", str(inspector),
                 "dizzass-core-sources"], cwd=root, capture_output=True, text=True, check=True)
            self.assertEqual(validate(result.stdout),
                             ["non-baseline module in production sources: integration/native_jobs.c"])

    def test_cli_exit_status(self):
        checker = Path(__file__).with_name("check_native_core.py").resolve()
        with tempfile.TemporaryDirectory(prefix="dizzass-boundary-cli-") as tmp:
            sources = Path(tmp) / "sources.txt"
            for content, expected in ((BASE, 0),
                                      (BASE + "integration/native_jobs.c\n", 1)):
                with self.subTest(expected=expected):
                    sources.write_text(content, encoding="utf-8")
                    result = subprocess.run([sys.executable, "-B", str(checker),
                                             "--sources", str(sources)],
                                            capture_output=True, text=True)
                    self.assertEqual(result.returncode, expected, result.stderr)
                    if expected:
                        self.assertIn("integration/native_jobs.c", result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)

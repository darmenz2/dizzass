#!/usr/bin/env python3
"""Tests for build-boundary validation; not tests of cgminer itself."""
from pathlib import Path
import subprocess
import tempfile
import unittest
from check_native_core import REQUIRED, validate

BASE = "\n".join(sorted(REQUIRED)) + "\nminer.h\n"


class BoundaryTests(unittest.TestCase):
    def test_native_sources(self):
        self.assertEqual(validate(BASE + "driver-icarus.c\nusbutils.c\n"), [])

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
        for name in ("../cgminer.c", "/tmp/cgminer.c", "$(extra_SOURCES)"):
            with self.subTest(name=name):
                self.assertTrue(validate(BASE + name))

    def test_duplicate_entries(self):
        self.assertTrue(validate(BASE + "cgminer.c"))

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


if __name__ == "__main__":
    unittest.main(verbosity=2)

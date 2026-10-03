#!/usr/bin/env python3
"""Actual L16 verifier boundaries and CI triggers; reference ELF is data only."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = (ROOT / "research/vnishnet-t21-aml-nand-1.3.5/"
            "30-reconstructed-unverified/bm1368-startup-registers")
ORIGINAL_WORKFLOW = ".github/workflows/bm1368-startup-registers-research.yml"
CURRENT_WORKFLOW = ".github/workflows/bm1368-startup-registers-verifier-135.yml"
CONTROL = "integration/tests/test_bm1368_startup_registers_verifier_135.py"



def workflow_patterns(relative):
    text = (ROOT / relative).read_text()
    # The two workflows use only this explicit, quoted paths-list form.
    # Reject a missing/changed event stanza rather than infer broad triggers.
    marker = "  pull_request:\n    branches: [work/reconstruction]\n    paths:\n"
    if text.count(marker) != 1 or text.count("  workflow_dispatch:\n") != 1:
        raise ValueError("workflow trigger structure")
    block = text.split(marker, 1)[1].split("  workflow_dispatch:\n", 1)[0]
    lines = block.splitlines()
    if not lines or any(re.fullmatch(r"      - '[^']+'", line) is None
                        for line in lines):
        raise ValueError("workflow paths structure")
    return [line[9:-1] for line in lines]


def matches(path, pattern):
    # Only * and ** appear in these lists. A single * cannot cross a slash.
    expression = re.escape(pattern).replace(r"\*\*", ".*").replace(r"\*", "[^/]*")
    return re.fullmatch(expression, path) is not None


class ActualVerifierTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.root = self.base / "root"
        self.root.mkdir()
        self.manifest = json.loads((EVIDENCE / "static-witness.json").read_text())
        self.pins = self.manifest["source_sha256"]
        self.reference = self.manifest["reference"]["path"]
        for relative in [*self.pins, self.reference]:
            target = self.root / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(ROOT / relative, target)

    def verify(self, directory=EVIDENCE):
        # A fresh interpreter exercises real CLI exit behavior and prevents a
        # tools.elf32 import cached for one fixture from leaking into another.
        command = [sys.executable]
        if sys.flags.optimize:
            command.append("-O")
        command += ["-B", str(directory / "verify.py"), "--root", str(self.root),
                    "--with-reference"]
        result = subprocess.run(command, capture_output=True, text=True, timeout=30)
        if result.returncode:
            self.assertEqual(result.returncode, 1, result.stderr)
            self.assertEqual(result.stdout, "")
            final_line = result.stderr.splitlines()[-1]
            self.assertTrue(final_line.startswith("ValueError: "), result.stderr)
            raise ValueError(final_line.removeprefix("ValueError: "))
        self.assertEqual(result.stderr, "")
        prefix = "STARTUP_REGISTERS_STATIC_PASS "
        self.assertTrue(result.stdout.startswith(prefix), result.stdout)
        return json.loads(result.stdout[len(prefix):])

    def test_actual_verifier_accepts_complete_current_inputs(self):
        self.assertEqual(self.verify(), {
            "regions": 33, "bytes": 3605, "words": 135,
            "direct_call_sites": 14, "constructor_slots": 4,
            "source_pins": 19, "reference_read_as_data": True,
            "original_execution": False})

    def test_every_pinned_source_change_is_rejected(self):
        self.assertEqual(len(self.pins), 19)
        for relative in self.pins:
            path = self.root / relative
            original = path.read_bytes()
            with self.subTest(relative=relative):
                path.write_bytes(original + b"\n")
                try:
                    with self.assertRaisesRegex(ValueError, "^source hash: " + re.escape(relative) + "$"):
                        self.verify()
                finally:
                    path.write_bytes(original)

    def test_every_missing_pinned_source_is_rejected(self):
        for relative in self.pins:
            path = self.root / relative
            original = path.read_bytes()
            with self.subTest(relative=relative):
                path.unlink()
                try:
                    with self.assertRaisesRegex(ValueError, "^missing/nonregular file: " + re.escape(relative) + "$"):
                        self.verify()
                finally:
                    path.write_bytes(original)

    def test_every_symlinked_pinned_source_is_rejected(self):
        for relative in self.pins:
            path = self.root / relative
            original = path.read_bytes()
            copy = self.base / "unaltered-source"
            copy.write_bytes(original)
            with self.subTest(relative=relative):
                path.unlink()
                path.symlink_to(copy)
                try:
                    with self.assertRaisesRegex(ValueError, "^symlink source$"):
                        self.verify()
                finally:
                    path.unlink()
                    path.write_bytes(original)

    def test_nonregular_pinned_source_is_rejected(self):
        relative = "libbitmain/src/chip/chip1368-startup-registers.c"
        path = self.root / relative
        path.unlink()
        path.mkdir()
        with self.assertRaisesRegex(ValueError, "^missing/nonregular file: " + re.escape(relative) + "$"):
            self.verify()

    def test_symlinked_source_parent_is_rejected(self):
        path = self.root / "integration"
        copy = self.base / "unaltered-integration"
        path.rename(copy)
        path.symlink_to(copy, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "^symlink source$"):
            self.verify()

    def test_modified_complete_elf_is_rejected(self):
        path = self.root / self.reference
        original = bytearray(path.read_bytes())
        original[4096] ^= 1
        path.write_bytes(original)
        with self.assertRaisesRegex(ValueError, "^complete ELF identity$"):
            self.verify()

    def test_truncated_elf_is_rejected(self):
        path = self.root / self.reference
        path.write_bytes(path.read_bytes()[:-1])
        with self.assertRaisesRegex(ValueError, "^complete ELF identity$"):
            self.verify()

    def test_missing_elf_is_rejected(self):
        (self.root / self.reference).unlink()
        with self.assertRaisesRegex(ValueError, "^missing/nonregular file: reference/cgminer.vendor.elf$"):
            self.verify()

    def test_nonregular_elf_is_rejected(self):
        path = self.root / self.reference
        path.unlink()
        path.mkdir()
        with self.assertRaisesRegex(ValueError, "^missing/nonregular file: reference/cgminer.vendor.elf$"):
            self.verify()

    def test_symlinked_elf_is_rejected(self):
        path = self.root / self.reference
        copy = self.base / "unaltered-elf"
        path.rename(copy)
        path.symlink_to(copy)
        with self.assertRaisesRegex(ValueError, "^symlink source$"):
            self.verify()

    def test_symlinked_reference_parent_is_rejected(self):
        path = self.root / "reference"
        copy = self.base / "unaltered-reference"
        path.rename(copy)
        path.symlink_to(copy, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "^symlink source$"):
            self.verify()

    def evidence_copy(self):
        directory = self.root / EVIDENCE.relative_to(ROOT)
        directory.mkdir(parents=True)
        for name in ("verify.py", "static-witness.json", "original-code.asm"):
            shutil.copyfile(EVIDENCE / name, directory / name)
        return directory

    def test_actual_verifier_rejects_mutated_frozen_witness(self):
        directory = self.evidence_copy()
        path = directory / "static-witness.json"
        path.write_bytes(path.read_bytes() + b" ")
        with self.assertRaisesRegex(ValueError, "^frozen witness hash$"):
            self.verify(directory)

    def test_actual_verifier_rejects_mutated_disassembly(self):
        directory = self.evidence_copy()
        path = directory / "original-code.asm"
        path.write_bytes(path.read_bytes() + b"\n")
        with self.assertRaisesRegex(ValueError, "^disassembly hash$"):
            self.verify(directory)

    def test_actual_verifier_rejects_missing_evidence_files(self):
        directory = self.evidence_copy()
        for name in ("static-witness.json", "original-code.asm"):
            path = directory / name
            original = path.read_bytes()
            with self.subTest(name=name):
                path.unlink()
                try:
                    with self.assertRaisesRegex(ValueError, "^missing/nonregular file: " + re.escape(name) + "$"):
                        self.verify(directory)
                finally:
                    path.write_bytes(original)

    def test_actual_verifier_rejects_symlinked_evidence_files(self):
        directory = self.evidence_copy()
        for name in ("static-witness.json", "original-code.asm"):
            path = directory / name
            original = path.read_bytes()
            with self.subTest(name=name):
                path.unlink()
                path.symlink_to(EVIDENCE / name)
                try:
                    with self.assertRaisesRegex(ValueError, "^symlink source$"):
                        self.verify(directory)
                finally:
                    path.unlink()
                    path.write_bytes(original)


class WorkflowTriggerTests(unittest.TestCase):
    def test_original_and_supplemental_dependency_closure(self):
        manifest = json.loads((EVIDENCE / "static-witness.json").read_text())
        inputs = set(manifest["source_sha256"])
        inputs.add(manifest["reference"]["path"])
        inputs.update(str(path.relative_to(ROOT)) for path in EVIDENCE.iterdir()
                      if path.is_file())
        for workflow in (ORIGINAL_WORKFLOW, CURRENT_WORKFLOW):
            patterns = workflow_patterns(workflow)
            expected = inputs | ({CURRENT_WORKFLOW, CONTROL}
                                 if workflow == CURRENT_WORKFLOW else set())
            for relative in sorted(expected):
                with self.subTest(workflow=workflow, relative=relative):
                    self.assertTrue(any(matches(relative, pattern) for pattern in patterns), relative)

    def test_supplemental_ci_runs_both_python_modes(self):
        text = (ROOT / CURRENT_WORKFLOW).read_text()
        for command in ("python3 -B " + CONTROL, "python3 -O -B " + CONTROL):
            self.assertIn(command + "\n", text)
        self.assertIn("permissions:\n  contents: read\n", text)
        self.assertIn("persist-credentials: false\n", text)


if __name__ == "__main__":
    unittest.main(verbosity=2)

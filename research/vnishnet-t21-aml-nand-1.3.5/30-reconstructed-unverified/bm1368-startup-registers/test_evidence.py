#!/usr/bin/env python3
"""Static verifier controls only; no original instruction or hardware execution."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
import verify as v


class EvidenceTests(unittest.TestCase):
    def setUp(self):
        self.m = json.loads((v.HERE / "static-witness.json").read_text())

    def reject(self, edit):
        m = copy.deepcopy(self.m)
        edit(m)
        with self.assertRaises((ValueError, KeyError, TypeError)):
            v.validate_document(m)

    def test_valid_document(self):
        self.assertEqual(len(v.validate_document(self.m)), 33)

    def test_complete_static_reference(self):
        result = v.verify(with_reference=True)
        self.assertEqual(result["constructor_slots"], 4)
        self.assertFalse(result["original_execution"])

    def test_schema(self):
        self.reject(lambda m: m.update(schema=2))

    def test_scope(self):
        for name in ("hardware", "original_execution", "automatic_equivalence_proof"):
            with self.subTest(name=name):
                self.reject(lambda m: m.update({name: True}))

    def test_wrong_reference(self):
        self.reject(lambda m: m["reference"].update(size=1))

    def test_wrong_base(self):
        self.reject(lambda m: m.update(base_commit="0" * 40))

    def test_region_byte_changed(self):
        self.reject(lambda m: m["regions"][0].update(hex="00" + m["regions"][0]["hex"][2:]))

    def test_region_removed(self):
        self.reject(lambda m: m["regions"].pop())

    def test_region_duplicated(self):
        self.reject(lambda m: m["regions"][1].update(name=m["regions"][0]["name"]))

    def test_region_overlapped(self):
        self.reject(lambda m: m["regions"][1].update(va=m["regions"][0]["va"]))

    def test_code_misaligned(self):
        self.reject(lambda m: m["regions"][0].update(va=m["regions"][0]["va"] + 1))

    def test_instruction_fact(self):
        self.reject(lambda m: m["word_facts"].update({"0xe35d0": "0xe2010003"}))

    def test_instruction_fact_removed(self):
        self.reject(lambda m: m["word_facts"].pop("0xe35d0"))

    def test_branch_target(self):
        self.reject(lambda m: m["branches"][0].update(target=0xe4a78))

    def test_pc_literal(self):
        self.reject(lambda m: m["pc_targets"][0].update(literal=0xe3708))

    def test_pc_target(self):
        self.reject(lambda m: m["pc_targets"][0].update(target=0x5eb443))

    def test_constructor_identity(self):
        self.reject(lambda m: m["constructor_slots"][0].update(method_identity="0xe35c0"))

    def test_constructor_got(self):
        self.reject(lambda m: m["constructor_slots"][0].update(got_address="0x5df214"))

    def test_constructor_offset(self):
        self.reject(lambda m: m["constructor_slots"][0].update(output_offset=0x90))

    def test_string_key(self):
        self.reject(lambda m: m["strings"][3].update(key=31))

    def test_string_text(self):
        self.reject(lambda m: m["strings"][3].update(text="a different message"))

    def test_parity_site(self):
        self.reject(lambda m: m["parity_sites"][0].update(multiply=0xe30a8))

    def test_frozen_manifest_and_assembly(self):
        with tempfile.TemporaryDirectory() as td:
            dest = Path(td)
            for name in ("static-witness.json", "original-code.asm"):
                (dest / name).write_bytes((v.HERE / name).read_bytes())
            (dest / "static-witness.json").write_bytes((dest / "static-witness.json").read_bytes() + b" ")
            with self.assertRaisesRegex(ValueError, "frozen witness"):
                v.verify(directory=dest)
            (dest / "static-witness.json").write_bytes((v.HERE / "static-witness.json").read_bytes())
            (dest / "original-code.asm").write_text("tampered")
            with self.assertRaisesRegex(ValueError, "disassembly"):
                v.verify(directory=dest)

    def test_source_hash(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "unit.c").write_text("int x;\n")
            pins = {"unit.c": v.sha((root / "unit.c").read_bytes())}
            v.validate_sources(root, pins)
            (root / "unit.c").write_text("int y;\n")
            with self.assertRaisesRegex(ValueError, "source hash"):
                v.validate_sources(root, pins)

    def test_missing_nonregular_symlink_and_traversal(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / "real").mkdir()
            (root / "real/unit.c").write_text("int x;\n")
            (root / "linked").symlink_to(root / "real", target_is_directory=True)
            (root / "link.c").symlink_to(root / "real/unit.c")
            for rel in ("absent", "real", "link.c", "linked/unit.c", "../unit.c", "/tmp/unit.c", "a\\b"):
                with self.subTest(rel=rel), self.assertRaises(ValueError):
                    v.ordinary_file(root, rel)


if __name__ == "__main__":
    unittest.main(verbosity=2)

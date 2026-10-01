"""Static data controls, not execution of original instructions."""
import importlib.util
import json
import pathlib
import unittest

HERE = pathlib.Path(__file__).resolve().parent.parent
SPEC = importlib.util.spec_from_file_location('uart_evidence', HERE/'verify_evidence.py')
MODULE = importlib.util.module_from_spec(SPEC); SPEC.loader.exec_module(MODULE)


class StaticEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.maps = {name:MODULE.mapped_source(name)[0] for name in MODULE.SOURCES}
        self.provenance = json.loads((HERE/'evidence/string-provenance.json').read_text())

    def put(self, name, at, word):
        for i, byte in enumerate(word.to_bytes(4,'little')): self.maps[name][at+i] = byte

    def rejected(self):
        with self.assertRaises(ValueError): MODULE.verify_semantics(self.maps,self.provenance)

    def test_verified_frozen_bytes(self):
        MODULE.verify_semantics(self.maps,self.provenance)

    def test_wrong_limit(self):
        self.put('hwscan',0x10e220,0xe3500003); self.rejected()

    def test_signed_condition(self):
        self.put('hwscan',0x10e224,0xc59f0018); self.rejected()

    def test_table_swap(self):
        self.put('cgminer',0x5db408,0x5ee826); self.rejected()

    def test_nonempty_invalid_result(self):
        self.maps['hwscan'][0x48e00e] = ord('x'); self.rejected()

    def test_wrong_xor_key(self):
        self.provenance['strings']['cgminer'][0]['xor_key'] = 0x41; self.rejected()

    def test_wrong_path_bytes(self):
        self.maps['hwscan'][0x4821d1] = ord('9'); self.rejected()

    def test_wrong_constructor_slot(self):
        self.put('cgminer',0x5db060,0x11c2bc); self.rejected()

    def test_wrong_decode_length(self):
        self.put('cgminer',0x11c4d8,0xe352000a); self.rejected()

    def test_wrong_callback(self):
        self.put('hwscan',0x4af640,0x10e224); self.rejected()

    def test_wrong_thunk(self):
        self.put('cgminer',0xfef44,0xe12fff10); self.rejected()

    def test_wrong_caller_target(self):
        self.put('cgminer',0xc34c8,0xeb00ee9c); self.rejected()


if __name__ == '__main__': unittest.main()

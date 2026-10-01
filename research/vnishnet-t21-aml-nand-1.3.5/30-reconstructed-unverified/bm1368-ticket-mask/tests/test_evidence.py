#!/usr/bin/env python3
"""Focused static-proof integrity tests in Python normal and optimized modes.

Only this host verifier is launched. Corrupted JSON/ELF data fixtures are never
executed as instructions or treated as usable firmware, models or pointers.
"""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
VERIFIER = ROOT/'verify_evidence.py'
BASE = json.loads((ROOT/'static-witness.json').read_text())
PINS = json.loads((ROOT/'static-pins.json').read_text())


def region(witness, identifier, source='cgminer'):
    return next(r for r in witness['sources'][source]['regions'] if r['id'] == identifier)


def corrupt_word(witness, address, source='cgminer', rehash=True):
    item = next(r for r in witness['sources'][source]['regions']
                if r['va'] <= address < r['va']+r['size'])
    data = bytearray.fromhex(item['bytes_hex'])
    data[address-item['va']] ^= 1
    item['bytes_hex'] = data.hex()
    if rehash:
        item['sha256'] = hashlib.sha256(data).hexdigest()


class EvidenceTests(unittest.TestCase):
    def check_verifier(self, arguments=(), success=False):
        for optimized in (False, True):
            with self.subTest(optimized=optimized):
                command = [sys.executable]+(['-O'] if optimized else [])+[str(VERIFIER)]+list(arguments)
                result = subprocess.run(command,text=True,capture_output=True,check=False)
                if success:
                    self.assertEqual(result.returncode,0,result.stderr)
                    report = json.loads(result.stdout)
                    self.assertTrue(report['static_witness_verified'])
                    self.assertEqual(report['method_code_bytes_per_elf'],208)
                    self.assertEqual(report['method_literal_bytes_per_elf'],16)
                    self.assertEqual(report['logger_strings'],4)
                    self.assertEqual(report['normalized_method_instructions'],52)
                    self.assertTrue(report['cgminer_startup_caller_witnessed'])
                    self.assertFalse(report['hwscan_startup_caller_claimed'])
                    self.assertFalse(report['firmware_executed'])
                    self.assertFalse(report['instruction_interpreter_used'])
                else:
                    self.assertNotEqual(result.returncode,0,'tampered evidence accepted')
                    self.assertIn('static witness rejected:',result.stderr)

    def reject_change(self, change):
        witness = copy.deepcopy(BASE)
        change(witness)
        with tempfile.TemporaryDirectory(prefix='ticket-mask-proof-') as directory:
            path = Path(directory)/'witness.json'
            path.write_text(json.dumps(witness))
            self.check_verifier(['--witness',str(path)])

    def test_reviewed_witness_without_originals(self):
        self.check_verifier(success=True)

    def test_exact_body_pool_and_input_boundaries(self):
        changes = [
            lambda w: region(w,'ticket-mask-code').__setitem__('size',212),
            lambda w: region(w,'ticket-mask-pool').__setitem__('kind','code'),
            lambda w: w['sources']['cgminer'].__setitem__('elf_sha256','0'*64),
            lambda w: w['sources']['hwscan']['regions'].pop(),
        ]
        for i,change in enumerate(changes):
            with self.subTest(boundary=i): self.reject_change(change)

    def test_writer_arguments_branch_and_fresh_index_words(self):
        # Raw bytes and attacker-updated own digest cannot change reviewed pins.
        for address in (0xe2170,0xe2190,0xe2198,0xe21a8,0xe21b0,0xe21c4,0xe21f0):
            with self.subTest(address=hex(address)):
                self.reject_change(lambda w,a=address: corrupt_word(w,a))
        self.reject_change(lambda w: corrupt_word(w,0xe21a8,rehash=False))

    def test_four_logger_strings_and_direct_initializer(self):
        self.reject_change(lambda w: w['strings'][3].__setitem__('length',42))
        self.reject_change(lambda w: w['strings'][1].__setitem__('key',0))
        self.reject_change(lambda w: w['strings'][2].__setitem__('text','other function'))
        self.reject_change(lambda w: corrupt_word(w,0xe56d4))
        self.reject_change(lambda w: corrupt_word(w,0x47e2bc,'hwscan'))
        self.reject_change(lambda w: w['sources']['cgminer']['literal_references'][0].__setitem__('target',0))

    def test_constructor_slot_and_got(self):
        self.reject_change(lambda w: w['sources']['cgminer']['slot'].__setitem__('offset',36))
        self.reject_change(lambda w: corrupt_word(w,0x5df8e8))

    def test_actual_caller_owner_and_read_lifetimes(self):
        for address in (0x735fc,0x82d60,0x55938,0x55de4,0x55c28,0x562a8,0x562b8):
            with self.subTest(address=hex(address)):
                self.reject_change(lambda w,a=address: corrupt_word(w,a))
        self.reject_change(lambda w: w['proof']['caller'].__setitem__('B1','Always identical to B0'))
        self.reject_change(lambda w: w['proof']['caller'].__setitem__('final','Always writes all ones'))

    def test_proof_qualifiers_edges_and_operand_metadata(self):
        self.reject_change(lambda w: w['proof']['domain'].clear())
        self.reject_change(lambda w: w['proof']['nonclaims'].clear())
        self.reject_change(lambda w: w['proof']['dependency'].__setitem__('scope','Whole dispatcher reproved'))
        self.reject_change(lambda w: w['proof']['direct_edges'][0].__setitem__('target',0))
        self.reject_change(lambda w: w['sources']['hwscan']['operands'][0].__setitem__(3,'invented'))

    def test_strict_schema_and_json(self):
        self.reject_change(lambda w: w.__setitem__('schema',True))
        self.reject_change(lambda w: w['proof']['caller'].__setitem__('unreviewed','new claim'))
        self.reject_change(lambda w: w['sources']['cgminer']['regions'].reverse())
        canonical = (ROOT/'static-witness.json').read_text()
        texts = [canonical.replace('"schema": 1,','"schema": 1, "schema": 1,',1),
                 canonical.replace('"schema": 1,','"schema": NaN,',1)]
        for text in texts:
            with tempfile.TemporaryDirectory(prefix='ticket-mask-json-') as directory:
                path = Path(directory)/'invalid.json'; path.write_text(text)
                self.check_verifier(['--witness',str(path)])

    def test_pins_cannot_reauthorize_changed_metadata(self):
        witness = copy.deepcopy(BASE)
        witness['proof']['caller']['B1'] = 'Always identical to B0'
        metadata = copy.deepcopy(witness)
        for source in metadata['sources'].values():
            for item in source['regions']: del item['bytes_hex']
        pins = copy.deepcopy(PINS)
        pins['metadata_sha256'] = hashlib.sha256(json.dumps(metadata,sort_keys=True,
            separators=(',',':'),ensure_ascii=True,allow_nan=False).encode('ascii')).hexdigest()
        with tempfile.TemporaryDirectory(prefix='ticket-mask-pins-') as directory:
            witness_path = Path(directory)/'witness.json'; witness_path.write_text(json.dumps(witness))
            pins_path = Path(directory)/'pins.json'; pins_path.write_text(json.dumps(pins))
            self.check_verifier(['--witness',str(witness_path),'--pins',str(pins_path)])

    def test_optional_original_identity_refusal(self):
        with tempfile.TemporaryDirectory(prefix='ticket-mask-original-data-') as directory:
            path = Path(directory)/'invalid-data.bin'; path.write_bytes(b'not an ELF')
            for source in ('cgminer','hwscan'):
                self.check_verifier(['--'+source,str(path)])
            # Same-size sparse data must still fail the complete original hash.
            with path.open('wb') as stream:
                stream.truncate(BASE['sources']['cgminer']['elf_size'])
            self.check_verifier(['--cgminer',str(path)])


if __name__ == '__main__':
    unittest.main(verbosity=2)

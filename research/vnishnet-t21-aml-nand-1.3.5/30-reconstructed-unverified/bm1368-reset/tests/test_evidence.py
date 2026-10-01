#!/usr/bin/env python3
"""Static evidence acceptance and tamper refusal, in Python normal and -O modes.

Only the host verifier is launched. Temporary files are deliberately corrupted
data fixtures; no original ELF, original instruction, hardware, or C projection
is executed by this test.
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
VERIFIER = ROOT / 'verify_evidence.py'
BASE = json.loads((ROOT / 'static-witness.json').read_text())
PINS = json.loads((ROOT / 'static-pins.json').read_text())


def region(witness, identifier, source='cgminer'):
    return next(item for item in witness['sources'][source]['regions'] if item['id']==identifier)


def mutate_word(witness, identifier, offset=0, source='cgminer', rehash=False):
    item = region(witness,identifier,source)
    data = bytearray.fromhex(item['bytes_hex'])
    data[offset] ^= 1
    item['bytes_hex'] = data.hex()
    if rehash:
        item['sha256'] = hashlib.sha256(data).hexdigest()


def change_instruction(witness, address):
    item = region(witness,'reset-code')
    mutate_word(witness,'reset-code',address-item['va'],rehash=True)


class EvidenceTests(unittest.TestCase):
    def run_verifier(self, extra=(), expected_success=False):
        for optimized in (False,True):
            with self.subTest(optimized=optimized):
                command = [sys.executable] + (['-O'] if optimized else []) + [str(VERIFIER)] + list(extra)
                result = subprocess.run(command,text=True,capture_output=True,check=False)
                if expected_success:
                    self.assertEqual(result.returncode,0,result.stderr)
                    report = json.loads(result.stdout)
                    self.assertTrue(report['static_witness_verified'])
                    self.assertFalse(report['firmware_executed'])
                    self.assertFalse(report['instruction_interpreter_used'])
                    self.assertEqual(report['ordinary_sites_per_elf'],24)
                    self.assertEqual(report['unreachable_cgminer_sites'],4)
                else:
                    self.assertNotEqual(result.returncode,0,'tampered evidence was accepted')
                    self.assertIn('static witness rejected:',result.stderr)

    def reject_mutation(self, mutate):
        witness = copy.deepcopy(BASE)
        mutate(witness)
        with tempfile.TemporaryDirectory(prefix='bm1368-static-tamper-') as directory:
            path = Path(directory)/'tampered-witness.json'
            path.write_text(json.dumps(witness))
            self.run_verifier(['--witness',str(path)])

    def test_canonical_witness(self):
        self.run_verifier(expected_success=True)

    def test_code_changed_without_digest(self):
        self.reject_mutation(lambda w: mutate_word(w,'reset-code'))

    def test_code_and_own_digest_changed(self):
        self.reject_mutation(lambda w: mutate_word(w,'reset-code',rehash=True))

    def test_range_inventory(self):
        def remove(w):
            w['sources']['cgminer']['regions'].pop()
        def duplicate(w):
            w['sources']['cgminer']['regions'].append(copy.deepcopy(w['sources']['cgminer']['regions'][-1]))
        def overlap(w):
            w['sources']['cgminer']['regions'][1]['va'] = w['sources']['cgminer']['regions'][0]['va']
        def reverse(w):
            w['sources']['cgminer']['regions'].reverse()
        for mutate in (remove,duplicate,overlap,reverse):
            with self.subTest(mutation=mutate.__name__):
                self.reject_mutation(mutate)

    def test_wrong_range_extent_and_name(self):
        for key,value in [('va',0xe1b68),('size',1332),('id','other-reset-code')]:
            with self.subTest(field=key):
                self.reject_mutation(lambda w,k=key,v=value: region(w,'reset-code').__setitem__(k,v))

    def test_hex_schema(self):
        for hex_data in ('zz','F04F2DE9','0'):
            with self.subTest(hex_data=hex_data):
                self.reject_mutation(lambda w,v=hex_data: region(w,'reset-code').__setitem__('bytes_hex',v))

    def test_whole_elf_provenance(self):
        for key,value in [('elf_size',1),('elf_sha256','0'*64)]:
            with self.subTest(field=key):
                self.reject_mutation(lambda w,k=key,v=value: w['sources']['cgminer'].__setitem__(k,v))

    def test_call_target_and_inventory(self):
        self.reject_mutation(lambda w: w['sources']['cgminer']['calls'][0].__setitem__('target',0))
        self.reject_mutation(lambda w: w['sources']['hwscan']['calls'].pop())

    def test_branch_target_and_operand_annotation(self):
        self.reject_mutation(lambda w: w['sources']['cgminer']['branches'][0].__setitem__('target',0))
        self.reject_mutation(lambda w: w['sources']['cgminer']['operands'][0].__setitem__(3,'invented operands'))

    def test_string_key_length_and_text(self):
        for key,value in [('key',0),('length',41),('text','wrong soft-reset text')]:
            with self.subTest(field=key):
                self.reject_mutation(lambda w,k=key,v=value: w['strings'][-1].__setitem__(k,v))

    def test_string_initializer_and_data(self):
        self.reject_mutation(lambda w: w['strings'][-1].__setitem__('load',0xe5fd0))
        self.reject_mutation(lambda w: mutate_word(w,'string-soft-reset',rehash=True))
        self.reject_mutation(lambda w: mutate_word(w,'string-soft-reset',source='hwscan',rehash=True))
        self.reject_mutation(lambda w: w['strings'].pop())

    def test_slot_offset_and_got(self):
        self.reject_mutation(lambda w: w['sources']['cgminer']['slot'].__setitem__('offset',24))
        self.reject_mutation(lambda w: mutate_word(w,'slot-got',rehash=True))

    def test_selected_semantic_words(self):
        # Mode, conditional branch, R3 zeroing, W6 bit field, wait and return.
        for address in (0xe1be4,0xe1d24,0xe1c14,0xe1f78,0xe2088,0xe2090):
            with self.subTest(address=hex(address)):
                self.reject_mutation(lambda w,a=address: change_instruction(w,a))

    def test_proof_masks_and_zero_output_metadata(self):
        self.reject_mutation(lambda w: w['proof']['write_values'][5].__setitem__('expression','pulse'))
        self.reject_mutation(lambda w: w['proof']['read_sites'][2]['cgminer'].__setitem__(0,0xe1c0c))

    def test_parity_metadata_and_unreachable_sites(self):
        self.reject_mutation(lambda w: w['proof']['opaque_conditions'][0].__setitem__('mul',0xe1c70))
        self.reject_mutation(lambda w: w['proof'].__setitem__('parity_lemma','assume a sampled result'))
        self.reject_mutation(lambda w: w['proof']['unreachable_cgminer'].pop())
        self.reject_mutation(lambda w: w['proof']['ordinary_calls'].pop())

    def test_logs_field_reload_and_return_metadata(self):
        self.reject_mutation(lambda w: w['proof']['logs'][6].__setitem__('cgminer_index_load',0xe1fbc))
        self.reject_mutation(lambda w: w['proof']['logs'][6].__setitem__('line',387))
        self.reject_mutation(lambda w: w['proof']['delays']['sequence'].__setitem__(-1,5))
        self.reject_mutation(lambda w: w['proof']['returns']['cgminer'].__setitem__(0,0xe208c))

    def test_strict_schema(self):
        self.reject_mutation(lambda w: w.__setitem__('unknown',1))
        self.reject_mutation(lambda w: w.__setitem__('schema',True))
        self.reject_mutation(lambda w: w['proof']['logs'][0].__setitem__('line',True))
        self.reject_mutation(lambda w: w['sources']['cgminer']['calls'][0].__setitem__('extra','field'))

    def test_duplicate_json_key(self):
        text = (ROOT/'static-witness.json').read_text()
        text = text.replace('"schema": 1,','"schema": 1, "schema": 1,',1)
        with tempfile.TemporaryDirectory(prefix='bm1368-static-duplicate-') as directory:
            path = Path(directory)/'duplicate-key.json'
            path.write_text(text)
            self.run_verifier(['--witness',str(path)])

    def test_changed_pins_cannot_reauthorize_tamper(self):
        pins = copy.deepcopy(PINS)
        pins['metadata_sha256'] = '0'*64
        with tempfile.TemporaryDirectory(prefix='bm1368-static-pins-') as directory:
            path = Path(directory)/'changed-pins.json'
            path.write_text(json.dumps(pins))
            self.run_verifier(['--pins',str(path)])

    def test_optional_original_size_and_hash(self):
        with tempfile.TemporaryDirectory(prefix='bm1368-static-invalid-elf-') as directory:
            path = Path(directory)/'deliberately-invalid-data.bin'
            path.write_bytes(b'not an original ELF')
            for name in ('cgminer','hwscan'):
                with self.subTest(original=name,corruption='size'):
                    self.run_verifier(['--'+name,str(path)])
            # A sparse, same-size invalid data file proves the complete hash
            # check is required. This file is never labeled valid evidence.
            with path.open('wb') as stream:
                stream.truncate(BASE['sources']['cgminer']['elf_size'])
            self.run_verifier(['--cgminer',str(path)])


if __name__ == '__main__':
    unittest.main(verbosity=2)

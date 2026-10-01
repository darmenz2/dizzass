#!/usr/bin/env python3
"""Focused public static-integrity tests, normal and -O host Python.

Only the authored host verifier runs. Corrupted JSON/ELF/source-byte fixtures
are data, never executable firmware, an original-instruction oracle or C code.
"""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
VERIFIER=ROOT/'verify_evidence.py'
BASE=json.loads((ROOT/'static-witness.json').read_text())
PINS=json.loads((ROOT/'static-pins.json').read_text())


def region(witness,identifier,source='cgminer'):
    return next(r for r in witness['sources'][source]['regions'] if r['id']==identifier)


def corrupt_word(witness,address,source='cgminer',rehash=True):
    item=next(r for r in witness['sources'][source]['regions'] if r['va']<=address<r['va']+r['size'])
    raw=bytearray.fromhex(item['bytes_hex']);raw[address-item['va']]^=1
    item['bytes_hex']=raw.hex()
    if rehash:item['sha256']=hashlib.sha256(raw).hexdigest()


class EvidenceTests(unittest.TestCase):
    def check(self,arguments=(),success=False,reason=None):
        for optimized in (False,True):
            with self.subTest(optimized=optimized):
                command=[sys.executable]+(['-O'] if optimized else [])+[str(VERIFIER)]+list(arguments)
                result=subprocess.run(command,text=True,capture_output=True,check=False)
                if success:
                    self.assertEqual(result.returncode,0,result.stderr)
                    report=json.loads(result.stdout)
                    self.assertTrue(report['static_witness_verified'])
                    self.assertEqual(report['method_code_bytes'],{'cgminer':264,'hwscan':144})
                    self.assertEqual(report['method_pool_bytes'],{'cgminer':24,'hwscan':16})
                    self.assertEqual(report['ordinary_writer_calls'],1)
                    self.assertEqual(report['logger_strings'],4)
                    self.assertEqual(report['l11_dependency_files_verified'],3)
                    self.assertEqual(report['runtime_source_identities_verified'],2)
                    self.assertFalse(report['method_body_identity_claimed'])
                    self.assertFalse(report['full_coordinator_claimed'])
                    self.assertFalse(report['hwscan_startup_caller_claimed'])
                    self.assertFalse(report['firmware_executed'])
                    self.assertFalse(report['instruction_interpreter_used'])
                else:
                    self.assertNotEqual(result.returncode,0,'altered evidence accepted')
                    self.assertIn('static witness rejected:',result.stderr)
                    if reason:self.assertIn(reason,result.stderr)

    def reject(self,change):
        witness=copy.deepcopy(BASE);change(witness)
        with tempfile.TemporaryDirectory(prefix='sweep-proof-') as directory:
            path=Path(directory)/'witness.json';path.write_text(json.dumps(witness))
            self.check(['--witness',str(path)])

    def test_reviewed_packet_without_original_files(self):
        self.check(success=True)

    def test_body_pool_boundary_and_provenance(self):
        changes=[lambda w:region(w,'sweep-code').__setitem__('size',268),
                 lambda w:region(w,'sweep-pool').__setitem__('kind','code'),
                 lambda w:w['sources']['hwscan'].__setitem__('elf_sha256','0'*64),
                 lambda w:w['sources']['hwscan']['regions'].pop()]
        for change in changes:self.reject(change)

    def test_argument_mask_writer_status_and_late_index_bytes(self):
        for source,address in [('cgminer',0xe330c),('cgminer',0xe331c),
                               ('cgminer',0xe332c),('cgminer',0xe3378),
                               ('cgminer',0xe3390),('cgminer',0xe33b0),
                               ('hwscan',0xf30f0),('hwscan',0xf3138)]:
            with self.subTest(source=source,address=hex(address)):
                self.reject(lambda w,s=source,a=address:corrupt_word(w,a,s))
        self.reject(lambda w:corrupt_word(w,0xe332c,rehash=False))

    def test_ordinary_parity_and_one_writer_contract(self):
        self.reject(lambda w:corrupt_word(w,0xe3340))
        self.reject(lambda w:w['sources']['cgminer']['method_calls'][1].__setitem__('ordinary',True))
        self.reject(lambda w:w['proof']['method_contract'].__setitem__('ordinary_writer_calls',2))
        self.reject(lambda w:w['proof']['ordinary_parity']['method_edges'][0].__setitem__(1,0xe3350))

    def test_logger_literals_and_direct_initializer_count(self):
        self.reject(lambda w:w['strings'][3].__setitem__('length',43))
        self.reject(lambda w:w['strings'][3].__setitem__('key',0))
        self.reject(lambda w:w['strings'][2].__setitem__('text','unknown'))
        self.reject(lambda w:corrupt_word(w,0xe5684))
        self.reject(lambda w:corrupt_word(w,0x47e292,'hwscan'))
        self.reject(lambda w:w['sources']['cgminer']['literal_references'][0].__setitem__('target',0))

    def test_sweep_and_pulse_constructor_associations(self):
        self.reject(lambda w:w['sources']['cgminer']['slots'][0].__setitem__('offset',0x78))
        self.reject(lambda w:corrupt_word(w,0x5ded70))
        self.reject(lambda w:w['sources']['hwscan']['slots'][1].__setitem__('method',0xf30d4))

    def test_caller_gate_arguments_failure_and_ordering(self):
        for address in (0x55ff4,0x56024,0x56028,0x5602c,0x56078,0x56118,0x56204):
            with self.subTest(address=hex(address)):
                self.reject(lambda w,a=address:corrupt_word(w,a))
        self.reject(lambda w:w['proof']['caller'].__setitem__('flag_origin','read the live flag at call time'))
        self.reject(lambda w:w['proof']['lifetime_review'].__setitem__('owner_stores',[]))
        self.reject(lambda w:w['proof']['ordering'].__setitem__('persistence','sweep value always persists'))

    def test_bound_l11_dependency_drift(self):
        dependency=BASE['dependencies']['l11']
        self.reject(lambda w:w['dependencies']['l11']['files'][1].__setitem__('sha256','0'*64))
        with tempfile.TemporaryDirectory(prefix='sweep-l11-') as directory:
            root=Path(directory)
            for item in dependency['files']:
                (root/item['file']).write_bytes((ROOT.parent/'bm1368-ticket-mask'/item['file']).read_bytes())
            target=root/'static-witness.json';target.write_bytes(target.read_bytes()+b'\n')
            self.check(['--l11-root',str(root)],reason='L11 immutable dependency identity mismatch')

    def test_frozen_runtime_source_drift(self):
        with tempfile.TemporaryDirectory(prefix='sweep-source-') as directory:
            root=Path(directory)
            for item in BASE['proof']['runtime_sources']:
                path=root/item['path'];path.parent.mkdir(parents=True,exist_ok=True)
                path.write_bytes((ROOT.parents[3]/item['path']).read_bytes())
            target=root/'libbitmain/src/chip/chip1368.c'
            raw=bytearray(target.read_bytes());raw[-2]^=1;target.write_bytes(raw)
            self.check(['--repo-root',str(root)],reason='reviewed runtime source identity mismatch')

    def test_reviewed_annotations_qualifiers_and_json_schema(self):
        self.reject(lambda w:w['proof']['domain'].clear())
        self.reject(lambda w:w['proof']['caller'].__setitem__('hwscan_caller_proved',True))
        self.reject(lambda w:w['sources']['hwscan']['operands'][0].__setitem__(3,'invented'))
        self.reject(lambda w:w.__setitem__('schema',True))
        self.reject(lambda w:w['proof'].__setitem__('unreviewed','new claim'))
        self.reject(lambda w:w['sources']['cgminer']['regions'].reverse())
        original=(ROOT/'static-witness.json').read_text()
        for bad in [original.replace('"schema": 1,','"schema": 1, "schema": 1,',1),
                    original.replace('"schema": 1,','"schema": NaN,',1)]:
            with tempfile.TemporaryDirectory(prefix='sweep-json-') as directory:
                path=Path(directory)/'invalid.json';path.write_text(bad)
                self.check(['--witness',str(path)])

    def test_changed_metadata_cannot_reauthorize_its_own_pins(self):
        witness=copy.deepcopy(BASE);witness['proof']['domain'].clear()
        metadata=copy.deepcopy(witness)
        for source in metadata['sources'].values():
            for item in source['regions']:del item['bytes_hex']
        pins=copy.deepcopy(PINS)
        pins['metadata_sha256']=hashlib.sha256(json.dumps(metadata,sort_keys=True,
            separators=(',',':'),ensure_ascii=True,allow_nan=False).encode('ascii')).hexdigest()
        with tempfile.TemporaryDirectory(prefix='sweep-pins-') as directory:
            w=Path(directory)/'w.json';w.write_text(json.dumps(witness))
            p=Path(directory)/'p.json';p.write_text(json.dumps(pins))
            self.check(['--witness',str(w),'--pins',str(p)],reason='independent static pins identity mismatch')

    def test_optional_original_identity_rejection(self):
        with tempfile.TemporaryDirectory(prefix='sweep-original-data-') as directory:
            path=Path(directory)/'invalid.bin';path.write_bytes(b'not an ELF')
            for source in ('cgminer','hwscan'):
                self.check(['--'+source,str(path)],reason='original ELF size mismatch')
            with path.open('wb') as stream:stream.truncate(BASE['sources']['cgminer']['elf_size'])
            self.check(['--cgminer',str(path)],reason='original ELF SHA256 mismatch')


if __name__=='__main__':
    unittest.main(verbosity=2)

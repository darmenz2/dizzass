#!/usr/bin/env python3
"""Focused static-evidence controls; no firmware run or instruction interpreter."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

HERE=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('address_evidence',HERE/'verify_evidence.py')
v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)

class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.original=json.loads((HERE/'static-witness.json').read_text())
    def reject(self,change):
        witness=copy.deepcopy(self.original);change(witness)
        with tempfile.TemporaryDirectory() as tmp:
            path=Path(tmp)/'witness.json';path.write_text(json.dumps(witness))
            with self.assertRaises(v.EvidenceError):v.verify(witness_path=path)
    @staticmethod
    def patch_word(witness,address,word):
        source=witness['sources']['cgminer']
        for region in source['regions']:
            off=address-region['va']
            if 0<=off and off+4<=region['size']:
                raw=bytearray.fromhex(region['bytes_hex']);raw[off:off+4]=word.to_bytes(4,'little')
                region['bytes_hex']=raw.hex();region['sha256']=hashlib.sha256(raw).hexdigest()
                for row in source['operands']:
                    if row[0]==address:row[1]=raw[off:off+4].hex()
                return
        raise ValueError('control address outside witness')
    def copy_bound_files(self,root):
        for item in self.original['dependencies']+self.original['runtime']:
            path=root/item['path'];path.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(v.ROOT/item['path'],path)
    def test_accepted_static_packet(self):
        self.assertTrue(v.verify()['static_witness_verified'])
    def test_schema_and_json_controls(self):
        self.reject(lambda w:w.update(extra='unexpected'))
        self.reject(lambda w:w.update(schema=True))
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp)/'malformed.json'
            for content in ('{"schema":1,"schema":1}','{"value":NaN}'):
                p.write_text(content)
                with self.assertRaises(v.EvidenceError):v.load_json(p)
    def test_hash_refreshed_instruction_controls(self):
        # Distinct semantic fault classes, never executed. Refreshing local
        # digest and operand bytes cannot change the independently pinned range.
        changes={
            'transport length':(0xe4948,0xe3a02007),
            'status branch':(0xe4954,0x1a000011),
            'late address becomes byte load':(0xe4970,0xe5d47004),
            'constructor offset':(0xe1514,0xe580c0bc),
            'string loop bound':(0xe59d0,0xe3510032),
            'caller starts testing result':(0x55b34,0xe3500000)}
        for label,(address,word) in changes.items():
            with self.subTest(label=label):self.reject(lambda w,a=address,b=word:self.patch_word(w,a,b))
    def test_branch_inventory_control(self):
        self.reject(lambda w:w['sources']['cgminer']['methods']['address']['branches'][0].update(condition=1))
    def test_status_contract_control(self):
        self.reject(lambda w:w['proof']['ordinary_contract'].update(nonzero_status_return=0))
    def test_read_timing_control(self):
        self.reject(lambda w:w['proof']['read_sites']['cgminer'].update(address_post=0xe4920))
    def test_address_word_metadata_control(self):
        self.reject(lambda w:w['proof']['logs'].update(address='transmitted low byte instead of full late word'))
    def test_string_bound_and_key_controls(self):
        self.reject(lambda w:w['strings'][-1].update(byte_count=50,encoded_end_exclusive=0x5eb5f9,plain_end_exclusive=0x47e089))
        self.reject(lambda w:w['strings'][-1].update(xor_key=0xd2))
    def test_constructor_identity_control(self):
        self.reject(lambda w:w['sources']['cgminer']['slots'][0].update(method=0xe48fc))
    def test_caller_ignored_status_control(self):
        self.reject(lambda w:w['proof']['caller'].update(address_status_ignored=False))
    def test_refreshed_metadata_pin_control(self):
        with tempfile.TemporaryDirectory() as tmp:
            witness=copy.deepcopy(self.original);witness['proof']['caller']['retained_owner_identity']=False
            wp=Path(tmp)/'witness.json';wp.write_text(json.dumps(witness))
            pins=json.loads((HERE/'static-pins.json').read_text());pins['metadata_sha256']=v.sha(v.canonical(v.metadata(witness)))
            pp=Path(tmp)/'pins.json';pp.write_text(json.dumps(pins))
            with self.assertRaisesRegex(v.EvidenceError,'independent static pins'):v.verify(wp,pp)
    def test_dependency_and_runtime_controls(self):
        with tempfile.TemporaryDirectory() as tmp:
            root=Path(tmp);self.copy_bound_files(root)
            for label,path in [('accepted dependency',root/self.original['dependencies'][0]['path']),('runtime prefix',root/'libbitmain/src/chip/chip1368.c'),('full header',root/'integration/bm1368_address_commands_135.h')]:
                with self.subTest(label=label):
                    data=path.read_bytes();changed=bytearray(data);changed[0]^=1;path.write_bytes(changed)
                    with self.assertRaises(v.EvidenceError):v.verify(root=root)
                    path.write_bytes(data)
            # Historical runtime evidence permits later gated append, while the
            # unchanged recorded prefix and the exact new header remain required.
            runtime=root/'libbitmain/src/chip/chip1368.c'
            runtime.write_bytes(runtime.read_bytes()+b'\n/* separate later gated extension */\n')
            self.assertTrue(v.verify(root=root)['static_witness_verified'])
            header=root/'integration/bm1368_address_commands_135.h';header.write_bytes(header.read_bytes()+b'\n')
            with self.assertRaises(v.EvidenceError):v.verify(root=root)
    def test_overlapping_range_control(self):
        self.reject(lambda w:w['sources']['cgminer']['regions'][1].update(va=w['sources']['cgminer']['regions'][0]['va']))

if __name__=='__main__':unittest.main(verbosity=2)

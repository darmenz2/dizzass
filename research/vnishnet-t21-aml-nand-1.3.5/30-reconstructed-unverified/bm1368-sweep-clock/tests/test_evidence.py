#!/usr/bin/env python3
"""Focused public static-integrity tests, normal and -O host Python.

Only the authored host verifier runs. Corrupted JSON/ELF/source-byte fixtures
are data, never executable firmware, an original-instruction oracle or C code.
"""
import copy
from contextlib import contextmanager
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT=Path(__file__).resolve().parents[1]
VERIFIER=ROOT/'verify_evidence.py'
BASE=json.loads((ROOT/'static-witness.json').read_text())
PINS=json.loads((ROOT/'static-pins.json').read_text())
_spec=importlib.util.spec_from_file_location('sweep_static_verifier',VERIFIER)
verifier=importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(verifier)


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
            original=target.read_bytes()
            # Distinguish L12, address and current drive-strength source drift.
            for offset in (9243,11279,len(original)-2):
                raw=bytearray(original);raw[offset]^=1;target.write_bytes(raw)
                self.check(['--repo-root',str(root)],reason='reviewed runtime source identity mismatch')
            target.write_bytes(original)
            header=root/'integration/bm1368_sweep_clock_135.h'
            header.write_bytes(header.read_bytes()+b'\n')
            self.check(['--repo-root',str(root)],reason='reviewed runtime source identity mismatch')

    def address_source(self):
        return (ROOT.parents[3]/verifier.BM1368_PATH).read_bytes()

    def sweep_item(self):
        return copy.deepcopy(BASE['proof']['runtime_sources'][0])

    def matching_frozen_address_identity(self,raw):
        blob=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
        return patch.multiple(verifier,BM1368_ADDRESS_SIZE=len(raw),
                              BM1368_ADDRESS_SHA256=verifier.sha(raw),BM1368_ADDRESS_BLOB=blob)

    def matching_drive_identity(self,raw):
        blob=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
        return patch.multiple(verifier,BM1368_DRIVE_SIZE=len(raw),
                              BM1368_DRIVE_SHA256=verifier.sha(raw),BM1368_DRIVE_BLOB=blob)

    @contextmanager
    def matching_address_identity(self,raw):
        # Match both outer hashes to leave the frozen L12 and address gate live.
        drive=self.address_source()[11280:]
        address=raw[:-len(drive)]
        with self.matching_drive_identity(raw), self.matching_frozen_address_identity(address):
            yield

    def test_current_address_transition_retains_frozen_l12_identity(self):
        raw=self.address_source();item=self.sweep_item()
        sweep=verifier.sweep_runtime_bytes(raw,item)
        self.assertEqual(sweep,raw[:9245])
        self.assertEqual(len(verifier.address_runtime_bytes(raw)),11280)
        self.assertEqual(item,{'path':'libbitmain/src/chip/chip1368.c','bytes':9245,
                              'git_blob':'f23565c15c9d174e644fc51a401e81dbe072dfd7',
                              'sha256':'e4c05fb8bc541e6e6b2a216cbaecf7ef57cc3d85101d59b81e8ebd3d4e2af7e4'})

    def test_address_identity_components_and_all_prior_sources_rejected(self):
        raw=self.address_source();item=self.sweep_item()
        for constant,value in (('BM1368_ADDRESS_SIZE',11279),
                               ('BM1368_ADDRESS_SHA256','0'*64),('BM1368_ADDRESS_BLOB','0'*40)):
            with self.subTest(constant=constant), patch.object(verifier,constant,value):
                with self.assertRaisesRegex(verifier.EvidenceError,'preserved address runtime source identity mismatch'):
                    verifier.sweep_runtime_bytes(raw,item)
        for end in (920,3803,7519,8350,9245):
            with self.subTest(end=end):
                with self.assertRaisesRegex(verifier.EvidenceError,'reviewed runtime source identity mismatch'):
                    verifier.sweep_runtime_bytes(raw[:end],item)

    def test_frozen_runtime_entry_cannot_be_relabelled(self):
        raw=self.address_source()
        for key,value in (('path',verifier.BM1368_PATH+'.copy'),('bytes',11280),
                          ('sha256','0'*64),('git_blob','0'*40)):
            item=self.sweep_item();item[key]=value
            with self.subTest(key=key):
                with self.assertRaisesRegex(verifier.EvidenceError,'historical sweep runtime identity differs'):
                    verifier.sweep_runtime_bytes(raw,item)
        self.reject(lambda w:w['proof']['runtime_sources'][0].__setitem__('bytes',11280))

    def test_sweep_identity_components_independent_of_matching_entry(self):
        raw=self.address_source()
        for constant,key,value in (('BM1368_SWEEP_SIZE','bytes',9244),
                                   ('BM1368_SWEEP_SHA256','sha256','0'*64),
                                   ('BM1368_SWEEP_BLOB','git_blob','0'*40)):
            item=self.sweep_item();item[key]=value
            # Direct helper control bypasses entry equality, never metadata pins.
            with self.subTest(constant=constant), patch.object(verifier,constant,value):
                with self.assertRaisesRegex(verifier.EvidenceError,'preserved sweep runtime source identity mismatch'):
                    verifier.sweep_runtime_bytes(raw,item)

    def test_preserved_sweep_bytes_checked_without_address_full_hash(self):
        raw=self.address_source();item=self.sweep_item()
        for offset in (0,920,3802,3803,7518,7519,8349,8350,9244):
            mutant=bytearray(raw);mutant[offset]^=1;mutant=bytes(mutant)
            with self.subTest(offset=offset), self.matching_address_identity(mutant):
                with self.assertRaisesRegex(verifier.EvidenceError,'preserved sweep runtime source identity mismatch'):
                    verifier.sweep_runtime_bytes(mutant,item)

    def test_address_gate_shape_checked_without_full_hash(self):
        raw=self.address_source();sweep,added=raw[:9245],raw[9245:11280];item=self.sweep_item()
        suffixes=[b'',added.replace(b'VN135_BM1368_ADDRESS_COMMANDS_135',b'OTHER_GATE'),
                  added.replace(b'"integration/bm1368_address_commands_135.h"',b'"wrong.h"'),
                  added.replace(b'#include "integration/bm1368_control.h"\n',b''),
                  added.replace(b'"integration/bm1368_control.h"',b'"wrong-helper.h"'),
                  b'int outside;\n'+added,added+added,added[:-8]]
        for replacement in (b'\n#endif\nint outside;\n\n',
                            b'\n#if OTHER\n#endif\n#endif\n',
                            b'\n#else\n#endif\n',b'\n#elif OTHER\n#endif\n',
                            b'\n#include "extra.h"\n#endif\n'):
            suffixes.append(added.replace(b'\n#endif\n',replacement))
        for index,suffix in enumerate(suffixes):
            mutant=sweep+suffix+raw[11280:]
            with self.subTest(mutation=index), self.matching_address_identity(mutant):
                with self.assertRaisesRegex(verifier.EvidenceError,'address-commands append is not separately gated'):
                    verifier.sweep_runtime_bytes(mutant,item)

    def test_address_semantics_truncation_and_extra_bytes_rejected(self):
        raw=self.address_source();sweep,added=raw[:9245],raw[9245:11280];item=self.sweep_item()
        for suffix in (added.replace(b'669, 1,',b'670, 1,'),
                       added.replace(b'699, 1,',b'700, 1,'),
                       added.replace(b'frame + 2, 5',b'frame + 2, 4'),added+b'\n',added[:-1]):
            with self.assertRaisesRegex(verifier.EvidenceError,'reviewed runtime source identity mismatch'):
                verifier.sweep_runtime_bytes(sweep+suffix+raw[11280:],item)

    def test_exact_drive_transition_retains_address_identity(self):
        raw=self.address_source();address=verifier.address_runtime_bytes(raw)
        self.assertEqual(address,raw[:11280])
        self.assertEqual(len(raw),14347)
        self.assertEqual(verifier.sha(raw),
                         'd31a47e24504be3cf48cad8cbca96a9a38f08fd5aa0b0a27e672fac84bff5ce6')
        self.assertEqual(hashlib.sha1(b'blob 14347\0'+raw).hexdigest(),
                         '355824db8f2127da4c678737ab86daf2a99f4a85')
        self.assertEqual(len(address),11280)
        self.assertEqual(verifier.sha(address),
                         '91cfb6f3bb640bcf3519027243970bcb37aeeb0275f96b931dd17cab940540d2')
        self.assertEqual(hashlib.sha1(b'blob 11280\0'+address).hexdigest(),
                         '890e2bfc9ead81a9cafe5b34c917b37133ea0d5e')
        self.assertEqual(len(raw[11280:]),3067)

    def test_drive_identity_components_are_independent(self):
        raw=self.address_source();item=self.sweep_item()
        for constant,value in (('BM1368_DRIVE_SIZE',14346),
                               ('BM1368_DRIVE_SHA256','0'*64),('BM1368_DRIVE_BLOB','0'*40)):
            with self.subTest(constant=constant), patch.object(verifier,constant,value):
                with self.assertRaisesRegex(verifier.EvidenceError,
                                            r'reviewed runtime source identity mismatch: .* \(drive strength\)'):
                    verifier.sweep_runtime_bytes(raw,item)

    def test_address_only_source_rejected_as_current(self):
        raw=self.address_source();item=self.sweep_item()
        with self.assertRaisesRegex(verifier.EvidenceError,
                                    r'reviewed runtime source identity mismatch: .* \(drive strength\)'):
            verifier.sweep_runtime_bytes(raw[:11280],item)

    def test_preserved_address_bytes_checked_without_drive_full_hash(self):
        raw=self.address_source()
        for offset in (0,920,3802,3803,7518,7519,8349,8350,9244,9245,11279):
            mutant=bytearray(raw);mutant[offset]^=1;mutant=bytes(mutant)
            with self.subTest(offset=offset), self.matching_drive_identity(mutant):
                with self.assertRaisesRegex(verifier.EvidenceError,'preserved address runtime source identity mismatch'):
                    verifier.address_runtime_bytes(mutant)

    def test_drive_gate_shape_checked_without_full_hash(self):
        raw=self.address_source();address,added=raw[:11280],raw[11280:]
        suffixes=[b'',added.replace(b'VN135_BM1368_DRIVE_STRENGTH_135',b'OTHER_GATE'),
                  added.replace(b'"integration/bm1368_drive_strength_135.h"',b'"wrong.h"'),
                  b'int outside;\n'+added,added+added,added[:-8],added[:-1],added+b'\n']
        for replacement in (b'\n#endif\nint outside;\n\n',
                            b'\n#if OTHER\n#endif\n#endif\n',
                            b'\n#else\n#endif\n',b'\n#elif OTHER\n#endif\n',
                            b'\n#include "extra.h"\n#endif\n'):
            suffixes.append(added.replace(b'\n#endif\n',replacement))
        for index,suffix in enumerate(suffixes):
            mutant=address+suffix
            with self.subTest(mutation=index), self.matching_drive_identity(mutant):
                with self.assertRaisesRegex(verifier.EvidenceError,'drive-strength append is not separately gated'):
                    verifier.address_runtime_bytes(mutant)

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

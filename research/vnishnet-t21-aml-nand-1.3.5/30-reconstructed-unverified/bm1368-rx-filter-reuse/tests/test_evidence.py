#!/usr/bin/env python3
"""Static artifact and authored reuse tamper controls; no CPU model or ELF run."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('rx_filter_reuse_evidence', HERE/'verify_evidence.py')
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.reference=VERIFY.ROOT/'reference/cgminer.vendor.elf'
        cls.evidence=HERE/'evidence'
        VERIFY.verify(cls.reference,cls.evidence)  # Missing originals fail, never skip acceptance.

    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work=Path(self.temp.name)
        self.packet=self.work/'evidence'
        shutil.copytree(self.evidence,self.packet)
        self.source=self.work/'work-gen.c'
        self.header=self.work/'work_rx.h'
        self.receipt=self.work/'REUSE.json'
        for key,path in [('source',self.source),('header',self.header)]:
            data=(VERIFY.ROOT/VERIFY.REUSE_PINS[key][0]).read_bytes().replace(b'\r\n',b'\n')
            path.write_bytes(data)
        shutil.copyfile(HERE/'REUSE.json',self.receipt)

    def verify(self,reference=None,**kwargs):
        params={'reuse_source':self.source,'reuse_header':self.header,'reuse_receipt':self.receipt}
        params.update(kwargs)
        return VERIFY.verify(reference or self.reference,self.packet,**params)

    def mutate(self,action):
        path=self.packet/'static-witness.json'
        packet=json.loads(path.read_text())
        action(packet)
        path.write_text(json.dumps(packet,indent=2)+'\n')

    @staticmethod
    def region(packet,source,name):
        return next(r for r in packet['sources'][source]['regions'] if r['name']==name)

    def mutate_bytes(self,source,name,offset):
        def change(p):
            item=self.region(p,source,name)
            data=bytearray.fromhex(item['bytes_hex']);data[offset]^=1
            item.update(bytes_hex=data.hex(),sha256=VERIFY.digest(data))
        self.mutate(change)

    def reject_packet(self):
        with self.assertRaisesRegex(VERIFY.EvidenceError,'independent approved pin'):
            self.verify()

    def mutate_receipt(self,action):
        receipt=json.loads(self.receipt.read_text())
        action(receipt)
        self.receipt.write_text(json.dumps(receipt,indent=2)+'\n')

    def reject_receipt(self):
        with self.assertRaisesRegex(VERIFY.EvidenceError,'canonical reuse receipt differs'):
            self.verify()

    def test_actual_method_and_reuse_integrity(self):
        result=self.verify()
        self.assertTrue(result['verified'])
        self.assertEqual(result['checked_original_regions'],{'cgminer':15})
        self.assertEqual(result['method_code_bytes'],{'cgminer':56,'hwscan':8})
        self.assertEqual(result['checked_reuse_files']['source']['canonical_lf_bytes'],6785)
        self.assertEqual(result['checked_reuse_files']['header']['canonical_lf_bytes'],3724)
        for name in ['original_executed','instruction_interpreter_used','historical_instruction_oracle_run','new_algorithm_or_constant_added','runtime_reachability_established','hwscan_original_checked']:
            self.assertFalse(result[name],name)

    def test_cli_normal_and_optimized_with_optional_reuse_paths(self):
        for flags in ([],['-O']):
            result=subprocess.run([sys.executable,'-B',*flags,str(HERE/'verify_evidence.py'),
                '--cgminer',str(self.reference),'--evidence',str(self.packet),
                '--reuse-source',str(self.source),'--reuse-header',str(self.header),
                '--reuse-receipt',str(self.receipt)],capture_output=True,text=True,timeout=30)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertTrue(json.loads(result.stdout)['verified'])

    def test_method_code_with_refreshed_hash_rejected(self):
        self.mutate_bytes('cgminer','method_code',0x30)
        self.reject_packet()

    def test_constructor_got_with_refreshed_hash_rejected(self):
        self.mutate_bytes('hwscan','constructor_got',0)
        self.reject_packet()

    def test_wrong_constructor_slot_rejected(self):
        self.mutate(lambda p:p['constructor_binding'].update(slot=0x8c))
        self.reject_packet()

    def test_selector4_jump_entry_rejected(self):
        self.mutate_bytes('cgminer','dispatch_jump_data',16)
        self.reject_packet()

    def test_duplicate_call_marked_ordinary_rejected(self):
        self.mutate(lambda p:p['dispatcher']['cgminer'].update(ordinary_call=0xd2bec,ordinary_calls_after_selector4=2))
        self.reject_packet()

    def test_register_field_replaced_by_chip_field_rejected(self):
        self.mutate(lambda p:p['rx_consumers']['normal'].update(register_byte_load=0xc4a30))
        self.reject_packet()

    def test_equal_branch_claim_changed_rejected(self):
        self.mutate(lambda p:p['rx_consumers']['special'].update(equal_target=0xc483c))
        self.reject_packet()

    def test_method_declared_packet_length_rejected(self):
        self.mutate(lambda p:p['method'].update(packet_length=64))
        self.reject_packet()

    def test_changed_opaque_snapshot_rejected(self):
        self.mutate(lambda p:p['opaque_predicates']['method'][0].update(subtract=0xe3bd4))
        self.reject_packet()

    def test_full_source_and_header_lf_crlf_accepted(self):
        for crlf in [False,True]:
            for path in [self.source,self.header]:
                data=path.read_bytes().replace(b'\r\n',b'\n')
                path.write_bytes(data.replace(b'\n',b'\r\n') if crlf else data)
            self.assertTrue(self.verify()['verified'])

    def test_corrected_existing_filter_constant_rejected(self):
        data=self.source.read_bytes()
        before=b'return chip <= 4u ? 0x40u : UINT32_MAX;'
        self.assertEqual(data.count(before),1)
        self.source.write_bytes(data.replace(before,b'return chip <= 4u ? 0x44u : UINT32_MAX;'))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'canonical LF reuse SHA256 mismatch: source'):
            self.verify()

    def test_inverted_existing_parser_classification_rejected(self):
        data=self.source.read_bytes();before=b'r.register_address == vn135_work_rx_filtered_register'
        self.assertEqual(data.count(before),1)
        self.source.write_bytes(data.replace(before,b'r.register_address != vn135_work_rx_filtered_register'))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'canonical LF reuse SHA256 mismatch: source'):
            self.verify()

    def test_changed_existing_filtered_enum_rejected(self):
        data=self.header.read_bytes();before=b'VN135_RX_REGISTER_FILTERED = 4'
        self.assertEqual(data.count(before),1)
        self.header.write_bytes(data.replace(before,b'VN135_RX_REGISTER_FILTERED = 5'))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'canonical LF reuse SHA256 mismatch: header'):
            self.verify()

    def test_lone_cr_in_source_and_header_rejected(self):
        for key,path in [('source',self.source),('header',self.header)]:
            with self.subTest(key=key):
                original=path.read_bytes();path.write_bytes(original.replace(b'\n',b'\r',1))
                with self.assertRaisesRegex(VERIFY.EvidenceError,'lone CR in reuse file: '+key):self.verify()
                path.write_bytes(original)

    def test_refreshed_reuse_hash_cannot_authorize_changed_source(self):
        data=self.source.read_bytes().replace(b'0x40u',b'0x44u',1);self.source.write_bytes(data)
        self.mutate(lambda p:p['reuse']['source'].update(canonical_lf_sha256=VERIFY.digest(data)))
        self.reject_packet()

    def test_bounded_reuse_read_rejects_oversized_source(self):
        self.source.write_bytes(b' '*(VERIFY.REUSE_PINS['source'][1]*2+1))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'file exceeds bounded size'):self.verify()

    def test_missing_reuse_header_is_not_skipped(self):
        self.header.unlink()
        with self.assertRaises(OSError):self.verify()

    def test_receipt_forged_t21_model_rejected(self):
        self.mutate_receipt(lambda p:p['boundaries'].update(raw_selector_is_t21_model=True))
        self.reject_receipt()

    def test_receipt_forged_packet_length_rejected(self):
        self.mutate_receipt(lambda p:p['original_method'].update(packet_length=64))
        self.reject_receipt()

    def test_receipt_erased_direct_caller_rejected(self):
        self.mutate_receipt(lambda p:p['boundaries'].update(direct_static_dispatcher_call_established=False))
        self.reject_receipt()

    def test_receipt_claims_original_execution_rejected(self):
        self.mutate_receipt(lambda p:p['boundaries'].update(original_executed_or_interpreted_this_run=True))
        self.reject_receipt()

    def test_receipt_semantic_json_formatting_accepted(self):
        receipt=json.loads(self.receipt.read_text())
        self.receipt.write_text(json.dumps(receipt,sort_keys=True,separators=(',',':')))
        self.assertTrue(self.verify()['verified'])

    def test_refreshed_packet_receipt_hash_cannot_authorize_claim(self):
        self.mutate_receipt(lambda p:p['boundaries'].update(queue_or_hardware_acceptance_claimed=True))
        receipt=json.loads(self.receipt.read_text())
        self.mutate(lambda p:p['reuse']['receipt'].update(canonical_json_sha256=VERIFY.digest(VERIFY.canonical(receipt))))
        self.reject_packet()

    def test_original_hash_tamper_rejected(self):
        path=self.work/'changed.elf';data=bytearray(self.reference.read_bytes());data[-1]^=1;path.write_bytes(data)
        with self.assertRaisesRegex(VERIFY.EvidenceError,'reference SHA256 mismatch'):self.verify(path)

    def test_optional_hwscan_input_failure_is_not_skipped(self):
        with self.assertRaises(OSError):self.verify(hwscan=self.work/'missing-hwscan.elf')
        with self.assertRaisesRegex(VERIFY.EvidenceError,'file exceeds bounded size'):self.verify(hwscan=self.reference)

    def test_duplicate_json_key_rejected(self):
        (self.packet/'static-witness.json').write_text('{"schema":1,"schema":1}')
        with self.assertRaisesRegex(VERIFY.EvidenceError,'duplicate JSON key'):self.verify()

    def test_nonfinite_and_nonintegral_json_rejected(self):
        for value in ['NaN','1.0','1e999']:
            with self.subTest(value=value):
                (self.packet/'static-witness.json').write_text('{"schema":'+value+'}')
                with self.assertRaises(VERIFY.EvidenceError):self.verify()

    def test_bounded_integer_rejected(self):
        (self.packet/'static-witness.json').write_text('{"schema":'+'1'*21+'}')
        with self.assertRaisesRegex(VERIFY.EvidenceError,'integer exceeds bounded digits'):self.verify()

    def test_bounded_packet_size_rejected(self):
        (self.packet/'static-witness.json').write_bytes(b' '*(VERIFY.MAX_ARTIFACT_BYTES+1))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'file exceeds bounded size'):self.verify()

    def test_assembly_compare_tamper_rejected(self):
        path=self.packet/'cgminer-rx_special_code.asm';data=path.read_text()
        self.assertIn('cmp r0, r1',data);path.write_text(data.replace('cmp r0, r1','cmp r0, r2',1))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'assembly annotation mismatch'):self.verify()

    def test_lone_cr_assembly_rejected(self):
        path=self.packet/'cgminer-method_code.asm';path.write_bytes(path.read_bytes().replace(b'\n',b'\r',1))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'lone CR in assembly'):self.verify()

    def test_crlf_assembly_accepted(self):
        for path in self.packet.glob('*.asm'):path.write_bytes(path.read_bytes().replace(b'\n',b'\r\n'))
        self.assertTrue(self.verify()['verified'])

    def test_optimized_python_rejects_changed_reuse_and_receipt(self):
        self.source.write_bytes(self.source.read_bytes().replace(b'0x40u',b'0x44u',1))
        common=[sys.executable,'-B','-O',str(HERE/'verify_evidence.py'),'--cgminer',str(self.reference),'--evidence',str(self.packet)]
        result=subprocess.run(common+['--reuse-source',str(self.source)],capture_output=True,text=True,timeout=30)
        self.assertEqual(result.returncode,1);self.assertIn('canonical LF reuse SHA256 mismatch',result.stderr)
        self.mutate_receipt(lambda p:p['boundaries'].update(original_executed_or_interpreted_this_run=True))
        result=subprocess.run(common+['--reuse-receipt',str(self.receipt)],capture_output=True,text=True,timeout=30)
        self.assertEqual(result.returncode,1);self.assertIn('canonical reuse receipt differs',result.stderr)

    def test_malformed_utf8_rejected(self):
        (self.packet/'static-witness.json').write_bytes(b'{"bad":"\xff"}')
        with self.assertRaisesRegex(VERIFY.EvidenceError,'invalid bounded JSON'):self.verify()


if __name__=='__main__':
    unittest.main()

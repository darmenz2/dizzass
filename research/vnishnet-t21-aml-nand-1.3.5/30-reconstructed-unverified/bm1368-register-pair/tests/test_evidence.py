#!/usr/bin/env python3
"""Static register-pair tamper controls; no original CPU instruction model."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE=Path(__file__).resolve().parents[1]
SPEC=importlib.util.spec_from_file_location('register_pair_evidence',HERE/'verify_evidence.py')
VERIFY=importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.reference=VERIFY.ROOT/'reference/cgminer.vendor.elf'
        cls.evidence=HERE/'evidence'
        VERIFY.verify(cls.reference,cls.evidence)  # Missing originals fail, never skip.

    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.work=Path(self.temp.name);self.packet=self.work/'evidence'
        shutil.copytree(self.evidence,self.packet)

    def verify(self,reference=None,hwscan=None):
        return VERIFY.verify(reference or self.reference,self.packet,hwscan)

    def mutate(self,action):
        path=self.packet/'static-witness.json';p=json.loads(path.read_text())
        action(p);path.write_text(json.dumps(p,indent=2)+'\n')

    @staticmethod
    def region(p,source,name):return next(r for r in p['sources'][source]['regions'] if r['name']==name)

    def mutate_bytes(self,source,name,offset):
        def change(p):
            r=self.region(p,source,name);b=bytearray.fromhex(r['bytes_hex']);b[offset]^=1
            r.update(bytes_hex=b.hex(),sha256=VERIFY.digest(b))
        self.mutate(change)

    def reject_packet(self):
        with self.assertRaisesRegex(VERIFY.EvidenceError,'independent approved pin'):self.verify()

    def test_actual_original_and_packet(self):
        result=self.verify();self.assertTrue(result['verified'])
        self.assertEqual(result['checked_original_regions'],{'cgminer':7})
        self.assertEqual(result['code_bytes'],{'cgminer':460,'hwscan':216})
        for key in ['original_executed','instruction_interpreter_used','runtime_reachability_established','hwscan_original_checked']:self.assertFalse(result[key])

    def test_cli_normal_and_optimized(self):
        for flags in ([],['-O']):
            result=subprocess.run([sys.executable,'-B',*flags,str(HERE/'verify_evidence.py'),'--cgminer',str(self.reference),'--evidence',str(self.packet)],capture_output=True,text=True,timeout=30)
            self.assertEqual(result.returncode,0,result.stderr);self.assertTrue(json.loads(result.stdout)['verified'])

    def test_code_refreshed_hash_rejected(self):
        self.mutate_bytes('cgminer','code',0xc0);self.reject_packet()

    def test_pool_refreshed_hash_rejected(self):
        self.mutate_bytes('cgminer','literals',0);self.reject_packet()

    def test_constructor_got_refreshed_hash_rejected(self):
        self.mutate_bytes('hwscan','constructor_got',0);self.reject_packet()

    def test_wrong_constructor_slot_rejected(self):
        self.mutate(lambda p:p['constructor_binding'].update(slot=0x98));self.reject_packet()

    def test_hwscan_boundary_crosses_next_method_rejected(self):
        self.mutate(lambda p:self.region(p,'hwscan','code').update(end=0xf36f4));self.reject_packet()

    def test_invented_output_zero_initialization_rejected(self):
        self.mutate(lambda p:p['contract']['reads'].update(output_initialized_by_method=True));self.reject_packet()

    def test_invented_permission_to_read_indeterminate_output_rejected(self):
        self.mutate(lambda p:p['contract']['reads'].update(reader_precondition='Reader may inspect previous stack output before writing.'));self.reject_packet()

    def test_chip_getter_substituted_for_common_getter_rejected(self):
        self.mutate(lambda p:p['contract']['reads'].update(cgminer=0x1079f0));self.reject_packet()

    def test_stale_second_reader_index_rejected(self):
        self.mutate(lambda p:p['contract']['reads'].update(cgminer_index_loads=[0xe3c14,0xe3c14]));self.reject_packet()

    def test_reversed_read_order_rejected(self):
        self.mutate(lambda p:p['contract']['reads'].update(order=[0x18,0xa8]));self.reject_packet()

    def test_first_read_failure_does_not_skip_remaining_calls_rejected(self):
        self.mutate(lambda p:p['contract']['reads'].update(nonzero_status_skips_remaining_calls=False));self.reject_packet()

    def test_flag_exact_one_claim_rejected(self):
        self.mutate(lambda p:p['contract'].update(flag_semantics='exactly one enables; every other input disables'));self.reject_packet()

    def test_wrong_enabled_a8_mask_rejected(self):
        self.mutate(lambda p:p['contract']['values']['flag_nonzero'].update(a8='cached_a8 | 0x1f0'));self.reject_packet()

    def test_wrong_enabled_misc_mask_rejected(self):
        self.mutate(lambda p:p['contract']['values']['flag_nonzero'].update(misc18='cached_18 & ~0xf0000'));self.reject_packet()

    def test_wrong_disabled_a8_mask_rejected(self):
        self.mutate(lambda p:p['contract']['values']['flag_zero'].update(a8='cached_a8 & ~0x10f'));self.reject_packet()

    def test_wrong_disabled_misc_mask_rejected(self):
        self.mutate(lambda p:p['contract']['values']['flag_zero'].update(misc18='cached_18 | 0xfff00000'));self.reject_packet()

    def test_cache_reread_instead_of_local_snapshot_rejected(self):
        self.mutate(lambda p:p['contract']['values'].update(snapshot='Read second value again after first writer.'));self.reject_packet()

    def test_unicast_or_nonnull_chip_claim_rejected(self):
        self.mutate(lambda p:p['contract']['writes'].update(mode=0,chip='supplied chip pointer'));self.reject_packet()

    def test_reversed_write_order_rejected(self):
        self.mutate(lambda p:p['contract']['writes'].update(order=[0x18,0xa8]));self.reject_packet()

    def test_second_write_after_first_failure_rejected(self):
        self.mutate(lambda p:p['contract']['writes'].update(second_only_after_exactly_zero_first_write=False));self.reject_packet()

    def test_second_write_failure_propagated_instead_of_normalized_rejected(self):
        self.mutate(lambda p:p['contract']['writes'].update(failure_return='raw lower status'));self.reject_packet()

    def test_added_retry_rejected(self):
        self.mutate(lambda p:p['contract'].update(retries=1));self.reject_packet()

    def test_added_outer_log_rejected(self):
        self.mutate(lambda p:p['contract'].update(outer_diagnostic_calls=1));self.reject_packet()

    def test_discarded_test_given_conditional_use_rejected(self):
        self.mutate(lambda p:p['opaque_predicates']['discarded_flag_test'].update(conditional_use_between_tests=True));self.reject_packet()

    def test_last_parity_branch_wrong_target_rejected(self):
        self.mutate(lambda p:p['opaque_predicates']['predicates'][4].update(always_target=0xe3da4));self.reject_packet()

    def test_ordinary_enabled_y_read_marked_dead_rejected(self):
        self.mutate(lambda p:p['opaque_predicates'].update(ordinary_enabled_y_value_read=None));self.reject_packet()

    def test_forged_hwscan_source_identity_rejected(self):
        self.mutate(lambda p:p['sources']['hwscan'].update(size=6228004));self.reject_packet()

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

    def test_assembly_register_tamper_rejected(self):
        path=self.packet/'cgminer-code.asm';data=path.read_text();self.assertIn('mov r3, #0xa8',data)
        path.write_text(data.replace('mov r3, #0xa8','mov r3, #0x18',1))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'assembly annotation mismatch'):self.verify()

    def test_crlf_assembly_accepted(self):
        for path in self.packet.glob('*.asm'):path.write_bytes(path.read_bytes().replace(b'\n',b'\r\n'))
        self.assertTrue(self.verify()['verified'])

    def test_lone_cr_assembly_rejected(self):
        path=self.packet/'cgminer-code.asm';path.write_bytes(path.read_bytes().replace(b'\n',b'\r',1))
        with self.assertRaisesRegex(VERIFY.EvidenceError,'lone CR in assembly'):self.verify()

    def test_original_hash_tamper_rejected(self):
        path=self.work/'changed.elf';data=bytearray(self.reference.read_bytes());data[-1]^=1;path.write_bytes(data)
        with self.assertRaisesRegex(VERIFY.EvidenceError,'reference SHA256 mismatch'):self.verify(path)

    def test_original_truncation_and_oversize_rejected(self):
        path=self.work/'bad-sized.elf';data=self.reference.read_bytes()
        path.write_bytes(data[:-1])
        with self.assertRaisesRegex(VERIFY.EvidenceError,'reference byte length mismatch'):self.verify(path)
        path.write_bytes(data+b'\0')
        with self.assertRaisesRegex(VERIFY.EvidenceError,'file exceeds bounded size'):self.verify(path)

    def test_optional_hwscan_failure_not_skipped(self):
        with self.assertRaises(OSError):self.verify(hwscan=self.work/'missing.elf')
        with self.assertRaisesRegex(VERIFY.EvidenceError,'file exceeds bounded size'):self.verify(hwscan=self.reference)

    def test_negative_acceptance_survives_optimized_python(self):
        self.mutate(lambda p:p['contract']['reads'].update(output_initialized_by_method=True))
        result=subprocess.run([sys.executable,'-B','-O',str(HERE/'verify_evidence.py'),'--cgminer',str(self.reference),'--evidence',str(self.packet)],capture_output=True,text=True,timeout=30)
        self.assertEqual(result.returncode,1);self.assertIn('independent approved pin',result.stderr)

    def test_malformed_utf8_rejected(self):
        (self.packet/'static-witness.json').write_bytes(b'{"bad":"\xff"}')
        with self.assertRaisesRegex(VERIFY.EvidenceError,'invalid bounded JSON'):self.verify()


if __name__=='__main__':
    unittest.main()

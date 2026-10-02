#!/usr/bin/env python3
"""Bounded static artifact and original-source tamper controls, no CPU model."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('analog_mux_evidence', HERE / 'verify_evidence.py')
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.reference = VERIFY.ROOT / 'reference/cgminer.vendor.elf'
        cls.evidence = HERE / 'evidence'
        # Missing original input fails; it is never skipped as acceptance.
        VERIFY.verify(cls.reference, cls.evidence)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.packet = self.work / 'evidence'
        shutil.copytree(self.evidence, self.packet)

    def verify(self, reference=None):
        return VERIFY.verify(reference or self.reference, self.packet)

    def mutate(self, action):
        path = self.packet / 'static-witness.json'
        data = json.loads(path.read_text())
        action(data)
        path.write_text(json.dumps(data, indent=2) + '\n')

    def region(self, packet, source, name):
        return next(r for r in packet['sources'][source]['regions'] if r['name'] == name)

    def mutate_bytes(self, source, name, offset):
        def change(packet):
            record = self.region(packet, source, name)
            raw = bytearray.fromhex(record['bytes_hex'])
            raw[offset] ^= 1
            record['bytes_hex'] = raw.hex()
            record['sha256'] = VERIFY.digest(raw)  # refreshing a local digest cannot authorize bytes
        self.mutate(change)

    def reject_packet(self):
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'independent approved pin'):
            self.verify()

    def test_actual_original_and_packet(self):
        result = self.verify()
        self.assertTrue(result['verified'])
        self.assertEqual(result['checked_original_regions']['cgminer'], 16)
        self.assertEqual(result['code_bytes'], {'cgminer':316, 'hwscan':136})
        self.assertFalse(result['original_executed'])
        self.assertFalse(result['instruction_interpreter_used'])
        self.assertFalse(result['runtime_reachability_established'])

    def test_cli_normal_and_optimized(self):
        for flags in ([], ['-O']):
            result = subprocess.run([sys.executable, '-B', *flags,
                str(HERE / 'verify_evidence.py'), '--cgminer', str(self.reference),
                '--evidence', str(self.packet)], capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertTrue(json.loads(result.stdout)['verified'])

    def test_code_refreshed_digest_rejected(self):
        self.mutate_bytes('cgminer', 'code', 0x10)
        self.reject_packet()

    def test_pool_refreshed_digest_rejected(self):
        self.mutate_bytes('cgminer', 'literals', 8)
        self.reject_packet()

    def test_binding_refreshed_digest_rejected(self):
        self.mutate_bytes('hwscan', 'constructor_got', 0)
        self.reject_packet()

    def test_hwscan_boundary_crossing_next_method_rejected(self):
        self.mutate(lambda p:self.region(p, 'hwscan', 'code').update(end=0xf34bc))
        self.reject_packet()

    def test_slot_change_rejected(self):
        self.mutate(lambda p:p['constructor_binding'].update(slot=0x84))
        self.reject_packet()

    def test_forged_source_function_name_rejected(self):
        def change(p):
            string = next(s for s in p['sources']['cgminer']['strings'] if s['name']=='function')
            string['decoded'] = 'set_analog_mux'
        self.mutate(change)
        self.reject_packet()

    def test_wrong_string_xor_key_rejected(self):
        self.mutate(lambda p:p['sources']['cgminer']['strings'][3].update(xor_key=0))
        self.reject_packet()

    def test_initializer_decoder_count_rejected(self):
        self.mutate(lambda p:p['initializer']['witnesses'][3].update(count=40))
        self.reject_packet()

    def test_altered_parity_proof_rejected(self):
        self.mutate(lambda p:p['opaque_predicates']['predicates'][0].update(multiply=0xe3610))
        self.reject_packet()

    def test_double_failure_log_claim_rejected(self):
        self.mutate(lambda p:p['contract']['ordinary_failure_log'].update(count=2))
        self.reject_packet()

    def test_wrong_mode_or_register_claim_rejected(self):
        self.mutate(lambda p:p['contract']['writer'].update(mode=0, register=0x3c))
        self.reject_packet()

    def test_hwscan_source_identity_rejected(self):
        self.mutate(lambda p:p['sources']['hwscan'].update(size=6228004))
        self.reject_packet()

    def test_extra_unreviewed_json_key_rejected(self):
        self.mutate(lambda p:p.update(unreviewed=True))
        self.reject_packet()

    def test_duplicate_json_key_rejected(self):
        (self.packet/'static-witness.json').write_text('{"schema":1,"schema":1}')
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'duplicate JSON key'):
            self.verify()

    def test_nonfinite_json_constant_rejected(self):
        (self.packet/'static-witness.json').write_text('{"schema":NaN}')
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'nonfinite JSON constant'):
            self.verify()

    def test_nonfinite_exponent_rejected(self):
        (self.packet/'static-witness.json').write_text('{"schema":1e999}')
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'invalid canonical witness'):
            self.verify()

    def test_bounded_artifact_size_rejected(self):
        (self.packet/'static-witness.json').write_bytes(b' '*(VERIFY.MAX_ARTIFACT_BYTES+1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'file exceeds bounded size'):
            self.verify()

    def test_assembly_operand_tamper_rejected(self):
        path = self.packet/'cgminer-code.asm'
        data = path.read_text()
        self.assertIn('mov r1, #1', data)
        path.write_text(data.replace('mov r1, #1','mov r1, #0',1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'assembly annotation mismatch'):
            self.verify()

    def test_removed_fresh_index_load_rejected(self):
        path = self.packet/'hwscan-code.asm'
        path.write_text(''.join(line for line in path.read_text().splitlines(keepends=True)
                                if not line.startswith('000f33a0')))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'assembly annotation mismatch'):
            self.verify()

    def test_crlf_checkout_is_accepted(self):
        for path in self.packet.glob('*.asm'):
            path.write_bytes(path.read_bytes().replace(b'\n',b'\r\n'))
        self.assertTrue(self.verify()['verified'])

    def test_lone_cr_rejected(self):
        path = self.packet/'cgminer-code.asm'
        path.write_bytes(path.read_bytes().replace(b'\n',b'\r',1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'lone CR'):
            self.verify()

    def test_original_hash_tamper_rejected(self):
        path = self.work/'changed.elf'
        data = bytearray(self.reference.read_bytes())
        data[-1] ^= 1
        path.write_bytes(data)
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'reference SHA256 mismatch'):
            self.verify(path)

    def test_short_original_rejected(self):
        path = self.work/'short.elf'
        path.write_bytes(self.reference.read_bytes()[:-1])
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'reference byte length mismatch'):
            self.verify(path)

    def test_oversized_original_rejected(self):
        path = self.work/'oversized.elf'
        path.write_bytes(self.reference.read_bytes()+b'\0')
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'file exceeds bounded size'):
            self.verify(path)

    def test_checks_survive_optimized_python(self):
        self.mutate(lambda p:p['contract']['ordinary_failure_log'].update(count=2))
        result = subprocess.run([sys.executable, '-B', '-O',
            str(HERE/'verify_evidence.py'), '--cgminer',str(self.reference),
            '--evidence',str(self.packet)],capture_output=True,text=True,timeout=30)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('independent approved pin',result.stderr)


if __name__ == '__main__':
    unittest.main()

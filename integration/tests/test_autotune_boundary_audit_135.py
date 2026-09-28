#!/usr/bin/env python3
"""Audit self-tests + bounded original-instruction witnesses; no vendor process.

Windows entered mid-function assume the explicitly supplied register/state
preconditions. They do not establish global reachability from the tuner entry.
No lower device, thread, config or registry implementation is executed here.
"""
from __future__ import annotations
import contextlib
import io
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
import audit_autotune_boundary_135 as audit
from arm32_verify_subset import ARM32Verify

ELF = audit.checked_elf(ROOT)
COUNTS = {'decoder_cases': 0, 'original_window_cases': 0, 'original_steps': 0}


class DecodeTests(unittest.TestCase):
    def test_direct_signed_condition_and_wrap(self):
        for pc in (0, 0x10000, 0xfffffffc):
            for off in (-0x800000, -8192, -1, 0, 1, 8192, 0x7fffff):
                for cond in range(15):
                    w = (cond << 28) | 0x0b000000 | (off & 0xffffff)
                    got = audit.decode_call(w, pc)
                    self.assertEqual(got, {'kind': 'BL', 'target': (pc+8+off*4) % 2**32,
                                          'target_state': 'arm', 'condition': cond})
                    COUNTS['decoder_cases'] += 1

    def test_blx_immediate_and_register(self):
        for pc in (0x10000, 0xfffffffc):
            for off in (-0x800000, -1, 0, 1, 0x7fffff):
                for h in (0, 1):
                    w = 0xfa000000 | h << 24 | (off & 0xffffff)
                    got = audit.decode_call(w, pc)
                    self.assertEqual(got['target'], (pc+8+off*4+h*2) % 2**32)
                    self.assertEqual(got['target_state'], 'thumb')
                    COUNTS['decoder_cases'] += 1
        for cond in range(15):
            for reg in range(16):
                got = audit.decode_call(cond << 28 | 0x012fff30 | reg, 0x400)
                self.assertEqual(got, {'kind': 'BLX_reg', 'condition': cond, 'register': reg})
                COUNTS['decoder_cases'] += 1

    def test_non_calls(self):
        for word in (0, 0xe1a00000, 0xea000001, 0xe12fff1e, 0xe59ff000, 0xf12fff30):
            self.assertIsNone(audit.decode_call(word, 0x10000))
            COUNTS['decoder_cases'] += 1

    def test_data_can_look_like_call(self):
        # The scanner intentionally cannot distinguish this data word from BL.
        class Synthetic:
            sections = {'.text': {'addr': 0x100, 'size': 0x100}}
            def read(self, a, n):
                return struct.pack('<I', 0xeb000000)
        result = audit.scan(Synthetic(), [{'start': 0x100, 'end': 0x104}])
        self.assertEqual(result['direct_outside_buckets_inside_text_sites'], 1)
        self.assertFalse(result['full_dependency_closure'])

    def test_filter_obviously_outside_text(self):
        class Synthetic:
            sections = {'.text': {'addr': 0x100, 'size': 0x100}}
            def read(self, a, n):
                return struct.pack('<I', 0xeb100000)
        result = audit.scan(Synthetic(), [{'start': 0x100, 'end': 0x104}])
        self.assertEqual(result['direct_outside_buckets_inside_text_sites'], 0)
        self.assertEqual(len(result['rejected_direct_targets_outside_text']), 1)


class IntegrityTests(unittest.TestCase):
    def test_exact_report(self):
        got = audit.build_report()
        want = json.loads((ROOT / audit.EVIDENCE).read_text())
        self.assertEqual(got, want)
        self.assertEqual(sum(m['candidate_buckets'] for m in got['modules']), 26)
        self.assertEqual(got['candidate_bucket_bytes'], 111444)
        self.assertFalse(got['decision']['drop_in_component_proven'])
        self.assertFalse(got['decision']['isolation_impossible_proven'])
        self.assertEqual(got['elf']['type'], 2)
        self.assertFalse(got['elf']['has_pt_dynamic'])
        self.assertFalse(got['elf']['has_dynsym'])

    def test_reference_tamper_rejected(self):
        with tempfile.TemporaryDirectory() as name:
            p = Path(name) / audit.REFERENCE
            p.parent.mkdir(parents=True)
            data = bytearray(ELF.data)
            data[0x94ce8 - 0x10000] ^= 1
            p.write_bytes(data)
            with self.assertRaisesRegex(ValueError, 'SHA-256 mismatch'):
                audit.checked_elf(Path(name))

    def test_non_bucket_metadata_rejected(self):
        real_read = Path.read_bytes
        def altered(path):
            data = real_read(path)
            if str(path).endswith('tuner_base.c.json'):
                doc = json.loads(data)
                doc['candidate_intervals'][0]['start'] = '0x00081f6c'
                return json.dumps(doc).encode()
            return data
        with mock.patch.object(Path, 'read_bytes', altered):
            with self.assertRaisesRegex(ValueError, 'Invalid candidate bucket'):
                audit.module_buckets(ROOT, ELF)

    def test_wrong_literal_metadata_rejected(self):
        real_read = Path.read_bytes
        def altered(path):
            data = real_read(path)
            if str(path).endswith('tuner_base.c.json'):
                doc = json.loads(data)
                doc['observed_as'] += '.wrong'
                return json.dumps(doc).encode()
            return data
        with mock.patch.object(Path, 'read_bytes', altered):
            with self.assertRaisesRegex(ValueError, 'Source-path bytes disagree'):
                audit.module_buckets(ROOT, ELF)

    def test_cli_evidence_drift_is_failure(self):
        bad = audit.build_report()
        bad['scan']['full_dependency_closure'] = True
        with mock.patch.object(audit, 'build_report', return_value=bad):
            with mock.patch.object(sys, 'argv', ['audit', '--check']):
                with contextlib.redirect_stderr(io.StringIO()) as error:
                    self.assertEqual(audit.main(), 1)
                self.assertIn('differs from committed evidence', error.getvalue())


class OriginalWindowTests(unittest.TestCase):
    def record(self, cpu):
        COUNTS['original_window_cases'] += 1
        COUNTS['original_steps'] += cpu.steps

    def test_backend_voltage_prefix(self):
        # The complete prefix from the selected routine entry; lower calls stop
        # at reset/power-set boundary, not a real voltage operation.
        for platform in (0, 2, 4, 6):
            for cached, wanted in ((1200, 1300), (1300, 1300), (1400, 1300)):
                c = ARM32Verify(ELF); b = c.DATA_BASE
                c.write(b+0x18, b+0x900); c.write(b+0x20c, cached)
                c.reset((b, wanted)); events = []
                def selector(cpu):
                    events.append(('selector',)); cpu.r[0] = platform
                def lock(cpu):
                    events.append(('lock', cpu.r[0])); cpu.r[0] = 0xffffffff
                def cleanup(cpu):
                    events.append(('cleanup', cpu.r[2])); cpu.r[0] = 0
                same = cached == wanted
                direct = platform == 6 or cached > wanted
                stop = 0x94ec0 if same else 0x5e084 if direct else 0x6100c if platform == 0 else 0x61170
                c.run(0x94c5c, stop=stop, hooks={0xfdfbc: selector, 0x5cf40: lock,
                      0x5a48a0: cleanup}, max_steps=100)
                if same:
                    self.assertEqual(events, [('selector',)])
                elif direct:
                    self.assertEqual(events, [('selector',)])
                    self.assertEqual(c.r[:2], [b, wanted])
                else:
                    self.assertEqual(events, [('selector',), ('lock', b), ('cleanup', b)])
                    self.assertEqual(c.r[:3], [b, int(platform == 0), wanted])
                self.record(c)

    def test_frequency_edge_gate(self):
        for flag in (0, 1, 0xffffffff):
            c = ARM32Verify(ELF); c.reset(); b = c.DATA_BASE
            c.r[0] = flag; c.r[4] = b; c.r[11] = c.STACK_TOP - 128
            stop = 0x65b3c if flag else 0x86d14
            c.run(0x86c1c, stop=stop, max_steps=20)
            self.assertEqual(c.read(c.r[11]-40), b+80)
            if flag: self.assertEqual(c.r[0], b)
            self.record(c)

    def test_voltage_thread_restart_sequence(self):
        for old_status in (0, 1, 0xffffffff):
            c = ARM32Verify(ELF); c.reset(); b = c.DATA_BASE
            c.write(c.r[13]+0xc0, b); events = []
            def hook(address):
                def f(cpu):
                    events.append((address, cpu.r[0])); cpu.r[0] = old_status
                return f
            c.run(0x93aa4, stop=0x93ac0,
                  hooks={x: hook(x) for x in (0xa6080, 0xa20a0, 0x10ef3c)}, max_steps=40)
            self.assertEqual(events, [(0xa6080, b), (0xa20a0, b), (0x10ef3c, 1000)])
            self.record(c)

    def test_profile_write_condition_and_pointer(self):
        for flag in (0, 1, 0xffffffff):
            for value in (0, 0x841800):
                c = ARM32Verify(ELF); c.reset(); c.r[4] = c.DATA_BASE
                c.write(c.r[13]+16, flag); c.write(c.r[4]+0x38, value)
                c.run(0x95498, stop=0x509b4 if flag else 0x954b4, max_steps=20)
                if flag: self.assertEqual(c.r[:2], [0x5e74e8, value])
                self.record(c)

    def test_sweep_late_indirect_target(self):
        for failed in (False, True):
            for retarget in (False, True):
                c = ARM32Verify(ELF); c.reset(); b = c.DATA_BASE; chain = b+0x1000
                c.r[9] = b; c.r[7] = chain
                first, second, changed = b+0x8000, b+0x8004, b+0x8008
                c.write(b+0x14c, first); c.write(b+0x150, second); events = []
                def first_call(cpu):
                    events.append(('first', *cpu.r[:2]))
                    if retarget: cpu.write(b+0x150, changed)
                    cpu.r[0] = 1 if failed else 0
                def second_call(cpu):
                    events.append(('second', cpu.r[15], *cpu.r[:2])); cpu.r[0] = 0
                def delay(cpu):
                    events.append(('delay', cpu.r[0])); cpu.r[0] = 0
                c.run(0x9c31c, stop=0x9d73c if failed else 0x9c350,
                      hooks={first:first_call, second:second_call, changed:second_call,
                             0x10ef3c:delay}, max_steps=40)
                want = [('first', chain+0x2b8, 0)]
                if not failed:
                    want += [('delay', 10), ('second', changed if retarget else second, chain+0x2b8, 1)]
                self.assertEqual(events, want); self.record(c)

    def test_nonce_indirect_arguments(self):
        for offset in (0, 744, 1488):
            for method in (0x848000, 0x848100):
                c = ARM32Verify(ELF); c.reset(); b = c.DATA_BASE
                c.write(c.r[13]+0x34, b); c.write(b+0x1ac, method); c.write(b+0x230, b+0x1000)
                c.r[5] = offset
                c.run(0x9fd74, stop=method, max_steps=20)
                self.assertEqual(c.r[:4], [b+0x1000+offset, 0, 144, 0]); self.record(c)


if __name__ == '__main__':
    suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    print('AUTOTUNE_BOUNDARY_TESTS', json.dumps(COUNTS, sort_keys=True))
    raise SystemExit(0 if result.wasSuccessful() else 1)

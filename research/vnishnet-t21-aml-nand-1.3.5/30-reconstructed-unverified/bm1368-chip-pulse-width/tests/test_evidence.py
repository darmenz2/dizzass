#!/usr/bin/env python3
"""Finite tamper controls for the e33e0 checker; vendor bytes stay data."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('chip_pulse_evidence', HERE / 'verify_evidence.py')
VERIFY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VERIFY)


class EvidenceTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.reference = VERIFY.ROOT / 'reference/cgminer.vendor.elf'
        cls.evidence = HERE / 'evidence'
        # Missing pinned inputs are a failure, never a skipped acceptance check.
        VERIFY.verify(cls.reference, cls.evidence)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name)
        self.packet = self.work / 'evidence'
        shutil.copytree(self.evidence, self.packet)

    def verify(self, reference=None, root=None):
        return VERIFY.verify(reference or self.reference, self.packet, root or VERIFY.ROOT)

    def mutate_json(self, name, action):
        path = self.packet / name
        data = json.loads(path.read_text())
        action(data)
        path.write_text(json.dumps(data, indent=2) + '\n')

    def test_actual_reference_and_artifacts(self):
        result = self.verify()
        self.assertTrue(result['verified'])
        self.assertEqual(result['code_bytes'], 216)
        self.assertFalse(result['original_executed'])

    def test_cli_normal_and_optimized(self):
        for flags in ([], ['-O']):
            with self.subTest(flags=flags):
                result = subprocess.run([sys.executable, '-B', *flags,
                    str(HERE / 'verify_evidence.py'), '--cgminer', str(self.reference),
                    '--evidence', str(self.packet)], capture_output=True, text=True, timeout=30)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(json.loads(result.stdout)['verified'])

    def test_changed_reference_hash_rejected(self):
        path = self.work / 'changed.elf'
        data = bytearray(self.reference.read_bytes())
        data[-1] ^= 1
        path.write_bytes(data)
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'reference SHA256 mismatch'):
            self.verify(path)

    def test_reference_length_rejected(self):
        path = self.work / 'short.elf'
        path.write_bytes(self.reference.read_bytes()[:-1])
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'reference byte length mismatch'):
            self.verify(path)

    def test_refreshed_artifact_checksums_cannot_change_code(self):
        def change(record):
            altered = bytearray.fromhex(record['bytes_hex'])
            altered[20] ^= 1  # change the clock mask instruction
            record['bytes_hex'] = altered.hex()
            record['sha256'] = VERIFY.digest(altered)
        self.mutate_json('code.json', change)
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'artifact JSON mismatch: code'):
            self.verify()

    def test_wrong_mode_annotation_rejected(self):
        path = self.packet / 'code.asm'
        text = path.read_text()
        self.assertIn('mov        r1, #0', text)
        path.write_text(text.replace('mov        r1, #0', 'mov        r1, #1', 1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'artifact assembly mismatch: code'):
            self.verify()

    def test_missing_fresh_index_annotation_rejected(self):
        path = self.packet / 'code.asm'
        text = path.read_text()
        self.assertIn('000e3478', text)
        path.write_text(''.join(line for line in text.splitlines(keepends=True)
                                if not line.startswith('000e3478')))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'artifact assembly mismatch: code'):
            self.verify()

    def test_literal_annotation_rejected(self):
        path = self.packet / 'literals.asm'
        path.write_text(path.read_text().replace('0x00507f98', '0x00507f99', 1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'artifact assembly mismatch: literals'):
            self.verify()

    def test_constructor_slot_change_rejected(self):
        path = self.packet / 'constructor.asm'
        path.write_text(path.read_text().replace('#0x74', '#0x78', 1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'artifact assembly mismatch: constructor'):
            self.verify()

    def test_manifest_source_change_rejected(self):
        self.mutate_json('manifest.json', lambda data: data['source'].update(size=1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'manifest differs'):
            self.verify()

    def test_manifest_region_boundary_change_rejected(self):
        self.mutate_json('manifest.json', lambda data: data['regions'][0].update(end=0xe34cc))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'manifest differs'):
            self.verify()

    def test_manifest_execution_claim_rejected(self):
        self.mutate_json('manifest.json', lambda data: data.update(original_executed=True))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'manifest differs'):
            self.verify()

    def test_extra_json_key_rejected(self):
        self.mutate_json('code.json', lambda data: data.update(extra='unreviewed'))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'artifact JSON mismatch: code'):
            self.verify()

    def test_duplicate_json_keys_rejected(self):
        (self.packet / 'manifest.json').write_text('{"schema":1,"schema":1}')
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'duplicate JSON key'):
            self.verify()

    def test_nonfinite_json_rejected(self):
        (self.packet / 'manifest.json').write_text('{"schema":NaN}')
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'nonfinite JSON constant'):
            self.verify()

    def test_boolean_cannot_replace_integer(self):
        self.mutate_json('manifest.json', lambda data: data.update(schema=True))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'manifest differs'):
            self.verify()

    def test_oversized_artifact_rejected(self):
        (self.packet / 'code.json').write_bytes(b' ' * (VERIFY.MAX_ARTIFACT_BYTES + 1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'file exceeds bounded size'):
            self.verify()

    def test_accepted_initializer_dependency_tamper_rejected(self):
        path = self.work / VERIFY.RESEARCH / 'bm1368-reset/static-witness.json'
        path.parent.mkdir(parents=True)
        original = VERIFY.ROOT / VERIFY.RESEARCH / 'bm1368-reset/static-witness.json'
        data = json.loads(original.read_text())
        data['kind'] = 'changed-but-valid-json'
        path.write_text(json.dumps(data))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'accepted reset initializer witness changed'):
            self.verify(root=self.work)

    def test_lf_and_crlf_initializer_witness_are_equivalent(self):
        path = self.work / VERIFY.RESEARCH / 'bm1368-reset/static-witness.json'
        path.parent.mkdir(parents=True)
        original = VERIFY.ROOT / VERIFY.RESEARCH / 'bm1368-reset/static-witness.json'
        canonical_lf = original.read_bytes().replace(b'\r\n', b'\n')
        self.assertEqual(len(canonical_lf), VERIFY.RESET_SIZE)
        self.assertEqual(VERIFY.digest(canonical_lf), VERIFY.RESET_SHA256)
        for name, data in (('LF', canonical_lf),
                           ('CRLF', canonical_lf.replace(b'\n', b'\r\n'))):
            with self.subTest(line_endings=name):
                path.write_bytes(data)
                self.assertTrue(self.verify(root=self.work)['verified'])

    def test_lone_cr_initializer_witness_is_not_normalized(self):
        path = self.work / VERIFY.RESEARCH / 'bm1368-reset/static-witness.json'
        path.parent.mkdir(parents=True)
        original = VERIFY.ROOT / VERIFY.RESEARCH / 'bm1368-reset/static-witness.json'
        canonical_lf = original.read_bytes().replace(b'\r\n', b'\n')
        path.write_bytes(canonical_lf.replace(b'\n', b'\r', 1))
        with self.assertRaisesRegex(VERIFY.EvidenceError, 'accepted reset initializer witness changed'):
            self.verify(root=self.work)

    def test_tamper_is_rejected_by_optimized_cli(self):
        self.mutate_json('manifest.json', lambda data: data.update(original_executed=True))
        result = subprocess.run([sys.executable, '-B', '-O', str(HERE / 'verify_evidence.py'),
            '--cgminer', str(self.reference), '--evidence', str(self.packet)],
            capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 2)
        self.assertIn('manifest differs', result.stderr)


if __name__ == '__main__':
    unittest.main(verbosity=2)

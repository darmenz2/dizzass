#!/usr/bin/env python3
"""Caller-wiring controls with synthetic metadata; full suites check real evidence."""
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_dependency_pins_135 as pins

ROOT = Path(__file__).resolve().parents[2]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


a08 = module('native_boundary_a08', ROOT / 'integration/tests/check_chain_temperature_setup_evidence_135.py')
a15 = module('native_boundary_a15', ROOT / 'tools/prepare_protocol_channel_tx.py')


class BoundaryCallers(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.current = (ROOT / pins.NATIVE_CHECKER_PATH).read_bytes()
        self.old = pins.historical_native_checker_bytes(self.current)
        self.put(pins.NATIVE_CHECKER_PATH, self.current)
        self.other = 'integration/unrelated-fixture.txt'
        self.put(self.other, b'unchanged fixture\n')
        self.other_blob = pins.git_blob(b'unchanged fixture\n')
        self.other_sha = hashlib.sha256(b'unchanged fixture\n').hexdigest()
        self.fake_reference = b'synthetic metadata wiring fixture; no original instructions'
        self.evidence = {
            'reference_sha256': hashlib.sha256(self.fake_reference).hexdigest(),
            'ranges': [], 'strings': [], 'instruction_words': {}, 'literal_edges': [],
            'immutable': {pins.NATIVE_CHECKER_PATH: pins.NATIVE_CHECKER_OLD_BLOB,
                          self.other: self.other_blob},
        }
        self.manifest = {'unchanged': [
            {'path': pins.NATIVE_CHECKER_PATH, 'blob': pins.NATIVE_CHECKER_OLD_BLOB,
             'sha256': pins.NATIVE_CHECKER_OLD_SHA256},
            {'path': self.other, 'blob': self.other_blob, 'sha256': self.other_sha}],
            'pending': []}

    def put(self, path, raw):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        return target

    def check_a08(self):
        self.put('integration/evidence/chain_temperature_setup_135.json',
                 json.dumps(self.evidence).encode())
        fake_elf = type('SyntheticELF', (), {'data': self.fake_reference})()
        with patch.object(a08, 'ROOT', self.root), patch.object(a08, 'ELF32', return_value=fake_elf), \
                contextlib.redirect_stdout(io.StringIO()):
            a08.main()

    def check_a15(self):
        path = self.put('integration/evidence/protocol_channel_tx_dependencies.json',
                        json.dumps(self.manifest).encode())
        output = self.root / 'build/a15-deps'
        with patch.object(a15, 'ROOT', self.root), patch.object(a15, 'MANIFEST', path):
            a15.prepare(output, None, output.exists())

    def both_reject(self):
        for name, check in (('A08', self.check_a08), ('A15', self.check_a15)):
            with self.subTest(caller=name), self.assertRaises((ValueError, AssertionError)):
                check()

    def test_exact_current_checker_reaches_both_real_callers(self):
        self.check_a08()
        self.check_a15()
        self.check_a15()  # Existing output uses the untouched --check path.
        self.assertEqual((self.root / 'build/a15-deps/.gitignore').read_bytes(), b'*\n')

    def test_both_reject_old_or_changed_current_checker(self):
        for raw in (self.old, self.current + b'\n', b'X' + self.current[1:]):
            self.put(pins.NATIVE_CHECKER_PATH, raw)
            self.both_reject()

    def test_both_reject_changed_original_blob_pin(self):
        for wrong in ('0' * 40, pins.NATIVE_CHECKER_CURRENT_BLOB):
            self.evidence['immutable'][pins.NATIVE_CHECKER_PATH] = wrong
            self.manifest['unchanged'][0]['blob'] = wrong
            self.both_reject()

    def test_a15_preserves_original_sha256_independently_of_original_blob(self):
        self.assertEqual(self.manifest['unchanged'][0]['blob'], pins.NATIVE_CHECKER_OLD_BLOB)
        for wrong in ('0' * 64, pins.NATIVE_CHECKER_CURRENT_SHA256):
            self.manifest['unchanged'][0]['sha256'] = wrong
            with self.assertRaisesRegex(ValueError, 'hash mismatch'):
                self.check_a15()

    def test_a15_preserves_unrelated_dependency_checks(self):
        self.put(self.other, b'changed fixture\n')
        with self.assertRaisesRegex(ValueError, 'hash mismatch'):
            self.check_a15()

    def test_a15_native_transition_does_not_apply_to_copied_path(self):
        copied = pins.NATIVE_CHECKER_PATH + '.copy'
        self.put(copied, self.current)
        self.manifest['unchanged'][0]['path'] = copied
        with self.assertRaisesRegex(ValueError, 'hash mismatch'):
            self.check_a15()

    def test_both_reject_native_checker_executable_or_symlink(self):
        target = self.root / pins.NATIVE_CHECKER_PATH
        target.chmod(0o755)
        self.both_reject()
        target.chmod(0o644)
        real = self.put(pins.NATIVE_CHECKER_PATH + '.real', self.current)
        target.unlink()
        target.symlink_to(real)
        self.both_reject()

    def test_a15_pending_blobs_keep_both_hash_checks(self):
        # No native-checker transition is applied in the generic pending verifier.
        entry = {'path': 'integration/native/fixture.h', 'blob': self.other_blob,
                 'sha256': self.other_sha}
        a15.verify(b'unchanged fixture\n', entry)
        for field, wrong in (('blob', '0' * 40), ('sha256', '0' * 64)):
            changed = dict(entry, **{field: wrong})
            with self.assertRaisesRegex(ValueError, 'hash mismatch'):
                a15.verify(b'unchanged fixture\n', changed)


if __name__ == '__main__':
    unittest.main(verbosity=2)

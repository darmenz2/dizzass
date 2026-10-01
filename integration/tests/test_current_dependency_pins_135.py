#!/usr/bin/env python3
"""Host-only pin controls: no firmware execution, ARM interpretation or devices."""
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_dependency_pins_135 as pins

ROOT = Path(__file__).resolve().parents[2]


class CurrentDependencyPins(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.thermal = (ROOT / pins.THERMAL_PATH).read_bytes()
        self.dispatch = (ROOT / pins.DISPATCH_PATH).read_bytes()
        self.old_thermal = pins.historical_thermal_bytes(self.thermal)
        self.old_dispatch = pins.historical_dispatch_bytes(self.dispatch)
        self.put(pins.THERMAL_PATH, self.thermal)
        self.put(pins.DISPATCH_PATH, self.dispatch)
        self.other = 'integration/unchanged-dependency.h'
        self.put(self.other, b'unchanged\n')
        self.other_sha = pins.git_blob(b'unchanged\n')

    def put(self, path, raw):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
        return target

    def check(self, path, expected):
        pins.check_current_dependency(self.root, path, expected)

    def pairs(self):
        return ((pins.THERMAL_PATH, pins.THERMAL_OLD_BLOB, self.thermal,
                 self.old_thermal),
                (pins.DISPATCH_PATH, pins.DISPATCH_OLD_BLOB, self.dispatch,
                 self.old_dispatch))

    def test_exact_current_blobs_and_original_witnesses(self):
        self.assertEqual(pins.git_blob(self.thermal), pins.THERMAL_CURRENT_BLOB)
        self.assertEqual(pins.git_blob(self.dispatch), pins.DISPATCH_CURRENT_BLOB)
        self.assertEqual(pins.git_blob(self.old_thermal), pins.THERMAL_OLD_BLOB)
        self.assertEqual(pins.git_blob(self.old_dispatch), pins.DISPATCH_OLD_BLOB)
        self.assertEqual(len(self.old_dispatch), pins.DISPATCH_OLD_SIZE)
        for path, old_sha, _, _ in self.pairs():
            self.check(path, old_sha)

    def test_historical_blobs_rejected_as_current_checkout(self):
        for path, old_sha, _, old in self.pairs():
            with self.subTest(path=path):
                self.put(path, old)
                with self.assertRaises(ValueError):
                    self.check(path, old_sha)

    def test_changed_original_pin_rejected(self):
        for path, _, current, _ in self.pairs():
            for wrong in ('0' * 40, pins.git_blob(current), None):
                with self.subTest(path=path, expected=wrong):
                    with self.assertRaises(ValueError):
                        self.check(path, wrong)

    def test_arbitrary_content_rejected(self):
        for path, old_sha, current, _ in self.pairs():
            for mutant in (b'', b'arbitrary\n', current + b'\n', current[:-1],
                           current.replace(b'\n', b'\r\n')):
                with self.subTest(path=path, size=len(mutant)):
                    self.put(path, mutant)
                    with self.assertRaises(ValueError):
                        self.check(path, old_sha)

    def test_thermal_token_location_and_other_flags_rejected(self):
        for mutant in (
                self.thermal.replace(b'-Iinclude ', b''),
                self.thermal.replace(b'-Iinclude ', b'-Iinclude -Iinclude '),
                self.thermal.replace(b'-Iinclude ', b'') + b'# -Iinclude\n',
                self.thermal.replace(b'-O1 ', b'-O2 '),
                self.thermal.replace(b'-Iinclude ', b'-I./include ')):
            self.put(pins.THERMAL_PATH, mutant)
            with self.assertRaises(ValueError):
                self.check(pins.THERMAL_PATH, pins.THERMAL_OLD_BLOB)

    def test_dispatch_prefix_and_gate_mutations_rejected(self):
        for mutant in (
                b'X' + self.dispatch[1:],
                self.dispatch.replace(b'VN135_TRANSPORT_INITIALIZE_135', b'OTHER_GATE'),
                self.dispatch.replace(b'UINT32_C(0xd253c)', b'UINT32_C(0xd253d)'),
                self.dispatch + b'int extra;\n',
                self.dispatch[:-7]):
            self.put(pins.DISPATCH_PATH, mutant)
            with self.assertRaises(ValueError):
                self.check(pins.DISPATCH_PATH, pins.DISPATCH_OLD_BLOB)

    def test_reverse_witness_checked_independently_of_current_hash(self):
        with patch.object(pins, 'THERMAL_OLD_BLOB', '0' * 40):
            with self.assertRaises(ValueError):
                pins.historical_thermal_bytes(self.thermal)
        with patch.object(pins, 'DISPATCH_OLD_BLOB', '0' * 40):
            with self.assertRaises(ValueError):
                pins.historical_dispatch_bytes(self.dispatch)

    def test_transition_shape_checked_independently_of_current_hash(self):
        mutant = self.thermal.replace(b'ROUTES135_FLAGS =', b'OTHER_FLAGS =')
        with patch.object(pins, 'THERMAL_CURRENT_BLOB', pins.git_blob(mutant)):
            with self.assertRaises(ValueError):
                pins.historical_thermal_bytes(mutant)
        mutant = self.dispatch.replace(b'VN135_TRANSPORT_INITIALIZE_135', b'OTHER_GATE')
        with patch.object(pins, 'DISPATCH_CURRENT_BLOB', pins.git_blob(mutant)):
            with self.assertRaises(ValueError):
                pins.historical_dispatch_bytes(mutant)

    def test_transition_cannot_be_applied_to_another_path(self):
        for path, old_sha, current, _ in self.pairs():
            alternate = path + '.copy'
            self.put(alternate, current)
            with self.assertRaises(ValueError):
                self.check(alternate, old_sha)

    def test_unrelated_pin_passes_and_mismatch_fails(self):
        self.check(self.other, self.other_sha)
        self.put(self.other, b'changed\n')
        with self.assertRaises(ValueError):
            self.check(self.other, self.other_sha)

    def test_missing_paths_fail(self):
        for path, expected in ((pins.THERMAL_PATH, pins.THERMAL_OLD_BLOB),
                               (pins.DISPATCH_PATH, pins.DISPATCH_OLD_BLOB),
                               (self.other, self.other_sha)):
            (self.root / path).unlink()
            with self.assertRaises(FileNotFoundError):
                self.check(path, expected)

    def test_directories_and_symlinks_fail(self):
        for path, old_sha, current, _ in self.pairs():
            target = self.root / path
            target.unlink()
            target.mkdir()
            with self.assertRaises(ValueError):
                self.check(path, old_sha)
            target.rmdir()
            original = self.put(path + '.real', current)
            target.symlink_to(original)
            with self.assertRaises(ValueError):
                self.check(path, old_sha)

    def test_executable_mode_fails(self):
        for path, old_sha, _, _ in self.pairs():
            (self.root / path).chmod(0o755)
            with self.assertRaises(ValueError):
                self.check(path, old_sha)

    def test_fifo_fails_without_reading_or_blocking(self):
        target = self.root / pins.THERMAL_PATH
        target.unlink()
        os.mkfifo(target)
        with self.assertRaises(ValueError):
            self.check(pins.THERMAL_PATH, pins.THERMAL_OLD_BLOB)

    def test_parent_symlink_fails(self):
        parent = self.root / 'libbitmain'
        parent.rename(self.root / 'actual-libbitmain')
        parent.symlink_to(self.root / 'actual-libbitmain', target_is_directory=True)
        with self.assertRaises(ValueError):
            self.check(pins.DISPATCH_PATH, pins.DISPATCH_OLD_BLOB)

    def test_unsafe_or_noncanonical_paths_fail(self):
        for path in ('', '/tmp/file', '../file', 'integration/../file',
                     './' + pins.THERMAL_PATH, 'integration//thermal-routes-135.mk',
                     'integration/./thermal-routes-135.mk', None):
            with self.subTest(path=path):
                with self.assertRaises(ValueError):
                    self.check(path, pins.THERMAL_OLD_BLOB)


if __name__ == '__main__':
    unittest.main(verbosity=2)

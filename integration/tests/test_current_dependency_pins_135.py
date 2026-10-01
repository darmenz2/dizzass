#!/usr/bin/env python3
"""Host-only pin controls: no firmware execution, ARM interpretation or devices."""
import os
from contextlib import contextmanager
import hashlib
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
        self.bm1368 = (ROOT / pins.BM1368_PATH).read_bytes()
        self.old_thermal = pins.historical_thermal_bytes(self.thermal)
        self.old_dispatch = pins.historical_dispatch_bytes(self.dispatch)
        self.old_bm1368 = pins.historical_bm1368_bytes(self.bm1368)
        self.reset_bm1368 = pins.reset_bm1368_bytes(self.bm1368)
        self.ticket_bm1368 = pins.ticket_bm1368_bytes(self.bm1368)
        self.ticket_append = self.ticket_bm1368[pins.BM1368_RESET_SIZE:]
        self.sweep_bm1368 = pins.sweep_bm1368_bytes(self.bm1368)
        self.sweep_append = self.sweep_bm1368[pins.BM1368_TICKET_SIZE:]
        self.address_append = self.bm1368[pins.BM1368_SWEEP_SIZE:]
        self.constructor_bm1368 = pins.constructor_bm1368_bytes(self.bm1368)
        self.put(pins.THERMAL_PATH, self.thermal)
        self.put(pins.DISPATCH_PATH, self.dispatch)
        self.put(pins.BM1368_PATH, self.bm1368)
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

    @contextmanager
    def accept_address_bm1368_identity(self, raw):
        # Bypass every full-source identity predicate so a failed prefix/gate
        # check is independently demonstrated rather than masked by hashing.
        with patch.multiple(pins, BM1368_CURRENT_SIZE=len(raw),
                            BM1368_CURRENT_BLOB=pins.git_blob(raw),
                            BM1368_CURRENT_SHA256=hashlib.sha256(raw).hexdigest()):
            yield

    @contextmanager
    def accept_current_bm1368_identity(self, raw):
        # Existing inner controls match both new-current and sweep identities.
        # The separately tested address-only helper leaves the sweep pin live.
        sweep = raw[:-len(self.address_append)]
        with self.accept_address_bm1368_identity(raw), patch.multiple(
                pins, BM1368_SWEEP_SIZE=len(sweep),
                BM1368_SWEEP_BLOB=pins.git_blob(sweep),
                BM1368_SWEEP_SHA256=hashlib.sha256(sweep).hexdigest()):
            yield

    @contextmanager
    def accept_ticket_bm1368_identity(self, raw):
        with patch.multiple(pins, BM1368_TICKET_SIZE=len(raw),
                            BM1368_TICKET_BLOB=pins.git_blob(raw),
                            BM1368_TICKET_SHA256=hashlib.sha256(raw).hexdigest()):
            yield

    @contextmanager
    def accept_current_and_ticket_identity(self, raw):
        # Older inner-predicate tests carry the unchanged outer sweep append.
        # Both identities are matched so neither can mask an inner failure.
        ticket = raw[:-len(self.sweep_append)-len(self.address_append)]
        with self.accept_current_bm1368_identity(raw), \
                self.accept_ticket_bm1368_identity(ticket):
            yield

    @contextmanager
    def accept_reset_bm1368_identity(self, raw):
        # Bypass this intermediate identity only to exercise deeper predicates.
        with patch.multiple(pins, BM1368_RESET_SIZE=len(raw),
                            BM1368_RESET_BLOB=pins.git_blob(raw),
                            BM1368_RESET_SHA256=hashlib.sha256(raw).hexdigest()):
            yield

    @contextmanager
    def accept_constructor_bm1368_identity(self, raw):
        with patch.multiple(pins, BM1368_CONSTRUCTOR_SIZE=len(raw),
                            BM1368_CONSTRUCTOR_BLOB=pins.git_blob(raw),
                            BM1368_CONSTRUCTOR_SHA256=hashlib.sha256(raw).hexdigest()):
            yield

    def pairs(self):
        return ((pins.THERMAL_PATH, pins.THERMAL_OLD_BLOB, self.thermal,
                 self.old_thermal),
                (pins.DISPATCH_PATH, pins.DISPATCH_OLD_BLOB, self.dispatch,
                 self.old_dispatch),
                (pins.BM1368_PATH, pins.BM1368_OLD_BLOB, self.bm1368,
                 self.old_bm1368))

    def test_exact_current_blobs_and_original_witnesses(self):
        self.assertEqual(pins.git_blob(self.thermal), pins.THERMAL_CURRENT_BLOB)
        self.assertEqual(pins.git_blob(self.dispatch), pins.DISPATCH_CURRENT_BLOB)
        self.assertEqual(pins.git_blob(self.bm1368), pins.BM1368_CURRENT_BLOB)
        self.assertEqual(len(self.bm1368), pins.BM1368_CURRENT_SIZE)
        self.assertEqual(hashlib.sha256(self.bm1368).hexdigest(), pins.BM1368_CURRENT_SHA256)
        self.assertEqual(len(self.constructor_bm1368), pins.BM1368_CONSTRUCTOR_SIZE)
        self.assertEqual(pins.git_blob(self.constructor_bm1368), pins.BM1368_CONSTRUCTOR_BLOB)
        self.assertEqual(hashlib.sha256(self.constructor_bm1368).hexdigest(),
                         pins.BM1368_CONSTRUCTOR_SHA256)
        self.assertEqual(pins.git_blob(self.old_thermal), pins.THERMAL_OLD_BLOB)
        self.assertEqual(pins.git_blob(self.old_dispatch), pins.DISPATCH_OLD_BLOB)
        self.assertEqual(len(self.old_dispatch), pins.DISPATCH_OLD_SIZE)
        self.assertEqual(pins.git_blob(self.old_bm1368), pins.BM1368_OLD_BLOB)
        self.assertEqual(len(self.old_bm1368), pins.BM1368_OLD_SIZE)
        for path, old_sha, _, _ in self.pairs():
            self.check(path, old_sha)

    def test_historical_blobs_rejected_as_current_checkout(self):
        for path, old_sha, _, old in self.pairs():
            with self.subTest(path=path):
                self.put(path, old)
                with self.assertRaises(ValueError):
                    self.check(path, old_sha)

    def test_constructor_only_blob_rejected_as_current_checkout(self):
        self.put(pins.BM1368_PATH, self.constructor_bm1368)
        with self.assertRaisesRegex(ValueError, 'not the reviewed address-commands blob'):
            self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

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
        with patch.object(pins, 'BM1368_OLD_BLOB', '0' * 40):
            with self.assertRaises(ValueError):
                pins.historical_bm1368_bytes(self.bm1368)

    def test_bm1368_prefix_and_gate_mutations_rejected(self):
        for mutant in (
                b'X' + self.bm1368[1:],
                self.bm1368.replace(b'VN135_BM1368_INITIALIZE_135', b'OTHER_GATE'),
                self.bm1368.replace(b'UINT32_C(0xe4a6c)', b'UINT32_C(0xe4a70)'),
                self.bm1368 + b'int extra;\n',
                self.bm1368[:-7]):
            self.put(pins.BM1368_PATH, mutant)
            with self.assertRaises(ValueError):
                self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_bm1368_prefix_checked_independently_of_current_hash(self):
        mutant = b'X' + self.bm1368[1:]
        constructor = mutant[:pins.BM1368_CONSTRUCTOR_SIZE]
        with self.accept_current_and_ticket_identity(mutant), \
                self.accept_reset_bm1368_identity(mutant[:pins.BM1368_RESET_SIZE]):
            with self.accept_constructor_bm1368_identity(constructor):
                with self.assertRaisesRegex(ValueError, 'historical prefix changed'):
                    pins.historical_bm1368_bytes(mutant)

    def test_constructor_prefix_checked_independently_of_current_hash(self):
        for offset in (0, pins.BM1368_OLD_SIZE, pins.BM1368_CONSTRUCTOR_SIZE - 1):
            mutant = bytearray(self.bm1368)
            mutant[offset] ^= 1
            mutant = bytes(mutant)
            with self.subTest(offset=offset):
                with self.accept_current_and_ticket_identity(mutant), \
                        self.accept_reset_bm1368_identity(mutant[:pins.BM1368_RESET_SIZE]):
                    with self.assertRaisesRegex(ValueError, 'constructor source prefix changed'):
                        pins.constructor_bm1368_bytes(mutant)

    def test_constructor_witness_hashes_are_independent(self):
        for constant in ('BM1368_CONSTRUCTOR_BLOB', 'BM1368_CONSTRUCTOR_SHA256'):
            with patch.object(pins, constant, '0' * len(getattr(pins, constant))):
                with self.assertRaisesRegex(ValueError, 'constructor source prefix changed'):
                    pins.constructor_bm1368_bytes(self.bm1368)

    def test_preserved_ticket_identity_components_are_independent(self):
        for constant, wrong in (('BM1368_TICKET_BLOB', '0' * 40),
                                ('BM1368_TICKET_SHA256', '0' * 64),
                                ('BM1368_TICKET_SIZE', 8350 - 1)):
            with patch.object(pins, constant, wrong):
                with self.assertRaisesRegex(ValueError, 'preserved ticket source prefix changed'):
                    pins.constructor_bm1368_bytes(self.bm1368)

    def test_reset_prefix_and_gate_mutations_rejected(self):
        for mutant in (
                self.bm1368.replace(b'VN135_BM1368_RESET_135', b'OTHER_RESET_GATE'),
                self.bm1368.replace(b'"integration/bm1368_reset_135.h"', b'"wrong.h"'),
                self.bm1368.replace(b'UINT32_C(0x800082aa)', b'UINT32_C(0x800082ab)'),
                self.bm1368 + self.bm1368[pins.BM1368_CONSTRUCTOR_SIZE:],
                self.bm1368 + b'int outside;\n', self.bm1368[:-1]):
            self.put(pins.BM1368_PATH, mutant)
            with self.assertRaises(ValueError):
                self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_reset_gate_shape_checked_independently_of_current_hash(self):
        added = self.reset_bm1368[pins.BM1368_CONSTRUCTOR_SIZE:]
        for suffix in (
                added.replace(b'VN135_BM1368_RESET_135', b'OTHER_GATE'),
                added.replace(b'"integration/bm1368_reset_135.h"', b'"wrong.h"'),
                b'int outside;\n' + added,
                added.replace(b'\n#endif\n', b'\n#endif\nint outside;\n\n'),
                added.replace(b'\n#endif\n', b'\n#if OTHER\n#endif\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#else\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#elif OTHER\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#include "extra.h"\n#endif\n'),
                added + added, added[:-8]):
            reset = self.constructor_bm1368 + suffix
            mutant = reset + self.ticket_append + self.sweep_append + self.address_append
            with self.subTest(suffix=suffix[:60]):
                with self.accept_current_and_ticket_identity(mutant), \
                        self.accept_reset_bm1368_identity(reset):
                    with self.assertRaisesRegex(ValueError, 'reset append is not separately gated'):
                        pins.constructor_bm1368_bytes(mutant)

    def test_constructor_expected_pin_is_not_an_old_evidence_pin(self):
        with self.assertRaisesRegex(ValueError, 'historical BM1368 chip pin changed'):
            self.check(pins.BM1368_PATH, pins.BM1368_CONSTRUCTOR_BLOB)

    def test_reset_transition_cannot_be_applied_to_another_path(self):
        alternate = pins.BM1368_PATH + '.reset-copy'
        self.put(alternate, self.bm1368)
        with self.assertRaises(ValueError):
            pins.check_current_dependency(self.root, alternate, pins.BM1368_CONSTRUCTOR_BLOB)

    def test_missing_reset_append_rejected_even_with_changed_full_identity(self):
        mutant = self.constructor_bm1368 + self.ticket_append + self.sweep_append + self.address_append
        with self.accept_current_and_ticket_identity(mutant), \
                self.accept_reset_bm1368_identity(self.constructor_bm1368):
            with self.assertRaisesRegex(ValueError, 'reset append is not separately gated'):
                pins.constructor_bm1368_bytes(mutant)

    def test_nonce_witness_remains_checked_after_all_transitions(self):
        with patch.object(pins, 'BM1368_OLD_BLOB', '0' * 40):
            with self.assertRaisesRegex(ValueError, 'historical prefix changed'):
                pins.historical_bm1368_bytes(self.bm1368)

    def test_bm1368_gate_shape_checked_independently_of_current_hash(self):
        old, added = self.old_bm1368, self.constructor_bm1368[pins.BM1368_OLD_SIZE:]
        reset = self.reset_bm1368[pins.BM1368_CONSTRUCTOR_SIZE:]
        for suffix in (
                added.replace(b'VN135_BM1368_INITIALIZE_135', b'OTHER_GATE'),
                b'int outside;\n' + added,
                added.replace(b'\n#endif\n', b'\n#endif\nint outside;\n'),
                added.replace(b'\n#endif\n', b'\n#if OTHER\n#endif\n#endif\n'),
                added + added,
                added[:-7]):
            constructor = old + suffix
            reset_source = constructor + reset
            mutant = reset_source + self.ticket_append + self.sweep_append + self.address_append
            with self.subTest(suffix=suffix[:60]):
                with self.accept_current_and_ticket_identity(mutant), \
                        self.accept_reset_bm1368_identity(reset_source):
                    with self.accept_constructor_bm1368_identity(constructor):
                        with self.assertRaisesRegex(ValueError, 'constructor append is not separately gated'):
                            pins.historical_bm1368_bytes(mutant)

    def test_exact_preserved_reset_witness(self):
        self.assertEqual(len(self.reset_bm1368), 7519)
        self.assertEqual(pins.git_blob(self.reset_bm1368),
                         'e024519eda8df9c1c85697548e8e0629f7c0f5cf')
        self.assertEqual(hashlib.sha256(self.reset_bm1368).hexdigest(),
                         'e3c8cecb8869c59847db357d26541e95123fa1cb4cf2ef04642a62c2e1e0738d')
        self.assertEqual(self.ticket_bm1368, self.reset_bm1368 + self.ticket_append)

    def test_reset_only_blob_rejected_as_current_checkout(self):
        self.put(pins.BM1368_PATH, self.reset_bm1368)
        with self.assertRaisesRegex(ValueError, 'not the reviewed address-commands blob'):
            self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_preserved_reset_identity_components_are_independent(self):
        for constant, wrong in (('BM1368_RESET_BLOB', '0' * 40),
                                ('BM1368_RESET_SHA256', '0' * 64),
                                ('BM1368_RESET_SIZE', 7518)):
            with self.subTest(constant=constant), patch.object(pins, constant, wrong):
                with self.assertRaisesRegex(ValueError, 'preserved reset source prefix changed'):
                    pins.reset_bm1368_bytes(self.bm1368)

    def test_reset_prefix_checked_independently_of_ticket_hash(self):
        for offset in (0, 920, 3802, 3803, 7518):
            raw = bytearray(self.bm1368)
            raw[offset] ^= 1
            mutant = bytes(raw)
            with self.subTest(offset=offset), self.accept_current_and_ticket_identity(mutant):
                with self.assertRaisesRegex(ValueError, 'preserved reset source prefix changed'):
                    pins.reset_bm1368_bytes(mutant)

    def test_ticket_gate_shape_checked_independently_of_current_hash(self):
        added = self.ticket_append
        suffixes = (b'',
                added.replace(b'VN135_BM1368_TICKET_MASK_135', b'OTHER_GATE'),
                added.replace(b'"integration/bm1368_ticket_mask_135.h"', b'"wrong.h"'),
                b'int outside;\n' + added,
                added.replace(b'\n#endif\n', b'\n#endif\nint outside;\n\n'),
                added.replace(b'\n#endif\n', b'\n#if OTHER\n#endif\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#else\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#elif OTHER\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#include "extra.h"\n#endif\n'),
                added + added, added[:-8])
        for suffix in suffixes:
            mutant = self.reset_bm1368 + suffix + self.sweep_append + self.address_append
            with self.subTest(suffix=suffix[:60]), self.accept_current_and_ticket_identity(mutant):
                with self.assertRaisesRegex(ValueError, 'ticket-mask append is not separately gated'):
                    pins.reset_bm1368_bytes(mutant)

    def test_ticket_bytes_missing_duplicate_and_changed_fail_closed(self):
        for mutant in (self.reset_bm1368, self.bm1368 + self.ticket_append,
                       self.bm1368.replace(b'0x14, value,', b'0x15, value,'),
                       self.bm1368.replace(b'TICKET_MASK", 507,', b'TICKET_MASK", 508,')):
            self.put(pins.BM1368_PATH, mutant)
            with self.assertRaises(ValueError):
                self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_reset_and_ticket_pins_cannot_replace_nonce_expected_pin(self):
        for expected in (pins.BM1368_RESET_BLOB, pins.BM1368_TICKET_BLOB,
                         pins.BM1368_SWEEP_BLOB, pins.BM1368_CURRENT_BLOB):
            with self.assertRaisesRegex(ValueError, 'historical BM1368 chip pin changed'):
                self.check(pins.BM1368_PATH, expected)

    def test_exact_preserved_ticket_witness(self):
        self.assertEqual(len(self.ticket_bm1368), 8350)
        self.assertEqual(pins.git_blob(self.ticket_bm1368),
                         '1cd2c6e7612b494c28f0bbbab0e62434d104881d')
        self.assertEqual(hashlib.sha256(self.ticket_bm1368).hexdigest(),
                         'ed818babcb847fb38094af8f08ae3c0ac6ef690192aa1e6030c3f8326e9968d9')
        self.assertEqual(self.sweep_bm1368, self.ticket_bm1368 + self.sweep_append)

    def test_preserved_sweep_identity_components_are_independent(self):
        for constant, wrong in (('BM1368_SWEEP_BLOB', '0' * 40),
                                ('BM1368_SWEEP_SHA256', '0' * 64),
                                ('BM1368_SWEEP_SIZE', 9244)):
            with self.subTest(constant=constant), patch.object(pins, constant, wrong):
                with self.assertRaisesRegex(ValueError, 'preserved sweep source prefix changed'):
                    pins.historical_bm1368_bytes(self.bm1368)

    def test_ticket_only_source_rejected_as_current(self):
        self.put(pins.BM1368_PATH, self.ticket_bm1368)
        with self.assertRaisesRegex(ValueError, 'not the reviewed address-commands blob'):
            self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_ticket_prefix_checked_without_sweep_full_hash(self):
        for offset in (0, 920, 3802, 3803, 7518, 7519, 8349):
            raw = bytearray(self.bm1368)
            raw[offset] ^= 1
            mutant = bytes(raw)
            with self.subTest(offset=offset), self.accept_current_bm1368_identity(mutant):
                with self.assertRaisesRegex(ValueError, 'preserved ticket source prefix changed'):
                    pins.ticket_bm1368_bytes(mutant)

    def test_sweep_gate_shape_checked_without_full_hash(self):
        added = self.sweep_append
        suffixes = (b'',
                added.replace(b'VN135_BM1368_SWEEP_CLOCK_135', b'OTHER_GATE'),
                added.replace(b'"integration/bm1368_sweep_clock_135.h"', b'"wrong.h"'),
                b'int outside;\n' + added,
                added.replace(b'\n#endif\n', b'\n#endif\nint outside;\n\n'),
                added.replace(b'\n#endif\n', b'\n#if OTHER\n#endif\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#else\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#elif OTHER\n#endif\n'),
                added.replace(b'\n#endif\n', b'\n#include "extra.h"\n#endif\n'),
                added + added, added[:-8])
        for suffix in suffixes:
            mutant = self.ticket_bm1368 + suffix + self.address_append
            with self.subTest(suffix=suffix[:60]), self.accept_current_bm1368_identity(mutant):
                with self.assertRaisesRegex(ValueError, 'sweep-clock append is not separately gated'):
                    pins.ticket_bm1368_bytes(mutant)

    def test_sweep_semantics_and_extra_bytes_fail_current_pin(self):
        for suffix in (self.sweep_append.replace(b'field1_2 & 3u', b'field1_2 & 7u'),
                       self.sweep_append.replace(b'<< 1', b'<< 2'),
                       self.sweep_append.replace(b'463, 1,', b'464, 1,'),
                       self.sweep_append + b'\n', self.sweep_append[:-1]):
            self.put(pins.BM1368_PATH, self.ticket_bm1368 + suffix + self.address_append)
            with self.assertRaisesRegex(ValueError, 'not the reviewed address-commands blob'):
                self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_exact_address_transition_retains_sweep_witness(self):
        self.assertEqual(len(self.sweep_bm1368), 9245)
        self.assertEqual(pins.git_blob(self.sweep_bm1368),
                         'f23565c15c9d174e644fc51a401e81dbe072dfd7')
        self.assertEqual(hashlib.sha256(self.sweep_bm1368).hexdigest(),
                         'e4c05fb8bc541e6e6b2a216cbaecf7ef57cc3d85101d59b81e8ebd3d4e2af7e4')
        self.assertEqual(self.bm1368, self.sweep_bm1368 + self.address_append)
        self.assertEqual(len(self.address_append), 2035)

    def test_current_address_identity_components_are_independent(self):
        for constant, wrong in (('BM1368_CURRENT_BLOB', '0' * 40),
                                ('BM1368_CURRENT_SHA256', '0' * 64),
                                ('BM1368_CURRENT_SIZE', 11279)):
            with self.subTest(constant=constant), patch.object(pins, constant, wrong):
                with self.assertRaisesRegex(ValueError, 'not the reviewed address-commands blob'):
                    pins.historical_bm1368_bytes(self.bm1368)

    def test_sweep_only_source_rejected_as_current(self):
        self.put(pins.BM1368_PATH, self.sweep_bm1368)
        with self.assertRaisesRegex(ValueError, 'not the reviewed address-commands blob'):
            self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_sweep_prefix_checked_without_address_full_hash(self):
        for offset in (0, 920, 3802, 3803, 7518, 7519, 8349, 8350, 9244):
            raw = bytearray(self.bm1368)
            raw[offset] ^= 1
            mutant = bytes(raw)
            with self.subTest(offset=offset), self.accept_address_bm1368_identity(mutant):
                with self.assertRaisesRegex(ValueError, 'preserved sweep source prefix changed'):
                    pins.sweep_bm1368_bytes(mutant)

    def test_address_gate_shape_checked_without_full_hash(self):
        added = self.address_append
        suffixes = [b'',
            added.replace(b'VN135_BM1368_ADDRESS_COMMANDS_135', b'OTHER_GATE'),
            added.replace(b'"integration/bm1368_address_commands_135.h"', b'"wrong.h"'),
            added.replace(b'#include "integration/bm1368_control.h"\n', b''),
            added.replace(b'"integration/bm1368_control.h"', b'"wrong-helper.h"'),
            b'int outside;\n' + added, added + added, added[:-8]]
        for replacement in (b'\n#endif\nint outside;\n\n',
                            b'\n#if OTHER\n#endif\n#endif\n',
                            b'\n#else\n#endif\n', b'\n#elif OTHER\n#endif\n',
                            b'\n#include "extra.h"\n#endif\n'):
            suffixes.append(added.replace(b'\n#endif\n', replacement))
        for index, suffix in enumerate(suffixes):
            mutant = self.sweep_bm1368 + suffix
            with self.subTest(mutation=index), self.accept_address_bm1368_identity(mutant):
                with self.assertRaisesRegex(ValueError, 'address-commands append is not separately gated'):
                    pins.sweep_bm1368_bytes(mutant)

    def test_address_semantics_truncation_and_extra_bytes_fail_current_pin(self):
        for suffix in (self.address_append.replace(b'669, 1,', b'670, 1,'),
                       self.address_append.replace(b'699, 1,', b'700, 1,'),
                       self.address_append.replace(b'frame + 2, 5', b'frame + 2, 4'),
                       self.address_append + b'\n', self.address_append[:-1]):
            self.put(pins.BM1368_PATH, self.sweep_bm1368 + suffix)
            with self.assertRaisesRegex(ValueError, 'not the reviewed address-commands blob'):
                self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

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
                               (pins.BM1368_PATH, pins.BM1368_OLD_BLOB),
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
        for path, old_sha, _, _ in self.pairs():
            target = self.root / path
            target.unlink()
            os.mkfifo(target)
            with self.assertRaises(ValueError):
                self.check(path, old_sha)

    def test_parent_symlink_fails(self):
        parent = self.root / 'libbitmain'
        parent.rename(self.root / 'actual-libbitmain')
        parent.symlink_to(self.root / 'actual-libbitmain', target_is_directory=True)
        with self.assertRaises(ValueError):
            self.check(pins.DISPATCH_PATH, pins.DISPATCH_OLD_BLOB)
        with self.assertRaises(ValueError):
            self.check(pins.BM1368_PATH, pins.BM1368_OLD_BLOB)

    def test_unsafe_or_noncanonical_paths_fail(self):
        for path in ('', '/tmp/file', '../file', 'integration/../file',
                     './' + pins.THERMAL_PATH, 'integration//thermal-routes-135.mk',
                     'integration/./thermal-routes-135.mk', None):
            with self.subTest(path=path):
                with self.assertRaises(ValueError):
                    self.check(path, pins.THERMAL_OLD_BLOB)


if __name__ == '__main__':
    unittest.main(verbosity=2)

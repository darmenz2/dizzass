#!/usr/bin/env python3
"""Metadata-only tests for L10 mutation boundaries; never compile or run C.

The expected names, mutant digests, exact anchor counts and source pins below
were derived from the immutable accepted L10 source. Later suffix bytes are
intentionally opaque to this scoped tool; current-checkout approval is separate.
"""
import ast
from contextlib import ExitStack
import hashlib
from pathlib import Path
import unittest
from unittest import mock

import negative_controls as controls

ROOT = Path(__file__).resolve().parents[5]
SOURCE = ROOT / 'libbitmain/src/chip/chip1368.c'
L10_SHA256 = 'e3c8cecb8869c59847db357d26541e95123fa1cb4cf2ef04642a62c2e1e0738d'
L10_BLOB = 'e024519eda8df9c1c85697548e8e0629f7c0f5cf'
EXPECTED_MUTANTS = [('normal-return-is-zero', 'df7246ea2d66d3c0b09dc4c9df1d5225596954bb0df9d601b21c3214c23e5e0f'),
 ('fast-is-full-word', 'b3e4706f78cf9587bb622398e9bbac3923589a5d404f438db667fe81ce71a21d'),
 ('unused-fourth-scalar', '4d122e3f519c8ab631a353f2093a229f80ddfbe445fd746a7528c37d7bb34627'),
 ('positive-status-is-failure', 'db86436b4b9c23753426a13959432dce28106263e39ac75f651421e35cf50b9b'),
 ('r1-clear-both-bits', 'b857940763669bdd818ab13f26d24470960941de65b796527aec595e6779e55c'),
 ('r2-soft-reset-mask', 'c70a931105977facec7bc7c9c8e4fe87f2bf5296d7c4adcaee69be023a052750'),
 ('r3-clear-required-bits', '2bd48a45abbf5191af8732ac2f068abeaaea442f44e472f69b1d3751d302671b'),
 ('r3-high-nibble', '0809d11a16114f9183c8bfc4675cbe72e2b56ce63298c46d6c47c4af722457e8'),
 ('w2-gates-w3-on-zero', 'd32b6750d7f4be72b43fdc86861a697c3b3c7318c30adf684f3842cc5f00a4ca'),
 ('r4-set-both-bits', '0cc67109348865316b7b4c8abd9f3794a649e251df94cd37d998086956061fee'),
 ('sweep-command-value', '672fae83cfe2740a0423010abc83ab46220ec66738305a342735b52bb553d447'),
 ('clock-mask-three-bits', '7e7746ec7240173e346b9473d702af40fea19dd7d39d0ab6720be31e301f54f7'),
 ('clock-shift-three', 'b8a2e50dd96b3ceee807ff429d780cfe071a048b092da34491e79adfb69e20e0'),
 ('pulse-mask-two-bits', '668f7f33a480faaef6e0b6cbb40b4eeffd8d676f43187e7adc4370443644badc'),
 ('final-core-command', '911360b5b0007f3bf00cf398735f9385287a73820129553a34341ee013b4d7d1'),
 ('final-ten-ms-wait', '260a5722709088b20ac23bfaf1daab5c3a9fd3237b5f9bc07c901b9b7de49d6f'),
 ('misc-log-line', 'e0a5a9abe5438fff62a4fbae42f2a055b70f12eca60055f2d925b0024f50c876'),
 ('clock-log-line-not-pulse', '8461d7f97b5ca55bc97c0657157a3d0b70a492918df2e3e2deb69016acbf8589'),
 ('wrapped-one-based-log-index', '52094b879e7876ac7ed30d6584028613cfd9bb7e6c48f54365368b52ff74e60f'),
 ('r2-output-zero', '8494c3ef2acf757b7e4ccbf6e6cfe2571cee681420371b878519f599b2b78447'),
 ('r3-output-zero', 'd360e99396eb20d9031f2f6ed255d5d0985316d05ed8a0f130451c08662daefd'),
 ('write-mode-is-zero', '7fb9105d5fb937a9965e2d75322c936401d5f0fbc0ffb5d45158ce91973d4264'),
 ('fresh-device-cache-index', '11cd4fd26c23616e2ee69b144b2d652c227d27c6dfb23edc5f1986b379617b77'),
 ('fresh-chip-cache-index', '821454481bc91ea0ac6503333a26bb5b5ef862e580d56e9ad3510af1a1293b92'),
 ('ignored-first-write-result', '589e703a214c7737cc25f0628740862d3df5abf69bce95d28e862a268f20d579'),
 ('ignored-delay-result', 'cb768dc2908da24db61e0da9b13cd6aa790689692a908189aa1ee6c70a95b22a'),
 ('second-w6-diagnostic', '10fa6a5eb1447197f6c01e8f0b5ca8bb5314ff035a91ef2fdc133d73e3c71856')]

EXPECTED_ANCHORS = [('    return 0;\n}', 1, 1),
 ('fast != 0 ? 1u : 5u', 1, 1),
 ('(void)unused;', 1, 1),
 ('!= 0)', 7, 1),
 ('value & ~UINT32_C(0x300)', 1, 1),
 ('value |= UINT32_C(0x1f0)', 1, 1),
 ('misc & UINT32_C(0x00f0ffff)', 1, 1),
 ('| UINT32_C(0xf0000000)', 1, 1),
 ('0xa8, value) == 0)', 1, 1),
 ('value | UINT32_C(0x300)', 1, 1),
 ('UINT32_C(0x80008b00)', 1, 1),
 ('(clock & 7u)', 1, 1),
 ('(clock & 7u) << 3', 1, 1),
 ('(pulse & 3u)', 1, 1),
 ('UINT32_C(0x800082aa)', 1, 1),
 ('ops->wait_context, 10)', 1, 1),
 ('device, 844, misc_error', 2, 1),
 ('device, 538,', 1, 1),
 ('device->index + UINT32_C(1)', 1, 1),
 ('    value = 0;\n    misc = 0;', 1, 1),
 ('    misc = 0;', 1, 1),
 ('device, 0, chip,', 7, 7),
 ('    uint32_t value = 0, misc;', 1, 1),
 ('reset_signed_index_135(device->index)', 4, 4),
 ('    uint32_t value = 0, misc;', 1, 1),
 ('chip->cache_index,', 4, 4),
 ('    else\n'
  '        (void)ops->write_register(ops->write_context, device, 0, chip,\n'
  '            0x18, value & ~UINT32_C(0x300));',
  1,
  1),
 ('    (void)ops->wait_ms(ops->wait_context, delay);', 4, 1),
 ('        reset_diagnostic_135(ops, device, 538,\n'
  '            "chain#%d - failed to set CLOCK_DELAY_CTRL", 1);',
  1,
  1)]

FUNCTION_PINS = {'checked': 'bfdc90850ba88ad0e28f6d651efe24f8ba4ff212ee76ec0fddfac4ffe2130a81',
 'controls': '319fe6225bf6fa7a9d02eb2d32094033017de8616f50924b4e342ce81b9c8804',
 'replace_exact': '02b7231905c2ff28e04310a9bd31c4616030ac558af86967309c2299b89133a2'}

SUBTREE_PINS = {'fixture_failure': 'd8a4a53242a21abed2c615fe36edc6b6f127204d90a0986fb5a1b01bf05cfd1d',
 'flags': '031a4d5376bb20a35fb80b85dbe01a79dc21b1a8eb7cc49fbb0db165c4dc4afd'}


class PartitionTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.raw = SOURCE.read_bytes()
        cls.l10 = cls.raw[:7519]
        cls.prefix = cls.l10[:3803]
        cls.reset = cls.l10[3803:]
        cls.suffix = cls.raw[7519:]
        cls.parts = controls.partition_source(cls.raw)

    def setUp(self):
        # A regression in this metadata suite must never launch any process.
        self.no_process = mock.patch.object(
            controls.subprocess, 'run', side_effect=AssertionError('process execution is forbidden'))
        self.no_process.start()
        self.addCleanup(self.no_process.stop)

    def shaped_source(self, reset):
        # Keep the tested span at exactly its old length, so malformed shape
        # tests cannot pass merely because a hash or size rejected the fixture.
        self.assertLessEqual(len(reset), len(self.reset))
        reset = reset.ljust(len(self.reset), b' ')
        return self.prefix + reset + self.suffix

    def accept_hashes(self):
        stack = ExitStack()
        sha = mock.Mock()
        sha.hexdigest.side_effect = [controls.CONSTRUCTOR_SHA256, controls.RESET_SPAN_SHA256]
        stack.enter_context(mock.patch.object(controls.hashlib, 'sha256', return_value=sha))
        stack.enter_context(mock.patch.object(
            controls, 'git_blob', side_effect=[controls.CONSTRUCTOR_BLOB, controls.RESET_SPAN_BLOB]))
        return stack

    def test_independent_historical_identities(self):
        self.assertEqual(controls.CONSTRUCTOR_SIZE, 3803)
        self.assertEqual(controls.RESET_END, 7519)
        self.assertEqual(len(self.prefix), 3803)
        self.assertEqual(len(self.reset), 3716)
        self.assertEqual(hashlib.sha256(self.l10).hexdigest(), L10_SHA256)
        self.assertEqual(controls.git_blob(self.l10), L10_BLOB)
        self.assertEqual(hashlib.sha256(self.prefix).hexdigest(), controls.CONSTRUCTOR_SHA256)
        self.assertEqual(controls.git_blob(self.prefix), controls.CONSTRUCTOR_BLOB)
        self.assertEqual(hashlib.sha256(self.reset).hexdigest(), controls.RESET_SPAN_SHA256)
        self.assertEqual(controls.git_blob(self.reset), controls.RESET_SPAN_BLOB)

    def test_exact_roundtrip_and_boundary(self):
        self.assertEqual(self.parts.prefix, self.prefix)
        self.assertEqual(controls.RESET_GATE + self.parts.body.encode('ascii'), self.reset)
        self.assertEqual(self.parts.suffix, self.suffix)
        self.assertEqual(controls.assemble_mutant(self.parts, self.parts.body), self.raw)
        original = controls.partition_source(self.l10)
        self.assertEqual(original.suffix, b'')
        self.assertEqual(controls.assemble_mutant(original, original.body), self.l10)

    def test_truncated_historical_spans(self):
        for size in (0, 919, 920, 3802, 3803, 7518):
            with self.subTest(size=size), self.assertRaisesRegex(ValueError, 'shorter'):
                controls.partition_source(self.raw[:size])

    def test_boundary_shift_is_rejected_without_hashes(self):
        variants = [self.raw[:3803] + b' ' + self.raw[3803:],
                    self.raw[:3803] + self.raw[3804:],
                    self.l10[:-2] + self.suffix]
        for raw in variants:
            with self.subTest(raw=raw[3803:3850]), self.accept_hashes():
                with self.assertRaisesRegex(ValueError, 'boundaries'):
                    controls.partition_source(raw)

    def test_changed_constructor_prefix(self):
        raw = b'!' + self.raw[1:]
        with self.assertRaisesRegex(ValueError, 'constructor source prefix changed'):
            controls.partition_source(raw)

    def test_constructor_sha256_is_independent_of_blob(self):
        with mock.patch.object(controls, 'git_blob', return_value=controls.CONSTRUCTOR_BLOB):
            with self.assertRaisesRegex(ValueError, 'constructor source prefix changed'):
                controls.partition_source(b'!' + self.raw[1:])

    def test_constructor_blob_is_independent_of_sha256(self):
        sha = mock.Mock()
        sha.hexdigest.return_value = controls.CONSTRUCTOR_SHA256
        with mock.patch.object(controls.hashlib, 'sha256', return_value=sha):
            with self.assertRaisesRegex(ValueError, 'constructor source prefix changed'):
                controls.partition_source(b'!' + self.raw[1:])

    def test_changed_reset_span(self):
        reset = self.reset.replace(b'(void)unused;', b'(void)clockx;', 1)
        self.assertEqual(len(reset), len(self.reset))
        with self.assertRaisesRegex(ValueError, 'reset source span changed'):
            controls.partition_source(self.prefix + reset + self.suffix)

    def test_reset_sha256_is_independent_of_blob(self):
        reset = self.reset.replace(b'(void)unused;', b'(void)clockx;', 1)
        with mock.patch.object(controls, 'git_blob',
                               side_effect=[controls.CONSTRUCTOR_BLOB, controls.RESET_SPAN_BLOB]):
            with self.assertRaisesRegex(ValueError, 'reset source span changed'):
                controls.partition_source(self.prefix + reset + self.suffix)

    def test_reset_blob_is_independent_of_sha256(self):
        reset = self.reset.replace(b'(void)unused;', b'(void)clockx;', 1)
        sha = mock.Mock()
        sha.hexdigest.side_effect = [controls.CONSTRUCTOR_SHA256, controls.RESET_SPAN_SHA256]
        with mock.patch.object(controls.hashlib, 'sha256', return_value=sha):
            with self.assertRaisesRegex(ValueError, 'reset source span changed'):
                controls.partition_source(self.prefix + reset + self.suffix)

    def test_reset_gate_shape_without_hashes(self):
        gate = controls.RESET_GATE
        header = controls.RESET_HEADER
        variants = {
            'missing gate': self.reset.replace(gate, b' ' * len(gate), 1),
            'altered gate': self.reset.replace(b'RESET_135', b'RESEU_135', 1),
            'wrong header': self.reset.replace(b'bm1368_reset_135.h', b'bm1368_wrong_135.h', 1),
            'missing header': self.reset.replace(header, b' ' * len(header), 1),
            'missing terminal endif': self.reset[:-7] + b' ' * 7,
            'extra trailing newline': self.reset[:-9] + b'\n#endif\n\n',
        }
        # Overwrite ordinary body bytes without moving either fixed boundary.
        at = len(gate + header) + 1
        for name, insertion in [('duplicate gate', gate), ('nested if', b'\n#if 1\n'),
                                ('extra endif', b'\n#endif\n'), ('else', b'\n#else\n'),
                                ('elif', b'\n#elif 1\n'), ('extra include', header)]:
            variants[name] = self.reset[:at] + insertion + self.reset[at + len(insertion):]
        for name, reset in variants.items():
            with self.subTest(name=name), self.accept_hashes():
                with self.assertRaisesRegex(ValueError, 'boundaries'):
                    controls.partition_source(self.shaped_source(reset))

    def test_opaque_later_suffix_can_repeat_every_anchor(self):
        anchors = b'\n'.join(old.encode('ascii') for old, _, _ in EXPECTED_ANCHORS)
        # Include duplicate gate/header text and non-ASCII bytes. The parser
        # must neither decode nor count, replace, strip or normalize this span.
        suffixes = [b'', self.suffix, b'\x00\xff\r\n' + anchors * 3,
                    self.reset * 2 + anchors + b'\r\n\x80',
                    b'\n#ifdef VN135_BM1368_TICKET_MASK_135\n' + anchors + b'\n#endif\n']
        for suffix in suffixes:
            with self.subTest(suffix_length=len(suffix)):
                parts = controls.partition_source(self.l10 + suffix)
                self.assertEqual(parts.prefix, self.prefix)
                self.assertEqual(parts.body, self.parts.body)
                self.assertEqual(parts.suffix, suffix)
                self.assertEqual(controls.assemble_mutant(parts, parts.body), self.l10 + suffix)
                for (name, changed), (old_name, expected_sha) in zip(
                        controls.controls(parts.body), EXPECTED_MUTANTS):
                    self.assertEqual(name, old_name)
                    body = changed.encode('ascii')
                    mutant = controls.assemble_mutant(parts, changed)
                    end = 3803 + len(controls.RESET_GATE) + len(body)
                    self.assertEqual(mutant[:3803], self.prefix, name)
                    self.assertEqual(mutant[end:], suffix, name)
                    self.assertEqual(mutant[3803:end], controls.RESET_GATE + body, name)
                    self.assertEqual(hashlib.sha256(body).hexdigest(), expected_sha, name)

    def test_all_27_historical_mutants_and_exact_counts(self):
        calls = []
        replace_exact = controls.replace_exact
        def record(text, old, new, occurrences=1, replacements=1):
            self.assertEqual(text.count(old), occurrences, old)
            calls.append((old, occurrences, replacements))
            return replace_exact(text, old, new, occurrences, replacements)
        with mock.patch.object(controls, 'replace_exact', side_effect=record):
            variants = list(controls.controls(self.parts.body))
        self.assertEqual(len(variants), 27)
        self.assertEqual(len({name for name, _ in variants}), 27)
        self.assertEqual(calls, EXPECTED_ANCHORS)
        self.assertEqual([(name, hashlib.sha256(body.encode('ascii')).hexdigest())
                          for name, body in variants], EXPECTED_MUTANTS)
        for name, changed in variants:
            with self.subTest(name=name):
                self.assertNotEqual(changed, self.parts.body)
                mutant = controls.assemble_mutant(self.parts, changed)
                end = 3803 + len(controls.RESET_GATE) + len(changed.encode('ascii'))
                self.assertEqual(mutant[:3803], self.prefix)
                self.assertEqual(mutant[end:], self.suffix)

    def test_exact_anchor_count_failure_is_retained(self):
        for old, occurrences, replacements in EXPECTED_ANCHORS:
            for text in (self.parts.body.replace(old, '', 1), self.parts.body + old):
                with self.subTest(anchor=old, altered_count=text.count(old)):
                    with self.assertRaisesRegex(ValueError, 'semantic control anchor changed'):
                        controls.replace_exact(text, old, 'changed', occurrences, replacements)

    def test_historical_transformations_and_failure_policy_are_unchanged(self):
        source = Path(controls.__file__).read_text()
        tree = ast.parse(source)
        functions = {node.name: node for node in tree.body if isinstance(node, ast.FunctionDef)}
        for name, expected in FUNCTION_PINS.items():
            with self.subTest(function=name):
                actual = ast.get_source_segment(source, functions[name]).encode()
                self.assertEqual(hashlib.sha256(actual).hexdigest(), expected)
        main = functions['main']
        flags = next(node for node in ast.walk(main) if isinstance(node, ast.Assign)
                     and any(isinstance(target, ast.Name) and target.id == 'flags'
                             for target in node.targets))
        failure = next(node for node in ast.walk(main) if isinstance(node, ast.If)
                       and 'ORIGINAL_RESET_FAIL ' in ast.unparse(node.test))
        for name, node in [('flags', flags), ('fixture_failure', failure)]:
            with self.subTest(subtree=name):
                actual = ast.dump(node, include_attributes=False).encode()
                self.assertEqual(hashlib.sha256(actual).hexdigest(), SUBTREE_PINS[name])
        flags_text = ast.unparse(flags)
        self.assertIn('-DVN135_BM1368_RESET_135', flags_text)
        self.assertNotIn('VN135_BM1368_TICKET_MASK_135', flags_text)


if __name__ == '__main__':
    unittest.main(verbosity=2)

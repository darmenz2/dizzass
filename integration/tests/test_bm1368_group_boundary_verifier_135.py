#!/usr/bin/env python3
"""L15 verifier caller controls; reference bytes are never executed."""
import ast
from contextlib import contextmanager
import copy
import fnmatch
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_dependency_pins_135 as pins

ROOT = Path(__file__).resolve().parents[2]
RESEARCH = Path('research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-group-boundary')
WORKFLOW = '.github/workflows/bm1368-group-boundary-135.yml'
spec = importlib.util.spec_from_file_location('group_boundary_verifier', ROOT / RESEARCH / 'verify.py')
verifier = importlib.util.module_from_spec(spec)
spec.loader.exec_module(verifier)


class GroupBoundaryVerifier(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.witness = json.loads((ROOT / RESEARCH / 'static-witness.json').read_bytes())
        self.sources = {}
        for path in self.witness['source_sha256']:
            self.sources[path] = (ROOT / path).read_bytes()
            self.put(path, self.sources[path])
        self.current = self.sources[pins.BM1368_PATH]
        self.old = pins.address_bm1368_bytes(self.current)

    def put(self, path, data):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        return target

    def check(self):
        return verifier.verify(self.root, False)

    @contextmanager
    def changed_manifest(self, witness):
        # Bypass only the complete manifest identity to exercise source-boundary
        # wiring independently; the production verifier never accepts this hash.
        raw = json.dumps(witness, sort_keys=True).encode()
        here = self.root / 'synthetic-evidence'
        self.put('synthetic-evidence/static-witness.json', raw)
        self.put('synthetic-evidence/original-code.asm',
                 (ROOT / RESEARCH / 'original-code.asm').read_bytes())
        with patch.object(verifier, 'HERE', here), patch.object(
                verifier, 'WITNESS_SHA256', hashlib.sha256(raw).hexdigest()):
            yield

    def test_exact_current_source_reaches_actual_verifier(self):
        result = self.check()
        self.assertEqual(result['regions'], 15)
        self.assertEqual(result['source_pins'], 22)
        self.assertFalse(result['original_read_as_data'])
        self.assertEqual(len(self.current), 14347)
        self.assertEqual(len(self.old), 11280)
        self.assertEqual(verifier.source_bytes(self.root, pins.BM1368_PATH,
                         self.witness['source_sha256'][pins.BM1368_PATH]), self.old)

    def test_saved_witness_and_disassembly_remain_exact(self):
        self.assertEqual(hashlib.sha256((ROOT / RESEARCH / 'static-witness.json').read_bytes()).hexdigest(),
                         '11051fe9f49e34e52cf4f2105480d6ac9be7dd90bae20a5dd8b43d9b78512c69')
        self.assertEqual(hashlib.sha256((ROOT / RESEARCH / 'original-code.asm').read_bytes()).hexdigest(),
                         '470a6a356a7830ad3c780209bb350aef78b227c64febba0c01e5adcf96f88fd4')

    def test_old_l13_is_not_an_accepted_current_source(self):
        self.put(pins.BM1368_PATH, self.old)
        with self.assertRaisesRegex(ValueError, 'not the reviewed drive-strength blob'):
            self.check()

    def test_changed_current_prefix_suffix_and_size_are_rejected(self):
        mutations = [self.current + b'\n', self.current[:-1]]
        for offset in (0, pins.BM1368_ADDRESS_SIZE - 1,
                       pins.BM1368_ADDRESS_SIZE, len(self.current) - 1):
            mutant = bytearray(self.current)
            mutant[offset] ^= 1
            mutations.append(bytes(mutant))
        for index, mutant in enumerate(mutations):
            with self.subTest(mutation=index):
                self.put(pins.BM1368_PATH, mutant)
                with self.assertRaisesRegex(ValueError, 'not the reviewed drive-strength blob'):
                    self.check()

    def test_original_l13_sha_pin_cannot_be_changed(self):
        for wrong in ('0' * 64, pins.BM1368_CURRENT_SHA256):
            witness = copy.deepcopy(self.witness)
            witness['source_sha256'][pins.BM1368_PATH] = wrong
            with self.subTest(pin=wrong), self.changed_manifest(witness):
                with self.assertRaisesRegex(ValueError, 'historical L13 source pin changed'):
                    self.check()

    def test_copied_path_gets_no_transition(self):
        witness = copy.deepcopy(self.witness)
        expected = witness['source_sha256'].pop(pins.BM1368_PATH)
        copied = pins.BM1368_PATH + '.copy'
        witness['source_sha256'][copied] = expected
        self.put(copied, self.current)
        with self.changed_manifest(witness):
            with self.assertRaisesRegex(ValueError, 'changed source: ' + copied):
                self.check()

    def test_recovered_bytes_keep_the_independent_manifest_sha_check(self):
        for wrong in (self.current, self.old + b'\n'):
            with self.subTest(size=len(wrong)), patch.object(
                    verifier, 'address_bm1368_bytes', return_value=wrong):
                with self.assertRaisesRegex(ValueError, 'changed source: ' + pins.BM1368_PATH):
                    self.check()

    def test_every_other_source_pin_still_rejects_byte_drift(self):
        for path, original in self.sources.items():
            if path == pins.BM1368_PATH:
                continue
            with self.subTest(path=path):
                self.put(path, original + b'\n')
                try:
                    with self.assertRaisesRegex(ValueError, 'changed source:'):
                        self.check()
                finally:
                    self.put(path, original)

    def test_missing_source_is_rejected(self):
        (self.root / pins.BM1368_PATH).unlink()
        with self.assertRaises(FileNotFoundError):
            self.check()

    def test_each_executable_bit_is_rejected(self):
        target = self.root / pins.BM1368_PATH
        for mode in (0o744, 0o654, 0o645):
            with self.subTest(mode=oct(mode)):
                target.chmod(mode)
                with self.assertRaisesRegex(ValueError, 'non-executable regular file'):
                    self.check()

    def test_leaf_symlink_is_rejected(self):
        real = self.put(pins.BM1368_PATH + '.real', self.current)
        target = self.root / pins.BM1368_PATH
        target.unlink()
        target.symlink_to(real)
        with self.assertRaisesRegex(ValueError, 'non-executable regular file'):
            self.check()

    def test_parent_symlink_is_rejected(self):
        parent = self.root / 'libbitmain/src/chip'
        real = self.root / 'actual-chip'
        parent.rename(real)
        parent.symlink_to(real, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, 'source parent is not a directory'):
            self.check()

    def test_noncanonical_paths_are_rejected_before_reading(self):
        for path in ('', '/' + pins.BM1368_PATH, './' + pins.BM1368_PATH,
                     '../' + pins.BM1368_PATH, 'libbitmain//src/chip/chip1368.c',
                     'libbitmain/./src/chip/chip1368.c',
                     'libbitmain/src/../src/chip/chip1368.c',
                     pins.BM1368_PATH + '/', None, Path(pins.BM1368_PATH),
                     pins.BM1368_PATH.encode(), 1, []):
            with self.subTest(path=path):
                with self.assertRaisesRegex(ValueError, 'canonical and repository-relative'):
                    verifier.source_bytes(self.root, path, pins.BM1368_ADDRESS_SHA256)

    def test_workflow_covers_all_consumed_sources_and_controls(self):
        workflow = (ROOT / WORKFLOW).read_text()
        path_block = workflow.split('    paths:\n', 1)[1].split('  workflow_dispatch:', 1)[0]
        patterns = [ast.literal_eval(line.strip()[2:]) for line in path_block.splitlines()
                    if line.strip().startswith('- ')]
        runner_path = 'integration/tests/check_bm1368_group_boundary_135.py'
        parsed = ast.parse((ROOT / runner_path).read_text())
        build_inputs = []
        for node in parsed.body:
            if isinstance(node, ast.Assign) and any(isinstance(target, ast.Name)
                    and target.id in ('SOURCES', 'HEADERS') for target in node.targets):
                build_inputs.extend(ast.literal_eval(node.value))
        required = set(self.witness['source_sha256']) | set(build_inputs) | {
            'AGENTS.md', WORKFLOW, self.witness['reference']['path'],
            str(RESEARCH / 'verify.py'), str(RESEARCH / 'static-witness.json'),
            str(RESEARCH / 'original-code.asm'), str(RESEARCH / 'README_RU.md'),
            'integration/tests/current_dependency_pins_135.py',
            'integration/tests/test_current_dependency_pins_135.py',
            'integration/tests/test_bm1368_group_boundary_verifier_135.py',
            pins.NATIVE_DOC_PATH, pins.NATIVE_CHECKER_PATH, pins.THERMAL_PATH,
            pins.DISPATCH_PATH,
        }
        for path in sorted(required):
            with self.subTest(path=path):
                self.assertTrue(any(fnmatch.fnmatchcase(path, pattern) for pattern in patterns), path)
        self.assertIn("include/xminer/recovery/*.h", patterns)
        self.assertIn('branches: [work/reconstruction]', workflow)
        self.assertIn('permissions:\n  contents: read\n', workflow)
        for control in ('test_current_dependency_pins_135.py',
                        'test_bm1368_group_boundary_verifier_135.py'):
            for prefix in ('python3 ', 'python3 -O '):
                self.assertIn(prefix + 'integration/tests/' + control, workflow)


if __name__ == '__main__':
    unittest.main(verbosity=2)

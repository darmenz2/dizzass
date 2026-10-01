"""Data consistency controls; no firmware code or shell script is executed."""
import importlib.util
import pathlib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('exit_evidence', ROOT / 'verify_evidence.py')
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class EvidenceTests(unittest.TestCase):
    def setUp(self):
        self.plan, self.manifest, self.claims, self.raw = MODULE.load(ROOT)

    def verify(self):
        return MODULE.verify_static(ROOT, self.plan, self.manifest, self.claims, self.raw)

    def rejected(self):
        with self.assertRaises(ValueError):
            self.verify()

    def test_frozen_data(self):
        result = self.verify()
        self.assertEqual(result['bytes'], 3152)
        self.assertFalse(result['firmware_executed'])

    def test_wrong_source(self):
        self.claims['source_sha256'] = '0' * 64; self.rejected()

    def test_execution_flag(self):
        self.manifest['firmware_executed'] = True; self.rejected()

    def test_plan_hash(self):
        self.manifest['plan_sha256'] = '0' * 64; self.rejected()

    def test_plan_object_disagreement(self):
        self.plan['ranges'][0]['end_exclusive'] = '0x158dc'; self.rejected()

    def test_artifact_set(self):
        self.manifest['artifact_sha256']['../outside'] = '0' * 64; self.rejected()

    def test_artifact_hash(self):
        self.manifest['artifact_sha256']['outer-main.asm'] = '0' * 64; self.rejected()

    def test_branch_target(self):
        self.claims['direct_edges'][0]['target'] = '0x158e0'; self.rejected()

    def test_branch_link(self):
        self.claims['direct_edges'][0]['kind'] = 'B'; self.rejected()

    def test_branch_condition(self):
        self.claims['direct_edges'][0]['condition'] = 0; self.rejected()

    def test_word(self):
        self.claims['words'][0]['word'] = '0xe3a06001'; self.rejected()

    def test_pc_relative_target(self):
        self.claims['pc_relative'][1]['result'] = '0x22428'; self.rejected()

    def test_pointer_cell(self):
        self.claims['pointer_cells'][0]['target'] = '0x2542c'; self.rejected()

    def test_got_offset(self):
        self.claims['startup_main_got_offset']['slot'] = '0x4afc6c'; self.rejected()

    def test_shell_identity(self):
        self.claims['shell_source']['sha256'] = '0' * 64; self.rejected()

    def test_shell_scope(self):
        self.claims['shell_source']['path'] = '/etc/passwd'; self.rejected()


if __name__ == '__main__':
    unittest.main()

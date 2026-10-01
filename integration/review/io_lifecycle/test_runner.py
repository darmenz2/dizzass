#!/usr/bin/env python3
import importlib.util
from pathlib import Path
import unittest
spec=importlib.util.spec_from_file_location('r05_runner',Path(__file__).with_name('run.py'))
r=importlib.util.module_from_spec(spec);spec.loader.exec_module(r)
class Runner(unittest.TestCase):
    def test_complete_marker(self):
        self.assertEqual(r.require_pass('R05_PASS cases=29 checks=123 native_calls=46 physical_asic=0\n'),123)
    def test_partial_or_wrong_result_rejected(self):
        for s in ['', 'PASS', 'R05_PASS cases=27 checks=123 native_calls=46 ', 'R05_PASS cases=29 checks=123 native_calls=45 ']:
            with self.assertRaises(RuntimeError):r.require_pass(s)
    def test_shared_staging(self):
        self.assertEqual(r.base.ROOT,r.ROOT)
        for s in ['/outside','../outside','build/../../outside','.']:
            with self.assertRaises(ValueError):r.base.safe_name(s)
if __name__=='__main__':unittest.main(verbosity=2)

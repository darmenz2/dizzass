#!/usr/bin/env python3
import importlib.util, unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('r16_runner',Path(__file__).with_name('run.py'))
run=importlib.util.module_from_spec(spec);spec.loader.exec_module(run)
class Tests(unittest.TestCase):
    def test_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),588)
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS[:-1]),559)
    def test_controls(self):
        self.assertEqual(len(run.CONTROLS),7)
        self.assertEqual(len({c[0] for c in run.CONTROLS}),7)
        code=(ROOT/'integration/native/native_io_stop.c').read_text()
        for name,scope,old,new,witness in run.CONTROLS:
            self.assertEqual(code.split(scope,1)[1].count(old),1,name)
            self.assertNotEqual(old,new);self.assertTrue(witness)
    def test_real_core_calls(self):
        code=(ROOT/'integration/review/native_io_stop/suite.mk').read_text()
        for name in ['cgminer_request_queued_stop','hash_queued_work','get_work','fill_queue']:
            self.assertNotIn('--wrap='+name,code)
        self.assertIn('integration/native/native_io_stop.c',code)
    def test_publication_before_cancel(self):
        code=(ROOT/'integration/native/native_io_stop.c').read_text()
        self.assertLess(code.index('*out = r;'),code.index('pthread_setcancelstate(saved'))
if __name__=='__main__':unittest.main(verbosity=2)

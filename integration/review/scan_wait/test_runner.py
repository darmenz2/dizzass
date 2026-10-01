#!/usr/bin/env python3
"""Control anchors, real native callback linkage and preservation of R16."""
import unittest
import run
class Tests(unittest.TestCase):
    def test_groups(self):
        run.configure_groups()
        self.assertEqual(sum(x[3] for x in run.combined.GROUPS),608)
        self.assertEqual(sum(x[3] for x in run.combined.GROUPS[:-1]),588)
        self.assertEqual(run.combined.GROUPS[-1][0],'scan_wait')
    def test_controls(self):
        self.assertEqual(len(run.CONTROLS),8)
        self.assertEqual(len({c[0] for c in run.CONTROLS}),8)
        text=(run.ROOT/'integration/native/scan_wait.c').read_text()
        for name,section,old,new,witness in run.CONTROLS:
            self.assertEqual(text.split(section,1)[1].count(old),1,name)
            self.assertNotEqual(old,new)
            self.assertTrue(witness)
        self.assertEqual(len(run.previous.CONTROLS),7)
    def test_no_fake_scheduler(self):
        text=(run.ROOT/'integration/native/scan_wait.c').read_text()
        for name in ('hash_push(', 'get_work(', 'submit_nonce(', 'pthread_create(', 'malloc(', 'add_cgpu(', 'begin_drained_epoch'):
            self.assertNotIn(name,text)
        self.assertIn('return rc || restored ? -1 : 0;',text)
    def test_real_native_loop(self):
        code=(run.ROOT/run.REL/'test.c').read_text()
        self.assertIn('hash_queued_work(w->thr)',code)
        self.assertIn('dizzass_native_io_stop(',code)
        self.assertIn('take_genesis(',code)
        mk=(run.ROOT/run.REL/'suite.mk').read_text()
        for name in ('hash_queued_work','get_work','dizzass_scanwork','cgminer_request_queued_stop'):
            self.assertNotIn('--wrap='+name,mk)
if __name__=='__main__':unittest.main(verbosity=2)

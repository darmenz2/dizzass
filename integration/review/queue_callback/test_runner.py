#!/usr/bin/env python3
"""Verify callback controls and preservation of the R11 suite configuration."""
import unittest
import run
class Tests(unittest.TestCase):
    def test_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),523)
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS[:-1]),496)
        self.assertEqual(run.combined.GROUPS[-1][0],'queue_callback')
    def test_controls(self):
        self.assertEqual(len(run.CONTROLS),6)
        self.assertEqual(len({x[0] for x in run.CONTROLS}),6)
        self.assertEqual(len(run.previous.CONTROLS),9)
        for name,path,scope,old,new,witness in run.CONTROLS:
            code=(run.ROOT/path).read_text().split(scope,1)[1]
            self.assertEqual(code.count(old),1,name)
            self.assertNotEqual(old,new);self.assertTrue(witness)
    def test_no_core_replacement(self):
        code=(run.ROOT/'integration/native/queue_callback.c').read_text()
        self.assertEqual(code.count('dizzass_queued_work_step('),1)
        for token in ('get_queued(', 'get_work(', 'work_completed(', 'calloc(', 'pthread_create(', 'begin_drained_epoch'):
            self.assertNotIn(token,code)
    def test_real_native_fill(self):
        code=(run.ROOT/run.REL/'test.c').read_text()
        self.assertIn('=fill_queue;',code);self.assertIn('=hash_pop;',code)
        self.assertIn('C12(hash_push(w))',code)
        mk=(run.ROOT/run.REL/'suite.mk').read_text()
        self.assertNotIn('--wrap=get_work',mk)
        self.assertNotIn('--undefined=fill_queue',mk)
        self.assertNotIn('--undefined=hash_pop',mk)
    def test_native_callback_signature(self):
        h=(run.ROOT/'integration/native/queue_callback.h').read_text()
        self.assertIn('bool dizzass_queue_full(struct cgpu_info *);',h)
        self.assertIn('BEFORE this callback',h)
if __name__=='__main__':unittest.main(verbosity=2)

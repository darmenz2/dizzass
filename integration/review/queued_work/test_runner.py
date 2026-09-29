#!/usr/bin/env python3
"""Verify added group/control registration without executing native code."""
import unittest
import run
class RunnerTests(unittest.TestCase):
    def test_all_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),439)
        self.assertEqual([g[0] for g in run.combined.GROUPS],
            ['early_rx','rx_submit','rx_owner','io_lifecycle','combined_rx','device_stop','rx_integrity','queued_work'])
    def test_existing_controls(self):
        run.configure_groups()
        count=sum(len(run.combined.controls(n)) for n in ['early_rx','rx_submit','rx_owner','io_lifecycle'])
        self.assertEqual(count,24)
        self.assertEqual(len(run.previous.previous.CONTROLS),7)
        self.assertEqual(len(run.previous.CONTROLS),6)
    def test_new_controls(self):
        src=(run.ROOT/'integration/native/queued_work_tx.c').read_text()
        self.assertEqual(len(run.CONTROLS),7)
        self.assertEqual(len({x[0] for x in run.CONTROLS}),7)
        for name,old,new,witness in run.CONTROLS:
            self.assertEqual(src.count(old),1,name)
            self.assertNotEqual(old,new)
            self.assertTrue(witness)
if __name__=='__main__':unittest.main(verbosity=2)

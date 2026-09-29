#!/usr/bin/env python3
import unittest
import run
class RunnerTests(unittest.TestCase):
    def test_original_groups_preserved(self):
        run.configure_groups()
        self.assertEqual(run.combined.GROUPS[:-1],run.ORIGINAL_GROUPS)
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),223)
        self.assertEqual(run.combined.controls('device_stop'),[])
    def test_original_controls_preserved(self):
        run.configure_groups()
        for name in ('early_rx','rx_submit','rx_owner','io_lifecycle'):
            self.assertEqual(run.combined.controls(name),run.original_controls(name))
        self.assertEqual(sum(len(run.combined.controls(n)) for n in ('early_rx','rx_submit','rx_owner','io_lifecycle')),24)
    def test_unique_exact_new_controls(self):
        source=(run.ROOT/'integration/native/io_stop_many.c').read_text()
        self.assertEqual(len(run.CONTROLS),7)
        self.assertEqual(len({c[0] for c in run.CONTROLS}),7)
        for _,old,new,witness in run.CONTROLS:
            self.assertEqual(source.count(old),1);self.assertNotEqual(old,new);self.assertTrue(witness)
if __name__=='__main__':unittest.main(verbosity=2)

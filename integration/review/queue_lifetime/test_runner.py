#!/usr/bin/env python3
"""Verify added scope controls and explicit current-source revisions."""
import hashlib,json,unittest
import run
class RunnerTests(unittest.TestCase):
    def test_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),455)
        self.assertEqual(run.combined.GROUPS[-1][0],'queue_lifetime')
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS[:-1]),439)
    def test_controls(self):
        self.assertEqual(len(run.CONTROLS),6)
        for name,file,old,new,witness in run.CONTROLS:
            s=(run.ROOT/'integration/native'/file).read_text()
            self.assertEqual(s.count(old),1,name);self.assertNotEqual(old,new);self.assertTrue(witness)
        self.assertEqual(len(run.previous.CONTROLS),7)
        self.assertEqual(len(run.previous.previous.CONTROLS),6)
    def test_input_revisions(self):
        r=json.loads((run.ROOT/run.REL/'input_revisions.json').read_text())
        self.assertEqual(r['parent'],'48196f27f146087c4d22ce21caf0e0615a897a0e')
        m=json.loads((run.ROOT/'integration/review/combined_rx/manifest.json').read_text())
        bypath={x['path']:x for x in m['inputs']}
        for x in r['revisions']:
            self.assertEqual(bypath[x['path']],x['after'])
            self.assertEqual(hashlib.sha256((run.ROOT/x['path']).read_bytes()).hexdigest(),x['after']['sha256'])
            self.assertNotEqual(x['before']['sha256'],x['after']['sha256'])
    def test_no_second_queue_implementation(self):
        s=(run.ROOT/'integration/native/queued_work_tx.c').read_text()
        self.assertEqual(s.count('get_queued(thr->cgpu)'),1)
        self.assertEqual(s.count('work_completed(thr->cgpu, work)'),1)
        self.assertNotIn('dizzass_io_send_queued',s)
if __name__=='__main__':unittest.main(verbosity=2)

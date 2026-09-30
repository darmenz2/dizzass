#!/usr/bin/env python3
import hashlib,json,unittest
import run
class Tests(unittest.TestCase):
    def test_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),537)
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS[:-1]),523)
    def test_controls(self):
        self.assertEqual(len(run.CONTROLS),8)
        self.assertEqual(len({x[0] for x in run.CONTROLS}),8)
        code=(run.ROOT/'cgminer.c').read_text()
        for name,scope,old,new,witness in run.CONTROLS:
            self.assertEqual(code.split(scope,1)[1].count(old),1,name)
            self.assertNotEqual(old,new);self.assertTrue(witness)
    def test_prior_hashes_preserved(self):
        rev=json.loads((run.ROOT/run.REL/'input_revisions.json').read_text())
        self.assertEqual({r['before']['path'] for r in rev['revisions']},{'cgminer.c','miner.h'})
        for r in rev['revisions']:
            self.assertEqual(r['after']['supersedes'],r['before'])
            self.assertEqual(hashlib.sha256((run.ROOT/r['after']['path']).read_bytes()).hexdigest(),r['after']['sha256'])
    def test_no_replacement_core(self):
        test=(run.ROOT/run.REL/'test.c').read_text()
        self.assertIn('hash_queued_work(w->thr)',test)
        self.assertNotIn('--wrap=get_work',(run.ROOT/run.REL/'suite.mk').read_text())
        self.assertNotIn('--wrap=hash_queued_work',(run.ROOT/run.REL/'suite.mk').read_text())
if __name__=='__main__':unittest.main(verbosity=2)

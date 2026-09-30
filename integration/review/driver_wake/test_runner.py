#!/usr/bin/env python3
import hashlib,json,unittest
import run
class Tests(unittest.TestCase):
    def test_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),551)
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS[:-1]),537)
    def test_controls(self):
        self.assertEqual(len(run.CONTROLS),8)
        self.assertEqual(len({x[0] for x in run.CONTROLS}),8)
        code=(run.ROOT/'cgminer.c').read_text()
        for name,scope,old,new,witness in run.CONTROLS:
            self.assertEqual(code.split(scope,1)[1].count(old),1,name)
            self.assertNotEqual(old,new);self.assertTrue(witness)
    def test_provenance(self):
        rev=json.loads((run.ROOT/run.REL/'input_revisions.json').read_text())
        self.assertEqual({r['before']['path'] for r in rev['revisions']},{'cgminer.c','miner.h'})
        for r in rev['revisions']:
            self.assertEqual(r['after']['supersedes'],r['before'])
            current=next(e for e in json.loads((run.ROOT/'integration/review/combined_rx/manifest.json').read_text())['inputs'] if e['path']==r['after']['path'])
            self.assertEqual(hashlib.sha256((run.ROOT/current['path']).read_bytes()).hexdigest(),current['sha256'])
            entry=current
            while entry != r['after'] and 'supersedes' in entry: entry=entry['supersedes']
            self.assertEqual(entry,r['after'])
    def test_thread_publication(self):
        code=(run.ROOT/'cgminer.c').read_text()
        self.assertEqual(code.count('cgpu->thr = cgcalloc(cgpu->threads + 1, sizeof(*cgpu->thr));'),2)
        self.assertNotIn('cgpu->thr = cgmalloc(',code)
    def test_native_loops(self):
        test=(run.ROOT/run.REL/'test.c').read_text()
        self.assertIn('hash_queued_work(w->t)',test);self.assertIn('miner_thread(w->t)',test)
        suite=(run.ROOT/run.REL/'suite.mk').read_text()
        for name in ['hash_queued_work','miner_thread','get_work','fill_queue']:
            self.assertNotIn('--wrap='+name,suite)
if __name__=='__main__':unittest.main(verbosity=2)

#!/usr/bin/env python3
import hashlib,json,unittest
import run
class Tests(unittest.TestCase):
    def test_groups_preserved(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),559)
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS[:-1]),551)
    def test_single_control(self):
        self.assertEqual(len(run.CONTROLS),1)
        text=(run.ROOT/'cgminer.c').read_text()
        for name,scope,old,new,witness in run.CONTROLS:
            self.assertEqual(text.split(scope,1)[1].count(old),1)
            self.assertNotEqual(old,new)
            self.assertIn(witness,(run.ROOT/run.REL/'test.c').read_text())
    def test_exact_provenance(self):
        revisions=json.loads((run.ROOT/run.REL/'input_revisions.json').read_text())['revisions']
        self.assertEqual(len(revisions),1)
        r=revisions[0];self.assertEqual(r['before']['blob'],'27def5aec3c7b4eb6d0b9c1ed315d51e0fccfc8d')
        self.assertEqual(r['after']['supersedes'],r['before'])
        self.assertEqual(hashlib.sha256((run.ROOT/'cgminer.c').read_bytes()).hexdigest(),r['after']['sha256'])
        self.assertIn(r['after'],json.loads((run.ROOT/'integration/review/combined_rx/manifest.json').read_text())['inputs'])
    def test_real_core_not_wrapped(self):
        suite=(run.ROOT/run.REL/'suite.mk').read_text()
        for name in ('null_device_drv','fill_device_drv','copy_drv','cgminer_request_queued_stop'):
            self.assertNotIn('--wrap='+name,suite)
            self.assertIn(name,(run.ROOT/run.REL/'test.c').read_text())
    def test_no_reference_hardware(self):
        source=(run.ROOT/run.REL/'test.c').read_text()
        self.assertNotIn('open12(',source)
        self.assertIn('sem_getvalue',source)
        self.assertIn('retired_wake_calls == 0 && rc == 0',source)
if __name__=='__main__':unittest.main(verbosity=2)

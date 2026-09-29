#!/usr/bin/env python3
"""Validate R11 controls and explicit, additive source revisions."""
import hashlib,json,unittest
import run
class RunnerTests(unittest.TestCase):
    def test_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS),496)
        self.assertEqual(sum(g[3] for g in run.combined.GROUPS[:-1]),455)
        self.assertEqual(run.combined.GROUPS[-1][0],'queue_capacity')
    def test_controls(self):
        self.assertEqual(len(run.CONTROLS),9)
        self.assertEqual(len({x[0] for x in run.CONTROLS}),9)
        self.assertEqual(len(run.previous.CONTROLS),6)
        self.assertEqual(len(run.previous.previous.CONTROLS),7)
        for label,path,section,old,new,witness in run.CONTROLS:
            text=(run.ROOT/path).read_text();body=text[text.index(section):]
            self.assertEqual(body.count(old),1,label)
            self.assertNotEqual(old,new);self.assertTrue(witness)
    def test_revisions(self):
        doc=json.loads((run.ROOT/run.REL/'input_revisions.json').read_text())
        self.assertEqual(doc['parent'],'2855ad18b6bc93a1727c587fa35886546e11fa84')
        manifest=json.loads((run.ROOT/'integration/review/combined_rx/manifest.json').read_text())
        entries={x['path']:x for x in manifest['inputs']}
        self.assertEqual(len(doc['revisions']),4)
        for e in doc['revisions']:
            self.assertEqual(entries[e['path']],e['after'])
            self.assertEqual(e['after']['supersedes'],e['before'])
            raw=(run.ROOT/e['path']).read_bytes()
            self.assertEqual(hashlib.sha256(raw).hexdigest(),e['after']['sha256'])
    def test_existing_runtime_prefix_unchanged(self):
        revisions=json.loads((run.ROOT/run.REL/'input_revisions.json').read_text())['revisions']
        anchors={'integration/native_jobs.c':'\n/* Advisory snapshot only;',
                 'integration/native/io_lifecycle.c':'\nint dizzass_io_capacity('}
        for e in revisions:
            if e['path'] in anchors:
                s=(run.ROOT/e['path']).read_text();prefix=s[:s.index(anchors[e['path']])]
                self.assertEqual(hashlib.sha256(prefix.encode()).hexdigest(),e['before']['sha256'])
    def test_reuses_one_native_queue_sender(self):
        text=(run.ROOT/'integration/native/queue_step.c').read_text()
        self.assertEqual(text.count('dizzass_queued_work_send('),1)
        self.assertNotIn('get_queued(',text);self.assertNotIn('work_completed(',text)
        self.assertNotIn('calloc(',text);self.assertNotIn('pthread_create(',text)
        self.assertNotIn('begin_drained_epoch',text)
    def test_state_masks_are_not_core_counts(self):
        text=(run.ROOT/'integration/native_jobs.c').read_text().split('int dizzass_jobs_capacity(')[1]
        self.assertIn('state == SLOT_EMPTY',text)
        self.assertNotIn('queued_count',text);self.assertNotIn('release_slot(',text)
if __name__=='__main__':unittest.main(verbosity=2)

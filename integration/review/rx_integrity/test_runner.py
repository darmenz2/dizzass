#!/usr/bin/env python3
import hashlib,json,unittest
import run
import generate_vectors as vectors
class IntegrityRunnerTests(unittest.TestCase):
    def test_prior_groups(self):
        run.configure_groups()
        self.assertEqual(sum(g[3] for g in run.previous.combined.GROUPS[:-1]),223)
        self.assertEqual(sum(g[3] for g in run.previous.combined.GROUPS),390)
        self.assertEqual(run.previous.combined.controls('rx_integrity'),[])
    def test_prior_controls(self):
        run.configure_groups()
        self.assertEqual(sum(len(run.previous.combined.controls(g)) for g in ['early_rx','rx_submit','rx_owner','io_lifecycle']),24)
        self.assertEqual(len(run.previous.CONTROLS),7)
    def test_new_controls(self):
        self.assertEqual(len(run.CONTROLS),6)
        self.assertEqual(len({x[0] for x in run.CONTROLS}),6)
        for _,name,old,new,witness in run.CONTROLS:
            self.assertEqual((run.ROOT/'integration/native'/name).read_text().count(old),1)
            self.assertNotEqual(old,new);self.assertTrue(witness)
    def test_polynomial_vectors(self):
        self.assertEqual((run.ROOT/run.REL/'vectors.h').read_text(),vectors.rendered())
        data=vectors.framed(bytes.fromhex('1dac2b7c0030000080'))[2:]
        self.assertEqual(vectors.remainder(data,72),0)
        for bit in range(72):
            bad=bytearray(data);bad[bit//8]^=1<<(bit%8)
            self.assertNotEqual(vectors.remainder(bad,72),0)
    def test_explicit_input_revisions(self):
        revisions=json.loads((run.ROOT/run.REL/'input_revisions.json').read_text())
        manifest=json.loads((run.ROOT/'integration/review/combined_rx/manifest.json').read_text())
        expected={'integration/native/'+n for n in ['rx_owner.c','rx_owner.h','io_lifecycle.c','io_lifecycle.h']}
        expected|={'integration/review/'+n+'/suite.mk' for n in ['rx_owner','io_lifecycle']}
        self.assertEqual({r['path'] for r in revisions},expected)
        current={e['path']:e for e in manifest['inputs']}
        for r in revisions:
            entry=current[r['path']]
            self.assertEqual(entry['supersedes']['blob'],r['before']['blob'])
            self.assertEqual(hashlib.sha256((run.ROOT/r['path']).read_bytes()).hexdigest(),entry['sha256'])
    def test_preserved_crc_source(self):
        manifest=json.loads((run.ROOT/'integration/review/combined_rx/manifest.json').read_text())
        entries={e['path']:e for e in manifest['inputs']}
        for name in ['integration/rx_crc5.c','integration/rx_crc5.h','reconstruction/support/crc5.c']:
            self.assertEqual(hashlib.sha256((run.ROOT/name).read_bytes()).hexdigest(),entries[name]['sha256'])
if __name__=='__main__':unittest.main(verbosity=2)

"""Tests of C-01 source guards; these are not application/hardware tests."""
import hashlib, importlib.util, pathlib, re, tempfile, unittest
from unittest.mock import patch
SPEC=importlib.util.spec_from_file_location('c01run',pathlib.Path(__file__).with_name('run.py'))
m=importlib.util.module_from_spec(SPEC); SPEC.loader.exec_module(m)
class Guards(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(); self.addCleanup(self.tmp.cleanup)
        self.root=pathlib.Path(self.tmp.name); self.f=self.root/'unit.c'; self.f.write_bytes(b'one')
        self.plan={'base':'base','order':[{'files':[{'path':'unit.c','blob':m.digest(b'one'),'sha256':hashlib.sha256(b'one').hexdigest()}]}]}
        self.p1=patch.object(m,'ROOT',self.root); self.p1.start(); self.addCleanup(self.p1.stop)
        self.p2=patch.object(m,'PLAN',self.plan); self.p2.start(); self.addCleanup(self.p2.stop)
        self.pe=patch.object(m,'expected_inputs',return_value={'unit.c':m.digest(b'one')}); self.pe.start(); self.addCleanup(self.pe.stop)
        self.p3=patch.object(m.subprocess,'check_output',return_value=''); self.git=self.p3.start(); self.addCleanup(self.p3.stop)
    def test_valid(self): m.verify_tree()
    def test_changed(self):
        self.f.write_bytes(b'two')
        with self.assertRaises(ValueError): m.verify_tree()
    def test_missing(self):
        self.f.unlink()
        with self.assertRaises(ValueError): m.verify_tree()
    def test_symlink(self):
        self.f.rename(self.root/'real'); self.f.symlink_to(self.root/'real')
        with self.assertRaises(ValueError): m.verify_tree()
    def test_uncommitted_source(self):
        self.git.return_value='cgminer.c\n'
        with self.assertRaises(ValueError): m.verify_tree()
    def test_base_modification(self):
        self.git.side_effect=['','miner.h\n']
        with self.assertRaises(ValueError): m.verify_tree()
    def test_generated_build_exceptions_only(self):
        self.git.side_effect=['compat/jansson-2.9/test-driver\n','']
        m.verify_tree()
class Coverage(unittest.TestCase):
    def test_matrix_covers_each_proposal_once(self):
        workflow=(m.ROOT/'.github/workflows/consolidated-source.yml').read_text()
        values=[int(n) for group in re.findall(r"stages: '([0-9,]+)'",workflow) for n in group.split(',')]
        expected=[p['pr'] for p in m.PLAN['order']]
        self.assertEqual(sorted(values),sorted(expected))
        self.assertEqual(len(set(values)),len(values))
if __name__=='__main__': unittest.main(verbosity=2)

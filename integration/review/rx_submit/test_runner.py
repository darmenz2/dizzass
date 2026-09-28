#!/usr/bin/env python3
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest
spec=importlib.util.spec_from_file_location('r03',Path(__file__).with_name('run.py'))
r03=importlib.util.module_from_spec(spec); spec.loader.exec_module(r03)
class Checks(unittest.TestCase):
    def test_offline_dependency(self):
        data=b'known input'; e={'commit':'a'*40,'path':'integration/input.h',
            'blob':hashlib.sha1(b'blob 11\0'+data).hexdigest(),'sha256':hashlib.sha256(data).hexdigest()}
        with tempfile.TemporaryDirectory() as d:
            root=Path(d); p=root/e['path']; p.parent.mkdir(); p.write_bytes(data)
            self.assertEqual(r03.dependency(e,root),data)
            p.write_bytes(data+b'x')
            with self.assertRaises(ValueError): r03.dependency(e,root)
    def test_bad_identity(self):
        with self.assertRaises(ValueError): r03.dependency({'commit':'bad','path':'safe'},Path('/not-used'))
        with self.assertRaises(ValueError): r03.dependency({'commit':'a'*40,'path':'../outside'},Path('/not-used'))
    def test_symlink_dependency(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d); (root/'link').symlink_to(root)
            with self.assertRaises(ValueError): r03.dependency({'commit':'a'*40,'path':'link/file'},root)
if __name__=='__main__': unittest.main(verbosity=2)

#!/usr/bin/env python3
"""Runner-only integrity tests; not substitutes for C/PTY scenarios."""
import hashlib
import io
from pathlib import Path
import tarfile
import tempfile
import unittest
import run
class Integrity(unittest.TestCase):
    def test_names(self):
        for name in ['.', '../x', '/tmp/x', 'a/../../x']:
            with self.assertRaises(ValueError): run.safe_name(name)
        self.assertEqual(str(run.safe_name('a/b.c')), 'a/b.c')
    def test_hashes(self):
        b=b'fixed'; e={'path':'a.c','blob':hashlib.sha1(b'blob 5\0'+b).hexdigest(),'sha256':hashlib.sha256(b).hexdigest()}
        run.verify(b,e)
        with self.assertRaises(ValueError): run.verify(b+b'!',e)
    def test_exclusive_output(self):
        old=run.ROOT
        with tempfile.TemporaryDirectory() as d:
            run.ROOT=Path(d)
            try:
                run.output('build/new')
                with self.assertRaises(FileExistsError): run.output('build/new')
                for p in ['/tmp/x','../x','build/../x','build']:
                    with self.assertRaises(ValueError): run.output(p)
                (run.ROOT/'build/link').symlink_to(run.ROOT/'build/new',target_is_directory=True)
                with self.assertRaises(ValueError): run.output('build/link/child')
            finally:run.ROOT=old
    def test_regular_input(self):
        with tempfile.TemporaryDirectory() as d:
            r=Path(d); (r/'a').write_bytes(b'yes'); (r/'link').symlink_to(r/'a')
            self.assertEqual(run.regular(r,'a'),b'yes')
            with self.assertRaises(ValueError):run.regular(r,'link')
            with self.assertRaises(ValueError):run.regular(r,'../a')
    def test_archive_rejections(self):
        for name,typ in [('a',tarfile.SYMTYPE),('../x',tarfile.REGTYPE),('b',tarfile.CHRTYPE)]:
            data=io.BytesIO()
            with tarfile.open(fileobj=data,mode='w') as t:
                m=tarfile.TarInfo(name);m.type=typ;m.linkname='elsewhere';t.addfile(m)
            with tempfile.TemporaryDirectory() as d:
                with self.assertRaises(ValueError):run.extract(data.getvalue(),Path(d)/'src')
    def test_archive_regular(self):
        data=io.BytesIO()
        with tarfile.open(fileobj=data,mode='w') as t:
            m=tarfile.TarInfo('a/b.c');m.size=3;m.mode=0o644;t.addfile(m,io.BytesIO(b'abc'))
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'src';run.extract(data.getvalue(),p);self.assertEqual((p/'a/b.c').read_bytes(),b'abc')
if __name__=='__main__':unittest.main(verbosity=2)

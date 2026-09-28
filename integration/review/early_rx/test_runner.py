#!/usr/bin/env python3
import hashlib
import io
from pathlib import Path
import tarfile
import tempfile
import unittest
import run
class Checks(unittest.TestCase):
    def test_digest(self):
        data=b'fixed dependency'; e={'blob':hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest(),'sha256':hashlib.sha256(data).hexdigest()}
        run.verify(data,e)
        with self.assertRaises(ValueError): run.verify(data+b'x',e)
    def test_names(self):
        for value in ['/etc/passwd','../escape','a/../../escape','.']:
            with self.assertRaises(ValueError): run.safe_name(value)
        self.assertEqual(str(run.safe_name('integration/a.c')),'integration/a.c')
    def test_output_exclusive(self):
        old=run.ROOT
        with tempfile.TemporaryDirectory() as d:
            run.ROOT=Path(d)
            try:
                run.output('build/a')
                with self.assertRaises(FileExistsError): run.output('build/a')
                for name in ['/tmp/a','../a','build/../a','a']:
                    with self.assertRaises(ValueError): run.output(name)
                (run.ROOT/'build'/'link').symlink_to(run.ROOT/'build'/'a',target_is_directory=True)
                with self.assertRaises(ValueError): run.output('build/link/out')
            finally: run.ROOT=old
    def test_archive_links(self):
        for name,kind in [('a',tarfile.SYMTYPE),('../escape',tarfile.REGTYPE),('device',tarfile.CHRTYPE)]:
            data=io.BytesIO()
            with tarfile.open(fileobj=data,mode='w') as t:
                item=tarfile.TarInfo(name); item.type=kind; item.linkname='outside'; t.addfile(item)
            with tempfile.TemporaryDirectory() as d:
                with self.assertRaises(ValueError): run.extract(data.getvalue(),Path(d)/'out')
    def test_regular_archive(self):
        data=io.BytesIO()
        with tarfile.open(fileobj=data,mode='w') as t:
            item=tarfile.TarInfo('one/two.c'); item.size=3; item.mode=0o644; t.addfile(item,io.BytesIO(b'abc'))
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'out'; run.extract(data.getvalue(),p); self.assertEqual((p/'one/two.c').read_bytes(),b'abc')
if __name__=='__main__': unittest.main(verbosity=2)

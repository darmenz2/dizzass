#!/usr/bin/env python3
import importlib.util
import tempfile
from pathlib import Path
import unittest
import compile_guard as guard
class Inputs(unittest.TestCase):
    def test_current(self):
        with tempfile.TemporaryDirectory() as d:
            r=Path(d);(r/'a.c').write_text('int x;');h={'a.c':guard.digest((r/'a.c').read_bytes())}
            self.assertEqual(guard.validate(r,['-I.','-c','a.c','-o','a.o'],h),[r/'a.c'])
    def test_staged_source(self):
        with tempfile.TemporaryDirectory() as d:
            r=Path(d);(r/'build').mkdir();(r/'build/old.c').write_text('int x;')
            with self.assertRaises(ValueError):guard.validate(r,['-c','build/old.c'],{})
    def test_shadow_include(self):
        with tempfile.TemporaryDirectory() as d:
            r=Path(d)
            for flag in [['-Ibuild/old'],['-I','build/old'],['-iquote','build/old']]:
                with self.assertRaises(ValueError):guard.validate(r,flag,{})
    def test_outside(self):
        with tempfile.TemporaryDirectory() as d:
            with self.assertRaises(ValueError):guard.validate(Path(d),['-I../outside'],{})
    def test_changed_source(self):
        with tempfile.TemporaryDirectory() as d:
            r=Path(d);(r/'a.c').write_text('different')
            with self.assertRaises(ValueError):guard.validate(r,['-c','a.c'],{'a.c':'wrong'})
    def test_symlink_escape(self):
        with tempfile.TemporaryDirectory() as d:
            r=Path(d);(r/'escape').symlink_to(r.parent,target_is_directory=True)
            with self.assertRaises(ValueError):guard.validate(r,['-Iescape'],{})
if __name__=='__main__':unittest.main(verbosity=2)

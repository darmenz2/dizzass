#!/usr/bin/env python3
# Runner-control tests ONLY. subprocess results are explicitly simulated here.
import contextlib
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest import mock
import run_a16 as subject

class ActualRunnerTests(unittest.TestCase):
    def setUp(self):
        temporary=tempfile.TemporaryDirectory(prefix='r01-a16-runner-test-')
        self.addCleanup(temporary.cleanup)
        self.root=Path(temporary.name)
        self.here=self.root/subject.REL
        (self.here/'evidence').mkdir(parents=True)
        data=b'pinned\n'
        self.entry={'commit':'c','path':'integration/native/test.c',
            'blob':hashlib.sha1(b'blob 7\0'+data).hexdigest(),
            'sha256':hashlib.sha256(data).hexdigest()}
        manifest={'base':'b','base_tree':'t','actual_a16':'a','pending':[self.entry]}
        (self.here/'manifest_a16.json').write_text(json.dumps(manifest))
        for name in ('test_stack.c','test_actual_a16.c','suite.mk','evidence/cancel_probe.c'):
            (self.here/name).write_text('/* test fixture */\n')
        stream=io.BytesIO()
        with tarfile.open(fileobj=stream,mode='w') as archive:
            entry=tarfile.TarInfo('root.c'); entry.size=7
            archive.addfile(entry,io.BytesIO(data))
        self.archive=stream.getvalue()
        self.corrupt=False
        self.health=0
        self.calls=[]
        for target,value in ((subject,'HERE'),(subject.base,'ROOT')):
            patch=mock.patch.object(target,value,self.here if value=='HERE' else self.root)
            patch.start(); self.addCleanup(patch.stop)
    def git(self,*args):
        if args[0]=='rev-parse': return b't\n'
        if args[0]=='archive': return self.archive
        if args[0]=='show': return b'changed\n' if self.corrupt else b'pinned\n'
        raise AssertionError(args)
    def process(self,command,**kwargs):
        self.calls.append(command)
        self.assertEqual(kwargs['env']['ASAN_OPTIONS'],'detect_leaks=1:halt_on_error=1')
        self.assertEqual(kwargs['env']['UBSAN_OPTIONS'],'halt_on_error=1')
        code=self.health if command[-1]=='./sanitizer-health' else 0
        kwargs['stdout'].write(b'simulated subprocess result\n')
        return subprocess.CompletedProcess(command,code)
    def invoke(self):
        with mock.patch.object(subject.base,'git_bytes',self.git), \
             mock.patch.object(subject.subprocess,'run',self.process), \
             mock.patch.object(sys,'argv',['run_a16.py','--out','build/test','--sanitize']), \
             contextlib.redirect_stdout(io.StringIO()),contextlib.redirect_stderr(io.StringIO()):
            result=subject.main()
        path=self.root/'build/test/results.json'
        return result,json.loads(path.read_text()) if path.exists() else None
    def test_failed_health_stops_before_application(self):
        self.health=1
        code,report=self.invoke()
        self.assertEqual(code,1)
        self.assertEqual(report['status'],'BLOCKED_SANITIZER_HEALTH')
        self.assertFalse(report['actual_a16_executed'])
        self.assertEqual(len(self.calls),3)
        self.assertFalse(any(x[0] in ('make','autoreconf','./configure') for x in self.calls))
    def test_corrupt_dependency_stops_before_any_process(self):
        self.corrupt=True
        code,report=self.invoke()
        self.assertEqual(code,1)
        self.assertIsNone(report)
        self.assertEqual(self.calls,[])
        self.assertFalse((self.root/'build').exists())
    def test_health_success_alone_cannot_pass_application(self):
        code,report=self.invoke()
        self.assertEqual(code,1)
        self.assertEqual(report['status'],'FAIL')
        self.assertTrue(report['actual_a16_executed'])
        self.assertEqual(report['error'],'missing semantic markers')
        self.assertTrue(any(x[0]=='make' for x in self.calls))

if __name__=='__main__':
    unittest.main(verbosity=2)

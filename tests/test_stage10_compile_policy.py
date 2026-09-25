#!/usr/bin/env python3
"""Require explicit rejection of math transformations outside the recovered API."""
from pathlib import Path
import json,subprocess,tempfile
ROOT=Path(__file__).resolve().parents[1]
records=[]
with tempfile.TemporaryDirectory(prefix='vn135-fp-policy-') as td:
    for cc in ('gcc','clang'):
        for flag in ('-ffast-math','-ffinite-math-only'):
            cmd=[cc,'-std=c11','-Werror','-Iinclude',flag,'-c','src/frontend/cgminer.c','-o',str(Path(td)/'test.o')]
            r=subprocess.run(cmd,cwd=ROOT,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
            if r.returncode==0 or 'Recovered floating-point arithmetic requires strict IEEE semantics' not in r.stdout:
                raise AssertionError((cmd,r.returncode,r.stdout))
            records.append({'compiler':cc,'flag':flag,'rejected':True})
print(json.dumps({'stage':10,'status':'PASS','compile_policy_checks':records}))

#!/usr/bin/env python3
"""Offline-only checks of fork planning. Does NOT create or test a GitHub fork."""
from pathlib import Path
import json,subprocess,sys,tempfile
R=Path(__file__).resolve().parents[1];sys.path.insert(0,str(R/'tools'))
from prepare_cgminer_fork import plan
lock=json.loads((R/'reconstruction/upstream.lock.json').read_text())
p=plan('darmenz2','cgminer-vn135-base',Path('/tmp/new-base'),True,lock)
assert p['pushes_commits'] is False and p['uploads_overlay_or_vendor_files'] is False
assert p['commands'][1]==['gh','repo','fork','ckolivas/cgminer','--fork-name','cgminer-vn135-base','--clone=false','--remote=false']
assert p['base_commit']==lock['commit'] and not p['exact_vendor_ancestor_proven']
for owner,name in [('../bad','fine'),('darmenz2','x/y'),('','x'),('x',';rm -rf')]:
 try:plan(owner,name,Path('/tmp/out'),False,lock)
 except ValueError:pass
 else:raise AssertionError('Invalid name accepted')
with tempfile.TemporaryDirectory() as d:
 out=Path(d)/'new';a=subprocess.run([sys.executable,str(R/'tools/prepare_cgminer_fork.py'),'--output',str(out),'--apply-overlay'],capture_output=True,text=True,check=True)
 data=json.loads(a.stdout);assert data['dry_run'] and data['network_called'] is False and not out.exists()
 b=subprocess.run([sys.executable,str(R/'tools/prepare_cgminer_fork.py'),'--output',d],capture_output=True,text=True)
 assert b.returncode==1
assert 'push' not in [arg for cmd in p['commands'] for arg in cmd]
print('Fork helper offline plan/validation PASS; real remote fork NOT created/tested')

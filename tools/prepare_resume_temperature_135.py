#!/usr/bin/env python3
"""Stage eight pinned dependency files in build/, never merge or fetch a branch.
Default reads already fetched exact commits using git cat-file. --source-tree is
an offline, hash-checked source copy, not a claim of locally available history.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import subprocess
ROOT=Path(__file__).resolve().parents[1]
MANIFEST=ROOT/'integration/evidence/resume_temperature_135.json'

def digest(data):
    return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--source-tree',type=Path)
    p.add_argument('--check',action='store_true')
    a=p.parse_args(); out=a.out.resolve(); manifest=json.loads(MANIFEST.read_text())
    if not out.is_relative_to(ROOT/'build') or out==ROOT/'build':
        raise ValueError('destination must be a child of this checkout build directory')
    for path,expected in manifest["immutable"].items():
        if hashlib.sha256((ROOT/path).read_bytes()).hexdigest()!=expected:
            raise ValueError("immutable dependency changed: "+path)
    pending=[]
    for item in manifest['dependencies']:
        path=PurePosixPath(item['path'])
        if path.is_absolute() or '..' in path.parts:raise ValueError('unsafe dependency path')
        if a.check:data=(out/path).read_bytes()
        elif a.source_tree:data=(a.source_tree/path).read_bytes()
        else:
            spec=item['commit']+':'+item['path']
            blob=subprocess.check_output(['git','rev-parse',spec],cwd=ROOT,text=True).strip()
            if blob!=item['blob']:raise ValueError('commit/path mapping mismatch: '+spec)
            data=subprocess.check_output(['git','cat-file','blob',blob],cwd=ROOT)
        if digest(data)!=item['blob'] or hashlib.sha256(data).hexdigest()!=item['sha256']:
            raise ValueError('dependency bytes mismatch: '+item['path'])
        pending.append((path,data))
    # Validate every input before touching output; no reference binary is executed.
    if not a.check:
        for path,data in pending:
            target=out/path
            if not target.resolve().is_relative_to(out):raise ValueError('output symlink escape')
            if target.exists() and target.read_bytes()!=data:
                raise ValueError('refusing changed existing dependency: '+str(target))
        out.mkdir(parents=True,exist_ok=True)
        marker=out/'.gitignore'
        if marker.is_symlink():raise ValueError('refusing ignore-marker symlink')
        marker.write_text('*\n')
        for path,data in pending:
            target=out/path;target.parent.mkdir(parents=True,exist_ok=True);target.write_bytes(data)
    print('RESUME_TEMPERATURE_DEPENDENCIES_PASS',len(pending),
          'offline-copy' if a.source_tree else 'staged-check' if a.check else 'exact-git-commits')
if __name__=='__main__': main()

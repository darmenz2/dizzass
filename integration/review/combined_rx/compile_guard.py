#!/usr/bin/env python3
"""Audit actual compiler inputs; reject stale staged C/headers before acceptance."""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys

def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def system_path(value: str) -> bool:
    p=Path(value)
    if not p.is_absolute():return False
    p=p.resolve()
    return any(p==r or r in p.parents for r in (Path('/usr/include'),Path('/usr/local/include')))

def checked_path(root: Path, value: str) -> Path:
    path=(root/value).resolve()
    relative=path.relative_to(root)
    if not relative.parts or relative.parts[0] in ('build','.git'):
        raise ValueError('build/staged/outside input: '+value)
    return path

def validate(root: Path, args: list[str], hashes: dict[str,str]) -> list[Path]:
    sources=[]
    for i,arg in enumerate(args):
        if arg.endswith('.c'):
            path=checked_path(root,arg)
            if hashes.get(str(path.relative_to(root)))!=digest(path.read_bytes()):
                raise ValueError('uncommitted/substituted C: '+arg)
            sources.append(path)
        if arg in ('-I','-iquote','-isystem'):
            value=args[i+1]
        elif arg.startswith('-I'):
            value=arg[2:]
        else: continue
        if value not in ('.','./') and not system_path(value):
            checked_path(root,value)
    if '-c' in args and len(sources)!=1:
        raise ValueError('expected one actual current-source compilation')
    return sources

def main() -> int:
    ap=argparse.ArgumentParser()
    ap.add_argument('--compiler',required=True);ap.add_argument('--inputs',type=Path,required=True)
    ap.add_argument('--records',type=Path,required=True);ap.add_argument('args',nargs=argparse.REMAINDER)
    a=ap.parse_args();args=a.args
    if args and args[0]=='--':args=args[1:]
    root=Path.cwd().resolve();report={'argv':args,'compiler':a.compiler,'returncode':None,'inputs':{}}
    record=a.records/(str(os.getpid())+'.json')
    try:
        hashes=json.loads(a.inputs.read_text());sources=validate(root,args,hashes)
        dep=None
        if '-c' in args:
            obj=Path(args[args.index('-o')+1]);dep=Path(str(obj)+'.r06.d')
            args=args+['-MMD','-MF',str(dep)]
        p=subprocess.run([a.compiler,*args]);report['returncode']=p.returncode
        if p.returncode:return p.returncode
        if dep:
            text=dep.read_text().replace('\\\n',' ')
            # Only the first rule contains inputs; -MP appends empty header rules.
            names=shlex.split(text.splitlines()[0].split(':',1)[1])
            for name in names:
                if system_path(name):continue
                path=checked_path(root,name);rel=str(path.relative_to(root));sha=digest(path.read_bytes())
                if hashes.get(rel)!=sha:raise ValueError('untracked/substituted include: '+rel)
                report['inputs'][rel]=sha
            if not report['inputs']:raise ValueError('empty dependency evidence')
        return 0
    except (OSError,ValueError,KeyError,IndexError,subprocess.SubprocessError) as e:
        report['error']=str(e);report['returncode']=97
        print('R06_INPUT_REJECT: '+str(e),file=sys.stderr);return 97
    finally:
        a.records.mkdir(parents=True,exist_ok=True);record.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

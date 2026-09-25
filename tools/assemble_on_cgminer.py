#!/usr/bin/env python3
"""Create a new upstream cgminer tree with this additive source overlay.
The supplied source checkout is never changed. ASICs are never contacted.
"""
from __future__ import annotations
import argparse,hashlib,io,json,os,shutil,subprocess,tarfile,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
INCLUDE='\n# VNish 1.3.5 recovery: additive, no active T21 hardware driver.\ninclude $(top_srcdir)/reconstruction/cgminer-overlay.am\n'

def git(repo,*args):
    return subprocess.check_output(['git','-C',str(repo),*args],stderr=subprocess.STDOUT).decode().strip()

def blob_sha(data):return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()

def verify_source(source,lock):
    if git(source,'rev-parse','HEAD')!=lock['commit']:raise ValueError('Source must be at the pinned upstream commit')
    if git(source,'rev-parse','HEAD^{tree}')!=lock['tree']:raise ValueError('Unexpected upstream tree')
    data=subprocess.check_output(['git','-C',str(source),'show',lock['commit']+':Makefile.am'])
    if blob_sha(data)!=lock['makefile_am_git_blob']:raise ValueError('Makefile.am does not match pinned upstream')
    if git(source,'status','--porcelain'):
        raise ValueError('Source checkout must be clean; local changes are not silently ignored')
    tree=git(source,'ls-tree','-r',lock['commit'])
    if any(line.startswith('160000 ') for line in tree.splitlines()):
        raise ValueError('Pinned tree contains submodules; explicit export handling is required')

def copy_overlay(root,dest):
    manifest=json.loads((root/'reconstruction/overlay-files.json').read_text())
    for entry in manifest:
        rel=entry['path'];src=root/rel;dst=dest/rel
        if Path(rel).is_absolute() or '..' in Path(rel).parts:raise ValueError('Unsafe overlay path')
        if not src.is_file() or src.is_symlink():raise ValueError(f'Invalid overlay entry: {rel}')
        if hashlib.sha256(src.read_bytes()).hexdigest()!=entry['sha256']:raise ValueError(f'Modified overlay: {rel}')
        if dst.exists() or dst.is_symlink():raise ValueError(f'Refusing to overwrite upstream file: {rel}')
        if not dst.parent.resolve().is_relative_to(dest.resolve()):raise ValueError('Overlay path traverses upstream symlink')
        dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,dst)
    own_manifest=dest/'reconstruction/overlay-files.json'
    if own_manifest.exists():raise ValueError('Overlay manifest collision')
    own_manifest.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(root/'reconstruction/overlay-files.json',own_manifest)
    mf=dest/'Makefile.am'
    if 'cgminer-overlay.am' in mf.read_text():raise ValueError('Overlay already applied')
    with mf.open('a') as f:f.write(INCLUDE)

def extract_git_archive(data,dest):
    with tarfile.open(fileobj=io.BytesIO(data),mode='r:') as t:
        for m in t:
            relative=Path(m.name)
            if relative.is_absolute() or '..' in relative.parts:raise ValueError('Unsafe upstream archive path')
            p=dest/relative
            if m.isdir():p.mkdir(parents=True,exist_ok=True)
            elif m.isfile():
                p.parent.mkdir(parents=True,exist_ok=True)
                p.write_bytes(t.extractfile(m).read());p.chmod(m.mode&0o777)
            elif m.issym():
                target=Path(os.path.normpath(str(p.parent/m.linkname)))
                if Path(m.linkname).is_absolute() or not target.is_relative_to(dest):raise ValueError('Unsafe upstream symlink')
                p.parent.mkdir(parents=True,exist_ok=True);p.symlink_to(m.linkname)
            else:raise ValueError(f'Unsupported upstream entry: {m.name}')

def assemble(source,output,lock,root=ROOT):
    output=output.resolve()
    if output.exists():raise ValueError('Output must not already exist; no existing worktree is overwritten')
    verify_source(source,lock)
    raw=subprocess.check_output(['git','-C',str(source),'archive','--format=tar',lock['commit']])
    output.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.vn135-assemble-',dir=output.parent) as temp:
        staging=Path(temp)/'tree';staging.mkdir()
        extract_git_archive(raw,staging);copy_overlay(root,staging)
        record={'upstream':lock,'overlay_applied':True,'upstream_files_changed':['Makefile.am'],
                'linkage':'Offline-tested recovered modules; no T21 driver registration',
                'base_build_tested_here':False,'hardware_runtime_ready':False}
        (staging/'RECONSTRUCTION_ASSEMBLY.json').write_text(json.dumps(record,indent=2)+'\n')
        staging.rename(output)
    print(f'Created: {output}\nOriginal source checkout was not changed. No firmware was installed.')

def main():
    p=argparse.ArgumentParser(description=__doc__)
    g=p.add_mutually_exclusive_group(required=True)
    g.add_argument('--source',type=Path,help='Existing checkout at the pinned upstream commit')
    g.add_argument('--fetch',action='store_true',help='Fetch the pinned public upstream using git (requires Internet)')
    p.add_argument('--output',type=Path,required=True,help='NEW directory to create')
    a=p.parse_args();lock=json.loads((ROOT/'reconstruction/upstream.lock.json').read_text())
    try:
        if a.source:assemble(a.source.resolve(),a.output,lock)
        else:
            with tempfile.TemporaryDirectory(prefix='cgminer-upstream-') as temp:
                source=Path(temp)
                subprocess.run(['git','init','--quiet',str(source)],check=True)
                subprocess.run(['git','-C',str(source),'remote','add','origin',lock['repository']],check=True)
                subprocess.run(['git','-C',str(source),'fetch','--depth=1','origin',lock['commit']],check=True)
                subprocess.run(['git','-C',str(source),'checkout','--quiet','--detach','FETCH_HEAD'],check=True)
                assemble(source,a.output,lock)
    except (OSError,ValueError,subprocess.CalledProcessError) as e:
        p.exit(1,f'Assembly failed: {e}\nNo completed output tree was published.\n')
if __name__=='__main__':main()

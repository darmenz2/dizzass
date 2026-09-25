#!/usr/bin/env python3
"""Prepare a real upstream fork/checkout with history. Dry-run by default.
--execute explicitly creates a PUBLIC upstream fork under the expected account.
No vendor binary, disassembly, source overlay, commit or push is uploaded.
--apply-overlay copies this user's reference material LOCALLY, never remotely.
An existing user checkout is never modified. Upstream identity remains provisional.
"""
from __future__ import annotations
import argparse,json,os,re,shutil,subprocess,tempfile
from pathlib import Path
from assemble_on_cgminer import verify_source,copy_overlay
ROOT=Path(__file__).resolve().parents[1]
SOURCE='ckolivas/cgminer'
BRANCH='reconstruction/vn135-stage14'
def command(args,*,cwd=None):
    return subprocess.check_output(args,cwd=cwd,text=True,stderr=subprocess.STDOUT).strip()
def plan(owner,name,out,overlay,lock):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9-]{0,38}',owner):raise ValueError('Invalid GitHub owner')
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,90}',name):raise ValueError('Invalid repository name')
    return {'remote_target':owner+'/'+name,'fork_source':SOURCE,'base_commit':lock['commit'],
      'exact_vendor_ancestor_proven':False,'new_checkout':str(out),'local_branch':BRANCH,
      'apply_overlay_locally':overlay,'uploads_overlay_or_vendor_files':False,
      'pushes_commits':False,'commands':[
       ['gh','api','user','--jq','.login'],
       ['gh','repo','fork',SOURCE,'--fork-name',name,'--clone=false','--remote=false'],
       ['gh','api','repos/'+owner+'/'+name],
       ['gh','repo','clone',owner+'/'+name,'<temporary-new-checkout>'],
       ['git','fetch','--no-tags','https://github.com/'+SOURCE+'.git',lock['commit']],
       ['git','checkout','-b',BRANCH,lock['commit']]]}
def execute(p,lock,out,run=command):
    if out.exists() or out.is_symlink():raise ValueError('Output already exists; refusing to modify it')
    if not shutil.which('gh') or not shutil.which('git'):raise ValueError('Install/authenticate gh and git first')
    owner=p['remote_target'].split('/')[0]
    if run(p['commands'][0])!=owner:raise ValueError('Active gh account differs from --owner; no fork created')
    # This creates ONLY the public upstream fork. A later local failure does not
    # delete a remote fork. Never rename/delete an existing user repository.
    run(p['commands'][1])
    meta=json.loads(run(p['commands'][2]))
    if meta.get('full_name')!=p['remote_target'] or not meta.get('fork') or meta.get('parent',{}).get('full_name')!=SOURCE:
        raise ValueError('Returned repository is not the expected direct fork; no local overlay applied')
    out.parent.mkdir(parents=True,exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='.vn135-fork-',dir=out.parent) as temp:
        dest=Path(temp)/'checkout'
        run(['gh','repo','clone',p['remote_target'],str(dest)])
        run(p['commands'][4],cwd=dest)
        run(p['commands'][5],cwd=dest)
        verify_source(dest,lock)
        if p['apply_overlay_locally']:copy_overlay(ROOT,dest)
        # Extra local accident-prevention. No commit is staged. The reference ELF
        # stays on disk for tests but is not a candidate for ordinary git add .
        ex=dest/'.git/info/exclude';ex.parent.mkdir(parents=True,exist_ok=True)
        with ex.open('a') as f:f.write('\n# User-supplied vendor evidence: local only\n/reference/\n/evidence/\n*.elf\n*.tar.gz\n/build/\n')
        result={'fork_url':meta['html_url'],'base_commit':lock['commit'],'branch':BRANCH,
          'full_history_clone_requested':True,'overlay_local':p['apply_overlay_locally'],
          'commits_created':False,'pushed':False,'hardware_tested':False,'upstream_built':False}
        (dest/'LOCAL_FORK_PREPARATION.json').write_text(json.dumps(result,indent=2)+'\n')
        dest.rename(out)
    return result

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--owner',default='darmenz2');ap.add_argument('--fork-name',default='cgminer-vn135-base')
    ap.add_argument('--output',type=Path,required=True);ap.add_argument('--apply-overlay',action='store_true')
    ap.add_argument('--execute',action='store_true',help='Create the remote public fork and new local checkout; never push overlay')
    a=ap.parse_args();lock=json.loads((ROOT/'reconstruction/upstream.lock.json').read_text())
    try:
        out=a.output.resolve();p=plan(a.owner,a.fork_name,out,a.apply_overlay,lock)
        if out.exists():raise ValueError('Output must be a NEW path')
        if out.is_relative_to(ROOT):raise ValueError('Output must be outside this overlay tree')
        if not a.execute:print(json.dumps({'dry_run':True,'network_called':False,**p},indent=2));return 0
        print(json.dumps(execute(p,lock,out),indent=2));return 0
    except (OSError,ValueError,subprocess.CalledProcessError) as e:
        ap.exit(1,str(e)+'\nA public upstream fork may already have been created; it is not automatically deleted. No overlay push was performed.\n')
if __name__=='__main__':raise SystemExit(main())

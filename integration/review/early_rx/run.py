#!/usr/bin/env python3
# GPL-3.0-or-later. Build the ACTUAL candidate in a fresh offline source copy.
from __future__ import annotations
import argparse
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tarfile
import time
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/early_rx')
def digest(data): return hashlib.sha256(data).hexdigest()
def git(*args):
    return subprocess.run(['git',*args],cwd=ROOT,check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=60).stdout
def verify(data,entry):
    obj=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
    if obj!=entry['blob'] or digest(data)!=entry['sha256']: raise ValueError('dependency hash mismatch')
def safe_name(name):
    p=PurePosixPath(name)
    if p.is_absolute() or '..' in p.parts or not p.parts: raise ValueError('unsafe archive path')
    return p

def extract(data,destination):
    destination.mkdir()
    with tarfile.open(fileobj=io.BytesIO(data),mode='r:') as archive:
        for m in archive.getmembers():
            p=destination.joinpath(*safe_name(m.name).parts)
            if m.isdir(): p.mkdir(parents=True,exist_ok=True)
            elif m.isfile():
                p.parent.mkdir(parents=True,exist_ok=True)
                with archive.extractfile(m) as src, p.open('xb') as dst: dst.write(src.read())
                p.chmod(m.mode & 0o777)
            else: raise ValueError('archive links and special files rejected')
def output(name):
    p=Path(name)
    if p.is_absolute() or '..' in p.parts or len(p.parts)<2 or p.parts[0]!='build':
        raise ValueError('output must be a fresh build subdirectory')
    out=ROOT/p
    for parent in [out,*out.parents]:
        if parent.is_symlink(): raise ValueError('symlink output rejected')
        if parent==ROOT: break
    out.mkdir(parents=True,exist_ok=False)
    return out

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',choices=['gcc','clang','clang-17'],default='gcc')
    ap.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    ap.add_argument('--out',required=True)
    ap.add_argument('--sanitize',action='store_true')
    ap.add_argument('--mutants',action='store_true')
    args=ap.parse_args()
    if args.sanitize and args.mutants: ap.error('run mutation and sanitizer groups separately')
    report={'status':'FAIL','cc':args.cc,'baseline':args.baseline,'sanitized':args.sanitize,
        'support_objects_sanitized':False,'commands':[],'mutants':[],
        'physical_asic':False,'pool_submission':False}
    out=None
    try:
        head=git('rev-parse','HEAD').decode().strip()
        manifest=json.loads((ROOT/REL/'manifest.json').read_text())
        material=[]
        for e in manifest['pending']:
            safe_name(e['path'])
            if len(e['commit'])!=40 or any(c not in '0123456789abcdef' for c in e['commit']):
                raise ValueError('invalid dependency commit')
            data=git('show',e['commit']+':'+e['path']); verify(data,e); material.append((e,data))
        paths=['integration/native_jobs.c','integration/native_jobs.h','integration/native/early_rx.c',
            'integration/native/early_rx.h']+[str(REL/p) for p in ['test.c','suite.mk','run.py','manifest.json','host_compat.h']]
        hashes={}
        for name in paths:
            data=git('show',head+':'+name)
            if data!=(ROOT/name).read_bytes(): raise ValueError('uncommitted input: '+name)
            hashes[name]=digest(data)
        out=output(args.out); native=out/'source'; logs=out/'logs'; logs.mkdir()
        extract(git('archive','--format=tar',head),native)
        report.update(source_head=head,source_tree=git('rev-parse',head+'^{tree}').decode().strip(),source_hashes=hashes,dependencies=manifest['pending'])
        deps=native/'build/r02-deps'
        for e,data in material:
            p=deps/e['path']; p.parent.mkdir(parents=True,exist_ok=True); p.write_bytes(data)
        def run(stage,command,allowed=(0,),timeout=240):
            rec={'stage':stage,'argv':command,'returncode':None}; report['commands'].append(rec)
            log=logs/(stage+'.log'); start=time.monotonic()
            with log.open('xb') as stream:
                p=subprocess.run(command,cwd=native,stdout=stream,stderr=subprocess.STDOUT,timeout=timeout,
                    env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1'})
            rec.update(returncode=p.returncode,seconds=round(time.monotonic()-start,3),log=str(log.relative_to(out)),sha256=digest(log.read_bytes()))
            print(stage+': '+str(p.returncode),flush=True)
            if p.returncode not in allowed:
                if stage=='sanitizer-health': report['status']='BLOCKED_SANITIZER_HEALTH'
                raise RuntimeError(stage+' failed; see '+str(log))
            return log.read_text(errors='replace')
        report['compiler']=run('compiler',[args.cc,'--version']).splitlines()[0]
        if args.sanitize:
            run('health-build',[args.cc,'-std=c11','-O1','-g','-pthread','-fsanitize=address,undefined',
                '-fno-omit-frame-pointer','-fno-pie','-no-pie',str(deps.relative_to(native)/'integration/review/native_uart_stack/evidence/cancel_probe.c'),'-o','health'])
            run('sanitizer-health',['timeout','15','./health'])
        run('autoreconf',['autoreconf','-fi'])
        config=['./configure','--enable-'+args.baseline,'--disable-curses','CC='+args.cc,'CFLAGS=-O2 -fcommon']
        if args.baseline=='ants2': config.append('--disable-libcurl')
        run('configure',config); run('core',['make','-j2'])
        make=['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+args.cc]
        flags=['RXQ_DIR=build/check']+(['SANITIZE=1'] if args.sanitize else [])
        text=run('inbox',make+flags+['early-rx-test'])
        if 'RXQ_PASS cases=25 ' not in text: raise RuntimeError('missing complete test marker')
        report['markers']=[x for x in text.splitlines() if x.startswith('RXQ_')]
        symbols=run('symbols',['nm','--defined-only','build/check/test'])
        names={x.split()[-1] for x in symbols.splitlines() if x.split()}
        required={'copy_work_noffset','_free_work','test_nonce','fulltest','dizzass_jobs_capture_reply',
            'dizzass_jobs_check_captured','dizzass_early_rx_offer','dizzass_early_rx_take',
            'dizzass_native_job_channel_send','__wrap_socket','__wrap_connect','__wrap_libusb_init','__wrap_strdup'}
        if not required<=names: raise RuntimeError('missing actual helpers or offline guards')
        report['symbols']=sorted(required)
        if not args.sanitize:
            old=['make','-f','Makefile','-f','integration/native-jobs.mk','CC='+args.cc]
            if args.baseline=='ants2':
                old.append('DIZZASS_JOBS_FLAGS=$(DIZZASS_NONCE_FLAGS) -fno-builtin-strdup -include '+str(REL/'host_compat.h'))
            run('old-jobs',old+['dizzass-native-jobs-test'])
            run('source-boundaries',['python3','integration/test_native_core.py'])
        if args.mutants:
            controls=[
                ('ignore-captured-serial','integration/native_jobs.c',
                 'if (!rc) rc = jobs_check_locked(jobs, ticket->epoch, reply, out);',
                 'rc = jobs_check_locked(jobs, ticket->epoch, reply, out);','e.job_status==DIZZASS_JOBS_STALE_TICKET'),
                ('pending-reported-empty','integration/native/early_rx.c',
                 'if (rc == DIZZASS_JOBS_PENDING) continue;',
                 'if (rc == DIZZASS_JOBS_PENDING) return DIZZASS_EARLY_RX_EMPTY;','dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_WAITING'),
                ('overflow-not-latched','integration/native/early_rx.c',
                 'q->stopped = DIZZASS_EARLY_RX_OVERFLOW;','return DIZZASS_EARLY_RX_OVERFLOW;','dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_OVERFLOW'),
                ('drop-copy-failure','integration/native/early_rx.c',
                 'if (rc && !terminal_rejection(rc)) return rc;','/* mutation: consume recoverable error */','dizzass_early_rx_take(q,&e)==DIZZASS_NONCE_PARTIAL_COPY'),
                ('erase-captured-epoch','integration/native/early_rx.c',
                 'event.captured = q->entries[i].ticket;','event.captured = q->entries[i].ticket; ++event.captured.epoch;','dizzass_early_rx_take(q,&e)==DIZZASS_EARLY_RX_WAITING')]
            for label,name,old,new,witness in controls:
                p=native/name; original=p.read_text()
                if original.count(old)!=1: raise ValueError('changed mutation anchor '+label)
                try:
                    p.write_text(original.replace(old,new,1)); directory='build/m-'+label
                    run(label+'-build',make+['RXQ_DIR='+directory,directory+'/test'])
                    rejected=run(label,['timeout','45',directory+'/test'],allowed=(1,))
                    if 'RXQ_ASSERT' not in rejected or witness not in rejected: raise RuntimeError('wrong mutant rejection '+label)
                    report['mutants'].append(label)
                finally: p.write_text(original)
        for e,_ in material: verify((deps/e['path']).read_bytes(),e)
        for name,sha in hashes.items():
            if digest((native/name).read_bytes())!=sha: raise RuntimeError('source not restored '+name)
        report['status']='PASS'; print('RXQ_REVIEW_PASS',flush=True); return 0
    except (OSError,ValueError,RuntimeError,KeyError,subprocess.SubprocessError) as error:
        report['error']=str(error); print('RXQ_ERROR: '+str(error),file=sys.stderr); return 1
    finally:
        if out is not None: (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__': raise SystemExit(main())

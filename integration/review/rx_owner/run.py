#!/usr/bin/env python3
"""R-04 offline runner: current accepted sources plus EXPLICIT pending R-03 APIs."""
from __future__ import annotations
import argparse
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import subprocess
import sys
import tarfile
import time
ROOT = Path(__file__).resolve().parents[3]
REL = Path('integration/review/rx_owner')
def digest(data): return hashlib.sha256(data).hexdigest()
def git(*args):
    return subprocess.run(['git', *args], cwd=ROOT, check=True, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, timeout=60).stdout

def safe_name(name):
    p = PurePosixPath(name)
    if p.is_absolute() or '..' in p.parts or not p.parts:
        raise ValueError('unsafe path')
    return p

def regular(root, name):
    p = root.joinpath(*safe_name(name).parts)
    for parent in (p, *p.parents):
        if parent.is_symlink(): raise ValueError('symlink rejected')
        if parent == root: break
    if not p.is_file(): raise ValueError('not a regular file')
    return p.read_bytes()

def verify(data, entry):
    blob = hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
    if blob != entry['blob'] or digest(data) != entry['sha256']:
        raise ValueError('hash mismatch: '+entry['path'])

def extract(data, destination):
    destination.mkdir()
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:') as archive:
        for m in archive.getmembers():
            p = destination.joinpath(*safe_name(m.name).parts)
            if m.isdir(): p.mkdir(parents=True, exist_ok=True)
            elif m.isfile():
                p.parent.mkdir(parents=True, exist_ok=True)
                with archive.extractfile(m) as src, p.open('xb') as dst: dst.write(src.read())
                p.chmod(m.mode & 0o777)
            else: raise ValueError('links/special files in source archive')

def output(name):
    p = Path(name)
    if p.is_absolute() or '..' in p.parts or len(p.parts)<2 or p.parts[0]!='build':
        raise ValueError('output must be a fresh build subdirectory')
    out = ROOT/p
    for parent in (out, *out.parents):
        if parent.is_symlink(): raise ValueError('symlink output')
        if parent == ROOT: break
    out.mkdir(parents=True, exist_ok=False)
    return out

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',choices=['gcc','clang','gcc-14','clang-17'],default='gcc')
    ap.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    ap.add_argument('--out',required=True)
    ap.add_argument('--deps-from',type=Path)
    ap.add_argument('--sanitize',action='store_true')
    ap.add_argument('--mutants',action='store_true')
    a=ap.parse_args()
    if a.sanitize and a.mutants: ap.error('run sanitizer and mutation groups separately')
    report={'status':'FAIL','cc':a.cc,'baseline':a.baseline,'sanitized_direct_units':a.sanitize,
        'support_objects_sanitized':False,'offline_dependencies':a.deps_from is not None,
        'commands':[],'mutants':[],'physical_asic':False,'network':False}
    out=None
    try:
        head=git('rev-parse','HEAD').decode().strip()
        manifest=json.loads((ROOT/REL/'manifest.json').read_text())
        for e in manifest['accepted']: verify(regular(ROOT,e['path']),e)
        material=[]
        for e in manifest['pending']:
            if not re.fullmatch('[0-9a-f]{40}',e['commit']): raise ValueError('invalid commit')
            data=regular(a.deps_from.absolute(),e['path']) if a.deps_from else git('show',e['commit']+':'+e['path'])
            verify(data,e); material.append((e,data))
        paths=['integration/native/rx_owner.c','integration/native/rx_owner.h'] + [str(REL/n) for n in
            ['test.c','suite.mk','run.py','manifest.json','host_compat.h','regressions.mk']]
        hashes={}
        for name in paths+[e['path'] for e in manifest['accepted']]:
            b=git('show',head+':'+name)
            if b!=regular(ROOT,name): raise ValueError('uncommitted input: '+name)
            hashes[name]=digest(b)
        out=output(a.out); src=out/'source'; extract(git('archive','--format=tar',head),src)
        logs=out/'logs'; logs.mkdir(); deps=src/'build/r04-deps'
        for e,b in material:
            p=deps/e['path'];p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
        report.update(source_head=head,source_tree=git('rev-parse',head+'^{tree}').decode().strip(),
                      source_hashes=hashes,pending=manifest['pending'])
        def run(stage,cmd,allowed=(0,),timeout=240):
            rec={'stage':stage,'argv':cmd,'returncode':None};report['commands'].append(rec)
            log=logs/(stage+'.log'); start=time.monotonic()
            try:
                with log.open('xb') as f:
                    p=subprocess.run(cmd,cwd=src,stdout=f,stderr=subprocess.STDOUT,timeout=timeout,
                        env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1'})
                rec['returncode']=p.returncode
            finally:
                rec.update(seconds=round(time.monotonic()-start,3),log=str(log.relative_to(out)),sha256=digest(log.read_bytes()))
            print(stage+': '+str(p.returncode),flush=True)
            if p.returncode not in allowed:
                if stage=='sanitizer-health':report['status']='BLOCKED_SANITIZER_HEALTH'
                raise RuntimeError(stage+' failed; see '+str(log))
            return log.read_text(errors='replace')
        report['compiler']=run('compiler',[a.cc,'--version']).splitlines()[0]
        if a.sanitize:
            run('health-build',[a.cc,'-std=c11','-O1','-g','-pthread','-fsanitize=address,undefined',
                '-fno-omit-frame-pointer','-fno-pie','-no-pie','build/r04-deps/integration/review/native_uart_stack/evidence/cancel_probe.c','-o','health'])
            run('sanitizer-health',['timeout','15','./health'])
        run('autoreconf',['autoreconf','-fi'])
        configure=['./configure','--enable-'+a.baseline,'--disable-curses','CC='+a.cc,'CFLAGS=-O2 -fcommon']
        if a.baseline=='ants2':configure.append('--disable-libcurl')
        run('configure',configure);run('core',['make','-j2']);run('version',['./cgminer','--version'])
        make=['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc]
        flags=['RO_DIR=build/check']+(['SANITIZE=1'] if a.sanitize else [])
        text=run('owner',make+flags+['rx-owner-test'])
        match=re.search(r'R04_PASS cases=38 checks=(\d+) native_calls=51 ',text)
        if not match:raise RuntimeError('missing complete owner result')
        report.update(scenarios=38,assertions=int(match[1]),native_calls=51,
            markers=[line for line in text.splitlines() if line.startswith('R04_')])
        symbols=run('symbols',['nm','--defined-only','build/check/test'])
        names={line.split()[-1] for line in symbols.splitlines() if line.split()}
        required={'copy_work_noffset','_free_work','test_nonce','fulltest','submit_nonce',
            'dizzass_submitter_run_captured','dizzass_early_rx_dispatch','dizzass_native_job_channel_send',
            'dizzass_rx_owner_start','dizzass_rx_owner_join','dizzass_rx_owner_request_stop',
            '__wrap_socket','__wrap_connect','__wrap_libusb_init','__wrap_read','__wrap_poll','__wrap_submit_nonce'}
        if not required<=names or 'r01_unused_cgminer_main' in names:raise RuntimeError('symbol boundary mismatch')
        report['symbols']=sorted(required)
        if not a.sanitize:
            cmd=['make','-f','Makefile','-f','integration/native-submit.mk','-f',str(REL/'regressions.mk'),
                'CC='+a.cc,'RO_ANTS2='+str(int(a.baseline=='ants2')),'dizzass-native-submit-test']
            run('old-native-submit',cmd);run('source-boundaries',['python3','integration/test_native_core.py'])
            run('strict-owner',[a.cc,'-Ibuild/r04-deps','-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-pthread','-fsyntax-only','integration/native/rx_owner.c'])
            if a.cc.startswith('clang'):
                run('analyzer',[a.cc,'--analyze','-Ibuild/r04-deps','-I.','-Iinclude','-std=c11','-pthread','-Xanalyzer','-analyzer-output=text','integration/native/rx_owner.c'])
        if a.mutants:
            controls=[
                ('stop-not-respected','while (*budget && !*backoff && !stopping(o))','while (*budget && !*backoff)','r.reason==0 && !r.dispatched && queue_empty(&e)'),
                ('retag-event-epoch','event->epoch = o->config.received_epoch;','event->epoch = o->config.received_epoch + 1;','e.events[0].epoch==17'),
                ('lose-partial-count','o->report.partial_frame_bytes = o->stream.used;','o->report.partial_frame_bytes = 0;','r.partial_frame_bytes==5 && r.bytes_read==5'),
                ('start-after-stop','if (stopping(o)) return ECANCELED;','/* mutation: allow stopped start */','dizzass_rx_owner_start(e.owner)==ECANCELED'),
                ('allow-blocking-fd','if ((flags & O_ACCMODE) == O_WRONLY || !(flags & O_NONBLOCK)) return EINVAL;','if ((flags & O_ACCMODE) == O_WRONLY) return EINVAL;','dizzass_rx_owner_create(&c,&e.owner)==EINVAL'),
                ('lose-callback-reason','return e ? fail(o, DIZZASS_RX_CALLBACK_ERROR, e) : 0;','return e ? fail(o, DIZZASS_RX_INBOX_ERROR, e) : 0;','r.reason==DIZZASS_RX_CALLBACK_ERROR && r.detail==771'),
                ('omit-wake-write','ssize_t n = write(o->wake_fd, &one, sizeof one);','ssize_t n = sizeof one;','r.wake_reads>=1')]
            p=src/'integration/native/rx_owner.c'; original=p.read_text()
            for name,old,new,witness in controls:
                if original.count(old)!=1:raise ValueError('mutation anchor changed: '+name)
                try:
                    p.write_text(original.replace(old,new,1));directory='build/m-'+name
                    run(name+'-build',make+['RO_DIR='+directory,directory+'/test'])
                    text=run(name,['timeout','60',directory+'/test'],allowed=(1,),timeout=70)
                    if 'R04_ASSERT' not in text or witness not in text:raise RuntimeError('not the expected semantic rejection: '+name)
                    report['mutants'].append(name)
                finally:p.write_text(original)
        for name,sha in hashes.items():
            if digest((src/name).read_bytes())!=sha:raise RuntimeError('source not restored '+name)
        for e,_ in material:verify((deps/e['path']).read_bytes(),e)
        report['status']='PASS';print('R04_REVIEW_PASS',flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['error']=str(e);print('R04_ERROR: '+str(e),file=sys.stderr);return 1
    finally:
        if out is not None:(out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

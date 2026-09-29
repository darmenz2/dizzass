#!/usr/bin/env python3
"""R-05: archive current candidate, reuse R-04 staging, execute real lifecycle."""
from __future__ import annotations
import argparse
import importlib.util
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/io_lifecycle')
spec=importlib.util.spec_from_file_location('r04_staging',ROOT/'integration/review/rx_owner/run.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)

def require_pass(text):
    m=re.search(r'R05_PASS cases=29 checks=(\d+) native_calls=46 ',text)
    if not m:raise RuntimeError('missing full lifecycle result')
    return int(m[1])

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',choices=['gcc','clang','gcc-14','clang-17'],default='gcc')
    ap.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    ap.add_argument('--out',required=True);ap.add_argument('--deps-from',type=Path)
    ap.add_argument('--sanitize',action='store_true');ap.add_argument('--mutants',action='store_true')
    a=ap.parse_args()
    if a.sanitize and a.mutants:ap.error('Separate sanitizer and mutation runs required')
    report={'status':'FAIL','commands':[],'mutants':[],'sanitized_direct_units':a.sanitize,
        'support_objects_sanitized':False,'baseline':a.baseline,'physical_asic':False,
        'external_network':False,'offline_dependencies':a.deps_from is not None}
    out=None
    try:
        head=base.git('rev-parse','HEAD').decode().strip()
        manifest=json.loads(base.regular(ROOT,'integration/review/rx_owner/manifest.json'))
        for e in manifest['accepted']:base.verify(base.regular(ROOT,e['path']),e)
        material=[]
        for e in manifest['pending']:
            if not re.fullmatch('[0-9a-f]{40}',e['commit']):raise ValueError('bad dependency commit')
            b=base.regular(a.deps_from.absolute(),e['path']) if a.deps_from else base.git('show',e['commit']+':'+e['path'])
            base.verify(b,e);material.append((e,b))
        paths=['integration/native/io_lifecycle.c','integration/native/io_lifecycle.h',
               'integration/native/rx_owner.c','integration/native/rx_owner.h']
        paths += ['integration/review/rx_owner/'+n for n in ['test.c','run.py','suite.mk','manifest.json','regressions.mk','host_compat.h']]
        paths += [str(REL/n) for n in ['run.py','test.c','suite.mk','test_runner.py']]
        paths += [e['path'] for e in manifest['accepted']]
        hashes={}
        for p in paths:
            b=base.git('show',head+':'+p)
            if b!=base.regular(ROOT,p):raise ValueError('uncommitted input: '+p)
            hashes[p]=base.digest(b)
        out=base.output(a.out);src=out/'source';base.extract(base.git('archive','--format=tar',head),src)
        logs=out/'logs';logs.mkdir();deps=src/'build/r04-deps'
        for e,b in material:
            p=deps/e['path'];p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b)
        report.update(source_head=head,source_tree=base.git('rev-parse',head+'^{tree}').decode().strip(),source_hashes=hashes,pending=manifest['pending'])
        def run(stage,cmd,allowed=(0,),timeout=240):
            r={'stage':stage,'argv':cmd,'returncode':None};report['commands'].append(r)
            p=logs/(stage+'.log');start=time.monotonic()
            try:
                with p.open('xb') as f:
                    done=subprocess.run(cmd,cwd=src,stdout=f,stderr=subprocess.STDOUT,timeout=timeout,
                        env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1'})
                r['returncode']=done.returncode
            finally:r.update(seconds=round(time.monotonic()-start,3),log=str(p.relative_to(out)),sha256=base.digest(p.read_bytes()))
            print(stage+': '+str(done.returncode),flush=True)
            if done.returncode not in allowed:
                if stage=='sanitizer-health':report['status']='BLOCKED_SANITIZER_HEALTH'
                raise RuntimeError(stage+' failed: '+str(p))
            return p.read_text(errors='replace')
        report['compiler']=run('compiler',[a.cc,'--version']).splitlines()[0]
        if a.sanitize:
            run('health-build',[a.cc,'-std=c11','-O1','-g','-pthread','-fsanitize=address,undefined','-fno-omit-frame-pointer','-fno-pie','-no-pie',str(deps.relative_to(src)/'integration/review/native_uart_stack/evidence/cancel_probe.c'),'-o','health'])
            run('sanitizer-health',['timeout','15','./health'])
        run('autoreconf',['autoreconf','-fi'])
        cfg=['./configure','--enable-'+a.baseline,'--disable-curses','CC='+a.cc,'CFLAGS=-O2 -fcommon']
        if a.baseline=='ants2':cfg.append('--disable-libcurl')
        run('configure',cfg);run('core',['make','-j2']);run('version',['./cgminer','--version'])
        make=['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc]
        flags=['LC_DIR=build/check']+(['SANITIZE=1'] if a.sanitize else [])
        text=run('lifecycle',make+flags+['io-lifecycle-test'])
        report.update(scenarios=29,assertions=require_pass(text),native_calls=46,
            markers=[s for s in text.splitlines() if s.startswith('R05_')])
        symbols=run('symbols',['nm','--defined-only','build/check/test'])
        names={s.split()[-1] for s in symbols.splitlines() if s.split()}
        required={'copy_work_noffset','_free_work','test_nonce','fulltest','submit_nonce',
            'dizzass_io_stop','dizzass_io_send_work','dizzass_io_send_command',
            'dizzass_native_job_channel_send','dizzass_rx_owner_join','dizzass_submitter_stop',
            '__wrap_socket','__wrap_connect','__wrap_libusb_init','__wrap_dizzass_jobs_finish'}
        if not required<=names or 'r01_unused_cgminer_main' in names:raise RuntimeError('symbol boundary mismatch')
        report['symbols']=sorted(required)
        old=['make','-f','Makefile','-f','integration/review/rx_owner/suite.mk','CC='+a.cc,'RO_DIR=build/r04-regression']+(['SANITIZE=1'] if a.sanitize else [])
        oldtext=run('r04-regression',old+['rx-owner-test'])
        if not re.search(r'R04_PASS cases=38 checks=\d+ native_calls=51 ',oldtext):raise RuntimeError('R04 regression incomplete')
        if not a.sanitize:
            run('native-regressions',['make','-f','Makefile','-f','integration/native-submit.mk','-f','integration/review/rx_owner/regressions.mk','CC='+a.cc,'RO_ANTS2='+str(int(a.baseline=='ants2')),'dizzass-native-submit-test'])
            run('boundary',['python3','integration/test_native_core.py'])
            run('strict',[a.cc,'-Ibuild/r04-deps','-I.','-Iinclude','-std=c11','-pthread','-Wall','-Wextra','-Wpedantic','-Werror','-fsyntax-only','integration/native/io_lifecycle.c'])
            if a.cc.startswith('clang'):run('analyzer',[a.cc,'--analyze','-Ibuild/r04-deps','-I.','-Iinclude','-std=c11','-pthread','-Xanalyzer','-analyzer-output=text','integration/native/io_lifecycle.c'])
        if a.mutants:
            controls=[
                ('ignore-whole-tx','r.tx_wait_status = wait_tx(l, deadline);','r.tx_wait_status = 0;','dizzass_io_stop(l,r01_now()+20,&r)==ETIMEDOUT'),
                ('omit-job-pause','r.pause_status = dizzass_jobs_pause(l->config.jobs, l->config.received_epoch);','r.pause_status = 0;','DIZZASS_JOBS_PAUSED'),
                ('omit-submit-stop','r.submit_stop_status = dizzass_submitter_stop(l->config.submitter);','r.submit_stop_status = 0;','DIZZASS_SUBMIT_STOPPED'),
                ('omit-notify','r.notify_status = dizzass_rx_owner_notify(l->rx);','r.notify_status = 0;','r.rx.wake_reads>=1'),
                ('admit-after-request','if (l->state.stop_requested) e = ECANCELED;\n    else if (!l->state.started)', 'if (false) e = ECANCELED;\n    else if (!l->state.started)','==ECANCELED'),
                ('omit-outer-cancel','int saved, e = begin(l, &saved);','int saved, e = begin(l, &saved); if (!e) (void)pthread_setcancelstate(saved, NULL);','old==PTHREAD_CANCEL_DISABLE')]
            p=src/'integration/native/io_lifecycle.c';original=p.read_text()
            for name,old,new,witness in controls:
                if original.count(old)<1:raise ValueError('missing mutant anchor '+name)
                try:
                    p.write_text(original.replace(old,new));directory='build/m-'+name
                    run(name+'-build',make+['LC_DIR='+directory,directory+'/test'])
                    text=run(name,['timeout','60',directory+'/test'],allowed=(1,),timeout=70)
                    if 'R04_ASSERT' not in text or witness not in text:raise RuntimeError('wrong semantic rejection '+name)
                    report['mutants'].append(name)
                finally:p.write_text(original)
        for name,sha in hashes.items():
            if base.digest((src/name).read_bytes())!=sha:raise RuntimeError('changed source '+name)
        for e,b in material:base.verify((deps/e['path']).read_bytes(),e)
        report['status']='PASS';print('R05_REVIEW_PASS',flush=True);return 0
    except (OSError,ValueError,RuntimeError,KeyError,subprocess.SubprocessError) as e:
        report['error']=str(e);print('R05_ERROR: '+str(e),file=sys.stderr);return 1
    finally:
        if out is not None:(out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

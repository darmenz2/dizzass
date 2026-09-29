#!/usr/bin/env python3
"""R-03: build the committed candidate, using verified pinned dependencies."""
from __future__ import annotations
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/rx_submit')
spec=importlib.util.spec_from_file_location('r02_build',ROOT/'integration/review/early_rx/run.py')
r02=importlib.util.module_from_spec(spec)
spec.loader.exec_module(r02)

def dependency(entry:dict, source:Path|None)->bytes:
    r02.safe_name(entry['path'])
    sha=entry['commit']
    if len(sha)!=40 or any(c not in '0123456789abcdef' for c in sha):
        raise ValueError('invalid dependency SHA')
    if source is None:
        data=r02.git('show',sha+':'+entry['path'])
    else:
        root=source.absolute()
        path=root/entry['path']
        for p in (path,*path.parents):
            if p.is_symlink(): raise ValueError('symlink dependency')
            if p==root: break
        data=path.read_bytes()
    r02.verify(data,entry)
    return data

def main()->int:
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',choices=['gcc','gcc-14','clang','clang-17'],default='gcc')
    ap.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    ap.add_argument('--out',required=True)
    ap.add_argument('--deps-from',type=Path,help='hash-verified offline dependency tree, not Git history')
    ap.add_argument('--sanitize',action='store_true')
    ap.add_argument('--mutants',action='store_true')
    a=ap.parse_args()
    if a.sanitize and a.mutants: ap.error('run semantic controls separately')
    result={'status':'FAIL','commands':[],'mutants':[],'compiler':a.cc,
        'baseline':a.baseline,'sanitized_direct_units':a.sanitize,
        'support_objects_sanitized':False,'network':False,'physical_asic':False,
        'dependency_mode':'offline verified blobs' if a.deps_from else 'Git objects'}
    out=None
    try:
        head=r02.git('rev-parse','HEAD').decode().strip()
        entries=json.loads((ROOT/'integration/review/early_rx/manifest.json').read_text())['pending']
        material=[(e,dependency(e,a.deps_from)) for e in entries]
        names=['integration/native_jobs.c','integration/native_submit.h',
            'integration/native/early_rx.c','integration/native/early_rx.h',
            str(REL/'test.c'),str(REL/'suite.mk'),str(REL/'run.py')]
        hashes={}
        for name in names:
            data=r02.git('show',head+':'+name)
            if data!=(ROOT/name).read_bytes(): raise ValueError('uncommitted input '+name)
            hashes[name]=r02.digest(data)
        out=r02.output(a.out); native=out/'source'; logs=out/'logs'; logs.mkdir()
        r02.extract(r02.git('archive','--format=tar',head),native)
        result.update(source_head=head,source_tree=r02.git('rev-parse',head+'^{tree}').decode().strip(),source_hashes=hashes,dependencies=entries)
        deps=native/'build/r02-deps'
        for e,data in material:
            p=deps/e['path']; p.parent.mkdir(parents=True,exist_ok=True); p.write_bytes(data)
        def run(stage,argv,allowed=(0,),timeout=240):
            record={'stage':stage,'argv':argv,'returncode':None}
            result['commands'].append(record)
            log=logs/(stage+'.log'); start=time.monotonic()
            with log.open('xb') as f:
                p=subprocess.run(argv,cwd=native,stdout=f,stderr=subprocess.STDOUT,timeout=timeout,
                    env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1','PYTHONDONTWRITEBYTECODE':'1'})
            record.update(returncode=p.returncode,seconds=round(time.monotonic()-start,3),log=str(log.relative_to(out)),sha256=r02.digest(log.read_bytes()))
            print(stage+': '+str(p.returncode),flush=True)
            if p.returncode not in allowed:
                if stage=='sanitizer-health': result['status']='BLOCKED_SANITIZER_HEALTH'
                raise RuntimeError(stage+' failed: '+str(log))
            return log.read_text(errors='replace')
        result['compiler_version']=run('compiler',[a.cc,'--version']).splitlines()[0]
        if a.sanitize:
            run('health-build',[a.cc,'-std=c11','-O1','-g','-pthread','-fsanitize=address,undefined',
                '-fno-omit-frame-pointer','-fno-pie','-no-pie',
                'build/r02-deps/integration/review/native_uart_stack/evidence/cancel_probe.c','-o','health'])
            run('sanitizer-health',['timeout','15','./health'])
        run('autoreconf',['autoreconf','-fi'])
        configure=['./configure','--enable-'+a.baseline,'--disable-curses','CC='+a.cc,'CFLAGS=-O2 -fcommon']
        if a.baseline=='ants2': configure.append('--disable-libcurl')
        run('configure',configure); run('native-core-build',['make','-j2']); run('version',['./cgminer','--version'])
        make=['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc]
        flags=['R03_DIR=build/test-r03']+(['SANITIZE=1'] if a.sanitize else [])
        text=run('integration',make+flags+['rx-submit-test'])
        required_markers=['R03_PASS cases=39 ','R03_EARLY fragment=11 ',
            'R03_REJECT mode=3 no_native_call=1','R03_COPY_RETRY field=3 ',
            'R03_CORE mode=6 ','R03_CANCEL owner_exclusion_submit_consume_receipt=1',
            'R03_SLOTS actual_a16_sends=32 captured_dispatches=32 ']
        if any(x not in text for x in required_markers): raise RuntimeError('missing complete application markers')
        result['markers']=[x for x in text.splitlines() if x.startswith('R03_')]
        symbols=run('symbols',['nm','--defined-only','build/test-r03/test'])
        found={x.split()[-1] for x in symbols.splitlines() if x.split()}
        required={'submit_nonce','copy_work_noffset','_free_work','test_nonce','fulltest','tq_push',
            'dizzass_submitter_run_captured','dizzass_early_rx_dispatch','dizzass_native_job_channel_send',
            '__wrap_socket','__wrap_connect','__wrap_libusb_init','__wrap_strdup','__wrap_submit_nonce'}
        if not required<=found: raise RuntimeError('missing real native helpers/guards '+str(required-found))
        result['symbols']=sorted(required)
        if not a.sanitize:
            run('r02-regression',['make','-f','Makefile','-f','integration/review/early_rx/suite.mk','CC='+a.cc,'RXQ_DIR=build/r02-regression','early-rx-test'])
            old=['make','-f','Makefile','-f','integration/native-submit.mk','CC='+a.cc]
            if a.baseline=='ants2': old.append('DIZZASS_JOBS_FLAGS=$(DIZZASS_NONCE_FLAGS) -fno-builtin-strdup -include integration/review/early_rx/host_compat.h')
            run('old-native-submit',old+['dizzass-native-submit-test'])
            run('source-boundaries',['python3','integration/test_native_core.py'])
            if a.cc.startswith('clang'): run('analyzer',make+['rx-submit-analyze'])
        if a.mutants:
            controls=[
                ('ignore-serial','integration/native_jobs.c','static int admit_submission(',
                 'rc = ticket_status(jobs, captured);','rc = 0;','s.job_status==expected && !s.native_called'),
                ('ordinary-submit','integration/native/early_rx.c','int dizzass_early_rx_dispatch(',
                 'dizzass_submitter_run_captured(submitter, q->jobs,\n            &event.captured, &event.reply, &event.result)',
                 'dizzass_submitter_run(submitter, q->jobs,\n            event.captured.epoch, &event.reply, &event.result)','s.job_status==expected && !s.native_called'),
                ('consume-pending','integration/native/early_rx.c','int dizzass_early_rx_dispatch(',
                 'if (rc == DIZZASS_JOBS_PENDING) continue;','if (rc == DIZZASS_JOBS_PENDING) { remove_entry(q, i); return DIZZASS_EARLY_RX_EMPTY; }','dizzass_early_rx_dispatch(e.q,e.submitter,&s)==DIZZASS_EARLY_RX_WAITING'),
                ('consume-copy-error','integration/native/early_rx.c','int dizzass_early_rx_dispatch(',
                 'if (rc && !terminal_rejection(rc)) return rc;','if (rc && !terminal_rejection(rc)) { remove_entry(q, i); return rc; }','dizzass_early_rx_size(e.q)==1 && memcmp(&s,&unchanged,sizeof s)==0'),
                ('never-consume-success','integration/native/early_rx.c','int dizzass_early_rx_dispatch(',
                 'remove_entry(q, i);','/* mutation: replay completed entry */','dizzass_early_rx_size(e.q)==0'),
                ('ignore-stopped-gate','integration/native_jobs.c','static int submitter_run(',
                 'if (gate->stopped) { rc = DIZZASS_SUBMIT_STOPPED; goto done; }','/* mutation: bypass gate stop */','dizzass_early_rx_dispatch(e.q,e.submitter,&s)==expected')]
            for label,name,boundary,old,new,witness in controls:
                p=native/name; original=p.read_text(); start=original.index(boundary)
                tail=original[start:]
                if tail.count(old)!=1: raise ValueError('changed mutation anchor '+label)
                try:
                    p.write_text(original[:start]+tail.replace(old,new,1)); directory='build/m-'+label
                    run(label+'-build',make+['R03_DIR='+directory,directory+'/test'])
                    text=run(label,['timeout','45',directory+'/test'],allowed=(1,))
                    if 'R03_ASSERT' not in text or witness not in text: raise RuntimeError('wrong semantic rejection '+label)
                    result['mutants'].append(label)
                finally: p.write_text(original)
        for name,sha in hashes.items():
            if r02.digest((native/name).read_bytes())!=sha: raise RuntimeError('source changed '+name)
        for e,_ in material: r02.verify((deps/e['path']).read_bytes(),e)
        result['status']='PASS'; print('R03_REVIEW_PASS',flush=True); return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        result['error']=str(e); print('R03_ERROR: '+str(e),file=sys.stderr); return 1
    finally:
        if out is not None: (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__': raise SystemExit(main())

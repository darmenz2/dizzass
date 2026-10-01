#!/usr/bin/env python3
"""R17: real paced scanwork callbacks; preserve the complete R16 stack."""
from __future__ import annotations
import argparse, importlib.util, json, os, shlex, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/scan_wait')
spec=importlib.util.spec_from_file_location('native_io_stop',ROOT/'integration/review/native_io_stop/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
combined=previous.combined
configure_previous=previous.configure_groups
CONTROLS=[('omit-stop-latch', 'int dizzass_scan_stop_wake(', 's->report.stop_requested = true;', '/* Mutant omits the sticky request. */', 'r.reason==DIZZASS_SCAN_STOP && r.stops==1 && !r.wait_calls && !r.ticks'), ('omit-stop-broadcast', 'int dizzass_scan_stop_wake(', 'rc = pthread_cond_broadcast(&s->cond);', 'rc = 0;', 'atomic_load(&broadcasts17)>old'), ('moving-deadline', 'int64_t dizzass_scanwork(', 'rc = pthread_cond_timedwait(&s->cond, &s->lock, &deadline);', '++deadline.tv_nsec; rc = pthread_cond_timedwait(&s->cond, &s->lock, &deadline);', 'd->tv_sec==first_deadline17.tv_sec && d->tv_nsec==first_deadline17.tv_nsec'), ('ignore-io-exit', 'static int io_active(', 'if (r.stop_requested || r.quiescent || r.rx_finished) return ECANCELED;', 'if (r.stop_requested || r.quiescent || r.rx_finished) return 0;', 'w.result==-1 && r.reason==DIZZASS_SCAN_IO_FAILURE && r.failures==1'), ('fake-hashes', 'int64_t dizzass_scanwork(', 'return rc || restored ? -1 : 0;', 'return rc || restored ? -1 : 1;', 'hashes==0 && r.reason==DIZZASS_SCAN_TICK && r.ticks==1'), ('omit-cancel-exclusion', 'int64_t dizzass_scanwork(', 'int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);', 'int saved = PTHREAD_CANCEL_ENABLE, rc = 0;', 'saved==PTHREAD_CANCEL_DISABLE'), ('retain-active', 'int64_t dizzass_scanwork(', 's->report.active = false;', 's->report.active = true;', 'r.wait_calls>=1 && elapsed+2>=ms && !r.active && !r.waiting && !r.failures'), ('wrong-clock', 'int dizzass_scan_wait_init(', 'pthread_condattr_setclock(&attr, CLOCK_MONOTONIC)', 'pthread_condattr_setclock(&attr, CLOCK_REALTIME)', 'r.wait_calls>=1 && elapsed+2>=ms && !r.active && !r.waiting && !r.failures')]


def configure_groups():
    configure_previous();old=combined.controls
    combined.GROUPS += [('scan_wait','S17','scan-wait-test',20,'R17_PASS cases=20 ')]
    combined.controls=lambda name: [] if name=='scan_wait' else old(name)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',choices=['gcc','clang','gcc-14','clang-17'],default='gcc')
    ap.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    ap.add_argument('--out',required=True);ap.add_argument('--groups',default='all')
    ap.add_argument('--sanitize',action='store_true');ap.add_argument('--mutants',action='store_true');a=ap.parse_args()
    if a.sanitize and a.mutants:ap.error('separate mutation and sanitizer runs')
    previous.configure_groups=configure_groups
    rc=previous.main()
    if rc:return rc
    out=ROOT/a.out;src=out/'source';rp=out/'results.json';report=json.loads(rp.read_text())
    if 'scan_wait' not in report['suites']:return 0
    report['status']='R17_CONTROLS_PENDING';rp.write_text(json.dumps(report,indent=2)+'\n')
    inp=out/'compiler-inputs.json';inputs=json.loads(inp.read_text());records=out/'compile-records';logs=out/'logs'
    def run(label,argv,allowed=(0,)):
        log=logs/(label+'.log');e={'stage':label,'argv':argv,'returncode':None};report['commands'].append(e);start=time.monotonic()
        try:
            with log.open('xb') as f:
                p=subprocess.run(argv,cwd=src,stdout=f,stderr=subprocess.STDOUT,timeout=150,
                    env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1','PYTHONDONTWRITEBYTECODE':'1'})
            e['returncode']=p.returncode
        finally:e.update(log=str(log.relative_to(out)),sha256=combined.sha(log.read_bytes()),seconds=round(time.monotonic()-start,3))
        if p.returncode not in allowed:raise RuntimeError(label+' failed: '+str(log))
        print(label+': '+str(p.returncode),flush=True);return log.read_text(errors='replace')
    try:
        report['suites']['scan_wait']['markers']=[s for s in (logs/'scan_wait.log').read_text().splitlines() if s.startswith('R17_')]
        sym=run('r17-symbols',['nm','--defined-only','build/combined-scan_wait/test'])
        names={s.split()[-1] for s in sym.splitlines() if s.split()}
        required={'dizzass_scanwork','dizzass_scan_stop_wake','dizzass_scan_wait_init','dizzass_scan_wait_snapshot','dizzass_scan_wait_destroy','dizzass_native_io_stop','cgminer_request_queued_stop','hash_queued_work','fill_queue'}
        if not required<=names:raise RuntimeError('missing native helpers: '+str(required-names))
        report['native_stop_symbols']=sorted(required)
        run('r17-strict',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc,'scan-wait-strict'])
        if a.mutants:
            key='integration/native/scan_wait.c';runtime=src/key;original=runtime.read_bytes()
            for name,section,old,new,witness in CONTROLS:
                text=original.decode();cut=text.index(section);prefix,body=text[:cut],text[cut:]
                if body.count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r17-'+name;directory='build/'+label
                try:
                    runtime.write_text(prefix+body.replace(old,new,1));inputs[key]=combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'S17_DEPS=.','S17_DIR='+directory,directory+'/test'])
                    result=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R17_ASSERT' not in result or witness not in result:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:runtime.write_bytes(original);inputs[key]=combined.sha(original);inp.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0:raise RuntimeError('failed audited compilation: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts;report['status']='PASS'
        print('R17_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R17_ERROR: '+str(e),file=sys.stderr);return 1
    finally:rp.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

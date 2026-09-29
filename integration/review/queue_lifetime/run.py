#!/usr/bin/env python3
"""R-10: extend the published R-09 runner, retaining native queue ownership."""
from __future__ import annotations
import argparse, importlib.util, json, os, shlex, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/queue_lifetime')
spec=importlib.util.spec_from_file_location('queued_work',ROOT/'integration/review/queued_work/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
combined=previous.combined
configure_previous=previous.configure_groups
CONTROLS=[
 ('omit-queue-count','io_lifecycle.c','else ++l->state.active_queue;','else e = 0;','s.active_queue==1'),
 ('ignore-queue-wait','io_lifecycle.c','while (l->state.active_tx || l->state.active_queue) {','while (l->state.active_tx) {','dizzass_io_stop(q.io,r01_now()+20,&report)==ETIMEDOUT'),
 ('omit-queue-release','io_lifecycle.c','--l->state.active_queue;','(void)l->state.active_queue;','s.active_queue==0 && s.active_tx==0'),
 ('lose-queue-report','io_lifecycle.c','r.active_queue = l->state.active_queue;','r.active_queue = 0;','report.active_queue==1 && !report.quiescent && !report.jobs_paused'),
 ('ignore-admission-stop','io_lifecycle.c','    int e = 0;\n    lock(l);\n    if (l->state.stop_requested) e = ECANCELED;','    int e = 0;\n    lock(l);\n    if (false) e = ECANCELED;','send_q(&q,3,&r)==(injected?EOVERFLOW:ECANCELED)'),
 ('release-before-output','queued_work_tx.c','    *out = r;\n    dizzass_io_queue_leave(io);','    dizzass_io_queue_leave(io);\n    *out = r;','visible_receipt && visible_receipt->dequeued==expect_taken && visible_receipt->completed==expect_taken')]

def configure_groups():
    configure_previous();old=combined.controls
    combined.GROUPS += [('queue_lifetime','NQL','queue-lifetime-test',16,'R10_PASS cases=16 ')]
    combined.controls=lambda name: [] if name=='queue_lifetime' else old(name)

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
    out=ROOT/a.out;src=out/'source';report_path=out/'results.json';report=json.loads(report_path.read_text())
    if 'queue_lifetime' not in report['suites']:return 0
    report['status']='R10_CONTROLS_PENDING';report_path.write_text(json.dumps(report,indent=2)+'\n')
    inp=out/'compiler-inputs.json';inputs=json.loads(inp.read_text());records=out/'compile-records';logs=out/'logs'
    def run(label,argv,allowed=(0,)):
        log=logs/(label+'.log');entry={'stage':label,'argv':argv,'returncode':None};report['commands'].append(entry)
        start=time.monotonic()
        try:
            with log.open('xb') as f:
                done=subprocess.run(argv,cwd=src,stdout=f,stderr=subprocess.STDOUT,timeout=100,
                    env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1','PYTHONDONTWRITEBYTECODE':'1'})
            entry['returncode']=done.returncode
        finally:entry.update(log=str(log.relative_to(out)),sha256=combined.sha(log.read_bytes()),seconds=round(time.monotonic()-start,3))
        if done.returncode not in allowed:raise RuntimeError(label+' failed: '+str(log))
        print(label+': '+str(done.returncode),flush=True);return log.read_text(errors='replace')
    try:
        run('r10-strict',[a.cc,'-I.','-Iinclude','-std=c11','-pthread','-Wall','-Wextra','-Wpedantic','-Werror','-fsyntax-only','integration/native/io_lifecycle.c'])
        run('r10-queue-strict',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc,'queue-lifetime-strict'])
        symbols=run('r10-symbols',['nm','--defined-only','build/combined-queue_lifetime/test'])
        names={s.split()[-1] for s in symbols.splitlines() if s.split()}
        required={'dizzass_queued_work_send','dizzass_io_queue_enter','dizzass_io_queue_leave','get_queued','work_completed','submit_nonce'}
        if not required<=names:raise RuntimeError('missing actual scope/native helpers: '+str(required-names))
        report['queue_lifetime_symbols']=sorted(required)
        if a.mutants:
            for name,file,old,new,witness in CONTROLS:
                key='integration/native/'+file;runtime=src/key;original=runtime.read_bytes()
                if original.decode().count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r10-'+name;directory='build/'+label
                try:
                    runtime.write_text(original.decode().replace(old,new,1));inputs[key]=combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'NQL_DEPS=.','NQL_DIR='+directory,directory+'/test'])
                    text=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R10_ASSERT' not in text or witness not in text:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:
                    runtime.write_bytes(original);inputs[key]=combined.sha(original);inp.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0:raise RuntimeError('failed audited compilation: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts;report['status']='PASS'
        print('R10_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R10_ERROR: '+str(e),file=sys.stderr);return 1
    finally:report_path.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

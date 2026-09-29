#!/usr/bin/env python3
"""R-11: native registry backpressure; preserve the complete R-10 regression set."""
from __future__ import annotations
import argparse, importlib.util, json, os, shlex, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/queue_capacity')
spec=importlib.util.spec_from_file_location('queue_lifetime',ROOT/'integration/review/queue_lifetime/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
combined=previous.combined
configure_previous=previous.configure_groups
CONTROLS=[
 ('occupied-is-free','integration/native_jobs.c','int dizzass_jobs_capacity(',
  'if (jobs->slots[i].state == SLOT_EMPTY)','if (true)',
  'mask.unused_mask==(UINT32_MAX & ~UINT32_C(7))'),
 ('quarantine-is-free','integration/native_jobs.c','int dizzass_jobs_capacity(',
  'if (jobs->slots[i].state == SLOT_EMPTY)','if (jobs->slots[i].state == SLOT_EMPTY || jobs->slots[i].state == SLOT_QUARANTINE)',
  'mask.unused_mask==(UINT32_MAX & ~UINT32_C(7))'),
 ('ignore-paused-registry','integration/native_jobs.c','int dizzass_jobs_capacity(',
  'if (!rc && jobs->paused) rc = DIZZASS_JOBS_PAUSED;','/* omitted paused check */',
  'dizzass_queued_work_step(thr,io,deadline,budget,out)==expected'),
 ('dequeue-without-capacity','integration/native/queue_step.c','int dizzass_queued_work_step(',
  'if (!r.before.unused_mask) { rc = ENOSPC; goto done; }','if (false) { rc = ENOSPC; goto done; }',
  'b11_step(&q,&r)==ENOSPC'),
 ('always-use-slot-zero','integration/native/queue_step.c','int dizzass_queued_work_step(',
  'struct dizzass_queued_tx_plan plan =','r.slot = 0; struct dizzass_queued_tx_plan plan =',
  'b11_step(&q,&r)==0 && r.slot==3'),
 ('continue-on-empty','integration/native/queue_step.c','int dizzass_queued_work_step(',
  'r = {.queue_full = true};','r = {.queue_full = false};',
  'r.queue_full && !r.after_checked && !r.queued.dequeued && !r.queued.completed'),
 ('ignore-last-slot','integration/native/queue_step.c','int dizzass_queued_work_step(',
  'r.queue_full = r.after_status != 0 || r.after.unused_mask == 0;','r.queue_full = r.after_status != 0;',
  'r.slot==i && r.queue_full==(i==31)'),
 ('omit-outer-cancellation','integration/native/queue_step.c','int dizzass_queued_work_step(',
  'int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);','int saved = PTHREAD_CANCEL_ENABLE, rc = 0;',
  'saved==PTHREAD_CANCEL_DISABLE'),
 ('wrong-bound-epoch','integration/native/io_lifecycle.c','int dizzass_io_capacity(',
  'l->config.received_epoch, out);','l->config.received_epoch + 1, out);',
  '__real_dizzass_io_capacity(q.io,&c)==0 && c.unused_mask==UINT32_MAX')]

def configure_groups():
    configure_previous();old=combined.controls
    combined.GROUPS += [('queue_capacity','QC11','queue-capacity-test',41,'R11_PASS cases=41 ')]
    combined.controls=lambda name: [] if name=='queue_capacity' else old(name)

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
    if 'queue_capacity' not in report['suites']:return 0
    report['status']='R11_CONTROLS_PENDING';report_path.write_text(json.dumps(report,indent=2)+'\n')
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
        report['suites']['queue_capacity']['markers']=[x for x in (logs/'queue_capacity.log').read_text().splitlines() if x.startswith('R11_')]
        run('r11-strict',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc,'queue-capacity-strict'])
        symbols=run('r11-symbols',['nm','--defined-only','build/combined-queue_capacity/test'])
        names={s.split()[-1] for s in symbols.splitlines() if s.split()}
        required={'dizzass_jobs_capacity','dizzass_io_capacity','dizzass_queued_work_step','dizzass_queued_work_send','get_queued','work_completed','submit_nonce'}
        if not required<=names:raise RuntimeError('missing capacity/native helpers: '+str(required-names))
        report['queue_capacity_symbols']=sorted(required)
        if a.mutants:
            for name,key,section,old,new,witness in CONTROLS:
                runtime=src/key;original=runtime.read_bytes();text=original.decode();cut=text.index(section);prefix,body=text[:cut],text[cut:]
                if body.count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r11-'+name;directory='build/'+label
                try:
                    runtime.write_text(prefix+body.replace(old,new,1));inputs[key]=combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'QC11_DEPS=.','QC11_DIR='+directory,directory+'/test'])
                    text=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R11_ASSERT' not in text or witness not in text:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:
                    runtime.write_bytes(original);inputs[key]=combined.sha(original);inp.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0:raise RuntimeError('failed audited compilation: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts;report['status']='PASS'
        print('R11_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R11_ERROR: '+str(e),file=sys.stderr);return 1
    finally:report_path.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

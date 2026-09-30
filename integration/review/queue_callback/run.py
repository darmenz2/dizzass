#!/usr/bin/env python3
"""R-12: native queue_full/fill_queue/get_work; preserve R-11 suites."""
from __future__ import annotations
import argparse, importlib.util, json, os, shlex, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/queue_callback')
spec=importlib.util.spec_from_file_location('queue_capacity',ROOT/'integration/review/queue_capacity/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
combined=previous.combined
configure_previous=previous.configure_groups
CONTROLS=[
 ('ignore-error-full','integration/native/queue_callback.c','bool dizzass_queue_full(',
  'if (r.receipt_valid) r.queue_full = r.step.queue_full;',
  'r.queue_full = r.receipt_valid ? r.step.queue_full : false;',
  'dizzass_queue_full(&v.q.e.cgpu)'),
 ('always-full','integration/native/queue_callback.c','bool dizzass_queue_full(',
  'if (r.receipt_valid) r.queue_full = r.step.queue_full;',
  'if (r.receipt_valid) r.queue_full = true;',
  '!dizzass_queue_full(&v.q.e.cgpu)'),
 ('wrap-deadline','integration/native/queue_callback.c','bool dizzass_queue_full(',
  'if (!r.status && b->timeout_ms > UINT64_MAX - now) r.status = EOVERFLOW;',
  '/* mutation: allow unsigned deadline wrap */',
  'v.b.last.status==EOVERFLOW && !v.b.last.step_called && !v.b.last.receipt_valid'),
 ('ignore-bound-device','integration/native/queue_callback.c','bool dizzass_queue_full(',
  'b->thr->cgpu != cgpu || ', '',
  'v.b.last.status==EINVAL && !v.b.last.step_called && !v.b.last.receipt_valid'),
 ('reuse-stale-receipt','integration/native/queue_callback.c','bool dizzass_queue_full(',
  '    b->last = r;\n    int restore',
  '    if (r.status) r.step = b->last.step;\n    b->last = r;\n    int restore',
  'v.b.last.status==EIO && !v.b.last.receipt_valid && !v.b.last.step.queued.dequeued'),
 ('omit-callback-cancel','integration/native/queue_callback.c','bool dizzass_queue_full(',
  'r.status = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);',
  'saved = PTHREAD_CANCEL_ENABLE; r.status = 0;',
  'saved==PTHREAD_CANCEL_DISABLE')]


def configure_groups():
    configure_previous();old=combined.controls
    combined.GROUPS += [('queue_callback','Q12','queue-callback-test',27,'R12_PASS cases=27 ')]
    combined.controls=lambda name: [] if name=='queue_callback' else old(name)

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
    if 'queue_callback' not in report['suites']:return 0
    report['status']='R12_CONTROLS_PENDING';report_path.write_text(json.dumps(report,indent=2)+'\n')
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
        report['suites']['queue_callback']['markers']=[x for x in (logs/'queue_callback.log').read_text().splitlines() if x.startswith('R12_')]
        run('r12-strict',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc,'queue-callback-strict'])
        symbols=run('r12-symbols',['nm','--defined-only','build/combined-queue_callback/test'])
        names={s.split()[-1] for s in symbols.splitlines() if s.split()}
        required={'dizzass_queue_callback_init','dizzass_queue_full','fill_queue','get_work','hash_pop','dizzass_queued_work_step','get_queued','work_completed','submit_nonce'}
        if not required<=names:raise RuntimeError('missing capacity/native helpers: '+str(required-names))
        report['queue_callback_symbols']=sorted(required)
        undefined=run('r12-undefined',['nm','--undefined-only','build/combined-queue_callback/test'])
        if any(line.split()[-1] in {'fill_queue','hash_pop'} for line in undefined.splitlines() if line.split()):
            raise RuntimeError('unresolved static core symbol')
        if a.mutants:
            for name,key,section,old,new,witness in CONTROLS:
                runtime=src/key;original=runtime.read_bytes();text=original.decode();cut=text.index(section);prefix,body=text[:cut],text[cut:]
                if body.count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r12-'+name;directory='build/'+label
                try:
                    runtime.write_text(prefix+body.replace(old,new,1));inputs[key]=combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'Q12_DEPS=.','Q12_DIR='+directory,directory+'/test'])
                    text=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R12_ASSERT' not in text or witness not in text:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:
                    runtime.write_bytes(original);inputs[key]=combined.sha(original);inp.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0:raise RuntimeError('failed audited compilation: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts;report['status']='PASS'
        print('R12_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R12_ERROR: '+str(e),file=sys.stderr);return 1
    finally:report_path.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

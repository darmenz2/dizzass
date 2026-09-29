#!/usr/bin/env python3
"""R-09: native queued-work ownership; extend, do not duplicate the R-08 suite."""
from __future__ import annotations
import argparse, importlib.util, json, os, shlex, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/queued_work')
spec=importlib.util.spec_from_file_location('rx_integrity',ROOT/'integration/review/rx_integrity/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
combined=previous.previous.combined
configure_previous=previous.configure_groups
CONTROLS=[
 ('omit-core-completion','work_completed(thr->cgpu, work);','/* mutation: leak native queued work */','atomic_load(&complete_calls)==1 && !atomic_load(&managed_calls)'),
 ('ignore-thread','if (work->thr_id != thr->id)','if (false)','r.dequeued && r.completed && r.work_id==id && !r.send_called'),
 ('omit-cancel-guard','int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);','int saved = PTHREAD_CANCEL_ENABLE, rc = 0;','saved==PTHREAD_CANCEL_DISABLE'),
 ('ignore-expired-deadline','if (now >= p->deadline_ms)','if (false)','dizzass_queued_work_send(t,io,arg,out)==expected'),
 ('consume-before-start','if (!state.started)','if (false)','dizzass_queued_work_send(t,io,arg,out)==expected'),
 ('lose-completion-receipt','r.completed = true;','r.completed = false;','r.dequeued && r.completed && r.work_id==id && !r.send_called'),
 ('bypass-core-get','struct work *work = get_queued(thr->cgpu);','struct work *work = thr->cgpu->unqueued_work;','atomic_load(&get_calls)==1 && !atomic_load(&complete_calls) && !atomic_load(&managed_calls)')]

def configure_groups():
    configure_previous();old=combined.controls
    combined.GROUPS += [('queued_work','Q09','queued-work-test',49,'R09_PASS cases=49 ')]
    combined.controls=lambda name: [] if name=='queued_work' else old(name)

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
    if 'queued_work' not in report['suites']:return 0
    report['status']='R09_CONTROLS_PENDING';report_path.write_text(json.dumps(report,indent=2)+'\n')
    inp=out/'compiler-inputs.json';inputs=json.loads(inp.read_text());records=out/'compile-records';logs=out/'logs'
    key='integration/native/queued_work_tx.c';runtime=src/key;original=runtime.read_bytes()
    def run(label,argv,allowed=(0,)):
        log=logs/(label+'.log');entry={'stage':label,'argv':argv,'returncode':None};report['commands'].append(entry)
        start=time.monotonic()
        try:
            with log.open('xb') as f:
                done=subprocess.run(argv,cwd=src,stdout=f,stderr=subprocess.STDOUT,timeout=90,
                    env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1','PYTHONDONTWRITEBYTECODE':'1'})
            entry['returncode']=done.returncode
        finally:entry.update(log=str(log.relative_to(out)),sha256=combined.sha(log.read_bytes()),seconds=round(time.monotonic()-start,3))
        if done.returncode not in allowed:raise RuntimeError(label+' failed: '+str(log))
        print(label+': '+str(done.returncode),flush=True);return log.read_text(errors='replace')
    try:
        report['suites']['queued_work']['markers']=[s for s in (logs/'queued_work.log').read_text().splitlines() if s.startswith('R09_')]
        run('r09-strict',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc,'queued-work-strict'])
        symbols=run('r09-symbols',['nm','--defined-only','build/combined-queued_work/test'])
        names={s.split()[-1] for s in symbols.splitlines() if s.split()}
        required={'dizzass_queued_work_send','get_queued','__get_queued','work_completed','_discard_work','dizzass_io_send_work','submit_nonce','dizzass_io_create_crc5'}
        if not required<=names:raise RuntimeError('missing real native queue helpers: '+str(required-names))
        report['native_queue_symbols']=sorted(required)
        if a.mutants:
            for name,old,new,witness in CONTROLS:
                if original.decode().count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r09-'+name;directory='build/'+label
                try:
                    runtime.write_text(original.decode().replace(old,new,1));inputs[key]=combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'Q09_DEPS=.','Q09_DIR='+directory,directory+'/test'])
                    text=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R09_ASSERT' not in text or witness not in text:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:
                    runtime.write_bytes(original);inputs[key]=combined.sha(original);inp.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0:raise RuntimeError('failed audited compilation: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts
        if runtime.read_bytes()!=original:raise RuntimeError('runtime not restored')
        report['status']='PASS'
        print('R09_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R09_ERROR: '+str(e),file=sys.stderr);return 1
    finally:report_path.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

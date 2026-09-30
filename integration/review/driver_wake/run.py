#!/usr/bin/env python3
"""R14: cooperative driver/paused-thread wake, preserving the R13 test stack."""
from __future__ import annotations
import argparse, importlib.util, json, os, shlex, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/driver_wake')
spec=importlib.util.spec_from_file_location('queue_stop',ROOT/'integration/review/queue_stop/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
combined=previous.combined
configure_previous=previous.configure_groups
CONTROLS=[
 ('omit-sem-wake','int cgminer_request_queued_stop(', 'if (first_stop && cgpu->thr)', 'if (false && first_stop && cgpu->thr)', 'r01_now()<end'),
 ('repeat-sem-wake','int cgminer_request_queued_stop(', 'if (first_stop && cgpu->thr)', 'if (cgpu->thr)', 'sem_value14(&g->thr[0]->sem)==1 && atomic_load(&e.driver.woke)==9'),
 ('omit-driver-wake','int cgminer_request_queued_stop(', 'if (cgpu->drv && cgpu->drv->queued_stop_wake)', 'if (false && cgpu->drv && cgpu->drv->queued_stop_wake)', 'atomic_load(&e.driver.woke)==1'),
 ('hide-wake-error','int cgminer_request_queued_stop(', 'rc = wake_rc;', 'rc = 0; (void)wake_rc;', 'rc==(mode==3?EIO:0)'),
 ('skip-prepause-stop','static bool mt_disable_common(', '{\n\tif (stop_aware && cgminer_queued_stopped(mythr->cgpu))\n\t\treturn false;', '{\n\t/* skipped pre-pause stop */', '!w.resumed && !atomic_load(&sem_seen14[0])'),
 ('reenable-on-stop','static bool mt_disable_common(', '\tcgsem_wait(&mythr->sem);\n\tif (stop_aware && cgminer_queued_stopped(mythr->cgpu))\n\t\treturn false;', '\tcgsem_wait(&mythr->sem);', '!atomic_load(&e.driver.enabled)'),
 ('legacy-stop-aware','static void mt_disable(', '(void)mt_disable_common(mythr, thr_id, drv, false);', '(void)mt_disable_common(mythr, thr_id, drv, true);', 'w.resumed && atomic_load(&e.driver.enabled)==1 && atomic_load(&sem_seen14[0])==1'),
 ('update-after-stop','void hash_queued_work(', '\t\t/* A normal thread_enable callback may itself request queued stop. */\n\t\tif (cgminer_queued_stopped(cgpu))\n\t\t\tbreak;', '\t\t/* missing post-enable stop guard */', 'atomic_load(&e.driver.updated)==(stop_from_enable?0u:1u)'),
]


def configure_groups():
    configure_previous();old=combined.controls
    combined.GROUPS += [('driver_wake','D14','driver-wake-test',14,'R14_PASS cases=14 ')]
    combined.controls=lambda name: [] if name=='driver_wake' else old(name)

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
    if 'driver_wake' not in report['suites']:return 0
    report['status']='R14_CONTROLS_PENDING';rp.write_text(json.dumps(report,indent=2)+'\n')
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
        report['suites']['driver_wake']['markers']=[s for s in (logs/'driver_wake.log').read_text().splitlines() if s.startswith('R14_')]
        sym=run('r14-symbols',['nm','--defined-only','build/combined-driver_wake/test'])
        names={s.split()[-1] for s in sym.splitlines() if s.split()}
        required={'cgminer_request_queued_stop','cgminer_queued_stopped','hash_queued_work','fill_queue','get_work','hash_pop','dizzass_queue_full','mt_disable_common','miner_thread'}
        if not required<=names:raise RuntimeError('missing native helpers: '+str(required-names))
        report['native_stop_symbols']=sorted(required)
        if a.mutants:
            key='cgminer.c';runtime=src/key;original=runtime.read_bytes()
            for name,section,old,new,witness in CONTROLS:
                text=original.decode();cut=text.index(section);prefix,body=text[:cut],text[cut:]
                if body.count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r14-'+name;directory='build/'+label
                try:
                    runtime.write_text(prefix+body.replace(old,new,1));inputs[key]=combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'D14_DEPS=.','D14_DIR='+directory,directory+'/test'])
                    result=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R14_ASSERT' not in result or witness not in result:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:runtime.write_bytes(original);inputs[key]=combined.sha(original);inp.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0:raise RuntimeError('failed audited compilation: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts;report['status']='PASS'
        print('R14_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R14_ERROR: '+str(e),file=sys.stderr);return 1
    finally:rp.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

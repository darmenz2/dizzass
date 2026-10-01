#!/usr/bin/env python3
"""R16: native queued stop plus managed IO; retain the complete R15 stack."""
from __future__ import annotations
import argparse, importlib.util, json, os, shlex, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/native_io_stop')
spec=importlib.util.spec_from_file_location('null_driver',ROOT/'integration/review/null_driver/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
combined=previous.combined
configure_previous=previous.configure_groups
CONTROLS=[('omit-native-stop', 'int dizzass_native_io_stop(', 'r.native_status = cgminer_request_queued_stop(cgpu);', 'r.native_status = 0;', 'atomic_load(&wakes16)==1'), ('omit-io-fanout', 'int dizzass_native_io_stop(', 'int e = dizzass_io_request_stop(members[i]);', 'int e = 0;', 's.stop_requested'), ('skip-after-error', 'int dizzass_native_io_stop(', 'if (!e && r.io.entries[i].io.quiescent) ++r.io.quiescent;', 'if (!e && r.io.entries[i].io.quiescent) ++r.io.quiescent;\n        if (e) break;', 'r.native_called && !r.native_status && !r.sequence_complete && r.io.attempted==3'), ('change-deadline', 'int dizzass_native_io_stop(', 'dizzass_io_stop(members[i], deadline,', 'dizzass_io_stop(members[i], deadline + 1,', 'd==deadline16'), ('ignore-native-error', 'int dizzass_native_io_stop(', 'r.native_status = cgminer_request_queued_stop(cgpu);', 'r.native_status = cgminer_request_queued_stop(cgpu);\n    r.native_status = 0;', 'dizzass_native_io_stop(gpu16(&e),e.io,3,deadline16,&r)==ENETDOWN'), ('false-completion', 'int dizzass_native_io_stop(', 'r.sequence_complete = !r.first_error && r.io.all_quiescent;', 'r.sequence_complete = true;', 'r.native_called && r.native_status==ENETDOWN && r.first_error==ENETDOWN && !r.sequence_complete'), ('omit-outer-cancel', 'int dizzass_native_io_stop(', 'int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);', 'int saved = PTHREAD_CANCEL_ENABLE, rc = 0;', 'old==PTHREAD_CANCEL_DISABLE')]



def configure_groups():
    configure_previous();old=combined.controls
    combined.GROUPS += [('native_io_stop','S16','native-io-stop-test',29,'R16_PASS cases=29 ')]
    combined.controls=lambda name: [] if name=='native_io_stop' else old(name)

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
    if 'native_io_stop' not in report['suites']:return 0
    report['status']='R16_CONTROLS_PENDING';rp.write_text(json.dumps(report,indent=2)+'\n')
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
        report['suites']['native_io_stop']['markers']=[s for s in (logs/'native_io_stop.log').read_text().splitlines() if s.startswith('R16_')]
        sym=run('r16-symbols',['nm','--defined-only','build/combined-native_io_stop/test'])
        names={s.split()[-1] for s in sym.splitlines() if s.split()}
        required={'dizzass_native_io_stop','dizzass_io_request_stop','dizzass_io_stop','cgminer_request_queued_stop','cgminer_queued_stopped','hash_queued_work'}
        if not required<=names:raise RuntimeError('missing native helpers: '+str(required-names))
        report['native_stop_symbols']=sorted(required)
        run('r16-strict',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+a.cc,'native-io-stop-strict'])
        if a.mutants:
            key='integration/native/native_io_stop.c';runtime=src/key;original=runtime.read_bytes()
            for name,section,old,new,witness in CONTROLS:
                text=original.decode();cut=text.index(section);prefix,body=text[:cut],text[cut:]
                if body.count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r16-'+name;directory='build/'+label
                try:
                    runtime.write_text(prefix+body.replace(old,new,1));inputs[key]=combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'S16_DEPS=.','S16_DIR='+directory,directory+'/test'])
                    result=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R16_ASSERT' not in result or witness not in result:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:runtime.write_bytes(original);inputs[key]=combined.sha(original);inp.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0:raise RuntimeError('failed audited compilation: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts;report['status']='PASS'
        print('R16_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R16_ERROR: '+str(e),file=sys.stderr);return 1
    finally:rp.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

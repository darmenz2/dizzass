#!/usr/bin/env python3
"""R-07: extend the unchanged R-06 current-source runner, preserving all suites."""
from __future__ import annotations
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import time
ROOT = Path(__file__).resolve().parents[3]
REL = Path('integration/review/device_stop')
spec = importlib.util.spec_from_file_location('combined', ROOT/'integration/review/combined_rx/run.py')
combined = importlib.util.module_from_spec(spec)
spec.loader.exec_module(combined)
ORIGINAL_GROUPS = list(combined.GROUPS)
original_controls = combined.controls
CONTROLS = [
    ('omit-fanout', 'r.entries[i].request_status = dizzass_io_request_stop(members[i]);',
     'r.entries[i].request_status = 0;', 'state.stop_requested'),
    ('stop-at-first-error', '++r.quiescent;\n    }',
     '++r.quiescent;\n        if (r.entries[i].stop_status) break;\n    }', 'r.requested==3 && r.attempted==3'),
    ('extend-deadline', 'dizzass_io_stop(members[i], deadline,',
     'dizzass_io_stop(members[i], deadline+1,', 'deadline==same_deadline'),
    ('omit-cancel-guard', 'int saved, e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);',
     'int saved = PTHREAD_CANCEL_ENABLE, e = 0;', 'saved==PTHREAD_CANCEL_DISABLE'),
    ('omit-last-stop', 'for (size_t i = 0; i < count; ++i) {\n        r.entries[i].stop_status',
     'for (size_t i = 0; i+1 < count; ++i) {\n        r.entries[i].stop_status', 'r->all_quiescent'),
    ('ignore-stop-error', 'r.first_error = r.entries[i].stop_status;',
     'r.first_error = 0;', 'dizzass_io_stop_many(g.io,g.n,same_deadline,&r)==(wake ? EIO : EAGAIN)'),
    ('false-quiescence', 'r.all_quiescent = !r.first_error && r.quiescent == count;',
     'r.all_quiescent = true;', '!r.all_quiescent && r.first_error==')]

def configure_groups():
    combined.GROUPS = ORIGINAL_GROUPS + [('device_stop','DS7','device-stop-test',26,'R07_PASS cases=26 ')]
    # R-06 executes ALL original controls. New-file controls below are separate;
    # R-06's original path-selection rules deliberately remain unchanged.
    combined.controls = lambda name: [] if name == 'device_stop' else original_controls(name)

def main() -> int:
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',choices=['gcc','clang','gcc-14','clang-17'],default='gcc')
    ap.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    ap.add_argument('--out',required=True)
    ap.add_argument('--groups',default='all')
    ap.add_argument('--sanitize',action='store_true');ap.add_argument('--mutants',action='store_true')
    args=ap.parse_args()
    if args.sanitize and args.mutants: ap.error('separate mutation and sanitizer runs')
    configure_groups()
    # Includes the original archive/input checks, native build, 197 regression
    # cases, compiler input guard, health probe, and all 24 original mutants.
    rc=combined.main()
    if rc: return rc
    out=ROOT/args.out;src=out/'source';path=out/'results.json'
    report=json.loads(path.read_text())
    if 'device_stop' not in report['suites']: return 0
    report['status']='R07_CONTROLS_PENDING'
    path.write_text(json.dumps(report,indent=2)+'\n')
    runtime=src/'integration/native/io_stop_many.c'
    original=runtime.read_bytes()
    inputs_path=out/'compiler-inputs.json';inputs=json.loads(inputs_path.read_text())
    records=out/'compile-records';logs=out/'logs'
    def run(label,argv,allowed=(0,)):
        p=logs/(label+'.log');entry={'stage':label,'argv':argv,'returncode':None}
        report['commands'].append(entry);start=time.monotonic()
        try:
            with p.open('xb') as stream:
                done=subprocess.run(argv,cwd=src,stdout=stream,stderr=subprocess.STDOUT,timeout=90,
                    env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1'})
            entry['returncode']=done.returncode
        finally:
            entry.update(log=str(p.relative_to(out)),sha256=combined.sha(p.read_bytes()),seconds=round(time.monotonic()-start,3))
        if done.returncode not in allowed: raise RuntimeError(label+' failed; '+str(p))
        print(label+': '+str(done.returncode),flush=True)
        return p.read_text(errors='replace')
    try:
        run('r07-strict',[args.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-pthread',
            '-c','integration/native/io_stop_many.c','-o','build/r07-strict.o'])
        if args.cc.startswith('clang'):
            run('r07-analyzer',[args.cc,'--analyze','-I.','-Iinclude','-std=c11','-pthread','-Xanalyzer',
                '-analyzer-output=text','integration/native/io_stop_many.c'])
        if args.mutants:
            for name,old,new,witness in CONTROLS:
                if original.decode().count(old)!=1: raise ValueError('ambiguous control anchor: '+name)
                label='r07-'+name;directory='build/'+label
                try:
                    runtime.write_text(original.decode().replace(old,new,1))
                    inputs['integration/native/io_stop_many.c']=combined.sha(runtime.read_bytes())
                    inputs_path.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),
                        '--compiler',args.cc,'--inputs',str(inputs_path),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,
                        'DS7_DEPS=.','DS7_DIR='+directory,directory+'/test'])
                    text=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if witness not in text or not any(x in text for x in ['R07_ASSERT','R04_ASSERT']):
                        raise RuntimeError('wrong rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':'integration/native/io_stop_many.c'})
                finally:
                    runtime.write_bytes(original)
                    inputs['integration/native/io_stop_many.c']=combined.sha(original)
                    inputs_path.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(records.rglob('*.json')):
            r=json.loads(p.read_text())
            if r.get('error') or r['returncode']!=0: raise RuntimeError('failed compiler receipt: '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':combined.sha(p.read_bytes()),'source_count':len(r['inputs'])})
        report['compile_receipts']=receipts
        if runtime.read_bytes()!=original: raise RuntimeError('runtime not restored')
        report['status']='PASS'
        print('R07_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True)
        return 0
    except (OSError,ValueError,RuntimeError,subprocess.SubprocessError) as error:
        report['status']='FAIL';report['error']=str(error);print('R07_ERROR: '+str(error),file=sys.stderr);return 1
    finally: path.write_text(json.dumps(report,indent=2)+'\n')

if __name__=='__main__': raise SystemExit(main())

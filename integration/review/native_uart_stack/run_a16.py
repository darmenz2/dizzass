#!/usr/bin/env python3
# R-01 continuation: actual, pinned A-16. Reuse the original safe staging helpers.
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import run as base

HERE=Path(__file__).resolve().parent
REL=base.REL


def main() -> int:
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cc', choices=['gcc','clang'],default='gcc')
    parser.add_argument('--out',required=True)
    parser.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    parser.add_argument('--sanitize',action='store_true')
    parser.add_argument('--mutants',action='store_true')
    args=parser.parse_args()
    if args.sanitize and args.mutants:
        parser.error('Run semantic mutants separately, without sanitizers')
    report={'status':'FAIL','compiler':args.cc,'baseline':args.baseline,
            'sanitized_direct_units':args.sanitize,'support_objects_sanitized':False,
            'sanitizer_executable_no_pie':args.sanitize,'hardware':False,
            'pool_submission':False,'commands':[],'mutants':[],'actual_a16_executed':False}
    out=None
    try:
        manifest=json.loads((HERE/'manifest_a16.json').read_text())
        if base.git_bytes('rev-parse',manifest['base']+'^{tree}').decode().strip()!=manifest['base_tree']:
            raise ValueError('base tree mismatch')
        material=[(e,base.git_bytes('show',e['commit']+':'+e['path'])) for e in manifest['pending']]
        for entry,data in material:
            base.verify(data,entry)
        out=base.exclusive_output(args.out)
        native=out/'source'
        base.extract_base(base.git_bytes('archive','--format=tar',manifest['base']),native)
        report.update(manifest=manifest,test_files={})
        for name in ['test_stack.c','test_actual_a16.c','suite.mk','evidence/cancel_probe.c']:
            data=(HERE/name).read_bytes()
            p=native/REL/name
            p.parent.mkdir(parents=True,exist_ok=True)
            p.write_bytes(data)
            report['test_files'][name]=base.digest(data)
        deps=native/'build/r01-deps'
        for entry,data in material:
            p=deps/entry['path']
            p.parent.mkdir(parents=True,exist_ok=True)
            p.write_bytes(data)
        logs=out/'logs'
        logs.mkdir()
        def run(stage,command,allowed=(0,),timeout=180):
            record={'stage':stage,'argv':command,'returncode':None}
            report['commands'].append(record)
            log=logs/(stage+'.log')
            start=time.monotonic()
            with log.open('xb') as f:
                done=subprocess.run(command,cwd=native,stdout=f,stderr=subprocess.STDOUT,timeout=timeout, env={**os.environ, 'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1', 'UBSAN_OPTIONS':'halt_on_error=1'})
            record.update(returncode=done.returncode,log=str(log.relative_to(out)),
                          log_sha256=base.digest(log.read_bytes()),seconds=round(time.monotonic()-start,3))
            print(stage+': exit '+str(done.returncode),flush=True)
            if done.returncode not in allowed:
                if stage=='sanitizer-health-run': report['status']='BLOCKED_SANITIZER_HEALTH'
                raise RuntimeError(stage+' failed; see '+str(log))
            return log.read_text(errors='replace')
        report['compiler_version']=run('compiler',[args.cc,'--version']).splitlines()[0]
        if args.sanitize:
            run('sanitizer-health-build',[args.cc,'-std=c11','-O1','-g','-pthread',
                '-fsanitize=address,undefined','-fno-omit-frame-pointer','-fno-pie','-no-pie',
                str(REL/'evidence/cancel_probe.c'),'-o','sanitizer-health'])
            run('sanitizer-health-run',['timeout','15','./sanitizer-health'])
        run('autoreconf',['autoreconf','-fi'])
        options=['./configure','--enable-'+args.baseline,'--disable-curses','CC='+args.cc,'CFLAGS=-O2 -fcommon']
        if args.baseline=='ants2': options.append('--disable-libcurl')
        run('configure',options)
        run('native-core-build',['make','-j2'])
        make=['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+args.cc]
        flags=['R01_DIR=build/r01-a16']+(['SANITIZE=1'] if args.sanitize else [])
        run('integration-build',make+flags+['build/r01-a16/actual-a16'])
        report['actual_a16_executed']=True
        text=run('integration',['timeout','45','build/r01-a16/actual-a16'],timeout=55)
        markers=['R01_A16_PASS cases=26 ','R01_A16_EARLY fragment=11 pause=0',
                 'R01_A16_EARLY fragment=1 pause=1','R01_A16_CANCEL point=2 finish_once=1',
                 'R01_A16_CANCEL point=5 finish_once=1','R01_A16_UNCERTAIN bytes=5',
                 'R01_A16_UNCERTAIN bytes=88','R01_A16_QUEUE timeout=1 stop_timeout=1',
                 'R01_A16_SLOTS count=32 retained_copies_checked=32']
        if any(x not in text for x in markers): raise RuntimeError('missing semantic markers')
        report['integration_markers']=[x for x in text.splitlines() if x.startswith('R01_A16_')]
        symbols=run('symbols',['nm','--defined-only','build/r01-a16/actual-a16'])
        names={x.split()[-1] for x in symbols.splitlines() if x.split()}
        required={'copy_work_noffset','_free_work','test_nonce','fulltest',
                  'dizzass_jobs_prepare_tx88','dizzass_jobs_finish','dizzass_jobs_check',
                  'dizzass_native_job_channel_send','dizzass_uart_channel_send',
                  '__wrap_socket','__wrap_connect','__wrap_libusb_init','__wrap_strdup'}
        if not required<=names: raise RuntimeError('missing real helpers or offline guards')
        report['native_symbols']=sorted(required)
        if args.mutants:
            p=deps/'integration/native/native_job_channel_tx.c'
            controls=[
                ('late-full-as-written',
                 'r.transport.status == DIZZASS_UART_OK &&\n            r.transport.written == sizeof prepared.packet && r.transport.error == 0',
                 'r.transport.written == sizeof prepared.packet','r->outcome==DIZZASS_TX_UNCERTAIN && r->finish_status==0'),
                ('uncertain-as-not-sent','? DIZZASS_TX_WRITTEN : DIZZASS_TX_UNCERTAIN;',
                 '? DIZZASS_TX_WRITTEN : DIZZASS_TX_NOT_SENT;','r->outcome==DIZZASS_TX_UNCERTAIN && r->finish_status==0'),
                ('omit-finish','r.finish_status = dizzass_jobs_finish(jobs, &prepared.ticket, r.outcome);',
                 'r.finish_status = 0;','a16_trace.prepares==1 && a16_trace.finishes==1'),
                ('omit-stop','if (r.outcome != DIZZASS_TX_WRITTEN || r.finish_status)',
                 'if (false)','s.receipt.stop_called && s.receipt.stop_status==0'),
                ('omit-cancel-guard','r.entry_error = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);',
                 'r.entry_error = 0; saved = PTHREAD_CANCEL_ENABLE;','previous==PTHREAD_CANCEL_DISABLE')]
            original=p.read_bytes()
            for name,old,new,witness in controls:
                if original.decode().count(old)!=1: raise ValueError('mutant source anchor changed: '+name)
                try:
                    p.write_text(original.decode().replace(old,new,1))
                    directory='build/a16-mutant-'+name
                    run(name+'-build',make+['R01_DIR='+directory,directory+'/actual-a16'])
                    rejected=run(name+'-run',['timeout','45',directory+'/actual-a16'],allowed=(1,),timeout=55)
                    if 'A16_ASSERT ' not in rejected or witness not in rejected:
                        raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':name,'semantic_rejection':True})
                finally:
                    p.write_bytes(original)
        for entry,data in material:
            base.verify((deps/entry['path']).read_bytes(),entry)
        report['status']='PASS'
        print('R01_ACTUAL_A16_REVIEW_PASS scenarios=26 no_hardware=1',flush=True)
        return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as error:
        report['error']=str(error)
        print('R01_ACTUAL_A16_ERROR: '+str(error),file=sys.stderr)
        return 1
    finally:
        if out is not None: (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')


if __name__=='__main__':
    raise SystemExit(main())

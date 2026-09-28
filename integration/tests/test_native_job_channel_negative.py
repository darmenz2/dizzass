#!/usr/bin/env python3
"""Finite semantic controls, actual-core symbol checks and staging integrity."""
from __future__ import annotations
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'integration/native/native_job_channel_tx.c'

def need(ok, text):
    if not ok:
        raise ValueError(text)

def symbols(path):
    names = {line.split()[-1] for line in Path(path).read_text().splitlines() if line.split()}
    required = {'copy_work_noffset', '_free_work', 'test_nonce', 'fulltest', 'sha256',
        'dizzass_jobs_prepare_tx88', 'dizzass_jobs_finish', 'dizzass_jobs_check',
        'dizzass_native_job_channel_send', 'dizzass_uart_channel_send', '__wrap_socket',
        '__wrap_connect', '__wrap_libusb_init'}
    need(required <= names, 'missing real native helpers/guards: '+str(required-names))
    banned = {'dizzass_unused_cgminer_main','dizzass_tx_channel_send','dizzass_posix_tx88_write'}
    need(not names & banned, 'unexpected alternate startup/transport path')
    print('NATIVE_JOB_TX_SYMBOLS_PASS real_core_helpers=1 alternate_transport=0')

def staging():
    spec = importlib.util.spec_from_file_location('prepare_nj',ROOT/'tools/prepare_native_job_channel.py')
    module = importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    source = ROOT/'build/a16-deps'
    module.prepare(source,None,True)
    total=1
    with tempfile.TemporaryDirectory(prefix='a16-staging-',dir=ROOT/'build') as temp:
        temp=Path(temp)
        out=temp/'copy'
        module.prepare(out,source,False);module.prepare(out,None,True);total+=1
        def rejects(call, word):
            nonlocal total
            try: call()
            except (ValueError,OSError) as err:
                need(word in str(err),'wrong rejection: '+str(err));total+=1
            else: raise ValueError('invalid staging accepted')
        rejects(lambda:module.prepare(out,source,False),'overwrite')
        file=out/'integration/native/uart_safe.c';old=file.read_bytes();file.write_bytes(old+b'\n')
        rejects(lambda:module.prepare(out,None,True),'hash mismatch');file.write_bytes(old)
        extra=out/'integration/native/extra.h';extra.write_text('shadow')
        rejects(lambda:module.prepare(out,None,True),'file set');extra.unlink()
        link=out/'alias';link.symlink_to(file)
        rejects(lambda:module.prepare(out,None,True),'symlink');link.unlink()
        file.unlink();file.symlink_to(source/'integration/native/uart_safe.c')
        rejects(lambda:module.prepare(out,None,True),'symlink');file.unlink();file.write_bytes(old)
        broken=temp/'source';shutil.copytree(source,broken)
        p=broken/'integration/native/uart_safe.h';p.write_bytes(p.read_bytes()+b'\n')
        rejects(lambda:module.prepare(temp/'new',broken,False),'hash mismatch')
        for bad in ('/tmp/a16','integration/new','build','build/../outside'):
            rejects(lambda b=bad:module.output_path(b),'output must')
    print(f'NATIVE_JOB_TX_STAGING_PASS checks={total}')

def negatives(cc, build, deps):
    root=ROOT/Path(build)
    need(root.is_relative_to(ROOT/'build'),'build must stay under build/')
    out=root/'negative';out.mkdir(parents=True,exist_ok=True)
    text=SOURCE.read_text()
    edits={
        'no_outer_cancel_guard':('pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved)','pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, &saved)'),
        'wrong_slot':('algorithm_selector, slot, variant, source, &prepared)','algorithm_selector, slot + 1, variant, source, &prepared)'),
        'short_packet':('sizeof prepared.packet, deadline_ms, max_no_progress)','sizeof prepared.packet - 1, deadline_ms, max_no_progress)'),
        'extended_deadline':('sizeof prepared.packet, deadline_ms, max_no_progress)','sizeof prepared.packet, deadline_ms + 1, max_no_progress)'),
        'changed_budget':('sizeof prepared.packet, deadline_ms, max_no_progress)','sizeof prepared.packet, deadline_ms, max_no_progress + 1)'),
        'status_only_publishes':('r.transport.written == sizeof prepared.packet && r.transport.error == 0','1'),
        'count_only_publishes':('r.transport.status == DIZZASS_UART_OK &&','1 &&'),
        'zero_reusable':('? DIZZASS_TX_WRITTEN : DIZZASS_TX_UNCERTAIN','? DIZZASS_TX_WRITTEN : (r.transport.written ? DIZZASS_TX_UNCERTAIN : DIZZASS_TX_NOT_SENT)'),
        'lose_count':('r.outcome = r.transport.status','r.transport.written = 0;\n        r.outcome = r.transport.status'),
        'lose_errno':('r.outcome = r.transport.status','r.transport.error = 0;\n        r.outcome = r.transport.status'),
        'lose_finish_error':('r.finish_status = dizzass_jobs_finish(jobs, &prepared.ticket, r.outcome);','r.finish_status = dizzass_jobs_finish(jobs, &prepared.ticket, r.outcome);\n        r.finish_status = 0;'),
        'omit_finish':('r.finish_status = dizzass_jobs_finish(jobs, &prepared.ticket, r.outcome);','r.finish_status = 0;'),
        'omit_stop':('if (r.outcome != DIZZASS_TX_WRITTEN || r.finish_status) {','if (0) {'),
        'hide_ticket':('r.ticket = prepared.ticket;','r.ticket = (struct dizzass_job_ticket){0};'),
        'hide_channel_entry':('r.channel_called = true;','r.channel_called = false;'),
    }
    records=[]
    for name,edit in [('baseline',None),*edits.items()]:
        data=text
        if edit:
            need(text.count(edit[0])==1,'ambiguous mutation '+name)
            data=text.replace(edit[0],edit[1])
        directory=out/name;directory.mkdir(exist_ok=True)
        source=directory/'binding.c';source.write_text(data)
        obj=directory/'binding.o';binary=directory/'control'
        # All unchanged objects come from the already built exact baseline.
        command=['make','-f','Makefile','-f','integration/native-job-channel-tx.mk',
            f'CC={cc}',f'NJ_DIR={root.relative_to(ROOT)}',f'NJ_DEPS={deps}',
            f'NJ_SOURCE={source.relative_to(ROOT)}',f'NJ_BINDING={obj.relative_to(ROOT)}',
            f'NJ_CONTROL={binary.relative_to(ROOT)}',str(binary.relative_to(ROOT))]
        compiled=subprocess.run(command,cwd=ROOT,text=True,capture_output=True,timeout=60)
        (directory/'build.log').write_text(compiled.stdout+compiled.stderr)
        need(compiled.returncode==0,'mutation did not compile: '+name)
        run=subprocess.run([str(binary)],cwd=ROOT,text=True,capture_output=True,timeout=50)
        (directory/'test.log').write_text(run.stdout+run.stderr)
        if name=='baseline': need(run.returncode==0 and 'NATIVE_JOB_TX_CONTROL_PASS' in run.stdout,'baseline failed')
        else: need(run.returncode==1 and 'NATIVE_JOB_TX_ASSERT' in run.stderr,'not a semantic rejection: '+name)
        records.append({'name':name,'build_exit':compiled.returncode,'test_exit':run.returncode})
    (out/'summary.json').write_text(json.dumps({'compiler':cc,'rejected':len(edits),'records':records},indent=2)+'\n')
    print(f'NATIVE_JOB_TX_NEGATIVE_PASS compiler={cc} rejected={len(edits)}')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--symbols');parser.add_argument('--staging-checks',action='store_true')
    parser.add_argument('--cc',default='cc');parser.add_argument('--build',default='build/native-job-channel')
    parser.add_argument('--deps',default='build/a16-deps');args=parser.parse_args()
    if args.symbols: symbols(args.symbols)
    elif args.staging_checks: staging()
    else: negatives(args.cc,args.build,args.deps)

if __name__=='__main__': main()

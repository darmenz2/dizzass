#!/usr/bin/env python3
"""R-08: extend unchanged R-07 runner; current-source CRC integration and controls."""
from __future__ import annotations
import argparse,importlib.util,json,os,shlex,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];REL=Path('integration/review/rx_integrity')
spec=importlib.util.spec_from_file_location('device_stop',ROOT/'integration/review/device_stop/run.py')
previous=importlib.util.module_from_spec(spec);spec.loader.exec_module(previous)
configure_previous=previous.configure_groups
CONTROLS=[
 ('bypass-crc','rx_owner.c','if (o->crc5_required) {','if (false) {','e.count==1 && e.events[0].kind==DIZZASS_RX_INTEGRITY_REJECTED'),
 ('nonce-only-crc','rx_owner.c','if (o->crc5_required) {','if (o->crc5_required && kind == VN135_RX_NONCE_RAW) {','e.count==1 && e.events[0].kind==DIZZASS_RX_INTEGRITY_REJECTED'),
 ('drop-crc-counter','rx_owner.c','++o->report.crc_rejected;','/* injected missing accounting */','r.crc5_required && r.crc_checked==1 && r.crc_rejected==1'),
 ('wrong-strict-profile','rx_owner.c','c->chip_selector != 4 || c->special_mode','c->chip_selector != 6 || c->special_mode','dizzass_rx_owner_create_crc5(&c,&e.owner)==0'),
 ('unchecked-lifecycle','io_lifecycle.c','e = require_crc5 ? dizzass_rx_owner_create_crc5(cfg, &l->rx) :','e = false ? dizzass_rx_owner_create_crc5(cfg, &l->rx) :','dizzass_io_create_crc5(&c,e.f.channel,&io)==DIZZASS_RX_CRC_UNSUPPORTED && !io'),
 ('lose-verification-receipt','rx_owner.c','.integrity_verified = o->crc5_required};','.integrity_verified = false};','e.events[1].kind==DIZZASS_RX_DISPATCHED && e.events[1].integrity_verified')]

def configure_groups():
    configure_previous();old=previous.combined.controls
    previous.combined.GROUPS += [('rx_integrity','CI8','rx-integrity-test',167,'R08_PASS cases=167 ')]
    previous.combined.controls=lambda name: [] if name=='rx_integrity' else old(name)

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
    out=ROOT/a.out;src=out/'source';p=out/'results.json';report=json.loads(p.read_text())
    if 'rx_integrity' not in report['suites']:return 0
    report['status']='R08_CONTROLS_PENDING';p.write_text(json.dumps(report,indent=2)+'\n')
    inp=out/'compiler-inputs.json';inputs=json.loads(inp.read_text());records=out/'compile-records';logs=out/'logs'
    def run(label,argv,allowed=(0,)):
        log=logs/(label+'.log');entry={'stage':label,'argv':argv,'returncode':None};report['commands'].append(entry)
        start=time.monotonic()
        try:
            with log.open('xb') as f:
                done=subprocess.run(argv,cwd=src,stdout=f,stderr=subprocess.STDOUT,timeout=90,
                    env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1','PYTHONDONTWRITEBYTECODE':'1'})
            entry['returncode']=done.returncode
        finally:entry.update(log=str(log.relative_to(out)),sha256=previous.combined.sha(log.read_bytes()),seconds=round(time.monotonic()-start,3))
        if done.returncode not in allowed:raise RuntimeError(label+' failed: '+str(log))
        print(label+': '+str(done.returncode),flush=True);return log.read_text(errors='replace')
    try:
        report['suites']['rx_integrity']['markers']=[x for x in (logs/'rx_integrity.log').read_text().splitlines() if x.startswith('R08_')]
        run('r08-vectors',[sys.executable,'-B',str(REL/'generate_vectors.py'),'--check'])
        for name in ['rx_owner','io_lifecycle']:
            run('r08-strict-'+name,[a.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-pthread','-c','integration/native/'+name+'.c','-o','build/r08-strict-'+name+'.o'])
        sym=run('r08-symbols',['nm','--defined-only','build/combined-rx_integrity/test'])
        names={line.split()[-1] for line in sym.splitlines() if line.split()}
        required={'dizzass_bm1368_reply_crc5','vn135_crc5_bits','dizzass_rx_owner_create_crc5','dizzass_io_create_crc5'}
        if not required<=names:raise RuntimeError('missing strict CRC helpers')
        report['integrity_symbols']=sorted(required)
        if a.mutants:
            for name,file,old,new,witness in CONTROLS:
                runtime=src/'integration/native'/file;original=runtime.read_text();key=str(runtime.relative_to(src))
                if original.count(old)!=1:raise ValueError('mutation anchor: '+name)
                label='r08-'+name;directory='build/'+label
                try:
                    runtime.write_text(original.replace(old,new,1));inputs[key]=previous.combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
                    cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/'integration/review/combined_rx/compile_guard.py'),'--compiler',a.cc,'--inputs',str(inp),'--records',str(records/label),'--'])
                    run(label+'-build',['make','-f','Makefile','-f',str(REL/'suite.mk'),'CC='+cc,'CI8_DEPS=.','CI8_DIR='+directory,directory+'/test'])
                    text=run(label,['timeout','60',directory+'/test'],allowed=(1,))
                    if 'R08_ASSERT' not in text or witness not in text:raise RuntimeError('wrong semantic rejection: '+name)
                    report['mutants'].append({'name':label,'witness':witness,'changed_file':key})
                finally:
                    runtime.write_text(original);inputs[key]=previous.combined.sha(runtime.read_bytes());inp.write_text(json.dumps(inputs))
        receipts=[]
        for file in sorted(records.rglob('*.json')):
            item=json.loads(file.read_text())
            if item.get('error') or item['returncode']!=0:raise RuntimeError('failed audited compilation '+str(file))
            receipts.append({'file':str(file.relative_to(out)),'sha256':previous.combined.sha(file.read_bytes()),'source_count':len(item['inputs'])})
        report['compile_receipts']=receipts;report['status']='PASS'
        print('R08_CURRENT_SOURCE_PASS scenarios='+str(report['scenario_total'])+' mutants='+str(len(report['mutants'])),flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['status']='FAIL';report['error']=str(e);print('R08_ERROR: '+str(e),file=sys.stderr);return 1
    finally:p.write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

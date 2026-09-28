#!/usr/bin/env python3
"""Semantic mutants must diverge from ARM fixtures, not merely crash or fail build."""
import argparse
import ctypes as C
import json
import os
from pathlib import Path
import subprocess
import sys
import test_work_rx_worker_135 as T
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'src/backend/work-gen/work-rx-worker.c'
MUTATIONS={
 'missing_start_flag':('backend->running=1;','backend->running=0;'),
 'stop_mid_pass':('&& i<count;++i)','&& i<count && backend->running;++i)'),
 'enabled_equals_one':('if(!chain->enabled)continue;','if(chain->enabled!=1)continue;'),
 'cached_mode':('            mode=ops->scalar(opaque,0xfe0b0u);','            mode=ops->scalar(opaque,0xfe0b0u); mode=initial_mode;'),
 'live_minimum':('<initial.frame_size','<(mode ? 9u : 9u+initial.variant)'),
 'strict_available':('<initial.frame_size','<=initial.frame_size'),
 'signed_available':('ops->available(opaque,chain->fifo)<initial.frame_size','(int32_t)ops->available(opaque,chain->fifo)<(int32_t)initial.frame_size'),
 'stop_on_byte_error':('(void)ops->byte(opaque,chain->fifo,&header);','if(ops->byte(opaque,chain->fifo,&header))goto consumed;'),
 'stop_on_payload_error':('(void)ops->payload(opaque,chain->fifo,frame+2,policy.payload_size);','if(ops->payload(opaque,chain->fifo,frame+2,policy.payload_size))goto consumed;'),
 'wrong_job_row':('&view->slots[slot]','&view->slots[(slot+1u)&31u]'),
 'filter_narrowed':('message.register_address!=filtered','message.register_address!=(uint8_t)filtered'),
 'lost_progress':('progress=1;','progress=0;'),
 'skip_wait_when_stopped':('if(!progress){','if(!progress && backend->running){'),
 'lost_cancel_state':('ops->cancel(opaque,old_cancel,NULL)','ops->cancel(opaque,1,NULL)'),
 'early_chain_capture':('struct vn135_rx_chain *chain=&backend->chains[i];','struct vn135_rx_chain *chain=&cached_chains[i];'),
}

def child(library,fixture):
    lib=C.CDLL(str(library.resolve()))
    for p,expected in json.loads(fixture.read_text()):
        got=T.native(p,lib)
        actual=[got.events,got.snapshot(),got.verify()]
        if json.loads(json.dumps(actual))!=expected:
            print('SEMANTIC_MISMATCH',json.dumps(p));return 1
    print('BASELINE_FIXTURES_PASS');return 0

def main(out,compiler):
    out.mkdir(parents=True,exist_ok=True);source_text=SOURCE.read_text()
    # All cases except exhaustive noisy prefixes; add AA AA explicitly.
    selected=[p for p in T.cases() if not (p.get('count')==1 and len(p.get('streams',[''])[0])==46)]
    selected += [{'count':1,'streams':[(b'\xaa'+T.packet()+bytes(11)).hex(),'','']},
                 {'reported':0xffffffff,'streams':['','',''],'mutations':[('lock',0,'running',0)]},
                 {'filter':0x141,'streams':[T.packet(2,False).hex(),'','']}]
    elf=T.ELF32(ROOT/'reference/cgminer.vendor.elf');assert T.digest(elf.data)==T.REF
    m=T.Machine(elf);fixtures=[]
    for p in selected:
        w=T.original(p,m);fixtures.append([p,[w.events,w.snapshot(),w.verify()]])
    fixture=out/'original-fixtures.json';fixture.write_text(json.dumps(fixtures))
    for name,change in [('baseline',None),*MUTATIONS.items()]:
        source=source_text
        if change:
            old,new=change;assert old in source,name;source=source.replace(old,new)
            if name=='early_chain_capture':source=source.replace('uint8_t header=', 'struct vn135_rx_chain *cached_chains=backend->chains;\n    uint8_t header=')
        path=out/(name+'.c');path.write_text(source);lib=out/(name+'.so')
        command=[compiler,'-I.','-Iinclude','-std=c11','-O2','-Wall','-Wextra','-Wpedantic','-Werror','-shared','-fPIC',
                 str(path),'src/backend/work-gen/work-gen.c','reconstruction/support/sha256_midstate.c','-o',str(lib)]
        build=subprocess.run(command,cwd=ROOT,text=True,capture_output=True)
        assert build.returncode==0,(name,build.stderr)
        check=subprocess.run([sys.executable,__file__,'--child',str(lib.resolve()),str(fixture.resolve())],
                             cwd=ROOT,text=True,capture_output=True,timeout=60)
        (out/(name+'.log')).write_text(check.stdout+check.stderr)
        if name=='baseline':assert check.returncode==0,check.stdout+check.stderr
        else:assert check.returncode==1 and 'SEMANTIC_MISMATCH' in check.stdout,(name,check.returncode,check.stdout,check.stderr)
    print(f'WORK_RX_WORKER_NEGATIVE_PASS mutants={len(MUTATIONS)} original_fixtures={len(fixtures)} baseline=PASS')

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='--child':sys.exit(child(Path(sys.argv[2]),Path(sys.argv[3])))
    p=argparse.ArgumentParser();p.add_argument('output',type=Path);p.add_argument('--cc',default=os.environ.get('CC','cc'));a=p.parse_args()
    main(a.output,a.cc)

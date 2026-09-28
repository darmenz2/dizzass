#!/usr/bin/env python3
"""Compile plausible semantic errors; each must fail against original fixtures."""
import argparse
import ctypes as C
import json
import os
from pathlib import Path
import subprocess
import sys
import test_work_tx_worker_135 as T

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'src/backend/work-gen/work-tx-worker.c'
MUTATIONS={
 'missing_start_flag':('backend->running=1;','backend->running=0;'),
 'stop_mid_pass':('for(i=0;i<count;++i){','for(i=0;i<count && backend->running;++i){'),
 'skip_state_5':('chain->state->state-3u)<=2u','chain->state->state-3u)<2u'),
 'empty_only_skips_one_chain':('if(head==tail)break;','if(head==tail)continue;'),
 'stale_tail_reread':('tail=ring->tail;\n            (void)ops->call(opaque,0x5a66c4u,0x633bf0u,0);\n            if((tail>>8)>2u)break;',
                       '(void)ops->call(opaque,0x5a66c4u,0x633bf0u,0);\n            if((tail>>8)>2u)break;'),
 'incomplete_snapshot':('memcpy(row,&ring->rows[tail],sizeof(*row));','memcpy(row,&ring->rows[tail],76);'),
 'slot_wrap_early':('slots->next=next>31u ? 0u : next;','slots->next=next>30u ? 0u : next;'),
 'increment_captured_tail':('next=ring->tail+1u;','next=tail+1u;'),
 'tail_wrap_early':('ring->tail=(next>>8)>2u ? 0u : next;','ring->tail=next>=767u ? 0u : next;'),
 'wrong_slot_tag':('frame[4]=(uint8_t)(slot<<3);','frame[4]=(uint8_t)(slots->next<<3);'),
 'wrong_prefix_order':('memcpy(frame+10,row->bytes+64,12);','memcpy(frame+10,row->bytes,12);'),
 'crc_wrong_span':('frame+2,84,UINT16_C(0xffff)','frame+2,83,UINT16_C(0xffff)'),
 'stop_on_uart_error':('(void)ops->write(opaque,uart,frame,sizeof(frame));','if(ops->write(opaque,uart,frame,sizeof(frame)))break;'),
 'missing_negative_carry':('--time->seconds_bits;','/* lost negative second carry */'),
 'millisecond_units':('interval*INT64_C(1000000)','interval*INT64_C(1000)'),
 'early_chain_capture':('struct vn135_tx_chain *chain=&backend->chains[i];','struct vn135_tx_chain *chain=&cached_chains[i];'),
}

def child(library,fixture):
    lib=C.CDLL(str(library.resolve()))
    for p,expected in json.loads(fixture.read_text()):
        got=T.native(p,lib)
        actual=[got.events,got.snapshot(),T.digest(got.data('queue')),T.digest(got.data('slots'))]
        if json.loads(json.dumps(actual))!=expected:
            print('SEMANTIC_MISMATCH',json.dumps(p));return 1
    print('BASELINE_FIXTURES_PASS');return 0

def main(out,compiler):
    out.mkdir(parents=True,exist_ok=True)
    text=SOURCE.read_text()
    params=list(T.cases())
    selected=params[:60]+params[-30:]+[p for p in params if 'mutations' in p]
    elf=T.ELF32(ROOT/'reference/cgminer.vendor.elf');assert T.digest(elf.data)==T.REF
    m=T.Machine(elf);fixtures=[]
    for p in selected:
        w=T.original(p,m)
        fixtures.append([p,[w.events,w.snapshot(),T.digest(w.data('queue')),T.digest(w.data('slots'))]])
    fixture=out/'original-fixtures.json';fixture.write_text(json.dumps(fixtures))
    for name,change in [('baseline',None),*MUTATIONS.items()]:
        source=text
        if change:
            old,new=change;assert old in source,name;source=source.replace(old,new)
            if name=='early_chain_capture':source=source.replace('int32_t count=ops->call','struct vn135_tx_chain *cached_chains=backend->chains;\n    int32_t count=ops->call')
        path=out/(name+'.c');path.write_text(source)
        lib=out/(name+'.so')
        command=[compiler,'-I.','-Iinclude','-std=c11','-O2','-Wall','-Wextra','-Wpedantic','-Werror',
                 '-shared','-fPIC',str(path),'integration/work_tx88.c','-o',str(lib)]
        build=subprocess.run(command,cwd=ROOT,text=True,capture_output=True)
        assert build.returncode==0,(name,build.stderr)
        check=subprocess.run([sys.executable,__file__,'--child',str(lib.resolve()),str(fixture.resolve())],
                             cwd=ROOT,text=True,capture_output=True,timeout=60)
        (out/(name+'.log')).write_text(check.stdout+check.stderr)
        if name=='baseline':assert check.returncode==0,check.stdout+check.stderr
        else:assert check.returncode==1 and 'SEMANTIC_MISMATCH' in check.stdout,(name,check.returncode,check.stdout,check.stderr)
    print(f'WORK_TX_WORKER_NEGATIVE_PASS mutants={len(MUTATIONS)} original_fixtures={len(fixtures)} baseline=PASS')

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='--child':sys.exit(child(Path(sys.argv[2]),Path(sys.argv[3])))
    p=argparse.ArgumentParser();p.add_argument('output',type=Path);p.add_argument('--cc',default=os.environ.get('CC','cc'));a=p.parse_args()
    main(a.output,a.cc)

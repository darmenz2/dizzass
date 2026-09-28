#!/usr/bin/env python3
"""Every semantic mutant must build and differ from original ARM fixtures."""
import argparse
import ctypes as C
import json
import os
from pathlib import Path
import subprocess
import sys
import test_work_producer_135 as T
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'src/backend/work-gen/work-producer.c'
MUTATIONS={
 'unsigned_count':('if(!count || count>=UINT32_C(0x80000000))return;','if(!count)return;'),
 'undoubled_limit':('uint32_t limit=count<<1;','uint32_t limit=count;'),
 'unsigned_limit':('(iteration^UINT32_C(0x80000000))<(limit^UINT32_C(0x80000000))','iteration<limit'),
 'full_without_wrap':('(head+1u)%768u==tail','head+1u==tail'),
 'stale_head':('\n        head=ring->head;\n','\n        /* omitted second head read */\n'),
 'early_head_guard':('if((head>>8)>2u)break;','if((head>>8)>=2u)break;'),
 'wrong_counter_endian':('(*view->counter>>(8*i))','(*view->counter>>(8*(7-i)))'),
 'single_sha':('vn135_sha256d_bytes','vn135_sha256_bytes'),
 'missing_64_reverse':('reverse_bytes(row->bytes,64);','/* omitted block reverse */'),
 'missing_12_reverse':('reverse_bytes(row->bytes+64,12);','/* omitted tail reverse */'),
 'swapped_bits_time':('job->header_words+40,4);','job->header_words+36,4);'),
 'missing_nonce_zero':('store_word(row->bytes+76,0);','/* leaves stale nonce */'),
 'wrong_root_metadata':('reverse_words(row->bytes+80,root,32);','memcpy(row->bytes+80,root,32);'),
 'missing_counter_high':('store_word(row->bytes+116,(uint32_t)(*view->counter>>32));','store_word(row->bytes+116,0);'),
 'increment_captured_head':('next=ring->head+1u;','next=head+1u;'),
 'counter_before_unlock':('        ++*view->counter;',''),
}

def child(library,fixture):
    lib=C.CDLL(str(library.resolve()))
    for p,expected in json.loads(fixture.read_text()):
        got=T.native(p,lib);actual=[got.events,got.snapshot()]
        if json.loads(json.dumps(actual))!=expected:
            print('SEMANTIC_MISMATCH',json.dumps(p));return 1
    print('BASELINE_FIXTURES_PASS');return 0

def main(out,compiler):
    out.mkdir(parents=True,exist_ok=True);text=SOURCE.read_text();params=list(T.cases())
    selected=params[:48]+params[-5:]+[p for p in params if 'mutations' in p]
    elf=T.ELF32(ROOT/'reference/cgminer.vendor.elf');assert T.digest(elf.data)==T.REF
    m=T.Machine(elf);T.check_umull(m);fixtures=[]
    for p in selected:
        w=T.original(p,m);fixtures.append([p,[w.events,w.snapshot()]])
    fixture=out/'original-fixtures.json';fixture.write_text(json.dumps(fixtures))
    for name,change in [('baseline',None),*MUTATIONS.items()]:
        source=text
        if change:
            old,new=change;assert old in source,name;source=source.replace(old,new)
            if name=='counter_before_unlock':source=source.replace('        next=ring->head+1u;','        ++*view->counter;\n        next=ring->head+1u;')
        path=out/(name+'.c');path.write_text(source);lib=out/(name+'.so')
        build=subprocess.run([compiler,'-I.','-Iinclude','-std=c11','-O2','-Wall','-Wextra','-Wpedantic','-Werror','-shared','-fPIC',str(path),
                              'reconstruction/support/sha256_bytes.c','reconstruction/support/sha256_midstate.c','-o',str(lib)],cwd=ROOT,text=True,capture_output=True)
        assert build.returncode==0,(name,build.stderr)
        check=subprocess.run([sys.executable,__file__,'--child',str(lib.resolve()),str(fixture.resolve())],cwd=ROOT,text=True,capture_output=True,timeout=60)
        (out/(name+'.log')).write_text(check.stdout+check.stderr)
        if name=='baseline':assert check.returncode==0,check.stdout+check.stderr
        else:assert check.returncode==1 and 'SEMANTIC_MISMATCH' in check.stdout,(name,check.returncode,check.stdout,check.stderr)
    print(f'WORK_PRODUCER_NEGATIVE_PASS mutants={len(MUTATIONS)} original_fixtures={len(fixtures)} baseline=PASS')

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='--child':sys.exit(child(Path(sys.argv[2]),Path(sys.argv[3])))
    p=argparse.ArgumentParser();p.add_argument('output',type=Path);p.add_argument('--cc',default=os.environ.get('CC','cc'));a=p.parse_args()
    main(a.output,a.cc)

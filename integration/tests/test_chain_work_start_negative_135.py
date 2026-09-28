#!/usr/bin/env python3
"""Compile each mutant, then require semantic disagreement with original A32."""
import argparse,json,subprocess,sys
from pathlib import Path
from test_chain_work_start_135 import ROOT,fixtures
def main():
    ap=argparse.ArgumentParser();ap.add_argument('output');ap.add_argument('--cc',required=True);ap.add_argument('--baseline',required=True);a=ap.parse_args()
    out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
    items,counts=fixtures()
    for _,result in items:result.pop('memory')
    fixture=out/'original.json';fixture.write_text(json.dumps(items))
    def run(name,library,expected):
        r=subprocess.run([sys.executable,str(ROOT/'integration/tests/test_chain_work_start_135.py'),str(library),'--fixtures',str(fixture)],capture_output=True,text=True,timeout=60)
        (out/(name+'.log')).write_text(r.stdout+r.stderr)
        assert r.returncode==expected,(name,r.returncode,r.stdout[:500],r.stderr[:500])
        assert ('BASELINE_FIXTURES_PASS' if expected==0 else 'SEMANTIC_MISMATCH') in r.stdout,name
    run('baseline',Path(a.baseline).resolve(),0)
    source=(ROOT/'src/backend/work-gen/chain-work-start.c').read_text()
    edits={
      'early_index':[('int32_t count=o->count(ctx);\n    int32_t index=*v->index;','int32_t index=*v->index;\n    int32_t count=o->count(ctx);')],
      'unsigned_count':[('index>=count','(uint32_t)index>=(uint32_t)count')],
      'off_by_one':[('index>=count','index>count')],
      'negative_getter_skipped':[('int32_t count=o->count(ctx);','int32_t count=*v->index<0?0:o->count(ctx);')],
      'flag_one':[('v->worker->running!=0','v->worker->running==1')],
      'handle_gate':[('v->worker->running!=0','v->worker->handle!=0')],
      'fail_mutex':[('(void)o->mutex_init(ctx,v->mutex,0);','if (o->mutex_init(ctx,v->mutex,0)) return -1;')],
      'fail_queue':[('(void)o->queue_init(ctx,v->queue,0x800,1);','if (o->queue_init(ctx,v->queue,0x800,1)) return -1;')],
      'wrong_queue_capacity':[('v->queue,0x800,1','v->queue,0x400,1')],
      'wrong_queue_stride':[('v->queue,0x800,1','v->queue,0x800,2')],
      'stale_path_index':[('o->path(ctx,*v->path_method,*v->index)','o->path(ctx,*v->path_method,index)')],
      'early_path_method':[('int32_t count=o->count(ctx);','uint32_t method=*v->path_method;\n    int32_t count=o->count(ctx);'),('o->path(ctx,*v->path_method','o->path(ctx,method')],
      'early_open_method':[('int32_t count=o->count(ctx);','uint32_t method=*v->open_method;\n    int32_t count=o->count(ctx);'),('o->open(ctx,*v->open_method','o->open(ctx,method')],
      'early_device_index':[('void *path=o->path(ctx,*v->path_method,*v->index);\n    *v->device_index=*v->index;','*v->device_index=*v->index;\n    void *path=o->path(ctx,*v->path_method,*v->index);')],
      'stale_device_index':[('*v->device_index=*v->index;','*v->device_index=index;')],
      'null_path_abort':[('    *v->device_index=*v->index;','    if (!path) return -1;\n    *v->device_index=*v->index;')],
      'negative_open_only':[('v->uart,path)!=0','v->uart,path)<0')],
      'negative_create_only':[('0xc36e8,v->chain)!=0','0xc36e8,v->chain)<0')],
      'wrong_worker':[('0xc36e8,v->chain','0xc3148,v->chain')],
      'clear_failed_handle':[('diagnostic(o,ctx,0x2d0','v->worker->handle=0;\n        diagnostic(o,ctx,0x2d0')],
      'set_running':[('    return 0;\n}','    v->worker->running=1;\n    return 0;\n}')],
      'stale_create_log':[('(uint32_t)*v->index+UINT32_C(1)','(uint32_t)index+UINT32_C(1)')],
      'wrong_path_log':[('(uintptr_t)path);','(uintptr_t)v->uart);')],
      'wrong_invalid_increment':[('(uint32_t)index+UINT32_C(1)','(uint32_t)index')],
    }
    for name,replacements in edits.items():
        changed=source
        for old,new in replacements:assert old in changed,(name,old);changed=changed.replace(old,new)
        path=out/(name+'.c');path.write_text(changed);library=out/(name+'.so')
        r=subprocess.run([a.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-O2','-shared','-fPIC',str(path),'reconstruction/support/record_fifo.c','libbitmain/src/uart.c','-Wl,-z,defs','-o',str(library)],cwd=ROOT,capture_output=True,text=True)
        (out/(name+'-build.log')).write_text(r.stdout+r.stderr);assert r.returncode==0,(name,r.stdout,r.stderr)
        run(name,library,3)
    print(f'CHAIN_WORK_START_NEGATIVE_PASS mutants={len(edits)} original_fixtures={counts["cases"]} baseline=PASS')
if __name__=='__main__':main()

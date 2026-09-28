#!/usr/bin/env python3
"""Only compiled semantic disagreements count; timeouts/crashes are failures."""
import argparse,json,subprocess,sys
from pathlib import Path
from test_chain_uart_reader_135 import ROOT,fixtures
def main():
    ap=argparse.ArgumentParser();ap.add_argument('output');ap.add_argument('--cc',required=True);ap.add_argument('--baseline',required=True);ap.add_argument('--policy',required=True);a=ap.parse_args()
    out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True);items,counts=fixtures()
    for _,r in items:r.pop('memory');r.pop('scratch')
    fixture=out/'original.json';fixture.write_text(json.dumps(items))
    def run(name,library,expected):
        p=subprocess.run([sys.executable,str(ROOT/'integration/tests/test_chain_uart_reader_135.py'),str(library),'--fixtures',str(fixture)],capture_output=True,text=True,timeout=60)
        (out/(name+'.log')).write_text(p.stdout+p.stderr)
        assert p.returncode==expected,(name,p.returncode,p.stdout[:500],p.stderr[:500])
        assert ('SEMANTIC_MISMATCH' if expected else 'BASELINE_FIXTURES_PASS') in p.stdout,name
    run('baseline',Path(a.baseline).resolve(),0)
    source=(ROOT/'src/backend/work-gen/chain-uart-reader.c').read_text()
    edits={
      'free_space_instead_capacity':[('if (capacity!=0) return capacity;','if (capacity!=0) return capacity-*v->queue_count;')],
      'stride_ignored':[('(*v->queue_end-*v->queue_begin)/stride','(*v->queue_end-*v->queue_begin)')],
      'wait_early_flag':[('        uint32_t stride=*v->queue_stride;','        if (!*v->running) { (void)o->mutex(ctx,0x5a66c4,v->mutex); return 0; }\n        uint32_t stride=*v->queue_stride;')],
      'late_capacity_load':[('        (void)o->mutex(ctx,0x5a66c4,v->mutex);\n        if (capacity','        (void)o->mutex(ctx,0x5a66c4,v->mutex);\n        capacity=*v->queue_stride?(*v->queue_end-*v->queue_begin)/ *v->queue_stride:0;\n        if (capacity')],
      'wait_delay_four':[('o->delay_ms(ctx,5)','o->delay_ms(ctx,4)')],
      'forced_threshold_wrong':[('uint32_t threshold=policy.frame_size;','uint32_t threshold=*v->force_nine?11:policy.frame_size;')],
      'special_controller_removed':[('&policy,controller,model','&policy,controller==4 && model==6?1:controller,model')],
      'model_seven_wrong':[('&policy,controller,model,','&policy,controller,model==7?0:model,')],
      'live_threshold':[('if (count>=threshold)','if (count>=(*v->force_nine?9:(*v->controller==0 || (*v->model==6 && *v->controller==4))?9:*v->model==7?10:threshold))')],
      'strict_signal_threshold':[('if (count>=threshold)','if (count>threshold)')],
      'skip_running_store':[('    *v->running=1;\n','')],
      'early_loop_exit':[('        (void)o->mode(ctx,0,&s->previous_mode[0]);','        if (!*v->running) break;\n        (void)o->mode(ctx,0,&s->previous_mode[0]);')],
      'clamp_255':[('if (amount>=256) amount=256;','if (amount>=255) amount=255;')],
      'early_method':[('    uint32_t model=*v->model','    uint32_t method=*v->read_method;\n    uint32_t model=*v->model'),('o->read(ctx,*v->read_method','o->read(ctx,method')],
      'omit_restore':[('        (void)o->mode(ctx,s->previous_mode[0],0);\n','')],
      'restore_constant':[('o->mode(ctx,s->previous_mode[0],0)','o->mode(ctx,1,0)')],
      'wrong_saved_slot':[('&s->previous_mode[0]','&s->previous_mode[1]')],
      'zero_read_positive':[('if (received<=0)','if (received<0)')],
      'clamp_result_to_request':[('        (void)o->mode(ctx,s->previous_mode[0],0);','        (void)o->mode(ctx,s->previous_mode[0],0);\n        if (received>0 && (uint32_t)received>amount) received=(int32_t)amount;')],
      'count_before_push':[('(void)o->push(ctx,v->queue,s->bytes,(uint32_t)received);\n            uint32_t count=*v->queue_count;','uint32_t count=*v->queue_count;\n            (void)o->push(ctx,v->queue,s->bytes,(uint32_t)received);')],
      'push_result_gate':[('(void)o->push(ctx,v->queue,s->bytes,(uint32_t)received);\n            uint32_t count=*v->queue_count;','uint32_t accepted=o->push(ctx,v->queue,s->bytes,(uint32_t)received);\n            uint32_t count=accepted?*v->queue_count:0;')],
      'signal_wrong_object':[('o->signal(ctx,v->condition)','o->signal(ctx,v->queue)')],
      'omit_terminal_exit':[('    o->exit_thread(ctx,0);','    (void)ctx;')],
      'fail_fast_initial_mode':[('(void)o->mode(ctx,1,0);','if (o->mode(ctx,1,0)) return;')],
    }
    for name,edits_for_case in edits.items():
        changed=source
        for old,new in edits_for_case:assert old in changed,(name,old);changed=changed.replace(old,new)
        p=out/(name+'.c');p.write_text(changed);library=out/(name+'.so')
        r=subprocess.run([a.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-O2','-shared','-fPIC',str(p),'reconstruction/support/record_fifo.c','libbitmain/src/uart.c',str(Path(a.policy).resolve()),'-Wl,--gc-sections,-z,defs','-o',str(library)],cwd=ROOT,capture_output=True,text=True)
        (out/(name+'-build.log')).write_text(r.stdout+r.stderr);assert r.returncode==0,(name,r.stdout,r.stderr)
        run(name,library,3)
    print(f'CHAIN_UART_READER_NEGATIVE_PASS mutants={len(edits)} original_fixtures={counts["cases"]} baseline=PASS')
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Only semantic disagreement with original fixtures counts as detection."""
import argparse,json,subprocess,sys
from pathlib import Path
from test_chain_work_stop_135 import ROOT,fixtures
def main():
    ap=argparse.ArgumentParser();ap.add_argument('output');ap.add_argument('--cc',required=True);ap.add_argument('--baseline',required=True);a=ap.parse_args()
    out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
    items,counts=fixtures()
    for _,result in items:result.pop('memory')
    fixture=out/'original.json';fixture.write_text(json.dumps(items))
    def run(name,library,expected):
        r=subprocess.run([sys.executable,str(ROOT/'integration/tests/test_chain_work_stop_135.py'),str(library),'--fixtures',str(fixture)],capture_output=True,text=True,timeout=60)
        (out/(name+'.log')).write_text(r.stdout+r.stderr)
        assert r.returncode==expected,(name,r.returncode,r.stdout[:300],r.stderr[:300])
        assert ('BASELINE_FIXTURES_PASS' if expected==0 else 'SEMANTIC_MISMATCH') in r.stdout,name
    run('baseline',Path(a.baseline).resolve(),0)
    source=(ROOT/'src/backend/work-gen/chain-work-stop.c').read_text()
    edits={
      'negative_getter':[('if (index >= 0)','if (1)')],
      'unsigned_count':[('if (index < count)','if ((uint32_t)index < (uint32_t)count)')],
      'fresh_validation_index':[('if (index < count)','if (*view->index < count)')],
      'stale_log_index':[('        index = *view->index;\n','')],
      'wrong_log_increment':[('(uint32_t)index + 1u','(uint32_t)index')],
      'flag_one_only':[('if (!view->worker->running)','if (view->worker->running != 1)')],
      'handle_gate':[('if (!view->worker->running)','if (!view->worker->handle)')],
      'late_queue_clear':[('            *view->head = 0;\n            *view->tail = 0;\n',''),('(void)ops->mutex(context, 0x5a66c4u, view->queue_mutex);','(void)ops->mutex(context, 0x5a66c4u, view->queue_mutex);\n            *view->head = 0;\n            *view->tail = 0;')],
      'omit_tail_clear':[('            *view->tail = 0;\n','')],
      'late_running_clear':[('            view->worker->running = 0;\n',''),('(void)ops->cancel(context, handle);','(void)ops->cancel(context, handle);\n            view->worker->running = 0;')],
      'stale_join_handle':[('ops->join(context, view->worker->handle, NULL)','ops->join(context, handle, NULL)')],
      'fail_fast_cancel':[('(void)ops->cancel(context, handle);','if (ops->cancel(context, handle)) return;')],
      'clear_handle':[('(void)ops->join(context, view->worker->handle, NULL);','(void)ops->join(context, view->worker->handle, NULL);\n            view->worker->handle = 0;')],
      'early_pointer_clear':[('ops->release(context, value);\n        *slot = NULL;','*slot = NULL;\n        ops->release(context, value);')],
      'keep_replacement_pointer':[('        *slot = NULL;\n','')],
      'release_null':[('if (value)','if (1)')],
      'early_pointer_capture':[('(void)ops->mutex(context, 0x5a6108u, view->chain_mutex);\n            clear_allocation(view->allocation, ops, context);','void *cached = *view->allocation;\n            (void)ops->mutex(context, 0x5a6108u, view->chain_mutex);\n            clear_allocation(&cached, ops, context);\n            *view->allocation = cached;')],
      'early_uart_method':[('int32_t index = *view->index;','uint32_t method = *view->uart_method;\n    int32_t index = *view->index;'),('ops->uart_destroy(context, *view->uart_method','ops->uart_destroy(context, method')],
      'omit_uart_cleanup':[('            ops->uart_destroy(context, *view->uart_method, view->uart);\n','')],
      'wrong_uart_object':[('ops->uart_destroy(context, *view->uart_method, view->uart)','ops->uart_destroy(context, *view->uart_method, view->chain_mutex)')],
    }
    for name,replacements in edits.items():
        changed=source
        for old,new in replacements:assert old in changed,(name,old);changed=changed.replace(old,new)
        path=out/(name+'.c');path.write_text(changed);library=out/(name+'.so')
        r=subprocess.run([a.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-O2','-shared','-fPIC',str(path),'libbitmain/src/uart.c','-o',str(library)],cwd=ROOT,capture_output=True,text=True)
        (out/(name+'-build.log')).write_text(r.stdout+r.stderr);assert r.returncode==0,(name,r.stdout,r.stderr)
        run(name,library,3)
    print(f'CHAIN_WORK_STOP_NEGATIVE_PASS mutants={len(edits)} original_fixtures={counts["cases"]} baseline=PASS')
if __name__=='__main__':main()

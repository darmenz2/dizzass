#!/usr/bin/env python3
"""Compiled mutants must disagree with original instructions, not crash."""
import argparse,json,subprocess,sys
from pathlib import Path
from test_work_stop_135 import ROOT,fixtures

def main():
    ap=argparse.ArgumentParser();ap.add_argument('output');ap.add_argument('--cc',required=True);ap.add_argument('--baseline',required=True);a=ap.parse_args()
    out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
    items,counts=fixtures()
    for _,result in items:result.pop('memory') # all event/final memory hashes retained
    fixture=out/'original.json';fixture.write_text(json.dumps(items))
    runner=ROOT/'integration/tests/test_work_stop_135.py'
    def run(name,library,expected):
        result=subprocess.run([sys.executable,str(runner),str(library),'--fixtures',str(fixture)],capture_output=True,text=True,timeout=60)
        (out/(name+'.log')).write_text(result.stdout+result.stderr)
        assert result.returncode==expected,(name,result.returncode,result.stdout[:400],result.stderr[:400])
        assert ('BASELINE_FIXTURES_PASS' if expected==0 else 'SEMANTIC_MISMATCH') in result.stdout,name
    run('baseline',Path(a.baseline).resolve(),0)
    source=(ROOT/'src/backend/work-gen/work-stop.c').read_text()
    edits={
      'gate_handle':[('if (thread->running)', 'if (thread->handle)')],
      'flag_one_only':[('if (thread->running)', 'if (thread->running == 1)')],
      'skip_zero_handle':[('if (thread->running)', 'if (thread->running && thread->handle)')],
      'late_flag_clear':[('        thread->running = 0;\n',''),('(void)ops->cancel(context, handle);','(void)ops->cancel(context, handle);\n        thread->running = 0;')],
      'clear_again':[('(void)ops->join(context, thread->handle, NULL);','(void)ops->join(context, thread->handle, NULL);\n        thread->running = 0;')],
      'clear_handle':[('(void)ops->join(context, thread->handle, NULL);','(void)ops->join(context, thread->handle, NULL);\n        thread->handle = 0;')],
      'stale_join_handle':[('ops->join(context, thread->handle, NULL)','ops->join(context, handle, NULL)')],
      'swap_threads':[('stop_thread(view->producer, ops, context);\n    stop_thread(view->receiver, ops, context);','stop_thread(view->receiver, ops, context);\n    stop_thread(view->producer, ops, context);')],
      'skip_nonpositive_cleanup':[('int32_t count = ops->chain_count(context);','int32_t count = ops->chain_count(context);\n    if (count <= 0) return 0;')],
      'fail_fast_cancel':[('(void)ops->cancel(context, handle);','if (ops->cancel(context, handle)) return;')],
      'fail_fast_destroy':[('(void)ops->destroy(context, 0x5a4954u, 0x633bc0u);','if (ops->destroy(context, 0x5a4954u, 0x633bc0u)) return -1;')],
      'wrong_object':[('0x5a4954u, 0x633bc0u','0x5a4954u, 0x633b08u')],
      'wrong_destroy_entry':[('0x5a4954u, 0x633bc0u','0x5a60b8u, 0x633bc0u')],
      'wrong_return':[('return 0;','return -1;')],
      'refresh_count':[('if (count > 0)', 'count = ops->chain_count(context);\n    if (count > 0)')],
      'cache_chain_base':[('if (count > 0)', 'const struct vn135_work_stop_chain *cached = view->chains;\n    if (count > 0)'),('&view->chains[i]','&cached[i]')],
      'cache_chain_method':[('if (count > 0)', 'uint32_t cached = view->chain_method;\n    if (count > 0)'),('ops->chain(context, view->chain_method','ops->chain(context, cached')],
      'enabled_one_only':[('if (*chain->enabled_318)', 'if (*chain->enabled_318 == 1)')],
      'omit_last_chain':[('i < (uint32_t)count','i + 1 < (uint32_t)count')],
    }
    for name,replacements in edits.items():
        changed=source
        for old,new in replacements:assert old in changed,(name,old);changed=changed.replace(old,new)
        path=out/(name+'.c');path.write_text(changed);library=out/(name+'.so')
        result=subprocess.run([a.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-O2','-shared','-fPIC',str(path),'-o',str(library)],cwd=ROOT,capture_output=True,text=True)
        (out/(name+'-build.log')).write_text(result.stdout+result.stderr)
        assert result.returncode==0,(name,result.stdout,result.stderr)
        run(name,library,3)
    print(f'WORK_STOP_NEGATIVE_PASS mutants={len(edits)} original_fixtures={counts["cases"]} baseline=PASS')
if __name__=='__main__':main()

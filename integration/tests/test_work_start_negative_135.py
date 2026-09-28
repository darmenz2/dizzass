#!/usr/bin/env python3
"""Each compiled mutation must semantically diverge from original fixtures."""
import argparse,json,subprocess,sys
from pathlib import Path
from test_work_start_135 import ROOT,fixtures

def main():
    ap=argparse.ArgumentParser();ap.add_argument('output');ap.add_argument('--cc',required=True);ap.add_argument('--baseline',required=True);a=ap.parse_args()
    out=Path(a.output).resolve();out.mkdir(parents=True,exist_ok=True)
    items,counts=fixtures();fixture=out/'original.json';fixture.write_text(json.dumps(items))
    runner=ROOT/'integration/tests/test_work_start_135.py'
    def run(name,library,expected):
        result=subprocess.run([sys.executable,str(runner),str(library),'--fixtures',str(fixture)],capture_output=True,text=True,timeout=60)
        (out/(name+'.log')).write_text(result.stdout+result.stderr)
        assert result.returncode==expected,(name,result.returncode,result.stdout[:400],result.stderr[:400])
        assert ('BASELINE_FIXTURES_PASS' if expected==0 else 'SEMANTIC_MISMATCH') in result.stdout,name
    run('baseline',Path(a.baseline).resolve(),0)
    source=(ROOT/'src/backend/work-gen/work-start.c').read_text()
    edits={
      'success_error':[('return 0;','return -1;')],
      'wrong_error_code':[('return -1;','return -2;')],
      'zero_scratch':[('view->attribute_initial','0u')],
      'wrong_clock':[('0x5a50f8u, &attribute, 1u','0x5a50f8u, &attribute, 0u')],
      'reject_init_error':[('(void)ops->attribute(context, 0x5a50e8u, &attribute, 0u);','if (ops->attribute(context, 0x5a50e8u, &attribute, 0u)) return -1;')],
      'missing_condition_attr':[('0x633bc0u, &attribute','0x633bc0u, NULL')],
      'missing_destroy':[('    (void)ops->attribute(context, 0x5a50e0u, &attribute, 0u);\n','')],
      'wrong_receiver':[('0u, 0xc4054u, view->backend','0u, 0xc4b18u, view->backend')],
      'constant_producer':[('*view->producer_entry','0xc2498u')],
      'early_producer':[('0u, *view->producer_entry, view->backend','0u, cached_entry, view->backend'),
          ('uint32_t attribute = view->attribute_initial;','uint32_t cached_entry = *view->producer_entry;\n    uint32_t attribute = view->attribute_initial;')],
      'wrong_sender_handle':[('view->thread_1058','view->thread_1068')],
      'positive_only_errors':[('view->backend)) {','view->backend) > 0) {')],
      'continue_after_failure':[('start_log(ops, context, 0x31du, 0x5e96d3u);\n        return -1;','start_log(ops, context, 0x31du, 0x5e96d3u);')],
      'missing_producer_log':[('        start_log(ops, context, 0x322u, 0x5e96fdu);\n','')],
      'wrong_failure_message':[('0x322u, 0x5e96fdu','0x322u, 0x5e9758u')],
      'clear_failed_handle':[('start_log(ops, context, 0x31du, 0x5e96d3u);','*view->thread_1060 = 0;\n        start_log(ops, context, 0x31du, 0x5e96d3u);')],
      'worker_attr_nonzero':[('view->thread_1068, 0u','view->thread_1068, 1u')],
      'duplicate_mutex':[('0x633ba8u, NULL','0x633af0u, NULL')],
    }
    for name,replacements in edits.items():
        changed=source
        for old,new in replacements:assert old in changed,(name,old);changed=changed.replace(old,new)
        path=out/(name+'.c');path.write_text(changed);library=out/(name+'.so')
        result=subprocess.run([a.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-O2','-shared','-fPIC',str(path),'-o',str(library)],cwd=ROOT,capture_output=True,text=True)
        assert result.returncode==0,(name,result.stdout,result.stderr)
        run(name,library,3)
    print(f'WORK_START_NEGATIVE_PASS mutants={len(edits)} original_fixtures={counts["cases"]} baseline=PASS')
if __name__=='__main__':main()

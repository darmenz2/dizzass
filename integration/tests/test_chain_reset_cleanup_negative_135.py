#!/usr/bin/env python3
"""Only compiled semantic mismatches count as rejecting a mutant."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'src/backend/chain-reset-cleanup.c'
MUTANTS={
    'preserve_detected':('view->chain->detected_8c = 0;','(void)view->chain->detected_8c;'),
    'omit_tail':('memset(view->statistics_tail_6c, 0, sizeof(view->statistics_tail_6c));','(void)view->statistics_tail_6c;'),
    'always_state2':('if ((uint32_t)(chain->state - 3u) >= 3u)','if (1)'),
    'wrong_chip_count':('i < model->expected_chips_48','i < chain->chip_count + (model->expected_chips_48 & 0)'),
    'wrong_sensor_count':('sensor_count = view->backend->model->sensor_count;','sensor_count = chain->sensor_count;'),
    'cached_model':('model = view->backend->model;','model = captured;'),
    'one_clock':('view->time_78 = ops->now(opaque);','view->time_78 = view->time_70;'),
    'clock_order':('view->time_70 = ops->now(opaque);\n    view->time_78 = ops->now(opaque);','view->time_78 = ops->now(opaque);\n    view->time_70 = ops->now(opaque);'),
    'clear_kind3':('sensor->access_kind == 0 || sensor->access_kind == 3 ||','sensor->access_kind == 0 ||'),
    'invert_kind4_flag':('sensor->access_kind == 4 && !sensor->skip_initial_read','sensor->access_kind == 4 && sensor->skip_initial_read'),
    'clear_local_offset':('sensor->remote_offset = 0;','sensor->remote_offset = 0; sensor->local_offset = 0;'),
    'skip_on_lock_error':('(void)stop->lock(opaque, chain);','if (stop->lock(opaque, chain)) return;'),
    'aggregate_before_unlock':('(void)stop->unlock(opaque, chain);\n    ops->aggregate(opaque, chain);','ops->aggregate(opaque, chain);\n    (void)stop->unlock(opaque, chain);'),
    'skip_aggregate_on_unlock_error':('(void)stop->unlock(opaque, chain);','if (stop->unlock(opaque, chain)) return;'),
}

def main():
    p=argparse.ArgumentParser();p.add_argument('--cc',default='cc');p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=True);source=SOURCE.read_text();records=[]
    for name,mutation in [('baseline',None),*MUTANTS.items()]:
        text=source
        if mutation:
            old,new=mutation;assert text.count(old)==1,name;text=text.replace(old,new)
            if name=='cached_model':
                text=text.replace('struct vn135_general_model *model;','struct vn135_general_model *model;\n    struct vn135_general_model *captured = view->backend->model;')
        src,lib=out/(name+'.c'),out/(name+'.so');src.write_text(text)
        build=subprocess.run([a.cc,'-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
            '-DVN135_CHAIN_RESET_CLEANUP_135','-shared','-fPIC',str(src),'src/backend/chain.c','-Wl,-z,defs','-o',str(lib)],cwd=ROOT,capture_output=True,text=True,timeout=45)
        (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
        assert build.returncode==0,(name,build.stderr)
        result=subprocess.run([sys.executable,'integration/tests/test_chain_reset_cleanup_135.py',str(lib),'--quick'],cwd=ROOT,capture_output=True,text=True,timeout=45)
        (out/(name+'.log')).write_text(result.stdout+result.stderr)
        if mutation:
            assert result.returncode==1 and "AssertionError: ('MISMATCH'," in result.stderr,(name,result.returncode,result.stderr)
        else:assert result.returncode==0 and 'CHAIN_RESET_CLEANUP135_ORIGINAL_PASS' in result.stdout
        records.append(dict(name=name,build_exit=build.returncode,test_exit=result.returncode))
    report=dict(status='PASS',rejected=len(MUTANTS),compiler=a.cc,records=records)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print('CHAIN_RESET_CLEANUP135_NEGATIVE_PASS',json.dumps(report))
if __name__=='__main__':main()

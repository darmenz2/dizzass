#!/usr/bin/env python3
"""Each mutant must compile, then fail specifically by an oracle mismatch."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
ROOT = Path(__file__).resolve().parents[2]
SOURCE = 'src/backend/throttling-reset.c'
MUTANTS = {
    'drop_platform_7': ('platform != 7 && platform != 4', 'platform != 4'),
    'allow_platform_2': ('platform != 7 && platform != 4', 'platform != 7 && platform != 4 && platform != 2'),
    'capture_model_early': (
        'int32_t count = ops->chain_count(opaque);\n    struct vn135_throttling_reset_model *model = view->model;',
        'struct vn135_throttling_reset_model *model = view->model;\n    int32_t count = ops->chain_count(opaque);'),
    'capture_model_late': (
        'struct vn135_throttling_reset_model *model = view->model;\n    int32_t platform = ops->platform(opaque);',
        'int32_t platform = ops->platform(opaque);\n    struct vn135_throttling_reset_model *model = view->model;'),
    'swap_size_family': ('case 0: length = model->count_60 << 3;', 'case 0: length = model->count_50 << 3;'),
    'skip_zero_length_call': ('ops->zero(opaque, row, length);', 'if (length) ops->zero(opaque, row, length);'),
    'empty_count_skips_lock': ('(void)ops->lock(opaque, view->mutex);', 'if (count < 1) return;\n    (void)ops->lock(opaque, view->mutex);'),
    'lock_error_aborts': ('(void)ops->lock(opaque, view->mutex);', 'if (ops->lock(opaque, view->mutex)) return;'),
    'last_group_times_eight': (
        'length = (uint32_t)model->general->expected_chips_48;\n                    break;',
        'length = (uint32_t)model->general->expected_chips_48 << 3;\n                    break;'),
    'no_unlock': ('(void)ops->unlock(opaque, view->mutex);', '(void)view->mutex;'),
}
def main():
    p=argparse.ArgumentParser();p.add_argument('--cc',default='cc');p.add_argument('--out',required=True)
    a=p.parse_args();out=Path(a.out).resolve();out.mkdir(parents=True,exist_ok=True)
    source=(ROOT/SOURCE).read_text();env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1')
    for name,(old,new) in MUTANTS.items():
        assert source.count(old)==1,name
        src=out/(name+'.c');lib=out/(name+'.so');src.write_text(source.replace(old,new))
        command=[a.cc,'-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
                 '-DVN135_THROTTLING_RESET_135','-DVN135_MINING_STOP_135','-shared','-fPIC',
                 str(src),'src/backend/base.c','-Wl,-z,defs','-o',str(lib)]
        subprocess.run(command,cwd=ROOT,check=True,timeout=30,env=env)
        result=subprocess.run([sys.executable,'integration/tests/test_throttling_reset_135.py',str(lib),'--quick'],
                              cwd=ROOT,capture_output=True,text=True,timeout=30,env=env)
        (out/(name+'.log')).write_text(result.stdout+result.stderr)
        assert result.returncode==1 and "AssertionError: ('MISMATCH'," in result.stderr, (name,result.returncode,result.stderr)
        print(name, 'REJECTED_BY_ORIGINAL',flush=True)
    print('THROTTLING_RESET135_NEGATIVE_PASS',len(MUTANTS))
if __name__=='__main__':main()

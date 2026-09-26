#!/usr/bin/env python3
"""Temporary faulty C variants must be rejected by the unmodified ELF oracle."""
import argparse
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
FLAGS=['-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
       '-fno-fast-math','-ffp-contract=off','-DVN135_GENERAL_MONITOR_135',
       '-DVN135_MONITOR_HANDLERS_135','-DVN135_BACKEND_SHUTDOWN_135',
       '-DVN135_STOP_POLICY_135','-DVN135_EXIT_CLEANUP_135']

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True)
    a=ap.parse_args();out=Path(a.out).resolve();out.mkdir(parents=True,exist_ok=True)
    text=(ROOT/'src/backend/base.c').read_text()
    mark='\n/* Original pre-exit teardown 5f0fc, distinct from common shutdown 5fc54. */'
    prefix,body=text.split(mark)
    # All four changes are confined to copies in the build directory. Neither
    # the checked-in C, the ELF nor the oracle is modified by these tests.
    faults=[('wrong_state','s->state=4;','s->state=6;'),
            ('wrong_mode','EXIT_STEP(0xf98b8,2)','EXIT_STEP(0xf98b8,1)'),
            ('skip_worker','i=5;i<9','i=5;i<8'),
            ('omit_parent_cleanup','(void)EXIT_STEP(0x287a4,0);','/* omitted intentionally */')]
    for name,old,new in faults:
        assert body.count(old)==1,(name,old)
        source=out/(name+'.c');library=out/(name+'.so')
        source.write_text(prefix+mark+body.replace(old,new))
        subprocess.run([a.cc,*FLAGS,'-shared','-fPIC',str(source),'-Wl,-z,defs','-o',str(library)],cwd=ROOT,check=True)
        run=subprocess.run([sys.executable,'integration/tests/test_exit_cleanup_135.py',str(library),'--quick'],
                           cwd=ROOT,capture_output=True,text=True,timeout=30)
        (out/(name+'.log')).write_text(run.stdout+run.stderr)
        assert run.returncode!=0 and 'original/native mismatch' in run.stderr,(name,run.returncode,run.stdout,run.stderr)
        print('EXIT_CLEANUP135_NEGATIVE_REJECTED',name)
    print('EXIT_CLEANUP135_NEGATIVE_PASS rejected=4 original_oracle_unchanged=true')
if __name__=='__main__':main()

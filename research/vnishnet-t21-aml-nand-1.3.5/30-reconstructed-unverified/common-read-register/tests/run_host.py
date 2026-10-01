#!/usr/bin/env python3
"""Compile actual source units separately, then run the bounded host suite."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

SOURCES=['libbitmain/src/chip/chip.c','integration/bm1368_control.c','reconstruction/support/crc5.c',
         'libbitmain/src/transport-dispatch.c','libbitmain/src/aml/chip.c','libbitmain/src/uart.c',
         'libbitmain/src/chip/chip1368.c']

def checked(command,**kwargs):
    result=subprocess.run(command,capture_output=True,text=True,**kwargs)
    if result.returncode:
        sys.stderr.write(result.stdout+result.stderr)
        result.check_returncode()
    return result

def main():
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True)
    p.add_argument('--test',type=Path,required=True);p.add_argument('--build',type=Path,required=True)
    p.add_argument('--cc',default=os.environ.get('CC','cc'));p.add_argument('--sanitize',action='store_true')
    a=p.parse_args();root=a.root.resolve();build=a.build.resolve();build.mkdir(parents=True,exist_ok=True)
    flags=['-I'+str(root),'-I'+str(root/'include'),'-std=c11','-O1' if a.sanitize else '-O2','-g',
           '-Wall','-Wextra','-Wpedantic','-Werror','-Wconversion','-Wshadow',
           '-DVN135_COMMON_READ_REGISTER_135','-DVN135_TRANSPORT_DISPATCH_135',
           '-DVN135_TRANSPORT_INITIALIZE_135','-DVN135_BM1368_INITIALIZE_135']
    san=['-fsanitize=address,undefined','-fno-omit-frame-pointer','-fno-pie'] if a.sanitize else []
    records=[];objects=[]
    for i,path in enumerate([root/s for s in SOURCES]+[a.test.resolve()]):
        extra=[]
        if a.sanitize and path==root/'reconstruction/support/crc5.c':
            # GCC 14 ASan/-O1 warns about unsigned conversion of a promoted
            # uint8_t right shift. Its value is always 0..255, hence nonnegative.
            # Preserve the pinned helper; only this unchanged TU receives the
            # narrow warning exception. All units remain ASan/UBSan instrumented.
            extra=['-Wno-sign-conversion']
        obj=build/f'unit-{i}.o';cmd=[a.cc,*flags,*san,*extra,'-c',str(path),'-o',str(obj)]
        checked(cmd,timeout=45)
        records.append({'source':str(path),'command':cmd});objects.append(str(obj))
    exe=build/'test-common-read';cmd=[a.cc,*san,*(['-no-pie'] if a.sanitize else []),*objects,'-o',str(exe)]
    checked(cmd,timeout=30)
    env=dict(os.environ)
    if a.sanitize:env.update(ASAN_OPTIONS='detect_leaks=0:halt_on_error=1',UBSAN_OPTIONS='halt_on_error=1')
    result=checked([str(exe)],timeout=30,env=env)
    if 'COMMON_READ_PASS' not in result.stdout:raise ValueError('missing pass marker')
    (build/'compile-records.json').write_text(json.dumps(records,indent=2)+'\n')
    print(result.stdout,end='')

if __name__=='__main__':main()

#!/usr/bin/env python3
"""Reject four wrong-key implementations by original/C mismatch, not crashes."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'libbitmain/src/chip/chip1368-reply-key.c'
FLAGS=['-I.','-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror',
       '-fno-fast-math','-ffp-contract=off']
FLAGS += ['-D'+x for x in ('VN135_GENERAL_MONITOR_135','VN135_MONITOR_HANDLERS_135',
 'VN135_BACKEND_SHUTDOWN_135','VN135_STOP_POLICY_135','VN135_EXIT_CLEANUP_135',
 'VN135_BM1368_REPLY_KEY_135')]
MUTANTS={'false_success_zero':'0u','adjacent_key_40':'0x40u',
         'wrong_high_byte':'0x144u','signed_error_as_key':'0xffffffffu'}
def main():
 p=argparse.ArgumentParser();p.add_argument('--cc',default='cc');p.add_argument('--out',type=Path,required=True)
 a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=True)
 original=SOURCE.read_text();assert original.count('return 0x44u;')==1
 results=[]
 for name,value in [('baseline',None),*MUTANTS.items()]:
  src=out/(name+'.c');lib=out/(name+'.so')
  src.write_text(original if value is None else original.replace('return 0x44u;','return '+value+';'))
  command=[a.cc,*FLAGS,'-shared','-fPIC',str(src),'src/backend/base.c','-Wl,-z,defs','-o',str(lib)]
  build=subprocess.run(command,cwd=ROOT,capture_output=True,text=True,timeout=30)
  (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
  if build.returncode:raise RuntimeError((name,'must compile',build.stderr))
  run=subprocess.run([sys.executable,'integration/tests/test_bm1368_reply_key_135.py',str(lib),'--quick'],
      cwd=ROOT,capture_output=True,text=True,timeout=30)
  (out/(name+'.log')).write_text(run.stdout+run.stderr)
  if value is None:
   assert run.returncode==0 and 'BM1368_REPLY_KEY135_ORIGINAL_PASS' in run.stdout
  else:
   assert run.returncode==1 and "MISMATCH', 'getter'" in run.stderr,(name,run.returncode,run.stderr)
  results.append({'name':name,'build_exit':build.returncode,'test_exit':run.returncode})
 report={'status':'PASS','compiler':a.cc,'rejected':len(MUTANTS),'results':results}
 (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
 print('BM1368_REPLY_KEY135_NEGATIVE_PASS',json.dumps(report))
if __name__=='__main__':main()

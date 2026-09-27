#!/usr/bin/env python3
"""Compile semantic mutations; only an explicit original mismatch rejects them."""
import argparse
import json
from pathlib import Path
import shlex
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
MUTANTS={
 'wrong_skip':('if (*binding->skip_654b22 != 0)','if (*binding->skip_654b22 == 0)'),
 'wrong_register_mask':('~UINT32_C(0x00400000)','~UINT32_C(0x00800000)'),
 'wrong_flags_mask':('~UINT32_C(0x00000040)','~UINT32_C(0x00000080)'),
 'wrong_index':('read_register(opaque, 27u)','read_register(opaque, 28u)'),
 'skip_rechecked':('word = ops->read_flags(opaque);','if (*binding->skip_654b22 != 0) return;\n    word = ops->read_flags(opaque);'),
 'missing_final_write':('(void)ops->write_flags(opaque, word & ~UINT32_C(0x00000040));','(void)word;'),
 'extra_dispatch':('slot->invoke(slot->context);','slot->invoke(slot->context); slot->invoke(slot->context);'),
 'early_flags_read':('word = ops->read_register(opaque, 27u);','(void)ops->read_flags(opaque);\n    word = ops->read_register(opaque, 27u);'),
}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True);a=ap.parse_args()
 out=Path(a.out).resolve();out.mkdir(parents=True,exist_ok=True)
 source=(ROOT/'libbitmain/src/platform-stop.c').read_text()
 probe='include integration/platform-stop-135.mk\nprint:\n\t@echo $(PLATFORM135_FLAGS)\n\t@echo $(MINING135_SOURCES)\n'
 lines=subprocess.check_output(['make','-s','-f','-','print'],input=probe,text=True,cwd=ROOT).splitlines()
 flags=shlex.split(lines[0]);sources=shlex.split(lines[1]);results=[]
 for name,(old,new) in MUTANTS.items():
  assert source.count(old)==1,(name,'nonunique')
  path=out/(name+'.c');path.write_text(source.replace(old,new));lib=out/(name+'.so')
  cmd=shlex.split(a.cc)+flags+['-shared','-fPIC',str(path),*sources,'-Wl,-z,defs','-o',str(lib)]
  build=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=45)
  (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
  assert build.returncode==0,(name,'BUILD_FAILED',build.stderr)
  run=subprocess.run([sys.executable,'integration/tests/test_platform_stop_135.py',str(lib),'--quick'],cwd=ROOT,capture_output=True,text=True,timeout=30)
  (out/(name+'.log')).write_text(run.stdout+run.stderr)
  assert run.returncode==1 and 'SEMANTIC_MISMATCH' in run.stderr,(name,'NOT_SEMANTIC_REJECTION',run.returncode,run.stderr)
  results.append(dict(name=name,compiled=True,rejected=True,exit_code=run.returncode))
 (out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
 print('PLATFORM_STOP135_NEGATIVE_PASS',len(results))
if __name__=='__main__':main()

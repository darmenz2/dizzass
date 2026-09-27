#!/usr/bin/env python3
"""Compile separate semantic mutants; require an actual oracle mismatch.
Never change the working tree, original ELF, interpreter or comparison logic.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
ROOT=Path(__file__).resolve().parents[2]
BIND='reconstruction/support/sensor_cleanup_binding_135.c'
CLEAN='reconstruction/support/sensor_cleanup_135.c'
RESET='src/backend/temp.c'
SOURCES=['src/backend/base.c',RESET,CLEAN,BIND]
FLAGS=['-I.','-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror','-fno-fast-math','-ffp-contract=off']
FLAGS += ['-DVN135_'+s+'_135' for s in ('GENERAL_MONITOR','MONITOR_HANDLERS','BACKEND_SHUTDOWN','STOP_POLICY','EXIT_CLEANUP','SENSOR_CLEANUP_BINDING')]
MUTANTS=[
 ('wrong_count',BIND,'count = model->sensor_count;','count = chain->sensor_count; (void)model;'),
 ('wrong_chain',BIND,'chains[index].thermal','chains[0].thermal'),
 ('drop_reset',BIND,'vn135_temperature_chain_cleanup_135(chain, count,','vn135_temperature_chain_cleanup_135(chain, 0,'),
 ('clamp_count',BIND,'count = model->sensor_count;','count = model->sensor_count > 1 ? 1 : model->sensor_count;'),
 ('lost_presence',CLEAN,'if(!chain->present)return;','if(0)return;'),
 ('only_state_one',CLEAN,'if(chain->sensors[i].state)','if(chain->sensors[i].state==1)'),
 ('clear_failures',RESET,'s->remote_offset=0;s->sample=0;','s->failures=0;s->remote_offset=0;s->sample=0;'),
 ('init_failure_early_return',RESET,'(void)o->mutex_init(p,s);','if(o->mutex_init(p,s))return;'),
 ('clear_sample_timestamp',RESET,'s->remote_offset=0;s->sample=0;','s->sampled_at=0;s->remote_offset=0;s->sample=0;'),
]
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True);args=ap.parse_args()
 out=Path(args.out).resolve();out.mkdir(parents=True,exist_ok=True);results=[]
 for name,path,old,new in MUTANTS:
  text=(ROOT/path).read_text();assert text.count(old)==1,(name,text.count(old))
  mutant=out/(name+'.c');mutant.write_text(text.replace(old,new))
  lib=out/(name+'.so');sources=[str(mutant) if p==path else p for p in SOURCES]
  build=subprocess.run([args.cc,*FLAGS,'-shared','-fPIC',*sources,'-Wl,-z,defs','-o',str(lib)],cwd=ROOT,capture_output=True,text=True,timeout=30)
  (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
  assert build.returncode==0,('MUTANT_BUILD_FAILED',name,build.stderr)
  run=subprocess.run([sys.executable,str(ROOT/'integration/tests/test_sensor_cleanup_binding_135.py'),str(lib)],cwd=ROOT,capture_output=True,text=True,timeout=40)
  (out/(name+'.test.log')).write_text(run.stdout+run.stderr)
  assert run.returncode==1 and 'SENSOR_CLEANUP_ORIGINAL_MISMATCH' in run.stderr,('NOT_A_SEMANTIC_REJECTION',name,run.returncode,run.stderr[-1500:])
  results.append({'name':name,'compiled':True,'exit':run.returncode,'oracle_mismatch':True})
 (out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
 print('SENSOR_CLEANUP_BINDING135_NEGATIVE_PASS',len(results),args.cc)
if __name__=='__main__':main()

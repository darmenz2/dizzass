#!/usr/bin/env python3
"""Compiled adapter mutants must fail original/C comparison, not crash/build."""
import argparse,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'integration/native/resume_temperature_135.c'
MUTANTS={
 'drop_temperature_error':('return vn135_temperature_start_composition_135(s->temperature,s->temperature_ops,s->context);','{ (void)vn135_temperature_start_composition_135(s->temperature,s->temperature_ops,s->context); return 0; }'),
 'shift_temperature_boundary':('if(e==VN135_R_CONFIG_6EC4C)','if(e==VN135_R_CONFIG_6E734)'),
 'lose_scalar_argument':('s->resume->step(s->context,e,a,b,c)','s->resume->step(s->context,e,0,b,c)'),
 'wrong_thread_entry':('s->resume->thread_create(s->context,off,entry,handle)','s->resume->thread_create(s->context,off,entry+4u,handle)'),
 'discard_create_error':('return s->resume->thread_create(s->context,off,entry,handle);','(void)s->resume->thread_create(s->context,off,entry,handle); return 0;'),
 'discard_handle_write':('return s->resume->thread_create(s->context,off,entry,handle);','uintptr_t temporary=*handle;return s->resume->thread_create(s->context,off,entry,&temporary);'),
 'lose_join_scratch':('return s->resume->thread_join(s->context,handle,result);','uintptr_t temporary=0;(void)result;return s->resume->thread_join(s->context,handle,&temporary);'),
 'lose_release':('s->resume->release(s->context,text);','(void)s;(void)text;'),
 'wrong_voltage':('s->power->set_voltage(s->context,v)','s->power->set_voltage(s->context,(uint16_t)(v+1u))'),
 'zero_timestamp':('return s->resume->timestamp(s->context);','(void)s->resume->timestamp(s->context);return 0.0;'),
}
def main():
 p=argparse.ArgumentParser();p.add_argument('--cc',default='cc');p.add_argument('--deps',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=True);deps=a.deps.resolve();source=SOURCE.read_text();records=[]
 flags=['-I'+str(deps),'-I.','-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror','-fno-fast-math','-ffp-contract=off','-DRT135_LIBRARY','-shared','-fPIC']
 flags += ['-D'+x for x in ('VN135_GENERAL_MONITOR_135','VN135_MONITOR_HANDLERS_135','VN135_CHAIN_TEMPERATURE_SETUP_135','VN135_CHIP_SENSOR_CHECK_135','VN135_BACKEND_SHUTDOWN_135')]
 sources=[str(deps/'integration/native/temperature_start_composition_135.c')]+[str(deps/'src/backend'/x) for x in ('temperature-setup.c','chain-temperature-setup.c','chip-sensor-check.c')]+['src/backend/base.c','src/backend/temp.c','integration/tests/test_resume_temperature_135.c']
 for name,change in [('baseline',None),*MUTANTS.items()]:
  data=source
  if change:
   old,new=change
   if data.count(old)!=1:raise RuntimeError(('mutation no longer unique',name))
   data=data.replace(old,new)
   # Removing a forwarded value must remain compilable under -Werror.
   if name=='lose_scalar_argument':data=data.replace('struct binding *s=p;\n    if(e==','struct binding *s=p;(void)a;\n    if(e==')
  path=out/(name+'.c');so=out/(name+'.so');path.write_text(data)
  build=subprocess.run([a.cc,*flags,str(path),*sources,'-Wl,-z,defs','-o',str(so)],cwd=ROOT,capture_output=True,text=True,timeout=45)
  (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
  if build.returncode:raise RuntimeError((name,'must compile',build.stderr))
  run=subprocess.run(['python3','integration/tests/test_resume_temperature_135.py',str(so),'--witnesses'],cwd=ROOT,capture_output=True,text=True,timeout=45)
  (out/(name+'.log')).write_text(run.stdout+run.stderr)
  if change:
   if run.returncode!=1 or 'SEMANTIC_MISMATCH' not in run.stdout:raise RuntimeError((name,'not a semantic rejection',run.returncode,run.stdout,run.stderr))
  elif run.returncode or 'RESUME_TEMPERATURE135_ORIGINAL_PASS' not in run.stdout:raise RuntimeError(('baseline failed',run.stdout,run.stderr))
  records.append({'name':name,'compile_exit':build.returncode,'run_exit':run.returncode})
 report={'status':'PASS','compiler':a.cc,'rejected':len(MUTANTS),'records':records,'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest()}
 (out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print('RESUME_TEMPERATURE135_NEGATIVE_PASS',json.dumps(report))
if __name__=='__main__':main()

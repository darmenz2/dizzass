#!/usr/bin/env python3
"""Wrong semantics must compile and fail on the original/C comparison."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE='src/backend/chain-temperature-setup.c'
MUTANTS={
 'presence_removed': [('!chain->present ||','0 ||')],
 'state5_not_skipped': [('(chain->state - 3u) < 3u','(chain->state - 3u) < 2u')],
 'cached_route_count': [('count = model->sensor_count;','count = chain->sensor_count; (void)model;')],
 'kind0_not_skipped': [('kind == 0u','kind == 99u')],
 'kind3_not_skipped': [('kind == 3u','kind == 33u')],
 'kind4_gate_inverted': [('!sensor->skip_initial_read','sensor->skip_initial_read')],
 'positive_error_ignored': [('if (!ops->initialize(opaque, chain, sensor))','if (ops->initialize(opaque, chain, sensor) >= 0)')],
 'state_before_diagnostic': [('        if (ops->log)','        sensor->state = 3;\n        if (ops->log)')],
 'cached_role': [('uint32_t kind = sensor->access_kind;','uint32_t kind = sensor->access_kind, role = sensor->role;'),('mode == 2u || sensor->role == 2u','mode == 2u || role == 2u')],
 'truncated_mode': [('mode == 2u','(mode & 255u) == 2u')],
 'ignore_role_failure': [('mode == 2u || sensor->role == 2u','mode == 2u')],
 'always_fail': [('mode == 2u || sensor->role == 2u','(void)mode, 1')],
 'cached_sensor_bank': [('    for (i = 0; i < count; ++i)', '    struct vn135_temperature_sensor *bank = chain->sensors;\n    for (i = 0; i < count; ++i)'),('&chain->sensors[i]','&bank[i]')],
 'count_rechecked': [('i < count;', 'i < count && i < model->sensor_count;')],
 'lost_captured_sensor': [('        if (ops->log)','        sensor = &chain->sensors[i];\n        if (ops->log)')],
}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True);a=ap.parse_args()
 out=Path(a.out).resolve();out.mkdir(parents=True,exist_ok=True)
 text=(ROOT/SOURCE).read_text();records=[]
 for name,replacements in [('baseline',[]),*MUTANTS.items()]:
  candidate=text
  for old,new in replacements:
   assert candidate.count(old)==1,(name,old)
   candidate=candidate.replace(old,new)
  src=out/(name+'.c');lib=out/(name+'.so');src.write_text(candidate)
  cmd=[a.cc,'-I.','-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror','-DVN135_CHAIN_TEMPERATURE_SETUP_135','-shared','-fPIC',str(src),'src/backend/temp.c','-Wl,-z,defs','-o',str(lib)]
  build=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30)
  (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
  assert build.returncode==0,(name,'build must pass',build.stderr)
  result=subprocess.run(['python3','integration/tests/test_chain_temperature_setup_135.py',str(lib),'--quick'],cwd=ROOT,capture_output=True,text=True,timeout=30)
  (out/(name+'.log')).write_text(result.stdout+result.stderr)
  if name=='baseline':assert result.returncode==0 and 'ORIGINAL_PASS' in result.stdout,(name,result.stderr)
  else:assert result.returncode==1 and 'SEMANTIC_MISMATCH' in result.stderr,(name,result.returncode,result.stderr)
  records.append(dict(name=name,build_exit=build.returncode,test_exit=result.returncode))
 report=dict(status='PASS',compiler=a.cc,rejected=len(MUTANTS),witnesses=17,source_sha256=hashlib.sha256((ROOT/SOURCE).read_bytes()).hexdigest(),records=records)
 (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
 print('CHAIN_TEMPERATURE_SETUP135_NEGATIVE_PASS',json.dumps(report,sort_keys=True))
if __name__=='__main__':main()

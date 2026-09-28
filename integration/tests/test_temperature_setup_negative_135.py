#!/usr/bin/env python3
"""Require a passing baseline and compiled semantic MISMATCH, not crashes."""
import argparse, hashlib, json, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'src/backend/temperature-setup.c'
MUTANTS={
 'miss_kind1':('!has_kind(s->description, 1u)', '!has_kind(s->description, 4u)'),
 'miss_kind2':('!has_kind(s->description, 2u)', '!has_kind(s->description, 3u)'),
 'invert_init_result':('if (!o->initialize_chain(p, chain, g->mode)) continue;', 'if (o->initialize_chain(p, chain, g->mode)) continue;'),
 'invert_suppression':('if (!g->suppress_thermal)', 'if (g->suppress_thermal)'),
 'propagate_stop_error':('(void)o->stop_chain(p, chain, "Failed to init temp sensors");', 'return o->stop_chain(p, chain, "Failed to init temp sensors");'),
 'use_current_chain_for_stop':('o->stop_chain(p, chain, "Failed to init temp sensors")', 'o->stop_chain(p, &g->chains[i].thermal, "Failed to init temp sensors")'),
 'register_wrong_kind':('if (has_kind(s->description, 2u)) {', 'if (has_kind(s->description, 1u)) {'),
 'truncate_key':('uint32_t key = o->reply_key(p);', 'uint32_t key = o->reply_key(p) & 255u;'),
 'wrong_role':('s->roles[i] == 2u', 's->roles[i] == 3u'),
 'invert_chip_result':('selected && !o->check_chip_sensors(p, g)', 'selected && o->check_chip_sensors(p, g)'),
 'ignore_chain_decision':('if (vn135_monitor_chain_decision_135(s->backend, h, p)) return -1;', '(void)vn135_monitor_chain_decision_135(s->backend, h, p);'),
 'cache_final_count':('    count = h->call(p, VN135_H_CHAIN_COUNT, 0, 0);', '    count = initial_count;'),
}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
 out=a.out.resolve();out.mkdir(parents=True,exist_ok=True);source=SOURCE.read_text();records=[]
 for name,mutation in [('baseline',None),*MUTANTS.items()]:
  content=source
  if mutation:
   old,new=mutation;assert source.count(old)==1,(name,source.count(old));content=source.replace(old,new)
  path=out/(name+'.c');lib=out/(name+'.so');path.write_text(content)
  command=[a.cc,'-I.','-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror','-fno-fast-math','-ffp-contract=off','-DVN135_GENERAL_MONITOR_135','-DVN135_MONITOR_HANDLERS_135','-shared','-fPIC',str(path),'src/backend/base.c','-Wl,-z,defs','-o',str(lib)]
  build=subprocess.run(command,cwd=ROOT,text=True,capture_output=True,timeout=45)
  (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
  assert build.returncode==0,(name,'BUILD_ERROR',build.stderr)
  run=subprocess.run(['python3','integration/tests/test_temperature_setup_135.py',str(lib),'--quick'],cwd=ROOT,text=True,capture_output=True,timeout=45)
  (out/(name+'.log')).write_text(run.stdout+run.stderr)
  if mutation:assert run.returncode==1 and 'TEMPERATURE_SETUP135_MISMATCH' in run.stderr,(name,'NOT_SEMANTIC_REJECTION',run.returncode,run.stderr)
  else:assert run.returncode==0 and 'TEMPERATURE_SETUP135_ORIGINAL_PASS' in run.stdout,('BASELINE_FAILED',run.stderr)
  records.append(dict(name=name,build_exit=build.returncode,test_exit=run.returncode))
 report=dict(status='PASS',compiler=a.cc,rejected=len(MUTANTS),source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),records=records)
 (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
 print('TEMPERATURE_SETUP135_NEGATIVE_PASS',json.dumps(report))
if __name__=='__main__':main()

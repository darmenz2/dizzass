#!/usr/bin/env python3
"""Full local check with isolated per-command logs and bounded parallel groups.
Use on a fresh extraction. Source files stay unchanged; build outputs are local.
No network, firmware install, ASIC access or original ELF process execution.
"""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor,as_completed
import argparse,hashlib,json,subprocess,sys,time
from verify_stage13 import GROUPS
ROOT=Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--logs',type=Path,required=True)
    p.add_argument('--workers',type=int,default=2,choices=[1,2]);a=p.parse_args();logs=a.logs.resolve()
    if logs.is_relative_to(ROOT):p.error('Logs must be outside the source tree')
    logs.mkdir(parents=True,exist_ok=True);started=time.monotonic();done={};supplemental=[]
    def run(group):
        with (logs/(group+'-driver.log')).open('w') as f:
            rc=subprocess.run([sys.executable,'tools/verify_stage13.py',group,'--logs',str(logs)],cwd=ROOT,stdout=f,stderr=subprocess.STDOUT).returncode
        file=logs/(group+'.json')
        row=json.loads(file.read_text()) if file.exists() else {'group':group,'status':'FAIL','complete':False,'records':[]}
        row['driver_returncode']=rc
        print(group,row['status'],'complete='+str(row['complete']),flush=True)
        return group,row
    group,row=run('build');done[group]=row
    if row['status']=='PASS':
        # Build shared Clang library once before independent Clang groups.
        with (logs/'clang-library-prebuild.log').open('w') as f:
            rc=subprocess.run(['make','-f','Makefile.recovery','build/libvn135_recovered-clang.so'],cwd=ROOT,stdout=f,stderr=subprocess.STDOUT).returncode
        supplemental.append({'command':['make','-f','Makefile.recovery','build/libvn135_recovered-clang.so'],'returncode':rc,'log':'clang-library-prebuild.log','sha256':hashlib.sha256((logs/'clang-library-prebuild.log').read_bytes()).hexdigest()})
        if rc:print('Clang library build failed',flush=True);return rc
        pending=[g for g in GROUPS if g not in ('build','evidence','full-runtime-blocked')]
        with ThreadPoolExecutor(max_workers=a.workers) as pool:
            for f in as_completed([pool.submit(run,g) for g in pending]):
                group,row=f.result();done[group]=row
        for group in ('evidence','full-runtime-blocked'):
            g,row=run(group);done[g]=row
    success=len(done)==len(GROUPS) and all(x['status']=='PASS' and x['complete'] and x['driver_returncode']==0 for x in done.values())
    result={'status':'PASS' if success else 'FAIL','complete':len(done)==len(GROUPS),
       'groups_expected':len(GROUPS),'groups_run':len(done),'command_count':sum(len(x['records']) for x in done.values())+len(supplemental),'supplemental_commands':supplemental,
       'seconds':round(time.monotonic()-started,3),'group_results':done,
       'elf_sha256':hashlib.sha256((ROOT/'reference/cgminer.vendor.elf').read_bytes()).hexdigest(),
       'hardware_tested':False,'full_upstream_build_tested':False,'full_runtime_expected_to_fail':True}
    (logs/'ALL_GROUPS.json').write_text(json.dumps(result,indent=2)+'\n')
    print('ALL_GROUPS',result['status'],result['groups_run'],result['command_count'],flush=True)
    return 0 if success else 1
if __name__=='__main__':raise SystemExit(main())

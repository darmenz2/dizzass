#!/usr/bin/env python3
"""Run a verification group with checked exit codes and persistent per-command logs.
All groups must pass in order after 'build' to validate a fresh extraction.
Splitting groups is for execution environments with short command time budgets.
Does not execute vendor ELF as a process and does not connect to miners/pools.
"""
from pathlib import Path
import argparse, datetime, hashlib, json, subprocess, sys, time
ROOT=Path(__file__).resolve().parents[1]
PY=sys.executable
GROUPS={
 'build':[
  ['make','-f','Makefile.recovery','clean'],
  ['make','-f','Makefile.recovery','all','build/libvn135_recovered.so','build/test-chip1398','build/test-pll-aml','build/test-reg-cache','build/test-uart','build/test-work-rx','arm']],
 'core':[
  ['./build/test-chip1398'],['./build/test-pll-aml'],['./build/test-reg-cache'],['./build/test-uart'],
  [PY,'tests/test_arm_subset.py'],[PY,'tests/test_arm_differential.py'],
  [PY,'tests/test_stage3_interpreter.py'],[PY,'tests/test_stage3_differential.py']],
 'cache':[[PY,'tests/test_stage4_cache_differential.py'],[PY,'tests/test_stage4_config_differential.py']],
 'uart':[[PY,'tests/test_stage5_uart_differential.py'],[PY,'tests/test_stage5_aml_uart_differential.py'],['make','-f','Makefile.recovery','linux-pty']],
 'rx':[['./build/test-work-rx'],[PY,'tests/test_stage6_interpreter.py'],[PY,'tests/test_stage6_rx_differential.py'],[PY,'tests/test_stage6_stream_differential.py'],['make','-f','Makefile.recovery','linux-pty-rx']],
 'sanitizers':[['make','-f','Makefile.recovery','sanitize','sanitize-linux-pty','sanitize-linux-pty-rx']],
 'evidence':[['make','-f','Makefile.recovery','evidence-check'],[PY,'tests/test_tree.py'],[PY,'tests/test_assembler.py'],[PY,'tools/update_overlay_inventory.py','--check']],
 'full-runtime-blocked':[['make','-f','Makefile.recovery','full-runtime']]
}
def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('group',choices=GROUPS)
    p.add_argument('--logs',type=Path,required=True,help='Use a directory outside the source tree (source inventory must stay unchanged).')
    args=p.parse_args();directory=args.logs.resolve()
    if directory.is_relative_to(ROOT):p.error('--logs must be outside the source tree')
    directory.mkdir(parents=True,exist_ok=True);records=[]
    for i,cmd in enumerate(GROUPS[args.group]):
        start=time.monotonic();log=directory/f'{args.group}-{i:02d}.log'
        expected=2 if args.group=='full-runtime-blocked' else 0
        with log.open('w') as out:
            out.write('COMMAND: '+repr(cmd)+'\n');out.flush()
            result=subprocess.run(cmd,cwd=ROOT,stdout=out,stderr=subprocess.STDOUT,check=False)
        record={'command':cmd,'returncode':result.returncode,'expected_returncode':expected,'log':log.name,
                'seconds':round(time.monotonic()-start,3),'sha256':hashlib.sha256(log.read_bytes()).hexdigest()}
        records.append(record)
        summary={'group':args.group,'status':'PASS' if all(r['returncode']==r['expected_returncode'] for r in records) else 'FAIL',
                 'complete':len(records)==len(GROUPS[args.group]),'records':records}
        (directory/(args.group+'.json')).write_text(json.dumps(summary,indent=2)+'\n')
        print(f'{args.group} {i+1}/{len(GROUPS[args.group])}: return={result.returncode} expected={expected} ({record["seconds"]}s)',flush=True)
        if result.returncode!=expected:return 1
    return 0
if __name__=='__main__':raise SystemExit(main())

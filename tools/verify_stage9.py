#!/usr/bin/env python3
"""Checked per-group verification of a fresh Stage9 extraction.
Logs MUST be outside source tree. No vendor ELF process or external network.
"""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys,time
from verify_stage8 import GROUPS as PRIOR
ROOT=Path(__file__).resolve().parents[1];PY=sys.executable
GROUPS={name:[list(cmd) for cmd in cmds] for name,cmds in PRIOR.items()}
GROUPS['build'][-1]+=['build/test-work-rebuild','build/vn135-rebuild-genesis']
GROUPS.update({
 'rebuild-sha':[[PY,'tests/test_stage9_differential.py','sha']],
 'rebuild-prefix':[[PY,'tests/test_stage9_differential.py','prefix']],
 'rebuild-candidate':[[PY,'tests/test_stage9_differential.py','candidate']],
 'rebuild-native':[['./build/test-work-rebuild'],[PY,'tests/test_stage9_interpreter.py'],
                   [PY,'tests/test_stage9_genesis.py'],[PY,'tools/generate_genesis_fixture.py']],
 'clang-rebuild':[['make','-f','Makefile.recovery','stage9-clang']]
})
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('group',choices=GROUPS)
    p.add_argument('--logs',type=Path,required=True);a=p.parse_args();directory=a.logs.resolve()
    if directory.is_relative_to(ROOT):p.error('--logs must be outside source tree')
    directory.mkdir(parents=True,exist_ok=True);records=[]
    for i,cmd in enumerate(GROUPS[a.group]):
        expected=2 if a.group=='full-runtime-blocked' else 0
        log=directory/f'{a.group}-{i:02d}.log';start=time.monotonic()
        with log.open('w') as out:
            out.write('COMMAND: '+repr(cmd)+'\n');out.flush()
            result=subprocess.run(cmd,cwd=ROOT,stdout=out,stderr=subprocess.STDOUT,check=False)
        row={'command':cmd,'returncode':result.returncode,'expected_returncode':expected,'log':log.name,
             'seconds':round(time.monotonic()-start,3),'sha256':hashlib.sha256(log.read_bytes()).hexdigest()}
        records.append(row)
        summary={'group':a.group,'status':'PASS' if all(x['returncode']==x['expected_returncode'] for x in records) else 'FAIL',
                 'complete':len(records)==len(GROUPS[a.group]),'records':records}
        (directory/(a.group+'.json')).write_text(json.dumps(summary,indent=2)+'\n')
        print(f'{a.group} {i+1}/{len(GROUPS[a.group])}: return={result.returncode} expected={expected} ({row["seconds"]}s)',flush=True)
        if result.returncode!=expected:return 1
    return 0
if __name__=='__main__':raise SystemExit(main())

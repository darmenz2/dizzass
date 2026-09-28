#!/usr/bin/env python3
"""Wrong semantics must compile and disagree with original; crashes do not count."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'src/backend/chip-sensor-check.c'
MUTANTS={
    'success_inverted': [('return 1;', 'return 0;')],
    'false_positive_empty': [('return 0;', 'return 1;')],
    'state_zero_rejected': [('sensor->state != 3u', 'sensor->state == 2u')],
    'failed_state_accepted': [('sensor->state != 3u', 'sensor->state == 3u')],
    'role_too_broad': [('sensor->role == 2u', 'sensor->role != 0u')],
    'kind_one_lost': [('(sensor->access_kind - 1u) <= 1u', 'sensor->access_kind == 2u')],
    'kind_truncated': [('sensor->access_kind - 1u', '(uint8_t)sensor->access_kind - 1u')],
    'role_truncated': [('sensor->role == 2u', '(uint8_t)sensor->role == 2u')],
    'absent_chain_accepted': [('!chain->present || ', '')],
    'chain_state_too_strict': [('(chain->state - 3u) <= 2u', 'chain->state != 2u')],
    'chain_state_five_accepted': [('(chain->state - 3u) <= 2u', 'chain->state == 3u')],
    'late_sensor_count': [('const int32_t sensors = general->model->sensor_count;\n    const int32_t chains = chain_count(context);',
                          'const int32_t chains = chain_count(context);\n    const int32_t sensors = general->model->sensor_count;')],
    'early_chain_bank': [('const int32_t chains = chain_count(context);',
                          'const struct vn135_general_chain *old_chains = general->chains;\n    const int32_t chains = chain_count(context);'),
                        ('&general->chains[i].thermal', '&old_chains[i].thermal')],
    'last_sensor_lost': [('j < sensors;', 'j + 1 < sensors;')],
    'last_chain_lost': [('i < chains;', 'i + 1 < chains;')],
    'wrong_count_source': [('j < sensors;', 'j < chain->sensor_count;')],
    'count_call_skipped': [('const int32_t chains = chain_count(context);',
                            'if (sensors < 1) return 0;\n    const int32_t chains = chain_count(context);')],
}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--cc',default='cc');p.add_argument('--out',required=True,type=Path)
    args=p.parse_args();out=args.out.resolve();out.mkdir(parents=True,exist_ok=True)
    source=SOURCE.read_text();records=[]
    for name,changes in [('baseline',[]),*MUTANTS.items()]:
        candidate=source
        for old,new in changes:
            if candidate.count(old)!=1:raise RuntimeError(('ambiguous mutation',name,old))
            candidate=candidate.replace(old,new)
        path=out/(name+'.c');path.write_text(candidate);library=out/(name+'.so')
        command=[args.cc,'-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
                 '-fno-fast-math','-ffp-contract=off','-DVN135_GENERAL_MONITOR_135',
                 '-DVN135_CHIP_SENSOR_CHECK_135','-shared','-fPIC',str(path),'src/backend/base.c','-Wl,-z,defs','-o',str(library)]
        build=subprocess.run(command,cwd=ROOT,capture_output=True,text=True,timeout=30)
        (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
        if build.returncode:raise RuntimeError((name,'must compile',build.stderr))
        test=subprocess.run([sys.executable,'integration/tests/test_chip_sensor_check_135.py',str(library),'--witness-only'],
                            cwd=ROOT,capture_output=True,text=True,timeout=30)
        (out/(name+'.log')).write_text(test.stdout+test.stderr)
        if changes:
            if test.returncode!=1 or not test.stderr.startswith('SEMANTIC_MISMATCH '):
                raise RuntimeError((name,'not a semantic rejection',test.returncode,test.stdout,test.stderr))
        elif test.returncode or 'CHIP_SENSOR_CHECK135_ORIGINAL_PASS' not in test.stdout:
            raise RuntimeError(('baseline failed',test.returncode,test.stderr))
        records.append(dict(name=name,build_exit=build.returncode,test_exit=test.returncode))
    report=dict(status='PASS',compiler=args.cc,rejected=len(MUTANTS),witnesses=20,
                source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(),records=records)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print('CHIP_SENSOR_CHECK135_NEGATIVE_PASS',json.dumps(report))
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Require actual oracle mismatches for compiled mutations, never build errors."""
import argparse
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
MARK='/* Original 65b3c: per-chain frequency-fall dispatch, before mining field reset. */'
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',required=True);ap.add_argument('--out',required=True);a=ap.parse_args()
    out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
    text=(ROOT/'src/backend/base.c').read_text();before,body=text.split(MARK)
    changes=[
        ('maximum_instead_of_minimum','minimum>=frequency','minimum<=frequency'),
        ('strict_boundary','if(floor<=target)','if(floor<target)'),
        ('ignore_configured_floor','if(minimum>floor)floor=minimum;','floor=minimum;'),
        ('reuse_initial_count','second=s->config;\n    count=o->chain_count(p);','second=s->config;\n    count=initial;'),
        ('skip_inactive_workers','arguments[i].backend=s;','if(!general_alive(&s->general->chains[i]))continue;\n        arguments[i].backend=s;'),
        ('join_previous_on_create_error','if(result){\n            if(o->log)',
         'if(result){\n            for(int32_t j=0;j<i;++j)(void)o->join(p,handles[j],NULL);\n            if(o->log)'),
        ('stop_joining_after_error','for(i=0;i<initial;++i)(void)o->join(p,handles[i],NULL);',
         'for(i=0;i<initial;++i)if(o->join(p,handles[i],NULL))break;'),
        ('fresh_first_config','target=first->target_18;','first=s->config;target=first->target_18;'),
        ('empty_active_is_always_error','empty_result=initial<1?-1:0;','empty_result=-1;'),
        ('release_order','o->release(p,VN135_FALL_ARGUMENTS,arguments);\n    o->release(p,VN135_FALL_HANDLES,handles);',
         'o->release(p,VN135_FALL_HANDLES,handles);\n    o->release(p,VN135_FALL_ARGUMENTS,arguments);'),
    ]
    for name,old,new in changes:
        assert body.count(old)==1,(name,body.count(old))
        source=out/(name+'.c');lib=out/(name+'.so');source.write_text(before+MARK+body.replace(old,new))
        subprocess.run([a.cc,'-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
            '-DVN135_GENERAL_MONITOR_135','-DVN135_FREQUENCY_FALL_135','-shared','-fPIC',str(source),'-Wl,-z,defs','-o',str(lib)],cwd=ROOT,check=True)
        r=subprocess.run([sys.executable,'integration/tests/test_frequency_fall_135.py',str(lib),'--quick'],cwd=ROOT,text=True,capture_output=True,timeout=30)
        (out/(name+'.log')).write_text(r.stdout+r.stderr)
        assert r.returncode!=0 and 'FREQUENCY_FALL_ORIGINAL_MISMATCH' in r.stderr,(name,r.returncode,r.stderr[-2000:])
        print('FREQUENCY_FALL135_NEGATIVE_REJECTED',name)
    print('FREQUENCY_FALL135_NEGATIVE_PASS rejected=10 compile_failures_accepted=0')
if __name__=='__main__':main()

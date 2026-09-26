#!/usr/bin/env python3
"""Reject compiled behavioral mutations; build errors are not passing controls."""
import argparse
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',required=True);ap.add_argument('--out',required=True);a=ap.parse_args()
    out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
    text=(ROOT/'src/backend/base.c').read_text()
    changes=[('early_flag_clear','(void)o->cancel(p,s->handle_104c);','g->tuning=0;(void)o->cancel(p,s->handle_104c);'),
        ('cached_handle','(void)o->cancel(p,s->handle_104c);\n        (void)o->join(p,s->handle_104c,NULL);',
         'uint32_t old=s->handle_104c;(void)o->cancel(p,old);\n        (void)o->join(p,old,NULL);'),
        ('skip_join_after_error','(void)o->cancel(p,s->handle_104c);\n        (void)o->join(p,s->handle_104c,NULL);',
         'if(!o->cancel(p,s->handle_104c))(void)o->join(p,s->handle_104c,NULL);'),
        ('missing_second_byte','g->tuning=0;s->byte_104a=0;','g->tuning=0;'),
        ('clear_inactive_joinable','(void)o->step(p,0x65b3cu,0);','s->byte_104a=0;(void)o->step(p,0x65b3cu,0);'),
        ('skip_delay','(void)o->delay_ms(p,100);\n    if(g->tuning){','if(g->tuning){'),
        ('skip_lower_cleanup','(void)o->step(p,0x65b3cu,0);','(void)0;'),
        ('retain_started_time','memset(&g->started_at,0,8);','(void)0;')]
    for name,old,new in changes:
        assert text.count(old)==1,(name,text.count(old))
        source=out/(name+'.c');lib=out/(name+'.so');source.write_text(text.replace(old,new))
        subprocess.run([a.cc,'-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
            '-DVN135_MINING_STOP_135','-shared','-fPIC',str(source),'-Wl,-z,defs','-o',str(lib)],cwd=ROOT,check=True)
        r=subprocess.run([sys.executable,'integration/tests/test_mining_stop_135.py',str(lib),'--quick'],
            cwd=ROOT,text=True,capture_output=True,timeout=30)
        (out/(name+'.log')).write_text(r.stdout+r.stderr)
        assert r.returncode!=0 and 'ORIGINAL_MISMATCH' in r.stderr,(name,r.returncode,r.stderr[-1200:])
        print('MINING_STOP135_NEGATIVE_REJECTED',name)
    print('MINING_STOP135_NEGATIVE_PASS rejected=8 compile_failures_accepted=0')
if __name__=='__main__':main()

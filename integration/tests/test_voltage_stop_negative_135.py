#!/usr/bin/env python3
"""A valid negative control must compile, then disagree with the original."""
import argparse
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',required=True);ap.add_argument('--out',required=True);a=ap.parse_args()
    out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
    text=(ROOT/'src/backend/base.c').read_text()
    old='t->running=0;self=o->self(p);handle=t->handle;'
    cancel='else{(void)o->cancel(p,handle);(void)o->join(p,t->handle,NULL);}'
    changes=[('late_flag_clear',old,'self=o->self(p);t->running=0;handle=t->handle;'),
             ('cached_before_self',old,'t->running=0;handle=t->handle;self=o->self(p);'),
             ('cached_before_cancel',cancel,'else{(void)o->cancel(p,handle);(void)o->join(p,handle,NULL);}'),
             ('skip_join_on_error',cancel,'else{if(!o->cancel(p,handle))(void)o->join(p,t->handle,NULL);}')]
    for name,source,replacement in changes:
        assert text.count(source)==1
        c=out/(name+'.c');lib=out/(name+'.so');c.write_text(text.replace(source,replacement))
        subprocess.run([a.cc,'-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
                        '-DVN135_BACKEND_SHUTDOWN_135','-DVN135_RESCUE_STOP_135','-DVN135_VOLTAGE_STOP_135','-shared','-fPIC',str(c),
                        'src/backend/volt-ctrl.c','-Wl,-z,defs','-o',str(lib)],cwd=ROOT,check=True)
        r=subprocess.run([sys.executable,'integration/tests/test_voltage_stop_135.py',str(lib),'--quick'],
                         cwd=ROOT,text=True,capture_output=True,timeout=30)
        (out/(name+'.log')).write_text(r.stdout+r.stderr)
        assert r.returncode!=0 and 'ORIGINAL_MISMATCH' in r.stderr,(name,r.returncode,r.stderr[-1000:])
        print('VOLTAGE_STOP135_NEGATIVE_REJECTED',name)
    print('VOLTAGE_STOP135_NEGATIVE_PASS rejected=4 compile_failures_accepted=0')
if __name__=='__main__':main()

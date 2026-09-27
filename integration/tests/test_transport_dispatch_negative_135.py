#!/usr/bin/env python3
"""Only a compiled original/C semantic mismatch counts as rejection."""
import argparse
import json
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[2]
SOURCE='libbitmain/src/transport-dispatch.c'
MUTANTS={
 'normalize_status':('return table->send_payload(table->context,device,payload,length);',
                     'return table->send_payload(table->context,device,payload,length)?-1:0;'),
 'truncate_length':('return table->send_payload(table->context,device,payload,length);',
                    'return table->send_payload(table->context,device,payload,length&255u);'),
 'reject_null_in_dispatch':('return table->send_payload(table->context,device,payload,length);',
                           'if(!device){return -1;}return table->send_payload(table->context,device,payload,length);'),
 'dispatch_twice':('return table->send_payload(table->context,device,payload,length);',
                   '(void)table->send_payload(table->context,device,payload,length);return table->send_payload(table->context,device,payload,length);'),
 'bypass_uart_helper':('return vn135_uart_write_legacy(uart,c->uart,frame,size);',
                      'return c->uart->write(c->uart->context,((vn135_uart*)uart)->fd,frame,size);'),
 'omit_outer_lock':('c->frame->lock(c->frame->context);','(void)c;'),
 'normalize_uart_count':('return vn135_uart_write_legacy(uart,c->uart,frame,size);',
                        'return vn135_uart_write_legacy(uart,c->uart,frame,size)==(int32_t)size?0:-1;'),
}
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True)
    a=ap.parse_args();out=Path(a.out).resolve();out.mkdir(parents=True,exist_ok=True)
    source=(ROOT/SOURCE).read_text();passed=[]
    others=['libbitmain/src/aml/chip.c','libbitmain/src/uart.c',
        'libbitmain/src/chip/chip1368-register-write.c','libbitmain/src/chip/chip1368-frequency.c',
        'libbitmain/src/pll.c','libbitmain/src/reg_cache.c','integration/bm1368_control.c',
        'reconstruction/support/crc5.c']
    for name,(old,new) in MUTANTS.items():
        assert source.count(old)==1,name
        c,so=out/(name+'.c'),out/(name+'.so');c.write_text(source.replace(old,new))
        cmd=[a.cc,'-I.','-Iinclude','-O1','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror',
            '-DVN135_TRANSPORT_DISPATCH_135','-DVN135_BM1368_REGISTER_WRITE_135',
            '-DVN135_BM1368_FREQUENCY_135','-shared','-fPIC',str(c),*others,'-Wl,-z,defs','-o',str(so)]
        build=subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30)
        (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
        if build.returncode:raise RuntimeError((name,'must compile',build.stderr))
        run=subprocess.run(['python3','integration/tests/test_transport_dispatch_135.py',str(so)],
                           cwd=ROOT,capture_output=True,text=True,timeout=30)
        (out/(name+'.log')).write_text(run.stdout+run.stderr)
        if run.returncode!=1 or 'SEMANTIC_MISMATCH' not in run.stderr:
            raise RuntimeError((name,'not a semantic rejection',run.returncode,run.stderr[-4000:]))
        passed.append(name)
    print('TRANSPORT_DISPATCH135_NEGATIVE_PASS',json.dumps({'rejected':len(passed),'mutants':passed}))
if __name__=='__main__':main()

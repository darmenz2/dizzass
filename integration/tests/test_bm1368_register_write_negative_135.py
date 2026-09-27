#!/usr/bin/env python3
"""Compile mutations; count only deterministic original/C mismatches."""
import argparse
import json
from pathlib import Path
import subprocess
ROOT=Path(__file__).resolve().parents[2]
SOURCE='libbitmain/src/chip/chip1368-register-write.c'
MUTANTS={
 'wire_nonzero_instead_of_one':('DIZZASS_BM1368_SET_CONFIG,mode==1u,','DIZZASS_BM1368_SET_CONFIG,mode!=0u,'),
 'cache_one_instead_of_nonzero':('if(mode!=0u)','if(mode==1u)'),
 'prefix_in_payload':('opaque,device,frame+2,9','opaque,device,frame,9'),
 'stale_device_index':('int32_t result,chain;','int32_t result,chain; uint32_t saved=device->index;'),
 'stale_chip_index':('int32_t result,chain;','int32_t result,chain; int32_t saved_chip=chip ? chip->cache_index : 0;'),
 'cache_register_truncation':('opaque,chain,reg,value','opaque,chain,reg&255u,value'),
 'ignore_transport_failure':('if(ops->send_payload(opaque,device,frame+2,9)){','if((ops->send_payload(opaque,device,frame+2,9),0)){'),
 'ignore_cache_failure':('return result==0 ? 0 : -1;','(void)result;return 0;'),
 'wrong_null_chip_index':('chip ? chip->cache_index : 0,reg,value','chip ? chip->cache_index : -1,reg,value'),
 'wrong_error_index':('350,device->index+1u','350,device->index'),
}
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True)
    args=ap.parse_args();out=Path(args.out).resolve();out.mkdir(parents=True,exist_ok=True)
    original=(ROOT/SOURCE).read_text();passed=[]
    for name,(old,new) in MUTANTS.items():
        assert original.count(old)==1,(name,'ambiguous change')
        text=original.replace(old,new)
        if name=='stale_device_index':text=text.replace('chain=register_signed_index(device->index);','chain=register_signed_index(saved);')
        if name=='stale_chip_index':text=text.replace('chip ? chip->cache_index : 0,reg,value','saved_chip,reg,value')
        c,so=out/(name+'.c'),out/(name+'.so');c.write_text(text)
        command=[args.cc,'-I.','-Iinclude','-O1','-g','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror',
            '-DVN135_BM1368_REGISTER_WRITE_135','-DVN135_BM1368_FREQUENCY_135','-shared','-fPIC',str(c),
            'libbitmain/src/chip/chip1368-frequency.c','libbitmain/src/pll.c','libbitmain/src/reg_cache.c',
            'integration/bm1368_control.c','reconstruction/support/crc5.c','-Wl,-z,defs','-o',str(so)]
        subprocess.run(command,cwd=ROOT,check=True,capture_output=True,timeout=25)
        run=subprocess.run(['python3','integration/tests/test_bm1368_register_write_135.py',str(so),'--quick'],
                           cwd=ROOT,capture_output=True,text=True,timeout=25)
        (out/(name+'.log')).write_text(run.stdout+run.stderr)
        if run.returncode!=1 or 'SEMANTIC_MISMATCH' not in run.stderr:
            raise RuntimeError((name,'not rejected by semantic comparison',run.returncode,run.stderr[-4000:]))
        passed.append(name)
    print('BM1368_REGISTER135_NEGATIVE_PASS',json.dumps({'rejected':len(passed),'mutants':passed}))
if __name__=='__main__':main()

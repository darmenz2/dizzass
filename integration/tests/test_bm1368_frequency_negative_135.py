#!/usr/bin/env python3
"""Mutants must compile, then fail specifically on an oracle mismatch."""
import argparse, json, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE='libbitmain/src/chip/chip1368-frequency.c'
MUTANTS={
 'first_write_controls_result':('(void)ops->write_config(opaque,device,1,NULL,8,word);','if(ops->write_config(opaque,device,1,NULL,8,word))goto failed;'),
 'single_write':('(void)ops->write_config(opaque,device,1,NULL,8,word);','(void)word;'),
 'vco_lower_inclusive':('pll.vco_mhz<limits->vco_min_mhz','pll.vco_mhz<=limits->vco_min_mhz'),
 'vco_upper_inclusive':('pll.vco_mhz>limits->vco_max_mhz','pll.vco_mhz>=limits->vco_max_mhz'),
 'threshold_inclusive':('pll.vco_mhz<limits->reserved_16','pll.vco_mhz<=limits->reserved_16'),
 'mode_from_requested':('pll.vco_mhz<limits->reserved_16','requested<limits->reserved_16'),
 'post1_no_minus_one':('((uint32_t)pll.post_divider1-1u)','((uint32_t)pll.post_divider1)'),
 'post2_no_minus_one':('((uint32_t)pll.post_divider2-1u)','((uint32_t)pll.post_divider2)'),
 'feedback_wrong_mask':('pll.feedback_divider & 4095u','pll.feedback_divider & 255u'),
 'return_success_on_write_error':('if(!ops->write_config(opaque,device,1,NULL,8,word))return 0;','(void)ops->write_config(opaque,device,1,NULL,8,word);return 0;'),
 'old_device_index':('ops->log(opaque,972,device->index+1u,requested)','ops->log(opaque,972,3u,requested)'),
}
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True);args=ap.parse_args()
    out=Path(args.out).resolve();out.mkdir(parents=True,exist_ok=True);original=(ROOT/SOURCE).read_text();passed=[]
    for name,(old,new) in MUTANTS.items():
        assert original.count(old)==1,(name,'ambiguous mutation')
        c=out/(name+'.c');so=out/(name+'.so');c.write_text(original.replace(old,new))
        command=[args.cc,'-I.','-Iinclude','-O1','-g','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror',
          '-fno-fast-math','-ffp-contract=off','-DVN135_BM1368_FREQUENCY_135','-shared','-fPIC',str(c),
          'libbitmain/src/pll.c','integration/bm1368_control.c','reconstruction/support/crc5.c','-Wl,-z,defs','-o',str(so)]
        subprocess.run(command,cwd=ROOT,check=True,capture_output=True,timeout=25)
        result=subprocess.run(['python3','integration/tests/test_bm1368_frequency_135.py',str(so),'--quick'],
                              cwd=ROOT,capture_output=True,text=True,timeout=25)
        (out/(name+'.log')).write_text(result.stdout+result.stderr)
        if result.returncode!=1 or 'SEMANTIC_MISMATCH' not in result.stderr:
            raise RuntimeError((name,'not rejected by semantic comparison',result.returncode,result.stdout,result.stderr))
        passed.append(name)
    print('BM1368_FREQUENCY135_NEGATIVE_PASS',json.dumps({'rejected':len(passed),'mutants':passed}))
if __name__=='__main__':main()

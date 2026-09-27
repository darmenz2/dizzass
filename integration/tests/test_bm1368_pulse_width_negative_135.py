#!/usr/bin/env python3
"""Each mutant must compile and fail specifically on an original/C mismatch."""
import argparse,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE='libbitmain/src/chip/chip1368-pulse-width.c'
MUTANTS={
 'width_mask':('pulse_width & 3u','pulse_width & 7u'),
 'delay_mask':('clock_delay & 7u','clock_delay & 15u'),
 'missing_enable_bit':('UINT32_C(0x80008000)','UINT32_C(0x00008000)'),
 'wrong_width_shift':('((pulse_width & 3u)<<6)','((pulse_width & 3u)<<5)'),
 'wrong_delay_shift':('((clock_delay & 7u)<<3)','((clock_delay & 7u)<<2)'),
 'wrong_register':('device,1,NULL,0x3c,word','device,1,NULL,0x38,word'),
 'unicast':('device,1,NULL,0x3c,word','device,0,NULL,0x3c,word'),
 'extra_argument_used':('(void)ignored_4;','word |= ignored_4;'),
 'positive_error_ignored':('if(!ops->write_config(opaque,device,1,NULL,0x3c,word))return 0;',
                           'if(ops->write_config(opaque,device,1,NULL,0x3c,word)>=0)return 0;'),
 'second_log_omitted':('if(ops->log)ops->log(opaque,569,device->index+1u);','/* lost second diagnostic */'),
 'old_index':('ops->log(opaque,387,device->index+1u)','ops->log(opaque,387,3u)'),
 'second_index_not_fresh':('ops->log(opaque,569,device->index+1u)','ops->log(opaque,569,18u)'),
}
SOURCES=['libbitmain/src/transport-dispatch.c','libbitmain/src/aml/chip.c','libbitmain/src/uart.c',
 'libbitmain/src/chip/chip1368-register-write.c','libbitmain/src/chip/chip1368-frequency.c',
 'libbitmain/src/pll.c','libbitmain/src/reg_cache.c','integration/bm1368_control.c','reconstruction/support/crc5.c']
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--out',required=True);a=ap.parse_args()
 out=Path(a.out).resolve();out.mkdir(parents=True,exist_ok=True);text=(ROOT/SOURCE).read_text();rejected=[]
 for name,(old,new) in MUTANTS.items():
  assert text.count(old)==1,(name,'ambiguous replacement')
  source=out/(name+'.c');so=out/(name+'.so');source.write_text(text.replace(old,new))
  cmd=[a.cc,'-I.','-Iinclude','-O1','-g','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror',
   '-DVN135_BM1368_PULSE_WIDTH_135','-DVN135_BM1368_REGISTER_WRITE_135','-DVN135_BM1368_FREQUENCY_135',
   '-DVN135_TRANSPORT_DISPATCH_135','-shared','-fPIC',str(source),*SOURCES,'-Wl,-z,defs','-o',str(so)]
  subprocess.run(cmd,cwd=ROOT,check=True,capture_output=True,timeout=30)
  result=subprocess.run(['python3','integration/tests/test_bm1368_pulse_width_135.py',str(so),'--quick'],
   cwd=ROOT,capture_output=True,text=True,timeout=30)
  (out/(name+'.log')).write_text(result.stdout+result.stderr)
  assert result.returncode==1 and 'SEMANTIC_MISMATCH' in result.stderr,(name,result.returncode,result.stdout,result.stderr)
  rejected.append(name)
 print('BM1368_PULSE135_NEGATIVE_PASS',json.dumps({'rejected':len(rejected),'mutants':rejected}))
if __name__=='__main__':main()

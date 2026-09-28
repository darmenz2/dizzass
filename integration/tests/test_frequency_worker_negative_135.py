#!/usr/bin/env python3
"""Compile six semantic mutants; require an oracle trace mismatch, not a crash."""
import argparse,subprocess,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
MUTANTS={
 'equal-target-skipped':('if(frequency<target)goto thread_exit;','if(frequency<=target)goto thread_exit;'),
 'wrong-step':('(uint32_t)frequency-100u','(uint32_t)frequency-50u'),
 'missing-final-delay':('(void)ops->call(opaque,0x10ef3cu,100,0);','if(frequency!=target)(void)ops->call(opaque,0x10ef3cu,100,0);'),
 'wrong-event':('0x49c98u,2010,0','0x49c98u,2007,0'),
 'missing-power-fallback':('(void)ops->call(opaque,0x6b778u,0,0);','(void)0;'),
 'late-frequency-snapshot':('frequency=(frequency/50)*50;','frequency=(worker_signed_word(chain->thermal.cleared_words[0])/50)*50;'),
}
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');a=ap.parse_args()
 original=(ROOT/'src/backend/frequency-worker.c').read_text()
 with tempfile.TemporaryDirectory() as directory:
  p=Path(directory)
  for name,(old,new) in MUTANTS.items():
   assert original.count(old)==1
   c=p/(name+'.c');so=p/(name+'.so');c.write_text(original.replace(old,new))
   command=[a.cc,'-I'+str(ROOT),'-std=c11','-O1','-shared','-fPIC','-DVN135_GENERAL_MONITOR_135','-DVN135_MONITOR_HANDLERS_135','-DVN135_FREQUENCY_WORKER_135',str(ROOT/'src/backend/base.c'),str(c),'-Wl,-z,defs','-o',str(so)]
   subprocess.run(command,check=True,timeout=30)
   result=subprocess.run(['python3',str(ROOT/'integration/tests/test_frequency_worker_135.py'),str(so)],capture_output=True,text=True,timeout=45)
   assert result.returncode==1 and 'worker comparison mismatch' in result.stderr and 'MISMATCH' in result.stdout,(name,result.returncode,result.stderr[-1000:])
   print('REJECTED',name)
 print('FREQUENCY_WORKER135_NEGATIVE_PASS mutants='+str(len(MUTANTS)))
if __name__=='__main__':main()

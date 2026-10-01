#!/usr/bin/env python3
"""Reject compiled, safe semantic changes; crashes/build errors are not passes."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

def main():
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True)
    p.add_argument('--test',type=Path,required=True);p.add_argument('--cc',default=os.environ.get('CC','cc'))
    args=p.parse_args();root=args.root.resolve()
    source=(root/'libbitmain/src/chip/chip1368.c').read_text()
    prefix,body=source.split('#ifdef VN135_BM1368_INITIALIZE_135',1)
    stores=list(re.finditer(r'method_words\[(0x[0-9a-f]+) / 4\] = UINT32_C\((0x[0-9a-f]+)\);',body))
    if len(stores)!=54:raise ValueError('expected complete 54-word initializer')
    mutants=[]
    for m in stores:
        replacement=m.group().replace(m.group(2),hex(int(m.group(2),16)^4))
        mutants.append(('wrong-slot-'+m.group(1),body[:m.start()]+replacement+body[m.end():]))
    for word in [0,6]:
        mutants.append(('overwrite-preserved-'+str(word),body.replace('    return 0;',f'    method_words[{word}] = 0;\n    return 0;')))
    mutants.append(('wrong-return',body.replace('    return 0;','    return 1;')))
    records=[]
    with tempfile.TemporaryDirectory(prefix='bm1368-init-controls-') as d:
        d=Path(d)
        for label,changed in [('baseline',body)]+mutants:
            src=d/'candidate.c';exe=d/'test'
            src.write_text(prefix+'#ifdef VN135_BM1368_INITIALIZE_135'+changed)
            cmd=[args.cc,'-I'+str(root),'-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
                 '-DVN135_BM1368_INITIALIZE_135','-DVN135_TRANSPORT_INITIALIZE_135',str(src),
                 str(root/'libbitmain/src/transport-dispatch.c'),str(args.test.resolve()),'-o',str(exe)]
            subprocess.run(cmd,check=True,capture_output=True,text=True,timeout=30)
            r=subprocess.run([str(exe)],capture_output=True,text=True,timeout=10)
            if label=='baseline':
                if r.returncode!=0 or 'BM1368_INIT_PASS' not in r.stdout:raise RuntimeError('baseline failed')
            elif r.returncode!=1 or 'BM1368_INIT_FAIL' not in r.stderr:
                raise RuntimeError(f'{label} not cleanly detected: {r.returncode} {r.stderr}')
            records.append({'control':label,'returncode':r.returncode,'semantic_detection':label!='baseline'})
    print(json.dumps({'compiled_controls':len(mutants),'baseline_pass':True,'records':records},indent=2))

if __name__=='__main__':main()

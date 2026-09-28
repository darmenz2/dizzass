#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Host functional/error tests plus compiled semantic negative controls."""
import argparse, hashlib, json, pathlib, subprocess
from build import ROOT,HERE,checked_sources

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',required=True);ap.add_argument('--out',required=True,type=pathlib.Path)
    ap.add_argument('--sanitize',action='store_true');args=ap.parse_args()
    checked_sources(); out=args.out.resolve();out.mkdir(parents=True,exist_ok=False)
    logs=[]
    def run(cmd,n,expected=0):
        import os
        env=dict(os.environ,ASAN_OPTIONS='detect_leaks=1:halt_on_error=1',UBSAN_OPTIONS='halt_on_error=1')
        p=subprocess.run([str(x) for x in cmd],cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=30)
        (out/n).write_text(p.stdout);logs.append({'argv':[str(x) for x in cmd],'exit':p.returncode,'log':n,'sha256':hashlib.sha256(p.stdout.encode()).hexdigest()})
        (out/'results.json').write_text(json.dumps(logs,indent=2)+'\n')
        if p.returncode!=expected: raise SystemExit('UNEXPECTED_RESULT '+n+'\n'+p.stdout)
        return p.stdout
    flags=[args.cc,'-std=c11','-O1','-g','-fno-builtin','-I'+str(ROOT),'-I'+str(ROOT/'include'),'-Wall','-Wextra','-Werror']
    if args.sanitize:flags+=['-fsanitize=address,undefined','-fno-omit-frame-pointer']
    inputs=[HERE/'host_test.c',HERE/'selftest.c',ROOT/'integration/work_tx88.c',ROOT/'integration/bm1368_control.c',ROOT/'reconstruction/support/crc5.c']
    run(flags+inputs+[HERE/'main.c','-o',out/'test'],'build.log')
    for mode in range(15):run([out/'test',str(mode)],'mode-%02d.log'%mode)
    # Reuse unchanged positive source and require semantic exit1, not crash.
    if not args.sanitize:
        mutations=[('integration/work_tx88.c','frame[3] = 0x36;','frame[3] = 0x37;'),
                   ('integration/work_tx88.c','slot > 31u','slot > 255u'),
                   ('integration/work_tx88.c','frame[87] = (uint8_t)crc;','frame[87] = (uint8_t)(crc ^ 1);'),
                   ('integration/bm1368_control.c','packet[n-1]=crc;','packet[n-1]=(uint8_t)(crc ^ 1);')]
        run(flags+['-DD01_PURE_ONLY']+inputs+['-o',out/'baseline'],'baseline-build.log')
        run([out/'baseline'],'baseline.log')
        for i,(path,old,new) in enumerate(mutations):
            src=(ROOT/path).read_text()
            if src.count(old)!=1:raise SystemExit('mutation source drift')
            mutated=out/('mutant-%d.c'%i);mutated.write_text(src.replace(old,new))
            mi=[mutated if p==ROOT/path else p for p in inputs]
            run(flags+['-DD01_PURE_ONLY']+mi+['-o',out/('mutant-%d'%i)],'mutant-%d-build.log'%i)
            text=run([out/('mutant-%d'%i)],'mutant-%d.log'%i,1)
            if 'D01_PURE checks=' not in text or 'failed=0' in text:raise SystemExit('not a semantic rejection')
    print('D01_HOST_SUITE_PASS compiler='+args.cc+' modes=15 sanitizer='+str(args.sanitize)+' semantic_mutants='+str(0 if args.sanitize else 4))
if __name__=='__main__':main()

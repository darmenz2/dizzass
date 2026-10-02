#!/usr/bin/env python3
"""Compiled semantic mutations; detection requires an explicit oracle failure.
Signals, build failures and timeouts never count as semantic detection.
Uninitialized incoming stack values are deliberately not observed by tests.
"""
import argparse
import json
from pathlib import Path
import shlex
import subprocess


def main():
    p=argparse.ArgumentParser()
    p.add_argument('--root',type=Path,required=True)
    p.add_argument('--cc',default='cc')
    p.add_argument('--build',type=Path,required=True)
    a=p.parse_args()
    root,build=a.root.resolve(),a.build.resolve()
    original=(root/'libbitmain/src/chip/chip1368-register-pair.c').read_text()
    read_a='reader->read_cached(reader->context, signed_index_135(device->index),\n            0xa8, &a8)'
    read_b='reader->read_cached(reader->context, signed_index_135(device->index),\n            0x18, &reg18)'
    write_a='vn135_bm1368_write_register_135(device, 1, NULL, 0xa8, a8,\n            writer, write_context)'
    variants={
        'baseline':original,
        'chip-instead-of-common':original.replace('vn135_reg_cache_get_chain(context, chain, reg, output)','vn135_reg_cache_get_chip(context, chain, 0, reg, output)'),
        'wrong-first-read-reg':original.replace('0xa8, &a8','0xa9, &a8'),
        'wrong-second-read-reg':original.replace('0x18, &reg18','0x19, &reg18'),
        'ignore-first-read-status':original.replace(read_a,'('+read_a+', 0)'),
        'ignore-second-read-status':original.replace(read_b,'('+read_b+', 0)'),
        'ignore-negative-first-read':original.replace(read_a+' != 0',read_a+' > 0'),
        'stale-second-read-index':original.replace('uint32_t a8, reg18;','const int32_t first_chain = signed_index_135(device->index);\n    uint32_t a8, reg18;').replace('signed_index_135(device->index),\n            0x18','first_chain,\n            0x18'),
        'flag-low-bit-only':original.replace('flag != 0','(flag & 1u) != 0'),
        'nonzero-a8-mask':original.replace('UINT32_C(0x10f)','UINT32_C(0x10e)'),
        'nonzero-18-mask':original.replace('UINT32_C(0xf00000)','UINT32_C(0xe00000)'),
        'zero-a8-mask':original.replace('UINT32_C(0xf0)','UINT32_C(0x70)'),
        'zero-18-mask':original.replace('UINT32_C(0xff0f0000)','UINT32_C(0xff0e0000)'),
        'unicast':original.replace('device, 1, NULL','device, 0, NULL'),
        'wrong-first-write-reg':original.replace('NULL, 0xa8, a8','NULL, 0x18, a8'),
        'wrong-second-write-reg':original.replace('NULL, 0x18, reg18','NULL, 0xa8, reg18'),
        'ignore-first-write-status':original.replace(write_a,'('+write_a+', 0)'),
        'second-write-reuses-a8':original.replace('NULL, 0x18, reg18','NULL, 0x18, a8'),
        'inverted-second-write-result':original.replace('== 0 ? 0 : -1','!= 0 ? 0 : -1'),
        'failure-success':original.replace('return -1;','return 0;'),
    }
    common=[root/r for r in ('libbitmain/src/chip/chip1368-register-write.c',
        'libbitmain/src/chip/chip1368-frequency.c','libbitmain/src/pll.c',
        'libbitmain/src/reg_cache.c','integration/bm1368_control.c','reconstruction/support/crc5.c')]
    test=Path(__file__).resolve().with_name('test_register_pair.c')
    flags=['-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror',
        '-fno-fast-math','-ffp-contract=off','-I'+str(root),'-I'+str(root/'include'),
        '-DVN135_BM1368_REGISTER_WRITE_135','-DVN135_BM1368_FREQUENCY_135',
        '-DVN135_BM1368_REGISTER_PAIR_135']
    results=[]
    for name,text in variants.items():
        if name!='baseline' and text==original:
            raise RuntimeError('empty control: '+name)
        folder=build/name; folder.mkdir(parents=True,exist_ok=True)
        variant,exe=folder/'runtime.c',folder/'test'
        variant.write_text(text)
        compiled=subprocess.run(shlex.split(a.cc)+flags+[str(s) for s in common]+[str(variant),str(test),'-o',str(exe)],capture_output=True,text=True,timeout=90)
        (folder/'build.log').write_text(compiled.stdout+compiled.stderr)
        if compiled.returncode:
            raise RuntimeError('control compilation failed: '+name)
        ran=subprocess.run([str(exe)],capture_output=True,text=True,timeout=45)
        (folder/'run.log').write_text(ran.stdout+ran.stderr)
        ok=(ran.returncode==0 and 'BM1368_PAIR135_HOST_PASS' in ran.stdout) if name=='baseline' else (ran.returncode==1 and 'PAIR135_FAIL' in ran.stderr)
        if not ok:
            raise RuntimeError('explicit oracle result absent: '+name)
        results.append({'name':name,'compiled':True,'exit_code':ran.returncode,'explicit_oracle_result':True})
    report={'compiler':a.cc,'baseline_passed':True,'semantic_controls_detected':len(results)-1,'results':results,'original_executed':False}
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))


if __name__=='__main__':
    main()

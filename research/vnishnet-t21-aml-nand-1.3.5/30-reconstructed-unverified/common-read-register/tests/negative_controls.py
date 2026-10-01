#!/usr/bin/env python3
"""Compiled host semantic controls; crashes/build errors never count as detection."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

def main():
    p=argparse.ArgumentParser();p.add_argument('--root',type=Path,required=True)
    p.add_argument('--test',type=Path,required=True);p.add_argument('--cc',default=os.environ.get('CC','cc'))
    a=p.parse_args();root=a.root.resolve()
    source=(root/'libbitmain/src/chip/chip.c').read_text()
    changes=[
      ('broadcast-nonzero','mode & 1u','mode != 0u'),
      ('broadcast-equals-one','mode & 1u','mode == 1u'),
      ('ignore-chip-address','chip ? chip->wire_address & 255u : 0u','0u'),
      ('cache-index-as-address','chip->wire_address & 255u','(uint32_t)chip->cache_index & 255u'),
      ('ignore-register','reg & 255u','0u'),
      ('reject-high-register','reg & 255u','reg'),
      ('duplicate-aml-prefix','device->identity, frame + 2, 5','device->identity, frame, 5'),
      ('short-body','device->identity, frame + 2, 5','device->identity, frame + 2, 4'),
      ('accept-positive','frame + 2, 5) == 0','frame + 2, 5) >= 0'),
      ('accept-negative','frame + 2, 5) == 0','frame + 2, 5) <= 0'),
      ('wrong-line','command", 103, 1','command", 104, 1'),
      ('wrong-severity','command", 103, 1','command", 103, 2'),
      ('wrong-index-increment','*device->index + UINT32_C(1)','*device->index + UINT32_C(2)'),
      ('wrong-module','"driver",','"chip",'),
      ('wrong-format','send GET_STATUS command','send READ_STATUS command'),
      ('missing-log','    log->emit(log->context, &diagnostic);','    (void)log; (void)diagnostic;'),
      ('double-log','    log->emit(log->context, &diagnostic);','    log->emit(log->context, &diagnostic);\n    log->emit(log->context, &diagnostic);'),
      ('wrong-error-status','    return -1;\n}', '    return 1;\n}'),
      ('double-send','    if (vn135_transport_send_135(', '    (void)vn135_transport_send_135(transport, device->identity, frame + 2, 5);\n    if (vn135_transport_send_135('),
    ]
    mutants=[]
    for label,old,new in changes:
        if source.count(old)!=1:raise ValueError('ambiguous mutation '+label)
        changed=source.replace(old,new)
        # Keep the deliberately ignored parameter meaningful to strict compilers.
        if label=='ignore-chip-address':changed=changed.replace('    uint8_t frame[7];','    (void)chip;\n    uint8_t frame[7];')
        if label=='ignore-register':changed=changed.replace('    uint8_t frame[7];','    (void)reg;\n    uint8_t frame[7];')
        mutants.append((label,changed))
    stale=source.replace('    uint8_t frame[7];','    uint32_t before = device->index ? *device->index : 0;\n    uint8_t frame[7];')
    stale=stale.replace('*device->index + UINT32_C(1)','before + UINT32_C(1)')
    mutants.append(('index-read-before-send',stale))
    deps=['integration/bm1368_control.c','reconstruction/support/crc5.c','libbitmain/src/transport-dispatch.c',
          'libbitmain/src/aml/chip.c','libbitmain/src/uart.c','libbitmain/src/chip/chip1368.c']
    flags=['-I'+str(root),'-I'+str(root/'include'),'-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror',
           '-Wconversion','-Wshadow','-DVN135_COMMON_READ_REGISTER_135','-DVN135_TRANSPORT_DISPATCH_135',
           '-DVN135_TRANSPORT_INITIALIZE_135','-DVN135_BM1368_INITIALIZE_135']
    records=[]
    with tempfile.TemporaryDirectory(prefix='common-read-controls-') as tmp:
        d=Path(tmp)
        for label,text in [('baseline',source)]+mutants:
            c=d/'candidate.c';exe=d/'test';c.write_text(text)
            cmd=[a.cc,*flags,str(c),*[str(root/x) for x in deps],str(a.test.resolve()),'-o',str(exe)]
            compiled=subprocess.run(cmd,capture_output=True,text=True,timeout=45)
            if compiled.returncode:
                sys.stderr.write(compiled.stdout+compiled.stderr)
                compiled.check_returncode()
            r=subprocess.run([str(exe)],capture_output=True,text=True,timeout=10)
            if label=='baseline':
                if r.returncode!=0 or 'COMMON_READ_PASS' not in r.stdout:raise RuntimeError('baseline failed')
            elif r.returncode!=1 or 'COMMON_READ_FAIL' not in r.stderr:
                raise RuntimeError(f'{label}: not a clean semantic detection, exit={r.returncode} {r.stderr}')
            records.append({'control':label,'returncode':r.returncode,'output':r.stdout.strip() or r.stderr.strip()})
    print(json.dumps({'baseline_pass':True,'compiled_controls':len(mutants),'records':records},indent=2))

if __name__=='__main__':main()

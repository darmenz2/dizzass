#!/usr/bin/env python3
"""Semantic adapter mutations plus exact-dependency staging failure checks."""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'integration/native/protocol_channel_tx.c'
MUTANTS = {
    'strip_prefix': ('channel, frame, length, deadline, budget)', 'channel, frame + 2, length - 2, deadline, budget)'),
    'extend_deadline': ('length, deadline, budget)', 'length, deadline + 1, budget)'),
    'change_budget': ('length, deadline, budget)', 'length, deadline, budget + 1)'),
    'lose_written': ('    return r;\n', '    r.transport.written = 0;\n    return r;\n'),
    'lose_errno': ('    return r;\n', '    r.transport.error = 0;\n    return r;\n'),
    'normalize_failure': ('    return r;\n', '    r.transport.status = DIZZASS_UART_OK;\n    return r;\n'),
    'hide_channel_call': ('.channel_called = true', '.channel_called = false'),
    'wrong_frame_size': ('.frame_size = length', '.frame_size = length - 1'),
    'lose_prepare_error': ('.prepare_status = error', '.prepare_status = error ? -999 : 0'),
    'truncate_address': ('command, broadcast, address, reg, value,', 'command, broadcast, (uint8_t)address, reg, value,'),
    'zero_value': ('command, broadcast, address, reg, value,', 'command, broadcast, address, reg, value & 0u,'),
    'wrap_slot': ('header_words, header_size, slot, frame,', 'header_words, header_size, slot & 31u, frame,'),
    'ignore_route_family': ('family != DIZZASS_WORK_SHA256_TX88', 'family == 0'),
    'send_twice': ('    return r;\n', '    (void)dizzass_uart_channel_send(channel, frame, length, deadline, budget);\n    return r;\n'),
}
def need(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)

def mutations(cc: str, deps: str, out: Path) -> None:
    out.mkdir(parents=True, exist_ok=True)
    text=SOURCE.read_text()
    inputs=[f'{deps}/integration/native/{name}.c' for name in ('uart_channel','uart_posix','uart_safe')]
    inputs+=['integration/bm1368_control.c','integration/work_tx88.c','integration/work_route.c','reconstruction/support/crc5.c','integration/tests/test_protocol_channel_tx.c']
    records=[]
    for name in ('baseline', *MUTANTS):
        changed=text
        if name!='baseline':
            old,new=MUTANTS[name]
            need(text.count(old)==1, f'not a unique mutation site: {name}')
            changed=text.replace(old,new)
        path=out/(name+'.c');binary=out/name;path.write_text(changed)
        cmd=[cc,f'-I{deps}','-I.','-Iinclude','-std=c11','-O1','-g','-Wall','-Wextra','-Wpedantic','-Werror','-pthread',str(path),*inputs,
            '-Wl,--wrap=dizzass_uart_posix_write_all,--wrap=dizzass_uart_posix_now_ms','-o',str(binary)]
        build=subprocess.run(cmd,cwd=ROOT,text=True,capture_output=True,timeout=30)
        (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
        need(build.returncode==0,f'build failure is NOT a semantic rejection: {name}')
        run=subprocess.run([str(binary.resolve())],cwd=ROOT,text=True,capture_output=True,timeout=25)
        (out/(name+'.test.log')).write_text(run.stdout+run.stderr)
        if name=='baseline':
            need(run.returncode==0 and 'PROTOCOL_TX_CONTROL_PASS' in run.stdout,'baseline failed')
        else:
            need(run.returncode==1 and 'PROTOCOL_TX_ASSERT' in run.stderr,f'not a semantic rejection: {name}: {run.returncode}')
        records.append({'name':name,'build_exit':build.returncode,'test_exit':run.returncode})
    report={'compiler':cc,'rejected':len(MUTANTS),'records':records}
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print('PROTOCOL_TX_NEGATIVE_PASS '+json.dumps(report))

def staging(deps: str) -> None:
    tool=ROOT/'tools/prepare_protocol_channel_tx.py'
    manifest=json.loads((ROOT/'integration/evidence/protocol_channel_tx_dependencies.json').read_text())
    count=0
    def run(args: list[str], ok: bool) -> None:
        nonlocal count
        p=subprocess.run([sys.executable,str(tool),*args],cwd=ROOT,text=True,capture_output=True,timeout=15)
        need(p.returncode==(0 if ok else 1) and ('PASS' if ok else 'PROTOCOL_TX_DEPENDENCY_ERROR') in p.stdout+p.stderr,'unexpected staging outcome: '+p.stdout+p.stderr)
        count+=1
    with tempfile.TemporaryDirectory(prefix='a15-staging-',dir=ROOT/'build') as d:
        folder=Path(d);source=folder/'source';source.mkdir();output=folder/'staged'
        for entry in manifest['pending']:
            p=source/entry['path'];p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/deps/entry['path'],p)
        name=str(output.relative_to(ROOT))
        run(['--out',name,'--source-tree',str(source)],True)
        run(['--out',name,'--check'],True)
        run(['--out',name,'--source-tree',str(source)],False)
        entry=manifest['pending'][0]['path'];p=output/entry;original=p.read_bytes();p.write_bytes(original+b'\n')
        run(['--out',name,'--check'],False);p.write_bytes(original)
        extra=output/'integration/native/shadow.h';extra.write_text('')
        run(['--out',name,'--check'],False);extra.unlink()
        p.unlink();p.symlink_to(source/entry);run(['--out',name,'--check'],False);p.unlink();p.write_bytes(original)
        inp=source/entry;inp.write_bytes(original+b'\n')
        run(['--out',str((folder/'bad').relative_to(ROOT)),'--source-tree',str(source)],False);inp.write_bytes(original)
        inp.unlink();inp.symlink_to(p)
        run(['--out',str((folder/'bad').relative_to(ROOT)),'--source-tree',str(source)],False)
        link=folder/'link';link.symlink_to(output,target_is_directory=True)
        run(['--out',str(link.relative_to(ROOT)),'--check'],False)
        run(['--out','integration/not-an-output','--check'],False)
        run(['--out','build/../integration','--check'],False)
    print(f'PROTOCOL_TX_STAGING_PASS checks={count}')

def main() -> int:
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--cc',default='cc');p.add_argument('--deps',default='build/a15-deps');p.add_argument('--out',type=Path,default=ROOT/'build/a15-negative');p.add_argument('--staging-checks',action='store_true');args=p.parse_args()
    try:
        if args.staging_checks:staging(args.deps)
        else:mutations(args.cc,args.deps,args.out)
    except (OSError,ValueError,RuntimeError,subprocess.SubprocessError) as error:
        print(f'PROTOCOL_TX_TEST_ERROR: {error}',file=sys.stderr);return 1
    return 0
if __name__=='__main__':raise SystemExit(main())

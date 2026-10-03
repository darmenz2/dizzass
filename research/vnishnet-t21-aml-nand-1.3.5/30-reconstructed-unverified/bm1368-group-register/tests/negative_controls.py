#!/usr/bin/env python3
"""Compile isolated semantic mutants; only clean fixture assertion failures count."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE=Path(__file__).resolve().parent
CHIP='libbitmain/src/chip/chip1368.c'
GROUP='integration/bm1368_group_register_135.c'
SPAN=(11280,14347)
COMMON='int32_t vn135_bm1368_set_chain_drive_strength_135('
SINGLE='int32_t vn135_bm1368_set_chip_drive_strength_135('

def once(text,old,new):
    if text.count(old)!=1:raise ValueError('mutation anchor is not unique: '+old)
    return text.replace(old,new,1)

def mutate_chip(raw,part,old,new):
    begin,end=SPAN
    text=raw[begin:end].decode('ascii')
    if part=='common':a,b=text.index(COMMON),text.index(SINGLE)
    elif part=='chip':a,b=text.index(SINGLE),text.rindex('#endif')
    else:a,b=0,len(text)
    result=raw[:begin]+(text[:a]+once(text[a:b],old,new)+text[b:]).encode('ascii')+raw[end:]
    if result[:begin]!=raw[:begin] or (raw[end:] and not result.endswith(raw[end:])):
        raise ValueError('mutation escaped historical span')
    return result

MUTATIONS=[
 ('common-nonzero-output','common','uint32_t value = 0;','uint32_t value = 1;'),
 ('chip-nonzero-output','chip','uint32_t value = 0;','uint32_t value = 1;'),
 ('common-read-register','common','0x58, &value)','0x18, &value)'),
 ('chip-read-index','chip','chip->cache_index, 0x58','chip->cache_index + 1, 0x58'),
 ('common-positive-read-accepted','common','0x58, &value) != 0','0x58, &value) < 0'),
 ('chip-positive-read-accepted','chip','0x58, &value) != 0','0x58, &value) < 0'),
 ('common-mask-three-bits','common','setting & 15u','setting & 7u'),
 ('chip-clear-extra-bits','chip','0xffff0fff','0xffff00ff'),
 ('common-shift-eight','common','<< 12','<< 8'),
 ('chip-shift-thirteen','chip','<< 12','<< 13'),
 ('common-wrong-mode','common','device, 1, NULL','device, 2, NULL'),
 ('chip-broadcast-mode','chip','device, 0, chip','device, 1, chip'),
 ('chip-null-descriptor','chip','device, 0, chip','device, 0, NULL'),
 ('common-write-register','common','NULL, 0x58, value','NULL, 0x54, value'),
 ('chip-write-register','chip','chip, 0x58, value','chip, 0x54, value'),
 ('common-read-format','common','driver strenght','drive strength'),
 ('chip-read-line','chip','device, 609,','device, 635,'),
 ('common-write-line','common','device, 645,','device, 619,'),
 ('chip-write-success-on-error','chip','"chain#%d - failed to config drive strength", 1);\n    return -1;','"chain#%d - failed to config drive strength", 1);\n    return 0;'),
 ('common-write-success-on-error','common','"chain#%d - failed to config drive strength", 1);\n    return -1;','"chain#%d - failed to config drive strength", 1);\n    return 0;'),
 ('diagnostic-index-constant','all','has_index ? device->index + UINT32_C(1) : 0','has_index ? (device->index * 0u) + UINT32_C(1) : 0'),
 ('chain-getter-register','all','vn135_reg_cache_get_chain(cache, chain, reg, value)','vn135_reg_cache_get_chain(cache, chain, reg + 1u, value)'),
 ('chip-getter-common-table','all','return vn135_reg_cache_get_chip(cache, chain, chip, reg, value);','(void)chip;\n    return vn135_reg_cache_get_chain(cache, chain, reg, value);'),
]
GROUP_MUTATIONS=[
 ('enable-bit0','if (board->enabled == 0)','if ((board->enabled & 1u) == 0)'),
 ('skip-last-group','while (group >= 1)','while (group > 1)'),
 ('group-index-off-by-one','- UINT32_C(1);','- UINT32_C(0);'),
 ('group-address-index-lost','chip.wire_address = index * board->address_stride;','chip.wire_address = board->address_stride;'),
 ('group-late-owner-board','board->chips_per_group * (uint32_t)group','owner->board->chips_per_group * (uint32_t)group'),
 ('group-late-device','method(owner->context, device, &chip, setting)','method(owner->context, ((void)device, chain->device), &chip, setting)'),
 ('group-ignore-status','if (result != 0)','if (result == 12345)'),
 ('group-raw-status','if (result != 0)\n            return -1;','if (result != 0)\n            return result;'),
 ('group-decrement-two','--group;','group -= 2;'),
 ('group-entry-count-one','int32_t group = board->group_count;','int32_t group = board->group_count > 0 ? 1 : board->group_count;'),
 ('group-setting-low-bit','const uint32_t setting = board->drive_strength;','const uint32_t setting = board->drive_strength & 1u;'),
]

def digest(raw):return hashlib.sha256(raw).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--root',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True);p.add_argument('--cc',default='gcc');a=p.parse_args()
    root=a.root.resolve();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
    spec=importlib.util.spec_from_file_location('host_runner',HERE/'run_host.py')
    runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
    # Resolve local includes from the accepted compile closure rather than copy
    # unrelated repository/original executables into the mutant root.
    paths=set(runner.SOURCES);pending=list(paths)
    import re
    while pending:
        name=pending.pop();path=root/name
        for inc in re.findall(r'^\s*#\s*include\s*"([^"]+)"',path.read_text(),re.M):
            options=[path.parent/inc,root/inc,root/'include'/inc]
            found=next((candidate.resolve() for candidate in options if candidate.is_file()),None)
            if found is None:raise ValueError('unresolved local include: '+inc)
            rel=found.relative_to(root).as_posix()
            if rel not in paths:paths.add(rel);pending.append(rel)
    original_chip=(root/CHIP).read_bytes();original_group=(root/GROUP).read_bytes()
    fixture_sha=digest((HERE/'test_group_register.c').read_bytes())
    if len(original_chip)<SPAN[1]:raise ValueError('historical L14 span missing')
    jobs=[(name,CHIP,mutate_chip(original_chip,part,old,new)) for name,part,old,new in MUTATIONS]
    jobs += [(name,GROUP,once(original_group.decode(),old,new).encode()) for name,old,new in GROUP_MUTATIONS]
    results=[]
    for name,target,changed in jobs:
        if digest((HERE/'test_group_register.c').read_bytes())!=fixture_sha:
            raise ValueError('fixture changed during control run')
        with tempfile.TemporaryDirectory(prefix='l14-'+name+'-') as temp:
            mutant=Path(temp)
            for rel in sorted(paths):
                dest=mutant/rel;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(root/rel,dest)
            (mutant/target).write_bytes(changed)
            command=[sys.executable,str(HERE/'run_host.py'),'--root',str(mutant),
                     '--build',str(out/name),'--test',str(HERE/'test_group_register.c'),'--cc',a.cc]
            result=subprocess.run(command,capture_output=True,text=True,timeout=45)
            record=json.loads((out/name/'compile-records.json').read_text())
            commands=record['commands'];last=commands[-1]
            passed=(len(record['objects'])==len(runner.SOURCES)+1 and
                    all(row['returncode']==0 for row in commands[:-1]) and
                    last['returncode']==1 and 'GROUP_REGISTER_FAIL' in last['stderr'])
            row={'name':name,'target':target,'mutant_sha256':digest(changed),
                 'wrapper_status':result.returncode,'compiled_all_units':len(record['objects'])==10,
                 'clean_fixture_rejection':passed,'failure':last['stderr'],
                 'compile_record_sha256':digest((out/name/'compile-records.json').read_bytes())}
            results.append(row)
            (out/'results.json').write_text(json.dumps({'span':SPAN,'controls':results},indent=2)+'\n')
            if not passed:raise RuntimeError('control did not produce a clean fixture rejection: '+name)
    print(json.dumps({'semantic_controls':len(results),'all_clean_rejections':True,'historical_chip_span':SPAN}))

if __name__=='__main__':main()

#!/usr/bin/env python3
"""Regenerate/verify the eight cache templates from the unchanged original ELF.
Default is read-only comparison; --write updates generated data, not firmware.
"""
from pathlib import Path
import argparse, hashlib, json, struct
from elf32 import ELF32
from arm32_subset import ARM32
ROOT=Path(__file__).resolve().parents[1]
EXPECTED='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
ADDRESSES=[0x5b165c,0x5b145c,0x5b125c,0x5b185c,0x5b1c5c,0x5b1a5c,0x5b1e5c,0x5b205c]
def generated():
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    if hashlib.sha256(elf.data).hexdigest()!=EXPECTED:raise ValueError('Wrong original ELF')
    m=ARM32(elf);tables=[]
    lines=['/* Extracted from the unchanged reference ELF; see evidence/stage4/cache-defaults.json. */',
           'static const vn135_reg_table cache_defaults[8] = {']
    for selector,expected in enumerate(ADDRESSES):
        m.reset((selector,2,3));m.run(0x106a58,stop=0x106b34)
        address=m.r[10]
        if address!=expected:raise ValueError('Selector dispatch changed')
        raw=elf.read(address,512);pairs=list(struct.iter_unpack('<II',raw))
        tables.append({'selector':selector,'address':hex(address),'size':512,
                       'sha256':hashlib.sha256(raw).hexdigest(),'entries':pairs})
        lines += ['    { /* selector %d, original %s */'%(selector,hex(address)), '        {']
        lines += ['            { UINT32_C(0x%08x), UINT32_C(0x%08x) },'%p for p in pairs]
        lines += ['        }','    },']
    lines.append('};\n')
    data={'reference_sha256':EXPECTED,'selection_entry':'0x106a58','stop_before_allocation':'0x106b34',
          'tables':tables,'model_mapping_proven':False,'hardware_settings_recommended':False}
    return '\n'.join(lines),json.dumps(data,indent=2)+'\n'
def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--write',action='store_true');args=ap.parse_args()
    inc,metadata=generated()
    for path,text in [(ROOT/'reconstruction/data/reg_cache_defaults.inc',inc),
                      (ROOT/'evidence/stage4/cache-defaults.json',metadata)]:
        if args.write:path.parent.mkdir(parents=True,exist_ok=True);path.write_text(text)
        elif path.read_text()!=text:raise ValueError(f'Data mismatch: {path}')
    print('cache defaults: 8 selectors, 512 bytes each, '+('written' if args.write else 'PASS'))
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Pin original start instructions, address indirections and Ghidra output."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
def main():
    r=json.loads((ROOT/'integration/evidence/work_start_135.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==r['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    ranges={'start':(0xc3b54,0xc3db4),'literals':(0xc3db4,0xc3e18),'producer_slot':(0x5df978,0x5df97c),
            'parity_slot':(0x5df468,0x5df46c),'opaque_limit_slot':(0x5deec0,0x5deec4),'log_data_context':(0x5e962e,0x5e9790)}
    assert set(r['slices'])==set(ranges)
    for name,(a,b) in ranges.items():
        item=r['slices'][name];assert (int(item['start'],16),int(item['end_exclusive'],16))==(a,b)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==item['sha256'],name
    def word(a):return int.from_bytes(elf.read(a,4),'little')
    assert word(0xc3b54)==0xe92d4df0 and word(0xc3b58)==0xe28db018 and word(0xc3b5c)==0xe24dd010
    assert word(0xc3b60)==0xe28d500c and word(0xc3db0)==0xe8bd8df0
    targets=[(0xc3db4,0xc3b8c,0x633af0),(0xc3db8,0xc3b9c,0x633b08),(0xc3dbc,0xc3bac,0x633ba8),
        (0xc3dc0,0xc3bbc,0x633bc0),(0xc3dc4,0xc3bdc,0xc4054),(0xc3dec,0xc3c44,0x5df978),(0xc3e04,0xc3cc8,0xc4b18)]
    for lit,pc8,target in targets:assert (word(lit)+pc8)&0xffffffff==target
    assert word(0x5df978)==0xc2498
    assert len(r['literal_targets'])==25
    for item in r['literal_targets']:assert (word(int(item['literal'],16))+int(item['pc8'],16))&0xffffffff==int(item['target'],16)
    assert r['entry']=='0xc3b54' and r['return_instruction']=='0xc3db0' and r['ghidra']['version']=='12.1.4'
    artifacts=r['ghidra']['artifacts'];assert set(artifacts)=={'InspectWorkStart.java','c3b54.ghidra.c','c3b54.ghidra.asm','headless.log'}
    for name,item in artifacts.items():assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    assert 'WORK_START_GHIDRA_DONE [[000c3b54, 000c3db3]]' in artifacts['headless.log']['text']
    print('WORK_START_EVIDENCE_PASS slices=6 literal_targets=25 ghidra_artifacts=4')
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Pin original stop body/literals/indirections and embedded Ghidra artifacts."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
def main():
    r=json.loads((ROOT/'integration/evidence/work_stop_135.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==r['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    ranges={'stop':(0xc3e18,0xc4038),'literals':(0xc4038,0xc4050),'parity_slot':(0x5de7ec,0x5de7f0),'opaque_limit_slot':(0x5dfb90,0x5dfb94)}
    assert set(r['slices'])==set(ranges)
    for name,(a,b) in ranges.items():
        item=r['slices'][name];assert (int(item['start'],16),int(item['end_exclusive'],16))==(a,b)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==item['sha256'],name
    def word(a):return int.from_bytes(elf.read(a,4),'little')
    targets=[(0xc4038,0xc3e30,0x5de7ec),(0xc403c,0xc3e44,0x5dfb90),
        (0xc4040,0xc3fa0,0x633bc0),(0xc4044,0xc3fac,0x633ba8),(0xc4048,0xc3fb8,0x633b08),(0xc404c,0xc3fc4,0x633af0)]
    assert [(int(i['literal'],16),int(i['pc8'],16),int(i['target'],16)) for i in r['literal_targets']]==targets
    for lit,pc8,target in targets:assert (word(lit)+pc8)&0xffffffff==target
    assert r['entry']=='0xc3e18' and r['return_instruction']=='0xc4034' and r['ghidra']['version']=='12.1.4'
    assert word(0xc4030)==0xe3a00000 and word(0xc4034)==0xe8bd8df0
    artifacts=r['ghidra']['artifacts'];assert set(artifacts)=={'InspectWorkStop.java','c3e18.ghidra.c','c3e18.ghidra.asm','headless.log'}
    for name,item in artifacts.items():assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    assert 'WORK_STOP_RESEARCH_DONE [[000c3e18, 000c4037]]' in artifacts['headless.log']['text']
    print('WORK_STOP_EVIDENCE_PASS slices=4 literal_targets=6 ghidra_artifacts=4')
if __name__=='__main__':main()

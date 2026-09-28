#!/usr/bin/env python3
"""Pin raw function bodies, selector provenance window and Ghidra context."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
TARGETS=[(0xc3b38,0xc3a38,0x5e9659),(0xc3b3c,0xc3a40,0x5e962e),(0xc3b40,0xc3a44,0x5e9660),(0xc3b44,0xc3a4c,0x5e966b),
 (0xc3b48,0xc39e8,None),(0xc3b4c,0xc39fc,None),(0xc3b50,0xc3a04,0x633bf0),(0xfeef8,0xfeef8,0x654c1c),
 (0xd21d4,0xd2168,None),(0xd21d8,0xd217c,None),(0x10ea54,0x10e9e8,None),(0x10ea58,0x10e9fc,None),
 (0x116fa0,0x116f24,None),(0x116fa4,0x116f38,None)]
def ranges(elf):
    result={'chain':(0xc39a8,0xc3b54),'allocation':(0xd2144,0xd21dc),'thunk':(0xfeeec,0xfeefc),
      'uart':(0x10e9a0,0x10ea5c),'xil_context':(0x116f00,0x116fa8),'initializer_prefix':(0xfb994,0xfbc00),
      'initializer_literals':(0xfc600,0xfc6b0),'log_context':(0x5e962e,0x5e9690)}
    for lit,pc8,target in TARGETS:
        if target is None:
            a=(int.from_bytes(elf.read(lit,4),'little')+pc8)&0xffffffff;result[f'slot_{lit:x}']=(a,a+4)
    return result
def main():
    r=json.loads((ROOT/'integration/evidence/chain_work_stop_135.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==r['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    expected=ranges(elf);assert set(r['slices'])==set(expected)
    for name,(a,b) in expected.items():
        item=r['slices'][name];assert (int(item['start'],16),int(item['end_exclusive'],16))==(a,b)
        assert hashlib.sha256(elf.read(a,b-a)).hexdigest()==item['sha256'],name
    assert len(r['literal_targets'])==len(TARGETS)
    for item,(lit,pc8,target) in zip(r['literal_targets'],TARGETS):
        actual=(int.from_bytes(elf.read(lit,4),'little')+pc8)&0xffffffff
        assert (item['literal'],item['pc8'],item['target'])==(hex(lit),hex(pc8),hex(actual))
        if target is not None:assert actual==target
    artifacts=r['ghidra']['artifacts'];entries=('c39a8','d2144','feeec','fb994','10e9a0','116f00')
    assert set(artifacts)=={'InspectChainWorkStop.java','headless.log'}|{e+'.ghidra.'+ext for e in entries for ext in ('c','asm')}
    assert r['ghidra']['version']=='12.1.4'
    for name,item in artifacts.items():assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    for entry in entries:assert 'CHAIN_WORK_STOP_GHIDRA_DONE '+entry in artifacts['headless.log']['text']
    from test_chain_work_stop_135 import provenance
    actual=provenance(elf);assert actual==r['slot_provenance']
    print(f'CHAIN_WORK_STOP_EVIDENCE_PASS slices={len(expected)} literal_targets={len(TARGETS)} ghidra_artifacts={len(artifacts)} provenance={len(actual)}')
if __name__=='__main__':main()

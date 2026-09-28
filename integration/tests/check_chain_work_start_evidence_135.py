#!/usr/bin/env python3
"""Verify immutable original bytes, literal identities and bounded bindings."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
TARGETS=[(0xc369c,0xc33ec,None),(0xc36a0,0xc3400,None),
 (0xc36a4,0xc3538,0x5e9659),(0xc36a8,0xc3540,0x5e962e),(0xc36ac,0xc3544,0x5e9660),(0xc36b0,0xc3548,0x5e966b),
 (0xc36b4,0xc3500,0x5e9659),(0xc36b8,0xc3508,0x5e962e),(0xc36bc,0xc350c,0x5e9660),(0xc36c0,0xc3514,0x5e9682),
 (0xc36c4,0xc359c,0xc36e8),(0xc36c8,0xc35f8,0x5e96a7),
 (0xc36cc,0xc3624,0x5e9659),(0xc36d0,0xc362c,0x5e962e),(0xc36d4,0xc3630,0x5e9660),
 (0xc36d8,0xc35d8,0xc36e8),(0xc36dc,0xc367c,0x5e9659),(0xc36e0,0xc3684,0x5e962e),(0xc36e4,0xc3688,0x5e9660),
 (0xfeedc,0xfee68,None),(0xfeee0,0xfee7c,None),(0xfeee4,0xfeea0,0x654c18),(0xfeee8,0xfeed4,0x654c18),(0xfef48,0xfef48,0x654b4c)]
ENTRIES=('c33d0','d19b0','fef3c','fee4c','fb994','10e0c8','116dd8')
def ranges(elf):
    result={'chain':(0xc33d0,0xc36e8),'fifo':(0xd19b0,0xd19f0),'path_thunk':(0xfef3c,0xfef4c),
        'open_dispatch':(0xfee4c,0xfeeec),'initializer_window':(0xfb994,0xfddfc),
        'uart_context':(0x10e0c8,0x10e518),'xil_context':(0x116dd8,0x116e40),'log_context':(0x5e962e,0x5e96d0)}
    for lit,pc8,target in TARGETS:
        if target is None:
            addr=(int.from_bytes(elf.read(lit,4),'little')+pc8)&0xffffffff
            result[f'slot_{lit:x}']=(addr,addr+4)
    return result
def main():
    r=json.loads((ROOT/'integration/evidence/chain_work_start_135.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
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
    decoded=bytes(v^9 for v in elf.read(0x5e962e,43)).split(b'\0')[0].decode()
    assert decoded==r['source_path']=='/tmp/build/src/backend/work-gen/work-gen.c'
    artifacts=r['ghidra']['artifacts']
    assert set(artifacts)=={'InspectChainWorkStart.java','headless.log'}|{e+'.ghidra.'+ext for e in ENTRIES for ext in ('c','asm')}
    assert r['ghidra']['version']=='12.1.4'
    for name,item in artifacts.items():assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    for e in ENTRIES:assert 'CHAIN_WORK_START_GHIDRA_DONE '+e in artifacts['headless.log']['text']
    from test_chain_work_start_135 import provenance
    actual=provenance(elf);assert actual==r['slot_provenance']
    print(f'CHAIN_WORK_START_EVIDENCE_PASS slices={len(expected)} literal_targets={len(TARGETS)} ghidra_artifacts={len(artifacts)} provenance={len(actual)}')
if __name__=='__main__':main()

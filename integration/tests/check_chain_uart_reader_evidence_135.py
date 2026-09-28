#!/usr/bin/env python3
"""Pin original bytes and literal targets; verify actual Ghidra/provenance."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from test_chain_uart_reader_135 import PARITY,provenance
TARGETS=[(a,b,None) for a,b in PARITY]+[(0xc3990,0xc3808,0x5e973e),(0xc39a0,0xc3960,0x653410),(0xc39a4,0xc3970,0x653428),(0xfef28,0xfef28,0x654c28),(0xfdfb8,0xfdfb8,0x654b08),(0xfdfc8,0xfdfc8,0x654b0c),(0xfe10c,0xfe0dc,0x654b24)]
ENTRIES=('c36e8','fef1c','d1bc8','5b150','d20b4','d20ac','fe0b0','fdfbc','fdfac','10e938','116fa8','5a6b2c')
def ranges(elf):
    result={'reader':(0xc36e8,0xc39a8),'wait':(0x5b150,0x5b1dc),'capacity':(0xd20b4,0xd212c),'count':(0xd20ac,0xd20b4),
      'bulk_context':(0xd1bc8,0xd1cf0),'dispatch':(0xfef1c,0xfef2c),'getters':(0xfdfac,0xfdfcc),'force':(0xfe0b0,0xfe114),
      'uart':(0x10e938,0x10e994),'xil_context':(0x116fa8,0x117074),'setter_context':(0x5a6b2c,0x5a6b60),
      'unsigned_division':(0x590e28,0x590ec4),'initializer':(0xfb994,0xfddfc),'source':(0x5e962e,0x5e9659),'format_context':(0x5e973e,0x5e9750)}
    for lit,pc8,target in TARGETS:
        if target is None:
            a=(int.from_bytes(elf.read(lit,4),'little')+pc8)&0xffffffff;result[f'slot_{lit:x}']=(a,a+4)
    return result
def main():
    r=json.loads((ROOT/'integration/evidence/chain_uart_reader_135.json').read_text());elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest()==r['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    expected=ranges(elf);assert set(expected)==set(r['slices'])
    for name,(a,b) in expected.items():
        item=r['slices'][name];assert (item['start'],item['end_exclusive'],item['sha256'])==(hex(a),hex(b),hashlib.sha256(elf.read(a,b-a)).hexdigest()),name
    assert len(r['literal_targets'])==len(TARGETS)
    for item,(lit,pc8,target) in zip(r['literal_targets'],TARGETS):
        actual=(int.from_bytes(elf.read(lit,4),'little')+pc8)&0xffffffff
        assert (item['literal'],item['pc8'],item['target'])==(hex(lit),hex(pc8),hex(actual))
        if target is not None:assert actual==target
    assert bytes(v^9 for v in elf.read(0x5e962e,43)).split(b'\0')[0].decode()==r['source_path']=='/tmp/build/src/backend/work-gen/work-gen.c'
    artifacts=r['ghidra']['artifacts'];assert r['ghidra']['version']=='12.1.4'
    assert set(artifacts)=={'InspectChainUartReader.java','headless.log'}|{e+'.ghidra.'+ext for e in ENTRIES for ext in ('c','asm')}
    for name,item in artifacts.items():assert hashlib.sha256(item['text'].encode()).hexdigest()==item['sha256'],name
    for e in ENTRIES:assert 'CHAIN_UART_READER_GHIDRA_DONE '+e in artifacts['headless.log']['text']
    actual=provenance(elf);assert actual==r['slot_provenance']
    print(f'CHAIN_UART_READER_EVIDENCE_PASS slices={len(expected)} targets={len(TARGETS)} artifacts={len(artifacts)} probes={len(actual)}')
if __name__=='__main__':main()

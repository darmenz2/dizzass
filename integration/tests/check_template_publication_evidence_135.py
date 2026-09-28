#!/usr/bin/env python3
"""Pin actual data, identities and Ghidra record; no ELF native execution."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2];sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
SLICES={'publish':(0xc3148,0xc3390),'publish_literals':(0xc3390,0xc33d0),
        'clone_boundary':(0x5cd70,0x5ce44),'queue_reset':(0xfa944,0xfa97c),
        'ring_reset':(0xd212c,0xd2144)}
TARGETS=((0xc3390,0xc3160,0x633af0),(0xc3394,0xc316c,0x633b40),
         (0xc33a8,0xc3290,0x633b40),(0xc33ac,0xc32a0,0x633b38),
         (0xc33c0,0xc3344,0x633b08),(0xc33c4,0xc3350,0x633af0),
         (0xc33c8,0xc337c,0x633b08),(0xc33cc,0xc3388,0x633af0),
         (0xfa974,0xfa958,0x654ad0),(0xfa978,0xfa968,0x654ae8))
def digest(b):return hashlib.sha256(b).hexdigest()
def check():
    e=ELF32(ROOT/'reference/cgminer.vendor.elf')
    d=json.loads((ROOT/'integration/evidence/template_publication_135.json').read_text())
    assert digest(e.data)==d['elf_sha256']=='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
    assert d['archive_sha256']=='20fabdd66255889315e61ae2a33ff2e4623566ca430f1cb8c90d9b938dc7b43c'
    assert set(d['slices'])==set(SLICES)
    for name,(a,b) in SLICES.items():
        s=d['slices'][name];assert (s['start'],s['end_exclusive'],s['sha256'])==(hex(a),hex(b),digest(e.read(a,b-a)))
    assert d['literal_targets']==[{'literal':hex(a),'pc8':hex(b),'target':hex(c)} for a,b,c in TARGETS]
    for a,b,c in TARGETS:assert (int.from_bytes(e.read(a,4),'little')+b)&0xffffffff==c
    for name,a in d['ghidra']['artifacts'].items():assert digest(a['text'].encode())==a['sha256'],name
    log=d['ghidra']['artifacts']['headless.log']['text']
    assert all('TEMPLATE_PUBLICATION_RESEARCH_DONE '+s in log for s in ('c3148','5cd70','fa944'))
    assert '[[000fa944, 000fa973] [005a66c4, 005a6877]]' in log
    assert d['clone_implemented'] is False and d['production_wired'] is False
    # The obfuscator predicate vanishes for BOTH possible low bits, including
    # wrapping subtraction/multiply. Runtime boundary cases are separate tests.
    assert all((x*((x-1)&0xffffffff)&1)==0 for x in (0,1,2,0x7fffffff,0x80000000,0xffffffff))
    print(f'TEMPLATE_PUBLICATION_EVIDENCE_PASS slices={len(SLICES)} targets={len(TARGETS)} ghidra={len(d["ghidra"]["artifacts"])}')
if __name__=='__main__':check()

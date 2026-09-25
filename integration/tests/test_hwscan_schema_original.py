#!/usr/bin/env python3
"""Original key-argument setup and slot wrap; never runs firmware as a process."""
from pathlib import Path
import hashlib
import json
import sys
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'tools'))
from elf32 import ELF32
from arm32_nonce_subset import ARM32Nonce

def main():
    e=json.loads((ROOT/'integration/evidence/hwscan_io.json').read_text())
    elf=ELF32(ROOT/'reference/cgminer.vendor.elf')
    if hashlib.sha256(elf.data).hexdigest()!=e['reference_sha256']:
        raise ValueError('Different reference ELF')
    literals={}
    for item in e['literals']:
        address=int(item['address'],16); value=item['value'].encode()+b'\0'
        raw=elf.read(address,len(value))
        if hashlib.sha256(raw).hexdigest()!=item['sha256'] or bytes(v^item['xor'] for v in raw)!=value:
            raise ValueError('Literal mismatch: '+item['address'])
        literals[address]=value[:-1].decode()
    m=ARM32Nonce(elf); objects=[]
    for item in e['layouts']:
        start,stop=int(item['start'],16),int(item['stop_before_call'],16)
        if hashlib.sha256(elf.read(start,stop-start)).hexdigest()!=item['range_sha256']:
            raise ValueError('Argument setup slice mismatch')
        m.reset(); b=m.DATA_BASE; fp=m.STACK_TOP-0x400
        for i in range(13):m.r[i]=b+0x100*i
        m.r[11]=fp;m.r[13]=m.STACK_TOP-0x1000
        # Addresses of scratch destinations, NOT precomputed parser results.
        for i in range(0,0x180,4):m.write(fp-i,b+0x2000+i*4)
        if start==0xaa274:m.r[1]=int.from_bytes(elf.read(0xab234,4),'little')
        if start==0xb2f40:m.r[2]=int.from_bytes(elf.read(0xb39f8,4),'little')
        def object_get(cpu):
            objects.append(literals[cpu.r[1]])
            cpu.r[0]=b+0x6000
        m.run(start,stop=stop,hooks={0x1527a8:object_get},max_steps=2000)
        keys=[m.read(m.r[13]+8*i) for i in range(len(item['keys']))]
        if keys!=[int(k,16) for k in item['keys']] or m.r[3]!=int(item['format'],16):
            raise ValueError('Original parser key/format mismatch: '+item['name'])
        if m.r[2]!=0:raise ValueError('Unexpected original JSON flags')
        print('SCHEMA',item['name'],literals[m.r[3]],','.join(literals[k] for k in keys))
    if objects!=['board','chip']:raise ValueError('Nested object names mismatch')
    item=e['slot_advance'];start,stop=int(item['start'],16),int(item['stop'],16)
    if hashlib.sha256(elf.read(start,stop-start)).hexdigest()!=item['range_sha256']:
        raise ValueError('Slot advance slice mismatch')
    address=(0xc4dc0+8+int.from_bytes(elf.read(0xc506c,4),'little'))&0xffffffff
    if address!=int(item['global'],16):raise ValueError('Slot global mismatch')
    for slot in range(32):
        m.reset();m.r[8]=m.DATA_BASE;m.write(address,slot)
        m.run(start,stop=stop,max_steps=30)
        if m.read(m.DATA_BASE)!=(slot+1)%32:raise ValueError('Original slot wrap mismatch')
    print(f'HWSCAN_ORIGINAL_PASS layouts=5 literals={len(literals)} slot_transitions=32 parser_or_scanner_executed=no')
if __name__=='__main__':main()

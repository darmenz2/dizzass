#!/usr/bin/env python3
"""Verify fixed static witnesses; optionally compare both original ELF inputs.

Only decoding, byte hashing and PC-relative arithmetic are used. No original
instruction executes, no machine state is simulated, and no method is called.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
from capstone import Cs, CS_ARCH_ARM, CS_MODE_ARM
from elftools.elf.elffile import ELFFile
import io

CODE_HASH='d1e526e4c773e51a22151a4082d3800142244982a9f7bfbc15ede6081b21559f'
SPECS={
 'cgminer':dict(entry=0xe1450,size=6228004,sha='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9',
    literals='6e3a9c4dcbaa131c081f211a991efdb31921ac30218319e4bb2086e8466d2154',
    got='96c7c476ea2cafe04c89dd079ae29c810993c84885c9d569b246608f4f5d4456'),
 'hwscan':dict(entry=0xf1d28,size=4883216,sha='951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077',
    literals='f4ba8cfd7d0fd13754f2ee3f8e7e869aa73aac00fcadd73349502fb17373d365',
    got='f1fcb37ae96a5d9a9571d1427c608f5b2a9cd3d43700723040b3bca8858f8272')}
OFFSETS=[0xdc]+list(range(0xd8,0x18,-4))+[0x14,0x10,0xc,8,4]
STORE_ORDER=[0xdc]+[x for b in [0xbc,0x9c,0x7c,0x5c,0x3c,0x1c] for x in range(b,b+32,4)]+[4,8,12,16,20]
STORE_PCS=[0x10,0x54,0x58,0x5c,0x60,0x68,0x68,0x68,0x6c]
for _base in [0xb0,0x108,0x160,0x1b8,0x210]:
    STORE_PCS += [_base,_base+8,_base+8,_base+8,_base+8,_base+12,_base+16,_base+20]
STORE_PCS += [0x250,0x250,0x254,0x258,0x25c]

def require(ok,why):
    if not ok: raise ValueError(why)
def sha(b):return hashlib.sha256(b).hexdigest()
def word(b,o):return struct.unpack_from('<I',b,o)[0]

class FileImage:
    def __init__(self,path,spec):
        self.raw=path.read_bytes()
        require(len(self.raw)==spec['size'] and sha(self.raw)==spec['sha'],'ELF source identity')
        elf=ELFFile(io.BytesIO(self.raw))
        require(elf.elfclass==32 and elf.little_endian and elf['e_machine']=='EM_ARM' and elf['e_type']=='ET_EXEC','ELF format')
        self.loads=[dict(s.header) for s in elf.iter_segments() if s['p_type']=='PT_LOAD']
    def read(self,address,size):
        for s in self.loads:
            if s['p_vaddr']<=address and address+size<=s['p_vaddr']+s['p_filesz']:
                off=s['p_offset']+address-s['p_vaddr'];return self.raw[off:off+size]
        raise ValueError('unbacked source range')

def check(directory,source_paths=None):
    source_paths=source_paths or {}
    p=json.loads((directory/'constructor-proof.json').read_text())
    require(p['schema']==1 and p['kind']=='static-bm1368-method-identity-constructor','schema')
    require(p['original_executed'] is False and p['instruction_interpreter_used'] is False,'execution boundary')
    require(p['code_bytes']==616 and p['literal_bytes']==216 and p['output_extent_bytes']==224,'sizes')
    require(p['untouched_offsets']==[0,24] and p['ordered_store_offsets']==STORE_ORDER,'output write shape')
    require(p['identical_code_bytes'] is True and set(p['sources'])==set(SPECS),'source set')
    checked=[]
    for name,spec in SPECS.items():
        s=p['sources'][name];entry=spec['entry'];folder=directory/name
        require(s['source_sha256']==spec['sha'] and s['source_bytes']==spec['size'] and int(s['entry'],16)==entry,'source provenance')
        require(s['code_sha256']==CODE_HASH and s['literal_sha256']==spec['literals'],'source range identities')
        artifacts={k:(folder/k).read_bytes() for k in ['body.asm','body.json','literals.asm','literals.json']}
        require(set(s['artifact_sha256'])==set(artifacts),'artifact names')
        for k,b in artifacts.items():require(sha(b)==s['artifact_sha256'][k],'artifact digest '+name+'/'+k)
        code_meta=json.loads(artifacts['body.json']);pool_meta=json.loads(artifacts['literals.json'])
        code=bytes.fromhex(code_meta['bytes_hex']);pool=bytes.fromhex(pool_meta['bytes_hex'])
        for meta,b,start,size,digest in [(code_meta,code,entry,616,CODE_HASH),(pool_meta,pool,entry+616,216,spec['literals'])]:
            require(len(b)==size and int(meta['start'],16)==start and int(meta['end_exclusive'],16)==start+size,'range bounds')
            require(sha(b)==digest==meta['sha256'],'fixed range hash')
        instructions=list(Cs(CS_ARCH_ARM,CS_MODE_ARM).disasm(code,entry))
        require(len(instructions)==154 and all(i.size==4 for i in instructions),'complete A32 decode')
        assembly='\n'.join(f'{i.address:08x}  {i.bytes.hex():8s}  {i.mnemonic:8s} {i.op_str}' for i in instructions)+'\n'
        pools='\n'.join(f'{entry+616+i:08x}  {pool[i:i+4].hex()}  .word  0x{word(pool,i):08x}' for i in range(0,216,4))+'\n'
        require(artifacts['body.asm']==assembly.encode() and artifacts['literals.asm']==pools.encode(),'static rendering')
        decoded={i.address:f'{i.mnemonic} {i.op_str}' for i in instructions}
        pairs=[i for i in range(0,616,4) if word(code,i)&0xffff0000==0xe59f0000]
        rows=s['method_words'];require(len(rows)==len(pairs)==54,'method count')
        packed=b''.join(bytes.fromhex(x['got_bytes']) for x in rows)
        require(len(packed)==216 and sha(packed)==spec['got'],'fixed GOT word set')
        image=FileImage(source_paths[name],spec) if name in source_paths else None
        if image:
            require(image.read(entry,616)==code and image.read(entry+616,216)==pool,'ELF body and pool')
        for index,(row,rel) in enumerate(zip(rows,pairs)):
            reg=(word(code,rel)>>12)&15
            require(word(code,rel+4)==(0xe79f0000|(reg<<12)|reg),'paired GOT load')
            require(len(bytes.fromhex(row['got_bytes']))==4,'GOT cell width')
            literal=entry+rel+8+(word(code,rel)&0xfff)
            require(literal==entry+616+4*index,'literal sequence')
            value=word(pool,4*index);got=(entry+rel+12+value)&0xffffffff
            require(row['literal_index']==index and row['output_offset']==OFFSETS[index],'destination mapping')
            require(int(row['load_instruction'],16)==entry+rel and int(row['got_load_instruction'],16)==entry+rel+4,'load edges')
            require(row['register']==reg and int(row['literal_address'],16)==literal and int(row['literal_word'],16)==value,'literal metadata')
            require(int(row['got_address'],16)==got and int(row['method_identity'],16)==word(packed,4*index),'GOT arithmetic')
            order=STORE_ORDER.index(OFFSETS[index]);store=entry+STORE_PCS[order]
            require(row['store_order']==order+1 and int(row['store_instruction'],16)==store and row['store_description']==decoded[store],'ordered store witness')
            if image:require(image.read(got,4)==bytes.fromhex(row['got_bytes']),'ELF GOT cell')
        checked.append({'source':name,'methods':54,'code_bytes':616,'literal_bytes':216,'got_bytes':216,'original_source_checked':bool(image)})
    return checked

def main():
    a=argparse.ArgumentParser();a.add_argument('--evidence',type=Path,default=Path(__file__).resolve().parent/'evidence')
    a.add_argument('--cgminer',type=Path);a.add_argument('--hwscan',type=Path);args=a.parse_args()
    checked=check(args.evidence,{n:getattr(args,n) for n in SPECS if getattr(args,n)})
    print('BM1368_INIT_STATIC_PASS '+json.dumps(checked,sort_keys=True))
if __name__=='__main__':main()

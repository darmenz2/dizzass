#!/usr/bin/env python3
"""Verify bounded static data and source identities for the register58 unit.
No original process, CPU state, instruction stepping, emulator or hardware I/O.
Manual CFG/parity/ABI contracts are pinned; this is not automatic equivalence.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import struct

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PINS_SHA256 = '0aae42fe26bc9c6a06ccbaddaa55f3bf4be8ed6093221f53fc1ac130bd889f5c'
MAX_JSON_BYTES = 1_000_000
MAX_SOURCE_BYTES = 16_000_000
EXTENTS = {'cgminer':{'chip':(0xe3728,0xe39dc,0xe3a1c),'common':(0xe3a1c,0xe3b88,0xe3bbc)},
           'hwscan':{'chip':(0xf33ec,0xf34dc,0xf34fc),'common':(0xf34fc,0xf35e8,0xf3608)}}
TARGETS = {'cgminer':{'get_common':0x107188,'get_chip':0x1079f0,'writer':0xe4a74,'logger':0xfa0c4},
           'hwscan':{'get_common':0x10564c,'get_chip':0x105a20,'writer':0xf3d7c,'logger':0xfeeb0}}

class EvidenceError(ValueError):
    pass

def require(condition, message):
    if not condition:
        raise EvidenceError(message)

def sha(data):
    return hashlib.sha256(data).hexdigest()

def keys(value, expected, label):
    require(type(value) is dict and set(value)==set(expected), label+': unexpected keys/type')

def integer(value, label, maximum=0xffffffff):
    require(type(value) is int and 0<=value<=maximum, label+': invalid integer')

def digest(value, label):
    require(type(value) is str and re.fullmatch('[0-9a-f]{64}',value) is not None,label+': invalid SHA256')

def strict_pairs(pairs):
    value={}
    for key,item in pairs:
        require(key not in value,'duplicate JSON key: '+key)
        value[key]=item
    return value

def bad_constant(value):
    raise EvidenceError('non-finite JSON value: '+value)

def load_json(path):
    path=Path(path)
    require(path.stat().st_size<=MAX_JSON_BYTES,'JSON budget exceeded')
    raw=path.read_bytes()
    value=json.loads(raw,object_pairs_hook=strict_pairs,parse_constant=bad_constant)
    return value,raw

def canonical(value):
    return json.dumps(value,sort_keys=True,separators=(',',':'),allow_nan=False).encode('ascii')

def metadata(witness):
    value=copy.deepcopy(witness)
    for source in value['sources'].values():
        for region in source['regions']:
            del region['bytes_hex']
    return value

class Ranges:
    def __init__(self,regions,expected):
        require(type(regions) is list and 0<len(regions)<100,'invalid range list')
        self.items=[]
        self.by_id={}
        end=0
        for region in regions:
            keys(region,['id','kind','va','file_offset','size','sha256','bytes_hex'],'range')
            name=region['id']
            require(type(name) is str and name and name not in self.by_id,'invalid/duplicate range id')
            require(region['kind'] in ('code','data'),'range kind')
            integer(region['va'],'range address');integer(region['size'],'range size',MAX_JSON_BYTES)
            require(region['size']>0 and region['va']>=end,'empty/overlapping/unsorted range')
            end=region['va']+region['size'];require(end<=0x100000000,'range overflow')
            if region['kind']=='code':require(region['va']%4==0 and region['size']%4==0,'unaligned ARM code')
            digest(region['sha256'],'range')
            text=region['bytes_hex']
            require(type(text) is str and len(text)==region['size']*2 and re.fullmatch('[0-9a-f]+',text) is not None,'invalid bounded hex')
            raw=bytes.fromhex(text);require(sha(raw)==region['sha256'],'range bytes/hash mismatch: '+name)
            self.items.append((region,raw));self.by_id[name]=region
        require([{k:v for k,v in region.items() if k!='bytes_hex'} for region in regions]==expected,
                'range identity differs from independent pins')
    def read(self,address,size):
        integer(address,'read address');integer(size,'read size',MAX_JSON_BYTES)
        require(size>0,'empty read')
        for region,raw in self.items:
            off=address-region['va']
            if 0<=off and off+size<=len(raw):return raw[off:off+size]
        raise EvidenceError('read outside witnessed range: '+hex(address))
    def word(self,address):
        require(address%4==0,'unaligned word')
        return int.from_bytes(self.read(address,4),'little')

# These decode one fixed instruction field; they do not operate a CPU or trace.
def branch(word,address):
    require(word&0x0e000000==0x0a000000,'expected immediate branch')
    offset=word&0xffffff
    if offset&0x800000:offset-=0x1000000
    return (address+8+offset*4)&0xffffffff,bool(word&0x01000000),word>>28

def immediate(word):
    value=word&255;rotation=((word>>8)&15)*2
    return ((value>>rotation)|(value<<((32-rotation)%32)))&0xffffffff

def expect_words(reader,words,label):
    for address,value in words.items():
        require(reader.word(address)==value,label+' at '+hex(address))

def verify_operands(source,reader):
    require(type(source['operands']) is list,'invalid operands')
    expected=[a for r,_ in reader.items if r['kind']=='code' for a in range(r['va'],r['va']+r['size'],4)]
    seen=[]
    for row in source['operands']:
        require(type(row) is list and len(row)==4,'invalid operand row')
        address,raw,mnemonic,operands=row
        integer(address,'operand address')
        require(type(raw) is str and re.fullmatch('[0-9a-f]{8}',raw) is not None,'operand bytes')
        require(reader.read(address,4).hex()==raw,'operand annotation byte mismatch')
        require(type(mnemonic) is str and mnemonic and type(operands) is str,'operand annotation type')
        seen.append(address)
    require(seen==expected,'operands must annotate every and only code word once')

def verify_methods(name, source, reader):
    keys(source['methods'], ['chip','common'], 'methods')
    for kind, method in source['methods'].items():
        keys(method, ['branches','calls','code_end_exclusive','code_start','literal_loads','pool_end_exclusive'], 'method')
        start,end,pool_end = EXTENTS[name][kind]
        require((method['code_start'],method['code_end_exclusive'],method['pool_end_exclusive']) == (start,end,pool_end), 'method extent')
        calls=[]; branches=[]; literals=[]
        for address in range(start,end,4):
            word=reader.word(address)
            if word & 0x0e000000 == 0x0a000000:
                target,link,condition=branch(word,address)
                if link:
                    require(condition==14 and target in TARGETS[name].values(), 'unexpected wrapper call')
                    call_kind=next(k for k,v in TARGETS[name].items() if v==target)
                    calls.append({'at':address,'kind':call_kind,'target':target})
                else:
                    require(start<=target<end,'wrapper branch leaves code')
                    branches.append({'at':address,'condition':condition,'target':target})
            if word & 0xffff0000 == 0xe59f0000:
                literal=address+8+(word & 4095)
                require(end<=literal<pool_end,'literal outside method pool')
                literals.append({'literal':literal,'load':address,'register':(word>>12)&15,'word':reader.word(literal)})
        require(method['calls']==calls and method['branches']==branches and method['literal_loads']==literals,'method effect/branch/literal inventory')
        require({r['literal'] for r in literals}==set(range(end,pool_end,4)),'method pool coverage')
        require(reader.word(end-4)&0xffff8000==0xe8bd8000,'method final return')

def verify_slots_references(source, reader):
    require(type(source['slots']) is list and len(source['slots'])==2,'constructor slot count')
    for slot in source['slots']:
        keys(slot,['backend_offset','base_add','got','got_load','literal','literal_word','load','method','offset','register','stm_store'],'constructor slot')
        for value in slot.values(): integer(value,'slot word')
        off=slot['offset'];reg=slot['register']
        require((off,reg) in ((0x84,4),(0x88,5)) and slot['backend_offset']==off+0x110,'selected constructor slot')
        word=reader.word(slot['load'])
        require(word & 0xfffff000 == 0xe59f0000 | (reg<<12),'constructor literal load')
        require(slot['load']+8+(word&4095)==slot['literal'],'constructor literal address')
        require(reader.word(slot['literal'])==slot['literal_word'],'constructor literal word')
        require(reader.word(slot['got_load'])==0xe79f0000|(reg<<12)|reg,'constructor GOT load')
        require((slot['got_load']+8+slot['literal_word'])&0xffffffff==slot['got'],'constructor GOT address')
        require(reader.word(slot['got'])==slot['method']==source['methods']['chip' if off==0x84 else 'common']['code_start'],'constructor method identity')
        require(reader.word(slot['base_add'])==0xe2802080 and reader.word(slot['stm_store'])==0xe8820072,'constructor STM store order')
    for ref in source['literal_references']:
        require(ref['kind'] in ('pc-add','pc-got-load'),'reference kind')
        reg=ref['register'];word=reader.word(ref['load'])
        require(word & 0xfffff000 == 0xe59f0000 | (reg<<12),'reference literal load')
        require(ref['load']+8+(word&4095)==ref['literal'] and reader.word(ref['literal'])==ref['word'],'reference literal')
        operation=0xe08f0000 if ref['kind']=='pc-add' else 0xe79f0000
        require(reader.word(ref['add_or_got_load'])==operation|(reg<<12)|reg,'reference address operation')
        require((ref['add_or_got_load']+8+ref['word'])&0xffffffff==ref['target'],'reference target')
        if ref['kind']=='pc-got-load':require(reader.word(ref['target'])==ref['got_word'],'GOT pointer identity')

def verify_strings(witness, readers):
    cg,hw=readers['cgminer'],readers['hwscan']
    require(len(witness['wrapper_strings'])==6,'wrapper string count')
    for st in witness['wrapper_strings']:
        keys(st,['add','backedge','backedge_target','bytes','compare','encoded_start','increment','key','literal','load','name','plain_start','text','xor','zero'],'wrapper string')
        n,key=st['bytes'],st['key'];integer(n,'string size',256);integer(key,'XOR key',255)
        expected=st['text'].encode('ascii')+b'\0'
        require(n==len(expected),'wrapper string length')
        require(bytes(v^key for v in cg.read(st['encoded_start'],n))==expected and hw.read(st['plain_start'],n)==expected,'cross-ELF decoded string')
        ld=cg.word(st['load']);reg=(ld>>12)&15
        require(ld & 0xffff0000==0xe59f0000 and st['load']+8+(ld&4095)==st['literal'],'initializer literal')
        require(cg.word(st['add'])==0xe08f0000|(reg<<12)|reg and (st['add']+8+cg.word(st['literal']))&0xffffffff==st['encoded_start'],'initializer string address')
        require(cg.word(st['xor']) & 0xfff00000 == 0xe2200000 and immediate(cg.word(st['xor']))==key,'initializer XOR')
        require(cg.word(st['compare']) & 0xfff00000 == 0xe3500000 and immediate(cg.word(st['compare']))==n,'initializer length bound')
        require(cg.word(st['zero']) & 0xffff0fff==0xe3a00000,'initializer zero counter')
        target,link,_=branch(cg.word(st['backedge']),st['backedge'])
        require(not link and target==st['backedge_target'],'initializer backedge')
    registration=witness['wrapper_initializer']
    require(registration['slot']==0x5dafe4 and registration['pointer']==0xe5370 and cg.word(registration['slot'])==registration['pointer'],'initializer registration')
    require(len(witness['group_strings'])==7,'group/coordinator string count')
    for st in witness['group_strings']:
        keys(st,['name','literal','literal_word','add','target','bytes','key','decoded_hex','text'],'group string')
        expected=st['text'].encode('ascii')+b'\0';require(len(expected)==st['bytes'] and expected.hex()==st['decoded_hex'],'group string length/text')
        require(cg.word(st['literal'])==st['literal_word'] and (st['add']+8+st['literal_word'])&0xffffffff==st['target'],'group string address')
        require(bytes(v^st['key'] for v in cg.read(st['target'],st['bytes']))==expected,'group decoded string')
    # Group initializer loops and source attribution are manual pinned proofs;
    # these static checks do not simulate their control flow or runtime timing.

def verify_grouping(witness, reader):
    proof=witness['proof']
    require(proof['grouping_code']==[0xb58e4,0xb5a44] and proof['grouping_pool']==[0xb5a44,0xb5a4c],'grouping boundaries')
    require(proof['grouping_source_path_proved'] is False and proof['hwscan_grouping_caller_proved'] is False,'unproved attribution must remain explicit')
    require(proof['no_original_execution'] is True and proof['no_instruction_interpreter'] is True and proof['no_hardware_acceptance'] is True,'scope limits')
    expect_words(reader,{
        0xb5900:0xe5d0103c,0xb5940:0xe5954018,0xb5944:0xe596801c,
        0xb5964:0xe3540001,0xb5970:0xe2444001,0xb5978:0xe3500000,
        0xb5980:0xe3540001,0xb59a8:0xe5950014,0xb59ac:0xe0000490,
        0xb59b0:0xe2400001,0xb59b4:0xe58d0004,0xb59b8:0xe5951000,
        0xb59c0:0xe58d0008,0xb59c8:0xe5983194,0xb59d0:0xe5d52040,
        0xb59d4:0xe12fff33,0xb5a2c:0xe3e00000},'grouping field/control facts')
    calls=[];indirect=[]
    for address in range(0xb58e4,0xb5a44,4):
        word=reader.word(address)
        if word & 0x0e000000 == 0x0a000000:
            target,link,condition=branch(word,address)
            if link:
                require(condition==14 and target in (0xa720c,0x53d98),'grouping direct dependency')
                calls.append((address,target))
            else:require(0xb58e4<=target<0xb5a44,'grouping branch extent')
        if word & 0x0ffffff0 == 0x012fff30:indirect.append((address,word&15))
    require(calls==[(0xb58fc,0xa720c),(0xb59bc,0x53d98),(0xb5a0c,0x53d98)] and indirect==[(0xb59d4,3),(0xb5a24,3)],'grouping complete call inventory')
    require(branch(reader.word(0x564dc),0x564dc)==(0xb58e4,True,14),'actual coordinator call')

def safe_relative(path):
    require(type(path) is str and path and '\\' not in path,'invalid relative path')
    parsed=PurePosixPath(path)
    require(not parsed.is_absolute() and path==parsed.as_posix() and all(p not in ('.','..') for p in parsed.parts),'unsafe relative path')

def verify_common_caller(witness, reader, root):
    common=witness['common_caller']
    keys(common,['captures','format','string_references','dependency_path','entry_flag','late_setting','retained_method_owner','device','error_index'],'common caller')
    path=common['dependency_path'];safe_relative(path)
    require(path=='research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-ticket-mask/static-witness.json','accepted capture dependency')
    prior,_=load_json(Path(root)/path)
    source=prior['sources']['cgminer']
    require(source['elf_sha256']==witness['sources']['cgminer']['elf_sha256'],'capture original identity')
    regions={row['id']:row for row in source['regions']}
    captures={}
    require(len(common['captures'])==25,'capture word count')
    for row in common['captures']:
        keys(row,['accepted_region','address','bytes_hex'],'capture word')
        require(row['accepted_region'] in regions and row['address'] not in captures,'capture region/address')
        region=regions[row['accepted_region']];offset=row['address']-region['va']
        require(region['kind']=='code' and 0<=offset and offset+4<=region['size'],'capture extent')
        raw=bytes.fromhex(region['bytes_hex'])[offset:offset+4]
        require(raw.hex()==row['bytes_hex'],'capture bytes differ from accepted L11 evidence')
        captures[row['address']]=int.from_bytes(raw,'little')
    require(captures[0x55804]==0xe5d7004b and captures[0x55808]==0xe58d001c,'entry flag capture')
    require(captures[0x55828]==0xe599701c and captures[0x55938]==0xe58d7014,'retained owner capture')
    require(captures[0xa71f8]==0x12800088 and captures[0xa7210]==0x12800038,'pure model view offsets')
    require(branch(captures[0x55ef8],0x55ef8)==(0x56d18,True,14) and captures[0x55efc]==0xe3e06000,'shared stop and failure return')
    expect_words(reader,{
        0x56378:0xe3a0000a,0x56380:0xe59d001c,0x56384:0xe3100001,
        0x5638c:0xe59d0014,0x56390:0xe5d51014,0x56394:0xe5902198,
        0x56398:0xe1a0000a,0x5639c:0xe12fff32,0x563a0:0xe3500000,
        0x563bc:0xe5993018,0x563cc:0xe2833001,0x563dc:0xe30032b9,
        0x5ba64:0xe3a02000,0x5ba74:0xe08f3003,0x5ba7c:0xe22000dd,
        0x5ba84:0xe2822001,0x5ba88:0xe352002b},'common caller field/control facts')
    for address,target,link,condition in [
        (0x5637c,0x10ef3c,True,14),(0x56388,0x563f0,False,0),
        (0x563a4,0x563f0,False,0),(0x563e0,0xfa0c4,True,14),
        (0x563ec,0x55ef4,False,14),(0x5ba8c,0x5ba78,False,1)]:
        require(branch(reader.word(address),address)==(target,link,condition),'common caller edge')
    require(len(common['string_references'])==5,'common logger references')
    for row in common['string_references']:
        keys(row,['add','literal','literal_word','load','name','target'],'common string reference')
        word=reader.word(row['load']);reg=(word>>12)&15
        require(word & 0xffff0000==0xe59f0000 and row['load']+8+(word&4095)==row['literal'],'common string load')
        require(reader.word(row['literal'])==row['literal_word'] and reader.word(row['add'])==0xe08f0000|(reg<<12)|reg,'common string address words')
        require((row['add']+8+row['literal_word'])&0xffffffff==row['target'],'common string target')
    fmt=common['format']
    require(fmt['target']==0x5e45e1 and fmt['bytes']==43 and fmt['xor']==0xdd and fmt['line']==697 and fmt['severity']==1,'common error format facts')
    expected=b'chain#%d - failed to config drive strength\0'
    require(expected.hex()==fmt['decoded_hex'] and expected[:-1].decode()==fmt['text'],'common error text')
    require(bytes(value^fmt['xor'] for value in reader.read(fmt['target'],fmt['bytes']))==expected,'common error decode')
    require((0x5ba74+8+reader.word(0x5c460))&0xffffffff==fmt['target'],'common initializer pointer')
    require(fmt['registration']==0x5daf90 and fmt['initializer']==0x5b1dc and reader.word(fmt['registration'])==fmt['initializer'],'common initializer registration')

def verify_files(witness, root):
    require(len(witness['runtime'])==4,'runtime file set')
    for entry in witness['dependencies']+witness['contracts']+witness['runtime']:
        keys(entry,['path','bytes','sha256','git_blob']+(['mode'] if 'mode' in entry else []),'file identity')
        safe_relative(entry['path']);integer(entry['bytes'],'file extent',MAX_SOURCE_BYTES)
        digest(entry['sha256'],'file');require(re.fullmatch('[0-9a-f]{40}',entry['git_blob']) is not None,'Git blob')
        mode=entry.get('mode','exact');require(mode in ('exact','prefix'),'file identity mode')
        path=Path(root)/entry['path'];size=path.stat().st_size
        require(size<=MAX_SOURCE_BYTES and (size>=entry['bytes'] if mode=='prefix' else size==entry['bytes']),'file extent mismatch: '+entry['path'])
        with path.open('rb') as stream:raw=stream.read(entry['bytes'])
        require(sha(raw)==entry['sha256'],'file span SHA256 mismatch: '+entry['path'])
        require(hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==entry['git_blob'],'file span Git identity: '+entry['path'])
    require(witness['runtime'][0]['path']=='libbitmain/src/chip/chip1368.c' and witness['runtime'][0]['mode']=='prefix' and witness['runtime'][0]['bytes']==14347,'historical runtime source span')

def verify_original(path, source, reader):
    path=Path(path);require(path.stat().st_size==source['elf_size']<=MAX_SOURCE_BYTES,'original size')
    data=path.read_bytes();require(sha(data)==source['elf_sha256'],'original whole-file identity')
    require(data[:7]==b'\x7fELF\x01\x01\x01' and struct.unpack_from('<H',data,18)[0]==40,'ELF32 ARM LE identity')
    phoff=struct.unpack_from('<I',data,28)[0];entsize,count=struct.unpack_from('<HH',data,42)
    require(entsize==32 and 0<count<=2048 and phoff+entsize*count<=len(data),'program header extent')
    loads=[]
    for n in range(count):
        kind,offset,va,_,filesz,memsz,flags,_=struct.unpack_from('<8I',data,phoff+n*entsize)
        if kind==1:
            require(filesz<=memsz and offset+filesz<=len(data) and va+memsz<=0x100000000,'PT_LOAD extent')
            loads.append((offset,va,filesz,flags))
    for region,raw in reader.items:
        matches=[(off+region['va']-va,flags) for off,va,size,flags in loads if va<=region['va'] and region['va']+region['size']<=va+size]
        require(len(matches)==1,'unique file-backed range')
        offset,flags=matches[0]
        require(offset==region['file_offset'] and (region['kind']!='code' or flags&1),'file offset/code mapping')
        require(data[offset:offset+len(raw)]==raw,'original selected byte mismatch')

def verify(witness_path=HERE/'static-witness.json',pins_path=HERE/'static-pins.json',root=ROOT,originals=None):
    pins,pins_raw=load_json(pins_path);require(sha(pins_raw)==PINS_SHA256,'immutable pins identity')
    keys(pins,['schema','kind','metadata_sha256','sources'],'pins')
    require(type(pins['schema']) is int and pins['schema']==1 and pins['kind']=='bm1368-group-register-static-pins','pins schema')
    witness,_=load_json(witness_path)
    keys(witness,['schema','kind','sources','wrapper_strings','wrapper_initializer','group_strings','common_caller','proof','dependencies','contracts','runtime'],'witness')
    require(type(witness['schema']) is int and witness['schema']==1 and witness['kind']=='bm1368-group-register-static-witness','witness schema')
    require(sha(canonical(metadata(witness)))==pins['metadata_sha256'],'reviewed metadata identity')
    keys(witness['sources'],['cgminer','hwscan'],'source set');keys(pins['sources'],['cgminer','hwscan'],'pin source set')
    readers={}
    for name,source in witness['sources'].items():
        keys(source,['elf_size','elf_sha256','regions','operands','methods','slots','literal_references'],'source')
        expected=pins['sources'][name];keys(expected,['elf_size','elf_sha256','regions'],'pin source')
        integer(source['elf_size'],'ELF size',MAX_SOURCE_BYTES);digest(source['elf_sha256'],'ELF')
        require(source['elf_size']==expected['elf_size'] and source['elf_sha256']==expected['elf_sha256'],'ELF provenance')
        reader=Ranges(source['regions'],expected['regions']);readers[name]=reader
        verify_operands(source,reader);verify_methods(name,source,reader);verify_slots_references(source,reader)
    verify_strings(witness,readers);verify_grouping(witness,readers['cgminer']);verify_files(witness,root)
    verify_common_caller(witness,readers['cgminer'],root)
    compared=[]
    for name,path in (originals or {}).items():
        require(name in readers,'unknown original input')
        verify_original(path,witness['sources'][name],readers[name]);compared.append(name)
    return {'static_witness_verified':True,'original_files_compared':sorted(compared),
            'selected_regions':sum(len(s['regions']) for s in witness['sources'].values()),
            'firmware_executed':False,'instruction_interpreter_used':False,
            'semantic_basis':'manual bounded CFG/parity/ABI proof; host regressions are separate'}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT)
    parser.add_argument('--witness',type=Path,default=HERE/'static-witness.json')
    parser.add_argument('--pins',type=Path,default=HERE/'static-pins.json')
    parser.add_argument('--cgminer',type=Path,help='optional original file, parsed only as static data')
    parser.add_argument('--hwscan',type=Path,help='optional original file, parsed only as static data')
    args=parser.parse_args()
    originals={name:path for name,path in (('cgminer',args.cgminer),('hwscan',args.hwscan)) if path is not None}
    print(json.dumps(verify(args.witness,args.pins,args.root,originals),sort_keys=True))

if __name__=='__main__':main()

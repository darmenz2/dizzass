#!/usr/bin/env python3
"""Verify bounded static BM1368 address-wrapper evidence (standard library only).
No target execution, CPU state, instruction stepping, emulation or hardware I/O.
Fixed byte/operand annotations and manual CFG/ABI conclusions are pinned; this
is not automatic C/original equivalence. Optional originals are parsed as data.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import re
import struct
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PINS_SHA256 = '0a998d7ca8ced6672f45a7d501dd5ee7cc255fa6abd48092a8651172590340c2'
MAX_JSON_BYTES = 1_000_000
MAX_SOURCE_BYTES = 16_000_000
CALL_TARGETS = {'cgminer':{'crc5':0xf7f10,'transport':0xd26ac,'log':0xfa0c4},
                'hwscan':{'crc5':0xfcc18,'transport':0xea8b8,'log':0xfeeb0}}
EXTENTS = {'cgminer':{'inactive':(0xe47b8,0xe48d8,0xe48fc),'address':(0xe48fc,0xe49ac,0xe49bc)},
           'hwscan':{'inactive':(0xf3bcc,0xf3c64,0xf3c74),'address':(0xf3c74,0xf3d24,0xf3d34)}}
STRING_FACTS = [('module',0x5eb3e0,0x47d914,7,0x1e,'driver'),
 ('source',0x5eb3e7,0x47e7ef,42,0xd8,'/tmp/build/libbitmain/src/chip/chip1368.c'),
 ('function',0x5eb411,0x47d359,11,0xd1,'[redacted]'),
 ('inactive_format',0x5eb59d,0x47e02d,42,0xdb,'chain#%d - failed to inactivate the chain'),
 ('address_format',0x5eb5c7,0x47e057,51,0xd3,'chain#%d - failed to assign chip address to 0x%02x')]

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
            keys(region,['id','kind','va','size','sha256','bytes_hex'],'range')
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

def verify_methods(name,source,reader):
    keys(source['methods'],['inactive','address'],'method list')
    require(source['call_targets']==CALL_TARGETS[name],'wrong dependency destinations')
    for method,row in source['methods'].items():
        keys(row,['code_start','code_end_exclusive','pool_end_exclusive','calls','branches','literal_loads'],'method')
        start,end,pool_end=EXTENTS[name][method]
        require((row['code_start'],row['code_end_exclusive'],row['pool_end_exclusive'])==(start,end,pool_end),'wrong code/pool bounds')
        require(reader.by_id[method+'-code']['va']==start and reader.by_id[method+'-code']['size']==end-start,'code identity')
        require(reader.by_id[method+'-pool']['va']==end and reader.by_id[method+'-pool']['size']==pool_end-end,'pool identity')
        calls=[];branches=[];literals=[]
        for address in range(start,end,4):
            word=reader.word(address)
            if word&0x0e000000==0x0a000000:
                target,link,condition=branch(word,address)
                if link:
                    require(condition==14 and target in CALL_TARGETS[name].values(),'unexpected wrapper call')
                    kind=next(k for k,v in CALL_TARGETS[name].items() if v==target)
                    calls.append({'va':address,'target':target,'kind':kind})
                else:
                    require(start<=target<end,'branch reaches pool or external code')
                    branches.append({'va':address,'target':target,'condition':condition})
            if word&0xffff0000==0xe59f0000:
                target=address+8+(word&4095)
                require(end<=target<pool_end,'literal outside own pool')
                literals.append({'load':address,'literal':target})
        require(row['calls']==calls and row['branches']==branches and row['literal_loads']==literals,'call/branch/literal inventory differs')
        require({x['literal'] for x in literals}==set(range(end,pool_end,4)),'unused/unwitnessed pool word')
        require(reader.word(end-4)&0xffff8000==0xe8bd8000,'last code word is not returning POP PC')
        require([x['kind'] for x in calls]==(['crc5','transport','log','log'] if name=='cgminer' and method=='inactive' else ['crc5','transport','log']),'unexpected wrapper effect sites')

def verify_slots_refs(source,reader):
    require(type(source['slots']) is list and len(source['slots'])==2,'two constructor slots required')
    require({s['offset'] for s in source['slots']}=={0xb4,0xb8},'wrong method offsets')
    for slot in source['slots']:
        keys(slot,['offset','register','load','got_load','literal','got','store','method'],'slot')
        for value in slot.values():integer(value,'slot value')
        reg=slot['register'];off=slot['offset']
        require(reg==(14 if off==0xb4 else 12),'wrong constructor register')
        ld=reader.word(slot['load'])
        require(ld&0xfffff000==0xe59f0000|(reg<<12),'slot literal instruction')
        require(slot['load']+8+(ld&4095)==slot['literal'],'wrong slot literal address')
        require(reader.word(slot['got_load'])==0xe79f0000|(reg<<12)|reg,'wrong GOT dereference instruction')
        require((slot['got_load']+8+reader.word(slot['literal']))&0xffffffff==slot['got'],'wrong GOT arithmetic')
        require(reader.word(slot['got'])==slot['method']==source['methods']['inactive' if off==0xb4 else 'address']['code_start'],'wrong method identity')
        require(reader.word(slot['store'])==0xe5800000|(reg<<12)|off,'wrong constructor store')
    require(type(source['literal_references']) is list,'invalid references')
    for ref in source['literal_references']:
        keys(ref,['load','add','register','literal','literal_word','target'],'reference')
        for value in ref.values():integer(value,'reference value')
        reg=ref['register'];ld=reader.word(ref['load'])
        require(ld&0xfffff000==0xe59f0000|(reg<<12),'wrong string pointer load')
        require(ref['load']+8+(ld&4095)==ref['literal'],'wrong string literal address')
        require(reader.word(ref['literal'])==ref['literal_word'],'wrong literal word')
        require(reader.word(ref['add'])==0xe08f0000|(reg<<12)|reg,'wrong string pointer add')
        require((ref['add']+8+ref['literal_word'])&0xffffffff==ref['target'],'wrong decoded string address')

def verify_strings(strings,sources,readers):
    require(type(strings) is list and len(strings)==len(STRING_FACTS),'exactly reviewed string set required')
    cg,hw=readers['cgminer'],readers['hwscan']
    for st,fact in zip(strings,STRING_FACTS):
        keys(st,['name','encoded_start','encoded_end_exclusive','plain_start','plain_end_exclusive','text','byte_count','xor_key','load','add','literal','zero','compare','xor','increment','backedge','local_loop_start','local_loop_end_exclusive'],'string')
        for key,value in st.items():
            if key not in ('name','text'):integer(value,'string '+key)
        require((st['name'],st['encoded_start'],st['plain_start'],st['byte_count'],st['xor_key'],st['text'])==fact,'wrong exact string fact')
        n,key=st['byte_count'],st['xor_key']
        require(st['encoded_end_exclusive']==st['encoded_start']+n and st['plain_end_exclusive']==st['plain_start']+n,'wrong string end')
        ld=cg.word(st['load'])
        require(ld&0xfffff000==0xe59f3000 and st['load']+8+(ld&4095)==st['literal'],'initializer pointer literal')
        require(cg.word(st['add'])==0xe08f3003 and (st['add']+8+cg.word(st['literal']))&0xffffffff==st['encoded_start'],'initializer pointer arithmetic')
        require(cg.word(st['xor'])&0xfff00fff==0xe2200000|key,'wrong XOR key/instruction')
        require(cg.word(st['compare'])&0xfff00fff==0xe3500000|n,'wrong initializer bound')
        require(cg.word(st['zero'])==(0xe3a00000 if st['name']=='module' else 0xe3a02000),'wrong initializer zero')
        target,link,cond=branch(cg.word(st['backedge']),st['backedge'])
        require(not link and cond==(1 if st['name']=='inactive_format' else 0),'wrong initializer backedge')
        require(target==(st['xor']-4 if st['name']=='inactive_format' else st['compare']),'wrong initializer loop target')
        expected=st['text'].encode('ascii')+b'\0'
        require(len(expected)==n and bytes(b^key for b in cg.read(st['encoded_start'],n))==expected and hw.read(st['plain_start'],n)==expected,'bounded XOR/plain string mismatch')
    for name,source in sources.items():
        targets={s['encoded_start' if name=='cgminer' else 'plain_start'] for s in strings}
        require({r['target'] for r in source['literal_references']}==targets,'literal reference target set differs')

def verify_proof(proof,sources,readers):
    keys(proof,['basis','ordinary_contract','logs','read_sites','opaque_conditions','unreachable_cgminer_log','initializer_registration','caller','domain','nonclaims'],'proof')
    expected={'inactive_body_prefix':'53050000','address_body_prefix':'4005','address_mask':255,'reserved_byte':0,'crc_bits':32,'send_length':5,'zero_status_return':0,'nonzero_status_return':4294967295,'retry':False,'cache_effect':False}
    require(proof['ordinary_contract']==expected,'wrong ordinary status/body/effect contract')
    require(proof['unreachable_cgminer_log']==0xe48c4,'wrong dead log identity')
    cg=readers['cgminer'];hw=readers['hwscan']
    # Exact selected stores, loads, argument words and status branches. These are
    # fixed instruction facts, not a generated run or dataflow interpreter.
    expect_words(cg,{0xe47cc:0xe3000553,0xe47d4:0xe58d0013,0xe47dc:0xe3a01020,0xe47f4:0xe3a02005,0xe47fc:0xe3500000,
      0xe4850:0xe5943018,0xe4860:0xe2833001,0xe4864:0xe58d3008,0xe4868:0xe300329d,0xe4874:0xe3e05000,
      0xe490c:0xe3a00d15,0xe4914:0xe1cd01b3,0xe4920:0xe5910004,0xe4928:0xe5cd6016,0xe492c:0xe3a01020,0xe4930:0xe5cd0015,
      0xe4948:0xe3a02005,0xe4950:0xe3500000,0xe4968:0xe5953018,0xe4970:0xe5947004,0xe497c:0xe2833001,0xe4980:0xe3a05001,
      0xe498c:0xe58d3008,0xe4990:0xe30032bb,0xe4994:0xe58d700c,0xe499c:0xe3e06000},'wrapper operand mismatch')
    expect_words(hw,{0xf3be0:0xe3000553,0xf3be8:0xe58d0013,0xf3bf0:0xe3a01020,0xf3c08:0xe3a02005,0xf3c10:0xe3500000,
      0xf3c2c:0xe5943018,0xf3c3c:0xe2833001,0xf3c48:0xe58d3008,0xf3c4c:0xe300329d,0xf3c54:0xe3e05000,
      0xf3c84:0xe3a00d15,0xf3c8c:0xe1cd01b3,0xf3c98:0xe5910004,0xf3ca0:0xe5cd6016,0xf3ca4:0xe3a01020,0xf3ca8:0xe5cd0015,
      0xf3cc0:0xe3a02005,0xf3cc8:0xe3500000,0xf3ce0:0xe5953018,0xf3ce8:0xe5947004,0xf3cf4:0xe2833001,0xf3cf8:0xe3a05001,
      0xf3d04:0xe58d3008,0xf3d08:0xe30032bb,0xf3d0c:0xe58d700c,0xf3d14:0xe3e06000},'wrapper operand mismatch')
    expected_sites={'cgminer':{'inactive_index':0xe4850,'address_pre':0xe4920,'address_post':0xe4970,'address_index':0xe4968},'hwscan':{'inactive_index':0xf3c2c,'address_pre':0xf3c98,'address_post':0xf3ce8,'address_index':0xf3ce0}}
    require(proof['read_sites']==expected_sites,'wrong field read timing/sites')
    for name,reader in readers.items():
        for method in ('inactive','address'):
            calls=sources[name]['methods'][method]['calls'];send=calls[1]['va'];log=calls[2]['va']
            target,link,cond=branch(reader.word(send+8),send+8)
            require(not link and cond==0 and target==sources[name]['methods'][method]['code_end_exclusive']-12,'wrong exact-zero success branch')
            r=expected_sites[name]
            require(send<r[method+'_index']<log,'diagnostic index must be loaded after send')
            if method=='address':require(r['address_pre']<calls[0]['va']<send<r['address_post']<log,'address snapshot/reread order')
    require(type(proof['opaque_conditions']) is list and len(proof['opaque_conditions'])==2,'wrong parity sites')
    for row in proof['opaque_conditions']:
        keys(row,['sub','mul','test','branch','target'],'parity')
        sub,mul,test=(cg.word(row[k]) for k in ('sub','mul','test'))
        require(sub&0xffe00000==0xe2400000 and immediate(sub)==1,'parity subtraction')
        original,minus=(sub>>16)&15,(sub>>12)&15
        require(mul&0xffe000f0==0xe0000090 and {mul&15,(mul>>8)&15}=={original,minus},'parity multiply')
        require(test&0xfff0f000==0xe3100000 and (test>>16)&15==(mul>>16)&15 and immediate(test)==1,'parity low-bit test')
        require(branch(cg.word(row['branch']),row['branch'])==(row['target'],False,0),'parity edge')
    require(proof['initializer_registration']==0x5dafe4 and cg.word(0x5dafe4)==0xe5370,'wrong initializer registration')
    logs=proof['logs']
    keys(logs,['module','source','function','severity','inactive_line','address_line','inactive_format','address_format','index','address'],'logs')
    require(logs['severity']==1 and logs['inactive_line']==669 and logs['address_line']==699,'wrong log constants')
    require(logs['module']==STRING_FACTS[0][-1] and logs['source']==STRING_FACTS[1][-1] and logs['function']==STRING_FACTS[2][-1] and logs['inactive_format']==STRING_FACTS[3][-1] and logs['address_format']==STRING_FACTS[4][-1],'wrong diagnostic text')
    caller=proof['caller']
    keys(caller,['scope','stage','backend_constructor_base','inactive_backend_slot','address_backend_slot','inactive_call','address_call','inactive_status_ignored','address_status_ignored','first_count_after_delay','reload_chip_array_each_iteration','reload_address_slot_each_iteration','reload_count_after_delay','retained_owner_identity','retained_board_view_identity','signed_count_comparison','byte_stride','no_standalone_return','cold_address_formula'],'caller')
    for key in ('inactive_status_ignored','address_status_ignored','first_count_after_delay','reload_chip_array_each_iteration','reload_address_slot_each_iteration','reload_count_after_delay','retained_owner_identity','retained_board_view_identity','signed_count_comparison','no_standalone_return'):
        require(caller[key] is True,'wrong caller fact: '+key)
    require(caller['stage']==[0x55ad8,0x55b50] and caller['backend_constructor_base']==0x110 and caller['inactive_backend_slot']==0x1c4 and caller['address_backend_slot']==0x1c8 and caller['byte_stride']==0x60,'wrong caller geometry')
    require(caller['inactive_call']==0x55b00 and caller['address_call']==0x55b30 and caller['cold_address_formula']=='low32(chip_index * board_word0)','wrong caller/cold-address identities')
    expect_words(cg,{0x55aec:0xe599601c,0x55af0:0xe289afae,0x55af4:0xe1a07000,0x55afc:0xe59611c4,0x55b00:0xe12fff31,
      0x55b04:0xe3a0001e,0x55b0c:0xe5970010,0x55b10:0xe3500001,0x55b20:0xe5990088,0x55b24:0xe59621c8,0x55b28:0xe0801004,
      0x55b30:0xe12fff32,0x55b34:0xe3a0000a,0x55b3c:0xe5970010,0x55b40:0xe2855001,0x55b44:0xe2844060,0x55b48:0xe1550000,
      0x736a0:0xe7808004,0x736c0:0xe5810004,0x53d98:0xe0000091,0x53d9c:0xe12fff1e},'caller selected instruction mismatch')
    require(branch(cg.word(0x55b14),0x55b14)==(0x55b50,False,11) and branch(cg.word(0x55b4c),0x55b4c)==(0x55b20,False,11),'wrong caller signed branch')
    require(branch(cg.word(0x55b08),0x55b08)==(0x10ed2c,True,14) and branch(cg.word(0x55b38),0x55b38)==(0x10ed2c,True,14),'wrong caller delay targets')

def safe_relative(path):
    require(type(path) is str and path and not Path(path).is_absolute() and all(p not in ('','.','..') for p in path.split('/')),'unsafe dependency path')

def verify_files(witness,root):
    require(type(witness['dependencies']) is list and len(witness['dependencies'])==8,'wrong dependency set')
    require(type(witness['runtime']) is list and len(witness['runtime'])==2,'wrong runtime set')
    for dep in witness['dependencies']:
        keys(dep,['path','bytes','sha256'],'dependency');safe_relative(dep['path']);integer(dep['bytes'],'dependency size',MAX_SOURCE_BYTES);digest(dep['sha256'],'dependency')
        path=Path(root)/dep['path'];require(path.stat().st_size==dep['bytes'],'dependency size mismatch: '+dep['path']);require(sha(path.read_bytes())==dep['sha256'],'dependency identity mismatch: '+dep['path'])
    for entry in witness['runtime']:
        keys(entry,['path','mode','bytes','sha256','git_blob'],'runtime');safe_relative(entry['path']);integer(entry['bytes'],'runtime size',MAX_SOURCE_BYTES);digest(entry['sha256'],'runtime')
        require(entry['mode'] in ('exact','prefix'),'runtime extent mode')
        path=Path(root)/entry['path'];size=path.stat().st_size
        require(size<=MAX_SOURCE_BYTES and (size>=entry['bytes'] if entry['mode']=='prefix' else size==entry['bytes']),'runtime extent mismatch')
        with path.open('rb') as stream:raw=stream.read(entry['bytes'])
        require(sha(raw)==entry['sha256'],'runtime recorded-span SHA256 mismatch')
        require(hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==entry['git_blob'],'runtime recorded-span Git blob mismatch')
    require(witness['runtime'][0]['path']=='libbitmain/src/chip/chip1368.c' and witness['runtime'][0]['mode']=='prefix' and witness['runtime'][0]['bytes']==11280,'runtime must pin historical prefix')
    require(witness['runtime'][1]['path']=='integration/bm1368_address_commands_135.h' and witness['runtime'][1]['mode']=='exact' and witness['runtime'][1]['bytes']==3621,'header must pin full extent')

def verify_original(path,source,reader):
    path=Path(path);require(path.stat().st_size==source['elf_size']<=MAX_SOURCE_BYTES,'original ELF size mismatch')
    data=path.read_bytes();require(sha(data)==source['elf_sha256'],'original ELF identity mismatch')
    require(data[:7]==b'\x7fELF\x01\x01\x01' and struct.unpack_from('<H',data,18)[0]==40,'expected little-endian ELF32 ARM')
    phoff=struct.unpack_from('<I',data,28)[0];entsize,count=struct.unpack_from('<HH',data,42)
    require(entsize==32 and 0<count<=2048 and phoff+entsize*count<=len(data),'invalid program-header extent')
    loads=[]
    for n in range(count):
        kind,offset,va,_,filesz,memsz,flags,_=struct.unpack_from('<8I',data,phoff+n*entsize)
        if kind==1:
            require(filesz<=memsz and offset+filesz<=len(data) and va+memsz<=0x100000000,'invalid PT_LOAD')
            loads.append((offset,va,filesz,flags))
    for region,raw in reader.items:
        hits=[(off+region['va']-va,flags) for off,va,size,flags in loads if va<=region['va'] and region['va']+region['size']<=va+size]
        require(len(hits)==1,'range lacks unique file-backed PT_LOAD')
        offset,flags=hits[0]
        require(region['kind']!='code' or flags&1,'code range not executable in ELF metadata')
        require(data[offset:offset+len(raw)]==raw,'selected bytes differ from original ELF')

def verify(witness_path=HERE/'static-witness.json',pins_path=HERE/'static-pins.json',root=ROOT,originals=None):
    pins,pins_raw=load_json(pins_path);require(sha(pins_raw)==PINS_SHA256,'independent static pins identity mismatch')
    keys(pins,['schema','kind','metadata_sha256','sources'],'pins')
    require(type(pins['schema']) is int and pins['schema']==1 and pins['kind']=='bm1368-address-commands-static-pins','wrong pins schema')
    witness,_=load_json(witness_path);keys(witness,['schema','kind','sources','strings','dependencies','runtime','proof'],'witness')
    require(type(witness['schema']) is int and witness['schema']==1 and witness['kind']=='bm1368-address-commands-static-witness','wrong witness schema')
    keys(witness['sources'],['cgminer','hwscan'],'source set');keys(pins['sources'],['cgminer','hwscan'],'pin source set')
    readers={}
    for name,source in witness['sources'].items():
        keys(source,['elf_size','elf_sha256','regions','operands','methods','slots','literal_references','call_targets'],'source')
        integer(source['elf_size'],'ELF size',MAX_SOURCE_BYTES);digest(source['elf_sha256'],'ELF')
        expected=pins['sources'][name];keys(expected,['elf_size','elf_sha256','regions'],'pin source')
        require(source['elf_size']==expected['elf_size'] and source['elf_sha256']==expected['elf_sha256'],'whole ELF provenance mismatch')
        reader=Ranges(source['regions'],expected['regions']);readers[name]=reader
        verify_operands(source,reader);verify_methods(name,source,reader);verify_slots_refs(source,reader)
    verify_strings(witness['strings'],witness['sources'],readers)
    verify_proof(witness['proof'],witness['sources'],readers)
    require(sha(canonical(metadata(witness)))==pins['metadata_sha256'],'reviewed metadata/operand facts differ from immutable pins')
    verify_files(witness,root)
    compared=[]
    for name,path in (originals or {}).items():
        require(name in readers,'unknown original input')
        verify_original(path,witness['sources'][name],readers[name]);compared.append(name)
    return {'static_witness_verified':True,'original_files_compared':sorted(compared),'runtime_span':'chip1368.c prefix [0,11280); header exact 3621 bytes','firmware_executed':False,'instruction_interpreter_used':False,'semantic_basis':'manual static CFG/parity/ABI review; no automatic equivalence or hardware acceptance'}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT)
    parser.add_argument('--witness',type=Path,default=HERE/'static-witness.json')
    parser.add_argument('--pins',type=Path,default=HERE/'static-pins.json')
    parser.add_argument('--cgminer',type=Path,help='optional original ELF, read only as data')
    parser.add_argument('--hwscan',type=Path,help='optional original ELF, read only as data')
    args=parser.parse_args()
    try:
        result=verify(args.witness,args.pins,args.root,{k:v for k,v in {'cgminer':args.cgminer,'hwscan':args.hwscan}.items() if v is not None})
    except (EvidenceError,OSError,UnicodeError,json.JSONDecodeError,ValueError,TypeError,KeyError,IndexError,struct.error) as error:
        print('static witness rejected: '+str(error),file=sys.stderr);return 1
    print(json.dumps(result,sort_keys=True));return 0

if __name__=='__main__':
    sys.exit(main())

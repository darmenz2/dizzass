#!/usr/bin/env python3
"""Verify pinned BM1368 SWEEP_CLOCK_CTRL static witnesses, with no instruction execution.

Standard library only. Default verification reads the bounded public witnesses,
the immutable sibling L11 packet, and the reviewed C/header files as bytes.
Optional original ELFs are hashed and compared as data. Reviewed operand/proof
annotations are immutable evidence, not automatically derived C equivalence.
There is no CPU state, interpreter, emulator, callback oracle or hardware access.
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
PINS_SHA256 = 'fd0cafe594ccd0d216b9aa26b4cfe7a45a6cf3bb730b7201e096fa7cd84cf12d'
MAX_JSON_BYTES = 1_000_000
TARGETS = {'cgminer': {'writer':0xe4a74,'logger':0xfa0c4},
           'hwscan': {'writer':0xf3d7c,'logger':0xfeeb0}}

class EvidenceError(ValueError):
    pass


def require(condition, message):
    if not condition:
        raise EvidenceError(message)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def keys(value, expected, context):
    require(type(value) is dict and set(value) == set(expected), context + ': wrong keys/type')


def integer(value, context, maximum=0xffffffff):
    require(type(value) is int and 0 <= value <= maximum, context + ': invalid integer')


def digest(value, context):
    require(type(value) is str and re.fullmatch('[0-9a-f]{64}', value) is not None,
            context + ': invalid SHA256')


def pairs_no_duplicates(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, 'duplicate JSON key: ' + key)
        result[key] = value
    return result


def reject_constant(value):
    raise EvidenceError('non-finite JSON constant: ' + value)


def load_json(path):
    raw = Path(path).read_bytes()
    require(len(raw) <= MAX_JSON_BYTES, 'JSON exceeds bounded evidence size')
    try:
        value = json.loads(raw, object_pairs_hook=pairs_no_duplicates,
                           parse_constant=reject_constant)
    except (UnicodeError, json.JSONDecodeError) as error:
        raise EvidenceError('invalid JSON: ' + str(error)) from error
    return value, raw


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=True,
                      allow_nan=False).encode('ascii')


def metadata(witness):
    result = copy.deepcopy(witness)
    for source in result['sources'].values():
        for region in source['regions']:
            del region['bytes_hex']
    return result


class Ranges:
    def __init__(self, regions, expected):
        require(type(regions) is list, 'regions must be a list')
        self.items = []
        self.by_id = {}
        last_end = -1
        for region in regions:
            keys(region, ['id','kind','va','size','sha256','bytes_hex'], 'region')
            name = region['id']
            require(type(name) is str and name not in self.by_id, 'duplicate/invalid region id')
            require(region['kind'] in ('code','data'), 'invalid region kind')
            integer(region['va'], 'region va')
            integer(region['size'], 'region size', MAX_JSON_BYTES)
            require(region['size'] > 0, 'empty region')
            end = region['va'] + region['size']
            require(end <= 0x100000000 and region['va'] >= last_end, 'overlap/order/range error')
            last_end = end
            digest(region['sha256'], 'region digest')
            hex_data = region['bytes_hex']
            require(type(hex_data) is str and len(hex_data) == 2*region['size'] and
                    re.fullmatch('[0-9a-f]+', hex_data) is not None, 'invalid region hex/length')
            data = bytes.fromhex(hex_data)
            require(sha(data) == region['sha256'], 'region bytes/digest mismatch: ' + name)
            self.items.append((region, data))
            self.by_id[name] = region
        descriptions = [{k:v for k,v in region.items() if k != 'bytes_hex'} for region in regions]
        require(descriptions == expected, 'region identities differ from independent pins')

    def read(self, address, size):
        integer(address, 'read address')
        integer(size, 'read size', MAX_JSON_BYTES)
        for region, data in self.items:
            offset = address - region['va']
            if 0 <= offset and offset + size <= region['size']:
                return data[offset:offset+size]
        raise EvidenceError('address is outside a witnessed range: ' + hex(address))

    def word(self, address):
        require(address % 4 == 0, 'unaligned instruction/literal')
        return int.from_bytes(self.read(address, 4), 'little')


def branch(word, address):
    require(word & 0x0e000000 == 0x0a000000, 'expected ARM immediate branch')
    displacement = word & 0xffffff
    if displacement & 0x800000:
        displacement -= 0x1000000
    target = (address + 8 + displacement*4) & 0xffffffff
    link = bool(word & 0x01000000)
    return target, link, word >> 28


def immediate(word):
    value = word & 255
    rotation = ((word >> 8) & 15)*2
    return ((value >> rotation) | (value << ((32-rotation) % 32))) & 0xffffffff


def verify_operands(source, ranges):
    require(type(source['operands']) is list, 'operands must be a list')
    code_addresses = [address for region, _ in ranges.items if region['kind'] == 'code'
                      for address in range(region['va'], region['va']+region['size'], 4)]
    seen = []
    for row in source['operands']:
        require(type(row) is list and len(row) == 4, 'invalid operand record')
        address, hex_word, mnemonic, operand_text = row
        integer(address, 'operand address')
        require(type(hex_word) is str and re.fullmatch('[0-9a-f]{8}', hex_word) is not None,
                'invalid operand word')
        require(type(mnemonic) is str and mnemonic and type(operand_text) is str,
                'invalid decoded operands')
        require(ranges.read(address, 4).hex() == hex_word, 'operand annotation has wrong bytes')
        seen.append(address)
    require(seen == code_addresses, 'decoded operands must cover all and only code bytes once')


def verify_original(path, expected, reader):
    path = Path(path)
    require(path.stat().st_size == expected['elf_size'], 'original ELF size mismatch')
    data = path.read_bytes()
    require(sha(data) == expected['elf_sha256'], 'original ELF SHA256 mismatch')
    require(data[:7] == b'\x7fELF\x01\x01\x01', 'expected ARM ELF32 little endian')
    require(struct.unpack_from('<H',data,18)[0] == 40, 'expected EM_ARM')
    phoff = struct.unpack_from('<I',data,28)[0]
    entsize, count = struct.unpack_from('<HH',data,42)
    require(entsize == 32 and phoff + entsize*count <= len(data), 'invalid ELF program headers')
    segments = [struct.unpack_from('<8I',data,phoff+index*entsize) for index in range(count)]
    for region, contents in reader.items:
        found = False
        for kind, offset, va, _, file_size, _, _, _ in segments:
            relative = region['va'] - va
            if kind == 1 and 0 <= relative and relative+region['size'] <= file_size:
                start = offset+relative
                require(start+region['size'] <= len(data), 'ELF range outside file')
                require(data[start:start+region['size']] == contents, 'witness differs from original ELF bytes')
                found = True
                break
        require(found, 'witness range missing from original ELF PT_LOAD')


def verify_reference(ref, reader, expected_keys):
    keys(ref,expected_keys,'PC reference')
    for key in ('load','add','register','literal','word','target'): integer(ref[key],'reference '+key)
    register = ref['register']
    require(register < 15 and register != 13,'invalid PC reference register')
    load = reader.word(ref['load'])
    require(load & 0xfffff000 == (0xe59f0000 | register << 12), 'wrong PC literal load')
    require(ref['literal'] == ref['load']+8+(load & 4095), 'wrong PC literal address')
    require(reader.word(ref['literal']) == ref['word'], 'wrong literal content')
    require(reader.word(ref['add']) == (0xe08f0000 | register << 12 | register), 'wrong PC add')
    require((ref['add']+8+ref['word']) & 0xffffffff == ref['target'],'wrong resolved PC target')


class Combined:
    """Read local new witnesses and immutable, separately bound L11 witnesses."""
    def __init__(self, local, inherited):
        self.local, self.inherited = local, inherited

    def read(self, address, size):
        for reader in (self.local, self.inherited):
            for region, data in reader.items:
                offset = address-region['va']
                if 0 <= offset and offset+size <= region['size']:
                    return data[offset:offset+size]
        raise EvidenceError('address outside new and inherited witnesses: '+hex(address))

    def word(self, address):
        require(address % 4 == 0, 'unaligned witnessed word')
        return int.from_bytes(self.read(address,4),'little')


def verify_dependencies(dependencies, directory):
    keys(dependencies,['l11'],'dependencies')
    dependency=dependencies['l11']
    keys(dependency,['directory','files','scope'],'L11 dependency')
    require(dependency['directory']=='../bm1368-ticket-mask','wrong dependency relationship')
    require(type(dependency['scope']) is str and dependency['scope'],'missing inherited scope')
    require(type(dependency['files']) is list and
            [f.get('file') for f in dependency['files']] ==
            ['STATIC_CONTRACT.md','static-witness.json','static-pins.json'], 'wrong dependency files')
    inherited=None
    for item in dependency['files']:
        keys(item,['file','bytes','sha256'],'dependency file')
        integer(item['bytes'],'dependency length',MAX_JSON_BYTES)
        digest(item['sha256'],'dependency identity')
        path=Path(directory)/item['file']; raw=path.read_bytes()
        require(len(raw)==item['bytes'] and sha(raw)==item['sha256'],
                'L11 immutable dependency identity mismatch: '+item['file'])
        if item['file']=='static-witness.json': inherited=load_json(path)[0]
    require(inherited['kind']=='bm1368-ticket-mask-static-witness','wrong L11 witness kind')
    readers={}
    for name,source in inherited['sources'].items():
        descriptions=[{k:v for k,v in r.items() if k!='bytes_hex'} for r in source['regions']]
        readers[name]=Ranges(source['regions'],descriptions)
    return inherited,readers


def verify_slots(name, source, reader):
    require(type(source['slots']) is list and len(source['slots'])==2,'sweep and pulse slots required')
    for slot,role,register,offset,target in zip(source['slots'],('sweep','pulse'),(3,12),(0x70,0x78),
            (0xe32c0,0xe34cc) if name=='cgminer' else (0xf30d4,0xf3260)):
        keys(slot,['role','load','got_load','literal','got','store','register','offset','method'],'slot')
        require(slot['role']==role and slot['register']==register and slot['offset']==offset and
                slot['method']==target,'incorrect sweep/pulse slot contract')
        for key,value in slot.items():
            if key!='role': integer(value,'slot '+key)
        load=reader.word(slot['load'])
        require(load&0xfffff000 == 0xe59f0000 | register<<12,'slot literal-load register mismatch')
        require(slot['load']+8+(load&4095)==slot['literal'],'slot literal location mismatch')
        require(reader.word(slot['got_load'])==0xe79f0000 | register<<12 | register,'slot GOT load mismatch')
        require((slot['got_load']+8+reader.word(slot['literal']))&0xffffffff==slot['got'],
                'slot GOT arithmetic mismatch')
        require(reader.word(slot['got'])==target,'slot original method identity mismatch')
        require(reader.word(slot['store'])==0xe5800000 | register<<12 | offset,'slot store mismatch')


def fixed(reader, values, context):
    for address,word in values.items():
        require(reader.word(address)==word,context+' at '+hex(address))


def verify_method(name, source, reader):
    cg=name=='cgminer'
    entry,end,pool_end=(0xe32c0,0xe33c8,0xe33e0) if cg else (0xf30d4,0xf3164,0xf3174)
    body,pool=reader.by_id['sweep-code'],reader.by_id['sweep-pool']
    require((body['kind'],body['va'],body['size'])==('code',entry,end-entry),'whole sweep body extent mismatch')
    require((pool['kind'],pool['va'],pool['size'])==('data',end,pool_end-end),'separate sweep pool extent mismatch')
    calls=[];branches=[];literal_cells=[]
    for address in range(entry,end,4):
        word=reader.word(address)
        if word&0x0e000000 == 0x0a000000:
            target,link,condition=branch(word,address)
            if link:
                require(condition==14,'conditional method call is unexpected')
                role=next((k for k,v in TARGETS[name].items() if v==target),None)
                require(role is not None,'unexpected external method call')
                calls.append({'va':address,'target':target,'role':role,'ordinary':address!=0xe336c})
            else:
                require(entry<=target<end,'method branch escapes its executable body')
                branches.append({'va':address,'target':target,'condition':condition})
        if word&0xffff0000 == 0xe59f0000:
            cell=address+8+(word&4095)
            require(end<=cell<pool_end,'method literal outside separate pool')
            literal_cells.append(cell)
    expected_calls=([(0xe332c,0xe4a74),(0xe336c,0xe4a74),(0xe33b4,0xfa0c4)] if cg else
                    [(0xf310c,0xf3d7c),(0xf3150,0xfeeb0)])
    require([(c['va'],c['target']) for c in calls]==expected_calls and
            source['method_calls']==calls,'syntactic/ordinary method call inventory mismatch')
    require(source['method_branches']==branches,'method branch inventory mismatch')
    require(set(literal_cells)==set(range(end,pool_end,4)),'unaccounted method literal pool cell')
    require(reader.word(entry-4)==0xe8bd8800,'preceding method must return before sweep entry')
    require(reader.word(pool_end)==0xe92d4df0,'following method entry mismatch')
    if cg:
        fixed(reader,{
            0xe32d0:0xe1a04000,0xe32d4:0xe3087b00,0xe32d8:0xe1a05002,0xe32dc:0xe3487000,
            0xe32ec:0xe2401001,0xe32f0:0xe0000190,0xe32f8:0xe3100001,
            0xe330c:0xe2050003,0xe3310:0xe3a01001,0xe3314:0xe3a02000,0xe3318:0xe3a0303c,
            0xe331c:0xe1870080,0xe3320:0xe58d0000,0xe3324:0xe1a00004,0xe3328:0xe3a06000,
            0xe3330:0xe5981000,0xe3334:0xe2412001,0xe3338:0xe0010291,0xe333c:0xe3110001,
            0xe3374:0xe3500000,0xe3380:0xe3a06001,0xe3390:0xe5943018,0xe33a0:0xe2833001,
            0xe33a8:0xe88d00c0,0xe33ac:0xe58d3008,0xe33b0:0xe30031cf,
            0xe33b8:0xe3e06000,0xe33bc:0xe1a00006,0xe33c4:0xe8bd8bf0},'cgminer sweep fixed operand')
        expected_edges=[(0xe32fc,0xe330c,0),(0xe3308,0xe3350,12),(0xe3340,0xe3374,0),
                        (0xe334c,0xe3374,13),(0xe3370,0xe330c,14),(0xe3378,0xe33bc,0)]
    else:
        fixed(reader,{
            0xf30e0:0xe1a04000,0xf30e4:0xe3080b00,0xf30e8:0xe3480000,0xf30ec:0xe3a01001,
            0xf30f0:0xe7c20092,0xf30f4:0xe58d0000,0xf30f8:0xe1a00004,0xf30fc:0xe3a02000,
            0xf3100:0xe3a0303c,0xf3104:0xe3a06001,0xf3108:0xe3a05000,0xf3110:0xe3500000,
            0xf3128:0xe5943018,0xf3138:0xe2833001,0xf313c:0xe58d3008,0xf3140:0xe30031cf,
            0xf3148:0xe58d6000,0xf314c:0xe58d5004,0xf3154:0xe3e05000,0xf3158:0xe1a00005,
            0xf3160:0xe8bd8c70},'hwscan sweep fixed operand')
        expected_edges=[(0xf3114,0xf3158,0)]
    require([(b['va'],b['target'],b['condition']) for b in branches]==expected_edges,'sweep branch destinations mismatch')


def verify_strings(strings, sources, readers):
    require(type(strings) is list and [s.get('id') for s in strings]==
            ['module','source','function','sweep'],'exactly four named logger strings required')
    cg,hw=readers['cgminer'],readers['hwscan']
    for st in strings:
        keys(st,['id','cgminer','hwscan','length','key','text','load','add','literal','xor','compare'],'string')
        for key in ('cgminer','hwscan','length','key','load','add','literal','xor','compare'):
            integer(st[key],'string '+key)
        require(0<st['length']<256 and st['key']<=255,'invalid string length/key')
        require(type(st['text']) is str and '\0' not in st['text'],'invalid logger text')
        load=cg.word(st['load'])
        require(load&0xfffff000==0xe59f3000 and st['load']+8+(load&4095)==st['literal'],
                'initializer r3 literal load mismatch')
        require(cg.word(st['add'])==0xe08f3003 and
                (st['add']+8+cg.word(st['literal']))&0xffffffff==st['cgminer'], 'initializer pointer mismatch')
        xor,compare=cg.word(st['xor']),cg.word(st['compare'])
        require(xor&0xffe00000==0xe2200000 and ((xor>>12)&15)==((xor>>16)&15) and
                immediate(xor)==st['key'],'initializer XOR mismatch')
        require(compare&0xfff0f000==0xe3500000 and immediate(compare)==st['length'],'initializer direct length mismatch')
        expected=st['text'].encode('ascii')+b'\0'
        require(bytes(v^st['key'] for v in cg.read(st['cgminer'],st['length']))==expected and
                hw.read(st['hwscan'],st['length'])==expected,'independent logger string bytes mismatch')
    require(strings[3]['length']==42 and strings[3]['key']==0xeb,'SWEEP direct42-byte/eb initializer required')
    fixed(cg,{0xe5660:0xe3a02000,0xe5674:0xe7d30002,0xe567c:0xe7c30002,
              0xe5680:0xe2822001,0xe5684:0xe352002a},'sweep initializer loop')
    require(branch(cg.word(0xe5688),0xe5688)==(0xe5674,False,1),'initializer loop exit mismatch')
    for name,source in sources.items():
        refs=source['literal_references']
        require(type(refs) is list and len(refs)==4,'four wrapper string references required')
        for st,ref in zip(strings,refs):
            verify_reference(ref,readers[name],['id','load','add','register','literal','word','target'])
            require(ref['id']==st['id'] and ref['target']==st[name],'wrong wrapper logger reference')


def verify_proof(proof, readers, repo_root):
    keys(proof,['basis','domain','nonclaims','method_contract','ordinary_parity','caller',
                'lifetime_review','ordering','fixed_words','runtime_sources'],'proof')
    for kind in ('domain','nonclaims'):
        require(type(proof[kind]) is list and proof[kind] and
                all(type(x) is str and x for x in proof[kind]),'missing proof '+kind)
    require(proof['method_contract']['ordinary_writer_calls']==1 and
            proof['method_contract']['line']==463 and proof['method_contract']['register']==60,
            'incorrect ordinary method contract')
    cg=readers['cgminer']
    for edge in proof['ordinary_parity']['method_edges']+proof['ordinary_parity']['caller_edges']:
        require(branch(cg.word(edge[0]),edge[0])==(edge[1],False,0),'parity edge mismatch')
    seen=set()
    for fact in proof['fixed_words']:
        keys(fact,['source','va','word','purpose'],'fixed word')
        integer(fact['va'],'fixed address');integer(fact['word'],'fixed word')
        require(fact['source'] in readers and type(fact['purpose']) is str and fact['purpose'],'invalid fixed fact')
        identity=(fact['source'],fact['va']);require(identity not in seen,'duplicate fixed word');seen.add(identity)
        require(readers[fact['source']].word(fact['va'])==fact['word'],'wrong fixed word: '+fact['purpose'])
    fixed(cg,{0x557ec:0xe5d70048,0x557f0:0xe58d0024,0x55ff4:0xe59d0024,
              0x55ff8:0xe3100001,0x55828:0xe599701c,0x55938:0xe58d7014,
              0x56020:0xe59d0014,0x56024:0xe3a02000,0x56028:0xe595101c,
              0x5602c:0xe5903180,0x56030:0xe1a0000a,0x56034:0xe12fff33,
              0x56074:0xe3500000,0x56100:0xe3003291,0x56120:0xe3e06000,
              0x56194:0xe3a0000a,0x56204:0xe5906188,0x5620c:0xe12fff36,
              0x562bc:0xe5902138,0x562c4:0xe12fff32},'caller flag/owner/argument/order contract')
    require(branch(cg.word(0x55ffc),0x55ffc)==(0x560b0,False,0) and
            branch(cg.word(0x56078),0x56078)==(0x560b0,False,0),'disabled/zero convergence mismatch')
    require(branch(cg.word(0x56118),0x56118)==(0x56d18,True,14),'failure boundary mismatch')
    require(branch(cg.word(0x56198),0x56198)==(0x10ef3c,True,14),'success delay boundary mismatch')
    require(proof['caller']['full_coordinator_proved'] is False and
            proof['caller']['hwscan_caller_proved'] is False,'caller limits removed')
    files=proof['runtime_sources']
    require(type(files) is list and [f.get('path') for f in files]==
            ['libbitmain/src/chip/chip1368.c','integration/bm1368_sweep_clock_135.h'],
            'exact reviewed runtime source identities required')
    for item in files:
        keys(item,['path','bytes','git_blob','sha256'],'runtime source')
        raw=(Path(repo_root)/item['path']).read_bytes()
        require(len(raw)==item['bytes'] and sha(raw)==item['sha256'],'reviewed runtime source identity mismatch: '+item['path'])
        require(hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()==item['git_blob'],
                'runtime Git blob mismatch')


def verify(witness_path=HERE/'static-witness.json', pins_path=HERE/'static-pins.json', originals=None,
           l11_root=HERE.parent/'bm1368-ticket-mask', repo_root=HERE.parents[3]):
    pins,pins_raw=load_json(pins_path)
    require(sha(pins_raw)==PINS_SHA256,'independent static pins identity mismatch')
    keys(pins,['schema','kind','metadata_sha256','sources'],'pins')
    require(type(pins['schema']) is int and pins['schema']==1 and
            pins['kind']=='bm1368-sweep-clock-static-pins','unsupported pins schema')
    keys(pins['sources'],['cgminer','hwscan'],'pin sources')
    witness,_=load_json(witness_path)
    keys(witness,['schema','kind','sources','strings','dependencies','proof'],'witness')
    require(type(witness['schema']) is int and witness['schema']==1 and
            witness['kind']=='bm1368-sweep-clock-static-witness','unsupported witness schema')
    keys(witness['sources'],['cgminer','hwscan'],'sources')
    readers={}
    for name,source in witness['sources'].items():
        keys(source,['elf_size','elf_sha256','regions','operands','method_calls','method_branches',
                     'literal_references','slots'],name)
        expected=pins['sources'][name]
        require(source['elf_size']==expected['elf_size'] and source['elf_sha256']==expected['elf_sha256'],
                'whole original source identity mismatch')
        readers[name]=Ranges(source['regions'],expected['regions'])
    require(sha(canonical(metadata(witness)))==pins['metadata_sha256'],
            'reviewed operand/proof metadata differs from independent pins')
    inherited,inherited_readers=verify_dependencies(witness['dependencies'],l11_root)
    combined={name:Combined(reader,inherited_readers[name]) for name,reader in readers.items()}
    for name,source in witness['sources'].items():
        require(source['elf_size']==inherited['sources'][name]['elf_size'] and
                source['elf_sha256']==inherited['sources'][name]['elf_sha256'],'L11/L12 source identity mismatch')
        verify_operands(source,readers[name]);verify_slots(name,source,readers[name]);verify_method(name,source,readers[name])
    verify_strings(witness['strings'],witness['sources'],combined)
    verify_proof(witness['proof'],combined,repo_root)
    checked=[]
    for name,path in (originals or {}).items():
        require(name in readers,'unknown original source')
        verify_original(path,pins['sources'][name],readers[name])
        verify_original(path,pins['sources'][name],inherited_readers[name]);checked.append(name)
    return {'static_witness_verified':True,'original_files_compared':sorted(checked),
            'method_code_bytes':{'cgminer':264,'hwscan':144},
            'method_pool_bytes':{'cgminer':24,'hwscan':16},'logger_strings':4,
            'local_witness_bytes':sum(r['size'] for s in witness['sources'].values() for r in s['regions']),
            'local_regions':sum(len(s['regions']) for s in witness['sources'].values()),
            'l11_dependency_files_verified':3,'runtime_source_identities_verified':2,
            'ordinary_writer_calls':1,'method_body_identity_claimed':False,
            'cgminer_startup_caller_witnessed':True,'hwscan_startup_caller_claimed':False,
            'full_coordinator_claimed':False,'firmware_executed':False,'instruction_interpreter_used':False,
            'limits':'Pinned static review and immutable L11 caller dependency; manual lifetime/parity deductions; no automatic C equivalence, native ABI or hardware acceptance'}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--witness',type=Path,default=HERE/'static-witness.json')
    parser.add_argument('--pins',type=Path,default=HERE/'static-pins.json')
    parser.add_argument('--l11-root',type=Path,default=HERE.parent/'bm1368-ticket-mask')
    parser.add_argument('--repo-root',type=Path,default=HERE.parents[3])
    parser.add_argument('--cgminer',type=Path,help='optional original ELF, read only as data')
    parser.add_argument('--hwscan',type=Path,help='optional original ELF, read only as data')
    args=parser.parse_args()
    try:
        result=verify(args.witness,args.pins,{k:v for k,v in {'cgminer':args.cgminer,'hwscan':args.hwscan}.items() if v is not None},args.l11_root,args.repo_root)
    except (EvidenceError,OSError,TypeError,KeyError,IndexError,struct.error,ValueError) as error:
        print('static witness rejected: '+str(error),file=sys.stderr);return 1
    print(json.dumps(result,sort_keys=True));return 0


if __name__=='__main__':
    sys.exit(main())

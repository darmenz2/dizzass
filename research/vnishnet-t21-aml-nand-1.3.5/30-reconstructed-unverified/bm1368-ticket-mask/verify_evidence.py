#!/usr/bin/env python3
"""Verify pinned BM1368 TICKET_MASK static witnesses, with no instruction execution.

Standard library only. Default verification needs only bounded public witnesses.
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
PINS_SHA256 = 'b4688abf6a15ced3ac8b455fdac4ed64783ada36dd24adca7734db0b1585f2bd'
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


def verify_method(name, source, reader):
    body = reader.by_id['ticket-mask-code']
    pool = reader.by_id['ticket-mask-pool']
    entry = 0xe2130 if name == 'cgminer' else 0xf264c
    require(body['kind'] == 'code' and body['va'] == entry and body['size'] == 208,
            'whole method code extent mismatch')
    require(pool['kind'] == 'data' and pool['va'] == entry+208 and pool['size'] == 16,
            'method literal pool must remain separate data')
    calls, branches = [], []
    for address in range(entry, entry+208, 4):
        word = reader.word(address)
        if word & 0x0e000000 == 0x0a000000:
            target, link, condition = branch(word,address)
            if link:
                require(condition == 14, 'unexpected conditional method call')
                calls.append((address,target))
            else:
                branches.append((address,target,condition))
    require(type(source['method_calls']) is list and len(source['method_calls']) == 2,
            'method requires exactly two syntactic call sites')
    recorded = []
    for call in source['method_calls']:
        keys(call,['va','target','kind'],'method call')
        integer(call['va'],'call address'); integer(call['target'],'call target')
        require(call['kind'] in TARGETS[name] and call['target'] == TARGETS[name][call['kind']],
                'wrong writer/logger target')
        recorded.append((call['va'],call['target']))
    require(recorded == calls == [(entry+120,TARGETS[name]['writer']),
                                  (entry+188,TARGETS[name]['logger'])], 'method call inventory mismatch')
    require(type(source['method_branches']) is list and len(source['method_branches']) == 1,
            'method requires one conditional branch')
    item = source['method_branches'][0]
    keys(item,['va','target','condition'],'method branch')
    for key,value in item.items(): integer(value,'method branch '+key)
    require(branches == [(item['va'],item['target'],item['condition'])] ==
            [(entry+128,entry+196,0)], 'writer success branch mismatch')
    # Fixed facts: fresh field read lies after writer and before wrapper logger.
    require(reader.word(entry+148) == 0xe5943018 and
            entry+120 < entry+148 < entry+188, 'diagnostic index is not a late reload')
    require(reader.word(entry+164) == 0xe2833001, 'diagnostic index increment mismatch')
    require(reader.word(entry+104) == 0xe3a01001 and reader.word(entry+96) == 0xe3a02000 and
            reader.word(entry+64) == 0xe3a03014, 'writer arguments mismatch')
    require(reader.word(entry+192) == 0xe3e05000 and reader.word(entry+196) == 0xe1a00005,
            'method return mapping mismatch')
    normalized = []
    for address, _, mnemonic, text in source['operands']:
        if not entry <= address < entry+208: continue
        if mnemonic in ('bl','beq'):
            target = int(text.removeprefix('#'),16)
            text = next((role for role,value in TARGETS[name].items() if target == value),
                        'method+'+hex(target-entry))
        normalized.append((mnemonic,text))
    require(len(normalized) == 52,'method must contain 52 ARM instructions')
    return normalized


def verify_slot(source, reader):
    slot = source['slot']
    keys(slot,['load','got_load','literal','got','store','offset','method'],'constructor slot')
    for key,value in slot.items(): integer(value,'slot '+key)
    word = reader.word(slot['load'])
    require(word & 0xfffff000 == 0xe59f5000, 'slot must load r5 from PC literal')
    require(slot['load']+8+(word & 4095) == slot['literal'], 'slot literal address mismatch')
    require(reader.word(slot['got_load']) == 0xe79f5005, 'slot GOT register mismatch')
    require((slot['got_load']+8+reader.word(slot['literal'])) & 0xffffffff == slot['got'],
            'slot GOT arithmetic mismatch')
    require(reader.word(slot['got']) == slot['method'] == reader.by_id['ticket-mask-code']['va'],
            'slot method identity mismatch')
    require(reader.word(slot['store']-4) == 0xe2802020 and
            reader.word(slot['store']) == 0xe8820072 and slot['offset'] == 40,
            'constructor third STM word must be output+0x28')


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


def verify_strings(strings, sources, readers):
    require(type(strings) is list and len(strings) == 4,'exactly four logger strings required')
    require([s.get('id') for s in strings if type(s) is dict] ==
            ['module','source','function','ticket-mask'],'wrong logger string identities/order')
    cg, hw = readers['cgminer'], readers['hwscan']
    for st in strings:
        keys(st,['id','cgminer','hwscan','length','key','text','load','add','literal','xor','compare'],'string')
        for key in ('cgminer','hwscan','length','key','load','add','literal','xor','compare'):
            integer(st[key],'string '+key)
        require(0 < st['length'] < 256 and st['key'] <= 255,'invalid string length/key')
        require(type(st['text']) is str and '\0' not in st['text'],'invalid logger text')
        load = cg.word(st['load'])
        require(load & 0xfffff000 == 0xe59f3000,'initializer must load r3')
        require(st['literal'] == st['load']+8+(load & 4095),'wrong initializer literal address')
        require(cg.word(st['add']) == 0xe08f3003 and
                (st['add']+8+cg.word(st['literal'])) & 0xffffffff == st['cgminer'],
                'wrong initializer string address')
        xor = cg.word(st['xor']); compare = cg.word(st['compare'])
        require(xor & 0xffe00000 == 0xe2200000 and ((xor>>12)&15) == ((xor>>16)&15)
                and immediate(xor) == st['key'],'wrong initializer XOR key/operands')
        require(compare & 0xfff0f000 == 0xe3500000 and immediate(compare) == st['length'],
                'wrong direct initializer length')
        expected = st['text'].encode('ascii')+b'\0'
        require(bytes(v ^ st['key'] for v in cg.read(st['cgminer'],st['length'])) == expected and
                hw.read(st['hwscan'],st['length']) == expected,'cross-ELF logger string mismatch')
    require(strings[3]['length'] == 37 and strings[3]['key'] == 128,
            'TICKET_MASK requires direct 37-byte evidence, not old heuristic length42')
    for name,source in sources.items():
        refs = source['literal_references']
        require(type(refs) is list and len(refs) == 4,'four wrapper string references required')
        for st,ref in zip(strings,refs):
            verify_reference(ref,readers[name],['id','load','add','register','literal','word','target'])
            require(ref['id'] == st['id'] and ref['target'] == st[name],'wrong logger string reference')


def verify_proof(proof, readers):
    keys(proof,['basis','dependency','domain','nonclaims','bit_permutation','helper','method_contract',
                'caller','direct_edges','thread_references','fixed_words'],'proof')
    require(type(proof['basis']) is str and proof['basis'],'missing proof basis')
    keys(proof['dependency'],['name','file','scope'],'dependency')
    for group in ('domain','nonclaims'):
        require(type(proof[group]) is list and proof[group] and
                all(type(x) is str and x for x in proof[group]),'invalid '+group)
    keys(proof['bit_permutation'],['input_domain','observed_bits','output_bits','high_bits'],'permutation')
    require(proof['bit_permutation']['observed_bits'] == list(range(8)) and
            proof['bit_permutation']['output_bits'] == list(reversed(range(8))), 'wrong reversal permutation')
    keys(proof['helper'],['file','function','sha256','proof'],'reuse helper')
    digest(proof['helper']['sha256'],'reuse source identity')
    keys(proof['method_contract'],['mode','chip','register','writer_calls','zero_status','nonzero_status',
                                  'line','severity','index','effects'],'method contract')
    keys(proof['caller'],['owner','startup','resume','thread','worker_gate','worker_arguments','model',
                         'entry_flags','B0','B1','triple','final','lifetime'],'caller')
    require(all(type(x) is str and x for x in proof['caller'].values()),'invalid caller facts')
    require(type(proof['direct_edges']) is list and len(proof['direct_edges']) == 10,'wrong direct edge inventory')
    for edge in proof['direct_edges']:
        keys(edge,['source','va','target','link'],'direct edge')
        require(edge['source'] in readers and type(edge['link']) is bool,'invalid direct edge')
        integer(edge['va'],'edge address'); integer(edge['target'],'edge target')
        target,link,condition = branch(readers[edge['source']].word(edge['va']),edge['va'])
        require(target == edge['target'] and link == edge['link'] and condition == 14,
                'direct call/tail edge mismatch')
    require(type(proof['thread_references']) is list and len(proof['thread_references']) == 2,
            'two thread entry references required')
    for ref in proof['thread_references']:
        require(type(ref) is dict and ref.get('source') in readers,'invalid thread source')
        verify_reference(ref,readers[ref['source']],['source','load','add','register','literal','word','target'])
    require(type(proof['fixed_words']) is list and proof['fixed_words'],'missing fixed proof words')
    seen = set()
    for fact in proof['fixed_words']:
        keys(fact,['source','va','word','purpose'],'fixed word')
        require(fact['source'] in readers and type(fact['purpose']) is str and fact['purpose'], 'invalid word fact')
        integer(fact['va'],'fixed word address'); integer(fact['word'],'fixed word value')
        identity = (fact['source'],fact['va'])
        require(identity not in seen,'duplicate fixed word'); seen.add(identity)
        require(readers[fact['source']].word(fact['va']) == fact['word'],'wrong fixed word: '+fact['purpose'])
    cg = readers['cgminer']
    require(cg.word(0x82d60) == 0xe3a00000 and cg.word(0x82d64) == 0xe12fff1e,
            'real worker mode helper must return zero')
    require(cg.word(0x55828) == 0xe599701c and cg.word(0x55938) == 0xe58d7014 and
            cg.word(0x55de4) == 0xe599601c and cg.word(0x562b4) == 0xe59d0014,
            'B0 saved and B1 reloaded owner distinctions lost')
    require(cg.word(0x557dc) == 0xe5d70046 and cg.word(0x562b8) == 0xe5951028,
            'entry flag snapshot and late model word distinction lost')
    for address in (0x55e38,0x55e6c,0x55ea0):
        require(cg.word(address) == 0xe3e01000,'optional triple input must be all ones')


def verify(witness_path=HERE/'static-witness.json', pins_path=HERE/'static-pins.json', originals=None):
    pins,pins_raw = load_json(pins_path)
    require(sha(pins_raw) == PINS_SHA256,'independent static pins identity mismatch')
    keys(pins,['schema','kind','metadata_sha256','sources'],'pins')
    require(type(pins['schema']) is int and pins['schema'] == 1 and
            pins['kind'] == 'bm1368-ticket-mask-static-pins','unsupported pin schema')
    keys(pins['sources'],['cgminer','hwscan'],'pin sources')
    digest(pins['metadata_sha256'],'metadata identity')
    witness,_ = load_json(witness_path)
    keys(witness,['schema','kind','sources','strings','proof'],'witness')
    require(type(witness['schema']) is int and witness['schema'] == 1 and
            witness['kind'] == 'bm1368-ticket-mask-static-witness','unsupported witness schema')
    keys(witness['sources'],['cgminer','hwscan'],'sources')
    readers = {}
    for name,source in witness['sources'].items():
        keys(source,['elf_size','elf_sha256','regions','operands','method_calls','method_branches',
                     'literal_references','slot'],name)
        integer(source['elf_size'],name+' size'); digest(source['elf_sha256'],name+' identity')
        expected = pins['sources'][name]
        keys(expected,['elf_size','elf_sha256','regions'],'pinned source')
        require(source['elf_size'] == expected['elf_size'] and source['elf_sha256'] == expected['elf_sha256'],
                'whole input provenance mismatch')
        readers[name] = Ranges(source['regions'],expected['regions'])
    # This exact canonical digest covers every operand, schema, proof qualifier,
    # dependency and relationship, including nested types and unknown fields.
    require(sha(canonical(metadata(witness))) == pins['metadata_sha256'],
            'reviewed operand/proof metadata differs from independent pins')
    normalized = []
    for name,source in witness['sources'].items():
        verify_operands(source,readers[name]); verify_slot(source,readers[name])
        normalized.append(verify_method(name,source,readers[name]))
    require(normalized[0] == normalized[1],'normalized 52-instruction methods differ')
    verify_strings(witness['strings'],witness['sources'],readers)
    verify_proof(witness['proof'],readers)
    checked = []
    for name,path in (originals or {}).items():
        require(name in readers,'unknown original source')
        verify_original(path,pins['sources'][name],readers[name]); checked.append(name)
    return {'static_witness_verified':True,'original_files_compared':sorted(checked),
            'method_code_bytes_per_elf':208,'method_literal_bytes_per_elf':16,'logger_strings':4,
            'normalized_method_instructions':52,'cgminer_startup_caller_witnessed':True,
            'hwscan_startup_caller_claimed':False,'firmware_executed':False,'instruction_interpreter_used':False,
            'limits':'pinned static review with L07 selector dependency; no complete coordinator, native ABI or hardware acceptance'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--witness',type=Path,default=HERE/'static-witness.json')
    parser.add_argument('--pins',type=Path,default=HERE/'static-pins.json')
    parser.add_argument('--cgminer',type=Path,help='optional full original ELF, read only as data')
    parser.add_argument('--hwscan',type=Path,help='optional full original ELF, read only as data')
    args = parser.parse_args()
    try:
        result = verify(args.witness,args.pins,{k:v for k,v in {'cgminer':args.cgminer,'hwscan':args.hwscan}.items() if v is not None})
    except (EvidenceError,OSError,TypeError,KeyError,IndexError,struct.error,ValueError) as error:
        print('static witness rejected: '+str(error),file=sys.stderr)
        return 1
    print(json.dumps(result,sort_keys=True))
    return 0


if __name__ == '__main__':
    sys.exit(main())

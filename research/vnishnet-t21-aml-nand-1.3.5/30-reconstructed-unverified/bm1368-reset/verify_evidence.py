#!/usr/bin/env python3
"""Verify bounded BM1368 reset byte evidence without executing instructions.

Standard library only. No CPU state, instruction dispatch, emulation, generated
callback trace, executable mapping, subprocess, hardware access, or vendor run.
Operand annotations are fixed reviewed disassembly facts, independently pinned
along with their bytes. The semantic implication remains documented static
review, not automatically established C/original equivalence.
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
PINS_SHA256 = 'd7dcc0e050e650f6aa371c2ce44589988940db9997ab7fcf378e98b6c586229d'
MAX_JSON_BYTES = 1_000_000
CALL_TARGETS = {
    'cgminer': {'read':0x1079f0, 'write':0xe4a74, 'wait':0x10ed2c, 'log':0xfa0c4},
    'hwscan': {'read':0x105a20, 'write':0xf3d7c, 'wait':0x108180, 'log':0xfeeb0},
}
BRANCH_NAMES = ['beq','bne','bhs','blo','bmi','bpl','bvs','bvc',
                'bhi','bls','bge','blt','bgt','ble','b','bnv']


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


def verify_calls_branches(name, source, ranges):
    require(type(source['calls']) is list and type(source['branches']) is list, 'invalid call/branch lists')
    body = ranges.by_id['reset-code']
    parsed_calls, parsed_branches = [], []
    for address in range(body['va'], body['va']+body['size'], 4):
        word = ranges.word(address)
        if word & 0x0e000000 == 0x0a000000:
            target, link, condition = branch(word, address)
            if link:
                require(condition == 14, 'unexpected conditional BL')
                parsed_calls.append((address, target))
            else:
                parsed_branches.append((address, target, BRANCH_NAMES[condition]))
    recorded_calls = []
    for call in source['calls']:
        keys(call, ['va','target','kind','ordinary_id'], 'call')
        integer(call['va'], 'call address')
        integer(call['target'], 'call target')
        require(call['kind'] in CALL_TARGETS[name], 'unknown effect boundary')
        require(call['target'] == CALL_TARGETS[name][call['kind']], 'wrong callback target')
        require(call['ordinary_id'] is None or type(call['ordinary_id']) is str, 'invalid call id')
        recorded_calls.append((call['va'],call['target']))
    require(recorded_calls == parsed_calls, 'call inventory does not match body bytes')
    recorded_branches = []
    for item in source['branches']:
        keys(item, ['va','target','mnemonic'], 'branch')
        integer(item['va'], 'branch address')
        integer(item['target'], 'branch target')
        require(item['mnemonic'] in BRANCH_NAMES, 'unknown branch mnemonic')
        recorded_branches.append((item['va'],item['target'],item['mnemonic']))
    require(recorded_branches == parsed_branches, 'branch inventory does not match body bytes')


def verify_slot(source, ranges):
    slot = source['slot']
    keys(slot, ['load','got_load','literal','got','store','offset','method'], 'slot')
    for key, value in slot.items():
        integer(value, 'slot ' + key)
    load = ranges.word(slot['load'])
    require(load & 0xfffff000 == 0xe59f4000, 'slot must load r4 from PC literal')
    require(slot['load'] + 8 + (load & 4095) == slot['literal'], 'wrong slot literal')
    require(ranges.word(slot['got_load']) == 0xe79f4004, 'wrong slot GOT load')
    require((slot['got_load'] + 8 + ranges.word(slot['literal'])) & 0xffffffff == slot['got'],
            'slot GOT arithmetic mismatch')
    require(ranges.word(slot['got']) == slot['method'] == ranges.by_id['reset-code']['va'],
            'wrong method identity')
    require(ranges.word(slot['store']-4) == 0xe2802020 and ranges.word(slot['store']) == 0xe8820072,
            'wrong constructor base/store sequence')
    require(slot['offset'] == 36, 'wrong reset method offset')


def verify_refs(source, ranges):
    require(type(source['literal_references']) is list, 'invalid literal references')
    for ref in source['literal_references']:
        keys(ref, ['load','add','register','literal','word','target'], 'literal reference')
        for key in ('load','add','literal','word','target'):
            integer(ref[key], 'literal reference ' + key)
        reg_names = {'r'+str(n):n for n in range(9)}
        reg_names.update({'sb':9,'sl':10,'fp':11,'ip':12,'lr':14})
        require(ref['register'] in reg_names, 'invalid literal register')
        reg = reg_names[ref['register']]
        word = ranges.word(ref['load'])
        require(word & 0xfffff000 == (0xe59f0000 | (reg << 12)), 'wrong literal load word')
        require(ref['literal'] == ref['load'] + 8 + (word & 4095), 'wrong literal address')
        require(ranges.word(ref['literal']) == ref['word'], 'wrong literal content')
        require(ranges.word(ref['add']) == (0xe08f0000 | (reg << 12) | reg), 'wrong PC add')
        require((ref['add'] + 8 + ref['word']) & 0xffffffff == ref['target'], 'wrong PC string address')


def verify_strings(strings, sources, readers):
    require(type(strings) is list and len(strings) == 8, 'eight strings are required')
    require({s.get('id') for s in strings if type(s) is dict} ==
            {'module','source','function','sweep','clock','core','misc','soft-reset'}, 'wrong string identities')
    cg, hw = readers['cgminer'], readers['hwscan']
    for st in strings:
        keys(st, ['id','cgminer','hwscan','length','key','text','load','add','literal','xor','compare'], 'string')
        for key in ('cgminer','hwscan','length','key','load','add','literal','xor','compare'):
            integer(st[key], 'string '+key)
        require(0 < st['length'] < 256 and st['key'] <= 255, 'invalid decode length/key')
        require(type(st['text']) is str and '\0' not in st['text'], 'invalid string text')
        load = cg.word(st['load'])
        require(load & 0xfffff000 == 0xe59f3000, 'wrong initializer literal load')
        require(st['literal'] == st['load'] + 8 + (load & 4095), 'wrong initializer literal address')
        require(cg.word(st['add']) == 0xe08f3003, 'wrong initializer PC add')
        require((st['add'] + 8 + cg.word(st['literal'])) & 0xffffffff == st['cgminer'],
                'wrong initializer string address')
        xor = cg.word(st['xor'])
        require(xor & 0xffe00000 == 0xe2200000 and ((xor >> 12) & 15) == ((xor >> 16) & 15)
                and immediate(xor) == st['key'], 'wrong XOR initializer key/operands')
        compare = cg.word(st['compare'])
        require(compare & 0xfff0f000 == 0xe3500000 and immediate(compare) == st['length'],
                'wrong initializer length comparison')
        decoded = bytes(value ^ st['key'] for value in cg.read(st['cgminer'],st['length']))
        try:
            expected = st['text'].encode('ascii') + b'\0'
        except UnicodeError as error:
            raise EvidenceError('non-ASCII reviewed literal') from error
        require(decoded == expected and hw.read(st['hwscan'],st['length']) == expected,
                'cross-ELF string mismatch: '+st['id'])
    for name, source in sources.items():
        targets = {st[name] for st in strings}
        require({ref['target'] for ref in source['literal_references']} == targets,
                'reset literal references do not cover exactly the reviewed strings')


def verify_proof(proof, sources, readers):
    keys(proof, ['basis','domain','nonclaims','ordinary_calls','unreachable_cgminer','opaque_conditions',
                 'parity_lemma','read_sites','input_sites','write_values','write_modes','delays',
                 'returns','logs','log_common','failure_graph'], 'proof')
    require(type(proof['ordinary_calls']) is list and len(proof['ordinary_calls']) == 24,
            'exactly 24 ordinary callback sites required')
    ids = set()
    for pair in proof['ordinary_calls']:
        keys(pair, ['id','kind','cgminer','hwscan'], 'ordinary call pair')
        require(type(pair['id']) is str and pair['id'] not in ids, 'duplicate ordinary call id')
        ids.add(pair['id'])
        for name in sources:
            integer(pair[name], 'ordinary call address')
            matches = [c for c in sources[name]['calls'] if c['ordinary_id'] == pair['id']]
            require(len(matches) == 1 and matches[0]['va'] == pair[name] and matches[0]['kind'] == pair['kind'],
                    'ordinary call correspondence mismatch')
    for name, source in sources.items():
        require({c['ordinary_id'] for c in source['calls'] if c['ordinary_id'] is not None} == ids,
                'unpaired ordinary call')
        extras = [c for c in source['calls'] if c['ordinary_id'] is None]
        require(len(extras) == (4 if name == 'cgminer' else 0), 'wrong unreachable call count')
    require(type(proof['unreachable_cgminer']) is list and len(proof['unreachable_cgminer']) == 4,
            'four unreachable cgminer sites required')
    for entry in proof['unreachable_cgminer']:
        keys(entry,['site','kind','reason'],'unreachable site')
    require({(c['va'],c['kind']) for c in sources['cgminer']['calls'] if c['ordinary_id'] is None} ==
            {(c['site'],c['kind']) for c in proof['unreachable_cgminer']}, 'wrong unreachable site identities')
    cg = readers['cgminer']
    require(type(proof['opaque_conditions']) is list and len(proof['opaque_conditions']) == 6,
            'six parity conditions required')
    for condition in proof['opaque_conditions']:
        keys(condition,['sub','mul','test','branch','target'],'parity condition')
        sub, mul, test = (cg.word(condition[k]) for k in ('sub','mul','test'))
        require(sub & 0xffe00000 == 0xe2400000 and immediate(sub) == 1, 'wrong parity subtraction')
        original, minus_one = (sub >> 16) & 15, (sub >> 12) & 15
        require(mul & 0xffe000f0 == 0xe0000090 and {mul & 15,(mul >> 8) & 15} == {original,minus_one},
                'wrong parity multiply')
        product = (mul >> 16) & 15
        require(test & 0xfff0f000 == 0xe3100000 and (test >> 16) & 15 == product and immediate(test) == 1,
                'wrong parity bit test')
        target, link, cond = branch(cg.word(condition['branch']),condition['branch'])
        require(not link and cond == 0 and target == condition['target'], 'wrong parity true edge')
    for name, reader in readers.items():
        for address in proof['write_modes'][name]:
            require(reader.word(address) == 0xe3a01000, 'write mode is not zero')
        require(reader.word(proof['returns'][name][0]) == 0xe3a00000, 'final result is not zero')
        require(reader.word(proof['delays'][name][-1]) == 0xe3a0000a, 'final delay is not ten')
        for row in proof['read_sites']:
            keys(row,['id','cgminer','hwscan','output'],'read site')
            zero, chip_load, device_load, call = row[name]
            require(reader.word(zero) == (0xe58d000c if row['id']=='R3' else 0xe58d0010),
                    'wrong cache output zero store')
            require(reader.word(chip_load) == (0xe5911000 if row['id']=='R1' else 0xe5961000),
                    'chip index must be reloaded')
            require(reader.word(device_load) == 0xe5950018, 'device index must be reloaded')
            require(chip_load < device_load < call, 'cache field load order mismatch')
        for log in proof['logs']:
            keys(log,['id','line','format','cgminer_index_load','hwscan_index_load'],'log fact')
            address = log[name+'_index_load']
            if address is not None:
                require(reader.word(address) in (0xe5950018,0xe5951018,0xe5953018), 'missing indexed diagnostic reload')
        first_log = next(pair[name] for pair in proof['ordinary_calls'] if pair['id']=='L387a')
        second_reload = next(log[name+'_index_load'] for log in proof['logs'] if log['id']=='L538')
        second_log = next(pair[name] for pair in proof['ordinary_calls'] if pair['id']=='L538')
        require(first_log < second_reload < second_log, 'second W6 diagnostic must reload after first log')


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


def verify(witness_path=HERE/'static-witness.json', pins_path=HERE/'static-pins.json', originals=None):
    pins, pins_raw = load_json(pins_path)
    require(sha(pins_raw) == PINS_SHA256, 'independent static pins identity mismatch')
    keys(pins,['schema','kind','metadata_sha256','sources'],'pins')
    require(type(pins['schema']) is int and pins['schema']==1 and pins['kind']=='bm1368-reset-static-pins',
            'unsupported pin schema')
    witness, _ = load_json(witness_path)
    keys(witness,['schema','kind','sources','strings','proof'],'witness')
    require(type(witness['schema']) is int and witness['schema']==1 and witness['kind']=='bm1368-reset-static-witness',
            'unsupported witness schema')
    keys(witness['sources'],['cgminer','hwscan'],'sources')
    readers = {}
    for name, source in witness['sources'].items():
        keys(source,['elf_size','elf_sha256','regions','operands','calls','branches','literal_references','slot'],name)
        integer(source['elf_size'], name+' size')
        digest(source['elf_sha256'], name+' identity')
        expected = pins['sources'][name]
        require(source['elf_size']==expected['elf_size'] and source['elf_sha256']==expected['elf_sha256'],
                'whole ELF provenance mismatch')
        readers[name] = Ranges(source['regions'],expected['regions'])
    require(sha(canonical(metadata(witness))) == pins['metadata_sha256'],
            'reviewed proof/operand metadata differs from independent pins')
    for name, source in witness['sources'].items():
        verify_operands(source,readers[name])
        verify_calls_branches(name,source,readers[name])
        verify_slot(source,readers[name])
        verify_refs(source,readers[name])
    verify_strings(witness['strings'],witness['sources'],readers)
    verify_proof(witness['proof'],witness['sources'],readers)
    checked = []
    for name, path in (originals or {}).items():
        require(name in readers, 'unknown original input')
        verify_original(path,pins['sources'][name],readers[name])
        checked.append(name)
    return {'static_witness_verified':True,'original_files_compared':sorted(checked),
            'ordinary_sites_per_elf':24,'unreachable_cgminer_sites':4,
            'firmware_executed':False,'instruction_interpreter_used':False,
            'limits':'ordinary callback contract; semantic inference is static review, not hardware acceptance or automatic C equivalence'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--witness',type=Path,default=HERE/'static-witness.json')
    parser.add_argument('--pins',type=Path,default=HERE/'static-pins.json')
    parser.add_argument('--cgminer',type=Path,help='optional original ELF, read only as data')
    parser.add_argument('--hwscan',type=Path,help='optional original ELF, read only as data')
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

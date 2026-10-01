#!/usr/bin/env python3
"""Verify a fixed static snapshot; never execute or interpret vendor instructions.

The trust anchors are reviewed constants and hashes in this program and its
hash-pinned static-pins.json. Capstone decodes bounded code only. Integer
arithmetic resolves branch/literal addresses and EHABI PREL31. Fixed XORs decode
string data. There is no ARM machine state, interpreter, emulator or device I/O.
All validation uses explicit exceptions, including with python -O.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path
import struct
import sys

import capstone
from capstone import Cs, CS_ARCH_ARM, CS_MODE_ARM, CS_GRP_CALL, CS_GRP_JUMP

HERE = Path(__file__).resolve().parent
PINS_SHA256 = '5cc4ab737f8fe54fa0f0b176431d7434760d67169f7d9d018e0941619e28cb43'
BASE_COMMIT = '98ad426482947cf29beed1371a63136f8aac2b0c'
BASE_TREE = '70d1e1b0e8e3786db2b843503dabf90ad486c6d1'
INDEX_PATH = 'research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/README.md'
TEXT = {
    'module': 'driver',
    'path': '/tmp/build/libbitmain/src/chip/chip.c',
    'function': '[redacted]',
    'format': 'chain#%d - failed to send GET_STATUS command',
}
STRING_LAYOUT = {
    'cgminer': [(0x5ea1b0,7,0x3b),(0x5ea1b7,38,0xff),(0x5ea1dd,11,0xe2),(0x5ea1e8,45,0x1b)],
    'hwscan': [(0x47d914,7,0),(0x47de8d,38,0),(0x47d359,11,0),(0x47deb3,45,0)],
}

# These are static statements about the pinned words, not execution scenarios.
# A single loaded x supplies both factors. In Z/(2^32), x*(x-1) has bit 0 zero
# because one consecutive factor is even. Therefore each listed BEQ is taken;
# no value of the other guard word makes the listed dead interval reachable.
PARITY_WITNESSES = [
    ('body',0xd25b8,0xd25c0,0xd25c4,0xd25d4,0xd25d8,0xd25e8,(0xd25dc,0xd25e8)),
    ('body',0xd261c,0xd2624,0xd2628,0xd262c,0xd2630,0xd2678,(0xd2634,0xd2678)),
    ('crc_body',0xf8008,0xf800c,0xf8010,0xf8014,0xf8018,0xf8028,(0xf801c,0xf8028)),
    ('string_initializer_body',0xd2c44,0xd2c48,0xd2c4c,0xd2c50,0xd2c54,0xd2c64,(0xd2c58,0xd2c64)),
    ('string_initializer_body',0xd2c70,0xd2c74,0xd2c78,0xd2c80,0xd2c84,0xd2c38,(0xd2c88,0xd2ca4)),
    ('string_initializer_body',0xd2d04,0xd2d08,0xd2d0c,0xd2d10,0xd2d14,0xd2d24,(0xd2d18,0xd2d24)),
    ('string_initializer_body',0xd2d30,0xd2d34,0xd2d38,0xd2d40,0xd2d44,0xd2cf8,(0xd2d48,0xd2d64)),
]


class EvidenceError(ValueError):
    """The supplied artifact is not the reviewed static snapshot."""


def require(condition, message):
    if not condition:
        raise EvidenceError(message)


def sha256(data):
    return hashlib.sha256(data).hexdigest()


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':')).encode('utf-8')


def hx(value):
    return f'0x{value:08x}'


def as_int(value):
    return int(value, 0)


def exact_keys(value, expected, where):
    require(type(value) is dict and set(value) == set(expected), where + ': field set differs')


def hex_bytes(value, where):
    require(type(value) is str and len(value) % 2 == 0, where + ': invalid hex length')
    try:
        result = bytes.fromhex(value)
    except ValueError as e:
        raise EvidenceError(where + ': invalid hex') from e
    require(result.hex() == value, where + ': noncanonical hex')
    return result


def u32(data, offset=0):
    require(0 <= offset and offset + 4 <= len(data), 'word is outside selected bytes')
    return struct.unpack_from('<I', data, offset)[0]


def decode_range(data, start):
    require(capstone.__version__ == '5.0.6', 'use Capstone 5.0.6 for reproducible assembly')
    cs = Cs(CS_ARCH_ARM, CS_MODE_ARM)
    cs.detail = True
    insns = list(cs.disasm(data, start))
    require(len(data) % 4 == 0 and sum(i.size for i in insns) == len(data), 'incomplete ARM decoding')
    require(all(i.address == start+4*n and i.size == 4 for n,i in enumerate(insns)), 'noncontiguous ARM decoding')
    return insns


def render_code(insns):
    return ''.join(f'{i.address:08x}  {i.bytes.hex()}  {i.mnemonic:8s} {i.op_str}\n' for i in insns)


def render_data(data, start):
    return ''.join(f'{start+n:08x}  {data[n:n+4].hex()}  .word  {hx(u32(data,n))}\n' for n in range(0,len(data),4))


def flow_rows(insns):
    return [{'address':hx(i.address), 'instruction':i.mnemonic+' '+i.op_str, 'bytes_hex':i.bytes.hex()}
            for i in insns if i.group(CS_GRP_CALL) or i.group(CS_GRP_JUMP)
            or (i.mnemonic.startswith('pop') and 'pc' in i.op_str)]


def direct_target(word, address):
    require(word & 0x0e000000 == 0x0a000000, 'not an immediate ARM B/BL word')
    imm = word & 0xffffff
    if imm & 0x800000:
        imm -= 0x1000000
    return (address + 8 + (imm << 2)) & 0xffffffff


def prel31(word, address):
    displacement = word & 0x7fffffff
    if displacement & 0x40000000:
        displacement -= 0x80000000
    return (address + displacement) & 0xffffffff


def range_read(row, address, size, kinds=None):
    matches = []
    for key, entry in row['ranges'].items():
        if kinds is not None and key not in kinds:
            continue
        start, end = as_int(entry['start']), as_int(entry['end_exclusive'])
        if start <= address and address+size <= end:
            matches.append(hex_bytes(entry['bytes_hex'], key)[address-start:address-start+size])
    require(len(matches) == 1, 'read must belong to exactly one selected code/data range')
    return matches[0]


def verify_ranges(name, row, pins, folder):
    require(set(row['ranges']) == set(pins['ranges'][name]), name+': range set differs')
    decoded = {}
    intervals = []
    for key, entry in row['ranges'].items():
        expected = pins['ranges'][name][key]
        fields = set(expected) | {'bytes_hex'} | ({'branch_witnesses'} if key == 'body' else set())
        exact_keys(entry, fields, name+'/'+key)
        for field,value in expected.items():
            require(entry[field] == value, name+'/'+key+': fixed '+field+' differs')
        data = hex_bytes(entry['bytes_hex'], name+'/'+key)
        start, end = as_int(entry['start']), as_int(entry['end_exclusive'])
        require(end-start == len(data) == entry['size'], name+'/'+key+': byte length differs')
        require(sha256(data) == expected['sha256'], name+'/'+key+': fixed byte hash differs')
        intervals.append((start,end,key))
        if key.endswith('body'):
            insns = decode_range(data,start)
            require(len(insns) == expected['instruction_count'], name+'/'+key+': instruction count differs')
            require(flow_rows(insns) == pins['control_flow'][name][key], name+'/'+key+': branch/call/return set differs')
            for i in insns:
                word = u32(i.bytes)
                if word & 0x0e000000 == 0x0a000000:
                    target = direct_target(word,i.address)
                    require(i.op_str == '#'+hex(target), name+'/'+key+': decoded branch target differs')
                    if not word & (1 << 24):
                        require(start <= target < end and target % 4 == 0, name+'/'+key+': branch escapes code into data')
                    else:
                        require(key == 'body', name+'/'+key+': unexpected external helper call')
            if key == 'body':
                old_rows = [r for r in flow_rows(insns) if not r['instruction'].startswith('pop')]
                require(entry['branch_witnesses'] == old_rows, name+': raw branch metadata differs')
            decoded[key] = insns
            rendered = render_code(insns)
        else:
            require(key.endswith('literals') or key.endswith('padding'), 'unclassified data range')
            require('instruction_count' not in entry, 'data must not be counted as instructions')
            rendered = render_data(data,start)
        require((folder/name/(key+'.asm')).read_bytes() == rendered.encode('ascii'), name+'/'+key+': assembly re-render differs')
    intervals.sort()
    require(all(a[1] <= b[0] for a,b in zip(intervals,intervals[1:])), name+': code and data ranges overlap')
    return decoded


def verify_literals(name, row, supplement, pins, decoded):
    edges = row['literal_edges'] + supplement['extra_literal_edges']
    require(edges == pins['literal_edges'][name], name+': literal edge metadata differs')
    found = []
    for insns in decoded.values():
        found.extend(i.address for i in insns if u32(i.bytes) & 0xffff0000 == 0xe59f0000)
    require(sorted(found) == sorted(as_int(e['load_instruction']) for e in edges), name+': incomplete PC-relative literal coverage')
    code_keys = tuple(k for k in row['ranges'] if k.endswith('body'))
    pool_keys = tuple(k for k in row['ranges'] if k.endswith('literals'))
    for edge in edges:
        load, pc, literal = map(as_int,(edge['load_instruction'],edge['pc_relative_instruction'],edge['literal_address']))
        load_word = u32(range_read(row,load,4,code_keys))
        require(load_word & 0xffff0000 == 0xe59f0000, 'literal load opcode differs')
        require(load+8+(load_word & 0xfff) == literal, 'PC-relative literal address differs')
        literal_word = u32(range_read(row,literal,4,pool_keys))
        require(literal_word == as_int(edge['literal_word']), 'literal pool word differs')
        register = (load_word >> 12) & 15
        operation = 0xe79f0000 if edge['operation'] == 'load' else 0xe08f0000
        require(edge['operation'] in ('load','add'), 'unsupported PC-relative operation')
        require(u32(range_read(row,pc,4,code_keys)) == operation | (register << 12) | register,
                'PC-relative use opcode/register differs')
        require((pc+8+literal_word)&0xffffffff == as_int(edge['target']), 'PC-relative target differs')
        if edge['operation'] == 'load':
            require(u32(hex_bytes(edge['file_got_bytes'],'GOT')) == as_int(edge['file_got_word']), 'GOT word differs')
        else:
            label = edge['label'].removeprefix('dead_')
            target = next(s['address'] for s in row['strings'] if s['label'] == label)
            require(edge['target'] == target, 'string edge points to different string')


def verify_strings(name, row, pins):
    require(row['strings'] == pins['strings'][name], name+': fixed string witness differs')
    require(len(row['strings']) == 4, 'four diagnostic strings required')
    for (label,text), layout, entry in zip(TEXT.items(),STRING_LAYOUT[name],row['strings']):
        address,size,key = layout
        require((entry['label'],as_int(entry['address']),entry['size'],entry['xor_key']) == (label,address,size,key), 'string layout differs')
        raw = hex_bytes(entry['raw_hex'],name+'/'+label)
        require(len(raw) == size and sha256(raw) == entry['raw_sha256'], 'raw string length/hash differs')
        decoded = bytes(byte ^ key for byte in raw)
        require(decoded == text.encode('ascii')+b'\0', 'fixed string XOR/NUL differs')
        require(entry['decoded'] == text and entry['decoded_hex'] == decoded.hex(), 'decoded string metadata differs')
        require(decoded.count(b'\0') == 1, 'embedded diagnostic NUL differs')


def verify_semantic_words(name, row, pins, decoded):
    insns = {i.address:i for body in decoded.values() for i in body}
    for label, words in pins['semantic_words'][name].items():
        for fixed in words:
            address = as_int(fixed['address'])
            require(address in insns, label+': witness lies outside code')
            i = insns[address]
            require(i.bytes.hex() == fixed['bytes_hex'] and i.mnemonic+' '+i.op_str == fixed['instruction'], label+': fixed instruction differs')
    if name != 'cgminer':
        return
    for body,load,sub,mul,tst,branch,target,dead in PARITY_WITNESSES:
        require(insns[load].mnemonic == 'ldr' and insns[sub].mnemonic == 'sub' and insns[mul].mnemonic == 'mul', 'parity factor words differ')
        require(insns[tst].mnemonic == 'tst' and insns[tst].op_str.endswith(', #1'), 'parity bit is not bit zero')
        require(insns[branch].mnemonic == 'beq' and direct_target(u32(insns[branch].bytes),branch) == target, 'parity live edge differs')
        require(all(a in insns for a in range(dead[0],dead[1],4)), 'parity dead interval is incomplete')
    # Bounds include their NUL. These instruction words are independent of the
    # editable string labels and are also pinned with the complete initializer.
    for key_at,bound_at,key_word,bound_word in [
        (0xd2c68,0xd2c38,0xe221103b,0xe3520007),
        (0xd2cbc,0xd2cc8,0xe1e02002,0xe3500026),
        (0xd2d28,0xd2cf8,0xe22110e2,0xe352000b),
        (0xd2d7c,0xd2d88,0xe222201b,0xe350002d),
    ]:
        require(u32(insns[key_at].bytes) == key_word and u32(insns[bound_at].bytes) == bound_word, 'initializer transform/bound differs')


def file_slices(supplement):
    return {entry['label']:entry for entry in supplement['file_slices']}


def verify_elf_metadata(name, row, supplement, pins):
    slices = file_slices(supplement)
    require(len(slices) == len(supplement['file_slices']) == 6, name+': selected ELF metadata slices differ')
    for label,entry in slices.items():
        exact_keys(entry,('label','file_offset','size','sha256','bytes_hex'),label)
        data = hex_bytes(entry['bytes_hex'],label)
        require(len(data) == entry['size'] and sha256(data) == entry['sha256'], label+': byte length/hash differs')
    header = hex_bytes(slices['ELF32 header']['bytes_hex'],'ELF header')
    require(header[:7] == b'\x7fELF\x01\x01\x01' and struct.unpack_from('<H',header,18)[0] == 40, 'expected little-endian ELF32 ARM')
    phoff,shoff = struct.unpack_from('<II',header,28)
    ehsize,phentsize,phnum,shentsize,shnum,shstrndx = struct.unpack_from('<6H',header,40)
    require((ehsize,phentsize,shentsize,shnum,shstrndx)==(52,32,40,18,17), 'ELF structure differs')
    require(slices['program headers']['file_offset']==phoff and slices['program headers']['size']==phnum*phentsize, 'ELF program header placement differs')
    names = hex_bytes(slices['.shstrtab bytes']['bytes_hex'],'section names')
    sections = {}
    for label,index in (('.ARM.exidx',6),('.init_array',9),('.shstrtab',17)):
        entry=slices[label+' section header']
        require(entry['file_offset']==shoff+index*shentsize, 'ELF section header placement differs')
        fields=struct.unpack('<10I',hex_bytes(entry['bytes_hex'],label))
        require(names[fields[0]:].split(b'\0',1)[0] == label.encode(), 'ELF section name differs')
        sections[label]=fields
    shstr=sections['.shstrtab']
    require((shstr[4],shstr[5]) == (slices['.shstrtab bytes']['file_offset'],len(names)), 'section-name table extent differs')
    require(row['ehabi'] == pins['ehabi'][name], name+': unwind metadata differs')
    require(len(supplement['next_unwind_entries']) == len(row['ehabi']), 'next unwind entry count differs')
    for entry,nxt in zip(row['ehabi'],supplement['next_unwind_entries']):
        address=as_int(entry['table_address']); following=as_int(nxt['address'])
        require(following==address+8, 'next EHABI address differs')
        require(prel31(u32(hex_bytes(entry['bytes_hex'],'EHABI')),address)==as_int(entry['start']), 'EHABI PREL31 start differs')
        require(prel31(u32(hex_bytes(nxt['bytes_hex'],'next EHABI')),following)==as_int(entry['next_unwind_start']), 'EHABI next start differs')
        exidx=sections['.ARM.exidx']
        require(exidx[3] <= address and following+8 <= exidx[3]+exidx[5], 'EHABI witnesses outside .ARM.exidx')
    if name=='cgminer':
        reg=row['initializer_registration']
        require(reg==pins['initializer_registration'][name], 'initializer registration differs')
        require(as_int(reg['pointer'])==0xd2c0c and u32(hex_bytes(reg['bytes_hex'],'initializer'))==0xd2c0c, 'initializer pointer differs')
        init=sections['.init_array']; slot=as_int(reg['slot_address'])
        require(init[1]==14 and init[9]==4 and init[3]<=slot and slot+4<=init[3]+init[5] and (slot-init[3])%4==0,
                'initializer is not a .init_array word')


def verify_baseline(folder, pins, source_root=None):
    data=(folder/'source-baseline.json').read_bytes()
    require(sha256(data)==pins['source_baseline_sha256'], 'source baseline receipt pin differs')
    receipt=json.loads(data)
    require(receipt['base_commit']==BASE_COMMIT and receipt['base_tree']==BASE_TREE, 'accepted base provenance differs')
    require(len(receipt['files'])==18 and len({e['path'] for e in receipt['files']})==18, 'base provenance file set differs')
    active=[e for e in receipt['files'] if e['path']!=INDEX_PATH]
    require(len(active)==17, 'active dependency set must exclude only research index')
    if source_root is not None:
        for entry in active:
            data=(source_root/entry['path']).read_bytes()
            require(len(data)==entry['bytes'] and sha256(data)==entry['sha256'], 'active dependency pin differs: '+entry['path'])
            blob=hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()
            require(blob==entry['git_blob'], 'active dependency Git blob differs: '+entry['path'])
    return len(active) if source_root is not None else 0


def verify_original(name, path, row, supplement):
    # Optional original-image mode reads files as data. pyelftools never loads,
    # links, executes, emulates or interprets any original ARM instruction.
    from elftools.elf.elffile import ELFFile
    image=path.read_bytes()
    require(len(image)==row['source_bytes'] and sha256(image)==row['source_sha256'], name+': original image hash/size differs')
    elf=ELFFile(io.BytesIO(image))
    require(elf.elfclass==32 and elf.little_endian and elf['e_machine']=='EM_ARM', name+': original ELF architecture differs')
    segments=[s for s in elf.iter_segments() if s['p_type']=='PT_LOAD']
    def read(address,size):
        matches=[s for s in segments if s['p_vaddr']<=address and address+size<=s['p_vaddr']+s['p_filesz']]
        require(len(matches)==1, 'selected original bytes lack unique file-backed PT_LOAD')
        s=matches[0];offset=s['p_offset']+address-s['p_vaddr']
        return image[offset:offset+size]
    selected=[]
    for entry in row['ranges'].values(): selected.append((as_int(entry['start']),entry['bytes_hex']))
    for entry in row['strings']: selected.append((as_int(entry['address']),entry['raw_hex']))
    for edge in row['literal_edges']+supplement['extra_literal_edges']:
        if edge['operation']=='load': selected.append((as_int(edge['target']),edge['file_got_bytes']))
    for entry in row['ehabi']: selected.append((as_int(entry['table_address']),entry['bytes_hex']))
    for entry in supplement['next_unwind_entries']: selected.append((as_int(entry['address']),entry['bytes_hex']))
    if 'initializer_registration' in row:
        reg=row['initializer_registration'];selected.append((as_int(reg['slot_address']),reg['bytes_hex']))
        init=elf.get_section_by_name('.init_array');slot=as_int(reg['slot_address'])
        require(init is not None and init['sh_addr']<=slot and slot+4<=init['sh_addr']+init['sh_size'], 'original initializer section membership differs')
    for address,value in selected:
        expected=hex_bytes(value,'original selection')
        require(read(address,len(expected))==expected, name+': selected original bytes differ at '+hx(address))
    for entry in supplement['file_slices']:
        start=entry['file_offset'];end=start+entry['size']
        require(image[start:end]==hex_bytes(entry['bytes_hex'],'original ELF metadata'), 'original ELF metadata bytes differ')
    return len(selected)+len(supplement['file_slices'])


def verify(folder=HERE, source_root=None, originals=None):
    folder=Path(folder)
    pins_data=(folder/'static-pins.json').read_bytes()
    require(sha256(pins_data)==PINS_SHA256, 'immutable static pin file differs')
    pins=json.loads(pins_data)
    proof=json.loads((folder/'static-witnesses.json').read_bytes())
    supplement=json.loads((folder/'static-supplement.json').read_bytes())
    exact_keys(proof,('kind','original_executed','instruction_interpreter_used','device_or_network_access','sources'),'raw witness')
    require(proof['kind']=='static-full-common-read-register-review', 'raw witness kind differs')
    require(all(proof[k] is False for k in ('original_executed','instruction_interpreter_used','device_or_network_access')), 'static-only provenance flags differ')
    require(set(proof['sources'])==set(supplement['sources'])=={'cgminer','hwscan'}, 'image witness set differs')
    counts={}; original_counts={}
    for name,row in proof['sources'].items():
        fields={'source_sha256','source_bytes','ranges','literal_edges','strings','ehabi'}
        if name=='cgminer': fields.add('initializer_registration')
        exact_keys(row,fields,name)
        require({k:row[k] for k in pins['sources'][name]}==pins['sources'][name], name+': source image identity differs')
        decoded=verify_ranges(name,row,pins,folder)
        verify_literals(name,row,supplement['sources'][name],pins,decoded)
        verify_strings(name,row,pins)
        verify_semantic_words(name,row,pins,decoded)
        verify_elf_metadata(name,row,supplement['sources'][name],pins)
        counts[name]={k:len(v) for k,v in decoded.items()}
        if originals and name in originals:
            original_counts[name]=verify_original(name,Path(originals[name]),row,supplement['sources'][name])
    # Preserve every raw field, including metadata outside the semantic checks.
    require(sha256(canonical(proof))==pins['raw_witness_canonical_sha256'], 'raw witness snapshot differs')
    require(sha256(canonical(supplement))==pins['supplement_canonical_sha256'], 'ELF supplement snapshot differs')
    checked=verify_baseline(folder,pins,Path(source_root) if source_root is not None else None)
    return {'status':'PASS','evidence_mode':'static fixed snapshot; no vendor execution',
            'decoded_instruction_counts':counts,'parity_identities_checked':len(PARITY_WITNESSES),
            'base_commit':BASE_COMMIT,'base_tree':BASE_TREE,'base_provenance_files':18,
            'active_dependencies_checked':checked,'active_dependency_total':17,
            'research_index_active_pin':False,'original_image_selections_checked':original_counts,
            'original_executed':False,'instruction_interpreter_used':False,
            'hardware_or_runtime_parity_proven':False}


def main(argv=None):
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--evidence-dir',type=Path,default=HERE)
    parser.add_argument('--source-root','--root',dest='source_root',type=Path,help='repository root; verifies the 17 unchanged dependency files')
    parser.add_argument('--cgminer',type=Path,help='optional original cgminer ELF, read only as data')
    parser.add_argument('--hwscan',type=Path,help='optional original hwscan ELF, read only as data')
    args=parser.parse_args(argv)
    source_root=args.source_root
    if source_root is None:
        # When installed at research/.../common-read-register, verify the repo
        # dependencies automatically. Standalone copied evidence remains usable.
        parents=args.evidence_dir.resolve().parents
        if len(parents)>3 and (parents[3]/'integration/bm1368_control.c').is_file():
            source_root=parents[3]
    originals={name:getattr(args,name) for name in ('cgminer','hwscan') if getattr(args,name) is not None}
    try:
        result=verify(args.evidence_dir,source_root,originals)
    except (EvidenceError,OSError,ValueError,KeyError,TypeError,StopIteration,struct.error) as error:
        print('FAIL: '+str(error),file=sys.stderr)
        return 1
    print(json.dumps(result,indent=2,sort_keys=True))
    return 0


if __name__=='__main__':
    sys.exit(main())

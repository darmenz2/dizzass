#!/usr/bin/env python3
"""Index ARM ELF metadata as data, without loading or executing the target.

EHABI rows describe unwind coverage, not a complete set of function boundaries.
"""
import argparse
import collections
import csv
import hashlib
import io
import json
import pathlib
import resource
import struct

from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection

MAX_BYTES = 128 * 1024**2
MAX_RECORDS = 200_000


def hx(value):
    return f"0x{value:08x}"


def prel31(word, place):
    value = word & 0x7fffffff
    if value & 0x40000000:
        value -= 0x80000000
    return (place + value) & 0xffffffff


class Snapshot:
    def __init__(self, raw):
        if len(raw) > MAX_BYTES:
            raise ValueError("ELF byte budget exceeded")
        self.raw = raw
        self.digest = hashlib.sha256(raw).hexdigest()
        self.elf = ELFFile(io.BytesIO(raw))
        if self.elf.elfclass != 32 or not self.elf.little_endian or self.elf['e_machine'] != 'EM_ARM':
            raise ValueError("need ELF32 little-endian ARM")
        if self.elf['e_type'] not in ('ET_EXEC', 'ET_DYN'):
            raise ValueError("need a linked ELF, not relocatable input")
        if self.elf.num_sections() > 2048 or self.elf.num_segments() > 2048:
            raise ValueError("ELF header count budget exceeded")
        self.sections = list(self.elf.iter_sections())
        self.loads = [dict(s.header) for s in self.elf.iter_segments() if s['p_type'] == 'PT_LOAD']
        for load in self.loads:
            if load['p_filesz'] > load['p_memsz'] or load['p_offset'] + load['p_filesz'] > len(raw):
                raise ValueError("invalid or truncated PT_LOAD")
            if load['p_vaddr'] + load['p_memsz'] > 2**32:
                raise ValueError("PT_LOAD address overflow")
        for section in self.sections:
            if section['sh_type'] != 'SHT_NOBITS' and section['sh_offset'] + section['sh_size'] > len(raw):
                raise ValueError("truncated section")

    @classmethod
    def read(cls, path):
        with pathlib.Path(path).open('rb') as source:
            return cls(source.read(MAX_BYTES + 1))

    def mapped(self, address, size=1, executable=False):
        if address < 0 or size <= 0 or address + size > 2**32:
            raise ValueError("invalid virtual range")
        matches = [s for s in self.loads if s['p_vaddr'] <= address and
                   address + size <= s['p_vaddr'] + s['p_filesz']]
        if len(matches) != 1:
            raise ValueError("range must have exactly one file-backed PT_LOAD mapping")
        load = matches[0]
        if executable and not load['p_flags'] & 1:
            raise ValueError("range is not executable by ELF metadata")
        return load['p_offset'] + address - load['p_vaddr'], load['p_flags']

    def bytes_at(self, address, size, executable=False):
        offset, flags = self.mapped(address, size, executable)
        return self.raw[offset:offset+size], offset, flags

    def section_bytes(self, section):
        raw, offset, _ = self.bytes_at(section['sh_addr'], section['sh_size'])
        if offset != section['sh_offset']:
            raise ValueError("section/load mapping disagrees")
        return raw


def build_index(snapshot):
    elf = snapshot.elf
    functions, mappings, unwind, arrays = [], [], [], []
    symbol_tables = []
    symbol_count = 0
    for section_number, section in enumerate(snapshot.sections):
        if not isinstance(section, SymbolTableSection):
            continue
        count = section.num_symbols()
        symbol_count += count
        if symbol_count > MAX_RECORDS:
            raise ValueError("symbol budget exceeded")
        symbol_tables.append(section.name)
        for symbol_number, symbol in enumerate(section.iter_symbols()):
            name = symbol.name
            if len(name) > 512 or any(ord(c) < 32 or ord(c) == 127 for c in name):
                raise ValueError("unsafe or oversized symbol name")
            index = symbol['st_shndx']
            if not isinstance(index, int) or not 0 < index < len(snapshot.sections):
                continue
            raw_address = symbol['st_value']
            if symbol['st_info']['type'] == 'STT_FUNC':
                address = raw_address & ~1
                size = symbol['st_size']
                snapshot.mapped(address, max(1, size), executable=True)
                functions.append(dict(address=hx(address), pointer=hx(raw_address),
                    mode='thumb' if raw_address & 1 else 'arm', name=name,
                    declared_size=size, end_exclusive=hx(address+size) if size else '',
                    boundary_evidence='ELF_symbol_declared_extent' if size else 'ELF_symbol_start_only',
                    table=section.name, symbol_index=symbol_number))
            elif symbol['st_info']['type'] == 'STT_NOTYPE' and symbol['st_info']['bind'] == 'STB_LOCAL':
                prefix = name.split('.')[0]
                if prefix in ('$a', '$t', '$d'):
                    mappings.append(dict(address=hx(raw_address), section_index=index,
                        kind={'$a':'arm','$t':'thumb','$d':'data'}[prefix], name=name))
    for section in snapshot.sections:
        if section['sh_type'] == 'SHT_ARM_EXIDX':
            if section['sh_size'] % 8 or section['sh_addr'] % 4 or section['sh_offset'] % 4:
                raise ValueError("unaligned/truncated EHABI table")
            if len(unwind) + section['sh_size']//8 > MAX_RECORDS:
                raise ValueError("EHABI record budget exceeded")
            rows = []
            raw = snapshot.section_bytes(section)
            for i, (word0, word1) in enumerate(struct.iter_unpack('<II', raw)):
                place = section['sh_addr'] + i*8
                if word0 & 0x80000000:
                    raise ValueError("EHABI function PREL31 high bit must be clear")
                pointer = prel31(word0, place)
                address = pointer & ~1
                snapshot.mapped(address, 1, executable=True)
                if rows and address <= int(rows[-1]['address'], 16):
                    raise ValueError("EHABI starts must be strictly increasing")
                descriptor = 'cantunwind' if word1 == 1 else ('compact_inline' if word1 & 0x80000000 else 'extab_pointer')
                extab = ''
                if descriptor == 'extab_pointer':
                    target = prel31(word1, place+4)
                    if target % 4:
                        raise ValueError("unaligned extab pointer")
                    snapshot.mapped(target, 4)
                    extab = hx(target)
                rows.append(dict(address=hx(address), pointer=hx(pointer),
                    mode_at_start='thumb' if pointer & 1 else 'arm',
                    coverage_end_exclusive='', function_end_exclusive='',
                    boundary_evidence='EHABI_unwind_range_start_not_function_extent',
                    descriptor=descriptor, extab_address=extab, section=section.name,
                    index=i, table_address=hx(place), file_offset=section['sh_offset']+i*8,
                    word0=hx(word0), word1=hx(word1)))
            for current, following in zip(rows, rows[1:]):
                current['coverage_end_exclusive'] = following['address']
            unwind.extend(rows)
        if section['sh_type'] in ('SHT_INIT_ARRAY', 'SHT_FINI_ARRAY', 'SHT_PREINIT_ARRAY'):
            if section['sh_size'] % 4 or section['sh_size']//4 > 8192:
                raise ValueError("invalid/budget-exceeding initialization array")
            for i, (pointer,) in enumerate(struct.iter_unpack('<I', snapshot.section_bytes(section))):
                address = pointer & ~1
                valid = pointer not in (0, 0xffffffff)
                if valid:
                    snapshot.mapped(address, 1, executable=True)
                arrays.append(dict(section=section.name, index=i,
                    slot_address=hx(section['sh_addr']+4*i), pointer=hx(pointer),
                    address=hx(address) if valid else '',
                    mode_at_start=('thumb' if pointer & 1 else 'arm') if valid else 'sentinel',
                    evidence='ELF_array_pointer_not_function_extent'))
    functions.sort(key=lambda r:(int(r['address'],16),r['name'],r['table'],r['symbol_index']))
    mappings.sort(key=lambda r:(r['section_index'],int(r['address'],16),r['name']))
    entry = elf['e_entry']
    snapshot.mapped(entry & ~1, 1, executable=True)
    summary = dict(schema=1, source_sha256=snapshot.digest, source_bytes=len(snapshot.raw),
        elf_class=elf.elfclass, machine=elf['e_machine'], little_endian=elf.little_endian,
        elf_type=elf['e_type'], flags=hx(elf['e_flags']), entry_pointer=hx(entry),
        entry_address=hx(entry & ~1), entry_mode='thumb' if entry & 1 else 'arm',
        symbol_tables=symbol_tables, symbol_records=symbol_count,
        function_symbol_records=len(functions), mapping_symbol_records=len(mappings),
        ehabi_records=len(unwind), ehabi_descriptors=dict(sorted(collections.Counter(r['descriptor'] for r in unwind).items())),
        array_pointer_records=len(arrays), firmware_executed=False,
        caveats=["EHABI entries can cover multiple functions, especially merged cantunwind ranges; leaf functions can be absent.",
                 "Coverage ends are next EHABI starts, not proven function ends; the final end is unknown.",
                 "Pointer bit zero identifies mode only at that address, not throughout the interval.",
                 "Symbol extents, when present, are declarations in ELF metadata, not independently proven control-flow extents.",
                 "No code execution, unwind interpretation, decompilation, CFG or runtime-equivalence proof is performed."],
        executable_sections=[dict(name=s.name,address=hx(s['sh_addr']),size=s['sh_size'],file_offset=s['sh_offset'])
                             for s in snapshot.sections if s['sh_flags'] & 4])
    return summary, {'functions':functions,'mapping-symbols':mappings,'ehabi':unwind,'init-arrays':arrays}


def new_output(path):
    for component in (path, *path.parents):
        if component.is_symlink():
            raise ValueError("output ancestor is a symlink")
    path.mkdir(parents=True, exist_ok=False, mode=0o700)


def write_index(path, summary, tables):
    new_output(path)
    artifacts = {}
    empty_headers = {
        'functions': ['address','pointer','mode','name','declared_size','end_exclusive','boundary_evidence','table','symbol_index'],
        'mapping-symbols': ['address','section_index','kind','name'],
        'ehabi': ['address','pointer','mode_at_start','coverage_end_exclusive','function_end_exclusive','boundary_evidence','descriptor','extab_address','section','index','table_address','file_offset','word0','word1'],
        'init-arrays': ['section','index','slot_address','pointer','address','mode_at_start','evidence'],
    }
    for name, rows in sorted(tables.items()):
        target = path / (name+'.tsv')
        with target.open('w', newline='') as stream:
            writer = csv.DictWriter(stream, fieldnames=list(rows[0]) if rows else empty_headers[name], delimiter='\t', lineterminator='\n')
            writer.writeheader()
            writer.writerows(rows)
        artifacts[target.name] = hashlib.sha256(target.read_bytes()).hexdigest()
    summary = dict(summary, artifacts_sha256=artifacts)
    (path/'summary.json').write_text(json.dumps(summary, indent=2, sort_keys=True)+'\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('elf', type=pathlib.Path)
    parser.add_argument('--out', type=pathlib.Path, required=True)
    args = parser.parse_args()
    resource.setrlimit(resource.RLIMIT_CPU, (30,30))
    resource.setrlimit(resource.RLIMIT_AS, (1024**3,1024**3))
    summary, tables = build_index(Snapshot.read(args.elf))
    write_index(args.out, summary, tables)
    print(json.dumps(summary, sort_keys=True))


if __name__ == '__main__':
    main()

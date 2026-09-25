#!/usr/bin/env python3
"""Rebuild source-path evidence and blocked pending translation units.
This is a map of OBSERVED paths, never a claim that all vendor paths survived.
"""
from pathlib import Path
import hashlib,json,re,sys,struct
from elf32 import ELF32
ROOT=Path(__file__).resolve().parents[1]
BIN_SHA='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'

def build():
    binary=ROOT/'reference/cgminer.vendor.elf'
    if hashlib.sha256(binary.read_bytes()).hexdigest()!=BIN_SHA:raise ValueError('Wrong original binary')
    elf=ELF32(binary)
    strings=json.loads((ROOT/'evidence/stage1/cgminer_xor_strings.json').read_text())
    xrefs=json.loads((ROOT/'evidence/stage1/cgminer_string_xrefs.json').read_text())
    # Preserve the historical Stage 1 files. Apply independently verified
    # constructor-length corrections only in this regenerated view.
    correction_file=ROOT/'evidence/stage5/source-string-corrections.json'
    corrections=json.loads(correction_file.read_text()) if correction_file.exists() else []
    by_address={c['base']:c for c in corrections}
    strings=[by_address.get(item['base'],item) for item in strings]
    for refs in xrefs.values():
        for ref in refs:
            if ref.get('string') in by_address:
                ref['text']=by_address[ref['string']]['text']
                ref['text_corrected_from_constructor']=True
    paths={};verified=0;different=0
    for item in strings:
        raw=bytes(v^item['xor'] for v in elf.read(int(item['base'],16),item['length']))
        text=raw.decode('utf-8','replace')
        if text.rstrip('\0')==item['text'].rstrip('\0'):verified+=1
        else:different+=1
        for match in re.finditer(rb'/tmp/build/[A-Za-z0-9_./+\-]+\.(?:c|h)(?=[^A-Za-z0-9_.]|$)',raw):
            absolute=match.group().decode('ascii');rel=absolute[len('/tmp/build/'):]
            if '..' in Path(rel).parts:raise ValueError('Unsafe path')
            entry=paths.setdefault(rel,dict(path=rel,observed_as=absolute,status='pending-not-implemented',
                evidence=[],candidate_intervals=[],implementation_files=[]))
            entry['evidence'].append(dict(address=item['base'],xor=item['xor'],decoded_length=item['length'],
                byte_match=True,terminal_suffix_hex=raw[match.end():].hex()))
    # Reparse EHABI, do not trust prior intervals as function boundaries.
    sec=elf.sections['.ARM.exidx'];data=elf.section('.ARM.exidx');ranges=[]
    for i in range(0,len(data),8):
        word,unwind=struct.unpack_from('<II',data,i);offset=word&0x7fffffff
        if offset&0x40000000:offset-=0x80000000
        ranges.append(dict(start=sec['addr']+i+offset,unwind_word=f'0x{unwind:08x}'))
    for i,entry in enumerate(ranges):
        entry['end_exclusive']=ranges[i+1]['start'] if i+1<len(ranges) else None
        entry['is_function_boundary_claim']=False
    ranged={e['start']:e for e in ranges}
    for start,refs in xrefs.items():
        for rel,entry in paths.items():
            matched=[r for r in refs if entry['observed_as'] in r['text']]
            if matched:
                interval=ranged.get(int(start,16),{'start':int(start,16),'end_exclusive':None})
                entry['candidate_intervals'].append(dict(start=f"0x{interval['start']:08x}",
                    end_exclusive=(f"0x{interval['end_exclusive']:08x}" if interval['end_exclusive'] else None),
                    path_references=matched,association='Stage 1 PC-relative xrefs inside EHABI bucket; ownership NOT proven'))
    partial_paths=['src/frontend/cgminer.c','src/backend/work-gen/work-gen.c','libbitmain/src/chip/chip1398.c','libbitmain/src/pll.c','libbitmain/src/aml/chip.c','libbitmain/src/reg_cache.c','libbitmain/src/uart.c']
    for partial in partial_paths:
        paths[partial]['status']='partial-verified-slices'
        paths[partial]['implementation_files']=[partial]
    for rel,entry in paths.items():
        p=ROOT/rel;p.parent.mkdir(parents=True,exist_ok=True)
        ep=ROOT/'evidence/modules'/Path(rel+'.json');ep.parent.mkdir(parents=True,exist_ok=True)
        ep.write_text(json.dumps(entry,indent=2)+'\n')
        if entry['status']=='partial-verified-slices':continue
        # Existing implementations are never overwritten by rerunning this mapper.
        if p.exists() and 'VN135_PENDING_MODULE' not in p.read_text():continue
        message=(f'/* VN135_PENDING_MODULE\n * Observed source path: {entry["observed_as"]}\n'
                 f' * Source-path bytes verified against the supplied ELF.\n'
                 f' * This translation unit is NOT reconstructed and is NOT in the build.\n'
                 f' * Evidence: evidence/modules/{rel}.json\n'
                 f' * No fake functions, signatures, constants or successful return values.\n */\n'
                 f'#error "VN135 pending module: {rel}; not a recovered implementation"\n')
        p.write_text(message)
    output=dict(reference_sha256=BIN_SHA,observed_source_paths=len(paths),
        partial_modules=len(partial_paths),pending_modules=len(paths)-len(partial_paths),complete_vendor_file_list=False,
        strings_checked=len(strings),string_text_equal_after_trailing_nul_strip=verified,
        string_text_different=different,
        source_path_method='XOR raw original bytes using Stage 1 metadata plus constructor-verified length corrections, then extract exact /tmp/build/...c or ...h prefix',
        limits=['File path evidence is not recovered file content.',
                'Paths absent from the binary cannot be enumerated from this evidence.',
                'A source-path reference inside an EHABI range does not prove all functions in that range belong to it.',
                'Stem libbitmain/src/pll.c is observed before trailing non-UTF-8 bytes; suffix is retained in evidence.'],
        modules=[paths[k] for k in sorted(paths)])
    (ROOT/'evidence/source-tree.json').write_text(json.dumps(output,indent=2)+'\n')
    (ROOT/'evidence/ehabi-ranges.json').write_text(json.dumps({'function_table':False,'entries':ranges},indent=2)+'\n')
    print(json.dumps({k:output[k] for k in ('observed_source_paths','partial_modules','pending_modules','strings_checked','string_text_equal_after_trailing_nul_strip','string_text_different')},indent=2))
if __name__=='__main__':build()

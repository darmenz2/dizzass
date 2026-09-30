#!/usr/bin/env python3
"""Static byte-verified ELF slice; does not load/execute the target program."""
import argparse,hashlib,io,json,pathlib,resource
import capstone
from elftools.elf.elffile import ELFFile

def parse_int(s): return int(s,0)
def extract_slice(path,start,end):
    if end<=start or end-start>1024**2:raise ValueError('range must be positive and at most 1 MiB')
    with path.open('rb') as source:
        snapshot=source.read(128*1024**2+1)
    if len(snapshot)>128*1024**2:raise ValueError('ELF byte budget exceeded')
    with io.BytesIO(snapshot) as f:
        elf=ELFFile(f)
        if elf['e_machine']!='EM_ARM' or not elf.little_endian:raise ValueError('need little-endian ARM ELF')
        for seg in elf.iter_segments():
            if seg['p_type']=='PT_LOAD' and seg['p_vaddr']<=start and end<=seg['p_vaddr']+seg['p_filesz']:
                offset=seg['p_offset']+start-seg['p_vaddr'];f.seek(offset);data=f.read(end-start)
                if len(data)!=end-start:raise ValueError('truncated range')
                return data,offset,elf.elfclass,seg['p_flags'],hashlib.sha256(snapshot).hexdigest()
    raise ValueError('range not wholly within one file-backed PT_LOAD segment')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('elf',type=pathlib.Path)
    p.add_argument('--start',type=parse_int,required=True);p.add_argument('--end',type=parse_int,required=True)
    p.add_argument('--mode',choices=['arm','thumb'],required=True);p.add_argument('--out',type=pathlib.Path,required=True)
    a=p.parse_args();resource.setrlimit(resource.RLIMIT_CPU,(30,30));resource.setrlimit(resource.RLIMIT_AS,(1024**3,1024**3))
    data,offset,bits,flags,source_sha256=extract_slice(a.elf,a.start,a.end)
    if a.start%(4 if a.mode=='arm' else 2):raise ValueError('start is not mode-aligned')
    md=capstone.Cs(capstone.CS_ARCH_ARM,capstone.CS_MODE_ARM if a.mode=='arm' else capstone.CS_MODE_THUMB)
    md.skipdata=True
    lines=[];used=0
    for ins in md.disasm(data,a.start):
        lines.append(f'{ins.address:08x}  {ins.bytes.hex():<10}  {ins.mnemonic:<10} {ins.op_str}')
        used+=ins.size
    if used!=len(data):raise ValueError('disassembly did not account for every slice byte')
    for component in (a.out,*a.out.parents):
        if component.is_symlink():raise ValueError('output ancestor is a symlink')
    a.out.mkdir(parents=True,exist_ok=False,mode=0o700)
    (a.out/'slice.bin').write_bytes(data);(a.out/'slice.bin').chmod(0o400)
    (a.out/'slice.asm').write_text('\n'.join(lines)+'\n')
    receipt={'schema':1,'source_name':a.elf.name,'source_sha256':source_sha256,
      'range_start':hex(a.start),'range_end_exclusive':hex(a.end),'file_offset':offset,'bytes':len(data),
      'slice_sha256':hashlib.sha256(data).hexdigest(),'elf_bits':bits,'segment_flags':flags,'mode':a.mode,
      'disassembler':'capstone','version':capstone.__version__,'firmware_executed':False,
      'caveat':'Linear decoding of a chosen range; boundaries/mode/code-vs-literal-data require independent control-flow proof.'}
    (a.out/'receipt.json').write_text(json.dumps(receipt,indent=2,sort_keys=True)+'\n')
    print(json.dumps(receipt))
if __name__=='__main__':main()

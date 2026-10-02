"""Read-only, bounded pattern audit. Original code is never executed.

Run with pinned ELF and output directory. Requires pyelftools 0.32 and
capstone 5.0.6 for static disassembly only. Patterns intentionally do not
establish whole-program reachability or absence of arbitrary indirect calls.
"""
from pathlib import Path
import sys, struct, json, hashlib
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM, CS_MODE_ARM, CS_MODE_LITTLE_ENDIAN

path=Path(sys.argv[1]); dest=Path(sys.argv[2]); dest.mkdir(exist_ok=True)
with path.open('rb') as source_stream:
 blob=source_stream.read(6228005)
if len(blob)!=6228004: raise ValueError('Wrong cgminer length')
expected='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
if hashlib.sha256(blob).hexdigest()!=expected: raise ValueError('Wrong cgminer identity')
md=Cs(CS_ARCH_ARM,CS_MODE_ARM|CS_MODE_LITTLE_ENDIAN)
receipt={'source_sha256':expected,'instruction_interpreter_used':False,
         'patterns':'all four-byte-aligned .text A32 B/BL immediate; aligned section words; exact LDR literal followed by LDR [PC,Rt] GOT pair; immediate positive LDR +74/+184 followed by same-register BLX within 24 words (candidate only; no def-use proof)',
         'direct_branches_to_e33e0':[],'aligned_words_e33e0':[],
         'pc_relative_got_loads':[],'immediate_load_counts':{},'candidate_same_register_calls':[]}
with path.open('rb') as f:
 elf=ELFFile(f); sec=elf.get_section_by_name('.text'); raw=sec.data(); base=sec['sh_addr']
 def read(a,n):
  for seg in elf.iter_segments():
   if seg['p_type']=='PT_LOAD' and seg['p_vaddr']<=a and a+n<=seg['p_vaddr']+seg['p_filesz']:
    off=seg['p_offset']+a-seg['p_vaddr']; return blob[off:off+n]
  raise ValueError(hex(a))
 def word(a):return struct.unpack('<I',read(a,4))[0]
 for s in elf.iter_sections():
  if s['sh_type']=='SHT_NOBITS':continue
  sd=s.data()
  for n in range(0,len(sd)-3,4):
   if struct.unpack_from('<I',sd,n)[0]==0xe33e0:receipt['aligned_words_e33e0'].append({'section':s.name,'address':hex(s['sh_addr']+n)})
 for n in range(0,len(raw)-3,4):
  a=base+n; w=struct.unpack_from('<I',raw,n)[0]
  nw=struct.unpack_from('<I',raw,n+4)[0] if n+8<=len(raw) else None
  if w>>25&7==5 and w>>28!=15:
   imm=(w&0xffffff)<<2
   if imm&0x2000000:imm-=0x4000000
   if (a+8+imm)&0xffffffff==0xe33e0:receipt['direct_branches_to_e33e0'].append(hex(a))
  if w&0x0f7f0000==0x051f0000:
   rt=w>>12&15; lit=a+8+((w&0xfff) if w&0x800000 else -(w&0xfff))
   if base<=lit<base+len(raw)-3:
    lv=word(lit)
    if nw is not None and nw&0x0ffffff0==(0x079f0000|(rt<<12)) and nw&15==rt and (a+12+lv)&0xffffffff==0x5dffe4:
     receipt['pc_relative_got_loads'].append({'literal_ldr':hex(a),'got_ldr':hex(a+4),'literal_address':hex(lit),'literal_word':hex(lv),'got':'0x5dffe4','identity':hex(word(0x5dffe4))})
  if w&0x0ff00000!=0x05900000 or w&0xfff not in (0x74,0x184):continue
  rn=w>>16&15;rt=w>>12&15
  if rn in (11,13,15):continue
  key=hex(w&0xfff);receipt['immediate_load_counts'][key]=receipt['immediate_load_counts'].get(key,0)+1
  for m in range(n+4,min(n+100,len(raw)-3),4):
   v=struct.unpack_from('<I',raw,m)[0]
   if v&0x0fffffff==0x012fff30|rt:
    receipt['candidate_same_register_calls'].append({'load':hex(a),'offset':key,'blx':hex(base+m)})
    break
 receipt['rejected_184_windows']=[]
 asm=[]
 for a,b in ((0x1e5c60,0x1e5ca0),(0x1e5cbc,0x1e5cf8),(0x1e5674,0x1e5680),(0x1e5b04,0x1e5b10)):
  r=read(a,b-a);receipt['rejected_184_windows'].append({'start':hex(a),'end_exclusive':hex(b),'bytes':len(r),'sha256':hashlib.sha256(r).hexdigest()})
  asm.append('RANGE '+hex(a)+'..'+hex(b))
  for i in md.disasm(r,a):asm.append(f'{i.address:08x}  {i.bytes.hex():8}  {i.mnemonic} {i.op_str}')
(dest/'audit-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n')
(dest/'rejected-184.asm').write_text('\n'.join(asm)+'\n')
print(json.dumps(receipt,indent=2))

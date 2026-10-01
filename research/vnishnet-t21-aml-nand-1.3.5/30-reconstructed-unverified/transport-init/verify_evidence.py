#!/usr/bin/env python3
"""Validate frozen data and optionally re-render exact ELF windows. Never execute targets."""
import argparse,hashlib,json,pathlib,struct,sys
HERE=pathlib.Path(__file__).resolve().parent
ROOT=HERE.parents[3]
SOURCE_HASHES={'cgminer':'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9','hwscan':'951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'}
def require(ok,message):
 if not ok:raise ValueError(message)
def digest(b):return hashlib.sha256(b).hexdigest()
def verify(directory=HERE,source_root=ROOT,references=None):
 proof=json.loads((directory/'evidence/dispatch-proof.json').read_text());total=0
 require(proof['firmware_executed'] is False and proof['original_interpreter_used'] is False,'execution scope')
 require(set(proof['sources'])==set(SOURCE_HASHES),'source set')
 for name,expected_source in SOURCE_HASHES.items():
  rec=proof['sources'][name];require(rec['sha256']==expected_source,'source hash');dest=directory/'evidence'/name
  plan=json.loads((dest/'plan.json').read_text());require(plan['source_sha256']==expected_source,'plan source');memory={}
  require(len(plan['ranges'])==rec['witness_windows'],'window count')
  require(set(rec['artifact_sha256'])=={e['name']+ext for e in plan['ranges'] for ext in ['.asm','.json']},'artifact set')
  for f,sha in rec['artifact_sha256'].items():require(digest((dest/f).read_bytes())==sha,'artifact digest '+f)
  for entry in plan['ranges']:
   receipt=json.loads((dest/(entry['name']+'.json')).read_text());start=int(entry['start'],0);end=int(entry['end_exclusive'],0)
   require(receipt['source_sha256']==expected_source,'receipt source')
   require(int(receipt['start'],0)==start and int(receipt['end_exclusive'],0)==end and receipt['mode']==entry['mode'],'receipt range')
   require(receipt['bytes']==end-start and receipt['firmware_executed'] is False,'receipt size/scope')
   data=bytearray();address=start
   for line in (dest/(entry['name']+'.asm')).read_text().splitlines():
    fields=line.split();require(int(fields[0],16)==address,'assembly address');b=bytes.fromhex(fields[1]);require(len(b)==4,'A32/data width')
    for offset,value in enumerate(b):
     previous=memory.get(address+offset);require(previous is None or previous==value,'overlap conflict');memory[address+offset]=value
    data.extend(b);address+=len(b)
   require(address==end and digest(data)==entry['sha256']==receipt['sha256'],'slice bytes/hash')
  def word(address):return struct.unpack('<I',bytes(memory[address+i] for i in range(4)))[0]
  require(sum(int(e['end_exclusive'],0)-int(e['start'],0) for e in plan['ranges'])==rec['witness_bytes'],'byte count')
  for pc,value in rec['fixed_words'].items():require(word(int(pc,0))==int(value,0),'fixed word')
  for row in rec['got']:
   literal=word(int(row['literal'],0));address=(int(row['load_instruction'],0)+8+literal)&0xffffffff
   require(literal==int(row['literal_word'],0) and address==int(row['got_address'],0),'GOT arithmetic')
   require(word(address)==int(row['value'],0),'GOT value')
  for table in rec['jump_tables'].values():
   base=int(table['base'],0)
   require([((base+word(base+4*i))&0xffffffff) for i in range(len(table['targets']))]==[int(v,0) for v in table['targets']],'jump table')
  require([r['chip_selector'] for r in rec['chip_initializers']]==list(range(8)),'chip selectors')
  for edge in rec['chip_initializers']:
   pc=int(edge['branch_instruction'],0);w=word(pc);imm=w&0xffffff;imm=imm-(1<<24) if imm&(1<<23) else imm
   require((w>>25)&7==5 and ((pc+8+4*imm)&0xffffffff)==int(edge['target'],0),'constructor edge')
   require(edge['tail_call']==(not bool(w&(1<<24))),'edge type')
  require(len(rec['ordered_stores'])==2,'store count')
  stores=rec['ordered_stores'];require(int(stores[0]['instruction'],0)<int(stores[1]['instruction'],0),'store order')
  require(word(int(stores[0]['instruction'],0))==({'hwscan':0xe580c018,'cgminer':0xe5823018}[name]),'send store')
  require(word(int(stores[1]['instruction'],0))==({'hwscan':0xe5830000,'cgminer':0xe5842000}[name]),'common store')
  require(stores[0]['destination']==({'hwscan':'0x4e4cac','cgminer':'0x68bf80'}[name]) and stores[1]['destination']=='caller output + 0','store destination')
  require(stores[1]['value']==({'hwscan':'0xea7e4','cgminer':'0xd253c'}[name]),'common identity')
  if references and name in references:
   sys.path.insert(0,str(source_root/'tools/firmware_lab/scripts'))
   from index_arm_elf import Snapshot
   from disassemble_plan import render_plan
   snapshot=Snapshot.read(references[name]);require(snapshot.digest==expected_source,'reference hash')
   for path,content in render_plan(snapshot,plan).items():require(content.encode()==(dest/path).read_bytes(),'reference regeneration '+path)
  total+=len(plan['ranges'])
 baseline=json.loads((directory/'source-baseline.json').read_text())
 for entry in baseline['unchanged_prefixes']:
  b=(source_root/entry['path']).read_bytes();require(digest(b[:entry['bytes']])==entry['sha256'],'unchanged source prefix')
 return {'static_windows':total,'artifacts':total*2,'witness_bytes':sum(r['witness_bytes'] for r in proof['sources'].values()),'reference_regenerated':sorted((references or {}).keys())}
def main():
 p=argparse.ArgumentParser();p.add_argument('--cgminer',type=pathlib.Path);p.add_argument('--hwscan',type=pathlib.Path);a=p.parse_args();refs={k:v for k,v in vars(a).items() if v is not None}
 print(json.dumps(verify(references=refs),sort_keys=True))
if __name__=='__main__':main()

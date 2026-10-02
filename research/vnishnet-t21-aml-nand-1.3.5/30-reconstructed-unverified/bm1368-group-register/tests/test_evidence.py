#!/usr/bin/env python3
"""Bounded parser, static-field, and source-span tamper controls; no C/original execution."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile

HERE=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('group_evidence',HERE/'verify_evidence.py')
v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
ROOT=HERE.parents[3]
WITNESS=json.loads((HERE/'static-witness.json').read_text())
PINS=json.loads((HERE/'static-pins.json').read_text())
passed=[]

def reject(name, callback):
    try:callback()
    except (v.EvidenceError,ValueError):passed.append(name)
    else:raise RuntimeError('tamper accepted: '+name)

def changed_reader(name,address,word):
    source=copy.deepcopy(WITNESS['sources'][name])
    for region in source['regions']:
        if region['va']<=address and address+4<=region['va']+region['size']:
            raw=bytearray.fromhex(region['bytes_hex']);off=address-region['va']
            raw[off:off+4]=word.to_bytes(4,'little');region['bytes_hex']=raw.hex()
            region['sha256']=hashlib.sha256(raw).hexdigest();break
    else:raise RuntimeError('mutation address missing')
    expected=[{k:item for k,item in r.items() if k!='bytes_hex'} for r in source['regions']]
    return source,v.Ranges(source['regions'],expected)

def main():
    v.verify(root=ROOT);passed.append('default-packet')
    with tempfile.TemporaryDirectory(prefix='l14-static-') as directory:
        temp=Path(directory);wp=temp/'witness.json';pp=temp/'pins.json'
        def witness_case(name, mutate):
            candidate=copy.deepcopy(WITNESS);mutate(candidate)
            wp.write_text(json.dumps(candidate));reject(name,lambda:v.verify(wp,HERE/'static-pins.json',ROOT))
        witness_case('raw-range-byte',lambda w:w['sources']['cgminer']['regions'][0].__setitem__('bytes_hex','00'+w['sources']['cgminer']['regions'][0]['bytes_hex'][2:]))
        witness_case('false-source-attribution',lambda w:w['proof'].__setitem__('grouping_source_path_proved',True))
        witness_case('false-hwscan-caller',lambda w:w['proof'].__setitem__('hwscan_grouping_caller_proved',True))
        witness_case('missing-method-call',lambda w:w['sources']['cgminer']['methods']['chip']['calls'].pop())
        witness_case('normalized-original-spelling',lambda w:w['wrapper_strings'][-1].__setitem__('text','Failed to read cached drive strength register'))
        witness_case('boolean-schema',lambda w:w.__setitem__('schema',True))
        wp.write_text('{"schema":1,"schema":1}');reject('duplicate-json-key',lambda:v.load_json(wp))
        wp.write_text('{"value":NaN}');reject('non-finite-json',lambda:v.load_json(wp))
        pins=copy.deepcopy(PINS);pins['metadata_sha256']='0'*64;pp.write_text(json.dumps(pins))
        reject('rewritten-pins',lambda:v.verify(HERE/'static-witness.json',pp,ROOT))
        # Coherent local byte/hash mutations reach semantic field checks directly.
        source,reader=changed_reader('cgminer',0xe3794,0xeb000000)
        reject('coherent-wrong-call-target',lambda:v.verify_methods('cgminer',source,reader))
        source,reader=changed_reader('cgminer',0xe39dc,0)
        reject('coherent-wrong-literal',lambda:v.verify_methods('cgminer',source,reader))
        _,reader=changed_reader('cgminer',0xb59c0,0xe58d000c)
        reject('coherent-wrong-descriptor-slot',lambda:v.verify_grouping(WITNESS,reader))
        _,reader=changed_reader('cgminer',0x56394,0xe5902194)
        reject('coherent-wrong-common-method-slot',lambda:v.verify_common_caller(WITNESS,reader,ROOT))
        # Only copy the explicitly bounded current source dependencies.
        checkout=temp/'checkout'
        for row in WITNESS['runtime']+WITNESS['dependencies']+WITNESS['contracts']:
            dest=checkout/row['path'];dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(ROOT/row['path'],dest)
        v.verify(root=checkout)
        chip=checkout/WITNESS['runtime'][0]['path'];raw=chip.read_bytes()
        chip.write_bytes(raw+b'\n/* later source is outside this historical witness */\n')
        v.verify(root=checkout);passed.append('historical-prefix-permits-later-suffix')
        chip.write_bytes(raw)
        for number,row in enumerate(WITNESS['runtime']):
            path=checkout/row['path'];original=path.read_bytes();changed=bytearray(original)
            changed[11280 if number==0 else 0]^=1;path.write_bytes(changed)
            reject('runtime-span-'+str(number),lambda:v.verify(root=checkout));path.write_bytes(original)
        chip.write_bytes(raw[:11280]);reject('stale-short-source',lambda:v.verify(root=checkout));chip.write_bytes(raw)
        for key in ('dependencies','contracts'):
            path=checkout/WITNESS[key][0]['path'];original=path.read_bytes();path.write_bytes(original+b'\n')
            reject('changed-'+key,lambda:v.verify(root=checkout));path.write_bytes(original)
        wrong=temp/'truncated.elf';wrong.write_bytes(b'\x7fELF')
        reject('truncated-original-data',lambda:v.verify(root=checkout,originals={'cgminer':wrong}))
    print(json.dumps({'static_control_categories':len(passed),'passed':passed,'original_executed':False}))

if __name__=='__main__':main()

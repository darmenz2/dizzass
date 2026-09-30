#!/usr/bin/env python3
"""Validate static byte/call witnesses; this is not an instruction interpreter."""
import argparse
import hashlib
import json
import pathlib
import re
import struct
import sys

HERE = pathlib.Path(__file__).resolve().parent
SOURCE = '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'


def main():
    if not __debug__:
        raise RuntimeError("verification requires assertions; do not use python -O")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--reference',type=pathlib.Path)
    parser.add_argument('--lab-scripts',type=pathlib.Path,default=HERE.parents[3]/'tools/firmware_lab/scripts')
    args = parser.parse_args()
    evidence = HERE/'evidence'
    plan_raw = (evidence/'plan.json').read_bytes()
    plan = json.loads(plan_raw)
    manifest = json.loads((evidence/'manifest.json').read_text())
    graph = json.loads((HERE/'callgraph.json').read_text())
    assert plan['source_sha256'] == graph['source_sha256'] == SOURCE
    assert manifest['plan_sha256'] == hashlib.sha256(plan_raw).hexdigest()
    assert not manifest['firmware_executed'] and not graph['firmware_executed']
    assert len(plan['ranges']) == 42 and len(graph['direct_edges']) == 42
    assert len(manifest['artifact_sha256']) == 84
    for name,digest in manifest['artifact_sha256'].items():
        assert pathlib.PurePosixPath(name).name == name
        assert hashlib.sha256((evidence/name).read_bytes()).hexdigest() == digest
    mapped = {}
    size = 0
    for entry in plan['ranges']:
        receipt = json.loads((evidence/(entry['name']+'.json')).read_text())
        start,end = int(entry['start'],0),int(entry['end_exclusive'],0)
        raw = bytearray();cursor=start
        for line in (evidence/(entry['name']+'.asm')).read_text().splitlines():
            match = re.fullmatch(r'([0-9a-f]{8})\s+([0-9a-f]+)\s+.*',line)
            assert match and int(match[1],16) == cursor
            value = bytes.fromhex(match[2]);raw.extend(value);cursor+=len(value)
        assert cursor == end and receipt['bytes'] == len(raw)
        assert receipt['source_sha256'] == SOURCE and not receipt['firmware_executed']
        assert hashlib.sha256(raw).hexdigest() == entry['sha256'] == receipt['sha256']
        for offset,value in enumerate(raw):
            assert start+offset not in mapped or mapped[start+offset] == value
            mapped[start+offset] = value
        size += len(raw)
    assert size == 7540

    def word(at):
        return int.from_bytes(bytes(mapped[at+i] for i in range(4)),'little')

    # Arithmetic target decoding and byte comparisons only, never a register VM.
    for edge in graph['direct_edges']:
        at,target = int(edge['at'],0),int(edge['target'],0)
        value = word(at)
        assert value == int(edge['instruction_word'],0) and (value>>25)&7 == 5
        assert bool(value & (1<<24)) == (edge['kind']=='BL')
        displacement = value&0xffffff
        if displacement&0x800000:displacement-=1<<24
        assert (at+8+4*displacement)&0xffffffff == target
    # Root callback handoff, AML jump-table case and exact GOT identities.
    assert (0x256c8+8+word(0x25958))&0xffffffff == 0x22424
    assert word(0x1c738) == 0xe12fff30  # BLX r0
    assert word(0xff7a8) == 0x4bc and 0xff7a0+word(0xff7a8) == 0xffc5c
    assert word(0x4afdf0) == 0x10dce8
    assert word(0x4afb08) == 0x10cfe0
    assert word(0x4af860) == 0x10e2ec
    assert word(0x4afb94) == 0x4b0a70
    assert word(0x1003b0) == 0xe12fff31  # BLX r1
    assert word(0x1003c8) == word(0x100444) == 0xe12fff30
    assert [word(0x482188+4*i) for i in range(6)] == [439,440,441,454,455,456]
    # The candidate code is not run: these are fixed instruction-word witnesses.
    assert word(0x45a370) == 0xe3a07027 and word(0x45a374) == 0xef000000
    assert word(0x463704) == 0xe3a07021 and word(0x463708) == 0xef000000
    assert word(0x45aa30) == 0xe3a07005 and word(0x45aa48) == 0xef000000
    assert word(0xe660c) == 0xe3e00000  # early worker return -1
    assert word(0xe67a8) == 0xe3a00000  # shared cleanup return 0
    assert word(0xff5fc) == 0xe3500005  # unknown selector ID guard
    provenance = json.loads((evidence/'string-provenance.json').read_text())
    assert provenance['source_sha256'] == SOURCE and len(provenance['strings']) == 32
    for entry in provenance['strings']:
        raw = bytes.fromhex(entry['bytes_hex'])
        assert raw == entry['value'].encode('ascii')+b'\0'
        assert hashlib.sha256(raw).hexdigest() == entry['sha256']
    reference_checked = False
    if args.reference:
        sys.path.insert(0,str(args.lab_scripts))
        from index_arm_elf import Snapshot
        from disassemble_plan import render_plan
        source = Snapshot.read(args.reference)
        assert source.digest == SOURCE
        rendered = render_plan(source,plan)
        for name,text in rendered.items():assert (evidence/name).read_text() == text
        for entry in provenance['strings']:
            raw = bytes.fromhex(entry['bytes_hex'])
            actual,offset,_ = source.bytes_at(int(entry['address'],0),len(raw))
            assert actual == raw and offset == entry['file_offset']
        reference_checked = True
    print(json.dumps(dict(schema=1,ranges=42,bytes=size,direct_edges=42,
        indirect_target_witnesses=4,strings=32,reference_checked=reference_checked,
        firmware_executed=False,proof='static byte/hash/target checks only'),sort_keys=True))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Static ELF-derived data checks only; never execute or emulate a target."""
import argparse
import hashlib
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[3]
SOURCES = {'hwscan': '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077',
           'cgminer': 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'}


def need(ok, message):
    if not ok: raise ValueError(message)


def mapped_source(name):
    folder = HERE / 'evidence' / name
    raw = (folder / 'plan.json').read_bytes()
    plan = json.loads(raw)
    manifest = json.loads((folder / 'manifest.json').read_text())
    need(plan['source_sha256'] == manifest['source_sha256'] == SOURCES[name], 'source identity')
    need(manifest['firmware_executed'] is False, 'execution flag')
    need(hashlib.sha256(raw).hexdigest() == manifest['plan_sha256'], 'plan hash')
    expected = {r['name'] + suffix for r in plan['ranges'] for suffix in ('.asm', '.json')}
    need(set(manifest['artifact_sha256']) == expected, 'artifact inventory')
    need(len(expected) == 2 * len(plan['ranges']), 'duplicate ranges')
    for path, digest in manifest['artifact_sha256'].items():
        need(pathlib.PurePosixPath(path).name == path, 'unsafe artifact name')
        need(hashlib.sha256((folder / path).read_bytes()).hexdigest() == digest, 'artifact hash')
    data = {}
    size = 0
    for entry in plan['ranges']:
        receipt = json.loads((folder / (entry['name'] + '.json')).read_text())
        start, end = int(entry['start'], 0), int(entry['end_exclusive'], 0)
        value = bytearray(); cursor = start
        for line in (folder / (entry['name'] + '.asm')).read_text().splitlines():
            match = re.fullmatch(r'([0-9a-f]{8})\s+([0-9a-f]{8})\s+.*', line)
            need(match is not None and int(match[1], 16) == cursor, 'word/address format')
            value.extend(bytes.fromhex(match[2])); cursor += 4
        need(cursor == end and len(value) == receipt['bytes'], 'range length')
        need(receipt['source_sha256'] == SOURCES[name] and receipt['firmware_executed'] is False, 'receipt identity')
        need(int(receipt['start'], 0) == start and int(receipt['end_exclusive'], 0) == end, 'receipt range')
        need(receipt['mode'] == entry['mode'], 'receipt mode')
        need(hashlib.sha256(value).hexdigest() == entry['sha256'] == receipt['sha256'], 'raw bytes hash')
        for i, byte in enumerate(value):
            at = start + i
            need(at not in data or data[at] == byte, 'overlap disagreement')
            data[at] = byte
        size += len(value)
    return data, plan, size


def verify_semantics(maps, provenance):
    def raw(name, at, size):
        return bytes(maps[name][at + i] for i in range(size))
    def word(name, at):
        return int.from_bytes(raw(name, at, 4), 'little')
    def words(name, at, values):
        need([word(name, at + 4*i) for i in range(len(values))] == values, 'instruction words')
    def relative(name, at, literal, result):
        need((at + 8 + word(name, literal)) & 0xffffffff == result, 'PC relative target')
    def branch(name, at, target):
        value = word(name, at)
        need(value >> 24 == 0xeb, 'unconditional A32 BL')
        displacement = value & 0xffffff
        if displacement & 0x800000: displacement -= 1 << 24
        need((at + 8 + 4 * displacement) & 0xffffffff == target, 'branch target')
    words('hwscan', 0x10e220, [0xe3500002,0x859f0018,0x808f0000,0x812fff1e,
                               0xe59f1008,0xe08f1001,0xe7910100,0xe12fff1e])
    words('cgminer', 0x11c0c0, [0xe3500002,0x859f0020,0x808f0000,0x812fff1e,
                                0xe59f1010,0xe08f1001,0xe7910100,0xe12fff1e])
    relative('hwscan',0x10e228,0x10e244,0x48e00e)
    relative('hwscan',0x10e234,0x10e240,0x4acf1c)
    relative('cgminer',0x11c0c8,0x11c0ec,0x5c2547)
    relative('cgminer',0x11c0d4,0x11c0e8,0x5db408)
    need(raw('hwscan',0x48e00e,1) == raw('cgminer',0x5c2547,1) == b'\0', 'empty result bytes')
    for name, table, pointers in [('hwscan',0x4acf1c,[0x4821c9,0x4821d4,0x4821df]),
                                   ('cgminer',0x5db408,[0x5ee810,0x5ee81b,0x5ee826])]:
        need([word(name,table+4*i) for i in range(3)] == pointers, 'three-entry table')
        records = provenance['strings'][name]
        need(len(records) == 3, 'three strings')
        for index, item in enumerate(records):
            need(item['index'] == index and int(item['address'],0) == pointers[index], 'string address/index')
            source_bytes = raw(name,pointers[index],11)
            need(source_bytes.hex() == item['source_bytes_hex'], 'string source bytes')
            need(hashlib.sha256(source_bytes).hexdigest() == item['source_sha256'], 'string hash')
            # A fixed data transformation of 11 bytes, NOT instruction execution.
            key = [0x40,0x99,0x5f][index] if name == 'cgminer' else 0
            need(item['xor_key'] == key, 'string XOR key')
            result = bytes(x ^ key for x in source_bytes)
            expected = ('/dev/ttyS' + str(3-index)).encode() + b'\0'
            need(result == expected and item['decoded_bytes_hex'] == result.hex(), 'decoded pathname')
            need(item['pathname'].encode() + b'\0' == expected, 'pathname text')
    # Fixed opaque parity prefix and fixed constructor decode witnesses.
    words('cgminer',0x11c098,[0xe5912000,0xe2423001,0xe0020392,0xe3120001,0x0a000004])
    for at, value in {0x11c4cc:0xe2200040,0x11c4d8:0xe352000b,
                      0x11c520:0xe2200099,0x11c4f0:0xe350000b,
                      0x11c574:0xe222205f,0x11c580:0xe350000b}.items():
        need(word('cgminer',at) == value,'constructor XOR/length witness')
    relative('cgminer',0x11c4c4,0x11c5b4,0x5ee810)
    relative('cgminer',0x11c4e8,0x11c5b8,0x5ee81b)
    relative('cgminer',0x11c56c,0x11c5bc,0x5ee826)
    need(word('cgminer',0x5db060) == 0x11c2b8,'constructor array entry')
    # Selected callback assignment and generic dispatch seam, not full init proof.
    relative('hwscan',0xffd20,0x100734,0x4c80a0)
    relative('hwscan',0xffd4c,0x100748,0x4af640)
    need(word('hwscan',0x4af640) == 0x10e220 and word('hwscan',0xffd50) == 0xe5867000,'hwscan callback assignment')
    relative('cgminer',0xfc12c,0xfd128,0x654b4c)
    relative('cgminer',0xfc158,0xfd13c,0x5dec90)
    need(word('cgminer',0x5dec90) == 0x11c080 and word('cgminer',0xfc15c) == 0xe5845000,'cgminer callback assignment')
    words('hwscan',0x100d9c,[0xe59f1004,0xe79f1001,0xe12fff11])
    words('cgminer',0xfef3c,[0xe59f1004,0xe79f1001,0xe12fff11])
    relative('hwscan',0x100da0,0x100da8,0x4c80a0)
    relative('cgminer',0xfef40,0xfef48,0x654b4c)
    branch('hwscan',0xe94a0,0x100d9c);branch('hwscan',0xe94bc,0x100d3c)
    branch('cgminer',0xc34c8,0xfef3c);branch('cgminer',0xc34e0,0xfee4c)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--hwscan-reference',type=pathlib.Path)
    parser.add_argument('--cgminer-reference',type=pathlib.Path)
    args = parser.parse_args()
    provenance = json.loads((HERE/'evidence/string-provenance.json').read_text())
    need(provenance['firmware_executed'] is False and provenance['arm_interpreter_used'] is False,'provenance execution flags')
    maps, plans, result = {}, {}, {}
    for name in SOURCES:
        data, plan, size = mapped_source(name)
        need(provenance['sources'][name]['sha256'] == SOURCES[name],'provenance source')
        need(provenance['sources'][name]['ranges'] == len(plan['ranges']) and provenance['sources'][name]['witness_bytes'] == size,'provenance counts')
        maps[name],plans[name] = data,plan
        result[name] = dict(ranges=len(plan['ranges']),bytes=size,reference_checked=False)
    verify_semantics(maps,provenance)
    for name,path in [('hwscan',args.hwscan_reference),('cgminer',args.cgminer_reference)]:
        if path is None: continue
        sys.path.insert(0,str(ROOT/'tools/firmware_lab/scripts'))
        from index_arm_elf import Snapshot
        from disassemble_plan import render_plan
        snapshot = Snapshot.read(path)
        need(snapshot.digest == SOURCES[name],'private reference hash')
        for file,contents in render_plan(snapshot,plans[name]).items():
            need((HERE/'evidence'/name/file).read_text() == contents,'exact reference regeneration')
        result[name]['reference_checked'] = True
    baseline = json.loads((HERE/'source-baseline.json').read_text())
    for path,digest in baseline['unchanged_inputs'].items():
        need(hashlib.sha256((ROOT/path).read_bytes()).hexdigest() == digest,'current tracked input: '+path)
    platform = (ROOT/'libbitmain/src/aml/platform.c').read_text()
    reset_region = platform[platform.index('static void note'):platform.index('\n/* cgminer')].strip().encode()
    need(hashlib.sha256(reset_region).hexdigest() == baseline['unchanged_reset_region_sha256'],'unchanged reset region')
    print(json.dumps(dict(sources=result,firmware_executed=False,arm_interpreter_used=False,
        proof='static bytes, arithmetic and fixed data XOR only'),sort_keys=True))


if __name__ == '__main__':
    main()

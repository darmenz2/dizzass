#!/usr/bin/env python3
"""Check bounded static evidence as data. No instruction emulation or firmware calls."""
import argparse
import hashlib
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).resolve().parent
SOURCE = '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'


def require(condition, message):
    if not condition:
        raise ValueError(message)


def load(root):
    evidence = root / 'evidence'
    plan_bytes = (evidence / 'plan.json').read_bytes()
    return (json.loads(plan_bytes), json.loads((evidence / 'manifest.json').read_text()),
            json.loads((root / 'claims.json').read_text()), plan_bytes)


def verify_static(root, plan, manifest, claims, plan_bytes):
    require(plan['schema'] == manifest['schema'] == claims['schema'] == 1, 'schema')
    require(plan['source_sha256'] == manifest['source_sha256'] == claims['source_sha256'] == SOURCE, 'source identity')
    require(manifest['firmware_executed'] is False and claims['firmware_executed'] is False, 'execution flag')
    require(hashlib.sha256(plan_bytes).hexdigest() == manifest['plan_sha256'], 'plan hash')
    require(json.loads(plan_bytes) == plan, 'parsed plan identity')
    evidence = root / 'evidence'
    names = [item['name'] for item in plan['ranges']]
    require(len(names) == len(set(names)) and all(re.fullmatch(r'[a-z0-9][a-z0-9_-]{0,79}', n) for n in names), 'range names')
    expected_artifacts = {n + suffix for n in names for suffix in ('.asm', '.json')}
    require(set(manifest['artifact_sha256']) == expected_artifacts, 'artifact set')
    for name, digest in manifest['artifact_sha256'].items():
        require(hashlib.sha256((evidence / name).read_bytes()).hexdigest() == digest, 'artifact hash: ' + name)
    mapped = {}
    total = 0
    for entry in plan['ranges']:
        receipt = json.loads((evidence / (entry['name'] + '.json')).read_text())
        start, end = int(entry['start'], 0), int(entry['end_exclusive'], 0)
        require(start % 4 == 0 and 0 < end - start <= 65536, 'bounded range')
        require(entry['mode'] in ('arm', 'data'), 'explicit mode')
        raw = bytearray()
        cursor = start
        for line in (evidence / (entry['name'] + '.asm')).read_text().splitlines():
            match = re.fullmatch(r'([0-9a-f]{8})\s+([0-9a-f]{8})\s+.*', line)
            require(match is not None and int(match[1], 16) == cursor, 'assembly address/word')
            raw.extend(bytes.fromhex(match[2])); cursor += 4
        require(cursor == end and len(raw) == receipt['bytes'], 'range length')
        require(receipt['source_sha256'] == SOURCE and receipt['firmware_executed'] is False, 'receipt identity')
        require(int(receipt['start'], 0) == start and int(receipt['end_exclusive'], 0) == end and receipt['mode'] == entry['mode'], 'receipt boundaries')
        require(hashlib.sha256(raw).hexdigest() == entry['sha256'] == receipt['sha256'], 'range hash')
        for offset, value in enumerate(raw):
            address = start + offset
            require(address not in mapped or mapped[address] == value, 'overlap disagreement')
            mapped[address] = value
        total += len(raw)

    def word(address):
        address = int(address, 0) if isinstance(address, str) else address
        try:
            return int.from_bytes(bytes(mapped[address + i] for i in range(4)), 'little')
        except KeyError as exc:
            raise ValueError('witness outside mapped bytes') from exc

    for edge in claims['direct_edges']:
        at, target = int(edge['at'], 0), int(edge['target'], 0)
        value = word(at)
        require(value == int(edge['instruction_word'], 0) and (value >> 25) & 7 == 5, 'direct branch opcode')
        require(edge['kind'] in ('B', 'BL') and bool(value & (1 << 24)) == (edge['kind'] == 'BL'), 'branch link bit')
        require(value >> 28 == edge['condition'], 'branch condition')
        displacement = value & 0xffffff
        if displacement & 0x800000:
            displacement -= 1 << 24
        require((at + 8 + 4 * displacement) & 0xffffffff == target, 'branch target')
    for witness in claims['words']:
        require(word(witness['at']) == int(witness['word'], 0), 'word witness')
    for witness in claims['pc_relative']:
        require((int(witness['at'], 0) + 8 + word(witness['literal'])) & 0xffffffff == int(witness['result'], 0), 'PC-relative target')
    for witness in claims['pointer_cells']:
        require(word(witness['at']) == int(witness['target'], 0), 'pointer target')
    witness = claims['startup_main_got_offset']
    require(int(witness['got_base'], 0) + word(witness['literal']) == int(witness['slot'], 0), 'main GOT offset')
    script = claims['shell_source']
    require(script['path'] == '../../10-extracted/rootfs/etc/init.d/S12hwscan', 'shell source scope')
    require(hashlib.sha256((root / script['path']).read_bytes()).hexdigest() == script['sha256'], 'shell source hash')
    # Critical interpretation anchors are pinned independently of labels in claims.json.
    anchors = {0x25664: 0xe3a06000, 0x256d4: 0xe59f0280, 0x2571c: 0xe1a00006,
               0x258ec: 0xe3a06065, 0xe660c: 0xe3e00000, 0xe67a8: 0xe3a00000,
               0x158a0: 0xe58d0004, 0x158b0: 0xe59d0004,
               0x4640a4: 0xe3a070f8, 0x4640a8: 0xef000000, 0x4640ac: 0xe3a07001}
    for address, value in anchors.items():
        require(word(address) == value, 'critical anchor')
    return dict(schema=1, source_sha256=SOURCE, ranges=len(names), bytes=total,
                direct_edges=len(claims['direct_edges']), word_witnesses=len(claims['words']),
                pc_relative_targets=len(claims['pc_relative']), pointer_cells=len(claims['pointer_cells']),
                shell_source_checked=True, firmware_executed=False,
                arm_interpreter_used=False, proof='static consistency and arithmetic only')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--reference', type=pathlib.Path)
    parser.add_argument('--lab-scripts', type=pathlib.Path, default=HERE.parents[3] / 'tools/firmware_lab/scripts')
    args = parser.parse_args()
    plan, manifest, claims, raw = load(HERE)
    result = verify_static(HERE, plan, manifest, claims, raw)
    result['reference_checked'] = False
    if args.reference is not None:
        sys.path.insert(0, str(args.lab_scripts))
        from index_arm_elf import Snapshot
        from disassemble_plan import render_plan
        snapshot = Snapshot.read(args.reference)
        require(snapshot.digest == SOURCE, 'private reference identity')
        for name, contents in render_plan(snapshot, plan).items():
            require((HERE / 'evidence' / name).read_text() == contents, 'reference regeneration: ' + name)
        result['reference_checked'] = True
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()

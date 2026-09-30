#!/usr/bin/env python3
"""Render a digest-pinned, bounded static ARM/Thumb/data slice plan. Never execute it."""
import argparse
import hashlib
import json
import pathlib
import re
import resource
import struct

import capstone
from index_arm_elf import Snapshot, hx, new_output


def render_plan(snapshot, plan):
    if plan.get('schema') != 1 or plan.get('source_sha256') != snapshot.digest:
        raise ValueError('plan/source identity mismatch')
    ranges = plan.get('ranges', [])
    if not isinstance(ranges, list) or not 1 <= len(ranges) <= 64:
        raise ValueError('plan must contain 1..64 ranges')
    artifacts = {}
    total = 0
    names = set()
    for entry in ranges:
        name = entry['name']
        if not re.fullmatch(r'[a-z0-9][a-z0-9_-]{0,79}', name) or name in names:
            raise ValueError('unsafe or duplicate range name')
        names.add(name)
        start, end = int(entry['start'], 0), int(entry['end_exclusive'], 0)
        size = end-start
        total += size
        if not 0 < size <= 64*1024 or total > 1024**2:
            raise ValueError('slice byte budget exceeded')
        mode = entry['mode']
        if mode not in ('arm', 'thumb', 'data'):
            raise ValueError('explicit arm/thumb/data mode required')
        if start % (4 if mode in ('arm','data') else 2):
            raise ValueError('slice start is not mode-aligned')
        if not entry.get('mode_evidence') or not entry.get('boundary_evidence'):
            raise ValueError('mode and boundary evidence descriptions required')
        raw, offset, flags = snapshot.bytes_at(start, size, executable=mode != 'data')
        digest = hashlib.sha256(raw).hexdigest()
        if entry.get('sha256') != digest:
            raise ValueError('slice digest mismatch')
        lines = []
        if mode == 'data':
            if size % 4:
                raise ValueError('data word slice must be word-sized')
            for i, (word,) in enumerate(struct.iter_unpack('<I', raw)):
                lines.append(f'{start+i*4:08x}  {raw[i*4:i*4+4].hex():<10}  .word      {hx(word)}')
        else:
            decoder = capstone.Cs(capstone.CS_ARCH_ARM, capstone.CS_MODE_ARM if mode == 'arm' else capstone.CS_MODE_THUMB)
            decoder.skipdata = True
            used = 0
            for instruction in decoder.disasm(raw, start):
                lines.append(f'{instruction.address:08x}  {instruction.bytes.hex():<10}  {instruction.mnemonic:<10} {instruction.op_str}')
                used += instruction.size
            if used != size:
                raise ValueError('decoder did not account for every byte')
        receipt = dict(schema=1, source_sha256=snapshot.digest, name=name,
            start=hx(start), end_exclusive=hx(end), bytes=size, file_offset=offset,
            segment_flags=flags, sha256=digest, mode=mode,
            mode_evidence=entry['mode_evidence'], boundary_evidence=entry['boundary_evidence'],
            evidence_sources=entry.get('evidence_sources', []),
            disassembler='capstone' if mode != 'data' else 'little-endian word rendering',
            disassembler_version=capstone.__version__ if mode != 'data' else '1',
            firmware_executed=False,
            caveat='Linear static rendering; literal pools may remain in instruction windows. No complete CFG, runtime path, function extent or parity is proved.')
        artifacts[name+'.asm'] = '\n'.join(lines)+'\n'
        artifacts[name+'.json'] = json.dumps(receipt, indent=2, sort_keys=True)+'\n'
    return artifacts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('elf', type=pathlib.Path)
    parser.add_argument('--plan', type=pathlib.Path, required=True)
    parser.add_argument('--out', type=pathlib.Path, required=True)
    args = parser.parse_args()
    resource.setrlimit(resource.RLIMIT_CPU, (30,30))
    resource.setrlimit(resource.RLIMIT_AS, (1024**3,1024**3))
    with args.plan.open('rb') as source:
        plan_raw = source.read(1024**2+1)
    if len(plan_raw) > 1024**2:
        raise ValueError('plan byte budget exceeded')
    artifacts = render_plan(Snapshot.read(args.elf), json.loads(plan_raw))
    new_output(args.out)
    for name, contents in artifacts.items():
        (args.out/name).write_text(contents)
    receipt = dict(schema=1, plan_sha256=hashlib.sha256(plan_raw).hexdigest(),
        artifact_sha256={name:hashlib.sha256(text.encode()).hexdigest() for name,text in sorted(artifacts.items())},
        firmware_executed=False)
    (args.out/'manifest.json').write_text(json.dumps(receipt, indent=2, sort_keys=True)+'\n')
    print(json.dumps(receipt, sort_keys=True))


if __name__ == '__main__':
    main()

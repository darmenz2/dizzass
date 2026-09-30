#!/usr/bin/env python3
"""Recheck published evidence against a read-only hwscan ELF. Never execute it."""
import argparse
import hashlib
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('elf',type=pathlib.Path)
    parser.add_argument('--lab-scripts',type=pathlib.Path,
                        default=HERE.parents[3]/'tools/firmware_lab/scripts')
    args = parser.parse_args()
    sys.path.insert(0,str(args.lab_scripts))
    from index_arm_elf import Snapshot
    from disassemble_plan import render_plan

    evidence = HERE/'evidence'
    source = Snapshot.read(args.elf)
    plan = json.loads((evidence/'plan.json').read_text())
    artifacts = render_plan(source,plan)
    for name,contents in artifacts.items():
        if (evidence/name).read_text() != contents:
            raise ValueError('regenerated evidence differs: '+name)
    provenance = json.loads((evidence/'string-provenance.json').read_text())
    if provenance['source_sha256'] != source.digest:
        raise ValueError('string/source identity mismatch')
    for item in provenance['strings']:
        expected = bytes.fromhex(item['bytes_hex'])
        raw,offset,_ = source.bytes_at(int(item['address'],16),len(expected))
        if (raw != expected or offset != item['file_offset'] or
                hashlib.sha256(raw).hexdigest() != item['sha256']):
            raise ValueError('string provenance differs: '+item['value'])
    print(json.dumps(dict(source_sha256=source.digest,regenerated_files=len(artifacts),
        ranges=len(plan['ranges']),strings=len(provenance['strings']),
        bytes=sum(int(r['end_exclusive'],0)-int(r['start'],0) for r in plan['ranges']),
        firmware_executed=False,comparison='static bytes and rendering only'),sort_keys=True))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Read-only boundary evidence, NOT a tuner extractor, loader or full call graph.

Linear A32 decoding in source-path-associated EHABI buckets can encounter data.
Candidate sites are explicitly not a reachable call graph or a module closure.
Only the bounded windows exercised by the separate tests have trace evidence.
"""
from __future__ import annotations
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import struct
import sys
from elf32 import ELF32

ROOT = Path(__file__).resolve().parents[1]
REFERENCE = 'reference/cgminer.vendor.elf'
ELF_SHA = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
BASE = '12446bed78a060a49364a80bcbfb4340b13f4f27'
MODULES = tuple('evidence/modules/src/backend/tuner/' + n + '.c.json'
                for n in ('tuner_base', 'tuner_hw_sweep', 'tuner_nonce'))
EVIDENCE = 'integration/evidence/autotune_boundary_135.json'
MASK = 0xffffffff
# Short reviewed instruction windows, not asserted whole-function ownership.
WINDOWS = (
    ('backend_reset_prefix', 0x94c5c, 0x94cec),
    ('backend_reset_alternative', 0x94d78, 0x94d84),
    ('frequency_fall_call', 0x86c1c, 0x86c34),
    ('voltage_worker_restart', 0x93aa4, 0x93ac0),
    ('profile_config_write', 0x95498, 0x954b4),
    ('sweep_method_pair', 0x9c31c, 0x9c350),
    ('nonce_method_dispatch', 0x9fd74, 0x9fd94),
)
DEPENDENCIES = (
    ('frequency_fall', 0x86c30, 0x65b3c, 'integration/frequency_fall_135.h'),
    ('voltage_stop', 0x93aac, 0xa6080, 'integration/voltage_stop_135.h'),
    ('voltage_start', 0x93ab4, 0xa20a0, 'integration/evidence/voltage_stop_135.json'),
    ('profile_write', 0x954b0, 0x509b4, 'integration/MONITOR_HANDLERS_135_RU.md'),
    ('reset_alternative', 0x94d80, 0x6100c, 'integration/MONITOR_HANDLERS_135_RU.md'),
    ('reset_default', 0x94ce8, 0x61170, 'integration/MONITOR_HANDLERS_135_RU.md'),
)
SUPPORT = ('tools/elf32.py', 'tools/arm32_subset.py', 'tools/arm32_vfp_subset.py',
           'tools/arm32_freshness_subset.py', 'tools/arm32_rx_subset.py',
           'tools/arm32_nonce_subset.py', 'tools/arm32_verify_subset.py',
           'cgminer.c', 'Makefile.am', 'AGENTS.md')


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def hx(value: int) -> str:
    return f'0x{value:08x}'


def decode_call(word: int, pc: int) -> dict | None:
    """Decode A32 BL/BLX-immediate/BLX-register; do not infer reachability."""
    cond = word >> 28
    if cond == 15:
        if word & 0xfe000000 != 0xfa000000:
            return None
        delta = word & 0xffffff
        if delta & 0x800000:
            delta -= 1 << 24
        return {'kind': 'BLX_imm', 'target': (pc + 8 + (delta << 2) +
                 ((word >> 23) & 2)) & MASK, 'target_state': 'thumb', 'condition': cond}
    if word & 0x0f000000 == 0x0b000000:
        delta = word & 0xffffff
        if delta & 0x800000:
            delta -= 1 << 24
        return {'kind': 'BL', 'target': (pc + 8 + (delta << 2)) & MASK,
                'target_state': 'arm', 'condition': cond}
    if word & 0x0ffffff0 == 0x012fff30:
        return {'kind': 'BLX_reg', 'register': word & 15, 'condition': cond}
    return None


def checked_elf(root: Path) -> ELF32:
    path = root / REFERENCE
    if digest(path.read_bytes()) != ELF_SHA:
        raise ValueError('Reference SHA-256 mismatch; refusing a different image')
    elf = ELF32(path)
    if elf.machine != 40:
        raise ValueError('Not ARM')
    return elf


def unwind_buckets(elf: ELF32) -> set[tuple[int, int]]:
    sec = elf.sections['.ARM.exidx']
    data = elf.section('.ARM.exidx')
    if len(data) % 8:
        raise ValueError('Invalid exidx length')
    starts = []
    for offset in range(0, len(data), 8):
        word = struct.unpack_from('<I', data, offset)[0] & 0x7fffffff
        if word & 0x40000000:
            word -= 1 << 31
        starts.append((sec['addr'] + offset + word) & MASK)
    if starts != sorted(set(starts)):
        raise ValueError('Unordered/duplicate exidx starts')
    return set(zip(starts, starts[1:]))


def module_buckets(root: Path, elf: ELF32) -> tuple[list, list]:
    known = unwind_buckets(elf)
    modules, ranges = [], []
    text = elf.sections['.text']
    for filename in MODULES:
        raw = (root / filename).read_bytes()
        doc = json.loads(raw)
        literals = []
        for item in doc['evidence']:
            address = int(item['address'], 16)
            data = elf.read(address, item['decoded_length'])
            decoded = bytes(b ^ item['xor'] for b in data).rstrip(b'\0').decode('ascii')
            if decoded != doc['observed_as']:
                raise ValueError('Source-path bytes disagree: ' + filename)
            literals.append({'address': hx(address), 'xor': item['xor'],
                             'bytes_sha256': digest(data), 'decoded': decoded})
        for item in doc['candidate_intervals']:
            start, end = int(item['start'], 16), int(item['end_exclusive'], 16)
            if (start, end) not in known or start % 4 or end % 4 or not (
                    text['addr'] <= start < end <= text['addr'] + text['size']):
                raise ValueError('Invalid candidate bucket: ' + filename)
            ranges.append({'start': start, 'end': end, 'module': doc['path'],
                           'sha256': digest(elf.read(start, end - start))})
        modules.append({'metadata': filename, 'metadata_sha256': digest(raw),
                        'path': doc['path'], 'literals': literals,
                        'candidate_buckets': len(doc['candidate_intervals'])})
    ranges.sort(key=lambda r: r['start'])
    if any(a['end'] > b['start'] for a, b in zip(ranges, ranges[1:])):
        raise ValueError('Overlapping candidate buckets')
    return modules, ranges


def scan(elf: ELF32, ranges: list) -> dict:
    sites, external, indirect, rejected = [], [], [], []
    text = elf.sections['.text']
    for region in ranges:
        for pc in range(region['start'], region['end'], 4):
            word = int.from_bytes(elf.read(pc, 4), 'little')
            hit = decode_call(word, pc)
            if hit is None:
                continue
            row = {'pc': hx(pc), 'word': hx(word), **hit}
            sites.append(row)
            if hit['kind'] == 'BLX_reg':
                indirect.append(row)
            elif not text['addr'] <= hit['target'] < text['addr'] + text['size']:
                rejected.append(row)
            elif not any(r['start'] <= hit['target'] < r['end'] for r in ranges):
                external.append(row)
    counts = Counter(x['target'] for x in external)
    return {
        'method': 'Linear aligned A32 opcode candidates; NOT CFG/data separation',
        'raw_candidates': len(sites),
        'raw_candidates_sha256': digest(json.dumps(sites, sort_keys=True).encode()),
        'direct_outside_buckets_inside_text_sites': len(external),
        'direct_outside_buckets_inside_text_targets': len(counts),
        'target_histogram': {hx(k): v for k, v in sorted(counts.items())},
        'indirect_candidates': indirect,
        'rejected_direct_targets_outside_text': rejected,
        'full_module_ownership': False, 'full_dependency_closure': False,
        'limits': ['A bucket can include several functions and literal pools.',
                   'Outside a path bucket does not mean outside the tuner.',
                   'Only BL/BLX are inventoried; tail B, LDR/MOV pc and tables are not resolved.',
                   'In-range instruction-shaped data may survive filtering.',
                   'An indirect candidate does not identify its possible callees.',
                   'Full function/firmware reachability and all global/TLS data are not established.'],
    }


def build_report(root: Path = ROOT) -> dict:
    elf = checked_elf(root)
    modules, ranges = module_buckets(root, elf)
    programs = [struct.unpack_from('<8I', elf.data, elf.phoff + i * elf.phentsize)
                for i in range(elf.phnum)]
    sources = set(SUPPORT + MODULES + tuple(d[3] for d in DEPENDENCIES))
    dependencies = []
    for name, pc, target, evidence in DEPENDENCIES:
        word = int.from_bytes(elf.read(pc, 4), 'little')
        decoded = decode_call(word, pc)
        if decoded is None or decoded.get('target') != target:
            raise ValueError('Wrong dependency witness: ' + name)
        dependencies.append({'name': name, 'call_site': hx(pc), 'target': hx(target),
                             'word': hx(word), 'existing_reference': evidence,
                             'scope': 'reached block/prefix only, not a complete tuner execution'})
    literal = bytes(x ^ 107 for x in elf.read(0x5e74e8, 17)).rstrip(b'\0')
    if literal != b'autotune-profile':
        raise ValueError('Profile key literal changed')
    return {
        'schema': 1, 'base_commit': BASE, 'reference': REFERENCE,
        'reference_sha256': ELF_SHA,
        'purpose': 'Embedded tuner reuse feasibility evidence; no binary extraction/loader',
        'elf': {'length': len(elf.data), 'type': struct.unpack_from('<H', elf.data, 16)[0],
                'machine': elf.machine, 'flags': hx(struct.unpack_from('<I', elf.data, 36)[0]),
                'entry': hx(elf.entry), 'has_pt_interp': any(p[0] == 3 for p in programs),
                'has_pt_dynamic': any(p[0] == 2 for p in programs),
                'has_pt_tls': any(p[0] == 7 for p in programs),
                'has_dynsym': any(s['type'] == 11 for s in elf.sections.values()),
                'has_relocation_sections': any(s['type'] in (4, 9) for s in elf.sections.values()),
                'init_array_entries': elf.sections['.init_array']['size'] // 4,
                'note': 'Whole-image metadata; does not imply all TLS/constructors belong to the tuner.'},
        'modules': modules,
        'buckets': [{**r, 'start': hx(r['start']), 'end': hx(r['end'])} for r in ranges],
        'candidate_bucket_bytes': sum(r['end'] - r['start'] for r in ranges),
        'scan': scan(elf, ranges),
        'reviewed_windows': [{'name': n, 'start': hx(a), 'end': hx(b),
                             'sha256': digest(elf.read(a, b-a))} for n, a, b in WINDOWS],
        'direct_witnesses': dependencies,
        'profile_literal': {'address': '0x005e74e8', 'length': 17, 'xor': 107,
                            'decoded': literal.decode(), 'sha256': digest(elf.read(0x5e74e8, 17))},
        'unchanged_dependencies': {p: digest((root / p).read_bytes()) for p in sorted(sources)},
        'decision': {'drop_in_component_proven': False, 'isolation_impossible_proven': False,
                     'hardware_execution': False, 'binary_relinked': False,
                     'full_firmware_archive_inventoried': False,
                     'next_gate': 'Resolve entries, state and transitive callees before choosing extraction over source porting.'},
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Compare with committed report; never rewrite it')
    args = parser.parse_args()
    try:
        report = build_report()
        if args.check:
            expected = json.loads((ROOT / EVIDENCE).read_text())
            if report != expected:
                raise ValueError('Generated report differs from committed evidence')
            print('AUTOTUNE_BOUNDARY_AUDIT_PASS: pinned data and candidate census only; not runtime acceptance')
        else:
            print(json.dumps(report, ensure_ascii=False, indent=2))
    except (ValueError, OSError, KeyError, struct.error) as exc:
        print(f'AUTOTUNE_BOUNDARY_AUDIT_FAIL: {exc}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())

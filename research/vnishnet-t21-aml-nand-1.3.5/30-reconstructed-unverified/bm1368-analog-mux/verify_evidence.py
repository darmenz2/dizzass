#!/usr/bin/env python3
"""Verify the reviewed bounded ANALOG_MUX_CTRL packet as static data.

The packet canonical digest and method/binding region pins below are independent
of the packet's own digests. No reference instruction is executed, emulated or
interpreted. This checks fixed source bytes and approved annotations; it is not
an automatic proof of C equivalence, hardware behavior or runtime reachability.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PACKET_SHA256 = 'db1575c1e3bcd590d0000cc4267bce42b9a0259741b194397ef04102ee39516c'
MAX_ARTIFACT_BYTES = 200000
SOURCE_PINS = {
    'cgminer': (6228004, 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'),
    'hwscan': (4883216, '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'),
}
# Core bounds are deliberately different: hwscan has no cgminer opaque blocks.
REGION_PINS = {
    'cgminer': {
        'code': (0xe35c0, 0xe36fc, '66b80d0c510d52d24e75c203cddd4039dd2404827a9143b3ec416e197d0814c7'),
        'literals': (0xe36fc, 0xe3728, '7b589d52da228d2b6afd416a5ec79264f078e8ad4c7e587f1f165fb485474362'),
        'constructor_code': (0xe1548, 0xe1564, '0050ab8d69c2a2470e987b59c87637f3d875d22cbd04edb1dbdafa2b8871bf13'),
        'constructor_literal': (0xe1714, 0xe1718, 'e7e4d8bb33021212a2b744f4cacaff0a126ee8f75b3b5ef1216be3bf9385c9db'),
        'constructor_got': (0x5dfe04, 0x5dfe08, '472eb90f526cc1ad771e08de0cb0f27df31de0fd96fe98bf3d7ee27911a67f81'),
    },
    'hwscan': {
        'code': (0xf3354, 0xf33dc, '73089e7c276c3807b8b0c1852113c621dd32a6a46b43772f0726a32ca21442a6'),
        'literals': (0xf33dc, 0xf33ec, '6ca72d86e1b3e0e58906bd877defa83a95d9c0ac9fe0c992e398eeda426a0eec'),
        'constructor_code': (0xf1e20, 0xf1e3c, '0050ab8d69c2a2470e987b59c87637f3d875d22cbd04edb1dbdafa2b8871bf13'),
        'constructor_literal': (0xf1fec, 0xf1ff0, '30dd2961fadb9f24eedb62faa728ba0138f7d4514948894d949e8b80459c309a'),
        'constructor_got': (0x4afbd8, 0x4afbdc, '621502832a10641c6063341026c888fda0456433a7b3e01f6dfa7a1490f38777'),
    },
}


class EvidenceError(ValueError):
    pass


def require(condition, message):
    # Keep all acceptance checks enabled in Python -O.
    if not condition:
        raise EvidenceError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def canonical(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'),
                      allow_nan=False).encode('ascii')


def unique_pairs(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, 'duplicate JSON key: ' + key)
        result[key] = value
    return result


def reject_constant(value):
    raise EvidenceError('nonfinite JSON constant: ' + value)


def read_bounded(path, maximum):
    with Path(path).open('rb') as stream:
        data = stream.read(maximum + 1)
    require(len(data) <= maximum, 'file exceeds bounded size: ' + str(path))
    return data


def load_json(path):
    try:
        return json.loads(read_bounded(path, MAX_ARTIFACT_BYTES),
                          object_pairs_hook=unique_pairs,
                          parse_constant=reject_constant)
    except (UnicodeError, json.JSONDecodeError, RecursionError) as exc:
        raise EvidenceError('invalid bounded JSON: ' + str(exc)) from exc


def normalized_assembly(path):
    data = read_bounded(path, MAX_ARTIFACT_BYTES).replace(b'\r\n', b'\n')
    require(b'\r' not in data, 'lone CR in assembly annotation')
    return data


def verify_packet(evidence):
    evidence = Path(evidence)
    packet = load_json(evidence / 'static-witness.json')
    try:
        require(digest(canonical(packet)) == PACKET_SHA256,
                'static witness differs from independent approved pin')
    except (ValueError, TypeError) as exc:
        if isinstance(exc, EvidenceError):
            raise
        raise EvidenceError('invalid canonical witness: ' + str(exc)) from exc
    for name, source in packet['sources'].items():
        require((source['size'], source['sha256']) == SOURCE_PINS[name],
                'packet source pin mismatch: ' + name)
        regions = {r['name']: r for r in source['regions']}
        for label, pin in REGION_PINS[name].items():
            r = regions[label]
            require((r['start'], r['end'], r['sha256']) == pin,
                    'independent region pin mismatch: ' + label)
        for r in source['regions']:
            data = bytes.fromhex(r['bytes_hex'])
            require(len(data) == r['end'] - r['start'], 'region length mismatch')
            require(digest(data) == r['sha256'], 'region bytes hash mismatch')
            if 'assembly_file' in r:
                annotation = normalized_assembly(evidence / r['assembly_file'])
                require(digest(annotation) == r['assembly_sha256'],
                        'assembly annotation mismatch: ' + r['assembly_file'])
                # Match a contiguous byte listing, without decoding instructions.
                rows = annotation.decode('ascii').splitlines()
                require(len(rows) * 4 == len(data), 'assembly coverage mismatch')
                for index, line in enumerate(rows):
                    columns = line.split(maxsplit=2)
                    require(len(columns) == 3, 'assembly row malformed')
                    require(int(columns[0], 16) == r['start'] + index * 4,
                            'assembly address mismatch')
                    require(bytes.fromhex(columns[1]) == data[index*4:index*4+4],
                            'assembly bytes mismatch')
        for s in source['strings']:
            raw = bytes.fromhex(s['bytes_hex'])
            require(len(raw) == s['length'], 'string length mismatch')
            require(digest(raw) == s['sha256'], 'string hash mismatch')
            require(bytes(b ^ s['xor_key'] for b in raw) ==
                    s['decoded'].encode('ascii') + b'\0',
                    'decoded string mismatch')
    return packet


def verify_source(path, name, packet):
    size, expected = SOURCE_PINS[name]
    data = read_bounded(path, size)
    require(len(data) == size, name + ' reference byte length mismatch')
    require(digest(data) == expected, name + ' reference SHA256 mismatch')
    sys.path.insert(0, str(ROOT / 'tools'))
    from elf32 import ELF32
    elf = ELF32(path)
    require(elf.data == data, 'reference changed while reading')
    require(elf.machine == 40, 'reference is not ARM')
    source = packet['sources'][name]
    for r in source['regions']:
        require(elf.read(r['start'], r['end'] - r['start']) ==
                bytes.fromhex(r['bytes_hex']), 'original region differs: ' + r['name'])
    for s in source['strings']:
        require(elf.read(s['address'], s['length']) == bytes.fromhex(s['bytes_hex']),
                'original string differs: ' + s['name'])
    if name == 'cgminer':
        bss = elf.sections['.bss']
        approved = packet['opaque_predicates']['bss']
        require((bss['addr'], bss['size'], bss['type']) ==
                (approved['address'], approved['size'], approved['type']),
                'opaque globals section mismatch')
    return len(source['regions'])


def verify(cgminer, evidence=HERE / 'evidence', hwscan=None):
    packet = verify_packet(evidence)
    regions = {'cgminer': verify_source(cgminer, 'cgminer', packet)}
    if hwscan is not None:
        regions['hwscan'] = verify_source(hwscan, 'hwscan', packet)
    return dict(verified=True, checked_original_regions=regions,
                code_bytes={'cgminer':316, 'hwscan':136},
                hwscan_original_checked=hwscan is not None,
                original_executed=False, instruction_interpreter_used=False,
                runtime_reachability_established=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cgminer', type=Path, default=ROOT / 'reference/cgminer.vendor.elf')
    parser.add_argument('--hwscan', type=Path)
    parser.add_argument('--evidence', type=Path, default=HERE / 'evidence')
    args = parser.parse_args()
    try:
        result = verify(args.cgminer, args.evidence, args.hwscan)
    except (EvidenceError, OSError, ValueError, KeyError) as exc:
        print('evidence verification failed: ' + str(exc), file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    sys.exit(main())

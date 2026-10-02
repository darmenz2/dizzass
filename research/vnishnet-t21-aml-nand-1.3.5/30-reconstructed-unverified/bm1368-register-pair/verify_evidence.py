#!/usr/bin/env python3
"""Verify the reviewed bounded register-pair packet as static data.

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
PACKET_SHA256 = 'cabcc929e16fbef5f1d0b7d5cde04e45cfff8dd65d68abd3a46b553a619e0b87'
MAX_ARTIFACT_BYTES = 200000
SOURCE_PINS = {
    'cgminer': (6228004, 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'),
    'hwscan': (4883216, '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'),
}
# Core bounds are deliberately different: hwscan has no cgminer opaque blocks.
REGION_PINS = {
    'cgminer': {
        'code': (0xe3c04, 0xe3dd0, '763ee4325290cac5d9913b3e8907b979b09894b2f9bbbd3c21ce5764b80412f1'),
        'literals': (0xe3dd0, 0xe3dd8, 'dcf52df5a5f460b20a63a0040fb7d26454ba9f2b53b5b6a0e6eaa67f3fbf991c'),
        'constructor_code': (0xe1520, 0xe156c, '5c025d20ff51251df31eaf91dd333aa4f03555da395edb1f4b3443420b5ead8e'),
        'constructor_literal': (0xe1700, 0xe1704, 'c850968a1030074a868c1ac678133ffde2851c7dfc9e5f7c2788f3095c7647a5'),
        'constructor_got': (0x5de630, 0x5de634, '7da7d813a7b15ad509ed945dd0e5bf3494102dd4ae84848ecffeac1af08a3b44'),
        'opaque_x_got': (0x5dfc2c, 0x5dfc30, '9a37d8f4068310cc4efe243d855fb4381615d2360279d957a556b9afe6480bb0'),
        'opaque_y_got': (0x5defd8, 0x5defdc, 'aaba8d1c10bda99fe3fb16ee55bcf1f9f273419e4801b3303b527b0bfef7ff68'),
    },
    'hwscan': {
        'code': (0xf3618, 0xf36f0, 'c32a75976b6e3f17ed1a24138469c512a857d46524c38708cbb9aec1f08a5b93'),
        'constructor_code': (0xf1df8, 0xf1e44, '5c025d20ff51251df31eaf91dd333aa4f03555da395edb1f4b3443420b5ead8e'),
        'constructor_literal': (0xf1fd8, 0xf1fdc, 'aca6cb76954a6885142f73112652db016b25cfc0e2e685d077f5fa77a995dca6'),
        'constructor_got': (0x4af9cc, 0x4af9d0, '34739460ddf66a0fd4ba1e5d3edb47d43bb0604ff986d1104e415bf44bc1b40a'),
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


def bounded_integer(value):
    require(len(value.lstrip('-')) <= 20, 'JSON integer exceeds bounded digits')
    return int(value)


def reject_float(value):
    raise EvidenceError('nonintegral JSON number: ' + value)


def reject_constant(value):
    raise EvidenceError('nonfinite JSON constant: ' + value)


def read_bounded(path, maximum):
    with Path(path).open('rb') as stream:
        data = stream.read(maximum + 1)
    require(len(data) <= maximum, 'file exceeds bounded size: ' + str(path))
    return data


def load_json(path):
    try:
        return json.loads(read_bounded(path, MAX_ARTIFACT_BYTES).decode('utf-8'),
                          object_pairs_hook=unique_pairs,
                          parse_constant=reject_constant,
                          parse_int=bounded_integer, parse_float=reject_float)
    except (UnicodeError, json.JSONDecodeError, RecursionError, ValueError) as exc:
        if isinstance(exc, EvidenceError):
            raise
        raise EvidenceError('invalid bounded JSON: ' + str(exc)) from exc


def normalized_assembly(path):
    data = read_bounded(path, MAX_ARTIFACT_BYTES).replace(b'\r\n', b'\n')
    require(b'\r' not in data, 'lone CR in assembly annotation')
    return data


def verify_packet(evidence):
    evidence = Path(evidence)
    packet = load_json(evidence / 'static-witness.json')
    require(type(packet) is dict, 'static witness must be an object')
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
        require(set(regions) == set(REGION_PINS[name]), 'exact region set mismatch')
        for label, pin in REGION_PINS[name].items():
            r = regions[label]
            require((r['start'], r['end'], r['sha256']) == pin,
                    'independent region pin mismatch: ' + label)
        for r in source['regions']:
            data = bytes.fromhex(r['bytes_hex'])
            require(len(data) == r['end'] - r['start'], 'region length mismatch')
            require(digest(data) == r['sha256'], 'region bytes hash mismatch')
            if 'assembly_file' in r:
                require(Path(r['assembly_file']).name == r['assembly_file'],
                        'assembly filename must remain inside bounded evidence')
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
                code_bytes={'cgminer':460, 'hwscan':216},
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

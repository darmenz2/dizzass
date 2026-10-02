#!/usr/bin/env python3
"""Verify the reviewed bounded per-chip drive-strength packet as static data.

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
PACKET_SHA256 = '2290f935c6eb7fbc70b3c8a7cb0ff83f809ae77f596e05211e5e833d3dcbdcdb'
MAX_ARTIFACT_BYTES = 200000
SOURCE_PINS = {
    'cgminer': (6228004, 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'),
    'hwscan': (4883216, '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'),
}
# Core bounds are deliberately different: hwscan has no cgminer opaque blocks.
REGION_PINS = {
    'cgminer': {
        'code': (0xe3728, 0xe39dc, 'ab79cf5615e41cef3bc606d43ce2c968eac107d2cd9fcd6d3f7a91d36641e7c0'),
        'literals': (0xe39dc, 0xe3a1c, '39fc48af7ddeb65eb8d2865894d3582c1c207bbe4814c6a914e8a29eef081e9b'),
        'constructor_code': (0xe1540, 0xe1564, '178feae33d727b32a1ca8dd2a52d1b73e8eeeff7d1d0abf299ee984a79523c2e'),
        'constructor_literal': (0xe1710, 0xe1714, 'd029a48aac2dcd4f5733c19eb54fe6ee15c5e02d746d9183fbb9e19c848fcadd'),
        'driver_xor_code': (0xe5370, 0xe53f8, '06bf703e2bfe3d9e8f8f96a9b6c88f8b9e5faf82b7e955ae542d0d4f01e7ef7a'),
        'driver_xor_literal': (0xe6060, 0xe6064, '69d1950d65221d7381c3a9d12d73ba49ecff982ce5d51853be44902cf04b4b6f'),
        'path_xor_code': (0xe5448, 0xe54bc, 'e79738811bd3a56adef820d4d5bd4d8f5084fd295dfd12085dc59912b5f17583'),
        'path_xor_literal': (0xe606c, 0xe6070, 'cb2a8eb06e68c5b606f3871347666003a94a3d1da34f2b7d0f01bba6b5033ff8'),
        'function_xor_code': (0xe54fc, 0xe5570, '0be71eb97350975dd1dde6d09659c1dcf2097e64f0febd2fb441999f7054bc00'),
        'function_xor_literal': (0xe6070, 0xe6074, 'ef7807d205e2d19863b2a4d86bf980a66fb3904756716af483cba6bff581dbd6'),
        'read_format_xor_code': (0xe57c8, 0xe584c, '71301ce3987f1ddab8583e0d768f4b3d3f19fdd4a0dd8d7bf11d975bea6d089d'),
        'read_format_xor_literal': (0xe608c, 0xe6090, 'bdfec57318a29dc729d5f3f0f9887120132d1add6f4f264a98528692efc45b99'),
        'write_format_xor_code': (0xe584c, 0xe58d0, '93e878dafc566edd695fce4e950d82af17272b97c95e51d6b915d04d70c6cc14'),
        'write_format_xor_literal': (0xe6090, 0xe6094, 'cfa7a7397116e079846495e2e586dd9024c1943872bf72450fdbdf8933ba32c2'),
        'opaque_x_got': (0x5dfa28, 0x5dfa2c, '5f6bdc55e7f916e7c1e3f44379f04758b2a9403912431ce9efc793a0eb89addc'),
        'opaque_y_got': (0x5dfe1c, 0x5dfe20, 'acc699391539de02e78d25e0f35288ce6583a05007137810cc90bdbfce9511b7'),
        'constructor_got': (0x5df41c, 0x5df420, '3af261e8362649ff598538ce74ecd0d7e61674438dfaacedbcdf9070c4cd95ec'),
        'initializer_registration': (0x5dafe4, 0x5dafe8, 'bde77998d34438e46530ea4f32972bb50ccfc36504c8fad84a328d8b2e2da63a'),
    },
    'hwscan': {
        'code': (0xf33ec, 0xf34dc, '87406b9d1f21eb417d04ea324ec294966bc2d5d3a8d4f7678167024538fbb9b7'),
        'literals': (0xf34dc, 0xf34fc, 'ab08ee3c545629e6b4b6fed39c6261baf9e300cb0c7a8bfbdb9dc4844ad7a242'),
        'constructor_code': (0xf1e18, 0xf1e3c, '178feae33d727b32a1ca8dd2a52d1b73e8eeeff7d1d0abf299ee984a79523c2e'),
        'constructor_literal': (0xf1fe8, 0xf1fec, 'beb9508eddc73d7b12c4fdd941008e6a3a7914e7169d7deb31c3a01c410b8324'),
        'constructor_got': (0x4af984, 0x4af988, '9b3c6459bd7ad25acd1234022a3a8b763903aad7974c87206e8f1f73e869bc1b'),
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
                code_bytes={'cgminer':692, 'hwscan':240},
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

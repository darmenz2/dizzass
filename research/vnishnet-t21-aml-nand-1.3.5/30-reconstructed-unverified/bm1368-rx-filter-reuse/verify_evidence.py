#!/usr/bin/env python3
"""Verify bounded RX filter reuse evidence and authored file integrity as data.

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
PACKET_SHA256 = 'ee713ee762f76ac7c3b30703d5eaf9f2cb7e383bc37a51b44e7afbb9e186a1c4'
MAX_ARTIFACT_BYTES = 200000
SOURCE_PINS = {
    'cgminer': (6228004, 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'),
    'hwscan': (4883216, '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'),
}
# Audited data tables are separated from code; partial RX windows stay bounded.
REGION_PINS = {
    'cgminer': {
        'method_code': (0xe3bc4, 0xe3bfc, 'becdc62d16e26e6b43f80c53febbe9bfdf8652e698047571d37354d28a0ff269'),
        'method_literals': (0xe3bfc, 0xe3c04, '76c67a9436423dc04d495b6f63bfe873287411784bca07674034b4e236faf9c9'),
        'constructor_code': (0xe1528, 0xe1568, '1f3a9ca1b64da10875ca27f1494ea78a13c9b32db2ccd736f9c8ade9e631462d'),
        'constructor_literal': (0xe1704, 0xe1708, '127d34f8166543190fdaec40d57f2af1a8d6c9d3de301c91afb3c9525f5b1c9b'),
        'constructor_got': (0x5def0c, 0x5def10, '84fffead78e51ea264a21613510b36d68a9ca87e487689a320bee5b825a432ab'),
        'method_x_got': (0x5def80, 0x5def84, 'cbbd75874638365787218bf6723c68cc22ff9985c982812cb1a94c819e16cc4d'),
        'method_y_got': (0x5dfba0, 0x5dfba4, '8f2877ee53432d1cbbc70c3701dc066360e7bfc15a4982a7c162451cb8e02e5a'),
        'dispatch_prefix_code': (0xd2a84, 0xd2aa4, '8daba0717b5561d1b0486943e5da2c68b976ceaaa069676df70d3f79d7aa1f95'),
        'dispatch_jump_data': (0xd2aa4, 0xd2ab8, '12f52d6c08989c7f02206c273aabd8a0b535ba916b5db2ed3f9b557b21d9a3ca'),
        'dispatch_suffix_code': (0xd2ab8, 0xd2bf4, '7908c49f2351efaee6ce09b6130cdb7a161504ec691b63f2782e4082d8da5709'),
        'dispatch_literals': (0xd2bf4, 0xd2c0c, '6c6ac793028422aa8d7e6905c2bd33012bd52422f47920a9342a711808951bc0'),
        'dispatch_x_got': (0x5df8f0, 0x5df8f4, 'a66e098f7adcee8e4d21087e91c783163354d4c593aed47291ef519e20025a20'),
        'dispatch_y_got': (0x5dfcb8, 0x5dfcbc, 'a438f030428d9cc77628a6f8adc9712d100628c30a97f23dd546e29f0281418f'),
        'rx_special_code': (0xc4750, 0xc4844, '0a13e5f2b023dbcf2a9e81854cf18c3cf1009eb182dba866cbf16069d157f287'),
        'rx_normal_code': (0xc4878, 0xc4a88, 'b68dc6a242287ba42358b62b0890a54346da7ccf507caacde1cc30e25fe41b26'),
    },
    'hwscan': {
        'method_code': (0xf3610, 0xf3618, '4fe40444ba4fa963fbe4230783e64a772a93d31a1ee99e83adc54d696880082b'),
        'constructor_code': (0xf1e00, 0xf1e40, '1f3a9ca1b64da10875ca27f1494ea78a13c9b32db2ccd736f9c8ade9e631462d'),
        'constructor_literal': (0xf1fdc, 0xf1fe0, '6ba145d16974c7a2b8546b2ac34a090bcd45412216a9ca189d4a88cb3847985f'),
        'constructor_got': (0x4af708, 0x4af70c, '9936062472c253523868f1bd1e675fedd678e503fc905395c1e9fa219c22eca8'),
        'dispatch_prefix_code': (0xeaa24, 0xeaa44, 'ce3828611aa13f38a7eedbdfae1f7f6d16c0f6e00b1d5544c0f6196df2b198c3'),
        'dispatch_jump_data': (0xeaa44, 0xeaa58, '2f5b471f3c16b01a29981d6c136aa0f6950871fe0ab047d0f8c8d6a01dc6124f'),
        'dispatch_suffix_code': (0xeaa58, 0xeaa88, '048b19fa4705912d6d8e2dcba51a9177604b459fc12a1c089cc5196a9932a79d'),
    },
}


REUSE_PINS = {
    'source': ('src/backend/work-gen/work-gen.c', 6785, 'd3a848413ac670a62a9fc6818323516f59dfd9057fc605f0c3ef134b4eb3af75'),
    'header': ('include/xminer/recovery/work_rx.h', 3724, '37d50c90b74bad73623100d52a269ab2c22568061e7637d6682e42d66722a60b'),
}
RECEIPT_PIN = ('REUSE.json', 2472, '6d04b1a1bcf6708c974b869ea5b77b3bfb0c8a6a1b59db2b1fe7556d4ff4c79b')


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


def verify_reuse(path, key, packet):
    relative, size, expected = REUSE_PINS[key]
    annotation = packet['reuse'][key]
    require((annotation['relative_path'], annotation['canonical_lf_size'],
             annotation['canonical_lf_sha256']) == REUSE_PINS[key],
            'independent reuse pin mismatch: ' + key)
    # At most every LF could have a preceding CR. Bounded read before any normalization.
    raw = read_bounded(path, size * 2)
    data = raw.replace(b'\r\n', b'\n')
    require(b'\r' not in data, 'lone CR in reuse file: ' + key)
    require(len(data) == size, 'canonical LF reuse byte length mismatch: ' + key)
    require(digest(data) == expected, 'canonical LF reuse SHA256 mismatch: ' + key)
    return dict(relative_path=relative, canonical_lf_bytes=size,
                canonical_lf_sha256=expected, crlf_to_lf_only=True)


def verify_receipt(path, packet):
    relative, size, expected = RECEIPT_PIN
    annotation = packet['reuse']['receipt']
    require((annotation['relative_path'], annotation['canonical_json_size'],
             annotation['canonical_json_sha256']) == RECEIPT_PIN,
            'independent receipt pin mismatch')
    receipt = load_json(path)
    require(type(receipt) is dict, 'reuse receipt must be an object')
    data = canonical(receipt)
    require(len(data) == size and digest(data) == expected,
            'canonical reuse receipt differs from independent approved pin')
    return dict(relative_path=relative, canonical_json_bytes=size,
                canonical_json_sha256=expected)


def verify(cgminer, evidence=HERE / 'evidence', hwscan=None,
           reuse_source=None, reuse_header=None, reuse_receipt=None):
    packet = verify_packet(evidence)
    regions = {'cgminer': verify_source(cgminer, 'cgminer', packet)}
    if hwscan is not None:
        regions['hwscan'] = verify_source(hwscan, 'hwscan', packet)
    reused = {
        'source': verify_reuse(reuse_source or ROOT / REUSE_PINS['source'][0],
                              'source', packet),
        'header': verify_reuse(reuse_header or ROOT / REUSE_PINS['header'][0],
                              'header', packet),
    }
    receipt = verify_receipt(reuse_receipt or HERE / RECEIPT_PIN[0], packet)
    return dict(verified=True, checked_original_regions=regions,
                method_code_bytes={'cgminer':56, 'hwscan':8},
                checked_reuse_files=reused, checked_reuse_receipt=receipt,
                hwscan_original_checked=hwscan is not None,
                original_executed=False, instruction_interpreter_used=False,
                historical_instruction_oracle_run=False,
                new_algorithm_or_constant_added=False,
                runtime_reachability_established=False)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cgminer', type=Path, default=ROOT / 'reference/cgminer.vendor.elf')
    parser.add_argument('--hwscan', type=Path)
    parser.add_argument('--evidence', type=Path, default=HERE / 'evidence')
    parser.add_argument('--reuse-source', type=Path)
    parser.add_argument('--reuse-header', type=Path)
    parser.add_argument('--reuse-receipt', type=Path)
    args = parser.parse_args()
    try:
        result = verify(args.cgminer, args.evidence, args.hwscan,
                        args.reuse_source, args.reuse_header, args.reuse_receipt)
    except (EvidenceError, OSError, ValueError, KeyError) as exc:
        print('evidence verification failed: ' + str(exc), file=sys.stderr)
        return 1
    print(json.dumps(result, indent=2))
    return 0


if __name__ == '__main__':
    sys.exit(main())

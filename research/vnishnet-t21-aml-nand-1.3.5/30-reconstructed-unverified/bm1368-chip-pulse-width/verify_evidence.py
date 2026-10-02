#!/usr/bin/env python3
"""Check the pinned e33e0 static packet; never execute reference instructions.

The constants are independent of the artifact manifest. This checks fixed bytes,
reviewed operand annotations and selected ARM instruction fields, not automatic
C/original equivalence, runtime reachability or permissions on a mounted drive.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
RESEARCH = Path('research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified')
SOURCE_SIZE = 6228004
SOURCE_SHA256 = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
# Accepted Git blob bytes use LF. A Windows autocrlf checkout may contain CRLF;
# normalize only that line-ending pair before comparing the historical pin.
RESET_SIZE = 148316
RESET_SHA256 = '44f126a4e966fd1b22c99131b83bb532115da69349f66ad253852dd78d50e40f'
MAX_ARTIFACT_BYTES = 200000
CODE = bytes.fromhex(
    'f04d2de918b08de210d04de20060a0e13800a0e3830100e00140a0e10010a0e3'
    '3c30a0e31203c7e70420a0e1020980e30050a0e3020180e300008de50600a0e1'
    '930500eb000050e31f00000a84809fe50140a0e380509fe5833100e37c709fe5'
    '08808fe0180096e505508fe070109fe507708fe0010080e208008de501108fe0'
    '04108de50800a0e10510a0e10720a0e100408de5125b00eb180096e50720a0e1'
    '40109fe51a3200e3010080e208008de501108fe004108de50800a0e10510a0e1'
    '00408de5065b00eb0050e0e30500a0e118d04be2f08dbde8')
LITERALS = bytes.fromhex('987f5000977f5000b97f50004c84500022805000')
CONSTRUCTOR = bytes.fromhex(
    'a0e19fe50ee09fe79c319fe503309fe798619fe506609fe794519fe505509fe7'
    '90419fe504409fe78c119fe501109fe788219fe502209fe75c2080e5602080e2'
    '720082e8703080e574e080e5')
REGIONS = (
    ('code', 'code', 0xe33e0, 0xe34b8, CODE,
     '7908fca036569ac33374f67f09cf0172f18e918654f5b7d590da6fd717366430'),
    ('literals', 'data', 0xe34b8, 0xe34cc, LITERALS,
     '74d3c202e104ffb63c3a2f8cd8bec7fc436f5ad2f501f2103e7821c93a4db51d'),
    ('constructor', 'code', 0xe1578, 0xe15c4, CONSTRUCTOR,
     'dbd567a63812084d3cdeaafb848563e73875ef8bc0e1f353fd7e161834096efd'),
)
CODE_OPERANDS = '''push|{r4, r5, r6, r7, r8, sl, fp, lr}
add|fp, sp, #0x18
sub|sp, sp, #0x10
mov|r6, r0
mov|r0, #0x38
and|r0, r0, r3, lsl #3
mov|r4, r1
mov|r1, #0
mov|r3, #0x3c
bfi|r0, r2, #6, #2
mov|r2, r4
orr|r0, r0, #0x8000
mov|r5, #0
orr|r0, r0, #0x80000000
str|r0, [sp]
mov|r0, r6
bl|#0xe4a74
cmp|r0, #0
beq|#0xe34ac
ldr|r8, [pc, #0x84]
mov|r4, #1
ldr|r5, [pc, #0x80]
movw|r3, #0x183
ldr|r7, [pc, #0x7c]
add|r8, pc, r8
ldr|r0, [r6, #0x18]
add|r5, pc, r5
ldr|r1, [pc, #0x70]
add|r7, pc, r7
add|r0, r0, #1
str|r0, [sp, #8]
add|r1, pc, r1
str|r1, [sp, #4]
mov|r0, r8
mov|r1, r5
mov|r2, r7
str|r4, [sp]
bl|#0xfa0c4
ldr|r0, [r6, #0x18]
mov|r2, r7
ldr|r1, [pc, #0x40]
movw|r3, #0x21a
add|r0, r0, #1
str|r0, [sp, #8]
add|r1, pc, r1
str|r1, [sp, #4]
mov|r0, r8
mov|r1, r5
str|r4, [sp]
bl|#0xfa0c4
mvn|r5, #0
mov|r0, r5
sub|sp, fp, #0x18
pop|{r4, r5, r6, r7, r8, sl, fp, pc}'''
CONSTRUCTOR_OPERANDS = '''ldr|lr, [pc, #0x1a0]
ldr|lr, [pc, lr]
ldr|r3, [pc, #0x19c]
ldr|r3, [pc, r3]
ldr|r6, [pc, #0x198]
ldr|r6, [pc, r6]
ldr|r5, [pc, #0x194]
ldr|r5, [pc, r5]
ldr|r4, [pc, #0x190]
ldr|r4, [pc, r4]
ldr|r1, [pc, #0x18c]
ldr|r1, [pc, r1]
ldr|r2, [pc, #0x188]
ldr|r2, [pc, r2]
str|r2, [r0, #0x5c]
add|r2, r0, #0x60
stm|r2, {r1, r4, r5, r6}
str|r3, [r0, #0x70]
str|lr, [r0, #0x74]'''


class EvidenceError(ValueError):
    pass


def require(condition, message):
    # Explicit checks remain active in Python -O.
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


def load_json(path, maximum=MAX_ARTIFACT_BYTES):
    raw = read_bounded(path, maximum)
    try:
        return json.loads(raw, object_pairs_hook=unique_pairs,
                          parse_constant=reject_constant), raw
    except (UnicodeError, json.JSONDecodeError) as error:
        raise EvidenceError('invalid JSON: ' + str(path)) from error


class Reference:
    """A bounded static ELF load reader; no CPU state or executable mappings."""
    def __init__(self, path):
        self.data = read_bounded(path, SOURCE_SIZE)
        require(len(self.data) == SOURCE_SIZE, 'reference byte length mismatch')
        require(digest(self.data) == SOURCE_SHA256, 'reference SHA256 mismatch')
        require(self.data[:7] == b'\x7fELF\x01\x01\x01', 'expected little-endian ELF32')
        header = struct.unpack_from('<16sHHIIIIIHHHHHH', self.data)
        require(header[1] == 2 and header[2] == 40, 'expected ARM ET_EXEC')
        phoff, phsize, count = header[5], header[9], header[10]
        require(phsize == 32 and phoff + phsize * count <= len(self.data),
                'invalid program-header extent')
        self.segments = []
        for index in range(count):
            segment = struct.unpack_from('<8I', self.data, phoff + index * phsize)
            if segment[0] == 1:
                _, offset, address, _, filesz, memsz, flags, _ = segment
                require(offset + filesz <= len(self.data) and filesz <= memsz,
                        'invalid file-backed load range')
                self.segments.append((offset, address, filesz, flags))

    def read(self, address, size):
        require(type(address) is int and type(size) is int and size > 0,
                'invalid fixed reference range')
        matches = [(offset, va) for offset, va, filesz, _ in self.segments
                   if va <= address and address + size <= va + filesz]
        require(len(matches) == 1, 'range needs one unique file-backed PT_LOAD')
        offset, va = matches[0]
        start = offset + address - va
        return self.data[start:start + size]

    def word(self, address):
        require(address % 4 == 0, 'unaligned fixed word')
        return struct.unpack('<I', self.read(address, 4))[0]


def manifest():
    return {
        'schema': 1, 'kind': 'bm1368-chip-pulse-width-static',
        'source': {'size': SOURCE_SIZE, 'sha256': SOURCE_SHA256},
        'regions': [{'name': name, 'start': start, 'end': end, 'sha256': sha}
                    for name, _, start, end, _, sha in REGIONS],
        'original_executed': False, 'instruction_interpreter_used': False,
    }


def expected_listing(name, start, data):
    if name == 'literals':
        return ''.join(f'{start + i:08x}  {data[i:i+4].hex():<10}  '
                       f'.word      0x{int.from_bytes(data[i:i+4], "little"):08x}\n'
                       for i in range(0, len(data), 4))
    rows = (CODE_OPERANDS if name == 'code' else CONSTRUCTOR_OPERANDS).splitlines()
    require(len(rows) * 4 == len(data), 'internal listing coverage mismatch')
    return ''.join(f'{start + 4*i:08x}  {data[4*i:4*i+4].hex():<10}  '
                   f'{row.split("|", 1)[0]:<10} {row.split("|", 1)[1]}\n'
                   for i, row in enumerate(rows))


def verify_artifacts(reference, evidence):
    metadata, _ = load_json(evidence / 'manifest.json')
    require(canonical(metadata) == canonical(manifest()), 'manifest differs from independent constants')
    for name, kind, start, end, data, sha in REGIONS:
        require(len(data) == end - start and digest(data) == sha, 'internal region pin mismatch')
        require(reference.read(start, end - start) == data, 'reference region mismatch: ' + name)
        record, _ = load_json(evidence / (name + '.json'))
        expected = {'kind': kind, 'start': start, 'end': end,
                    'sha256': sha, 'bytes_hex': data.hex()}
        require(canonical(record) == canonical(expected), 'artifact JSON mismatch: ' + name)
        listing = read_bounded(evidence / (name + '.asm'), MAX_ARTIFACT_BYTES)
        # Only platform line-ending normalization; every annotation stays exact.
        require(listing.replace(b'\r\n', b'\n') == expected_listing(name, start, data).encode('ascii'),
                'artifact assembly mismatch: ' + name)


def branch_target(word, address):
    require(word & 0x0e000000 == 0x0a000000, 'expected fixed ARM immediate branch')
    displacement = word & 0xffffff
    if displacement & 0x800000:
        displacement -= 0x1000000
    return (address + 8 + displacement * 4) & 0xffffffff


def verify_instruction_facts(reference):
    fixed = {
        0xe33ec: 0xe1a06000,  # retain device r0 in r6
        0xe33f0: 0xe3a00038, 0xe33f4: 0xe0000183,  # mask clock<<3 with 0x38
        0xe33f8: 0xe1a04001, 0xe33fc: 0xe3a01000,  # retain chip; mode zero
        0xe3400: 0xe3a0303c, 0xe3404: 0xe7c70312,  # reg3c; pulse low2 at bit6
        0xe3408: 0xe1a02004, 0xe340c: 0xe3800902,
        0xe3410: 0xe3a05000, 0xe3414: 0xe3800102,  # zero result; base80008000
        0xe3418: 0xe58d0000, 0xe341c: 0xe1a00006,  # fifth arg word; device
        0xe3424: 0xe3500000, 0xe3428: 0x0a00001f,  # exact-zero success branch
        0xe3430: 0xe3a04001, 0xe3438: 0xe3003183,  # severity1; source line387
        0xe3444: 0xe5960018, 0xe3454: 0xe2800001, 0xe3458: 0xe58d0008,
        0xe3478: 0xe5960018, 0xe3484: 0xe300321a,  # fresh index; line538
        0xe3488: 0xe2800001, 0xe348c: 0xe58d0008,
        0xe34a8: 0xe3e05000, 0xe34ac: 0xe1a00005,  # failure-1 or saved zero
        0xe34b4: 0xe8bd8df0,  # return before literal pool
        0xe1578: 0xe59fe1a0, 0xe157c: 0xe79fe00e, 0xe15c0: 0xe580e074,
    }
    for address, word in fixed.items():
        require(reference.word(address) == word, 'instruction fact mismatch: ' + hex(address))
    for address, word, target in ((0xe3420, 0xeb000593, 0xe4a74),
                                  (0xe3474, 0xeb005b12, 0xfa0c4),
                                  (0xe34a4, 0xeb005b06, 0xfa0c4),
                                  (0xe3428, 0x0a00001f, 0xe34ac)):
        require(reference.word(address) == word and branch_target(word, address) == target,
                'fixed call/branch target mismatch')
    # Resolve the two constructor loads, then the +74 store; identities are data.
    literal = 0xe1578 + 8 + (reference.word(0xe1578) & 0xfff)
    require(literal == 0xe1720 and reference.word(literal) == 0x4fea60,
            'constructor literal mismatch')
    got = (0xe157c + 8 + reference.word(literal)) & 0xffffffff
    require(got == 0x5dffe4 and reference.word(got) == 0xe33e0,
            'constructor GOT identity mismatch')


def verify_strings(reference, root):
    path = root / RESEARCH / 'bm1368-reset/static-witness.json'
    witness, raw = load_json(path)
    pinned_text = raw.replace(b'\r\n', b'\n')
    require(len(pinned_text) == RESET_SIZE and digest(pinned_text) == RESET_SHA256,
            'accepted reset initializer witness changed')
    regions = {region['id']: region for region in witness['sources']['cgminer']['regions']}
    needed = ('module', 'source', 'function', 'clock', 'core')
    for suffix in needed:
        for prefix in ('initializer-', 'initializer-literal-'):
            region = regions[prefix + suffix]
            data = bytes.fromhex(region['bytes_hex'])
            require(len(data) == region['size'] and digest(data) == region['sha256'] and
                    reference.read(region['va'], len(data)) == data,
                    'accepted initializer range mismatch: ' + prefix + suffix)
    require(reference.word(0x5dafe4) == 0xe5370, 'string initializer registration mismatch')
    # The key/count/store/backedge premises of the two reused ordinary XOR loops.
    for pc, word in ((0xe5758, 0xe22000d8), (0xe575c, 0xe7c30002),
                     (0xe5764, 0xe352002a), (0xe5768, 0x1afffff9),
                     (0xe5f60, 0xe2200067), (0xe5f64, 0xe7c30002),
                     (0xe5f6c, 0xe3520027), (0xe5f70, 0x1afffff9)):
        require(reference.word(pc) == word, 'initializer key/count/store/backedge mismatch')
    strings = (
        (0xe342c, 0xe34b8, 0xe3440, 0x5eb3e0, 0x1e, b'driver\0'),
        (0xe3434, 0xe34bc, 0xe3448, 0x5eb3e7, 0xd8,
         b'/tmp/build/libbitmain/src/chip/chip1368.c\0'),
        (0xe343c, 0xe34c0, 0xe3450, 0x5eb411, 0xd1, b'[redacted]\0'),
        (0xe344c, 0xe34c4, 0xe345c, 0x5eb8b0, 0x67,
         b'chain#%d - failed to send core command\0'),
        (0xe3480, 0xe34c8, 0xe3490, 0x5eb4ba, 0xd8,
         b'chain#%d - failed to set CLOCK_DELAY_CTRL\0'),
    )
    for load, literal, add, address, key, plain in strings:
        require(load + 8 + (reference.word(load) & 0xfff) == literal,
                'string literal-load relation mismatch')
        require((add + 8 + reference.word(literal)) & 0xffffffff == address,
                'string PC-relative address mismatch')
        require(bytes(value ^ key for value in reference.read(address, len(plain))) == plain,
                'bounded decoded string mismatch')


def verify(reference_path=None, evidence_path=None, root=ROOT):
    root = Path(root)
    reference = Reference(reference_path or root / 'reference/cgminer.vendor.elf')
    evidence = Path(evidence_path) if evidence_path is not None else HERE / 'evidence'
    verify_artifacts(reference, evidence)
    verify_instruction_facts(reference)
    verify_strings(reference, root)
    return {'verified': True, 'source_sha256': SOURCE_SHA256,
            'code_bytes': len(CODE), 'literal_bytes': len(LITERALS),
            'constructor_bytes': len(CONSTRUCTOR), 'original_executed': False,
            'instruction_interpreter_used': False}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cgminer', type=Path)
    parser.add_argument('--evidence', type=Path)
    parser.add_argument('--root', type=Path, default=ROOT)
    args = parser.parse_args(argv)
    try:
        print(json.dumps(verify(args.cgminer, args.evidence, args.root), sort_keys=True))
    except (EvidenceError, OSError, KeyError, TypeError, struct.error) as error:
        print('static verification failed: ' + str(error), file=sys.stderr)
        return 2
    return 0


if __name__ == '__main__':
    sys.exit(main())

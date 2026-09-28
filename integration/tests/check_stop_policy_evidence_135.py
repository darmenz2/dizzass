#!/usr/bin/env python3
"""Check immutable original bytes, decoded literals and the published prefix."""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from elf32 import ELF32

def blob(data):
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

def main():
    e = json.loads((ROOT / 'integration/evidence/stop_policy_135.json').read_text())
    elf = ELF32(ROOT / e['reference'])
    assert hashlib.sha256(elf.data).hexdigest() == e['reference_sha256']
    for item in e['ranges']:
        a, b = int(item['start'], 16), int(item['end_exclusive'], 16)
        assert hashlib.sha256(elf.read(a, b-a)).hexdigest() == item['sha256'], item['name']
    for item in e['literals']:
        data = elf.read(int(item['address'], 16), item['length'])
        assert hashlib.sha256(data).hexdigest() == item['sha256']
        assert bytes(x ^ item['xor_key'] for x in data) == item['decoded'].encode() + b'\0'
    # 10110 calls three exit cleanup routines then the never-returning SVC loop.
    # We pin the target/words without issuing a host syscall or running the ELF.
    word = int.from_bytes(elf.read(0x10128, 4), 'little')
    imm = word & 0xffffff
    if imm & 0x800000:
        imm -= 0x1000000
    assert word >> 24 == 0xeb and 0x10128 + 8 + 4 * imm == 0x5a89d8
    assert elf.read(0x5a89e0, 20).hex() == 'f870a0e3000000ef0170a0e30300a0e1fbffffea'
    for path, wanted in e['unchanged_files'].items():
        assert blob((ROOT / path).read_bytes()) == wanted, path
    item = e['base_source']
    data = (ROOT / item['path']).read_bytes()
    assert blob(data[:item['length']]) == item['git_blob']
    assert data[item['length']:].startswith(b'\n/* Original stop/retry decision 5e92c and retry-count writer 5cea8. */')
    print('STOP_POLICY135_EVIDENCE_PASS original entries literals terminal edge published prefix and production core')

if __name__ == '__main__':
    main()

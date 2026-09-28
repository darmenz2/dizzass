#!/usr/bin/env python3
"""Verify native work packets with original ARM and independent CRC/permutation."""
from pathlib import Path
import binascii
import re
import sys
from tx88_oracle import Tx88Oracle

REQUIRED = {
    'copy_work_noffset', '_free_work', 'test_nonce', 'fulltest', 'sha256',
    'dizzass_jobs_prepare', 'dizzass_jobs_finish', 'dizzass_jobs_check',
    'dizzass_jobs_prepare_tx88', 'dizzass_native_work_tx88',
    'dizzass_tx88_encode_words', 'dizzass_work_route_select',
    '__wrap_socket', '__wrap_connect', '__wrap_libusb_init', '__wrap_strdup',
}

def symbols(text):
    names = set()
    for line in text.splitlines():
        if not line.strip():
            continue
        fields = line.split()
        if len(fields) != 3 or not re.fullmatch(r'[0-9a-fA-F]+',fields[0]):
            raise ValueError(f'Malformed symbol line: {line!r}')
        names.add(fields[2])
    missing = REQUIRED - names
    legacy = {name for name in names if name.startswith('vn135_')}
    if missing or legacy:
        raise ValueError(f'Wrong native boundary: {missing=}, {legacy=}')

def verify(log, symbol_path):
    lines = Path(log).read_text(encoding='utf-8').splitlines()
    rows = [line.split() for line in lines if line.startswith('ROUTE_TX88_NATIVE ')]
    counts = [line for line in lines if line.startswith('WORK_ROUTE_NATIVE_PASS ')]
    if len(rows) != 64 or len(counts) != 1 or not re.fullmatch(
        r'WORK_ROUTE_NATIVE_PASS vectors=64 slots=32 strdup_failures=4 checks=\d+', counts[0]):
        raise ValueError('Missing native cases or invalid counts')
    oracle = Tx88Oracle()
    for i,row in enumerate(rows):
        if len(row) != 4 or len(row[2]) != 160 or len(row[3]) != 176:
            raise ValueError(f'Malformed vector {i}')
        slot = int(row[1]); header,packet = map(bytes.fromhex,row[2:])
        if slot != (i & 31) or packet != oracle.frame(header,slot):
            raise ValueError(f'Original TX88 mismatch {i}')
        expected = bytes([0x55,0xaa,0x21,0x36,slot<<3,1])+bytes(4)+header[:76][::-1]
        expected += binascii.crc_hqx(expected[2:],0xffff).to_bytes(2,'big')
        if packet != expected:
            raise ValueError(f'Independent frame/CRC mismatch {i}')
    symbols(Path(symbol_path).read_text(encoding='utf-8'))
    print('WORK_ROUTE_NATIVE_ORACLE_PASS packets=64 native_work_and_registry=yes')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('usage: check_work_route_native.py LOG SYMBOLS')
    verify(*sys.argv[1:])

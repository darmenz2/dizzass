#!/usr/bin/env python3
"""Original ARM attribution and independent native SHA check; no hardware I/O."""
from pathlib import Path
import hashlib
import re
import sys
from bm1368_oracle import BM1368Oracle

def main(log_path, symbols_path):
    lines = Path(log_path).read_text().splitlines()
    vectors = [x.split() for x in lines if x.startswith('BM1368_NATIVE ')]
    hashes = [x.split() for x in lines if x.startswith('BM1368_HASH ')]
    summaries = [x for x in lines if x.startswith('BM1368_NATIVE_PASS ')]
    if len(vectors) != 96 or len(hashes) != 11 or len(summaries) != 1 or not re.fullmatch(
            r'BM1368_NATIVE_PASS vectors=96 streams=11 checks=\d+', summaries[0]):
        raise ValueError('Missing native cases')
    oracle = BM1368Oracle()
    for row in vectors:
        if len(row) != 7:
            raise ValueError('Wrong vector fields')
        count, variant = map(int, row[1:3])
        got = (int(row[4], 16), int(row[5]), int(row[6]))
        if got != oracle.rx_attribution(variant, bytes.fromhex(row[3]), count):
            raise ValueError('Original RX attribution differs from native decoder/module')
    expected_display = '000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f'
    for row in hashes:
        if len(row) != 3 or len(row[1]) != 160 or len(row[2]) != 64:
            raise ValueError('Wrong native hash fields')
        digest = hashlib.sha256(hashlib.sha256(bytes.fromhex(row[1])).digest()).digest()
        if digest.hex() != row[2] or digest[::-1].hex() != expected_display:
            raise ValueError('Native SHA256d differs from independent result')
    names = {line.split()[-1] for line in Path(symbols_path).read_text().splitlines() if line.split()}
    required = {'dizzass_bm1368_locate', 'dizzass_nonce_decode_payload',
        'dizzass_nonce_check_matched', 'copy_work_noffset', '_free_work',
        'test_nonce', 'sha256', 'fulltest', '__wrap_socket', '__wrap_connect', '__wrap_libusb_init'}
    allowed_recovery = {'vn135_work_rx_policy_init', 'vn135_work_rx_filtered_register',
        'vn135_work_rx_next', 'vn135_work_rx_job_slot', 'vn135_work_rx_stream_init',
        'vn135_work_rx_stream_feed'}
    unexpected = {n for n in names if n.startswith('vn135_')} - allowed_recovery
    if required - names or unexpected:
        raise ValueError(f'Native boundary mismatch: missing={required-names}, unexpected={unexpected}')
    print('BM1368_NATIVE_VERIFIED original_rx=96 independent_sha=11 native_core=yes')

if __name__ == '__main__':
    if len(sys.argv) != 3:
        raise SystemExit('usage: check_bm1368_native.py LOG SYMBOLS')
    main(*sys.argv[1:])

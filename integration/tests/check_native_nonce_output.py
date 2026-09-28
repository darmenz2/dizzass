#!/usr/bin/env python3
"""Independently verify native cgminer digests with hashlib, not recovery SHA."""
from __future__ import annotations
import argparse
import hashlib
import re
from pathlib import Path

def verify(path: Path) -> None:
    lines = path.read_text(encoding='utf-8').splitlines()
    vectors = [line.split() for line in lines if line.startswith('VECTOR ')]
    summaries = [line for line in lines if line.startswith('NATIVE_NONCE_PASS ')]
    if len(vectors) != 128 or len(summaries) != 1:
        raise ValueError('Missing vectors or unique PASS summary')
    for number, row in enumerate(vectors):
        if len(row) != 6 or len(row[1]) != 160 or len(row[2]) != 64 or len(row[3]) != 64:
            raise ValueError(f'Invalid vector {number}')
        header, digest, target = (bytes.fromhex(s) for s in row[1:4])
        expected = hashlib.sha256(hashlib.sha256(header).digest()).digest()
        if expected != digest:
            raise ValueError(f'SHA256d mismatch at {number}')
        flags = (str(int(digest[28:] == bytes(4))),
                 str(int(int.from_bytes(digest, 'little') <= int.from_bytes(target, 'little'))))
        if tuple(row[4:6]) != flags:
            raise ValueError(f'Native flags mismatch at {number}')
    if not re.fullmatch(r'NATIVE_NONCE_PASS decodes=2700 streams=11 vectors=128 assertions=\d+', summaries[0]):
        raise ValueError('Unexpected case counts')
    print('Independent hashlib/uint256 PASS: 128 native vectors')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('log', type=Path)
    args = parser.parse_args()
    verify(args.log)

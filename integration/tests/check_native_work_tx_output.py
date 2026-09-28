#!/usr/bin/env python3
"""Verify bytes emitted from real struct work against original ARM and CRC."""
from pathlib import Path
import binascii
import re
import sys
from tx86_oracle import TX86Oracle

REQUIRED_SYMBOLS = frozenset({
    'copy_work_noffset', '_free_work', 'test_nonce', 'fulltest', 'sha256',
    'dizzass_native_work_tx86', 'dizzass_work_tx86_encode', 'dizzass_tx86_crc16',
    '__wrap_socket', '__wrap_connect', '__wrap_libusb_init',
})

def verify_symbols(text):
    """Parse defined-symbol nm output; reject missing native or recovery core."""
    symbols = set()
    for line in text.splitlines():
        fields = line.split()
        if not fields:
            continue
        if len(fields) != 3 or not re.fullmatch(r'[0-9a-fA-F]+', fields[0]):
            raise ValueError(f'Malformed defined-symbol nm line: {line!r}')
        if len(fields[1]) != 1 or not fields[1].isalpha():
            raise ValueError(f'Malformed nm symbol type: {line!r}')
        symbols.add(fields[2])
    missing = REQUIRED_SYMBOLS.difference(symbols)
    unexpected = {name for name in symbols if name.startswith('vn135_')}
    if missing or unexpected:
        related = sorted((name, name.encode('utf-8').hex())
                         for name in symbols if 'copy' in name)
        raise ValueError(f'Wrong native symbol boundary: {missing=} '
                         f'{unexpected=} copy_symbols={related!r}')

def selftest_symbols():
    lines = ['0000000000004000 T ' + name for name in sorted(REQUIRED_SYMBOLS)]
    text = '\n'.join(lines) + '\n'
    verify_symbols(text)
    verify_symbols(text.replace(' ', '\t').replace('\n', '\r\n'))
    rejected = 0
    for symbol in sorted(REQUIRED_SYMBOLS):
        damaged = '\n'.join(line for line in lines if line.split()[-1] != symbol)
        try:
            verify_symbols(damaged)
        except ValueError:
            rejected += 1
        else:
            raise ValueError(f'Missing required symbol was accepted: {symbol}')
    for damaged in (text + '00000001 T vn135_work_hash\n',
                    text.replace('copy_work_noffset', 'copy_work_noffset.clone'),
                    text + 'not a valid nm line\n'):
        try:
            verify_symbols(damaged)
        except ValueError:
            rejected += 1
        else:
            raise ValueError('Invalid symbol boundary accepted by self-test')
    print(f'NATIVE_WORK_TX_SYMBOL_SELFTEST_PASS accepted=2 rejected={rejected}')

def verify(path, symbols_path=None):
    lines=Path(path).read_text(encoding='utf-8').splitlines()
    rows=[line.split() for line in lines if line.startswith('TX86_NATIVE ')]
    summaries=[line for line in lines if line.startswith('NATIVE_WORK_TX_PASS ')]
    if len(rows)!=64 or len(summaries)!=1 or not re.fullmatch(
        r'NATIVE_WORK_TX_PASS packets=256 vectors=64 roundtrips=2 assertions=\d+',summaries[0]):
        raise ValueError('Missing native TX vectors or unexpected case counts')
    oracle=TX86Oracle()
    for i,row in enumerate(rows):
        if len(row)!=5 or len(row[3])!=160 or len(row[4])!=172:
            raise ValueError(f'Malformed native TX vector {i}')
        layout,raw_id=map(int,row[1:3]); words,packet=map(bytes.fromhex,row[3:5])
        if layout not in (0,7) or raw_id not in range(128):
            raise ValueError('Invalid explicit layout/ID')
        if packet!=oracle.encode(words,layout,raw_id):
            raise ValueError(f'Original packet slice mismatch {i}')
        body=(words[:76]+bytes(4)) if layout==0 else (bytes(4)+words[:76])
        if packet[4:84]!=body[::-1] or packet[:4]!=bytes([0x55,0xaa,0x20,raw_id]):
            raise ValueError(f'Independent packet mapping mismatch {i}')
        if int.from_bytes(packet[84:],'big')!=binascii.crc_hqx(packet[2:84],0xffff):
            raise ValueError(f'Independent CRC mismatch {i}')
    if symbols_path is not None:
        verify_symbols(Path(symbols_path).read_text(encoding='utf-8'))
    print('NATIVE_WORK_TX_ORACLE_PASS native_vectors=64 original_reversal_and_crc=yes')
if __name__=='__main__':
    if sys.argv[1:] == ['--self-test']:
        selftest_symbols()
    else:
        if len(sys.argv) not in (2,3):
            raise SystemExit('usage: check_native_work_tx_output.py LOG [SYMBOLS] | --self-test')
        selftest_symbols()
        verify(*sys.argv[1:])

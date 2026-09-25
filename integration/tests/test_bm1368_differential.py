#!/usr/bin/env python3
"""Compare compiled BM1368 attribution to original ARM dispatch and RX calls."""
from pathlib import Path
import ctypes as C
import json
import random
import sys
from bm1368_oracle import BM1368Oracle, MODEL_NAMES

class Location(C.Structure):
    _fields_ = [('chip', C.c_uint32), ('core', C.c_uint32)]

def check(condition, message):
    if not condition:
        raise ValueError(message)

def main(path):
    lib = C.CDLL(str(Path(path).resolve()))
    locate = lib.dizzass_bm1368_locate
    locate.argtypes = [C.c_uint32, C.c_uint32, C.c_uint32, C.POINTER(Location)]
    locate.restype = C.c_int
    oracle = BM1368Oracle()
    rng = random.Random(0x13682026)
    model_cases = 0
    for selector, name in enumerate(MODEL_NAMES):
        check(oracle.selector(name.encode()) == selector, 'Original chip-name selector')
        check(oracle.chip_number(selector) == int(name[2:], 16), 'Original numeric chip map')
        model_cases += 1
    for name in (b'', b'BM136', b'BM1368x', b'bm1368', b'BM1368 ', b' BM1368', b'T21', b'S21'):
        check(oracle.selector(name) == 8, 'Unexpected model-name match')
        model_cases += 1
    for selector in (8, 9, 255, 0xffffffff):
        check(oracle.chip_number(selector) == 0, 'Original unknown numeric chip map')
        model_cases += 1

    cases = set()
    # Every supported chain count, extremes of the partition field, and both
    # extreme core values. Low bits vary independently; no nonce search occurs.
    for count in range(1, 257):
        for field in (0, 1, 0x8000, 0xffff):
            for core in (0, 127):
                cases.add((count, (core << 25) | (field << 9) | rng.randrange(512)))
    for count in (2, 3, 7, 16, 63, 64, 65, 100, 108, 128, 255, 256):
        for chip in {1, count//2, count-1}:
            boundary = (chip * 65536 + count-1)//count
            for field in (boundary-1, boundary, boundary+1):
                if 0 <= field < 65536:
                    cases.add((count, (rng.randrange(128) << 25) | (field << 9) | 0x1ff))
    for core in range(128):
        cases.add((108, (core << 25) | (0x8000 << 9) | core))
    for bit in range(32):
        cases.add((108, 1 << bit))
        cases.add((108, 0xffffffff ^ (1 << bit)))
    for _ in range(512):
        cases.add((rng.randrange(1, 257), rng.getrandbits(32)))
    for count, nonce in sorted(cases):
        original = oracle.locate(nonce, count)
        got = Location(0xaaaaaaaa, 0xbbbbbbbb)
        check(locate(4, count, nonce, C.byref(got)) == 0, 'New attribution rejected valid input')
        check((got.chip, got.core) == original, f'Original mismatch {count=} {nonce=:08x}')
        # Independent extraction/division, not the same C expression.
        bits = f'{nonce:032b}'
        expected = (int(bits[7:23], 2) * count // 65536, int(bits[:7], 2))
        check(original == expected and 0 <= got.chip < count and got.core < 128,
              'Independent partition check failed')

    rx_cases = 0
    for variant in range(3):
        for _ in range(96):
            payload = bytearray(rng.getrandbits(8) for _ in range(7+variant))
            payload[-1] |= 0x80
            count = rng.randrange(1, 257)
            word, chip, core = oracle.rx_attribution(variant, payload, count)
            offset = 1 if variant == 1 else 0
            check(word == int.from_bytes(payload[offset:offset+4], 'big'), 'Original RX word order')
            result = Location()
            check(locate(4, count, word, C.byref(result)) == 0 and
                  (result.chip, result.core) == (chip, core), 'Original RX composition mismatch')
            rx_cases += 1

    rejected = 0
    for selector, count, expected in [(4, 0, -1), (4, 257, -1), (4, 0xffffffff, -1)] + [
            (x, 108, -2) for x in (0, 1, 2, 3, 5, 6, 7, 8, 0xffffffff)]:
        result = Location(0xaabbccdd, 0x11223344)
        before = bytes(result)
        check(locate(selector, count, 0x12345678, C.byref(result)) == expected and
              bytes(result) == before, 'Error mutated output or returned wrong code')
        rejected += 1
    check(locate(4, 108, 0, None) == -1, 'NULL output accepted')
    print('BM1368_DIFFERENTIAL_PASS ' + json.dumps({
        'locations': len(cases), 'rx_compositions': rx_cases, 'model_cases': model_cases,
        'rejected_inputs': rejected+1, 'source_decoder_steps': oracle.source_decode_steps,
        'attribution_external_hooks': 0, 'model_external_hooks': ['strcmp']}, sort_keys=True))

if __name__ == '__main__':
    if len(sys.argv) != 2:
        raise SystemExit('usage: test_bm1368_differential.py SHARED_LIBRARY')
    main(sys.argv[1])

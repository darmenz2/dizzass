#!/usr/bin/env python3
"""Test-only independent polynomial long division; no vendor/reference execution."""
from pathlib import Path
import argparse

def remainder(data: bytes, bits: int) -> int:
    if not 0 <= bits <= len(data)*8:
        raise ValueError('invalid bit length')
    word = int.from_bytes(data, 'big') >> (len(data)*8-bits)
    dividend = (31 << bits) ^ (word << 5)
    while dividend.bit_length() > 5:
        dividend ^= 0x25 << (dividend.bit_length()-6)
    return dividend

def framed(payload: bytes) -> bytes:
    p=bytearray(payload)
    p[-1]=(p[-1]&0xe0) | remainder(p,67)
    if remainder(p,72):
        raise ValueError('nonzero appended residue')
    return b'\xaa\x55'+p

def rendered() -> str:
    # wire nonce word uses the same already established native fixture byte order.
    nonce=[framed(bytes.fromhex('1dac2b7c')+bytes([s>>4,(s&15)<<4,0,0,0x80])) for s in range(32)]
    regs=[framed(bytes.fromhex('deadbeef08')+bytes([reg,0,0,0])) for reg in (0x42,0x40)]
    text='/* Test-only synthetic frames; polynomial division, not hardware captures. */\n'
    for name,values in [('r08_nonce',nonce),('r08_register',regs)]:
        text+=f'static const uint8_t {name}[{len(values)}][11] = {{\n'
        text+=''.join('    {'+','.join(f'0x{b:02x}' for b in value)+'},\n' for value in values)
        text+='};\n'
    return text
if __name__=='__main__':
    ap=argparse.ArgumentParser();ap.add_argument('--check',action='store_true');a=ap.parse_args()
    p=Path(__file__).with_name('vectors.h')
    if a.check:
        if p.read_text()!=rendered():raise SystemExit('fixture mismatch')
        print('R08_POLYNOMIAL_VECTORS_PASS frames=34')
    else:p.write_text(rendered())

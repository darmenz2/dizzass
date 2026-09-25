#!/usr/bin/env python3
"""Actual ARM-slice comparisons; output counts refer to test cases, not functions."""
import binascii
import ctypes as C
import random
import struct
import sys
from tx86_oracle import TX86Oracle, TX86ARM

def main():
    if len(sys.argv)!=2: raise SystemExit('usage: test_tx86_differential.py LIBRARY')
    lib=C.CDLL(sys.argv[1]);u8=C.c_uint8;P=C.POINTER(u8)
    encode=lib.dizzass_work_tx86_encode
    encode.argtypes=[P,C.c_size_t,C.c_int,C.c_uint32,P,C.c_size_t];encode.restype=C.c_int
    crc=lib.dizzass_tx86_crc16;crc.argtypes=[P,C.c_size_t,C.c_uint16];crc.restype=C.c_uint16
    def buf(b): return (u8*max(1,len(b))).from_buffer_copy(b or b'\0')
    o=TX86Oracle();rng=random.Random(0x8666);packets=checks=opcodes=0
    # Independent instruction checks for both added decoder forms and conditions.
    for b in range(256):
        m=o.m;p=m.DATA_BASE;m.reset();m.write(p,0xe6af0071);m.r[1]=0xaabb0000|b
        m.run(p,stop=p+4);assert m.r[0]==((b-256 if b>=128 else b)&0xffffffff);opcodes+=1
    for _ in range(128):
        m=o.m;p=m.DATA_BASE;x=rng.getrandbits(32);m.reset();m.write(p,0xe6bf0fb1);m.r[1]=x
        m.run(p,stop=p+4)
        bb=x.to_bytes(4,'little');assert m.r[0]==int.from_bytes(bb[1::-1]+bb[3:1:-1],'little');opcodes+=1
    for n in (0,1,2,7,32,80,82,86,127,256,1024):
        for seed in (0,1,0xffff,0x1234):
            b=rng.randbytes(n);expected=binascii.crc_hqx(b,seed)
            assert crc(buf(b),n,seed)==expected==o.crc(b,seed);checks+=1
    for b in range(256):
        data=bytes([b]);seed=rng.getrandbits(16)
        assert crc(buf(data),1,seed)==o.crc(data,seed)==binascii.crc_hqx(data,seed);checks+=1
    # Both original layout branches and every supported transmitted ID.
    for selector in (0,7):
        for raw_id in range(128):
            for _ in range(2):
                w=rng.randbytes(80);out=buf(b'\xa5'*94)
                assert encode(buf(w),80,selector,raw_id,C.cast(C.byref(out,3),P),88)==0
                got=bytes(out)[3:89];expected=o.encode(w,selector,raw_id)
                assert got==expected,(selector,raw_id,got.hex(),expected.hex())
                body=w[:76]+b'\0'*4 if selector==0 else b'\0'*4+w[:76]
                assert got[4:84]==body[::-1] and got[:4]==bytes([0x55,0xaa,0x20,raw_id])
                assert int.from_bytes(got[84:],'big')==binascii.crc_hqx(got[2:84],0xffff)
                assert bytes(out)[:3]==b'\xa5'*3 and bytes(out)[89:]==b'\xa5'*5
                packets+=1
    # The special selector is 7, not every nonzero selector.
    for selector in (1,2,3,4,5,6,8,9,0xffffffff):
        w=rng.randbytes(80);out=buf(b'\0'*86)
        assert encode(buf(w),80,0,17,out,86)==0
        assert bytes(out)==o.encode(w,selector,17);packets+=1
    # Original high-bit input wraps to 1; the public encoder rejects it.
    for selector in (0,7):
        w=rng.randbytes(80)
        for raw_id in (128,129,254,255):
            expected=o.encode(w,selector,raw_id)
            assert expected[3]==1
            out=buf(b'\xa5'*86)
            assert encode(buf(w),80,selector,raw_id,out,86)==-300 and bytes(out)==b'\xa5'*86
    w=rng.randbytes(80)
    for n in (0,1,79,81):
        out=buf(b'\xa5'*86)
        assert encode(buf(w),n,0,1,out,86)==-300 and bytes(out)==b'\xa5'*86
    for cap in (0,1,80,85):
        out=buf(b'\xa5'*86)
        assert encode(buf(w),80,0,1,out,cap)==-302 and bytes(out)==b'\xa5'*86
    for layout in (-1,1,2,8):
        out=buf(b'\xa5'*86)
        assert encode(buf(w),80,layout,1,out,86)==-301 and bytes(out)==b'\xa5'*86
    out=buf(b'\xa5'*86)
    assert encode(None,80,0,1,out,86)==-300
    assert encode(buf(w),80,0,1,None,86)==-300
    for layout in (0,7):
        overlap=buf(w+b'\0'*6)
        assert encode(overlap,80,layout,1,overlap,86)==0
        assert bytes(overlap)==o.encode(w,layout,1)
    print(f'TX86_DIFFERENTIAL_PASS packets={packets} crc={checks} opcode_checks={opcodes}')
if __name__=='__main__': main()

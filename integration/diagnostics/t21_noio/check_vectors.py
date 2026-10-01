#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Recompute fixed data using binascii CRC16 and GF(2) CRC5 long division."""
import binascii, pathlib
def crc5(data):
    bitlen=len(data)*8
    dividend=(int.from_bytes(data,'big')<<5) ^ (31<<bitlen)
    for pos in range(bitlen+4,4,-1):
        if (dividend>>pos)&1: dividend ^= 0x25<<(pos-5)
    return dividend & 31
frame=bytearray([0x55,0xaa,0x21,0x36,0,1,0,0,0,0])+bytearray(range(75,-1,-1))
if len(frame)!=86:raise SystemExit('bad vector length')
frame+=binascii.crc_hqx(frame[2:],0xffff).to_bytes(2,'big')
v='/* SPDX-License-Identifier: GPL-3.0-only\n * D-01 fixed software vectors, not operational chip settings.\n * TX88 CRC: Python binascii.crc_hqx; CRC5: host GF(2) long division. */\n'
v+='static const uint8_t d01_tx0[88]={'+','.join('0x%02x'%x for x in frame)+'};\n'
v+='static const uint8_t d01_slots[32][3]={\n'
for i in range(32):
 f=bytearray(frame);f[4]=i*8;c=binascii.crc_hqx(f[2:86],0xffff)
 v+='    {0x%02x,0x%02x,0x%02x},\n'%(f[4],c>>8,c&255)
v+='};\nstruct d01_command_vector {unsigned cmd,broadcast,address,reg; uint32_t value; size_t length; uint8_t packet[11];};\nstatic const struct d01_command_vector d01_commands[]={\n'
for cmd,bc,addr,reg,value in [(0,0,0,0,0),(1,0,0x42,0,0),(2,0,0x23,0x18,0),(2,1,0,0x20,0),(3,0,0x23,0xa8,0x12345678),(3,1,0,8,0xa5a55a5a)]:
 n=11 if cmd==3 else 7
 typ=[0x53,0x40,0x42|(bc*16),0x41|(bc*16)][cmd]
 p=bytearray([0x55,0xaa,typ,n-2,addr,reg]);
 if n==11:p+=value.to_bytes(4,'big')
 p+=bytes([crc5(p[2:])])
 v+='    {%d,%d,%d,%d,UINT32_C(0x%08x),%d,{%s}},\n'%(cmd,bc,addr,reg,value,n,','.join('0x%02x'%b for b in p))
v+='};\n'
if v != (pathlib.Path(__file__).resolve().parent/'vectors.h').read_text():
 raise SystemExit('VECTOR_DRIFT')
print('D01_INDEPENDENT_VECTORS_PASS frames=32 commands=6')

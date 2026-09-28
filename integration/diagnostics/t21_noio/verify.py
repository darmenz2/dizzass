#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Structural ELF / fixed syscall-site audit. This is not formal verification."""
import argparse, hashlib, json, pathlib, struct

def require(ok, message):
    if not ok: raise ValueError(message)

def inspect(path):
    data=pathlib.Path(path).read_bytes()
    require(len(data)>=64 and data[:4]==b'\x7fELF','not ELF')
    require(data[5:7]==b'\x01\x01','requires little-endian ELF v1')
    cls=data[4]; require(cls in (1,2),'ELF class')
    def unpack(fmt,off):
        require(off>=0 and off+struct.calcsize(fmt)<=len(data),'truncated ELF')
        return struct.unpack_from(fmt,data,off)
    h=unpack('<HHIIIIIHHHHHH' if cls==1 else '<HHIQQQIHHHHHH',16)
    typ,machine,version,entry,phoff,shoff,flags,ehsize,phsize,phnum,shsize,shnum,shstr=h
    require(typ==2 and version==1,'not static executable type')
    require((cls,machine) in ((1,40),(2,183)),'unsupported target')
    require(phnum<32 and 0<shnum<128 and shstr<shnum,'invalid header counts')
    require(phsize==(32 if cls==1 else 56) and shsize==(40 if cls==1 else 64),'invalid header sizes')
    require(len(data)<131072,'unexpected diagnostic size')
    executable=[]; stack=False
    for i in range(phnum):
        p=unpack('<IIIIIIII' if cls==1 else '<IIQQQQQQ',phoff+i*phsize)
        if cls==1: pt,off,va,pa,fs,ms,pf,align=p
        else: pt,pf,off,va,pa,fs,ms,align=p
        require(pt not in (2,3),'dynamic section or ELF interpreter')
        require(not(pf&1 and pf&2),'writable executable segment')
        if pt==1:
            require(fs<=ms and off+fs<=len(data),'bad load segment')
            if pf&1: executable.append((va,ms))
        if pt==0x6474e551: stack=True; require(pf==6,'executable/nonstandard stack')
    require(stack and any(a<=entry<a+n for a,n in executable),'entry/stack boundary')
    sections=[unpack('<IIIIIIIIII' if cls==1 else '<IIQQQQIIQQ',shoff+i*shsize) for i in range(shnum)]
    def section_bytes(i):
        s=sections[i]; require(s[4]+s[5]<=len(data),'section outside ELF')
        return data[s[4]:s[4]+s[5]]
    names=section_bytes(shstr)
    def name(buf,off):
        require(off<len(buf),'string offset'); end=buf.find(b'\0',off)
        require(end!=-1,'unterminated string'); return buf[off:end].decode('ascii')
    text_i=[i for i,s in enumerate(sections) if name(names,s[0])=='.text']
    require(len(text_i)==1,'single code section required')
    ti=text_i[0]; text=section_bytes(ti); addr=sections[ti][3]
    require(len(text)%4==0,'instruction alignment')
    # No other executable section may smuggle an additional syscall site.
    require(all(i==ti or not(s[2]&4) or not s[5] for i,s in enumerate(sections)),'extra executable section')
    syms={}; undefined=[]
    for s in sections:
        if s[1]!=2: continue
        strings=section_bytes(s[6]); step=s[9]
        require(step==(16 if cls==1 else 24) and s[5]%step==0,'symbol table')
        for off in range(s[4],s[4]+s[5],step):
            v=unpack('<IIIBBH' if cls==1 else '<IBBHQQ',off)
            if cls==1: no,value,size,info,other,idx=v
            else: no,info,other,idx,value,size=v
            nm=name(strings,no)
            if nm and idx==0: undefined.append(nm)
            if nm and idx==ti and size: syms[nm]=(value,size)
    require(not undefined,'undefined symbols: '+str(undefined))
    require('dizzass_bm1368_reset_cores' not in syms,'reset code must not be linked')
    required=['diag_main','diag_selftest','dizzass_tx88_encode_words','dizzass_tx88_crc16','dizzass_bm1368_command_encode','vn135_crc5_bits']
    require(all(n in syms for n in required),'missing actual diagnostic/codec implementation')
    arm={
        'diag_write':[0xe92d4080,0xe1a02001,0xe1a01000,0xe3a00001,0xe3a07004,0xef000000,0xe8bd8080],
        'diag_uname':[0xe92d4080,0xe3a0707a,0xef000000,0xe8bd8080],
        'diag_clock':[0xe92d4080,0xe1a01000,0xe3a00001,0xe3007107,0xef000000,0xe8bd8080],
        'diag_exit':[0xe3a07001,0xef000000,0xe7f000f0]}
    a64={
        'diag_write':[0xaa0103e2,0xaa0003e1,0xd2800020,0xd2800808,0xd4000001,0xd65f03c0],
        'diag_uname':[0xd2801408,0xd4000001,0xd65f03c0],
        'diag_clock':[0xaa0003e1,0xd2800020,0xd2800e28,0xd4000001,0xd65f03c0],
        'diag_exit':[0xd2800ba8,0xd4000001,0xd4200000]}
    expected=arm if cls==1 else a64; sites=set()
    for nm,words in expected.items():
        require(nm in syms,'missing fixed syscall wrapper '+nm)
        va,size=syms[nm]; want=struct.pack('<'+'I'*len(words),*words)
        require(size==len(want) and text[va-addr:va-addr+size]==want,'changed syscall wrapper '+nm)
        for j,w in enumerate(words):
            if w in (0xef000000,0xd4000001): sites.add(va+4*j)
    found=set()
    for i in range(0,len(text),4):
        w=struct.unpack_from('<I',text,i)[0]
        is_svc=(w&0x0f000000)==0x0f000000 if cls==1 else (w&0xffe0001f)==0xd4000001
        if is_svc: found.add(addr+i)
    require(len(sites)==4 and found==sites,'unaccounted syscall site')
    return {'file':str(path),'sha256':hashlib.sha256(data).hexdigest(),'size':len(data),
            'elf_class':cls,'machine':machine,'entry':hex(entry),'syscall_sites':4,
            'allowed':['write(fd=1)','uname','clock_gettime(CLOCK_MONOTONIC)','exit'],
            'dynamic_loader':False,'writable_executable_segment':False,'reset_linked':False}

if __name__=='__main__':
    ap=argparse.ArgumentParser(description=__doc__); ap.add_argument('binaries',nargs='+',type=pathlib.Path)
    args=ap.parse_args()
    for p in args.binaries: print('D01_ELF_AUDIT_PASS '+json.dumps(inspect(p),sort_keys=True))

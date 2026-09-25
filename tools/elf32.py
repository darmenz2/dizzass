"""Read-only ELF32 little-endian reader used by the reconstruction tests."""
from __future__ import annotations
import struct
from pathlib import Path

class ELF32:
    def __init__(self, path):
        self.data = Path(path).read_bytes()
        if len(self.data)<52 or self.data[:7] != b'\x7fELF\x01\x01\x01':
            raise ValueError('Expected ELF32 little-endian')
        h = struct.unpack_from('<16sHHIIIIIHHHHHH', self.data)
        self.machine, self.entry = h[2], h[4]
        self.phoff,self.shoff=h[5],h[6]
        self.phentsize,self.phnum,self.shentsize,self.shnum,self.shstr=h[9:14]
        self.segments=[]
        for i in range(self.phnum):
            p=struct.unpack_from('<8I',self.data,self.phoff+i*self.phentsize)
            if p[0]==1:
                if p[1]+p[4]>len(self.data) or p[4]>p[5]:raise ValueError('Bad segment')
                self.segments.append(dict(offset=p[1],addr=p[2],filesz=p[4],memsz=p[5],flags=p[6]))
        self.sections={}
        sh=[struct.unpack_from('<10I',self.data,self.shoff+i*self.shentsize) for i in range(self.shnum)]
        if sh:
            ns=sh[self.shstr]; names=self.data[ns[4]:ns[4]+ns[5]]
            for s in sh:
                end=names.find(b'\0',s[0]); name=names[s[0]:end].decode('ascii','replace')
                self.sections[name]=dict(addr=s[3],offset=s[4],size=s[5],type=s[1])

    def read(self, addr, length):
        if length<0:raise ValueError('Negative length')
        for s in self.segments:
            off=addr-s['addr']
            if 0<=off and off+length<=s['filesz']:
                p=s['offset']+off;return self.data[p:p+length]
        raise ValueError(f'Unmapped file address 0x{addr:x} length {length}')

    def section(self,name):
        s=self.sections[name];return self.data[s['offset']:s['offset']+s['size']]

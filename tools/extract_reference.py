#!/usr/bin/env python3
"""Extract only cgminer from the user-supplied archive without running it."""
from pathlib import Path
import argparse,gzip,hashlib,struct,tarfile
EXPECTED='b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'

def extract(path):
    with tarfile.open(path) as t:
        member=t.getmember('uramdisk.image.gz')
        if not member.isfile() or member.size>100*1024*1024:raise ValueError('Unexpected RAM disk member')
        data=t.extractfile(member).read()
    if data[:4]!=bytes.fromhex('27051956'):raise ValueError('Expected U-Boot legacy image')
    size=struct.unpack_from('>I',data,12)[0]
    if size!=len(data)-64:raise ValueError('U-Boot payload size mismatch')
    data=gzip.decompress(data[64:])
    if len(data)>128*1024*1024:raise ValueError('Oversized RAM disk')
    pos=0
    while pos+110<=len(data):
        if data[pos:pos+6] not in (b'070701',b'070702'):raise ValueError('Invalid newc record')
        fields=[int(data[pos+6+i*8:pos+14+i*8],16) for i in range(13)]
        size,namesize=fields[6],fields[11]
        if namesize<1 or pos+110+namesize>len(data):raise ValueError('Invalid newc name')
        name=data[pos+110:pos+110+namesize-1].decode('utf-8','strict')
        begin=(pos+110+namesize+3)&~3;end=begin+size
        if end>len(data):raise ValueError('Truncated newc record')
        if name in ('usr/bin/cgminer','./usr/bin/cgminer'):
            out=data[begin:end]
            if hashlib.sha256(out).hexdigest()!=EXPECTED:raise ValueError('Wrong cgminer binary')
            return out
        if name=='TRAILER!!!':break
        pos=(end+3)&~3
    raise ValueError('cgminer not found')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('firmware',type=Path)
    p.add_argument('--output',type=Path,default=Path(__file__).resolve().parents[1]/'reference/cgminer.vendor.elf')
    a=p.parse_args();data=extract(a.firmware)
    if a.output.exists() and a.output.read_bytes()!=data:raise ValueError('Refusing to replace a different reference')
    a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_bytes(data);a.output.chmod(0o644)
    print(f'{a.output}: {len(data)} bytes, SHA-256 {EXPECTED}')
if __name__=='__main__':main()

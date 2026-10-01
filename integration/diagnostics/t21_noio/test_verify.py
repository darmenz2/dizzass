#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Reject modified ELF headers / syscall instructions without executing them."""
import argparse, pathlib, struct, tempfile
from verify import inspect

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--build',required=True,type=pathlib.Path)
    a=ap.parse_args();cases=0
    for arch in ['armv7','aarch64']:
        path=a.build/('dizzass-noio-'+arch); original=path.read_bytes();inspect(path)
        cls=original[4];phoff=struct.unpack_from('<I' if cls==1 else '<Q',original,28 if cls==1 else 32)[0]
        def patch(offset,fmt,value):
            b=bytearray(original);struct.pack_into(fmt,b,offset,value);return bytes(b)
        write_fd=struct.pack('<I',0xe3a00001 if cls==1 else 0xd2800020)
        # Find fixed wrapper body rather than arbitrary occurrences of mov #1.
        start=original.find(struct.pack('<II',0xe92d4080,0xe1a02001) if cls==1 else struct.pack('<II',0xaa0103e2,0xaa0003e1))
        if start<0:raise SystemExit('no wrapper')
        changes=[('magic',b'BAD!'+original[4:]),('class',patch(4,'B',0)),
            ('machine',patch(18,'<H',0)),('dynamic_type',patch(16,'<H',3)),
            ('interpreter',patch(phoff,'<I',3)),('wx',patch(phoff+(24 if cls==1 else 4),'<I',7)),
            ('truncated',original[:60]),('oversized',original+b'\0'*131072),
            ('write_fd',patch(start+(12 if cls==1 else 8),'<I',0xe3a00002 if cls==1 else 0xd2800040))]
        for label,data in changes:
            with tempfile.TemporaryDirectory(prefix='d01-elf-negative-') as tmp:
                p=pathlib.Path(tmp)/'data-only.elf';p.write_bytes(data)
                try:inspect(p)
                except (ValueError,UnicodeDecodeError):cases+=1
                else:raise SystemExit('MUTATION_ACCEPTED '+arch+' '+label)
    print('D01_ELF_NEGATIVE_PASS rejected='+str(cases)+' executed_modified_binaries=0')
if __name__=='__main__':main()

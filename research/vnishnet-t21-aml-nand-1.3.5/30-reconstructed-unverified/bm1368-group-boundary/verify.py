#!/usr/bin/env python3
"""Static data/source integrity only, NOT execution or automatic equivalence."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import stat
import sys
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[3]
sys.path.insert(0,str(ROOT/"integration/tests"))
from current_dependency_pins_135 import (
    BM1368_PATH, BM1368_ADDRESS_SHA256, address_bm1368_bytes)
WITNESS_SHA256="11051fe9f49e34e52cf4f2105480d6ac9be7dd90bae20a5dd8b43d9b78512c69"
ASM_SHA256="470a6a356a7830ad3c780209bb350aef78b227c64febba0c01e5adcf96f88fd4"

def require(ok,why):
    if not ok:raise ValueError(why)

def sha(data):return hashlib.sha256(data).hexdigest()

def source_bytes(root,path,expected):
    """Read a canonical regular source; recover only the exact old L13 pin."""
    require(isinstance(path,str) and path != ""
            and not PurePosixPath(path).is_absolute()
            and all(part not in ("", ".", "..") for part in path.split("/")),
            "source path must be canonical and repository-relative")
    file=Path(root)
    parts=path.split("/")
    for index,part in enumerate(parts):
        file=file/part
        mode=file.lstat().st_mode
        if index < len(parts)-1:
            require(stat.S_ISDIR(mode),"source parent is not a directory: "+path)
        else:
            require(stat.S_ISREG(mode) and not mode & 0o111,
                    "source must be a non-executable regular file: "+path)
    data=file.read_bytes()
    if path == BM1368_PATH:
        require(expected==BM1368_ADDRESS_SHA256,"historical L13 source pin changed")
        data=address_bm1368_bytes(data)
    require(sha(data)==expected,"changed source: "+path)
    return data

def verify(root,with_reference):
    raw=(HERE/"static-witness.json").read_bytes()
    require(sha(raw)==WITNESS_SHA256,"static witness changed")
    require(sha((HERE/"original-code.asm").read_bytes())==ASM_SHA256,"disassembly changed")
    m=json.loads(raw)
    regions={}
    for region in m["regions"]:
        b=bytes.fromhex(region["hex"])
        require(len(b)==region["size"] and sha(b)==region["sha256"],"region bytes/hash")
        regions[region["name"]]=(region,b)
    def word(address):
        for region,b in regions.values():
            offset=address-region["va"]
            if 0<=offset<=len(b)-4:return int.from_bytes(b[offset:offset+4],"little")
        raise ValueError("word outside recorded ranges")
    for at,expected in m["word_facts"].items():
        require(word(int(at,16))==int(expected,16),"instruction annotation")
    for edge in m["branches"]:
        w=word(edge["at"]);require(w>>24==0xeb,"expected unconditional ARM BL")
        displacement=w&0xffffff
        if displacement&0x800000:displacement-=0x1000000
        require((edge["at"]+8+4*displacement)&0xffffffff==edge["target"],"branch target")
    for row in m["strings"]:
        plain=bytes(x^row["xor"] for x in regions[row["region"]][1])
        require(plain.split(b"\0",1)[0].decode("ascii")==row["text"],"diagnostic string")
        require(b"\0" in plain,"unterminated diagnostic")
    require((0xe4778+8+word(0xe47b4))&0xffffffff==0x5eb5fa,"format literal")
    require((0xe5a7c+8+word(0xe60a0))&0xffffffff==0x5eb5fa,"format initializer literal")
    require((0xfdfb0+8+word(0xfdfb8))&0xffffffff==0x654b08,"first selector global")
    for path,expected in m["source_sha256"].items():
        source_bytes(root,path,expected)
    if with_reference:
        source=root/m["reference"]["path"]
        require(source.is_file() and not source.is_symlink(),"reference must be regular")
        image=source.read_bytes()
        require(len(image)==m["reference"]["size"] and sha(image)==m["reference"]["sha256"],"wrong complete reference")
        sys.path.insert(0,str(root/"tools"))
        from elf32 import ELF32
        elf=ELF32(source)
        for region,b in regions.values():
            require(elf.read(region["va"],region["size"])==b,"reference range mismatch")
    return {"regions":len(regions),"bytes":sum(len(b) for _,b in regions.values()),
        "word_facts":len(m["word_facts"]),"branches":len(m["branches"]),
        "source_pins":len(m["source_sha256"]),"original_read_as_data":with_reference}

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root",type=Path,default=ROOT)
    p.add_argument("--with-reference",action="store_true")
    args=p.parse_args()
    print("GROUP_BOUNDARY_STATIC_PASS "+json.dumps(verify(args.root,args.with_reference),sort_keys=True))

if __name__=="__main__":main()

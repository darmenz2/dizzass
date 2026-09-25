#!/usr/bin/env python3
"""Explicitly refresh or verify the additive overlay's source inventory.
Run --write only after reviewing edits and tests. Build outputs are excluded.
"""
from pathlib import Path
import argparse,hashlib,json,sys
ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/'reconstruction/overlay-files.json'

def inventory():
    rows=[]
    for p in sorted(ROOT.rglob('*')):
        rel=p.relative_to(ROOT)
        if rel.parts[0]=='build' or any(x in ('__pycache__','.git') for x in rel.parts):continue
        if p==DEST:continue
        if p.is_symlink():raise ValueError(f'Symlink not allowed in overlay: {rel}')
        if not p.is_file():continue
        data=p.read_bytes();rows.append({'path':rel.as_posix(),'sha256':hashlib.sha256(data).hexdigest(),'bytes':len(data)})
    return rows

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    group=ap.add_mutually_exclusive_group(required=True)
    group.add_argument('--check',action='store_true');group.add_argument('--write',action='store_true')
    args=ap.parse_args();rows=inventory()
    if args.write:DEST.write_text(json.dumps(rows,indent=2)+'\n')
    elif json.loads(DEST.read_text())!=rows:ap.exit(1,'Overlay inventory does not match the current source tree.\n')
    print(f'Overlay inventory: {len(rows)} files; {"written" if args.write else "PASS"}')
if __name__=='__main__':main()

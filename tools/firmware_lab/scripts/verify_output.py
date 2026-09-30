#!/usr/bin/env python3
"""Verify static extraction object hashes; never execute any extracted content."""
import argparse,hashlib,json,pathlib,re,stat

def digest(path):
    if path.is_symlink() or not path.is_file():raise ValueError('expected regular non-symlink file: '+str(path))
    h=hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda:f.read(1024**2),b''):h.update(chunk)
    return h.hexdigest()

def verify(root):
    if root.is_symlink() or (root/'objects').is_symlink():raise ValueError('symlinked output directory')
    m=json.loads((root/'manifest.json').read_text())
    refs={}
    for r in m['tar']+m['newc']+m['layers']:
        if 'object' not in r:continue
        if re.fullmatch(r'objects/[0-9a-f]{64}',r['object']) is None:raise ValueError('invalid object path')
        if r['object'].split('/')[1]!=r['sha256']:raise ValueError('object identity differs from manifest')
        if r['object'] in refs and refs[r['object']]!=r['sha256']:raise ValueError('conflicting object record')
        refs[r['object']]=r['sha256']
    actual={'objects/'+p.name for p in (root/'objects').iterdir()}
    if actual!=set(refs):raise ValueError('missing or unreferenced objects')
    for name,expected in refs.items():
        p=root/name
        if digest(p)!=expected:raise ValueError('object hash mismatch: '+name)
        if p.stat().st_mode&0o111:raise ValueError('executable object: '+name)
    if digest(root/'cgminer.vendor.elf')!=m['expected_elf_sha256']:raise ValueError('reference ELF hash mismatch')
    if (root/'cgminer.vendor.elf').stat().st_mode&0o111:raise ValueError('executable reference ELF')
    return {'objects_verified':len(refs),'manifest_sha256':digest(root/'manifest.json'),'reference_elf_sha256':m['expected_elf_sha256']}

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=pathlib.Path);a=p.parse_args()
    print(json.dumps(verify(a.output),sort_keys=True))
if __name__=='__main__':main()

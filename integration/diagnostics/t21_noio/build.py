#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Build the isolated D-01 diagnostic; never build or start the miner."""
import argparse, hashlib, json, pathlib, shutil, subprocess
ROOT=pathlib.Path(__file__).resolve().parents[3]
HERE=pathlib.Path(__file__).resolve().parent

def checked_sources():
    manifest=json.loads((HERE/'manifest.json').read_text())
    for name,digest in manifest['pure_sources'].items():
        if hashlib.sha256((ROOT/name).read_bytes()).hexdigest()!=digest:
            raise SystemExit('SOURCE_HASH_MISMATCH: '+name)
    return manifest

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',required=True,type=pathlib.Path)
    ap.add_argument('--cc',default='clang')
    args=ap.parse_args(); manifest=checked_sources()
    cc=shutil.which(args.cc)
    if not cc: raise SystemExit('Clang not available: '+args.cc)
    out=args.out.resolve(); out.mkdir(parents=True,exist_ok=False)
    resource=subprocess.check_output([cc,'-print-resource-dir'],text=True).strip()
    records=[]
    def run(cmd,name):
        p=subprocess.run(cmd,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
        (out/name).write_text(p.stdout)
        records.append({'argv':cmd,'exit':p.returncode,'log':name})
        if p.returncode:
            (out/'commands.json').write_text(json.dumps(records,indent=2)+'\n')
            raise SystemExit(p.stdout)
    inputs=[HERE/'main.c',HERE/'selftest.c',HERE/'mini_mem.c',HERE/'linux_entry.S',
            ROOT/'integration/work_tx88.c',ROOT/'integration/bm1368_control.c',
            ROOT/'reconstruction/support/crc5.c']
    for arch,triple,cpu in [('armv7','armv7-linux-gnueabi',['-march=armv7-a','-marm','-mfloat-abi=soft','-mno-unaligned-access']),
                            ('aarch64','aarch64-linux-gnu',['-march=armv8-a','-mgeneral-regs-only','-mstrict-align'])]:
        common=[cc,'--target='+triple,*cpu,'-Os','-ffreestanding','-fno-builtin',
                '-fno-stack-protector','-fno-unwind-tables','-fno-asynchronous-unwind-tables',
                '-fno-pic','-fno-pie','-ffunction-sections','-fdata-sections','-nostdinc',
                '-isystem',resource+'/include','-I'+str(HERE/'freestanding'),'-I'+str(ROOT),
                '-I'+str(ROOT/'include'),'-Wall','-Wextra','-Werror']
        objects=[]
        for i,source in enumerate(inputs):
            obj=out/(arch+'-'+str(i)+'.o'); objects.append(str(obj))
            run(common+['-c',str(source),'-o',str(obj)],arch+'-compile-'+str(i)+'.log')
        binary=out/('dizzass-noio-'+arch)
        run([cc,'--target='+triple,*cpu,'-nostdlib','-static','-fuse-ld=lld',
             '-Wl,--build-id=none,-z,noexecstack,--gc-sections,--no-undefined,-e,_start',
             '-Wl,-Map,'+str(out/(arch+'.map')),*objects,'-o',str(binary)],arch+'-link.log')
        run(['readelf','-h','-l','-A',str(binary)],arch+'-elf.txt')
    manifest['toolchain']=subprocess.check_output([cc,'--version'],text=True)
    manifest['diagnostic_sources']={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
        for p in HERE.rglob('*') if p.is_file() and '__pycache__' not in p.parts}
    manifest['binaries']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in out.glob('dizzass-noio-*')}
    (out/'build-receipt.json').write_text(json.dumps(manifest,indent=2)+'\n')
    (out/'commands.json').write_text(json.dumps(records,indent=2)+'\n')
    (out/'SHA256SUMS').write_text(''.join(h+'  '+p+'\n' for p,h in manifest['binaries'].items()))
    print('D01_BUILD_PASS',json.dumps(manifest['binaries']))
if __name__=='__main__': main()

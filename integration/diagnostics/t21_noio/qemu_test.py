#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Execute only the newly built diagnostic under QEMU user mode and audit guest syscalls."""
import argparse, hashlib, json, pathlib, re, subprocess
from verify import inspect,require

def main():
    ap=argparse.ArgumentParser(description=__doc__);ap.add_argument('--build',required=True,type=pathlib.Path)
    ap.add_argument('--out',required=True,type=pathlib.Path)
    ap.add_argument('--arm',default='qemu-arm');ap.add_argument('--aarch64',default='qemu-aarch64')
    a=ap.parse_args();a.out.mkdir(parents=True,exist_ok=False);results=[]
    for arch,qemu,cpus in [('armv7',a.arm,['cortex-a7','cortex-a9','cortex-a15']),('aarch64',a.aarch64,['cortex-a53','cortex-a72'])]:
        binary=(a.build/('dizzass-noio-'+arch)).resolve(); audit=inspect(binary)
        for cpu in cpus:
            for mode,args,expected in [('selftest',[],0),('help',['--help'],0),('reject',['--mine'],64)]:
                cmd=[qemu,'-cpu',cpu,'-strace',str(binary),*args]
                p=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,timeout=10)
                stem=arch+'-'+cpu+'-'+mode
                (a.out/(stem+'.stdout')).write_text(p.stdout);(a.out/(stem+'.trace')).write_text(p.stderr)
                require(p.returncode==expected,'wrong exit '+stem+' '+p.stderr)
                calls=re.findall(r'^\d+ (\w+)\(',p.stderr,re.M)
                allowed={'write','uname','clock_gettime','exit'} if mode=='selftest' else {'write','exit'}
                require(set(calls)==allowed,'unexpected/missing guest syscall '+stem+' '+str(calls))
                require(all(line.split('write(',1)[1].startswith('1,') for line in p.stderr.splitlines() if re.match(r'^\d+ write\(',line)),'write not to stdout')
                if mode=='selftest':require('SELFTEST=PASS' in p.stdout and 'HARDWARE_NOT_TESTED=1' in p.stdout,'self-test missing')
                else:require('SELFTEST=PASS' not in p.stdout,'unexpected self-test path')
                results.append({'arch':arch,'cpu':cpu,'mode':mode,'exit':p.returncode,'binary_sha256':audit['sha256'],'syscalls':calls,
                    'stdout_sha256':hashlib.sha256(p.stdout.encode()).hexdigest(),'trace_sha256':hashlib.sha256(p.stderr.encode()).hexdigest()})
                (a.out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print('D01_QEMU_PASS runs='+str(len(results))+' physical_hardware=0 guest_device_syscalls=0')
if __name__=='__main__':main()

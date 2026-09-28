#!/usr/bin/env python3
"""C-01: validate the combined development tree; never start a miner/device."""
import argparse, hashlib, json, os, pathlib, re, shlex, subprocess, sys, time
ROOT=pathlib.Path(__file__).resolve().parents[2]
HERE=ROOT/'integration/consolidation'
PLAN=json.loads((HERE/'manifest.json').read_text())

def digest(data):
    return hashlib.sha1(b'blob '+str(len(data)).encode()+b'\0'+data).hexdigest()

def expected_inputs():
    entries={}
    for group in PLAN['order']:
        raw=subprocess.check_output(['git','diff','--raw','--no-abbrev',PLAN['base'],group['head']],cwd=ROOT,text=True)
        for line in raw.splitlines():
            meta,name=line.split('\t',1); fields=meta.split()
            if fields[-1]!='A' or name in entries: raise ValueError('non-additive/overlapping proposal: '+name)
            if fields[1] not in ('100644','100755'): raise ValueError('unsupported file mode: '+name)
            entries[name]=fields[3]
    return entries

def verify_tree():
    for name,blob in expected_inputs().items():
        p=ROOT/name
        if p.is_symlink() or not p.is_file(): raise ValueError('non-regular input: '+str(p))
        if digest(p.read_bytes())!=blob: raise ValueError('proposal input differs: '+name)
    dirty=subprocess.check_output(['git','diff','--name-only'],cwd=ROOT,text=True).splitlines()
    allowed={'compat/jansson-2.9/jansson_private_config.h.in','compat/jansson-2.9/test-driver'}
    if set(dirty)-allowed: raise ValueError('uncommitted source changes: '+repr(dirty))
    changed=subprocess.check_output(['git','diff','--name-only','--diff-filter=MDR',PLAN['base'],'HEAD'],cwd=ROOT,text=True)
    if changed.strip(): raise ValueError('pre-existing tracked files changed: '+changed)

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',required=True); ap.add_argument('--out',required=True)
    ap.add_argument('--no-sanitize',action='store_true',help='Functional checkpoint ONLY; not final acceptance')
    ap.add_argument('--stages',help='Comma-separated PR numbers; omitted means all')
    a=ap.parse_args(); output=pathlib.Path(a.out)
    if output.is_absolute() or '..' in output.parts or len(output.parts)<2 or output.parts[0]!='build':
        raise ValueError('output must be a fresh child of build/')
    output=ROOT/output; output.mkdir(parents=True,exist_ok=False)
    selected=set(map(int,a.stages.split(','))) if a.stages else {p['pr'] for p in PLAN['order']}
    valid={p['pr'] for p in PLAN['order']}
    if not selected or not selected<=valid: raise ValueError('unknown or empty stage selection')
    records=[]; receipt={'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
        'tree':subprocess.check_output(['git','rev-parse','HEAD^{tree}'],cwd=ROOT,text=True).strip(),
        'compiler':a.cc,'sanitizers_required':not a.no_sanitize,'selected':sorted(selected),'commands':records,'passed':False}
    env=dict(os.environ,ASAN_OPTIONS='detect_leaks=1:halt_on_error=1',UBSAN_OPTIONS='halt_on_error=1')
    def run(label,cmd,timeout=300):
        log=output/(str(len(records)).zfill(3)+'-'+label+'.log'); start=time.monotonic()
        print('C01_RUN',label,shlex.join(cmd),flush=True)
        with log.open('wb') as f:
            try: rc=subprocess.run(cmd,cwd=ROOT,env=env,stdout=f,stderr=subprocess.STDOUT,timeout=timeout).returncode
            except subprocess.TimeoutExpired: rc=124
        data=log.read_bytes(); records.append({'label':label,'argv':cmd,'exit':rc,'seconds':round(time.monotonic()-start,3),'log':log.name,'sha256':hashlib.sha256(data).hexdigest()})
        (output/'results.json').write_text(json.dumps(receipt,indent=2)+'\n')
        if rc: print(data.decode(errors='replace')[-9000:],flush=True); raise RuntimeError(label+' failed: '+str(rc))
        return data.decode(errors='replace')
    try:
        verify_tree(); run('compiler',[a.cc,'--version'])
        if not a.no_sanitize:
            probe=str(output/'cancel-probe')
            run('health-build',[a.cc,'-std=gnu11','-O1','-g','-pthread','-fsanitize=address,undefined','-fno-omit-frame-pointer',str(HERE/'cancel_probe.c'),'-o',probe])
            run('health-required',[probe],30)
        for s in PLAN['stages']:
            n=s['pr']
            if n not in selected: continue
            deps=str((output/f'deps-{n}').relative_to(ROOT))
            if s['prepare']: run(f'pr{n}-current-inputs',['python3',s['prepare'],'--out',deps,'--source-tree','.'])
            prefix=['make']+(['-f','Makefile'] if n==58 else [])+['-f',s['makefile'],'-f','integration/consolidation/current-tree.mk','CC='+a.cc]
            if s['deps_var']: prefix += [s['deps_var']+'='+deps]
            normal=prefix+[s['directory_var']+'='+str((output/f'pr{n}').relative_to(ROOT))]
            dry=run(f'pr{n}-compile-plan',normal+['-n']+s['positive'])
            # A compile plan that still uses staged C as input is not this check.
            for line in dry.splitlines():
                if line.startswith(a.cc+' '):
                    if any(x.endswith('.c') and x.startswith(deps+'/') for x in shlex.split(line)):
                        raise ValueError('staged C in positive compile plan: '+line)
            run(f'pr{n}-positive',normal+s['positive'],600)
            if s['negative']: run(f'pr{n}-mutants',normal+s['negative'],600)
            if not a.no_sanitize:
                san=prefix+[s['directory_var']+'='+str((output/f'pr{n}-san').relative_to(ROOT)),'SANITIZE=1']
                run(f'pr{n}-sanitizers',san+s['sanitized'],600)
        if 35 in selected:
            run('autotune-check',['python3','tools/audit_autotune_boundary_135.py','--check'])
            for flags in ([],['-O']): run('autotune-tests'+''.join(flags),['python3']+flags+['integration/tests/test_autotune_boundary_audit_135.py'])
        run('native-boundaries',['python3','integration/test_native_core.py'])
        verify_tree()
        receipt['passed']=True
        print('C01_FUNCTIONAL_PASS' if a.no_sanitize else 'C01_CURRENT_TREE_GROUP_PASS' if a.stages else 'C01_COMBINED_TREE_ALL_PASS',flush=True)
    finally:
        (output/'results.json').write_text(json.dumps(receipt,indent=2)+'\n')
    return 0

if __name__=='__main__':
    try: sys.exit(main())
    except (OSError,ValueError,KeyError,subprocess.SubprocessError,RuntimeError) as e:
        print('C01_FAILURE:',e,file=sys.stderr); sys.exit(1)

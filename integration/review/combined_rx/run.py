#!/usr/bin/env python3
"""R-06: build all four proposals from one tracked source tree; never fetch."""
from __future__ import annotations
import argparse,ast,hashlib,importlib.util,json,os,re,shlex,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
REL=Path('integration/review/combined_rx')
spec=importlib.util.spec_from_file_location('safe_staging',ROOT/'integration/review/rx_owner/run.py')
staging=importlib.util.module_from_spec(spec);spec.loader.exec_module(staging)
GROUPS=[('early_rx','RXQ','early-rx-test',25,'RXQ_PASS cases=25 '),
        ('rx_submit','R03','rx-submit-test',39,'R03_PASS cases=39 '),
        ('rx_owner','RO','rx-owner-test',38,'R04_PASS cases=38 '),
        ('io_lifecycle','LC','io-lifecycle-test',29,'R05_PASS cases=29 '),
        ('combined_rx','C06','combined-extra-test',66,'R06_PASS cases=66 ')]
def sha(b):return hashlib.sha256(b).hexdigest()
def controls(group):
    tree=ast.parse((ROOT/'integration/review'/group/'run.py').read_text())
    matches=[n for n in ast.walk(tree) if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='controls' for t in n.targets)]
    if len(matches)!=1:raise ValueError('ambiguous original controls: '+group)
    return ast.literal_eval(matches[0].value)
def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cc',choices=['gcc','clang','gcc-14','clang-17'],default='gcc')
    ap.add_argument('--baseline',choices=['ants2','icarus'],default='ants2')
    ap.add_argument('--out',required=True);ap.add_argument('--sanitize',action='store_true')
    ap.add_argument('--groups',default='all')
    ap.add_argument('--mutants',action='store_true');a=ap.parse_args()
    if a.sanitize and a.mutants:ap.error('separate positive-sanitizer and semantic-mutation runs')
    groups=GROUPS if a.groups=='all' else [g for g in GROUPS if g[0] in a.groups.split(',')]
    if not groups or (a.groups!='all' and {g[0] for g in groups}!=set(a.groups.split(','))):ap.error('unknown group')
    report={'status':'FAIL','commands':[],'suites':{},'mutants':[], 'current_source_only':True,
        'sanitized_direct_units':a.sanitize,'support_objects_sanitized':False,'physical_asic':False,
        'external_network':False,'baseline':a.baseline};out=None
    try:
        head=staging.git('rev-parse','HEAD').decode().strip()
        names=staging.git('ls-files','-z').decode().strip('\0').split('\0')
        origins=json.loads((ROOT/REL/'manifest.json').read_text())
        for e in origins['inputs']:staging.verify(staging.regular(ROOT,e['path']),e)
        # All relevant tracked bytes must match HEAD; no implicit workspace overlay.
        tracked={}
        for name in names:
            if name.endswith(('.c','.h','.mk','.py','.json')) or name=='Makefile.am':
                data=staging.git('show',head+':'+name)
                if data!=staging.regular(ROOT,name):raise ValueError('dirty source: '+name)
                tracked[name]=sha(data)
        out=staging.output(a.out);src=out/'source';logs=out/'logs';logs.mkdir()
        staging.extract(staging.git('archive','--format=tar',head),src)
        report.update(source_head=head,source_tree=staging.git('rev-parse',head+'^{tree}').decode().strip(),origins=origins,source_hashes=tracked)
        def run(label,argv,allowed=(0,),timeout=240):
            entry={'stage':label,'argv':argv,'returncode':None};report['commands'].append(entry)
            p=logs/(label+'.log');start=time.monotonic()
            try:
                with p.open('xb') as f:
                    result=subprocess.run(argv,cwd=src,stdout=f,stderr=subprocess.STDOUT,timeout=timeout,
                        env={**os.environ,'ASAN_OPTIONS':'detect_leaks=1:halt_on_error=1','UBSAN_OPTIONS':'halt_on_error=1','PYTHONDONTWRITEBYTECODE':'1'})
                entry['returncode']=result.returncode
            finally:entry.update(log=str(p.relative_to(out)),sha256=sha(p.read_bytes()),seconds=round(time.monotonic()-start,3))
            print(label+': '+str(result.returncode),flush=True)
            if result.returncode not in allowed:
                if label=='health':report['status']='BLOCKED_SANITIZER_HEALTH'
                raise RuntimeError(label+' failed; '+str(p))
            return p.read_text(errors='replace')
        report['compiler']=run('compiler',[a.cc,'--version']).splitlines()[0]
        if a.sanitize:
            run('health-build',[a.cc,'-O1','-g','-std=c11','-pthread','-fsanitize=address,undefined','-fno-omit-frame-pointer','-fno-pie','-no-pie','integration/review/native_uart_stack/evidence/cancel_probe.c','-o','health'])
            run('health',['timeout','15','./health'])
        run('autoreconf',['autoreconf','-fi'])
        cfg=['./configure','--enable-'+a.baseline,'--disable-curses','CC='+a.cc,'CFLAGS=-O2 -fcommon']
        if a.baseline=='ants2':cfg.append('--disable-libcurl')
        run('configure',cfg);run('core',['make','-j2']);run('version',['./cgminer','--version'])
        run('core-sources',['make','-s','-f','Makefile','-f','integration/native-check.mk','dizzass-core-sources'])
        run('core-symbols',['nm','--defined-only','cgminer'])
        run('core-boundary',['python3','integration/check_native_core.py','--sources',str(logs/'core-sources.log'),'--symbols',str(logs/'core-symbols.log')])
        # Allow exact generated headers from this configure/build, not stale deps.
        inputs=dict(tracked)
        for p in src.rglob('*.h'):
            name=str(p.relative_to(src))
            if not name.startswith('build/'):inputs[name]=sha(p.read_bytes())
        input_file=out/'compiler-inputs.json';input_file.write_text(json.dumps(inputs))
        record_root=out/'compile-records';record_root.mkdir()
        def make(group,prefix,directory,label):
            records=record_root/label
            cc=' '.join(shlex.quote(x) for x in [sys.executable,str(src/REL/'compile_guard.py'),'--compiler',a.cc,'--inputs',str(input_file),'--records',str(records),'--'])
            return ['make','-f','Makefile','-f','integration/review/'+group+'/suite.mk','CC='+cc,
                    prefix+'_DEPS=.',prefix+'_DIR='+directory]+(['SANITIZE=1'] if a.sanitize else [])
        for group,prefix,target,count,marker in groups:
            directory='build/combined-'+group
            text=run(group,make(group,prefix,directory,group)+[target])
            if marker not in text:raise RuntimeError('missing full suite marker: '+group)
            report['suites'][group]={'cases':count,'markers':[s for s in text.splitlines() if s.startswith(('RXQ_','R03_','R04_','R05_','R06_'))]}
            sym=run(group+'-symbols',['nm','--defined-only',directory+'/test'])
            found={s.split()[-1] for s in sym.splitlines() if s.split()}
            required={'copy_work_noffset','_free_work','fulltest','__wrap_socket','__wrap_connect','__wrap_libusb_init'}
            if group!='early_rx':required|={'submit_nonce','test_nonce'}
            if not required<=found:raise RuntimeError('native symbol guard failed: '+group+' '+str(required-found))
        # Keep prior test assertions untouched; only a non-USB opaque type shim.
        old=['make','-f','Makefile','-f','integration/native-submit.mk','CC='+a.cc]
        if a.baseline=='ants2':old.append('DIZZASS_JOBS_FLAGS=$(DIZZASS_NONCE_FLAGS) -fno-builtin-strdup -include integration/review/rx_owner/host_compat.h')
        run('native-regressions',old+['dizzass-native-submit-test'])
        run('boundary',['python3','integration/test_native_core.py'])
        if a.cc.startswith('clang') and not a.sanitize:
            run('analyzer',['make','-f','Makefile','-f','integration/review/rx_submit/suite.mk','CC='+a.cc,'R03_DEPS=.','rx-submit-analyze'])
            run('owner-analysis',[a.cc,'--analyze','-I.','-Iinclude','-std=c11','-pthread','-Xanalyzer','-analyzer-output=text','integration/native/rx_owner.c','integration/native/io_lifecycle.c'])
        if a.mutants:
            for group,prefix,_,_,_ in [g for g in groups if g[0]!='combined_rx']:
                for item in controls(group):
                    if group=='early_rx':name,path,old,new,witness=item;section=None
                    elif group=='rx_submit':name,path,section,old,new,witness=item
                    else:
                        name,old,new,witness=item;section=None
                        path='integration/native/'+('rx_owner.c' if group=='rx_owner' else 'io_lifecycle.c')
                    p=src/path;original=p.read_text();label=group+'-'+name
                    if section:
                        cut=original.index(section);before,body=original[:cut],original[cut:]
                    else:before,body='',original
                    if old not in body:raise ValueError('missing original mutation anchor '+label)
                    # R02 targets take (first occurrence); R03 scopes dispatch/admit.
                    changed=before+body.replace(old,new,1 if group in ('early_rx','rx_submit') else -1)
                    try:
                        p.write_text(changed);inputs[path]=sha(p.read_bytes());input_file.write_text(json.dumps(inputs))
                        directory='build/m-'+label
                        run(label+'-build',make(group,prefix,directory,label)+[directory+'/test'])
                        text=run(label,['timeout','60',directory+'/test'],allowed=(1,),timeout=70)
                        expected='RXQ_ASSERT' if group=='early_rx' else 'R03_ASSERT' if group=='rx_submit' else 'R04_ASSERT'
                        if expected not in text or witness not in text:raise RuntimeError('wrong semantic rejection '+label)
                        report['mutants'].append({'name':label,'witness':witness,'changed_file':path})
                    finally:p.write_text(original);inputs[path]=tracked[path];input_file.write_text(json.dumps(inputs))
        receipts=[]
        for p in sorted(record_root.rglob('*.json')):
            data=json.loads(p.read_text())
            if data.get('error') or data['returncode']!=0:raise RuntimeError('failed audited compilation '+str(p))
            receipts.append({'file':str(p.relative_to(out)),'sha256':sha(p.read_bytes()),'source_count':len(data['inputs'])})
        if not receipts:raise RuntimeError('no compiler evidence')
        report['compile_receipts']=receipts
        # Reject stale source/include paths without weakening the real compiler.
        run('guard-tests',[sys.executable,'-B',str(REL/'test_guard.py')])
        run('guard-tests-optimized',[sys.executable,'-B','-O',str(REL/'test_guard.py')])
        for e in origins['inputs']:staging.verify((src/e['path']).read_bytes(),e)
        report['status']='PASS';report['scenario_total']=sum(x['cases'] for x in report['suites'].values())
        print('R06_COMBINED_PASS scenarios='+str(report['scenario_total'])+' tracked_runtime_only=1',flush=True);return 0
    except (OSError,ValueError,KeyError,RuntimeError,subprocess.SubprocessError) as e:
        report['error']=str(e);print('R06_ERROR: '+str(e),file=sys.stderr);return 1
    finally:
        if out is not None:(out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':raise SystemExit(main())

#!/usr/bin/env python3
"""Mutate only the NEW adapter. Pinned component bodies remain byte-identical."""
import argparse,json,subprocess,sys,tempfile,shutil
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'integration/native/temperature_start_composition_135.c'
MUTANTS={
 'skip_chain_initializer':('return vn135_chain_temperature_setup_135(&view,&ops,p,mode);','(void)view;(void)ops;(void)p;(void)mode;return 0;'),
 'lost_initializer_failure':('return vn135_chain_temperature_setup_135(&view,&ops,p,mode);','(void)vn135_chain_temperature_setup_135(&view,&ops,p,mode);return 0;'),
 'wrong_mode':('return vn135_chain_temperature_setup_135(&view,&ops,p,mode);','(void)mode;return vn135_chain_temperature_setup_135(&view,&ops,p,0);'),
 'truncated_mode':('(&view,&ops,p,mode);','(&view,&ops,p,(uint8_t)mode);'),
 'constant_chip_success':('return vn135_backend_has_chip_sensor_135(g,count,p);','(void)g;(void)count;(void)p;return 1;'),
 'constant_chip_failure':('return vn135_backend_has_chip_sensor_135(g,count,p);','(void)g;(void)count;(void)p;return 0;'),
 'key_truncated':('return s->ops->reply_key(s->context);','return s->ops->reply_key(s->context)&255u;'),
 'wrong_context':('s->ops->temperature,s->context','s->ops->temperature,NULL'),
 'lost_outer_diagnostic':('if(s->ops->handlers->log)','if(0 && s->ops->handlers->log)'),
 'wrong_count_arguments':('return scalar(p,VN135_H_CHAIN_COUNT,0,0);','return scalar(p,VN135_H_CHAIN_COUNT,0,1);'),
}

def integrity_checks(dep):
    manifest=json.loads((ROOT/'integration/evidence/temperature_start_composition_135.json').read_text())
    with tempfile.TemporaryDirectory(prefix='tc135-integrity-',dir=ROOT/'build') as tmp:
        root=Path(tmp);src=root/'source';out=root/'output'
        for item in manifest['dependencies']:
            target=src/item['path'];target.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(dep/item['path'],target)
        def invoke(destination,*extra):
            return subprocess.run([sys.executable,'tools/prepare_temperature_start_composition_135.py','--out',str(destination),*extra],cwd=ROOT,capture_output=True,text=True,timeout=15)
        if invoke(out,'--source-tree',str(src)).returncode:raise RuntimeError('integrity baseline failed')
        path=manifest['dependencies'][0]['path'];(src/path).write_bytes((src/path).read_bytes()+b'\n')
        failed=invoke(root/'not-created','--source-tree',str(src))
        if not failed.returncode or 'dependency bytes mismatch' not in failed.stderr or (root/'not-created').exists():raise RuntimeError('tampered input accepted or partially copied')
        (out/path).write_bytes(b'changed')
        failed=invoke(out,'--check')
        if not failed.returncode or 'dependency bytes mismatch' not in failed.stderr:raise RuntimeError('staged tamper accepted')
        failed=invoke(ROOT/'integration')
        if not failed.returncode or 'destination must be' not in failed.stderr:raise RuntimeError('unsafe destination accepted')
    return 4

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--cc',default='cc');ap.add_argument('--deps',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args()
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=True);dep=a.deps.resolve()
    source=SOURCE.read_text();records=[]
    flags=['-I'+str(dep),'-I.','-std=c11','-O1','-Wall','-Wextra','-Wpedantic','-Werror','-fno-fast-math','-ffp-contract=off','-DVN135_GENERAL_MONITOR_135','-DVN135_MONITOR_HANDLERS_135','-DVN135_CHAIN_TEMPERATURE_SETUP_135','-DVN135_CHIP_SENSOR_CHECK_135']
    others=[str(dep/'src/backend'/name) for name in ['temperature-setup.c','chain-temperature-setup.c','chip-sensor-check.c']]+['src/backend/base.c','src/backend/temp.c']
    for name,mutation in [('baseline',None),*MUTANTS.items()]:
        candidate=source
        if mutation:
            old,new=mutation
            if candidate.count(old)!=1:raise ValueError('ambiguous mutation '+name)
            candidate=candidate.replace(old,new)
        path=out/(name+'.c');lib=out/(name+'.so');path.write_text(candidate)
        build=subprocess.run([a.cc,*flags,'-shared','-fPIC',str(path),*others,'-Wl,-z,defs','-o',str(lib)],cwd=ROOT,capture_output=True,text=True,timeout=45)
        (out/(name+'.build.log')).write_text(build.stdout+build.stderr)
        if build.returncode:raise RuntimeError((name,'BUILD_FAILURE',build.stderr))
        run=subprocess.run([sys.executable,'integration/tests/test_temperature_start_composition_135.py',str(lib),'--quick'],cwd=ROOT,capture_output=True,text=True,timeout=45)
        (out/(name+'.log')).write_text(run.stdout+run.stderr)
        if mutation:
            if run.returncode!=1 or 'SEMANTIC_MISMATCH' not in run.stderr:raise RuntimeError((name,'not semantic rejection',run.returncode,run.stderr))
        elif run.returncode or 'TEMPERATURE_START_COMPOSITION135_ORIGINAL_PASS' not in run.stdout:raise RuntimeError(('baseline failed',run.stderr))
        records.append({'name':name,'build_exit':build.returncode,'test_exit':run.returncode})
    report={'status':'PASS','rejected':len(MUTANTS),'dependency_integrity_checks':integrity_checks(dep),'records':records}
    (out/'negative.json').write_text(json.dumps(report,indent=2)+'\n');print('TEMPERATURE_START_COMPOSITION135_NEGATIVE_PASS',json.dumps(report))
if __name__=='__main__':main()

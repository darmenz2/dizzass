#!/usr/bin/env python3
"""Compiled semantic faults must disagree with cached ORIGINAL fixtures.
Crashes, timeout or compilation failures never count as successful detection.
"""
import argparse,os,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
SOURCE=ROOT/'src/backend/work-gen/template-publication.c'
def mutants(s):
    out={}
    def add(name,old,new):
        assert s.count(old)==1,(name,s.count(old));out[name]=s.replace(old,new)
    add('skip_lock','(void)o->lock(context, v->mutex);','/* omitted lock */')
    add('abort_lock_error','(void)o->lock(context, v->mutex);','if (o->lock(context, v->mutex)) return;')
    add('wrong_lock','o->lock(context, v->mutex)','o->lock(context, v->condition)')
    add('early_ready','    o->clone(context, v->destination, v->source);\n    *v->ready = 1;','    *v->ready = 1;\n    o->clone(context, v->destination, v->source);')
    add('skip_ready','    *v->ready = 1;','    *v->ready = 0;')
    add('cached_source_flag','    if (*v->source_reset)','    if (saved_flag)')
    out['cached_source_flag']=out['cached_source_flag'].replace('    void *allocation;','    void *allocation;\n    const uint8_t saved_flag = *v->source_reset;')
    add('exact_one_reset','if (*v->source_reset)','if (*v->source_reset == 1)')
    add('unconditional_reset','if (*v->source_reset)','if (1)')
    add('skip_reset','        o->reset(context);','        (void)context;')
    add('skip_clone','    o->clone(context, v->destination, v->source);','    /* omitted clone */')
    add('swap_clone_objects','o->clone(context, v->destination, v->source);','o->clone(context, (void *)v->source, v->destination);')
    add('broadcast_after_unlock','    (void)o->broadcast(context, v->condition);\n    (void)o->unlock(context, v->mutex);','    (void)o->unlock(context, v->mutex);\n    (void)o->broadcast(context, v->condition);')
    add('wrong_condition','o->broadcast(context, v->condition)','o->broadcast(context, v->mutex)')
    add('skip_unlock','    (void)o->unlock(context, v->mutex);','    /* omitted unlock */')
    for slot in ('branches','coinbase','text'):
        # Locate the unique block with this field.
        old=f'''    allocation = *v->{slot};
    if (allocation) {{
        o->release(context, allocation);
        *v->{slot} = 0;
    }}'''
        add('clear_before_free_'+slot,old,old.replace('        o->release(context, allocation);\n        *v->'+slot+' = 0;', '        *v->'+slot+' = 0;\n        o->release(context, allocation);'))
        add('skip_clear_'+slot,old,old.replace('        *v->'+slot+' = 0;','        /* omitted clear */'))
    for slot in ('coinbase','text'):
        add('cached_'+slot,'    allocation = *v->'+slot+';','    allocation = saved_slot;')
        out['cached_'+slot]=out['cached_'+slot].replace('    void *allocation;','    void *allocation;\n    void *saved_slot = *v->'+slot+';')
    return out
def main():
    p=argparse.ArgumentParser();p.add_argument('directory');p.add_argument('--cc',required=True);p.add_argument('--baseline',required=True);a=p.parse_args()
    directory=Path(a.directory).resolve();directory.mkdir(parents=True,exist_ok=True)
    oracle=ROOT/'integration/tests/test_template_publication_135.py';fixture=directory/'original-fixtures.json'
    env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1')
    def check(command,name,semantic=False):
        r=subprocess.run(list(map(str,command)),cwd=ROOT,env=env,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=90)
        (directory/(name+'.log')).write_bytes(r.stdout)
        if semantic:assert r.returncode>0 and b'SEMANTIC_MISMATCH' in r.stdout and b'TEMPLATE_PUBLICATION_ORIGINAL_PASS' not in r.stdout,(name,r.returncode)
        else:assert r.returncode==0,(name,r.returncode,r.stdout[-2000:])
    check([sys.executable,oracle,Path(a.baseline).resolve(),'--fixtures',fixture],'baseline')
    variants=mutants(SOURCE.read_text())
    for name,code in variants.items():
        src=directory/(name+'.c');so=directory/(name+'.so');src.write_text(code)
        check([a.cc,'-I.','-Iinclude','-std=c11','-Wall','-Wextra','-Wpedantic','-Werror','-O2','-shared','-fPIC',src,
            'reconstruction/support/record_fifo.c','reconstruction/support/nonce_fifo.c','-Wl,-z,defs','-o',so],name+'-build')
        check([sys.executable,oracle,so,'--fixtures',fixture],name,True)
    print(f'TEMPLATE_PUBLICATION_NEGATIVE_PASS rejected={len(variants)} baseline=pass')
if __name__=='__main__':main()

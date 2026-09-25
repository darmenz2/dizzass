#!/usr/bin/env python3
"""Local file-operation tests only, NOT an upstream cgminer build test."""
from pathlib import Path
import hashlib,json,subprocess,sys,tempfile
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT/'tools'))
from assemble_on_cgminer import assemble,git,blob_sha

def run(*args):subprocess.run(args,check=True,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
with tempfile.TemporaryDirectory(prefix='vn135-assembler-test-') as temp:
    temp=Path(temp);source=temp/'fixture-base';source.mkdir()
    (source/'Makefile.am').write_text('cgminer_SOURCES := cgminer.c\n')
    (source/'cgminer.c').write_text('/* FILE-COPY FIXTURE ONLY, not cgminer code. */\n')
    (source/'COPYING').write_text('Fixture license marker.\n')
    run('git','init','--quiet',str(source));run('git','-C',str(source),'add','.')
    run('git','-C',str(source),'-c','user.name=Fixture','-c','user.email=fixture@example.invalid','commit','--quiet','-m','file-operation fixture')
    lock=dict(repository='local test fixture',commit=git(source,'rev-parse','HEAD'),tree=git(source,'rev-parse','HEAD^{tree}'),makefile_am_git_blob=blob_sha((source/'Makefile.am').read_bytes()))
    output=temp/'assembled'
    assemble(source,output,lock)
    assert (source/'Makefile.am').read_text()=='cgminer_SOURCES := cgminer.c\n'
    assert (output/'cgminer.c').read_bytes()==(source/'cgminer.c').read_bytes()
    assert (output/'COPYING').read_bytes()==(source/'COPYING').read_bytes()
    assert 'cgminer-overlay.am' in (output/'Makefile.am').read_text()
    assert (output/'reconstruction/overlay-files.json').is_file()
    assert git(source,'status','--porcelain')==''
    try:assemble(source,output,lock)
    except ValueError:pass
    else:raise AssertionError('Existing destination not protected')
    # Dirty source must not be silently ignored.
    (source/'cgminer.c').write_text('local change\n')
    try:assemble(source,temp/'dirty-output',lock)
    except ValueError:pass
    else:raise AssertionError('Dirty source not rejected')
    assert not (temp/'dirty-output').exists()
print('assembler file-operation tests: PASS; actual upstream download/build NOT tested')

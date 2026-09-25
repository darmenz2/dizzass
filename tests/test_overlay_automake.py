#!/usr/bin/env python3
"""Build-name integration fixture, NOT a build of upstream or vendor cgminer.
Exercises all recovered sources alongside an independent root cgminer.c.
All commands operate inside an automatically removed temporary directory.
"""
from pathlib import Path
import hashlib,json,shutil,subprocess,tempfile
ROOT=Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='vn135-automake-fixture-') as tmp:
    tree=Path(tmp)/'source'
    shutil.copytree(ROOT,tree,ignore=shutil.ignore_patterns('build','__pycache__','.git'))
    (tree/'configure.ac').write_text('AC_INIT([vn135-object-fixture], [1.0])\nAM_INIT_AUTOMAKE([foreign])\nAC_PROG_CC\nAC_CONFIG_FILES([Makefile])\nAC_OUTPUT\n')
    (tree/'Makefile.am').write_text('AM_CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -Werror\nbin_PROGRAMS = cgminer\ncgminer_CPPFLAGS =\ncgminer_SOURCES = cgminer.c\nEXTRA_DIST =\ninclude $(top_srcdir)/reconstruction/cgminer-overlay.am\n')
    (tree/'cgminer.c').write_text('''/* TEST FIXTURE ONLY. Not original or reconstructed cgminer main. */
#include "xminer/recovery/nonce_verify.h"
#include <stdio.h>
int main(void){unsigned char h[80]={0},d[32],t[32]={0};
if(vn135_sha256d_header80(h,d)!=0)return 1;
if(vn135_target256_check_le(d,d)!=1)return 1;
if(vn135_target256_check_le(d,t)!=0)return 1;
puts("Automake distinct-object fixture PASS; not upstream cgminer");return 0;}
''')
    records=[]
    def run(args,expect=0):
        p=subprocess.run(args,cwd=tree,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
        records.append({'command':args,'returncode':p.returncode,'output':p.stdout})
        if expect==0:assert p.returncode==0,p.stdout
        else:assert p.returncode!=0,p.stdout
        return p.stdout
    overlay=tree/'reconstruction/cgminer-overlay.am';good=overlay.read_text()
    assert 'AUTOMAKE_OPTIONS = subdir-objects' in good
    overlay.write_text(good.replace('AUTOMAKE_OPTIONS = subdir-objects\n',''))
    failure=run(['autoreconf','-fi'],expect=1)
    assert 'cgminer-cgminer.$(OBJEXT)' in failure and 'created' in failure,failure
    overlay.write_text(good)
    run(['autoreconf','-fi']);run(['./configure']);run(['make','-j2'])
    assert (tree/'cgminer-cgminer.o').exists()
    assert (tree/'src/frontend/cgminer-cgminer.o').exists()
    run(['./cgminer'])
    result={'status':'PASS','without_subdir_objects_collision_reproduced':True,
            'with_subdir_objects_all_recovered_modules_linked':True,
            'actual_upstream_cgminer_tested':False,'fixture_only':True,'commands':records}
    (ROOT/'build/stage8-automake-fixture.json').write_text(json.dumps(result,indent=2)+'\n')
    print('Automake fixture PASS: reproduced basename collision and fixed it with subdir-objects; upstream cgminer NOT built.')

#!/usr/bin/env python3
"""Compile isolated safe host mutants; require an ordinary assertion exit 1."""
import argparse,json,pathlib,subprocess,tempfile
HERE=pathlib.Path(__file__).resolve().parents[1]
ROOT=HERE.parents[3]
SOURCE=ROOT/'libbitmain/src/transport-dispatch.c'

def variants(s):
 old='    *v->shared_send_method = selected;\n    *v->common_method = UINT32_C(0xd253c);'
 return {
 'subtype-only-one':s.replace('subtype != 0','subtype == 1'),
 'subtype-signed-positive':s.replace('subtype != 0','(int32_t)subtype > 0'),
 'subtype-all-platforms':s.replace('platform == 0 && subtype != 0','subtype != 0'),
 'wrong-aml-send':s.replace('UINT32_C(0x117f7c)','UINT32_C(0x117f80)'),
 'wrong-chip-four':s.replace('UINT32_C(0xe1450)','UINT32_C(0xe1454)'),
 'chip-first-rejection':s.replace('    uint32_t selected = send[platform];','    if (chip >= sizeof(initialize) / sizeof(initialize[0])) return -1;\n    uint32_t selected = send[platform];'),
 'omit-common-store':s.replace('*v->common_method = UINT32_C(0xd253c);','(void)v->common_method;'),
 'reverse-store-order':s.replace(old,'    *v->common_method = UINT32_C(0xd253c);\n    *v->shared_send_method = selected;'),
 'normalize-result':s.replace('return o->initialize(context, initialize[chip], v->chip_methods);','return o->initialize(context, initialize[chip], v->chip_methods) == 0 ? 0 : -1;'),
 'duplicate-constructor':s.replace('    return o->initialize(context, initialize[chip], v->chip_methods);','    (void)o->initialize(context, initialize[chip], v->chip_methods);\n    return o->initialize(context, initialize[chip], v->chip_methods);'),
 'clear-on-refusal':s.replace('    return o->initialize(context, initialize[chip], v->chip_methods);','    int32_t status = o->initialize(context, initialize[chip], v->chip_methods);\n    if (status != 0) *v->shared_send_method = 0;\n    return status;'),
 'wrong-output-identity':s.replace('initialize[chip], v->chip_methods','initialize[chip], context'),
 'reject-valid-chip-seven':s.replace('chip >= sizeof(initialize) / sizeof(initialize[0])','chip >= (sizeof(initialize) / sizeof(initialize[0])) - 1'),
 'high-platform-zero-result':s.replace('    if (platform >= sizeof(send)', '    if ((int32_t)platform < 0) return 0;\n    if (platform >= sizeof(send)'),
 'high-chip-zero-result':s.replace('    if (chip >= sizeof(initialize)', '    if ((int32_t)chip < 0) return 0;\n    if (chip >= sizeof(initialize)'),
 }
def main():
 p=argparse.ArgumentParser();p.add_argument('--cc',default='cc');a=p.parse_args()
 text=SOURCE.read_text();mutants=variants(text);reports=[]
 with tempfile.TemporaryDirectory(prefix='transport-init-controls-') as d:
  d=pathlib.Path(d)
  for name,source in [('pristine',text),*mutants.items()]:
   if name!='pristine' and source==text:raise RuntimeError('ineffective mutation '+name)
   c=d/(name+'.c');exe=d/name;c.write_text(source)
   cmd=[a.cc,'-std=c11','-O2','-Wall','-Wextra','-Werror','-Wconversion','-Wshadow','-pedantic','-DVN135_TRANSPORT_INITIALIZE_135','-I'+str(ROOT),str(c),str(HERE/'tests/test_transport_initialize.c'),'-o',str(exe)]
   build=subprocess.run(cmd,text=True,capture_output=True,timeout=30)
   if build.returncode:raise RuntimeError('compile failure is not detection: '+name+'\n'+build.stderr)
   run=subprocess.run([str(exe)],text=True,capture_output=True,timeout=10)
   expected=0 if name=='pristine' else 1
   marker='PASS transport initializer:' if name=='pristine' else 'FAIL line '
   if run.returncode!=expected or marker not in run.stdout+run.stderr:raise RuntimeError('wrong detection '+name+' '+repr(run))
   reports.append({'name':name,'compile_exit':0,'test_exit':run.returncode,'witness':(run.stdout+run.stderr).strip()})
 print(json.dumps({'schema':1,'compiler':a.cc,'positive':1,'semantic_controls':len(mutants),'results':reports},indent=2))
if __name__=='__main__':main()

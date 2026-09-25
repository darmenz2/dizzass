#!/usr/bin/env python3
from pathlib import Path
import json,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools'))
manifest=json.loads((ROOT/'evidence/source-tree.json').read_text())
assert manifest['complete_vendor_file_list'] is False
assert len(manifest['modules'])==46
assert manifest['pending_modules']==39
assert manifest['partial_modules']==7
for module in manifest['modules']:
    text=(ROOT/module['path']).read_text()
    if module['status']=='pending-not-implemented':
        assert '#error "VN135 pending module:' in text
        assert 'return 0;' not in text
assert not (ROOT/'src/backend/work_gen').exists(),'Wrong work-gen spelling'
assert (ROOT/'src/backend/work-gen/work-gen.c').is_file()
assert not list(ROOT.rglob('recovered_stubs.c'))
assert not list(ROOT.rglob('cgminer_reconstructed_full.c'))
for name in ('src/frontend/cgminer.c','src/backend/work-gen/work-gen.c','libbitmain/src/uart.c','libbitmain/src/reg_cache.c','libbitmain/src/pll.c','libbitmain/src/aml/chip.c','libbitmain/src/chip/chip1398.c'):
    assert 'VN135 pending module:' not in (ROOT/name).read_text()
print('module tree and no fake stubs: PASS')

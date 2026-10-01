#!/usr/bin/env python3
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

HERE=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('verify_bm1368',HERE/'verify_evidence.py')
verify=importlib.util.module_from_spec(spec);spec.loader.exec_module(verify)

class Evidence(unittest.TestCase):
    def test_pristine(self):
        self.assertEqual(len(verify.check(HERE/'evidence')),2)
    def corrupt(self,edit):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d)/'evidence';shutil.copytree(HERE/'evidence',root)
            p=root/'constructor-proof.json';data=json.loads(p.read_text())
            edit(data,root);p.write_text(json.dumps(data))
            with self.assertRaises(ValueError):verify.check(root)

def change(key,value):
    return lambda p,r:p.__setitem__(key,value)
def change_row(key,value):
    return lambda p,r:p['sources']['cgminer']['method_words'][0].__setitem__(key,value)
def change_source(key,value):
    return lambda p,r:p['sources']['hwscan'].__setitem__(key,value)
def alter_artifact(which):
    def edit(p,r):
        path=r/'cgminer'/which
        if which.endswith('.asm'):path.write_text(path.read_text()+'; invented line\n')
        else:
            m=json.loads(path.read_text());b=bytearray.fromhex(m['bytes_hex']);b[0]^=4
            m['bytes_hex']=b.hex();m['sha256']=hashlib.sha256(b).hexdigest();path.write_text(json.dumps(m))
        p['sources']['cgminer']['artifact_sha256'][which]=hashlib.sha256(path.read_bytes()).hexdigest()
    return edit

CONTROLS={
 'execution_claim':change('original_executed',True),
 'undersized_output':change('output_extent_bytes',220),
 'wrong_preserved_slot':change('untouched_offsets',[0,20]),
 'reverse_stores':change('ordered_store_offsets',list(reversed(verify.STORE_ORDER))),
 'wrong_source_hash':change_source('source_sha256','0'*64),
 'wrong_source_size':change_source('source_bytes',4883212),
 'wrong_entry':change_source('entry','0xf1d2c'),
 'wrong_destination':change_row('output_offset',216),
 'wrong_literal_index':change_row('literal_index',1),
 'wrong_load_edge':change_row('load_instruction','0xe145c'),
 'wrong_literal_word':change_row('literal_word','0'),
 'wrong_got_address':change_row('got_address','0x5df454'),
 'wrong_identity':change_row('method_identity','0xe4a70'),
 'wrong_got_bytes':change_row('got_bytes','704a0e00'),
 'wrong_store_pc':change_row('store_instruction','0xe14a4'),
 'wrong_store_order':change_row('store_order',2),
 'changed_code_with_updated_receipt':alter_artifact('body.json'),
 'changed_literals_with_updated_receipt':alter_artifact('literals.json'),
 'invented_assembly_with_updated_digest':alter_artifact('body.asm'),
}
for label,edit in CONTROLS.items():
    def test(self,edit=edit):self.corrupt(edit)
    setattr(Evidence,'test_reject_'+label,test)

if __name__=='__main__':unittest.main()

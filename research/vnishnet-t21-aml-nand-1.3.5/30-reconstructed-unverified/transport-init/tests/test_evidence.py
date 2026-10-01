"""Synthetic frozen-data corruption controls, never firmware behavior tests."""
import importlib.util,json,pathlib,shutil,tempfile,unittest
HERE=pathlib.Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('verify_transport_init',HERE/'verify_evidence.py');v=importlib.util.module_from_spec(spec);spec.loader.exec_module(v)
class EvidenceTests(unittest.TestCase):
 def setUp(self):
  self.tmp=tempfile.TemporaryDirectory(prefix='transport-init-evidence-');self.root=pathlib.Path(self.tmp.name);self.d=self.root/'report'
  shutil.copytree(HERE,self.d,ignore=shutil.ignore_patterns('build','__pycache__'))
  target=self.root/'source/libbitmain/src';target.mkdir(parents=True);shutil.copyfile(v.ROOT/'libbitmain/src/transport-dispatch.c',target/'transport-dispatch.c')
 def tearDown(self):self.tmp.cleanup()
 def check(self):return v.verify(self.d,self.root/'source')
 def edit_proof(self,f):
  p=self.d/'evidence/dispatch-proof.json';j=json.loads(p.read_text());f(j);p.write_text(json.dumps(j))
 def test_pristine(self):self.assertEqual(self.check()['static_windows'],32)
 def test_source_hash(self):
  self.edit_proof(lambda j:j['sources']['cgminer'].__setitem__('sha256','0'*64))
  with self.assertRaises(ValueError):self.check()
 def test_execution_flag(self):
  self.edit_proof(lambda j:j.__setitem__('firmware_executed',True))
  with self.assertRaises(ValueError):self.check()
 def test_artifact_bytes(self):
  p=self.d/'evidence/cgminer/entry.asm';p.write_text(p.read_text().replace('704c2de9','704c2de8',1))
  with self.assertRaises(ValueError):self.check()
 def test_plan_start(self):
  p=self.d/'evidence/cgminer/plan.json';j=json.loads(p.read_text());j['ranges'][0]['start']='0xd21e0';p.write_text(json.dumps(j))
  with self.assertRaises(ValueError):self.check()
 def test_fixed_word(self):
  self.edit_proof(lambda j:j['sources']['cgminer']['fixed_words'].__setitem__('0xd21ec','0xe35c0005'))
  with self.assertRaises(ValueError):self.check()
 def test_got_literal(self):
  self.edit_proof(lambda j:j['sources']['hwscan']['got'][0].__setitem__('literal_word','0'))
  with self.assertRaises(ValueError):self.check()
 def test_got_value(self):
  self.edit_proof(lambda j:j['sources']['hwscan']['got'][0].__setitem__('value','0'))
  with self.assertRaises(ValueError):self.check()
 def test_jump_destination(self):
  self.edit_proof(lambda j:j['sources']['cgminer']['jump_tables']['chips']['targets'].__setitem__(4,'0'))
  with self.assertRaises(ValueError):self.check()
 def test_edge_target(self):
  self.edit_proof(lambda j:j['sources']['cgminer']['chip_initializers'][4].__setitem__('target','0xe1454'))
  with self.assertRaises(ValueError):self.check()
 def test_chip_number(self):
  self.edit_proof(lambda j:j['sources']['cgminer']['chip_initializers'][4].__setitem__('chip_selector',5))
  with self.assertRaises(ValueError):self.check()
 def test_store_order(self):
  self.edit_proof(lambda j:j['sources']['hwscan']['ordered_stores'].reverse())
  with self.assertRaises(ValueError):self.check()
 def test_common_identity(self):
  self.edit_proof(lambda j:j['sources']['cgminer']['ordered_stores'][1].__setitem__('value','0'))
  with self.assertRaises(ValueError):self.check()
 def test_missing_artifact(self):
  self.edit_proof(lambda j:j['sources']['hwscan']['artifact_sha256'].pop('entry.asm'))
  with self.assertRaises(ValueError):self.check()
 def test_old_source_changed(self):
  p=self.root/'source/libbitmain/src/transport-dispatch.c';p.write_text('changed'+p.read_text())
  with self.assertRaises(ValueError):self.check()
if __name__=='__main__':unittest.main()

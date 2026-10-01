#!/usr/bin/env python3
"""Negative controls for static evidence; no vendor program is executed.

Run directly with the same Python used for verify_evidence.py. Tests also run
with python -O. --root ROOT enables additional actual dependency-file controls.
"""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(HERE))
import verify_evidence as verifier

SOURCE_ROOT=None
if '--root' in sys.argv:
    index=sys.argv.index('--root')
    SOURCE_ROOT=Path(sys.argv[index+1]).resolve()
    del sys.argv[index:index+2]
else:
    for candidate in (Path.cwd(),*HERE.parents):
        if (candidate/'integration/bm1368_control.c').is_file():
            SOURCE_ROOT=candidate
            break


class EvidenceControls(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(prefix='common-read-static-')
        self.addCleanup(self.temp.cleanup)
        self.folder=Path(self.temp.name)/'evidence'
        # Copy only the immutable evidence and expected assembly, never runtime
        # files or an original ELF. Test mutations cannot touch real inputs.
        self.folder.mkdir()
        for name in ('static-pins.json','static-witnesses.json','static-supplement.json','source-baseline.json'):
            shutil.copyfile(HERE/name,self.folder/name)
        for name in ('cgminer','hwscan'):
            shutil.copytree(HERE/name,self.folder/name)
        self.proof=json.loads((self.folder/'static-witnesses.json').read_text())

    def write_proof(self):
        (self.folder/'static-witnesses.json').write_text(json.dumps(self.proof))

    def rejected(self,pattern):
        self.write_proof()
        with self.assertRaisesRegex(verifier.EvidenceError,pattern):
            verifier.verify(self.folder)

    def change_word(self,name,kind,address,replacement):
        entry=self.proof['sources'][name]['ranges'][kind]
        data=bytearray.fromhex(entry['bytes_hex'])
        offset=address-int(entry['start'],0)
        data[offset:offset+4]=bytes.fromhex(replacement)
        entry['bytes_hex']=data.hex()

    def test_complete_self_contained_snapshot(self):
        result=verifier.verify(self.folder)
        self.assertEqual(result['status'],'PASS')
        self.assertEqual(result['decoded_instruction_counts']['cgminer']['body'],82)
        self.assertEqual(result['decoded_instruction_counts']['hwscan']['body'],48)
        self.assertEqual(result['parity_identities_checked'],7)
        self.assertFalse(result['original_executed'])
        self.assertEqual(result['original_image_selections_checked'],{})

    def test_fixed_pins_cannot_be_replaced_by_consistent_metadata(self):
        entry=self.proof['sources']['cgminer']['ranges']['body']
        self.change_word('cgminer','body',0xd2558,'0000a0e1')
        entry['sha256']=verifier.sha256(bytes.fromhex(entry['bytes_hex']))
        self.rejected('fixed sha256 differs')

    def test_packet_broadcast_bit_zero_word(self):
        self.change_word('cgminer','body',0xd2558,'1102c5e7')
        self.rejected('fixed byte hash differs')

    def test_optional_address_is_word_load_not_byte_load(self):
        self.change_word('hwscan','body',0xea814,'0400d215')
        self.rejected('fixed byte hash differs')

    def test_register_store_byte_offset(self):
        self.change_word('cgminer','body',0xd2570,'1230cde5')
        self.rejected('fixed byte hash differs')

    def test_send_length_is_five(self):
        self.change_word('hwscan','body',0xea834,'0420a0e3')
        self.rejected('fixed byte hash differs')

    def test_crc_bit_count_is_32(self):
        self.change_word('cgminer','body',0xd2574,'2810a0e3')
        self.rejected('fixed byte hash differs')

    def test_minus_one_return_cannot_be_changed_to_zero(self):
        self.change_word('hwscan','body',0xea894,'0050a0e3')
        self.rejected('fixed byte hash differs')

    def test_current_index_load_offset(self):
        self.change_word('cgminer','body',0xd25fc,'143094e5')
        self.rejected('fixed byte hash differs')

    def test_logger_line_is_103(self):
        self.change_word('hwscan','body',0xea88c,'6830a0e3')
        self.rejected('fixed byte hash differs')

    def test_dead_duplicate_is_preserved(self):
        self.change_word('cgminer','body',0xd2670,'000000ea')
        self.rejected('fixed byte hash differs')

    def test_parity_guard_bit_is_pinned(self):
        self.change_word('cgminer','body',0xd25d4,'020010e3')
        self.rejected('fixed byte hash differs')

    def test_crc_final_return_is_included(self):
        entry=self.proof['sources']['cgminer']['ranges']['crc_body']
        entry['bytes_hex']=entry['bytes_hex'][:-8]
        self.rejected('byte length differs')

    def test_crc_recurrence_word_is_pinned(self):
        self.change_word('hwscan','crc_body',0xfcc94,'075023e0')
        self.rejected('fixed byte hash differs')

    def test_literal_pool_is_pinned(self):
        self.change_word('cgminer','literals',0xd2698,'af7a5100')
        self.rejected('fixed byte hash differs')

    def test_code_data_boundary_is_pinned(self):
        self.proof['sources']['cgminer']['ranges']['body']['end_exclusive']='0x000d2688'
        self.rejected('fixed end_exclusive differs')

    def test_data_is_not_counted_as_code(self):
        self.proof['sources']['hwscan']['ranges']['literals']['instruction_count']=5
        self.rejected('field set differs')

    def test_instruction_count_is_pinned(self):
        self.proof['sources']['cgminer']['ranges']['body']['instruction_count']=81
        self.rejected('fixed instruction_count differs')

    def test_missing_branch_metadata_rejected(self):
        self.proof['sources']['hwscan']['ranges']['body']['branch_witnesses'].pop()
        self.rejected('raw branch metadata differs')

    def test_branch_target_metadata_rejected(self):
        self.proof['sources']['cgminer']['ranges']['body']['branch_witnesses'][2]['instruction']='beq #0xd2640'
        self.rejected('raw branch metadata differs')

    def test_literal_edge_target_rejected(self):
        self.proof['sources']['cgminer']['literal_edges'][5]['target']='0x005ea1b8'
        self.rejected('literal edge metadata differs')

    def test_literal_use_register_rejected(self):
        self.change_word('cgminer','body',0xd2600,'02208fe0')
        self.rejected('fixed byte hash differs')

    def test_got_current_storage_word_rejected(self):
        self.proof['sources']['hwscan']['literal_edges'][0]['file_got_word']='0x004e4c98'
        self.rejected('literal edge metadata differs')

    def test_old_plain_hwscan_literal_rejected(self):
        self.proof['sources']['hwscan']['strings'][0]['raw_hex']='65726976657200'
        self.rejected('fixed string witness differs')

    def test_wrong_diagnostic_path_rejected(self):
        self.proof['sources']['cgminer']['strings'][1]['decoded']='/tmp/build/libbitmain/src/chip.c'
        self.rejected('fixed string witness differs')

    def test_get_status_format_must_not_be_renamed(self):
        self.proof['sources']['hwscan']['strings'][3]['decoded']='chain#%d - failed to send READ_REGISTER command'
        self.rejected('fixed string witness differs')

    def test_string_length_includes_nul(self):
        self.proof['sources']['cgminer']['strings'][3]['size']=44
        self.rejected('fixed string witness differs')

    def test_xor_key_is_immutable(self):
        self.proof['sources']['cgminer']['strings'][0]['xor_key']=0x3a
        self.rejected('fixed string witness differs')

    def test_initializer_key_instruction_rejected(self):
        self.change_word('cgminer','string_initializer_body',0xd2d7c,'1a2022e2')
        self.rejected('fixed byte hash differs')

    def test_initializer_length_instruction_rejected(self):
        self.change_word('cgminer','string_initializer_body',0xd2cc8,'250050e3')
        self.rejected('fixed byte hash differs')

    def test_initializer_registration_slot_rejected(self):
        self.proof['sources']['cgminer']['initializer_registration']['slot_address']='0x005dafd8'
        self.rejected('initializer registration differs')

    def test_initializer_pointer_rejected(self):
        self.proof['sources']['cgminer']['initializer_registration']['pointer']='0x000d2c10'
        self.rejected('initializer registration differs')

    def test_section_name_metadata_rejected(self):
        path=self.folder/'static-supplement.json'
        sup=json.loads(path.read_text())
        data=sup['sources']['cgminer']['file_slices'][-1]
        raw=bytes.fromhex(data['bytes_hex']).replace(b'.init_array',b'.fake_array')
        data['bytes_hex']=raw.hex();data['sha256']=verifier.sha256(raw)
        path.write_text(json.dumps(sup))
        self.rejected('ELF section name differs')

    def test_unwind_boundary_rejected(self):
        self.proof['sources']['cgminer']['ehabi'][0]['next_unwind_start']='0x000d2684'
        self.rejected('unwind metadata differs')

    def test_added_raw_metadata_is_rejected(self):
        self.proof['unexpected']='unreviewed claim'
        self.rejected('field set differs')

    def test_source_image_hash_is_immutable(self):
        self.proof['sources']['hwscan']['source_sha256']='0'*64
        self.rejected('source image identity differs')

    def test_source_image_size_is_immutable(self):
        self.proof['sources']['cgminer']['source_bytes']-=1
        self.rejected('source image identity differs')

    def test_original_execution_claim_rejected(self):
        self.proof['original_executed']=True
        self.rejected('static-only provenance flags differ')

    def test_assembly_is_re_rendered(self):
        path=self.folder/'cgminer/body.asm'
        path.write_text(path.read_text().replace('bfi','bfc',1))
        self.rejected('assembly re-render differs')

    def test_static_pin_manifest_is_anchored(self):
        path=self.folder/'static-pins.json'
        path.write_bytes(path.read_bytes()+b'\n')
        self.rejected('immutable static pin file differs')

    def test_base_provenance_receipt_is_anchored(self):
        path=self.folder/'source-baseline.json'
        receipt=json.loads(path.read_text());receipt['base_commit']='0'*40
        path.write_text(json.dumps(receipt))
        self.rejected('source baseline receipt pin differs')

    def test_active_dependency_receipt_hash_cannot_be_replaced(self):
        path=self.folder/'source-baseline.json'
        receipt=json.loads(path.read_text());receipt['files'][1]['sha256']='0'*64
        path.write_text(json.dumps(receipt))
        self.rejected('source baseline receipt pin differs')

    def test_optimized_python_rejects_corruption(self):
        self.change_word('cgminer','body',0xd258c,'0620a0e3')
        self.write_proof()
        command=[sys.executable,'-O',str(HERE/'verify_evidence.py'),'--evidence-dir',str(self.folder)]
        result=subprocess.run(command,capture_output=True,text=True,check=False)
        self.assertEqual(result.returncode,1)
        self.assertIn('fixed byte hash differs',result.stderr)

    def test_optional_original_mode_rejects_fake_elf(self):
        path=Path(self.temp.name)/'wrong.elf';path.write_bytes(b'\x7fELF'+b'\0'*48)
        with self.assertRaisesRegex(verifier.EvidenceError,'original image hash/size differs'):
            verifier.verify(self.folder,originals={'cgminer':path})

    def test_arm_branch_address_arithmetic(self):
        self.assertEqual(verifier.direct_target(0xeb009661,0xd2584),0xf7f10)
        self.assertEqual(verifier.direct_target(0xeaffffdb,0xd2674),0xd25e8)
        with self.assertRaisesRegex(verifier.EvidenceError,'not an immediate'):
            verifier.direct_target(0xe12fff33,0xd25a4)

    def dependency_copy(self):
        if SOURCE_ROOT is None:
            self.skipTest('use --root ROOT to exercise actual unchanged source file controls')
        root=Path(self.temp.name)/'source'
        for entry in json.loads((HERE/'source-baseline.json').read_text())['files']:
            if entry['path']==verifier.INDEX_PATH:
                continue
            path=root/entry['path'];path.parent.mkdir(parents=True,exist_ok=True)
            shutil.copyfile(SOURCE_ROOT/entry['path'],path)
        return root

    def test_all_17_actual_dependencies_match(self):
        root=self.dependency_copy()
        result=verifier.verify(self.folder,root)
        self.assertEqual(result['active_dependencies_checked'],17)

    def test_encoder_source_modification_rejected(self):
        root=self.dependency_copy()
        path=root/'integration/bm1368_control.c';path.write_bytes(path.read_bytes()+b'\n')
        with self.assertRaisesRegex(verifier.EvidenceError,'active dependency pin differs: integration/bm1368_control.c'):
            verifier.verify(self.folder,root)

    def test_crc_source_same_length_mutation_rejected(self):
        root=self.dependency_copy()
        path=root/'reconstruction/support/crc5.c';raw=bytearray(path.read_bytes());raw[-1]^=1;path.write_bytes(raw)
        with self.assertRaisesRegex(verifier.EvidenceError,'active dependency pin differs: reconstruction/support/crc5.c'):
            verifier.verify(self.folder,root)

    def test_transport_source_modification_rejected(self):
        root=self.dependency_copy()
        path=root/'libbitmain/src/transport-dispatch.c';path.write_bytes(path.read_bytes()+b'/* changed */')
        with self.assertRaisesRegex(verifier.EvidenceError,'active dependency pin differs: libbitmain/src/transport-dispatch.c'):
            verifier.verify(self.folder,root)

    def test_research_index_edit_is_allowed_by_active_pins(self):
        root=self.dependency_copy()
        path=root/verifier.INDEX_PATH;path.parent.mkdir(parents=True,exist_ok=True)
        path.write_text('The research index intentionally changes for the new module.\n')
        result=verifier.verify(self.folder,root)
        self.assertEqual(result['base_provenance_files'],18)
        self.assertEqual(result['active_dependencies_checked'],17)
        self.assertFalse(result['research_index_active_pin'])


if __name__=='__main__':
    unittest.main(verbosity=2)

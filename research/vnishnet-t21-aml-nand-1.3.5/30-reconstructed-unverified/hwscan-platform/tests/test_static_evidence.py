"""Check frozen evidence bytes and explicit claims; never interpret instructions."""
import hashlib
import json
import pathlib
import re
import struct
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]/'evidence'
SOURCE = '951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077'


def data(name):
    receipt = json.loads((ROOT/(name+'.json')).read_text())
    address = int(receipt['start'],16)
    out = bytearray()
    for line in (ROOT/(name+'.asm')).read_text().splitlines():
        match = re.fullmatch(r'([0-9a-f]{8})\s+([0-9a-f]+)\s+.*',line)
        if match is None or int(match[1],16) != address:
            raise ValueError('invalid or discontinuous evidence listing')
        chunk = bytes.fromhex(match[2])
        out.extend(chunk)
        address += len(chunk)
    if address != int(receipt['end_exclusive'],16):
        raise ValueError('incomplete evidence bytes')
    return bytes(out)


class StaticEvidenceTests(unittest.TestCase):
    def test_all_receipts_and_manifest(self):
        plan_raw = (ROOT/'plan.json').read_bytes()
        plan = json.loads(plan_raw)
        manifest = json.loads((ROOT/'manifest.json').read_text())
        self.assertEqual(plan['source_sha256'],SOURCE)
        self.assertEqual(len(plan['ranges']),12)
        self.assertEqual(manifest['plan_sha256'],hashlib.sha256(plan_raw).hexdigest())
        self.assertFalse(manifest['firmware_executed'])
        for item in plan['ranges']:
            with self.subTest(name=item['name']):
                receipt = json.loads((ROOT/(item['name']+'.json')).read_text())
                raw = data(item['name'])
                self.assertEqual(receipt['source_sha256'],SOURCE)
                self.assertFalse(receipt['firmware_executed'])
                self.assertEqual(len(raw),receipt['bytes'])
                self.assertEqual(hashlib.sha256(raw).hexdigest(),receipt['sha256'])
                self.assertEqual(receipt['sha256'],item['sha256'])
        for name,digest in manifest['artifact_sha256'].items():
            self.assertEqual(hashlib.sha256((ROOT/name).read_bytes()).hexdigest(),digest)

    def test_exact_lookup_instruction_words(self):
        # Pin the reviewed eight words. This is byte comparison, not an ARM VM.
        self.assertEqual(struct.unpack('<8I',data('lookup-code')),
            (0xe3500004,0x859f0018,0x808f0000,0x812fff1e,
             0xe59f1008,0xe08f1001,0xe7910100,0xe12fff1e))

    def test_lookup_literal_and_table_addresses(self):
        table_offset,unknown_offset = struct.unpack('<II',data('lookup-literals'))
        self.assertEqual(0xe8e38+8+table_offset,0x4aced8)
        self.assertEqual(0xe8e2c+8+unknown_offset,0x47f59f)
        self.assertEqual(struct.unpack('<5I',data('lookup-table')),
            (0x47db00,0x47daf6,0x47daf2,0x47daf9,0x47dafc))

    def test_string_content_and_source_positions(self):
        provenance = json.loads((ROOT/'string-provenance.json').read_text())
        self.assertEqual(provenance['source_sha256'],SOURCE)
        expected = {'xil':0x47db00,'bb':0x47daf6,'aml':0x47daf2,
                    'cv':0x47daf9,'stm':0x47dafc,'unk':0x47f59f}
        self.assertEqual(len(provenance['strings']),6)
        for item in provenance['strings']:
            raw = bytes.fromhex(item['bytes_hex'])
            address = int(item['address'],16)
            self.assertEqual(address,expected[item['value']])
            self.assertEqual(raw,item['value'].encode()+b'\0')
            self.assertEqual(hashlib.sha256(raw).hexdigest(),item['sha256'])
            base,name = (0x47f59c,'unknown-token-bytes') if item['value']=='unk' else (0x47daf0,'platform-token-bytes')
            self.assertEqual(data(name)[address-base:address-base+len(raw)],raw)

    def test_selector_pinned_assignments_and_null_skip(self):
        raw = data('selection-code')
        word = lambda address: struct.unpack_from('<I',raw,address-0xe907c)[0]
        self.assertEqual(word(0xe9084),0x0a00003e)  # BEQ to the skip target.
        self.assertEqual(word(0xe9114),0x13000005)  # MOVWNE #5.
        for address,value in [(0xe9124,2),(0xe912c,1),(0xe9134,3),(0xe913c,4)]:
            self.assertEqual(word(address),0xe3a00000|value)
        self.assertEqual(word(0xe9108),0xeb0dd9b3)  # Fifth comparator call.
        self.assertEqual(word(0xe911c),0x01a04006)  # Equal xil keeps zero result.

    def test_comparison_callee_exact_words(self):
        self.assertEqual(struct.unpack('<10I',data('comparison-callee')),
            (0xe2400001,0xe2411001,0xe5f03001,0xe5f12001,0xe1530002,
             0x1a000001,0xe3530000,0x1afffff9,0xe0430002,0xe12fff1e))

    def test_global_initial_value_is_data_only(self):
        self.assertEqual(struct.unpack('<I',data('platform-global-got'))[0],0x4b0a70)
        self.assertEqual(struct.unpack('<I',data('platform-global-initial'))[0],5)
        raw = data('selection-literals')
        displacement = struct.unpack_from('<I',raw,0xe93d4-0xe93ac)[0]
        self.assertEqual(0xe9164+8+displacement,0x4afb94)

    def test_direct_lookup_call_word(self):
        raw = data('lookup-caller')
        self.assertEqual(struct.unpack_from('<I',raw,0xe69cc-0xe69c4)[0],0xeb000914)


if __name__ == '__main__':
    unittest.main()

import hashlib
import importlib.util
import pathlib
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]/'scripts'))
AVAILABLE = bool(importlib.util.find_spec('elftools') and importlib.util.find_spec('capstone'))
if AVAILABLE:
    import index_arm_elf as index
    import disassemble_plan as plan


def fixture(symbols=True):
    raw = bytearray(0x800)
    raw[:16] = b'\x7fELF'+bytes([1,1,1])+bytes(9)
    struct.pack_into('<HHIIIIIHHHHHH', raw, 16, 2,40,1,0x10100,52,0x400,0x5000400,52,32,1,40,7,6)
    struct.pack_into('<IIIIIIII', raw, 52, 1,0,0x10000,0x10000,len(raw),len(raw),5,4)
    raw[0x100:0x108] = bytes.fromhex('1eff2fe170470000')
    struct.pack_into('<IIII', raw, 0x200, (0x10100-0x10200)&0x7fffffff,1,
                     (0x10105-0x10208)&0x7fffffff,0x80b0b0b0)
    struct.pack_into('<III', raw, 0x240, 0x10100,0x10105,0xffffffff)
    strings = b'\0arm_fn\0thumb_fn\0$a\0$t\0$d\0'
    raw[0x300:0x300+len(strings)] = strings
    records = [(0,0,0,0,0,0),(1,0x10100,4,0x12,0,1),(8,0x10105,2,0x12,0,1),
               (17,0x10100,0,0,0,1),(20,0x10104,0,0,0,1),(23,0x10106,0,0,0,1)]
    for n, values in enumerate(records):
        struct.pack_into('<IIIBBH', raw, 0x280+16*n, *values)
    names = b'\0.text\0.ARM.exidx\0.init_array\0.symtab\0.strtab\0.shstrtab\0'
    raw[0x340:0x340+len(names)] = names
    sections = [(0,0,0,0,0,0,0,0,0,0),
        (1,1,6,0x10100,0x100,0x40,0,0,4,0),
        (7,0x70000001,2,0x10200,0x200,16,1,0,4,8),
        (18,14,3,0x10240,0x240,12,0,0,4,4),
        (30,2 if symbols else 1,0,0,0x280,96,5,1,4,16),
        (38,3,0,0,0x300,len(strings),0,0,1,0),
        (46,3,0,0,0x340,len(names),0,0,1,0)]
    # Locate names by their actual offsets, not display assumptions.
    labels = [b'',b'.text',b'.ARM.exidx',b'.init_array',b'.symtab',b'.strtab',b'.shstrtab']
    for n, values in enumerate(sections):
        values = (names.find(labels[n]) if n else 0,)+values[1:]
        struct.pack_into('<IIIIIIIIII', raw, 0x400+40*n, *values)
    return bytes(raw)


@unittest.skipUnless(AVAILABLE, 'optional pinned static analysis packages not installed')
class ArmIndexTests(unittest.TestCase):
    def test_prel31_sign_and_wrap(self):
        self.assertEqual(index.prel31(0x7fffff00,0x200),0x100)
        self.assertEqual(index.prel31(0x3fffffff,0),0x3fffffff)
        self.assertEqual(index.prel31(0x40000000,0),0xc0000000)
        self.assertEqual(index.prel31(4,0xfffffffe),2)

    def test_symbols_thumb_and_mapping(self):
        summary, tables = index.build_index(index.Snapshot(fixture()))
        self.assertEqual(summary['function_symbol_records'],2)
        self.assertEqual(summary['mapping_symbol_records'],3)
        self.assertEqual(tables['functions'][1]['address'],'0x00010104')
        self.assertEqual(tables['functions'][1]['pointer'],'0x00010105')
        self.assertEqual(tables['functions'][1]['mode'],'thumb')
        self.assertEqual(tables['functions'][1]['end_exclusive'],'0x00010106')

    def test_ehabi_ranges_are_not_function_extents(self):
        _, tables = index.build_index(index.Snapshot(fixture()))
        first, second = tables['ehabi']
        self.assertEqual(first['coverage_end_exclusive'],'0x00010104')
        self.assertEqual(first['descriptor'],'cantunwind')
        self.assertEqual(first['function_end_exclusive'],'')
        self.assertEqual(second['function_end_exclusive'],'')
        self.assertEqual(second['coverage_end_exclusive'],'')
        self.assertEqual(second['mode_at_start'],'thumb')

    def test_stripped_file_still_indexes_metadata(self):
        summary, tables = index.build_index(index.Snapshot(fixture(symbols=False)))
        self.assertEqual(summary['symbol_tables'],[])
        self.assertEqual(summary['function_symbol_records'],0)
        self.assertEqual(summary['ehabi_records'],2)
        self.assertEqual(tables['init-arrays'][1]['mode_at_start'],'thumb')
        self.assertEqual(tables['init-arrays'][2]['mode_at_start'],'sentinel')

    def test_reject_arch_class_endian_and_relocatable(self):
        for offset, value in [(4,b'\2'),(5,b'\2'),(18,struct.pack('<H',3)),(16,struct.pack('<H',1))]:
            raw = bytearray(fixture()); raw[offset:offset+len(value)] = value
            with self.subTest(offset=offset), self.assertRaises(Exception):
                index.Snapshot(bytes(raw))

    def test_reject_truncated_load(self):
        with self.assertRaises(ValueError): index.Snapshot(fixture()[:-1])

    def test_reject_invalid_mappings(self):
        snapshot = index.Snapshot(fixture())
        for address, size in [(0x20000,1),(0x107ff,2),(0x10000,0),(-1,1),(0xffffffff,2)]:
            with self.subTest(address=address,size=size), self.assertRaises(ValueError):
                snapshot.mapped(address,size)
        snapshot.loads.append(dict(snapshot.loads[0]))
        with self.assertRaises(ValueError): snapshot.mapped(0x10100)

    def test_reject_nonexecutable_function(self):
        snapshot = index.Snapshot(fixture()); snapshot.loads[0]['p_flags'] = 4
        with self.assertRaises(ValueError): index.build_index(snapshot)

    def test_reject_ehabi_high_bit_and_order(self):
        for offset, value in [(0x200,0xffffff00),(0x208,(0x100fc-0x10208)&0x7fffffff)]:
            raw = bytearray(fixture()); struct.pack_into('<I',raw,offset,value)
            with self.subTest(offset=offset), self.assertRaises(ValueError): index.build_index(index.Snapshot(bytes(raw)))

    def test_reject_truncated_ehabi(self):
        raw = bytearray(fixture()); struct.pack_into('<I',raw,0x400+40*2+20,15)
        with self.assertRaises(ValueError): index.build_index(index.Snapshot(bytes(raw)))

    def test_extab_pointer(self):
        raw = bytearray(fixture()); struct.pack_into('<I',raw,0x204,(0x10320-0x10204)&0x7fffffff)
        _, tables = index.build_index(index.Snapshot(bytes(raw)))
        self.assertEqual(tables['ehabi'][0]['extab_address'],'0x00010320')

    def test_index_is_deterministic(self):
        first = index.build_index(index.Snapshot(fixture()))
        second = index.build_index(index.Snapshot(fixture()))
        self.assertEqual(first,second)
        with tempfile.TemporaryDirectory() as temp:
            a,b = pathlib.Path(temp)/'a', pathlib.Path(temp)/'b'
            index.write_index(a,*first); index.write_index(b,*second)
            self.assertEqual({p.name:p.read_bytes() for p in a.iterdir()}, {p.name:p.read_bytes() for p in b.iterdir()})
            with self.assertRaises(FileExistsError): index.write_index(a,*first)

    def test_output_symlink_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root = pathlib.Path(temp); (root/'link').symlink_to(root, target_is_directory=True)
            with self.assertRaises(ValueError): index.new_output(root/'link'/'out')

    def make_plan(self):
        raw = fixture()
        return raw, dict(schema=1,source_sha256=hashlib.sha256(raw).hexdigest(),ranges=[dict(
            name='arm-return',start='0x10100',end_exclusive='0x10104',mode='arm',
            sha256=hashlib.sha256(raw[0x100:0x104]).hexdigest(),mode_evidence='synthetic A32 bx lr',
            boundary_evidence='synthetic four-byte fixture')])

    def test_plan_arm_thumb_and_data(self):
        raw, spec = self.make_plan()
        result = plan.render_plan(index.Snapshot(raw),spec)
        self.assertIn('bx         lr',result['arm-return.asm'])
        entry = spec['ranges'][0]
        entry.update(name='thumb-return',start='0x10104',end_exclusive='0x10106',mode='thumb',
                     sha256=hashlib.sha256(raw[0x104:0x106]).hexdigest())
        self.assertIn('bx         lr',plan.render_plan(index.Snapshot(raw),spec)['thumb-return.asm'])
        entry.update(name='literal',start='0x10100',end_exclusive='0x10104',mode='data',
                     sha256=hashlib.sha256(raw[0x100:0x104]).hexdigest())
        self.assertIn('.word      0xe12fff1e',plan.render_plan(index.Snapshot(raw),spec)['literal.asm'])

    def test_plan_rejects_digest_mode_range_and_name(self):
        for key, value in [('name','../escape'),('mode','auto'),('start','0x10101'),('sha256','bad'),
                           ('end_exclusive','0x30104'),('boundary_evidence',''),('mode_evidence','')]:
            raw,spec = self.make_plan(); spec['ranges'][0][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError): plan.render_plan(index.Snapshot(raw),spec)
        raw,spec = self.make_plan(); spec['source_sha256']='bad'
        with self.assertRaises(ValueError): plan.render_plan(index.Snapshot(raw),spec)


if __name__ == '__main__':
    unittest.main()

import hashlib,importlib.util,pathlib,struct,sys,tempfile,unittest
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'scripts'))
AVAILABLE=bool(importlib.util.find_spec('capstone') and importlib.util.find_spec('elftools'))
if AVAILABLE:import disassemble_slice as d

def fixture():
    ident=b'\x7fELF'+bytes([1,1,1])+bytes(9)
    header=ident+struct.pack('<HHIIIIIHHHHHH',2,40,1,0x1000,52,0,0x5000400,52,32,1,40,0,0)
    ph=struct.pack('<IIIIIIII',1,84,0x1000,0x1000,4,4,5,4)
    return header+ph+bytes.fromhex('1eff2fe1')

@unittest.skipUnless(AVAILABLE,'optional pinned static analysis packages not installed')
class DisassemblyTests(unittest.TestCase):
    def test_verified_snapshot(self):
        with tempfile.TemporaryDirectory() as temp:
            p=pathlib.Path(temp)/'synthetic.elf';raw=fixture();p.write_bytes(raw)
            data,offset,bits,flags,digest=d.extract_slice(p,0x1000,0x1004)
            self.assertEqual(data,bytes.fromhex('1eff2fe1'));self.assertEqual(offset,84)
            self.assertEqual(bits,32);self.assertEqual(flags,5);self.assertEqual(digest,hashlib.sha256(raw).hexdigest())
    def test_range_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            p=pathlib.Path(temp)/'synthetic.elf';p.write_bytes(fixture())
            for start,end in [(0x1000,0x1008),(0x1000,0x1000),(0x1000,0x1000+1024**2+1)]:
                with self.subTest(start=start,end=end),self.assertRaises(ValueError):d.extract_slice(p,start,end)
    def test_wrong_architecture(self):
        with tempfile.TemporaryDirectory() as temp:
            p=pathlib.Path(temp)/'synthetic.elf';raw=bytearray(fixture());raw[18:20]=struct.pack('<H',3);p.write_bytes(raw)
            with self.assertRaises(ValueError):d.extract_slice(p,0x1000,0x1004)
if __name__=='__main__':unittest.main()

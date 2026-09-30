import gzip,io,json,pathlib,stat,struct,sys,tarfile,tempfile,unittest,zlib
sys.path.insert(0,str(pathlib.Path(__file__).resolve().parents[1]/'scripts'))
import unpack_firmware as u
from unittest.mock import patch

def cpio(name='usr/bin/cgminer',body=b'ELF',mode=stat.S_IFREG|0o755,magic=b'070701',checksum=0,nlink=1):
    n=name.encode()+b'\0'
    fields=[1,mode,0,0,nlink,0,len(body),0,0,0,0,len(n),checksum]
    raw=magic+b''.join(f'{x:08x}'.encode() for x in fields)+n
    raw+=b'\0'*((-len(raw))%4);raw+=body;raw+=b'\0'*((-len(raw))%4)
    return raw

def archive(entries):
    b=io.BytesIO()
    with tarfile.open(fileobj=b,mode='w') as t:
        for name,body,kind,link in entries:
            m=tarfile.TarInfo(name);m.size=len(body);m.type=kind;m.linkname=link
            t.addfile(m,io.BytesIO(body))
    return b.getvalue()

class SafetyTests(unittest.TestCase):
    def test_path_rejection(self):
        for path in ['/etc/passwd','../../escape','a/../escape','a\\b','a\nb','']:
            with self.subTest(path=path),self.assertRaises(u.UnsafeArchive):u.safe_name(path)
    def test_safe_normalization(self):self.assertEqual(u.safe_name('./usr/bin/cgminer'),'usr/bin/cgminer')
    def test_tar_traversal(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_tar(archive([('../escape',b'x',tarfile.REGTYPE,'')]))
    def test_tar_symlink_metadata_only(self):
        rows=u.parse_tar(archive([('badlink',b'',tarfile.SYMTYPE,'/etc/passwd')]))
        self.assertIsNone(rows[0][1]);self.assertEqual(rows[0][0]['link_target'],'/etc/passwd')
    def test_tar_hardlink_metadata_only(self):
        rows=u.parse_tar(archive([('badlink',b'',tarfile.LNKTYPE,'../../escape')]))
        self.assertIsNone(rows[0][1])
    def test_duplicate_tar(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_tar(archive([('x',b'a',tarfile.REGTYPE,''),('./x',b'b',tarfile.REGTYPE,'')]))
    def test_tar_nonzero_suffix_rejected(self):
        raw=archive([('x',b'a',tarfile.REGTYPE,'')])
        for suffix in [b'garbage',archive([('y',b'b',tarfile.REGTYPE,'')])]:
            with self.subTest(suffix=suffix[:8]),self.assertRaises(u.UnsafeArchive):u.parse_tar(raw+suffix)
    def test_newc_strict_hex(self):
        for malformed in [b'-0000001',b'0000_001',b' 0000001',b'+0000001']:
            raw=bytearray(cpio());raw[54:62]=malformed
            with self.subTest(field=malformed),self.assertRaises(u.UnsafeArchive):u.parse_newc(bytes(raw))
    def test_entry_budget(self):
        with patch.object(u,'MAX_ENTRIES',1):
            with self.assertRaises(u.UnsafeArchive):u.parse_tar(archive([('x',b'a',tarfile.REGTYPE,''),('y',b'b',tarfile.REGTYPE,'')]))
    def test_file_budget(self):
        with patch.object(u,'MAX_FILE',2):
            with self.assertRaises(u.UnsafeArchive):u.parse_tar(archive([('x',b'abc',tarfile.REGTYPE,'')]))
            with self.assertRaises(u.UnsafeArchive):u.parse_newc(cpio()+cpio('TRAILER!!!',b'',0))
    def test_input_budget(self):
        with patch.object(u,'MAX_EXPANDED',2):
            with self.assertRaises(u.UnsafeArchive):u.parse_tar(b'abc')
            with self.assertRaises(u.UnsafeArchive):u.parse_newc(b'abc')
    def test_newc_positive_crc(self):
        rows=u.parse_newc(cpio(magic=b'070702',checksum=sum(b'ELF'))+cpio('TRAILER!!!',b'',0))
        self.assertEqual(rows[0][1],b'ELF')
    def test_tar_missing_end_marker(self):
        raw=archive([('x',b'a',tarfile.REGTYPE,'')])
        with self.assertRaises(u.UnsafeArchive):u.parse_tar(raw[:1024])
    def test_inflate_limit(self):
        with self.assertRaises(u.UnsafeArchive):u.inflate(gzip.compress(b'A'*10000),100)
    def test_newc_regular(self):
        rows=u.parse_newc(cpio()+cpio('TRAILER!!!',b'',0))
        self.assertEqual(rows[0][1],b'ELF')
    def test_newc_missing_trailer(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_newc(cpio())
    def test_newc_traversal(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_newc(cpio('../escape')+cpio('TRAILER!!!',b'',0))
    def test_newc_symlink_metadata_only(self):
        rows=u.parse_newc(cpio('lib/link',b'../../escape',stat.S_IFLNK|0o777)+cpio('TRAILER!!!',b'',0))
        self.assertIsNone(rows[0][1]);self.assertEqual(rows[0][0]['link_target'],'../../escape')
    def test_newc_device_metadata_only(self):
        rows=u.parse_newc(cpio('dev/x',b'',stat.S_IFCHR|0o600)+cpio('TRAILER!!!',b'',0))
        self.assertIsNone(rows[0][1]);self.assertEqual(rows[0][0]['type'],'character-device')
    def test_newc_bad_checksum(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_newc(cpio(magic=b'070702',checksum=1)+cpio('TRAILER!!!',b'',0))
    def test_newc_duplicate(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_newc(cpio()+cpio()+cpio('TRAILER!!!',b'',0))
    def test_newc_truncated(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_newc(cpio()[:-4])
    def test_newc_link_identity(self):
        rows=u.parse_newc(cpio(nlink=2)+cpio('TRAILER!!!',b'',0));self.assertEqual(rows[0][0]['hardlink_identity'],[0,0,1])
    def test_newc_bad_name_terminator(self):
        raw=bytearray(cpio());raw[110+len('usr/bin/cgminer')]=65
        with self.assertRaises(u.UnsafeArchive):u.parse_newc(bytes(raw))
    def test_newc_trailing_data(self):
        with self.assertRaises(u.UnsafeArchive):u.parse_newc(cpio('TRAILER!!!',b'',0)+b'evil')
    def test_uboot_crc(self):
        data=gzip.compress(b'hello',mtime=0)
        hdr=struct.pack('>7I4B32s',0x27051956,0,0,len(data),0,0,zlib.crc32(data),5,2,3,1,b'test')
        hdr=hdr[:4]+struct.pack('>I',zlib.crc32(hdr))+hdr[8:]
        info,payload=u.parse_uboot(hdr+data);self.assertTrue(info['header_crc_verified']);self.assertEqual(payload,data)
        with self.assertRaises(u.UnsafeArchive):u.parse_uboot(hdr+data[:-1]+b'!')
    def test_uboot_bad_fields(self):
        data=gzip.compress(b'hello',mtime=0)
        for magic,size,comp in [(0,len(data),1),(0x27051956,len(data)+1,1),(0x27051956,len(data),0)]:
            hdr=struct.pack('>7I4B32s',magic,0,0,size,0,0,zlib.crc32(data),5,2,3,comp,b'test')
            hdr=hdr[:4]+struct.pack('>I',zlib.crc32(hdr))+hdr[8:]
            with self.subTest(magic=magic,size=size,comp=comp),self.assertRaises(u.UnsafeArchive):u.parse_uboot(hdr+data)
        with self.assertRaises(u.UnsafeArchive):u.parse_uboot(b'x'*63)
    def test_output_and_modes(self):
        with tempfile.TemporaryDirectory() as temp:
            root=u.prepare_output(pathlib.Path(temp)/'out');rel=u.store_blob(root,b'data')
            self.assertFalse((root/rel).stat().st_mode&0o111)
            self.assertEqual(u.store_blob(root,b'data'),rel)
            with self.assertRaises(FileExistsError):u.prepare_output(root)
    def test_output_symlink_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            path=pathlib.Path(temp);(path/'link').symlink_to(path,target_is_directory=True)
            with self.assertRaises(u.UnsafeArchive):u.prepare_output(path/'link'/'out')
    def test_objects_directory_symlink_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            path=pathlib.Path(temp);root=u.prepare_output(path/'out');(path/'other').mkdir()
            (root/'objects').symlink_to(path/'other',target_is_directory=True)
            with self.assertRaises(u.UnsafeArchive):u.store_blob(root,b'data')
            self.assertEqual(list((path/'other').iterdir()),[])
    def test_blob_symlink_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            root=u.prepare_output(pathlib.Path(temp)/'out');(root/'objects').mkdir()
            (root/'objects'/u.sha(b'data')).symlink_to('/etc/hosts')
            with self.assertRaises(u.UnsafeArchive):u.store_blob(root,b'data')
if __name__=='__main__':unittest.main()

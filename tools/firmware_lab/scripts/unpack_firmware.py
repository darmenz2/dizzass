#!/usr/bin/env python3
"""Bounded static firmware inventory. Never execute or restore archive paths/modes."""
from __future__ import annotations
import argparse, gzip, hashlib, io, json, os, pathlib, re, resource, stat, struct, tarfile, zlib

ARCHIVE_SHA256 = '20fabdd66255889315e61ae2a33ff2e4623566ca430f1cb8c90d9b938dc7b43c'
ELF_SHA256 = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
MAX_FILE = 128 * 1024**2
MAX_EXPANDED = 512 * 1024**2
MAX_ENTRIES = 100000

class UnsafeArchive(ValueError):
    pass

def sha(data):
    return hashlib.sha256(data).hexdigest()

def safe_name(name):
    if not name or '\\' in name or any(ord(c) < 32 or ord(c) == 127 for c in name):
        raise UnsafeArchive('invalid archive name')
    if name.startswith('/') or '..' in name.split('/'):
        raise UnsafeArchive('absolute/traversal archive name')
    value = pathlib.PurePosixPath(name).as_posix()
    if len(value.encode('utf-8')) > 4096:
        raise UnsafeArchive('overlong archive name')
    return value

def bounded_read(stream, limit):
    pieces, count = [], 0
    while True:
        block = stream.read(min(1024**2, limit + 1 - count))
        if not block:
            return b''.join(pieces)
        count += len(block)
        if count > limit:
            raise UnsafeArchive('expanded byte budget exceeded')
        pieces.append(block)

def inflate(data, limit=MAX_EXPANDED):
    with gzip.GzipFile(fileobj=io.BytesIO(data), mode='rb') as f:
        return bounded_read(f, limit)

def parse_tar(data):
    if len(data)>MAX_EXPANDED:
        raise UnsafeArchive('tar input byte budget exceeded')
    records, seen, total = [], set(), 0
    with tarfile.open(fileobj=io.BytesIO(data), mode='r:') as archive:
        for member in archive:
            if len(records) >= MAX_ENTRIES:
                raise UnsafeArchive('tar entry budget exceeded')
            name = safe_name(member.name)
            if name in seen:
                raise UnsafeArchive('duplicate tar name: ' + name)
            seen.add(name)
            if member.size < 0 or member.size > MAX_FILE:
                raise UnsafeArchive('tar file byte budget exceeded')
            total += member.size
            if total > MAX_EXPANDED:
                raise UnsafeArchive('tar total byte budget exceeded')
            record = dict(path=name, raw_path=member.name, type=member.type.decode('ascii','backslashreplace'),
                          mode=member.mode, uid=member.uid, gid=member.gid, size=member.size,
                          header_offset=member.offset, data_offset=member.offset_data)
            if member.isfile():
                if member.issparse():
                    raise UnsafeArchive('sparse tar unsupported')
                stream = archive.extractfile(member)
                data_item = bounded_read(stream, MAX_FILE)
                if len(data_item) != member.size:
                    raise UnsafeArchive('truncated tar file')
                record.update(sha256=sha(data_item), materialization='content-addressed-regular-data')
            else:
                data_item = None
                record['materialization'] = 'metadata-only'
                if member.issym() or member.islnk():
                    record['link_target'] = member.linkname
            records.append((record, data_item))
        if len(data)-archive.offset<1024:
            raise UnsafeArchive('missing two-block tar end marker')
        if any(data[archive.offset:]):
            raise UnsafeArchive('nonzero tar suffix/concatenated archive')
    return records

def parse_uboot(data):
    if len(data) < 64:
        raise UnsafeArchive('truncated U-Boot header')
    magic, hcrc, timestamp, size, load, entry, dcrc, os_, arch, type_, comp, name = struct.unpack('>7I4B32s',data[:64])
    if magic != 0x27051956 or size != len(data)-64:
        raise UnsafeArchive('U-Boot magic or payload size mismatch')
    header = data[:4] + b'\0'*4 + data[8:64]
    if zlib.crc32(header) & 0xffffffff != hcrc:
        raise UnsafeArchive('U-Boot header CRC mismatch')
    if zlib.crc32(data[64:]) & 0xffffffff != dcrc:
        raise UnsafeArchive('U-Boot data CRC mismatch')
    if comp != 1:
        raise UnsafeArchive('expected gzip U-Boot payload')
    return dict(header_crc32=f'{hcrc:08x}', data_crc32=f'{dcrc:08x}', payload_size=size,
                load_address=load, entry_address=entry, timestamp=timestamp, os=os_, architecture=arch,
                image_type=type_, compression=comp, name=name.rstrip(b'\0').decode('ascii','backslashreplace'),
                header_crc_verified=True,data_crc_verified=True), data[64:]

def parse_newc(data):
    if len(data)>MAX_EXPANDED:
        raise UnsafeArchive('newc input byte budget exceeded')
    records, seen, pos = [], set(), 0
    while True:
        if len(records) >= MAX_ENTRIES:
            raise UnsafeArchive('newc entry budget exceeded')
        if pos + 110 > len(data) or data[pos:pos+6] not in (b'070701',b'070702'):
            raise UnsafeArchive('truncated/invalid newc header or missing trailer')
        magic = data[pos:pos+6]
        fields=data[pos+6:pos+110]
        if re.fullmatch(b'[0-9a-fA-F]{104}',fields) is None:
            raise UnsafeArchive('invalid newc hex field')
        try:
            f = [int(fields[i*8:(i+1)*8],16) for i in range(13)]
        except ValueError as exc:
            raise UnsafeArchive('invalid newc hex field') from exc
        inode, mode, uid, gid, nlink, mtime, size, devmajor, devminor, rdevmajor, rdevminor, namesize, checksum = f
        if namesize < 1 or namesize > 4097 or pos+110+namesize > len(data):
            raise UnsafeArchive('invalid newc name size')
        raw_name = data[pos+110:pos+110+namesize]
        if raw_name[-1:] != b'\0' or b'\0' in raw_name[:-1]:
            raise UnsafeArchive('invalid newc name terminator')
        try:
            name = safe_name(raw_name[:-1].decode('utf-8','strict'))
        except UnicodeDecodeError as exc:
            raise UnsafeArchive('non-UTF8 newc name') from exc
        start = (pos+110+namesize+3) & ~3
        end = start + size
        next_pos = (end+3) & ~3
        if size > MAX_FILE or end > len(data) or next_pos > len(data):
            raise UnsafeArchive('truncated/oversized newc payload')
        payload = data[start:end]
        if magic == b'070702' and (sum(payload) & 0xffffffff) != checksum:
            raise UnsafeArchive('newc payload checksum mismatch')
        if magic == b'070701' and checksum != 0:
            raise UnsafeArchive('unexpected newc checksum')
        if name == 'TRAILER!!!':
            if size != 0 or any(data[next_pos:]):
                raise UnsafeArchive('nonempty newc trailer or trailing data')
            return records
        if name in seen:
            raise UnsafeArchive('duplicate newc name: '+name)
        seen.add(name)
        kind = stat.S_IFMT(mode)
        kind_name = {stat.S_IFREG:'regular',stat.S_IFDIR:'directory',stat.S_IFLNK:'symlink',
                     stat.S_IFCHR:'character-device',stat.S_IFBLK:'block-device',stat.S_IFIFO:'fifo',stat.S_IFSOCK:'socket'}.get(kind,'unknown')
        record = dict(path=name, raw_path=raw_name[:-1].decode(), type=kind_name, mode=mode, uid=uid,gid=gid,
                      inode=inode,nlink=nlink,mtime=mtime,size=size,device=[devmajor,devminor],
                      special_device=[rdevmajor,rdevminor], header_offset=pos,data_offset=start,
                      sha256=sha(payload), checksum_format=magic.decode(), checksum=checksum)
        if kind == stat.S_IFREG:
            record['materialization']='content-addressed-regular-data'
            if nlink > 1:
                record['hardlink_identity']=[devmajor,devminor,inode]
                record['hardlink_note']='payload preserved as stored; no hardlink restoration'
            body=payload
        else:
            record['materialization']='metadata-only'
            body=None
            if kind == stat.S_IFLNK:
                record['link_target']=payload.decode('utf-8','backslashreplace')
        records.append((record,body))
        pos=next_pos

def prepare_output(path):
    path = pathlib.Path(path).absolute()
    for component in (path, *path.parents):
        if component.is_symlink():
            raise UnsafeArchive('output ancestor is a symlink')
    path.mkdir(mode=0o700,parents=False,exist_ok=False)
    return path

def store_blob(root,data):
    digest=sha(data)
    # Directory descriptors prevent the objects directory/final name from being
    # redirected by preexisting links. A concurrently hostile same-UID process
    # is outside this workspace-level isolation model.
    root_fd=os.open(root,os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW)
    try:
        try:
            os.mkdir('objects',0o700,dir_fd=root_fd)
        except FileExistsError:
            pass
        try:
            objects_fd=os.open('objects',os.O_RDONLY|os.O_DIRECTORY|os.O_NOFOLLOW,dir_fd=root_fd)
        except OSError as exc:
            raise UnsafeArchive('unsafe objects directory') from exc
        try:
            try:
                fd=os.open(digest,os.O_WRONLY|os.O_CREAT|os.O_EXCL|os.O_NOFOLLOW,0o400,dir_fd=objects_fd)
            except FileExistsError:
                try:
                    fd=os.open(digest,os.O_RDONLY|os.O_NOFOLLOW,dir_fd=objects_fd)
                except OSError as exc:
                    raise UnsafeArchive('unsafe existing object') from exc
                with os.fdopen(fd,'rb') as stream:
                    if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode) or bounded_read(stream,MAX_EXPANDED)!=data:
                        raise UnsafeArchive('object collision/unsafe existing object')
            else:
                with os.fdopen(fd,'wb') as stream:
                    stream.write(data)
        finally:
            os.close(objects_fd)
    finally:
        os.close(root_fd)
    return 'objects/'+digest

def run(source, output):
    source=pathlib.Path(source)
    if source.is_symlink() or not source.is_file():
        raise UnsafeArchive('source must be a regular non-symlink file')
    with source.open('rb') as source_stream:
        original=bounded_read(source_stream,MAX_FILE)
    if sha(original)!=ARCHIVE_SHA256:
        raise UnsafeArchive('original archive SHA-256 differs from pinned reference')
    tar_data=inflate(original)
    tar_items=parse_tar(tar_data)
    ramdisks=[body for r,body in tar_items if r['path']=='uramdisk.image.gz' and body is not None]
    if len(ramdisks)!=1:
        raise UnsafeArchive('need exactly one regular uramdisk.image.gz')
    uboot,gz=parse_uboot(ramdisks[0])
    cpio=inflate(gz)
    cpio_items=parse_newc(cpio)
    refs=[body for r,body in cpio_items if r['path']=='usr/bin/cgminer' and body is not None]
    if len(refs)!=1 or sha(refs[0])!=ELF_SHA256:
        raise UnsafeArchive('cgminer ELF absent or SHA-256 mismatch')
    root=prepare_output(output)
    for record,body in [*tar_items,*cpio_items]:
        if body is not None:
            record['object']=store_blob(root,body)
    layers=[{'name':'original.tar.gz','size':len(original),'sha256':sha(original)},
            {'name':'outer.tar','size':len(tar_data),'sha256':sha(tar_data)},
            {'name':'uramdisk.image.gz','size':len(ramdisks[0]),'sha256':sha(ramdisks[0])},
            {'name':'ramdisk.gzip','size':len(gz),'sha256':sha(gz)},
            {'name':'ramdisk.newc','size':len(cpio),'sha256':sha(cpio),'object':store_blob(root,cpio)}]
    manifest={'schema':1,'policy':'static data only; no archive paths, links, devices, modes or ownership restored',
              'original_sha256_verified':True,'elf_sha256_verified':True,'firmware_executed':False,
              'expected_archive_sha256':ARCHIVE_SHA256,'expected_elf_sha256':ELF_SHA256,
              'layers':layers,'uboot':uboot,'tar':[r for r,b in tar_items],'newc':[r for r,b in cpio_items]}
    (root/'manifest.json').write_text(json.dumps(manifest,indent=2,sort_keys=True)+'\n')
    (root/'cgminer.vendor.elf').write_bytes(refs[0]);(root/'cgminer.vendor.elf').chmod(0o400)
    with source.open('rb') as source_stream:
        after_sha=sha(bounded_read(source_stream,MAX_FILE))
    if after_sha!=ARCHIVE_SHA256:
        raise UnsafeArchive('source changed during extraction')
    print(json.dumps({'output':str(root),'tar_entries':len(tar_items),'newc_entries':len(cpio_items),'cgminer_bytes':len(refs[0]),'cgminer_sha256':sha(refs[0])}))
    return manifest

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('source',type=pathlib.Path);p.add_argument('output',type=pathlib.Path)
    args=p.parse_args()
    resource.setrlimit(resource.RLIMIT_CPU,(120,120))
    resource.setrlimit(resource.RLIMIT_AS,(2*1024**3,2*1024**3))
    resource.setrlimit(resource.RLIMIT_FSIZE,(MAX_EXPANDED,MAX_EXPANDED))
    os.umask(0o077)
    run(args.source,args.output)
if __name__=='__main__':
    main()

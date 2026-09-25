#!/usr/bin/env python3
"""Import the exact supplied Stage 14 ZIP into an existing cgminer checkout.
No network, commit, push, executable launch, firmware installation or hardware I/O.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import stat
import subprocess
import sys
import zipfile

ARCHIVE_SHA256 = '0c61e8acea79e1e6bad4b1058d50cbb60cf985fcf98ad3f9eb026d4b25178f50'
PREFIX = 'VNish135_CGMINER_OVERLAY/'
BASE_COMMIT = 'b8491c66e7e22f23a9edf095dd1337ee581e88bd'
BASE_TREE = '2228aee63ac41271bbbe26773ad81f31fdec0373'
MAKEFILE_BLOB = '17d2fbde26b5e8cb614b61908b84d5937af48325'
ELF_SHA256 = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
INCLUDE = b'\n# VNish 1.3.5 recovery: additive, no active T21 hardware driver.\ninclude $(top_srcdir)/reconstruction/cgminer-overlay.am\n'
RECEIPT = 'migration/STAGE14_IMPORT.json'


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def git_blob(data: bytes) -> str:
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()


def git(root: Path, *args: str) -> str:
    return subprocess.check_output(['git', '-C', str(root), *args], text=True,
                                   stderr=subprocess.STDOUT).strip()


def archive_entries(path: Path) -> dict[str, bytes]:
    if path.stat().st_size > 16 * 1024 * 1024:
        raise ValueError('Archive exceeds the expected size bound')
    raw = path.read_bytes()
    if sha256(raw) != ARCHIVE_SHA256:
        raise ValueError('Not the exact verified Stage 14 archive; refusing import')
    entries: dict[str, bytes] = {}
    with zipfile.ZipFile(path) as archive:
        if sum(item.file_size for item in archive.infolist()) > 64 * 1024 * 1024:
            raise ValueError('Expanded archive exceeds bound')
        for item in archive.infolist():
            if not item.filename.startswith(PREFIX):
                raise ValueError('Unexpected archive root')
            rel = item.filename[len(PREFIX):]
            if not rel and item.is_dir():
                continue
            parsed = PurePosixPath(rel)
            if (not rel or parsed.is_absolute() or '..' in parsed.parts
                    or '\\' in rel or '.git' in parsed.parts or '.github' in parsed.parts
                    or parsed.as_posix() != rel.rstrip('/')):
                raise ValueError(f'Unsafe path: {rel!r}')
            mode = (item.external_attr >> 16) & 0o170000
            if mode not in (0, stat.S_IFREG, stat.S_IFDIR):
                raise ValueError(f'Unsupported archive object: {rel}')
            if item.is_dir():
                continue
            if rel in entries:
                raise ValueError(f'Duplicate archive path: {rel}')
            entries[rel] = archive.read(item)
    if len(entries) != 790:
        raise ValueError('Unexpected Stage 14 file count')
    manifest_path = 'reconstruction/overlay-files.json'
    manifest = json.loads(entries[manifest_path])
    seen: set[str] = set()
    for row in manifest:
        rel = row['path']
        if rel in seen or rel == manifest_path or rel not in entries:
            raise ValueError(f'Invalid inventory entry: {rel}')
        data = entries[rel]
        if len(data) != row['bytes'] or sha256(data) != row['sha256']:
            raise ValueError(f'Inventory mismatch: {rel}')
        seen.add(rel)
    if seen != set(entries) - {manifest_path}:
        raise ValueError('Archive inventory is incomplete')
    if sha256(entries['reference/cgminer.vendor.elf']) != ELF_SHA256:
        raise ValueError('Original reference ELF differs')
    return entries


def target_path(root: Path, rel: str) -> Path:
    current = root
    for component in PurePosixPath(rel).parts:
        current = current / component
        if current.is_symlink():
            raise ValueError(f'Symlink in destination: {rel}')
    if not current.resolve().is_relative_to(root.resolve()):
        raise ValueError(f'Path escapes destination: {rel}')
    return current


def apply(root: Path, entries: dict[str, bytes], *, check_only: bool) -> dict:
    makefile = target_path(root, 'Makefile.am')
    original_makefile = makefile.read_bytes()
    if original_makefile.endswith(INCLUDE):
        original_makefile = original_makefile[:-len(INCLUDE)]
    if git_blob(original_makefile) != MAKEFILE_BLOB:
        raise ValueError('Makefile.am is not the pinned upstream file or approved overlay')
    for rel, data in entries.items():
        dest = target_path(root, rel)
        if dest.exists() and (not dest.is_file() or dest.read_bytes() != data):
            raise ValueError(f'Existing different file; refusing overwrite: {rel}')
    receipt = {
        'stage': 14,
        'archive_sha256': ARCHIVE_SHA256,
        'upstream_commit': BASE_COMMIT,
        'upstream_tree': BASE_TREE,
        'imported_file_count': len(entries),
        'reference_elf_sha256': ELF_SHA256,
        'all_archive_files_preserved_byte_for_byte': True,
        'upstream_file_changes': ['Makefile.am'],
        'original_overlay_inventory_preserved': True,
        'full_upstream_build_tested': False,
        'hardware_tested': False,
        'runtime_ready': False,
    }
    receipt_data = (json.dumps(receipt, indent=2) + '\n').encode()
    receipt_path = target_path(root, RECEIPT)
    if receipt_path.exists() and receipt_path.read_bytes() != receipt_data:
        raise ValueError('Different import receipt already exists')
    if check_only:
        return dict(receipt, check_only=True, written=False)
    for rel, data in entries.items():
        dest = target_path(root, rel)
        if dest.exists():
            continue
        dest.parent.mkdir(parents=True, exist_ok=True)
        with dest.open('xb') as output:
            output.write(data)
        dest.chmod(0o644)
    makefile.write_bytes(original_makefile + INCLUDE)
    for rel, data in entries.items():
        if target_path(root, rel).read_bytes() != data:
            raise ValueError(f'Post-import verification failed: {rel}')
    receipt_path.parent.mkdir(parents=True, exist_ok=True)
    receipt_path.write_bytes(receipt_data)
    return dict(receipt, check_only=False, written=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('archive', type=Path)
    parser.add_argument('--root', type=Path, default=Path.cwd())
    parser.add_argument('--check-only', action='store_true')
    args = parser.parse_args()
    try:
        root = args.root.resolve()
        if git(root, 'rev-parse', '--show-toplevel') != str(root):
            raise ValueError('--root must be the checkout root')
        if git(root, 'rev-parse', BASE_COMMIT + '^{tree}') != BASE_TREE:
            raise ValueError('Pinned source tree is absent')
        git(root, 'merge-base', '--is-ancestor', BASE_COMMIT, 'HEAD')
        if git(root, 'status', '--porcelain', '--untracked-files=no'):
            raise ValueError('Tracked checkout files must be clean before import')
        result = apply(root, archive_entries(args.archive), check_only=args.check_only)
        print(json.dumps(result, indent=2))
        return 0
    except (OSError, ValueError, KeyError, zipfile.BadZipFile,
            json.JSONDecodeError, subprocess.CalledProcessError) as error:
        print(f'Import failed: {error}', file=sys.stderr)
        print('No commit, push or hardware operation was performed.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())

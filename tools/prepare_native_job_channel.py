#!/usr/bin/env python3
"""Stage eight exact pending dependency blobs; no network, hardware or Git writes."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'integration/evidence/native_job_channel_dependencies.json'
IGNORE = b'*\n'

def regular(path: Path, root: Path) -> bytes:
    path.relative_to(root)
    for p in (path, *path.parents):
        if p.is_symlink():
            raise ValueError(f'symlink rejected: {p}')
        if p == root:
            break
    if not path.is_file():
        raise ValueError(f'not a regular file: {path}')
    return path.read_bytes()

def verify(data: bytes, entry: dict) -> None:
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    if blob != entry['blob'] or hashlib.sha256(data).hexdigest() != entry['sha256']:
        raise ValueError(f'hash mismatch: {entry["path"]}')

def output_path(name: str) -> Path:
    path = Path(name)
    if path.is_absolute() or '..' in path.parts or len(path.parts) < 2 or path.parts[0] != 'build':
        raise ValueError('output must be a subdirectory of build, without ..')
    out = ROOT / path
    for p in (out, *out.parents):
        if p.is_symlink():
            raise ValueError(f'symlink output: {p}')
        if p == ROOT:
            break
    return out

def prepare(out: Path, source: Path | None, check: bool) -> None:
    manifest = json.loads(MANIFEST.read_text())
    for entry in manifest['unchanged']:
        verify(regular(ROOT / entry['path'], ROOT), entry)
    entries = manifest['pending']
    if check:
        expected = {e['path'] for e in entries} | {'.gitignore'}
        found = set()
        for p in out.rglob('*'):
            if p.is_symlink():
                raise ValueError('symlink in staged tree')
            if not p.is_dir():
                found.add(str(p.relative_to(out)))
        if found != expected or regular(out / '.gitignore', out) != IGNORE:
            raise ValueError('staged tree file set differs')
        for entry in entries:
            verify(regular(out / entry['path'], out), entry)
        return
    if out.exists():
        raise ValueError('refusing to overwrite staged output; use --check')
    material = []
    for entry in entries:
        if source is None:
            result = subprocess.run(['git', 'show', f'{entry["commit"]}:{entry["path"]}'],
                cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=15)
            if result.returncode:
                raise ValueError('missing exact dependency commit; fetch it read-only first')
            data = result.stdout
        else:
            data = regular(source / entry['path'], source)
        verify(data, entry)
        material.append((entry['path'], data))
    out.mkdir(parents=True)  # Exclusive destination; no existing file is changed.
    (out / '.gitignore').write_bytes(IGNORE)
    for name, data in material:
        p = out / name
        p.parent.mkdir(parents=True, exist_ok=True)
        with p.open('xb') as stream:
            stream.write(data)

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', default='build/a16-deps')
    parser.add_argument('--source-tree', type=Path)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    try:
        source = args.source_tree.absolute() if args.source_tree else None
        if source is not None and source.is_symlink():
            raise ValueError('symlink source root')
        prepare(output_path(args.out), source, args.check)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        print(f'NATIVE_JOB_CHANNEL_DEPENDENCY_ERROR: {error}', file=sys.stderr)
        return 1
    print('NATIVE_JOB_CHANNEL_DEPENDENCIES_PASS: eight exact blobs, no merge or network')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())

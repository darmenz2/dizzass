#!/usr/bin/env python3
"""Stage exact B-01 source/test dependency blobs; no network and no reference execution."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import shutil

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / 'integration/evidence/uart_posix_dependencies.json'


def checked(data, record):
    blob = hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    if blob != record['blob'] or hashlib.sha256(data).hexdigest() != record['sha256']:
        raise ValueError('dependency bytes differ: ' + record['path'])
    return data


def prepare(output, source=None, check=False):
    build = ROOT / 'build'
    output = Path(output).resolve()
    relative = output.relative_to(build.resolve())
    if build.is_symlink() or not relative.parts:
        raise ValueError('output must be a subdirectory of local build/')
    manifest = json.loads(MANIFEST.read_text())
    records = manifest['files']
    if check or output.exists():
        if not output.is_dir():
            raise ValueError('output is not a directory')
        expected = {record['path'] for record in records} | {'.gitignore'}
        actual = set()
        for item in output.rglob('*'):
            if item.is_symlink():
                raise ValueError('dependency symlink rejected')
            if item.is_file():
                actual.add(item.relative_to(output).as_posix())
        if actual != expected or (output / '.gitignore').read_text() != '*\n':
            raise ValueError('unexpected staging contents')
        for record in records:
            path = output / record['path']
            if path.is_symlink() or not path.resolve().is_relative_to(output):
                raise ValueError('dependency symlink rejected')
            checked(path.read_bytes(), record)
        return
    contents = []
    for record in records:
        if source:
            data = (Path(source) / record['path']).read_bytes()
        else:
            data = subprocess.check_output(['git', 'show',
                manifest['dependency_commit'] + ':' + record['path']], cwd=ROOT)
        contents.append((record['path'], checked(data, record)))
    output.parent.mkdir(parents=True, exist_ok=True)
    temp = Path(tempfile.mkdtemp(prefix='.uart-posix-', dir=output.parent))
    try:
        for path, data in contents:
            target = temp / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
        (temp / '.gitignore').write_text('*\n')
        temp.rename(output)  # Existing altered output is never overwritten.
    finally:
        if temp.exists():
            shutil.rmtree(temp)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, default=ROOT / 'build/a13-deps')
    parser.add_argument('--source-tree', type=Path)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    try:
        prepare(args.out, args.source_tree, args.check)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, 'UART_POSIX_DEPENDENCY_ERROR: ' + str(error) + '\n')
    print('UART_POSIX_DEPENDENCIES_PASS: exact bytes, pending PR not merged')


if __name__ == '__main__':
    main()

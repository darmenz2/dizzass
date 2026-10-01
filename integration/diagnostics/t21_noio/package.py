#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Package D-01 binaries with the exact corresponding sources; never execute them."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import zipfile

DIAG = 'integration/diagnostics/t21_noio/'
WORKFLOW = '.github/workflows/t21-noio-diagnostic.yml'
BINARIES = ('dizzass-noio-armv7', 'dizzass-noio-aarch64')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read_regular(root, name):
    p = PurePosixPath(name)
    if p.is_absolute() or '..' in p.parts or p.as_posix() != name or '\\' in name:
        raise ValueError('unsafe package path: ' + name)
    current = root
    for part in p.parts:
        current = current / part
        if current.is_symlink():
            raise ValueError('symlink in package input: ' + name)
    if not current.is_file() or current.stat().st_size > 2_000_000:
        raise ValueError('missing/oversized package input: ' + name)
    return current.read_bytes()


def collect(root, build):
    receipt_bytes = read_regular(build, 'build-receipt.json')
    receipt = json.loads(receipt_bytes)
    manifest = json.loads(read_regular(root, DIAG + 'manifest.json'))
    if receipt['base'] != manifest['base'] or receipt['pure_sources'] != manifest['pure_sources']:
        raise ValueError('receipt does not match the source manifest')
    diag_names = {str(p.relative_to(root)) for p in (root / DIAG).rglob('*')
                  if p.is_file() and '__pycache__' not in p.parts}
    if set(receipt['diagnostic_sources']) != diag_names:
        raise ValueError('diagnostic source inventory changed after build')
    if set(receipt['binaries']) != set(BINARIES):
        raise ValueError('unexpected binary inventory')
    entries = {}
    for group in ('pure_sources', 'diagnostic_sources'):
        for name, expected in receipt[group].items():
            data = read_regular(root, name)
            if sha(data) != expected:
                raise ValueError('source hash mismatch: ' + name)
            entries['source/' + name] = data
    for name in ('COPYING', WORKFLOW):
        entries['source/' + name] = read_regular(root, name)
    for name in BINARIES:
        data = read_regular(build, name)
        if sha(data) != receipt['binaries'][name]:
            raise ValueError('binary hash mismatch: ' + name)
        entries['device/' + name] = data
    entries['device/SHA256SUMS'] = ''.join(
        receipt['binaries'][name] + '  ' + name + '\n' for name in BINARIES).encode()
    entries['README_RU.md'] = entries['source/' + DIAG + 'README_RU.md']
    entries['BUILD_RECEIPT.json'] = receipt_bytes
    return entries


def write_package(entries, output, provenance=None):
    # All inputs are already read and verified before the exclusive output open.
    inventory = {'files': {p: sha(b) for p, b in sorted(entries.items())},
                 'provenance': provenance or {}, 'physical_hardware_tested': False}
    with zipfile.ZipFile(output, 'x', compression=zipfile.ZIP_DEFLATED) as z:
        for name, data in sorted({**entries, 'PACKAGE_MANIFEST.json':
                                 (json.dumps(inventory, indent=2) + '\n').encode()}.items()):
            item = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
            item.create_system = 3
            item.external_attr = 0o100644 << 16
            item.compress_type = zipfile.ZIP_DEFLATED
            z.writestr(item, data)
    return sha(output.read_bytes())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--build', required=True, type=Path)
    ap.add_argument('--out', required=True, type=Path)
    a = ap.parse_args()
    root = Path(__file__).resolve().parents[3]
    entries = collect(root, a.build.resolve())
    provenance = {key: os.environ[key] for key in
                  ('GITHUB_REPOSITORY', 'GITHUB_SHA', 'GITHUB_RUN_ID', 'GITHUB_RUN_ATTEMPT')
                  if key in os.environ}
    digest = write_package(entries, a.out, provenance)
    print('D01_PACKAGE_PASS files=' + str(len(entries) + 1) + ' sha256=' + digest)


if __name__ == '__main__':
    main()

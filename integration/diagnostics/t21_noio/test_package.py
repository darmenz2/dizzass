#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Packaging integrity tests with synthetic files; not runtime/ELF tests."""
import json
from pathlib import Path
import tempfile
import unittest
import zipfile
from package import BINARIES, DIAG, WORKFLOW, collect, sha, write_package


class PackageTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='d01-package-test-')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name) / 'source'
        self.build = Path(self.tmp.name) / 'build'
        self.build.mkdir()
        def put(name, data):
            p = self.root / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes(data)
        put('integration/codec.c', b'synthetic source, never compiled\n')
        put(DIAG + 'README_RU.md', b'synthetic manual\n')
        put('COPYING', b'synthetic license fixture\n')
        put(WORKFLOW, b'synthetic workflow fixture\n')
        self.manifest = {'base': 'synthetic-test-only', 'pure_sources': {
            'integration/codec.c': sha((self.root / 'integration/codec.c').read_bytes())}}
        put(DIAG + 'manifest.json', json.dumps(self.manifest).encode())
        for name in BINARIES:
            (self.build / name).write_bytes(('synthetic non-executable ' + name).encode())
        self.receipt = {**self.manifest, 'diagnostic_sources': {
            str(p.relative_to(self.root)): sha(p.read_bytes()) for p in (self.root / DIAG).rglob('*')
            if p.is_file()}, 'binaries': {name: sha((self.build / name).read_bytes()) for name in BINARIES}}
        self.save_receipt()

    def save_receipt(self):
        (self.build / 'build-receipt.json').write_text(json.dumps(self.receipt))

    def test_success_contents_and_repeatability(self):
        entries = collect(self.root, self.build)
        paths = [Path(self.tmp.name) / (str(i) + '.zip') for i in range(2)]
        digests = [write_package(entries, p, {'source': 'fixture'}) for p in paths]
        self.assertEqual(*digests)
        with zipfile.ZipFile(paths[0]) as z:
            record = json.loads(z.read('PACKAGE_MANIFEST.json'))
            self.assertEqual(set(record['files']), set(z.namelist()) - {'PACKAGE_MANIFEST.json'})
            for name, digest in record['files'].items():
                self.assertEqual(sha(z.read(name)), digest)
            self.assertEqual(z.read('device/' + BINARIES[0]), (self.build / BINARIES[0]).read_bytes())
            self.assertEqual(z.read('README_RU.md'), entries['README_RU.md'])

    def test_reject_changed_source(self):
        (self.root / 'integration/codec.c').write_bytes(b'changed')
        with self.assertRaisesRegex(ValueError, 'source hash mismatch'):
            collect(self.root, self.build)

    def test_reject_changed_binary(self):
        (self.build / BINARIES[0]).write_bytes(b'changed')
        with self.assertRaisesRegex(ValueError, 'binary hash mismatch'):
            collect(self.root, self.build)

    def test_reject_extra_binary(self):
        self.receipt['binaries']['miner'] = '0' * 64
        self.save_receipt()
        with self.assertRaisesRegex(ValueError, 'binary inventory'):
            collect(self.root, self.build)

    def test_reject_changed_manifest(self):
        self.receipt['base'] = 'different'
        self.save_receipt()
        with self.assertRaisesRegex(ValueError, 'source manifest'):
            collect(self.root, self.build)

    def test_reject_source_added_after_build(self):
        (self.root / DIAG / 'new.c').write_bytes(b'new')
        with self.assertRaisesRegex(ValueError, 'inventory changed'):
            collect(self.root, self.build)

    def test_reject_symlink_even_with_matching_bytes(self):
        p = self.root / 'integration/codec.c'
        target = Path(self.tmp.name) / 'outside.c'
        target.write_bytes(p.read_bytes())
        p.unlink()
        p.symlink_to(target)
        with self.assertRaisesRegex(ValueError, 'symlink'):
            collect(self.root, self.build)

    def test_reject_parent_escape(self):
        (self.root.parent / 'outside.c').write_bytes(b'outside')
        self.receipt['pure_sources'] = {'../outside.c': sha(b'outside')}
        manifest = {key: self.receipt[key] for key in ('base', 'pure_sources')}
        p = self.root / DIAG / 'manifest.json'
        p.write_text(json.dumps(manifest))
        self.receipt['diagnostic_sources'][DIAG + 'manifest.json'] = sha(p.read_bytes())
        self.save_receipt()
        with self.assertRaisesRegex(ValueError, 'unsafe package path'):
            collect(self.root, self.build)

    def test_never_overwrite_output(self):
        p = Path(self.tmp.name) / 'existing.zip'
        p.write_bytes(b'keep me')
        with self.assertRaises(FileExistsError):
            write_package(collect(self.root, self.build), p)
        self.assertEqual(p.read_bytes(), b'keep me')


if __name__ == '__main__':
    unittest.main(verbosity=2)

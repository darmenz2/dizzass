#!/usr/bin/env python3
"""Frozen R-06 scope: three exact R-03 replacements, no other old-file edits."""
from pathlib import Path
import subprocess
BASE = '12446bed78a060a49364a80bcbfb4340b13f4f27'
EXPECTED = {
    'integration/native_jobs.c': '566529ae9774174659436b0ae6e3cc713f40f467',
    'integration/native_jobs.h': 'cf6f3c5b21d090bb9a94f679c4528fedee2fa4e5',
    'integration/native_submit.h': '373dc3c16fb0a80d848e2c823154095c3f319aa6',
}
def validate(changes, blobs):
    if len(changes) != len(EXPECTED) or set(changes) != {('M', p) for p in EXPECTED}:
        raise ValueError('unexpected modified/deleted/renamed original path')
    if blobs != EXPECTED:
        raise ValueError('original path does not match the exact R-03 blob')
def main():
    root = Path(__file__).resolve().parents[3]
    def git(*args):
        return subprocess.run(['git', *args], cwd=root, check=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=30).stdout.decode().strip()
    try:
        changes = [tuple(line.split('\t')) for line in git('diff', '--name-status',
            '--diff-filter=MDR', BASE, 'HEAD').splitlines()]
        blobs = {p: git('rev-parse', 'HEAD:' + p) for p in EXPECTED}
        validate(changes, blobs)
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print('R06_LEGACY_SCOPE_REJECT:', error)
        return 1
    print('R06_LEGACY_SCOPE_PASS exact_r03_replacements=3 deletions=0 renames=0')
    return 0
if __name__ == '__main__':
    raise SystemExit(main())

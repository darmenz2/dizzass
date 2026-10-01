#!/usr/bin/env python3
"""Compile real translation units separately; run only bounded host fixtures.

No firmware, interpreter, prior oracle, hardware, real wait, OOM/fault probe,
network service or production binding is part of this runner.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

SOURCES = [
    'libbitmain/src/chip/chip1368.c',
    'libbitmain/src/chip/chip1368-register-write.c',
    'libbitmain/src/reg_cache.c',
    'integration/bm1368_control.c',
    'reconstruction/support/crc5.c',
    'libbitmain/src/transport-dispatch.c',
    'libbitmain/src/aml/chip.c',
    'libbitmain/src/uart.c',
]
TESTS = {'test_original_reset.c': 'ORIGINAL_RESET_PASS',
         'test_composed_reset.c': 'COMPOSED_RESET_PASS'}


def checked(command, **kwargs):
    result = subprocess.run(command, capture_output=True, text=True, **kwargs)
    if result.returncode:
        sys.stderr.write(result.stdout + result.stderr)
        result.check_returncode()
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--test', type=Path)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--cc', default=os.environ.get('CC', 'cc'))
    parser.add_argument('--sanitize', action='store_true')
    args = parser.parse_args()
    root, build = args.root.resolve(), args.build.resolve()
    build.mkdir(parents=True, exist_ok=True)
    test_dir = Path(__file__).resolve().parent
    tests = [args.test.resolve()] if args.test else [test_dir / name for name in TESTS]
    if any(test.name not in TESTS for test in tests):
        parser.error('--test must name one of this packet\'s two host fixtures')
    flags = ['-I' + str(root), '-I' + str(root / 'include'), '-std=c11',
             '-O1' if args.sanitize else '-O2', '-g', '-Wall', '-Wextra',
             '-Wpedantic', '-Werror', '-Wconversion', '-Wshadow',
             '-DVN135_BM1368_RESET_135', '-DVN135_BM1368_REGISTER_WRITE_135',
             '-DVN135_TRANSPORT_DISPATCH_135']
    san = ['-fsanitize=address,undefined', '-fno-omit-frame-pointer', '-fno-pie'] if args.sanitize else []
    records, results = [], []
    source_paths = [root / source for source in SOURCES]
    objects = []
    for number, source in enumerate(source_paths):
        extra = []
        if args.sanitize and source == root / 'reconstruction/support/crc5.c':
            # Existing L09 exception: GCC 14 ASan/-O1 warns about unsigned
            # conversion of a promoted uint8_t right shift (always 0..255).
            # Preserve the pinned helper. This unchanged TU alone receives
            # -Wno-sign-conversion; every TU remains ASan/UBSan instrumented.
            extra = ['-Wno-sign-conversion']
        obj = build / f'unit-{number}.o'
        command = [args.cc, *flags, *san, *extra, '-c', str(source), '-o', str(obj)]
        checked(command, timeout=60)
        objects.append(str(obj))
        records.append({'source': str(source), 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'command': command})
    for test in tests:
        obj, exe = build / (test.stem + '.o'), build / test.stem
        command = [args.cc, *flags, *san, '-c', str(test), '-o', str(obj)]
        checked(command, timeout=60)
        records.append({'source': str(test), 'sha256': hashlib.sha256(test.read_bytes()).hexdigest(), 'command': command})
        command = [args.cc, *san, *(['-no-pie'] if args.sanitize else []), *objects, str(obj), '-o', str(exe)]
        checked(command, timeout=30)
        environment = dict(os.environ)
        if args.sanitize:
            environment.update(ASAN_OPTIONS='detect_leaks=0:halt_on_error=1', UBSAN_OPTIONS='halt_on_error=1')
        result = checked([str(exe)], timeout=120, env=environment)
        if TESTS[test.name] not in result.stdout:
            raise ValueError('missing pass marker: ' + test.name)
        results.append({'test': str(test), 'link_command': command, 'stdout': result.stdout,
                        'stderr': result.stderr, 'returncode': result.returncode})
        print(result.stdout, end='')
    (build / 'compile-records.json').write_text(json.dumps(records, indent=2) + '\n')
    (build / 'results.json').write_text(json.dumps({'sanitized': args.sanitize, 'tests': results}, indent=2) + '\n')


if __name__ == '__main__':
    main()

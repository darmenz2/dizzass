#!/usr/bin/env python3
"""Build each real TU separately and execute only the new bounded host test.

No original executable/interpreter, old test, hardware/OS UART, real sleep,
model/Jansson/OOM/malformed-pointer probe, network, CI or remote operation.
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
    'libbitmain/src/chip/chip1398.c',
    'libbitmain/src/chip/chip1368-register-write.c',
    'libbitmain/src/chip/chip1368-pulse-width.c',
    'libbitmain/src/reg_cache.c',
    'integration/bm1368_control.c',
    'reconstruction/support/crc5.c',
    'libbitmain/src/transport-dispatch.c',
    'libbitmain/src/aml/chip.c',
    'libbitmain/src/uart.c',
]


def checked(command, **kwargs):
    result = subprocess.run(command, capture_output=True, text=True, **kwargs)
    if result.returncode:
        sys.stderr.write(result.stdout + result.stderr)
        result.check_returncode()
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--cc', default=os.environ.get('CC', 'cc'))
    parser.add_argument('--sanitize', action='store_true')
    args = parser.parse_args()
    root, build = args.root.resolve(), args.build.resolve()
    build.mkdir(parents=True, exist_ok=True)
    test = Path(__file__).resolve().parent / 'test_sweep_clock.c'
    compiler_version = checked([args.cc, '--version'], timeout=10).stdout
    (build / 'compiler-version.txt').write_text(compiler_version)
    flags = ['-I' + str(root), '-I' + str(root / 'include'), '-std=c11',
             '-O1' if args.sanitize else '-O2', '-g', '-Wall', '-Wextra',
             '-Wpedantic', '-Werror', '-Wconversion', '-Wshadow',
             '-DVN135_BM1368_SWEEP_CLOCK_135',
             '-DVN135_BM1368_TICKET_MASK_135',
             '-DVN135_BM1368_PULSE_WIDTH_135',
             '-DVN135_BM1368_REGISTER_WRITE_135',
             '-DVN135_TRANSPORT_DISPATCH_135']
    san = ['-fsanitize=address,undefined', '-fno-omit-frame-pointer', '-fno-pie'] if args.sanitize else []
    records, objects = [], []
    for number, source in enumerate([root / name for name in SOURCES] + [test]):
        extra = []
        if args.sanitize and source == root / 'reconstruction/support/crc5.c':
            # Same pinned-CRC-only exception documented by L10: GCC ASan/-O1
            # warns for the promoted uint8_t shift, whose value is 0..255.
            # No source changes; all linked TUs still receive ASan/UBSan.
            extra = ['-Wno-sign-conversion']
        obj = build / f'unit-{number}.o'
        command = [args.cc, *flags, *san, *extra, '-c', str(source), '-o', str(obj)]
        compiled = subprocess.run(command, capture_output=True, text=True, timeout=60)
        records.append({'source': str(source),
                        'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                        'command': command,
                        'returncode': compiled.returncode,
                        'stdout': compiled.stdout,
                        'stderr': compiled.stderr,
                        'object_sha256': hashlib.sha256(obj.read_bytes()).hexdigest()
                        if compiled.returncode == 0 else None})
        # Preserve partial compilation evidence on a strict compiler failure.
        (build / 'compile-records.json').write_text(json.dumps(records, indent=2) + '\n')
        if compiled.returncode:
            sys.stderr.write(compiled.stdout + compiled.stderr)
            compiled.check_returncode()
        objects.append(str(obj))
    exe = build / 'test_sweep_clock'
    command = [args.cc, *san, *(['-no-pie'] if args.sanitize else []),
               '-Wl,--wrap=vn135_bm1368_write_register_135',
               *objects, '-o', str(exe)]
    linked = subprocess.run(command, capture_output=True, text=True, timeout=30)
    (build / 'link-result.json').write_text(json.dumps({
        'command': command, 'returncode': linked.returncode,
        'stdout': linked.stdout, 'stderr': linked.stderr}, indent=2) + '\n')
    if linked.returncode:
        sys.stderr.write(linked.stdout + linked.stderr)
        linked.check_returncode()
    environment = dict(os.environ)
    if args.sanitize:
        environment.update(ASAN_OPTIONS='detect_leaks=0:halt_on_error=1',
                           UBSAN_OPTIONS='halt_on_error=1')
    result = subprocess.run([str(exe)], capture_output=True, text=True,
                            timeout=120, env=environment)
    report = {'sanitized': args.sanitize, 'test': str(test), 'link_command': command,
              'translation_units': len(records), 'compiler_version': compiler_version,
              'executable_sha256': hashlib.sha256(exe.read_bytes()).hexdigest(),
              'stdout': result.stdout, 'stderr': result.stderr,
              'returncode': result.returncode,
              'semantic_failure': 'ORIGINAL_SWEEP_CLOCK_FAIL' in result.stderr,
              'pass_marker': 'ORIGINAL_SWEEP_CLOCK_PASS' in result.stdout}
    (build / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    sys.stdout.write(result.stdout)
    sys.stderr.write(result.stderr)
    if result.returncode:
        result.check_returncode()
    if not report['pass_marker'] or report['semantic_failure']:
        raise ValueError('missing pass marker or unexpected semantic failure')


if __name__ == '__main__':
    main()

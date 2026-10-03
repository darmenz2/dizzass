#!/usr/bin/env python3
"""Compile each authored unit; run only the bounded host callback fixture."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys

SOURCES = [
    'libbitmain/src/chip/chip1368.c',
    'integration/bm1368_group_register_135.c',
    'libbitmain/src/chip/chip1368-register-write.c',
    'libbitmain/src/reg_cache.c',
    'integration/bm1368_control.c',
    'reconstruction/support/crc5.c',
    'libbitmain/src/transport-dispatch.c',
    'libbitmain/src/aml/chip.c',
    'libbitmain/src/uart.c',
]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--test', type=Path, default=Path(__file__).with_name('test_group_register.c'))
    parser.add_argument('--cc', default=os.environ.get('CC', 'gcc'))
    parser.add_argument('--sanitize', action='store_true')
    args = parser.parse_args()
    root, build = args.root.resolve(), args.build.resolve()
    build.mkdir(parents=True, exist_ok=True)
    record = {'sanitize_all_translation_units': args.sanitize,
              'commands': [], 'objects': [], 'dependencies': {}, 'result': 'incomplete'}

    def save():
        (build/'compile-records.json').write_text(json.dumps(record, indent=2)+'\n')

    def run(command, timeout=45, env=None):
        result = subprocess.run(command, capture_output=True, text=True, timeout=timeout, env=env)
        record['commands'].append({'command': command, 'returncode': result.returncode,
                                   'stdout': result.stdout, 'stderr': result.stderr})
        save()
        if result.returncode:
            sys.stderr.write(result.stdout+result.stderr)
            result.check_returncode()
        return result

    flags = ['-I'+str(root), '-I'+str(root/'include'), '-std=c11',
             '-O1' if args.sanitize else '-O2', '-g', '-Wall', '-Wextra',
             '-Wpedantic', '-Werror', '-Wconversion', '-Wshadow',
             '-DVN135_BM1368_DRIVE_STRENGTH_135', '-DVN135_BM1368_REGISTER_WRITE_135',
             '-DVN135_TRANSPORT_DISPATCH_135']
    instrument = ['-fsanitize=address,undefined', '-fno-omit-frame-pointer', '-fno-pie'] if args.sanitize else []
    try:
        run([args.cc, '--version'])
        record['runner_sha256'] = digest(Path(__file__))
        objects = []
        for number, source in enumerate([root/name for name in SOURCES]+[args.test.resolve()]):
            obj, deps = build/f'unit-{number}.o', build/f'unit-{number}.d'
            before = digest(source)
            # Existing promoted-byte warning in GCC's instrumented CRC unit;
            # this one warning is suppressed, while the entire TU is sanitized.
            extra = ['-Wno-sign-conversion'] if args.sanitize and source == root/'reconstruction/support/crc5.c' else []
            run([args.cc, *flags, *instrument, *extra, '-MMD', '-MF', str(deps),
                 '-c', str(source), '-o', str(obj)])
            if before != digest(source):
                raise RuntimeError('source changed while compiling: '+str(source))
            dependencies = shlex.split(deps.read_text().replace('\\\n', ' ').split(':', 1)[1])
            for name in dependencies:
                path = Path(name).resolve()
                identity = digest(path)
                if str(path) in record['dependencies'] and record['dependencies'][str(path)] != identity:
                    raise RuntimeError('dependency changed while compiling: '+str(path))
                record['dependencies'][str(path)] = identity
            record['objects'].append({'source': str(source), 'source_sha256': before,
                                      'object': str(obj), 'object_sha256': digest(obj),
                                      'instrumented': args.sanitize})
            objects.append(str(obj)); save()
        exe = build/'test-group-register'
        run([args.cc, *instrument, *(['-no-pie'] if args.sanitize else []), *objects, '-o', str(exe)])
        record['executable_sha256'] = digest(exe)
        env = dict(os.environ)
        if args.sanitize:
            env.update(ASAN_OPTIONS='detect_leaks=0:halt_on_error=1',
                       UBSAN_OPTIONS='halt_on_error=1:print_stacktrace=1')
            record['sanitizer_environment'] = {key:env[key] for key in ('ASAN_OPTIONS','UBSAN_OPTIONS')}
        result = run([str(exe)], timeout=30, env=env)
        counts = json.loads(result.stdout)
        if set(counts) != {'cases','checks','group_cases','composed_cases'} or any(type(v) is not int or v <= 0 for v in counts.values()):
            raise RuntimeError('invalid host-fixture result')
        record['result'] = 'passed'; record['counts'] = counts
        print(json.dumps(counts))
    except Exception as error:
        record['result'] = 'failed'; record['error'] = str(error)
        raise
    finally:
        save()


if __name__ == '__main__':
    main()

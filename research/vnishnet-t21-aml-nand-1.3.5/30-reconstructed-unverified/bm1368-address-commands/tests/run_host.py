#!/usr/bin/env python3
"""Build the real command/transport units separately; run only the host fixture."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

SOURCES = [
    'libbitmain/src/chip/chip1368.c', 'libbitmain/src/chip/chip.c',
    'integration/bm1368_control.c', 'reconstruction/support/crc5.c',
    'libbitmain/src/transport-dispatch.c', 'libbitmain/src/aml/chip.c',
    'libbitmain/src/uart.c',
]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--test', type=Path,
                        default=Path(__file__).with_name('test_address_commands.c'))
    parser.add_argument('--cc', default=os.environ.get('CC', 'gcc'))
    parser.add_argument('--sanitize', action='store_true')
    args = parser.parse_args()
    root, build = args.root.resolve(), args.build.resolve()
    build.mkdir(parents=True, exist_ok=True)
    record = {'sanitize_all_translation_units': args.sanitize,
              'commands': [], 'objects': [], 'result': 'incomplete'}

    def save():
        (build / 'compile-records.json').write_text(json.dumps(record, indent=2) + '\n')

    def run(command, timeout=45, env=None):
        result = subprocess.run(command, capture_output=True, text=True,
                                timeout=timeout, env=env)
        record['commands'].append({'command': command, 'returncode': result.returncode,
                                   'stdout': result.stdout, 'stderr': result.stderr})
        save()
        if result.returncode:
            sys.stderr.write(result.stdout + result.stderr)
            result.check_returncode()
        return result

    flags = ['-I' + str(root), '-I' + str(root / 'include'), '-std=c11',
             '-O1' if args.sanitize else '-O2', '-g', '-Wall', '-Wextra',
             '-Wpedantic', '-Werror', '-Wconversion', '-Wshadow',
             '-DVN135_BM1368_ADDRESS_COMMANDS_135',
             '-DVN135_COMMON_READ_REGISTER_135', '-DVN135_TRANSPORT_DISPATCH_135']
    instrument = (['-fsanitize=address,undefined', '-fno-omit-frame-pointer', '-fno-pie']
                  if args.sanitize else [])
    try:
        run([args.cc, '--version'])
        record['runner_sha256'] = digest(Path(__file__))
        record['headers'] = {
            name: digest(root / name) for name in [
                'integration/bm1368_address_commands_135.h',
                'integration/common_read_register_135.h',
                'integration/transport_dispatch_135.h',
                'integration/bm1368_control.h',
                'integration/bm1368_nonce.h',
                'include/xminer/recovery/chip1398.h',
                'include/xminer/recovery/aml_chip.h',
                'include/xminer/recovery/uart.h',
                'include/xminer/recovery/pll.h',
                'include/xminer/recovery/reg_cache.h',
            ]
        }
        objects = []
        for number, source in enumerate([root / name for name in SOURCES] +
                                        [args.test.resolve()]):
            obj = build / f'unit-{number}.o'
            before = digest(source)
            # Existing CRC TU has a promoted uint8_t shift warning at -O1
            # under GCC ASan. Narrow warning exception only; still instrument it.
            extra = (['-Wno-sign-conversion'] if args.sanitize and
                     source == root / 'reconstruction/support/crc5.c' else [])
            run([args.cc, *flags, *instrument, *extra, '-c', str(source), '-o', str(obj)])
            if before != digest(source):
                raise RuntimeError(f'source changed while compiling: {source}')
            record['objects'].append({'source': str(source), 'source_sha256': before,
                                      'object': str(obj), 'object_sha256': digest(obj),
                                      'instrumented': args.sanitize})
            objects.append(str(obj))
            save()
        exe = build / 'test-address-commands'
        run([args.cc, *instrument, *(['-no-pie'] if args.sanitize else []),
             *objects, '-o', str(exe)], timeout=30)
        record['executable_sha256'] = digest(exe)
        env = dict(os.environ)
        if args.sanitize:
            env.update(ASAN_OPTIONS='detect_leaks=0:halt_on_error=1',
                       UBSAN_OPTIONS='halt_on_error=1:print_stacktrace=1')
            record['sanitizer_environment'] = {key: env[key] for key in
                                               ('ASAN_OPTIONS', 'UBSAN_OPTIONS')}
        result = run([str(exe)], timeout=30, env=env)
        if 'ADDRESS_COMMANDS_PASS' not in result.stdout:
            raise RuntimeError('missing host-fixture pass marker')
        record['result'] = 'passed'
        print(result.stdout, end='')
    except Exception as error:
        record['result'] = 'failed'
        record['error'] = str(error)
        raise
    finally:
        save()


if __name__ == '__main__':
    main()

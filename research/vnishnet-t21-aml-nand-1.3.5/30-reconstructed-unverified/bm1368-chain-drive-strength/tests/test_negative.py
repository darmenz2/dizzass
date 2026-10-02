#!/usr/bin/env python3
"""Compiled semantic controls: only explicit oracle failures count.
Build errors, signals and timeouts are not evidence of semantic detection.
"""
import argparse
import json
from pathlib import Path
import shlex
import subprocess


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--root', type=Path, required=True)
    p.add_argument('--cc', default='cc')
    p.add_argument('--build', type=Path, required=True)
    a = p.parse_args()
    root, build = a.root.resolve(), a.build.resolve()
    original = (root/'libbitmain/src/chip/chip1368-chain-drive-strength.c').read_text()
    cache_call = 'reader->read_cached(reader->context, signed_index_135(device->index),\n            0x58, &value)'
    variants = {
        'baseline': original,
        'chip-instead-of-common': original.replace('vn135_reg_cache_get_chain(context, chain, reg, output)', 'vn135_reg_cache_get_chip(context, chain, 0, reg, output)'),
        'nonzero-output': original.replace('uint32_t value = 0;', 'uint32_t value = 1;'),
        'wrong-read-register': original.replace('0x58, &value', '0x59, &value'),
        'ignore-read-status': original.replace(cache_call, '('+cache_call+', 0)'),
        'extra-read': original.replace('uint32_t value = 0;', 'uint32_t value = 0;\n    uint32_t extra = 0;\n    (void)reader->read_cached(reader->context, signed_index_135(device->index), 0x58, &extra);'),
        'mask-three-bits': original.replace('input & 15u', 'input & 7u'),
        'clear-extra-bits': original.replace('~UINT32_C(0xf000)', '~UINT32_C(0xffff)'),
        'wrong-shift': original.replace('<< 12', '<< 13'),
        'unicast': original.replace('device, 1, NULL', 'device, 0, NULL'),
        'wrong-write-register': original.replace('NULL, 0x58, value', 'NULL, 0x59, value'),
        'read-log-has-index': original.replace('635, 1, 0, 0', '635, 1, 1, 0'),
        'normalized-read-typo': original.replace('driver strenght', 'drive strength'),
        'wrong-write-line': original.replace('645, 1, 1,', '646, 1, 1,'),
        'wrong-write-format': original.replace('failed to config drive strength', 'failed to set drive strength'),
        'failure-success': original.replace('return -1;', 'return 0;'),
        'double-log': original.replace('log->emit(log->context, &diagnostic);', 'log->emit(log->context, &diagnostic);\n    log->emit(log->context, &diagnostic);'),
        'early-index': original.replace('uint32_t value = 0;', 'const uint32_t early_index = device->index;\n    uint32_t value = 0;').replace('device->index + UINT32_C(1)', 'early_index + UINT32_C(1)'),
    }
    common = [root/r for r in ('libbitmain/src/chip/chip1368-register-write.c',
        'libbitmain/src/chip/chip1368-frequency.c', 'libbitmain/src/pll.c',
        'libbitmain/src/reg_cache.c', 'integration/bm1368_control.c',
        'reconstruction/support/crc5.c')]
    test = Path(__file__).resolve().with_name('test_chain_drive_strength.c')
    flags = ['-std=c11', '-O1', '-g', '-Wall', '-Wextra', '-Wpedantic', '-Werror',
        '-fno-fast-math', '-ffp-contract=off', '-I'+str(root), '-I'+str(root/'include'),
        '-DVN135_BM1368_REGISTER_WRITE_135', '-DVN135_BM1368_FREQUENCY_135',
        '-DVN135_BM1368_CHAIN_DRIVE_STRENGTH_135']
    results = []
    for name, text in variants.items():
        if name != 'baseline' and text == original:
            raise RuntimeError('empty control: '+name)
        folder = build/name
        folder.mkdir(parents=True, exist_ok=True)
        variant, exe = folder/'runtime.c', folder/'test'
        variant.write_text(text)
        built = subprocess.run(shlex.split(a.cc)+flags+[str(v) for v in common]+[str(variant), str(test), '-o', str(exe)], capture_output=True, text=True, timeout=90)
        (folder/'build.log').write_text(built.stdout+built.stderr)
        if built.returncode:
            raise RuntimeError('control compilation failed: '+name)
        ran = subprocess.run([str(exe)], capture_output=True, text=True, timeout=45)
        (folder/'run.log').write_text(ran.stdout+ran.stderr)
        ok = (ran.returncode == 0 and 'BM1368_CHAIN_DRIVE135_HOST_PASS' in ran.stdout) if name == 'baseline' else (ran.returncode == 1 and 'CHAIN_DRIVE135_FAIL' in ran.stderr)
        if not ok:
            raise RuntimeError('required oracle result absent: '+name)
        results.append({'name': name, 'compiled': True, 'exit_code': ran.returncode, 'explicit_oracle_result': True})
    report = {'compiler': a.cc, 'baseline_passed': True, 'semantic_controls_detected': len(results)-1, 'results': results, 'original_executed': False}
    (build/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()

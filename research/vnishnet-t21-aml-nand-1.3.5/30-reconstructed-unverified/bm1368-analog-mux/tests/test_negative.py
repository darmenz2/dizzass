#!/usr/bin/env python3
"""Compile semantic controls; require the host oracle's explicit failure.

Build failures, signals, unexpected statuses and timeouts are NOT detection.
No reference executable or firmware instructions run.
"""
import argparse
import json
from pathlib import Path
import shlex
import subprocess


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--cc', default='cc')
    parser.add_argument('--build', type=Path, required=True)
    args = parser.parse_args()
    root, build = args.root.resolve(), args.build.resolve()
    build.mkdir(parents=True, exist_ok=True)
    source = root / 'libbitmain/src/chip/chip1368-analog-mux.c'
    original = source.read_text()
    diag = 'device->index + UINT32_C(1)'
    variants = {
        'baseline': original,
        'high-bits-unmasked': original.replace('vn135_bm1398_analog_mux_word(input)', 'input'),
        'extra-value-bit': original.replace('vn135_bm1398_analog_mux_word(input)', 'vn135_bm1398_analog_mux_word(input) | 8u'),
        'wrong-register': original.replace('NULL, 0x54, value', 'NULL, 0x55, value'),
        'unicast': original.replace('device, 1, NULL', 'device, 0, NULL'),
        'wrong-line': original.replace('425, 1,', '426, 1,'),
        'wrong-severity': original.replace('425, 1,', '425, 2,'),
        'wrong-format': original.replace('failed to set ANALOG_MUX_CTRL', 'failed to set CLOCK_DELAY_CTRL'),
        'failure-is-success': original.replace('return -1;', 'return 0;'),
        'status-one': original.replace('return -1;', 'return 1;'),
        'duplicate-log': original.replace('log->emit(log->context, &diagnostic);',
            'log->emit(log->context, &diagnostic);\n    log->emit(log->context, &diagnostic);'),
        'early-index': original.replace('const uint32_t value =',
            'const uint32_t early_index = device->index;\n    const uint32_t value =').replace(diag, 'early_index + UINT32_C(1)'),
    }
    common = [root / rel for rel in (
        'libbitmain/src/chip/chip1368-register-write.c',
        'libbitmain/src/chip/chip1368-frequency.c', 'libbitmain/src/pll.c',
        'libbitmain/src/reg_cache.c', 'integration/bm1368_control.c',
        'reconstruction/support/crc5.c', 'libbitmain/src/chip/chip1398.c')]
    test = Path(__file__).resolve().with_name('test_analog_mux.c')
    flags = ['-std=c11', '-O1', '-g', '-Wall', '-Wextra', '-Wpedantic', '-Werror',
        '-fno-fast-math', '-ffp-contract=off', '-I'+str(root), '-I'+str(root/'include'),
        '-DVN135_BM1368_REGISTER_WRITE_135', '-DVN135_BM1368_FREQUENCY_135',
        '-DVN135_BM1368_ANALOG_MUX_135']
    results = []
    for name, text in variants.items():
        if name != 'baseline' and text == original:
            raise RuntimeError('control did not change source: '+name)
        folder = build/name
        folder.mkdir(parents=True, exist_ok=True)
        variant, executable = folder/'runtime.c', folder/'test'
        variant.write_text(text)
        command = shlex.split(args.cc)+flags+[str(p) for p in common]+[str(variant),str(test),'-o',str(executable)]
        built = subprocess.run(command, capture_output=True, text=True, timeout=90)
        (folder/'build.log').write_text(built.stdout+built.stderr)
        if built.returncode != 0:
            raise RuntimeError('control build failed: '+name)
        ran = subprocess.run([str(executable)], capture_output=True, text=True, timeout=45)
        (folder/'run.log').write_text(ran.stdout+ran.stderr)
        if name == 'baseline':
            ok = ran.returncode == 0 and 'BM1368_ANALOG_MUX135_HOST_PASS' in ran.stdout
        else:
            ok = ran.returncode == 1 and 'ANALOG_MUX135_FAIL' in ran.stderr
        if not ok:
            raise RuntimeError('control did not produce required oracle result: '+name)
        results.append({'name':name, 'compiled':True, 'exit_code':ran.returncode,
                        'explicit_oracle_result':True})
    report = {'compiler':args.cc,'baseline_passed':True,'semantic_controls_detected':len(results)-1,
              'results':results,'original_executed':False}
    (build/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report))


if __name__ == '__main__':
    main()

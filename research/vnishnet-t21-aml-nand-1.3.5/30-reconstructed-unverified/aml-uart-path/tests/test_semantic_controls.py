#!/usr/bin/env python3
"""Compile safe, deliberate misrouting variants; never execute vendor code."""
import argparse
import json
import pathlib
import shlex
import subprocess

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[4]
SOURCE = ROOT / 'libbitmain/src/aml/platform.c'
HEADER = ROOT / 'include'
TEST = HERE / 'test_aml_uart_path.c'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cc', default='cc')
    parser.add_argument('--build', type=pathlib.Path, required=True)
    args = parser.parse_args()
    args.build.mkdir(parents=True, exist_ok=True)
    original = SOURCE.read_text()
    # These variants remain memory-safe: every wrong indexed return is guarded.
    controls = [
        ('wrong_chain0', '"/dev/ttyS3"', '"/dev/ttyS9"'),
        ('wrong_chain1', '"/dev/ttyS2"', '"/dev/ttyS8"'),
        ('wrong_chain2', '"/dev/ttyS1"', '"/dev/ttyS7"'),
        ('invalid_falls_back', 'return "";', 'return paths[0];'),
        ('invalid_null', 'return "";', 'return NULL;'),
        ('reject_chain2', 'if (chain_index < sizeof(paths) / sizeof(paths[0]))',
         'if (chain_index < sizeof(paths) / sizeof(paths[0]) && chain_index != 2u)'),
        ('wrap_index', 'if (chain_index < sizeof(paths) / sizeof(paths[0]))',
         'chain_index &= 3u;\n    if (chain_index < sizeof(paths) / sizeof(paths[0]))'),
        ('invalid_nonempty', 'return "";', 'return "unknown";'),
    ]
    reports = []
    for name, before, after in [('pristine', '', '')] + controls:
        if name == 'pristine':
            text = original
        else:
            if original.count(before) != 1:
                raise ValueError('control source anchor must occur once: ' + name)
            text = original.replace(before, after)
        variant = args.build / (name + '.c')
        binary = args.build / name
        variant.write_text(text)
        command = shlex.split(args.cc) + ['-std=c11', '-Wall', '-Wextra', '-Werror',
            '-Wconversion', '-Wshadow', '-pedantic', '-O2', '-I' + str(ROOT),
            '-I' + str(HEADER), str(variant), str(TEST), '-o', str(binary)]
        compiled = subprocess.run(command, text=True, capture_output=True, check=False)
        (args.build / (name + '-compile.log')).write_text(compiled.stdout + compiled.stderr)
        if compiled.returncode:
            raise RuntimeError('compile failed; not a detected semantic control: ' + name)
        run = subprocess.run([str(binary.resolve())], text=True, capture_output=True,
                             check=False, timeout=15)
        (args.build / (name + '.log')).write_text(run.stdout + run.stderr)
        expected = 0 if name == 'pristine' else 1
        if run.returncode != expected:
            raise RuntimeError('expected controlled return %s, got %s: %s' %
                               (expected, run.returncode, name))
        reports.append(dict(name=name, compile_exit=compiled.returncode,
                            run_exit=run.returncode, expected_exit=expected))
    result = dict(pristine_passed=True, semantic_controls_rejected=len(controls),
                  crashes_counted_as_detection=False, firmware_executed=False,
                  reports=reports)
    (args.build / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, sort_keys=True))


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Compile bounded semantic mutants of the authored reset, never vendor code.

Every control uses valid ordinary storage and the record-only unit fixture.
A compiler error, timeout or unrelated crash is not an accepted test failure.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def replace_exact(text, old, new, occurrences=1, replacements=1):
    if text.count(old) != occurrences:
        raise ValueError('semantic control anchor changed: ' + old)
    return text.replace(old, new, replacements)


def controls(body):
    substitutions = [
        ('normal-return-is-zero', '    return 0;\n}', '    return -1;\n}', 1),
        ('fast-is-full-word', 'fast != 0 ? 1u : 5u', '(fast & 1u) != 0 ? 1u : 5u', 1),
        ('unused-fourth-scalar', '(void)unused;', 'clock ^= unused;', 1),
        ('positive-status-is-failure', '!= 0)', '< 0)', 7),
        ('r1-clear-both-bits', 'value & ~UINT32_C(0x300)', 'value & ~UINT32_C(0x100)', 1),
        ('r2-soft-reset-mask', 'value |= UINT32_C(0x1f0)', 'value |= UINT32_C(0x1e0)', 1),
        ('r3-clear-required-bits', 'misc & UINT32_C(0x00f0ffff)', 'misc & UINT32_C(0x00ffffff)', 1),
        ('r3-high-nibble', '| UINT32_C(0xf0000000)', '| UINT32_C(0xe0000000)', 1),
        ('w2-gates-w3-on-zero', '0xa8, value) == 0)', '0xa8, value) != 0)', 1),
        ('r4-set-both-bits', 'value | UINT32_C(0x300)', 'value | UINT32_C(0x100)', 1),
        ('sweep-command-value', 'UINT32_C(0x80008b00)', 'UINT32_C(0x80008a00)', 1),
        ('clock-mask-three-bits', '(clock & 7u)', '(clock & 15u)', 1),
        ('clock-shift-three', '(clock & 7u) << 3', '(clock & 7u) << 4', 1),
        ('pulse-mask-two-bits', '(pulse & 3u)', '(pulse & 7u)', 1),
        ('final-core-command', 'UINT32_C(0x800082aa)', 'UINT32_C(0x800082ab)', 1),
        ('final-ten-ms-wait', 'ops->wait_context, 10)', 'ops->wait_context, 9)', 1),
        ('misc-log-line', 'device, 844, misc_error', 'device, 845, misc_error', 2),
        ('clock-log-line-not-pulse', 'device, 538,', 'device, 569,', 1),
        ('wrapped-one-based-log-index', 'device->index + UINT32_C(1)', 'device->index', 1),
        ('r2-output-zero', '    value = 0;\n    misc = 0;', '    value = 1;\n    misc = 0;', 1),
        ('r3-output-zero', '    misc = 0;', '    misc = 1;', 1),
    ]
    for name, old, new, count in substitutions:
        yield name, replace_exact(body, old, new, count)
    yield 'write-mode-is-zero', replace_exact(body, 'device, 0, chip,',
        'device, 1, chip,', occurrences=7, replacements=7)
    yield 'fresh-device-cache-index', replace_exact(
        replace_exact(body, '    uint32_t value = 0, misc;',
            '    uint32_t value = 0, misc;\n    const uint32_t saved_index = device->index;'),
        'reset_signed_index_135(device->index)', 'reset_signed_index_135(saved_index)',
        occurrences=4, replacements=4)
    yield 'fresh-chip-cache-index', replace_exact(
        replace_exact(body, '    uint32_t value = 0, misc;',
            '    uint32_t value = 0, misc;\n    const int32_t saved_chip = chip->cache_index;'),
        'chip->cache_index,', 'saved_chip,', occurrences=4, replacements=4)
    yield 'ignored-first-write-result', replace_exact(body,
        '    else\n        (void)ops->write_register(ops->write_context, device, 0, chip,\n'
        '            0x18, value & ~UINT32_C(0x300));',
        '    else if (ops->write_register(ops->write_context, device, 0, chip,\n'
        '            0x18, value & ~UINT32_C(0x300)) != 0)\n        return -1;')
    yield 'ignored-delay-result', replace_exact(body,
        '    (void)ops->wait_ms(ops->wait_context, delay);',
        '    if (ops->wait_ms(ops->wait_context, delay) != 0) return -1;',
        occurrences=4)
    yield 'second-w6-diagnostic', replace_exact(body,
        '        reset_diagnostic_135(ops, device, 538,\n'
        '            "chain#%d - failed to set CLOCK_DELAY_CTRL", 1);', '')


def checked(command):
    result = subprocess.run(command, capture_output=True, text=True, timeout=45)
    if result.returncode:
        sys.stderr.write(result.stdout + result.stderr)
        result.check_returncode()
    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--root', type=Path, required=True)
    parser.add_argument('--cc', default=os.environ.get('CC', 'cc'))
    args = parser.parse_args()
    root = args.root.resolve()
    folder = Path(__file__).resolve().parent.parent
    raw = (root / 'libbitmain/src/chip/chip1368.c').read_text()
    gate = '\n#ifdef VN135_BM1368_RESET_135\n'
    if raw.count(gate) != 1:
        raise ValueError('expected one separately gated reset append')
    prefix, body = raw.split(gate)
    variants = list(controls(body))
    flags = ['-I' + str(root), '-I' + str(root / 'include'), '-std=c11', '-O2',
             '-Wall', '-Wextra', '-Wpedantic', '-Werror', '-Wconversion', '-Wshadow',
             '-DVN135_BM1368_RESET_135']
    results = []
    with tempfile.TemporaryDirectory(prefix='bm1368-reset-controls-') as tmp:
        temp = Path(tmp)
        fixture = temp / 'fixture.o'
        checked([args.cc, *flags, '-c', str(folder/'tests/test_original_reset.c'), '-o', str(fixture)])
        for number, (name, changed) in enumerate(variants):
            source, obj, exe = temp/f'mutant-{number}.c', temp/f'mutant-{number}.o', temp/f'mutant-{number}'
            source.write_text(prefix + gate + changed)
            checked([args.cc, *flags, '-c', str(source), '-o', str(obj)])
            checked([args.cc, str(obj), str(fixture), '-o', str(exe)])
            result = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
            if result.returncode != 1 or 'ORIGINAL_RESET_FAIL ' not in result.stderr:
                raise ValueError('semantic mutant was not caught by its fixture: ' + name +
                                 '\n' + result.stdout + result.stderr)
            results.append({'name': name, 'returncode': result.returncode,
                            'failure': result.stderr.strip().splitlines()[0]})
    receipt = {'kind': 'authored-host-semantic-controls', 'controls': len(results),
               'source_sha256': hashlib.sha256(raw.encode()).hexdigest(),
               'fixture_sha256': hashlib.sha256((folder/'tests/test_original_reset.c').read_bytes()).hexdigest(),
               'compiler': args.cc, 'compile_flags': flags, 'results': results,
               'firmware_executed': False, 'instruction_interpreter_used': False, 'hardware': False}
    target = folder/'build/negative-controls.json'
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(receipt, indent=2) + '\n')
    print('ORIGINAL_RESET_CONTROLS_PASS controls=' + str(len(results)))


if __name__ == '__main__':
    main()

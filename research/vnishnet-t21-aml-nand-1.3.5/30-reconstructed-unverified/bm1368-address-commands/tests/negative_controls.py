#!/usr/bin/env python3
"""Compile mutations of only the two authored address-command wrappers.

Earlier accepted source and any later append remain byte-identical. Only a
normal exit 1 with the fixture's assertion marker detects a mutation. Build
errors, crashes and timeouts are failures of this runner, never passing controls.
No original instructions are executed.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

from run_host import SOURCES

START, END = 9245, 11280
PREFIX_SHA256 = 'e4c05fb8bc541e6e6b2a216cbaecf7ef57cc3d85101d59b81e8ebd3d4e2af7e4'
WITNESS_SHA256 = '91cfb6f3bb640bcf3519027243970bcb37aeeb0275f96b931dd17cab940540d2'
GATE = b'\n#ifdef VN135_BM1368_ADDRESS_COMMANDS_135\n'
HEADERS = (b'#include "integration/bm1368_address_commands_135.h"\n'
           b'#include "integration/bm1368_control.h"\n')
FUNCTIONS = ('vn135_bm1368_inactivate_135', 'vn135_bm1368_assign_address_135')


def require(ok, message):
    if not ok:
        raise ValueError(message)


def partition_source(raw):
    require(type(raw) is bytes and len(raw) >= END, 'address witness is truncated or not bytes')
    require(hashlib.sha256(raw[:START]).hexdigest() == PREFIX_SHA256,
            'accepted sweep prefix differs')
    require(hashlib.sha256(raw[:END]).hexdigest() == WITNESS_SHA256,
            'accepted address witness differs')
    section = raw[START:END]
    require(section.startswith(GATE + HEADERS) and section.endswith(b'\n#endif\n') and
            section.count(b'#if') == 1 and section.count(b'#endif') == 1,
            'address span is not separately gated')
    return raw[:START], section[len(GATE):].decode('utf-8'), raw[END:]


def change_function(body, function, old, new):
    start = body.index('int32_t ' + function + '(')
    end = body.find('\nint32_t ', start + 1)
    if end < 0:
        end = body.index('\n#endif', start)
    part = body[start:end]
    require(part.count(old) == 1, 'semantic anchor changed: ' + function + ': ' + old)
    return body[:start] + part.replace(old, new, 1) + body[end:]


def controls(body):
    for role, function, line, message in (
        ('inactive', FUNCTIONS[0], 669, 'chain#%d - failed to inactivate the chain'),
        ('address', FUNCTIONS[1], 699, 'chain#%d - failed to assign chip address to 0x%02x'),
    ):
        variants = [
            ('exact-zero-status', 'frame + 2, 5) == 0)', 'frame + 2, 5) <= 0)'),
            ('success-return-zero', '        return 0;', '        return -1;'),
            ('failure-return-minus-one',
             '    log->emit(log->context, &diagnostic);\n    return -1;',
             '    log->emit(log->context, &diagnostic);\n    return -2;'),
            ('body-excludes-prefix', 'device->identity, frame + 2, 5)', 'device->identity, frame, 5)'),
            ('body-length-five', 'device->identity, frame + 2, 5)', 'device->identity, frame + 2, 4)'),
            ('device-identity', 'device->identity, frame + 2, 5)', 'NULL, frame + 2, 5)'),
            ('one-based-index', '*device->index + UINT32_C(1)', '*device->index + UINT32_C(0)'),
            ('source-line', f'\", {line}, 1,', f'\", {line + 1}, 1,'),
            ('severity', f'\", {line}, 1,', f'\", {line}, 2,'),
            ('format', '"' + message + '"', '"' + message + '_BAD"'),
            ('diagnostic-emitted', '    log->emit(log->context, &diagnostic);',
             '    (void)log; (void)diagnostic;'),
            ('one-dispatch', '    if (vn135_transport_send_135(',
             '    (void)vn135_transport_send_135(transport, device->identity, frame + 2, 5);\n'
             '    if (vn135_transport_send_135('),
        ]
        for name, old, new in variants:
            yield role + '-' + name, change_function(body, function, old, new)
        stale = change_function(body, function, '*device->index + UINT32_C(1)',
                                'saved_index + UINT32_C(1)')
        yield role + '-late-index', change_function(stale, function, '    uint8_t frame[7];',
            '    const uint32_t saved_index = device->index ? *device->index : 0;\n'
            '    uint8_t frame[7];')
    yield 'inactive-opcode', change_function(body, FUNCTIONS[0],
        'DIZZASS_BM1368_INACTIVE, 0, 0, 0, 0,', 'DIZZASS_BM1368_SET_ADDRESS, 0, 0, 0, 0,')
    yield 'address-opcode', change_function(body, FUNCTIONS[1],
        'DIZZASS_BM1368_SET_ADDRESS, 0,', 'DIZZASS_BM1368_READ_REGISTER, 0,')
    yield 'address-byte-truncation', change_function(body, FUNCTIONS[1],
        'chip->wire_address & 255u, 0, 0, frame', 'chip->wire_address, 0, 0, frame')
    yield 'address-uses-chip-word', change_function(body, FUNCTIONS[1],
        'chip->wire_address & 255u, 0, 0, frame', '0, 0, 0, frame')
    yield 'address-full-diagnostic-word', change_function(body, FUNCTIONS[1],
        'UINT32_C(1), 1, chip->wire_address', 'UINT32_C(1), 1, chip->wire_address & 255u')
    stale = change_function(body, FUNCTIONS[1],
        'UINT32_C(1), 1, chip->wire_address', 'UINT32_C(1), 1, saved_address')
    yield 'address-late-diagnostic-word', change_function(stale, FUNCTIONS[1],
        '    uint8_t frame[7];',
        '    const uint32_t saved_address = chip->wire_address;\n    uint8_t frame[7];')
    yield 'inactive-has-no-address-argument', change_function(body, FUNCTIONS[0],
        'UINT32_C(1), 0, 0', 'UINT32_C(1), 1, 0')
    yield 'address-has-address-argument', change_function(body, FUNCTIONS[1],
        'UINT32_C(1), 1, chip->wire_address', 'UINT32_C(1), 0, chip->wire_address')


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
    raw = (root/'libbitmain/src/chip/chip1368.c').read_bytes()
    prefix, body, suffix = partition_source(raw)
    variants = list(controls(body))
    flags = ['-I'+str(root), '-I'+str(root/'include'), '-std=c11', '-O2', '-g',
             '-Wall', '-Wextra', '-Wpedantic', '-Werror', '-Wconversion', '-Wshadow',
             '-DVN135_BM1368_ADDRESS_COMMANDS_135', '-DVN135_COMMON_READ_REGISTER_135',
             '-DVN135_TRANSPORT_DISPATCH_135']
    results, inputs, records = [], [], []
    with tempfile.TemporaryDirectory(prefix='address-command-controls-') as temporary:
        build = Path(temporary)
        objects = []
        unchanged = [root/name for name in SOURCES if name != 'libbitmain/src/chip/chip1368.c']
        unchanged.append(folder/'tests/test_address_commands.c')
        for index, source in enumerate(unchanged):
            obj = build/f'unchanged-{index}.o'
            cmd = [args.cc, *flags, '-c', str(source), '-o', str(obj)]
            checked(cmd)
            objects.append(str(obj))
            item = {'path':str(source), 'sha256':hashlib.sha256(source.read_bytes()).hexdigest()}
            inputs.append(item)
            records.append({**item,'command':cmd,'object_sha256':hashlib.sha256(obj.read_bytes()).hexdigest()})
        for number, (name, changed) in enumerate(variants):
            mutant = prefix + GATE + changed.encode() + suffix
            require(mutant[:START] == prefix, 'control altered earlier source')
            require(mutant[START+len(GATE)+len(changed.encode()):] == suffix,
                    'control altered later source')
            source, obj, exe = build/f'mutant-{number}.c', build/f'mutant-{number}.o', build/f'mutant-{number}'
            source.write_bytes(mutant)
            compile_cmd = [args.cc, *flags, '-c', str(source), '-o', str(obj)]
            checked(compile_cmd)
            link_cmd = [args.cc, str(obj), *objects, '-o', str(exe)]
            checked(link_cmd)
            result = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
            require(result.returncode == 1 and 'ADDRESS_COMMANDS_FAIL ' in result.stderr,
                    'semantic mutation was not caught: '+name+'\n'+result.stdout+result.stderr)
            results.append({'name':name,'returncode':result.returncode,
                'failure':result.stderr.strip().splitlines()[0],
                'source_sha256':hashlib.sha256(mutant).hexdigest(),
                'compile_command':compile_cmd,'object_sha256':hashlib.sha256(obj.read_bytes()).hexdigest(),
                'link_command':link_cmd,'stdout':result.stdout,'stderr':result.stderr})
    report = {'kind':'authored-host-semantic-controls','controls':len(results),
              'source_sha256':hashlib.sha256(raw).hexdigest(),'preserved_prefix_bytes':START,
              'address_span_bytes':END-START,'untouched_suffix_bytes':len(suffix),
              'compiler':args.cc,'compile_flags':flags,'unchanged_inputs':inputs,
              'compile_records':records,'results':results,'firmware_executed':False,'hardware':False}
    target = folder/'build/negative-controls.json'
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(report,indent=2)+'\n')
    print('ADDRESS_COMMANDS_CONTROLS_PASS controls='+str(len(results)))


if __name__ == '__main__':
    main()

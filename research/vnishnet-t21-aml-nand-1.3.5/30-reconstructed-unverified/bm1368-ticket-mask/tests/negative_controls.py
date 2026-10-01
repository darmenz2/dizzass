#!/usr/bin/env python3
"""Compile safe mutations of the authored ticket setter and run its host fixture.

Only the exact ticket-method span is changed. Earlier source and any later
append stay byte-identical. A build error, signal, timeout or unrelated failure
never counts as a detected semantic mutation. No original instructions run.
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

START, END = 7519, 8350
PREFIX_SHA256 = 'e3c8cecb8869c59847db357d26541e95123fa1cb4cf2ef04642a62c2e1e0738d'
WITNESS_SHA256 = 'ed818babcb847fb38094af8f08ae3c0ac6ef690192aa1e6030c3f8326e9968d9'
GATE = b'\n#ifdef VN135_BM1368_TICKET_MASK_135\n'
HEADER = b'#include "integration/bm1368_ticket_mask_135.h"\n'


def require(ok, message):
    if not ok:
        raise ValueError(message)


def partition_source(raw):
    require(type(raw) is bytes and len(raw) >= END, 'ticket witness is truncated or not bytes')
    require(hashlib.sha256(raw[:START]).hexdigest() == PREFIX_SHA256,
            'preserved reset prefix differs')
    require(hashlib.sha256(raw[:END]).hexdigest() == WITNESS_SHA256,
            'accepted ticket witness differs')
    section = raw[START:END]
    require(section.startswith(GATE + HEADER) and section.endswith(b'\n#endif\n')
            and section.count(b'#if') == 1 and section.count(b'#endif') == 1,
            'ticket span is not separately gated')
    return raw[:START], section[len(GATE):].decode('utf-8'), raw[END:]


def replace_one(body, old, new):
    require(body.count(old) == 1, 'semantic anchor changed: ' + old)
    return body.replace(old, new, 1)


def controls(body):
    rows = [
        ('reverse-low-byte', 'vn135_bm1398_ticket_mask_word(mask)', '(mask & 255u)'),
        ('correct-input-word', 'vn135_bm1398_ticket_mask_word(mask)', 'vn135_bm1398_ticket_mask_word(mask >> 1)'),
        ('broadcast-mode-one', 'device, 1, NULL, 0x14, value', 'device, 2, NULL, 0x14, value'),
        ('ticket-register', 'device, 1, NULL, 0x14, value', 'device, 1, NULL, 0x15, value'),
        ('nonzero-writer-status-fails', 'writer, write_context) == 0)', 'writer, write_context) <= 0)'),
        ('zero-status-succeeds', '        return 0;', '        return -1;'),
        ('failure-status-minus-one', '    return -1;', '    return 0;'),
        ('one-based-index-bits', 'device->index + UINT32_C(1)', 'device->index + UINT32_C(0)'),
        ('source-line-507', '", 507, 1,', '", 506, 1,'),
        ('severity-one', '", 507, 1,', '", 507, 2,'),
        ('ticket-format', '"chain#%d - failed to set TICKET_MASK"',
                          '"chain#%d - failed to set TICKET_MASK_BAD"'),
        ('diagnostic-is-emitted', '    log->emit(log->context, &diagnostic);',
                                 '    (void)log; (void)diagnostic;'),
    ]
    for name, old, new in rows:
        yield name, replace_one(body, old, new)
    anchor = '    const uint32_t value = vn135_bm1398_ticket_mask_word(mask);'
    yield 'high-bits-are-accepted', replace_one(body, anchor,
        '    if (mask > 255u) return -1;\n' + anchor)
    stale = replace_one(body, 'device->index + UINT32_C(1)', 'saved_index + UINT32_C(1)')
    yield 'post-writer-index', replace_one(stale, anchor,
        '    const uint32_t saved_index = device->index;\n' + anchor)
    yield 'one-writer-call', replace_one(body, anchor, anchor +
        '\n    (void)vn135_bm1368_write_register_135(device, 1, NULL, 0x14, value, writer, write_context);')


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
             '-DVN135_BM1368_TICKET_MASK_135', '-DVN135_BM1368_REGISTER_WRITE_135',
             '-DVN135_TRANSPORT_DISPATCH_135']
    results, inputs = [], []
    with tempfile.TemporaryDirectory(prefix='ticket-mask-controls-') as temporary:
        build = Path(temporary)
        objects = []
        unchanged = [root/name for name in SOURCES if name != 'libbitmain/src/chip/chip1368.c']
        unchanged.append(folder/'tests/test_ticket_mask.c')
        for index, source in enumerate(unchanged):
            obj = build/f'unchanged-{index}.o'
            checked([args.cc, *flags, '-c', str(source), '-o', str(obj)])
            objects.append(str(obj))
            inputs.append({'path':str(source), 'sha256':hashlib.sha256(source.read_bytes()).hexdigest()})
        for number, (name, changed) in enumerate(variants):
            mutant = prefix + GATE + changed.encode() + suffix
            require(mutant[:START] == prefix, 'control altered the earlier source')
            require(mutant[START+len(GATE)+len(changed.encode()):] == suffix,
                    'control altered a later append')
            source, obj, exe = build/f'mutant-{number}.c', build/f'mutant-{number}.o', build/f'mutant-{number}'
            source.write_bytes(mutant)
            checked([args.cc, *flags, '-c', str(source), '-o', str(obj)])
            checked([args.cc, '-Wl,--wrap=vn135_bm1368_write_register_135',
                     str(obj), *objects, '-o', str(exe)])
            result = subprocess.run([str(exe)], capture_output=True, text=True, timeout=30)
            require(result.returncode == 1 and 'ORIGINAL_TICKET_MASK_FAIL ' in result.stderr,
                    'semantic mutation was not caught: '+name+'\n'+result.stdout+result.stderr)
            results.append({'name':name, 'returncode':result.returncode,
                            'failure':result.stderr.strip().splitlines()[0]})
    report = {'kind':'authored-host-semantic-controls', 'controls':len(results),
              'source_sha256':hashlib.sha256(raw).hexdigest(), 'preserved_prefix_bytes':START,
              'ticket_span_bytes':END-START, 'untouched_suffix_bytes':len(suffix),
              'compiler':args.cc, 'compile_flags':flags, 'unchanged_inputs':inputs,
              'results':results, 'firmware_executed':False, 'hardware':False}
    target = folder/'build/negative-controls.json'
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(report, indent=2)+'\n')
    print('TICKET_MASK_CONTROLS_PASS controls='+str(len(results)))


if __name__ == '__main__':
    main()

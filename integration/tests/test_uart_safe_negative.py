#!/usr/bin/env python3
"""Require compiled semantic failures, not build errors, crashes or timeouts."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'integration/native/uart_safe.c'
MUTANTS = {
    'resend_prefix': ('data + written, remaining);', 'data, length);'),
    'short_write_is_success': ('if (written == length)', 'if (written > 0)'),
    'zero_is_success': ('if (attempt.count == -1) {',
        'if (attempt.count == 0) return result(DIZZASS_UART_OK, written, 0);\n        if (attempt.count == -1) {'),
    'stale_errno_controls_positive': ('if (attempt.count > 0) {',
        'if (attempt.count > 0 && !attempt.error) {'),
    'lose_failure_progress': ('callback_error(DIZZASS_UART_WRITE_ERROR, written, error)',
        'callback_error(DIZZASS_UART_WRITE_ERROR, 0, error)'),
    'extend_wait_deadline': ('io->wait(io->context, deadline_ms)',
        'io->wait(io->context, deadline_ms + 1)'),
    'spin_on_zero': ('if (error == EINTR)\n            continue;',
        'if (error == EINTR || attempt.count == 0)\n            continue;'),
    'ready_resets_budget': ('if (!error)\n                break;',
        'if (!error) { idle = 0; break; }'),
}
FIXTURE = ['libbitmain/src/chip/chip1398.c', 'libbitmain/src/aml/chip.c',
           'libbitmain/src/reg_cache.c', 'reconstruction/support/crc5.c']


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cc', default='cc')
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    source = SOURCE.read_text()
    records = []
    for name, mutation in [('baseline', None), *MUTANTS.items()]:
        candidate = source
        if mutation:
            old, new = mutation
            assert source.count(old) == 1, name
            candidate = source.replace(old, new)
        path, binary = out / (name + '.c'), out / name
        path.write_text(candidate)
        command = [args.cc, '-I.', '-Iinclude', '-std=c11', '-O1', '-g', '-Wall',
                   '-Wextra', '-Wpedantic', '-Werror', str(path), *FIXTURE,
                   'integration/tests/test_uart_safe.c', '-o', str(binary)]
        build = subprocess.run(command, cwd=ROOT, capture_output=True, text=True, timeout=45)
        (out / (name + '.build.log')).write_text(build.stdout + build.stderr)
        if build.returncode:
            raise RuntimeError((name, 'must compile', build.stderr))
        run = subprocess.run([str(binary)], cwd=ROOT, capture_output=True, text=True, timeout=30)
        (out / (name + '.log')).write_text(run.stdout + run.stderr)
        if mutation:
            if run.returncode != 1 or 'UART_SAFE_ASSERT' not in run.stderr:
                raise RuntimeError((name, 'not a semantic rejection', run.returncode, run.stderr))
        elif run.returncode or 'UART_SAFE_PASS' not in run.stdout:
            raise RuntimeError(('baseline did not pass', run.returncode, run.stderr))
        records.append({'name': name, 'build_exit': build.returncode, 'test_exit': run.returncode})
    report = {'status': 'PASS', 'compiler': args.cc, 'rejected': len(MUTANTS),
              'source_sha256': hashlib.sha256(SOURCE.read_bytes()).hexdigest(), 'records': records}
    (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    print('UART_SAFE_NEGATIVE_PASS', json.dumps(report))


if __name__ == '__main__':
    main()

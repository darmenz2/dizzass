#!/usr/bin/env python3
"""A-13 semantic controls and dependency isolation; no hardware/network I/O."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'integration/native/uart_posix.c'
MUTANTS = {
    'blocking_admitted': ('!(flags & O_NONBLOCK)', '0'),
    'readonly_admitted': ('(flags & O_ACCMODE) == O_RDONLY', '0'),
    'postprocessing_admitted': ('if (attributes.c_oflag & OPOST)', 'if (0)'),
    'wall_clock': ('clock_gettime(CLOCK_MONOTONIC, &t)', 'clock_gettime(CLOCK_REALTIME, &t)'),
    'wrong_millisecond_scale': ('*out = (uint64_t)t.tv_sec * 1000u + fraction;', '*out = (uint64_t)t.tv_sec * 100u + fraction;'),
    'lost_write_errno': ('int error = count < 0 ? os_error(errno) : 0;', 'int error = count < 0 ? EIO : 0;'),
    'wrong_remaining_timeout': ('int ready = poll(&p, 1, timeout);', 'int ready = poll(&p, 1, timeout + 1);'),
    'slice_is_expiry': ('if (!ready) continue;', 'if (!ready) return ETIMEDOUT;'),
    'hangup_ready': ('(POLLHUP | POLLERR)', 'POLLERR'),
    'nval_is_generic': ('if (p.revents & POLLNVAL) return EBADF;', 'if (p.revents & POLLNVAL) return EIO;'),
    'interrupted_is_timeout': ('if (ready < 0) return os_error(errno);', 'if (ready < 0) return ETIMEDOUT;'),
    'lost_accepted_count': ('return dizzass_uart_write_all(&io, data, length, deadline_ms, max_no_progress);', 'struct dizzass_uart_result r = dizzass_uart_write_all(&io, data, length, deadline_ms, max_no_progress); r.written = 0; return r;'),
}


def staging_checks(deps):
    spec = importlib.util.spec_from_file_location('prepare', ROOT / 'tools/prepare_uart_posix.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    count = 0
    def rejected(call):
        nonlocal count
        try:
            call()
        except (ValueError, OSError):
            count += 1
        else:
            raise RuntimeError('invalid staging accepted')
    with tempfile.TemporaryDirectory(dir=ROOT / 'build', prefix='a13-integrity-') as temp:
        directory = Path(temp)
        valid = directory / 'valid'
        module.prepare(valid, deps); count += 1
        module.prepare(valid, check=True); count += 1
        first = valid / 'integration/native/uart_safe.c'
        original = first.read_bytes(); first.write_bytes(original + b'\n')
        rejected(lambda: module.prepare(valid, check=True))
        rejected(lambda: module.prepare(valid, deps))
        if first.read_bytes() != original + b'\n':
            raise RuntimeError('altered output overwritten')
        first.write_bytes(original)
        (valid / 'errno.h').write_text('unexpected include')
        rejected(lambda: module.prepare(valid, check=True))
        (valid / 'errno.h').unlink()
        first.unlink(); first.symlink_to(deps / 'integration/native/uart_safe.c')
        rejected(lambda: module.prepare(valid, check=True))
        rejected(lambda: module.prepare(ROOT / 'integration'))
        rejected(lambda: module.prepare(ROOT / 'build'))
        broken = directory / 'input'; shutil.copytree(deps, broken)
        (broken / 'integration/native/uart_safe.h').write_text('bad input')
        rejected(lambda: module.prepare(directory / 'out', broken))
    print('UART_POSIX_STAGING_PASS checks=' + str(count))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--cc', default='cc')
    parser.add_argument('--deps', type=Path, default=ROOT / 'build/a13-deps')
    parser.add_argument('--out', type=Path, default=ROOT / 'build/uart-posix/negative')
    parser.add_argument('--staging-checks', action='store_true')
    args = parser.parse_args()
    deps = args.deps.resolve()
    if args.staging_checks:
        staging_checks(deps); return
    out = args.out.resolve(); out.relative_to(ROOT / 'build')
    out.mkdir(parents=True, exist_ok=True)
    source = SOURCE.read_text(); records = []
    for name, edit in [('baseline', None), *MUTANTS.items()]:
        candidate = source
        if edit:
            if source.count(edit[0]) != 1:
                raise RuntimeError('ambiguous mutation: ' + name)
            candidate = source.replace(*edit)
        path = out / (name + '.c'); path.write_text(candidate)
        binary = out / name
        command = [args.cc, '-I.', '-I' + str(deps), '-std=c11', '-O1', '-g',
            '-Wall', '-Wextra', '-Wpedantic', '-Werror', str(path),
            str(deps / 'integration/native/uart_safe.c'),
            'integration/tests/test_uart_posix.c',
            '-Wl,--wrap=fcntl,--wrap=tcgetattr,--wrap=clock_gettime,--wrap=write,--wrap=poll,--wrap=__poll_chk', '-o', str(binary)]
        build = subprocess.run(command, cwd=ROOT, text=True, capture_output=True, timeout=30)
        (out / (name + '.build.log')).write_text(build.stdout + build.stderr)
        if build.returncode:
            raise RuntimeError((name, 'does not compile', build.stderr))
        run = subprocess.run([str(binary)], cwd=ROOT, text=True, capture_output=True, timeout=10)
        (out / (name + '.test.log')).write_text(run.stdout + run.stderr)
        if edit:
            if run.returncode != 1 or 'UART_POSIX_ASSERT' not in run.stderr:
                raise RuntimeError((name, 'not semantic rejection', run.returncode))
        elif run.returncode or 'UART_POSIX_UNIT_PASS' not in run.stdout:
            raise RuntimeError('baseline failed')
        records.append(dict(name=name, build_exit=build.returncode, test_exit=run.returncode))
    report = dict(status='PASS', compiler=args.cc, rejected=len(MUTANTS),
        source_sha256=hashlib.sha256(SOURCE.read_bytes()).hexdigest(), records=records)
    (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    print('UART_POSIX_NEGATIVE_PASS', json.dumps(report))


if __name__ == '__main__':
    main()

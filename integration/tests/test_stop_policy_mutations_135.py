#!/usr/bin/env python3
"""Negative controls: the oracle must reject three deliberate control-flow bugs."""
import argparse
import os
import shlex
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--cc', default=os.environ.get('CC', 'cc'))
    args = parser.parse_args()
    source = (ROOT / 'src/backend/base.c').read_text()
    mutations = (
        ('exit-return', 'return VN135_STOP_PROCESS_EXIT;', 'return VN135_STOP_RETURNED;'),
        ('negative-limit', 'if (limit != 0 && s->retune_104', 'if (limit > 0 && s->retune_104'),
        ('description-reclear', 'uint32_t next = (uint32_t)attempts + 1u;',
         'uint32_t next = (uint32_t)attempts + 1u; memset(description, 0, sizeof(description));'),
    )
    with tempfile.TemporaryDirectory(prefix='stop-policy-negative-') as temp:
        directory = Path(temp)
        for name, before, after in mutations:
            assert source.count(before) == 1, name
            path, library = directory / (name + '.c'), directory / (name + '.so')
            path.write_text(source.replace(before, after, 1))
            command = shlex.split(args.cc) + [
                '-I.', '-std=c11', '-O1', '-Wall', '-Wextra', '-Werror',
                '-fno-fast-math', '-ffp-contract=off', '-DVN135_STOP_POLICY_135',
                '-DVN135_GENERAL_MONITOR_135', '-DVN135_MONITOR_HANDLERS_135',
                '-shared', '-fPIC', str(path), 'integration/tests/stop_policy_bridge_135.c',
                '-Wl,-z,defs', '-o', str(library)]
            subprocess.run(command, cwd=ROOT, check=True, timeout=45)
            run = subprocess.run([sys.executable, 'integration/tests/test_stop_policy_135.py', str(library)],
                                 cwd=ROOT, text=True, capture_output=True, timeout=90)
            # A crash, missing library, malformed fixture or any unrelated error
            # is not an acceptable negative-control result.
            assert run.returncode == 1 and 'AssertionError: stop policy mismatch' in run.stderr, (name, run.stdout, run.stderr)
            failure = next(line for line in run.stdout.splitlines() if line.startswith('FAIL '))
            print('STOP_POLICY135_MUTANT_REJECTED', name, failure[:180])
    print('STOP_POLICY135_MUTATION_PASS rejected=3')

if __name__ == '__main__':
    main()

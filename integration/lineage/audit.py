"""Read pinned Git objects as data; do not build or run candidate firmware."""
from __future__ import annotations
import argparse
import hashlib
import json
import re
import subprocess
from pathlib import Path

TOKEN = re.compile(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|[A-Za-z_][A-Za-z_0-9]*|(?:[0-9]|\.[0-9])(?:[A-Za-z0-9_.]|[eEpP][+-])*|>>=|<<=|\.\.\.|##|->|\+\+|--|<<|>>|<=|>=|==|!=|&&|\|\||\*=|/=|%=|\+=|-=|&=|\^=|\|=|[^\s]', re.S)
FUNCTIONS = {
    'cgminer.c': ['_copy_work', 'copy_work_noffset', 'stale_work', 'regen_hash',
                  'test_nonce', 'submit_nonce', 'submit_tested_work', 'set_target',
                  'gen_stratum_work', 'get_work', 'restart_wait'],
    'util.c': ['fulltest'],
}

def c_tokens(source: str) -> list[str]:
    source = re.sub(r'\\\r?\n', '', source)  # Translation phase 2, before comments.
    return [m.group() for m in TOKEN.finditer(source)
            if not m.group().startswith(('/*', '//'))]

def function_tokens(source: str, name: str) -> list[str] | None:
    """Lexical definition fingerprint, not a C preprocessor or semantic proof."""
    ts = c_tokens(source)
    found = []
    for i, token in enumerate(ts):
        if token != name or ts[i + 1:i + 2] != ['(']:
            continue
        j, depth = i + 2, 1
        while j < len(ts) and depth:
            depth += (ts[j] == '(') - (ts[j] == ')')
            j += 1
        if depth or ts[j:j + 1] != ['{']:
            continue
        k, depth = j + 1, 1
        while k < len(ts) and depth:
            depth += (ts[k] == '{') - (ts[k] == '}')
            k += 1
        if depth:
            raise ValueError(f'Unbalanced definition: {name}')
        found.append(ts[i:k])
    if len(found) > 1:
        raise ValueError(f'Ambiguous definitions: {name}')
    return found[0] if found else None

def checked_sha(value: str) -> str:
    if not isinstance(value, str) or not re.fullmatch('[0-9a-f]{40}', value):
        raise ValueError('Expected full lowercase 40-digit Git SHA')
    return value

def git(repo: Path, *args: str) -> str:
    return subprocess.run(['git', '-C', str(repo), *args], check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                          text=True, timeout=90).stdout.rstrip('\n')

def audit(repo: Path, meta: dict) -> dict:
    candidate = checked_sha(meta['candidate']['commit'])
    baseline = checked_sha(meta['baseline']['commit'])
    prefix = meta['firmware_marker']
    if not re.fullmatch('[0-9a-f]{7,40}', prefix) or not candidate.startswith(prefix):
        raise ValueError('Firmware marker and candidate prefix disagree')
    for rev in (candidate, baseline):
        if git(repo, 'cat-file', '-t', rev) != 'commit':
            raise ValueError('Pinned object is not a commit')
    tree = git(repo, 'rev-parse', candidate + '^{tree}')
    if tree != checked_sha(meta['candidate']['tree']):
        raise ValueError('Candidate tree mismatch')
    parents = git(repo, 'show', '-s', '--format=%P', candidate).split()
    if parents != meta['candidate']['parents']:
        raise ValueError('Candidate parents mismatch')
    for path, expected in meta['candidate']['blobs'].items():
        if not re.fullmatch('[A-Za-z0-9_.-]+', path):
            raise ValueError('Only top-level source pins are supported')
        if git(repo, 'rev-parse', candidate + ':' + path) != checked_sha(expected):
            raise ValueError('Candidate blob mismatch: ' + path)
    rows = []
    for path, names in FUNCTIONS.items():
        a = git(repo, 'show', candidate + ':' + path)
        b = git(repo, 'show', baseline + ':' + path)
        for name in names:
            fa, fb = function_tokens(a, name), function_tokens(b, name)
            def digest(tokens):
                return None if tokens is None else hashlib.sha256(
                    json.dumps(tokens, separators=(',', ':')).encode()).hexdigest()
            rows.append({'file': path, 'function': name,
                         'candidate_sha256': digest(fa), 'baseline_sha256': digest(fb),
                         'status': 'missing' if fa is None or fb is None else
                                   ('same_tokens' if fa == fb else 'different_tokens')})
    paths = git(repo, 'ls-tree', '-r', '--name-only', candidate).splitlines()
    counts = git(repo, 'rev-list', '--left-right', '--count', candidate + '...' + baseline).split()
    return {'schema': 1, 'candidate': candidate, 'baseline': baseline, 'tree': tree,
            'parents': parents, 'candidate_only_commits': int(counts[0]),
            'baseline_only_commits': int(counts[1]),
            'merge_base': git(repo, 'merge-base', candidate, baseline),
            'candidate_history_count': int(git(repo, 'rev-list', '--count', candidate)),
            'candidate_source_paths': len(paths),
            'candidate_libbitmain_paths': [p for p in paths if 'libbitmain' in p.lower()],
            'functions': rows, 'vendor_ancestry_proven': False,
            'note': 'Matching short revision and public objects do not prove vendor binary ancestry. '
                    'Token equality excludes return types, headers, compiler flags and callees.'}

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--metadata', type=Path, default=Path(__file__).with_name('candidate.json'))
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = audit(args.repo, json.loads(args.metadata.read_text()))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))

if __name__ == '__main__':
    main()

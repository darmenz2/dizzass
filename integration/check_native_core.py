#!/usr/bin/env python3
"""Check the evaluated *baseline* cgminer source list; no builds or hardware I/O.
Deliberately strict until an explicitly reviewed native T21 adapter is added.
This checks linkage inputs, not mining behavior or complete absence of defects.
"""
from __future__ import annotations
import argparse
from pathlib import Path, PurePosixPath
import re
import sys

REQUIRED = frozenset({"cgminer.c", "util.c", "sha2.c", "api.c", "logging.c", "klist.c", "noncedup.c"})
FORBIDDEN_PREFIXES = ("src/", "libbitmain/", "reconstruction/", "tests/", "reference/")


def validate(sources: str, symbols: str | None = None) -> list[str]:
    errors: list[str] = []
    names: list[str] = []
    for token in sources.split():
        path = PurePosixPath(token)
        if path.is_absolute() or ".." in path.parts or "$" in token:
            errors.append(f"unexpanded or unsafe source path: {token}")
            continue
        names.append(path.as_posix())
    present = set(names)
    for name in sorted(REQUIRED - present):
        errors.append(f"missing native core source: {name}")
    for name in sorted(present):
        if name.startswith(FORBIDDEN_PREFIXES):
            errors.append(f"non-baseline module in production sources: {name}")
    if len(names) != len(present):
        errors.append("duplicate source entries")
    if symbols is not None and re.search(r"\bvn135_[A-Za-z0-9_]+", symbols):
        errors.append("recovery symbols present in the production binary")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, required=True,
                        help="output of native-check.mk dizzass-core-sources")
    parser.add_argument("--symbols", type=Path, help="optional nm --defined-only output")
    args = parser.parse_args()
    try:
        sources = args.sources.read_text(encoding="utf-8")
        symbols = args.symbols.read_text(encoding="utf-8") if args.symbols else None
    except (OSError, UnicodeError) as exc:
        print(f"Cannot read build evidence: {exc}", file=sys.stderr)
        return 2
    errors = validate(sources, symbols)
    if errors:
        print("Native core boundary FAILED:\n" + "\n".join(errors), file=sys.stderr)
        return 1
    print("Native baseline source boundary PASS; hardware/runtime behavior not tested here.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

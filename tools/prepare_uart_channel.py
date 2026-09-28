#!/usr/bin/env python3
"""Read exact pending A-13/B-01 bytes; stage for offline tests, never merge or fetch."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "integration/evidence/uart_channel_dependencies.json"

def checked(data: bytes, entry: dict) -> bytes:
    blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
    if blob != entry["blob"] or hashlib.sha256(data).hexdigest() != entry["sha256"]:
        raise ValueError("dependency byte mismatch: " + entry["path"])
    return data

def safe_path(root: Path, relative: str) -> Path:
    part = Path(relative)
    if part.is_absolute() or ".." in part.parts:
        raise ValueError("unsafe dependency path")
    at = root
    for name in part.parts:
        at /= name
        if at.is_symlink():
            raise ValueError("symlink not allowed: " + str(at))
    return at

def prepare(out: Path, source: Path | None, check: bool) -> None:
    # Only isolated output beneath THIS checkout's build directory is allowed.
    if not out.is_absolute():
        out = ROOT / out
    relative = out.relative_to(ROOT)
    if len(relative.parts) < 2 or relative.parts[0] != "build":
        raise ValueError("output must be a child of checkout/build")
    out = safe_path(ROOT, relative.as_posix())
    entries = json.loads(MANIFEST.read_text())["pending_dependencies"]
    expected = {e["path"] for e in entries} | {".gitignore"}
    allowed_dirs = {str(p) for path in expected for p in Path(path).parents if str(p) != "."}
    if out.exists():
        for p in out.rglob("*"):
            rel = p.relative_to(out).as_posix()
            if p.is_symlink() or (p.is_dir() and rel not in allowed_dirs) or (not p.is_dir() and rel not in expected):
                raise ValueError("unexpected staged entry: " + rel)
    elif check:
        raise ValueError("dependencies not prepared")
    payload = {".gitignore": b"*\n"}
    for e in entries:
        dest = safe_path(out, e["path"])
        if check:
            data = dest.read_bytes()
        elif source is not None:
            if source.is_symlink(): raise ValueError("symlink source root")
            data = safe_path(source, e["path"]).read_bytes()
        else:
            data = subprocess.check_output(["git", "show", e["commit"] + ":" + e["path"]], cwd=ROOT, timeout=20)
        payload[e["path"]] = checked(data, e)
    # Validate ALL existing targets before writing anything. Never repair drift.
    for path, data in payload.items():
        target = safe_path(out, path)
        if target.exists() and target.read_bytes() != data:
            raise ValueError("refusing overwrite: " + path)
        if check and not target.is_file():
            raise ValueError("missing staged entry: " + path)
    if not check:
        for path, data in payload.items():
            target = safe_path(out, path)
            target.parent.mkdir(parents=True, exist_ok=True)
            if not target.exists():
                with target.open("xb") as f:
                    f.write(data)

def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--out", type=Path, default=Path("build/a14-deps"))
    p.add_argument("--source-tree", type=Path)
    p.add_argument("--check", action="store_true")
    a = p.parse_args()
    try:
        prepare(a.out, a.source_tree, a.check)
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as e:
        print("UART_CHANNEL_DEPENDENCIES_FAIL:", e, file=sys.stderr)
        return 1
    print("UART_CHANNEL_DEPENDENCIES_PASS: four exact pending blobs, no merge or network")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())

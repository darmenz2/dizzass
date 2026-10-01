#!/usr/bin/env python3
"""R-01: rebuild one pinned, offline native-work/UART/RX test stack.

No fetch, git writes, package installation, miner startup or hardware access.
All compilation and deliberate mutants live in an exclusive output directory.
"""
from __future__ import annotations
import argparse
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
REL = Path("integration/review/native_uart_stack")


def git_bytes(*args: str) -> bytes:
    return subprocess.run(["git", *args], cwd=ROOT, check=True,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=60).stdout


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def verify(data: bytes, entry: dict) -> None:
    blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
    if blob != entry["blob"] or digest(data) != entry["sha256"]:
        raise ValueError("pinned dependency mismatch: " + entry["path"])


def exclusive_output(name: str) -> Path:
    path = Path(name)
    if path.is_absolute() or ".." in path.parts or len(path.parts) < 2 or path.parts[0] != "build":
        raise ValueError("--out must be a NEW directory under build, without ..")
    out = ROOT / path
    for parent in (out, *out.parents):
        if parent.is_symlink():
            raise ValueError("symlink output is not allowed")
        if parent == ROOT:
            break
    out.mkdir(parents=True, exist_ok=False)
    (out / ".gitignore").write_text("*\n")
    return out


def extract_base(data: bytes, target: Path) -> None:
    """Reject links/devices and traversal; only ordinary tracked files/directories."""
    target.mkdir()
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:") as archive:
        members = archive.getmembers()
        for member in members:
            path = Path(member.name)
            if path.is_absolute() or ".." in path.parts or not (member.isdir() or member.isfile()):
                raise ValueError("unsupported archive member: " + member.name)
        for member in members:
            path = target / member.name
            if member.isdir():
                path.mkdir(parents=True, exist_ok=True)
                continue
            path.parent.mkdir(parents=True, exist_ok=True)
            source = archive.extractfile(member)
            if source is None:
                raise ValueError("missing archive member data")
            with source, path.open("xb") as stream:
                shutil.copyfileobj(source, stream)
            path.chmod(member.mode & 0o777)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cc", choices=["gcc", "clang"], default="gcc")
    parser.add_argument("--out", required=True)
    parser.add_argument("--baseline", choices=["ants2", "icarus"], default="ants2",
                        help="host compile configuration only; no driver is started")
    parser.add_argument("--sanitize", action="store_true",
                        help="ASan/UBSan on test, included root core and directly linked adapters")
    parser.add_argument("--mutants", action="store_true",
                        help="four compiled semantic controls; use a non-sanitized run")
    args = parser.parse_args()
    if args.sanitize and args.mutants:
        parser.error("run semantic mutants separately without --sanitize")
    report = {"status": "FAIL", "compiler": args.cc, "baseline": args.baseline,
              "sanitized_direct_units": args.sanitize, "support_objects_sanitized": False, "sanitizer_executable_no_pie": args.sanitize,
              "hardware": False, "pool_submission": False, "a16_tested": False,
              "commands": [], "mutants": []}
    out = None
    try:
        manifest = json.loads((HERE / "manifest.json").read_text())
        base = manifest["base"]
        if git_bytes("rev-parse", base + "^{tree}").decode().strip() != manifest["base_tree"]:
            raise ValueError("base tree mismatch")
        dependencies = [(e, git_bytes("show", e["commit"] + ":" + e["path"]))
                        for e in manifest["pending"]]
        for entry, data in dependencies:
            verify(data, entry)
        out = exclusive_output(args.out)
        native = out / "source"
        extract_base(git_bytes("archive", "--format=tar", base), native)
        tests = native / REL
        tests.mkdir(parents=True, exist_ok=False)
        report.update(base=base, base_tree=manifest["base_tree"],
                      dependencies=manifest["pending"], test_files={})
        for name in ("test_stack.c", "suite.mk"):
            data = (HERE / name).read_bytes()
            (tests / name).write_bytes(data)
            report["test_files"][name] = digest(data)
        deps = native / "build/r01-deps"
        for entry, data in dependencies:
            path = deps / entry["path"]
            path.parent.mkdir(parents=True, exist_ok=True)
            with path.open("xb") as stream:
                stream.write(data)
        logs = out / "logs"
        logs.mkdir()

        def run(stage: str, command: list[str], allowed=(0,), timeout=180) -> str:
            start = time.monotonic()
            log = logs / (stage + ".log")
            record = {"stage": stage, "argv": command, "log": str(log.relative_to(out)),
                      "returncode": None}
            report["commands"].append(record)
            with log.open("xb") as stream:
                done = subprocess.run(command, cwd=native, stdout=stream,
                                      stderr=subprocess.STDOUT, timeout=timeout)
            record.update(returncode=done.returncode, seconds=round(time.monotonic()-start, 3),
                          log_sha256=digest(log.read_bytes()))
            print(stage + ": exit " + str(done.returncode), flush=True)
            if done.returncode not in allowed:
                raise RuntimeError(stage + " failed; see " + str(log))
            return log.read_text(errors="replace")

        report["compiler_version"] = run("compiler", [args.cc, "--version"]).splitlines()[0]
        run("autoreconf", ["autoreconf", "-fi"])
        options = ["./configure", "--enable-" + args.baseline, "--disable-curses",
                   "CC=" + args.cc, "CFLAGS=-O2 -fcommon"]
        if args.baseline == "ants2":
            options.append("--disable-libcurl")
        run("configure", options)
        run("native-core-build", ["make", "-j2"])
        make = ["make", "-f", "Makefile", "-f", str(REL / "suite.mk"), "CC=" + args.cc]
        test_dir = "build/r01-test"
        flags = ["R01_DIR=" + test_dir] + (["SANITIZE=1"] if args.sanitize else [])
        text = run("integration", make + flags + ["r01-test"])
        required = ["R01_STACK_PASS cases=8 ",
                    "R01_CANCELLATION outer_guard=0 bytes=88 job_status=-108",
                    "R01_CANCELLATION outer_guard=1 bytes=88 job_status=0",
                    "R01_UNCERTAIN bytes=5 quarantined=1 inactive_refused=1",
                    "R01_UNCERTAIN bytes=88 quarantined=1 inactive_refused=1",
                    "R01_SLOTS count=32 no_in_epoch_reuse=1 stale_epoch_rejected=1"]
        if any(marker not in text for marker in required):
            raise RuntimeError("integration markers incomplete")
        report["integration_markers"] = [line for line in text.splitlines() if line.startswith("R01_")]
        symbols = run("symbols", ["nm", "--defined-only", test_dir + "/test"])
        names = {line.split()[-1] for line in symbols.splitlines() if line.split()}
        expected = {"copy_work_noffset", "_free_work", "test_nonce", "fulltest",
                    "dizzass_jobs_prepare_tx88", "dizzass_jobs_finish", "dizzass_jobs_check",
                    "dizzass_uart_channel_send", "__wrap_socket", "__wrap_connect"}
        if not expected <= names:
            raise RuntimeError("missing actual native helper or offline guard symbols")
        report["native_symbols"] = sorted(expected)
        if args.mutants:
            jobs = native / "integration/native_jobs.c"
            channel = deps / "integration/native/uart_channel.c"
            controls = [
                ("uncertain-as-written", jobs,
                 "if (outcome == DIZZASS_TX_WRITTEN)\n        slot->state = SLOT_WRITTEN;",
                 "if (outcome == DIZZASS_TX_WRITTEN || outcome == DIZZASS_TX_UNCERTAIN)\n        slot->state = SLOT_WRITTEN;",
                 "dizzass_jobs_ticket_live(f.jobs,&p.ticket)==DIZZASS_JOBS_QUARANTINED"),
                ("never-publish-written", jobs,
                 "if (outcome == DIZZASS_TX_WRITTEN)\n        slot->state = SLOT_WRITTEN;",
                 "if (outcome == DIZZASS_TX_WRITTEN)\n        slot->state = SLOT_PREPARED;",
                 "dizzass_jobs_check(f->jobs,17,reply,&r)==0"),
                ("ignore-received-epoch", jobs,
                 "return epoch == jobs->epoch ? DIZZASS_JOBS_OK : DIZZASS_JOBS_OLD_EPOCH;",
                 "return DIZZASS_JOBS_OK;",
                 "dizzass_jobs_check(f.jobs,17,&old_reply,&result)==DIZZASS_JOBS_OLD_EPOCH"),
                ("ignore-stopped-gate", channel,
                 "if (c->state.stopped) { r = answer(DIZZASS_UART_CANCELED, ECANCELED); break; }",
                 "if (false) { r = answer(DIZZASS_UART_CANCELED, ECANCELED); break; }",
                 "command.transport.status==DIZZASS_UART_CANCELED && command.transport.written==0"),
            ]
            for name, path, old, new, witness in controls:
                original = path.read_bytes()
                if original.decode().count(old) != 1:
                    raise ValueError("mutant source anchor changed: " + name)
                try:
                    path.write_text(original.decode().replace(old, new, 1))
                    directory = "build/r01-mutant-" + name
                    run(name + "-build", make + ["R01_DIR=" + directory, directory + "/test"])
                    rejected = run(name + "-run", [directory + "/test"], allowed=(1,), timeout=30)
                    if "R01_ASSERT " not in rejected or witness not in rejected:
                        raise RuntimeError("control did not fail at its semantic witness: " + name)
                    report["mutants"].append({"name": name, "semantic_rejection": True})
                finally:
                    path.write_bytes(original)
                if path.read_bytes() != original:
                    raise RuntimeError("mutant source restoration failed")
        for entry, data in dependencies:
            verify((deps / entry["path"]).read_bytes(), entry)
        report["status"] = "PASS"
        print("R01_REVIEW_PASS: 8 host scenarios; no ASIC, no pool, no A-16 acceptance", flush=True)
        return 0
    except (OSError, ValueError, KeyError, RuntimeError, subprocess.SubprocessError) as error:
        report["error"] = str(error)
        print("R01_REVIEW_ERROR: " + str(error), file=sys.stderr)
        return 1
    finally:
        if out is not None:
            (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    raise SystemExit(main())

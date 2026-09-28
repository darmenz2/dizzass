#!/usr/bin/env python3
"""Semantic controls for the NEW channel only; staging-integrity checks."""
from __future__ import annotations
import argparse
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "integration/native/uart_channel.c"
MUTANTS = {
    "real_time_wait": ("pthread_condattr_setclock(&attributes, CLOCK_MONOTONIC)", "pthread_condattr_setclock(&attributes, CLOCK_REALTIME)"),
    "allow_parallel_frames": ("c->state.active = true;", "c->state.active = false;"),
    "lose_fault_latch": ("if (r.status != DIZZASS_UART_OK) c->state.stopped = true;", "if (r.status != DIZZASS_UART_OK) c->state.stopped = false;"),
    "lose_last_result": ("c->state.last = r;", "c->state.last = answer(DIZZASS_UART_OK, 0);"),
    "lose_has_result": ("c->state.has_result = true;", "c->state.has_result = false;"),
    "wrong_fd": ("write_all(c->fd, data, length, deadline, budget)", "write_all(c->fd + 1, data, length, deadline, budget)"),
    "wrong_pointer": ("write_all(c->fd, data, length, deadline, budget)", "write_all(c->fd, data + 1, length, deadline, budget)"),
    "wrong_length": ("write_all(c->fd, data, length, deadline, budget)", "write_all(c->fd, data, length - 1, deadline, budget)"),
    "extend_deadline": ("write_all(c->fd, data, length, deadline, budget)", "write_all(c->fd, data, length, deadline + 1, budget)"),
    "wrong_budget": ("write_all(c->fd, data, length, deadline, budget)", "write_all(c->fd, data, length, deadline, budget - 1)"),
    "cancel_enabled_in_owner": ("pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, saved)", "pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, saved)"),
    "stopped_returns_success": ("answer(DIZZASS_UART_CANCELED, ECANCELED)", "answer(DIZZASS_UART_OK, 0)"),
    "expired_enters_io": ("if (now >= deadline) { r = answer", "if (now == 0) { r = answer"),
    "stop_timeout_is_success": ("if (now >= deadline) { e = ETIMEDOUT; break; }", "if (now >= deadline) { e = 0; break; }"),
}

def stage_checks(deps: Path) -> None:
    spec = importlib.util.spec_from_file_location("channel_prepare", ROOT / "tools/prepare_uart_channel.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    count = 0
    def rejected(out: Path, src: Path | None, check: bool) -> None:
        nonlocal count
        try:
            module.prepare(out, src, check)
        except (ValueError, OSError):
            count += 1
        else:
            raise RuntimeError("staging accepted invalid input")
    (ROOT / "build").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=ROOT / "build", prefix="a14-stage-") as d:
        base = Path(d)
        out = base / "valid"
        module.prepare(out, deps, False); module.prepare(out, None, True); count += 1
        target = out / "integration/native/uart_safe.c"
        original = target.read_bytes(); target.write_bytes(original + b"\n")
        rejected(out, None, True); rejected(out, deps, False)
        target.write_bytes(original)
        shadow = out / "integration/native/shadow.h"; shadow.write_text("bad")
        rejected(out, None, True); shadow.unlink()
        target.unlink(); target.symlink_to(deps / "integration/native/uart_safe.c")
        rejected(out, None, True); target.unlink(); target.write_bytes(original)
        link = base / "link"; link.symlink_to(out, target_is_directory=True)
        rejected(link, deps, False)
        rejected(ROOT / "integration/forbidden-channel-output", deps, False)
        rejected(ROOT / "build/../integration/forbidden-channel-output", deps, False)
        rejected(base / "missing", None, True)
        broken = base / "source"; shutil.copytree(deps, broken)
        (broken / "integration/native/uart_posix.c").write_bytes(b"bad")
        rejected(base / "badinput", broken, False)
    print("UART_CHANNEL_STAGING_PASS checks=" + str(count))

def run(cc: str, deps: Path, out: Path) -> None:
    source = SOURCE.read_text()
    out.mkdir(parents=True, exist_ok=True)
    records = []
    for name, replacement in [("baseline", None), *MUTANTS.items()]:
        text = source
        if replacement:
            before, after = replacement
            if before not in text: raise RuntimeError("missing mutant site: " + name)
            text = text.replace(before, after, 1)
        path = out / (name + ".c"); path.write_text(text)
        binary = out / name
        cmd = [cc,"-I.","-I"+str(deps),"-std=c11","-O1","-g","-Wall","-Wextra","-Wpedantic","-Werror","-pthread",
               str(path),str(deps/"integration/native/uart_posix.c"),str(deps/"integration/native/uart_safe.c"),"integration/tests/test_uart_channel.c",
               "-Wl,--wrap=dizzass_uart_posix_write_all,--wrap=dizzass_uart_posix_now_ms,--wrap=pthread_condattr_setclock,--wrap=pthread_cond_init,--wrap=pthread_cond_timedwait","-o",str(binary)]
        build = subprocess.run(cmd,cwd=ROOT,capture_output=True,text=True,timeout=30)
        (out/(name+".build.log")).write_text(build.stdout+build.stderr)
        if build.returncode: raise RuntimeError("build error, NOT rejection: " + name)
        result = subprocess.run([str(binary)],cwd=ROOT,capture_output=True,text=True,timeout=25)
        (out/(name+".log")).write_text(result.stdout+result.stderr)
        if name == "baseline":
            if result.returncode != 0 or "UART_CHANNEL_CONTROL_PASS" not in result.stdout: raise RuntimeError("baseline failed")
        elif result.returncode != 1 or "UART_CHANNEL_ASSERT" not in result.stderr:
            raise RuntimeError("not a semantic rejection: " + name + " code=" + str(result.returncode))
        records.append({"name":name,"build_exit":build.returncode,"test_exit":result.returncode})
    summary = {"compiler":cc,"rejected":len(MUTANTS),"records":records}
    (out/"summary.json").write_text(json.dumps(summary,indent=2)+"\n")
    print("UART_CHANNEL_NEGATIVE_PASS " + json.dumps(summary))

def main() -> None:
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("--cc",default="cc");p.add_argument("--deps",type=Path,default=ROOT/"build/a14-deps")
    p.add_argument("--out",type=Path,default=ROOT/"build/a14-negative");p.add_argument("--staging-checks",action="store_true")
    a=p.parse_args();deps=a.deps.resolve();out=a.out.resolve()
    if a.staging_checks: stage_checks(deps)
    else: run(a.cc,deps,out)

if __name__ == "__main__": main()

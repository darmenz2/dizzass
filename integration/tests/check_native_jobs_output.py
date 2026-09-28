#!/usr/bin/env python3
"""Check test completion and real native linkage; not a hardware certificate."""
from __future__ import annotations
import argparse
import re
from pathlib import Path


def verify(log: Path, symbols: Path) -> None:
    text = log.read_text(encoding="utf-8")
    summaries = re.findall(r"^NATIVE_JOBS_PASS groups=(\d+) assertions=(\d+)$", text, re.M)
    if len(summaries) != 1 or int(summaries[0][0]) != 6 or int(summaries[0][1]) < 1000:
        raise ValueError("Missing or unexpected registry test summary")
    threads = re.findall(r"^NATIVE_JOBS_THREADS reads=4000 transitions=200 snapshots=(\d+) rejected=(\d+)$", text, re.M)
    if len(threads) != 1 or sum(map(int, threads[0])) != 4000:
        raise ValueError("Incomplete concurrent read accounting")
    names = {line.split()[-1] for line in symbols.read_text().splitlines() if line.split()}
    required = {"dizzass_jobs_create", "dizzass_jobs_prepare", "dizzass_jobs_finish",
                "dizzass_jobs_check", "dizzass_jobs_retire", "dizzass_jobs_pause",
                "dizzass_jobs_begin_drained_epoch", "dizzass_jobs_ticket_live",
                "dizzass_jobs_destroy", "dizzass_job_result_clear", "__wrap_strdup",
                "copy_work_noffset", "test_nonce", "fulltest", "_free_work"}
    if required - names:
        raise ValueError(f"Missing native/registry symbols: {sorted(required - names)}")
    print("Native job registry PASS: lifetime, send outcomes, epochs, OOM, RX, concurrency")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("log", type=Path)
    parser.add_argument("symbols", type=Path)
    args = parser.parse_args()
    verify(args.log, args.symbols)

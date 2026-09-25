#!/usr/bin/env python3
"""Check real native submission/queue coverage, not pool acceptance."""
import re
import sys
from pathlib import Path


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: check_native_submit_output.py LOG SYMBOLS")
    text = Path(sys.argv[1]).read_text()
    markers = re.findall(r"^NATIVE_SUBMIT_PASS groups=(\d+) rx_fragments=(\d+) assertions=(\d+)$", text, re.M)
    if len(markers) != 1 or tuple(map(int, markers[0][:2])) != (6, 11) or int(markers[0][2]) < 200:
        raise SystemExit("Missing or incomplete native submission checks")
    if "NATIVE_SUBMIT_THREADS calls=64 chains=2 valid=1 rejected=63" not in text:
        raise SystemExit("Cross-chain serialization check missing")
    symbols = {line.split()[-1] for line in Path(sys.argv[2]).read_text().splitlines() if line.split()}
    required = {"submit_nonce", "submit_tested_work", "tq_new", "tq_push", "tq_pop",
                "dizzass_submitter_create", "dizzass_submitter_run", "dizzass_submitter_stop",
                "dizzass_submitter_destroy", "dizzass_nonce_match_status", "__wrap_tq_push"}
    if required - symbols:
        raise SystemExit(f"Native submission symbols missing: {sorted(required - symbols)}")
    print("Native submission PASS: real submit_nonce, native queue/stale/stats, shared gate; no live pool")


if __name__ == "__main__":
    main()

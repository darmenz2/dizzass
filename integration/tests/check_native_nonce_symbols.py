#!/usr/bin/env python3
"""Require native core symbols and reject a second recovery core in this harness."""
import sys
from pathlib import Path

symbols = {line.split()[-1] for line in Path(sys.argv[1]).read_text().splitlines() if line.split()}
required = {'copy_work_noffset', '_free_work', 'test_nonce', 'fulltest', 'sha256',
            'dizzass_nonce_decode_payload', 'dizzass_nonce_check_matched', 'dizzass_nonce_check_clear',
            '__wrap_socket', '__wrap_connect', '__wrap_libusb_init'}
allowed_reference = {'vn135_work_rx_policy_init', 'vn135_work_rx_filtered_register',
                     'vn135_work_rx_job_slot', 'vn135_work_rx_next',
                     'vn135_work_nonce_version_bits', 'vn135_work_rx_stream_init',
                     'vn135_work_rx_stream_feed'}
missing = required - symbols
unexpected = {s for s in symbols if s.startswith('vn135_')} - allowed_reference
if missing or unexpected:
    raise SystemExit(f'Native boundary failed: missing={sorted(missing)} unexpected_recovery={sorted(unexpected)}')
print('Native symbol boundary PASS: real cgminer core; recovery RX only, no recovery SHA/work/target')

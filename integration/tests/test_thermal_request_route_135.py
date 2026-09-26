#!/usr/bin/env python3
"""Read-only audit of the original BM1368 temperature method selection.
No reconstructed successful stubs are provided. Only original instructions run
inside the bounded interpreter; the production request emitter is unresolved.
"""
import argparse
import hashlib
import json
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from arm32_difficulty_subset import ARM32Difficulty
from elf32 import ELF32
REFERENCE_HASH = 'b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9'
TABLE = 0x840110
METHODS = {0xc0: 0xe49c4, 0xc4: 0xe49cc, 0xc8: 0xe49d4, 0xcc: 0xe49dc}
RANGES = ((0xd21dc, 0xd24ec), (0xe1450, 0xe16b8), (0xe49c4, 0xe49e4))
class AuditArm(ARM32Difficulty):
    def extra_instruction(self, word, pc):
        if not any(a <= pc < b for a, b in RANGES):
            raise ValueError('Unexpected request-route instruction: %x' % pc)
        return super().extra_instruction(word, pc)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--summary')
    args = ap.parse_args()
    elf = ELF32(ROOT / 'reference/cgminer.vendor.elf')
    assert hashlib.sha256(elf.data).hexdigest() == REFERENCE_HASH
    evidence = json.loads((ROOT / 'integration/evidence/thermal_completion_135.json').read_text())
    for region in evidence['ranges'].values():
        a, b = int(region['start'], 16), int(region['end_exclusive'], 16)
        assert hashlib.sha256(elf.read(a, b-a)).hexdigest() == region['sha256']
    for item in evidence['xor_literals']:
        data = elf.read(int(item['address'], 16), item['length'])
        assert hashlib.sha256(data).hexdigest() == item['encoded_sha256']
        assert bytes(v ^ item['xor'] for v in data) == item['text'].encode() + b'\0'
    # mov r0,#0; bx lr. Both instructions and their order are pinned.
    code = bytes.fromhex('0000a0e31eff2fe1')
    for entry in METHODS.values():
        assert elf.read(entry, 8) == code
    selection_cases = 0
    leaf_cases = 0
    for platform in range(5):
        for subtype in (0, 1, 0xffffffff):
            m = AuditArm(elf)
            m.mem[TABLE-16:TABLE+0x240] = b'\xa5' * 0x250
            # Signature proved at the caller: platform, chip selector, subtype,
            # output table. Selector 4 is the previously established BM1368.
            m.reset((platform, 4, subtype, TABLE))
            assert m.run(0xd21dc, max_steps=10000) == 0
            for offset, entry in METHODS.items():
                assert m.read(TABLE+offset) == entry
            assert m.mem[TABLE-16:TABLE] == b'\xa5'*16
            assert m.mem[TABLE+0xe0:TABLE+0x240] == b'\xa5'*(0x240-0xe0)
            selection_cases += 1
    for entry in METHODS.values():
        for seed in (0, 1, 255, 0xffffffff):
            m = AuditArm(elf)
            m.reset((0x840400, seed, 0x840800, 0x840c00))
            m.mem[0x840000:0x841000] = bytes([seed & 255]) * 0x1000
            before = bytes(m.mem)
            regs = m.r[:]
            assert m.run(entry, max_steps=4) == 0
            assert bytes(m.mem) == before
            assert m.r[1:15] == regs[1:15]
            assert m.steps == 2
            leaf_cases += 1
    result = {
        'selection_cases': selection_cases,
        'original_noop_cases': leaf_cases,
        'chip_selector': 4,
        'table_relative_offsets': {hex(k): hex(v) for k,v in METHODS.items()},
        'backend_offsets_if_table_at_110': {hex(k+0x110): hex(v) for k,v in METHODS.items()},
        'original_dispatch_and_table_body_executed': True,
        'original_leaf_bodies_executed': True,
        'production_success_stubs_added': False,
        'full_rx_query_emitter_recovered': False,
        'physical_profile_t21_confirmed': False,
        'physical_io': False,
        'reference_sha256': REFERENCE_HASH,
    }
    print('THERMAL_REQUEST_ROUTE135_PASS', json.dumps(result, sort_keys=True))
    if args.summary:
        Path(args.summary).write_text(json.dumps(result, indent=2)+'\n')
if __name__ == '__main__':
    main()

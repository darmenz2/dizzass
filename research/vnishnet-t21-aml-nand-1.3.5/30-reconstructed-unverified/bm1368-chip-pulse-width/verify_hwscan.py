#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-3.0-only
"""Optional static corroboration against the privately retained hwscan ELF.

Reads the two reference files and checked-in evidence as data. It never
executes, loads as a process, or emulates either reference executable.
Uses only the Python standard library and the existing tools/elf32.py reader;
the archived Capstone listing is checksum-verified rather than re-rendered.
This comparison establishes one bounded method's correspondence, not the
writer/logger internals, its callers, hardware acceptance, or native linkage.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

FOLDER = Path(__file__).resolve().parent
ROOT = FOLDER.parents[3]
sys.path.insert(0, str(ROOT / "tools"))
from elf32 import ELF32

CGMINER_SHA256 = "b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9"
HWSCAN_SHA256 = "951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077"
CG_START, CG_END = 0xe33e0, 0xe34b8
HW_START, HW_CODE_END, HW_POOL_END = 0xf3174, 0xf324c, 0xf3260
RANGES = (
    (HW_START, HW_CODE_END, "275315f6bf34601e73c7cb5e7db75048c13ad952de7326ab0ed54aace2a21240"),
    (HW_CODE_END, HW_POOL_END, "453a1d4d3cd56e572f2e232b53c49449b55ee586fb5dd02f63cf14dfda17b2d7"),
    (HW_START, HW_POOL_END, "73fa3b93bbb7c2c18acf9f8369ad6650fd453ab8010544cd91729b50086427fa"),
)
REPORT_HASHES = {
    "hwscan.json": "24bbc0293c2fa7bc8ff34204f9ede6a45c0e50b296edc0960b5478eb62234eb3",
    "hwscan.asm": "8ccb5b9405db23c80f8687b335c158c8c49e85bd43d7358547f8fed672e2a21c",
}
# offset: (cgminer BL word, cgminer target, hwscan BL word, hwscan target).
CALLS = {
    0x40: (0xeb000593, 0xe4a74, 0xeb0002f0, 0xf3d7c),
    0x94: (0xeb005b12, 0xfa0c4, 0xeb002f28, 0xfeeb0),
    0xc4: (0xeb005b06, 0xfa0c4, 0xeb002f1c, 0xfeeb0),
}
# Exact ARM words covering the packed fifth argument, unicast/chip boundary,
# status branch, source-line arguments and the two separate device+18 loads.
OPERANDS = {
    0x10: 0xe3a00038,  # mov r0,#0x38
    0x14: 0xe0000183,  # and r0,r0,r3,lsl #3
    0x18: 0xe1a04001,  # mov r4,r1: preserve original chip
    0x1c: 0xe3a01000,  # mov r1,#0: unicast mode
    0x20: 0xe3a0303c,  # mov r3,#0x3c
    0x24: 0xe7c70312,  # bfi r0,r2,#6,#2
    0x28: 0xe1a02004,  # mov r2,r4: original chip
    0x2c: 0xe3800902,  # orr r0,r0,#0x8000
    0x30: 0xe3a05000,  # mov r5,#0: success result
    0x34: 0xe3800102,  # orr r0,r0,#0x80000000
    0x38: 0xe58d0000,  # str r0,[sp]: fifth writer argument
    0x3c: 0xe1a00006,  # mov r0,r6: original device
    0x44: 0xe3500000,  # cmp r0,#0
    0x48: 0x0a00001f,  # beq common return
    0x50: 0xe3a04001,  # severity 1
    0x58: 0xe3003183,  # source line 387
    0x64: 0xe5960018,  # first fresh device index load
    0x74: 0xe2800001,  # first unsigned one-based index
    0x98: 0xe5960018,  # second fresh device index load
    0xa4: 0xe300321a,  # source line 538
    0xa8: 0xe2800001,  # second unsigned one-based index
    0xc8: 0xe3e05000,  # mvn r5,#0: failure result -1
    0xcc: 0xe1a00005,  # mov r0,r5
    0xd4: 0xe8bd8df0,  # pop including pc
}
# (pool word address, PC-relative ADD address, absolute plaintext target,
#  exact text including the final NUL byte).
STRINGS = (
    (0xf324c, 0xf31d4, 0x47d914, b"driver\0"),
    (0xf3250, 0xf31dc, 0x47e7ef, b"/tmp/build/libbitmain/src/chip/chip1368.c\0"),
    (0xf3254, 0xf31e4, 0x47d359, b"[redacted]\0"),
    (0xf3258, 0xf31f0, 0x47e5a3, b"chain#%d - failed to send core command\0"),
    (0xf325c, 0xf3224, 0x47e20d, b"chain#%d - failed to set CLOCK_DELAY_CTRL\0"),
)


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def word(elf: ELF32, address: int) -> int:
    return int.from_bytes(elf.read(address, 4), "little")


def bl_target(opcode: int, address: int) -> int:
    require(opcode & 0xff000000 == 0xeb000000,
            f"expected unconditional ARM BL at {address:#x}")
    displacement = opcode & 0xffffff
    if displacement & 0x800000:
        displacement -= 0x1000000
    return (address + 8 + displacement * 4) & 0xffffffff


def verify(hwscan: Path, cgminer: Path, evidence: Path) -> dict:
    cg, hw = ELF32(cgminer), ELF32(hwscan)
    require(sha256(cg.data) == CGMINER_SHA256, "cgminer reference identity mismatch")
    require(sha256(hw.data) == HWSCAN_SHA256, "hwscan reference identity mismatch")
    require(cg.machine == hw.machine == 40, "expected ARM ELF32 references")
    require(CG_END - CG_START == HW_CODE_END - HW_START == 216,
            "method code bound mismatch")
    require(HW_POOL_END - HW_CODE_END == 20, "literal pool bound mismatch")
    for start, end, expected_hash in RANGES:
        require(sha256(hw.read(start, end-start)) == expected_hash,
                f"hwscan range hash mismatch: [{start:#x},{end:#x})")

    equal_noncall_words = 0
    for offset in range(0, 216, 4):
        cg_word, hw_word = word(cg, CG_START + offset), word(hw, HW_START + offset)
        if offset in CALLS:
            cg_expected, cg_target, hw_expected, hw_target = CALLS[offset]
            require((cg_word, hw_word) == (cg_expected, hw_expected),
                    f"BL word mismatch at method offset {offset:#x}")
            require(bl_target(cg_word, CG_START+offset) == cg_target,
                    f"cgminer BL target mismatch at offset {offset:#x}")
            require(bl_target(hw_word, HW_START+offset) == hw_target,
                    f"hwscan BL target mismatch at offset {offset:#x}")
        else:
            require(cg_word == hw_word, f"non-call word mismatch at offset {offset:#x}")
            require(cg_word & 0x0f000000 != 0x0b000000,
                    f"unexpected BL in non-call word at offset {offset:#x}")
            equal_noncall_words += 1
    require(equal_noncall_words == 51, "expected exactly 51 equal non-call words")
    for offset, expected_word in OPERANDS.items():
        require(word(hw, HW_START+offset) == expected_word,
                f"bounded operand mismatch at offset {offset:#x}")
    for literal, pc_add, address, expected in STRINGS:
        require((pc_add + 8 + word(hw, literal)) & 0xffffffff == address,
                f"logger PC-relative literal mismatch at {literal:#x}")
        require(hw.read(address, len(expected)) == expected,
                f"plaintext logger metadata mismatch at {address:#x}")

    # Pin the original archived report/listing bytes. No Capstone installation
    # or disassembler version is required to reproduce this verification.
    for name, expected_hash in REPORT_HASHES.items():
        require(sha256((evidence / name).read_bytes()) == expected_hash,
                f"archived evidence checksum mismatch: {name}")
    report = json.loads((evidence / "hwscan.json").read_text(encoding="utf-8"))
    require(report["reference_sha256"] == HWSCAN_SHA256,
            "archived report hwscan identity mismatch")
    require(report["firmware_execution"] is False and report["firmware_emulation"] is False,
            "archived report static-only boundary mismatch")
    require(report["cgminer_comparison"]["reference_sha256"] == CGMINER_SHA256,
            "archived report cgminer identity mismatch")
    return {"passed": True, "reference_sha256": HWSCAN_SHA256,
            "code_bytes": 216, "pool_bytes": 20,
            "equal_noncall_words": equal_noncall_words,
            "verified_bl_calls": 3, "plaintext_logger_strings": 5,
            "archived_evidence_checksums": 2,
            "firmware_execution": False, "firmware_emulation": False}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--hwscan", type=Path, required=True,
                        help="exact privately retained hwscan ELF; read only")
    parser.add_argument("--cgminer", type=Path, default=ROOT / "reference/cgminer.vendor.elf",
                        help="exact cgminer reference ELF (default: repository reference)")
    parser.add_argument("--evidence", type=Path, default=FOLDER / "evidence",
                        help="directory containing archived hwscan.json and hwscan.asm")
    args = parser.parse_args()
    try:
        result = verify(args.hwscan, args.cgminer, args.evidence)
    except (OSError, ValueError, KeyError, TypeError, struct.error) as error:
        print(f"HWSCAN_CHIP_PULSE135_FAIL: {error}", file=sys.stderr)
        return 1
    print("HWSCAN_CHIP_PULSE135_STATIC_PASS " + json.dumps(result, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

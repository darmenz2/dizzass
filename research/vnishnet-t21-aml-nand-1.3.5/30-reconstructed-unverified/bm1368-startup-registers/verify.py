#!/usr/bin/env python3
"""Static byte/source integrity and bounded ARM encodings; not execution/equivalence."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
WITNESS_SHA256 = "0c46eba6b94087e1c54d7af9bb62aa5fac4965a34c8b078c6694feed6b6b7196"
REFERENCE_SHA256 = "b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9"


def require(ok, why):
    if not ok:
        raise ValueError(why)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def ordinary_file(root, relative):
    rel = PurePosixPath(relative)
    require(relative and not rel.is_absolute() and ".." not in rel.parts and "\\" not in relative,
            "unsafe relative path")
    path = root.joinpath(*rel.parts)
    for parent in [path, *path.parents]:
        if parent == root:
            break
        require(not parent.is_symlink(), "symlink source")
    require(path.is_file(), "missing/nonregular file: " + relative)
    return path


def validate_sources(root, entries):
    require(bool(entries), "empty source inventory")
    for relative, expected in entries.items():
        require(sha(ordinary_file(root, relative).read_bytes()) == expected,
                "source hash: " + relative)


def ror32(value, count):
    return ((value >> count) | (value << ((32 - count) % 32))) & 0xffffffff


def validate_document(m):
    require(m["schema"] == 1 and m["kind"] == "bm1368-startup-registers-static-witness", "schema")
    require(m["base_commit"] == "01299b84255542c16ee6d3f0c65a3e33e7aa876a", "base identity")
    require(m["original_execution"] is False and m["hardware"] is False and
            m["automatic_equivalence_proof"] is False, "scope flags")
    require(m["reference"] == {"path": "reference/cgminer.vendor.elf", "size": 6228004,
                              "sha256": REFERENCE_SHA256}, "reference identity")
    require(len(m["regions"]) == 33, "region count")
    regions = {}
    spans = []
    for row in m["regions"]:
        require(row["name"] not in regions, "duplicate region")
        require(row["kind"] in ("code", "data"), "code/data kind")
        b = bytes.fromhex(row["hex"])
        require(row["size"] > 0 and len(b) == row["size"] and sha(b) == row["sha256"], "region identity")
        require(0 <= row["va"] < row["va"] + len(b) <= 0x100000000, "region address")
        if row["kind"] == "code":
            require(row["va"] % 4 == 0 and len(b) % 4 == 0, "ARM instruction alignment")
        regions[row["name"]] = (row, b)
        spans.append((row["va"], row["va"] + len(b)))
    spans.sort()
    require(all(a[1] <= b[0] for a, b in zip(spans, spans[1:])), "overlapping regions")

    def word(address):
        for row, b in regions.values():
            offset = address - row["va"]
            if 0 <= offset <= len(b) - 4:
                return int.from_bytes(b[offset:offset + 4], "little")
        raise ValueError("word outside witnessed ranges")

    require(len(m["word_facts"]) == 135, "word fact count")
    for address, expected in m["word_facts"].items():
        require(word(int(address, 16)) == int(expected, 16), "instruction word fact")
    require(len(m["branches"]) == 14, "branch count")
    for edge in m["branches"]:
        w = word(edge["at"])
        require(w >> 24 == 0xeb, "unconditional ARM BL")
        displacement = w & 0xffffff
        if displacement & 0x800000:
            displacement -= 0x1000000
        require((edge["at"] + 8 + 4 * displacement) & 0xffffffff == edge["target"], "BL target")
        require(edge["target"] in (0xe4a74, 0xfa0c4, 0x107188), "unexpected external call")
    require(len(m["pc_targets"]) == 11, "PC target count")
    for row in m["pc_targets"]:
        load = word(row["load"])
        require(load & 0xffff0000 == 0xe59f0000, "PC literal load encoding")
        reg = (load >> 12) & 15
        require(row["load"] + 8 + (load & 0xfff) == row["literal"], "literal address")
        require(word(row["add"]) == (0xe08f0000 | (reg << 12) | reg), "PC add encoding")
        require((row["add"] + 8 + word(row["literal"])) & 0xffffffff == row["target"], "PC data target")
    require(len(m["constructor_slots"]) == 4, "constructor count")
    expected_slots = {0x80: 0xe35c0, 0x68: 0xe3098, 0x6c: 0xe3290, 0x94: 0xe3c04}
    require({s["output_offset"]: int(s["method_identity"], 16) for s in m["constructor_slots"]} == expected_slots,
            "constructor slot identities")
    for s in m["constructor_slots"]:
        load_at = int(s["load_instruction"], 16)
        got_at = int(s["got_load_instruction"], 16)
        literal = int(s["literal_address"], 16)
        got = int(s["got_address"], 16)
        reg = s["register"]
        w = word(load_at)
        require(w & 0xfffff000 == (0xe59f0000 | (reg << 12)), "constructor literal opcode")
        require(load_at + 8 + (w & 0xfff) == literal, "constructor literal pointer")
        require(word(literal) == int(s["literal_word"], 16), "constructor literal word")
        require(word(got_at) == (0xe79f0000 | (reg << 12) | reg), "constructor GOT load")
        require((got_at + 8 + word(literal)) & 0xffffffff == got, "constructor GOT address")
        require(word(got) == int(s["method_identity"], 16), "constructor GOT identity")
        store_at = int(s["store_instruction"], 16)
        store = word(store_at)
        if store & 0xfffff000 == (0xe5800000 | (reg << 12)):
            require(store & 0xfff == s["output_offset"], "single slot store")
        else:
            require(store & 0xffff0000 == 0xe8820000 and store & (1 << reg), "multi slot store")
            add = word(store_at - 4)
            require(add & 0xfffff000 == 0xe2802000, "multi slot base")
            base = ror32(add & 255, 2 * ((add >> 8) & 15))
            preceding = (store & ((1 << reg) - 1)).bit_count()
            require(base + 4 * preceding == s["output_offset"], "multi slot offset")
    require(len(m["strings"]) == 6, "string count")
    for s in m["strings"]:
        require(0 <= s["key"] <= 255, "XOR key range")
        raw = regions[s["region"]][1]
        decoded = bytes(v ^ s["key"] for v in raw)
        require(decoded.startswith(s["text"].encode("ascii") + b"\0"), "diagnostic plaintext")
    require(len(m["parity_sites"]) == 11, "parity count")
    for s in m["parity_sites"]:
        require(word(s["multiply"]) & 0x0fe000f0 == 0x00000090, "MUL parity site")
        require(word(s["test"]) & 0xfff0ffff == 0xe3100001, "TST low-bit parity site")
    return regions


def verify(root=ROOT, with_reference=False, directory=HERE):
    raw = ordinary_file(directory, "static-witness.json").read_bytes()
    require(sha(raw) == WITNESS_SHA256, "frozen witness hash")
    m = json.loads(raw)
    regions = validate_document(m)
    require(sha(ordinary_file(directory, "original-code.asm").read_bytes()) == m["disassembly_sha256"], "disassembly hash")
    validate_sources(root, m["source_sha256"])
    if with_reference:
        source = ordinary_file(root, m["reference"]["path"])
        image = source.read_bytes()
        require(len(image) == 6228004 and sha(image) == REFERENCE_SHA256, "complete ELF identity")
        sys.path.insert(0, str(root / "tools"))
        from elf32 import ELF32
        elf = ELF32(source)
        require(elf.machine == 40, "ARM ELF machine")
        for row, b in regions.values():
            require(elf.read(row["va"], len(b)) == b, "original range mismatch")
    return {"regions": len(regions), "bytes": sum(len(b) for _, b in regions.values()),
            "words": len(m["word_facts"]), "direct_call_sites": len(m["branches"]),
            "constructor_slots": 4, "source_pins": len(m["source_sha256"]),
            "reference_read_as_data": with_reference, "original_execution": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=ROOT)
    parser.add_argument("--with-reference", action="store_true")
    args = parser.parse_args()
    print("STARTUP_REGISTERS_STATIC_PASS " + json.dumps(verify(args.root.resolve(), args.with_reference), sort_keys=True))


if __name__ == "__main__":
    main()

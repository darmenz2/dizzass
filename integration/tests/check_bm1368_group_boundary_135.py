#!/usr/bin/env python3
"""Host-only builds and compiled semantic controls. Never executes reference ELF."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
SOURCES = [
    "integration/bm1368_group_boundary_135.c",
    "libbitmain/src/chip/chip1368-group-boundary.c",
    "libbitmain/src/chip/chip1368-register-write.c",
    "libbitmain/src/reg_cache.c", "integration/bm1368_control.c",
    "reconstruction/support/crc5.c",
    "integration/tests/test_bm1368_group_boundary_135.c",
]
HEADERS = ["integration/bm1368_group_boundary_135.h",
    "integration/bm1368_register_write_135.h", "integration/bm1368_frequency_135.h",
    "integration/bm1368_control.h", "include/xminer/recovery/reg_cache.h",
    "include/xminer/recovery/chip1398.h", "include/xminer/recovery/pll.h",
    "reconstruction/data/reg_cache_defaults.inc"]
# Exactly one safe source substitution per control. A crash/timeout/build error
# is NOT a detected semantic control. Existing dependencies are never mutated.
CONTROLS = [
    (1,"reg30","0x2c, value","0x30, value"),
    (1,"broadcast","(device, 0, chip","(device, 1, chip"),
    (1,"base2","UINT32_C(3) |","UINT32_C(2) |"),
    (1,"shift15","setting << 16","setting << 15"),
    (1,"upper-field","setting << 16","setting & UINT32_C(0xffff0000)"),
    (1,"error-success","return -1;","return 0;"),
    (1,"line720","721, 1,","720, 1,"),
    (1,"raw-chain-index","device->index + UINT32_C(1)","device->index"),
    (1,"wire-diagnostic","(uint32_t)chip->cache_index + UINT32_C(1)","chip->wire_address + UINT32_C(1)"),
    (0,"selector3","== 4)","== 3)"),
    (0,"gate11","(count) < 10","(count) < 11"),
    (0,"unsigned-gate","boundary_signed_135(count) < 10","count < 10u"),
    (0,"initial-offbyone","group = count - board->group_step;","group = count - board->group_step + 1u;"),
    (0,"offset13","+ 14u : 0u","+ 13u : 0u"),
    (0,"offset-count-snapshot","(board->group_count - group)","(count - group)"),
    (0,"first-offbyone","index = board->chips_per_group * group;","index = board->chips_per_group * group + 1u;"),
    (0,"last-offbyone","size * group + size - UINT32_C(1)","size * group + size"),
    (0,"last-uses-first-flag","if (board->configure_last != 0)","if (board->configure_first != 0)"),
    (0,"first-address-offbyone","first.wire_address = index * board->address_stride;","first.wire_address = index * board->address_stride + 1u;"),
    (0,"step-one","group -= board->group_step;","group -= 1u;"),
    (0,"zero-step-skip","if ((group & UINT32_C(0x80000000)) != 0)","if (board->group_step == 0 || (group & UINT32_C(0x80000000)) != 0)"),
]

def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def run(command, timeout, env, record):
    result = subprocess.run(command, cwd=ROOT, capture_output=True,
                            text=True, timeout=timeout, env=env)
    record.append(dict(command=[str(x) for x in command], exit=result.returncode,
                       stdout=result.stdout, stderr=result.stderr))
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cc", default="cc")
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--sanitize", action="store_true")
    parser.add_argument("--mutants", action="store_true")
    args=parser.parse_args()
    out=args.out.resolve()
    out.mkdir(parents=True,exist_ok=False)
    report={"result":"incomplete", "cc":args.cc, "sanitized_all_seven_tus":args.sanitize,
        "leak_detection":False, "hardware":False, "original_execution":False,
        "source_sha256":{x:digest(ROOT/x) for x in SOURCES+HEADERS},
        "runner_sha256":digest(Path(__file__)), "commands":[], "controls":[]}
    flags=["-I"+str(ROOT),"-I"+str(ROOT/"include"),"-std=c11","-O1","-g",
        "-Wall","-Wextra","-Wpedantic","-Werror","-Wshadow",
        "-DVN135_BM1368_GROUP_BOUNDARY_135","-DVN135_BM1368_REGISTER_WRITE_135"]
    if args.sanitize:
        flags += ["-fsanitize=address,undefined","-fno-omit-frame-pointer","-fno-pie","-no-pie"]
    env=dict(os.environ,ASAN_OPTIONS="detect_leaks=0:halt_on_error=1",
             UBSAN_OPTIONS="halt_on_error=1:print_stacktrace=1")
    try:
        version=run([args.cc,"--version"],10,env,report["commands"])
        if version.returncode: raise RuntimeError("compiler unavailable")
        exe=out/"host-test"
        sources=[ROOT/x for x in SOURCES]
        built=run([args.cc,*flags,*sources,"-o",exe],45,env,report["commands"])
        if built.returncode: raise RuntimeError("positive build failed")
        positive=run([exe],20,env,report["commands"])
        match=re.fullmatch(r"GROUP_BOUNDARY_PASS cases=(\d+) checks=(\d+) hardware=no\n",positive.stdout)
        if positive.returncode or not match: raise RuntimeError("positive test failed")
        report["cases"]=int(match[1]);report["checks"]=int(match[2])
        report["executable_sha256"]=digest(exe)
        if args.mutants:
            for number,(source_idx,name,before,after) in enumerate(CONTROLS):
                content=(ROOT/SOURCES[source_idx]).read_text()
                if content.count(before)!=1: raise RuntimeError("non-unique control: "+name)
                changed=out/(name+".c");changed.write_text(content.replace(before,after))
                selected=list(sources);selected[source_idx]=changed
                target=out/("control-"+str(number))
                row={"name":name,"source":SOURCES[source_idx],"commands":[]}
                report["controls"].append(row)
                built=run([args.cc,*flags,*selected,"-o",target],45,env,row["commands"])
                if built.returncode: raise RuntimeError("control build failed: "+name)
                result=run([target],20,env,row["commands"])
                if result.returncode!=1 or "GROUP_BOUNDARY_ASSERT" not in result.stderr:
                    raise RuntimeError("control not detected by assertion: "+name)
                row["result"]="assertion_detected"
                # Record proof, not dozens of duplicate executables in the archive.
                row["executable_sha256"]=digest(target);target.unlink()
        if report["source_sha256"]!={x:digest(ROOT/x) for x in SOURCES+HEADERS}:
            raise RuntimeError("tracked inputs changed during tests")
        report["result"]="passed"
        print("GROUP_BOUNDARY_RUN_PASS cases=%s checks=%s controls=%s sanitize=%s" %
              (report["cases"],report["checks"],len(report["controls"]),args.sanitize))
    except BaseException as error:
        report["result"]="failed";report["error"]=repr(error)
        raise
    finally:
        (out/"report.json").write_text(json.dumps(report,indent=2)+"\n")

if __name__=="__main__":
    main()

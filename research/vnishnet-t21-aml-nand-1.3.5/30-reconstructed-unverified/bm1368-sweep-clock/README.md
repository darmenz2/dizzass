# Original BM1368 SWEEP_CLOCK_CTRL method

This reconstructs cgminer `e32c0` / hwscan `f30d4` in the observed
`libbitmain/src/chip/chip1368.c` module under
`VN135_BM1368_SWEEP_CLOCK_135`. The accepted 8,350-byte source prefix is
unchanged; the new method is an 895-byte append.

The method ignores its second incoming argument (r1) and writes
`0x80008b00 | ((third_argument & 3) << 1)`. It calls the actual existing BM1368
register writer once with the original device, mode 1, NULL chip and register
`0x3c`. Writer zero returns zero. Failure reads the device index after the
writer returns, increments modulo 2^32, emits the line-463 diagnostic and
returns -1. Failure may follow packet dispatch. There is no wrapper retry,
wait, second write, cache read or rollback.

The existing BM1398 sweep helper has a different fixed word and bit positions;
it is not equivalent. The existing BM1368 pulse-width method also targets
register `0x3c`, with a different word and diagnostic sequence. Both remain
unchanged. Actual cache, encoder/CRC, dispatcher, AML and UART projections are
reused through the writer; the test also uses the real pulse and ticket methods.

## Original startup boundary

The independent [static contract](STATIC_CONTRACT.md) binds the accepted L11
caller proof and extends its concrete cgminer startup route. Constructor slot
`+0x70` becomes cached backend B0's `+0x180` slot. The coordinator captures the
enabling flag from model byte `M+0x80` at entry, then tests bit 0 later. At
`56034` it freshly reads `M+0xa4` into the argument this method ignores and
passes zero as the active third argument, requesting exactly `0x80008b00`.
The model-word read still occurs in the original caller and requires valid
storage even though this particular method ignores its value.

The owner identity is cached; the method slot is read at call time. Earlier
callbacks and live-object/selection preconditions remain explicit. A later
optional pulse-width call at `5620c` can overwrite the same register before
the final ticket call at `562c4`. Successful sweep therefore does not prove
final register-value persistence. The full coordinator, native ABI binding,
physical readiness and a corresponding hwscan startup caller remain outside
this reconstruction. Numeric constructor entries are still noncallable identities.

## Reproduction and validation

From this directory, with a C11 compiler and Python standard library:

    make test sanitize

Optional complete-original byte comparison, from the repository root:

    python3 research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/bm1368-sweep-clock/verify_evidence.py --cgminer reference/cgminer.vendor.elf

The optional `--hwscan PATH` reads the independently pinned private ELF as data.
The public verifier hashes bounded witnesses and reviewed operand/branch facts;
it does not execute instructions or automatically prove C equivalence. The
cgminer and hwscan bodies differ: the ordinary cgminer path requires the
reviewed even-product simplification. Code and literal pools remain separate.

The focused host fixture passed GCC ordinary and all-TU ASan/UBSan with
25 method invocations / 2,418 checks. It uses a four-word literal oracle,
selected high-bit and ignored-argument cases, failures, callback index mutation
and wrap, one bounded recorded replay, and a carried-cache sweep → pulse →
ticket subsequence. That sequence contains real selected methods and no
successful stand-ins for missing coordinator callbacks. The linker observer
forwards to the actual writer unchanged. Terminal callbacks record/refuse
bounded frames using caller-owned valid storage; no OS/device operation occurs.

Seventeen compiled semantic controls must fail through the named fixture
assertion; compile errors, signals and timeouts do not count. The initial
unused-parameter error in one mutant was corrected before the passing run.
`validation.json` records completed checks, regressions and limits. All eleven
linked TUs receive both sanitizers; leak detection is disabled and the existing
CRC-only sign-conversion warning exception is retained. Local Clang/full native
build and live CI are separate from this local host snapshot.

The real writer normalizes its results to 0/-1. A positive-short terminal UART
result is tested through that writer; no positive writer result is fabricated.
The original's treatment of arbitrary nonzero writer statuses is a static
branch fact. Callback identities are stable and synchronous, while valid mutable
device fields may change; the diagnostic pointer is borrowed only during emit.

`source-baseline.json` records accepted provenance, not a waiver for changed
current sources. Exact current-source transitions and the complete tenth A13
state are reviewed separately. Older proof/validation receipts and both earlier
fixed-span control generators remain historical and unchanged. No original
process/interpreter, physical I/O, real wait or model/OOM probe is included.

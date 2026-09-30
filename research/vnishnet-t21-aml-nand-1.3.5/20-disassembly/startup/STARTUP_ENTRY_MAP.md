# ELF startup entry map

These are static references in two separately hashed ELF files, not observations from running firmware. Both are ELF32 little-endian ARM EABI5 hard-float executables. Neither has a symbol table or `$a`/`$t`/`$d` mapping symbols. Names below describe research roles, not recovered vendor symbols.

## Direct byte and metadata evidence

| Item | cgminer | hwscan |
|---|---|---|
| Source SHA-256 | b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9 | 951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077 |
| ELF entry | 0x1012c | 0x158b8 |
| Entry code window | [0x1012c,0x1014c) | [0x158b8,0x158d8) |
| Entry direct A32 BL | 0x10148 -> 0x10150 | 0x158d4 -> 0x158dc |
| Bridge code window | [0x10150,0x101a4) | [0x158dc,0x15930) |
| Bridge direct A32 BL | 0x10198 -> 0x5930b8 | 0x15924 -> 0x452350 |
| Bridge literal words | [0x101a4,0x101b4) | [0x15930,0x15940) |
| GOT base expression | 0x10164 + 0x5ce490 = 0x5de5f4 | 0x158f0 + 0x499c7c = 0x4af56c |
| init slot / pointer | 0x5dff8c -> 0x100f4 | 0x4aff94 -> 0x100f4 |
| main-candidate slot / pointer | 0x5dff78 -> 0x3720c | 0x4afc68 -> 0x25428 |
| fini slot / pointer | 0x5dea9c -> 0x5b025c | 0x4af7b4 -> 0x46e5c8 |
| Main-candidate prefix rendered | [0x3720c,0x3730c) | [0x25428,0x25528) |

The PC-relative loads and GOT values are independently visible in the code/data `.asm` files and hash receipts. The three slots are four-byte little-endian words within the writable ELF load mapping. The init/fini pointers match their ELF section start addresses. At the bridge call, the listed main-candidate pointer is supplied in `r0`, an initial-stack word in `r1`, initial-stack-plus-four in `r2`, the init pointer in `r3`, and the fini pointer as a stack argument. Calling the `r0` target “main” is an inference from this startup shape; the receiving routines have not been named from symbols or completely analyzed. No complete bridge-callee-to-main control-flow proof is claimed.

Both main-candidate pointers are also EHABI unwind-range starts with the ARM bit encoding. Prefixes are intentionally bounded at 256 bytes. Branches, literal references and callees leaving those prefixes remain unresolved here. These windows cannot establish that the scanner is passive, enumerate its complete device accesses, or prove a safe path through cgminer initialization.

## Literals are not instructions

The entry's load references its immediately following word: cgminer 0x10134 references 0x1014c; hwscan 0x158c0 references 0x158d8. The bridge contains four analogous PC-relative literal references. These words are emitted as `.word` data in separate artifacts, rather than plausible-looking A32 instructions. The selected UART-open interval similarly separates the code listing through the return at 0x10e4a4 from the following 112-byte literal interval [0x10e4a8,0x10e518).

Other GPIO/PSU/reset windows retain the exact boundaries of earlier repository evidence and may contain embedded literals. Their linear decoding is explicitly a candidate interpretation. No mapping symbols survive to classify every interior byte. The plan's mode evidence applies at the start and to reviewed instruction references; it is not a statement that an entire EHABI interval has one mode or is all code.

## Initialization arrays and scope gap

`cgminer-index/init-arrays.tsv` records 185 `.init_array` pointers and one `.fini_array` pointer. `hwscan-index/init-arrays.tsv` records 48 `.init_array` pointers and one `.fini_array` pointer. Each row retains its slot, raw pointer and normalized address/mode. These are loader metadata, not a proved startup schedule or an assertion that each target is hardware-free. The referenced initialization routines are not exhaustively disassembled in this change.

See [STARTUP_SAFETY_MAP.md](STARTUP_SAFETY_MAP.md) for the exact selected shell stages, GPIO/PWM/PSU/UART cautions and unresolved prerequisites. Script ordering is direct evidence; the complete sequence through binary hardware initialization remains an open static-analysis task. Unknown paths remain unsupported.

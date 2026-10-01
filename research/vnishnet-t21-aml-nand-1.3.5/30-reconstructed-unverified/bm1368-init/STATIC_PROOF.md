# Complete bounded constructor proof

cgminer source: 6,228,004 bytes, SHA256
`b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9`.
hwscan source: 4,883,216 bytes, SHA256
`951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077`.
Both are little-endian ARM32 ET_EXEC images, read as data only.

| Source | Code, half-open | Literal pool, half-open | L07 selector-4 edge |
|---|---|---|---|
| cgminer | e1450..e16b8 | e16b8..e1790 | d23c8 → e1450 |
| hwscan | f1d28..f1f90 | f1f90..f2068 | ea79c → f1d28 |

Each complete body is 616 bytes / 154 aligned A32 instructions. The code bytes
are identical, SHA256
`d1e526e4c773e51a22151a4082d3800142244982a9f7bfbc15ede6081b21559f`.
The following 216-byte pools contain 54 literals each and are data. Every literal
is used once. cgminer's unwind entries independently bracket e1450..e1790.
The bounded L07 tail edges and identical body support hwscan's boundary; this
does not assert whole-program reachability or physical chip identification.

## All operations

The exhaustive body contains: 1 push, 7 adds, 108 loads, 29 single-word stores,
6 increment-after multiple stores, 1 increment-before multiple store, 1 move
and 1 pop. Every instruction is unconditional. There are no calls, conditional
branches, loops, system calls, barriers or flag-setting operations.

An adjacent load pair resolves each identity using:

    literal_address = literal_load_pc + 8 + immediate
    got_address = (got_load_pc + 8 + literal_word) mod 2^32
    identity = uint32 little-endian word at got_address

The 54 GOT cells are distinct and their pinned values are distinct aligned
addresses in .text. `evidence/constructor-proof.json` records every load PC,
literal value, GOT cell/raw bytes, destination offset, store PC and store order
for both images. The checked-in code and data windows plus GOT cells account
for 1,048 bytes per source, 2,096 total; the complete original images remain
separate inputs.

The first output write is +dc, followed by ascending words in these groups:
+bc..+d8, +9c..+b8, +7c..+98, +5c..+78, +3c..+58, +1c..+38, +04..+14.
Thus the required extent is 0xe0 bytes / 56 words, with exactly 54 assignments.
+00 and +18 have no direct stores. The multiple-store mapping uses increasing
register numbers and output addresses; it is not a claim about bus transaction
order within one instruction. Previous output values are never read.

Input r0 is the output base. Incoming r1-r3 and stack arguments are unused.
The prologue saves r4/r5/r6/r10/r11/lr in a 24-byte stack frame. The epilogue
restores those saved registers and SP, sets r0 to zero, and returns through the
saved LR. Stack layout and scratch-register effects are not part of the C
projection. The chosen int32_t result type represents the sole observed zero;
machine code does not recover the original C declaration or method typedefs.

## Independent positional cross-checks

| Output offset | cgminer identity | hwscan identity |
|---|---|---|
| +8c | e3bbc | f3608 |
| +c0 | e49c4 | f3d3c |
| +c4 | e49cc | f3d44 |
| +c8 | e49d4 | f3d4c |
| +cc | e49dc | f3d54 |

The +8c identity agrees with existing A06 reply-key evidence. The four later
positions agree with existing thermal-table evidence. Their complete signatures
are not inferred from position or names. Existing nonce functions correspond to
the identities at +a8 and +ac, but this constructor does not bind or call them.

## Observable domain

The original instructions read current GOT contents interleaved with stores;
the new C writes pinned cgminer identity constants. Both GOT regions fall in
PT_GNU_RELRO, but static ELF metadata does not prove runtime enforcement or
absence of mutations. Fixed identities therefore require stable pinned code,
literals and GOT; ordinary writable output RAM; a valid aligned stack; and no
output overlap with GOT/code/literals or the active save frame. Overlap can
change later reads or corrupt the return, including the preserved-hole claim.

No routine validates the output size, pointer, alignment or permissions. These
are valid-call preconditions, not new error returns. Faults may leave a partial
table; no fault or signal equivalence is claimed. External serialization must
exclude concurrent observers/writers, and the new function is not atomic.
Relocated or dynamically replaced method values are outside this fixed snapshot.

Only the pure initializer shell is reconstructed. Method bodies, signatures,
typed linking, model selection, command transport, hardware admission and native
driver integration remain separate. The existing d253c packet/CRC encoder
prefix is reusable work, not newly implemented by this constructor.

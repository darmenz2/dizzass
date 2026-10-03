# Group-end caller static contract

## Boundaries and source attribution

The function's code is `[0xb58e4,0xb5a44)`. It begins with its own PUSH/prologue and has complete returns at `0xb5a30..0xb5a38` and `0xb5a38..0xb5a44`. The two literal words occupy `[0xb5a44,0xb5a4c)`. The next function has a new prologue at `0xb5a4c`. The preceding function returns before its separate literals at `0xb58dc..0xb58e4`.

EHABI does not independently identify this function: the unwind entry at `0x5c8b1c` covers a range beginning `0xb5568`; the next entry at `0x5c8b24` begins `0xb5a4c`. Consequently the unwind range `[0xb5568,0xb5a4c)` must not be presented as the extent or identity of `0xb58e4`.

The grouping body contains no source-path, function-name, format-string, or logging reference. The coordinator's actual failure diagnostic directly names `/tmp/build/src/backend/chain.c`, module `driver`, function string `[redacted]`, line 716. These are witnessed facts about the coordinator, not direct source attribution of `0xb58e4`.

The nearby separately registered initializer `0xb5ad4` decodes module `driver` and `/tmp/build/src/backend/driver.c`. Both complete decode loops and ciphertext are supplied. That is supporting address-cluster evidence for a driver.c attribution, but is not a definitive compilation-unit proof for the logging-free grouping function. The binary is stripped of symbol and DWARF sections; adjacency, common conventions, and EHABI grouping alone cannot establish an exact source owner. Keep the original grouping identity explicit if choosing an implementation module. Do not rewrite its provenance as positively proved chain.c or driver.c on this packet alone.

## Original objects and access timing

Let `C` be incoming r0, `M` the model pointer read from the entry owner, `V` the board view, `B` the owner captured after enable evaluation, and `D=C+0x2b8`. These are original object identities, not proposed host layouts.

1. `b58f0` retains C. `b58f4` loads `[C+0x1c]`, then `b58f8` loads that owner's word `+0x18` into M.
2. `b58fc` calls the complete pure accessor `a720c..a7218`: it returns M+0x38 when M is nonzero, otherwise zero. No callbacks or storage writes occur in the accessor. The following caller load still requires a readable board view; this is not null acceptance by the caller.
3. `b5900` reads the entire unsigned byte `[V+0x3c]`. `b5904` retains V in r5. `b5908` sets result zero and `b5910` returns if the byte equals zero. This is whole-byte nonzero enable semantics, not bit0 enable semantics.
4. On the enabled path, `b5940` reads count `[V+0x18]` once into r4, and `b5944` separately captures B=`[C+0x1c]` into r8. `b595c` forms D arithmetically and retains it in r6.
5. `b5964/b5968` uses signed `count>=1`. Thus counts whose 32-bit signed value is nonpositive produce no calls and return zero.
6. Each reached iteration reads `[V+0x14]` at `b59a8`, multiplies it by the retained current group r4, subtracts one, and writes the descriptor's index at `b59b4`.
7. `b59b8` rereads `[V+0]`; `b59bc` calls the pure multiply function `53d98..53da0` with index and that word. `b59c0` writes the resulting address into the descriptor.
8. `b59c8` loads the current `[B+0x194]` method pointer. `b59d0` reads the current unsigned byte `[V+0x40]`. `b59d4` invokes the method as `(D, descriptor, value_byte)`.
9. After a returning callback, the opaque predicate is read without modifying the callback's r0. At `b5970` the retained group is decremented; `b5978/b597c` first checks the callback status and returns -1 for every nonzero status. For zero status, `b5980/b5984` continues only if the decremented group is still at least one. The final successful call is followed by zero return.

The `sb=-count` computation at `b5960` and `sb++` at `b5974` have no consumer in this complete function. They do not create a second loop limit or change a callback argument.

### Mutation observations

| Item | Capture/reload behavior | Effect of a returning callback changing it |
|---|---|---|
| C's owner pointer | Read to obtain M; captured separately as B before the loop | Replacement after a callback does not retarget B or V |
| Owner's model pointer | Read only when obtaining V on entry | Replacement after a callback does not retarget V |
| Board V identity | Retained once | Retained view must remain alive |
| Enable V.byte3c | Read once before count capture | Later changes do not stop or start this invocation |
| Group count V.word18 | Captured once, signed | Later changes do not change this invocation's iteration count |
| Group size V.word14 | Read for every descriptor | Next iteration sees a changed value |
| Address multiplier V.word0 | Read for every descriptor | Next iteration sees a changed value |
| B.slot194 | Reloaded before every callback | Next iteration sees a changed slot in retained B |
| Parameter V.byte40 | Reloaded before every callback | Next iteration sees the changed byte |
| Descriptor words | Rewritten before every callback; never reread afterward by this caller | Callback changes do not carry into the next descriptor |
| C.word18 diagnostic index | Not read by grouping | Coordinator reads it later if grouping fails |

There is no external callback between the initial owner/model/accessor sequence and B capture. In the ordinary synchronous domain without asynchronous mutation these two owner observations coincide, but preserving both observations avoids making a stronger assumption in a typed projection.

## Exact skip-path access requirements

Disabled (`V.byte3c==0`): C's owner pointer, that owner's model pointer, the pure accessor, and V.byte3c are accessed. No group count is read; no second owner is captured; D is not formed; no opaque-global pointer/value, method slot, descriptor, group size, multiplier, or parameter is accessed. No callback occurs.

Enabled but signed count nonpositive: the above reads occur, then the routine resolves opaque-x/y GOT pointers, reads opaque-x storage, reads V.word18, captures B from C.owner, and forms D arithmetically. On the ordinary even-product path it never reads the opaque-y pointee. It does not dereference B, D, or a method slot, construct a descriptor, read V.word14/V.word0/V.byte40, or call a method. It returns zero.

Thus neither skip path needs readable device storage or a callable method slot. The enabled/count-nonpositive path still performs the explicit owner capture and D address calculation. Any host adapter must distinguish those accesses from a fabricated validation or callback requirement.

## Arithmetic, temporary descriptor, and valid domain

For a retained positive signed group g, the exact ARM calculations are:

```
index   = low32(low32(V.word14 * g) - 1)
address = low32(index * V.word0)
```

Both multiplications retain only the low 32 bits; subtraction wraps modulo 2^32. Index `0xffffffff` is therefore possible (for example, a zero current group-size word). The code has no clamp, range check, or special-case rejection. A faithful host implementation must use defined unsigned arithmetic rather than introduce signed overflow. The group itself starts in `[1,INT32_MAX]` and decreases by one to zero, so its ordinary loop arithmetic does not wrap. Changes to V.word18 cannot extend the loop.

After saving nine registers (36 bytes), the function reserves 12 additional stack bytes. The callback's descriptor pointer is `sp+4`; only words at `sp+4` and `sp+8` are initialized, containing index and address. The word at `sp+0` is not initialized or used by this function. Saved registers start at `sp+12`. The evidence therefore supports an eight-byte two-word projection and no zeroed padding, extra metadata, 0x60-byte chip allocation, or address into C's chip array.

The descriptor uses the same temporary stack address for each callback and lasts only through the invocation. Both words are assigned before every callback, and the caller does not read the descriptor after callback return. Synchronous callbacks may read or mutate both valid temporary fields during the call; both fields are overwritten before the next iteration's callback. They must not retain it for later use or read a larger fabricated chip layout. A typed host descriptor can preserve semantic fields and temporary lifetime without claiming original stack identity or layout for a native cgminer chip object.

Valid-call requirements remain explicit: readable reached C/owner/model/view and ordinary opaque storage, live retained B/V for every reached callback, a callable current slot when reached, returning synchronous callbacks, and a D value valid for the selected callee when called. No null/malformed-pointer behavior, raw adjacent-stack observation, asynchronous lifetime change, or hardware acceptance is established. The original's arithmetic does not prove that every possible wrapped descriptor is semantically accepted by the chip-cache callee.

## Opaque branches and all returns

The code reads x through GOT `5dec68 -> 68be14`, with its literal at `b5a44`; y's pointer comes through `5df01c -> 68be20`, literal at `b5a48`. The full complete body is retained, including the duplicated call block at `b59f8..b5a2c`.

Every such branch computes `low32(x*(x-1)) & 1`. For every 32-bit x this is zero, including multiplication and subtraction wrap. Each product uses one loaded x and its immediately derived x-1, so a callback changing x does not invalidate that arithmetic fact. Under ordinary readable storage the duplicate block and corresponding repeat edges are unreachable. This is direct algebra over the witnessed instructions, not an executed model. The y value does not select ordinary control flow.

All ordinary status outcomes are covered:

- Disabled: zero
- Enabled, signed count<=0: zero
- Enabled, positive count, all reached callback statuses exactly zero: zero
- First nonzero callback status, including a positive one: -1, with no subsequent method call

The routine has no other external call besides the accessor, multiply helper, and method callback. It has no internal logger initialization/call, delay, retry, cache operation, state write beyond the temporary stack words, rollback, or device read. Callee-internal effects remain the selected method's separate contract.

## BM1368 method identity and hwscan limit

The supplied constructor proof, hashed as a dependency, assigns output slot +0x84 to cgminer `e3728` and hwscan `f33ec`. The selected original load/literal/GOT/store bytes for both are included. Under the accepted backend output base B+0x110, the actual grouping slot B+0x194 is that output slot. This depends on the accepted backend binding; a generic arbitrary B need not select BM1368.

No hwscan grouping caller homolog is established. A reproducible `.text` scan for positive, pre-indexed, non-writeback ARM LDR word offset 0x194 with non-PC/non-SP base finds cgminer `3c920`, `b59c8`, `b5a18`, and hwscan `2f0d88`. The hwscan context copies two words at +0x190/+0x194 into an output buffer; it does not call that loaded value in the witnessed context. This scan is an exploratory candidate filter and cannot prove absence of a homolog, different layout, indirect call, Thumb implementation, or differently encoded address calculation. Do not invent a hwscan caller address by subtracting a binary offset.

## Coordinator call, failure, and logger strings

The accepted map supplies the broader route and coordinator identity `55774`; this packet verifies its incoming C capture and the bounded grouping stage. In the ordinary path:

1. `564d0/564d4` requests delay `10ef3c(10)`. Its return is ignored.
2. `564d8/564dc` invokes `b58e4(C)`. The coordinator imposes no new enable gate; the helper evaluates its own current owner/model/view.
3. `56524/56528` tests helper status exactly against zero. Zero continues at `56554`, where the next retained entry flag controls the following stage.
4. For nonzero status, `56530..56550` selects the error format at `5e4649`. The even-product condition makes `56604` the ordinary error block. `56678..566c4` is retained as an unreachable duplicate under the same arithmetic premise.
5. `56604..56638` calls logger `fa0c4` with module=`5e4260` ("driver"), source=`5e4267` ("/tmp/build/src/backend/chain.c"), function=`5e4286` ("[redacted]"), line=`0x2cc` (716), severity/flag stack word `1`, format=`5e4649` ("chain#%d - failed to config drive strength per domain"), and late `low32(C.word18+1)` as its format argument. The descriptor's group index is not used for that coordinator diagnostic.
6. Logger return is ignored. `5663c..56648` then invokes `56d18(C,"Failed to set initial settings")`; its return is ignored. The accepted `vn135_chain_stop_135` is a real behavior boundary, not merely string recording.
7. `56650` sets r6 to -1; the ordinary edge reaches `55f00..55f0c`, which returns r6. The failure does not continue to the next group-register stage.

The following exact static initializer derivations support the strings rather than reading ciphertext as if it were plaintext:

| Registered initializer | Target | Length | XOR | Result |
|---|---:|---:|---:|---|
| 5b1dc, init-array word5daf90 | 5e4260 | 7 | a1 | driver |
| same | 5e4267 | 31 | b7 | /tmp/build/src/backend/chain.c |
| same | 5e4286 | 11 | 2f | [redacted] |
| same | 5e4595 | 31 | 6e | Failed to set initial settings |
| same | 5e4649 | 54 | ee | chain#%d - failed to config drive strength per domain |
| b5ad4, init-array word5dafb4 | 5e9038 | 7 | 49 | driver |
| same | 5e903f | 32 | d0 | /tmp/build/src/backend/driver.c |

Lengths include NUL. Literal addressing uses ARM PC+8. The initializer registration and transformations are proved as file facts; no initializer was run, and this packet does not claim a fresh proof of global runtime startup completion or logger `fa0c4` internals. There is no lazy string initialization in the grouping helper or its bounded coordinator error path.

## Integration limits

This packet does not implement a full startup coordinator, establish the source unit of the logging-free helper beyond the qualified evidence above, supply hwscan caller behavior, prove controller/device lifetime, bind production transport, validate replies or ACKs, or make a successful host callback into hardware acceptance. Numeric original method identities remain evidence labels. The current accepted 32-slot/no-safe-reuse limit is unaffected.

# Register-0x58 wrapper static contract

## Complete code and literal boundaries

All ends below are exclusive.

| Original/method | Code | Code bytes | Literal pool | Pool bytes |
| --- | --- | ---: | --- | ---: |
| cgminer chip | e3728..e39dc | 692 | e39dc..e3a1c | 64 |
| cgminer common | e3a1c..e3b88 | 364 | e3b88..e3bbc | 52 |
| hwscan chip | f33ec..f34dc | 240 | f34dc..f34fc | 32 |
| hwscan common | f34fc..f35e8 | 236 | f35e8..f3608 | 32 |

Code hashes in that order are `ab79cf5615e41cef3bc606d43ce2c968eac107d2cd9fcd6d3f7a91d36641e7c0`, `00a27102185f70ad1daf4b4cd6563a452f66f82d05dc00f3c16077fed104f66d`, `87406b9d1f21eb417d04ea324ec294966bc2d5d3a8d4f7678167024538fbb9b7`, and `ecafb850f8afa258e94b955b9d659748d40256e2a96901ca2d199520e837b41b`.

The preceding routines return at e36f8/f33d8. Each selected wrapper starts with its own PUSH and frame setup; internal immediate branches remain inside its code span, calls target only the listed cache getter/writer/logger, and the body ends in POP-PC at e39d8/e3b84/f34d8/f35e4. Every pool cell has an explicit PC-relative LDR reference from that body. There is no fall-through edge into a pool. Following common methods start at e3bbc/f3608 (`MOV r0,#0x44; BX lr`). These are control/data boundaries, not unwind coverage extents.

## Constructor association

Both constructors load chip into r4 and common into r5, then perform `ADD r2,r0,#0x80; STM r2,{r1,r4,r5,r6}`. ARM stores registers in ascending register-number order, giving +80=r1, **+84=r4**, **+88=r5**, +8c=r6. No instruction between these two loads and STM overwrites r4 or r5.

| Method | cgminer load → literal → GOT → pointer | Final store |
| --- | --- | --- |
| chip +84 | e1540/e1544 → e1710=`004fded0` → 5df41c=`e3728` | e155c/e1560 |
| common +88 | e1538/e153c → e170c=`004fdde0` → 5df324=`e3a1c` | e155c/e1560 |
| hwscan chip +84 | f1e18/f1e1c → f1fe8=`003bdb60` → 4af984=`f33ec` | f1e34/f1e38 |
| hwscan common +88 | f1e10/f1e14 → f1fe4=`003be008` → 4afe24=`f34fc` | f1e34/f1e38 |

For example, e1544+8+004fded0=5df41c. With the already accepted BM1368 output base B+110, constructor offsets +84/+88 are owner/backend offsets **+194/+198**. Numeric identities are not callable host addresses and do not establish an immutable runtime method table.

## Cache reads, saved input, and exact transform

Raw original signatures have no explicit cache parameter: their cache is a singleton. The authored API's caller-owned cache context is an existing explicit projection.

| Method | Original reached read | Register arguments |
| --- | --- | --- |
| cgminer common | e3a44 → 107188 | r0=device.word18, r1=58, r2=&value |
| hwscan common | f3524 → 10564c | same |
| cgminer chip | e3794 → 1079f0 | r0=device.word18, r1=chip.word0, r2=58, r3=&value |
| hwscan chip | f341c → 105a20 | same |

Each local output word is explicitly initialized to zero before the read. Cgminer common stores zero at e3a30; cgminer chip stores zero at e3784; hwscan stores at f3510/f3400. Thus a returning zero-status callback that does not write the output leaves zero; no uninitialized word needs to be invented. Cgminer chip reserves an aligned eight-byte temporary area but uses one four-byte value; compiler stack padding is not a new semantic field.

The complete incoming setting is retained before the cache call: cgminer common r6 at e3a3c, chip r6 at e3740; hwscan common r6 at f351c, chip r7 at f3414. The bit mask is applied after a successful read, but callback mutation of external storage cannot replace this already passed, saved value.

On exact-zero read status the transform is:

```c
value = (value & UINT32_C(0xffff0fff)) | ((setting & UINT32_C(15)) << 12);
```

Cgminer chip instructions are e3814..e3824; common e3a8c..e3aa8. Hwscan uses the same AND/BIC/ORR sequence at f345c..f3474 and f3564..f3580. Input upper bits and sign interpretation are irrelevant. All other cache bits remain unchanged. There is no shift by a variable amount, overflow exception, range check, clamp or setting-to-enum conversion.

The chain index and chip cache index loaded before the cache read are only that read's arguments. The wrappers do not save those numeric values for the later writer or failure diagnostic. Original getters interpret index words as signed for bounds validation; a host adapter should preserve the original 32-bit word when converting to the existing signed index type.

## Live object identity and write/read/log timing

On successful read:

- Common at e3ab8/f3590 invokes e4a74/f3d7c with r0=the original device pointer, r1=1, r2=NULL, r3=58, and fifth AAPCS word at [sp]=the transformed value
- Chip at e3844/f3484 invokes the same writer with r0=the original device pointer, r1=0, r2=the original chip pointer, r3=58, and [sp]=the transformed value

The setting and transformed word are retained values. Device and chip are retained **identities**, not copies of their fields. A cache callback can mutate the live device index or chip wire/cache values; the later writer observes them at the writer's established times. In particular its wire-address read is before its send, and its device/cache-index reads are after successful send. Its accepted send-before-cache behavior and diagnostic differences remain intact. Replacing a variable that once held the passed object pointer does not replace the already passed object identity.

On **every nonzero cache status**, including positive statuses, the wrapper emits its cache-read diagnostic and returns -1. It makes no register-writer call. The failure diagnostic has **no device index or chip index variadic field**; it does not reload those values just to log.

On **exact-zero writer status**, the wrapper returns zero and emits no wrapper diagnostic. On every nonzero writer status it reads device.word18 **after the writer returns** (e391c/e3ad4/f34a4/f35ac), adds one with 32-bit wrap, emits the write-failure diagnostic, ignores the logger return and returns -1. The format uses `%d`; the witness preserves the raw one-based word, including its signed rendering for high-bit values. Neither wrapper logs a chip index.

The full writer may already have sent before it reports cache failure, so wrapper -1 does not imply nothing was dispatched. Cache/getter/writer diagnostics can precede a wrapper diagnostic. The proof says one reached cache call, at most one reached writer call and one wrapper diagnostic on failure; it does not say there is at most one event inside the reused dependencies. There is no wrapper retry, wait, rollback, cache preflight, ACK or separate second write.

## Opaque predicates and cross-ELF method match

Cgminer includes dead duplicate cache/log paths. Their gates use one loaded 32-bit x, then `x*(x-1)` modulo 2^32 and test bit0. An integer and its predecessor have opposite parity, so this bit is always zero. Wrap at x=0 does not change that result. Reads after a callback may obtain another x; the same identity applies to that independently loaded x.

Thus the ordinary cgminer chip route takes e3760→e3770 and e37a8→e37e0, never e37b8's duplicate read. Read failure takes e3800→e3880, and then e38c4→e39b0. Write failure takes e386c→e3908, and then e395c→e39b0. The final e39c0→e39d0 returns. Common read failure takes e3a78→e3b04 then e3b40→e3b7c, never the duplicate e3b50 block. Hwscan is the corresponding straightforward flow. The complete methods agree on arguments, saved-setting timing, zero-output initialization, transform, status normalization and exact diagnostics. This is stronger than a name/address-offset match, but is confined to ordinary valid synchronous calls and readable opaque storage.

## Exact logger fields and initializer

All four failure kinds pass:

- module: `driver`
- source: `/tmp/build/libbitmain/src/chip/chip1368.c`
- function: `[redacted]` (the literal original string)
- severity: 1

| Failure | Line | Exact format | Additional field |
| --- | ---: | --- | --- |
| chip cache read | 609 / 0x261 | `Failed to read cached drive strength register` | none |
| chip writer | 619 / 0x26b | `chain#%d - failed to config drive strength` | late device.word18+1 |
| common cache read | 635 / 0x27b | `Failed to read cached driver strenght register` | none |
| common writer | 645 / 0x285 | `chain#%d - failed to config drive strength` | late device.word18+1 |

`driver` versus `drive` and `strenght` versus `strength` are original distinctions. Logger ABI: r0=module, r1=source, r2=function, r3=line; [sp]=severity, [sp+4]=format, and only write failures additionally set [sp+8]=index word. The common cgminer calls are e3af8 (writer) and e3b28 (read); chip calls e3940 (writer) and e38a8 (read). Hwscan shares a logger call per method at f34c8/f35d4, selected by preceding path-specific argument setup.

| String | cgminer encoded | hwscan plain | NUL-inclusive bytes | Key | Initializer compare / XOR |
| --- | --- | --- | ---: | --- | --- |
| module | 5eb3e0 | 47d914 | 7 | 1e | e539c / e53cc |
| source | 5eb3e7 | 47e7ef | 42 | d8 | e5460 / e5490 |
| function | 5eb411 | 47d359 | 11 | d1 | e5514 / e5544 |
| chip read format | 5eb515 | 47e627 | 46 | f7 | e57e0 / e5810 |
| shared write format | 5eb543 | 47e655 | 43 | cc | e5864 / e5894 |
| common read format | 5eb56e | 47e680 | 47 | a5 | e5924 / e5918 |

The initializer's own zero counters, PC-relative pointers, byte loads/stores, key immediates, increments, bound comparisons and loop backedges establish the byte transforms directly. Decoded bytes equal each independently plain hwscan string including exactly one terminal NUL. `e5370..e6058` is executable initializer code; `e6058..e60e8` its data pool. An init-array cell at `5dafe4` contains `e5370`. This proves registration, not runtime order or that startup has already initialized strings. Normal initialized diagnostic storage is a precondition of the runtime text contract.

The two wrappers directly reference the source string, establishing their chip1368.c attribution. The grouping helper has separate source-attribution evidence/limits in `GROUPING_CONTRACT.md` and must not inherit the wrapper's source path.

## Reuse and missing implementation

The accepted `libbitmain/src/chip/chip1368.c` already includes the numeric initializer storing e3728/e3a1c. It implements earlier reset, ticket, sweep and address methods, but a targeted search of authored src/libbitmain/integration finds no executable register-58 wrapper or b58e4 reconstruction. Numeric constructor entries are not implementations.

Reuse these exact authored dependencies:

1. `libbitmain/src/reg_cache.c`: `vn135_reg_cache_get_chain` (original107188) and `vn135_reg_cache_get_chip` (original1079f0), through explicit existing caller-owned context. Preserve that API's valid-storage domain and omission of original internal cache diagnostics
2. `libbitmain/src/chip/chip1368-register-write.c`: `vn135_bm1368_write_register_135`, retaining original object pointers, exact modes, reg58 and computed word. Its existing cache setters, send ordering and zero/nonzero semantics remain relevant
3. Existing `vn135_bm1368_frequency_device` and `vn135_chip_reference` typed projections, with named index/cache_index/wire_address fields; do not cast a vendor struct or impose original0x60 chip stride
4. Existing encoder/CRC and transport dispatch reached by the writer. The wrapper does not create a frame encoder, transport or cache implementation
5. The exact wrapper diagnostics can follow earlier reset/address diagnostic-record conventions while retaining separate read-failure formats, line numbers and field-presence semantics

The concrete common coordinator call at5639c and group caller at564dc belong to the already identified coordinator route. This wrapper packet does not independently duplicate its incoming-model/entry-flag provenance or treat a demonstration as the full coordinator. The actual grouping helper is separately proved in the accompanying grouping packet.

## Valid host domain and useful discrimination checks

Use synchronous returning cache/writer/logger callbacks, stable callback-table storage, live reached device/chip objects, readable original-equivalent fields, and output pointers used only during their callback lifetime. Chip mode requires its chip descriptor for the initial cache-index read even if the cache call fails. Common mode needs no chip. Each wrapper initializes its local read output to zero. No pointer-fault/OOM/emulator probes are part of this proof.

Useful host checks should distinguish: both forms and all16 nibbles; upper input bits; preservation of other cached bits; positive/negative read and write failures; read success without output assignment; no writer after failed read; no wrapper log on success; exact failure text/lines/field presence; mutation of live device/chip fields by read/send callbacks; original pointer identity; late index reload and uint32 wrap; send-before-cache composition; and common versus chip cache selection. These are proposed checks, not executed C tests in this static proof.

## Optional common register58 coordinator call

This supplements the frozen wrapper/grouping proof with six selected original-data regions totaling231 bytes. The exact accepted L11 witness supplies25 explicitly checked capture/return words. It does not add a coordinator implementation or change runtime semantics.

At56378/5637c, the coordinator requests `10ef3c(10)` and ignores its return. At56380..56388 it tests bit0 of the byte captured at entry from `M+0x83` (board-view+0x4b) into stack+0x1c. A clear bit continues at563f0 without calling the method. Later mutation of the model flag does not replace that retained byte.

The enabled path loads the previously saved owner B0 from stack+0x14, reads byte[r5+0x14] where the retained r5 is the entry model's chip view M+0x88, and reloads [B0+0x198]. Thus the setting is a late unsigned read of **entry M.byte9c**, whereas the enabling flag was captured at entry. It sets r0 to retained D=C+0x2b8 and calls that loaded method through r2 at5639c. The constructor +88/backend+198 proof identifies the selected BM1368 common wrapper e3a1c. B0's slot is loaded at this call, so a callback may have changed that slot; replacing C.owner or the owner's model does not automatically retarget retained B0/M.

Exact-zero method status branches to563f0. Every nonzero status enters the diagnostic block. It calls loggerfa0c4 at563e0 with module `driver`, source `/tmp/build/src/backend/chain.c`, literal function label `[redacted]`, line697/0x2b9, severity1, and exact format `chain#%d - failed to config drive strength`. The sole format argument is a **late read of C.word18 plus1 modulo2^32** at563bc/563cc. This is C's coordinator index, distinct from D's wrapper index.

The logger return is ignored. The coordinator resolves `Failed to set initial settings`, branches at563ec to the existing shared55ef4 block, calls56d18(C,reason), ignores its return, and returns−1 through55efc..55f08. The existing chain-stop operation is a substantive dependency; this evidence does not replace it with string recording.

The new format is ciphertext at5e45e1, exactly43 bytes including NUL. The registered5b1dc initializer has a zero-based fixed loop at5ba64..5ba90: pointer literal5c460, PC ADD5ba74, XORdd at5ba7c, increment5ba84, compare43 at5ba88, and backedge5ba8c→5ba78. Static decoding yields the exact text above. The existing grouping packet already witnesses the same module/source/function/stop-reason strings and initializer registration5daf90→5b1dc; those need not be duplicated.

The accepted L11 dependency, whose complete file hashes are recorded in the common_caller record in static-witness.json, already covers:

- C/M entry captures and pure view accessors at55784/5578c,557bc..557d0,a71f4..a71fc,a720c..a7214
- The specific common flag load/store at55804/55808
- B0 load/save at55828/55938
- D formation and model-view restoration at55af0/55b8c
- The shared stop/−1 return block at55ef4..55f08

The supplement directly compares every listed dependency word with the pinned original. Public normalization can retain these unchanged L11 dependencies and explicit capture mappings rather than duplicate their graph. The six added regions are complete for the newly claimed call's local flag/argument/status/error path and new format loop. No corresponding hwscan coordinator caller is established.


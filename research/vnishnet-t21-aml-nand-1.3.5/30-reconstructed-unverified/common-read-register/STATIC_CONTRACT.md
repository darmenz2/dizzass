# Common READ_REGISTER wrapper: independent static contract

This review reads the two original ELF images as data. It neither runs them nor
interprets or emulates their instructions. `collect_static_review.py` checks the
full image hashes, extracts fixed ranges with pyelftools, uses Capstone only for
disassembly, evaluates PC-relative address arithmetic, and applies fixed XORs
to string data. No implementation, CI, device, network, or mining operation was
performed. No previous execution-based oracle was used as proof.

## Result

The selected wrappers have the same observable contract on normally returning,
ABI-conforming calls with valid required memory and initialized diagnostic
strings. They construct one five-byte command, calculate CRC5 over the first
four bytes, load the current shared transport method once, and send once. A
zero send result returns zero. Every other 32-bit result invokes the logger
once with the diagnostic below, then returns `0xffffffff` (-1). This is one
logger invocation; the logger's own filtering/output behavior is outside this
wrapper and is not proof that a line reaches a terminal or file.

The diagnostic source path is **`/tmp/build/libbitmain/src/chip/chip.c`**, not
`/tmp/build/libbitmain/src/chip.c`. The format names **GET_STATUS**, although the
existing project's encoder calls this command READ_REGISTER.

## Images, bounds, and evidence limits

| Image | Bytes | SHA-256 |
|---|---:|---|
| cgminer | 6,228,004 | `b2663b3aa753cc14ae9d3b11a14d3d93c74b605a3e433b02101c3c17c69d95e9` |
| hwscan | 4,883,216 | `951208595a4947220160f8a5161303862ff1c72100ba3971d006fd8a73d5b077` |

| Image | ARM body, end exclusive | Instructions | Literal pool, end exclusive |
|---|---|---:|---|
| cgminer | `0xd253c..0xd2684` | 82 | `0xd2684..0xd26ac` (40 bytes) |
| hwscan | `0xea7e4..0xea8a4` | 48 | `0xea8a4..0xea8b8` (20 bytes) |

The body ranges include the prologues and final return instructions, and all
in-body branch targets and all wrapper PC-relative literal loads fit these
bounds. Literal bytes are recorded as `.word`, not counted as code. cgminer's
EHABI entry at `0x5c8e04` covers `0xd253c` up to the next unwind start `0xd26ac`;
this corroborates, but does not alone establish, the code/literal division.
hwscan has no exact EHABI start for this wrapper in the original image, so its
entry/extent is supported by the selected instruction stream, prologue, complete
control flow, return and self-contained literal references, not a symbol-size
claim. Both images are stripped of a usable `.symtab`; a recovered semantic
name is not an original symbol name or a recovered C signature.

`static-witnesses.json` preserves exact bytes, hashes, PC-relative calculations,
GOT cells, strings and initializer registration. Image-specific `.asm` files
preserve complete selected wrapper bodies, literals, CRC bodies and the
cgminer string initializer. These are static witnesses, not test executions.

## Entry inputs and packet

| Entry register | Use |
|---|---|
| r0 | Opaque device identity, preserved in r4 and passed unchanged to send |
| r1 | Only bit zero controls packet bit four |
| r2 | Optional object pointer; if nonzero, a 32-bit word is loaded at byte offset 4 |
| r3 | Only its low byte is stored as the register selector |

The packet is five initialized bytes at local `sp+0x10..sp+0x14`:

1. `0x42 | ((entry_r1 & 1) << 4)`
2. `0x05`
3. `r2 == 0 ? 0 : low8(load32(r2+4))`
4. `low8(entry_r3)`
5. `low8(CRC5(packet, 32 bits))`

`BFI r0,r1,#4,#1` is not a nonzero-to-Boolean conversion: input 2 selects
header `0x42`, input 3 selects `0x52`, and all other bits are ignored. The
address source is a **word load**, followed by byte truncation; the original
requires that four-byte read to be valid, even though only eight bits survive.
The optional-object null case produces address zero without a read. There is
no range rejection for wide broadcast/address/register values in the original.

The CRC calls are cgminer `0xd2584 -> 0xf7f10` and hwscan
`0xea82c -> 0xfcc18`, with r0=packet and r1=32. The bounded helper bodies show
the same bitwise CRC5 recurrence: seed `0x1f`, MSB-first input, polynomial
`0x05`, five-bit state, no final XOR. It reads the packet and has no external
call. cgminer additionally has a parity-dead guard at `0xf7ff8..0xf8024`.
The complete cgminer helper code ends at `0xf8040`, including the `BX lr` at
`0xf803c`; the pool is `0xf8040..0xf8048`. hwscan's helper ends at `0xfcd0c`.

The wrapper has no `0x55,0xaa` preamble. The already-present
`integration/bm1368_control.c` encoder returns a seven-byte framed command;
its normalized READ_REGISTER packet bytes 2..6 are exactly this five-byte
payload. Reuse that encoder and the existing transport seam rather than
implementing another packet encoder. A host integration can normalize bit0
and low bytes before calling the stricter existing encoder. Any admission
checks or encoder-error statuses belong to that host integration, not to the
original wrapper's return contract.

## Current transport selection and send

| Image | Load literal / PC-relative load | GOT cell | File word in GOT | Method read | Call |
|---|---|---|---|---|---|
| cgminer | `0xd2588 / 0xd2590` | `0x5df454` | `0x68bf68` | `[r1+0x18]` at `0xd259c` | `BLX r3` at `0xd25a4` |
| hwscan | `0xea830 / 0xea838` | `0x4afe54` | `0x4e4c94` | `[r1+0x18]` at `0xea844` | `BLX r3` at `0xea84c` |

The GOT points to shared writable storage; the file word is an image address,
not proof of the runtime-selected method. The wrapper reads the current GOT
cell and then the current method at offset `0x18` **after CRC**. It selects the
method once for this call. Its exact send arguments are r0=original device
identity, r1=local five-byte payload pointer, and r2=5. There is no method-null
check, transport retry, platform dispatch, acknowledgement read, cache update,
or wait in the wrapper.

An update to the shared dispatch storage during the callback does not cause a
second selection or send. A later wrapper invocation can observe that update.
An integration must not silently freeze the shared table or selected method at
construction time. `libbitmain/src/transport-dispatch.c` is the existing project
send boundary; its typed fields and context are project API design, not a
claim that a host function-pointer structure has the original ARM layout.

## Complete control flow

| Image | Range / branch | Consequence |
|---|---|---|
| cgminer | `0xd253c..0xd25a8` | Build, CRC, select, send, compare result |
| cgminer | `BEQ 0xd2678` at `0xd25ac` | Zero send result returns r5=0 |
| cgminer | `0xd25b0..0xd25e4` | Load parity state; the parity branch at `0xd25d8` always takes `0xd25e8` |
| cgminer | `0xd25e8..0xd2618` | Load current device index, form arguments, invoke logger once |
| cgminer | `0xd261c..0xd263c` | Set r5=-1; parity branch at `0xd2630` always takes return `0xd2678` |
| cgminer | `0xd2640..0xd2674` | Duplicate logger block and back edge; unreachable under integer parity identity |
| cgminer | `0xd2678..0xd2684` | Return r5 and restore frame/registers |
| hwscan | `0xea7e4..0xea850` | Build, CRC, select, send, compare result |
| hwscan | `BEQ 0xea898` at `0xea854` | Zero send result returns r5=0 |
| hwscan | `0xea858..0xea890` | Load current device index, form arguments, invoke logger once |
| hwscan | `0xea894..0xea8a4` | Set r5=-1, return and restore frame/registers |

The cgminer guards compute `x*(x-1)` modulo 2^32 from a single loaded x per
predicate. Consecutive integers have an even product, including wraparound;
the low bit is always zero. Neither changing x between predicates nor changing
the other guard value defeats this identity. Thus there is no reachable repeat
log path, and the `y>9` branches are unreachable. The guard pointer loads and
x-word reads do still exist in the original on the error path. A mathematical
deobfuscation discards their effects only within the admitted, normally readable
memory model; it does not promise equivalent fault timing on invalid memory.

## Exact diagnostic arguments and mutation order

| Position | Value |
|---|---|
| r0 | `"driver"` |
| r1 | `"/tmp/build/libbitmain/src/chip/chip.c"` |
| r2 | `"[redacted]"` |
| r3 | `0x67` (103) |
| stack+0 | `1` (logging level) |
| stack+4 | `"chain#%d - failed to send GET_STATUS command"` |
| stack+8 | `(load32(device+0x18) + 1) modulo 2^32` |

The direct logger calls are cgminer `0xd2618 -> 0xfa0c4` and hwscan
`0xea890 -> 0xfeeb0`. The cgminer dead duplicate at `0xd2670` has the identical
argument values and target. No send status, address, register, payload pointer,
or broadcast value is an additional diagnostic argument.

The index loads are **after send returns**: cgminer `0xd25fc`, hwscan
`0xea86c`. The callback may therefore change the device index and the diagnostic
must observe the new word. Do not snapshot it before sending. The ARM ADD is
wrapping 32-bit arithmetic; the `%d` argument is interpreted as a signed
32-bit integer. Examples: raw index `0xffffffff` logs 0;
`0x7fffffff` logs -2147483648; `0xfffffffe` logs -1. Implement this with unsigned
addition and an explicit signed representation conversion, not overflowing
signed C arithmetic or a saturation/clamping operation.

The wrapper calls a fixed logger routine; it has no original replaceable
logger-pointer field. Any host logger hook is an explicit boundary. If that
boundary supports changes to its hook/context during send, read its current
state at the error notification, not before send. The logger's own current
verbosity/output state and the contents of the referenced string storage can
also change; this review establishes the wrapper's arguments and invocation,
not an immutable global logging environment. A logger's normal return value
does not alter wrapper -1. If send returns zero, the wrapper does not load the
device index or invoke the logger.

## String initialization witnesses

hwscan contains the four plaintext NUL-terminated strings directly. cgminer
contains encoded writable data and registers initializer `0xd2c0c` in
`.init_array` slot `0x5dafd4`. Relevant initializer body:
`0xd2c0c..0xd2d94`; literal pool `0xd2d94..0xd2db4`; alignment word
`0xd2db4..0xd2db8`. Its loop keys and lengths are independently visible:

| String | cgminer address | Length including NUL | Transform | Key instruction / bound | hwscan address |
|---|---|---:|---|---|---|
| module | `0x5ea1b0` | 7 | XOR `0x3b` | `0xd2c68 / 0xd2c38` | `0x47d914` |
| path | `0x5ea1b7` | 38 | byte NOT (XOR `0xff`) | `0xd2cbc / 0xd2cc8` | `0x47de8d` |
| function | `0x5ea1dd` | 11 | XOR `0xe2` | `0xd2d28 / 0xd2cf8` | `0x47d359` |
| format | `0x5ea1e8` | 45 | XOR `0x1b` | `0xd2d7c / 0xd2d88` | `0x47deb3` |

The module and function loops have the same parity-dead duplicate structure as
the wrapper. Statically applying each displayed transform once to the recorded
data bytes yields the exact hwscan strings, including their NULs. No dynamic
input is needed to derive this result and no initializer was executed. This
does not assert what strings an arbitrary runtime sees if its initializer is
skipped, run twice, interrupted, or its writable storage is altered later. The
wrapper itself performs no lazy decoding or initialization check.

## Aliasing, frame and lifetime limits

* The identity passed to send is the exact entry pointer value, not a copy of
  a device structure and not the optional address object. The optional object
  and device may refer to the same admitted storage; the address is read before
  send, while the index is read after send. Preserve that ordering.
* cgminer pushes 32 bytes and reserves 24 more; hwscan pushes 24 and reserves
  24. Both keep the five-byte packet at local sp+16. The logger's three stack
  arguments occupy local sp+0..11 and do not overlap that packet. Unused frame
  bytes and saved registers are not payload, and the send length is exactly 5.
* The original send receives writable stack-backed bytes, with no constness
  encoded in the ARM ABI. The wrapper does not read the payload after send.
  A host const pointer is a documented boundary restriction; do not claim that
  it proves original payload immutability. The callback can inspect/copy the
  five bytes synchronously. Retaining the pointer after return is outside its
  lifetime; caller ownership does not transfer to the callback.
* An adapter can use a seven-byte encoder buffer and pass bytes 2..6, but its
  host frame geometry is different. Do not promise raw-address aliasing with
  the original stack, saved registers, GOT addresses or original numeric
  pointers. Only admitted C objects/pointers and the stated observable ordering
  are projected. Do not manufacture reads outside the five-byte payload.
* There is no unconditional device-null check in the original. A zero send
  result never dereferences device in this wrapper; a failing send reaches a
  device+0x18 word read. Likewise, nonnull r2 is dereferenced before send. This
  is not authority to fault-probe null, invalid, unaligned or freed pointers.
* Normal-return statements assume send and logger preserve the ARM ABI's
  callee-saved registers and stack. If a callback aborts, throws/unwinds,
  longjmps, never returns, or corrupts that state, the wrapper may not reach the
  subsequent index read, log or return. A C callback model must not invent
  cleanup, logging or success after such a nonlocal exit.

## Scope of the conclusion

This proves a static wrapper contract and exact diagnostic provenance. It does
not prove hardware acceptance, a register reply, a cache value, transport
initialization success, a valid platform binding, runtime string initialization,
thread synchronization or physical safety. It does not claim that the proposed
host API reproduces the original binary ABI. The wrapper itself contains no
cache update, ACK path, response parser, success side effect beyond its one
send invocation, or rollback. Effects inside CRC, transport and logger must be
kept distinct from the wrapper's own effects.

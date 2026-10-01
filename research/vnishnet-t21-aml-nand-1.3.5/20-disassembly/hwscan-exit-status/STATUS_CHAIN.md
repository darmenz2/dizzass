# Bounded status propagation and acceptance implications

## 1. Entry to the outer main

The existing ELF entry is `0x158b8`. Its direct call at `0x158d4` reaches
`0x158dc`. The bridge computes GOT base `0x4af56c` from the word at `0x15930`
and the PC of the add at `0x158e8`. Offset word `0x15938` is `0x6fc`, selecting
GOT cell `0x4afc68`, whose initial file-backed value is `0x25428`. The bridge
passes that pointer in r0 to `0x452350` at `0x15924`.

`0x452350` retains the supplied main pointer in r6 across its setup dependency
`0x4520d8`. At `0x452380`, PC-relative word `0x45238c` resolves target
`0x45231c`; `0x452388: BX r3` enters that stage. The stage preserves the main
pointer, calls the initialization-array dependency `0x4522dc`, sets up argument
registers, then `0x452348: BLX r6` invokes the outer main. Initialization routines
are not exhaustively examined and are not established to be side-effect-free.

## 2. Worker to wrapper to outer main

The outer main initializes r6 to zero at `0x25664`. PC-relative code at
`0x256c0/0x256c8`, with word `0x25958`, selects callback `0x22424`.
`0x256d0` calls `0x1c734`, whose `0x1c738: BLX r0` invokes that callback.

The argument wrapper has two C-worker transfers:

- Empty converted-argument path: `0x225b4` supplies r0=0, `0x225b8` supplies
  r1=4, restores its frame/callee-saved registers and tail-branches from
  `0x225c4` to C worker `0xe6524`. Value 4 is an observed pointer/sentinel
  argument; it is not evidence of four actual arguments or a valid dereference
- Populated-argument path: `0x22630` calls the same worker. At `0x22634` the
  wrapper tests its preserved allocation/capacity value. A nonzero value causes
  `0x2263c` to replace r0 with the storage pointer and `0x22648` to tail-call
  cleanup target `0x452e70`; the alternative at `0x22688..0x2268c` restores the
  frame and returns. No cleanup return-value contract is required for the
  outer-main conclusion, and no wrapper source-level return type is asserted

The worker's direct early error epilogue sets r0=`0xffffffff` at `0xe660c`.
Its shared late cleanup epilogue sets r0=0 at `0xe67a8`. Both restore r6.
The previous dispatch report describes the relevant diagnostics and dependency
failures; this change does not reclassify every worker branch.

When the callback returns normally to outer main, **the next instruction**,
`0x256d4`, overwrites r0. The status register r6 retains zero. A runtime cleanup
branch at `0x256e8` may call another dependency and rejoin via `0x25890`.
The ordinary exit-owner path reaches `0x2571c: MOV r0,r6` and the return at
`0x25724`. Thus the worker's result is not used to select the normal process
status, even when a wrapper path happens to preserve it in r0.

## 3. Outer-main result to Linux termination

Immediately after the indirect main call returns, `0x45234c` calls `0x1589c`
without changing r0. That routine:

1. Stores the status at `[sp+4]` at `0x158a0`
2. Calls `0x4525c0`, `0x45276c` and `0x46c408`
3. Reloads the saved status into r0 at `0x158b0`
4. Calls `0x46409c` at `0x158b4`

The three calls are termination-cleanup dependencies. Their callbacks, effects,
termination, races and error handling are not proved by this bounded report.
The status-to-syscall conclusion is conditional on them returning normally
without corrupting the saved stack slot or taking a different termination path.

At `0x46409c`, the wrapper backs up r0 in r3, loads r7=248 at `0x4640a4` and
issues `SVC #0` at `0x4640a8`. If that returns, the fallback sets r7=1,
restores r0 from r3 and branches back to the same SVC. The
[Linux ARM syscall table, v6.12](https://raw.githubusercontent.com/torvalds/linux/v6.12/arch/arm/tools/syscall.tbl)
assigns 248 to exit_group and 1 to exit. These are observed instructions plus
an ABI interpretation, not an observed kernel result on the user's board.

The register/result interpretation follows
[AAPCS32, 2025Q1, sections 6.1.1 and 6.4](https://github.com/ARM-software/abi-aa/blob/2025Q1/aapcs32/aapcs32.rst):
r0 carries word-sized results; normally returning conforming calls preserve
r6. This is an explicit ABI assumption, not exhaustive redisassembly of every
transitive callee.

## 4. Paths that the zero-status conclusion does not cover

- The runtime's other-exit-owner path at `0x258b4..0x258b8` loops around a
  wait-related dependency. Progress or eventual termination is not guaranteed
- A separate region at `0x258c8..0x25900` handles a payload/drop-like sequence,
  sets r6=101 at `0x258ec` and rejoins cleanup. It is consistent with a Rust
  unwind landing pad. This checkpoint does not prove the personality/action
  semantics or classify all panics, aborts, signals or exception destinations
- Wrapper allocation/conversion calls, worker calls and termination callbacks
  can fail to return, unwind or terminate directly. No fault injection occurred
- CLI code at `0xe934c/0xe9350` and `0xe9358/0xe935c` supplies zero directly
  to `0x1589c`, bypassing normal C-worker return propagation. These are selected
  direct-exit witnesses, not a complete help/model/options/exit inventory
- The working directory, kernel, file/device permissions, initialization arrays,
  arguments, logging, filesystem content and hardware state remain unobserved

No claim is made that every negative worker result, every diagnostic or every
possible invocation is followed by process status zero. The established claim
is conditional on the normal-return chain above.

## 5. First controlboard result criteria

`hwscan` exit status, `S12hwscan`'s `OK`, and the startup script's own status are
three different observations. None alone is evidence of successful scan/model
selection, complete cleanup, electrical containment, live native cgminer,
working hashboards or a valid accepted share.

For any later, separately authorized first controlboard experiment, the review
must define the expected stage/result observations and collect them separately:
what code was actually started; its logs and explicit stage diagnostics; its
process termination status; and whether the isolated no-hashboard objective was
met. Missing, ambiguous or contradictory observations stay unresolved. A future
reconstruction must preserve known status behavior where parity is intended and
label any deliberately improved reporting as a new adapter policy.

This checkpoint does not authorize that experiment or propose invoking stock
startup as a diagnostic. The existing S11board GPIO/PWM and scanner GPIO/I2C/PSU
side-effect findings remain in force. A failed scan or “OK” output does not
substitute for the separately reviewed boot arrangement, board/kernel identity,
pin ownership, power containment and measurement prerequisites.

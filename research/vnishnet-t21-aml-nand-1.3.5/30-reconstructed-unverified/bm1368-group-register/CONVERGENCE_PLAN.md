# Bounded startup closure plan after L13

This is a gap map for the already identified BM1368 coordinator `55774`, not a catalog of unrelated helpers. Accepted base is PR109 merge `01299b84255542c16ee6d3f0c65a3e33e7aa876a`. “Implemented” means an authored, tested host projection or recovered pure operation; none of these labels establishes physical startup or production binding.

## Named missing functional units

1. **L14: register-0x58 configuration.** Recover common-cache RMW `e3a1c/f34fc`, chip-cache RMW `e3728/f33ec`, and the actual grouping function `b58e4`. This resolves coordinator calls `5639c` and `564dc` using existing cache getters/setters and the existing register writer. The caller's exact source-file attribution is not established; put its typed projection in `integration/bm1368_group_register_135.c`, not a guessed original file. Exit condition: exact static contract, composed callback tests covering failure and mutable observations, preserved source gates, and independent review.
2. **Group-boundary register-0x2c configuration.** Recover caller `b5568` and chip method `e4690/f3b24`, reached from `56844`. Prove entry gates, zero-step/nonterminating-domain limits, live board observations, temporary descriptors, and method errors before translating. Reuse the same writer and typed descriptor concepts. Exit condition: the second real grouping call has an implemented bounded contract.
3. **Simple model-enabled writes.** Recover the three remaining direct methods reached at `56330`, `56594`, and `56798`: `e35c0/f3354` (reg54, input&7), `e3098/f2fc0` (reg3c, (input^1)|80008dee), and `e3290/f30a4` (reg68, 5aa55aa5). Preserve their distinct return/log behavior and prove flag origins. Group them as one coherent model-configuration unit if the proof remains small. Exit condition: these three actual coordinator method boundaries are callable through the existing writer.
4. **Early two-register cache RMW.** Recover `e3c04/f3618`, reached at `558ec`, with its actual model-selector/chain/count gate. AML controller=2 does not prove the distinct model-selector gate false. Reuse cache and writer and preserve partial effects. Exit condition: this last substantive selected BM1368 method boundary is covered.
5. **Complete typed coordinator composition.** Translate `55774` only after the above contracts close its method calls. Reuse the existing exact reset, INACTIVE/SET_ADDRESS, ticket, sweep, pulse, and chain-stop routines. Preserve captured owners versus reread fields, entry flags versus late model values, delay identities, ignored statuses, and first failure handling. Bind the five proved ordinary zero-return slots explicitly rather than treating them as missing hardware functions. Keep numeric constructor identities separate from host callable bindings. Exit condition: a complete bounded software coordinator executes a named startup configuration with recorded effects and meaningful failure cases; no unresolved substantive selected-method callback is disguised as success.
6. **State and worker ownership closure.** Prove and compose the startup route `7409c -> 7bfc0 -> 67ff8 -> 6c89c -> 7863c -> 55774`, alongside existing cold construction, model view, cache initialization/reset ordering, and stop/cleanup projections. Identify each remaining lifetime/worker boundary precisely. This stage may reveal a bounded missing lifecycle routine; that is a dependency of the named route, not a reason to add unrelated helpers.

## Already available and not new gaps

- Real register encoding/CRC, transport dispatcher, AML framing and UART host callbacks
- Cache defaults, getters, setters and reset algorithms, with existing API limits
- BM1368 numeric constructor identities; READ_REGISTER, reset, ticket, sweep and pulse projections; L13 address commands
- Original ordinary zero-return selected methods `e2808/f2a78`, `e49bc/f3d34`, `e49ec/f3d64`, `e4a2c/f3d6c`, and `e4a6c/f3d74`. Their raw-storage/opaque-global domain still needs to be respected; they do not stand in for unknown real operations
- Existing `vn135_chain_stop_135` for the coordinator's `56d18` error helper; it has real state/cleanup behavior and cannot be replaced by merely recording an error string

## Separate native and physical stages

An accepted host coordinator still needs an explicit native cgminer driver boundary, proved model/profile values, real transport/reply/ACK ownership, safety controls, and an authorized staged control-board run. Preserve the parallel native queue/RX/TX work and the existing 32-slot/no-safe-reuse limit. No software-only test authorizes device access or implies that the T21 miner is working.

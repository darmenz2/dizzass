/* Original 5a9fc, offline typed view; not a vendor memory layout. */
#ifndef VN135_CHAIN_CLEANUP_135_H
#define VN135_CHAIN_CLEANUP_135_H
#include "integration/general_monitor_135.h"

struct vn135_chain_cleanup_view {
    struct vn135_general_chain *chain;
    struct vn135_general_monitor *backend; /* source chain+1c */
    uint32_t word_80;
    /* Existing thermal.statistics covers +40..+6b. This body clears through
     * +6f, so preserve the missing four bytes separately, without changing ABI. */
    uint8_t statistics_tail_6c[4];
};
/* Reuses the existing reset/delay/auxiliary exchange/lock/log bindings. No
 * indicator call. The model's query_fault_87 is source board+4f; its existing
 * expected_chips_48 is board+10. Chain.chip_count is NOT the loop bound.
 *
 * All reached objects/ops are valid, serialized and terminating; no real I/O
 * is supplied. chain identity is stable. Synchronous callbacks may change
 * backend/model/chip-array pointers to valid objects and their scalar fields.
 * Reached model counts must fit the chip array. Model, chip and view objects
 * do not alias the cleared storage; no concurrent mutation is supported.
 * The final model pointer is captured after lock and chain statistics reset.
 * Chip temperature is reset as eight zero bytes, without floating arithmetic.
 * reply_scratch belongs to the existing auxiliary helper and is initialized
 * by the caller, including its stale values on failed exchange.
 * Return is the original final unlock result, NOT proof of hardware shutdown.
 * No size checks, retries beyond the original helper, or lock recovery added.
 */
int32_t vn135_chain_cleanup_135(struct vn135_chain_cleanup_view *,
    const struct vn135_chain_stop_ops *, void *, uint8_t reply_scratch[2]);
#endif

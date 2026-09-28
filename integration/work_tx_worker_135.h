/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_WORK_TX_WORKER_135_H
#define VN135_WORK_TX_WORKER_135_H
#include "integration/thermal_routes_135.h"
#include "xminer/recovery/work_nonce.h"

/* Field projections, NOT vendor, pthread, timespec or native cgminer ABIs. */
struct vn135_tx_time { uint64_t seconds_bits; uint32_t nanoseconds_bits, untouched; };
struct vn135_tx_chain { struct vn135_route_chain *state; void *uart; };
struct vn135_tx_backend { struct vn135_tx_chain *chains; uint8_t running; };
struct vn135_tx_ring { uint32_t head, tail; vn135_work_job_snapshot *rows; };
struct vn135_tx_slots { uint32_t next; vn135_work_job_snapshot *rows; };
struct vn135_tx_worker_view {
    struct vn135_tx_backend *backend;
    struct vn135_tx_ring *ring;
    struct vn135_tx_slots *slots;
};
struct vn135_tx_worker_ops {
    /* Original entry + scalar arguments. count fe668 and interval fedc4 have
     * no arguments; cancel 5a6b2c(1,0); name 593af8(15,5e977d), remaining
     * original arguments zero; lock 5a6108/unlock 5a66c4(global identity,0);
     * exit 5a52d0(0,0). Identities are labels, never host addresses. */
    int32_t (*call)(void *,uint32_t entry,uint32_t a,uint32_t b);
    int32_t (*clock)(void *,uint32_t clock_id,struct vn135_tx_time *);
    int32_t (*wait)(void *,uint32_t condition,uint32_t mutex,struct vn135_tx_time *);
    int32_t (*write)(void *,void *uart,const uint8_t *,uint32_t size);
};
/* Original 10f544 restricted to its c4b18 caller's signed 32-bit interval.
 * Adds milliseconds with source integer wrap and one normalization step.
 * Preserves the fourth word. No host clock or invented deadline policy. */
void vn135_tx_add_interval_135(struct vn135_tx_time *,int32_t milliseconds);
enum vn135_tx_worker_flow { VN135_TX_THREAD_EXIT = 1 };
/* Whole c4b18 control flow under serialized, terminating callbacks. Objects,
 * all callbacks, ring.rows[768], slots.rows[32], and all chains reached by the
 * entry-time count must be valid and nonoverlapping. slots.next is 0..31 at
 * every selection; original corruption beyond that domain is not modeled.
 * View pointers and row storage are stable. backend.chains may change at a
 * callback boundary; per-chain state/UART identities remain stable. All return
 * codes except count/interval are ignored exactly as in the source worker.
 * Callbacks may mutate running, ring indices/data, slots and chain fields.
 * No real mutex, race, UART, job freshness or production binding is supplied.
 * EXIT is an offline terminal-flow marker, not original pthread return/success.
 * The original exit callback does not return; a live caller cannot resume it. */
enum vn135_tx_worker_flow vn135_work_tx_worker_135(
    const struct vn135_tx_worker_view *,const struct vn135_tx_worker_ops *,void *);
#endif

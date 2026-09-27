/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_WORK_RX_WORKER_135_H
#define VN135_WORK_RX_WORKER_135_H
#include "integration/thermal_routes_135.h"
#include "xminer/recovery/work_nonce.h"

/* Normalized field views, not original/backend/pthread/cgminer ABIs. */
struct vn135_rx_chain {
    struct vn135_route_chain *chain; /* Only index (+18) is read here. */
    uint8_t enabled;                /* Original +318, NOT chain.present. */
    void *mutex, *fifo;             /* Original embedded +2e0, +2f8. */
};
struct vn135_rx_backend { struct vn135_rx_chain *chains; uint8_t running; };
struct vn135_rx_scratch { uint32_t cancel_old; uint8_t header_byte; };
struct vn135_rx_worker_view {
    struct vn135_rx_backend *backend;
    const vn135_work_job_snapshot *slots; /* 32 existing 168-byte snapshots. */
    struct vn135_rx_scratch initial_scratch;
};
struct vn135_rx_worker_ops {
    /* fe668 count (signed word); fdfbc selector (twice at entry); fdfac
     * selector; fe0b0 mode at entry and EACH enabled chain; d2a84 filter.
     * All are mandatory exact scalar boundaries with no default success. */
    uint32_t (*scalar)(void *,uint32_t entry);
    int32_t (*cancel)(void *,uint32_t mode,uint32_t *old_mode);
    int32_t (*name)(void *,uint32_t operation,uint32_t string_identity);
    int32_t (*sync)(void *,uint32_t entry,void *mutex);
    int32_t (*wait)(void *,uint32_t condition,uint32_t mutex);
    uint32_t (*available)(void *,void *fifo);
    int32_t (*byte)(void *,void *fifo,uint8_t *out);
    int32_t (*payload)(void *,void *fifo,uint8_t *out,uint32_t size);
    uint32_t (*chip)(void *,uint32_t nonce);
    uint32_t (*core)(void *,uint32_t nonce);
    /* Only defined source fields, not 16-byte register / 72-byte nonce ABIs.
     * Other message fields are normalized parser metadata, not source stack. */
    int32_t (*register_reply)(void *,const vn135_work_rx_message *);
    int32_t (*nonce)(void *,const vn135_nonce_candidate *);
};
/* Reconstructs c4054 including loop, wait, FIFO and dispatch ordering, while
 * reusing the existing parser and nonce preparation. All reached objects and
 * callbacks valid; positive count fits chains. View and per-chain identities
 * stable; backend.chains may switch at serialized callback boundaries. Selected
 * job is immutable during chip/core attribution and preparation (existing API
 * contract). No asynchronous races or freshness guarantee. Output callbacks
 * must not alter input byte buffers. FIFO writes are bounded by requested size;
 * return values are ignored. Explicit initial scratch supplies original old
 * stack values if byte/cancel callbacks fail without writing. Payload bytes
 * start zero on every chain. Callbacks must eventually stop the worker.
 * sync receives original global wait mutex as (void *)(uintptr_t)0x653410;
 * it is an identity token and must not be dereferenced on the host.
 * No OS/hardware defaults or production registration. Return is original 0. */
int vn135_work_rx_worker_135(const struct vn135_rx_worker_view *,
    const struct vn135_rx_worker_ops *,void *);
#endif

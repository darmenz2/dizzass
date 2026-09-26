/* Original 5e92c stop/retry decision and 5cea8 retry-count writer.
 * Offline field projections and explicit I/O bindings, not the vendor ABI. */
#ifndef VN135_STOP_POLICY_135_H
#define VN135_STOP_POLICY_135_H
#include "integration/monitor_handlers_135.h"
#include <stddef.h>
#include <stdint.h>

struct vn135_stop_policy {
    struct vn135_monitor_handlers *handlers; /* existing backend byte b0 */
    /* Bind to the existing prepare/resume text_90 slot where applicable.
     * No second independently mutable copy of that source field is created. */
    const char **top_preset_90;
    const char *text_3c;
    uint32_t word_30;
    int32_t retry_limit_88;
    uint8_t raise_failed_c8, retune_104;
};
struct vn135_restart_count_ops {
    void *(*open)(void *, const char *path, const char *mode); /* 59e5b0 */
    int32_t (*scan)(void *, void *stream, const char *format, int32_t *);
    int32_t (*print)(void *, void *stream, const char *format, int32_t);
    int32_t (*close)(void *, void *stream); /* 59e084 */
};
struct vn135_stop_policy_ops {
    uint32_t (*event_code)(void *); /* 49e94 on backend+10b4 */
    /* 82ee8 gets text_3c; 82d68 gets no text argument (NULL here).
     * Existing key/label projection; selected records and strings stay live. */
    struct vn135_handler_profile *(*profile)(void *, uint32_t entry, const char *);
    int32_t (*profile_action)(void *, uint32_t entry, const char *key);
    /* 49bd8: buffer is zeroed once on entry, then reused, not cleared per call.
     * A reached logger requires a NUL in these 512 bytes. Return is ignored. */
    int32_t (*describe_event)(void *, char *out, size_t capacity);
    /* 83080 output: exactly five source words zero-initialized before lookup.
     * The policy does not inspect the output and does not interpret its pointers.
     * Caller binding owns any allocations made by the real lower operation. */
    int32_t (*probe_profile)(void *, const char *key, uint32_t out[5]);
    const struct vn135_restart_count_ops *counter;
    void (*before_process_exit)(void *); /* 5f0fc, distinct from 5fc54 */
    void (*request_process_exit)(void *, uint32_t status); /* 10110, status=0 */
    void (*shutdown)(void *); /* bind to recovered 5fc54 when composing */
    void (*log)(void *, uint32_t line, uint32_t level,
                uint32_t first, uint32_t second, const char *detail);
};
enum vn135_stop_flow {
    VN135_STOP_RETURNED = 0,
    VN135_STOP_PROCESS_EXIT = 1
};
/* 5cea8 ignores write/close failures and returns if opening fails. This is not
 * a successful-persistence result. Nothing here opens a host file itself. */
void vn135_restart_count_store_135(const struct vn135_restart_count_ops *,
                                  void *opaque, int32_t value);
/* Full ordinary flow of 5e92c through explicit lower callees. The source's exit
 * is NONRETURNING. For offline tests the callback may return; the projection
 * then returns VN135_STOP_PROCESS_EXIT immediately, without falling through
 * to retune or shutdown. This enum is a flow boundary, NOT a vendor return code.
 * A composed parent MUST propagate that boundary or unwind its test harness;
 * it must never continue the parent as though the stop function returned.
 *
 * Required domain: valid views, callbacks and NUL-terminated accessed strings;
 * stable object/storage lifetimes; synchronous serialized callback mutations.
 * Numeric strings/scan outputs must be int32-representable (atoi/%d overflow
 * is not covered). All reached callbacks except log are required. Callback
 * errors are preserved; actual I/O, profile persistence/probing, process exit,
 * 5f0fc teardown and physical restart are NOT certified by this caller port. */
enum vn135_stop_flow vn135_stop_policy_135(struct vn135_stop_policy *,
    const struct vn135_stop_policy_ops *, void *opaque);
/* Bind only 5e92c from general/handler/prepare/resume adapters. Unknown entries
 * return 0 and leave *flow unchanged. Does not modify historical dispatchers. */
int vn135_stop_policy_dispatch_135(struct vn135_stop_policy *,
    const struct vn135_stop_policy_ops *, void *, uint32_t entry,
    enum vn135_stop_flow *flow);
#endif

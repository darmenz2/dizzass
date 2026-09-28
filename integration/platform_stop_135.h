/* A-02: original fe218 and selected platform methods. Offline projections. */
#ifndef VN135_PLATFORM_STOP_135_H
#define VN135_PLATFORM_STOP_135_H
#include <stdint.h>

/* Source slot 654b34 contains only a function pointer. Context is a new host
 * adapter facility, not an original argument or a vendor-compatible layout.
 * Slot must have a valid method. No NULL fallback or automatic platform choice. */
struct vn135_platform_stop_slot {
    void (*invoke)(void *);
    void *context;
};
void vn135_platform_stop_dispatch_135(const struct vn135_platform_stop_slot *);

/* Original 11bfbc / 1238cc / 10cf34 are BX LR; 11fda4 has only opaque
 * arithmetic/reads. None writes state or calls an external operation.
 * This void method is NOT a fabricated successful hardware result, and must
 * not be used as a fallback for unknown/missing methods. */
void vn135_platform_stop_noop_135(void *);

struct vn135_xil_stop_ops {
    uint32_t (*read_register)(void *, uint32_t index);       /* 112320 */
    uint32_t (*write_register)(void *, uint32_t, uint32_t);  /* 111c48 */
    uint32_t (*read_flags)(void *);                         /* fe7b4 */
    uint32_t (*write_flags)(void *, uint32_t);               /* fe83c */
};
struct vn135_xil_stop_binding {
    const uint8_t *skip_654b22; /* byte read by original fe024 */
    const struct vn135_xil_stop_ops *ops;
    void *context;
};
/* Original 115d88: skip if byte is nonzero; otherwise read reg 27, clear bit
 * 22, write it, then read flags, clear bit 6 and write them. Write results
 * are ignored; no additional skip check, retry, lock, delay or rollback.
 * Binding, ops and context stay stable/alive; pointed-to byte may change at
 * callback boundaries. Reached callbacks are mandatory, skipped ops may be NULL.
 * No register addresses are dereferenced on the host; no MMIO/UART defaults.
 * Real register helpers and physical stop semantics remain unaccepted. */
void vn135_platform_stop_xil_135(void *binding);
#endif

/* The selected original BM1368 method e3bbc; no vendor-ABI structure. */
#ifndef VN135_BM1368_REPLY_KEY_135_H
#define VN135_BM1368_REPLY_KEY_135_H
#include <stdint.h>

/* Returns the registration key 0x44, NOT a status or a count of work slots.
 * Table e1450 puts this getter at +0x8c; the inspected cold caller passes
 * backend+0x110 to the table builder, giving backend+0x19c.
 *
 * No arguments, state changes, I/O, callback invocation or synchronization.
 * Use only with the verified BM1368 method table. This is not a fallback for
 * unknown chips. Binding the getter does not implement callback registration,
 * unregister/drain or destruction of an in-flight callback's context.
 *
 * The old shutdown ops.step(opaque,0x19c,0) interface can call this getter
 * after independent model selection; composition is currently test-only.
 * No production registration or new registry implementation is supplied. */
uint32_t vn135_bm1368_reply_key_135(void);
#endif

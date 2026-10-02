/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_BM1368_CHIP_PULSE_WIDTH_135_H
#define VN135_BM1368_CHIP_PULSE_WIDTH_135_H
#include "integration/bm1368_pulse_width_135.h"

/* Bounded offline projection of original cgminer e33e0, BM1368 slot +0x74.
 * Distinct from the broadcast e34cc method. Reuse the existing typed register
 * writer boundary and logger; this header supplies no vendor/native ABI.
 *
 * Original ARM arguments: device, chip, pulse_width, clock_delay. Only low
 * 2/3 bits of the last two arguments are used, without range rejection.
 * Write once: (device, mode=0, original chip, register=0x3c, packed value).
 * The existing writer supports NULL chip by selecting address/cache index 0.
 * A nonzero write status emits lines 387 then 538, with a fresh one-based
 * device index for EACH diagnostic, and returns -1; zero returns zero.
 *
 * Domain: device, optional chip, ops and opaque remain valid through return;
 * both ops callbacks are present, fixed and synchronous. Device/chip fields
 * may change at callback boundaries; callbacks may not retain borrowed data.
 * Shared effects are externally serialized. uint32 index increment wraps.
 * The logger abstraction preserves line/index events and omits formatting
 * internals, as in the existing pulse API. Required decoded metadata is
 * documented in the static contract; no full logging equivalence is claimed.
 *
 * No cache preflight, retry, wait, ACK, rollback or production registration.
 * Failure may follow a dispatched write or a partial cache effect. Numeric
 * constructor binding proves method identity, not an established T21 caller.
 */
int32_t vn135_bm1368_set_chip_pulse_width_135(
    struct vn135_bm1368_frequency_device *device,
    const vn135_chip_reference *chip, uint32_t pulse_width,
    uint32_t clock_delay, const struct vn135_bm1368_pulse_ops *ops,
    void *opaque);
#endif

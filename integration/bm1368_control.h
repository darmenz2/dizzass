/* Verified BM1368 command encoding and a new fail-fast reset adapter.
 * GPL-3.0-or-later. Not a complete board initialization or power driver. */
#ifndef DIZZASS_BM1368_CONTROL_H
#define DIZZASS_BM1368_CONTROL_H
#include <stddef.h>
#include <stdint.h>
enum dizzass_bm1368_control_status {
    DIZZASS_CONTROL_OK=0, DIZZASS_CONTROL_INVALID=-810,
    DIZZASS_CONTROL_NO_SPACE=-811, DIZZASS_CONTROL_CALLBACK=-812
};
enum dizzass_bm1368_command {
    DIZZASS_BM1368_INACTIVE=0, DIZZASS_BM1368_SET_ADDRESS=1,
    DIZZASS_BM1368_READ_REGISTER=2, DIZZASS_BM1368_SET_CONFIG=3
};
/* Build only: no syscall, memory allocation, cache update or hardware access.
 * Output includes the proven AML 55AA prefix; command body matches the vendor
 * boundary before transport. INACTIVE and SET_ADDRESS require broadcast=0,
 * register=0, value=0 (inactive is intrinsically broadcast, address is zero).
 * READ requires value=0. Only explicit 0/1 broadcast and byte addresses.
 * Errors leave both outputs unchanged. out and written must not overlap.
 * Neither INACTIVE nor reset below is a proven queue-drain/power-off barrier.
 */
int dizzass_bm1368_command_encode(enum dizzass_bm1368_command command,
    uint32_t broadcast, uint32_t address, uint32_t reg, uint32_t value,
    uint8_t *out, size_t capacity, size_t *written);
struct dizzass_bm1368_reset_ops {
    void *context;
    int (*read_cached)(void *context, uint8_t reg, uint32_t *value);
    int (*write_config)(void *context, uint8_t reg, uint32_t value);
    int (*wait_ms)(void *context, uint32_t milliseconds);
};
struct dizzass_bm1368_reset_result {
    uint32_t completed; /* successful callback operations, not ASIC ACKs */
    uint32_t failed_step; /* 1-based; zero on completion */
    int callback_status;
};
/* Success-path sequence from 0xe1b64..0xe209c. fast=0/1 selects the observed
 * 5/1 ms waits; clock_delay=0..7 and pulse_width=0..3 are explicit inputs,
 * NOT recommended operating parameters. read_cached MUST be a coherent,
 * externally verified chip cache; writes MUST update it on success.
 * New fail-fast policy: stop at FIRST callback failure, no retry or rollback.
 * Caller must serialize all chip control and independently provide PSU,
 * thermal/fan protection, physical readiness, and recovery on partial changes.
 * No safety sensor or hardware reset is fabricated by this function.
 */
int dizzass_bm1368_reset_cores(const struct dizzass_bm1368_reset_ops *ops,
    uint32_t fast, uint32_t clock_delay, uint32_t pulse_width,
    struct dizzass_bm1368_reset_result *out);
#endif

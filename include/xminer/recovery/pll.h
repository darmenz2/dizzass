/* SPDX-License-Identifier: GPL-3.0-only
 * New integration API, layouts recovered from original load/store offsets.
 * No hardware programming and no implied mapping of either search to T21.
 */
#ifndef VN135_RECOVERY_PLL_H
#define VN135_RECOVERY_PLL_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    double reference_mhz;          /* +0: divisor input to legacy search */
    double vco_max_mhz;            /* +8 */
    double reserved_16;            /* +16: not read in the recovered searches */
    double vco_min_mhz;            /* +24 */
    int32_t max_reference_divider; /* +32 */
    int32_t max_feedback_divider;  /* +36 */
    int32_t max_post_divider;      /* +40 */
    int32_t reserved_44;           /* +44: not read */
    double initial_error_mhz;      /* +48 */
} vn135_pll_limits;

typedef struct {
    double vco_mhz;                /* +0, not final divided frequency */
    int32_t reference_divider;     /* +8 */
    int32_t feedback_divider;      /* +12 */
    int32_t post_divider1;         /* +16 */
    int32_t post_divider2;         /* +20 */
    int32_t candidate_written;     /* +24, may be set even on legacy failure */
    int32_t reserved_28;           /* +28, cleared by original function */
} vn135_pll_result;

/* 0 success, -1 no acceptable positive divider tuple, -2 invalid bounded input.
 * limits and out must not alias; default rounding, no fast-math is required.
 * The -2 guards are NEW: null/non-finite inputs and reference/post loops >64
 * are refused before the original search. Results are zeroed when out != NULL.
 * The two searches intentionally retain their distinct loop order, 0.1 MHz
 * tolerance, truncation/rounding and VCO restrictions; neither is generic DVFS.
 */
int vn135_pll_search_legacy(const vn135_pll_limits *limits, double requested_mhz,
    vn135_pll_result *out);
int vn135_pll_search_round4(const vn135_pll_limits *limits, double requested_mhz,
    vn135_pll_result *out);

#ifdef __cplusplus
}
#endif
#endif

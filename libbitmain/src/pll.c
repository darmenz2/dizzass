/* SPDX-License-Identifier: GPL-3.0-only
 * Partial reconstruction of /tmp/build/libbitmain/src/pll.c.
 * Entire computational searches: 0x000ff288 and 0x000ff660.
 * Original logging and opaque-predicate obfuscation are not reimplemented.
 * These API/type/field names are assigned for integration, not vendor names.
 * See evidence/stage3/ for disassembly, offsets, inputs and differential tests.
 */
#include "xminer/recovery/pll.h"
#include <float.h>
#include <stddef.h>
#include <limits.h>

#if defined(__FAST_MATH__)
#error "Recovered PLL searches require strict floating-point semantics, not fast-math"
#endif
_Static_assert(FLT_RADIX == 2 && DBL_MANT_DIG == 53 && DBL_MAX_EXP == 1024, "IEEE binary64 required");
_Static_assert(FLT_EVAL_METHOD == 0, "No extended-precision evaluation in recovered PLL searches");
_Static_assert(sizeof(double) == 8, "binary64 required");
_Static_assert(sizeof(vn135_pll_limits) == 56, "PLL input layout");
_Static_assert(sizeof(vn135_pll_result) == 32, "PLL output layout");
_Static_assert(offsetof(vn135_pll_limits, max_reference_divider) == 32, "PLL offset");
_Static_assert(offsetof(vn135_pll_limits, initial_error_mhz) == 48, "PLL offset");
_Static_assert(offsetof(vn135_pll_result, candidate_written) == 24, "PLL offset");

static int finite_value(double x) { return x == x && x <= DBL_MAX && x >= -DBL_MAX; }
static double absolute(double x) { return x < 0.0 ? -x : x; }
/* VCVT.S32.F64: round toward zero with signed saturation. Inputs here finite. */
static int32_t trunc_s32(double x)
{
    if (x >= 2147483647.0) return INT32_MAX;
    if (x <= -2147483648.0) return INT32_MIN;
    return (int32_t)x;
}
static int valid_tuple(const vn135_pll_result *r)
{
    return r->reference_divider > 0 && r->feedback_divider > 0
        && r->post_divider1 > 0 && r->post_divider2 > 0;
}
static int prepare(const vn135_pll_limits *c, double requested, vn135_pll_result *out)
{
    if (!out) return -2;
    *out = (vn135_pll_result){0};
    if (!c || !finite_value(requested) || requested < 0.0 || requested > 1e9
        || !finite_value(c->reference_mhz) || c->reference_mhz < 1e-9
        || c->reference_mhz > 1e9 || !finite_value(c->vco_min_mhz)
        || !finite_value(c->vco_max_mhz) || !finite_value(c->initial_error_mhz)
        || c->max_reference_divider > 64 || c->max_post_divider > 64)
        return -2;
    return 0;
}
static void choose(vn135_pll_result *r, double vco, int32_t ref, int32_t fb,
    int32_t p1, int32_t p2)
{
    r->vco_mhz = vco;
    r->reference_divider = ref;
    r->feedback_divider = fb;
    r->post_divider1 = p1;
    r->post_divider2 = p2;
    r->candidate_written = 1;
}

int vn135_pll_search_legacy(const vn135_pll_limits *c, double requested, vn135_pll_result *out)
{
    if (prepare(c, requested, out)) return -2;
    double best = c->initial_error_mhz;
    /* 0xff348..0xff478: ref descends; p2 ascends; p1 ascends from p2. */
    for (int32_t ref = c->max_reference_divider; ref > 0; --ref) {
        for (int32_t p2 = 1; p2 <= c->max_post_divider; ++p2) {
            for (int32_t p1 = p2; p1 <= c->max_post_divider; ++p1) {
                double numerator = (double)p1 * requested;
                numerator = numerator * (double)p2;
                numerator = numerator * (double)ref;
                int32_t fb = trunc_s32(numerator / c->reference_mhz);
                if (fb > c->max_feedback_divider) continue;
                double vco = (c->reference_mhz * (double)fb) / (double)ref;
                /* 0xff4bc..0xff500, constants taken from 0xff630..0xff648. */
                if (vco < c->vco_min_mhz - 0.1 || vco > c->vco_max_mhz + 0.1
                    || (ref != 1 && vco > 3125.1)) continue;
                double error = absolute(requested - vco / (double)(p1 * p2));
                /* A candidate less than best+0.1 replaces best, even if it is
                 * slightly WORSE. Do not silently 'fix' this to strict minimum.
                 */
                if (!valid_tuple(out) || error < best + 0.1) {
                    choose(out, vco, ref, fb, p1, p2);
                    if (error < 0.1) return valid_tuple(out) ? 0 : -1;
                    best = error;
                }
            }
        }
    }
    return valid_tuple(out) ? 0 : -1;
}

int vn135_pll_search_round4(const vn135_pll_limits *c, double requested, vn135_pll_result *out)
{
    if (prepare(c, requested, out)) return -2;
    double best = c->initial_error_mhz;
    for (int32_t ref = c->max_reference_divider; ref > 0; --ref) {
        /* 0xff790..0xff818: inclusive max_post+1, unlike legacy search. */
        for (int32_t p1 = 1; p1 <= c->max_post_divider + 1; ++p1) {
            for (int32_t p2 = p1; p2 > 0; --p2) {
                double value = (double)(ref * p1 * p2) * requested;
                value = value * 4.0;
                value = value / 100.0;
                int32_t fb = trunc_s32(value + 0.5);
                double vco = (c->reference_mhz * (double)fb) / (double)ref;
                /* 0xff900..0xff9c0. The fixed 4/100 in fb is intentional;
                 * this implementation does NOT replace it with 1/reference.
                 */
                if (fb > c->max_feedback_divider || fb < 8
                    || (ref == 1 && vco > 13325.0)
                    || vco < c->vco_min_mhz || vco > c->vco_max_mhz) continue;
                double error = absolute((vco / (double)p1) / (double)p2 - requested);
                if (!valid_tuple(out) || error < best + 0.1) {
                    choose(out, vco, ref, fb, p1, p2);
                    best = error;
                    if (error < 0.1) return 0;
                }
            }
        }
    }
    return valid_tuple(out) ? 0 : -1;
}

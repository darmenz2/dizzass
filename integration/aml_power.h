/* AML power-gate requests and shutdown policy. GPL-3.0-or-later. */
#ifndef DIZZASS_AML_POWER_H
#define DIZZASS_AML_POWER_H
#include <stdint.h>
#include <stddef.h>
#define DIZZASS_AML_CHAINS 3u
#define DIZZASS_AML_SHUTDOWN_STEPS 7u

enum dizzass_power_status {
    DIZZASS_POWER_INVALID=-900, DIZZASS_POWER_UNSUPPORTED=-901,
    DIZZASS_POWER_NOT_READY=-902, DIZZASS_POWER_IO=-903,
    DIZZASS_POWER_SHUTDOWN_FAILED=-904
};
struct dizzass_gpio_request { uint32_t pin; uint32_t value; };
/* Original platform-2 constants, not portable GPIO numbers for any T21.
 * value is the sysfs logical value observed in the binary, not a measured rail.
 * Both ON and OFF reject uninitialized state. The original OFF returned success
 * without a write there; this API intentionally does not copy that behavior.
 * Output is unchanged on error. These functions perform NO hardware operation.
 */
int dizzass_aml_power_request(uint32_t platform, int initialized, int enable,
    struct dizzass_gpio_request *out);
int dizzass_aml_reset_request(uint32_t platform, uint32_t chain, int asserted,
    struct dizzass_gpio_request *out);

typedef int (*dizzass_power_gpio_fn)(void *, const struct dizzass_gpio_request *);
struct dizzass_shutdown_ops {
    void *context;
    int (*stop_tx)(void *, uint32_t chain);
    dizzass_power_gpio_fn gpio_write;
};
struct dizzass_shutdown_receipt {
    uint32_t attempted_mask;
    uint32_t reported_ok_mask;
    int status[DIZZASS_AML_SHUTDOWN_STEPS];
};
/* New best-effort shutdown policy: stop all three software channels, request
 * PSU off, assert each chain reset. Does not stop after the first failed action.
 * Steps 0..2=stop_tx, 3=off, 4..6=reset. A missing callback is an explicit error;
 * other actions are still attempted. Only a caller-verified platform-2 binding
 * may supply GPIO I/O. No export, polarity change, voltage or frequency changes.
 * Serialized caller/lifetime exclusion required; callbacks must not reenter.
 * Return 0 means callbacks reported success, NOT off-voltage, drained UART,
 * stopped silicon or permission to reuse slots. There is no clean/resume API.
 */
int dizzass_aml_quench(uint32_t platform, const struct dizzass_shutdown_ops *ops,
    struct dizzass_shutdown_receipt *out);

/* Observed signed cutoff ordering: PCB >= limit precedes CHIP >= limit.
 * Units/limits must come from verified configuration; no T21 defaults exist.
 */
enum dizzass_thermal_trip {
    DIZZASS_THERMAL_NONE=0, DIZZASS_THERMAL_PCB=1, DIZZASS_THERMAL_CHIP=2,
    DIZZASS_THERMAL_TELEMETRY=3, DIZZASS_THERMAL_CLOCK=4,
    DIZZASS_THERMAL_FAN=5, DIZZASS_THERMAL_PSU=6
};
int dizzass_thermal_cutoff(int32_t pcb, int32_t chip,
    int32_t pcb_limit, int32_t chip_limit);
#define DIZZASS_SAMPLE_PCB 1u
#define DIZZASS_SAMPLE_CHIP 2u
#define DIZZASS_SAMPLE_FAN 4u
#define DIZZASS_SAMPLE_PSU 8u
#define DIZZASS_SAMPLE_ALL 15u
struct dizzass_thermal_sample {
    uint64_t epoch, observed_ms;
    int32_t pcb, chip;
    uint32_t valid;
    uint8_t fans_ok, psu_ok;
};
struct dizzass_thermal_limits {
    int32_t pcb, chip;
    uint32_t max_age_ms;
};
/* Additional fail-closed telemetry policy, NOT recovered vendor behavior.
 * A sample requires all fields, the current nonzero session epoch, monotonic
 * timestamps and explicit fan/PSU-health results from real drivers. Data age
 * equal to max_age_ms is stale. No arithmetic wraps on future timestamps.
 */
int dizzass_thermal_sample_check(const struct dizzass_thermal_sample *sample,
    const struct dizzass_thermal_limits *limits, uint64_t epoch, uint64_t now_ms);
#endif

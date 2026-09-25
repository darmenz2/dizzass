#ifndef DIZZASS_NATIVE_POWER_GUARD_H
#define DIZZASS_NATIVE_POWER_GUARD_H
#include "integration/aml_power.h"
struct dizzass_tx_channel;
struct dizzass_native_trip_receipt {
    int reason;
    struct dizzass_shutdown_receipt shutdown;
};
/* New integration, no second cgminer core. The array covers ALL software
 * channels connected to the common PSU; NULL entries mean absent channels.
 * Caller excludes destroy and serializes invocations; no callback may reenter
 * the channel/guard. On trip all existing channels stay stopped permanently.
 * GPIO callback must be an actual verified platform-2 backend; missing callback
 * fails explicitly but software channels are still stopped. It may use
 * gpio_value_write_at with four caller-bound trusted per-line directories.
 */
int dizzass_native_aml_quench(struct dizzass_tx_channel *const channels[3],
    dizzass_power_gpio_fn gpio_write,void *gpio_context,
    struct dizzass_shutdown_receipt *out);
/* Call from a real monitoring loop. This routine does not create a sensor
 * driver, background thread, fan override or hardware watchdog. No invocation
 * means no monitoring. Preexisting hardware protections must remain enabled.
 * Return 0 = sample acceptable (NO hardware writes); 1 = trip, all callbacks
 * reported success; negative = input error or incomplete shutdown. In no case
 * does this authorize power-on, session rearm, slot reuse or physical readiness.
 * Invalid limits also trigger best-effort shutdown before returning an error.
 */
int dizzass_native_aml_check(struct dizzass_tx_channel *const channels[3],
    const struct dizzass_thermal_sample *sample,
    const struct dizzass_thermal_limits *limits,uint64_t epoch,uint64_t now_ms,
    dizzass_power_gpio_fn gpio_write,void *gpio_context,
    struct dizzass_native_trip_receipt *out);
#endif

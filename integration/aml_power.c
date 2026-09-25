#include "integration/aml_power.h"

int dizzass_aml_power_request(uint32_t platform, int initialized, int enable,
    struct dizzass_gpio_request *out)
{
    struct dizzass_gpio_request request;
    if (!out || (initialized != 0 && initialized != 1) ||
        (enable != 0 && enable != 1)) return DIZZASS_POWER_INVALID;
    if (platform != 2) return DIZZASS_POWER_UNSUPPORTED;
    if (!initialized) return DIZZASS_POWER_NOT_READY;
    request.pin = 437;
    request.value = enable ? 0u : 1u;
    *out = request;
    return 0;
}
int dizzass_aml_reset_request(uint32_t platform, uint32_t chain, int asserted,
    struct dizzass_gpio_request *out)
{
    static const uint32_t pins[DIZZASS_AML_CHAINS] = {454,455,456};
    struct dizzass_gpio_request request;
    if (!out || chain >= DIZZASS_AML_CHAINS || (asserted != 0 && asserted != 1))
        return DIZZASS_POWER_INVALID;
    if (platform != 2) return DIZZASS_POWER_UNSUPPORTED;
    request.pin = pins[chain];
    request.value = asserted ? 0u : 1u;
    *out = request;
    return 0;
}
static void record(struct dizzass_shutdown_receipt *r, unsigned step, int status)
{
    r->attempted_mask |= UINT32_C(1) << step;
    r->status[step] = status;
    if (!status) r->reported_ok_mask |= UINT32_C(1) << step;
}
int dizzass_aml_quench(uint32_t platform, const struct dizzass_shutdown_ops *ops,
    struct dizzass_shutdown_receipt *out)
{
    struct dizzass_shutdown_receipt r = {0};
    struct dizzass_gpio_request request;
    unsigned i;
    if (!ops || !out) return DIZZASS_POWER_INVALID;
    if (platform != 2) return DIZZASS_POWER_UNSUPPORTED;
    for (i=0; i<DIZZASS_AML_CHAINS; ++i)
        record(&r,i,ops->stop_tx ? ops->stop_tx(ops->context,i) : DIZZASS_POWER_NOT_READY);
    /* Emergency cutoff must be attempted even when initialization/stop failed.
     * This does not invent an initialized vendor flag: gpio_write must itself
     * reject an unavailable or unverified line binding and report the failure.
     */
    (void)dizzass_aml_power_request(platform,1,0,&request);
    record(&r,3,ops->gpio_write ? ops->gpio_write(ops->context,&request) : DIZZASS_POWER_NOT_READY);
    for (i=0; i<DIZZASS_AML_CHAINS; ++i) {
        (void)dizzass_aml_reset_request(platform,i,1,&request);
        record(&r,4+i,ops->gpio_write ? ops->gpio_write(ops->context,&request) : DIZZASS_POWER_NOT_READY);
    }
    *out = r;
    return r.reported_ok_mask == UINT32_C(0x7f) ? 0 : DIZZASS_POWER_SHUTDOWN_FAILED;
}
int dizzass_thermal_cutoff(int32_t pcb,int32_t chip,int32_t pcb_limit,int32_t chip_limit)
{
    if (pcb >= pcb_limit) return DIZZASS_THERMAL_PCB;
    if (chip >= chip_limit) return DIZZASS_THERMAL_CHIP;
    return DIZZASS_THERMAL_NONE;
}
int dizzass_thermal_sample_check(const struct dizzass_thermal_sample *s,
    const struct dizzass_thermal_limits *limits, uint64_t epoch,uint64_t now)
{
    if (!limits || !limits->max_age_ms || !epoch) return DIZZASS_POWER_INVALID;
    if (!s || s->epoch != epoch || s->valid != DIZZASS_SAMPLE_ALL ||
        s->fans_ok > 1 || s->psu_ok > 1) return DIZZASS_THERMAL_TELEMETRY;
    if (now < s->observed_ms) return DIZZASS_THERMAL_CLOCK;
    if (now-s->observed_ms >= limits->max_age_ms) return DIZZASS_THERMAL_TELEMETRY;
    if (!s->fans_ok) return DIZZASS_THERMAL_FAN;
    if (!s->psu_ok) return DIZZASS_THERMAL_PSU;
    return dizzass_thermal_cutoff(s->pcb,s->chip,limits->pcb,limits->chip);
}

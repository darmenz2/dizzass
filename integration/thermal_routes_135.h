/* Bounded original 1.3.5 temperature-reply and chain-stop projections.
 * No vendor ABI, physical I/O defaults, new cooling policy or native miner. */
#ifndef VN135_THERMAL_ROUTES_135_H
#define VN135_THERMAL_ROUTES_135_H
#include "integration/thermal_sensors_135.h"
#include <stddef.h>
struct vn135_route_chip {
    uint32_t index, word_08;
    uint8_t valid;
    uint8_t statistics[44];
    double temperature;
};
struct vn135_route_chain {
    uint32_t index, state;
    uint8_t present, auxiliary_enabled, extra_stop_enabled, suppress_chip_samples;
    uint32_t cleared_words[4]; /* original +28,+30,+34,+38, not all statistics */
    uint8_t statistics[44];   /* original +40..+6b */
    int32_t local[3], remote[3]; /* min, signed average, max */
    uint8_t local_valid, remote_valid, local_tail[3], remote_tail[3];
    int32_t sensor_count, chip_count;
    struct vn135_temperature_sensor *sensors;
    const uint32_t *sensor_chip_addresses; /* original sensor +20 */
    struct vn135_route_chip *chips;
    char reason[512];
};
enum vn135_route_log_source {
    VN135_ROUTE_REPLY, VN135_ROUTE_CHAIN_STOP, VN135_ROUTE_AUX_STOP,
    VN135_ROUTE_AML_RESET, VN135_ROUTE_DIRECT_READ
};
typedef void (*vn135_route_log)(void *,enum vn135_route_log_source,
    uint32_t source_line,const uint32_t *arguments,size_t count);
struct vn135_reply_ops {
    const struct vn135_temperature_ops *temperature;
    int32_t (*chain_count)(void *);
    /* Original helper 6687c returns whether per-chip samples are supported.
     * Its body is outside this interface; it is NOT a new capability default. */
    int32_t (*chip_samples_supported)(void *);
    int32_t (*chain_lock)(void *,struct vn135_route_chain *);
    int32_t (*chain_unlock)(void *,struct vn135_route_chain *);
    /* Bind to existing vn135_thermal_check_overheat with a typed field view.
     * The existing decision then calls the recovered chain stop when composed. */
    int32_t (*overheat)(void *,struct vn135_route_chain *);
    int32_t (*backend_action)(void *,struct vn135_route_chain *);
    int32_t (*create_stop_thread)(void *,uint32_t entry,uint32_t *handle);
    int32_t (*power_stop)(void *);
    vn135_route_log log;
};
struct vn135_temperature_reply { int32_t chain_index; uint8_t chip_address; uint32_t payload; };
struct vn135_reply_profile { int32_t sensor_count; const uint32_t *description_types; };
/* All objects/counts/identities and reachable callbacks are valid and stable.
 * Positive counts fit allocated arrays. Callbacks may change only documented
 * outputs; no asynchronous races. Handles/scratch are explicit initialized
 * source 32-bit values. No mutex/thread_t or other vendor ABI is assumed.
 * The lookup accepts kind 1/2 and ignores state/role; stored sensor.index, not
 * its lookup position, selects the destination in the following accept step.
 * Payload is ALREADY decoded, not a raw UART frame; no new CRC decoder here. */
int32_t vn135_temperature_lookup_chip_135(const struct vn135_route_chain *,uint32_t address);
void vn135_temperature_accept_chip_135(struct vn135_route_chain *,int32_t index,
    int32_t local,int32_t remote,const struct vn135_reply_ops *,void *);
/* Includes optional per-chip override; input doubles must be finite. Original
 * 32-bit wrapping sums and truncation are preserved; flags still describe the
 * valid sensor count even when per-chip values replace remote aggregates. */
void vn135_temperature_aggregate_135(struct vn135_route_chain *,const struct vn135_reply_ops *,void *);
int vn135_temperature_reply_135(const struct vn135_reply_profile *,struct vn135_route_chain *,
    const struct vn135_temperature_reply *,const struct vn135_reply_ops *,void *,uint32_t *thread_scratch);
struct vn135_chain_stop_ops {
    int32_t (*reset_line)(void *,uint32_t chain,uint32_t asserted);
    int32_t (*delay_ms)(void *,uint32_t original_entry,uint32_t milliseconds);
    int32_t (*exchange)(void *,uint32_t chain,uint32_t address,
        const uint8_t *,uint32_t,uint8_t *,uint32_t);
    int32_t (*indicator)(void *,uint32_t value);
    int32_t (*lock)(void *,struct vn135_route_chain *);
    int32_t (*unlock)(void *,struct vn135_route_chain *);
    vn135_route_log log;
};
/* The two reply bytes explicitly model old source stack contents after an
 * unsuccessful transport call. The caller initializes them; the exchange may
 * leave them unchanged. Original return codes are ignored, as observed. */
int vn135_chain_auxiliary_stop_135(struct vn135_route_chain *,
    const struct vn135_chain_stop_ops *,void *,uint8_t reply_scratch[2]);
/* Return is the original final unlock return, NOT a hardware-success result.
 * This clears selected cache fields, not the sensor history or UART queues.
 * Inputs are serialized and reason is a nonaliasing, NUL-terminated string. */
int32_t vn135_chain_stop_135(struct vn135_route_chain *,const char *reason,
    const struct vn135_chain_stop_ops *,void *,uint8_t reply_scratch[2]);
struct vn135_aml_reset_ops {
    int32_t (*gpio_set)(void *,uint32_t pin,uint32_t value);
    vn135_route_log log;
};
/* Original AML table 454/455/456; explicit original XOR 1 (not logical NOT).
 * Not a claim about arbitrary board pin assignments. No OS I/O is built in. */
int32_t vn135_chain_reset_aml_135(uint32_t index,uint32_t asserted,
    const struct vn135_aml_reset_ops *,void *);
struct vn135_direct_temperature_ops {
    const struct vn135_temperature_ops *temperature;
    uint32_t (*platform_kind)(void *);
    /* entry identifies the original callee, not a host executable address.
     * kind 0: route, sensor address, register; kind 3: combined byte address,
     * zero addressing-mode slot, register. Bus itself is bound by context. */
    int32_t (*read)(void *,uint32_t entry,uint32_t first,uint32_t second,
        uint32_t reg,uint8_t *,uint32_t length);
    vn135_route_log log;
};
/* Bounded paths of original b5f40: access_kind is 0 OR 3. Other kinds do not
 * belong to this function's domain. Kind 1 remains in the existing reader;
 * multiplexed kind 4 and full remote calibration are not claimed here. */
int vn135_temperature_read_direct_135(struct vn135_temperature_sensor *,uint32_t chain,
    const struct vn135_direct_temperature_ops *,void *);
#endif

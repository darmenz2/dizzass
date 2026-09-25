/* New integration API for recovered work-gen RX slices; not the vendor ABI. */
#ifndef VN135_WORK_RX_H
#define VN135_WORK_RX_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
#define VN135_WORK_RX_MAX_FRAME 11u
#define VN135_WORK_RX_MAX_PAYLOAD 9u

typedef enum {
    VN135_RX_INVALID = -2,
    VN135_RX_NEED_MORE = 0,
    VN135_RX_DISCARDED = 1,
    VN135_RX_REGISTER = 2,
    VN135_RX_NONCE_RAW = 3,
    VN135_RX_REGISTER_FILTERED = 4
} vn135_work_rx_kind;

typedef struct {
    uint32_t board_selector;
    uint32_t chip_selector;
    uint32_t special_mode;
    uint32_t variant;
    uint32_t payload_size;
    uint32_t frame_size;
} vn135_work_rx_policy;

typedef struct {
    uint32_t kind;
    uint32_t consumed;       /* Bytes removed from the pending stream, not feed input. */
    uint32_t payload_size;
    uint32_t chain_id;
    uint32_t register_value;
    uint32_t chip_address;   /* First decoded address byte; model mapping unproven. */
    uint32_t register_address;
    uint32_t crc5_field;     /* Extracted low 5 bits. NOT a checksum validation. */
    uint32_t job_slot;       /* Raw 0..31 selector, NOT proof that this job exists. */
    uint8_t payload[VN135_WORK_RX_MAX_PAYLOAD];
} vn135_work_rx_message;

/* Raw internal selectors, not model names. special_mode must be stable for a
 * stream. Reconfigure only after draining/resetting the stream (new API rule). */
int vn135_work_rx_policy_init(vn135_work_rx_policy *out,
                             uint32_t board_selector, uint32_t chip_selector,
                             uint32_t special_mode);
/* Recovered dispatch 0xd2a84 with explicit selector instead of its global getter.
 * Selectors 0..4 return 0x40; all others return UINT32_MAX. Not a CRC check. */
uint32_t vn135_work_rx_filtered_register(uint32_t chip_selector);

/* Inspect one parser iteration over available, immutable bytes. No I/O, locks,
 * queue writes, or command acknowledgments. Output is unchanged on invalid args.
 * A short buffer consumes nothing; original parser waits for a full minimum
 * frame even before discarding noise. Bad first byte consumes one; AA followed
 * by non-55 consumes two (including AA AA). Input/output must not overlap.
 * REGISTER means decoded, NOT hardware verified; NONCE_RAW is not a share. */
int vn135_work_rx_next(const vn135_work_rx_policy *policy, uint32_t chain_id,
                      const uint8_t *data, size_t available,
                      vn135_work_rx_message *out);

/* Separately callable recovered bit extraction (0xc4480..0xc44dc).
 * Returns -2 for invalid arguments, otherwise writes a slot in 0..31. */
int vn135_work_rx_job_slot(uint32_t chip_selector, uint32_t variant,
                          const uint8_t *payload, size_t size, uint32_t *slot);

/* New bounded transport adapter, not reconstructed pthread/ring-buffer code.
 * No allocation; at most eleven pending bytes; explicit consumed input count.
 * One call yields at most one event. Loop over unconsumed input to drain it.
 * No automatic recovery from a changed model, no threads, callbacks, or I/O. */
typedef struct {
    vn135_work_rx_policy policy;
    uint32_t chain_id;
    uint32_t used;
    uint8_t pending[VN135_WORK_RX_MAX_FRAME];
} vn135_work_rx_stream;
int vn135_work_rx_stream_init(vn135_work_rx_stream *state, uint32_t chain_id,
                             uint32_t board_selector, uint32_t chip_selector,
                             uint32_t special_mode);
int vn135_work_rx_stream_feed(vn135_work_rx_stream *state,
                             const uint8_t *input, size_t size,
                             size_t *input_consumed, vn135_work_rx_message *out);
#ifdef __cplusplus
}
#endif
#endif

/* Selected f98b8/f9840 bodies. A host projection, not a vendor ABI. */
#ifndef VN135_LED_OUTPUT_135_H
#define VN135_LED_OUTPUT_135_H
#include <stdint.h>
#include "integration/gpio_power_135.h"

struct vn135_led_state_135 {
    uint8_t ready;
    uint32_t pins[2];
};
struct vn135_led_ops_135 {
    int32_t (*set_value)(void *, uint32_t pin, uint32_t value);
};
/* Valid stable state/ops; sequential bounded callbacks. Pin fields may change
 * at callback boundaries. No physical LED polarity or shutdown ACK is implied.
 * A reached write requires set_value. A disabled/unknown selector needs no ops.
 * GPIO return values are ignored by the original. Selector 2 reads the second
 * pin after the first call; readiness is tested once per invocation. */
void vn135_led_clear_135(struct vn135_led_state_135 *,
    const struct vn135_led_ops_135 *, void *, uint32_t selector);
void vn135_led_set_135(struct vn135_led_state_135 *,
    const struct vn135_led_ops_135 *, void *, uint32_t selector);
/* Context is a valid caller-owned vn135_gpio_io. Reuses 124ba4; no OS default. */
int32_t vn135_led_gpio_set_135(void *, uint32_t pin, uint32_t value);

enum vn135_led_route_135 {
    VN135_LED_UNHANDLED = 0,
    VN135_LED_HANDLED = 1,
    VN135_LED_INVALID_BINDING = -1
};
/* New routing status, NOT an original return value or hardware success code.
 * Unrecognized entry does not inspect state/ops. Invalid binding has no effect.
 * Caller handles other shutdown steps separately; no fallback implementation. */
enum vn135_led_route_135 vn135_led_shutdown_step_135(
    struct vn135_led_state_135 *, const struct vn135_led_ops_135 *, void *,
    uint32_t entry, uint32_t selector);
#endif

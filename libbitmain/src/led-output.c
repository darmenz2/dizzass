/* f98b8/f9840, associated through f96a0 with libbitmain/src/led.c.
 * This project-only translation unit leaves the historical led.c unchanged. */
#ifdef VN135_LED_OUTPUT_135
#include "integration/led_output_135.h"

void vn135_led_clear_135(struct vn135_led_state_135 *state,
    const struct vn135_led_ops_135 *ops, void *context, uint32_t selector)
{
    if (state->ready == 0)
        return;
    if (selector == 0 || selector == 2)
        (void)ops->set_value(context, state->pins[0], 0);
    if (selector == 1 || selector == 2)
        (void)ops->set_value(context, state->pins[1], 0);
}

void vn135_led_set_135(struct vn135_led_state_135 *state,
    const struct vn135_led_ops_135 *ops, void *context, uint32_t selector)
{
    if (state->ready != 1)
        return;
    if (selector == 0 || selector == 2)
        (void)ops->set_value(context, state->pins[0], 1);
    if (selector == 1 || selector == 2)
        (void)ops->set_value(context, state->pins[1], 1);
}

int32_t vn135_led_gpio_set_135(void *context, uint32_t pin, uint32_t value)
{
    return vn135_gpio_set_value_135((const struct vn135_gpio_io *)context,
        pin, value);
}

enum vn135_led_route_135 vn135_led_shutdown_step_135(
    struct vn135_led_state_135 *state, const struct vn135_led_ops_135 *ops,
    void *context, uint32_t entry, uint32_t selector)
{
    if (entry != 0xf98b8u && entry != 0xf9840u)
        return VN135_LED_UNHANDLED;
    if (!state)
        return VN135_LED_INVALID_BINDING;
    if (selector <= 2 && (entry == 0xf98b8u ? state->ready != 0 : state->ready == 1)
        && (!ops || !ops->set_value))
        return VN135_LED_INVALID_BINDING;
    if (entry == 0xf98b8u)
        vn135_led_clear_135(state, ops, context, selector);
    else
        vn135_led_set_135(state, ops, context, selector);
    return VN135_LED_HANDLED;
}
#endif

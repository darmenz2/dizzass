/* Checked legacy GPIO attribute write, not a physical cutoff acknowledgement. */
#ifndef DIZZASS_GPIO_VALUE_IO_H
#define DIZZASS_GPIO_VALUE_IO_H
#include "integration/aml_power.h"
struct dizzass_gpio_io_receipt {
    uint32_t value;
    unsigned written;
    int io_errno, close_errno;
};
/* Caller supplies an already-open, trusted RESOLVED directory for the specific
 * GPIO line. Binding it to request.pin is the caller's verified board-specific
 * responsibility. Sysfs class entries can be symlinks; this API never resolves
 * guessed GPIO paths. No export/direction/active_low writes are performed.
 * Requires direction="out", active_low="0"; reads only fixed attribute names.
 * Caller exclusively owns configuration and lifetime throughout the operation.
 * Success means one logical byte written and fd closed without error, NOT a
 * measured voltage or completed drain. Kernel sysfs providers may block; this
 * function makes no hard real-time/deadline guarantee. EINTR retries are capped.
 * Receipt reports uncertain progress even when close fails. No automatic retry
 * after a non-EINTR error or short write. No fsync (not a GPIO acknowledgement).
 */
int dizzass_gpio_value_write_at(int trusted_line_directory, uint32_t value,
    struct dizzass_gpio_io_receipt *out);
#endif

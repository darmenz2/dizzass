#ifndef DIZZASS_RESEARCH_HWSCAN_PLATFORM_135_H
#define DIZZASS_RESEARCH_HWSCAN_PLATFORM_135_H

#include <stdint.h>

/* Static reconstruction of the separate hwscan ELF's pure lookup at 0xe8e24.
 * Content/numeric behavior only: no vendor ABI, pointer identity or parity claim.
 */
const char *hwscan_platform_name_135(uint32_t platform_id);

/* A NEW research result carrier for the original selection slice. It replaces
 * the slice's global-store/logging boundary; it is not a recovered vendor type.
 * When argument_present == 0, platform_id preserves the supplied previous ID
 * and label is NULL because the original slice skips selection and logging.
 */
struct hwscan_platform_selection_135 {
    uint32_t platform_id;
    int argument_present;
    const char *label;
};

/* argument is NULL (option absent), or points to a readable NUL-terminated
 * string. There is no trim, case folding, prefix matching, argv parsing, I/O,
 * allocation, global write, platform dispatch or hardware access.
 */
struct hwscan_platform_selection_135 hwscan_platform_select_135(
    uint32_t previous_platform_id, const char *argument);

#endif

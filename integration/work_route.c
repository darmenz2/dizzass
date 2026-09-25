/* GPL-3.0-or-later. Bounded policy from original 0x738a4..0x73af8.
 * Algorithm==1 selects the scrypt initializer. Otherwise a nonzero platform
 * selects the TX88 initializer, while platform zero selects a separate path.
 * Reject unknown selectors rather than copying the original fall-through.
 */
#include "integration/work_route.h"
int dizzass_work_route_select(uint32_t platform_selector,
    uint32_t algorithm_selector, enum dizzass_work_family *out)
{
    enum dizzass_work_family family;
    if (!out)
        return DIZZASS_ROUTE_INVALID;
    if (platform_selector > 4 || algorithm_selector > 1)
        return DIZZASS_ROUTE_UNSUPPORTED;
    if (algorithm_selector == 1)
        family = DIZZASS_WORK_SCRYPT_TX86;
    else if (platform_selector != 0)
        family = DIZZASS_WORK_SHA256_TX88;
    else
        family = DIZZASS_WORK_SHA256_PLATFORM0;
    *out = family;
    return DIZZASS_ROUTE_OK;
}

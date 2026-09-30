#include "hwscan_platform_135.h"

#include <stddef.h>
#include <string.h>

const char *hwscan_platform_name_135(uint32_t platform_id)
{
    /* hwscan 0x4aced8: five pointers in ID order. The leaf's HI condition
     * is unsigned; negative-looking bit patterns must not index this table.
     */
    static const char *const names[] = { "xil", "bb", "aml", "cv", "stm" };

    if (platform_id > UINT32_C(4))
        return "unk";
    return names[platform_id];
}

struct hwscan_platform_selection_135 hwscan_platform_select_135(
    uint32_t previous_platform_id, const char *argument)
{
    struct hwscan_platform_selection_135 result = {
        previous_platform_id, 0, NULL
    };

    /* 0xe907c..0xe9084 skips assignment when the parsed option is absent. */
    if (argument == NULL)
        return result;

    result.argument_present = 1;
    /* Comparison order and IDs are from 0xe9088..0xe9140. The callee at
     * 0x45f7dc compares unsigned bytes through NUL; libc strcmp provides
     * the equality contract needed here without cloning a string library.
     */
    if (strcmp(argument, "aml") == 0)
        result.platform_id = UINT32_C(2);
    else if (strcmp(argument, "bb") == 0)
        result.platform_id = UINT32_C(1);
    else if (strcmp(argument, "cv") == 0)
        result.platform_id = UINT32_C(3);
    else if (strcmp(argument, "stm") == 0)
        result.platform_id = UINT32_C(4);
    else if (strcmp(argument, "xil") == 0)
        result.platform_id = UINT32_C(0);
    else
        result.platform_id = UINT32_C(5);

    /* Normalized output only. The vendor's global store and logger at
     * 0xe9168/0xe9180 are deliberately outside this pure research API.
     */
    result.label = hwscan_platform_name_135(result.platform_id);
    return result;
}

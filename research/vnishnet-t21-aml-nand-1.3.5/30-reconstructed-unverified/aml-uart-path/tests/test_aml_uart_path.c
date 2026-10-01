/* Host-only tests of the actual tracked recovered source; no hardware I/O. */
#include "xminer/recovery/aml_platform.h"
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

static uint64_t checked;
static int check(uint32_t index)
{
    const char *expected;
    const char *actual = vn135_aml_uart_path_135(index);
    /* Deliberately use explicit equality cases, independent of table indexing. */
    if (index == UINT32_C(0)) expected = "/dev/ttyS3";
    else if (index == UINT32_C(1)) expected = "/dev/ttyS2";
    else if (index == UINT32_C(2)) expected = "/dev/ttyS1";
    else expected = "";
    ++checked;
    if (actual == NULL) {
        fprintf(stderr, "NULL result for index=%" PRIu32 "\n", index);
        return 1;
    }
    if (strcmp(actual, expected) != 0) {
        fprintf(stderr, "wrong pathname for index=%" PRIu32 "\n", index);
        return 1;
    }
    /* Original return value distinguishes valid routes by contents, not NULL. */
    if ((actual[0] != '\0') != (index == 0 || index == 1 || index == 2)) {
        fprintf(stderr, "wrong caller-visible empty-string contract\n");
        return 1;
    }
    if (actual != vn135_aml_uart_path_135(index)) {
        fprintf(stderr, "result lacks stable per-index storage\n");
        return 1;
    }
    return 0;
}

int main(void)
{
    static const uint32_t high[] = {0, 1, 0x7fff, 0x8000, 0xffff};
    static const uint32_t boundary[] = {0, 1, 2, 3, 4, 7, 8, 255, 256,
        65535, 65536, UINT32_C(0x7fffffff), UINT32_C(0x80000000),
        UINT32_C(0xfffffffe), UINT32_MAX};
    const char *saved[3];
    uint32_t random = UINT32_C(0x135a6106);
    for (uint32_t index = 0; index < 3; ++index)
        saved[index] = vn135_aml_uart_path_135(index);
    for (size_t h = 0; h < sizeof(high) / sizeof(high[0]); ++h)
        for (uint32_t low = 0; low <= UINT32_C(0xffff); ++low)
            if (check((high[h] << 16) | low)) return 1;
    for (size_t i = 0; i < sizeof(boundary) / sizeof(boundary[0]); ++i)
        if (check(boundary[i])) return 1;
    for (uint32_t i = 0; i < UINT32_C(65536); ++i) {
        random = random * UINT32_C(1664525) + UINT32_C(1013904223);
        if (check(random)) return 1;
    }
    for (uint32_t index = 0; index < 3; ++index)
        if (saved[index] != vn135_aml_uart_path_135(index)) return 1;
    printf("passed: %" PRIu64 " pathname-result cases; no device operations\n", checked);
    return 0;
}

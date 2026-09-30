#include "hwscan_platform_135.h"

#include <inttypes.h>
#include <stddef.h>
#include <stdio.h>
#include <string.h>

static unsigned long checks;
static unsigned long failures;
static unsigned groups;

#define CHECK(condition) do { \
    ++checks; \
    if (!(condition)) { \
        ++failures; \
        fprintf(stderr, "line %d: %s\n", __LINE__, #condition); \
    } \
} while (0)

static void lookup_known(void)
{
    static const char *const expected[] = { "xil", "bb", "aml", "cv", "stm" };
    uint32_t id;
    ++groups;
    for (id = 0; id < UINT32_C(5); ++id) {
        const char *name = hwscan_platform_name_135(id);
        CHECK(name != NULL);
        CHECK(strcmp(name, expected[id]) == 0);
    }
}

static void lookup_unsigned_boundaries(void)
{
    static const uint32_t ids[] = {
        UINT32_C(5), UINT32_C(6), UINT32_C(255), UINT32_C(256),
        UINT32_C(65535), UINT32_C(65536), UINT32_C(0x7fffffff),
        UINT32_C(0x80000000), UINT32_C(0xfffffffe), UINT32_MAX
    };
    size_t i;
    ++groups;
    for (i = 0; i < sizeof(ids)/sizeof(ids[0]); ++i)
        CHECK(strcmp(hwscan_platform_name_135(ids[i]), "unk") == 0);
}

static void lookup_exhaustive_low_words(void)
{
    uint32_t id;
    ++groups;
    for (id = UINT32_C(5); id <= UINT32_C(65535); ++id)
        CHECK(strcmp(hwscan_platform_name_135(id), "unk") == 0);
}

static void lookup_large_values(void)
{
    uint32_t state = UINT32_C(0x6d2b79f5);
    unsigned i;
    ++groups;
    for (i = 0; i < 10000; ++i) {
        /* Fixed host-test sequence, not firmware execution or a fuzz oracle. */
        state = state * UINT32_C(1664525) + UINT32_C(1013904223);
        CHECK(strcmp(hwscan_platform_name_135(state | UINT32_C(0x80000000)), "unk") == 0);
    }
}

static void selection_known(void)
{
    static const struct { const char *name; uint32_t id; } cases[] = {
        {"aml",2}, {"bb",1}, {"cv",3}, {"stm",4}, {"xil",0}
    };
    size_t i;
    ++groups;
    for (i = 0; i < sizeof(cases)/sizeof(cases[0]); ++i) {
        struct hwscan_platform_selection_135 result = hwscan_platform_select_135(UINT32_MAX, cases[i].name);
        CHECK(result.argument_present == 1);
        CHECK(result.platform_id == cases[i].id);
        CHECK(result.label != NULL);
        CHECK(strcmp(result.label,cases[i].name) == 0);
    }
}

static void selection_unknown(void)
{
    static const char *const cases[] = {
        "", "unk", "AML", "BB", "CV", "STM", "XIL", "Aml", "aml ",
        " aml", "\taml", "aml\n", "am", "a", "b", "c", "st", "xi",
        "amll", "bbb", "cvx", "stmm", "xill", "--platform", "2", "0",
        "am\200", "\377", "\xc3\xa1ml", "arm", "amlogic"
    };
    size_t i;
    ++groups;
    for (i = 0; i < sizeof(cases)/sizeof(cases[0]); ++i) {
        struct hwscan_platform_selection_135 result = hwscan_platform_select_135(UINT32_C(2), cases[i]);
        CHECK(result.argument_present == 1);
        CHECK(result.platform_id == UINT32_C(5));
        CHECK(strcmp(result.label,"unk") == 0);
    }
}

static void selection_absent_preserves_previous(void)
{
    static const uint32_t ids[] = {0,1,2,3,4,5,6,UINT32_C(0x80000000),UINT32_MAX};
    size_t i;
    ++groups;
    for (i = 0; i < sizeof(ids)/sizeof(ids[0]); ++i) {
        struct hwscan_platform_selection_135 result = hwscan_platform_select_135(ids[i], NULL);
        CHECK(result.argument_present == 0);
        CHECK(result.platform_id == ids[i]);
        CHECK(result.label == NULL);
    }
}

static void selection_c_string_boundary(void)
{
    static const char after_nul[] = {'a','m','l','\0','x','i','l','\0'};
    static const char before_end[] = {'a','m','\0','l','\0'};
    struct hwscan_platform_selection_135 a,b;
    ++groups;
    a = hwscan_platform_select_135(UINT32_C(5),after_nul);
    b = hwscan_platform_select_135(UINT32_C(2),before_end);
    CHECK(a.platform_id == UINT32_C(2));
    CHECK(strcmp(a.label,"aml") == 0);
    CHECK(b.platform_id == UINT32_C(5));
    CHECK(strcmp(b.label,"unk") == 0);
}

static void selection_does_not_modify_input(void)
{
    char input[] = "aml";
    char saved[sizeof(input)];
    struct hwscan_platform_selection_135 result;
    ++groups;
    memcpy(saved,input,sizeof(input));
    result = hwscan_platform_select_135(UINT32_MAX,input);
    CHECK(result.platform_id == UINT32_C(2));
    CHECK(memcmp(input,saved,sizeof(input)) == 0);
}

static void lookup_names_round_trip(void)
{
    uint32_t id;
    ++groups;
    for (id = 0; id < UINT32_C(5); ++id) {
        const char *name = hwscan_platform_name_135(id);
        struct hwscan_platform_selection_135 result = hwscan_platform_select_135(UINT32_C(5),name);
        CHECK(result.platform_id == id);
        CHECK(strcmp(result.label,name) == 0);
    }
}

int main(void)
{
    lookup_known();
    lookup_unsigned_boundaries();
    lookup_exhaustive_low_words();
    lookup_large_values();
    selection_known();
    selection_unknown();
    selection_absent_preserves_previous();
    selection_c_string_boundary();
    selection_does_not_modify_input();
    lookup_names_round_trip();
    printf("{\"suite\":\"hwscan-platform-135\",\"groups\":%u,\"checks\":%lu,"
           "\"failures\":%lu,\"oracle\":\"static-derived-vectors\","
           "\"firmware_executed\":false}\n",groups,checks,failures);
    return failures != 0 ? 1 : 0;
}

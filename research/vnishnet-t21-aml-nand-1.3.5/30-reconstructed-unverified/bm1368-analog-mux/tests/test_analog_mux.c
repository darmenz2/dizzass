/* SPDX-License-Identifier: GPL-3.0-only
 * Offline composition tests: actual writer, encoder/CRC and cache. Terminal
 * callbacks only record/refuse data; no firmware instructions or I/O run.
 */
#include "integration/bm1368_analog_mux_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr, "ANALOG_MUX135_FAIL case=%u line=%d %s\n", cases, __LINE__, #x); \
    exit(1); } } while (0)
enum { CHAINS = 2, CHIPS = 3, BODY = 9 };
struct fixture {
    struct vn135_bm1368_frequency_device device;
    struct vn135_bm1368_register_ops writer;
    struct vn135_bm1368_analog_mux_log_135 log;
    vn135_reg_cache cache;
    vn135_reg_chain chains[CHAINS];
    vn135_reg_table chips[CHAINS][CHIPS];
    uint8_t expected[BODY];
    uint32_t value, outer_index, inner_index;
    int32_t send_status, selected_chain;
    unsigned scenario, sends, cache_calls, inner_logs, outer_logs;
    char events[8];
    unsigned event_count;
};
static void event(struct fixture *f, char ch)
{
    CHECK(f->event_count + 1u < sizeof f->events);
    f->events[f->event_count++] = ch;
}
/* Independent polynomial long division, x^5+x^2+1, initial 0x1f.
 * This differs from the encoder's bitwise feedback algorithm. */
static uint8_t crc_oracle(const uint8_t bytes[8])
{
    unsigned char dividend[69] = {0};
    for (unsigned bit = 0; bit < 64; ++bit)
        dividend[68u - bit] = (unsigned char)
            (((unsigned)bytes[bit / 8u] >> (7u - bit % 8u)) & 1u);
    for (unsigned bit = 64; bit < 69; ++bit) dividend[bit] ^= 1u;
    for (int bit = 68; bit >= 5; --bit) if (dividend[bit]) {
        dividend[bit] ^= 1u;
        dividend[bit - 3] ^= 1u;
        dividend[bit - 5] ^= 1u;
    }
    unsigned result = 0;
    for (unsigned bit = 0; bit < 5; ++bit) result |= (unsigned)dividend[bit] << bit;
    return (uint8_t)result;
}
static int slot54(const vn135_reg_table *table)
{
    for (int i = 0; i < VN135_REG_CACHE_SLOTS; ++i)
        if (table->entries[i].address == 0x54) return i;
    CHECK(0);
    return 0;
}
static int32_t send_record(void *opaque, struct vn135_bm1368_frequency_device *d,
    const uint8_t *body, size_t size)
{
    struct fixture *f = opaque;
    CHECK(d == &f->device && size == BODY && f->sends == 0);
    CHECK(memcmp(body, f->expected, BODY) == 0);
    CHECK(f->cache_calls == 0 && f->outer_logs == 0);
    ++f->sends; event(f, 'S');
    if (f->scenario == 1) d->index = 0;
    if (f->scenario == 2 || f->scenario == 7) f->cache.initialized = 0;
    if (f->scenario == 3) d->index = UINT32_MAX;
    return f->send_status; /* Recorded host result, no ASIC acceptance claim. */
}
static int32_t cache_chain(void *opaque, int32_t chain, uint32_t reg, uint32_t value)
{
    struct fixture *f = opaque;
    CHECK(f->sends == 1 && f->cache_calls == 0 && f->send_status == 0);
    CHECK(reg == 0x54 && value == f->value);
    f->selected_chain = chain; ++f->cache_calls; event(f, 'C');
    int32_t result = vn135_bm1368_register_cache_chain_135(&f->cache, chain, reg, value);
    if (f->scenario == 6 || f->scenario == 7) f->device.index = UINT32_MAX;
    return result;
}
static int32_t forbidden_chip(void *opaque, int32_t chain, int32_t chip,
    uint32_t reg, uint32_t value)
{
    (void)opaque; (void)chain; (void)chip; (void)reg; (void)value;
    CHECK(0); return -1;
}
static void inner_log(void *opaque, uint32_t line, uint32_t index)
{
    struct fixture *f = opaque;
    CHECK(line == 350 && f->sends == 1 && f->inner_logs == 0);
    CHECK(f->send_status != 0 && f->cache_calls == 0 && f->outer_logs == 0);
    f->inner_index = index; ++f->inner_logs; event(f, 'I');
    if (f->scenario == 6) f->device.index = UINT32_MAX;
}
static void outer_log(void *opaque,
    const struct vn135_bm1368_analog_mux_diagnostic_135 *d)
{
    struct fixture *f = opaque;
    CHECK(f->sends == 1 && f->outer_logs == 0);
    CHECK(strcmp(d->module, "driver") == 0);
    CHECK(strcmp(d->source, "/tmp/build/libbitmain/src/chip/chip1368.c") == 0);
    CHECK(strcmp(d->function, "[redacted]") == 0);
    CHECK(strcmp(d->format, "chain#%d - failed to set ANALOG_MUX_CTRL") == 0);
    CHECK(d->line == 425 && d->severity == 1);
    f->outer_index = d->index_bits; ++f->outer_logs; event(f, 'L');
    f->device.index = 123; /* No second diagnostic or index read may follow. */
}
static void one_case(uint32_t input, unsigned scenario, int32_t status)
{
    struct fixture f = {0};
    vn135_reg_table before_common[CHAINS], expected_chips[CHAINS][CHIPS];
    f.device.index = 1; f.scenario = scenario; f.send_status = status;
    /* Reviewed eight-output period, independent of helper's AND expression. */
    static const uint32_t words[8] = {0,1,2,3,4,5,6,7};
    f.value = words[input % 8u];
    f.cache.chains = f.chains; f.cache.chain_count = CHAINS; f.cache.initialized = 1;
    for (int i = 0; i < CHAINS; ++i) {
        CHECK(vn135_reg_cache_defaults(4, &f.chains[i].common) == 0);
        f.chains[i].chips = f.chips[i]; f.chains[i].chip_count = CHIPS;
        for (int j = 0; j < CHIPS; ++j) f.chips[i][j] = f.chains[i].common;
    }
    int slot = slot54(&f.chains[1].common);
    if (scenario == 4) f.chains[1].common.entries[slot].address = 0x100;
    if (scenario == 5) f.chains[1].chips = NULL;
    for (int i = 0; i < CHAINS; ++i) before_common[i] = f.chains[i].common;
    memcpy(expected_chips, f.chips, sizeof expected_chips);
    f.writer = (struct vn135_bm1368_register_ops)
        {send_record, cache_chain, forbidden_chip, inner_log};
    f.log = (struct vn135_bm1368_analog_mux_log_135){&f, outer_log};
    f.expected[0] = 0x51; f.expected[1] = 9; f.expected[2] = 0;
    f.expected[3] = 0x54; f.expected[7] = (uint8_t)f.value;
    f.expected[8] = crc_oracle(f.expected);
    int failed = status != 0 || (scenario >= 2 && scenario <= 5) || scenario == 7;
    CHECK(vn135_bm1368_set_analog_mux_135(&f.device, input, &f.writer, &f,
        failed ? &f.log : NULL) == (failed ? -1 : 0));
    CHECK(f.sends == 1 && f.cache_calls == (unsigned)(status == 0));
    CHECK(f.inner_logs == (unsigned)(status != 0));
    CHECK(f.outer_logs == (unsigned)failed);
    CHECK(strcmp(f.events, status ? "SIL" : failed ? "SCL" : "SC") == 0);
    int chain = scenario == 1 ? 0 : 1;
    if (!status) CHECK(f.selected_chain == (scenario == 3 ? -1 : chain));
    if (!failed) {
        before_common[chain].entries[slot].value = f.value;
        for (int j = 0; j < CHIPS; ++j)
            expected_chips[chain][j].entries[slot].value = f.value;
    }
    for (int i = 0; i < CHAINS; ++i)
        CHECK(memcmp(&before_common[i], &f.chains[i].common, sizeof before_common[i]) == 0);
    CHECK(memcmp(expected_chips, f.chips, sizeof expected_chips) == 0);
    if (failed) {
        uint32_t index = scenario == 1 ? 0 : scenario == 3 ? UINT32_MAX : 1;
        if (status) CHECK(f.inner_index == index + UINT32_C(1));
        if (scenario == 6 || (scenario == 7 && !status)) index = UINT32_MAX;
        CHECK(f.outer_index == index + UINT32_C(1));
    }
    ++cases;
}
int main(void)
{
    static const uint32_t high[] = {0,8,0x10000,0x7ffffff8,0x80000000,0xfffffff8};
    static const int32_t statuses[] = {0,1,-1,INT32_MIN,INT32_MAX};
    for (unsigned low = 0; low < 8; ++low) for (unsigned h = 0; h < 6; ++h)
    for (unsigned scenario = 0; scenario < 8; ++scenario)
    for (unsigned s = 0; s < 5; ++s) one_case(high[h] | low, scenario, statuses[s]);
    for (unsigned bit = 0; bit < 32; ++bit) {
        one_case(UINT32_C(1) << bit, bit % 8u, statuses[bit % 5u]);
        one_case(~(UINT32_C(1) << bit), bit % 8u, statuses[(bit + 1u) % 5u]);
    }
    printf("BM1368_ANALOG_MUX135_HOST_PASS cases=%u checks=%u\n", cases, checks);
    return 0;
}

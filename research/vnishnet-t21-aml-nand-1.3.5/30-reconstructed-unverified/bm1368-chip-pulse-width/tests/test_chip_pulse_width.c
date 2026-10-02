/* SPDX-License-Identifier: GPL-3.0-only
 * Authored host tests for the bounded e33e0 projection. Terminal callbacks
 * record or refuse bytes in caller-owned storage; there is no hardware I/O.
 * Field expectations come from the reviewed static mask/shift contract.
 */
#include "integration/bm1368_chip_pulse_width_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases, checks;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr, "CHIP_PULSE135_FAIL case=%u line=%d %s\n", cases, __LINE__, #x); \
    exit(1); } } while (0)

/* Separately recorded low-field contributions, rather than the runtime's
 * masking expression. High input bits must not select another table entry. */
static uint32_t expected_word(uint32_t pulse, uint32_t clock)
{
    static const uint32_t widths[4] = {0, 0x40, 0x80, 0xc0};
    static const uint32_t delays[8] = {0, 8, 0x10, 0x18, 0x20, 0x28, 0x30, 0x38};
    return UINT32_C(0x80008000) + widths[pulse % 4u] + delays[clock % 8u];
}

struct direct {
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip;
    const vn135_chip_reference *argument;
    uint32_t word, after_write, after_first_log;
    int32_t status;
    unsigned mutate, writes, logs;
    uint32_t lines[2], indices[2];
    char order[4];
};
static int32_t direct_write(void *opaque, struct vn135_bm1368_frequency_device *d,
    uint32_t mode, const vn135_chip_reference *chip, uint32_t reg, uint32_t word)
{
    struct direct *f = opaque;
    CHECK(d == &f->device && chip == f->argument && mode == 0 && reg == 0x3c);
    CHECK(word == f->word && f->writes == 0 && f->logs == 0);
    f->order[0] = 'W'; ++f->writes;
    if (f->mutate & 1u) { d->index = f->after_write; f->chip.wire_address ^= UINT32_MAX; }
    return f->status;
}
static void direct_log(void *opaque, uint32_t line, uint32_t index)
{
    struct direct *f = opaque;
    CHECK(f->writes == 1 && f->logs < 2 && f->status != 0);
    f->lines[f->logs] = line; f->indices[f->logs] = index;
    f->order[f->logs + 1u] = f->logs ? 'B' : 'A';
    if (!f->logs && (f->mutate & 2u)) f->device.index = f->after_first_log;
    ++f->logs;
}
static const struct vn135_bm1368_pulse_ops direct_ops = {direct_write, direct_log};

static void direct_case(uint32_t pulse, uint32_t clock, int32_t status,
    unsigned mutate, unsigned null_chip, uint32_t initial)
{
    struct direct f = {0};
    f.device.index = initial; f.chip = (vn135_chip_reference){2, 0x123};
    f.argument = null_chip ? NULL : &f.chip;
    f.word = expected_word(pulse, clock); f.status = status; f.mutate = mutate;
    f.after_write = UINT32_MAX; f.after_first_log = 17;
    CHECK(vn135_bm1368_set_chip_pulse_width_135(&f.device, f.argument,
        pulse, clock, &direct_ops, &f) == (status ? -1 : 0));
    CHECK(f.writes == 1 && f.logs == (status ? 2u : 0u));
    CHECK(strcmp(f.order, status ? "WAB" : "W") == 0);
    if (status) {
        uint32_t first = (mutate & 1u) ? f.after_write : initial;
        uint32_t second = (mutate & 2u) ? f.after_first_log : first;
        CHECK(f.lines[0] == 387 && f.lines[1] == 538);
        CHECK(f.indices[0] == first + UINT32_C(1));
        CHECK(f.indices[1] == second + UINT32_C(1));
    }
    ++cases;
}
static void direct_cases(void)
{
    static const int32_t statuses[] = {0, 1, -1, 23, -57, INT32_MIN, INT32_MAX};
    static const uint32_t high_pulse[] = {0, 4, 0x80000000, 0xfffffffc};
    static const uint32_t high_clock[] = {0, 8, 0x80000000, 0xfffffff8};
    for (unsigned p = 0; p < 4; ++p) for (unsigned c = 0; c < 8; ++c)
    for (unsigned h = 0; h < 4; ++h) for (unsigned r = 0; r < 7; ++r)
    for (unsigned m = 0; m < 4; ++m) for (unsigned n = 0; n < 2; ++n)
        direct_case(p + high_pulse[h], c + high_clock[h], statuses[r], m, n,
            h & 1u ? UINT32_MAX : UINT32_MAX - 1u);
    for (unsigned bit = 0; bit < 32; ++bit) {
        direct_case(UINT32_C(1) << bit, ~(UINT32_C(1) << bit), -1, 3, 0, 0);
        direct_case(~(UINT32_C(1) << bit), UINT32_C(1) << bit, 0, 0, 1, 0);
    }
}

enum { CHAINS = 2, CHIPS = 3, BODY = 9 };
struct pipeline {
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip;
    const vn135_chip_reference *argument;
    struct vn135_bm1368_pulse_binding binding;
    struct vn135_bm1368_register_ops writer;
    vn135_reg_cache cache;
    vn135_reg_chain chains[CHAINS];
    vn135_reg_table chips[CHAINS][CHIPS];
    uint8_t expected[BODY], captured[BODY];
    uint32_t word, outer_lines[2], outer_indices[2], inner_index;
    unsigned writes, sends, chain_calls, chip_calls, inner_logs, outer_logs;
    unsigned mutation, outer_mutation;
    int32_t send_status, selected_chain, selected_chip;
    char events[8];
    unsigned event_count;
};
static void event(struct pipeline *f, char ch)
{
    CHECK(f->event_count + 1u < sizeof f->events);
    f->events[f->event_count++] = ch;
}
/* Independent CRC5 polynomial long division, x^5+x^2+1, initial 0x1f. */
static uint8_t expected_crc(const uint8_t bytes[8])
{
    unsigned char dividend[69] = {0};
    for (unsigned bit = 0; bit < 64; ++bit)
        dividend[68u - bit] = (unsigned char)
            (((unsigned)bytes[bit / 8u] >> (7u - bit % 8u)) & 1u);
    for (unsigned bit = 64; bit < 69; ++bit) dividend[bit] ^= 1u;
    for (int bit = 68; bit >= 5; --bit) if (dividend[bit]) {
        dividend[bit] ^= 1u; dividend[bit - 3] ^= 1u; dividend[bit - 5] ^= 1u;
    }
    unsigned result = 0;
    for (unsigned bit = 0; bit < 5; ++bit) result |= (unsigned)dividend[bit] << bit;
    return (uint8_t)result;
}
static int32_t record_send(void *opaque, struct vn135_bm1368_frequency_device *d,
    const uint8_t *body, size_t n)
{
    struct pipeline *f = opaque;
    CHECK(d == &f->device && n == BODY && f->sends == 0);
    CHECK(memcmp(body, f->expected, BODY) == 0);
    memcpy(f->captured, body, BODY); ++f->sends; event(f, 'S');
    if (f->mutation == 1) {
        d->index = 0; f->chip.cache_index = 0; f->chip.wire_address = 0xff;
    } else if (f->mutation == 2) f->cache.initialized = 0;
    else if (f->mutation == 3) f->chip.cache_index = -1;
    else if (f->mutation == 4) d->index = UINT32_MAX;
    return f->send_status; /* Host recording/refusal, never an ASIC ACK. */
}
static int32_t record_chain(void *opaque, int32_t chain, uint32_t reg, uint32_t word)
{
    struct pipeline *f = opaque;
    ++f->chain_calls; event(f, 'F');
    return vn135_bm1368_register_cache_chain_135(&f->cache, chain, reg, word);
}
static int32_t record_chip(void *opaque, int32_t chain, int32_t chip,
    uint32_t reg, uint32_t word)
{
    struct pipeline *f = opaque;
    CHECK(f->sends == 1 && f->chip_calls == 0 && reg == 0x3c && word == f->word);
    f->selected_chain = chain; f->selected_chip = chip;
    ++f->chip_calls; event(f, 'C');
    return vn135_bm1368_register_cache_chip_135(&f->cache, chain, chip, reg, word);
}
static void record_inner_log(void *opaque, uint32_t line, uint32_t index)
{
    struct pipeline *f = opaque;
    CHECK(line == 350 && f->sends == 1 && f->inner_logs == 0);
    f->inner_index = index; ++f->inner_logs; event(f, 'I');
}
static int32_t real_write(void *opaque, struct vn135_bm1368_frequency_device *d,
    uint32_t mode, const vn135_chip_reference *chip, uint32_t reg, uint32_t word)
{
    struct pipeline *f = opaque;
    CHECK(d == &f->device && chip == f->argument && mode == 0);
    CHECK(reg == 0x3c && word == f->word && f->writes == 0);
    ++f->writes; event(f, 'W');
    return vn135_bm1368_pulse_register_135(&f->binding, d, mode, chip, reg, word);
}
static void record_outer_log(void *opaque, uint32_t line, uint32_t index)
{
    struct pipeline *f = opaque;
    CHECK(f->outer_logs < 2 && f->sends == 1);
    f->outer_lines[f->outer_logs] = line; f->outer_indices[f->outer_logs] = index;
    event(f, f->outer_logs ? 'B' : 'A');
    if (!f->outer_logs && f->outer_mutation) f->device.index = UINT32_MAX;
    ++f->outer_logs;
}
static const struct vn135_bm1368_pulse_ops pipeline_ops = {real_write, record_outer_log};
static void pipeline_init(struct pipeline *f, uint32_t pulse, uint32_t clock,
    uint32_t address, unsigned null_chip)
{
    memset(f, 0, sizeof *f);
    f->device.index = 1; f->chip = (vn135_chip_reference){2, address};
    f->argument = null_chip ? NULL : &f->chip; f->word = expected_word(pulse, clock);
    f->cache.chains = f->chains; f->cache.chain_count = CHAINS; f->cache.initialized = 1;
    for (int i = 0; i < CHAINS; ++i) {
        CHECK(vn135_reg_cache_defaults(4, &f->chains[i].common) == 0);
        f->chains[i].chips = f->chips[i]; f->chains[i].chip_count = CHIPS;
        for (int j = 0; j < CHIPS; ++j) f->chips[i][j] = f->chains[i].common;
    }
    f->writer = (struct vn135_bm1368_register_ops)
        {record_send, record_chain, record_chip, record_inner_log};
    f->binding = (struct vn135_bm1368_pulse_binding){&f->writer, f};
    f->expected[0] = 0x41; f->expected[1] = 9;
    f->expected[2] = null_chip ? 0 : (uint8_t)address; f->expected[3] = 0x3c;
    f->expected[4] = (uint8_t)(f->word >> 24); f->expected[5] = (uint8_t)(f->word >> 16);
    f->expected[6] = (uint8_t)(f->word >> 8); f->expected[7] = (uint8_t)f->word;
    f->expected[8] = expected_crc(f->expected);
}
static void pipeline_case(uint32_t pulse, uint32_t clock, uint32_t address,
    unsigned null_chip, unsigned mutation, int32_t send_status)
{
    struct pipeline f;
    vn135_reg_table before_common[CHAINS], expected_chips[CHAINS][CHIPS];
    pipeline_init(&f, pulse, clock, address, null_chip);
    f.mutation = mutation; f.send_status = send_status; f.outer_mutation = 1;
    if (mutation == 5) { /* Real cache's register-not-found failure, after send. */
        int chip = null_chip ? 0 : 2;
        for (int k = 0; k < VN135_REG_CACHE_SLOTS; ++k)
            if (f.chips[1][chip].entries[k].address == 0x3c)
                f.chips[1][chip].entries[k].address = 0x100;
    }
    for (int i = 0; i < CHAINS; ++i) before_common[i] = f.chains[i].common;
    memcpy(expected_chips, f.chips, sizeof expected_chips);
    int cache_error = mutation >= 2 && !(null_chip && mutation == 3);
    int failed = send_status != 0 || cache_error;
    CHECK(vn135_bm1368_set_chip_pulse_width_135(&f.device, f.argument,
        pulse, clock, &pipeline_ops, &f) == (failed ? -1 : 0));
    CHECK(f.writes == 1 && f.sends == 1 && f.chain_calls == 0);
    CHECK(f.chip_calls == (unsigned)(send_status == 0));
    CHECK(f.inner_logs == (unsigned)(send_status != 0));
    CHECK(f.outer_logs == (failed ? 2u : 0u));
    CHECK(memcmp(f.captured, f.expected, BODY) == 0);
    CHECK(strcmp(f.events, send_status ? "WSIAB" : failed ? "WSCAB" : "WSC") == 0);
    int chain = mutation == 1 ? 0 : 1;
    int chip = null_chip || mutation == 1 ? 0 : 2;
    if (!send_status) {
        CHECK(f.selected_chain == (mutation == 4 ? -1 : chain));
        CHECK(f.selected_chip == (null_chip ? 0 : mutation == 3 ? -1 : chip));
    }
    if (!failed) {
        for (int k = 0; k < VN135_REG_CACHE_SLOTS; ++k)
            if (expected_chips[chain][chip].entries[k].address == 0x3c)
                expected_chips[chain][chip].entries[k].value = f.word;
    }
    for (int i = 0; i < CHAINS; ++i)
        CHECK(memcmp(&before_common[i], &f.chains[i].common, sizeof before_common[i]) == 0);
    CHECK(memcmp(expected_chips, f.chips, sizeof expected_chips) == 0);
    if (failed) {
        uint32_t index_after_send = mutation == 1 ? 0 : mutation == 4 ? UINT32_MAX : 1;
        CHECK(f.outer_lines[0] == 387 && f.outer_lines[1] == 538);
        CHECK(f.outer_indices[0] == index_after_send + UINT32_C(1));
        CHECK(f.outer_indices[1] == 0);
        if (send_status) CHECK(f.inner_index == index_after_send + UINT32_C(1));
    }
    ++cases;
}
static void pipeline_cases(void)
{
    static const int32_t failures[] = {1, -1, INT32_MIN, INT32_MAX};
    for (unsigned p = 0; p < 4; ++p) for (unsigned c = 0; c < 8; ++c)
    for (unsigned n = 0; n < 2; ++n) for (unsigned m = 0; m < 6; ++m)
        pipeline_case(p | 0xfffffffc, c | 0xfffffff8, 0x123, n, m, 0);
    for (unsigned i = 0; i < 4; ++i) for (unsigned n = 0; n < 2; ++n)
    for (unsigned m = 0; m < 5; ++m)
        pipeline_case(3, 7, UINT32_MAX, n, m, failures[i]);
    for (unsigned address = 0; address < 256; ++address)
        pipeline_case(address, ~address, address | UINT32_C(0xa5123400), 0, 0, 0);
}
int main(void)
{
    direct_cases(); pipeline_cases();
    printf("BM1368_CHIP_PULSE135_HOST_PASS cases=%u checks=%u\n", cases, checks);
    return 0;
}

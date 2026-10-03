/* SPDX-License-Identifier: GPL-3.0-only
 * Host code only. No reference instruction interpreter or device I/O.
 */
#include "integration/bm1368_startup_registers_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases, checks, simple_cases, rmw_cases, composition_cases;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr, "STARTUP_REGISTERS_ASSERT line=%d expression=%s\n", __LINE__, #x); \
    exit(1); } } while (0)
static const int32_t statuses[] = {0, -1, 1, -91, INT32_MIN, INT32_MAX};
static uint32_t rng = UINT32_C(0x912abe37);
static uint32_t random_word(void)
{
    rng ^= rng << 13; rng ^= rng >> 17; rng ^= rng << 5; return rng;
}
/* Independent bit-position oracle, not the implementation's mask expression. */
static uint32_t expected_simple(unsigned method, uint32_t input)
{
    uint32_t out = 0;
    if (method == 2) return UINT32_C(0x5aa55aa5);
    for (unsigned bit = 0; bit < 32; ++bit) {
        unsigned set = (input >> bit) & 1u;
        if (method == 0 && bit >= 3) set = 0;
        if (method == 1) {
            if (bit == 0) set = !set;
            if ((UINT32_C(0x80008dee) >> bit) & 1u) set = 1;
        }
        if (set) out |= UINT32_C(1) << bit;
    }
    return out;
}
static uint32_t expected_rmw(unsigned reg, uint32_t input, uint32_t mode)
{
    uint32_t out = 0;
    for (unsigned bit = 0; bit < 32; ++bit) {
        unsigned set = (input >> bit) & 1u;
        if (reg == 0 && mode && (bit < 4 || bit == 8)) set = 1;
        if (reg == 0 && !mode && bit >= 4 && bit <= 7) set = 0;
        if (reg == 1 && mode && bit >= 20 && bit <= 23) set = 0;
        if (reg == 1 && !mode && ((bit >= 16 && bit <= 19) || bit >= 24)) set = 1;
        if (set) out |= UINT32_C(1) << bit;
    }
    return out;
}
struct event { char type; uint32_t index, reg, value, line; const char *format; };
struct fixture {
    struct vn135_bm1368_frequency_device device;
    int32_t read_status[2], write_status[2];
    uint32_t read_value[2];
    struct event events[8];
    unsigned used, reads, writes, logs, mutation, max_logs;
};
static void mutate(struct fixture *f)
{
    static const uint32_t values[] = {UINT32_MAX, UINT32_C(0x80000000),
        37, UINT32_C(0x7fffffff), 91, 0, UINT32_MAX, 4};
    if (f->mutation & (1u << (f->used - 1))) f->device.index = values[f->used - 1];
}
static struct event *add_event(struct fixture *f, char type)
{
    CHECK(f->used < 8);
    struct event *e = &f->events[f->used++];
    e->type = type; e->index = f->device.index; return e;
}
static int32_t raw_read(void *opaque, int32_t chain, uint32_t reg, uint32_t *out)
{
    struct fixture *f = opaque;
    CHECK(f->reads < 2); CHECK(out != NULL);
    if (f->reads) CHECK(f->read_status[0] == 0);
    struct event *e = add_event(f, 'R');
    CHECK((uint32_t)chain == e->index);
    e->reg = reg; *out = f->read_value[f->reads];
    int32_t rc = f->read_status[f->reads++];
    mutate(f); return rc;
}
static int32_t raw_write(void *opaque, struct vn135_bm1368_frequency_device *device,
    uint32_t broadcast, const vn135_chip_reference *chip, uint32_t reg, uint32_t value)
{
    struct fixture *f = opaque;
    CHECK(device == &f->device); CHECK(f->writes < 2);
    if (f->reads) CHECK(f->read_status[0] == 0 && f->read_status[1] == 0);
    if (f->writes) CHECK(f->write_status[0] == 0);
    CHECK(broadcast == 1); CHECK(chip == NULL);
    struct event *e = add_event(f, 'W'); e->reg = reg; e->value = value;
    int32_t rc = f->write_status[f->writes++];
    mutate(f); return rc;
}
static void raw_emit(void *opaque, const struct vn135_bm1368_startup_diagnostic_135 *d)
{
    struct fixture *f = opaque;
    CHECK(d != NULL); CHECK(f->logs < f->max_logs);
    CHECK(strcmp(d->component, "driver") == 0);
    CHECK(strcmp(d->source, "/tmp/build/libbitmain/src/chip/chip1368.c") == 0);
    CHECK(strcmp(d->function, "[redacted]") == 0);
    CHECK(d->severity == 1);
    CHECK(d->chain_index == f->device.index + UINT32_C(1));
    struct event *e = add_event(f, 'L');
    e->index = d->chain_index; e->line = d->line; e->format = d->format;
    ++f->logs; mutate(f);
}
static struct vn135_bm1368_startup_ops_135 raw_ops(struct fixture *f)
{
    const struct vn135_bm1368_startup_ops_135 ops = {
        raw_read, f, raw_write, f, raw_emit, f
    };
    return ops;
}
static int32_t invoke(unsigned method, struct vn135_bm1368_frequency_device *d,
    uint32_t input, const struct vn135_bm1368_startup_ops_135 *ops)
{
    switch (method) {
    case 0: return vn135_bm1368_set_analog_mux_135(d, input, ops);
    case 1: return vn135_bm1368_set_nonce_bin_overflow_135(d, input, ops);
    case 2: return vn135_bm1368_write_reg68_pattern_135(d, ops);
    case 3: return vn135_bm1368_update_soft_reset_misc_135(d, input, ops);
    default: CHECK(0); return -1;
    }
}
static void simple_case(unsigned method, uint32_t input, int32_t status,
    uint32_t initial_index, unsigned mutation)
{
    struct fixture f = {0};
    f.device.index = initial_index; f.write_status[0] = status; f.mutation = mutation;
    struct vn135_bm1368_startup_ops_135 ops = raw_ops(&f);
    f.max_logs = method == 2 || !status ? 0u : method + 1u;
    ops.read_chain = NULL; ops.read_context = NULL;
    int32_t rc = invoke(method, &f.device, input, &ops);
    CHECK(rc == (method == 2 ? status : status ? -1 : 0));
    CHECK(f.reads == 0); CHECK(f.writes == 1);
    CHECK(f.logs == (method == 2 || !status ? 0u : method + 1u));
    CHECK(f.used == f.writes + f.logs);
    CHECK(f.events[0].type == 'W'); CHECK(f.events[0].index == initial_index);
    CHECK(f.events[0].reg == (method == 0 ? 0x54u : method == 1 ? 0x3cu : 0x68u));
    CHECK(f.events[0].value == expected_simple(method, input));
    if (f.logs) {
        CHECK(f.events[1].line == (method == 0 ? 425u : 387u));
        CHECK(strcmp(f.events[1].format, method == 0 ?
            "chain#%d - failed to set ANALOG_MUX_CTRL" :
            "chain#%d - failed to send core command") == 0);
        CHECK(f.events[1].index == ((mutation & 1u) ? 0 : initial_index + 1u));
    }
    if (f.logs == 2) {
        CHECK(f.events[2].line == 593);
        CHECK(strcmp(f.events[2].format,
            "chain#%d - failed to set NONCE_BIN_OVERFLOW_CTRL") == 0);
        CHECK(f.events[2].index == ((mutation & 2u) ? UINT32_C(0x80000001) : f.events[1].index));
    }
    ++cases; ++simple_cases;
}
static void rmw_case(uint32_t mode, uint32_t soft, uint32_t misc,
    int32_t r1, int32_t r2, int32_t w1, int32_t w2, unsigned mutation)
{
    struct fixture f = {0};
    f.device.index = UINT32_C(0x81234567); f.mutation = mutation;
    f.read_value[0] = soft; f.read_value[1] = misc;
    f.read_status[0] = r1; f.read_status[1] = r2;
    f.write_status[0] = w1; f.write_status[1] = w2;
    struct vn135_bm1368_startup_ops_135 ops = raw_ops(&f);
    /* Forbidden effects assert in callbacks, including mutated error paths. */
    int32_t rc = invoke(3, &f.device, mode, &ops);
    unsigned nr = r1 ? 1 : 2;
    unsigned nw = r1 || r2 ? 0 : w1 ? 1 : 2;
    CHECK(rc == (r1 || r2 || w1 || w2 ? -1 : 0));
    CHECK(f.reads == nr); CHECK(f.writes == nw); CHECK(f.logs == 0);
    CHECK(f.used == nr + nw); CHECK(f.events[0].type == 'R');
    CHECK(f.events[0].reg == 0xa8); CHECK(f.events[0].index == UINT32_C(0x81234567));
    if (nr == 2) {
        CHECK(f.events[1].type == 'R'); CHECK(f.events[1].reg == 0x18);
        CHECK(f.events[1].index == ((mutation & 1u) ? UINT32_MAX : UINT32_C(0x81234567)));
    }
    if (nw) {
        CHECK(f.events[2].type == 'W'); CHECK(f.events[2].reg == 0xa8);
        CHECK(f.events[2].value == expected_rmw(0, soft, mode));
    }
    if (nw == 2) {
        CHECK(f.events[3].type == 'W'); CHECK(f.events[3].reg == 0x18);
        CHECK(f.events[3].value == expected_rmw(1, misc, mode));
    }
    ++cases; ++rmw_cases;
}

/* The composed tests call the REAL new adapters, reg_cache, writer, encoder
 * and CRC. Only the terminal send is a recording/refusing test boundary. */
struct composed {
    struct vn135_bm1368_frequency_device device;
    vn135_reg_cache cache;
    unsigned method, sends, cache_calls, lower_logs, upper_logs;
    unsigned fail_send, fail_cache, mutate;
    int32_t failure;
    uint32_t input, soft, misc;
    uint32_t shadow[2][5];
    uint8_t frames[2][9];
};
static const uint32_t regs[5] = {0x54, 0x3c, 0x68, 0xa8, 0x18};
static void *allocate_zero(void *unused, size_t size, size_t count)
{ (void)unused; return calloc(count, size); }
static void release_alloc(void *unused, void *p) { (void)unused; free(p); }
static uint8_t crc_expected(const uint8_t *p)
{
    unsigned state = 31;
    for (unsigned bit = 0; bit < 64; ++bit) {
        unsigned feedback = ((state >> 4) & 1u) ^ (((unsigned)p[bit / 8] >> (7 - bit % 8)) & 1u);
        state = (state * 2) & 31u;
        if (feedback) state ^= 5u;
    }
    return (uint8_t)state;
}
static int32_t terminal_send(void *opaque, struct vn135_bm1368_frequency_device *d,
    const uint8_t *p, size_t size)
{
    struct composed *f = opaque;
    CHECK(d == &f->device); CHECK(size == 9); CHECK(f->sends < 2);
    unsigned position = f->sends++;
    memcpy(f->frames[position], p, 9);
    CHECK(p[0] == 0x51); CHECK(p[1] == 9); CHECK(p[2] == 0);
    CHECK(p[3] == (f->method < 3 ? regs[f->method] : regs[3 + position]));
    uint32_t word = ((uint32_t)p[4] << 24) | ((uint32_t)p[5] << 16) | ((uint32_t)p[6] << 8) | p[7];
    CHECK(word == (f->method < 3 ? expected_simple(f->method, f->input) :
        expected_rmw(position, position ? f->misc : f->soft, f->input)));
    CHECK(p[8] == crc_expected(p));
    if (f->mutate && position == 0) {
        /* Change cache and destination AFTER both RMW input reads. */
        f->device.index = 1;
        CHECK(vn135_reg_cache_set_chain(&f->cache, 1, 0x18, UINT32_C(0xdeadbeef)) == 0);
        f->shadow[1][4] = UINT32_C(0xdeadbeef);
    }
    return f->fail_send == f->sends ? f->failure : 0;
}
static int32_t cache_real(void *opaque, int32_t chain, uint32_t reg, uint32_t word)
{
    struct composed *f = opaque; ++f->cache_calls;
    CHECK(chain == (int32_t)f->device.index);
    if (f->fail_cache == f->cache_calls) f->cache.initialized = 0;
    int32_t rc = vn135_bm1368_register_cache_chain_135(&f->cache, chain, reg, word);
    if (!rc) {
        unsigned k = 0; while (k < 5 && regs[k] != reg) ++k;
        CHECK(k < 5); f->shadow[(unsigned)chain][k] = word;
    }
    return rc;
}
static int32_t unicast_forbidden(void *unused, int32_t c, int32_t i, uint32_t r, uint32_t w)
{ (void)unused; (void)c; (void)i; (void)r; (void)w; CHECK(0); return -1; }
static void lower_log(void *opaque, uint32_t line, uint32_t index)
{
    struct composed *f = opaque; ++f->lower_logs;
    CHECK(line == 350); CHECK(index == f->device.index + 1u);
    if (f->mutate) f->device.index = UINT32_MAX;
}
static void upper_log(void *opaque, const struct vn135_bm1368_startup_diagnostic_135 *d)
{
    struct composed *f = opaque; ++f->upper_logs;
    CHECK(f->method < 2); CHECK(d->chain_index == f->device.index + 1u);
    CHECK(d->line == (f->method == 0 ? 425u : f->upper_logs == 1 ? 387u : 593u));
    if (f->mutate) f->device.index = UINT32_C(0x80000000);
}
static void composed_case(unsigned method, uint32_t input, unsigned fail_send,
    unsigned fail_cache, int32_t failure, unsigned mutate_cache)
{
    struct composed f = {0};
    f.method = method; f.input = input; f.fail_send = fail_send;
    f.fail_cache = fail_cache; f.failure = failure; f.mutate = mutate_cache;
    f.soft = UINT32_C(0x12345678); f.misc = UINT32_C(0x89abcdef);
    const vn135_reg_allocator allocator = {NULL, allocate_zero, release_alloc};
    CHECK(vn135_reg_cache_init(&f.cache, 4, 2, 3, &allocator) == 0);
    for (int32_t c = 0; c < 2; ++c) {
        CHECK(vn135_reg_cache_set_chain(&f.cache, c, 0xa8, f.soft) == 0);
        CHECK(vn135_reg_cache_set_chain(&f.cache, c, 0x18, f.misc) == 0);
        for (unsigned k = 0; k < 5; ++k)
            CHECK(vn135_reg_cache_get_chain(&f.cache, c, regs[k], &f.shadow[(unsigned)c][k]) == 0);
    }
    const struct vn135_bm1368_register_ops writer = {
        terminal_send, cache_real, unicast_forbidden, lower_log
    };
    struct vn135_bm1368_startup_write_binding_135 binding = {&writer, &f};
    const struct vn135_bm1368_startup_ops_135 ops = {
        vn135_bm1368_startup_cache_read_135, &f.cache,
        vn135_bm1368_startup_register_write_135, &binding, upper_log, &f
    };
    int32_t rc = invoke(method, &f.device, input, &ops);
    unsigned maximum = method == 3 ? 2 : 1;
    unsigned stop = fail_send ? fail_send : fail_cache;
    unsigned sent = stop ? stop : maximum;
    CHECK(rc == (stop ? -1 : 0)); CHECK(f.sends == sent);
    CHECK(f.cache_calls == sent - (fail_send ? 1u : 0u));
    CHECK(f.lower_logs == (fail_send ? 1u : 0u));
    CHECK(f.upper_logs == (stop && method < 2 ? method + 1u : 0u));
    /* Inspect only after restoring the fixture's deliberately disabled cache. */
    f.cache.initialized = 1;
    for (int32_t c = 0; c < 2; ++c) for (unsigned k = 0; k < 5; ++k) {
        uint32_t v = 0;
        CHECK(vn135_reg_cache_get_chain(&f.cache, c, regs[k], &v) == 0);
        CHECK(v == f.shadow[(unsigned)c][k]);
        for (int32_t chip = 0; chip < 3; ++chip) {
            CHECK(vn135_reg_cache_get_chip(&f.cache, c, chip, regs[k], &v) == 0);
            CHECK(v == f.shadow[(unsigned)c][k]);
        }
    }
    vn135_reg_cache_destroy(&f.cache);
    CHECK(f.cache.chains == NULL); ++cases; ++composition_cases;
}
static void real_read_failure_cases(void)
{
    struct vn135_bm1368_frequency_device d = {0};
    vn135_reg_cache cache = {0};
    const struct vn135_bm1368_startup_ops_135 ops = {
        vn135_bm1368_startup_cache_read_135, &cache, NULL, NULL, NULL, NULL
    };
    CHECK(vn135_bm1368_update_soft_reset_misc_135(&d, 1, &ops) == -1);
    ++cases; ++composition_cases;
    const vn135_reg_allocator a = {NULL, allocate_zero, release_alloc};
    CHECK(vn135_reg_cache_init(&cache, 4, 1, 2, &a) == 0);
    d.index = UINT32_MAX;
    CHECK(vn135_bm1368_update_soft_reset_misc_135(&d, 0, &ops) == -1);
    ++cases; ++composition_cases;
    d.index = 0;
    /* Corrupt only the fixture's second requested common-cache entry. */
    int found = 0;
    for (unsigned i = 0; i < VN135_REG_CACHE_SLOTS; ++i)
        if (cache.chains[0].common.entries[i].address == 0x18) {
            cache.chains[0].common.entries[i].address = UINT32_MAX; found = 1;
        }
    CHECK(found);
    CHECK(vn135_bm1368_update_soft_reset_misc_135(&d, 2, &ops) == -1);
    ++cases; ++composition_cases;
    vn135_reg_cache_destroy(&cache);
}
int main(void)
{
    uint32_t vectors[832]; unsigned n = 0;
    for (uint32_t i = 0; i < 256; ++i) vectors[n++] = i;
    for (unsigned i = 0; i < 32; ++i) vectors[n++] = UINT32_C(1) << i;
    for (unsigned i = 0; i < 32; ++i) vectors[n++] = ~(UINT32_C(1) << i);
    while (n < 832) vectors[n++] = random_word();
    for (unsigned method = 0; method < 2; ++method)
        for (unsigned i = 0; i < n; ++i)
            for (unsigned s = 0; s < 6; ++s)
                for (unsigned mutation = 0; mutation < 4; ++mutation)
                    simple_case(method, vectors[i], statuses[s], vectors[n - i - 1], mutation);
    for (unsigned i = 0; i < 8; ++i) for (unsigned s = 0; s < 6; ++s)
        for (unsigned m = 0; m < 2; ++m) simple_case(2, 0, statuses[s], vectors[i], m);
    const uint32_t modes[] = {0, 1, 2, UINT32_C(0x80000000), UINT32_MAX, 0x100};
    for (unsigned mode = 0; mode < 6; ++mode)
        for (unsigned r1 = 0; r1 < 6; ++r1) for (unsigned r2 = 0; r2 < 6; ++r2)
            for (unsigned w1 = 0; w1 < 6; ++w1) for (unsigned w2 = 0; w2 < 6; ++w2)
                rmw_case(modes[mode], UINT32_C(0x01234567), UINT32_C(0x89abcdef),
                    statuses[r1], statuses[r2], statuses[w1], statuses[w2], 15);
    for (unsigned i = 0; i < n; ++i) for (unsigned mode = 0; mode < 6; ++mode)
        rmw_case(modes[mode], vectors[i], vectors[n - i - 1], 0, 0, 0, 0, i & 15u);
    for (unsigned method = 0; method < 4; ++method)
        for (unsigned mode = 0; mode < 6; ++mode) for (unsigned mutate_cache = 0; mutate_cache < 2; ++mutate_cache) {
            composed_case(method, modes[mode], 0, 0, 0, mutate_cache);
            unsigned maximum = method == 3 ? 2 : 1;
            for (unsigned position = 1; position <= maximum; ++position) {
                composed_case(method, modes[mode], position, 0, -91, mutate_cache);
                composed_case(method, modes[mode], position, 0, 73, mutate_cache);
                composed_case(method, modes[mode], 0, position, 0, mutate_cache);
            }
        }
    real_read_failure_cases();
    printf("STARTUP_REGISTERS_PASS cases=%u checks=%u simple=%u rmw=%u composition=%u hardware=no\n",
        cases, checks, simple_cases, rmw_cases, composition_cases);
    return 0;
}

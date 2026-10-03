/* Host fixtures for the statically witnessed e3728/e3a1c and b58e4 contracts.
 * All transport, locking and wait effects are recorded callbacks. */
#include "integration/bm1368_group_register_135.h"
#include "integration/transport_dispatch_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned checks, cases, group_cases, composed_cases;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr, "GROUP_REGISTER_FAIL line=%d %s\n", __LINE__, #x); \
    exit(1); \
} } while (0)

static int32_t signed_word(uint32_t word)
{
    return word <= INT32_MAX ? (int32_t)word :
        (int32_t)((int64_t)word - INT64_C(4294967296));
}

/* Independently express the selected bit-field replacement arithmetically. */
static uint32_t expected_value(uint32_t old, uint32_t setting)
{
    return old - ((old / 4096u) % 16u) * 4096u + (setting % 16u) * 4096u;
}

/* Polynomial long division for x^5+x^2+1, initial1f, MSB-first, no final XOR.
 * Dividing one incoming data bit at a time avoids a >64-bit intermediate. */
static uint8_t independent_crc(const uint8_t data[8])
{
    unsigned remainder = 0;
    /* Divide (data_as_u64 << 5) XOR (31 << 64), one coefficient at a time. */
    for (int position = 68; position >= 0; --position) {
        const unsigned bit = (unsigned)(68 - position);
        unsigned coefficient = position >= 5 ?
            ((unsigned)data[bit / 8u] >> (7u - bit % 8u)) & 1u : 0u;
        if (position >= 64) coefficient ^= 1u;
        const unsigned dividend = (remainder << 1) | coefficient;
        remainder = (dividend & 32u) ? dividend ^ 0x25u : dividend;
    }
    return (uint8_t)remainder;
}

static void crc_goldens(void)
{
    static const uint8_t inputs[][8] = {
        {0,0,0,0,0,0,0,0},
        {0x51,9,0,0x58,0x12,0x34,0x96,0x78},
        {0x41,9,0x34,0x58,0xff,0xff,0xff,0xff}
    };
    static const uint8_t expected[] = {0x13, 0x0e, 0x16};
    for (unsigned i = 0; i < sizeof expected; ++i)
        CHECK(independent_crc(inputs[i]) == expected[i]);
}

struct fixture {
    struct vn135_bm1368_frequency_device device;
    vn135_chip_reference chip, *active_chip;
    vn135_reg_cache cache;
    vn135_reg_chain chains[2];
    vn135_reg_table chips[2][8];
    struct vn135_bm1368_drive_strength_read_135 read;
    struct vn135_bm1368_register_ops writer;
    struct vn135_bm1368_drive_strength_log_135 log;
    struct vn135_transport_dispatch_135 transport;
    unsigned common, reads, sends, stores, writer_logs, wrapper_logs;
    unsigned fail_read, fail_send, fail_store, omit_output;
    int32_t read_status, send_status, store_status;
    unsigned mutate_read, mutate_send, mutate_store, mutate_writer_log, mutate_wrapper_log;
    uint32_t setting, saved_setting, last_old, last_value, last_log_index;
    uint8_t sent[8][9];
    int32_t read_chain[8], read_chip[8], store_chain[8], store_chip[8];
    char events[256];
    unsigned event_count;
    unsigned lower, allocated, outer, inner, allocations, releases, writes, sleeps, errors;
    unsigned replay, short_write, lower_failure_number;
    int32_t error_number;
    uint8_t frame[11];
    vn135_uart uart;
    vn135_uart_ops uart_ops;
    vn135_aml_transport framing;
    struct vn135_aml_uart_binding_135 binding;
};

static void event(struct fixture *f, char code)
{
    CHECK(f->event_count + 1 < sizeof f->events);
    f->events[f->event_count++] = code;
    f->events[f->event_count] = 0;
}

static void mutate_after_read(struct fixture *f)
{
    if (!f->mutate_read) return;
    f->device.index = 1;
    if (f->active_chip) {
        f->active_chip->cache_index = 4;
        f->active_chip->wire_address = UINT32_C(0x123456a7);
    }
    f->setting = UINT32_MAX; /* The actual call already captured its value. */
}

static int32_t read_chain(void *opaque, int32_t chain, uint32_t reg, uint32_t *value)
{
    struct fixture *f = opaque;
    CHECK(f->common && reg == 0x58 && *value == 0 && f->reads < 8);
    CHECK(chain == signed_word(f->device.index));
    f->read_chain[f->reads] = chain; f->read_chip[f->reads] = -1;
    ++f->reads; event(f, 'R');
    int32_t result = 0;
    if (f->reads == f->fail_read) result = f->read_status;
    else if (!f->omit_output)
        result = vn135_bm1368_drive_strength_cache_chain_135(&f->cache, chain, reg, value);
    if (f->reads != f->fail_read && !f->omit_output)
        CHECK(result == (chain >= 0 && chain < 2 ? 0 : -1));
    if (result == 0 && !f->omit_output) {
        CHECK(chain >= 0 && chain < 2);
        CHECK(*value == f->chains[chain].common.entries[0].value);
    }
    f->last_old = *value;
    mutate_after_read(f);
    return result;
}

static int32_t read_chip(void *opaque, int32_t chain, int32_t chip,
                         uint32_t reg, uint32_t *value)
{
    struct fixture *f = opaque;
    CHECK(!f->common && reg == 0x58 && *value == 0 && f->reads < 8);
    CHECK(chain == signed_word(f->device.index));
    CHECK(f->active_chip && chip == f->active_chip->cache_index);
    f->read_chain[f->reads] = chain; f->read_chip[f->reads] = chip;
    ++f->reads; event(f, 'R');
    int32_t result = 0;
    if (f->reads == f->fail_read) result = f->read_status;
    else if (!f->omit_output)
        result = vn135_bm1368_drive_strength_cache_chip_135(&f->cache, chain, chip, reg, value);
    if (f->reads != f->fail_read && !f->omit_output)
        CHECK(result == (chain >= 0 && chain < 2 && chip >= 0 && chip < 8 ? 0 : -1));
    if (result == 0 && !f->omit_output) {
        CHECK(chain >= 0 && chain < 2 && chip >= 0 && chip < 8);
        CHECK(*value == f->chips[chain][chip].entries[0].value);
    }
    f->last_old = *value;
    mutate_after_read(f);
    return result;
}

static int32_t direct_transport(void *opaque, void *device, const uint8_t *body, uint32_t n)
{
    struct fixture *f = opaque;
    CHECK(device == &f->device && n == 9 && f->sends > 0);
    CHECK(memcmp(body, f->sent[f->sends - 1], 9) == 0);
    return f->sends == f->fail_send ? f->send_status : 0;
}

static int32_t send_payload(void *opaque, struct vn135_bm1368_frequency_device *device,
                            const uint8_t *body, size_t n)
{
    struct fixture *f = opaque;
    CHECK(device == &f->device && n == 9 && f->sends < 8 && f->reads == f->sends + 1);
    uint8_t expected[9] = {f->common ? 0x51 : 0x41, 9, 0, 0x58, 0, 0, 0, 0, 0};
    expected[2] = f->common ? 0 : (uint8_t)(f->active_chip->wire_address % 256u);
    const uint32_t value = expected_value(f->last_old, f->saved_setting);
    for (unsigned i = 0; i < 4; ++i)
        expected[4 + i] = (uint8_t)(value >> (24u - 8u * i));
    expected[8] = independent_crc(expected);
    CHECK(memcmp(body, expected, sizeof expected) == 0);
    CHECK((value & UINT32_C(0xffff0fff)) == (f->last_old & UINT32_C(0xffff0fff)));
    CHECK((value / 4096u) % 16u == f->saved_setting % 16u);
    f->last_value = value;
    memcpy(f->sent[f->sends], body, 9);
    ++f->sends; event(f, 'S');
    const int32_t result = vn135_transport_send_135(&f->transport, device, body, (uint32_t)n);
    if (f->mutate_send) {
        f->device.index = 1;
        if (f->active_chip) {
            f->active_chip->cache_index = 5;
            f->active_chip->wire_address = UINT32_C(0x76543219);
        }
    }
    return result;
}

static int32_t store_value(struct fixture *f, int32_t chain, int32_t chip,
                           uint32_t reg, uint32_t value)
{
    CHECK(reg == 0x58 && value == f->last_value && f->stores < 8);
    CHECK(chain == signed_word(f->device.index));
    CHECK(f->common || (f->active_chip && chip == f->active_chip->cache_index));
    CHECK(!f->allocated && !f->outer && !f->inner);
    f->store_chain[f->stores] = chain; f->store_chip[f->stores] = chip;
    ++f->stores; event(f, 'C');
    int32_t result;
    if (f->stores == f->fail_store) result = f->store_status;
    else if (f->common)
        result = vn135_bm1368_register_cache_chain_135(&f->cache, chain, reg, value);
    else
        result = vn135_bm1368_register_cache_chip_135(&f->cache, chain, chip, reg, value);
    if (f->mutate_store) f->device.index = UINT32_MAX;
    return result;
}
static int32_t store_chain(void *p, int32_t chain, uint32_t reg, uint32_t value)
{
    struct fixture *f = p; CHECK(f->common);
    return store_value(f, chain, -1, reg, value);
}
static int32_t store_chip(void *p, int32_t chain, int32_t chip, uint32_t reg, uint32_t value)
{
    struct fixture *f = p; CHECK(!f->common);
    return store_value(f, chain, chip, reg, value);
}
static void writer_log(void *opaque, uint32_t line, uint32_t index)
{
    struct fixture *f = opaque;
    CHECK(line == 350 && index == f->device.index + UINT32_C(1));
    CHECK(!f->allocated && !f->outer && !f->inner);
    ++f->writer_logs; event(f, 'W');
    if (f->mutate_writer_log) f->device.index = UINT32_MAX;
}
static void wrapper_log(void *opaque, const struct vn135_bm1368_drive_strength_diagnostic_135 *d)
{
    struct fixture *f = opaque;
    const unsigned read_error = f->reads > f->sends;
    CHECK(strcmp(d->module, "driver") == 0);
    CHECK(strcmp(d->source_path, "/tmp/build/libbitmain/src/chip/chip1368.c") == 0);
    CHECK(strcmp(d->function, "[redacted]") == 0);
    CHECK(d->severity == 1 && d->has_index == !read_error);
    CHECK(d->source_line == (read_error ? (f->common ? 635u : 609u) : (f->common ? 645u : 619u)));
    CHECK(strcmp(d->format, read_error ? (f->common ?
        "Failed to read cached driver strenght register" :
        "Failed to read cached drive strength register") :
        "chain#%d - failed to config drive strength") == 0);
    CHECK(d->index_bits == (read_error ? 0 : f->device.index + UINT32_C(1)));
    CHECK(!f->allocated && !f->outer && !f->inner);
    f->last_log_index = d->index_bits;
    ++f->wrapper_logs; event(f, 'L');
    if (f->mutate_wrapper_log) {
        f->device.index = 37;
        CHECK(d->index_bits == f->last_log_index);
    }
}

static void initialize(struct fixture *f, unsigned common, uint32_t old, uint32_t setting)
{
    memset(f, 0, sizeof *f);
    f->common = common; f->chip.cache_index = 2; f->chip.wire_address = 0x1234;
    f->active_chip = &f->chip;
    f->setting = setting; f->saved_setting = setting;
    f->cache.chains = f->chains; f->cache.chain_count = 2; f->cache.initialized = 1;
    for (unsigned chain = 0; chain < 2; ++chain) {
        f->chains[chain].chips = f->chips[chain]; f->chains[chain].chip_count = 8;
        f->chains[chain].common.entries[0] = (vn135_reg_entry){0x58, old};
        for (unsigned chip = 0; chip < 8; ++chip)
            f->chips[chain][chip].entries[0] = (vn135_reg_entry){0x58, old};
    }
    f->read = (struct vn135_bm1368_drive_strength_read_135){f, read_chain, read_chip};
    f->writer = (struct vn135_bm1368_register_ops){send_payload, store_chain, store_chip, writer_log};
    f->log = (struct vn135_bm1368_drive_strength_log_135){f, wrapper_log};
    f->transport = (struct vn135_transport_dispatch_135){direct_transport, f};
}

static int32_t invoke(struct fixture *f, unsigned no_writer, unsigned no_log)
{
    const struct vn135_bm1368_register_ops *writer = no_writer ? NULL : &f->writer;
    const struct vn135_bm1368_drive_strength_log_135 *log = no_log ? NULL : &f->log;
    return f->common ? vn135_bm1368_set_chain_drive_strength_135(&f->device,
        f->setting, &f->read, writer, f, log) :
        vn135_bm1368_set_chip_drive_strength_135(&f->device, &f->chip,
            f->setting, &f->read, writer, f, log);
}

static void bit_and_failure_cases(void)
{
    static const uint32_t olds[] = {0, UINT32_MAX, 0xa5a5a5a5, 0x80000fff, 0x7654f321};
    static const uint32_t aliases[] = {0x10, 0x1000000a, 0x80000007, UINT32_MAX};
    static const int32_t failures[] = {-1, 1, -73, INT32_MIN, INT32_MAX};
    for (unsigned common = 0; common < 2; ++common) {
        for (size_t w = 0; w < sizeof olds / sizeof olds[0]; ++w)
            for (uint32_t setting = 0; setting < 16; ++setting) {
                struct fixture f; initialize(&f, common, olds[w], setting); ++cases;
                CHECK(invoke(&f, 0, 1) == 0);
                CHECK(strcmp(f.events, "RSC") == 0 && f.wrapper_logs == 0 && f.writer_logs == 0);
                const uint32_t expected = expected_value(olds[w], setting);
                CHECK(f.chains[0].common.entries[0].value == (common ? expected : olds[w]));
                for (unsigned chip = 0; chip < 8; ++chip)
                    CHECK(f.chips[0][chip].entries[0].value == (common || chip == 2 ? expected : olds[w]));
                CHECK(f.chains[1].common.entries[0].value == olds[w]);
            }
        for (size_t a = 0; a < sizeof aliases / sizeof aliases[0]; ++a) {
            struct fixture f; initialize(&f, common, 0xcafebabe, aliases[a]); ++cases;
            CHECK(invoke(&f, 0, 1) == 0 && f.sends == 1 && f.stores == 1);
        }
        for (size_t s = 0; s < sizeof failures / sizeof failures[0]; ++s) {
            struct fixture f; initialize(&f, common, 0xabcd1234, 5); ++cases;
            f.fail_read = 1; f.read_status = failures[s]; f.mutate_read = 1;
            CHECK(invoke(&f, 0, 0) == -1 && strcmp(f.events, "RL") == 0);
            CHECK(f.sends == 0 && f.stores == 0 && f.wrapper_logs == 1 && f.last_log_index == 0);
            initialize(&f, common, 0xabcd1234, 5); ++cases;
            f.fail_send = 1; f.send_status = failures[s];
            CHECK(invoke(&f, 0, 0) == -1 && strcmp(f.events, "RSWL") == 0);
            CHECK(f.stores == 0 && f.writer_logs == 1 && f.wrapper_logs == 1);
            initialize(&f, common, 0xabcd1234, 5); ++cases;
            f.fail_store = 1; f.store_status = failures[s];
            CHECK(invoke(&f, 0, 0) == -1 && strcmp(f.events, "RSCL") == 0);
            CHECK(f.sends == 1 && f.writer_logs == 0 && f.wrapper_logs == 1);
            CHECK(f.chips[0][2].entries[0].value == 0xabcd1234);
        }
        struct fixture f; initialize(&f, common, 0xfedcba98, 0x23); ++cases;
        f.omit_output = 1;
        CHECK(invoke(&f, 0, 1) == 0 && f.last_value == 0x3000);
        initialize(&f, common, 0xfedcba98, 2); ++cases;
        f.mutate_read = 1; f.mutate_send = 1;
        CHECK(invoke(&f, 0, 1) == 0 && f.setting == UINT32_MAX);
        CHECK(f.read_chain[0] == 0 && f.store_chain[0] == 1);
        CHECK(f.common || (f.read_chip[0] == 2 && f.store_chip[0] == 5 && f.sent[0][2] == 0xa7));
        CHECK(f.last_value == expected_value(0xfedcba98, 2));
        initialize(&f, common, 0xfedcba98, 2); ++cases;
        f.fail_send = 1; f.send_status = -9; f.mutate_send = 1;
        f.mutate_writer_log = 1; f.mutate_wrapper_log = 1;
        CHECK(invoke(&f, 0, 0) == -1 && f.last_log_index == 0 && f.device.index == 37);
        initialize(&f, common, 0xfedcba98, 2); ++cases;
        f.fail_store = 1; f.store_status = 7; f.mutate_store = 1;
        CHECK(invoke(&f, 0, 0) == -1 && f.last_log_index == 0);
        initialize(&f, common, 0, 2); ++cases;
        f.device.index = UINT32_MAX;
        CHECK(invoke(&f, 1, 0) == -1 && f.read_chain[0] == -1 && f.sends == 0);
        initialize(&f, common, 0x11111111, 2); ++cases;
        f.device.index = 1;
        f.chains[1].common.entries[0].value = 0xabcdef01;
        f.chips[1][2].entries[0].value = 0x76543210;
        CHECK(invoke(&f, 0, 1) == 0);
        CHECK(f.last_old == (common ? UINT32_C(0xabcdef01) : UINT32_C(0x76543210)));
    }
}

struct group_trace {
    struct vn135_bm1368_group_chain_135 *chain;
    struct vn135_bm1368_group_owner_135 *owner, *replacement;
    struct vn135_bm1368_group_board_135 *board, *replacement_board;
    struct vn135_bm1368_frequency_device *device;
    uintptr_t descriptor;
    unsigned calls, alternate_calls, mutation;
    int32_t fail_status;
    unsigned fail_at;
    int32_t indices[8];
    uint32_t addresses[8], settings[8];
};
static int32_t trace_alternate(void *, struct vn135_bm1368_frequency_device *, vn135_chip_reference *, uint32_t);
static int32_t trace_method(void *opaque, struct vn135_bm1368_frequency_device *device,
                            vn135_chip_reference *chip, uint32_t setting)
{
    struct group_trace *t = opaque;
    CHECK(device == t->device && t->calls < 8);
    if (!t->calls) t->descriptor = (uintptr_t)chip;
    CHECK(t->descriptor == (uintptr_t)chip);
    t->indices[t->calls] = chip->cache_index;
    t->addresses[t->calls] = chip->wire_address;
    t->settings[t->calls] = setting;
    ++t->calls;
    if (t->mutation && t->calls == 1) {
        t->board->enabled = 0; t->board->group_count = 100;
        t->board->chips_per_group = 3; t->board->address_stride = 5;
        t->board->drive_strength = 0x92;
        t->chain->owner = t->replacement; t->chain->device = NULL;
        t->owner->board = t->replacement_board;
        t->owner->configure = trace_alternate;
    } else if (t->mutation && t->calls == 2) {
        t->board->chips_per_group = 4; t->board->address_stride = 7;
        t->board->drive_strength = 255;
    }
    chip->cache_index = -777; chip->wire_address = 0xdeadbeef;
    return t->calls == t->fail_at ? t->fail_status : 0;
}
static int32_t trace_alternate(void *opaque, struct vn135_bm1368_frequency_device *device,
                               vn135_chip_reference *chip, uint32_t setting)
{
    struct group_trace *t = opaque; ++t->alternate_calls;
    return trace_method(opaque, device, chip, setting);
}

static void grouping_cases(void)
{
    struct vn135_bm1368_group_board_135 board = {4, 2, INT32_MAX, 0, 7};
    struct vn135_bm1368_group_owner_135 owner = {&board, NULL, NULL};
    struct vn135_bm1368_group_chain_135 chain = {&owner, NULL};
    ++cases; ++group_cases; CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == 0);
    static const int32_t skipped[] = {0, -1, INT32_MIN};
    for (unsigned i = 0; i < sizeof skipped / sizeof skipped[0]; ++i) {
        board.enabled = 0x80; board.group_count = skipped[i]; ++cases; ++group_cases;
        CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == 0);
    }
    static const int32_t statuses[] = {0, -1, 1, INT32_MIN, INT32_MAX};
    for (unsigned i = 0; i < sizeof statuses / sizeof statuses[0]; ++i) {
        struct vn135_bm1368_frequency_device device = {9};
        struct group_trace t = {0};
        board = (struct vn135_bm1368_group_board_135){4, 2, 4, 2, 0xab};
        owner = (struct vn135_bm1368_group_owner_135){&board, trace_method, &t};
        chain = (struct vn135_bm1368_group_chain_135){&owner, &device};
        t.device = &device; t.fail_at = statuses[i] ? 2u : 0u; t.fail_status = statuses[i];
        ++cases; ++group_cases;
        CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == (statuses[i] ? -1 : 0));
        CHECK(t.calls == (statuses[i] ? 2u : 4u));
        for (unsigned j = 0; j < t.calls; ++j) {
            CHECK(t.indices[j] == (int32_t)(7u - j * 2u));
            CHECK(t.addresses[j] == (7u - j * 2u) * 4u && t.settings[j] == 0xab);
        }
    }
    struct vn135_bm1368_frequency_device device = {0};
    struct vn135_bm1368_group_board_135 other_board = {19, 23, 91, 1, 57};
    struct vn135_bm1368_group_owner_135 other_owner = {&other_board, NULL, NULL};
    struct group_trace t = {0};
    board = (struct vn135_bm1368_group_board_135){4, 2, 3, 1, 4};
    owner = (struct vn135_bm1368_group_owner_135){&board, trace_method, &t};
    chain = (struct vn135_bm1368_group_chain_135){&owner, &device};
    t.chain = &chain; t.owner = &owner; t.replacement = &other_owner;
    t.board = &board; t.replacement_board = &other_board; t.device = &device; t.mutation = 1;
    ++cases; ++group_cases;
    CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == 0);
    CHECK(t.calls == 3 && t.alternate_calls == 2);
    CHECK(t.indices[0] == 5 && t.addresses[0] == 20 && t.settings[0] == 4);
    CHECK(t.indices[1] == 5 && t.addresses[1] == 25 && t.settings[1] == 0x92);
    CHECK(t.indices[2] == 3 && t.addresses[2] == 21 && t.settings[2] == 255);
    static const uint32_t sizes[] = {0, UINT32_MAX, 0x80000000};
    for (unsigned i = 0; i < sizeof sizes / sizeof sizes[0]; ++i) {
        memset(&t, 0, sizeof t); t.device = &device;
        board = (struct vn135_bm1368_group_board_135){UINT32_MAX, sizes[i], 2, 1, 1};
        owner = (struct vn135_bm1368_group_owner_135){&board, trace_method, &t};
        chain = (struct vn135_bm1368_group_chain_135){&owner, &device};
        ++cases; ++group_cases;
        CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == 0 && t.calls == 2);
        for (unsigned j = 0; j < 2; ++j) {
            const uint32_t index = sizes[i] * (2u - j) - 1u;
            CHECK(t.indices[j] == signed_word(index) && t.addresses[j] == index * UINT32_MAX);
        }
    }
    memset(&t, 0, sizeof t); t.device = &device; t.fail_at = 1; t.fail_status = 7;
    board = (struct vn135_bm1368_group_board_135){0, 0, INT32_MAX, 1, 1};
    owner = (struct vn135_bm1368_group_owner_135){&board, trace_method, &t};
    chain = (struct vn135_bm1368_group_chain_135){&owner, &device};
    ++cases; ++group_cases;
    CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == -1 && t.calls == 1);
    CHECK(t.indices[0] == -1 && t.addresses[0] == 0);
}

static void *allocate_frame(void *opaque, size_t n)
{
    struct fixture *f = opaque; CHECK(n == 11 && !f->allocated && !f->outer && !f->inner);
    f->allocated = 1; ++f->allocations; event(f, 'A'); return f->frame;
}
static void release_frame(void *opaque, void *ptr)
{
    struct fixture *f = opaque; CHECK(ptr == f->frame && f->allocated && !f->outer && !f->inner);
    f->allocated = 0; ++f->releases; event(f, 'F');
}
static void outer_lock(void *opaque)
{
    struct fixture *f = opaque; CHECK(f->allocated && !f->outer && !f->inner);
    f->outer = 1; event(f, 'O');
}
static void outer_unlock(void *opaque)
{
    struct fixture *f = opaque; CHECK(f->outer && !f->inner);
    f->outer = 0; event(f, 'X');
}
static void inner_lock(void *opaque)
{
    struct fixture *f = opaque; CHECK(f->outer && !f->inner);
    f->inner = 1; event(f, 'I');
}
static void inner_unlock(void *opaque)
{
    struct fixture *f = opaque; CHECK(f->outer && f->inner);
    f->inner = 0; event(f, 'U');
}
static int32_t record_write(void *opaque, int32_t fd, const uint8_t *data, uint32_t n)
{
    struct fixture *f = opaque;
    CHECK(fd == -71 && n == 11 && data == f->frame && f->outer && f->inner);
    CHECK(data[0] == 0x55 && data[1] == 0xaa);
    CHECK(memcmp(data + 2, f->sent[f->sends - 1], 9) == 0);
    ++f->writes; event(f, 'T');
    if (f->replay && f->writes == 1) { f->error_number = 11; return 2; }
    f->error_number = 5;
    if (f->sends == f->lower_failure_number) return f->short_write ? 2 : -73;
    return 11;
}
static int32_t *record_errno(void *opaque)
{
    struct fixture *f = opaque; CHECK(f->outer && !f->inner);
    ++f->errors; event(f, 'E'); return &f->error_number;
}
static void record_sleep(void *opaque, uint32_t ms)
{
    struct fixture *f = opaque; CHECK(ms == 20 && f->outer && !f->inner && f->error_number == 11);
    ++f->sleeps; event(f, 'D');
}
static void use_lower_transport(struct fixture *f)
{
    f->lower = 1; f->uart = (vn135_uart)VN135_UART_INITIALIZER; f->uart.fd = -71;
    f->uart_ops.context = f; f->uart_ops.write = record_write;
    f->uart_ops.error_number = record_errno; f->uart_ops.lock = inner_lock;
    f->uart_ops.unlock = inner_unlock; f->uart_ops.sleep_ms = record_sleep;
    f->framing = (vn135_aml_transport){f, allocate_frame, release_frame, outer_lock, outer_unlock, NULL};
    f->binding = (struct vn135_aml_uart_binding_135){&f->device, &f->uart, &f->framing, &f->uart_ops};
    f->transport = (struct vn135_transport_dispatch_135){vn135_aml_uart_send_135, &f->binding};
}
static int32_t composed_method(void *opaque, struct vn135_bm1368_frequency_device *device,
                               vn135_chip_reference *chip, uint32_t setting)
{
    struct fixture *f = opaque;
    f->active_chip = chip; f->saved_setting = setting;
    struct vn135_bm1368_group_binding_135 binding = {&f->read, &f->writer, f, &f->log};
    const int32_t result = vn135_bm1368_group_drive_strength_135(&binding, device, chip, setting);
    f->active_chip = NULL;
    return result;
}
static void composed_cases_run(void)
{
    /* Each failure is on the second group; the first group's effects remain. */
    for (unsigned failure = 0; failure < 5; ++failure) {
        struct fixture f; initialize(&f, 0, 0x12345678, 9); use_lower_transport(&f);
        if (failure == 1) { f.fail_read = 2; f.read_status = 7; }
        if (failure == 2) f.lower_failure_number = 2;
        if (failure == 3) { f.lower_failure_number = 2; f.short_write = 1; }
        if (failure == 4) { f.fail_store = 2; f.store_status = -3; }
        struct vn135_bm1368_group_board_135 board = {4, 2, 4, 1, 9};
        struct vn135_bm1368_group_owner_135 owner = {&board, composed_method, &f};
        struct vn135_bm1368_group_chain_135 chain = {&owner, &f.device};
        ++cases; ++composed_cases;
        CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == (failure ? -1 : 0));
        CHECK(f.reads == (failure ? 2u : 4u));
        CHECK(f.sends == (failure == 1 ? 1u : failure ? 2u : 4u));
        CHECK(f.allocations == f.sends && f.releases == f.sends && f.writes == f.sends);
        CHECK(!f.allocated && !f.outer && !f.inner && f.active_chip == NULL);
        CHECK(f.wrapper_logs == (unsigned)(failure != 0));
        CHECK(f.chains[0].common.entries[0].value == 0x12345678);
        for (unsigned chip = 0; chip < 8; ++chip) {
            const unsigned changed = chip == 7 || (!failure && (chip == 5 || chip == 3 || chip == 1));
            CHECK(f.chips[0][chip].entries[0].value == (changed ? expected_value(0x12345678, 9) : 0x12345678));
        }
    }
    for (unsigned common = 0; common < 2; ++common) {
        struct fixture f; initialize(&f, common, 0x12345678, 9); use_lower_transport(&f);
        f.replay = 1; ++cases; ++composed_cases;
        CHECK(invoke(&f, 0, 1) == 0);
        CHECK(f.reads == 1 && f.sends == 1 && f.stores == 1 && f.writes == 2);
        CHECK(f.allocations == 1 && f.releases == 1 && f.sleeps == 1 && f.errors == 1);
        CHECK(strcmp(f.events, "RSAOITUEDITUXFC") == 0);
    }
    /* Wrapped index bits are data to the real cache API, never an address. */
    struct fixture f; initialize(&f, 0, 0x12345678, 9); use_lower_transport(&f);
    struct vn135_bm1368_group_board_135 board = {UINT32_MAX, 0, 1, 1, 9};
    struct vn135_bm1368_group_owner_135 owner = {&board, composed_method, &f};
    struct vn135_bm1368_group_chain_135 chain = {&owner, &f.device};
    ++cases; ++composed_cases;
    CHECK(vn135_bm1368_configure_group_drive_strength_135(&chain) == -1);
    CHECK(f.read_chip[0] == -1 && f.reads == 1 && f.sends == 0 && f.stores == 0);
    CHECK(f.allocations == 0 && f.wrapper_logs == 1 && strcmp(f.events, "RL") == 0);
}

int main(void)
{
    crc_goldens(); bit_and_failure_cases(); grouping_cases(); composed_cases_run();
    printf("{\"cases\":%u,\"checks\":%u,\"group_cases\":%u,\"composed_cases\":%u}\n",
        cases, checks, group_cases, composed_cases);
    return 0;
}

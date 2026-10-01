/* Bounded host composition of the BM1368 ordinary SWEEP_CLOCK_CTRL method.
 * Oracle provenance: cgminer e32c0..e33c8 and hwscan f30d4..f3164 in
 * dizzass-next-sweep-gap/{cgminer,hwscan}-method-code.asm. Four literal words
 * come from cgminer AND/ORR and independently hwscan BFI at bit 1, width 2.
 * The second incoming argument is overwritten in both bodies. L11's lower
 * recording machinery is reused; expectations for this method are separate.
 * The forwarding linker observer checks exact writer arguments; it always
 * calls the separately compiled real writer and returns its actual status.
 * All lower logic is real; terminal callbacks only record or refuse bounded
 * frames. No firmware, OS I/O, hardware success, real wait or coordinator.
 */
#include "integration/bm1368_sweep_clock_135.h"
#include "integration/bm1368_ticket_mask_135.h"
#include "integration/bm1368_pulse_width_135.h"
#include "integration/transport_dispatch_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned cases, checks;
static const char *case_name;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr, "ORIGINAL_SWEEP_CLOCK_FAIL case=%u name=%s line=%d %s\n", \
        cases, case_name, __LINE__, #x); exit(1); } } while (0)

enum { CHAINS = 3, CHIPS = 3, FRAME = 11, EVENTS = 64 };
enum terminal_result { EXACT, REFUSE, SHORT, REPLAY };
struct fixture {
    struct vn135_bm1368_frequency_device device;
    struct vn135_bm1368_register_ops writer;
    struct vn135_bm1368_sweep_clock_log_135 log;
    struct vn135_transport_dispatch_135 dispatch;
    struct vn135_aml_uart_binding_135 binding;
    vn135_aml_transport framing;
    vn135_uart_ops uart_ops;
    vn135_uart uart;
    vn135_reg_cache cache;
    vn135_reg_chain chains[CHAINS];
    vn135_reg_table chips[CHAINS][CHIPS];
    vn135_reg_table before_common[CHAINS], before_chips[CHAINS][CHIPS];
    uint8_t frame_storage[FRAME + 2], expected[FRAME], copied[2][FRAME];
    char events[EVENTS];
    unsigned event_count, writer_calls, sends, selected_sends, cache_calls;
    unsigned allocations, releases, attempts, sleeps, errors, inner_logs, outer_logs;
    unsigned outer_locked, inner_locked, allocated;
    enum terminal_result terminal;
    unsigned fail_cache, mutate_send, mutate_cache, mutate_inner_log;
    uint32_t send_index, cache_index, inner_log_index;
    uint32_t expected_reg, expected_word, expected_inner_index, expected_outer_index;
    int32_t expected_chain, expected_status, error;
};

static void event(struct fixture *f, char value)
{
    CHECK(f->event_count + 1u < EVENTS);
    f->events[f->event_count++] = value;
    f->events[f->event_count] = '\0';
}

/* Literal oracle derived before reading the implementation. The repeated
 * four-output period follows both source bodies; high bits and original r1
 * have no influence. This is not the production expression copied into C. */
static uint32_t expected_sweep_word(uint32_t third)
{
    static const uint32_t words[4] = {
        UINT32_C(0x80008b00), UINT32_C(0x80008b02),
        UINT32_C(0x80008b04), UINT32_C(0x80008b06)
    };
    return words[third % 4u];
}

/* Independent polynomial long division for the accepted lower packet
 * contract: x^5+x^2+1, initial 0x1f, 64 message bits, no final XOR.
 * Does not call the encoder/CRC under test or repeat its feedback loop. */
static uint8_t expected_crc(const uint8_t bytes[8])
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
    for (unsigned bit = 0; bit < 5; ++bit)
        result |= (unsigned)dividend[bit] << bit;
    return (uint8_t)result;
}

static int register_slot(const vn135_reg_table *table, uint32_t reg)
{
    for (int slot = 0; slot < VN135_REG_CACHE_SLOTS; ++slot)
        if (table->entries[slot].address == reg) return slot;
    CHECK(0);
    return 0;
}

static void unlocked(const struct fixture *f)
{
    CHECK(!f->allocated && !f->outer_locked && !f->inner_locked);
}

static void *allocate_frame(void *opaque, size_t size)
{
    struct fixture *f = opaque;
    unlocked(f);
    CHECK(size == FRAME);
    event(f, 'A');
    f->allocated = 1;
    ++f->allocations;
    return f->frame_storage + 1;
}

static void release_frame(void *opaque, void *pointer)
{
    struct fixture *f = opaque;
    CHECK(f->allocated && !f->outer_locked && !f->inner_locked);
    CHECK(pointer == f->frame_storage + 1 && f->attempts > 0);
    event(f, 'R');
    f->allocated = 0;
    ++f->releases;
}

static void outer_lock(void *opaque)
{
    struct fixture *f = opaque;
    CHECK(f->allocated && !f->outer_locked && !f->inner_locked);
    event(f, 'O'); f->outer_locked = 1;
}
static void outer_unlock(void *opaque)
{
    struct fixture *f = opaque;
    CHECK(f->allocated && f->outer_locked && !f->inner_locked);
    event(f, 'P'); f->outer_locked = 0;
}
static void inner_lock(void *opaque)
{
    struct fixture *f = opaque;
    CHECK(f->allocated && f->outer_locked && !f->inner_locked);
    event(f, 'I'); f->inner_locked = 1;
}
static void inner_unlock(void *opaque)
{
    struct fixture *f = opaque;
    CHECK(f->allocated && f->outer_locked && f->inner_locked);
    event(f, 'J'); f->inner_locked = 0;
}

static int32_t record_terminal(void *opaque, int32_t fd,
    const uint8_t *bytes, uint32_t length)
{
    struct fixture *f = opaque;
    CHECK(fd == -71 && length == FRAME);
    CHECK(f->allocated && f->outer_locked && f->inner_locked);
    CHECK(bytes == f->frame_storage + 1);
    CHECK(memcmp(bytes, f->expected, FRAME) == 0 && f->attempts < 2);
    memcpy(f->copied[f->attempts], bytes, FRAME);
    event(f, 'T');
    ++f->attempts;
    if (f->mutate_send) f->device.index = f->send_index;
    if (f->terminal == REFUSE) return -55;
    if (f->terminal == SHORT || (f->terminal == REPLAY && f->attempts == 1))
        return 5;
    return FRAME; /* Recorded host acceptance only; no device exists. */
}

static int32_t *record_errno(void *opaque)
{
    struct fixture *f = opaque;
    CHECK(f->allocated && f->outer_locked && !f->inner_locked);
    event(f, 'E'); ++f->errors;
    return &f->error;
}

static void record_sleep(void *opaque, uint32_t milliseconds)
{
    struct fixture *f = opaque;
    CHECK(f->allocated && f->outer_locked && !f->inner_locked);
    CHECK(f->terminal == REPLAY && milliseconds == 20 && f->attempts == 1);
    event(f, 'H'); ++f->sleeps; /* No OS wait. */
}

static int32_t forbidden_frame_write(void *opaque, void *uart,
    const uint8_t *bytes, uint32_t length)
{
    (void)opaque; (void)uart; (void)bytes; (void)length;
    CHECK(0); return -1;
}

static int32_t selected_send(void *opaque, void *device,
    const uint8_t *bytes, uint32_t length)
{
    struct fixture *f = opaque;
    unlocked(f);
    CHECK(device == &f->device && length == 9);
    CHECK(memcmp(bytes, f->expected + 2, 9) == 0);
    event(f, 'D'); ++f->selected_sends;
    return vn135_aml_uart_send_135(&f->binding, device, bytes, length);
}

static int32_t register_send(void *opaque,
    struct vn135_bm1368_frequency_device *device,
    const uint8_t *bytes, size_t length)
{
    struct fixture *f = opaque;
    CHECK(device == &f->device && length == 9);
    CHECK(memcmp(bytes, f->expected + 2, 9) == 0);
    event(f, 'S'); ++f->sends;
    return vn135_transport_send_135(&f->dispatch, device, bytes, (uint32_t)length);
}

static int32_t cache_chain(void *opaque, int32_t chain,
    uint32_t reg, uint32_t value)
{
    struct fixture *f = opaque;
    unlocked(f);
    CHECK(chain == f->expected_chain && reg == f->expected_reg && value == f->expected_word);
    CHECK(f->releases == 1 && f->attempts >= 1);
    event(f, 'C'); ++f->cache_calls;
    /* A supported disabled-cache refusal after dispatch. Storage remains
     * bounded, owned, fully valid, and unchanged by the failing setter. */
    if (f->fail_cache) f->cache.initialized = 0;
    int32_t status = vn135_bm1368_register_cache_chain_135(&f->cache,
        chain, reg, value);
    f->cache.initialized = 1;
    CHECK(status == (f->fail_cache ? -1 : 0));
    if (f->mutate_cache) f->device.index = f->cache_index;
    return status;
}

static int32_t forbidden_cache_chip(void *opaque, int32_t chain,
    int32_t chip, uint32_t reg, uint32_t value)
{
    (void)opaque; (void)chain; (void)chip; (void)reg; (void)value;
    CHECK(0); return -1;
}

static void register_log(void *opaque, uint32_t line, uint32_t index)
{
    struct fixture *f = opaque;
    unlocked(f);
    CHECK(line == 350 && index == f->expected_inner_index);
    CHECK(f->terminal == REFUSE || f->terminal == SHORT);
    CHECK(f->cache_calls == 0);
    event(f, 'L'); ++f->inner_logs;
    if (f->mutate_inner_log) f->device.index = f->inner_log_index;
}

static void sweep_log(void *opaque,
    const struct vn135_bm1368_sweep_clock_diagnostic_135 *diagnostic)
{
    struct fixture *f = opaque;
    unlocked(f);
    CHECK(diagnostic->line == 463 && diagnostic->severity == 1);
    CHECK(strcmp(diagnostic->module, "driver") == 0);
    CHECK(strcmp(diagnostic->source, "/tmp/build/libbitmain/src/chip/chip1368.c") == 0);
    CHECK(strcmp(diagnostic->function, "[redacted]") == 0);
    CHECK(strcmp(diagnostic->format, "chain#%d - failed to set SWEEP_CLOCK_CTRL") == 0);
    CHECK(diagnostic->index_bits == f->expected_outer_index);
    CHECK(f->expected_status == -1);
    event(f, 'X'); ++f->outer_logs;
    /* No borrowed pointer is retained. */
}

int32_t __real_vn135_bm1368_write_register_135(
    struct vn135_bm1368_frequency_device *, uint32_t,
    const vn135_chip_reference *, uint32_t, uint32_t,
    const struct vn135_bm1368_register_ops *, void *);
int32_t __wrap_vn135_bm1368_write_register_135(
    struct vn135_bm1368_frequency_device *device, uint32_t mode,
    const vn135_chip_reference *chip, uint32_t reg, uint32_t value,
    const struct vn135_bm1368_register_ops *writer, void *opaque)
{
    struct fixture *f = opaque;
    CHECK(device == &f->device && writer == &f->writer);
    CHECK(mode == 1 && chip == NULL && reg == f->expected_reg && value == f->expected_word);
    event(f, 'W'); ++f->writer_calls;
    return __real_vn135_bm1368_write_register_135(device, mode, chip,
        reg, value, writer, opaque);
}

static void initialize(struct fixture *f)
{
    memset(f, 0, sizeof *f);
    f->device.index = 1;
    f->expected_chain = 1;
    f->expected_inner_index = f->expected_outer_index = 2;
    f->error = 5;
    f->frame_storage[0] = 0xa5;
    f->frame_storage[FRAME + 1] = 0x5a;
    f->cache.chains = f->chains;
    f->cache.chain_count = CHAINS;
    f->cache.initialized = 1;
    for (int chain = 0; chain < CHAINS; ++chain) {
        CHECK(vn135_reg_cache_defaults(4, &f->chains[chain].common) == 0);
        f->chains[chain].chips = f->chips[chain];
        f->chains[chain].chip_count = CHIPS;
        for (int chip = 0; chip < CHIPS; ++chip)
            f->chips[chain][chip] = f->chains[chain].common;
        CHECK(vn135_reg_cache_set_chain(&f->cache, chain, 0x14,
            UINT32_C(0x12345600) + (uint32_t)chain) == 0);
        CHECK(vn135_reg_cache_set_chain(&f->cache, chain, 0x3c,
            UINT32_C(0x98765400) + (uint32_t)chain) == 0);
        for (int chip = 0; chip < CHIPS; ++chip) {
            CHECK(vn135_reg_cache_set_chip(&f->cache, chain, chip, 0x14,
                UINT32_C(0xabcdef00) + (uint32_t)chain * 16u + (uint32_t)chip) == 0);
            CHECK(vn135_reg_cache_set_chip(&f->cache, chain, chip, 0x3c,
                UINT32_C(0xfedcba00) + (uint32_t)chain * 16u + (uint32_t)chip) == 0);
        }
    }
    f->writer = (struct vn135_bm1368_register_ops){
        register_send, cache_chain, forbidden_cache_chip, register_log};
    f->log = (struct vn135_bm1368_sweep_clock_log_135){f, sweep_log};
    f->dispatch = (struct vn135_transport_dispatch_135){selected_send, f};
    f->framing = (vn135_aml_transport){f, allocate_frame, release_frame,
        outer_lock, outer_unlock, forbidden_frame_write};
    f->uart = (vn135_uart)VN135_UART_INITIALIZER;
    f->uart.fd = -71;
    f->uart_ops.context = f;
    f->uart_ops.write = record_terminal;
    f->uart_ops.error_number = record_errno;
    f->uart_ops.lock = inner_lock;
    f->uart_ops.unlock = inner_unlock;
    f->uart_ops.sleep_ms = record_sleep;
    f->binding = (struct vn135_aml_uart_binding_135){
        &f->device, &f->uart, &f->framing, &f->uart_ops};
}

static void verify_cache(struct fixture *f)
{
    for (int chain = 0; chain < CHAINS; ++chain) {
        vn135_reg_table common = f->before_common[chain];
        unsigned updated = (unsigned)(f->expected_status == 0 && chain == f->expected_chain);
        if (updated) common.entries[register_slot(&common, f->expected_reg)].value = f->expected_word;
        CHECK(memcmp(&f->chains[chain].common, &common, sizeof common) == 0);
        for (int chip = 0; chip < CHIPS; ++chip) {
            vn135_reg_table expected = f->before_chips[chain][chip];
            if (updated) expected.entries[register_slot(&expected, f->expected_reg)].value = f->expected_word;
            CHECK(memcmp(&f->chips[chain][chip], &expected, sizeof expected) == 0);
        }
        CHECK(f->chains[chain].chips == f->chips[chain]);
        CHECK(f->chains[chain].chip_count == CHIPS);
    }
    CHECK(f->cache.chains == f->chains && f->cache.chain_count == CHAINS);
    CHECK(f->cache.initialized == 1);
}

static void prepare(struct fixture *f, const char *name, uint32_t reg, uint32_t word)
{
    case_name = name;
    ++cases;
    f->expected_reg = reg;
    f->expected_word = word;
    const uint8_t header[FRAME] = {0x55, 0xaa, 0x51, 9, 0, 0, 0, 0, 0, 0, 0};
    memcpy(f->expected, header, FRAME);
    f->expected[5] = (uint8_t)reg;
    f->expected[6] = (uint8_t)(word >> 24);
    f->expected[7] = (uint8_t)(word >> 16);
    f->expected[8] = (uint8_t)(word >> 8);
    f->expected[9] = (uint8_t)word;
    f->expected[10] = expected_crc(f->expected + 2);
    for (int chain = 0; chain < CHAINS; ++chain)
        f->before_common[chain] = f->chains[chain].common;
    memcpy(f->before_chips, f->chips, sizeof f->chips);
}

static void verify(struct fixture *f, int32_t result)
{
    CHECK(result == f->expected_status);
    unsigned send_failed = (unsigned)(f->terminal == REFUSE || f->terminal == SHORT);
    CHECK(f->writer_calls == 1 && f->sends == 1 && f->selected_sends == 1);
    CHECK(f->allocations == 1 && f->releases == 1);
    CHECK(f->cache_calls == 1u - send_failed);
    CHECK(f->inner_logs == send_failed);
    CHECK(f->outer_logs == (unsigned)(f->expected_status != 0));
    CHECK(f->attempts == (f->terminal == REPLAY ? 2u : 1u));
    CHECK(f->sleeps == (unsigned)(f->terminal == REPLAY));
    CHECK(f->errors == (unsigned)(f->terminal != EXACT));
    CHECK(memcmp(f->copied[0], f->expected, FRAME) == 0);
    if (f->terminal == REPLAY) CHECK(memcmp(f->copied[0], f->copied[1], FRAME) == 0);
    const char *trace = send_failed ? "WSDAOITJEPRLX" :
        f->fail_cache ? "WSDAOITJPRCX" :
        f->terminal == REPLAY ? "WSDAOITJEHITJPRC" : "WSDAOITJPRC";
    CHECK(strcmp(f->events, trace) == 0);
    CHECK(f->frame_storage[0] == 0xa5 && f->frame_storage[FRAME + 1] == 0x5a);
    unlocked(f);
    verify_cache(f);
}

static void run_sweep(struct fixture *f, const char *name,
    uint32_t ignored_second, uint32_t third)
{
    prepare(f, name, 0x3c, expected_sweep_word(third));
    int32_t result = vn135_bm1368_set_sweep_clock_135(&f->device,
        ignored_second, third, &f->writer, f, f->expected_status == 0 ? NULL : &f->log);
    verify(f, result);
}

static void four_values_and_invariance(void)
{
    for (uint32_t field = 0; field < 4; ++field) {
        struct fixture f; initialize(&f);
        run_sweep(&f, "four-low-bit-values", 0, field);
    }
    static const uint32_t high[] = {
        UINT32_C(0x00000004), UINT32_C(0x80000001),
        UINT32_C(0xfffffffe), UINT32_MAX
    };
    for (unsigned i = 0; i < sizeof high / sizeof high[0]; ++i) {
        struct fixture f; initialize(&f);
        run_sweep(&f, "selected-high-bits-ignored", 0, high[i]);
    }
    static const uint32_t ignored[] = {1u, UINT32_C(0x12345678), UINT32_MAX};
    for (unsigned i = 0; i < sizeof ignored / sizeof ignored[0]; ++i) {
        struct fixture f; initialize(&f);
        run_sweep(&f, "second-argument-ignored", ignored[i], 2);
    }
}

static void focused_failures_and_mutations(void)
{
    struct fixture f;
    initialize(&f); f.terminal = REFUSE; f.expected_status = -1;
    run_sweep(&f, "terminal-refusal", 0, 0);

    initialize(&f); f.terminal = SHORT; f.expected_status = -1;
    run_sweep(&f, "positive-short-refusal", 0, 1);

    initialize(&f); f.fail_cache = 1; f.expected_status = -1;
    run_sweep(&f, "cache-refusal-after-dispatch", 0, 2);

    initialize(&f); f.mutate_send = 1; f.send_index = 2; f.expected_chain = 2;
    run_sweep(&f, "cache-chain-reloaded-after-send", 0, 3);

    initialize(&f); f.terminal = REFUSE; f.expected_status = -1;
    f.mutate_send = 1; f.send_index = 7;
    f.expected_inner_index = f.expected_outer_index = 8;
    run_sweep(&f, "fresh-index-after-send-refusal", UINT32_MAX, 1);

    initialize(&f); f.fail_cache = 1; f.expected_status = -1;
    f.mutate_cache = 1; f.cache_index = 11; f.expected_outer_index = 12;
    run_sweep(&f, "fresh-index-after-cache-refusal", UINT32_MAX, 2);

    initialize(&f); f.terminal = SHORT; f.expected_status = -1;
    f.mutate_send = 1; f.send_index = 2; f.expected_inner_index = 3;
    f.mutate_inner_log = 1; f.inner_log_index = 17; f.expected_outer_index = 18;
    run_sweep(&f, "fresh-index-after-inner-log", UINT32_MAX, 3);

    initialize(&f); f.terminal = REFUSE; f.expected_status = -1;
    f.mutate_send = 1; f.send_index = UINT32_MAX;
    f.expected_inner_index = f.expected_outer_index = 0;
    run_sweep(&f, "both-diagnostic-indices-wrap", 0, 0);

    initialize(&f); f.terminal = REFUSE; f.expected_status = -1;
    f.mutate_inner_log = 1; f.inner_log_index = UINT32_MAX; f.expected_outer_index = 0;
    run_sweep(&f, "outer-index-wrap-after-inner-log", 0, 1);

    initialize(&f); f.fail_cache = 1; f.expected_status = -1;
    f.mutate_cache = 1; f.cache_index = INT32_MAX;
    f.expected_outer_index = UINT32_C(0x80000000);
    run_sweep(&f, "signed-diagnostic-argument-bits", 0, 2);

    initialize(&f); f.terminal = REPLAY; f.error = VN135_UART_EAGAIN;
    run_sweep(&f, "one-bounded-whole-frame-eagain-replay", 0, 3);
}

static void clear_observations(struct fixture *f)
{
    unlocked(f);
    f->event_count = f->writer_calls = f->sends = f->selected_sends = f->cache_calls = 0;
    f->allocations = f->releases = f->attempts = f->sleeps = f->errors = 0;
    f->inner_logs = f->outer_logs = 0;
    f->events[0] = '\0';
}

static uint32_t chain_value(struct fixture *f, uint32_t reg)
{
    uint32_t value = 0;
    CHECK(vn135_reg_cache_get_chain(&f->cache, 1, reg, &value) == 0);
    return value;
}

/* Selected-method subsequence only, ordered as static coordinator call sites
 * 56034 (sweep), 5620c (optional pulse), 562c4 (ticket). Cache state is carried
 * across all three real methods; no absent operations/conditions are supplied.
 * The startup sweep passes third=0 and writes the FULL 0x80008b00 to reg 0x3c.
 * Pulse(3,5) then replaces it with 0x800080e8 from its accepted contract, rather
 * than merging sweep fields. Ticket(0x96) reverses the low byte to 0x69 in reg
 * 0x14 and preserves 0x3c. This is not an execution of the startup caller. */
static void shared_register_subsequence(void)
{
    struct fixture f;
    initialize(&f);
    const struct vn135_bm1368_pulse_ops pulse_ops = {
        vn135_bm1368_pulse_register_135, NULL};
    struct vn135_bm1368_pulse_binding pulse_binding = {&f.writer, &f};
    run_sweep(&f, "subsequence-startup-sweep-field-zero", UINT32_C(0x76543210), 0);
    CHECK(chain_value(&f, 0x3c) == UINT32_C(0x80008b00));
    CHECK(chain_value(&f, 0x14) == UINT32_C(0x12345601));

    clear_observations(&f);
    prepare(&f, "subsequence-existing-pulse-overwrites-sweep", 0x3c, UINT32_C(0x800080e8));
    verify(&f, vn135_bm1368_set_pulse_width_135(&f.device, 3, 5, UINT32_MAX,
        &pulse_ops, &pulse_binding));
    CHECK(chain_value(&f, 0x3c) == UINT32_C(0x800080e8));
    CHECK(chain_value(&f, 0x14) == UINT32_C(0x12345601));

    clear_observations(&f);
    prepare(&f, "subsequence-existing-ticket-mask", 0x14, UINT32_C(0x69));
    verify(&f, vn135_bm1368_set_ticket_mask_135(&f.device, UINT32_C(0x96),
        &f.writer, &f, NULL));
    CHECK(chain_value(&f, 0x3c) == UINT32_C(0x800080e8));
    CHECK(chain_value(&f, 0x14) == UINT32_C(0x69));
}

int main(void)
{
    case_name = "setup";
    four_values_and_invariance();
    focused_failures_and_mutations();
    shared_register_subsequence();
    printf("ORIGINAL_SWEEP_CLOCK_PASS cases=%u checks=%u hardware=no real_waits=no "
        "coordinator=not-implemented\n", cases, checks);
    return 0;
}

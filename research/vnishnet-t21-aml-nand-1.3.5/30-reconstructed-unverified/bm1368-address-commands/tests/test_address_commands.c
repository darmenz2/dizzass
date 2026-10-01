/* Host-only contract fixture. Expected bodies and diagnostics derive from raw
 * e47b8/e48fc and f3bcc/f3c74 proof, not the reconstructed wrapper's output.
 * The concluding sequence follows the witnessed INACTIVE -> SET_ADDRESS order
 * and ignored statuses at 55b00/55b30. It is not a recovered coordinator,
 * firmware execution, address readback, physical I/O, or hardware proof. */
#include "integration/bm1368_address_commands_135.h"
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned checks, cases, wire_cases, alias_cases, lower_cases;
#define CHECK(x) do { ++checks; if (!(x)) { \
    fprintf(stderr, "ADDRESS_COMMANDS_FAIL line=%d %s\n", __LINE__, #x); \
    exit(1); \
} } while (0)

enum command { INACTIVE, SET_ADDRESS, READ_REGISTER };

/* Independent polynomial division: x^5+x^2+1, initial 1f, MSB first,
 * no final XOR. This does not call the production CRC recurrence. */
static uint8_t crc_division(const uint8_t bytes[4])
{
    uint32_t word = ((uint32_t)bytes[0] << 24) | ((uint32_t)bytes[1] << 16) |
                    ((uint32_t)bytes[2] << 8) | bytes[3];
    uint64_t remainder = ((uint64_t)word << 5) ^ (UINT64_C(31) << 32);
    for (int bit = 36; bit >= 5; --bit)
        if (remainder & (UINT64_C(1) << (unsigned)bit))
            remainder ^= UINT64_C(0x25) << (unsigned)(bit - 5);
    return (uint8_t)remainder;
}

static void expected_body(uint8_t out[5], enum command command, uint32_t address)
{
    /* READ_REGISTER below uses broadcast mode 3 and register 0x18. */
    out[0] = command == INACTIVE ? 0x53 : command == SET_ADDRESS ? 0x40 : 0x52;
    out[1] = 5;
    out[2] = command == INACTIVE ? 0 : (uint8_t)(address % 256u);
    out[3] = command == READ_REGISTER ? 0x18 : 0;
    out[4] = crc_division(out);
}

static void address_diagnostic(const struct vn135_bm1368_address_diagnostic_135 *d,
                               enum command command, uint32_t index, uint32_t wire)
{
    CHECK(command == INACTIVE || command == SET_ADDRESS);
    CHECK(strcmp(d->module, "driver") == 0);
    CHECK(strcmp(d->source_path, "/tmp/build/libbitmain/src/chip/chip1368.c") == 0);
    CHECK(strcmp(d->function, "[redacted]") == 0);
    CHECK(strcmp(d->format, command == INACTIVE ?
        "chain#%d - failed to inactivate the chain" :
        "chain#%d - failed to assign chip address to 0x%02x") == 0);
    CHECK(d->source_line == (command == INACTIVE ? 669u : 699u));
    CHECK(d->severity == 1 && d->index_bits == index + UINT32_C(1));
    CHECK(d->has_wire_address == (unsigned)(command == SET_ADDRESS));
    CHECK(d->wire_address_bits == (command == SET_ADDRESS ? wire : 0));
}

static int32_t invoke(enum command command,
    const struct vn135_common_read_device_135 *device, const vn135_chip_reference *chip,
    const struct vn135_transport_dispatch_135 *transport,
    const struct vn135_bm1368_address_log_135 *log)
{
    CHECK(command == INACTIVE || command == SET_ADDRESS);
    return command == INACTIVE ? vn135_bm1368_inactivate_135(device, transport, log) :
        vn135_bm1368_assign_address_135(device, chip, transport, log);
}

struct direct {
    enum command command;
    void *identity;
    uint32_t *index;
    vn135_chip_reference *chip;
    uint8_t expected[5], copied[5];
    int32_t status;
    unsigned sends, logs, mutate_send, mutate_log;
    uint32_t index_after_send, wire_after_send;
};

static int32_t direct_send(void *opaque, void *identity, const uint8_t *body, uint32_t n)
{
    struct direct *d = opaque;
    CHECK(d->sends == 0 && d->logs == 0);
    CHECK(identity == d->identity && n == 5);
    CHECK(memcmp(body, d->expected, 5) == 0);
    memcpy(d->copied, body, 5);
    ++d->sends;
    if (d->mutate_send) {
        *d->index = d->index_after_send;
        d->chip->wire_address = d->wire_after_send;
    }
    return d->status;
}

static void direct_log(void *opaque, const struct vn135_bm1368_address_diagnostic_135 *log)
{
    struct direct *d = opaque;
    CHECK(d->sends == 1 && d->logs == 0 && d->status != 0);
    address_diagnostic(log, d->command, *d->index, d->chip->wire_address);
    ++d->logs;
    if (d->mutate_log) {
        *d->index = UINT32_C(0xdeadbeef);
        d->chip->wire_address = UINT32_C(0x789abcde);
        /* The diagnostic is a pre-callback snapshot, not a field alias. */
        CHECK(log->index_bits == d->index_after_send + UINT32_C(1));
        CHECK(log->wire_address_bits ==
              (d->command == SET_ADDRESS ? d->wire_after_send : 0));
    }
}

static void run_direct(enum command command, uint32_t wire, uint32_t index,
                       int32_t status, unsigned mutate_send, unsigned mutate_log)
{
    vn135_chip_reference chip = {INT32_MIN, wire};
    struct direct d = {0};
    d.command = command; d.identity = &chip; d.index = &index; d.chip = &chip;
    d.status = status; d.mutate_send = mutate_send; d.mutate_log = mutate_log;
    d.index_after_send = UINT32_MAX; d.wire_after_send = UINT32_C(0xabcde109);
    expected_body(d.expected, command, wire);
    struct vn135_common_read_device_135 device = {d.identity, &index};
    struct vn135_transport_dispatch_135 transport = {direct_send, &d};
    struct vn135_bm1368_address_log_135 log = {direct_log, &d};
    uint32_t entry_index = index;
    ++cases;
    CHECK(invoke(command, &device, &chip, &transport, &log) == (status == 0 ? 0 : -1));
    CHECK(d.sends == 1 && d.logs == (unsigned)(status != 0));
    CHECK(memcmp(d.copied, d.expected, 5) == 0);
    CHECK(index == (mutate_log ? UINT32_C(0xdeadbeef) :
                   mutate_send ? d.index_after_send : entry_index));
    CHECK(chip.wire_address == (mutate_log ? UINT32_C(0x789abcde) :
                               mutate_send ? d.wire_after_send : wire));
    CHECK(chip.cache_index == INT32_MIN);
}

static void golden_vectors(void)
{
    static const uint8_t vectors[][5] = {
        {0x53, 5, 0, 0, 3}, {0x40, 5, 0, 0, 0x1c},
        {0x40, 5, 1, 0, 0}, {0x40, 5, 0x80, 0, 0x10},
        {0x40, 5, 0xff, 0, 3}, {0x52, 5, 0x5a, 0x18, 0x0e}
    };
    for (size_t i = 0; i < sizeof vectors / sizeof vectors[0]; ++i) {
        uint8_t body[5];
        expected_body(body, i == 0 ? INACTIVE : i == 5 ? READ_REGISTER : SET_ADDRESS,
                      vectors[i][2]);
        ++cases;
        CHECK(memcmp(body, vectors[i], 5) == 0);
    }
}

static void bounded_direct_cases(void)
{
    /* Exhaust the one-byte wire field once, without a Cartesian product. */
    for (uint32_t address = 0; address < 256; ++address) {
        run_direct(SET_ADDRESS, address, 73, 0, 0, 0);
        ++wire_cases;
    }
    static const uint32_t aliases[] = {
        0x100, 0x101, 0x1ff, 0x80000000u, 0x80000080u,
        0xffffff00u, 0x1234565au, UINT32_MAX
    };
    for (size_t i = 0; i < sizeof aliases / sizeof aliases[0]; ++i) {
        run_direct(SET_ADDRESS, aliases[i], 12, -9, 0, 0);
        ++alias_cases;
    }
    static const int32_t statuses[] = {0, 1, -1, -73, INT32_MAX, INT32_MIN};
    static const uint32_t indices[] = {17, 0, UINT32_MAX, 0x7fffffffu, 0x80000000u, 0xfffffffeu};
    for (unsigned command = 0; command < 2; ++command) {
        for (size_t i = 0; i < sizeof statuses / sizeof statuses[0]; ++i)
            run_direct((enum command)command, UINT32_C(0x12345678), indices[i], statuses[i], 0, 0);
        run_direct((enum command)command, UINT32_C(0x100a5), 91, 0, 1, 0);
        run_direct((enum command)command, UINT32_C(0x100a5), 91, -3, 1, 0);
        run_direct((enum command)command, UINT32_C(0x100a5), 91, 23, 1, 1);
    }
}

static void success_without_diagnostics(void)
{
    /* Real absent diagnostic-only storage, never invalid pointer sentinels.
     * direct_send explicitly accepts either a valid or NULL opaque identity. */
    for (unsigned command = 0; command < 2; ++command)
        for (unsigned null_identity = 0; null_identity < 2; ++null_identity) {
            uint32_t identity = 41;
            vn135_chip_reference chip = {-4, UINT32_C(0xfeedbe80)};
            struct direct d = {0};
            d.command = (enum command)command;
            d.identity = null_identity ? NULL : &identity;
            expected_body(d.expected, d.command, chip.wire_address);
            struct vn135_common_read_device_135 device = {d.identity, NULL};
            struct vn135_transport_dispatch_135 transport = {direct_send, &d};
            ++cases;
            CHECK(invoke(d.command, &device, &chip, &transport, NULL) == 0);
            CHECK(d.sends == 1 && d.logs == 0 && chip.cache_index == -4);
            CHECK(chip.wire_address == UINT32_C(0xfeedbe80));
        }
}

struct replacement {
    struct vn135_transport_dispatch_135 *transport;
    struct direct *current, *next;
};
static int32_t replace_next(void *opaque, void *identity, const uint8_t *body, uint32_t n)
{
    struct replacement *r = opaque;
    r->transport->send_payload = direct_send;
    r->transport->context = r->next;
    return direct_send(r->current, identity, body, n);
}
static void next_invocation_dispatch(void)
{
    uint32_t index = 4;
    vn135_chip_reference chip = {19, UINT32_C(0x100f0)};
    struct direct first = {0}, next = {0};
    first.command = INACTIVE; next.command = SET_ADDRESS;
    first.identity = next.identity = &chip;
    first.index = next.index = &index; first.chip = next.chip = &chip;
    first.status = -10;
    expected_body(first.expected, INACTIVE, chip.wire_address);
    expected_body(next.expected, SET_ADDRESS, chip.wire_address);
    struct vn135_transport_dispatch_135 transport = {0};
    struct replacement replacement = {&transport, &first, &next};
    transport.send_payload = replace_next; transport.context = &replacement;
    struct vn135_common_read_device_135 device = {&chip, &index};
    struct vn135_bm1368_address_log_135 log = {direct_log, &first};
    ++cases;
    CHECK(vn135_bm1368_inactivate_135(&device, &transport, &log) == -1);
    CHECK(first.sends == 1 && first.logs == 1 && next.sends == 0);
    CHECK(vn135_bm1368_assign_address_135(&device, &chip, &transport, NULL) == 0);
    CHECK(first.sends == 1 && next.sends == 1 && next.logs == 0);
}

struct scenario {
    const char *name;
    int32_t write_results[5];
    int32_t error_values[5];
    unsigned attempts, sleeps, errors;
    int32_t result;
};
static const struct scenario scenarios[] = {
    {"exact write", {7}, {5}, 1, 0, 0, 0},
    {"positive short", {2}, {5}, 1, 0, 1, -1},
    {"negative write", {-55}, {5}, 1, 0, 1, -1},
    {"zero write", {0}, {5}, 1, 0, 1, -1},
    {"negative EAGAIN exhaustion", {-11,-11,-11,-11,-11}, {11,11,11,11,11}, 5, 5, 1, -1},
    {"short EAGAIN recovery", {2,7}, {11,11}, 2, 1, 1, 0},
    {"cached errno changes", {-11,-55}, {11,5}, 2, 1, 1, -1},
    {"short EAGAIN exhaustion", {2,2,2,2,2}, {11,11,11,11,11}, 5, 5, 1, -1}
};

struct lower {
    uint32_t index;
    vn135_chip_reference *chip;
    enum command command;
    const struct scenario *scenario;
    struct { uint8_t before, frame[7], after; } owned;
    uint8_t expected[7];
    char events[96];
    unsigned event_count, sends, logs, allocations, releases;
    unsigned outer_locked, inner_locked, outer_locks, outer_unlocks;
    unsigned inner_locks, inner_unlocks, writes, errors, sleeps;
    int32_t error;
    struct vn135_aml_uart_binding_135 binding;
};

static void event(struct lower *l, char value)
{
    CHECK(l->event_count + 1 < sizeof l->events);
    l->events[l->event_count++] = value; l->events[l->event_count] = 0;
}
static void *allocate_frame(void *opaque, size_t n)
{
    struct lower *l = opaque;
    CHECK(n == 7 && l->allocations == 0 && l->sends == 1);
    CHECK(!l->outer_locked && !l->inner_locked);
    ++l->allocations; event(l, 'A'); return l->owned.frame;
}
static void release_frame(void *opaque, void *pointer)
{
    struct lower *l = opaque;
    CHECK(pointer == l->owned.frame && l->releases == 0 && l->allocations == 1);
    CHECK(!l->outer_locked && !l->inner_locked && l->outer_unlocks == 1);
    CHECK(l->writes == l->scenario->attempts);
    ++l->releases; event(l, 'F');
}
static void outer_lock(void *opaque)
{
    struct lower *l = opaque;
    CHECK(!l->outer_locked && !l->inner_locked && l->allocations == 1);
    CHECK(memcmp(l->owned.frame, l->expected, 7) == 0);
    l->outer_locked = 1; ++l->outer_locks; event(l, 'O');
}
static void outer_unlock(void *opaque)
{
    struct lower *l = opaque;
    CHECK(l->outer_locked && !l->inner_locked && l->releases == 0);
    l->outer_locked = 0; ++l->outer_unlocks; event(l, 'X');
}
static void inner_lock(void *opaque)
{
    struct lower *l = opaque;
    CHECK(l->outer_locked && !l->inner_locked);
    l->inner_locked = 1; ++l->inner_locks; event(l, 'I');
}
static void inner_unlock(void *opaque)
{
    struct lower *l = opaque;
    CHECK(l->outer_locked && l->inner_locked);
    l->inner_locked = 0; ++l->inner_unlocks; event(l, 'U');
}
static int32_t os_write(void *opaque, int32_t fd, const uint8_t *bytes, uint32_t n)
{
    struct lower *l = opaque;
    CHECK(fd == -71 && l->outer_locked && l->inner_locked && n == 7);
    CHECK(l->writes < l->scenario->attempts && l->writes < 5);
    CHECK(bytes == l->owned.frame && memcmp(bytes, l->expected, 7) == 0);
    unsigned attempt = l->writes++;
    event(l, 'W');
    /* Mutation in the actual lower OS callback must not re-encode retries. */
    l->index = UINT32_MAX - attempt;
    l->chip->wire_address = UINT32_C(0xabcde100) + attempt;
    l->error = l->scenario->error_values[attempt];
    return l->scenario->write_results[attempt];
}
static int32_t *error_number(void *opaque)
{
    struct lower *l = opaque;
    CHECK(l->outer_locked && !l->inner_locked && l->writes == 1 && l->errors == 0);
    ++l->errors; event(l, 'E'); return &l->error;
}
static void record_sleep(void *opaque, uint32_t ms)
{
    struct lower *l = opaque;
    CHECK(ms == 20 && l->outer_locked && !l->inner_locked && l->error == VN135_UART_EAGAIN);
    ++l->sleeps; event(l, 'T');
}
static int32_t forbidden_framing_write(void *opaque, void *uart, const uint8_t *bytes, uint32_t n)
{
    (void)opaque; (void)uart; (void)bytes; (void)n;
    CHECK(0); return -1;
}
static int32_t selected_send(void *opaque, void *identity, const uint8_t *body, uint32_t n)
{
    struct lower *l = opaque;
    CHECK(l->sends == 0 && l->logs == 0 && n == 5 && identity == l);
    CHECK(identity == l->binding.device_identity && memcmp(body, l->expected + 2, 5) == 0);
    ++l->sends; event(l, 'S');
    return vn135_aml_uart_send_135(&l->binding, identity, body, n);
}
static void lower_address_log(void *opaque, const struct vn135_bm1368_address_diagnostic_135 *d)
{
    struct lower *l = opaque;
    CHECK(l->sends == 1 && l->logs == 0 && l->releases == 1);
    CHECK(!l->outer_locked && !l->inner_locked && l->scenario->result == -1);
    address_diagnostic(d, l->command, l->index, l->chip->wire_address);
    ++l->logs; event(l, 'L');
}
static void lower_read_log(void *opaque, const struct vn135_common_read_diagnostic_135 *d)
{
    struct lower *l = opaque;
    CHECK(l->command == READ_REGISTER && l->sends == 1 && l->logs == 0 && l->releases == 1);
    CHECK(!l->outer_locked && !l->inner_locked && l->scenario->result == -1);
    CHECK(strcmp(d->module, "driver") == 0 && strcmp(d->function, "[redacted]") == 0);
    CHECK(strcmp(d->source_path, "/tmp/build/libbitmain/src/chip/chip.c") == 0);
    CHECK(strcmp(d->format, "chain#%d - failed to send GET_STATUS command") == 0);
    CHECK(d->source_line == 103 && d->severity == 1 && d->index_bits == l->index + UINT32_C(1));
    ++l->logs; event(l, 'L');
}

static void check_event_order(const struct lower *l)
{
    char expected[96] = "SAO";
    for (unsigned attempt = 0; attempt < l->scenario->attempts; ++attempt) {
        strcat(expected, "IWU");
        if (attempt == 0 && l->scenario->errors) strcat(expected, "E");
        if (attempt < l->scenario->sleeps) strcat(expected, "T");
    }
    strcat(expected, l->scenario->result == 0 ? "XF" : "XFL");
    CHECK(strcmp(l->events, expected) == 0);
}

static void run_lower(struct lower *l, const struct vn135_common_read_device_135 *device,
                      vn135_chip_reference *chip, enum command command, unsigned scenario)
{
    /* Reuse owned storage and the same typed identity/index between calls. */
    uint32_t index = l->index;
    memset(l, 0, sizeof *l);
    l->index = index; l->chip = chip; l->command = command;
    CHECK(scenario < sizeof scenarios / sizeof scenarios[0]);
    l->scenario = &scenarios[scenario];
    l->owned.before = 0xa5; l->owned.after = 0x5a;
    l->expected[0] = 0x55; l->expected[1] = 0xaa;
    expected_body(l->expected + 2, command, chip->wire_address);
    vn135_uart uart = VN135_UART_INITIALIZER; uart.fd = -71;
    vn135_aml_transport framing = {l, allocate_frame, release_frame, outer_lock,
                                   outer_unlock, forbidden_framing_write};
    vn135_uart_ops uart_ops = {0};
    uart_ops.context = l; uart_ops.write = os_write;
    uart_ops.lock = inner_lock; uart_ops.unlock = inner_unlock;
    uart_ops.error_number = error_number; uart_ops.sleep_ms = record_sleep;
    l->binding = (struct vn135_aml_uart_binding_135){l, &uart, &framing, &uart_ops};
    struct vn135_transport_dispatch_135 transport = {selected_send, l};
    struct vn135_bm1368_address_log_135 log = {lower_address_log, l};
    struct vn135_common_read_log_135 read_log = {lower_read_log, l};
    int32_t cache_index = chip->cache_index;
    ++cases; ++lower_cases;
    int32_t result = command == READ_REGISTER ?
        vn135_common_read_register_135(device, 3, chip, 0x18, &transport, &read_log) :
        invoke(command, device, chip, &transport, &log);
    CHECK(result == l->scenario->result);
    CHECK(l->sends == 1 && l->logs == (unsigned)(result != 0));
    CHECK(l->writes == l->scenario->attempts && l->errors == l->scenario->errors);
    CHECK(l->sleeps == l->scenario->sleeps && l->allocations == 1 && l->releases == 1);
    CHECK(l->outer_locks == 1 && l->outer_unlocks == 1 && !l->outer_locked && !l->inner_locked);
    CHECK(l->inner_locks == l->writes && l->inner_unlocks == l->writes);
    CHECK(l->owned.before == 0xa5 && l->owned.after == 0x5a);
    CHECK(memcmp(l->owned.frame, l->expected, 7) == 0 && chip->cache_index == cache_index);
    CHECK(l->index == UINT32_MAX - (l->writes - 1u));
    CHECK(chip->wire_address == UINT32_C(0xabcde100) + l->writes - 1u);
    check_event_order(l);
}

static void actual_transport_cases(void)
{
    for (unsigned command = 0; command < 2; ++command)
        for (unsigned scenario = 0; scenario < sizeof scenarios / sizeof scenarios[0]; ++scenario) {
            struct lower lower = {0}; lower.index = 42;
            struct vn135_common_read_device_135 device = {&lower, &lower.index};
            vn135_chip_reference chip = {-99, UINT32_C(0x123456a5)};
            run_lower(&lower, &device, &chip, (enum command)command, scenario);
        }
}

static void host_sequence_fixture(void)
{
    struct lower lower = {0}; lower.index = 7;
    struct vn135_common_read_device_135 device = {&lower, &lower.index};
    vn135_chip_reference chips[] = {{91, 0}, {-4, 0x5a}, {INT32_MAX, 0x100b4}};
    /* The observed inline caller ignores each command status. Continue after
     * INACTIVE failure and after a SET_ADDRESS failure. Delays, chip spacing,
     * count/reload rules and software address calculation are not reconstructed. */
    run_lower(&lower, &device, &chips[0], INACTIVE, 2);
    chips[0].wire_address = 0;
    run_lower(&lower, &device, &chips[0], SET_ADDRESS, 0);
    run_lower(&lower, &device, &chips[1], SET_ADDRESS, 1);
    run_lower(&lower, &device, &chips[2], SET_ADDRESS, 5);
    /* Actual common READ_REGISTER reuses the same typed identity/index and
     * the current chip word after the lower callback changed it. This is host
     * composition, not a claim of immediate readback in the original caller. */
    run_lower(&lower, &device, &chips[2], READ_REGISTER, 2);
    run_lower(&lower, &device, &chips[2], READ_REGISTER, 0);
    CHECK(chips[0].cache_index == 91 && chips[1].cache_index == -4 && chips[2].cache_index == INT32_MAX);
    puts("HOST_SEQUENCE_FIXTURE_PASS inactive_then_set_address=3 common_read_register=2");
}

int main(void)
{
    golden_vectors(); bounded_direct_cases(); success_without_diagnostics();
    next_invocation_dispatch(); actual_transport_cases(); host_sequence_fixture();
    printf("ADDRESS_COMMANDS_PASS cases=%u wire_bytes=%u high_word_aliases=%u lower_calls=%u checks=%u\n",
           cases, wire_cases, alias_cases, lower_cases, checks);
    return 0;
}

/* Deterministic byte-write scripts. No device, clock, sleep or thread syscall. */
#include "integration/native/uart_safe.h"
#include "xminer/recovery/chip1398.h"
#include "xminer/recovery/aml_chip.h"
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static unsigned scenarios, checks;
#define CHECK(x) do { ++checks; if (!(x)) { fprintf(stderr, "UART_SAFE_ASSERT line=%d %s\n", __LINE__, #x); exit(1); } } while (0)
enum kind { CLOCK, WRITE, WAIT };
struct event {
    enum kind kind;
    uint64_t time;
    ptrdiff_t count;
    size_t offset;
    int error;
};
struct fixture {
    uint8_t guarded[13], original[13], accepted[11];
    size_t used, next, accepted_count;
    uint64_t deadline;
    struct event events[128];
};
static void init(struct fixture *f)
{
    uint8_t payload[9];
    memset(f, 0, sizeof(*f));
    memset(f->guarded, 0xa5, sizeof(f->guarded));
    /* Existing, original-checked SET_CONFIG encoder + AML framing; no new CRC.
     * Reusing a packet encoder is not a claim of T21 -> chip1398 dispatch. */
    CHECK(vn135_bm1398_set_config_packet(1, 0, 0x54, 0x12345678, payload, sizeof(payload)) == 0);
    CHECK(vn135_aml_frame_command(payload, sizeof(payload), f->guarded + 1, 11) == 0);
    memcpy(f->original, f->guarded, sizeof(f->guarded));
    f->deadline = 100;
}
static void add(struct fixture *f, struct event e)
{
    CHECK(f->used < sizeof(f->events) / sizeof(f->events[0]));
    f->events[f->used++] = e;
}
static void clock_event(struct fixture *f, uint64_t time, int error)
{ add(f, (struct event){.kind=CLOCK, .time=time, .error=error}); }
static void write_event(struct fixture *f, size_t offset, ptrdiff_t count, int error)
{ add(f, (struct event){.kind=WRITE, .offset=offset, .count=count, .error=error}); }
static void wait_event(struct fixture *f, int error)
{ add(f, (struct event){.kind=WAIT, .error=error}); }
static struct event next(struct fixture *f, enum kind kind)
{
    CHECK(f->next < f->used);
    CHECK(f->events[f->next].kind == kind);
    return f->events[f->next++];
}
static int clock_cb(void *opaque, uint64_t *time)
{
    struct event e = next(opaque, CLOCK);
    *time = e.time;
    return e.error;
}
static struct dizzass_uart_attempt write_cb(void *opaque, const uint8_t *data, size_t size)
{
    struct fixture *f = opaque;
    struct event e = next(f, WRITE);
    CHECK(data == f->guarded + 1 + e.offset);
    CHECK(size == 11 - e.offset);
    CHECK(e.offset == f->accepted_count);
    if (e.count > 0 && (size_t)e.count <= size) {
        CHECK(f->accepted_count + (size_t)e.count <= sizeof(f->accepted));
        memcpy(f->accepted + f->accepted_count, data, (size_t)e.count);
        f->accepted_count += (size_t)e.count;
        CHECK(memcmp(f->accepted, f->original + 1, f->accepted_count) == 0);
    }
    /* Deliberately unrelated ambient errno; only the result struct is valid. */
    errno = ENOSPC;
    return (struct dizzass_uart_attempt){e.count, e.error};
}
static int wait_cb(void *opaque, uint64_t deadline)
{
    struct fixture *f = opaque;
    struct event e = next(f, WAIT);
    CHECK(deadline == f->deadline);
    errno = EBADF;
    return e.error;
}
static struct dizzass_uart_io io(struct fixture *f)
{ return (struct dizzass_uart_io){f, write_cb, clock_cb, wait_cb}; }
static void run(struct fixture *f, unsigned budget, enum dizzass_uart_status status,
    size_t written, int error)
{
    struct dizzass_uart_io ops = io(f);
    struct dizzass_uart_result r = dizzass_uart_write_all(&ops, f->guarded + 1,
        11, f->deadline, budget);
    CHECK(r.status == status && r.written == written && r.error == error);
    CHECK(f->next == f->used); /* Includes exact numbers/order of all calls. */
    CHECK(f->accepted_count == written);
    CHECK(memcmp(f->accepted, f->original + 1, written) == 0);
    CHECK(memcmp(f->guarded, f->original, sizeof(f->original)) == 0);
    ++scenarios;
}
static void all_partitions(void)
{
    unsigned mask, mode;
    for (mask = 0; mask < 1024; ++mask)
        for (mode = 0; mode < 4; ++mode) {
            struct fixture f;
            unsigned start = 0, end;
            init(&f); clock_event(&f, 1, 0);
            for (end = 1; end <= 11; ++end) {
                if (end != 11 && !(mask & (1u << (end - 1))))
                    continue;
                if (mode == 1) {
                    write_event(&f, start, -1, EINTR); clock_event(&f, 1, 0);
                } else if (mode == 2) {
                    write_event(&f, start, -1, start & 1u ? EAGAIN : EWOULDBLOCK);
                    clock_event(&f, 1, 0); wait_event(&f, 0); clock_event(&f, 1, 0);
                } else if (mode == 3) {
                    write_event(&f, start, 0, ECANCELED); clock_event(&f, 1, 0);
                    wait_event(&f, EINTR); clock_event(&f, 1, 0);
                    wait_event(&f, 0); clock_event(&f, 1, 0);
                }
                write_event(&f, start, (ptrdiff_t)(end - start), start & 1u ? EINTR : EAGAIN);
                clock_event(&f, 1, 0);
                start = end;
            }
            run(&f, 4, DIZZASS_UART_OK, 11, 0);
        }
}
static void faults(void)
{
    struct fixture f;
    unsigned progress, i;
    const int fatal[] = {EIO, EPIPE, EBADF, ENOSPC, ECANCELED};
    for (progress = 0; progress <= 1; ++progress) {
        for (i = 0; i < sizeof(fatal)/sizeof(fatal[0]); ++i) {
            init(&f); clock_event(&f, 1, 0);
            if (progress) { write_event(&f, 0, 3, EAGAIN); clock_event(&f, 2, 0); }
            write_event(&f, progress * 3, -1, fatal[i]);
            run(&f, 4, fatal[i] == ECANCELED ? DIZZASS_UART_CANCELED : DIZZASS_UART_WRITE_ERROR,
                progress * 3, fatal[i]);
        }
        const int wait_errors[] = {EIO, ECANCELED, ETIMEDOUT, EAGAIN, -1};
        for (i = 0; i < sizeof(wait_errors)/sizeof(wait_errors[0]); ++i) {
            int error = wait_errors[i];
            init(&f); clock_event(&f, 1, 0);
            if (progress) { write_event(&f, 0, 3, 0); clock_event(&f, 2, 0); }
            write_event(&f, progress * 3, -1, EAGAIN); clock_event(&f, 3, 0);
            wait_event(&f, error);
            run(&f, 4, error < 0 ? DIZZASS_UART_INVALID_CALLBACK :
                error == ECANCELED ? DIZZASS_UART_CANCELED :
                error == ETIMEDOUT ? DIZZASS_UART_TIMEOUT : DIZZASS_UART_WAIT_ERROR,
                progress * 3, error < 0 ? EPROTO : error);
        }
        const int clock_errors[] = {EIO, ECANCELED, -1};
        for (i = 0; i < sizeof(clock_errors)/sizeof(clock_errors[0]); ++i) {
            int error = clock_errors[i];
            init(&f);
            if (progress) { clock_event(&f, 1, 0); write_event(&f, 0, 3, 0); }
            clock_event(&f, 2, error);
            run(&f, 4, error < 0 ? DIZZASS_UART_INVALID_CALLBACK :
                error == ECANCELED ? DIZZASS_UART_CANCELED : DIZZASS_UART_CLOCK_ERROR,
                progress * 3, error < 0 ? EPROTO : error);
        }
        const ptrdiff_t counts[] = {-2, -1, -1, 12, PTRDIFF_MAX};
        const int errors[] = {EIO, 0, -EIO, 0, EAGAIN};
        for (i = 0; i < sizeof(counts)/sizeof(counts[0]); ++i) {
            init(&f); clock_event(&f, 1, 0);
            if (progress) { write_event(&f, 0, 3, 0); clock_event(&f, 2, 0); }
            write_event(&f, progress * 3, counts[i], errors[i]);
            run(&f, 4, DIZZASS_UART_INVALID_CALLBACK, progress * 3, EPROTO);
        }
    }
}
static void bounded_progress(void)
{
    struct fixture f;
    unsigned mode, i;
    for (mode = 0; mode < 3; ++mode) {
        int error = mode == 0 ? 0 : mode == 1 ? EINTR : EAGAIN;
        init(&f); clock_event(&f, 1, 0);
        write_event(&f, 0, 2, 0); clock_event(&f, 1, 0);
        for (i = 0; i < 3; ++i) {
            write_event(&f, 2, error ? -1 : 0, error); clock_event(&f, 1, 0);
            if (i < 2 && error != EINTR) { wait_event(&f, 0); clock_event(&f, 1, 0); }
        }
        run(&f, 3, DIZZASS_UART_NO_PROGRESS, 2, error);
    }
    init(&f); clock_event(&f, 1, 0);
    write_event(&f, 0, -1, EAGAIN); clock_event(&f, 1, 0);
    wait_event(&f, EINTR); clock_event(&f, 1, 0);
    wait_event(&f, EINTR); clock_event(&f, 1, 0);
    run(&f, 3, DIZZASS_UART_NO_PROGRESS, 0, EINTR);

    /* A positive write resets the budget; readiness alone does not (above). */
    init(&f); clock_event(&f, 1, 0);
    write_event(&f, 0, -1, EINTR); clock_event(&f, 1, 0);
    write_event(&f, 0, 1, ECANCELED); clock_event(&f, 1, 0);
    write_event(&f, 1, -1, EINTR); clock_event(&f, 1, 0);
    write_event(&f, 1, 10, EINTR); clock_event(&f, 1, 0);
    run(&f, 2, DIZZASS_UART_OK, 11, 0);

    init(&f); clock_event(&f, 1, 0);
    write_event(&f, 0, 0, EAGAIN); clock_event(&f, 1, 0);
    run(&f, 1, DIZZASS_UART_NO_PROGRESS, 0, 0);
}
static void deadlines(void)
{
    struct fixture f;
    unsigned full;
    init(&f); clock_event(&f, 100, 0); run(&f, 3, DIZZASS_UART_TIMEOUT, 0, ETIMEDOUT);
    init(&f); f.deadline = 0; clock_event(&f, 0, 0); run(&f, 3, DIZZASS_UART_TIMEOUT, 0, ETIMEDOUT);
    for (full = 0; full < 2; ++full) {
        init(&f); clock_event(&f, 1, 0); write_event(&f, 0, full ? 11 : 3, 0);
        clock_event(&f, 100, 0); run(&f, 3, DIZZASS_UART_TIMEOUT, full ? 11 : 3, ETIMEDOUT);
    }
    init(&f); f.deadline = 10; clock_event(&f, 1, 0);
    write_event(&f, 0, 3, EAGAIN); clock_event(&f, 2, 0);
    write_event(&f, 3, -1, EINTR); clock_event(&f, 3, 0);
    write_event(&f, 3, -1, EAGAIN); clock_event(&f, 4, 0);
    wait_event(&f, 0); clock_event(&f, 5, 0);
    write_event(&f, 3, 2, 0); clock_event(&f, 6, 0);
    write_event(&f, 5, -1, EINTR); clock_event(&f, 7, 0);
    write_event(&f, 5, -1, EAGAIN); clock_event(&f, 8, 0);
    wait_event(&f, EINTR); clock_event(&f, 9, 0);
    wait_event(&f, 0); clock_event(&f, 10, 0);
    run(&f, 4, DIZZASS_UART_TIMEOUT, 5, ETIMEDOUT);

    init(&f); clock_event(&f, 1, 0); write_event(&f, 0, -1, EINTR);
    clock_event(&f, 100, 0); run(&f, 1, DIZZASS_UART_TIMEOUT, 0, ETIMEDOUT);
    init(&f); clock_event(&f, 7, 0); write_event(&f, 0, 3, 0);
    clock_event(&f, 6, 0); run(&f, 3, DIZZASS_UART_CLOCK_ERROR, 3, EPROTO);

    init(&f); f.deadline = UINT64_MAX; clock_event(&f, UINT64_MAX - 2, 0);
    write_event(&f, 0, 3, EAGAIN); clock_event(&f, UINT64_MAX - 1, 0);
    write_event(&f, 3, 8, 0); clock_event(&f, UINT64_MAX - 1, 0);
    run(&f, UINT_MAX, DIZZASS_UART_OK, 11, 0);
    init(&f); f.deadline = UINT64_MAX; clock_event(&f, UINT64_MAX - 1, 0);
    write_event(&f, 0, 3, 0); clock_event(&f, UINT64_MAX, 0);
    run(&f, 3, DIZZASS_UART_TIMEOUT, 3, ETIMEDOUT);
    init(&f); f.deadline = UINT64_MAX; clock_event(&f, UINT64_MAX - 1, 0);
    write_event(&f, 0, 3, 0); clock_event(&f, 0, 0);
    run(&f, 3, DIZZASS_UART_CLOCK_ERROR, 3, EPROTO);
}
static void inputs(void)
{
    struct fixture f;
    struct dizzass_uart_io ops, bad;
    struct dizzass_uart_result r;
    init(&f); ops = io(&f);
#define INVALID(io_, data_, length_, budget_, error_) do { \
    r = dizzass_uart_write_all(io_, data_, length_, 100, budget_); \
    CHECK(r.status == DIZZASS_UART_INVALID_INPUT && r.written == 0 && r.error == error_); \
    CHECK(f.next == 0); ++scenarios; } while (0)
    INVALID(NULL, f.guarded + 1, 11, 3, EINVAL);
    INVALID(&ops, NULL, 11, 3, EINVAL);
    INVALID(&ops, f.guarded + 1, 11, 0, EINVAL);
    INVALID(&ops, f.guarded + 1, (size_t)PTRDIFF_MAX + 1, 3, EOVERFLOW);
    INVALID(&ops, f.guarded + 1, SIZE_MAX, 3, EOVERFLOW);
    bad = ops; bad.write = NULL; INVALID(&bad, f.guarded + 1, 11, 3, EINVAL);
    bad = ops; bad.clock = NULL; INVALID(&bad, f.guarded + 1, 11, 3, EINVAL);
    bad = ops; bad.wait = NULL; INVALID(&bad, f.guarded + 1, 11, 3, EINVAL);
    r = dizzass_uart_write_all(NULL, NULL, 0, 0, 0);
    CHECK(r.status == DIZZASS_UART_OK && !r.written && !r.error); ++scenarios;
    r = dizzass_uart_write_all(&ops, f.guarded + 1, 0, 0, 0);
    CHECK(r.status == DIZZASS_UART_OK && !r.written && !r.error && !f.next); ++scenarios;
}
int main(void)
{
    inputs(); faults(); bounded_progress(); deadlines(); all_partitions();
    printf("UART_SAFE_PASS scenarios=%u checks=%u all_11byte_partitions=1024 modes=4 hardware_io=0\n", scenarios, checks);
    return 0;
}

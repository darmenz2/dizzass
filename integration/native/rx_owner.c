/* GPL-3.0-or-later. Single owner of existing parser/inbox; no second miner. */
#define _DEFAULT_SOURCE
#define _POSIX_C_SOURCE 200809L
#include "integration/native/rx_owner.h"
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <pthread.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <sys/eventfd.h>
#include <termios.h>
#include <unistd.h>

struct dizzass_rx_owner {
    struct dizzass_rx_owner_config config;
    struct dizzass_early_rx *inbox;
    vn135_work_rx_stream stream;
    struct dizzass_rx_owner_report report;
    pthread_t thread;
    atomic_bool stop, finished;
    int wake_fd;
    bool started, joined; /* Single controller only; never read by worker. */
};
static int fail(struct dizzass_rx_owner *o, enum dizzass_rx_exit reason, int detail)
{
    o->report.reason = reason; o->report.detail = detail;
    return -1;
}
static bool stopping(const struct dizzass_rx_owner *o)
{ return atomic_load_explicit(&o->stop, memory_order_acquire); }
static int emit(struct dizzass_rx_owner *o, struct dizzass_rx_event *event)
{
    event->epoch = o->config.received_epoch;
    ++o->report.callback_calls;
    int e = o->config.event(o->config.context, event);
    return e ? fail(o, DIZZASS_RX_CALLBACK_ERROR, e) : 0;
}
static bool admission_rejection(int e)
{
    return e == DIZZASS_JOBS_EMPTY || e == DIZZASS_JOBS_PAUSED ||
        e == DIZZASS_JOBS_QUARANTINED || e == DIZZASS_JOBS_OLD_EPOCH ||
        e == DIZZASS_JOBS_STALE_TICKET || e == DIZZASS_JOBS_WRONG_CHAIN ||
        e == DIZZASS_NONCE_WRONG_FORMAT || e == DIZZASS_NONCE_WRONG_VERSION;
}
static int dispatch(struct dizzass_rx_owner *o, unsigned *budget, bool *backoff)
{
    while (*budget && !*backoff && !stopping(o)) {
        struct dizzass_rx_event e = {.kind = DIZZASS_RX_DISPATCHED};
        int rc = dizzass_early_rx_dispatch(o->inbox, o->config.submitter, &e.submission);
        if (rc == DIZZASS_EARLY_RX_EMPTY || rc == DIZZASS_EARLY_RX_WAITING) return 0;
        if (rc == DIZZASS_NONCE_PARTIAL_COPY) {
            ++o->report.copy_retries; *backoff = true; return 0;
        }
        if (rc) return fail(o, DIZZASS_RX_INBOX_ERROR, rc);
        --*budget; ++o->report.dispatched;
        e.status = e.submission.job_status; e.reply = e.submission.reply;
        /* A completed native attempt gets its receipt even if stop raced it. */
        if (emit(o, &e)) return -1;
    }
    return 0;
}
static int message(struct dizzass_rx_owner *o, int kind, const vn135_work_rx_message *m)
{
    struct dizzass_rx_event e = {0};
    if (kind == VN135_RX_NEED_MORE) return 0;
    if (kind == VN135_RX_DISCARDED) { o->report.noise_bytes += m->consumed; return 0; }
    if (kind == VN135_RX_REGISTER || kind == VN135_RX_REGISTER_FILTERED) {
        ++o->report.register_frames; e.kind = DIZZASS_RX_REGISTER; e.message = *m;
        return emit(o, &e);
    }
    if (kind != VN135_RX_NONCE_RAW) return fail(o, DIZZASS_RX_PARSE_ERROR, kind);
    ++o->report.nonce_frames;
    int rc = dizzass_nonce_decode_payload(o->stream.policy.chip_selector,
        o->stream.policy.variant, m->chain_id, m->payload, m->payload_size, &e.reply);
    if (rc) return fail(o, DIZZASS_RX_PARSE_ERROR, rc);
    rc = dizzass_early_rx_offer(o->inbox, o->config.received_epoch, &e.reply);
    if (rc && !admission_rejection(rc)) return fail(o, DIZZASS_RX_INBOX_ERROR, rc);
    e.status = rc;
    if (rc) { ++o->report.rejected; e.kind = DIZZASS_RX_REJECTED; }
    else { ++o->report.offered; e.kind = DIZZASS_RX_QUEUED; }
    return emit(o, &e);
}
static void *receive_loop(void *arg)
{
    struct dizzass_rx_owner *o = arg;
    int error = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, NULL);
    if (error) { fail(o, DIZZASS_RX_INTERNAL_ERROR, error); goto done; }
    /* This owner uses cooperative stop only; no cancellation in native code. */
    while (!stopping(o)) {
        unsigned budget = 64;
        bool backoff = false;
        if (dispatch(o, &budget, &backoff) || stopping(o)) break;
        struct pollfd p[2] = {{o->wake_fd, POLLIN, 0},
            {backoff ? -1 : o->config.fd, POLLIN, 0}};
        int wait_ms = !budget && dizzass_early_rx_size(o->inbox) ? 0 : (int)o->config.poll_ms;
        ++o->report.poll_calls;
        int ready = poll(p, 2, wait_ms);
        error = errno;
        if (stopping(o)) break;
        if (ready < 0) {
            if (error == EINTR) continue;
            fail(o, DIZZASS_RX_IO_ERROR, error); break;
        }
        if (p[0].revents & (POLLERR | POLLHUP | POLLNVAL)) {
            fail(o, DIZZASS_RX_INTERNAL_ERROR, EIO); break;
        }
        if (p[0].revents & POLLIN) {
            uint64_t count;
            ssize_t n = read(o->wake_fd, &count, sizeof count);
            error = errno;
            if (n == sizeof count) ++o->report.wake_reads;
            else if (n >= 0 || (error != EAGAIN && error != EINTR)) {
                fail(o, DIZZASS_RX_INTERNAL_ERROR, n >= 0 ? EPROTO : error); break;
            }
        }
        if (stopping(o)) break;
        if (backoff) continue; /* No hot retry on a perpetually readable UART. */
        /* Fail closed on hangup; this is explicitly NOT a final device drain. */
        if (p[1].revents & (POLLERR | POLLHUP | POLLNVAL)) {
            fail(o, DIZZASS_RX_IO_ERROR, (p[1].revents & POLLNVAL) ? EBADF : EIO); break;
        }
        if (!(p[1].revents & POLLIN)) continue;
        uint8_t bytes[256];
        ++o->report.read_calls;
        ssize_t n = read(o->config.fd, bytes, sizeof bytes);
        error = errno;
        if (n < 0 && (error == EINTR || error == EAGAIN || error == EWOULDBLOCK)) continue;
        if (n <= 0 || (size_t)n > sizeof bytes) {
            fail(o, DIZZASS_RX_IO_ERROR, n < 0 ? error : n == 0 ? EPIPE : EPROTO); break;
        }
        o->report.bytes_read += (size_t)n;
        o->report.unprocessed_batch_bytes = (size_t)n;
        size_t position = 0;
        bool failed = false;
        while (position < (size_t)n && !stopping(o)) {
            vn135_work_rx_message m;
            size_t used = 0;
            int kind = vn135_work_rx_stream_feed(&o->stream, bytes + position,
                (size_t)n - position, &used, &m);
            if (kind < 0 || !used || used > (size_t)n - position) {
                fail(o, DIZZASS_RX_PARSE_ERROR, kind < 0 ? kind : EPROTO); failed = true; break;
            }
            position += used; o->report.unprocessed_batch_bytes -= used;
            if (message(o, kind, &m) || dispatch(o, &budget, &backoff)) { failed = true; break; }
        }
        if (failed) break;
    }
done:
    o->report.pending_replies = dizzass_early_rx_size(o->inbox);
    o->report.partial_frame_bytes = o->stream.used;
    (void)dizzass_early_rx_stop(o->inbox);
    atomic_store_explicit(&o->finished, true, memory_order_release);
    return NULL;
}
static int validate_fd(int fd)
{
    int flags = fcntl(fd, F_GETFL);
    if (flags < 0) return errno;
    if ((flags & O_ACCMODE) == O_WRONLY || !(flags & O_NONBLOCK)) return EINVAL;
    struct termios t;
    if (tcgetattr(fd, &t)) return errno;
    if ((t.c_iflag & (IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON|IXOFF|IXANY|INPCK|IGNPAR)) ||
        (t.c_lflag & (ECHO|ECHONL|ICANON|ISIG|IEXTEN)) || (t.c_oflag & OPOST) ||
        (t.c_cflag & (CSIZE|PARENB)) != CS8 || !(t.c_cflag & CREAD) ||
        t.c_cc[VMIN] != 1 || t.c_cc[VTIME] != 0) return EINVAL;
    return 0;
}
int dizzass_rx_owner_create(const struct dizzass_rx_owner_config *c,
    struct dizzass_rx_owner **out)
{
    if (!c || !out || *out || !c->jobs || !c->submitter || !c->event ||
        !c->received_epoch || !c->poll_ms || c->poll_ms > 1000 ||
        !c->inbox_capacity || c->inbox_capacity > DIZZASS_EARLY_RX_MAX_CAPACITY ||
        c->board_selector > 4 || c->chip_selector > 8 || c->special_mode > 1) return EINVAL;
    int e = validate_fd(c->fd);
    if (e) return e;
    struct dizzass_rx_owner *o = calloc(1, sizeof *o);
    if (!o) return ENOMEM;
    o->config = *c; atomic_init(&o->stop, false); atomic_init(&o->finished, false);
    e = dizzass_early_rx_create(c->jobs, c->chain_id, c->received_epoch, c->inbox_capacity, &o->inbox);
    if (e) { free(o); return e; }
    e = vn135_work_rx_stream_init(&o->stream, c->chain_id, c->board_selector, c->chip_selector, c->special_mode);
    if (e) { dizzass_early_rx_destroy(&o->inbox); free(o); return e; }
    o->wake_fd = eventfd(0, EFD_NONBLOCK | EFD_CLOEXEC);
    if (o->wake_fd < 0) { e = errno; dizzass_early_rx_destroy(&o->inbox); free(o); return e; }
    *out = o;
    return 0;
}
int dizzass_rx_owner_start(struct dizzass_rx_owner *o)
{
    if (!o) return EINVAL;
    if (o->started) return EALREADY;
    if (stopping(o)) return ECANCELED;
    int e = pthread_create(&o->thread, NULL, receive_loop, o);
    if (!e) o->started = true;
    return e;
}
int dizzass_rx_owner_notify(struct dizzass_rx_owner *o)
{
    if (!o) return EINVAL;
    uint64_t one = 1;
    ssize_t n = write(o->wake_fd, &one, sizeof one);
    int e = errno;
    if (n == sizeof one || (n < 0 && e == EAGAIN)) return 0;
    return n < 0 ? e : EPROTO;
}
int dizzass_rx_owner_request_stop(struct dizzass_rx_owner *o)
{
    if (!o) return EINVAL;
    atomic_store_explicit(&o->stop, true, memory_order_release);
    return dizzass_rx_owner_notify(o);
}
bool dizzass_rx_owner_finished(const struct dizzass_rx_owner *o)
{ return o && atomic_load_explicit(&o->finished, memory_order_acquire); }
int dizzass_rx_owner_join(struct dizzass_rx_owner *o, struct dizzass_rx_owner_report *out)
{
    if (!o || !out || !o->started) return EINVAL;
    if (o->joined) { *out = o->report; return 0; }
    if (pthread_equal(pthread_self(), o->thread)) return EDEADLK;
    int saved, e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (e) return e;
    e = pthread_join(o->thread, NULL);
    if (!e) { o->joined = true; *out = o->report; }
    int restore = pthread_setcancelstate(saved, NULL);
    return e ? e : restore;
}
int dizzass_rx_owner_destroy(struct dizzass_rx_owner **pointer)
{
    if (!pointer || !*pointer) return EINVAL;
    struct dizzass_rx_owner *o = *pointer;
    if (o->started && !o->joined) return EBUSY;
    /* Linux closes this owned eventfd even when close reports EINTR. No retry. */
    int e = close(o->wake_fd) ? errno : 0;
    dizzass_early_rx_destroy(&o->inbox); free(o); *pointer = NULL;
    return e;
}

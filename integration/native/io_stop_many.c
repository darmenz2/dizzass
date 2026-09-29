/* GPL-3.0-or-later. Compose existing one-chain shutdown without owning it. */
#include "integration/native/io_stop_many.h"
#include <errno.h>
#include <pthread.h>

int dizzass_io_stop_many(struct dizzass_io_lifecycle *const *members,
    size_t count, uint64_t deadline, struct dizzass_io_stop_many_report *out)
{
    if (!members || !out || !count || count > DIZZASS_IO_STOP_MANY_MAX)
        return EINVAL;
    /* Complete validation precedes ALL side effects. */
    for (size_t i = 0; i < count; ++i) {
        if (!members[i]) return EINVAL;
        for (size_t j = 0; j < i; ++j)
            if (members[i] == members[j]) return EINVAL;
    }
    int saved, e = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (e) return e;
    struct dizzass_io_stop_many_report r = {0};
    r.count = count;
    /* Do not combine these loops: one child's shared submitter may block. */
    for (size_t i = 0; i < count; ++i) {
        r.entries[i].request_status = dizzass_io_request_stop(members[i]);
        ++r.requested;
        if (!r.first_error && r.entries[i].request_status)
            r.first_error = r.entries[i].request_status;
    }
    for (size_t i = 0; i < count; ++i) {
        r.entries[i].stop_status = dizzass_io_stop(members[i], deadline, &r.entries[i].io);
        ++r.attempted;
        if (!r.first_error && r.entries[i].stop_status)
            r.first_error = r.entries[i].stop_status;
        if (!r.entries[i].stop_status && r.entries[i].io.quiescent)
            ++r.quiescent;
    }
    r.all_quiescent = !r.first_error && r.quiescent == count;
    *out = r;
    e = pthread_setcancelstate(saved, NULL);
    if (e) out->cancel_restore_status = e;
    return r.first_error ? r.first_error : e;
}

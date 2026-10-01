/* GPL-3.0-or-later. No new loop, ownership model or hardware operation. */
#include "config.h"
#include "miner.h"
#include "integration/native/native_io_stop.h"
#include <errno.h>

int dizzass_native_io_stop(struct cgpu_info *cgpu,
    struct dizzass_io_lifecycle *const *members, size_t count,
    uint64_t deadline, struct dizzass_native_io_stop_report *out)
{
    if (!cgpu || !cgpu->drv || !members || !out || !count ||
        count > DIZZASS_IO_STOP_MANY_MAX)
        return EINVAL;
    for (size_t i = 0; i < count; ++i) {
        if (!members[i]) return EINVAL;
        for (size_t j = 0; j < i; ++j)
            if (members[i] == members[j]) return EINVAL;
    }
    int saved, rc = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (rc) return rc;
    struct dizzass_native_io_stop_report r = {0};
    r.io.count = count;
    /* The native hook may wait on a driver mutex. Close ALL admission first. */
    for (size_t i = 0; i < count; ++i) {
        int e = dizzass_io_request_stop(members[i]);
        r.io.entries[i].request_status = e;
        ++r.io.requested;
        if (!r.io.first_error && e) r.io.first_error = e;
    }
    r.first_error = r.io.first_error;
    r.native_called = true;
    r.native_status = cgminer_request_queued_stop(cgpu);
    if (!r.first_error && r.native_status) r.first_error = r.native_status;
    /* An error does not abandon the remaining returning children. */
    for (size_t i = 0; i < count; ++i) {
        int e = dizzass_io_stop(members[i], deadline, &r.io.entries[i].io);
        r.io.entries[i].stop_status = e;
        ++r.io.attempted;
        if (!r.io.first_error && e) r.io.first_error = e;
        if (!r.first_error && e) r.first_error = e;
        if (!e && r.io.entries[i].io.quiescent) ++r.io.quiescent;
    }
    r.io.all_quiescent = !r.io.first_error && r.io.quiescent == count;
    r.sequence_complete = !r.first_error && r.io.all_quiescent;
    *out = r;
    rc = pthread_setcancelstate(saved, NULL);
    if (rc) out->cancel_restore_status = rc;
    return r.first_error ? r.first_error : rc;
}

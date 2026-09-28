/* SPDX-License-Identifier: GPL-3.0-only */
#include "integration/native/native_job_channel_tx.h"
#include <errno.h>
#include <pthread.h>

struct dizzass_native_job_tx_receipt dizzass_native_job_channel_send(
    struct dizzass_jobs *jobs, struct dizzass_uart_channel *channel,
    uint64_t expected_epoch, uint32_t platform_selector,
    uint32_t algorithm_selector, uint32_t slot, uint32_t variant,
    const struct work *source, uint64_t deadline_ms, unsigned max_no_progress)
{
    struct dizzass_native_job_tx_receipt r = {0};
    struct dizzass_tx88_prepared prepared = {0};
    int saved;
    if (!jobs || !channel || !source || !max_no_progress) {
        r.entry_error = EINVAL;
        return r;
    }
    r.entry_error = pthread_setcancelstate(PTHREAD_CANCEL_DISABLE, &saved);
    if (r.entry_error) return r;
    r.prepare_called = true;
    r.prepare_status = dizzass_jobs_prepare_tx88(jobs, expected_epoch,
        platform_selector, algorithm_selector, slot, variant, source, &prepared);
    if (!r.prepare_status) {
        r.ticket = prepared.ticket;
        r.frame_size = sizeof prepared.packet;
        r.channel_called = true;
        r.transport = dizzass_uart_channel_send(channel, prepared.packet,
            sizeof prepared.packet, deadline_ms, max_no_progress);
        r.outcome = r.transport.status == DIZZASS_UART_OK &&
            r.transport.written == sizeof prepared.packet && r.transport.error == 0
            ? DIZZASS_TX_WRITTEN : DIZZASS_TX_UNCERTAIN;
        r.finish_called = true;
        r.finish_status = dizzass_jobs_finish(jobs, &prepared.ticket, r.outcome);
        if (r.outcome != DIZZASS_TX_WRITTEN || r.finish_status) {
            r.stop_called = true;
            r.stop_status = dizzass_uart_channel_stop(channel, 0);
        }
    }
    r.cancel_restore_error = pthread_setcancelstate(saved, NULL);
    return r;
}

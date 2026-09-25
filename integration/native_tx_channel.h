/* Single-chain native-work/real-tty session. GPL-3.0-or-later.
 * New conservative integration policy, not the original vendor lifecycle.
 */
#ifndef DIZZASS_NATIVE_TX_CHANNEL_H
#define DIZZASS_NATIVE_TX_CHANNEL_H
#include "integration/hwscan_profile.h"
#include "integration/posix_tx88.h"
#include "integration/native_work_tx88.h"
struct dizzass_tx_channel;
enum dizzass_channel_status { DIZZASS_CHANNEL_AGAIN=1,
    DIZZASS_CHANNEL_DISCARDED=2, DIZZASS_CHANNEL_STOPPED=-700,
    DIZZASS_CHANNEL_RX_IO=-701 };
struct dizzass_channel_send_result {
    struct dizzass_job_ticket ticket;
    struct dizzass_serial_receipt io;
};
struct dizzass_channel_rx_result {
    int match_status;
    struct dizzass_job_result job;
};
/* Requires a caller-proven CLEAN DEVICE boundary, a quiescent hwscan snapshot,
 * and an exclusively owned configured tty (raw 8N1, VMIN=1, VTIME=0). A successful syscall does not prove
 * any of those physical preconditions. Duplicates fd; caller may close its copy
 * but may NOT keep using it. No baud setting, power, flash, or hardware reset.
 * initial_epoch is nonzero and unique for this physical RX session. No API in
 * this module resumes/relabels a stopped session or reuses its sent slots.
 * Only fixed work: version rolling and CRC validation are not implemented.
 */
int dizzass_tx_channel_create(const struct dizzass_hwscan_profile *profile,
    uint32_t chain_id,uint64_t initial_epoch,int configured_fd,
    struct dizzass_tx_channel **out);
/* Replaces active work: retires the previous slot BEFORE preparing new work.
 * Late replies keep their original slot and cannot resolve to a replacement.
 * After 32 successful sends, returns EXHAUSTED; no modulo reuse. A partial
 * frame stops the whole session; NOT_SENT may retry the unused slot. The
 * result always reports actual partial progress, not merely a bool.
 */
int dizzass_tx_channel_send(struct dizzass_tx_channel *channel,
    const struct work *source,uint32_t deadline_ms,
    struct dizzass_channel_send_result *out);
/* Reads the actual fd and existing bounded RX parser, at most one complete
 * event per call; at most one new 128-byte read, so noise cannot starve stop. Calls native work checking, NOT network submission. No CRC
 * confidence is claimed. Caller initializes out to zero and clears owned job.
 * Rejects a foreign epoch BEFORE reading or consuming buffered bytes. The
 * epoch must come from the session at capture, never from a mutable global.
 */
int dizzass_tx_channel_read(struct dizzass_tx_channel *channel,
    uint64_t captured_epoch,struct dizzass_channel_rx_result *out);
/* Waits for an in-flight send/check, retires everything, never resumes. Does not
 * stop chips or drain UART; no tcflush is used as a substitute for a reset. */
int dizzass_tx_channel_stop(struct dizzass_tx_channel *channel);
/* Stop/join all users before destroy; not concurrent with any other call. */
void dizzass_tx_channel_destroy(struct dizzass_tx_channel **channel);
#endif

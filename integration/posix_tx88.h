/* Linux termios2/monotonic TX adapter. New policy, GPL-3.0-or-later. */
#ifndef DIZZASS_POSIX_TX88_H
#define DIZZASS_POSIX_TX88_H
#include <stdint.h>
#include <stddef.h>
#include "integration/work_tx88.h"
enum dizzass_serial_status { DIZZASS_SERIAL_OK=0, DIZZASS_SERIAL_INVALID=-600,
    DIZZASS_SERIAL_IO=-601, DIZZASS_SERIAL_TIMEOUT=-602 };
enum dizzass_serial_outcome { DIZZASS_SERIAL_WRITTEN=0,
    DIZZASS_SERIAL_NOT_SENT=1, DIZZASS_SERIAL_UNCERTAIN=2 };
struct dizzass_serial_receipt {
    enum dizzass_serial_outcome outcome;
    size_t written;
    int error_number;
};
/* Caller owns an EXCLUSIVE fd; nobody may close/reconfigure/read/write it while
 * attached. Requires O_RDWR|O_NONBLOCK, raw 8N1, CREAD, no hardware flow control,
 * and the exact requested input/output baud. Does not configure/open a device.
 */
int dizzass_posix_uart_check(int fd,uint32_t baud);
/* Calls real write()/poll(). Positive short writes advance the buffer, never
 * replay its prefix. Deadline uses CLOCK_MONOTONIC, 1..10000 ms. The descriptor
 * must have passed check() and stay exclusive. Receipt always initialized.
 * WRITTEN means accepted by kernel, NOT drained, chip ACK, or a found share.
 * A partial/uncertain frame invalidates the CHANNEL until physical recovery;
 * neither tcflush nor reopening a descriptor proves old chip work is gone.
 */
int dizzass_posix_tx88_write(int fd,const uint8_t packet[DIZZASS_TX88_SIZE],
    uint32_t timeout_ms,struct dizzass_serial_receipt *receipt);
#endif

/* Offline original c36e8/5b150 projection, not a native driver or ARM ABI. */
#ifndef VN135_CHAIN_UART_READER_135_H
#define VN135_CHAIN_UART_READER_135_H
#include <stdint.h>
struct vn135_chain_uart_reader_view {
    const uint32_t *model, *controller;
    const uint8_t *force_nine;
    const int32_t *index;
    uint8_t *running;
    const uint32_t *read_method;
    /* Numeric ARM pointer identities for modulo32 end-begin, never dereferenced.
     * d20b4 measures total geometry, NOT occupancy or remaining space. */
    const uint32_t *queue_begin, *queue_end, *queue_stride, *queue_count;
    void *mutex, *queue, *uart, *condition_mutex, *condition;
};
struct vn135_chain_uart_reader_scratch {
    uint8_t bytes[256];
    char name[64];
    uint32_t previous_mode[2];
};
struct vn135_chain_uart_reader_ops {
    int32_t (*mutex)(void *,uint32_t entry,void *object);
    int32_t (*delay_ms)(void *,uint32_t);
    /* Exact 5a6b2c boundary. Whenever old!=NULL it MUST initialize *old,
     * including on an injected error. No guessed TLS/POSIX implementation. */
    int32_t (*mode)(void *,uint32_t value,uint32_t *old);
    int32_t (*format)(void *,char *out,uint32_t size,uint32_t format,int32_t index);
    int32_t (*name)(void *,uint32_t operation,const char *,uint32_t,uint32_t,uint32_t);
    int32_t (*read)(void *,uint32_t method,void *uart,uint8_t *out,uint32_t request);
    uint32_t (*push)(void *,void *queue,const uint8_t *data,uint32_t count);
    int32_t (*signal)(void *,void *condition);
    void (*exit_thread)(void *,uint32_t value);
};
/* All fields/objects/callbacks valid, nonaliasing, fixed identities. Only values
 * behind field pointers may change synchronously. No asynchronous C access.
 * Scratch is caller-owned, initialized and accessible; callbacks do not retain
 * scratch pointers. Positive read counts <=256, and every consumed byte must
 * be initialized. No invented clamp of a positive result to requested length.
 * Format writes a bounded terminated name. Mode initializes saved state.
 * Capacity wait must eventually become nonzero; worker callbacks eventually
 * clear running at a loop-tail boundary. No source timeout/flag check is added
 * inside wait. Bulk push and selected read bodies are REQUIRED boundaries.
 * Worker has no success value. Comparison ends after exit_thread; returning
 * from that injected callback returns to the harness, not to an original
 * pthread caller. No actual thread/fd/ASIC, pending-PR or production dependency. */
uint32_t vn135_chain_uart_wait_capacity_135(const struct vn135_chain_uart_reader_view *,
    const struct vn135_chain_uart_reader_ops *,void *);
void vn135_chain_uart_reader_135(const struct vn135_chain_uart_reader_view *,
    const struct vn135_chain_uart_reader_ops *,void *,struct vn135_chain_uart_reader_scratch *);
#endif

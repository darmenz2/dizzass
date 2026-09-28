/* Original d26ac with an explicit table view; no global or hardware binding. */
#ifndef VN135_TRANSPORT_DISPATCH_135_H
#define VN135_TRANSPORT_DISPATCH_135_H
#include <stdint.h>
#include "xminer/recovery/aml_chip.h"
#include "xminer/recovery/uart.h"

/* send_payload represents the method at global table+0x18. context is a new
 * adapter field, not a source-ABI offset. The table and reached method must
 * exist. Device/payload identities and all 32 length bits pass through, even
 * NULL or zero; admission belongs to the selected method, not this wrapper.
 * The table may be changed by a synchronous callback for the NEXT invocation.
 */
struct vn135_transport_dispatch_135 {
    int32_t (*send_payload)(void *context,void *device,
                           const uint8_t *payload,uint32_t length);
    void *context;
};
int32_t vn135_transport_send_135(const struct vn135_transport_dispatch_135 *,
    void *device,const uint8_t *payload,uint32_t length);

/* New typed binding, not reconstructed device layout or platform detection.
 * The original AML path forwards the SAME source pointer into the UART helper.
 * Our existing device/index view and uart view are separate projections; this
 * object explicitly associates them. Never cast a chip-device view to uart.
 * framing supplies allocate/release and the OUTER lock callbacks/context.
 * framing->write is deliberately unused: the bridge calls the existing
 * vn135_uart_write_legacy with uart_ops (whose locks are the INNER locks).
 * Both callback tables and this binding remain valid/stable during a call.
 * Outer and inner mutexes must be distinct; callbacks must not retain buffers.
 */
struct vn135_aml_uart_binding_135 {
    void *device_identity;
    vn135_uart *uart;
    const vn135_aml_transport *framing;
    const vn135_uart_ops *uart_ops;
};
/* Selected explicitly only after AML route admission (source platform=2).
 * NULL source device preserves legacy -1 before any framing/UART operations.
 * Mismatched identities/incomplete bindings return NEW API guard -2. Existing
 * AML/UART pointer/length guards and omitted diagnostic scope are unchanged.
 * No default OS operations, opening devices, implicit retries or write-all.
 * Legacy UART may replay the WHOLE frame on EAGAIN, including short writes;
 * success means an exact reported byte count, not an ASIC acknowledgement.
 */
int32_t vn135_aml_uart_send_135(void *binding,void *device,
    const uint8_t *payload,uint32_t length);
#endif

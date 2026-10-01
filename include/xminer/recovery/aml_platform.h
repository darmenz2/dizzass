/* SPDX-License-Identifier: GPL-3.0-only
 * Bounded source-level reconstruction of bounded AML platform behavior.
 * No device discovery, open, UART configuration or production registration.
 */
#ifndef VN135_RECOVERY_AML_PLATFORM_H
#define VN135_RECOVERY_AML_PLATFORM_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

/* Original cgminer 0x11c080 / hwscan 0x10e220 pathname-result projection.
 * uint32 index 0,1,2 maps to /dev/ttyS3,/dev/ttyS2,/dev/ttyS1 respectively.
 * Every other uint32 value returns an EMPTY, NON-NULL string, not an error
 * pointer or a fallback device. Check path[0] if a caller needs valid routing.
 * Result has static lifetime and must not be modified or freed.
 *
 * The projection assumes the vendor path table is initialized and unchanged.
 * cgminer string-decryption initialization and opaque-predicate memory reads
 * are not reproduced. This function performs no I/O, allocation or mutation.
 * Static byte/flow evidence + host tests are not vendor execution parity.
 */
const char *vn135_aml_uart_path_135(uint32_t chain_index);

#ifdef __cplusplus
}
#endif
#endif

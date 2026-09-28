/* Observed backend selection, GPL-3.0-or-later. No hardware detection or I/O. */
#ifndef DIZZASS_WORK_ROUTE_H
#define DIZZASS_WORK_ROUTE_H
#include <stdint.h>

enum dizzass_work_family {
    DIZZASS_WORK_SHA256_PLATFORM0 = 1,
    DIZZASS_WORK_SHA256_TX88 = 2,
    DIZZASS_WORK_SCRYPT_TX86 = 3
};
enum dizzass_route_status {
    DIZZASS_ROUTE_OK = 0,
    DIZZASS_ROUTE_INVALID = -400,
    DIZZASS_ROUTE_UNSUPPORTED = -401
};
/* Numeric selectors from the reference configuration, not model identifiers.
 * Original algorithm parser: sha256d=0, scrypt=1, unknown=2. The analysed AML
 * caller passes platform=2. Only the bounded domain platform 0..4, algo 0..1
 * is classified here; unsupported inputs leave *out unchanged. Classification
 * does not authorize hardware use or prove a model/board/chip configuration.
 * The platform-zero SHA256 backend has NOT been implemented by this module.
 */
int dizzass_work_route_select(uint32_t platform_selector,
    uint32_t algorithm_selector, enum dizzass_work_family *out);
#endif

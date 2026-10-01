/* SPDX-License-Identifier: GPL-3.0-or-later */
#ifndef VN135_BM1368_INITIALIZE_135_H
#define VN135_BM1368_INITIALIZE_135_H
#include <stdint.h>

#define VN135_BM1368_METHOD_WORDS_135 56

/* Bounded projection of cgminer e1450, selected by original chip selector 4.
 * Write 54 original cgminer uint32_t address IDENTITIES into caller storage.
 * These words are data, never callable host pointers. Only this table-building
 * function is reconstructed here; its 54 pointed-to methods are not supplied.
 * A separate reviewed typed binding is required before any implemented method
 * can be called. Do not cast these words or this array to a native/vendor ABI.
 *
 * Domain: method_words denotes at least 56 aligned writable uint32_t objects,
 * alive through return, with no overlap with code/static source data and no
 * concurrent or asynchronous users. Offsets 0 and 0x18 (words 0 and 6) remain
 * unchanged. All other words through offset 0xdc are assigned in the original
 * logical store order. No reads of the previous output values, allocation,
 * callbacks or I/O. External serialization is required for shared storage.
 *
 * This fixes GOT contents to the pinned, unrelocated cgminer snapshot. Runtime
 * GOT mutation, relocation, invalid pointers, fault/access traces, stack-frame
 * layout, races and asynchronous interruption are outside the projection.
 * Return zero means this pure table constructor completed; it says nothing
 * about hardware discovery, UART readiness or a working chip driver.
 */
int32_t vn135_bm1368_initialize_135(
    uint32_t method_words[static VN135_BM1368_METHOD_WORDS_135]);
#endif

/* SPDX-License-Identifier: GPL-3.0-only
 * Integration API for recovered libbitmain/src/reg_cache.c behavior.
 * No hardware writes. Caller must serialize operations and own the allocator.
 * This is not a binary-compatible replacement for vendor globals or structs.
 */
#ifndef VN135_RECOVERY_REG_CACHE_H
#define VN135_RECOVERY_REG_CACHE_H
#include <stddef.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
#define VN135_REG_CACHE_SLOTS 64
#define VN135_REG_CACHE_SELECTORS 8

typedef struct { uint32_t address, value; } vn135_reg_entry;
typedef struct { vn135_reg_entry entries[VN135_REG_CACHE_SLOTS]; } vn135_reg_table;
typedef struct {
    vn135_reg_table common;
    vn135_reg_table *chips;
    int32_t chip_count;
} vn135_reg_chain;
typedef struct {
    void *context;
    /* Return zero-initialized storage or NULL. Arguments follow the original
     * (element_size, count) order. Host pointer width changes chain size;
     * the original/ARM32 chain record is 520 bytes, a chip table is 512. */
    void *(*allocate_zeroed)(void *context, size_t element_size, size_t count);
    void (*release)(void *context, void *memory);
} vn135_reg_allocator;
typedef struct {
    vn135_reg_chain *chains;
    int32_t chain_count;
    uint8_t initialized;
    vn135_reg_allocator allocator;
} vn135_reg_cache;

/* selector is the vendor internal enum 0..7, not a chip number/model name.
 * Exact table data; not recommended operating settings. */
int vn135_reg_cache_defaults(uint32_t selector, vn135_reg_table *out);
/* A zero-initialized cache is required. Reinitializing a live/partial cache
 * returns -2. 0 success; -1 invalid selector/allocation failure. Negative
 * counts, overflow or invalid integration arguments return -2.
 * On allocation failure, original partial allocation is retained and the
 * cache remains disabled. Call destroy before retrying. */
int vn135_reg_cache_init(vn135_reg_cache *cache, uint32_t selector,
    int32_t chain_count, int32_t chip_count, const vn135_reg_allocator *allocator);
/* Restore prefixes of allocated chain/chip arrays, matching 0x106e58.
 * Does not enable/disable cache or change stored counts. Added bounds checks
 * refuse lengths exceeding owned storage (-2). Missing storage returns -1.
 * A later missing chip array may leave earlier chains reset, as in original. */
int vn135_reg_cache_reset(vn135_reg_cache *cache, uint32_t selector,
    int32_t chain_count, int32_t chip_count);
/* 0 success, -1 disabled/cache index/register/output error or not found.
 * Added structural guards return -2 for corrupt integration context.
 * Getters do not modify output on failure. No read-through to hardware.
 * set_chain updates common plus the SAME slot in every chip table;
 * set_chip changes only the selected chip, not the common entry. */
int vn135_reg_cache_get_chain(const vn135_reg_cache *cache, int32_t chain,
    uint32_t reg, uint32_t *value);
int vn135_reg_cache_set_chain(vn135_reg_cache *cache, int32_t chain,
    uint32_t reg, uint32_t value);
int vn135_reg_cache_get_chip(const vn135_reg_cache *cache, int32_t chain,
    int32_t chip, uint32_t reg, uint32_t *value);
int vn135_reg_cache_set_chip(vn135_reg_cache *cache, int32_t chain,
    int32_t chip, uint32_t reg, uint32_t value);
/* Disable, release per-chip arrays then chain array, clear pointer/count.
 * NULL and already empty contexts are accepted by this integration API.
 * The allocator context/callbacks are retained, so destroy is idempotent. */
void vn135_reg_cache_destroy(vn135_reg_cache *cache);
#ifdef __cplusplus
}
#endif
#endif

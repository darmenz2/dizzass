/* SPDX-License-Identifier: GPL-3.0-only
 * Recovered from /tmp/build/libbitmain/src/reg_cache.c in reference ELF.
 * Sources/addresses and supported equivalence domain: evidence/stage4/.
 * The vendor singleton is made an explicit caller-owned context. Diagnostic
 * formatting and opaque parity predicates are not part of this API.
 */
#include "xminer/recovery/reg_cache.h"
#include <limits.h>

_Static_assert(sizeof(vn135_reg_entry) == 8, "register pair layout");
_Static_assert(sizeof(vn135_reg_table) == 512, "register table layout");
#if UINTPTR_MAX == UINT32_MAX
_Static_assert(sizeof(vn135_reg_chain) == 520, "ARM32 chain layout");
_Static_assert(offsetof(vn135_reg_chain, chips) == 512, "ARM32 chip pointer");
_Static_assert(offsetof(vn135_reg_chain, chip_count) == 516, "ARM32 chip count");
#endif
#include "../../reconstruction/data/reg_cache_defaults.inc"

static void table_copy(vn135_reg_table *dst, const vn135_reg_table *src)
{
    for (size_t i = 0; i < VN135_REG_CACHE_SLOTS; ++i) dst->entries[i] = src->entries[i];
}
static int find_slot(const vn135_reg_table *table, uint32_t reg)
{
    for (int i = 0; i < VN135_REG_CACHE_SLOTS; ++i)
        if (table->entries[i].address == reg) return i;
    return -1;
}
int vn135_reg_cache_defaults(uint32_t selector, vn135_reg_table *out)
{
    if (selector >= VN135_REG_CACHE_SELECTORS) return -1;
    if (!out) return -2;
    table_copy(out, &cache_defaults[selector]);
    return 0;
}
/* 0x106a58. Partial allocations intentionally remain available to destroy. */
int vn135_reg_cache_init(vn135_reg_cache *cache, uint32_t selector,
    int32_t chain_count, int32_t chip_count, const vn135_reg_allocator *allocator)
{
    if (selector >= VN135_REG_CACHE_SELECTORS) return -1;
    if (!cache || !allocator || !allocator->allocate_zeroed || !allocator->release
        || chain_count < 0 || chip_count < 0 || cache->initialized
        || cache->chains || cache->chain_count
        || (size_t)chain_count > SIZE_MAX / sizeof(vn135_reg_chain)
        || (size_t)chip_count > SIZE_MAX / sizeof(vn135_reg_table)) return -2;
    cache->allocator = *allocator;
    cache->chains = allocator->allocate_zeroed(allocator->context,
        sizeof(vn135_reg_chain), (size_t)chain_count);
    if (!cache->chains) return -1;
    cache->chain_count = chain_count;
    for (int32_t i = 0; i < chain_count; ++i) {
        vn135_reg_chain *chain = &cache->chains[i];
        chain->chips = allocator->allocate_zeroed(allocator->context,
            sizeof(vn135_reg_table), (size_t)chip_count);
        if (!chain->chips) return -1;
        chain->chip_count = chip_count;
        table_copy(&chain->common, &cache_defaults[selector]);
        for (int32_t j = 0; j < chip_count; ++j)
            table_copy(&chain->chips[j], &cache_defaults[selector]);
    }
    cache->initialized = 1;
    return 0;
}
/* 0x106e58; the caller's counts are not stored back into the cache. */
int vn135_reg_cache_reset(vn135_reg_cache *cache, uint32_t selector,
    int32_t chain_count, int32_t chip_count)
{
    if (selector >= VN135_REG_CACHE_SELECTORS) return -1;
    if (!cache) return -2;
    if (!cache->chains) return -1;
    if (chain_count < 0 || chip_count < 0 || chain_count > cache->chain_count)
        return -2;
    for (int32_t i = 0; i < chain_count; ++i) {
        vn135_reg_chain *chain = &cache->chains[i];
        if (!chain->chips) return -1;
        if (chip_count > chain->chip_count) return -2;
        table_copy(&chain->common, &cache_defaults[selector]);
        for (int32_t j = 0; j < chip_count; ++j)
            table_copy(&chain->chips[j], &cache_defaults[selector]);
    }
    return 0;
}
static int validate_chain(const vn135_reg_cache *cache, int32_t chain, uint32_t reg)
{
    if (!cache) return -2;
    if (!cache->initialized || chain < 0 || chain >= cache->chain_count || reg >= 256)
        return -1;
    if (!cache->chains) return -2;
    return 0;
}
/* 0x107188 */
int vn135_reg_cache_get_chain(const vn135_reg_cache *cache, int32_t chain,
    uint32_t reg, uint32_t *value)
{
    int rc = validate_chain(cache, chain, reg);
    if (rc) return rc;
    if (!value) return -1;
    const vn135_reg_table *table = &cache->chains[chain].common;
    int slot = find_slot(table, reg);
    if (slot < 0) return -1;
    *value = table->entries[slot].value;
    return 0;
}
/* 0x107648 */
int vn135_reg_cache_set_chain(vn135_reg_cache *cache, int32_t chain,
    uint32_t reg, uint32_t value)
{
    int rc = validate_chain(cache, chain, reg);
    if (rc) return rc;
    vn135_reg_chain *record = &cache->chains[chain];
    int slot = find_slot(&record->common, reg);
    if (slot < 0) return -1;
    if (record->chip_count > 0 && !record->chips) return -2;
    record->common.entries[slot].value = value;
    for (int32_t chip = 0; chip < record->chip_count; ++chip)
        record->chips[chip].entries[slot].value = value;
    return 0;
}
static int validate_chip(const vn135_reg_chain *chain, int32_t chip)
{
    if (chip < 0 || chip >= chain->chip_count) return -1;
    return chain->chips ? 0 : -2;
}
/* 0x1079f0 */
int vn135_reg_cache_get_chip(const vn135_reg_cache *cache, int32_t chain,
    int32_t chip, uint32_t reg, uint32_t *value)
{
    int rc = validate_chain(cache, chain, reg);
    if (rc) return rc;
    if (!value) return -1;
    const vn135_reg_chain *record = &cache->chains[chain];
    rc = validate_chip(record, chip);
    if (rc) return rc;
    const vn135_reg_table *table = &record->chips[chip];
    int slot = find_slot(table, reg);
    if (slot < 0) return -1;
    *value = table->entries[slot].value;
    return 0;
}
/* 0x107ed0 */
int vn135_reg_cache_set_chip(vn135_reg_cache *cache, int32_t chain,
    int32_t chip, uint32_t reg, uint32_t value)
{
    int rc = validate_chain(cache, chain, reg);
    if (rc) return rc;
    vn135_reg_chain *record = &cache->chains[chain];
    rc = validate_chip(record, chip);
    if (rc) return rc;
    vn135_reg_table *table = &record->chips[chip];
    int slot = find_slot(table, reg);
    if (slot < 0) return -1;
    table->entries[slot].value = value;
    return 0;
}
/* 0x1082b4; return register is not part of the original void contract. */
void vn135_reg_cache_destroy(vn135_reg_cache *cache)
{
    if (!cache) return;
    cache->initialized = 0;
    if (cache->chains) {
        if (!cache->allocator.release) return;
        for (int32_t i = 0; i < cache->chain_count; ++i) {
            if (cache->chains[i].chips) {
                cache->allocator.release(cache->allocator.context, cache->chains[i].chips);
                cache->chains[i].chips = NULL;
            }
        }
        cache->allocator.release(cache->allocator.context, cache->chains);
    }
    cache->chains = NULL;
    cache->chain_count = 0;
}

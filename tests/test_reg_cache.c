/* SPDX-License-Identifier: GPL-3.0-only */
#include "xminer/recovery/reg_cache.h"
#include "xminer/recovery/chip1398.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { size_t calls, frees, live; int fail; } heap_state;
static void *allocate_zeroed(void *ctx, size_t size, size_t count)
{
    heap_state *h = ctx;
    size_t index = h->calls++;
    if ((int)index == h->fail) return NULL;
    void *p = calloc(count ? count : 1, size);
    if (p) ++h->live;
    return p;
}
static void release(void *ctx, void *p)
{
    heap_state *h = ctx;
    assert(p && h->live);
    --h->live; ++h->frees; free(p);
}
static vn135_reg_allocator allocator(heap_state *h)
{
    vn135_reg_allocator a = {h, allocate_zeroed, release}; return a;
}
typedef struct { unsigned calls; int rc; uint8_t packet[9]; } sender_state;
static int send_payload(void *ctx, const uint8_t *packet, size_t size)
{
    sender_state *s = ctx;assert(size == 9);
    ++s->calls; memcpy(s->packet, packet, 9);return s->rc;
}
static void cache_cases(void)
{
    heap_state h = {0, 0, 0, -1};vn135_reg_allocator a = allocator(&h);
    vn135_reg_cache cache = {0};uint32_t value = 0xa5a5a5a5;
    assert(vn135_reg_cache_get_chain(&cache, 0, 8, &value) == -1);
    assert(value == 0xa5a5a5a5);
    assert(vn135_reg_cache_init(&cache, 5, 2, 3, &a) == 0);
    assert(cache.initialized && h.live == 3);
    assert(vn135_reg_cache_init(&cache, 5, 2, 3, &a) == -2);
    assert(h.calls == 3);
    assert(vn135_reg_cache_set_chip(&cache, 0, 1, 0x25, 0x13579bdf) == 0);
    assert(vn135_reg_cache_get_chip(&cache, 0, 1, 0x25, &value) == 0 && value == 0x13579bdf);
    assert(vn135_reg_cache_get_chain(&cache, 0, 0x25, &value) == 0 && value == 0);
    assert(vn135_reg_cache_set_chain(&cache, 0, 0x25, 0xfedcba98) == 0);
    for (int i = 0; i < 3; ++i) {
        assert(vn135_reg_cache_get_chip(&cache, 0, i, 0x25, &value) == 0);
        assert(value == 0xfedcba98);
    }
    assert(vn135_reg_cache_get_chip(&cache, 1, 1, 0x25, &value) == 0 && value == 0);
    value = 0xa5a5a5a5;
    assert(vn135_reg_cache_get_chain(&cache, -1, 8, &value) == -1);
    assert(vn135_reg_cache_get_chain(&cache, 2, 8, &value) == -1);
    assert(vn135_reg_cache_get_chain(&cache, 0, 256, &value) == -1);
    assert(vn135_reg_cache_get_chain(&cache, 0, 3, &value) == -1);
    assert(vn135_reg_cache_get_chip(&cache, 0, -1, 8, &value) == -1);
    assert(vn135_reg_cache_get_chip(&cache, 0, 3, 8, &value) == -1);
    assert(value == 0xa5a5a5a5);
    assert(vn135_reg_cache_get_chain(&cache, 0, 8, NULL) == -1);
    assert(vn135_reg_cache_get_chip(&cache, 0, 0, 8, NULL) == -1);
    vn135_reg_table old = cache.chains[0].common;
    assert(vn135_reg_cache_reset(&cache, 9, 2, 3) == -1);
    assert(vn135_reg_cache_reset(&cache, 2, -1, 3) == -2);
    assert(vn135_reg_cache_reset(&cache, 2, 3, 3) == -2);
    assert(vn135_reg_cache_reset(&cache, 2, 2, 4) == -2);
    assert(memcmp(&old, &cache.chains[0].common, sizeof(old)) == 0);
    assert(vn135_reg_cache_reset(&cache, 2, 1, 1) == 0);
    assert(cache.chain_count == 2 && cache.chains[0].chip_count == 3);
    assert(vn135_reg_cache_get_chip(&cache, 0, 0, 0x25, &value) == -1);
    assert(vn135_reg_cache_get_chip(&cache, 0, 1, 0x25, &value) == 0 && value == 0xfedcba98);
    cache.initialized = 0;
    assert(vn135_reg_cache_set_chain(&cache, 0, 8, 0) == -1);
    assert(vn135_reg_cache_set_chip(&cache, 0, 0, 8, 0) == -1);
    assert(vn135_reg_cache_reset(&cache, 5, 2, 3) == 0 && cache.initialized == 0);
    vn135_reg_cache_destroy(&cache);
    assert(h.live == 0 && h.frees == 3 && cache.chains == NULL && cache.chain_count == 0);
    vn135_reg_cache_destroy(&cache);vn135_reg_cache_destroy(NULL);
    assert(h.frees == 3);
}
static void failure_cases(void)
{
    for (int fail = 0; fail < 4; ++fail) {
        heap_state h = {0, 0, 0, fail};vn135_reg_allocator a = allocator(&h);
        vn135_reg_cache cache = {0};
        assert(vn135_reg_cache_init(&cache, 2, 3, 2, &a) == -1);
        assert(!cache.initialized && h.live == (size_t)fail);
        vn135_reg_cache_destroy(&cache);
        assert(h.live == 0 && h.frees == (size_t)fail);
    }
    heap_state h = {0, 0, 0, -1};vn135_reg_allocator a = allocator(&h);
    vn135_reg_cache cache = {0};vn135_reg_table table;
    assert(vn135_reg_cache_init(&cache, 8, 1, 1, &a) == -1);
    assert(vn135_reg_cache_init(&cache, 2, -1, 1, &a) == -2);
    assert(vn135_reg_cache_init(&cache, 2, 1, -1, &a) == -2);
    assert(vn135_reg_cache_init(NULL, 2, 1, 1, &a) == -2);
    assert(vn135_reg_cache_init(&cache, 2, 1, 1, NULL) == -2);
    assert(h.calls == 0);
    assert(vn135_reg_cache_defaults(8, &table) == -1);
    assert(vn135_reg_cache_defaults(0, NULL) == -2);
    assert(vn135_reg_cache_reset(NULL, 0, 0, 0) == -2);
    assert(vn135_reg_cache_get_chip(NULL, 0, 0, 8, NULL) == -2);
    assert(vn135_reg_cache_set_chain(NULL, 0, 8, 0) == -2);
    assert(vn135_reg_cache_init(&cache, 0, 0, 0, &a) == 0);
    assert(cache.initialized && cache.chain_count == 0);
    vn135_reg_cache_destroy(&cache);assert(h.live == 0);
}
static void config_cases(void)
{
    heap_state h = {0, 0, 0, -1};vn135_reg_allocator a = allocator(&h);
    vn135_reg_cache cache = {0};assert(vn135_reg_cache_init(&cache, 2, 2, 3, &a) == 0);
    sender_state s = {0, 0, {0}};vn135_config_sender sender = {&s, send_payload};
    vn135_chip_reference chip = {1, 0x103};uint32_t value;
    assert(vn135_bm1398_set_config(&cache, 0, 0, &chip, 8, 0x12345678, &sender) == 0);
    assert(s.calls == 1 && s.packet[0] == 0x41 && s.packet[2] == 3);
    assert(vn135_reg_cache_get_chip(&cache, 0, 1, 8, &value) == 0 && value == 0x12345678);
    assert(vn135_reg_cache_get_chain(&cache, 0, 8, &value) == 0 && value != 0x12345678);
    assert(vn135_bm1398_set_config(&cache, 0, 2, &chip, 8, 0xaabbccdd, &sender) == 0);
    assert(s.calls == 2 && s.packet[0] == 0x41);
    for (int i = 0; i < 3; ++i) {
        assert(vn135_reg_cache_get_chip(&cache, 0, i, 8, &value) == 0 && value == 0xaabbccdd);
    }
    s.rc = -7;
    assert(vn135_bm1398_set_config(&cache, 0, 1, &chip, 8, 0, &sender) == -1);
    assert(s.calls == 3 && s.packet[0] == 0x51);
    assert(vn135_reg_cache_get_chain(&cache, 0, 8, &value) == 0 && value == 0xaabbccdd);
    s.rc = 0;
    /* Original sends low address byte, THEN the cache rejects full reg 0x108. */
    assert(vn135_bm1398_set_config(&cache, 0, 0, NULL, 0x108, 0, &sender) == -1);
    assert(s.calls == 4 && s.packet[3] == 8);
    cache.initialized = 0;
    assert(vn135_bm1398_set_config(&cache, 0, 1, NULL, 8, 0, &sender) == -1);
    assert(s.calls == 5);
    assert(vn135_bm1398_set_config(&cache, 0, 1, NULL, 8, 0, NULL) == -2);
    assert(vn135_bm1398_set_config(NULL, 0, 1, NULL, 8, 0, &sender) == -2);
    assert(s.calls == 5);
    vn135_reg_cache_destroy(&cache);assert(h.live == 0);
}
int main(void)
{
    cache_cases();failure_cases();config_cases();
    puts("Stage 4 cache/transaction native assertions: PASS");return 0;
}

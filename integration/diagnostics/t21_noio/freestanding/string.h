/* SPDX-License-Identifier: GPL-3.0-only
 * Diagnostic-only declarations; never added to production include paths. */
#ifndef DIZZASS_D01_STRING_H
#define DIZZASS_D01_STRING_H
#include <stddef.h>
void *memcpy(void *restrict dst, const void *restrict src, size_t n);
void *memset(void *dst, int byte, size_t n);
int memcmp(const void *a, const void *b, size_t n);
#endif

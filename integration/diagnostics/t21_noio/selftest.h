/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef DIZZASS_D01_SELFTEST_H
#define DIZZASS_D01_SELFTEST_H
/* Pure bounded diagnostic; returns the first failing check, zero on success. */
unsigned diag_selftest(unsigned *checks);
#endif

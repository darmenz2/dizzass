/* SPDX-License-Identifier: GPL-3.0-only */
#ifndef VN135_TEMPLATE_PUBLICATION_135_H
#define VN135_TEMPLATE_PUBLICATION_135_H
#include <stdint.h>

/* Offline named-field view of c3148, NOT a native cgminer work or vendor ABI.
 * All field pointers, object and callback identities remain fixed throughout
 * the call. Callbacks may synchronously change pointed-to values. Each pointer
 * is valid; callbacks are mandatory, do not retain view pointers or reenter.
 * Slots, ready/source-reset fields and view/ops storage do not overlap;
 * destination and source identify distinct stable objects.
 * The caller supplies ownership-correct release and clone operations. This
 * module does NOT implement 5cd70 or transfer a raw104 object into cgminer.
 * No real concurrent accesses or OS/hardware defaults are provided.
 */
typedef struct {
    void **branches;             /* global template +0x50 */
    void **coinbase;             /* global template +0x48 */
    void **text;                 /* global template +0x04 */
    uint8_t *ready;
    const uint8_t *source_reset; /* source +0x60; read AFTER clone and ready */
    void *destination;
    const void *source;
    void *mutex;
    void *condition;
} vn135_template_publication_view;

typedef struct {
    int (*lock)(void *, void *);
    void (*release)(void *, void *);
    void (*clone)(void *, void *, const void *); /* required 5cd70 boundary */
    void (*reset)(void *);                      /* required fa944 boundary */
    int (*broadcast)(void *, void *);
    int (*unlock)(void *, void *);
} vn135_template_publication_ops;

/* Return-less coordinator. Original ignores lock/broadcast/unlock outcomes.
 * No rollback, fallible-clone success convention or added input guards.
 * fa944 can be composed with existing nonce FIFO reset ONLY in its documented
 * initialized, successful-lock domain; broader raw behavior stays external.
 */
void vn135_template_publish_135(const vn135_template_publication_view *,
    const vn135_template_publication_ops *, void *context);
#endif

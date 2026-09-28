/* SPDX-License-Identifier: GPL-3.0-only
 * Original c3148, /tmp/build/src/backend/work-gen/work-gen.c.
 * Evidence and callback contract: integration/TEMPLATE_PUBLICATION_135_RU.md.
 * Offline comparison only; not linked into production cgminer.
 */
#include "integration/template_publication_135.h"

void vn135_template_publish_135(const vn135_template_publication_view *v,
    const vn135_template_publication_ops *o, void *context)
{
    void *allocation;
    (void)o->lock(context, v->mutex);

    allocation = *v->branches;
    if (allocation) {
        o->release(context, allocation);
        *v->branches = 0;
    }
    allocation = *v->coinbase;
    if (allocation) {
        o->release(context, allocation);
        *v->coinbase = 0;
    }
    allocation = *v->text;
    if (allocation) {
        o->release(context, allocation);
        *v->text = 0;
    }

    o->clone(context, v->destination, v->source);
    *v->ready = 1;
    if (*v->source_reset)
        o->reset(context);
    (void)o->broadcast(context, v->condition);
    (void)o->unlock(context, v->mutex);
}

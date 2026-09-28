/* Original 6ec4c..6f188, source literal /tmp/build/src/backend/base.c.
 * Separate offline translation unit; all older source remains unchanged. */
#include "integration/temperature_setup_135.h"

static int has_kind(const struct vn135_resume_description *d, uint32_t kind)
{
    for (int32_t i = 0; i < d->table_count; ++i)
        if (d->table_types[i] == kind) return 1;
    return 0;
}

int32_t vn135_backend_temperature_setup_135(struct vn135_temperature_setup_view *s,
    const struct vn135_temperature_setup_ops *o, void *p)
{
    struct vn135_general_monitor *g = s->backend->general;
    const struct vn135_monitor_handler_ops *h = o->handlers;
    const struct vn135_resume_description *d;
    int32_t initial_count = h->call(p, VN135_H_CHAIN_COUNT, 0, 0);
    int32_t count;
    uint32_t selected = 0, alive = 0;

    if (!has_kind(s->description, 2u) && !has_kind(s->description, 1u))
        return 0;
    for (int32_t i = 0; i < initial_count; ++i) {
        struct vn135_route_chain *chain = &g->chains[i].thermal;
        if (!o->initialize_chain(p, chain, g->mode)) continue;
        if (h->log) h->log(p, 1811, 1, chain->index + 1u, 0, NULL);
        /* Re-read AFTER diagnostic effects; keep the same selected chain. */
        if (!g->suppress_thermal)
            (void)o->stop_chain(p, chain, "Failed to init temp sensors");
    }
    if (has_kind(s->description, 2u)) {
        uint32_t key = o->reply_key(p);
        o->register_reply(p, key, g, 0x78aa4);
    }
    d = s->description;
    for (int32_t i = 0; i < d->table_count; ++i)
        if (d->table_types[i] - 1u <= 1u && s->roles[i] == 2u) ++selected;
    if (selected && !o->check_chip_sensors(p, g)) return -1;
    if (vn135_monitor_chain_decision_135(s->backend, h, p)) return -1;
    count = h->call(p, VN135_H_CHAIN_COUNT, 0, 0);
    for (int32_t i = 0; i < count; ++i) {
        const struct vn135_route_chain *chain = &g->chains[i].thermal;
        alive += (uint32_t)(chain->present && chain->state - 3u > 2u);
    }
    return alive ? 0 : -1;
}

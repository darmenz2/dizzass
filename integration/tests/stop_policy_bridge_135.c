/* Test-only parent unwinding at the original nonreturning process-exit edge.
 * This object is linked into the comparison library, never production cgminer. */
#include "integration/stop_policy_135.h"
#include <setjmp.h>
struct stop_bridge {
    struct vn135_stop_policy *state;
    const struct vn135_stop_policy_ops *stop_ops;
    const struct vn135_monitor_handler_ops *handler_ops;
    void *opaque;
    jmp_buf exit_edge;
};
static int32_t bridge_call(void *opaque, uint32_t entry, uint32_t a, uint32_t b)
{
    struct stop_bridge *c = opaque;
    if (entry == VN135_H_STOP) {
        enum vn135_stop_flow flow = vn135_stop_policy_135(c->state, c->stop_ops, c->opaque);
        if (flow == VN135_STOP_PROCESS_EXIT) longjmp(c->exit_edge, 1);
        return 0; /* Void return is not inspected by 60730. */
    }
    return c->handler_ops->call(c->opaque, entry, a, b);
}
static void bridge_log(void *opaque, uint32_t line, uint32_t level,
                       uint32_t a, uint32_t b, const char *detail)
{
    struct stop_bridge *c = opaque;
    if (c->handler_ops->log)
        c->handler_ops->log(c->opaque, line, level, a, b, detail);
}
int vn135_test_stop_chain_composed_135(struct vn135_stop_policy *state,
    const struct vn135_stop_policy_ops *stop_ops,
    const struct vn135_monitor_handler_ops *handler_ops, void *opaque)
{
    struct stop_bridge c = {.state=state, .stop_ops=stop_ops,
                            .handler_ops=handler_ops, .opaque=opaque};
    const struct vn135_monitor_handler_ops ops = {.call=bridge_call, .log=bridge_log};
    if (setjmp(c.exit_edge)) return VN135_STOP_PROCESS_EXIT;
    vn135_monitor_check_chains_135(state->handlers, &ops, &c);
    return VN135_STOP_RETURNED;
}

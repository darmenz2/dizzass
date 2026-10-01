/* Original d26ac..d2750; isolated project file, not a claimed vendor filename.
 * Only the missing dispatch and typed composition are new. */
#ifdef VN135_TRANSPORT_DISPATCH_135
#include "integration/transport_dispatch_135.h"

int32_t vn135_transport_send_135(const struct vn135_transport_dispatch_135 *table,
    void *device,const uint8_t *payload,uint32_t length)
{
    return table->send_payload(table->context,device,payload,length);
}

struct aml_uart_call {
    const vn135_aml_transport *frame;
    const vn135_uart_ops *uart;
};
static void *frame_allocate(void *opaque,size_t size)
{
    const struct aml_uart_call *c=opaque;
    return c->frame->allocate(c->frame->context,size);
}
static void frame_release(void *opaque,void *pointer)
{
    const struct aml_uart_call *c=opaque;
    c->frame->release(c->frame->context,pointer);
}
static void frame_lock(void *opaque)
{
    const struct aml_uart_call *c=opaque;
    c->frame->lock(c->frame->context);
}
static void frame_unlock(void *opaque)
{
    const struct aml_uart_call *c=opaque;
    c->frame->unlock(c->frame->context);
}
static int32_t frame_write(void *opaque,void *uart,
    const uint8_t *frame,uint32_t size)
{
    const struct aml_uart_call *c=opaque;
    return vn135_uart_write_legacy(uart,c->uart,frame,size);
}
int32_t vn135_aml_uart_send_135(void *opaque,void *device,
    const uint8_t *payload,uint32_t length)
{
    const struct vn135_aml_uart_binding_135 *b=opaque;
    struct aml_uart_call call;
    vn135_aml_transport transport;
    if(!device)return vn135_aml_send_command(NULL,NULL,payload,length);
    /* Binding admission is new, not behavior attributed to d26ac. */
    if(!b || device!=b->device_identity || !b->uart || !b->framing || !b->uart_ops)
        return -2;
    if(!b->framing->allocate || !b->framing->release ||
       !b->framing->lock || !b->framing->unlock || !b->uart_ops->write ||
       !b->uart_ops->lock || !b->uart_ops->unlock ||
       !b->uart_ops->error_number || !b->uart_ops->sleep_ms)
        return -2;
    call=(struct aml_uart_call){b->framing,b->uart_ops};
    transport=(vn135_aml_transport){&call,frame_allocate,frame_release,
                                  frame_lock,frame_unlock,frame_write};
    return vn135_aml_send_command(b->uart,&transport,payload,length);
}
#endif

/* Original d21dc: transport/chip-method initialization, observable projection.
 * The eight selected constructor bodies remain explicit required boundaries.
 * Proof: research/vnishnet-t21-aml-nand-1.3.5/30-reconstructed-unverified/
 *        transport-init/STATIC_PROOF.md
 */
#ifdef VN135_TRANSPORT_INITIALIZE_135
#include "integration/transport_initialize_135.h"

int32_t vn135_transport_initialize_135(uint32_t platform, uint32_t chip,
    uint32_t subtype, const struct vn135_transport_initialize_view_135 *v,
    const struct vn135_transport_initialize_ops_135 *o, void *context)
{
    static const uint32_t send[] = {
        UINT32_C(0x10fa38), UINT32_C(0x11d0cc), UINT32_C(0x117f7c),
        UINT32_C(0xf8048), UINT32_C(0x109740)
    };
    static const uint32_t initialize[] = {
        UINT32_C(0xd2db8), UINT32_C(0xd8c78), UINT32_C(0xea7c8),
        UINT32_C(0xdcbe0), UINT32_C(0xe1450), UINT32_C(0xe60e8),
        UINT32_C(0xf0560), UINT32_C(0xf4448)
    };
    if (platform >= sizeof(send) / sizeof(send[0])) return -1;
    uint32_t selected = send[platform];
    if (platform == 0 && subtype != 0) selected = UINT32_C(0x10f938);
    *v->shared_send_method = selected;
    *v->common_method = UINT32_C(0xd253c);
    if (chip >= sizeof(initialize) / sizeof(initialize[0])) return -1;
    return o->initialize(context, initialize[chip], v->chip_methods);
}
#endif

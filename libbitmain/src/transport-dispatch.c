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

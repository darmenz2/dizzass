/* Compose the existing offline caller with the actual pathname getter.
 * The host open callback records its argument and ALWAYS refuses (-55).
 * No device, thread, mutex, queue, vendor entry or production adapter is used.
 */
#include "integration/chain_work_start_135.h"
#include "xminer/recovery/aml_platform.h"
#include <limits.h>
#include <stdio.h>
#include <string.h>

struct fixture {
    int32_t index, device_index, next_index;
    uint32_t path_method, open_method;
    int change_index;
    struct vn135_shutdown_thread worker;
    struct vn135_chain_work_start_view view;
    unsigned mutex_calls, queue_calls, path_calls, open_calls, create_calls, logs;
    uint32_t last_line;
    const char *observed_path;
    int bad;
};
static int32_t count(void *opaque) { (void)opaque; return 3; }
static int32_t mutex_record(void *opaque, void *object, uint32_t attributes)
{
    struct fixture *f=opaque;
    if (object != f->view.mutex || attributes != 0) f->bad=1;
    ++f->mutex_calls;
    return -11; /* Existing caller intentionally ignores this result. */
}
static int32_t queue_record(void *opaque, void *object, uint32_t capacity,
                            uint32_t stride)
{
    struct fixture *f=opaque;
    if (object != f->view.queue || capacity != 0x800 || stride != 1) f->bad=1;
    ++f->queue_calls;
    if (f->change_index) f->index=f->next_index;
    return -22; /* Same documented existing behavior; no actual queue exists. */
}
static void *selected_path(void *opaque, uint32_t method, int32_t index)
{
    struct fixture *f=opaque;
    ++f->path_calls;
    if (method != UINT32_C(0x11c080)) { f->bad=1; return NULL; }
    /* Explicit test binding only. The ARM identity is data, never executed. */
    return (void *)vn135_aml_uart_path_135((uint32_t)index);
}
static int32_t refuse_open(void *opaque, uint32_t method, void *uart, void *path)
{
    struct fixture *f=opaque;
    ++f->open_calls;
    if (method != UINT32_C(0x10e0c8) || uart != f->view.uart) f->bad=1;
    f->observed_path=path;
    return -55;
}
static int32_t no_create(void *opaque, uint32_t *handle, uint32_t attributes,
                         uint32_t entry, void *argument)
{
    struct fixture *f=opaque;
    (void)handle; (void)attributes; (void)entry; (void)argument;
    ++f->create_calls;
    return -99;
}
static void record_log(void *opaque, uint32_t prefix, uint32_t source,
                       uint32_t group, uint32_t line, uint32_t severity,
                       uint32_t message, uintptr_t argument)
{
    struct fixture *f=opaque;
    (void)prefix; (void)source; (void)group; (void)severity; (void)message;
    (void)argument;
    ++f->logs; f->last_line=line;
}
static const struct vn135_chain_work_start_ops ops = {
    count, mutex_record, queue_record, selected_path, refuse_open, no_create,
    record_log
};
static int scenario(int32_t initial, int change, int32_t next, int running,
                    const char *expected)
{
    struct fixture f={0};
    f.index=initial; f.device_index=-123; f.change_index=change; f.next_index=next;
    f.path_method=UINT32_C(0x11c080); f.open_method=UINT32_C(0x10e0c8);
    f.worker.running=(uint8_t)running;
    f.view=(struct vn135_chain_work_start_view){ &f.index, &f.device_index,
        &f.worker, &f.path_method, &f.open_method, &f, &f.mutex_calls,
        &f.queue_calls, &f.open_calls };
    int32_t rc=vn135_chain_work_start_135(&f.view,&ops,&f);
    if (f.bad || f.create_calls) return 1;
    if (initial < 0 || initial >= 3)
        return !(rc == -1 && f.logs == 1 && f.last_line == 0x2b8 &&
            f.mutex_calls == 0 && f.queue_calls == 0 && f.path_calls == 0 &&
            f.open_calls == 0 && f.device_index == -123);
    if (running)
        return !(rc == 0 && f.logs == 0 && f.mutex_calls == 0 &&
            f.queue_calls == 0 && f.path_calls == 0 && f.open_calls == 0);
    return !(rc == -1 && f.mutex_calls == 1 && f.queue_calls == 1 &&
        f.path_calls == 1 && f.open_calls == 1 && f.logs == 1 &&
        f.last_line == 0x2c8 && f.device_index == (change ? next : initial) &&
        f.observed_path != NULL && strcmp(f.observed_path,expected) == 0);
}
int main(void)
{
    if (scenario(0,0,0,0,"/dev/ttyS3") || scenario(1,0,0,0,"/dev/ttyS2") ||
        scenario(2,0,0,0,"/dev/ttyS1") || scenario(-1,0,0,0,NULL) ||
        scenario(3,0,0,0,NULL) || scenario(INT32_MAX,0,0,0,NULL) ||
        scenario(0,1,-1,0,"") || scenario(0,1,3,0,"") ||
        scenario(0,1,INT32_MAX,0,"") || scenario(0,1,2,0,"/dev/ttyS1") ||
        scenario(0,0,0,1,NULL)) {
        fprintf(stderr,"caller seam mismatch\n"); return 1;
    }
    puts("passed: 11 existing-caller composition cases; every attempted open refused");
    return 0;
}

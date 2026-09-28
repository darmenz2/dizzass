#include "integration/bm1368_control.h"
#include "xminer/recovery/chip1398.h"
#include <string.h>
int dizzass_bm1368_command_encode(enum dizzass_bm1368_command command,
    uint32_t broadcast, uint32_t address, uint32_t reg, uint32_t value,
    uint8_t *out, size_t capacity, size_t *written)
{
    uint8_t packet[11]={0x55,0xaa,0,0,0,0,0,0,0,0,0}, crc;
    size_t n;
    if (!out || !written || broadcast>1 || address>255 || reg>255 ||
        command<DIZZASS_BM1368_INACTIVE || command>DIZZASS_BM1368_SET_CONFIG)
        return DIZZASS_CONTROL_INVALID;
    n=command==DIZZASS_BM1368_SET_CONFIG ? 11u : 7u;
    if ((command<=DIZZASS_BM1368_SET_ADDRESS && (broadcast || reg || value)) ||
        (command==DIZZASS_BM1368_INACTIVE && address) ||
        (command==DIZZASS_BM1368_READ_REGISTER && value))
        return DIZZASS_CONTROL_INVALID;
    if (capacity<n) return DIZZASS_CONTROL_NO_SPACE;
    packet[2]=command==DIZZASS_BM1368_INACTIVE ? 0x53 :
        command==DIZZASS_BM1368_SET_ADDRESS ? 0x40 :
        (uint8_t)((command==DIZZASS_BM1368_READ_REGISTER ? 0x42 : 0x41) |
        (broadcast ? 0x10 : 0));
    packet[3]=(uint8_t)(n-2); packet[4]=(uint8_t)address; packet[5]=(uint8_t)reg;
    if (n==11) {
        packet[6]=(uint8_t)(value>>24); packet[7]=(uint8_t)(value>>16);
        packet[8]=(uint8_t)(value>>8); packet[9]=(uint8_t)value;
    }
    if (vn135_crc5_bits(packet+2,n-3,(n-3)*8,&crc))
        return DIZZASS_CONTROL_INVALID;
    packet[n-1]=crc; memcpy(out,packet,n); *written=n;
    return 0;
}
int dizzass_bm1368_reset_cores(const struct dizzass_bm1368_reset_ops *ops,
    uint32_t fast, uint32_t clock_delay, uint32_t pulse_width,
    struct dizzass_bm1368_reset_result *out)
{
    struct dizzass_bm1368_reset_result result={0};
    uint32_t misc,soft,delay=fast ? 1u : 5u;
    int rc;
    if (!ops || !ops->read_cached || !ops->write_config || !ops->wait_ms ||
        !out || fast>1 || clock_delay>7 || pulse_width>3)
        return DIZZASS_CONTROL_INVALID;
#define STEP(call) do { rc=(call); if (rc) { result.failed_step=result.completed+1; \
    result.callback_status=rc; *out=result; return DIZZASS_CONTROL_CALLBACK; } \
    ++result.completed; } while (0)
    STEP(ops->read_cached(ops->context,0x18,&misc));
    STEP(ops->write_config(ops->context,0x18,misc & ~UINT32_C(0x300)));
    STEP(ops->read_cached(ops->context,0xa8,&soft));
    STEP(ops->read_cached(ops->context,0x18,&misc));
    STEP(ops->write_config(ops->context,0xa8,soft | UINT32_C(0x1f0)));
    STEP(ops->write_config(ops->context,0x18,
        (misc & UINT32_C(0x00f0ffff)) | UINT32_C(0xf0000000)));
    STEP(ops->wait_ms(ops->context,delay));
    STEP(ops->read_cached(ops->context,0x18,&misc));
    STEP(ops->write_config(ops->context,0x18,misc | UINT32_C(0x300)));
    STEP(ops->write_config(ops->context,0x3c,UINT32_C(0x80008b00)));
    STEP(ops->wait_ms(ops->context,delay));
    STEP(ops->write_config(ops->context,0x3c,UINT32_C(0x80008000) |
        (pulse_width<<6) | (clock_delay<<3)));
    STEP(ops->wait_ms(ops->context,delay));
    STEP(ops->write_config(ops->context,0x3c,UINT32_C(0x800082aa)));
    STEP(ops->wait_ms(ops->context,delay));
    STEP(ops->wait_ms(ops->context,10));
#undef STEP
    *out=result; return 0;
}
